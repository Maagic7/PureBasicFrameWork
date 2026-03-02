; ===========================================================================
; FILE : PbFw_Module_Spline.pb
; NAME : PureBasic Framework : Module Spline [Spline::]
; DESC : Cubic Splines : C-Splines
; DESC : Basis Splines : B-Splines
; DESC : Bezier Spline
; DESC : T-Spline (free from surface)
; SOURCES: VB6 Source from F. Languasco, 2002: http://members.xoom.virgilio.it/flanguasco/
;          (link do not exist any longer). VB code was converted from Fotran.
;          https://de.wikipedia.org/wiki/Spline
;          https://en.wikipedia.org/wiki/Spline_(mathematics)
;          https://en.wikipedia.org/wiki/Smoothing_spline
;          https://en.wikipedia.org/wiki/T-spline
;
;          This describes the differences between
;          Natural Cubic Spline, Hermite Spline, Bézier Spline and B-Spline
;          https://www.baeldung.com/cs/spline-differences

; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/04
; VERSION  :  0.0  Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{
;   2026/02/28 S.Maag fixed some things with help of GEMENI
;}
;{ TODO: Implement and test all the spline stuff until know it is a Brainstroming
;   collection of code snippets of other languages which I found in Web.
;   I ported it to PureBasic - but maybe wrong! See comments in Procedures!
;}
; ===========================================================================

;{ Splines Dokumentation
; https://www.codeproject.com/Articles/747928/Spline-Interpolation-history-theory-And-implementa;
; https://github.com/tannerhelland/vb6-code
; https://github.com/tannerhelland/vb6-code/tree/master/Curves-effect

; https://rosettacode.org/wiki/Bitmap/B%C3%A9zier_curves/Cubic
; https://rosettacode.org/wiki/Bitmap/B%C3%A9zier_curves/Quadratic

; Splines in 5 Minutes
; Part 1 Cubic Curves  	: https://www.youtube.com/watch?v=YMl25iCCRew
; Part 2 come together 	: https://www.youtube.com/watch?v=DLsqkWV6Cag
; Part 3 2D And B-Splines : https://www.youtube.com/watch?v=JwN43QAlF50

; ----------------------------------------------------------------------
; 1. Natural Cubic Curve
; ----------------------------------------------------------------------
;  Biegekurve, minimiert die Biegenergie!
;   at³ + bt² +ct +d
;   4 Kontrollpunkte oder 2 Kontrollpunkte und 2 Krümmungen (Tensions)

; ----------------------------------------------------------------------
; 2. Catmull-Rom Spline
; ----------------------------------------------------------------------
;
; C1 Kontinuität = Kontinuität in der 1 Ableitung (Steigung)
;
; Folge von Punkten, die im Übergang stetig sind d.h. gleiche Steigung
; es bleibt als Freiheitsgrad am Übergang Krümmung (Tension) dadurch
; sind korrekte Übergänge mit unterschiedlichen Steigungen möglich.
; Es wird die eine Mittlere Steigung verwendet, bestimmt aus der
; Geraden vom Punkt 1 zu Punkt 3.
; die so erzeugte Folge nennt man dan Catumull-Rom-Spline

; ----------------------------------------------------------------------
; 2. Natural Cubic Spline
; ----------------------------------------------------------------------
;
; C2 Kontinuität = Kontinuität in der 2 Ableitung (Krümmung)
;
; Folge von Punkten, die im Übergang stetig sowohl in Steigung als
; auch Krümmung sind (identische Steigung und Krümmung)
; Kein Freiheitsgrad mehr im Übergang (es gibt nur eine Lösung)
; (minimierte Biegeenergie!)

; ----------------------------------------------------------------------
; 2. Bezier Splines
; ----------------------------------------------------------------------

; C2 Kontinuität : Kontinuität in der 2 Ableitung (Krümmung)
;   Ableitung einer Bezier-Kurve ist wieder eine Bezier-Kurve mit um
;   1 nierigerer Ordnung

; ----------------------------------------------------------------------
; Eigenschaften Tabelle Splines
; ----------------------------------------------------------------------
;                 :  C1  :  C2  : interpol : local control
;-----------------------------------------------------------------------
; Catmull-Rom     :   x  :  -   :    x     :   x
; Natural-Cubic   :   x  :  x   :    x     :   -
; Bezier          :   x  :  x   :    -     :   x
; ----------------------------------------------------------------------

; C1: Kontinuität in der 1. Ableitung (Steigung) s1=s2, k1<>k2
; C2: Kontinuität in der 2. Ableitung (Krümmung) s1=s2, k1 =k2

; local Control: Bei Änderung eines Kontrollpunktes wirkt sich das nur
;                local aus. Also zwischen den beiden benachbarten Punkten.
;                Bei den anderen Splines wirkt sich das weiter entfernt noch aus!
;}

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb" ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb" ; DBG::      Debug Module
XIncludeFile "PbFw_Module_VECTORd.pb" ; VECd::     double precision Vector Module

;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule Spline

  EnableExplicit

  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------

;     Structure TPoint2D
;         X.d
;         Y.d
;     EndStructure

  UseModule VECd
 
  Declare CatmullRom(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1), NI.i)

  Declare Bezier_C(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
  Declare Bezier_1(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
  Declare Bezier (Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
  Declare Bezier_P(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
  
  Declare C_Spline(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
  Declare B_Spline(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1), Nodes.i)
  Declare T_Spline(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1), VZ.i)

EndDeclareModule

Module Spline

  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module) ; Lists the Module in the ModuleList (for statistics)

  #Epsilon = 0.01

  UseModule VECd ; Module VECTORd VECd::  double precision Vector

  ;- ----------------------------------------------------------------------
  ;- Module Private - common
  ;- ----------------------------------------------------------------------

  Macro mac_IsEqual(x1, x2, delta)
    (x1 <= x2 + delta) And (x1 >= x2 -delta)
  EndMacro

  Macro mac_IsEqualPoint2D(Pt1, Pt2, Epsilon)
    mac_IsEqual(Pt1\x, Pt2\x, Epsilon) And mac_IsEqual(Pt1\y, Pt2\y, Epsilon)
  EndMacro

  Macro _mac_Exp2(value)
    (value * value)
  EndMacro

  Macro _mac_Exp3(value)
    (value * value * value)
  EndMacro

  Procedure.i _Factor(N2.i, N1.i = 2)
    ; ======================================================================
    ; NAME: _Factor
    ; DESC: Calculates the continuous product of integers from N1..N2
    ; DESC: and returns the result as Integer
    ; DESC: if N2=1 the Result is N!
    ; VAR(N1.i): N1
    ; VAR(N2.i): N2
    ; RET.d : Calculated Factor as Integer
    ; ======================================================================

    Protected.i ret
    ; berechnet fortlaufendes Produkt aus ganzen Zahlen von N1..N2
    ; bzw. Fakultät N! wenn N1=2!
    If N1 > 1
      ret = 1.0
      While N2 >= N1
        ret * N2
        N2 - 1
      Wend
    EndIf
    ProcedureReturn ret
  EndProcedure

  Procedure.d _FactorDbl(N2.i, N1.i = 2)
    ; ======================================================================
    ; NAME: _FactorDbl
    ; DESC: Calculates the continuous product of integers from N1..N2
    ; DESC: and returns the result as Double
    ; DESC: if N2=1 the Result is N!
    ; VAR(N1.i): N1
    ; VAR(N2.i): N2
    ; RET.d : Calculated Factor as Double
    ; ======================================================================

    Protected.d ret
    ; berechnet fortlaufendes Produkt aus ganzen Zahlen von N1..N2
    ; bzw. Fakultät N! wenn N1=2!
    If N1 > 1
      ret = 1
      While N2 >= N1
        ret * N2
        N2 - 1
      Wend
    EndIf
    ProcedureReturn ret
  EndProcedure

  Procedure.d _BinomialCoefficient(N.i, K.i)
    ; ======================================================================
    ; NAME: _BinomialCoefficient
    ; DESC: Calculate Binominal Coefficient N over K
    ; DESC:
    ; DESC:                               N!
    ; DESC:   BinomialCoefficient = -----------------
    ; DESC:                          ((N - K)! * K!)
    ; DESC:
    ; DESC: for the calculation, the ROW representation of the algorithm
    ; DESC: is used. An explicite calculation of N! (N-K)! and K!
    ; DESC: is not necessary. It is a calculation in a Loop
    ; DESC: This code is the port of the Rosetta Code ADA expample from
    ; DESC: https://rosettacode.org/wiki/Evaluate_binomial_coefficients#Ada
    ; VAR(N): N
    ; VAR(K): K
    ; RET.d : Binomial Coefficient
    ; ======================================================================

    Protected.i I, M
    Protected.d ret = 1.0

    If N > K
      If K >= 1
        If K > N / 2 ; Use symmetry
          M = N-K
        Else
          M = K
        EndIf
        For I = 1 To M
          ret = ret * ((N-M + I) / I)
        Next I
      EndIf
    EndIf
    ProcedureReturn ret
  EndProcedure

  Global Dim BezierCoefficientTable.d(255) ; It's pre calcualted BinomialCoeffizientTable

  Procedure _AllBernstein(n.i, t.d, Array AB.d(1))
    ; ======================================================================
    ; NAME: _AllBernstein
    ; DESC: Compute all Bernstein basis coefficients for degree 'n' at parameter
    ;       value 't'. Results are stored in 'AB' array (0..n-1).
    ; VAR(n.i): polynomial degree (integer)
    ; VAR(t.d): parameter value in [0,1]
    ; VAR(AB.d()): output array receiving Bernstein coefficients
    ; RET: -
    ; ======================================================================
    ; https://www.uni-ulm.de/fileadmin/website_uni_ulm/mawi.inst.070/ws15_16/AngewandteNumerik2/Vorlesungsskript/2015_08_19_AngNumerik2.pdf
    ; berechnet die AllBernstein Faktoren zu Gewichtung von B-Splines
    Protected.i I, K
    Protected.d t1, saved, temp
    ReDim AB.d(n - 1)

    AB(0) = 1.0
    t1 = 1 - t

    For I = 1 To n - 1

      saved = 0
      For K = 0 To I - 1
        temp = AB(K)
        AB(K) = saved + t1 * temp
        saved = t * temp
      Next
      AB(I) = saved
    Next
  EndProcedure


  Define mxCH.TMatrix ; 4x4 Hermit Cubic Polynom Matrix

  ; Hermite polynomial Matrix for 2 Points an 2 Tangents
  mac_SetVector(mxCH\v[0], 2, -2, 1, 1)
  mac_SetVector(mxCH\v[1], -3, 3, -2, -1)
  mac_SetVector(mxCH\v[2], 0, 0, 1, 0)
  mac_SetVector(mxCH\v[3], 1, 0, 0, 0)

  Procedure _TRIDAG(Array a.d(1), Array B.d(1), Array C.d(1), Array f.TPoint2D(1), Array s.TPoint2D(1), NPI_2.i)
    ; ======================================================================
    ; NAME: _TRIDAG
    ; DESC: Solve a tridiagonal linear system (Thomas algorithm) for a 2D
    ;       right-hand side stored in array 'f'. The solution is returned in
    ;       's'. This variant handles TPoint2D vectors (X/Y components).
    ; VAR(a.d()):   sub-diagonal coefficients (1..N)
    ; VAR(B.d()):   main diagonal coefficients (1..N)
    ; VAR(C.d()):   super-diagonal coefficients (1..N)
    ; VAR(f.TPoint2D()):  right-hand side vectors
    ; VAR(s.TPoint2D()):  output solution vectors
    ; VAR(NPI_2.i):       number of equations
    ; RET: -
    ; ======================================================================
    ;
    ;   Solves the tridiagonal linear system of equations:
    ;
    Protected.i J
    Protected.d bet

    Dim gam.d(NPI_2) ; we need 1 to NPI_2

    If B(1) = 0
      ProcedureReturn
    EndIf

    bet = B(1)
    s(1)\X = f(1)\X / bet
    s(1)\Y = f(1)\Y / bet
    For J = 2 To NPI_2
      gam(J) = C(J-1) / bet
      bet = B(J) - a(J) * gam(J)
      If bet = 0
        ProcedureReturn
      EndIf
      s(J)\X = (f(J)\X - a(J) * s(J-1)\X) / bet
      s(J)\Y = (f(J)\Y - a(J) * s(J-1)\Y) / bet
    Next J

    For J = NPI_2 - 1 To 1 Step -1
      s(J)\X = s(J)\X - gam(J + 1) * s(J + 1)\X
      s(J)\Y = s(J)\Y - gam(J + 1) * s(J + 1)\Y
    Next J
  EndProcedure

  Procedure _Find_CCof(Array PtIn.TPoint2D(1), NPI.i, Array cof.TPoint2D(2))
    ; ======================================================================
    ; NAME: _Find_CCof
    ; DESC: Compute cubic-spline coefficients for each segment using a
    ;       uniform parameterization. The output 'cof' contains coefficients
    ;       (cof(0..3, segment)) representing the cubic polynomial on each
    ;       interval.
    ; VAR(PtIn.TPoint2D()): input control points (1..NPI)
    ; VAR(NPI.i):           number of points
    ; VAR(cof.TPoint2D(2)): output coefficient array (0..3,1..NPI-1)
    ; RET : -
    ; ======================================================================

    ;   Find the coefficients of the cubic spline
    ;   using constant interval parameterization:
    ;
    Protected.i I
    Protected.d H

    ReDim cof.TPoint2D(4, NPI) ; we need only (1..4, 1..NPI)
    Dim s.TPoint2D(NPI) ; (1..NPI)
    Dim f.TPoint2D(NPI) ; (1..NPI)

    Dim a.d(NPI) ; (1..NPI)
    Dim B.d(NPI) ; (1..NPI)
    Dim C.d(NPI) ; (1..NPI)

    H = 1.0 / (NPI-1)
    For I = 1 To NPI - 2
      a(I) = 1.0
      B(I) = 4.0
      C(I) = 1.0
    Next I

    For I = 1 To NPI - 2
      f(I)\X = 6.0 * (PtIn(I + 1)\X - 2.0 * PtIn(I)\X + PtIn(I-1)\X) / H / H
      f(I)\Y = 6.0 * (PtIn(I + 1)\Y - 2.0 * PtIn(I)\Y + PtIn(I-1)\Y) / H / H
    Next I

    _TRIDAG(a(), B(), C(), f(), s(), NPI-2)
    For I = 1 To NPI-2
      s(NPI-I)\X = s(NPI-1-I)\X
      s(NPI-I)\Y = s(NPI-1-I)\Y
    Next I

    s(1)\X = 0.0
    s(NPI)\X = 0.0
    s(1)\Y = 0.0
    s(NPI)\Y = 0.0
    For I = 1 To NPI-1
      cof(3, I)\X = (s(I + 1)\X - s(I)\X) / 6.0 / H
      cof(3, I)\Y = (s(I + 1)\Y - s(I)\Y) / 6.0 / H
      cof(2, I)\X = s(I)\X / 2.0
      cof(2, I)\Y = s(I)\Y / 2.0
      cof(1, I)\X = (PtIn(I)\X - PtIn(I-1)\X) / H - (2.0 * s(I)\X + s(I + 1)\X) * H / 6.0
      cof(1, I)\Y = (PtIn(I)\Y - PtIn(I-1)\Y) / H - (2.0 * s(I)\Y + s(I + 1)\Y) * H / 6.0
      cof(0, I)\X = PtIn(I-1)\X
      cof(0, I)\Y = PtIn(I-1)\Y
    Next I
  EndProcedure

  Procedure _Find_TCof(Array PtIn.TPoint2D(1), NPI, Array s.TPoint2D(1), z.d)
    ; ======================================================================
    ; NAME: _Find_TCof
    ; DESC: Compute coefficients (helper values) required for T-Spline
    ;       interpolation. Produces internal array 's' used by the T-spline
    ;       evaluator, based on tension parameter 'z'.
    ; VAR(PtIn.TPoint2D()): input control points (1..NPI)
    ; VAR(NPI.i):           number of points
    ; VAR(s.TPoint2D()):    output array of helper coefficients
    ; VAR(z.d):             tension parameter
    ; RET: -
    ; ======================================================================
    ;
    ;   Find the coefficients of the T-Spline
    ;   using constant interval:
    ;
    Protected.i I
    Protected.d H, a0, b0, zh, z2

    ReDim s(NPI) ; we need (1..NPI)
    Dim f.TPoint2D(NPI) ; we need (1..NPI)
    Dim a.d(NPI) ; we need (1..NPI)
    Dim B.d(NPI) ; we need (1..NPI)
    Dim C.d(NPI) ; we need (1..NPI)

    H = 1.0 / (NPI-1)
    zh = z * H
    a0 = 1.0 / H - z / SinH(zh)
    b0 = z * 2.0 * CosH(zh) / SinH(zh) - 2.0 / H
    For I = 1 To NPI-2
      a(I) = a0
      B(I) = b0
      C(I) = a0
    Next I

    z2 = z * z / H
    For I = 1 To NPI-2
      f(I)\X = (PtIn(I + 1)\X - 2.0 * PtIn(I)\X + PtIn(I-1)\X) * z2
      f(I)\Y = (PtIn(I + 1)\Y - 2.0 * PtIn(I)\Y + PtIn(I-1)\Y) * z2
    Next I

    _TRIDAG(a(), B(), C(), f(), s(), NPI-2)
    For I = 1 To NPI-2
      s(NPI-I)\X = s(NPI-1-I)\X
      s(NPI-I)\Y = s(NPI-1-I)\Y
    Next I

    s(1)\X = 0.0
    s(NPI)\X = 0.0
    s(1)\Y = 0.0
    s(NPI)\Y = 0.0
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Catmull-Rom Splines
  ;- ----------------------------------------------------------------------
  ; C1=yes, C2=no, interpolating=yes, localcontrol=yes

  ; https://www.baeldung.com/cs/spline-differences
  ; 5. Hermite Basis Polynomials and Cubic Hermite Interpolation
  ; https://de.wikipedia.org/wiki/Kubisch_Hermitescher_Spline

  ; Private
  Procedure _Catmull_RomTangent(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
    ; ============================================================================
    ; NAME: CatmullRom_Tangent
    ; DESC: Calculates the Catmull-Rom approach of the tangent
    ; DESC: tangent[i] = 0.5 * (point[i+1] - point[i-1])
    ; DESC: Assume endpoint tangents are parallel With line with neighbour
    ; VAR(PtOut.TPoint2D()): Points Array for Tangents
    ; VAR(PtIn.TPoint2D()) : Points Array of Spline Control Points
    ; RET - :
    ; ============================================================================

    ; TODO! Try SSE Vector optimation (Copy 2 Point2D in a Vector and use Vector operations)

    #Catmull_Tangent_Factor = 0.5

    Protected.i I, nPIn, IsClosedSpline

    nPIn = ArraySize(PtIn())

    If mac_IsEqualPoint2D(PtIn(0), PtIn(nPIn), #Epsilon)
      PtIn(nPIn) = PtIn(0) ; Closed Spline
      IsClosedSpline = #True
    EndIf

    For I = 1 To nPIn-1
      PtOut(0)\x = (PtIn(I)\x - PtIn(I-1)\x) * #Catmull_Tangent_Factor
      PtOut(0)\y = (PtIn(I)\y - PtIn(I-1)\y) * #Catmull_Tangent_Factor
    Next

    ; now we must calcualte 1st and last Tangents seperate for open and closed Splines
    If IsClosedSpline
      ; For a closed Spline we have to overried the firtst Tangents
      PtOut(0)\x = (PtIn(1)\x - PtIn(nPIn-1)\x) * #Catmull_Tangent_Factor
      PtOut(0)\y = (PtIn(1)\y - PtIn(nPIn-1)\y) * #Catmull_Tangent_Factor

      ; last Tagents for a closed Spline is same as first
      PtOut(nPIn) = PtOut(0)

    Else ; open Spline
      ; last Tagents for an open Spline
      PtOut(nPIn)\x = (PtIn(nPIn)\x - PtIn(nPIn-1)\x) * #Catmull_Tangent_Factor
      PtOut(nPIn)\y = (PtIn(nPIn)\y - PtIn(nPIn-1)\y) * #Catmull_Tangent_Factor
      ; first Tanget was calculated correctly in the Loop
    EndIf
  EndProcedure

  ; --------------------------------------------------------------------------------
  ;  Module Public
  ; --------------------------------------------------------------------------------

  Procedure CatmullRom(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1), NI.i)
    ; ============================================================================
    ; NAME: CatmullRom_
    ; DESC: Calculates the Catmull-Rom Spline Interpolation
    ; DESC: with a number of interpolation Points [NI]
    ; VAR(PtOut.TPoint2D()): Points Array to draw the Curve
    ; VAR(PtIn.TPoint2D()) : Points Array with the Spline Control Points
    ; VAR(NI.i): Number of Interpolation Points
    ; RET :
    ; ============================================================================

    Shared mxCH ; Shared use inside the Procedure of coefficient Matrix

    Protected.i I, J, nPIn, nPOut, idxOut
    Protected.d t ; Time variable t={0..1}
    Protected vecPow.TVector ; Power Vector
    Protected vecRet.TVector ; Calculation Return Vector
    Protected mxPts.TMatrix ; Point-Tangent Matrix
    Protected mxRet.TMatrix ; Calculation Return Matrix

    ; The Algorithm is: Ret = powers * Coeffs * Matrix4(point1, point2, tangent1, tangent2)

    nPIn = ArraySize(PtIn())
    nPOut = nPIn * NI

    If ArraySize(PtOut()) <> nPOut
      ReDim PtOut(nPOut)
    EndIf

    Dim PtTan.TPoint2D(nPIn) ; Tangent Points

    _Catmull_RomTangent(PtTan(), PtIn()) ; Calculate Catmul-Rom Tangets

    ; set the constant part of the Power Vector
    vecPow\w = 1.0 ; w is a constant

    ; set the constant part of the Points Matrix
    With mxPts
      \v[0]\w = 1.0
      \v[1]\w = 1.0
      \v[2]\w = 1.0
      \v[3]\w = 1.0
    EndWith

    For I = 1 To nPIn
      ; ----------------------------------------------------------------------
      ;  Step through all ControlPoints (Segments)
      ; ----------------------------------------------------------------------

      ; The first Point of the segement is the ControlPoint, t=0
      PtOut(idxOut) = PtIn(I-1)

      For J = 1 To NI
        ; ----------------------------------------------------------------------
        ;  Step through the interpolated Points
        ; ----------------------------------------------------------------------

        t = J / NI ; Time Value form t={0..1}={0..100%}
        ; Form a vector of powers of t
        With vecPow
          \x = t*t*t ; t³
          \y = t*t ; t²
          \z = t ; t
          ;\w = 1.0        ; 1.0   ; it is constant and was set outside the Loop
        EndWith

        With mxPts ; Points Matrix
          ; Set the Points-Matrix, using 2 ControlPoints and 2 Tangents

          ; To copy the Points in an esay way, we use the VectorView of the Matrix
          ; copy Control Point 1 to Matrix
          \v[0]\Pt2D[0] = PtIn(I-1)
          ; \v[0]\w = 1.0       ; fixed part already set outside the Loop

          ; copy Control Point 2 to Matrix
          \v[1]\Pt2D[0] = PtIn(I)
          ; \v[1]\w = 1.0       ; fixed part already set outside the Loop

          ; copy Tangent 1 to Matrix
          \v[2]\Pt2D[0] = PtTan(I-1)
          ; \v[2]\w = 1.0       ; fixed part already set outside the Loop

          ; copy Tangent 2 to Matrix
          \v[3]\Pt2D[0] = PtTan(I)
          ; \v[3]\w = 1.0       ; fixed part already set outside the Loop
        EndWith

        ; Calculate the interpolated Point
        ; vecRet = vecPow * (mxPts * mxCH)
        Matrix_X_Matrix(mxRet, mxPts, mxCH) ; function from VECd::
        Vector_X_Matrix(vecRet, vecPow, mxRet) ; function from VECd::

        idxOut + 1 ; index of the actual output point of the compelte Spline
        PtOut(idxOut) = vecRet\Pt2D[0] ; for 2D Splines we use only the Point2D part of the caclculated Vector

      Next J ; Loop of interpolated Points
    Next I ; Loop or ControlPoints

    ; Now we must set the last Spline Point which is the last ControlPoint
    idxOut + 1 ; now idxOut = nPOut
    ; Last Point on curve = PtIn(nPin) => LastSegment, t = 1
    PtOut(idxOut) = PtIn(nPIn)

    ProcedureReturn PtOut()
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Natrual Cubic Splines
  ;- ----------------------------------------------------------------------
  ; C1=yes, C2=yes, interpolating=yes, localcontrol=no

  Procedure _NaturalCubicTangent(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
    ; ============================================================================
    ; NAME: _NaturalCubicTangent
    ; DESC: Compute first derivatives (tangents) for a natural cubic spline
    ;       (second derivatives zero at endpoints) from a series of control
    ;       points.  The resulting tangents are suitable for use with the
    ;       Hermite-curve interpolation routine used elsewhere in this module.
    ;
    ;       Algorithm:
    ;         * solve for second derivatives (s) by tri-diagonal system
    ;         * use closed-form expression to convert second derivatives into
    ;           first derivatives at each knot.
    ;
    ; VAR(PtOut.TPoint2D()): receives the tangent vectors (same dimension as PtIn)
    ; VAR(PtIn.TPoint2D()): array of input control points.
    ; ============================================================================
    Protected.i I, nPIn
    Protected.d H
    Dim s.TPoint2D(1) ; second-derivative helpers
    Dim f.TPoint2D(1)
    Dim a.d(1)
    Dim B.d(1)
    Dim C.d(1)
    
    nPIn = ArraySize(PtIn())
    If nPIn < 2
      ProcedureReturn ; nothing to do
    EndIf
    H = 1.0 / (nPIn - 1)

    ; allocate working arrays (1..nPIn)
    ReDim s.TPoint2D(nPIn)
    ReDim f.TPoint2D(nPIn)
    ReDim a.d(nPIn)
    ReDim B.d(nPIn)
    ReDim C.d(nPIn)

    ; build system for second derivatives
    For I = 1 To nPIn - 2
      a(I) = 1.0
      B(I) = 4.0
      C(I) = 1.0
      f(I)\X = 6.0 * (PtIn(I + 1)\X - 2.0 * PtIn(I)\X + PtIn(I-1)\X) / H / H
      f(I)\Y = 6.0 * (PtIn(I + 1)\Y - 2.0 * PtIn(I)\Y + PtIn(I-1)\Y) / H / H
    Next I

    _TRIDAG(a(), B(), C(), f(), s(), nPIn - 2)
    ; reflect the solution (algorithm in _NaturalCubicCoeff)
    For I = 1 To nPIn - 2
      s(nPIn - I)\X = s(nPIn - 1 - I)\X
      s(nPIn - I)\Y = s(nPIn - 1 - I)\Y
    Next I
    s(1)\X = 0.0 : s(nPIn)\X = 0.0
    s(1)\Y = 0.0 : s(nPIn)\Y = 0.0

    ; now convert second derivatives into first derivatives (tangents)
    For I = 0 To nPIn
      If I = 0
        ; natural boundary: derivative equals forward difference
        PtOut(I)\X = (PtIn(1)\X - PtIn(0)\X) / H
        PtOut(I)\Y = (PtIn(1)\Y - PtIn(0)\Y) / H
      ElseIf I = nPIn
        ; other boundary: backward difference
        PtOut(I)\X = (PtIn(nPIn)\X - PtIn(nPIn - 1)\X) / H
        PtOut(I)\Y = (PtIn(nPIn)\Y - PtIn(nPIn - 1)\Y) / H
      Else
        ; interior formula from standard cubic spline theory
        PtOut(I)\X = (PtIn(I + 1)\X - PtIn(I - 1)\X) / (2 * H) - (s(I + 1)\X - s(I - 1)\X) * H / 6.0
        PtOut(I)\Y = (PtIn(I + 1)\Y - PtIn(I - 1)\Y) / (2 * H) - (s(I + 1)\Y - s(I - 1)\Y) * H / 6.0
      EndIf
    Next I
  EndProcedure

  Procedure _NaturalCubicCoeff(Array PtIn.TPoint2D(1), NPI.i, Array cof.TPoint2D(2))
    ; ============================================================================
    ; NAME: _NaturalCubicCoeff
    ; DESC: Compute coefficient arrays for a natural cubic spline (uniform
    ;       parameterization). Produces cubic coefficients usable by the
    ;       interpolator per segment.
    ; VAR(PtIn.TPoint2D()) : input control points (1..NPI)
    ; VAR(NPI.i) : number of points
    ; VAR(cof.TPoint2D(2)) : output coefficient array (0..3,1..NPI-1)
    ; RET: -
    ; ============================================================================

    ;   Find the coefficients of the natural cubic spline
    ;   using constant interval parameterization:
    ;
    Protected.i I
    Protected.d H

    ReDim cof.TPoint2D(4, NPI) ; we need only (1..4, 1..NPI)
    Dim s.TPoint2D(NPI) ; (1..NPI)
    Dim f.TPoint2D(NPI) ; (1..NPI)

    Dim a.d(NPI) ; (1..NPI)
    Dim B.d(NPI) ; (1..NPI)
    Dim C.d(NPI) ; (1..NPI)

    H = 1.0 / (NPI-1)
    For I = 1 To NPI - 2
      a(I) = 1.0
      B(I) = 4.0
      C(I) = 1.0
    Next I

    For I = 1 To NPI - 2
      f(I)\X = 6.0 * (PtIn(I + 1)\X - 2.0 * PtIn(I)\X + PtIn(I-1)\X) / H / H
      f(I)\Y = 6.0 * (PtIn(I + 1)\Y - 2.0 * PtIn(I)\Y + PtIn(I-1)\Y) / H / H
    Next I

    _TRIDAG(a(), B(), C(), f(), s(), NPI-2)
    For I = 1 To NPI-2
      s(NPI-I)\X = s(NPI-1-I)\X
      s(NPI-I)\Y = s(NPI-1-I)\Y
    Next I

    s(1)\X = 0.0
    s(NPI)\X = 0.0
    s(1)\Y = 0.0
    s(NPI)\Y = 0.0
    For I = 1 To NPI-1
      cof(3, I)\X = (s(I + 1)\X - s(I)\X) / 6.0 / H
      cof(3, I)\Y = (s(I + 1)\Y - s(I)\Y) / 6.0 / H
      cof(2, I)\X = s(I)\X / 2.0
      cof(2, I)\Y = s(I)\Y / 2.0
      cof(1, I)\X = (PtIn(I)\X - PtIn(I-1)\X) / H - (2.0 * s(I)\X + s(I + 1)\X) * H / 6.0
      cof(1, I)\Y = (PtIn(I)\Y - PtIn(I-1)\Y) / H - (2.0 * s(I)\Y + s(I + 1)\Y) * H / 6.0
      cof(0, I)\X = PtIn(I-1)\X
      cof(0, I)\Y = PtIn(I-1)\Y
    Next I
  EndProcedure

  Procedure NaturalCubic(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1), NI.i)

    Protected.i I, J, nPIn, nPOut, idxOut
    Protected.d t ; Time variable t={0..1}
    Protected vecPow.TVector ; Power Vector
    Protected vecRet.TVector ; Calculation Return Vector
    Protected mxPts.TMatrix ; Point-Tangent Matrix
    Protected mxRet.TMatrix ; Calculation Return Matrix
    Shared mxCH ; use global Hermite coefficient matrix

    nPIn = ArraySize(PtIn())
    nPOut = nPIn * NI

    If ArraySize(PtOut()) <> nPOut
      ReDim PtOut(nPOut)
    EndIf

    Dim PtTan.TPoint2D(nPIn) ; Tangent Points

    _NaturalCubicTangent(PtTan(), PtIn()) ; Calculate  Tangets

    ; set the constant part of the Power Vector
    vecPow\w = 1.0 ; w is a constant

    ; set the constant part of the Points Matrix
    With mxPts
      \v[0]\w = 1.0
      \v[1]\w = 1.0
      \v[2]\w = 1.0
      \v[3]\w = 1.0
    EndWith

    For I = 1 To nPIn
      ; ----------------------------------------------------------------------
      ;  Step through all ControlPoints (Segments)
      ; ----------------------------------------------------------------------

      ; The first Point of the segement is the ControlPoint, t=0
      PtOut(idxOut) = PtIn(I-1)

      For J = 1 To NI
        ; ----------------------------------------------------------------------
        ;  Step through the interpolated Points
        ; ----------------------------------------------------------------------

        t = J / NI ; Time Value form t={0..1}={0..100%}
        ; Form a vector of powers of t
        With vecPow
          \x = t*t*t ; t³
          \y = t*t ; t²
          \z = t ; t
          ;\w = 1.0        ; 1.0   ; it is constant and was set outside the Loop
        EndWith

        With mxPts ; Points Matrix
          ; Set the Points-Matrix, using 2 ControlPoints and 2 Tangents

          ; To copy the Points in an esay way, we use the VectorView of the Matrix
          ; copy Control Point 1 to Matrix
          \v[0]\Pt2D[0] = PtIn(I-1)
          ; \v[0]\w = 1.0       ; fixed part already set outside the Loop

          ; copy Control Point 2 to Matrix
          \v[1]\Pt2D[0] = PtIn(I)
          ; \v[1]\w = 1.0       ; fixed part already set outside the Loop

          ; copy Tangent 1 to Matrix
          \v[3]\Pt2D[0] = PtTan(I-1)
          ; \v[3]\w = 1.0       ; fixed part already set outside the Loop

          ; copy Tangent 2 to Matrix
          \v[4]\Pt2D[0] = PtTan(I)
          ; \v[4]\w = 1.0       ; fixed part already set outside the Loop
        EndWith

        ; Calculate the interpolated Point
        ; vecRet = vecPow * (mxPts * mxCH)
        Matrix_X_Matrix(mxRet, mxPts, mxCH) ; use Hermite matrix
        Vector_X_Matrix(vecRet, vecPow, mxRet)

        idxOut + 1 ; index of the actual output point of the compelte Spline
        PtOut(idxOut) = vecRet\Pt2D[0] ; for 2D Splines we use only the Point2D part of the caclculated Vector

      Next J ; Loop of interpolated Points
    Next I ; Loop or ControlPoints

    ; Now we must set the last Spline Point which is the last ControlPoint
    idxOut + 1 ; now idxOut = nPOut
    ; Last Point on curve = PtIn(nPin) => LastSegment, t = 1
    PtOut(idxOut) = PtIn(nPIn)

    ProcedureReturn PtOut()
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Bezier Splines
  ;- ----------------------------------------------------------------------
  ; C1=yes, C2=yes, interpolating=no, localcontrol=yes

  ;https://rosettacode.org/wiki/B-spline

  ; Private
  Procedure _InitBezierCoefficientTable(nPoints)
    ; ======================================================================
    ; NAME: _InitBezierCoefficientTable
    ; DESC: Precompute and initialize a table of binomial coefficients used
    ;       by Bezier basis calculations to accelerate repeated evaluations.
    ; VAR(nPoints) : maximum number of points (degree+1) to prepare table for
    ; RET: -
    ; ======================================================================
    Protected I

    If ArraySize(BezierCoefficientTable()) < nPoints
      ReDim BezierCoefficientTable(nPoints)
      For I = 1 To nPoints-1
        BezierCoefficientTable(I) = _BinomialCoefficient(nPoints, I)
      Next
    EndIf
  EndProcedure

  _InitBezierCoefficientTable(254) ; initialize BinomialCoefficientTable with 255 values

  ;- ----------------------------------------------------------------------
  ;- Cubic Bezier Splines
  ;- ----------------------------------------------------------------------
  ; C1=yes, C2=yes, interpolating=no, localcontrol=yes


  ;- ----------------------------------------------------------------------
  ;- Quadratic Bezier Splines
  ;- ----------------------------------------------------------------------
  ; C1=yes, C2=yes, interpolating=no, localcontrol=yes

  ;- ----------------------------------------------------------------------
  ;- Rational Bezier Splines (high order Plynoms [5..99])
  ;- ----------------------------------------------------------------------
  ; C1=yes, C2=yes, interpolating=no, localcontrol=yes


  Procedure _B_Basis(nPIn.i, ut.d, K.i, Array AB.d(1))
    ; ======================================================================
    ; NAME: _B_Basis
    ; DESC: Compute the B-spline basis (weights) for parameter 'ut' and
    ;       degree/order 'K' over 'nPIn' control points. Result returned in
    ;       AB (0..nPIn).
    ; VAR(nPIn.i):  number of control points (n)
    ; VAR(ut.d):    parameter value (typically scaled to knot vector)
    ; VAR(K.i):     degree/order of the B-spline
    ; VAR(AB.d()):  output array of basis weights
    ; RET: -
    ; ======================================================================
    ;
    ;   Compute the basis function (also called weight)
    ;   for the B-Spline approximation curve:
    ;
    Protected.i NT, I, J
    Protected.d b0, b1, bl0, bl1, bu0, bu1

    ReDim AB (nPIn + 1)
    Dim AB0.d(nPIn + 1)
    Dim t.d(nPIn + K + 1)

    NT = nPIn + K + 1
    For I = 0 To NT
      If (I < K)
        t(I) = 0.0
      EndIf

      If ((I >= K) And (I <= nPIn))
        t(I) = (I - K + 1)
      EndIf

      If (I > nPIn)
        t(I) = (nPIn - K + 2)
      EndIf
    Next I

    For I = 0 To nPIn
      AB0(I) = 0.0
      If ((ut >= t(I)) And (ut < t(I + 1)))
        AB0(I) = 1.0
      EndIf

      If ((t(I) = 0.0) And (t(I + 1) = 0.0))
        AB0(I) = 0.0
      EndIf
    Next I

    For J = 2 To K
      For I = 0 To nPIn
        bu0 = (ut - t(I)) * AB0(I)
        bl0 = t(I + J - 1) - t(I)
        If (bl0 = 0.0)
          b0 = 0.0
        Else
          b0 = bu0 / bl0

        EndIf

        bu1 = (t(I + J) - ut) * AB0(I + 1)
        bl1 = t(I + J) - t(I + 1)
        If (bl1 = 0.0)
          b1 = 0.0
        Else
          b1 = bu1 / bl1
        EndIf
        AB(I) = b0 + b1
      Next I
      For I = 0 To nPIn
        AB0(I) = AB(I)
      Next I

    Next J

  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Module Public
  ;- ----------------------------------------------------------------------

  Procedure Bezier_C(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
    ; ======================================================================
    ; NAME: Bezier_C
    ; DESC: Compute Bezier curve points into PtOut for parameter t in [0,1]
    ;       using the Bernstein polynomial formulation. This version maps
    ;       the full closed interval t=[0..1].
    ; VAR(PtOut.TPoint2D()) : output point array
    ; VAR(PtIn.TPoint2D()) : input control points
    ; RET: -
    ; ======================================================================
    ;
    ;   Ritorna, nel vettore PtOut(), i valori della curva di Bezier calcolata
    ;   al valore t (0 <= t <= 1). La curva e' calcolata in modo
    ;   parametrico con il valore 0 di t corrispondente a PtOut(0)
    ;   ed il valore 1 corrispondente a PtOut(nPOut).
    ;   Questo algoritmo ricalca la forma classica del polinomio
    ;   di Bernstein.
    ;
    Protected.i I, K, nPIn, nPOut, NF
    Protected.d t, BF

    nPIn = ArraySize(PtIn()) ; N Points-In
    nPOut = ArraySize(PtOut()) ; n Points-Out

    For I = 0 To nPOut
      t = (I) / (nPOut)
      PtOut(I)\X = 0.0
      PtOut(I)\Y = 0.0
      ;PtOut(I)\Z = 0.0       ; for 3D Splines

      For K = 0 To nPIn
        BF = _FactorDbl(nPIn, K + 1) * Pow(t, K) * Pow((1.0-t), (nPIn-K)) / _Factor(nPIn-K)

        PtOut(I)\X = PtOut(I)\X + PtIn(K)\X * BF
        PtOut(I)\Y = PtOut(I)\Y + PtIn(K)\Y * BF
        ;PtOut(I)\Z = PtOut(I)\Z + PtIn(K)\Z * BF  ; for 3D Splines
      Next K
    Next I

  EndProcedure

  ; ======================================================================
  ; NAME: Bezier_1
  ; DESC: Compute Bezier curve samples in PtOut for t in [0,1) (excluding
  ;       the final endpoint). Uses an incremental algorithm that avoids
  ;       direct factorial computations.
  ; VAR(PtOut.TPoint2D()) : output point array
  ; VAR(PtIn.TPoint2D()) : input control points
  ; RET - : fills PtOut (except last point, which corresponds to t=1)
  ; ======================================================================
  Procedure Bezier_1(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
    ;
    ;   Ritorna, nel vettore PtOut(), i valori della curva di Bezier.
    ;   La curva e' calcolata in modo parametrico (0 <= t < 1)
    ;   con il valore 0 di t corrispondente a PtOut(0);
    ;   Attenzione: il punto PtOut(nPOut), corrispondente al valore t = 1,
    ;               non puo; essere calcolato.
    ;
    ;   Parametri:
    ;       PtIn(0 to NPI-1):   Vettore dei punti, dati, da
    ;                           approssimare.
    ;       PtOut(0 to NPC-1):   Vettore dei punti, calcolati,
    ;                           della curva approssimante.
    ;
    Protected I, K, nPIn, nPOut
    Protected.d t, t1, ue, u_1e, BF

    nPIn = ArraySize(PtIn()) ; N. di punti da approssimare - 1.
    nPOut = ArraySize(PtOut()) ; N. di punti sulla curva - 1.

    ; La curva inizia sempre da PtIn(0) -> t = 0:
    PtOut(0)\X = PtIn(0)\X
    PtOut(0)\Y = PtIn(0)\Y
    ;PtOut(0)\Z = PtIn(0)\Z  ; for 3D Splines

    For I = 1 To nPOut-1
      t = (I) / (nPOut)
      ue = 1.0
      t1 = 1.0-t
      u_1e = Pow(t1, nPIn)

      PtOut(I)\X = 0.0
      PtOut(I)\Y = 0.0
      ;PtOut(I)\Z = 0.0
      For K = 0 To nPIn
        BF = _FactorDbl(nPIn, K + 1) * ue * u_1e / _FactorDbl(nPIn-K)
        PtOut(I)\X = PtOut(I)\X + PtIn(K)\X * BF
        PtOut(I)\Y = PtOut(I)\Y + PtIn(K)\Y * BF
        ;PtOut(I)\Z = PtOut(I)\Z + PtIn(K)\Z * BF  ; for 3D Splines

        ue = ue * t
        u_1e = u_1e / t1
      Next K
    Next I

    ; Last Point on curve = PtIn(nPin) => t = 1
    PtOut(nPOut) = PtIn(nPIn)

  EndProcedure

  Procedure Bezier(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
    ;
    ;   Ritorna, nel vettore PtOut(), i valori della curva di Bezier.
    ;   La curva e' calcolata in modo parametrico (0 <= t < 1)
    ;   con il valore 0 di t corrispondente a PtOut(0);
    ;
    ;   Questa versione elimina alcuni problemi di "underflow"
    ;   e di "overflow" presentati dalla Bezier_1 e dalla Bezier_C.
    ;
    ;   Parametri:
    ;       PtIn(0 to NPI-1):   Vettore dei punti, dati, da
    ;                           approssimare.
    ;       PtOut(0 to NPC-1):   Vettore dei punti, calcolati,
    ;                           della curva approssimante.
    ;

    Protected.i I, K, nPIn, nPOut
    Protected.d t, ue, BF

    nPIn = ArraySize(PtIn()) ; Number of Points  (2 <= nPIn <= 1029).
    nPOut = ArraySize(PtOut()) ; Numger of Points on curve

    If ArraySize(BezierCoefficientTable()) < nPIn
      _InitBezierCoefficientTable(nPIn)
    EndIf

    ; The curve starts always with  PtIn(0) => t = 0
    PtOut(0) = PtIn(0)

    For I = 1 To nPOut-1
      t = I / nPOut
      ue = 1.0

      PtOut(I)\X = 0.0
      PtOut(I)\Y = 0.0
      ;PtOut(I)\Z = 0.0  ; for 3D Splines

      For K = 0 To nPIn
        BF = BezierCoefficientTable(K) * ue * Pow((1.0-t), (nPIn-K))

        PtOut(I)\X = PtOut(I)\X + PtIn(K)\X * BF
        PtOut(I)\Y = PtOut(I)\Y + PtIn(K)\Y * BF
        ;PtOut(I)\Z = PtOut(I)\Z + PtIn(K)\Z * BF  ; for 3D Splines

        Ue = ue * t
      Next K
    Next I

    ; Last Point on curve = PtIn(nPin) => t = 1
    PtOut(nPOut) = PtIn(nPIn)

  EndProcedure

  Procedure Bezier_P(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
    ; ======================================================================
    ; NAME: Bezier_P
    ; DESC: Compute Bezier curve samples using an algorithm from P. Bourke
    ;       that avoids factorials and is numerically stable for many orders.
    ; VAR(PtOut.TPoint2D()) : output array
    ; VAR(PtIn.TPoint2D()) : input control points
    ; RET - : fills PtOut with curve samples (last element = PtIn(nPIn))
    ; ======================================================================
    ;
    ;   Ritorna, nel vettore PtOut(), i valori della curva di Bezier calcolata
    ;   al valore t (0 <= t < 1). La curva e' calcolata in modo
    ;   parametrico con il valore 0 di t corrispondente a PtOut(0);
    ;   Attenzione: il punto PtOut(nPOut), corrispondente al valore t = 1,
    ;               non puo; essere calcolato.
    ;
    ;   Questo algoritmo (tratto da una pubblicazione di P. Bourke
    ;   e tradotto dal C) e' particolarmente interessante, in quanto
    ;   evita l' uso dei fattoriali della forma normale.
    ;
    Protected.i I, K, memK, nPIn, nPOut, NoOfNodes, Node
    Protected.d t, uk, dPow, dBlend

    nPIn = ArraySize(PtIn())
    nPOut = ArraySize(PtOut())

    For I = 0 To nPOut-1
      t = I / nPOut
      uk = 1.0
      dPow = Pow((1.0-t), nPIn)

      PtOut(I)\X = 0
      PtOut(I)\Y = 0
      ;PtOut(I)\Z = 0  ; for 3D Splines

      For K = 0 To nPIn

        NoOfNodes = nPIn
        memK = K
        Node = nPIn - K
        dBlend = uk * dPow
        uk = uk * t
        dPow = dPow / (1.0-t)

        While NoOfNodes >= 1
          dBlend = dBlend * NoOfNodes
          NoOfNodes - 1
          If memK > 1
            dBlend = dBlend / memK
            memK -1
          EndIf
          If Node > 1
            dBlend = dBlend / Node
            Node - 1
          EndIf
        Wend

        PtOut(I)\X = PtOut(I)\X + PtIn(K)\X * dBlend
        PtOut(I)\Y = PtOut(I)\Y + PtIn(K)\Y * dBlend
        ;PtOut(I)\Z = PtOut(I)\Z + PtIn(K)\Z * dBlend  ; for 3D Splines
      Next
    Next

    ; Last Point on curve = PtIn(nPin) => t = 1
    PtOut(nPOut) = PtIn(nPIn)

  EndProcedure

  Procedure C_Spline(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1))
    ; ======================================================================
    ; NAME: C_Spline
    ; DESC: Compute natural cubic spline interpolation samples for given
    ;       control points into PtOut. Uses uniform parameterization and
    ;       the internal _Find_CCof helper to obtain per-segment coefficients.
    ; VAR(PtOut.TPoint2D()) : output array of interpolated points
    ; VAR(PtIn.TPoint2D()) : input control points
    ; VAR(NI.i) : number of interpolation subdivisions per segment (passed by caller)
    ; RET - : fills PtOut with interpolated curve points
    ; ======================================================================
    ;
    ;   Ritorna, nel vettore PtOut(), i valori della curva C-Spline.
    ;   La curva e' calcolata in modo parametrico (0 <= t <= 1)
    ;   con il valore 0 di t corrispondente a PtOut(0) ed il valore
    ;   1 corrispondente a PtOut(nPOut).
    ;
    ;   Parametri:
    ;       PtIn(0 to NPI - 1):   Vettore dei punti, dati, da
    ;                           interpolare.
    ;       PtOut(0 to NPC - 1):   Vettore dei punti, calcolati,
    ;                           della curva interpolante.
    ;
    Protected.i nPIn, nPOut, I, J
    Protected.d t, ui
    Dim cof.TPoint2D(0, 0)

    nPIn = ArraySize(PtIn()) ; N. di punti da interpolare - 1.
    nPOut = ArraySize(PtOut()) ; N. di punti sulla curva - 1.

    _Find_CCof(PtIn(), nPIn + 1, cof())

    ; The curve starts always with  PtIn(0) => t = 0
    PtOut(0) = PtIn(0)

    For I = 1 To nPOut-1
      t = I / nPOut
      J = Int(t * nPIn) + 1

      If J > nPIn : J = nPIn : EndIf

      ui = t - (J-1) / nPIn

      PtOut(I)\X = cof(3, J)\X * _mac_Exp3(ui) + cof(2, J)\X * _mac_Exp2(ui) + cof(1, J)\X * ui + cof(0, J)\X
      PtOut(I)\Y = cof(3, J)\Y * _mac_Exp3(ui) + cof(2, J)\Y * _mac_Exp2(ui) + cof(1, J)\Y * ui + cof(0, J)\Y
      ;PtOut(I)\Z = cof(3, J)\Z * _mac_Exp3(ui) + cof(2, J)\Z * _mac_Exp2(ui) + cof(1, J)\Z * ui + cof(0, J)\Z  ; for 3D Splines
    Next I

    ; Last Point on curve = PtIn(nPin) => t = 1
    PtOut(nPOut) = PtIn(nPIn)
  EndProcedure

  Procedure B_Spline(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1), Nodes.i)
    ; ======================================================================
    ; NAME: B_Spline
    ; DESC: Compute a B-spline approximation curve sample set for the given
    ;       control points. The 'Nodes' parameter determines the spline order
    ;    (Nodes=2 -> linear segments, Nodes=3 -> quadratic, etc.).
    ; VAR(PtOut.TPoint2D()) : output sampled points
    ; VAR(PtIn.TPoint2D()) : input control points
    ; VAR(Nodes.i) : spline order / number of nodes
    ; RET - : fills PtOut with approximated B-spline samples
    ; ======================================================================
    ;
    ;   Ritorna, nel vettore PtOut(), i valori della curva B-Spline.
    ;   La curva e' calcolata in modo parametrico (0 <= t <= 1)
    ;   con il valore 0 di t corrispondente a PtOut(0) ed il valore
    ;   1 corrispondente a PtOut(nPOut).
    ;
    ;   Parametri:
    ;       PtIn(0 to NPI - 1):   Vettore dei punti, dati, da
    ;                           approssimare.
    ;       PtOut(0 to NPC - 1):   Vettore dei punti, calcolati,
    ;                           della curva approssimante.
    ;       Nodes:                 Numero di nodi della curva
    ;                           approssimante:
    ;                           Nodes = 2    -> segmenti di retta.
    ;                           Nodes = 3    -> curve quadratiche.
    ;                           ..   .       ..................
    ;                           Nodes = NPI  -> splines di Bezier.

    Protected.i nPIn, nPOut, I, J
    Protected.d tmax, t, ut
    Dim bn.d(0)
    #Eps = 0.0000001

    nPIn = ArraySize(PtIn()) ; N. di punti da approssimare - 1.
    nPOut = ArraySize(PtOut()) ; N. di punti sulla curva - 1.
    tmax = nPIn - Nodes + 2

    ; The curve starts always with  PtIn(0) => t = 0
    PtOut(0)\X = PtIn(0)\X
    PtOut(0)\Y = PtIn(0)\Y
    ; PtOut(0)\Z = PtIn(0)\Z  ; for 3D Splines

    For I = 1 To nPOut-1
      t = I / nPOut
      ut = t * tmax
      If Abs(ut - (nPIn + Nodes-2)) <= #Eps
        PtOut(I)\X = PtIn(nPIn)\X
        PtOut(I)\Y = PtIn(nPIn)\Y
        ;PtOut(I)\Z = PtIn(nPIn)\Z  ; for 3D Spline
      Else
        _B_Basis(nPIn, ut, Nodes, bn())
        For J = 0 To nPIn
          PtOut(I)\X = PtIn(J)\X * bn(J)
          PtOut(I)\Y = PtIn(J)\Y * bn(J)
          ;PtOut(I)\Z = PtIn(J)\Z * bn(J)  ; for 3D Spline
        Next J
      EndIf
    Next I

    ; Last Point on curve = PtIn(nPin) => t = 1
    PtOut(nPOut) = PtIn(nPIn)

  EndProcedure

  Procedure T_Spline(Array PtOut.TPoint2D(1), Array PtIn.TPoint2D(1), VZ.i)
    ; ======================================================================
    ; NAME: T_Spline
    ; DESC: Compute T-spline interpolation samples for given control points
    ;       with tension parameter 'VZ'. Higher VZ flattens the curve.
    ; VAR(PtOut.TPoint2D()):  output array of sampled points
    ; VAR(PtIn.TPoint2D()):   input control points
    ; VAR(VZ.i): tension parameter [1..100], higher values flatten the curve
    ; RET - : fills PtOut with interpolated points
    ; ======================================================================
    ;
    ;   Ritorna, nel vettore PtOut(), i valori della curva T-Spline.
    ;   La curva e' calcolata in modo parametrico (0 <= t <= 1)
    ;   con il valore 0 di t corrispondente a PtOut(0) ed il valore
    ;   1 corrispondente a PtOut(nPOut).
    ;
    ;   Parametri:
    ;       PtIn(0 to NPI - 1):   Vettore dei punti, dati, da
    ;                           interpolare.
    ;       PtOut(0 to NPC - 1):   Vettore dei punti, calcolati,
    ;                           della curva interpolante.
    ;       VZ:                 Valore di tensione della curva
    ;                           (1 <= VZ <= 100): valori grandi
    ;                           di VZ appiattiscono la curva.
    ;
    Protected.i nPIn, nPOut, I, J
    Protected.d H, z, z2i, szh, t, u0, t1, du1, du0
    Dim s.TPoint2D(1)

    nPIn = ArraySize(PtIn()) ; N. di punti da interpolare - 1.
    nPOut = ArraySize(PtOut()) ; N. di punti sulla curva - 1.
    z = (VZ)

    _Find_TCof(PtIn(), nPIn + 1, s(), z)

    ; The curve starts always with  PtIn(0) => t = 0
    PtOut(0)\X = PtIn(0)\X
    PtOut(0)\Y = PtIn(0)\Y
    ;PtOut(0)\Z = PtIn(0)\Z ; for 3D Spline

    H = 1.0 / (nPIn)
    szh = SinH(z * H)
    z2i = 1.0 / z / z
    For I = 1 To nPOut-1
      t = (I) / (nPOut)
      J = Int(t * (nPIn)) + 1
      If (J > (nPIn))
        J = nPIn
      EndIf

      u0 = (J-1) / nPIn
      t1 = J / nPIn
      du1 = t1 - t
      du0 = t - u0

      PtOut(I)\X = s(J)\X * z2i * SinH(z * du1) / szh + (PtIn(J-1)\X - s(J)\X * z2i) * du1 / H
      PtOut(I)\X = PtOut(I)\X + s(J + 1)\X * z2i * SinH(z * du0) / szh + (PtIn(J)\X - s(J + 1)\X * z2i) * du0 / H

      PtOut(I)\Y = s(J)\Y * z2i * SinH(z * du1) / szh + (PtIn(J-1)\Y - s(J)\Y * z2i) * du1 / H
      PtOut(I)\Y = PtOut(I)\Y + s(J + 1)\Y * z2i * SinH(z * du0) / szh + (PtIn(J)\Y - s(J + 1)\Y * z2i) * du0 / H

      ;PtOut(I)\Z = s(J)\Z * z2i * SinH(z * du1) / szh + (PtIn(J-1)\Z - s(J)\Z * z2i) * du1 / H
      ;PtOut(I)\Z = PtOut(I)\Z + s(J+1)\Z * z2i * SinH(z * du0) / szh + (PtIn(J)\Z - s(J+1)\Z * z2i) * du0 / H
    Next I

    ; Last Point on curve = PtIn(nPin) => t = 1
    PtOut(nPOut) = PtIn(nPIn)
  EndProcedure

EndModule
; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 36
; FirstLine = 51
; Folding = ------
; Optimizer
; CPU = 5