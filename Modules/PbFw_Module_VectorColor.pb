; ===========================================================================
;  FILE: PbFw_Module_VectorColor.pb
;  NAME: VectorColor Module [VecCol::]
;  DESC: This module impements VectorColor operations with MMX/SSE optimation!
;  DESC: A VectorColor is a packed float Color-Structure 
;  DESC: Reed, Green, Blue, Alpha as single precision floats 
;  DESC: (R.F, G.f, B.f, A.f)
;  DESC: Colors in VectorColor-Format are used in 3D-Grafic-Secenes
;  DESC: because this is more acurat for rendering
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/02/18
; VERSION  :  0.0   Brainstorming Version
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;             
; ============================================================================


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

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
XIncludeFile "PbFw_Module_COLOR.pb"        ; COLOR::    RGBA-Color Modul
XIncludeFile "PbFw_Module_VECTORf.pb"      ; VECf::     single precision Vector Modul

;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule VecCol
  EnableExplicit
  
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
  
  #VecCol_Inv255255 = 1.0 / 255 / 255
  
  Structure TVectorColor  ; Single precicion Vector [16 Bytes / 128 Bit]
    StructureUnion
      col.f[0]            ; virutal Array  v[0]=R, v[1]=G, v[2]=B, v[3]=A
    EndStructureUnion  
    R.f
    G.f
    B.f
    A.f
  EndStructure 
  
  
  Declare.i Mix2Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, Factor1.f=1.0, Factor2.f=0.0)
  Declare.i Mix3Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, *IN3.TVectorColor, Factor1.f=1.0, Factor2.f=0.0, Factor3.f=0.0)

EndDeclareModule


Module VecCol  
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  ;- ======================================================================
  ;- Module Private Functions
  ;- ======================================================================

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
  
  Macro ASM_Mix2Colors(REGA, REGD, REGC)
    ; Mix2Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, Factor1.f=1.0, Factor2.f=0.0)
      
      ; *OUT\Red   = *IN1\Red   * Factor1 + *IN2\Red   * Factor2
      ; *OUT\Green = *IN1\Green * Factor1 + *IN2\Green * Factor2 
      ; *OUT\Blue  = *IN1\Blue  * Factor1 + *IN2\Blue  * Factor2 
      ; *OUT\Alpha = *IN1\Alpha * Factor1 + *IN2\Alpha * Factor2

      ! MOV    REGD, [p.p_IN1]
  		! MOVUPS XMM1, [REGD] 			
  		! MOV    REGD, [p.p_IN2] 			
  		! MOVUPS XMM2, [REGD]  			
  		
 			! MOVSS  XMM0, [p.v_Factor1]
   		! SHUFPS XMM0, XMM0, 000000000b
 			! MULPS  XMM1, XMM0

   		! MOVSS  XMM0, [p.v_Factor2]
   		! SHUFPS XMM0, XMM0, 000000000b
   		! MULPS  XMM2, XMM0
  			
  		! ADDPS  XMM1, XMM2
  			
  		! MOV    REGA, [p.p_OUT]
  		! MOVUPS [REGA], XMM1
  EndMacro

  Macro ASM_Mix3Colors(REGA, REGD, REGC)
    ; Mix3Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, *IN3.TVectorColor, Factor1.f=1.0, Factor2.f=0.0, Factor3.f=0.0)
    
      ; *OUT\Red   = *IN1\Red   * Factor1 + *IN2\Red   * Factor2 + *IN3\Red   * Factor3
      ; *OUT\Green = *IN1\Green * Factor1 + *IN2\Green * Factor2 + *IN3\Green * Factor3
      ; *OUT\Blue  = *IN1\Blue  * Factor1 + *IN2\Blue  * Factor2 + *IN3\Blue  * Factor3 		
      ; *OUT\Alpha = *IN1\Alpha * Factor1 + *IN2\Alpha * Factor2 + *IN3\Alpha * Factor3
      
      ! MOV    REGD, [p.p_IN1]
  		! MOVUPS XMM1, [REGD] 			
  		! MOV    REGD, [p.p_IN2] 			
  		! MOVUPS XMM2, [REGD]  			
   		! MOV    REGD, [p.p_IN3] 			
 			! MOVUPS XMM3, [REGD]
  		
 			! MOVSS  XMM0, [p.v_Factor1]
   		! SHUFPS XMM0, XMM0, 000000000b
 			! MULPS  XMM1, XMM0

   		! MOVSS  XMM0, [p.v_Factor2]
   		! SHUFPS XMM0, XMM0, 000000000b
   		! MULPS  XMM2, XMM0

  		! MOVSS  XMM0, [p.v_Factor3]
  		! SHUFPS XMM0, XMM0, 000000000b 			
  		! MULPS  XMM3, XMM0
  			
  		! ADDPS  XMM1, XMM2
  		! ADDPS  XMM1, XMM3
  			
  		! MOV    REGA, [p.p_OUT]
  		! MOVUPS [REGA], XMM1
  EndMacro
    
  Macro ASM_BlendColor(REGA, REGD, REGC)
    ; BlendColor(*Use.TVectorColor, *Source.TVectorColor)
    
      ; InvAlpha.f  = 1.0 - *Source\Alpha
      ; *Use\Red    = *Use\Red   * InvAlpha + *Source\Red
      ; *Use\Green  = *Use\Green * InvAlpha + *Source\Green
      ; *Use\Blue   = *Use\Blue  * InvAlpha + *Source\Blue
      ; *Use\Alpha  = *Use\Alpha * InvAlpha + *Source\Alpha  		

  	  ! MOV    REGA, [p.p_Use]
  		! MOV    REGD, [p.p_Source]
  		! MOVUPS XMM0, [REGA]
  		! MOVUPS XMM1, [REGD]
  		! MOVUPS XMM2, [pbfw.ll_blendcolor_packedfloat]   
  		! MOVAPS XMM3, XMM1
  		! SHUFPS XMM3, XMM3, 00000000b
  		! SUBPS  XMM2, XMM3
  		! MULPS  XMM0, XMM2
  		! ADDPS  XMM0, XMM1
  		! MOVUPS [REGA], XMM0   
  EndMacro
  
  Procedure.f _MaxOf3(Value1.f, Value2.f, Value3.f=-1.0e100)
  ; ============================================================================
  ; NAME: MaxOf3
  ; DESC: Calculates the Maximum of 3 Values
  ; VAR(Value1) : Value 1
  ; VAR(Value1) : Value 2
  ; VAR(Value1) : Value 3
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

  ;- ======================================================================
  ;- Module Public Functions
  ;- ======================================================================

  Procedure.l VecColToColor(*VecCol.TVectorColor)
    ; ============================================================================
    ; NAME: VecColToColor
    ; DESC: VectorColor to Color (OS RGBA Format)
    ; VAR(*VecCol.TVectorColor) : Vector Color Structure
    ; RET.l: The RGBA Color
    ; ============================================================================
	
  	Protected Factor.f, Alpha.l
  	
    DBG::mac_CheckPointer(*VecCol)    ; Check Pointer Exception
    
    If *VecCol\A
  	  With *VecCol
    		Factor = 255.0 / *VecCol\A
    		Alpha  = \A * 255
    		ProcedureReturn RGBA(\R * Factor, \G * Factor, \B * Factor, Alpha)
  		EndWith
  	Else
  		ProcedureReturn 0
  	EndIf
	
  EndProcedure
  
  ; Color to VectorColor
  Procedure.i ColorToVecCol(*OUT.TVectorColor, InColor.l)
    ; ============================================================================
    ; NAME: ColorToVecCol
    ; DESC: Color (in OS RGBA Format) to VectorColor (4 floats)
    ; VAR(*OUT.TVectorColor) : Vector Color Structure
    ; VAR(InColor.l) : RGBA Color Input
    ; RET.i: *OUT 
    ; ============================================================================
  	    
    Protected Factor.f = Alpha(InColor) * #VecCol_Inv255255
    
    DBG::mac_CheckPointer(*OUT)    ; Check Pointer Exception

  	With *OUT
    	\A = 255 * Factor
    	\R = Red(InColor) * Factor
    	\G = Green(InColor) * Factor
    	\B = Blue(InColor) * Factor
    EndWith
  
  	ProcedureReturn *OUT  	
  EndProcedure

  ; Blendet die Source-Farbe auf die Use-Farbe
  Procedure BlendColor(*Use.TVectorColor, *Source.TVectorColor)
    ; ============================================================================
    ; NAME: BlendColor
    ; DESC: Blend the Source-Color on the Use-Color
    ; VAR(*Use.TVectorColor) : OUT or Use Color
    ; VAR(*Source.TVectorColor) : The Source Color
    ; RET.i: *Use
    ; ============================================================================
    
    DBG::mac_CheckPointer2(*Use, *Source)    ; Check Pointer Exception

  	CompilerSelect PbFw::#PbfW_USE_MMX_Type
  	    
  	  CompilerCase PbFw::#PbfW_SSE_x64          ; 64 Bit Version
  	    
  	    ASM_BlendColor(RAX, RDX, RCX)
 			  ProcedureReturn ; RAX
   			
  		  DataSection
  		    packedfloat:        
  		    Data.f 1.0, 1.0, 1.0, 1.0     ; Packed-Float with all 4 values = 1.0
  			EndDataSection

  		CompilerCase PbFw::#PbfW_SSE_x32          ; 32 Bit Version
  		  
  		  ASM_BlendColor(EAX, EDX, EXC)
  			ProcedureReturn ; EAX
  			
			  DataSection
			    packedfloat:        
			    Data.f 1.0, 1.0, 1.0, 1.0     ; Packed-Float with all 4 values = 1.0
  			EndDataSection
  			
  		; CompilerCase PbFw::#PbfW_SSE_C_Backend    ; for the C-Backend
  			
  			; use deafault Version until we have a C-Backend Optimation
    		
  	  CompilerDefault
  		
    		Protected InvAlpha.f = 1.0 - *Source\Alpha
    		
    		*Use\Red   * InvAlpha + *Source\Red
    		*Use\Green * InvAlpha + *Source\Green
    		*Use\Blue  * InvAlpha + *Source\Blue
    		*Use\Alpha * InvAlpha + *Source\Alpha  		
    		ProcedureReturn *Use
  		
  	CompilerEndSelect
  	
  EndProcedure  
  
  Procedure.i NormalizeColor(*VecCol.TVectorColor)
    ; ============================================================================
    ; NAME: NormalizeColor
    ; DESC: Normlaize the Color
    ; VAR((*VecCol.TVectorColor) : The VectorColor
    ; RET.i: *VecCol
    ; ============================================================================
 	
    DBG::mac_CheckPointer(*VecCol)    ; Check Pointer Exception
    
    Protected Max.f = _MaxOf3(*VecCol\R, *VecCol\G, *VecCol\B)
  	
  	With *VecCol
    	If Max > 1
    		\R / Max
    		\G / Max
    		\B / Max
    	EndIf
  
    	\R * \A
    	\G * \A
    	\B * \A
    EndWith
  
  	ProcedureReturn *VecCol  	
  EndProcedure
              
  Procedure.i Mix2Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, Factor1.f=1.0, Factor2.f=0.0)
    
    DBG::mac_CheckPointer3(*OUT, *IN1, *IN2)    ; Check Pointer Exception

  	CompilerSelect PbFw::#PbfW_USE_MMX_Type
  		
  		CompilerCase PbFw::#PbfW_SSE_x64          ; 64 Bit-Version
   		  ASM_Mix2Colors(RAX, RDX, RCX)
  			ProcedureReturn   ;RAX
  			
  		CompilerCase PbFw::#PbfW_SSE_x32          ; 32 Bit Version
   		  ASM_Mix2Colors(EAX, EDX, ECX)  		  
		 		ProcedureReturn   ; EAX

  		;CompilerCase PbFw::#PbfW_SSE_C_Backend    ; for the C-Backend
		 		
		 		; use deafault Version until we have a C-Backend Optimation
 		
   		
  	  CompilerDefault                           ; Classic Version
  		
     		*OUT\Red   = *IN1\Red   * Factor1 + *IN2\Red   * Factor2
    		*OUT\Green = *IN1\Green * Factor1 + *IN2\Green * Factor2
    		*OUT\Blue  = *IN1\Blue  * Factor1 + *IN2\Blue  * Factor2
    		*OUT\Alpha = *IN1\Alpha * Factor1 + *IN2\Alpha * Factor2 
   		  ProcedureReturn *OUT
  		
  	CompilerEndSelect
  	
  EndProcedure

  
  Procedure.i Mix3Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, *IN3.TVectorColor, Factor1.f=1.0, Factor2.f=0.0, Factor3.f=0.0)
  	
    DBG::mac_CheckPointer4(*OUT, *IN1, *IN2, *IN3)    ; Check Pointer Exception

    CompilerSelect PbFw::#PbfW_USE_MMX_Type
  		
  		CompilerCase PbFw::#PbfW_SSE_x64          ; 64 Bit-Version
   		  ASM_Mix3Colors(RAX, RDX, RCX)
  			ProcedureReturn   ;RAX
  			
  		CompilerCase PbFw::#PbfW_SSE_x32          ; 32 Bit Version
   		  ASM_Mix3Colors(EAX, EDX, ECX)  		  
		 		ProcedureReturn   ; EAX

  		;CompilerCase PbFw::#PbfW_SSE_C_Backend    ; for the C-Backend
		 		
		 		; use deafault Version until we have a C-Backend Optimation
 		   		
  	  CompilerDefault                           ; Classic Version
  		
    		*OUT\Red   = *IN1\Red   * Factor1 + *IN2\Red   * Factor2 + *IN3\Red   * Factor3
    		*OUT\Green = *IN1\Green * Factor1 + *IN2\Green * Factor2 + *IN3\Green * Factor3
    		*OUT\Blue  = *IN1\Blue  * Factor1 + *IN2\Blue  * Factor2 + *IN3\Blue  * Factor3
    		*OUT\Alpha = *IN1\Alpha * Factor1 + *IN2\Alpha * Factor2 + *IN3\Alpha * Factor3  		
  		  ProcedureReturn *OUT
  		
  	CompilerEndSelect
  	
  EndProcedure
  
  ; CompilerSelect PbFw::#PbfW_USE_MMX_Type
  ;   
  ;   CompilerCase PbFw::#PbfW_SSE_x64          ; 64 Bit-Version
  ;    
  ;   CompilerCase PbFw::#PbfW_SSE_x32          ; 32 Bit Version
  ;   
  ;   CompilerCase PbFw::#PbfW_SSE_C_Backend    ; for the C-Backend
  ;    
  ;   CompilerDefault                           ; Classic Version
  ; 
  ; CompilerEndSelect       

   
 
  
EndModule

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 274
; FirstLine = 240
; Folding = ---
; Optimizer
; CPU = 5