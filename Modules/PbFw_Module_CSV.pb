; ===========================================================================
;  FILE : Module_CSV.pb
;  NAME : Module CSV [CSV::]
;  DESC : .CSB-File Functions 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/15
; VERSION  :  0.0   Brainstormin Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PX.pb"           ; PX::       Purebasic Extentions
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_FileSystem.pb"   ; FS::       File Functions
XIncludeFile "PbFw_Module_Buffer.pb"       ; BUF::      Buffer handling
XIncludeFile "PbFw_Module_String.pb"       ; STR::      String Functions
XIncludeFile "PbFw_Module_IsNumeric.pb"    ; IsNum::    IsNumeric String functions


DeclareModule CSV
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  Structure hCSV    ; CSV Handle Structure
    sFileName.s
    cDelimiter.c    ; Delimiter Character ';' ','
    xHeaderExist.i  ; a Header exists
    FileNo.i        ; if File is open, the File Number
  EndStructure 
  
EndDeclareModule

Module CSV
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
    
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
 
EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule CSV
  
CompilerEndIf

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 24
; Folding = -
; Optimizer
; CPU = 5