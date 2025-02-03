; ===========================================================================
; FILE : PbFw_Module_TRIGf.pb
; NAME : PureBasic Framework : Module Trigonometry [TRIGf::]
; DESC : Single precicion Trigonometry 
; DESC : 
; DESC : For double precicion Trigonometry use [TRIGd::]
; SOURCES:
;   Computational Geometry in C - Joseph O'Rourke.
;   https://github.com/w8r/orourke-compc/blob/master/
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/07/30
; VERSION  :  0.11 Brainstorming Version
; COMPILER :  PureBasic 6.0 and higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
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
    Ri.f         ; Radius inner circle
    Ro.f         ; Raduus outseide circle
    alpha.f     ; Angle alpha [radian]
    beta.f      ; Angle beta  [radian]
    gamma.f     ; Angle gamma [radian]
    dir.i       ; direction -1 := CW (ClockWise) / 0 := collinear points / 1 := CCW (CounterClockWise)
  EndStructure
  
  ; Line functions
  Declare.f Line_Length(*LPtA.TPoint2D, *LPtB.TPoint2D)
  Declare.f Line_PointDistance(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
  Declare.f Line_IsPointOnLine(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
  Declare.i Line_Intersection(*Out.TPoint2D, *L1PtA.TPoint2D, *L1PtB.TPoint2D, *L2PtA.TPoint2D, *L2PtB.TPoint2D)
  
  ; Triangle functions
  Declare.f Triangel_Perimeter(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_Angles(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Triangle_Area(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.i Triangle_Center(*OutPt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Triangle_Radius(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
  Declare.f Triangle_RadiusIn(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
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
    ;           3      |    2      |     1     |    0
    ; --------------------------------------------------------------------------------
    ; XMM1 : L2PtB\Y   |  L2PtB\X  |  L2PtB\Y  |  L2PtB\X   ; All End-Coordinates   in a Vector
    ; XMM0 : L2PtA\Y | S2Start\X | L1PtA\Y | L1PtA\X  ; All Start-Coordinates in a Vector
    ; --------------------------------------------------------------------------------
    
    !MOVAPS XMM2, XMM1     ; Copy End-Coordinates to XMM2
    !SUBPS XMM2, XMM0      ; End - Start
    ; now we have
    ; DWORD:     3     |    2      |     1     |    0
    ; --------------------------------------------------------------------------------
    ; XMM0 : L2PtA\Y | L2PtA\X | L1PtA\Y | L1PtA\X  ; All Start-Coordinates in a Vector
    ; XMM2 : L2H       | L2W       | L1H       | L1W        ; All Delta-Coordinates in a Vector
    
    ; => we have to Shuffel XMM2 to XMM3 to get the correct values together
    
    ; XMM0 :  L2PtA\Y | L2PtA\X | L1PtA\Y | L1PtA\X  ; All Start-Coordinates in a Vector
    ; XMM3 :  L2W       | L2H       | L1W       | L1H        ; We need this constellation for Multiply
    ; SHUF :   2        |  3        |  0        |  1         ; = b10110001
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
  
  Procedure.f Collinear(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
;  Reference:
;
;    Joseph ORourke,
;    Computational Geometry in C,
    
    ; collinear ( xa, ya, xb, yb, xc, yc )
    Protected.f side_ab_sq, side_bc_sq, side_ca_sq, side_max_sq
    Protected.f xa, xb, xc
    Protected.f ya, yb, yc
    
    Protected.f area
    
;     area = 0.5 * ( (xb - xa) * (yc - ya )  - ( xc - xa ) * ( yb - ya ) )
;     
;     side_ab_sq = (xa - xb) ** 2 + (ya - yb) ** 2
;     side_bc_sq = (xb - xc) ** 2 + (yb - yc) ** 2
;     side_ca_sq = (xc - xa) ** 2 + (yc - ya) ** 2
;     
;     side_max_sq = max ( side_ab_sq, max ( side_bc_sq, side_ca_sq ) )
; 
;     If ( side_max_sq <= r8_eps ) then
;       value = #True
;     Else If ( 2.0D+00 * Abs ( area ) <= r8_eps * side_max_sq ) then
;       value = #True
;     Else
;     value = #False
;     End If

    ; ProcedureReturn value

  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Line Functions
  ;- ----------------------------------------------------------------------
  
  ; TPoint2D is from VectorModule VECf::TPoint2D
  Procedure.f Line_Length(*LPtA.TPoint2D, *LPtB.TPoint2D)
    
  EndProcedure
    
  Procedure.f Line_PointDistance(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
    Protected.f dx, dy, pvx, pvy, m
    
    ; distances 
    dx = *LPtB\x - *LPtA\x    ; LineWidth
    dy = *LPtB\y - *LPtA\y    ; LineHeight
    pvx = *Pt\x - *LPtA\x        ; Point to LPtA X
    pvy = *Pt\y - *LPtA\y        ; Point to LPtA y
  
    ; Normalize
    m = Sqr(dx * dx + dy * dy)
    
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
  
  Procedure.f Line_IsPointOnLine(*Pt.TPoint2D, *LPtA.TPoint2D, *LPtB.TPoint2D)
    
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
    
  EndProcedure
  
  Procedure.i Triangle_Angles(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    
  EndProcedure
  
  Macro mac_Triangle_Area(P1, P2, P3)
    ( ( (P2\X - P1\X) * (P3\Y - P1\Y) - (P3\X - P1\X) * (P2\Y - P1\Y) ) * 0.5 ) 
  EndMacro
  
  Procedure.f Triangle_Area(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; https://de.wikipedia.org/wiki/Dreiecksfl%C3%A4che
    ; A=0.5 * Abs( (X2-X1)(Y3-Y1) - (X3-X1)(Y2-Y1) )
    ; A = 0.5 ( (*PtB\X - *PtA\X) * (*PtC\Y - *PtA\Y) - (*PtC\X - *PtA\X) * (*PtB\Y - *PtA\Y) )
  
    ProcedureReturn ( ( (*PtB\X - *PtA\X) * (*PtC\Y - *PtA\Y) - (*PtC\X - *PtA\X) * (*PtB\Y - *PtA\Y) ) *0.5 )
  EndProcedure
  
  Procedure Triangle_Center(*OutPt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    
  EndProcedure
  
  Procedure.f Triangle_Radius(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    
  EndProcedure

  Procedure.f Triangle_RadiusIn(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    
  EndProcedure
  
  Procedure.i Triangle_Edges(*Out.TVector, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; calculates the length of all 3 edges  
  EndProcedure
  
  Procedure.i Triangle_PointNear(*OutPt.TPoint2D, *Pt.TPoint2D, *PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; finds the nearest point on the TPangle to Pt
  EndProcedure
  
  Procedure.f Triangle_PointDistance(*Pt.TPoint2D, *PtA.TPoint2D, *TP2.TPoint2D, *TP3.TPoint2D)
    
  EndProcedure
  
  Procedure.i Triangle_IsPointInside(*Pt.TPoint2D, *PtA.TPoint2D, *TP2.TPoint2D, *TP3.TPoint2D)
    
  EndProcedure
  
  Procedure.f Triangle_Quality(*PtA.TPoint2D, *PtB.TPoint2D, *PtC.TPoint2D)
    ; The triangel qualility is  Q = 2 * InsideRadius / OutsedeRadius
    ; The range of qulity Q = [0..1]. A equilateral triangle has Q=1
    
    ProcedureReturn 0
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
    
    dx = *Pt\x - *CircleCenter\x        ; Distance X
    dy = *Pt\y - *CircleCenter\y        ; Distance Y
    
    m = Abs(Sqr(dx * dx + dy * dy))     ; Absolute distance Point to CircleCenter
    
    ProcedureReturn (m - Radius)        ; If ReturnValue is negative Then Point is inside the Circle    
  EndProcedure
  
  
  Procedure.i Circle_IsPointInside(*Pt.TPoint2D, *CircleCenter.TPoint2D, Radius.f)
    
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
    
  EndProcedure
  
  Procedure.f CircleSector_Area(Radius.f, Angle.f)
    
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
    
  EndProcedure
  
  Procedure.f Ellipse_Area(R1.f, R2.f)
    ProcedureReturn R1 * R2 * #PI 
  EndProcedure
  
  Procedure.i Ellipse_PointNear(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
    
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
    ProcedureReturn R1 * R2 * #PI 
  EndProcedure
  
  Procedure.f EllipseSector_Area(R1.f, R2.f)
    ProcedureReturn R1 * R2 * #PI 
  EndProcedure
  
  Procedure.i EllipseSector_PointNear(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
    
  EndProcedure
  
  Procedure.f EllipseSector_PointDistance(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
      
  EndProcedure

  Procedure.i EllipseSector_IsPointInside(*Pt.TPoint2D, *EllipseCenter.TPoint2D, R1.f, R2.f)
      
  EndProcedure
 
EndModule

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 424
; FirstLine = 394
; Folding = ----------
; Optimizer
; CPU = 5