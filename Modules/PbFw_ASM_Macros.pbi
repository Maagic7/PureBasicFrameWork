; ===========================================================================
;  FILE : PbFw_ASM_Macros.pbi
;  NAME : Collection of Assembler optimation Macros
;  DESC : Macros for PUSH, POP MMX and XMM Registers when using
;  DESC : in PB Procedures
;  DESC : The macros don't work in out of Procedure code becuase
;  DESC : the in Procedure Assembler variable convetion is used
;  DESC : [p.p_] [p.v_] for Pointers / Variables
;  DESC : For use outside of Procedures you have to use [p_] [v_]
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/02/04
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 2024/08/01 S.Maag : added Register Load/Save Macros and Vector Macros
;                      for packed SingleFloat and packed DoubleWord

;{ TODO:
;}
; ===========================================================================


; ------------------------------
; MMX and SSE Registers
; ------------------------------
; MM0..MM7    :  MMX    : Pentium P55C (Q5 1995) and AMD K6 (Q2 1997)
; XMM0..XMM15 :  SSE    : Intel Core2 and AMD K8 Athlon64 (2003)
; YMM0..YMM15 :  AVX256 : Intel SandyBridge (Q1 2011) and AMD Bulldozer (Q4 2011)
; X/Y/ZMM0..31 : AVX512 : Tiger Lake (Q4 2020) and AMD Zen4 (Q4 2022)

; ------------------------------
; Caller/callee saved registers
; ------------------------------
; The x64 ABI considers the registers RAX, RCX, RDX, R8, R9, R10, R11, And XMM0-XMM5 volatile.
; When present, the upper portions of YMM0-YMM15 And ZMM0-ZMM15 are also volatile. On AVX512VL;
; the ZMM, YMM, And XMM registers 16-31 are also volatile. When AMX support is present, 
; the TMM tile registers are volatile. Consider volatile registers destroyed on function calls
; unless otherwise safety-provable by analysis such As whole program optimization.
; The x64 ABI considers registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, R15, And XMM6-XMM15 nonvolatile.
; They must be saved And restored by a function that uses them. 

;https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions?view=msvc-170
; x64 calling conventions - Register use

; ------------------------------
; x64 CPU Register
; ------------------------------
; RAX 	    Volatile 	    Return value register
; RCX 	    Volatile 	    First integer argument
; RDX 	    Volatile 	    Second integer argument
; R8 	      Volatile 	    Third integer argument
; R9 	      Volatile 	    Fourth integer argument
; R10:R11 	Volatile 	    Must be preserved As needed by caller; used in syscall/sysret instructions
; R12:R15 	Nonvolatile 	Must be preserved by callee
; RDI 	    Nonvolatile 	Must be preserved by callee
; RSI 	    Nonvolatile 	Must be preserved by callee
; RBX 	    Nonvolatile 	Must be preserved by callee
; RBP 	    Nonvolatile 	May be used As a frame pointer; must be preserved by callee
; RSP 	    Nonvolatile 	Stack pointer
; ------------------------------
; MMX-Register
; ------------------------------
; MM0:MM7   Nonvolatile   Registers shared with FPU-Register. An EMMS Command is necessary after MMX-Register use
;                         to enable correct FPU functions again. 
; ------------------------------
; SSE Register
; ------------------------------
; XMM0, YMM0 	Volatile 	  First FP argument; first vector-type argument when __vectorcall is used
; XMM1, YMM1 	Volatile 	  Second FP argument; second vector-type argument when __vectorcall is used
; XMM2, YMM2 	Volatile 	  Third FP argument; third vector-type argument when __vectorcall is used
; XMM3, YMM3 	Volatile 	  Fourth FP argument; fourth vector-type argument when __vectorcall is used
; XMM4, YMM4 	Volatile 	  Must be preserved As needed by caller; fifth vector-type argument when __vectorcall is used
; XMM5, YMM5 	Volatile 	  Must be preserved As needed by caller; sixth vector-type argument when __vectorcall is used
; XMM6:XMM15, YMM6:YMM15 	Nonvolatile (XMM), Volatile (upper half of YMM) 	Must be preserved by callee. YMM registers must be preserved As needed by caller.


; @f = Jump forward to next @@;  @b = Jump backward to next @@  
; .Loop:      ; is a local Label or SubLable. It works form the last global lable
; The PB compiler sets a global label for each Procedure, so local lables work only inside the Procedure

; ------------------------------
; Some important SIMD instructions 
; ------------------------------
; https://hjlebbink.github.io/x86doc/

; PAND, POR, PXOR, PADD ...  : SSE2
; PCMPEQW         : SSE2  : Compare Packed Data for Equal
; PSHUFLW         : SSE2  : Shuffle Packed Low Words
; PSHUFHW         : SSE2  : Shuffle Packed High Words
; PSHUFB          : SSE3  : Packed Shuffle Bytes
; PEXTR[B/W/D/Q]  : SSE4.1 : PEXTRB RAX, XMM0, 1 : loads Byte 1 of XMM0[Byte 0..7] 
; PINSR[B/W/D/Q]  : SSE4.1 : PINSRB XMM0, RAX, 1 : transfers RAX LoByte to Byte 1 of XMM0 
; PCMPESTRI       : SSE4.2 : Packed Compare Implicit Length Strings, Return Index
; PCMPISTRM       : SSE4.2 : Packed Compare Implicit Length Strings, Return Mask


;- ----------------------------------------------------------------------
;- NaN Value 32/64 Bit
; #Nan32 = $FFC00000            ; Bit representaion for the 32Bit Float NaN value
; #Nan64 = $FFF8000000000000    ; Bit representaion for the 64Bit Float NaN value
;  ----------------------------------------------------------------------

; ----------------------------------------------------------------------
;  Structures to reserve Space on the Stack for ASM_PUSH, ASM_POP
; ----------------------------------------------------------------------

Structure TStack_16Byte
  R.q[2]  
EndStructure

Structure TStack_32Byte
  R.q[4]  
EndStructure

Structure TStack_48Byte
  R.q[6]  
EndStructure

Structure TStack_64Byte
  R.q[8]  
EndStructure

Structure TStack_96Byte
  R.q[12]  
EndStructure

Structure TStack_128Byte
  R.q[16]  
EndStructure

Structure TStack_256Byte
  R.q[32]  
EndStructure

Structure TStack_512Byte
  R.q[64]  
EndStructure

;- ----------------------------------------------------------------------
;- CPU Registers
;- ----------------------------------------------------------------------

; seperate Macros for EBX,RBX because this is often needed expecally for x32
Macro ASM_PUSH_EBX()
  Protected mEBX
  !MOV [p.v_mEBX], EBX
EndMacro

Macro ASM_POP_EBX()
   !MOV EBX, [p.v_mEBX]
EndMacro

Macro ASM_PUSH_RBX()
  Protected mRBX
  !MOV [p.v_mRBX], RBX
EndMacro

Macro ASM_POP_RBX()
   !MOV RBX, [p.v_mRBX]
EndMacro
 
; The LEA instruction: LoadEffectiveAddress of a variable
Macro ASM_PUSH_R10to11(ptrREG)
  Protected R1011.TStack_16Byte
  !LEA ptrREG, [p.v_R1011]        ; RDX = @R1011 = Pionter to RegisterBackupStruct
  !MOV [ptrREG], R10
  !MOV [ptrREG+8], R11
EndMacro

Macro ASM_POP_R10to11(ptrREG)
  !LEA ptrREG, [p.v_R1011]        ; RDX = @R1011 = Pionter to RegisterBackupStruct
  !MOV R10, [ptrREG]
  !MOV R11, [ptrREG+8]
 EndMacro

Macro ASM_PUSH_R12to15(ptrREG)
  Protected R1215.TStack_32Byte
  !LEA ptrREG, [p.v_R1215]        ; RDX = @R1215 = Pionter to RegisterBackupStruct
  !MOV [ptrREG], R12
  !MOV [ptrREG+8], R13
  !MOV [ptrREG+16], R14
  !MOV [ptrREG+24], R15
EndMacro

Macro ASM_POP_R12to15(ptrREG)
  !LEA ptrREG, [p.v_R1215]        ; RDX = @R1215 = Pionter to RegisterBackupStruct
  !MOV R12, [ptrREG]
  !MOV R13, [ptrREG+8]
  !MOV R14, [ptrREG+16]
  !MOV R15, [ptrREG+24]
EndMacro
 
;- ----------------------------------------------------------------------
;- MMX Registers
;- ----------------------------------------------------------------------

; All MMX-Registers are non volatile (shard with FPU-Reisters)
; After the end of use of MMX-Regiters an EMMS Command mus follow to enable
; correct FPU operations again!

Macro ASM_PUSH_MM_0to3(ptrREG)
  Protected M03.TStack_32Byte
  !LEA ptrREG, [p.v_M03]          ; RDX = @M03 = Pionter to RegisterBackupStruct 
  !MOVQ [ptrREG], MM0
  !MOVQ [ptrREG+8], MM1
  !MOVQ [ptrREG+16], MM2
  !MOVQ [ptrREG+24], MM3
EndMacro

Macro ASM_POP_MM_0to3(ptrREG)
  !LEA ptrREG, [p.v_M03]          ; RDX = @M03 = Pionter to RegisterBackupStruct  
  !MOVQ MM0, [ptrREG]
  !MOVQ MM1, [ptrREG+8]
  !MOVQ MM2, [ptrREG+16]
  !MOVQ MM3, [ptrREG+24]
EndMacro

Macro ASM_PUSH_MM_4to5(ptrREG)
  Protected M45.TStack_32Byte
  !LEA ptrREG, [p.v_M45]          ; RDX = @M47 = Pionter to RegisterBackupStruct 
  !MOVQ [ptrREG], MM4
  !MOVQ [ptrREG+8], MM5
EndMacro

Macro ASM_POP_MM_4to5(ptrREG)
  !LEA ptrREG, [p.v_M45]          ; RDX = @M47 = Pionter to RegisterBackupStruct  
  !MOVQ MM4, [ptrREG]
  !MOVQ MM5, [ptrREG+8]
EndMacro

Macro ASM_PUSH_MM_4to7(ptrREG)
  Protected M47.TStack_32Byte
  !LEA ptrREG, [p.v_M47]          ; RDX = @M47 = Pionter to RegisterBackupStruct 
  !MOVQ [ptrREG], MM4
  !MOVQ [ptrREG+8], MM5
  !MOVQ [ptrREG+16], MM6
  !MOVQ [ptrREG+24], MM7
EndMacro

Macro ASM_POP_MM_4to7(ptrREG)
  !LEA ptrREG, [p.v_M47]          ; RDX = @M47 = Pionter to RegisterBackupStruct  
  !MOVQ MM4, [ptrREG]
  !MOVQ MM5, [ptrREG+8]
  !MOVQ MM6, [ptrREG+16]
  !MOVQ MM7, [ptrREG+24]
EndMacro

;- ----------------------------------------------------------------------
;- XMM Registers
;- ----------------------------------------------------------------------

; because of unaligend Memory latency we use 2x64 Bit MOV instead of 1x128 Bit MOV
; MOVDQU [ptrREG], XMM4 -> MOVLPS [ptrREG], XMM4  and  MOVHPS [ptrREG+8], XMM4
; x64 Prozessor can do 2 64Bit Memory transfers parallel

;  XMM4:XMM5 normally are volatile and we do not have to preserve it

; ATTENTION: XMM4:XMM5 must be preserved only when __vectorcall is used
; as I know PB don't use __vectorcall in ASM Backend. But if we use it 
; within a Procedure where __vectorcall isn't used. We don't have to preserve.
; So wee keep the Macro empty. If you want to activate, just activate the code.


Macro ASM_PUSH_XMM_4to5(ptrREG) 
EndMacro

Macro ASM_POP_XMM_4to5(ptrREG)
EndMacro

; Macro ASM_PUSH_XMM_4to5(ptrREG)
;   Protected X45.TStack_32Byte
;   !LEA ptrREG, [p.v_X45]          ; RDX = @X45 = Pionter to RegisterBackupStruct 
;   !MOVLPS [ptrREG], XMM4
;   !MOVHPS [ptrREG+8], XMM4 
;   !MOVLPS [ptrREG+16], XMM5
;   !MOVHPS [ptrREG+24], XMM5
; EndMacro

; Macro ASM_POP_XMM_4to5(ptrREG)
;   !LEA ptrREG, [p.v_X45]          ; RDX = @X45 = Pionter to RegisterBackupStruct
;   !MOVLPS XMM4, [ptrREG]
;   !MOVHPS XMM4, [ptrREG+8]  
;   !MOVLPS XMM5, [ptrREG+16]
;   !MOVHPS XMM5, [ptrREG+24]
; EndMacro
; ======================================================================

Macro ASM_PUSH_XMM_6to7(ptrREG)
  Protected X67.TStack_32Byte
  !LEA ptrREG, [p.v_X67]          ; RDX = @X67 = Pionter to RegisterBackupStruct    
  !MOVLPS [ptrREG], XMM6
  !MOVHPS [ptrREG+8], XMM6 
  !MOVLPS [ptrREG+16], XMM7
  !MOVHPS [ptrREG+24], XMM7
EndMacro

Macro ASM_POP_XMM_6to7(ptrREG)
  !LEA ptrREG, [p.v_X67]          ; RDX = @X67 = Pionter to RegisterBackupStruct  
  !MOVLPS XMM6, [ptrREG]
  !MOVHPS XMM6, [ptrREG+8]
  !MOVLPS XMM6, [ptrREG+16]
  !MOVHPS XMM6, [ptrREG+24]  
EndMacro

; Fast LOAD/SAVE XMM-Register; MOVDQU command for 128Bit has long latency.
; 2 x64Bit loads are faster! Processed parallel in 1 cycle with low or 0 latency
; this optimation is token from AMD code optimation guide
Macro ASM_LD_XMMM(REGX, ptrREG)
  !MOVLPS REGX, [ptrREG]
  !MOVHPS REGX, [ptrREG+8]
EndMacro

Macro ASM_SAV_XMMM(REGX, ptrREG)
  !MOVLPS [ptrREG], REGX
  !MOVHPS [ptrREG+8] + REGX 
EndMacro

;- ----------------------------------------------------------------------
;- YMM Registers
;- ----------------------------------------------------------------------

; for YMM 256 Bit Registes we switch to aligned Memory commands.
; YMM needs 256Bit = 32Byte Align. So wee need 32Bytes more Memory for manual
; align it! We have to ADD 32 to the Adress and than clear the lo 5 bits
; to get an address Align 32

; ATTENTION!  When using YMM-Registers we have to preserve only the lo-parts (XMM-Part)
;             The hi-parts are always volatile. So preserving XMM-Registers is enough!
; Use this Macros only if you want to preserve the complete YMM-Registers for your own purpose!
Macro ASM_PUSH_YMM_4to5(ptrREG)
  Protected Y45.TStack_96Byte ; we need 64Byte and use 96 to get Align 32
  ; Aling Adress to 32 Byte, so we can use Aligend MOV VMOVAPD
  !LEA ptrREG, [p.b_Y45]          ; RDX = @Y45 = Pionter to RegisterBackupStruct
  !ADD ptrREG, 32
  !SHR ptrREG, 5
  !SHL ptrREG, 5
  ; Move the YMM Registers to Memory Align 32
  !VMOVAPD [ptrREG], YMM4
  !VMOVAPD [ptrREG+32], YMM5
EndMacro

Macro ASM_POP_YMM_4to5(ptrREG)
  ; Aling Address @Y45 to 32 Byte, so we can use Aligned MOV VMOVAPD
  !LEA ptrREG, [p.v_Y45]          ; RDX = @Y45 = Pionter to RegisterBackupStruct
  !ADD ptrREG, 32
  !SHR ptrREG, 5
  !SHL ptrREG, 5
  ; POP Registers from Stack
  !VMOVAPD YMM4, [ptrREG]
  !VMOVAPD YMM5, [ptrREG+32]
EndMacro

Macro ASM_PUSH_YMM_6to7(ptrREG)
  Protected Y67.TStack_96Byte ; we need 64Byte an use 96 to get Align 32
  ; Aling Adress to 32 Byte, so we can use Aligend MOV VMOVAPD
  !LEA ptrREG, [p.b_Y67]          ; RDX = @Y67 = Pionter to RegisterBackupStruct
  !ADD ptrREG, 32
  !SHR ptrREG, 5
  !SHL ptrREG, 5
  ; Move the YMM Registers to Memory Align 32
  !VMOVAPD [ptrREG], YMM6
  !VMOVAPD [ptrREG+32], YMM7
EndMacro

Macro ASM_POP_YMM_6to7(ptrREG)
  ; Aling Adress @Y67 to 32 Byte, so we can use Aligned MOV VMOVAPD
  !LEA ptrREG, [p.v_Y67]          ; RDX = @Y67 = Pionter to RegisterBackupStruct
  !ADD ptrREG, 32
  !SHR ptrREG, 5
  !SHL ptrREG, 5
  ; POP Registers from Stack
  !VMOVAPD YMM6, [ptrREG]
  !VMOVAPD YMM7, [ptrREG+32]
EndMacro

;- ----------------------------------------------------------------------
;- Load/Save Registers from/to Value or Pointer
;- ----------------------------------------------------------------------

; Attention! This Macros only work only when called inside a Procedure
; because we use Procedure Prefix for the variables in ASM p.v_ p.p.
Macro ASM_LoadReg_Val(REG, Val)
  !MOV REG, [p.v_#Val] 
EndMacro

Macro ASM_SaveReg_Val(REG, Val)
  !MOV [p.v_#Val], REG 
EndMacro

Macro ASM_LoadReg_Ptr(REG, ptrVar)
  !MOV REG, [p.p_#ptrVar]  
EndMacro

Macro ASM_SaveReg_Ptr(REG, ptrVar)
  !MOV [p.p_#ptrVar], REG  
EndMacro

; SSE Extention Functions
; MOVDQU := MoveDQuadUnalingned
Macro ASM_LoadXMM(REG_XMM, ptrVar, _REGA=RAX)
  !MOV _REGA, [p.p_#ptrVar]
  !MOVDQU REG_XMM, [RAX]
EndMacro

Macro ASM_SaveXMM(REG_XMM, ptrVar, _REGA=RAX)
  !MOV _REGA, [p.p_#ptrVar]
  !MOVDQU [_REGA], REG_XMM
EndMacro

;- ----------------------------------------------------------------------
;- Vector PackedSingle ADD, SUB, MUL, DIV
;- ----------------------------------------------------------------------

; SSE Extention Functions

Macro ASM_Vec4Add_PS(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !ADDPS _XMMA, _XMMB       ; Add packed single float
EndMacro

Macro ASM_Vec4Sub_PS(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !SUBPS _XMMA, _XMMB       ; Sub packed single float
EndMacro

Macro ASM_Vec4Mul_PS(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !MULPS _XMMA, _XMMB       ; Mul packed single float
EndMacro

Macro ASM_Vec4Div_PS(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !DIVPS _XMMA, _XMMB
EndMacro

Macro ASM_Vec4Min_PS(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !MINPS _XMMA, _XMMB       ; Minimum of packed single float
EndMacro

Macro ASM_Vec4Max_PS(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !MAXPS _XMMA, _XMMB       ; Maximum of packed single float
EndMacro

;- ----------------------------------------------------------------------
;- Vector PackedDoubleWord ADD, SUB, MUL
;- ----------------------------------------------------------------------

; SSE Extention Functions

Macro ASM_Vec4Add_PDW(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !PADDW _XMMA, _XMMB
EndMacro

Macro ASM_Vec4Sub_PDW(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !PSUBDW _XMMA, _XMMB       ; Subtract packed DoubleWord integers
EndMacro

Macro ASM_Vec4Mul_PDW(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !PMULDQ _XMMA, _XMMB      ; Multiply packed DoubleWord Integers
EndMacro

; A PDIVDQ to devide packed Doubleword Integers do not exixt because of the CPU cycles are depending on the operands 

Macro ASM_Vec4Min_PDW(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !PMINSD _XMMA, _XMMB      ; Minimum of signed packed Doubleword Integers
EndMacro

Macro ASM_Vec4Max_PDW(ptrVec1, ptrVec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  !MOV _REGA, [p.p_#ptrVec1]  
  !MOV _REGD, [p.p_#ptrVec2]  
  !MOVDQU _XMMA, [_REGA]
  !MOVDQU _XMMB, [_REGD]
  !PMAXSD _XMMA, _XMMB      ; Maximum of signed packed Doubleword Integers
EndMacro


; Debug ASM_Reg2Pointer(myptr, RAX)

; Debug ASM_VecMul_PDW(In1, In2)


; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 496
; FirstLine = 433
; Folding = --------
; Optimizer
; CPU = 5