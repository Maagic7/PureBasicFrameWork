; ===========================================================================
;  FILE: PbFw_Module_Complex.pb
;  NAME: Module Complex [Complex::]
;  DESC: Complex number 
;  DESC: In mathematics, a complex number is an element of a number system 
;  DESC: that extends the real numbers with a specific element denoted i,
;  DESC: called the imaginary unit. The square of i is (-1); i²=-1
;  SOURCES:  
;     https://www.tf.uni-kiel.de/matwis/amat/mw1_ge/kap_2/basics/b2_1_5.html
;     https://en.wikipedia.org/wiki/Complex_number
;     http://www.flanguasco.org/VisualBasic/VisualBasic.html
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/02/27
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 

;   2023/12/17 S.Maag : finished the hyperbolic functions
;                       tested CHAT-GPT to support the coding
;
;   2023/08/27 S.Maag : As I was ready with the basic implementations
;              I found a full implementation in Visual Basic from 2001
;              what is based on a Fortra77 implementation (Numerical Recipes in Fortran 77)
;              http://www.flanguasco.org/VisualBasic/VisualBasic.html
;              Because of correct mathematical names, I decided to use this 
;              FunctionNames. I added all additional functions of the  
;              Visual Basic version (all the CSin, CCos, CTan, CAsin ...)         
;}
;{ TODO:
;}
; ===========================================================================


;   r = CAbs(Z):        Absolute value of Z, (Vector legnth) 
;   r = CArg(Z):        Argument of Z, (= Angle or Phase) [-#Pi ... #Pi]

;   w = CModQ(Z):       Modulo of Z² in complex format (it is the CAbs in complex format)

;   w = CAdd(Z1, Z2):   add Z1 + Z2.
;   w = CSub(Z1, Z2):   subtract Z1 - Z2.
;   w = CMul(Z1, Z2):   multiply Z1 * Z2.
;   w = CDiv(Z1, Z2):   divide Z1 / Z2.

;   w = CCon(Z):        conjugate Z
;   w = CInv(Z):        inverse or reciprocal value: 1/Z

;   w = CPow(Z, N):     potency Z1 ^ N       
;   w = CPow2(Z, N):    Z²
;   w = CPowC(Z1, Z2):  complex potency Z1 ^ Z2.    
;   w = CSqr(Z):        square root Z

;   w=  CRootN(Z, N)    N'th Root of Z
;   w = CExp(Z):        Expontnent e^Z.
;   w = CLog(Z):        natural logarithm of Z
;
;   w = CSin(Z):        Sine(Z).
;   w = CCos(Z):        Cosine(Z)
;   w = CTan(Z):        Tangent(Z)

;   w = CAsin(Z):       ArcSine(Z).
;   w = CAcos(Z):       ArcSosine(Z)
;   w = CAtan(Z):       ArcTangent(Z)

;   w = CSinh(Z):       HyperbolicSine(Z)
;   w = CCosh(Z):       HyperbolicCosine(Z)
;   w = CTanh(Z):       HyperbolicTangent(Z)

;   w = CAsinh(Z):      HyperbolicArcSine(Z)
;   w = CAcosh(Z):      HyperbolicArcCosine(Z)
;   w = CAtnh(Z):       HyperbolicArcTangent(Z)


;   CSWAP Z1, Z2:       exchange Z1, Z2.
;
;   w() = CPMPY(Z1(), Z2()): polynom product Z1() * Z2().
;
;   S = CFormat$(Z, F): ritorna una stringa rappresentante Z con il formato F.
;   CMsgBox Z:          espone un MsgBox con Z a piena precisione.
;

; ----------------------------------------------------------------------
; Notes on hyperbolic functions
; ----------------------------------------------------------------------
; DE:
; Hyperbelfunktionen werden vor allem im wissenschaftlich-physikalischen Zusammenhang verwendet,
; immer dort wo Geschwindigkeit, Licht, Hitze oder Radioaktivität nach und nach absorbiert wird 
; oder sich verringert, da Zerfall mit diesen Funktionen dargestellt werden kann. 
; Ein weit verbreitetes Beispiel, das häufig benutzt wird, um Anwendungsgebiete
; der Hyperbelfunktionen anschaulich darzustellen, sind die Seile die zwischen zwei Pfeilern (gleiche Höhe)
; gespannt werden. Die Kurve, die sich daraus ergibt – auch Kettenkurve genannt – lässt sich durch
; die hyperbolischen Funktionen darstellen.

; EN:
; Hyperbolic functions are mainly used in scientific and physical contexts,
; wherever speed, light, heat Or radioactivity is gradually absorbed
; or decreases since decay can be represented With these functions.
; A common example to describe areas of application to illustrate the hyperbolic functions clearly
; is a rope tensioned between two pillars (of same height)
; The resulting curve – also called the chain curve – represent the hyperbolic functions.

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
; XIncludeFile "PbFw_Module_Complex.pb"     ; PX::      Complex Math Module

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"       ; DBG::     Debug Module
XIncludeFile "PbFw_Module_CPU.pb"         ; CPU::     CPU-Features
; XIncludeFile ""

DeclareModule Complex
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
    
  Structure TComplex      ; kartesian coordinates
    re.d
    im.d
  EndStructure
    
  Structure TComplexPolar ; Polar coordinates
    R.d                   ; Magnitude, Radius
    Phi.d                 ; Angle [Radian]
  EndStructure
  
  Declare.i CEq(*Z1.TComplex, *Z2.TComplex, eps.d=1e-10) ; As Boolean

  ;  Functions returning a double float
  Declare.d CAbs(*Z.TComplex)
  Declare.d CArg(*Z.TComplex)
  
  ;  Functions returning a Complex
  Declare.i CSet(*OUT.TComplex, re.d, im.d)
  Declare.i CModQ(*OUT.TComplex, *Z.TComplex)
  Declare.i CAdd(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex) 
  Declare.i CSub(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex) 
  Declare.i CMul(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex) 
  Declare.i CDiv(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex) 
  
  Declare.i CCon(*InOut.TComplex)
  Declare.i CInv(*OUT.TComplex, *Z.TComplex) 
   
  Declare.i CPow(*OUT.TComplex, *Z.TComplex, N.i)
  Declare.i CPow2(*OUT.TComplex, *Z.TComplex)
  Declare.i CPowC(*OUT.TComplex, *Z.TComplex, *Z2.TComplex)
  
  Declare.i CSqr(*OUT.TComplex, *Z.TComplex)
  Declare.i CRootN(Array *OUT.TComplex(1), *Z.TComplex, N.i)

  Declare.i CExp(*OUT.TComplex, *Z.TComplex)
  Declare.i CLog(*OUT.TComplex, *Z.TComplex)
  
  Declare.i CSin(*OUT.TComplex, *Z.TComplex)
  Declare.i CCos(*OUT.TComplex, *Z.TComplex)
  Declare.i CTan(*OUT.TComplex, *Z.TComplex)
  
  Declare.i CAsin(*OUT.TComplex, *Z.TComplex)
  Declare.i CAcos(*OUT.TComplex, *Z.TComplex)
  Declare.i CAtan(*OUT.TComplex, *Z.TComplex)
  
  Declare.i CSinh(*OUT.TComplex, *Z.TComplex)
  Declare.i CCosh(*OUT.TComplex, *Z.TComplex)
  Declare.i CTanh(*OUT.TComplex, *Z.TComplex)
  
  Declare.i CAsinh(*OUT.TComplex, *Z.TComplex)
  Declare.i CAcosh(*OUT.TComplex, *Z.TComplex)
  Declare.i CAtanh(*OUT.TComplex, *Z.TComplex)
  
  Declare.i CModQ(*OUT.TComplex, *Z.TComplex)  
  
  ;  Misc Functions
  Declare.i KartesianToPolar(*OUT.TComplexPolar, *Z.TComplex)
  Declare.i PolarToKartesian(*OUT.TComplex, *Z.TComplexPolar)
  Declare.i CSwap(*Z1.TComplex, *Z2.TComplex)
  Declare.i CMsgBox(*Z, Decimals=3)

 EndDeclareModule


Module Complex
  
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- PbFw Module local configurations
  ;  ----------------------------------------------------------------------
  #PbFwCfg_Module_CheckPointerException = #True     ; This constant must have same Name in all Modules. On/Off PoninterExeption for this Module

  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;- ----------------------------------------------------------------------
  ;-  Functions returning a double float
  ;- ----------------------------------------------------------------------
  
  Procedure.i CEq(*Z1.TComplex, *Z2.TComplex, eps.d=1e-10) ; As Boolean
  ; ============================================================================
  ; NAME: CEq
  ; DESC: checks if 2 complex numbers are equal
  ; DESC: Abs = Sqr(Z\re² + Z\im²)
  ; VAR(*Z1.TComplex) : Pointer to complex value Z1
  ; VAR(*Z2.TComplex) : Pointer to complex value Z2
  ; RET.d : #True if the complex numbers are equal
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*Z1, *Z2)      ; Check Pointer Exception

    ; #_Tol = 0.000000000000000001 ; TODO! Change with the CPU Tolerance for a double!
    ; If Abs(*Z1\re - *Z2\re) < #_Tol And Abs(*Z1\im - *Z2\im) < #_Tol
    
    If Abs(*Z1\re - *Z2\re) < eps
      If Abs(*Z1\im - *Z2\im) < eps
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.d CAbs(*Z.TComplex)
  ; ============================================================================
  ; NAME: CAbs
  ; DESC: Cacluclates the absolute value of Z, the length of vector!
  ; DESC: Abs = Sqr(Z\re² + Z\im²)
  ; VAR(*Z.TComplex): Pointer to IN value as ComplexPolar
  ; RET.d : Abs of Z, (Magnitude, length of vector) 
  ; ============================================================================

    DBG::mac_CheckPointer(*Z)      ; Check Pointer Exception
    ; absolute value of Complex (length of Vector, Magnitude)
      
    ProcedureReturn Sqr(*Z\re * *Z\re + *Z\im * *Z\im)    
  EndProcedure
  
  Procedure.d CArg(*Z.TComplex) 
  ; ============================================================================
  ; NAME: CArg
  ; DESC: Cacluclates the Argument of Z, the angel betwween vector and X-Axis
  ; VAR(*Z.TComplex): Pointer to IN value as Complex
  ; RET.d : Argument of Z in the range [-#Pi .. #Pi] 
  ; ============================================================================
    
    DBG::mac_CheckPointer(*Z)      ; Check Pointer Exception
    ; RET.d -Pi ... PI 
    
    ; Ritorna l' argomento del numero complesso z:
    
    ; Das Argument einer komplexen Zahl ist der Winkel zwischen dieser ...
    ; Linie und der positiven reellen Achse (der x-Achse). Phi
    
    ; ProcedureReturn DATAN2(*Z\im, *Z\re)
    ProcedureReturn ATan2(*Z\re, *Z\im)
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;-  Functions returning a Complex Number
  ;- ----------------------------------------------------------------------
  
 
  Procedure CSet(*OUT.TComplex, re.d, im.d)
  ; ============================================================================
  ; NAME: CSet
  ; DESC: Set the parts of a complex cumber
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(re.d) : real part
  ; VAR(im.d) : imaginary part
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    DBG::mac_CheckPointer(*OUT)     ; Check Pointer Exception
  
    *Out\re = re
    *Out\im = im
    
    ProcedureReturn *OUT  
  EndProcedure
  
     
  ; Ghat GPT Code CCMP
  Procedure.i CCmp_(*Z1.TComplex, *Z2.TComplex)
    ; Compare two complex values
    ; Returns 0 if Z1 equals Z2, -1 if Z1 is less than Z2, and 1 if Z1 is greater than Z2
    
    If *Z1\re = *Z2\re And *Z1\im = *Z2\im
      ; Complex values are equal
      ProcedureReturn 0
    ElseIf (*Z1\re < *Z2\re) Or (*Z1\re = *Z2\re And *Z1\im < *Z2\im)
      ; Z1 is less than Z2
      ProcedureReturn -1
    Else
      ; Z1 is greater than Z2
      ProcedureReturn 1
    EndIf
  EndProcedure
  
  Procedure.i CModQ(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CModQ
  ; DESC: Calculate the square of the modulus of a complex number in complex form
  ; DESC: 
  ; VAR(*Z.TComplex): Pointer to IN value as ComplexPolar
  ; RET.d : *OUT or 0 if PointerException
  ; ============================================================================
    ; Calculate the square of the modulus of a complex number in complex form
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception

    ; |z|^2 = Re(z)^2 + Im(z)^2
    *OUT\re = *Z\re * *Z\re
    *OUT\im = *Z\im * *Z\im

    ProcedureReturn *OUT
  EndProcedure

  Procedure.i CAdd(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex) 
  ; ============================================================================
  ; NAME: CAdd
  ; DESC: Add 2 complex numbers OUT = IN1 + IN2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z1.TComplex) : Pointer to complex value Z1
  ; VAR(*Z2.TComplex) : Pointer to complex value Z2
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
   
    DBG::mac_CheckPointer3(*OUT, *Z1, *Z2)      ; Check Pointer Exception
    
    ; SSE-Version possible
    
    *OUT\re= *Z1\re + *Z2\re
    *OUT\im= *Z1\im + *Z2\im   
    
    ProcedureReturn *OUT
  EndProcedure

  Procedure.i CSub(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex) 
  ; ============================================================================
  ; NAME: CSub
  ; DESC: Sub 2 complex numbers OUT = Z1 - Z2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z1.TComplex) : Pointer to complex value Z1
  ; VAR(*Z2.TComplex) : Pointer to complex value Z2
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
   
    DBG::mac_CheckPointer3(*OUT, *Z1, *Z2)      ; Check Pointer Exception
    
    ; SSE-Version possible
     
    *OUT\re= *Z1\re - *Z2\re
    *OUT\im= *Z1\im - *Z2\im   
    
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i CMul(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex) 
  ; ============================================================================
  ; NAME: CMul
  ; DESC: Multiply 2 complex numbers OUT = Z1 * Z2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z1.TComplex) : Pointer to complex value Z1
  ; VAR(*Z1.TComplex) : Pointer to complex value Z2
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *Z1, *Z2)      ; Check Pointer Exception
    
   ; z1 · z2	 = 	(x1 + iy1) · (x2 + iy2)  =  (x1 x2  –  y1 y2)  +  i (x1 y2 +  x2 y1)

    *OUT\re= *Z1\re * *Z2\re - *Z1\im * *Z2\im
    *OUT\im= *Z1\re * *Z2\im + *Z2\re * *Z1\im   
    
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i CDiv(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex) 
  ; ============================================================================
  ; NAME: CDiv
  ; DESC: Divide 2 complex numbers OUT = Z1 / Z2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z1.TComplex) : Pointer to complex value Z1
  ; VAR(*Z2.TComplex) : Pointer to complex value Z2
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
        
    DBG::mac_CheckPointer3(*OUT, *Z1, *Z2)      ; Check Pointer Exception
    
    Protected.d denom
    
    ;  z1      x1 + iy1      x1*x2 + y1*y2          x2 * y1 - x1 * y2   
    ; ---- =  ---------- =  ---------------- + i ---------------------------
    ;  z2      x2 + iy2       x2² + y2²                x2² + y2²
    
    denom = 1/(*Z2\re * *Z2\re + *Z2\im * *Z2\im)
    
    If denom = Infinity()
      *OUT\re = Infinity()
      *OUT\im = Infinity()
    Else  
      *OUT\re = (*Z1\re * *Z2\re + *Z1\im * *Z2\im) * denom
      *OUT\im = (*Z2\re * *Z1\im - *Z1\re * *Z2\im) * denom
    EndIf
    
    ProcedureReturn *OUT   
  EndProcedure
  
  Procedure.i CCon(*InOut.TComplex)
  ; ============================================================================
  ; NAME: CCon
  ; DESC: Conjugate a Complex Number (change sign of i-Part)
  ; VAR(*InOut.TComplex): Pointer to complex Retrun Value OUT
  ; RET.i : *InOut or 0 if PointerException
  ; ============================================================================
     
    DBG::mac_CheckPointer(*InOut)      ; Check Pointer Exception
    With *InOut
      ;\x=   \x
      \im= -\im
    EndWith
    
    ProcedureReturn *InOut
  EndProcedure
  
  Procedure.i CInv(*OUT.TComplex, *Z.TComplex) 
  ; ============================================================================
  ; NAME: CInv
  ; DESC: Complex invert, reciprocal = 1/z
  ; DESC: x  = x / (x² + y²)
  ; DESC: iy = y / (x² + y²)
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*IN.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
       
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    Protected.d r
    
    r = *Z\re * *Z\re + *Z\im * *Z\im
    
    If r = 0
      *OUT\re = Infinity()
      *OUT\im = Infinity()      
    Else  
      *OUT\re = *Z\re / r
      *OUT\im = *Z\im / r
    EndIf
    
    ProcedureReturn *Out
  EndProcedure
 
  Procedure.i CPow(*OUT.TComplex, *Z.TComplex, N.i)
  ; ============================================================================
  ; NAME: CPow
  ; DESC: Calculate Z^N
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
   
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
     
    ; z^n = 	r^n · e^(i·n·ϕ)	 =  r^n · (cos n·ϕ +  i· sin n·ϕ)

    Protected.d rExpN, NPhi
    
    rExpN = Pow(Sqr(*Z\re * *Z\re + *Z\im * *Z\im), N)
    NPhi = N * ATan2(*Z\re, *Z\im)

    *OUT\re = rExpN * Cos(NPhi)
    *OUT\im = rExpN * Sin(NPhi)

    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i CPow2(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CPow2
  ; DESC: Calculate Z²
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
   
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
     
    ; z² = 	(x² - y²) + i·2xy 
    
    *OUT\re = (*Z\re * *Z\re) - (*Z\im * *Z\im)
    *OUT\im = *Z\re * *Z\im * 2

    ProcedureReturn *OUT
  EndProcedure

  Procedure.i CPowC(*OUT.TComplex, *Z1.TComplex, *Z2.TComplex)
  ; ============================================================================
  ; NAME: CPowC
  ; DESC: Calculate Z1^Z2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z1.TComplex) : Pointer to complex value Z1
  ; VAR(*Z2.TComplex) : Pointer to complex value Z2
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================

    DBG::mac_CheckPointer3(*OUT, *Z1, *Z2)      ; Check Pointer Exception
    
    Protected w_mem1.TComplex, w_mem2.TComplex
    
    ; CPowC = CExp(CMul(*Z2, CLog(*Z1)))
    Clog(w_mem1, *Z1)   
    CMul(w_mem2, *Z2, w_mem1)
    CExp(*OUT, w_mem2)
    
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i CSqr(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CSqr
  ; DESC: Calculate SquareRoot(Z)
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
            
    Protected.d Rsqr, Phi2
    
    ; Rsqr = Sqr(CAbs(*Z))
    Rsqr = Sqr(Sqr(*Z\re * *Z\re  +  *Z\im * *Z\im))
    
    Phi2 = ATan2(*Z\re, *Z\im)/2

    *OUT\re = Rsqr * Cos(Phi2)
    *OUT\im = Rsqr * Sin(Phi2)
  
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i CRootN(Array OUT.TComplex(1), *Z.TComplex, N.i)
  ; ============================================================================
  ; NAME: CRootN
  ; DESC: Calculate the Array with the N'th_Roots of Z
  ; DESC: A complex number has N different N'th roots
  ; DESC: W(0) .. W(n-1)
  ; VAR(Array *OUT.TComplex(1): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; VAR(N.i): No of the 
  ; RET.i : @OUT or 0 if PointerException
  ; ============================================================================
    
    ;        (1/n) (     phi +2·#Pi·k          phi + 2·#Pi·k  )
    ;  Wk=  r      (cos -------------- + i·sin -------------- )
    ;              (         n                       n        )
    ;              
    ;                       k= 0..n-1
    
    DBG::mac_CheckPointer(*Z)      ; Check Pointer Exception

    Protected.i K 
    Protected.d R_RootN, Phi_n, _1divN, val
    
    If N > 1  
      ReDim OUT(N-1)
      
      _1divN = 1/n
      
      R_RootN = Pow(Sqr(*Z\re * *Z\re + *Z\im * *Z\im), _1divN) ; CAbs(*Z)^(1/N)
      Phi_n = ATan2(*Z\re, *Z\im) * _1divN ; / N
      
      For K = 0 To N-1
        val = Phi_n + (2*#PI)* _1divN * K ; /N
        OUT(K)\re = R_RootN * Cos(val)
        OUT(K)\im = R_RootN * Sin(val)
      Next      
      
    ElseIf N = 1  
      ReDim OUT(0)
      OUT(0)\re = *Z\re
      OUT(0)\im = *Z\im
      
    Else
      ReDim OUT(0)
      OUT(0)\re = 0
      OUT(0)\im = 0    
    EndIf
    
    ProcedureReturn OUT()
  EndProcedure

  Procedure.i CExp(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CExp
  ; DESC: Calculate Exponent(Z), e^Z
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    ; e^(x+iy) = e^x * e^iy = e^x(Cos(y) + i·Sin(y))
    Protected.d Exp_re

    Exp_re = Exp(*Z\re)
    *OUT\re = Exp_re * Cos(*Z\im)
    *OUT\im = Exp_re * Sin(*Z\im)
    
    ProcedureReturn *OUT    
  EndProcedure 
    
  Procedure.i CLog(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CLog
  ; DESC: Calculate natural Logartihm Log(Z)
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
     
    ; w = 	ln r  +  i·(ϕ + 2kπ)
    ;       2kπ is full phase, so we can ignore to get 1st solution
    ; w = 	ln r  +  i·ϕ
    
    ;*OUT\re = Log(CAbs(*Z))
    *OUT = Log(Sqr(*Z\re * *Z\re + *Z\im * *Z\im))
    *OUT\im = ATan2(*Z\re, *Z\im)
    
    ProcedureReturn *OUT
  EndProcedure        
  
  Procedure.i CSin(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CSin
  ; DESC: Calculate Sin(Z)
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
  
    Protected.TComplex w_esp, w_esn
    Protected.TComplex w_mem, w_esp2, w_esn2 
    
    w_mem\re = 0
    w_mem\re = 1

    ; w_esp = CMul(CSet(0.0, 1.0), z)
    ; w_esn = CMul(CSet(0.0, -1.0), z)
    
    CMul(w_esp, w_mem, *Z)
    w_mem\im = -1 
    CMul(w_esn, w_mem, *Z)
 
    ;CSin = CDiv(CDif(CExp(w_esp), CExp(w_esn)), CSet(0.0, 2.0))
    CExp(w_esp2, w_esp)
    CExp(w_esn2, w_esn)
    CSub(w_mem, w_esp2, w_esn2)
    
    w_esp2\re = 0
    w_esp2\im = 2
    
    CDiv(*OUT, w_mem, w_esp2)
    
    ProcedureReturn *OUT
  EndProcedure

  Procedure.i CCos(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CCos
  ; DESC: Calculate Cos(Z)
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    Protected.TComplex w_esp, w_esn
    Protected.TComplex w_mem, w_esp2, w_esn2 
    
    w_mem\re = 0
    w_mem\re = 1
    
    CMul(w_esp, w_mem, *Z)
    w_mem\im = -1 
    CMul(w_esn, w_mem, *Z)
   
    ; w_esp = CMul(CSet(0.0, 1.0), *Z)
    ; w_esn = CMul(CSet(0-0, -1.0), *Z)
  
    ; CCos = CDiv(CAdd(CExp(w_esp), CExp(w_esn)), CSet(2.0, 0.0))
    CExp(w_esp2, w_esp)
    CExp(w_esn2, w_esn)
    CAdd(w_mem, w_esp2, w_esn2)
    
    w_esp2\re = 2
    w_esp2\im = 0
    
    CDiv(*OUT, w_mem, w_esp2)
    
    ProcedureReturn *OUT  
  EndProcedure

  Procedure.i CTan(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CTan
  ; DESC: Calculate Tan(Z)
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
   
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception

    Protected.TComplex ccos, csin 
    
    CCos(ccos, *Z)
    Csin(csin, *Z)
    
    ; CTan = CDiv(CSin(*Z), CCos(*Z))
    CDiv(*OUT, csin, ccos)
    
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i CAsin(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CAsin
  ; DESC: Calculate ASin(Z), Arcos Sine
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception

    ;Dim w_as As Complex
    Protected.TComplex w_as, w_as2
    Protected.TComplex w_mem, mul 
    
    w_mem\re = 1 
    ;mem\im = 0
    
    ; w_as = CSqr(CSub(CSet(1, 0), CMul(*Z, *Z)))
    CMul(mul, *Z, *Z)
    Csub(w_as2, w_mem, mul)
    ; w_as = CAdd(CMul(CSet(0, 1), z), w_as)
    w_mem\re = 0
    w_mem\im = 1
    CMul(mul, w_mem, *Z)
    CAdd(w_as, mul, w_as2)
    
    ;CAsin = CDiv(CLog(w_as), CSet(0, 1))
    CLog(w_as2, w_as)
    CDiv(*OUT, w_as2, w_mem)
    
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i CAcos(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CAcos
  ; DESC: Calculate ACos(Z), Arcos Cosine
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    ;Dim w_ac As Complex
    Protected.TComplex w_ac, w_ac2, w_mem, mul
    
    ;w_ac = CSqr(CSub(CMul(z, z), CSet(1, 0)))
    w_mem\re = 1
    ;mem\im = 0 
    
    CMul(mul, *Z, *Z)
    CSub(w_ac2 , mul, w_mem)
    ; w_ac = CAdd(*Z, w_ac)
    CAdd(w_ac, *Z, w_ac2)
    
    ; CAcos = CDiv(CLog(w_ac), CSet(0, 1))
    w_mem\re = 0
    w_mem\im = 1
    CLog(w_ac2, w_ac)
    CDiv(*OUT, w_ac2, w_mem)
 
    ProcedureReturn *OUT
  EndProcedure

  Procedure.i CAtan(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CAtan
  ; DESC: Calculate ATan(Z), Arcos Tangent
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
  
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
  
    Protected.TComplex w_de, w_nu, w_mem0, w_mem1, mul, div
    
    ; w_nu = CAdd(CSet(1.0, 0.0), CMul(CSet(0.0, 1), z))
    ;mem0\re = 0
    w_mem0\im = 1
    w_mem1\re = 1
    ; mem1\im = 0
    CMul(mul, w_mem0, *Z)
    CAdd(w_nu, w_mem1, mul)
    
    ;w_de = CSub(CSet(1.0, 0.0), CMul(CSet(0.0, 1), z))
    CMul(mul, w_mem0, *Z)
    CSub(w_de, w_mem1, mul)
    
    ; CAtan = CDiv(CLog(CDiv(w_nu, w_de)), CSet(0.0, 2.0))
    w_mem0\im = 2
    CDiv(div, w_nu, w_de)
    CLog(mul, div)
    CDiv(*OUT, mul, w_mem0)
    
    ProcedureReturn *OUT    
  EndProcedure
    
  ; With Chat GPT support
  Procedure.i CSinh(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CSinh
  ; DESC: Calculate Sinh(Z), hyberplic sine
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    ; Calculate the hyperbolic sine of a complex number
    ; Sinh(z) = (e^z - e^(-z)) / 2
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception

    ; Calculate e^Z and e^(-Z)
    Protected expZ.TComplex
    Protected expNegZ.TComplex
    
    Protected.d exp_re 
    
    ; e^z
    exp_re= Exp(-*Z\re)
    expZ\re = exp_re * Cos(*Z\im)
    expZ\im = exp_re * Sin(*Z\im)
    
    ; e^(-z)
    exp_re = Exp(-*Z\re)
    expNegZ\re = exp_re * Cos(-*Z\im)
    expNegZ\im = exp_re * Sin(-*Z\im)
  
    ; Calculate sinh(Z)
    *OUT\re = (expZ\re - expNegZ\re) * 0.5  ; /2
    *OUT\im = (expZ\im - expNegZ\im) * 0.5  ; /2
  
    ProcedureReturn *OUT
  EndProcedure
  
; ; With Chat GPT support
  Procedure.i CCosh(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CCosh
  ; DESC: Calculate Cosh(Z), hyberplic cosine
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    ; Calculate the hyperbolic cosine of a complex number
    ; Cosh(z) = (e^z + e^(-z)) / 2
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    ; Calculate e^Z and e^(-Z)
    Protected expZ.TComplex
    Protected expNegZ.TComplex
    
    Protected.d exp_re 
   
    ; e^z
    exp_re = Exp(*Z\re)
    expZ\re = exp_re * Cos(*Z\im)
    expZ\im = exp_re * Sin(*Z\im)
  
   ; e^(-z)
    exp_re = Exp(-*Z\re)
    expNegZ\re = exp_re * Cos(-*Z\im)
    expNegZ\im = exp_re * Sin(-*Z\im)
  
    ; Calculate cosh(Z)
    *OUT\re = (expZ\re + expNegZ\re) * 0.5 ; / 2.0
    *OUT\im = (expZ\im + expNegZ\im) * 0.5 ; / 2.0
  
    ProcedureReturn *OUT
 
  EndProcedure
  
  Procedure.i CTanh(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CTanh
  ; DESC: Calculate Cosh(Z), hyperbolic tangent of a complex number
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    ; Calculate the hyperbolic tangent of a complex number
    ; Tanh(z) = sinh(z) / cosh(z)
    
    ; sinh(z)    (e^z - e^(-z)) / 2       e^z - e^(-z)
    ; -------- = -------------------- = ---------------
    ; cosh(z)    (e^z + e^(-z)) / 2       e^z + e^(-z)
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception

    ; Calculate sinh(Z) and cosh(Z)
    Protected sinhZ.TComplex
    Protected coshZ.TComplex
    
    CSinh(sinhZ, *Z)
    CCosh(coshZ, *Z)
    CDiv(*OUT, sinhZ, coshZ)
   
    ProcedureReturn *OUT
  EndProcedure  
  
  ; ; With Chat GPT support
  Procedure.i CAsinh(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CAsinh
  ; DESC: Calculate CAsinh(Z), inverse hyperbolic sine of a complex number
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    ; Calculate the inverse hyperbolic sine of a complex number
    ; ASinh(z) = ln(z + sqrt(1 + z^2))
  
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    Protected zSquared.TComplex
    Protected onePlusZSquared.TComplex
    Protected sqrtOnePlusZSquared.TComplex
    Protected zPlusSqrtOnePlusZSquared.TComplex
    
    ; z² = 	(x² - y²) + i·2xy 
    zSquared\re = *Z\re * *Z\re - *Z\im * *Z\im
    zSquared\im = *Z\re * *Z\im * 2.0
  
    onePlusZSquared\re = 1.0 + zSquared\re
    onePlusZSquared\im = zSquared\im
  
    CSqr(sqrtOnePlusZSquared, onePlusZSquared)
  
    zPlusSqrtOnePlusZSquared\re = *Z\re + sqrtOnePlusZSquared\re
    zPlusSqrtOnePlusZSquared\im = *Z\im + sqrtOnePlusZSquared\im
  
    CLog(*OUT, zPlusSqrtOnePlusZSquared)
  
    ProcedureReturn *OUT
  EndProcedure
    
  ; ; With Chat GPT support
  Procedure.i CAcosh(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CAcosh
  ; DESC: Calculate Acosh(Z), inverse hyperbolic cosine of a complex number
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    ; Calculate the inverse hyperbolic cosine of a complex number
    ; Acosh(z) = ln(z + sqrt(z² - 1))
  
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    ; Define complex variables
    Protected zSquaredMinusOne.TComplex
    Protected sqrtZSquaredMinusOne.TComplex
    Protected zPlusSqrtZSquaredMinusOne.TComplex
  
    ; Calculate z² - 1
    zSquaredMinusOne\re = (*Z\re * *Z\re - *Z\im * *Z\im) - 1.0
    zSquaredMinusOne\im = 2.0 * *Z\re * *Z\im
  
    ; Calculate sqrt(z² - 1)
    CSqr(sqrtZSquaredMinusOne, zSquaredMinusOne)
  
    ; Calculate z + sqrt(z² - 1)
    zPlusSqrtZSquaredMinusOne\re = *Z\re + sqrtZSquaredMinusOne\re
    zPlusSqrtZSquaredMinusOne\im = *Z\im + sqrtZSquaredMinusOne\im
  
    ; Calculate ln(z + sqrt(z² - 1))
    CLog(*OUT, @zPlusSqrtZSquaredMinusOne)
  
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i CAtanh(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CAtanh
  ; DESC: Calculate CAtanh(Z), inverse hyperbolic tangent of a complex number
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    ; Calculate the inverse hyperbolic tangent of a complex number
    ; Atanh(z) = 0.5 * ln((1 + z) / (1 - z))
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    ; Define complex variables
    Protected onePlusZ.TComplex
    Protected oneMinusZ.TComplex
    Protected ratio.TComplex
    
    ; (1 + z)
    onePlusZ\re = 1.0 + *Z\re
    onePlusZ\im = *Z\im
    
    ;(1 - z)
    oneMinusZ\re = 1.0 - *Z\re
    oneMinusZ\im = -(*Z\im)
    
    ; ln((1 + z) / (1 - z))
    CDiv(ratio, onePlusZ, oneMinusZ)
    Clog(*OUT, ratio)
    
    ; * 0.5
    *OUT\re * 0.5
    *OUT\im * 0.5
     
    ProcedureReturn *OUT
  EndProcedure
   
  ;- ----------------------------------------------------------------------
  ;-  Misc Functions
  ;- ----------------------------------------------------------------------

  Procedure.i KartesianToPolar(*OUT.TComplexPolar, *Z.TComplex)
  ; ============================================================================
  ; NAME: KartesianToPolar
  ; DESC: Convert Kartesian Coordinates to Polar Coordinates
  ; VAR(*OUT.TComplexPolar): Pointer to OUT value as ComplexPolar
  ; VAR(*IN.TComplex): Pointer to IN value as Complex kartesian 
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    With *Z
      *OUT\R = Sqr(\re * \re + \im * \im)
      *OUT\Phi = ATan2(\re, \im)
    EndWith
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i PolarToKartesian(*OUT.TComplex, *Z.TComplexPolar)
  ; ============================================================================
  ; NAME: PolarToKartesian
  ; DESC: Convert the Polar Coordinates to Kartesian Coordinates
  ; VAR(*OUT.TComplex): Pointer to OUT value as Complex kartesian 
  ; VAR(*IN.TComplexPolar): Pointer to IN value as ComplexPolar
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    With *Z
      *Out\re = Cos(*Z\Phi) * *Z\R 
      *Out\im = Sin(*Z\Phi) * *Z\R 
    EndWith
    ProcedureReturn *OUT
  EndProcedure

  Procedure.i CSwap(*Z1.TComplex, *Z2.TComplex)  
  ; ============================================================================
  ; NAME: CSwap
  ; DESC: Swap 2 complex values.
  ; VAR(*Z1.TComplex): Pointer to value Z1 as Complex
  ; VAR(*Z2.TComplex): Pointer to value Z2 as Complex
  ; RET.i : #True or 0 if PointerException
  ; ============================================================================
    DBG::mac_CheckPointer2(*Z1, *Z2)      ; Check Pointer Exception
    Swap *Z1\re, *Z2\re
    Swap *Z1\im, *Z2\im
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i CMsgBox(*Z.TComplex, Decimals=3)
  ; ============================================================================
  ; NAME: CMsgBox
  ; DESC: Shows the values of Z in a MessageBox
  ; DESC: 1: Cartesian form, Polar form in radian, Polar form in degree
  ; VAR(*Z.TComplex): Pointer to value Z as Complex
  ; VAR(Decimals): Number of decimals (3 ->  2.123; 1 -> 2.1) 
  ; RET:  Return value of MessageRequester() or 0 if PointerException
  ; ============================================================================
    
    DBG::mac_CheckPointer(*Z)      ; Check Pointer Exception

    Protected txt.s, ret.i
    Protected.TComplexPolar Zp
    
    KartesianToPolar(Zp, *Z)
    
    txt = "Cartesian   : " + StrD(*Z\re, Decimals) + " + i·" + StrD(*Z\im, Decimals) + #CRLF$
    txt + "Polar radian: " + StrD(Zp\R, Decimals)  + " Phi " + StrD(Zp\Phi, Decimals)  + #CRLF$
    txt + "Polar degree: " + StrD(Zp\R, Decimals)  + " Deg " + StrD(Degree(Zp\Phi), Decimals)  + " °"
    
    ret=MessageRequester("Complex", txt, #PB_MessageRequester_Info)
    
    ProcedureReturn ret
  EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
 ;- ----------------------------------------------------------------------
 ;-  M O D U L E   T E S T   C O D E
 ;-  ---------------------------------------------------------------------- 
 
  UseModule Complex
  
  Structure TPoint2D
    x.d
    y.d
  EndStructure

  Procedure Show(Header$, *Complex.TComplex)
    If *Complex
      Protected.d i=*Complex\im, r=*Complex\re 
      Print(LSet(Header$,7))
      Print("= "+StrD(r,3))
      If i>=0:  Print(" + ")
      Else:     Print(" - ")
      EndIf
      PrintN(StrD(Abs(i),3)+"i")
    EndIf
  EndProcedure
  
  Define P.TPoint2D, Pcplx.TComplex, phi.d
  
   
CompilerEndIf

; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 138
; FirstLine = 147
; Folding = -------
; Optimizer
; CPU = 5