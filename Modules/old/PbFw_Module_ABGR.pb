; ===========================================================================
;  FILE : PbFw_Module_RGB.pb
;  NAME : Module RGB::
;  DESC : RGB color funcktions like GreyScale, RGB <-> HSV/HSL 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/09/18
; VERSION  :  0.1 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{  2023/09/18 S.Maag : 
;   - new  Module based on Module_Color
;                       
;}
;{ TODO:
;}
; ============================================================================


;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile ""

DeclareModule ABGR
  ; ----------------------------------------------------------
  
  ; ======================================================================
  ;   S T R U C T U R E S
  ; ======================================================================
  ; for all Structures we use T as prefix (user defined type)
  ; ----------------------------------------------------------------------
  
  ;  Pixel and color formats
  ; ----------------------------------------------------------------------
    
  ; ABGR and RGBA Color orientation depends on Memory Model
  ; Little-Endian, Big-Endian (Intel, Motorla) 
  ; The Linux Kernel Documentation describes all possible Pixel Formats for Images
  ; see https://www.kernel.org/doc/html/v4.14/media/uapi/v4l/pixfmt-packed-rgb.html
  ; At INTEL x86 Processors the Memory Alignment is Lo|Hi
  ; what means that the Lo-Byte of a VAR is at 1st Position in Memory
  
  ; we need for PureBasci programming the following 4
  ; with the PureBasic Command DrawingBufferPixelFormat() we can test which Format is
  ; used. As I figured out:
  ; Standard under Purebasic Windows is ABGR32 and BGR24
  ; Standard under Purebasic Linux   is ?
  
  ; Format    |   b0  |   b1  |   b2  |   b3  | Bytes in Memory
  ; Register  | 31..24| 23..16| 15..8 |  7..0 | Bits in Register
  ;---------------------------------------------------------- 
  ; ABGR-32   |   A   |   B   |   G   |   R   | 4 Byte/Pixel
  ; ARGB-32   |   A   |   R   |   G   |   B   | 4 Byte/Pixel
  ; BGR-24    |   B   |   G   |   R   |   -   | 3 Byte/Pixel
  ; RGB-24    |   R   |   G   |   B   |   -   | 3 Byte/Pixel


  ; x86, x64; ARM32; ARM64
  CompilerIf #True   
  ; ----------------------------------------------------------------------
  ; This is the Standard Windows Alignment RED=LoByte .. Alpha=HiByte
  ; In Memory RGBA but in Processor Register ABGR  
  ; ----------------------------------------------------------------------
    #PbFw_RGB_Red   = 0  ; ByteIndex for RED     TColor\c[idxRed]
    #PbFw_RGB_Green = 1  ; ByteIndex for Green   TColor\c[idxGreen]
    #PbFw_RGB_Blue  = 2  ; ByteIndex for Blue    TColor\c[idxBlue]
    #PbFw_RGB_Alpha = 3  ; ByteIndex for Alpha   TColor\c[idxAlpha]
    #PbFw_RGB_AlphaMask = $FF000000  ; BitMask for Alpha in Byte 3
                                     ; COLOR | AlphaMask sets the Alpha value To 255 (=$FF) 
  CompilerElse
  ; ----------------------------------------------------------------------
  ; This is the Exception Alpha first
  ; ----------------------------------------------------------------------
    #PbFw_RGB_Red   = 2  ; ByteIndex for RED     TColor\c[idxRed]
    #PbFw_RGB_Green = 1  ; ByteIndex for Green   TColor\c[idxGreen]
    #PbFw_RGB_Blue  = 0  ; ByteIndex for Blue    TColor\c[idxBlue]
    #PbFw_RGB_Alpha = 3  ; ByteIndex for Alpha   TColor\c[idxAlpha]
    #PbFw_RGB_AlphaMask = $FF000000  ; BitMask for Alpha in Byte 0
    
  CompilerEndIf

  ; ----------------------------------------------------------------------
  ; TColor Union Structure! Use TColor to handle Colors instead of 
  ;                         a Standard 32Bit Value
  ; ----------------------------------------------------------------------
  Structure TColor
     c.a[0]       ; Access as Array 4Bytes [0..3]                 
     ; w.u[0]       ; Access for 16/15 Bit Colors w As unsigned WORD (unicode)
     Color.l      ; Access as 32Bit Long
  EndStructure
   
  ; Structure for 2 Pixel
  Structure TColor2
    c.TColor[2]  
  EndStructure
  
  ; univeral Pointer to a 32Bit color
  Structure pColor
    col.TColor[0]  
  EndStructure
  
  ; Hue is a degree on the color wheel from 0..360! 0 is red, 120 is green, 240 is blue.
  ; Saturation can be described As the intensity of a color. It is a percentage value from 0% To 100%.
  ;   100% is full color, no shades of gray. 50% is 50% gray, but you can still see the color.
  ;   0% is completely gray; you can no longer see the color
  ; The lightness of a color can be described As how much light you want To give the color,
  ;   where 0% means no light (dark), 50% means 50% light (neither dark nor light), And 100% means full light.
  ; https://www.w3schools.com/colors/colors_hsl.asp
  
  Structure THSL ; 12-Byte
    H.f   ; Hue [0..359°]
    S.f   ; Saturation [0..100%]
    L.f   ; Light [0..100%]
    A.f   ; Alpha [0..100%]
  EndStructure
  
  Structure THSV ; 12-Byte
    H.f   ; Hue 0..359°]
    S.f   ; Saturation [0..100%]
    V.f   ; 
    A.f   ; Alpha [0..100%]
  EndStructure
  
  Structure THSV255
    H.w   ; Hue 0..359°]
    S.w   ; Saturation [0..255]
    V.w   ; Value [0..255]
    A.w   ; Alpha [0..255]     
  EndStructure
  
EndDeclareModule 

Module ABGR
  EnableExplicit
         
  Procedure.i RGBtoHSV255(RGB.l, *HSV.THSV255)
  ; ======================================================================
  ; NAME : RGBtoHSV255
  ; DESC : Conerts a RGB-Color to a HSV-Color where the HSV values
  ; DESC : are 16-Bit-INT-Values H=[0..359], S=[0.255], V=[0..255]
  ; DESC : So the resulting HSV can be used directly as a Vector
  ; DESC : for SSE Matrix/Vector Operations with WORDs
  ; VAR(RGB) : The RGB color value
  ; VAR(*HSV.THSV255) : Pointer to the rsulting HSV Structure
  ; RET : *HSV
  ; ======================================================================
  
    Protected col.TColor, hsv.THSV255
    Protected.w delta
          
    ; Value ranges
    ; v = [0..359]
    ; s = [0..255]
    ; v = [0..255]
    
    col\Color = RGB
    hsv\V = col\c[#PbFw_RGB_Red]
    hsv\V = col\c[#PbFw_RGB_Green]
    hsv\H = col\c[#PbFw_RGB_Blue]
    hsv\A = col\c[#PbFw_RGB_Alpha]
    
    With hsv
      ; v = Max(r,g,b)
      If \H > \S : Swap \H, \S : EndIf ; MaxOf h,s -> s
      If \S > \V : Swap \S, \V : EndIf ; MaxOf s,v -> v => now v = Max(r,g,b) 
      If \S < \H : Swap \H, \S : EndIf ; MinOf s,h -> h => now h = Min(r,g,b)
      ; now it is sorted max/middle/min : v/s/h => v = Max(r,g,b)
   
      Debug "v = " + Str(\v)
      Debug "s = " +Str(\s)
      Debug "h = " +Str(\h)
        
      delta = \V-\H ; delta = max - min
      Debug "delta = " + delta
      
      \S = delta * 255 / \V
      Debug "s = " + Str(\S)
      
      Select \V    ; 
          
        Case col\c[#PbFw_COL_idxRed]
          ; hue red is from 0..119°
          \H = 60 * (col\c[#PbFw_COL_idxGreen] - col\c[#PbFw_COL_idxBlue]) / delta
            
        Case col\c[#PbFw_COL_idxGreen]
          ; hue green is from 120..239°
          \H = 60 * (col\c[#PbFw_COL_idxBlue] - col\c[#PbFw_COL_idxRed]) / delta + 120
            
        Default
         ; hue blue is from 240..359°
         \H = 60 * (col\c[#PbFw_COL_idxRed] - col\c[#PbFw_COL_idxGreen]) / delta + 240
            
      EndSelect           
    EndWith

  EndProcedure
  
  Procedure.l HueRotateRGB(RGBcolor.l, dHue.l)
    ; ======================================================================
    ; NAME : HueRotateRGB
    ; DESC : Do a Color rotation in HSV-ColorSpace on a RGB-Color
    ; DESC : Converts the RGB-Color to HSV-Color, add the Rotation Angle dHue
    ; DESC : and convert HSV back to RGB
    ; DESC : This is the excact version without any aproximation.
    ; DESC : But this Methode will change the Luminance of the Colors
    ; VAR(RGBcolor) : The RGB color value
    ; VAR(dHue) : Hue rotation angle ° : delta hue
    ; RET : hue rotated color 
    ; ======================================================================
  
    Protected ret.TColor
    Protected.l delta
    Protected.l h,s,v
    
    ret\Color = RGBcolor
    
    ; ----------------------------------------------------------------------
    ;  RGB to HSV 
    ; ----------------------------------------------------------------------
   
    ; Value ranges
    ; v = [0..359]
    ; s = [0..255]
    ; v = [0..255]
    
    v = ret\c[#PbFw_COL_idxRed]
    s = ret\c[#PbFw_COL_idxGreen]
    h = ret\c[#PbFw_COL_idxBlue]
    
    ; v = Max(r,g,b)
    If h > s : Swap h,s : EndIf ; MaxOf h,s -> s
    If s > v : Swap s,v : EndIf ; MaxOf s,v -> v => now v = Max(r,g,b) 
    If s < h : Swap h,s : EndIf ; MinOf s,h -> h => now h = Min(r,g,b)
    ; now it is sorted max/middle/min : v/s/h => v = Max(r,g,b)
    
    Debug "v = " + Str(v)
    Debug "s = " +Str(s)
    Debug "h = " +Str(s)

    If v = 0      ; It's black and stay black
      ProcedureReturn ret\Color    
    EndIf
       
    delta = v-h ; delta = max - min
    Debug "delta = " + delta
    
    s = delta * 255 / v
    Debug "s = " + Str(s)
    
    Select v    ; 
        
      Case ret\c[#PbFw_COL_idxRed]
        ; hue red is from 0..119°
        h = 60 * (ret\c[#PbFw_COL_idxGreen] - ret\c[#PbFw_COL_idxBlue]) / delta
          
      Case ret\c[#PbFw_COL_idxGreen]
        ; hue green is from 120..239°
        h = 60 * (ret\c[#PbFw_COL_idxBlue] - ret\c[#PbFw_COL_idxRed]) / delta + 120
          
      Default
       ; hue blue is from 240..359°
       h = 60 * (ret\c[#PbFw_COL_idxRed] - ret\c[#PbFw_COL_idxGreen]) / delta + 240
          
    EndSelect           
    
    Debug "h = " + Str(h)
    
    ; ----------------------------------------------------------------------
    ;  Add dHue and convert back from HSV to RGB 
    ; ----------------------------------------------------------------------
    
    Protected.l i, f, aa, bb, cc
    
    If s = 0    ; grey
      ret\c[#PbFw_COL_idxRed]  = v
      ret\c[#PbFw_COL_idxGreen] = v
      ret\c[#PbFw_COL_idxBlue] = v
    Else
      
      h + dHue          ; add the HueRotation angle, delta h 
      
      ; set h to 0..359       
      While h < 0
        h + 360
      Wend
      While h >= 360
        h -360
      Wend
      
      Debug "h_new = " + Str(h)
              
      i = h/60      
      f = h % 60    
      
      Debug "i = " + Str(i)
      Debug "f = " + Str(f)
      
;     aa = *HSVcolor\V * (1 - *HSVcolor\S)
;     bb = *HSVcolor\V * (1 - (*HSVcolor\S * f))
;     cc = *HSVcolor\V * (1 - (*HSVcolor\S * (1 - f)))

      aa = (v * (255 - s)) / 255
      Debug "v = " + Str(v) + " " +  "s =" + Str(s) 
      bb = (v * (255 - s * f)) / 255
      cc = (v * (255 - s * (255 - f)/255 )) / 255
      
      Debug "aa = " +Str(aa)
      Debug "bb = " + Str(bb)
      Debug "cc = " + Str(cc)

      Select i
        Case 0
          ret\c[#PbFw_COL_idxRed]    = v
          ret\c[#PbFw_COL_idxGreen]  = cc
          ret\c[#PbFw_COL_idxBlue]   = aa
        Case 1
          ret\c[#PbFw_COL_idxRed]   = bb
          ret\c[#PbFw_COL_idxGreen] = v
          ret\c[#PbFw_COL_idxBlue]  = aa
        Case 2
          ret\c[#PbFw_COL_idxRed]   = aa
          ret\c[#PbFw_COL_idxGreen] = v
          ret\c[#PbFw_COL_idxBlue]  = cc
        Case 3
          ret\c[#PbFw_COL_idxRed]   = aa
          ret\c[#PbFw_COL_idxGreen] = bb
          ret\c[#PbFw_COL_idxBlue]  = v
        Case 4
          ret\c[#PbFw_COL_idxRed]   = cc
          ret\c[#PbFw_COL_idxGreen] = aa
          ret\c[#PbFw_COL_idxBlue]  = v
        Case 5
          ret\c[#PbFw_COL_idxRed]   = v
          ret\c[#PbFw_COL_idxGreen] = aa
          ret\c[#PbFw_COL_idxBlue]  = bb
      EndSelect

    EndIf
    
    ProcedureReturn ret\Color
  EndProcedure
    
  Procedure HueRotateMemory(dHue.l, *Buf.TColor, NoOfPixels)
    ; ======================================================================
    ; NAME : HueRotateMemory
    ; DESC : Do Color rotation in HSV-ColorSpace on a RGB-Color Buffer
    ; DESC : (Image)
    ; DESC : Converts the RGB-Color to HSV-Color, add the Rotation Angle dHue
    ; DESC : and convert HSV back to RGB
    ; DESC : This is the excact version without any aproximation.
    ; DESC : But this Methode will change the Luminance of the Colors
    ; VAR(dHue) : Hue rotation angle ° : delta hue
    ; VAR(*Buf.TColor) : Pointer to the Image Buffer
    ; VAR(NoOfPixels) : Number of pixels to convert
    ; RET : hue rotated color 
    ; ======================================================================
    
    Protected ret.TColor
    Protected.i delta
    Protected.i h,s,v
    Protected.i J
    
    If Not *Buf
      ProcedureReturn
    EndIf
    
    For J = 1 To NoOfPixels
      
      ret\Color = *Buf\Color
      
      ; ----------------------------------------------------------------------
      ;  RGB to HSV 
      ; ----------------------------------------------------------------------
      
      ; Value ranges
      ; v = [0..359]
      ; s = [0..255]
      ; v = [0..255]
      
      ; first we copy the R,B,G part into v,s,h
      v = ret\c[#PbFw_COL_idxRed]
      s = ret\c[#PbFw_COL_idxGreen]
      h = ret\c[#PbFw_COL_idxBlue]
      
      ; v = Max(r,g,b) , bring the maximunm to v and the min to h
      If h > s : Swap h,s : EndIf ; MaxOf h,s -> s
      If s > v : Swap s,v : EndIf ; MaxOf s,v -> v => now v = Max(r,g,b) 
      If s < h : Swap h,s : EndIf ; MinOf s,h -> h => now h = Min(r,g,b)
      ; now it is sorted max/middle/min : v/s/h => v = Max(r,g,bl
      
      If v = 0
        Continue    ; jump to NEXT Color is black and stay black
      EndIf
      
;       Debug "v = " + Str(v)
;       Debug "s = " +Str(s)
;       Debug "h = " +Str(s)
     
      delta = v-h ; delta = max - min
;      Debug "delta = " + delta
      
      s = delta * 255 / v     ; s = delta / max
;       Debug "s = " + Str(s)
      
      Select v    ; check the ColorBase red, green or blue 
          
        Case ret\c[#PbFw_COL_idxRed]
          ; hue red is from 0..119°
          h = 60 * (ret\c[#PbFw_COL_idxGreen] - ret\c[#PbFw_COL_idxBlue]) / delta
            
        Case ret\c[#PbFw_COL_idxGreen]
          ; hue green is from 120..239°
          h = 60 * (ret\c[#PbFw_COL_idxBlue] - ret\c[#PbFw_COL_idxRed]) / delta + 120
            
        Case ret\c[#PbFw_COL_idxBlue]
          ; hue blue is from 240..359°
          h = 60 * (ret\c[#PbFw_COL_idxRed] - ret\c[#PbFw_COL_idxGreen]) / delta + 240
            
      EndSelect           
      
     ; Debug "h = " + Str(h)
      
      ; ----------------------------------------------------------------------
      ;  Add dHue and convert back from HSV to RGB 
      ; ----------------------------------------------------------------------
      
      Protected.i i, f, aa, bb, cc
      
      If s = 0    ; grey
        ret\c[#PbFw_COL_idxRed]  = v
        ret\c[#PbFw_COL_idxGreen] = v
        ret\c[#PbFw_COL_idxBlue] = v
      Else
        
        h + dHue          ; add the HueRotation angle, delta h 
        
        ; set h to 0..359
        While h < 0
          h + 360
        Wend
        While h >= 360
          h -360
        Wend
        
        ; Debug "h_new = " + Str(h)
                
        i = h/60      ; 
        f = h-i*60    ; h % 60
                
  ;     Debug "i = " + Str(i)
  ;     Debug "f = " + Str(f)
        
  ;     aa = *HSVcolor\V * (1 - *HSVcolor\S)
  ;     bb = *HSVcolor\V * (1 - (*HSVcolor\S * f))
  ;     cc = *HSVcolor\V * (1 - (*HSVcolor\S * (1 - f)))
  
        aa = (255 - s) * v / 255
        cc = (255 - s * (255 - f)/255 ) *v / 255
        bb = (255 - s * f) * v / 255
         
;         aa = ((256 - s) * v) >> 8
;         bb = ((256 - s * f) * v ) >> 8
;         cc = ((256 - s * (256 - f)>>8 ) *v ) >> 8

;       Debug "aa = " +Str(aa)
;       Debug "bb = " + Str(bb)
;       Debug "cc = " + Str(cc)
  
        Select i
          Case 0
            ret\c[#PbFw_COL_idxRed]   = v
            ret\c[#PbFw_COL_idxGreen] = cc
            ret\c[#PbFw_COL_idxBlue]  = aa
          Case 1
            ret\c[#PbFw_COL_idxRed]   = bb
            ret\c[#PbFw_COL_idxGreen] = v
            ret\c[#PbFw_COL_idxBlue]  = aa
          Case 2
            ret\c[#PbFw_COL_idxRed]   = aa
            ret\c[#PbFw_COL_idxGreen] = v
            ret\c[#PbFw_COL_idxBlue]  = cc
          Case 3
            ret\c[#PbFw_COL_idxRed]   = aa
            ret\c[#PbFw_COL_idxGreen] = bb
            ret\c[#PbFw_COL_idxBlue]  = v
          Case 4
            ret\c[#PbFw_COL_idxRed]   = cc
            ret\c[#PbFw_COL_idxGreen] = aa
            ret\c[#PbFw_COL_idxBlue]  = v
          Case 5
            ret\c[#PbFw_COL_idxRed]   = v
            ret\c[#PbFw_COL_idxGreen] = aa
            ret\c[#PbFw_COL_idxBlue]  = bb
        EndSelect
  
      EndIf ; s <> 0
      
      *Buf\Color = ret\Color        
      *Buf + SizeOf(Long)
    Next   
  EndProcedure

    Structure THSV ; 12-Byte
    H.f   ; Hue 0..359°]
    S.f   ; Saturation [0..100%]
    V.f   ; 
    ;A.f   ; Alpha [0..100%]
  EndStructure
  
    
  Procedure RGBToHSV(RGBcolor.l, *HSVcolor.THSV)
    ; ======================================================================
    ; NAME : RGBToHSV
    ; DESC : converts an RGB color to HSV color
    ; DESC : Basic Code token from PureBasic Forum "FastImage-Project"
    ; VAR(RGBcolor) : The RGB color value
    ; VAR(*HSVcolor.THSV) : Pointer to a HSV-Color Structrue
    ; RET : - 
    ; ======================================================================
  
    Protected.f r, g, b
    Protected.f delta, min
    Protected.i r_temp, g_temp, b_temp
   
    r_temp = Red(RGBcolor)
    g_temp = Green(RGBcolor)
    b_temp = Blue(RGBcolor)
  
    r = r_temp / 255
    g = g_temp / 255
    b = b_temp / 255
   
    If r < g
      min = r
    Else
      min = g
    EndIf
    If b < min
      b = min
    EndIf
   
    If r > g
      *HSVcolor\V = r
    Else
      *HSVcolor\V = g
    EndIf
    If b > *HSVcolor\V
      *HSVcolor\V = b
    EndIf
   
    delta = *HSVcolor\V - min
  
    If *HSVcolor\V = 0
      *HSVcolor\S = 0
    Else
      *HSVcolor\S = delta / *HSVcolor\V
    EndIf
  
    If *HSVcolor\S = 0
      *HSVcolor\H = 0
    Else
      If r = *HSVcolor\V
        *HSVcolor\H = 60 * (g - b) / delta
      ElseIf g = *HSVcolor\V
        *HSVcolor\H = 60 * (b - r) / delta + 120
      ElseIf b = *HSVcolor\V
        *HSVcolor\H = 60 * (r - g) / delta + 240
      EndIf
      If *HSVcolor\H < 0
        *HSVcolor\H + 360
      EndIf
    EndIf
     
  EndProcedure
  
  Procedure.l HSVToRGB(*HSVcolor.THSV)
    ; ======================================================================
    ; NAME : HSVToRGB
    ; DESC : converts a HSB color to RGB color
    ; DESC : Basic Code from PureBasic Forum "FastImage-Project"
    ; VAR(*HSVcolor.THSV) : Pointer to the HSB-Color Structrue
    ; RET :  The RGB-Color value 
    ; ======================================================================
  
    Protected.f f, aa, bb, cc, h_temp
    Protected.f r, g, b
    Protected.i i
   
    If *HSVcolor\S = 0
      r = *HSVcolor\V
      g = *HSVcolor\V
      b = *HSVcolor\V
    Else
      If *HSVcolor\H = 360
        *HSVcolor\H = 0
      EndIf
     
      h_temp = *HSVcolor\H / 60
      i = Int(h_temp)
      f = h_temp - i
     
      aa = *HSVcolor\V * (1 - *HSVcolor\S)
      bb = *HSVcolor\V * (1 - (*HSVcolor\S * f))
      cc = *HSVcolor\V * (1 - (*HSVcolor\S * (1 - f)))
     
      Select i
        Case 0
          r = *HSVcolor\V
          g = cc
          b = aa
        Case 1
          r = bb
          g = *HSVcolor\V
          b = aa
        Case 2
          r = aa
          g = *HSVcolor\V
          b = cc
        Case 3
          r = aa
          g = bb
          b = *HSVcolor\V
        Case 4
          r = cc
          g = aa
          b = *HSVcolor\V
        Case 5
          r = *HSVcolor\V
          g = aa
          b = bb
      EndSelect
    EndIf
   
    ProcedureReturn RGB(Int(r * 255), Int(g * 255), Int(b * 255)) 
  EndProcedure
  
EndModule

UseModule ABGR
  Procedure.q ElapsedMicroSeconds()
    Protected v.Quad, f.Quad
    
    QueryPerformanceFrequency_(f)
    QueryPerformanceCounter_(v)
    
    ProcedureReturn (v\q / (f\q /1e6) ) ; normalize value to MicroSeconds : 1e6 = 1.000.000 = 1Mhz
  EndProcedure

  Define.l Col, hCol
  Define.l r, g, b
  
  Col=RGB(255,0,255)
  
  hcol = HueRotateRGB(Col, 180)
  r = Red(hCol)
  g = Green(hCol)
  b = Blue(hCol)
 
  Debug "hueCol = RGB(" + Str(r) + "," + Str(g) + "," + Str(b) +")"
  
  Define HSV.THSV
  
  RGBToHSV(Col, HSV)
  
  HSV\H + 180
  
  hcol = HSVToRGB(HSV)
  r = Red(hCol)
  g = Green(hCol)
  b = Blue(hCol)
  Debug "classic" 
  Debug "hueCol = RGB(" + Str(r) + "," + Str(g) + "," + Str(b) +")"
  
  Define t1, I
  #Pixels = 1920 * 1080
  
  Dim img.l(#Pixels)
  
  For I = 0 To #Pixels - 1
    img(I) = RGB(255,0,0)  
  Next
  
  t1 = ElapsedMicroSeconds()
  HueRotateMemory(180, @img(0), #Pixels)
  t1 = ElapsedMicroSeconds() - t1
  
  MessageRequester("Time", StrF(t1/1000,3) + " ms")
  
    
;   For I = 1 To #Pixels
;     ;hcol = HueRotateRGB(Col, 180)
;   Next

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 652
; FirstLine = 618
; Folding = --
; Optimizer
; CPU = 5