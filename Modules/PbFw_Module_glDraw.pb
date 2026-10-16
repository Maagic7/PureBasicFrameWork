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
; VERSION  :  0.5 untested Developer Version
; COMPILER :  PureBasic 6.0 or higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ VDraw:: vs. glDraw::
;  20206/10/10 S.Maag : removed biggest bugs with AI help, so we get a output!
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

  Declare.i gl_StartDraw(PBNo.i, Unit.i = #PB_Unit_Pixel, Zoom.f = 1.0, DPIscaling = #False)
  Declare.i gl_StopDraw()

  Declare.i gl_Box(X.f, Y.f, Width.f, Height.f, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Rotate.f = 0, Flags.i = #False)
  Declare.i gl_Circle(X.f, Y.f, Radius.f, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Flags.i = #False)
  Declare.i gl_CircleArc(X.f, Y.f, Radius.f, startAngle.f, endAngle.f, Color.l, Flags.i = #False)
  Declare.i gl_CircleSector(X.f, Y.f, Radius.f, startAngle.f, endAngle.f, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Flags.i = #False)

  Declare.i gl_Ellipse(X.f, Y.f, RadiusX.f, RadiusY.f, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Rotate.f = 0, Flags.i = #False)
  Declare.i gl_EllipseArc(X.f, Y.f, RadiusX.f, RadiusY.f, startAngle.f, endAngle.f, Color.l, Flags.i = #False)

  Declare.i gl_Line(X.f, Y.f, Width.f, Height.f, Color.l, Flags.i = #False)
  Declare.i gl_LinesArc(X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f, Radius.f, Color.l, Flags.i = #False)
  Declare.i gl_LineH(X.f, Y.f, Width.f, Color.l, Flags.i = #False)
  Declare.i gl_LineV(X.f, Y.f, Height.f, Color.l, Flags.i = #False)
  Declare.i gl_LineXY(X1.f, Y1.f, X2.f, Y2.f, Color.l, Flags.i = #False)
  Declare.i gl_SetFont(FontID.i, Size.f = #PB_Default, Flags.i = #False)

  Declare.i gl_TangentsArc(X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f, X4.f, Y4.f, Color.l, Flags.i = #False) 
  Declare.i gl_Text(X.f, Y.f, Text$, Color.l, Angle.f = 0, Flags.i = #False)
  Declare.f gl_GetTextWidth(Text.s, Flags.i = #glDraw_FLAG_Text_Default)
  Declare.f gl_GetTextHeight(Text.s, Flags.i = #glDraw_FLAG_Text_Default)

  Declare.i gl_SetDotPattern(LineWidth.f, Array Pattern.f(1), Flags.i = #False, StartOffset.f = 0)
  Declare.i gl_DisableDotPattern(State.i = #True)
  Declare.i gl_SetStroke(LineWidth.f = 1)

EndDeclareModule

Module glDraw
  EnableExplicit
  ;PbFw::ListModule(#PB_Compiler_Module)

  Structure _TThis
    GadgetID.i
    Width.i
    Height.i
    Stroke.f
    CurrentFontID.i
    CurrentFontSize.f
  EndStructure

  Global This._TThis

  Procedure _gl_SetColor(PBColor.l)
    PX::SetAlphaIfNull(PBColor)
    GL::GL_SetColor(Red(PBColor) / 255.0, Green(PBColor) / 255.0, Blue(PBColor) / 255.0, Alpha(PBColor) / 255.0)
  EndProcedure

  Procedure.i gl_StartDraw(glGadgetNo.i, Unit.i = #PB_Unit_Pixel, Zoom.f = 1.0, DPIscaling = #False)


    This\GadgetID = glGadgetNo
    This\Width = GadgetWidth(glGadgetNo)
    This\Height = GadgetHeight(glGadgetNo)
    This\Stroke = 1.0
    This\CurrentFontID = FontID(LoadFont(#PB_Any, "Arial",10))

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

  Procedure.i gl_SetStroke(LineWidth.f = 1)
  ; ======================================================================
  ; NAME: gl_SetStroke
  ; DESC: Set the global stroke thickness (line width) for shapes and vectors
  ; VAR(LineWidth.f): Line width in pixels (Single-Float)
  ; RET : #TRUE on success#, #FALSE=Invalid width (<= 0)
  ; ======================================================================   This\Stroke = LineWidth
    
    If LineWidth <= 0.0
      ProcedureReturn #False
    EndIf
  
    glLineWidth_(LineWidth)
    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_Box(X.f, Y.f, Width.f, Height.f, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Rotate.f = 0, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_Box
  ; DESC: Draw a hardware-accelerated rectangle with optional fill, gradients, and rotation
  ; VAR(X.f): X-Coordinate of the top-left starting position
  ; VAR(Y.f): Y-Coordinate of the top-left starting position
  ; VAR(Width.f): Width of the rectangle
  ; VAR(Height.f): Height of the rectangle
  ; VAR(Color.l): 32-Bit RGBA value for the border/outline color
  ; VAR(FillColor.l): 32-Bit RGBA value for the background fill (#PB_Default = No fill / Outline only)
  ; VAR(GradientColor.l): 32-Bit RGBA value to create a linear gradient effect (#PB_Default = Solid color)
  ; VAR(Rotate.f): Rotation angle in degrees around the shape's origin
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Drawing failed; #TRUE=Success
  ; ======================================================================    
    
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

  Procedure.i gl_LineXY(X1.f, Y1.f, X2.f, Y2.f, Color.l, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_LineXY
  ; DESC: Draw a single hardware-accelerated straight line from start to end coordinates
  ; VAR(X1.f): X-Coordinate of the starting point
  ; VAR(Y1.f): Y-Coordinate of the starting point
  ; VAR(X2.f): X-Coordinate of the ending point
  ; VAR(Y2.f): Y-Coordinate of the ending point
  ; VAR(Color.l): 32-Bit RGBA value for the line color
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Context active fault / Drawing failed; #TRUE=Success
  ; ======================================================================    If This\GadgetID = 0 : ProcedureReturn #False : EndIf
    _gl_SetColor(Color)
    GL::GL_DrawLine(X1, Y1, 0, X2, Y2, 0)
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i gl_Circle(X.f, Y.f, Radius.f, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_Circle
  ; DESC: Draw a hardware-accelerated circle with optional fill, radial gradient, and outline
  ; VAR(X.f): X-Coordinate of the circle's center point
  ; VAR(Y.f): Y-Coordinate of the circle's center point
  ; VAR(Radius.f): Radius of the circle
  ; VAR(Color.l): 32-Bit RGBA value for the border/outline color (#PB_Default = No outline)
  ; VAR(FillColor.l): 32-Bit RGBA value for the background fill (#PB_Default = No fill)
  ; VAR(GradientColor.l): 32-Bit RGBA value for a radial center gradient (#PB_Default = Solid fill)
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Context active fault / Drawing failed; #TRUE=Success
  ; ======================================================================
    Protected i.i, segments.i = 72 ; More segments for smoother circle
    Protected angle.f, dx.f, dy.f
    
    If This\GadgetID = 0 
      ProcedureReturn #False 
    EndIf

    ; Fill circle
    If FillColor <> #PB_Default
      glBegin_(#GL_TRIANGLE_FAN)
      
      ; middle point color for the gradient
      If GradientColor <> #PB_Default
        _gl_SetColor(GradientColor)
      Else
        _gl_SetColor(FillColor)
      EndIf
      
      glVertex2f_(X, Y)
      
      ; Color for the Circle line
      _gl_SetColor(FillColor)
      For i = 0 To segments
        angle = i * (2.0 * #PI) / segments
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2f_(dx, dy)
      Next
      glEnd_()
    EndIf

    ; Draw Circle line
    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_LOOP)
      For i = 0 To segments
        angle = i * (2.0 * #PI) / segments
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2f_(dx, dy) 
      Next
      glEnd_()
    EndIf

    ProcedureReturn #True
  EndProcedure

 Procedure.i gl_SetFont(FontID.i, Size.f = #PB_Default, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_SetFont
  ; DESC: Assign the active drawing font asset and vertical scale size within the module context
  ; VAR(FontID.i): The initialized PureBasic font object identifier number
  ; VAR(Size.f): Font character height scale size metric (#PB_Default = Retain current size state)
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : Always returns #TRUE once tracking parameters are assigned
  ; ======================================================================
   
   This\CurrentFontID = FontID
    If Size <> #PB_Default
      This\CurrentFontSize = Size
    EndIf
    ProcedureReturn #True
  EndProcedure    
  
  Procedure.i gl_Text(X.f, Y.f, Text$, Color.l, Angle.f = 0, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_Text
  ; DESC: Draw a hardware-accelerated text string by converting a 2D font image into an OpenGL texture map
  ; VAR(X.f): X-Coordinate where the top-left corner of the text will be placed
  ; VAR(Y.f): Y-Coordinate where the top-left corner of the text will be placed
  ; VAR(Text$): String text sequence content to render
  ; VAR(Color.l): 32-Bit RGBA value for the character text font color
  ; VAR(Angle.f): Rotation angle in degrees applied around the text's top-left starting location
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Context active fault / Drawing failed; #TRUE=Success
  ; ======================================================================
    
    If This\GadgetID = 0 Or This\CurrentFontID = -1 ; Or Not IsFont(This\CurrentFontID) 
      Debug "gl_Text : " + "first exit! FontID="+This\CurrentFontID 
      ProcedureReturn #False
    EndIf

    Protected TxtImg.i, TxtW.i, TxtH.i
    Protected TextureID.i, *Buffer

    ; Step 1: Measure text boundary footprint
    TxtImg = CreateImage(#PB_Any, 1, 1, 32, RGBA(0, 0, 0, 0))
    If TxtImg
      If StartDrawing(ImageOutput(TxtImg))
        DrawingFont(This\CurrentFontID)
        TxtW = TextWidth(Text$)
        TxtH = TextHeight(Text$)
        StopDrawing()
      EndIf
      FreeImage(TxtImg)
    EndIf

    ; Proceed only if text contains valid geometry dimensions
    If TxtW > 0 And TxtH > 0
      TxtImg = CreateImage(#PB_Any, TxtW, TxtH, 32, RGBA(0, 0, 0, 0))
      If Not TxtImg : ProcedureReturn #False : EndIf

      ; Step 2: Render crisp vector font characters onto image buffer
      If StartDrawing(ImageOutput(TxtImg))
        DrawingFont(This\CurrentFontID)
        PX::SetAlphaIfNull(Color)
        DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
        DrawText(0, 0, Text$, Color)
        
        ; Allocate clean buffer memory to safely copy raw image bytes out of 2D Drawing lock
        *Buffer = AllocateMemory(TxtW * TxtH * 4)
        If *Buffer
          CopyMemory(DrawingBuffer(), *Buffer, TxtW * TxtH * 4)
        EndIf
        StopDrawing() ; SAFELY RELEASE PUREBASIC DRAWING BEFORE TOUCHING OPENGL CONTROLS
      EndIf

      ; Abort safely if memory bounds allocation failed
      If Not *Buffer
        FreeImage(TxtImg)
        ProcedureReturn #False
      EndIf

      ; Step 3: Hardware pipeline integration (Bind raw pixel buffer to dynamic hardware texture)
      glGenTextures_(1, @TextureID)
      glBindTexture_(#GL_TEXTURE_2D, TextureID)
      
      ; Configure strict edge clamping to avoid visual pixel-bleeding artifacts
      glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE)
      glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE)
      glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
      glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
      
      ; Upload layout using standard 32-Bit BGRA alignment
      glTexImage2D_(#GL_TEXTURE_2D, 0, #GL_RGBA, TxtW, TxtH, 0, #GL_BGRA_EXT, #GL_UNSIGNED_BYTE, *Buffer)
      FreeMemory(*Buffer) ; Clear heap footprint immediately since VRAM now holds data

      ; Step 4: Spatial canvas placement and geometric texturing
      glEnable_(#GL_TEXTURE_2D)
      glEnable_(#GL_BLEND) ; Ensure alpha blending layer is active for smooth antialiasing
      glBlendFunc_(#GL_SRC_ALPHA, #GL_ONE_MINUS_SRC_ALPHA)
      glColor4f_(1.0, 1.0, 1.0, 1.0) ; Set clean neutral tint multiplier matrix

      GL::GL_PushMatrix()
      GL::GL_Translate(X, Y, 0)
      GL::GL_Rotate(Angle, 0, 0, 1)

      ; Map texture to a surface quad. 
      ; The texture coordinates (Y-Axis) are inverted to flip the text right-side up.
      glBegin_(#GL_QUADS)
        glTexCoord2f_(0.0, 1.0) : glVertex2f_(0.0, 0.0)   ; Top-Left of quad maps to Bottom-Left of texture
        glTexCoord2f_(1.0, 1.0) : glVertex2f_(TxtW, 0.0)  ; Top-Right of quad maps to Bottom-Right of texture
        glTexCoord2f_(1.0, 0.0) : glVertex2f_(TxtW, TxtH) ; Bottom-Right of quad maps to Top-Right of texture
        glTexCoord2f_(0.0, 0.0) : glVertex2f_(0.0, TxtH)  ; Bottom-Left of quad maps to Top-Left of texture
      glEnd_()
      
      GL::GL_PopMatrix()

      ; Step 5: Resource house-cleaning routine
      glDisable_(#GL_TEXTURE_2D)
      glDeleteTextures_(1, @TextureID)
      FreeImage(TxtImg)

      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure.i gl_CircleArc(X.f, Y.f, Radius.f, startAngle.f, endAngle.f, Color.l, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_CircleArc
  ; DESC: Draw a hardware-accelerated open curved line segment (Circle Arc)
  ; VAR(X.f): X-Coordinate of the arc's center point
  ; VAR(Y.f): Y-Coordinate of the arc's center point
  ; VAR(Radius.f): Radius of the arc
  ; VAR(startAngle.f): Starting angle in degrees
  ; VAR(endAngle.f): Ending angle in degrees
  ; VAR(Color.l): 32-Bit RGBA value for the line color
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Context active fault / Drawing failed; #TRUE=Success
  ; ======================================================================
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    Protected i, segments
    Protected angle.f, dx.f, dy.f, stepAngle.f
    Protected currentAngle.f

    ; Calculate segments: ~5 degrees per segment, minimum 8
    Protected diff.f = endAngle - startAngle
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
        glVertex2f_(dx, dy) 
      Next
      glEnd_()
    EndIf

    ProcedureReturn #True
  EndProcedure
  
  Procedure.i gl_CircleSector(X.f, Y.f, Radius.f, startAngle.f, endAngle.f, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_CircleSector
  ; DESC: Draw a hardware-accelerated pie slice (Circle Sector) with optional fill, gradient, and outline
  ; VAR(X.f): X-Coordinate of the sector's center point
  ; VAR(Y.f): Y-Coordinate of the sector's center point
  ; VAR(Radius.f): Radius of the sector
  ; VAR(startAngle.f): Starting angle in degrees
  ; VAR(endAngle.f): Ending angle in degrees
  ; VAR(Color.l): 32-Bit RGBA value for the border/outline color (#PB_Default = No outline)
  ; VAR(FillColor.l): 32-Bit RGBA value for the background fill (#PB_Default = No fill)
  ; VAR(GradientColor.l): 32-Bit RGBA value for a radial center gradient (#PB_Default = Solid fill)
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Context active fault / Drawing failed; #TRUE=Success
  ; ======================================================================
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    Protected i, segments
    Protected angle.f, dx.f, dy.f, stepAngle.f, currentAngle.f

    Protected diff.f = endAngle - startAngle
    segments = Abs(diff) / 5
    If segments < 8 : segments = 8 : EndIf
    stepAngle = diff / segments

    ; Draw the filled pie surface
    If FillColor <> #PB_Default
      glBegin_(#GL_TRIANGLE_FAN)
      If GradientColor <> #PB_Default
        _gl_SetColor(GradientColor) ; Center color for radial gradient effect
        glVertex2f_(X, Y)           
        _gl_SetColor(FillColor)     ; Outer color boundary
      Else
        _gl_SetColor(FillColor)
        glVertex2f_(X, Y)         
      EndIf

      For i = 0 To segments
        currentAngle = startAngle + (i * stepAngle)
        angle = Radian(currentAngle)
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2f_(dx, dy)         
      Next
      glEnd_()
    EndIf

    ; Draw the solid perimeter outline
    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_LOOP)
      glVertex2f_(X, Y)          
      For i = 0 To segments
        currentAngle = startAngle + (i * stepAngle)
        angle = Radian(currentAngle)
        dx = X + Cos(angle) * Radius
        dy = Y + Sin(angle) * Radius
        glVertex2f_(dx, dy)         
      Next
      glEnd_()
    EndIf

    ProcedureReturn #True
  EndProcedure
  
  Procedure.i gl_Ellipse(X.f, Y.f, RadiusX.f, RadiusY.f, Color.l, FillColor.l = #PB_Default, GradientColor.l = #PB_Default, Rotate.f = 0, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_Ellipse
  ; DESC: Draw a hardware-accelerated ellipse with optional fill, center gradient, and custom rotation axis
  ; VAR(X.f): X-Coordinate of the ellipse's center point
  ; VAR(Y.f): Y-Coordinate of the ellipse's center point
  ; VAR(RadiusX.f): Horizontal radius (semi-major axis)
  ; VAR(RadiusY.f): Vertical radius (semi-minor axis)
  ; VAR(Color.l): 32-Bit RGBA value for the border/outline color (#PB_Default = No outline)
  ; VAR(FillColor.l): 32-Bit RGBA value for the background fill (#PB_Default = No fill)
  ; VAR(GradientColor.l): 32-Bit RGBA value for a radial center gradient (#PB_Default = Solid fill)
  ; VAR(Rotate.f): Rotation angle in degrees around the center point
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Context active fault / Drawing failed; #TRUE=Success
  ; ======================================================================
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    Protected i, segments = 72
    Protected angle.f, dx.f, dy.f

    ; Apply matrix transformation around the shape's center origin
    GL::GL_PushMatrix()
    GL::GL_Translate(X, Y, 0)
    GL::GL_Rotate(Rotate, 0, 0, 1)
    GL::GL_Translate(-X, -Y, 0)

    ; Pass 1: Draw the filled ellipse surface
    If FillColor <> #PB_Default
      glBegin_(#GL_TRIANGLE_FAN)
      If GradientColor <> #PB_Default
        _gl_SetColor(GradientColor) ; Center color for radial gradient effect
        glVertex2f_(X, Y)           ; CHANGED: Use glVertex2f_ for .f values
        _gl_SetColor(FillColor)     ; Edge color boundary
      Else
        _gl_SetColor(FillColor)
        glVertex2f_(X, Y)           ; CHANGED: Use glVertex2f_ for .f values
      EndIf

      For i = 0 To segments
        angle = i * (2.0 * #PI) / segments
        dx = X + Cos(angle) * RadiusX
        dy = Y + Sin(angle) * RadiusY
        glVertex2f_(dx, dy)         ; CHANGED: Use glVertex2f_ for .f values
      Next
      glEnd_()
    EndIf

    ; Pass 2: Draw the perimeter perimeter outline
    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_LOOP)
      For i = 0 To segments
        angle = i * (2.0 * #PI) / segments
        dx = X + Cos(angle) * RadiusX
        dy = Y + Sin(angle) * RadiusY
        glVertex2f_(dx, dy)         ; CHANGED: Use glVertex2f_ for .f values
      Next
      glEnd_()
    EndIf

    GL::GL_PopMatrix()
    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_EllipseArc(X.f, Y.f, RadiusX.f, RadiusY.f, startAngle.f, endAngle.f, Color.l, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_EllipseArc
  ; DESC: Draw a hardware-accelerated open curved ellipse line segment (Ellipse Arc)
  ; VAR(X.f): X-Coordinate of the ellipse's center point
  ; VAR(Y.f): Y-Coordinate of the ellipse's center point
  ; VAR(RadiusX.f): Horizontal radius (semi-major axis)
  ; VAR(RadiusY.f): Vertical radius (semi-minor axis)
  ; VAR(startAngle.f): Starting angle in degrees
  ; VAR(endAngle.f): Ending angle in degrees
  ; VAR(Color.l): 32-Bit RGBA value for the line color
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Context active fault / Drawing failed; #TRUE=Success
  ; ======================================================================
    If This\GadgetID = 0 : ProcedureReturn #False : EndIf

    Protected i, segments
    Protected angle.f, dx.f, dy.f, stepAngle.f, currentAngle.f

    Protected diff.f = endAngle - startAngle
    segments = Abs(diff) / 5
    If segments < 8 : segments = 8 : EndIf
    stepAngle = diff / segments

    ; Draw the open elliptical path line segments
    If Color <> #PB_Default And This\Stroke > 0
      _gl_SetColor(Color)
      glBegin_(#GL_LINE_STRIP)
      For i = 0 To segments
        currentAngle = startAngle + (i * stepAngle)
        angle = Radian(currentAngle)
        dx = X + Cos(angle) * RadiusX
        dy = Y + Sin(angle) * RadiusY
        glVertex2f_(dx, dy)        
      Next
      glEnd_()
    EndIf

    ProcedureReturn #True
  EndProcedure

  Procedure.i gl_Line(X.f, Y.f, Width.f, Height.f, Color.l, Flags.i = #False) 
  ; ======================================================================
  ; NAME: gl_Line
  ; DESC: Draw a single hardware-accelerated straight line defined by start point, width, and height offsets
  ; VAR(X.f): X-Coordinate of the starting point
  ; VAR(Y.f): Y-Coordinate of the starting point
  ; VAR(Width.f): Horizontal distance offset to the line's end point
  ; VAR(Height.f): Vertical distance offset to the line's end point
  ; VAR(Color.l): 32-Bit RGBA value for the line color
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Drawing failed; #TRUE=Success
  ; ======================================================================
    ProcedureReturn gl_LineXY(X, Y, X + Width, Y + Height, Color, Flags) 
  EndProcedure
  
  Procedure.i gl_LinesArc(X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f, Radius.f, Color.l, Flags.i = #False)
  ; ======================================================================
  ; NAME: gl_LinesArc
  ; DESC: Draw a hardware-accelerated arc defined by two connecting lines and a radius
  ; VAR(X1.f): X-Coordinate of the first line's starting point
  ; VAR(Y1.f): Y-Coordinate of the first line's starting point
  ; VAR(X2.f): X-Coordinate of the vertex intersection point (corner)
  ; VAR(Y2.f): Y-Coordinate of the vertex intersection point (corner)
  ; VAR(X3.f): X-Coordinate of the second line's destination point
  ; VAR(Y3.f): Y-Coordinate of the second line's destination point
  ; VAR(Radius.f): Radius of the rounding arc fillet
  ; VAR(Color.l): 32-Bit RGBA value for the arc color
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Not implemented / Drawing failed; #TRUE=Success
  ; ======================================================================
    ProcedureReturn #False 
  EndProcedure
  
  Procedure.i gl_LineH(X.f, Y.f, Width.f, Color.l, Flags.i = #False) 
  ; ======================================================================
  ; NAME: gl_LineH
  ; DESC: Draw a horizontal hardware-accelerated straight line from a start point
  ; VAR(X.f): X-Coordinate of the starting point
  ; VAR(Y.f): Y-Coordinate of the starting point
  ; VAR(Width.f): Horizontal width offset (length of the line)
  ; VAR(Color.l): 32-Bit RGBA value for the line color
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Drawing failed; #TRUE=Success
  ; ======================================================================
    ProcedureReturn gl_LineXY(X, Y, X + Width, Y, Color, Flags)
  EndProcedure
  
  Procedure.i gl_LineV(X.f, Y.f, Height.f, Color.l, Flags.i = #False) 
  ; ======================================================================
  ; NAME: gl_LineV
  ; DESC: Draw a vertical hardware-accelerated straight line from a start point
  ; VAR(X.f): X-Coordinate of the starting point
  ; VAR(Y.f): Y-Coordinate of the starting point
  ; VAR(Height.f): Vertical height offset (length of the line)
  ; VAR(Color.l): 32-Bit RGBA value for the line color
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Drawing failed; #TRUE=Success
  ; ======================================================================
    ProcedureReturn gl_LineXY(X, Y, X, Y + Height, Color, Flags) 
  EndProcedure
  
  Procedure.i gl_TangentsArc(X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f, X4.f, Y4.f, Color.l, Flags.i = #False) 
  ; ======================================================================
  ; NAME: gl_TangentsArc
  ; DESC: Draw a hardware-accelerated arc defined by two tangent lines
  ; VAR(X1.f): X-Coordinate of the first tangent line's start point
  ; VAR(Y1.f): Y-Coordinate of the first tangent line's start point
  ; VAR(X2.f): X-Coordinate of the first tangent line's end point
  ; VAR(Y2.f): Y-Coordinate of the first tangent line's end point
  ; VAR(X3.f): X-Coordinate of the second tangent line's start point (FIXED: changed from .i to .f)
  ; VAR(Y3.f): Y-Coordinate of the second tangent line's start point
  ; VAR(X4.f): X-Coordinate of the second tangent line's end point
  ; VAR(Y4.f): Y-Coordinate of the second tangent line's end point
  ; VAR(Color.l): 32-Bit RGBA value for the arc color
  ; VAR(Flags.i): Custom bitwise operational flags for layout or rendering control
  ; RET : #FALSE=Not implemented / Drawing failed; #TRUE=Success
  ; ======================================================================
    ProcedureReturn #False 
  EndProcedure

  Procedure.f gl_GetTextWidth(Text.s, Flags.i = #glDraw_FLAG_Text_Default)
    Protected width = TextWidth(Text.s)
    
    If This\CurrentFontID <> -1 And IsFont(This\CurrentFontID)
      If StartDrawing(ImageOutput(#PB_Any))
        DrawingFont(This\CurrentFontID)
        StopDrawing()
        ProcedureReturn width
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.f gl_GetTextHeight(Text.s, Flags.i = #glDraw_FLAG_Text_Default)
    Protected height = TextHeight(Text.s)
    
    If This\CurrentFontID <> -1 And IsFont(This\CurrentFontID)
      If StartDrawing(ImageOutput(#PB_Any))
        DrawingFont(This\CurrentFontID)
        StopDrawing()
        ProcedureReturn height
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.i gl_SetDotPattern(LineWidth.f, Array Pattern.f(1), Flags.i = #False, StartOffset.f = 0)
    ProcedureReturn #False
  EndProcedure
  
  
  Procedure.i gl_DisableDotPattern(State.i = #True) 
    ProcedureReturn #False 
  EndProcedure

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

  Dim Pattern.f(3)

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
      
      Define result
      result = glDraw::gl_Text(65, 65, "Text", $701919, 0, #False)
      Debug "gl_Text = " + result
      
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
; CursorPosition = 19
; Folding = -----
; CPU = 5