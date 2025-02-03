; ===========================================================================
;  FILE : PbFw_Module_COLOR.pb
;  NAME : Module COLOR::
;  DESC : Implements Standard COLOR Functions in a Modul
;  DESC : and supplies Constants for common Colors
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/03/09
; VERSION  :  0.1 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{  
;   2025/02/02 S.Maag : Removed Macros and Functions moved to Modul PB::
;                       Rework of the functions
;}
;{ TODO:
;}
; ============================================================================


;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::   FrameWork control Module
XIncludeFile "PbFw_Module_PB.pb"          ; PB::     PureBasic extention Module

DeclareModule COLOR
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
            
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
    ;A.f   ; Alpha [0..100%]
  EndStructure
  
  Structure THSV ; 12-Byte
    H.f   ; Hue 0..359°]
    S.f   ; Saturation [0..100%]
    V.f   ; 
    ;A.f   ; Alpha [0..100%]
  EndStructure
  
  ; 3:3 Matrix Structure for ColorSpace adjusting
  Structure TColorMatrix
    m11.f : m12.f : m13.f
    m21.f : m22.f : m23.f
    m31.f : m32.f : m33.f
  EndStructure

  ; ------------------ END Pixel and Color formats -----------------------
    
  Declare.l BlendColor(Color1.l, Color2.l, Alpha.a=127)

  Declare RGBToHSV(RGBcolor.l, *HSVcolor.THSV)
  Declare.l HSLtoRGB(*HSLcolor.THSL, Alpha.a=0)
  Declare.l HSVToRGB(*HSVcolor.THSV, Alpha.a=0)
  
  ;- ----------------------------------------------------------------------
  ;- MACROS
  ;- ----------------------------------------------------------------------  

EndDeclareModule

Module COLOR
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
    
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
      
  Procedure.l BlendColor(Color1.l, Color2.l, Alpha.a=127)
  ; ======================================================================
  ; NAME : BlendColor
  ; DESC : Mix 2 Colors with user defined Alpha
  ; DESC : The Alpha Channels of the Colors are ignored
  ; VAR(Color1.l) : Color1 Value
  ; VAR(Color2.l) : Color2 Value
  ; VAR(Alpha.a=127) : Alpha belending for Color 1 [0..255 = 0..100%]
  ; RET.l : Blended Color with Alpha =255 intransparent
  ; ======================================================================
    
    Protected.i Alpha1, Alpha2 
    
    Protected.PB::TSystemColor c1, c2  
    
    Alpha1 = Alpha
    Alpha2 = 255 - Alpha1
    
    c1\col = Color1
    c2\col = Color2
    
    c1\RGB\R = (c1\RGB\R * Alpha1 + c2\RGB\G * Alpha2) >> 8
    c1\RGB\G = (c1\RGB\G * Alpha1 + c2\RGB\G * Alpha2) >> 8
    c1\RGB\B = (c1\RGB\B * Alpha1 + c2\RGB\B * Alpha2) >> 8
    c1\RGB\A = 255    ; the Alpha of the returned color is fully intransparent
          
    ProcedureReturn c1\col
  EndProcedure
  
  Procedure.l BlendColorRGBA(Color1.l, Color2.l)
  ; ======================================================================
  ; NAME : BlendColorRGBA
  ; DESC : Mix 2 Colors with Alpha Channel. 
  ; DESC : Alpha Channel from Color 1 is used for Blending
  ; VAR(Color1.l) : Color1 Value
  ; VAR(Color2.l) : Color2 Value
   ; RET.l : Blended Color with Alpha =255 intransparent
  ; ======================================================================
    
    Protected.i Alpha1, Alpha2 
    
    Protected.PB::TSystemColor c1, c2  
    
    c1\col = Color1
    c2\col = Color2
    
    Alpha1 = c1\RGB\a 
    Alpha2 = 255 - Alpha1
     
    c1\RGB\R = (c1\RGB\R * Alpha1 + c2\RGB\G * Alpha2) >> 8
    c1\RGB\G = (c1\RGB\G * Alpha1 + c2\RGB\G * Alpha2) >> 8
    c1\RGB\B = (c1\RGB\B * Alpha1 + c2\RGB\B * Alpha2) >> 8
    c1\RGB\A = 255    ; the Alpha of the returned color is fully intransparent
          
    ProcedureReturn c1\col
  EndProcedure

  Procedure RGBtoHSV(RGBcolor.l, *HSVcolor.THSV)
  ; ======================================================================
  ; NAME : RGBtoHSV
  ; DESC : converts RGB color to HSV color
  ; DESC : Basic Code token from PureBasic Forum "FastImage-Project"
  ; VAR(RGBcolor) : The RGB color value
  ; VAR(*HSVcolor.THSV) : Pointer to a HSV-Color Structrue
  ; RET : - 
  ; ======================================================================
  
    Protected.f r, g, b
    Protected.f delta, min
    Protected SysRGB.PB::TSystemColor
       
    #_ColorFactor_ = 0.00392156885937  ; = 1/255
    
    SysRGB\col = RGBcolor ; move the Color to a SystemColor Structure
        
    r= #_ColorFactor_ * SysRGB\RGB\R
    g= #_ColorFactor_ * SysRGB\RGB\G
    b= #_ColorFactor_ * SysRGB\RGB\B
        
    PB::MinOf3(min,r,g,b)           ;  min        = Min(r,g,b)
    PB::MaxOf3(*HSVcolor\V, r,g,b)  ; *HSVcolor\V = Max(r,g,b)
       
    delta = *HSVcolor\V - min
  
    If *HSVcolor\V = 0
      *HSVcolor\S = 0
      *HSVcolor\H = 0
    Else
      *HSVcolor\S = delta / *HSVcolor\V
      
      If r = *HSVcolor\V
        *HSVcolor\H = 60 * (g - b) / delta
      ElseIf g = *HSVcolor\V
        *HSVcolor\H = 120 + 60 * (b - r) / delta
      ElseIf b = *HSVcolor\V
        *HSVcolor\H = 240 + 60 * (r - g) / delta
      EndIf
      
      If *HSVcolor\H < 0
        *HSVcolor\H + 360
      EndIf      
    EndIf       
  EndProcedure
  
  Procedure.l HSLtoRGB(*HSLcolor.THSL, Alpha.a=0)
  ; ======================================================================
  ; NAME : HSLtoRGB
  ; DESC : converts a HSL color to RGB color
  ; DESC : Basic Code token from PureBasic Forum "FastImage-Project"
  ; VAR(*HSLcolor.THSL) : Pointer to the HSL-Color Structrue
  ; RET :  The RGB-Color value 
  ; ======================================================================
  
    Protected.f r, g, b
    Protected.f temp1, temp2
    Protected.f r_temp, g_temp, b_temp
     
    If *HSLcolor\S = 0
      r = *HSLcolor\L
      g = *HSLcolor\L
      b = *HSLcolor\L
    Else
      
      If *HSLcolor\L < 0.5
        temp2 = *HSLcolor\L * (1 + *HSLcolor\S)
      Else
        temp2 = *HSLcolor\L + *HSLcolor\S - *HSLcolor\L * *HSLcolor\S
      EndIf
     
      temp1 = 2 * *HSLcolor\L - temp2
          
      g_temp = *HSLcolor\H * (1/360)
      b_temp = g_temp - 1/3
      r_temp = g_temp + 1/3
      
      ; bring back r_temp -> {0..1}
      If r_temp < 0
        r_temp + 1
      ElseIf r_temp > 1
        r_temp - 1
      EndIf
     
      ; bring back g_temp -> {0..1}
      If g_temp < 0
        g_temp + 1
      ElseIf g_temp > 1
        g_temp - 1
      EndIf
     
      ; bring back b_temp -> {0..1}
      If b_temp < 0
        b_temp + 1
      ElseIf b_temp > 1
        b_temp - 1
      EndIf
     
      If r_temp < 1/6
        r = temp1 + (temp2 - temp1) * 6 * r_temp
      ElseIf r_temp < 1/2
        r = temp2
      ElseIf r_temp < 2/3
        r = temp1 + (temp2 - temp1) * ((2 / 3) - r_temp) * 6
      Else
        r = temp1
      EndIf
     
      If g_temp < 1/6
        g = temp1 + (temp2 - temp1) * 6 * g_temp
      ElseIf g_temp < 1/2
        g = temp2
      ElseIf g_temp < 2/3
        g = temp1 + (temp2 - temp1) * ((2/3) - g_temp) * 6
      Else
        g = temp1
      EndIf
     
      If b_temp < 1/6
        b = temp1 + (temp2 - temp1) * 6 * b_temp
      ElseIf b_temp < 1/2
        b = temp2
      ElseIf b_temp < 2/3
        b = temp1 + (temp2 - temp1) * ((2 / 3) - b_temp) * 6
      Else
        b = temp1
      EndIf
    EndIf
            
    ProcedureReturn RGBA(Int(r * 255), Int(g * 255), Int(b * 255), Alpha)  
  EndProcedure
  
  Procedure.l HSLtoRGB_INT(H=360, S=100, L=100, Alpha.a=0)
  ; ======================================================================
  ; NAME : HSLtoRGB_INT
  ; DESC : converts a HSL color to RGB color. HSL values as INT
  ; DESC : This is the Fast version of HSL to RGB
  ; VAR(H=360) : The H value [0..360]
  ; VAR(S=100) : The S value [0..100]
  ; VAR(L=100) : The L value [0..100]
  ; RET.l : The RGB-Color value 
  ; ======================================================================
    
    ; h[0,360], s[0,100], l[0,100]
    
    Protected.i c, x, r, g, b
    
    c = L
    If L > 50
      c = 100 - c
    EndIf
    
    c= c * S    
    L= 100 * L - c
    c= c + c
    
    H = (H * 1118481) >> 10
    If H & $10000
      x = c
      c = ((~H & $ffff) * x) >> 16
    Else
      x = ((H & $ffff) * c) >> 16
    EndIf
    H >> 17
    
    If H < 1
      r = c + L 
      g = x + L 
      b = L
    ElseIf H = 1
      r = L 
      g = c + L 
      b = x + L
    Else
      r = x + L 
      g = L 
      b = c + L
    EndIf  
    
    r = (r*106955+$200000) >> 22
    g = (g*106955+$200000) >> 22
    b = (b*106955+$200000) >> 22  
    
    ProcedureReturn RGBA(r, g, b, Alpha)
  EndProcedure

  Procedure.l HSVtoRGB(*HSVcolor.THSV, Alpha.a=0)
  ; ======================================================================
  ; NAME : HSVtoRGB
  ; DESC : converts a HSB color to RGB color
  ; DESC : Basic Code from PureBasic Forum "FastImage-Project"
  ; VAR(*HSVcolor.THSV) : Pointer to the HSV-Color Structrue
  ; RET.l : The RGB-Color value 
  ; ======================================================================
  
    Protected.f r, g ,b, aa, bb, cc, f, h_temp
    Protected.i n
   
    If *HSVcolor\S = 0
      r = *HSVcolor\V
      g = *HSVcolor\V
      b = *HSVcolor\V
    Else
      If *HSVcolor\H = 360
        *HSVcolor\H = 0
      EndIf
     
      h_temp = *HSVcolor\H * (1/60)
      n = Int(h_temp)
      f = h_temp - n
     
      aa = *HSVcolor\V * (1 - *HSVcolor\S)
      bb = *HSVcolor\V * (1 - (*HSVcolor\S * f))
      cc = *HSVcolor\V * (1 - (*HSVcolor\S * (1 - f)))
     
      Select n
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
   
    ProcedureReturn RGBA(Int(r * 255), Int(g * 255), Int(b * 255), Alpha) 
  EndProcedure
  
EndModule

;- ========  Module - Example ========



CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  UseModule COLOR
  
  #Window = 0
  #Gadget = 1
  #Font   = 2
  
  Define Event
  
  If OpenWindow(#Window, 0, 0, 200, 200, "Modul Color Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered)
    
    CanvasGadget(#Gadget, 10, 10, 180, 180)

    
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
    
  EndIf

CompilerEndIf  

DisableExplicit


; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 194
; FirstLine = 191
; Folding = --
; Optimizer
; CPU = 2