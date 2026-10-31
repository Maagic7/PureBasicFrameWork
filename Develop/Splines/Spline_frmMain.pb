; PureBasic code generated from VB6 Form "frmSplines"
; Date: 2026-03-01

EnableExplicit

XIncludeFile "..\..\Modules\PbFw_Module_Spline.pb"
XIncludeFile "..\..\Modules\PbFw_Module_VECTORd.pb" ; VECd::     double precision Vector Module

; -----------------------------------------------------------------------------
; Structures
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; Enumerations
; -----------------------------------------------------------------------------

Enumeration Window
  #frmSplines
EndEnumeration

Enumeration Gadgets
  ; TabStrip
  #tabTipoI

  ; Main Drawing Area (PictureBox)
  #picQuadro

  ; Controls overlaying the PictureBox area
  #chkSegnaPc
  #lblX_Label ; "x:"
  #lblX ; Value
  #lblY_Label ; "y:"
  #lblY ; Value

  ; Grid (MSFlexGrid)
  #grdPunti
  #zLabel07 ; "Punti da interpolare:"

  ; Hidden Edit Box for Grid
  #txtEditPunti

  ; Frame 1: Parametri della curva
  #zFrame1
  #zLabel02 ; "N. di punti da interpolare:"
  #txtNPI
  #cmdNPI_OK
  #zLabel01 ; "N. di punti sulla curva:"
  #txtNPC
  #cmdNPC_OK
  #lblKZ ; "Parametro NK o VZ"
  #txtKZ
  #cmdKZ_OK

  ; Frame 2: Scala del grafico
  #zFrame2
  #zLabel03 ; "Xmin"
  #txtXmin
  #zLabel04 ; "Xmax"
  #txtXmax
  #zLabel05 ; "Ymin"
  #txtYmin
  #zLabel06 ; "Ymax"
  #txtYmax
  #zLabel08 ; Symbol R (Optional)
  #zLabel09 ; Symbol R (Optional)
  #cmdSG_OK

  ; Hidden PictureBox for printing
  #picStampa
EndEnumeration

Enumeration Menu
  #mnuCurve
  #mnuLeggiPunti
  #mnuSalvaCurva
  #mnuStampa
  #mnuEsci
  #mnuQm
  #mnuIstruzioni
  #mnuInformazioni
EndEnumeration

; -----------------------------------------------------------------------------
; Constants & Globals
; -----------------------------------------------------------------------------

; Conversion factor: 15 Twips ~= 1 Pixel
#TwipsPerPixel = 15
; Structure TPoint2D
;   x.d
;   y.d
; EndStructure
UseModule VECd
; -----------------------------------------------------------------------------
; Global Variables & Constants
; -----------------------------------------------------------------------------

Global NPI.i ; No. of points to interpolate.
Global Dim Pi.TPoint2D(0) ; Vector of points to interpolate.
Global NPC.i ; No. of points on the curve.
Global Dim Pc.TPoint2D(0) ; Vector of curve points.
Global NK.i ; No. of nodes for B-Spline.
Global VZ.i ; Tension of T-Spline curve.

Global TipoI.s ; Active interpolation type.

Global ShOx.f, ShOy.f ; Center offset of point indicators.
Global PSel.i ; Index of selected point.

Global Xmin.f, Xmax.f ; Min and max coordinates
Global Ymin.f, Ymax.f ; of the Frame.

Global DirNome.s ; Folder of Spline Files.
Global PExt.s = "dat" ; Preferred extension for Spline files.

#PxM = 2.0 ; Definition for printing in [Pixel/mm].

Global BZ.s = ""
Global CS.s = ""
Global BS.s = "No. of &nodes" + #CRLF$ + "2 <= NK <= NPI"
Global TS.s = "Te&nsion" + #CRLF$ + "1 <= VZ <= 100"

Global RS1.i ; Positioning for "editing"
Global CS1.i ; of point coordinates
Global RS1_O.i ; in the table.
Global CS1_O.i ;

Global grdPunti_Left.i
Global grdPunti_Top.i

Global NoPaint.i ; Avoid multiple Paint events.

#PCHL = $C0FFFF ; Highlight color for cursor position labels.

; -----------------------------------------------------------------------------
; Helper Procedures
; -----------------------------------------------------------------------------

#LOCALE_SDECIMAL = $E
#LOCALE_STHOUSAND = $F
#LOCALE_SDATE = $1D
#LOCALE_STIME = $1E

Procedure GetLocale(*DS.String, *MS.String, *GS.String, *TS.String)
  ; Find system separators
  Protected LCID = GetThreadLocale_()
  Protected Buffer.s = Space(10)

  If *DS : *DS\s = " " : EndIf
  If *MS : *MS\s = " " : EndIf
  If *GS : *GS\s = " " : EndIf
  If *TS : *TS\s = " " : EndIf

  If *DS And GetLocaleInfo_(LCID, #LOCALE_SDECIMAL, @Buffer, 10)
    *DS\s = Left(Buffer, 1)
  EndIf
  If *MS And GetLocaleInfo_(LCID, #LOCALE_STHOUSAND, @Buffer, 10)
    *MS\s = Left(Buffer, 1)
  EndIf
  If *GS And GetLocaleInfo_(LCID, #LOCALE_SDATE, @Buffer, 10)
    *GS\s = Left(Buffer, 1)
  EndIf
  If *TS And GetLocaleInfo_(LCID, #LOCALE_STIME, @Buffer, 10)
    *TS\s = Left(Buffer, 1)
  EndIf
EndProcedure

Procedure.i KAscNumInteri(KeyAscii.i, Gadget.i, Neg.i = #False)
  ; Returns only valid characters for a field containing an integer
  Protected KeyMinus.i
  Protected Text.s = GetGadgetText(Gadget)
  Protected StartPos.i, EndPos.i
  Protected myKeyMinus = 45

  SendMessage_(GadgetID(Gadget), #EM_GETSEL, @StartPos, @EndPos)

  ; Filtro per il segno "-":
  If (Left(Text, 1) <> "-" Or StartPos <> EndPos) And Neg And StartPos = 0
    KeyMinus = myKeyMinus
  EndIf

  Select KeyAscii
    Case 48 To 57, KeyMinus, 8 ; 0-9, -, Backspace
      ProcedureReturn KeyAscii
    Default
      ProcedureReturn 0
  EndSelect
EndProcedure

Procedure.i KAscNumReali(KeyAscii.i, Gadget.i, Neg.i = #False)
  ; Returns only valid characters for a field containing a real number
  Protected KeyDecimal.i, KeyMinus.i, KeyE.i
  Protected Text.s = GetGadgetText(Gadget)
  Protected SD.s, SM.s
  Protected myKeyDecimal.i
  Protected StartPos.i, EndPos.i
  Protected SelTextLen.i
  Protected DS_Str.String, MS_Str.String, GS_Str.String, TS_Str.String
  Protected myKeyMinus = 45

  GetLocale(@DS_Str, @MS_Str, @GS_Str, @TS_Str)
  SD = DS_Str\s
  SM = MS_Str\s
  myKeyDecimal = Asc(SD)

  SendMessage_(GadgetID(Gadget), #EM_GETSEL, @StartPos, @EndPos)
  SelTextLen = EndPos - StartPos

  ; Filtro per il separatore decimale:
  If (FindString(Text, SD) = 0 And Not (StartPos = 0 And Left(Text, 1) = "-")) Or SelTextLen = Len(Text)
    KeyDecimal = myKeyDecimal
  EndIf

  ; Filtro per il segno "-":
  If (Left(Text, 1) <> "-" Or SelTextLen = Len(Text)) And Neg And StartPos = 0
    KeyMinus = myKeyMinus
  EndIf

  ; Filtro per la notazione scientifica:
  If StartPos > 0
    KeyAscii = Asc(UCase(Chr(KeyAscii)))
    If (FindString(Text, "E") = 0 And Not (StartPos = 0 Or SelTextLen = Len(Text))) And Mid(Text, StartPos, 1) <> "-"
      KeyE = 'E'
    EndIf

    If Mid(Text, StartPos, 1) = "E"
      KeyMinus = myKeyMinus
    EndIf

    If FindString(Text, "E") > 0 And (StartPos - FindString(Text, "E") >= 0)
      KeyDecimal = 0
    EndIf
  EndIf

  Select KeyAscii
    Case 48 To 57, KeyDecimal, KeyMinus, 8, KeyE
      ProcedureReturn KeyAscii
    Default
      ProcedureReturn 0
  EndSelect
EndProcedure

Procedure.d Ceil(X.d)
  If X = Int(X)
    ProcedureReturn X
  Else
    ProcedureReturn Int(X) + 1.0
  EndIf
EndProcedure

; -----------------------------------------------------------------------------
; Forward Declarations
; -----------------------------------------------------------------------------

Declare DisegnaCurva(Gadget.i)
Declare AggiornaPunti()
Declare PositionPoint()
Declare Quadro(Gadget.i, X0.f, Xn.f, Y0.f, Yn.f, FormatVX.s = "#0.0##", FormatVY.s = "#0.0##", Npx.i = 1, *PxN_X.Float = 0, *PxN_Y.Float = 0, Titolo.s = "", UnitaX.s = "", UnitaY.s = "", AutoRed.i = #False)

; -----------------------------------------------------------------------------
; Procedure Implementations
; -----------------------------------------------------------------------------

Procedure.f X_Scr(x.d)
  Protected CW = GadgetWidth(#picQuadro)
  If Xmax <> Xmin
    ProcedureReturn (x - Xmin) * CW / (Xmax - Xmin)
  EndIf
  ProcedureReturn 0
EndProcedure

Procedure.f Y_Scr(y.d)
  Protected CH = GadgetHeight(#picQuadro)
  If Ymax <> Ymin
    ProcedureReturn CH - (y - Ymin) * CH / (Ymax - Ymin)
  EndIf
  ProcedureReturn 0
EndProcedure

Procedure.d X_Log(x_scr.i)
  Protected CW = GadgetWidth(#picQuadro)
  If CW > 0
    ProcedureReturn Xmin + (x_scr * (Xmax - Xmin) / CW)
  EndIf
  ProcedureReturn Xmin
EndProcedure

Procedure.d Y_Log(y_scr.i)
  Protected CH = GadgetHeight(#picQuadro)
  If CH > 0
    ProcedureReturn Ymin + ((CH - y_scr) * (Ymax - Ymin) / CH)
  EndIf
  ProcedureReturn Ymin
EndProcedure

Procedure Quadro(Gadget.i, X0.f, Xn.f, Y0.f, Yn.f, FormatVX.s = "#0.0##", FormatVY.s = "#0.0##", Npx.i = 1, *PxN_X.Float = 0, *PxN_Y.Float = 0, Titolo.s = "", UnitaX.s = "", UnitaY.s = "", AutoRed.i = #False)
  If StartDrawing(CanvasOutput(Gadget))
    Box(0, 0, OutputWidth(), OutputHeight(), $FFFFFF)
    Protected y0_scr = Y_Scr(0)
    Protected x0_scr = X_Scr(0)
    LineXY(0, y0_scr, OutputWidth(), y0_scr, 0)
    LineXY(x0_scr, 0, x0_scr, OutputHeight(), 0)
    StopDrawing()
  EndIf
EndProcedure

Procedure AggiornaPunti()
  ClearGadgetItems(#grdPunti)
  Protected i
  For i = 0 To NPI - 1
    AddGadgetItem(#grdPunti, -1, Str(i + 1) + #LF$ + StrD(Pi(i)\x, 3) + #LF$ + StrD(Pi(i)\y, 3))
  Next
EndProcedure

Procedure PositionPoint()
  If StartDrawing(CanvasOutput(#picQuadro))
    Protected i, x, y
    For i = 0 To NPI - 1
      x = X_Scr(Pi(i)\x)
      y = Y_Scr(Pi(i)\y)
      Circle(x, y, 3, $0000FF)
      DrawText(x + 5, y, Str(i + 1), $000000, $FFFFFF)
    Next
    StopDrawing()
  EndIf
EndProcedure

Procedure.i TrovaPunto(x_scr.i, y_scr.i)
  ; Returns the index of the point visually closest to mouse coordinates
  Protected i, bestI = -1
  Protected dist.d, minDist.d = 1.0e38
  Protected px, py, dx, dy

  For i = 0 To NPI - 1
    px = X_Scr(Pi(i)\x)
    py = Y_Scr(Pi(i)\y)
    dx = x_scr - px
    dy = y_scr - py
    dist = dx*dx + dy*dy

    If dist < minDist
      minDist = dist
      bestI = i
    EndIf
  Next

  ; Optional: Threshold for selection (e.g., within 10 pixels)
  If minDist > 100 ; 10*10
    ProcedureReturn -1
  EndIf

  ProcedureReturn bestI
EndProcedure

Procedure AggiornaPosizioniCursore(sVal1.s, sVal2.s)
  SetGadgetText(#lblX, sVal1)
  SetGadgetText(#lblY, sVal2)
  ; Note: Changing background color of TextGadget dynamically in PB requires API or custom draw, skipping for standard gadgets.
EndProcedure

Procedure DisegnaCurva(Gadget.i)
  Quadro(Gadget, Xmin, Xmax, Ymin, Ymax)
  PositionPoint()

  If NPI < 2 : ProcedureReturn : EndIf

  Dim Pc(NPC)

  ; Note: We assume TPoint2D structure matches the module's TPoint2D (2 doubles)
  Select TipoI
    Case "B-Spline"
      Spline::B_Spline(Pc(), Pi(), NK)
    Case "C-Spline"
      Spline::C_Spline(Pc(), Pi())
    Case "T-Spline"
      Spline::T_Spline(Pc(), Pi(), VZ)
    Case "Bezier"
      Spline::Bezier(Pc(), Pi())
  EndSelect

  If StartDrawing(CanvasOutput(Gadget))
    Protected i, x1, y1, x2, y2
    x1 = X_Scr(Pc(0)\x) : y1 = Y_Scr(Pc(0)\y)
    For i = 1 To ArraySize(Pc())
      x2 = X_Scr(Pc(i)\x) : y2 = Y_Scr(Pc(i)\y)
      LineXY(x1, y1, x2, y2, $FF0000)
      x1 = x2 : y1 = y2
    Next
    StopDrawing()
  EndIf
EndProcedure

; -----------------------------------------------------------------------------
; Event Procedures
; -----------------------------------------------------------------------------

Procedure.i VerificaSG(*X1.Float, *Y1.Float, *X2.Float, *Y2.Float)
  Protected M.s = ""
  Protected vXmin.f = ValF(GetGadgetText(#txtXmin))
  Protected vXmax.f = ValF(GetGadgetText(#txtXmax))
  Protected vYmin.f = ValF(GetGadgetText(#txtYmin))
  Protected vYmax.f = ValF(GetGadgetText(#txtYmax))

  If vXmin >= vXmax
    M + "Xmin or Xmax incorrect" + #CRLF$
  EndIf
  *X1\f = vXmin
  *X2\f = vXmax

  If vYmin >= vYmax
    M + "Ymin or Ymax incorrect" + #CRLF$
  EndIf
  *Y1\f = vYmin
  *Y2\f = vYmax

  If M <> ""
    MessageRequester("Error in graph parameters", M, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure chkSegnaPc_Click()
  DisegnaCurva(#picQuadro)

  If GetGadgetState(#chkSegnaPc) = #PB_Checkbox_Checked
    GadgetToolTip(#chkSegnaPc, "Hide Spline points")
  Else
    GadgetToolTip(#chkSegnaPc, "Mark Spline points")
  EndIf
EndProcedure

Procedure cmdKZ_OK_Click()
  Protected ValKZ.i = Val(GetGadgetText(#txtKZ))

  Select TipoI
    Case "B-Spline"
      If ValKZ >= 2 And ValKZ <= NPI
        NK = ValKZ
        DisegnaCurva(#picQuadro)
      Else
        SetGadgetText(#txtKZ, Str(NK))
      EndIf

    Case "T-Spline"
      If ValKZ >= 1 And ValKZ <= 100
        VZ = ValKZ
        DisegnaCurva(#picQuadro)
      Else
        SetGadgetText(#txtKZ, Str(VZ))
      EndIf
  EndSelect
EndProcedure

Procedure cmdNPI_OK_Click()
  Protected ValNPI.i = Val(GetGadgetText(#txtNPI))

  If ValNPI >= 3
    NPI = ValNPI
    If NK > NPI
      NK = NPI
      If TipoI = "B-Spline" : SetGadgetText(#txtKZ, Str(NK)) : EndIf
    EndIf

    ReDim Pi(NPI - 1)
    AggiornaPunti()
    PositionPoint()
  Else
    SetGadgetText(#txtNPI, Str(NPI))
  EndIf
EndProcedure

Procedure cmdSG_OK_Click()
  Protected X1.f, X2.f, Y1.f, Y2.f

  If VerificaSG(@X1, @Y1, @X2, @Y2)
    Xmin = X1
    Xmax = X2
    Ymin = Y1
    Ymax = Y2

    Quadro(#picQuadro, Xmin, Xmax, Ymin, Ymax, "", "", 2, @ShOx, @ShOy, "", "x", "y")
    PositionPoint()
  EndIf
EndProcedure

Procedure cmdNPC_OK_Click()
  Protected ValNPC.i = Val(GetGadgetText(#txtNPC))

  If ValNPC >= 2
    NPC = ValNPC
    DisegnaCurva(#picQuadro)
  Else
    SetGadgetText(#txtNPC, Str(NPC))
  EndIf
EndProcedure

Procedure tabTipoI_Click()
  TipoI = GetGadgetItemText(#tabTipoI, GetGadgetState(#tabTipoI))

  ; Clean up label (remove & from menu text if present)
  TipoI = ReplaceString(TipoI, "&", "")

  Select TipoI
    Case "Bezier"
      HideGadget(#txtKZ, 1)
      HideGadget(#cmdKZ_OK, 1)
      SetGadgetText(#lblKZ, BZ)

    Case "B-Spline"
      SetGadgetText(#txtKZ, Str(NK))
      HideGadget(#txtKZ, 0)
      HideGadget(#cmdKZ_OK, 0)
      SetGadgetText(#lblKZ, BS)

    Case "C-Spline"
      HideGadget(#txtKZ, 1)
      HideGadget(#cmdKZ_OK, 1)
      SetGadgetText(#lblKZ, CS)

    Case "T-Spline"
      SetGadgetText(#txtKZ, Str(VZ))
      HideGadget(#txtKZ, 0)
      HideGadget(#cmdKZ_OK, 0)
      SetGadgetText(#lblKZ, TS)
  EndSelect

  DisegnaCurva(#picQuadro)
EndProcedure

Procedure Init_Form_Load()
  NPI = 6
  SetGadgetText(#txtNPI, Str(NPI))
  NPC = 100
  SetGadgetText(#txtNPC, Str(NPC))

  NK = 3
  VZ = 30

  ReDim Pi(NPI - 1)
  Pi(0)\x = -10 : Pi(0)\y = -3.5
  Pi(1)\x = 3 : Pi(1)\y = 3
  Pi(2)\x = 3 : Pi(2)\y = -0.01
  Pi(3)\x = 5 : Pi(3)\y = 3
  Pi(4)\x = 7 : Pi(4)\y = -4.2
  Pi(5)\x = 10 : Pi(5)\y = 4

  Xmin = -10 : SetGadgetText(#txtXmin, StrF(Xmin))
  Ymin = -5 : SetGadgetText(#txtYmin, StrF(Ymin))
  Xmax = 10 : SetGadgetText(#txtXmax, StrF(Xmax))
  Ymax = 5 : SetGadgetText(#txtYmax, StrF(Ymax))

  Quadro(#picQuadro, Xmin, Xmax, Ymin, Ymax, "", "", 2, @ShOx, @ShOy, "", "x", "y")

  SetGadgetState(#tabTipoI, 0) ; Select Bezier
  tabTipoI_Click()

  AggiornaPunti()
  PositionPoint()
EndProcedure

Procedure picQuadro_Events()
  Protected mx, my, Type
  mx = GetGadgetAttribute(#picQuadro, #PB_Canvas_MouseX)
  my = GetGadgetAttribute(#picQuadro, #PB_Canvas_MouseY)
  Type = EventType()

  Select Type
    Case #PB_EventType_LeftButtonDown
      PSel = TrovaPunto(mx, my)
      If PSel <> -1
        ; Start dragging logic if needed, usually handled in MouseMove with button check
        DisegnaCurva(#picQuadro) ; Refresh to show selection if we add selection visual
      EndIf

    Case #PB_EventType_MouseMove
      If GetGadgetAttribute(#picQuadro, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton
        If PSel <> -1
          NoPaint = #True
          Pi(PSel)\x = X_Log(mx)
          Pi(PSel)\y = Y_Log(my)

          ; Update Grid
          SetGadgetItemText(#grdPunti, PSel, StrD(Pi(PSel)\x, 3), 1)
          SetGadgetItemText(#grdPunti, PSel, StrD(Pi(PSel)\y, 3), 2)

          NoPaint = #False
          DisegnaCurva(#picQuadro)
        EndIf
      Else
        GadgetToolTip(#picQuadro, "Move point " + Str(TrovaPunto(mx, my) + 1))
      EndIf

      AggiornaPosizioniCursore(StrD(X_Log(mx), 3), StrD(Y_Log(my), 3))

  EndSelect
EndProcedure

; -----------------------------------------------------------------------------
; Procedure: Open_frmSplines
; -----------------------------------------------------------------------------
Procedure Open_frmSplines()
  Protected WindowFlags

  ; Calculate Window Size from Twips
  ; Width: 9510 / 15 = 634
  ; Height: 6540 / 15 = 436

  WindowFlags = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered

  If OpenWindow(#frmSplines, 0, 0, 634, 436, " Curve di Interpolazione con Splines", WindowFlags)

    ; --- Menu ---
    If CreateMenu(0, WindowID(#frmSplines))
      MenuTitle("Cur&ves")
      MenuItem(#mnuLeggiPunti, "&Read interpolation points file")
      MenuItem(#mnuSalvaCurva, "&Save curve to File")
      MenuBar()
      MenuItem(#mnuStampa, "&Print")
      MenuBar()
      MenuItem(#mnuEsci, "&Exit")

      MenuTitle("&?")
      MenuItem(#mnuIstruzioni, "&Instructions")
      MenuBar()
      MenuItem(#mnuInformazioni, "In&formation")
    EndIf

    ; --- TabStrip (tabTipoI) ---
    ; VB6: Left=135, Top=120, Width=6735, Height=6255
    ; PB: ~9, 8, 449, 417
    PanelGadget(#tabTipoI, 9, 8, 449, 417)
    AddGadgetItem(#tabTipoI, -1, "Be&zier")
    AddGadgetItem(#tabTipoI, -1, "&B-Spline")
    AddGadgetItem(#tabTipoI, -1, "&C-Spline")
    AddGadgetItem(#tabTipoI, -1, "&T-Spline")
    CloseGadgetList()

    ; --- PictureBox (picQuadro) ---
    ; VB6: Left=255, Top=540, Width=6480, Height=5700
    ; PB: ~17, 36, 432, 380
    ; Note: In VB6 this sits visually on top of the TabStrip area.
    ; We place it on the window at the calculated coordinates.
    CanvasGadget(#picQuadro, 17, 36, 432, 380, #PB_Canvas_Border)

    ; --- Controls associated with picQuadro ---
    ; These are placed relative to the Window, calculated from their VB6 positions relative to picQuadro.
    ; Canvas Origin: (17, 36)

    ; chkSegnaPc "p:" (VB6: Left=5880, Top=60 inside picQuadro)
    ; PB X = 17 + (5880/15) = 409
    ; PB Y = 36 + (60/15) = 40
    CheckBoxGadget(#chkSegnaPc, 409, 40, 35, 17, "&p:")
    GadgetToolTip(#chkSegnaPc, "Mark Spline points")

    ; Labels for X/Y coordinates
    ; zLabel10 "x:" (VB6: Left=3540 -> 236 px) -> X = 17 + 236 = 253
    TextGadget(#lblX_Label, 253, 40, 15, 17, "x:", #PB_Text_Right)
    ; lblX (VB6: Left=3780 -> 252 px) -> X = 17 + 252 = 269
    TextGadget(#lblX, 269, 40, 49, 17, "", #PB_Text_Border)

    ; zLabel11 "y:" (VB6: Left=4620 -> 308 px) -> X = 17 + 308 = 325
    TextGadget(#lblY_Label, 325, 40, 15, 17, "y:", #PB_Text_Right)
    ; lblY (VB6: Left=4860 -> 324 px) -> X = 17 + 324 = 341
    TextGadget(#lblY, 341, 40, 49, 17, "", #PB_Text_Border)


    ; --- Right Side Controls ---

    ; zLabel07 "Punti da interpolare:"
    ; VB6: Left=7110, Top=165 -> PB: 474, 11
    TextGadget(#zLabel07, 474, 11, 120, 17, "Punti da interpolare:")

    ; grdPunti (MSFlexGrid)
    ; VB6: Left=7080, Top=405, Width=2295, Height=2265
    ; PB: 472, 27, 153, 151
    ListIconGadget(#grdPunti, 472, 27, 153, 151, "I", 30, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect)
    AddGadgetColumn(#grdPunti, 1, "Pi(I).x", 50)
    AddGadgetColumn(#grdPunti, 2, "Pi(I).y", 50)

    ; txtEditPunti (Hidden TextBox for editing)
    ; VB6: Left=7920, Top=2040
    StringGadget(#txtEditPunti, 528, 136, 73, 25, "")
    HideGadget(#txtEditPunti, 1)

    ; --- Frame 1: Parametri della curva ---
    ; VB6: Left=7080, Top=2760, Width=2295, Height=1575
    ; PB: 472, 184, 153, 105
    FrameGadget(#zFrame1, 472, 184, 153, 105, "Parametri della curva:")

    ; Controls inside Frame 1 (Positions are relative to Window, calculated by adding Frame Offset)
    ; Frame Origin: (472, 184)

    ; zLabel02 "N. di punti da interpolare:" (VB6: Left=120, Top=240) -> (8, 16)
    TextGadget(#zLabel02, 472 + 8, 184 + 16, 70, 30, "No. of points to interpolate:")

    ; txtNPI (VB6: Left=120, Top=720) -> (8, 48)
    StringGadget(#txtNPI, 472 + 8, 184 + 48, 41, 19, "6")

    ; cmdNPI_OK (VB6: Left=720, Top=720) -> (48, 48)
    ButtonGadget(#cmdNPI_OK, 472 + 48, 184 + 48, 20, 19, "OK")

    ; zLabel01 "N. di punti sulla curva:" (VB6: Left=1320, Top=240) -> (88, 16)
    TextGadget(#zLabel01, 472 + 88, 184 + 16, 60, 30, "No. of points on curve:")

    ; txtNPC (VB6: Left=1320, Top=720) -> (88, 48)
    StringGadget(#txtNPC, 472 + 88, 184 + 48, 41, 19, "100")

    ; cmdNPC_OK (VB6: Left=1920, Top=720) -> (128, 48)
    ButtonGadget(#cmdNPC_OK, 472 + 128, 184 + 48, 20, 19, "OK")

    ; lblKZ "Parametro NK o VZ" (VB6: Left=1080, Top=1110) -> (72, 74)
    TextGadget(#lblKZ, 472 + 72, 184 + 74, 80, 25, "Parameter NK or VZ")

    ; txtKZ (VB6: Left=120, Top=1170) -> (8, 78)
    StringGadget(#txtKZ, 472 + 8, 184 + 78, 41, 19, "")
    HideGadget(#txtKZ, 1)

    ; cmdKZ_OK (VB6: Left=720, Top=1170) -> (48, 78)
    ButtonGadget(#cmdKZ_OK, 472 + 48, 184 + 78, 20, 19, "OK")
    HideGadget(#cmdKZ_OK, 1)


    ; --- Frame 2: Scala del grafico ---
    ; VB6: Left=7080, Top=4440, Width=2295, Height=1935
    ; PB: 472, 296, 153, 129
    FrameGadget(#zFrame2, 472, 296, 153, 129, "Scala del grafico:")

    ; Frame Origin: (472, 296)

    ; zLabel03 "Xmin" (VB6: Left=120, Top=240) -> (8, 16)
    TextGadget(#zLabel03, 472 + 8, 296 + 16, 30, 17, "Xmin")
    ; txtXmin (VB6: Left=120, Top=480) -> (8, 32)
    StringGadget(#txtXmin, 472 + 8, 296 + 32, 57, 19, "-10")

    ; zLabel04 "Xmax" (VB6: Left=1320, Top=240) -> (88, 16)
    TextGadget(#zLabel04, 472 + 88, 296 + 16, 41, 17, "Xmax")
    ; txtXmax (VB6: Left=1320, Top=480) -> (88, 32)
    StringGadget(#txtXmax, 472 + 88, 296 + 32, 57, 19, "10")

    ; zLabel05 "Ymin" (VB6: Left=120, Top=840) -> (8, 56)
    TextGadget(#zLabel05, 472 + 8, 296 + 56, 49, 17, "Ymin")
    ; txtYmin (VB6: Left=120, Top=1080) -> (8, 72)
    StringGadget(#txtYmin, 472 + 8, 296 + 72, 57, 19, "-5")

    ; zLabel06 "Ymax" (VB6: Left=1320, Top=840) -> (88, 56)
    TextGadget(#zLabel06, 472 + 88, 296 + 56, 41, 17, "Ymax")
    ; txtYmax (VB6: Left=1320, Top=1080) -> (88, 72)
    StringGadget(#txtYmax, 472 + 88, 296 + 72, 57, 19, "5")

    ; cmdSG_OK (VB6: Left=120, Top=1560) -> (8, 104)
    ButtonGadget(#cmdSG_OK, 472 + 8, 296 + 104, 137, 20, "OK")

  EndIf
EndProcedure

; -----------------------------------------------------------------------------
; Main Event Loop
; -----------------------------------------------------------------------------

Open_frmSplines()
Init_Form_Load()

Repeat
  Define Event = WaitWindowEvent()

  Select Event
    Case #PB_Event_CloseWindow
      Break

    Case #PB_Event_Menu
      Select EventMenu()
        Case #mnuEsci
          Break
        Case #mnuInformazioni
          MessageRequester("Information", "Program for interpolation with Splines." + #CRLF$ + "Original VB6 by F. Languasco")
      EndSelect

    Case #PB_Event_Gadget
      Select EventGadget()
        Case #tabTipoI
          tabTipoI_Click()

        Case #picQuadro
          picQuadro_Events()

        Case #chkSegnaPc
          chkSegnaPc_Click()
        Case #cmdKZ_OK
          cmdKZ_OK_Click()
        Case #cmdNPI_OK
          cmdNPI_OK_Click()
        Case #cmdSG_OK
          cmdSG_OK_Click()
        Case #cmdNPC_OK
          cmdNPC_OK_Click()
      EndSelect

  EndSelect
ForEver

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 601
; FirstLine = 711
; Folding = -----
; EnableXP
; DPIAware