; ===========================================================================
;  FILE : ECAD.pb
;  NAME : Module ECAD
;  DESC : Implements the ECAD Types and Structures in a Modul
;  DESC : Use ECAD::{Name of Object} to access from other Modules
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/09/09
; VERSION  :  1.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;             
; ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; All files are already included in ECAD_Main.pb! 
; It's just to know which Include Files are necessary

; XIncludeFile ""

DeclareModule ECAD

; ======================================================================
;   S T R U C T U R E S
; ======================================================================
; for all Structures we use T as prefix (user defined type)
; ----------------------------------------------------------------------

;- ----------------------------------------------------------------------
;- Basic STRUCTURES Point, 3DPoint, Custom DashPath
;  ----------------------------------------------------------------------

; We use .Double for Coordinates, because the VectorDrawing Library
; needs .Double too!

Structure TPoint
  X.d     ; X As Double (64Bit Float)
  Y.d     ; Y As Double (64Bit Float)
EndStructure

Structure TPoint3D
  X.d
  Y.d
  Z.d
EndStructure

Structure TSize
  dX.d    ; dimension, delta X = width
  dY.d    ; dimension, delta Y = height
EndStructure

Structure TSize3D
  dX.d    ; dimension, delta X = width
  dY.d    ; dimension, delta Y = height
  dZ.d    ; dimension, delta Z = depth
EndStructure

; 128Bit MD5 Structure
Structure TMD5
  lo.q      ; 64 Bit lo of 128Bit MD5
  hi.q      ; 64 Bit Hi of 128Bit MD5
EndStructure

; This is the State of a Elemnt and must be implemented by all Element Structures
; like TLine, TCircle, ... , TPageFrame, TPage ...
Structure TState
  Layer.l   ; No of grafical Layer
  Groupe.l  ; Number of the associated group
  xHide.w   ; #FALSE=visible, #TRUE=Hider
EndStructure

Enumeration eFillStyle
  #FillStyle_Transparent = 0     ; Transparent = without filling
  #FillStyle_Solid               ; with solid filling
  #FillStyle_Pattern             ; Musterfüllung (z.B. gestreift)
  #FillStyle_Image               ; Filled with an Image (.bmp, .png, .jpg)
EndEnumeration

Enumeration eLineStyle
  #LineStyle_Solid       ; Solid Line   : StrokePath()
  #LineStyle_Dash        ; ------ Line  : DashPath()
  #LineStyle_Dot         ; ..... Line   : DotPath()
  #LineStyle_DashDot     ; -.-.- Line   : CustomDashPath()
  #LineStyle_DashDotDot  ; -..-..- Line : CustomDashPath()
EndEnumeration

; For the DashDot [- . - .] and DashDotDot [- . . - . .] LineStile we must define our 
; custom DashPath(). CustomDashPath() need an Array with the Style Definition
Global Dim ECAD_DashDash.d(3)     ; custom DashPath-Array for [- -] LineStyle
Global Dim ECAD_DashDotDot.d(5)   ; custom DashPath-Array for [- . . ] LineStyle

;[- -] Definiton
ECAD_DashDash(0) = 5 ; Length 1st dash [mm]
ECAD_DashDash(1) = 5 ; Distance [mm]
ECAD_DashDash(2) = 5 ; Length 2nd dash [mm]
ECAD_DashDash(3) = 5 ; Distance [mm]
;[- . . ] Definition
ECAD_DashDotDot(0) = 5 ; Length 1st dash [mm]
ECAD_DashDotDot(1) = 5 ; Distance [mm]
ECAD_DashDotDot(2) = 0 ; 1st Dot 
ECAD_DashDotDot(3) = 5 ; Distance [mm]
ECAD_DashDotDot(4) = 0 ; 2nd Dot 
ECAD_DashDotDot(5) = 5 ; Distance [mm]

Structure TLineStyle
  Col.l                 ; Color
  Width.d               ; Line width
  Style.l               ; LineStyle
EndStructure

Structure TFillStyle
  Color.l               ; Fill Color
  GradientColor.l       ; Gradient Color {Farbverlauf}
  Style.l               ; Fill Style  
EndStructure

;- ----------------------------------------------------------------------
;-    STRUCTURES FOR GRAPHIC ELEMENTS
;  ----------------------------------------------------------------------

; Orientation used for all operations where we can set a direction
; like for Texts, Symbols ...
Enumeration eDirection
  #Right ; 0°
  #Down  ; 90°
  #Left  ; 180°  
  #Up    ; 270°
EndEnumeration

Enumeration eGraphObj
  #GraphObj_Line       ; single Line
  #GraphObj_PloyLine   ; Polyline
  #GraphObj_Polygon    ; filled Polygon structre
  #GraphObj_Rect       ; Rectangle
  #GraphObj_RoundRect  ; Rounded Rectangle
  #GraphObj_Circle     ; Circle
  #GraphObj_Ellipse    ; Ellipse
  #GraphObj_TriAngle   ; Triangle
  #GraphObj_Arrow      ; Arrow
EndEnumeration

Structure TLine
  ;TypeID.l               ; Type-ID        
  P1.TPoint               ; Start-Point
  P2.TPoint               ; End-Point
  Style.TLineStyle        ; Line-Style-Defintion
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TPolyLine
  ;TypeID.l               ; Type-ID        
  Style.TLineStyle        ; Line-Style-Defintion
  List LPoints.TPoint()   ; Points List
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TPolygon
  ;TypeID.l               ; Type-ID        
  LineStyle.TLineStyle    ; Line-Style-Defintion
  FillStyle.TFillStyle    ; Fill-Style-Deintiion
  List LPoints.TPoint()   ; Points List
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TTriAngle
  P1.TPoint               ; Point 1
  P2.TPoint               ; Point 2
  P3.TPoint               ; Point 3
  LineStyle.TLineStyle    ; Line-Style-Defintion
  FillStyle.TFillStyle    ; Fill-Style-Deintiion
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TRect           ; #PB Box
  ;TypeID.l               ; Type-ID        
  P1.TPoint               ; Start Point
  Size.TSize              ; Width and height
  LineStyle.TLineStyle    ; Line-Style-Defintion
  FillStyle.TFillStyle    ; Fill-Style-Deintiion
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TRoundRect Extends TRect  ; #PB RoundBox
  Rx.d                    ; Radius x
  Ry.d                    ; Radius y
EndStructure

Structure TCircle
  ;TypeID.l               ; Type-ID        
  P1.TPoint               ; middle point
  R.d                     ; radius
  LineStyle.TLineStyle    ; Line-Style-Defintion
  FillStyle.TFillStyle    ; Fill-Style-Deintiion
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TEllipse
  ;TypeID.l               ; Type-ID        
  P1.TPoint               ; middle point
  Rx.d                    ; Radius x
  Ry.d                    ; Radius y
  LineStyle.TLineStyle    ; Line-Style-Defintion
  FillStyle.TFillStyle    ; Fill-Style-Deintiion  
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TArrow
  PT.TPoint               ; Start point
  Length.d                ; Length of the Arrow
  Width.d                 ; Width of the Arrow
  Direction.i             ; use Enum eDirection : #Right/#Down/#Left/#Up
  LineStyle.TLineStyle    ; Line-Style-Defintion
  FillStyle.TFillStyle    ; Fill-Style-Deintiion
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

; Structure to define differnt graphical Objects in a Graphic-Element-List
Structure TGraphObj
  *Obj                  ; Pointer to the graphical Object [Line, PolyLine, Polygon, Rect, ...]
  Type.l                ; eGraphObj-Type [Line, PolyLine, Polygon, Rect, ...]
EndStructure

;- ----------------------------------------------------------------------
;-  STRUCTURES FOR TEXT ELEMENTS
;  ----------------------------------------------------------------------

Enumeration eTextAlign
  #TextAlign_UpLeft
  #TextAlign_UpMiddle
  #TextAlign_UpRight
  #TextAlign_DownLeft
  #TextAlign_DownMiddle
  #TextAlign_DownRight 
EndEnumeration

#Font_BOLD = #PB_Font_Bold
#Font_Italic = #PB_Font_Italic
#Font_StrikeOut = #PB_Font_StrikeOut
#Font_Underline = #PB_Font_Underline

Structure TFont   ; Vector Fonts only
  FontID.i
  Size.l
  Style.l         ; #PB_Font_Bold, #PB_Font_Italic
EndStructure

Structure TText
  Txt.s               ; the Text
  Align.l             ; how to align the Text:  [Enumeration eTextAlign UpLeft, UpMiddle, UpRight, ...]
  Direction.l         ; Enumeration eDirection [#Right, #Left, #Up, #Down]
  Color.i             ; Text Color
  Origin.TPoint       ; origin of the Text [x,y]
  Language.l          ; 
  xDoNotTranslate.w   ; Bool: #TRUE= Do not translate    
  State.TState        ; Status: LayerNo, Hide ...
EndStructure

;- ----------------------------------------------------------------------
;-   STRUCTURES FOR SYMBOLS 
; ----------------------------------------------------------------------

Enumeration ePinDirection
  #PinDirection_up    
  #PinDirection_right 
  #PinDirection_down 
  #PinDirection_left 
  #PinDirection_inside
EndEnumeration

Enumeration ePinType
  #PIN_Standard
  #PIN_PLC_UniversalIO
  #PIN_PLC_DigitalIn
  #PIN_PLC_DigitalOut
  #PIN_PLC_AnalogIN
  #PIN_PLC_AnalogOut
  #PIN_PLC_AUX
EndEnumeration

Structure TPin
  No.l              ; Pin Number
  Pos.TPoint        ; Position x,y
  Type.l            ; Pin-Type ePinType
  Direction.l       ; ePinDirection
  Text.TText        ; Standard Text (Anschlussbezeichung)
  State.TState      ; Status: LayerNo, Hide ...
EndStructure

Structure TSymbol
  ID.l                      ; Symbol Number
  Origin.TPoint             ; Symbol origin in Symbol Editor
  Pos.TPoint                ; Startposition x,y on Page or Macro
  MD5.TMD5                  ; MD5 Hash - used to dedect changed Symbols
  Name.s                    ; Symbol Name
  ClsID.i                   ; Symbol Class
  SubCls.i                  ; Symbol SubClass
  List LGraph.TGraphObj()   ; List of Pointers To the grafical Elements (EcadLine, EcadPolyLine ...)
  List LText.TText()        ; List of text Elements
  List LPins.TPin()         ; List of Pins
  State.TState              ; Status: LayerNo, Hide ...
EndStructure

; ----------------------------------------------------------------------
; SYMBOL CLASSES 
; ----------------------------------------------------------------------


; 390 Montagezubehör
; 391 Schaltschrank
; 392 Montageplatte
; 393 Kabelkanal
; 394 Montageschiene
; 395 Klemmenabschluss
; 396 Stromschiene

; 400 Einzelgerät
; 410 Hydraulikgerät
; 420 MSR

; 500 Klemme
; 510 Stecker
; 620 SPS
; 690 BlackBox

; 1000 Schütz Hauptelement
; 1010 Schalter Hauptelement
; 1020 Sicherungs Hauptelement
; 1030 Großgeräte Hauptelement

; Same numbers as in ElekctroCAD 9.0
#ECAD_CLASS_Acessory        = 390   ; Montagezubehör
#ECAD_CLASS_SwitchBoard     = 391   ; Schaltschrank
#ECAD_CLASS_SUBPLATE        = 392   ; Montageplatte
#ECAD_CLASS_CableChannel    = 393   ; Kabelkanal
#ECAD_CLASS_MountingRail    = 394   ; Montageschiene
#ECAD_CLASS_TerminalEnd     = 395   ; Klemmenabschluss
#ECAD_CLASS_Busbar          = 396   ; Stromschiene

#ECAD_CLASS_SingleDevice    = 400   ; Einzelgerät
#ECAD_CLASS_HydraulicDevice = 410   ; Hydraulikgerät
#ECAD_CLASS_MAC             = 420   ; (MSR) Messen steuern regeln, (MAC) measurement and control

#ECAD_CLASS_Terminal        = 500   ; Klemme
#ECAD_CLASS_Plug            = 510   ; Stecker

#ECAD_CLASS_PLC             = 620   ; SPS
#ECAD_CLASS_BlackBox        = 690   ; Black-Box

#ECAD_CLASS_ContacorMain    = 1000  ; Schütz Hauptelement
#ECAD_CLASS_SwitchMain      = 1010  ; Schalter Hauptelement
#ECAD_CLASS_FuseMain        = 1020  ; Sicherungs Hauptelement
#ECAD_CLASS_DeviceMain      = 1030  ; Großgeräte Hauptelement

Structure TSymbolClass
  ID.i                ; #ECAD_CLASS_Acessory = 390
  Name.s              ; "Acessory"
EndStructure
  
;- ----------------------------------------------------------------------
;-  STRUCTURES FOR CABLES AND WIRES 
;  ----------------------------------------------------------------------

; Datas for AWG Wire-System

; AWG   d[mm]   A[mm²]  Ohm/km  metr.mm²
; 1     7,35	  42,41	  0,42	  50
; 2	    6,54	  33,63	  0,53	  35
; 3	    5,83	  26,67	  0,67	  -
; 4	    5,19	  21,15	  0,84	  25
; 5	    4,62	  16,77	  1,06	  -
; 6	    4,12	  13,30	  1,34	  16
; 7	    3,66	  10,55	  1,69	  -
; 8	    3,26	  8,37	  2,13	  10
; 9	    2,91	  6,63	  2,68	  -
; 10	  2,59	  5,26	  3,38	  6
; 11	  2,30	  4,17	  4,27	  -
; 12	  2,05	  3,31	  5,38	  4
; 13	  1,83	  2,62	  6,78	  -
; 14	  1,63	  2,08	  8,55	  2,5
; 15	  1,45	  1,65	  10,8	  -
; 16	  1,29	  1,31	  13,6	  1,5
; 17	  1,15	  1,04	  17,1	  -
; 18	  1,0237	0,823	  21,6	  1
; 19	  0,9116	0,653	  27,3	  0,75
; 20	  0,8118	0,518	  34,4	  0,75
; 21	  0,7229	0,410	  43,4	  0,5
; 22	  0,6438	0,326	  54,7	  0,34
; 23	  0,5733	0,258	  67	    -
; 24	  0,5106	0,205	  87	    0,25
; 25	  0,4547	0,162	  110	    -
; 26	  0,4049	0,129	  138	    0,14
; 27	  0,3606	0,102	  174	    -
; 28	  0,3211	0,081	  220	    0,09

Structure TWire
  ID.l            ; Wire ID
  WireCol.l       ; real wire color
  DrawingCol.l    ; color for drawing on screen
  mmsq.f          ; Millimeter square; cross section (Leiter Querschnitt mm)
  AWG.l           ; Average Wire Gage AWG 1..28
  Potential.l     ; Project Potential No
  ; StartPoint ??? ; Maybe we use Symbol Pins instead of absolute Positions
  ; EndPoint ???
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TCable
  ID.l
  BMK.TText
  Name.TText
  List LWires.TWire()
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

;- ----------------------------------------------------------------------
;-  STRUCTURES FOR TERMINALSm CLAMPS, PLUGS  
; ----------------------------------------------------------------------

Structure TClamp
  ID.l
  Type.l
  Text.TText
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TTerminal
  ID.l
  BMK.TText
  Name.TText
  List LClamps.TClamp()  
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TPlug
  ID.l
  BMK.TText
  Name.TText
  List LClamps.TClamp()  
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

;- ----------------------------------------------------------------------
;-  STRUCTURES FOR PLCs 
; ----------------------------------------------------------------------

Structure TPlcIO
  ID.l
  Pin.TPin
  txtIO.s
  txtComment.s
  txtSymbol.s
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TPLC
  ID.l
  Name.TText
  List LPlcIOs.TPlcIO()
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

;- ----------------------------------------------------------------------
;-  STRUCTURES FOR MATERIAL
; ----------------------------------------------------------------------

Structure TObj2D
  Shape.TRect  
  SnapPoint.TPoint
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TPart
  ID.l
  Name.s
  Obj2D.TObj2D
  State.TState            ; Status: LayerNo, Hide ...
  ClsID.i                 ; Symbol Class
  SubCls.i                ; Symbol SubClass
EndStructure
  
;- ----------------------------------------------------------------------
;-  STRUCTURES FOR PAGES 
; ----------------------------------------------------------------------

Enumeration eUnit
  #UNIT_mm  
  #UNIT_cm 
  #UNIT_dm
  #UNIT_m  
  #UNIT_km
  #UNIT_in
  #UNIT_ft
EndEnumeration

; Standard Paper Formats in Ladscape orientation (Querformat)
;    |    mm        | Pixel 300DPI  | Area
; ---------------------------------------
; A0 |	1189 x 841  |	14043 x 9933 	| 1 m²
; A1 |	 841 x 594	| 9933 x 7016	  | 0,5 m²
; A2 |	 594 x 420	|	7016 x 4961	  | 0,25 m²
; A3 |	 420 x 297	|	4961 x 3508 	| 0,12 m²
; A4 |	 297 x 210	|	3508 x 2480	  | 624 cm²

Enumeration ePageFormat
  #PageFormat_A0         ; 1189 x 841 mm
  #PageFormat_A1         ;  841 x 594 mm
  #PageFormat_A2         ;  594 x 420 mm
  #PageFormat_A3         ;  420 x 297 mm
  #PageFormat_A4         ;  297 x 210 mm
  #PageFormat_Letter     ; US Letter 11 x 8.5 Inch
  #PageFormat_Legal      ; US Legal  14 x 8.5 Inch
  #PageFormat_Tabloid    ; US Tabloid 17 x 11 Inch
EndEnumeration

; Array for PageSizes
Global Dim PageSize.TSize(7)

; DIN A0
PageSize(#PageFormat_A0)\dX =1189 
PageSize(#PageFormat_A0)\dy =841
; DIN A1
PageSize(#PageFormat_A1)\dX =841 
PageSize(#PageFormat_A1)\dY =594 
; DIN A2
PageSize(#PageFormat_A2)\dX =594 
PageSize(#PageFormat_A2)\dY =420 
; DIN A3
PageSize(#PageFormat_A2)\dX =420 
PageSize(#PageFormat_A2)\dY =297 
; DIN A3
PageSize(#PageFormat_A4)\dX =297 
PageSize(#PageFormat_A4)\dY =210 
; US Letter
PageSize(#PageFormat_Letter)\dX = 11 * 25.4    ; 279.4mm
PageSize(#PageFormat_Letter)\dY = 8.5* 25.4    ; 215.9mm
; US Legal
PageSize(#PageFormat_Legal)\dX = 14 * 25.4     ; 355.6mm
PageSize(#PageFormat_Legal)\dY = 8.5* 25.4     ; 215.9mm
; US Tabloid
PageSize(#PageFormat_Tabloid)\dX = 17 * 25.4   ; 431.86mm
PageSize(#PageFormat_Tabloid)\dY = 11 * 25.4   ; 279.4mm

Structure TEdit
  CreateAuthor.s
  CreateTimeStamp.i
  EditAuthor.s
  EditTimeStamp.i
EndStructure

; Seitenvorlage, SchriftFeld
Structure TPageFrame
  ID.l                          ; Page Template Number
  Pahts.l                       ; Number of paths
  FirstPath.l                   ; Number of first Path 
  Unit.l                        ; eUnit mm,cm,dm,m,km,in,ft
  MD5.TMD5                      ; MD5 Hash - used to dedect changed Symbols
  List LGraphics.TGraphObj()    ; List of Pointers to the grafical Elements (EcadLine, EcadPolyLine ...)
  List LText.TText()            ; List of text Elements 
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

Structure TPage
  UUID.l                        ; unique page ID "key"
  No.l                          ; Page No
  *Frame.TPageFrame             ; Pointer To PageFrame Object
  TEdit.TEdit                   ; Edit and Creation Data
  xLock.w                       ; Lock Page = not editable
  Unit.l                        ; #UNIT_mm, #UNIT_cm ...
  ScaleScreen.d                 ; Scaling on Screen (like 1:20)
  ScalePrinter.d                ; Scaling on Printer (like 1:25)
  List LSymbols.TSymbol()       ; List of Symbols on Page
  List LText.TText()            ; List of Text-Objects on Page
  List LWires.TWire()           ; List of Wires on Page (connections)
  List LGraph.TGraphObj()       ; List of Graphical Objects
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

;- ----------------------------------------------------------------------
;-  STRUCTURES FOR ECAD MACROS
;  ----------------------------------------------------------------------

; Makros sind vordefinierte Zeichnungsteile z.B. Stern-Dreick-Schaltung ...

; Generally a Macro is very similar to a Page
; It must have same Lists as a Page

Structure TMacro
  UUID.l                     ; unique Macro ID "key"
  Name.s                    ; Macro Name
  TEdit.TEdit               ; Edit and Creation Data
  List LSymbols.TSymbol()   ; List of Symbols 
  List LText.TText()        ; List of Text-Objects o
  List LWires.TWire()       ; List of Wires on Page (connections)
  List LGraph.TGraphObj()   ; List of Graphical Objects
  State.TState            ; Status: LayerNo, Hide ...
EndStructure

;- ----------------------------------------------------------------------
;-  STRUCTURES FOR PROJECTS 
; ----------------------------------------------------------------------

Structure TProject
  Name.s                        ; Poject Name
  TEdit.TEdit                   ; Edit and Cration Data
  MD5.TMD5
  List LPages.TPage()           ; List of Pages
  List LCables.TCable()         ; List of Cables
  List LTerminals.TTerminal()   ; List of Terminals
  List LPlugs.TPlug()           ; List of Plugs
  List LPLC.TPLC()              ; List of PLCs
EndStructure


;- ----------------------------------------------------------------------
;-  MACROS FOR mm CONVERSION
;  ----------------------------------------------------------------------

Macro mm2cm(mm)
  mm/10  
EndMacro

Macro mm2dm(mm)
  mm/100
EndMacro

Macro mm2m(mm)
  mm/1000
EndMacro

Macro mm2km(mm)
  mm/1000000
EndMacro

; 1in = 25.4mm
Macro mm2in(mm)
  mm/25.4
EndMacro

; 1ft = 12in = 12*25.4mm = 304.8mm
Macro mm2ft(mm)
  mm/304.8
EndMacro

Macro cm2mm(cm)
  cm*10  
EndMacro

Macro dm2mm(dm)
  dm*100  
EndMacro

Macro m2mm(m)
  m*1000  
EndMacro

Macro km2mm(km)
  km*1000000  
EndMacro

Macro in2mm(in)
  in*25.4
EndMacro

Macro ft2mm(ft)
  ft*304.8  
EndMacro

EndDeclareModule

Module ECAD
  
  EnableExplicit

  Global NewList SymClassList.TSymbolClass()
    
  ;- ----------------------------------------------------------------------
  ;- Modul internal Functions
  ;- ----------------------------------------------------------------------

  ;- ----------------------------------------------------------------------
  ;- Modul Public Functions
  ;- ----------------------------------------------------------------------
  
  ; LoadProject, SaveProject, NewProject ....
EndModule

; ----------------------------------------------------------------------
; Template Switch for Symbol Classes
;  ----------------------------------------------------------------------

; Select ClassID                    ; Symbol Class
; 
;   Case #ECAD_CLASS_Acessory       ; Montagezubehör
;     
;   Case #ECAD_CLASS_SwitchBoard    ; Schaltschrank
;     
;   Case #ECAD_CLASS_SUBPLATE       ; Montageplatte
;     
;   Case #ECAD_CLASS_CableChannel   ; Kabelkanal
;     
;   Case #ECAD_CLASS_MountingRail   ; Montageschiene
;     
;   Case #ECAD_CLASS_TerminalEnd    ; Klemmenabschluss
;     
;   Case #ECAD_CLASS_Busbar         ; Stromschiene
;     
;   Case #ECAD_CLASS_SingleDevice   ; Einzelgerät
;     
;   Case #ECAD_CLASS_HydraulicDevice ; Hydraulikgerät
;     
;   Case #ECAD_CLASS_MAC            ; (MSR) Messen steuern regeln, (MAC) measurement and control
;     
;   Case #ECAD_CLASS_Terminal       ; Klemme
;     
;   Case #ECAD_CLASS_Plug           ; Stecker
;     
;   Case #ECAD_CLASS_PLC            ; SPS
;     
;   Case #ECAD_CLASS_BlackBox       ; Black-Box
;     
;   Case #ECAD_CLASS_ContacorMain   ; Schütz Hauptelement
;     
;   Case #ECAD_CLASS_SwitchMain     ; Schalter Hauptelement
;     
;   Case #ECAD_CLASS_FuseMain       ; Sicherungs Hauptelement
;     
;   Case #ECAD_CLASS_DeviceMain     ; Großgeräte Hauptelement
;     
; EndSelect






; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 334
; FirstLine = 303
; Folding = ---
; EnableXP
; CPU = 2