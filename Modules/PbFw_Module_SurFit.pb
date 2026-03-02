; ===========================================================================
;  FILE: PbFw_Module_SurFit.pb
;  NAME: Geostatistical Surface Fitting [SurFit::]
;  DESC: A consolidated Module for surface fitting and interpolation algorithms

;  DESC: This Module allows realistic spatial modeling instead of
;       random ore generation and adds strategic depth to mining
;       simulation games.
; 
; ===========================================================================
;
; AUTHOR     : Stefan Maag
; NOTES      : Converted with the help of Gemini Code Assist from VB6 to Purebasic
;              orginal Authors, see section USE CASES 

; DATE     :  2026/03/01
; VERSION  :  0.50  untested developer version  
; COMPILER :  PB 6.0 and higher
; OS       :  all
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
;             The original VB6 code from 2001 from F. Languasco is 
;             under a free licence without specify a comon licence model
;             (do what you want on your own response)
; ===========================================================================
; ChangeLog:
;{
; 2026/03/01 : S.Maag : created a new Module SurFit what contains all the 
;                       algorithms in a single Module. The name is token from
;                       F. Languasco's demo program in VB6 what is called Surfit
;}
;{ TODO: 
;   - until now it's converted Syntax Error free but the correct function
;     is not tested yet! 2026/03/01

;   - Changing the Point coordinate variables from X,Y,Z to a 3D/4D Point
;     Structure to use this Module in combination with the Vector Modules
;     VECf/VECd
;}

; ============================================================================

; USE CASES
;{
; Gradient2D : Finite difference gradient calculation.
;              http://www.flanguasco.org
;   - Input: interpolated grid
;   - Output: slope and direction of change
;   - Use in games:
;   - Guide AI or player toward high-value zones
;   - Flow simulation For rivers, wind, or currents
;   - Visual slope And shading effects
;   - Strategic pathfinding in voxel or terrain worlds

; QSHEP2 : Shepard Interpolation
;        ACM Collected Algorithms No. 660, https://calgo.acm.org/
;  - Input scattered Data points
;  - Output: smooth interpolated surface
;  - Use in games:
;  - Fast terrain or height Map previews
;  - Procedural environment textures
;  - Smooth water or wave surfaces
;  - Artistic generative surfaces

; KTB2D : 2D Kriging / GSLIB Kriging for gridding.
;         Geostatistics library: www.gslib.com
;  - Input drill/sample points or sparse 3D points
;  - Output: interpolated grid values
;  - Use in games:
;    - Realistic ore body simulation
;    - Procedural terrain generation
;    - Voxel world creation For mining games
; - Scientific visualization of temperature, pressure, or density fields
  
; 
; CONREC : A 2D contouring algorithm by Paul Bourke 1987
;          https://paulbourke.net/papers/conrec/
;   - Input: 2D or 3D grid values
;   - Output: iso-value lines or surfaces
;   - Use in games:
;   - Geological or topographic Map overlays
;   - Cut-off grade visualization
;   - 3D isosurface generation For ores or terrain layers
;   - Artistic contour-based visual effects

; Terrain Generation / Landscape Modeling
; - Use scattered height points To create realistic terrain meshes.
; - Kriging can generate smooth hills, valleys, And plateaus from sparse Data.
; - CONREC can produce contour lines For maps or artistic overlays.
; - Gradient2D can help calculate slope And flow direction, useful For rivers or erosion simulation.
; 
; Procedural Environment Textures
; - Generate 2D or 3D procedural textures based on a spatial property.
; - Example: Assign moisture, vegetation, or heat levels across a landscape.
; - QSHEP2 can quickly interpolate scattered “seed points” For visual variety.
; 
; Ocean / Water Surface Simulation
; - Model wave heights or currents over a grid using kriging or Shepard interpolation.
; - Generate smooth water surfaces For 3D scenes.
; - Gradient fields can help simulate flow direction For particles or boats.
; 
; Scientific Visualization
; - For geoscience, meteorology, or medical imaging, you can interpolate 3D fields.
;   Examples:
;     - Temperature or pressure fields in weather simulations.
; 	- Pollution or density maps.
;     - MRI / CT scan surface visualization in 3D
; 	
; Procedural Voxel Worlds / 3D Mining Games
; - Extend your 2D kriging Module To 3D grids (x, y, z) → voxel blocks.
; - Each block has a value (ore, material, or density).
; - Use gradients For AI pathfinding, mining optimization, or flow simulation.
; - CONREC -> 3D isosurfaces (like marching cubes) For visualizing ore bodies or terrain layers
; 
; Artistic / Generative Graphics
; - Use kriging To interpolate colors, heights, or patterns For digital art.
; - Contours can create abstract Map-like visuals.
; - Gradient fields can be used For particle systems, wind fields, or cloth simulation.
; 
; Key Advantage of Your Module in 3D Graphics
; - Smoothly interpolates sparse input points into full grids.
; - Generates both visual surfaces (color maps) And structural Data (gradients, contours, voxel values).
; - Works in real-time or offline For simulation, visualization, or gameplay mechanics.

;}

; Notes on conversion from VB6 to Purebasic
;{ 
; Generally all the origianl code of the algorithms is written in Fortran77
; But I converted the VisualBasic 6 Version from F. Languasco to Purebasic
; The reason is very simple. F. Languasco did all the hard conversion work
; from Fortran to a modern Basic language. VB6 to Purebasic is much easier
; than Fortran to Purebasic, what I did some times For ohter functions.
;
; I used Google GEMINI V2.5 for converting Visual Basic to Purebasic.
; With the right setup, GEMENI delivers very good Purebasic code with less 
; syntax errors -> not error free. 
; I tried first the WEB interface of ChatGPT and GEMINI, but that's not a
; good solution. 
;
; The game changer was Visual Studio Code with the GEMENI Plugin or
; the Github Copilot. That's an amazing experience. It was just a weekend work
; to test AI coding.

; I did the conversion of the CONREC contouring algorithm a longer time ago and
; fully by hand.
; I needed more time for that than for this entire module with AI help!
;}

DeclareModule SurFit
  
  EnableExplicit
  
  ; -----------------------------------
  ; Structures from modGradiente
  ; -----------------------------------
  Structure Grad_Type ; Components
    DX.d ; horizontal
    DY.d ; and vertical
  EndStructure ; of the gradient.
  
  ; -----------------------------------
  ; Structures from modKTB2D
  ; -----------------------------------
  Structure ParType
    tmin.d          ; Trimming limits.
    tmax.d          ;     "       "
    nxdis.i         ; Number of discretization points/block in X.
    nydis.i         ; Number of discretization points/block in Y.
    ndmin.i         ; Minimum number of data required for kriging.
    ndmax.i         ; Maximum number of samples to use in kriging.
    radius.d        ; Maximum search radius closest ndmax samples will be retained.
    ktype.i         ; Indicator for simple kriging (0=No, 1=Yes).
    skmean.d        ; Mean for simple kriging (used if ktype=1).
    c0.d            ; Nugget constant (isotropic).
    Nst.i           ; Number of nested structures (max. 4).
    It.i[5]         ; Type of each nested structure (1-based index).
    cc.d[5]         ; Multiplicative factor of each nested structure (1-based index).
    ang.d[5]        ; Azimuth angle for the principal direction (1-based index).
    AA.d[5]         ; Parameter "a" of each nested structure (1-based index).
    a2.d[5]         ; Anisotropy factor (1-based index).
  EndStructure
  

  ;- -----------------------------------
  ;- Public Declare
  ;- -----------------------------------
  
  ; From modGradiente
  Declare Gradient2D(Array XI.d(1), Array YI.d(1), Array ZI.d(2), NXI.i, NYI.i, Array Grad.Grad_Type(2))
  
  ; From org. VB6 Module modKTB2D.bas
  Declare KTB2D(ND.i, Array XD.d(1), Array YD.d(1), Array ZD.d(1), *Par.ParType, NX.i, XMN.d, xsiz.d, NY.i, YMN.d, ysiz.d, Array Z.d(2), *IER.Integer)
 
  ; From org. VB6 Module modQSHEP2D.bas
  Declare QSHEP2(N.i, Array X.d(1), Array Y.d(1), Array F.d(1), NQ.i, NW.i, NR.i, Array LCELL.i(2), Array LNEXT.i(1), *XMin.Double, *YMin.Double, *DX.Double, *DY.Double, *RMAX.Double, Array RSQ.d(1), Array A.d(2), *IER.Integer)
  Declare STORE2(N.i, Array X.d(1), Array Y.d(1), NR.i, Array LCELL.i(2), Array LNEXT.i(1), *XMin.Double, *YMin.Double, *DX.Double, *DY.Double, *IER.Integer)
  Declare.d QS2VAL(PX.d, PY.d, N.i, Array X.d(1), Array Y.d(1), Array F.d(1), NR.i, Array LCELL.i(2), Array LNEXT.i(1), XMin.d, YMin.d, DX.d, DY.d, RMAX.d, Array RSQ.d(1), Array A.d(2))
  Declare QS2GRD(PX.d, PY.d, N.i, Array X.d(1), Array Y.d(1), Array F.d(1), NR.i, Array LCELL.i(2), Array LNEXT.i(1), XMin.d, YMin.d, DX.d, DY.d, RMAX.d, Array RSQ.d(1), Array A.d(2), *Q.Double, *QX.Double, *QY.Double, *IER.Integer)
  
  ; 
  Declare Conrec(Array z.d(2), Array x.d(1), Array y.d(1), nc, Array contour.d(1), ilb, iub, jlb, jub, Array color.l(1))

EndDeclareModule

Module SurFit
  
  EnableExplicit
  
  ; Constants
  #MAXDAT = 10000
  #MAXSAM = 120
  #MAXDIS = 64
  #MAXNST = 4
  #MAXKD = #MAXSAM + 1
  #MAXKRG = #MAXKD * #MAXKD
  #UNEST = -999.0
  #EPSLON = 0.0000001
  #DTOR = 3.14159265358979 / 180.0


  ; Helper structures for array pointers
  Structure DoubleArray
    v.d[0]
  EndStructure

  Structure IntegerArray
    v.i[0]
  EndStructure

  ; Global Static variables for COVA2
  Global Dim COVA2_rotmat.d(5, 5) ; 1-based 1..4, 1..4
  Global COVA2_maxcov.d

  ; Helper for DMAX1
  Procedure.d _MaxD(a.d, b.d)
    If a > b
      ProcedureReturn a
    Else
      ProcedureReturn b
    EndIf
  EndProcedure
  
  ; Helper for Min of 5 doubles (DMIN1 replacement)
  Procedure.d _MinOf5d(v1.d, v2.d, v3.d, v4.d, v5.d)
    Protected r.d = v1
    If v2 < r : r = v2 : EndIf
    If v3 < r : r = v3 : EndIf
    If v4 < r : r = v4 : EndIf
    If v5 < r : r = v5 : EndIf
    ProcedureReturn r
  EndProcedure

  Procedure Gradient2D(Array XI.d(1), Array YI.d(1), Array ZI.d(2), NXI.i, NYI.i, Array Grad.Grad_Type(2))
  ; original Author: F. Languasco, 2001 for VisualBasic 6
  ; http://www.flanguasco.org
  ;
  ; Calculates the gradient of a surface using the finite difference method.
  ; Input parameters:
  ;   XI(1 To NXI):              vector of the surface's abscissas.
  ;   YI(1 To NYI):              vector of the surface's ordinates.
  ;   ZI(1 To NXI, 1 To NYI):    matrix of the surface's values.
  ;   NXI:                       Number of columns in the ZI() grid (NXI >= 3).
  ;   NYI:                       Number of rows in the ZI() grid (NYI >= 3).
  ; Output parameters:
  ;   Grad(1 To NXI, 1 To NYI):  matrix of the horizontal
  ;                              and vertical components of the gradient.
  ;
  ; Note: use this routine ONLY for ZI() grids with equispaced
  ;       XI() abscissas and YI() ordinates.
  ;
    Define I.i, J.i, dDenx1.d, dDeny1.d, dDenx2.d, dDeny2.d
  
    ; Calculate differences on rows and columns:
    dDenx1 = XI(2) - XI(1)
    dDenx2 = XI(3) - XI(1)
    dDeny1 = YI(2) - YI(1)
    dDeny2 = YI(3) - YI(1)
  
    ; Calculate the gradient of the central part:
    For J = 2 To NYI - 1
      For I = 2 To NXI - 1
        Grad(I, J)\DX = (ZI(I + 1, J) - ZI(I - 1, J)) / dDenx2
        Grad(I, J)\DY = (ZI(I, J + 1) - ZI(I, J - 1)) / dDeny2
      Next I
    Next J
  
    ; Calculate the gradient of the top and bottom rows:
    For I = 2 To NXI - 1
      Grad(I, 1)\DX = (ZI(I + 1, 1) - ZI(I - 1, 1)) / dDenx2
      Grad(I, 1)\DY = (ZI(I, 2) - ZI(I, 1)) / dDeny1
  
      Grad(I, NYI)\DX = (ZI(I + 1, NYI) - ZI(I - 1, NYI)) / dDenx2
      Grad(I, NYI)\DY = (ZI(I, NYI) - ZI(I, NYI - 1)) / dDeny1
    Next I
  
    ; Calculate the gradient of the left and right columns:
    For J = 2 To NYI - 1
      Grad(1, J)\DX = (ZI(2, J) - ZI(1, J)) / dDenx1
      Grad(1, J)\DY = (ZI(1, J + 1) - ZI(1, J - 1)) / dDeny2
  
      Grad(NXI, J)\DX = (ZI(NXI, J) - ZI(NXI - 1, J)) / dDenx1
      Grad(NXI, J)\DY = (ZI(NXI, J + 1) - ZI(NXI, J - 1)) / dDeny2
    Next J
  
    ; Calculate the gradient at the four corners:
    Grad(1, 1)\DX = (ZI(2, 1) - ZI(1, 1)) / dDenx1 ; Bottom-left
    Grad(1, 1)\DY = (ZI(1, 2) - ZI(1, 1)) / dDeny1 ; corner.
  
    Grad(NXI, 1)\DX = (ZI(NXI, 1) - ZI(NXI - 1, 1)) / dDenx1 ; Bottom-right
    Grad(NXI, 1)\DY = (ZI(NXI, 2) - ZI(NXI, 1)) / dDeny1 ; corner.
  
    Grad(NXI, NYI)\DX = (ZI(NXI, NYI) - ZI(NXI - 1, NYI)) / dDenx1 ; Top-right
    Grad(NXI, NYI)\DY = (ZI(NXI, NYI) - ZI(NXI, NYI - 1)) / dDeny1 ; corner.
  
    Grad(1, NYI)\DX = (ZI(2, NYI) - ZI(1, NYI)) / dDenx1 ; Top-left
    Grad(1, NYI)\DY = (ZI(1, NYI) - ZI(1, NYI - 1)) / dDeny1 ; corner.
  
  EndProcedure

  ;- -----------------------------------
  ;- KTB2D: GSLIB Kriging for gridding
  ;- -----------------------------------
  
  ; private
  Procedure _KSOL(Nright.i, NEQ.i, Nsb.i, Array A.d(1), Array R.d(1), Array S.d(1), *Ising.Integer)
    ; -----------------------------------------------------------------------
    ;
    ;                Solution of a System of Linear Equations
    ;                ****************************************
    ;
    ;
    ;
    ;   INPUT VARIABLES:
    ;
    ;    nright,nsb     number of columns in right hand side matrix.
    ;                   for KB2D: nright=1, nsb=1
    ;    neq            number of equations
    ;    a()            upper triangular left hand side matrix (stored
    ;                   columnwise)
    ;    r()            right hand side matrix (stored columnwise)
    ;                   for kb2d, one column per variable
    ;
    ;
    ;
    ;   OUTPUT VARIABLES:
    ;
    ;    s()            solution array, same dimension as r above.
    ;    ising          singularity indicator
    ;                     0,  no singularity problem
    ;                    -1,  neq .le. 1
    ;                     k,  a null pivot appeared at the kth iteration
    ;
    ;
    ;
    ;   PROGRAM NOTES:
    ;
    ;    1. Requires the upper triangular left hand side matrix.
    ;    2. Pivots are on the diagonal.
    ;    3. Does not search for max. element for pivot.
    ;    4. Several right hand side matrices possible.
    ;    5. USE for ok and sk only, NOT for UK.
    ;
    ;
    ; -----------------------------------------------------------------------
    ;
    Protected I.i, II.i, IJ.i, IJm.i, IN1.i, IV.i, J.i, K.i, KK.i, LL.i, LLb.i, LL1.i, Lp.i
    Protected KM1.i, M1.i, Nm.i, NM1.i, Nn.i
    Protected Ak.d, Ap.d, Piv.d, Tol.d

    ; If there is only one equation then set ising and return:
    If NEQ <= 1
      *Ising\i = -1
      ProcedureReturn
    EndIf

    ; Initialize:
    Tol = 0.0000001
    *Ising\i = 0
    Nn = NEQ * (NEQ + 1) / 2
    Nm = Nsb * NEQ
    M1 = NEQ - 1
    KK = 0

    ; Start triangulation:
    For K = 1 To M1
      KK = KK + K
      Ak = A(KK)
      If Abs(Ak) < Tol
        *Ising\i = K
        ProcedureReturn
      EndIf
      KM1 = K - 1
      For IV = 1 To Nright
        NM1 = Nm * (IV - 1)
        II = KK + Nn * (IV - 1)
        Piv = 1.0 / A(II)
        Lp = 0
        For I = K To M1
          LL = II
          II = II + I
          Ap = A(II) * Piv
          Lp = Lp + 1
          IJ = II - KM1
          For J = I To M1
            IJ = IJ + J
            LL = LL + J
            A(IJ) = A(IJ) - Ap * A(LL)
          Next J
          LLb = K
          While LLb <= Nm
            IN1 = LLb + Lp + NM1
            LL1 = LLb + NM1
            R(IN1) = R(IN1) - Ap * R(LL1)
            LLb = LLb + NEQ
          Wend
        Next I
      Next IV
    Next K

    ; Error checking - singular matrix:
    IJm = IJ - Nn * (Nright - 1)
    If Abs(A(IJm)) < Tol
      *Ising\i = NEQ
      ProcedureReturn
    EndIf

    ; Finished triangulation, start solving back:
    For IV = 1 To Nright
      NM1 = Nm * (IV - 1)
      IJ = IJm + Nn * (IV - 1)
      Piv = 1.0 / A(IJ)
      LLb = NEQ
      While LLb <= Nm
        LL1 = LLb + NM1
        S(LL1) = R(LL1) * Piv
        LLb = LLb + NEQ
      Wend
      I = NEQ
      KK = IJ
      For II = 1 To M1
        KK = KK - I
        Piv = 1.0 / A(KK)
        I = I - 1
        LLb = I
        While LLb <= Nm
          LL1 = LLb + NM1
          IN1 = LL1
          Ap = R(IN1)
          IJ = KK
          For J = I To M1
            IJ = IJ + J
            IN1 = IN1 + 1
            Ap = Ap - A(IJ) * S(IN1)
          Next J
          S(LL1) = Ap * Piv
          LLb = LLb + NEQ
        Wend
      Next II
    Next IV

    ; Finished solving back, return:
  EndProcedure

  ; private
  Procedure.d _COVA2(x1.d, y1.d, x2.d, y2.d, Nst.i, c0.d, PMX.d, *cc.DoubleArray, *AA.DoubleArray, *It.IntegerArray, *ang.DoubleArray, *anis.DoubleArray, First.i)
    ; -----------------------------------------------------------------------
    ;
    ;              Covariance Between Two Points (2-D Version)
    ;              *******************************************
    ;
    ;   This function returns the covariance associated with a variogram model
    ;   that is specified by a nugget effect and possibly four different
    ;   nested varigoram structures.  The anisotropy definition can be
    ;   different for each of the nested structures (spherical, exponential,
    ;   gaussian, or power).
    ;
    ;   INPUT VARIABLES:
    ;
    ;    x1,y1              Coordinates of first point
    ;    x2,y2              Coordinates of second point
    ;    nst                Number of nested structures (max. 4).
    ;    c0                 Nugget constant (isotropic).
    ;    PMX                Maximum variogram value needed for kriging when
    ;                       using power model.  A unique value of PMX is
    ;                       used for all nested structures which use the
    ;                       power model.  therefore, PMX should be chosen
    ;                       large enough to account for the largest single
    ;                       structure which uses the power model.
    ;    cc(nst)            Multiplicative factor of each nested structure.
    ;    aa(nst)            Parameter "a" of each nested structure.
    ;    it(nst)            Type of each nested structure:
    ;                        1. spherical model of range a;
    ;                        2. exponential model of parameter a;
    ;                           i.e. practical range is 3a
    ;                        3. gaussian model of parameter a;
    ;                           i.e. practical range is a*sqrt(3)
    ;                        4. power model of power a (a must be gt. 0  and
    ;                           lt. 2).  if linear model, a=1,c=slope.
    ;    ang(nst)           Azimuth angle for the principal direction of
    ;                       continuity (measured clockwise in degrees from Y)
    ;    anis(nst)          Anisotropy (radius in minor direction at 90 degrees
    ;                       from "ang" divided by the principal radius in
    ;                       direction "ang")
    ;    first              A logical variable which is set to true if the
    ;                       direction specifications have changed - causes
    ;                       the rotation matrices to be recomputed.
    ;
    ;
    ;
    ;   OUTPUT VARIABLES:   returns "COVA2" the covariance obtained from the
    ;                       variogram model.
    ;
    ;
    ;
    ; -----------------------------------------------------------------------
    ;
    Protected azmuth.d, DX.d, DY.d, Dx1.d, Dy1.d, H.d, hh.d, hr.d, cov1.d, COVA2T.d
    Protected IS1.i

    ; The first time around, re-initialize the cosine matrix for the
    ; variogram structures:
    If First
      COVA2_maxcov = c0
      For IS1 = 1 To Nst
        azmuth = (90.0 - *ang\v[IS1]) * #DTOR
        COVA2_rotmat(1, IS1) = Cos(azmuth)
        COVA2_rotmat(2, IS1) = Sin(azmuth)
        COVA2_rotmat(3, IS1) = -Sin(azmuth)
        COVA2_rotmat(4, IS1) = Cos(azmuth)
        If *It\v[IS1] = 4
          COVA2_maxcov = COVA2_maxcov + PMX
        Else
          COVA2_maxcov = COVA2_maxcov + *cc\v[IS1]
        EndIf
      Next IS1
    EndIf

    ; Check for very small distance:
    DX = x2 - x1
    DY = y2 - y1
    If (DX * DX + DY * DY) < #EPSLON
      ProcedureReturn COVA2_maxcov
    EndIf

    ; Non-zero distance, loop over all the structures:
    COVA2T = 0.0
    For IS1 = 1 To Nst
      ; Compute the appropriate structural distance:
      Dx1 = (DX * COVA2_rotmat(1, IS1) + DY * COVA2_rotmat(2, IS1))
      Dy1 = (DX * COVA2_rotmat(3, IS1) + DY * COVA2_rotmat(4, IS1)) / *anis\v[IS1]
      H = Sqr(_MaxD((Dx1 * Dx1 + Dy1 * Dy1), 0.0))

      If *It\v[IS1] = 1
        ; Spherical model:
        hr = H / *AA\v[IS1]
        If hr < 1.0
          COVA2T = COVA2T + *cc\v[IS1] * (1.0 - hr * (1.5 - 0.5 * hr * hr))
        EndIf
      ElseIf *It\v[IS1] = 2
        ; Exponential model:
        COVA2T = COVA2T + *cc\v[IS1] * Exp(-H / *AA\v[IS1])
      ElseIf *It\v[IS1] = 3
        ; Gaussian model:
        hh = -(H * H) / (*AA\v[IS1] * *AA\v[IS1])
        COVA2T = COVA2T + *cc\v[IS1] * Exp(hh)
      Else
        ; Power model:
        cov1 = PMX - *cc\v[IS1] * Pow(H, *AA\v[IS1])
        COVA2T = COVA2T + cov1
      EndIf
    Next IS1

    ProcedureReturn COVA2T
  EndProcedure
  
  Procedure KTB2D(ND.i, Array XD.d(1), Array YD.d(1), Array ZD.d(1), *Par.ParType, NX.i, XMN.d, xsiz.d, NY.i, YMN.d, ysiz.d, Array Z.d(2), *IER.Integer)
    ; KTB2D is part of Geostatistics library: www.gslib.com
    
    ;   Input parameters:
    ;    ND:            Number of data points.
    ;    XD(1 To ND):   vector of the abscissas of the data points.
    ;    YD(1 To ND):   vector of the ordinates of the data points.
    ;    ZD(1 To ND):   vector of the surface values at the data points.
    ;    Par:           structure of control parameters.
    ;    NX:            Number of columns of the interpolated points grid.
    ;    XMN:           minimum abscissa of the interpolated points grid.
    ;    xsiz:          distance between the abscissas of the interpolated points grid.
    ;    NY:            Number of rows of the interpolated points grid.
    ;    YMN:           minimum ordinate of the interpolated points grid.
    ;    ysiz:          distance between the ordinates of the interpolated points grid.
    ;    IER:           if the IER parameter is passed with a value > 0 a
    ;                   "Debug.txt" file is generated with information on the
    ;                   functioning of the routine.
    ;
    ;   Output parameters:
    ;    Z(1 To NX, 1 To NY):   matrix of interpolated values.
    ;    IER:           error code returned by the routine
    ;                    0 = No errors.
    ;                    1 = Exceeded available memory for data.
    ;                    2 = ndmax is too big - modify PARAMETERS.
    ;                    3 = nst is too big - modify PARAMETERS.
    ;                    4 = INVALID power variogram.
    ;                    5 = Too many discretization points:
    ;                        Increase MAXDIS or lower n[xy]dis.
    ;
    ; -----------------------------------------------------------------------
    ;
    ;           Ordinary/Simple Kriging of a 2-D Rectangular Grid
    ;           *************************************************
    ;
    ;   This subroutine estimates point or block values of one variable by
    ;   ordinary kriging.  All of the samples are rescanned for each block
    ;   estimate; this makes the program simple but inefficient.  The data
    ;   should NOT contain any missing values.  Unestimated points are
    ;   returned as -1.0e21
    ;
    ;
    ;
    ;   Original:  A.G.Journel 1978
    ;   Revisions: B.E. Buxton                                     Apr. 1983
    ; -----------------------------------------------------------------------
    ;
    ;                       *******************
    ;
    ;   The following Parameters control static dimensioning within KTB2D:
    ;
    ;    MAXX      maximum nodes in X
    ;    MAXY      maximum nodes in Y
    ;    MAXDAT    maximum number of data points
    ;    MAXSAM    maximum number of data points to use in one kriging system
    ;    MAXDIS    maximum number of discretization points per block
    ;    MAXNST    maximum number of nested structures
    ;
    ;   User Adjustable:
    ;   (Defined as Constants at top of file)

    Protected Dim NUMS.i(#MAXSAM)
    Protected NDr.i, N1.i, Na.i, Ndb.i, NEQ.i, Nn.i, Nk.i, I.i, IA.i, Isam.i, II.i, ID.i, IN1.i, Ix.i, Iy.i
    Protected Ldbg.i, K.i, JK.i, J.i, J1.i, JJ.i, Idbg.i, Ising.i

    Protected Dim X.d(#MAXDAT), Dim Y.d(#MAXDAT), Dim VR.d(#MAXDAT)
    Protected Dim xdb.d(#MAXDIS), Dim ydb.d(#MAXDIS), Dim xa.d(#MAXSAM), Dim ya.d(#MAXSAM)
    Protected Dim vra.d(#MAXSAM), Dim DIST.d(#MAXSAM), PMX.d, Dim anis.d(#MAXNST)
    Protected Dim R.d(#MAXSAM + 1), Dim rr.d(#MAXSAM + 1), Dim S.d(#MAXSAM + 1), Dim A.d(#MAXKRG)
    Protected v.d, ss.d, xloc.d, yloc.d, xdis.d, ydis.d, cbb.d, cb1.d, rad2.d, cov.d, unbias.d
    Protected Ak.d, AV.d, vk.d, DX.d, DY.d, h2.d, est.d, estv.d, XX.d, YY.d, cb.d, sumw.d, vrt.d
    Protected First.i

    First = #True
    PMX = 9999.0

    ; Read Input Parameters:
    Idbg = *IER\i ; Debug flag
    If Idbg > 0
      ; Unit numbers:
      Ldbg = CreateFile(#PB_Any, "Debug.txt")
    EndIf

    If ND > #MAXDAT
      If Idbg > 0
        WriteStringN(Ldbg, " ERROR: Exceeded available memory for data")
        *IER\i = 1
        If IsFile(Ldbg) : CloseFile(Ldbg) : EndIf
        ProcedureReturn
      EndIf
    EndIf

    *IER\i = 0

    If *Par\ndmin < 0 : *Par\ndmin = 0 : EndIf
    If *Par\ndmax > #MAXSAM
      If Idbg > 0
        WriteStringN(Ldbg, "ndmax is too big - modify PARAMETERS")
        *IER\i = 2
        If IsFile(Ldbg) : CloseFile(Ldbg) : EndIf
        ProcedureReturn
      EndIf
    EndIf

    If *Par\Nst > #MAXNST
      If Idbg > 0
        WriteStringN(Ldbg, "nst is too big - modify PARAMETERS")
        *IER\i = 3
        If IsFile(Ldbg) : CloseFile(Ldbg) : EndIf
        ProcedureReturn
      EndIf
    EndIf

    If *Par\Nst < 0
      *Par\Nst = 1
      *Par\It[1] = 1
      *Par\cc[1] = 0.0
      *Par\ang[1] = 0.0
      *Par\AA[1] = 0.0
      anis(1) = 0.0
    Else
      For I = 1 To *Par\Nst
        anis(I) = *Par\a2[I] / *Par\AA[I]

        If *Par\It[I] = 4
          If *Par\AA[I] < 0.0 Or *Par\AA[I] > 2.0
            If Idbg > 0
              WriteStringN(Ldbg, "INVALID power variogram")
              *IER\i = 4
              If IsFile(Ldbg) : CloseFile(Ldbg) : EndIf
              ProcedureReturn
            EndIf
          EndIf
        EndIf
      Next I
    EndIf

    ; Read the data:
    AV = 0.0
    ss = 0.0

    NDr = 0
    For I = 1 To ND
      vrt = ZD(I)
      If vrt < *Par\tmin Or vrt > *Par\tmax : Goto Label7 : EndIf

      NDr = NDr + 1
      X(NDr) = XD(I)
      Y(NDr) = YD(I)
      VR(NDr) = vrt
      AV = AV + vrt
      ss = ss + vrt * vrt
      Label7:
      ; CONTINUE
    Next I

    ; Echo the input data if debugging flag >0:
    If Idbg > 0
      WriteStringN(Ldbg, "tmin,tmax " + StrD(*Par\tmin) + " " + StrD(*Par\tmax))
      WriteStringN(Ldbg, "xmn,ymn " + StrD(XMN) + " " + StrD(YMN))
      WriteStringN(Ldbg, "xsiz,ysiz " + StrD(xsiz) + " " + StrD(ysiz))
      WriteStringN(Ldbg, "nxdis,nydis " + Str(*Par\nxdis) + " " + Str(*Par\nydis))
      WriteStringN(Ldbg, "ndmin " + Str(*Par\ndmin))
      WriteStringN(Ldbg, "ndmax " + Str(*Par\ndmax))
      WriteStringN(Ldbg, "radius " + StrD(*Par\radius))
      WriteStringN(Ldbg, "ktype " + Str(*Par\ktype))
      WriteStringN(Ldbg, "skmean " + StrD(*Par\skmean))
      WriteStringN(Ldbg, "nst " + Str(*Par\Nst))
      WriteStringN(Ldbg, "c0 " + StrD(*Par\c0))
      For I = 1 To *Par\Nst
        WriteStringN(Ldbg, "it " + Str(I) + " " + Str(*Par\It[I]))
        WriteStringN(Ldbg, "cc " + Str(I) + " " + StrD(*Par\cc[I]))
        WriteStringN(Ldbg, "ang " + Str(I) + " " + StrD(*Par\ang[I]))
        WriteStringN(Ldbg, "aa " + Str(I) + " " + StrD(*Par\AA[I]))
        WriteStringN(Ldbg, "a2 " + Str(I) + " " + StrD(*Par\a2[I]))
      Next I
      WriteStringN(Ldbg, "NDr,nx,ny " + Str(NDr) + " " + Str(NX) + " " + Str(NY))

      For ID = 1 To NDr
        WriteStringN(Ldbg, Str(ID) + " " + StrD(X(ID)) + " " + StrD(Y(ID)) + " " + StrD(VR(ID)))
      Next ID

      ; Compute the averages and variances as an error check for the user:
      AV = AV / _MaxD(NDr, 1.0)
      ss = (ss / _MaxD(NDr, 1.0)) - AV * AV
      WriteStringN(Ldbg, "av,ss " + StrD(AV) + " " + StrD(ss))
    EndIf

    ; Set up the discretization points per block.  Figure out how many
    ; are needed, the spacing, and fill the xdb and ydb arrays with the
    ; offsets relative to the block center (this only gets done once):
    Ndb = *Par\nxdis * *Par\nydis
    If Ndb > #MAXDIS
      If Idbg > 0
        WriteStringN(Ldbg, "ERROR KB2D: Too many discretization points.")
        WriteStringN(Ldbg, "            Increase MAXDIS")
        WriteStringN(Ldbg, "            or lower n[xy]dis.")
      EndIf
      *IER\i = 5
      If IsFile(Ldbg) : CloseFile(Ldbg) : EndIf
      ProcedureReturn
    EndIf
    xdis = xsiz / _MaxD(*Par\nxdis, 1.0)
    ydis = ysiz / _MaxD(*Par\nydis, 1.0)
    xloc = -0.5 * (xsiz + xdis)
    I = 0
    For Ix = 1 To *Par\nxdis
      xloc = xloc + xdis
      yloc = -0.5 * (ysiz + ydis)
      For Iy = 1 To *Par\nydis
        yloc = yloc + ydis
        I = I + 1
        xdb(I) = xloc
        ydb(I) = yloc
      Next Iy
    Next Ix

    ; Initialize accumulators:
    cbb = 0.0
    rad2 = *Par\radius * *Par\radius

    ; Calculate Block Covariance. Check for point kriging.
    cov = _COVA2(xdb(1), ydb(1), xdb(1), ydb(1), *Par\Nst, *Par\c0, PMX, @*Par\cc[0], @*Par\AA[0], @*Par\It[0], @*Par\ang[0], @anis(0), First)

    ; Keep this value to use for the unbiasedness constraint:
    unbias = cov
    First = #False
    If Ndb <= 1
      cbb = cov
    Else
      For I = 1 To Ndb
        For J = 1 To Ndb
          cov = _COVA2(xdb(I), ydb(I), xdb(J), ydb(J), *Par\Nst, *Par\c0, PMX, @*Par\cc[0], @*Par\AA[0], @*Par\It[0], @*Par\ang[0], @anis(0), First)
          If I = J : cov = cov - *Par\c0 : EndIf
          cbb = cbb + cov
        Next J
      Next I
      cbb = cbb / (Ndb * Ndb)
    EndIf

    ; MAIN LOOP OVER ALL THE BLOCKS IN THE GRID:
    Nk = 0
    Ak = 0.0
    vk = 0.0
    For Iy = 1 To NY
      yloc = YMN + (Iy - 1) * ysiz
      For Ix = 1 To NX
        xloc = XMN + (Ix - 1) * xsiz

        ; Find the nearest samples within each octant: First initialize
        ; the counter arrays:
        Na = 0
        For Isam = 1 To *Par\ndmax
          DIST(Isam) = 1.0e + 20
          NUMS(Isam) = 0
        Next Isam

        ; Scan all the samples (this is inefficient and the user with lots of
        ; data should move to ktb3d):
        For ID = 1 To NDr
          DX = X(ID) - xloc
          DY = Y(ID) - yloc
          h2 = DX * DX + DY * DY
          If h2 > rad2 : Goto Label6 : EndIf

          ; Do not consider this sample if there are enough close ones:
          If Na = *Par\ndmax
            If h2 > DIST(Na) : Goto Label6 : EndIf
          EndIf

          ; Consider this sample (it will be added in the correct location):
          If Na < *Par\ndmax : Na = Na + 1 : EndIf
          NUMS(Na) = ID
          DIST(Na) = h2
          If Na = 1 : Goto Label6 : EndIf

          ; Sort samples found thus far in increasing order of distance:
          N1 = Na - 1
          For II = 1 To N1
            K = II
            If h2 < DIST(II)
              JK = 0
              For JJ = K To N1
                J = N1 - JK
                JK = JK + 1
                J1 = J + 1
                DIST(J1) = DIST(J)
                NUMS(J1) = NUMS(J)
              Next JJ
              DIST(K) = h2
              NUMS(K) = ID
              Goto Label6
            EndIf
          Next II
          Label6:
          ; CONTINUE
        Next ID

        ; Is there enough samples?
        If Na < *Par\ndmin
          If Idbg > 0 : WriteStringN(Ldbg, "Block " + Str(Ix) + " " + Str(Iy) + " not estimated") : EndIf
          est = #UNEST
          estv = #UNEST
          Goto Label1
        EndIf

        ; Put coordinates and values of neighborhood samples into xa,ya,vra:
        For IA = 1 To Na
          JJ = NUMS(IA)
          xa(IA) = X(JJ)
          ya(IA) = Y(JJ)
          vra(IA) = VR(JJ)
        Next IA

        ; Handle the situation of only one sample:
        If Na = 1
          cb1 = _COVA2(xa(1), ya(1), xa(1), ya(1), *Par\Nst, *Par\c0, PMX, @*Par\cc[0], @*Par\AA[0], @*Par\It[0], @*Par\ang[0], @anis(0), First)
          XX = xa(1) - xloc
          YY = ya(1) - yloc

          ; Establish Right Hand Side Covariance:
          If Ndb <= 1
            cb = _COVA2(XX, YY, xdb(1), ydb(1), *Par\Nst, *Par\c0, PMX, @*Par\cc[0], @*Par\AA[0], @*Par\It[0], @*Par\ang[0], @anis(0), First)
          Else
            cb = 0.0
            For I = 1 To Ndb
              cb = cb + _COVA2(XX, YY, xdb(I), ydb(I), *Par\Nst, *Par\c0, PMX, @*Par\cc[0], @*Par\AA[0], @*Par\It[0], @*Par\ang[0], @anis(0), First)
              DX = XX - xdb(I)
              DY = YY - ydb(I)
              If (DX * DX + DY * DY) < #EPSLON : cb = cb - *Par\c0 : EndIf
            Next I
            cb = cb / Ndb
          EndIf
          If *Par\ktype = 0
            S(1) = cb / cbb
            est = S(1) * vra(1) + (1.0 - S(1)) * *Par\skmean
            estv = cbb - S(1) * cb
          Else
            est = vra(1)
            estv = cbb - 2.0 * cb + cb1
          EndIf
        Else
          ; Solve the Kriging System with more than one sample:
          NEQ = Na + *Par\ktype
          Nn = (NEQ + 1) * NEQ / 2

          ; Set up kriging matrices:
          IN1 = 0
          For J = 1 To Na
            ; Establish Left Hand Side Covariance Matrix:
            For I = 1 To J
              IN1 = IN1 + 1
              A(IN1) = _COVA2(xa(I), ya(I), xa(J), ya(J), *Par\Nst, *Par\c0, PMX, @*Par\cc[0], @*Par\AA[0], @*Par\It[0], @*Par\ang[0], @anis(0), First)
            Next I
            XX = xa(J) - xloc
            YY = ya(J) - yloc

            ; Establish Right Hand Side Covariance:
            If Ndb <= 1
              cb = _COVA2(XX, YY, xdb(1), ydb(1), *Par\Nst, *Par\c0, PMX, @*Par\cc[0], @*Par\AA[0], @*Par\It[0], @*Par\ang[0], @anis(0), First)
            Else
              cb = 0.0
              For J1 = 1 To Ndb
                cb = cb + _COVA2(XX, YY, xdb(J1), ydb(J1), *Par\Nst, *Par\c0, PMX, @*Par\cc[0], @*Par\AA[0], @*Par\It[0], @*Par\ang[0], @anis(0), First)
                DX = XX - xdb(J1)
                DY = YY - ydb(J1)
                If (DX * DX + DY * DY) < #EPSLON : cb = cb - *Par\c0 : EndIf
              Next J1
              cb = cb / Ndb
            EndIf
            R(J) = cb
            rr(J) = R(J)
          Next J

          ; Set the unbiasedness constraint:
          If *Par\ktype = 1
            For I = 1 To Na
              IN1 = IN1 + 1
              A(IN1) = unbias
            Next I
            IN1 = IN1 + 1
            A(IN1) = 0.0
            R(NEQ) = unbias
            rr(NEQ) = R(NEQ)
          EndIf

          ; Solve the Kriging System:
          _KSOL(1, NEQ, 1, A(), R(), S(), @Ising)

          ; Write a warning if the matrix is singular:
          If Ising <> 0
            If Idbg > 0
              WriteStringN(Ldbg, "WARNING KB2D: singular matrix")
              WriteStringN(Ldbg, "              for block " + Str(Ix) + " " + Str(Iy))
            EndIf
            est = #UNEST
            estv = #UNEST
            Goto Label1
          EndIf

          ; Compute the estimate and the kriging variance:
          est = 0.0
          estv = cbb
          sumw = 0.0
          If *Par\ktype = 1 : estv = estv - S(Na + 1) : EndIf
          For I = 1 To Na
            sumw = sumw + S(I)
            est = est + S(I) * vra(I)
            estv = estv - (S(I) * rr(I))
          Next I
          If *Par\ktype = 0 : est = est + (1.0 - sumw) * *Par\skmean : EndIf
        EndIf

        ; Write the result to the output matrix:
        Label1:
        Z(Ix, Iy) = est

        If est > #UNEST
          Nk = Nk + 1
          Ak = Ak + est
          vk = vk + est * est
        EndIf

        ; END OF MAIN LOOP OVER ALL THE BLOCKS:
        Label4:
        ; CONTINUE
      Next Ix
    Next Iy

    ; Finished:
    Label100:
    ; CONTINUE
    If Idbg > 0 : CloseFile(Ldbg) : EndIf
  EndProcedure

 
  ;- -----------------------------------
  ;- QSHEP2D: ACM ALGORITHM 660
  ;- -----------------------------------
 
  ;   Setup Routine: QSHEP2
  ;   Interpolation Routines: QS2GRD and QS2VAL
  ;
  ;   Note:   All vectors and matrices in these routines
  ;           start from index 1.
  ;
  ;   Translated from FORTRAN program:
  ;    ALGORITHM 660, COLLECTED ALGORITHMS FROM ACM.
  ;    THIS WORK PUBLISHED IN TRANSACTIONS ON MATHEMATICAL SOFTWARE,
  ;    VOL. 14, NO. 2, P.149.
  ;
  
  ; private
  Procedure _GETNP2(PX.d, PY.d, Array X.d(1), Array Y.d(1), NR.i, Array LCELL.i(2), Array LNEXT.i(1), XMin.d, YMin.d, DX.d, DY.d, *NP.Integer, *DSQ.Double)
    ;
    ;***********************************************************
    ;
    ;                       ROBERT RENKA
    ;                   UNIV. OF NORTH TEXAS
    ;                         (817) 565-2767
    ;
    ;   GIVEN A SET OF N NODES AND THE DATA STRUCTURE DEFINED IN
    ;   SUBROUTINE STORE2, THIS SUBROUTINE USES THE CELL METHOD TO
    ;   FIND THE CLOSEST UNMARKED NODE NP TO A SPECIFIED POINT P.
    ;   NP IS THEN MARKED BY SETTING LNEXT(NP) TO -LNEXT(NP).  (A
    ;   NODE IS MARKED IF AND ONLY IF THE CORRESPONDING LNEXT ELE-
    ;   MENT IS NEGATIVE.  THE ABSOLUTE VALUES OF LNEXT ELEMENTS,
    ;   HOWEVER, MUST BE PRESERVED.)  THUS, THE CLOSEST M NODES TO
    ;   P MAY BE DETERMINED BY A SEQUENCE OF M CALLS TO THIS ROU-
    ;   TINE.  NOTE THAT IF THE NEAREST NEIGHBOR TO NODE K IS TO
    ;   BE DETERMINED (PX = X(K) AND PY = Y(K)), THEN K SHOULD BE
    ;   MARKED BEFORE THE CALL TO THIS ROUTINE.
    ;   THE SEARCH IS BEGUN IN THE CELL CONTAINING (OR CLOSEST
    ;   TO) P AND PROCEEDS OUTWARD IN RECTANGULAR LAYERS UNTIL ALL
    ;   CELLS WHICH CONTAIN POINTS WITHIN DISTANCE R OF P HAVE
    ;   BEEN SEARCHED, WHERE R IS THE DISTANCE FROM P TO THE FIRST
    ;   UNMARKED NODE ENCOUNTERED (INFINITE IF NO UNMARKED NODES
    ;   ARE PRESENT).
    ;
    ;   ON INPUT --
    ;
    ;   PX,PY = CARTESIAN COORDINATES OF THE POINT P WHOSE
    ;           NEAREST UNMARKED NEIGHBOR IS TO BE FOUND.
    ;
    ;   X,Y =   ARRAYS OF LENGTH N, FOR N .GE. 2, CONTAINING
    ;           THE CARTESIAN COORDINATES OF THE NODES.
    ;
    ;   NR =    NUMBER OF ROWS AND COLUMNS IN THE CELL GRID.
    ;           NR .GE. 1.
    ;
    ;   LCELL = NR BY NR ARRAY OF NODAL INDICES ASSOCIATED
    ;           WITH CELLS.
    ;
    ;   LNEXT = ARRAY OF LENGTH N CONTAINING NEXT-NODE INDI-
    ;           CES (OR THEIR NEGATIVES).
    ;
    ;   XMIN,YMIN,DX,DY = MINIMUM NODAL COORDINATES AND CELL
    ;           DIMENSIONS.  DX AND DY MUST BE
    ;           POSITIVE.
    ;
    ;   INPUT PARAMETERS OTHER THAN LNEXT ARE NOT ALTERED BY
    ;   THIS ROUTINE.  WITH THE EXCEPTION OF (PX,PY) AND THE SIGNS
    ;   OF LNEXT ELEMENTS, THESE PARAMETERS SHOULD BE UNALTERED
    ;   FROM THEIR VALUES ON OUTPUT FROM SUBROUTINE STORE2.
    ;
    ;   ON OUTPUT --
    ;
    ;   NP =    INDEX (FOR X AND Y) OF THE NEAREST UNMARKED
    ;           NODE TO P, OR 0 IF ALL NODES ARE MARKED OR NR
    ;           .LT. 1 OR DX .LE. 0 OR DY .LE. 0.  LNEXT(NP)
    ;           .LT. 0 IF NP .NE. 0.
    ;
    ;   DSQ =   SQUARED EUCLIDEAN DISTANCE BETWEEN P AND NODE
    ;           NP, OR 0 IF NP = 0.
    ;
    ;   MODULES REQUIRED BY GETNP2 -- NONE
    ;
    ;   INTRINSIC FUNCTIONS CALLED BY GETNP2 -- IABS, IFIX, SQRT
    ;
    ;***********************************************************
    ;
    ; THIS SUBROUTINE USES THE CELL METHOD TO FIND THE CLOSEST UNMARKED NODE NP TO A SPECIFIED POINT P.
    ;
    Protected I.i, I0.i, I1.i, I2.i, IMIN.i, IMax.i, J.i, J0.i, J1.i, J2.i, JMIN.i, JMAX.i
    Protected L.i, LMIN.i, LN.i
    Protected DELX.d, DELY.d, R.d, RSMIN.d, RSQ.d, XP.d, YP.d
    Protected First.i
  
    XP = PX
    YP = PY
  
    ; TEST FOR INVALID INPUT PARAMETERS.
    If NR < 1 Or DX <= 0.0 Or DY <= 0.0
      Goto Label9
    EndIf
  
    ; INITIALIZE PARAMETERS --
    ;
    ;   FIRST = TRUE IFF THE FIRST UNMARKED NODE HAS YET TO BE
    ;           ENCOUNTERED,
    ;   IMIN,IMAX,JMIN,JMAX = CELL INDICES DEFINING THE RANGE OF
    ;           THE SEARCH,
    ;   DELX,DELY = PX-XMIN AND PY-YMIN,
    ;   I0,J0 = CELL CONTAINING OR CLOSEST TO P,
    ;   I1,I2,J1,J2 = CELL INDICES OF THE LAYER WHOSE INTERSEC-
    ;           TION WITH THE RANGE DEFINED BY IMIN,...,
    ;           JMAX IS CURRENTLY BEING SEARCHED.
    First = #True
    IMIN = 1
    IMax = NR
    JMIN = 1
    JMAX = NR
    DELX = XP - XMin
    DELY = YP - YMin
    I0 = Int(DELX / DX) + 1
    If I0 < 1 : I0 = 1 : EndIf
    If I0 > NR : I0 = NR : EndIf
    J0 = Int(DELY / DY) + 1
    If J0 < 1 : J0 = 1 : EndIf
    If J0 > NR : J0 = NR : EndIf
    I1 = I0
    I2 = I0
    J1 = J0
    J2 = J0
  
    ; OUTER LOOP ON LAYERS, INNER LOOP ON LAYER CELLS, EXCLUDING
    ; THOSE OUTSIDE THE RANGE (IMIN,IMAX) X (JMIN,JMAX).
    ; OUTER LOOP ON LAYERS
    Label1:
    For J = J1 To J2
      If J > JMAX : Goto Label7 : EndIf
      If J < JMIN : Goto Label6 : EndIf
      For I = I1 To I2
        If I > IMax : Goto Label6 : EndIf
        If I < IMIN : Goto Label5 : EndIf
        If J <> J1 And J <> J2 And I <> I1 And I <> I2 : Goto Label5 : EndIf
  
        ; SEARCH CELL (I,J) FOR UNMARKED NODES L.
        L = LCELL(I, J)
        If L = 0 : Goto Label5 : EndIf
  
        ; LOOP ON NODES IN CELL (I,J).
        Label2:
        LN = LNEXT(L)
        If LN < 0 : Goto Label4 : EndIf
  
        ; NODE L IS NOT MARKED.
        RSQ = Pow(X(L) - XP, 2) + Pow(Y(L) - YP, 2)
        If Not First : Goto Label3 : EndIf
  
        ; NODE L IS THE FIRST UNMARKED NEIGHBOR OF P ENCOUNTERED.
        ; INITIALIZE LMIN TO THE CURRENT CANDIDATE FOR NP, AND
        ; RSMIN TO THE SQUARED DISTANCE FROM P TO LMIN.  IMIN,
        ; IMAX, JMIN, AND JMAX ARE UPDATED TO DEFINE THE SMAL-
        ; LEST RECTANGLE CONTAINING A CIRCLE OF RADIUS R =
        ; SQRT(RSMIN) CENTERED AT P, AND CONTAINED IN (1,NR) X
        ; (1,NR) (EXCEPT THAT, IF P IS OUTSIDE THE RECTANGLE
        ; DEFINED BY THE NODES, IT IS POSSIBLE THAT IMIN .GT.
        ; NR, IMAX .LT. 1, JMIN .GT. NR, OR JMAX .LT. 1).  FIRST
        ; IS RESET TO FALSE.
        ; NODE L IS THE FIRST UNMARKED NEIGHBOR OF P ENCOUNTERED.
        LMIN = L
        RSMIN = RSQ
        R = Sqr(RSMIN)
        IMIN = Int((DELX - R) / DX) + 1
        If IMIN < 1 : IMIN = 1 : EndIf
        IMax = Int((DELX + R) / DX) + 1
        If IMax > NR : IMax = NR : EndIf
        JMIN = Int((DELY - R) / DY) + 1
        If JMIN < 1 : JMIN = 1 : EndIf
        JMAX = Int((DELY + R) / DY) + 1
        If JMAX > NR : JMAX = NR : EndIf
        First = #False
        Goto Label4
  
        ; TEST FOR NODE L CLOSER THAN LMIN TO P.
        Label3:
        If RSQ >= RSMIN : Goto Label4 : EndIf
  
        ; UPDATE LMIN AND RSMIN.
        LMIN = L
        RSMIN = RSQ
  
        ; TEST FOR TERMINATION OF LOOP ON NODES IN CELL (I,J).
        Label4:
        If Abs(LN) = L : Goto Label5 : EndIf
        L = Abs(LN)
        Goto Label2
        Label5:
        ; CONTINUE
      Next I
      Label6:
      ; CONTINUE
    Next J
  
    ; TEST FOR TERMINATION OF LOOP ON CELL LAYERS.
    Label7:
    If I1 <= IMIN And I2 >= IMax And J1 <= JMIN And J2 >= JMAX
      Goto Label8
    EndIf
    I1 = I1 - 1
    I2 = I2 + 1
    J1 = J1 - 1
    J2 = J2 + 1
    Goto Label1
  
    ; UNLESS NO UNMARKED NODES WERE ENCOUNTERED, LMIN IS THE
    ; CLOSEST UNMARKED NODE TO P.
    ; UNLESS NO UNMARKED NODES WERE ENCOUNTERED, LMIN IS THE CLOSEST UNMARKED NODE TO P.
    Label8:
    If First : Goto Label9 : EndIf
    *NP\i = LMIN
    *DSQ\d = RSMIN
    LNEXT(LMIN) = -LNEXT(LMIN)
    ProcedureReturn
  
    ; ERROR -- NR, DX, OR DY IS INVALID OR ALL NODES ARE MARKED.
    ; ERROR
    Label9:
    *NP\i = 0
    *DSQ\d = 0.0
  EndProcedure
  
  ; private
  Procedure _SETUP2(XK.d, YK.d, FK.d, XI.d, YI.d, FI.d, S1.d, S2.d, R.d, Array Row.d(2), IRow.i, JRow.i)
    ;
    ;***********************************************************
    ;
    ;                       ROBERT RENKA
    ;                   UNIV. OF NORTH TEXAS
    ;                         (817) 565-2767
    ;
    ;   THIS ROUTINE SETS UP THE I-TH ROW OF AN AUGMENTED RE-
    ;   GRESSION MATRIX FOR A WEIGHTED LEAST-SQUARES FIT OF A
    ;   QUADRATIC FUNCTION Q(X,Y) TO A SET OF DATA VALUES F, WHERE
    ;   Q(XK,YK) = FK.  THE FIRST 3 COLUMNS (QUADRATIC TERMS) ARE
    ;   SCALED BY 1/S2 AND THE FOURTH AND FIFTH COLUMNS (LINEAR
    ;   TERMS) ARE SCALED BY 1/S1.  THE WEIGHT IS (R-D)/(R*D) IF
    ;   R .GT. D AND 0 IF R .LE. D, WHERE D IS THE DISTANCE
    ;   BETWEEN NODES I AND K.
    ;
    ;   ON INPUT --
    ;
    ;    XK,YK,FK = COORDINATES AND DATA VALUE AT NODE K --
    ;               INTERPOLATED BY Q.
    ;
    ;    XI,YI,FI = COORDINATES AND DATA VALUE AT NODE I.
    ;
    ;    S1,S2 =    RECIPROCALS OF THE SCALE FACTORS.
    ;
    ;    R =        RADIUS OF INFLUENCE ABOUT NODE K DEFINING THE
    ;               WEIGHT.
    ;
    ;    ROW =      ARRAY OF LENGTH 6.
    ;
    ;   INPUT PARAMETERS ARE NOT ALTERED BY THIS ROUTINE.
    ;
    ;   ON OUTPUT --
    ;
    ;    ROW =      VECTOR CONTAINING A ROW OF THE AUGMENTED
    ;               REGRESSION MATRIX.
    ;
    ;   MODULES REQUIRED BY SETUP2 -- NONE
    ;
    ;   INTRINSIC FUNCTION CALLED BY SETUP2 -- SQRT
    ;
    ;***********************************************************
    ;
    ; THIS ROUTINE SETS UP THE I-TH ROW OF AN AUGMENTED REGRESSION MATRIX
    ;
    Protected I.i, DX.d, DY.d, DXSQ.d, DYSQ.d, D.d, w.d, W1.d, W2.d
  
    ; LOCAL PARAMETERS -
    ;
    ; I =    DO-LOOP INDEX
    ; DX =   XI - XK
    ; DY =   YI - YK
    ; DXSQ = DX * DX
    ; DYSQ = DY * DY
    ; D =    DISTANCE BETWEEN NODES K AND I
    ; W =    WEIGHT ASSOCIATED WITH THE ROW
    ; W1 =   W / S1
    ; W2 =   W / S2
    DX = XI - XK
    DY = YI - YK
    DXSQ = DX * DX
    DYSQ = DY * DY
    D = Sqr(DXSQ + DYSQ)
    If D <= 0.0 Or D >= R
      Goto Label1
    EndIf
    w = (R - D) / R / D
    W1 = w / S1
    W2 = w / S2
    Row(1 + IRow, JRow) = DXSQ * W2
    Row(2 + IRow, JRow) = DX * DY * W2
    Row(3 + IRow, JRow) = DYSQ * W2
    Row(4 + IRow, JRow) = DX * W1
    Row(5 + IRow, JRow) = DY * W1
    Row(6 + IRow, JRow) = (FI - FK) * w
    ProcedureReturn
  
    ; NODES K AND I COINCIDE OR NODE I IS OUTSIDE OF THE RADIUS
    ; OF INFLUENCE.  SET ROW TO THE ZERO VECTOR.
    Label1:
    For I = 1 To 6
      Label2:
      Row(I + IRow, JRow) = 0.0
    Next I
  EndProcedure
  
  
  ; private
  Procedure _GIVENS(*A.Double, *B.Double, *C.Double, *S.Double)
    ;
    ;***********************************************************
    ;
    ;                       ROBERT RENKA
    ;                   UNIV. OF NORTH TEXAS
    ;                         (817) 565-2767
    ;
    ;   THIS ROUTINE CONSTRUCTS THE GIVENS PLANE ROTATION --
    ;        ( C  S)
    ;    G = (     ) WHERE C*C + S*S = 1 -- WHICH ZEROS THE SECOND
    ;        (-S  C)
    ;    ENTRY OF THE 2-VECTOR (A B)-TRANSPOSE.  A CALL TO GIVENS
    ;    IS NORMALLY FOLLOWED BY A CALL TO ROTATE WHICH APPLIES
    ;    THE TRANSFORMATION TO A 2 BY N MATRIX.  THIS ROUTINE WAS
    ;    TAKEN FROM LINPACK.
    ;
    ;   ON INPUT --
    ;
    ;    A,B =  COMPONENTS OF THE 2-VECTOR TO BE ROTATED.
    ;
    ;   ON OUTPUT --
    ;
    ;    A =    VALUE OVERWRITTEN BY R = +/-SQRT(A*A + B*B)
    ;
    ;    B =    VALUE OVERWRITTEN BY A VALUE Z WHICH ALLOWS C
    ;           AND S TO BE RECOVERED AS FOLLOWS --
    ;           C = SQRT(1-Z*Z), S=Z     IF ABS(Z) .LE. 1.
    ;           C = 1/Z, S = SQRT(1-C*C) IF ABS(Z) .GT. 1.
    ;
    ;    C =    +/-(A/R)
    ;
    ;    S =    +/-(B/R)
    ;
    ;   MODULES REQUIRED BY GIVENS -- NONE
    ;
    ;   INTRINSIC FUNCTIONS CALLED BY GIVENS - ABS, SQRT
    ;
    ;***********************************************************
    ;
    ; THIS ROUTINE CONSTRUCTS THE GIVENS PLANE ROTATION
    ;
    Protected AA.d, BB.d, R.d, u.d, v.d
  
    ; LOCAL PARAMETERS --
    ;
    ; AA,BB = LOCAL COPIES OF A AND B
    ; R =     C*A + S*B = +/-SQRT(A*A+B*B)
    ; U,V =   VARIABLES USED TO SCALE A AND B FOR COMPUTING R
    AA = *A\d
    BB = *B\d
    If Abs(AA) <= Abs(BB)
      Goto Label1
    EndIf
  
    ; ABS(A) .GT. ABS(B)
    u = AA + AA
    v = BB / u
    R = Sqr(0.25 + v * v) * u
    *C\d = AA / R
    *S\d = v * (*C\d + *C\d)
  
    ; NOTE THAT R HAS THE SIGN OF A, C .GT. 0, AND S HAS
    ; SIGN(A)*SIGN(B).
    *B\d = *S\d
    *A\d = R
    ProcedureReturn
  
    ; ABS(A) .LE. ABS(B)
    Label1:
    If BB = 0.0
      Goto Label2
    EndIf
    u = BB + BB
    v = AA / u
  
    ; STORE R IN A.
    *A\d = Sqr(0.25 + v * v) * u
    *S\d = BB / *A\d
    *C\d = v * (*S\d + *S\d)
  
    ; NOTE THAT R HAS THE SIGN OF B, S .GT. 0, AND C HAS
    ; SIGN(A)*SIGN(B).
    *B\d = 1.0
    If *C\d <> 0.0 : *B\d = 1.0 / *C\d : EndIf
    ProcedureReturn
  
    ; A = B = 0#
    Label2:
    *C\d = 1.0
    *S\d = 0.0
  EndProcedure
  
  ; private
  Procedure _ROTATE(N.i, C.d, S.d, Array X.d(2), Ix.i, Jx.i, Array Y.d(2), Iy.i, Jy.i)
    ;
    ;***********************************************************
    ;
    ;                       ROBERT RENKA
    ;                   UNIV. OF NORTH TEXAS
    ;                         (817) 565-2767
    ;
    ;                                            ( C  S)
    ;   THIS ROUTINE APPLIES THE GIVENS ROTATION (     ) TO THE
    ;                                            (-S  C)
    ;                 (X(1) ... X(N))
    ;   2 BY N MATRIX (             ).
    ;                 (Y(1) ... Y(N))
    ;
    ;   ON INPUT --
    ;
    ;    N =    NUMBER OF COLUMNS TO BE ROTATED.
    ;
    ;    C,S =  ELEMENTS OF THE GIVENS ROTATION.  THESE MAY BE
    ;           DETERMINED BY SUBROUTINE GIVENS.
    ;
    ;    X,Y =  ARRAYS OF LENGTH .GE. N CONTAINING THE VECTORS
    ;           TO BE ROTATED.
    ;
    ;   PARAMETERS N, C, AND S ARE NOT ALTERED BY THIS ROUTINE.
    ;
    ;   ON OUTPUT --
    ;
    ;    X,Y =  ROTATED VECTORS.
    ;
    ;   MODULES REQUIRED BY ROTATE -- NONE
    ;
    ;***********************************************************
    ;
    ; THIS ROUTINE APPLIES THE GIVENS ROTATION
    ;
    Protected I.i, XI.d, YI.d
  
    ; LOCAL PARAMETERS --
    ;
    ; I =     DO-LOOP INDEX
    ; XI, YI = X(I), Y(I)
    If N <= 0 Or (C = 1.0 And S = 0.0)
      ProcedureReturn
    EndIf
    For I = 1 To N
      XI = X(I + Ix, Jx)
      YI = Y(I + Iy, Jy)
      X(I + Ix, Jx) = C * XI + S * YI
      Y(I + Iy, Jy) = -S * XI + C * YI
      Label1:
    Next I
  EndProcedure
  
  Procedure QSHEP2(N.i, Array X.d(1), Array Y.d(1), Array F.d(1), NQ.i, NW.i, NR.i, Array LCELL.i(2), Array LNEXT.i(1), *XMin.Double, *YMin.Double, *DX.Double, *DY.Double, *RMAX.Double, Array RSQ.d(1), Array A.d(2), *IER.Integer)
    ;
    ;***********************************************************
    ;
    ;                       ROBERT RENKA
    ;                   UNIV. OF NORTH TEXAS
    ;                         (817) 565-2767
    ;   1 / 8 / 90
    ;
    ; THIS SUBROUTINE COMPUTES A SET OF PARAMETERS A AND RSQ
    ; DEFINING A SMOOTH (ONCE CONTINUOUSLY DIFFERENTIABLE) BI-
    ; VARIATE FUNCTION Q(X,Y) WHICH INTERPOLATES DATA VALUES F
    ; AT SCATTERED NODES (X,Y).  THE INTERPOLANT Q MAY BE EVAL-
    ; UATED AT AN ARBITRARY POINT BY FUNCTION QS2VAL, AND ITS
    ; FIRST DERIVATIVES ARE COMPUTED BY SUBROUTINE QS2GRD.
    ; THE INTERPOLATION SCHEME IS A MODIFIED QUADRATIC SHEPARD
    ; METHOD --
    ;
    ;  Q = (W(1)*Q(1)+W(2)*Q(2)+..+W(N)*Q(N))/(W(1)+W(2)+..+W(N))
    ;
    ; FOR BIVARIATE FUNCTIONS W(K) AND Q(K).  THE NODAL FUNC-
    ; TIONS ARE GIVEN BY
    ;
    ;  Q(K)(X,Y) = A(1,K)*(X-X(K))**2 + A(2,K)*(X-X(K))*(Y-Y(K))
    ;            + A(3,K)*(Y-Y(K))**2 + A(4,K)*(X-X(K))
    ;            + A(5,K)*(Y-Y(K))    + F(K) .
    ;
    ; THUS, Q(K) IS A QUADRATIC FUNCTION WHICH INTERPOLATES THE
    ; DATA VALUE AT NODE K.  ITS COEFFICIENTS A(,K) ARE OBTAINED
    ; BY A WEIGHTED LEAST SQUARES FIT TO THE CLOSEST NQ DATA
    ; POINTS WITH WEIGHTS SIMILAR TO W(K).  NOTE THAT THE RADIUS
    ; OF INFLUENCE FOR THE LEAST SQUARES FIT IS FIXED FOR EACH
    ; K, BUT VARIES WITH K.
    ; THE WEIGHTS ARE TAKEN TO BE
    ;
    ;  W(K)(X,Y) = ( (R(K)-D(K))+ / R(K)*D(K) )**2
    ;
    ; WHERE (R(K)-D(K))+ = 0 IF R(K) .LE. D(K) AND D(K)(X,Y) IS
    ; THE EUCLIDEAN DISTANCE BETWEEN (X,Y) AND (X(K),Y(K)).  THE
    ; RADIUS OF INFLUENCE R(K) VARIES WITH K AND IS CHOSEN SO
    ; THAT NW NODES ARE WITHIN THE RADIUS.  NOTE THAT W(K) IS
    ; NOT DEFINED AT NODE (X(K),Y(K)), BUT Q(X,Y) HAS LIMIT F(K)
    ; AS (X,Y) APPROACHES (X(K),Y(K)).
    ;
    ; ON INPUT --
    ;
    ;  N =     NUMBER OF NODES AND ASSOCIATED DATA VALUES.
    ;          N .GE. 6.
    ;
    ;  X,Y =   ARRAYS OF LENGTH N CONTAINING THE CARTESIAN
    ;          COORDINATES OF THE NODES.
    ;
    ;  F =     ARRAY OF LENGTH N CONTAINING THE DATA VALUES
    ;          IN ONE-TO-ONE CORRESPONDENCE WITH THE NODES.
    ;
    ;  NQ =    NUMBER OF DATA POINTS TO BE USED IN THE LEAST
    ;          SQUARES FIT FOR COEFFICIENTS DEFINING THE NODAL
    ;          FUNCTIONS Q(K).  A HIGHLY RECOMMENDED VALUE IS
    ;          NQ = 13.  5 .LE. NQ .LE. MIN(40,N-1).
    ;
    ;  NW =    NUMBER OF NODES WITHIN (AND DEFINING) THE RADII
    ;          OF INFLUENCE R(K) WHICH ENTER INTO THE WEIGHTS
    ;          W(K).  FOR N SUFFICIENTLY LARGE, A RECOMMENDED
    ;          VALUE IS NW = 19.  1 .LE. NW .LE. MIN(40,N-1).
    ;
    ;  NR =    NUMBER OF ROWS AND COLUMNS IN THE CELL GRID DE-
    ;          FINED IN SUBROUTINE STORE2.  A RECTANGLE CON-
    ;          TAINING THE NODES IS PARTITIONED INTO CELLS IN
    ;          ORDER TO INCREASE SEARCH EFFICIENCY.  NR =
    ;          SQRT(N/3) IS RECOMMENDED.  NR .GE. 1.
    ;
    ; THE ABOVE PARAMETERS ARE NOT ALTERED BY THIS ROUTINE.
    ;
    ;  LCELL = ARRAY OF LENGTH .GE. NR**2.
    ;
    ;  LNEXT = ARRAY OF LENGTH .GE. N.
    ;
    ;  RSQ =   ARRAY OF LENGTH .GE. N.
    ;
    ;  A =     ARRAY OF LENGTH .GE. 5N.
    ;
    ; ON OUTPUT --
    ;
    ;  LCELL = NR BY NR ARRAY OF NODAL INDICES ASSOCIATED
    ;          WITH CELLS.  REFER TO STORE2.
    ;
    ;  LNEXT = ARRAY OF LENGTH N CONTAINING NEXT-NODE INDI-
    ;          CES.  REFER TO STORE2.
    ;
    ;  XMIN,YMIN,DX,DY = MINIMUM NODAL COORDINATES AND CELL
    ;          DIMENSIONS.  REFER TO STORE2.
    ;
    ;  RMAX =  SQUARE ROOT OF THE LARGEST ELEMENT IN RSQ --
    ;          MAXIMUM RADIUS R(K).
    ;
    ;  RSQ =   ARRAY CONTAINING THE SQUARES OF THE RADII R(K)
    ;          WHICH ENTER INTO THE WEIGHTS W(K).
    ;
    ;  A =     5 BY N ARRAY CONTAINING THE COEFFICIENTS FOR
    ;          QUADRATIC NODAL FUNCTION Q(K) IN COLUMN K.
    ;
    ; NOTE THAT THE ABOVE OUTPUT PARAMETERS ARE NOT DEFINED
    ; UNLESS IER = 0.
    ;
    ;  IER =   ERROR INDICATOR --
    ;           IER = 0 IF NO ERRORS WERE ENCOUNTERED.
    ;           IER = 1 IF N, NQ, NW, OR NR IS OUT OF RANGE.
    ;           IER = 2 IF DUPLICATE NODES WERE ENCOUNTERED.
    ;           IER = 3 IF ALL NODES ARE COLLINEAR.
    ;
    ; MODULES REQUIRED BY QSHEP2 -- GETNP2, GIVENS, ROTATE,
    ; SETUP2, STORE2
    ;
    ; INTRINSIC FUNCTIONS CALLED BY QSHEP2 -- ABS, AMIN1, FLOAT,
    ; MAX0, MIN0, SQRT
    ;
    ;***********************************************************
    ;
    Protected I.i, IB.i, IERR.i, IP1.i, IRM1.i, IRow.i, J.i, JP1.i, K.i, LMAX.i
    Protected LNP.i, NEQ.i, Nn.i, NNQ.i, NNR.i, NNW.i, NP.i, NQWMAX.i
    Protected Dim NPTS.i(40)
    Protected AV.d, AVSQ.d, Dim B.d(6, 6), C.d, DDX.d, DDY.d, DMin.d, FK.d
    Protected RQ.d, RS.d, RSMX.d, RSOLD.d, RWS.d, S.d, sum.d, t.d
    Protected XK.d, XMN.d, YK.d, YMN.d
  
    Protected RTOL.d = 0.00001
    Protected DTOL.d = 0.01
    Protected SF.d = 1.0
  
    ; LOCAL PARAMETERS --
    ;
    ;  AV =         ROOT-MEAN-SQUARE DISTANCE BETWEEN K AND THE
    ;               NODES IN THE LEAST SQUARES SYSTEM (UNLESS
    ;               ADDITIONAL NODES ARE INTRODUCED FOR STABIL-
    ;               ITY).  THE FIRST 3 COLUMNS OF THE MATRIX
    ;               ARE SCALED BY 1/AVSQ, THE LAST 2 BY 1/AV
    ;  AVSQ =       AV * AV
    ;  B =          TRANSPOSE OF THE AUGMENTED REGRESSION MATRIX
    ;  C =          FIRST COMPONENT OF THE PLANE ROTATION USED TO
    ;               ZERO THE LOWER TRIANGLE OF B**T -- COMPUTED
    ;               BY SUBROUTINE GIVENS
    ;  DDX,DDY =    LOCAL VARIABLES FOR DX AND DY
    ;  DMIN =       MINIMUM OF THE MAGNITUDES OF THE DIAGONAL
    ;               ELEMENTS OF THE REGRESSION MATRIX AFTER
    ;               ZEROS ARE INTRODUCED BELOW THE DIAGONAL
    ;  DTOL =       TOLERANCE FOR DETECTING AN ILL-CONDITIONED
    ;               SYSTEM.  THE SYSTEM IS ACCEPTED WHEN DMIN
    ;               .GE.DTOL
    ;  FK =         DATA VALUE AT NODE K -- F(K)
    ;  I =          INDEX FOR A, B, AND NPTS
    ;  IB =         DO-LOOP INDEX FOR BACK SOLVE
    ;  IERR =       ERROR FLAG FOR THE CALL TO STORE2
    ;  IP1 =        I + 1
    ;  IRM1 =       IROW - 1
    ;  IROW =       ROW INDEX FOR B
    ;  J =          INDEX FOR A AND B
    ;  JP1 =        J + 1
    ;  K =          NODAL FUNCTION INDEX AND COLUMN INDEX FOR A
    ;  LMAX =       MAXIMUM NUMBER OF NPTS ELEMENTS (MUST BE CON-
    ;               SISTENT WITH THE DIMENSION STATEMENT ABOVE)
    ;  LNP =        CURRENT LENGTH OF NPTS
    ;  NEQ =        NUMBER OF EQUATIONS IN THE LEAST SQUARES FIT
    ;  NN,NNQ,NNR = LOCAL COPIES OF N, NQ, AND NR
    ;  NNW =        LOCAL COPY OF NW
    ;  NP =         NPTS ELEMENT
    ;  NPTS =       ARRAY CONTAINING THE INDICES OF A SEQUENCE OF
    ;               NODES TO BE USED IN THE LEAST SQUARES FIT
    ;               OR TO COMPUTE RSQ.  THE NODES ARE ORDERED
    ;               BY DISTANCE FROM K AND THE LAST ELEMENT
    ;               (USUALLY INDEXED BY LNP) IS USED ONLY TO
    ;               DETERMINE RQ, OR RSQ(K) IF NW .GT. NQ
    ;  NQWMAX =     Max(NQ, NW)
    ;  RQ =         RADIUS OF INFLUENCE WHICH ENTERS INTO THE
    ;               WEIGHTS FOR Q(K) (SEE SUBROUTINE SETUP2)
    ;  RS =         SQUARED DISTANCE BETWEEN K AND NPTS(LNP) --
    ;               USED TO COMPUTE RQ AND RSQ(K)
    ;  RSMX =       MAXIMUM RSQ ELEMENT ENCOUNTERED
    ;  RSOLD =      SQUARED DISTANCE BETWEEN K AND NPTS(LNP-1) --
    ;               USED TO COMPUTE A RELATIVE CHANGE IN RS
    ;               BETWEEN SUCCEEDING NPTS ELEMENTS
    ;  RTOL =       TOLERANCE FOR DETECTING A SUFFICIENTLY LARGE
    ;               RELATIVE CHANGE IN RS.  IF THE CHANGE IS
    ;               NOT GREATER THAN RTOL, THE NODES ARE
    ;               TREATED AS BEING THE SAME DISTANCE FROM K
    ;  RWS =        CURRENT VALUE OF RSQ(K)
    ;  S =          SECOND COMPONENT OF THE PLANE GIVENS ROTATION
    ;  SF =         MARQUARDT STABILIZATION FACTOR USED TO DAMP
    ;               OUT THE FIRST 3 SOLUTION COMPONENTS (SECOND
    ;               PARTIALS OF THE QUADRATIC) WHEN THE SYSTEM
    ;               IS ILL-CONDITIONED.  AS SF INCREASES, THE
    ;               FITTING FUNCTION APPROACHES A LINEAR
    ;  SUM =        SUM OF SQUARED EUCLIDEAN DISTANCES BETWEEN
    ;               NODE K AND THE NODES USED IN THE LEAST
    ;               SQUARES FIT (UNLESS ADDITIONAL NODES ARE
    ;               ADDED FOR STABILITY)
    ;  T =          TEMPORARY VARIABLE FOR ACCUMULATING A SCALAR
    ;               PRODUCT IN THE BACK SOLVE
    ;  XK,YK =      COORDINATES OF NODE K -- X(K), Y(K)
    ;  XMN,YMN =    LOCAL VARIABLES FOR XMIN AND YMIN
    ;
    Nn = N
    NNQ = NQ
    NNW = NW
    NNR = NR
    If NNQ > NNW : NQWMAX = NNQ : Else : NQWMAX = NNW : EndIf ; MAX0
    If 40 < Nn - 1 : LMAX = 40 : Else : LMAX = Nn - 1 : EndIf ; MIN0
  
    If (5 > NNQ Or 1 > NNW Or NQWMAX > LMAX Or NNR < 1)
      Goto Label20
    EndIf
  
    ; CREATE THE CELL DATA STRUCTURE, AND INITIALIZE RSMX.
    STORE2(Nn, X(), Y(), NNR, LCELL(), LNEXT(), @XMN, @YMN, @DDX, @DDY, @IERR)
    If IERR <> 0
      Goto Label22
    EndIf
    RSMX = 0.0
  
    ; OUTER LOOP ON NODE K
    For K = 1 To Nn
      XK = X(K)
      YK = Y(K)
      FK = F(K)
  
      ; MARK NODE K TO EXCLUDE IT FROM THE SEARCH FOR NEAREST NEIGHBORS.
      LNEXT(K) = -LNEXT(K)
  
      ; INITIALIZE FOR LOOP ON NPTS.
      RS = 0.0
      sum = 0.0
      RWS = 0.0
      RQ = 0.0
      LNP = 0
  
      ; COMPUTE NPTS, LNP, RWS, NEQ, RQ, AND AVSQ.
      Label1:
      sum = sum + RS
      If LNP = LMAX
        Goto Label3
      EndIf
      LNP = LNP + 1
      RSOLD = RS
      _GETNP2(XK, YK, X(), Y(), NNR, LCELL(), LNEXT(), XMN, YMN, DDX, DDY, @NP, @RS)
      If RS = 0.0
        Goto Label21
      EndIf
      NPTS(LNP) = NP
      If (RS - RSOLD) / RS < RTOL
        Goto Label1
      EndIf
      If RWS = 0.0 And LNP > NNW
        RWS = RS
      EndIf
      If RQ <> 0.0 Or LNP <= NNQ
        Goto Label2
      EndIf
  
      ; RQ = 0 (NOT YET COMPUTED) AND LNP .GT. NQ.  RQ =
      ; SQRT(RS) IS SUFFICIENTLY LARGE TO (STRICTLY) INCLUDE
      ; NQ NODES.  THE LEAST SQUARES FIT WILL INCLUDE NEQ =
      ; LNP - 1 EQUATIONS FOR 5 .LE. NQ .LE. NEQ .LT. LMAX
      ; .LE.N - 1#
      ; RQ = 0 (NOT YET COMPUTED) AND LNP .GT. NQ.
      NEQ = LNP - 1
      RQ = Sqr(RS)
      AVSQ = sum / NEQ
  
      ; BOTTOM OF LOOP -- TEST FOR TERMINATION.
      Label2:
      If LNP > NQWMAX
        Goto Label4
      EndIf
      Goto Label1
  
      ; ALL LMAX NODES ARE INCLUDED IN NPTS.  RWS AND/OR RQ**2 IS
      ; (ARBITRARILY) TAKEN TO BE 10 PERCENT LARGER THAN THE
      ; DISTANCE RS TO THE LAST NODE INCLUDED.
      ; ALL LMAX NODES ARE INCLUDED IN NPTS.
      Label3:
      If RWS = 0.0
        RWS = 1.1 * RS
      EndIf
      If RQ <> 0.0
        Goto Label4
      EndIf
      NEQ = LMAX
      RQ = Sqr(1.1 * RS)
      AVSQ = sum / NEQ
  
      ; STORE RSQ(K), UPDATE RSMX IF NECESSARY, AND COMPUTE AV.
      Label4:
      RSQ(K) = RWS
      If RWS > RSMX
        RSMX = RWS
      EndIf
      AV = Sqr(AVSQ)
  
      ; SET UP THE AUGMENTED REGRESSION MATRIX (TRANSPOSED) AS THE
      ; COLUMNS OF B, AND ZERO OUT THE LOWER TRIANGLE (UPPER
      ; TRIANGLE OF B) WITH GIVENS ROTATIONS -- QR DECOMPOSITION
      ; WITH ORTHOGONAL MATRIX Q NOT STORED.
      ; SET UP THE AUGMENTED REGRESSION MATRIX (TRANSPOSED)
      I = 0
      Label5:
      I = I + 1
      NP = NPTS(I)
      If I < 6 : IRow = I : Else : IRow = 6 : EndIf ; MIN0(I, 6)
      _SETUP2(XK, YK, FK, X(NP), Y(NP), F(NP), AV, AVSQ, RQ, B(), 0, IRow)
      If I = 1
        Goto Label5
      EndIf
      IRM1 = IRow - 1
      For J = 1 To IRM1
        JP1 = J + 1
        _GIVENS(@B(J, J), @B(J, IRow), @C, @S)
        _ROTATE(6 - J, C, S, B(), JP1 - 1, J, B(), JP1 - 1, IRow)
        Label6:
      Next J
      If I < NEQ
        Goto Label5
      EndIf
  
      ; TEST THE SYSTEM FOR ILL-CONDITIONING.
      DMin = _MinOf5d(Abs(B(1, 1)), Abs(B(2, 2)), Abs(B(3, 3)), Abs(B(4, 4)), Abs(B(5, 5)))
      If DMin * RQ >= DTOL
        Goto Label13
      EndIf
      If NEQ = LMAX
        Goto Label10
      EndIf
  
      ; INCREASE RQ AND ADD ANOTHER EQUATION TO THE SYSTEM TO
      ; IMPROVE THE CONDITIONING.  THE NUMBER OF NPTS ELEMENTS
      ; IS ALSO INCREASED IF NECESSARY.
      ; INCREASE RQ AND ADD ANOTHER EQUATION TO THE SYSTEM
      Label7:
      RSOLD = RS
      NEQ = NEQ + 1
      If NEQ = LMAX
        Goto Label9
      EndIf
      If NEQ = LNP
        Goto Label8
      EndIf
  
      ; NEQ .LT. LNP
      NP = NPTS(NEQ + 1)
      RS = Pow(X(NP) - XK, 2) + Pow(Y(NP) - YK, 2)
      If (RS - RSOLD) / RS < RTOL
        Goto Label7
      EndIf
      RQ = Sqr(RS)
      Goto Label5
  
      ; ADD AN ELEMENT TO NPTS.
      Label8:
      LNP = LNP + 1
      _GETNP2(XK, YK, X(), Y(), NNR, LCELL(), LNEXT(), XMN, YMN, DDX, DDY, @NP, @RS)
      If NP = 0
        Goto Label21
      EndIf
      NPTS(LNP) = NP
      If (RS - RSOLD) / RS < RTOL
        Goto Label7
      EndIf
      RQ = Sqr(RS)
      Goto Label5
  
      Label9:
      RQ = Sqr(1.1 * RS)
      Goto Label5
  
      ; STABILIZE THE SYSTEM BY DAMPING SECOND PARTIALS -- ADD
      ; MULTIPLES OF THE FIRST THREE UNIT VECTORS TO THE FIRST
      ; THREE EQUATIONS.
      ; STABILIZE THE SYSTEM BY DAMPING SECOND PARTIALS
      Label10:
      For I = 1 To 3
        B(I, 6) = SF
        IP1 = I + 1
        For J = IP1 To 6
          B(J, 6) = 0.0
          Label11:
        Next J
        For J = I To 5
          JP1 = J + 1
          _GIVENS(@B(J, J), @B(J, 6), @C, @S)
          Label12:
          _ROTATE(6 - J, C, S, B(), JP1 - 1, J, B(), JP1 - 1, 6)
        Next J
      Next I
  
      ; TEST THE STABILIZED SYSTEM FOR ILL-CONDITIONING.
      DMin = _MinOf5d(Abs(B(1, 1)), Abs(B(2, 2)), Abs(B(3, 3)), Abs(B(4, 4)), Abs(B(5, 5)))
      If DMin * RQ < DTOL
        Goto Label22
      EndIf
  
      ; SOLVE THE 5 BY 5 TRIANGULAR SYSTEM FOR THE COEFFICIENTS
      ; SOLVE THE 5 BY 5 TRIANGULAR SYSTEM
      Label13:
      For IB = 1 To 5
        I = 6 - IB
        t = 0.0
        If I = 5
          Goto Label15
        EndIf
        IP1 = I + 1
        For J = IP1 To 5
          Label14:
          t = t + B(J, I) * A(J, K)
        Next J
        Label15:
        A(I, K) = (B(6, I) - t) / B(I, I)
      Next IB
  
      ; SCALE THE COEFFICIENTS TO ADJUST FOR THE COLUMN SCALING.
      ; SCALE THE COEFFICIENTS
      For I = 1 To 3
        Label16:
        A(I, K) = A(I, K) / AVSQ
      Next I
      A(4, K) = A(4, K) / AV
      A(5, K) = A(5, K) / AV
  
      ; UNMARK K AND THE ELEMENTS OF NPTS.
      LNEXT(K) = -LNEXT(K)
      For I = 1 To LNP
        NP = NPTS(I)
        Label17:
        LNEXT(NP) = -LNEXT(NP)
      Next I
      Label18:
      ; CONTINUE
    Next K
  
    ; NO ERRORS ENCOUNTERED.
    *XMin\d = XMN
    *YMin\d = YMN
    *DX\d = DDX
    *DY\d = DDY
    *RMAX\d = Sqr(RSMX)
    *IER\i = 0
    ProcedureReturn
  
    ; N, NQ, NW, OR NR IS OUT OF RANGE.
    Label20:
    *IER\i = 1
    ProcedureReturn
  
    ; DUPLICATE NODES WERE ENCOUNTERED BY GETNP2.
    Label21:
    *IER\i = 2
    ProcedureReturn
  
    ; NO UNIQUE SOLUTION DUE TO COLLINEAR NODES.
    Label22:
    *XMin\d = XMN
    *YMin\d = YMN
    *DX\d = DDX
    *DY\d = DDY
    *IER\i = 3
  
  EndProcedure
    
  Procedure.d QS2VAL(PX.d, PY.d, N.i, Array X.d(1), Array Y.d(1), Array F.d(1), NR.i, Array LCELL.i(2), Array LNEXT.i(1), XMin.d, YMin.d, DX.d, DY.d, RMAX.d, Array RSQ.d(1), Array A.d(2))
    ;
    ;***********************************************************
    ;
    ;                       ROBERT RENKA
    ;                   UNIV. OF NORTH TEXAS
    ;                         (817) 565-2767
    ;   10 / 28 / 87
    ;
    ;   THIS FUNCTION RETURNS THE VALUE Q(PX,PY) WHERE Q IS THE
    ;   WEIGHTED SUM OF QUADRATIC NODAL FUNCTIONS DEFINED IN SUB-
    ;   ROUTINE QSHEP2.  QS2GRD MAY BE CALLED TO COMPUTE A GRADI-
    ;   ENT OF Q ALONG WITH THE VALUE, AND/OR TO TEST FOR ERRORS.
    ;
    ;   ON INPUT --
    ;
    ;    PX,PY = CARTESIAN COORDINATES OF THE POINT P AT
    ;            WHICH Q IS TO BE EVALUATED.
    ;
    ;    N =     NUMBER OF NODES AND DATA VALUES DEFINING Q.
    ;            N .GE. 6.
    ;
    ;    X,Y,F = ARRAYS OF LENGTH N CONTAINING THE NODES AND
    ;            DATA VALUES INTERPOLATED BY Q.
    ;
    ;    NR =    NUMBER OF ROWS AND COLUMNS IN THE CELL GRID.
    ;            REFER TO STORE2.  NR .GE. 1.
    ;
    ;    LCELL = NR BY NR ARRAY OF NODAL INDICES ASSOCIATED
    ;            WITH CELLS.  REFER TO STORE2.
    ;
    ;    LNEXT = ARRAY OF LENGTH N CONTAINING NEXT-NODE INDI-
    ;            CES.  REFER TO STORE2.
    ;
    ;    XMIN,YMIN,DX,DY = MINIMUM NODAL COORDINATES AND CELL
    ;            DIMENSIONS.  DX AND DY MUST BE
    ;            POSITIVE.  REFER TO STORE2.
    ;
    ;    RMAX =  SQUARE ROOT OF THE LARGEST ELEMENT IN RSQ --
    ;            MAXIMUM RADIUS.
    ;
    ;    RSQ =   ARRAY OF LENGTH N CONTAINING THE SQUARED RADII
    ;            WHICH ENTER INTO THE WEIGHTS DEFINING Q.
    ;
    ;    A =     5 BY N ARRAY CONTAINING THE COEFFICIENTS FOR THE
    ;            NODAL FUNCTIONS DEFINING Q.
    ;
    ;   INPUT PARAMETERS ARE NOT ALTERED BY THIS FUNCTION.  THE
    ;   PARAMETERS OTHER THAN PX AND PY SHOULD BE INPUT UNALTERED
    ;   FROM THEIR VALUES ON OUTPUT FROM QSHEP2.  THIS FUNCTION
    ;   SHOULD NOT BE CALLED IF A NONZERO ERROR FLAG WAS RETURNED
    ;   BY QSHEP2.
    ;
    ;   ON OUTPUT --
    ;
    ;    QS2VAL = FUNCTION VALUE Q(PX,PY) UNLESS N, NR, DX,
    ;             DY, OR RMAX IS INVALID, IN WHICH CASE NO
    ;             VALUE IS RETURNED.
    ;
    ;   MODULES REQUIRED BY QS2VAL -- NONE
    ;
    ;   INTRINSIC FUNCTIONS CALLED BY QS2VAL -- IFIX, SQRT
    ;
    ;***********************************************************
    ;
    ; THIS FUNCTION RETURNS THE VALUE Q(PX,PY)
    ;
    Protected I.i, IMIN.i, IMax.i, J.i, JMIN.i, JMAX.i, K.i, KP.i
    Protected DELX.d, DELY.d, DS.d, DXSQ.d, DYSQ.d, RD.d, RS.d, RDS.d, SW.d, SWQ.d, w.d, XP.d, YP.d
  
    XP = PX
    YP = PY
    If N < 6 Or NR < 1 Or DX <= 0.0 Or DY <= 0.0 Or RMAX < 0.0
      ProcedureReturn 0.0
    EndIf
  
    ; SET IMIN, IMAX, JMIN, AND JMAX TO CELL INDICES DEFINING
    ; THE RANGE OF THE SEARCH FOR NODES WHOSE RADII INCLUDE
    ; P.  THE CELLS WHICH MUST BE SEARCHED ARE THOSE INTER-
    ; SECTED BY (OR CONTAINED IN) A CIRCLE OF RADIUS RMAX
    ; CENTERED AT P.
    IMIN = Int((XP - XMin - RMAX) / DX) + 1
    IMax = Int((XP - XMin + RMAX) / DX) + 1
    If IMIN < 1 : IMIN = 1 : EndIf
    If IMax > NR : IMax = NR : EndIf
    JMIN = Int((YP - YMin - RMAX) / DY) + 1
    JMAX = Int((YP - YMin + RMAX) / DY) + 1
    If JMIN < 1 : JMIN = 1 : EndIf
    If JMAX > NR : JMAX = NR : EndIf
  
    ; THE FOLLOWING IS A TEST FOR NO CELLS WITHIN THE CIRCLE
    ; OF RADIUS RMAX.
    If IMIN > IMax Or JMIN > JMAX
      Goto Label5
    EndIf
  
    ; ACCUMULATE WEIGHT VALUES IN SW AND WEIGHTED NODAL FUNCTION
    ; VALUES IN SWQ.  THE WEIGHTS ARE W(K) = ((R-D)+/(R*D))**2
    ; FOR R**2 = RSQ(K) AND D = DISTANCE BETWEEN P AND NODE K.
    SW = 0.0
    SWQ = 0.0
  
    ; OUTER LOOP ON CELLS (I,J).
    For J = JMIN To JMAX
      For I = IMIN To IMax
        K = LCELL(I, J)
        If K = 0 : Goto Label3 : EndIf
  
        ; INNER LOOP ON NODES K.
        Label1:
        DELX = XP - X(K)
        DELY = YP - Y(K)
        DXSQ = DELX * DELX
        DYSQ = DELY * DELY
        DS = DXSQ + DYSQ
        RS = RSQ(K)
        If DS >= RS : Goto Label2 : EndIf
        If DS = 0.0 : Goto Label4 : EndIf
        RDS = RS * DS
        RD = Sqr(RDS)
        w = (RS + DS - RD - RD) / RDS
        SW = SW + w
        SWQ = SWQ + w * (A(1, K) * DXSQ + A(2, K) * DELX * DELY + A(3, K) * DYSQ + A(4, K) * DELX + A(5, K) * DELY + F(K))
  
        ; BOTTOM OF LOOP ON NODES IN CELL (I,J).
        Label2:
        KP = K
        K = LNEXT(KP)
        If K <> KP : Goto Label1 : EndIf
        Label3:
      Next I
    Next J
  
    ; SW = 0 IFF P IS NOT WITHIN THE RADIUS R(K) FOR ANY NODE K.
    If SW = 0.0 : Goto Label5 : EndIf
    ProcedureReturn SWQ / SW
  
    ; (PX,PY) = (X(K),Y(K))
    Label4:
    ProcedureReturn F(K)
  
    ; ALL WEIGHTS ARE 0 AT P.
    Label5:
    ProcedureReturn 0.0
  EndProcedure
  
  Procedure QS2GRD(PX.d, PY.d, N.i, Array X.d(1), Array Y.d(1), Array F.d(1), NR.i, Array LCELL.i(2), Array LNEXT.i(1), XMin.d, YMin.d, DX.d, DY.d, RMAX.d, Array RSQ.d(1), Array A.d(2), *Q.Double, *QX.Double, *QY.Double, *IER.Integer)
    ;
    ;***********************************************************
    ;
    ;                       ROBERT RENKA
    ;                   UNIV. OF NORTH TEXAS
    ;                         (817) 565-2767
    ;   10 / 28 / 87
    ;
    ;   THIS SUBROUTINE COMPUTES THE VALUE AND GRADIENT AT
    ;   (PX,PY) OF THE INTERPOLATORY FUNCTION Q DEFINED IN SUB-
    ;   ROUTINE QSHEP2.  Q(X,Y) IS A WEIGHTED SUM OF QUADRATIC
    ;   NODAL FUNCTIONS.
    ;
    ;   ON INPUT --
    ;
    ;    PX,PY = CARTESIAN COORDINATES OF THE POINT AT WHICH
    ;            Q AND ITS PARTIALS ARE TO BE EVALUATED.
    ;
    ;    N =     NUMBER OF NODES AND DATA VALUES DEFINING Q.
    ;            N .GE. 6.
    ;
    ;    X,Y,F = ARRAYS OF LENGTH N CONTAINING THE NODES AND
    ;            DATA VALUES INTERPOLATED BY Q.
    ;
    ;    NR =    NUMBER OF ROWS AND COLUMNS IN THE CELL GRID.
    ;            REFER TO STORE2.  NR .GE. 1.
    ;
    ;    LCELL = NR BY NR ARRAY OF NODAL INDICES ASSOCIATED
    ;            WITH CELLS.  REFER TO STORE2.
    ;
    ;    LNEXT = ARRAY OF LENGTH N CONTAINING NEXT-NODE INDI-
    ;            CES.  REFER TO STORE2.
    ;
    ;    XMIN,YMIN,DX,DY = MINIMUM NODAL COORDINATES AND CELL
    ;            DIMENSIONS.  DX AND DY MUST BE
    ;            POSITIVE.  REFER TO STORE2.
    ;
    ;    RMAX =  SQUARE ROOT OF THE LARGEST ELEMENT IN RSQ --
    ;            MAXIMUM RADIUS.
    ;
    ;    RSQ =   ARRAY OF LENGTH N CONTAINING THE SQUARED RADII
    ;            WHICH ENTER INTO THE WEIGHTS DEFINING Q.
    ;
    ;    A =     5 BY N ARRAY CONTAINING THE COEFFICIENTS FOR THE
    ;            NODAL FUNCTIONS DEFINING Q.
    ;
    ;   INPUT PARAMETERS ARE NOT ALTERED BY THIS SUBROUTINE.
    ;   THE PARAMETERS OTHER THAN PX AND PY SHOULD BE INPUT UNAL-
    ;   TERED FROM THEIR VALUES ON OUTPUT FROM QSHEP2.  THIS SUB-
    ;   ROUTINE SHOULD NOT BE CALLED IF A NONZERO ERROR FLAG WAS
    ;   RETURNED BY QSHEP2.
    ;
    ;   ON OUTPUT --
    ;
    ;    Q =     VALUE OF Q AT (PX,PY) UNLESS IER .EQ. 1, IN
    ;            WHICH CASE NO VALUES ARE RETURNED.
    ;
    ;    QX,QY = FIRST PARTIAL DERIVATIVES OF Q AT (PX,PY)
    ;            UNLESS IER .EQ. 1.
    ;
    ;    IER =   ERROR INDICATOR
    ;             IER = 0 IF NO ERRORS WERE ENCOUNTERED.
    ;             IER = 1 IF N, NR, DX, DY OR RMAX IS INVALID.
    ;             IER = 2 IF NO ERRORS WERE ENCOUNTERED BUT
    ;                     (PX,PY) IS NOT WITHIN THE RADIUS R(K)
    ;                     FOR ANY NODE K (AND THUS Q=QX=QY=0).
    ;
    ;   MODULES REQUIRED BY QS2GRD -- NONE
    ;
    ;   INTRINSIC FUNCTIONS CALLED BY QS2GRD -- IFIX, SQRT
    ;
    ;***********************************************************
    ;
    ; THIS SUBROUTINE COMPUTES THE VALUE AND GRADIENT AT (PX,PY)
    ;
    Protected I.i, IMIN.i, IMax.i, J.i, JMIN.i, JMAX.i, K.i, KP.i
    Protected DELX.d, DELY.d, DS.d, DXSQ.d, DYSQ.d, RD.d, QK.d, QKX.d, QKY.d, RS.d, RDS.d
    Protected SW.d, SWS.d, SWX.d, SWY.d, SWQ.d, SWQX.d, SWQY.d, t.d, w.d, WX.d, WY.d, XP.d, YP.d
  
    XP = PX
    YP = PY
    If N < 6 Or NR < 1 Or DX <= 0.0 Or DY <= 0.0 Or RMAX < 0.0
      Goto Label5
    EndIf
  
    ; SET IMIN, IMAX, JMIN, AND JMAX TO CELL INDICES DEFINING
    ; THE RANGE OF THE SEARCH FOR NODES WHOSE RADII INCLUDE
    ; P.  THE CELLS WHICH MUST BE SEARCHED ARE THOSE INTER-
    ; SECTED BY (OR CONTAINED IN) A CIRCLE OF RADIUS RMAX
    ; CENTERED AT P.
    IMIN = Int((XP - XMin - RMAX) / DX) + 1
    IMax = Int((XP - XMin + RMAX) / DX) + 1
    If IMIN < 1 : IMIN = 1 : EndIf
    If IMax > NR : IMax = NR : EndIf
    JMIN = Int((YP - YMin - RMAX) / DY) + 1
    JMAX = Int((YP - YMin + RMAX) / DY) + 1
    If JMIN < 1 : JMIN = 1 : EndIf
    If JMAX > NR : JMAX = NR : EndIf
  
    ; THE FOLLOWING IS A TEST FOR NO CELLS WITHIN THE CIRCLE
    ; OF RADIUS RMAX.
    If IMIN > IMax Or JMIN > JMAX
      Goto Label6
    EndIf
  
    ; Q = SWQ/SW = SUM(W(K)*Q(K))/SUM(W(K)) WHERE THE SUM IS
    ; FROM K = 1 TO N, Q(K) IS THE QUADRATIC NODAL FUNCTION,
    ; AND W(K) = ((R-D)+/(R*D))**2 FOR RADIUS R(K) AND DIST-
    ; ANCE D(K).  THUS
    ;
    ;  QX = (SWQX*SW - SWQ*SWX)/SW**2  AND
    ;  QY = (SWQY*SW - SWQ*SWY)/SW**2
    ;
    ; WHERE SWQX AND SWX ARE PARTIAL DERIVATIVES WITH RESPECT
    ; TO X OF SWQ AND SW, RESPECTIVELY.  SWQY AND SWY ARE DE-
    ; FINED SIMILARLY.
    SW = 0.0
    SWX = 0.0
    SWY = 0.0
    SWQ = 0.0
    SWQX = 0.0
    SWQY = 0.0
  
    ; OUTER LOOP ON CELLS (I,J).
    For J = JMIN To JMAX
      For I = IMIN To IMax
        K = LCELL(I, J)
        If K = 0 : Goto Label3 : EndIf
  
        ; INNER LOOP ON NODES K.
        Label1:
        DELX = XP - X(K)
        DELY = YP - Y(K)
        DXSQ = DELX * DELX
        DYSQ = DELY * DELY
        DS = DXSQ + DYSQ
        RS = RSQ(K)
        If DS >= RS : Goto Label2 : EndIf
        If DS = 0.0 : Goto Label4 : EndIf
        RDS = RS * DS
        RD = Sqr(RDS)
        w = (RS + DS - RD - RD) / RDS
        t = 2.0 * (RD - RS) / (DS * RDS)
        WX = DELX * t
        WY = DELY * t
        QKX = 2.0 * A(1, K) * DELX + A(2, K) * DELY
        QKY = A(2, K) * DELX + 2.0 * A(3, K) * DELY
        QK = (QKX * DELX + QKY * DELY) / 2.0
        QKX = QKX + A(4, K)
        QKY = QKY + A(5, K)
        QK = QK + A(4, K) * DELX + A(5, K) * DELY + F(K)
        SW = SW + w
        SWX = SWX + WX
        SWY = SWY + WY
        SWQ = SWQ + w * QK
        SWQX = SWQX + WX * QK + w * QKX
        SWQY = SWQY + WY * QK + w * QKY
  
        ; BOTTOM OF LOOP ON NODES IN CELL (I,J).
        Label2:
        KP = K
        K = LNEXT(KP)
        If K <> KP : Goto Label1 : EndIf
        Label3:
      Next I
    Next J
  
    ; SW = 0 IFF P IS NOT WITHIN THE RADIUS R(K) FOR ANY NODE K.
    If SW = 0.0 : Goto Label6 : EndIf
    *Q\d = SWQ / SW
    SWS = SW * SW
    *QX\d = (SWQX * SW - SWQ * SWX) / SWS
    *QY\d = (SWQY * SW - SWQ * SWY) / SWS
    *IER\i = 0
    ProcedureReturn
  
    ; (PX,PY) = (X(K),Y(K))
    Label4:
    *Q\d = F(K)
    *QX\d = A(4, K)
    *QY\d = A(5, K)
    *IER\i = 0
    ProcedureReturn
  
    ; INVALID INPUT PARAMETER.
    Label5:
    *IER\i = 1
    ProcedureReturn
  
    ; NO CELLS CONTAIN A POINT WITHIN RMAX OF P, OR
    ; SW = 0 AND THUS DS .GE. RSQ(K) FOR ALL K.
    Label6:
    *Q\d = 0.0
    *QX\d = 0.0
    *QY\d = 0.0
    *IER\i = 2
  EndProcedure
  
 Procedure STORE2(N.i, Array X.d(1), Array Y.d(1), NR.i, Array LCELL.i(2), Array LNEXT.i(1), *XMin.Double, *YMin.Double, *DX.Double, *DY.Double, *IER.Integer)
    ;
    ;***********************************************************
    ;
    ;                       ROBERT RENKA
    ;                   UNIV. OF NORTH TEXAS
    ;                         (817) 565-2767
    ;
    ;   GIVEN A SET OF N ARBITRARILY DISTRIBUTED NODES IN THE
    ;   PLANE, THIS SUBROUTINE CREATES A DATA STRUCTURE FOR A
    ;   CELL-BASED METHOD OF SOLVING CLOSEST-POINT PROBLEMS.  THE
    ;   SMALLEST RECTANGLE CONTAINING THE NODES IS PARTITIONED
    ;   INTO AN NR BY NR UNIFORM GRID OF CELLS, AND NODES ARE AS-
    ;   SOCIATED WITH CELLS.  IN PARTICULAR, THE DATA STRUCTURE
    ;   STORES THE INDICES OF THE NODES CONTAINED IN EACH CELL.
    ;   FOR A UNIFORM RANDOM DISTRIBUTION OF NODES, THE NEAREST
    ;   NODE TO AN ARBITRARY POINT CAN BE DETERMINED IN CONSTANT
    ;   EXPECTED TIME.
    ;
    ;   ON INPUT --
    ;
    ;    N =   NUMBER OF NODES.  N .GE. 2.
    ;
    ;    X,Y = ARRAYS OF LENGTH N CONTAINING THE CARTESIAN
    ;          COORDINATES OF THE NODES.
    ;
    ;    NR =  NUMBER OF ROWS AND COLUMNS IN THE GRID.  THE
    ;          CELL DENSITY (AVERAGE NUMBER OF NODES PER CELL)
    ;          IS D = N/(NR**2).  A RECOMMENDED VALUE, BASED
    ;          ON EMPIRICAL EVIDENCE, IS D = 3 -- NR =
    ;          SQRT(N/3).  NR .GE. 1.
    ;
    ;   THE ABOVE PARAMETERS ARE NOT ALTERED BY THIS ROUTINE.
    ;
    ;    LCELL = ARRAY OF LENGTH .GE. NR**2.
    ;
    ;    LNEXT = ARRAY OF LENGTH .GE. N.
    ;
    ;   ON OUTPUT --
    ;
    ;    LCELL = NR BY NR CELL ARRAY SUCH THAT LCELL(I,J)
    ;            CONTAINS THE INDEX (FOR X AND Y) OF THE
    ;            FIRST NODE (NODE WITH SMALLEST INDEX) IN
    ;            CELL (I,J), OR LCELL(I,J) = 0 IF NO NODES
    ;            ARE CONTAINED IN THE CELL.  THE UPPER RIGHT
    ;            CORNER OF CELL (I,J) HAS COORDINATES (XMIN+
    ;            I*DX,YMIN+J*DY).  LCELL IS NOT DEFINED IF
    ;            IER .NE. 0.
    ;
    ;    LNEXT = ARRAY OF NEXT-NODE INDICES SUCH THAT
    ;            LNEXT(K) CONTAINS THE INDEX OF THE NEXT NODE
    ;            IN THE CELL WHICH CONTAINS NODE K, OR
    ;            LNEXT(K) = K IF K IS THE LAST NODE IN THE
    ;            CELL FOR K = 1,...,N.  (THE NODES CONTAINED
    ;            IN A CELL ARE ORDERED BY THEIR INDICES.)
    ;            IF, FOR EXAMPLE, CELL (I,J) CONTAINS NODES
    ;            2, 3, AND 5 (AND NO OTHERS), THEN LCELL(I,J)
    ;            = 2, LNEXT(2) = 3, LNEXT(3) = 5, AND
    ;            LNEXT(5) = 5.  LNEXT IS NOT DEFINED IF
    ;            IER .NE. 0.
    ;
    ;    XMIN,YMIN = CARTESIAN COORDINATES OF THE LOWER LEFT
    ;            CORNER OF THE RECTANGLE DEFINED BY THE
    ;            NODES (SMALLEST NODAL COORDINATES) UN-
    ;            LESS IER = 1.  THE UPPER RIGHT CORNER IS
    ;            (XMAX,YMAX) FOR XMAX = XMIN + NR*DX AND
    ;            YMAX = YMIN + NR*DY.
    ;
    ;    DX,DY = DIMENSIONS OF THE CELLS UNLESS IER = 1.
    ;            DX = (XMAX - XMIN) / NR And DY = (YMAX - YMIN) / NR
    ;            WHERE XMIN, XMAX, YMIN, AND YMAX ARE THE
    ;            EXTREMA OF X AND Y.
    ;
    ;    IER =  ERROR INDICATOR --
    ;            IER = 0 IF NO ERRORS WERE ENCOUNTERED.
    ;            IER = 1 IF N .LT. 2 OR NR .LT. 1.
    ;            IER = 2 IF DX = 0 OR DY = 0.
    ;
    ;   MODULES REQUIRED BY STORE2 -- NONE
    ;
    ;   INTRINSIC FUNCTIONS CALLED BY STORE2 -- FLOAT, IFIX
    ;
    ;***********************************************************
    ;
    ; THIS SUBROUTINE CREATES A DATA STRUCTURE FOR A CELL-BASED METHOD
    ;
    Protected I.i, J.i, K.i, L.i, KB.i, Nn.i, NNR.i, NP1.i
    Protected XMN.d, XMX.d, YMN.d, YMX.d, DELX.d, DELY.d
  
    Nn = N
    NNR = NR
    If Nn < 2 Or NNR < 1
      Goto Label4
    EndIf
  
    ; COMPUTE THE DIMENSIONS OF THE RECTANGLE CONTAINING THE
    ; NODES.
    XMN = X(1)
    XMX = XMN
    YMN = Y(1)
    YMX = YMN
    For K = 2 To Nn
      If X(K) < XMN : XMN = X(K) : EndIf
      If X(K) > XMX : XMX = X(K) : EndIf
      If Y(K) < YMN : YMN = Y(K) : EndIf
      Label1:
      If Y(K) > YMX : YMX = Y(K) : EndIf
    Next K
    *XMin\d = XMN
    *YMin\d = YMN
  
    ; COMPUTE CELL DIMENSIONS AND TEST FOR ZERO AREA.
    DELX = (XMX - XMN) / NNR
    DELY = (YMX - YMN) / NNR
    *DX\d = DELX
    *DY\d = DELY
    If DELX = 0.0 Or DELY = 0.0
      Goto Label5
    EndIf
  
    ; INITIALIZE LCELL.
    For J = 1 To NNR
      For I = 1 To NNR
        Label2:
        LCELL(I, J) = 0
      Next I
    Next J
  
    ; LOOP ON NODES, STORING INDICES IN LCELL AND LNEXT.
    NP1 = Nn + 1
    For K = 1 To Nn
      KB = NP1 - K
      I = Int((X(KB) - XMN) / DELX) + 1
      If I > NNR : I = NNR : EndIf
      J = Int((Y(KB) - YMN) / DELY) + 1
      If J > NNR : J = NNR : EndIf
      L = LCELL(I, J)
      LNEXT(KB) = L
      If L = 0 : LNEXT(KB) = KB : EndIf
      Label3:
      LCELL(I, J) = KB
    Next K
  
    ; NO ERRORS ENCOUNTERED
    *IER\i = 0
    ProcedureReturn
  
    ; INVALID INPUT PARAMETER
    Label4:
    *IER\i = 1
    ProcedureReturn
  
    ; DX = 0 Or DY = 0
    Label5:
    *IER\i = 2
  EndProcedure

  ;- -----------------------------------
  ;- CONREC Contouring
  ;- -----------------------------------
  
  Procedure Conrec(Array z.d(2), Array x.d(1), Array y.d(1), nc, Array contour.d(1), ilb, iub, jlb, jub, Array color.l(1))

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
    ; ilb,iub,jlb,jub ; index bounds of Data matrix (x-lower,x-upper, y-lower,y-upper)
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
           ;extra conditional added here to insure that large values are not plotted
           ;if an area should not be contoured, values above nullcode should be entered in
           ;the matrix Z          
    ; ------------------------------------------------------------------------
         Protected Nullcode.d = 1E+37

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
                    ;this is where the program specific drawing routine comes in.
                    ;This specific command will work well for a properly dimensioned
                    ;vb picture box or vb form (where "Form1" is the name of the form)
                       
                    ; -------------------------------------------------------------------
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
  
  ;- -----------------------------------
  ;- Test Code
  ;- -----------------------------------
  
  ; until now all the Test Code is a simple conversion of
  ; the original test code.
  
  UseModule SurFit

  Procedure Test_Gradient_2D()
    Define NXI = 5
    Define NYI = 4
  
    ; Dimension arrays to be 1-based, just like in the VB6 code
    Dim XI.d(NXI)
    Dim YI.d(NYI)
    Dim ZI.d(NXI, NYI)
    Dim Grad.Grad_Type(NXI, NYI)
  
    Define I.i, J.i
  
    ; --- Fill input arrays with sample data ---
    ; Create an equispaced grid
    For I = 1 To NXI
      XI(I) = I - 1 ; 0.0, 1.0, 2.0, 3.0, 4.0
    Next
  
    For J = 1 To NYI
      YI(J) = J - 1 ; 0.0, 1.0, 2.0, 3.0
    Next
  
    ; Create a simple planar surface Z = X + 2Y
    ; The gradient should be (1, 2) everywhere
    For J = 1 To NYI
      For I = 1 To NXI
        ZI(I, J) = XI(I) + 2 * YI(J)
      Next
    Next
  
    ; --- Calculate the gradient ---
    Gradient2D(XI(), YI(), ZI(), NXI, NYI, Grad())
  
    ; --- Print the results to the debug console ---
    Debug "Gradient Results (DX, DY) for surface Z = X + 2Y:"
    Protected row$
    For J = 1 To NYI
      For I = 1 To NXI
        row$ + "I" + I + ",J" + J + ":(" + StrD(Grad(I, J)\DX, 1) + ", " + StrD(Grad(I, J)\DY, 1) + ")   "
      Next
      Debug RTrim(row$)
    Next
  EndProcedure
  
  Procedure Test_QSHEPD2()
    Protected.i I, IER, J, K
    Protected.d EPS, EP1, EQ, EQX, EQY, PX, PY, Q, QX, QY, Q1, RQ
    Protected.d XX, YK, YY, XMin, YMin, DX, DY, RMAX
  
    ; Constants
    #N = 36
    #NQ = 13
    #NW = 19
    #NR = 3
  
    ; Arrays (1-based)
    Dim LCELL.i(#NR, #NR)
    Dim LNEXT.i(#N)
    Dim X.d(#N)
    Dim Y.d(#N)
    Dim F.d(#N)
    Dim RSQ.d(#N)
    Dim A.d(5, #N)
    Dim P.d(10)
  
    ; GENERATE A 6 BY 6 GRID OF NODES
    K = 0
    For J = 1 To 6
      YK = (6 - J) / 5.0
      For I = 1 To 6
        K = K + 1
        X(K) = (I - 1) / 5.0
        Y(K) = YK
      Next I
    Next J
  
    ; COMPUTE THE DATA VALUES.
    For K = 1 To #N
      F(K) = Pow((X(K) + 2.0 * Y(K)) / 3.0, 2)
    Next K
  
    ; COMPUTE PARAMETERS DEFINING THE INTERPOLANT Q.
    QSHEP2(#N, X(), Y(), F(), #NQ, #NW, #NR, LCELL(), LNEXT(), @XMin, @YMin, @DX, @DY, @RMAX, RSQ(), A(), @IER)
  
    If IER <> 0
      MessageRequester("Error", "Error in QSHEP2 -- IER = " + Str(IER))
      End
    EndIf
  
    ; GENERATE A 10 BY 10 UNIFORM GRID OF INTERPOLATION POINTS
    For I = 1 To 10
      P(I) = (I - 1) / 9.0
    Next I
  
    ; COMPUTE THE MACHINE PRECISION EPS.
    EPS = 1.0
    Label4_Main:
    EPS = EPS / 2.0
    EP1 = EPS + 1.0
    If EP1 > 1.0 : Goto Label4_Main : EndIf
    EPS = EPS * 2.0
  
    ; COMPUTE INTERPOLATION ERRORS
    EQ = 0.0
    EQX = 0.0
    EQY = 0.0
  
    For J = 1 To 10
      PY = P(J)
      For I = 1 To 10
        PX = P(I)
        Q1 = QS2VAL(PX, PY, #N, X(), Y(), F(), #NR, LCELL(), LNEXT(), XMin, YMin, DX, DY, RMAX, RSQ(), A())
        QS2GRD(PX, PY, #N, X(), Y(), F(), #NR, LCELL(), LNEXT(), XMin, YMin, DX, DY, RMAX, RSQ(), A(), @Q, @QX, @QY, @IER)
  
        If IER <> 0
          MessageRequester("Error", "Error in QS2GRD -- IER = " + Str(IER))
          End
        EndIf
  
        If Abs(Q1 - Q) > 3.0 * Abs(Q) * EPS
          MessageRequester("Error", "Interpolated values differ: " + StrD(Q1) + " vs " + StrD(Q))
        EndIf
  
        If Abs(Pow((PX + 2.0 * PY) / 3.0, 2) - Q) > EQ : EQ = Abs(Pow((PX + 2.0 * PY) / 3.0, 2) - Q) : EndIf
        If Abs(2.0 * (PX + 2.0 * PY) / 9.0 - QX) > EQX : EQX = Abs(2.0 * (PX + 2.0 * PY) / 9.0 - QX) : EndIf
        If Abs(4.0 * (PX + 2.0 * PY) / 9.0 - QY) > EQY : EQY = Abs(4.0 * (PX + 2.0 * PY) / 9.0 - QY) : EndIf
      Next I
    Next J
  
    RQ = EQ / EPS
    Define Msg$
    Msg$ = "MAXIMUM ABSOLUTE ERRORS RELATIVE TO MACHINE PRECISION EPS" + #CRLF$ + #CRLF$
    Msg$ + "FUNCTION  MAX ERROR  MAX ERROR/EPS" + #CRLF$
    Msg$ + "Q         " + StrD(EQ, 6) + "     " + StrD(RQ, 2) + #CRLF$
    Msg$ + "QX        " + StrD(EQX, 6) + #CRLF$
    Msg$ + "QY        " + StrD(EQY, 6)
  
    MessageRequester("QSHEP2D Results", Msg$)
  
  EndProcedure
  
  Test_Gradient_2D()
  Test_QSHEPD2()
CompilerEndIf


; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 23
; Folding = -----
; EnableXP
; DPIAware