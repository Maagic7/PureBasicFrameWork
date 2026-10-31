; ===========================================================================
;  FILE: PbFw_Module_CSGf.pb
;  NAME: Module Constructive Solid Geometry with Single-Float Vector coordinates
;  DESC: DataStructures for Solid 3D Models
;  DESC: - Boundary Representation (B-Rep) : Representation by Polygon-Surfaces
;  DESC: - Wire-Frame-Model     : Representation by Edges
;  DESC: - Face Representation  : Representation by Triangle-Surfaces
;  DESC: - Octree Representation: Representation by 3D Pixels (Voxels)
;  SOURCES:
;
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/10/27
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.12
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog:
;
;}
;{ TODO: a lot!
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "..\PbFw_Module_PbFw.pb" ; PbFw::    FrameWork control Module
XIncludeFile "..\PbFw_Module_Debug.pb" ; DBG::     Debug Module
XIncludeFile "..\Grafics\PbFw_Module_VECTORf.pb" ; VECf::    single precision Vector Module

DeclareModule CSGf

  EnableExplicit

  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------

  Enumeration EhStruct ; Enumeration of Structure handels
    #CSG_hStruct_unknown
    #CSG_hStruct_CsgBase = $10 ; ID of the Base Structure (allows 15 Substructures $11..$1F)
    #CSG_hStruct_CsgObjBRep ; ID of the Sub Structure Boundary Representation
    #CSG_hStruct_CsgObjWFM ; ID of the Sub Structure WireFrameModel
    #CSG_hStruct_CsgObjFacet ; ID of the Sub Structure Facet Representation
    #CSG_hStruct_CsgObjOctree ; ID of the Sub Structure Octree Representation
  EndEnumeration

  ; UseModule VECd ; Using the VectorModule with double (64Bit) coordinates
  UseModule VECf ; Using the VectorModule with single (32Bit) coordinates

  ; After a long resarch for effective 3D Data Structures.
  ; I found out the following things:

  ; 1.  Using 4D Object coordinates (x,y,z,w) as standard looks more effective for me than using
  ;     3D coordinates (x,y,z). Because the resulting Matrix operation for 3D cooridnates
  ;     are 4D. And for the SSE-Operations which can operate 4 values simulatan it does not matter.

  ; 2.  There are some different DataStructrues to store 3D Solid Objects.
  ;     Each has it's advantages and disadvantages.

  ; 3.  For effective 3D operations with solid Objects we need more than one DataStructure.
  ;     I guess it's better to integreate more DataStructures in a Module.
  ;     So we can add important transformation functions between the DataStructures here!

  ; 4.  Handle Pointer to Points in a Point-List seems to be more effective at the end.
  ;     Transformations of the complete object can be done directly with all points in the list
  ;     (move, turn, zoom, ..). Just multiply all points with the combiend transformation matrix.
  ;     One single point can be part of more Edges, Polygons, Facets. A reference Structure
  ;     implements that facts better!
  ;     So for a Facet: We store the Pointers to the 3 Points, not the Points directly.


  ; VERTTEX: in der Geometrie ist ein Vertex eine Ecke eines Polygons.

  Structure TCircle
    *pVx.TVector
    r.f
  EndStructure

  Structure TEdge ; An Edge is a straight line
    *pVx1.TVector ; Pointer to Vertex 1 (Start Point)
    *pVx2.TVector ; Pointer to Vertex 2 (End Point)
  EndStructure

  Structure TTriangle
    *pVx1.TVector ; Pointer to Vertex 1
    *pVx2.TVector ; Pointer to Vertex 2
    *pVx3.TVector ; Pointer to Vertex 3
  EndStructure

  Structure TFacet Extends TTriangle ; Facet of 3 Points and Normal Vector
    N.TVector ; Normal Vector of the Facet
  EndStructure

  Structure TPolygon
    List *lst_pVx.TVector() ; List of Pointers to Vertex
    N.TVector ; Normal Vector of the plane Polygon
  EndStructure

  Structure TSolidShape
    ShapeID.i
  EndStructure

  ; ----------------------------------------------------------------------

  Structure TCsgObjBase ; Base for Constructive-Solid-Geometry-Objects
    *This ; Pointer to itself (for internal validity checks)
    hStruct.i ; Structure ID (Structure handle to find out the Type of the Structure by Pointer)
    ObjID.i ; User defined Object-ID
    Name.s ; User defined Object Name
    List lstPoints.TVector() ; List of definition Pointes (Vertices)
  EndStructure

  ; ----------------------------------------------------------------------
  ; Boundary Representation (B-Rep)
  ; ----------------------------------------------------------------------
  ; All objects are represented by their surfaces (boundaries).
  ; In the surface model more informations are stored than in the edge model.
  ; In addition, you can also store geometric information for each surface,
  ; which makes futher calculations easier, such as the corresponding plane
  ; equation or the normal vector, which gives you direct information about
  ; the space between the surfaces.

  ; Object = List of references to Polygones
  ; List of Polygons = List of Polygones in the Model
  ; Polygon = List of references to Edges
  ; Edge = References to the 2 Points
  ; List of Points = List of all Points in the Model
  ; Point = a Point in the 3D Space

  Structure TObjBRep Extends TCsgObjBase ; Object as BoundaryRepresentation
    List lstPolys.TPolygon() ; List of polygons that define the object's surface
  EndStructure

  ; ----------------------------------------------------------------------
  ; WireFrameModel
  ; ----------------------------------------------------------------------
  ; In the wireframe model, each Object is represented by its edges.
  ; A cube is therefore only represented by its twelve edges
  ; there is no geometric information about the areas between the edges Or between the faces
  ; of the cube

  ; Object = List of Edge references.
  ; List of Edges = List of all Edges in the Model
  ; Edge = References to the 2 Points
  ; List of Points = List of all Points in the Model
  ; Point = a Point in the 3D Space

  Structure TObjWFM Extends TCsgObjBase ; Object as WireFrameModel
    List lstEdges.TEdge() ; List of edges that define the object's wireframe
  EndStructure

  ; ----------------------------------------------------------------------
  ; Facet (Triangle) Representation
  ; ----------------------------------------------------------------------

  Structure TObjFacet Extends TCsgObjBase ; Object as FacetRepresentation
    List lstFacets.TFacet() ; List of triangular facets that define the object's surface
  EndStructure

  ; ----------------------------------------------------------------------
  ; Octree Representation
  ; ----------------------------------------------------------------------
  ; Octree Representation is a Tree-Structure wehere each Object is
  ; represented by a List of 3D Pixels (a 3D Pixel is called a Voxel).
  ; The Object is successively parted into 8 smaler Objects.
  ; https://en.wikipedia.org/wiki/Voxel
  ; https://en.wikipedia.org/wiki/Octree

  ; ----------------------------------------------------------------------
  ; A Voxel is a 3D Pixel. We can say a small cube/sphere or a 3D Point with size/diameter!
  ; We need a diameter and a center point.
  Structure TVoxel
    *pVec.TVector ; Pointer to Vector of Center Point
    D.f ; 3D Pixel diameter
    Col.l ; Color
  EndStructure

  Enumeration TOctreeNodeType
    #CSG_Octree_Branch ; Node is a branch with 8 sub-nodes
    #CSG_Octree_Leaf_Empty ; Node is a leaf and is empty
    #CSG_Octree_Leaf_Solid ; Node is a leaf and is completely solid
    #CSG_Octree_Leaf_Partial ; Node is a leaf and contains a list of voxels
  EndEnumeration

  Structure TOctreeNode
    NodeType.i ; Type of node (Branch, Leaf, etc.)
    Bounds.TCircle ; Bounding sphere for the node's volume
    StructureUnion
      *pSubNodes.TOctreeNode ; Pointer to an array of 8 child nodes (for #CSG_Octree_Branch)
      *pVoxels.TVoxel ; Pointer to a single Voxel or a list of Voxels (for #CSG_Octree_Leaf_Partial)
    EndStructureUnion
  EndStructure

  Structure TObjOctree Extends TCsgObjBase ; Object as Octree Representation
    *pRootNode.TOctreeNode ; The root node of the octree
    List lstVoxels.TVoxel() ; Master list of all voxels for this object
  EndStructure

EndDeclareModule


Module CSGf

  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module) ; Lists the Module in the ModuleList (for statistics)

  Define V.TVoxel

EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 33
; Folding = -
; Optimizer
; CPU = 5