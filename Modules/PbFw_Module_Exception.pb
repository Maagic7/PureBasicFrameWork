; ===========================================================================
;  FILE : Module_Exception.pb
;  NAME : Module Exception
;  DESC : Code Exception handling
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/28
; VERSION  :  0.1
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;             
; ============================================================================

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
;- ----------------------------------------------------------------------

; All files are already included in ECAD_Main.pb! 
; It's just to know which Include Files are necessary

; XIncludeFile ""

DeclareModule Exception
  
  Enumeration MyExceptions 1
    #EXCEPTION_ObjectNotExist ; 1
    #EXCEPTION_VectorDrawingNotStarted
  EndEnumeration

  Declare Exception(ModuleName.s, FunctionName.s, ExeptionType)
EndDeclareModule


Module Exception
  
  EnableExplicit

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
      Case #EXCEPTION_ObjectNotExist
        txt = "#EXCEPTION_ObjectNotExist"
        
      Case #EXCEPTION_VectorDrawingNotStarted
         txt = "VectorDrawingNotStarted"
       
    EndSelect
    
    ProcedureReturn txt
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Modul Public Functions
  ;- ----------------------------------------------------------------------

  Procedure Exception(ModuleName.s, FunctionName.s, ExceptionType)
  ; ======================================================================
  ; NAME: Exception::Exception
  ; DESC: 
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
    
    ; !!! Write the Info in a Log-File
    
    ProcedureReturn ExceptionType  
  EndProcedure
  
  Procedure ErrorHandler()
  ; ======================================================================
  ; NAME: ErrorHandler
  ; DESC: Error Handler for .exe
  ; DESC: Shows some information about the Error 
  ; DESC: Use OnErrorCall(@Exception::ErrorHandler())
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

EnableExplicit

CompilerIf #PB_Compiler_IsMainFile
; ======================================================================
;   Mdoule TestCode  
; ======================================================================

  ; Setup the error handler.
  ;
  OnErrorCall(@Exception::ErrorHandler())
   
  ; Write to protected memory
  ;
  PokeS(123, "The quick brown fox jumped over the lazy dog.")
   
  ; Division by zero
  ;
  a = 0
  a = 1 / a
   
  ; Generate an error manually
  ;
  RaiseError(#PB_OnError_IllegalInstruction)
   
   
  ; This should not be displayed
  ;
  MessageRequester("OnError example", "Execution finished normally.")
  End

CompilerEndIf

DisableExplicit

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 9
; Folding = --
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)