; ===========================================================================
;  FILE : Module_Math.pb
;  NAME : Module Math
;  DESC : Mathematic Functions Library
;  DESC : 
; ===========================================================================
;
; AUTHOR   : Stefan Maag
; DATE     : 2022/10/30
; VERSION  : 0.01 untested Developer Version
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

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

; XIncludeFile ""

DeclareModule Math
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

  Macro mac_IsInRange(value, min, max)
    Bool(value >= min) And Bool(Val <= max)  
  EndMacro 
  
  Macro mac_IsEqual(x1, x2, delta)
    (x1 <= (x2 +delta)) And (x1 >= (x2 -delta))
  EndMacro

  Macro _mac_Exp2(value)
    (value * value)
  EndMacro
  
  Macro _mac_Exp3(value)
    (value * value * value)
  EndMacro

  Macro mac_Hypothenuse(A, B)
  ; ============================================================================
  ; NAME: Hypothenuse
  ; DESC: Calculates the Hypothenuse of a Triangle with Pythagoras c²=a²+b²
  ; VAR(A): Legnth Triangel leg A
  ; VAR(B): Legnth Triangel leg B 
  ; RET : Legnth of Hypothenuse c=Sqr(a²+b²)
  ; ============================================================================
    Sqr(A*A + B*B)  
  EndMacro
  Declare.d Hypothenuse(A.d, B.d)   ; Procedure Version of Hypothenuse()
  
  Macro mac_Lerp(A, B, T)   
  ; ============================================================================
  ; NAME: Lerp
  ; DESC: Blending between A..B from 0..100% with T={0..1}
  ; DESC: 
  ; VAR(A): Startvalue A 
  ; VAR(B): Endvalue   B 
  ; VAR(T) : Time Value {0..1} = {0..100%}
  ; RET : Lerped Value in the Range {ValStart..ValEnd}
  ; ============================================================================
 
    A + (B-A) * T   ; A*(1-T) + B*T
  EndMacro
  ; InverseLerp Get the T={0..1} for the blended Value V in the Range {A..B}
  Declare.d Lerp(A.d, B.d, T.d)  ; Procedure Version of Lerp()
    
  Macro mac_InverseLerp(A, B, V)
  ; ============================================================================
  ; NAME: InverseLerp
  ; DESC: Get the BlendingTime T{0..1} of the Value V in the Range 
  ; DESC: A..B 
  ; DESC: 
  ; VAR(A): Startvalue A 
  ; VAR(B): Endvalue   B 
  ; VAR(T): Time Value {0..1} = {0..100%}
  ; RET : Blendig Time of the Value V {0..1} = {0..100%}
  ; ============================================================================  
    (V-A)/(B-A)
  EndMacro
  Declare.d InverseLerp(A, B, V) ; Procedure Version of InverseLerp()
    
  Macro mac_Remap(val, inMin, inMax, outMin, outMax)
  ; ============================================================================
  ; NAME: Remap
  ; DESC: Scales a value what is in the 
  ; DESC: Range {inMin..inMax} ro a new Range {outMin..outMax}
  ; DESC: 
  ; DESC:                       (outMax - outMinOut)
  ; DESC: ret = (val - inMin) ------------------------  + outMin
  ; DESC:                         (inMax - inMin) 
  ; DESC: 
  ; VAR(val) : Pointer to Return-Vector VECf::TVector
  ; VAR(inMin) : Input Range Minimum
  ; VAR(inMax) : Input Range Maximum
  ; VAR(outMin): Output Range Minimum
  ; VAR(outMax): Output Range Maximum
  ; RET : the Value val scaled to the Output Range
  ; ============================================================================     
    (outMax - outMin)/(inMax - inMin) * (val - inMin) + outMin
  EndMacro
  
  Declare.d BinomialCoefficient(N.i, K.i)
  Declare.i GreatestCommonDivisor(A.i, B.i)
EndDeclareModule


Module Math
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
    
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------

  Procedure.d Hypothenuse(A.d, B.d)
  ; ============================================================================
  ; NAME: Hypothenuse
  ; DESC: Calculates the Hypothenuse of a Triangle with Pythagoras c²=a²+b²
  ; VAR(A): Legnth Triangel leg A
  ; VAR(B): Legnth Triangel leg B 
  ; RET : Legnth of Hypothenuse c=Sqr(a²+b²)
  ; ============================================================================
   ProcedureReturn Sqr(A*A + B*B) 
  EndProcedure 
  
  Procedure.d Lerp(A.d, B.d, T.d)  ; Return the blended Value  
  ; ============================================================================
  ; NAME: Lerp
  ; DESC: Blending between A..B from 0..100% with T={0..1}
  ; DESC: 
  ; VAR(A): Startvalue A 
  ; VAR(B): Endvalue   B 
  ; VAR(T) : Time Value {0..1} = {0..100%}
  ; RET : Lerped Value in the Range {ValStart..ValEnd}
  ; ============================================================================
    ProcedureReturn A + (B-A) * T  ; A*(1-T) + B*T
  EndProcedure 
  
  ; InverseLerp Get the T={0..1} for the blended Value V in the Range {A..B}
  Procedure.d InverseLerp(A, B, V) ; Return the Time of the blended Value T {0<= T <=1} 
  ; ============================================================================
  ; NAME: InverseLerp
  ; DESC: Get the BlendingTime T{0..1} of the Value V in the Range 
  ; DESC: A..B 
  ; DESC: 
  ; VAR(A): Startvalue A 
  ; VAR(B): Endvalue   B 
  ; VAR(T) : Time Value {0..1} = {0..100%}
  ; RET : Blendig Time of the Value V {0..1} = {0..100%}
  ; ============================================================================
    ProcedureReturn (V-A)/(B-A)
  EndProcedure
    
  Procedure.d Remap(val.d, inMin.d, inMax.d, outMin.d, outMax.d) ; Scale Range(inMin..inMay) -> (outMin..outMax)
  ; ============================================================================
  ; NAME: Remap
  ; DESC: Scales a value what is in the 
  ; DESC: Range {inMin..inMax} ro a new Range {outMin..outMax}
  ; DESC: 
  ; DESC:                       (outMax - outMinOut)
  ; DESC: ret = (val - inMin) ------------------------  + outMin
  ; DESC:                         (inMax - inMin) 
  ; DESC: 
  ; VAR(val) : Pointer to Return-Vector VECf::TVector
  ; VAR(inMin) : Input Range Minimum
  ; VAR(inMax) : Input Range Maximum
  ; VAR(outMin): Output Range Minimum
  ; VAR(outMax): Output Range Maximum
  ; RET : the Value val scaled to the Output Range
  ; ============================================================================
    ProcedureReturn (outMax - outMin)/(inMax - inMin) * (val - inMin) + outMin
  EndProcedure
  
  
  ; Invertiert einen Wertebereich (Messrichtungsumkehr), vertauscht sozusagen Oberund Untergrenze.
  ; Bei symetrischen Wertebereichen: MIN = -MAX ist das einfach eine Vorzeichenumkehr.
  ; Ein Wert, der im Wertebereich mit T={0..1} von [20..100] läuft wird dann zu [100..20]  
  ;
  ;   MIN=-100 MAX=100 VALUE=20 : ret= -20
  ;   MIN=  20 MAX=100 VALUE=20 : ret= 100
  ;                    VALUE=50 : ret=  70 
  
  Macro mac_InvertRange(val, Min, Max)
    ; ret = Max - Val + Min
    Max - Val + Min
  EndMacro
  Procedure.d InvertRange(val.d, Min.d, Max.d)
    ProcedureReturn Max - Val + Min
  EndProcedure
  
  Procedure.d BinomialCoefficient(N.i, K.i)
  ; ======================================================================
  ; NAME: BinomialCoefficient
  ; DESC: Calculate Binominal Coefficient N over K
  ; DESC:  
  ; DESC:                               N! 
  ; DESC:   BinomialCoefficient = -----------------
  ; DESC:                          ((N - K)! * K!) 
  ; DESC:
  ; DESC: for the calculation, the ROW representation of the algorithm
  ; DESC: is used. An explicite calculation of N! (N-K)! and K!
  ; DESC: ist not necessary. It is a calculation in a Loop
  ; DESC: This code is the port of the Rosetta Code ADA expample from
  ; DESC: https://rosettacode.org/wiki/Evaluate_binomial_coefficients#Ada
  ; VAR(N): N
  ; VAR(K): K
  ; RET.e : Binomial Coefficient 
  ; ======================================================================
     
    Protected.i I, M
    Protected.d ret=1.0
   
    If N>K
      If K>=1     
        If K > N/2    ; Use symmetry
          M=N-K
        Else
          M=K
        EndIf     
        For I = 1 To M
          ret= ret * ((N-M+I)/I)  
        Next I     
      EndIf
    EndIf      
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i GreatestCommonDivisor(A.i, B.i)   ; GCD(A, B)
  ; ======================================================================
  ; NAME: GreatestCommonDivisor
  ; DESC: Calculates the greatest common divisor of A and B
  ; DESC: Iterative Euclid Algorithm
  ; VAR(A.i): First Value As Integer
  ; VAR(B.i): Second Value As Integer
  ; RET.i: Greatest common Divisor of A and B
  ; ======================================================================
    Protected.i C
    While B
      C = A
      A = B
      ;B = C % B
      B = _mac_Modulo(C, B) ; Macro with Modulo SpeedOptimation
    Wend
    ProcedureReturn A
  EndProcedure

  Procedure BresenhamLine(x0 ,y0 ,x1 ,y1)
   ;  Bersenham Algorithmus to draw a Line of Pixeles
    Protected xSteep, error
    Protected x, y, dx, dy, xstep, ystep
    
    If Abs(y1 - y0) > Abs(x1 - x0);
      xSteep =#True 
      Swap x0, y0
      Swap x1, y1
    EndIf    
    
    If x0 > x1 
       Swap x0, x1
       Swap y0, y1
    EndIf 
    
    dx = x1 - x0
    dy = Abs(y1 - y0)
    error = dx / 2
    
    y = y0 
    If y0 < y1  
      ystep = 1
    Else
      ystep = -1 
    EndIf 
    
    For x = x0 To x1
      If xSteep 
        Plot(y,x)
      Else 
        Plot(x,y)
      EndIf
      error - dy
      If error < 0 
        y + ystep
        error + dx
      EndIf
    Next        
  EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile    
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------

  EnableExplicit
  UseModule Math
  
  ; ----------------------------------------------------------------------
  ;  Define Variables
  ; ----------------------------------------------------------------------
  
  Procedure Test_PrimeFactors()
    Protected.q Number, time, cnt, res
    Protected.s str
    Number = 9007199254740991
    Number = (1<<31)-1  ; 8te Mersenn Primzahl 2^31-1 =            2.147.483.647
    ;Number = (1<<61)-5  ; 9te Mersenn Primzahl 2^61-1 = 2.305.843.009.213.693.951
    Number = 715827881 * 2147483647
     ;Number = 4294967295  ; Produkt der 5 Fermat Primzahlen
    
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
; CursorPosition = 21
; Folding = -----
; Optimizer
; CPU = 5