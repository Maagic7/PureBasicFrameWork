; ===========================================================================
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
XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_PB.pb"          ; PB::      Purebasic Extention Module

DeclareModule CC
  
  EnableExplicit
  
  EnumerationBinary 0
    #CC_NoShift         
    #CC_SHL_BEFORE     ; Shift the Code 1 Tab$ left, before adding line
    #CC_SHR_BEFORE     ; Shift the Code 1 Tab$ right, before adding line
    #CC_SHL_AFTER      ; Shift the Code 1 Tab$ left, after adding line
    #CC_SHR_AFTER      ; Shift the Code 1 Tab$ right, after adding line
  EndEnumeration
  
  ; Test to make 'End-Commands easier! Use automatic shift
  Enumeration EEndCommand
    #CC_CMD_Else  
    #CC_CMD_EndEnumeration  
    #CC_CMD_EndIf   
    #CC_CMD_EndMacro   
    #CC_CMD_EndProcedure     
    #CC_CMD_EndSelect        
    #CC_CMD_EndStructure 
    #CC_CMD_EndStructureUnion
    #CC_CMD_EndWith          
    #CC_CMD_ForEver          
    #CC_CMD_Wend             
  EndEnumeration
  
  Macro DQ
  "
  EndMacro
  
  Macro QuoteIt(TextToQuote)
    CC::DQ#TextToQuote#CC::DQ
  EndMacro
  
  Declare ClrShift()          ; Clear the ShiftLevel
  Declare SHR(Levels=1)       ; Set the CodeShiftLevel No of Levels right
  Declare SHL(Levels=1)       ; Set the CodeShiftLevel No of Levels left
  Declare ADD(sCodeLine.s="", Shift = #CC_NoShift) ; Add a line To the CodeList
  Declare PRC(ProcName$, Paramters$, ReturnAs$=".i")   ; Add a Procedure definition to the CodeList
  Declare ADE(EnumCmd = #CC_CMD_EndIf)            ; Easy way to add an 'End'-Command with automatic shifting

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
  
  Procedure ADD(sCodeLine.s="", Shift = #CC_NoShift)
  ; ============================================================================
  ; NAME: ADD
  ; DESC: Add a line to the CodeList
  ; VAR(sCodeLine.s): The CodeLine Text
  ; VAR(Shift): Shift the Code  #CC_SHL, #CC_NoShift, #CC_SHR 
  ; RET : -
  ; ============================================================================
    Protected I
    
    If sCodeLine
      
      ; Test SHIFT_BEFOR adding line
      If Shift & #CC_SHL_BEFORE
        SHL()  
      ElseIf Shift  & #CC_SHR_BEFORE
        SHR()  
      EndIf
             
      AddElement(lstCodeLine())
      If mem_ShiftLevel > 0
        lstCodeLine() = mem_Tab$ + sCodeLine
      Else
        lstCodeLine() = sCodeLine
      EndIf
      
      ; Test SHIFT_AFTER adding line
      If Shift & #CC_SHL_AFTER
        SHL()  
      ElseIf Shift  & #CC_SHR_AFTER
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
  
  Procedure ADE(EnumCmd = #CC_CMD_EndIf)
  ; ============================================================================
  ; NAME: ADE
  ; DESC: Add a 'End'-Command with automatic shifting
  ; RET : -
  ; ============================================================================
    Protected sText.s
    Protected ShiftMode.i = #CC_SHL_BEFORE
    
    Select EnumCmd
      Case #CC_CMD_Else             
        sText = "Else"
        ; at 'Else' we have to shift left before and shift right after
        ShiftMode + #CC_SHR_AFTER
        
      Case #CC_CMD_EndEnumeration           
         sText = "EndIf"
       
      Case #CC_CMD_EndIf            
         sText = "EndEnumeration"
         
       Case #CC_CMD_EndMacro            
         sText = "EndIf"
      
      Case #CC_CMD_EndProcedure     
        sText = "EndProcedure"
        
      Case #CC_CMD_EndSelect        
        sText = "EndSelect"
        
      Case #CC_CMD_EndStructure 
        sText = "EndStructure"
        
      Case #CC_CMD_EndStructureUnion
        sText = "EndStructureUnion"
        
      Case #CC_CMD_EndWith          
        sText = "EndWith"
        
      Case #CC_CMD_ForEver          
        sText = "ForEver"
        
      Case #CC_CMD_Wend             
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
    SetClipboardText(PB::JoinList(lstCodeLine(), #CRLF$))
    
    ; Protected txt.s  
    ; ForEach lstCodeLine()
    ;   txt + lstCodeLine() +   #CRLF$
    ;  Next
    ; SetClipboardText(txt)
  EndProcedure
   
EndModule

CompilerIf #PB_Compiler_IsMainFile
  Debug "----"
  Debug CC::QuoteIt(blablabla)  
CompilerEndIf

;- ----------------------------------------------------------------------
;- Templeates
;- ----------------------------------------------------------------------

;   Procedure CreateDataSection()
;     Protected txt.s
;     Protected I
;     UseModule CC
;     ClearCode()
;     #DQ = Chr(34)       ; DoubleQuotes
;     #SEP = ", "         ; Separator [,]
;     #DQS = #DQ + #SEP   ; DoubleQuotes + Separator [",]
;     
;     ADD("DataSection", #CC_SHR_AFTER)
;     ADD("MyData:")  
;     ADD(" ; Column1, Column2, Column3") ; Column Comments 
;     
;     For I = 0 To ArraySize(ary())
;       With ary(I)
;         txt = "Data.s "
;         txt + #DQ + Str(I) + #DQS
;         txt + #DQ + \Name + #DQS
;         txt + #DQ + \Value + #DQ
;          ADD(txt)
;       EndWith      
;     Next
;     
;     Add("EndDatasection", #CC_SHL_BEFORE)
;     
;     CopyToClipBoard()
;   EndProcedure


; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 310
; FirstLine = 238
; Folding = ---
; Optimizer
; CPU = 5