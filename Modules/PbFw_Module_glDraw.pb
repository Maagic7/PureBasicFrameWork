; ===========================================================================
;  FILE : PbFw_Module_VDraw.pb
;  NAME : Module OpenGl Drawing [glDraw::]
;  DESC : Implements Drawing Commands with the Open GL Library.
;  DESC : Module glDraw is Call compatible with VDraw, so it is possible
;  DESC : To switch from Vector Drawing directly to OpenGL drawing
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/02/28
; VERSION  :  0.11 untested Developer Version
; COMPILER :  PureBasic 6.0 or higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ VDraw:: vs. glDraw::
;}
;{ TODO:
;}
; ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"
XIncludeFile "PbFw_Module_PX.pb"
XIncludeFile "PbFw_Module_Debug.pb"
XIncludeFile "PbFw_Module_OpenGL.pb"

DeclareModule glDraw
  EnableExplicit

  #glDraw_FLAG_Text_Default = 0

  EnumerationBinary EglDrawFlags
    #glDraw_FLAG_Text_Visible = 1
    #glDraw_FLAG_Text_Offset
    #glDraw_FLAG_Text_Baseline
    #glDraw_FLAG_Vertical
    #glDraw_FLAG_Horizontal
    #glDraw_FLAG_Diagonal
  EndEnumeration

  #glDraw_RoundEnd = 0
  #glDraw_SquareEnd = 1
  #glDraw_RoundCorner = 2
  #glDraw_FLAG_DiagonalCorner = 3

  Declare.i gl_StartDraw(PBNo.i, Unit.i = #PB_Unit_Pixel, Zoom.d = 1.0, DPIscaling = #False)
  Declare.i gl_StopDraw()

  Declare.i gl_Box(X.d, Y.d, Width.d, Height.d, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Rotate.d = 0, Flags.i = #False)
  Declare.i gl_Circle(X.d, Y.d, Radius.d, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Flags.i = #False)
  Declare.i gl_CircleArc(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, Flags.i = #False)
  Declare.i gl_CircleSector(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Flags.i = #False)

  Declare.i gl_Ellipse(X.d, Y.d, RadiusX.d, RadiusY.d, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Rotate.d = 0, Flags.i = #False)
  Declare.i gl_EllipseArc(X.d, Y.d, RadiusX.d, RadiusY.d, startAngle.d, endAngle.d, Color.l, Flags.i = #False)

  Declare.i gl_Line(X.d, Y.d, Width.d, Height.d, Color.l, Flags.i = #False)
  Declare.i gl_LinesArc(X1.d, Y1.d, X2.d, Y2.d, X3.d, Y3.d, Radius.d, Color.l, Flags.i = #False)
  Declare.i gl_LineH(X.d, Y.d, Width.d, Color.l, Flags.i = #False)
  Declare.i gl_LineV(X.d, Y.d, Height.d, Color.l, Flags.i = #False)
  Declare.i gl_LineXY(X1.d, Y1.d, X2.d, Y2.d, Color.l, Flags.i = #False)
  Declare.i gl_SetFont(FontID.i, Size.d = #PB_Default, Flags.i = #False)

  Declare.i gl_TangentsArc(X1.d, Y1.d, X2.d, Y2.d, X3.i, Y3.d, X4.d, Y4.d, Color.l, Flags.i = #False)
  Declare.i gl_Text(X.d, Y.d, Text$, Color.l, Angle.d = 0, Flags.i = #False)
  Declare.d gl_GetTextWidth(Text.s, Flags.i = #glDraw_FLAG_Text_Default)
  Declare.d gl_GetTextHeight(Text.s, Flags.i = #glDraw_FLAG_Text_Default)

  Declare.i gl_SetDotPattern(LineWidth.d, Array Pattern.d(1), Flags.i = #False, StartOffset.d = 0)
  Declare.i gl_DisableDotPattern(State.i = #True)
  Declare.i gl_SetStroke(LineWidth.d = 1)

EndDeclareModule

Module glDraw
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)

  Structure _TThis
    GadgetID.i
    Width.i
    Height.i
    Stroke.d
    CurrentFontID.i
    CurrentFontSize.d
  EndStructure

  Global This._TThis

  Procedure _gl_SetColor(PBColor.l)
    PX::SetAlphaIfNull(PBColor)
    GL::GL_SetColor(Red(PBColor) / 255.0, Green(PBColor) / 255.0, Blue(PBColor) / 255.0, Alpha(PBColor) / 255.0)
  EndProcedure

  Procedure.i gl_StartDraw(PBNo.i, Unit.i = #PB_Unit_Pixel, Zoom.d = 1.0, DPIscaling = #False)


    This\GadgetID = PBNo
    This\Width = GadgetWidth(PBNo)
    This\Height = GadgetHeight(PBNo)
    This\Stroke = 1.0
    This\CurrentFontID = -1
    This\CurrentFontSize = 10

    SetGadgetAttribute(This\GadgetID, #PB_OpenGL_SetContext, #True)

    glViewport_(0, 0, This\Width, This\Height)
    GL::GL_SetOrthographic(0, This\Width, This\Height, 0, -1, 1)

    GL::GL_EnableBlend()

    GL::GL_Clear(1, 1, 1, 1) ; Default to white background

    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_StopDraw()
    If This\GadgetID
      GL::GL_SwapBuffers(This\GadgetID)
      SetGadgetAttribute(This\GadgetID, #PB_OpenGL_SetContext, #False)
      This\GadgetID = 0
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i gl_SetStroke(LineWidth.d = 1)
    This\Stroke = LineWidth
    glLineWidth_(LineWidth)
    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_Box(X.d, Y.d, Width.d, Height.d, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Rotate.d = 0, Flags.i = #False)
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    GL::GL_PushMatrix()
    If Rotate <> 0
      GL::GL_Translate(X + Width / 2, Y + Height / 2, 0)
      GL::GL_Rotate(Rotate, 0, 0, 1)
      GL::GL_Translate(-(X + Width / 2), -(Y + Height / 2), 0)
    EndIf

    If FillColor <> #PB_Default
      glBegin_(#GL_QUADS)
      If GradientColor <> #PB_Default
        _gl_SetColor(FillColor)
        glVertex2d_(X, Y)
        glVertex2d_(X + Width, Y)
        _gl_SetColor(GradientColor)
        glVertex2d_(X + Width, Y + Height)
        glVertex2d_(X, Y + Height)
      Else
        _gl_SetColor(FillColor)
        glVertex2d_(X, Y)
        glVertex2d_(X + Width, Y)
        glVertex2d_(X + Width, Y + Height)
        glVertex2d_(X, Y + Height)
      EndIf
      glEnd_()
    EndIf

    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_LOOP)
      glVertex2d_(X, Y)
      glVertex2d_(X + Width, Y)
      glVertex2d_(X + Width, Y + Height)
      glVertex2d_(X, Y + Height)
      glEnd_()
    EndIf

    GL::GL_PopMatrix()
    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_LineXY(X1.d, Y1.d, X2.d, Y2.d, Color.l, Flags.i = #False)
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf
    _gl_SetColor(Color)
    GL::GL_DrawLine(X1, Y1, 0, X2, Y2, 0)
    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_Circle(X.d, Y.d, Radius.d, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Flags.i = #False)
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf
    Protected i, segments = 72 ; More segments for smoother circle
    Protected angle.d, dx.d, dy.d

    If FillColor <> #PB_Default
      glBegin_(#GL_TRIANGLE_FAN)
      If GradientColor <> #PB_Default
        _gl_SetColor(GradientColor)
      Else
        _gl_SetColor(FillColor)
      EndIf
      glVertex2d_(X, Y) ; Center point
      _gl_SetColor(FillColor)
      For i = 0 To segments
        angle = i * 2 * #PI / segments
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2d_(dx, dy)
      Next
      glEnd_()
    EndIf

    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_LOOP)
      For i = 0 To segments
        angle = i * 2 * #PI / segments
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2d_(dx, dy)
      Next
      glEnd_()
    EndIf

    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_SetFont(FontID.i, Size.d = #PB_Default, Flags.i = #False)
    This\CurrentFontID = FontID
    If Size <> #PB_Default
      This\CurrentFontSize = Size
    EndIf
    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_Text(X.d, Y.d, Text$, Color.l, Angle.d = 0, Flags.i = #False)
    ; NOTE: This is a complex task in raw OpenGL.
    ; This implementation renders text to a temporary image and displays it as a texture.
    If This\GadgetID = 0 Or This\CurrentFontID = -1 Or Not IsFont(This\CurrentFontID) : ProcedureReturn #False : EndIf

    Protected TxtImg = CreateImage(#PB_Any, 1, 1, 32, RGBA(0, 0, 0, 0))
    Protected TxtW, TxtH

    If StartDrawing(ImageOutput(TxtImg))
      DrawingFont(This\CurrentFontID)
      TxtW = TextWidth(Text$)
      TxtH = TextHeight(Text$)
      StopDrawing()
    EndIf

    FreeImage(TxtImg)

    If TxtW > 0 And TxtH > 0
      TxtImg = CreateImage(#PB_Any, TxtW, TxtH, 32, RGBA(0, 0, 0, 0))

      StartDrawing(ImageOutput(TxtImg))
      DrawingFont(This\CurrentFontID)
      PX::SetAlphaIfNull(Color)
      DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
      DrawText(0, 0, Text$, Color)

      Protected TextureID.i
      glGenTextures_(1, @TextureID)
      glBindTexture_(#GL_TEXTURE_2D, TextureID)
      glTexImage2D_(#GL_TEXTURE_2D, 0, #GL_RGBA, TxtW, TxtH, 0, #GL_BGRA_EXT, #GL_UNSIGNED_BYTE, DrawingBuffer())
      glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
      glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)

      StopDrawing()

      glEnable_(#GL_TEXTURE_2D)
      glColor4f_(1, 1, 1, 1) ; Use white color to not tint the texture

      GL::GL_PushMatrix()
      GL::GL_Translate(X, Y, 0)
      GL::GL_Rotate(Angle, 0, 0, 1)

      glBegin_(#GL_QUADS)
      glTexCoord2f_(0, 0) : glVertex2f_(0, 0)
      glTexCoord2f_(1, 0) : glVertex2f_(TxtW, 0)
      glTexCoord2f_(1, 1) : glVertex2f_(TxtW, TxtH)
      glTexCoord2f_(0, 1) : glVertex2f_(0, TxtH)
      glEnd_()

      GL::GL_PopMatrix()

      glDisable_(#GL_TEXTURE_2D)
      glDeleteTextures_(1, @TextureID)
      FreeImage(TxtImg)

      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  ; --- Stubs for remaining functions ---

  Procedure.i gl_CircleArc(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, Flags.i = #False)
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    Protected i, segments
    Protected angle.d, dx.d, dy.d, stepAngle.d
    Protected currentAngle.d

    ; Calculate segments: ~5 degrees per segment, minimum 8
    Protected diff.d = endAngle - startAngle
    segments = Abs(diff) / 5
    If segments < 8 : segments = 8 : EndIf

    stepAngle = diff / segments

    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_STRIP)
      For i = 0 To segments
        currentAngle = startAngle + (i * stepAngle)
        angle = Radian(currentAngle)
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2d_(dx, dy)
      Next
      glEnd_()
    EndIf

    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_CircleSector(X.d, Y.d, Radius.d, startAngle.d, endAngle.d, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Flags.i = #False)
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    Protected i, segments
    Protected angle.d, dx.d, dy.d, stepAngle.d, currentAngle.d

    Protected diff.d = endAngle - startAngle
    segments = Abs(diff) / 5
    If segments < 8 : segments = 8 : EndIf
    stepAngle = diff / segments

    If FillColor <> #PB_Default
      glBegin_(#GL_TRIANGLE_FAN)
      If GradientColor <> #PB_Default
        _gl_SetColor(GradientColor) ; Center Color
        glVertex2d_(X, Y)
        _gl_SetColor(FillColor) ; Outer Color
      Else
        _gl_SetColor(FillColor)
        glVertex2d_(X, Y)
      EndIf

      For i = 0 To segments
        currentAngle = startAngle + (i * stepAngle)
        angle = Radian(currentAngle)
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2d_(dx, dy)
      Next
      glEnd_()
    EndIf

    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_LOOP)
      glVertex2d_(X, Y) ; Center
      For i = 0 To segments
        currentAngle = startAngle + (i * stepAngle)
        angle = Radian(currentAngle)
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2d_(dx, dy)
      Next
      glEnd_()
    EndIf

    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_Ellipse(X.d, Y.d, RadiusX.d, RadiusY.d, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Rotate.d = 0, Flags.i = #False)
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    Protected i, segments = 72
    Protected angle.d, dx.d, dy.d

    GL::GL_PushMatrix()
    GL::GL_Translate(X, Y, 0)
    GL::GL_Rotate(Rotate, 0, 0, 1)
    GL::GL_Translate(-X, -Y, 0)

    If FillColor <> #PB_Default
      glBegin_(#GL_TRIANGLE_FAN)
      If GradientColor <> #PB_Default
        _gl_SetColor(GradientColor) ; Center
        glVertex2d_(X, Y)
        _gl_SetColor(FillColor) ; Edge
      Else
        _gl_SetColor(FillColor)
        glVertex2d_(X, Y)
      EndIf

      For i = 0 To segments
        angle = i * 2 * #PI / segments
        dx = X + Cos(angle) * RadiusX
        dy = Y + Sin(angle) * RadiusY
        glVertex2d_(dx, dy)
      Next
      glEnd_()
    EndIf

    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_LOOP)
      For i = 0 To segments
        angle = i * 2 * #PI / segments
        dx = X + Cos(angle) * RadiusX
        dy = Y + Sin(angle) * RadiusY
        glVertex2d_(dx, dy)
      Next
      glEnd_()
    EndIf

    GL::GL_PopMatrix()
    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_EllipseArc(X.d, Y.d, RadiusX.d, RadiusY.d, startAngle.d, endAngle.d, Color.l, Flags.i = #False)
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    Protected i, segments
    Protected angle.d, dx.d, dy.d, stepAngle.d, currentAngle.d

    Protected diff.d = endAngle - startAngle
    segments = Abs(diff) / 5
    If segments < 8 : segments = 8 : EndIf
    stepAngle = diff / segments

    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_STRIP)
      For i = 0 To segments
        currentAngle = startAngle + (i * stepAngle)
        angle = Radian(currentAngle)
        dx = X + Cos(angle) * RadiusX
        dy = Y + Sin(angle) * RadiusY
        glVertex2d_(dx, dy)
      Next
      glEnd_()
    EndIf

    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_Line(X.d, Y.d, Width.d, Height.d, Color.l, Flags.i = #False) : ProcedureReturn gl_LineXY(X, Y, X + Width, Y + Height, Color, Flags) : EndProcedure
  Procedure.i gl_LinesArc(X1.d, Y1.d, X2.d, Y2.d, X3.d, Y3.d, Radius.d, Color.l, Flags.i = #False) : ProcedureReturn #False : EndProcedure
  Procedure.i gl_LineH(X.d, Y.d, Width.d, Color.l, Flags.i = #False) : ProcedureReturn gl_LineXY(X, Y, X + Width, Y, Color, Flags) : EndProcedure
  Procedure.i gl_LineV(X.d, Y.d, Height.d, Color.l, Flags.i = #False) : ProcedureReturn gl_LineXY(X, Y, X, Y + Height, Color, Flags) : EndProcedure
  Procedure.i gl_TangentsArc(X1.d, Y1.d, X2.d, Y2.d, X3.i, Y3.d, X4.d, Y4.d, Color.l, Flags.i = #False) : ProcedureReturn #False : EndProcedure

  Procedure.d gl_GetTextWidth(Text.s, Flags.i = #glDraw_FLAG_Text_Default)
    If This\CurrentFontID <> -1 And IsFont(This\CurrentFontID)
      If StartDrawing(ImageOutput(#PB_Any))
        DrawingFont(This\CurrentFontID)
        Protected width = TextWidth(Text.s)
        StopDrawing()
        ProcedureReturn width
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.d gl_GetTextHeight(Text.s, Flags.i = #glDraw_FLAG_Text_Default)
    If This\CurrentFontID <> -1 And IsFont(This\CurrentFontID)
      If StartDrawing(ImageOutput(#PB_Any))
        DrawingFont(This\CurrentFontID)
        Protected height = TextHeight(Text.s)
        StopDrawing()
        ProcedureReturn height
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.i gl_SetDotPattern(LineWidth.d, Array Pattern.d(1), Flags.i = #False, StartOffset.d = 0) : ProcedureReturn #False : EndProcedure
  Procedure.i gl_DisableDotPattern(State.i = #True) : ProcedureReturn #False : EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
  ;- ----------------------------------------------------------------------
  ;-  M O D U L E   T E S T   C O D E
  ;-  ----------------------------------------------------------------------

  XIncludeFile "PbFw_Module_VDraw.pb"

  EnableExplicit

  #glDraw_FLAG_Window = 0
  #Gadget_OpenGL = 1
  #Gadget_Canvas = 2

  #Font = 2

  LoadFont(#Font, "Arial", 16, #PB_Font_Bold)

  Dim Pattern.d(3)

  Pattern(0) = 0
  Pattern(1) = 5
  Pattern(2) = 6
  Pattern(3) = 5

  If OpenWindow(#glDraw_FLAG_Window, 0, 0, 400, 400, "OpenGL Drawing Example", #PB_Window_SystemMenu | #PB_Window_Tool | #PB_Window_ScreenCentered)

    CanvasGadget(#Gadget_Canvas, 210, 10, 180, 180)
    OpenGLGadget(#Gadget_OpenGL, 10, 10, 180, 180)

    If glDraw::gl_StartDraw(#Gadget_OpenGL)

      glDraw::gl_SetFont(FontID(#Font))

      glDraw::gl_Box(2, 2, 176, 176, $CD0000, $FACE87, $FFF8F0, 0) ; glDraw::#FLAG_Horizontal / glDraw::#FLAG_Diagonal
      glDraw::gl_Text(65, 65, "Text", $701919, 0, #False)

      ;glDraw::gl_SetDotPattern(2, Pattern())

      glDraw::gl_CircleSector(90, 90, 70, 40, 90, $800000, $00D7FF, $008CFF)
      glDraw::gl_SetStroke(2)
      glDraw::gl_LineXY(90, 90, 90 + 80 * Cos(Radian(150)), 90 + 80 * Sin(Radian(150)), $228B22)
      glDraw::gl_Circle(90, 90, 80, $800000, #PB_Default, #PB_Default)
      ;glDraw::gl_Ellipse(90, 90, 80, 60, $800000, $FACE87, $FFF8F0, 30)
      glDraw::gl_SetStroke(4)
      glDraw::gl_EllipseArc(90, 90, 70, 45, 160, 240, $CC3299)
      glDraw::gl_SetStroke(1)
      glDraw::gl_CircleArc(90, 90, 70, 250, 340, $008CFF)

      ;glDraw::gl_DisableDotPattern(#True)

      glDraw::gl_Line(10, 90, 160, 1, $8515C7)

      glDraw::gl_Stopdraw()
    EndIf


    If VDraw::V_StartDraw(#Gadget_Canvas, VDraw::#VDraw_FLAG_Canvas)

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

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 118
; FirstLine = 220
; Folding = -----
; CPU = 5