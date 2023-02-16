; ===========================================================================
; FILE : PbFw_Module_VECTORd.pb
; NAME : PureBasic Framework : Module VECTORd [VEDd::]
; DESC : Double precicion Vector Library
; DESC : using the MMX, SSE Registers, to speed up vector operations
; DESC : For single precicion Vectors use VECTORf [VECf::]
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
; VERSION  :  0.11 untested Developper Version
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog: 
;{ 2022/12/11 S.Maag : added SetMatrix-Functions
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
XIncludeFile "PbFw_Module_CPU.pb"

;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule VECd
  EnableExplicit
  
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
      
  ; Vector ist immer aus 4 Elementen, sonst macht das keinen Sinn
  ; die Unterscheidung Vector3, Vector4 bringt nur Nachteile statt Vorteile
  ; Man braucht neben den x,y,z,w Kooridnaten noch die Möglichkeit des
  ; indizierten Zugriffs des dürfte für Matrix-Operationen besser sein!
   
  Structure TVector  ; Double precicion Vector [32 Bytes / 256 Bit]
    StructureUnion
      v.d[0]          ; virutal Array  v[0]=x, v[1]=y, v[2]=z, v[3]=w
    EndStructureUnion
    x.d
    y.d
    z.d  
    w.d
  EndStructure
  
  Debug "SyzeOf(TVector) = " + SizeOf(TVector)
     
  Structure TMatrix  ; Double precicion Matrix
    v.TVector[4]   ; 4 Elements 0..3
  EndStructure
  
  Structure pTMatrix  ; Pointer to virtual TVector-Array 
    m.TMatrix[0]      ; Virtual Array of *TVector  
  EndStructure

  Macro mac_SetVector(Vec, _X, _Y, _Z, _W)
    Vec\x = _X
    Vec\y = _Y
    Vec\z = _Z
    Vec\w = _W
  EndMacro

  Macro mac_ClearVector(Vec)
    Vec\x = 0
    Vec\y = 0
    Vec\z = 0
    Vec\w = 0   
  EndMacro
  
  Macro mac_ClearMatrix(Matrix)
    ClearVector(Matrix\v[0])
    ClearVector(Matrix\v[1])
    ClearVector(Matrix\v[2])  
    ClearVector(Matrix\v[3])
  EndMacro
    
  ; Declare Vector Functions
  Declare.i Vector_Add(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  Declare.i Vector_Sub(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  Declare.i Vector_Mul(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  Declare.i Vector_Div(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  Declare.i Vector_Swap(*OUT.TVector, *IN.Tvector)
  Declare.i Vector_Copy(*OUT.TVector, *IN.TVector)
  Declare.i Vector_Set(*Out.TVector, X.d=0.0, Y.d=0.0, Z.d=0.0, W.d=0.0)
  Declare.d Vector_Length(*In.TVector)
  Declare.i Vector_Normalize(*InOut.TVector)
  Declare.d Vector_Scalar(*IN1.TVector, *IN2.TVector)
  Declare.i Vector_Scale(*OUT.TVector, *IN.TVector, Factor.d)
  Declare.i Vector_CrossProduct(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  
   ; Declare Matrix Functions
  Declare.i SetMatrixIdentity(*Matrix) ; EinheitsMatrix
  Declare.i SetMatrixRotZ(*Matrix, Angle.d)
  Declare.i SetMatrixTranslation(*Matrix, dX.d, dY.d, dZ.d)
  Declare.i SetMatrixScale(*Matrix.TMatrix, Sx.D, Sy.D, Sz.D)
	Declare.i SetMatrixRotX(*Matrix, Angle.d)
  Declare.i SetMatrixRotY(*Matrix, Angle.d)
  Declare.i Vector_X_Matrix(*OUT.TVector, *IN.TVector, *Matrix.TMatrix) 
  Declare.i Matrix_X_Matrix(*OUT.TMatrix, *M1.TMatrix, *M2.TMatrix)
  
  Declare.d MinOf3(Value1.d, Value2.d, Value3.d=1e1000)
  Declare.d MaxOf3(Value1.d, Value2.d, Value3.d=-1e1000)

EndDeclareModule
  
  Module VECd
  ;- ----------------------------------------------------------------------
  ;- Module Private
  ;- ----------------------------------------------------------------------
          
  Enumeration 
    #VEC_MMX_OFF            ; No SSE present
    #VEC_MMX_x32
    #VEC_MMX_X64
    #VEC_SSE_x32        ; 32-Bit Assembler SSE Code
    #VEC_SSE_x64        ; 64-Bot Assembler SSE Code
    #VEC_SSE_C_Backend  ; For Future use in the C-Backend (maybe it will be possible To force SSE optimation with the C intrinsic Macros)
  EndEnumeration  
  
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
    
    ; **********  32 BIT  **********
    CompilerIf CPU::#CPU_APPx32_SSE
      #VEC_USE_MMX = #VEC_SSE_x32             ; x32 SSE ASM
      
    CompilerElseIf CPU::#CPU_APPx32_MMX
      #VEC_USE_MMX = #VEC_MMX_x32             ; X32 MMX ASM
      
    ; **********  64 BIT  **********
    CompilerElseIf CPU::#CPU_APPx64_SSE
       #VEC_USE_MMX = #VEC_SSE_x64            ; X64 SSE ASM
       
     CompilerElseIf CPU::#CPU_APPx32_MMX
      #VEC_USE_MMX = #VEC_MMX_X64             ; x64 SSE MMX
      
    CompilerElse
       #VEC_USE_MMX = #VEC_MMX_OFF            ; MMX OFF
    CompilerEndIf
      
  CompilerElseIf    #PB_Compiler_Backend = #PB_Backend_C
    
    If CPU::#CPU_APPx32_SSE | CPU::#CPU_APPx32_MMX | CPU::#CPU_APPx64_SSE | CPU::#CPU_APPx64_MMX
      #VEC_USE_MMX = #VEC_SSE_C_Backend       ; Activate C-Backend-MMX optimation 
    Else
       #VEC_USE_MMX = #VEC_MMX_OFF            ; MMX OFF
    EndIf
    
  CompilerElse
    #VEC_USE_MMX = #VEC_MMX_OFF
  CompilerEndIf 
 
    
; TEMPLATE Compiler Select SSE
;     CompilerSelect #VEC_USE_MMX
;         
;       CompilerCase #VEC_SSE_x64     ; 64 Bit-Version
;         
;       CompilerCase #VEC_SSE_x32     ; 32 Bit Version
;         
;       CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
;         
;       CompilerDefault                   ; Classic Version
;         
;     CompilerEndSelect  
  
  ;  ----------------------------------------------------------------------
  ;- Assembler Macros : MMX/SSE optimized routines
  ;- ----------------------------------------------------------------------
  
  ; Assembler Macros for double precicion Vector calculations
  ; using 256Bit AVX-Registers
  
  ; The Macro has always the same structure, for x32/x64 we hvae to change
  ; only the Register-Parameters! So call:
  ; MacroName(EAX, EDX, ECX) for x32
  ; MacroName(RAX, RDX, RCX) for x64
  
  ; ATTENTION in PureBasic Inline-Assembler we can use 
  ; only the following registers
  ; EAX,EDX,ECX XMM0..XMM3
  ; RAX,RDX,RCX,R8,R9, XMM0..XMM3
  
  Macro ASM_Vector_Add(REGA, REGD, REGC)
    ;Vector_Add(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
      !MOV REGA, [p.p_IN2]
    	!MOV REGD, [p.p_IN1]
      !VMOVUPD  YMM0, [REGA]
      !VMOVUPD  YMM1, [REGD]
      !VSUBPD   YMM1, YMM1, YMM0
      !MOV REGA, [p.p_OUT]
      !VMOVUPD  [REGA], YMM1     
  EndMacro
    
  Macro ASM_Vector_Sub(REGA, REGD, REGC) 
    ;Vector_Sub(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
      !MOV REGA, [p.p_IN2]
    	!MOV REGD, [p.p_IN1]
      !VMOVUPD  YMM0, [REGA]
      !VMOVUPD  YMM1, [REGD]
      !VSUBPD   YMM1, YMM1, YMM0
      !MOV REGA, [p.p_OUT]
      !VMOVUPD  [REGA], YMM1     
  EndMacro
  
  Macro ASM_Vector_Mul (REGA, REGD, REGC) 
    ;Vector_Mul(*OUT.TVector, *IN1.TVector, *IN2.TVector)
      !MOV REGA, [p.p_IN1]
    	!MOV REGD, [p.p_IN2]
      !VMOVUPD  YMM0, [REGA]
      !VMOVUPD  YMM1, [REGD]
      !VMULPD   YMM1, YMM1, YMM0
      !MOV REGA, [p.p_OUT]
      !VMOVUPD  [REGA], YMM1      
   EndMacro
   
  Macro ASM_Vector_Div (REGA, REGD, REGC) 
    ;Vector_Div(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
      !MOV REGA, [p.p_IN1]
    	!MOV REGD, [p.p_IN2]
      !VMOVUPD  YMM0, [REGA]
      !VMOVUPD  YMM1, [REGD]
      !Vdivpd   YMM1, YMM0, YMM1
      !MOV REGA, [p.p_OUT]
      !VMOVUPD  [REGA], YMM1
  EndMacro 
  
  Macro ASM_Vector_Min(REGA, REGD, REGC) 
  		!MOV    REGA, [p.p_OUT]
			!MOV    REGC, [p.p_IN1]
			!MOV    REGD, [p.p_IN2]
			!VMOVUPD YMM1, [REGC]       ; IN1
			!VMOVUPD YMM2, [REGD]       ; IN2
			!VMINPS  YMM0, YMM1, YMM2
			!VMOVUPD [REGA], YMM0    
  EndMacro
  
  Macro ASM_Vector_Max(REGA, REGD, REGC) 
  		!MOV    REGA, [p.p_OUT]
			!MOV    REGC, [p.p_IN1]
			!MOV    REGD, [p.p_IN2]
			!VMOVUPD YMM1, [REGC]       ; IN1
			!VMOVUPD YMM2, [REGD]       ; IN2
			!VMAXPS  YMM0, YMM1, YMM3
			!MOVUPS [REGA], YMM0    
  EndMacro
  
  Macro ASM_Vector_MinMax(REGA, REGD, REGC) 
  		!MOV    REGA, [p.p_OutMin]
			!MOV    REGC, [p.p_IN1]
			!MOV    REGD, [p.p_IN2]
			
			!VMOVUPD YMM1, [REGC]       ; IN1			
			!VMOVUPD YMM2, [REGD]       ; IN2
			
			!VMINPD  YMM0, YMM1, YMM2   ; Minimum to YMM0
			!VMAXPD  YMM3, YMM1, YMM2   ; Maximum to YMM3
			
			!VMOVUPD [REGA], YMM0       ; Min
			!MOV     REGA, [p.p_OutMax]
			!VMOVUPD [REGA], YMM3       ; Max				
  EndMacro

  Macro ASM_Vector_Swap (REGA, REGD, REGC) 
    ;Vector_Swap(*OUT.TVector, *IN.Tvector)
      !MOV REGA, [p.p_IN]
      !VMOVUPD  YMM0, [REGA]
      !VPERMPD  YMM1, YMM0, $1b  ; 
      !MOV REGA, [p.p_OUT]
      !VMOVUPD  [REGA], YMM1     
  EndMacro
  
  Macro ASM_Vector_Scale (REGA, REGD, REGC) 
    ;Vector_Scale(*OUT.TVector, *IN.TVector, Factor.d)
      !VMOVQ    XMM0, QWORD [p.v_Factor]  ; Load Factor 8-Bytes to Lo Register Xmm0  
      !VPERMPD  YMM0, YMM0, $00           ; Shuffle Factor to all 4 sections
      !MOV REGA, [p.p_IN] 
      !VMOVUPD  YMM1, [REGA]              ; load Vector
      !VMULPD   YMM2 , YMM1, YMM0         ; YMM2 = YMM1 * YMM0
      !MOV REGA, [p.p_OUT] 
      !VMOVUPD  [REGA], YMM2
   EndMacro
  
  Macro ASM_Vector_CrossProduct (REGA, REGD, REGC) 
    ;Vector_CrossProduct(*OUT.TVector, *IN1.TVector, *IN2.TVector)
			!MOV REGA, [p.p_OUT]
			!MOV REGC, [p.p_IN1]
			!MOV REGD, [p.p_IN2]
			!VMOVUPD YMM0, [REGC]         ; unaligned packed double
			!VMOVUPD YMM1, [REGD]
			!VMOVAPD YMM2, YMM0          ; aligned packed double
			!VMOVAPD YMM3, YMM1
			!VPERMPD YMM0, YMM0, 11001001b
			!VPERMPD YMM1, YMM1, 11010010b
			!VPERMPD YMM2, YMM2, 11010010b
			!VPERMPD YMM3, YMM3, 11001001b
			!VMULPD  YMM0, YMM0, YMM1
			!VMULPD  YMM2, YMM2, YMM3
			!VSUBPD  YMM0, YMM0, YMM2
			!VMOVUPD [REGA], YMM0
 EndMacro
 
  Macro ASM_Vector_X_Matrix(REGA, REGD, REGC) 
   ;Vector_X_Matrix(*OUT.TVector, *IN.TVector, *Matrix.TMatrix)
  	  ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
      !MOV     REGA, [p.p_Matrix]
      !VMOVUPD YMM4, [REGA + $00]
      !VMOVUPD YMM5, [REGA + $20]
      !VMOVUPD YMM6, [REGA + $40]
      !VMOVUPD YMM7, [REGA + $40]         
      !MOV REGA,  [p.p_IN] 
      !VMOVUPD YMM2, [REGA]
      ; Line 0
      !VPERMPD YMM0, YMM2, 00000000b
      !VMULPD  YMM0, YMM0, YMM4
      ; Line 1
      !VPERMPD YMM1, YMM2, 01010101b
      !VMULPD  YMM1, YMM1, YMM5
      !VADDPD  YMM0, YMM1
      ; Line 2
      !VPERMPD YMM1, YMM2, 10101010b
      !VMULPD  YMM1, YMM1, YMM6
      !VADDPD  YMM0, YMM1
      ; Line 3
      !VPERMPD YMM1, YMM2, 11111111b
      !VMULPD  YMM1, YMM1, YMM7
      !VADDPD  YMM0, YMM0, YMM1
      ; Return Result
      !MOV REGA,  [p.p_OUT] 
      !VMOVUPD [REGA], YMM0
  EndMacro
  
  Macro ASM_Matrix_X_Matrix(REGA, REGD, REGC) 
    ;Matrix_X_Matrix(*OUT.TMatrix, *M1.TMatrix, *M2.TMatrix)
	    ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
			!MOV     REGA, [p.p_M1]
      !VMOVUPD YMM4, [REGA + $00]
      !VMOVUPD YMM5, [REGA + $20]
      !VMOVUPD YMM6, [REGA + $40]
      !VMOVUPD YMM7, [REGA + $60]
      
      ; Spalte 0
 			!MOV     REGA, [p.p_M2]     ; M2
      !VMOVUPD YMM2, [REGA + $00]
      !VPERMPD YMM0, YMM2, 00000000b
      !VMULPD  YMM0, YMM0, YMM4
      
      !VPERMPD YMM1, YMM2, 01010101b
      !VMULPD  YMM1, YMM1, YMM5
      !VADDPD  YMM0, YMM0, YMM1
      !VPERMPD YMM1, YMM2, 10101010b
      !VMULPD  YMM1, YMM1, YMM6
      !VADDPD  YMM0, YMM0, YMM1
      !VPERMPD YMM1, YMM2, 11111111b
      !VMULPD  YMM1, YMM1, YMM7
      !VADDPD  YMM0, YMM0, YMM1

      !MOV     REGD, [p.p_OUT]      ; OUT
      !VMOVUPD [REGD + $00], YMM0
      
      ; Spalte 1
      !VMOVUPD YMM2, [REGA + $20]    ; M2
      !VPERMPD YMM0, YMM2, 00000000b
      !VMULPD  YMM0, YMM0, YMM4
      
      !VPERMPD YMM1, YMM2, 01010101b
      !VMULPD  YMM1, YMM1, YMM5
      !VADDPD  YMM0, YMM0, YMM1
      
      !VPERMPD YMM1, YMM2, 10101010b
      !VMULPD  YMM1, YMM1, YMM6
      !VADDPD  YMM0, YMM0, YMM1
      
      !VPERMPD YMM1, YMM2, 11111111b
      !VMULPD  YMM1, YMM1, YMM7
      !VADDPD  YMM0, YMM0, YMM1
      
      !VMOVUPD   [REGD + $20], YMM0 ; OUT
      
      ; Spalte 2
      !VMOVUPD  YMM2, [REGA + $40] ; M2
      
      !VPERMPD YMM0, YMM2, 00000000b
      !VMULPD  YMM0, YMM0, YMM4
      
      !VPERMPD YMM1, YMM2, 01010101b
      !VMULPD  YMM1, YMM1, YMM5
      !VADDPD  YMM0, YMM0, YMM1
      
      !VPERMPD YMM1, YMM2, 10101010b
      !VMULPD  YMM1, YMM1, YMM6
      !VADDPD  YMM0, YMM0, YMM1
      
      !VPERMPD YMM1, YMM2, 11111111b
      !VMULPD  YMM1, YMM1, YMM7
      !VADDPD  YMM0, YMM0, YMM1
      
      !VMOVUPD [REGD + $40], YMM0 ; OUT
      
      ; Spalte 3
      !VMOVUPD YMM2, [REGA + $60]  ; M2
      
      !VPERMPD YMM0, YMM2, 00000000b
      !VMULPD  YMM0, YMM0, YMM4
      
      !VPERMPD YMM1, YMM2, 01010101b
      !VMULPD  YMM1, YMM1, YMM5
      !VADDPD  YMM0, YMM0, YMM1
      
      !VPERMPD YMM1, YMM2, 10101010b
      !VMULPD  YMM1, YMM1, YMM6
      !VADDPD  YMM0, YMM0, YMM1
      
      !VPERMPD YMM1, YMM2, 11111111b
      !VMULPD  YMM1, YMM1, YMM7
      !VADDPD  YMM0, YMM0, YMM1
      
      !VMOVUPD [REGD + $60], YMM0 ; OUT
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Classic Macros
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
  
  Macro mac_Vector_Min(OUT, IN1, IN2)
	  
	  If IN1\X < IN2\X
	    OUT\X = IN1\X
	  Else
      OUT\X = IN2\X
    EndIf
    
	  If IN1\Y < IN2\Y
	    OUT\Y = IN1\Y
	  Else
      OUT\Y = IN2\Y
    EndIf
    
 	  If IN1\Z < IN2\Z
	    OUT\Z = IN1\Z
	  Else
      OUT\Z = IN2\Z
    EndIf
    
    If IN1\W < IN2\W
	    OUT\W = IN1\W
	  Else
      OUT\W = IN2\W
    EndIf
  EndMacro
  
	Macro mac_Vector_Max(OUT, IN1, IN2)  
	  If IN1\X > IN2\X
	    OUT\X = IN1\X
	  Else
      OUT\X = IN2\X
    EndIf   
    
	  If IN1\Y > IN2\Y
	    OUT\Y = IN1\Y
	  Else
      OUT\Y = IN2\Y
    EndIf    
    
 	  If IN1\Z > IN2\Z
	    OUT\Z = IN1\Z
	  Else
      OUT\Z = IN2\Z
    EndIf    
    
    If IN1\W > IN2\W
	    OUT\W = IN1\W
	  Else
      OUT\W = IN2\W
    EndIf
  EndMacro
  
  Macro mac_VectorMinMax(OutMin, OutMax, IN1, IN2)   
    mac_Vector_Min(OutMin, IN1, IN2)
    mac_Vector_Max(OutMax, IN1, IN2)   
  EndMacro

  Macro mac_Vector_Scale(OUT, IN, Factor)
    OUT\x= IN\x * Factor   
    OUT\y= IN\y * Factor   
    OUT\z= IN\z * Factor    
    OUT\w= IN\w * Factor     
  EndMacro
  
  Macro mac_Vector_CrossProduct(OUT, IN1, IN2)
 		Out\X = IN1\Y * IN2\Z - IN1\Z * IN2\Y
		Out\Y = IN1\Z * IN2\X - IN1\X * IN2\Z
		Out\Z = IN1\X * IN2\Y - IN1\Y * IN2\X
		Out\W = 0
	EndMacro
	
	Macro mac_Vector_X_Matrix(OUT, IN, Matrix)
 	  ; 3D
; 	  OUT\x = IN\x * Matrix\m11 + IN\y * Matrix\m12 + IN\z * Matrix\m13
; 	  OUT\y = IN\x * Matrix\m21 + IN\y * Matrix\m22 + IN\z * Matrix\m23
;     OUT\z = IN\x * Matrix\m31 + IN\y * Matrix\m32 + IN\z * Matrix\m33
	  
	  ; 4D
	  OUT\x = IN\x * Matrix\m11 + IN\y * Matrix\m12 + IN\z * Matrix\m13 + IN\w * Matrix\m14
	  OUT\y = IN\x * Matrix\m21 + IN\y * Matrix\m22 + IN\z * Matrix\m23 + IN\w * Matrix\m24
    OUT\z = IN\x * Matrix\m31 + IN\y * Matrix\m32 + IN\z * Matrix\m33 + IN\w * Matrix\m34
    OUT\w = IN\x * Matrix\m41 + IN\y * Matrix\m42 + IN\z * Matrix\m43 + IN\w * Matrix\m44	  
	EndMacro
	
	Macro mac_Matrix_X_Matrix(OUT, A, B)   
	  
	  OUT\m11 = A\m11 * B\m11  +  A\m21 * B\m12  +  A\m31 * B\m13  +  A\m41 * B\m14  
  	OUT\m12 = A\m12 * B\m11  +  A\m22 * B\m12  +  A\m32 * B\m13  +  A\m24 * B\m14
  	OUT\m13 = A\m13 * B\m11  +  A\m23 * B\m12  +  A\m33 * B\m13  +  A\m34 * B\m14
  	OUT\m14 = A\m14 * B\m11  +  A\m24 * B\m12  +  A\m34 * B\m13  +  A\m44 * B\m14
  	
  	OUT\m21 = A\m11 * B\m21  +  A\m21 * B\m22  +  A\m31 * B\m23  +  A\m41 * B\m24
  	OUT\m22 = A\m12 * B\m21  +  A\m22 * B\m22  +  A\m32 * B\m23  +  A\m42 * B\m24
  	OUT\m23 = A\m13 * B\m21  +  A\m23 * B\m22  +  A\m33 * B\m23  +  A\m43 * B\m24
  	OUT\m24 = A\m14 * B\m21  +  A\m24 * B\m22  +  A\m34 * B\m23  +  A\m44 * B\m24
  
  	OUT\m31 = A\m11 * B\m31  +  A\m21 * B\m32  +  A\m31 * B\m33  +  A\m41 * B\m34
  	OUT\m32 = A\m12 * B\m31  +  A\m22 * B\m32  +  A\m32 * B\m33  +  A\m42 * B\m34
  	OUT\m33 = A\m13 * B\m31  +  A\m23 * B\m32  +  A\m33 * B\m33  +  A\m43 * B\m34
  	OUT\m34 = A\m14 * B\m31  +  A\m24 * B\m32  +  A\m34 * B\m33  +  A\m44 * B\m34
  
  	OUT\m41 = A\m11 * B\m41  +  A\m21 * B\m42  +  A\m31 * B\m43  +  A\m41 * B\m44
  	OUT\m42 = A\m12 * B\m41  +  A\m22 * B\m42  +  A\m32 * B\m43  +  A\m42 * B\m44
  	OUT\m42 = A\m13 * B\m41  +  A\m23 * B\m42  +  A\m33 * B\m43  +  A\m43 * B\m44
  	OUT\m44 = A\m14 * B\m41  +  A\m24 * B\m42  +  A\m34 * B\m43  +  A\m44 * B\m44
        	
  EndMacro

  Procedure.s Get_MMX_STATE_TXT()
    Protected ret.s
    
    Select #VEC_USE_MMX
        
      Case #VEC_MMX_OFF
        ret = "MMX_SSE_OFF"
        
      Case #VEC_SSE_x32
        ret = "MMX_SSE_x32_ASM"
        
      Case #VEC_SSE_x64
         ret = "MMX_SSE_x64_ASM"
       
      Case #VEC_SSE_C_Backend
         ret = "MMX_SSE_C_BackEnd"
        
     EndSelect
     ProcedureReturn ret    
  EndProcedure
  
  Debug Get_MMX_STATE_TXT()
  ;- ======================================================================
  ;- Module Public Functions
  ;- ======================================================================
  
  ;  ----------------------------------------------------------------------
  ;- Vector-Functions
  ;-  ----------------------------------------------------------------------

  ; ATTENTION: For SSE single Flaot shuffling 
  ; SSE : PShufd  Xmm1, Xmm0, $1b => AVX : VPERMPD YMM1, YMM0, $1b  (Permute Double-Precision Floating-Point Elements)
  ; 
  ; The AVX Vpshufd has other function
    
  Procedure.i Vector_Add(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  ; ============================================================================
  ; NAME: Vector_Add
  ; DESC: Add to Vectors Out = IN1 + IN2
  ; VAR(*OUT) : Pointer to Return-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector    
  ; RET.i : *OUT
  ; ============================================================================
       
    CompilerSelect #VEC_USE_MMX
      
      CompilerCase #VEC_SSE_x64       ; 64 Bit-Version        
        ASM_Vector_Add(RAX, RDX, RCX) ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase #VEC_SSE_x32       ; 32 Bit Version
        ASM_Vector_Add(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
      
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
        mac_Vector_ADD(*OUT, *IN1, *IN2)    
        ProcedureReturn *OUT

      CompilerDefault             ; Classic Version
        mac_Vector_ADD(*OUT, *IN1, *IN2)     
        ProcedureReturn *OUT

    CompilerEndSelect  
  EndProcedure
  
  Procedure.i Vector_SUB(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  ; ============================================================================
  ; NAME: Vector_SUB
  ; DESC: SUBtract to Vectors Out = IN1 - IN2
  ; VAR(*OUT) : Pointer to Return-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector    
  ; RET.i : *OUT
  ; ============================================================================
       
     CompilerSelect #VEC_USE_MMX
          
      CompilerCase #VEC_SSE_x64       ; 64 Bit-Version
        ASM_Vector_SUB(RAX, RDX, RCX) ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase #VEC_SSE_x32       ; 32 Bit Version
        ASM_Vector_SUB(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
        mac_Vector_SUB(*OUT, *IN1, *IN2)        
        ProcedureReturn *OUT

      CompilerDefault             ; Classic Version
        mac_Vector_SUB(*OUT, *IN1, *IN2)     
        ProcedureReturn *OUT

    CompilerEndSelect  
  EndProcedure
  
  Procedure.i Vector_Mul(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  ; ============================================================================
  ; NAME: Vector_Mul
  ; DESC: Multiply to Vectors Out = IN1 * IN2
  ; VAR(*OUT) : Pointer to Return-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector    
  ; RET.i : *OUT
  ; ============================================================================
    
    CompilerSelect #VEC_USE_MMX
      
      CompilerCase #VEC_SSE_x64       ; 64 Bit-Version
        ASM_Vector_Mul(RAX, RDX, RCX) ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase #VEC_SSE_x32       ; 32 Bit Version
        ASM_Vector_Mul(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
         mac_Vector_MUL(*OUT, *IN1, *IN2)        
         ProcedureReturn *OUT 

      CompilerDefault             ; Classic Version
        mac_Vector_MUL(*OUT, *IN1, *IN2)        
        ProcedureReturn *OUT 

    CompilerEndSelect  
  EndProcedure
  
  Procedure.i Vector_Div(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  ; ============================================================================
  ; NAME: Vector_Mul
  ; DESC: Divide to Vectors Out = IN1 / IN2
  ; VAR(*OUT) : Pointer to Return-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector    
  ; RET.i : *OUT
  ; ============================================================================
   
    CompilerSelect #VEC_USE_MMX
   
      CompilerCase #VEC_SSE_x64       ; 64 Bit-Version
        ASM_Vector_Div(RAX, RDX, RCX) ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase #VEC_SSE_x32       ; 32 Bit Version
        ASM_Vector_Div(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
       
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
        mac_Vector_DIV(*OUT, *IN1, *IN2)        
        ProcedureReturn *OUT

      CompilerDefault             ; Classic Versio  
        mac_Vector_DIV(*OUT, *IN1, *IN2)        
        ProcedureReturn *OUT
     
    CompilerEndSelect  
   EndProcedure
  
  Procedure.i Vector_Min(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  ; ============================================================================
  ; NAME: Vector_Min
  ; DESC: Calculates the minimum coordiantes of 2 Vectors and return it in a
  ; DESC: Vector
  ; VAR(*OUT) : Pointer to Vector which receives the Min-Coordinates (x,y,z,w)
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; VAR(*IN2) : Pointer to IN1-Vector VECd::TVector
  ; RET.i : *OUT
  ; ============================================================================
    ; Das Krezprodukt ergbigt einen zu den beiden Vectoren senkrechten Vector
    CompilerSelect #VEC_USE_MMX
        
      CompilerCase #VEC_SSE_x64             ; 64 Bit-Version
        ASM_Vector_Min(RAX, RDX, RCX)       ; for x64 we use RAX,RDX,RCX
 			  ProcedureReturn ; RAX
  			
      CompilerCase #VEC_SSE_x32             ; 32 Bit Version
        ASM_Vector_Min(EAX, EDX, ECX)       ; for x32 we use Registers EAX,EDX,ECX
  			ProcedureReturn ; EAX
  			
      CompilerCase #VEC_SSE_C_Backend       ; for the C-Backend
        mac_Vector_Min(*OUT, *IN1, *IN2)       
        ProcedureReturn *OUT

      CompilerDefault                       ; Classic Version
        mac_Vector_Max(*OUT, *IN1, *IN2)       
        ProcedureReturn *OUT

    CompilerEndSelect      
  EndProcedure
  
  Procedure.i Vector_Max(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  ; ============================================================================
  ; NAME: Vector_Max
  ; DESC: Calculates the maximum coordiantes of 2 Vectors and return it in a
  ; DESC: Vector
  ; VAR(*OUT) : Pointer to Vector which receives the Max-Coordinates (x,y,z,w)
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; VAR(*IN2) : Pointer to IN1-Vector VECd::TVector
  ; RET.i : *OUT
  ; ============================================================================
    ; Das Krezprodukt ergbigt einen zu den beiden Vectoren senkrechten Vector
    CompilerSelect #VEC_USE_MMX
        
      CompilerCase #VEC_SSE_x64             ; 64 Bit-Version
        ASM_Vector_Min(RAX, RDX, RCX)       ; for x64 we use RAX,RDX,RCX
 			  ProcedureReturn ; RAX
  			
      CompilerCase #VEC_SSE_x32             ; 32 Bit Version
        ASM_Vector_Min(EAX, EDX, ECX)       ; for x32 we use Registers EAX,EDX,ECX
  			ProcedureReturn ; EAX
  			
      CompilerCase #VEC_SSE_C_Backend       ; for the C-Backend
        mac_Vector_Max(*OUT, *IN1, *IN2)       
        ProcedureReturn *OUT

      CompilerDefault                       ; Classic Version
        mac_Vector_Min(*OUT, *IN1, *IN2)       
        ProcedureReturn *OUT

    CompilerEndSelect       
  EndProcedure
  
  Procedure.i Vector_MinMax(*OutMin.TVector, *OutMax.TVector, *IN1.TVector, *IN2.TVector)
  ; ============================================================================
  ; NAME: Vector_MinMax
  ; DESC: Calculates the maximum and maximum coordiantes of 2 Vectors and 
  ; DESC: return it in a Vector
  ; VAR(*OutMin) : Pointer to Vector which receives the Min-Coordinates (x,y,z,w)
  ; VAR(*OutMax) : Pointer to Vector which receives the Max-Coordinates (x,y,z,w)
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; VAR(*IN2) : Pointer to IN1-Vector VECd::TVector
  ; RET : -
  ; ============================================================================
    ; Das Krezprodukt ergbigt einen zu den beiden Vectoren senkrechten Vector
    CompilerSelect #VEC_USE_MMX
        
      CompilerCase #VEC_SSE_x64             ; 64 Bit-Version
        ASM_Vector_MinMax(RAX, RDX, RCX)    ; for x64 we use RAX,RDX,RCX
   			
      CompilerCase #VEC_SSE_x32             ; 32 Bit Version
        ASM_Vector_MinMax(EAX, EDX, ECX)    ; for x32 we use Registers EAX,EDX,ECX
   			
      CompilerCase #VEC_SSE_C_Backend       ; for the C-Backend
        mac_Vector_MinMax(*OutMin, *OutMax *IN1, *IN2)       

      CompilerDefault                       ; Classic Version
        mac_Vector_MinMax(*OutMin, *OutMax *IN1, *IN2)       
 
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

  Procedure.i Vector_Swap(*OUT.TVector, *IN.Tvector)
  ; ============================================================================
  ; NAME: Vector_Swap
  ; DESC: Swaps the postion of the Vector coordinates
  ; DESC: OUT(X) = IN(W)
  ; DESC: OUT(Y) = IN(Z)
  ; DESC: OUT(Z) = IN(Y)
  ; DESC: OUT(W) = IN(X)
  ; VAR(*OUT) : Pointer to Return-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; RET.i : *OUT
  ; ============================================================================
    
    CompilerSelect #VEC_USE_MMX
      
      CompilerCase #VEC_SSE_x64   ; 64 Bit-Version
        ASM_Vector_Swap(RAX, RDX, RCX) ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase #VEC_SSE_x32   ; 32 Bit Version
        ASM_Vector_Swap(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
        Swap *Vec\x, *Vec\w
        Swap *Vec\y, *Vec\z
        ProcedureReturn *OUT

      CompilerDefault             ; Classic Version
        Swap *Vec\x, *Vec\w
        Swap *Vec\y, *Vec\z
        ProcedureReturn *OUT

    CompilerEndSelect     
  EndProcedure
  
  Procedure.i Vector_Copy(*OUT.TVector, *IN.TVector)
  ; ============================================================================
  ; NAME: Vector_Copy
  ; DESC: Copies Vector OUT = IN
  ; DESC: we need this Copy-Function because PureBasic can't copy the
  ; DESC: DataPart of a Pointer directly. *OUT = *IN just copys the pointer
  ; DESC: not the Datas
  ; VAR(*OUT): Pointer to Return-Vector VECd::TVector
  ; VAR(*IN) : Pointer to IN1-Vector VECd::TVector
  ; RET.i : *OUT
  ; ============================================================================
    
    CompilerSelect #VEC_USE_MMX
        
      CompilerCase #VEC_SSE_x64     ; 64 Bit-Version
        !MOV RAX, [p.p_OUT]
        !MOV RDX, [p.p_IN]
        !VMOVUPD YMM0, [RDX]       
        !VMOVUPD [RAX], YMM0       
        ProcedureReturn     ; RAX
        
      CompilerCase #VEC_SSE_x32     ; 32 Bit Version
        !MOV EAX, [p.p_OUT]
        !MOV EDX, [p.p_IN]
        !VMOVUPD YMM0, [EDX]       
        !VMOVUPD [EAX], YMM0       
        ProcedureReturn     ; EAX
        
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
        CopyMemory(*IN, *OUT, SizeOf(TVector))
        ProcedureReturn *OUT
        
      CompilerDefault                   ; Classic Version
        CopyMemory(*IN, *OUT, SizeOf(TVector))
        ProcedureReturn *OUT

    CompilerEndSelect  
  EndProcedure
  
  Procedure.i Vector_Set(*Out.TVector, X.d=0.0, Y.d=0.0, Z.d=0.0, W.d=0.0)
  ; ============================================================================
  ; NAME: Vector_Set
  ; DESC: Sets the Vector coordinates
  ; VAR(*OUT): Pointer to Return-Vector VECf::TVector
  ; VAR(X) : The X-value
  ; VAR(Y) : The Y-value
  ; VAR(Z) : The Z-value
  ; VAR(W) : The W-value
  ; RET.i : *OUT
  ; ============================================================================
    
   CompilerSelect #VEC_USE_MMX
      ; using MMX-Register to copy 4xDouble directly from Stack to destination
      ; for packed Double in YMM Register use the 256-Bit VMOVUPD
      ; an optimation like split into 64Bit Moves is not more effective
      ; (like 2x 64Bit Move For 128Bit Data)
      ; Latency; Aligned 256-Bit VMOVAPD = 5 Cyles (but 2 commands parallel : commands per Cycle = 2)
      ;        Unaligned 256-Bit VMOVUPD = 4 Cyles (but 1 cammand  parallel : commands üer Cycle = 1)
       
     CompilerCase #VEC_SSE_x64     ; 64 Bit-Version
        !LEA RDX, [p.v_X]          ; load effective address of X  (Pointer to X on Stack)
        !MOV RAX, [p.p_OUT]
        !VMOVUPS XMM0, [RDX]       ; Move 256-Bit, 32Bytes
        !VMOVUPS [RAX], XMM0
        ProcedureReturn
       
      CompilerCase #VEC_SSE_x32     ; 32 Bit Version
        !LEA EDX, [p.v_X]
        !MOV EAX, [p.p_OUT]
        !VMOVUPS XMM0, [EDX]        ; Move 256-Bit, 32Bytes
        !VMOVUPS [EAX], XMM0
        ProcedureReturn
        
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
        With *OUT
          \X = X
      	  \Y = Y
      	  \Z = Z
      	  \W = W
    	  EndWith
    	  ProcedureReturn *Out
        
      CompilerDefault                   ; Classic Version
         With *OUT
          \X = X
      	  \Y = Y
      	  \Z = Z
      	  \W = W
    	  EndWith
    	  ProcedureReturn *Out
       
    CompilerEndSelect    
  EndProcedure
  
  Procedure.d Vector_Length(*In.TVector)
  ; ============================================================================
  ; NAME: Vector_Length
  ; DESC: Calculates the Vector Length L=SQRT(x² + y² + z²) 
  ; VAR(*IN): Pointer to the Vector VECd::TVector
  ; RET.d :  The Vector length
  ; ============================================================================
 	  ProcedureReturn Sqr( *In\X * *In\X + *In\Y * *In\Y + *In\Z * *In\Z )
  EndProcedure 
  
  Procedure.i Vector_Normalize(*InOut.TVector)
  ; ============================================================================
  ; NAME: Vector_Normalize
  ; DESC: Normalize a Vector to Length=1
  ; VAR(*IN): Pointer to the Vector VECd::TVector
  ; RET.d :  The Vector length
  ; ============================================================================
  	Protected Length.d = Vector_Length(*InOut)
  	If Length
  		Length = 1.0 / Length
  		*InOut\X * Length
  		*InOut\Y * Length
  		*InOut\Z * Length
  	EndIf
  	ProcedureReturn *InOut
  EndProcedure
  
  Procedure.d Vector_Scalar(*IN1.TVector, *IN2.TVector)
  ; ============================================================================
  ; NAME: Vector_Scalar
  ; DESC: Calculates the Scalar Product of 2 Vectors
  ; DESC: S = v1(x) * v2(x) + v1(y) * v2(y) + v1(z) * v2(z)
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECd::TVector    
  ; RET.d :  The Scalar Product
  ; ============================================================================
  	ProcedureReturn *IN1\X * *IN2\X + *IN1\Y * *IN2\Y + *IN1\Z * *IN2\Z
  EndProcedure

  Procedure.i Vector_Scale(*OUT.TVector, *IN.TVector, Factor.d)
  ; ============================================================================
  ; NAME: Vector_Scale
  ; DESC: Scales a Vector with a Factor V() * Factor
  ; VAR(*OUT): Pointer to Return-Vector VECd::TVector
  ; VAR(*IN) : Pointer to IN1-Vector VECd::TVector
  ; VAR(Factor.f): The scaling factor
  ; RET.i : *OUT
  ; ============================================================================
   
    CompilerSelect #VEC_USE_MMX
      
      CompilerCase #VEC_SSE_x64         ; 64 Bit-Version       
        ASM_Vector_Scale(RAX, RDX, RCX) ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase #VEC_SSE_x32         ; 32 Bit Version
        ASM_Vector_Scale(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
        mac_Vector_Scale(*OUT, *IN, Factor)        
        ProcedureReturn *OUT

      CompilerDefault               ; Classic Version
        mac_Vector_Scale(*OUT, *IN, Factor)        
        ProcedureReturn *OUT

    CompilerEndSelect     
  EndProcedure
  
  Procedure.i Vector_CrossProduct(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  ; ============================================================================
  ; NAME: Vector_CrossProduct
  ; DESC: Calculates the Vector-Cross-Product
  ; VAR(*OUT): Pointer to Return-Vector VECd::TVector
  ; VAR(*IN) : Pointer to IN1-Vector VECd::TVector
  ; VAR(Factor.f): The scaling factor
  ; RET.i : *OUT
  ; ============================================================================
    ; Das Krezprodukt ergbigt einen zu den beiden Vectoren senkrechten Vector
    CompilerSelect #VEC_USE_MMX
        
      CompilerCase #VEC_SSE_x64                 ; 64 Bit-Version
        ASM_Vector_CrossProduct(RAX, RDX, RCX)  ; for x64 we use RAX,RDX,RCX
 			  ProcedureReturn ; RAX
  			
      CompilerCase #VEC_SSE_x32                 ; 32 Bit Version
        ASM_Vector_CrossProduct(EAX, EDX, ECX)  ; for x32 we use Registers EAX,EDX,ECX
  			ProcedureReturn ; EAX
  			
      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend
        mac_Vector_CrossProduct(*Out, *IN1, *IN2)       
        ProcedureReturn *OUT

      CompilerDefault                   ; Classic Version
        mac_Vector_CrossProduct(*Out, *IN1, *IN2)       
        ProcedureReturn *OUT

    CompilerEndSelect      
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Matrix-Functions
  ;- ----------------------------------------------------------------------
  
 Procedure.i SetMatrixIdentity(*Matrix.TMatrix) ; EinheitsMatrix
  ; ============================================================================
  ; NAME: SetMatrixIdentity
  ; DESC: Set the Indentity Matrix
  ; DESC: returns a STL-Solid Structure which conatains all the Triangles.
  ; VAR(*Matrix) : Pointer to VECd::TMatrix
  ; RET.i : *Matrix
  ; ============================================================================
    
     ; 3D-Identity Matrix (Einheitsmatrix)
    ; |1   0   0   0 | 
    ; |0   1   0   0 | 
    ; |0   0   1   0 | 
    ; |0   0   0   1 | 
    
    If *Matrix
      mac_SetVector(*Matrix\v[0], 1, 0, 0, 0) ; (X ,Y, Z, W)
  	  mac_SetVector(*Matrix\v[1], 0, 1, 0, 0)
  	  mac_SetVector(*Matrix\v[2], 0, 0, 1, 0)
  	  mac_SetVector(*Matrix\v[3], 0, 0, 0, 1)
  	EndIf
 	  ProcedureReturn *Matrix
  EndProcedure

  Procedure.i SetMatrixTranslation(*Matrix.TMatrix, dX.d, dY.d, dZ.d)
  ; ============================================================================
  ; NAME: SetMatrixTranslation
  ; DESC: Set the Matrix for Translation operation dX, dY, dZ
  ; DESC: Translation is a Movement with (dX,dY,dZ)
  ; VAR(*Matrix) : Pointer to VECd::TMatrix
  ; VAR(dX) : Delta X (Move in X direction)
  ; VAR(dY) : Delta Y (Move in Y direction)
  ; VAR(dZ) : Delta Z (Move in Z direction)
  ; RET.i : *Matrix
  ; ============================================================================
    
     ; 3D-Translation (Verschiebung)
    ; |1   0   0   dx | 
    ; |0   1   0   dy | 
    ; |0   0   1   dz | 
    ; |0   0   0    1 | 

    If *Matrix
      ; Attention here we set the values horizontal! Not vertical! -> 90° turned
  	  mac_SetVector(*Matrix\v[0],  1,  0,  0,  0) ; (X ,Y, Z, W)
  	  mac_SetVector(*Matrix\v[1],  0,  1,  0,  0)
  	  mac_SetVector(*Matrix\v[2],  0,  0,  1,  0)
  	  mac_SetVector(*Matrix\v[3], dX, dY, dZ,  1)
  	EndIf
	  ProcedureReturn *Matrix
  EndProcedure
  
  Procedure.i SetMatrixScale(*Matrix.TMatrix, Sx.D, Sy.D, Sz.D)
  ; ============================================================================
  ; NAME: SetMatrixScale
  ; DESC: Set the Matrix for Scaling (Zoom)
  ; VAR(*Matrix) : Pointer to VECd::TMatrix
  ; VAR(Sx.f) : Scale factor X
  ; VAR(Sy.f) : Scale factor Y
  ; VAR(Sz.f) : Scale factor Z 
  ; RET.i : *Matrix
  ; ============================================================================
    ; 3D-Scaling (Zoom)
    ; |Sx   0    0   0 | 
    ; |0   Sy    0   0 | 
    ; |0    0   Sz   0 | 
    ; |0    0    0   1 | 
    
    If *Matrix
  	  mac_SetVector(*Matrix\v[0], Sx,   0,   0,  0) ; (X ,Y, Z, W)
  	  mac_SetVector(*Matrix\v[1],  0,  Sy,   0,  0)
  	  mac_SetVector(*Matrix\v[2],  0,   0,  Sz,  0)
  	  mac_SetVector(*Matrix\v[3],  0,   0,   0,  1)
  	EndIf
    ProcedureReturn *Matrix

  EndProcedure
 
	Procedure.i SetMatrixRotX(*Matrix.TMatrix, Angle.d)
  ; ============================================================================
  ; NAME: SetMatrixRotX
  ; DESC: Set the Matrix for Rotation arround X-Axis
  ; VAR(*Matrix) : Pointer to VECd::TMatrix
	; VAR(Angle.d) : Angle in Radian (use Radain() to convert Degree to Radian
  ; RET.i : *Matrix
  ; ============================================================================
	  
	  Protected s.d=Sin(Angle)
	  Protected c.d=Cos(Angle)
	  
    ; Rotation X
    ; | 1     0      0    0 | 
    ; | 0    cos   -sin   0 | 
    ; | 0    sin    cos   0 | 
    ; | 0     0      0    1 | 
 	
    If *Matrix
      ; Attention here we set the values horizontal! Not vertical! -> 90° turned
      mac_SetVector(*Matrix\v[0], 1,  0,  0,  0) ; (X ,Y, Z, W)
  	  mac_SetVector(*Matrix\v[1], 0,  c,  s,  0)
  	  mac_SetVector(*Matrix\v[2], 0, -s,  c,  0)
  	  mac_SetVector(*Matrix\v[3], 0,  0,  0,  1)   
    EndIf
	  ProcedureReturn *Matrix
  EndProcedure
	  
  Procedure.i SetMatrixRotY(*Matrix.TMatrix, Angle.d)
  ; ============================================================================
  ; NAME: SetMatrixRotY
  ; DESC: Set the Matrix for Rotation arround Y-Axis
  ; VAR(*Matrix) : Pointer to VECd::TMatrix
	; VAR(Angle.d) : Angle in Radian (use Radain() to convert Degree to Radian
  ; RET.i : *Matrix
  ; ============================================================================
    
    Protected s.d=Sin(Angle)
	  Protected c.d=Cos(Angle)
	  
    ; Attention here the values ar vertical
    ; Rotation Y
    ; | cos   0    sin   0 | 
    ; |  0    1     0    0 | 
    ; |-sin   0    cos   0 | 
    ; |  0    0     0    1 | 
	  
	  If *Matrix
      ; Attention here we set the values horizontal! Not vertical! -> 90° turned
  	  mac_SetVector(*Matrix\v[0],  c, 0, -s, 0) ; (X ,Y, Z, W)
  	  mac_SetVector(*Matrix\v[1],  0, 1,  0, 0)
  	  mac_SetVector(*Matrix\v[2],  s, 0,  c, 0)
  	  mac_SetVector(*Matrix\v[3],  0, 0,  0, 1)   
    EndIf
	  ProcedureReturn *Matrix
  EndProcedure
  
  Procedure.i SetMatrixRotZ(*Matrix.TMatrix, Angle.d)
  ; ============================================================================
  ; NAME: SetMatrixRotZ
  ; DESC: Set the Matrix for Rotation arround Z-Axis
  ; VAR(*Matrix) : Pointer to VECd::TMatrix
	; VAR(Angle.d) : Angle in Radian (use Radain() to convert Degree to Radian
  ; RET.i : *Matrix
  ; ============================================================================
    
    Protected s.d=Sin(Angle)
	  Protected c.d=Cos(Angle)
	  
    ; Attention here the values ar vertical
    ; Rotation Z
    ; |cos   -sin   0   0 | 
    ; |sin    cos   0   0 | 
    ; | 0      0    1   0 | 
    ; | 0      0    0   1 | 
  	
    If *Matrix
      ; Attention here we set the values horizontal! Not vertical! -> 90° turned
  	  mac_SetVector(*Matrix\v[0],  c, s, 0, 0) ; (X ,Y, Z, W)
  	  mac_SetVector(*Matrix\v[1], -s, c, 0, 0)
  	  mac_SetVector(*Matrix\v[2],  0, 0, 1, 0)
  	  mac_SetVector(*Matrix\v[3],  0, 0, 0, 1)   
  	EndIf
	  ProcedureReturn *Matrix
	EndProcedure
	
  Procedure.i Vector_X_Matrix(*OUT.TVector, *IN.TVector, *Matrix.TMatrix)
  ; ============================================================================
  ; NAME: Vector_X_Matrix
  ; DESC: Caluclate the Vector-Matrix-Product  V()xM()
  ; VAR(*OUT) : Pointer to Return-Vector VECd::TVector
  ; VAR(*IN) : Pointer to a VECd::TVector
  ; VAR(*Matrix) : Pointer to a VECd::TMatrix
	; VAR(Angle.f) : Angle in Radian (use Radain() to convert Degree to Radian
  ; RET.i : *Matrix
  ; ============================================================================
   
    CompilerSelect #VEC_USE_MMX
        
      CompilerCase #VEC_SSE_x64             ; 64 Bit-Version
        ASM_Vector_X_Matrix(RAX, RDX, RCX)  ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
         
  		CompilerCase #VEC_SSE_x32             ; 32 Bit Version
        ASM_Vector_X_Matrix(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
  		  
;   		  mac_Vector_X_Matrix(*OUT, *IN, *Matrix)
;         ProcedureReturn *OUT

      CompilerCase #VEC_SSE_C_Backend   ; for the C-Backend  
        mac_Vector_X_Matrix(*OUT, *IN, *Matrix)
        ProcedureReturn *OUT

      CompilerDefault                   ; Classic Version
        mac_Vextor_X_Matrix(*OUT, *IN, *Matrix)
        ProcedureReturn *OUT

    CompilerEndSelect       
  EndProcedure
  
  Procedure.i Matrix_X_Matrix(*OUT.TMatrix, *M1.TMatrix, *M2.TMatrix)
  ; ============================================================================
  ; NAME: Matrix_X_Matrix
  ; DESC: Caluclate the Matrix-Matrix-Product  M() x M()
  ; VAR(*OUT) : Pointer to Return-Matrix VECd::TMatrix
  ; VAR(*M1) : Pointer to IN1 Matrix a VECd::TMatrix
  ; VAR(*M1) : Pointer to IN2 Matrix a VECd::TMatrix
  ; RET.i : *OUT
  ; ============================================================================
   
    CompilerSelect #VEC_USE_MMX
        
      CompilerCase #VEC_SSE_x64     ; 64 Bit-Version
         ASM_Matrix_X_Matrix(RAX, RDX, RCX)  ; for x64 we use RAX,RDX,RCX
         ProcedureReturn  ; RAX
         
      CompilerCase #VEC_SSE_x32     ; 32 Bit Version
         ASM_Matrix_X_Matrix(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
         ProcedureReturn  ; EAX
         
;         mac_Matrix_X_Matrix(*OUT, *M1, *M2) 
;         ProcedureReturn *OUT
        
      CompilerCase #VEC_SSE_C_Backend     ; for the C-Backend
        mac_Matrix_X_Matrix(*OUT, *M1, *M2) 
        ProcedureReturn *OUT

      CompilerDefault                   ; Classic Version
        mac_Matrix_X_Matrix(*OUT, *M1, *M2) 
        ProcedureReturn *OUT

    CompilerEndSelect          
   EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Auxiliary Functions
  ;-  ----------------------------------------------------------------------

  Procedure.d MinOf3(Value1.d, Value2.d, Value3.d=1.0e1000)
  ; ============================================================================
  ; NAME: MinOf3
  ; DESC: Calculates the Minimum of 3 Values
  ; VAR(Value1) : Value 1
  ; VAR(Value1) : Value 2
  ; VAR(Value1) : Value 3
  ; RET.d : Min(Value1, Value2, Value3)
  ; ============================================================================
	
  	If Value3 < Value2
  		If Value3 < Value1
  			ProcedureReturn Value3
  		Else
  			ProcedureReturn Value1
  		EndIf
  	ElseIf Value2 < Value1
  		ProcedureReturn Value2
  	Else
  		ProcedureReturn Value1
  	EndIf
  	
  EndProcedure
 
  Procedure.d MaxOf3(Value1.d, Value2.d, Value3.d=-1.0e1000)
  ; ============================================================================
  ; NAME: MaxOf3
  ; DESC: Calculates the Maximum of 3 Values
  ; VAR(Value1) : Value 1
  ; VAR(Value1) : Value 2
  ; VAR(Value1) : Value 3
  ; RET.d : Max(Value1, Value2, Value3)
  ; ============================================================================
  	
  	If Value3 > Value2
  		If Value3 > Value1
  			ProcedureReturn Value3
  		Else
  			ProcedureReturn Value1
  		EndIf
  	ElseIf Value2 > Value1
  		ProcedureReturn Value2
  	Else
  		ProcedureReturn Value1
  	EndIf
  	
  EndProcedure
EndModule

CompilerIf #PB_Compiler_IsMainFile    
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------

  EnableExplicit
  UseModule VECd
  
  ; ----------------------------------------------------------------------
  ;  Define Variables
  ; ----------------------------------------------------------------------
  Global.TVector dA, dB, dC    ; double Vectors
  
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
    ; set the double Vectors
    mac_SetVector(dA,  1, 2, 3, 4)
    mac_SetVector(dB, 10,20,30,40)
  EndMacro
   
  ; ----------------------------------------------------------------------
  ;  Test Procedures
  ; ----------------------------------------------------------------------

  Procedure Test_VectorAdd()  
    Debug "----------------------------------------"    
    Debug "Vetor_Add()"   
    Vector_Add(dC, dA , dB)
    mac_Debug_Result(dC, dA, dB)   
  EndProcedure
  
  Procedure Test_VectorSub()  
    Debug "----------------------------------------"
    Debug "Vetor_Sub()"   
    Vector_Sub(dC, dA , dB)
    mac_Debug_Result(dC, dA, dB)    
  EndProcedure
 
  Procedure Test_VectorMul()  
    Debug "----------------------------------------"
     Debug "Vetor_Mul()"   
    Vector_Mul(dC, dA , dB)
    mac_Debug_Result(dC, dA, dB)    
  EndProcedure

  Procedure Test_VectorDiv()  
    Debug "----------------------------------------"
    Debug "Vetor_Div()"   
    Vector_Div(dC, dA , dB)
    mac_Debug_Result(dC, dA, dB)    
  EndProcedure
  
  Procedure Test_VectorSwap()  
    Debug "----------------------------------------"
    Debug "Vetor_Swap()"   
    
    Vector_Swap(dC, dA)
    mac_Debug_Result(dC, dA, dA)    
  EndProcedure
  
  Procedure Test_VectorScale()  
    Debug "----------------------------------------"
    Debug "Vetor_Scale(*2.5)"   
    
    Vector_Scale(dC, dA, 2.5)
    mac_Debug_Result(dC, dA, dA)    
  EndProcedure

  Procedure Test_Vector_CrossProduct()  
    Debug "----------------------------------------"    
    Debug "Vetor_Vector_CrossProduct()"   
    mac_SetVector(dA, 2, -1, 5 ,0)
    mac_SetVector(dB, 6, 7, 2 , 0)
    Vector_CrossProduct(dC, dA, dB)
    
    Debug ("correct Result (-37,26,20)")
    mac_Debug_Result(dC, dA, dA)    
  EndProcedure
 
  SetVectorBasicValues()        ; Set Vectors to basic valus
  
  Debug "----------------------------------------"
  mac_Debug_AB(dA, dB)  ; Show A and B in Debug output
  
  ; correct Results at x32
  Test_VectorAdd()          ; Test the Vector_Add funtions
  Test_VectorSub()          ; Test the Vector_Sub funtions
  Test_VectorMul()          ; Test the Vector_Mul funtions
  Test_VectorDiv()          ; Test the Vector_Div funtions
  Test_VectorSwap()         ; Test the Vector_Div funtions
  Test_VectorScale()        ; Test the Vector_Div funtions
  
  Test_Vector_CrossProduct() ; Test the Vector_CrossProduct funtions
  
  ; Not Implemented and not tested
  ; Test_Vector_X_Matrix
  ; Test_Matrix _X_Matrix
CompilerEndIf


; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 130
; FirstLine = 1305
; Folding = ------------
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)