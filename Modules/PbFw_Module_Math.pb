; ===========================================================================
;  FILE : Module_Math.pb
;  NAME : Module Math
;  DESC : Mathematic Functions Library
;  DESC : 
; ===========================================================================
;
; AUTHOR   : Stefan Maag
; DATE     : 2022/10/30
; VERSION  : 0.1 Brainstorming version
; COMPILER : PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;   2023/09/02 S.Maag : added Conrec contouring algorithm 
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
  
  ; in x64: hand made Modulo is ~13% in fastern than PB's (Number % div) tested on Ryzen 5800
  ; in x32: for Quads PureBasic Modulo is faster
;   CompilerIf #PB_Compiler_64Bit
;     Macro _mac_Modulo(Number, div)
;       (Number-(Number/div)*div)
;     EndMacro
;   CompilerElse
;     Macro _mac_Modulo(Number, div)
;       Number % div
;     EndMacro
;   CompilerEndIf
    
  Declare.d BinomialCoefficient(N.i, K.i)
  Declare.i GreatestCommonDivisor(A.i, B.i)
  
  Declare Conrec(Array z.d(2), Array x.d(1), Array y.d(1), nc, Array contour.d(1), ilb, iub, jlb, jub, Array color.l(1))

EndDeclareModule


Module Math
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
    
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------  
     
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
  
  
  ; Invertiert einen Wertebereich (Messrichtungsumkehr), vertauscht sozusagen Ober- und Untergrenze.
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
  ; RET.d : Binomial Coefficient 
  ; ======================================================================
     
    Protected.i I, M
    Protected.d ret = 1.0
   
    If N>K
      If K>=1     
        If K > N/2    ; Use symmetry
          M=N-K
        Else
          M=K
        EndIf     
        For I = 1 To M
          ret = ret * ((N-M+I)/I)  
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
      B = C % B
    Wend
    ProcedureReturn A
  EndProcedure

  Procedure BresenhamLine(x1 ,y1 ,x2 ,y2, Color.l=0)
   ;  Bersenham Algorithmus to draw a Line of Pixeles
    Protected xSteep, error
    Protected x, y, dx, dy, xstep, ystep
    
    If Abs(y2 - y1) > Abs(x2 - x1);
      xSteep = #True 
      Swap x1, y1
      Swap x2, y2
    EndIf    
    
    If x1 > x2 
       Swap x1, x2
       Swap y1, y2
    EndIf 
    
    dx = x2 - x1
    dy = Abs(y2 - y1)
    error = dx / 2
    
    y = y1 
    If y1 < y2  
      ystep = 1
    Else
      ystep = -1 
    EndIf 
    
    For x = x1 To x2
      If xSteep 
        Plot(y,x, Color)
      Else 
        Plot(x,y, Color)
      EndIf
      
      error - dy      
      If error < 0 
        y + ystep
        error + dx
      EndIf
    Next        
  EndProcedure
  
  Procedure Conrec(Array z.d(2), Array x.d(1), Array y.d(1), nc, Array contour.d(1), ilb, iub, jlb, jub, Array color.l(1))

    ;taken from: http://astronomy.swin.edu.au/~pbourke/projection/conrec/conrec_vb.txt
    ; ported to PureBasic by Stefan Maag 09/2023
    
    ; original Documentation: https://paulbourke.net/papers/conrec/
    
    ; DE: Conrec zeichnet Höhenlinien, Isobare ... je nach Ausgangsdaten
    
    ;=============================================================================
    ;     CONREC is a contouring subroutine for rectangularily spaced data.
    ;
    ;     It emits calls to a line drawing subroutine supplied by the user
    ;     which draws a contour map corresponding to real*4 (double) data
    ;     on a randomly spaced rectangular grid.
    ;     The coordinates emitted are in the same units given in the X() and Y() arrays.
    ;     Any number of contour levels may be specified but they must be
    ;     in order of increasing value.
    ;
    ;     adapted from the fortran-77 routine CONREC.F developed by Paul D. Bourke
    ;=============================================================================
    
    ; Z(#,#)          ; matrix of Data To contour
    ; ilb,iub,jlb,jub ; index bounds of Data matrix (x-lower,x-upper,y-lower,y-upper)
    ; X(#)            ; Data matrix column coordinates
    ; Y(#)            ; Data matrix row coordinates
    ; nc              ; number of contour levels
    ; contour(#)      ; contour levels in increasing order
                         
    ; Dim m1, m2, m3, case_value As Integer
    Protected.i m1, m2, m3, case_value
    
    ;Dim dmin, dmax As Double
    ;Dim x1, x2, y1, y2 As Double
    Protected.d x1, x2, y1, y2, dmin, dmax
    
    ;Dim i, j, k, m As Integer
    Protected.i i, j, k, m
    
    ; Dim h(5) As Double
    ; Dim sh(5) As Integer
    ; Dim xh(5), yh(5) As Double
    
    Dim  h.d(5)
    Dim xh.d(5)
    Dim yh.d(5)
    Dim sh.i(5)
    
    Protected Nullcode.d = 1E+37
    
    Dim im.i(4)
    Dim jm.i(4)
    
    im(0) = 0
    im(1) = 1
    im(2) = 1
    im(3) = 0
    jm(0) = 0
    jm(1) = 0
    jm(2) = 1
    jm(3) = 1
    
    Dim castab.i(3, 3, 3)
    castab(0, 0, 0) = 0
    castab(0, 0, 1) = 0
    castab(0, 0, 2) = 8 
    castab(0, 1, 0) = 0
    castab(0, 1, 1) = 2
    castab(0, 1, 2) = 5 
    castab(0, 2, 0) = 7
    castab(0, 2, 1) = 6
    castab(0, 2, 2) = 9 
    castab(1, 0, 0) = 0
    castab(1, 0, 1) = 3
    castab(1, 0, 2) = 4 
    castab(1, 1, 0) = 1
    castab(1, 1, 1) = 3
    castab(1, 1, 2) = 1 
    castab(1, 2, 0) = 4
    castab(1, 2, 1) = 3
    castab(1, 2, 2) = 0 
    castab(2, 0, 0) = 9
    castab(2, 0, 1) = 6
    castab(2, 0, 2) = 7 
    castab(2, 1, 0) = 5
    castab(2, 1, 1) = 2
    castab(2, 1, 2) = 0 
    castab(2, 2, 0) = 8
    castab(2, 2, 1) = 0
    castab(2, 2, 2) = 0 
    
    If nc <> 0 
      For j = jub - 1 To jlb Step -1
        For i = ilb To iub - 1
          Protected.d temp1, temp2
          
          ; temp1 = Min(z(i, j), z(i, j + 1))
          If z(i, j) < z(i, j+1)
            temp1 = z(i, j)
          Else
            temp1 = z(i, j+1)
          EndIf
            
          ; temp2 = Min(z(i + 1, j), z(i + 1, j + 1))
          If z(i+1, j) < z(i+1, j+1)
            temp2 =  z(i+1, j)
          Else
            temp2 = z(i+1, j+1)
          EndIf
          
          ;dmin = Min(temp1, temp2)
          If temp1 < temp2
            dmin = temp1
          Else
            dmin = temp2
          EndIf
          
          
          ;temp1 = Max(z(i, j), z(i, j + 1))
          If z(i, j) > z(i, j+1)
            temp1 = z(i, j)
          Else
            temp1 = z(i, j+1)
          EndIf
         
          ;temp2 = Max(z(i + 1, j), z(i + 1, j + 1))
          If z(i+1, j) > z(i+1, j+1)
            temp2 =  z(i+1, j)
          Else
            temp2 = z(i+1, j+1)
          EndIf
          
          ;dmax = Max(temp1, temp2)
          If temp1 > temp2
            dmax = temp1
          Else
            dmax = temp2
          EndIf
          
          ; -------------------------------------------------------------------------
          ; extra condition added here to insure that large values are not plotted
          ; if an area should not be contoured, values above nullcode should be entered in
          ; the matrix Z
          
          ; ------------------------------------------------------------------------
          If dmax >= contour(0) And dmin <= contour(nc - 1) And dmax < Nullcode
            For k = 0 To nc - 1
              If contour(k) >= dmin And contour(k) < dmax 
                For m = 4 To 0 Step -1
                  
                  If m >0
                    h(m) = z(i + im(m - 1), j + jm(m - 1)) - contour(k)
                    xh(m) = x(i + im(m - 1))
                    yh(m) = y(j + jm(m - 1))
                  Else
                    h(0) = 0.25 * (h(1) + h(2) + h(3) + h(4))
                    xh(0) = 0.5 * (x(i) + x(i + 1))
                    yh(0) = 0.5 * (y(j) + y(j + 1))
                  EndIf
                  
                  If (h(m) > 0) 
                    sh(m) = 1
                  ElseIf h(m) < 0
                    sh(m) = -1
                  Else
                    sh(m) = 0
                  EndIf
                Next m
               
                ;=================================================================
                ;
                ; Note: at this stage the relative heights of the corners and the
                ; centre are in the h array, and the corresponding coordinates are
                ; in the xh and yh arrays. The centre of the box is indexed by 0
                ; and the 4 corners by 1 to 4 as shown below.
                ; Each triangle is then indexed by the parameter m, and the 3
                ; vertices of each triangle are indexed by parameters m1,m2,and m3.
                ; It is assumed that the centre of the box is always vertex 2
                ; though this isimportant only when all 3 vertices lie exactly on
                ; the same contour level, in which case only the side of the box
                ; is drawn.
                ;
                ;
                ;      vertex 4 +-------------------+ vertex 3
                ;               | \               / |
                ;               |   \    m-3    /   |
                ;               |     \       /     |
                ;               |       \   /       |
                ;               |  m=2    X   m=2   |       the centre is vertex 0
                ;               |       /   \       |
                ;               |     /       \     |
                ;               |   /    m=1    \   |
                ;               | /               \ |
                ;      vertex 1 +-------------------+ vertex 2
                ;
                ;
                ;
                ;               Scan each triangle in the box
                ;              
                ;=================================================================
                
                For m = 1 To 4
                  m1 = m
                  m2 = 0
                  If (m <> 4) 
                    m3 = m + 1
                  Else
                    m3 = 1
                  EndIf
                  
                  case_value = castab(sh(m1) + 1, sh(m2) + 1, sh(m3) + 1)
                  
                  If case_value <> 0 
                    
                    Select case_value
                            
                      Case 1
                        ; Line between vertices 1 and 2
                        x1 = xh(m1)
                        y1 = yh(m1)
                        x2 = xh(m2)
                        y2 = yh(m2)
                         
                      Case 2
                        ; Line between vertices 2 and 3
                        x1 = xh(m2)
                        y1 = yh(m2)
                        x2 = xh(m3)
                        y2 = yh(m3)
                        
                      Case 3
                        ;Line between vertices 3 and 1 
                        x1 = xh(m3)
                        y1 = yh(m3)
                        x2 = xh(m1)
                        y2 = yh(m1)
                         
                      Case 4
                        ; Line between vertex 1 and side 2-3
                        x1 = xh(m1)
                        y1 = yh(m1)
                        x2 = (h(m3) * xh(m2) - h(m2) * xh(m3)) / (h(m3) - h(m2))
                        y2 = (h(m3) * yh(m2) - h(m2) * yh(m3)) / (h(m3) - h(m2))
                           
                      Case 5
                        ; Line between vertex 2 and side 3-1  
                        x1 = xh(m2)
                        y1 = yh(m2)
                        x2 = (h(m1) * xh(m3) - h(m3) * xh(m1)) / (h(m1) - h(m3))
                        y2 = (h(m1) * yh(m3) - h(m3) * yh(m1)) / (h(m1) - h(m3))
                         
                      Case 6
                        ; Line between vertex 3 and side 1-2 
                        x1 = xh(m3)
                        y1 = yh(m3)
                        x2 = (h(m2) * xh(m1) - h(m1) * xh(m2)) / (h(m2) - h(m1))
                        y2 = (h(m2) * yh(m1) - h(m1) * yh(m2)) / (h(m2) - h(m1))
                         
                      Case 7
                        ; Line between sides 1-2 and 2-3  
                        x1 = (h(m2) * xh(m1) - h(m1) * xh(m2)) / (h(m2) - h(m1))
                        y1 = (h(m2) * yh(m1) - h(m1) * yh(m2)) / (h(m2) - h(m1))
                        x2 = (h(m3) * xh(m2) - h(m2) * xh(m3)) / (h(m3) - h(m2))
                        y2 = (h(m3) * yh(m2) - h(m2) * yh(m3)) / (h(m3) - h(m2))
                           
                      Case 8
                        ; Line between sides 2-3 and 3-1 
                        x1 = (h(m3) * xh(m2) - h(m2) * xh(m3)) / (h(m3) - h(m2))
                        y1 = (h(m3) * yh(m2) - h(m2) * yh(m3)) / (h(m3) - h(m2))
                        x2 = (h(m1) * xh(m3) - h(m3) * xh(m1)) / (h(m1) - h(m3))
                        y2 = (h(m1) * yh(m3) - h(m3) * yh(m1)) / (h(m1) - h(m3))
                         
                      Case 9
                        ; Line between sides 3-1 and 1-2
                        x1 = (h(m1) * xh(m3) - h(m3) * xh(m1)) / (h(m1) - h(m3))
                        y1 = (h(m1) * yh(m3) - h(m3) * yh(m1)) / (h(m1) - h(m3))
                        x2 = (h(m2) * xh(m1) - h(m1) * xh(m2)) / (h(m2) - h(m1))
                        y2 = (h(m2) * yh(m1) - h(m1) * yh(m2)) / (h(m2) - h(m1))
                        
                    EndSelect
                    
                    ; --------------------------------------------------------------
                    ; this is where the program specific drawing routine comes in.
                    ; This specific command will work well for a properly dimensioned
                    ; vb picture box or vb form (where "Form1" is the name of the form)                     
                    ; -------------------------------------------------------------------
                    ; TODO! For PureBasic we need Startdrawing() and a OutPutChannel
                    ; maybe change to a CallBack Procedure for drawing 
                    LineXY(x1, y1, x2, y2, color(k))
                       
                    ; -------------------------------------------------------------------
                  EndIf
                Next m
              EndIf
            Next k
          EndIf
         Next i      
       Next j
    EndIf
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
  
     
  

CompilerEndIf
; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 63
; FirstLine = 48
; Folding = --
; Markers = 481
; Optimizer
; CPU = 5