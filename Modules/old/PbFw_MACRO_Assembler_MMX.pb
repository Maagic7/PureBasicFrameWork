; ===========================================================================
; FILE : PbFw_MACRO_Assembler_MMX.pb
; NAME : PureBasic Framework : Assembler Macros for Multi-Media-Extention
; DESC : Assembler Macros for MMX/SSE/AVX
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/04
; VERSION  :  0.1 untested Developper Version
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

Macro PshufdMulpsAddps(reg, shufle)
	!Pshufd Xmm1, Xmm2, shufle
	!Mulps  Xmm1, reg
	!Addps  Xmm0, Xmm1
EndMacro

; PshufdMulpsAddps(Xmm5, 01010101b)


; use only for debug Print, because in the Assembler Code this will not work
Macro CreateShuffle(HH, HL, LH, LL)
  LL | (LH<<2) | (HL<<4) | (HH<<6)   
EndMacro

Debug Hex(CreateShuffle(0,1,2,3))

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 263
; Folding = x-
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)