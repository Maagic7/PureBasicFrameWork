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
; 2024/01/06: S.Maag : added Assert macro and Procedure from PB forum
;                      http://www.purebasic.fr/english/viewtopic.php?f=12&t=50842
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
  
  Enumeration EExceptions 0
    #PbFw_DBG_Err_Unknown
    #PbFw_DBG_Err_PointerIsNull              ; 1
    #PbFw_DBG_Err_IdenticalPointers          ; if 2 identical pointers are not allowd
    #PbFw_DBG_Err_ObjectNotExist
    #PbFw_DBG_Err_DrawingNotStarted
    #PbFw_DBG_Err_VectorDrawingNotStarted
    #PbFw_DBG_Err_IsNotImage
    #PbFw_DBG_Err_IsNotGadget
    
    ; ------------------------------------------------------------------------------
    #PbFw_DBG_Err_ModulSpecific        ;  !Last one! From here starts the ModulSpecificError
  EndEnumeration
  
  #PbFw_DBG_ProcedureReturn_Error = #Null
  
  Declare.i ListProcedureCall(ModuleName.s, ProcedureName.s)
 
  Declare Exception(ModuleName.s, FunctionName.s, ExeptionType, *Text.String=0)
  Declare ErrorHandler()
  
  
  Macro mac_CheckPointer(ptr, ret=0)
    If Not ptr
      DBG::Exception(#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_PointerIsNull) 
      ProcedureReturn ret
    EndIf 
  EndMacro
  
  Macro mac_CheckPointer2(ptr1, ptr2, ProcRet=0)
    If (Not ptr1) Or (Not ptr2)
      DBG::Exception(#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_PointerIsNull) 
      ProcedureReturn ProcRet
    EndIf 
  EndMacro
  
  Macro mac_CheckPointer3(ptr1, ptr2, ptr3, ProcRet=0)
    If (Not ptr1) Or (Not ptr2) Or (Not ptr3)
      DBG::Exception(#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_PointerIsNull) 
      ProcedureReturn ProcRet
   EndIf 
 EndMacro
 
  Macro mac_CheckPointer4(ptr1, ptr2, ptr3, ptr4, ProcRet=0)
    If (Not ptr1) Or (Not ptr2) Or (Not ptr3) Or (Not ptr4)
      DBG::Exception(#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_PointerIsNull) 
      ProcedureReturn ProcRet
   EndIf 
  EndMacro

  Macro mac_Check_2PointerIdenticalException(ptr1, ptr2, ProcRet=0)
    If ptr1 = ptr2
      DBG::Exception((#PB_Compiler_Module, #PB_Compiler_Procedure, DBG::#PbFw_DBG_IdenticalPointers)       
      ProcedureReturn ProcRet
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
  
  Macro mDQ
    "
  EndMacro
  
  ; ----------------------------------------------------------------------------------------
  ; ----MACRO sDebug pour afficher sur une seule ligne NOM DE VARIABLE ET VALEUR
  ; (Pour les constantes utiliser sDebug SANS #   
  ; UTILISATION: sDebug (variable [, "commentaire"])
  ; https://www.purebasic.fr/french/viewtopic.php?t=18841

  Macro sDebug (sDpar1, sDpar2="") 
    ; from French Forum
    ; https://www.purebasic.fr/french/viewtopic.php?t=18841
  ; UTILISATION: sDebug (variable [, "commentaire"])
    
        CompilerIf #PB_Compiler_Debugger ; Debugger activated
        
            CompilerIf Defined(sDpar1, #PB_Constant) ;UNE CONSTANTE?  (ici sans dièse) 
            Debug "#"+mDQ#sDpar1#mDQ + ": " + #sDpar1  +" "+sDpar2
            
            CompilerElse ;UNE VARIABLE (Les Str(...) ne semblent plus utiles...(?)
              
              CompilerSelect TypeOf(sDpar1)
                  
                ; Integer Types
                CompilerCase #PB_Byte 
                  Debug  mDQ#sDpar1#mDQ + ".b: " +Str(sDpar1) +" "+sDpar2
                CompilerCase #PB_Word
                  Debug  mDQ#sDpar1#mDQ + ".w: " +Str(sDpar1) +" "+sDpar2
                CompilerCase #PB_Long 
                  Debug  mDQ#sDpar1#mDQ + ".l: " +Str(sDpar1) +" "+sDpar2
                CompilerCase #PB_Integer 
                  Debug  mDQ#sDpar1#mDQ + ".i: " +Str(sDpar1) +" "+sDpar2
                
                ; Char Types
                CompilerCase #PB_Ascii  
                  Debug  mDQ#sDpar1#mDQ + ".a: " +StrU(sDpar1) +" "+sDpar2
                CompilerCase #PB_Character    
                  Debug  mDQ#sDpar1#mDQ + ".c: " +StrU(sDpar1) +" "+sDpar2
                CompilerCase #PB_Unicode     
                  Debug  mDQ#sDpar1#mDQ + ".u: " +StrU(sDpar1) +" "+sDpar2
                
                ; Float Types
                CompilerCase #PB_Float 
                  Debug  mDQ#sDpar1#mDQ + ".f: " +StrF(sDpar1) +" "+sDpar2
                CompilerCase #PB_Double
                  Debug  mDQ#sDpar1#mDQ + ".d: " +StrD(sDpar1) +" "+sDpar2
                
                ; ----STRING 
                CompilerCase #PB_String
                  Debug  mDQ#sDpar1#mDQ + ".s: " + sDpar1 +" "+sDpar2
                
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
  
  ; if #ASSERT_ENABLED is not defined in your main program, automagically defaults to #ASSERT_ENABLED = 0
  CompilerIf Not Defined(ASSERT_ENABLED, #PB_Constant) ; = 0
     #PbFw_DBG_ASSERT_ENABLED = 0
  CompilerEndIf

  #PbFw_DBG_ASSERT_TITLE$ = "ASSERT"
  
  Global NewMap AssertFlags.i()
    
  CompilerIf #PbFw_DBG_ASSERT_ENABLED

    Declare.i _AssertProc(Exp$, File$, Proc$, iLine, Msg$)
    
    ; ASSERT: http://www.purebasic.fr/english/viewtopic.php?f=12&t=50842
    ; [DESC]
    ; Check the validity of the expression and if not true stops the execution showing a warning window.
    ;
    ; [INPUT]
    ; exp : The expression to be checked.
    ; msg: An optional message to show if the assert fails.
    ;
    ; [NOTES]
    ; Asserts can be used both in the debugged program and the final exe, and are inserted in the code only if #ASSERT_ENABLED = 1
    ;
    ; If a check fails the user has three options:
    ; - continue
    ; - continue skipping further notifications by this specific assert
    ; - stop the program at the offending line through a call to CallDebugger() or End it if the debugger is disabled.
    ;
    ; You can't use string literals in the expression to be evaluated, shouldn't be a problem in practice.
    ; You can't use more than one ASSERT for each line.
  
    Macro ASSERT(exp, msg = "")    
       If Not (exp)
        If DBG::_AssertProc(DBG::mDQ#exp#DBG::mDQ, #PB_Compiler_File, #PB_Compiler_Procedure, #PB_Compiler_Line, msg)
             CallDebugger
        EndIf
      EndIf
     EndMacro
    
  CompilerElse
    
    Macro ASSERT (exp, msg = "")       
    EndMacro
    
  CompilerEndIf
  
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
      Case #PbFw_DBG_Err_ObjectNotExist
        txt = "#PbFw_DBG_ObjectNotExist"
        
      Case #PbFw_DBG_Err_VectorDrawingNotStarted
         txt = "VectorDrawingNotStarted"
       
    EndSelect
    
    ProcedureReturn txt
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Modul Public Functions
  ;- ----------------------------------------------------------------------
  
  Procedure ListProcedureCall(ModuleName.s, ProcedureName.s)
    
    
  EndProcedure
     

  Procedure Exception(ModuleName.s, FunctionName.s, ExceptionType, *Text.String=0)
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
  
  Procedure.i _AssertProc (Exp$, File$, Proc$, iLine, Msg$)
  ; ======================================================================
  ; NAME: _AssertProc
  ; DESC: This is called when Exp$ is false (see ASSERT macro)
  ; DESC: It opens a Assert Window!
  ; VAR(Exp$): The Expression
  ; VAR(File$): The PureBasic File Name
  ; VAR(Proc$): The Procedure Name
  ; VAR(iLine): The Line Number in the File
  ; VAR(Msg$): The Message
  ; RET : -
  ; ======================================================================
   
    Protected Text$, StopText$, Title$
    Protected iRetCode, iEvent, nWin
    Protected nBtnContinue, nBtnSkipAsserts, nBtnStop, nEditor, nLabel
    Protected nFontEdit, nFontTitle, flgExit
    Protected w = 400, h = 240
   
     iRetCode = 0
     
    If FindMapElement(AssertFlags(), File$ + "_" + Str(iLine)) = 0
      ; This is better than
      ; If AssertFlags(File$ + "_" + Str(iLine)) = 0
      ; because it does not allocate data if an ASSERT has not been disabled.
      
      Title$ = #PbFw_DBG_ASSERT_TITLE$
      
      CompilerIf #PB_Compiler_Debugger = 1
         StopText$ = " Call Debugger "
         Title$ + " (debug)"
      CompilerElse
         StopText$ = " End "
      CompilerEndIf
      
      If Proc$ : Proc$ + "()" : EndIf
      
      nWin = OpenWindow(#PB_Any, 0, 0, w, h, Title$, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
      
      If nWin
        StickyWindow(nWin, 1)
        
        nFontTitle = LoadFont(#PB_Any, "Arial", 16, #PB_Font_Bold)
        
        CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
          nFontEdit = LoadFont(#PB_Any, "Courier New", 12) ; suggested by WilliamL
        CompilerElse
          nFontEdit = LoadFont(#PB_Any, "Courier New", 9)   
        CompilerEndIf                 
        
        nLabel= TextGadget(#PB_Any, 10, 8, w-20, 20, "ASSERT FAILED !", #PB_Text_Center)
        
        nEditor = EditorGadget(#PB_Any, 10, 40, w-20, 155, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
        nBtnContinue = ButtonGadget(#PB_Any, 10, h-35, 120, 30, " Continue ")
        nBtnSkipAsserts = ButtonGadget(#PB_Any, 140, h-35, 120, 30, " Disable this ASSERT ")
        nBtnStop = ButtonGadget(#PB_Any, 270, h-35, 120, 30, StopText$, #PB_Button_Default)
                  
        Text$ = "Expr: " + Exp$ + #LF$ + #LF$
        Text$ + "File: " + GetFilePart(File$) + #LF$ +#LF$         
        Text$ + "Proc: " + Proc$ + #LF$ + #LF$ 
        Text$ + "Line: " + Str(iLine)   
        
        If Msg$
          Text$ + #LF$ + #LF$ + Msg$
        EndIf
        
        SetGadgetFont(nLabel, FontID(nFontTitle))
        SetGadgetFont(nEditor, FontID(nFontEdit))
        SetGadgetText(nEditor, Text$)
         
        Repeat
          iEvent = WaitWindowEvent()
            
          Select iEvent
            Case #PB_Event_CloseWindow
              iRetCode = 0
              flgExit = 1               
                
            Case #PB_Event_Gadget
              
            Select EventGadget()
              Case nBtnContinue
                iRetCode = 0
                flgExit = 1
                
              Case nBtnSkipAsserts
                AssertFlags(File$ + "_" + Str(iLine)) = 1
                  iRetCode = 0
                  flgExit = 1
                  
              Case nBtnStop
                CompilerIf #PB_Compiler_Debugger = 1
                  iRetCode = 1
                  flgExit = 1
                CompilerElse
                  End
                CompilerEndIf                                           
            EndSelect
              
          EndSelect       
        Until flgExit = 1
         
        CloseWindow(nWin)
         
        FreeFont(nFontTitle)
        FreeFont(nFontEdit)       
      EndIf         
    EndIf
   
    ProcedureReturn iRetCode
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

; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 94
; FirstLine = 68
; Folding = -----
; Optimizer
; CPU = 5