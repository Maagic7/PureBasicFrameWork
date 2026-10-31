; ===========================================================================
;  FILE: PbFw_Module_TD.pb
;  NAME: Module Thermodynamics Core [TD::]
;  DESC: Core Module for universal thermodynamic laws, gas laws and equations
;  DESC: This Module is used as base Module from Air, Wind, Water
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/10/26
; COATHOR  :  AI Assistant (Gemini)
; VERSION  :  0.5 pretested Developer Version
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

; XIncludeFile "PbFw_Module_TD.pb"           ; TD::       Basic Thermodynamics Core

XIncludeFile "PbFw_Module_UC.pb"            ; UC::      Unit conversions

DeclareModule TD  ; basic thermo dynamics
  EnableExplicit  
  
  ; --- Atmospheric Normal Reference (ANR) ---
  #TD_ANR_T_KELVIN     = 293.15    ; 20 °C in Kelvin
  #TD_ANR_PE_PASCAL    = 101325.0  ; 1.01325 bar (Standard Atmosphere)
  
  ; --- Universal Constants ---
  #TD_T_ZERO           = 273.15    ; Absolute zero in Kelvin
  #TD_R_UNIVERSAL      = 8.314462  ; Universal gas constant in J/(mol·K)
  
  ; --- Gas-Specific Constants (Common Shortcuts) ---
  #TD_R_SPECIFIC_AIR   = 287.058   ; Specific gas constant for dry air in J/(kg·K)  
  
  ; --- Specific Heat Capacities (Isobaric, Cp) ---
  #TD_CP_DRY_AIR       = 1005.0    ; Specific heat capacity of dry air in J/(kg·K)
  #TD_CP_STEAM         = 1860.0    ; Specific heat capacity of water vapor in J/(kg·K)
  #TD_CP_WATER         = 4184.0    ; Specific heat capacity of liquid water in J/(kg·K)

  
  ; --- Enumeration for IdealGasLaw Solvers ---
  #TD_Solve_P1 = 1
  #TD_Solve_V1 = 2
  #TD_Solve_T1 = 3
  #TD_Solve_P2 = 4
  #TD_Solve_V2 = 5
  #TD_Solve_T2 = 6
  
  ; --- Enumeration for Absolute Ideal Gas Law Solvers (p * V = m * R * T) ---
  #TD_Solve_Abs_P = 11
  #TD_Solve_Abs_V = 12
  #TD_Solve_Abs_M = 13
  #TD_Solve_Abs_T = 14

  
  ; --- Deklaration der Prozeduren ---
  Declare.d IdealGasLaw(P1.d, V1.d, T1_Kelvin.d, P2.d, V2.d, T2_Kelvin.d, SolveForVariable.i = #TD_Solve_V2)
  Declare.d IdealGasLawAbsolute(P.d, V.d, M.d, R_Specific.d, T_Kelvin.d, SolveForVariable.i = #TD_Solve_Abs_M)
  Declare.d IdealGasDensity(P_Pascal.d, T_Kelvin.d, R_Specific.d)
  
  Declare.d SensibleHeat(Mass.d,     Cp.d, DeltaT.d)
  Declare.d ThermalPower(MassFlow.d, Cp.d, DeltaT.d)
EndDeclareModule


Module TD
  EnableExplicit  
  
  Procedure.d IdealGasLaw(P1.d, V1.d, T1_Kelvin.d, P2.d, V2.d, T2_Kelvin.d, SolveForVariable.i = #TD_Solve_V2)
  ; ============================================================================
  ; NAME: IdealGasLaw
  ; DESC: Solves the combined ideal gas law equation (P1 * V1 / T1 = P2 * V2 / T2) 
  ;       for any single missing parameter using strict numeric solver flags.
  ; VAR(P1.d)             : Initial absolute pressure in Pascals (Pa)
  ; VAR(V1.d)             : Initial volume in cubic meters (m³)
  ; VAR(T1_Kelvin.d)      : Initial absolute temperature in Kelvin (K)
  ; VAR(P2.d)             : Target absolute pressure in Pascals (Pa)
  ; VAR(V2.d)             : Target volume in cubic meters (m³)
  ; VAR(T2_Kelvin.d)      : Target absolute temperature in Kelvin (K)
  ; VAR(SolveForVariable.i): Numeric flag specifying the return target (#Flu_Solve_P1 to #Flu_Solve_T2)
  ; RET.d                 : The calculated value of the requested missing parameter
  ; ============================================================================
    Select SolveForVariable
      Case #TD_Solve_P1
        If V1 = 0.0 Or T2_Kelvin = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (P2 * V2 * T1_Kelvin) / (T2_Kelvin * V1)
        
      Case #TD_Solve_V1
        If P1 = 0.0 Or T2_Kelvin = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (P2 * V2 * T1_Kelvin) / (T2_Kelvin * P1)
        
      Case #TD_Solve_T1
        If P2 = 0.0 Or V2 = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (P1 * V1 * T2_Kelvin) / (P2 * V2)
        
      Case #TD_Solve_P2
        If V2 = 0.0 Or T1_Kelvin = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (P1 * V1 * T2_Kelvin) / (T1_Kelvin * V2)
        
      Case #TD_Solve_V2
        If P2 = 0.0 Or T1_Kelvin = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (P1 * V1 * T2_Kelvin) / (T1_Kelvin * P2)
        
      Case #TD_Solve_T2
        If P1 = 0.0 Or V1 = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (P2 * V2 * T1_Kelvin) / (P1 * V1)
        
      Default
        ProcedureReturn 0.0
    EndSelect
  EndProcedure
  
  Procedure.d IdealGasLawAbsolute(P.d, V.d, M.d, R_Specific.d, T_Kelvin.d, SolveForVariable.i = #TD_Solve_Abs_M)
  ; ============================================================================
  ; NAME: IdealGasLawAbsolute
  ; DESC: Solves the absolute ideal gas law equation (P * V = M * R_Specific * T)
  ;       for any single missing parameter using strict numeric solver flags.
  ; VAR(P.d)              : Absolute pressure in Pascals (Pa)
  ; VAR(V.d)              : Volume in cubic meters (m³)
  ; VAR(M.d)              : Mass in kilograms (kg)
  ; VAR(R_Specific.d)     : Specific gas constant of the medium in J/(kg·K)
  ; VAR(T_Kelvin.d)       : Absolute temperature in Kelvin (K)
  ; VAR(SolveForVariable.i): Numeric flag specifying the return target (#TD_Solve_Abs_P to #TD_Solve_Abs_T)
  ; RET.d                 : The calculated value of the requested missing parameter
  ; ============================================================================
    
    Select SolveForVariable
      Case #TD_Solve_Abs_P
        If V = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (M * R_Specific * T_Kelvin) / V
        
      Case #TD_Solve_Abs_V
        If P = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (M * R_Specific * T_Kelvin) / P
        
      Case #TD_Solve_Abs_M
        If R_Specific = 0.0 Or T_Kelvin = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (P * V) / (R_Specific * T_Kelvin)
        
      Case #TD_Solve_Abs_T
        If M = 0.0 Or R_Specific = 0.0 : ProcedureReturn 0.0 : EndIf
        ProcedureReturn (P * V) / (M * R_Specific)
        
      Default
        ProcedureReturn 0.0
    EndSelect
  EndProcedure

  Procedure.d IdealGasDensity (P_Pascal.d, T_Kelvin.d, R_Specific.d)
  ; ============================================================================
  ; NAME: IdealGasDensity
  ; DESC: Calculates the density (rho = P / (R_Specific * T)) of an ideal gas
  ;       based on pressure, absolute temperature, and its specific gas constant.
  ; VAR(P_Pascal.d)   : Absolute pressure in Pascals (Pa)
  ; VAR(T_Kelvin.d)   : Absolute temperature in Kelvin (K)
  ; VAR(R_Specific.d) : Specific gas constant of the medium in J/(kg·K)
  ; RET.d             : The calculated density of the gas in kg/m³
  ; ============================================================================    
    
    If T_Kelvin = 0.0 Or R_Specific = 0.0 
      ProcedureReturn 0.0 
    EndIf
    
    ProcedureReturn P_Pascal / (R_Specific * T_Kelvin)
  EndProcedure
  
  Procedure.d SensibleHeat(Mass.d, Cp.d, DeltaT.d)
  ; ============================================================================
  ; NAME: SensibleHeat
  ; DESC: Calculates the sensible thermal energy required to change the 
  ;       temperature of a static mass without causing a phase change.
  ; VAR(Mass.d)    : Mass of the substance in kilograms (kg)
  ; VAR(Cp.d)      : Specific heat capacity at constant pressure in J/(kg·K)
  ; VAR(DeltaT.d)  : Temperature difference in Kelvin or Celsius (K or °C)
  ; RET.d          : The calculated thermal energy in Joules (J)
  ; ============================================================================
    ProcedureReturn Mass * Cp * DeltaT
  EndProcedure

  Procedure.d ThermalPower(MassFlow.d, Cp.d, DeltaT.d)
  ; ============================================================================
  ; NAME: ThermalPower
  ; DESC: Calculates the thermal power required for a heating or cooling process
  ;       based on a mass flow rate, specific heat, and temperature difference.
  ; VAR(MassFlow.d) : Mass flow rate in kilograms per second (kg/s)
  ; VAR(Cp.d)       : Specific heat capacity at constant pressure in J/(kg·K)
  ; VAR(DeltaT.d)   : Temperature difference in Kelvin or Celsius (K or °C)
  ; RET.d           : The calculated thermal power in Watts (W)
  ; ============================================================================
    ProcedureReturn MassFlow * Cp * DeltaT
  EndProcedure

  
EndModule


; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 25
; Folding = --
; DPIAware
; CPU = 5