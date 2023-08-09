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
; 
;}
;{ TODO:
;}
; ===========================================================================

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
    x.d
    iy.d
  EndStructure
    
  Structure TComplexPolar ; Polar coordinates
    R.d                   ; Magnitude, Radius
    Phi.d                 ; Angle [Radian]
  EndStructure
  
  Declare.d Complex_Magnitude(*IN.TComplex)
  Declare.d Complex_Phase(*IN.TComplex)
  Declare.i Complex_Add(*OUT.TComplex, *IN1.TComplex, *IN2.TComplex) 
  Declare.i Complex_Sub(*OUT.TComplex, *IN1.TComplex, *IN2.TComplex) 
  Declare.i Complex_Mul(*OUT.TComplex, *IN1.TComplex, *IN2.TComplex) 
  Declare.i Complex_Div(*OUT.TComplex, *IN1.TComplex, *IN2.TComplex)           
  
  Declare.i Complex_Conjugate(*InOut.TComplex)
  Declare.i Complex_Negate(*InOut.TComplex)

  Declare.i Complex_Invert(*OUT.TComplex, *IN.TComplex) 
  Declare.i Complex_Reciprocal(*OUT.TComplex, *IN.TComplex)

  Declare.i KartesianToPolar(*OUT.TComplexPolar, *IN.TComplex)
  Declare.i PolarToKartesian(*OUT.TComplex, *IN.TComplexPolar)

EndDeclareModule


Module Complex
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  Procedure.d Complex_Magnitude(*IN.TComplex)
  ; ============================================================================
  ; NAME: Magnitude
  ; DESC: Get the lenth of the complex vector l=Sqr(x² + iy²)
  ; VAR(*IN.TComplex) : Pointer to complex value struct
  ; RET.d : the Angel in Radian
  ; ============================================================================
   
    DBG::mac_CheckPointer(*IN)      ; Check Pointer Exception
    
    With *IN
      ProcedureReturn Sqr(\x * \x + \iy * \iy )
    EndWith   
  EndProcedure
  
  Procedure.d Complex_Phase(*IN.TComplex)
  ; ============================================================================
  ; NAME: Phase
  ; DESC: Get the angle Phi (between X-Axis and Point)
  ; VAR(*IN.TComplex) : Pointer to complex value struct
  ; RET.d : the Angel in Radian
  ; ============================================================================
    
    DBG::mac_CheckPointer(*IN)      ; Check Pointer Exception
    
    ; ATan2 is the Purebasic function to calculate Angle Phi of a Point with X-Axis
    ProcedureReturn ATan2(*IN\x, *IN\iy)    
  EndProcedure
  
  Procedure.i Complex_Add(*OUT.TComplex, *IN1.TComplex, *IN2.TComplex) 
  ; ============================================================================
  ; NAME: Complex_Add
  ; DESC: Add 2 complex numbers OUT = IN1 + IN2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*IN1.TComplex) : Pointer to complex value struct IN1
  ; VAR(*IN1.TComplex) : Pointer to complex value struct IN2
  ; RET.i : *OUT
  ; ============================================================================
   
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)      ; Check Pointer Exception
    
    ; SSE-Version possible
    
    *OUT\x= *IN1\x + *IN2\x
    *OUT\iy= *IN1\iy + *IN2\iy   
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i Complex_Sub(*OUT.TComplex, *IN1.TComplex, *IN2.TComplex) 
  ; ============================================================================
  ; NAME: Complex_Sub
  ; DESC: Sub 2 complex numbers OUT = IN1 - IN2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*IN1.TComplex) : Pointer to complex value struct IN1
  ; VAR(*IN1.TComplex) : Pointer to complex value struct IN2
  ; RET.i : *OUT
  ; ============================================================================
   
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)      ; Check Pointer Exception
    
    ; SSE-Version possible
     
    *OUT\x= *IN1\x - *IN2\x
    *OUT\iy= *IN1\iy - *IN2\iy   
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i Complex_Mul(*OUT.TComplex, *IN1.TComplex, *IN2.TComplex) 
  ; ============================================================================
  ; NAME: Complex_Mul
  ; DESC: Multiply 2 complex numbers OUT = IN1 * IN2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*IN1.TComplex) : Pointer to complex value struct IN1
  ; VAR(*IN1.TComplex) : Pointer to complex value struct IN2
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)      ; Check Pointer Exception
    
    ; SSE-Version possible but lower precision
 
    *OUT\x= *IN1\x * *IN2\x - *IN1\iy * *IN2\iy
    *OUT\iy= *IN1\x * *IN2\iy + *IN1\iy * *IN2\x    
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i Complex_Div(*OUT.TComplex, *IN1.TComplex, *IN2.TComplex) 
  ; ============================================================================
  ; NAME: Complex_Div
  ; DESC: Divide 2 complex numbers OUT = IN1 / IN2
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*IN1.TComplex) : Pointer to complex value struct IN1
  ; VAR(*IN1.TComplex) : Pointer to complex value struct IN2
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)      ; Check Pointer Exception
    
    ; SSE maybe or Add and Sub
    *OUT\x= 1/(*IN2\x * *IN2\x + *IN2\iy * *IN2\iy)
    *OUT\iy= *IN2\x * *IN1\iy - *IN1\x * *IN2\iy  
     ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i Complex_Conjugate(*InOut.TComplex)
  ; ============================================================================
  ; NAME: Complex_Conjugate
  ; DESC: Conjugate a Complex Number (change sign of i-Part)
  ; VAR(*InOut.TComplex): Pointer to complex Retrun Value OUT
  ; RET.i : *InOut
  ; ============================================================================
     
    DBG::mac_CheckPointer(*InOut)      ; Check Pointer Exception
    With *InOut
      ;\x=   \x
      \iy= -\iy
    EndWith
    ProcedureReturn *InOut
  EndProcedure
  
  Procedure.i Complex_Negate(*InOut.TComplex)
  ; ============================================================================
  ; NAME: Complex_Negate
  ; DESC: Complex_Negate a Complex Number (change sign of real and i-Part)
  ; VAR(*InOut.TComplex): Pointer to complex Retrun Value OUT
  ; RET.i : *InOut
  ; ============================================================================
    
    DBG::mac_CheckPointer(*InOut)      ; Check Pointer Exception
    With *InOut
      \x=  -\x
      \iy= -\iy
    EndWith
    ProcedureReturn *InOut
   
  EndProcedure
  
  Procedure.i Complex_Invert(*OUT.TComplex, *IN.TComplex) 
  ; ============================================================================
  ; NAME: Complex_Invert
  ; DESC: calculate 1/IN
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*IN.TComplex) : Pointer to complex value struct IN
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *IN)      ; Check Pointer Exception
   
    *OUT\x= 1/(*IN\x * *IN\x + *IN\iy * *IN\iy)
    *OUT\iy=  - *IN\iy  
     ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i Complex_Reciprocal(*OUT.TComplex, *IN.TComplex)
  ; ============================================================================
  ; NAME: Complex_Reciprocal
  ; DESC: Reciprocal Value of a Complex NUmber
  ; DESC: x  = x  / (x² + iy²)
  ; DESC: iy = iy / (x² + iy²)
  ; VAR(*OUT.TComplex): Pointer to complex Retrun Value OUT
  ; VAR(*IN.TComplex) : Pointer to complex value struct IN
  ; RET.i : *OUT
  ; ============================================================================
       
    DBG::mac_CheckPointer2(*OUT, *IN)      ; Check Pointer Exception
    
    Protected.d m
    m = *IN\x * *IN\x + *IN\iy * *IN\iy
    *OUT\x  / m
    *OUT\iy / m
    ProcedureReturn *Out
  EndProcedure
  
  Procedure.i KartesianToPolar(*OUT.TComplexPolar, *IN.TComplex)
  ; ============================================================================
  ; NAME: KartesianToPolar
  ; DESC: Convert Kartesian Coordinates to Polar Coordinates
  ; VAR(*OUT.TComplexPolar): Pointer to OUT value as ComplexPolar
  ; VAR(*IN.TComplex): Pointer to IN value as Complex kartesian 
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *IN)      ; Check Pointer Exception
    
    With *IN
      *OUT\R = Sqr(\x * \x + \iy * \iy)
      *OUT\Phi = ATan2(\x, \iy)
    EndWith
    ProcedureReturn *OUT
  EndProcedure
  
  Procedure.i PolarToKartesian(*OUT.TComplex, *IN.TComplexPolar)
  ; ============================================================================
  ; NAME: PolarToKartesian
  ; DESC: Convert the Polar Coordinates to Kartesian Coordinates
  ; VAR(*OUT.TComplex): Pointer to OUT value as Complex kartesian 
  ; VAR(*IN.TComplexPolar): Pointer to IN value as ComplexPolar
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *IN)      ; Check Pointer Exception
    
    With *IN
      *Out\x = Cos(*IN\Phi) * *IN\R 
      *Out\iy = Sin(*IN\Phi) * *IN\R 
    EndWith
    ProcedureReturn *OUT
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
      Protected.d i=*Complex\iy, r=*Complex\x 
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
  
  Pcplx\x = P\x
  Pcplx\iy = P\y
  
  
  phi= Complex_Phase(P)
  Debug phi
  phi = Complex_Phase(Pcplx)
  Debug phi
  
  If OpenConsole()
    Define.TComplex a, b, c
    
    a\x=1.0: a\iy=1.0
    b\x=#PI: b\iy=1.2
    
    Complex_Add(c,a,b):  Show("a+b",    c)
    Complex_Mul(c,a,b):  Show("a*b",    c)
    Complex_Negate(a):    Show("-a",     a)
    Print(#CRLF$+"Press ENTER to exit"):Input()
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 291
; FirstLine = 256
; Folding = ----
; Optimizer
; CPU = 5