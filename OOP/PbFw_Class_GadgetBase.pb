; ===========================================================================
; FILE : PbFw_Class_GadgetBase.pb 
; NAME : PureBasic Framework: Base Class for Gadgets clsGadgetBase::
; DESC : This Class implements all Methodes which are supported by all
; DESC : Gadgets. 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  
; VERSION  :  0.1    Brainstorming Version
; COMPILER :  Purebasic
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 

;} 
;{ TODO: 
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "..\Modules\PbFw_Module_PbFw.pb"   ; PbFw:: FrameWork control Module
XIncludeFile "PbFw_Class_OOP.pb"                ; OOP::  FrameWork BaseClass

DeclareModule clsGadgetBase ; clsGadgetBase
  EnableExplicit
  
  ; Input the BasceClassName here! Attention do not add ;comments after BaseClassName. PB don't like this in Macros
  Macro BaseClass
    OOP
  EndMacro
   
  Interface IClass Extends OOP::IClass ; create the Interface
    DataValue.i()
    DataValue_(NewDataValue.i)
    
    Disable.i()
    Disable_(disable=#False)
    
    Font.i()
    Font_(NewFontID)
    
    Group.i()                   ; for groups of Gadgets, maybe all Gadgets on a Window or Container
    Group_(NewGroup)
    
    Height.i()

    Hide.i()
    Hide_(hide=#False)
    
    hPB.i()         ; the PureBasic handle #Gadget
    hOS.i()         ; the Operatin System handle #GadgetID
    
    Move(x.i, y.i, Mode = #PB_Absolute)
    Resize(x.i, y.i, width.i, height.i)
    SetFocus()
    
    Tag.s()                     ; to store user defined data
    Tag_(NewTag$)

    Type.i()
    Width.i()

    X.i()
    Y.i()
    
  EndInterface
  
  Structure TThis Extends OOP::TThis   ; Structure for the Instance Data
    hPB.i         ; PureBasic handle (#Gadget)
    disable.i
    hide.i      
    init.i  
    Group.i
    Tag.s
  EndStructure
  
  Declare.i New()
  Declare.i _Inherit_VTable(*Destination_VTable) 
  
  Global NewMap mapGadget()
EndDeclareModule

Module clsGadgetBase
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)   ; Lists the Module in the ModuleList (for statistics)
 
  Global Dim VTable.a(SizeOf(IClass)-1)   ; create VTable with the Size of the Interface 
  BaseClass::_Inherit_VTable(@VTable())    ; Inherit the Methodes of BaseClass (copy BaseClass::VTable => VTable)
 
  ; Macro to write MethodeAdress into VTable. Use it after EndProcedure : AsMethode(MethodeName) 
  Macro AsMethode(MethodeName)
    PokeI(@VTable() + OffsetOf(IClass\MethodeName()), @MethodeName()) 
  EndMacro
  ; use Overwrite if the MethodeName is different from ProcedureName
  Macro Overwrite(MethodeName, ProcedureName)
    PokeI(@VTable() + OffsetOf(IClass\MethodeName()), @ProcedureName()) 
  EndMacro
    
  ;- ---------------------------------------------------------------------
  ;- Public Methodes 
  ;- ---------------------------------------------------------------------
  
  Procedure DataValue_(*This.TThis, NewDataValue)
  ; ============================================================================
  ; NAME: DataValue
  ; DESC: Set the Data-Value value of the Gadget! Data is a user defined 
  ; DESC: value which can be used at all Gadgests
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(DataValue): The new DataValue
  ; RET: -
  ; ============================================================================    
    If *This\init
      SetGadgetData(*This\hPB, NewDataValue)  
    EndIf   
  EndProcedure : AsMethode(DataValue_)
  
  Procedure.i DataValue(*This.TThis)
    If *This\init      
      ProcedureReturn GetGadgetData(*This\hPB)
    EndIf 
  EndProcedure : AsMethode(DataValue)
  
  Procedure Disable_(*This.TThis, disable=#False)
  ; ============================================================================
  ; NAME: Gadget_Type
  ; DESC: Get the Gadget Type
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(disable): #False = EnableGadget, #True = DisableGadget
  ; RET.i: 
  ; ============================================================================
    Protected oldDisable
    
    If *This\init 
      With *This
        oldDisable = \disable
        If disable <> oldDisable
          \disable = disable
          HideGadget(\hPB, disable)
        EndIf
        ProcedureReturn oldDisable
      EndWith
    EndIf
  EndProcedure : AsMethode(Disable_)
  
  Procedure.i Disable(*This.TThis)
     ProcedureReturn *This\disable
  EndProcedure : AsMethode(Disable)
  
  Procedure Font_(*This.TThis, NewFontID)
  ; ============================================================================
  ; NAME: Font
  ; DESC: Set Gadget Font
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(NewFontID): The new FontID
  ; RET: -
  ; ============================================================================
     
    If *This\init
      With *This
          SetGadgetFont(\hPB, NewFontID)
      EndWith 
    EndIf
  EndProcedure : AsMethode(Font_)
 
  Procedure.i Font(*This.TThis)
    If *This\init
      GetGadgetFont(*This\hPB)
    EndIf
  EndProcedure : AsMethode(Font)
  
  Procedure Group_(*This.TThis, NewGroup)
  ; ============================================================================
  ; NAME: Group
  ; DESC: Set the Group value! Group can be used to indentify groups of Gadgets
  ; DESC: maybe all Gadgets on an Window or Containter
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(NewGroup): The new Group
  ; RET.i: the previous Group
  ; ============================================================================
    Protected oldGroup
    
    If *This\init
      With *This
        oldGroup = \Group
        If oldGroup <> NewGroup
          \Group  = NewGroup
       EndIf      
      EndWith
    EndIf   
    ProcedureReturn oldGroup
  EndProcedure : AsMethode(Group_)
  
  Procedure.i Group(*This.TThis)
    If *This\init      
      ProcedureReturn *This\Group
    EndIf 
  EndProcedure : AsMethode(Group)

  Procedure.i Height(*This.TThis, Mode = #PB_Gadget_ActualSize)
  ; ============================================================================
  ; NAME: Height
  ; DESC: Get the Gadget Height  according to Mode
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(Mode): #PB_Gadget_ActualSize, #PB_Gadget_RequiredSize   
  ; RET.i : Gadget Height
  ; ============================================================================
    If *This\init
      ProcedureReturn GadgetHeight(*This\hPB, Mode)
    EndIf
  EndProcedure : AsMethode(Height)
  
  Procedure Hide_(*This.TThis, hide=#False)
  ; ============================================================================
  ; NAME: Hide
  ; DESC: Set Gadget Hide
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(hide): #False = hide Gadget, #True = show Gadget
  ; RET.i: the previous hide state
  ; ============================================================================
    Protected oldhide
    
    If *This\init
      With *This
        oldhide = \hide
        If hide <> oldhide
          \hide = hide
          HideGadget(\hPB, hide)
        EndIf
        ProcedureReturn oldhide
      EndWith
    EndIf
  EndProcedure : AsMethode(Hide_)
  
  Procedure.i Hide(*This.TThis)     ; Get Hide State
    ProcedureReturn *This\hide
  EndProcedure : AsMethode(Hide)    

  
  Procedure.i hPB(*This.TThis)     ; PureBasic handle #Gadget
  ; ============================================================================
  ; NAME: hPB
  ; DESC: Get the PureBasic handle for the Gadget (#Gadget)
  ; VAR(*This.TThis) : Instance pointer
  ; RET.i : Gadget PureBasic handle
  ; ============================================================================
    If *This\init 
      ProcedureReturn *This\hPB
    EndIf
  EndProcedure : AsMethode(hPB)
  
  Procedure.i hOS(*This.TThis)     ; Operating System handle # GadgetID
  ; ============================================================================
  ; NAME: hOS
  ; DESC: Get the OS handle for the Gadget (GadgetID), under Windows it's hwnd
  ; VAR(*This.TThis) : Instance pointer
  ; RET.i : Gadget Operating System handle (hwnd)
  ; ============================================================================
    If *This\init 
      ProcedureReturn GadgetID(*This\hPB)
    EndIf
  EndProcedure : AsMethode(hOS)
  
  Procedure Move(*This.TThis, x.i, y.i, Mode = #PB_Absolute)
  ; ============================================================================
  ; NAME: Move
  ; DESC: Move the Gadget to a new x,y postion. Abolute or realtive
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(x): x position [Pixel], or #PB_Ignore to skip this parameter
  ; VAR(y): y position [Pixel], or #PB_Ignore to skip this parameter
  ; VAR(Mode): #PB_Absolute or #PB_Relative
  ; RET : -
  ; ============================================================================
         
    If *This\init
      With *This
        If Mode = #PB_Relative
          x + GadgetX(\hPB)
          y + GadgetY(\hPB)
        EndIf     
        ResizeGadget(\hPB, x, y, #PB_Ignore, #PB_Ignore)
      EndWith           
    EndIf 
  EndProcedure : AsMethode(Move)      
  
  Procedure Resize(*This.TThis, x.i, y.i, width.i, height.i)
  ; ============================================================================
  ; NAME: Move
  ; DESC: Move the Gadget to a new x,y postion. Abolute or realtive!
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(x): x position [Pixel], or #PB_Ignore to skip this parameter
  ; VAR(y): y position [Pixel], or #PB_Ignore to skip this parameter
  ; VAR(width): width  [Pixel], or #PB_Ignore to skip this parameter
  ; VAR(width): height [Pixel], or #PB_Ignore to skip this parameter
  ; VAR(Mode): #PB_Absolute or #PB_Relative
  ; RET : -
  ; ============================================================================
    If *This\init
      With *This
        ResizeGadget(\hPB, x, y, width, height)
      EndWith      
    EndIf 
  EndProcedure : AsMethode(Resize)
  
  Procedure SetFocus(*This.TThis)
  ; ============================================================================
  ; NAME: SetFocus
  ; DESC: Set the Focus to the Gadget. Make it the active Gadget
  ; VAR(*This.TThis) : Instance pointer
  ; RET.i : Type, #PB_GadgetType_ [Button .. Web], see PB-Help; >0 if it's a Gadget
  ; ============================================================================
    If *This\init
      SetActiveGadget(*This\hPB)
    EndIf 
  EndProcedure    
  
  Procedure Tag_(*This.TThis, NewTag$)
  ; ============================================================================
  ; NAME: Tag
  ; DESC: Set the Tag string! Tag can be used to store user information.
  ; DESC: It's like in VisualBasic where you can use a Tag-String!
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(NewTag$): The new Tag-String
  ; ============================================================================
    If *This\init
      *This\Tag  = NewTag$
    EndIf
  EndProcedure : AsMethode(Tag_)

  Procedure.s Tag(*This.TThis)
    If *This\init
      ProcedureReturn *This\Tag 
    EndIf 
  EndProcedure : AsMethode(Tag)
  
  Procedure.i Type(*This.TThis)
  ; ============================================================================
  ; NAME: Gadget_Type
  ; DESC: Get the Gadget Type
  ; VAR(*This.TThis) : Instance pointer
  ; RET.i : Type, #PB_GadgetType_ [Button .. Web], see PB-Help; >0 if it's a Gadget
  ; ============================================================================
    If *This\init 
      ProcedureReturn GadgetType(*This\hPB)
    EndIf
  EndProcedure : AsMethode(Type)

  Procedure.i Width(*This.TThis, Mode = #PB_Gadget_ActualSize)
  ; ============================================================================
  ; NAME: Width
  ; DESC: Get the Gadget Width  according to Mode
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(Mode): #PB_Gadget_ActualSize, #PB_Gadget_RequiredSize   
  ; RET.i : Gadget Width
  ; ============================================================================
    If *This\init
      ProcedureReturn GadgetWidth(*This\hPB, Mode)
    EndIf
  EndProcedure : AsMethode(Width)

  Procedure.i X(*This.TThis, Mode = #PB_Gadget_ContainerCoordinate)
  ; ============================================================================
  ; NAME: X
  ; DESC: Get the X-coordinate according to Mode
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(Mode): #PB_Gadget_ContainerCoordinate, #PB_Gadget_WindowCoordinate, #PB_Gadget_ScreenCoordinate    
  ; RET.i : X-coordinate
  ; ============================================================================
    If *This\init
      ProcedureReturn GadgetX(*This\hPB, Mode)
    EndIf  
  EndProcedure : AsMethode(X)
  
  Procedure.i Y(*This.TThis, Mode = #PB_Gadget_ContainerCoordinate)
  ; ============================================================================
  ; NAME: Y
  ; DESC: Get the Y-coordinate according to Mode
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(Mode): #PB_Gadget_[ContainerCoordinate, WindowCoordinate, ScreenCoordinate]
  ; RET.i : Y-coordinate
  ; ============================================================================
    If *This\init
      ProcedureReturn GadgetY(*This\hPB, Mode)
    EndIf 
  EndProcedure : AsMethode(Y)

  Procedure.i MyRelease(*This.TThis)
  ; ======================================================================
  ; NAME: MyRelease()
  ; DESC: Decrement the ReferenceCounter! Destroy the object?
  ; DESC: If we do Multithreading and the object is referenced by more than 1
  ; DESC: Thread, only the reference counter will be decremented. 
  ; DESC: If it is the last reference to the object it will be destroyed.
  ; DESC: This is the normal way for single threaded programms were we have
  ; DESC: only 1 reference!  
  ; VAR(*This.TThis): Pointer to the instance data
  ; RET.i: Value of reference counter
  ; ======================================================================
    
    If *This
      If OOP::Release(*This) = 0   ; first call the BaseClass::Relase, it returns the RefCounter
        DeleteMapElement(mapGadget(),Str(*This))
      EndIf
    EndIf
    
   EndProcedure : Overwrite(Release, MyRelease)

  ;- ---------------------------------------------------------------------
  ;- Public Procedures 
  ;- ---------------------------------------------------------------------     
  
  Procedure New() 
  ; ======================================================================
  ; NAME: New  
  ; DESC: Create a New Instance of the ClassObject
  ; DESC: Call it: *myObj=MyClassModul::NEW()  
  ; RET.i: *This; The Pointer to the allocated memory or 0 if if
  ;        could not get the memory from OS
  ; ======================================================================
    
    Protected *obj.TThis
    
    ; Step 1: Allocate memory for the instance data; Structure TThis
    *obj = AllocateStructure(TThis)
    
    ; Step 2: If we got a valid pointer to the structure then create standard values
    If *obj
      *obj\VTable = @VTable()             ; Pointer to the virtual Methode Table
      *obj\Mutex = CreateMutex()          ; Mutex to prevent the RefCounter, needed for MultiThread referenced objects 
      *obj\cntRef = 1                     ; Reference counter
      
      mapGadget(Str(*obj)) = *obj         ; AddGadget to Map
      
      ; If you use a NEW() Functionw with Paramenters, add further code hier     
    EndIf
        
    ProcedureReturn *obj
  EndProcedure

  Procedure.i _Inherit_VTable(*Destination_VTable) 
  ; ======================================================================
  ; NAME: Inherit_VTable 
  ; DESC: This Procedure has to be called from the derivate class to copy
  ; DESC: the VTable of the BaseClass into the derivate class!
  ; DESC: This is the inheritance of the BaseClass-Methods
  ; VAR(*Destination_VTable): Pointer to destination VTable
  ; RET.i: Bytes copied
  ; ======================================================================
    
    ProcedureReturn OOP::_CopyVTable(@VTable(), *Destination_VTable, SizeOf(IClass))
  EndProcedure

EndModule

;- ----------------------------------------------------------------------
;- Test Code 
;- ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  UseModule clsGadgetBase
  
  Define *obj1.IClass = New()
  
  DisableExplicit
CompilerEndIf

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 14
; Folding = ------
; Optimizer
; CPU = 5