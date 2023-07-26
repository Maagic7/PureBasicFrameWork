; ===========================================================================
;  FILE: PbFw_Module_IGES.pb
;  NAME: Module IGES : Initial Graphic Exchange Specification
;  DESC: IGES-Format is a 3D Solid Format, defined in the 1990s
;  DESC: It is an ASCII text based format. Each line is exactly 80 characters long!
;  DESC: IGES File Basic Implementations
;
; SOURCES: https://wiki.eclipse.org/IGES_file_Specification
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/02/12
; VERSION  :  0.0    Brainstorming Version
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;{
;}
; ============================================================================

;{ ====================      M I T   L I C E N S E        ====================
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

; https://wiki.eclipse.org/IGES_file_Specification


; { ==========     I G E S   F I L E   F O R M A T   B A S I C S      ==========

; ----------------------------------------------------------------------
;    IGES Format basics
; ----------------------------------------------------------------------

; 1. The model space X, Y, Z coordinate system is a righthanded
;     Cartesian coordinate system. It is fixed relative To the model

; Table 4. Examples of Physical Parent-Child Relationships
; ----------------------------------------------------------------------
; Parent                        - Child
; ----------------------------------------------------------------------
; Composite Curve               - all constituents
; Plane                         - bounding curve
; Point                         - display symbol
; Ruled Surface                 - rail curves
; Flash                         - defining entity
; Surface of Revolution         - axis, generatrix
; Tabulated Cylinder            - directrix
; Offset Curve                  - base curve
; Offset Surface                - surface
; Trimmed Surface               - surface
; Angular Dimension             - all subordinate entities
; Diameter Dimension            - all subordinate entities
; Flag Note                     - all subordinate entities
; General Label                 - all subordinate entities
; Linear Dimension              - all subordinate entities
; Ordinate Dimension            - all subordinate entities
; Point Dimension               - all subordinate entities
; Radius Dimension              - all subordinate entities
; General Symbol                - all subordinate entities
; Sectioned Area                - all boundary curves
; Entity Label Display          - all leaders
; Connect Point                 - display symbol, Text Display Templates
; Drawing                       - all annotation entities
; Subfigure Definition          - all associated entities
; Network Subfigure Definition  - all associated entities, Text Display Templates And Connect Points
; Nodal Display And Rotation    - all General Notes And Nodes
; Any entity With Entity Use    - all General Notes in text pointer field
; ----------------------------------------------------------------------

;}

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

  ;XIncludeFile "PbFw_Module_BUFFER.pb"  ; Module for Buffer handling
  ;XIncludeFile "PbFw_Module_STRING.pb"  ; Module for extended String handling

DeclareModule IGES
  
  Enumeration IGES_ColorNumber
    #IGES_COL_BLACK = 1
    #IGES_COL_RED 
    #IGES_COL_GREEN 
    #IGES_COL_BLUE 
    #IGES_COL_YELLOW 
    #IGES_COL_MAGENTA 
    #IGES_COL_CYAN
    #IGES_COL_WHITE
  EndEnumeration
  
  ;- ----------------------------------------------------------------------
  ;- Constants for IGES Entity-Types 
  ; ----------------------------------------------------------------------
  ;{ IGES Entities:  
  #IGES_CircularArc = 100        ; Circular Arc (Type 100)
  #IGES_CompositeCurve = 102     ; Composite Curve (Type 102)
  #IGES_ConicArc = 104
  #IGES_Plane = 108
  #IGES_Line = 110
  #IGES_ParametricSplineCurve = 112
  #IGES_ParametricSplineSurface = 114
  #IGES_Point = 116
  #IGES_RuledSurface = 118
  #IGES_SurfaceOfRevolution = 120
  #IGES_TabulatedCylinder = 122
  #IGES_Direction = 123
  #IGES_TransformationMatrix = 124
  #IGES_RationalBSplineCurve = 126
  #IGES_RationalBSplineSurface = 128
  #IGES_OffsetCurve = 130
  #IGES_OffsetSurface = 140
  #IGES_Boundary = 141
  #IGES_CurveOnParametricSurface = 142
  #IGES_BoundedSurface = 143
  #IGES_TrimmedSurface = 144
  #IGES_Block = 150
  #IGES_RightAngularWedge = 152
  #IGES_RightCircularCylinder = 154
  #IGES_RightCircularCone = 156
  #IGES_Sphere = 158
  #IGES_Torus = 160
  #IGES_SolidOfRevolution = 162
  #IGES_SolidOfLinearExtrusion = 164
  #IGES_Ellipsoid = 168
  #IGES_BooleanTree = 180
  #IGES_ManifoldSolid_BRepObject = 186
  #IGES_PlaneSurface = 190
  #IGES_RightCircularCylindricalSurface = 192
  #IGES_RightCircularConicalSurface = 194
  #IGES_SphericalSurface = 196
  #IGES_ToroidalSurface = 198
  #IGES_SubfigureDefinition = 308
  #IGES_SingularSubfigureInstance = 408
  #IGES_VertexList = 502
  #IGES_EdgeList = 504
  #IGES_Loop = 508
  #IGES_Face = 510
  #IGES_Shell = 514  
  
  ; Annotation entities defined in the Specification 
  #IGES_CopiousData = 106
  #IGES_AngularDimension =202 
  #IGES_CurveDimension =204 
  #IGES_DiameterDimension =206 
  #IGES_FlagNote =208 
  #IGES_GeneralLabel =210 
  #IGES_GeneralNote =212 
  #IGES_NewGeneralNote =213
  #IGES_LeaderArrow =214 
  #IGES_LinearDimension =216 
  #IGES_OrdinateDimension =218
  #IGES_PointDimension =220 
  #IGES_RadiusDimension =222 
  #IGES_GeneralSymbol =228 
  #IGES_SectionedArea =230 
  
  ; Structure entities defined in the Specification  
  #IGES_ConnectPoint = 132
  #IGES_Node = 134
  #IGES_FiniteElement = 136
  #IGES_NodalDisplacementAndRotation = 138
  #IGES_NodalResults = 146
  #IGES_ElementResults = 148
  #IGES_AssociativityDefinition = 302
  #IGES_LineFontDefinition = 304
  #IGES_MacroDefinition = 306
  #IGES_SubfigureDefinition = 308
  #IGES_TextFontDefinition = 310
  #IGES_TextDisplayTemplate = 312
  #IGES_ColorDefinition = 314
  #IGES_UnitsData = 316
  #IGES_NetworkSubfigureDefinition = 320
  #IGES_AttributeTableDefinition = 322
  #IGES_AssociativityInstance = 402
  #IGES_Drawing = 404
  #IGES_Property = 406
  #IGES_SingularSubfigureInstance = 408
  #IGES_View = 410
  #IGES_RectangularArraySubfigureInstance = 412
  #IGES_CircularArraySubfigureInstance = 414
  #IGES_ExternalReference = 416
  #IGES_NodalLoad = 418
  #IGES_NetworkSubfigureInstance = 420
  #IGES_AttributeTableInstance = 422
  ;}
  
  ;- ----------------------------------------------------------------------
  ;- Helper Structures
  ; ----------------------------------------------------------------------
  ;{
  
  Structure TEntityRef    ; Structure for a Entity Refernce
    Type.i      ; Type of Entity {#IGES_CircularArc ...  #IGES_Shell}
    pEntity.i   ; Pointer to the Entity Object
  EndStructure
  
  Structure TIges3DObject   ; Main Structure for an IGES-3D-Object
    Name.s                  ; 3D Object Name
    List ENT.TEntityRef()   ; The List of Entities
  EndStructure
  
  Structure T3DPoint
    X.f   ; x coordinate of point 
    Y.f   ; y coordinate of point 
    Z.f   ; z coordinate of point     
  EndStructure
  
  ;- ----------------------------------------------------------------------
  ;- IGES Structures
  ; ----------------------------------------------------------------------
  
  ; Simple circular arc of constant radius. Usually defined With a Transformation Matrix Entity (Type 124) 
  Structure TCircularArc ; Type 100
   	Z.f     ; z displacement on XT,YT plane
   	X.f     ; x coordinate of center
   	Y.f     ; y coordinate of center
   	X1.f    ; x coordinate of start
   	Y1.f    ; y coordinate of start
   	X2.f    ; x coordinate of End
   	Y2.f    ; y coordinate of End 
  EndStructure
  
  ;Groups other curves to form a composite. Can use Ordered List, Point, Connected Point, and Parameterized Curve entities 
  Structure TCompositeCurve ; Type 102
    N.i                     ; Number of curves comprising this entity
    List pCurve.i()         ; Pointer to curves 1..N   
  EndStructure
  
  ; Arc defined by the equation: Axt^2 + Bxtyt + Cyt^2 + Dxt + Eyt + F = 0, With a Transformation Matrix (Entity 124)
  ; Can Define an ellipse, parabola, Or hyperbola.
  Structure TConicARC ; Type 104  
    A.f     ;	coefficient of xt^2 
    B.f     ;	coefficient of xtyt 
    C.f     ;	coefficient of yt^2 
    D.f     ;	coefficient of xt 
    E.f     ;	coefficient of yt 
    F.f     ;	scalar coefficient 
    Pt1.T3DPoint  ; coordinates of start point 
    Pt2.T3DPoint  ; coordinates of end point 
;     X1.f    ;	x coordinate of start point 
;     Y1.f    ;	y coordinate of start point 
;     Z1.f    ;	z coordinate of start point 
;     X2.f    ;	x coordinate of End point 
;     Y2.f    ;	y coordinate of End point 
;     Z2.f    ;	z coordinate of End point
  EndStructure
  
  Structure TCopiousData    ; Type 106
    Tye.i                   ; {1,2,3} 1=(x,y) Point; 2=(x,y,z) points; 3=(x,y,z,i,j,k)
    List Pt.T3DPoint()      ; Points With values like in Type
    ; List pt.f()           ; Points with values like in Type
  EndStructure
  
  ; Defines a plane by Ax + By +Cz = D, And a curve pointer that gives the plane its bounds
  ; Also gives a display symbol at a specified vertex And With a specified size
  Structure TPlane ; Type 108
    A.f       ; coefficient of x
   	B.f       ; coefficient of y
  	C.f       ; coefficient of z
   	D.f       ; scalar coefficient
   	Bounds.i  ; Pointer To bounding curve
   	Pt.T3DPoint ; coordinates of display symbol
;     X.f       ; x coordinate of display symbol
;     Y.f       ; y coordinate of display symbol
;     Z.f       ; z coordinate of display symbol
    Size.i    ; size of display symbol   
  EndStructure
  
  ; Defines a line using an End point And a start point 
  Structure TLine ; Type 110
    P1.T3DPoint ; coordinates of start point 
    P2.T3DPoint ; coordinates of emd point 
  EndStructure
  
  ; Defines a curve As a series of parametric polynomials, given As Ax(i) + sBx(i) + s^2 Cx(i) + s^3 Dx(i)
  ; For the x component in the i'th section. The same function is used for y and z. 
  Structure TParametricSplineCurve  ; Type 112
    
  EndStructure
  
  ; Defines a surface As a series of parametric surfaces, splitting them into a grid (i by j). They are described by the equation
  ; Ax(i,j) + sBx(i,j) + s^2 Cx(i,j) + s^3 Dx(i,j) + tEx(i,j) + tsEx(i,j) + ts^2 Fx(i,j) + ts^3 Gx(i,j) + t^2 Kx(i,j) +
  ;   t^2 s Lx(i,j) + t^2 s^2 Mx(i,j) + t^2 s^3 Nx(i,j) + t^3 Px(i,j) + t^3 s Qx(i,j) + t^3 s^2 Rx(i,j) + t^3 s^2 Sx(i,j)
  ; Note that that equation is the description of the X element in the i,j section of the spline surface. 
  Structure TParametricSplineSurface ; Type 114
    
  EndStructure
    
  ; Defines a point in 3D space. 
  Structure TPoint  ; Type 116 
    Pt.T3DPoint  ;coordinates of point 
;     X.f       ; x coordinate of point 
;     Y.f       ; y coordinate of point 
;     Z.f       ; z coordinate of point 
    ptr.i     ; Pointer To sub-figure entity, specifies display symbol 
  EndStructure
  
  ; This is a surface formed by sweeping over an area between defined curves. The sweep can be done by lines connecting points of 
  ; equal arc length (Form 0) Or equal parametric values (Form1). Valid curves would be points, lines, circles, conics, parametric splines,
  ; rational B-splines, composite curves, Or any parametric curves. 
  Structure TRuledSurface ; Type 118
    ptr1.i          ; 	pointer To first curve
    ptr2.i          ; 	pointer To second curve
    DirFlag.i       ; 	Direction. 0=FirstToFirst, LastToLast; 1=FirstToLast, LastToFirst
    DevFlag.i       ; 	Developable: 0=Possibly Not; 1=Yes     
  EndStructure
  
  ; This solid is formed by rotating a bounded surface on a specified axis and recording the area it passes through
  Structure TSurfaceOfRevolution ; Type 120
  	Axis.i          ; Pointer To Line describing axis of rotation
    Surface.i       ; Pointer To generatrix entity
    SA.f 	          ; Start angle (Rad)
    EA.f 	          ; End angle (Rad)    
  EndStructure
  
  ; Formed by moving a line segment parallel To itself along a curve called the directrix. 
  ; Curve may be any of: a line, a circular arc, a conic arc, a parametric spline curve, Or a rational B-spline curve. 
  Structure TTabulatedCylinder ; Type 122
    pCurve.i                   ; Pointer To directrix
    Pt.T3DPoint  ; coordinates of line End
;     Lx.f          ; x coordinate of line End
;     Ly.f          ; y coordinate of line End
;     Lz.f          ; z coordinate of line End   
  EndStructure
  
  ; Gives a direction in 3 Dimensions, where x^2 + y^2 + z^2 > 0 
  Structure  TDirection ; Type 123
    X1.f      ; x component
    Y1.f      ; y component
    Z1.f      ; z component
  EndStructure
  
  ; Transforms entities by matrix multiplication and vector addition to give a translation, as shown below
  ;            | R11  R12  R13 |          | T1 |              
  ;        R=  | R21  R22  R23 |     T =  | T2 |        ET = RE + T, where E is the entity coordinate 
  ;            | R31  R32  R33 |          | T3 |           
  
  Structure TTransformationMatrix ; Type 124
    R11.f   ; 1st Row
    R12.f
    R13.f
    T1.f    ; 1st T vector value 
    R21.f   ; 2nd Row
    R22.f
    R23.f
    T2.f    ; 2nd T vector value 
    R31.f   ; 3th Row
    R32.f
    R33.f
    T3.f    ; 3th T vector value 
  EndStructure
  
  Structure TRationalBSplineCurve ; Type 126
    
  EndStructure
  
  ; This is a surface entity defined by multiple surfaces. The form number describes the general type:
  ; 0=determined from Data, 1=Plane, 2=Right circular cylinder, 3=Cone, 4=Sphere, 5=Torus, 6=Surface of revolution,
  ; 7=Tabulated cylinder, 8=Ruled surface, 9=General quadratic surface. 
  Structure TRationalBSplineSurface ; Type 128
    
  EndStructure
  
  ; Contains the data to determine curve offsets 
  Structure TOffsetCurve ; Type 130
    
  EndStructure
  
  ; Gives the Data necessary To calculate the offset surface from a particular surface
  Structure  TOffsetSurface ; Type 140
    
  EndStructure
  
  ; Identifies a surface boundary consisting of curves lying on a surface
  Structure TBoundary ; Type 141
    
  EndStructure
  
  ; Associates a curve and a surface, gives how a curve lies on the specified surface
  Structure TCurveOnParametricSurface ; Type 142
    
  EndStructure
  
  ; Represents a surface bounded by Boundary Entities. 
  Structure TBoundedSurface ; Type 143
    
  EndStructure
  
  ; Describes a surface trimmed by a boundary consisting of boundary Curves. 
  Structure TTrimmedSurface ; Type 144
    
  EndStructure
  
  ; Defines a CSG Block object. 
  Structure TBlock ; Type 150
    LX.f      ; Side length along x axis
    LY.f      ; Side length along y axis
    LZ.f      ; Side length along z axis
    X.f       ; Corner x coordinate
    Y.f       ; Corner y coordinate
    Z.f       ; Corner z coordinate
    Xi.f      ; Unit vector along x direction
    Xj.f      ; 
    Xk.f      ; 
    Zi.f      ; Unit vector along z direction
    Zj.f      ; 
    Zk.f      ;     
  EndStructure
  
  ; Defines a CSG Wedge 
  Structure TRightAngularWedge ; Type 152
    LX.f      ; 	Size along x axis
    LY.f      ; 	Size along y axis
    LZ.f      ; 	Size along z axis
    TLX.f     ; 	Distance from local x axis LY away
    X.f       ; 	Coordinates of corner
    Y.f       ; 	
    Z.f       ;  	
    Xi.f      ; 	Normal vector For x axis
    Xj.f      ; 	
    Xk.f      ; 	
    Zi.f      ; 	Normal vector For z axis
    Zj.f      ; 	
    Zk.f      ; 	    
  EndStructure
  
  ; Defines a CSG cylinder
  Structure TRightCircularCylinder ; Type 154
    H.f       ; Height
    R.f       ; Radius
    X.f       ; X coordinate of larger face center
    Y.f       ; Y coordinate of larger face center
    Z.f       ; Z coordinate of larger face center
    i.f       ; Normal vector along axis (from larger face toward smaller)
    j.f       ; 
    k.f       ;      
  EndStructure
  
  ; Defines a CSG Cone primitive object. 
  Structure TRightCircularCone ; Type 156
    H.f     ; Height
    R1.f    ; Larger radius
    R2.f    ; Smaller radius
    X.f     ; X coordinate of larger face center
    Y.f     ; Y coordinate of larger face center
    Z.f     ; Z coordinate of larger face center
    i.f     ; Normal vector along axis (from larger face toward smaller)
    j.f     ; 
    k.f     ;  
  EndStructure
  
  ;Defines the CSG Sphere primitive type 
  Structure TSphere ; Type 158
    R.f             ; 	Radius
    Pt.T3DPoint     ; coordinates of center
;     X.f             ; X coordinate of center
;     Y.f             ; Y coordinate of center
;     Z.f             ; Z coordinate of cent   
  EndStructure
  
  ; Defines the CSG Torus primitive type 
  Structure TTorus ; Type 160
    R1.f          ; Radius from center To middle of loop (how big torus is)
    R2.f          ; Radius of loop (how thick torus is)
    Pt.T3DPoint   ; coordinates of center
;     X.f          ; X coordinate of center
;     Y.f          ; Y coordinate of center
;     Z.f          ; Z coordinate of center
    vPt.T3DPoint  ; Normal vector through center hole
;     i.f         ; Normal vector through center hole
;     j.f 	
;     k.f 	
  EndStructure
  
  ; Describes a solid that is formed by rotating a curve around an axis 
  Structure TSolidOfRevolution ; Type 162
    C.i ; Pointer 	Curve To revolve
    F.f ; 	Fraction of full rotation (Default 1)
    X.f ; 	X coordinate To revolve around
    Y.f ; 	Y coordinate To revolve around
    Z.f ; 	Z coordinate To revolve around
    i.f ; 	Vector specifying axis of revolution
    j.f ; 	
    k.f ; 	    
  EndStructure
  
  ; Describes a solid that is formed by translating an area by a planar curve
  Structure TSolidOfLinearExtrusion ; Type 164
    C.i       ; Pointer 	Closed curve To translate
    L.f       ; Length of extrusion
    i.f       ; Vector specifying direction of extrusion
    j.f       ; 	
    k.f       ; 	    
  EndStructure 
  
  ; Defines the CSG Ellipsoid primitive type, defined by the curve: X^2/LX^2 + Y^2/LY^2 + Z^2/LZ^2 = 1
  Structure TEllipsoid ; Type 168
    LX.f      ;	X scaling
    LY.f      ; Y scaling
    LZ.f      ; Z scaling
    X.f       ; X coordinate of center
    Y.f       ;	Y coordinate of center
    Z.f       ; Z coordinate of center
    i1.f      ; Unit vector along local X axis (major axis)
    j1.f      ; 	
    k1.f      ; 	
    i2.f      ; Unit vector along local Z axis (minor axis)
    j2.f      ; 	
    k2.f      ;
  EndStructure
  
  ; Provides a CSG Boolean tree structure, for constructing CSG geometries.
  ; The three types of operations it accepts are denoted by an integer:
  ; 1 = Union
  ; 2 = Intersection
  ; 3 = Difference
  ; The Data is provided in post-order notation, giving operands And operations. 
  Structure TBooleanTree ; Type 180
    
  EndStructure
  
  ; Defines a closed, solid, finite volume in R^3 by enumerating the boundary
  Structure TManifoldSolid_BRepObject ; Type 186
    Shell.i         ; Pointer To the shell entity (Type 514)
    FLAG.l          ; Orientation flag- True = shell agrees With faces
    N.i             ; Number of void shells
    VShell1.i       ; Pointer First void shell
    List VFLAG.l()  ; Orientation Flags of VShell1     
  EndStructure
  
  ; The Plane Surface is given by a point on the plane and the normal. Used by a Face entity
  Structure TPlaneSurface ; Type 190
    pPoint.i       ;	Pointer To Point Entity (Type 116)
    pNormal.i      ;	Pointer To Direction Entity (Type 123)
    pRef.i         ;	Pointer To Direction Entity (Type 123), Gives the reference direction
  EndStructure
  
  ; Defines the surface for a right circular cylinder. Used by a Face Entity. 
  Structure TRightCircularCylindricalSurface ; Type 192
    pPoint.i      ; Pointer To Point Entity (Type 116) Point on axis
    pAxis.i       ; Pointer To Direction Entity (Type 123) Axis direction
  	R.f           ; Radius
    pRef.i        ; Pointer To Direction Entity (Type 123) Gives the reference direction
  EndStructure
  
  ; Defines a surface as a circular cone. Used by a Face Entity. 
  Structure TRightCircularConicalSurface ; Type 194
    pPoint.i      ; Pointer To Point Entity (Type 116) Point on axis
    pAxis.i       ; Pointer To Direction Entity (Type 123) Axis direction
    R.f           ; Radius at Point
    ANG.f         ; Angle between axis and cone surface
    Ref.i         ; Pointer To Direction Entity (Type 123) Gives the reference direction
  EndStructure
  
  ; Defines a surface as a sphere. Used by a Face Entity. 
  Structure TSphericalSurface ; Type 196
    pPoint.i      ;  Pointer To Point Entity (Type 116) Center point
    R.f           ; Radius
    pAxis.i       ; Pointer To Direction Entity (Type 123) Axis direction
 	  pRef.i        ; Pointer To Direction Entity (Type 123) Gives the reference direction
  EndStructure
  
  ; Defines a surface as a Torus. Used by the Face Entity. 
  Structure TToroidalSurface ; Type 198
    pPoint.i      ; Pointer To Point Entity (Type 116) Point on axis
    pAxis.i       ;	Pointer To Direction Entity (Type 123) Axis direction
    R1.f          ; Major radius
    R2.f          ; Minor radius
    pRef.i        ; Pointer To Direction Entity (Type 123)  Gives the reference direction      
  EndStructure
  
  ;Combines other entity definitions into one Entity. 
  Structure TSubfigureDefinition ; Type 308
    Depth.i       ; Depth of subfigure (With nesting)
    Name.s        ;	Subfigure Name
    N.i           ;	Number of entities in subfigure
    List pE.i()   ; Pointer to associated entities
  EndStructure
  
  ; Used to give custom colors for other entities, in RGB color space. 
  Structure TColorDefinition ; Type 314
    Red.f         ; Red value, from 0.0 - 100.0
    Green.f       ; Green value, from 0.0 - 100.0
    Blue.f        ; Blue value, from 0.0 - 100.0
    Name.s        ; Optional color name      
  EndStructure
  
  ; Gives the Subfigure Definition Entity a defined subfigure. 
  Structure TSingularSubfigureInstance ; Type 408
    SD.i          ; The Subfigure Definition Entity (type 308)
    T.T3DPoint    ; Translation in x,y,z direction
;     X.f           ; Translation in the x direction
;     Y.f           ; Translation in the y direction
;     Z.f           ; Translation in the z direction
    S.f           ; Scale factor 
  EndStructure
 
  ; Provides a list of vertices for specifying B-Rep Geometries. 
  Structure TVertexList       ; Type 502
    N.i                       ; Number of vertices in List 
    List Vertex.T3DPoint()    ; List of Vertex coordinates
  EndStructure
  
  Structure TEdge   ; helper Structure - not defined in IGES
    Curve.i         ; Pointer First model space curve
    SVL.i           ; Pointer Vertex list for start vertex 
    S.i             ; Index of start vertex in SVL
    ELV.i           ; Pointer Vertex list for end vertex
    E.i             ; Index of end vertex in EVL
  EndStructure
  
  ; Provides a list of edges, comprised of vertices, for specifying B-Rep Geometries.
  Structure TEdgeList   ; Type 504
    N.i                 ; Number of Edges in List 
    List Edge.TEdge()   ; List of Edges
  EndStructure
  
  ; Defines a loop, specifying a bounded face, for B-Rep Geometries
  Structure TLoop       ; Type 508
    
  EndStructure
  
  ; Defines a bound portion of three dimensional space (R^3) which has a finite area. Used to construct B-Rep Geometries. 
  Structure TFace       ; Type 510
    
  EndStructure
  
  ; Defines edge connected sets of faces for defining B-Rep geometries
  Structure TShell ; Type 514
    
  EndStructure
;}
 

 EndDeclareModule
  
 Module IGES
   
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
   
  ;- ----------------------------------------------------------------------
  ;- DataSection
  ; ----------------------------------------------------------------------
  DataSection
    Entities:
    ;      Type , Name
    Data.s "100", "CircularArc"
    Data.s "102", "CompositeCurve"
    Data.s "104", "ConicArc"
    Data.s "106", "CopiousData"
    Data.s "108", "Plane"
    Data.s "110", "Line"
    Data.s "112", "ParametricSplineCurve"
    Data.s "114", "ParametricSplineSurface"
    Data.s "116", "Point"
    Data.s "118", "RuledSurface"
    Data.s "120", "SurfaceOfRevolution"
    Data.s "122", "TabulatedCylinder"
    Data.s "123", "Direction"
    Data.s "124", "TransformationMatrix"
    Data.s "126", "RationalBSplineCurve"
    Data.s "128", "RationalBSplineSurface"
    Data.s "130", "OffsetCurve"
    Data.s "140", "OffsetSurface"
    Data.s "141", "Boundary"
    Data.s "142", "CurveOnParametricSurface"
    Data.s "143", "BoundedSurface"
    Data.s "144", "TrimmedSurface"
    Data.s "150", "Block"
    Data.s "152", "RightAngularWedge"
    Data.s "154", "RightCircularCylinder"
    Data.s "156", "RightCircularCone"
    Data.s "158", "Sphere"
    Data.s "160", "Torus"
    Data.s "162", "SolidOfRevolution"
    Data.s "164", "SolidOfLinearExtrusion"
    Data.s "168", "Ellipsoid"
    Data.s "180", "BooleanTree"
    Data.s "186", "ManifoldSolid_BRepObject"
    Data.s "190", "PlaneSurface"
    Data.s "192", "RightCircularCylindricalSurface"
    Data.s "194", "RightCircularConicalSurface"
    Data.s "196", "SphericalSurface"
    Data.s "198", "ToroidalSurface"
    Data.s "308", "SubfigureDefinition"
    Data.s "502", "VertexList"
    Data.s "504", "EdgeList"
    Data.s "508", "Loop"
    Data.s "510", "Face"
    Data.s "514", "Shell"   
    ; annotation entities
    Data.s "202", "AngularDimension"
    Data.s "204", "CurveDimension"
    Data.s "206", "DiameterDimension"
    Data.s "208", "FlagNote"
    Data.s "210", "GeneralLabel"
    Data.s "212", "GeneralNote"
    Data.s "213", "NewGeneralNote"
    Data.s "214", "LeaderArrow"
    Data.s "216", "LinearDimension"
    Data.s "218", "OrdinateDimension"
    Data.s "220", "PointDimension"
    Data.s "222", "RadiusDimension"
    Data.s "228", "GeneralSymbol"
    Data.s "230", "SectionedArea"    
    ; Structure entities are defined in the Specification      
    Data.s "132", "ConnectPoint"
    Data.s "134", "Node"
    Data.s "136", "FiniteElement"
    Data.s "138", "NodalDisplacementAndRotation"
    Data.s "146", "NodalResults"
    Data.s "148", "ElementResults"
    Data.s "302", "AssociativityDefinition"
    Data.s "304", "LineFontDefinition"
    Data.s "306", "MacroDefinition"
    Data.s "308", "SubfigureDefinition"
    Data.s "310", "TextFontDefinition"
    Data.s "312", "TextDisplayTemplate"
    Data.s "314", "ColorDefinition"
    Data.s "316", "UnitsData"
    Data.s "320", "NetworkSubfigureDefinition"
    Data.s "322", "AttributeTableDefinition"
    Data.s "402", "AssociativityInstance"
    Data.s "404", "Drawing"
    Data.s "406", "Property"
    Data.s "408", "SingularSubfigureInstance"
    Data.s "410", "View"
    Data.s "412", "RectangularArraySubfigureInstance"
    Data.s "414", "CircularArraySubfigureInstance"
    Data.s "416", "ExternalReference"
    Data.s "418", "NodalLoad"
    Data.s "420", "NetworkSubfigureInstance"
    Data.s "422", "AttributeTableInstance"
     
  EndDataSection   

EndModule
  

; IDE Options = PureBasic 6.01 LTS (Windows - x64)
; CursorPosition = 31
; FirstLine = 125
; Folding = --
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)