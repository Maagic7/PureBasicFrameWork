; ===========================================================================
;  FILE: PbFw_Module_OpenGL.pb
;  NAME: Open GL Drawing Module [GL::]
;  DESC: Implements common OpenGL functions and procedural helpers
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/02/21
; VERSION  :  0.50  untested Developer Version
; COMPILER :  PB 6.0 and higher
; OS       :  all
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{
;   
; }            
; ============================================================================

DeclareModule GL
  EnableExplicit
  
  ; ----------------------------
  ; Transformation Helpers
  ; ----------------------------
 
  ; Save current matrix on stack
  Macro GL_PushMatrix()
    glPushMatrix_()
  EndMacro

  ; Restore last matrix from stack
  Macro GL_PopMatrix()
    glPopMatrix_()
  EndMacro

  ; Translate object by (x, y, z)
  Macro GL_Translate(_x, _y, _z)
    glTranslatef_(_x, _y, _z)
  EndMacro

  ; Rotate object by angle (degrees) around axis (x, y, z)
  Macro GL_Rotate(_angle, _x, _y, _z)
    glRotatef_(_angle, _x, _y, _z)
  EndMacro

  ; Scale object by (sx, sy, sz)
  Macro GL_Scale(_sx, _sy, _sz)
    glScalef_(_sx, _sy, _sz)
  EndMacro
  
  ; ----------------------------
  ; Rendering Functions
  ; ----------------------------

  ; Clear color and depth buffers
  Macro GL_Clear(_r, _g, _b, _a = 1.0)
    glClearColor_(_r, _g, _b, _a)
    glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
  EndMacro

  ; Enable depth testing
  Macro GL_EnableDepthTest()
    glEnable_(#GL_DEPTH_TEST)
  EndMacro

  ; Disable depth testing
  Macro GL_DisableDepthTest()
    glDisable_(#GL_DEPTH_TEST)
  EndMacro

  ; Enable blending (for transparency)
  Macro GL_EnableBlend()
    glEnable_(#GL_BLEND)
    glBlendFunc_(#GL_SRC_ALPHA, #GL_ONE_MINUS_SRC_ALPHA)
  EndMacro

  ; Disable blending
  Macro GL_DisableBlend()
    glDisable_(#GL_BLEND)
  EndMacro

  ; Set line width
  Macro GL_SetLineWidth(_width)
    glLineWidth_(_width)
  EndMacro

  ; Set point size
  Macro GL_SetPointSize(_size)
    glPointSize_(_size)
  EndMacro

  ; Swap buffers of the OpenGL Gadget
  Macro GL_SwapBuffers(_OpenGLGadgetNo)
    SetGadgetAttribute(_OpenGLGadgetNo, #PB_OpenGL_FlipBuffers, #True)
  EndMacro

  ; ----------------------------
  ; Camera & Projection
  ; ----------------------------
  Declare GL_SetPerspective(fov.f, aspect.f, near.f, far.f)
  Declare GL_SetOrthographic(left.f, right.f, bottom.f, top.f, near.f, far.f)
  Declare GL_SetCameraPosition(x.f, y.f, z.f, targetX.f, targetY.f, targetZ.f)

  ; ----------------------------
  ; Primitive Drawing Functions
  ; ----------------------------
  Declare GL_DrawCube(size.f)
  Declare GL_DrawSphere(radius.f, slices.i, stacks.i)
  Declare GL_DrawCylinder(radius.f, height.f, slices.i)
  Declare GL_DrawLine(x1.f, y1.f, z1.f, x2.f, y2.f, z2.f)

  Declare GL_DrawPoints(List vertices.Vector3())

  Declare GL_DrawPolygon(List vertices.Vector3())
  Declare GL_DrawMesh(Array vertices.Vector3(1), Array indices.l(1))

  ;- ----------------------------
  ;- Color & Material Macros
  ;- ----------------------------
  
  ; Set current color (r,g,b,a)
  Macro GL_SetColor(_r, _g, _b, _a = 1.0)
    glColor4f_(_r, _g, _b, _a)
  EndMacro
  
  ; Enable lighting calculations
  Macro GL_EnableLighting()
    glEnable_(#GL_LIGHTING)
  EndMacro

  ; Disable lighting
  Macro GL_DisableLighting()
    glDisable_(#GL_LIGHTING)
  EndMacro

  Declare GL_SetMaterial(Array ambient.f(1), Array diffuse.f(1), Array specular.f(1), shininess.f)
 
  ; ----------------------------
  ; Lighting & Shading
  ; ----------------------------
  Declare GL_AddDirectionalLight(id.i, dirX.f, dirY.f, dirZ.f, r.f, g.f, b.f)
  Declare GL_AddPointLight(id.i, posX.f, posY.f, posZ.f, r.f, g.f, b.f)

  ; ----------------------------
  ; Procedural Models
  ; ----------------------------
  Declare GL_CreateCubeVertices(size.f, List vertices.vector3())
  Declare GL_CreateSphereVertices(radius.f, slices.i, stacks.i, List vertices.vector3())

EndDeclareModule

Module GL
  
  EnableExplicit

  ;- ----------------------------
  ;- Camera & Projection
  ;- ----------------------------
  
  Procedure GL_SetPerspective(fov.f, aspect.f, near.f, far.f)
  ; ============================================================================
  ; NAME: GL_SetPerspective
  ; DESC: Set perspective projection
  ; VAR(fov.f): field of view in degrees
  ; VAR(aspect.f): width/height ratio
  ; VAR(near): near clipping plane
  ; VAR(far) : far clipping plane
  ; RET: -
  ; ============================================================================
    glMatrixMode_(#GL_PROJECTION)
    glLoadIdentity_()
    gluPerspective_(fov, aspect, near, far)
    glMatrixMode_(#GL_MODELVIEW)
    glLoadIdentity_()
  EndProcedure

  Procedure GL_SetOrthographic(left.f, right.f, bottom.f, top.f, near.f, far.f)
  ; ============================================================================
  ; NAME: GL_SetOrthographic
  ; DESC: Set orthographic projection
  ; VAR(left.f):
  ; VAR(right.f):
  ; VAR(bottom.f):
  ; VAR(top.f):
  ; VAR(near): near clipping plane
  ; VAR(far) : far clipping plane   
  ; RET : -
  ; ============================================================================
    glMatrixMode_(#GL_PROJECTION)
    glLoadIdentity_()
    glOrtho_(left, right, bottom, top, near, far)
    glMatrixMode_(#GL_MODELVIEW)
    glLoadIdentity_()
  EndProcedure

  Procedure GL_SetCameraPosition(eyeX.f, eyeY.f, eyeZ.f, centerX.f, centerY.f, centerZ.f)
  ; ============================================================================
  ; NAME: GL_SetCameraPosition
  ; DESC: Set camera position (like gluLookAt)
  ; VAR(eyeX.f): Camera position X
  ; VAR(eyeY.f): Camera position A
  ; VAR(eyeZ.f): Camera position Z
  ; VAR(centerX.f): target point X
  ; VAR(centerY.f): target point Y
  ; VAR(centerZ.f): target point Z
  ; RET : -
  ; ============================================================================
    glMatrixMode_(#GL_MODELVIEW)
    glLoadIdentity_()
    gluLookAt_(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, 0.0, 1.0, 0.0)
  EndProcedure

  ;- ----------------------------
  ;- Primitive Drawing Functions
  ;- ----------------------------

   Procedure GL_DrawCube(size.f)
  ; ============================================================================
  ; NAME: GL_DrawCube
  ; DESC: Draw a cube centered at origin with given size
  ; VAR(size.f): Cube size
  ; RET : -
  ; ============================================================================
    Protected s.f = size * 0.5

    glBegin_(#GL_QUADS)

    ; Front face
    glVertex3f_(-s, -s, s)
    glVertex3f_(s, -s, s)
    glVertex3f_(s, s, s)
    glVertex3f_(-s, s, s)

    ; Back face
    glVertex3f_(-s, -s, -s)
    glVertex3f_(-s, s, -s)
    glVertex3f_(s, s, -s)
    glVertex3f_(s, -s, -s)

    ; Left face
    glVertex3f_(-s, -s, -s)
    glVertex3f_(-s, -s, s)
    glVertex3f_(-s, s, s)
    glVertex3f_(-s, s, -s)

    ; Right face
    glVertex3f_(s, -s, -s)
    glVertex3f_(s, s, -s)
    glVertex3f_(s, s, s)
    glVertex3f_(s, -s, s)

    ; Top face
    glVertex3f_(-s, s, -s)
    glVertex3f_(-s, s, s)
    glVertex3f_(s, s, s)
    glVertex3f_(s, s, -s)

    ; Bottom face
    glVertex3f_(-s, -s, -s)
    glVertex3f_(s, -s, -s)
    glVertex3f_(s, -s, s)
    glVertex3f_(-s, -s, s)

    glEnd_()
  EndProcedure

  Procedure GL_DrawLine(x1.f, y1.f, z1.f, x2.f, y2.f, z2.f)
  ; ============================================================================
  ; NAME: GL_DrawLine
  ; DESC: Draw a line between two points
  ; VAR(x.f): x Point 1 
  ; VAR(y.f): y Point 1 
  ; VAR(z.f): z Point 1 
  ; VAR(x.f): x Point 2 
  ; VAR(y.f): y Point 2 
  ; VAR(z.f): z Point 2 
  ; RET : -
  ; ============================================================================
    glBegin_(#GL_LINES)
    glVertex3f_(x1, y1, z1)
    glVertex3f_(x2, y2, z2)
    glEnd_()
  EndProcedure

  Procedure GL_DrawPoints(List vertices.Vector3())
  ; ============================================================================
  ; NAME: GL_DrawPoints
  ; DESC: Draw points from a List of vertic
  ; VAR(vertices): List of vector3
  ; RET : -
  ; ============================================================================

    If ListSize(vertices())
      glBegin_(#GL_POINTS)
      ForEach vertices()
        glVertex3f_(vertices()\x, vertices()\y, vertices()\z)
      Next
      glEnd_()
    EndIf
  EndProcedure

  Procedure GL_DrawCone(Rbase.f, Rtop.f, height.f, slices)
  ; =========================================================
  ; NAME:  GL_DrawCone 
  ; DESC: DrawCone - Draw a cone or truncated cone
  ; VAR(Rbase): radius at bottom
  ; VAR(Rtop): radius at top
  ; VAR(height): height along Y axis
  ; VAR(slices): divisions around circumference
  ; =========================================================
    Protected.i I
    Protected.f x0, z0, x1, z1
    Protected.f angle
    Protected.f angleStep = 2.0 * #PI / slices

    ; Draw side faces as quad strips
    glBegin_(#GL_QUAD_STRIP)
    For I = 0 To slices
      angle = I * angleStep
      x0 = Cos(angle) * Rbase
      z0 = Sin(angle) * Rbase
      x1 = Cos(angle) * Rtop
      z1 = Sin(angle) * Rtop
      glVertex3f_(x0, 0, z0) ; bottom circle
      glVertex3f_(x1, height, z1) ; top circle
    Next
    glEnd_()

    ; Draw bottom cap
    If Rbase > 0
      glBegin_(#GL_TRIANGLE_FAN)
      glVertex3f_(0, 0, 0) ; center
      For i = 0 To slices
        angle = i * angleStep
        x0 = Cos(angle) * Rbase
        z0 = Sin(angle) * Rbase
        glVertex3f_(x0, 0, z0)
      Next
      glEnd_()
    EndIf

    ; Draw top cap
    If Rtop > 0
      glBegin_(#GL_TRIANGLE_FAN)
      glVertex3f_(0, height, 0) ; center
      For i = 0 To slices
        angle = i * angleStep
        x1 = Cos(angle) * Rtop
        z1 = Sin(angle) * Rtop
        glVertex3f_(x1, height, z1)
      Next
      glEnd_()
    EndIf
  EndProcedure

  Procedure GL_DrawCylinder(radius.f, height.f, slices.i)
  ; =========================================================
  ; NAME: GL_DrawCylinder  
  ; DESC: Draw a cylinder along Y axis
  ; VAR(radius): cylinder radius
  ; VAR(height): cylinder height
  ; VAR(slices): divisions around circumference
  ; RET: -
  ; =========================================================
    ; Just call DrawCone with same top/bottom radius
    GL_DrawCone(radius, radius, height, slices)
  EndProcedure

  Procedure GL_DrawPolygon(List vertices.Vector3())
  ; =========================================================
  ; NAME: GL_DrawPolygon  
  ; DESC: Draw polygon from a List of vector3
  ; VAR(vertices): List of vertices
  ; RET: -
  ; =========================================================

    If ListSize(vertices())
      glBegin_(#GL_POLYGON)
      ForEach vertices()
        glVertex3f_(vertices()\x, vertices()\y, vertices()\z)
      Next
      glEnd_()
    EndIf
  EndProcedure

  Procedure GL_DrawSphere(radius.f, slices.i, stacks.i)
  ; =========================================================
  ; NAME: GL_DrawSphere
  ; DESC: DrawSphere - Draw a sphere centered at origin
  ; VAR(radius): sphere radius
  ; VAR(slices): longitude divisions
  ; VAR(stacks): latitude divisions
  ; RET: -
  ; =========================================================
    Protected.i I, J
    Protected.f x0, y0, z0
    Protected.f x1, y1, z1
    Protected.f phi0, phi1, theta
    Protected.f phiStep = #PI / stacks
    Protected.f thetaStep = 2 * #PI / slices
    
    For I = 0 To stacks-1
      phi0 = I * phiStep
      phi1 = (I + 1) * phiStep
      glBegin_(#GL_QUAD_STRIP)
      
      For J = 0 To slices
        theta = J * thetaStep

        ; lower ring
        x0 = radius * Sin(phi0) * Cos(theta)
        y0 = radius * Cos(phi0)
        z0 = radius * Sin(phi0) * Sin(theta)
        glVertex3f_(x0, y0, z0)

        ; upper ring
        x1 = radius * Sin(phi1) * Cos(theta)
        y1 = radius * Cos(phi1)
        z1 = radius * Sin(phi1) * Sin(theta)
        glVertex3f_(x1, y1, z1)
      Next
      glEnd_()
    Next
  EndProcedure

  Procedure GL_DrawMesh(Array vertices.Vector3(1), Array indices.l(1))
  ; =========================================================
  ; NAME: GL_DrawMesh
  ; DESC: Draw mesh from Array of vertices and indices
  ; VAR(vertices): Array of Vector3
  ; VAR(indices) : Array of Integers (triangle indices)
  ; RET: -
  ; =========================================================

    ; Enable the client state for vertex positions
    glEnableClientState_(#GL_VERTEX_ARRAY)

    ; Point OpenGL to your vertex data
    glVertexPointer_(3, #GL_FLOAT, SizeOf(Vector3), @vertices(0))

    ; Draw everything in one command
    glDrawElements_(#GL_TRIANGLES, ArraySize(indices()) + 1, #GL_UNSIGNED_INT, @indices(0))
    glDisableClientState_(#GL_VERTEX_ARRAY)
  EndProcedure

  ; =========================================================
  ; GL Module - Color & Material Functions (Point 5)
  ; =========================================================

  ; Set material properties
  ; ambient, diffuse, specular: float arrays of 4 values each
  ; shininess: single float
  Procedure GL_SetMaterial(Array ambient.f(1), Array diffuse.f(1), Array specular.f(1), shininess.f)
  ; =========================================================
  ; NAME: GL_SetMaterial
  ; DESC: Set material properties
  ; VAR(ambient)  : Array of 4 floats
  ; VAR(diffuse)  : Array of 4 floats
  ; VAR(specular) : Array of 4 floats
  ; VAR(shininess): Array of 4 floats
  ; RET: -
  ; =========================================================
    glMaterialfv_(#GL_FRONT_AND_BACK, #GL_AMBIENT, ambient())
    glMaterialfv_(#GL_FRONT_AND_BACK, #GL_DIFFUSE, diffuse())
    glMaterialfv_(#GL_FRONT_AND_BACK, #GL_SPECULAR, specular())
    glMaterialf_(#GL_FRONT_AND_BACK, #GL_SHININESS, shininess)
  EndProcedure

  ;- ----------------------------
  ;- Lighting & Shading
  ;- ----------------------------

  Procedure GL_AddDirectionalLight(id.i, dirX.f, dirY.f, dirZ.f, r.f, g.f, b.f)
  ; =========================================================
  ; NAME: GL_AddDirectionalLight
  ; DESC: Set material properties
  ; VAR(id)  : OpenGL light number (e.g., #GL_LIGHT0)
  ; VAR(dirX)  : x direction of the light
  ; VAR(dirY)  : y direction of the light
  ; VAR(dirZ)  : z direction of the light
  ; VAR(r):  Red 
  ; VAR(g):  Green
  ; VAR(b):  Blue
  ; RET: -
  ; =========================================================
    Protected diffuse.Vector4
    Protected position.Vector4

    ; Enable the light
    glEnable_(id)

    ; Set light color
    diffuse\x = r
    diffuse\y = g
    diffuse\z = b
    diffuse\w = 1.0
    glLightfv_(id, #GL_DIFFUSE, diffuse)

    ; Directional light has w = 0
    position\x = dirX
    position\y = dirY
    position\z = dirZ
    position\w = 0.0 ; w = 0 -> directional light
    glLightfv_(id, #GL_POSITION, position)
  EndProcedure

  Procedure GL_AddPointLight(id.i, posX.f, posY.f, posZ.f, r.f, g.f, b.f)
  ; =========================================================
  ; NAME: GL_AddPointLight
  ; DESC: Add a point light
  ; VAR(id)  : OpenGL light number (e.g., #GL_LIGHT0)
  ; VAR(posX)  : x position of the light
  ; VAR(posY)  : y position of the light
  ; VAR(posZ)  : z position of the light
  ; VAR(r):  Red 
  ; VAR(g):  Green
  ; VAR(b):  Blue
  ; RET: -
  ; =========================================================

    Protected diffuse.Vector4
    Protected position.Vector4

    ; Enable lighting system (important)
    glEnable_(#GL_LIGHTING)
    glEnable_(id)

    ; ---- Diffuse color (RGBA) ----
    diffuse\x = r
    diffuse\y = g
    diffuse\z = b
    diffuse\w = 1.0
    glLightfv_(id, #GL_DIFFUSE, diffuse)

    ; ---- Position (w = 1.0 → point light) ----
    position\x = posX
    position\y = posY
    position\z = posZ
    position\w = 1.0
    glLightfv_(id, #GL_POSITION, position)

  EndProcedure

  ;- ----------------------------
  ;- Procedural Models
  ;- ----------------------------

  Procedure GL_CreateCubeVertices(size.f, List vertices.vector3())
  ; =========================================================
  ; NAME: GL_CreateCubeVertices
  ; DESC: Create cube vertices for a cube centered at origin
  ; VAR(size): full edge length
  ; VAR(vertices): List of vector3 (output, 8 vertices)
  ; RET: -
  ; =========================================================

    Protected s.f = size * 0.5

    ; Clear existing content
    ClearList(vertices())

    ; ---- Back face ----
    AddElement(vertices())
    vertices()\x = -s : vertices()\y = -s : vertices()\z = -s

    AddElement(vertices())
    vertices()\x = s : vertices()\y = -s : vertices()\z = -s

    AddElement(vertices())
    vertices()\x = s : vertices()\y = s : vertices()\z = -s

    AddElement(vertices())
    vertices()\x = -s : vertices()\y = s : vertices()\z = -s

    ; ---- Front face ----
    AddElement(vertices())
    vertices()\x = -s : vertices()\y = -s : vertices()\z = s

    AddElement(vertices())
    vertices()\x = s : vertices()\y = -s : vertices()\z = s

    AddElement(vertices())
    vertices()\x = s : vertices()\y = s : vertices()\z = s

    AddElement(vertices())
    vertices()\x = -s : vertices()\y = s : vertices()\z = s

  EndProcedure

  Procedure GL_CreateSphereVertices(radius.f, slices.i, stacks.i, List vertices.vector3())
  ; =========================================================
  ; NAME: GL_CreateSphereVertices  
  ; DESC: Create sphere vertices
  ; VAR(radius): sphere radius
  ; VAR(slices): longitude divisions
  ; VAR(stacks): latitude divisions
  ; VAR(ertices): List of vector3 (output)
  ; =========================================================
    Protected I, J
    Protected.f phi, y, r, theta
    ClearList(vertices())

    For I = 0 To stacks

      phi = #PI * I / stacks
      y = radius * Cos(phi)
      r = radius * Sin(phi)

      For J = 0 To slices
        theta = 2 * #PI * J / slices
        AddElement(vertices())
        vertices()\x = r * Cos(theta)
        vertices()\y = y
        vertices()\z = r * Sin(theta)
      Next
    Next
  EndProcedure

EndModule

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 598
; FirstLine = 493
; Folding = ------
; DPIAware
; CPU = 5