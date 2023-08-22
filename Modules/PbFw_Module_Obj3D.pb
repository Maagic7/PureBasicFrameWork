; ===========================================================================
; FILE : PbFw_Module_Obj3D.pb
; NAME : PureBasic Framework : Module Objects3D  [Obj3D::]
; DESC : 2D/3D Object definition and handling for Objects with 
; DESC : double precicion coordinates
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/15
; VERSION  :  0.0  Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 2023/08/22 S.Maag : fixed syntax errors
;
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

DeclareModule Obj3D
  EnableExplicit
  
  UseModule VECd    ; VectorModul with single preciciion Float values
  
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
    
  Enumeration eObj3D
    ; flat objects (2D)
    #PbFw_Obj3D_unknown
    #PbFw_Obj3D_Text
    #PbFw_Obj3D_Line
    #PbFw_Obj3D_Polygon
    #PbFw_Obj3D_Spline
    #PbFw_Obj3D_Ellipse
    ; Volume objects (3D)
    #PbFw_Obj3D_3DPolygon
    #PbFw_Obj3D_3DCone
  EndEnumeration
  
  Enumeration eObj3D_SubType
    #PbFw_Obj3D_SubType_unknown    
    ; Subtypes of Text
    #PbFw_Obj3D_SubType_TextSingle      ; Single Line Text    
    #PbFw_Obj3D_SubType_TextMulti       ; Single Line Text    
  
    ; SubTypes of Line
    #PbFw_Obj3D_SubType_Line            ; Line     
    #PbFw_Obj3D_SubType_PolyLine        ; PolyLine 
    ; SubTypes of Ellipse
    #PbFw_Obj3D_SubType_Circle          ; Circle 
    #PbFw_Obj3D_SubType_Ellipse         ; Ellipse)   
    ; SubTypes of Polygon
    #PbFw_Obj3D_SubType_Triangle        ; 3 Edges 
    #PbFw_Obj3D_SubType_Rectangle       ; 4 Edges, regualr Rectangel
    #PbFw_Obj3D_SubType_Pentagon        ; 5 Edges, regular Pentagon
    #PbFw_Obj3D_SubType_Hexagon         ; 6 Edges, regular Hexagon
    #PbFw_Obj3D_SubType_Octagon         ; 8 Edges, regular Octagon
    #PbFw_Obj3D_SubType_Polygon         ; any other Polygon
    
    ; SubTypes of Spline
    #PbFw_Obj3D_SubType_CatMullRom
    #PbFw_Obj3D_SubType_CSpline
    #PbFw_Obj3D_SubType_BSpline   
    
    ; SubTypes of 3DPolygon
    #PbFw_Obj3D_SubType_3DTriangle      ; 
    #PbFw_Obj3D_SubType_3DBox           ; 
    #PbFw_Obj3D_SubType_3DPentagon      ; 5 Edges, regular Pentagon
    #PbFw_Obj3D_SubType_3DHexagon       ; 6 Edges, regular Hexagon
    #PbFw_Obj3D_SubType_3DOctagon       ; 8 Edges, regular Octagon
    #PbFw_Obj3D_SubType_3DPolygon       ; any other Polygon   

    ; SubTypes of 3DCone
    #PbFw_Obj3D_SubType_3DCylinder            ; 3D Cylinder
    #PbFw_Obj3D_SubType_3DEllipticCylinder    ; 3D elliptical Cylinder
    #PbFw_Obj3D_SubType_3DCone                ; 3D Cone  {Kegel}
    #PbFw_Obj3D_SubType_3DEllipticCone        ; 3D elliptical Cone {elliptischer Kegel} 
    
  EndEnumeration
  
  Enumeration eObj3D_FillStyle
    #PbFw_Obj3D_FillStyle_Transparent = 0     ; Transparent = without filling
    #PbFw_Obj3D_FillStyle_Solid               ; with solid filling
    #PbFw_Obj3D_FillStyle_Pattern             ; Musterfüllung (z.B. gestreift)
    #PbFw_Obj3D_FillStyle_Image               ; Filled with an Image (.bmp, .png, .jpg)
  EndEnumeration

  Enumeration eObj3D_LineStyle
    #PbFw_Obj3D_LineStyle_Solid       ; Solid Line   : StrokePath()
    #PbFw_Obj3D_LineStyle_Dash        ; ------ Line  : DashPath()
    #PbFw_Obj3D_LineStyle_Dot         ; ..... Line   : DotPath()
    #PbFw_Obj3D_LineStyle_DashDot     ; -.-.- Line   : CustomDashPath()
    #PbFw_Obj3D_LineStyle_DashDotDot  ; -..-..- Line : CustomDashPath()
  EndEnumeration
  
  Structure TLineStyle
    Color.l               ; Color
    Width.d               ; Line width
    Style.l               ; LineStyle {eObj3D_LineStyle}
  EndStructure
  
  Structure TFillStyle
    Color.l               ; Fill Color
    GradientColor.l       ; Gradient Color {Farbverlauf}
    Style.l               ; Fill Style {eObj3D_FillStyle}
  EndStructure
  
  ; This is the State of a Element and must be implemented by all Element Structures
  ; like TLine, TCircle, ... 
  Structure TObjState
    Layer.l   ; No of grafical Layer
    Groupe.l  ; Number of the associated group
    xHide.l   ; #FALSE=visible, #TRUE=Hide
  EndStructure
  
  ; ----------------------------------------------------------------------
  ; Text Object
  ; ----------------------------------------------------------------------

  Enumeration eTextAlign
    #PbFw_Obj3D_TextAlign_UpLeft
    #PbFw_Obj3D_TextAlign_UpMiddle
    #PbFw_Obj3D_TextAlign_UpRight
    #PbFw_Obj3D_TextAlign_DownLeft
    #PbFw_Obj3D_TextAlign_DownMiddle
    #PbFw_Obj3D_TextAlign_DownRight 
  EndEnumeration

  #PbFw_Obj3D_Font_BOLD = #PB_Font_Bold
  #PbFw_Obj3D_Font_Italic = #PB_Font_Italic
  #PbFw_Obj3D_Font_StrikeOut = #PB_Font_StrikeOut
  #PbFw_Obj3D_Font_Underline = #PB_Font_Underline

  Structure TFont   ; Vector Fonts only
    FontID.i
    Size.l
    Style.l         ; #PB_Font_Bold, #PB_Font_Italic
  EndStructure
  
  Structure TText
    ObjType.i           ; Object-Type = #PbFw_Obj3D_Text
    ObjSubType.i
    Align.l             ; how to align the Text:  [Enumeration eTextAlign UpLeft, UpMiddle, UpRight, ...]
    Direction.l         ; Enumeration eDirection [#Right, #Left, #Up, #Down]
    Color.i             ; Text Color
    Origin.TVector      ; origin of the Text [x,y]
    State.TObjState     ; Status: LayerNo, Hide ...
    Font.TFont          ; Font
    NoOfLines.i         ; Number of Lines = 1
    Array Txt.s(0)      ; one entry for each Line
  EndStructure

  ; ----------------------------------------------------------------------
  ; Flat Objects -2D
  ; ----------------------------------------------------------------------
  
  Structure TObjBase
    ObjType.i                 ; Object-Type = #PbFw_Obj3D_Polygon
    ObjSubType.i    
  EndStructure
  
  Structure TObj2DBase Extends TObjBase
    LStyle.TLineStyle
    NoOfPts.i                 ; Number of Points = 2
    Array PT.TVector(0)       ; Array of Points. Point(0) = Reference Point; Object defintion Points start at PT(1)
  EndStructure
  
  Structure TLine Extends TObj2DBase
    ;  Line defintion is excatly the TObj2DBase Structure
  EndStructure  
  Structure T3DLine Extends TLine
    TMx.TMatrix                ; Object's Transformation Matrix
  EndStructure  
 
  Structure TPolygon Extends TObj2DBase
    Fill.TFillStyle
  EndStructure
  
  Structure TSpline Extends TPolygon
    Array defPT.TVector(0)    ; Spline definition Points
  EndStructure
   
  Structure TEllipse Extends TObj2DBase
    Fill.TFillStyle
    Rx.TVector                ; Radius X
    Ry.TVector                ; Radius Y
  EndStructure
  Structure T3DEllipse Extends TEllipse
    TMx.TMatrix               ; Object's Transformation Matrix    
  EndStructure   
  
  ; ----------------------------------------------------------------------
  ; Volume Objects
  ; ----------------------------------------------------------------------
  
  Structure TObj3DBase Extends TObjBase
    RefPt.TVector             ; Reference Point
    TMx.TMatrix               ; Object's Transformation Matrix    
  EndStructure

  Structure T3DPolygon Extends TObj3DBase       ; volume Quadrangle
    POL.TPolygon[2]
  EndStructure
  
  Structure T3DCone Extends TObj3DBase          ; volume Circle (Cylinder, Cone)
    EL.TEllipse[2]
  EndStructure
    
  ; ----------------------------------------------------------------------
  ; 
  ; ----------------------------------------------------------------------
  Structure T3DObj
    *Obj          ; Pointer to Object T3DCircle, T3DBox ...
    ObjType.i     ; ObjectType: #PbFw_Obj3D_3D_Circle ....
    TMx.TMatrix    ; Transformation Matrix
  EndStructure
  
  ;- ----------------------------------------------------------------------
  ;- Declare Module
  ;- ----------------------------------------------------------------------
  Declare.i Create_Line(*Obj3D.TLine, width.d, height.d)
  Declare.i Create_PolyLine(*Obj3D.TLine, width.d, height.d)

  Declare.i Create_Triangle(*Obj3D.TPolygon, X2.d,Y2.d, X3.d,Y3.d)
  Declare.i Create_Rectangle(*Obj3D.TPolygon, width.d, height.d)
  Declare.i Create_Pentagon(*Obj3D.TPolygon, r.d)
  Declare.i Create_Hexagon(*Obj3D.TPolygon, r.d)
  Declare.i Create_Octagon(*Obj3D.TPolygon, r.d)
  Declare.i Create_Circle(*Obj3D.TEllipse, r.d)
  Declare.i Create_Ellipse(*Obj3D.TEllipse, rx.d, ry.d)
  
  Declare.i Create_3DBox(*Obj3D.T3DPolygon, X.d, Y.d, width.d, height.d, depth.d)
  Declare.i Create_3DCylinder(*Obj3D.T3DCone, r.d, h.d)
  Declare.i Create_3DCone(*Obj3D.T3DCone, r1.d, r2.d, h.d)
  Declare.i Create_3DPentagon(*Obj3D.T3DPolygon, r.d, h.d)
  Declare.i Create_3DHexagon(*Obj3D.T3DPolygon, r.d, h.d)
  Declare.i Create_3DOctagon(*Obj3D.T3DPolygon, r.d, h.d)

EndDeclareModule

Module Obj3D
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
 
  UseModule VECd
  
  ;  ----------------------------------------------------------------------
  ;- Create 2D flat Objects
  ;- ----------------------------------------------------------------------
  
  Procedure.i Create_Line(*Obj3D.TLine, width.d, height.d)
  ; ============================================================================
  ; NAME: Create_Line
  ; DESC: Create a Line definition in a TLine Structure
  ; VAR(*Obj3D.TLine) : Pointer to the Line Object
  ; VAR( width.d)  :  Width
  ; VAR( height.d) : Height  
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    ; ACHTUNG!!! Ändern PT(0) wird immer der Refernz-Punkt (Drehpunkt/Ursprung)
    ; Jedes Objekt hat also einen Punkt mehr. Der derste Objekt-Punkt ist immer PT(1)
    
    With *Obj3D
      \NoOfPts = 2      
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf     
      \NoOfPts    = 2
      \ObjType    = #PbFw_Obj3D_Line 
      \ObjSubType = #PbFw_Obj3D_SubType_Line
    EndWith
    
    With *Obj3D\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *Obj3D\PT(2)
      \x = width
      \y = height
      \z = 0 
    EndWith
    
    *Obj3D\PT(0) = *Obj3D\PT(1) ; Set Reference Point PT(0)
    
    ProcedureReturn *Obj3D
  EndProcedure
  
  Procedure.i Create_PolyLine(*Obj3D.TLine, width.d, height.d)
  ; ============================================================================
  ; NAME: Create_PolyLine
  ; DESC: Create a PolyLine definition in a TLine Structure
  ; VAR(*Obj3D.TLine) : Pointer to the Line Object
  ; VAR( width.d)  :  Width
  ; VAR( height.d) : Height  
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \NoOfPts = 5      
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf     
      \NoOfPts    = 2
      \ObjType    = #PbFw_Obj3D_Line 
      \ObjSubType = #PbFw_Obj3D_SubType_PolyLine
    EndWith
    
    With *Obj3D\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *Obj3D\PT(2)
      \x = width
      \y = height
      \z = 0 
    EndWith
    
    *Obj3D\PT(0) = *Obj3D\PT(1) ; Set Reference Point PT(0)
   
    ProcedureReturn *Obj3D
  EndProcedure
  
  Procedure.i Create_Triangle(*Obj3D.TPolygon, X2.d,Y2.d, X3.d,Y3.d)
  ; ============================================================================
  ; NAME: Create_Triangle
  ; DESC: Create a Triangle definition in a TPolygon Structure
  ; VAR(*Obj3D.TPolygon) : Pointer to the Polygon Object
  ; VAR(X2.d): X of 2nd Point
  ; VAR(Y2.d): Y of 2nd Point
  ; VAR(X3.d): X of 3nd Point
  ; VAR(Y3.d): Y of 3nd Point
  ; RET.i : *Obj3D
  ; ============================================================================
    
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \NoOfPts = 3     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #PbFw_Obj3D_Polygon  
      \ObjSubType = #PbFw_Obj3D_SubType_Triangle
    EndWith
   
    With *Obj3D\PT(1)
      \x = 0
      \y = 0
      \z = 0       
    EndWith
    
    With *Obj3D\PT(2)
      \x = X2
      \y = Y2
      \z = 0        
    EndWith
    
    With *Obj3D\PT(3)
      \x = X3
      \y = Y3
      \z = 0        
    EndWith
    
    *Obj3D\PT(0) = *Obj3D\PT(1) ; Set Reference Point PT(0)
   
    ProcedureReturn *Obj3D  
  EndProcedure
  
  Procedure.i Create_Rectangle(*Obj3D.TPolygon, width.d, height.d)
  ; ============================================================================
  ; NAME: Create_Rectangle
  ; DESC: Create a Rectangle definition in a TPolygon Structure
  ; VAR(*Obj3D.TPolygon) : Pointer to the Polygon Object
  ; VAR( width.d)  : Width
  ; VAR( height.d) : Height  
  ; RET.i : *Obj3D
  ; ============================================================================
       
  ;   P1--------------P2
  ;   |               | 
  ;   |               |
  ;   |               |
  ;   P0--------------P3
    
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \NoOfPts = 4     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #PbFw_Obj3D_Polygon  
      \ObjSubType = #PbFw_Obj3D_SubType_Rectangle
    EndWith
    
    With *Obj3D\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *Obj3D\PT(2)
      \X = 0
      \Y = height
      \Z = 0
    EndWith
    
    With *Obj3D\PT(3)
      \X = width
      \Y = height
      \Z = 0
    EndWith
    
    With *Obj3D\PT(4)
      \X = width
      \Y = 0
      \Z = 0
    EndWith
    
    *Obj3D\PT(0) = *Obj3D\PT(1) ; Set Reference Point PT(0)
    
    ProcedureReturn *Obj3D
  EndProcedure

  Procedure.i Create_Pentagon(*Obj3D.TPolygon, r.d)
  ; ============================================================================
  ; NAME: Create_Pentagon
  ; DESC: Create a Pentagon definition in a TPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.TPolygon) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *Obj3D
  ; ============================================================================
    
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \NoOfPts = 5     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #PbFw_Obj3D_Polygon  
      \ObjSubType = #PbFw_Obj3D_SubType_Pentagon
    EndWith
    
    With *Obj3D\PT(1)
      \x= r
      \y= 0
      \z =0
    EndWith
    
    With *Obj3D\PT(3)
      \x= r * Cos(Radian(72))
      \y= r * Sin(Radian(72))
      \z =0
    EndWith
    
    With *Obj3D\PT(3)
      \x= r * Cos(Radian(72*2))
      \y= r * Sin(Radian(72*2))
      \z =0
    EndWith

    With *Obj3D\PT(4)
      \x= r * Cos(Radian(72*3))
      \y= r * Sin(Radian(72*3))
      \z =0
    EndWith
    
    With *Obj3D\PT(5)
      \x= r * Cos(Radian(72*4))
      \y= r * Sin(Radian(72*4))
      \z =0
    EndWith
    
    ; Set Reference Point PT(0) = Center Point
    With *Obj3D\PT(0)
      \x= 0
      \y= 0
      \z =0
    EndWith
    
    ProcedureReturn *Obj3D  
  EndProcedure
  
  Procedure.i Create_Hexagon(*Obj3D.TPolygon, r.d)
  ; ============================================================================
  ; NAME: Create_Hexagon
  ; DESC: Create a Hexagon definition in a TPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.TPolygon) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *Obj3D
  ; ============================================================================
    
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \NoOfPts = 6     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #PbFw_Obj3D_Polygon  
      \ObjSubType = #PbFw_Obj3D_SubType_Hexagon
    EndWith
    
    With *Obj3D\PT(1)
      \x= r
      \y= 0
      \z =0
    EndWith
    
    With *Obj3D\PT(2)
      \x= r * Cos(Radian(60))
      \y= r * Sin(Radian(60))
      \z =0
    EndWith
    
    With *Obj3D\PT(3)
      \x= r * Cos(Radian(60*2))
      \y= r * Sin(Radian(60*2))
      \z =0
    EndWith

    With *Obj3D\PT(4)
      \x= r * Cos(Radian(60*3))
      \y= r * Sin(Radian(60*3))
      \z =0
    EndWith
    
    With *Obj3D\PT(5)
      \x= r * Cos(Radian(60*4))
      \y= r * Sin(Radian(60*4))
      \z =0
    EndWith
    
    With *Obj3D\PT(6)
      \x= r * Cos(Radian(60*5))
      \y= r * Sin(Radian(60*5))
      \z =0
    EndWith

    ; Set Reference Point PT(0) = Center Point
    With *Obj3D\PT(0)
      \x= 0
      \y= 0
      \z =0
    EndWith
    
    ProcedureReturn *Obj3D  
  EndProcedure
  
  Procedure.i Create_Octagon(*Obj3D.TPolygon, r.d)
  ; ============================================================================
  ; NAME: Create_Octagon
  ; DESC: Create an Octagon definition in a TPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.TPolygon) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \NoOfPts = 8     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #PbFw_Obj3D_Polygon  
      \ObjSubType = #PbFw_Obj3D_SubType_Octagon
    EndWith
    
    With *Obj3D\PT(1)
      \x= r
      \y= 0
      \z =0
    EndWith
    
    With *Obj3D\PT(2)
      \x= r * Cos(Radian(45))
      \y= r * Sin(Radian(45))
      \z =0
    EndWith
    
    With *Obj3D\PT(3)
      \x= r * Cos(Radian(45*2))
      \y= r * Sin(Radian(45*2))
      \z =0
    EndWith

    With *Obj3D\PT(4)
      \x= r * Cos(Radian(45*3))
      \y= r * Sin(Radian(45*3))
      \z =0
    EndWith
    
    With *Obj3D\PT(5)
      \x= r * Cos(Radian(45*4))
      \y= r * Sin(Radian(45*4))
      \z =0
    EndWith
    
    With *Obj3D\PT(6)
      \x= r * Cos(Radian(45*5))
      \y= r * Sin(Radian(45*5))
      \z =0
    EndWith
    
    With *Obj3D\PT(7)
      \x= r * Cos(Radian(45*6))
      \y= r * Sin(Radian(45*6))
      \z =0
    EndWith
    
    With *Obj3D\PT(8)
      \x= r * Cos(Radian(45*7))
      \y= r * Sin(Radian(45*7))
      \z =0
    EndWith

    ; Set Reference Point PT(0) = Center Point
    With *Obj3D\PT(0)
      \x= 0
      \y= 0
      \z =0
    EndWith
    
    ProcedureReturn *Obj3D  
  EndProcedure
  
  Procedure.i Create_PolygonCircel(*Obj3D.TPolygon, r.d, NoOfPoints.i)
  ; ============================================================================
  ; NAME: Create_PolygonCircel
  ; DESC: Create a Circle as Polygon definition in a TPolygon Structure
  ; VAR(*Obj3D.TPolygon) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; VAR(NoOfPoints.d): No of Points to create
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    If NoOfPoints > 0 And NoOfPoints <= (360*60) ; maximum value for a resulution in AngularMinutes 
      
      With *Obj3D
        \NoOfPts = NoOfPoints     
        If ArraySize(\PT()) <> \NoOfPts
          ReDim \PT(\NoOfPts)
        EndIf      
        \ObjType    = #PbFw_Obj3D_Polygon  
        \ObjSubType = #PbFw_Obj3D_SubType_Polygon
      EndWith
            
      Protected dAngle.d = (#PI * 2) / NoOfPoints
      Protected I
      
      With *Obj3D\PT(1)
        \x= r
        \y= 0
        \z =0
      EndWith
      
      For I = 2 To NoOfPoints       
        With *Obj3D\PT(I)
          \x= r * Cos(dAngle)
          \y= r * Sin(dAngle)
          \z =0
        EndWith
        dAngle + dAngle  
      Next
      
      ; Set Reference Point PT(0) = Center Point
      With *Obj3D\PT(0)
        \x= 0
        \y= 0
        \z =0
      EndWith
    EndIf
    
    ProcedureReturn *Obj3D  
  EndProcedure
  
  Procedure.i Create_PolygonFromList(*Obj3D.TPolygon, List Pts.TVector())
  ; ============================================================================
  ; NAME: Create_PolygonFromList
  ; DESC: Create a Polygon definition in a TPolygon Structure
  ; DESC: based on a List of Points As TVector
  ; VAR(*Obj3D.TPolygon) : Pointer to the Polygon Object
  ; VAR(Pts.TVector()): List of Points as TVector
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer2(*Obj3D, Pts())    ; Check Pointer Exception
    
    Protected lstSize = ListSize(Pts())
    
    If lstSize > 1
      
      With *Obj3D
        \NoOfPts = lstSize     
        If ArraySize(\PT()) <> \NoOfPts
          ReDim \PT(\NoOfPts)
        EndIf      
        \ObjType    = #PbFw_Obj3D_Polygon  
        \ObjSubType = #PbFw_Obj3D_SubType_Polygon
      EndWith
            
      Protected I      
      ResetList(Pts())      
      ForEach Pts()
        I+1 
        *Obj3D\PT(I) = Pts()
      Next
      
      ; Set Reference Point PT(0) = Center Point
      With *Obj3D\PT(0)
        \x= 0
        \y= 0
        \z =0
      EndWith
      
    EndIf
    
    ProcedureReturn *Obj3D  
  EndProcedure

  
  Procedure.i Create_Circle(*Obj3D.TEllipse, r.d)
  ; ============================================================================
  ; NAME: Create_Circle
  ; DESC: Create a Circle definition in a TEllipse Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.TEllipse) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \NoOfPts = 1     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #PbFw_Obj3D_Ellipse  
      \ObjSubType = #PbFw_Obj3D_SubType_Circle
    EndWith

    With *Obj3D\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *Obj3D\Rx
      \x = r
      \y = 0
      \z = 0
    EndWith
    
    With *Obj3D\Ry
      \x = 0
      \y = r
      \z = 0
    EndWith
    
    *Obj3D\PT(0) = *Obj3D\PT(1) ; Set Reference Point PT(0)

    ProcedureReturn *Obj3D
  EndProcedure
  
  Procedure.i Create_Ellipse(*Obj3D.TEllipse, rx.d, ry.d)
  ; ============================================================================
  ; NAME: Create_Ellipse
  ; DESC: Create an Ellipse definition in a TEllipse Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.TEllipse) : Pointer to the Polygon Object
  ; VAR(r.d): Radius
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \NoOfPts = 1     
      If ArraySize(\PT()) <> \NoOfPts
        ReDim \PT(\NoOfPts)
      EndIf      
      \ObjType    = #PbFw_Obj3D_Ellipse  
      \ObjSubType = #PbFw_Obj3D_SubType_Ellipse
    EndWith
    
    With *Obj3D\PT(1)
      \x = 0
      \y = 0
      \z = 0
    EndWith
    
    With *Obj3D\Rx
      \x = rx
      \y = 0
      \z = 0
    EndWith
    
    With *Obj3D\Ry
      \x = 0
      \y = ry
      \z = 0
    EndWith
    
    *Obj3D\PT(0) = *Obj3D\PT(1) ; Set Reference Point PT(0)

    ProcedureReturn *Obj3D
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Create 3D volume Objects
  ;- ----------------------------------------------------------------------
 
  Procedure.i Create_3DTriangle(*Obj3D.T3DPolygon, X2.d,Y2.d, X3.d,Y3.d, depth.d)
  ; ============================================================================
  ; NAME: Create_3DTriangle
  ; DESC: Create a 3D Triangle definition in a T3DPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.T3DPolygon) : Pointer to the 3DPolygon Object
  ; VAR(X2.d): X of 2nd Point
  ; VAR(Y2.d): Y of 2nd Point
  ; VAR(X3.d): X of 3nd Point
  ; VAR(Y3.d): Y of 3nd Point
  ; RET.i : *Obj3D
  ; ============================================================================
   
  ;         .p5  
  ;      .  |    .         
  ;    P1   |        .
  ;    |   .|            .
  ;    |   .p4-----------.p6
  ;    | .           .
  ;    P0--------------P2
    
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
 
    With *Obj3D
      \ObjType    = #PbFw_Obj3D_3DPolygon 
      \ObjSubType = #PbFw_Obj3D_SubType_3DTriangle

      Create_Triangle(\POL[0], X2.d,Y2.d, X3.d,Y3.d) 
      \POL[1] = \POL[0]   ; Polygon(1) = Polygon(0)
    EndWith
  
    With *Obj3D\POL[1]  ; set the depth (z-coordinates of Poligon(1))
      \PT(1)\z = depth  
      \PT(2)\z = depth  
      \PT(3)\z = depth  
    EndWith
    
    ProcedureReturn *Obj3D
  EndProcedure

  Procedure.i Create_3DBox(*Obj3D.T3DPolygon, X.d, Y.d, width.d, height.d, depth.d)
  ; ============================================================================
  ; NAME: Create_3DBox
  ; DESC: Create a 3D Box definition in a T3DPolygon Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.T3DPolygon) : Pointer to the 3DPolygon Object
  ; VAR(width.d):  width  (lenth in x-direction)
  ; VAR(height.d): height (lenth in y-direction)    
  ; VAR(depth.d):  depth  (lenth in z-direction)
  ; RET.i : *Obj3D
  ; ============================================================================
   
  ;         .p5------------.p6  
  ;      .  |            . |
  ;    P1--------------P2  |
  ;    |    |          |   |
  ;    |   .p4---------|--.p7
  ;    | .             |.
  ;    P0--------------P3
    
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
 
    With *Obj3D
      \ObjType    = #PbFw_Obj3D_3DPolygon 
      \ObjSubType = #PbFw_Obj3D_SubType_3DBox

      Create_Rectangle(\POL[0], width, height) 
      \POL[1] = \POL[0]
    EndWith
  
    With *Obj3D\POL[1]
      \PT(1)\z = depth  
      \PT(2)\z = depth  
      \PT(3)\z = depth  
      \PT(4)\z = depth     
    EndWith
    
    With *Obj3D\RefPt
      \x=0
      \y=0
      \z=0
      \w=0
    EndWith
   
    ProcedureReturn *Obj3D
  EndProcedure
  
  Procedure.i Create_3DCylinder(*Obj3D.T3DCone, r.d, h.d)
  ; ============================================================================
  ; NAME: Create_T3DCylinder
  ; DESC: Create a 3D Cylinder definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.T3DCone) : Pointer to the 3DCone Object
  ; VAR(r.d): Radius
  ; VAR(h.d): Height  (lenth in z-direction)
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      \ObjType    = #PbFw_Obj3D_3DCone 
      \ObjSubType = #PbFw_Obj3D_SubType_3DCylinder
      
      Create_Circle(*Obj3D\EL[0], r)
      \EL[1] = \EL[0]
    EndWith
        
    With *Obj3D\EL[1]\PT(1)
      \x = 0
      \y = 0
      \z = h
    EndWith

    ProcedureReturn *Obj3D
  EndProcedure
  
  Procedure.i Create_3DCone(*Obj3D.T3DCone, r1.d, r2.d, h.d)
  ; ============================================================================
  ; NAME: Create_T3DCone
  ; DESC: Create a 3D Cone definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.T3DCone) : Pointer to the 3DCone Object
  ; VAR(r1.d): Radius 1
  ; VAR(r2.d): Radius 2
  ; VAR(h.d):  Height  (lenth in z-direction)
  ; RET.i : *Obj3D
  ; ============================================================================
      
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    Create_Ellipse(*Obj3D\EL[0], r1, r1)  
    *Obj3D\EL[1] = *Obj3D\EL[0]
    
    With *Obj3D\EL[1]
      
      \PT(1)\z = h
      \Rx\x = r2
      \Ry\y = r2
    EndWith
    
    ProcedureReturn *Obj3D
  EndProcedure
  
  Procedure.i Create_3DPentagon(*Obj3D.T3DPolygon, r.d, h.d)
  ; ============================================================================
  ; NAME: Create_3DPentagon
  ; DESC: Create a 3D Pentagon definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.T3DPolygon) : Pointer to the 3DCone Object
  ; VAR(r.d): Radius 
  ; VAR(h.d): Height
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      Create_Pentagon(\POL[0], r) 
      \POL[1] = \POL[0]  
    EndWith 
    
    With *Obj3D\POL[1]
     \PT(0)\z = h 
     \PT(1)\z = h 
     \PT(2)\z = h 
     \PT(3)\z = h 
     \PT(4)\z = h    
    EndWith
    
    ProcedureReturn *Obj3D  
  EndProcedure
  
  Procedure.i Create_3DHexagon(*Obj3D.T3DPolygon, r.d, h.d)
  ; ============================================================================
  ; NAME: Create_3DHexagon
  ; DESC: Create a 3D Hexagon definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.T3DPolygon) : Pointer to the 3DPolygon Object
  ; VAR(r.d): Radius 
  ; VAR(h.d): Height
  ; RET.i : *Obj3D
  ; ============================================================================
   
    DBG::mac_CheckPointer(*Obj3D)    ; Check Pointer Exception
    
    With *Obj3D
      Create_Hexagon(\POL[0], r) 
      \POL[1] = \POL[0]  
    EndWith 
    
    With *Obj3D\POL[1]
     \PT(0)\z = h 
     \PT(1)\z = h 
     \PT(2)\z = h 
     \PT(3)\z = h 
     \PT(4)\z = h 
     \PT(5)\z = h    
    EndWith
    
    ProcedureReturn *Obj3D  
  EndProcedure
  
  Procedure.i Create_3DOctagon(*Obj3D.T3DPolygon, r.d, h.d)
  ; ============================================================================
  ; NAME: Create_3DOctagon
  ; DESC: Create a 3D Octagon definition in a T3DCone Structure
  ; DESC: with Center Point = [0,0,0]
  ; VAR(*Obj3D.T3DPolygon) : Pointer to the 3DPolygon Object
  ; VAR(r.d): Radius 
  ; VAR(h.d): Height
  ; RET.i : *Obj3D
  ; ============================================================================
    
    With *Obj3D
      Create_Octagon(\POL[0], r) 
      \POL[1] = \POL[0]  
    EndWith 
    
    With *Obj3D\POL[1]
     \PT(0)\z = h 
     \PT(1)\z = h 
     \PT(2)\z = h 
     \PT(3)\z = h 
     \PT(4)\z = h 
     \PT(5)\z = h    
     \PT(6)\z = h 
     \PT(7)\z = h    
    EndWith
    
    ProcedureReturn *Obj3D  
  EndProcedure

EndModule

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 998
; Folding = ----
; Optimizer
; CPU = 5