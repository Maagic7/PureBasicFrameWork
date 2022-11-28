; ===========================================================================
;  FILE : Module_COLOR.pb
;  NAME : Module COLOR
;  DESC : Implements Standard COLOR Functions in a Modul
;  DESC : and supplies Constans for common Colors
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/03/09
; VERSION  :  1.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;{  2022/11/17 S.Maag : 
;   - added universal Pointer pColor for virtual TColor-Array
;   - added some Macros using pColor to get direct access to R,G,B,A                    
;}
; ============================================================================

;{ ====================      M I T   L I C E N S E        ====================
;
; Copyright (c) 2022 Stefan Maag
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ============================================================================
;

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

; XIncludeFile ""

DeclareModule COLOR
  ;- ----------------------------------------------------------------------
  ;- COLORS
  ;- ----------------------------------------------------------------------
  ; Stadard Colors   
  #Black       = 0            ; RGB(0,0,0)
  #Blue        = 16711680     ; RGB(0,0,255)
  #Gray        = 8421504      ; RGB(128,128,128)
  #Green       = 65280        ; RGB(0,255,0)
  #Magenta     = 16711935     ; RGB(255,0,255) 
  #Orange      = 42495        ; RGB(255,165,0) 
  #OrangeRed   = 17919        ; RGB(255,69,0)
  #Pink        = 13353215     ; RGB(255,192,203)
  #Purple      = 8388736      ; RGB(128,0,128) 
  #Red         = 255          ; RGB(255,0,0)
  #White       = 16777215     ; RGB(255,255,255)
  #Violet      = 15631086     ; RGB(238,130,238)
  #Yellow      = 65535        ; RGB(255,255,0) 
  #YellowGreen = 3329434      ; RGB(154,205,50)
  
  #DarkBlue    = 9109504      ; RGB(0,0,139) 
  #DarkGray    = 11119017     ; RGB(169,169,169) 
  #DarkGreen   = 25600        ; RGB(0,100,0)
  #DarkMagenta = 9109643      ; RGB(139,0,139) 
  #DarkOrange  = 36095        ; RGB(255,140,0) 
  #DarkRed     = 139          ; RGB(139,0,0) 
  #DarkViolet  = 13828244     ; RGB(148,0,211) 
  #DeepPink    = 9639167      ; RGB(255,20,147) 
  
  #LightBlue   = 15128749     ; RGB(173,216,230)
  #LightGreen  = 9498256      ; RGB(144,238,144) 
  #LightGray   = 13882323     ; RGB(211,211,211) 
  #LightPink   = 12695295     ; RGB(255,182,193) 
  #LightYellow = 14745599     ; RGB(255,255,224)
  
  ;{ More Colors, definition translated from the NET-Framework 
  ; ----------------------------------------------------------
  ;   ACTIVATE it if you need!!!
  
;   #AliceBlue = 16775408             ; RGB(240,248,255)
;   #AntiqueWhite = 14150650          ; RGB(250,235,215)
;   #Aqua = 16776960                  ; RGB(0,255,255)
;   #Aquamarine = 13959039            ; RGB(127,255,212)
;   #Azure = 16777200                 ; RGB(240,255,255)
;   #Beige = 14480885                 ; RGB(245,245,220)
;   #Bisque = 12903679                ; RGB(255,228,196)
;   #BlanchedAlmond = 13495295        ; RGB(255,235,205)
;   #BlueViolet = 14822282            ; RGB(138,43,226)
;   #Brown = 2763429                  ; RGB(165,42,42)
;   #BurlyWood = 8894686              ; RGB(222,184,135)
;   #CadetBlue = 10526303             ; RGB(95,158,160)
;   #Chartreuse = 65407               ; RGB(127,255,0) 
;   #Chocolate = 1993170              ; RGB(210,105,30) 
;   #Coral = 5275647                  ; RGB(255,127,80) 
;   #CornflowerBlue = 15570276        ; RGB(100,149,237) 
;   #Cornsilk = 14481663              ; RGB(255,248,220) 
;   #Crimson = 3937500                ; RGB(220,20,60) 
;   #Cyan = 16776960                  ; RGB(0,255,255) 
;   #DarkCyan = 9145088               ; RGB(0,139,139) 
;   #DarkGoldenrod = 755384           ; RGB(184,134,11) 
;   #DarkKhaki = 7059389              ; RGB(189,183,107) 
;   #DarkOliveGreen = 3107669         ; RGB(85,107,47) 
;   #DarkOrchid = 13382297            ; RGB(153,50,204) 
;   #DarkSalmon = 8034025             ; RGB(233,150,122) 
;   #DarkSeaGreen = 9157775           ; RGB(143,188,139) 
;   #DarkSlateBlue = 9125192          ; RGB(72,61,139)
;   #DarkSlateGray = 5197615          ; RGB(47,79,79) 
;   #DarkTurquoise = 13749760         ; RGB(0,206,209) 
;   #DeepSkyBlue = 16760576           ; RGB(0,191,255) 
;   #DimGray = 6908265                ; RGB(105,105,105) 
;   #DodgerBlue = 16748574            ; RGB(30,144,255) 
;   #Firebrick = 2237106              ; RGB(178,34,34) 
;   #FloralWhite = 15792895           ; RGB(255,250,240) 
;   #ForestGreen = 2263842            ; RGB(34,139,34) 
;   #Fuchsia = 16711935               ; RGB(255,0,255) 
;   #Gainsboro = 14474460             ; RGB(220,220,220) 
;   #GhostWhite = 16775416            ; RGB(248,248,255) 
;   #Gold = 55295                     ; RGB(255,215,0) 
;   #Goldenrod = 2139610              ; RGB(218,165,32) 
;   #GreenYellow = 3145645            ; RGB(173,255,47) 
;   #Honeydew = 15794160              ; RGB(240,255,240) 
;   #HotPink = 11823615               ; RGB(255,105,180) 
;   #IndianRed = 6053069              ; RGB(205,92,92) 
;   #Indigo = 8519755                 ; RGB(75,0,130) 
;   #Ivory = 15794175                 ; RGB(255,255,240) 
;   #Khaki = 9234160                  ; RGB(240,230,140) 
;   #Lavender = 16443110              ; RGB(230,230,250)
;   #LavenderBlush = 16118015         ; RGB(255,240,245) 
;   #LawnGreen = 64636                ; RGB(124,252,0) 
;   #LemonChiffon = 13499135          ; RGB(255,250,205) 
;   #LightCoral = 8421616             ; RGB(240,128,128) 
;   #LightCyan = 16777184             ; RGB(224,255,255) 
;   #LightGoldenrodYellow = 13826810  ; RGB(250,250,210) 
;   #LightSalmon = 8036607            ; RGB(255,160,122) 
;   #LightSeaGreen = 11186720         ; RGB(32,178,170) 
;   #LightSkyBlue = 16436871          ; RGB(135,206,250) 
;   #LightSlateGray = 10061943        ; RGB(119,136,153) 
;   #LightSteelBlue = 14599344        ; RGB(176,196,222) 
;   #Lime = 65280                     ; RGB(0,255,0) 
;   #LimeGreen = 3329330              ; RGB(50,205,50) 
;   #Linen = 15134970                 ; RGB(250,240,230) 
;   #Maroon = 128                     ; RGB(128,0,0) 
;   #MediumAquamarine = 11193702      ; RGB(102,205,170) 
;   #MediumBlue = 13434880            ; RGB(0,0,205) 
;   #MediumOrchid = 13850042          ; RGB(186,85,211) 
;   #MediumPurple = 14381203          ; RGB(147,112,219)
;   #MediumSeaGreen = 7451452         ; RGB(60,179,113) 
;   #MediumSlateBlue = 15624315       ; RGB(123,104,238) 
;   #MediumSpringGreen = 10156544     ; RGB(0,250,154) 
;   #MediumTurquoise = 13422920       ; RGB(72,209,204) 
;   #MediumVioletRed = 8721863        ; RGB(199,21,133) 
;   #MidnightBlue = 7346457           ; RGB(25,25,112) 
;   #MintCream = 16449525             ; RGB(245,255,250) 
;   #MistyRose = 14804223             ; RGB(255,228,225) 
;   #Moccasin = 11920639              ; RGB(255,228,181) 
;   #NavajoWhite = 11394815           ; RGB(255,222,173) 
;   #Navy = 8388608                   ; RGB(0,0,128) 
;   #OldLace = 15136253               ; RGB(253,245,230) 
;   #Olive = 32896                    ; RGB(128,128,0) 
;   #OliveDrab = 2330219              ; RGB(107,142,35) 
;   #Orchid = 14053594                ; RGB(218,112,214) 
;   #PaleGoldenrod = 11200750         ; RGB(238,232,170) 
;   #PaleGreen = 10025880             ; RGB(152,251,152) 
;   #PaleTurquoise = 15658671         ; RGB(175,238,238) 
;   #PaleVioletRed = 9662683          ; RGB(219,112,147) 
;   #PapayaWhip = 14020607            ; RGB(255,239,213) 
;   #PeachPuff = 12180223             ; RGB(255,218,185) 
;   #Peru = 4163021                   ; RGB(205,133,63) 
;   #Plum = 14524637                  ; RGB(221,160,221) 
;   #PowderBlue = 15130800            ; RGB(176,224,230) 
;   #RosyBrown = 9408444              ; RGB(188,143,143) 
;   #RoyalBlue = 14772545             ; RGB(65,105,225) 
;   #SaddleBrown = 1262987            ; RGB(139,69,19) 
;   #Salmon = 7504122                 ; RGB(250,128,114) 
;   #SandyBrown = 6333684             ; RGB(244,164,96) 
;   #SeaGreen = 5737262               ; RGB(46,139,87) 
;   #SeaShell = 15660543              ; RGB(255,245,238) 
;   #Sienna = 2970272                 ; RGB(160,82,45) 
;   #Silver = 12632256                ; RGB(192,192,192) 
;   #SkyBlue = 15453831               ; RGB(135,206,235) 
;   #SlateBlue = 13458026             ; RGB(106,90,205) 
;   #SlateGray = 9470064              ; RGB(112,128,144)
;   #Snow = 16448255                  ; RGB(255,250,250)
;   #SpringGreen = 8388352            ; RGB(0,255,127)
;   #SteelBlue = 11829830             ; RGB(70,130,180)
;   #Tan = 9221330                    ; RGB(210,180,140)
;   #Teal = 8421376                   ; RGB(0,128,128)
;   #Thistle = 14204888               ; RGB(216,191,216)
;   #Tomato = 4678655                 ; RGB(255,99,71)
;   #Turquoise = 13688896             ; RGB(64,224,208)
;   #Wheat = 11788021                 ; RGB(245,222,179)
;   #WhiteSmoke = 16119285            ; RGB(245,245,245)
 ;}                                  
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
  
  CompilerIf #False  ; Maybe in any circumstance for future use
    ; ----------------------------------------------------------------------
    ; This is the Exception Alpha first
    ; ----------------------------------------------------------------------
    
    #idxRed   = 3  ; ByteIndex for RED     TColor\c[idxRed]
    #idxGreen = 2  ; ByteIndex for Green   TColor\c[idxGreen]
    #idxBlue  = 1  ; ByteIndex for Blue    TColor\c[idxBlue]
    #idxAlpha = 0  ; ByteIndex for Alpha   TColor\c[idxAlpha]
    #AlphaMask = $FF  ; BitMask for Alpha in Byte 0
    
  CompilerElse  ; x86, x64; ARM32; ARM64
    ; ----------------------------------------------------------------------
    ; This is the Standard Windows Alignment RED=LoByte .. Alpha=HiByte
    ; In Memory RGBA but in Processor Register ABGR  
    ; ----------------------------------------------------------------------
   
    #idxRed   = 0  ; ByteIndex for RED     TColor\c[idxRed]
    #idxGreen = 1  ; ByteIndex for Green   TColor\c[idxGreen]
    #idxBlue  = 2  ; ByteIndex for Blue    TColor\c[idxBlue]
    #idxAlpha = 3  ; ByteIndex for Alpha   TColor\c[idxAlpha]
    #AlphaMask = $FF000000  ; BitMask for Alpha in Byte 3
                            ; COLOR | AlphaMask sets the Alpha value To 255 (=$FF)
  CompilerEndIf

  ; ----------------------------------------------------------------------
  ; TColor Union Structure! Use TColor to handle Colors instead of 
  ;                         a Standard 32Bit Value
  ; ----------------------------------------------------------------------
  Structure TColor
    StructureUnion
     Color.l      ; Access as 32Bit Long
     c.a[4]       ; Access as Array 4Bytes [0..3]
     ; c.a[4] defines a fixed 4Byte Array[0..3] for ASCI Bytes 0..255
    EndStructureUnion
  EndStructure
  
  ; univeral Pointer to a 32Bit color
  Structure pColor
    col.TColor[0]  
  EndStructure
  
  Structure THSL ; 12-Byte
    h.f  ; (.f = 4Byte Float)
    s.f
    l.f
  EndStructure
  
  Structure THSV ; 12-Byte
    h.f
    s.f
    v.f
  EndStructure
  ; ------------------ END Pixel and Color formats -----------------------
    
  Declare.l BlendColor (Color1.l, Color2.l, Factor.l=50)

  Declare RGBToHSV(RGBcolor.l, *HSVcolor.THSV)
  Declare.l HSLToRGB(*HSLcolor.THSL)
  Declare.l HSVToRGB(*HSVcolor.THSV)
  
  ;- ----------------------------------------------------------------------
  ;- MACROS
  ;- ----------------------------------------------------------------------
  
  ; ======================================================================
  ; Macros to access the elements fo a *pColor virutal TColor-Array
  ; MacroName + '_' becaue to see it is a Pointer Version! Be carefull!
  ; ======================================================================

   ; 32-Bit Color Value
  Macro pCol_GetColor_(pColor, Index)
    pColor\col[Index]\Color
  EndMacro
  
  Macro pCol_SetColor_(pColor, Index, NewColor)
    pColor\col[Index]\Color = NewColor 
  EndMacro

  ; ALPHA CHANNEL
  Macro pCol_GetAlpha_(pColor, Index)
    pColor\col[Index]\c[#idxAplpha]  
  EndMacro
  
  Macro pCol_SetAlpha_(pColor, Index, NewAlpha)
    pColor\col[Index]\c[#idxAplpha] = NewAlpha 
  EndMacro
  
  ; RED CHANNEL
  Macro pCol_GetRed_(pColor, Index)
    pColor\col[Index]\c[#idxRed]  
  EndMacro
  
  Macro pCol_SetRed_(pColor, Index, NewRed)
    pColor\col[Index]\c[#idxRed] = NewRed
  EndMacro
  
  ; GREEN CHANNEL
  Macro pCol_GetGreen_(pColor, Index)
    pColor\col[Index]\c[#idxGreen]  
  EndMacro
  
  Macro pCol_SetGreen_(pColor, Index, NewGreen)
    pColor\col[Index]\c[#idxGreen] = NewGreen
  EndMacro
  
  ; BLUE CHANNEL
  Macro pCol_GetBlue_(pColor, Index)
    pColor\col[Index]\c[#idxGreen]  
  EndMacro
  
  Macro pCol_SetBlue_(pColor, Index, NewBlue)
    pColor\col[Index]\c[#idxGreen] = NewBlue
  EndMacro
  
  ; ======================================================================
  ; Macros to access the elements fo a TColor Structure
  ; ======================================================================
 
  ; ALPHA CHANNEL
  Macro TCol_GetAlpha (TColor)          ; returns the value of the Alpah Channel, Like PB's Alpha()
    TColor\c[#idxAplpha]  
  EndMacro
  
  Macro TCol_SetAlpha(TColor, NewAlpha) ; sets the Alpha Channel with a new Value
    TColor\c[#idxAlpha] = NewAlpha 
  EndMacro
  
  ; RED CHANNEL
  Macro TCol_GetRed(TColor)             ; returns the value of the Red Channel, Like PB's Red()
    TColor\c[#idxRed]    
  EndMacro
  
  Macro TCol_SetRed(TColor, NewRed)     ; sets the Red Channel with a new Value
    TColor\c[#idxRed] = NewRed 
  EndMacro
  
  ; GREEN CHANNEL
  Macro TCol_GetGreen(TColor)           ; returns the value of the Green Channel, Like PB's Green()
    TColor\c[#idxGreen]    
  EndMacro
  
  Macro TCol_SetGreen(TColor, NewGreen) ; sets the Green Channel with a new Value
    TColor\c[#idxGreen] = NewGreen 
  EndMacro
  
  ; BLUE CHANNEL
  Macro mTCol_GetBlue(TColor)           ; returns the value of the Blue Channel, Like PB's Blue()
    TColor\c[#idxBlue]    
  EndMacro
  
  Macro mac_SetBlue(TColor, NewBlue)    ; sets the Blue Channel with a new Value
    TColor\c[#idxBlue] = NewBlue 
  EndMacro
  
  Macro ToggleRGB(TColor)
  ; ======================================================================
  ; NAME : ToggleRGB
  ; DESC : Toggles the RGB value between RGB and BGR
  ; DESC : 
  ; VAR(TColor) : Color As TColor Structure or *TColor
  ; ======================================================================
    Swap TColor\c[#idxRed], TColor\c[#idxBlue]
  EndMacro
  
  Macro ToggleRGBA(TColor)
  ; ======================================================================
  ; NAME : ToggleRGBA
  ; DESC : Toggles the RGBA value between RGBA and ABGR
  ; DESC : (Little-Endian <=> Big-Endian)
  ; VAR(TColor) : Color As TColor Structure or *TColor
  ; ======================================================================
    Swap TColor\c[#idxAlpha], TColor\c[#idxRed]
    Swap TColor\c[#idxGreen], TColor\c[#idxBlue]
    ; The fastest way would be the Processors ByteSwap Command in Assembler BSWAP
  EndMacro

EndDeclareModule

Module COLOR
  
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.l BlendColor (Color1.l, Color2.l, Blend.l=50)
    ; ======================================================================
    ; NAME : BlendColor
    ; DESC : Mix 2 Colors
    ; DESC : 
    ; VAR(Color1.l) : Color1 Value
    ; VAR(Color2.l) : Color2 Value
    ; VAR Blend : Belending factor [0..100 %] 80 = 80% from Color1 20% from Color2
    ; RET.l : Blended Color 
    ; ======================================================================
    Protected.a R, G, B  ; ASCII BYTE-TYPE 0..255
    
    R = (  Red(Color1) * Blend +   Red(Color2) *(100-Blend)) /100
    G = (Green(Color1) * Blend + Green(Color2) *(100-Blend)) /100
    B = ( Blue(Color1) * Blend +  Blue(Color2) *(100-Blend)) /100
        
    ProcedureReturn RGB(R,G,B)
  EndProcedure
  
  Procedure RGBToHSV(RGBcolor.l, *HSVcolor.THSV)
    ; ======================================================================
    ; NAME : RGBToHSV
    ; DESC : converts an RGB color to HSV color
    ; DESC : Basic Code token from PureBasic Forum "FastImage-Project"
    ; VAR(RGBcolor) : The RGB color value
    ; VAR(*HSVcolor.THSV) : Pointer to a HSV-Color Structrue
    ; RET : - 
    ; ======================================================================
  
    Protected r.f, g.f, b.f
    Protected r_temp.l, g_temp.l, b_temp.l
    Protected delta.f, min.f
  
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
      *HSVcolor\v = r
    Else
      *HSVcolor\v = g
    EndIf
    If b > *HSVcolor\v
      *HSVcolor\v = b
    EndIf
   
    delta = *HSVcolor\v - min
  
    If *HSVcolor\v = 0
      *HSVcolor\s = 0
    Else
      *HSVcolor\s = delta / *HSVcolor\v
    EndIf
  
    If *HSVcolor\s = 0
      *HSVcolor\h = 0
    Else
      If r = *HSVcolor\v
        *HSVcolor\h = 60 * (g - b) / delta
      ElseIf g = *HSVcolor\v
        *HSVcolor\h = 120 + 60 * (b - r) / delta
      ElseIf b = *HSVcolor\v
        *HSVcolor\h = 240 + 60 * (r - g) / delta
      EndIf
      If *HSVcolor\h < 0
        *HSVcolor\h + 360
      EndIf
    EndIf
     
  EndProcedure
  
  Procedure.l HSLToRGB(*HSLcolor.THSL)
    ; ======================================================================
    ; NAME : HSLToRGB
    ; DESC : converts a HSL color to RGB color
    ; DESC : Basic Code token from PureBasic Forum "FastImage-Project"
    ; VAR(*HSLcolor.THSL) : Pointer to the HSL-Color Structrue
    ; RET :  The RGB-Color value 
    ; ======================================================================
  
    Protected r.f, g.f, b.f
    Protected temp1.f, temp2.f
    Protected r_temp.f, g_temp.f, b_temp.f
    Protected h_temp.f
   
    If *HSLcolor\s = 0
      r = *HSLcolor\l
      g = *HSLcolor\l
      b = *HSLcolor\l
    Else
      If *HSLcolor\l < 0.5
        temp2 = *HSLcolor\l * (1 + *HSLcolor\s)
      Else
        temp2 = *HSLcolor\l + *HSLcolor\s - *HSLcolor\l * *HSLcolor\s
      EndIf
     
      temp1 = 2 * *HSLcolor\l - temp2
     
      h_temp = *HSLcolor\h / 360
     
      r_temp = h_temp + 1 / 3
      g_temp = h_temp
      b_temp = h_temp - 1 / 3
     
      If r_temp < 0
        r_temp + 1
      ElseIf r_temp > 1
        r_temp - 1
      EndIf
     
      If g_temp < 0
        g_temp + 1
      ElseIf g_temp > 1
        g_temp - 1
      EndIf
     
      If b_temp < 0
        b_temp + 1
      ElseIf b_temp > 1
        b_temp - 1
      EndIf
     
      If 6 * r_temp < 1
        r = temp1 + (temp2 - temp1) * 6 * r_temp
      ElseIf 2 * r_temp < 1
        r = temp2
      ElseIf 3 * r_temp < 2
        r = temp1 + (temp2 - temp1) * ((2 / 3) - r_temp) * 6
      Else
        r = temp1
      EndIf
     
      If 6 * g_temp < 1
        g = temp1 + (temp2 - temp1) * 6 * g_temp
      ElseIf 2 * g_temp < 1
        g = temp2
      ElseIf 3 * g_temp < 2
        g = temp1 + (temp2 - temp1) * ((2 / 3) - g_temp) * 6
      Else
        g = temp1
      EndIf
     
      If 6 * b_temp < 1
        b = temp1 + (temp2 - temp1) * 6 * b_temp
      ElseIf 2 * b_temp < 1
        b = temp2
      ElseIf 3 * b_temp < 2
        b = temp1 + (temp2 - temp1) * ((2 / 3) - b_temp) * 6
      Else
        b = temp1
      EndIf
    EndIf
     
    ProcedureReturn RGB(Int(r * 255), Int(g * 255), Int(b * 255))
  
  EndProcedure
  
  Procedure.l HSVToRGB(*HSVcolor.THSV)
    ; ======================================================================
    ; NAME : HSVToRGB
    ; DESC : converts a HSB color to RGB color
    ; DESC : Basic Code from PureBasic Forum "FastImage-Project"
    ; VAR(*HSVcolor.THSV) : Pointer to the HSB-Color Structrue
    ; RET :  The RGB-Color value 
    ; ======================================================================
  
    Protected f.f, i.l, aa.f, bb.f, cc.f
    Protected r.f, g.f, b.f
    Protected h_temp.f
   
    If *HSVcolor\s = 0
      r = *HSVcolor\v
      g = *HSVcolor\v
      b = *HSVcolor\v
    Else
      If *HSVcolor\h = 360
        *HSVcolor\h = 0
      EndIf
     
      h_temp = *HSVcolor\h / 60
      i = Int(h_temp)
      f = h_temp - i
     
      aa = *HSVcolor\v * (1 - *HSVcolor\s)
      bb = *HSVcolor\v * (1 - (*HSVcolor\s * f))
      cc = *HSVcolor\v * (1 - (*HSVcolor\s * (1 - f)))
     
      Select i
        Case 0
          r = *HSVcolor\v
          g = cc
          b = aa
        Case 1
          r = bb
          g = *HSVcolor\v
          b = aa
        Case 2
          r = aa
          g = *HSVcolor\v
          b = cc
        Case 3
          r = aa
          g = bb
          b = *HSVcolor\v
        Case 4
          r = cc
          g = aa
          b = *HSVcolor\v
        Case 5
          r = *HSVcolor\v
          g = aa
          b = bb
      EndSelect
    EndIf
   
    ProcedureReturn RGB(Int(r * 255), Int(g * 255), Int(b * 255))
  
  EndProcedure

EndModule

;- ========  Module - Example ========



CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  UseModule Color
  
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

  Define *pCol.pColor
  *pCol\col[0]\c[#idxAlpha] = 255
  *pCol\col[0]\Color = 255
CompilerEndIf  

DisableExplicit


; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 562
; Folding = 4-----
; Optimizer
; CPU = 2