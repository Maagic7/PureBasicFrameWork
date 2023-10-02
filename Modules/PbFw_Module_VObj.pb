; ===========================================================================
; FILE : PbFw_Module_VObj.pb
; NAME : PureBasic Framework : Module VectorObjects  [VObj::]
; DESC : 2D/3D Object definition and handling for Objects with 
; DESC : double precicion vector coordinates
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/15
; VERSION  :  0.1  Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;  2023/09/01 S.Maag : changed Name form Obj3D to VObj (VectorObjects)
;     because this describes better what it is and we do not have Obj3D
;     prefixes for 2D Objects.                
;     Added some code!
;  
;   2023/08/22 S.Maag : fixed syntax Errors!
;}
;{ TODO:
;}
; ===========================================================================

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
    
    #PbFw_VObj_unknown     
    ; ------------------------------------------------------------
    ;- Flat Objects in 2D/3D Space
    ; ------------------------------------------------------------
    #PbFw_VObj_Text
    #PbFw_VObj_Line     
    #PbFw_VObj_Polygon    
    #PbFw_VObj_Ellipse      
    #PbFw_VObj_Plane            ; Plane ;[Ebene]      
    #PbFw_VObj_Arc
    #PbFw_VObj_Spline                    
   
    ; ------------------------------------------------------------
    ;- Volume Objects in 3D Space
    ; ------------------------------------------------------------    
    #PbFw_VObj_3DText          ; Volume Text   
    #PbFw_VObj_3DPoly          ; Volume Polygon    
    #PbFw_VObj_3DCone
          
  EndEnumeration
  
  Enumeration EVObjSubType 1000       ; start with 1000, so ObjType and ObjSubType are at a different Numspace 
    ;#PbFw_VObj_Text
    #PbFw_VObj_Text_TextSingle          ; Single Line Text    
    #PbFw_VObj_Text_TextMulti           ; Single Line Text    
    
    ;#PbFw_VObj_Line     
    #PbFw_VObj_Line_Line                ; Line     
    #PbFw_VObj_Line_PolyLine            ; PolyLine 
    
    ;#PbFw_VObj_Polygon    
    #PbFw_VObj_Polygon_Triangle         ; 3 Edges 
    #PbFw_VObj_Polygon_Rectangle        ; 4 Edges, regualr Rectangel
    #PbFw_VObj_Polygon_Pentagon         ; 5 Edges, regular Pentagon
    #PbFw_VObj_Polygon_Hexagon          ; 6 Edges, regular Hexagon
    #PbFw_VObj_Polygon_Octagon          ; 8 Edges, regular Octagon
    #PbFw_VObj_Polygon_Polygon          ; any other Polygon
          
    ;#PbFw_VObj_Ellipse      
    #PbFw_VObj_Ellipse_Circle           ; Circle 
    #PbFw_VObj_Ellipse_Ellipse          ; Ellipse)   
    
    ;#PbFw_VObj_Plane            ; Plane ;[Ebene]      
    

    ;#PbFw_VObj_Arc
    #PbFw_VObj_Arc_Circular             ; Circular Arc
    #PbFw_VObj_Arc_Conic                ; Circular Arc
    
    ;#PbFw_VObj_Spline                    
    #PbFw_VObj_Spline_CatMullRom        ; Catmull Rom Spline
    #PbFw_VObj_Spline_CSpline           ; Cubic Spline
    #PbFw_VObj_Spline_BSpline           ; Bezier Spline
    #PbFw_VObj_Spline_TSpline           ; T-Spline

    ; ---------------------------------------------------------------------------------
    ;#PbFw_VObj_3DPoly                  ; Volume Polygon    
    #PbFw_VObj_3DPoly_Triangle          ; 3 Edges 
    #PbFw_VObj_3DPoly_Rectangle         ; 4 Edges, regualr Rectangel
    #PbFw_VObj_3DPoly_Pentagon          ; 5 Edges, regular Pentagon
    #PbFw_VObj_3DPoly_Hexagon           ; 6 Edges, regular Hexagon
    #PbFw_VObj_3DPoly_Octagon           ; 8 Edges, regular Octagon
    #PbFw_VObj_3DPoly_Polygon           ; any other Polygon
    
    ;#PbFw_VObj_3DCone
    #PbFw_VObj_3DCone_Cylinder          ; 3D Cylinder
    #PbFw_VObj_3DCone_EllipticCylinder  ; 3D elliptical Cylinder
    #PbFw_VObj_3DCone_Cone              ; 3D Cone  {Kegel}
    #PbFw_VObj_3DCone_EllipticCone      ; 3D elliptical Cone {elliptischer Kegel} 
    
 
  EndEnumeration
  
  EnumerationBinary EVObjFlags
    #PbFw_VObj_Flag_Hidden
    #PbFw_VObj_Flag_Locked 
    #PbFw_VObj_Flag_Flat 
  EndEnumeration
  
  Enumeration EVObj_FillStyle
    #PbFw_VObj_FillStyle_Transparent    ; Transparent = without filling
    #PbFw_VObj_FillStyle_Solid          ; with solid filling
    #PbFw_VObj_FillStyle_Pattern        ; Musterfüllung (z.B. gestreift)
    #PbFw_VObj_FillStyle_Image          ; Filled with an Image (.bmp, .png, .jpg)
  EndEnumeration

  Enumeration EVObj_LineStyle
    #PbFw_VObj_LineStyle_Solid          ; Solid Line   : StrokePath()
    #PbFw_VObj_LineStyle_Dash           ; ------ Line  : DashPath()
    #PbFw_VObj_LineStyle_Dot            ; ..... Line   : DotPath()
    #PbFw_VObj_LineStyle_DashDot        ; -.-.- Line   : CustomDashPath()
    #PbFw_VObj_LineStyle_DashDotDot     ; -..-..- Line : CustomDashPath()
  EndEnumeration
    
  ; ----------------------------------------------------------------------
  ; Basic defintions for Text
  ; ----------------------------------------------------------------------

  Enumeration ETextAlign
    #PbFw_VObj_TextAlign_UpLeft
    #PbFw_VObj_TextAlign_UpMiddle
    #PbFw_VObj_TextAlign_UpRight
    #PbFw_VObj_TextAlign_DownLeft
    #PbFw_VObj_TextAlign_DownMiddle
    #PbFw_VObj_TextAlign_DownRight 
  EndEnumeration

  #PbFw_VObj_Font_BOLD = #PB_Font_Bold
  #PbFw_VObj_Font_Italic = #PB_Font_Italic
  #PbFw_VObj_Font_StrikeOut = #PB_Font_StrikeOut
  #PbFw_VObj_Font_Underline = #PB_Font_Underline
    
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
    ObjType.l                 ; Object-Type     = #PbFw_VObj_Polygon
    ObjSubType.l              ; Object-SubType  = #PbFw_VObj_SubType_Triangle
    ObjFlags.l                ; Flags like #PbFw_VObj_Flag_Hidden
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
  
  ;- ----------------------------------------------------------------------
  ;- Declare Module
  ;- ----------------------------------------------------------------------
  Declare.i New(ObjType = #PbFw_VObj_Line)
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
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
 
  UseModule VECd
  
  ;  ----------------------------------------------------------------------
  ;-  Handling Functions 
  ;- ----------------------------------------------------------------------
  
  Procedure.i New(ObjType = #PbFw_VObj_Line)
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
      Case #PbFw_VObj_Text
        *This = AllocateStructure(TText)
        xFlat = #True
        
      Case #PbFw_VObj_Line
        *This = AllocateStructure(TLine)
       xFlat = #True
        
      Case #PbFw_VObj_Polygon
        *This = AllocateStructure(TPolygon)
        xFlat = #True
       
      Case #PbFw_VObj_Spline
        *This = AllocateStructure(TSpline)
        xFlat = #True
       
      Case #PbFw_VObj_Ellipse
        *This = AllocateStructure(TEllipse)
        xFlat = #True
        
      ; ------------------------------------------------------------
      ; Volume Objects in 3D Space
      ; ------------------------------------------------------------      
      Case  #PbFw_VObj_3DText   
        *This = AllocateStructure(T3DText)
        
      Case #PbFw_VObj_3DPoly
        *This = AllocateStructure(T3DPoly)

      Case #PbFw_VObj_3DCone
        *This = AllocateStructure(T3DCone)

    EndSelect
    
    If *This                    ; If the memory is allocated
      *This\This = *This        ; Set the Pointer on itself (it's for interity check)
      *This\ObjType = ObjType   ; Set the ObjectType
      If xFlat
        *This\ObjFlags = #PbFw_VObj_Flag_Flat  
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
          Case #PbFw_VObj_Text
            CopyStructure(*VObj, *ThisNew, TText)
            
          Case #PbFw_VObj_Line
            CopyStructure(*VObj, *ThisNew, TText)
            
          Case #PbFw_VObj_Polygon
            CopyStructure(*VObj, *ThisNew, TPolygon)
            
          Case #PbFw_VObj_Spline
            CopyStructure(*VObj, *ThisNew, TSpline)
           
          Case #PbFw_VObj_Ellipse
             CopyStructure(*VObj, *ThisNew, TEllipse)
            
          ; ------------------------------------------------------------
          ; Volume Objects in 3D Space
          ; ------------------------------------------------------------      
          Case  #PbFw_VObj_3DText   
            CopyStructure(*VObj, *ThisNew, T3DText)
            
          Case #PbFw_VObj_3DPoly
            CopyStructure(*VObj, *ThisNew, T3DPoly)
    
          Case #PbFw_VObj_3DCone
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
    
    If *VObj\ObjFlags & #PbFw_VObj_Flag_Flat
      
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
  ; DESC: Create a Line definition in a TLine Structure
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
      \ObjType    = #PbFw_VObj_Line 
      \ObjSubType = #PbFw_VObj_Line_Line
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
  ; DESC: Create a PolyLine definition in a TLine Structure
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
      \ObjType    = #PbFw_VObj_Line 
      \ObjSubType = #PbFw_VObj_Line_PolyLine
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
  ; DESC: Create a Triangle definition in a TPolygon Structure
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
      \ObjType    = #PbFw_VObj_Polygon  
      \ObjSubType = #PbFw_VObj_Polygon_Triangle
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
  ; DESC: Create a Rectangle definition in a TPolygon Structure
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
      \ObjType    = #PbFw_VObj_Polygon  
      \ObjSubType = #PbFw_VObj_Polygon_Rectangle
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
  ; DESC: Create a Pentagon definition in a TPolygon Structure
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
      \ObjType    = #PbFw_VObj_Polygon  
      \ObjSubType = #PbFw_VObj_Polygon_Pentagon
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
  ; DESC: Create a Hexagon definition in a TPolygon Structure
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
      \ObjType    = #PbFw_VObj_Polygon  
      \ObjSubType = #PbFw_VObj_Polygon_Hexagon
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
  ; DESC: Create an Octagon definition in a TPolygon Structure
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
      \ObjType    = #PbFw_VObj_Polygon  
      \ObjSubType = #PbFw_VObj_Polygon_Octagon
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
        \ObjType    = #PbFw_VObj_Polygon  
        \ObjSubType = #PbFw_VObj_Polygon_Polygon
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
        \ObjType    = #PbFw_VObj_Polygon  
        \ObjSubType = #PbFw_VObj_Polygon_Polygon
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
      \ObjType    = #PbFw_VObj_Ellipse  
      \ObjSubType = #PbFw_VObj_Ellipse_Circle
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
      \ObjType    = #PbFw_VObj_Ellipse  
      \ObjSubType = #PbFw_VObj_Ellipse_Ellipse
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
      \ObjType    = #PbFw_VObj_3DPoly 
      \ObjSubType = #PbFw_VObj_3DPoly_Triangle

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
  ; VAR(H.d): height (length in y-direction)    
  ; VAR(D.d): depth  (length in z-direction)
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
      \ObjType    = #PbFw_VObj_3DPoly 
      \ObjSubType = #PbFw_VObj_3DPoly_Rectangle

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
      \ObjType    = #PbFw_VObj_3DCone 
      \ObjSubType = #PbFw_VObj_3DCone_Cylinder
      
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

EndModule

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 347
; FirstLine = 347
; Folding = -----
; Optimizer
; CPU = 5