; ===========================================================================
;  FILE : PbFw_Module_Integer.pb
;  NAME : Module Integer [INT::]
;  DESC : Provides raw Integer operations that do not use 
;  DESC : Floating-Point conversion for calculating.
;  DESC : Generally this is slower in calculation but provides
;  DESC : the full bit resultion without any rounding.
;  DESC : For PB especally in C-Backend the result for Integer operations
;  DESC : using Floating unit may differ from ASM Backend result when
;  DESC : Integers with more than 53 Bits are used.
;  DESC : Try in C-Backend Abs(1234567891234567890) = 1234567891234567936
;  DESC : The difference is 46. This is because of the rounding in to 53
;  DESC : Bit in C-Backend.  In ASM the full 80Bit float is used, so
;  DESC : in ASM-Backend the results are correct.
;  DESC : In some circumstances native Integer operations are good to have. 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/02/11
; VERSION  :  0.1 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;  2024/01/28 S.Maag : added ASM x64 optiomations for CountChar, ReplaceChar
;                      added Fast LenStr_x64() function and Macro LenStrFast()
;                        to use it only at x64!
;  2024/01/20 S.Maag : added ToggleStringEndianess()
;                      faster Version for RemoveTabsAndDoubleSpace()
;                      RemoveTabsAndDoubleSpaceFast(*String); Pointer Version
;                      moved String File-Functions to Module FileSystem FS::
;}
;{ TODO:
;}
; ===========================================================================

;- --------------------------------------------------
;- Include Files
;  --------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"          ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_PX.pb"            ; PX::      Purebasic Extention Module
; XIncludeFile ""


DeclareModule INT

;   ; AbsI() and AbsQ() solve tha PB's ABS() Problem at C-Backend
;   ; because at ASM Backend the 80Bit Float unit is used for ABS() what works perfect for 64Bit INT
;   ; In C-Backend a MMX Version is used for ABS(). This is a problem because MMX use only 64Bit Floats
;   ; with a manitassa of 53 Bits. This will cause bugs if the ABS() is used for values with more bits
;   ; like address calculation!
;   
;   ; This is the optimized Abs Version (translated from Assembler to PB-Code; Soure Math.asm from Linux Asm Project
;   ; X!(X>>63)-(X>>63) ; x64
;   ; X!(X>>31)-(X>>31) ; x32
;   
;   ; Assembler_ShiftArithmeticRight_Bits : This is how to cacluclate the NumberOfBits to shift
;   ; its 63 for x64 und 31 for x32
;   #ABS_SHIFT_BITS = (SizeOf(Integer)*8-1)    
;   
;   ; PB 6.04 on Ryzen 5800 the Macro is nearly same speed as PB's ABS()
;   ; ASM BAckend: For 100Mio calls (50% with -X and 50% with +X) :  PB_ABS() = 53ms  AbsI() = 58ms
;   CompilerIf #PB_Compiler_Backend =#PB_Backend_Asm
;     Macro AbsI(X)
;       Abs(X)
;     EndMacro
;   CompilerElse  ; C-Backend
;     Macro AbsI(X)
;       (X!(X>>#ABS_SHIFT_BITS)-(X>>#ABS_SHIFT_BITS))
;     EndMacro
;   CompilerEndIf
;   
;   ; only for x32 we need an extra Macro for AbsQ() which shifts 63 Bit for Quads
;   CompilerIf #PB_Compiler_Backend =#PB_Backend_Asm
;     Macro AbsQ(X)
;       Abs(X)
;     EndMacro
;   CompilerElse  ; C-Backend
;     Macro AbsQ(X)
;       (X!(X>>63)-(X>>63))
;     EndMacro
;   CompilerEndIf
;   
   Declare.i SqrI(X.i)
   Declare.i RootN(Number.i, N.i) 

EndDeclareModule

Module INT
  
  Procedure.i SqrI(X.i)
  ; ============================================================================
  ; NAME: SqrI
  ; DESC: A raw integer Square-Root function using iterative calcualtion
  ; DESC: Because PB's Sqr() rounds the result to the nearest Integer
  ; DESC: what it isn't always a correct result in native Integer math.
  ; DESC: N.i = Sqr(7) = 3 and 3*3=9  F.f=Sqr(7)=2.64575. It's automaitcally
  ; DESC: rounded up to the nearest if you use Integer variables.
  ; DESC: An other fix for that Problem is N.i = Round(Sqr(7), #PB_Round_Down)
  ; DESC: But in some circumstances it's good to have native Integer math!
  ; VAR(X): The value to calculate the square root from.
  ; RET.i : The native Integer Square Root
  ; ============================================================================
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
      ; this is a hand otimized ASM-Code for the PB-Code below
      ; it's 2..3 times faster than the PB-Code but 3..4 times slower than
      ; PB-BuidIn Sqr() using Floating Point Unit
      
      CompilerIf #PB_Compiler_64Bit
        
        ; used Registers
        ; R8  = X
        ; RDX = Q
        ; RCX = T
        ; RAX = R
        
        !XOR RAX, RAX     ; R=0
        !XOR RDX, RDX     ; Q=0
        
        ; While Q<=X : Q<<2 : Wend
        ;  - can be reduced to a BitSet
        !MOV R8, QWORD[p.v_X]   ; Load X
        !BSR RCX, R8            ; BitScanReverse => NoOf(MSB)
        !BTR RCX, 0             ; Reset Bit 0 from NoOf(MSB) => Make NoOf(MSB) even!
        !ADD RCX, 2             ; Even(NoOf(MSB) + 2 => We get the Even BitNo higher than MSB
        !BTS RDX, RCX           ; set the BitNo in Q
            
        !.Loop:
        !CMP RDX, 1             ; While Q > 1
        !JLE .EndLoop
          !SHR RDX, 2             ; Q>>2 : Q/4
          ; T = X -R -Q
          !MOV RCX, R8            ; T = X
          !SUB RCX, RAX           ; T - R
          !SUB RCX, RDX           ; T - Q
          !SHR RAX, 1             ; R>>1 : R/2
          
          !Test RCX, RCX        
          !JL @f                  ; If T > 0
            !MOV R8, RCX            ; X = T
            !ADD RAX, RDX           ; R + Q
           !@@:                   ; Endif
        !JMP .Loop              ; Wend
        !.EndLoop:
          
        ProcedureReturn  
        
      CompilerElse            ; #PB_Compiler_32Bit
        
        Protected mEBX
        ; used Registers
        ; EBX = X
        ; EDX = Q
        ; ECX = T
        ; EAX = R
        
        !MOV [p.v_mEBX], EBX      ; PUSH EBX
        
        !XOR RAX, RAX     ; R=0
        !XOR RDX, RDX     ; Q=0
        
        ; While Q<=X : Q<<2 : Wend
        ;  - can be reduced to a BitSet
        !MOV EBX, QWORD[p.v_X]  ; Load X
        !BSR ECX, EBX           ; BitScanReverse => NoOf(MSB)
        !BTR ECX, 0             ; Reset Bit 0 from NoOf(MSB) => Make NoOf(MSB) even!
        !ADD ECX, 2             ; Even(NoOf(MSB) + 2 => We get the Even BitNo higher than MSB
        !BTS EDX, ECX           ; set the BitNo in Q
           
        !.Loop:
        !CMP EDX, 1             ; While Q > 1
        !JLE .EndLoop
          !SHR EDX, 2             ; Q>>2 : Q/4
          ; T = X -R -Q
          !MOV ECX, EBX           ; T = X
          !SUB ECX, EAX           ; T - R
          !SUB ECX, EDX           ; T - Q
          !SHR EAX, 1             ; R>>1 : R/2
          
          !Test ECX, ECX        
          !JL @f                  ; If T > 0
            !MOV EBX, ECX           ; X = T
            !ADD EAX, EDX           ; R + Q
           !@@:                   ; Endif
          !JMP .Loop            ; Wend
          !.EndLoop:
          
          !MOV EBX, [p.v_mEBX]  ; POP EBX 
        ProcedureReturn  
   
      CompilerEndIf
  
    CompilerElse
      
      ; https://rosettacode.org/wiki/Isqrt_(integer_square_root)_of_X#C
      Protected.i Q =1 
      Protected.i T, R
      
      If X > 0  ; No Sqr for negative X
        
        ; find the Even BitNo higher than in X
        While Q <= X 
          Q << 2 
        Wend
        
        While Q > 1
          Q >> 2  
          T = X -R -Q
          R >> 1
          If T >= 0
            X = T
            R + Q
          EndIf
        Wend
      EndIf
      
      ProcedureReturn R
  
    CompilerEndIf
  EndProcedure

  Procedure.i PowI(Number, Exponent)
  ; ============================================================================
  ; NAME: PowI
  ; DESC: A raw integer Power function using iterative calcualtion
  ; DESC: Attention it is limited to 31 Bit/x32 and 63 Bit/x64
  ; DESC: Use only if you need raw Integer calculation in that ranges
  ; DESC: Otherwise use PB's Pow() function with Floats
  ; VAR(Number): The Number
  ; VAR(Exponent): The Exponent 
  ; RET.i : Number^Exponent
  ; ============================================================================
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
      
      CompilerIf #PB_Compiler_64Bit
        !XOR RAX, RAX
        !INC RAX     
        !MOV R8, [p.v_Exponent]
        !TEST R8, R8        
        !JZ .Return           ; Return 1 if Exponent = 0
        
        !MOV RAX, [p.v_Number]  ; Load Number   
        !MOV RCX, [p.v_Number]
        ; Decrement Exponent first to use faster TEST instruction instead of CMP RDX, 1
        !DEC R8                
        !.Loop
        !TEST R8, R8
        !JLE @f
          !MUL RAX, RCX     ; saves the result in RAX:RDX
          !DEC R8
        !@@:
        !.Return:
        ProcedureReturn
        
      CompilerElse    ; #PB_Compiler_32Bit
        
        Protected mEBX
        !MOV [p.v_mEBX], EBX  ; PUSH EBX
        
        !XOR EAX, EAX
        !INC EAX     
        !MOV ECX, [p.v_Exponent]
         !TEST ECX, ECX        
        !JZ .Return           ; Return 1 if Exponent = 0
        
        !MOV EAX, [p.v_Number]  ; Load Number      
        !MOV EBX, [p.v_Exponent]
        ; Decrement Exponent first to use faster TEST instruction instead of CMP RDX, 1
        !DEC ECX                
        !.Loop
        !TEST ECX, ECX
        !JLE @f
          !MUL EAX, EBX   ; saves the result in EAX:EDX
          !DEC ECX
        !@@:
        !.Return:
        !MOV EBX, [p.v_mEBX]  ; POP EBX
        ProcedureReturn
       
      CompilerEndIf
      
    CompilerElse
      
      Protected res = Number
      
      While Exponent > 1
        res * Number
        Exponent -1
      Wend
      ProcedureReturn Res
      
    CompilerEndIf
    
  EndProcedure
  
  Procedure.i RootN(Number.i, N.i) 
  ; ============================================================================
  ; NAME: RootN
  ; DESC: Calculates the N'th Root of Number as native Integer.
  ; DESC: Ther is no use of the Floating Point Unit which can cause
  ; DESC: rounding effects.
  ; DESC: The PB BuildIn to calculate N'th Root with FPU is Pow(Number, 1/N)
  ; VAR(Number): The number to calculate the N'th root from.
  ; VAR(N): The N to caclculate N'th root
  ; RET.i : The N'th Root of Number
  ; ============================================================================
    
    ;https://rosettacode.org/wiki/Integer_roots#C
    Protected.i N1, N2, N3, C, D, E;

    If Number < 2 
      ProcedureReturn Number
    EndIf
    
    If N = 0
      ProcedureReturn 1;
    EndIf
    
    N1 = N - 1
    N2 = N
    N3 = N1
    C = 1
    
    D = (N3 + Number) / N2
    E = (N3 * D + Number / PowI(D, N1)) / N2

    While (C <> D And C <> E)
      C = D
      D = E
      E = (N3 * E + Number / PowI(E, N1)) / N2
    Wend

    If D < E 
      ProcedureReturn D
    EndIf
    
    ProcedureReturn E
    
  EndProcedure

EndModule


; ===========================================================================
;  Test-Code
; ===========================================================================

CompilerIf  #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  Procedure.i procAbs(X)
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
      CompilerIf #PB_Compiler_64Bit
        !MOV RDX, [p.v_X]
        !MOV RAX, RDX
        !SAR RDX, 63      ; RDX = X>>63
        !XOR RAX, RDX     ; RAX = X!(X>>63)
        !SUB RAX, RDX     ; RAX = RAX - RDX = X!(X>>63) - (X>>63)
        ProcedureReturn 
      CompilerElse
        !MOV EDX, [p.v_X]
        !MOV EAX, EDX
        !SAR EDX, 31
        !XOR EAX, EDX
        !SUB EAX, EDX
        ProcedureReturn   
      CompilerEndIf
      
    CompilerElse ; C-Backend
      ProcedureReturn AbsI(X)
    CompilerEndIf
  EndProcedure
    
  Procedure.i PB_SqrI(X)
    Protected Q=1 
    Protected T, R
    
    While Q <= X 
      Q << 2 
    Wend
    
    While Q > 1
      Q >> 2  
      T = X -R -Q
      R >> 1
      If T >= 0
        X = T
        R= R + Q
      EndIf
    Wend
    
    ProcedureReturn R
  EndProcedure
  
  UseModule INT

  Define I, K, L, N, t1, t2, t3, t4
  
  CompilerIf #PB_Compiler_Debugger
    ; to see the Bug you have to switch on Compiler\Compiler Options\Optimze generated code
    ; or set CPU with MMX/SSE 
     N = 1234567891234567890   ; in C Backend the difference is 46
    ; N =  1<<54 -1             ; in C Backend the difference is 1
    Debug "N = " + N
    Debug "Hex(N) = " + Hex(N)
    Debug #Null$
    
    Debug "In C-Backend this is wrong! If Compiler\Compiler Options\Optimze generated code is activated or MMX/SSE CPU is selected"
    K = Abs(N)
    Debug "PB Abs(N)  = " + K
    K = Abs(-N)
    Debug "PB Abs(-N) = " + K
  
    Debug #Null$
    Debug "Macro AbsI()"
    K = PX::AbsI(N)
    Debug K
    K = PX::AbsI(-N)
    Debug K
    
    Debug #Null$ 
    K = PX::AbsI(N)
    L= Abs(N)
    K -L
    Debug "AbsI(N) - Abs(N) = " + K
    Debug "The difference should be 0 but in C-Backend it is not!"
    
    For I = 1 To 25
      Debug Str(I) + " : " + Str(SqrI(I) )  
    Next
    
    Debug "RootN"
    Debug RootN(166375,3)
  CompilerElse
    
    #Start = 100000000000000005
    #LOOPS = 100000000  ; 50Mio
    t1 =$123
    t1 = ElapsedMilliseconds()
    For I = 1 To #LOOPS
      K =  PX::AbsI(-I)
      L =  PX::AbsI(I)
    Next
    t1 = ElapsedMilliseconds() - t1
    
    t2 = ElapsedMilliseconds()
    For I = 1 To #LOOPS
      K =  Abs(-I)
      L =  Abs(I)
    Next
    t2 = ElapsedMilliseconds() - t2
  
    t3 = ElapsedMilliseconds()
    For I = 1 To #LOOPS
      K =  procAbs(-I)
      L =  procAbs(I)
    Next
    t3 = ElapsedMilliseconds() - t3
   
    MessageRequester("Time", "Macro AbsI() = " + Str(t1) + #CRLF$ + "PB Abs() = " + Str(t2) + #CRLF$ + "ASM procAbs() = " + Str(t3))
  CompilerEndIf
  
CompilerEndIf
; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 448
; FirstLine = 409
; Folding = ---
; Optimizer
; Executable = ..\Test\AbsTest_C_x64.exe
; CPU = 5