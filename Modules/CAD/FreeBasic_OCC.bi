' Freebasic C-Wrapper OpenCascade V0.3
'
' Joseba Epalza <jepalza> gmail punto com , Enero-Febrero 2026
'
' no hay limite de uso de este codigo, es libre dde uso 100% (solo pido una mencion si lo empleas)
'
' C-WRAPPER para OpenCascade < https://dev.opencascade.org/ > version 7.7 x32 (noviembre 2022)
' empleando las rutinas de < https://github.com/marcuswu/occwrapper > con ligeras modificaciones
' licencias de sus respectivos autores, segun se indica en su pagina WEB  

  Type As Long Ptr gcCircle
  Type As Long Ptr gcSurface
  Type As Long Ptr gcTrimmedCurve
  Type As Long Ptr gpAx1
  Type As Long Ptr gpAx2
  Type As Long Ptr gpAx3
  Type As Long Ptr gpCirc
  Type As Long Ptr gpDir
  Type As Long Ptr gpPln
  Type As Long Ptr gpPnt
  Type As Long Ptr gpQuaternion
  Type As Long Ptr gpTrsf
  Type As Long Ptr gpVec
  Type As Long Ptr BRepAdapterCurve
  Type As Long Ptr BRepAdapterSurface
  Type As Long Ptr BRepAlgoAPIBooleanOperation
  Type As Long Ptr BRepAlgoAPICut
  Type As Long Ptr BRepAlgoAPIFuse
  Type As Long Ptr BRepBuilderAPIMakeEdge
  Type As Long Ptr BRepBuilderAPIMakeWire
  Type As Long Ptr BRepBuilderAPIMakeFace
  Type As Long Ptr BRepBuilderAPIMakeShape
  Type As Long Ptr BRepBuilderAPITransform
  Type As Long Ptr BRepBuilder
  Type As Long Ptr BRepFilletAPIMakeChamfer
  Type As Long Ptr BRepFilletAPIMakeFillet
  Type As Long Ptr BRepMeshIncrementalMesh

  Type As Long Ptr BRepPrimAPIMakeBox
  Type As Long Ptr BRepPrimAPIMakeCylinder
  Type As Long Ptr BRepPrimAPIMakePrism
  Type As Long Ptr BRepPrimAPIMakeRevol
  Type As Long Ptr BRepPrimAPIMakeSphere

  Type As Long Ptr GPropGProps
  Type As Long Ptr GeomAdapterCurve
  Type As Long Ptr GeomAdapterSurface
  Type As Long Ptr GeomLPropSLProps
  Type As Long Ptr GeomCurve
  Type As Long Ptr ShapeIterator

  Type As Long Ptr STEPControlWriter
  Type As Long Ptr IGESControlWriter
  Type As Long Ptr StlAPIWriter

  Type As Long Ptr TopoDSCompound
  Type As Long Ptr TopoDSEdge
  Type As Long Ptr TopoDSWire
  Type As Long Ptr TopoDSFace
  Type As Long Ptr TopoDSShape
  Type As Long Ptr TopoDSVertex
  Type As Long Ptr TopExpExplorer
  Type As Long Ptr TopLocLocation
  Type As Long Ptr TopToolsListOfShape

	' Añadidos por 'Joseba Epalza <jepalza>'
    Type As Long Ptr AISShape ' entidades que se envian al visualizador
    Type As Long Ptr AISViewController ' manejador de eventos de ventana y raton
	 Type As Long Ptr BRepPrimAPIMakeSphere 'esferas


'----------------------------------------
' OCC Viewer (jepalza)
  Declare Function OCCViewer_Init Cdecl Alias "OCCViewer_Init"(byval hwnd0 as long,byval context as long ptr,byval views as long ptr) As long 
  Declare Function OCCViewer_Add  Cdecl Alias "OCCViewer_Add"(byval figura as long, modo as long) As AISShape
  Declare Function OCCViewer_Update Cdecl Alias "OCCViewer_Update"(byval modo as long=0) As Long
  Declare Function OCCViewer_Mouse Cdecl Alias "OCCViewer_Mouse"(byval mx as long=0,byval my as long=0,byval v1 as long=0,byval v2 as long=0,byval mb as long=0) As AISShape
  Declare Function OCCViewer_Mouse3D Cdecl Alias "OCCViewer_Mouse3D"(byval mx as long,byval my as long,byval xp as Double Ptr,byval yp as Double Ptr,byval zp as Double Ptr) As Long
  Declare Function OCCViewer_Transform Cdecl Alias "OCCViewer_Transform"(MyAISShape As AISShape,ByVal orig As gpPnt,ByVal dest As gpPnt) As AISShape
  Declare sub OCCViewer_Demo Cdecl Alias "OCCViewer_Demo"(byval MyDemo as long=0)
	
'----------------------------------------
' Viewer Events (raton y vistas) (jepalza)
  Declare Function FLUSHView_Init Cdecl Alias "FLUSHView_Init"() As AISViewController 
  Declare Function FLUSHView_Free  Cdecl Alias "FLUSHView_Free"(byval viewevents as AISViewController) As long
  Declare Function FLUSHView_Update Cdecl Alias "FLUSHView_Update"(byval viewevents as AISViewController,byval context as long ptr,byval views as long ptr) As long


' ---------------------------------------
' Fichero: brep_builder.h
  Declare Function BRepBuilder_Init Cdecl Alias "BRepBuilder_Init"() As BRepBuilder 
  Declare Sub      BRepBuilder_MakeCompound Cdecl Alias "BRepBuilder_MakeCompound"(ByVal builder As BRepBuilder ,ByVal res As TopoDSCompound) 
  Declare Sub      BRepBuilder_Add Cdecl Alias "BRepBuilder_Add"(ByVal builder As BRepBuilder ,ByVal res As TopoDSShape ,ByVal shape As TopoDSShape) 
  Declare Sub      BRepBuilder_Free Cdecl Alias "BRepBuilder_Free"(ByVal builder As BRepBuilder) 
  Declare Sub      BRepBuilderAPI_SetPrecision Cdecl Alias "BRepBuilderAPI_SetPrecision"(ByVal precision As Double) 
  Declare Function BRepBuilderAPIMakeEdge_InitWithGeomCurve Cdecl Alias "BRepBuilderAPIMakeEdge_InitWithGeomCurve"(ByVal curve As GeomCurve) As BRepBuilderAPIMakeEdge 
  Declare Function BRepBuilderAPIMakeEdge_ToTopoDSEdge Cdecl Alias "BRepBuilderAPIMakeEdge_ToTopoDSEdge"(ByVal edge As BRepBuilderAPIMakeEdge) As TopoDSEdge 
  Declare Sub      BRepBuilderAPIMakeEdge_Free Cdecl Alias "BRepBuilderAPIMakeEdge_Free"(ByVal edge As BRepBuilderAPIMakeEdge) 

  Declare Function BRepBuilderAPIMakeWire_Init Cdecl Alias "BRepBuilderAPIMakeWire_Init"() As BRepBuilderAPIMakeWire 
  Declare Function BRepBuilderAPIMakeWire_InitWithTopoDSEdge Cdecl Alias "BRepBuilderAPIMakeWire_InitWithTopoDSEdge"(ByVal edge As TopoDSEdge) As BRepBuilderAPIMakeWire 
  Declare Sub      BRepBuilderAPIMakeWire_AddEdge Cdecl Alias "BRepBuilderAPIMakeWire_AddEdge"(ByVal wire As BRepBuilderAPIMakeWire ,ByVal edge As TopoDSEdge) 
  Declare Sub      BRepBuilderAPIMakeWire_AddWire Cdecl Alias "BRepBuilderAPIMakeWire_AddWire"(ByVal makeWire As BRepBuilderAPIMakeWire ,ByVal wire As TopoDSWire) 
  Declare Function BRepBuilderAPIMakeWire_ToTopoDSWire Cdecl Alias "BRepBuilderAPIMakeWire_ToTopoDSWire"(ByVal wire As BRepBuilderAPIMakeWire) As TopoDSWire 
  Declare Sub      BRepBuilderAPIMakeWire_Free Cdecl Alias "BRepBuilderAPIMakeWire_Free"(ByVal wire As BRepBuilderAPIMakeWire) 

  Declare Function BRepBuilderAPIMakeFace_InitWithWire Cdecl Alias "BRepBuilderAPIMakeFace_InitWithWire"(ByVal wire As TopoDSWire) As BRepBuilderAPIMakeFace 
  Declare Function BRepBuilderAPIMakeFace_ToTopoDSFace Cdecl Alias "BRepBuilderAPIMakeFace_ToTopoDSFace"(ByVal face As BRepBuilderAPIMakeFace) As TopoDSFace 
  Declare Sub      BRepBuilderAPIMakeFace_Free Cdecl Alias "BRepBuilderAPIMakeFace_Free"(ByVal face As BRepBuilderAPIMakeFace) 
  Declare Function BRepBuilderAPIMakeShape_Shape Cdecl Alias "BRepBuilderAPIMakeShape_Shape"(ByVal makeShape As BRepBuilderAPIMakeShape) As TopoDSShape 
  Declare Function BRepBuilderAPITransform_InitWithShapeTrsf Cdecl Alias "BRepBuilderAPITransform_InitWithShapeTrsf"(ByVal shape As TopoDSShape ,ByVal trsf As gpTrsf) As BRepBuilderAPITransform 
  Declare Function BRepBuilderAPITransform_Shape Cdecl Alias "BRepBuilderAPITransform_Shape"(ByVal breptrsf As BRepBuilderAPITransform) As TopoDSShape 
  Declare Sub      BRepBuilderAPITransform_Free Cdecl Alias "BRepBuilderAPITransform_Free"(ByVal breptrsf As BRepBuilderAPITransform) 

' ---------------------------------------
' Fichero: toptools_listofshape.h
  Declare Function TopToolsListOfShape_Init Cdecl Alias "TopToolsListOfShape_Init"() As TopToolsListOfShape 
  Declare Sub      TopToolsListOfShape_Free Cdecl Alias "TopToolsListOfShape_Free"(ByVal list As TopToolsListOfShape) 
  Declare Function TopToolsListOfShape_Append Cdecl Alias "TopToolsListOfShape_Append"(ByVal list As TopToolsListOfShape ,ByVal shape As TopoDSShape) As TopoDSShape 
  Declare Sub      TopToolsListOfShape_AppendList Cdecl Alias "TopToolsListOfShape_AppendList"(ByVal list As TopToolsListOfShape ,ByVal other As TopToolsListOfShape) 
  Declare Function TopToolsListOfShape_Extent Cdecl Alias "TopToolsListOfShape_Extent"(ByVal list As TopToolsListOfShape) As Long Ptr 
  Declare Function TopToolsListOfShape_Begin Cdecl Alias "TopToolsListOfShape_Begin"(ByVal list As TopToolsListOfShape) As ShapeIterator 

  Declare Function ShapeIterator_Next Cdecl Alias "ShapeIterator_Next"(ByVal iter As ShapeIterator) As ShapeIterator 
  Declare Function ShapeIterator_Shape Cdecl Alias "ShapeIterator_Shape"(ByVal iter As ShapeIterator) As TopoDSShape 

' ---------------------------------------
' Fichero: brepalgoapi.h
  Declare Function BRepAlgoAPIFuse_Init Cdecl Alias "BRepAlgoAPIFuse_Init"() As BRepAlgoAPIFuse 
  Declare Sub      BRepAlgoAPIFuse_Free Cdecl Alias "BRepAlgoAPIFuse_Free"(ByVal algo As BRepAlgoAPIFuse) 
  Declare Function BRepAlgoAPIFuse_ToBooleanOperation Cdecl Alias "BRepAlgoAPIFuse_ToBooleanOperation"(ByVal algo As BRepAlgoAPIFuse) As BRepAlgoAPIBooleanOperation 
	
  Declare Function BRepAlgoAPICut_Init Cdecl Alias "BRepAlgoAPICut_Init"() As BRepAlgoAPICut 
  Declare Sub      BRepAlgoAPICut_Free Cdecl Alias "BRepAlgoAPICut_Free"(ByVal algo As BRepAlgoAPICut) 
  Declare Function BRepAlgoAPICut_ToBooleanOperation Cdecl Alias "BRepAlgoAPICut_ToBooleanOperation"(ByVal algo As BRepAlgoAPICut) As BRepAlgoAPIBooleanOperation 

  Declare Function BRepAlgoAPIBooleanOperation_Shape Cdecl Alias "BRepAlgoAPIBooleanOperation_Shape"(ByVal op As BRepAlgoAPIBooleanOperation) As TopoDSShape 
  Declare Sub      BRepAlgoAPIBooleanOperation_SetTools Cdecl Alias "BRepAlgoAPIBooleanOperation_SetTools"(ByVal op As BRepAlgoAPIBooleanOperation ,ByVal list As TopToolsListOfShape) 
  Declare Sub      BRepAlgoAPIBooleanOperation_SetArguments Cdecl Alias "BRepAlgoAPIBooleanOperation_SetArguments"(ByVal op As BRepAlgoAPIBooleanOperation ,ByVal list As TopToolsListOfShape) 
  Declare Sub      BRepAlgoAPIBooleanOperation_Build Cdecl Alias "BRepAlgoAPIBooleanOperation_Build"(ByVal op As BRepAlgoAPIBooleanOperation) 
  Declare Sub      BRepAlgoAPIBooleanOperation_Free Cdecl Alias "BRepAlgoAPIBooleanOperation_Free"(ByVal op As BRepAlgoAPIBooleanOperation) 

' ---------------------------------------
' Fichero: brepfilletapi.h
  Declare Function BRepFilletAPIMakeFillet_Init Cdecl Alias "BRepFilletAPIMakeFillet_Init"(ByVal shape As TopoDSShape) As BRepFilletAPIMakeFillet 
  Declare Sub      BRepFilletAPIMakeFillet_Add  Cdecl Alias "BRepFilletAPIMakeFillet_Add"(ByVal fillet As BRepFilletAPIMakeFillet ,ByVal edge As TopoDSEdge ,ByVal radius As Double) 
  Declare Function BRepFilletAPIMakeFillet_Shape Cdecl Alias "BRepFilletAPIMakeFillet_Shape"(ByVal fillet As BRepFilletAPIMakeFillet) As TopoDSShape 
  Declare Sub      BRepFilletAPIMakeFillet_Free  Cdecl Alias "BRepFilletAPIMakeFillet_Free"(ByVal fillet As BRepFilletAPIMakeFillet) 
  
  Declare Function BRepFilletAPIMakeChamfer_Init Cdecl Alias "BRepFilletAPIMakeChamfer_Init"(ByVal shape As TopoDSShape) As BRepFilletAPIMakeChamfer 
  Declare Sub      BRepFilletAPIMakeChamfer_Add  Cdecl Alias "BRepFilletAPIMakeChamfer_Add"(ByVal f As BRepFilletAPIMakeChamfer ,ByVal e As TopoDSEdge ,ByVal radius As Double) 
  Declare Function BRepFilletAPIMakeChamfer_Shape Cdecl Alias "BRepFilletAPIMakeChamfer_Shape"(ByVal f As BRepFilletAPIMakeChamfer) As TopoDSShape 
  Declare Sub      BRepFilletAPIMakeChamfer_Free  Cdecl Alias "BRepFilletAPIMakeChamfer_Free"(ByVal f As BRepFilletAPIMakeChamfer) 

' ---------------------------------------
' Fichero: brepgprop.h
  Declare Sub      BRepGProp_SurfaceProperties Cdecl Alias "BRepGProp_SurfaceProperties"(ByVal shape As TopoDSShape ,ByVal sprops As GPropGProps ,ByVal skipShared As Boolean ,ByVal useTriangulation As Boolean) 
  Declare Sub      BRepGProp_LinearProperties  Cdecl Alias "BRepGProp_LinearProperties" (ByVal shape As TopoDSShape ,ByVal sprops As GPropGProps ,ByVal skipShared As Boolean ,ByVal useTriangulation As Boolean) 

' ---------------------------------------
' Fichero: brepmesh.h
  Declare Function BRepMeshIncrementalMesh_Init Cdecl Alias "BRepMeshIncrementalMesh_Init"(ByVal shape As TopoDSShape ,ByVal linearDefl As Double ,ByVal isRelative As Boolean ,ByVal angularDefl As Double ,ByVal isParallel As Boolean) As BRepMeshIncrementalMesh 
  Declare Sub      BRepMeshIncrementalMesh_Free Cdecl Alias "BRepMeshIncrementalMesh_Free"(ByVal mesh As BRepMeshIncrementalMesh) 

' ---------------------------------------
' Fichero: brepprimapi.h
  Declare Function BRepPrimAPIMakeRevol_Init Cdecl Alias "BRepPrimAPIMakeRevol_Init"(ByVal face As TopoDSFace ,ByVal axis As gpAx1 ,ByVal degrees As Double) As BRepPrimAPIMakeRevol 
  Declare Function BRepPrimAPIMakeRevol_Shape Cdecl Alias "BRepPrimAPIMakeRevol_Shape"(ByVal makeRevol As BRepPrimAPIMakeRevol) As TopoDSShape 
  Declare Sub      BRepPrimAPIMakeRevol_Free Cdecl Alias "BRepPrimAPIMakeRevol_Free"(ByVal makeRevol As BRepPrimAPIMakeRevol) 

  Declare Function BRepPrimAPIMakePrism_Init Cdecl Alias "BRepPrimAPIMakePrism_Init"(ByVal face As TopoDSFace ,ByVal vec As gpVec) As BRepPrimAPIMakePrism 
  Declare Function BRepPrimAPIMakePrism_Shape Cdecl Alias "BRepPrimAPIMakePrism_Shape"(ByVal makePrism As BRepPrimAPIMakePrism) As TopoDSShape 
  Declare Sub      BRepPrimAPIMakePrism_Free Cdecl Alias "BRepPrimAPIMakePrism_Free"(ByVal makePrism As BRepPrimAPIMakePrism) 

  Declare Function BRepPrimAPIMakeCylinder_Init Cdecl Alias "BRepPrimAPIMakeCylinder_Init"(ByVal position As gpAx2 ,ByVal radius As Double ,ByVal height As Double) As BRepPrimAPIMakeCylinder 
  Declare Function BRepPrimAPIMakeCylinder_Shape Cdecl Alias "BRepPrimAPIMakeCylinder_Shape"(ByVal makeCylinder As BRepPrimAPIMakeCylinder) As TopoDSShape 
  Declare Sub      BRepPrimAPIMakeCylinder_Free Cdecl Alias "BRepPrimAPIMakeCylinder_Free"(ByVal makeCylinder As BRepPrimAPIMakeCylinder) 

  Declare Function BRepPrimAPIMakeSphere_Init Cdecl Alias "BRepPrimAPIMakeSphere_Init"(ByVal position As gpAx2 ,ByVal radius As Double ) As BRepPrimAPIMakeSphere 
  Declare Function BRepPrimAPIMakeSphere_Shape Cdecl Alias "BRepPrimAPIMakeSphere_Shape"(ByVal makeSphere As BRepPrimAPIMakeSphere) As TopoDSShape 
  Declare Sub      BRepPrimAPIMakeSphere_Free Cdecl Alias "BRepPrimAPIMakeSphere_Free"(ByVal makeSphere As BRepPrimAPIMakeSphere) 

  Declare Function BRepPrimAPIMakeBox_Init Cdecl Alias "BRepPrimAPIMakeBox_Init"(ByVal position As gpAx2 ,ByVal dx As Double ,ByVal dy As Double ,ByVal dz As Double) As BRepPrimAPIMakeBox 
  Declare Function BRepPrimAPIMakeBox_Shape Cdecl Alias "BRepPrimAPIMakeBox_Shape"(ByVal makeBox As BRepPrimAPIMakeBox) As TopoDSShape 
  Declare Sub      BRepPrimAPIMakeBox_Free Cdecl Alias "BRepPrimAPIMakeBox_Free"(ByVal makeBox As BRepPrimAPIMakeBox) 

' ---------------------------------------
' Fichero: breptools.h
  Declare Sub      BRepTools_UVBounds Cdecl Alias "BRepTools_UVBounds"(ByVal face As TopoDSFace ,ByVal  umin As Double,ByVal  umax As Double,ByVal  vmin As Double,ByVal  vmax As Double) 

' ---------------------------------------
' Fichero: brep_adapter.h
	Type As Long Ptr GeomAbs_SurfaceType 
  Declare Function BRepAdapterCurve_Init Cdecl Alias "BRepAdapterCurve_Init"(ByVal edge As TopoDSEdge) As BRepAdapterCurve 
  Declare Function BRepAdapterCurve_IsLine Cdecl Alias "BRepAdapterCurve_IsLine"(ByVal curve As BRepAdapterCurve) As Boolean 
  Declare Function BRepAdapterCurve_IsCircle Cdecl Alias "BRepAdapterCurve_IsCircle"(ByVal curve As BRepAdapterCurve) As Boolean 
  Declare Function BRepAdapterCurve_IsEllipse Cdecl Alias "BRepAdapterCurve_IsEllipse"(ByVal curve As BRepAdapterCurve) As Boolean 
  Declare Function BRepAdapterCurve_ToCircle Cdecl Alias "BRepAdapterCurve_ToCircle"(ByVal curve As BRepAdapterCurve) As gpCirc 

  Declare Function BRepAdapterSurface_Init Cdecl Alias "BRepAdapterSurface_Init"(ByVal face As TopoDSFace) As BRepAdapterSurface 
  Declare Function BRepAdapterSurface_InitRestriction Cdecl Alias "BRepAdapterSurface_InitRestriction"(ByVal face As TopoDSFace ,ByVal restriction As Boolean) As BRepAdapterSurface 
  Declare Function BRepAdapterSurface_Plane Cdecl Alias "BRepAdapterSurface_Plane"(ByVal surface As BRepAdapterSurface) As gpPln 
  Declare Function BRepAdapterSurface_Direction Cdecl Alias "BRepAdapterSurface_Direction"(ByVal surface As BRepAdapterSurface) As gpDir 
  Declare Function BRepAdapterSurface_Type Cdecl Alias "BRepAdapterSurface_Type"(ByVal surface As BRepAdapterSurface) As GeomAbs_SurfaceType 
  Declare Sub      BRepAdapterSurface_Free Cdecl Alias "BRepAdapterSurface_Free"(ByVal surface As BRepAdapterSurface) 

' ---------------------------------------
' Fichero: brep_tool.h
  Declare Function BRepTool_Surface Cdecl Alias "BRepTool_Surface"(ByVal face As TopoDSFace) As gcSurface 
  Declare Sub      GCSurface_Free Cdecl Alias "GCSurface_Free"(ByVal surface As gcSurface) 
  Declare Function BRepTool_Pnt Cdecl Alias "BRepTool_Pnt"(ByVal vertex As TopoDSVertex) As gpPnt 

' ---------------------------------------
' Fichero: gcpnts.h
  Declare Function CurveLength Cdecl Alias "CurveLength"(ByVal c As BRepAdapterCurve) As Double 

' ---------------------------------------
' Fichero: geomlprop_slprops.h
  Declare Function GeomLPropSLProps_Init Cdecl Alias "GeomLPropSLProps_Init"(ByVal surface As gcSurface ,ByVal umin As Double ,ByVal vmin As Double ,ByVal n As Double ,ByVal res As Double) As GeomLPropSLProps 
  Declare Function GeomLPropsSLProps_Normal Cdecl Alias "GeomLPropsSLProps_Normal"(ByVal props As GeomLPropSLProps) As gpDir 
  Declare Sub      GeomLPropSLProps_Free Cdecl Alias "GeomLPropSLProps_Free"(ByVal props As GeomLPropSLProps) 

' ---------------------------------------
' Fichero: geom_adapter.h
  Declare Function GeomAdapterSurface_Init Cdecl Alias "GeomAdapterSurface_Init"(ByVal surface As gcSurface) As GeomAdapterSurface 
  Declare Sub      GeomAdapterSurface_Free Cdecl Alias "GeomAdapterSurface_Free"(ByVal surface As GeomAdapterSurface) 
  Declare Function GeomAdapterSurface_IsConical Cdecl Alias "GeomAdapterSurface_IsConical"(ByVal surface As GeomAdapterSurface) As Boolean 
  Declare Function GeomAdapterSurface_IsCylindrical Cdecl Alias "GeomAdapterSurface_IsCylindrical"(ByVal surface As GeomAdapterSurface) As Boolean 
  Declare Function GeomAdapterSurface_IsPlanar Cdecl Alias "GeomAdapterSurface_IsPlanar"(ByVal surface As GeomAdapterSurface) As Boolean 

' ---------------------------------------
' Fichero: geom_curve.h
  Declare Function gcMakeCircle Cdecl Alias "gcMakeCircle"(ByVal center As gpAx2 ,ByVal radius As Double) As gcTrimmedCurve 
  Declare Function gcMakeArcOfCircle Cdecl Alias "gcMakeArcOfCircle"(ByVal circles As gpCirc ,ByVal pt1 As gpPnt ,ByVal pt2 As gpPnt ,ByVal sense As Boolean) As gcTrimmedCurve 
  Declare Function gcMakeArcOfCirclePts Cdecl Alias "gcMakeArcOfCirclePts"(ByVal pt1 As gpPnt ,ByVal pt2 As gpPnt ,ByVal pt3 As gpPnt) As gcTrimmedCurve 
  Declare Function gcMakeSegment Cdecl Alias "gcMakeSegment"(ByVal start As gpPnt ,ByVal end As gpPnt) As gcTrimmedCurve 
  Declare Sub      gcTrimmedCurve_Free Cdecl Alias "gcTrimmedCurve_Free"(ByVal arc As gcTrimmedCurve) 
  Declare Function gcTrimmedCurve_ToGeomCurve Cdecl Alias "gcTrimmedCurve_ToGeomCurve"(ByVal curve As gcTrimmedCurve) As GeomCurve 

' ---------------------------------------
' Fichero: gprop.h
  Declare Function GPropGProps_Init Cdecl Alias "GPropGProps_Init"() As GPropGProps 
  Declare Sub      GPropGProps_Free Cdecl Alias "GPropGProps_Free"(ByVal props As GPropGProps) 
  Declare Function GPropGProps_Mass Cdecl Alias "GPropGProps_Mass"(ByVal props As GPropGProps) As Double 
  Declare Function GPropGProps_CentreOfMass Cdecl Alias "GPropGProps_CentreOfMass"(ByVal props As GPropGProps) As gpPnt 

' ---------------------------------------
' Fichero: gp_ax1.h
  Declare Function gpAx1_Init Cdecl Alias "gpAx1_Init"(ByVal origin As gpPnt ,ByVal dirs As gpDir) As gpAx1 
  Declare Function gpAx1_Direction Cdecl Alias "gpAx1_Direction"(ByVal axis As gpAx1) As gpDir 
  Declare Sub      gpAx1_Free Cdecl Alias "gpAx1_Free"(ByVal axis As gpAx1) 

' ---------------------------------------
' Fichero: gp_ax2.h
  Declare Function gpAx2_Init Cdecl Alias "gpAx2_Init"(ByVal origin As gpPnt ,ByVal normal As gpDir ,ByVal xAxis As gpDir) As gpAx2 
  Declare Sub      gpAx2_Free Cdecl Alias "gpAx2_Free"(ByVal axis As gpAx2) 

' ---------------------------------------
' Fichero: gp_ax3.h
  Declare Function gpAx3_Init Cdecl Alias "gpAx3_Init"(ByVal origin As gpPnt ,ByVal normal As gpDir ,ByVal xDir As gpDir) As gpAx3 
  Declare Function gpAx3_XDirection Cdecl Alias "gpAx3_XDirection"(ByVal coord As gpAx3) As gpDir 
  Declare Function gpAx3_YDirection Cdecl Alias "gpAx3_YDirection"(ByVal coord As gpAx3) As gpDir 
  Declare Function gpAx3_Direction Cdecl Alias "gpAx3_Direction"(ByVal coord As gpAx3) As gpDir 
  Declare Function gpAx3_Location Cdecl Alias "gpAx3_Location"(ByVal coord As gpAx3) As gpPnt 
  Declare Sub      gpAx3_Rotate Cdecl Alias "gpAx3_Rotate"(ByVal coord As gpAx3 ,ByVal axis As gpAx1 ,ByVal angle As Double) 
  Declare Function gpAx3_Translated Cdecl Alias "gpAx3_Translated"(ByVal coord As gpAx3 ,ByVal vec As gpVec) As gpAx3 
  Declare Sub      gpAx3_Free Cdecl Alias "gpAx3_Free"(ByVal coord As gpAx3) 

' ---------------------------------------
' Fichero: gp_circ.h
  Declare Function gpCirc_Init Cdecl Alias "gpCirc_Init"(ByVal center As gpAx2 ,ByVal radius As Double) As gpCirc 
  Declare Function gpCirc_Radius Cdecl Alias "gpCirc_Radius"(ByVal circles As gpCirc) As Double 
  Declare Function gpCirc_Location Cdecl Alias "gpCirc_Location"(ByVal circles As gpCirc) As gpPnt 
  Declare Sub      gpCirc_Free Cdecl Alias "gpCirc_Free"(ByVal circles As gpCirc) 

' ---------------------------------------
' Fichero: gp_dir.h
  Declare Function gpDir_Init Cdecl Alias "gpDir_Init"(ByVal x As Double ,ByVal y As Double ,ByVal z As Double) As gpDir 
  Declare Function gpDir_InitVec Cdecl Alias "gpDir_InitVec"(ByVal vector As gpVec) As gpDir 
  Declare Sub      gpDir_Free Cdecl Alias "gpDir_Free"(ByVal dirs As gpDir) 
  Declare Function gpDir_X Cdecl Alias "gpDir_X"(ByVal dirs As gpDir) As Double 
  Declare Function gpDir_Y Cdecl Alias "gpDir_Y"(ByVal dirs As gpDir) As Double 
  Declare Function gpDir_Z Cdecl Alias "gpDir_Z"(ByVal dirs As gpDir) As Double 
  Declare Function gpDir_Dot Cdecl Alias "gpDir_Dot"(ByVal dirs As gpDir ,ByVal other As gpDir) As Double 
  Declare Function gpDir_IsEqual Cdecl Alias "gpDir_IsEqual"(ByVal dirs As gpDir ,ByVal other As gpDir) As Boolean 
  Declare Function gpDir_IsParallel Cdecl Alias "gpDir_IsParallel"(ByVal dirs As gpDir ,ByVal other As gpDir) As Boolean 

' ---------------------------------------
' Fichero: gp_pln.h
  Declare Function gpPln_Init Cdecl Alias "gpPln_Init"() As gpPln 
  Declare Function gpPln_InitAx3 Cdecl Alias "gpPln_InitAx3"(ByVal coord As gpAx3) As gpPln 
  Declare Function gpPln_InitPntDir Cdecl Alias "gpPln_InitPntDir"(ByVal origin As gpPnt ,ByVal dirs As gpDir) As gpPln 
  Declare Function gpPln_Axis Cdecl Alias "gpPln_Axis"(ByVal plane As gpPln) As gpAx1 
  Declare Function gpPln_Position Cdecl Alias "gpPln_Position"(ByVal plane As gpPln) As gpAx3 
  Declare Function gpPln_ContainsPoint Cdecl Alias "gpPln_ContainsPoint"(ByVal plane As gpPln ,ByVal points As gpPnt) As Boolean 
  Declare Sub      gpPln_Free Cdecl Alias "gpPln_Free"(ByVal plane As gpPln) 

' ---------------------------------------
' Fichero: gp_pnt.h
  Declare Function gpPnt_Init Cdecl Alias "gpPnt_Init"(ByVal x As Double ,ByVal y As Double ,ByVal z As Double) As gpPnt 
  Declare Sub      gpPnt_Free Cdecl Alias "gpPnt_Free"(ByVal pnt As gpPnt) 
  Declare Sub      gpPnt_SetCoord Cdecl Alias "gpPnt_SetCoord"(ByVal pnt As gpPnt ,ByVal x As Double ,ByVal y As Double ,ByVal z As Double) 
  Declare Sub      gpPnt_SetX Cdecl Alias "gpPnt_SetX"(ByVal pnt As gpPnt ,ByVal x As Double) 
  Declare Sub      gpPnt_SetY Cdecl Alias "gpPnt_SetY"(ByVal pnt As gpPnt ,ByVal y As Double) 
  Declare Sub      gpPnt_SetZ Cdecl Alias "gpPnt_SetZ"(ByVal pnt As gpPnt ,ByVal z As Double) 
  Declare Function gpPnt_X Cdecl Alias "gpPnt_X"(ByVal pnt As gpPnt) As Double 
  Declare Function gpPnt_Y Cdecl Alias "gpPnt_Y"(ByVal pnt As gpPnt) As Double 
  Declare Function gpPnt_Z Cdecl Alias "gpPnt_Z"(ByVal pnt As gpPnt) As Double 
  Declare Function gpPnt_IsEqual Cdecl Alias "gpPnt_IsEqual"(ByVal pnt As gpPnt ,ByVal other As gpPnt ,ByVal tolerance As Double) As Boolean 
  Declare Function gpPnt_Distance Cdecl Alias "gpPnt_Distance"(ByVal pnt As gpPnt ,ByVal other As gpPnt) As Double 
  Declare Function gpPnt_SquareDistance Cdecl Alias "gpPnt_SquareDistance"(ByVal pnt As gpPnt ,ByVal other As gpPnt) As Double 
  Declare Sub      gpPnt_MirrorCenterPoint Cdecl Alias "gpPnt_MirrorCenterPoint"(ByVal pnt As gpPnt ,ByVal center As gpPnt) 
  Declare Function gpPnt_MirroredCenterPoint Cdecl Alias "gpPnt_MirroredCenterPoint"(ByVal pnt As gpPnt ,ByVal center As gpPnt) As gpPnt 
  Declare Sub      gpPnt_MirrorAxis Cdecl Alias "gpPnt_MirrorAxis"(ByVal pnt As gpPnt ,ByVal axis As gpAx1) 
  Declare Function gpPnt_MirroredAxis Cdecl Alias "gpPnt_MirroredAxis"(ByVal pnt As gpPnt ,ByVal axis As gpAx1) As gpPnt 
  Declare Sub      gpPnt_Rotate Cdecl Alias "gpPnt_Rotate"(ByVal pnt As gpPnt ,ByVal axis As gpAx1 ,ByVal angle As Double) 
  Declare Function gpPnt_Rotated Cdecl Alias "gpPnt_Rotated"(ByVal pnt As gpPnt ,ByVal axis As gpAx1 ,ByVal angle As Double) As gpPnt 
  Declare Sub      gpPnt_Scale Cdecl Alias "gpPnt_Scale"(ByVal pnt As gpPnt ,ByVal other As gpPnt ,ByVal scale As Double) 
  Declare Function gpPnt_Scaled Cdecl Alias "gpPnt_Scaled"(ByVal pnt As gpPnt ,ByVal other As gpPnt ,ByVal scale As Double) As gpPnt 
  Declare Sub      gpPnt_Transform Cdecl Alias "gpPnt_Transform"(ByVal pnt As gpPnt ,ByVal transform As gpTrsf) 
  Declare Function gpPnt_Transformed Cdecl Alias "gpPnt_Transformed"(ByVal pnt As gpPnt ,ByVal transform As gpTrsf) As gpPnt 
  Declare Sub      gpPnt_Translate Cdecl Alias "gpPnt_Translate"(ByVal pnt As gpPnt ,ByVal vector As gpVec) 
  Declare Function gpPnt_Translated Cdecl Alias "gpPnt_Translated"(ByVal pnt As gpPnt ,ByVal vector As gpVec) As gpPnt 
  Declare Sub      gpPnt_TranslatePoints Cdecl Alias "gpPnt_TranslatePoints"(ByVal pnt As gpPnt ,ByVal pnt1 As gpPnt ,ByVal pnt2 As gpPnt) 
  Declare Function gpPnt_TranslatedPoints Cdecl Alias "gpPnt_TranslatedPoints"(ByVal pnt As gpPnt ,ByVal pnt1 As gpPnt ,ByVal pnt2 As gpPnt) As gpPnt 

' ---------------------------------------
' Fichero: gp_trsf.h
  Declare Function gpTrsf_Init Cdecl Alias "gpTrsf_Init"() As gpTrsf 
  Declare Sub      gpTrsf_SetMirror Cdecl Alias "gpTrsf_SetMirror"(ByVal trsf As gpTrsf ,ByVal axis As gpAx1) 
  Declare Sub      gpTrsf_SetMirrorAx1 Cdecl Alias "gpTrsf_SetMirrorAx1"(ByVal transform As gpTrsf ,ByVal axis As gpAx1) 
  Declare Sub      gpTrsf_SetMirrorAx2 Cdecl Alias "gpTrsf_SetMirrorAx2"(ByVal transform As gpTrsf ,ByVal axis As gpAx2) 
  Declare Sub      gpTrsf_SetTransformation Cdecl Alias "gpTrsf_SetTransformation"(ByVal transform As gpTrsf ,ByVal from As gpAx3 ,ByVal to_ As gpAx3) 
  Declare Sub      gpTrsf_SetRotation Cdecl Alias "gpTrsf_SetRotation"(ByVal transform As gpTrsf ,ByVal axis As gpAx1 ,ByVal rads As Double) 
	
  Declare Sub      gpTrsf_SetTranslation Cdecl Alias "gpTrsf_SetTranslation"(ByVal transform As gpTrsf ,ByVal vec As gpVec) 
  Declare Function gpTrsf_GetRotation Cdecl Alias "gpTrsf_GetRotation"(ByVal transform As gpTrsf) As gpQuaternion 
  Declare Sub      gpTrsf_Free Cdecl Alias "gpTrsf_Free"(ByVal transform As gpTrsf) 

' ---------------------------------------
' Fichero: gp_vec.h
  Declare Function gpVec_Init Cdecl Alias "gpVec_Init"(ByVal x As Double ,ByVal y As Double ,ByVal z As Double) As gpVec 
  Declare Function gpVec_InitDir Cdecl Alias "gpVec_InitDir"(ByVal dirs As gpDir) As gpVec 
  Declare Function gpVec_InitPoints Cdecl Alias "gpVec_InitPoints"(ByVal ini As gpPnt ,ByVal fin As gpPnt) As gpVec 
  Declare Sub      gpVec_Free Cdecl Alias "gpVec_Free"(ByVal vector As gpVec) 
  Declare Function gpVec_X Cdecl Alias "gpVec_X"(ByVal vec As gpVec) As Double 
  Declare Function gpVec_Y Cdecl Alias "gpVec_Y"(ByVal vec As gpVec) As Double 
  Declare Function gpVec_Z Cdecl Alias "gpVec_Z"(ByVal vec As gpVec) As Double 
  Declare Function gpVec_IsEqual Cdecl Alias "gpVec_IsEqual"(ByVal vec As gpVec ,ByVal other As gpVec) As Boolean 
  Declare Function gpVec_Dot Cdecl Alias "gpVec_Dot"(ByVal v As gpVec ,ByVal other As gpVec) As Double 
  Declare Function gpVec_Multiplied Cdecl Alias "gpVec_Multiplied"(ByVal v As gpVec ,ByVal dist As Double) As gpVec 
  Declare Function gpVec_Crossed Cdecl Alias "gpVec_Crossed"(ByVal v As gpVec ,ByVal other As gpVec) As gpVec 
  Declare Function gpVec_Normalized Cdecl Alias "gpVec_Normalized"(ByVal v As gpVec) As gpVec 
  Declare Function gpVec_Magnitude Cdecl Alias "gpVec_Magnitude"(ByVal v As gpVec) As Double 
	'
  Declare Function gpResolution Cdecl Alias "gpResolution"() As Double 

' ---------------------------------------
' Fichero: gp_quaternion.h
  Declare Function gpQuaternion_Inverted Cdecl Alias "gpQuaternion_Inverted"(ByVal q As gpQuaternion) As gpQuaternion 
  Declare Function gpQuaternion_Multiplied Cdecl Alias "gpQuaternion_Multiplied"(ByVal q As gpQuaternion ,ByVal other As gpQuaternion) As gpQuaternion 
  Declare Function gpQuaternion_IsEqual Cdecl Alias "gpQuaternion_IsEqual"(ByVal q As gpQuaternion ,ByVal other As gpQuaternion) As Boolean 
  Declare Function gpQuaternion_GetRotationAngle Cdecl Alias "gpQuaternion_GetRotationAngle"(ByVal q As gpQuaternion) As Double 
  Declare Sub      gpQuaternion_Free Cdecl Alias "gpQuaternion_Free"(ByVal q As gpQuaternion) 

' ---------------------------------------
' Fichero: occutils.h
  Declare Function gpPnt_Midpoint Cdecl Alias "gpPnt_Midpoint"(ByVal p1 As gpPnt ,ByVal p2 As gpPnt) As gpPnt 

' ---------------------------------------
' Fichero: stepcontrol_writer.h
   Type As Long Ptr STEPControlStepModelType 
  Declare Function STEPControlWriter_Init  Cdecl Alias "STEPControlWriter_Init"() As STEPControlWriter 
  Declare Function STEPControlWriter_Add   Cdecl Alias "STEPControlWriter_Transfer"(ByVal writer As STEPControlWriter ,ByVal shape As TopoDSShape ,ByVal types As STEPControlStepModelType) As Long Ptr 
  Declare Function STEPControlWriter_Write Cdecl Alias "STEPControlWriter_Write"(ByVal writer As STEPControlWriter ,ByVal filename As Zstring Ptr) As Long Ptr 
  Declare Sub      STEPControlWriter_Free  Cdecl Alias "STEPControlWriter_Free"(ByVal writer As STEPControlWriter) 

' Fichero: IGESapi_writer.h
   Type As Long Ptr IGESControlIgesModelType 
  Declare Function IGESControlWriter_Init  Cdecl Alias "IGESControlWriter_Init"() As IGESControlWriter 
  Declare sub 		 IGESControlWriter_Add   Cdecl Alias "IGESControlWriter_Add"(ByVal writer As IGESControlWriter ,ByVal shape As TopoDSShape ,ByVal types As IGESControlIgesModelType)
  Declare Function IGESControlWriter_Write Cdecl Alias "IGESControlWriter_Write"(ByVal writer As IGESControlWriter ,ByVal filename As Zstring Ptr) As Long Ptr 
  Declare Sub      IGESControlWriter_Free  Cdecl Alias "IGESControlWriter_Free"(ByVal writer As IGESControlWriter) 

' ---------------------------------------
' Fichero: stlapi_writer.h
  Declare Function StlAPIWriter_Init Cdecl Alias "StlAPIWriter_Init"() As StlAPIWriter 
  Declare Function StlAPIWriter_Write Cdecl Alias "StlAPIWriter_Write"(ByVal writer As StlAPIWriter ,ByVal res As TopoDSCompound ,ByVal filename As Zstring Ptr) As Boolean 
  Declare Sub      StlAPIWriter_Free Cdecl Alias "StlAPIWriter_Free"(ByVal writer As StlAPIWriter) 

' ---------------------------------------
' Fichero: topexp_explorer.h
   Type As Long Ptr TopAbsShapeEnum 
  Declare Function TopExpExplorer_Init Cdecl Alias "TopExpExplorer_Init"(ByVal shape As TopoDSShape ,ByVal toFind As TopAbsShapeEnum) As TopExpExplorer 
  Declare Sub      TopExpExplorer_Free Cdecl Alias "TopExpExplorer_Free"(ByVal exp As TopExpExplorer) 
  Declare Function TopExpExplorer_More Cdecl Alias "TopExpExplorer_More"(ByVal exp As TopExpExplorer) As Boolean 
  Declare Sub      TopExpExplorer_Next Cdecl Alias "TopExpExplorer_Next"(ByVal exp As TopExpExplorer) 
  Declare Function TopExpExplorer_Current Cdecl Alias "TopExpExplorer_Current"(ByVal exp As TopExpExplorer) As TopoDSShape 
  Declare Function TopExpExplorer_Depth Cdecl Alias "TopExpExplorer_Depth"(ByVal exp As TopExpExplorer) As Long Ptr 

  Declare Function TopExp_FirstVertex Cdecl Alias "TopExp_FirstVertex"(ByVal edge As TopoDSEdge) As TopoDSVertex 
  Declare Function TopExp_LastVertex Cdecl Alias "TopExp_LastVertex"(ByVal edge As TopoDSEdge) As TopoDSVertex 

' ---------------------------------------
' Fichero: toploc_location.h
  Declare Sub      TopLocLocation_Free Cdecl Alias "TopLocLocation_Free"(ByVal loc As TopLocLocation) 
  Declare Function TopLocLocation_Transformation Cdecl Alias "TopLocLocation_Transformation"(ByVal loc As TopLocLocation) As gpTrsf 

' ---------------------------------------
' Fichero: topods_compound.h
  Declare Function TopoDSCompound_Init Cdecl Alias "TopoDSCompound_Init"() As TopoDSCompound 
  Declare Sub      TopoDSCompound_Free Cdecl Alias "TopoDSCompound_Free"(ByVal comp As TopoDSCompound) 

' ---------------------------------------
' Fichero: topods_shape.h
  Declare Function TopoDSShape_IsEqual Cdecl Alias "TopoDSShape_IsEqual"(ByVal shape As TopoDSShape ,ByVal other As TopoDSShape) As Boolean 
  Declare Sub      TopoDSShape_Free Cdecl Alias "TopoDSShape_Free"(ByVal shape As TopoDSShape) 
  Declare Function TopoDSShape_Location Cdecl Alias "TopoDSShape_Location"(ByVal shape As TopoDSShape) As TopLocLocation 
  Declare Function TopoDSShape_Orientation Cdecl Alias "TopoDSShape_Orientation"(ByVal shape As TopoDSShape) As Long Ptr 
  Declare Function TopoDSShape_Wire Cdecl Alias "TopoDSShape_Wire"(ByVal shape As TopoDSShape) As TopoDSWire 