; ===========================================================================
; FILE : PbFw_Class_Template.pb 
; NAME : PureBasic Framework: A Template for a Class Module
; DESC : 
; DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  
; VERSION  :  
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
XIncludeFile "PbFw_Class_OOP.pb"               ; OOP::  FrameWork BaseClass

DeclareModule clsTemplate ; clsText
  EnableExplicit
  
  ; Input the BasceClassName here! Attention do not add ;comments after BaseClassName. PB don't like this in Macros
  Macro BaseClass
    OOP
  EndMacro
  
  ; if you want to use the IDE intellisense, exchange BaseClass here with the real ClassName otherwise the IDE don't detected it!
  Interface IClass Extends BaseClass::IClass ; create the Interface
    Text.s()          ; Get
    Text_(NewText.s)  ; Set
  EndInterface
  
 ; if you want to use the IDE intellisense, exchange BaseClass here with the real ClassName otherwise the IDE don't detected it!
  Structure TThis Extends BaseClass::TThis   ; Structure for the Instance Data
    Text.s  
  EndStructure
  
  Declare.i New()
  Declare.i _Inherit_VTable(*Destination_VTable) 
 
EndDeclareModule

Module clsTemplate
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)   ; Lists the Module in the ModuleList (for statistics)
 
  Global Dim VTable(OOP::GetNoOfInterfaceEntries(IClass)-1) ; create VTable with the Size of the Interface 
  BaseClass::_Inherit_VTable(@VTable())   ; Inherit the Methodes of BaseClass (copy BaseClass::VTable => VTable)
 
;   ; Macro to write MethodeAdress into VTable. Use it after EndProcedure : AsMethode(MethodeName) 
;   Macro AsMethode(MethodeName)
;     PokeI(@VTable() + OffsetOf(IClass\MethodeName()), @MethodeName()) 
;   EndMacro
;   ; use Overwrite if the MethodeName is different from ProcedureName
;   Macro Overwrite(MethodeName, ProcedureName)
;     PokeI(@VTable() + OffsetOf(IClass\MethodeName()), @ProcedureName()) 
;   EndMacro
  
  ;- ---------------------------------------------------------------------
  ;- Public Methodes 
  ;- ---------------------------------------------------------------------

  Procedure.s Text(*This.TThis)
    ProcedureReturn  *This\Text
  EndProcedure : OOP::AsMethode(Text)
    
  Procedure Text_(*This.TThis, NewText.s)
    *This\Text = NewText  
  EndProcedure : OOP::AsMethode(Text_)
  
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
      
      ; If you use a NEW() Functionw with Paramenters, add further code hier     
    EndIf
        
    ProcedureReturn *obj
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
    
    ; call the _CopyVTable from Module OOP::
    ProcedureReturn OOP::_CopyVTable(@VTable(), *Destination_VTable, SizeOf(IClass))
  EndProcedure

EndModule

;- ----------------------------------------------------------------------
;- Test Code 
;- ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  UseModule clsTemplate
  
  Define *obj1.IClass = New()
  
  DisableExplicit
CompilerEndIf

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 72
; FirstLine = 18
; Folding = --
; Optimizer
; CPU = 5