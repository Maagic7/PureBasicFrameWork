; ==============================================================================
; :- OPENCASCADE 64-BIT OBJECT POINTERS (HANDLES) REFERENCE
; ==============================================================================
; Translated from FreeBASIC 'Type As Long Ptr' to PureBasic 64-Bit Pointers.
; In PureBasic x64, all pointers (*) are natively handled as 64-bit integers.
; ==============================================================================

; https://github.com/jepalza/FB_OPENCASCADE/tree/main


DeclareModule OCC   ; OpenCacCade
  ; --- Geometry & Mathematical Objects ---
  ; Usage in Code: Define *myPoint.gpPnt
  Structure gpPnt               : EndStructure ; Point in 3D Space
  Structure gpVec               : EndStructure ; Direction Vector in 3D Space
  Structure gpDir               : EndStructure ; Normalized Direction Vector
  Structure gpAx1               : EndStructure ; Axis (Point and Direction)
  Structure gpAx2               : EndStructure ; Coordinate System (Right-handed)
  Structure gpAx3               : EndStructure ; Coordinate System with axis directions
  Structure gpPln               : EndStructure ; Infinite Plane
  Structure gpCirc              : EndStructure ; Circle in 3D Space
  Structure gpQuaternion        : EndStructure ; Rotation Quaternion
  Structure gpTrsf              : EndStructure ; Geometric Transformation Matrix
  
  ; --- Geometry Curves & Surfaces (gc) ---
  Structure gcCircle            : EndStructure
  Structure gcSurface           : EndStructure
  Structure gcTrimmedCurve      : EndStructure
  
  ; --- BRep Adapters ---
  Structure BRepAdapterCurve    : EndStructure
  Structure BRepAdapterSurface  : EndStructure
  Structure GeomAdapterCurve    : EndStructure
  Structure GeomAdapterSurface  : EndStructure
  
  ; --- BRep Primitives & Builders (CAD Elements) ---
  Structure BRepBuilder         : EndStructure
  Structure BRepPrimAPIMakeBox  : EndStructure    ; Box Generator
  Structure BRepPrimAPIMakeCylinder : EndStructure ; Cylinder Generator
  Structure BRepPrimAPIMakePrism : EndStructure   ; Extrusion Prism Generator
  Structure BRepPrimAPIMakeRevol : EndStructure   ; Revolution Body Generator
  Structure BRepPrimAPIMakeSphere : EndStructure  ; Sphere Generator
  
  ; --- Topology Objects (TopoDS Shapes) ---
  ; Crucial: These hold the actual geometric structures in memory
  Structure TopoDSShape         : EndStructure ; Base class for all shapes
  Structure TopoDSCompound      : EndStructure ; Compound Group of Shapes
  Structure TopoDSFace          : EndStructure ; 3D Surface / Face
  Structure TopoDSWire          : EndStructure ; Wire (connected edges)
  Structure TopoDSEdge          : EndStructure ; 3D Line / Edge
  Structure TopoDSVertex        : EndStructure ; 3D Corner Vertex
  Structure TopLocLocation      : EndStructure ; Placement Location
  
  ; --- BRep Modifiers (Fillet / Chamfer / Boolean) ---
  Structure BRepAlgoAPIBooleanOperation : EndStructure
  Structure BRepAlgoAPICut      : EndStructure    ; Boolean Subtraction (Cut)
  Structure BRepAlgoAPIFuse     : EndStructure    ; Boolean Addition (Fuse)
  Structure BRepBuilderAPIMakeEdge : EndStructure
  Structure BRepBuilderAPIMakeWire : EndStructure
  Structure BRepBuilderAPIMakeFace : EndStructure
  Structure BRepBuilderAPIMakeShape : EndStructure
  Structure BRepBuilderAPITransform : EndStructure ; Applies translation/rotation
  Structure BRepFilletAPIMakeChamfer : EndStructure ; Phasen / Chamfer API
  Structure BRepFilletAPIMakeFillet : EndStructure ; Kantenrundung / Fillet API
  Structure BRepMeshIncrementalMesh : EndStructure ; Triangulation for rendering
  
  ; --- Analyzers & Iterators ---
  Structure GPropGProps         : EndStructure
  Structure GeomLPropSLProps    : EndStructure
  Structure GeomCurve           : EndStructure
  Structure ShapeIterator       : EndStructure
  Structure TopExpExplorer      : EndStructure ; Loops through faces/edges/vertices
  Structure TopToolsListOfShape : EndStructure ; Linked list of shapes
  
  ; --- Data Exchange (IO / File Exporters) ---
  Structure STEPControlWriter   : EndStructure ; STEP File Exporter
  Structure IGESControlWriter   : EndStructure ; IGES File Exporter
  Structure StlAPIWriter        : EndStructure ; STL Mesh Exporter
  
  ; --- Visualizer / Interaction Objects (Added by Joseba Epalza) ---
  Structure AISShape            : EndStructure ; Visual Representation in Viewport
  Structure AISViewController   : EndStructure ; Input Handler (Window & Mouse)
  
  
  ; Prototypes
  
  ;----------------------------------------
  ; OCC Viewer (jepalza)
  ; Return a status code (#False/#True)
  PrototypeC.i OCCViewer_Init(hwnd0.i, *context, *views)
  ; Return an Object Pointer (AISShape-Pointer)
  PrototypeC.i OCCViewer_Add(figura.i, modo.l)
  ; Return a status code
  PrototypeC.i OCCViewer_Update(modo.l = 0)
  ; Return an Object Pointer (AISShape-Pointer) or NULL if nothing selected
  PrototypeC.i OCCViewer_Mouse(mx.l = 0, my.l = 0, v1.l = 0, v2.l = 0, mb.l = 0)
  ; Return a status code
  PrototypeC.i OCCViewer_Mouse3D(mx.l, my.l, *xp.Double, *yp.Double, *zp.Double)
  ; Return an Object Pointer (AISShape-Pointer)
  PrototypeC.i OCCViewer_Transform(*MyAISShape, *orig, *dest)
  ; Void procedure (No return value)
  PrototypeC.i OCCViewer_Demo(MyDemo.l = 0)
  	
  ;----------------------------------------
  ; Viewer Events (raton y vistas) (jepalza)
  ; Return an Object Pointer (AISViewController-Pointer)
  PrototypeC.i FLUSHView_Init()
  ; Return a status code
  PrototypeC.l FLUSHView_Free(*viewevents)
  ; Return a status code
  PrototypeC.l FLUSHView_Update(*viewevents, *context, *views)
  
  ; ---------------------------------------
  ; Fichero: brep_builder.h
  ; Return an Object Pointer (BRepBuilder-Pointer)
  PrototypeC.i BRepBuilder_Init()
  ; Void procedure (No return value)
  PrototypeC BRepBuilder_MakeCompound(*builder, *res)
  ; Void procedure (No return value)
  PrototypeC BRepBuilder_Add(*builder, *res, *shape)
  ; Void procedure (No return value)
  PrototypeC BRepBuilder_Free(*builder)
  ; Void procedure (No return value)
  PrototypeC BRepBuilderAPI_SetPrecision(precision.d)
  ; Return an Object Pointer (BRepBuilderAPIMakeEdge-Pointer)
  PrototypeC.i BRepBuilderAPIMakeEdge_InitWithGeomCurve(*curve)
  ; Return an Object Pointer (TopoDSEdge-Pointer)
  PrototypeC.i BRepBuilderAPIMakeEdge_ToTopoDSEdge(*edge)
  ; Void procedure (No return value)
  PrototypeC BRepBuilderAPIMakeEdge_Free(*edge)
  
  ; Return an Object Pointer (BRepBuilderAPIMakeWire-Pointer)
  PrototypeC.i BRepBuilderAPIMakeWire_Init()
  ; Return an Object Pointer (BRepBuilderAPIMakeWire-Pointer)
  PrototypeC.i BRepBuilderAPIMakeWire_InitWithTopoDSEdge(*edge)
  ; Void procedure (No return value)
  PrototypeC BRepBuilderAPIMakeWire_AddEdge(*wire, *edge)
  ; Void procedure (No return value)
  PrototypeC BRepBuilderAPIMakeWire_AddWire(*makeWire, *wire)
  ; Return an Object Pointer (TopoDSWire-Pointer)
  PrototypeC.i BRepBuilderAPIMakeWire_ToTopoDSWire(*wire)
  ; Void procedure (No return value)
  PrototypeC BRepBuilderAPIMakeWire_Free(*wire)
  
  ; Return an Object Pointer (BRepBuilderAPIMakeFace-Pointer)
  PrototypeC.i BRepBuilderAPIMakeFace_InitWithWire(*wire)
  ; Return an Object Pointer (TopoDSFace-Pointer)
  PrototypeC.i BRepBuilderAPIMakeFace_ToTopoDSFace(*face)
  ; Void procedure (No return value)
  PrototypeC BRepBuilderAPIMakeFace_Free(*face)
  ; Return an Object Pointer (TopoDSShape-Pointer)
  PrototypeC.i BRepBuilderAPIMakeShape_Shape(*makeShape)
  ; Return an Object Pointer (BRepBuilderAPITransform-Pointer)
  PrototypeC.i BRepBuilderAPITransform_InitWithShapeTrsf(*shape, *trsf)
  ; Return an Object Pointer (TopoDSShape-Pointer)
  PrototypeC.i BRepBuilderAPITransform_Shape(*breptrsf)
  ; Void procedure (No return value)
  PrototypeC BRepBuilderAPITransform_Free(*breptrsf)
  
  ; ---------------------------------------
  ; Fichero: toptools_listofshape.h
  ; Return an Object Pointer
  PrototypeC.i TopToolsListOfShape_Init()
  ; Void procedure
  PrototypeC TopToolsListOfShape_Free(*list)
  ; Return an Object Pointer
  PrototypeC.i TopToolsListOfShape_Append(*list, *shape)
  ; Void procedure
  PrototypeC TopToolsListOfShape_AppendList(*list, *other)
  ; Return an Object Pointer
  PrototypeC.i TopToolsListOfShape_Extent(*list)
  ; Return an Object Pointer
  PrototypeC.i TopToolsListOfShape_Begin(*list)
  
  ; Return an Object Pointer
  PrototypeC.i ShapeIterator_Next(*iter)
  ; Return an Object Pointer
  PrototypeC.i ShapeIterator_Shape(*iter)
  
  ; ---------------------------------------
  ; Fichero: brepalgoapi.h
  ; Return an Object Pointer
  PrototypeC.i BRepAlgoAPIFuse_Init()
  ; Void procedure
  PrototypeC BRepAlgoAPIFuse_Free(*algo)
  ; Return an Object Pointer
  PrototypeC.i BRepAlgoAPIFuse_ToBooleanOperation(*algo)
  	
  ; Return an Object Pointer
  PrototypeC.i BRepAlgoAPICut_Init()
  ; Void procedure
  PrototypeC BRepAlgoAPICut_Free(*algo)
  ; Return an Object Pointer
  PrototypeC.i BRepAlgoAPICut_ToBooleanOperation(*algo)
  
  ; Return an Object Pointer
  PrototypeC.i BRepAlgoAPIBooleanOperation_Shape(*op)
  ; Void procedure
  PrototypeC BRepAlgoAPIBooleanOperation_SetTools(*op, *list)
  ; Void procedure
  PrototypeC BRepAlgoAPIBooleanOperation_SetArguments(*op, *list)
  ; Void procedure
  PrototypeC BRepAlgoAPIBooleanOperation_Build(*op)
  ; Void procedure
  PrototypeC BRepAlgoAPIBooleanOperation_Free(*op)
  
  ; ---------------------------------------
  ; Fichero: brepfilletapi.h
  ; Return an Object Pointer
  PrototypeC.i BRepFilletAPIMakeFillet_Init(*shape)
  ; Void procedure
  PrototypeC BRepFilletAPIMakeFillet_Add(*fillet, *edge, radius.d)
  ; Return an Object Pointer
  PrototypeC.i BRepFilletAPIMakeFillet_Shape(*fillet)
  ; Void procedure
  PrototypeC BRepFilletAPIMakeFillet_Free(*fillet)
    
  ; Return an Object Pointer
  PrototypeC.i BRepFilletAPIMakeChamfer_Init(*shape)
  ; Void procedure
  PrototypeC BRepFilletAPIMakeChamfer_Add(*f, *e, radius.d)
  ; Return an Object Pointer
  PrototypeC.i BRepFilletAPIMakeChamfer_Shape(*f)
  ; Void procedure
  PrototypeC BRepFilletAPIMakeChamfer_Free(*f)
  
  ; ---------------------------------------
  ; Fichero: brepgprop.h
  ; Void procedure
  PrototypeC BRepGProp_SurfaceProperties(*shape, *sprops, skipShared.b, useTriangulation.b)
  ; Void procedure
  PrototypeC BRepGProp_LinearProperties(*shape, *sprops, skipShared.b, useTriangulation.b)
  
  ; ---------------------------------------
  ; Fichero: brepmesh.h
  ; Return an Object Pointer
  PrototypeC.i BRepMeshIncrementalMesh_Init(*shape, linearDefl.d, isRelative.b, angularDefl.d, isParallel.b)
  ; Void procedure
  PrototypeC BRepMeshIncrementalMesh_Free(*mesh)
  
  ; ---------------------------------------
  ; Fichero: brepprimapi.h
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakeRevol_Init(*face, *axis, degrees.d)
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakeRevol_Shape(*makeRevol)
  ; Void procedure
  PrototypeC BRepPrimAPIMakeRevol_Free(*makeRevol)
  
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakePrism_Init(*face, *vec)
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakePrism_Shape(*makePrism)
  ; Void procedure
  PrototypeC BRepPrimAPIMakePrism_Free(*makePrism)
  
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakeCylinder_Init(*position, radius.d, height.d)
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakeCylinder_Shape(*makeCylinder)
  ; Void procedure
  PrototypeC BRepPrimAPIMakeCylinder_Free(*makeCylinder)
  
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakeSphere_Init(*position, radius.d)
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakeSphere_Shape(*makeSphere)
  ; Void procedure
  PrototypeC BRepPrimAPIMakeSphere_Free(*makeSphere)
  
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakeBox_Init(*position, dx.d, dy.d, dz.d)
  ; Return an Object Pointer
  PrototypeC.i BRepPrimAPIMakeBox_Shape(*makeBox)
  ; Void procedure
  PrototypeC BRepPrimAPIMakeBox_Free(*makeBox)
  
  ; ---------------------------------------
  ; Fichero: breptools.h
  ; Void procedure
  PrototypeC BRepTools_UVBounds(*face, umin.d, umax.d, vmin.d, vmax.d)
  
  ; ---------------------------------------
  ; Fichero: brep_adapter.h
  ; Return an Object Pointer
  PrototypeC.i BRepAdapterCurve_Init(*edge)
  ; Return a status code (#False/#True)
  PrototypeC.i BRepAdapterCurve_IsLine(*curve)
  ; Return a status code (#False/#True)
  PrototypeC.i BRepAdapterCurve_IsCircle(*curve)
  ; Return a status code (#False/#True)
  PrototypeC.i BRepAdapterCurve_IsEllipse(*curve)
  ; Return an Object Pointer
  PrototypeC.i BRepAdapterCurve_ToCircle(*curve)
  
  ; Return an Object Pointer
  PrototypeC.i BRepAdapterSurface_Init(*face)
  ; Return an Object Pointer
  PrototypeC.i BRepAdapterSurface_InitRestriction(*face, restriction.b)
  ; Return an Object Pointer
  PrototypeC.i BRepAdapterSurface_Plane(*surface)
  ; Return an Object Pointer
  PrototypeC.i BRepAdapterSurface_Direction(*surface)
  ; Return an Object Pointer
  PrototypeC.i BRepAdapterSurface_Type(*surface)
  ; Void procedure
  PrototypeC BRepAdapterSurface_Free(*surface)
  
  ; ---------------------------------------
  ; Fichero: brep_tool.h
  ; Return an Object Pointer
  PrototypeC.i BRepTool_Surface(*face)
  ; Void procedure
  PrototypeC GCSurface_Free(*surface)
  ; Return an Object Pointer
  PrototypeC.i BRepTool_Pnt(*vertex)
  
  ; ---------------------------------------
  ; Fichero: gcpnts.h
  ; Return a Double value
  PrototypeC.d CurveLength(*c)
  
  ; ---------------------------------------
  ; Fichero: geomlprop_slprops.h
  ; Return an Object Pointer
  PrototypeC.i GeomLPropSLProps_Init(*surface, umin.d, vmin.d, n.d, res.d)
  ; Return an Object Pointer
  PrototypeC.i GeomLPropsSLProps_Normal(*props)
  ; Void procedure
  PrototypeC GeomLPropSLProps_Free(*props)
  
  ; ---------------------------------------
  ; Fichero: geom_adapter.h
  ; Return an Object Pointer
  PrototypeC.i GeomAdapterSurface_Init(*surface)
  ; Void procedure
  PrototypeC GeomAdapterSurface_Free(*surface)
  ; Return a status code (#False/#True)
  PrototypeC.i GeomAdapterSurface_IsConical(*surface)
  ; Return a status code (#False/#True)
  PrototypeC.i GeomAdapterSurface_IsCylindrical(*surface)
  ; Return a status code (#False/#True)
  PrototypeC.i GeomAdapterSurface_IsPlanar(*surface)
  
  ; ---------------------------------------
  ; Fichero: geom_curve.h
  ; Return an Object Pointer
  PrototypeC.i gcMakeCircle(*center, radius.d)
  ; Return an Object Pointer
  PrototypeC.i gcMakeArcOfCircle(*circles, *pt1, *pt2, sense.b)
  ; Return an Object Pointer
  PrototypeC.i gcMakeArcOfCirclePts(*pt1, *pt2, *pt3)
  ; Return an Object Pointer
  PrototypeC.i gcMakeSegment(*start, *end)
  ; Void procedure
  PrototypeC gcTrimmedCurve_Free(*arc)
  ; Return an Object Pointer
  PrototypeC.i gcTrimmedCurve_ToGeomCurve(*curve)
  
  ; ---------------------------------------
  ; Fichero: gprop.h
  ; Return an Object Pointer
  PrototypeC.i GPropGProps_Init()
  ; Void procedure
  PrototypeC GPropGProps_Free(*props)
  ; Return a Double value
  PrototypeC.d GPropGProps_Mass(*props)
  ; Return an Object Pointer
  PrototypeC.i GPropGProps_CentreOfMass(*props)
  
  ; ---------------------------------------
  ; Fichero: gp_ax1.h
  ; Return an Object Pointer
  PrototypeC.i gpAx1_Init(*origin, *dirs)
  ; Return an Object Pointer
  PrototypeC.i gpAx1_Direction(*axis)
  ; Void procedure
  PrototypeC gpAx1_Free(*axis)
  
  ; ---------------------------------------
  ; Fichero: gp_ax2.h
  ; Return an Object Pointer
  PrototypeC.i gpAx2_Init(*origin, *normal, *xAxis)
  ; Void procedure
  PrototypeC gpAx2_Free(*axis)
  
  ; ---------------------------------------
  ; Fichero: gp_ax3.h
  ; Return an Object Pointer
  PrototypeC.i gpAx3_Init(*origin, *normal, *xDir)
  ; Return an Object Pointer
  PrototypeC.i gpAx3_XDirection(*coord)
  ; Return an Object Pointer
  PrototypeC.i gpAx3_YDirection(*coord)
  ; Return an Object Pointer
  PrototypeC.i gpAx3_Direction(*coord)
  ; Return an Object Pointer
  PrototypeC.i gpAx3_Location(*coord)
  ; Void procedure
  PrototypeC gpAx3_Rotate(*coord, *axis, angle.d)
  ; Return an Object Pointer
  PrototypeC.i gpAx3_Translated(*coord, *vec)
  ; Void procedure
  PrototypeC gpAx3_Free(*coord)
  
  ; ---------------------------------------
  ; Fichero: gp_circ.h
  ; Return an Object Pointer
  PrototypeC.i gpCirc_Init(*center, radius.d)
  ; Return a Double value
  PrototypeC.d gpCirc_Radius(*circles)
  ; Return an Object Pointer
  PrototypeC.i gpCirc_Location(*circles)
  ; Void procedure
  PrototypeC gpCirc_Free(*circles)
  
  ; ---------------------------------------
  ; Fichero: gp_dir.h
  ; Return an Object Pointer
  PrototypeC.i gpDir_Init(x.d, y.d, z.d)
  ; Return an Object Pointer
  PrototypeC.i gpDir_InitVec(*vector)
  ; Void procedure
  PrototypeC gpDir_Free(*dirs)
  ; Return a Double value
  PrototypeC.d gpDir_X(*dirs)
  ; Return a Double value
  PrototypeC.d gpDir_Y(*dirs)
  ; Return a Double value
  PrototypeC.d gpDir_Z(*dirs)
  ; Return a Double value
  PrototypeC.d gpDir_Dot(*dirs, *other)
  ; Return a status code (#False/#True)
  PrototypeC.i gpDir_IsEqual(*dirs, *other)
  ; Return a status code (#False/#True)
  PrototypeC.i gpDir_IsParallel(*dirs, *other)
  
  ; ---------------------------------------
  ; Fichero: gp_pln.h
  ; Return an Object Pointer
  PrototypeC.i gpPln_Init()
  ; Return an Object Pointer
  PrototypeC.i gpPln_InitAx3(*coord)
  ; Return an Object Pointer
  PrototypeC.i gpPln_InitPntDir(*origin, *dirs)
  ; Return an Object Pointer
  PrototypeC.i gpPln_Axis(*plane)
  ; Return an Object Pointer
  PrototypeC.i gpPln_Position(*plane)
  ; Return a status code (#False/#True)
  PrototypeC.i gpPln_ContainsPoint(*plane, *points)
  ; Void procedure
  PrototypeC gpPln_Free(*plane)
  
  ; ---------------------------------------
  ; Fichero: gp_pnt.h
  ; Return an Object Pointer
  PrototypeC.i gpPnt_Init(x.d, y.d, z.d)
  ; Void procedure
  PrototypeC gpPnt_Free(*pnt)
  ; Void procedure
  PrototypeC gpPnt_SetCoord(*pnt, x.d, y.d, z.d)
  ; Void procedure
  PrototypeC gpPnt_SetX(*pnt, x.d)
  ; Void procedure
  PrototypeC gpPnt_SetY(*pnt, y.d)
  ; Void procedure
  PrototypeC gpPnt_SetZ(*pnt, z.d)
  ; Return a Double value
  PrototypeC.d gpPnt_X(*pnt)
  ; Return a Double value
  PrototypeC.d gpPnt_Y(*pnt)
  ; Return a Double value
  PrototypeC.d gpPnt_Z(*pnt)
  ; Return a status code (#False/#True)
  PrototypeC.i gpPnt_IsEqual(*pnt, *other, tolerance.d)
  ; Return a Double value
  PrototypeC.d gpPnt_Distance(*pnt, *other)
  ; Return a Double value
  PrototypeC.d gpPnt_SquareDistance(*pnt, *other)
  ; Void procedure
  PrototypeC gpPnt_MirrorCenterPoint(*pnt, *center)
  ; Return an Object Pointer
  PrototypeC.i gpPnt_MirroredCenterPoint(*pnt, *center)
  ; Void procedure
  PrototypeC gpPnt_MirrorAxis(*pnt, *axis)
  ; Return an Object Pointer
  PrototypeC.i gpPnt_MirroredAxis(*pnt, *axis)
  ; Void procedure
  PrototypeC gpPnt_Rotate(*pnt, *axis, angle.d)
  ; Return an Object Pointer
  PrototypeC.i gpPnt_Rotated(*pnt, *axis, angle.d)
  ; Void procedure
  PrototypeC gpPnt_Scale(*pnt, *other, scale.d)
  ; Return an Object Pointer
  PrototypeC.i gpPnt_Scaled(*pnt, *other, scale.d)
  ; Void procedure
  PrototypeC gpPnt_Transform(*pnt, *transform)
  ; Return an Object Pointer
  PrototypeC.i gpPnt_Transformed(*pnt, *transform)
  ; Void procedure
  PrototypeC gpPnt_Translate(*pnt, *vector)
  ; Return an Object Pointer
  PrototypeC.i gpPnt_Translated(*pnt, *vector)
  ; Void procedure
  PrototypeC gpPnt_TranslatePoints(*pnt, *pnt1, *pnt2)
  ; Return an Object Pointer
  PrototypeC.i gpPnt_TranslatedPoints(*pnt, *pnt1, *pnt2)
  
  ; ---------------------------------------
  ; Fichero: gp_trsf.h
  ; Return an Object Pointer
  PrototypeC.i gpTrsf_Init()
  ; Void procedure
  PrototypeC gpTrsf_SetMirror(*trsf, *axis)
  ; Void procedure
  PrototypeC gpTrsf_SetMirrorAx1(*transform, *axis)
  ; Void procedure
  PrototypeC gpTrsf_SetMirrorAx2(*transform, *axis)
  ; Void procedure
  PrototypeC gpTrsf_SetTransformation(*transform, *from, *to_)
  ; Void procedure
  PrototypeC gpTrsf_SetRotation(*transform, *axis, rads.d)
  	
  ; Void procedure
  PrototypeC gpTrsf_SetTranslation(*transform, *vec)
  ; Return an Object Pointer
  PrototypeC.i gpTrsf_GetRotation(*transform)
  ; Void procedure
  PrototypeC gpTrsf_Free(*transform)
  
  ; ---------------------------------------
  ; Fichero: gp_vec.h
  ; Return an Object Pointer
  PrototypeC.i gpVec_Init(x.d, y.d, z.d)
  ; Return an Object Pointer
  PrototypeC.i gpVec_InitDir(*dirs.gpDir)
  ; Return an Object Pointer
  PrototypeC.i gpVec_InitPoints(*ini, *fin)
  ; Void procedure
  PrototypeC gpVec_Free(*vector)
  ; Return a Double value
  PrototypeC.d gpVec_X(*vec)
  ; Return a Double value
  PrototypeC.d gpVec_Y(*vec)
  ; Return a Double value
  PrototypeC.d gpVec_Z(*vec)
  ; Return a status code (#False/#True)
  PrototypeC.i gpVec_IsEqual(*vec, *other)
  ; Return a Double value
  PrototypeC.d gpVec_Dot(*v, *other)
  ; Return an Object Pointer
  PrototypeC.i gpVec_Multiplied(*v, dist.d)
  ; Return an Object Pointer
  PrototypeC.i gpVec_Crossed(*v, *other)
  ; Return an Object Pointer
  PrototypeC.i gpVec_Normalized(*v)
  ; Return a Double value
  PrototypeC.d gpVec_Magnitude(*v)
  
  ; Return a Double value
  PrototypeC.d gpResolution()
  
  ; ---------------------------------------
  ; Fichero: gp_quaternion.h
  ; Return an Object Pointer
  PrototypeC.i gpQuaternion_Inverted(*q.gpQuaternion)
  ; Return an Object Pointer
  PrototypeC.i gpQuaternion_Multiplied(*q.gpQuaternion, *other.gpQuaternion)
  ; Return a status code (#False/#True)
  PrototypeC.i gpQuaternion_IsEqual(*q.gpQuaternion, *other.gpQuaternion)
  ; Return a Double value
  PrototypeC.d gpQuaternion_GetRotationAngle(*q.gpQuaternion)
  ; Void procedure
  PrototypeC gpQuaternion_Free(*q)
  
  ; ---------------------------------------
  ; Fichero: occutils.h
  ; Return an Object Pointer
  PrototypeC.i gpPnt_Midpoint(*p1, *p2)
  
  ; ---------------------------------------
  ; Fichero: stepcontrol_writer.h
  ; Return an Object Pointer
  PrototypeC.i STEPControlWriter_Init()
  ; Return an Object Pointer
  PrototypeC.i STEPControlWriter_Add(*writer, *shape, *types)
  ; Return an Object Pointer
  PrototypeC.i STEPControlWriter_Write(*writer, *filename)
  ; Void procedure
  PrototypeC STEPControlWriter_Free(*writer)
  
  ; Fichero: IGESapi_writer.h
  ; Return an Object Pointer
  PrototypeC.i IGESControlWriter_Init()
  ; Void procedure
  PrototypeC IGESControlWriter_Add(*writer, *shape, *types)
  ; Return an Object Pointer
  PrototypeC.i IGESControlWriter_Write(*writer, *filename)
  ; Void procedure
  PrototypeC IGESControlWriter_Free(*writer)
  
  ; ---------------------------------------
  ; Fichero: stlapi_writer.h
  ; Return an Object Pointer
  PrototypeC.i StlAPIWriter_Init()
  ; Return a status code (#False/#True)
  PrototypeC.i StlAPIWriter_Write(*writer, *res, *filename)
  ; Void procedure
  PrototypeC StlAPIWriter_Free(*writer)
  
  ; ---------------------------------------
  ; Fichero: topexp_explorer.h
  ; Return an Object Pointer
  PrototypeC.i TopExpExplorer_Init(*shape, *toFind)
  ; Void procedure
  PrototypeC TopExpExplorer_Free(*exp)
  ; Return a status code (#False/#True)
  PrototypeC.i TopExpExplorer_More(*exp)
  ; Void procedure
  PrototypeC TopExpExplorer_Next(*exp)
  ; Return an Object Pointer
  PrototypeC.i TopExpExplorer_Current(*exp)
  ; Return an Object Pointer
  PrototypeC.i TopExpExplorer_Depth(*exp)
  
  ; Return an Object Pointer
  PrototypeC.i TopExp_FirstVertex(*edge)
  ; Return an Object Pointer
  PrototypeC.i TopExp_LastVertex(*edge)
  
  ; ---------------------------------------
  ; Fichero: toploc_location.h
  ; Void procedure
  PrototypeC TopLocLocation_Free(*loc)
  ; Return an Object Pointer
  PrototypeC.i TopLocLocation_Transformation(*loc)
  
  ; ---------------------------------------
  ; Fichero: topods_compound.h
  ; Return an Object Pointer
  PrototypeC.i TopoDSCompound_Init()
  ; Void procedure
  PrototypeC TopoDSCompound_Free(*comp)
  
  ; ---------------------------------------
  ; Fichero: topods_shape.h
  ; Return a status code (#False/#True)
  PrototypeC.i TopoDSShape_IsEqual(*shape, *other)
  ; Void procedure
  PrototypeC TopoDSShape_Free(*shape)
  ; Return an Object Pointer
  PrototypeC.i TopoDSShape_Location(*shape)
  ; Return an Object Pointer
  PrototypeC.i TopoDSShape_Orientation(*shape)
  ; Return an Object Pointer
  PrototypeC.i TopoDSShape_Wire(*shape)

EndDeclareModule

Module OCC
  
  EnableExplicit
  
  Procedure LOAD_OCC()
    Protected DLL = OpenLibrary(#PB_Any, "occwrapper.dll")
    If DLL
      ; Hier verknüpfen wir die globalen Variablen mit den DLL-Funktionen
      ;occ_makebox    = GetFunction(DLL, "occ_makebox")
      ;occ_makefillet = GetFunction(DLL, "occ_makefillet")
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 99
; FirstLine = 17
; Folding = -
; DPIAware
; CPU = 5