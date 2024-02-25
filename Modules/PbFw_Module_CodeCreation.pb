; ===========================================================================
;  FILE : PbFw_Module_CodeCreation.pb
;  NAME : Module Code Creation CC::
;  DESC : Helper Functions for Creating PB-Code and copy it to ClipBoard
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/11/17
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{
; 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;-  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule CC
  
  EnableExplicit
  
  #PbFw_CC_SHL = -1  ; Shift the Code 1 Tab$ left
  #PbFw_CC_NoShift = 0         
  #PbFw_CC_SHR = 1  ; Shift the Code 1 Tab§ right
  
  Declare ClrShift()
  Declare SHR(Levels=1)
  Declare SHL(Levels=1)
  Declare ADD(sCodeLine.s="", Shift = #PbFw_CC_NoShift)
  Declare ClearCode()
  Declare CopyToClipBoard()
 
EndDeclareModule

Module CC
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Global mem_ShiftLevel
  Global mem_Tab$
  
  Global NewList lstCodeLine.s()
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------

  Procedure ClrShift()
  ; ============================================================================
  ; NAME: ClrShift
  ; DESC: Clear the ShiftLevel
  ; DESC: Sets mem_ShiftLevel = 0 and mem_Tab$ =""
  ; RET.i: Old ShiftLevel 
  ; ============================================================================
    Protected mem
    mem = mem_ShiftLevel
    mem_Tab$ = ""
    mem_ShiftLevel = 0
    ProcedureReturn mem
  EndProcedure
    
  Procedure SHR(Levels=1)
  ; ============================================================================
  ; NAME: SHR
  ; DESC: Set the CodeShiftLevel No of Levels right
  ; VAR(Levels): No of Levels [Tab$] to Shift right 
  ; RET.i: Value of the actual ShiftLevel [0...n]
  ; ============================================================================   
    Protected I
    
    For I = 1 To Levels
      mem_ShiftLevel + 1
      mem_Tab$ + #TAB$
    Next
    ProcedureReturn mem_ShiftLevel
  EndProcedure
  
  Procedure.i SHL(Levels=1)
  ; ============================================================================
  ; NAME: SHL
  ; DESC: Set the CodeShiftLevel No of Levels left
  ; VAR(Levels): No of Levels [Tab$] to Shift Left 
  ; RET.i: Value of the actual ShiftLevel [0...n]
  ; ============================================================================
    Protected I
       
    mem_ShiftLevel - Levels
    If mem_ShiftLevel <0 
      mem_ShiftLevel = 0
    EndIf
    mem_Tab$=""
    For I = 1 To mem_ShiftLevel
      mem_Tab$ + #TAB$
    Next      
    ProcedureReturn mem_ShiftLevel
  EndProcedure
  
  Procedure ADD(sCodeLine.s="", Shift = #PbFw_CC_NoShift)
  ; ============================================================================
  ; NAME: ADD
  ; DESC: Add a line to the CodeList
  ; VAR(sCodeLine.s): The CodeLine Text
  ; VAR(Shift): Shift the Code  #PbFw_CC_SHL, #PbFw_CC_NoShift, #PbFw_CC_SHR 
  ; RET : -
  ; ============================================================================
    Protected I
    If sCodeLine
      Select Shift
        Case #PbFw_CC_SHL
          SHL()  
        Case #PbFw_CC_SHR
          SHR()    
      EndSelect
        
      AddElement(lstCodeLine())
      If mem_ShiftLevel > 0
        lstCodeLine() = mem_Tab$ + sCodeLine
      Else
        lstCodeLine() = sCodeLine
      EndIf
    Else
      AddElement(lstCodeLine())  
    EndIf
  EndProcedure
  
  Procedure ClearCode()
  ; ============================================================================
  ; NAME: ClearCode
  ; DESC: Clear all the code in lstCodeList()
  ; RET : -
  ; ============================================================================
    
    ClearList(lstCodeLine())  
  EndProcedure

  Procedure CopyToClipBoard()
  ; ============================================================================
  ; NAME: CopyToClipBoard
  ; DESC: Copy the Code stored in the List lstCodeLine to the ClipBoard   
  ; RET : -
  ; ============================================================================
    Protected txt.s
    
    ClearClipboard()
    
    ForEach lstCodeLine()
      txt = txt + lstCodeLine() + #CRLF$  
    Next
    
    SetClipboardText(txt)  
  EndProcedure
   
EndModule

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 69
; FirstLine = 33
; Folding = --
; Optimizer
; CPU = 5