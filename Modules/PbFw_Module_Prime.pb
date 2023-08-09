; ===========================================================================
;  FILE : PbFw_Module_Prime.pb
;  NAME : Module Prime [Prime::]
;  DESC : Prime Number Functions Library
;  DESC : 
; ===========================================================================
;
; AUTHOR   : Stefan Maag
; DATE     : 2023/03/28
; VERSION  : 0.5 Developer Version
; COMPILER : PureBasic 6.0
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

;x64 Registers
; RAX 	Akkumulator
; RBX 	Base Register
; RCX 	Counter
; RDX 	Data Register
; RBP 	Base-Pointer
; RSI 	Source-Index
; RDI 	Destination-Index
; RSP 	Stack-Pointer 
; R8…R15 	Register 8 bis 15 

; Combinations of RestClasses-Mod30 and the RestClass-Mod30 of the multiplication Result

; RestClass_A * RestClass_B = RestClass_C

;  1  *  1  Rest  1   ; Numbers of RestClass_1 * RestClass_1 cause a Result with RestClass_1 
;  7	*	13	Rest	1   ; Numbers of RestClass_7 * RestClass_13 cause a Result with RestClass_1 
; 11	*	11	Rest	1
; 17	*	23	Rest	1
; 19	*	19	Rest	1
; 29	*	29	Rest	1
; {1,7,11,17,19,29}   ; This RestClases of deviders we have to test
; -----------------------

;  1	*	 7	Rest	7   ; Numbers of RestClass_1 * RestClass_7 cause a Result with RestClass_7
; 11	*	17	Rest	7
; 13	*	19	Rest	7
; 23	*	29	Rest	7
; {1,11,13,23}        ; This RestClases of deviders we have to test
; -----------------------

;  1	*	11	Rest	11
;  7	*	23	Rest	11
; 13	*	17	Rest	11
; 19	*	29	Rest	11
; {1,7,13,19}         ; This RestClases of deviders we have to test
; -----------------------

;  1	*	13	Rest	13
;  7	*	19	Rest	13
; 11	*	23	Rest	13
; 17	*	29	Rest	13
; {1,7,11,17}         ; This RestClases of deviders we have to test
; -----------------------

;  1	*	17	Rest	17
;  7	*	11	Rest	17
; 13	*	29	Rest	17
; 19	*	23	Rest	17
; {1,7,13,19}         ; This RestClases of deviders we have to test
; -----------------------

;  1	*	19	Rest	19
;  7	*	 7	Rest	19
; 11	*	29	Rest	19
; 13	*	13	Rest	19
; 17	*	17	Rest	19
; 23	*	23	Rest	19
; {1,7,11,13,17,23}   ; This RestClases of deviders we have to test
; -----------------------

;  1	*	23	Rest	23
;  7	*	29	Rest	23
; 11	*	13	Rest	23
; 17	*	19	Rest	23
; {1,7,11,17}         ; This RestClases of deviders we have to test
; -----------------------

;  1	*	29	Rest	29
;  7	*	17	Rest	29
; 11	*	19	Rest	29
; 13	*	23	Rest	29
; {1,7,11,13}         ; This RestClases of deviders we have to test

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule Prime
  
; Structures for BigNumber Calculations! Not implemented yet!
;   Structure uInt128
;     val.q[1]
;   EndStructure
;   
;   Structure uInt256
;     val.q[3]
;   EndStructure
;   
;   Structure uInt512
;     val.q[7]
;   EndStructure
;   
;   Structure uInt1024
;     val.q[15]
;   EndStructure
;   
;   Structure uInt2048
;     val.q[31]
;   EndStructure
  
  Declare.q PrimeFactors(Number.q, List lstPrimeFactors.q())
  Declare.i IsPrime(Number.q)
  
  ;- ----------------------------------------------------------------------
  ;- LookUpTables
  ;- ----------------------------------------------------------------------
  
  Enumeration eRC
    #RC_1 = 0
    #RC_7
    #RC_11
    #RC_13
    
    #RC_17
    #RC_19
    #RC_23
    #RC_29
  EndEnumeration
  
   ; Mod30 RestClasses for possible Primes
  Global Dim RC.i(7)
    RC(0) = 1
    RC(1) = 7
    RC(2) = 11
    RC(3) = 13
    RC(4) = 19
    RC(6) = 23
    RC(7) = 29
    
  ; Mod30 RestClass-Delta LookUpTable
  Global Dim RCdelta.i(7)    
    ; Init LookUpTable!  
    RCdelta(0) = 6  ;  1=>7  : = 7  -1      MOD30_Rest(1) - MOD30_Rest(0)
    RCdelta(1) = 4  ;  7=>11 : = 11 -7      MOD30_Rest(2) - MOD30_Rest(1)
    RCdelta(2) = 2  ; 11=>13 : =13 -11
    RCdelta(3) = 4  ; 13=>17 : =17 -13
    RCdelta(4) = 2  ; 17=>29 : =19 -17
    RCdelta(5) = 4  ; 19=>23 : =23 -19
    RCdelta(6) = 6  ; 23=>29 : =29 -23
    RCdelta(7) = 2  ; 29=>31 : =31 -29     MOD30_Rest(7+1) - MOD30_Rest(7)   

EndDeclareModule

Module Prime
  
  EnableExplicit
  
    
  ; in x64: HandMade Modulo is ~13% in fastern than PB's (Number % div) tested on Ryzen 5800
  ; in x32: for Quads PureBasic Modulo is faster
  CompilerIf #PB_Compiler_64Bit
    Macro _mac_Modulo(Number, div)
      (Number-(Number/div)*div)
    EndMacro
  CompilerElse
    Macro _mac_Modulo(Number, div)
      Number % div
    EndMacro
  CompilerEndIf
    
  Procedure.q PrimeFactors(Number.q, List lstPrimeFactors.q())
  ; ============================================================================
  ; NAME: PrimeFactors
  ; DESC: Do a Prime-Number-Crunching! Calculates all PrimFactors of Number.
  ; DESC: The algorithm use a 8 Value LookUpTabele for the MOD30 Distances
  ; DESC: Instead of 15 odd Dividers in a Segment of 30 we have to calculate
  ; DESC: only the 8 possible Primes with Rest(MOD30) = {1,7,11,13, 17,19,23,29}
  ; DESC: The maximum number of Iterations is Sqr(Number)/30*8
  ; DESC: For a 32-Bit signed INT we need max. 12352 Iterations. 
  ; DESC: On a Ryzen 5000 this needs less than 1ms
  ; DESC: To crunch (2^63)-1 needs 24.729 Iterations <1ms
  ; DESC: The longest time was 595ms for 404.933.400 Iterations
  ; DESC: This is for the 9th Mersenn Prim (1^61)-1
  ; VAR(Number.q) : The Number to chrunch
  ; VAR(List lstPrimeFactors.q()) : The List() for the Prime Factors
  ; RET.i : #True: if Number is Prim; 
  ; ============================================================================
   
    Shared RCdelta()        ; Share the LookUpTable
    Protected.q P, memN, I, Max
        
    ClearList(lstPrimeFactors())
        
    memN = Number
    
    ; ----------------------------------------------------------------------
    ; First the MOD30 = (2*3*5) Factors
    ; ----------------------------------------------------------------------
    While Not (memN % 2)  
      memN / 2           
      AddElement(lstPrimeFactors())
      lstPrimeFactors() = 2
      ;Debug "Factor 2"
    Wend
    
    While Not (memN % 3)  
      memN / 3           
      AddElement(lstPrimeFactors())
      lstPrimeFactors() = 3
      ;Debug "Factor 3"
    Wend
    
    While Not (memN % 5)
      memN / 5           
      AddElement(lstPrimeFactors())
      lstPrimeFactors() = 5
      ;Debug "Factor 5"
    Wend
    
    P = 7   ; now we can start with the next possible Prim Divider :=7
    I = 0   ; Iteration counter and Index for RCdelta() LookUpTable
    
    ; ATTENTION Sqr works with double Float. 52Bit + 12Bit Exponent.
    ; This is no Problem because the FPU internal works with at least 80 Bits
    Max = Abs(Sqr(memN)+1) 
    
    While P <= Max  
      ;While Not (memN % P)         ; (memN % P) = 0, Rest =0 => Found a PrimFactor
      While _mac_Modulo(memN, P) = 0   ; HandMade Modulo is Faster 682 -> 597ms
        ; Found a PrimFactor
        AddElement(lstPrimeFactors())
        lstPrimeFactors() = P
        memN = memN / P           ; calculates the new Value to crunch
        Max = Sqr(memN)+1         ; Limit for the new divider
      Wend      
      I = I + 1                 ; Iterations; With I we calculate the Index of RCdelta(I & 7) 
      P = P + RCdelta(I & 7)    ; Calculates next possilbe Prim with the Delatas from the LookUpTable
    Wend
    
    If P > Max And memN > 1
      ; If P > Max Then memN is not devideable 
      ; in this case memN is the PrimFactor itself
      AddElement(lstPrimeFactors())
      lstPrimeFactors() = memN      
    EndIf 
    
    ProcedureReturn I ; Return the Iterations needed for Calculation
    ;ProcedureReturn Bool(Number=memN) ; #True If IsPrim(Number)
  EndProcedure
  
  Procedure.i IsPrime(Number.q)
  ; ============================================================================
  ; NAME: IsPrime
  ; DESC: See at PrimeFactors() for a more detailed description of how
  ; DESC: it works
  ; VAR(Number.q) : The Number to chrunch
  ; RET.i : #True: if Number is Prim; 
  ; ============================================================================
   
    Shared RCdelta()        ; Share the LookUpTable
    Protected.q P, memN, I, Max
              
    memN = Number  
    ; ----------------------------------------------------------------------
    ; First the MOD30 = (2*3*5) Factors
    ; ----------------------------------------------------------------------
    
    If (memN >=-1) And (memN <= 1)
      ProcedureReturn #False
    EndIf
    If (memN=2) Or (memN=3) Or (memN=5)
      ProcedureReturn #True   
    EndIf 
    
    If (memN % 2) = 0  Or (memN % 3) = 0 Or (memN % 5) = 0
      ProcedureReturn #False
    EndIf
        
    P = 7   ; now we can start with the Next possible Prim Divider :=7
    I = 0   ; Iteration counter and Index for RCdelta() LookUpTable
    
    ; ATTENTION Sqr works with double Float. 52Bit + 12Bit Exponent.
    ; This is no Problem because the FPU internal works with at least 80 Bits
    Max = Abs(Sqr(memN)+1) 
    
    While P <= Max  
      ;If Not (memN % P)           ; (memN % P) = 0, Rest =0 => Found a PrimFactor
      If _mac_Modulo(memN, P)=0  ; HandMade Modulo is Faster 682 -> 597ms
       ; Found a PrimFactor 
        ProcedureReturn #False
      EndIf      
      I = I + 1                 ; Iterations; With I we calculate the Index of RCdelta(I & 7) 
      P = P + RCdelta(I & 7)    ; Calculates next possilbe Prim with the Delatas from the LookUpTable
    Wend
    ProcedureReturn #True  
  EndProcedure
  
EndModule

CompilerIf #PB_Compiler_IsMainFile    
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------

  EnableExplicit
  UseModule Prime
  
  ; ----------------------------------------------------------------------
  ;  Define Variables
  ; ----------------------------------------------------------------------
  
  Procedure Test_PrimeFactors()
    Protected.q Number, time, cnt, res
    Protected.s str
    Number = 9007199254740991
    ;Number = (1<<31)-1  ; 8te Mersenn Primzahl 2^31-1 =            2.147.483.647
    ;Number = (1<<61)-5  ; 9te Mersenn Primzahl 2^61-1 = 2.305.843.009.213.693.951
    ;Number = 715827881 * 2147483647
     ;Number = 4294967295  ; Product of the first 5 Fermat Primes
    
    NewList Factors.q()
    
    time = ElapsedMilliseconds()
    cnt = PrimeFactors(Number, Factors())
    time = ElapsedMilliseconds()-time
    
    ResetList(Factors())
    
    res = 1
    ForEach Factors()
      res * Factors()    
    Next
    
    str = "Number   = " + Str(Number) + #CRLF$
    Str + "SqrRoot  = " + Str(Int(Sqr(Number))) + #CRLF$
    str + "Result P!  = " + Str(res) + #CRLF$ 
    str + "Iterations = " + Str(cnt) + #CRLF$
    str + "Time       = " + Str(time) + "ms" + #CRLF$
    str + #CRLF$
    str + "Prime Factors " 
    ForEach Factors()
      str + #CRLF$ + Str(Factors())
    Next
    
    ClearClipboard()  ; Clear the Clipboard
    SetClipboardText(str) ; Paste text to the clipboard..
    
    MessageRequester("Prime Factors", str, #PB_MessageRequester_Ok)  
  EndProcedure
  
  Test_PrimeFactors()
CompilerEndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 27
; FirstLine = 51
; Folding = --
; Optimizer
; CPU = 5