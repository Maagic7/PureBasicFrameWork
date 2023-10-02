; ===========================================================================
;  FILE: PbFw_Module_Complex.pb
;  NAME: Module Complex [Complex::]
;  DESC: Complex number 
;  DESC: In mathematics, a complex number is an element of a number system 
;  DESC: that extends the real numbers with a specific element denoted i,
;  DESC: called the imaginary unit. The square of is (-1); i²=-1
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
;   2023/08/27 S.Maag : As I was ready with the basic implementations
;              I found a full implementation in Visual Basic from 2001
;              what is based on a Fortra77 implementation (Numerical Recipes in Fortran 77)
;              http://www.flanguasco.org/VisualBasic/VisualBasic.html
;              Because of correct mathematical names, I decided to use this 
;              FunctionNames. I added all additional functions of the  
;              Visual Basic version (all the CSin, CCos, CTan, CAsin ...) 
;          
;}
;{ TODO:
;}
; ===========================================================================


;   r = CAbs(Z):        Absolute value of Z, (Vector legnth) 
;   r = CArg(Z):        Argument of Z, (Angle, Phase)

;   w = CAdd(Z1, Z2):   add Z1 + Z2.
;   w = CSub(Z1, Z2):   subtract Z1 - Z2.
;   w = CMul(Z1, Z2):   multiply Z1 * Z2.
;   w = CDiv(Z1, Z2):   divide Z1 / Z2.

;   w = CCon(Z):        conjugate Z
;   w = CInv(Z):        inverse or reciprocal value: 1/Z

;   w = CPow(Z, N):     potency Z1 ^ N       
;   w = CPow2(Z, N):    Z^2
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

;   w = CModQ(Z):       Modulo of Z² in complex format


;   CSWAP Z1, Z2:       exchange Z1, Z2.
;
;   w() = CPMPY(Z1(), Z2()): polynom product Z1() * Z2().
;
;   S = CFormat$(Z, F): ritorna una stringa rappresentante Z con il formato F.
;   CMsgBox Z:          espone un MsgBox con Z a piena precisione.
;
   

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
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
  
  ;  Functions returning a double float
  Declare.d CAbs(*Z.TComplex)
  Declare.d CArg(*Z.TComplex)

  ;  Functions returning a Complex
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
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;- ----------------------------------------------------------------------
  ;-  Functions returning a double float
  ;- ----------------------------------------------------------------------

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
    
    Protected.d div
    
    ;  z1      x1 + iy1      x1*x2 + y1*y2          x2 * y1 - x1 * y2   
    ; ---- =  ---------- =  ---------------- + i ---------------------------
    ;  z2      x2 + iy2       x2² + y2²                x2² + y2²
    
    div = *Z2\re * *Z2\re + *Z2\im * *Z2\im
    
    If div = 0
      *OUT\re = Infinity()
      *OUT\im = Infinity()
    Else  
      *OUT\re = (*Z1\re * *Z2\re + *Z1\im * *Z2\im) / div
      *OUT\im = (*Z2\re * *Z1\im - *Z1\re * *Z2\im) / div
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
    
    *OUT\re = *Z\re * *Z\re - *Z\im * *Z\im
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

    Protected.i  K 
    Protected.d R_RootN, Phi_n, val
    
    If N > 1  
      ReDim OUT(N-1)
      
      R_RootN = Pow(Sqr(*Z\re * *Z\re + *Z\im * *Z\im), 1/N) ; CAbs(*Z)^(1/N)
      Phi_n = ATan2(*Z\re, *Z\im) / N
      
      For K = 0 To N-1
        val = Phi_n + (2*#PI)*K/N
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
    
    ProcedureReturn @OUT(0)
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
    ; Ritorna il valore, complesso, del seno di z:

    Protected.TComplex w_esp, w_esn
    Protected.TComplex w_mem, w_esp2, w_esn2 
    
    w_mem\re = 0
    w_mem\re = 1

    ; w_esp = CMul(CCmp(0#, 1#), z)
    ; w_esn = CMul(CCmp(0#, -1#), z)
    
    CMul(w_esp, w_mem, *Z)
    w_mem\im = -1 
    CMul(w_esn, w_mem, *Z)
 
    ;CSin = CDiv(CDif(CExp(w_esp), CExp(w_esn)), CCmp(0#, 2#))
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
    ; Ritorna il valore, complesso, del coseno di z:
    
    Protected.TComplex w_esp, w_esn
    Protected.TComplex w_mem, w_esp2, w_esn2 
    
    w_mem\re = 0
    w_mem\re = 1
    
    CMul(w_esp, w_mem, *Z)
    w_mem\im = -1 
    CMul(w_esn, w_mem, *Z)
   
    ; w_esp = CMul(CCmp(0.0, 1.0), *Z)
    ; w_esn = CMul(CCmp(0-0, -1.0), *Z)
  
    ; CCos = CDiv(CAdd(CExp(w_esp), CExp(w_esn)), CCmp(2.0, 0.0))
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

    ; Ritorna il valore, complesso, della tangente di z:
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
    ; Ritorna il valore, complesso, dell' arcoseno di z:

    ;Dim w_as As Complex
    Protected.TComplex w_as, w_as2
    Protected.TComplex w_mem, mul 
    
    w_mem\re = 1 
    ;mem\im = 0
    
    ; w_as = CSqr(CSub(CCmp(1, 0), CMul(*Z, *Z)))
    CMul(mul, *Z, *Z)
    Csub(w_as2, w_mem, mul)
    ; w_as = CAdd(CMul(CCmp(0, 1), z), w_as)
    w_mem\re = 0
    w_mem\im = 1
    CMul(mul, w_mem, *Z)
    CAdd(w_as, mul, w_as2)
    
    ;CAsin = CDiv(CLog(w_as), CCmp(0, 1))
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
    ; Ritorna il valore, complesso, dell' arcocoseno di z:
    
    ;Dim w_ac As Complex
    Protected.TComplex w_ac, w_ac2, w_mem, mul
    
    ;w_ac = CSqr(CSub(CMul(z, z), CCmp(1, 0)))
    w_mem\re = 1
    ;mem\im = 0 
    
    CMul(mul, *Z, *Z)
    CSub(w_ac2 , mul, w_mem)
    ; w_ac = CAdd(*Z, w_ac)
    CAdd(w_ac, *Z, w_ac2)
    
    ; CAcos = CDiv(CLog(w_ac), CCmp(0, 1))
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
    ; Ritorna il valore, complesso, dell' arcotangente di z:
  
    Protected.TComplex w_de, w_nu, w_mem0, w_mem1, mul, div
    
    ; w_nu = CAdd(CCmp(1#, 0#), CMul(CCmp(0#, 1), z))
    ;mem0\re = 0
    w_mem0\im = 1
    w_mem1\re = 1
    ; mem1\im = 0
    CMul(mul, w_mem0, *Z)
    CAdd(w_nu, w_mem1, mul)
    
    ;w_de = CSub(CCmp(1#, 0#), CMul(CCmp(0#, 1), z))
    CMul(mul, w_mem0, *Z)
    CSub(w_de, w_mem1, mul)
    
    ; CAtan = CDiv(CLog(CDiv(w_nu, w_de)), CCmp(0#, 2#))
    w_mem0\im = 2
    CDiv(div, w_nu, w_de)
    CLog(mul, div)
    CDiv(*OUT, mul, w_mem0)
    ProcedureReturn *OUT    
  EndProcedure
  
  Procedure.i CSinh(*OUT.TComplex, *Z.TComplex)
  ; ============================================================================
  ; NAME: CSinh
  ; DESC: Calculate Sinh(Z), hyberplic sine
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*Z.TComplex) : Pointer to complex value Z
  ; RET.i : *OUT or 0 if PointerException
  ; ============================================================================

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    ;   Ritorna il valore, complesso, del seno
    ;   iperbolico di z:

    ; Dim w_esn As Complex
    Protected.TComplex w_esn, w_mem, w_exp_z, w_exp_esn
        
    ; w_esn = CMul(CCmp(-1#, 0#), z)
    w_mem\re = -1
    ;w_mem\im = 0
    CMul(w_esn, w_mem, *Z)
    
    ; CSinh = CDiv(CSub(CExp(z), CExp(w_esn)), CCmp(2#, 0#))
    w_mem\re = 2
    CExp(w_exp_z, *Z)
    Cexp(w_exp_esn, w_esn)
    CSub(w_esn, w_exp_z, w_exp_esn)
    
    CDiv(*OUT, w_esn, mem)
    ProcedureReturn *OUT    
  EndProcedure
  
  Procedure.i CCosh(*OUT.TComplex, *Z.TComplex)

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    
    ; Ritorna il valore, complesso, del coseno
    ; iperbolico di z:

    ; Dim w_esn As Complex
    Protected w_esn.TComplex

    w_esn = CMul(CCmp(-1#, 0#), z)

    CCosh = CDiv(CAdd(CExp(z), CExp(w_esn)), CCmp(2#, 0#))

    ProcedureReturn *OUT    
  EndProcedure
  
  Procedure.i CTanh(*OUT.TComplex, *Z.TComplex)

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    ; Ritorna il valore, complesso, della tangente
    ; iperbolica di z:

    CTanh = CDiv(CSinh(z), CCosh(z))

    ProcedureReturn *OUT    
  EndProcedure
  
  Procedure.i CAsinh(*OUT.TComplex, *Z.TComplex)

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    ; Ritorna il valore, complesso, dell' arcoseno
    ; iperbolico di z:

    Dim w_as As Complex

    w_as = CSqr(CAdd(CMul(z, z), CCmp(1#, 0#)))
    w_as = CAdd(z, w_as)

    CAsinh = CLog(w_as)

    ProcedureReturn *OUT    
  EndProcedure

  Procedure.i CAcosh(*OUT.TComplex, *Z.TComplex)

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    ; Ritorna il valore, complesso, dell' arcocoseno
    ; iperbolico di z:

    Dim w_ac As Complex

    w_ac = CSqr(CDif(CMul(z, z), CCmp(1#, 0#)))
    w_ac = CAdd(z, w_ac)

    CAcosh = CLog(w_ac)

    ProcedureReturn *OUT    
  EndProcedure

  Procedure.i CAtanh(*OUT.TComplex, *Z.TComplex)

    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    ; Ritorna il valore, complesso, dell' arcotangente
    ; iperbolica di z:

    Dim w_de As Complex, w_nu As Complex

    w_nu = CSom(CCmp(1#, 0#), z)
    w_de = CSub(CCmp(1#, 0#), z)

    CAtnh = CDiv(CLog(CDiv(w_nu, w_de)), CCmp(2#, 0#))

    ProcedureReturn *OUT    
  EndProcedure  
  
  Procedure.i CModQ(*OUT.TComplex, *Z.TComplex)
    
    DBG::mac_CheckPointer2(*OUT, *Z)      ; Check Pointer Exception
    ; Ritorna il modulo di z al quadrato in formato complesso:
    ; CModQ = CCmp(z.Re * z.Re + z.Im * z.Im, 0#)
   
    *OUT\re = (*Z\re * *Z\re) + (*Z\im * *Z\im)
    *OUT\im = 0      
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
  ; RET.d : #True or 0 if PointerException
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
    
    DBG::mac_CheckPointer1(*Z)      ; Check Pointer Exception

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
  
  P\x = 1
  P\y = 5
  
  Pcplx\re = P\x
  Pcplx\im= P\y
  
  
  phi= Complex_Phase(P)
  Debug phi
  phi = Complex_Phase(Pcplx)
  Debug phi
  
  If OpenConsole()
    Define.TComplex a, b, c
    
    a\re=1.0: a\im=1.0
    b\re=#PI: b\im=1.2
    
    Complex_Add(c,a,b):  Show("a+b",    c)
    Complex_Mul(c,a,b):  Show("a*b",    c)
    Complex_Negate(a):    Show("-a",     a)
    Print(#CRLF$+"Press ENTER to exit"):Input()
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 661
; FirstLine = 793
; Folding = -------
; Optimizer
; CPU = 5