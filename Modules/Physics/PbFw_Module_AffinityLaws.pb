; ===========================================================================
;  FILE: PbFw_Module_AffinityLaws.pb
;  NAME: Module AffinityLaws [AffinityLaws::]
;  DESC: Modul for affinity laws of centrifugal pumps and fans (Drehzahlgesetze)
;  DESC: 
;  SOURCES: 
; ===========================================================================
;
; AUTHOR   :  MyName
; DATE     :  2026/10/26
; COAUTHOR :  AI Assistant (Gemini)
; VERSION  :  0.1 Developer Version (Collection Phase)
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;   2026/10/26 - Initial interface design for pump and fan affinity laws
;                governing flow, pressure, and power scaling.
;}
;{ TODO:
;}
; ===========================================================================

DeclareModule AffinityLaws
  EnableExplicit

  ; Structure to output the full operational shift after a speed change
  Structure AffinityResult
    NewSpeed.d        ; Resulting rotational speed [rpm] or frequency [Hz]
    NewVolumeFlow.d   ; Resulting volume flow rate [m³/h] (linear scaling)
    NewPressure.d     ; Resulting static/total pressure [Pa] (quadratic scaling)
    NewPower.d        ; Resulting power consumption [kW] (cubic scaling)
  EndStructure

  ; Public Functions
  Declare.d GetNewVolumeFlow(OldVolumeFlow.d, OldSpeed.d, NewSpeed.d)
  Declare.d GetNewPressure(OldPressure.d, OldSpeed.d, NewSpeed.d)
  Declare.d GetNewPower(OldPower.d, OldSpeed.d, NewSpeed.d)
  Declare.i CalculateSpeedShift(OldSpeed.d, OldVolumeFlow.d, OldPressure.d, OldPower.d, NewSpeed.d, *Result.AffinityResult)
  Declare.d GetRequiredSpeedForFlow(OldSpeed.d, OldVolumeFlow.d, TargetVolumeFlow.d)

EndDeclareModule

Module AffinityLaws
  EnableExplicit

  ; ======================================================================
  ; NAME: GetNewVolumeFlow
  ; DESC: Calculates new flow rate based on linear affinity law: V2 = V1 * (n2 / n1)
  ; VAR(OldVolumeFlow.d): Baseline volume flow [m³/h] or [l/min]
  ; VAR(OldSpeed.d): Baseline speed [rpm] or frequency [Hz]
  ; VAR(NewSpeed.d): Target speed [rpm] or frequency [Hz]
  ; RET.d: New volume flow rate in the same unit as input
  ; ======================================================================
  Procedure.d GetNewVolumeFlow(OldVolumeFlow.d, OldSpeed.d, NewSpeed.d)
    If OldSpeed <= 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn OldVolumeFlow * (NewSpeed / OldSpeed)
  EndProcedure

  ; ======================================================================
  ; NAME: GetNewPressure
  ; DESC: Calculates new pressure based on quadratic law: p2 = p1 * (n2 / n1)²
  ; VAR(OldPressure.d): Baseline pressure [Pa] or [mbar]
  ; VAR(OldSpeed.d): Baseline speed [rpm] or frequency [Hz]
  ; VAR(NewSpeed.d): Target speed [rpm] or frequency [Hz]
  ; RET.d: New pressure in the same unit as input
  ; ======================================================================
  Procedure.d GetNewPressure(OldPressure.d, OldSpeed.d, NewSpeed.d)
    If OldSpeed <= 0.0 : ProcedureReturn 0.0 : EndIf
    Protected SpeedRatio.d = NewSpeed / OldSpeed
    ProcedureReturn OldPressure * (SpeedRatio * SpeedRatio)
  EndProcedure

  ; ======================================================================
  ; NAME: GetNewPower
  ; DESC: Calculates new electrical/shaft power via cubic law: P2 = P1 * (n2 / n1)³
  ; VAR(OldPower.d): Baseline power consumption [kW] or [W]
  ; VAR(OldSpeed.d): Baseline speed [rpm] or frequency [Hz]
  ; VAR(NewSpeed.d): Target speed [rpm] or frequency [Hz]
  ; RET.d: New power consumption in the same unit as input
  ; ======================================================================
  Procedure.d GetNewPower(OldPower.d, OldSpeed.d, NewSpeed.d)
    If OldSpeed <= 0.0 : ProcedureReturn 0.0 : EndIf
    Protected SpeedRatio.d = NewSpeed / OldSpeed
    ProcedureReturn OldPower * Pow(SpeedRatio, 3.0)
  EndProcedure

  ; ======================================================================
  ; NAME: CalculateSpeedShift
  ; DESC: Convenience function filling an AffinityResult structure for full overview
  ; VAR(OldSpeed.d): Baseline speed [rpm] or [Hz]
  ; VAR(OldVolumeFlow.d): Baseline volume flow [m³/h]
  ; VAR(OldPressure.d): Baseline pressure [Pa]
  ; VAR(OldPower.d): Baseline power [kW]
  ; VAR(NewSpeed.d): Target evaluation speed [rpm] or [Hz]
  ; VAR(*Result.AffinityResult): Pointer to target structure receiving the results
  ; RET.i: #True if successful, #False if pointer is invalid
  ; ======================================================================
  Procedure.i CalculateSpeedShift(OldSpeed.d, OldVolumeFlow.d, OldPressure.d, OldPower.d, NewSpeed.d, *Result.AffinityResult)
    If *Result = 0 : ProcedureReturn #False : EndIf
    
    *Result\NewSpeed      = NewSpeed
    *Result\NewVolumeFlow = GetNewVolumeFlow(OldVolumeFlow, OldSpeed, NewSpeed)
    *Result\NewPressure   = GetNewPressure(OldPressure, OldSpeed, NewSpeed)
    *Result\NewPower      = GetNewPower(OldPower, OldSpeed, NewSpeed)
    
    ProcedureReturn #True
  EndProcedure

  ; ======================================================================
  ; NAME: GetRequiredSpeedForFlow
  ; DESC: Back-calculates the target speed/Hz needed to achieve a specific flow
  ; VAR(OldSpeed.d): Baseline speed [rpm] or [Hz]
  ; VAR(OldVolumeFlow.d): Baseline volume flow [m³/h]
  ; VAR(TargetVolumeFlow.d): Desired volume flow rate [m³/h]
  ; RET.d: Required target speed/frequency in the baseline unit
  ; ======================================================================
  Procedure.d GetRequiredSpeedForFlow(OldSpeed.d, OldVolumeFlow.d, TargetVolumeFlow.d)
    If OldVolumeFlow <= 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn OldSpeed * (TargetVolumeFlow / OldVolumeFlow)
  EndProcedure

EndModule

; --- Complete Module Test Application for Open-Source Release ---
CompilerIf #PB_Compiler_IsMainFile
  
  ; Baseline data from a fan's type plate at 100% nominal speed (50.0 Hz)
  Define NominalHz.d = 50.0
  Define NominalFlow.d = 8000.0   ; 8000 m³/h
  Define NominalPress.d = 600.0   ; 600 Pa static pressure
  Define NominalPower.d = 4.0     ; 4.0 kW electrical power consumption
  
  ; ============================================================================
  ; TEST 13: THE ECO-MODE DEMO (SPEED REDUCTION TO 40 HZ)
  ; ============================================================================
  Define EcoHz.d = 40.0
  Define EcoResult.AffinityLaws::AffinityResult
  
  AffinityLaws::CalculateSpeedShift(NominalHz, NominalFlow, NominalPress, NominalPower, EcoHz, @EcoResult)
  
  Debug "=== TEST 13: ENERGY EFFICIENCY VIA SPEED REDUCTION ==="
  Debug "Nominal State: " + StrD(NominalHz,1) + " Hz | " + StrD(NominalFlow,0) + " m³/h | " + StrD(NominalPress,0) + " Pa | " + StrD(NominalPower,1) + " kW"
  Debug "Reducing Frequency Down To: " + StrD(EcoResult\NewSpeed, 1) + " Hz (80% Speed)"
  Debug "----------------------------------------------------------------------"
  Debug "Resulting Volume Flow: " + StrD(EcoResult\NewVolumeFlow, 0) + " m³/h (Linear drop)"
  Debug "Resulting Pressure:    " + StrD(EcoResult\NewPressure, 1) + " Pa (Quadratic drop)"
  Debug "Resulting Power Draw:  " + StrD(EcoResult\NewPower, 2) + " kW (Cubic drop!)"
  Debug ""
  Debug "Live Defense Note: By reducing the speed by only 20%, our software saves:"
  Debug "-> " + StrD(NominalPower - EcoResult\NewPower, 2) + " kW of electrical power!"
  Debug "-> That is a massive " + StrD(((NominalPower - EcoResult\NewPower)/NominalPower)*100, 1) + "% energy reduction!"
  Debug "**********************************************************************"
  
  
  ; ============================================================================
  ; TEST 14: TARGET SETPOINT BACK-CALCULATION
  ; ============================================================================
  ; The customer requests an upgrade to 10,000 m³/h. What frequency do we need?
  Define TargetFlow.d = 10000.0
  Define RequiredHz.d = AffinityLaws::GetRequiredSpeedForFlow(NominalHz, NominalFlow, TargetFlow)
  Define RequiredPower.d = AffinityLaws::GetNewPower(NominalPower, NominalHz, RequiredHz)
  
  Debug "=== TEST 14: SPEED BACK-CALCULATION FOR TARGET FLOW ==="
  Debug "Desired Volume Flow Target: " + StrD(TargetFlow, 0) + " m³/h"
  Debug "----------------------------------------------------------------------"
  Debug "Required Frequency on Frequency Inverter: " + StrD(RequiredHz, 2) + " Hz"
  Debug "Estimated New Power Consumption:          " + StrD(RequiredPower, 2) + " kW"
  
  If RequiredHz > 60.0
    Debug "-> Critical Warning: Frequency exceeds standard motor limits (max 50/60Hz)!"
  Else
    Debug "-> State: Frequency achievable if motor and drive support over-syncing."
  EndIf
  Debug "**********************************************************************"

CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 24
; Folding = --
; DPIAware
; CPU = 5