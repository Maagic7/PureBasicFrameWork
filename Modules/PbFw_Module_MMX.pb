; ===========================================================================
; FILE : PbFw_Module_MMX.pb
; NAME : PureBasic Framework : Module MMX [MMX::]
; DESC : Functions using the Multi-Media-Extentions of x86 Processors
; DESC : The MMX, SSE, AVX-Registers, to speed up vector operations
; SOURCES:
;   Lazarus Free Pascal SEE optimation
;     https://wiki.freepascal.org/SSE/de
;   PurePasic 3DDrawing Module
;     https://www.purebasic.fr/german/viewtopic.php?t=22128&hilit=3DDrawing
;   Orcacel SEE Dokumentation
;     https://docs.oracle.com/cd/E26502_01/html/E28388/eojde.html
;   AMD Software Optimization Guide for AMD64 Processors
;     https://www.amd.com/system/files/TechDocs/25112.PDF
;   A full description of the Intel Assembler Commands
;     https://hjlebbink.github.io/x86doc/
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/04
; VERSION  :  0.1 untested Develpper Version
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog: 
;{
;}
; ===========================================================================

;{ ====================      M I T   L I C E N S E        ====================
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
; XIncludeFile ""

; Check CPUID SSE-Flags  https://wiki.osdev.org/SSE

;- ----------------------------------------------------------------------
;- MMX Assembler commands
;  MM0..MM7  64Bit Registers
;- ----------------------------------------------------------------------
;{ MMX Assembler command list
;
;-Data Transfer Instructions
; The data transfer instructions move doubleword and quadword operands between MMX registers and between MMX registers and memory.
;
; MOVD      : move doubleword
; MOVQ      : move quadword
;
; Conversion Instructions
; The conversion instructions pack and unpack bytes, words, and doublewords.
;
; PACKSSDW  : pack doublewords into words with signed saturation
; PACKSSWB  : pack words into bytes with signed saturation
; PACKUSWB  : pack words into bytes with unsigned saturation
; PUNPCKHBW : unpack high-order bytes
; PUNPCKHDQ : unpack high-order doublewords
; PUNPCKHWD : unpack high-order words
; PUNPCKLBW : unpack low-order bytes
; PUNPCKLDQ : unpack low-order doublewords
; PUNPCKLWD : unpack low-order words
;
;-Packed Arithmetic Instructions
; The packed arithmetic instructions perform packed integer arithmetic on packed byte, word, and doubleword integers.
;
; PADDB     : add packed byte integers
; PADDD     : add packed doubleword integers
; PADDSB    : add packed signed byte integers with signed saturation
; PADDSW    : add packed signed word integers with signed saturation
; PADDUSB   : add packed unsigned byte integers with unsigned saturation
; PADDUSW   : add packed unsigned word integers with unsigned saturation
; PADDW     : add packed word integers
; PMADDWD   : multiply and add packed word integers
; PMULHW    : multiply packed signed word integers and store high result
; PMULLW    : multiply packed signed word integers and store low result
; PSUBB     : subtract packed byte integers
; PSUBD     : subtract packed doubleword integers
; PSUBSB    : subtract packed signed byte integers with signed saturation
; PSUBSW    : subtract packed signed word integers with signed saturation
; PSUBUSB   : subtract packed unsigned byte integers with unsigned saturation
; PSUBUSW   : subtract packed unsigned word integers with unsigned saturation
; PSUBW     : subtract packed word integers
;
;-Comparison Instructions
; The compare instructions compare packed bytes, words, or doublewords.
;
; PCMPEQB   : compare packed bytes for equal
; PCMPEQD   : compare packed doublewords for equal
; PCMPEQW   : compare packed words for equal
; PCMPGTB   : compare packed signed byte integers for greater than
; PCMPGTD   : compare packed signed doubleword integers for greater than
; PCMPGTW   : compare packed signed word integers for greater than
;
;-Logical Instructions
; The logical instructions perform logical operations on quadword operands.
;
; PAND      : bitwise logical AND
; PANDN     : bitwise logical AND NOT
; POR       : bitwise logical OR
; PXOR      : bitwise logical XOR
;
;-Shift and Rotate Instructions
; The shift and rotate instructions operate on packed bytes, words, doublewords, or quadwords in 64–bit operands
;
; PSLLD     : shift packed doublewords left logical
; PSLLQ     : shift packed quadword left logical
; PSLLW     : shift packed words left logical
; PSRAD     : shift packed doublewords right arithmetic
; PSRAW     : shift packed words right arithmetic
; PSRLD     : shift packed doublewords right logical
; PSRLQ     : shift packed quadword right logical
; PSRLW     : shift packed words right logical
;
;-State Management Instructions 
; The emms (EMMS) instruction clears the MMX state from the MMX registers.
;
; EMMS      : empty MMX state
;}

;- ----------------------------------------------------------------------
;- SSE Assembler commands
;  XMM0..XMM7  128Bit Registers Extended MMX-Registers
;  containing [SSE1] 4x single presicion or [SSED2], 2 x double presicion Floats
;  for duble presicion change the last 'S' to D
;  MOVAPS -> MOVPD; ADDPS -> ADDPD ...
;  for using 4x double precision values (256-Bit) use AVX commands 
;- ----------------------------------------------------------------------
;{ SSE Assembler command list 
;
;-Data Transfer Instructions 
; The SSE Data transfer instructions move packed And scalar single-precision floating-point operands between XMM registers And between XMM registers And memory.
;
; MOVAPS    : move four aligned packed single-precision floating-point values between XMM registers or memory
; MOVHLPS   : move two packed single-precision floating-point values from the high quadword of an XMM register to the low quadword of another XMM register
; MOVHPS    : move two packed single-precision floating-point values to or from the high quadword of an XMM register or memory
; MOVLHPS   : move two packed single-precision floating-point values to or from the low quadword of an XMM register or memory
; MOVMSKPS  : extract sign mask from four packed single-precision floating-point values
; MOVSS     : move scalar single-precision floating-point value between XMM registers or memory
; MOVUPS    : move four unaligned packed single-precision floating-point values between XMM registers or memory
;
;-Packed Arithmetic Instructions
; SSE packed arithmetic instructions perform packed and scalar arithmetic operations on packed and scalar single-precision floating-point operands.
;
; ADDPS     : add packed single-precision floating-point value
; ADDSS     : add scalar single-precision floating-point values
; DIVPS     : divide packed single-precision floating-point values
; DIVSS     : divide scalar single-precision floating-point values
; MAXPS     : return maximum packed single-precision floating-point values
; MAXSS     : return maximum scalar single-precision floating-point values
; MINPS     : return minimum packed single-precision floating-point values
; MINSS     : return minimum scalar single-precision floating-point values.
; MULPS     : multiply packed single-precision floating-point values
; MULSS     : multiply scalar single-precision floating-point values
; RCPPS     : compute reciprocals of packed single-precision floating-point values
; RCPSS     : compute reciprocal of scalar single-precision floating-point values
; RSQRTPS   : compute reciprocals of square roots of packed single-precision floating-point values
; RSQRTSS   : compute reciprocal of square root of scalar single-precision floating-point values
; SQRTPS    : compute square roots of packed single-precision floating-point values
; SQRTSS    : compute square root of scalar single-precision floating-point values
; SUBPS     : subtract packed single-precision floating-point values
; SUBSS     : subtract scalar single-precision floating-point values
;
;-Comparison Instructions
; The SEE compare instructions compare packed and scalar single-precision floating-point operands.
;
; CMPPS     : compare packed single-precision floating-point values
; CMPSS     : compare scalar single-precision floating-point values
; COMISS    : perform ordered comparison of scalar single-precision floating-point values and set flags in EFLAGS register
; UCOMISS   : perform unordered comparison of scalar single-precision floating-point values and set flags in EFLAGS register
;
;-Logical Instructions
; The SSE logical instructions perform bitwise AND, AND NOT, OR, and XOR operations on packed single-precision floating-point operands.
;
; ANDNPS    : perform bitwise logical AND NOT of packed single-precision floating-point values
; ANDPS     : perform bitwise logical AND of packed single-precision floating-point values
; ORPS      : perform bitwise logical OR of packed single-precision floating-point values
; XORPS     : perform bitwise logical XOR of packed single-precision floating-point values
;
;-Shuffle and Unpack Instructions
; The SSE shuffle and unpack instructions shuffle or interleave single-precision floating-point values in packed single-precision floating-point operands.
;
; SHUFPS    : shuffles values in packed single-precision floating-point operands
; UNPCKHPS  : unpacks and interleaves the two high-order values from two single-precision floating-point operands
; UNPCKLPS  : unpacks and interleaves the two low-order values from two single-precision floating-point operands
;
;-Conversion Instructions
; The SSE conversion instructions convert packed and individual doubleword integers into packed and scalar single-precision floating-point values.
;
; CVTPI2PS  : convert packed doubleword integers to packed single-precision floating-point values
; CVTPS2PI  : convert packed single-precision floating-point values to packed doubleword integers
; CVTSI2SS  : convert doubleword integer to scalar single-precision floating-point value
; CVTSS2SI  : convert scalar single-precision floating-point value to a doubleword integer
; CVTTPS2PI : convert with truncation packed single-precision floating-point values to packed doubleword integers
; CVTTSS2SI : convert with truncation scalar single-precision floating-point value to scalar doubleword integer
;
;- MXCSR State Management Instructions
; The MXCSR state management instructions save and restore the state of the MXCSR control and status register.
;
; LDMXCSR   : load %mxcsr register
; STMXCSR   : save %mxcsr register state

; 64–Bit SIMD Integer Instructions
; The SSE 64–bit SIMD integer instructions perform operations on packed bytes, words, Or doublewords in MMX registers.
;
; PAVGB     : compute average of packed unsigned byte integers
; PAVGW     : compute average of packed unsigned byte integers
; PEXTRW    : extract word
; PINSRW    : insert word
; PMAXSW    : maximum of packed signed word integers
; PMAXUB    : maximum of packed unsigned byte integers
; PMINSW    : minimum of packed signed word integers
; PMINUB    : minimum of packed unsigned byte integers
; PMOVMSKB  : move byte mask
; PMULHUW   : multiply packed unsigned integers and store high result
; PSADBW    : compute sum of absolute differences
; PSHUFW    : shuffle packed integer word in MMX register
;
;-Miscellaneous Instructions
; The following instructions control caching, prefetching, and instruction ordering.
;
; MASKMOVQ    : non-temporal store of selected bytes from an MMX register into memory
; MOVNTPS     : non-temporal store of four packed single-precision floating-point values from an XMM register into memory
; MOVNTQ      : non-temporal store of quadword from an MMX register into memory
; PREFETCHNTA : prefetch data into non-temporal cache structure and into a location close to the processor
; PREFETCHT0  : prefetch data into all levels of the cache hierarchy
; PREFETCHT1  : prefetch data into level 2 cache and higher
; PREFETCHT2  : prefetch data into level 2 cache and higher
; SFENCE      : serialize store operations
;}

;- ----------------------------------------------------------------------
;- AVX/AVX2 Assembler commands
;  YMM0..YMM15  256Bit Registers! The low 128-Bits are the XMM0..XMM15 
;- ----------------------------------------------------------------------


;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule MMX
  EnableExplicit
  
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
    
  
  ; Vector ist immer aus 4 Elementen, sonst macht das keinen Sinn
  ; die Unterscheidung Vector3, Vector4 bringt nur Nachteile statt Vorteile
  ; Man braucht neben den x,y,z,w Kooridnaten noch die Möglichkeit des
  ; indizierten Zugriffs des dürfte für Matrix-Operationen besser sein!
  
  Structure TsVector  ; Single precicion Vector [16 Bytes / 128 Bit]
    StructureUnion
      v.f[0]          ; virutal Array  v[0]=x, v[1]=y, v[2]=z, v[3]=w
    EndStructureUnion
    x.f
    y.f
    z.f
    w.f
  EndStructure 
 
  Structure TdVector  ; Double precicion Vector [32 Bytes / 256 Bit]
    StructureUnion
      v.d[0]          ; virutal Array  v[0]=x, v[1]=y, v[2]=z, v[3]=w
    EndStructureUnion
    x.d
    y.d
    z.d  
    w.d
  EndStructure
    
  Debug "SyzeOf(TsVector) = " + SizeOf(TsVector)
  Debug "SyzeOf(TdVector) = " + SizeOf(TdVector)
   
  Structure TsMatrix  ; Single precicion Matrix
    vec.TsVector[4]   ; 4 Elements 0..3
  EndStructure
  
  Structure TdMatrix  ; Double precicion Matrix
    vec.TdVector[4]   ; 4 Elements 0..3
  EndStructure
  
  Macro SetVector(Vec, _X, _Y, _Z)
    Vec\x = _X
    Vex\y = _Y
    Vec\z = _Z
    Vec\w = 0
  EndMacro
  
  Macro SetVector4(Vec, _X, _Y, _Z, _W)
    Vec\x = _X
    Vec\y = _Y
    Vec\z = _Z
    Vec\w = _W
  EndMacro

  Macro ClearVector(Vec)
    Vec\x = 0
    Vec\y = 0
    Vec\z = 0
    Vec\w = 0   
  EndMacro
  
  Macro ClearMatrix(Matrix)
    ClearVector(Matrix\vec[0])
    ClearVector(Matrix\vec[1])
    ClearVector(Matrix\vec[2])  
    ClearVector(Matrix\vec[3])
  EndMacro
  
  Macro SetIdentityMatrix(Matrix) ; Einheitsmatrix
    ClearMatrix(Matrix)
    Matrix\vec[0]\v[0] = 1.0
    Matrix\vec[1]\v[1] = 1.0
    Matrix\vec[2]\v[2] = 1.0
    Matrix\vec[3]\v[3] = 1.0
  EndMacro
  
  Macro ColorToVector(Vector, Color)
    Vector\v[0] = Red(Color)
    Vector\v[1] = Green(Color)
    Vector\v[2] = Blue(Color)
    Vector\v[3] = Alpha(Color)/(255*255)
  EndMacro
  
  Declare sVector_Add(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector)
  Declare sVector_Sub(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector) 
  Declare sVector_Mul(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector) 
  Declare sVector_Div(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector) 
  Declare sVector_Swap(*Vec.TsVector)
  Declare sVector_Scale(*Vec.TsVector, Factor.f)
  Declare sVectorCrossProduct(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector)
  Declare sVector_X_Matrix(*OUT.TsVector, *IN.TsVector, *Matrix.TsMatrix)
  Declare sMatrix_X_Matrix(*OUT.TsMatrix, *M1.TsMatrix, *M2.TsMatrix)
    
  Declare dVector_Add(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector) 
  Declare dVector_Sub(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector) 
  Declare dVector_Mul(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector)
  Declare dVector_Div(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector)
  Declare dVector_Swap(*Vec.TdVector)
  Declare dVector_Scale(*Vec.TdVector, Factor.d)
  Declare dVectorCrossProduct(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector)
  Declare dVector_X_Matrix(*OUT.TdVector, *IN.TdVector, *Matrix.TdMatrix) 
  Declare dMatrix_X_Matrix(*OUT.TdMatrix, *M1.TdMatrix, *M2.TdMatrix)
EndDeclareModule
  
  Module MMX
        
  Enumeration 
    #MMX_SSE_Off        ; No SSE present
    #MMX_SSE_x32        ; 32-Bit Assembler SSE Code
    #MMX_SSE_x64        ; 64-Bot Assembler SSE Code
    #MMX_SSE_C_Backend  ; For Future use in the C-Backend (maybe it will be possible To force SSE optimation with the C intrinsic Macros)
  EndEnumeration  
  
  
  ; Here, the #MMX_USE_SSE Constant is set to right value
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86 Or #PB_Compiler_Processor = #PB_Processor_x64
            
      CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
        
          CompilerIf #PB_Compiler_64Bit       ; 64Bit-Compiler on x64 Processor
            #MMX_USE_SSE = #MMX_SSE_x64       
          CompilerElse                        ; 32Bit Compiler on x64 Processor
             #MMX_USE_SSE = #MMX_SSE_x32      
          CompilerEndIf
        
      CompilerElse
          #MMX_USE_SSE = #MMX_SSE_C_Backend   ; Activate SEE Optiomation in C-Backend       
      CompilerEndIf
      
  CompilerElse ; ANY OTHER PROCESSOR LIKE ARM32, ARM64
       #MMX_USE_SSE = #MMX_SSE_Off    ; Switch Off SSE Optimation
     
  CompilerEndIf 
  
; TEMPLATE Compiler Select SSE
;     CompilerSelect #MMX_USE_SSE
;         
;       CompilerCase #MMX_SSE_x64     ; 64 Bit-Version
;         
;       CompilerCase #MMX_SSE_x32     ; 32 Bit Version
;         
;       CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
;         
;       CompilerDefault                   ; Classic Version
;         
;     CompilerEndSelect  

  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  ; Macros for Classic Versions without SSE
  Macro mac_Vector_ADD(OUT, IN1, IN2)
    OUT\x= IN1\x + IN2\x   
    OUT\y= IN1\y + IN2\y   
    OUT\z= IN1\z + IN2\z   
    OUT\w= IN1\w + IN2\w   
  EndMacro
  
  Macro mac_Vector_SUB(OUT, IN1, IN2)
    OUT\x= IN1\x - IN2\x   
    OUT\y= IN1\y - IN2\y   
    OUT\z= IN1\z - IN2\z   
    OUT\w= IN1\w - IN2\w     
  EndMacro
  
  Macro mac_Vector_MUL(OUT, IN1, IN2)
    OUT\x= IN1\x * IN2\x   
    OUT\y= IN1\y * IN2\y   
    OUT\z= IN1\z * IN2\z   
    OUT\w= IN1\w * IN2\w     
  EndMacro
  
  Macro mac_Vector_DIV(OUT, IN1, IN2)
    OUT\x= IN1\x / IN2\x   
    OUT\y= IN1\y / IN2\y   
    OUT\z= IN1\z / IN2\z   
    OUT\w= IN1\w / IN2\w     
  EndMacro
  
  Macro mac_Vector_Scale(OUT, IN, Factor)
    OUT\x= IN\x * Factor   
    OUT\y= IN\y * Factor   
    OUT\z= IN\z * Factor    
    OUT\w= IN\w * Factor     
  EndMacro
  
  Macro mac_VectorCrossProduct(OUT, IN1, IN2)
 		*Out\X = *In1\Y * *In2\Z - *In1\Z * *In2\Y
		*Out\Y = *In1\Z * *In2\X - *In1\X * *In2\Z
		*Out\Z = *In1\X * *In2\Y - *In1\Y * *In2\X
		*Out\W = 0
	EndMacro
	
	Macro mac_Vextor_X_Matrix(vecOUT, vecIN, Matrix)
	  
	  ; *****     C O D E   F E H L T   N O C H *****
	  
	EndMacro
	
	Macro mac_Matrix_X_Matrix(OUT, M1, M2)
	  
	  ; *****     C O D E   F E H L T   N O C H *****
	  
	EndMacro
	
  
  Procedure.s Get_MMX_USE_SSE_String()
    Protected ret.s
    
    Select #MMX_USE_SSE
        
      Case #MMX_SSE_Off
        ret = "MMX_SSE_OFF"
        
      Case #MMX_SSE_x32
        ret = "MMX_SSE_x32_ASM"
        
      Case #MMX_SSE_x64
         ret = "MMX_SSE_x64_ASM"
       
      Case #MMX_SSE_C_Backend
         ret = "MMX_SSE_C_BackEnd"
        
     EndSelect
     ProcedureReturn ret    
  EndProcedure
  
  Debug Get_MMX_USE_SSE_String()
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
  
  ;- ----------------------------------------------------------------------
  ;-   Single precision functions .f (SSE) 128-Bit-XMM-Register
  ;- ----------------------------------------------------------------------

  Procedure sVector_Add(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector) 
        
    CompilerSelect #MMX_USE_SSE
      
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_IN1]       ; Move Data-Pointer 1 to rax
      	!Mov rdx, [p.p_IN2]       ; Move Data-Pointer 2 to rdx
        !Movups  Xmm0, [rax]      ; Move 16 Byte from Data 1 to Xmm0 Register
        !Movups  Xmm1, [rdx]      ; Move 16 Byte from Data 2 to Xmm1 Register
        !Addps   Xmm1, Xmm0       ; Add 4 packed single precision Float
        !Mov rax, [p.p_OUT]       ; Move Data-Pointer of Result to rax
        !Movups  [rax], Xmm1      ; Move the 16-Byte Result to our Result Data
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_IN1]
      	!Mov edx, [p.p_IN2]
        !Movups  Xmm0, [eax]
        !Movups  Xmm1, [edx]
        !Addps   Xmm1, Xmm0
        !Mov eax, [p.p_OUT]
        !Movups  [eax], Xmm1
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector4_ADD(*OUT, *IN1, *IN2)    
        
      CompilerDefault             ; Classic Version
        mac_Vector4_ADD(*OUT, *IN1, *IN2)        
    CompilerEndSelect
    
  EndProcedure
  
  Procedure sVector_Sub(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector) 
        
     CompilerSelect #MMX_USE_SSE
          
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_IN1]
      	!Mov rdx, [p.p_IN2]
        !Movups  Xmm0, [rax]
        !Movups  Xmm1, [rdx]
        !Subps   Xmm1, Xmm0
        !Mov rax, [p.p_OUT]
        !Movups  [rax], Xmm1     
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_IN1]
      	!Mov edx, [p.p_IN2]
        !Movups  Xmm0, [eax]
        !Movups  Xmm1, [edx]
        !Subps   Xmm1, Xmm0
        !Mov eax, [p.p_OUT]
        !Movups  [eax], Xmm1
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector4_SUB(*OUT, *IN1, *IN2)        

      CompilerDefault             ; Classic Version
        mac_Vector4_SUB(*OUT, *IN1, *IN2)        
    CompilerEndSelect  
  EndProcedure
  
  Procedure sVector_Mul(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector) 
    
    CompilerSelect #MMX_USE_SSE
      
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_IN1]
      	!Mov rdx, [p.p_IN2]
        !Movups  Xmm0, [rax]
        !Movups  Xmm1, [rdx]
        !Mulps   Xmm1, Xmm0
        !Mov rax, [p.p_OUT]
        !Movups  [rax], Xmm1      
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_IN1]
      	!Mov edx, [p.p_IN2]
        !Movups  Xmm0, [eax]
        !Movups  Xmm1, [edx]
        !Mulps   Xmm1, Xmm0
        !Mov eax, [p.p_OUT]
        !Movups  [eax], Xmm1
          
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
         mac_Vector4_MUL(*OUT, *IN1, *IN2)        
       
      CompilerDefault             ; Classic Version
        mac_Vector4_MUL(*OUT, *IN1, *IN2)        
        
    CompilerEndSelect
  
  EndProcedure
  
  Procedure sVector_Div(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector) 
    
    CompilerSelect #MMX_USE_SSE
   
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_IN1]
      	!Mov rdx, [p.p_IN2]
        !Movups  Xmm0, [rax]
        !Movups  Xmm1, [rdx]
        !Divps   Xmm0, Xmm1
        !Mov rax, [p.p_OUT]
        !Movups  [rax], Xmm0
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_IN1]
      	!Mov edx, [p.p_IN2]
        !Movups  Xmm0, [eax]
        !Movups  Xmm1, [edx]
        !Divps   Xmm0, Xmm1
        !Mov eax, [p.p_OUT]
        !Movups  [eax], Xmm0  
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector4_DIV(*OUT, *IN1, *IN2)        

      CompilerDefault             ; Classic Versio  
        mac_Vector4_DIV(*OUT, *IN1, *IN2)        
      
    CompilerEndSelect 
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------------------
  ; H O W  T O  S H U F F L E  ?  (reorder Elements!)
  ; ----------------------------------------------------------------------------------------------------
  ; XMM-Register      [ HH | HL | LH | LL ]  HH,HL,LH,LL are the 4 values
  ; Position-Index    [  3 |  2 |  1 |  0 ]  The Position Index, we need for Shuffle-Command, Position Index ix coded in 2-Bits
  ; Swap Position     [  0 |  1 |  2 |  3 ]  0-LL is on highest position than 1-LH, 2-HL, 3-HH
  ; Bit-Coded Mask    [ 00 | 01 | 10 | 11 ]  so our Shuffle-Mask is 00011011-Binary = $1B Hex
  ; ----------------------------------------------------------------------------------------------------
  ; In SSE it is !PSHUFD Command in AVX is VPERMPD
  
  ; A Shuffle description video on Youtube: https://www.youtube.com/watch?v=MOb9SZOdcXk

  Procedure sVector_Swap(*Vec.TsVector)
    
    CompilerSelect #MMX_USE_SSE
      
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_Vec]
        !Movups  Xmm0, [rax]
        !PShufd  Xmm1, Xmm0, $1B   ; Shuffle 4 packed DWORDs (should be faster than Shufps (Shuffel packed Single)
        !Movups  [rax], Xmm1     
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_Vec]
        !Movups  Xmm0, [eax]
        !Pshufd  Xmm1,Xmm0, $1B   ; 00011011b = $1b = [0,1,2,3]=[00b,01b,10b,11b]  (SSE: Pshufd => AVX: Vpermpd)
        !Movups  [eax], Xmm1
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        Swap *Vec\x, *Vec\w
        Swap *Vec\y, *Vec\z
       
      CompilerDefault             ; Classic Version
        Swap *Vec\x, *Vec\w
        Swap *Vec\y, *Vec\z
        
    CompilerEndSelect  
  EndProcedure
  
  Procedure sVector_Scale(*Vec.TsVector, Factor.f)
    
    CompilerSelect #MMX_USE_SSE
      
      CompilerCase #MMX_SSE_x64     ; 64 Bit-Version       
 	      ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
        !Movss   Xmm0, [p.v_Factor]
        !Pshufd  Xmm0, Xmm0, $00    ; Shuffle Factor to all 4 sections
        !Mov rax, [p.p_Vec] 
        !Movups  Xmm1, [rax]        ; load Vector
        !Mulps   Xmm1, Xmm0
        !Movups  [rax], Xmm1
         
      CompilerCase #MMX_SSE_x32     ; 32 Bit Version
        !Movss   Xmm0, [p.v_Factor]
        !Pshufd  Xmm0, Xmm0, $00
        !Mov eax, [p.p_Vec] 
        !Movups  Xmm1, [eax]
        !Mulps   Xmm1,Xmm0
        !Movups  [eax], Xmm1
   
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector_Scale(*Vec, *Vec, Factor)        
        
      CompilerDefault               ; Classic Version
        mac_Vector_Scale(*Vec, *Vec, Factor)        
        
    CompilerEndSelect  
 
  EndProcedure
  
  Procedure sVectorCrossProduct(*OUT.TsVector, *IN1.TsVector, *IN2.TsVector)
    ; Das Krezprodukt erbigt einen zu den beiden Vectoren senkrechten Vector
    CompilerSelect #MMX_USE_SSE
        
      CompilerCase #MMX_SSE_x64     ; 64 Bit-Version
        ; From Drawing3D PureBasic Library (STARGATE) 
        ! MOV rax, [p.p_OUT]
  			! MOV rcx, [p.p_IN1]
  			! MOV rdx, [p.p_IN2]
  			! MOVUPS xmm0, [rcx]
  			! MOVUPS xmm1, [rdx]
  			! MOVAPS xmm2, xmm0
  			! MOVAPS xmm3, xmm1
  			! SHUFPS xmm0, xmm0, 01111000b
  			! SHUFPS xmm1, xmm1, 10011100b
  			! SHUFPS xmm2, xmm2, 10011100b
  			! SHUFPS xmm3, xmm3, 01111000b
  			! MULPS  xmm0, xmm1
  			! MULPS  xmm2, xmm3
  			! SUBPS  xmm0, xmm2
  			! MOVUPS [rax], xmm0
        
      CompilerCase #MMX_SSE_x32     ; 32 Bit Version
  			! MOV eax, [p.p_OUT]
  			! MOV ecx, [p.p_IN1]
  			! MOV edx, [p.p_IN2]
  			! MOVUPS xmm0, [ecx]
  			! MOVUPS xmm1, [edx]
  			! MOVAPS xmm2, xmm0
  			! MOVAPS xmm3, xmm1
  			! SHUFPS xmm0, xmm0, 01111000b
  			! SHUFPS xmm1, xmm1, 10011100b
  			! SHUFPS xmm2, xmm2, 10011100b
  			! SHUFPS xmm3, xmm3, 01111000b
  			! MULPS  xmm0, xmm1
  			! MULPS  xmm2, xmm3
  			! SUBPS  xmm0, xmm2
  			! MOVUPS [eax], xmm0
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_VectorCrossProduct(*Out, *IN1, *IN2)       
        
      CompilerDefault                   ; Classic Version
        mac_VectorCrossProduct(*Out, *IN1, *IN2)       
        
    CompilerEndSelect  
  EndProcedure
    
  Procedure sVector_X_Matrix(*OUT.TsVector, *IN.TsVector, *Matrix.TsMatrix)
    
    CompilerSelect #MMX_USE_SSE
        
      CompilerCase #MMX_SSE_x64     ; 64 Bit-Version
   	      ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
   			 !MOV     rax, [p.p_Matrix]
         !Movups Xmm4, [rax + $00]
         !Movups Xmm5, [rax + $10]
         !Movups Xmm6, [rax + $20]
         !Movups Xmm7, [rax + $30]         
         !Mov rax,  [p.p_IN] 
         !Movups Xmm2, [rax]
         ; Line 0
         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4
         ; Line 1
         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1
         ; Line 2
         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1
         ; Line 3
         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1
         ; Return Result
         !Mov rax,  [p.p_OUT] 
         !Movups [rax], Xmm0
        
  		CompilerCase #MMX_SSE_x32     ; 32 Bit Version
   			 !MOV     eax, [p.p_Matrix]
         !Movups Xmm4, [eax + $00]
         !Movups Xmm5, [eax + $10]
         !Movups Xmm6, [eax + $20]
         !Movups Xmm7, [eax + $30]         
         !Mov eax,  [p.p_IN] 
         !Movups Xmm2, [eax]
         ; Line 0
         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4
         ; Line 1
         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1
         ; Line 2
         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1
         ; Line 3
         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1
         ; Return Result
         !Mov eax,  [p.p_OUT] 
         !Movups [eax], Xmm0
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend  
        mac_Vextor_X_Matrix(*OUT, *IN, *Matrix)
        
      CompilerDefault                   ; Classic Version
        mac_Vextor_X_Matrix(*OUT, *IN, *Matrix)
        
    CompilerEndSelect  
   
  EndProcedure
  
  Procedure sMatrix_X_Matrix(*OUT.TsMatrix, *M1.TsMatrix, *M2.TsMatrix)
    
    CompilerSelect #MMX_USE_SSE
        
      CompilerCase #MMX_SSE_x64     ; 64 Bit-Version
  	     ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
  			 !MOV     rax, [p.p_M1]
         !Movups Xmm4, [rax + $00]
         !Movups Xmm5, [rax + $10]
         !Movups Xmm6, [rax + $20]
         !Movups Xmm7, [rax + $30]
         
         ; Spalte 0
   			 !MOV     rax, [p.p_M2]     ; M2
         !Movups Xmm2, [rax + $00]
         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4
         
         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1

    		 !MOV     rdx, [p.p_OUT]      ; OUT
         !Movups [rdx + $00], Xmm0

         ; Spalte 1
         !Movups Xmm2, [rax + $10]    ; M2
         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4

         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1

         !Movups   [rdx + $10], Xmm0 ; OUT

         ; Spalte 2
         !Movups  Xmm2, [rax + $20] ; M2

         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4

         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1

         !Movups [rdx + $20], Xmm0 ; OUT

         ; Spalte 3
         !Movups Xmm2, [rax + $30]  ; M2

         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4

         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1

         !Movups [rdx + $30], Xmm0 ; OUT
        
      CompilerCase #MMX_SSE_x32     ; 32 Bit Version
 			   !MOV     eax, [p.p_M1]
         !Movups Xmm4, [eax + $00]
         !Movups Xmm5, [eax + $10]
         !Movups Xmm6, [eax + $20]
         !Movups Xmm7, [eax + $30]
         
         ; Spalte 0
   			 !MOV     eax, [p.p_M2]     ; M2
         !Movups Xmm2, [eax + $00]
         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4
         
         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1

    		 !MOV     edx, [p.p_OUT]      ; OUT
         !Movups [edx + $00], Xmm0

         ; Spalte 1
         !Movups Xmm2, [eax + $10]    ; M2
         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4

         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1

         !Movups   [edx + $10], Xmm0 ; OUT

         ; Spalte 2
         !Movups  Xmm2, [eax + $20] ; M2

         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4

         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1

         !Movups [edx + $20], Xmm0 ; OUT

         ; Spalte 3
         !Movups Xmm2, [eax + $30]  ; M2

         !Pshufd Xmm0, Xmm2, 00000000b
         !Mulps  Xmm0, Xmm4

         !Pshufd Xmm1, Xmm2, 01010101b
         !Mulps  Xmm1, Xmm5
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 10101010b
         !Mulps  Xmm1, Xmm6
         !Addps  Xmm0, Xmm1

         !Pshufd Xmm1, Xmm2, 11111111b
         !Mulps  Xmm1, Xmm7
         !Addps  Xmm0, Xmm1

         !Movups [edx + $30], Xmm0 ; OUT
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        max_Matrix_X_Matrix(*OUT, *M1, *M2) 
        
      CompilerDefault                   ; Classic Version
        max_Matrix_X_Matrix(*OUT, *M1, *M2) 
    CompilerEndSelect    
    
  EndProcedure
  
  
  ;- ----------------------------------------------------------------------
  ;-  Double precision functions .d AVX-256-Bit-YMM-Register
  ;- ----------------------------------------------------------------------
  ; Assembler Commands at:  https://hjlebbink.github.io/x86doc/
  
  ; ATTENTION: For SSE single Flaot shuffling 
  ; SSE : PShufd  Xmm1, Xmm0, $1b => AVX : Vpermpd Ymm1, Ymm0, $1b  (Permute Double-Precision Floating-Point Elements)
  ; 
  ; The AVX Vpshufd has other function
    
  Procedure dVector_Add(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector) 
        
    CompilerSelect #MMX_USE_SSE
      
      CompilerCase #MMX_SSE_x64     ; 64 Bit-Version
        !Mov rax, [p.p_IN1]         ; Move Data-Pointer 1 to rax
      	!Mov rdx, [p.p_IN2]         ; Move Data-Pointer 2 to rdx
        !Vmovupd  Ymm0, [rax]       ; Move 32 Byte from Data 1 to Ymm0 Register
        !Vmovupd  Ymm1, [rdx]       ; Move 32 Byte from Data 2 to Ymm1 Register
        !Vaddpd   Ymm2, Ymm1, Ymm0  ; Add 4 packed double precision Float
        !Mov rax, [p.p_OUT]         ; Move Data-Pointer of Result to rax
        !Vmovupd  [rax], Ymm2       ; Move the 32-Byte Result to our Result Data
        
      CompilerCase #MMX_SSE_x32     ; 32 Bit Version
        !Mov eax, [p.p_IN1]
      	!Mov edx, [p.p_IN2]
      	!Vmovupd  Ymm0, [eax]       ; VectorMoveUnalignedPackedDouble
        !Vmovupd  Ymm1, [edx]
        !Vaddpd   Ymm2, Ymm1, Ymm0  ; VectorAddPackedDouble
        !Mov eax, [p.p_OUT]
        !Vmovupd  [eax], Ymm2
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector_ADD(*OUT, *IN1, *IN2)        
        ; __m256d c = _mm256_add_pd(a, b ; 
        
      CompilerDefault             ; Classic Version
        mac_Vector_ADD(*OUT, *IN1, *IN2)        
    CompilerEndSelect
    
  EndProcedure
  
  Procedure dVector_Sub(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector) 
        
    CompilerSelect #MMX_USE_SSE
          
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_IN1]
      	!Mov rdx, [p.p_IN2]
        !Vmovupd  Ymm0, [rax]
        !Vmovupd  Ymm1, [rdx]
        !Vsubpd   Ymm1, Ymm0
        !Mov rax, [p.p_OUT]
        !Vmovupd  [rax], Ymm1     
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_IN1]
      	!Mov edx, [p.p_IN2]
        !Vmovupd  Ymm0, [eax]
        !Vmovupd  Ymm1, [edx]
        !Vsubpd   Ymm2, Ymm1, Ymm0
        !Mov eax, [p.p_OUT]
        !Vmovupd  [eax], Ymm2
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector_SUB(*OUT, *IN1, *IN2)    
        ; __m256d c = _mm256_sub_pd(a, b ; 

      CompilerDefault             ; Classic Version
        mac_Vector_SUB(*OUT, *IN1, *IN2)        
    CompilerEndSelect  
  EndProcedure
  
  Procedure dVector_Mul(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector) 
    
    CompilerSelect #MMX_USE_SSE
      
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_IN1]
      	!Mov rdx, [p.p_IN2]
        !Vmovupd  Ymm0, [rax]
        !Vmovupd  Ymm1, [rdx]
        !Vmulpd   Ymm1, Ymm1, Ymm0
        !Mov rax, [p.p_OUT]
        !Vmovupd  [rax], Ymm1      
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_IN1]
      	!Mov edx, [p.p_IN2]
        !Vmovupd  Ymm0, [eax]
        !Vmovupd  Ymm1, [edx]
        !Vmulpd   Ymm1, Ymm1, Ymm0
        !Mov eax, [p.p_OUT]
        !Vmovupd  [eax], Ymm1
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector_MUL(*OUT, *IN1, *IN2)        
         
      CompilerDefault             ; Classic Version
        mac_Vector_MUL(*OUT, *IN1, *IN2)        
        
    CompilerEndSelect 
  EndProcedure
  
  Procedure dVector_Div(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector) 
    
    CompilerSelect #MMX_USE_SSE
   
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_IN1]
      	!Mov rdx, [p.p_IN2]
        !Vmovupd  Ymm0, [rax]
        !Vmovupd  Ymm1, [rdx]
        !Vdivpd   Ymm1, Ymm0, Ymm1
        !Mov rax, [p.p_OUT]
        !Vmovupd  [rax], Ymm1
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_IN1]
      	!Mov edx, [p.p_IN2]
        !Vmovupd  Ymm0, [eax]
        !Vmovupd  Ymm1, [edx]
        !Vdivpd   Ymm1, Ymm0, Ymm1
        !Mov eax, [p.p_OUT]
        !Vmovupd  [eax], Ymm1  
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector_DIV(*OUT, *IN1, *IN2)        
        
      CompilerDefault             ; Classic Version  
        mac_Vector_DIV(*OUT, *IN1, *IN2)        
      
    CompilerEndSelect 
  EndProcedure
  
  
;         !Mov eax, [p.p_Vec]
;         !Movups  Xmm0, [eax]
;         !Pshufd  Xmm1,Xmm0, $1b   ; Shuffle 4 packed DWORDs (should be faster than Shufps (Shuffel packed Single)
;         !Movups  [eax], Xmm1

  Procedure dVector_Swap(*Vec.TdVector)
    ;   Result\x = Vec\w
    ;   Result\y = Vec\z
    ;   Result\z = Vec\y
    ;   Result\w = Vec\y
    
    CompilerSelect #MMX_USE_SSE
      
      CompilerCase #MMX_SSE_x64   ; 64 Bit-Version
        !Mov rax, [p.p_Vec]
        !Vmovupd  Ymm0, [rax]
        !Vpermpd  Ymm1, Ymm0, $1b  ; 
        !Movupd  [rax], Ymm1     
        
      CompilerCase #MMX_SSE_x32   ; 32 Bit Version
        !Mov eax, [p.p_Vec]
        !Vmovupd  Ymm0, [eax]
        !Vpermpd  Ymm1, Ymm0, $1b  ; 00011011b = $1b = [0,1,2,3]=[00b,01b,10b,11b]  (SSE: Pshufd => AVX: Vpermpd)
        !Vmovupd  [eax], Ymm1
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        Swap *Vec\x, *Vec\w
        Swap *Vec\y, *Vec\z
       
      CompilerDefault             ; Classic Version
        Swap *Vec\x, *Vec\w
        Swap *Vec\y, *Vec\z
        
    CompilerEndSelect  
  EndProcedure
  
  Procedure dVector_Scale(*Vec.TdVector, Factor.d)
    
    CompilerSelect #MMX_USE_SSE
      
      CompilerCase #MMX_SSE_x64       ; 64 Bit-Version
        !Vmovsd   Xmm0, [p.v_Factor]  ; Load Factor 8-Bytes to Lo Register mm0  
        !Vpermpd  Ymm0, Ymm0, $00     ; Shuffle Factor to all 4 sections
        !Mov rax, [p.p_Vec] 
        !Vmovupd  Ymm1, [rax]         ; load Vector
        !Vmulpd   Ymm2 , Ymm1, Ymm0   ; Ymm2 = Ymm1 * Ymm0
        !Vmovupd  [rax], Ymm2
         
      CompilerCase #MMX_SSE_x32       ; 32 Bit Version
        !Vmovsd   Xmm0, [p.v_Factor]
        !Vpermpd  Ymm0, Ymm0, $00
        !Mov eax, [p.p_Vec] 
        !Vmovupd  Ymm1, [eax]
        !Vmulpd   Ymm2 ,Ymm1, Ymm0
        !Vmovupd  [eax], Ymm2
   
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_Vector_Scale(*Vec, *Vec, Factor)        
        
      CompilerDefault               ; Classic Version
        mac_Vector_Scale(*Vec, *Vec, Factor)        
        
    CompilerEndSelect  
 
  EndProcedure
  
  Procedure dVectorCrossProduct(*OUT.TdVector, *IN1.TdVector, *IN2.TdVector)
    ; Das Krezprodukt erbigt einen zu den beiden Vectoren senkrechten Vector
    CompilerSelect #MMX_USE_SSE
        
      CompilerCase #MMX_SSE_x64     ; 64 Bit-Version
  			! Mov rax, [p.p_OUT]
  			! Mov rcx, [p.p_IN1]
  			! Mov rdx, [p.p_IN2]
  			! Vmovupd Ymm0, [rcx]         ; unaligned packed double
  			! Vmovupd Ymm1, [rdx]
  			! Vmovapd Ymm2, Ymm0          ; aligned packed double
  			! Vmovapd Ymm3, Ymm1
  			! Vpermpd Ymm0, Ymm0, 01111000b
  			! Vpermpd Ymm1, Ymm1, 10011100b
  			! Vpermpd Ymm2, Ymm2, 10011100b
  			! Vpermpd Ymm3, Ymm3, 01111000b
  			! Vmulpd  Ymm0, Ymm0, Ymm1
  			! Vmulpd  Ymm2, Ymm2, Ymm3
  			! Vsubpd  Ymm0, Ymm0, Ymm2
  			! Vmovupd [rax], Ymm0
        
      CompilerCase #MMX_SSE_x32     ; 32 Bit Version
  			! MOV eax, [p.p_OUT]
  			! MOV ecx, [p.p_IN1]
  			! MOV edx, [p.p_IN2]
  			! Vmovupd Ymm0, [ecx]
  			! Vmovupd Ymm1, [edx]
  			! Vmovapd Ymm2, Ymm0
  			! Vmovapd Ymm3, Ymm1
  			! Vpermpd Ymm0, Ymm0, 01111000b
  			! Vpermpd Ymm1, Ymm1, 10011100b
  			! Vpermpd Ymm2, Ymm2, 10011100b
  			! Vpermpd Ymm3, Ymm3, 01111000b
  			! Vmulpd  Ymm0, Ymm0, Ymm1
  			! Vmulpd  Ymm2, Ymm2, Ymm3
  			! Vsubpd  Ymm0, Ymm0, Ymm2
  			! Vmovupd [eax], Ymm0
        
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        mac_VectorCrossProduct(*Out, *IN1, *IN2)       
        
      CompilerDefault                   ; Classic Version
        mac_VectorCrossProduct(*Out, *IN1, *IN2)       
        
    CompilerEndSelect  

  EndProcedure
  
  Procedure dVector_X_Matrix(*OUT.TdVector, *IN.TdVector, *Matrix.TdMatrix)
    
    CompilerSelect #MMX_USE_SSE
        
      CompilerCase #MMX_SSE_x64     ; 64 Bit-Version
   	      ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
   			 !MOV     rax, [p.p_Matrix]
         !Vmovupd Ymm4, [rax + $00]
         !Vmovupd Ymm5, [rax + $20]
         !Vmovupd Ymm6, [rax + $40]
         !Vmovupd Ymm7, [rax + $40]         
         !Mov rax,  [p.p_IN] 
         !Vmovupd Ymm2, [rax]
         ; Line 0
         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4
         ; Line 1
         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm1
         ; Line 2
         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm1
         ; Line 3
         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1
         ; Return Result
         !Mov rax,  [p.p_OUT] 
         !Vmovupd [rax], Ymm0
        
  		CompilerCase #MMX_SSE_x32     ; 32 Bit Version
   			 !MOV     eax, [p.p_Matrix]
         !Vmovupd Ymm4, [eax + $00]
         !Vmovupd Ymm5, [eax + $20]
         !Vmovupd Ymm6, [eax + $40]
         !Vmovupd Ymm7, [eax + $40]         
         !Mov eax,  [p.p_IN] 
         !Vmovupd Ymm2, [eax]
         ; Line 0
         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4
         ; Line 1
         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm1
         ; Line 2
         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm1
         ; Line 3
         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1
         ; Return Result
         !Mov eax,  [p.p_OUT] 
         !Vmovupd [eax], Ymm0
       
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend  
        mac_Vextor_X_Matrix(*OUT, *IN, *Matrix)
        
      CompilerDefault                   ; Classic Version
        mac_Vextor_X_Matrix(*OUT, *IN, *Matrix)
        
    CompilerEndSelect  
   
  EndProcedure
  
  Procedure dMatrix_X_Matrix(*OUT.TdMatrix, *M1.TdMatrix, *M2.TdMatrix)
    
    CompilerSelect #MMX_USE_SSE
        
      CompilerCase #MMX_SSE_x64     ; 64 Bit-Version
  	     ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
  			 !MOV     rax, [p.p_M1]
         !Vmovupd Ymm4, [rax + $00]
         !Vmovupd Ymm5, [rax + $20]
         !Vmovupd Ymm6, [rax + $40]
         !Vmovupd Ymm7, [rax + $60]
         
         ; Spalte 0
   			 !MOV     rax, [p.p_M2]     ; M2
         !Vmovupd Ymm2, [rax + $00]
         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4
         
         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1

    		 !MOV     rdx, [p.p_OUT]      ; OUT
         !Vmovupd [rdx + $00], Ymm0

         ; Spalte 1
         !Vmovupd Ymm2, [rax + $20]    ; M2
         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4

         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vmovupd   [rdx + $20], Ymm0 ; OUT

         ; Spalte 2
         !Vmovupd  Ymm2, [rax + $40] ; M2

         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4

         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vmovupd [rdx + $40], Ymm0 ; OUT

         ; Spalte 3
         !Vmovupd Ymm2, [rax + $60]  ; M2

         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4

         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vmovupd [rdx + $60], Ymm0 ; OUT
        
      CompilerCase #MMX_SSE_x32     ; 32 Bit Version
  			 !MOV     eax, [p.p_M1]
         !Vmovupd Ymm4, [eax + $00]
         !Vmovupd Ymm5, [eax + $20]
         !Vmovupd Ymm6, [eax + $40]
         !Vmovupd Ymm7, [eax + $60]
         
         ; Spalte 0
   			 !MOV     eax, [p.p_M2]     ; M2
         !Vmovupd Ymm2, [eax + $00]
         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4
         
         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1

    		 !MOV     edx, [p.p_OUT]      ; OUT
         !Vmovupd [edx + $00], Ymm0

         ; Spalte 1
         !Vmovupd Ymm2, [eax + $20]    ; M2
         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4

         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vmovupd   [edx + $20], Ymm0 ; OUT

         ; Spalte 2
         !Vmovupd  Ymm2, [eax + $40] ; M2

         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4

         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vmovupd [edx + $40], Ymm0 ; OUT

         ; Spalte 3
         !Vmovupd Ymm2, [eax + $60]  ; M2

         !Vpermpd Ymm0, Ymm2, 00000000b
         !Vmulpd  Ymm0, Ymm0, Ymm4

         !Vpermpd Ymm1, Ymm2, 01010101b
         !Vmulpd  Ymm1, Ymm1, Ymm5
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 10101010b
         !Vmulpd  Ymm1, Ymm1, Ymm6
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vpermpd Ymm1, Ymm2, 11111111b
         !Vmulpd  Ymm1, Ymm1, Ymm7
         !Vaddpd  Ymm0, Ymm0, Ymm1

         !Vmovupd [edx + $60], Ymm0 ; OUT
         
      CompilerCase #MMX_SSE_C_Backend   ; for the C-Backend
        max_Matrix_X_Matrix(*OUT, *M1, *M2) 
        
      CompilerDefault                   ; Classic Version
        max_Matrix_X_Matrix(*OUT, *M1, *M2) 
    CompilerEndSelect  
    
    
  EndProcedure
EndModule

CompilerIf #PB_Compiler_IsMainFile    
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------

  EnableExplicit
  UseModule MMX
  
  ; ----------------------------------------------------------------------
  ;  Define Variables
  ; ----------------------------------------------------------------------
  Global.TsVector sA, sB, sC    ; single Vectors
  Global.TdVector dA, dB, dC    ; double Vectors
  
  Global.i tim1, tim2, tim2, tim3 ; Timer to get execution time

  ; ----------------------------------------------------------------------
  ;  Macros
  ; ----------------------------------------------------------------------
  Macro mac_Debug_Result(Res, In1, In2)
    Debug "Result   :  Input"
    Debug "X= " + Res\x  + #TAB$ + " :  " + In1\x + #TAB$ + " :  " + In2\x
    Debug "Y= " + Res\y  + #TAB$ + " :  " + In1\y + #TAB$ + " :  " + In2\y
    Debug "Z= " + Res\z  + #TAB$ + " :  " + In1\z + #TAB$ + " :  " + In2\z
    Debug "W= " + Res\w  + #TAB$ + " :  " + In1\w + #TAB$ + " :  " + In2\w
    Debug ""
  EndMacro
  
   Macro mac_Debug_AB(A,B)
    Debug " A         :    B"
    Debug "X= " + A\x  + #TAB$ + " :  " + B\x
    Debug "Y= " + A\y  + #TAB$ + " :  " + B\y
    Debug "Z= " + A\z  + #TAB$ + " :  " + B\z
    Debug "W= " + A\w  + #TAB$ + " :  " + B\w
    Debug ""
  EndMacro

  ; Macro to set our Vectors sA, sB, dA, dB to the basic values
  Macro SetVectorBasicValues()
    ; set the single Vectors
    SetVector4(sA,  1, 2, 3, 4)
    SetVector4(sB, 10,20,30,40)
  
    ; set the double Vectors
    SetVector4(dA,  1, 2, 3, 4)
    SetVector4(dB, 10,20,30,40)
  EndMacro
   
  ; ----------------------------------------------------------------------
  ;  Test Procedures
  ; ----------------------------------------------------------------------

  Procedure Test_VectorAdd()  
    Debug "----------------------------------------"
    Debug "sVetor_Add()"    
    sVector_Add(sC, sA , sB)
    mac_Debug_Result(sC, sA, sB)
    
    Debug "dVetor_Add()"   
    dVector_Add(dC, dA , dB)
    mac_Debug_Result(dC, dA, dB)   
  EndProcedure
  
  Procedure Test_VectorSub()  
    Debug "----------------------------------------"
    Debug "sVetor_Sub()"   
    sVector_Sub(sC, sA , sB)
    mac_Debug_Result(sC, sA, sB)
    
    Debug "dVetor_Sub()"   
    dVector_Sub(dC, dA , dB)
    mac_Debug_Result(dC, dA, dB)    
  EndProcedure
 
  Procedure Test_VectorMul()  
    Debug "----------------------------------------"
    Debug "sVetor_Mul()"   
    sVector_Mul(sC, sA , sB)
    mac_Debug_Result(sC, sA, sB)
    
    Debug "dVetor_Mul()"   
    dVector_Mul(dC, dA , dB)
    mac_Debug_Result(dC, dA, dB)    
  EndProcedure

  Procedure Test_VectorDiv()  
    Debug "----------------------------------------"
    Debug "sVetor_Div()"   
    sVector_Div(sC, sA , sB)
    mac_Debug_Result(sC, sA, sB)
    
    Debug "dVetor_Div()"   
    dVector_Div(dC, dA , dB)
    mac_Debug_Result(dC, dA, dB)    
  EndProcedure
  
  Procedure Test_VectorSwap()  
    Debug "----------------------------------------"
    Debug "sVetor_Swap()"   
    sC = sA
    sVector_Swap(sC)
    mac_Debug_Result(sC, sA, sA)
    
    Debug "dVetor_Swap()"   
    dC = dA
    dVector_Swap(dC)
    mac_Debug_Result(dC, dA, dA)    
  EndProcedure
  
  Procedure Test_VectorScale()  
    Debug "----------------------------------------"
    Debug "sVetor_Scale(*2.5)"   
    sC = sA
    sVector_Scale(sC, 2.5)
    mac_Debug_Result(sC, sA, sA)
    
   Debug "dVetor_Scale(*2.5)"   
    dC = dA
    dVector_Scale(dC, 2.5)
    mac_Debug_Result(dC, dA, dA)    
  EndProcedure

  Procedure Test_VectorCrossProduct()  
    Debug "----------------------------------------"
    Debug "sVetor_VectorCrossProduct()"
    SetVector4(sA, 2, -1, 5 ,0)
    SetVector4(sB, 6, 7, 2 , 0)
    ; correct Result = (-37,26,20) 
    sVectorCrossProduct(sC, sA, sB)
    Debug ("correct Result (-37,26,20)")
    mac_Debug_Result(sC, sA, sA)
    
   Debug "dVetor_VectorCrossProduct()"   
    SetVector4(dA, 2, -1, 5 ,0)
    SetVector4(dB, 6, 7, 2 , 0)
    dVectorCrossProduct(dC, dA, dB)
    Debug ("correct Result (-37,26,20)")
    mac_Debug_Result(dC, dA, dA)    
  EndProcedure
 
  SetVectorBasicValues()        ; Set Vectors to basic valus
  
  Debug "----------------------------------------"
  mac_Debug_AB(sA, sB)  ; Show A and B in Debug output
  
  ; correct Results at x32
  Test_VectorAdd()          ; Test the Vector_Add funtions
  Test_VectorSub()          ; Test the Vector_Sub funtions
  Test_VectorMul()          ; Test the Vector_Mul funtions
  Test_VectorDiv()          ; Test the Vector_Div funtions
  Test_VectorSwap()         ; Test the Vector_Div funtions
  Test_VectorScale()        ; Test the Vector_Div funtions
  
  ; Wrong Result
  Test_VectorCrossProduct() ; Test the Vector_CrossProduct funtions
  
  ; Not Implemented and not tested
  ; Test_Vector_X_Matrix
  ; Test_Matrix _X_Matrix
CompilerEndIf


; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 1544
; Folding = 6--------
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)