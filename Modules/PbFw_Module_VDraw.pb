; ===========================================================================
;  FILE : PbFw_Module_VDraw.pb
;  NAME : Module Vectror Drawing [VDraw::]
;  DESC : Implements Drawing Commands with the VectorDrawing Library
;  DESC : 
;  DESC : Based on Thorsten Hoeppner's DrawVectorExModule
;  DESC : https://github.com/Hoeppner1867/PureBasic/blob/master/DrawVectorEx/DrawVectorExModule.pbi
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/27
; VERSION  :  0.11 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ VDraw:: vs. DrawVectorEx Draw::
;   - I added some more detailed Procedure descriptions
;     and some comments
;   - DrawVectorEx used INTEGER for cooridates, but this is not suitable for mm.
;     For mm output scaling we need floating point values
;
;   - PureBasic Vector drawing use .d (double) as standard, so I changed
;     all variables with .i and .f to .d
;   - I changed all COLOR variables from .q (64Bit) to .l (32Bit)
;     Yes I know that PureBasic recommend to use a Quad COLOR because
;     of negative COLOR values when using a signed Long. 
;     But I use always 32Bit for COLOR. I never do direct compare like Col1>Col2
;
;   - I Included my Standard COLOR:: Module and removed double Functions
;      AlphaColor_(); MixColor_();  BlendColor()!     
;      Changed the AlphaChannel=0 Check to my Version - see MACRO mac_AddAlphaIfNull()
;
;   - I replaced the dpiX(), dpiY() Scaling Procedures with MACROs
;   - Changed Define statment in Procedures to Protected
;
;   - Added Exeption Handling because I want to have it for my Project
;
; 2025/02/02 S.Maag; use Module PB:: now; removed Module COL:: 
; 2024/07/17 S.Maag; added functions for regular Star shape and Triangle from Radius
;
; 2023/08/22 S.Maag; moved all local data to _TThis Structure to prepare for OOP 
;}
;{ TODO:
;}
; ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_PB.pb"          ; PB::       Purebasic Extention Module
XIncludeFile "PbFw_Module_Debug.pb"       ; DBG::      Debug Module

;{ *** All PB Vectro drawing commands ****
   ; AddPathArc                                      
  ; AddPathBox                                      
  ; AddPathCircle                                   
  ; AddPathCurve                                    
  ; AddPathEllipse                                  
  ; AddPathLine
  ; AddPathSegments
  ; AddPathText
  ; BeginVectorLayer
  ; ClipPath
  ; ClosePath
  ; ConvertCoordinateX
  ; ConvertCoordinateY
  ; CustomDashPath
  ; DashPath
  ; DotPath
  ; DrawVectorImage
  ; DrawVectorParagraph
  ; DrawVectorText
  ; EndVectorLayer
  ; FillPath
  ; FillVectorOutput
  ; FlipCoordinatesX
  ; FlipCoordinatesY
  ; IsInsidePath
  ; IsInsideStroke
  ; IsPathEmpty
  ; MovePathCursor
  ; NewVectorPage
  ; PathBoundsHeight
  ; PathBoundsWidth
  ; PathBoundsX
  ; PathBoundsY
  ; PathCursorX
  ; PathCursorY
  ; PathLength
  ; PathPointAngle
  ; PathPointX
  ; PathPointY
  ; PathSegments
  ; PdfVectorOutput
  ; ResetCoordinates
  ; ResetPath
  ; RestoreVectorState
  ; RotateCoordinates
  ; SaveVectorState
  ; ScaleCoordinates
  ; SkewCoordinates
  ; StartVectorDrawing
  ; StopVectorDrawing
  ; StrokePath
  ; SvgVectorOutput
  ; TranslateCoordinates
  ; VectorFont
  ; VectorOutputHeight
  ; VectorOutputWidth
  ; VectorParagraphHeight
  ; VectorResolutionX
  ; VectorResolutionY
  ; VectorSourceCircularGradient
  ; VectorSourceColor
  ; VectorSourceGradientColor
  ; VectorSourceImage
  ; VectorSourceLinearGradient
  ; VectorTextHeight
  ; VectorTextWidth
  ; VectorUnit
;}

;{ _____ DrawEx - Commands _____

; VDraw::Box_()           - similar to Box()
; VDraw::Circle_()        - similar to Circle()
; VDraw::CircleArc_()     - draws a arc of a circle
; VDraw::CircleSector_()  - draws a circle sector
; VDraw::Ellipse_()       - similar to Ellipse()
; VDraw::EllipseArc_()    - draws an arc of a ellipse

; VDraw::Line_()          - similar to Line()
; VDraw::VLine_()         - draws a vertical line
; VDraw::HLine_()         - draws a horizontal line
; VDraw::LineXY_()        - similar to LineXY()
; VDraw::LinesArc()       -
; VDraw::TangentsArc()    -

; VDraw::Font_()          - similar to DrawingFont()
; VDraw::Text_()          - similar to DrawText()
; VDraw::TextWidth_()     - similar to TextWidth()
; VDraw::TextHeight_()    - similar to TextHeight()

; VDraw::SetDotPattern()
; VDraw::DisableDotPattern()

; VDraw::SetStroke_()     - changes the stroke width
; VDraw::StartVector_()   - similar to StartVectorDrawing()
; VDraw::StopVector_()    - similar to StopVectorDrawing()

;}

DeclareModule VDraw
    
  EnumerationBinary EVDrawFlags
    #PbFw_VD_FLAG_Text_Default  = #PB_VectorText_Default 
    #PbFw_VD_FLAG_Text_Visible  = #PB_VectorText_Visible
    #PbFw_VD_FLAG_Text_Offset   = #PB_VectorText_Offset
    #PbFw_VD_FLAG_Text_Baseline = #PB_VectorText_Baseline
    #PbFw_VD_FLAG_Vertical
    #PbFw_VD_FLAG_Horizontal
    #PbFw_VD_FLAG_Diagonal
    #PbFw_VD_FLAG_Window
    #PbFw_VD_FLAG_Image
    #PbFw_VD_FLAG_Printer
    #PbFw_VD_FLAG_Canvas
  EndEnumeration
  
  #PbFw_VD_RoundEnd       = #PB_Path_RoundEnd
  #PbFw_VD_SquareEnd      = #PB_Path_SquareEnd
  #PbFw_VD_RoundCorner    = #PB_Path_RoundCorner
  #PbFw_VD_FLAG_DiagonalCorner = #PB_Path_DiagonalCorner
  
  ;- ----------------------------------------------------------------------
  ;-   Declare Module
  ;  ----------------------------------------------------------------------  
  
  ; To avoid confilcts with PureBasic 2D Drawing commands, we use "V_" as Prefix
  Declare.i  V_StartDraw(PBNo.i, OutPutType.i=#PbFw_VD_FLAG_Canvas, Unit.i=#PB_Unit_Pixel, Zoom.d=1.0, DPIscaling=#False)
  Declare.i  V_StopDraw() 

  Declare.i  V_Box(X.d, Y.d, Width.d, Height.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Rotate.d=0, Flags.i=#False)
  Declare.i  V_Circle(X.d, Y.d, Radius.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Flags.i=#False)
  Declare.i  V_CircleArc(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, Flags.i=#False)
  Declare.i  V_CircleSector(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Flags.i=#False)
  
  Declare.i  V_Ellipse(X.d, Y.d, RadiusX.d, RadiusY.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Rotate.d=0, Flags.i=#False)
  Declare.i  V_EllipseArc(X.d, Y.d, RadiusX.d, RadiusY.d, startAngle.d, endAngle.d, Color.l, Flags.i=#False)
  
  Declare.i  V_Line(X.d, Y.d, Width.d, Height.d, Color.l, Flags.i=#False)
  Declare.i  V_LinesArc(X1.d, Y1.d, X2.d, Y2.d, X3.d, Y3.d, Radius.d, Color.l, Flags.i=#False)
  Declare.i  V_LineH(X.d, Y.d, Width.d, Color.l, Flags.i=#False)
  Declare.i  V_LineV(X.d, Y.d, Height.d, Color.l, Flags.i=#False)
  Declare.i  V_LineXY(X1.d, Y1.d, X2.d, Y2.d, Color.l, Flags.i=#False)
  Declare.i  V_SetFont(FontID.i, Size.d=#PB_Default, Flags.i=#False)
  
  Declare.i  V_TangentsArc(X1.d, Y1.d, X2.d, Y2.d, X3.i, Y3.d, X4.d, Y4.d, Color.l, Flags.i=#False)
  Declare.i  V_Text(X.d, Y.d, Text$, Color.l, Angle.d=0, Flags.i=#False)
  Declare.d  V_GetTextWidth(Text.s,  Flags.i=#PB_VectorText_Default) ; [ #FLAG_Text_Default / #FLAG_Text_Visible / #FLAG_Text_Offset ]
  Declare.d  V_GetTextHeight(Text.s, Flags.i=#PB_VectorText_Default) ; [ #FLAG_Text_Default / #FLAG_Text_Visible / #FLAG_Text_Offset / #FLAG_Text_Baseline ]
  
  Declare.i  V_SetDotPattern(LineWidth.d, Array Pattern.d(1), Flags.i=#False, StartOffset.d=0)
  Declare.i  V_DisableDotPattern(State.i=#True)
  Declare.i  V_SetStroke(LineWidth.d=1)

EndDeclareModule


Module VDraw
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
    
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  #VectorDrawingNotStarted = DBG::#PbFw_DBG_Err_VectorDrawingNotStarted
  Global memScaleX.d = 1.0  ; total Zoom factor X [DPIscalingX * Zoom]
  Global memScaleY.d = 1.0  ; total Zoom factor Y [DPIscalingY * Zoom]
  Global memDPIscaling = #False
  
  Procedure _Exception(FName.s, ExceptionType)
    ; ======================================================================
    ; NAME: Vraw::_Exception
    ; DESC: Modul Exeption Handler
    ; VAR(FName): Function Name which caused the Exeption
    ; RET : -
    ; ======================================================================
    
    ; Call the Exception Handler Function in the Module Exception
    DBG::Exception(#PB_Compiler_Module, FName, ExceptionType)
    ProcedureReturn ExceptionType
  EndProcedure
  
  Structure _TPoint
    X.d     ; X As Double (64Bit Float)
    Y.d     ; Y As Double (64Bit Float)
  EndStructure

  Structure _TLineInfo
    Width.d
    State.i
    Flags.i
    Offset.i
    Array Pattern.d(1)
  EndStructure  
    
  Structure _TThis
    Line._TLineInfo
    Stroke.d
    VStart.i
  EndStructure
  
  Global This._TThis
  Global *This._TThis  ; prepare a Pointer on This to prepare it for OOP use
  *This = @This
  
  ; ======================================================================
  ; NAME: mac_AddAlphaIfNull
  ; DESC: Macro to set the Alpha Channel to 255 if it is 0 (=transparent)
  ; DESC: It's why drawing with Alpha=0 shows nothing because color is
  ; DESC: invisibel
  ; VAR(COLOR): The Color Value 32Bit 
  ; RET : -
  ; ======================================================================
   
  Macro mac_dpiX (Value)
    DesktopScaledX(Value)
  EndMacro
  
  Macro mac_dpiY (Value)
    DesktopScaledY(Value)
  EndMacro
  
  Macro mac_ScaleX(Value)
    Value * memScaleX  
  EndMacro
  
  Macro mac_ScaleY(Value)
    Value * memScaleY  
  EndMacro

  ; REPLACED with Macros mac_dpiX mac_dpiY
  
  ;   Procedure.d dpiX(Value.d)
  ;     ProcedureReturn DesktopScaledX(Value)
  ;   EndProcedure
  ;   
  ;   Procedure.d dpiY(Value.d)
  ;     ProcedureReturn DesktopScaledY(Value)
  ;   EndProcedure
  
  ; Private
  Procedure _LineXY(X1.d, Y1.d, X2.d, Y2.d, Color.l)
    
    PB::SetAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0

    MovePathCursor(X1, Y1)
    AddPathLine(X2, Y2)
    VectorSourceColor(Color)
    
    With *This
      If \Line\State And \Line\Width > 0
        CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
      Else
        StrokePath(\Stroke)
      EndIf  
    EndWith
  EndProcedure
  
  ; Private
  Procedure.i _FindLinesIntersection(L1_X1.d, L1_Y1.d, L1_X2.d, L1_Y2.d, L2_X1.d, L2_Y1.d, L2_X2.d, L2_Y2.d, *isP._TPoint)
    Protected.d L1_W, L1_H, L2_W, L2_H, Denominator, T1, T2
    
    L1_W = L1_X2 - L1_X1
    L1_H = L1_Y2 - L1_Y1
    L2_W = L2_X2 - L2_X1
    L2_H = L2_Y2 - L2_Y1
  
    Denominator = (L1_H * L2_W - L1_W * L2_H)
    T1 = ((L1_X1 - L2_X1) * L2_H + (L2_Y1 - L1_Y1) * L2_W) / Denominator
  
    If IsInfinity(T1)   ; if T1 is not a valid number
      ProcedureReturn #False 
    EndIf
  
    T2 = ((L2_X1 - L1_X1) * L1_H + (L1_Y1 - L2_Y1) * L1_W) / Denominator
    
    ; Intersection Point
    *isP\X = L1_X1 + L1_W * T1
    *isP\Y = L1_Y1 + L1_H * T2
  
    ProcedureReturn #True
  EndProcedure
  
  ; Private  
  Procedure.d _FindArcFromTangents(X1.d, Y1.d, X2.d, Y2.d, X3.i, Y3.d, X4.d, Y4.d, *isPoint._TPoint)
    Protected.d dX, dY, dX1, dY1, dX2, dY2, Radius
    Protected._TPoint sPoint, pPoint1, pPoint2, isCircle
   
    If _FindLinesIntersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4, *isPoint)
    
      dX1 = X2 - X1
      dY1 = Y2 - Y1
  
      pPoint1\X = X2 - dY1
      pPoint1\Y = X2 + dX1
      
      dX2 = X3 - X4
      dY2 = Y3 - Y4
      
      pPoint2\X = X3 - dY2
      pPoint2\Y = Y3 + dX2
      
      If _FindLinesIntersection(X2, Y2, pPoint1\X, pPoint1\Y, X3, Y3, pPoint2\X, pPoint2\Y, @isCircle)
    
        dX = X2 - isCircle\X
        dY = Y2 - isCircle\Y
      
        Radius = Sqr(dX * dX + dY * dY)
        
        ProcedureReturn Radius
      EndIf   
    EndIf  
  EndProcedure  
  
  Procedure _CalculateStarPoints(Array StarPoints._TPoint(1), outerRadius.d, innerRadius.d, numPoints, StartAngle=0)
  ; ======================================================================
  ; NAME: CalculateStarPoints
  ; DESC: Calculates the Points of regular Star
  ; VAR(Array StarPoints.Point(1)): Arry to return the Pionts
  ; VAR(outerRadius.f): Radius of the outer circle
  ; VAR(outerRadius.f): Radius of the inner circle
  ; VAR(numPoints): Number of Points/Spikes
  ; VAR(StartAngle) : Angle of the first Spike [0..360°]
  ; RET :
  ; ======================================================================
    Protected.d Phi, dPhi
    Protected.i I
    
    Dim StarPoints(2* numPoints - 1)
    
    Phi = Radian(StartAngle)
    dPhi = #PI /numPoints
    
    For I = 0 To numPoints - 1
      ; Calculate outer point
      StarPoints(I * 2)\x = Sin(Phi) * outerRadius
      StarPoints(I * 2)\y = Cos(Phi) * outerRadius
      Phi = Phi + dPhi
      
      ; Calculate inner point
      StarPoints(I * 2 + 1)\x = Sin(Phi) * innerRadius
      StarPoints(I * 2 + 1)\y = Cos(Phi) * innerRadius
      Phi = Phi + dPhi
    Next 
  EndProcedure
  
  Procedure _CalculateTrianglePoints(Array TrianglePoints._TPoint(1), radius.d, StartAngle=0)
    ; ======================================================================
    ; NAME: CalculateTrianglePoints
    ; DESC: Calculates the Points of an equilateral triangle
    ; VAR(Array TrianglePoints._TPoint(1)): Array to return the Points
    ; VAR(radius.d) : Radius of the circle circumscribed around the triangle
    ; VAR(StartAngle) : Angle of the first vertex [0..360°]
    ; RET :
    ; ======================================================================
    Protected.f Phi, dPhi
    Protected.i I
    
    Dim TrianglePoints(2)
    
    Phi = Radian(StartAngle)
    dPhi = 2 * #PI / 3 ; 120 degrees for equilateral triangle
    
    For I = 0 To 2
      TrianglePoints(I)\x = Sin(Phi) * radius
      TrianglePoints(I)\y = Cos(Phi) * radius
      Phi + dPhi
    Next I
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
    
  Procedure.i V_StartDraw(PBNo.i, OutPutType.i=#PbFw_VD_FLAG_Canvas, Unit.i=#PB_Unit_Pixel, Zoom.d=1.0, DPIscaling=#False) 
  ; ======================================================================
  ; NAME: V_StartDraw
  ; DESC: Start Vector Drawing
  ; VAR(PB_No): PureBasic Number; #Gadget, #Image. #Window
  ; VAR(OutPutType): #FLAG_Canvas, #FLAG_Image, #FLAG_Window, #FLAG_Printer
  ; VAR(Unit): #PB_Unit_Pixel, #PB_Unit_Millimeter, #PB_Unit_Inch, #PB_Unit_Point
  ; VAR(Zoom.d): Zoom factor
  ; VAR(DPIscaling) : Desktop/OS DPI-Scaling #FALE=OFF, #TRUE=ON
  ; RET : 0=FAULT;  <>0 Drawing started
  ; ======================================================================
    
    *This\Stroke = 1
    
    memDpiScaling = DPIscaling 

    If memDPIscaling
      memScaleX = Zoom * mac_ScaleX(1)
      memScaleY = Zoom * mac_ScaleY(1)
    Else
      memScaleX = Zoom
      memScaleY = Zoom
    EndIf
  
    Select OutPutType
        
      Case #PbFw_VD_FLAG_Canvas
        If IsGadget(PbNo)
          If GadgetType(PbNo) = #PB_GadgetType_Canvas
            If StartVectorDrawing(CanvasVectorOutput(PBNo, Unit))
              *This\VStart = #True
            EndIf
          EndIf
        EndIf  
        
      Case #PbFw_VD_FLAG_Image
        If IsImage(PbNo)
          If StartVectorDrawing(ImageVectorOutput(PBNo, Unit))
            *This\VStart = #True
          EndIf
        EndIf
        
      Case #PbFw_VD_FLAG_Window
        If IsWindow(PbNo)
          If StartVectorDrawing(WindowVectorOutput(PBNo, Unit))
            *This\VStart = #True   
          EndIf
        EndIf
        
      Case #PbFw_VD_FLAG_Printer    
        If StartVectorDrawing(PrinterVectorOutput(Unit))
          *This\VStart = #True
        EndIf
        
    EndSelect
        
    If *This\VStart = #False
      _Exception(#PB_Compiler_Procedure, #VectorDrawingNotStarted)
    EndIf
    
    ProcedureReturn *This\VStart
  EndProcedure
  
  Procedure.i V_StopDraw() 
  ; ======================================================================
  ; NAME: StopVector_
  ; DESC: Stops the Vector Drawing 
  ; RET : #True
  ; ======================================================================
    
    *This\Stroke = 0
    *This\Vstart = #False     ; clear the Start indication of VectorDrawing
    StopVectorDrawing()
    ProcedureReturn #True
  EndProcedure

  Procedure.i V_Box(X.d, Y.d, Width.d, Height.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Rotate.d=0, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_Box
  ; DESC: Draws a Box 
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Width): The Box width
  ; VAR(Height): The Box height
  ; VAR(Radius): Radius
  ; VAR(Color): Drawing Color
  ; VAR(FillColor): FillColor
  ; VAR(GradientColor): GradientColor
  ; VAR(Rotate): Rotation Angle in degree [+/-360]
  ; VAR(Flags): FLAGs
  ; RET : -
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started
  
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Width  = mac_ScaleX(Width)
      Height = mac_ScaleY(Height)
       
      PB::SetAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      If Rotate <>0 : RotateCoordinates(X, Y, Rotate) : EndIf
      
      AddPathBox(X, Y, Width, Height)
      VectorSourceColor(Color)
      
      If FillColor <> #PB_Default
        
        PB::SetAlphaIfNull(FillColor) ; set Alpha Channel to 255 if it is 0
  
        If GradientColor <> #PB_Default
          
          PB::SetAlphaIfNull(GradientColor) ; set Alpha Channel to 255 if it is 0

          If Flags & #PbFw_VD_FLAG_Horizontal
            VectorSourceLinearGradient(X, Y, X + Width, Y)
          ElseIf Flags & #PbFw_VD_FLAG_Diagonal
            VectorSourceLinearGradient(X, Y, X + Width, Y + Height)
          Else
            VectorSourceLinearGradient(X, Y, X, Y + Height)
          EndIf
          VectorSourceGradientColor(FillColor, 1.0)
          VectorSourceGradientColor(GradientColor, 0.0)
          FillPath(#PB_Path_Preserve)
        Else
          VectorSourceColor(FillColor)
          FillPath(#PB_Path_Preserve)
        EndIf
        
      EndIf
      
      VectorSourceColor(Color)
      
      With *This
        If \Line\State And \Line\Width > 0
          CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
        Else
          StrokePath(\Stroke)
        EndIf  
      EndWith
      If Rotate <>0  : RotateCoordinates(X, Y, -Rotate) : EndIf
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret                     
  EndProcedure
  
  Procedure.i V_Circle(X.d, Y.d, Radius.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_Circle
  ; DESC: Draws a Circle 
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Radius): Radius
  ; VAR(Color): Drawing Color
  ; VAR(FillColor): FillColor
  ; VAR(GradientColor): GradientColor
  ; VAR(Flags): FLAGs
  ; RET : -
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started
   
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Radius = mac_ScaleX(Radius)
       
      PB::SetAlphaIfNull(Color)             ; set Alpha Channel to 255 if it is 0
      
      AddPathCircle(X, Y, Radius)
      
      If FillColor <> #PB_Default
        
        PB::SetAlphaIfNull(FillColor)       ; set Alpha Channel to 255 if it is 0
        
        If GradientColor <> #PB_Default
          PB::SetAlphaIfNull(GradientColor) ; set Alpha Channel to 255 if it is 0
          
          VectorSourceCircularGradient(X, Y, Radius)
          VectorSourceGradientColor(FillColor, 1.0)
          VectorSourceGradientColor(GradientColor, 0.0)
          FillPath(#PB_Path_Preserve)
        Else
          VectorSourceColor(FillColor)
          FillPath(#PB_Path_Preserve)
        EndIf
        
      EndIf
      
      VectorSourceColor(Color)
      With *This
        If \Line\State And \Line\Width > 0
          CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
        Else
          StrokePath(\Stroke)
        EndIf  
      EndWith
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret                  
  EndProcedure
  
  Procedure.i V_CircleArc(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_CircleArc
  ; DESC: Draws a Circle Arc
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Radius): Radius
  ; VAR(startAngle): Start Angle
  ; VAR(endAngle): End Angle
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; RET : -
  ; ======================================================================
  
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started
      
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Radius = mac_ScaleX(Radius)
       
      PB::SetAlphaIfNull(Color)           ; set Alpha Channel to 255 if it is 0
      
      AddPathCircle(X, Y, Radius, startAngle, endAngle)
      
      VectorSourceColor(Color)
      
      With *This
        If \Line\State And \Line\Width > 0
          CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
        Else
          StrokePath(\Stroke)
        EndIf  
      EndWith
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret                  
  EndProcedure
  
  Procedure.i V_CircleSector(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_CircleSector
  ; DESC: Draws a Circle Sector 
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Radius): Radius
  ; VAR(startAngle): Start Angle
  ; VAR(endAngle): End Angle
  ; VAR(Color): Drawing Color
  ; VAR(FillColor): FillColor
  ; VAR(GradientColor): GradientColor
  ; VAR(Flags): FLAGs
  ; RET : -
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started
    
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Radius = mac_ScaleX(Radius)
       
      PB::SetAlphaIfNull(Color)             ; set Alpha Channel to 255 if it is 0
  
      MovePathCursor(X, Y)
      AddPathCircle(X, Y, Radius, startAngle, endAngle, #PB_Path_Connected)
      ClosePath()
      
      If FillColor <> #PB_Default
        
        PB::SetAlphaIfNull(FillColor)       ; set Alpha Channel to 255 if it is 0
        
        If GradientColor <> #PB_Default
          PB::SetAlphaIfNull(GradientColor) ; set Alpha Channel to 255 if it is 0
          
          VectorSourceCircularGradient(X, Y, Radius)
          VectorSourceGradientColor(FillColor, 0.0)
          VectorSourceGradientColor(GradientColor, 1.0)
          FillPath(#PB_Path_Preserve)
        Else
          VectorSourceColor(FillColor)
          FillPath(#PB_Path_Preserve)
        EndIf
        
      EndIf
      
      VectorSourceColor(Color)
      With *This
        If \Line\State And \Line\Width > 0
          CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
        Else
          StrokePath(\Stroke)
        EndIf  
      EndWith
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret               
  EndProcedure
    
  Procedure.i V_Ellipse(X.d, Y.d, RadiusX.d, RadiusY.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Rotate.d=0, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_Ellipse
  ; DESC: Draws a Ellipse
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(RadiusX): X-Radius
  ; VAR(RadiusY): Y-Radius
  ; VAR(Color): Drawing Color
  ; VAR(FillColor): FillColor
  ; VAR(GradientColor): GradientColor
  ; VAR(Rotate): Rotation Angle in degree [+/-360]
  ; VAR(Flags): FLAGs
  ; RET : -
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started

      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      RadiusX = mac_ScaleX(RadiusX)
      RadiusY = mac_ScaleY(RadiusY)
        
      PB::SetAlphaIfNull(Color)             ; set Alpha Channel to 255 if it is 0
      
      If Rotate <>0 : RotateCoordinates(X, Y, Rotate) : EndIf
      
      AddPathEllipse(X, Y, RadiusX, RadiusY)
      
      If FillColor <> #PB_Default
        
        PB::SetAlphaIfNull(FillColor)       ; set Alpha Channel to 255 if it is 0
        
        If GradientColor <> #PB_Default
          PB::SetAlphaIfNull(GradientColor) ; set Alpha Channel to 255 if it is 0
          
          If RadiusX > RadiusY
            VectorSourceCircularGradient(X, Y, RadiusX)
          Else
            VectorSourceCircularGradient(X, Y, RadiusY)
          EndIf 
          
          VectorSourceGradientColor(FillColor, 1.0)
          VectorSourceGradientColor(GradientColor, 0.0)
          FillPath(#PB_Path_Preserve)
          
        Else
          VectorSourceColor(FillColor)
          FillPath(#PB_Path_Preserve)
        EndIf
        
      EndIf
      
      VectorSourceColor(Color)
      With *This
        If \Line\State And \Line\Width > 0
          CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
        Else
          StrokePath(\Stroke)
        EndIf  
      EndWith
      If Rotate <>0 : RotateCoordinates(X, Y, -Rotate) : EndIf
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret             
  EndProcedure
  
  Procedure.i V_EllipseArc(X.d, Y.d, RadiusX.d, RadiusY.d, startAngle.d, endAngle.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_EllipseArc
  ; DESC: Draws a Ellipse Arc {Ellipsenbogen}
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(RadiusX): X-Radius
  ; VAR(RadiusY): Y-Radius
  ; VAR(startAngle): Start Angle
  ; VAR(endAngle): End Angle
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; RET : -
  ; ======================================================================
   
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started
      
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      RadiusX = mac_ScaleX(RadiusX)
      RadiusY = mac_ScaleY(RadiusY)
        
      PB::SetAlphaIfNull(Color)         ; set Alpha Channel to 255 if it is 0
     
      AddPathEllipse(X, Y, RadiusX, RadiusY, startAngle, endAngle)
      VectorSourceColor(Color)
      
      With *This
        If \Line\State And \Line\Width > 0
          CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
        Else
          StrokePath(\Stroke)
        EndIf  
      EndWith
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret          
  EndProcedure

  Procedure.i V_Line(X.d, Y.d, Width.d, Height.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_Line
  ; DESC: Draws a Line
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Width):  The Line width  :  X2 = X + Width
  ; VAR(Height): The Line height :  Y2 = Y + Height
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started

      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Width  = mac_ScaleX(Width)
      Height = mac_ScaleY(Height)
      
      ; AlphaCheck will be done in _LineXY()
      ; PB::SetAlphaIfNull(Color)     ; set Alpha Channel to 255 if it is 0
      
      If Width And Height
        
        If Width > 1
           _LineXY(X, Y, X + Width, Y, Color)
         Else
           _LineXY(X, Y, X, Y + Height, Color)
        EndIf
        
      EndIf
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret        
  EndProcedure
  
  Procedure.i V_LineV(X.d, Y.d, Height.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_LineV
  ; DESC: Draws a vertical Line
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Height): The Line height :  Y2 = Y + Height
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started

      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Height = mac_ScaleY(Height)
      
      ; AlphaCheck will be done in _LineXY()
      ; mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      If Height
        _LineXY(X, Y, X, Y + Height, Color)
      EndIf
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret        
  EndProcedure
  
  Procedure.i V_LineH(X.d, Y.d, Width.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_LineH
  ; DESC: Draws a horizontal Line
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Width):  The Line width  :  X2 = X + Width
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; ======================================================================
   
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started
      
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Width  = mac_ScaleX(Width)
      
      ; AlphaCheck will be done in _LineXY()
      ; mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      If Width > 1 
        _LineXY(X, Y, X + Width, Y, Color)
      EndIf    
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret  
  EndProcedure
  
  Procedure.i V_LineXY(X1.d, Y1.d, X2.d, Y2.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_LineXY
  ; DESC: Draws a Line between 2 Points
  ; VAR(X1): X-Coordinate Point 1
  ; VAR(Y1): Y-Coordinate Point 1
  ; VAR(X2): X-Coordinate Point 2
  ; VAR(Y2): Y-Coordinate Point 2
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; RET.i: 0 or ExeptionType
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started
   
      X1 = mac_ScaleX(X1)
      Y1 = mac_ScaleY(Y1)
      X2 = mac_ScaleX(X2)
      Y2 = mac_ScaleY(Y2)
      
      ; AlphaCheck will be done in _LineXY()
      ; mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
  
      _LineXY(X1, Y1, X2, Y2, Color)
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret  
  EndProcedure
    
  Procedure.i V_LinesArc(X1.d, Y1.d, X2.d, Y2.d, X3.d, Y3.d, Radius.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_LinesArc
  ; DESC: Draws a Arc between 3 Points 
  ; VAR(X1): X-Coordinate Point 1
  ; VAR(Y1): Y-Coordinate Point 1
  ; VAR(X2): X-Coordinate Point 2
  ; VAR(Y2): Y-Coordinate Point 2
  ; VAR(X3): X-Coordinate Point 3
  ; VAR(Y3): Y-Coordinate Point 3
  ; VAR(Radius): Radius Curve Radius
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs   
  ; RET.i: 0 or ExeptionType
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started

      X1 = mac_ScaleX(X1)
      Y1 = mac_ScaleY(Y1)
      X2 = mac_ScaleX(X2)
      Y2 = mac_ScaleY(Y2)
      X3 = mac_ScaleX(X3)
      Y3 = mac_ScaleY(Y3)
      Radius = mac_ScaleX(Radius)
      
      PB::SetAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      MovePathCursor(X1, Y1)
      AddPathArc(X2, Y2, X3, Y3, Radius)
      AddPathLine(X3, Y3)
      
      VectorSourceColor(Color)
      With *This
        If \Line\State And \Line\Width > 0
          CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
        Else
          StrokePath(\Stroke)
        EndIf  
      EndWith
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i V_TangentsArc(X1.d, Y1.d, X2.d, Y2.d, X3.i, Y3.d, X4.d, Y4.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_TangentsArc
  ; DESC: Draws a tangetial ARC 
  ; VAR(X1): X-Coordinate Point 1
  ; VAR(Y1): Y-Coordinate Point 1
  ; VAR(X2): X-Coordinate Point 2
  ; VAR(Y2): Y-Coordinate Point 2
  ; VAR(X3): X-Coordinate Point 3
  ; VAR(Y3): Y-Coordinate Point 3
  ; VAR(X4): X-Coordinate Point 4
  ; VAR(Y4): Y-Coordinate Point 4
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs   
  ; RET.i: 0 or ExeptionType
  ; ======================================================================
    Protected Angle.d
    Protected isP._TPoint ; Intersection Point
    Protected ret
    
    If *This\VStart  ; if Vector drawing is started
      
      X1 = mac_ScaleX(X1)
      Y1 = mac_ScaleY(Y1)
      X2 = mac_ScaleX(X2)
      Y2 = mac_ScaleY(Y2)
      X3 = mac_ScaleX(X3)
      Y3 = mac_ScaleY(Y3)
      X4 = mac_ScaleX(X4)
      Y4 = mac_ScaleY(Y4)
       
      PB::SetAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      Angle = _FindArcFromTangents(X1, Y1, X2, Y2, X3, Y3, X4, Y4, @isP)
      
      MovePathCursor(X1, Y1)
      AddPathLine(X2, Y2)
      AddPathArc(isP\X, isP\Y, X3, Y3, Angle)
      AddPathLine(X4, Y4)
  
      VectorSourceColor(Color)
      With *This
        If \Line\State And \Line\Width > 0
          CustomDashPath(\Line\Width, \Line\Pattern(), \Line\Flags, \Line\Offset)
        Else
          StrokePath(\Stroke)
        EndIf  
      EndWith
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)
    EndIf 
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i V_SetFont(FontID.i, Size.d=#PB_Default, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_SetFont
  ; DESC: Set the Font and Size
  ; VAR(X): 
  ; VAR(FontID): Font ID
  ; VAR(Size): Font Size
  ; VAR(Flags): FLAGs
  ; RET : -
  ; ======================================================================
   
    Size = mac_ScaleY(Size)
    
    If Size <= 0
      VectorFont(FontID)
    Else
      VectorFont(FontID, Size)
    EndIf

  EndProcedure

  Procedure.i V_Text(X.d, Y.d, Text$, Color.l, Rotate.d=0, Flags.i=#False)
  ; ======================================================================
  ; NAME: V_Text
  ; DESC: Draws a Text at X, Y
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Text$): The Text String
  ; VAR(Flags): FLAGs   
  ; RET.i: 0 or ExeptionType
  ; ======================================================================
    
    Protected ret
    
    If *This\VStart

      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
       
      PB::SetAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      If Rotate <> 0 : RotateCoordinates(X, Y, Rotate) : EndIf
      
      MovePathCursor(X, Y)
      VectorSourceColor(Color)
      DrawVectorText(Text$)
  
      If Rotate <> 0 : RotateCoordinates(X, Y, -Rotate) : EndIf
    Else
      ret = #VectorDrawingNotStarted
      _Exception(#PB_Compiler_Procedure, ret)     
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure.d V_GetTextWidth(Text.s, Flags.i=#PB_VectorText_Default)
    ; ======================================================================
    ; NAME: V_GetTextWidth
    ; DESC: Calculates the Text Width
    ; VAR(X): 
   ; RET : Text width in units according to the setting Pixel, mm ...
    ; ======================================================================
   
    Protected ret.d
    
    If *This\VStart
      ret= VectorTextWidth(Text, Flags)
    Else
      ret= 0
      _Exception(#PB_Compiler_Procedure, #VectorDrawingNotStarted)
    EndIf
    
    ProcedureReturn ret
 EndProcedure
  
  Procedure.d V_GetTextHeight(Text.s, Flags.i=#PB_VectorText_Default)
  ; ======================================================================
  ; NAME: V_GetTextHeight
  ; DESC: Calculates the Text Height
  ; VAR(Text$): The Text String
  ; VAR(Flags): FLAGs   
  ; RET : Text width in units according to the setting Pixel, mm ...
  ; ======================================================================
    Protected ret.d
    
    If *This\VStart
      ret= VectorTextHeight(Text, Flags)  
    Else
      ret= 0
      _Exception(#PB_Compiler_Procedure, #VectorDrawingNotStarted)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i V_SetDotPattern(LineWidth.d, Array Pattern.d(1), Flags.i=#False, StartOffset.d=0)
  ; ======================================================================
  ; NAME: V_SetDotPattern
  ; DESC: Sets the DotPattern
  ; VAR(LineWidth): LineWidth (thickness)
  ; VAR(Array Patternd(1): The pattern definition (dash and dot length)    
  ; VAR(Flags): FLAGs   
  ; VAR(StartOffset): Sart Offset        
  ; RET : .
  ; ======================================================================
    
    With *This
      \Line\Width = mac_ScaleX(LineWidth)
       
      CopyArray(Pattern(), \Line\Pattern())
      
      \Line\Flags     = Flags
      \Line\Offset    = StartOffset
      
      If LineWidth
        \Line\State = #True
      Else
        \Line\State = #False
      EndIf
    EndWith
  EndProcedure
  
  Procedure.i V_DisableDotPattern(NewState.i=#True)
  ; ======================================================================
  ; NAME: V_DisableDotPattern
  ; DESC: Disable/Enable DotPattern
  ; VAR(NewState): #FALSE=Disabled, #TRUE=Enabled
  ; RET : -
  ; ======================================================================
    
    With *This
      If NewState
        \Line\State = #False
      Else  
        \Line\State = #True
      EndIf
    EndWith
  EndProcedure  

  Procedure.i V_SetStroke(LineWidth.d=1)
  ; ======================================================================
  ; NAME: V_SetStroke
  ; DESC: Sets the Stroke, LineWidth (thikness)
  ; VAR(LineWidth): Line width (thickness)
  ; RET : .
  ; ======================================================================
    
    *This\Stroke = LineWidth
  EndProcedure
   
EndModule

CompilerIf #PB_Compiler_IsMainFile
 ;- ----------------------------------------------------------------------
 ;-  M O D U L E   T E S T   C O D E
 ;-  ---------------------------------------------------------------------- 
  
  EnableExplicit
 
  #PbFw_VD_FLAG_Window = 0
  #Gadget = 1
  #Font   = 2
  
  LoadFont(#Font, "Arial", 16, #PB_Font_Bold)
  
  Dim Pattern.d(3)
  
  Pattern(0) = 0
  Pattern(1) = 5
  Pattern(2) = 6
  Pattern(3) = 5
  
  If OpenWindow(#PbFw_VD_FLAG_Window, 0, 0, 200, 200, "VectorDrawing Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered)
    
    CanvasGadget(#Gadget, 10, 10, 180, 180)

    If VDraw::V_StartDraw(#Gadget, VDraw::#PbFw_VD_FLAG_Canvas)
      
      VDraw::V_SetFont(FontID(#Font))
      
      VDraw::V_Box(2, 2, 176, 176, $CD0000, $FACE87, $FFF8F0, 0) ; VDraw::#FLAG_Horizontal / VDraw::#FLAG_Diagonal
      VDraw::V_Text(65, 65, "Text", $701919, #False)
      
      ;VDraw::SetDotPattern(2, Pattern())
      
      VDraw::V_CircleSector(90, 90, 70, 40, 90, $800000, $00D7FF, $008CFF)
      VDraw::V_SetStroke(2)
      VDraw::V_LineXY(90, 90, 90 + 80 * Cos(Radian(150)), 90 + 80 * Sin(Radian(150)), $228B22)
      VDraw::V_Circle(90, 90, 80, $800000, #PB_Default, #PB_Default)
      ;VDraw::V_Ellipse(90, 90, 80, 60, $800000, $FACE87, $FFF8F0, 30)
      VDraw::V_SetStroke(4)
      VDraw::V_EllipseArc(90, 90, 70, 45, 160, 240, $CC3299)
      VDraw::V_SetStroke(1)
      VDraw::V_CircleArc(90, 90, 70, 250, 340, $008CFF)
      
      ;VDraw::DisableDotPattern(#True)
      
      VDraw::V_Line(10, 90, 160, 1, $8515C7)
      
      VDraw::V_Stopdraw()
    EndIf
    
    Repeat
      Define Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
    
  EndIf

  DisableExplicit
CompilerEndIf  


; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 271
; FirstLine = 258
; Folding = -------
; Optimizer
; CPU = 5