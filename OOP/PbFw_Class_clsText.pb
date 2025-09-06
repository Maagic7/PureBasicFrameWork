; ===========================================================================
; FILE : PbFw_Class_clsText.pb 
; NAME : PureBasic Framework: Class clsText
; DESC : 
; DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/08/06
; VERSION  :  0.1 Brainstorming Version
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
XIncludeFile "..\Modules\PbFw_Module_PbFw.pb"   ; PbFw:: FrameWork control Module
XIncludeFile "PbFw_Class_OOP.pb"                ; OOP::  FrameWork BaseClass

DeclareModule clsText ; clsText
  EnableExplicit
  
  Macro BaseClass
    OOP
  EndMacro
   
  Interface IClass Extends BaseClass::IClass ; create the Interface
    Text.s()
    Text_(NewText$)
  EndInterface
  
  Structure TThis Extends BaseClass::TThis   ; Structure for the Instance Data
    Text.s  
    FontID.i
  EndStructure
  
  Declare.i New()
  Declare.i _Inherit_VTable(*Destination_VTable) 
 
EndDeclareModule

Module clsText
  
  EnableExplicit
  CompilerIf Defined(PbFw, #PB_Module)
    PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  CompilerEndIf 
 
  Global Dim VTable.i(SizeOf(IClass)/SizeOf(Integer)-1) ; create VTable with the Size of the Interface 
  BaseClass::_Inherit_VTable(@VTable())   ; Inherit the Methodes of BaseClass (copy BaseClass::VTable => VTable)
 
  Procedure.s Text(*This.TThis)
    ProcedureReturn  *This\Text
  EndProcedure : OOP::AsMethode(Text)
  
  Procedure Text_(*This.TThis, NewText.s)
    *This\Text = NewText  
  EndProcedure : OOP::AsMethode(Text_)
  
  Procedure.i Font(*This.TThis)
    ProcedureReturn *This\FontID
  EndProcedure : OOP::AsMethode(Font)

  Procedure Font_(*This.TThis, NewFontID.i)
    *This\FontID = NewFontID
  EndProcedure : OOP::AsMethode(Font_)
      
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
    
    ProcedureReturn OOP::_CopyVTable(@VTable(), *Destination_VTable, SizeOf(IClass))
  EndProcedure

EndModule


Define *obj1.clsText::IClass = clsText::New()

UseModule clsText
Define *obj2.IClass = New()

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 52
; FirstLine = 27
; Folding = ---
; Optimizer
; CPU = 5