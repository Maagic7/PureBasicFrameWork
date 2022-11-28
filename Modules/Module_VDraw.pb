; ===========================================================================
;  FILE : Module_VDraw.pb
;  NAME : Module Vectror Drawing [VDraw::]
;  DESC : Implements Drawing Commands with the VectorDrawing Library
;  DESC : 
;  DESC : Based on Thorsten Hoeppner's DrawVectorExModule
;  DESC : https://github.com/Hoeppner1867/PureBasic/blob/master/DrawVectorEx/DrawVectorExModule.pbi
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/27
; VERSION  :  1.0
; COMPILER :  PureBasic 6.0
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
;}
; ============================================================================

;{ ====================      M I T   L I C E N S E        ====================
;
; Copyright (c) 2019 Thorsten Hoeppner ; 2022 S.Maag
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

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "Module_Color.pb"
XIncludeFile "Module_Exception.pb"

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
    
  EnumerationBinary FLAGs
    #FLAG_Text_Default  = #PB_VectorText_Default 
    #FLAG_Text_Visible  = #PB_VectorText_Visible
    #FLAG_Text_Offset   = #PB_VectorText_Offset
    #FLAG_Text_Baseline = #PB_VectorText_Baseline
    #FLAG_Vertical
    #FLAG_Horizontal
    #FLAG_Diagonal
    #FLAG_Window
    #FLAG_Image
    #FLAG_Printer
    #FLAG_Canvas
  EndEnumeration
  
  #RoundEnd       = #PB_Path_RoundEnd
  #SquareEnd      = #PB_Path_SquareEnd
  #RoundCorner    = #PB_Path_RoundCorner
  #FLAG_DiagonalCorner = #PB_Path_DiagonalCorner
  
  ;- ----------------------------------------------------------------------
  ;-   Declare Module
  ;  ----------------------------------------------------------------------  
  
  ; To avoid confilcts with PureBasic 2D Drawing commands, we use "_" at the end of the commands
  
  Declare   Box_(X.d, Y.d, Width.d, Height.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Rotate.d=0, Flags.i=#False)
  Declare   Circle_(X.d, Y.d, Radius.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Flags.i=#False)
  Declare   CircleArc_(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, Flags.i=#False)
  Declare   CircleSector_(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Flags.i=#False)
  
  Declare   Ellipse_(X.d, Y.d, RadiusX.d, RadiusY.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Rotate.d=0, Flags.i=#False)
  Declare   EllipseArc_(X.d, Y.d, RadiusX.d, RadiusY.d, startAngle.d, endAngle.d, Color.l, Flags.i=#False)
  
  Declare   Line_(X.d, Y.d, Width.d, Height.d, Color.l, Flags.i=#False)
  Declare   LinesArc_(X1.d, Y1.d, X2.d, Y2.d, X3.d, Y3.d, Radius.d, Color.l, Flags.i=#False)
  Declare   HLine_(X.d, Y.d, Width.d, Color.l, Flags.i=#False)
  Declare   VLine_(X.d, Y.d, Height.d, Color.l, Flags.i=#False)
  Declare   LineXY_(X1.d, Y1.d, X2.d, Y2.d, Color.l, Flags.i=#False)
  Declare   Font_(FontID.i, Size.d=#PB_Default, Flags.i=#False)
  
  Declare   TangentsArc_(X1.d, Y1.d, X2.d, Y2.d, X3.i, Y3.d, X4.d, Y4.d, Color.l, Flags.i=#False)
  Declare   Text_(X.d, Y.d, Text$, Color.l, Angle.d=0, Flags.i=#False)
  Declare.d TextWidth_(Text.s,  Flags.i=#PB_VectorText_Default) ; [ #FLAG_Text_Default / #FLAG_Text_Visible / #FLAG_Text_Offset ]
  Declare.d TextHeight_(Text.s, Flags.i=#PB_VectorText_Default) ; [ #FLAG_Text_Default / #FLAG_Text_Visible / #FLAG_Text_Offset / #FLAG_Text_Baseline ]
  
  Declare   SetDotPattern(LineWidth.d, Array Pattern.d(1), Flags.i=#False, StartOffset.d=0)
  Declare   DisableDotPattern(State.i=#True)
  Declare   SetStroke_(LineWidth.d=1)
  Declare.i StartVector_(PB_No.i, OutPutType.i=#FLAG_Canvas, Unit.i=#PB_Unit_Pixel, Zoom.d=1.0, DPIscaling=#False)
  Declare   StopVector_() 

EndDeclareModule


Module VDraw
  
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  #VectorDrawingNotStarted = Exception::#EXCEPTION_VectorDrawingNotStarted
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
    Exception::Exception("VDraw", FName, ExceptionType)
    ProcedureReturn ExceptionType
  EndProcedure

  Structure TLineInfo
    Width.d
    State.i
    Flags.i
    Offset.i
    Array Pattern.d(1)
  EndStructure  
  
  Structure TPoint
    X.d     ; X As Double (64Bit Float)
    Y.d     ; Y As Double (64Bit Float)
  EndStructure
   
  Global Stroke.i, VStart.i, Line.TLineInfo
  Global VStart.i ; indication VectorDrawing started
  
  Macro mac_AddAlphaIfNull(Color)
  ; ======================================================================
  ; NAME: mac_AddAlphaIfNull
  ; DESC: Macro to set the Alpha Channel to 255 if it is 0 (=transparent)
  ; DESC: It's why drawing with Alpha=0 shows nothing because color is
  ; DESC: invisibel
  ; VAR(COLOR): The Color Value 32Bit 
  ; RET : -
  ; ======================================================================

    If Alpha(Color)=0 
      Color = Color | COLOR::#AlphaMask  ; Set Alpha =255 -> full intransparent
    EndIf
  EndMacro
  
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
  
 
  Procedure _LineXY(X1.d, Y1.d, X2.d, Y2.d, Color.l)
    
    mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0

    MovePathCursor(X1, Y1)
    AddPathLine(X2, Y2)
    VectorSourceColor(Color)
    
    If Line\State And Line\Width > 0
      CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
    Else
      StrokePath(Stroke)
    EndIf  
    
  EndProcedure
  
  

  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
  
  Procedure Box_(X.d, Y.d, Width.d, Height.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Rotate.d=0, Flags.i=#False)
  ; ======================================================================
  ; NAME: Box
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
    
    If VStart  ; if Vector drawing is started
  
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Width  = mac_ScaleX(Width)
      Height = mac_ScaleY(Height)
       
      mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      If Rotate <>0 : RotateCoordinates(X, Y, Rotate) : EndIf
      
      AddPathBox(X, Y, Width, Height)
      VectorSourceColor(Color)
      
      If FillColor <> #PB_Default
        
        mac_AddAlphaIfNull(FillColor) ; set Alpha Channel to 255 if it is 0
  
        If GradientColor <> #PB_Default
          
          mac_AddAlphaIfNull(GradientColor) ; set Alpha Channel to 255 if it is 0

          If Flags & #FLAG_Horizontal
            VectorSourceLinearGradient(X, Y, X + Width, Y)
          ElseIf Flags & #FLAG_Diagonal
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
      
      If Line\State And Line\Width > 0
        CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
      Else
        StrokePath(Stroke)
      EndIf  
      
      If Rotate <>0  : RotateCoordinates(X, Y, -Rotate) : EndIf
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception("Box_",ret)
    EndIf 
    
    ProcedureReturn ret                     
  EndProcedure
  
  Procedure Circle_(X.d, Y.d, Radius.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Flags.i=#False)
  ; ======================================================================
  ; NAME: Circle_
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
    
    If VStart  ; if Vector drawing is started
   
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Radius = mac_ScaleX(Radius)
       
      mac_AddAlphaIfNull(Color)             ; set Alpha Channel to 255 if it is 0
      
      AddPathCircle(X, Y, Radius)
      
      If FillColor <> #PB_Default
        
        mac_AddAlphaIfNull(FillColor)       ; set Alpha Channel to 255 if it is 0
        
        If GradientColor <> #PB_Default
          mac_AddAlphaIfNull(GradientColor) ; set Alpha Channel to 255 if it is 0
          
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
      
      If Line\State And Line\Width > 0
        CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
      Else
        StrokePath(Stroke)
      EndIf  
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception("Circle_",ret)
    EndIf 
    
    ProcedureReturn ret                  
  EndProcedure
  
  Procedure CircleArc_(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: CircleArc_
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
    
    If VStart  ; if Vector drawing is started
      
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Radius = mac_ScaleX(Radius)
       
      mac_AddAlphaIfNull(Color)           ; set Alpha Channel to 255 if it is 0
      
      AddPathCircle(X, Y, Radius, startAngle, endAngle)
      
      VectorSourceColor(Color)
      
      If Line\State And Line\Width > 0
        CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
      Else
        StrokePath(Stroke)
      EndIf  
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception("CircleArc_",ret)
    EndIf 
    
    ProcedureReturn ret                  
  EndProcedure
  
  Procedure CircleSector_(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Flags.i=#False)
  ; ======================================================================
  ; NAME: CircleSector_
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
    
    If VStart  ; if Vector drawing is started
    
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Radius = mac_ScaleX(Radius)
       
      mac_AddAlphaIfNull(Color)             ; set Alpha Channel to 255 if it is 0
  
      MovePathCursor(X, Y)
      AddPathCircle(X, Y, Radius, startAngle, endAngle, #PB_Path_Connected)
      ClosePath()
      
      If FillColor <> #PB_Default
        
        mac_AddAlphaIfNull(FillColor)       ; set Alpha Channel to 255 if it is 0
        
        If GradientColor <> #PB_Default
          mac_AddAlphaIfNull(GradientColor) ; set Alpha Channel to 255 if it is 0
          
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
      
      If Line\State And Line\Width > 0
        CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
      Else
        StrokePath(Stroke)
      EndIf  
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception("CircleSector_",ret)
    EndIf 
    
    ProcedureReturn ret               
  EndProcedure
    
  Procedure Ellipse_(X.d, Y.d, RadiusX.d, RadiusY.d, Color.l, FillColor.l=#PB_Default, GradientColor.l=#PB_Default, Rotate.d=0, Flags.i=#False)
  ; ======================================================================
  ; NAME: Ellipse_
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
    
    If VStart  ; if Vector drawing is started

      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      RadiusX = mac_ScaleX(RadiusX)
      RadiusY = mac_ScaleY(RadiusY)
        
      mac_AddAlphaIfNull(Color)             ; set Alpha Channel to 255 if it is 0
      
      If Rotate <>0 : RotateCoordinates(X, Y, Rotate) : EndIf
      
      AddPathEllipse(X, Y, RadiusX, RadiusY)
      
      If FillColor <> #PB_Default
        
        mac_AddAlphaIfNull(FillColor)       ; set Alpha Channel to 255 if it is 0
        
        If GradientColor <> #PB_Default
          mac_AddAlphaIfNull(GradientColor) ; set Alpha Channel to 255 if it is 0
          
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
      
      If Line\State And Line\Width > 0
        CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
      Else
        StrokePath(Stroke)
      EndIf  
      
      If Rotate <>0 : RotateCoordinates(X, Y, -Rotate) : EndIf
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception("Ellipse_",ret)
    EndIf 
    
    ProcedureReturn ret             
  EndProcedure
  
  Procedure EllipseArc_(X.d, Y.d, RadiusX.d, RadiusY.d, startAngle.d, endAngle.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: EllipseArc_
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
    
    If VStart  ; if Vector drawing is started
      
      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      RadiusX = mac_ScaleX(RadiusX)
      RadiusY = mac_ScaleY(RadiusY)
        
      mac_AddAlphaIfNull(Color)         ; set Alpha Channel to 255 if it is 0
     
      AddPathEllipse(X, Y, RadiusX, RadiusY, startAngle, endAngle)
      VectorSourceColor(Color)
      
      If Line\State And Line\Width > 0
        CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
      Else
        StrokePath(Stroke)
      EndIf  
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception("EllipseArc_",ret)
    EndIf 
    
    ProcedureReturn ret          
  EndProcedure

  Procedure Line_(X.d, Y.d, Width.d, Height.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: Line_
  ; DESC: Draws a Line
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Width):  The Line width  :  X2 = X + Width
  ; VAR(Height): The Line height :  Y2 = Y + Height
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; ======================================================================
    
    Protected ret
    
    If VStart  ; if Vector drawing is started

      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
      Width  = mac_ScaleX(Width)
      Height = mac_ScaleY(Height)
      
      ; AlphaCheck will be done in _LineXY()
      ; mac_AddAlphaIfNull(Color)     ; set Alpha Channel to 255 if it is 0
      
      If Width And Height
        
        If Width > 1
           _LineXY(X, Y, X + Width, Y, Color)
         Else
           _LineXY(X, Y, X, Y + Height, Color)
        EndIf
        
      EndIf
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception("Line_",ret)
    EndIf 
    
    ProcedureReturn ret        
  EndProcedure
  
  Procedure VLine_(X.d, Y.d, Height.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: VLine_
  ; DESC: Draws a vertical Line
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Height): The Line height :  Y2 = Y + Height
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; ======================================================================
    
    Protected ret
    
    If VStart  ; if Vector drawing is started

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
      _Exception("VLine_",ret)
    EndIf 
    
    ProcedureReturn ret        
  EndProcedure
  
  Procedure HLine_(X.d, Y.d, Width.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: HLine_
  ; DESC: Draws a horizontal Line
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Width):  The Line width  :  X2 = X + Width
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; ======================================================================
   
    Protected ret
    
    If VStart  ; if Vector drawing is started
      
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
      _Exception("HLine_",ret)
    EndIf 
    
    ProcedureReturn ret  
  EndProcedure
  
  Procedure LineXY_(X1.d, Y1.d, X2.d, Y2.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: LineXY_
  ; DESC: Draws a Line between 2 Points
  ; VAR(X1): X-Coordinate Point 1
  ; VAR(Y1): Y-Coordinate Point 1
  ; VAR(X2): X-Coordinate Point 2
  ; VAR(Y2): Y-Coordinate Point 2
  ; VAR(Color): Drawing Color
  ; VAR(Flags): FLAGs
  ; ======================================================================
    
    Protected ret
    
    If VStart  ; if Vector drawing is started
   
      X1 = mac_ScaleX(X1)
      Y1 = mac_ScaleY(Y1)
      X2 = mac_ScaleX(X2)
      Y2 = mac_ScaleY(Y2)
      
      ; AlphaCheck will be done in _LineXY()
      ; mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
  
      _LineXY(X1, Y1, X2, Y2, Color)
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception("LineXY_",ret)
    EndIf 
    
    ProcedureReturn ret  
  EndProcedure
    
  Procedure LinesArc_(X1.d, Y1.d, X2.d, Y2.d, X3.d, Y3.d, Radius.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: LinesArc_
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
  ; RET : -
  ; ======================================================================
    
    Protected ret
    
    If VStart  ; if Vector drawing is started

      X1 = mac_ScaleX(X1)
      Y1 = mac_ScaleY(Y1)
      X2 = mac_ScaleX(X2)
      Y2 = mac_ScaleY(Y2)
      X3 = mac_ScaleX(X3)
      Y3 = mac_ScaleY(Y3)
      Radius = mac_ScaleX(Radius)
      
      mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      MovePathCursor(X1, Y1)
      AddPathArc(X2, Y2, X3, Y3, Radius)
      AddPathLine(X3, Y3)
      
      VectorSourceColor(Color)
      
      If Line\State And Line\Width > 0
        CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
      Else
        StrokePath(Stroke)
      EndIf  
    
    Else
      ret = #VectorDrawingNotStarted
      _Exception("LinesArc_",ret)
    EndIf 
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure TangentsArc_(X1.d, Y1.d, X2.d, Y2.d, X3.i, Y3.d, X4.d, Y4.d, Color.l, Flags.i=#False)
  ; ======================================================================
  ; NAME: TangentsArc_
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
  ; RET : -
  ; ======================================================================
    Protected Angle.d
    Protected isP.TPoint ; Intersection Point
    Protected ret
    
    If VStart  ; if Vector drawing is started
      
      X1 = mac_ScaleX(X1)
      Y1 = mac_ScaleY(Y1)
      X2 = mac_ScaleX(X2)
      Y2 = mac_ScaleY(Y2)
      X3 = mac_ScaleX(X3)
      Y3 = mac_ScaleY(Y3)
      X4 = mac_ScaleX(X4)
      Y4 = mac_ScaleY(Y4)
       
      mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      Angle = FindArcFromTangents(X1, Y1, X2, Y2, X3, Y3, X4, Y4, @isP)
      
      MovePathCursor(X1, Y1)
      AddPathLine(X2, Y2)
      AddPathArc(isP\X, isP\Y, X3, Y3, Angle)
      AddPathLine(X4, Y4)
  
      VectorSourceColor(Color)
      
      If Line\State And Line\Width > 0
        CustomDashPath(Line\Width, Line\Pattern(), Line\Flags, Line\Offset)
      Else
        StrokePath(Stroke)
      EndIf  
      
    Else
      ret = #VectorDrawingNotStarted
      _Exception("TangentsArc_",ret)
    EndIf 
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure Font_(FontID.i, Size.d=#PB_Default, Flags.i=#False)
  ; ======================================================================
  ; NAME: Font_
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

  Procedure Text_(X.d, Y.d, Text$, Color.l, Rotate.d=0, Flags.i=#False)
  ; ======================================================================
  ; NAME: Text_
  ; DESC: Draws a Text at X, Y
  ; VAR(X): X-Coordinate
  ; VAR(Y): Y-Coordinate
  ; VAR(Text$): The Text String
  ; VAR(Flags): FLAGs   
  ; RET : -
  ; ======================================================================
    
    Protected ret
    
    If VStart

      X = mac_ScaleX(X)
      Y = mac_ScaleY(Y)
       
      mac_AddAlphaIfNull(Color) ; set Alpha Channel to 255 if it is 0
      
      If Rotate <> 0 : RotateCoordinates(X, Y, Rotate) : EndIf
      
      MovePathCursor(X, Y)
      VectorSourceColor(Color)
      DrawVectorText(Text$)
  
      If Rotate <> 0 : RotateCoordinates(X, Y, -Rotate) : EndIf
    Else
      ret = #VectorDrawingNotStarted
      _Exception("Text_",ret)     
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure.d TextWidth_(Text.s, Flags.i=#PB_VectorText_Default)
    ; ======================================================================
    ; NAME: TextWidth_
    ; DESC: Calculates the Text Width
    ; VAR(X): 
    ; RET : TextWidth
    ; ======================================================================
   
    Protected ret.d
    
    If VStart
      ret= VectorTextWidth(Text, Flags)
    Else
      ret= 0
      _Exception("TextWidth_", #VectorDrawingNotStarted)
    EndIf
    
    ProcedureReturn ret
 EndProcedure
  
  Procedure.d TextHeight_(Text.s, Flags.i=#PB_VectorText_Default)
  ; ======================================================================
  ; NAME: TextHeight_
  ; DESC: Calculates the Text Height
  ; VAR(Text$): The Text String
  ; VAR(Flags): FLAGs   
  ; RET : Text width in units according to the setting Pixel, mm ...
  ; ======================================================================
    Protected ret.d
    
    If VStart
      ret= VectorTextHeight(Text, Flags)  
    Else
      ret= 0
      _Exception("TextHeight", #VectorDrawingNotStarted)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure SetDotPattern(LineWidth.d, Array Pattern.d(1), Flags.i=#False, StartOffset.d=0)
  ; ======================================================================
  ; NAME: SetDotPattern
  ; DESC: Sets the DotPattern
  ; VAR(LineWidth): LineWidth (thickness)
  ; VAR(Array Patternd(1): The pattern definition (dash and dot length)    
  ; VAR(Flags): FLAGs   
  ; VAR(StartOffset): Sart Offset        
  ; RET : .
  ; ======================================================================
    
    Line\Width = mac_ScaleX(LineWidth)
     
    CopyArray(Pattern(), Line\Pattern())
    
    Line\Flags     = Flags
    Line\Offset    = StartOffset
    
    If LineWidth
      Line\State = #True
    Else
      Line\State = #False
    EndIf
    
  EndProcedure
  
  Procedure DisableDotPattern(NewState.i=#True)
  ; ======================================================================
  ; NAME: DisableDotPattern
  ; DESC: Disable/Enable DotPattern
  ; VAR(NewState): #FALSE=Disabled, #TRUE=Enabled
  ; RET : -
  ; ======================================================================
   
    If NewState
      Line\State = #False
    Else  
      Line\State = #True
    EndIf
    
  EndProcedure  

  Procedure SetStroke_(LineWidth.d=1)
  ; ======================================================================
  ; NAME: SetStroke_
  ; DESC: Sets the Stroke, LineWidth (thikness)
  ; VAR(LineWidth): Line width (thickness)
  ; RET : .
  ; ======================================================================
    Stroke = LineWidth
  EndProcedure
  
  Procedure.i StartVector_(PB_No.i, OutPutType.i=#FLAG_Canvas, Unit.i=#PB_Unit_Pixel, Zoom.d=1.0, DPIscaling=#False) 
  ; ======================================================================
  ; NAME: StartVector_
  ; DESC: Start Vector Drawing
  ; VAR(PB_No): PureBasic Number; #Gadget, #Image. #Window
  ; VAR(OutPutType): #FLAG_Canvas, #FLAG_Image, #FLAG_Window, #FLAG_Printer
  ; VAR(Unit): #PB_Unit_Pixel, #PB_Unit_Millimeter, #PB_Unit_Inch, #PB_Unit_Point
  ; VAR(Zoom.d): Zoom factor
  ; VAR(DPIscaling) : Desktop/OS DPI-Scaling #FALE=OFF, #TRUE=ON
  ; RET : 0=FAULT;  <>0 Drawing started
  ; ======================================================================
    Protected ret
    
    Stroke = 1
    
    memDpiScaling = DPIscaling 

    If memDPIscaling
      memScaleX = Zoom * mac_ScaleX(1)
      memScaleY = Zoom * mac_ScaleY(1)
    Else
      memScaleX = Zoom
      memScaleY = Zoom
    EndIf
  
  
    Select OutPutType
        
      Case #FLAG_Canvas
        ret = StartVectorDrawing(CanvasVectorOutput(PB_No, Unit))
        
      Case #FLAG_Image
        ret = StartVectorDrawing(ImageVectorOutput(PB_No, Unit))
        
      Case #FLAG_Window
        ret = StartVectorDrawing(WindowVectorOutput(PB_No, Unit))
        
      Case #FLAG_Printer
        ret = StartVectorDrawing(PrinterVectorOutput(Unit))
        
    EndSelect
    
    VStart = ret    ; Indication: VectorDrawing started #True=started
    
    If Vstart = #False
      _Exception("StartVector_",#VectorDrawingNotStarted)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure StopVector_() 
  ; ======================================================================
  ; NAME: StopVector_
  ; DESC: Stops the Vector Drawing 
  ; RET : -
  ; ======================================================================
    Stroke = 0
    StopVectorDrawing()
    Vstart = #False     ; clear the Start indication of VectorDrawing
  EndProcedure
   
EndModule

;- ========  Module - Example ========

EnableExplicit

CompilerIf #PB_Compiler_IsMainFile
  
  #FLAG_Window = 0
  #Gadget = 1
  #Font   = 2
  
  LoadFont(#Font, "Arial", 16, #PB_Font_Bold)
  
  Dim Pattern.d(3)
  
  Pattern(0) = 0
  Pattern(1) = 5
  Pattern(2) = 6
  Pattern(3) = 5
  
  If OpenWindow(#FLAG_Window, 0, 0, 200, 200, "VectorDrawing Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered)
    
    CanvasGadget(#Gadget, 10, 10, 180, 180)

    If VDraw::StartVector_(#Gadget, VDraw::#FLAG_Canvas)
      
      VDraw::Font_(FontID(#Font))
      
      VDraw::Box_(2, 2, 176, 176, $CD0000, $FACE87, $FFF8F0, 0) ; VDraw::#FLAG_Horizontal / VDraw::#FLAG_Diagonal
      VDraw::Text_(65, 65, "Text", $701919, #False)
      
      ;VDraw::SetDotPattern(2, Pattern())
      
      VDraw::CircleSector_(90, 90, 70, 40, 90, $800000, $00D7FF, $008CFF)
      VDraw::SetStroke_(2)
      VDraw::LineXY_(90, 90, 90 + 80 * Cos(Radian(150)), 90 + 80 * Sin(Radian(150)), $228B22)
      VDraw::Circle_(90, 90, 80, $800000, #PB_Default, #PB_Default)
      ;VDraw::Ellipse_(90, 90, 80, 60, $800000, $FACE87, $FFF8F0, 30)
      VDraw::SetStroke_(4)
      VDraw::EllipseArc_(90, 90, 70, 45, 160, 240, $CC3299)
      VDraw::SetStroke_(1)
      VDraw::CircleArc_(90, 90, 70, 250, 340, $008CFF)
      
      ;VDraw::DisableDotPattern(#True)
      
      VDraw::Line_(10, 90, 160, 1, $8515C7)
      
      VDraw::StopVector_()
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
    
  EndIf

  
CompilerEndIf  

DisableExplicit
; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 1209
; FirstLine = 1075
; Folding = 7------
; EnableXP
; DPIAware
