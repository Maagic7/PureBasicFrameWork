; ===========================================================================
;  FILE : PbFw_Module_Win_Glyph.pb
;  NAME : Glyph Module for Windows [Glyph::]
;  DESC : Extracts TrueType/OpenType vector outlines using Win32 API
;  DESC : and stores them in structured PureBasic lists.
;  DESC : Supports single Character and complete Strings
;  SOURCES:
;     - my old VB6 GlyphOutline code 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/11/01
; VERSION  :  0.9  Beta Test Version
; COMPILER :  PureBasic 6.0+
; OS       :  Windows only
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{ 
;  2026/11/04 S.Maag Added G-Code Export
;  2026/11/03 S.Maag fixed some things and created test code with help of AI
;}             
; ============================================================================

DeclareModule Glyph
  EnableExplicit

  ;- --- Windows API Structures (Predefined in PB, left as reference) ---
  ;   Structure POINTFX
  ;     x.POINTFX_FIXED
  ;     y.POINTFX_FIXED
  ;   EndStructure
  ;
  ;   Structure TTPOLYGONHEADER
  ;     cb.l
  ;     dwType.l
  ;     pfxStart.POINTFX
  ;   EndStructure
  ;
  ;   Structure TTPOLYCURVE
  ;     wType.w
  ;     cpfx.w
  ;   EndStructure
  ;
  ;   Structure GLYPHMETRICS
  ;     gmBlackBoxX.l
  ;     gmBlackBoxY.l
  ;     gmptGlyphOrigin.POINT
  ;     gmCellIncX.w
  ;     gmCellIncY.w
  ;   EndStructure
  ;
  ;   Structure MAT2
  ;     eM11.POINTFX
  ;     eM12.POINTFX
  ;     eM21.POINTFX
  ;     eM22.POINTFX
  ;   EndStructure

  ;- --- Internal PureBasic Structures for Storage ---
  
  #GLYPH_LINE    = 1
  #GLYPH_QSPLINE = 2

  Structure TPointGlyph
    x.f
    y.f
    type.i ; #GLYPH_LINE or #GLYPH_QSPLINE
  EndStructure

  Structure TGlyphPolygon
    startX.f
    startY.f
    List Points.TPointGlyph()
  EndStructure

  Structure TGlyphData
    Char.c
    Metrics.GLYPHMETRICS
    List Polygons.TGlyphPolygon()
  EndStructure
   
  Structure TPointFloat
    x.f
    y.f
  EndStructure

  Structure TPolygonPoints
     ; we need Char here, because for a text, the polygons of all Glyphs are copied into a single TGlyphContour
     Char.c        
     List PathPoints.TPointFloat()
  EndStructure

  Structure TGlyphContour
   List Contour.TPolygonPoints()
  EndStructure

  ;- --- Public Module Procedures ---
  Declare.i ExtractGlyphOutline(Hdc.i, Character.c, *OutGlyph.TGlyphData)
  Declare.i SmoothGlyphContour(*SourceGlyph.TGlyphData, *outGC.TGlyphContour, Subdivisions.i = 8)
  Declare.i SmoothTextContour(Hdc.i, Text.s, *outGC.TGlyphContour, Subdivisions.i = 8)
  Declare.i DrawGlyph(*GC.TGlyphContour, X.f, Y.f, Scale.f = 1.0, DrawPoints.i = #False)
  Declare.i DrawEngravingContour(*GC.TGlyphContour, X.f, Y.f, Scale.f = 1.0)
  
  Declare.s CreateGCodeString(*GC.TGlyphContour, Comment$, Scale.f = 1.0, FeedRate.i = 1000, PlungeRate.i = 300, TravelZ.f = 2.0, WorkZ.f = -0.2)

EndDeclareModule

Module Glyph
  
  EnableExplicit

  #GGO_METRICS = 0
  #GGO_NATIVE  = 2

  ; Helper Macro to convert Windows 16.16 Fixed Point (POINTFX structure components) to Float
  Macro FixedToFloat(_PointFX)
    (_PointFX\value + (_PointFX\fract / 65536.0))
  EndMacro

  Procedure.i _CreateIdentityMatrix(*Matrix.MAT2)
    If *Matrix
      *Matrix\eM11\value = 1
      *Matrix\eM11\fract = 0
      *Matrix\eM12\value = 0
      *Matrix\eM12\fract = 0
      *Matrix\eM21\value = 0
      *Matrix\eM21\fract = 0
      *Matrix\eM22\value = 1
      *Matrix\eM22\fract = 0
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i ExtractGlyphOutline(Hdc.i, Character.c, *outGlyph.TGlyphData)
  ; ======================================================================
  ; NAME: ExtractGlyphOutline
  ; DESC: Extracts raw TrueType/OpenType vector outlines via Win32 API
  ; VAR(Hdc.i): Windows Device Context handle containing the active font
  ; VAR(Character.c): The Unicode character to extract the outlines from
  ; VAR(*outGlyph.TGlyphData): Pointer to the structure receiving the vectors
  ; RET.i : #True if extraction succeeded, #False otherwise
  ; ======================================================================
    Protected Matrix.MAT2
    Protected Metrics.GLYPHMETRICS
    Protected BufferSize.l
    Protected *Buffer, *BufferEnd, *CurrentPtr, *PolyHeader.TTPOLYGONHEADER
    Protected *PolyCurve.TTPOLYCURVE, *PointPtr.POINTFX
    Protected I.i, CurvesLength.i
    
    If Not *outGlyph : ProcedureReturn #False : EndIf
    
    ClearList(*outGlyph\Polygons())
    *outGlyph\Char = Character
    _CreateIdentityMatrix(Matrix)
    
    BufferSize = GetGlyphOutline_(Hdc, Character, #GGO_NATIVE, @Metrics, 0, #Null, @Matrix)
    If BufferSize <= 0 : ProcedureReturn #False : EndIf
    
    *Buffer = AllocateMemory(BufferSize)
    If Not *Buffer : ProcedureReturn #False : EndIf
    
    If GetGlyphOutline_(Hdc, Character, #GGO_NATIVE, @Metrics, BufferSize, *Buffer, @Matrix) <= 0
      FreeMemory(*Buffer)
      ProcedureReturn #False
    EndIf
    
    CopyStructure(@Metrics, *outGlyph\Metrics, GLYPHMETRICS)
    
    *CurrentPtr = *Buffer
    *BufferEnd  = *Buffer + BufferSize
    
    While *CurrentPtr < *BufferEnd
      *PolyHeader = *CurrentPtr
      
      AddElement(*outGlyph\Polygons())
      *outGlyph\Polygons()\startX = FixedToFloat(*PolyHeader\pfxStart\x)
      *outGlyph\Polygons()\startY = FixedToFloat(*PolyHeader\pfxStart\y)
      
      ; The next curve segment starts strictly after the header length (24 Bytes)
      *CurrentPtr + SizeOf(TTPOLYGONHEADER)
      Protected *PolyEnd = *PolyHeader + *PolyHeader\cb
      
      While *CurrentPtr < *PolyEnd
        *PolyCurve = *CurrentPtr
        
        ; Crucial Fix: A TTPOLYCURVE structure payload is exactly 4 bytes (wType.w + cpfx.w). 
        ; Do NOT use SizeOf(TTPOLYCURVE) to advance to the points array, as compiler padding corrupts it.
        *PointPtr = *CurrentPtr + 4 
        
        For I = 0 To *PolyCurve\cpfx - 1
          AddElement(*outGlyph\Polygons()\Points())
          *outGlyph\Polygons()\Points()\x = FixedToFloat(*PointPtr\x)
          *outGlyph\Polygons()\Points()\y = FixedToFloat(*PointPtr\y)
          
          If *PolyCurve\wType = 1 ; TT_PRIM_LINE
            *outGlyph\Polygons()\Points()\type = #GLYPH_LINE
          Else ; TT_PRIM_QSPLINE
            *outGlyph\Polygons()\Points()\type = #GLYPH_QSPLINE
          EndIf
          
          *PointPtr + SizeOf(POINTFX) ; POINTFX is always exactly 8 bytes (4 bytes X + 4 bytes Y)
        Next
        
        ; Advance to the next curve block by jumping past the header (4 bytes) and all points
        *CurrentPtr = *PointPtr
      Wend
    Wend
    
    FreeMemory(*Buffer)
    ProcedureReturn #True
  EndProcedure
      
  Procedure.i SmoothGlyphContour(*SourceGlyph.TGlyphData, *outGC.TGlyphContour, Subdivisions.i = 8)
  ; ======================================================================
  ; NAME: SmoothGlyphContour
  ; DESC: Processes raw quadratic bezier curves (QSPLINES) and linear strokes 
  ;       extracted from TrueType data, flattening them into sequential point links.
  ; VAR(*SourceGlyph)  : Input pointer containing the raw API polygon structural data
  ; VAR(*outGC): Destination pointer to receive the smoothed linear vector tracks
  ; VAR(Subdivisions)  : Level of resolution (number of linear segments per bezier span)
  ; RET.i              : #True if formatting and interpolation succeeded, #False otherwise
  ; ======================================================================    
    Protected P.i, Pt.i, S.i
    Protected StepFactor.f, T.f, InvT.f
    Protected MidX.f, MidY.f
    Protected Ax.f, Ay.f, Bx.f, By.f, Cx.f, Cy.f
    Protected NextX.f, NextY.f
    Protected BypassSpline.i

    If Not *SourceGlyph Or Not *outGC : ProcedureReturn #False : EndIf
    
    ; Intercept Subdivisions = 0 to trigger raw original points mode safely
    If Subdivisions <= 0
      BypassSpline = #True
    ElseIf Subdivisions < 2
      Subdivisions = 2 ; Clamp minimal splitting to avoid math errors
    EndIf
    
    ClearList(*outGC\Contour())
    
    ; Avoid division-by-zero errors if subdivisions are set to 0 (Fallback to Raw mode)
    If Subdivisions < 1 : Subdivisions = 1 : EndIf
    StepFactor = 1.0 / Subdivisions
    
    ; Iterate through each individual raw polygon contour segment block
    ForEach *SourceGlyph\Polygons()
      AddElement(*outGC\Contour())
      
      ; Establish and log the initial starting coordinate of the layout loop
      Ax = *SourceGlyph\Polygons()\startX
      Ay = *SourceGlyph\Polygons()\startY
      
      AddElement(*outGC\Contour()\PathPoints())
      *outGC\Contour()\PathPoints()\x = Ax
      *outGC\Contour()\PathPoints()\y = Ay
      
      ; Traverse through all sequential point coordinates within this contour loop
      ForEach *SourceGlyph\Polygons()\Points()
        
       ; If BypassSpline is true, treat everything as raw coordinate points without math
        If *SourceGlyph\Polygons()\Points()\type = #GLYPH_LINE Or BypassSpline
          ; --- Process Standard Linear Move ---
          Ax = *SourceGlyph\Polygons()\Points()\x
          Ay = *SourceGlyph\Polygons()\Points()\y
          
          AddElement(*outGC\Contour()\PathPoints())
          *outGC\Contour()\PathPoints()\x = Ax
          *outGC\Contour()\PathPoints()\y = Ay
          
        Else
          ; --- Process Quadratic Bezier Spline (TT_PRIM_QSPLINE) ---
          ; Identify the active control point coordinates
          Bx = *SourceGlyph\Polygons()\Points()\x
          By = *SourceGlyph\Polygons()\Points()\y
          
          ; Determine the destination anchor position of the curve sequence
          If ListIndex(*SourceGlyph\Polygons()\Points()) < ListSize(*SourceGlyph\Polygons()\Points()) - 1
            ; Peak forward to check if the subsequent node is also a spline component
            PushListPosition(*SourceGlyph\Polygons()\Points())
            NextElement(*SourceGlyph\Polygons()\Points())
            
            If *SourceGlyph\Polygons()\Points()\type = #GLYPH_QSPLINE
              ; If consecutive control nodes appear, their exact mid-point acts as the anchor
              Cx = (Bx + *SourceGlyph\Polygons()\Points()\x) * 0.5
              Cy = (By + *SourceGlyph\Polygons()\Points()\y) * 0.5
            Else
              ; Standard final anchor point match
              Cx = *SourceGlyph\Polygons()\Points()\x
              Cy = *SourceGlyph\Polygons()\Points()\y
            EndIf
            PopListPosition(*SourceGlyph\Polygons()\Points())
          Else
            ; Loop wrap-around anchor condition targeting the initial start coordinate
            Cx = *SourceGlyph\Polygons()\startX
            Cy = *SourceGlyph\Polygons()\startY
          EndIf
          
          ; Interpolate the quadratic bezier path via De Casteljau step divisions
          For S = 1 To Subdivisions
            T = S * StepFactor
            InvT = 1.0 - T
            
            ; Standard quadratic Bernstein polynomial blend formula
            NextX = (InvT * InvT * Ax) + (2.0 * InvT * T * Bx) + (T * T * Cx)
            NextY = (InvT * InvT * Ay) + (2.0 * InvT * T * By) + (T * T * Cy)
            
            AddElement(*outGC\Contour()\PathPoints())
            *outGC\Contour()\PathPoints()\x = NextX
            *outGC\Contour()\PathPoints()\y = NextY
          Next
          
          ; Set current end coordinate as the origin marker for the next iteration step
          Ax = Cx
          Ay = Cy
        EndIf
      Next
    Next
    
    ProcedureReturn #True
  EndProcedure

 Procedure.i SmoothTextContour(Hdc.i, Text.s, *outGC.TGlyphContour, Subdivisions.i = 8)
  ; ======================================================================
  ; NAME: SmoothTextContour
  ; DESC: Extracts, smooths, and strings multiple characters sequentially into a unified text buffer.
  ;       Automatically computes tracking advances and shifts horizontal spacing offsets.
  ; VAR(Hdc.i)    : Windows Device Context handle containing the active font selection
  ; VAR(Text.s)   : The target text string to be converted into vector lines
  ; VAR(*outGC): Destination pointer to the master TGlyphContour accumulation buffer
  ; VAR(Subdivisions): Number of linear steps used to evaluate bezier curve segments
  ; RET.i         : #True if text string processing succeeded, #False otherwise
  ; ======================================================================    
    Protected I.i, Length.i, Char.c
    Protected TempGlyph.TGlyphData
    Protected TempContour.TGlyphContour
    Protected CurrentXOffset.f = 0.0 ; Tracks the active horizontal cursor insertion point
    
    Length = Len(Text)
    ClearList(*outGC\Contour())
    
    For I = 1 To Length
      Char = Asc(Mid(Text, I, 1))
      
      ; 1. Extract raw vector data from the Win32 API font engine
      If ExtractGlyphOutline(Hdc, Char, TempGlyph)
        ClearList(TempContour\Contour())
        
        ; Evaluate and flatten bezier curves into localized vector coordinates starting at X=0
        SmoothGlyphContour(TempGlyph, @TempContour, Subdivisions)
        
        ; 2. Transfer generated segments into the master buffer and apply horizontal translation
        ForEach TempContour\Contour()
          AddElement(*outGC\Contour())
          CopyStructure(TempContour\Contour(), *outGC\Contour(), TPolygonPoints)
          
          ; Tag the active segment contour with its parent character ID for G-code tracking
          *outGC\Contour()\Char = Char 
          
          ; Shift every single point coordinate forward by the active cumulative text offset
          ForEach *outGC\Contour()\PathPoints()
            *outGC\Contour()\PathPoints()\x + CurrentXOffset
          Next
        Next
        
        ; 3. Advance the horizontal spacing offset using official character metric widths
        CurrentXOffset + TempGlyph\Metrics\gmCellIncX
        
      Else
        ; Fallback layout width handler for spaces (where the API returns no physical outline vectors)
        CurrentXOffset + 24.0 
      EndIf
    Next
    
    ProcedureReturn #True
  EndProcedure

 Procedure.i DrawGlyph(*GC.TGlyphContour, X.f, Y.f, Scale.f = 1.0, DrawPoints.i = #False)
  ; ======================================================================
  ; NAME: DrawGlyph
  ; DESC: Renders the smoothed vector contour shapes or raw mesh control points.
  ;       Used for structural layout visualization and mesh diagnostic inspection.
  ; VAR(*GC): Pointer to the flattened point render buffer
  ; VAR(X.f)      : Target horizontal insertion coordinate (X-axis position)
  ; VAR(Y.f)      : Target vertical insertion coordinate (Y-axis position)
  ; VAR(Scale.f)  : Multiplier factor to scale the display rendering size
  ; VAR(DrawPoints): If #True, just Draw the Points. No lines!
  ; RET.i         : #True if drawing succeeded, #False otherwise
  ; ======================================================================    
    Protected IsFirst.i
    Protected PtX.f, PtY.f
    
    If Not *GC
      ProcedureReturn #False
    EndIf
    
    SaveVectorState()
    
    ; Setup rendering offsets, scales, and flip the Y-axis to match the active font matrix
    TranslateCoordinates(X, Y)
    ScaleCoordinates(Scale, Scale)
    FlipCoordinatesY(0.0)
    
    If DrawPoints
      ; --- Option A: Render mathematical subdivision control points (Debug Mode) ---
      VectorSourceColor(RGBA(231, 76, 60, 255)) ; High-contrast red for nodes
      
      ForEach *GC\Contour()
        ForEach *GC\Contour()\PathPoints()
          MovePathCursor(*GC\Contour()\PathPoints()\x, *GC\Contour()\PathPoints()\y)
          AddPathCircle(*GC\Contour()\PathPoints()\x, *GC\Contour()\PathPoints()\y, 1.5)
        Next
      Next
      FillPath()
      
    Else
      ; --- Option B: Render toolpath contours strictly as straight linear chains ---
      ForEach *GC\Contour()
        IsFirst = #True
        
        ForEach *GC\Contour()\PathPoints()
          PtX = *GC\Contour()\PathPoints()\x
          PtY = *GC\Contour()\PathPoints()\y
          
          If IsFirst
            MovePathCursor(PtX, PtY)
            IsFirst = #False
          Else
            ; Forces linear tracking between steps to visually reveal the active resolution
            AddPathLine(PtX, PtY) 
          EndIf
        Next
        
        ; Close the loop for standard font visualization previews
        ClosePath() 
      Next
      
      VectorSourceColor(RGBA(52, 152, 219, 255)) ; Clean blue for outline profiles
      StrokePath(1.5)
    EndIf
    
    RestoreVectorState()
    ProcedureReturn #True
  EndProcedure
 
Procedure.i DrawEngravingContour(*GC.TGlyphContour, X.f, Y.f, Scale.f = 1.0)
  ; ======================================================================
  ; NAME: DrawEngravingContour
  ; DESC: Renders points as open, single-line contours (perfect for CNC engraving).
  ;       Strictly prevents paths from being automatically closed.
  ; VAR(*GC): Pointer to the smoothed glyph contour render buffer
  ; VAR(X.f)      : Target horizontal insertion coordinate (X-axis position)
  ; VAR(Y.f)      : Target vertical insertion coordinate (Y-axis position)
  ; VAR(Scale.f)  : Multiplier factor to scale the output toolpath size
  ; RET.i         : #True if drawing succeeded, #False otherwise
  ; ======================================================================    
    Protected IsFirstPoint.i
    Protected PtX.f, PtY.f
    
    If Not *GC
      ProcedureReturn #False
    EndIf
  
    SaveVectorState()
    
    ; Setup transformation, scaling, and flip the Cartesian Y-axis direction for CNC
    TranslateCoordinates(X, Y)
    ScaleCoordinates(Scale, Scale)
    FlipCoordinatesY(0.0)
  
    ; Iterate through all contour segments and draw them strictly as open line tracks
    ForEach *GC\Contour()
      IsFirstPoint = #True
      
      ForEach *GC\Contour()\PathPoints()
        PtX = *GC\Contour()\PathPoints()\x
        PtY = *GC\Contour()\PathPoints()\y
        
        If IsFirstPoint
          MovePathCursor(PtX, PtY)
          IsFirstPoint = #False
        Else
          AddPathLine(PtX, PtY)
        EndIf
      Next
      
      ; CRUCIAL FOR ENGRAVING: Do NOT call ClosePath() here!
      ; The engraving tool must stop at the end of the line and retract.
      ; ClosePath() 
   Next

    ; Visualize the calculated toolpath as a clear engraving hairline
    VectorSourceColor(RGBA(255, 128, 0, 255)) ; High-visibility orange for the toolpath
    StrokePath(0.8, #PB_Path_RoundEnd | #PB_Path_RoundCorner)
    
    RestoreVectorState()
    ProcedureReturn #True
  EndProcedure
    
  Procedure.s CreateGCodeString(*GC.TGlyphContour, Text.s, Scale.f = 1.0, FeedRate.i = 1000, PlungeRate.i = 300, TravelZ.f = 2.0, WorkZ.f = -0.2)
  ; ======================================================================
  ; NAME: CreateGCodeString
  ; DESC: Converts the prepared contours into a production-ready CNC G-code text string
  ; VAR(*GC): Pointer to the point render buffer
  ; VAR(Text.s)   : The actual text string converted into this G-Code payload
  ; VAR(Scale.f): Multiplier factor to convert font units into millimeters
  ; VAR(FeedRate): Linear milling cutting feedrate speed (mm/min)
  ; VAR(PlungeRate): Vertical entry speed into the material for the Z-axis (mm/min)
  ; VAR(TravelZ): Safe rapid clearance height above stock level (retracted)
  ; VAR(WorkZ): Physical engraving depth target inside stock (negative value)
  ; RET.s: A full valid G-code script block string
  ; ======================================================================
    
    ; created by Google Gemeni
    
    Protected GCode.s = ""
    Protected IsFirstPoint.i
    Protected PtX.f, PtY.f
    Protected SafeText.s
    
    If Not *GC : ProcedureReturn "" : EndIf
    
    ; Clean up the text for CNC safety (strip out internal brackets that break G-Code parsers)
    SafeText = ReplaceString(Text, "(", "[")
    SafeText = ReplaceString(SafeText, ")", "]")
    
    ; --- Write G-Code Header ---
    GCode + "( G-Code generated with PureBasic Glyph Module )" + #CRLF$
    GCode + "( Date: " + FormatDate("%Y-%m-%d %H:%M:%S", Date()) + " )" + #CRLF$
    GCode + "( Engraved Text: " + SafeText + " )" + #CRLF$
    GCode + "G21 ( Units: Millimeters )" + #CRLF$
    GCode + "G90 ( Absolute Positioning )" + #CRLF$
    GCode + "G17 ( Select XY Plane )" + #CRLF$
    GCode + "M03 S12000 ( Spindle ON at 12000 RPM )" + #CRLF$
    GCode + "G00 Z" + StrF(TravelZ, 3) + " ( Move to safe clearance height )" + #CRLF$
    
    ; --- Process Contours ---
    Protected LastChar.c = 0
    
    ForEach *GC\Contour()
      If ListSize(*GC\Contour()\PathPoints()) = 0 : Continue : EndIf
      
      ; FIXED: Check the active contour item's Char field to catch string transitions
      If *GC\Contour()\Char <> 32 And *GC\Contour()\Char <> LastChar
        LastChar = *GC\Contour()\Char
        GCode + #CRLF$ + "( --- Character: " + Chr(LastChar) + " --- )" + #CRLF$
      EndIf
      
      IsFirstPoint = #True
      ForEach *GC\Contour()\PathPoints()
        PtX = *GC\Contour()\PathPoints()\x * Scale
        PtY = *GC\Contour()\PathPoints()\y * Scale * -1.0 
        
        If IsFirstPoint
          GCode + "G00 X" + StrF(PtX, 3) + " Y" + StrF(PtY, 3) + #CRLF$
          GCode + "G01 Z" + StrF(WorkZ, 3) + " F" + Str(PlungeRate) + #CRLF$
          IsFirstPoint = #False
        Else
          GCode + "G01 X" + StrF(PtX, 3) + " Y" + StrF(PtY, 3) + " F" + Str(FeedRate) + #CRLF$
        EndIf
      Next
            
      ; Instantly pull tool back up to safe travel clearance at the end of each independent contour strip
      GCode + "G00 Z" + StrF(TravelZ, 3) + #CRLF$
    Next
    
    ; --- Write G-Code Footer ---
    GCode + "M05 ( Spindle OFF )" + #CRLF$
    GCode + "G00 X0 Y0 ( Return to Home Origin )" + #CRLF$
    GCode + "M30 ( End of Program )" + #CRLF$
    
    ProcedureReturn GCode
  EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
  ;- ==========================================================================
  ;- --- TEST PROCEDURES ---
  ;- ==========================================================================
  
  ; all Tests created bei Google Gemeni!
  #CanvasGadget = 0
  
  ; --- TEST 1: The Original Two-Buffer Layout (Static Demo) ---
  Procedure Test_OriginalBuffers(CanvasID.i, CanvasFont.i, Text$)
    Protected Hdc.i
    Protected SingleCharBuffer.Glyph::TGlyphContour
    Protected TextBuffer.Glyph::TGlyphContour
    Protected TempGlyph.Glyph::TGlyphData
    
    Hdc = StartDrawing(CanvasOutput(CanvasID))
    If Hdc
      DrawingFont(CanvasFont)
      
      ; Extract and smooth the first character of the string (Using 12 subdivisions)
      Glyph::ExtractGlyphOutline(Hdc, Asc(Left(Text$, 1)), @TempGlyph)
      Glyph::SmoothGlyphContour(@TempGlyph, @SingleCharBuffer, 12)
      
      ; Extract and smooth the entire string into the text buffer
      Glyph::SmoothTextContour(Hdc, Text$, @TextBuffer, 12)
      
      StopDrawing()
    EndIf
    
    If StartVectorDrawing(CanvasVectorOutput(CanvasID))
      VectorSourceColor(RGBA(245, 245, 245, 255)) ; Light gray background
      FillVectorOutput()
      
      ; Output 1: Single character placed at the top left
      Glyph::DrawGlyph(@SingleCharBuffer, 20.0, 170.0, 1.5, #False)
      
      ; Output 2: Complete text string placed below it
      Glyph::DrawGlyph(@TextBuffer, 20.0, 420.0, 1.2, #False)
      
      StopVectorDrawing()
    EndIf  
  EndProcedure


  ; --- TEST 2: Interactive Subdivision Mesh (Mouse-Wheel Demo) ---
  Procedure Test_InteractiveMesh(CanvasID.i, CanvasFont.i, Text$, SubDiv.i)
    Protected Hdc.i
    Protected TextBuffer.Glyph::TGlyphContour
    
    Hdc = StartDrawing(CanvasOutput(CanvasID))
    If Hdc
      DrawingFont(CanvasFont)
      Glyph::SmoothTextContour(Hdc, Text$, @TextBuffer, SubDiv)
      StopDrawing()
    EndIf
    
    If StartVectorDrawing(CanvasVectorOutput(CanvasID))
      ;VectorSourceColor(RGBA(245, 245, 245, 255)) ; Light gray background
      VectorSourceColor(RGBA(30, 30, 30, 255)) ; Dark background
      FillVectorOutput()
      
      ; 1. Draw solid vector outline path
      Glyph::DrawGlyph(@TextBuffer, 40.0, 250.0, 1.0, #False)
      
      ; 2. Render mathematical subdivision control points on top
      Glyph::DrawGlyph(@TextBuffer, 40.0, 250.0, 1.0, #True)
      
      ; Overlay Text Info Banner
      MovePathCursor(10, 10)
      VectorSourceColor(RGBA(255, 255, 255, 255))
      DrawVectorText("Subdivisions: " + Str(SubDiv) + "  [ Use Mouse-Wheel to change ]")
      
      StopVectorDrawing()
    EndIf  
  EndProcedure


  ; --- TEST 3: CNC Engraving Preview (Open Paths & G-Code String Output) ---
  Procedure Test_EngravingPreview(CanvasID.i, CanvasFont.i, Text$)
    Protected Hdc.i, IsFirstPoint.i
    Protected PtX.f, PtY.f
    Protected TextBuffer.Glyph::TGlyphContour
    Protected GCodeResult.s
    
    Hdc = StartDrawing(CanvasOutput(CanvasID))
    If Hdc
      DrawingFont(CanvasFont)
      ; Calculate the text vectors (8 subdivisions for smooth milling curves)
      Glyph::SmoothTextContour(Hdc, Text$, @TextBuffer, 8)
      StopDrawing()
    EndIf
    
    ; 1. Render the Engraving Toolpath Preview (Strictly as open lines)
    If StartVectorDrawing(CanvasVectorOutput(CanvasID))
      ;VectorSourceColor(RGBA(20, 25, 30, 255)) ; Safe dark metallic-alloy background
      VectorSourceColor(RGBA(245, 245, 245, 255)) ; Light gray background
      FillVectorOutput()
      
      SaveVectorState()
      TranslateCoordinates(40.0, 250.0)
      ScaleCoordinates(1.0, 1.0)
      FlipCoordinatesY(0.0) ; Invert Y back to standard Cartesian system
      
      ; Draw each contour without calling ClosePath()
      ForEach TextBuffer\Contour()
        IsFirstPoint = #True
        ForEach TextBuffer\Contour()\PathPoints()
          PtX = TextBuffer\Contour()\PathPoints()\x
          PtY = TextBuffer\Contour()\PathPoints()\y
          
          If IsFirstPoint
            MovePathCursor(PtX, PtY)
            IsFirstPoint = #False
          Else
            AddPathLine(PtX, PtY)
          EndIf
        Next
      Next
      
      ; Render as an orange engraving hairline path
      VectorSourceColor(RGBA(255, 128, 0, 255))
      StrokePath(0.8, #PB_Path_RoundEnd | #PB_Path_RoundCorner)
      
      RestoreVectorState()
      
      ; Small indicator text
      MovePathCursor(10, 20)
      VectorSourceColor(RGBA(0, 0, 0, 255))
      DrawVectorText("CNC Toolpath Preview (" + Text$ + ") - G-Code generated in Debug Window")
      
      StopVectorDrawing()
    EndIf
    
    ; 2. Generate the raw G-Code text string payload and stream it into the Debugger
    GCodeResult = Glyph::CreateGCodeString(@TextBuffer, Text$, 0.08, 1200, 400, 3.0, -0.3)
    Debug "==================== EXPORTED G-CODE STRING ===================="
    Debug GCodeResult
    Debug "================================================================"
  EndProcedure


  ; --- TEST 4: Generate G-Code and Copy Directly to Clipboard ---
  Procedure Test_CopyToClipboard(CanvasID.i, CanvasFont.i, Text$)
    Protected Hdc.i
    Protected TextBuffer.Glyph::TGlyphContour
    Protected GCodeResult.s
    
    Hdc = StartDrawing(CanvasOutput(CanvasID))
    If Hdc
      DrawingFont(CanvasFont)
      ; Calculates exactly the text passed from the main layout context
      Glyph::SmoothTextContour(Hdc, Text$, @TextBuffer, 8)
      StopDrawing()
    EndIf
    
    ; Generate G-Code string from buffer data
    GCodeResult = Glyph::CreateGCodeString(@TextBuffer, Text$, 0.08, 1200, 400, 3.0, -0.3)
    
    ; Copy the string directly to the OS Clipboard
    If GCodeResult <> ""
      SetClipboardText(GCodeResult)
      
      ; Update Canvas to notify the user
      If StartVectorDrawing(CanvasVectorOutput(CanvasID))
        VectorSourceColor(RGBA(34, 112, 63, 255)) ; Green success background
        FillVectorOutput()
        
        MovePathCursor(30, 200)
        VectorSourceColor(RGBA(255, 255, 255, 255))
        LoadFont(2, "Arial", 22, #PB_Font_Bold)
        VectorFont(FontID(2))
        DrawVectorText("SUCCESS: G-Code copied to Clipboard!")
        
        MovePathCursor(30, 250)
        LoadFont(3, "Arial", 14)
        VectorFont(FontID(3))
        DrawVectorText("Copied string for text: '" + Text$ + "'")
        
        MovePathCursor(30, 280)
        DrawVectorText("You can now paste it directly into your CNC editor (Ctrl + V).")
        
        StopVectorDrawing()
      EndIf
      
      Debug ">>> G-Code successfully pushed to OS Clipboard for: " + Text$ + " <<<"
    EndIf
  EndProcedure

  ;- ==========================================================================
  ;- --- MAIN PROGRAM APP LOOP ---
  ;- ==========================================================================
  Enumeration Gadgets
    #MainCanvas
    #BtnTest1
    #BtnTest2
    #BtnTest3
    #BtnTest4
  EndEnumeration
  
  Define Event.i, SelectedTest.i = 2 ; Startet direkt in Test 2 (Mesh)
  Define CanvasFont.i, SubDiv.i = 6
  Define GravurText$ = "CNC PUREBASIC" 
  
  If OpenWindow(0, 100, 100, 1020, 500, "Glyph CNC Module - 4 Isolated Test Routines", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    ; Erstellung der Gadgets mit eindeutigen Enumerations-IDs
    CanvasGadget(#MainCanvas, 10, 50, 1000, 440, #PB_Canvas_WheelDelta | #PB_Canvas_Keyboard)
    ButtonGadget(#BtnTest1, 10, 10, 120, 30, "Test 1: Static")
    ButtonGadget(#BtnTest2, 140, 10, 150, 30, "Test 2: Interactive Mesh")
    ButtonGadget(#BtnTest3, 300, 10, 160, 30, "Test 3: CNC Engraving")
    ButtonGadget(#BtnTest4, 470, 10, 180, 30, "Test 4: Copy to Clipboard")
    
    CanvasFont = LoadFont(0, "Georgia", 75, #PB_Font_Italic)
    
    ; Initialen Test ausführen
    Test_InteractiveMesh(#MainCanvas, CanvasFont, GravurText$, SubDiv)
    
    Repeat
      Event = WaitWindowEvent()
      
      If Event = #PB_Event_Gadget
        ; Flache und saubere Zuweisung wie im Hilfe-Beispiel
        Select EventGadget()
            
          Case #BtnTest1
            SelectedTest = 1 
            Test_OriginalBuffers(#MainCanvas, CanvasFont, GravurText$)
            
          Case #BtnTest2
            SelectedTest = 2 
            Test_InteractiveMesh(#MainCanvas, CanvasFont, GravurText$, SubDiv)
            
          Case #BtnTest3
            SelectedTest = 3 
            Test_EngravingPreview(#MainCanvas, CanvasFont, GravurText$)
            
          Case #BtnTest4
            SelectedTest = 4 
            Test_CopyToClipboard(#MainCanvas, CanvasFont, GravurText$)
            
          Case #MainCanvas
            ; Abfrage der Event-Typen für das Canvas (exakt wie im Hilfe-Beispiel)
            If SelectedTest = 2
              
              ; Automatischen Fokus setzen, wenn die Maus das Canvas betritt
              If EventType() = #PB_EventType_MouseEnter
                SetActiveGadget(#MainCanvas)
              EndIf
              
              ; Mausrad detektieren
              If EventType() = #PB_EventType_MouseWheel
                SubDiv + GetGadgetAttribute(#MainCanvas, #PB_Canvas_WheelDelta)
                
                ; Grenzen schützen
                If SubDiv < 0 : SubDiv = 0 : EndIf
                If SubDiv > 30 : SubDiv = 30 : EndIf
                
                ; Live neu rendern
                Test_InteractiveMesh(#MainCanvas, CanvasFont, GravurText$, SubDiv)
              EndIf
            EndIf
            
        EndSelect
      EndIf
      
    Until Event = #PB_Event_CloseWindow
  EndIf
CompilerEndIf

End



; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 28
; Folding = ---
; DPIAware
; CPU = 5