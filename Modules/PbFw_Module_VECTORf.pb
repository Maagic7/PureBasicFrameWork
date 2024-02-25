; ===========================================================================
; FILE : PbFw_Module_VECTORf.pb
; NAME : PureBasic Framework : Module VECTORf [VEDf::]
; DESC : Single precicion Vector Library
; DESC : using the MMX, SSE Registers, to speed up vector operations
; DESC : For double precicion Vectors use VECTORd [VECd::]
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
;     https://linasm.sourceforge.net/docs/instructions/simd.php
;
;   LMU Munich: Coumputer Grafics (Prof. Dr. Ing. Axel Hope)
;
;   Einführung in die Computergrafik
;   Thomas Jung
;   Geometrische Transformationen: https://www.youtube.com/watch?v=h7xqgVcRgXA
;   Verdeckung : https://www.youtube.com/watch?v=ZxX_lMRU2_o
;   Beleuchtung : https://www.youtube.com/watch?v=mYTy10L6osU

;   Prof. Dr. Phillip Jenke
;   Polygonale Netze: https://www.youtube.com/watch?v=cItuE_CUUgE&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=2 
;   Kamera:      https://www.youtube.com/watch?v=DqpgUiVDiQc&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=3
;   Szenengraph: https://www.youtube.com/watch?v=WaH2JP9lNs0&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=4
;   Geometrische Formen: https://www.youtube.com/watch?v=6uc7MHoz40I&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=5
;   Matrizen   : https://www.youtube.com/watch?v=iu833P760Bc&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=6
;   Transformationen: https://www.youtube.com/watch?v=2LpwLnj92UM&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=7
;   Rendering Pipeline: https://www.youtube.com/watch?v=NTbDKecTk_0&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=8
;   Baryzentrische Koordinaten: https://www.youtube.com/watch?v=aUBh02MOOk8&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=9
;   Halbkanten-Datenstruktur: https://www.youtube.com/watch?v=aX3wJz5eHkc&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=10
;   Glättung: https://www.youtube.com/watch?v=P97SJu6-N0A&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=11
;   SUBdivision: https://www.youtube.com/watch?v=gKiodYX1LZk&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=12
;   Fehlerquadriken: https://www.youtube.com/watch?v=nxYVdeuaDr4&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=13
;   Beleuchtungsmodelle: https://www.youtube.com/watch?v=UDR3MQdNLVI&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=14
;   Shading:  https://www.youtube.com/watch?v=Vv7cLcOzolA&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=15
;   Material: https://www.youtube.com/watch?v=eK8bzMWhsJQ&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=16
;   Schatten: https://www.youtube.com/watch?v=3ECs3GVHSbg&list=PLx-ZSX5Ln14w3l_Vwym9Iw4vHthOLN6TJ&index=17
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/04
; VERSION  :  0.511 Developper Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
; 
; 2024/02/24 S.Maag : included "PbFw_ASM_Macros.pbi"
; 2023/07/29 S.Maag : changed some comments
; 2023/03/19 S.Maag : added Vector_Lerp, Vector_InverseLerp, Vector_Rempap
; 2023/02/18 S.Maag : integrated FrameWork Contol Module PbFw::
; 2023/02/17 S.Maag : some Bugfixes and x64 Test 
; 2022/12/24 S.Maag : added some tests and optimations
; 2022/12/11 S.Maag : added SetMatrix-Functions
;} 
;{ TODO:
; Implement all the SSE optimations for the C-Backend on x86
; propably by using the C intrinsic Macros
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module

;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule VECf
  
  EnableExplicit
   
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
    
  
  ; Vector ist immer aus 4 Elementen, sonst macht das keinen Sinn
  ; die Unterscheidung Vector3, Vector4 bringt nur Nachteile statt Vorteile
  ; Man braucht neben den x,y,z,w Kooridnaten noch die Möglichkeit des
  ; indizierten Zugriffs das dürfte für Matrix-Operationen besser sein!
  Structure TPoint2D Align 4    ; to be sure it will be 4Byte Aligned at x64
    X.f          
    Y.f          
  EndStructure
  
  #PbFw_VectorCoordinate_X = 0
  #PbFw_VectorCoordinate_Y = 1
  #PbFw_VectorCoordinate_Z = 2
  #PbFw_VectorCoordinate_W = 3
 
  Structure TVector Align 4 ; Single precicion Vector [16 Bytes / 128 Bit]
    StructureUnion
      v.f[0]                ; virutal Array  v[0]=x, v[1]=y, v[2]=z, v[3]=w
      Pt2D.TPoint2D[0]
    EndStructureUnion
    x.f
    y.f
    z.f
    w.f
  EndStructure 
  
  Debug "SyzeOf(VECf::TVector) = " + SizeOf(TVector)
  
  ; we need this construction of a Matrix because in common C and Pascal Code 
  ; it's in this way
  ; ------------------
  ; m11  m12  m13  m14
  ; m21  m22  m23  m24
  ; m31  m32  m33  m34
  ; m41  m42  m43  m44
  ; ------------------
  ; This is the C-Definition of a TMatrix3D
  ;         struct
  ;             float m11;
  ;             float m12;
  ;             float m13;
  ;             float m21;
  ;             float m22;
  ;             float m23;
  ;             float m31;
  ;             float m32;
  ;             float m33;
         
  Structure TMatrix  ; Single precicion Matrix
    StructureUnion
      v.TVector[0]   ; Vector interpretation of the Matrix Structure
      Pt2D.TPoint2D[0]
    EndStructureUnion
    m11.f : m12.f : m13.f : m14.f    
    m21.f : m22.f : m23.f : m24.f
    m31.f : m32.f : m33.f : m34.f   
    m41.f : m42.f : m43.f : m44.f
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
  
  Macro mac_Debug_Vector(Vec)
    Debug "X= " + Vec\X + "  :  Y=" + Vec\y + "  :  Z= " + Vec\Z + "  :  W=" + Vec\W
  EndMacro
    
  ; Declare Vector Functions
  Declare.i Vector_Add(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  Declare.i Vector_SUB(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  Declare.i Vector_Mul(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  Declare.i Vector_Div(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  Declare.i Vector_Min(*OutTVector, *IN1.TVector, *IN2.TVector)
  Declare.i Vector_Max(*OutTVector, *IN1.TVector, *IN2.TVector)
  Declare.i Vector_Swap(*OUT.TVector, *IN.Tvector)
  Declare.i Vector_Copy(*OUT.TVector, *IN.TVector)
  Declare.i Vector_Set(*Out.TVector, X.f=0.0, Y.f=0.0, Z.f=0.0, W.f=0.0)
  Declare.f Vector_Length(*IN.TVector)
  
  Declare.i Vector_Normalize(*InOut.TVector)
  Declare.f Vector_Scalar(*IN1.TVector, *IN2.TVector)
  Declare.i Vector_Scale(*OUT.TVector, *IN.TVector, Factor.f)
  Declare.i Vector_CrossProduct(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  Declare.i Vector_Lerp(*OUT.TVector, *A.TVector, *B.TVector, T.f)
  Declare.f Vector_InverseLerp(*A.TVector, *B.TVector, *V.TVector, XYZW.i=#PbFw_VectorCoordinate_X)
  Declare.i Vector_Remap(*OUT.TVector, *IN.TVector, *inMin.TVector, *inMax.TVector, *outMin.TVector, *outMax.TVector, xRemapW=#False)
  
  ; Declare Matrix Functions
  Declare.i SetMatrixIdentity(*Matrix.TMatrix) ; EinheitsMatrix
  Declare.i SetMatrixTranslation(*Matrix.TMatrix, dX.f, dY.f, dZ.f)
	Declare.i SetMatrixRotX(*Matrix.TMatrix, Angle.f)
	Declare.i SetMatrixRotY(*Matrix.TMatrix, Angle.f)
  Declare.i SetMatrixRotZ(*Matrix.TMatrix, Angle.f)
	Declare.i SetMatrixRotXYZ(*Matrix.TMatrix, AngleX.f, AngleY.f, AngleZ.f)
	
  Declare.i Vector_X_Matrix(*OUT.TVector, *IN.TVector, *Matrix.TMatrix)
  Declare.i Matrix_X_Matrix(*OUT.TMatrix, *M1.TMatrix, *M2.TMatrix)
  
  Declare.f MinOf3(Value1.f, Value2.f, Value3.f=1.0e100)
  Declare.f MaxOf3(Value1.f, Value2.f, Value3.f=-1.0e100)

EndDeclareModule
  
Module VECf
 
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)   ; Lists the Module in the ModuleList (for statistics)
  
  IncludeFile "PbFw_ASM_Macros.pbi"       ; Standard Assembler Macros
  
  ;- ----------------------------------------------------------------------
  ;- Module Private
  ;- ----------------------------------------------------------------------
        

; TEMPLATE Compiler Select SSE
;     CompilerSelect PbFw::#PbfW_SE_MMX_Type
;         
;       CompilerCase PbFw::#PbfW_SSE_x64          ; 64 Bit-Version
;         
;       CompilerCase PbFw::#PbfW_SSE_x32          ; 32 Bit Version
;         
;       CompilerCase PbFw::#PbfW_SSE_C_Backend    ; for the C-Backend
;         
;       CompilerDefault                           ; Classic Version
;         
;     CompilerEndSelect  
  
  ;  ----------------------------------------------------------------------
  ;- Assembler Macros : MMX/SSE optimized routines
  ;- ----------------------------------------------------------------------
  
  ; Assembler Macros for single precicion Vector calculations
  ; using 128Bit SSE-Registers
  
  ; After sone testing I found a methode, to use same ASM-Code for
  ; x32 and x64. The trick is to use the 3 possible Registers as Paramter.
  
  ; The Macro has always the same structure, for x32/x64. We hvae to change
  ; only the Register-Parameters! So call:
  ; MacroName(EAX, EDX, ECX) for x32
  ; MacroName(RAX, RDX, RCX) for x64
      
  Macro ASM_Vector_Add(REGA, REGD, REGC)
    ;Vector_Add(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
      !MOV     REGA, [p.p_IN1]    ; Move Data-Pointer 1 to rax,eax
    	!MOV     REGD, [p.p_IN2]    ; Move Data-Pointer 2 to rdx,edx
      !MOVUPS  XMM0, [REGA]       ; Move 16 Byte from Data 1 to XMM0 Register
      !MOVUPS  XMM1, [REGD]       ; Move 16 Byte from Data 2 to XMM1 Register
      !ADDPS   XMM1, XMM0         ; Add 4 packed single precision Float
      !MOV     REGA, [p.p_OUT]    ; Move Data-Pointer of Result to rax,eax
      !MOVUPS  [REGA], XMM1       ; Move the 16-Byte Result to our Result Data
  EndMacro
    
  Macro ASM_Vector_SUB(REGA, REGD, REGC) 
    ;Vector_SUB(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
      !MOV     REGA, [p.p_IN2]
    	!MOV     REGD, [p.p_IN1]
      !MOVUPS  XMM0, [REGA]
      !MOVUPS  XMM1, [REGD]
      !SUBPS   XMM1, XMM0
      !MOV     REGA, [p.p_OUT]
      !MOVUPS  [REGA], XMM1
  EndMacro
  
  Macro ASM_Vector_Mul (REGA, REGD, REGC) 
    ;Vector_Mul(*OUT.TVector, *IN1.TVector, *IN2.TVector)
      !MOV     REGA, [p.p_IN1]
    	!MOV     REGD, [p.p_IN2]
      !MOVUPS  XMM0, [REGA]
      !MOVUPS  XMM1, [REGD]
      !MULPS   XMM1, XMM0
      !MOV     REGA, [p.p_OUT]
      !MOVUPS  [REGA], XMM1
   EndMacro
   
  Macro ASM_Vector_Div (REGA, REGD, REGC) 
    ;Vector_Div(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
      !MOV     REGA, [p.p_IN1]
    	!MOV     REGD, [p.p_IN2]
      !MOVUPS  XMM0, [REGA]
      !MOVUPS  XMM1, [REGD]
      !Divps   XMM0, XMM1
      !MOV     REGA, [p.p_OUT]
      !MOVUPS  [REGA], XMM0  
  EndMacro 

  Macro ASM_Vector_Min(REGA, REGD, REGC) 
    ;Vector_Min(*OutTVector, *IN1.TVector, *IN2.TVector)
      !MOV    REGA, [p.p_OUT]
			!MOV    REGC, [p.p_IN1]
			!MOV    REGD, [p.p_IN2]
			!MOVUPS XMM0, [REGC]    ; IN1
			!MOVUPS XMM1, [REGD]    ; IN2
			!MINPS  XMM0, XMM1
			!MOVUPS [REGA], XMM0    
  EndMacro
  
  Macro ASM_Vector_Max(REGA, REGD, REGC) 
    ;Vector_Max(*OutTVector, *IN1.TVector, *IN2.TVector)
      !MOV    REGA, [p.p_OUT]
			!MOV    REGC, [p.p_IN1]
			!MOV    REGD, [p.p_IN2]
			!MOVUPS XMM0, [REGC]    ; IN1
			!MOVUPS XMM1, [REGD]    ; IN2
			!MAXPS  XMM0, XMM1
			!MOVUPS [REGA], XMM0    
  EndMacro
  
  Macro ASM_Vector_MinMax(REGA, REGD, REGC) 
    ;Vector_MinMax(*IOmin.TVector, *IOmax.TVector, *IN.TVector)
      !MOV    REGA, [p.p_IOmin]
			!MOV    REGC, [p.p_IOmax]
			!MOV    REGD, [p.p_IN]
			
			!MOVUPS XMM0, [REGA]    ; IOmin
			!MOVUPS XMM2, [REGC]    ; IOmax
			
			!MOVUPS XMM1, [REGD]    ; IN
			
			!MINPS  XMM0, XMM1      ; Minimum to XMM0
			!MAXPS  XMM2, XMM1      ; Maximum to XMM2
			
			!MOVUPS [REGA], XMM0    ; Min
			!MOV    REGA, [p.p_IOmax]
			!MOVUPS [REGA], XMM2    ; Max				
  EndMacro

  Macro ASM_Vector_Swap (REGA, REGD, REGC) 
    ;Vector_Swap(*OUT.TVector, *IN.Tvector)
      !MOV     REGA, [p.p_IN]
      !MOVUPS  XMM0, [REGA]
      !PSHUFD  XMM1,XMM0, $1B   ; 00011011b = $1b = [0,1,2,3]=[00b,01b,10b,11b]  (SSE: PSHUFD => AVX: Vpermpd)
      !MOV     REGA, [p.p_OUT]
      !MOVUPS  [REGA], XMM1
  EndMacro
  
  Macro ASM_Vector_Scale (REGA, REGD, REGC) 
    ;Vector_Scale(*OUT.TVector, *IN.TVector, Factor.f)
      !MOVSS   XMM0, [p.v_Factor]
      !PSHUFD  XMM0, XMM0, $00    ; Shuffle Factor to all 4 sections
      !MOV     REGA, [p.p_IN] 
      !MOVUPS  XMM1, [REGA]        ; load Vector
      !MULPS   XMM1, XMM0
      !MOV     REGA, [p.p_OUT] 
      !MOVUPS  [REGA], XMM1
  EndMacro
  
  Macro ASM_Vector_CrossProduct (REGA, REGD, REGC) 
    ;Vector_CrossProduct(*OUT.TVector, *IN1.TVector, *IN2.TVector)
 			!MOV    REGA, [p.p_OUT]
			!MOV    REGC, [p.p_IN1]
			!MOV    REGD, [p.p_IN2]
			!MOVUPS XMM0, [REGC]
			!MOVUPS XMM1, [REGD]
			!MOVAPS XMM2, XMM0
			!MOVAPS XMM3, XMM1
			!SHUFPS XMM0, XMM0, 11001001b ; 3-0-2-1
			!SHUFPS XMM1, XMM1, 11010010b ; 3-1-0-2
			!SHUFPS XMM2, XMM2, 11010010b 
			!SHUFPS XMM3, XMM3, 11001001b 
			!MULPS  XMM0, XMM1
			!MULPS  XMM2, XMM3
			!SUBPS  XMM0, XMM2
			!MOVUPS [REGA], XMM0
  EndMacro
  
  Macro ASM_Vector_Lerp (REGA, REGD, REGC) 
    ;Vector_Lerp(*OUT.TVector, *A.TVector, *A.TVector, T.f)
    ; ret = A + (B-A) * T
    ; XMM0 = OUT  XMM1 = A  XMM2 = B
 			!MOV    REGC, [p.p_A]
			!MOV    REGD, [p.p_A]
      !MOVUPS  XMM2, [REGD]   ; A
      !MOVUPS  XMM1, [REGC]   ; B
      
      !MOVSS  XMM0, DWORD [p.v_T]     ; Load Timing Value
      !PSHUFD XMM0, XMM0, 00000000b   ; Shuffle T to all 4 32-Bit SubRegisters 
      
      !SUBPS  XMM2, XMM1      ; B-A -> XMM2
      !ADDPS  XMM2, XMM1      ; A + (B-A) -> XMM2
      !MULPS  XMM0, XMM2      ; T* (...)  
   		!MOV    REGA, [p.p_OUT]
      !MOVUPS [REGA], XMM0   
  EndMacro
  
  Macro ASM_Vector_Remap(REGA, REGD, REGC)
    ; Vector_Remap(*OUT.TVector, *IN.TVector, *inMin.TVector, *inMax.TVector, *outMin.TVector, *outMax.TVector, xRemapW=#False)    
    ; Out = (outMax - outMin)/(inMax - inMin) * (IN - inMin) + outMin
    
 			!MOV    REGC, [p.p_outMin]
			!MOV    REGD, [p.p_outMax]
			
			!MOVUPS  XMM0, [REGD]   ; outMax
      !MOVUPS  XMM1, [REGC]   ; outMin      
      !SUBPS XMM0, XMM1       ; XMM0 = (outMax - outMin)
      
 			!MOV    REGC, [p.p_inMin]
			!MOV    REGD, [p.p_inMax]
			!MOVUPS  XMM2, [REGD]   ; inMax
      !MOVUPS  XMM3, [REGC]   ; inMin
      !SUBPS XMM2, XMM3       ; XMM2 = (inMax - inMin)
      !DIVPS XMM0, XMM2       ; XMM0 = XMM0/XMM2 = (outMax - outMin)/(inMax - inMin)
      
 			!MOV    REGD, [p.p_IN]
 			!MOVUPS  XMM2, [REGC]   ; IN
 			!SUBPS XMM2, XMM3       ; XMM2 = (IN-inMin)
 			!MULPS XMM0, XMM2       ; XMM0 = (outMax - outMin)/(inMax - inMin) * (IN-inMin)
 			!ADDPS XMM0, XMM1       ; Add outMIn
 			
   		!MOV    REGA, [p.p_OUT]       ; RAX = Pointer *OUT
   		!MOVUPS [REGA], XMM0          ; OUT = Result
   		
   		!MOV REGC, [p.v_xRemapW]      
   		!CMP REGC, 0                            ; xRemapW=0 ?
    	!CMOVZ [REGA + 12], DWORD[REGD +12]     ;  OUT\w = IN\w  ; 3x4 Byte Offet; CMOVZ MoveIfZero  
   EndMacro
  
    
  Macro ASM_Vector_X_Matrix(REGA, REGD, REGC) 
   ;Vector_X_Matrix(*OUT.TVector, *IN.TVector, *Matrix.TMatrix)
  	  ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
      !MOV     REGD,  [p.p_IN]      ; load Adress of IN.VEctor
      !MOV     REGA,  [p.p_Matrix]  ; load Adress of Matrix
      ;!MOVUPS  XMM2, [REGD]
         !MOVLPS XMM2, [REGD]        ; split 128Bit MOVUPS to 2x 64 Bit MOVLPS, MOVHPS. It's faster because of unaligned Memory
         !MOVHPS XMM2, [REGD+8]      ; a modern CPU do 2 64Bit load/save parallel
        
      ; we use Shuffle command and vertical Add instead of horizontal Add, because Shuffle it's faster 
      ; Line 0
      !PSHUFD  XMM0, XMM2, 00000000b
      ;!MOVUPS  XMM3, [REGA + $00]
        !MOVLPS XMM3, [REGA + $00]
        !MOVHPS XMM3, [REGA + $08]
      !MULPS   XMM0, XMM3
      
      ; Line 1
      !PSHUFD  XMM1, XMM2, 01010101b
      ;!MOVUPS  XMM3, [REGA + $10]
        !MOVLPS XMM3, [REGA + $10]
        !MOVHPS XMM3, [REGA + $18]
      !MULPS   XMM1, XMM3
      !ADDPS   XMM0, XMM1
      
      ; Line 2
      !PSHUFD  XMM1, XMM2, 10101010b
      ;!MOVUPS  XMM3, [REGA + $20]
        !MOVLPS XMM3, [REGA + $20]
        !MOVHPS XMM3, [REGA + $28]
      !MULPS   XMM1, XMM3
      !ADDPS   XMM0, XMM1
      
      ; Line 3
      !PSHUFD  XMM1, XMM2, 11111111b
      ;!MOVUPS  XMM3, [REGA + $30]         
        !MOVLPS XMM3, [REGA + $30]
        !MOVHPS XMM3, [REGA + $38]
      !MULPS   XMM1, XMM3
      !ADDPS   XMM0, XMM1
      
      ; Return Result
      !MOV     REGA, [p.p_OUT] 
      !MOVUPS  [REGA], XMM0   
        ;!MOVLPS [REGA], XMM0
        ;!MOVHPS [REGA + 8], XMM0
  EndMacro
  
  Macro ASM_Vector_X_Matrix_test(REGA, REGD, REGC) 
   ;Vector_X_Matrix(*OUT.TVector, *IN.TVector, *Matrix.TMatrix)
  	  ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
      !MOV     REGD,  [p.p_IN]      ; load Adress of IN.VEctor
      !MOV     REGA,  [p.p_Matrix]  ; load Adress of Matrix
      !MOVUPS  XMM2, [REGD]
      ;!MOVDQU XMM2, [REGD]
        
      ; we use Shuffle command and vertical Add instead of horizontal Add, because Shuffle it's faster 
      ; Line 0
      !PSHUFD  XMM0, XMM2, 00000000b
      ;!MOVUPS  XMM3, [REGA + $00]
      !MOVDQU  XMM3, [REGA + $00]
      !MULPS   XMM0, XMM3
      
      ; Line 1
      !PSHUFD  XMM1, XMM2, 01010101b
      ;!MOVUPS  XMM3, [REGA + $10]
      !MOVDQU  XMM3, [REGA + $10]
      !MULPS   XMM1, XMM3
      !ADDPS   XMM0, XMM1
      
      ; Line 2
      !PSHUFD  XMM1, XMM2, 10101010b
      ;!MOVUPS  XMM3, [REGA + $20]
      !MOVDQU  XMM3, [REGA + $20]
      !MULPS   XMM1, XMM3
      !ADDPS   XMM0, XMM1
      
      ; Line 3
      !PSHUFD  XMM1, XMM2, 11111111b
      ;!MOVUPS  XMM3, [REGA + $30]         
      !MOVDQU  XMM3, [REGA + $30]         
      !MULPS   XMM1, XMM3
      !ADDPS   XMM0, XMM1
      
      ; Return Result
      !MOV     REGA, [p.p_OUT] 
      ;!MOVUPS  [REGA], XMM0   
      !MOVDQU  [REGA], XMM0   
   EndMacro

  
  Macro ASM_Matrix_X_Matrix(REGA, REGD, REGC)     
    ;Procedure Matrix_X_Matrix(*OUT.TMatrix, *M1.TMatrix, *M2.TMatrix)
    
    ; ATTENTION: The Pointer *OUT must be at RAX/EAX
    ; because this is the Return Value
    ; be shure to call the ASM_Matrix_X_Matrix(RAX, RDX, RCX) 
    ; do not swicht the Registers, otherwise you will get wrong Return Value
    
      ; ----------------------------------------------------------------------
      ; 1st PUSH the XMM-Register 6..7 to Stack because in PB-Inline-ASM
      ASM_PUSH_XMM_6to7(REGC)   ; Macro from "PbFw_ASM_Macros.pbi"
      ; ----------------------------------------------------------------------
      	      
      ; translated from the FreePascal Wiki at https://wiki.freepascal.org/SSE/de	  
			!MOV     REGD, [p.p_M1]
      !MOVUPS  XMM3, [REGD + $00]      ; M1\m11..14
      !MOVUPS  XMM4, [REGD + $10]      ; M1\m21..24
      !MOVUPS  XMM5, [REGD + $20]      ; M1\m31..34
      !MOVUPS  XMM6, [REGD + $30]      ; M1\m41..44
       
      ; Spalte 0
 			!MOV     REGD, [p.p_M2]          ; M2\m11..14
      !MOVUPS  XMM2, [REGD + $00]
      !PSHUFD  XMM0, XMM2, 00000000b
      !MULPS   XMM0, XMM3              ; (M1\m11..14) * M2.m11
       
      !PSHUFD  XMM1, XMM2, 01010101b
      !MULPS   XMM1, XMM4              ; (M1\m21..24) * M2.m12
      !ADDPS   XMM0, XMM1
      
      !PSHUFD  XMM1, XMM2, 10101010b
      !MULPS   XMM1, XMM5              ; (M1\m31..34) * M2.m13
      !ADDPS   XMM0, XMM1

      !PSHUFD  XMM1, XMM2, 11111111b
      !MULPS   XMM1, XMM6              ; (M1\m41..44) * M2.m14
      !ADDPS   XMM0, XMM1

  		!MOV     REGA, [p.p_OUT]         ; OUT\m11..14
      !MOVUPS  [REGA + $00], XMM0

      ; Spalte 1
      !MOVUPS  XMM2, [REGD + $10]      ; M2\m21..24
      !PSHUFD  XMM0, XMM2, 00000000b
      !MULPS   XMM0, XMM3              ; (M1\m11..14) * M2.m21

      !PSHUFD  XMM1, XMM2, 01010101b
      !MULPS   XMM1, XMM4              ; (M1\m21..24) * M2.m23
      !ADDPS   XMM0, XMM1

      !PSHUFD  XMM1, XMM2, 10101010b
      !MULPS   XMM1, XMM5              ; (M1\m31..34) * M2.m23
      !ADDPS   XMM0, XMM1

      !PSHUFD  XMM1, XMM2, 11111111b
      !MULPS   XMM1, XMM6              ; (M1\m41..44) * M2.m24
      !ADDPS   XMM0, XMM1

      !MOVUPS  [REGA + $10], XMM0      ; OUT\m21..24

      ; Spalte 2
      !MOVUPS  XMM2, [REGD + $20]      ; M2\m31..34

      !PSHUFD  XMM0, XMM2, 00000000b
      !MULPS   XMM0, XMM3

      !PSHUFD  XMM1, XMM2, 01010101b
      !MULPS   XMM1, XMM4
      !ADDPS   XMM0, XMM1

      !PSHUFD  XMM1, XMM2, 10101010b
      !MULPS   XMM1, XMM5
      !ADDPS   XMM0, XMM1

      !PSHUFD  XMM1, XMM2, 11111111b
      !MULPS   XMM1, XMM6
      !ADDPS   XMM0, XMM1

      !MOVUPS  [REGA + $20], XMM0      ; OUT\m31..34

      ; Spalte 3
      !MOVUPS  XMM2, [REGD + $30]      ; M2\m41..44

      !PSHUFD  XMM0, XMM2, 00000000b
      !MULPS   XMM0, XMM3

      !PSHUFD  XMM1, XMM2, 01010101b
      !MULPS   XMM1, XMM4
      !ADDPS   XMM0, XMM1

      !PSHUFD  XMM1, XMM2, 10101010b
      !MULPS   XMM1, XMM5
      !ADDPS   XMM0, XMM1

      !PSHUFD  XMM1, XMM2, 11111111b
      !MULPS   XMM1, XMM6
      !ADDPS   XMM0, XMM1

      !MOVUPS [REGA + $30], XMM0       ; OUT\m41..44
       
      ; ----------------------------------------------------------------------
      ; now resotre XMM-Register 6..7
      ASM_POP_XMM_6to7(REGC)
      ; ----------------------------------------------------------------------
       
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
    
  Macro mac_Vector_Scale(OUT, IN, Factor)
    OUT\x= IN\x * Factor   
    OUT\y= IN\y * Factor   
    OUT\z= IN\z * Factor    
    OUT\w= IN\w ; * Factor     
  EndMacro
  
  Macro mac_Vector_CrossProduct(OUT, IN1, IN2)
 		Out\X = IN1\Y * IN2\Z - IN1\Z * IN2\Y
		Out\Y = IN1\Z * IN2\X - IN1\X * IN2\Z
		Out\Z = IN1\X * IN2\Y - IN1\Y * IN2\X
		Out\W = 0
	EndMacro
	
	Macro mac_Lerp(ValStart, ValEnd, T)   
  ; ============================================================================
  ; NAME: Lerp
  ; DESC: Blending between ValStart..ValEnd from 0..100% with T={0..1}
  ; DESC: 
  ; VAR(ValStart): Startvalue A 
  ; VAR(ValEnd)  : Endvalue   B 
  ; VAR(T) : Time Value {0..1} = {0..100%}
  ; RET : Lerped Value in the Range {ValStart..ValEnd}
  ; ============================================================================
	  
	 ; For Lerp we have to call the Macro for each Coordinate X,Y,Z,[W]

    A + (B-A) * T   ; A*(1-T) + B*T
  EndMacro
	
  Macro mac_Remap(val, inMin, inMax, outMin, outMax)
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
    
    ; For Remap we have to call the Macro for each Coordinate X,Y,Z,[W]
    (outMax - outMin)/(inMax - inMin) * (val - inMin) + outMin
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
  	OUT\m12 = A\m12 * B\m11  +  A\m22 * B\m12  +  A\m32 * B\m13  +  A\m42 * B\m14
  	OUT\m13 = A\m13 * B\m11  +  A\m23 * B\m12  +  A\m33 * B\m13  +  A\m43 * B\m14
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
  	OUT\m43 = A\m13 * B\m41  +  A\m23 * B\m42  +  A\m33 * B\m43  +  A\m43 * B\m44
  	OUT\m44 = A\m14 * B\m41  +  A\m24 * B\m42  +  A\m34 * B\m43  +  A\m44 * B\m44
        	
  EndMacro
    
  ;- ======================================================================
  ;- Module Public Functions
  ;- ======================================================================
  
  ;  ----------------------------------------------------------------------
  ;- Vector-Functions
  ;-  ----------------------------------------------------------------------

  Procedure.i Vector_Add(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  ; ============================================================================
  ; NAME: Vector_ADD
  ; DESC: Add to Vectors Out = IN1 + IN2
  ; VAR(*OUT.TVector) : Pointer to Return-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector
  ; VAR(*IN2.TVector) : Pointer to IN2-Vector VECf::TVector    
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)    ; Check Pointer Exception
  
    CompilerSelect PbFw::#PbFw_USE_MMX_Type
      
      CompilerCase PbFw::#PbFw_SSE_x64        ; 64 Bit-Version        
        ASM_Vector_Add(RAX, RDX, RCX)         ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
               
      CompilerCase PbFw::#PbFw_SSE_x32        ; 32 Bit Version
        ASM_Vector_Add(EAX, EDX, ECX)         ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
      
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
        mac_Vector_ADD(*OUT, *IN1, *IN2)    
        ProcedureReturn *OUT

      CompilerDefault             ; Classic Version
        mac_Vector_ADD(*OUT, *IN1, *IN2)     
        ProcedureReturn *OUT

    CompilerEndSelect  
  EndProcedure
  
  Procedure.i Vector_Sub(*OUT.TVector, *IN1.TVector, *IN2.TVector) 
  ; ============================================================================
  ; NAME: Vector_SUB
  ; DESC: SUBtract to Vectors Out = IN1 - IN2
  ; VAR(*OUT.TVector) : Pointer to Return-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector    
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)    ; Check Pointer Exception

     CompilerSelect PbFw::#PbFw_USE_MMX_Type
          
      CompilerCase PbFw::#PbFw_SSE_x64        ; 64 Bit-Version
        ASM_Vector_SUB(RAX, RDX, RCX)         ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase PbFw::#PbFw_SSE_x32        ; 32 Bit Version
        ASM_Vector_SUB(EAX, EDX, ECX)         ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
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
  ; VAR(*OUT.TVector) : Pointer to Return-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector    
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)    ; Check Pointer Exception

    CompilerSelect PbFw::#PbFw_USE_MMX_Type
      
      CompilerCase PbFw::#PbFw_SSE_x64        ; 64 Bit-Version
        ASM_Vector_Mul(RAX, RDX, RCX)         ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase PbFw::#PbFw_SSE_x32        ; 32 Bit Version
        ASM_Vector_Mul(EAX, EDX, ECX)         ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase PbFw::#PbFw_SSE_C_Backend  ; for the C-Backend
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
  ; VAR(*OUT.TVector) : Pointer to Return-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector    
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)    ; Check Pointer Exception

    CompilerSelect PbFw::#PbFw_USE_MMX_Type
   
      CompilerCase PbFw::#PbFw_SSE_x64       ; 64 Bit-Version
        ASM_Vector_Div(RAX, RDX, RCX) ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase PbFw::#PbFw_SSE_x32       ; 32 Bit Version
        ASM_Vector_Div(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
       
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
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
  ; VAR(*OUT.TVector) : Pointer to Vector which receives the Min-Coordinates (x,y,z,w)
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector
  ; VAR(*IN2.TVector) : Pointer to IN1-Vector VECf::TVector
  ; RET.i : *OUT
  ; ============================================================================
    ; Das Krezprodukt ergbigt einen zu den beiden Vectoren senkrechten Vector
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)    ; Check Pointer Exception

    CompilerSelect PbFw::#PbFw_USE_MMX_Type
        
      CompilerCase PbFw::#PbFw_SSE_x64             ; 64 Bit-Version
        ASM_Vector_Min(RAX, RDX, RCX)       ; for x64 we use RAX,RDX,RCX
 			  ProcedureReturn ; RAX
 			   			
      CompilerCase PbFw::#PbFw_SSE_x32             ; 32 Bit Version
        ASM_Vector_Min(EAX, EDX, ECX)       ; for x32 we use Registers EAX,EDX,ECX
  			ProcedureReturn ; EAX
  			
      CompilerCase PbFw::#PbFw_SSE_C_Backend       ; for the C-Backend
        mac_Vector_Min(*OUT, *IN1, *IN2)       
        ProcedureReturn *OUT

      CompilerDefault                       ; Classic Version
        mac_Vector_Min(*OUT, *IN1, *IN2)       
        ProcedureReturn *OUT

    CompilerEndSelect     
  EndProcedure
  
  Procedure.i Vector_Max(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  ; ============================================================================
  ; NAME: Vector_Max
  ; DESC: Calculates the maximum coordiantes of 2 Vectors and return it in a
  ; DESC: Vector
  ; VAR(*OUT.TVector) : Pointer to Vector which receives the Max-Coordinates (x,y,z,w)
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector
  ; VAR(*IN2.TVector) : Pointer to IN1-Vector VECf::TVector
  ; RET.i : *OUT
  ; ============================================================================
    ; Das Krezprodukt ergbigt einen zu den beiden Vectoren senkrechten Vector
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)    ; Check Pointer Exception

    CompilerSelect PbFw::#PbFw_USE_MMX_Type
        
      CompilerCase PbFw::#PbFw_SSE_x64             ; 64 Bit-Version
        ASM_Vector_Min(RAX, RDX, RCX)       ; for x64 we use RAX,RDX,RCX
 			  ProcedureReturn ; RAX
  			
      CompilerCase PbFw::#PbFw_SSE_x32             ; 32 Bit Version
        ASM_Vector_Min(EAX, EDX, ECX)       ; for x32 we use Registers EAX,EDX,ECX
  			ProcedureReturn ; EAX
  			
      CompilerCase PbFw::#PbFw_SSE_C_Backend       ; for the C-Backend
        mac_Vector_Min(*OUT, *IN1, *IN2)       
        ProcedureReturn *OUT

      CompilerDefault                       ; Classic Version
        mac_Vector_Max(*OUT, *IN1, *IN2)       
        ProcedureReturn *OUT

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
  ; VAR(*OUT.TVector) : Pointer to Return-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *IN)    ; Check Pointer Exception

    CompilerSelect PbFw::#PbFw_USE_MMX_Type
      
      CompilerCase PbFw::#PbFw_SSE_x64   ; 64 Bit-Version
        ASM_Vector_Swap(RAX, RDX, RCX) ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
       
      CompilerCase PbFw::#PbFw_SSE_x32   ; 32 Bit Version
        ASM_Vector_Swap(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
        *OUT\x = *IN\w
        *OUT\y = *IN\z
        *OUT\y = *IN\y
        *OUT\w = *IN\x      
        ProcedureReturn *OUT

      CompilerDefault             ; Classic Version
        *OUT\x = *IN\w
        *OUT\y = *IN\z
        *OUT\y = *IN\y
        *OUT\w = *IN\x
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
  ; VAR(*OUT): Pointer to Return-Vector VECf::TVector
  ; VAR(*IN) : Pointer to IN1-Vector VECf::TVector
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*OUT, *IN)    ; Check Pointer Exception
    
    CompilerSelect PbFw::#PbFw_USE_MMX_Type
        
      CompilerCase PbFw::#PbFw_SSE_x64       ; 64 Bit-Version
        !MOV RAX, [p.p_OUT]
        !MOV RDX, [p.p_IN]
        !MOVLPS XMM0, [RDX]           ; IN Lo-64
        !MOVHPS XMM0, [RDX+8]         ; IN Hi-64
        !MOVLPS [RAX], XMM0           ; Out Lo-64
        !MOVHPS [RAX+8], XMM0         ; Out Hi 64
        ProcedureReturn     ; RAX
        
      CompilerCase PbFw::#PbFw_SSE_x32     ; 32 Bit Version
        !MOV EAX, [p.p_OUT]
        !MOV EDX, [p.p_IN]
        !MOVLPS XMM0, [EDX]           ; IN Lo-64
        !MOVHPS XMM0, [EDX+8]         ; IN Hi-64
        !MOVLPS [EAX], XMM0           ; Out Lo-64
        !MOVHPS [EAX+8], XMM0         ; Out Hi 64
        ProcedureReturn     ; EAX
        
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
        CopyMemory(*IN, *OUT, SizeOf(TVector))
        ProcedureReturn *OUT
        
      CompilerDefault                   ; Classic Version
        CopyMemory(*IN, *OUT, SizeOf(TVector))
        ProcedureReturn *OUT

    CompilerEndSelect       
  EndProcedure
  
  Procedure.i Vector_Set(*OUT.TVector, X.f=0.0, Y.f=0.0, Z.f=0.0, W.f=0.0)
  ; ============================================================================
  ; NAME: Vector_Set
  ; DESC: Sets the Vector coordinates
  ; VAR(*OUT.TVector): Pointer to Return-Vector VECf::TVector
  ; VAR(X.f) : The X-value
  ; VAR(Y.f) : The Y-value
  ; VAR(Z.f) : The Z-value
  ; VAR(W.f) : The W-value
  ; RET.i : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer(*OUT)    ; Check Pointer Exception
    
    CompilerSelect PbFw::#PbFw_USE_MMX_Type
      ; using MMX-Register to copy 4xFloat directly from Stack to destination
      ; AMD Code Optimation Guide: for unaligned Data, 2x 64Bit Moves are better
      ; MOVLPS and MOVHPS do not clear upper Bits of the Register
      ; MOVLPS = 2 Cyles! MOVUPS on 128Bit = 4 Cycles; MOVLPS + MOVHPS are proceeded
      ; parallel, so the to commands MOVLPS + MOVHPS together need 2 Cycles
       
     CompilerCase PbFw::#PbFw_SSE_x64     ; 64 Bit-Version
       ; at x64 an 8-Byte-Align is used, so we can not copy the complete Vector
       ; directly from the Stack. We have to use 4 seperate operations!
      With *OUT
        \X = X
        \Y = Y
        \Z = Z
        \W = W
      EndWith
;       Debug "VectorSet-Pointers"    ; 8-Byte-Align for 4 Byte Values
;       Debug @X
;       Debug @Y
;       Debug @Z
              
      CompilerCase PbFw::#PbFw_SSE_x32     ; 32 Bit Version
        !LEA EDX, [p.v_X]
        !MOV EAX, [p.p_OUT]
        ;!MOVUPS XMM0, [EDX]          ; AMD Code Optimation Guide page 214:
        !MOVLPS XMM0, [EDX]           ; "for unaligned Data, 2 64 Bit Moves
        !MOVHPS XMM0, [EDX+8]         ; are faster"
         ;!MOVUPS [EAX], XMM0
        !MOVLPS [EAX],   XMM0
        !MOVHPS [EAX+8], XMM0
        ProcedureReturn   ; EAX
       
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
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
  
  Procedure.f Vector_Length(*IN.TVector)
  ; ============================================================================
  ; NAME: Vector_Length
  ; DESC: Calculates the Vector Length L=SQRT(x² + y² + z²) 
  ; VAR(*IN.TVector): Pointer to the Vector VECf::TVector
  ; RET.f :  The Vector length
  ; ============================================================================
    
    DBG::mac_CheckPointer(*IN)    ; Check Pointer Exception

    ProcedureReturn Sqr( *IN\X * *IN\X + *IN\Y * *IN\Y + *IN\Z * *IN\Z )
  EndProcedure 
  
  Procedure.i Vector_Normalize(*InOut.TVector)
  ; ============================================================================
  ; NAME: Vector_Normalize
  ; DESC: Normalize a Vector to Length=1
  ; VAR(*InOut.TVector): Pointer to the Vector VECf::TVector
  ; RET.f :  The Vector length
  ; ============================================================================
    
    DBG::mac_CheckPointer(*InOut)    ; Check if Pointers is 0

    Protected Length.f = Vector_Length(*InOut)
  	If Length
  		Length = 1.0 / Length
  		*InOut\X * Length
  		*InOut\Y * Length
  		*InOut\Z * Length
  	EndIf
  	ProcedureReturn *InOut
  EndProcedure
  
  Procedure.f Vector_Scalar(*IN1.TVector, *IN2.TVector)
  ; ============================================================================
  ; NAME: Vector_Scalar
  ; DESC: Calculates the Scalar Product of 2 Vectors
  ; DESC: S = v1(x) * v2(x) + v1(y) * v2(y) + v1(z) * v2(z)
  ; VAR(*IN1) : Pointer to IN1-Vector VECf::TVector
  ; VAR(*IN1) : Pointer to IN1-Vector VECf::TVector    
  ; RET.f :  The Scalar Product
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*IN1, *IN2)    ; Check Pointer Exception

    ProcedureReturn *IN1\X * *IN2\X + *IN1\Y * *IN2\Y + *IN1\Z * *IN2\Z
  EndProcedure

  Procedure.i Vector_Scale(*OUT.TVector, *IN.TVector, Factor.f)
  ; ============================================================================
  ; NAME: Vector_Scale
  ; DESC: Scales a Vector with a Factor V() * Factor
  ; VAR(*OUT.TVector): Pointer To Return-Vector VECf::TVector
  ; VAR(*IN.TVector) : Pointer to IN1-Vector VECf::TVector
  ; VAR(Factor.f): The scaling factor
  ; RET.i : *OUT
  ; ============================================================================
   
    DBG::mac_CheckPointer2(*OUT, *IN)     ; Check Pointer Exception

    CompilerSelect PbFw::#PbFw_USE_MMX_Type
      
      CompilerCase PbFw::#PbFw_SSE_x64    ; 64 Bit-Version       
        ASM_Vector_Scale(RAX, RDX, RCX)   ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase PbFw::#PbFw_SSE_x32    ; 32 Bit Version
        ASM_Vector_Scale(EAX, EDX, ECX)   ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
        mac_Vector_Scale(*OUT, *IN, Factor)        
        ProcedureReturn *OUT

      CompilerDefault                     ; Classic Version
        mac_Vector_Scale(*OUT, *IN, Factor)        
        ProcedureReturn *OUT

    CompilerEndSelect   
  EndProcedure
  
  Procedure.i Vector_CrossProduct(*OUT.TVector, *IN1.TVector, *IN2.TVector)
  ; ============================================================================
  ; NAME: VectorCrossProduct
  ; DESC: Calculates the Vector-Cross-Product
  ; VAR(*OUT.TVector): Pointer to Return-Vector VECf::TVector
  ; VAR(*IN1.TVector) : Pointer to IN1-Vector VECf::TVector
  ; VAR(*IN2.TVector) : Pointer to IN2-Vector VECf::TVector
  ; RET.i : *OUT
  ; ============================================================================
   ; Das Krezprodukt ergbigt einen zu den beiden Vectoren senkrechten Vector        
     
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)      ; Check Pointer Exception
    
    CompilerSelect PbFw::#PbFw_USE_MMX_Type
        
      CompilerCase PbFw::#PbFw_SSE_x64            ; 64 Bit-Version
        ASM_Vector_CrossProduct(RAX, RDX, RCX)    ; for x64 we use RAX,RDX,RCX
 			  ProcedureReturn ; RAX
  			
      CompilerCase PbFw::#PbFw_SSE_x32            ; 32 Bit Version
        ASM_Vector_CrossProduct(EAX, EDX, ECX)    ; for x32 we use Registers EAX,EDX,ECX
  			ProcedureReturn ; EAX
  			
      CompilerCase PbFw::#PbFw_SSE_C_Backend      ; for the C-Backend
        mac_VectorCrossProduct(*Out, *IN1, *IN2)       
        ProcedureReturn *OUT

      CompilerDefault                             ; Classic Version
        mac_Vector_CrossProduct(*Out, *IN1, *IN2)       
        ProcedureReturn *OUT

    CompilerEndSelect    
  EndProcedure
  
  Procedure Vector_Lerp(*OUT.TVector, *A.TVector, *B.TVector, T.f)
  ; ============================================================================
  ; NAME: Vector_Lerp
  ; DESC: Blending from IN1 to IN2 from 0..100% with T={0..1}
  ; DESC: This can be used for straight moving in a 3D Space form Point IN1 to IN2
  ; DESC: according to the Time Value T
  ; VAR(*A.TVector): Start Vector  (from)
  ; VAR(*B.TVector): End Vector    (to)
  ; VAR(T) : Time Value {0..1} = {0..100%}
  ; VAR(xLerpW): #False = do not Lerp \w Coordinate, #True = Lerp \w 
  ; RET : Lerped Vector in the Range {IN1..IN2}
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *A, *B)     ; Check Pointer Exception

    CompilerSelect PbFw::#PbFw_USE_MMX_Type
      
      CompilerCase PbFw::#PbFw_SSE_x64    ; 64 Bit-Version              
        ASM_Vector_Lerp(RAX, RDX, RCX)    ; for x64 we use RAX,RDX,RCX
        ; maybe here we must save EAX, to not overwrite during following If
        ProcedureReturn ; RAX
        
      CompilerCase PbFw::#PbFw_SSE_x32    ; 32 Bit Version        
        ASM_Vector_Lerp(EAX, EDX, ECX)    ; for x32 we use Registers EAX,EDX,ECX
        ; maybe here we must save EAX, to not overwrite during following If
       ProcedureReturn ; EAX
        
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
        mac_Lerp(*OUT\x, *A\x *B\x, T)        
        mac_Lerp(*OUT\y, *A\y *B\y, T)        
        mac_Lerp(*OUT\z, *A\x *B\z, T)        
        mac_Lerp(*OUT\w, *A\w *B\w, T)   
        ProcedureReturn *OUT

      CompilerDefault                     ; Classic Version
        mac_Lerp(*OUT\x, *A\x *B\x, T)        
        mac_Lerp(*OUT\y, *A\y *B\y, T)        
        mac_Lerp(*OUT\z, *A\x *B\z, T)        
        mac_Lerp(*OUT\w, *A\w *B\w, T)   
        ProcedureReturn *OUT

    CompilerEndSelect   
  
  EndProcedure
  
  Procedure.f Vector_InverseLerp(*A.TVector, *B.TVector, *V.TVector, XYZW.i=#PbFw_VectorCoordinate_X)
  ; ============================================================================
  ; NAME: Vector_InverseLerp
  ; DESC: Get the BlendingTime T{0..1} of the Value V in the Range 
  ; DESC: This can be used to get Back the Time Position of the Vector in the Range {A..B}
  ; DESC: or you can interpret this as Postion in % between A and B
  ; VAR(*A.TVector): Start Vector  (from)
  ; VAR(*B.TVector): End Vector    (to)
  ; VAR(*V.TVector): Vector to calculate Time for
  ; VAR(XYZW.i): Index fo Vector Coordinate to use for the calculation. 
  ;              use {X,Y,Z,W}={0,1,2,3} Default=#PbFw_VectorCoordinate_X
  ; RET.d : Time Value {0..1} = {0..100%}
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*A, *B, *V)     ; Check Pointer Exception
    Protected ret.f
    
    Select XYZW
      Case #PbFw_VectorCoordinate_Y
        ret= (*V\x - *A\x) / (*B\x - *A\x)
        
      Case #PbFw_VectorCoordinate_Y
        ret= (*V\y - *A\y) / (*B\y - *A\y)
        
      Case #PbFw_VectorCoordinate_Z
        ret= (*V\z - *A\z) / (*B\z - *A\z)
        
      Case #PbFw_VectorCoordinate_W
        ret= (*V\w- *A\w) / (*B\w - *A\w)
        
      Default   ; any Other Value -> use X-Coordinate
        ret= (*V\x - *A\x) / (*B\x - *A\x)
    EndSelect
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i Vector_Remap(*OUT.TVector, *IN.TVector, *inMin.TVector, *inMax.TVector, *outMin.TVector, *outMax.TVector, xRemapW=#False)
  ; ============================================================================
  ; NAME: Vector_Remap
  ; DESC: Scales a value what is in the 
  ; DESC: Range {inMin..inMax} ro a new Range {outMin..outMax}
  ; DESC: 
  ; DESC:                       (outMax - outMinOut)
  ; DESC: ret = (val - inMin) ------------------------  + outMin
  ; DESC:                         (inMax - inMin) 
  ; DESC: 
  ; DESC: This calculation is done for X,Y,Z, W only, if xRemapW=#TRUE
  ; VAR(*Out.TVector): Pointer to ReturnValue
  ; VAR(*IN.TVector) : in Value Vector
  ; VAR(*inMin.TVector) : Input Range Minimum
  ; VAR(*inMax.TVector) : Input Range Maximum
  ; VAR(*outMin.TVector): Output Range Minimum
  ; VAR(*outMax.TVector): Output Range Maximum
  ; VAR(xRemapW): #False = don't remap Vector\W; #True = remap Vector\W too
  ; RET : *OUT
  ; ============================================================================
    
    DBG::mac_CheckPointer3(*OUT, *IN, *inMin)         ; Check Pointer Exception
    DBG::mac_CheckPointer3(*inMax, *outMin, *outMax)  ; Check Pointer Exception

    CompilerSelect PbFw::#PbFw_USE_MMX_Type
      
      CompilerCase PbFw::#PbFw_SSE_x64      ; 64 Bit-Version             
        ASM_Vector_Remap(RAX, RDX, RCX)     ; for x64 we use RAX,RDX,RCX
        ProcedureReturn ; RAX
        
      CompilerCase PbFw::#PbFw_SSE_x32      ; 32 Bit Version        
        ASM_Vector_Remap(EAX, EDX, ECX)     ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
        
      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend
        mac_Vector_Remap(*OUT\x, *IN\x, *inMin\x, *inMax\x, *outMin\x, *outMax\x)        
        mac_Vector_Remap(*OUT\y, *IN\y, *inMin\y, *inMax\y, *outMin\y, *outMax\y)        
        mac_Vector_Remap(*OUT\z, *IN\z, *inMin\z, *inMax\z, *outMin\z, *outMax\z)
        
        If xRemapW
          mac_Vector_Remap(*OUT\w, *IN\w, *inMin\w, *inMax\w, *outMin\w, *outMax\w)        
        EndIf        
        
        ProcedureReturn *OUT

      CompilerDefault                       ; Classic Version
        mac_Vector_Remap(*OUT\x, *IN\x, *inMin\x, *inMax\x, *outMin\x, *outMax\x)        
        mac_Vector_Remap(*OUT\y, *IN\y, *inMin\y, *inMax\y, *outMin\y, *outMax\y)        
        mac_Vector_Remap(*OUT\z, *IN\z, *inMin\z, *inMax\z, *outMin\z, *outMax\z)
        
        If xRemapW
          mac_Vector_Remap(*OUT\w, *IN\w, *inMin\w, *inMax\w, *outMin\w, *outMax\w)        
        EndIf
        
        ProcedureReturn *OUT

    CompilerEndSelect   
  
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Matrix-Functions
  ;- ----------------------------------------------------------------------
  
  ;  As Matrix notation  |   As Vector notation
  ; ------------------------------------------------------
  ; m11  m12  m13  m14   |   [0]\x  [0]\y  [0]\z  [0]\w 
  ; m21  m22  m23  m24   |   [1]\x  [1]\y  [1]\z  [1]\w
  ; m31  m32  m33  m34   |   [2]\x  [2]\y  [2]\z  [2]\w
  ; m41  m42  m43  m44   |   [3]\x  [3]\y  [3]\z  [3]\w
  ; -----------------------------------------------------
  ; m11 == Matrix\v[0]\x  m12 == Matrix\v[0]\y ...

  Procedure.i SetMatrixIdentity(*Matrix.TMatrix) ; EinheitsMatrix
  ; ============================================================================
  ; NAME: SetMatrixIdentity
  ; DESC: Set the Indentity Matrix
  ; DESC: returns a STL-Solid Structure which conatains all the Triangles.
  ; VAR(*Matrix) : Pointer to VECf::TMatrix
  ; RET.i : *Matrix
  ; ============================================================================
    
    ; 3D-Identity Matrix (Einheitsmatrix)
    ; |1   0   0   0 | 
    ; |0   1   0   0 | 
    ; |0   0   1   0 | 
    ; |0   0   0   1 | 
    
    DBG::mac_CheckPointer(*Matrix)      ; Check Pointer Exception

    mac_SetVector(*Matrix\v[0], 1, 0, 0, 0) ; (X ,Y, Z, W)
	  mac_SetVector(*Matrix\v[1], 0, 1, 0, 0)
	  mac_SetVector(*Matrix\v[2], 0, 0, 1, 0)
	  mac_SetVector(*Matrix\v[3], 0, 0, 0, 1) 
	  
	  ProcedureReturn *Matrix
  EndProcedure

  Procedure.i SetMatrixTranslation(*Matrix.TMatrix, dX.f, dY.f, dZ.f)
  ; ============================================================================
  ; NAME: SetMatrixTranslation
  ; DESC: Set the Matrix for Translation operation dX, dY, dZ
  ; DESC: Translation is a Movement with (dX,dY,dZ)
  ; VAR(*Matrix.TMatrix) : Pointer to VECf::TMatrix
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

    DBG::mac_CheckPointer(*Matrix)      ; Check Pointer Exception
    
    mac_SetVector(*Matrix\v[0],  1,  0,  0,  dX) ; (X ,Y, Z, W)
  	mac_SetVector(*Matrix\v[1],  0,  1,  0,  dY)
  	mac_SetVector(*Matrix\v[2],  0,  0,  1,  dZ)
  	mac_SetVector(*Matrix\v[3],  0,  0,  0,  1)
  	
	  ProcedureReturn *Matrix
  EndProcedure
  
  Procedure SetMatrixScale(*Matrix.TMatrix, Sx.f, Sy.f, Sz.f)
  ; ============================================================================
  ; NAME: SetMatrixScale
  ; DESC: Set the Matrix for Scaling (Zoom)
  ; VAR(*Matrix.TMatrix) : Pointer to VECf::TMatrix
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
    
    DBG::mac_CheckPointer(*Matrix)      ; Check Pointer Exception
    
    mac_SetVector(*Matrix\v[0], Sx,   0,   0,  0) ; (X ,Y, Z, W)
	  mac_SetVector(*Matrix\v[1],  0,  Sy,   0,  0)
	  mac_SetVector(*Matrix\v[2],  0,   0,  Sz,  0)
	  mac_SetVector(*Matrix\v[3],  0,   0,   0,  1)
	  
	  ProcedureReturn *Matrix
  EndProcedure
  
	Procedure.i SetMatrixRotX(*Matrix.TMatrix, Angle.f)
  ; ============================================================================
  ; NAME: SetMatrixRotX
  ; DESC: Set the Matrix for Rotation arround X-Axis
  ; VAR(*Matrix.TMatrix) : Pointer to VECf::TMatrix
	; VAR(Angle.f) : Angle in Radian (use Radain() to convert Degree to Radian
  ; RET.i : *Matrix
  ; ============================================================================
	  
	  Protected s.f=Sin(Angle)
	  Protected c.f=Cos(Angle)
	  
    ; Rotation X
    ; | 1     0      0    0 | 
    ; | 0    cos   -sin   0 | 
    ; | 0    sin    cos   0 | 
    ; | 0     0      0    1 | 
 	
    DBG::mac_CheckPointer(*Matrix)      ; Check Pointer Exception
    
    mac_SetVector(*Matrix\v[0],  1,  0,   0,  0) ; (X ,Y, Z, W)
  	mac_SetVector(*Matrix\v[1],  0,  c,  -s,  0)
  	mac_SetVector(*Matrix\v[2],  0,  s,   c,  0)
  	mac_SetVector(*Matrix\v[3],  0,  0,   0,  1)   
 
	  ProcedureReturn *Matrix
  EndProcedure
	  
  Procedure.i SetMatrixRotY(*Matrix.TMatrix, Angle.f)
  ; ============================================================================
  ; NAME: SetMatrixRotY
  ; DESC: Set the Matrix for Rotation arround Y-Axis
  ; VAR(*Matrix.TMatrix) : Pointer to VECf::TMatrix
	; VAR(Angle.f) : Angle in Radian (use Radain() to convert Degree to Radian
  ; RET.i : *Matrix
  ; ============================================================================
    
    Protected s.f=Sin(Angle)
	  Protected c.f=Cos(Angle)
	  
    ; Rotation Y
    ; | cos   0    sin   0 | 
    ; |  0    1     0    0 | 
    ; |-sin   0    cos   0 |
    ; |  0    0     0    1 | 
	  
    DBG::mac_CheckPointer(*Matrix)      ; Check Pointer Exception
    
    mac_SetVector(*Matrix\v[0],   c, 0,  s, 0) ; (X ,Y, Z, W)
	  mac_SetVector(*Matrix\v[1],   0, 1,  0, 0)
	  mac_SetVector(*Matrix\v[2],  -s, 0,  c, 0)
	  mac_SetVector(*Matrix\v[3],   0, 0,  0, 1)   
  
	  ProcedureReturn *Matrix
  EndProcedure
  
  Procedure.i SetMatrixRotZ(*Matrix.TMatrix, Angle.f)
  ; ============================================================================
  ; NAME: SetMatrixRotZ
  ; DESC: Set the Matrix for Rotation arround Z-Axis
  ; VAR(*Matrix.TMatrix) : Pointer to VECf::TMatrix
	; VAR(Angle.f) : Angle in Radian (use Radain() to convert Degree to Radian
  ; RET.i : *Matrix
  ; ============================================================================
    
    Protected s.f=Sin(Angle)
	  Protected c.f=Cos(Angle)
	  
    ; Rotation Z
    ; |cos   -sin   0   0 | 
    ; |sin    cos   0   0 |  
    ; | 0      0    1   0 | 
    ; | 0      0    0   1 | 
  	
    DBG::mac_CheckPointer(*Matrix)      ; Check Pointer Exception
    
    mac_SetVector(*Matrix\v[0],  c, -s,  0,  0) ; (X ,Y, Z, W)
	  mac_SetVector(*Matrix\v[1],  s,  c,  0,  0)
	  mac_SetVector(*Matrix\v[2],  0,  0,  1,  0)
	  mac_SetVector(*Matrix\v[3],  0,  0,  0,  1)   
	  
	  ProcedureReturn *Matrix
	EndProcedure
	
  Procedure.i SetMatrixRotXYZ(*Matrix.TMatrix, AngleX.f, AngleY.f, AngleZ.f)
  ; ============================================================================
  ; NAME: SetMatrixRotXYZ
  ; DESC: Set the Matrix for Rotation arround all 3-Axis
  ; VAR(*Matrix.TMatrix) : Pointer to VECf::TMatrix
  ; VAR(AngleX.f) : Angle X in Radian (use Radain() to convert Degree to Radian
  ; VAR(AngleY.f) : Angle Y in Radian (use Radain() to convert Degree to Radian
  ; VAR(AngleZ.f) : Angle Z in Radian (use Radain() to convert Degree to Radian   
  ; RET.i : *Matrix
  ; ============================================================================
    
    DBG::mac_CheckPointer(*Matrix)      ; Check Pointer Exception

    ;   maybe later, calculate the Matrix directly by using Sin, Cos functions for
    ;   Each element or the Matrix. Might be faster than 2 times Matrix_X_Matrix
    
    ;     Protected.f SinX, SinY, SinZ 
    ;     Protected.f CosX, CosY, CosZ
    ;       
    ;     SinX=Sin(AngleX) : CosX=Cos(AngleX)
    ;     SinY=Sin(AngleY) : CosY=Cos(AngleY)
    ;     SinZ=Sin(AngleZ) : CosZ=Cos(AngleZ)
    ;       
    ;     With *Matrix         
    ;       \m11= CosY*CosZ                   : \m12= SinX*SinY*CosZ + CosX*SinZ  :  \m13= SinY        : \m14= 0
    ;       \m21= -CosY*SinZ                  : \m22= -SinX*SinY*SinZ+ CosX*CosZ  :  \M23= -SinX*CosY  : \m24= 0
    ;       \m31= SinY                        : \m32= CosX*SinY*SinZ + SinX*CosZ  :  \m33= CosX*CosY   : \m34= 0
    ;       \m41= 0                           : \m42= 0                           :  \m43= 0           : \m44= 1
    ;       
    ;     EndWith 

 
    Protected m1.TMatrix, m2.TMatrix, m3.TMatrix
        
    SetMatrixRotX(m1, AngleX)
    SetMatrixRotY(m2, AngleY)
    
    Matrix_X_Matrix(m3, m1, m2)       ; XY-Matirx

    SetMatrixRotZ(m1, AngleZ)         ; m1 = Z-matrix
    
    Matrix_X_Matrix(*Matrix, m1, m3)  ; OUT = Z-Matrix * XY-Matrix
    
    ProcedureReturn *Matrix
  EndProcedure
  
  ;   	*Use\A11 =  CosY*CosZ                : *Use\A12 = -CosY*SinZ                : *Use\A13 =  SinY
  ;   	
  ;   	*Use\A21 =  SinX*SinY*CosZ+CosX*SinZ : *Use\A22 = -SinX*SinY*SinZ+CosX*CosZ : *Use\A23 = -SinX*CosY
  ;   	
  ;   	*Use\A31 = -CosX*SinY*CosZ+SinX*SinZ : *Use\A32 =  CosX*SinY*SinZ+SinX*CosZ : *Use\A33 =  CosX*CosY

  
  Procedure.i Vector_X_Matrix(*OUT.TVector, *IN.TVector, *Matrix.TMatrix)
  ; ============================================================================
  ; NAME: Vector_X_Matrix
  ; DESC: Caluclate the Vector-Matrix-Product  V()xM()
  ; VAR(*OUT.TVector) : Pointer to Return-Vector VECf::TVector
  ; VAR(*IN.TVector) : Pointer to a VECf::TVector
  ; VAR(*Matrix.TMatrix) : Pointer to a VECf::TMatrix
	; VAR(Angle.f) : Angle in Radian (use Radain() to convert Degree to Radian
  ; RET.i : *Matrix
  ; ============================================================================
   
    DBG::mac_CheckPointer3(*OUT, *IN, *Matrix)      ; Check Pointer Exception
    
    CompilerSelect PbFw::#PbFw_USE_MMX_Type
        
      CompilerCase PbFw::#PbFw_SSE_x64             ; 64 Bit-Version
       ASM_Vector_X_Matrix(RAX, RDX, RCX)  ; for x64 we use RAX,RDX,RCX
       ProcedureReturn ; RAX
                 
  		CompilerCase PbFw::#PbFw_SSE_x32             ; 32 Bit Version
        ASM_Vector_X_Matrix(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
        ProcedureReturn ; EAX
  		  
;   		  mac_Vector_X_Matrix(*OUT, *IN, *Matrix)
;         ProcedureReturn *OUT

      CompilerCase PbFw::#PbFw_SSE_C_Backend   ; for the C-Backend  
        mac_Vector_X_Matrix(*OUT, *IN, *Matrix)
        ProcedureReturn *OUT

      CompilerDefault                   ; Classic Version
        mac_Vector_X_Matrix(*OUT, *IN, *Matrix)
        ProcedureReturn *OUT

    CompilerEndSelect       
  EndProcedure
  
  Procedure.i Matrix_X_Matrix(*OUT.TMatrix, *M1.TMatrix, *M2.TMatrix)
  ; ============================================================================
  ; NAME: Matrix_X_Matrix
  ; DESC: Caluclate the Matrix-Matrix-Product  M() x M()
  ; DESC: ATTENTION: *OUT must be different from *M1, *M2
  ; DESC:    Matrix_X_Matrix(myInOut, myInOut, myIN) will cause wrong results!
  ; VAR(*OUT.TMatrix): Pointer to Return-Matrix VECf::TMatrix
  ; VAR(*M1.TMatrix): Pointer to IN1 Matrix a VECf::TMatrix
  ; VAR(*M2.TMatrix): Pointer to IN2 Matrix a VECf::TMatrix
  ; RET.i : *OUT
  ; ============================================================================
        
    DBG::mac_CheckPointer3(*OUT, *M1, *M2)      ; Check Pointer Exception
    
    CompilerSelect PbFw::#PbFw_USE_MMX_Type
        
      CompilerCase PbFw::#PbFw_SSE_x64     ; 64 Bit-Version
          ASM_Matrix_X_Matrix(RAX, RDX, RCX)  ; for x64 we use RAX,RDX,RCX
          ProcedureReturn  ; RAX
         
;          mac_Matrix_X_Matrix(*OUT, *M1, *M2) 
;          ProcedureReturn *OUT
        
      CompilerCase PbFw::#PbFw_SSE_x32     ; 32 Bit Version
         ASM_Matrix_X_Matrix(EAX, EDX, ECX) ; for x32 we use Registers EAX,EDX,ECX
         ProcedureReturn  ; EAX
         
;         mac_Matrix_X_Matrix(*OUT, *M1, *M2) 
;         ProcedureReturn *OUT
        
      CompilerCase PbFw::#PbFw_SSE_C_Backend     ; for the C-Backend
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

  Procedure.f MinOf3(Value1.f, Value2.f, Value3.f=1.0e100)
  ; ============================================================================
  ; NAME: MinOf3
  ; DESC: Calculates the Minimum of 3 Values
  ; VAR(Value1.f) : Value 1
  ; VAR(Value2.f) : Value 2
  ; VAR(Value3.f) : Value 3
  ; RET.f : Min(Value1, Value2, Value3)
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
 
  Procedure.f MaxOf3(Value1.f, Value2.f, Value3.f=-1.0e100)
  ; ============================================================================
  ; NAME: MaxOf3
  ; DESC: Calculates the Maximum of 3 Values
  ; VAR(Value1.f) : Value 1
  ; VAR(Value2.f) : Value 2
  ; VAR(Value3.f) : Value 3
  ; RET.f : Max(Value1, Value2, Value3)
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
  UseModule VECf
  
  ; ----------------------------------------------------------------------
  ;  Define Variables
  ; ----------------------------------------------------------------------
  Global.TVector sA, sB, sC    ; single Vectors
  
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
    ;mac_SetVector(sA,  1, 2, 3, 4)
    Vector_Set(sA, 11,12,13,4)
    Debug "Vector_Set : 1,2,3,4"
    mac_Debug_Vector(sA)
    mac_SetVector(sB, 10,20,30,40)  
  EndMacro
   
  ; ----------------------------------------------------------------------
  ;  Test Procedures
  ; ----------------------------------------------------------------------

  Procedure Test_VectorAdd()  
    Debug "----------------------------------------"
    Debug "Vetor_Add()"    
    Vector_Add(sC, sA , sB)
    mac_Debug_Result(sC, sA, sB)
  EndProcedure
  
  Procedure Test_VectorSUB()  
    Debug "----------------------------------------"
    Debug "Vetor_SUB()"   
    Vector_SUB(sC, sA , sB)
    mac_Debug_Result(sC, sA, sB)
  EndProcedure
 
  Procedure Test_VectorMul()  
    Debug "----------------------------------------"
    Debug "Vetor_Mul()"   
    Vector_Mul(sC, sA , sB)
    mac_Debug_Result(sC, sA, sB)
  EndProcedure

  Procedure Test_VectorDiv()  
    Debug "----------------------------------------"
    Debug "Vetor_Div()"   
    Vector_Div(sC, sA , sB)
    mac_Debug_Result(sC, sA, sB)
   EndProcedure
  
  Procedure Test_VectorSwap()  
    Debug "----------------------------------------"
    Debug "Vetor_Swap()"   
    Vector_Swap(sC, sA)
    mac_Debug_Result(sC, sA, sA)
  EndProcedure
  
  Procedure Test_VectorScale()  
    Debug "----------------------------------------"
    Debug "Vetor_Scale(*2.5)"   
    
    Vector_Scale(sC, sA, 2.5)
    mac_Debug_Result(sC, sA, sA)
  EndProcedure

  Procedure Test_VectorCrossProduct()  
    Debug "----------------------------------------"
    Debug "Vector_CrossProduct()"
    mac_SetVector(sA, 2, -1, 5 ,0)
    mac_SetVector(sB, 6, 7, 2 , 0)
    ; correct Result = (-37,26,20) 
    Vector_CrossProduct(sC, sA, sB)
    Debug ("correct Result (-37,26,20)")
    mac_Debug_Result(sC, sA, sA)
  EndProcedure
  
  Procedure Test_Vector_X_Matrix()
    Protected mx.TMatrix 
   
    Debug "----------------------------------------"
    Debug "Vector_X_Matrix()"
   
    Vector_X_Matrix(sC, sA, mx)
  EndProcedure
  
  Procedure Test_Matrix_X_Matrix()
    Protected mx0.Tmatrix, mx1.TMatrix, mx2.TMatrix
    
    Debug "----------------------------------------"
    Debug "Marix_X_Matrix()"
    
    Matrix_X_Matrix(mx0, mx1, mx2)
    
  EndProcedure
  
  SetVectorBasicValues()        ; Set Vectors to basic valus
  
  Debug "----------------------------------------"
  mac_Debug_AB(sA, sB)  ; Show A and B in Debug output
  
  ; correct Results at x32
  Test_VectorAdd()          ; Test the Vector_Add funtions
  Test_VectorSUB()          ; Test the Vector_SUB funtions
  Test_VectorMul()          ; Test the Vector_Mul funtions
  Test_VectorDiv()          ; Test the Vector_Div funtions
  Test_VectorSwap()         ; Test the Vector_Div funtions
  Test_VectorScale()        ; Test the Vector_Div funtions
  
  Test_VectorCrossProduct() ; Test the Vector_CrossProduct funtions
  
  Test_Vector_X_Matrix()
  Test_Matrix_X_Matrix()
  
CompilerEndIf


; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 48
; FirstLine = 24
; Folding = -------------
; Optimizer
; CPU = 5