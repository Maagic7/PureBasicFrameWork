; ===========================================================================
;  FILE: PbFw_Module_TreeOhase.pb
;  NAME: Module Tree Phase Current System 
;  DESC: Calculations for 3-Phase Current in electrical systems
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/08/08
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
; 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
; XIncludeFile ""

DeclareModule TreePhase
   
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------

  Declare.d GetPower(U.d, I.d, CosPhi.d=1.0)
  Declare.d GetCurrentFromPower(P.d, U.d, CosPhi.d=1.0)
  Declare.d GetNominalRpm(f_Hz.d=50)
  Declare.d GetPhaseToNeutralVoltage(U_Ph.d)
  Declare.d GetPhaseToPhaseVoltage(U_Ph_N.d)
  Declare.d GetPeakVoltage(U_Grid.d)
  
EndDeclareModule


Module TreePhase
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;#SQR3 = 1.7320508075688772   ; SQR(3)

  Procedure.d GetPower(U.d, I.d, CosPhi.d=1.0)
  ; ============================================================================
  ; NAME: GetPower
  ; DESC: P = U * I * SQR(3) * CosPhi
  ; VAR(U.d) : Voltage [V]
  ; VAR(I.d) : Current [A]
  ; VAR(CosPhi.d): The Cosine Phi
  ; RET.d : Power in 3 Phase-System
  ; ============================================================================
    
    ProcedureReturn U * I * Sqr(3) * CosPhi
  EndProcedure
  
  Procedure.d GetCurrentFromPower(P.d, U.d, CosPhi.d=1.0)
  ; ============================================================================
  ; NAME: GetCurrentFromPower
  ; DESC: I = P / (U * SQR(3) * CosPhi)
  ; VAR(P.d) : Power [W] [VA]
  ; VAR(U.d) : Voltage [V]
  ; VAR(CosPhi.d): The Cosine Phi
  ; RET.d : Current [A]
  ; ============================================================================   
    
    ProcedureReturn  P / (U * Sqr(3) * CosPhi)
  EndProcedure
  
  Procedure.d GetNominalRpm(f_Hz.d=50)
  ; ============================================================================
  ; NAME: GetNominalRpm
  ; DESC: Get the nominal rotation speed in a 3-Phase-System
  ; VAR(f_Hz.d) : Frequency [Hz] [1/s]
  ; RET.d : Nominal rotation speed [rpm], [1/min] (50Hz=3000; 60Hz=3600)
  ; ============================================================================  
    ProcedureReturn f_Hz * 60
  EndProcedure
  
  Procedure.d GetPhaseToNeutralVoltage(U_Ph.d)
  ; ============================================================================
  ; NAME: GetPhaseToNeutralVoltage
  ; DESC: Get the Phase to Neutral Voltage in a 3-Phase-System (Star connection)
  ; VAR(U_Ph.d) : Phase to Phase Voltage
  ; RET.d : Phase to Neutral Voltage
  ; ============================================================================
    ProcedureReturn U_Ph/Sqr(3)  
  EndProcedure
  
  Procedure.d GetPhaseToPhaseVoltage(U_Ph_N.d)
  ; ============================================================================
  ; NAME: GetPhaseToPhaseVoltage
  ; DESC: Get the Phase to Phase Voltage in a 3-Phase-System (Star connection)
  ; VAR(U_Ph_N.d) : Phase to Neutral Voltage
  ; RET.d : Phase to Phase Voltage
  ; ============================================================================
    ProcedureReturn U_Ph_N * Sqr(3)  
  EndProcedure
  
  Procedure.d GetPeakVoltage(U_Grid.d)
  ; ============================================================================
  ; NAME: GetPeakVoltage
  ; DESC: Get the sine peak voltage from the nominal grid voltage
  ; VAR(U_Grid.d) : The nominal grid voltage
  ; RET.d : The sine peak voltage
  ; ============================================================================
    ProcedureReturn U_Grid * Sqr(2)  
  EndProcedure
  
EndModule

 ;- ----------------------------------------------------------------------
 ;-  M O D U L E   T E S T   C O D E
 ;  ---------------------------------------------------------------------- 

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  UseModule TreePhase
  
  DisableExplicit
CompilerEndIf




; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 111
; FirstLine = 31
; Folding = --
; Optimizer
; CPU = 5