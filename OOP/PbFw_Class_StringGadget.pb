; ===========================================================================
; FILE : PbFw_Class_StringGadget.pb 
; NAME : PureBasic Framework: Class wrapper for String Gadget
; DESC : 
; DESC : 
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
XIncludeFile "PbFw_Class_GadgetBase.pb"         ; clsGadgetBase::  BaseClass for Gadgets

; individual Methodes to implement
; Color, Text, ToolTip, Attribute [#PB_String_MaximumLength]

DeclareModule clsStringGadget   ; String Gadget
  EnableExplicit
  
  Macro BaseClass
    clsGadgetBase
  EndMacro
  
  ; Interface IClass Extends BaseClass::IClass        ; create the Interface
  Interface IClass Extends clsGadgetBase::IClass      ; create the Interface, Intellisense needs real name, not BaseClass::     
    Color.l()
    Color_(NewColor.l)
    
    MaxInputLength.i()
    MaxInputLength_(NewMaxLength)

    Text.s()
    Text_(NewText$)
    
    ToolTip_(NewToolTip$)
  EndInterface
  
  ; Structure TThis Extends BaseClass::TThis   ; Structure for the Instance Data
  Structure TThis Extends clsGadgetBase::TThis   ; Structure for the Instance Data
  
  EndStructure
  
  Declare.i New()
  Declare.i Inherit_VTable(*Destination_VTable) 
 
EndDeclareModule

Module clsStringGadget
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)   ; Lists the Module in the ModuleList (for statistics)
 
  Global Dim VTable.a(SizeOf(IClass)-1)   ; create VTable with the Size of the Interface 
  BaseClass::Inherit_VTable(@VTable())    ; Inherit the Methodes of BaseClass (copy BaseClass::VTable => VTable)
 
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
  
  Procedure Color_(*This.TThis, NewColor.l, Type =#PB_Gadget_BackColor)   ; Set
  ; ============================================================================
  ; NAME: Color
  ; DESC: Set Gadget Color
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(NewColor.l): The new RGB-Color value
  ; VAR(Type): #PB_Gadget_[FrontColor, BackColor, LineColor]
  ; RET.i: the previous Color
  ; ============================================================================
    Protected oldColor
    
    If *This\init
      oldColor = GetGadgetColor(*This\hPB, Type)
      If oldColor <> NewColor
        SetGadgetColor(*This\hPB, Type, NewColor)
      EndIf
    EndIf
    ProcedureReturn oldColor
  EndProcedure : AsMethode(Color_)

  Procedure.l Color(*This.TThis, Type =#PB_Gadget_BackColor)           ; Get
    If *This\init
      ProcedureReturn GetGadgetColor(*This\hPB, Type)    
    EndIf
  EndProcedure : AsMethode(Color)
  
   ; MaxInputLength is the Implementation of the StringGadgets Attribute #PB_String_MaximumLength
  Procedure MaxInputLength_(*This.TThis, NewMaxLength)
  ; ============================================================================
  ; NAME: MaxInputLength
  ; DESC: Set the maximum length of the string input
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(NewMaxLength): The new maximum string input length
  ; RET: -
  ; ============================================================================
    If *This\init
       SetGadgetAttribute(*This\hPB, #PB_String_MaximumLength, NewMaxLength)
    EndIf    
  EndProcedure : AsMethode(MaxInputLength_)

  Procedure.i MaxInputLength(*This.TThis)
     If *This\init
       ProcedureReturn GetGadgetAttribute(*This\hPB, #PB_String_MaximumLength)
     EndIf
  EndProcedure : AsMethode(MaxInputLength)
  
  Procedure Text_(*This.TThis, NewText$)
  ; ============================================================================
  ; NAME: Text
  ; DESC: Set Gadget Text
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(NewText$): The new RGB-Color value
  ; RET: -
  ; ============================================================================
    If *This\init
      SetGadgetText(*This\hPB, NewText$)
    EndIf
  EndProcedure : AsMethode(Text_)
  
  Procedure.s Text(*This.TThis)
    If *This\init
      ProcedureReturn GetGadgetText(*This\hPB)
    EndIf
  EndProcedure : AsMethode(Text)
  
  Procedure ToolTip_(*This.TThis, NewToolTip$)
  ; ============================================================================
  ; NAME: ToolTip
  ; DESC: Set Gadget ToolTip
  ; VAR(*This.TThis) : Instance pointer
  ; VAR(NewToolTip$) : The new ToolTip
  ; RET: -
  ; ============================================================================
    If *This\init
      GadgetToolTip(*This\hPB, NewToolTip$)
    EndIf
  EndProcedure : AsMethode(Text_)
  
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
  
  Procedure.i Inherit_VTable(*Destination_VTable) 
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
  UseModule clsStringGadget
  
  
  Define *obj1.IClass = New()
  
  Debug *obj1\Font()
  DisableExplicit
CompilerEndIf

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 60
; Folding = ---
; Optimizer
; CPU = 5