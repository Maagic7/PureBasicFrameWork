; ======================================================================
; FILE: PbFW_OOP_BacsicMacros.pb
; DESC: Include-File with the standard Macros for OOP Classes in PureBasic
; DESC:
; DESC: Implements the Methods of iUnknown 
; DESC:    _QueryInterface(), _AddRef(), _Release()
; DESC: Impelemts : MyClass::New()
; DESC:             MyClass::GetInstanceCounter()
; DESC:
; DESC: Because this Methods are always identical for each class
; DESC: they are exported to Macros. So a change here changes
; DESC: the code of the standard Methods from all Classes
;
; AUTHOR   :  Stefan Maag
; DATE     :  2020/10/25
; VERSION  :  1.0
; COMPILER :  PureBasic 5.7(Windows - x32/x64)
; ======================================================================
; ChangeLog
;
; ======================================================================

; https://docs.microsoft.com/en-us/windows/win32/com/using-And-implementing-iunknown
; https://en.wikipedia.org/wiki/IUnknown
; I found the basics of iUnknown implementation in the PureBasic Forum and
; I added all the coments, integrity check, LastErroHandling, InstanceCounter
; I created Macros to implement the OOP-Procedures in a easy way in all typs of classes 


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

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------


Enumeration
  #OOP_Error_NoError = 0              ; no Error
  #OOP_Error_NullPointer = 1          ; the Pointer passed with *This = 0
  #OOP_Error_NotAnInstance =2         ; the Pointer passed with *This is not a Pointer of MyClass
  #OOP_Error_PointerNotReferenced =4  ; the Pointer passed with *This is a Pointer to a MyClassObject but it's
                                      ; not correctly referenced with the object. A Release is not possible! 
                                      ; Maybe *This contains a ShadwoCopy of a MyClassObject
EndEnumeration


Macro MACRO_OOP_iUnknown_QueryInterface()
; ======================================================================
; NAME : MACRO_OOP_iUnknown
; DESC : Implements the iUnknown.QueryInterface() Methode of a COM-Object
; ======================================================================

  ; QueryInterface : part of iUnknown, for PureBasic only it's not needed
  Procedure QueryInterface(*This.udtThis, *riid, *addr)
  ; ======================================================================
  ; NAME: QueryInterface  
  ; DESC: iUnknown.QueryInterface() of a COM-Object  
  ; RET : InterfaceType  
  ; ======================================================================
   
    ProcedureReturn $80004002 ; (#E_NOINTERFACE)
  EndProcedure
EndMacro

Macro MACRO_OOP_iUnknown_AddRef() ; iUnknown.AddRef()
; ======================================================================
; NAME : MACRO_OOP_iUnknown_AddRef
; DESC : Implements the iUnknown.AddRef() Methode of a COM-Object
; ======================================================================
  
  Procedure AddRef(*This.udtThis)
  ; ======================================================================
  ; NAME: AddRef  
  ; DESC: iUnknown.AddRef() of a COM-Object  
  ; DESC: Increments the ReferenceCounter! This is used if you do Multithreading
  ; DESC: and access 1 ObjectInstance from 2 different Threads
  ; DESC: in VB6/VBA we can't to this because it is single threading only!
  ; DESC: in PureBasic we can use Multitherading with language integrated
  ; DESC: command CreateThread() 
  ; RET : 0 if *This is referenced; *This if it is not referenced
  ;       call MyClass::GetLastError() to get information why!  
  ; ======================================================================
    
    If CheckPointerIntegrity(*This) ; if Pointer is a valid Pointer to correct referenced Object
           
      LockMutex(*This\objMutex)
      *This\cntRef + 1
      UnlockMutex(*This\objMutex)
      ProcedureReturn 0   ; If reference is added
    Else
      ProcedureReturn *This      
    EndIf
   ; Returns 0 if correctly added otherwise the original value of *This
   EndProcedure
EndMacro

Macro MACRO_OOP_iUnknown_Release(MyInstanceCounter) ; iUnknown.Release()
; ======================================================================
; NAME : MACRO_OOP_iUnknown_Release
; DESC : Implements the iUnknown.Release() Methode of a COM-Object
; ======================================================================

  Procedure.i Release(*This.udtThis)
  ; ======================================================================
  ; NAME: Release
  ; DESC: Decrement the ReferenceCounter and destroy the object if *This
  ; DESC: was the last referenced Pointer to the Object.
  ; DESC: (More references to an Object is only for multi threading when
  ; DESC: the object is referenced by more than 1 thread)
  ; RET:  Returns 0 if the pointer *This is correctly released
  ;       Returns *This, if the pointer *This is not released => Error   
  ;       call MyClass::GetLastError() to get information why!  
  ;  
  ;       in your SourceCode   
  ;       call   : *MyObj = Release(*MyObj)
  ;                 If *MyObj ; if *MyObj<>0, the Object isn't released 
  ;                   MyError = MyClassModul::GetLastError()  
  ;                   !DoErrorHandling!
  ;                 EndIf  
  ;       or call: If Release(*MyObj)=0 THEN 
  ;                   *MyObj=0 
  ;                Else
  ;                   MyError = MyClassModul::GetLastError()  
  ;                   !DoErroHandling!  
  ;                EndIf
  ; ======================================================================
    
    If CheckPointerIntegrity(*This) ; if Pointer is a valid Pointer to correct referenced Object
      LockMutex(*This\objMutex)
      If *This\cntRef = 1  ; If it is the last reference THEN delete the object
        ; 
        ; Maybe further operations here for cleanup
        ; ---
        ; Dispose(*this)
        ; ---
        FreeMutex(*This\objMutex)    ; Delete the Mutes
        FreeStructure(*This)    ; Relase the allocated memory; kill the instance
        
        MyInstanceCounter = MyInstanceCounter - 1  ; We killed 1 instance => NoOfInstancesAlive-1
        
      Else
        *This\cntRef - 1 ; Decrement No of referenced threads
      EndIf
      UnlockMutex(*This\objMutex)
      
      ProcedureReturn 0     ; Return 0 if *This is released correctly
    Else
      ProcedureReturn *This
    EndIf
    ; Returns 0 if correctly released otherwise the original value of *This
    
    ; to release *MyObj and set *MyObj = 0; call
    ; *MyObj = Release(*MyObj)
    ; If *MyObj 
    ;   MessageRequester ("Error", "*MyObj not released", #PB_MessageRequester_Ok)
    ; Endif
  EndProcedure
  
EndMacro

Macro MACRO_OOP_New(MyInstanceCounter)
; ======================================================================
; NAME : MACRO_Class_New
; DESC : Implements the Procedure New() to create a new Instance
; ======================================================================
  
  Procedure New() 
  ; ======================================================================
  ; NAME: New  
  ; DESC: Creates a New Instance of the ClassObject
  ; RET : Returns the Pointer to the allocated memory or 0 if if
  ;       could not get the memory from OS
  ;       call: *myObj=MyClassModul::NEW()  
  ; ======================================================================
    
    Protected *obj.udtThis
    
    ; Step 1: Allocate the memory for the data structure udtThis
    *obj = AllocateStructure(udtThis)
    
    ; Step 2: If we got a valid pointer to the structure then create standard values
    If *obj
      *obj\vTable = ?VirtualMethodeTable  ; Pointer to the Methode Table. See DataSection
      *obj\objMutex = CreateMutex()       ; Mutex to prevent the RefCounter, needed for MultiThread referenced objects 
      *obj\cntRef = 1                     ; Reference counter
      *obj\ptrObj = *obj                  ; save the pointer to the structure in the structure. This if for integrity check!
      ; Eventuelle weitere Zuweisungen. Zum Beipiel eine New-Funktion mit Parametern
      
      MyInstanceCounter = MyInstanceCounter + 1  ; No of instances alive
    EndIf
    
    ; check the pointer integrity of the new generated Object and set the
    ; LastError variable. Here a error is nearly impossible because we
    ; just created the Object and set the correct values in the DataStructure.
    ; Only if the OS did not allocate the memory, the pointer is not valid!
    CheckPointerIntegrity(*obj) 
    
    ProcedureReturn *obj
  EndProcedure
EndMacro

Macro MACRO_OOP_GetInstanceCounter(MyInstanceCounter)
; ======================================================================
; NAME: MACRO_OOP_GetInstanceCounter
; DESC: Implements: Procedure GetInstanceCounter()
; ======================================================================

 Procedure.i GetInstanceCounter()
 ; ======================================================================
 ; NAME: GetInstanceCounter
 ; DESC: It is a MyClassModul Public Procedure. It's not part of the
 ; DESC: MyClass Interface    
 ; DESC: Call the Procedure with: MyClassModul::GetInstanceCounter()  
 ; DESC: The InstanceCounter returns the number of existing instances 
 ; ======================================================================
    ProcedureReturn MyInstanceCounter
  EndProcedure
EndMacro

Macro MACRO_OOP_ProcedureBody_CheckPointerIntegrity(LastError)
; ======================================================================
; NAME: MACRO_Procedure_CheckPointerIntegrity
; DESC: Implements: Procedure CheckPointerIntegrity()
; DESC: Because the PB IDE has Problems with displaying the Procedure help
; DESC: it is better to implement only the Procedure Body in the MACRO
; DESC: and the Procedure Header directly in the Class Modul
; ======================================================================
  
 ; Procedure.i CheckPointerIntegrity(*This.udtThis)
  ; ======================================================================
  ; NAME: CheckPointerIntegrity
  ; DESC: It is a private Procededure of MyClassModul. It is not reachable
  ; DESC: from Code outside of MyClassModul  
  ; DESC: It checks the integrity of the passed Pointer *This
  ; DESC: and sets the LastError variable. See Enumeration #OOP_Error_ 
  ; DESC: To be a valid Pointer to a MyClass Instance *This must be <>0
  ; DESC: *This\vTable must contain the correct Address of our 
  ; DESC: VirtualMethode Table stored in \vTable
  ; DESC: \ptrObj must contain same address as *This, otherwise it's
  ; DESC: a correct Memory Structure of MyClass but not a correct 
  ; DESC: referenced Object (maybe a ShadowCopy of a MyClassObject and
  ; DESC: it has to be destroyed in individual source code)  
  ; ======================================================================
    Protected RET.i
    
    RET = #False
    
    ; Let's do pointer integrity check!
    ; If *This points to a correct instance of MyClass, *This\vTable must contain
    ; the correct Address of our 'VirtualMethodeTable:' in the DataSection. Otherwise
    ; it is anything else but not an instance of MyClass.
    ; Further we stored the original referenced pointer in *This\ptrObj
    ; If *This is a correct referenced Object, *This and *This\ptrObj must have
    ; the same value (Address). Otherwise it is not the orignally referenced Object.
    ; It might be a copy (ShadowCopy) of the original instance.
    ; Under this ciurcumstances we should not Release it. Our Software might crash later,
    ; because we destroyed the memory of an other referenced Object which is still referenced.
    
    If *This  ; if *This is a valid Pointer
      If *This\vTable = ?VirtualMethodeTable ; check IsInstanceOf("MyClass")
        If *This = *This\ptrObj              ; check integrity of original reference returned from New()
          RET = #True
          LastError = #OOP_Error_NoError  
        Else
          LastError = #OOP_Error_PointerNotReferenced
        EndIf
      Else
          LastError = #OOP_Error_NotAnInstance
      EndIf
    Else
          LastError = #OOP_Error_NullPointer
    EndIf
    
    ProcedureReturn RET
 ; EndProcedure
EndMacro

; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 115
; Folding = --
; Optimizer
; EnableXP
; CPU = 5