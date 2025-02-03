; ===========================================================================
;  FILE : PbFw_Module_RPN.pb
;  NAME : Module RPN Calculator Emulation [RPN::]
;  DESC : RPN "Reverse polish notation" calculator functions
;  DESC : For emulating a RPN Calculator or to process 'compiled' RPN programs
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2025/01/06
; VERSION  :  0.1 Brainstorming Version
; COMPILER :  PureBasic 6.0 and higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
;
; SOURCES : Reverse polish notation: https://www.youtube.com/watch?v=LQ-iW8jm6Mk
; ===========================================================================
; ChangeLog: 
;{ 
; 2025/01/17 S.Maag : changed from the first very simple Register definition
;                     of A1, A2, M to Register-Stacks, what is necessary
;                     to calculate formulas converted/compiled to RPN Syntax
;}
;{ TODO:
;}
; ===========================================================================

;- --------------------------------------------------
;- Include Files
;  --------------------------------------------------

;XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile ""

DeclareModule RPN   ; reverse polish notation
  EnableExplicit
  
  Enumeration ERPN_FUNCTION 0
    ; Fuctions without Parameter value
    #RPN_CLRALL
    #RPN_D_LD         ; LOAD
    #RPN_D_SAV        ; SAV 
    
    #RPN_D_ADD
    #RPN_D_SUB
    
    #RPN_D_MUL
    #RPN_D_DIV
    
    #RPN_D_SIN
    #RPN_D_COS
    #RPN_D_TAN
    #RPN_D_COT
    
    #RPN_D_SQ         ; Square : x²
    #RPN_D_CUB        ; Load Cubic  : x³
    #RPN_D_SQRT       ; SquareRoot
    #RPN_D_EXP        ; Exponent
        
    ; Memory Functions
    #RPN_D_MCLR       ; Clear Memory
    #RPN_D_MADD       ; Add to Memory   
    #RPN_D_MSUB       ; Sub from Memory
    #RPN_D_MRET       ; Return Memory to A1
    
    ; last Function
    #RPN_LAST  
  EndEnumeration
  
  ; this is one Operation for the RPN Processor. An operation consists always of 2 values: the ProcPointer of the RPN_Function and a Pointer to the Value processed
  Structure TRPN_PROG_ELEMENT
    *pProc
    *pValue.Double
  EndStructure 
  
  Declare GetRpnProcPointer(ProcNo = #RPN_CLRALL)
  
  Declare.i CallRPN(RpnFctNo = #RPN_CLRALL, *value.Double=0)
  Declare.d GetResult()
  Declare.d RunRpnProg(Array RPN_PROC.TRPN_PROG_ELEMENT(1), NoOfElements.i=#PB_Default)
  
EndDeclareModule

Module RPN
  
  EnableExplicit
  
  ; Priority-Level   |     Operato
  ; -----------------+---------------------------
  ;      8 (high)    |         ~, - (negativ)
  ;      7           |      <<, >>, %, !
  ;      6           |         |, &
  ;      5           |         *, /
  ;      4           |         +, - (Substraktion)
  ;      3           | >, >=, =>, <, <=, =<, =, <>
  ;      2           |          Not
  ;      1 (lo)      |      And, Or, XOr

  ; RPN Processor Register/Memory
  ; ----------
  ; RD[]            ; Double value Register Stack
  ; RI[]            ; Integer value Register Stack
  ; RC[]            ; Complex value Register Stack
  ; pRD             ; Double Register Pointer
  ; pRI             ; Integer Register Pointer
  ; pRC             ; Complex Register Pointer
  ; MD              ; Memory Register Double
  ; MI              ; Memory Register Integer
  ; MC              ; Memory Register Complex
  ; ----------
  
  ; For downgrowing Stack
  ;   NextPointer - 1
  ;   PreviousPointer + 1
  
  #RPN_StackMax  = %00011111          ; 5 Bit = 31  ; only full Bits (2^n -1)
  #RPN_StackSize = #RPN_StackMax +1   ; 32 Registers 0..31
  #RPN_StackNext = -1                 ; -1 because of downgrowing Stack
  
  Macro mac_StackNext(StackPointer)
    (StackPointer + #RPN_StackNext) & #RPN_StackMax
  EndMacro
  
  Macro mac_StackPrevious(StackPointer)
    (StackPointer - #RPN_StackNext) & #RPN_StackMax  
  EndMacro
  
  ; TODO! exchange it later with Module Complex
  Structure TComplex            ; Complex Value in kartesian coordinates
    re.d
    im.d
  EndStructure

  Structure TRpnCompiler
    OP.i[255]                   ; Operation Stack for compiling formulas to RPN Syntax 
    pOP.i                       ; Pointer Operation Register Stack
  EndStructure
    
  Structure TRpnCpu
    RD.d[#RPN_StackSize]        ; Double  value Register Stack
    RI.i[#RPN_StackSize]        ; Integer value Register Stack
    RC.TComplex[#RPN_StackSize] ; Complex value Register Stack (For future complex calculations
    
    MD.d                        ; Memory Register Double value 
    MI.i                        ; Memory Register Integer value 
    MC.TComplex                 ; Memory Register Complex value 
    
    pRD.i                       ; StackPointer Double  Register Stack
    pRI.i                       ; StackPointer Integer Register Stack
    pRC.i                       ; StackPointer Complex Register Stack
  EndStructure
    
  Global RPN.TRpnCpu
  
  Global Dim RPN_ProcPtr.i(#RPN_LAST)   ; the Array with the Pointers to all RPN_Functions
  
  ; This is the general Prototype function for calling any RPN_Function
  ; We same Prototype for all RPN_Functions, so we do not need any IF or SELECT statment to process
  ; compiled RPN programms. Any RPN Command in a compiled program consist of to values:
  ;   *pProc "Pointer to the RPN_Function" 
  ;   *pValue "Pointer to the Value as Double -> see the TRPN_PROG_ELEMENT Stuct
  ; A compiled RPN program is only an Array or a List of Pointers
  Prototype InvokeUpnFkt(*value.Double)
  Global InvokeUpnFkt.InvokeUpnFkt
  
  Global _RpnDummy.Double
  
  ;- ----------------------------------------
  ;- Public
  ;- ----------------------------------------
  
  Procedure.i GetRpnProcPointer(ProcNo = #RPN_CLRALL)
  
    ProcedureReturn RPN_ProcPtr(ProcNo)  
  EndProcedure
  
  Procedure CallRPN(RpnFctNo = #RPN_CLRALL, *value.Double=0)
    
    If *value = 0
      *value = _RpnDummy
    EndIf
    
    InvokeUpnFkt = RPN_ProcPtr(RpnFctNo)
    InvokeUpnFkt(*value)

  EndProcedure
  
  Procedure.d GetResult()
    ProcedureReturn RPN\RD[1]
  EndProcedure
  
  Procedure.d RunRpnProg(Array RPN_PROC.TRPN_PROG_ELEMENT(1), NoOfElements.i=#PB_Default)
    ; process a RPN Program of multiple operations stored in an Array
    Protected res.d, I, N
    
    If NoOfElements = #PB_Default   ; #PB_Default = -1
      N = ArraySize(RPN_PROC())
    ElseIf NoOfElements > (ArraySize(RPN_PROC()) + 1)
      N = ArraySize(RPN_PROC())
    Else
      n = NoOfElements - 1
    EndIf
    
    For I = 0 To N
      InvokeUpnFkt = RPN_PROC(I)\pProc
      InvokeUpnFkt(RPN_PROC(I)\pValue)
    Next
 
    ProcedureReturn RPN\RD[1]
  EndProcedure

  ;- ----------------------------------------
  ;- Private
  ;- ----------------------------------------
  
  Macro mac_DebugProc()
    Debug #PB_Compiler_Procedure
  EndMacro
  
  Macro mac_DebugProcWithPara(Para)
    Debug #PB_Compiler_Procedure + " : " + Para
  EndMacro
   
  Procedure CLRALL(*dummy)          ; Clear All : Akku1/2 and Mem
    Protected I
    
    mac_DebugProc()
    With RPN
      For I = 0 To #RPN_StackMax
        \RD[I] = 0
        \RI[I] = 0
        \RC[I]\re = 0
        \RC[I]\im = 0
      Next
      
      ; Downgrowing Stack starts at upper end
      \pRD = #RPN_StackSize   
      \pRI = #RPN_StackSize
      \pRC = #RPN_StackSize
      ; Memory Registers
      \MD = 0
      \MI = 0
      \MC\re = 0 :  \MC\im = 0      
    EndWith   
  EndProcedure
  RPN_ProcPtr(#RPN_CLRALL) = @CLRALL()
  
  Procedure D_LD(*value.Double)
    ; Load Double: PUSH value on the Stack
    mac_DebugProcWithPara(*value\d)
    With RPN
      \pRD = mac_StackNext(\pRD)   ; grow the Stack         
      \RD[\pRD] = *value\d
    EndWith      
  EndProcedure
  RPN_ProcPtr(#RPN_D_LD) = @D_LD()
   
  Procedure D_SAV(*Result.Double)
    ; Save the Top value from Stack into Result. Do not modifiy Stackpointer
    mac_DebugProcWithPara(*Result\d)
    With RPN
      *Result\d = \RD[\pRD]
    EndWith   
  EndProcedure
  RPN_ProcPtr(#RPN_D_SAV) = @D_SAV()

  Procedure D_ADD(*dummy)               
    ; ADD the2 top most values on Double Stack and shrink Stack
    Protected mem.d
    With RPN
      ; POP Top Value from Stack to mem
      mem = \RD[\pRD]
      \pRD = mac_StackPrevious(\pRD)    ; Shrink Stack
      ; process the ADD
      \RD[\pRD] + mem
      mac_DebugProcWithPara(\RD[\pRD])
    EndWith      
  EndProcedure
  RPN_ProcPtr(#RPN_D_ADD) = @D_ADD()
  
  Procedure D_SUB(*dummy)               
    ; SUD the2 top most values on Double Stack and shrink Stack
    Protected mem.d
    With RPN
      ; POP Top Value from Stack to mem
      mem = \RD[\pRD]
      \pRD = mac_StackPrevious(\pRD)    ; Shrink Stack
      ; process the SUB
      \RD[\pRD] - mem
      mac_DebugProcWithPara(\RD[\pRD])
    EndWith      
  EndProcedure
  RPN_ProcPtr(#RPN_D_SUB) = @D_SUB()
  
  Procedure D_MUL(*dummy)
    ; MUL the2 top most values on Double Stack and shrink Stack
    Protected mem.d
    With RPN
      ; POP Top Value from Stack to mem
      mem = \RD[\pRD]
      \pRD = mac_StackPrevious(\pRD)    ; Shrink Stack
      ; process the MUL
      \RD[\pRD] * mem
      mac_DebugProcWithPara(\RD[\pRD])
    EndWith      
  EndProcedure
  RPN_ProcPtr(#RPN_D_MUL) = @D_MUL()
  
  Procedure D_DIV(*dummy)
    ; DIV the2 top most values on Double Stack and shrink Stack
    Protected mem.d
    With RPN
      ; POP Top Value from Stack to mem
      mem = \RD[\pRD]
      \pRD = mac_StackPrevious(\pRD)    ; Shrink Stack
      ; process the DIV
      \RD[\pRD] / mem
      mac_DebugProcWithPara(\RD[\pRD])
    EndWith      
  EndProcedure
  RPN_ProcPtr(#RPN_D_DIV) = @D_DIV()


EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule RPN
  
  Procedure CreateParableProg(Array RpnProg.TRPN_PROG_ELEMENT(1), *x, *a, *b, *c) ; creates the RPN Programm for a parabel function ax² + bx +c
    ; creates the compiled RPN Program for ; ax² + bx +c
    Protected I
    
    ; --------------------------------------------------
    ; !Thats the Programm Script we have to compile
    ; --------------------------------------------------   
    ; CLRALL    ; Clear Akku1/2 and Mem
    ;  --- ax² ---
    ; LD_SQ x     ; Load x² to A1
    ; LD_MUL a    ; Load & MUL a
    ; MADD        ; Add result to Mem
    ;  --- bx ---
    ; LD x
    ; LD_MUL b    ; A1 = b*x
    ; MRET        ; Return ax² from Mem
    ; ADD         ; Add to bx
    ; LD_ADD c    ; +c : Now A1 contains result of ax² + bx + c
    ; --------------------------------------------------
   
    Dim RpnProg(8)  ; we need 9 operations 0..9
    
    ; Create an entry for each operation in the RpnProg - Array
    ; CLRALL
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_CLRALL)  
    RpnProg(I)\pValue = 0
    I + 1
    ; LD_SQ x     ; Load x² to A1
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_LD_SQ)  
    RpnProg(I)\pValue = *x
    I + 1 
    ; LD_MUL a    ; Load & MUL a
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_LD_MUL)  
    RpnProg(I)\pValue = *a
    I + 1
    ; MADD        ; Add result to Mem
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_MDADD)  
    RpnProg(I)\pValue = 0
    I + 1
    ; LD x
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_LD)  
    RpnProg(I)\pValue = *x
    I + 1
    ; LD_MUL b
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_LD_MUL)  
    RpnProg(I)\pValue = *b
    I + 1
    ; MRET        ; Return ax² from Mem
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_MDRET)  
    RpnProg(I)\pValue = 0
    I + 1
    ; ADD         ; Add to bx
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_D_ADD)  
    RpnProg(I)\pValue = 0
    I + 1
    ; LD_ADD c    ; +c
    RpnProg(I)\pProc = GetRpnProcPointer(#RPN_LD_ADD)  
    RpnProg(I)\pValue = *c   
   
  EndProcedure
  
  Define.d y, x, a, b, c
  Define P.Double
  Define.i I
  
  Debug "--------------------------------------------------"
  Debug "  Test all Function calls"
  Debug "--------------------------------------------------"
 
  ; Fuctions with dummy Parameter
  CallRPN(#RPN_CLRALL)
  CallRPN(#RPN_D_ADD)
  CallRPN(#RPN_D_SUB)
  CallRPN(#RPN_D_MUL)
  CallRPN(#RPN_D_DIV)
    
  ; Memory Functions
  CallRPN(#RPN_MDCLR, P)
  CallRPN(#RPN_MDADD, P)
  CallRPN(#RPN_MDSUB, P)
  CallRPN(#RPN_MDRET, P)
  
  ; last Function
  CallRPN(#RPN_D_SAV, P)
  
  Debug "--------------------------------------------------"
  Debug "  Test Loop(10) with x parameter "
  Debug "  y = x + c :  x = {1..10} c=1"
  Debug "--------------------------------------------------"

  For I = 1 To 10
    x = I 
    c = 1
    CallRPN(#RPN_LD, @c)
    CallRPN(#RPN_LD_ADD, @x)
    Debug "Result = " + StrD(GetResult())
    Debug ""
  Next
  
  Debug "--------------------------------------------------"
  Debug " Test compiled RPN Program for y = ax² + bx +c "
  Debug "--------------------------------------------------"

  Dim MyRpnProg.TRPN_PROG_ELEMENT(0)
  
  CreateParableProg(MyRpnProg(), @x, @a, @b, @c)
  
  a = 1 : b=1 : c = 0  ; -> y = x² + x
  
  For I = 1 To 10
    x=I
    y = RunRpnProg(MyRpnProg(), 99)  
    Debug "*******"
      Debug "y = " + StrD(y)  
    Debug "*******"
 Next 
  
CompilerEndIf

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 362
; FirstLine = 343
; Folding = ----
; Optimizer
; EnableXP
; CPU = 5