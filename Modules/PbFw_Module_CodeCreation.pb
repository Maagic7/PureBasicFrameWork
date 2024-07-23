﻿; ===========================================================================
;  FILE : PbFw_Module_CodeCreation.pb
;  NAME : Module Code Creation CC::
;  DESC : Helper Functions for Creating PB-Code and copy it to ClipBoard
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/11/17
; VERSION  :  0.1 untested Developer Version
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
;- ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_String.pb"       ; STR::      String Module

DeclareModule CC
  
  EnableExplicit
  
  EnumerationBinary 0
    #PbFw_CC_NoShift         
    #PbFw_CC_SHL_BEFORE     ; Shift the Code 1 Tab$ left, before adding line
    #PbFw_CC_SHR_BEFORE     ; Shift the Code 1 Tab$ right, before adding line
    #PbFw_CC_SHL_AFTER      ; Shift the Code 1 Tab$ left, after adding line
    #PbFw_CC_SHR_AFTER      ; Shift the Code 1 Tab$ right, after adding line
  EndEnumeration
  
  ; Test to make 'End-Commands easier! Use automatic shift
  Enumeration EEndCommand
    #PbFw_CC_CMD_Else             
    #PbFw_CC_CMD_EndIf   
    #PbFw_CC_CMD_EndMacro   
    #PbFw_CC_CMD_EndProcedure     
    #PbFw_CC_CMD_EndSelect        
    #PbFw_CC_CMD_EndStructure 
    #PbFw_CC_CMD_EndStructureUnion
    #PbFw_CC_CMD_EndWith          
    #PbFw_CC_CMD_ForEver          
    #PbFw_CC_CMD_Wend             
  EndEnumeration
  
  Declare ClrShift()          ; Clear the ShiftLevel
  Declare SHR(Levels=1)       ; Set the CodeShiftLevel No of Levels right
  Declare SHL(Levels=1)       ; Set the CodeShiftLevel No of Levels left
  Declare ADD(sCodeLine.s="", Shift = #PbFw_CC_NoShift) ; Add a line To the CodeList
  Declare PRC(ProcName$, Paramters$, ReturnAs$=".i")   ; Add a Procedure definition to the CodeList
  Declare ADE(EnumCmd = #PbFw_CC_CMD_EndIf)            ; Easy way to add an 'End'-Command with automatic shifting

  Declare ClearCode()         ; Clear all the code in lstCodeList()
  Declare CopyToClipBoard()   ; Copy the Code stored in the List lstCodeLine To the ClipBoard
 
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
      
      ; Test SHIFT_BEFOR adding line
      If Shift & #PbFw_CC_SHL_BEFORE
        SHL()  
      ElseIf Shift  & #PbFw_CC_SHR_BEFORE
        SHR()  
      EndIf
             
      AddElement(lstCodeLine())
      If mem_ShiftLevel > 0
        lstCodeLine() = mem_Tab$ + sCodeLine
      Else
        lstCodeLine() = sCodeLine
      EndIf
      
      ; Test SHIFT_AFTER adding line
      If Shift & #PbFw_CC_SHL_AFTER
        SHL()  
      ElseIf Shift  & #PbFw_CC_SHR_AFTER
        SHR()  
      EndIf

    Else
      AddElement(lstCodeLine())  
    EndIf
  EndProcedure
  
  Procedure PRC(ProcName$, Paramters$, ReturnAs$=".i")
  ; ============================================================================
  ; NAME: PRC
  ; DESC: Add a Procedure definition to the CodeList
  ; VAR(ProcName$): The ProcedureName
  ; VAR(Paramters$): The Parameters-String withour brackets
  ; VAR(ReturnAs$): The Procedure Return Type ".i", ".f", etc.
  ; RET : -
  ; ============================================================================
    Protected code$ = "Procedure"
    code$ + ReturnAs$ + " " + ProcName$ + "(" + Paramters$ + ")"
    ADD(code$)
  EndProcedure
  
  Procedure ADE(EnumCmd = #PbFw_CC_CMD_EndIf)
  ; ============================================================================
  ; NAME: ADE
  ; DESC: Add a 'End'-Command with automatic shifting
  ; RET : -
  ; ============================================================================
    Protected sText.s
    Protected ShiftMode.i = #PbFw_CC_SHL_BEFORE
    
    Select EnumCmd
      Case #PbFw_CC_CMD_Else             
        sText = "Else"
        ; at 'Else' we have to shift left before and shift right after
        ShiftMode + #PbFw_CC_SHR_AFTER
        
      Case #PbFw_CC_CMD_EndIf            
         sText = "EndIf"
         
       Case #PbFw_CC_CMD_EndMacro            
         sText = "EndIf"
      
      Case #PbFw_CC_CMD_EndProcedure     
        sText = "EndProcedure"
        
      Case #PbFw_CC_CMD_EndSelect        
        sText = "EndSelect"
        
      Case #PbFw_CC_CMD_EndStructure 
        sText = "EndStructure"
        
      Case #PbFw_CC_CMD_EndStructureUnion
        sText = "EndStructureUnion"
        
      Case #PbFw_CC_CMD_EndWith          
        sText = "EndWith"
        
      Case #PbFw_CC_CMD_ForEver          
        sText = "ForEver"
        
      Case #PbFw_CC_CMD_Wend             
        sText = "Wend"
        
      Default
        sText = "Error! CodeCreation ADE(): unknown 'EndCommand'"
    EndSelect
    
    ADD(sText, ShiftMode)
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
    
    ClearClipboard()
    
    ; use the JoinList Function from String Module to produce a singel String 
    ; from all Code-Lines
    SetClipboardText(STR::JoinList(lstCodeLine(), #CRLF$)) 
    
  EndProcedure
   
EndModule


; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 202
; FirstLine = 180
; Folding = ---
; Optimizer
; CPU = 5