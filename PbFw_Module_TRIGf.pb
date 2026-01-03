; ===========================================================================
; FILE : PbFw_Module_TRIGf.pb
; NAME : PureBasic Framework : Module Trigonometry [TRIGf::]
; DESC : Single precicion Trigonometry 
; DESC : 
; DESC : For double precicion Trigonometry use [TRIGd::]
; SOURCES:
;   Computational Geometry in C - Joseph O'Rourke.
;   https://github.com/w8r/orourke-compc/blob/master/
;
;   John Burkardt, Florida State University - Department of scientific computing           
;   https://people.sc.fsu.edu/~jburkardt/

; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/07/30
; VERSION  :  0.12 Brainstorming Version
; COMPILER :  PureBasic 6.0+
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
; 2025/12/03 S.Maag : implemented some functions
; 2024/09/08 S.Maag : added new Module local configurations 
; 
;} 
;{ TODO:
; 
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_PX.pb"           ; PX::       Purebasic Extention Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
XIncludeFile "PbFw_Module_VECTORf.pb"      ; VECf::     single precicion Vector Module

;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule TRIGf
  
  EnableExplicit
   
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
  
  UseModule VECf
  
  ; TPoint2D is from VectorModule VECf::TPoint2D
  
  Structure TTriPara
    S.f         ; Area, Surface
    P.f         ; Perimeter, lenght of closed path = a+b+c
    Q.f         ; Qualtiy of the triangle
    a.f         ; Lenght side a
    b.f         ; Lenght side b
    c.f         ; Lenght side c
    Ri.f        ; Radius inner circle
    Ro.f        ; Raduus outside circle
    alpha.f     ; Angle alpha [radian]
    beta.f      ; Angle beta  [radian]
    gamma.f     ; Angle gamma [radian]
    dir.i       ; direction -1 := CW (ClockWise) / 0 := collinear points / 1 := CCW (CounterClockWise)
  EndStructure
  
  ; Line functions
  Declare.i Collinear(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Line_Length(*LPtA.TPoint2D, *LPtB.TPoint2D)
  Declare.f Line_PointDistance(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
  Declare.i Line_Intersection(*Out.TPoint2D, *L1PtA.TPoint2D, *L1PtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D)
  
  ; Triangle functions
  Declare.f Triangel_Perimeter(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_Angles(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Triangle_Area(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_Center(*OutPt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Triangle_CircumCircle(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Triangle_InCircle(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_Edges(*Out.TVector, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Triangle_PointDistance(*Pt.TPoint2D, *PtA.TPoint2D, *TP2.TPoint2D, *TP3.TPoint2D)
  Declare.i Triangle_IsPointInside(*Pt.TPoint2D, *PtA.TPoint2D, *TP2.TPoint2D, *TP3.TPoint2D)
  Declare.f Triangle_Quality(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  
  ; Polygon functions
  Declare.f Polygon_Perimeter(List PolyPts.TPoint2D())
  Declare.i Polygon_Angles(List lstOutAngles.f(), List PolyPts.TPoint2D())
  Declare.f Polygon_Area(List PolyPts.TPoint2D())
  Declare.i Polygon_Center(*OutPt.TPoint2D, List PolyPts.TPoint2D())
  Declare.f Polygon_Radius(*PtA.TPoint2D, List PolyPts.TPoint2D())
  Declare.f Polygon_RadiusIn(List PolyPts.TPoint2D())
  Declare.i Polygon_Edges(Array OutEdges.f(1), List PolyPts.TPoint2D())
  Declare.i Polygon_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, List PolyPts.TPoint2D())
  Declare.f Polygon_PointDistance(*Pt.TPoint2D, List PolyPts.TPoint2D())
  Declare.i Polygon_IsPointInside(*Pt.TPoint2D, List PolyPts.TPoint2D())
  
  ; Circle functions
  Declare.f Circle_Perimeter(Radius.f)
  Declare.f Circle_Area(Radius.f)
  Declare.i Circle_PointNear(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
  Declare.f Circle_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
  Declare.i Circle_IsPointInside(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
  Declare.i Circle_TangentToPoint(*OutT1.TPoint2D, *OutT2.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, Radius.f)
  
  ; CircleSector functions
  Declare.f CircleSector_Perimeter(Radius.f, Angle.f)
  Declare.f CircleSector_Area(Radius.f, Angle.f)
 
  ; Ellipse functions
  Declare.f Ellipse_Perimeter(R1.f, R2.f)
  Declare.f Ellipse_Area(R1.f, R2.f)
  Declare.i Ellipse_PointNear(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
  Declare.f Ellipse_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
  Declare.i Ellipse_IsPointInside(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
  Declare.i Ellipse_TangentToPoint(*OutT1.TPoint2D, *OutT2.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, R1.f, R2.f)
  
  ; EllipseSector functions
  Declare.f EllipseSector_Perimeter(R1.f, R2.f)

EndDeclareModule

Module TRIGf
  
  EnableExplicit
  UseModule VECf
  
  ;- ----------------------------------------------------------------------
  ;- PbFw Module local configurations
  ;  ----------------------------------------------------------------------
  ; This constants must have same Name in all Modules
  
  ; ATTENTION: with the PbFw::CONST Macro the PB-IDE Intellisense do not registrate the ConstantName
  
  ; #PbFwCfg_Module_CheckPointerException = #True     ; On/Off PoninterExeption for this Module
  PbFw::CONST(PbFwCfg_Module_CheckPointerException, #True)
  
  ;#PbFwCfg_Module_ASM_Enable = #True                ; On/Off Assembler Versions when compling in ASM Backend
  PbFw::CONST(PbFwCfg_Module_ASM_Enable, #True)
 
  ; -----------------------------------------------------------------------
      
  ; ************************************************************************
  ; PbFw::mac_CompilerModeSettting      ; using Macro for CompilerSetting is a problem for the IDE
  ; so better use the MacroCode directly
  ; Do not change! Must be changed globaly in PbFw:: and then copied to each Module
  Enumeration
    #PbFwCfg_Module_Compile_Classic                 ; use Classic PB Code
    #PbFwCfg_Module_Compile_ASM32                   ; x32 Bit Assembler
    #PbFwCfg_Module_Compile_ASM64                   ; x64 Bit Assembler
    #PbFwCfg_Module_Compile_C                       ; use optimations for C-Backend
  EndEnumeration
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm And #PbFwCfg_Module_ASM_Enable And PbFw::#PbFwCfg_Global_ASM_Enable 
    ; A S M   B A C K E N D
    CompilerIf #PB_Compiler_32Bit
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM32     
    ; **********  64 BIT  **********
    CompilerElseIf #PB_Compiler_64Bit
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM64     
    ; **********  Classic Code  **********
    CompilerElse
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
    CompilerEndIf
      
  CompilerElseIf  #PB_Compiler_Backend = #PB_Backend_C
    ;  C - B A C K E N D
     #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_C     
  CompilerElse
    Debug "Classic" 
    ;  To force Classic Code Compilation
    #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
  CompilerEndIf 
  ; ************************************************************************
  ;Debug "PbFwCfg_Module_Compile = " + #PbFwCfg_Module_Compile
  
  ; ----------------------------------------------------------------------
  
  PbFw::ListModule(#PB_Compiler_Module)   ; Lists the Module in the ModuleList (for statistics)
  
  IncludeFile "PbFw_ASM_Macros.pbi"       ; Standard Assembler Macros
  
   
  ;- ----------------------------------------------------------------------
  ;- Module Private
  ;- ----------------------------------------------------------------------
  
  Macro _macPythagoras(A, B)
    Sqr((A*A + B*B))  
  EndMacro
  
  Macro _mac_Triangle_Area(P1, P2, P3)
    (( (P2\X - P1\X) * (P3\Y - P1\Y) - (P3\X - P1\X) * (P2\Y - P1\Y) ) *0.5) 
  EndMacro
  
  Macro _Epsilon(val = 1)
    PX::#PX_EpsilonF
  EndMacro
  
  ;  ----------------------------------------------------------------------
  ;- Assembler Macros : MMX/SSE optimized routines
  ;- ----------------------------------------------------------------------
    
  ; The Macro has always the same structure, for x32/x64. We hvae to change
  ; only the Register-Parameters! So call:
  ; MacroName(EAX, EDX, ECX) for x32
  ; MacroName(RAX, RDX, RCX) for x64
  Macro ASM_Line_Intersection(REGA, REGD, REGC) 
    ; Line_Intersection(*Out.TPoint2D, *L1PtA.TPoint2D, *LPtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D)
    
    ; SSE2 needed
    ; XMM0 : All Start-Coordinates : and later 4x determinant
    ; XMM1 : All End-Coordiantes
    ; XMM2 : Coordinate deltas : XMM1-XMM0
    ; XMM3 : Operation Register for Shuffle
    ; XMM4 : Operation Register
    ; XMM5 : -
    
    ; This is an empty Macro because XMM4/5 are volatile! XMM4/5 are nonVolatile if Compiler use VectorCall option (might be in C-Backend)
    ASM_PUSH_XMM_4to5(REGD)     ; we call Macro here, so if it is later filled with code, we do not have to update our ASM Code
    
    !MOV     REGA, [p.p_L2PtA]
    !MOV     REGD, [p.p_L2PtB]
    !MOVHPS  XMM0, [REGA]       ; Move 8 Byte from L1PtA to XMM0 Register Hi-QuadWord
    !MOVHPS  XMM1, [REGD]       ; Move 8 Byte from L2PtA to XMM1 Register Hi-QuadWord

    !MOV     REGA, [p.p_L1PtA]
    !MOV     REGD, [p.p_LPtB]
    !MOVLPS  XMM0, [REGA]       ; Move 8 Byte from L1PtA to XMM0 Register Lo-QuadWord
    !MOVLPS  XMM1, [REGD]       ; Move 8 Byte from L2PtA to XMM1 Register Lo-QuadWord
    
    
    ; now we have
    ;           3     |    2      |     1     |    0
    ; --------------------------------------------------------------------------------
    ; XMM1 : L2PtB\Y  |  L2PtB\X  |  L2PtB\Y  | L2PtB\X   ; All End-Coordinates   in a Vector
    ; XMM0 : L2PtA\Y  | S2Start\X |  L1PtA\Y  | L1PtA\X   ; All Start-Coordinates in a Vector
    ; --------------------------------------------------------------------------------
    
    !MOVAPS XMM2, XMM1     ; Copy End-Coordinates to XMM2
    !SUBPS XMM2, XMM0      ; End - Start
    ; now we have
    ; DWORD:     3    |    2     |     1    |    0
    ; --------------------------------------------------------------------------------
    ; XMM0 : L2PtA\Y  | L2PtA\X  | L1PtA\Y  | L1PtA\X   ; All Start-Coordinates in a Vector
    ; XMM2 : L2H      | L2W      | L1H      | L1W       ; All Delta-Coordinates in a Vector
    
    ; => we have to Shuffel XMM2 to XMM3 to get the correct values together
    
    ; XMM0 :  L2PtA\Y | L2PtA\X | L1PtA\Y | L1PtA\X    ; All Start-Coordinates in a Vector
    ; XMM3 :  L2W     | L2H     | L1W     | L1H        ; We need this constellation for Multiply
    ; SHUF :   2      |  3      |  0      |  1         ; = b10110001
    ; to change the Positions we have to use a Shuffle-Command PSHUFD where the Suffle Parameter
    ; is the made of the Position-Index where the value is from [0..3]
    
    !PSHUFD XMM3, XMM2, b10110001 ; [2,3,0,1]
    !MULPS  XMM3, XMM0
    
    ; now we have
    ;             3           |        2        |        1        |       0
    ; --------------------------------------------------------------------------------
    ; XMM3 :  L2PtA\Y * L2W | L2PtA\X * L2H | L1PtA\Y * L1W | L1PtA\X * L1H  
    ; XMM1 :  L2PtA\X * L2H | L2PtA\Y * L2W | L1PtA\X * L1H | L1PtA\Y * L1W   ; PSHUFD XMM1, XMM3, b10110001
    ; --------------------------------------------------------------------------------
    ; after ADDPS XMM3, XMM1
    ; XMM3 :    K2            |       K2        |      K1         |       K1
    
    !PSHUFD XMM1, XMM3, b10110001
    !ADDPS XMM3, XMM1
    ; --------------------------------------------------------------------------------
    
    ; now caclulating determinant   det = (L1H * L2W) - (L2H * L1W);

    ;          3     |    2     |     1    |    0
    ; --------------------------------------------------------------------------------
    ; XMM2 :  L2H    |   L2W    |    L1H   |   L1W        ; All Delta-Coordinates   in a vector
    ; XMM1 :  L1W    |   L1H    |    L2W   |   L2H        ; Suffle for (L1W * L2H) and (L2W * L1H) 
    ; --------------------------------------------------------------------------------
    ; XMM1 : L2H*L1W | L1H*L2W  | L1H*L2W  | L2H*L1W      ; Multilpy !MULPS XMM1, XMM2
    ; XMM4 : L2H*L1W | L2H*L1W  | L2H*L1W  | L2H*L1W      ; !PSHUFD XMM0, XMM1, $0  
    
    !PSHUFD XMM1, XMM2, b00011011 ; [0,1,2,3]
    !MULPS XMM1, XMM2
    !PSHUFD XMM4, XMM1, $0        ; [0,0,0,0] fill all 4 values with from XMM0 with XMM1[0] = L2H*L1W
    
    ; (L1H * L2W) - (L2H * L1W)
    !SUBPS XMM1, XMM4
    !PSHUFD XMM0, XMM1, b01010101 ; [1,1,1,1] fill all 4 values of XMM0 with XMM1[0] = L2H*L1W
    !RCPPS XMM0, XMM0             ; Reciprocal of XMM0 = 1/XMM0  Reciprocals of Packed Single-Precision Float
    ; XMM0 : 4x det1 
    
    ; TODO! Check determinant valid! No Error at Reciprocal
    
    ; #Nan32 = $FFC00000            ; Bit representaion for the 32Bit Float NaN value
    ; #Nan64 = $FFF8000000000000    ; Bit representaion for the 64Bit Float NaN value

    ; *Out\x = (L2W * K1 - L1W * K2) * det  :   *Out\y = (L1H * K2 - L2H * K1) * det
    ; we have the follwing values in our Registers
    ; XMM2 :  L2H    |   L2W   |  L1H    |  L1W       ; All Delta-Coordinates   in a vector
    ; XMM3 :   K2    |   K2    |  K1     |  K1
    ; XMM4 :   K1    |   K1    |  K2     |  K2        ; PSHUFD XMM4, XMM3, b00001010       ; [0,0,2,2]     
    ; XMM4 :  L2H*K1 |  L2W*K1 |  L1H*K2 |  L1W*K2    ; MULPS XMM4, XMM2
    ; XMM3 :    0    |  L1W*K2 |  L2H*K1 |   0        ; PSHUFD XMM3, XMM4, b11011100       ; [3,1,3,0]   
    ; XMM4      0    |  out\x  | out\y   |   0        ; SUBPS XMM4, XMM3 : MULPS XMM4, XMM0
    ; XMM3      0    |    0    | out\y   | out\x      ; PSHUFD XMM4, XMM3, b11110110       ; [3,3,1,2] 
    
    !PSHUFD XMM4, XMM3, b00001010       ; [0,0,2,2] 
    !MULPS XMM4, XMM2
    !PSHUFD XMM3, XMM4, b11011100       ; [3,1,3,0] 
    !SUBPS XMM4, XMM3
    !MULPS XMM4, XMM0                   ; Multiply all with reciprocal determinant det1
    !PSHUFD XMM4, XMM3, b11110110       ; [3,3,1,2] 
    
    ; Move Point coordinates to *OUT
    !MOV REGA, [p.p_Out]
    !MOVUPS [REGA], XMM3
    !MOV REGA, 1            ; MOV EAX/RAX, #TRUE
    
    ASM_POP_XMM_4to5(REGD)  ; POP XMM4 and XMM5 if Macro is active   
   EndMacro
   
  ;- ----------------------------------------------------------------------
  ;- Classic Macros
  ;- ----------------------------------------------------------------------

  Macro mac_LineInstersection2D()
   ; Line_Intersection(*Out.TPoint2D, *L1PtA.TPoint2D, *LPtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D) 
    
   ; based on RosettaCode C# example
   ; https://rosettacode.org/wiki/Find_the_intersection_of_two_lines#C#
    
    Protected.f L1W, L1H, K1, L2W, L2H, K2, det1
    
    ; Line 1 
    L1W = *LPtB\x - *L1PtA\x     ; Line Width
    L1H = *LPtB\y - *L1PtA\y     ; Line Height
    K1  = *L1PtA\x * L1H  + *L1PtA\y * L1W    
    ; Line 2 
    L2W = *L2PtB\x - *L2PtA\x     ; Line Width
    L2H = *L2PtB\y - *L2PtA\y     ; Line Height
    K2  = *L2PtA\x * L2H + *L2PtA\y * L2W  
     
     ; det = L1Height * L2Width - L1Width * L2Height
    det1 = 1/(L1H * L2W - L2H * L1W) ; reciproce value of determinant
  
    ; If the determinant is zero, the lines are parallel!
    ; Because of using reciproce value we have to check for Infinity
    If IsInfinity(det1)
      *Out\x = NaN()
      *Out\y = NaN()
      ProcedureReturn #False
    Else
      ; Calculate the intersection point
      *Out\x = (L2W * K1 - L1W * K2) * det1
      *Out\y = (L1H * K2 - L2H * K1) * det1
      ProcedureReturn #True
    EndIf  
  EndMacro
  
  ;- ----------------------------------------------------------------------
  ;- Line Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.i Collinear(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ;Reference:
    ;Joseph O'Rourke,
    ;Computational Geometry in C,    
    ;collinear ( xa, ya, xb, yb, xc, yc ) : AllPointsOnLine?
    
    Protected.f side_sq, side_max_sq, area, dx, dy
    Protected.i ret
    
    #_r8_eps = _Epsilon()
    
    ;area = 0.5 * ( (xb - xa) * (yc - ya )  - ( xc - xa ) * ( yb - ya ) )
    area = _mac_Triangle_Area(*PtA, *PtB, *PtC)
     
    ;side_ab_sq = (xa - xb) ** 2 + (ya - yb) ** 2
    dx = *PtA\X - *PtB\X : dy = *PtA\Y - *PtB\Y
    side_max_sq = dx*dx + dy*dy
    
    ;side_bc_sq = (xb - xc) ** 2 + (yb - yc) ** 2
    dx = *PtB\X - *PtC\X : dy = *PtB\Y - *PtC\Y
    side_sq = dx*dx + dy*dy
    
    If side_sq > side_max_sq
      side_max_sq = side_sq
    EndIf
    
    ;side_ca_sq = (xc - xa) ** 2 + (yc - ya) ** 2
    dx = *PtC\X - *PtA\X : dy = *PtC\Y - *PtA\Y
    side_sq = dx*dx + dy*dy
    
    If side_sq > side_max_sq
      side_max_sq = side_sq     ; here we get Max(side_ab_sq, side_bc_sq, side_ca_sq)
    EndIf        
    ;side_max_sq = max ( side_ab_sq, max ( side_bc_sq, side_ca_sq ) )
   
    ; If ( side_max_sq <= r8_eps ) then
    ;   ret = #True
    ; Else If ( 2.0D+00 * Abs ( area ) <= r8_eps * side_max_sq ) then
    ;   ret = #True
    ; Else
    ;   ret = #False
    ; End If
    
    If side_max_sq <= #_r8_eps
      ret = #True
    ElseIf (Abs(area)*2) <= (#_r8_eps * side_max_sq)
      ret = #True
    EndIf
    
    ProcedureReturn ret
  EndProcedure

  ; TPoint2D is from VectorModule VECf::TPoint2D
  Procedure.f Line_Length(*LPtA.TPoint2D, *LPtB.TPoint2D)
    Protected.f dx, dy
    dx= *LPtA\X - *LPtB\X  : dy= *LPtA\Y - *LPtB\Y
    ProcedureReturn Sqr(dx*dx + dy*dy)
  EndProcedure
    
  Procedure.f Line_PointDistance(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
    Protected.f dx, dy, pvx, pvy, m
    
    ; distances 
    dx = *LPtB\x - *LPtA\x    ; LineWidth
    dy = *LPtB\y - *LPtA\y    ; LineHeight
    pvx = *Pt\x - *LPtA\x     ; Point to LPtA X
    pvy = *Pt\y - *LPtA\y     ; Point to LPtA y
  
    ; Normalize
    m = Sqr(dx*dx + dy*dy)
    
    If (m > 0.0) 
      dx / m
      dy / m
    Else
      ProcedureReturn 0.0     ; Point is on the Line
    EndIf
      
    ; Get dot product (project pv onto normalized direction)
    m = dx * pvx + dy * pvy; 
    ; Scale line direction vector and subtract it from pv
    pvx = pvx - m * dx
    pvy = pvy - m * dy
  
    ProcedureReturn Sqr(pvx * pvx + pvy * pvy)
  EndProcedure
    
  Procedure.i Line_Intersection(*Out.TPoint2D, *L1PtA.TPoint2D, *LPtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D)
  ; ============================================================================
  ; NAME: Line_Intersection
  ; DESC: Calculates the intersection point of 2 Lines
  ; VAR(*OUT.TPoint2D) : Pointer to Return-VPoint VECf::TPoint2D
  ; VAR(*L1PtA.TPoint2D): Pointer to Line 1 StartPoint VECf::TPoint2D
  ; VAR(*LPtB.TPoint2D)  : Pointer to Line 1 EndPoint   VECf::TPoint2D  
  ; VAR(*L2PtA.TPoint2D): Pointer to Line 2 StartPoint VECf::TPoint2D
  ; VAR(*L2PtB.TPoint2D)  : Pointer to Line 2 EndPoint   VECf::TPoint2D  
  ; RET.i : #False, if lines are parallel : #True, if lines intersect
  ; ============================================================================
             
    DBG::mac_CheckPointer5(*OUT, *L1PtA, *LPtB, *L2PtA, *L2PtB)    ; Check Pointer Exception
  
    CompilerSelect #PbFwCfg_Module_Compile
      
      CompilerCase #PbFwCfg_Module_Compile_ASM64  ; 64 Bit-Version        
        ASM_Line_Intersection(RAX, RDX, RCX)     ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
               
      CompilerCase #PbFwCfg_Module_Compile_ASM32  ; 32 Bit Version
        ASM_Line_Intersection(EAX, EDX, ECX)     ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
      
      CompilerCase #PbFwCfg_Module_Compile_C      ; for the C-Backend
        mac_LineInstersection2D()     
        ProcedureReturn *OUT

      CompilerDefault                 ; Classic Version
        mac_LineInstersection2D()     
        ProcedureReturn *OUT

    CompilerEndSelect  
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Triangle Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f Triangel_Perimeter(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    Protected.f ret, dx, dy
    
    ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    ret = Sqr(dx*dx + dy*dy)  
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    ret = ret + Sqr(dx*dx + dy*dy)    
    ; C->A
    dx = *PtC\x - *PtA\x : dy = *PtC\y - *PtA\y 
    ret = ret + Sqr(dx*dx + dy*dy)

    ProcedureReturn ret
  EndProcedure
  
  Procedure.i Triangle_Angles(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutAngles.TVector)
    Protected.f dx, dy, a, b, c, aa, bb, cc
    ; With use of cosines law:
    ;   c² = a² + b² - 2 * a * b * Cos (GAMMA)
    ; where GAMMA is the angle opposite side c.
    
    ; original by John Burkardt, 04 May 2005, MIT Licence, Fortran 90
    
    ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    aa = dx*dx + dy*dy 
    a = Sqr(aa)
    
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    bb = dx*dx + dy*dy    
    b = Sqr(bb)
    
    ; C->A
    dx = *PtC\x - *PtA\x : dy = *PtC\y - *PtA\y 
    cc = dx*dx + dy*dy
    c = Sqr(cc)
    
    With *Angles
      \v[0] = ACos((cc+aa-bb)/(c*a*2))
      \v[1] = ACos((aa+bb-cc)/(a*b*2))
      \v[2] = ACos((bb+cc-aa)/(b*c*2))
    EndWith
    
    ProcedureReturn *OutAngles
  EndProcedure
    
  Procedure.f Triangle_Area(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; https://de.wikipedia.org/wiki/Dreiecksfl%C3%A4che
    ; A=0.5 * Abs( (X2-X1)(Y3-Y1) - (X3-X1)(Y2-Y1) )
    ; A = 0.5 ( (*PtB\X - *PtA\X) * (*PtC\Y - *PtA\Y) - (*PtC\X - *PtA\X) * (*PtB\Y - *PtA\Y) )
  
    ProcedureReturn _mac_Triangle_Area(*PtA, *PtB, *PtC)
  EndProcedure
  
  Procedure Triangle_Center(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPt.TPoint2D)
    
    With *OutPt
      \X = (*PtA\X + *PtB\X + *PtC\X) * (1/3)
      \Y = (*PtA\Y + *PtB\Y + *PtC\Y) * (1/3)
    EndWith
    ProcedureReturn *OutPt
  EndProcedure
  
  Procedure.f Triangle_CircumCircle(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPtCenter.TPoint2D, *Radius.Float)
  ; The circumcenter of a triangle is the center of the circumcircle, the
  ; circle that passes through the three vertices of the triangle.
  ; 
  ; The circumcircle contains the triangle, but it is Not necessarily the
  ; smallest triangle to do so.
  ; 
  ; If all angles of the triangle are not greater than 90 degrees, then
  ; the center of the circumscribed circle will lie inside the triangle.
  ; Otherwise, the center will lie outside the triangle.
  ; 
  ; The circumcenter is the intersection of the perpendicular bisectors
  ; of the sides of the triangle.
  ; 
  ; In geometry, the circumcenter of a triangle is often symbolized by "O".
    
  ; original by John Burkardt, 6 May 2005, MIT Licence, Fortran 90
     
    Protected.f dxa, dxb, dxc, dya, dyb, dyc, a, b, c, aa, bb, cc
    ; With use of cosines law:
    ;   c² = a² + b² - 2 * a * b * Cos (GAMMA)
    ; where GAMMA is the angle opposite side c.
    
     ; A->B
    dxa = *PtA\x - *PtB\x : dya = *PtA\y - *PtB\y 
    aa = dxa*dxa + dya*dya 
    a = Sqr(aa)
    
    ; B->C
    dxb = *PtB\x - *PtC\x : dyb = *PtB\y - *PtC\y 
    bb = dxb*dxb + dyb*dyb    
    b = Sqr(bb)
    
    ; C->A
    dxc = *PtC\x - *PtA\x : dyc = *PtC\y - *PtA\y 
    cc = dxc*dxc + dyc*dyc
    c = Sqr(cc)
    
    bot = (a+b+c) * (-a+b+c ) * (a-b+c) * (a+b-c)
    
    If bot <= 0.0
      *Radius\f = -1.0
      *OutPtCenter\X = 0
      *OutPtCenter\Y = 0
    EndIf
    
    *Radius\f = a*b*c / Sqr(bot)
        
    tpx = dyc * aa + dya * cc
    tpy = dxc * aa - dxy * cc
    
    det =  (dya * dxc - dyc * dxa) * 2
    
    With *OutPtCenter
      \x = *PtA\x + tpx/det
      \y = *PtA\y + tpy/det
    EndWith
    
    ProcedureReturn *OutPtCenter
  EndProcedure

  Procedure.f Triangle_InCricle(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D, *OutPtCenter.TPoint2D, *Radius.Float)
    Protected.f dx, dy, a, b, c, u
   
    ; The inscribed circle of a triangle is the largest circle that can
    ; be drawn inside the triangle.  It is tangent To all three sides,
    ; and the lines from its center to the vertices bisect the angles
    ; made by each vertex.
    
    ; original by John Burkardt, 17 August 2009, MIT Licence, Fortran 90
    
    ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    a = Sqr(dx*dx + dy*dy) 
    
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    b = Sqr(dx*dx + dy*dy)    
    
    ; C->A
    dx = *PtC\x - *PtA\x : dy = *PtC\y - *PtA\y 
    c = Sqr(dx*dx + dy*dy)
    
    u = a+b+c
    
    With *OutPtCenter
      If u = 0 
        \X = *PtA\X
        \Y = *PtA\Y
        *Radius\f = 0  
      Else
        \X = (*PtA\x *b  + *PtB\X * c + *PtC\X * a) / u
        \Y = (*PtA\Y *b  + *PtB\Y * c + *PtC\Y * a) / u
        *Radius\f = Sqr((-a+b+c)*(a-b+c)*(a+b-c)/u) *0.5
      EndIf
    EndWith
    
  EndProcedure
  
  Procedure.i Triangle_Edges(*Out.TVector, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; calculates the length of all 3 edges  
    Protected.f dx, dy
    
    ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    *Out\x = Sqr(dx*dx + dy*dy)    
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    *Out\y = Sqr(dx*dx + dy*dy)   
    ; A->C
    dx = *PtA\x - *PtC\x : dy = *PtA\y - *PtC\y 
    *Out\z = Sqr(dx*dx + dy*dy)
  
  EndProcedure
  
  Procedure.i Triangle_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; finds the nearest point on the TPangle to Pt
  EndProcedure
  
  Procedure.f Triangle_PointDistance(*Pt.TPoint2D, *PtA.TPoint2D, *TP2.TPoint2D, *TP3.TPoint2D)
    
  EndProcedure
  
  Procedure.i Triangle_IsPointInside(*Pt.TPoint2D, *PtA.TPoint2D, *TP2.TPoint2D, *TP3.TPoint2D)
    Protected.f m
    Protected.i ret 
    
    ; The routine assumes that the vertices are given in counter clockwise
    ; order.  If the triangle vertices are actually given in clockwise 
    ; order, this routine will behave as though the triangle contains
    ; no points whatsoever!
    
    ; The routine determines if a point P is "to the right of" each of the lines
    ; that bound the triangle.  It does this by computing the cross product
    ; of vectors from a vertex to its next vertex, and to P.
    
    ; original by John Burkardt, 07 June 2006, MIT Licence, Fortran 90

    ;   do j = 1, 3
    ;     k = Mod ( j, 3 ) + 1      ; -> k= [2,3,1]
    ; 
    ;     If ( 0.0D+00 < ( p(1) - t(1,j) ) * ( t(2,k) - t(2,j) ) &
    ;                  - ( p(2) - t(2,j) ) * ( t(1,k) - t(1,j) ) ) then
    ;       inside = .false.
    ;       Return
    ;     End If
    ;   End do
    
    With *Pt
      m = (\x - *PtA\x * *PtB\y - *PtA\y) - (\y - *PtA\y * *PtB\x - *PtA\x)
      If m > 0 : ProcedureReturn #False  : EndIf
     
      m = (\x - *PtB\x * *PtC\y - *PtB\y) - (\y - *PtB\y * *PtC\x - *PtB\x)
      If m > 0 : ProcedureReturn #False  : EndIf
     
      m = (\x - *PtC\x * *PtA\y - *PtC\y) - (\y - *PtC\y * *PtA\x - *PtC\x)
      If m > 0 : ProcedureReturn #False  : EndIf  
    EndWith
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.f Triangle_Quality(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
   Protected.f dx, dy, a, b, c, q, ro
   
   ; The triangel qualility is  Q = 2 * InsideRadius / OutsideRadius
   ; The range of qulity Q = [0..1]. A equilateral triangle has Q=1
   
   ; original by John Burkardt, 30 July 2009, MIT Licence, Fortran 90
    
    ; A->B
    dx = *PtA\x - *PtB\x : dy = *PtA\y - *PtB\y 
    a = Sqr(dx*dx + dy*dy) 
    
    ; B->C
    dx = *PtB\x - *PtC\x : dy = *PtB\y - *PtC\y 
    b = Sqr(dx*dx + dy*dy)    
    
    ; C->A
    dx = *PtC\x - *PtA\x : dy = *PtC\y - *PtA\y 
    c = Sqr(dx*dx + dy*dy)
    
    ro = a*b*c 
    If ro = 0
      q=0
    Else
      q = (-a+b+c)*(a-b+c)*(a+b-c)/ro
    EndIf
    
    ProcedureReturn q
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Polygon Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f Polygon_Perimeter(List PolyPts.TPoint2D())
    
  EndProcedure

  Procedure.f Polygon_Area(List PolyPts.TPoint2D())
    
  EndProcedure
  
  Procedure.i Polygon_Center(*OutPt.TPoint2D, List PolyPts.TPoint2D())
    
  EndProcedure
  
  Procedure.i Polygon_Angles(List lstOutAngles.f(), List PolyPts.TPoint2D())
    
  EndProcedure

  Procedure.f Polygon_Radius(*PtA.TPoint2D, List PolyPts.TPoint2D())
    
  EndProcedure

  Procedure.f Polygon_RadiusIn(List PolyPts.TPoint2D())
    
  EndProcedure
  
  Procedure.i Polygon_Edges(Array OutEdges.f(1), List PolyPts.TPoint2D())
    ; calculates the length of all 3 edges  
  EndProcedure
  
  Procedure.i Polygon_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, List PolyPts.TPoint2D())
    ; finds the nearest point on the TPangle to Pt
  EndProcedure
  
  Procedure.f Polygon_PointDistance(*Pt.TPoint2D, List PolyPts.TPoint2D())
    
  EndProcedure
  
  Procedure.i Polygon_IsPointInside(*Pt.TPoint2D, List PolyPts.TPoint2D())
    
  EndProcedure
  

  ;- ----------------------------------------------------------------------
  ;- Circle Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f Circle_Perimeter(Radius.f)
    ProcedureReturn Radius * 2 *#PI 
  EndProcedure

  Procedure.f Circle_Area(Radius.f)
    ProcedureReturn Radius * Radius * #PI 
  EndProcedure
  
  Procedure.i Circle_PointNear(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
    
  EndProcedure

  Procedure.f Circle_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
    Protected.f dx, dy, m
    
    dx = *Pt\x - *CircleCenter\x      ; Distance X
    dy = *Pt\y - *CircleCenter\y      ; Distance Y
    
    m = Sqr(dx*dx + dy*dy)            ; Absolute distance Point to CircleCenter
    
    ProcedureReturn (m - Radius)      ; If ReturnValue is negative Then Point is inside the Circle    
  EndProcedure
   
  Procedure.i Circle_IsPointInside(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
    Protected.f dx, dy, m
    
    dx = *Pt\x - *CircleCenter\x      ; Distance X
    dy = *Pt\y - *CircleCenter\y      ; Distance Y
    
    m = Sqr(dx*dx + dy*dy)            ; Absolute distance Point to CircleCenter
    
    dx = (m - Radius)                 ; if Value is negative Then Point is inside the Circle  
    If dx < 0
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf    
  EndProcedure
 
  Procedure.i Circle_TangentToPoint(*OutT1.TPoint2D, *OutT2.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, Radius.f)
    ; calculates the 2 possible tanget points on a circle from a point outside the circle
    
    ; https://stackoverflow.com/questions/49968720/find-tangent-points-in-a-circle-from-a-point
    
    Protected.f dx, dy, b, th, d, d1, d2
    
    dx = *Pt\x - *CenterPt\x        ; X-Distance between Point and CenterOfCircle
    dy = *Pt\y - *CenterPt\y        ; Y-Distance between Point and CenterOfCircle
    
    d = ATan2(dy, dx)               ; Angle betwwen Point Pt and CircleCenter
    b = Sqr(dx *dx + dy *dy)        ; absolute Distance between Point and CenterOfCircle
    
    th = ACos(Radius/b)             ; Angle between Line b and Radius  
    d1 = d + th                     ; direction angle of point T1 from C
    d2 = d - th                     ; direction angle of point T2 from C
    
    With *OutT1
      \x = *CenterPt\x + Radius * Cos(d1)
      \y = *CenterPt\y + Radius * Sin(d1)    
    EndWith 
    
    With *OutT2
      \x = *CenterPt\x + Radius * Cos(d2)
      \y = *CenterPt\y + Radius * Sin(d2)    
    EndWith 
    
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- CircleSector Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f CircleSector_Perimeter(Radius.f, Angle.f)
;     Protected.f b
;     b = 2*#PI * Radius * Angle/360 
;     ProcedureReturn 2*Radius + b 
    
    ProcedureReturn ((#PI/180) * Angle +2) * Radius
  EndProcedure
  
  Procedure.f CircleSector_Area(Radius.f, Angle.f)
    ; A=Angle/360 * #PI * r*r
    ProcedureReturn (#PI/360) * Angle * Radius * Radius   
  EndProcedure
  
  Procedure.i CircleSector_PointNear(*Pt.TPoint2D, *CircelCenter.TPoint2D, Radius.f)
    
  EndProcedure

  Procedure.f CircleSector_PointDistance(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
    
  EndProcedure
  
  
  Procedure.i CircleSector_IsPointInside(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
    
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Ellipse Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f Ellipse_Perimeter(R1.f, R2.f)
    ; Ramanujan Aproximation : 
    ;               (         3x²        )       a-b
    ; (a+b) * #PI * (1 +  ---------------)  ; x=-----  ; a = Rx/2; b=Ry/2
    ;               (      10+Sqr(4-3x²) )       a+b
    
    Protected.f a, b, ab, x, z
    a= R1*0.5 : b= R2*0.5
    ab = a+b
    x = (a-b)/ab
    z = x*x*3   ; z=3x²
    
    ProcedureReturn (z/(Sqr(4-z)+10) +1) * #PI*ab
  EndProcedure
  
  Procedure.f Ellipse_Area(R1.f, R2.f)
    ; A= a*b*#PI  = R1/2 * R2/2 * #PI
    ProcedureReturn R1 * R2 * #PI * 0.25
  EndProcedure
  
  Procedure.i Ellipse_PointNear(R1.f, R2.f, *Pt.TPoint2D, *PtOut.TPoint2D)
    
    ; original by John Burkardt, 26 February 2005, MIT Licence, Fortran 90
    
    Protected.i I
    Protected.f x, y, t, rr1, rr2
    Protected.f ct, st, f, fp
    
    R1= Abs(R1) : R2= Abs(R2)
    
    x= Abs(*Pt\X= : y= Abs(*Pt\Y)
    rr1 = R1*R1 : rr2 = R2*R2
    
    If y=0 And (rr1-rr2 <= R1*x)
      t = 0
    ElseIf X=0 And (rr2-rr1 <= r2*y)
      t = #PI * 0.5
    Else
      
      If y=0
        y= Sqr(_epsilon(y) * r2)
      EndIf
      
      If x=0 
        x= Sqr(_epsilon(x) * r1)
      EndIf
      
      t = ATan2(x,y)
      
      Repeat
        
        ct = Cos(t) : st= Sin(t)
        
        f= (x- R1*ct) *R1*st - (y- R2*st) *R2*ct
        If Abs(f) <= 100 * _epsilon(f)
          Break
        EndIf
        
        ; max Iterations
        If I > 100
          Debug "Ellipse_PointNear: reacht iteration limit! T= " + StrF(t) + " : F= " + StrF(f)
          Break
        EndIf
        
        I+1
        
        fp= rr1*st*st + rr2*ct*ct + (x-R1*ct)*R1*ct + (y-R2*st)*R2*st
        t= t - f/fp
      ForEver
     
    EndIf
    
    ;  From the T value, we get the nearest point. 
    ; Take care of case where the point was in another quadrant.
    *PtOut\X = R1 * Cos(t) * Sign(*Pt\X)
    *PtOut\Y = R2 * Sin(t) * Sign(*Pt\Y)
    
  EndProcedure
  
  
  Procedure.f Ellipse_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
      
  EndProcedure

  Procedure.i Ellipse_IsPointInside(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
      
  EndProcedure
  
  
  Procedure.i Ellipse_TangentToPoint(*OutT1.TPoint2D, *OutT2.TPoint2D, *Pt.TPoint2D, *CenterPt.TPoint2D, R1.f, R2.f)
    ; calculates the 2 possible tanget points on a ellipse from a point outside the ellipse
    
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- EllipseSector Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.f EllipseSector_Perimeter(R1.f, R2.f)
    
  EndProcedure
  
  Procedure.f EllipseSector_Area(R1.f, R2.f)
    
  EndProcedure
  
  Procedure.i EllipseSector_PointNear(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
    
  EndProcedure
  
  Procedure.f EllipseSector_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
      
  EndProcedure

  Procedure.i EllipseSector_IsPointInside(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
      
  EndProcedure
 
EndModule

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 781
; FirstLine = 737
; Folding = ----------
; Optimizer
; CPU = 5