; ===========================================================================
;  FILE: PbFw_Module_Template.pb
;  NAME: Module Template 
;  DESC: for creating new PbFw Modules
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/01/01
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
; 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
; XIncludeFile ""

DeclareModule Template
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------

 
EndDeclareModule


Module Template
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Procedure.i MyProc(Par.i)
  ; ============================================================================
  ; NAME: MyProc
  ; DESC: 
  ; VAR(Par.i) : 
  ; RET.i : 
  ; ============================================================================
    ProcedureReturn 0  
  EndProcedure
  
EndModule

;- ----------------------------------------------------------------------
;- Test Code
;  ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; UseModule 
  
  DisableExplicit
CompilerEndIf




; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 61
; Folding = --
; Optimizer
; CPU = 5