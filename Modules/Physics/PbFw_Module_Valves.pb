; ===========================================================================
;  FILE: PbFw_Module_Valves.pb
;  NAME: Module Valves [Valves::]
;  DESC: Modul for control valve sizing, kv/kvs values and valve authority
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
;   2026/10/26 - Initial interface design for fluid control valve sizing, 
;                flow coefficients (kv/kvs), and hydraulic authority.
;}
;{ TODO:
;}
; ===========================================================================

DeclareModule Valves
  EnableExplicit

  ; Public Functions
  Declare.d CalculateKv(VolumeFlow_m3h.d, PressureDrop_Pa.d, FluidDensity.d)
  Declare.d GetPressureDrop(VolumeFlow_m3h.d, Kv.d, FluidDensity.d)
  Declare.d GetVolumeFlow(Kv.d, PressureDrop_Pa.d, FluidDensity.d)
  Declare.d GetValveAuthority(PressureDropValve_Pa.d, PressureDropTotal_Pa.d)
  Declare.d GetLinearOpeningPercent(CurrentKv.d, Kvs.d)
  
EndDeclareModule

Module Valves
  EnableExplicit

  ; ======================================================================
  ; NAME: CalculateKv
  ; DESC: Calculates the flow coefficient Kv: kv = V_dot * Sqrt((rho / 1000) / dp_bar)
  ; VAR(VolumeFlow_m3h.d): Volumetric flow rate through the valve [m³/h]
  ; VAR(PressureDrop_Pa.d): Differential pressure across the valve [Pa]
  ; VAR(FluidDensity.d): Current density of the fluid [kg/m³] (e.g. from Water:: module)
  ; RET.d: Resulting Kv value [m³/h]
  ; ======================================================================
  Procedure.d CalculateKv(VolumeFlow_m3h.d, PressureDrop_Pa.d, FluidDensity.d)
    Protected PressureDrop_bar.d, RelativeDensity.d
    
    If PressureDrop_Pa <= 0.0 Or FluidDensity <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; Convert Pascal to bar (1 bar = 100,000 Pa)
    PressureDrop_bar = PressureDrop_Pa / 100000.0
    RelativeDensity  = FluidDensity / 1000.0 ; water at 4°C reference standard
    
    ProcedureReturn VolumeFlow_m3h * Sqr(RelativeDensity / PressureDrop_bar)
  EndProcedure

  ; ======================================================================
  ; NAME: GetPressureDrop
  ; DESC: Calculates valve pressure drop for a given flow and Kv: dp_Pa = (V_dot / kv)² * (rho / 1000) * 100000
  ; VAR(VolumeFlow_m3h.d): Volumetric flow rate [m³/h]
  ; VAR(Kv.d): Current Kv coefficient of the valve at its opening state [m³/h]
  ; VAR(FluidDensity.d): Current density of the fluid [kg/m³]
  ; RET.d: Pressure drop across the valve [Pa]
  ; ======================================================================
  Procedure.d GetPressureDrop(VolumeFlow_m3h.d, Kv.d, FluidDensity.d)
    Protected RelativeDensity.d, PressureDrop_bar.d
    
    If Kv <= 0.0 Or FluidDensity <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    RelativeDensity = FluidDensity / 1000.0
    PressureDrop_bar = Pow(VolumeFlow_m3h / Kv, 2.0) * RelativeDensity
    
    ProcedureReturn PressureDrop_bar * 100000.0 ; Convert back to Pascal
  EndProcedure

  ; ======================================================================
  ; NAME: GetVolumeFlow
  ; DESC: Calculates flow through a valve: V_dot = kv * Sqrt(dp_bar / (rho / 1000))
  ; VAR(Kv.d): Current Kv coefficient [m³/h]
  ; VAR(PressureDrop_Pa.d): Differential pressure across the valve [Pa]
  ; VAR(FluidDensity.d): Current density of the fluid [kg/m³]
  ; RET.d: Volumetric flow rate [m³/h]
  ; ======================================================================
  Procedure.d GetVolumeFlow(Kv.d, PressureDrop_Pa.d, FluidDensity.d)
    Protected PressureDrop_bar.d, RelativeDensity.d
    
    If PressureDrop_Pa <= 0.0 Or FluidDensity <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    PressureDrop_bar = PressureDrop_Pa / 100000.0
    RelativeDensity  = FluidDensity / 1000.0
    
    ProcedureReturn Kv * Sqr(PressureDrop_bar / RelativeDensity)
  EndProcedure

  ; ======================================================================
  ; NAME: GetValveAuthority
  ; DESC: Computes valve authority (P-Authority): N = dp_valve / dp_total
  ; VAR(PressureDropValve_Pa.d): Pressure drop across fully open valve [Pa]
  ; VAR(PressureDropTotal_Pa.d): Total pressure drop of the entire hydraulic loop [Pa]
  ; RET.d: Dimensionless valve authority factor [0..1] (Should be > 0.3 for stable control)
  ; ======================================================================
  Procedure.d GetValveAuthority(PressureDropValve_Pa.d, PressureDropTotal_Pa.d)
    If PressureDropTotal_Pa <= 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn PressureDropValve_Pa / PressureDropTotal_Pa
  EndProcedure

  ; ======================================================================
  ; NAME: GetLinearOpeningPercent
  ; DESC: Calculates structural opening percent for linear characteristic valves
  ; VAR(CurrentKv.d): Kv calculated from field measurements [m³/h]
  ; VAR(Kvs.d): Valve plate nominal maximum flow coefficient [m³/h]
  ; RET.d: Calculated target opening percentage [0..100%]
  ; ======================================================================
  Procedure.d GetLinearOpeningPercent(CurrentKv.d, Kvs.d)
    If Kvs <= 0.0 : ProcedureReturn 0.0 : EndIf
    Protected Percent.d = (CurrentKv / Kvs) * 100.0
    If Percent > 100.0 : Percent = 100.0 : EndIf
    ProcedureReturn Percent
  EndProcedure

EndModule

; --- Complete Module Test Application for Open-Source Release ---
CompilerIf #PB_Compiler_IsMainFile
  
  ; Fetching standard hot water density from your TD or Water engine setup
  Define WaterDensity.d = 983.2 ; Hot water at approx. 60°C
  
  ; System measurements from the shivering system
  Define MeasuredFlow.d  = 5.0    ; 5.0 m³/h active flow rate
  Define Valve_dp.d      = 15000.0 ; 15,000 Pa (150 mbar) measured deltaP over the open valve
  Define Loop_dp_total.d = 100000.0 ; 100,000 Pa (1.0 bar) total pressure drop of the entire circuit
  Define InstalledKvs.d  = 16.0   ; The type plate on the physical valve says Kvs 16
  
  ; ============================================================================
  ; TEST 15: VALVE SIZING AND DYNAMIC KV CALCULATION
  ; ============================================================================
  Define RequiredKv.d = Valves::CalculateKv(MeasuredFlow, Valve_dp, WaterDensity)
  
  Debug "=== TEST 15: LIVE CONTROL VALVE ANALYSIS ==="
  Debug "Measured Flow: " + StrD(MeasuredFlow, 1) + " m³/h | Valve deltaP: " + StrD(Valve_dp/1000, 1) + " kPa"
  Debug "The calculated required Kv value for this state is:"
  Debug "-> Required Kv: " + StrD(RequiredKv, 2) + " m³/h"
  Debug "The physically installed valve size has a max capacity of: Kvs " + StrD(InstalledKvs, 1)
  Debug "**********************************************************************"
  
  
  ; ============================================================================
  ; TEST 16: HYDRAULIC VALVE AUTHORITY (THE OSCILLATION ROOT CAUSE)
  ; ============================================================================
  Define Authority.d = Valves::GetValveAuthority(Valve_dp, Loop_dp_total)
  Define OpeningPercent.d = Valves::GetLinearOpeningPercent(RequiredKv, InstalledKvs)
  
  Debug "=== TEST 16: VALVE AUTHORITY & STABILITY CHECK ==="
  Debug "Calculated Valve Authority (a): " + StrD(Authority, 2)
  
  ; Regulating authority rules of thumb: Must be > 0.3 for the PID loop to ever be stable!
  If Authority < 0.3
    Debug "-> CRITICAL WARNING: Valve Authority is way too low (" + StrD(Authority, 2) + " < 0.30)!"
    Debug "   The valve is oversized and dominates only a tiny fraction of the loop friction."
  Else
    Debug "-> State: Valve Authority is hydraulically healthy."
  EndIf
  
  Debug "Effective control valve opening position for this flow: " + StrD(OpeningPercent, 1) + " %"
  If OpeningPercent < 20.0
    Debug "-> LIVE DEFENSE STATEMENT: The valve is vastly oversized! At maximum required heating,"
    Debug "   it operates at only " + StrD(OpeningPercent, 1) + " % open. The PID controller is NOT at fault;"
    Debug "   the valve is physically incapable of modulating stable flow in this lower band!"
  EndIf
  Debug "**********************************************************************"

CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 6
; Folding = --
; DPIAware
; CPU = 5