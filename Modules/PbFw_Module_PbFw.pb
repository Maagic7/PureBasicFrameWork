; ===========================================================================
;  FILE: PbFw_Module_PbFw.pb
;  NAME: Module PbFw [PbFw::]
;  DESC: FrameWork Control Module
;  DESC: Set the basic configurations for compiling with different
;  DESC: options here.
;  DESC: The idea is, to set the configuration Flags in the future
;  DESC: with a Purebasic IDE Tool Plugin with a GUI
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/02/18
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ChangeLog: 
;{
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile ""

DeclareModule PbFw
   EnableExplicit

  ;- ----------------------------------------------------------------------
  ;- Library configuration Constants used for compiling
  ;  ----------------------------------------------------------------------
   
  ; The idea is, to set this in future with an PB IDE Tool
  #PbFw_cfg_Use_MMX = #True     ; Configuration FLAG Use MMX 
  #PbFw_cfg_Use_SSE = #True     ; Configuration FLAG Use SSE  
  #PbFw_cfg_Use_AVX = #True     ; Configuration FLAG Use AVX
  ;  ----------------------------------------------------------------------
  
  ; Use this Template to select differnt MMX-Use
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

  Enumeration USE_MMX
    #PbFw_MMX_OFF        ; MMX Extention not present
    #PbFw_MMX_x32
    #PbFw_MMX_X64
    #PbFw_SSE_x32        ; 32-Bit Assembler SSE Code
    #PbFw_SSE_x64        ; 64-Bot Assembler SSE Code
    #PbFw_SSE_C_Backend  ; For Future use in the C-Backend (maybe it will be possible To force SSE optimation with the C intrinsic Macros)
  EndEnumeration  

  ; Constants to compile Application with features! 
  ; DO Not modify For individual configuration! The user have to use the #PbFw_cfg_ Flags for configuration
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86 Or #PB_Compiler_Processor = #PB_Processor_x64 And  #PB_Compiler_32Bit  
    ; 32 Bit Application on AMD/INTEL x86, x64
    #PbFw_APPx32_MMX = #PbFw_cfg_Use_MMX
    #PbFw_APPx32_SSE = #PbFw_cfg_Use_SSE
    #PbFw_APPx32_AVX = #PbFw_cfg_Use_AVX
    
    #PbFw_APPx64_MMX = #False
    #PbFw_APPx64_SSE = #False
    #PbFw_APPx64_AVX = #False
    
  CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64 And  #PB_Compiler_64Bit 
    ; 64 Bit Application on AMD/INTEL x64
    #PbFw_APPx32_MMX = #False
    #PbFw_APPx32_SSE = #False
    #PbFw_APPx32_AVX = #False
    
    #PbFw_APPx64_MMX = #PbFw_cfg_Use_MMX
    #PbFw_APPx64_SSE = #PbFw_cfg_Use_SSE
    #PbFw_APPx64_AVX = #PbFw_cfg_Use_AVX
   
  CompilerElse
    #PbFw_APPx32_MMX = #False
    #PbFw_APPx32_SSE = #False
    #PbFw_APPx32_AVX = #False
    
    #PbFw_APPx64_MMX = #False 
    #PbFw_APPx64_SSE = #False 
    #PbFw_APPx64_AVX = #False
  CompilerEndIf
  
   Enumeration 
    #PbFw_VEC_MMX_OFF        ; No SSE present
    #PbFw_VEC_MMX_x32
    #PbFw_VEC_MMX_X64
    #PbFw_VEC_SSE_x32        ; 32-Bit Assembler SSE Code
    #PbFw_VEC_SSE_x64        ; 64-Bot Assembler SSE Code
    #PbFw_VEC_SSE_C_Backend  ; For Future use in the C-Backend (maybe it will be possible To force SSE optimation with the C intrinsic Macros)
  EndEnumeration  
  
   
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
    
    ; **********  32 BIT  **********
    CompilerIf PbFw::#PbFw_APPx32_SSE
      #PbFw_USE_MMX_Type = #PbFw_SSE_x32             ; x32 SSE
      
    CompilerElseIf PbFw::#PbFw_APPx32_MMX
      #PbFw_USE_MMX_Type = #PbFw_MMX_x32             ; X32 MMX
      
    ; **********  64 BIT  **********
    CompilerElseIf PbFw::#PbFw_APPx64_SSE
       #PbFw_USE_MMX_Type = #PbFw_SSE_x64            ; X64 SSE
       
     CompilerElseIf PbFw::#PbFw_APPx32_MMX
      #PbFw_USE_MMX_Type = #PbFw_MMX_X64             ; x64 SSE
      
    CompilerElse
       #PbFw_USE_MMX_Type = #PbFw_MMX_OFF            ; MMX OFF
    CompilerEndIf
      
  CompilerElseIf    #PB_Compiler_Backend = #PB_Backend_C
    
    If PbFw::#PbFw_APPx32_SSE | PbFw::#PbFw_APPx32_MMX | PbFw::#PbFw_APPx64_SSE | PbFw::#PbFw_APPx64_MMX
      
      #PbFw_USE_MMX_Type = #PbFw_SSE_C_Backend       ; Activate C-Backend-MMX optimation 
    Else
       #PbFw_USE_MMX_Type = #PbFw_MMX_OFF            ; MMX OFF
    EndIf
    
  CompilerElse
    #PbFw_USE_MMX_Type = #PbFw_MMX_OFF
  CompilerEndIf 
  
  Structure TPbFw_cfgUseMMX
    Use_MMX.i     ; Configuration FLAG Use MMX 
    Use_SSE.i     ; Configuration FLAG Use SSE  
    Use_AVX.i     ; Configuration FLAG Use AVX
  EndStructure  
  
  Structure TPbFw_Config
    MMX.TPbFw_cfgUseMMX   ; MMX Use Flags  
  EndStructure
    
  Declare.s Get_MMX_STATE_TXT()
  Declare.i ListModule(ModuleName.s)

  
EndDeclareModule

Module PbFw
  
  Global NewList ModuleList.s()     ; List to hold all included Modules (for statistics)

  EnableExplicit
  ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  Procedure GetPbFwSettings()
    
  EndProcedure
  
   
  Procedure.i ListModule(ModuleName.s)
  ; ============================================================================
  ; NAME: ListModule
  ; DESC: Lists the Module in the PbFW internal List 
  ; DESC: containing all ModuleNames which are included in the Program.
  ; DESC: Call in each mdoule 1 Time: PbFw::ListModule(#PB_Compiler_Module)  
  ; DESC: This ist just for statistics. Show this information in the 
  ; DESC: Programs help section!
  ; VAR(ModuleName.s) : ModuleName.s
  ; RET.i : ListID
  ; ============================================================================
    
    Protected ret.i   
    ret = AddElement(ModuleList())
    ModuleList() = ModuleName
    ; Debug "Module listed : " + ModuleName
    
    ProcedureReturn ret
  EndProcedure
    
  Procedure.s Get_MMX_STATE_TXT()
    Protected ret.s
    
    Select PbFw::#PbFw_USE_MMX_Type
        
      Case PbFw::#PbfW_MMX_Off
        ret = "MMX_OFF"
        
      Case PbFw::#PbfW_SSE_x32
        ret = "MMX_SSE_x32_ASM"
        
      Case PbFw::#PbfW_SSE_x64
         ret = "MMX_SSE_x64_ASM"
       
      Case PbFw::#PbfW_SSE_C_Backend
         ret = "MMX_SSE_C_BackEnd"
        
     EndSelect
     ProcedureReturn ret    
  EndProcedure
  
  ; Debug Get_MMX_STATE_TXT()

EndModule

DisableExplicit


; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 23
; Folding = --
; Optimizer
; CPU = 5