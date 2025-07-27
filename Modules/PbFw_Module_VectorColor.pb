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
; VERSION  :  0.1   Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
; 2024/09/08 S.Maag : added new Module local configurations
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_PX.pb"          ; PX::      PureBasic extention Module
XIncludeFile "PbFw_Module_Debug.pb"       ; DBG::     Debug Module
XIncludeFile "PbFw_Module_COLOR.pb"       ; COLOR::   RGBA-Color Module
XIncludeFile "PbFw_Module_VECTORf.pb"     ; VECf::    single precision Vector Module

;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule VecCol
  
  EnableExplicit
    
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
  
  #VecCol_Factor = 255
  
  #VecCol_R = 0
  #VecCol_G = 1
  #VecCol_B = 2
  #VecCol_A = 3
  
  ; it is same Structure as TVector, so it is possible to pass it to functions of the VECTORf Module
  Structure TVectorColor  ; Single precicion Vector [16 Bytes / 128 Bit]
    col.f[0]              ; virutal Array  v[0]=R, v[1]=G, v[2]=B, v[3]=A  
    R.f
    G.f
    B.f
    A.f
  EndStructure 
  
  Declare.i Mix2Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, Factor1.f=1.0, Factor2.f=0.0)
  Declare.i Mix3Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, *IN3.TVectorColor, Factor1.f=1.0, Factor2.f=0.0, Factor3.f=0.0)
  
  Declare.i Get_HSVadjustRGB_Matrix (*Matrix.VECf::TMatrix, h.f, s.f, v.f)
  Declare.l HSVadjustRGB(RGB.l, *Matrix.VECf::TMatrix)
  
EndDeclareModule


Module VecCol  
  
  EnableExplicit
  
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
    
    If *VecCol
  	  With *VecCol
      		ProcedureReturn RGBA(\R * #VecCol_Factor, \G * #VecCol_Factor, \B * #VecCol_Factor, \A * #VecCol_Factor)
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
  	    
    
    DBG::mac_CheckPointer(*OUT)    ; Check Pointer Exception

  	With *OUT
    	\A = Alpha(InColor) / #VecCol_Factor
    	\R = Red(InColor) / #VecCol_Factor
    	\G = Green(InColor) / #VecCol_Factor
    	\B = Blue(InColor) / #VecCol_Factor
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

  	CompilerSelect #PbFwCfg_Module_Compile
  	    
  	  CompilerCase #PbFwCfg_Module_Compile_ASM64          ; 64 Bit Version
  	    
  	    ASM_BlendColor(RAX, RDX, RCX)
 			  ProcedureReturn ; RAX
   			
  		  DataSection
  		    packedfloat:        
  		    Data.f 1.0, 1.0, 1.0, 1.0     ; Packed-Float with all 4 values = 1.0
  			EndDataSection

  		CompilerCase #PbFwCfg_Module_Compile_ASM32          ; 32 Bit Version
  		  
  		  ASM_BlendColor(EAX, EDX, EXC)
  			ProcedureReturn ; EAX
  			
			  DataSection
			    packedfloat:        
			    Data.f 1.0, 1.0, 1.0, 1.0     ; Packed-Float with all 4 values = 1.0
  			EndDataSection
  			
  	  ; CompilerCase #PbFwCfg_Module_Compile_C    ; for the C-Backend
  			
  			; use deafault Version until we have a C-Backend Optimation
    		
  	  CompilerDefault
  		
    		Protected InvAlpha.f = 1.0 - *Source\A
    		
    		*Use\R * InvAlpha + *Source\R
    		*Use\G * InvAlpha + *Source\G
    		*Use\B * InvAlpha + *Source\B
    		*Use\A * InvAlpha + *Source\A  		
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

  	CompilerSelect #PbFwCfg_Module_Compile
  		
  		CompilerCase #PbFwCfg_Module_Compile_ASM64          ; 64 Bit-Version
   		  ASM_Mix2Colors(RAX, RDX, RCX)
  			ProcedureReturn   ;RAX
  			
  		CompilerCase #PbFwCfg_Module_Compile_ASM32          ; 32 Bit Version
   		  ASM_Mix2Colors(EAX, EDX, ECX)  		  
		 		ProcedureReturn   ; EAX

  		;CompilerCase PbFw::#PbfW_SSE_C_Backend    ; for the C-Backend
		 		
		 		; use deafault Version until we have a C-Backend Optimation
 		
   		
  	  CompilerDefault                           ; Classic Version
  		
     		*OUT\R = *IN1\R * Factor1 + *IN2\R * Factor2
    		*OUT\G = *IN1\G * Factor1 + *IN2\G * Factor2
    		*OUT\B = *IN1\B * Factor1 + *IN2\B * Factor2
    		*OUT\A = *IN1\A * Factor1 + *IN2\A * Factor2 
   		  ProcedureReturn *OUT
  		
  	CompilerEndSelect
  	
  EndProcedure

  
  Procedure.i Mix3Colors(*OUT.TVectorColor, *IN1.TVectorColor, *IN2.TVectorColor, *IN3.TVectorColor, Factor1.f=1.0, Factor2.f=0.0, Factor3.f=0.0)
  	
    DBG::mac_CheckPointer4(*OUT, *IN1, *IN2, *IN3)    ; Check Pointer Exception

    CompilerSelect #PbFwCfg_Module_Compile
  		
  		CompilerCase #PbFwCfg_Module_Compile_ASM64          ; 64 Bit-Version
   		  ASM_Mix3Colors(RAX, RDX, RCX)
  			ProcedureReturn   ;RAX
  			
  		CompilerCase #PbFwCfg_Module_Compile_ASM32          ; 32 Bit Version
   		  ASM_Mix3Colors(EAX, EDX, ECX)  		  
		 		ProcedureReturn   ; EAX

  		;CompilerCase #PbFwCfg_Module_Compile_C    ; for the C-Backend
		 		
		 		; use deafault Version until we have a C-Backend Optimation
 		   		
  	  CompilerDefault                           ; Classic Version
  		
    		*OUT\R = *IN1\R * Factor1 + *IN2\R * Factor2 + *IN3\R * Factor3
    		*OUT\G = *IN1\G * Factor1 + *IN2\G * Factor2 + *IN3\G * Factor3
    		*OUT\B = *IN1\B * Factor1 + *IN2\B * Factor2 + *IN3\B * Factor3
    		*OUT\A = *IN1\A * Factor1 + *IN2\A * Factor2 + *IN3\A * Factor3  		
  		  ProcedureReturn *OUT
  		
  	CompilerEndSelect
  	
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Color Space adjusting
  ;- ----------------------------------------------------------------------

  Procedure.i Get_HSVadjustRGB_Matrix (*Matrix.VECf::TMatrix, h.f, s.f, v.f)
  ; ======================================================================
  ; NAME : Get_HSVadjustRGB_Matrix
  ; DESC : Calculates the HSV adjust Matrix for RGB Colors
  ; DESC : It will keep the original Alpha
  ; VAR(*Matrix.TMatrix) : Pointer to Return Matrix
  ; VAR(s.f) : saturation multiplier (scalar)
  ; VAR(v.f) : value multiplier (scalar)
  ; RET.i *Matrix
  ; ======================================================================
    
    Protected.f vsu, vsw
    
    DBG::mac_CheckPointer(*Matrix)    ; Check Pointer Exception
    
    vsu = v * s * Cos(Radian(h))
    vsw = v * s * Sin(Radian(h))
    
    ; https://beesbuzz.biz/code/16-hsv-color-transforms

    ; The Matriex for direct HSV adjsuting a RGB! [RGB_2_HSV ] * [Adjusting_Matrix] * [HSV_2_RGB] 
    ; generally we need a 3:3 Matrix, but for SSE-Extention we have to use a 4:4 Matirx
    ;( V  0      0  )
    ;( 0  VSU  -VSW )
    ;( 0  VSW  -VSU )

    With *Matrix
      \m11 = 0.299*v + 0.701*vsu + 0.168*vsw
      \m12 = 0.587*v - 0.587*vsu + 0.330*vsw
      \m13 = 0.114*v - 0.114*vsu - 0.497*vsw
      ;\m14 = 0
      
      \m21 = 0.299*v - 0.299*vsu - 0.328*vsw
      \m22 = 0.587*v + 0.413*vsu + 0.035*vsw
      \m23 = 0.114*v - 0.114*vsu + 0.292*vsw
      ;\m24 = 0
      
      \m31 = 0.299*v - 0.300*vsu + 1.250*vsw
      \m32 = 0.587*v - 0.588*vsu - 1.050*vsw
      \m33 = 0.114*v + 0.886*vsu - 0.203*vsw
      \m34 = 0
      
      ;\m41 = 0
      ;\m42 = 0
      ;\m43 = 0
      ;\m44 = 0
    EndWith
    
    ProcedureReturn *Matrix   
  EndProcedure

  Procedure.l HSVadjustRGB(RGB.l, *Matrix.VECf::TMatrix)
  ; ======================================================================
  ; NAME : HSVadjustRGB
  ; DESC : Do a HSV-Color Space adjust of a RGB color with 24/32 Bit
  ; DESC : It will keep the original Alpha
  ; VAR(RGB.l) : 24/32 Bit RGB Color
  ; VAR(*Matrix.TMatrix) : Matrix Structure from VECf Module
  ; RET.i HSV adjusted RGB Color
  ; ======================================================================
    
    Protected IN.TVectorColor    ; the RGB color as IN-Vector for Vector_X_Matrix
    Protected OUT.TVectorColor   ; the returuned HSV adjusted Vector color
    
    DBG::mac_CheckPointer(*Matrix)    ; Check Pointer Exception
     
    With IN  
      \R = Red(RGB)
      \G = Green(RGB)
      \B = Blue(RGB)
     EndWith
        
    VECf::Vector_X_Matrix(Out, IN, *Matrix)
    
    ; TODO : maybe move the conversion from Float to INT and the necessary saturation into ASM Code 
    
    With OUT
      If \R > 255 
        \R = 255
      ElseIf \R < 0 
        \R = 0
      EndIf
      
      If \G > 255 
        \G = 255
      ElseIf \G < 0 
        \G = 0
      EndIf
      
      If \B > 255 
        \B = 255
      ElseIf \B < 0 
        \B = 0
      EndIf
    EndWith
  
    ProcedureReturn RGBA(Int(OUT\R), Int(OUT\G), Int(OUT\B), Alpha(RGB))
  EndProcedure

  ; CompilerSelect #PbFwCfg_Module_Compile
  ;   
  ;   CompilerCase #PbFwCfg_Module_Compile_ASM64        ; 64 Bit-Version
  ;    
  ;   CompilerCase #PbFwCfg_Module_Compile_ASM32        ; 32 Bit Version
  ;   
  ;   CompilerCase #PbFwCfg_Module_Compile_C            ; for the C-Backend
  ;    
  ;   CompilerDefault                                   ; Classic Version
  ; 
  ; CompilerEndSelect       

   
 
  
EndModule

; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 300
; FirstLine = 297
; Folding = ----
; Optimizer
; CPU = 5