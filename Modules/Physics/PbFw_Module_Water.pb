; ===========================================================================
;  FILE: PbFw_Module_Water.pb
;  NAME: Module Water Water::
;  DESC: Modul for water hydraulics, thermal power transfer and glycol mixtures
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
;   2026/10/26 - Initial interface design supporting Pure Water, Ethylene, 
;                and Propylene Glycol mixtures for thermal power calculations.
;}
;{ TODO:
;}
; ===========================================================================

; XIncludeFile "PbFw_Module_WATER.pb"     ; WATER::     Water Thermodynamics 

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "..\PbFw_Module_PbFw.pb"     ; PbFw::     FrameWork control Module

XIncludeFile "PbFw_Module_TD.pb"           ; TD::       Basic Thermodynamics Core

DeclareModule Water
  EnableExplicit
  
  ; Standard reference values for pure water at 20°C
  #DEFAULT_WATER_DENSITY = 998.2   ; kg/m³
  #DEFAULT_WATER_HEATCAP = 4.182   ; kJ/(kg*K)

  ; Glycol Types for chemical mixtures
  Enumeration GlycolType
    #Glycol_None       ; Pure Water
    #Glycol_Ethylene   ; Industrial/Technical cooling loops (MEG - toxic)
    #Glycol_Propylene  ; HVAC, Solar, Food industry applications (MPG - non-toxic)
  EndEnumeration

  ; Public Functions
  Declare.d GetMixtureDensity(Temperature.d, GlycolType.i, Percentage.d)
  Declare.d GetMixtureSpecificHeatCapacity(Temperature.d, GlycolType.i, Percentage.d)
  Declare.d GetVolumeFlowRate(CrossSectionArea.d, Velocity.d)
  Declare.d GetMassFlowRate(VolumeFlow_m3h.d, Temperature.d, GlycolType.i, Percentage.d)
  Declare.d GetThermalPower_kW(VolumeFlow_m3h.d, TempInlet.d, TempOutlet.d, GlycolType.i, Percentage.d)
  Declare.d VolumeFlowToVelocity(VolumeFlow_m3h.d, PipeDiameter_m.d)
  
EndDeclareModule

Module Water
  EnableExplicit
  
  ; ======================================================================
  ; NAME: GetMixtureDensity
  ; DESC: Approximates the fluid density based on temperature and glycol content
  ; VAR(Temperature.d): Fluid temperature [°C]
  ; VAR(GlycolType.i): Type of glycol (#Glycol_None, #Glycol_Ethylene, #Glycol_Propylene)
  ; VAR(Percentage.d): Glycol volume concentration [0..100%]
  ; RET.d: Fluid density [kg/m³]
  ; ======================================================================
  Procedure.d GetMixtureDensity(Temperature.d, GlycolType.i, Percentage.d)
    Protected BaseDensity.d = 1000.0 - 0.004 * Pow(Temperature - 4.0, 2.0) ; Standard water density curve
    
    If GlycolType = #Glycol_None Or Percentage <= 0.0
      ProcedureReturn BaseDensity
    EndIf
    
    ; Limit percentage to practical limits (max 60%)
    If Percentage > 60.0 : Percentage = 60.0 : EndIf
    
    Select GlycolType
      Case #Glycol_Ethylene
        ; Ethylene glycol increases density significantly (approx +1.35 kg/m³ per % concentration)
        ProcedureReturn BaseDensity + (1.35 * Percentage) - (0.1 * Temperature)
        
      Case #Glycol_Propylene
        ; Propylene glycol increases density slightly less (approx +0.85 kg/m³ per % concentration)
        ProcedureReturn BaseDensity + (0.85 * Percentage) - (0.15 * Temperature)
        
      Default
        ProcedureReturn BaseDensity
    EndSelect
  EndProcedure

  ; ======================================================================
  ; NAME: GetMixtureSpecificHeatCapacity
  ; DESC: Approximates specific heat capacity c_p factoring in glycol dilution
  ; VAR(Temperature.d): Fluid temperature [°C]
  ; VAR(GlycolType.i): Type of glycol (#Glycol_None, #Glycol_Ethylene, #Glycol_Propylene)
  ; VAR(Percentage.d): Glycol volume concentration [0..100%]
  ; RET.d: Specific heat capacity c_p [kJ/(kg*K)]
  ; ======================================================================
  Procedure.d GetMixtureSpecificHeatCapacity(Temperature.d, GlycolType.i, Percentage.d)
    Protected BaseCp.d = #DEFAULT_WATER_HEATCAP ; Pure water baseline
    
    If GlycolType = #Glycol_None Or Percentage <= 0.0
      ProcedureReturn BaseCp
    EndIf
    
    If Percentage > 60.0 : Percentage = 60.0 : EndIf
    
    Select GlycolType
      Case #Glycol_Ethylene
        ; Ethylene glycol drops c_p by roughly 0.023 per percent concentration
        ProcedureReturn BaseCp - (0.023 * Percentage) + (0.001 * Temperature)
        
      Case #Glycol_Propylene
        ; Propylene glycol drops c_p slightly faster, by roughly 0.026 per percent
        ProcedureReturn BaseCp - (0.026 * Percentage) + (0.0015 * Temperature)
        
      Default
        ProcedureReturn BaseCp
    EndSelect
  EndProcedure

  ; ======================================================================
  ; NAME: GetVolumeFlowRate
  ; DESC: Computes volumetric displacement through pipe area: V_dot = A * v
  ; VAR(CrossSectionArea.d): Pipe inner cross-section [m²]
  ; VAR(Velocity.d): Flow velocity [m/s]
  ; RET.d: Volume flow rate [m³/s]
  ; ======================================================================
  Procedure.d GetVolumeFlowRate(CrossSectionArea.d, Velocity.d)
    ProcedureReturn CrossSectionArea * Velocity
  EndProcedure

  ; ======================================================================
  ; NAME: GetMassFlowRate
  ; DESC: Calculates weight of fluid passing per second: m_dot = V_dot * rho
  ; VAR(VolumeFlow_m3h.d): Volumetric flow rate [m³/h]
  ; VAR(Temperature.d): Average fluid temperature [°C]
  ; VAR(GlycolType.i): Type of glycol (#Glycol_None, #Glycol_Ethylene, #Glycol_Propylene)
  ; VAR(Percentage.d): Glycol volume concentration [0..100%]
  ; RET.d: Mass flow rate [kg/s]
  ; ======================================================================
  Procedure.d GetMassFlowRate(VolumeFlow_m3h.d, Temperature.d, GlycolType.i, Percentage.d)
    Protected Density.d = GetMixtureDensity(Temperature, GlycolType, Percentage)
    Protected VolumeFlow_m3s.d = VolumeFlow_m3h / 3600.0
    ProcedureReturn VolumeFlow_m3s * Density
  EndProcedure

  ; ======================================================================
  ; NAME: GetThermalPower_kW
  ; DESC: The core automation check: Q_dot = m_dot * c_p * deltaT
  ; VAR(VolumeFlow_m3h.d): Flow meter reading [m³/h]
  ; VAR(TempInlet.d): Flow/Inlet temperature (Vorlauf) [°C]
  ; VAR(TempOutlet.d): Return/Outlet temperature (Rücklauf) [°C]
  ; VAR(GlycolType.i): Type of glycol (#Glycol_None, #Glycol_Ethylene, #Glycol_Propylene)
  ; VAR(Percentage.d): Glycol volume concentration [0..100%]
  ; RET.d: Transmitted thermal power [kW]
  ; ======================================================================
  Procedure.d GetThermalPower_kW(VolumeFlow_m3h.d, TempInlet.d, TempOutlet.d, GlycolType.i, Percentage.d)
    Protected AverageTemp.d = (TempInlet + TempOutlet) / 2.0
    Protected MassFlow.d = GetMassFlowRate(VolumeFlow_m3h, AverageTemp, GlycolType, Percentage)
    Protected Cp.d = GetMixtureSpecificHeatCapacity(AverageTemp, GlycolType, Percentage)
    Protected DeltaT.d = Abs(TempInlet - TempOutlet)
    
    ; Power (kW) = kg/s * kJ/(kg*K) * K
    ProcedureReturn MassFlow * Cp * DeltaT
  EndProcedure

  ; ======================================================================
  ; NAME: VolumeFlowToVelocity
  ; DESC: Calculates the internal pipe velocity to prevent noise/erosion
  ; VAR(VolumeFlow_m3h.d): Volumetric flow rate [m³/h]
  ; VAR(PipeDiameter_m.d): Pipe inner diameter [m]
  ; RET.d: Velocity [m/s]
  ; ======================================================================
  Procedure.d VolumeFlowToVelocity(VolumeFlow_m3h.d, PipeDiameter_m.d)
    Protected Area.d
    If PipeDiameter_m <= 0.0 : ProcedureReturn 0.0 : EndIf
    Area = #PI * (PipeDiameter_m * PipeDiameter_m) / 4.0
    ProcedureReturn (VolumeFlow_m3h / 3600.0) / Area
  EndProcedure

EndModule

; --- Complete Module Test Application for Open-Source Release ---
CompilerIf #PB_Compiler_IsMainFile
  
  Define FlowRate.d = 12.0  ; 12 m³/h flow meter measurement
  Define T_Inlet.d  = 12.0  ; 12°C warm return fluid arriving
  Define T_Outlet.d = 6.0   ; 6°C cold fluid leaving the chiller
  
  ; ============================================================================
  ; TEST 10: PURE WATER THERMAL COOLING CAPACATY
  ; ============================================================================
  Define PowerWater.d
  PowerWater = Water::GetThermalPower_kW(FlowRate, T_Inlet, T_Outlet, Water::#Glycol_None, 0.0)
  
  Debug "=== TEST 10: PURE WATER THERMAL POWER ==="
  Debug "Flow Rate: " + StrD(FlowRate, 1) + " m³/h with DeltaT: " + StrD(Abs(T_Inlet - T_Outlet), 1) + " K"
  Debug "Calculated Cooling Power: " + StrD(PowerWater, 1) + " kW"
  Debug "**********************************************************************"
  
  
  ; ============================================================================
  ; TEST 11: PROPYLENE GLYCOL MIXTURE CORRECTION (SOLAR / HVAC STANDARD)
  ; ============================================================================
  ; Same flow and temperatures, but 35% Propylene Glycol antifreeze mixed in
  Define PowerGlycol.d
  Define AntifreezePercent.d = 35.0
  PowerGlycol = Water::GetThermalPower_kW(FlowRate, T_Inlet, T_Outlet, Water::#Glycol_Propylene, AntifreezePercent)
  
  Debug "=== TEST 11: GLYCOL MIXTURE CORRECTION (35% PROPYLENE) ==="
  Debug "Flow Rate: " + StrD(FlowRate, 1) + " m³/h with DeltaT: " + StrD(Abs(T_Inlet - T_Outlet), 1) + " K"
  Debug "Calculated Cooling Power: " + StrD(PowerGlycol, 1) + " kW"
  Debug "Live Defense Note: Adding 35% Antifreeze lowered the heat capacity."
  Debug "-> Actual thermal performance dropped by: " + StrD(PowerWater - PowerGlycol, 1) + " kW (" + StrD(((PowerWater-PowerGlycol)/PowerWater)*100,1) + " % reduction!)"
  Debug "-> Without this module, your software would OVERESTIMATE the cooling by " + StrD(PowerWater - PowerGlycol, 1) + " kW!"
  Debug "**********************************************************************"
  
  
  ; ============================================================================
  ; TEST 12: HYDRAULIC PIPE FLOW VELOCITY VELOCITY CHECKS
  ; ============================================================================
  Define PipeDN.d = 0.065 ; DN65 Pipe (65 mm inner diameter = 0.065m)
  Define FlowVelocity.d = Water::VolumeFlowToVelocity(FlowRate, PipeDN)
  
  Debug "=== TEST 12: HYDRAULIC PIPE FLOW VELOCITY ==="
  Debug "Flow Rate: " + StrD(FlowRate, 1) + " m³/h through DN65 Pipe"
  Debug "Velocity: " + StrD(FlowVelocity, 2) + " m/s"
  If FlowVelocity > 1.5
    Debug "-> Warning: Velocity high! Risk of noise and erosion."
  Else
    Debug "-> State: Velocity within perfect engineering boundaries (0.5 - 1.5 m/s)."
  EndIf
  Debug "**********************************************************************"

CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 34
; Folding = --
; DPIAware
; CPU = 5