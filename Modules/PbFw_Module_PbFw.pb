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
   
  Macro HashTag
  #
  EndMacro
  
  ; define Constant if Not defined yet
  Macro CONST(ConstName, Value)
    CompilerIf Not Defined(ConstName, #PB_Constant)
      PbFw::HashTag#ConstName = Value
    CompilerEndIf
  EndMacro
   
  ;- ----------------------------------------------------------------------
  ;- Library configuration Constants used for compiling
  ;- ----------------------------------------------------------------------
   
  ; The idea is, to set this in future with an PB IDE Tool
  ; then the config Constants are set in a Project config file
  CONST(PbFwCfg_Global_CheckPointerException, #True)  
  CONST(PbFwCfg_Global_ASM_Enable,            #True)     ; Enables special ASM Version, if #False -> CompileClassicMode 
  
  ;  ----------------------------------------------------------------------
    
   ; use this Macro in Moduls where different Code is used for the same Funtion  
  Macro mac_CompilerModeSettting
 ; ************************************************************************
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
        ;  To force Classic Code Compilation
        #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
    CompilerEndIf 
  ; ************************************************************************
  EndMacro
    
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
    
     ProcedureReturn ret    
  EndProcedure
    
  ; Debug Get_MMX_STATE_TXT()

EndModule

DisableExplicit


; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 52
; FirstLine = 15
; Folding = --
; Optimizer
; CPU = 5