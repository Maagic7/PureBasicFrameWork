; ===========================================================================
;  FILE : PbFw_ASM_Macros.pbi
;  NAME : Collection of Assembler Macros for SIMD SSE instructions
;  DESC : Since PB has a C-Backend, Assembler Code in PB only make sens if
;  DESC : it is used for SIMD instructions. Generally SIMD is suitable for all vector 
;  DESC : arithmetics like 3D Grafics, Color operations, Complex number arithmetic.
;  DESC : This Library provides a general basic set of Macros for SIMD vector operations.
;  DESC : for 2D and 4D Datas. Furthermore the necessary Macros for preserving non volatile 
;  DESC : Registers.
;  DESC : Macros for PUSH, POP MMX and XMM Registers 
;  DESC : Macros for SIMD .Vector4 functions using SSE-Commands
;  DESC : Macros for SIMD .Vector2 functions using SSE-Commands
;  DESC : The Macros now work inside and outside of Procedures, but need EnableASM Statment
;  DESC : The Macros are Structure Name independet. A fixed Data defintion is used but
;  DESC : we can pass any Structure to it whitout Name checking. So it does not matter if we
;  DESC : use the PB .Vector4 or our own Structure what implements the 4 floats (like 'VECf' from Vector Module) 
;  SOURCES:
;   A full description of the Intel Assembler Commands
;   https://hjlebbink.github.io/x86doc/

; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/02/04
; VERSION  :  0.62 Developer Version
; COMPILER :  PureBasic 6.0+
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{
; 2025/12/27 S.Maag : Macro for creating BitMaskBytes()
; 2025/11/20 S.Maag : Added Matrix and Vector Multiplication

; 2025/11/15 S.Maag : Solved problem loading VectorPointerToRegister inside and outside a Procedure.
;                     see https://www.purebasic.fr/english/viewtopic.php?t=87903
;                     added more functions for VEC2d (2 packed doubles). 

; 2025/11/14 S.Maag : I run into some practial conflicts.
;                     - somtimes for 2D coordinates it is not suitable to use 4D coordinates.
;                       Because of that I added the 2 dimenional SSE Commands for double floats.
;                     - Naming convention: SIMD SSE vector functions MUL/DIV... are not the same as 
;                       mathematical correct Vector MUL/DIV. Because of that I changed the naming 
;                       to exactly what it is: SIMD (Single Instruction Multiple Data)
;                       Like ASM_Vec4_ADD_PS -> ASM_SIMD_ADD_4PS (SIMD ADD 4 packed single)

; 2025/11/13 S.Maag : modified Macros to use inside and outside Procedures
;                     This is possible with the PB ASM preprocessor (EnableAsm).
;                     Changed the register loads form !MOV REG, [p.v_var] to MOV REG, var
;                     Added _VectorPointerToREG Macro to handle *vec or vec automatically.

; 2025/11/12 S.Maag : added/changed some comments. Repaired bugs in XMM functions.
;                     For Vector4 Functions we have to determine the VarType of the 
;                     Vector4 Structure: #ASM_VAR or #ASM_PTR. Need LEA command vor #ASM_VAR
;                     and MOV command for #ASM_PTR

; 2024/08/01 S.Maag : added Register Load/Save Macros and Vector Macros
;                     for packed SingleFloat and packed DoubleWord
;}
;{ TODO:
; - Add Funtions for 4D Double Float Vetors. But this is a little bit more complicated as it seems.
;   For the 4D Double we have to change to 256-Bit YMM-Registers. That are the commands in the SSE instruction
;   with the 'V' as prefix like VMAXPD. But 256 Bit instructions with 'V' has different functions compared to
;   the 128 Bit instructions. So first a exact study of the documentation is needed.

; - Add Functions for fast SIMD Color operations

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
; PSHUFB          : SSE2  : Packed Shuffle Bytes !
; PSHUFW          : SSE2  : Packed Shuffle Words !
; PSHUFLW         : SSE2  : Shuffle Packed Low Words
; PSHUFHW         : SSE2  : Shuffle Packed High Words
; PSHUFD          : SSE2  : Packed Shuffle DoulbeWords !
; PEXTR[B/W/D/Q]  : SSE4.1 : PEXTRB RAX, XMM0, 1 : loads Byte 1 of XMM0[Byte 0..7] 
; PINSR[B/W/D/Q]  : SSE4.1 : PINSRB XMM0, RAX, 1 : transfers RAX LoByte to Byte 1 of XMM0 
; PCMPESTRI       : SSE4.2 : Packed Compare Implicit Length Strings, Return Index
; PCMPISTRM       : SSE4.2 : Packed Compare Implicit Length Strings, Return Mask

;- ----------------------------------------------------------------------
;- NaN Value 32/64 Bit
; #Nan32 = $FFC00000            ; Bit representaion for the 32Bit Float NaN value
; #Nan64 = $FFF8000000000000    ; Bit representaion for the 64Bit Float NaN value
;  ----------------------------------------------------------------------

; --------------------------------------------------
; Assembler Datasection Definition
; --------------------------------------------------
; db 	Define Byte = 1 byte
; dw 	Define Word = 2 bytes
; dd 	Define Doubleword = 4 bytes
; dq 	Define Quadword = 8 bytes
; dt 	Define ten Bytes = 10 bytes
; !label: dq 21, 22, 23
; --------------------------------------------------

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

Macro AsmCodeIsInProc
  Bool(#PB_Compiler_Procedure <> #Null$)  
EndMacro

; create a BitMask for full Bytes 
; Load the number of Bytes first in _REG
; The BitMask is returned in _REG
; No of Bytes 0..7
; with 1 in RAX you get FF; with 2 in RAX you get FFFF ...
; use it for create a blending mask for the last Bytes of a String or Buffer
Macro CreateBitMaskBytes(_REG=RAX)
  !MOV RCX, _REG
  !XOR _REG, _REG
  !SHL RCX, 3
  !TEST RCX, RCX
  !JZ @f
    !DEC RCX
    !MOV _REG, 1
    !SHL _REG, CL 
    !BLSMSK _REG, _REG    ; Get Mask Up to Lowest Set Bit
  !@@:
EndMacro

;- ----------------------------------------------------------------------
;- CPU Registers
;- ----------------------------------------------------------------------

; seperate Macros for EBX/RBX because this is often needed expecally for x32
; It is not real a PUSH/POP it is more a SAVE/RESTORE!

; ATTENTION! Use EnableAsm in your code before using the Macros
; By using the PB ASM preprocessor and the Define Statement instead of Protected
; we can use the Macros now inside and outside a Procedure.
; Inside a Procedure PB handels Define and Proteced in the same way.
Macro ASM_PUSH_EBX()
  Define mEBX  
  MOV mEBX, EBX
  ; !MOV [p.v_mEBX], EBX
EndMacro

Macro ASM_POP_EBX()
  MOV EBX, mEBX
  ; !MOV EBX, [p.v_mEBX]
EndMacro

Macro ASM_PUSH_RBX()
  Define mRBX
  MOV mRBX, RBX
  ; !MOV [p.v_mRBX], RBX
EndMacro

Macro ASM_POP_RBX()
  MOV RBX, mRBX
  ;!MOV RBX, [p.v_mRBX]
EndMacro
 
; The LEA instruction: LoadEffectiveAddress of a variable
Macro ASM_PUSH_R10to11(_REG=RDX)
  Define R1011.TStack_16Byte
  LEA _REG, R1011
  ;!LEA _REG, [p.v_R1011]        ; RDX = @R1011 = Pionter to RegisterBackupStruct
  !MOV [_REG], R10
  !MOV [_REG+8], R11
EndMacro

Macro ASM_POP_R10to11(_REG=RDX)
  LEA _REG, R1011
  ; !LEA _REG, [p.v_R1011]        ; RDX = @R1011 = Pionter to RegisterBackupStruct
  !MOV R10, [_REG]
  !MOV R11, [_REG+8]
EndMacro

Macro ASM_PUSH_R12to15(_REG=RDX)
  Define R1215.TStack_32Byte
  LEA _REG, R1215
  ; !LEA _REG, [p.v_R1215]        ; RDX = @R1215 = Pionter to RegisterBackupStruct
  !MOV [_REG], R12
  !MOV [_REG+8], R13
  !MOV [_REG+16], R14
  !MOV [_REG+24], R15
EndMacro

Macro ASM_POP_R12to15(_REG=RDX)
  LEA _REG, R1215
  ; !LEA _REG, [p.v_R1215]        ; RDX = @R1215 = Pionter to RegisterBackupStruct
  !MOV R12, [_REG]
  !MOV R13, [_REG+8]
  !MOV R14, [_REG+16]
  !MOV R15, [_REG+24]
EndMacro
 
;- ----------------------------------------------------------------------
;- MMX Registers (on x64 don't use MMX-Registers! XMM is the better!
;- ----------------------------------------------------------------------

; All MMX-Registers are non volatile (shard with FPU-Reisters)
; After the end of use of MMX-Regiters an EMMS Command mus follow to enable
; correct FPU operations again!

Macro ASM_PUSH_MM_0to3(_REG=RDX)
  Define M03.TStack_32Byte
  LEA _REG, M03
  ; !LEA _REG, [p.v_M03]          ; RDX = @M03 = Pionter to RegisterBackupStruct 
  !MOVQ [_REG], MM0
  !MOVQ [_REG+8], MM1
  !MOVQ [_REG+16], MM2
  !MOVQ [_REG+24], MM3
EndMacro

Macro ASM_POP_MM_0to3(_REG=RDX)
  LEA _REG, M03
  ; !LEA _REG, [p.v_M03]          ; RDX = @M03 = Pionter to RegisterBackupStruct  
  !MOVQ MM0, [_REG]
  !MOVQ MM1, [_REG+8]
  !MOVQ MM2, [_REG+16]
  !MOVQ MM3, [_REG+24]
EndMacro

Macro ASM_PUSH_MM_4to5(_REG=RDX)
  Define M45.TStack_32Byte
  LEA _REG, M45
  ; !LEA _REG, [p.v_M45]          ; RDX = @M47 = Pionter to RegisterBackupStruct 
  !MOVQ [_REG], MM4
  !MOVQ [_REG+8], MM5
EndMacro

Macro ASM_POP_MM_4to5(_REG=RDX)
  LEA _REG, M45
  ;!LEA _REG, [p.v_M45]          ; RDX = @M47 = Pionter to RegisterBackupStruct  
  !MOVQ MM4, [_REG]
  !MOVQ MM5, [_REG+8]
EndMacro

Macro ASM_PUSH_MM_4to7(_REG=RDX)
  Define M47.TStack_32Byte
  LEA _REG, M47
  ; !LEA _REG, [p.v_M47]          ; RDX = @M47 = Pionter to RegisterBackupStruct 
  !MOVQ [_REG], MM4
  !MOVQ [_REG+8], MM5
  !MOVQ [_REG+16], MM6
  !MOVQ [_REG+24], MM7
EndMacro

Macro ASM_POP_MM_4to7(_REG=RDX)
  LEA _REG, M47
  ;!LEA _REG, [p.v_M47]          ; RDX = @M47 = Pionter to RegisterBackupStruct  
  !MOVQ MM4, [_REG]
  !MOVQ MM5, [_REG+8]
  !MOVQ MM6, [_REG+16]
  !MOVQ MM7, [_REG+24]
EndMacro

;- ----------------------------------------------------------------------
;- XMM Registers
;- ----------------------------------------------------------------------

; because of unaligend Memory latency we use 2x64 Bit MOV instead of 1x128 Bit MOV
; MOVDQU [ptrREG], XMM4 -> MOVLPS [ptrREG], XMM4  and  MOVHPS [ptrREG+8], XMM4
; x64 Prozessor can do 2 64Bit Memory transfers parallel

; XMM4:XMM5 normally are volatile and we do not have to preserve it

; ATTENTION: XMM4:XMM5 must be preserved only when __vectorcall is used
; as I know PB don't use __vectorcall in ASM Backend. But if we use it 
; within a Procedure where __vectorcall isn't used, we don't have to preserve.
; So wee keep the Macro empty. If you want to activate, just activate the code.


Macro ASM_PUSH_XMM_4to5(_REG=RDX) 
EndMacro

Macro ASM_POP_XMM_4to5(_REG=RDX)
EndMacro

; Macro ASM_PUSH_XMM_4to5(REG=RDX)
;   Define X45.TStack_32Byte
;   LEA REG, X45
;   ; !LEA REG, [p.v_X45]          ; RDX = @X45 = Pionter to RegisterBackupStruct 
;   !MOVDQU [REG], XMM4
;   !MOVDQU [REG+16], XMM5
; EndMacro

; Macro ASM_POP_XMM_4to5(REG)
;   LEA REG, X45
;   ; !LEA REG, [p.v_X45]          ; RDX = @X45 = Pionter to RegisterBackupStruct
;   !MOVDQU XMM4, [REG]
;   !MOVDQU XMM5, [REG+16]
; EndMacro
; ======================================================================

Macro ASM_PUSH_XMM_6to7(_REG=RDX)
  Define X67.TStack_32Byte
  LEA _REG, X67
  ; !LEA _REG, [p.v_X67]          ; RDX = @X67 = Pionter to RegisterBackupStruct    
  !MOVDQU [_REG], XMM6
  !MOVDQU [_REG+16], XMM7
EndMacro

Macro ASM_POP_XMM_6to7(_REG=RDX)
  LEA _REG, X67
  ;!LEA _REG, [p.v_X67]          ; RDX = @X67 = Pionter to RegisterBackupStruct  
  !MOVDQU XMM6, [_REG]
  !MOVDQU XMM7, [_REG+16]
 EndMacro
 
 Macro ASM_PUSH_XMM_6to9(_REG=RDX)
  Define X89.TStack_64Byte
  LEA _REG, X69
  ; !LEA _REG, [p.v_X69]          ; RDX = @X69 = Pionter to RegisterBackupStruct    
  !MOVDQU [_REG], XMM6
  !MOVDQU [_REG+16], XMM7
  !MOVDQU [_REG+32], XMM8
  !MOVDQU [_REG+48], XMM9
EndMacro

Macro ASM_POP_XMM_6to9(_REG=RDX)
  LEA _REG, X69
  ;!LEA _REG, [p.v_X69]          ; RDX = @X69 = Pionter to RegisterBackupStruct  
  !MOVDQU XMM6, [_REG]
  !MOVDQU XMM7, [_REG+16]
  !MOVDQU XMM8, [_REG+32]
  !MOVDQU XMM9, [_REG+48]
 EndMacro

;- ----------------------------------------------------------------------
;- YMM Registers
;- ----------------------------------------------------------------------

; for YMM 256 Bit Registes we switch to aligned Memory commands (much faster than unaligned)
; YMM needs 256Bit = 32Byte Align. So wee need 32Bytes more Memory for manual
; align it! We have to ADD 32 to the Adress and than clear the lo 5 bits
; to get an address Align 32

; ATTENTION!  When using YMM-Registers we have to preserve only the lo-parts (XMM-Part)
;             The hi-parts are always volatile. So preserving XMM-Registers is enough!
; Use this Macros only if you want to preserve the complete YMM-Registers for your own purpose!
Macro ASM_PUSH_YMM_4to5(_REG=RDX)
  Define Y45.TStack_96Byte ; we need 64Byte and use 96 to get Align 32
  ; Aling Adress to 32 Byte, so we can use Aligend MOV VMOVAPD
  LEA _REG, Y45
  ; !LEA _REG, [p.b_Y45]          ; RDX = @Y45 = Pionter to RegisterBackupStruct
  !ADD _REG, 32
  !SHR _REG, 5
  !SHL _REG, 5
  ; Move the YMM Registers to Memory Align 32
  !VMOVAPD [_REG], YMM4
  !VMOVAPD [_REG+32], YMM5
EndMacro

Macro ASM_POP_YMM_4to5(_REG=RDX)
  ; Aling Address @Y45 to 32 Byte, so we can use Aligned MOV VMOVAPD
  LEA _REG, Y45
  ;!LEA _REG, [p.v_Y45]          ; RDX = @Y45 = Pionter to RegisterBackupStruct
  !ADD _REG, 32
  !SHR _REG, 5
  !SHL _REG, 5
  ; POP Registers from Stack
  !VMOVAPD YMM4, [_REG]
  !VMOVAPD YMM5, [_REG+32]
EndMacro

Macro ASM_PUSH_YMM_6to7(_REG=RDX)
  Define Y67.TStack_96Byte ; we need 64Byte an use 96 to get Align 32
  ; Aling Adress to 32 Byte, so we can use Aligend MOV VMOVAPD
  LEA _REG, Y67
  ; !LEA _REG, [p.b_Y67]          ; RDX = @Y67 = Pionter to RegisterBackupStruct
  !ADD _REG, 32
  !SHR _REG, 5
  !SHL _REG, 5
  ; Move the YMM Registers to Memory Align 32
  !VMOVAPD [_REG], YMM6
  !VMOVAPD [_REG+32], YMM7
EndMacro

Macro ASM_POP_YMM_6to7(_REG=RDX)
  ; Aling Adress @Y67 to 32 Byte, so we can use Aligned MOV VMOVAPD
  LEA _REG, Y67
  ; !LEA PtrREG, [p.v_Y67]          ; RDX = @Y67 = Pionter to RegisterBackupStruct
  !ADD _REG, 32
  !SHR _REG, 5
  !SHL _REG, 5
  ; POP Registers from Stack
  !VMOVAPD YMM6, [_REG]
  !VMOVAPD YMM7, [_REG+32]
EndMacro

;- ----------------------------------------------------------------------
;- Load/Save Registers from/to Value or Pointer
;- ----------------------------------------------------------------------

; This Macros are just to have a template for the correct code!
; 
; Load a Register with a variable
Macro ASM_LD_REG_Var(_REG, var)
  MOV _REG, var
  ; !MOV _REG, [p.v_#var] 
EndMacro

; Save Register to variable 
Macro ASM_SAV_REG_Var(_REG, var)
  MOV var, _REG
  ; !MOV [p.v_#var], _REG 
EndMacro

; load the Register with the Pointer of a var : REG=@var
Macro ASM_LD_REG_VarPtr(var, _REG=RDX)
  LEA _REG, var      
  ; !LEA _REG, [p.v_#var]      
EndMacro

; ----------------------------------------------------------------------
; Load the Pointer of a VectorStructure to a Register
; ----------------------------------------------------------------------
; SizeOf(StructureVar) = 16  SizeOf(StructurePointer = 8)
; TypeOf(StructureVar) = 7   TypeOf(StructurePointer = 7) -> TypeOf do not work!

; If _vector_ is a PointerToVector we have to use : MOV MOV REG, _vector_
; If _vector_ is the Structure we have to use     : LEA REG, _vector_  ; LoadEffectiveAddress
; The problme solved: are mixed calls with PointerOfVector and VectorVar.

; This example Proc shows the Problem!
; Procedure VecTest(*InVec.Vector4)
;   Protected v.Vector4, res.Vector4 
;   v\x = 1.0 : v\y = 1.0 : v\z = 1.0 : v\w = 0.0 
;   
;   ASM_Vec4Add_PS(*InVec, v) ; Now this is possible because of autodetect Pointer or var by the compiler
;   
; EndProcedure

Macro ASM_LD_REG_VecPtr(_REG_, _vector_)
  CompilerIf #PB_Compiler_Procedure <> #Null$
    CompilerIf SizeOf(_vector_)=SizeOf(Integer)
      MOV _REG_, _vector_
    CompilerElse
      LEA _REG_, _vector_
    CompilerEndIf
  CompilerElse
    MOV _REG_, _vector_
  CompilerEndIf
EndMacro

; ----------------------------------------------------------------------
; Lo latency LOAD/SAVE 128 Bit XMM-Register
; ----------------------------------------------------------------------
; MOVDQU command for 128Bit has long latency.
; 2 x64Bit loads are faster! Processed parallel in 1 cycle with low or 0 latency
; This optimation is token from AMD code optimation guide.
; (for 2020+ Processors like AMD Ryzen it does not matter, because Ryzen can load
; (128 Bit at same speed as 2x64Bit. For older Processors 2x 64Bit load is faster)

; With new Processors sometimes the best way how to load SSE Registers change. Using
; a Macro makes it easy to adapt. 

; ---------------------------------
; Zen3     Reg.   Lateny  Recipr.
; ---------------------------------
; MOVUPS   x,m128   4       0.5   SSE
; MOVDQU   x,m128   4       0.5   SSE2     
; MOVLPS   x,m64    5       0.5   SSE   ; On Ryzen seems to be better. My test shwos that's true 

; ATTENTION! You have to load the MemoryPointer to REG first

; _XMM : The XMM Register to load with 16 Byte Data from Memory
; _REG : The Register containing the Pointer to the Memory
Macro ASM_LD_XMM(_XMM=XMM0, _REG=RDX)
  !MOVDQU _XMM, [_REG]    
EndMacro
; !MOVLPS _XMM, [_REG]
; !MOVHPS _XMM, [_REG+8]
; or
; !MOVDQU _XMM, [_REG]    ; alternative 128Bit direct load DQU
; or
; !MOVUPS _XMM, [_REG]    ; alternative 128Bit direct load UPS

Macro ASM_SAV_XMM(_XMM=XMM0, _REG=RDX)
  !MOVDQU [_REG], _XMM  
EndMacro

; Load a 32Bit value with Shuffle to XMM. Shuffle the value to all 4 components of XMM
Macro ASM_LDx32_SHUF_XMM(var32, _XMM=XMM0, _REG=RDX)
  MOV _REG, DWORD var32
  !MOVQ _XMM, _REG  
  !PSHUFD _XMM, _XMM, 0
EndMacro

Macro ASM_LDx64_XMM(var64, _XMM=XMM0, _REG=RDX)
  MOV _REG, var64
  !MOVQ _XMM, _REG  
EndMacro

; _YMM : The YMM Register to load with 32Byte Data from Memory
; _REG : The Register containing the Pointer to the Memory

Macro ASM_LD_YMM(_YMM=YMM0, _REG=RDX)
  !VMOVUPD _YMM, [_REG]    
EndMacro

Macro ASM_SAV_YMM(_YMM=YMM0, _REG=RDX)
  !VMOVUPD [_REG], _YMM  
EndMacro

Macro ASM_SHUFD_YMM(_YMM=YMM0, imm8=0)
  !VPSHUFD YMM0, YMM0, imm8
EndMacro

; Load a 64Bit value to YMM0 and Shuffle it to all 4 components of YMM
Macro ASM_LDx64_SHUF_YMM0(var64, _REG=RDX)
  MOV _REG, var64
  !MOVQ XMM0, _REG 
  !VPSHUFD YMM0, YMM0, 0
EndMacro

; ----------------------------------------------------------------------

;- ----------------------------------------------------------------------
;- Vec4 PS PackedSingle (4x32Bit Float Vectors)
;- ----------------------------------------------------------------------

; use to speed up standard 3D Grafics with SSE 

; Vector4 is a predefined Structure in PB
;   Structure Vector4
;     x.f
;     y.f
;     z.f
;     w.f
;   EndStructure 

; SSE Extention Functions

; 2025/11/13 : Changed form direct 128Bit loads to 2x 64Bit loads because of high latency of 
;              unaligned 128 Bit loads (MOVDQU) on older processor. Now use Macro ASM_LD_XMM instead of MOVDQU

; 4PS := 4 packed single (32Bit)

; _XMMA = _vec1 + _vec2
Macro ASM_SIMD_ADD_4PS(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !ADDPS _XMMA, _XMMB       ; Add packed single float
EndMacro

; _XMMA = _vec1 - _vec2
Macro ASM_SIMD_SUB_4PS(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !SUBPS _XMMA, _XMMB       ; Sub packed single float
EndMacro

; _XMMA = _vec1 * _vec2
Macro ASM_SIMD_MUL_4PS(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !MULPS _XMMA, _XMMB       ; Mul packed single float
EndMacro

; _XMMA = _vec1 / _vec2
Macro ASM_SIMD_DIV_4PS(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !DIVPS _XMMA, _XMMB
EndMacro

; _XMMA\x = Min(_vec1\x _vec2\x) : _XMMA\y = Min(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MIN_4PS(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !MINPS _XMMA, _XMMB       ; Minimum of packed single float
EndMacro

; _XMMA\x = Max(_vec1\x, _vec2\x) : _XMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MAX_4PS(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !MAXPS _XMMA, _XMMB       ; Maximum of packed single float
EndMacro

; _XMMA\x = Min(_vec1\x _vec2\x) : _XMMA\y = Min(_vec1\y, _vec2\y) ...
; _XMMB\x = Max(_vec1\x, _vec2\x) : _XMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MinMax_4PS(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _XMMC=XMM2, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD)
  !MOVDQA _XMMC, _XMMA
  !MINPS _XMMA, _XMMB        
  !MAXPS _XMMB, _XMMC
EndMacro

; _XMMA=SQRT(_vec)
Macro ASM_SIMD_SQRT_4PS(_vec, _XMM=XMM0, _REG=RDX)
  ASM_LD_REG_VecPtr(_REG, _vec)
  ASM_LD_XMM(_XMM, _REG)
  !SQRTPS _XMM, _XMM
EndMacro

; Cross Product AxB
; ----------------------------------------
; Cx = Ay*Bz - Az*By : C1 = A2*B3 - A3*B2
; Cy = Az*Bx - Ax*Bz : C2 = A3*B1 - A1*B3
; Cz = Ax*By - Ay*Bx : C3 = A1*B2 - A2*B1
; ----------------------------------------

; XMM0 = CrossProduct(_vec1, _vec2) ; use XMM0..3
Macro ASM_CrossProduct_4PS(_vec1, _vec2, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(XMM0, _REGA)
  ASM_LD_XMM(XMM1, _REGD) 
	!MOVAPS XMM2, XMM0
	!MOVAPS XMM3, XMM1
	!SHUFPS XMM0, XMM0, 11001001b ; 3-0-2-1
	!SHUFPS XMM1, XMM1, 11010010b ; 3-1-0-2
	!SHUFPS XMM2, XMM2, 11010010b 
	!SHUFPS XMM3, XMM3, 11001001b 
	!MULPS  XMM0, XMM1
	!MULPS  XMM2, XMM3
	!SUBPS  XMM0, XMM2
EndMacro

; REGA = DotProduct(_vec1, _vec2) : res=x1*x2+y1*y2+z1*z2+w1*w2
Macro ASM_DotProduct_4PS(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(XMM0, _REGA)
  ASM_LD_XMM(XMM1, _REGD)
  !MULPS _XMMA, _XMMB
  !HADDPS _XMMA, _XMMA
  !HADDPS _XMMA, _XMMA  
  !MOVQ _REGA, _XMMA
EndMacro

;- ----------------------------------------------------------------------
;- Vec4 PDW : PackedDoubleWord (4x32Bit Int Vectors)
;- ----------------------------------------------------------------------

;   Structure Vector4L    ; This is not predefined in PB
;     x.l
;     y.l
;     z.l
;     w.l
;   EndStructure 

; SSE Extention Functions
; use for direct Integer Pixel postion calculations 

; 4PDW := 4 packed double words (32Bit)
; _XMMA = _vec1 + _vec2
Macro ASM_SIMD_ADD_4PDW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PADDQ _XMMA, _XMMB
EndMacro

; _XMMA = _vec1 - _vec2
Macro ASM_SIMD_SUB_4PDW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PSUBDQ _XMMA, _XMMB       ; Subtract packed DoubleWord integers
EndMacro

; _XMMA = _vec1 * _vec2
Macro ASM_SIMD_MUL_4PDW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PMULDQ _XMMA, _XMMB      ; Multiply packed DoubleWord Integers 
EndMacro

; A PDIVDQ to devide packed Doubleword Integers do not exist because of the CPU cycles are depending on the operands 

; _XMMA\x = Min(_vec1\x _vec2\x) : _XMMA\y = Min(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MIN_4PDW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PMINSQ _XMMA, _XMMB      ; Minimum of signed packed Doubleword Integers
EndMacro

; _XMMA\x = Max(_vec1\x, _vec2\x) : _XMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MAX_4PDW(_vec1, _vec2,  _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PMAXSQ _XMMA, _XMMB      ; Maximum of signed packed Doubleword Integers
EndMacro

; _XMMA\x = Min(_vec1\x _vec2\x) : _XMMA\y = Min(_vec1\y, _vec2\y) ...
; _XMMB\x = Max(_vec1\x, _vec2\x) : _XMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MinMax_4PDW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _XMMC=XMM2, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD)
  !MOVDQA _XMMC, _XMMA
  !PMINSQ _XMMA, _XMMB        
  !PMAXSQ _XMMB, _XMMC
EndMacro

; REGA = DotProduct(_vec1, _vec2) : res=x1*x2+y1*y2+z1*z2+w1*w2
Macro ASM_DotProduct_4PDW(_vec1, _vec2, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(XMM0, _REGA)
  ASM_LD_XMM(XMM1, _REGD)
  !PMULDQ _XMMA, _XMMB
  !PHADDD  _XMMA, _XMMA
  !PHADDD  _XMMA, _XMMA  
  !MOVQ _REGA, _XMMA
EndMacro

;- ----------------------------------------------------------------------
;- Vec4 PD PackedDouble (4x64Bit double float Vectors)
;- ----------------------------------------------------------------------

;   Structure Vector4d    ; This is not predefined in PB
;     x.d
;     y.d
;     z.d
;     w.d
;   EndStructure 

; SSE Extention Functions
; use for direct Integer Pixel postion calculations 

; 4PD := 4 packed double floads (64Bit)
; _YMMA = _vec1 + _vec2
Macro ASM_SIMD_ADD_4PD(_vec1, _vec2, _YMMA=YMM0, _YMMB=YMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_YMM(_YMMA, _REGA)
  ASM_LD_YMM(_YMMB, _REGD) 
  !VADDPD _YMMA, _YMMA, _YMMB
EndMacro

; _YMMA = _vec1 - _vec2
Macro ASM_SIMD_SUB_4PD(_vec1, _vec2, _YMMA=YMM0, _YMMB=YMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_YMM(_YMMA, _REGA)
  ASM_LD_YMM(_YMMB, _REGD) 
  !VSUBPD _YMMA, _YMMA, _YMMB
EndMacro

; _YMMA = _vec1 * _vec2
Macro ASM_SIMD_MUL_4PD(_vec1, _vec2, _YMMA=YMM0, _YMMB=YMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_YMM(_YMMA, _REGA)
  ASM_LD_YMM(_YMMB, _REGD) 
  !VMULPD _YMMA, _YMMA, _YMMB
EndMacro

; _YMMA = _vec1 / _vec2
Macro ASM_SIMD_DIV_4PD(_vec1, _vec2, _YMMA=YMM0, _YMMB=YMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_YMM(_YMMA, _REGA)
  ASM_LD_YMM(_YMMB, _REGD) 
  !VDIVPD _YMMA, _YMMA, _YMMB
EndMacro

; _YMMA\x = Min(_vec1\x _vec2\x) : _YMMA\y = Min(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MIN_4PD(_vec1, _vec2, _YMMA=YMM0, _YMMB=YMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_YMM(_YMMA, _REGA)
  ASM_LD_YMM(_YMMB, _REGD) 
  !VMINPD _YMMA, _YMMA, _YMMB
EndMacro

; _AMMA\x = Max(_vec1\x, _vec2\x) : _YMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MAX_4PD(_vec1, _vec2,  _YMMA=YMM0, _YMMB=YMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)
  ASM_LD_YMM(_YMMA, _REGA)
  ASM_LD_YMM(_YMMB, _REGD) 
  !VMAXPD  _YMMA, _YMMA, _YMMB    
EndMacro

; _YMMA\x = Min(_vec1\x _vec2\x)  : _YMMA\y = Min(_vec1\y, _vec2\y) ...
; _YMMB\x = Max(_vec1\x, _vec2\x) : _YMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MinMax_4PD(_vec1, _vec2, _YMMA=YMM0, _YMMB=YMM1, _YMMC=YMM2, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_YMM(_YMMB, _REGA)
  ASM_LD_YMM(_YMMC, _REGD)
  !VMINPD _YMMA, _YMMB, _YMMC
  !VMAXPD _YMMB, _YMMB, _YMMC    
 EndMacro

; _YMMA=SQRT(_vec)
Macro ASM_SIMD_SQRT_4PD(_vec, _YMM=YMM0, _REG=RDX)
  ASM_LD_REG_VecPtr(_REG, _vec)
  ASM_LD_YMM(_YMM, _REG)
  !VSQRTPD _XMM, _XMM
EndMacro

;- ----------------------------------------------------------------------
;- Vec2 PD PackedDouble (2x64Bit Double Vectors)
;- ----------------------------------------------------------------------

; use for 2D Double Float coordinates and Complex Number math

; 2PD := 2 packed double (64Bit)
; _XMMA = _vec1 + _vec2
Macro ASM_SIMD_ADD_2PD(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !ADDPD _XMMA, _XMMB       ; Add packed double float
EndMacro

; _XMMA = _vec1 - _vec2
Macro ASM_SIMD_SUB_2PD(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !SUBPD _XMMA, _XMMB       ; Sub packed double float
EndMacro

; _XMMA = _vec1 * _vec2
Macro ASM_SIMD_MUL_2PD(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !MULPD _XMMA, _XMMB       ; Mul packed double float
EndMacro

; _XMMA = _vec1 / _vec2
Macro ASM_SIMD_DIV_2PD(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !DIVPD _XMMA, _XMMB
EndMacro

; _XMMA\x = Min(_vec1\x _vec2\x) : _XMMA\y = Min(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MIN_2PD(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !MINPD _XMMA, _XMMB       ; Minimum of packed double float
EndMacro

; _XMMA\x = Max(_vec1\x, _vec2\x) : _XMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MAX_2PD(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !MAXPD _XMMA, _XMMB       ; Maximum of packed double float
EndMacro

; _XMMA\x = Min(_vec1\x _vec2\x) : _XMMA\y = Min(_vec1\y, _vec2\y) ...
; _XMMB\x = Max(_vec1\x, _vec2\x) : _XMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MinMax_2PD(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _XMMC=XMM2, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD)
  !MOVDQA _XMMC, _XMMA
  !MINPD _XMMA, _XMMB
  !MAXPD _XMMA, _XMMB
EndMacro

; _XMMA=SQRT(_vec)
Macro ASM_SIMD_SQRT_2PD(_vec, _XMM=XMM0, _REG=RDX)
  ASM_LD_REG_VecPtr(_REG, _vec)
  ASM_LD_XMM(_XMM, _REG)
  !SQRTPD _XMM, _XMM
EndMacro

; _REG=SQRT(vec\x² + vec\y²) : Pythagoras : 
Macro ASM_VecLength_2PD(_vec, _XMM=XMM0, _REG=RAX)
  ASM_LD_REG_VecPtr(_REG, _vec)
  ASM_LD_XMM(_XMM, _REG)
  !MULPD _XMM, _XMM
  !HADDPD _XMM, _XMM
  !SQRTSD _XMM, _XMM
  !MOVQ _REG, _XMM
EndMacro

; _REG=(vec\x² + vec\y²) : The Sum of the squares.
Macro ASM_VecSqSum_2PD(_vec, _XMM=XMM0, _REG=RAX)
  ASM_LD_REG_VecPtr(_REG, _vec)
  ASM_LD_XMM(_XMM, _REG)
  !MULPD _XMM, _XMM
  !HADDPD _XMM, _XMM
  !MOVQ _REG, _XMM
EndMacro

;- ----------------------------------------------------------------------
;- Vector Color functions 
;- ----------------------------------------------------------------------

; Expand the Color from Byte to Word
Macro ASM_COL_EXPw(_XMM=XMM0, _XMMH=XMM1)
  !PXOR _XMMH, _XMMH
  !PUNPCKLBW _XMM, _XMMH
EndMacro

Macro ASM_COL_CMPw(_XMM=XMM0)
  
EndMacro

Macro ASM_COL_EXPf(_XMM=XMM0)
  
EndMacro

Macro ASM_COL_CMPf(_XMM=XMM0)
  
EndMacro

; ADD with unsigned satration 16x 8 Bit unsigned Byte
Macro ASM_SIMD_ADDUS_16PB(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PADDUSB _XMMA, _XMMB       
EndMacro

; SUB with unsigned satration 16x 8 Bit unsigned Byte
Macro ASM_SIMD_SUBUS_16PB(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PSUBUSB  _XMMA, _XMMB       
EndMacro

; ADD with signed satration 8x 16 Bit signed INT
Macro ASM_SIMD_ADDSS_8PW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PADDSW  _XMMA, _XMMB       
EndMacro

; SUB with signed satration 8x 16 Bit signed INT
Macro ASM_SIMD_SUBSS_8PW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PSUBSW  _XMMA, _XMMB       
EndMacro

; MUL & ADD 8x 16 Bit signed Word INT
Macro ASM_SIMD_MADD_8PW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD) 
  !PMADDWD _XMMA, _XMMB       
EndMacro

; _XMMA\x = Min(_vec1\x _vec2\x) : _XMMA\y = Min(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_Min_8PW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD)
  !PMINPW _XMMA, _XMMB
EndMacro

; _XMMB\x = Max(_vec1\x, _vec2\x) : _XMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_Max_8PW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD)
  !PMAXSW _XMMA, _XMMB
EndMacro

; _XMMA\x = Min(_vec1\x _vec2\x) : _XMMA\y = Min(_vec1\y, _vec2\y) ...
; _XMMB\x = Max(_vec1\x, _vec2\x) : _XMMA\y = Max(_vec1\y, _vec2\y) ...
Macro ASM_SIMD_MinMax_8PW(_vec1, _vec2, _XMMA=XMM0, _XMMB=XMM1, _XMMC=XMM2, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _vec1)
  ASM_LD_REG_VecPtr(_REGD, _vec2)    
  ASM_LD_XMM(_XMMA, _REGA)
  ASM_LD_XMM(_XMMB, _REGD)
  !MOVDQA _XMMC, _XMMA
  !PMINSW _XMMA, _XMMB
  !PMAXSW _XMMA, _XMMB
EndMacro

; XMMV = DotProduct(_XMM-Vector, _XMM-Matrix)
Macro ASM_DotProduct_8PW(_XMMV, _XMMMx)
  !PMADDWD _XMMV, _XMMMx      
  !PHADDW _XMMV, _XMMV
EndMacro

;- ----------------------------------------------------------------------
;- Matrix PS Packed Single 
;- ----------------------------------------------------------------------

Macro ASM_LD_XMM47_Mx4_PS(_mx_, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _mx_)
  !MOV _REGD, _REGA
  !ADD _REGD, 8
  !MOVDQU XMM4, [_REGA]
  !MOVDQU XMM5, [_REGD]
  !MOVDQU XMM6, [_REGA+8]
  !MOVDQU XMM7, [_REGD+8]
EndMacro

; load a 4x4 Matrix of PackedWords in Column style (90° turned)
; this eliminates the Shuffle Commands for Vectors in Vector*Matrix
; because in SSE vertical Adds are much faster than horizontal Adds
; Use Register: XMM4..7
Macro ASM_LD_XMM47_Column_Mx4_PS(_mx_, _AX=AX, _REGC=RCX)
  
  ; load the 1st column as vector to XMM4_lo and XMM4_hi 
  ASM_LD_REG_VecPtr(_REGC, _mx_) ; Pointer to Column 1, Row 1
  !PXOR XMM4, XMM4  
  !MOVD XMM4, [_REGC +48] ; C1,R4
  !PSLLDQ XMM4, 32        ; Shift left 1 DoubleWord = 32 Bit
  !MOVD XMM4, [_REGC +32] ; C1,R3
  !PSLLDQ XMM4, 32
  !MOVD XMM4, [_REGC +16] ; C1,R2
  !PSLLDQ XMM4, 32
  !MOVD XMM4, [_REGC]     ; C1,R1
  ; ---------------
  
  ; load the 2nd column as vector to XMM5_lo and XMM5_hi 
  !ADD _REGC, 4       ; Pointer to next Column C2, R1
  !PXOR XMM5, XMM5  
  !MOVD XMM5, [_REGC +48] ; C2,R4
  !PSLLDQ XMM5, 32
  !MOVD XMM5, [_REGC +32] ; C2,R3
  !PSLLDQ XMM5, 32
  !MOVD XMM5, [_REGC +16] ; C2,R2
  !PSLLDQ XMM5, 32
  !MOVD XMM5, [_REGC]     ; C2,R1
  ; ---------------
  
  ; load the 3d column as vector to XMM6_lo and XMM6_hi 
  !ADD _REGC, 4       ; Pointer to next Column C3, R1
  !PXOR XMM6, XMM6  
  !MOVD XMM6, [_REGC +48] ; C3,R4
  !PSLLDQ XMM6, 32
  !MOVD XMM6, [_REGC +32] ; C3,R3
  !PSLLDQ XMM6, 32
  !MOVD XMM6, [_REGC +16] ; C3,R2
  !PSLLDQ XMM6, 32
  !MOVD XMM6, [_REGC]     ; C3,R1 
  ; ---------------
  
  ; load the 4th column as vector to XMM7_lo and XMM7_hi 
  !ADD _REGC, 4       ; Pointer to next Column C4, R1
  !PXOR XMM7, XMM6  
  !MOVD XMM7, [_REGC +48] ; C4,R4
  !PSLLDQ XMM7, 32
  !MOVD XMM7, [_REGC +32] ; C4,R3
  !PSLLDQ XMM7, 32
  !MOVD XMM7, [_REGC +16] ; C4,R2
  !PSLLDQ XMM7, 32
  !MOVD XMM7, [_REGC]     ; C4,R1
EndMacro

; First: load Matrix in Column Style (for use of fast vertical Adds instead of slow horizontal Adds) 
; Second: Load Vector, 16Bit Packed Words, to XMM0 first
; Call ASM_VECxMx_PS
; Result as 4x32Bit Vector in XMM0
; DownPack WORDS to BYTES to get a 32 Bit Color Value again!
; Read the ready result from XMM0: 
; Use Register: XMM0..7
Macro ASM_Vec_x_Mx_PS()
  ; load XMM0 first with your vectors (1 or 2 colors and expand BYTE to WORD
  !MOVDQA XMM1, XMM0  ; copy the Vector to XMM1
  !MOVDQA XMM2, XMM0  ; copy the Vector to XMM2
  !MOVDQA XMM3, XMM1  ; copy the Vector to XMM3
    
  ; SIMD Multiply with unscaling SHR>>14 and +1 Rounding
  ; that's the perfect Command to Multiply RGB-Colors with an INT Matrix scaled by 16384 (<<14)  
  !MULPS XMM0, XMM4   ; Multiply the Vector with Column1 of Matrix
  !MULPS XMM1, XMM5   ; Multiply the Vector with Column2 of Matrix
  !MULPS XMM2, XMM6   ; Multiply the Vector with Column3 of Matrix
  !MULPS XMM3, XMM7   ; Multiply the Vector with Column4 of Matrix 
  ; Vertical ADD all together
  !ADDPS  XMM0, XMM1
  !ADDPS  XMM2, XMM3
  !ADDPS  XMM0, XMM2
  
  ; XMM0 lo 64Bit = New Vector 1
  ; XMM0 hi 64Bit = New Vector 2 
EndMacro

; MatrixC [XMM0..3] = MatrixA [XMM4..7] * MatrixB [XMM8..11]
; Use Register: XMM0..11
Macro ASM_Mx_x_Mx_PS()
  !MOVDQA XMM0, XMM8    ; Matrix B Column 1
  ASM_Vec_x_Mx_PS()     ; Multiply with Matrix A -> Result to XMM0
  !MOVDQA XMM8, XMM0    ; Save result to XMM8
  
  !MOVDQA XMM0, XMM9    ; Matrix B Column 2
  ASM_Vec_x_Mx_PS()     ; Multiply with Matrix A -> Result to XMM0
  !MOVDQA XMM9, XMM0    ; Save result to XMM9
  
  !MOVDQA XMM0, XMM10   ; Matrix B Column 3
  ASM_Vec_x_Mx_PS()     ; Multiply with Matrix A -> Result to XMM0
  !MOVDQA XMM10, XMM0   ; Save result to XMM10
  
  !MOVDQA XMM0, XMM11   ; Matrix B Column 4
  ASM_Vec_x_Mx_PS()     ; Multiply with Matrix A -> Result to XMM0
  !MOVDQA XMM3, XMM0    ; Move Result to XMM3 : Row 4
  
  !MOVDQA XMM2, XMM10   ; Move Result to XMM2 : Row 3
  !MOVDQA XMM1, XMM9    ; Move Result to XMM1 : Row 2
  !MOVDQA XMM0, XMM8    ; Move Result to XMM0 : Row 1
EndMacro

;- ----------------------------------------------------------------------
;- Matrix PS Packed Word
;- ----------------------------------------------------------------------

; Load a 4x4 Matrix of Packed Words into XMM4..7 lo 64Bit and hi 64Bit 
; Use Register: XMM4..7
Macro ASM_LD_XMM47_Row_Mx4_PW(_mx_, _REGA=RAX, _REGD=RDX)
  ASM_LD_REG_VecPtr(_REGA, _mx_)
  !MOV _REGD, _REGA
  !ADD _REGD, 16
  !MOVQ XMM4, [_REGA]
  !PSHUFD XMM4, XMM4, 01000100b
  
  !MOVQ XMM5, [_REGD]
  !PSHUFD XMM5, XMM5, 01000100b
  
  !MOVQ XMM6, [_REGA+32]
  !PSHUFD XMM6, XMM6, 01000100b
  
  !MOVQ XMM7, [_REGD+32]
  !PSHUFD XMM7, XMM7, 01000100b
EndMacro

; load a 4x4 Matrix of PackedWords in Column style (90° turned)
; this eliminates the Shuffle Commands for Vectors in Vector*Matrix
; because in SSE vertical Adds are much faster than horizontal Adds
; Use Register: XMM4..7
Macro ASM_LD_XMM47_Column_Mx4_PW(_mx_, _AX=AX, _REGC=RCX)
  
  ; load the 1st column as vector to XMM4_lo and XMM4_hi 
  ASM_LD_REG_VecPtr(_REGC, _mx_) ; Pointer to Column 1, Row 1
  !XOR R#_AX, R#_AX
  !MOV _AX, [_REGC+24]  ; C1,R4
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC +16] ; C1,R3
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC +8]  ; C1,R2
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC]     ; C1,R1
  
  !MOVQ XMM4, R#_AX
  !PSHUFD XMM4, XMM4, 01000100b   ; copy XMM_lo to _hi
  ; ---------------
  
  ; load the 2nd column as vector to XMM5_lo and XMM5_hi 
  !ADD _REGC, 2         ; Pointer to next Column C2, R1
  !XOR R#_AX, R#_AX
  !MOV _AX, [_REGC +24] ; C2,R4
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC +16] ; C2,R3
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC +8]  ; C2,R2
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC]     ; C2,R1
   
  !MOVQ XMM5, R#_AX
  !PSHUFD XMM5, XMM5, 01000100b    ; copy XMM_lo to _hi
  ; ---------------
  
  ; load the 3d column as vector to XMM6_lo and XMM6_hi 
  !ADD _REGC, 2         ; Pointer to next Column C3, R1
  !XOR R#_AX, R#_AX
  !MOV _AX, [_REGC+24]  ; C3,R4
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC +16] ; C3,R3
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC +8]  ; C3,R2
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC]     ; C3,R1
  
  !MOVQ XMM6, R#_AX
  !PSHUFD XMM6, XMM6, 01000100b   ; copy XMM_lo to _hi 
  ; ---------------
  
  ; load the 4th column as vector to XMM7_lo and XMM7_hi 
  !ADD _REGC, 2         ; Pointer to  next Column C4, R1
  !XOR R#_AX, R#_AX
  !MOV _AX, [_REGC+24]  ; C4,R4
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC +16] ; C4,R2
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC +8]  ; C4,R3
  !SHL R#_AX, 16        
  !MOV _AX, [_REGC]     ; C4,R4
  
  !MOVQ XMM7, R#_AX
  !PSHUFD XMM7, XMM7, 01000100b   ; copy XMM_lo to _hi
EndMacro

; Vector Color * Matrix
; First: load Matrix in Column Style (for use of fast vertical Adds instead of slow horizontal Adds) 
; Second: Load Vector, 16Bit Packed Words, to XMM0 first
; Call ASM_VECxMx_PW
; Result as 4x16Bit Vector in XMM0
; DownPack WORDS to BYTES to get a 32 Bit Color Value again!
; Read the ready result from XMM0: if 2 Pixel where loaded to XMM0, the result will contain the 2 Pixles in XMM_hi_lo

; Use Register: XMM0..7
Macro ASM_VecCol_x_Mx_PW()
  ; load XMM0 first with your vectors (1 or 2 colors and expand BYTE to WORD
  !MOVDQA XMM1, XMM0    ; copy the 2 Pixels to XMM1
  !MOVDQA XMM2, XMM0    ; copy the 2 Pixels to XMM2
  !MOVDQA XMM3, XMM1    ; copy the 2 Pixels to XMM3
    
  ; SIMD Multiply with unscaling SHR>>14 and +1 Rounding
  ; that's the perfect Command to Multiply RGB-Colors with an INT Matrix scaled by 16384 (<<14)  
  !PMULHRSW XMM0, XMM4  ; Multiply the Pixels with Column1 of Matrix
  !PMULHRSW XMM1, XMM5  ; Multiply the Pixels with Column2 of Matrix
  !PMULHRSW XMM2, XMM6  ; Multiply the Pixels with Column3 of Matrix
  !PMULHRSW XMM3, XMM7  ; Multiply the Pixels with Column4 of Matrix 
  ; Vertical ADD all together
  !PADDW  XMM0, XMM1
  !PADDW  XMM2, XMM3
  !PADDW  XMM0, XMM2
  
  ; XMM0 lo 64Bit = New Vector 1
  ; XMM0 hi 64Bit = New Vector 2  
EndMacro

; MatrixC [XMM0..3] = MatrixA [XMM4..7] * MatrixB [XMM8..11]
; load first Matrix B to XMM8..11 and Matrix A to XMM4..7
; Use Register: XMM0..11
Macro ASM_Mx_x_Mx_PW()
  !MOVDQA XMM0, XMM8
  ASM_VecCol_x_Mx_PW()
  !MOVDQA XMM8, XMM0

  !MOVDQA XMM0, XMM9
  ASM_VecCol_x_Mx_PW()
  !MOVDQA XMM9, XMM0

  !MOVDQA XMM0, XMM10
  ASM_VecCol_x_Mx_PW()
  !MOVDQA XMM10, XMM0

  !MOVDQA XMM0, XMM11
  ASM_VecCol_x_Mx_PW()
  !MOVDQA XMM3, XMM0

  !MOVDQA XMM0, XMM8
  !MOVDQA XMM1, XMM9
  !MOVDQA XMM2, XMM10
EndMacro

CompilerIf #PB_Compiler_IsMainFile
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------
  EnableExplicit
  EnableASM
  
  Structure VEC2d
    x.d
    y.d
  EndStructure
   
  ; Single precicion Matrix
  Structure TMatrixW 
    StructureUnion
      m.w[0]
      v.Vector4[0]        ; Vector interpretation of the Matrix Structure
    EndStructureUnion
    m11.w : m12.w : m13.w : m14.w    
    m21.w : m22.w : m23.w : m24.w
    m31.w : m32.w : m33.w : m34.w   
    m41.w : m42.w : m43.w : m44.w
  EndStructure
    
  Macro DbgVector4(_v4)
    Debug "x=" + _v4\x
    Debug "y=" + _v4\y
    Debug "z=" + _v4\z
    Debug "w=" + _v4\w   
  EndMacro
  
  Macro DbgVector2(_v2)
    Debug "x=" + _v2\x
    Debug "y=" + _v2\y
  EndMacro
 
  Procedure TestVEC2d()
    Protected.VEC2d v1, v2, vres
    Protected.d vlen
    
    v1\x = 1
    v1\y = 1
    
    v2\x = 2
    v2\y = 2
    
    ASM_VecLength_2PD(v1) ; Retrun length in RAX
    MOV vlen, RAX    
    Debug "Vector length v1(1,1) = " +StrD(vlen)    
    ASM_VecLength_2PD(v2) ; Retrun length in RAX
    MOV vlen, RAX    
    Debug "Vector length v2(2,2) = " +StrD(vlen) 
    
    ASM_SIMD_ADD_2PD(v1,v2)   ; XMM0=v1+v2
    ASM_LD_REG_VarPtr(vres)   ; RDX = @vres
    ASM_SAV_XMM(XMM0)         ; vres = XMM0 : MOVQ [RDX], XMM0
    Debug "v1 + v2"
    DbgVector2(vres)
    
    Debug ""
    ASM_SIMD_MUL_2PD(v1,v2)   ; Return result in XMM0
    ASM_LD_REG_VarPtr(vres)   ; RDX = @vres
    ASM_SAV_XMM(XMM0)         ; vres = XMM0 : MOVQ [RDX], XMM0
    Debug "v1*v2"
    DbgVector2(vres)
    
    Debug""
    ASM_SIMD_DIV_2PD(v1,v2)
    ASM_LD_REG_VarPtr(vres)   ; RDX = @vres
    ASM_SAV_XMM(XMM0)         ; vres = XMM0 : MOVQ [RDX], XMM0
    Debug "v1/v2"
    DbgVector2(vres)
  EndProcedure
  
  Procedure AddVector4(*vecResult.Vector4, *vec1.Vector4, *vec2.Vector4)
    With *vecResult
      \x = *vec1\x + *vec2\x
      \y = *vec1\y + *vec2\y
      \z = *vec1\z + *vec2\z
      \w = *vec1\w + *vec2\w
    EndWith
  EndProcedure
  
  Procedure AddVector4_SSE(*vecResult.Vector4, *vec1.Vector4, *vec2.Vector4)
    ASM_SIMD_ADD_4PS(*vec1, *vec2)    ; XMM0 = vec1 + vec2 
    
    ASM_LD_REG_Var(RDX, *vecResult) ; RDX = *vecRestlt
    ;!MOV RDX, [p.p_vecResult]     ; or alternative the ASM-Code
    
    ASM_SAV_XMM(XMM0, RDX)          ; vecResult = XMM0 : lo latency 128Bit load
  EndProcedure

  ; because all variables in the ASM Macros are defined as in Procedure, we have to use
  ; a Procedure for the TestCoode
  Procedure TestVEC4()
    Protected.Vector4 v1, v2, vres
    v1\x = 1.0
    v1\y = 12.0
    v1\z = 3.0
    v1\w = 14.0
    
    v2\x = 11.0
    v2\y = 2.0
    v2\z = 13.0
    v2\w = 4.0
    
    Debug "SSE Vector4 operations"
    Debug "v1.Vector4"
    DbgVector4(v1)
    Debug ""
    Debug "v2.Vector4"
    DbgVector4(v2)

    ; example adding two Vector4 Structures with SSE Commands
    ; vres = v1 + v2
    ASM_SIMD_Add_4PS(v1, v2)      ; ADD v1 to v2 using XMM0/XMM1 -> result in XMM0. Using RAX/RDX as pointer Registers
    ASM_LD_REG_VecPtr(RDX, vres)  ; load Register with Pointer @vres
    ASM_SAV_XMM()                 ; save XMM0 to Memory pointed by RDX : vres = XMM0
    
    Debug ""
    Debug "v1 + v2"
    DbgVector4(vres)
    
    ; example multiply two Vector4 Structures with SSE Commands
    ; vres = v1 * v2
    ASM_SIMD_MUL_4PS(v1, v2)      ; ADD v1 to v2 using XMM0/XMM1 -> result in XMM0. Using RAX/RDX as pointer Registers
    ASM_LD_REG_VecPtr(RDX, vres)  ; load Register with Pointer @vres
    ASM_SAV_XMM()                 ; save XMM0 to Memory pointed by RDX : vres = XMM0
    
    ; example devide two Vector4 Structures with SSE Commands
    ; vres = vres / v2    -> reult will be v1
    ASM_SIMD_DIV_4PS(vres, v2)    ; ADD v1 to v2 using XMM0/XMM1 -> result in XMM0. Using RAX/RDX as pointer Registers
    ASM_LD_REG_VecPtr(RDX, vres)  ; load Register with Pointer @vres
    ASM_SAV_XMM()                 ; save XMM0 to Memory pointed by RDX : vres = XMM0

    Debug ""
    Debug "vres / v2 -> result will be v1"
    DbgVector4(vres)
    
    ; example minimum of two Vector4 Structures with SSE Commands
    ; vres = Min(v1 * v2)
    ASM_SIMD_MIN_4PS(v1, v2)      ; ADD v1 to v2 using XMM0/XMM1 -> result in XMM0. Using RAX/RDX as pointer Registers
    ASM_LD_REG_VecPtr(RDX, vres)  ; load Register with Pointer @vres
    ASM_SAV_XMM()                 ; save XMM0 to Memory pointed by RDX : vres = XMM0
    
    Debug ""
    Debug "Min(v1, v2)"
    DbgVector4(vres)
    
    ; example maximum of two Vector4 Structures with SSE Commands
    ; vres = Max(v1 * v2)
    ASM_SIMD_MAX_4PS(v1, v2)      ; ADD v1 to v2 using XMM0/XMM1 -> result in XMM0. Using RAX/RDX as pointer Registers
    ASM_LD_REG_VecPtr(RDX, vres)  ; load Register with Pointer @vres
    ASM_SAV_XMM()                 ; save XMM0 to Memory pointed by RDX : vres = XMM0
    
    Debug ""
    Debug "Max(v1, v2)"
    DbgVector4(vres)
    
    Debug "--------------------------------------------------"
    Debug ""
    
    Debug "For Timing Test"
    Debug "First test the result of classic ADD and SSE ADD"
    Debug "If you want to see timing result, compile without debugger"
    Debug ""
    
    Debug "Classic ADD:"
    AddVector4(vres, v1, v2)
    DbgVector4(vres)
    
    Debug "SSE ADD:"
    AddVector4_SSE(vres, v1, v2)
    DbgVector4(vres)
    
    Debug ""
    
    Define I, t1, t2
    
    #Loops = 1000 * 10000
    
    DisableDebugger
    ; because DisableDebugger do not switch off Debugger completely -> do not run Timing code when
    ; compiling with Debugger (PB 6.21)
    CompilerIf Not #PB_Compiler_Debugger
      ; Classic ADD
      AddVector4(vres, v1, v2)      ; Load Proc to Cash  
      t1 = ElapsedMilliseconds()
      For I =0 To #Loops
        AddVector4(vres, v1, v2)
      Next
      t1 = ElapsedMilliseconds() - t1
      
      ; SEE ADD
      AddVector4_SSE(vres, v1, v2)   ; Load Proc to Cash  
      t2 = ElapsedMilliseconds()
      For I =0 To #Loops
        AddVector4_SSE(vres, v1, v2)
      Next
      t2 = ElapsedMilliseconds() - t1
       
      OpenConsole()
      PrintN("Debugger off for SpeedTest to get the correct timing")
  
      PrintN( "Result for Loops=" + #Loops)
      PrintN( "Classic ADD  ms=" + t1)
      PrintN( "SSE SIMD ADD ms=" + t2)
      PrintN("Press a Key")
      Input()
    CompilerEndIf
    EnableDebugger
  EndProcedure
  
  Procedure TestVecMatrixW()
    Protected mx.TMatrixW
    Protected v.Vector4
    Protected I, t1, *p, *pEnd
    
    #NoOfPixels = 3840 * 2160 *10 ; 4k *10
    #MaxPxIndex = #NoOfPixels -1
    
    Dim px.l(#NoOfPixels)
    *p = @px(0)
    *pEnd = @px(#MaxPxIndex)
    
    For I = 0 To #MaxPxIndex
      px(I)=I  ; Fill Pixel Array  
    Next
    
    t1=ElapsedMilliseconds()
    ASM_LD_XMM47_Column_Mx4_PW(mx) ; load Matric vertical 90° turned
    While *p <= *pEnd
      ASM_LD_REG_Var(RDX, *p)
      !MOVQ XMM0, [RDX]
      ASM_COL_EXPw(XMM0, XMM1)
      ASM_VecCol_x_Mx_PW()
      *p + 8
    Wend
    t1=ElapsedMilliseconds()-t1
    
    OpenConsole()
    PrintN("Speedtest Matrix PW Multiplication")

    PrintN( "Result for Pixels=" + #NoOfPixels)
    PrintN( "ms=" + t1)
    PrintN("Press a Key")
    Input()
    
  EndProcedure
  
;   TestVEC4() 
;   Debug "------------------------------------------------------------"
;   Debug " 2 packed doubles VEC2d"
;   Debug "------------------------------------------------------------"
;  
;   TestVEC2d()
 
  TestVecMatrixW()
CompilerEndIf


; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 209
; FirstLine = 186
; Folding = ------------------
; DPIAware
; CPU = 5