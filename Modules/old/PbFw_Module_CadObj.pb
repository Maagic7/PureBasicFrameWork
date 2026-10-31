; ===========================================================================
; FILE : PbFw_Module_CadObj.pb
; NAME : PureBasic Framework : Module CAD-Objects  [CadObj::]
; DESC : 2D/3D CAD Object definition and handling
; DESC : The System how to define 2D/3D CAD Objects is inspiered by
; DESC : Stamdard STEP Data Format what is a kind of linked list/tree for
; DESC : the objects and it's definitions. Each Object (Entity) can consists
; DESC : of a set of SubObjects referenced by it's pointers. So an Object
; DESC : can be part of n other Objects.
;
; DESC : At the moment it's only a test implemantion to see how to learn
; DESC : how to handle such strutures and test its effectivity!
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/10/27
; VERSION  :  0.0  Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;  2023/10/27 S.Maag : 
;  
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
; XIncludeFile "PbFw_Module_VECTORd.pb"      ; VECd::     double precision Vector Module

DeclareModule CadObj
  
  ;- ----------------------------------------------------------------------
  ;- CONSTANTS
  ; ----------------------------------------------------------------------
  
  Enumeration EEntitys 1
    #Entity_SimplePoint
    #Entity_SimpleLine
    #Entity_Rect
    #Entity_Circle
    #Entity_Polygon
  EndEnumeration
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES
  ; ----------------------------------------------------------------------
  
  ; UseModule VECd    ; VectorModul with single preciciion Float values
  Structure TVector
    X.d
    Y.d
    Z.d
    W.d
  EndStructure
  
  Structure TEntityBase
    TypeID.l                  ; Type     = #Entity_[Name]
    cRef.l                    ; Reference Counter
    GroupID.l                 ; if the Object is grouped with others, the Group-ID
    LayerID.l                 ; Drawing layer ID
  EndStructure
  
  Structure TSimplePoint ; Extends TEntityBase
    TypeID.l                  ; Type     = #Entity_[Name]
    cRef.l                    ; Reference Counter
    PT.TVector
  EndStructure
  
  Structure TSimpleLine Extends TEntityBase
     *pPT.TSimplePoint[1]
  EndStructure
        
  Structure TEntity Extends TEntityBase
    SubTypeID.l
    key.q
    Flags.q
    N.l                   ; NoOfSubEntities
    Array pObj.i(0)       ; Array of Pointer to SubEntities
  EndStructure 
  
EndDeclareModule

Module CadObj
  
  Global NewList lstPoint.i()
  Global NewList lstLine.i()
  Global NewList lstEntity.i()
  
  Global *PTOrigin.TSimplePoint   ; the origin for LineDrawing Fuchtion : New_LineTo()

  Macro mac_AutoincrementingKey(MyKeyVar)
    Static MyKeyVar.q : MyKeyVar + 1  
  EndMacro
  
  Procedure _SetOrigin(*PT.TSimplePoint)    
    If *PT
      *PTOrigin = *PT 
    Else
      ; Debug.Error  
    EndIf   
    ProcedureReturn *PT  
  EndProcedure
  
  Procedure.i _AddReference(*Entity.TEntityBase)
    If *Entity
      *Entity\cRef + 1
    Else
      ; Debug.Error  
    EndIf 
    ProcedureReturn  *Entity\cRef
  EndProcedure
  
  Procedure.i _RemoveReference(*Entity.TEntityBase)
    If *Entity
      With *Entity
        If \cRef > 0
          \cRef - 1
        Else
          \cRef = 0
        EndIf   
      EndWith
    Else
      ; Debug.Error  
    EndIf     
    ProcedureReturn *Entity\cRef
  EndProcedure

  Procedure.i New_Entity(Type = #Entity_Rect, NoOfSubEntries.i=4)
    Protected *Entity.TEntity    
    Static  key.q :  key + 1      ; Autoincrementing key value
        
    *Entity= AllocateStructure(TEntity)
    If *Entity
      With *Entity  
        \TypeID = Type
        \Key = key
        Dim \pObj(NoOfSubEntries)
      EndWith
      
      AddElement(lstEntity())
      lstEntity() = *Entity
    Else
      ; Debug.Error  
    EndIf
    
    ProcedureReturn *Entity
  EndProcedure
  
  Procedure Kill_Entity(*Entity.TEntityBase)
    
    If *Entity
      FreeStructure(*Entity)  
      
      ; Remove Entity Reference from List
      ForEach lstEntity()
        If lstEntity() = *Entity
          DeleteElement(lstEntity())
        EndIf
      Next
    Else
      ; Debug.Error        
    EndIf
  EndProcedure
  
  Procedure.i New_SimplePoint(X.d=0, Y.d=0, Z.d=0)
    Protected *PT.TSimplePoint    
    
    *PT = AllocateStructure(TSimplePoint)  
    If *PT
      With *PT
        \TypeID = #Entity_SimplePoint
        \PT\X = X
        \PT\Y = Y
        \PT\Z = Z      
      EndWith
      
      AddElement(lstPoint())
      lstPoint()= *PT
    Else
      ; Debug.Error        
    EndIf
   
    ProcedureReturn *PT
  EndProcedure
  
  Procedure Release_SimplePoint(*PT.TSimplePoint)
    
    If *PT
      With *PT        
        If _RemoveReference(*PT) = 0          
          FreeStructure(*PT)  
          ; Remove Entity Reference from List
          ForEach lstPoint()
            If lstPoint() = *PT
              DeleteElement(lstPoint())
            EndIf
          Next  
        EndIf
      EndWith  
    Else
      ; Debug.Error        
    EndIf
  EndProcedure
  
  Procedure.i New_SimpleLine(*PT0.TSimplePoint=0, *PT1.TSimplePoint=0)
    Protected *Line.TSimpleLine
     
    *Line = AllocateStructure(TSimpleLine)
    If *Line
      With *Line
        \TypeID = #Entity_SimpleLine
        If Not *PT0
          *PT0 = New_SimplePoint()
        EndIf 
        If Not *PT2
          *PT1 = New_SimplePoint()
        EndIf
        *PT0\cRef + 1   ; INC ReferenceCounter of PT0
        *PT1\cRef + 1   ; INC ReferenceCounter of PT1
        \pPT[0] = *PT0  ; Hook PT0 into Line : (Set Reference of Lines Point0)
        \pPT[1] = *PT1  ; Hook PT1 into Line    
      EndWith
    Else
      ; Debug.Error        
    EndIf
    
    ProcedureReturn *Line  
  EndProcedure
      
  Procedure New_LineTo(X.d, Y.d, Z.d=0)
    Protected *Line.TSimpleLine
     
    *Line = AllocateStructure(TSimpleLine)
    If *Line
      With *Line
        \TypeID = #Entity_SimpleLine
        \pPT[0] = *PTOrigin   ; Set Origin as Lines Point0
        *PTOrigin\cRef + 1
        
        *PTOrigin = New_SimplePoint(X, Y, Z)
        \pPT[1] = *PTOrigin
        *PTOrigin\cRef + 1
      EndWith
    Else
      ; Debug.Error        
    EndIf
    
    ProcedureReturn *Line     
  EndProcedure
  
  Procedure.i New_Rectangle(X.d=0, Y.d=0, w.d=1, h.d=1)
    Protected *Entity.TEntity
    Protected *Line.TEntity
    Protected *PTStart.TSimplePoint
    
    *Entity = New_Entity(#Entity_Rect, 4)
    
    If *Entity
      *PTStart = New_SimplePoint(X, Y)     ; create the StartPoint
      _SetOrigin(*PTStart)                 ; set StartPoint as origin
      
      ; a rectangle is a set of 4 Lines
      With *Entity
        ; 1st line
        *Line = New_LineTo(X, Y + h)      ; first Line from Origin to (x, y) and set EndPoint as new Origin
        *Line\cRef + 1                    ; Increment Lines ReferenceCounter (because it is part of the rectangle)
        \pObj(0) = *Line                  ; Hook Line into Rectangle as 1st Object
        
        ; 2nd Line
        *Line = New_LineTo(X + w, Y + h)  ; Line from Origin to a new Point
        *Line\cRef + 1                    ; Increment Lines ReferenceCounter (because it is part of the rectangle)
        \pObj(1) = *Line                  ; Hook Line into Rectangle as 2nd Object
         
        ; 3th Line
        *Line = New_LineTo(X + w, Y)
        *Line\cRef + 1
        \pObj(3) = *Line
        
        ; 4th Line
        *Line = New_SimpleLine(*PTOrigin, *PTStart) ; the last line go to an existing Point (the StartPoint)! Do not create a new Point!
        *Line\cRef + 1
        \pObj(4) = *Line
       
      EndWith
    Else
      ; Debug.Error        
    EndIf
    ProcedureReturn *Entity
  EndProcedure
  
EndModule
  
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 253
; FirstLine = 190
; Folding = ---
; Optimizer
; CPU = 5