; ===========================================================================
;  FILE: PbFw_Module_ElectricalTreePhase.pb
;  NAME: Module Tree Phase Current System E3P::
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

; XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
; XIncludeFile ""

DeclareModule E3P
  EnableExplicit 

  ; --- Public Function Declarations ---
  Declare.d GetActivePower(U.d, I.d, CosPhi.d = 1.0)
  Declare.d GetApparentPower(U.d, I.d)
  Declare.d GetReactivePower(U.d, I.d, CosPhi.d = 1.0)
  Declare.d GetCurrentFromActivePower(P.d, U.d, CosPhi.d = 1.0)
  Declare.d GetSynchronousRpm(f_Hz.d = 50.0, PolePairs.i = 1)
  Declare.d GetPhaseToNeutralVoltage(U_PhaseToPhase.d)
  Declare.d GetPhaseToPhaseVoltage(U_PhaseToNeutral.d)
  Declare.d GetPeakVoltage(U_RMS.d)
EndDeclareModule

Module E3P
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)
  
  ; ============================================================================
  ; NAME: GetActivePower
  ; DESC: Calculates the active (true) power (P) in a balanced 3-phase system.
  ; VAR(U.d)      : Line-to-Line Voltage in Volts [V] (e.g., 400V)
  ; VAR(I.d)      : Line Current in Amperes [A]
  ; VAR(CosPhi.d) : Power factor (dimensionless, usually 0.8 to 1.0)
  ; RET.d         : Active Power in Watts [W]
  ; ============================================================================
  Procedure.d GetActivePower(U.d, I.d, CosPhi.d = 1.0)
    ProcedureReturn U * I * Sqr(3.0) * CosPhi
  EndProcedure

  ; ============================================================================
  ; NAME: GetApparentPower
  ; DESC: Calculates the total apparent power (S) in a balanced 3-phase system.
  ; VAR(U.d) : Line-to-Line Voltage in Volts [V]
  ; VAR(I.d) : Line Current in Amperes [A]
  ; RET.d    : Apparent Power in Volt-Amperes [VA]
  ; ============================================================================
  Procedure.d GetApparentPower(U.d, I.d)
    ProcedureReturn U * I * Sqr(3.0)
  EndProcedure

  ; ============================================================================
  ; NAME: GetReactivePower
  ; DESC: Calculates the displaced reactive power (Q) in a balanced 3-phase system.
  ; VAR(U.d)      : Line-to-Line Voltage in Volts [V]
  ; VAR(I.d)      : Line Current in Amperes [A]
  ; VAR(CosPhi.d) : Power factor used to determine SinPhi internally
  ; RET.d         : Reactive Power in Volt-Amperes Reactive [var]
  ; ============================================================================
  Procedure.d GetReactivePower(U.d, I.d, CosPhi.d = 1.0)
    Protected SinPhi.d = Sqr(1.0 - (CosPhi * CosPhi)) ; Trigonometric identity
    ProcedureReturn U * I * Sqr(3.0) * SinPhi
  EndProcedure
  
  ; ============================================================================
  ; NAME: GetCurrentFromActivePower
  ; DESC: Re-calculates the line current required for a given active power output.
  ; VAR(P.d)      : Active Power in Watts [W]
  ; VAR(U.d)      : Line-to-Line Voltage in Volts [V]
  ; VAR(CosPhi.d) : Power factor
  ; RET.d         : Line Current in Amperes [A]
  ; ============================================================================   
  Procedure.d GetCurrentFromActivePower(P.d, U.d, CosPhi.d = 1.0)
    Protected Denominator.d = U * Sqr(3.0) * CosPhi
    If Denominator = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn P / Denominator
  EndProcedure
  
  ; ============================================================================
  ; NAME: GetSynchronousRpm
  ; DESC: Calculates the synchronous magnetic stator speed of an AC motor.
  ; VAR(f_Hz.d)    : Grid frequency in Hertz [Hz] (Default: 50Hz)
  ; VAR(PolePairs.i): Number of pole pairs (1=3000rpm, 2=1500rpm, 4=750rpm at 50Hz)
  ; RET.d          : Synchronous rotation speed in revolutions per minute [rpm]
  ; ============================================================================  
  Procedure.d GetSynchronousRpm(f_Hz.d = 50.0, PolePairs.i = 1)
    If PolePairs <= 0 : ProcedureReturn 0.0 : EndIf
    ; ns = (f * 60) / p
    ProcedureReturn (f_Hz * 60.0) / PolePairs
  EndProcedure
  
  ; ============================================================================
  ; NAME: GetPhaseToNeutralVoltage
  ; DESC: Derives the Phase-to-Neutral (star / U0) voltage from the Phase-to-Phase level.
  ; VAR(U_PhaseToPhase.d) : The line-to-line voltage (e.g., 400V)
  ; RET.d                 : The line-to-neutral voltage (e.g., 230V)
  ; ============================================================================
  Procedure.d GetPhaseToNeutralVoltage(U_PhaseToPhase.d)
    ProcedureReturn U_PhaseToPhase / Sqr(3.0)  
  EndProcedure
  
  ; ============================================================================
  ; NAME: GetPhaseToPhaseVoltage
  ; DESC: Multiplies the single phase-to-neutral voltage up to the phase-to-phase system level.
  ; VAR(U_PhaseToNeutral.d) : The line-to-neutral voltage (e.g., 230V)
  ; RET.d                   : The line-to-line voltage (e.g., 400V)
  ; ============================================================================
  Procedure.d GetPhaseToPhaseVoltage(U_PhaseToNeutral.d)
    ProcedureReturn U_PhaseToNeutral * Sqr(3.0)  
  EndProcedure
  
  ; ============================================================================
  ; NAME: GetPeakVoltage
  ; DESC: Computes the peak amplitude voltage (Û) from the effective RMS value.
  ; VAR(U_RMS.d) : The effective root-mean-square grid voltage
  ; RET.d        : The absolute peak amplitude of the sine wave
  ; ============================================================================
  Procedure.d GetPeakVoltage(U_RMS.d)
    ProcedureReturn U_RMS * Sqr(2.0)  
  EndProcedure
  
    ; ============================================================================
  ; NAME: GetTotalUnbalancedPower
  ; DESC: Calculates the total active power in an unbalanced 3-phase system 
  ;       by summing up the individual phase-to-neutral powers.
  ; VAR(P1.d) : Active power on Phase 1 in Watts [W]
  ; VAR(P2.d) : Active power on Phase 2 in Watts [W]
  ; VAR(P3.d) : Active power on Phase 3 in Watts [W]
  ; RET.d     : The total active power of the system in Watts [W]
  ; ============================================================================
  Procedure.d GetTotalUnbalancedPower(P1.d, P2.d, P3.d)
    ProcedureReturn P1 + P2 + P3
  EndProcedure

  ; ============================================================================
  ; NAME: GetNeutralCurrent
  ; DESC: Calculates the resulting current flowing through the neutral conductor (IN) 
  ;       caused by unbalanced phase currents (Schieflast) in a star connection.
  ; VAR(IL1.d) : Line current on Phase 1 in Amperes [A]
  ; VAR(IL2.d) : Line current on Phase 2 in Amperes [A]
  ; VAR(IL3.d) : Line current on Phase 3 in Amperes [A]
  ; RET.d      : The neutral conductor current in Amperes [A]
  ; ============================================================================
  Procedure.d GetNeutralCurrent(IL1.d, IL2.d, IL3.d)
    Protected Radicand.d = (IL1 * IL1) + (IL2 * IL2) + (IL3 * IL3) - (IL1 * IL2) - (IL2 * IL3) - (IL3 * IL1)
    If Radicand < 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn Sqr(Radicand)
  EndProcedure

  ; ============================================================================
  ; NAME: GetTotalPowerFactor
  ; DESC: Calculates the true total power factor (Lambda) of the grid.
  ; VAR(ActivePowerW.d)   : The measured true active power in Watts [W]
  ; VAR(ApparentPowerVA.d): The measured total apparent power in Volt-Amperes [VA]
  ; RET.d                 : The true power factor Lambda (dimensionless, 0.0 to 1.0)
  ; ============================================================================
  Procedure.d GetTotalPowerFactor(ActivePowerW.d, ApparentPowerVA.d)
    If ApparentPowerVA = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn Abs(ActivePowerW / ApparentPowerVA)
  EndProcedure

  ; ============================================================================
  ; NAME: GetCompensationRequiredVar
  ; DESC: Calculates the required reactive power capacity (Qc) for a capacitor bank 
  ;       to improve the grid power factor from CosPhi_Current to CosPhi_Target.
  ; VAR(ActivePowerW.d)    : The active power load of the plant in Watts [W]
  ; VAR(CosPhi_Current.d)  : The current uncompensated power factor (e.g., 0.70)
  ; VAR(CosPhi_Target.d)   : The desired target power factor (e.g., 0.95)
  ; RET.d                  : The required compensation power in Volt-Amperes Reactive [var]
  ; ============================================================================
  Procedure.d GetCompensationRequiredVar(ActivePowerW.d, CosPhi_Current.d, CosPhi_Target.d)
    If CosPhi_Current <= 0.0 Or CosPhi_Current > 1.0 Or CosPhi_Target <= 0.0 Or CosPhi_Target > 1.0
      ProcedureReturn 0.0
    EndIf
    
    ; Calculate tan(phi) from cos(phi) using trigonometric identities
    Protected TanPhi_Current.d = Sqr(1.0 - (CosPhi_Current * CosPhi_Current)) / CosPhi_Current
    Protected TanPhi_Target.d  = Sqr(1.0 - (CosPhi_Target * CosPhi_Target)) / CosPhi_Target
    
    ; Qc = P * (tan(phi1) - tan(phi2))
    ProcedureReturn ActivePowerW * (TanPhi_Current - TanPhi_Target)
  EndProcedure

EndModule

;- --- Verification Unit Test ---
CompilerIf #PB_Compiler_IsMainFile
  OpenConsole("E3P Module - Advanced Drehstrom Check")
  
  ; Test 1: Industrial electric motor with 2 pole pairs (4 poles total)
  Define MotorSpeed.d = E3P::GetSynchronousRpm(50.0, 2)
  PrintN("Synchronous speed of 4-pole motor at 50Hz: " + StrD(MotorSpeed, 0) + " rpm") ; Expected: 1500
  
  ; Test 2: Calculate reactive and active power for a 400V pump motor drawing 11 Amperes at cos phi 0.82
  Define ActiveP.d   = E3P::GetActivePower(400.0, 11.0, 0.82)
  Define ReactiveP.d = E3P::GetReactivePower(400.0, 11.0, 0.82)
  
  PrintN("Active Power (True Load):   " + StrD(ActiveP / 1000.0, 2) + " kW")
  PrintN("Reactive Power (Idle Load): " + StrD(ReactiveP / 1000.0, 2) + " kvar")
  
  Input()
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 185
; Folding = ---
; DPIAware
; CPU = 5