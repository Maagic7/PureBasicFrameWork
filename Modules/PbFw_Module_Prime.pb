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

; The number of Primes up to a limit! The excact values
; and the calculated result with Tschebyscheff aproximation.
; 1.1056 * x/ln(x)

; https://en.wikipedia.org/wiki/Prime_number_theorem
;  Primes up to           |    NoOfPrimes  | N(x)/(x/ln(x)    | Tschebyscheff aproximation     
; 10e2   	                             25 	    1.1513                           29 
; 10e3            	                  168 	    1.1606                          177
; 10e4           	                  1.229 	    1.1320                        1.245 	
; 10e5          	                  9.592 	    1.1044                        9.629 	
; 10e6        	                   78.498 	    1.0845                       78.627 	
; 10e7       	                    664.579 	    1.0712                      664.917 
; 10e8  	                      5.761.455 	    1.0613                    5.762.208 
; 10e9    	                   50.847.534 	    1.0538                   50.849.234 	
; 10e10 	                    455.052.511 	    1.0478                  455.055.614
; 10e11 	                  4.118.054.813 	    1.0431                4.118.066.400 
; 10e12 	                 37.607.912.018 	    1.0392               37.607.950.280 	
; 10e13 	                346.065.536.839       1.0359
; 10e14 	              3.204.941.750.802 	    1.0332
; 10e15 	             29.844.570.422.669 	    1.0308
; 10e16 	            279.238.341.033.925 	    1.0288
; 10e17 	          2.623.557.157.654.233 	    1.0270
; 10e18 	         24.739.954.287.740.860 	    1.0254
; 10e19 	        234.057.667.276.344.607 	    1.0240
; 10e20 	      2.220.819.602.560.918.840 	    1.0228
; 10e21 	     21.127.269.486.018.731.928 	    1.0216
; 10e22 	    201.467.286.689.315.906.290 	    1.0206
; 10e23 	  19.25.320.391.606.803.968.923 	    1.0197
; 10e24 	 18.435.599.767.349.200.867.866 	    1.0188
; 10e25 	176.846.309.399.143.769.411.680 	    1.0181

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
  
  Declare.q GetMaxNoOfPrimes(Limit.q)
  Declare.q PrimeFactors(Number.q, List lstPrimeFactors.q())
  Declare.i IsPrime(Number.q)
  Declare.i IsPrime_x64(Value.q)
  Declare.i PrimeSieve_SumAlgo (Limit.i, Array *Primes(1)) ; *Primes(1) Pointer to a 1 dimensional Array of Integer
  Declare.q ListPrimes(Limit.q, Array *Primes(1))
  Declare CountMod120(Array *Primes(1), N.q, Array *OutCnt(1))


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
  
  ; Mod30/60/120 RestClasses for possible Primes
  Global Dim RC.i(31)      
  Global Dim RCIndex(119)  
  ; Mod30 RestClass-Delta LookUpTable
  Global Dim RCdelta.i(7)    
 
EndDeclareModule

Module Prime
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  IncludeFile "PbFw_ASM_Macros.pbi"
    
  ; in x64: HandMade Modulo is ~13% fastern than PB's (Number % div) tested on Ryzen 5800
  ; in x32: for Quads PureBasic Modulo is faster
  CompilerIf #PB_Compiler_32Bit ; Or #True
    Macro _mac_Modulo(Number, div)
      Number % div
    EndMacro
  CompilerElse
    Macro _mac_Modulo(Number, div)
      (Number-(Number/div)*div)
    EndMacro
  CompilerEndIf
  
  Procedure.i _Init()
  ; ============================================================================
  ; NAME: _Init
  ; DESC: Initialize Parameters and LookUpTabels
  ; Ret.i: #True  
  ; ============================================================================
    
    Protected I,J 
    
    ; Mod30/60/120 RestClasses for possible Primes
    ; The Rest Classes of Mod(30) filter. Products of 2,3,5 are filtered out
    ; To get the Prime Candiates in each RestClass we calculate 30*n + RC(RestClassNo)

    RC(0) = 1       ; 31, 61, 91, 121 ...
    RC(1) = 7       ; 37, 67, 97, 127 ...
    RC(2) = 11      ; 41, 71, 101, 131 ...
    RC(3) = 13      ; 43, 73, 103, 133 ...
    RC(4) = 17      ; 47, 77, 107, 137 ...
    RC(5) = 19      ; 49, 79, 109, 139 ...
    RC(6) = 23      ; 53, 83, 113, 143 ...
    RC(7) = 29      ; 59. 89, 119, 149 ...
    
    RC(8) = 31      ; MOD 60 
    RC(9) = 37      
    RC(10) = 41     
    RC(11) = 43     
    RC(12) = 47      
    RC(13) = 49      
    RC(14) = 53      
    RC(15) = 59     ; --------------------- 
    
    RC(16) = 61     ; MOD 120   
    RC(17) = 67      
    RC(18) = 71     
    RC(19) = 73     
    RC(20) = 77      
    RC(21) = 79      
    RC(22) = 83      
    RC(23) = 89      
    
    RC(24) = 91       
    RC(25) = 97      
    RC(26) = 101     
    RC(27) = 103     
    RC(28) = 107      
    RC(29) = 109      
    RC(30) = 113      
    RC(31) = 119    ; --------------------- 
      
    ; Mod30 RestClass-Delta LookUpTable
    ; Init LookUpTable!  
    RCdelta(0) = 6  ;  1=>7  : = 7  -1      MOD30_Rest(1) - MOD30_Rest(0)
    RCdelta(1) = 4  ;  7=>11 : = 11 -7      MOD30_Rest(2) - MOD30_Rest(1)
    RCdelta(2) = 2  ; 11=>13 : =13 -11
    RCdelta(3) = 4  ; 13=>17 : =17 -13
    RCdelta(4) = 2  ; 17=>19 : =19 -17
    RCdelta(5) = 4  ; 19=>23 : =23 -19
    RCdelta(6) = 6  ; 23=>29 : =29 -23
    RCdelta(7) = 2  ; 29=>31 : =31 -29     MOD30_Rest(7+1) - MOD30_Rest(7)   
    
    ; Create Index LookUpTable
    J = 0
    For I = 0 To 31
      RCIndex(RC(I)) = J
      J+1      
    Next
    
;     For I=0 To 119
;       Debug "I: " + Str(I) + " : Index: " + RCIndex(I) 
;     Next
    
  EndProcedure
  _Init()  ; do Init
  
  Procedure.q GetMaxNoOfPrimes(Limit.q)
  ; ============================================================================
  ; NAME: GetMaxNoOfPrimes
  ; DESC: Returns the maximum Number of Primes up to Limit.
  ; DESC: It can be used to calculate the size of Buffers
  ; VAR(Limit.q) : The limit value
  ; RET.i : maximum Number of Primes up to Limit; 
  ; ============================================================================
      
    Protected.q res
    Protected.d k
    
    If      Limit <= 1e2  : k = 1.1513 
    ElseIf  Limit <= 1e3  : k = 1.1606  
    ElseIf  Limit <= 1e4  : k = 1.1320  
    ElseIf  Limit <= 1e5  : k = 1.1044  
    ElseIf  Limit <= 1e6  : k = 1.0845  
    ElseIf  Limit <= 1e7  : k = 1.0712  
    ElseIf  Limit <= 1e8  : k = 1.0613  
    ElseIf  Limit <= 1e9  : k = 1.0538  
    ElseIf  Limit <= 1e10 : k = 1.0478  
    ElseIf  Limit <= 1e11 : k = 1.0431  
    ElseIf  Limit <= 1e12 : k = 1.0392  
    ElseIf  Limit <= 1e13 : k = 1.0359  
    ElseIf  Limit <= 1e14 : k = 1.0332  
    ElseIf  Limit <= 1e15 : k = 1.0308  
    ElseIf  Limit <= 1e16 : k = 1.0288  
    ElseIf  Limit <= 1e17 : k = 1.0270  
    Else                  : k = 1.0254
    EndIf                                  
    
    res = k * Limit/Log(Limit)  ; maximal possible No of Primes up to the users requested Limit
    
    ProcedureReturn res
  EndProcedure

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
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm And #PB_Compiler_64Bit
      ; in x64 Assembler we can do a extrem fast MillerRabin Test
      ; before trying to crunch
      If IsPrime_x64(Number)
        AddElement(lstPrimeFactors())
        lstPrimeFactors() = Number
        
        ProcedureReturn 1  
      EndIf
    CompilerEndIf
  
    memN = Number
    
    ; ----------------------------------------------------------------------
    ; First the MOD30 = (2*3*5) Factors
    ; ----------------------------------------------------------------------
    While Not (memN & 1)  
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
    Max = Sqr(memN)+1 
    
    While P <= Max  
     ; While Not (memN % P)         ; (memN % P) = 0, Rest =0 => Found a PrimFactor
      While _mac_Modulo(memN, P)  = 0   ; HandMade Modulo is Faster 682 -> 597ms
        ; Found a PrimeFactor
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
    Protected.q P, I, Max
    Protected xIsPrime = #True
    
    ; ----------------------------------------------------------------------
    ; First the MOD30 = (2*3*5) Factors
    ; ----------------------------------------------------------------------
    
    CompilerIf #False 
      If Number < 30
        Select Number
          Case 2, 3, 5, 7, 11, 13, 17, 19, 23, 29
            ProcedureReturn #True
          Default
            ProcedureReturn #False   
        EndSelect 
        
      ElseIf Number&1=0 Or Number%3=0 Or Number%5=0 Or Number%7=0 Or Number%11=0 Or Number%13=0 Or Number%17=0 Or Number%19=0 Or Number%23=0 Or Number%29=0
        ProcedureReturn #False         
      EndIf
    
    CompilerElse
      
      If Number < 30
        Select Number
          Case 2, 3, 5, 7, 11, 13, 17, 19, 23, 29
            ProcedureReturn #True
          Default
            ProcedureReturn #False   
        EndSelect 
        
      ElseIf (Number & 1) = 0
        ProcedureReturn #False
      Else  
        Select Number % 30
          Case 3,5,9,15,21,25,27      ; Prime not possible
            ProcedureReturn #False
          ; Case 1,7,11,13,17,19,23,29   ; Prime possible      
        EndSelect             
      EndIf
   
    CompilerEndIf
          
    P = 7  ; now we can start with the Next possible Prim Divider :=7
    I = 0   ; Iteration counter and Index for RCdelta() LookUpTable
    
    ; ATTENTION Sqr works with double Float. 52Bit + 12Bit Exponent.
    ; This is no Problem because the FPU internal works with at least 80 Bits
    Max = Sqr(Number)+1 
  
    While P <= Max  
       ; If (Number % P) = 0          ; (Number % P) = 0, Rest =0 => Found a PrimFactor
      If _mac_Modulo(Number, P)=0   ; HandMade Modulo is Faster 682 -> 597ms
       ; Found a PrimFactor 
        xIsPrime = #False
        Break
      EndIf      
      I = I + 1                 ; Iterations; With I we calculate the Index of RCdelta(I & 7)    
      P = P + RCdelta(I & 7)    ; Calculates next possilbe Prim with the Delatas from the LookUpTable
    Wend
    ProcedureReturn xIsPrime  
  EndProcedure
  
  Procedure.i IsPrime_x64(Value.q)
  ; ============================================================================
  ; NAME: IsPrime_x64
  ; DESC: Attention! Only for ASM Backend and x64
  ; DESC: Performes a full deterministic Miller Rabin Test for signed 
  ; DESC: 64 Bit Intger.
  ; DESC: Because Miller Rabin use x², the caculation reaches
  ; DESC: 128Bit results. The CPU internal computes x64 MUL, DIV
  ; DESC: with 128Bit in RAX:RDX, so we can use 128Bit in ASM-Code.
  ; DESC: In normal PB-Code this isn't possible without a BigInt Lib.
  ; VAR(Value.q) : The Number to chrunch
  ; RET.i : #True: if Number is Prime
  ; ============================================================================
    
    ; based on Code from PB-Forum from STARGATE
    ; https://www.purebasic.fr/german/viewtopic.php?p=361719&hilit=Primzahlen#p361719
    
    ; https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
  	; https://en.wikipedia.org/wiki/Exponentiation_by_squaring
  	; https://www.purebasic.fr/german/viewtopic.php?f=8&t=30523
  	; Thanks to NicknameFJ und Helle
    
    Protected ret = #True
    Protected *Try.Integer
    Protected.i Loops, Exponent, Base
    
  	If Value < 0
   	  Value = -Value
   	EndIf 	
   	
   	#BranchPrediction = #True
   	
    CompilerIf #BranchPrediction
      ; ---------------------------------------------------------------------- 
      ; This Version with the seperate Modulo functions performs aprox. 
      ; 10% better. The Reason might be the BranchPrediction which 
      ; precalculates the ElseIf so the CPU don't have to do all the Modulos
      ; ---------------------------------------------------------------------- 
  
      If Value <=30                     ; Values up to 30 (2*3*5) , We handle direct    	 	   
        Select Value 
          Case 2, 3, 5, 7, 11, 13, 17, 19, 23, 29   ; all Primes <30
            ProcedureReturn #True
          Default
            ProcedureReturn #False   
        EndSelect 
        
      ElseIf Value&1=0 Or Value%3=0 Or Value%5=0 Or Value%7=0 Or Value%11=0 Or Value%13=0 Or Value%17=0 Or Value%19=0 Or Value%23=0 Or Value%29=0 
        ProcedureReturn #False  
      EndIf
      
    CompilerElse
     ; ----------------------------------------------------------------------  
     ; This Version looks like to be the better and faster Code. 
     ; But it isn't. I tested the 2 Versions on new and older CPU 
     ; from 2011, 2016, 2020 and this version is always slower!
     ; ---------------------------------------------------------------------- 
      
      If Value <=30                     ; Values up to 30 (2*3*5) , We handle direct    	 	
        
        Select Value 
          Case 2, 3, 5, 7, 11, 13, 17, 19, 23, 29   ; all Primes <30
            ProcedureReturn #True
          Default
            ProcedureReturn #False   
        EndSelect 
        
      ElseIf (Value & 1) = 0            ; If Even(Value) 
        ProcedureReturn #False          ;   Not a Prime!
        
      Else                              ; from here on we have: Even Values > 30                                       
        Select (Value % 30)             ; Check Mod30 RestClasses: (Value Mod 5 =0) or (Value Mod 3 =0)
          Case 3,5,9,15,21,25,27        ; Prime not possible! Value IsNotElementOf Mod30 RestClass for PirmeCandidates
            ProcedureReturn #False       
          ; Case 1,7,11,13,17,19,23,29  ; Prime possible! Value IsElementOf Mod30 RestClass for PrimeCandidates [1,7,11,13, 17,19,23,29]      
        EndSelect    
      EndIf
      
    ; ----------------------------------------------------------------------   
    CompilerEndIf
  
  	; with unrolling the loop we get a little faster code 	
  	If Value < 2047
  	  *Try = ?Lower_2047 
  	 
  	ElseIf Value <  1373653
  	  *Try = ?Lower_1373653	  
  	  
  	ElseIf Value <  9080191
  	  *Try = ?Lower_9080191
  	  
  	ElseIf Value <  25326001 
  	  *Try = ?Lower_25326001
  	  
  	ElseIf Value <  3215031751
  	  *Try = ?Lower_3215031751
  	  
  	ElseIf Value <  4759123141
  	  *Try = ?Lower_4759123141	  
  	  
  	ElseIf Value <  1122004669633
  	  *Try = ?Lower_1122004669633	  
  	  
  	ElseIf Value <  2152302898747
  	  *Try = ?Lower_2152302898747	  
  	  
  	ElseIf Value <  3474749660383
  	  *Try = ?Lower_3474749660383	  
  	  
  	ElseIf Value <  341550071728321
  	  *Try = ?Lower_341550071728321	  
  	  
  	ElseIf Value <  3825123056546413051
  	  *Try = ?Lower_3825123056546413051	  
  	Else   
  	  *Try = ?Lower_18446744073709551616  	  
  	EndIf
  	
 		; because for MillerRabin we need 128Bit, this is not possible in standard PB-Code

  	; used Registers
    ;   RAX : operating Register MUL, DIV
    ;   RCX : Counter
    ;   RDX : operating Register MUL, DIV
    ;   R8  : Exponent
    ;   R9  : Value
    ;   R10 : -
  	  	
  	; Solve: 2^Loops * Exponent + 1 = Value
  	! MOV   RAX, [p.v_Value]          ; RAX = Value
  	! DEC   RAX                       ; RAX - 1
  	! BSF   RCX, RAX                  ; Find LSB [0..63]
  	! MOV   [p.v_Loops], RCX          ; Loops = LSB(Value)
  	! SHR   RAX, cl                   ; RAX = (Value-1) >> LSB(Value)
  	! MOV   [p.v_Exponent], RAX       ; Exponent = (Value-1) >> LSB(Value)
  	
  	; Witness loop
  	!_WhileTry:
  	!MOV RAX, QWORD [p.p_Try]         ; RAX = *Try
  	!MOV RAX, [RAX]                   ; RAX = *Try\i
  	!TEST RAX, RAX                    ; RAX == 0     
  	!JZ _Return                       ; Jump _Retrun if 0 
  ;	While *Try\i
  		
  		;Base = *Try\i
  		!MOV RAX, QWORD [p.p_Try]       ; RAX = *Try
  		!MOV RAX, [RAX]                 ; RAX = *Try\i
      !MOV QWORD [p.v_Base],RAX       ; Base = *Try\i
  
  		; RAX = Base^Exponent % Value
  		!MOV  R8, [p.v_Exponent]        ; R8 = Exponent
  		!MOV  R9, [p.v_Value]           ; R9 = Value
  		!MOV  RAX, 1                    ; RAX = 1
  		!BSR  RCX, R8                   ; RCX = MSB(Exponent)
  		;Loop:
  		!_InnerLoop:
  			!MUL  RAX                     ; RAX = RAX * RAX
  			!DIV  R9                      ; RAX:RDX = RAX:RDX / Value  
  			!MOV  RAX, rdx                ; RAX = RAX % Value : Move Devision Remainder to RAX
  			!BT   R8, RCX                 ; BitTest(Exponent, RCX), starts with RDX =  MSB(Exponent)
  			!JNC @F
  				!MUL  QWORD [p.v_Base]      ; RAX:RDX * Base
  				!DIV  R9                    ; RAX:RDX / Value
  				!MOV  RAX, rdx              ; RAX = Devision Remainder
  			!@@:
  			!DEC  RCX                     ; RCX-1 : Bitcounter - 1
  		!JNS _InnerLoop
  		
  		; RAX = 1 or RAX = Value-1 ?
  		!MOV  R8, R9                    ; R8 = Value
  		!DEC  R8                        ; R8 = Value -1
  		!CMP  RAX, 1                    ; If RAX = 1
  		!JE  _Continue                  ;   Continue  
  		!CMP  RAX, R8                   ; If RAX = Value -1
   		!JE  _Continue                  ;   Continue
  	
  		; Square-Mod-Loop: RAX = RAX^2 % Value  and check for  RAX = Value-1
  		!MOV  RCX, [p.v_Loops]          ; RCX = Loops
  		!@@:                            ; Repeat
  			!MUL  RAX                     ; RAX * RAX
  			!DIV  R9                      ; RAX:RDX / Value
  			!MOV  RAX, rdx                ; RAX = Devsion Remainder
  			!CMP  RAX, R8                 ; If RAX = VAlue -1
  			!JE  _Continue                ;  Countinue
  			!CMP  RAX, 1                  ; If RAX = 1
    		!JBE  _NoPrime                ; NoPrime	
    		!DEC  RCX                     ; RCX-1 : Bitcounter - 1
    	!JNZ @B                         ; Repeat If RCX<> 0
    		
  	  ;	noprime:
  		!_NoPrime:                      ; NoPrime
    		!XOR RAX, RAX                 ; RAX = 0
    		!MOV [p.v_ret], RAX           ; ret = 0
    		!JMP _Return                  ; Jump to Return
   		
  		!_Continue:                     ; Continue
  		;*Try + SizeOf(Integer)
    		!MOV    RAX, QWORD [p.p_Try]  ; RAX = *Try
        !ADD    RAX,8                 ; RAX + 8
        !MOV    QWORD [p.p_Try],RAX   ; *Try = *Try + 8   
      !JMP _WhileTry                  ; Repeat While Loop
    ;Wend
    !_Return:
    ProcedureReturn ret 
  		
  	; Witness bases
  	DataSection 
  		Lower_2047:                 : Data.q 2, 0
  		Lower_1373653:              : Data.q 2, 3, 0
  		Lower_9080191:              : Data.q 31, 73, 0
  		Lower_25326001:             : Data.q 2, 3, 5, 0
  		Lower_3215031751:           : Data.q 2, 3, 5, 7, 0
  		Lower_4759123141:           : Data.q 2, 7, 61, 0
  		Lower_1122004669633:        : Data.q 2, 13, 23, 1662803, 0
  		Lower_2152302898747:        : Data.q 2, 3, 5, 7, 11, 0
  		Lower_3474749660383:        : Data.q 2, 3, 5, 7, 11, 13, 0
  		Lower_341550071728321:      : Data.q 2, 3, 5, 7, 11, 13, 17, 0
  		Lower_3825123056546413051:  : Data.q 2, 3, 5, 7, 11, 13, 17, 19, 23, 0
  		Lower_18446744073709551616: : Data.q 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 0
  	EndDataSection
  		
  EndProcedure
  
  Procedure.i PrimeSieve_SumAlgo (Limit.i, Array *Primes(1)) ; *Primes(1) Pointer to a 1 dimensional Array of Integer
  ; ============================================================================
  ; NAME: PrimeSieve_SumAlgo
  ; DESC: Calculates all Primes up to users Limit with the sum algorithm
  ; DESC: and returns all found Primes in the Integer Array Primes().
  ; DESC: And the number of found Primes as Retrun Value
  ; VAR(Limit.i) : The limit up to primes are searched
  ; RET.i : Number of found Prime numbers.
  ; ============================================================================
    
  ;   Die Funktion wurde nach Hinweisen von Holger Suhr gegenüber der Original-Funktion (s.u.) verbessert.
  ; 	Summenverfahren
    Protected K, J, N   ; Counter
    Protected idxPrim, X, p, IsPrime, root
    Protected NoP
    
    ; Tschebyscheff aproximation for the number of Primes: 0.912*x/ln(x) < pi(x) < 1,1056*x/ln(x)
    NoP = GetMaxNoOfPrimes(Limit) * 1.1
    
    #BufferEntries = 10000
    
   	Dim *Primes(NoP)
   	Dim psum(NoP)
   	
   	root = Sqr(Limit) + 1
   	
   	; the first Primes we know. 2x3x5=30 This is the Mod30 Filter which elemiates all products of 2,3,5
   	*Primes(0) = 2
   	*Primes(1) = 3
   	*Primes(2) = 5
   	
   	X = 7              ; The 1st Prime Candidate we start To test
   	idxPrim = 2        ; The index of 5 in P() is 2
   	
   	psum(3) = 7*7     ; we can start with the sum at p² because the lower values are reached with prims < 7
   	
   	; J is our Prime-Candidate counter. With this counter (J & 7) we step trough RCdelta() and calculate next candidate 
    ; we have to start at J=1 because we start with 7 as first candiate and the next candidate will be 11 so the
   	; difference 11-7 = 4 and this is entray No 1 RCdelta() : RCdelata(1)= 4 =  11-7
   	J = 1
    	
   	; ----------------------------------------------------------------------
   	;   Main Loop: do for all Prime Candidates up to users limit
   	; ----------------------------------------------------------------------
   	While X <= Limit      ; As long as out Prime test candidate is lower than the user requested limit
  
   		K = 3               ; we start with indes of p() at 3 what is 7 because 2,3,5 is eliminated with Mod30() filter
   		IsPrime = #True      
   		
   		; ----------------------------------------------------------------------
   		;  Sum up all Primes from [7.. Sqr(X)] up to X
   	  ; ----------------------------------------------------------------------
  		While  (K < idxPrim) And (*Primes(K) <= root)   ; K is lower than the index of our Prime Candidate and p(k) < lower than users Limit
  		 ; N = 0   ; debug Counter         
  		  
  		  While psum(K) < X     ; Sum up all p(k) up to the actual Prime Candidate
          ; Sum p(k)*2 because +p(k) would result in an even No. what can't be a Prime
          ; it would be possible to sum p(k) * RCdelta([6,4,2,4,2,4,6,2])
  		    ; I didn't test it but I guess a fewe mor Adds are faster than finding out the correct factor. 
  			  psum(K) = psum(K) + *Primes(K)*2
  			  N+1  ; debug Counter
  			Wend
  			
  			; Debug "N = " + Str(N) + " : P = " + Str(*Primes(k)) + " : X = " + Str(X)	
  			
  			; If we reach with our sum exactly the value of the Prime Candidate, it is not a Prime!
  			If psum(k) = X
   			  IsPrime = #False
          Break           ; leave While Loop and countinue with the next Candidate
   			EndIf
   			K + 1             ; Continue sum with next p(K+1)
      Wend
   	  ; ----------------------------------------------------------------------
      
      ; If the Prime Candidate is a Prime, add it to the list of Primes.
   		If IsPrime
   			idxPrim= idxPrim + 1      ; next index in Prime List
   			*Primes(idxPrim) = X        
   			psum(idxPrim) = X*X       ; We can start the Sum at X². (The lowest value what can't be reached by lower Primes)
       EndIf
      
      ; calculate the next Prime Candidate in the Mod(30) filter range 
      X = X + RCdelta(J & 7)    ; here we add a value form RCdelta([6,4,2,4,2,4,6,2]) to get the next Prime Candidate Mod30() filtered
      J = J + 1                 ; J is the iteration counter. It's value is the number of tested candidates
   	Wend
   	; ----------------------------------------------------------------------
   	
   	FreeArray(psum())
   	; Debug "Cycles = " + J
   	ProcedureReturn idxPrim + 1 	; Return the number of found Primes
   	
  EndProcedure
  
  Procedure.q ListPrimes(Limit.q, Array *Primes(1))
  ; ============================================================================
  ; NAME: ListPrimes
  ; DESC: Lists all Primes from 3..Limit
  ; DESC: 
  ; DESC: 
  ; VAR(Limit) : The limit up to primes are searched
  ; VAR(*Primes(1)) : Array to List the Primes
  ; RET.i : Number of Primes found
  ; ============================================================================
   Protected.q I, N
    
    Dim *Primes(GetMaxNoOfPrimes(Limit))
    
    For I = 3 To Limit Step 2
      If IsPrime_x64(I)
        *Primes(N) = I
        N+1
      EndIf
    Next
    
    ProcedureReturn N
  EndProcedure
  
  Procedure CountMod120(Array *Primes(1), N.q, Array *OutCnt(1))
    Protected.q I, J, R
    
    Dim *OutCnt(31)
    
    For I = 0 To (N-1)
      R = *Primes(I)  % 120
      J = RCIndex(R)
      *OutCnt(J) + 1  
    Next
    
  EndProcedure
  
  DataSection
    RestClasses:
    Data.i   1,  7,  11,  13,  19,  23,  29
    Data.i  31, 37,  41,  43,  49,  53,  59
    Data.i  61, 67,  71,  73,  79,  83,  89
    Data.i  91, 97, 101, 103, 109, 113, 119  
  EndDataSection

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
  
  Global Dim Prim(0) 
  Global Dim Squars(0)
  Global Dim CntM120(31)
  Global Dim CntSqr(31)
  
  Procedure.i PrimSquares(Lim, Array *Primes(1), N, Array *OutSquares(1))
    Protected I, J, S, u
    
    u = ArraySize(*Primes())
    
    Dim *OutSquares(u/4)
    Debug "Ubound : " + Str(u) 
    Debug "Limit = " + Lim
    
    For I = 0 To N-1
      S = *Primes(I)
      If S=0 
        Break
      EndIf
      
      S = S * S
;     Debug "Quadrat = " + S
      
      While (S < Lim)
         Debug "S= " + S
         *OutSquares(J) = S
          S = S * *Primes(I)  * *Primes(I)
          J = J + 1
          Debug "J= " +Str(J)   
       Wend     
     
     
     S =  *Primes(I)
     S = S*S*S
     
     While (S < Lim)
 ;        Debug "S= " + S
         *OutSquares(J) = S
          S = S * *Primes(I)  * *Primes(I)
          J = J + 1
          Debug "J= " +Str(J)   
       Wend     
     Next
     
    ProcedureReturn J
  EndProcedure

  Procedure CountPrimesMod()
    Protected N, NSq, I, sum, R, L, mem
    
    #Limit = 100000
    
    N = ListPrimes(#Limit, Prim())
    CountMod120(Prim(), N, CntM120())
    
    NSq = PrimSquares(#Limit, Prim(), N, Squars()) 
    Debug "Squares= " +NSq
    CountMod120(Squars(), NSq, CntSqr())
    
    
    Debug ""
    Debug "NoOfPrimes = " +Str(N)
    Debug ""
    Debug "Number of Primes Mod 120"
    For I=0 To 31
      Debug "RC= " + Str(RC(I)) + " : cnt= " + CntM120(I) + " : csq = " + Str(CntSqr(I))
      sum + CntM120(I)
    Next
    Debug ""
    Debug "Sum= " + Str(sum)
    Debug "Average = " +Str(N/32)
    
    Debug ""
    
    #Mod = 30
    #Rest = 11
    
    For I = 1 To N
      R= Prim(I) % #Mod  
      If R = #Rest
        L = Prim(I) / #Mod 
        Debug "I= " + Str(I) + " : L= " + Str(L) + " : P=" + Prim(I) + " : D= " + Str(L-mem)
        mem = L
      EndIf  
    Next
    
  EndProcedure
  
   
  Procedure RestCombi()
    Protected I, J, R
      
    For J = 0 To 30
      
      For I=J+1 To 31
        R = (RC(I) * RC(J)) % 120
        CntM120(RCIndex(R)) + 1
      Next
    Next
    
    Debug "Restclassen summiert"
    For I = 0 To 31
      Debug CntM120(I)
    Next
  EndProcedure
  
  
  Procedure Test_PrimeFactors()
    Protected.q Number, res
    Protected.s str
    Protected I, cnt, cnt2, cnt3, IsP, t1, t2, t3
    
    Number = 9007199254740991
    ;Number = (1<<31)-1  ; 8te Mersenn Primzahl 2^31-1 =            2.147.483.647
    ;Number = (1<<61)-1  ; 9te Mersenn Primzahl 2^61-1 = 2.305.843.009.213.693.951
    Number = 715827881 * 2147483647
    ;Number = 4294967295  ; Product of the first 5 Fermat Primes
    
    NewList Factors.q()
    
    t1 = ElapsedMilliseconds()
    cnt = PrimeFactors(Number, Factors())
    t1 = ElapsedMilliseconds()-t1
    
    #Loops = 1000000

    t2 = ElapsedMilliseconds()
      For I = 1 To #Loops Step 2
        If IsPrime(I)
          cnt2+1
        EndIf
      Next
    t2 = ElapsedMilliseconds()-t2
    
    ; IsPrime_x64 Miller Rabin Test
    t3 = ElapsedMilliseconds()
      For I = 1 To #Loops Step 2
        If IsPrime_x64(I)
          cnt3+1
        EndIf
      Next
    t3 = ElapsedMilliseconds()-t3

    ResetList(Factors())
    
    res = 1
    ForEach Factors()
      res * Factors()    
    Next
    
    str = "Number   = " + Str(Number) + #CRLF$
    Str + "SqrRoot  = " + Str(Int(Sqr(Number))) + #CRLF$
    str + "Result P!  = " + Str(res) + #CRLF$ 
    str + "Iterations = " + Str(cnt) + #CRLF$
    str + "Time       = " + Str(t1) + "ms" + #CRLF$
    str + #CRLF$
    str + "Prime Factors " 
    ForEach Factors()
      str + #CRLF$ + Str(Factors())
    Next
    Str + #CRLF$
    str + #CRLF$ + "PB  = " + Str(t2) + " : Primes found = " + Str(cnt2)
    str + #CRLF$ + "ASM= " + Str(t3) + " : Primes found = " + Str(cnt3)
    
   
    ClearClipboard()  ; Clear the Clipboard
    SetClipboardText(str) ; Paste text to the clipboard..
    
    MessageRequester("Prime Factors", str, #PB_MessageRequester_Ok)  
  EndProcedure
  
  CountPrimesMod()
  ; RestCombi()
CompilerEndIf
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 675
; FirstLine = 578
; Folding = ----
; Optimizer
; CPU = 5