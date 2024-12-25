; ===========================================================================
; FILE : PbFw_Module_OOP.pb
; NAME : PureBasic Framework : Module object oriented programing [OOP::]
; DESC : Contains the BasceClass function for object oriented programing.
; DESC : Inheritance is supported! Overwriting Methodes is supported!
; DESC : Because OOP is not natively supported by PB, we have to do some jobs
; DESC : manually. 
; DESC : We have to create the VTable (virtual Methode Table), and we
; DESC : have to fill it with the correct Procedure addresses for our
; DESC : Methodes.
; DESC : For inheritance we have to copy the BasceClass VTable into the
; DESC : the VTable of the SubClass.
; DESC : The VTable is handled as an Array of Byte because this can be
; DESC : created automatically in the correct size of the Interface.
; DESC : The usual Methode of VTable in the DataSection can't be used
; DESC : with inheritance, because at design time we do not know the
; DESC : exact size of VTable because the length of VTable depends 
; DESC : on the level of inheritance!
; DESC :
; DESC : There are several good implementations of OOP for PureBasic
; DESC : like the very comfortable one from the english forum
; DESC : http://www.purebasic.fr/english/viewtopic.php?f=12&t=64305
; DESC : but it hides the "how to do" in Multilevel Macro calls
; DESC : and it use some tricky Macros. It is very hard to understand 
; DESC : in detail.
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/08/05
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
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
XIncludeFile "..\Modules\PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule OOP
  
  EnableExplicit
      
  ; Every User-Class has to integerate this Interface
  ; here we have to use the real InterfaceName. With Macro MyInterface, the IDE-Intellisense don't know the Interface
  Interface IClass Extends IUnknown ; create the Interface based on IUnknown; the COM-Basic-Interface
  EndInterface
  
  Structure TThis   ; Structure for the Instance Data
    ; iUnknown
    *VTable     ; Pointer to VirtalMethodeTable (Addresslist of Methodes declared in the Interface)
    cntRef.i    ; Object reference counter
    Mutex.i     ; Object Mutex! Only if object used by different Treads! It shows that the Object is in operation by a Thread!
  EndStructure
          
  Macro mac_Procedure_Clone()
    Procedure.i Clone(*This.TThis)
      Protected *retVal.TThis   
      If *This
        *retVal = New()
        If *retVal
          CopyStructure(*This, *retVal, TThis)
        EndIf  
      EndIf
      ProcedureReturn *retVal
    EndProcedure
  EndMacro
  
  Declare.i Release(*This.TThis)    ; make Release() Public, so it's possible to call over Interface or direct call
  
  Declare.i _CopyVTable(*Source, *Destination, ByteSize)
  
  Declare.i _Inherit_VTable(*Destination_VTable) 
  ; ======================================================================
  ; NAME: Inherit_VTable 
  ; DESC: This Procedure has to be called from the derivate class to copy
  ; DESC: the VTable of the OOP BaseClass into the derivate class!
  ; DESC: It will be converted into a CopyMemory command
  ; DESC: CopyMemory(OOP::@VTable(), *Destination_VTable, SizeOf(IClass)
  ; DESC: This is the inheritance of the BaseClass-Methods
  ; ======================================================================

EndDeclareModule

Module OOP
   
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Global Dim VTable.a(SizeOf(IClass)-1) ; create VTable with the Size of the Interface 

  ; Macro to write MethodeAdress into VTable. Use it in this way: EndProcedure : AsMethode(MethodeName) 
  Macro AsMethode(MethodeName)
    PokeI(@VTable() + OffsetOf(IClass\MethodeName()), @MethodeName()) 
  EndMacro

  ; ======================================================================
  ;  Implement the Methodes of iUnknown
  ; ======================================================================
  
  ; IUnknow is the BaseInterface of Windows-COM-Objects
  
   Procedure.i QueryInterface(*This.TThis, *riid, *addr)
  ; ======================================================================
  ; NAME: QueryInterface()
  ; DESC: IUnknown\QueryInterface()
  ; VAR(*This.TThis): Pointer To the instance Data
  ; VAR(*riid):
  ; VAR(*addr):
  ; RET.i:  $80004002 ; (#E_NOINTERFACE)
  ; ======================================================================
    ProcedureReturn $80004002 ; (#E_NOINTERFACE)
  EndProcedure : AsMethode(QueryInterface)
  ;PokeI(@VTable() + OffsetOf(IOOP\QueryInterface()), @QueryInterface()) ; Write Methode Address into VTable

  Procedure.i AddRef(*This.TThis)
  ; ======================================================================
  ; NAME: AddRef()
  ; DESC: IUnknown\AddRef()
  ; DESC: Increments the ReferenceCounter! This is used for Multithreading
  ; DESC: if 1 ObjectInstance is referenced from 2 different Threads.
  ; VAR(*This.TThis): Pointer to the instance data
  ; RET.i: Value of reference counter
  ; ======================================================================

    If *This
      LockMutex(*This\Mutex)
      *This\cntRef + 1
      UnlockMutex(*This\Mutex)
      ProcedureReturn *This\cntRef
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure : AsMethode(AddRef)
  ;PokeI(@VTable() + OffsetOf(IOOP\AddRef()), @AddRef()) ; Write Methode Address into VTable

  Procedure.i Release(*This.TThis)
  ; ======================================================================
  ; NAME: Release()
  ; DESC: IUnknown\Release()
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
      With *This
        LockMutex(\Mutex)
        If \cntRef = 1  ; If it is the last reference THEN delete the object
          ; 
          ; Maybe further operations here for cleanup
          ; ---
          ; Dispose(*this)
          ; ---
          FreeMutex(\Mutex)    ; Delete the Mutes
          FreeStructure(*This)    ; Relase the allocated memory; kill the instance
          
          ProcedureReturn 0
          
        Else
          \cntRef - 1 ; Decrement No of referenced threads
        EndIf
        UnlockMutex(\Mutex)
        ProcedureReturn \cntRef
      EndWith
    Else
       ProcedureReturn *This\cntRef
    EndIf
  EndProcedure : AsMethode(Release)
  ; PokeI(@VTable() + OffsetOf(IOOP\Release()), @Release()) ; Write Methodes Address into VTable

  Procedure.i _CopyVTable(*Source, *Destination, ByteSize)
  ; ======================================================================
  ; NAME: CopyVTable()
  ; DESC: Copy a VTable to an other! From BaseClass to DerivateClass
  ; DESC: This function will be called by Inherit_VTable in each Class.
  ; VAR(*Source): Pointer to the Source-VTable, form BaseClass
  ; VAR(*Destination): Pointer to the Destination-VTable, from DerivateClass
  ; VAR(ByteSize): Bytes to Copy; SizeOf(BaseClass-Interface)  
  ; RET.i: Value of reference counter
  ; ======================================================================
   If *Source And *Destination And ByteSize
      CopyMemory(*Source, *Destination, ByteSize)
      ProcedureReturn ByteSize
    EndIf
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i _Inherit_VTable(*Destination_VTable) 
  ; ======================================================================
  ; NAME: Inherit_VTable 
  ; DESC: This Procedure has to be called from the derivate class to copy
  ; DESC: the VTable of the OOP BaseClass into the derivate class!
  ; DESC: This is the inheritance of the BaseClass-Methods
  ; VAR(*Destination_VTable): Pointer to destination VTable
  ; RET.i: Bytes copied
  ; ======================================================================
    
    ProcedureReturn _CopyVTable(@VTable(), *Destination_VTable, SizeOf(IClass))
  EndProcedure

  
;   Debug "VTable Adress of IUnknown"
;   Debug @VTable()
;   Debug @VTable(0)
  
EndModule

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 211
; FirstLine = 65
; Folding = 9-
; Optimizer
; CPU = 5