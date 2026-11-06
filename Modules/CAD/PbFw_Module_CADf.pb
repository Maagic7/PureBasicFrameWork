; ===========================================================================
; FILE : PbFw_Module_CADf.pb
; NAME : 2D CAD Geometry Engine [CADf::]
; DESC : Single precision float 2D CAD Geometry, 
; DESC : Snapping and DRC Core
; DESC : For double precision CAD Geometry use [CADd::]
; SOURCES:
;   Computational Geometry in C - Joseph O'Rourke
;   https://github.com/w8r/orourke-compc/blob/master/
;
;   John Burkardt, Florida State University - Department of Scientific Computing
;   https://people.sc.fsu.edu/~jburkardt/
; ===========================================================================

;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/07/30
; VERSION  :  0.5 Develper Version
; COMPILER :  PureBasic 6.0+
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 

; 2026/11/03 S.Maag : added a lot of missing functions with AI Assistance
;                     AI generated Test and Demo App
; 2025/12/03 S.Maag : implemented some functions
; 2024/09/08 S.Maag : added new Module local configurations 
; 
;} 
;{ TODO:
; 
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "..\PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "..\PbFw_Module_PX.pb"           ; PX::       Purebasic Extention Module
XIncludeFile "..\PbFw_Module_Debug.pb"        ; DBG::      Debug Module
XIncludeFile "..\Math\PbFw_Module_VECTORf.pb" ; VECf::     single precicion Vector Module

;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule CADf
  
  EnableExplicit
   
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
  
  UseModule VECf
  
  ; TPoint2D is from VectorModule VECf::TPoint2D
  
  Structure TTriPara  ; Triangle Parameter
    S.f         ; Area, Surface
    P.f         ; Perimeter, lenght of closed path = a+b+c
    Q.f         ; Qualtiy of the triangle
    a.f         ; Lenght side a
    b.f         ; Lenght side b
    c.f         ; Lenght side c
    Ri.f        ; Radius inner circle
    Ro.f        ; Raduus outside circle
    alpha.f     ; Angle alpha [radian]
    beta.f      ; Angle beta  [radian]
    gamma.f     ; Angle gamma [radian]
    dir.i       ; direction -1 := CW (ClockWise) / 0 := collinear points / 1 := CCW (CounterClockWise)
  EndStructure
  
  ; ----------------------------------------------------------------------
  ; PHYSICAL LAYER OBJECT STRUCTURES
  ; ----------------------------------------------------------------------
  
  ; Represents a physical pin, via anchor, or schematic junction node
  Structure TPin
    Id.i          ; Unique identifier for netlist binding
    Pos.TPoint2D  ; Absolute world coordinate position
    Layer.i       ; PCB Layer (e.g., #Layer_Top, #Layer_Bottom)
    DrillRadius.f ; Inner hole size (0.0 for SMD pads)
    OuterRadius.f ; Copper diameter boundary
  EndStructure
  
  ; Represents a real, physical routed trace (Track) on the board or layout
  Structure TTrack
    Id.i          ; Unique identifier for DRC flagging
    NetId.i       ; Electrical net association (e.g., GND, VCC, Signal_1)
    PtA.TPoint2D  ; Start coordinate of the track centerline
    PtB.TPoint2D  ; End coordinate of the track centerline
    Width.f       ; Physical copper width/thickness of the trace
    Layer.i       ; Active routing layer
  EndStructure
  
  Structure TTrackPolygon
    Vertex.TPoint2D[4] ; The 4 absolute corner points of the thick track boundary
  EndStructure

  
  ; Point Functions
  ; Rotate a point around a rotation center by a given angle (in radians)
  Declare.i Point_Rotate(*OutPt.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, Angle.f)
  
  ; Mirror a point across an axis defined by two points
  Declare.i Point_Mirror(*OutPt.TPoint2D, *Pt.TPoint2D, *AxisPtA.TPoint2D, *AxisPtB.TPoint2D)

  ; Line functions
  Declare.i Collinear(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Line_Length(*LPtA.TPoint2D, *LPtB.TPoint2D)
  Declare.f Line_PointDistance(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
  ; Find the nearest point on a finite line segment (e.g. track) to a given test point
  Declare.i Line_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
  Declare.i Line_Intersection(*out.TPoint2D, *L1PtA.TPoint2D, *L1PtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D)  
  ; Check if two finite line segments (e.g. tracks) intersect. Returns #True/#False and intersection point via *OutPt.
  Declare.i LineSegments_Intersect(*OutPt.TPoint2D, *L1PtA.TPoint2D, *L1PtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D)
  ; Calculate a parallel offset line from a given line segment by a specific distance
  Declare.i Line_Offset(*OutLPtA.TPoint2D, *OutLPtB.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D, Distance.f)
  
  Declare.i FindOppositeInnerIntersection(*OuterPt.TPoint2D, *Normal.TPoint2D, *SegA.TPoint2D, *SegB.TPoint2D, *BestHit.TPoint2D)

  ; Rectangle functions (High-speed bounding box operations)
  Declare.i Rect_IsPointInside(*Pt.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
  Declare.i Rect_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
  Declare.f Rect_PointDistance(*Pt.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
  ; Rectangle circle utilities (Returns radius directly, center coordinates via *OutPtCenter)
  Declare.f Rect_CircumCircle(*OutPtCenter.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
  Declare.f Rect_InCircle(*OutPtCenter.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)

  ; Triangle functions
  Declare.f Triangel_Perimeter(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_Angles(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *outAngles.TVector)
  Declare.f Triangle_Area(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_Center(*OutPt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  ; Calculate the circumcircle of a triangle. Returns the radius directly, center via *OutPtCenter.
  Declare.f Triangle_CircumCircle(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPtCenter.TPoint2D)
  ; Calculate the incircle of a triangle. Returns the radius directly, center via *OutPtCenter.
  Declare.f Triangle_InCircle(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPtCenter.TPoint2D)
  Declare.i Triangle_Edges(*out.TVector, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Triangle_PointDistance(*Pt.TPoint2D, *PtA.TPoint2D, *TP2.TPoint2D, *TP3.TPoint2D)
  ; Triangle functions (Direction-validated point checks)
  Declare.i Triangle_IsPointInside(*Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, Clockwise.i = #False)
  Declare.i Triangle_IsPointInsideCW(*Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_IsPointInsideCCW(*Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  ; Triangle orientation evaluation (-1 = CW, 0 = Collinear, 1 = CCW)
  Declare.i Triangle_GetOrientation(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)  
  ; Force a triangle into Counter-Clockwise (CCW) orientation
  Declare.i Triangle_SetCCW(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  ; Calculate the 3D surface normal vector of a CCW triangle
  Declare.i Triangle_GetNormal(*OutNormal.TVector, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)

  Declare.f Triangle_Quality(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  
  ; Polygon functions
  Declare.f Polygon_Perimeter(List PolyPts.TPoint2D())
  Declare.i Polygon_Angles(List lstOutAngles.f(), List PolyPts.TPoint2D())
  Declare.f Polygon_Area(List PolyPts.TPoint2D())
  Declare.i Polygon_Center(*OutPt.TPoint2D, List PolyPts.TPoint2D())
  Declare.f Polygon_Radius(*PtA.TPoint2D, List PolyPts.TPoint2D())
  Declare.f Polygon_RadiusIn(List PolyPts.TPoint2D())
  Declare.i Polygon_Edges(Array OutEdges.f(1), List PolyPts.TPoint2D())
  Declare.i Polygon_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, List PolyPts.TPoint2D())
  Declare.f Polygon_PointDistance(*Pt.TPoint2D, List PolyPts.TPoint2D())
  Declare.i Polygon_IsPointInside(*Pt.TPoint2D, List PolyPts.TPoint2D())
  
  ; Circle functions
  Declare.f Circle_Perimeter(Radius.f)
  Declare.f Circle_Area(Radius.f)
  Declare.i Circle_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
  Declare.f Circle_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
  Declare.i Circle_IsPointInside(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
  Declare.i Circle_TangentToPoint(*OutT1.TPoint2D, *OutT2.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, Radius.f)
  
  ; CircleSector functions
  Declare.f CircleSector_Perimeter(Radius.f, Angle.f)
  Declare.f CircleSector_Area(Radius.f, Angle.f)
  ; Find the nearest point on a circle sector to a given test point
  Declare.i CircleSector_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
  ; Calculate the minimum distance between a point and a circle sector boundary
  Declare.f CircleSector_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
   ; Check if a point is inside a circle sector wedge
  Declare.i CircleSector_IsPointInside(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
  
  ; Find the nearest point on a finite circular arc to a given test point
  Declare.i Arc_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
  ; Calculate the minimum distance between a point and a circular arc boundary
  Declare.f Arc_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)

  ; Ellipse functions
  Declare.f Ellipse_Perimeter(R1.f, R2.f)
  Declare.f Ellipse_Area(R1.f, R2.f)
  Declare.i Ellipse_PointNear(R1.f, R2.f, *Pt.TPoint2D, *PtOut.TPoint2D)
  Declare.f Ellipse_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
  Declare.i Ellipse_IsPointInside(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
  Declare.i Ellipse_TangentToPoint(*OutT1.TPoint2D, *OutT2.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, R1.f, R2.f)
  
  ; EllipseSector functions
  ; Calculate the perimeter of an ellipse sector (including the two linear radii and the arc)
  Declare.f EllipseSector_Perimeter(R1.f, R2.f, StartAngle.f, SweepAngle.f)
  ; Calculate the area of an ellipse sector (angles in radians)
  Declare.f EllipseSector_Area(R1.f, R2.f, StartAngle.f, SweepAngle.f)
  ; Find the nearest point on an ellipse sector to a given test point (angles in radians)
  Declare.i EllipseSector_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
  ; Calculate the minimum distance between a point and an ellipse sector boundary
  Declare.f EllipseSector_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
  ; Check if a point is inside an ellipse sector wedge (angles in radians)
  Declare.i EllipseSector_IsPointInside(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
  
  ; Find the nearest point on a finite elliptic arc to a given test point (angles in radians)
  Declare.i EllipseArc_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
  
  ; Calculate the minimum distance between a point and an elliptic arc boundary
  Declare.f EllipseArc_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
  
  ; Capsule / Oval Slot functions (Core line segment expanded by a specific radius)
  Declare.i Capsule_IsPointInside(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D, Radius.f)
  Declare.i Capsule_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D, Radius.f)
  Declare.f Capsule_PointDistance(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D, Radius.f)
  
  ; Donut / Annulus functions (Circular ring with a hollow interior hole)
  Declare.i Donut_IsPointInside(*Pt.TPoint2D, *CenterPt.TPoint2D, RadiusIn.f, RadiusOut.f)
  Declare.i Donut_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, RadiusIn.f, RadiusOut.f)
  Declare.f Donut_PointDistance(*Pt.TPoint2D, *CenterPt.TPoint2D, RadiusIn.f, RadiusOut.f)
  
    ; Snap the cursor precisely to the outer physical edge of a thick track
  Declare.i Track_SnapToEdge(*OutPt.TPoint2D, *Pt.TPoint2D, *Track.TTrack)
  
  ; Constrain a dynamic target point to perfect 45 or 90 degree angles relative to a start anchor
  Declare.i Track_Constraint45(*OutPt.TPoint2D, *StartPt.TPoint2D, *MousePt.TPoint2D)

EndDeclareModule

Module CADf
  
  EnableExplicit
  UseModule VECf
  
  ;- ----------------------------------------------------------------------
  ;- PbFw Module local configurations
  ;  ----------------------------------------------------------------------
  ; This constants must have same Name in all Modules
  
  ; ATTENTION: with the PbFw::CONST Macro the PB-IDE Intellisense do not registrate the ConstantName
  
  ; #PbFwCfg_Module_CheckPointerException = #True     ; On/Off PoninterExeption for this Module
  PbFw::CONST(PbFwCfg_Module_CheckPointerException, #True)
  
  ;#PbFwCfg_Module_ASM_Enable = #True                ; On/Off Assembler Versions when compling in ASM Backend
  PbFw::CONST(PbFwCfg_Module_ASM_Enable, #True)
 
  ; -----------------------------------------------------------------------
      
  ; ************************************************************************
  ; PbFw::mac_CompilerModeSettting      ; using Macro for CompilerSetting is a problem for the IDE
  ; so better use the MacroCode directly
  ; Do not change! Must be changed globaly in PbFw:: and then copied to each Module
  Enumeration
    #PbFwCfg_Module_Compile_Classic                 ; use Classic PB Code
    #PbFwCfg_Module_Compile_ASM32                   ; x32 Bit Assembler
    #PbFwCfg_Module_Compile_ASM64                   ; x64 Bit Assembler
    #PbFwCfg_Module_Compile_C                       ; use optimations for C-Backend
  EndEnumeration
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm And #PbFwCfg_Module_ASM_Enable And PbFw::#PbFwCfg_Global_ASM_Enable 
    ; A S M   B A C K E N D
    CompilerIf #PB_Compiler_32Bit
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM32     
    ; **********  64 BIT  **********
    CompilerElseIf #PB_Compiler_64Bit
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM64     
    ; **********  Classic Code  **********
    CompilerElse
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
    CompilerEndIf
      
  CompilerElseIf  #PB_Compiler_Backend = #PB_Backend_C
    ;  C - B A C K E N D
     #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_C     
  CompilerElse
    Debug "Classic" 
    ;  To force Classic Code Compilation
    #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
  CompilerEndIf 
  
  ; ************************************************************************
  ;Debug "PbFwCfg_Module_Compile = " + #PbFwCfg_Module_Compile
  
  ; ----------------------------------------------------------------------
  
  PbFw::ListModule(#PB_Compiler_Module)   ; Lists the Module in the ModuleList (for statistics)
    
  ;- ----------------------------------------------------------------------
  ;- Module Private
  ;- ----------------------------------------------------------------------
  
  Macro _macPythagoras(A, B)
    Sqr((A*A + B*B))  
  EndMacro
  
  Macro _mac_Triangle_Area(P1, P2, P3)
    (( (P2\X - P1\X) * (P3\Y - P1\Y) - (P3\X - P1\X) * (P2\Y - P1\Y) ) *0.5) 
  EndMacro
  
  ; now use fixed Epsilon! Ignore _val
  Macro _Epsilon(_val=1)
    PX::#PX_EpsilonF
  EndMacro   
  
  ;- ----------------------------------------------------------------------
  ;- Point Functions
  ;- ----------------------------------------------------------------------
 
  Procedure.i Point_Rotate(*OutPt.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, Angle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. COMPONENT ROTATION & FOOTPRINT ORIENTATION:
    ;    The foundational matrix transformation tool for rotating component symbols, 
    ;    footprints, text labels, and structural blocks around a specified anchor point. 
    ;    Essential for handling standard layout operations like 90-degree component 
    ;    swaps or matching precise angular placement constraints on a schematic sheet.
    ;
    ; 2. POLAR COORDINATE PATTERN GENERATION:
    ;    Used to easily generate uniform radial arrays of layout elements, such as 
    ;    circular LED grids, multi-pin circular connectors, rotary switch contacts, 
    ;    or radial architectural support columns, by rotating a single base element 
    ;    iteratively by a constant angle step.
    ; ===========================================================================
    Protected.f CosA, SinA, dx, dy
    
    ; Cache trigonometric calculations to optimize speed
    CosA = Cos(Angle)
    SinA = Sin(Angle)
    
    ; Translate point relative to the rotation center
    dx = *Pt\x - *CenterPt\x
    dy = *Pt\y - *CenterPt\y
    
    ; Apply 2D rotation matrix rotation and translate back to absolute world coordinates
    *OutPt\x = *CenterPt\x + (dx * CosA - dy * SinA)
    *OutPt\y = *CenterPt\y + (dx * SinA + dy * CosA)
    
    ProcedureReturn #True
  EndProcedure

  Procedure.i Point_Mirror(*OutPt.TPoint2D, *Pt.TPoint2D, *AxisPtA.TPoint2D, *AxisPtB.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ASYMMETRICAL BLOCK FLIPPING & MULTI-LAYER TRANSFORMS:
    ;    The core mathematical engine for mirroring sub-circuits, footprints, or 
    ;    architectural wall arrangements across a custom axis line. Essential for 
    ;    flipping layout assets when moving components from the top layer to the 
    ;    bottom layer of a PCB or creating mirrored room groupings in floor plans.
    ;
    ; 2. SYMMETRICAL INTERACTIVE SKETCHING:
    ;    Enables live symmetrical drawing modes. As the operator digitizes lines, 
    ;    tracks, or silkscreen artwork on one side of a user-defined reflection axis, 
    ;    this procedure instantly projects the mirrored duplicate nodes in real-time, 
    ;    ensuring perfect geometric symmetry.
    ; ===========================================================================
    
    Protected.f dx, dy, axisLenSq, t, projX, projY
    
    ; Direction vector of the mirroring axis line
    dx = *AxisPtB\x - *AxisPtA\x
    dy = *AxisPtB\y - *AxisPtA\y
    
    axisLenSq = dx * dx + dy * dy
    
    ; Handle degenerate case where the axis points overlap (axis line is just a point)
    If axisLenSq = 0.0
      ; Mirror directly across the single point AxisPtA
      *OutPt\x = 2.0 * *AxisPtA\x - *Pt\x
      *OutPt\y = 2.0 * *AxisPtA\y - *Pt\y
      ProcedureReturn #True
    EndIf
    
    ; Project the test point *Pt onto the infinite axis line using dot product division
    t = ((*Pt\x - *AxisPtA\x) * dx + (*Pt\y - *AxisPtA\y) * dy) / axisLenSq
    
    ; Calculate the projection base coordinates (nearest point on the axis)
    projX = *AxisPtA\x + t * dx
    projY = *AxisPtA\y + t * dy
    
    ; The mirrored point is twice the distance from the original point to its projection on the axis
    *OutPt\x = 2.0 * projX - *Pt\x
    *OutPt\y = 2.0 * projY - *Pt\y
    
    ProcedureReturn #True
  EndProcedure
 
  ;- ----------------------------------------------------------------------
  ;- Line Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.i Collinear(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. DEGENERATE GEOMETRY FILTERING & CLEANUP:
    ;    Acts as the primary safety gate for numerical algorithms. It checks if 
    ;    three consecutive vertices lie exactly on a straight line, identifying 
    ;    redundant nodes in custom copper polygons or architectural wall chains. 
    ;    Filtering these out prevents division-by-zero crashes in advanced 
    ;    triangulation, area, and center calculations.
    ;
    ; 2. OVERLAPPING TRACK & WIRE SNAP SANITIZATION:
    ;    Used during interactive layout routing to detect if a new connection 
    ;    node lies directly along the path of an existing linear segment. This 
    ;    allows the routing engine to smoothly merge separate trace segments 
    ;    into a single continuous wire entity instead of creating messy stacked tracks.
    ; ===========================================================================
    
    ;Reference:
    ;Joseph O'Rourke,
    ;Computational Geometry in C,    
    ;collinear ( xa, ya, xb, yb, xc, yc ) : AllPointsOnLine?
    
    Protected.f side_sq, side_max_sq, area, dx, dy
    Protected.i ret
    
    #_r8_eps = _Epsilon()
    
    ;area = 0.5 * ( (xb - xa) * (yc - ya )  - ( xc - xa ) * ( yb - ya ) )
    area = _mac_Triangle_Area(*PtA, *PtB, *PtC)
     
    ;side_ab_sq = (xa - xb) ** 2 + (ya - yb) ** 2
    dx = *PtA\X - *PtB\X : dy = *PtA\Y - *PtB\Y
    side_max_sq = dx*dx + dy*dy
    
    ;side_bc_sq = (xb - xc) ** 2 + (yb - yc) ** 2
    dx = *PtB\X - *PtC\X : dy = *PtB\Y - *PtC\Y
    side_sq = dx*dx + dy*dy
    
    If side_sq > side_max_sq
      side_max_sq = side_sq
    EndIf
    
    ;side_ca_sq = (xc - xa) ** 2 + (yc - ya) ** 2
    dx = *PtC\X - *PtA\X : dy = *PtC\Y - *PtA\Y
    side_sq = dx*dx + dy*dy
    
    If side_sq > side_max_sq
      side_max_sq = side_sq     ; here we get Max(side_ab_sq, side_bc_sq, side_ca_sq)
    EndIf        
    ;side_max_sq = max ( side_ab_sq, max ( side_bc_sq, side_ca_sq ) )
   
    ; If ( side_max_sq <= r8_eps ) then
    ;   ret = #True
    ; Else If ( 2.0D+00 * Abs ( area ) <= r8_eps * side_max_sq ) then
    ;   ret = #True
    ; Else
    ;   ret = #False
    ; End If
    
    If side_max_sq <= #_r8_eps
      ret = #True
    ElseIf (Abs(area)*2) <= (#_r8_eps * side_max_sq)
      ret = #True
    EndIf
    
    ProcedureReturn ret
  EndProcedure

  ; TPoint2D is from VectorModule VECf::TPoint2D
  Procedure.f Line_Length(*LPtA.TPoint2D, *LPtB.TPoint2D)
  ; ===========================================================================
  ; CAD APPLICATION CONTEXT & USAGE:
  ; ===========================================================================
  ; 1. LENGTH REGULATION & EQUALIZATION:
  ;    Essential for checking total copper track lengths. High-speed signals 
  ;    (like DDR memory buses or differential pairs) require length matching 
  ;    to prevent propagation delay (skew).
  ;
  ; 2. DIMENSIONING & MEASUREMENT TOOLS:
  ;    Used as the core engine for dynamic measurement overlay graphics, HUDs, 
  ;    and auto-generated dimension lines displayed when dragging components.
  ; ===========================================================================
    Protected.f dx, dy
    dx= *LPtA\X - *LPtB\X  : dy= *LPtA\Y - *LPtB\Y
    ProcedureReturn Sqr(dx*dx + dy*dy)
  EndProcedure
    
  Procedure.f Line_PointDistance(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
  ; ===========================================================================
  ; CAD APPLICATION CONTEXT & USAGE:
  ; ===========================================================================
  ; 1. ON-THE-FLY HIGHLIGHTING & HOVER DETECTION:
  ;    Used continuously inside the mouse-move event loop to determine if the 
  ;    cursor is floating near an infinite reference grid line, allowing the 
  ;    UI to highlight or activate selection outlines.
  ;
  ; 2. REFERENCE AXIS DISTANCE:
  ;    Calculates the exact space between an absolute schematic alignment axis 
  ;    and a newly placed component anchor to enforce grid spacing metrics.
  ; ===========================================================================
    Protected.f dx, dy, pvx, pvy, m
    
    ; distances 
    dx = *LPtB\x - *LPtA\x    ; LineWidth
    dy = *LPtB\y - *LPtA\y    ; LineHeight
    pvx = *Pt\x - *LPtA\x     ; Point to LPtA X
    pvy = *Pt\y - *LPtA\y     ; Point to LPtA y
  
    ; Normalize
    m = Sqr(dx*dx + dy*dy)
    
    If (m > 0.0) 
      dx / m
      dy / m
    Else
      ProcedureReturn 0.0     ; Point is on the Line
    EndIf
      
    ; Get dot product (project pv onto normalized direction)
    m = dx * pvx + dy * pvy; 
    ; Scale line direction vector and subtract it from pv
    pvx = pvx - m * dx
    pvy = pvy - m * dy
  
    ProcedureReturn Sqr(pvx * pvx + pvy * pvy)
  EndProcedure
  
  Procedure.i Line_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
  ; ===========================================================================
  ; CAD APPLICATION CONTEXT & USAGE:
  ; ===========================================================================
  ; 1. MAGNET SNAPPING: 
  ;    To implement a magnetic snap-to-track feature, call this procedure 
  ;    with the current mouse position as *Pt. Then, measure the distance 
  ;    between the mouse and the calculated *OutPt. If the distance is within 
  ;    your snapping threshold (e.g., 5 pixels), visually lock the cursor 
  ;    directly onto the *OutPt coordinates.
  ;
  ; 2. T-JUNCTIONS & ROUTING:
  ;    When a user wants to connect a new copper track at a perfect 90-degree 
  ;    angle to an existing track, this function immediately delivers the 
  ;    exact perpendicular intersection target destination on the target segment.
  ; ===========================================================================
    Protected.f dx, dy, segLenSq, t
    
    ; Clear output coordinates to prevent corrupt data on failure
    *OutPt\x = 0.0
    *OutPt\y = 0.0
    
    ; Calculate the direction vector of the line segment
    dx = *LPtB\x - *LPtA\x
    dy = *LPtB\y - *LPtA\y
    
    ; Calculate the squared length of the segment to avoid an expensive Sqr() here
    segLenSq = dx * dx + dy * dy
    
    ; Handle edge case where the line segment has zero length (points overlap)
    If segLenSq = 0.0
      *OutPt\x = *LPtA\x
      *OutPt\y = *LPtA\y
      ProcedureReturn #True
    EndIf
    
    ; Calculate the projection factor 't' along the line segment using the dot product
    t = ((*Pt\x - *LPtA\x) * dx + (*Pt\y - *LPtA\y) * dy) / segLenSq
    
    ; Clamp 't' strictly to the range [0.0 ... 1.0] to stay within the finite segment boundaries.
    ; Without this clamping, it would calculate the nearest point on an infinite line.
    If t < 0.0
      t = 0.0
    ElseIf t > 1.0
      t = 1.0
    EndIf
    
    ; Compute the absolute world coordinates of the nearest point
    *OutPt\x = *LPtA\x + t * dx
    *OutPt\y = *LPtA\y + t * dy
    
    ProcedureReturn #True
  EndProcedure
    
  ; Hilfslinien oder Bemaßungs-Fluchtlinien zu schneiden, die unendlich im Raum verlaufen.         
  Procedure.i Line_Intersection(*out.TPoint2D, *L1PtA.TPoint2D, *L1PtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D)
  ; ============================================================================
  ; NAME: Line_Intersection
  ; DESC: Calculates the intersection point of 2 Lines
  ; VAR(*out.TPoint2D) : Pointer to Return-VPoint VECf::TPoint2D
  ; VAR(*L1PtA.TPoint2D): Pointer to Line 1 StartPoint VECf::TPoint2D
  ; VAR(*LPtB.TPoint2D)  : Pointer to Line 1 EndPoint   VECf::TPoint2D  
  ; VAR(*L2PtA.TPoint2D): Pointer to Line 2 StartPoint VECf::TPoint2D
  ; VAR(*L2PtB.TPoint2D)  : Pointer to Line 2 EndPoint   VECf::TPoint2D  
  ; RET.i : #False, if lines are parallel : #True, if lines intersect
  ; ============================================================================
    
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ALIGNMENT GUIDE LINE GENERATION:
    ;    Used when projecting infinite architectural reference lines, snap grids, 
    ;    or schematic alignment rays to compute virtual intersection points where 
    ;    two construction guides would theoretically meet.
    ;
    ; 2. EXTENSION LINE BEMAßUNG (DIMENSIONING):
    ;    Determines projectable reference anchors when calculating where 
    ;    dimension extension lines intersect outer drawing borders.
    ; ===========================================================================

    Protected.f A1, B1, C1
    Protected.f A2, B2, C2
    Protected.f Denominator
    
    ; Clear output coordinates
    *out\x = 0.0
    *out\y = 0.0
    
    ; Line 1 representation: A1*x + B1*y = C1
    A1 = *L1PtB\y - *L1PtA\y
    B1 = *L1PtA\x - *L1PtB\x
    C1 = A1 * *L1PtA\x + B1 * *L1PtA\y
    
    ; Line 2 representation: A2*x + B2*y = C2
    A2 = *L2PtB\y - *L2PtA\y
    B2 = *L2PtA\x - *L2PtB\x
    C2 = A2 * *L2PtA\x + B2 * *L2PtA\y
    
    ; Calculate the determinant (denominator)
    Denominator = A1 * B2 - A2 * B1
    
    ; If denominator is 0, the lines are parallel or collinear
    If Denominator = 0.0
      *out\x = NaN()
      *out\y = NaN()
      ProcedureReturn #False
    EndIf
    
    ; Apply Cramer's Rule to find the exact intersection point
    *out\x = (B2 * C1 - B1 * C2) / Denominator
    *out\y = (A1 * C2 - A2 * C1) / Denominator
    
    ProcedureReturn #True
  EndProcedure
  
  ; LineSegments_Intersect, um zu prüfen, ob zwei reale Leiterbahnen (mit fixem Anfang und Ende) einander real berühren oder kreuzen 
  Procedure.i LineSegments_Intersect(*OutPt.TPoint2D, *L1PtA.TPoint2D, *L1PtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D)
    
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. DESIGN RULE CHECK (DRC) - SHORT CIRCUIT DETECTOR:
    ;    The primary mathematical firewall for electrical clearance checking. It 
    ;    scans all finite net tracks to detect unauthorized overlapping segments, 
    ;    instantly flagging physical shorts and unwanted electrical connections.
    ;
    ; 2. NETLIST EXTRACTION / VIA TOUCH DOWN:
    ;    Verifies if a newly routed trace successfully bridges or touches an 
    ;    existing track segment on the same layer to dynamically group them into 
    ;    the same copper net structure.
    ; ===========================================================================
    
    Protected.f cp1, cp2, cp3, cp4
    Protected.f num, denom, t
    
    ; Clear output coordinates
    *OutPt\x = 0.0
    *OutPt\y = 0.0
    
    ; Step 1: Winding order / orientation checks using 2D cross products
    ; Check if the endpoints of segment 2 lie on opposite sides of segment 1
    cp1 = (*L1PtB\x - *L1PtA\x) * (*L2PtA\y - *L1PtA\y) - (*L1PtB\y - *L1PtA\y) * (*L2PtA\x - *L1PtA\x)
    cp2 = (*L1PtB\x - *L1PtA\x) * (*L2PtB\y - *L1PtA\y) - (*L1PtB\y - *L1PtA\y) * (*L2PtB\x - *L1PtA\x)
    
    ; Check if the endpoints of segment 1 lie on opposite sides of segment 2
    cp3 = (*L2PtB\x - *L2PtA\x) * (*L1PtA\y - *L2PtA\y) - (*L2PtB\y - *L2PtA\y) * (*L1PtA\x - *L2PtA\x)
    cp4 = (*L2PtB\x - *L2PtA\x) * (*L1PtB\y - *L2PtA\y) - (*L2PtB\y - *L2PtA\y) * (*L1PtB\x - *L2PtA\x)
    
    ; If the signs of the cross products are the same, the segments do not intersect
    If ((cp1 > 0.0 And cp2 > 0.0) Or (cp1 < 0.0 And cp2 < 0.0))
      ProcedureReturn #False
    EndIf
    
    If ((cp3 > 0.0 And cp4 > 0.0) Or (cp3 < 0.0 And cp4 < 0.0))
      ProcedureReturn #False
    EndIf
    
    ; Step 2: Lines are crossing, now compute the exact intersection coordinates
    denom = (*L1PtA\x - *L1PtB\x) * (*L2PtA\y - *L2PtB\y) - (*L1PtA\y - *L1PtB\y) * (*L2PtA\x - *L2PtB\x)
    
    ; Prevent division by zero if lines are perfectly parallel/collinear
    If denom = 0.0
      ProcedureReturn #False
    EndIf
    
    num = (*L1PtA\x - *L2PtA\x) * (*L2PtA\y - *L2PtB\y) - (*L1PtA\y - *L2PtA\y) * (*L2PtA\x - *L2PtB\x)
    t = num / denom
    
    ; Calculate the absolute intersection coordinate point
    *OutPt\x = *L1PtA\x + t * (*L1PtB\x - *L1PtA\x)
    *OutPt\y = *L1PtA\y + t * (*L1PtB\y - *L1PtA\y)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i Line_Offset(*OutLPtA.TPoint2D, *OutLPtB.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D, Distance.f)
    
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. DIFFERENTIAL PAIR ROUTING (BUS ROUTING):
    ;    Crucial for high-speed differential signal traces (e.g., USB, Ethernet, 
    ;    PCIe). When the user draws the primary trace, this function calculates 
    ;    the exact companion path at a constant clearance distance to maintain impedance.
    ;
    ; 2. COPPER TRACK BORDER GENERATION:
    ;    Converts a single zero-width logical trace path into a thick solid physical 
    ;    polygon by generating parallel outer boundaries based on half the target 
    ;    trace width setting.
    ; ===========================================================================
    
    Protected.f dx, dy, length, nx, ny
    
    ; Clear output structures to prevent corrupt data on failure
    *OutLPtA\x = 0.0 : *OutLPtA\y = 0.0
    *OutLPtB\x = 0.0 : *OutLPtB\y = 0.0
    
    ; Calculate the direction vector of the original line segment
    dx = *LPtB\x - *LPtA\x
    dy = *LPtB\y - *LPtA\y
    
    ; Calculate the length of the segment
    length = Sqr(dx*dx + dy*dy)
    
    ; Prevent calculation if the line segment has no length (points overlap)
    If length = 0.0
      ProcedureReturn #False
    EndIf
    
    ; Calculate the perpendicular normal vector pointing to the right side of the line direction
    ; For a line going up, the right normal points to the right (nx = dy/len, ny = -dx/len)
    nx = dy / length
    ny = -dx / length
    
    ; Apply the distance scaling to the normal vector and translate both endpoints
    *OutLPtA\x = *LPtA\x + nx * Distance
    *OutLPtA\y = *LPtA\y + ny * Distance
    
    *OutLPtB\x = *LPtB\x + nx * Distance
    *OutLPtB\y = *LPtB\y + ny * Distance
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i FindOppositeInnerIntersection(*OuterPt.TPoint2D, *Normal.TPoint2D, *SegA.TPoint2D, *SegB.TPoint2D, *BestHit.TPoint2D)
  ; ======================================================================
  ; NAME: FindOppositeInnerIntersection
  ; DESC: Uses LineSegments_Intersect to find the closest valid wall intersection on the inner structure
  ; VAR(*OuterPt.TPoint2D): The outer control point acting as the ray origin
  ; VAR(*Normal.TPoint2D): The inward-pointing normal vector for the ray direction
  ; VAR(*SegA.TPoint2D): Start point of the inner structure line segment
  ; VAR(*SegB.TPoint2D): End point of the inner structure line segment
  ; VAR(*BestHit.TPoint2D): Pointer to store the closest valid intersection coordinates
  ; RET.i: #True if a valid intersection occurs on the actual segment in ray-direction
  ; ======================================================================
    
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. MEDIAL AXIS SKELETONIZATION / TOOLPATH GENERATION:
    ;    Acts as the geometric foundation for centerline extraction inside complex, 
    ;    closed vector paths. It projects inward-facing normal rays from the outer 
    ;    boundary to compute the exact geometric median path. This is heavily used 
    ;    in CAM toolpath planning for single-line engraving, laser tracking, and 
    ;    equidistant CNC drilling layouts.
    ;
    ; 2. ISOLATION ROUTING & CLEARANCE VERIFICATION:
    ;    Enables high-speed width-verification across dual-walled trace hulls 
    ;    (such as specialized RF shielding corridors, differential pairs, or 
    ;    copper pour neckdowns). By mapping opposing wall intersections, the system 
    ;    instantly flags structural bottlenecks where the physical width falls 
    ;    below manufacturing DRC clearance limits.
    ; ===========================================================================
    Protected.TPoint2D RayEnd, Hit
    Protected.f dot
    
    ; 1. Erzeuge ein langes virtuelles Segment in Richtung der Senkrechten
    ;    100000.0 Einheiten reichen bei Schriften völlig aus, um die Innenwand sicher zu durchstoßen
    RayEnd\x = *OuterPt\x + *Normal\x * 100000.0 
    RayEnd\y = *OuterPt\y + *Normal\y * 100000.0
    
    ; 2. Nutze Ihre existierende DRC-Funktion für die Segment-Kreuzung
    If LineSegments_Intersect(@Hit, *OuterPt, @RayEnd, *SegA, *SegB)
      
      ; 3. Da LineSegments_Intersect bereits garantiert, dass der Punkt AUF dem inneren 
      ;    Segment liegt, müssen wir hier nur noch die mathematische Sicherheitshalber 
      ;    prüfen, ob das Vorzeichen stimmt (Strahl-Richtung nach vorne)
      dot = (Hit\x - *OuterPt\x) * *Normal\x + (Hit\y - *OuterPt\y) * *Normal\y
      If dot >= 0.0
        If *BestHit
          *BestHit\x = Hit\x
          *BestHit\y = Hit\y
        EndIf
        ProcedureReturn #True ; Treffer versenkt!
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Rectangle Functions
  ;- ----------------------------------------------------------------------

  Procedure.i Rect_IsPointInside(*Pt.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. BOUNDING BOX HIT-TESTING & FAST FILTERING:
    ;    The fastest containment test in CAD. Used as a high-speed pre-filter 
    ;    for component selection clicks, group drag-selection boxes, and checking 
    ;    if objects reside inside keep-out zones before executing heavier geometry checks.
    ; ===========================================================================
    ; Check if coordinates fall strictly within the min/max bounding limits
    If *Pt\x >= MinX And *Pt\x <= MaxX And *Pt\y >= MinY And *Pt\y <= MaxY
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i Rect_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. COMPONENT EDGE SNAPPING:
    ;    Allows schematic signals and layout tracks to snap perfectly onto the 
    ;    outer structural perimeter of rectangular IC bodies, connector outlines, 
    ;    or wall boundaries instead of locking to the inside space.
    ; ===========================================================================
    
    Protected.f ClampedX, ClampedY
    Protected.f dl, dr, dt, db, minDist
    
    ; Clamp the point inside the infinite horizontal and vertical bands
    ClampedX = *Pt\x
    If ClampedX < MinX 
      ClampedX = MinX 
    ElseIf ClampedX > MaxX 
      ClampedX = MaxX 
    EndIf
    
    ClampedY = *Pt\y
    If ClampedY < MinY 
      ClampedY = MinY 
    ElseIf ClampedY > MaxY 
      ClampedY = MaxY 
    EndIf
    
    ; If the point was outside, the clamped coordinate is the closest perimeter point
    If *Pt\x < MinX Or *Pt\x > MaxX Or *Pt\y < MinY Or *Pt\y > MaxY
      *OutPt\x = ClampedX
      *OutPt\y = ClampedY
      ProcedureReturn #True
    EndIf
    
    ; If the point is INSIDE, we find the absolute closest single outer edge to push to
    dl = *Pt\x - MinX
    dr = MaxX - *Pt\x
    dt = *Pt\y - MinY
    db = MaxY - *Pt\y
    
    minDist = dl
    *OutPt\x = MinX
    *OutPt\y = *Pt\y
    
    If dr < minDist
      minDist = dr
      *OutPt\x = MaxX
      *OutPt\y = *Pt\y
    EndIf
    
    If dt < minDist
      minDist = dt
      *OutPt\x = *Pt\x
      *OutPt\y = MinY
    EndIf
    
    If db < minDist
      *OutPt\x = *Pt\x
      *OutPt\y = MaxY
    EndIf
    
    ProcedureReturn #True
  EndProcedure

  Procedure.f Rect_PointDistance(*Pt.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. RECTANGULAR CLEARANCE MATRIX (DRC):
    ;    Computes the exact proximity distance between high-voltage tracking nodes 
    ;    and rectangular chassis keep-outs, transformer boundaries, or massive 
    ;    SMD shunt pads to guarantee mechanical clearance compliance.
    ; ===========================================================================
    Protected.f dx = 0.0, dy = 0.0
    
    ; Calculate directional deltas if the point resides outside the box bounds
    If *Pt\x < MinX
      dx = MinX - *Pt\x
    ElseIf *Pt\x > MaxX
      dx = *Pt\x - MaxX
    EndIf
    
    If *Pt\y < MinY
      dy = MinY - *Pt\y
    ElseIf *Pt\y > MaxY
      dy = *Pt\y - MaxY
    EndIf
    
    ; If both deltas are 0, the point is inside the box -> Distance to boundary is 0.0
    ; Otherwise, return standard Euclidean distance of the exterior deltas
    ProcedureReturn Sqr(dx*dx + dy*dy)
  EndProcedure
  
  Procedure.f Rect_CircumCircle(*OutPtCenter.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. HIGH-SPEED RECTANGULAR BOUNDING CIRCLE (SPATIAL CULLING):
    ;    Calculates the absolute minimum enclosing circle for a rectangular asset 
    ;    or chip package. Used by the rendering engine to perform lighting-fast 
    ;    radial distance checks to determine if an object is visible on screen 
    ;    or within selecting brush range before executing deep pixel-perfect tests.
    ; ===========================================================================
    Protected.f Width, Height
    
    ; Step 1: Calculate the exact center point of the bounding box
    *OutPtCenter\x = MinX + (MaxX - MinX) * 0.5
    *OutPtCenter\y = MinY + (MaxY - MinY) * 0.5
    
    ; Step 2: Calculate dimensions
    Width = MaxX - MinX
    Height = MaxY - MinY
    
    ; Step 3: The radius is exactly half of the rectangle's diagonal length
    ProcedureReturn Sqr(Width * Width + Height * Height) * 0.5
  EndProcedure

  Procedure.f Rect_InCircle(*OutPtCenter.TPoint2D, MinX.f, MinY.f, MaxX.f, MaxY.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. MAXIMUM INNER PAD CAPSULE SOLVER:
    ;    Determines the center and the maximum possible radius of a circular 
    ;    copper landing pad or via zone that can safely fit inside a rectangular 
    ;    keep-out area or footprint boundary without violating the outer margins.
    ; ===========================================================================
    Protected.f Width, Height, ShortestSide
    
    ; Step 1: Calculate the exact center point of the bounding box
    *OutPtCenter\x = MinX + (MaxX - MinX) * 0.5
    *OutPtCenter\y = MinY + (MaxY - MinY) * 0.5
    
    ; Step 2: Calculate dimensions
    Width = MaxX - MinX
    Height = MaxY - MinY
    
    ; Step 3: Find the shortest side to constrain the maximum fitting internal circle
    If Width < Height
      ShortestSide = Width
    Else
      ShortestSide = Height
    EndIf
    
    ; The inner radius is exactly half of the shortest side dimension
    ProcedureReturn ShortestSide * 0.5
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Triangle Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f Triangel_Perimeter(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. STRUCTURAL LENGTH MONITORING & MANUFACTURING AUDITS:
    ;    Computes the total outer perimeter length of a triangular layout entity or 
    ;    mesh component. Essential for the CAM export engine to calculate mechanical 
    ;    tool path configurations, mill-cutting lengths, and perimeter routing costs.
    ;
    ; 2. ISOLATION OUTLINE BOUNDARY PATTERNS:
    ;    Supplies raw linear geometry constraints to the copper pour engine when 
    ;    building concentric safety clearance rings or isolated guard traces around 
    ;    triangular high-voltage shielding nodes.
    ; ===========================================================================
    Protected.f ret, dx, dy
    
    ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    ret = Sqr(dx*dx + dy*dy)  
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    ret = ret + Sqr(dx*dx + dy*dy)    
    ; C->A
    dx = *PtC\x - *PtA\x : dy = *PtC\y - *PtA\y 
    ret = ret + Sqr(dx*dx + dy*dy)

    ProcedureReturn ret
  EndProcedure
  
  Procedure.i Triangle_Angles(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *outAngles.TVector)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ANGLE ENFORCEMENT & DRC DESIGN RULES:
    ;    Used inside the Design Rule Check (DRC) to verify layout constraints. 
    ;    For example, it checks if copper corners or intersecting tracks form acute 
    ;    angles (angles below 45 or 90 degrees), which must be prevented because 
    ;    they create dangerous acid traps during chemical PCB etching.
    ;
    ; 2. AUTOMATIC DIMENSIONING WIDGETS:
    ;    Provides the raw geometric degree values needed to feed angular dimension 
    ;    drawing tools, allowing the UI to automatically render correct measurement 
    ;    arcs and numeric degree annotations between three schematic lines.
    ; ===========================================================================
    Protected.f dx, dy, a, b, c, aa, bb, cc
    
    ; With use of cosines law:
    ;   c² = a² + b² - 2 * a * b * Cos (GAMMA)
    ; where GAMMA is the angle opposite side c.
    
    ; original by John Burkardt, 04 May 2005, MIT Licence, Fortran 90
    
     ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    aa = dx*dx + dy*dy : a = Sqr(aa)
    
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    bb = dx*dx + dy*dy : b = Sqr(bb)
    
    ; C->A
    dx = *PtC\x - *PtA\x : dy = *PtC\y - *PtA\y 
    cc = dx*dx + dy*dy : c = Sqr(cc)
    
    With *outAngles
      \v[0] = ACos((cc+aa-bb)/(c*a*2))
      \v[1] = ACos((aa+bb-cc)/(a*b*2))
      \v[2] = ACos((bb+cc-aa)/(b*c*2))
    EndWith
    
    ProcedureReturn *outAngles
  EndProcedure    
  
  Procedure.f Triangle_Area(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. FINITE ELEMENT MESH & PLATING ESTIMATION:
    ;    Calculates the exact area of a single triangular mesh element (tessellation). 
    ;    Essential when computing the total surface area of complex copper pours 
    ;    or structural ground planes to estimate manufacturing copper weight, thermal 
    ;    dissipation capabilities, and galvanic chemistry volume requirements.
    ;
    ; 2. POLYGON DECOMPOSITION QUANTIFICATION:
    ;    Acts as the foundational calculator when determining the overall space of 
    ;    highly irregular geometric zones or floor-plan rooms. By breaking down arbitrary 
    ;    shapes into triangles, summing their individual areas provides an mathematically 
    ;    exact representation of the entire layout region.
    ; ===========================================================================
    
    ; https://de.wikipedia.org/wiki/Dreiecksfl%C3%A4che
    ; A=0.5 * Abs( (X2-X1)(Y3-Y1) - (X3-X1)(Y2-Y1) )
    ; A = 0.5 ( (*PtB\X - *PtA\X) * (*PtC\Y - *PtA\Y) - (*PtC\X - *PtA\X) * (*PtB\Y - *PtA\Y) )
  
    ProcedureReturn _mac_Triangle_Area(*PtA, *PtB, *PtC)
  EndProcedure
  
  Procedure Triangle_Center(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPt.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ELEMENT LABELING & TEXT PLACEMENT:
    ;    Determines the ideal balance center to automatically position component 
    ;    designators, text labels, or reference tags (e.g., "TR_1", "V_IN") inside 
    ;    triangular polygon zones or 3-pin component symbols without clipping borders.
    ;
    ; 2. ANCHOR & GRAB POINT GENERATION:
    ;    Calculates the central grip origin for triangular structures or custom 
    ;    geometric symbols, giving the layout operator a logical snap anchor to 
    ;    grab, move, or rotate the entire group uniformly.
    ; ===========================================================================
    
    With *OutPt
      \X = (*PtA\X + *PtB\X + *PtC\X) * (1/3)
      \Y = (*PtA\Y + *PtB\Y + *PtC\Y) * (1/3)
    EndWith
    ProcedureReturn *OutPt
  EndProcedure
  
  
  ; ==========================================================================================
  ; ARCHITECTURAL COMPARISON: Triangle Circumcircle Algorithms
  ; ==========================================================================================
  
  ; METHOD 1: Vector Algebraic Variant (Triangle_CircumCircle)
  ; ------------------------------------------------------------------------------------------
  ; * Core Engine : Perpendicular bisector intersection & vector cross-product with dynamic swap.
  ; * Overhead    : Extremely low (Requires only 1x Sqr() operation at the very end).
  ; * Sweet Spot  : High-speed mesh generation & Delaunay triangulation.
  ;                 The ultimate workhorse for large point clouds (tessellation, copper zones).
  ;                 Numerically more stable at extreme acute angles due to the built-in 
  ;                 pointer-swapping mechanism when dealing with near-collinear points.
  ;
  ; PERFORMANCE NOTE: 
  ; Variant 2 runs significantly faster in massive loops (mesh generation) because it
  ; reduces expensive CPU square root calculations by 75%.
  ;
  ; METHOD 2: Burkardt/Fortran Port (Triangle_CircumCircle)
  ; ------------------------------------------------------------------------------------------
  ; * Core Engine : Semi-perimeter edge lengths & relative equation system via determinant.
  ; * Overhead    : High (Requires 4x Sqr() square root operations).
  ; * Sweet Spot  : Pure CAD validation & bounding box pre-checks.
  ;                 Perfect if the actual edge lengths (a, b, c) are already required for 
  ;                 other calculations within the same pass (e.g., mechanical stress analysis).
  ;
  ; ==========================================================================================
  
  Procedure.f Triangle_CircumCircle(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPtCenter.TPoint2D)
  ; ======================================================================
  ; NAME: Triangle_CircumCircle (Algebraic Vector Variant)
  ; DESC: Calculates the exact center point and radius of a circle passing through three 2D vertices.
  ;       Uses vector cross-products and midpoints for maximum numerical stability.
  ; VAR(*PtA.TPoint2D): Pointer to the first triangle vertex coordinate structure
  ; VAR(*PtB.TPoint2D): Pointer to the second triangle vertex coordinate structure
  ; VAR(*PtC.TPoint2D): Pointer to the third triangle vertex coordinate structure
  ; VAR(*OutPtCenter.TPoint2D): Pointer to the output structure receiving center coordinates
  ; RET:  Calculated true radius as float, or -1.0 if vertices are collinear (flat line)
  ; ======================================================================
    Protected i.i
    Protected.f mx, my, v1x, v1y, v2x, v2y, t, lambda
    Protected *a.TPoint2D = *PtA
    Protected *b.TPoint2D = *PtB
    Protected *c.TPoint2D = *PtC
    
    lambda = NaN()
    
    ; Loop checks two vector combinations if the first one is unfavorable (Swap)
    For i = 0 To 1
      mx = 0.5 * (*b\x - *c\x)
      my = 0.5 * (*b\y - *c\y)
      
      v1x = *b\x - *a\x
      v1y = *b\y - *a\y
      
      v2x = *c\x - *a\x
      v2y = *c\y - *a\y
      
      t = v2y * v1x - v1y * v2x
      
      ; Epsilon check prevents division by near-zero on flat/degenerate triangles
      If (Abs(t) > 0.00001) ; Standard single-precision float epsilon threshold
        lambda = (v2x * mx + v2y * my) / t
        Break
      EndIf
      
      ; Swap pointers to enforce numerical stability on the second attempt
      Swap *a, *b
    Next i
  
    ; If no valid determinant was found after both iterations (collinear points)
    If IsNaN(lambda)
      *OutPtCenter\x = 0.0
      *OutPtCenter\y = 0.0
      ProcedureReturn -1.0
    EndIf
  
    ; Calculate the circumradius center coordinates
    *OutPtCenter\x =   lambda * v1y + 0.5 * (*a\x + *b\x)
    *OutPtCenter\y = - lambda * v1x + 0.5 * (*a\y + *b\y)
    
    ; Calculate the true circumradius (Only a single Sqr() operation required at the very end!)
    Protected.f dx = *OutPtCenter\x - *PtA\x
    Protected.f dy = *OutPtCenter\y - *PtA\y
    
    ProcedureReturn Sqr(dx * dx + dy * dy)
  EndProcedure

  Procedure.f Triangle_CircumCircle_JB(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPtCenter.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. DELAUNAY TRIANGULATION & MESH GENERATION:
    ;    The foundational mathematical check for grid-mesh generation (tessellation).
    ;    When breaking down irregular copper zones or complex architectural polygons 
    ;    into triangle meshes, this function ensures the Delaunay criterion is met: 
    ;    no other mesh vertices may reside inside a triangle's circumcircle.
    ;
    ; 2. HIGH-SPEED MESH CULLING & BOUNDING FIELDS:
    ;    Calculates the exact geometric center and minimum outer bounding circle 
    ;    for any 3-pin macro element or triangular grouping. If a tool crosshair 
    ;    or track is further away than the returned radius, the system safely 
    ;    skips deep polygon math, vastly speeding up real-time rendering.
    ; ===========================================================================
    
    ; The circumcenter of a triangle is the center of the circumcircle, the
    ; circle that passes through the three vertices of the triangle.
    ; Original by John Burkardt, 6 May 2005, MIT Licence, Fortran 90
    
    Protected.f dxa, dxb, dxc, dya, dyb, dyc, a, b, c, aa, bb, cc
    Protected.f bot, tpx, tpy, det, radius
     
    ; Edge A -> B
    dxa = *PtA\x - *PtB\x : dya = *PtA\y - *PtB\y 
    aa = dxa*dxa + dya*dya : a = Sqr(aa)
    
    ; Edge B -> C
    dxb = *PtB\x - *PtC\x : dyb = *PtB\y - *PtC\y 
    bb = dxb*dxb + dyb*dyb : b = Sqr(bb)
    
    ; Edge C -> A
    dxc = *PtC\x - *PtA\x : dyc = *PtC\y - *PtA\y 
    cc = dxc*dxc + dyc*dyc : c = Sqr(cc)
    
    bot = (a + b + c) * (-a + b + c) * (a - b + c) * (a + b - c)
    
    ; Prevent Division by Zero if vertices are collinear (flat line)
    If bot <= 0.0
      *OutPtCenter\x = 0.0
      *OutPtCenter\y = 0.0
      ProcedureReturn -1.0 ; Return negative radius to indicate an invalid/flat triangle
    EndIf
    
    ; Calculate the true circumradius
    radius = (a * b * c) / Sqr(bot)
        
    tpx = dyc * aa + dya * cc
    tpy = dxc * aa - dxa * cc 
    
    det = (dya * dxc - dyc * dxa) * 2.0
    
    ; Prevent division by zero on the center coordinates calculation
    If det = 0.0
      *OutPtCenter\x = 0.0
      *OutPtCenter\y = 0.0
      ProcedureReturn -1.0
    EndIf
    
    With *OutPtCenter
      \x = *PtA\x + tpx / det
      \y = *PtA\y + tpy / det
    EndWith
    
    ; Return the calculated radius directly as a float
    ProcedureReturn radius
  EndProcedure
 
  Procedure.f Triangle_InCircle(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPtCenter.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. MAXIMUM INNER PAD & SHIELD DISCOVERY:
    ;    Calculates the exact center and maximum possible radius of a circular 
    ;    copper pad or grounding via that can safely fit inside a triangular-shaped 
    ;    shield enclosure or structural restricted zone without breaking outer margins.
    ;
    ; 2. ANCHORING FOR THREE-WAY TRACK FILTERS:
    ;    Used when calculating the smooth curve transition paths where three 
    ;    converging high-power tracks meet at a central triangular junction, 
    ;    ensuring optimal, balanced geometric smoothing across all three sides.
    ; ===========================================================================
    
    ; The inscribed circle of a triangle is the largest circle that can
    ; be drawn inside the triangle. It is tangent to all three sides.
    ; Original by John Burkardt, 17 August 2009, MIT Licence, Fortran 90
    
    Protected.f dx, dy, a, b, c, u, radius
   
    ; Side a: Opposing vertex A (Edge B -> C)
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    a = Sqr(dx*dx + dy*dy) 
    
    ; Side b: Opposing vertex B (Edge C -> A)
    dx = *PtC\x - *PtA\x : dy = *PtC\y - *PtA\y 
    b = Sqr(dx*dx + dy*dy)    
    
    ; Side c: Opposing vertex C (Edge A -> B)
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    c = Sqr(dx*dx + dy*dy)
    
    u = a + b + c
    
    With *OutPtCenter
      If u = 0.0
        \x = *PtA\x
        \y = *PtA\y
        ProcedureReturn 0.0  
      Else
        ; Mathematically correct barycentric coordinate weighting for the incenter:
        ; Vertex A is weighted by side a, B by side b, and C by side c.
        \x = (*PtA\x * a + *PtB\x * b + *PtC\x * c) / u
        \y = (*PtA\y * a + *PtB\y * b + *PtC\y * c) / u
        
        ; Calculate the inradius directly
        radius = Sqr((-a + b + c) * (a - b + c) * (a + b - c) / u) * 0.5
        ProcedureReturn radius
      EndIf
    EndWith
  EndProcedure
  
  Procedure.i Triangle_Edges(*out.TVector, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. COPPER POUR HULL STRUCTURING:
    ;    Extracts the precise segment lengths of a triangular mesh element. 
    ;    Essential for the routing engine when checking if the perimeter edges 
    ;    of a copper fill section provide enough physical clearance to prevent 
    ;    manufacturing defects or narrow bottlenecks.
    ;
    ; 2. STRUCTURAL LENGTH VALIDATION & MEASUREMENT:
    ;    Feeds raw geometric data into the inspection pipeline to dynamically 
    ;    evaluate structural constraints, such as ensuring that triangular component 
    ;    outline segments or silkscreen markers match specified drawing tolerances.
    ; ===========================================================================
    ; calculates the length of all 3 edges  
    Protected.f dx, dy
    
    ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    *out\x = Sqr(dx*dx + dy*dy)    
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    *out\y = Sqr(dx*dx + dy*dy)   
    ; A->C
    dx = *PtA\x - *PtC\x : dy = *PtA\y - *PtC\y 
    *out\z = Sqr(dx*dx + dy*dy)
  
  EndProcedure
  
  Procedure.i Triangle_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. MESH PERIMETER SNAPPING:
    ;    Allows routing traces to snap directly onto the nearest outer edge of 
    ;    a triangular ground-plane shield or specialized connector boundary 
    ;    during high-density board routing.
    ;
    ; 2. BOUNDARY REPAIR ALGORITHMS:
    ;    Identifies the exact coordinate offset when a track line ends slightly 
    ;    outside a mesh element, locking it back perfectly to the boundary.
    ; ===========================================================================
    
    Protected.f MinDistanceSq = Infinity()
    Protected.f dx, dy, segX, segY, t, distSq, edgeLenSq
    Protected.f NearX.f, NearY.f
    Protected.i i.i
    Protected *CurrentPt.TPoint2D, *NextPt.TPoint2D
    
    ; Clear output coordinates
    *OutPt\x = 0.0
    *OutPt\y = 0.0
    
    ; Loop through the 3 edges of the triangle: AB, BC, and CA
    For i = 1 To 3
      Select i
        Case 1
          *CurrentPt = *PtA : *NextPt = *PtB
        Case 2
          *CurrentPt = *PtB : *NextPt = *PtC
        Case 3
          *CurrentPt = *PtC : *NextPt = *PtA
      EndSelect
      
      ; Direction vector of the current edge segment
      dx = *NextPt\x - *CurrentPt\x
      dy = *NextPt\y - *CurrentPt\y
      
      edgeLenSq = dx*dx + dy*dy
      
      ; Handle degenerate edge case where vertices overlap
      If edgeLenSq = 0.0
        segX = *CurrentPt\x
        segY = *CurrentPt\y
      Else
        ; Projection factor t of the point onto the infinite line
        t = ((*Pt\x - *CurrentPt\x) * dx + (*Pt\y - *CurrentPt\y) * dy) / edgeLenSq
        
        ; Clamp t to constrain the result strictly onto the finite line segment [0.0 ... 1.0]
        If t < 0.0
          t = 0.0
        ElseIf t > 1.0
          t = 1.0
        EndIf
        
        ; Calculate the closest coordinates on this specific edge segment
        segX = *CurrentPt\x + t * dx
        segY = *CurrentPt\y + t * dy
      EndIf
      
      ; Calculate squared distance to optimize performance inside the loop
      dx = *Pt\x - segX
      dy = *Pt\y - segY
      distSq = dx*dx + dy*dy
      
      ; Track the absolute minimum squared distance
      If distSq < MinDistanceSq
        MinDistanceSq = distSq
        NearX = segX
        NearY = segY
      EndIf
    Next
    
    ; Save the absolute closest coordinates to the output structure
    *OutPt\x = NearX
    *OutPt\y = NearY
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.f Triangle_PointDistance(*Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. MESH & ENCLOSURE CLEARANCE ANALYSIS (DRC):
    ;    Calculates the exact minimum air-gap or insulation space between an 
    ;    independent track, via, or copper node and a triangular shielding element 
    ;    or single mesh boundary segment to validate electrical clearance constraints.
    ;
    ; 2. INTERACTIVE HOVER SELECTION REGULATION:
    ;    Used continuously inside the mouse interaction loop to evaluate the precise 
    ;    distance between the crosshair tool and a triangular entity contour, deciding 
    ;    whether the cursor is close enough to trigger visual edge highlighting 
    ;    or activate node editing controls.
    ; ===========================================================================
    
    Protected.f MinDistanceSq = Infinity()
    Protected.f dx, dy, segX, segY, t, distSq, edgeLenSq
    Protected.i i.i
    Protected *CurrentPt.TPoint2D, *NextPt.TPoint2D
    
    ; Loop through the 3 edges of the triangle: AB, BC, and CA
    For i = 1 To 3
      Select i
        Case 1
          *CurrentPt = *PtA : *NextPt = *PtB
        Case 2
          *CurrentPt = *PtB : *NextPt = *PtC
        Case 3
          *CurrentPt = *PtC : *NextPt = *PtA
      EndSelect
      
      ; Direction vector of the current edge segment
      dx = *NextPt\x - *CurrentPt\x
      dy = *NextPt\y - *CurrentPt\y
      
      edgeLenSq = dx*dx + dy*dy
      
      ; Handle degenerate edge case where vertices overlap
      If edgeLenSq = 0.0
        segX = *CurrentPt\x
        segY = *CurrentPt\y
      Else
        ; Projection factor t of the point onto the infinite line
        t = ((*Pt\x - *CurrentPt\x) * dx + (*Pt\y - *CurrentPt\y) * dy) / edgeLenSq
        
        ; Clamp t to constrain the result strictly onto the finite line segment [0.0 ... 1.0]
        If t < 0.0
          t = 0.0
        ElseIf t > 1.0
          t = 1.0
        EndIf
        
        ; Calculate the closest coordinates on this specific edge segment
        segX = *CurrentPt\x + t * dx
        segY = *CurrentPt\y + t * dy
      EndIf
      
      ; Calculate squared distance to optimize performance inside the loop
      dx = *Pt\x - segX
      dy = *Pt\y - segY
      distSq = dx*dx + dy*dy
      
      ; Track the absolute minimum squared distance
      If distSq < MinDistanceSq
        MinDistanceSq = distSq
      EndIf
    Next
    
    ; Return the actual Euclidean distance by computing the square root at the very end
    ProcedureReturn Sqr(MinDistanceSq)
  EndProcedure
  
  Procedure.i Triangle_IsPointInside(*Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, Clockwise.i = #False)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. TRIANGLE MESH HIT-TESTING (3D/2D GL-VIEWERS):
    ;    Used when selecting complex 3D components or complex copper pour hulls 
    ;    that have been broken down into a triangle mesh (tessellation). It verifies 
    ;    if the cursor click hits a specific surface element.
    ;
    ; 2. REGIONAL KEEP-OUT BOUNDS:
    ;    Acts as a high-speed boundary check for specialized triangular restricted 
    ;    zones or triangular shield pins commonly found in RF shielding footprints.
    ; ===========================================================================
    
    Protected.f d1, d2, d3
    
    ; Compute signed 2D cross-products (determinants) for all 3 edges
    d1 = (*Pt\x - *PtB\x) * (*PtA\y - *PtB\y) - (*PtA\x - *PtB\x) * (*Pt\y - *PtB\y)
    d2 = (*Pt\x - *PtC\x) * (*PtB\y - *PtC\y) - (*PtB\x - *PtC\x) * (*Pt\y - *PtC\y)
    d3 = (*Pt\x - *PtA\x) * (*PtC\y - *PtA\y) - (*PtC\x - *PtA\x) * (*Pt\y - *PtA\y)
    
    If Clockwise
      ; Clockwise (CW): All cross-products must be >= 0
      If d1 >= 0 And d2 >= 0 And d3 >= 0
        ProcedureReturn #True
      EndIf
    Else
      ; Counter-Clockwise (CCW): All cross-products must be <= 0
      If d1 <= 0 And d2 <= 0 And d3 <= 0
        ProcedureReturn #True
      EndIf
    EndIf
    
    ; Returns false if point is outside or triangle vertices don't match specified orientation
    ProcedureReturn #False
  EndProcedure

  Procedure.i Triangle_IsPointInsideCW(*Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; Explicit wrapper for Clockwise verification
    ProcedureReturn Triangle_IsPointInside(*Pt, *PtA, *PtB, *PtC, #True)
  EndProcedure

  Procedure.i Triangle_IsPointInsideCCW(*Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; Explicit wrapper for Counter-Clockwise verification
    ProcedureReturn Triangle_IsPointInside(*Pt, *PtA, *PtB, *PtC, #False)
  EndProcedure
  
  Procedure.i Triangle_GetOrientation(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ROBUST POLYGON HOLE CLASSIFICATION & SANITIZATION:
    ;    Determines the winding order (Clockwise vs. Counter-Clockwise) of a 
    ;    triangular facet. This is critical when importing or exporting DXF layout 
    ;    geometries, as it identifies whether a closed loop represents a solid 
    ;    copper plane (outer shell) or an empty cutout hole (inner island void).
    ;
    ; 2. SURFACE NORMAL ORIENTATION FOR GRAPHICS RENDERING:
    ;    Provides the geometric wind-direction data required by the viewport 
    ;    render engine (OpenGL/DirectX) to handle back-face culling correctly, 
    ;    ensuring that 2D plane orientations remain mathematically consistent and 
    ;    preventing rendering glitches during dynamic zoom or pan operations.
    ; ===========================================================================
    
    Protected.f SignedArea
    
    ; Compute the signed area using the existing macro
    SignedArea = _mac_Triangle_Area(*PtA, *PtB, *PtC)
    
    ; Check the sign of the result
    If SignedArea > 0.0
      ProcedureReturn 1  ; Counter-Clockwise (CCW)
    ElseIf SignedArea < 0.0
      ProcedureReturn -1 ; Clockwise (CW)
    Else
      ProcedureReturn 0  ; Collinear points (Degenerate flat triangle)
    EndIf
  EndProcedure
  
  Procedure.i Triangle_SetCCW(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. DATA SANITIZATION FOR IMPORTED CAD DATA (DXF/GERBER):
    ;    Ensures geometric data consistency by forcing a Counter-Clockwise (CCW) 
    ;    winding order on triangular facets. This is critical when importing third-party 
    ;    DXF or Gerber files, as it standardizes irregular point sequences into a 
    ;    predictable orientation required for advanced mesh operations.
    ;
    ; 2. COMPUTATIONAL GEOMETRY ALGORITHM ENFORCEMENT:
    ;    Guarantees winding-order compliance for downstream geometric pipelines. 
    ;    Advanced algorithms—such as polygon triangulation, convex hull solvers, 
    ;    and localized intersection tests—strictly require vertices to be ordered 
    ;    counter-clockwise to prevent sign-flip errors and mathematical instabilities.
    ; ===========================================================================
    
    Protected.TPoint2D TmpPt
    
    ; Check the current orientation
    ;  1 = Already CCW
    ;  0 = Linear/Flat (cannot be re-oriented)
    ; -1 = Clockwise (needs to be flipped)
    If Triangle_GetOrientation(*PtA, *PtB, *PtC) = -1
      
      ; Swap Vertex B and Vertex C to invert the winding order
      TmpPt\x = *PtB\x : TmpPt\y = *PtB\y
      
      *PtB\x = *PtC\x : *PtB\y = *PtC\y
      *PtC\x = TmpPt\x : *PtC\y = TmpPt\y
      
      ProcedureReturn #True  ; Orientation was flipped to CCW
    EndIf
    
    ProcedureReturn #False ; No changes needed (already CCW or Collinear)
  EndProcedure
  
  Procedure.i Triangle_GetNormal(*OutNormal.TVector, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. PERSPECTIVE CULLING & VIEWPORT VISIBILITY:
    ;    Provides the 2D perpendicular outward normal vector for a triangular 
    ;    facet or boundary edge. Used by the rendering pipeline to instantly 
    ;    determine surface facing direction, ensuring that vertex occlusion and 
    ;    dynamic camera angle optimizations function flawlessly without visual artifacting.
    ;
    ; 2. ORTHOGONAL OFFSET TRACK GENERATION:
    ;    Supplies the exact orientation vector needed to push out parallel clearance 
    ;    boundaries or structural expansion zones around triangular features, 
    ;    ensuring that insulation guard rings are generated at a perfectly uniform 
    ;    distance along all three sides.
    ; ===========================================================================
    
    Protected.f ax, ay, az, bx, by, bz, nx, ny, nz, length
    
    ; Edge vector 1: A -> B (assuming Z = 0 for 2D points)
    ax = *PtB\x - *PtA\x
    ay = *PtB\y - *PtA\y
    az = 0.0
    
    ; Edge vector 2: A -> C (assuming Z = 0 for 2D points)
    bx = *PtC\x - *PtA\x
    by = *PtC\y - *PtA\y
    bz = 0.0
    
    ; Compute the 3D cross product (Vector Product)
    nx = (ay * bz) - (az * by)
    ny = (az * bx) - (ax * bz)
    nz = (ax * by) - (ay * bx)
    
    ; Calculate the magnitude (length) of the normal vector
    length = Sqr(nx*nx + ny*ny + nz*nz)
    
    ; Normalize the vector to unit length 1.0
    If length > 0.0
      With *OutNormal
        \x = nx / length
        \y = ny / length
        \z = nz / length
      EndWith
      ProcedureReturn #True
    EndIf
    
    ; Return false if the triangle is degenerate (collinear points)
    ProcedureReturn #False
  EndProcedure

  Procedure.f Triangle_Quality(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. MESH OPTIMIZATION & DEGENERATE VERTEX CORRECTION:
    ;    Evaluates the aspect ratio or condition number of a triangular element 
    ;    during copper pour triangulation (tessellation). It flags "sliver" 
    ;    triangles (extremely thin, needle-like shapes with poor geometric quality) 
    ;    that trigger severe numerical rounding errors and software instabilities.
    ;
    ; 2. CNC MILLING PATH & RE-MESHING AUDITING:
    ;    Used by the CAM export pipeline to audit mesh density. Ensuring high-quality 
    ;    triangle shapes prevents localized floating-point arithmetic failures, 
    ;    guaranteeing smooth interpolation paths for CNC milling heads, tool travel 
    ;    trajectories, and clean area clipping operations.
    ; ===========================================================================
    
    Protected.f dx, dy, a, b, c, q, ro
   
    ; The triangel qualility is  Q = 2 * InsideRadius / OutsideRadius
    ; The range of qulity Q = [0..1]. A equilateral triangle has Q=1
   
    ; original by John Burkardt, 30 July 2009, MIT Licence, Fortran 90
    
    ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    a = Sqr(dx*dx + dy*dy) 
    
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    b = Sqr(dx*dx + dy*dy)    
    
    ; C->A
    dx = *PtC\x - *PtA\x : dy = *PtC\y - *PtA\y 
    c = Sqr(dx*dx + dy*dy)
    
    ro = a*b*c 
    If ro = 0
      q=0
    Else
      q = (-a+b+c)*(a-b+c)*(a+b-c)/ro
    EndIf
    
    ProcedureReturn q
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Polygon Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f Polygon_Perimeter(List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. BOARD CUTOUT & OUTLINE ROUTING:
    ;    Computes the total length of the board edge contour (Milling Path). 
    ;    Essential for CNC machining time estimation and quoting manufacturing costs.
    ;
    ; 2. ANTENNA PATH LENGTH VERIFICATION:
    ;    Measures the absolute total length of custom meandering printed PCB trace 
    ;    antennas (e.g., NFC loops or zig-zag RF antennas) to tune resonance.
    ; ===========================================================================
    
    Protected.f TotalPerimeter = 0.0
    Protected.f dx, dy
    Protected *FirstPt.TPoint2D, *CurrentPt.TPoint2D, *NextPt.TPoint2D
    Protected ElementsCount.i
    
    ElementsCount = ListSize(PolyPts())
    
    ; A polygon path needs at least 2 vertices to have a measurable length
    If ElementsCount < 2
      ProcedureReturn 0.0
    EndIf
    
    ; Store the first element pointer to close the path loop at the end
    FirstElement(PolyPts())
    *FirstPt = @PolyPts()
    
    ; Traverse through all polygon vertices
    ForEach PolyPts()
      *CurrentPt = @PolyPts()
      
      ; If at the last element, the path wraps back to the first vertex
      If NextElement(PolyPts())
        *NextPt = @PolyPts()
        ; Move the list cursor back to current element for the loop progression
        PreviousElement(PolyPts())
      Else
        *NextPt = *FirstPt
      EndIf
      
      ; Calculate the standard Euclidean distance between current and next point
      dx = *CurrentPt\x - *NextPt\x
      dy = *CurrentPt\y - *NextPt\y
      TotalPerimeter + Sqr(dx*dx + dy*dy)
    Next
    
    ProcedureReturn TotalPerimeter
  EndProcedure
  
  Procedure.f Polygon_Area(List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. COPPER VOLUME & MATERIAL ESTIMATION:
    ;    Calculates the exact total area of complex copper pours, ground planes, 
    ;    and power zones. This data is critical for calculating board weight, 
    ;    galvanic chemistry usage, and electrical current density capacities.
    ;
    ; 2. STENCIL PASTE CALCULATOR:
    ;    Determines the volume of solder paste required for complex custom SMD 
    ;    landing pads by evaluating the area of their structural mask shapes.
    ; ===========================================================================
    
    Protected.f Area = 0.0
    Protected *FirstPt.TPoint2D, *CurrentPt.TPoint2D, *NextPt.TPoint2D
    Protected ElementsCount.i
    
    ElementsCount = ListSize(PolyPts())
    
    ; A polygon needs at least 3 vertices to enclose an area
    If ElementsCount < 3
      ProcedureReturn 0.0
    EndIf
    
    ; Store the first element pointer to close the loop at the end
    FirstElement(PolyPts())
    *FirstPt = @PolyPts()
    
    ; Loop through all elements
    ForEach PolyPts()
      *CurrentPt = @PolyPts()
      
      ; If we are at the last element, the next point is the first element
      If NextElement(PolyPts())
        *NextPt = @PolyPts()
        ; Move the list cursor back to the current element for the loop progression
        PreviousElement(PolyPts())
      Else
        *NextPt = *FirstPt
      EndIf
      
      ; Shoelace formula calculation step: (X_i * Y_i+1) - (X_i+1 * Y_i)
      Area + (*CurrentPt\x * *NextPt\y) - (*NextPt\x * *CurrentPt\y)
    Next
    
    ; The absolute value is taken because the result can be negative 
    ; depending on the winding order (CW/CCW) of the polygon vertices.
    ProcedureReturn Abs(Area) * 0.5
  EndProcedure
  
  Procedure.i Polygon_Center(*OutPt.TPoint2D, List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. PICK-AND-PLACE CENTER CALCULATION:
    ;    Calculates the mathematical centroid of custom components, irregular shield 
    ;    cans, or complex SMD pads. This coordinate is exported to automated assembly 
    ;    machines so the vacuum nozzle grips the part exactly at its balance center.
    ;
    ; 2. AUTO-LABEL & DESIGNATOR PLACEMENT:
    ;    Finds the ideal center point to automatically drop reference designators 
    ;    (e.g., "GND_PLANE_1" or component names) inside complex geometric polygons.
  ; ===========================================================================
    
    Protected.f SignedArea = 0.0
    Protected.f Factor = 0.0
    Protected.f Cx = 0.0, Cy = 0.0
    Protected *FirstPt.TPoint2D, *CurrentPt.TPoint2D, *NextPt.TPoint2D
    Protected ElementsCount.i
    
    ElementsCount = ListSize(PolyPts())
    
    ; Clear the output coordinates first
    *OutPt\x = 0.0
    *OutPt\y = 0.0
    
    ; A polygon needs at least 3 vertices to have a geometric center
    If ElementsCount < 3
      ProcedureReturn #False
    EndIf
    
    ; Store the first element pointer to close the loop at the end
    FirstElement(PolyPts())
    *FirstPt = @PolyPts()
    
    ; Traverse all vertices
    ForEach PolyPts()
      *CurrentPt = @PolyPts()
      
      ; If we are at the last element, the next point is the first element
      If NextElement(PolyPts())
        *NextPt = @PolyPts()
        ; Move the list cursor back to the current element for the loop progression
        PreviousElement(PolyPts())
      Else
        *NextPt = *FirstPt
      EndIf
      
      ; Common factor for Shoelace-based centroid calculation: (X_i * Y_i+1) - (X_i+1 * Y_i)
      Factor = (*CurrentPt\x * *NextPt\y) - (*NextPt\x * *CurrentPt\y)
      
      SignedArea + Factor
      Cx + (*CurrentPt\x + *NextPt\x) * Factor
      Cy + (*CurrentPt\y + *NextPt\y) * Factor
    Next
    
    ; Finalize the signed area
    SignedArea * 0.5
    
    ; Prevent division by zero if the polygon has zero area (collinear vertices)
    If SignedArea = 0.0
      ProcedureReturn #False
    EndIf
    
    ; Divide by 6 times the signed area to get the true centroid coordinates
    *OutPt\x = Cx / (6.0 * SignedArea)
    *OutPt\y = Cy / (6.0 * SignedArea)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i Polygon_Angles(List lstOutAngles.f(), List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. CONTOUR GEOMETRY CORRECTION & CLEANING:
    ;    Analyzes every interior corner of a complex drawn polygon (e.g., custom board 
    ;    outlines or large copper pours) to automatically detect and flag illegal 
    ;    acute vertices that would violate modern PCB or architectural routing constraints.
    ;
    ; 2. MULTI-CORNER DIMENSIONING LOGIC:
    ;    Supplies the exact internal radian data required by the drawing layer to 
    ;    render localized angle measurement arcs and text overlays at any arbitrary 
    ;    vertex corner of a complex architectural room shape or copper zone.
    ; ===========================================================================
     
    Protected.f dx1, dy1, dx2, dy2, dot, cross, angle, totalArea
    Protected *PrevPt.TPoint2D, *CurrentPt.TPoint2D, *NextPt.TPoint2D
    Protected ElementsCount.i, i.i
    Protected IsCCW.i = #True
    
    ElementsCount = ListSize(PolyPts())
    ClearList(lstOutAngles())
    
    ; A polygon must have at least 3 vertices to have internal angles
    If ElementsCount < 3
      ProcedureReturn #False
    EndIf
    
    ; Step 1: Determine the winding order using Polygon_Area logic
    ; We need to know if the polygon is CW or CCW to get the correct interior side
    FirstElement(PolyPts())
    *PrevPt = @PolyPts()
    totalArea = 0.0
    ForEach PolyPts()
      *CurrentPt = @PolyPts()
      If NextElement(PolyPts())
        *NextPt = @PolyPts()
        PreviousElement(PolyPts())
      Else
        FirstElement(PolyPts())
        *NextPt = @PolyPts()
      EndIf
      totalArea + (*CurrentPt\x * *NextPt\y) - (*NextPt\x * *CurrentPt\y)
    Next
    
    ; If totalArea is negative, the winding order is Clockwise (CW)
    If totalArea < 0.0
      IsCCW = #False
    EndIf
    
    ; Step 2: Calculate the interior angle at each vertex
    FirstElement(PolyPts())
    For i = 0 To ElementsCount - 1
      SelectElement(PolyPts(), i)
      *CurrentPt = @PolyPts()
      
      ; Get the previous vertex pointer
      If i = 0
        SelectElement(PolyPts(), ElementsCount - 1)
      Else
        SelectElement(PolyPts(), i - 1)
      EndIf
      *PrevPt = @PolyPts()
      
      ; Get the next vertex pointer
      If i = ElementsCount - 1
        SelectElement(PolyPts(), 0)
      Else
        SelectElement(PolyPts(), i + 1)
      EndIf
      *NextPt = @PolyPts()
      
      ; Vector 1: Current -> Previous
      dx1 = *PrevPt\x - *CurrentPt\x
      dy1 = *PrevPt\y - *CurrentPt\y
      
      ; Vector 2: Current -> Next
      dx2 = *NextPt\x - *CurrentPt\x
      dy2 = *NextPt\y - *CurrentPt\y
      
      ; Calculate dot product and 2D cross product
      dot = dx1 * dx2 + dy1 * dy2
      cross = dx1 * dy2 - dy1 * dx2
      
      ; Get the directional angle between the two vectors using ATan2
      angle = ATan2(dot, cross)
      
      ; Ensure the angle is strictly positive [0 ... 2*PI]
      If angle < 0.0
        angle + (2.0 * #PI)
      EndIf
      
      ; Invert the angle if the winding order orientation dictates it
      If IsCCW = #False
        angle = (2.0 * #PI) - angle
      EndIf
      
      ; Add the final corrected interior angle to the output list
      AddElement(lstOutAngles())
      lstOutAngles() = angle
    Next
    
    ProcedureReturn #True
  EndProcedure

  Procedure.f Polygon_Radius(*PtA.TPoint2D, List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. CONVEX HULL & SPATIAL BOUNDING SPHERE GENERATION:
    ;    Calculates the maximum bounding radius from a chosen reference anchor (such 
    ;    as the centroid or component origin) to the furthest outer vertex. Used by 
    ;    the viewport engine to quickly cull complex shapes if they fall outside the 
    ;    visible screen or current selection window.
    ;
    ; 2. MECHANICAL SWEEP & CLEARANCE RADII:
    ;    Determines the minimum safety boundary required around asymmetrical polygons 
    ;    (e.g., custom connector outlines, irregular multi-pin headers, or indoor 
    ;    architectural equipment) to ensure no tracks or layout walls penetrate 
    ;    the asset's structural footprint envelope.
    ; ===========================================================================
    
    Protected.f MaxDistanceSq = 0.0
    Protected.f dx, dy, distSq
    
    ; A polygon must have at least 1 vertex to calculate a radius
    If ListSize(PolyPts()) < 1
      ProcedureReturn 0.0
    EndIf
    
    ; Find the vertex that is furthest away from the reference point *PtA
    ForEach PolyPts()
      dx = PolyPts()\x - *PtA\x
      dy = PolyPts()\y - *PtA\y
      
      ; Using squared distance inside the loop for performance
      distSq = dx*dx + dy*dy
      
      If distSq > MaxDistanceSq
        MaxDistanceSq = distSq
      EndIf
    Next
    
    ; Return the actual Euclidean distance at the end
    ProcedureReturn Sqr(MaxDistanceSq)
  EndProcedure

  Procedure.f Polygon_RadiusIn(List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. LARGEST SAFE INTERNAL PAD CORING:
    ;    Calculates the maximum inner radius from the polygon's true geometric 
    ;    center to its closest bounding edge. Used to determine the absolute 
    ;    largest circular copper pad, mounting via, or structural foundation 
    ;    that can safely fit entirely inside an irregular polygonal space.
    ;
    ; 2. ISOLATION FILL BULKHEAD CHECKING:
    ;    Assists the solid copper-pour expansion engine by analyzing the narrowest 
    ;    internal clearance bottlenecks of a polygon shape, preventing the 
    ;    generation of copper fills that violate structural width rules.
    ; ===========================================================================
    Protected Centroid.TPoint2D
    
    ; Step 1: Calculate the true geometric center (centroid) of the polygon
    ; If the polygon is degenerate or has no area, we cannot calculate an inner radius
    If Polygon_Center(@Centroid, PolyPts()) = #False
      ProcedureReturn 0.0
    EndIf
    
    ; Step 2: The inner radius is the minimum distance from the centroid to the polygon's boundary.
    ; We can directly reuse the optimized Polygon_PointDistance procedure here.
    ProcedureReturn Polygon_PointDistance(@Centroid, PolyPts())
  EndProcedure

  Procedure.i Polygon_Edges(Array OutEdges.f(1), List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. CNC MILLING PATH & OUTLINE TRAVERSAL:
    ;    Extracts the individual segment lengths of a complex board outline or 
    ;    architectural perimeter. This array data is critical for the CAM export 
    ;    pipeline to map out tool travel paths, CNC milling durations, and cutting 
    ;    tolerances along polygon borders.
    ;
    ; 2. SEGMENT-BASED DRILLING & CLEARANCE MATRIX:
    ;    Loops through the individual edge lengths of custom copper pours or multi-sided 
    ;    keep-out zones to quickly evaluate if any particular side falls below the 
    ;    minimum width restrictions or requires specialized geometric isolation.
    ; ===========================================================================
    Protected.f dx, dy
    Protected *FirstPt.TPoint2D, *CurrentPt.TPoint2D, *NextPt.TPoint2D
    Protected ElementsCount.i, Index.i = 0
    
    ElementsCount = ListSize(PolyPts())
    
    ; A polygon must have at least 2 vertices to define edges
    If ElementsCount < 2
      ReDim OutEdges(0)
      OutEdges(0) = 0.0
      ProcedureReturn 0
    EndIf
    
    ; Resize the output array to match the exact number of edges (0-indexed)
    ReDim OutEdges(ElementsCount - 1)
    
    ; Store the first element pointer to close the loop at the end
    FirstElement(PolyPts())
    *FirstPt = @PolyPts()
    
    ; Loop through all vertices of the polygon
    ForEach PolyPts()
      *CurrentPt = @PolyPts()
      
      ; If we are at the last element, the next point is the first element
      If NextElement(PolyPts())
        *NextPt = @PolyPts()
        ; Move the list cursor back to the current element for loop progression
        PreviousElement(PolyPts())
      Else
        *NextPt = *FirstPt
      EndIf
      
      ; Calculate the standard Euclidean distance for the current edge
      dx = *CurrentPt\x - *NextPt\x
      dy = *CurrentPt\y - *NextPt\y
      OutEdges(Index) = Sqr(dx*dx + dy*dy)
      
      Index + 1
    Next
    
    ProcedureReturn ElementsCount
  EndProcedure
  
  Procedure.i Polygon_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. COMPLEX SHAPE PERIMETER MAGNETIC SNAPPING:
    ;    The core engine for snapping onto irregular or custom geometric shapes. 
    ;    When a user hovers the cursor near a complex multi-sided copper zone, a 
    ;    board cutout perimeter, or an architectural wall layout, this routine 
    ;    instantly locks the active coordinate onto the nearest physical edge point.
    ;
    ; 2. T-JUNCTION CONNECTIONS TO ARBITRARY HULLS:
    ;    Provides the exact landing target coordinate when a trace or secondary 
    ;    construction guide needs to terminate or anchor itself at a perfect 
    ;    perpendicular intersection anywhere along a polygon's boundary contour.
    ; ===========================================================================
    Protected.f MinDistance = Infinity()
    Protected.f dx, dy, segX, segY, t, dist, edgeLenSq
    Protected *FirstPt.TPoint2D, *CurrentPt.TPoint2D, *NextPt.TPoint2D
    Protected NearX.f, NearY.f
    Protected ElementsCount.i
    
    ElementsCount = ListSize(PolyPts())
    
    ; Clear output coordinates
    *OutPt\x = 0.0
    *OutPt\y = 0.0
    
    ; A polygon must have at least 2 vertices to define edges
    If ElementsCount < 2
      ProcedureReturn #False
    EndIf
    
    ; Store the first element pointer to close the loop at the end
    FirstElement(PolyPts())
    *FirstPt = @PolyPts()
    
    ; Traverse all edges of the polygon
    ForEach PolyPts()
      *CurrentPt = @PolyPts()
      
      ; Get the next vertex pointer
      If NextElement(PolyPts())
        *NextPt = @PolyPts()
        PreviousElement(PolyPts())
      Else
        *NextPt = *FirstPt
      EndIf
      
      ; Direction vector of the current edge segment
      dx = *NextPt\x - *CurrentPt\x
      dy = *NextPt\y - *CurrentPt\y
      
      edgeLenSq = dx*dx + dy*dy
      
      ; Handle degenerate edge (coinciding vertices)
      If edgeLenSq = 0.0
        segX = *CurrentPt\x
        segY = *CurrentPt\y
      Else
        ; Projection factor t of point onto the infinite line
        t = ((*Pt\x - *CurrentPt\x) * dx + (*Pt\y - *CurrentPt\y) * dy) / edgeLenSq
        
        ; Clamp t to constrain the point onto the finite line segment [0.0 ... 1.0]
        If t < 0.0
          t = 0.0
        ElseIf t > 1.0
          t = 1.0
        EndIf
        
        ; Calculate the closest coordinates on this specific segment
        segX = *CurrentPt\x + t * dx
        segY = *CurrentPt\y + t * dy
      EndIf
      
      ; Calculate squared distance to avoid slow Sqr() in the loop comparison
      dx = *Pt\x - segX
      dy = *Pt\y - segY
      dist = dx*dx + dy*dy
      
      ; If this segment is closer than previous ones, store the coordinates
      If dist < MinDistance
        MinDistance = dist
        NearX = segX
        NearY = segY
      EndIf
    Next
    
    ; Save the final absolute closest coordinates to the output structure
    *OutPt\x = NearX
    *OutPt\y = NearY
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.f Polygon_PointDistance(*Pt.TPoint2D, List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ISOLATION CLEARANCE VERIFICATION (DRC):
    ;    Calculates the exact minimum air-gap or insulation space between an 
    ;    independent track, via, or copper node and an entire irregular polygon 
    ;    boundary (e.g., custom copper pours, ground planes, or keep-out layers) 
    ;    to validate electrical clearance constraints.
    ;
    ; 2. DYNAMIC MOUSE HOVER SELECTION DETECTION:
    ;    Used inside the real-time event loop to determine if the cursor crosshair 
    ;    is floating within a pre-defined clicking threshold of a polygon contour. 
    ;    This allows the UI to quickly trigger context-sensitive edge highlights 
    ;    or activate border modification states.
    ; ===========================================================================
    
    Protected.f MinDistanceSq = Infinity()
    Protected.f dx, dy, segX, segY, t, dist, edgeLenSq
    Protected *FirstPt.TPoint2D, *CurrentPt.TPoint2D, *NextPt.TPoint2D
    Protected ElementsCount.i
    
    ElementsCount = ListSize(PolyPts())
    
    ; A polygon must have at least 2 vertices to define edges and distance
    If ElementsCount < 2
      ProcedureReturn 0.0
    EndIf
    
    ; Store the first element pointer to close the loop at the end
    FirstElement(PolyPts())
    *FirstPt = @PolyPts()
    
    ; Traverse all edges of the polygon
    ForEach PolyPts()
      *CurrentPt = @PolyPts()
      
      ; Get the next vertex pointer
      If NextElement(PolyPts())
        *NextPt = @PolyPts()
        PreviousElement(PolyPts())
      Else
        *NextPt = *FirstPt
      EndIf
      
      ; Direction vector of the current edge segment
      dx = *NextPt\x - *CurrentPt\x
      dy = *NextPt\y - *CurrentPt\y
      
      edgeLenSq = dx*dx + dy*dy
      
      ; Handle degenerate edge (coinciding vertices)
      If edgeLenSq = 0.0
        segX = *CurrentPt\x
        segY = *CurrentPt\y
      Else
        ; Projection factor t of point onto the infinite line
        t = ((*Pt\x - *CurrentPt\x) * dx + (*Pt\y - *CurrentPt\y) * dy) / edgeLenSq
        
        ; Clamp t to constrain the point onto the finite line segment [0.0 ... 1.0]
        If t < 0.0
          t = 0.0
        ElseIf t > 1.0
          t = 1.0
        EndIf
        
        ; Calculate the closest coordinates on this specific segment
        segX = *CurrentPt\x + t * dx
        segY = *CurrentPt\y + t * dy
      EndIf
      
      ; Calculate squared distance to optimize performance inside the loop
      dx = *Pt\x - segX
      dy = *Pt\y - segY
      dist = dx*dx + dy*dy
      
      ; Keep track of the absolute minimum squared distance
      If dist < MinDistanceSq
        MinDistanceSq = dist
      EndIf
    Next
    
    ; Return the actual Euclidean distance by computing the square root at the very end
    ProcedureReturn Sqr(MinDistanceSq)
  EndProcedure
  
  Procedure.i Polygon_IsPointInside(*Pt.TPoint2D, List PolyPts.TPoint2D())
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. COMPLEX COPPER POUR / KEEP-OUT ISOLATION:
    ;    The core engine for polygon hit-testing. Checks if vias, components, 
    ;    or traces reside within a custom-shaped copper zone or inside an arbitrary 
    ;    Keep-Out/Restricted area to enforce electrical clearance.
    ;
    ; 2. FLOATING COPPER DETECTION (ISLAND FINDER):
    ;    Used during DRC connectivity analysis to check if isolated copper areas 
    ;    contain at least one connected via or pin anchor, identifying dead 
    ;    "floating islands" that must be unpoured.
    ; ===========================================================================
    Protected Inside.i
    Protected *CurrentPt.TPoint2D, *PrevPt.TPoint2D
    Protected ElementsCount.i
    
    ElementsCount = ListSize(PolyPts())
    
    ; A polygon must have at least 3 vertices to enclose a space
    If ElementsCount < 3
      ProcedureReturn #False
    EndIf
    
    ; Set the initial previous point to the last element of the list to close the loop
    LastElement(PolyPts())
    *PrevPt = @PolyPts()
    
    ; Loop through all vertices of the polygon
    FirstElement(PolyPts())
    ForEach PolyPts()
      *CurrentPt = @PolyPts()
      
      ; Check if the ray intersects the edge between *CurrentPt and *PrevPt
      If Bool(*CurrentPt\y > *Pt\y) <> Bool(*PrevPt\y > *Pt\y)
        
        ; Calculate the exact X-coordinate of the intersection on the edge
        ; and check if the intersection point is to the right of our test point
        If (*Pt\x < (*PrevPt\x - *CurrentPt\x) * (*Pt\y - *CurrentPt\y) / (*PrevPt\y - *CurrentPt\y) + *CurrentPt\x)
          ; Toggle the inside/outside state (Even-Odd Rule)
          Inside = Bool(Inside=0); = Not Inside
        EndIf
        
      EndIf
      
      ; Move the previous point pointer to the current point for the next edge
      *PrevPt = *CurrentPt
    Next
    
    ProcedureReturn Inside
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Circle Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f Circle_Perimeter(Radius.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. CNC MILLING PATH & CIRCULAR CUTOUT ESTIMATION:
    ;    Computes the exact total cutting perimeter for round structural cutouts, 
    ;    circular chassis openings, or large mounting holes. This profile length 
    ;    is vital for the CAM export engine to plan tool path cycles, predict 
    ;    CNC machining time, and adjust mechanical milling feed rates.
    ;
    ; 2. EMBEDDED ANTENNA & EMBOSSED SILKSCREEN PACKAGING:
    ;    Provides the absolute path length for circular trace elements, such as 
    ;    coaxial shielding rings, circular loop antennas, or decorative logo shapes, 
    ;    ensuring perfect manufacturing alignment and proper RF wavelength calculations.
    ; ===========================================================================
    
    ProcedureReturn Radius * 2 *#PI 
  EndProcedure

  Procedure.f Circle_Area(Radius.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. COPPER VOLUME & PLATING MASS CALCULATION:
    ;    Calculates the precise surface area of solid circular landing pads, test 
    ;    points, or massive power vias. This data is critical for estimating total 
    ;    copper weight, thermal dissipation capabilities, and calculating exact 
    ;    galvanic electroplating solution requirements during board manufacturing.
    ;
    ; 2. DRILL VOID PLANE MASKING & SHIELD GENERATION:
    ;    Determines the exact physical footprint area that a circular drill bit or 
    ;    mounting screw hole will displace. The copper pour engine uses this to 
    ;    subtract the geometric void area from inner power planes, ensuring correct 
    ;    negative thermal-relief boundaries are generated.
    ; ===========================================================================
    ProcedureReturn Radius * Radius * #PI 
  EndProcedure
  
  Procedure.i Circle_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)    
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. PAD/VIA BOUNDARY SNAPPING:
    ;    Allows the mouse cursor or interactive routing lines to snap exactly 
    ;    to the copper edge of a round pad, via hole, or test point rather than 
    ;    jumping straight to the center coordinate.
    ;
    ; 2. ANNOTATION AND LEADER LINES:
    ;    Calculates the clean starting point for mechanical pointer arrows or 
    ;    text leaders that point directly to a circular component without 
    ;    overlapping the interior symbol drawing.
    ; ===========================================================================

    Protected.f dx, dy, length
    
    ; Clear output coordinates
    *OutPt\x = 0.0
    *OutPt\y = 0.0
    
    If Radius < 0.0
      ProcedureReturn #False
    EndIf
    
    ; Calculate the vector from the circle center to the test point
    dx = *Pt\x - *CircleCenter\x
    dy = *Pt\y - *CircleCenter\y
    
    ; Calculate the distance (magnitude) from center to point
    length = Sqr(dx*dx + dy*dy)
    
    ; Handle the degenerate case where the test point lies exactly at the center
    If length = 0.0
      *OutPt\x = *CircleCenter\x + Radius
      *OutPt\y = *CircleCenter\y
      ProcedureReturn #True
    EndIf
    
    ; Project the point onto the circle perimeter by normalizing the direction vector
    *OutPt\x = *CircleCenter\x + (dx / length) * Radius
    *OutPt\y = *CircleCenter\y + (dy / length) * Radius
    
    ProcedureReturn #True
  EndProcedure

  Procedure.f Circle_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. CLEARANCE CHECKS (COPPER POURS / DRC):
    ;    Determines the shortest distance between a track/polygon and a circular 
    ;    via/pad. Essential for calculating if the net insulation satisfies the 
    ;    minimum clearance matrix defined in the design rules.
    ;
    ; 2. TEARDROP GENERATION ANALYSIS:
    ;    Analyzes how far away an incoming track is from a pad to smoothly 
    ;    calculate the teardrop reinforcement shape at the transition junction.
    ; ===========================================================================
    
    Protected.f dx, dy, m
    
    dx = *Pt\x - *CircleCenter\x      ; Distance X
    dy = *Pt\y - *CircleCenter\y      ; Distance Y
    
    m = Sqr(dx*dx + dy*dy)            ; Absolute distance Point to CircleCenter
    
    ProcedureReturn (m - Radius)      ; If ReturnValue is negative Then Point is inside the Circle    
  EndProcedure
   
  Procedure.i Circle_IsPointInside(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. HIT-TESTING & OBJECT SELECTION:
    ;    Used inside the mouse-click event handler to verify if the user clicked 
    ;    inside a circular pad, via, mounting hole, or test point to highlight 
    ;    and select the component.
    ;
    ; 2. DRILL HOLE VOID GENERATION:
    ;    Used during Gerber export to verify which structural parts of an inner 
    ;    power/ground plane must be etched away to leave clear space for a 
    ;    non-plated mounting screw hole.
  ; ===========================================================================
    Protected.f dx, dy, m
    
    dx = *Pt\x - *CircleCenter\x      ; Distance X
    dy = *Pt\y - *CircleCenter\y      ; Distance Y
    
    m = Sqr(dx*dx + dy*dy)            ; Absolute distance Point to CircleCenter
    
    dx = (m - Radius)                 ; if Value is negative Then Point is inside the Circle  
    If dx < 0
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf    
  EndProcedure
 
  Procedure.i Circle_TangentToPoint(*OutT1.TPoint2D, *OutT2.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, Radius.f)
    
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. PERPENDICULAR APPRROACH ROUTING:
    ;    Calculates the ideal straight routing path coming from a remote component 
    ;    pin to meet a circular bus ring or target shield pad at a perfectly 
    ;    smooth tangent angle, preventing sharp reflection points.
    ;
    ; 2. FOOTPRINT SHELL GRAPHICS:
    ;    Assists in drawing complex mechanical outlines (silkscreen) for round 
    ;    relays or specialized connectors that require tangentially blending lines.
    ; ===========================================================================
    
    ; calculates the 2 possible tanget points on a circle from a point outside the circle
    
    ; https://stackoverflow.com/questions/49968720/find-tangent-points-in-a-circle-from-a-point
    
    Protected.f dx, dy, b, th, d, d1, d2
    
    dx = *Pt\x - *CenterPt\x        ; X-Distance between Point and CenterOfCircle
    dy = *Pt\y - *CenterPt\y        ; Y-Distance between Point and CenterOfCircle
    
    d = ATan2(dy, dx)               ; Angle betwwen Point Pt and CircleCenter
    b = Sqr(dx *dx + dy *dy)        ; absolute Distance between Point and CenterOfCircle
    
    th = ACos(Radius/b)             ; Angle between Line b and Radius  
    d1 = d + th                     ; direction angle of point T1 from C
    d2 = d - th                     ; direction angle of point T2 from C
    
    With *OutT1
      \x = *CenterPt\x + Radius * Cos(d1)
      \y = *CenterPt\y + Radius * Sin(d1)    
    EndWith 
    
    With *OutT2
      \x = *CenterPt\x + Radius * Cos(d2)
      \y = *CenterPt\y + Radius * Sin(d2)    
    EndWith 
    
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- CircleSector Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f CircleSector_Perimeter(Radius.f, Angle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. CNC MILLING PATH & PANEL OUTLINE CALCULATION:
    ;    Computes the exact total cutting distance for a circular pie-wedge shape 
    ;    or a rounded corner-chassis cutout. This profile length is critical for 
    ;    the CAM export engine to calculate mechanical tool travel paths, machine 
    ;    feed rates, and overall fabrication cycle times.
    ;
    ; 2. MECHANICAL CASING & SILKSCREEN PACKAGING ANALYSIS:
    ;    Provides the total linear boundary footprint for circular wedge assets 
    ;    or radial mechanical dials. This is used to accurately draw protective 
    ;    silkscreen component boundaries and evaluate spatial enclosure housing rules.
    ; ===========================================================================
    
    ;     Protected.f b
    ;     b = 2*#PI * Radius * Angle/360 
    ;     ProcedureReturn 2*Radius + b 
    
    ProcedureReturn ((#PI/180) * Angle +2) * Radius
  EndProcedure
  
  Procedure.f CircleSector_Area(Radius.f, Angle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. COPPER VOLUME & SHIELD PLANE ESTIMATION:
    ;    Calculates the exact area of a circular pie-wedge shape or radial copper 
    ;    pour segment. This data is critical for estimating total copper volume, 
    ;    evaluating mass distributions on specific board layers, and calculating 
    ;    galvanic plating chemistry requirements.
    ;
    ; 2. ARCHITECTURAL WEDGE ZONE ANALYSIS:
    ;    Determines the precise square footage or surface space of rounded alcoves, 
    ;    radial room features, or localized circular clearance zones within building 
    ;    blueprints, ensuring zone-specific compliance metrics are met.
    ; ===========================================================================
    
    ; A=Angle/360 * #PI * r*r
    ProcedureReturn (#PI/360) * Angle * Radius * Radius   
  EndProcedure
  
  Procedure.i CircleSector_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. PIE-WEDGE SHAPE MAGNET SNAPPING:
    ;    The primary alignment routine for circular wedge elements. When an operator 
    ;    moves the mouse cursor near a radial shielding zone, a pie-wedge pad, or a 
    ;    curved architectural layout element, this function instantly locks the 
    ;    active coordinate onto the closest boundary edge (the center vertex, the 
    ;    straight radial edges, or the outer circular arc).
    ;
    ; 2. ROTATIONAL COMPONENT PIN ATTACHMENT:
    ;    Provides the exact landing target coordinate when a trace, structural wall, 
    ;    or custom dimension line needs to connect flush to the physical boundary 
    ;    profile of a wedge-shaped dial indicator or custom multi-pin radial connector.
    ; ===========================================================================
    Protected.f testX, testY, relX, relY, angle, distSq, minDistSq
    Protected.f edgeX, edgeY, t, endAngle
    Protected.f nearX, nearY
    
    ; Clear output coordinates
    *OutPt\x = *CircleCenter\x
    *OutPt\y = *CircleCenter\y
    
    If Radius <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn #False
    EndIf
    
    ; Normalize test point relative to the circle center
    relX = *Pt\x - *CircleCenter\x
    relY = *Pt\y - *CircleCenter\y
    
    ; --------------------------------------------------------------------
    ; Case 1: Check distance to the Center Vertex
    ; --------------------------------------------------------------------
    minDistSq = relX*relX + relY*relY
    nearX = *CircleCenter\x
    nearY = *CircleCenter\y
    
    ; Get the absolute polar angle of the test point relative to center
    angle = ATan2(relX, relY)
    If angle < 0.0
      angle + (2.0 * #PI)
    EndIf
    
    ; Ensure SweepAngle does not exceed a full circle
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Normalize angles to check if the point lies within the angular sector wedge
    Protected.f diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    ; --------------------------------------------------------------------
    ; Case 2: Point is inside the angular wedge -> Project onto circular arc edge
    ; --------------------------------------------------------------------
    If diffAngle <= SweepAngle
      edgeX = *CircleCenter\x + Radius * Cos(angle)
      edgeY = *CircleCenter\y + Radius * Sin(angle)
      
      testX = *Pt\x - edgeX
      testY = *Pt\y - edgeY
      distSq = testX*testX + testY*testY
      
      If distSq < minDistSq
        minDistSq = distSq
        nearX = edgeX
        nearY = edgeY
      EndIf
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 3: Project onto the Start-Radius Line Segment
    ; --------------------------------------------------------------------
    edgeX = Cos(StartAngle)
    edgeY = Sin(StartAngle)
    ; Dot product projection to find scalar t along the radius line segment
    t = relX * edgeX + relY * edgeY
    If t < 0.0 : t = 0.0 : ElseIf t > Radius : t = Radius : EndIf
    
    testX = *Pt\x - (*CircleCenter\x + t * edgeX)
    testY = *Pt\y - (*CircleCenter\y + t * edgeY)
    distSq = testX*testX + testY*testY
    
    If distSq < minDistSq
      minDistSq = distSq
      nearX = *CircleCenter\x + t * edgeX
      nearY = *CircleCenter\y + t * edgeY
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 4: Project onto the End-Radius Line Segment
    ; --------------------------------------------------------------------
    endAngle = StartAngle + SweepAngle
    edgeX = Cos(endAngle)
    edgeY = Sin(endAngle)
    ; Dot product projection to find scalar t along the end radius line segment
    t = relX * edgeX + relY * edgeY
    If t < 0.0 : t = 0.0 : ElseIf t > Radius : t = Radius : EndIf
    
    testX = *Pt\x - (*CircleCenter\x + t * edgeX)
    testY = *Pt\y - (*CircleCenter\y + t * edgeY)
    distSq = testX*testX + testY*testY
    
    If distSq < minDistSq
      minDistSq = distSq
      nearX = *CircleCenter\x + t * edgeX
      nearY = *CircleCenter\y + t * edgeY
    EndIf
    
    ; Save the final absolute nearest point coordinates
    *OutPt\x = nearX
    *OutPt\y = nearY
    ProcedureReturn #True
  EndProcedure  
  
  Procedure.f CircleSector_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. STRUCTURAL INSULATION CLEARANCE ANALYSIS (DRC):
    ;    Calculates the exact minimum air-gap or clearance space between an 
    ;    independent track, via, or copper node and a solid pie-wedge shape boundary 
    ;    (such as a specialized radial shielding pad or localized keep-out zone) 
    ;    to prevent high-voltage arcing or trace shorts.
    ;
    ; 2. WEDGE-CONTOUR HOVER CAPTURE FILTER:
    ;    Used continuously inside the mouse interaction loop to evaluate the precise 
    ;    distance between the crosshair tool and a circular sector entity, deciding 
    ;    whether the cursor is close enough to trigger visual edge highlighting 
    ;    or activate node editing controls.
    ; ===========================================================================
    Protected.f testX, testY, relX, relY, angle, distSq, minDistSq
    Protected.f edgeX, edgeY, t, endAngle
    
    If Radius <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn 0.0
    EndIf
    
    ; Normalize test point relative to the circle center
    relX = *Pt\x - *CircleCenter\x
    relY = *Pt\y - *CircleCenter\y
    
    ; --------------------------------------------------------------------
    ; Case 1: Check distance to the Center Vertex
    ; --------------------------------------------------------------------
    minDistSq = relX*relX + relY*relY
    
    ; Get the absolute polar angle of the test point relative to center
    angle = ATan2(relX, relY)
    If angle < 0.0
      angle + (2.0 * #PI)
    EndIf
    
    ; Ensure SweepAngle does not exceed a full circle
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Normalize angles to check if the point lies within the angular sector wedge
    Protected.f diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    ; --------------------------------------------------------------------
    ; Case 2: Point is inside the angular wedge -> Project onto circular arc edge
    ; --------------------------------------------------------------------
    If diffAngle <= SweepAngle
      edgeX = *CircleCenter\x + Radius * Cos(angle)
      edgeY = *CircleCenter\y + Radius * Sin(angle)
      
      testX = *Pt\x - edgeX
      testY = *Pt\y - edgeY
      distSq = testX*testX + testY*testY
      
      If distSq < minDistSq
        minDistSq = distSq
      EndIf
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 3: Project onto the Start-Radius Line Segment
    ; --------------------------------------------------------------------
    edgeX = Cos(StartAngle)
    edgeY = Sin(StartAngle)
    ; Dot product projection to find scalar t along the radius line segment
    t = relX * edgeX + relY * edgeY
    If t < 0.0 : t = 0.0 : ElseIf t > Radius : t = Radius : EndIf
    
    testX = *Pt\x - (*CircleCenter\x + t * edgeX)
    testY = *Pt\y - (*CircleCenter\y + t * edgeY)
    distSq = testX*testX + testY*testY
    
    If distSq < minDistSq
      minDistSq = distSq
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 4: Project onto the End-Radius Line Segment
    ; --------------------------------------------------------------------
    endAngle = StartAngle + SweepAngle
    edgeX = Cos(endAngle)
    edgeY = Sin(endAngle)
    ; Dot product projection to find scalar t along the end radius line segment
    t = relX * edgeX + relY * edgeY
    If t < 0.0 : t = 0.0 : ElseIf t > Radius : t = Radius : EndIf
    
    testX = *Pt\x - (*CircleCenter\x + t * edgeX)
    testY = *Pt\y - (*CircleCenter\y + t * edgeY)
    distSq = testX*testX + testY*testY
    
    If distSq < minDistSq
      minDistSq = distSq
    EndIf
    
    ; Return the actual Euclidean distance by computing the square root at the very end
    ProcedureReturn Sqr(minDistSq)
  EndProcedure
  
  Procedure.i CircleSector_IsPointInside(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. INTERACTIVE MOUSE HIT-TESTING & LAYER SELECTION:
    ;    Used inside the mouse-click event loop to immediately determine if the 
    ;    crosshair tool resides inside a specialized radial copper landing pad, 
    ;    a pie-wedge symbol component, or a circular floor plan sector to quickly 
    ;    trigger object selection, dragging, or modification properties.
    ;
    ; 2. PIE-WEDGE KEEP-OUT & RECOVERY FILTER:
    ;    Acts as the spatial evaluation engine for radial restricted zones or angular 
    ;    clearance vectors. It verifies whether vias, tracks, or mechanical drill 
    ;    nodes are penetrating a forbidden circular slice space, instantly throwing 
    ;    a design rule warning upon violation.
    ; ===========================================================================
    Protected.f relX, relY, distSq, angle, diffAngle
    
    If Radius <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn #False
    EndIf
    
    ; Step 1: Check if the point is within the radius boundary (using squared distance to optimize speed)
    relX = *Pt\x - *CircleCenter\x
    relY = *Pt\y - *CircleCenter\y
    distSq = relX*relX + relY*relY
    
    If distSq > Radius * Radius
      ProcedureReturn #False ; Outside the circular boundary
    EndIf
    
    ; Step 2: Full circle optimization shortcut
    If SweepAngle >= 2.0 * #PI
      ProcedureReturn #True ; Point is within the radius of a full circle
    EndIf
    
    ; Step 3: Check if the point lies within the angular wedge
    angle = ATan2(relX, relY)
    If angle < 0.0
      angle + (2.0 * #PI)
    EndIf
    
    ; Normalize the target angle relative to the StartAngle
    diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    ; If the normalized difference angle fits inside the sweep arc, it is inside
    If diffAngle <= SweepAngle
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i Arc_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. DXF DIMENSION ARCS & WALL SNAPPING:
    ;    Essential for catching the mouse cursor on standard circular architectural 
    ;    arcs (e.g., door swing indicators, curved wall profiles, or dimension paths) 
    ;    without snapping to the invisible interior space or center of the circle.
    ;
    ; 2. TERMINAL ANCHOR CONNECTION:
    ;    If the cursor misses the active section of the arc, it automatically forces 
    ;    a snap directly to either the start vertex or end vertex, ensuring clean 
    ;    intersections when attaching straight walls or routing tracks to arc ends.
    ; ===========================================================================
    
    Protected.f dx, dy, length, angle, diffAngle, endAngle
    Protected.f startX, startY, endX, endY
    Protected.f distStartSq, distEndSq
    
    ; Clear output coordinates to prevent corrupt data on failure
    *OutPt\x = *CircleCenter\x
    *OutPt\y = *CircleCenter\y
    
    If Radius <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn #False
    EndIf
    
    ; Calculate the vector from the circle center to the test point
    dx = *Pt\x - *CircleCenter\x
    dy = *Pt\y - *CircleCenter\y
    
    ; Calculate the distance from center to the test point
    length = Sqr(dx*dx + dy*dy)
    
    ; Handle the degenerate case where the test point lies exactly at the center
    If length = 0.0
      ; Default to the start point of the arc if the direction is undefined
      *OutPt\x = *CircleCenter\x + Radius * Cos(StartAngle)
      *OutPt\y = *CircleCenter\y + Radius * Sin(StartAngle)
      ProcedureReturn #True
    EndIf
    
    ; Get the absolute polar angle of the test point relative to the center
    angle = ATan2(dx, dy)
    If angle < 0.0
      angle + (2.0 * #PI)
    EndIf
    
    ; Cap SweepAngle to a full circle rotation
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Normalize the target angle relative to the StartAngle
    diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    ; --------------------------------------------------------------------
    ; Case 1: Point's angle falls within the valid arc sweep window
    ; --------------------------------------------------------------------
    If diffAngle <= SweepAngle
      ; Project the point directly onto the circular boundary line
      *OutPt\x = *CircleCenter\x + (dx / length) * Radius
      *OutPt\y = *CircleCenter\y + (dy / length) * Radius
      ProcedureReturn #True
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 2: Point is outside the sweep -> Snap to the closer arc endpoint
    ; --------------------------------------------------------------------
    ; Calculate absolute world coordinates for Arc Start Point
    startX = *CircleCenter\x + Radius * Cos(StartAngle)
    startY = *CircleCenter\y + Radius * Sin(StartAngle)
    
    ; Calculate absolute world coordinates for Arc End Point
    endAngle = StartAngle + SweepAngle
    endX = *CircleCenter\x + Radius * Cos(endAngle)
    endY = *CircleCenter\y + Radius * Sin(endAngle)
    
    ; Calculate squared distances to avoid expensive Sqr() operations
    dx = *Pt\x - startX : dy = *Pt\y - startY
    distStartSq = dx*dx + dy*dy
    
    dx = *Pt\x - endX : dy = *Pt\y - endY
    distEndSq = dx*dx + dy*dy
    
    ; Snap to the closer endpoint of the arc segment
    If distStartSq < distEndSq
      *OutPt\x = startX
      *OutPt\y = startY
    Else
      *OutPt\x = endX
      *OutPt\y = endY
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.f Arc_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. CONTOUR HOVER SELECTION:
    ;    Used continuously in the mouse interaction loop to detect if the user's 
    ;    cursor is hovering within clicking range of a thin structural arc entity 
    ;    (e.g., drawing boundary curves or symbol outlines) to trigger visual highlights.
    ;
    ; 2. DESIGN RULE CHECK (DRC) FOR ARCHITECTURE:
    ;    Calculates the minimum wall clearance between straight structural partition 
    ;    elements and round columns or curved bay-window structural arcs to ensure 
    ;    insulation or zoning tolerances are maintained.
    ; ===========================================================================
    Protected.f dx, dy, length, angle, diffAngle, endAngle
    Protected.f startX, startY, endX, endY
    Protected.f distStartSq, distEndSq
    
    If Radius <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn 0.0
    EndIf
    
    ; Calculate the vector from the circle center to the test point
    dx = *Pt\x - *CircleCenter\x
    dy = *Pt\y - *CircleCenter\y
    
    ; Calculate the distance from center to the test point
    length = Sqr(dx*dx + dy*dy)
    
    ; Handle the degenerate case where the test point lies exactly at the center
    If length = 0.0
      ProcedureReturn Radius
    EndIf
    
    ; Get the absolute polar angle of the test point relative to the center
    angle = ATan2(dx, dy)
    If angle < 0.0
      angle + (2.0 * #PI)
    EndIf
    
    ; Cap SweepAngle to a full circle rotation
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Normalize the target angle relative to the StartAngle
    diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    ; --------------------------------------------------------------------
    ; Case 1: Point's angle falls within the valid arc sweep window
    ; --------------------------------------------------------------------
    If diffAngle <= SweepAngle
      ; The closest distance is the absolute radial delta to the curve surface
      ProcedureReturn Abs(length - Radius)
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 2: Point is outside the sweep -> Measure to the closer endpoint
    ; --------------------------------------------------------------------
    ; Calculate absolute world coordinates for Arc Start Point
    startX = *CircleCenter\x + Radius * Cos(StartAngle)
    startY = *CircleCenter\y + Radius * Sin(StartAngle)
    
    ; Calculate absolute world coordinates for Arc End Point
    endAngle = StartAngle + SweepAngle
    endX = *CircleCenter\x + Radius * Cos(endAngle)
    endY = *CircleCenter\y + Radius * Sin(endAngle)
    
    ; Calculate squared distances to endpoints
    dx = *Pt\x - startX : dy = *Pt\y - startY
    distStartSq = dx*dx + dy*dy
    
    dx = *Pt\x - endX : dy = *Pt\y - endY
    distEndSq = dx*dx + dy*dy
    
    ; Return the actual Euclidean distance to the closer terminal vertex
    If distStartSq < distEndSq
      ProcedureReturn Sqr(distStartSq)
    Else
      ProcedureReturn Sqr(distEndSq)
    EndIf
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Ellipse Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f Ellipse_Perimeter(R1.f, R2.f)
    ; Ramanujan Aproximation : 
    ;               (         3x²        )       a-b
    ; (a+b) * #PI * (1 +  ---------------)  ; x=-----  ; a = Rx/2; b=Ry/2
    ;               (      10+Sqr(4-3x²) )       a+b
    
    Protected.f a, b, ab, x, z
    a= R1*0.5 : b= R2*0.5
    ab = a+b
    x = (a-b)/ab
    z = x*x*3   ; z=3x²
    
    ProcedureReturn (z/(Sqr(4-z)+10) +1) * #PI*ab
  EndProcedure
  
  Procedure.f Ellipse_Area(R1.f, R2.f)
    ; A= a*b*#PI  = R1/2 * R2/2 * #PI
    ProcedureReturn R1 * R2 * #PI * 0.25
  EndProcedure
  
 Procedure.i Ellipse_PointNear(R1.f, R2.f, *Pt.TPoint2D, *PtOut.TPoint2D)
    Protected.i I
    Protected.f x, y, t, rr1, rr2
    Protected.f ct, st, f, fp
    
    R1 = Abs(R1) : R2 = Abs(R2)
    
    x = Abs(*Pt\X) : y = Abs(*Pt\Y) ; Fix: Syntaxfehler '=' entfernt
    rr1 = R1*R1 : rr2 = R2*R2
    
    If y=0 And (rr1-rr2 <= R1*x)
      t = 0
    ElseIf X=0 And (rr2-rr1 <= r2*y)
      t = #PI * 0.5
    Else
      
      If y=0
        y= Sqr(_epsilon(y) * r2)
      EndIf
      
      If x=0 
        x= Sqr(_epsilon(x) * r1)
      EndIf
      
      t = ATan2(x,y)
      
      Repeat
        
        ct = Cos(t) : st= Sin(t)
        
        f= (x- R1*ct) *R1*st - (y- R2*st) *R2*ct
        If Abs(f) <= 100 * _epsilon(f)
          Break
        EndIf
        
        ; max Iterations
        If I > 100
          Debug "Ellipse_PointNear: reacht iteration limit! T= " + StrF(t) + " : F= " + StrF(f)
          Break
        EndIf
        
        I+1
        
        fp= rr1*st*st + rr2*ct*ct + (x-R1*ct)*R1*ct + (y-R2*st)*R2*st
        t= t - f/fp
      ForEver
     
    EndIf
    
    ;  From the T value, we get the nearest point. 
    ; Take care of case where the point was in another quadrant.
    *PtOut\X = R1 * Cos(t) * Sign(*Pt\X)
    *PtOut\Y = R2 * Sin(t) * Sign(*Pt\Y)
    
  EndProcedure
  
  Procedure.f Ellipse_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. SPECIALIZED FOOTPRINT CLEARANCE:
    ;    Used to monitor safety distances around oval/elongated SMD power pads, 
    ;    ensuring neighboring traces respect insulation rules around non-standard 
    ;    geometry pins.
    ;
    ; 2. ISOLATION ROUTING IN MESHES:
    ;    Determines localized clearances when routing digital copper traces around 
    ;    oval heat-sink openings or structural keep-out zones.
    ; ===========================================================================
     
     Protected NearPt.TPoint2D
    Protected.f dx, dy
    
    If R1 <= 0.0 Or R2 <= 0.0
      ProcedureReturn 0.0
    EndIf
    
    ; Step 1: Normalize the test point relative to the ellipse center
    Protected RelPt.TPoint2D
    RelPt\x = *Pt\x - *EllipseCenter\x
    RelPt\y = *Pt\y - *EllipseCenter\y
    
    ; Step 2: Find the closest point on the centered ellipse perimeter
    ; Reuses the iterative Newton-Raphson implementation inside Ellipse_PointNear
    If Ellipse_PointNear(R1, R2, @RelPt, @NearPt) = #False
      ProcedureReturn 0.0
    EndIf
    
    ; Step 3: Calculate the Euclidean distance between the relative test point and the near point
    dx = RelPt\x - NearPt\x
    dy = RelPt\y - NearPt\y
    
    ProcedureReturn Sqr(dx*dx + dy*dy)
  EndProcedure

  Procedure.i Ellipse_IsPointInside(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. OVAL PIN HIT-TESTING:
    ;    Validates selection clicks on elongated through-hole pads (e.g., standard 
    ;    DC jacks or electrolytic capacitors) that use oval copper landing zones.
    ;
    ; 2. COMPONENT KEEP-OUT WIDGETS:
    ;    Acts as the bounding logic for oval keep-out zones under critical RF 
    ;    components or high-voltage capacitors where no traces are allowed.
    ; ===========================================================================
    
    Protected.f dx, dy
    Protected.f NormalizedValue
    
    If R1 <= 0.0 Or R2 <= 0.0
      ProcedureReturn #False
    EndIf
    
    ; Step 1: Translate the test point relative to the ellipse center
    dx = *Pt\x - *EllipseCenter\x
    dy = *Pt\y - *EllipseCenter\y
    
    ; Step 2: Apply the standard algebraic equation for an ellipse:
    ; (x^2 / r1^2) + (y^2 / r2^2) <= 1.0
    NormalizedValue = (dx * dx) / (R1 * R1) + (dy * dy) / (R2 * R2)
    
    ; If the resulting value is less than or equal to 1.0, the point is inside
    If NormalizedValue <= 1.0
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure.i Ellipse_TangentToPoint(*OutT1.TPoint2D, *OutT2.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, R1.f, R2.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. SMOOTH SHIELD BOUNDARY CONNECTING:
    ;    Computes the collision-free trajectory when connecting a signal trace to 
    ;    the boundary of an elongated ground shield or specialized oval capacitor pad.
    ;
    ; 2. MECHANICAL SILKSCREEN CURVES:
    ;    Generates the precise tangential endpoints needed to connect straight lines 
    ;    to oval casing shapes when rendering mechanical silkscreen component drawings.
    ; ===========================================================================
    
    Protected.f px, py, a2, b2, denom, clip
    Protected.f nx, ny, c, x0, y0, d, s, tx, ty
    
    ; Clear output structures
    *OutT1\x = 0.0 : *OutT1\y = 0.0
    *OutT2\x = 0.0 : *OutT2\y = 0.0
    
    If R1 <= 0.0 Or R2 <= 0.0
      ProcedureReturn #False
    EndIf
    
    ; Step 1: Translate external point relative to ellipse center
    px = *Pt\x - *CenterPt\x
    py = *Pt\y - *CenterPt\y
    
    a2 = R1 * R1
    b2 = R2 * R2
    
    ; Step 2: Verify if the external point lies strictly outside the ellipse
    If (px * px) / a2 + (py * py) / b2 <= 1.0
      ProcedureReturn #False ; No real tangents exist if point is inside or exactly on boundary
    EndIf
    
    ; Step 3: Compute the line equation coefficients of the polar line (nx*x + ny*y = c)
    nx = px / a2
    ny = py / b2
    c  = 1.0
    
    ; Step 4: Solve intersection of the polar line with the ellipse equation
    ; Handle case to avoid division by zero when nx or ny approaches zero
    If Abs(nx) > Abs(ny)
      denom = a2 * nx * nx + b2 * ny * ny
      x0 = c * a2 * nx / denom
      y0 = c * b2 * ny / denom
      
      clip = a2 * b2 * nx * nx - b2 * c * c + b2 * b2 * ny * ny
      If clip < 0.0 : ProcedureReturn #False : EndIf
      
      d = Sqr(clip)
      s = b2 * ny * d / (denom * nx)
      
      ; Calculate the two tangent contact points
      *OutT1\x = x0 + b2 * ny * d / denom
      *OutT1\y = y0 - a2 * nx * s / b2
      
      *OutT2\x = x0 - b2 * ny * d / denom
      *OutT2\x = y0 + a2 * nx * s / b2
    Else
      denom = a2 * nx * nx + b2 * ny * ny
      x0 = c * a2 * nx / denom
      y0 = c * b2 * ny / denom
      
      clip = a2 * b2 * ny * ny - a2 * c * c + a2 * a2 * nx * nx
      If clip < 0.0 : ProcedureReturn #False : EndIf
      
      d = Sqr(clip)
      
      ; Calculate the two tangent contact points
      *OutT1\x = x0 - b2 * ny * (a2 * nx * d / (denom * ny)) / a2
      *OutT1\y = y0 + a2 * nx * d / denom
      
      *OutT2\x = x0 + b2 * ny * (a2 * nx * d / (denom * ny)) / a2
      *OutT2\y = y0 - a2 * nx * d / denom
    EndIf
    
    ; Step 5: Translate back to absolute world coordinates
    *OutT1\x + *CenterPt\x : *OutT1\y + *CenterPt\y
    *OutT2\x + *CenterPt\x : *OutT2\y + *CenterPt\y
    
    ProcedureReturn #True
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- EllipseSector Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f EllipseSector_Perimeter(R1.f, R2.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. CNC CURVED CUTOUT & MILLING PATH PROFILE:
    ;    Computes the exact total cutting perimeter for an irregular, elongated 
    ;    elliptical wedge or decorative panel routing path. This perimeter length 
    ;    is crucial for the CAM software to schedule tool path cycles, predict 
    ;    CNC machining time, and adjust mechanical milling feed rates.
    ;
    ; 2. HOUSING ENCLOSURE & MESH PATH AUDITING:
    ;    Provides the absolute outline boundary length of an elliptic wedge layout 
    ;    or complex sheet-metal casing slice. Used to draw exact component enclosure 
    ;    graphics (silkscreen) and verify mechanical space enclosure rules.
    ; ===========================================================================
    Protected.f EndAngle, ArcLength, RadiusStart, RadiusEnd
    Protected.f x1, y1, x2, y2
    Protected.i i, Steps = 20
    Protected.f t, dt, r, dx, dy, lastX, lastY
    
    If R1 <= 0.0 Or R2 <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn 0.0
    EndIf
    
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    EndAngle = StartAngle + SweepAngle
    
    ; --------------------------------------------------------------------
    ; Step 1: Calculate the lengths of the two straight bounding radius
    ; --------------------------------------------------------------------
    ; Terminal point 1 (Start of Arc)
    x1 = R1 * Cos(StartAngle)
    y1 = R2 * Sin(StartAngle)
    RadiusStart = Sqr(x1*x1 + y1*y1)
    
    ; Terminal point 2 (End of Arc)
    x2 = R1 * Cos(EndAngle)
    y2 = R2 * Sin(EndAngle)
    RadiusEnd = Sqr(x2*x2 + y2*y2)
    
    ; --------------------------------------------------------------------
    ; Step 2: Compute the curved elliptic arc length via numerical integration
    ; --------------------------------------------------------------------
    ArcLength = 0.0
    dt = SweepAngle / Steps
    
    ; Initialize the starting coordinates of the arc segment loop
    lastX = x1
    lastY = y1
    
    For i = 1 To Steps
      t = StartAngle + i * dt
      
      ; Current point on the ellipse boundary
      x2 = R1 * Cos(t)
      y2 = R2 * Sin(t)
      
      ; Euclidean distance between the tiny step intervals
      dx = x2 - lastX
      dy = y2 - lastY
      ArcLength + Sqr(dx*dx + dy*dy)
      
      ; Cache current position for the next iteration step
      lastX = x2
      lastY = y2
    Next
    
    ; --------------------------------------------------------------------
    ; Step 3: Total perimeter is the sum of both straight limbs and the arc
    ; --------------------------------------------------------------------
    ProcedureReturn RadiusStart + RadiusEnd + ArcLength
  EndProcedure
  
  Procedure.f EllipseSector_Area(R1.f, R2.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ASYMMETRICAL COPPER SHIELD & PLANE QUANTIFICATION:
    ;    Calculates the exact surface area of an elongated, non-uniform elliptical 
    ;    wedge copper zone. This metric is essential for evaluating local copper mass 
    ;    distributions on signal layers, estimating total board weight, and computing 
    ;    exact galvanic electroplating solution requirements.
    ;
    ; 2. IRREGULAR ARCHITECTURAL SPACE COMPLIANCE:
    ;    Determines the precise square footage or internal area of decorative elliptic 
    ;    arches, complex curved wall alcoves, or specialized oval zoning footprints 
    ;    within structural architectural blueprints to fulfill localized environmental 
    ;    and spatial layout parameters.
    ; ===========================================================================
    
    Protected.f TransformedStart, TransformedEnd, TransformedSweep
    Protected.f Area2D
    
    If R1 <= 0.0 Or R2 <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn 0.0
    EndIf
    
    ; Cap SweepAngle to a full ellipse rotation (2*PI)
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Step 1: Transform angles from ellipse space into circular projection space.
    ; The standard parametric transformation relation is: tan(alpha_circle) = (R1 / R2) * tan(alpha_ellipse)
    TransformedStart = ATan2(Cos(StartAngle) * R2, Sin(StartAngle) * R1)
    TransformedEnd   = ATan2(Cos(StartAngle + SweepAngle) * R2, Sin(StartAngle + SweepAngle) * R1)
    
    ; Normalize circular space angles to positive range [0 ... 2*PI]
    If TransformedStart < 0.0 : TransformedStart + (2.0 * #PI) : EndIf
    If TransformedEnd < 0.0   : TransformedEnd   + (2.0 * #PI) : EndIf
    
    ; Calculate the true angular sweep inside the circular projection space
    TransformedSweep = TransformedEnd - TransformedStart
    If TransformedSweep < 0.0
      TransformedSweep + (2.0 * #PI)
    EndIf
    
    ; Handle floating point wrapping edge case for a full rotation
    If SweepAngle = 2.0 * #PI And TransformedSweep = 0.0
      TransformedSweep = 2.0 * #PI
    EndIf
    
    ; Step 2: Calculate unit circle sector area ratio and scale by Ellipse Factor (R1 * R2)
    ; Sector Area = (TransformedSweep / 2.0) * R1 * R2
    Area2D = TransformedSweep * 0.5 * R1 * R2
    
    ProcedureReturn Area2D
  EndProcedure
  
  Procedure.i EllipseSector_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. OVAL PIE-WEDGE CONTOUR SNAP OVERRIDES:
    ;    The foundational perimeter-matching tool for elongated, elliptical sector 
    ;    entities. When a user hovers the cursor crosshair near an irregular elliptic 
    ;    shielding zone or a curved architectural profile line, this function locks 
    ;    the coordinate straight onto the absolute nearest point of its multi-part 
    ;    boundary (the center vertex, the straight radial edges, or the elliptic arc).
    ;
    ; 2. T-JUNCTION CONNECTIONS TO OPEN OVAL WEDGES:
    ;    Delivers the exact target landing coordinates when an incoming connection 
    ;    track, structural wall partition, or dimension annotation extension wire 
    ;    needs to anchor itself flush against the boundary envelope of an elliptic 
    ;    wedge footprint layout.
    ; ===========================================================================
    
    Protected.f relX, relY, angle, diffAngle, endAngle
    Protected.f t, dt, testX, testY, distSq, minDistSq
    Protected.f nearX, nearY, edgeX, edgeY, edgeLenSq
    Protected.i i, Steps = 24
    
    ; Clear output coordinates
    *OutPt\x = *EllipseCenter\x
    *OutPt\y = *EllipseCenter\y
    
    If R1 <= 0.0 Or R2 <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn #False
    EndIf
    
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Normalize test point relative to the ellipse center
    relX = *Pt\x - *EllipseCenter\x
    relY = *Pt\y - *EllipseCenter\y
    
    ; --------------------------------------------------------------------
    ; Case 1: Check distance to the Center Vertex
    ; --------------------------------------------------------------------
    minDistSq = relX * relX + relY * relY
    nearX = *EllipseCenter\x
    nearY = *EllipseCenter\y
    
    ; --------------------------------------------------------------------
    ; Case 2: Project onto the Start-Radius Line Segment
    ; --------------------------------------------------------------------
    edgeX = R1 * Cos(StartAngle)
    edgeY = R2 * Sin(StartAngle)
    edgeLenSq = edgeX * edgeX + edgeY * edgeY
    If edgeLenSq > 0.0
      t = (relX * edgeX + relY * edgeY) / edgeLenSq
      If t < 0.0 : t = 0.0 : ElseIf t > 1.0 : t = 1.0 : EndIf
      
      testX = *Pt\x - (*EllipseCenter\x + t * edgeX)
      testY = *Pt\y - (*EllipseCenter\y + t * edgeY)
      distSq = testX * testX + testY * testY
      
      If distSq < minDistSq
        minDistSq = distSq
        nearX = *EllipseCenter\x + t * edgeX
        nearY = *EllipseCenter\y + t * edgeY
      EndIf
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 3: Project onto the End-Radius Line Segment
    ; --------------------------------------------------------------------
    endAngle = StartAngle + SweepAngle
    edgeX = R1 * Cos(endAngle)
    edgeY = R2 * Sin(endAngle)
    edgeLenSq = edgeX * edgeX + edgeY * edgeY
    If edgeLenSq > 0.0
      t = (relX * edgeX + relY * edgeY) / edgeLenSq
      If t < 0.0 : t = 0.0 : ElseIf t > 1.0 : t = 1.0 : EndIf
      
      testX = *Pt\x - (*EllipseCenter\x + t * edgeX)
      testY = *Pt\y - (*EllipseCenter\y + t * edgeY)
      distSq = testX * testX + testY * testY
      
      If distSq < minDistSq
        minDistSq = distSq
        nearX = *EllipseCenter\x + t * edgeX
        nearY = *EllipseCenter\y + t * edgeY
      EndIf
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 4: Project onto the Elliptic Arc segment (if point is inside wedge)
    ; --------------------------------------------------------------------
    ; Get polar angle of the relative test point
    angle = ATan2(relX, relY)
    If angle < 0.0 : angle + (2.0 * #PI) : EndIf
    
    ; Normalize angle relative to the StartAngle wedge
    diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    ; If the point's sector orientation falls within the active slice, 
    ; search the boundary curve for the optimal minimum point.
    If diffAngle <= SweepAngle
      dt = SweepAngle / Steps
      For i = 0 To Steps
        t = StartAngle + i * dt
        edgeX = *EllipseCenter\x + R1 * Cos(t)
        edgeY = *EllipseCenter\y + R2 * Sin(t)
        
        testX = *Pt\x - edgeX
        testY = *Pt\y - edgeY
        distSq = testX * testX + testY * testY
        
        If distSq < minDistSq
          minDistSq = distSq
          nearX = edgeX
          nearY = edgeY
        EndIf
      Next
    EndIf
    
    ; Save absolute closest coordinates to output
    *OutPt\x = nearX
    *OutPt\y = nearY
    ProcedureReturn #True
  EndProcedure
  
  Procedure.f EllipseSector_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ASYMMETRICAL PROXIMITY RULES & DRC VERIFICATION:
    ;    Calculates the exact minimum air-gap or insulation space between an 
    ;    independent track, via, or copper node and an elongated elliptical sector 
    ;    boundary (e.g., custom shielding pads or localized keep-out wedges) 
    ;    to validate electrical clearance constraints.
    ;
    ; 2. ELLIPTIC WEDGE CONTOR HOVER EVALUATION:
    ;    Used continuously inside the mouse interaction loop to determine if the 
    ;    crosshair tool is hovering within a pre-defined picking threshold of an 
    ;    elliptical wedge contour, allowing the UI to quickly trigger context-sensitive 
    ;    edge highlights or activate border modification states.
    ; ===========================================================================
    
    Protected.f relX, relY, angle, diffAngle, endAngle
    Protected.f t, dt, testX, testY, distSq, minDistSq
    Protected.f edgeX, edgeY, edgeLenSq
    Protected.i i, Steps = 24
    
    If R1 <= 0.0 Or R2 <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn 0.0
    EndIf
    
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Normalize test point relative to the ellipse center
    relX = *Pt\x - *EllipseCenter\x
    relY = *Pt\y - *EllipseCenter\y
    
    ; --------------------------------------------------------------------
    ; Case 1: Check distance to the Center Vertex
    ; --------------------------------------------------------------------
    minDistSq = relX * relX + relY * relY
    
    ; --------------------------------------------------------------------
    ; Case 2: Project onto the Start-Radius Line Segment
    ; --------------------------------------------------------------------
    edgeX = R1 * Cos(StartAngle)
    edgeY = R2 * Sin(StartAngle)
    edgeLenSq = edgeX * edgeX + edgeY * edgeY
    If edgeLenSq > 0.0
      t = (relX * edgeX + relY * edgeY) / edgeLenSq
      If t < 0.0 : t = 0.0 : ElseIf t > 1.0 : t = 1.0 : EndIf
      
      testX = *Pt\x - (*EllipseCenter\x + t * edgeX)
      testY = *Pt\y - (*EllipseCenter\y + t * edgeY)
      distSq = testX * testX + testY * testY
      
      If distSq < minDistSq
        minDistSq = distSq
      EndIf
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 3: Project onto the End-Radius Line Segment
    ; --------------------------------------------------------------------
    endAngle = StartAngle + SweepAngle
    edgeX = R1 * Cos(endAngle)
    edgeY = R2 * Sin(endAngle)
    edgeLenSq = edgeX * edgeX + edgeY * edgeY
    If edgeLenSq > 0.0
      t = (relX * edgeX + relY * edgeY) / edgeLenSq
      If t < 0.0 : t = 0.0 : ElseIf t > 1.0 : t = 1.0 : EndIf
      
      testX = *Pt\x - (*EllipseCenter\x + t * edgeX)
      testY = *Pt\y - (*EllipseCenter\y + t * edgeY)
      distSq = testX * testX + testY * testY
      
      If distSq < minDistSq
        minDistSq = distSq
      EndIf
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 4: Project onto the Elliptic Arc segment (if point is inside wedge)
    ; --------------------------------------------------------------------
    ; Get polar angle of the relative test point
    angle = ATan2(relX, relY)
    If angle < 0.0 : angle + (2.0 * #PI) : EndIf
    
    ; Normalize angle relative to the StartAngle wedge
    diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    ; If the point's sector orientation falls within the active slice,
    ; search the boundary curve for the optimal minimum point.
    If diffAngle <= SweepAngle
      dt = SweepAngle / Steps
      For i = 0 To Steps
        t = StartAngle + i * dt
        edgeX = *EllipseCenter\x + R1 * Cos(t)
        edgeY = *EllipseCenter\y + R2 * Sin(t)
        
        testX = *Pt\x - edgeX
        testY = *Pt\y - edgeY
        distSq = testX * testX + testY * testY
        
        If distSq < minDistSq
          minDistSq = distSq
        EndIf
      Next
    EndIf
    
    ; Return the actual Euclidean distance by computing the square root at the very end
    ProcedureReturn Sqr(minDistSq)
  EndProcedure

  Procedure.i EllipseSector_IsPointInside(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. INTERACTIVE MOUSE HOVER HIT-TESTING & LAYER SELECTION:
    ;    Used inside the mouse-click event handler to instantly determine if the 
    ;    crosshair tool resides within an elongated, asymmetrical elliptical sector 
    ;    zone, allowing the UI to quickly trigger object selection, dragging, 
    ;    or property modifications.
    ;
    ; 2. OVAL SECTOR WEDGE KEEP-OUT MATRIX:
    ;    Acts as the spatial evaluation engine for specialized irregular restricted 
    ;    zones or angular clearance fields. It verifies whether vias, tracks, or 
    ;    mechanical drilling nodes are penetrating a forbidden elliptical wedge space, 
    ;    instantly throwing a design rule warning upon violation.
    ; ===========================================================================
    Protected.f relX, relY, angle, diffAngle, normalizedValue
    
    If R1 <= 0.0 Or R2 <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn #False
    EndIf
    
    ; Step 1: Check if the point is within the solid ellipse boundary
    ; Standard algebraic ellipse equation: (x^2 / r1^2) + (y^2 / r2^2) <= 1.0
    relX = *Pt\x - *EllipseCenter\x
    relY = *Pt\y - *EllipseCenter\y
    normalizedValue = (relX * relX) / (R1 * R1) + (relY * relY) / (R2 * R2)
    
    If normalizedValue > 1.0
      ProcedureReturn #False ; Point is outside the global elliptic boundary
    EndIf
    
    ; Step 2: Full rotation optimization shortcut
    If SweepAngle >= 2.0 * #PI
      ProcedureReturn #True ; Point is inside a fully closed ellipse
    EndIf
    
    ; Step 3: Check if the point lies within the angular sector wedge
    angle = ATan2(relX, relY)
    If angle < 0.0
      angle + (2.0 * #PI)
    EndIf
    
    ; Normalize the target angle relative to the StartAngle
    diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    ; If the normalized difference angle fits inside the sweep arc, it is inside
    If diffAngle <= SweepAngle
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i EllipseArc_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. NATIVE DXF ELLIPSE ENTITY SNAPPING:
    ;    Directly processes native AutoCAD DXF 'ELLIPSE' entities with customized 
    ;    start/end parameter constraints. Allows the mouse cursor to grab the 
    ;    curved path of decorative silhouettes or architectural profiles.
    ;
    ; 2. HOVER DETECTOR FOR OPEN OVAL PATHS:
    ;    Enables magnetic cursor snapping onto open-ended architectural arches 
    ;    enforcing accurate connections when starting new intersecting lines from 
    ;    anywhere on the elliptic contour.
    ; ===========================================================================
    Protected.f relX, relY, angle, diffAngle, endAngle
    Protected.f t, dt, testX, testY, distSq, minDistSq
    Protected.f startX, startY, endX, endY
    Protected.f nearX, nearY, edgeX, edgeY
    Protected.i i, Steps = 32
    
    ; Clear output coordinates to prevent corrupt data on failure
    *OutPt\x = *EllipseCenter\x
    *OutPt\y = *EllipseCenter\y
    
    If R1 <= 0.0 Or R2 <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn #False
    EndIf
    
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Normalize test point relative to the ellipse center
    relX = *Pt\x - *EllipseCenter\x
    relY = *Pt\y - *EllipseCenter\y
    
    ; Get polar angle of the relative test point
    angle = ATan2(relX, relY)
    If angle < 0.0 : angle + (2.0 * #PI) : EndIf
    
    ; Normalize angle relative to the StartAngle wedge
    diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    minDistSq = Infinity()
    
    ; --------------------------------------------------------------------
    ; Case 1: Point's angle falls within the active slice -> Search curve
    ; --------------------------------------------------------------------
    If diffAngle <= SweepAngle
      dt = SweepAngle / Steps
      For i = 0 To Steps
        t = StartAngle + i * dt
        edgeX = *EllipseCenter\x + R1 * Cos(t)
        edgeY = *EllipseCenter\y + R2 * Sin(t)
        
        testX = *Pt\x - edgeX
        testY = *Pt\y - edgeY
        distSq = testX * testX + testY * testY
        
        If distSq < minDistSq
          minDistSq = distSq
          nearX = edgeX
          nearY = edgeY
        EndIf
      Next
      
      *OutPt\x = nearX
      *OutPt\y = nearY
      ProcedureReturn #True
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 2: Point is outside the sweep -> Snap to the closer endpoint
    ; --------------------------------------------------------------------
    ; Calculate absolute world coordinates for Arc Start Point
    startX = *EllipseCenter\x + R1 * Cos(StartAngle)
    startY = *EllipseCenter\y + R2 * Sin(StartAngle)
    
    ; Calculate absolute world coordinates for Arc End Point
    endAngle = StartAngle + SweepAngle
    endX = *EllipseCenter\x + R1 * Cos(endAngle)
    endY = *EllipseCenter\y + R2 * Sin(endAngle)
    
    ; Calculate squared distances to endpoints
    testX = *Pt\x - startX : testY = *Pt\y - startY
    Protected.f distStartSq = testX * testX + testY * testY
    
    testX = *Pt\x - endX : testY = *Pt\y - endY
    Protected.f distEndSq = testX * testX + testY * testY
    
    ; Snap to the closer terminal vertex of the elliptic arc
    If distStartSq < distEndSq
      *OutPt\x = startX
      *OutPt\y = startY
    Else
      *OutPt\x = endX
      *OutPt\y = endY
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.f EllipseArc_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f, StartAngle.f, SweepAngle.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. INTERACTIVE MOUSE SELECTION FILTER:
    ;    Continuously evaluates the precise clearance between the crosshair tool 
    ;    and complex imported DXF open ellipse assets, deciding whether the cursor 
    ;    is near enough to trigger graphical highlighting or active element editing.
    ;
    ; 2. DESIGN RULE BOUNDARY ANALYSIS:
    ;    Assists in structural validation loops by checking if newly sketched 
    ;    partition boundaries or wiring nodes are penetrating safety clearance fields 
    ;    surrounding decorative open elliptic curves.
    ; ===========================================================================
    Protected.f relX, relY, angle, diffAngle, endAngle
    Protected.f t, dt, testX, testY, distSq, minDistSq
    Protected.f startX, startY, endX, endY
    Protected.f distStartSq, distEndSq
    Protected.i i, Steps = 32
    
    If R1 <= 0.0 Or R2 <= 0.0 Or SweepAngle <= 0.0
      ProcedureReturn 0.0
    EndIf
    
    If SweepAngle > 2.0 * #PI
      SweepAngle = 2.0 * #PI
    EndIf
    
    ; Normalize test point relative to the ellipse center
    relX = *Pt\x - *EllipseCenter\x
    relY = *Pt\y - *EllipseCenter\y
    
    ; Get polar angle of the relative test point
    angle = ATan2(relX, relY)
    If angle < 0.0 : angle + (2.0 * #PI) : EndIf
    
    ; Normalize angle relative to the StartAngle wedge
    diffAngle = angle - StartAngle
    While diffAngle < 0.0 : diffAngle + (2.0 * #PI) : Wend
    While diffAngle >= (2.0 * #PI) : diffAngle - (2.0 * #PI) : Wend
    
    minDistSq = Infinity()
    
    ; --------------------------------------------------------------------
    ; Case 1: Point's angle falls within the active slice -> Search curve
    ; --------------------------------------------------------------------
    If diffAngle <= SweepAngle
      dt = SweepAngle / Steps
      For i = 0 To Steps
        t = StartAngle + i * dt
        testX = *Pt\x - (*EllipseCenter\x + R1 * Cos(t))
        testY = *Pt\y - (*EllipseCenter\y + R2 * Sin(t))
        distSq = testX * testX + testY * testY
        
        If distSq < minDistSq
          minDistSq = distSq
        EndIf
      Next
      
      ProcedureReturn Sqr(minDistSq)
    EndIf
    
    ; --------------------------------------------------------------------
    ; Case 2: Point is outside the sweep -> Measure to the closer endpoint
    ; --------------------------------------------------------------------
    ; Calculate absolute world coordinates for Arc Start Point
    startX = *EllipseCenter\x + R1 * Cos(StartAngle)
    startY = *EllipseCenter\y + R2 * Sin(StartAngle)
    
    ; Calculate absolute world coordinates for Arc End Point
    endAngle = StartAngle + SweepAngle
    endX = *EllipseCenter\x + R1 * Cos(endAngle)
    endY = *EllipseCenter\y + R2 * Sin(endAngle)
    
    ; Calculate squared distances to endpoints
    testX = *Pt\x - startX : testY = *Pt\y - startY
    distStartSq = testX * testX + testY * testY
    
    testX = *Pt\x - endX : testY = *Pt\y - endY
    distEndSq = testX * testX + testY * testY
    
    ; Return the actual Euclidean distance to the closer terminal vertex
    If distStartSq < distEndSq
      ProcedureReturn Sqr(distStartSq)
    Else
      ProcedureReturn Sqr(distEndSq)
    EndIf
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Capsule Functions
  ;- ----------------------------------------------------------------------
 
  Procedure.i Capsule_IsPointInside(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D, Radius.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. OVAL SMD/THRU-HOLE PAD HIT-TESTING:
    ;    Used continuously inside the mouse interaction loop to instantly detect 
    ;    if a user clicks inside an elongated oval landing pad (e.g., standard DC jacks, 
    ;    micro-USB shells, or high-power inductors) to select or highlight the part.
    ; ===========================================================================
    Protected NearPt.TPoint2D
    Protected.f dx, dy
    
    If Radius <= 0.0 : ProcedureReturn #False : EndIf
    
    ; Step 1: Project the test point onto the capsule's core centerline segment
    Line_PointNear(NearPt, *Pt, *LPtA, *LPtB)
    
    ; Step 2: Check if the distance to the centerline is less than or equal to the radius
    dx = *Pt\x - NearPt\x
    dy = *Pt\y - NearPt\y
    
    ; Using squared distance comparison to prevent slow Sqr() execution
    If (dx*dx + dy*dy) <= (Radius * Radius)
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure.i Capsule_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D, Radius.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. OVAL PAD EDGE SNAPPING:
    ;    Allows newly routed track segments or mechanical measurement wires to snap 
    ;    cleanly onto the outer copper boundary of a slot pad instead of jumping 
    ;    straight to the center terminal alignment axis.
    ; ===========================================================================
    
    Protected CenterNearPt.TPoint2D
    Protected.f dx, dy, length
    
    ; Clear output coordinates
    *OutPt\x = 0.0 : *OutPt\y = 0.0
    
    If Radius <= 0.0 : ProcedureReturn #False : EndIf
    
    ; Step 1: Find the nearest point on the core centerline segment
    Line_PointNear(@CenterNearPt, *Pt, *LPtA, *LPtB)
    
    dx = *Pt\x - CenterNearPt\x
    dy = *Pt\y - CenterNearPt\y
    length = Sqr(dx*dx + dy*dy)
    
    ; Handle edge case where the test point lies exactly on the centerline axis
    If length = 0.0
      ; Default shift pointing perpendicular to the centerline vector
      dx = *LPtB\y - *LPtA\y
      dy = *LPtA\x - *LPtB\x
      length = Sqr(dx*dx + dy*dy)
      
      If length = 0.0 ; Degenerate line case (A and B are identical, capsule is just a circle)
        *OutPt\x = *LPtA\x + Radius
        *OutPt\y = *LPtA\y
        ProcedureReturn #True
      EndIf
    EndIf
    
    ; Step 2: Push the centerline anchor point outward along the normalized direction vector by the radius
    *OutPt\x = CenterNearPt\x + (dx / length) * Radius
    *OutPt\y = CenterNearPt\y + (dy / length) * Radius
    
    ProcedureReturn #True
  EndProcedure

  Procedure.f Capsule_PointDistance(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D, Radius.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. INSULATION DESIGN RULE CHECK (DRC):
    ;    Calculates the exact minimum insulation clearance between custom mechanical 
    ;    slot cutouts or elongated connector shells and surrounding high-density traces 
    ;    to prevent high-voltage arcing or manufacturing issues.
    ; ===========================================================================
    
    Protected NearPt.TPoint2D
    Protected.f dx, dy, distToCenter
    
    If Radius <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; Step 1: Project point onto the centerline axis
    Line_PointNear(NearPt, *Pt, *LPtA, *LPtB)
    
    ; Step 2: Compute absolute Euclidean distance to the core center line
    dx = *Pt\x - NearPt\x
    dy = *Pt\y - NearPt\y
    distToCenter = Sqr(dx*dx + dy*dy)
    
    ; Step 3: Subtract the capsule profile radius. 
    ; If the result is negative, the point is inside the capsule (distance to boundary is 0.0)
    distToCenter - Radius
    If distToCenter < 0.0
      ProcedureReturn 0.0
    EndIf
    
    ProcedureReturn distToCenter
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Donut Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.i Donut_IsPointInside(*Pt.TPoint2D, *CenterPt.TPoint2D, RadiusIn.f, RadiusOut.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. THROUGH-HOLE VIA & PAD SELECTION HIT-TEST:
    ;    Verifies if a user clicked exactly on the copper ring of a through-hole pin 
    ;    or via. Clicking directly inside the hollow drill hole will correctly return 
    ;    #False, allowing precise selection filtering in dense layouts.
    ; ===========================================================================
    Protected.f dx, dy, distSq
    
    If RadiusOut <= 0.0 Or RadiusIn >= RadiusOut : ProcedureReturn #False : EndIf
    
    ; Calculate vector from center to test point
    dx = *Pt\x - *CenterPt\x
    dy = *Pt\y - *CenterPt\y
    distSq = dx*dx + dy*dy
    
    ; Point must be smaller/equal to outer radius AND greater/equal to inner radius
    If distSq <= (RadiusOut * RadiusOut) And distSq >= (RadiusIn * RadiusIn)
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure.i Donut_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, RadiusIn.f, RadiusOut.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. RING-PAD EDGE SNAPPING:
    ;    Snaps an incoming trace or cursor precisely to the closest physical boundary 
    ;    of the donut. If the cursor approaches from the outside, it snaps to the outer 
    ;    copper rim; if it approaches from inside the hole, it snaps to the inner drill wall.
    ; ===========================================================================
    Protected.f dx, dy, length, targetRadius
    
    ; Clear output coordinates
    *OutPt\x = 0.0 : *OutPt\y = 0.0
    
    If RadiusOut <= 0.0 Or RadiusIn >= RadiusOut : ProcedureReturn #False : EndIf
    
    dx = *Pt\x - *CenterPt\x
    dy = *Pt\y - *CenterPt\y
    length = Sqr(dx*dx + dy*dy)
    
    ; Handle case where test point sits exactly at the dead center
    If length = 0.0
      ; Default snap to the right side of the inner ring wall
      *OutPt\x = *CenterPt\x + RadiusIn
      *OutPt\y = *CenterPt\y
      ProcedureReturn #True
    EndIf
    
    ; Determine if the point is closer to the inner or outer perimeter line
    If Abs(length - RadiusIn) < Abs(length - RadiusOut)
      targetRadius = RadiusIn
    Else
      targetRadius = RadiusOut
    EndIf
    
    ; Project the anchor onto the selected target boundary ring
    *OutPt\x = *CenterPt\x + (dx / length) * targetRadius
    *OutPt\y = *CenterPt\y + (dy / length) * targetRadius
    
    ProcedureReturn #True
  EndProcedure

  Procedure.f Donut_PointDistance(*Pt.TPoint2D, *CenterPt.TPoint2D, RadiusIn.f, RadiusOut.f)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. DRC DRILL CLEARANCE & THERMAL RELIEF SEPARATION:
    ;    Calculates clearance from surrounding copper planes or routing tracks to 
    ;    either the outer pad rim or the inner bare drill-hole wall, which is essential 
    ;    for calculating correct isolation distances (thermal reliefs) during plane generation.
    ; ===========================================================================
    Protected.f dx, dy, length
    
    If RadiusOut <= 0.0 Or RadiusIn >= RadiusOut : ProcedureReturn 0.0 : EndIf
    
    dx = *Pt\x - *CenterPt\x
    dy = *Pt\y - *CenterPt\y
    length = Sqr(dx*dx + dy*dy)
    
    ; If the point is inside the active ring body, the distance to the shape is 0.0
    If length >= RadiusIn And length <= RadiusOut
      ProcedureReturn 0.0
    EndIf
    
    ; If the point is inside the hollow interior hole, distance is to the inner rim
    If length < RadiusIn
      ProcedureReturn RadiusIn - length
    EndIf
    
    ; Otherwise, the point is outside, distance is to the outer rim
    ProcedureReturn length - RadiusOut
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- TRACK EXTENSION ENGINE (INTERACTIVE BRIDGE MODULE)
  ;- ----------------------------------------------------------------------
  
  ; ===========================================================================
  ; CAD APPLICATION CONTEXT & USAGE:
  ; ===========================================================================
  ; 1. FRONTEND VS. BACKEND SEPARATION (PHYSICAL TRACK ENVELOPE):
  ;    While the PureBasic VectorDrawing library renders traces using decorative 
  ;    path commands (`VectorSourceLineWidth`), it possesses no logical awareness 
  ;    of spatial occupancy. This engine bridges that gap by treating thick tracks 
  ;    as analytical mathematical capsules (`CADf::Capsule`).
  ;
  ; 2. ADVANCED INTERACTIVE DRC SHORT-CIRCUIT SAFETY DETECTOR:
  ;    Instead of relying on zero-width centerline intersections, this routine 
  ;    evaluates the true physical volumetric boundaries of copper expansion. 
  ;    It ensures that parallel data buses or high-voltage lines running side-by-side 
  ;    are instantly flagged if their physical outer outer hulls touch or violate 
  ;    insulation thresholds, providing production-safe layout verification.
  ; ===========================================================================

  ; 1. PHYSICAL TRACK HIT-TESTING (Selection & Hovering)
  Procedure.i Track_IsMouseOver(*Track.TTrack, *MousePt.TPoint2D)
    Protected.f HalfWidth = *Track\Width * 0.5
    
    ; A thick track is mathematically a capsule around its centerline
    ProcedureReturn Capsule_IsPointInside(*MousePt, @*Track\PtA, @*Track\PtB, HalfWidth)
  EndProcedure
  
  ; 2. PHYSICAL TRACK-TO-TRACK COLLISION (The Ultimate DRC Short-Circuit Check)
  Procedure.i Track_CheckCollision(*Track1.TTrack, *Track2.TTrack)
    Protected.f CombinedClearance
    
    ; Layer verification: tracks on different copper layers cannot short-circuit
    If *Track1\Layer <> *Track2\Layer
      ProcedureReturn #False
    EndIf
    
    ; Calculate the minimum safety distance allowed between the two unsheathed centerlines
    CombinedClearance = (*Track1\Width * 0.5) + (*Track2\Width * 0.5)
    
    ; Check if the closest point between the two track paths violates the copper boundary.
    ; To do this, we measure the clearance from Track2's endpoints to Track1's capsule shield.
    If Capsule_PointDistance(@*Track2\PtA, @*Track1\PtA, @*Track1\PtB, CombinedClearance) = 0.0 Or
       Capsule_PointDistance(@*Track2\PtB, @*Track1\PtA, @*Track1\PtB, CombinedClearance) = 0.0
      ProcedureReturn #True ; DRC ALARM: Physical copper violation detected!
    EndIf
    
    ProcedureReturn #False ; Clear: Tracks respect safety boundaries
  EndProcedure
  
  ; ===========================================================================
  ; CAD : GEOMETRIC GENERATION INTERFACE (TRACK FACTORY)
  ; ===========================================================================
  Procedure.i Track_Create(*NewTrack.TTrack, Id.i, NetId.i, StartX.f, StartY.f, EndX.f, EndY.f, Width.f, Layer.i)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. OBJECT FACTORY & SANITIZATION STAGE:
    ;    Acts as the primary initialization gate for creating physical trace layers. 
    ;    It enforces strict structural integrity by blocking degenerate entries, 
    ;    such as traces with zero width or overlapping start/end vertices, which 
    ;    would cause mathematical instabilities inside the DRC engine.
    ;
    ; 2. NETLIST & GRAPHICS INTERACTION PRIMITIVE:
    ;    Standardizes how the user interface generates trace nodes during live routing. 
    ;    It binds absolute world coordinates instantly to the logical net structure, 
    ;    preparing the object for downstream viewport rendering and analytical clipping.
    ; ===========================================================================
    Protected.f dx, dy
    
    ; Validate clearance parameters
    If Width <= 0.0
      ProcedureReturn #False
    EndIf
    
    ; Check for degenerate geometry (zero-length protection)
    dx = EndX - StartX
    dy = EndY - StartY
    If (dx * dx + dy * dy) = 0.0
      ProcedureReturn #False ; A trace must have a physical length
    EndIf
    
    ; Populate the structural properties of the physical trace
    *NewTrack\Id    = Id
    *NewTrack\NetId = NetId
    *NewTrack\PtA\x = StartX
    *NewTrack\PtA\y = StartY
    *NewTrack\PtB\x = EndX
    *NewTrack\PtB\y = EndY
    *NewTrack\Width = Width
    *NewTrack\Layer = Layer
    
    ProcedureReturn #True
  EndProcedure

  ; ===========================================================================
  ; CAD: GEOMETRIC TRANSFER FUNCTION (STROKE-TO-POLYGON CONVERTER)
  ; ===========================================================================
  
  Procedure.i Track_To_Polygon(*OutPoly.TTrackPolygon, *Track.TTrack)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. STRUCTURAL GEOMETRY TRANSFER INTERFACE:
    ;    Acts as the analytical converter that transforms an abstract, zero-width 
    ;    logical track path (`TTrack`) into a fully defined, solid 2D bounding 
    ;    polygon (`TTrackPolygon`). This is essential for manufacturing exports 
    ;    such as Gerber apertures, CNC isolation milling paths, and DXF HULL geometry.
    ;
    ; 2. VECTOR STROKE TO SHAPE CONVERSION:
    ;    While rendering engines simulate thickness using pixel shading, this routine 
    ;    materializes the actual physical volume of the copper. It provides the 
    ;    exact vertex data needed to pass thick traces into heavy geometric sub-systems 
    ;    like ray-casters, arbitrary area clippers, and complex mesh triangulators.
    ; ===========================================================================
    Protected.f dx, dy, length, nx, ny, halfWidth
    
    halfWidth = *Track\Width * 0.5
    
    ; Calculate direction vector of the track centerline
    dx = *Track\PtB\x - *Track\PtA\x
    dy = *Track\PtB\y - *Track\PtA\y
    
    length = Sqr(dx*dx + dy*dy)
    
    ; Prevent calculation if the track segment has zero length
    If length = 0.0
      ProcedureReturn #False
    EndIf
    
    ; Calculate the normalized perpendicular normal vector (pointing right)
    nx = dy / length
    ny = -dx / length
    
    ; --- Transfer Step: Generate the 4 corners of the solid copper rectangle ---
    
    ; Corner 1: Top-Left (Shifted left from Start Point A)
    *OutPoly\Vertex[0]\x = *Track\PtA\x - nx * halfWidth
    *OutPoly\Vertex[0]\y = *Track\PtA\y - ny * halfWidth
    
    ; Corner 2: Top-Right (Shifted left from End Point B)
    *OutPoly\Vertex[1]\x = *Track\PtB\x - nx * halfWidth
    *OutPoly\Vertex[1]\y = *Track\PtB\y - ny * halfWidth
    
    ; Corner 3: Bottom-Right (Shifted right from End Point B)
    *OutPoly\Vertex[2]\x = *Track\PtB\x + nx * halfWidth
    *OutPoly\Vertex[2]\y = *Track\PtB\y + ny * halfWidth
    
    ; Corner 4: Bottom-Left (Shifted right from Start Point A)
    *OutPoly\Vertex[3]\x = *Track\PtA\x + nx * halfWidth
    *OutPoly\Vertex[3]\y = *Track\PtA\y + ny * halfWidth
    
    ProcedureReturn #True
  EndProcedure
  
  ; ===========================================================================
  ; CAD : INTERACTIVE SNAPPING INTERFACE (TRACK-TO-EDGE SNAPPER)
  ; ===========================================================================
  
  Procedure.i Track_SnapToEdge(*OutPt.TPoint2D, *Pt.TPoint2D, *Track.TTrack)
    ; ===========================================================================
    ; CAD APPLICATION CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. PHYSICAL TRACE BORDER SNAPPING:
    ;    Essential for micro-alignment and precision sketching. While classic wireframe 
    ;    snappers lock strictly onto the abstract, invisible centerline path of a trace, 
    ;    this procedure projects the coordinates onto the actual physical volumetric 
    ;    outer copper hull, matching exactly where the mask layer boundary sits.
    ;
    ; 2. BUNDLE ROUTING & T-JUNCTION ANCHORING:
    ;    Enables operators to snap and attach secondary interconnect lines, mechanical 
    ;    shield brackets, or architectural partition structures flush and parallel against 
    ;    the real physical outer casing profile of a heavy trace, ensuring gap-free 
    ;    boundary junctions across the layout canvas.
    ; ===========================================================================
    
    Protected.f dx, dy, length, nx, ny, halfWidth
    Protected NearPtA.TPoint2D, NearPtB.TPoint2D
    Protected.f distASq, distBSq
    
    ; Clear output coordinates
    *OutPt\x = 0.0 : *OutPt\y = 0.0
    
    halfWidth = *Track\Width * 0.5
    
    ; Calculate the direction vector of the track centerline
    dx = *Track\PtB\x - *Track\PtA\x
    dy = *Track\PtB\y - *Track\PtA\y
    length = Sqr(dx*dx + dy*dy)
    
    ; Prevent calculation if the track segment has zero length
    If length = 0.0
      ProcedureReturn #False
    EndIf
    
    ; Calculate the normalized perpendicular normal vector (pointing right)
    nx = dy / length
    ny = -dx / length
    
    ; Step 1: Project the test point onto the uninflected track center axis line
    Protected CenterNear.TPoint2D
    Line_PointNear(@CenterNear, *Pt, @*Track\PtA, @*Track\PtB)
    
    ; Step 2: Extrapolate the exact parallel outer left and right border coordinates
    NearPtA\x = CenterNear\x - nx * halfWidth
    NearPtA\y = CenterNear\y - ny * halfWidth
    
    NearPtB\x = CenterNear\x + nx * halfWidth
    NearPtB\y = CenterNear\y + ny * halfWidth
    
    ; Step 3: Use high-speed squared distance checking to see which boundary line is closer
    dx = *Pt\x - NearPtA\x : dy = *Pt\y - NearPtA\y
    distASq = dx*dx + dy*dy
    
    dx = *Pt\x - NearPtB\x : dy = *Pt\y - NearPtB\y
    distBSq = dx*dx + dy*dy
    
    ; Step 4: Lock the snap point onto the absolute closer physical copper edge
    If distASq < distBSq
      *OutPt\x = NearPtA\x
      *OutPt\y = NearPtA\y
    Else
      *OutPt\x = NearPtB\x
      *OutPt\y = NearPtB\y
    EndIf
    
    ProcedureReturn #True
  EndProcedure
    
  ;- ----------------------------------------------------------------------
  ;- Application Interaction Functions
  ;- ----------------------------------------------------------------------
  
  ; Inside your mouse loop while dragging a track:
  ; If IsRouting
  ;   Protected SnappedMouse.TPoint2D
  ;   
  ;   ; Force mouse coordinates into the 45-degree raster relative to the track start point
  ;   CADf::Track_Constraint45(@SnappedMouse, @ActiveTrack\PtA, @MousePt)
  ;   
  ;   ; Now pass the snapped point to your preview rendering and DRC checks!
  ;   ActiveTrack\PtB\x = SnappedMouse\x
  ;   ActiveTrack\PtB\y = SnappedMouse\y
  ; EndIf
  
  Procedure.i Track_Constraint45(*OutPt.TPoint2D, *StartPt.TPoint2D, *MousePt.TPoint2D)
    ; ===========================================================================
    ; CAD HANDBOOK CONTEXT & USAGE:
    ; ===========================================================================
    ; 1. ANGLING ENFORCEMENT & INTERACTIVE ROUTING STEERING:
    ;    The primary interface controller for enforcing professional layout habits. 
    ;    As the user drags a new track across the canvas, this function filters 
    ;    the raw mouse delta, instantly locking the track vector into clean, 
    ;    geometric 45-degree or 90-degree paths.
    ;
    ; 2. SIGNAL INTEGRITY & CLEAN SCHEMATICS ENFORCEMENT:
    ;    Crucial for electrical CAD to eliminate unstable, arbitrary trace slants 
    ;    which cause impedance mismatches, and vital for architectural layouts 
    ;    to guarantee perfectly square wall corners and parallel partitions.
    ; ===========================================================================
    Protected.f dx, dy, length, angle, snappedAngle
    
    ; Clear output coordinates
    *OutPt\x = *StartPt\x
    *OutPt\y = *StartPt\y
    
    ; Calculate the raw vector from the starting anchor to the current mouse position
    dx = *MousePt\x - *StartPt\x
    dy = *MousePt\y - *StartPt\y
    length = Sqr(dx*dx + dy*dy)
    
    ; If the mouse is exactly on the start point, the direction is undefined
    If length = 0.0
      ProcedureReturn #True
    EndIf
    
    ; Get the absolute polar angle of the mouse vector
    angle = ATan2(dx, dy)
    
    ; --- Snapping Stage: Round the angle to the nearest 45-degree interval (PI / 4) ---
    ; (#PI / 4.0 = 0.7853981)
    snappedAngle = Round(angle / (#PI * 0.25), #PB_Round_Nearest) * (#PI * 0.25)
    
    ; --- Re-projection Stage: Extrapolate the new constrained world coordinates ---
    *OutPt\x = *StartPt\x + length * Cos(snappedAngle)
    *OutPt\y = *StartPt\y + length * Sin(snappedAngle)
    
    ProcedureReturn #True
  EndProcedure

EndModule

;- ----------------------------------------------------------------------
;- TestCode
;- ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  ; ===========================================================================
  ; FILE : Cadf_InteractiveTest.pb
  ; DESC : Extended 2D Interactive Test Environment for CAD Primitives
  ;        Tests Capsule, Donut, Ellipse, Arc, and Rectangle routines.
  ; ===========================================================================
  
  InitSprite()
  InitKeyboard()
  InitMouse()
  
  ; --- Mock Structures (matching your framework) ---
  Structure TPoint2D
    x.f
    y.f
  EndStructure
  
  ; --- Open a standard clean windowed screen ---
  OpenWindow(0, 0, 0, 1024, 768, "Extended 2D CAD Geometry Module - Interactive Test Workspace", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  OpenWindowedScreen(WindowID(0), 0, 0, 1024, 768)
  
  ; --- Setup Test Primitives Coordinates ---
  ; 1. Capsule (Oval Slot Pad)
  Define CapA.TPoint2D, CapB.TPoint2D, CapRadius.f = 35.0
  CapA\x = 80.0  : CapA\y = 300.0
  CapB\x = 320.0 : CapB\y = 300.0
  
  ; 2. Donut (Through-Hole Via)
  Define DonutCenter.TPoint2D, DonutRadIn.f = 25.0, DonutRadOut.f = 65.0
  DonutCenter\x = 180.0 : DonutCenter\y = 520.0
  
  ; 3. Ellipse (Elongated SMD Pad / Layout Zone)
  Define EllipseCenter.TPoint2D, EllipseR1.f = 90.0, EllipseR2.f = 50.0
  EllipseCenter\x = 520.0 : EllipseCenter\y = 300.0
  
  ; 4. Arc (Circular DXF Bogen / Wall Indicator)
  Define ArcCenter.TPoint2D, ArcRadius.f = 80.0, ArcStartAngle.f, ArcSweepAngle.f
  ArcCenter\x = 520.0 : ArcCenter\y = 520.0
  ArcStartAngle = 0.0          ; 0 degrees (pointing right)
  ArcSweepAngle = #PI * 1.25   ; 225 degrees sweeping counter-clockwise
  
  ; 5. Rectangle (IC Body / Bounding Box)
  Define RectMinX.f = 750.0, RectMinY.f = 220.0, RectMaxX.f = 950.0, RectMaxY.f = 420.0
  
  ; 6. Track Intersection Test Coordinates
  Define Track1A.TPoint2D, Track1B.TPoint2D
  Define Track2A.TPoint2D, Track2B.TPoint2D
  Define IntersectPt.TPoint2D, HasIntersection.i
  
  ; Fixed track on screen
  Track1A\x = 750.0 : Track1A\y = 600.0
  Track1B\x = 950.0 : Track1B\y = 500.0
  
  ; Track that hitches to the mouse cursor (offset line segment)
  Track2B\x = -50.0 : Track2B\y = -50.0 ; Relative offset vector from mouse
  
  ; --- Runtime Interaction Variables ---
  Define MousePt.TPoint2D
  Define SnapPt.TPoint2D
  Define ColorCapsule.i, ColorDonut.i, ColorEllipse.i, ColorArc.i, ColorRect.i
  Define Event.i
  
  Repeat
    Repeat
      Event = WindowEvent()
      If Event = #PB_Event_CloseWindow : End : EndIf
    Until Event = 0
    
    ; Query hardware inputs
    ExamineMouse()
    ExamineKeyboard()
    
    ; Check if Escape key is pressed to exit
    If KeyboardPushed(#PB_Key_Escape)
      End
    EndIf
    
    MousePt\x = MouseX()
    MousePt\y = MouseY()
    
    ; Dynamic track 2 follows the mouse cursor position
    Track2A\x = MousePt\x
    Track2A\y = MousePt\y
    Track2B\x = MousePt\x + 60.0  ; Line vector points 60px right
    Track2B\y = MousePt\y + 60.0  ; and 60px down from cursor
    
    ; Clear with a solid dark CAD background
    ClearScreen(RGB(20, 24, 32)) 
    
    StartDrawing(ScreenOutput())
      
      ; =======================================================================
      ; 1. TEST & DRAW CAPSULE (OVAL PAD)
      ; =======================================================================
      If CADf::Capsule_IsPointInside(@MousePt, @CapA, @CapB, CapRadius)
        ColorCapsule = RGB(220, 50, 50)
      Else
        ColorCapsule = RGB(45, 100, 200)
      EndIf
      
      DrawingMode(#PB_2DDrawing_Default)
      Circle(CapA\x, CapA\y, CapRadius, ColorCapsule)
      Circle(CapB\x, CapB\y, CapRadius, ColorCapsule)
      Box(CapA\x, CapA\y - CapRadius, CapB\x - CapA\x, CapRadius * 2, ColorCapsule)
      LineXY(CapA\x, CapA\y, CapB\x, CapB\y, RGB(255, 255, 255))
      
      CADf::Capsule_PointNear(@SnapPt, @MousePt, @CapA, @CapB, CapRadius)
      LineXY(SnapPt\x - 8, SnapPt\y, SnapPt\x + 8, SnapPt\y, RGB(0, 255, 0))
      LineXY(SnapPt\x, SnapPt\y - 8, SnapPt\x, SnapPt\y + 8, RGB(0, 255, 0))
      
      ; =======================================================================
      ; 2. TEST & DRAW DONUT (THRU-HOLE VIA)
      ; =======================================================================
      If CADf::Donut_IsPointInside(@MousePt, @DonutCenter, DonutRadIn, DonutRadOut)
        ColorDonut = RGB(220, 50, 50)
      Else
        ColorDonut = RGB(210, 160, 40)
      EndIf
      
      Circle(DonutCenter\x, DonutCenter\y, DonutRadOut, ColorDonut)
      Circle(DonutCenter\x, DonutCenter\y, DonutRadIn, RGB(20, 24, 32)) ; Mask drill hole
      
      CADf::Donut_PointNear(@SnapPt, @MousePt, @DonutCenter, DonutRadIn, DonutRadOut)
      LineXY(SnapPt\x - 8, SnapPt\y, SnapPt\x + 8, SnapPt\y, RGB(0, 255, 0))
      LineXY(SnapPt\x, SnapPt\y - 8, SnapPt\x, SnapPt\y + 8, RGB(0, 255, 0))
      
      ; =======================================================================
      ; 3. TEST & DRAW ELLIPSE
      ; =======================================================================
      If CADf::Ellipse_IsPointInside(@MousePt, @EllipseCenter, EllipseR1, EllipseR2)
        ColorEllipse = RGB(220, 50, 50)
      Else
        ColorEllipse = RGB(140, 70, 190)
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Define r.i
      For r = 0 To EllipseR2 Step 2
        Ellipse(EllipseCenter\x, EllipseCenter\y, (EllipseR1 / EllipseR2) * r, r, ColorEllipse)
      Next
      Ellipse(EllipseCenter\x, EllipseCenter\y, EllipseR1, EllipseR2, ColorEllipse)
      
      CADf::Ellipse_PointNear(EllipseR1, EllipseR2, @MousePt, @SnapPt)
      SnapPt\x + EllipseCenter\x : SnapPt\y + EllipseCenter\y
      LineXY(SnapPt\x - 8, SnapPt\y, SnapPt\x + 8, SnapPt\y, RGB(0, 255, 0))
      LineXY(SnapPt\x, SnapPt\y - 8, SnapPt\x, SnapPt\y + 8, RGB(0, 255, 0))
      
      ; =======================================================================
      ; 4. TEST & DRAW CIRCULAR ARC (OPEN CURVE)
      ; =======================================================================
      ColorArc = RGB(0, 190, 190)
      DrawingMode(#PB_2DDrawing_Default)
      Define steps.i = 40, s.i
      Define t.f, dt.f = ArcSweepAngle / steps
      Define lastX.f = ArcCenter\x + ArcRadius * Cos(ArcStartAngle)
      Define lastY.f = ArcCenter\y + ArcRadius * Sin(ArcStartAngle)
      Define currX.f, currY.f
      
      For s = 1 To steps
        t = ArcStartAngle + s * dt
        currX = ArcCenter\x + ArcRadius * Cos(t)
        currY = ArcCenter\y + ArcRadius * Sin(t)
        LineXY(lastX, lastY, currX, currY, ColorArc)
        lastX = currX : lastY = currY
      Next
      
      CADf::Arc_PointNear(@SnapPt, @MousePt, @ArcCenter, ArcRadius, ArcStartAngle, ArcSweepAngle)
      LineXY(SnapPt\x - 8, SnapPt\y, SnapPt\x + 8, SnapPt\y, RGB(0, 255, 0))
      LineXY(SnapPt\x, SnapPt\y - 8, SnapPt\x, SnapPt\y + 8, RGB(0, 255, 0))
      
      ; =======================================================================
      ; 5. TEST & DRAW RECTANGLE
      ; =======================================================================
      If CADf::Rect_IsPointInside(@MousePt, RectMinX, RectMinY, RectMaxX, RectMaxY)
        ColorRect = RGB(220, 50, 50)
      Else
        ColorRect = RGB(80, 170, 80)
      EndIf
      
      Box(RectMinX, RectMinY, RectMaxX - RectMinX, RectMaxY - RectMinY, ColorRect)
      
      CADf::Rect_PointNear(@SnapPt, @MousePt, RectMinX, RectMinY, RectMaxX, RectMaxY)
      LineXY(SnapPt\x - 8, SnapPt\y, SnapPt\x + 8, SnapPt\y, RGB(0, 255, 0))
      LineXY(SnapPt\x, SnapPt\y - 8, SnapPt\x, SnapPt\y + 8, RGB(0, 255, 0))
      
      ; =======================================================================
      ; 6. TEST & DRAW TRACK INTERSECTION (DRC)
      ; =======================================================================
      ; Run the Design Rule Check: Do the two track segments collide right now?
      HasIntersection = CADf::LineSegments_Intersect(@IntersectPt, @Track1A, @Track1B, @Track2A, @Track2B)
      
      ; Set trace colors depending on short circuit evaluation state
      If HasIntersection
        Define ColorTrack.i = RGB(255, 50, 50)  ; Crimson Red = Short Circuit!
      Else
        Define ColorTrack.i = RGB(240, 120, 30) ; Copper Orange = Clear, No Collision
      EndIf
      
      ; Draw static track segment 1
      LineXY(Track1A\x, Track1A\y, Track1B\x, Track1B\y, ColorTrack)
      ; Draw dynamic mouse track segment 2
      LineXY(Track2A\x, Track2A\y, Track2B\x, Track2B\y, ColorTrack)
      
      ; If they cross, render a bold target crosshair directly on the short circuit coordinate
      If HasIntersection
        LineXY(IntersectPt\x - 12, IntersectPt\y, IntersectPt\x + 12, IntersectPt\y, RGB(255, 50, 50))
        LineXY(IntersectPt\x, IntersectPt\y - 12, IntersectPt\x, IntersectPt\y + 12, RGB(255, 50, 50))
        Circle(IntersectPt\x, IntersectPt\y, 4, RGB(255, 255, 255))
      EndIf
      
      ; =======================================================================
      ; 7. DRAW CROSSHAIR CURSOR & DISTANCE DISPLAY MATRIX
      ; =======================================================================
      DrawingMode(#PB_2DDrawing_Default)
      Circle(MousePt\x, MousePt\y, 4, RGB(255, 255, 255))
      
      ; Gather clearance metrics from the module
      Define DistCap.f = CADf::Capsule_PointDistance(@MousePt, @CapA, @CapB, CapRadius)
      Define DistDonut.f = CADf::Donut_PointDistance(@MousePt, @DonutCenter, DonutRadIn, DonutRadOut)
      Define DistEllipse.f = CADf::Ellipse_PointDistance(@MousePt, @EllipseCenter, EllipseR1, EllipseR2)
      Define DistArc.f = CADf::Arc_PointDistance(@MousePt, @ArcCenter, ArcRadius, ArcStartAngle, ArcSweepAngle)
      Define DistRect.f = CADf::Rect_PointDistance(@MousePt, RectMinX, RectMinY, RectMaxX, RectMaxY)
      
      ; HUD Dashboard Output
      DrawText(20, 15, " Capsule Distance : " + StrF(DistCap, 1) + " mm", RGB(255, 255, 255), RGB(20, 24, 32))
      DrawText(20, 35, " Donut Distance   : " + StrF(DistDonut, 1) + " mm", RGB(255, 255, 255), RGB(20, 24, 32))
      DrawText(20, 55, " Ellipse Distance : " + StrF(DistEllipse, 1) + " mm", RGB(255, 255, 255), RGB(20, 24, 32))
      DrawText(20, 75, " Circular Arc Dist: " + StrF(DistArc, 1) + " mm", RGB(255, 255, 255), RGB(20, 24, 32))
      DrawText(20, 95, " Rect Box Distance: " + StrF(DistRect, 1) + " mm", RGB(255, 255, 255), RGB(20, 24, 32))
      
      ; DRC Message HUD
      If HasIntersection
        DrawText(750, 630, "DRC ALARM: SHORT CIRCUIT!", RGB(255, 50, 50), RGB(20, 24, 32))
      Else
        DrawText(750, 630, "DRC STATUS: TRACKS CLEAR", RGB(50, 220, 50), RGB(20, 24, 32))
      EndIf
      
      DrawText(20, 730, "Move mouse to inspect geometry interaction. Press ESC to close workspace.", RGB(140, 150, 160), RGB(20, 24, 32))
      
    StopDrawing()
    
    FlipBuffers()
    Delay(1)
  ForEver
  
CompilerEndIf
; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 74
; FirstLine = 52
; Folding = ----------------
; Optimizer
; CPU = 5