; ===========================================================================
; FILE : PbFw_Module_VObj.pb
; NAME : PureBasic Framework : Module VectorObjects  [VObj::]
; DESC : 2D/3D Object definition and handling for Objects with 
; DESC : double precicion vector coordinates
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/15
; VERSION  :  0.12  Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;   2024/07/18 S.Maag : addes function for regular Star shape!
;               Added Functions to create Facets from VObj for Mesh use

;   2023/09/01 S.Maag : changed Name form Obj3D to VObj (VectorObjects)
;     because this describes better what it is and we do not have Obj3D
;     prefixes for 2D Objects.                
;     Added some code!
  
;   2023/08/22 S.Maag : fixed syntax Errors!
;}
;{ TODO:
;}
; ===========================================================================

; See this Project from Berkely University for CSG Mesh basic operations
; https://github.com/robonrrd/csg/tree/master

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
XIncludeFile "PbFw_Module_VECTORd.pb"      ; VECd::     double precision Vector Module

DeclareModule VObj
  EnableExplicit
  
  UseModule VECd    ; VectorModul with single preciciion Float values
  
  ;- ----------------------------------------------------------------------
  ;- CONSTANTS
  ; ----------------------------------------------------------------------
    
  Enumeration EVObjType
    
    #VObj_unknown     
    ; ------------------------------------------------------------
    ;- Flat Objects in 2D/3D Space
    ; ------------------------------------------------------------
    #VObj_Text
    #VObj_Line     
    #VObj_Polygon    
    #VObj_Ellipse      
    #VObj_Plane            ; Plane ;[Ebene]      
    #VObj_Arc
    #VObj_Spline                    
   
    ; ------------------------------------------------------------
    ;- Volume Objects in 3D Space
    ; ------------------------------------------------------------    
    #VObj_3DText          ; Volume Text   
    #VObj_3DPoly          ; Volume Polygon    
    #VObj_3DCone
          
  EndEnumeration
  
  Enumeration EVObjSubType 1000         ; start with 1000, so ObjType and ObjSubType are at a different Numspace 
    ;#VObj_Text
    #VObj_Text_TextSingle          ; Single Line Text    
    #VObj_Text_TextMulti           ; Single Line Text    
    
    ;#VObj_Line     
    #VObj_Line_Line                ; Line     
    #VObj_Line_PolyLine            ; PolyLine 
    
    ;#VObj_Polygon    
    #VObj_Polygon_Triangle         ; 3 Edges 
    #VObj_Polygon_Rectangle        ; 4 Edges, regualr Rectangel
    #VObj_Polygon_Pentagon         ; 5 Edges, regular Pentagon
    #VObj_Polygon_Hexagon          ; 6 Edges, regular Hexagon
    #VObj_Polygon_Octagon          ; 8 Edges, regular Octagon
    #VObj_Polygon_Star             ; n Spikes, regular Star   
    #VObj_Polygon_Polygon          ; any other Polygon
          
    ;#VObj_Ellipse      
    #VObj_Ellipse_Circle           ; Circle 
    #VObj_Ellipse_Ellipse          ; Ellipse)   
    
    ;#VObj_Plane            ; Plane ;[Ebene]      
    

    ;#VObj_Arc
    #VObj_Arc_Circular             ; Circular Arc
    #VObj_Arc_Conic                ; Circular Arc
    
    ;#VObj_Spline                    
    #VObj_Spline_CatMullRom        ; Catmull Rom Spline
    #VObj_Spline_CSpline           ; Cubic Spline
    #VObj_Spline_BSpline           ; Bezier Spline
    #VObj_Spline_TSpline           ; T-Spline

    ; ---------------------------------------------------------------------------------
    ;#VObj_3DPoly                  ; Volume Polygon    
    #VObj_3DPoly_Triangle          ; 3 Edges 
    #VObj_3DPoly_Rectangle         ; 4 Edges, regualr Rectangel
    #VObj_3DPoly_Pentagon          ; 5 Edges, regular Pentagon
    #VObj_3DPoly_Hexagon           ; 6 Edges, regular Hexagon
    #VObj_3DPoly_Octagon           ; 8 Edges, regular Octagon
    #VObj_3DPoly_Star              ; n Spikes, regular Star   
    #VObj_3DPoly_Polygon           ; any other Polygon
    
    ;#VObj_3DCone
    #VObj_3DCone_Cylinder          ; 3D Cylinder
    #VObj_3DCone_EllipticCylinder  ; 3D elliptical Cylinder
    #VObj_3DCone_Cone              ; 3D Cone  {Kegel}
    #VObj_3DCone_EllipticCone      ; 3D elliptical Cone {elliptischer Kegel} 
    
 
  EndEnumeration
  
  EnumerationBinary EVObjFlags
    #VObj_Flag_Hidden
    #VObj_Flag_Locked 
    #VObj_Flag_Flat 
  EndEnumeration
  
  Enumeration EVObj_FillStyle
    #VObj_FillStyle_Transparent    ; Transparent = without filling
    #VObj_FillStyle_Solid          ; with solid filling
    #VObj_FillStyle_Pattern        ; Musterfüllung (z.B. gestreift)
    #VObj_FillStyle_Image          ; Filled with an Image (.bmp, .png, .jpg)
  EndEnumeration

  Enumeration EVObj_LineStyle
    #VObj_LineStyle_Solid          ; Solid Line   : StrokePath()
    #VObj_LineStyle_Dash           ; ------ Line  : DashPath()
    #VObj_LineStyle_Dot            ; ..... Line   : DotPath()
    #VObj_LineStyle_DashDot        ; -.-.- Line   : CustomDashPath()
    #VObj_LineStyle_DashDotDot     ; -..-..- Line : CustomDashPath()
  EndEnumeration
    
  ; ----------------------------------------------------------------------
  ; Basic defintions for Text
  ; ----------------------------------------------------------------------

  Enumeration ETextAlign
    #VObj_TextAlign_UpLeft
    #VObj_TextAlign_UpMiddle
    #VObj_TextAlign_UpRight
    #VObj_TextAlign_DownLeft
    #VObj_TextAlign_DownMiddle
    #VObj_TextAlign_DownRight 
  EndEnumeration

  #VObj_Font_BOLD = #PB_Font_Bold
  #VObj_Font_Italic = #PB_Font_Italic
  #VObj_Font_StrikeOut = #PB_Font_StrikeOut
  #VObj_Font_Underline = #PB_Font_Underline
    
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES
  ; ----------------------------------------------------------------------
  Structure TLineStyle
    Color.l               ; Color
    Width.d               ; Line Width
    Style.l               ; LineStyle {EVObj_LineStyle}
  EndStructure
  
  Structure TFillStyle
    Color.l               ; Fill Color
    GradientColor.l       ; Gradient Color {Farbverlauf}
    Style.l               ; Fill Style {EVObj_FillStyle}
  EndStructure   

  Structure TFont   ; Vector Fonts only
    FontID.i
    Size.l
    Style.l         ; #PB_Font_Bold, #PB_Font_Italic
  EndStructure

  ; ------------------------------------------------------------
  ;- Flat Objects in 2D/3D Space
  ; ------------------------------------------------------------
  
  Structure TVObjBase
    *This                     ; Pointer to itself; for plausiblity checks
    ObjType.l                 ; Object-Type     = #VObj_Polygon
    ObjSubType.l              ; Object-SubType  = #VObj_SubType_Triangle
    ObjFlags.l                ; Flags like #VObj_Flag_Hidden
    GroupID.l                 ; if the Object is grouped with others, the Group-ID
    LayerID.l                 ; Drawing layer ID
  EndStructure

  Structure TVObjBase2D Extends TVObjBase
    LStyle.TLineStyle
    NoOfPts.i                 ; Number of Points = 2
    Array PT.TVector(0)       ; Array of Points. Point(0) = Reference Point; Object defintion Points start at PT(1)
  EndStructure
  
  Structure TText Extends TVObjBase2D
    Align.l             ; how to align the Text:  [Enumeration ETextAlign UpLeft, UpMiddle, UpRight, ...]
    Direction.l         ; Enumeration EDirection [#Right, #Left, #Up, #Down]
    Color.i             ; Text Color
    Font.TFont          ; Font
    NoOfLines.i         ; Number of Lines = 1
    Array Txt.s(0)      ; one entry for each Line
  EndStructure

  Structure TLine Extends TVObjBase2D
    ;  Line defintion is excatly the TVObjBase2D Structure
  EndStructure  

  Structure TPolygon Extends TVObjBase2D
    Fill.TFillStyle
  EndStructure
  
  Structure TSpline Extends TPolygon
    Array defPT.TVector(0)    ; Spline definition Points
  EndStructure
  
  Structure TEllipse Extends TVObjBase2D
    Fill.TFillStyle
    Rx.TVector                ; Radius X
    Ry.TVector                ; Radius Y
  EndStructure
   
  ; ----------------------------------------------------------------------
  ;- Volume Objects in 3D Space
  ; ----------------------------------------------------------------------
  
  Structure TVObjBase3D Extends TVObjBase
    TMx.TMatrix               ; Object's Transformation Matrix    
  EndStructure
  
  Structure T3DText Extends TVObjBase3D
    TXT.TText  
  EndStructure
    
  Structure T3DPoly Extends TVObjBase3D       ; Volume Polygon
    POL.TPolygon[2]
  EndStructure
  
  Structure T3DCone Extends TVObjBase3D          ; Volume Cone (Cylinder, Cone)
    EL.TEllipse[2]
  EndStructure  
  
  ; Structure of a 3D Facet with normal Vector
  Structure TFacet
    V1.TVector
    V2.TVector
    V3.TVector
    N.TVector
  EndStructure

  ;- ----------------------------------------------------------------------
  ;- Declare Module
  ;- ----------------------------------------------------------------------
  Declare.i New(ObjType = #VObj_Line)
  Declare.i Kill(*VObj.TVObjBase)
  Declare.i Clone(*VObj)
  Declare.i MoveFlatObj(*VObj.TVObjBase, X.d, Y.d, Z.d=0, MoveType= #PB_Absolute) 

  Declare.i Create_Line(*VObj.TLine, W.d, H.d)
  Declare.i Create_PolyLine(*VObj.TLine, W.d, H.d)

  Declare.i Create_Triangle(*VObj.TPolygon, X2.d,Y2.d, X3.d,Y3.d)
  Declare.i Create_Rectangle(*VObj.TPolygon, W.d, H.d)
  Declare.i Create_Pentagon(*VObj.TPolygon, r.d)
  Declare.i Create_Hexagon(*VObj.TPolygon, r.d)
  Declare.i Create_Octagon(*VObj.TPolygon, r.d)
  Declare.i Create_Star(*VObj.TPolygon, outerRadius.d, innerRadius.d,  NoOfSpikes, StartAngle=0)

  Declare.i Create_Circle(*VObj.TEllipse, r.d)
  Declare.i Create_Ellipse(*VObj.TEllipse, rx.d, ry.d)
  
  Declare.i Create3D_Box(*VObj.T3DPoly, W.d, H.d, D.d)
  Declare.i Create3D_Cylinder(*VObj.T3DCone, r.d, h.d)
  Declare.i Create3D_Cone(*VObj.T3DCone, r1.d, r2.d, h.d)
  Declare.i Create3D_Pentagon(*VObj.T3DPoly, r.d, h.d)
  Declare.i Create3D_Hexagon(*VObj.T3DPoly, r.d, h.d)
  Declare.i Create3D_Octagon(*VObj.T3DPoly, r.d, h.d)

EndDeclareModule

Module VObj
  
  EnableExplicit
  ;- ----------------------------------------------------------------------
  ;- PbFw Module local configurations
  ;  ----------------------------------------------------------------------
  ; This constants must have same Name in all Modules
  
  ; ATTENTION: with the PbFw::CONST Macro the PB-IDE Intellisense do not registrate the ConstantName
  
  ; #PbFwCfg_Module_CheckPointerException = #True     ; On/Off PoninterExeption for this Module
  PbFw::CONST(PbFwCfg_Module_CheckPointerException, #True)

  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
 
  UseModule VECd
  
  ;  ----------------------------------------------------------------------
  ;-  Handling Functions 
  ;- ----------------------------------------------------------------------
  
  Procedure.i New(ObjType = #VObj_Line)
  ; ============================================================================
  ; NAME: New
  ; DESC: Allocate Memory for a New Object, set the ObjectType and the
  ; DESC: Pointer to itself (for integrity check)
  ; VAR(ObjType) : Object BaseType
  ; RET.i : *This : Pointer to the new Object or 0
  ; ============================================================================
    
    Protected *This.TVObjBase
    Protected xFlat
    
    Select ObjType     
        
      ; ------------------------------------------------------------
      ; Flat Objects in 2D/3D Space
      ; ------------------------------------------------------------
      Case #VObj_Text
        *This = AllocateStructure(TText)
        xFlat = #True
        
      Case #VObj_Line
        *This = AllocateStructure(TLine)
       xFlat = #True
        
      Case #VObj_Polygon
        *This = AllocateStructure(TPolygon)
        xFlat = #True
       
      Case #VObj_Spline
        *This = AllocateStructure(TSpline)
        xFlat = #True
       
      Case #VObj_Ellipse
        *This = AllocateStructure(TEllipse)
        xFlat = #True
        
      ; ------------------------------------------------------------
      ; Volume Objects in 3D Space
      ; ------------------------------------------------------------      
      Case  #VObj_3DText   
        *This = AllocateStructure(T3DText)
        
      Case #VObj_3DPoly
        *This = AllocateStructure(T3DPoly)

      Case #VObj_3DCone
        *This = AllocateStructure(T3DCone)

    EndSelect
    
    If *This                    ; If the memory is allocated
      *This\This = *This        ; Set the Pointer on itself (it's for interity check)
      *This\ObjType = ObjType   ; Set the ObjectType
      If xFlat
        *This\ObjFlags = #VObj_Flag_Flat  
      EndIf      
    EndIf
    
    ProcedureReturn *This
  EndProcedure
  
  Procedure.i Kill(*VObj.TVObjBase)
  ; ============================================================================
  ; NAME: Kill
  ; DESC: Kill the Obkect, release the memory
  ; VAR(*VObj.TVObjBase) : Pointer to the VectorObject As TVObjBase
  ; RET.i : *VObj if killed or 0 if not killed
  ; ============================================================================
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception

    If *VObj = *VObj\This     ; If it's a TVObj, it has a Pointer on itself
      ; Integrity check passed! It's a valid TVObj Structure
      FreeStructure(*VObj)    ; release the allocated memory
      ProcedureReturn *VObj   ; return the original Pointer
    EndIf
     
    MessageRequester("Module Object3D", "Object is not a valid Obj3fD, can't kill it", #PB_MessageRequester_Error)
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i Clone(*VObj.TVObjBase)
  ; ============================================================================
  ; NAME: Clone
  ; DESC: Clone an Object: allocate memory and copy the datas from SourceObject
  ; VAR(*VObj.TVObjBase) : Pointer to the source VectorObject As TVObjBase 
  ; RET.i : *ThisNew: Pointer to the new created Objected or 0 (if failed)
  ; ============================================================================
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    Protected *ThisNew.TVObjBase
    
    If *VObj= *VObj\This
      
      *ThisNew = New(*VObj\ObjType)
      If *ThisNew
        
        Select *VObj\ObjType             
          ; ------------------------------------------------------------
          ; Flat Objects in 2D/3D Space
          ; ------------------------------------------------------------
          Case #VObj_Text
            CopyStructure(*VObj, *ThisNew, TText)
            
          Case #VObj_Line
            CopyStructure(*VObj, *ThisNew, TText)
            
          Case #VObj_Polygon
            CopyStructure(*VObj, *ThisNew, TPolygon)
            
          Case #VObj_Spline
            CopyStructure(*VObj, *ThisNew, TSpline)
           
          Case #VObj_Ellipse
             CopyStructure(*VObj, *ThisNew, TEllipse)
            
          ; ------------------------------------------------------------
          ; Volume Objects in 3D Space
          ; ------------------------------------------------------------      
          Case  #VObj_3DText   
            CopyStructure(*VObj, *ThisNew, T3DText)
            
          Case #VObj_3DPoly
            CopyStructure(*VObj, *ThisNew, T3DPoly)
    
          Case #VObj_3DCone
            CopyStructure(*VObj, *ThisNew, T3DCone)
            
        EndSelect
        
        *ThisNew\This = *ThisNew  ; correct Pointer on itself
        
      EndIf     
    EndIf     
     
    ProcedureReturn *ThisNew
  EndProcedure
  
  Procedure.i MoveFlatObj(*VObj.TVObjBase2D, X.d, Y.d, Z.d=0, MoveType= #PB_Absolute) 
  ; ============================================================================
  ; NAME: MoveFlatObj
  ; DESC: Move a flat VectorObject absolut or relativ
  ; VAR(*VObj.TVObjBase) : Pointer to the source VectorObject As TVObjBase 
  ; VAR(X.d) : X-Coordinate
  ; VAR(Y.d) : Y-Coordinate
  ; VAR(Z.d) : Z-Coordinate
  ; VAR(MoveType): #PB_Absolute or #PB_Relative
  ; RET.i : *VObj 
  ; ============================================================================
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    Protected.i I, N
    Protected Vmove.TVector
    
    If *VObj\ObjFlags & #VObj_Flag_Flat
      
      N = ArraySize(*VObj\PT())
      mac_SetVector(Vmove, X, Y, Z) ; from VECd::
     
      If MoveType = #PB_Absolute
        ; Move the Origin of the Object to the absolut Position
        ; => Move the Points of the Object relative to (Origin-Vmove) 
        
        ; VECd::Vector_SUB(*OUT.TVector, *IN1.TVector, *IN2.TVector); OUT=IN1-IN2
        ; Vmove = Origin - Vmove
        Vector_SUB(Vmove, *VObj\PT(0), Vmove)   ; PT(0) is the Origin
      EndIf
              
      For I = 0 To N  ; step trough all Points
        ; VECd::Vector_Add(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
        Vector_Add(*VObj\PT(I), *VObj\PT(I), Vmove)       
      Next
      
    Else
      ; It's not a Flat Object. It's a volume Object
    EndIf
    
    ProcedureReturn *VObj
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Create 2D flat Objects
  ;- ----------------------------------------------------------------------
  
  Procedure.i Create_Line(*VObj.TLine, W.d, H.d)
  ; ============================================================================
  ; NAME: Create_Line
  ; DESC: Create a 2D Line definition in a TLine Structure
  ; VAR(*VObj.TLine) : Pointer to the Line Object
  ; VAR( W.d) :  Width
  ; VAR( H.d) : Height  
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    ; ACHTUNG!!! Ändern PT(0) wird immer der Refernz-Punkt (Drehpunkt/Ursprung)
    ; Jedes Objekt hat also einen Punkt mehr. Der derste Objekt-Punkt ist immer PT(1)
    
    With *VObj
      \NoOfPts = 2      
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf     
      \NoOfPts    = 2
      \ObjType    = #VObj_Line 
      \ObjSubType = #VObj_Line_Line
    EndWith
    
    With *VObj\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *VObj\PT(2)
      \x = W
      \y = H
      \z = 0 
    EndWith
    
    *VObj\PT(0) = *VObj\PT(1) ; Set Reference Point PT(0)
    
    ProcedureReturn *VObj
  EndProcedure
  
  Procedure.i Create_PolyLine(*VObj.TLine, W.d, H.d)
  ; ============================================================================
  ; NAME: Create_PolyLine
  ; DESC: Create a 2D PolyLine definition in a TLine Structure
  ; VAR(*VObj.TLine) : Pointer to the Line Object
  ; VAR( W.d) : Width
  ; VAR( H.d) : Height  
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \NoOfPts = 5      
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf     
      \NoOfPts    = 2
      \ObjType    = #VObj_Line 
      \ObjSubType = #VObj_Line_PolyLine
    EndWith
    
    With *VObj\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *VObj\PT(2)
      \x = W
      \y = H
      \z = 0 
    EndWith
    
    *VObj\PT(0) = *VObj\PT(1) ; Set Reference Point PT(0)
   
    ProcedureReturn *VObj
  EndProcedure
  
  Procedure.i Create_Triangle(*VObj.TPolygon, X2.d,Y2.d, X3.d,Y3.d)
  ; ============================================================================
  ; NAME: Create_Triangle
  ; DESC: Create a 2D Triangle definition in a TPolygon Structure
  ; VAR(*VObj.TPolygon) : Pointer to the Polygon Object
  ; VAR(X2.d): X of 2nd Point
  ; VAR(Y2.d): Y of 2nd Point
  ; VAR(X3.d): X of 3nd Point
  ; VAR(Y3.d): Y of 3nd Point
  ; RET.i : *VObj
  ; ============================================================================
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \NoOfPts = 3     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #VObj_Polygon  
      \ObjSubType = #VObj_Polygon_Triangle
    EndWith
   
    With *VObj\PT(1)
      \x = 0
      \y = 0
      \z = 0       
    EndWith
    
    With *VObj\PT(2)
      \x = X2
      \y = Y2
      \z = 0        
    EndWith
    
    With *VObj\PT(3)
      \x = X3
      \y = Y3
      \z = 0        
    EndWith
    
    *VObj\PT(0) = *VObj\PT(1) ; Set Reference Point PT(0)
   
    ProcedureReturn *VObj  
  EndProcedure
  
  Procedure.i Create_Rectangle(*VObj.TPolygon, W.d, H.d)
  ; ============================================================================
  ; NAME: Create_Rectangle
  ; DESC: Create a 2D Rectangle definition in a TPolygon Structure
  ; VAR(*VObj.TPolygon) : Pointer to the Polygon Object
  ; VAR( W.d)  : Width
  ; VAR( H.d) : Height  
  ; RET.i : *VObj
  ; ============================================================================
       
  ;   P2--------------P3
  ;   |               | 
  ;   |               |
  ;   |               |
  ;   P1--------------P4
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \NoOfPts = 4     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #VObj_Polygon  
      \ObjSubType = #VObj_Polygon_Rectangle
    EndWith
    
    With *VObj\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *VObj\PT(2)
      \X = 0
      \Y = H
      \Z = 0
    EndWith
    
    With *VObj\PT(3)
      \X = W
      \Y = H
      \Z = 0
    EndWith
    
    With *VObj\PT(4)
      \X = W
      \Y = 0
      \Z = 0
    EndWith
    
    *VObj\PT(0) = *VObj\PT(1) ; Set Reference Point PT(0)
    
    ProcedureReturn *VObj
  EndProcedure

  Procedure.i Create_Pentagon(*VObj.TPolygon, r.d)
  ; ============================================================================
  ; NAME: Create_Pentagon
  ; DESC: Create a 2D Pentagon definition in a TPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.TPolygon) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *VObj
  ; ============================================================================
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \NoOfPts = 5     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #VObj_Polygon  
      \ObjSubType = #VObj_Polygon_Pentagon
    EndWith
    
    With *VObj\PT(1)
      \x= r
      \y= 0
      \z =0
    EndWith
    
    With *VObj\PT(3)
      \x= r * Cos(Radian(72))
      \y= r * Sin(Radian(72))
      \z =0
    EndWith
    
    With *VObj\PT(3)
      \x= r * Cos(Radian(72*2))
      \y= r * Sin(Radian(72*2))
      \z =0
    EndWith

    With *VObj\PT(4)
      \x= r * Cos(Radian(72*3))
      \y= r * Sin(Radian(72*3))
      \z =0
    EndWith
    
    With *VObj\PT(5)
      \x= r * Cos(Radian(72*4))
      \y= r * Sin(Radian(72*4))
      \z =0
    EndWith
    
    ; Set Reference Point PT(0) = Center Point
    With *VObj\PT(0)
      \x= 0
      \y= 0
      \z =0
    EndWith
    
    ProcedureReturn *VObj  
  EndProcedure
  
  Procedure.i Create_Hexagon(*VObj.TPolygon, r.d)
  ; ============================================================================
  ; NAME: Create_Hexagon
  ; DESC: Create a 2D Hexagon definition in a TPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.TPolygon) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *VObj
  ; ============================================================================
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \NoOfPts = 6     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #VObj_Polygon  
      \ObjSubType = #VObj_Polygon_Hexagon
    EndWith
    
    With *VObj\PT(1)
      \x= r
      \y= 0
      \z =0
    EndWith
    
    With *VObj\PT(2)
      \x= r * Cos(Radian(60))
      \y= r * Sin(Radian(60))
      \z =0
    EndWith
    
    With *VObj\PT(3)
      \x= r * Cos(Radian(60*2))
      \y= r * Sin(Radian(60*2))
      \z =0
    EndWith

    With *VObj\PT(4)
      \x= r * Cos(Radian(60*3))
      \y= r * Sin(Radian(60*3))
      \z =0
    EndWith
    
    With *VObj\PT(5)
      \x= r * Cos(Radian(60*4))
      \y= r * Sin(Radian(60*4))
      \z =0
    EndWith
    
    With *VObj\PT(6)
      \x= r * Cos(Radian(60*5))
      \y= r * Sin(Radian(60*5))
      \z =0
    EndWith

    ; Set Reference Point PT(0) = Center Point
    With *VObj\PT(0)
      \x= 0
      \y= 0
      \z =0
    EndWith
    
    ProcedureReturn *VObj  
  EndProcedure
  
  Procedure.i Create_Octagon(*VObj.TPolygon, r.d)
  ; ============================================================================
  ; NAME: Create_Octagon
  ; DESC: Create a 2D Octagon definition in a TPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.TPolygon) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \NoOfPts = 8     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #VObj_Polygon  
      \ObjSubType = #VObj_Polygon_Octagon
    EndWith
    
    With *VObj\PT(1)
      \x= r
      \y= 0
      \z =0
    EndWith
    
    With *VObj\PT(2)
      \x= r * Cos(Radian(45))
      \y= r * Sin(Radian(45))
      \z =0
    EndWith
    
    With *VObj\PT(3)
      \x= r * Cos(Radian(45*2))
      \y= r * Sin(Radian(45*2))
      \z =0
    EndWith

    With *VObj\PT(4)
      \x= r * Cos(Radian(45*3))
      \y= r * Sin(Radian(45*3))
      \z =0
    EndWith
    
    With *VObj\PT(5)
      \x= r * Cos(Radian(45*4))
      \y= r * Sin(Radian(45*4))
      \z =0
    EndWith
    
    With *VObj\PT(6)
      \x= r * Cos(Radian(45*5))
      \y= r * Sin(Radian(45*5))
      \z =0
    EndWith
    
    With *VObj\PT(7)
      \x= r * Cos(Radian(45*6))
      \y= r * Sin(Radian(45*6))
      \z =0
    EndWith
    
    With *VObj\PT(8)
      \x= r * Cos(Radian(45*7))
      \y= r * Sin(Radian(45*7))
      \z =0
    EndWith

    ; Set Reference Point PT(0) = Center Point
    With *VObj\PT(0)
      \x= 0
      \y= 0
      \z =0
    EndWith
    
    ProcedureReturn *VObj  
  EndProcedure
  
  Procedure.i Create_Star(*VObj.TPolygon, outerRadius.d, innerRadius.d,  NoOfSpikes, StartAngle=0)
  ; ============================================================================
  ; NAME: Create_Star
  ; DESC: Create a 2D Start in a TPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.TPolygon) : Pointer to the Polygon Object
  ; VAR(outerRadius.d): Radius of the outer circle
  ; VAR(outerRadius.d): Radius of the inner circle
  ; VAR(NoOfSpikes) : Number of the Stars Spikes (2 Points needed per spike)
  ; VAR(StartAngle) : Angle of the first Spike [0..360°] (because +y goes down 0° is down!
  ; RET.i : *VObj
  ; ============================================================================
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    If NoOfSpikes > 0 And NoOfSpikes <= 36 ; 
      With *VObj
        \NoOfPts = NoOfSpikes * 2     
        If ArraySize(\PT()) <> \NoOfPts
          ReDim \PT(\NoOfPts)
        EndIf      
        \ObjType    = #VObj_Polygon  
        \ObjSubType = #VObj_Polygon_Star
           
        Protected I.i            
        Protected Phi.d = Radian(StartAngle) ; on a X/Y Screen the Angle 0 is down because +Y goes down
        Protected dPhi.d = #PI / NoOfSpikes
      
        ; we start at Point 1 because Point 0 is the reference/center Point
        ; the first Point is the Point on the outer Radius, the second on the inner Radius
        For I = 2 To \NoOfPts Step 2
          ; Calculate outer point
          \PT(I-1)\x = Sin(Phi) * outerRadius
          \PT(I-1)\y = Cos(Phi) * outerRadius
          Phi = Phi + dPhi
          
          ; Calculate inner point
          \PT(I)\x = Sin(Phi) * outerRadius
          \PT(I)\y = Cos(Phi) * outerRadius
          Phi = Phi + dPhi
        Next i
      EndWith    
    EndIf
  
    ProcedureReturn *VObj
  EndProcedure

  Procedure.i Create_PolygonCircel(*VObj.TPolygon, r.d, NoOfPoints.i)
  ; ============================================================================
  ; NAME: Create_PolygonCircel
  ; DESC: Create a Circle as Polygon definition in a TPolygon Structure
  ; VAR(*VObj.TPolygon) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; VAR(NoOfPoints.d): No of Points to create
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    If NoOfPoints > 0 And NoOfPoints <= (360*60) ; maximum value for a resulution in AngularMinutes 
      
      With *VObj
        \NoOfPts = NoOfPoints     
        If ArraySize(\PT()) <> \NoOfPts
          ReDim \PT(\NoOfPts)
        EndIf      
        \ObjType    = #VObj_Polygon  
        \ObjSubType = #VObj_Polygon_Polygon
      EndWith
            
      Protected dAngle.d = (#PI * 2) / NoOfPoints
      Protected I
      
      With *VObj\PT(1)
        \x= r
        \y= 0
        \z =0
      EndWith
      
      For I = 2 To NoOfPoints       
        With *VObj\PT(I)
          \x= r * Cos(dAngle)
          \y= r * Sin(dAngle)
          \z =0
        EndWith
        dAngle + dAngle  
      Next
      
      ; Set Reference Point PT(0) = Center Point
      With *VObj\PT(0)
        \x= 0
        \y= 0
        \z =0
      EndWith
    EndIf
    
    ProcedureReturn *VObj  
  EndProcedure
  
  Procedure.i Create_PolygonFromList(*VObj.TPolygon, List Pts.TVector())
  ; ============================================================================
  ; NAME: Create_PolygonFromList
  ; DESC: Create a Polygon definition in a TPolygon Structure
  ; DESC: based on a List of Points As TVector
  ; VAR(*VObj.TPolygon) : Pointer to the Polygon Object
  ; VAR(Pts.TVector()): List of Points as TVector
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer2(*VObj, Pts())    ; Check Pointer Exception
    
    Protected lstSize = ListSize(Pts())
    
    If lstSize > 1
      
      With *VObj
        \NoOfPts = lstSize     
        If ArraySize(\PT()) <> \NoOfPts
          ReDim \PT(\NoOfPts)
        EndIf      
        \ObjType    = #VObj_Polygon  
        \ObjSubType = #VObj_Polygon_Polygon
      EndWith
            
      Protected I      
      ResetList(Pts())      
      ForEach Pts()
        I+1 
        *VObj\PT(I) = Pts()
      Next
      
      ; Set Reference Point PT(0) = Center Point
      With *VObj\PT(0)
        \x= 0
        \y= 0
        \z =0
      EndWith
      
    EndIf
    
    ProcedureReturn *VObj  
  EndProcedure

  
  Procedure.i Create_Circle(*VObj.TEllipse, r.d)
  ; ============================================================================
  ; NAME: Create_Circle
  ; DESC: Create a Circle definition in a TEllipse Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.TEllipse) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \NoOfPts = 1     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #VObj_Ellipse  
      \ObjSubType = #VObj_Ellipse_Circle
    EndWith

    With *VObj\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *VObj\Rx
      \x = r
      \y = 0
      \z = 0
    EndWith
    
    With *VObj\Ry
      \x = 0
      \y = r
      \z = 0
    EndWith
    
    *VObj\PT(0) = *VObj\PT(1) ; Set Reference Point PT(0)

    ProcedureReturn *VObj
  EndProcedure
  
  Procedure.i Create_Ellipse(*VObj.TEllipse, rx.d, ry.d)
  ; ============================================================================
  ; NAME: Create_Ellipse
  ; DESC: Create an Ellipse definition in a TEllipse Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.TEllipse) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \NoOfPts = 1     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #VObj_Ellipse  
      \ObjSubType = #VObj_Ellipse_Ellipse
    EndWith
    
    With *VObj\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *VObj\Rx
      \x = rx
      \y = 0
      \z = 0
    EndWith
    
    With *VObj\Ry
      \x = 0
      \y = ry
      \z = 0
    EndWith
    
    *VObj\PT(0) = *VObj\PT(1) ; Set Reference Point PT(0)

    ProcedureReturn *VObj
  EndProcedure
  
 
  ;- ----------------------------------------------------------------------
  ;- Create 3D volume Objects
  ;- ----------------------------------------------------------------------

 
  Procedure.i Create3D_Triangle(*VObj.T3DPoly, X2.d,Y2.d, X3.d,Y3.d, depth.d)
  ; ============================================================================
  ; NAME: Create3D_Triangle
  ; DESC: Create a 3D Triangle definition in a 3DPoly Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.T3DPoly) : Pointer to the 3DPolygon Object
  ; VAR(X2.d): X of 2nd Point
  ; VAR(Y2.d): Y of 2nd Point
  ; VAR(X3.d): X of 3nd Point
  ; VAR(Y3.d): Y of 3nd Point
  ; RET.i : *VObj
  ; ============================================================================
   
  ;         .P5  
  ;      .  |    .         
  ;    P2   |        .
  ;    |   .|            .
  ;    |   .P4-----------.P6
  ;    | .           .
  ;    P1--------------P3
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
 
    With *VObj
      \ObjType    = #VObj_3DPoly 
      \ObjSubType = #VObj_3DPoly_Triangle

      Create_Triangle(\POL[0], X2.d,Y2.d, X3.d,Y3.d) 
      \POL[1] = \POL[0]   ; Polygon(1) = Polygon(0)
    EndWith
  
    With *VObj\POL[1]  ; set the depth (z-coordinates of Poligon(1))
      \PT(1)\z = depth  
      \PT(2)\z = depth  
      \PT(3)\z = depth  
    EndWith
    
    ProcedureReturn *VObj
  EndProcedure

  Procedure.i Create3D_Box(*VObj.T3DPoly, W.d, H.d, D.d)
  ; ============================================================================
  ; NAME: Create3D_Box
  ; DESC: Create a 3D Box definition in a T3DPoly Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.T3DPoly) : Pointer to the 3DPoly Object
  ; VAR(W.d): Width  (length in x-direction)
  ; VAR(H.d): Height (length in y-direction)    
  ; VAR(D.d): Depth  (length in z-direction)
  ; RET.i : *VObj
  ; ============================================================================
   
  ;         .P6------------.P7  
  ;      .  |            . |
  ;    P2--------------P3  |
  ;    |    |          |   |
  ;    |   .P5---------|--.P8
  ;    | .             |.
  ;    P1--------------P4
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
 
    With *VObj
      \ObjType    = #VObj_3DPoly 
      \ObjSubType = #VObj_3DPoly_Rectangle

      Create_Rectangle(\POL[0], W, H) 
      \POL[1] = \POL[0]
    EndWith
  
    With *VObj\POL[1]
      \PT(1)\z = D  
      \PT(2)\z = D  
      \PT(3)\z = D  
      \PT(4)\z = D     
    EndWith
       
    ProcedureReturn *VObj
  EndProcedure
  
  Procedure.i Create3D_Cylinder(*VObj.T3DCone, r.d, h.d)
  ; ============================================================================
  ; NAME: Create_T3DCylinder
  ; DESC: Create a 3D Cylinder definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.T3DCone) : Pointer to the Cone Object
  ; VAR(r.d): Radius
  ; VAR(h.d): Height  (lenth in z-direction)
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      \ObjType    = #VObj_3DCone 
      \ObjSubType = #VObj_3DCone_Cylinder
      
      Create_Circle(*VObj\EL[0], r)
      \EL[1] = \EL[0]
    EndWith
        
    With *VObj\EL[1]\PT(1)
      \x = 0
      \y = 0
      \z = h
    EndWith

    ProcedureReturn *VObj
  EndProcedure
  
  Procedure.i Create3D_Cone(*VObj.T3DCone, r1.d, r2.d, h.d)
  ; ============================================================================
  ; NAME: Create_TCone
  ; DESC: Create a 3D Cone definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.T3DCone) : Pointer to the Cone Object
  ; VAR(r1.d): Radius 1
  ; VAR(r2.d): Radius 2
  ; VAR(h.d):  Height  (lenth in z-direction)
  ; RET.i : *VObj
  ; ============================================================================
      
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    Create_Ellipse(*VObj\EL[0], r1, r1)  
    *VObj\EL[1] = *VObj\EL[0]
    
    With *VObj\EL[1]
      
      \PT(1)\z = h
      \Rx\x = r2
      \Ry\y = r2
    EndWith
    
    ProcedureReturn *VObj
  EndProcedure
  
  Procedure.i Create3D_Pentagon(*VObj.T3DPoly, r.d, h.d)
  ; ============================================================================
  ; NAME: Create3D_Pentagon
  ; DESC: Create a 3D Pentagon definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.T3DPoly) : Pointer to the Cone Object
  ; VAR(r.d): Radius 
  ; VAR(h.d): Height
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      Create_Pentagon(\POL[0], r) 
      \POL[1] = \POL[0]  
    EndWith 
    
    With *VObj\POL[1]
     \PT(0)\z = h 
     \PT(1)\z = h 
     \PT(2)\z = h 
     \PT(3)\z = h 
     \PT(4)\z = h    
    EndWith
    
    ProcedureReturn *VObj  
  EndProcedure
  
  Procedure.i Create3D_Hexagon(*VObj.T3DPoly, r.d, h.d)
  ; ============================================================================
  ; NAME: Create3D_Hexagon
  ; DESC: Create a 3D Hexagon definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.T3DPoly) : Pointer to the 3DPoly Object
  ; VAR(r.d): Radius 
  ; VAR(h.d): Height
  ; RET.i : *VObj
  ; ============================================================================
   
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception
    
    With *VObj
      Create_Hexagon(\POL[0], r) 
      \POL[1] = \POL[0]  
    EndWith 
    
    With *VObj\POL[1]
     \PT(0)\z = h 
     \PT(1)\z = h 
     \PT(2)\z = h 
     \PT(3)\z = h 
     \PT(4)\z = h 
     \PT(5)\z = h    
    EndWith
    
    ProcedureReturn *VObj  
  EndProcedure
  
  Procedure.i Create3D_Octagon(*VObj.T3DPoly, r.d, h.d)
  ; ============================================================================
  ; NAME: Create3D_Octagon
  ; DESC: Create a 3D Octagon definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*VObj.T3DPoly) : Pointer to the 3DPoly Object
  ; VAR(r.d): Radius 
  ; VAR(h.d): Height
  ; RET.i : *VObj
  ; ============================================================================
    
    DBG::mac_CheckPointer(*VObj)    ; Check Pointer Exception

    With *VObj
      Create_Octagon(\POL[0], r) 
      \POL[1] = \POL[0]  
    EndWith 
    
    With *VObj\POL[1]
     \PT(0)\z = h 
     \PT(1)\z = h 
     \PT(2)\z = h 
     \PT(3)\z = h 
     \PT(4)\z = h 
     \PT(5)\z = h    
     \PT(6)\z = h 
     \PT(7)\z = h    
    EndWith
    
    ProcedureReturn *VObj  
  EndProcedure
    
  ;- ----------------------------------------------------------------------
  ;- VObjects to Facets
  ;- ----------------------------------------------------------------------
  
  Procedure _CalcFacetNormal(*Facet.TFacet)
    Protected v1.TVector
    Protected v2.TVector
    
    ; Calculate the normal Vector N (counterclockwise Point order)
    ; (if we change to clockwise Point order the direction of the normal Vector change)
    Vector_SUB(v1, *Facet\V2, *Facet\V1)
    Vector_SUB(v2, *Facet\V3, *Facet\V1)
    Vector_CrossProduct(*Facet\N, v1, v2)
    Vector_Normalize(*Facet\N)
  EndProcedure
  
  Procedure _PointsToFacet(*Facet.TFacet, *P1.TVector, *P2.TVector, *P3.TVector)
    Vector_Copy(*Facet\V1, *P1)
    Vector_Copy(*Facet\V2, *P2)
    Vector_Copy(*Facet\V3, *P3)
    _CalcFacetNormal(*Facet)
  EndProcedure
  
  Procedure _RectToFacet(*Facet1.TFacet, *Facet2.TFacet, *P1.TVector, *P2.TVector, *P3.TVector, *P4.TVector)
    
  ;   P2--------------P3
  ;   |               | 
  ;   |               |
  ;   |               |
  ;   P1--------------P4
          
    ; Facet 1 : P1, P2, P3
    Vector_Copy(*Facet1\V1, *P1)
    Vector_Copy(*Facet1\V2, *P2)
    Vector_Copy(*Facet1\V3, *P3)
    _CalcFacetNormal(*Facet1)
    
    ; Facet 2 : P1, P3, P4
    Vector_Copy(*Facet2\V1, *P1)
    Vector_Copy(*Facet2\V2, *P3)
    Vector_Copy(*Facet2\V3, *P4)
    _CalcFacetNormal(*Facet2)
 
  EndProcedure
  
  Procedure _PoligonToFacet(Array Facets.TFacet(1), *Poly.TPolygon)
    
    Protected I    
    Protected nFacets = *Poly\NoOfPts - 2  ; Number of facets for a polygon with nPoints vertices
    
    Dim Facets(nFacets -1)
    
    ; Create Facets: One facet from StartPoint with 2 other Points
    ; Facet(1) = P1,P2,P3 : Facet(2) = P1,P3,P4 : Facet(3) = P1,P4,P5 ... P1, P(n-1), Pn
    ; an alternative way would be to calculate the Facets from the CenterPoint - but that is work
    For I = 0 To nFacets - 1
      With *Poly
        _PointsToFacet(Facets(I), \PT(1), \PT(I+2), \PT(I+3) )  
      EndWith  
    Next
    ProcedureReturn nFacets
  EndProcedure
  
  Procedure _CenterOf_RegularPolygon(*Out.TVector, *Poly.TPolygon)
    ; triangles, Rectangles, Pentagon, Hexagon ... polygoned Circels
    ; the CenterPoint is just the average of all coordinates
    Protected I
    Protected.d cx, cy, cz, f
    
    With *Poly
      For I = 1 To \NoOfPts
        Cx + \PT(I)\x
        Cy + \PT(I)\y
        Cz + \PT(I)\z
      Next
      f = 1 / \NoOfPts
     EndWith
    
    With *Out
      \x = cx * f
      \y = cy * f
      \z = cz * f
    EndWith
  
    ProcedureReturn *Out
  EndProcedure
  
  Procedure _CenterOf_FreePolygon(Array Poly.TPoint2D(1), numPoints)
    ; we can calucalte only in X/Y Plane when Z=0 otherwise 
    Protected I, J
    Protected.d Area, cx, cy, cz, temp, f
    
    ; alogrithm by ChatCPT 4
    For I = 1 To numPoints -1 
      J = I+1
      temp = Poly(I)\X * Poly(J)\Y - Poly(J)\X * Poly(I)\Y
      Area + temp
      Cx + (Poly(I)\X + Poly(J)\X) * temp
      Cy + (Poly(I)\Y + Poly(J)\Y) * temp
    Next
    
    ; the connection between last an first point (a closed Polygon)
    I = numPoints : J= 1
    temp = Poly(I)\X * Poly(J)\Y - Poly(J)\X * Poly(I)\Y
    Area + temp
    Cx + (Poly(I)\X + Poly(J)\X) * temp
    Cy + (Poly(I)\Y + Poly(J)\Y) * temp
  
    ; Area / 2
    ; Cx / (6.0 * Area)
    ; Cy / (6.0 * Area)
    
    f = 1/(Area * 3)
    cx * f
    cy * f
    
  EndProcedure
  
  Procedure _CalculateCentroid3D(Array Poly.TVector(1), numPoints)
    Protected I, J
    Protected Area.d = 0.0
    Protected Cx.d = 0.0
    Protected Cy.d = 0.0
    Protected Cz.d = 0.0
    Protected temp.d
    ; alogrithm by ChatCPT 4
    For I = 1 To numPoints
      J = (I + 1) % numPoints  ; Next vertex index, with wrap-around
      
      ; Compute the cross product of the edges
      temp = (Poly(I)\x * Poly(J)\y - Poly(J)\x * Poly(I)\y) + (Poly(I)\y * Poly(J)\z - Poly(J)\y * Poly(I)\z) + (Poly(I)\z * Poly(J)\x - Poly(J)\z * Poly(I)\x)
      Area + temp
      Cx + (Poly(I)\x + Poly(J)\x) * temp
      Cy + (Poly(I)\y + Poly(I)\y) * temp
      Cz + (Poly(I)\z + Poly(I)\z) * temp
    Next
    
    Area *0.5
    
    Cx / (6.0 * Area)
    Cy / (6.0 * Area)
    Cz / (6.0 * Area)
  
  EndProcedure

  
  Procedure Facets3D_Poligon(Array Facets.TFacet(1), *VObj.T3DPoly)
  ; ============================================================================
  ; NAME: Facets3D_Poligon
  ; DESC: Creates the Facets of a 3D Poligon Structure
  ; DESC: 
  ; VAR(Array Facets(1).TFacet) : Array to receive the 12 Facets [0..11]
  ; VAR(*VObj.T3DPoly) : Pointer to the 3DPoly Object
  ; RET.i : No of Facets total
  ; ============================================================================
    Protected I, nFacets, nFPoly, sides, idx
     
    ; Step 1 count the Number of Facets
    ; a 2D Poligion needs (NoOfPoints-2) Facets, we have 2 Poligons
    ; and for each side 2 more facets. 
    ; A Plogion with n Points has n sides 2
    
    With *VObj 
      sides = \POL[0]\NoOfPts           ; no of sides of the 3D polygon based Cylinder
      nFPoly = sides - 2                ; NoOfFacets for a Polygon
      nFacets = nFPoly * 2 + sides * 2  ; NoOfFacets total (the 2 Polygons + the sides)
    EndWith
    
    Dim Facets(nFacets-1)     ; Array for all Facets
    
    ; ----------------------------------------------------------------------
    ;   Step 1: Process Facets of the 2 Polygons
    ; ----------------------------------------------------------------------
    idx = nFacets -nFPoly -1    ; Index at End of FacetArray for 2nd Polygon
    
    For I = 0 To (nFPoly - 1)
      ; Facets of Poygon[0] - we put at beginning of the Facet-Array
      With *VObj\POL[0]
        ; Attention coordinates start at Point(1) : Point(0) is ReferencePoint
        _PointsToFacet(Facets(I), \PT(1), \PT(I+2), \PT(I+3) )   
      EndWith  
      
      ; Facets of Poygon[1] - we put at end of the Facet-Array
      With *VObj\POL[1]
        ; Attention coordinates start at Point(1) : Point(0) is ReferencePoint
        _PointsToFacet(Facets(I+idx), \PT(1), \PT(I+2), \PT(I+3) )  
      EndWith  
    Next
    
    ; ----------------------------------------------------------------------
    ;   Step 2: Process Facets of the Cylinder sides
    ; ----------------------------------------------------------------------     
    idx = nFPoly ; Set Index after Facets of 1st Polygon to add Facets of the sides
        
    For I = 1 To (sides -1)  ; [1..(NoOfPoints-1)]
      With *VObj
        ; Attention coordinates start at Point(1) : Point(0) is ReferencePoint
        _RectToFacet(Facets(idx), Facets(idx+1), \POL[0]\PT(I), \POL[1]\PT(I), \POL[0]\PT(I+1), \POL[1]\PT(I+1)) 
        idx + 1
      EndWith
    Next
    
    ProcedureReturn nFacets   ; Total number of facets
  EndProcedure
  
    
EndModule
; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 53
; FirstLine = 50
; Folding = ------
; Optimizer
; CPU = 5