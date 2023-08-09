; ===========================================================================
;  FILE : PbFw_Module_Debug.pb
;  NAME : Module Debug DBG::
;  DESC : Code for Debugging and Exception handling
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/28
; VERSION  :  0.1 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{
; 2023/02/18: S.Maag : added Macros for Check Pointers
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

; All files are already included in ECAD_Main.pb! 
; It's just to know which Include Files are necessary

; XIncludeFile ""

DeclareModule DBG
  
  #PbFw_DBG_ListProcedureCalls = #True
  
  Enumeration MyExceptions 1
    #PbFw_DBG_PointerIsNull              ; 1
    #PbFw_DBG_IdenticalPointers          ; if 2 identical pointers are not allowd
    #PbFw_DBG_ObjectNotExist
    #PbFw_DBG_VectorDrawingNotStarted
  EndEnumeration
  
  #PbFw_DBG_ProcedureReturn_Error = #Null
  
  Declare.i ListProcedureCall(ModuleName.s, ProcedureName.s)
 
  Declare Exception(ModuleName.s, FunctionName.s, ExeptionType)
  Declare ErrorHandler()
  
  
  Macro mac_CheckPointer(ptr)
    If Not ptr
      DBG::Exception(#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_PointerIsNull) 
      ProcedureReturn 
    EndIf 
  EndMacro
  
  Macro mac_CheckPointer2(ptr1, ptr2)
    If (Not ptr1) Or (Not ptr2)
      DBG::Exception(#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_PointerIsNull) 
      ProcedureReturn 
    EndIf 
  EndMacro
  
  Macro mac_CheckPointer3(ptr1, ptr2, ptr3)
    If (Not ptr1) Or (Not ptr2) Or (Not ptr3)
      DBG::Exception(#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_PointerIsNull) 
      ProcedureReturn 
   EndIf 
 EndMacro
 
  Macro mac_CheckPointer4(ptr1, ptr2, ptr3, ptr4)
    If (Not ptr1) Or (Not ptr2) Or (Not ptr3) Or (Not ptr4)
      DBG::Exception(#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_PointerIsNull) 
      ProcedureReturn 
   EndIf 
 EndMacro
  

  Macro mac_Check_2PointerIdenticalException(ptr1, ptr2)
    If ptr1 = ptr2
      DBG::Exception((#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_IdenticalPointers)       
      ProcedureReturn 
    EndIf 
  EndMacro
  
  Structure TProcedureCall
    ModuleName.s
    ProcedureName.s
  EndStructure
  
  Global NewList lstProcedureCall.TProcedureCall()
  
  Macro mac_ListProcedureCall()
    CompilerIf #EXC_ListProcedureCalls
      ListProcedureCall(#PB_Compiler_Module, #PB_Compiler_Procedure)  
    CompilerEndIf
  EndMacro
  
  ;----------------------------------------------------------------------------------------
;----MACRO sDebug pour afficher sur une seule ligne NOM DE VARIABLE ET VALEUR
; (Pour les constantes utiliser sDebug SANS #   
; UTILISATION: sDebug (variable [, "commentaire"])
; https://www.purebasic.fr/french/viewtopic.php?t=18841
Macro Quotes
  "
EndMacro

Macro sDebug (sDpar1, sDpar2="") 
  ; from French Forum
  ; https://www.purebasic.fr/french/viewtopic.php?t=18841
; UTILISATION: sDebug (variable [, "commentaire"])
  
      CompilerIf #PB_Compiler_Debugger ; Debugger activated
      
          CompilerIf Defined(sDpar1, #PB_Constant) ;UNE CONSTANTE?  (ici sans dièse) 
          Debug "#"+Quotes#sDpar1#Quotes + ": " + #sDpar1  +" "+sDpar2
          
          CompilerElse ;UNE VARIABLE (Les Str(...) ne semblent plus utiles...(?)
            
            CompilerSelect TypeOf(sDpar1)
                
              ; Integer Types
              CompilerCase #PB_Byte 
                Debug  Quotes#sDpar1#Quotes + ".b: " +Str(sDpar1) +" "+sDpar2
              CompilerCase #PB_Word
                Debug  Quotes#sDpar1#Quotes + ".w: " +Str(sDpar1) +" "+sDpar2
              CompilerCase #PB_Long 
                Debug  Quotes#sDpar1#Quotes + ".l: " +Str(sDpar1) +" "+sDpar2
              CompilerCase #PB_Integer 
                Debug  Quotes#sDpar1#Quotes + ".i: " +Str(sDpar1) +" "+sDpar2
              
              ; Char Types
              CompilerCase #PB_Ascii  
                Debug  Quotes#sDpar1#Quotes + ".a: " +StrU(sDpar1) +" "+sDpar2
              CompilerCase #PB_Character    
                Debug  Quotes#sDpar1#Quotes + ".c: " +StrU(sDpar1) +" "+sDpar2
              CompilerCase #PB_Unicode     
                Debug  Quotes#sDpar1#Quotes + ".u: " +StrU(sDpar1) +" "+sDpar2
              
              ; Float Types
              CompilerCase #PB_Float 
                Debug  Quotes#sDpar1#Quotes + ".f: " +StrF(sDpar1) +" "+sDpar2
              CompilerCase #PB_Double
                Debug  Quotes#sDpar1#Quotes + ".d: " +StrD(sDpar1) +" "+sDpar2
              
              ; ----STRING 
              CompilerCase #PB_String
                Debug  Quotes#sDpar1#Quotes + ".s: " + sDpar1 +" "+sDpar2
              
              ; ----AUTRE?
              CompilerDefault 
                CompilerError "Type unknown"
              CompilerEndSelect  
          CompilerEndIf;VARIABLE
      CompilerEndIf    ;debogueur actif
EndMacro               ;sDebug

; ;----------------------------------------------------------------------------------------
; ;exemples
; MaVariable= 10
; UneAutre$= "bla bla"
; machin.f= 2/3
; sDebug(MaVariable)                        ; MaVariable.i: 10 
; sDebug(UneAutre$, " j'dis ça j'dis rien") ;UneAutre$.s: bla bla  j'dis ça j'dis rien
; sDebug(machin)                            ;machin.f: 0.6666666865 
; ;----------------------------------------------------------------------------------------

EndDeclareModule


Module DBG
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  Structure TExceptionInfo
    TimeStamp.i
    ModuleName.s
    FunctionName.s
    ExceptionCode.i
  EndStructure
  
  ;- ----------------------------------------------------------------------
  ;- Modul internal Functions
  ;- ----------------------------------------------------------------------

  Procedure.s _CodeToString(Code)
  ; ======================================================================
  ; NAME: _CodeToString
  ; DESC: Returns the Text to a ExceptionCode
  ; VAR(Code): ExceptionCode
  ; RET : Exception Text
  ; ======================================================================
   Protected txt.s
    
    Select Code
      Case #PbFw_DBG_ObjectNotExist
        txt = "#PbFw_DBG_ObjectNotExist"
        
      Case #PbFw_DBG_VectorDrawingNotStarted
         txt = "VectorDrawingNotStarted"
       
    EndSelect
    
    ProcedureReturn txt
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Modul Public Functions
  ;- ----------------------------------------------------------------------
  
  Procedure ListProcedureCall(ModuleName.s, ProcedureName.s)
    
    
  EndProcedure
     

  Procedure Exception(ModuleName.s, FunctionName.s, ExceptionType)
  ; ======================================================================
  ; NAME: DBG::Exception
  ; DESC: The calling Procedure can use the Compiler Constants
  ; DESC: for ModuleName    : #PB_Compiler_Module
  ; DESC; for FunctionName  : #PB_Compiler_Procedure
  ; VAR(ModuleName): Module Name which caused the Exeption  
  ; VAR(FunctionName): Function Name which caused the Exeption
  ; RET : -
  ; ======================================================================
    
    Protected INFO.TExceptionInfo
    
    With INFO
      \Timestamp = 1
      \ModuleName = ModuleName
      \FunctionName = FunctionName
      \ExceptionCode = ExceptionType
    EndWith
    
    Select ExceptionType
        
    EndSelect
    
    MessageRequester("Purebasic Framework Pointer Exception dedected in", "Module : " + ModuleName + #CRLF$ + "Procedure : " + FunctionName + "()", #PB_MessageRequester_Error )
    
    ; !!! Write the Info in a Log-File
    
    ProcedureReturn ExceptionType  
  EndProcedure
  
  Procedure ErrorHandler()
  ; ======================================================================
  ; NAME: ErrorHandler
  ; DESC: Error Handler for .exe
  ; DESC: Shows some information about the Error 
  ; DESC: Use OnErrorCall(@DBG::ErrorHandler())
  ; DESC: to activate automatic Calls to ErrorHandler
  ; DESC: Code token from the PureBasic Help
  ; RET: -
  ; ======================================================================
    
    CompilerIf #PB_Compiler_Debugger = #False
      
    Protected ErrorMessage$
      
    ErrorMessage$ = "A program error was detected:" + Chr(13)
    ErrorMessage$ + Chr(13)
    ErrorMessage$ + "Error Message:   " + ErrorMessage()      + Chr(13)
    ErrorMessage$ + "Error Code:      " + Str(ErrorCode())    + Chr(13)
    ErrorMessage$ + "Code Address:    " + Str(ErrorAddress()) + Chr(13)
   
    If ErrorCode() = #PB_OnError_InvalidMemory
      ErrorMessage$ + "Target Address:  " + Str(ErrorTargetAddress()) + Chr(13)
    EndIf
   
    If ErrorLine() = -1
      ErrorMessage$ + "Sourcecode line: Enable OnError lines support to get code line information." + Chr(13)
    Else
      ErrorMessage$ + "Sourcecode line: " + Str(ErrorLine()) + Chr(13)
      ErrorMessage$ + "Sourcecode file: " + ErrorFile() + Chr(13)
    EndIf
   
    ErrorMessage$ + Chr(13)
    ErrorMessage$ + "Register content:" + Chr(13)
   
    CompilerSelect #PB_Compiler_Processor
      CompilerCase #PB_Processor_x86
        ErrorMessage$ + "EAX = " + Str(ErrorRegister(#PB_OnError_EAX)) + Chr(13)
        ErrorMessage$ + "EBX = " + Str(ErrorRegister(#PB_OnError_EBX)) + Chr(13)
        ErrorMessage$ + "ECX = " + Str(ErrorRegister(#PB_OnError_ECX)) + Chr(13)
        ErrorMessage$ + "EDX = " + Str(ErrorRegister(#PB_OnError_EDX)) + Chr(13)
        ErrorMessage$ + "EBP = " + Str(ErrorRegister(#PB_OnError_EBP)) + Chr(13)
        ErrorMessage$ + "ESI = " + Str(ErrorRegister(#PB_OnError_ESI)) + Chr(13)
        ErrorMessage$ + "EDI = " + Str(ErrorRegister(#PB_OnError_EDI)) + Chr(13)
        ErrorMessage$ + "ESP = " + Str(ErrorRegister(#PB_OnError_ESP)) + Chr(13)
   
      CompilerCase #PB_Processor_x64
        ErrorMessage$ + "RAX = " + Str(ErrorRegister(#PB_OnError_RAX)) + Chr(13)
        ErrorMessage$ + "RBX = " + Str(ErrorRegister(#PB_OnError_RBX)) + Chr(13)
        ErrorMessage$ + "RCX = " + Str(ErrorRegister(#PB_OnError_RCX)) + Chr(13)
        ErrorMessage$ + "RDX = " + Str(ErrorRegister(#PB_OnError_RDX)) + Chr(13)
        ErrorMessage$ + "RBP = " + Str(ErrorRegister(#PB_OnError_RBP)) + Chr(13)
        ErrorMessage$ + "RSI = " + Str(ErrorRegister(#PB_OnError_RSI)) + Chr(13)
        ErrorMessage$ + "RDI = " + Str(ErrorRegister(#PB_OnError_RDI)) + Chr(13)
        ErrorMessage$ + "RSP = " + Str(ErrorRegister(#PB_OnError_RSP)) + Chr(13)
        ErrorMessage$ + "Display of registers R8-R15 skipped."         + Chr(13)
   
    CompilerEndSelect
   
    MessageRequester("OnError example", ErrorMessage$)
    End
    
    CompilerElse
       ; CompilerError "The debugger must be turned OFF for this example"
    CompilerEndIf

  EndProcedure

EndModule


CompilerIf #PB_Compiler_IsMainFile
; ======================================================================
;   Mdoule TestCode  
; ======================================================================
  
  EnableExplicit
  
 ;   ; Setup the error handler.
;   ;
;   OnErrorCall(DBG::@ErrorHandler())
;    
;   ; Write to protected memory
;   ;
;   PokeS(123, "The quick brown fox jumped over the lazy dog.")
;    
;   ; Division by zero
;   ;
;   Define a
;   a = 1 / a
;    
;   ; Generate an error manually
;   ;
;   RaiseError(#PB_OnError_IllegalInstruction)
;    
;    
;   ; This should not be displayed
;   ;
;   MessageRequester("OnError example", "Execution finished normally.")
;   End

CompilerEndIf

DisableExplicit

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 20
; Folding = ----
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)