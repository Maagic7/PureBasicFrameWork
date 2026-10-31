; ===========================================================================
;  FILE: PbFw_Module_UC.pb
;  NAME: Module Unit conversions [UC::]
;  DESC: Universal SI unit conversion macros and scaling constants
;  DESC: 
;  SOURCES: 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/10/25
; COAUTHOR :  AI Assistant (Gemini)
; VERSION  :  1.0 Release Stable Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;   2026/10/26 - Rearragend as Modul from SI_Unit_Macros.pbi
;              - Integrated Group 10 (Mass Flow) And Group 11 (Energy) macros
;                with precise floating-point scaling factors for thermodynamic use.
;}
;{ TODO:
;}
; ===========================================================================

DeclareModule UC
  
  ; ============================================================================
  ;-  GROUP 1: LENGTH CONVERSIONS (Base: mm)
  ; ============================================================================
  
  ; --- Metric to Metric ---
  Macro mm_to_cm(mm)  : ((mm) / 10.0)      : EndMacro
  Macro mm_to_dm(mm)  : ((mm) / 100.0)     : EndMacro
  Macro mm_to_m(mm)   : ((mm) / 1000.0)    : EndMacro
  Macro mm_to_km(mm)  : ((mm) / 1000000.0) : EndMacro
  
  Macro cm_to_mm(cm)  : ((cm) * 10.0)      : EndMacro
  Macro dm_to_mm(dm)  : ((dm) * 100.0)     : EndMacro
  Macro m_to_mm(m)    : ((m) * 1000.0)     : EndMacro
  Macro km_to_mm(km)  : ((km) * 1000000.0) : EndMacro

  ; --- Imperial to Metric & Vice Versa ---
  Macro mm_to_in(mm)  : ((mm) / 25.4)      : EndMacro
  Macro mm_to_ft(mm)  : ((mm) / 304.8)     : EndMacro
  
  Macro in_to_mm(in)  : ((in) * 25.4)      : EndMacro
  Macro ft_to_mm(ft)  : ((ft) * 304.8)     : EndMacro


  ; ============================================================================
  ;-  GROUP 2: PRESSURE CONVERSIONS (Base: bar)
  ; ============================================================================
  
 ; --- Bar to other units ---
  Macro bar_to_mbar(bar)  : ((bar) * 1000.0)   : EndMacro
  Macro bar_to_pa(bar)    : ((bar) * 100000.0) : EndMacro
  Macro bar_to_hpa(bar)   : ((bar) * 1000.0)   : EndMacro
  Macro bar_to_N_sqm(bar) : ((bar) * 100000.0) : EndMacro

  ; --- Other units back to Bar (Inverse) ---
  Macro mbar_to_bar(mbar) : ((mbar) / 1000.0)  : EndMacro
  Macro pa_to_bar(pa)     : ((pa) / 100000.0)  : EndMacro
  Macro hpa_to_bar(hpa)   : ((hpa) / 1000.0)   : EndMacro
  Macro N_sqm_to_bar(N)   : ((N) / 100000.0)   : EndMacro

  ; ============================================================================
  ;-  GROUP 3: TEMPERATURE CONVERSIONS
  ; ============================================================================
  
  ; #T0_Celsius is kept internal in the Module section to avoid global pollution
  
  Macro K_to_C(T_Kelvin)      : ((T_Kelvin) - 273.15)                   : EndMacro
  Macro C_to_K(T_Celsius)     : ((T_Celsius) + 273.15)                  : EndMacro
  Macro F_to_C(T_Fahrenheit)  : (((T_Fahrenheit) - 32.0) * (5.0 / 9.0)) : EndMacro
  Macro C_to_F(T_Celsius)     : (((T_Celsius) * (9.0 / 5.0)) + 32.0)    : EndMacro
  Macro F_to_K(T_Fahrenheit)  : (((T_Fahrenheit) + 459.67) * (5.0 / 9.0)): EndMacro
  Macro K_to_F(T_Kelvin)      : (((T_Kelvin) * (9.0 / 5.0)) - 459.67)   : EndMacro


  ; ============================================================================
  ;-  GROUP 4: INDUSTRIAL VOLUME FLOW CONVERSIONS
  ; ============================================================================
  
  ; Liters per minute <-> Cubic meters per second (SI unit for flow)
  Macro lpm_to_m3s(lpm)  : ((lpm) / 60000.0) : EndMacro
  Macro m3s_to_lpm(m3s)  : ((m3s) * 60000.0) : EndMacro
  
  ; ============================================================================
  ;-  GROUP 5: VELOCITY CONVERSIONS (Base: m/s)
  ; ============================================================================
  
  ; --- Metric Conversions ---
  ; 1 m/s = 3.6 km/h
  Macro m_s_to_km_h(m_s)   : ((m_s) * 3.6)       : EndMacro
  Macro km_h_to_m_s(km_h)  : ((km_h) / 3.6)       : EndMacro
  
  ; --- Imperial Conversions (Miles per Hour) ---
  ; 1 mph = 0.44704 m/s
  Macro m_s_to_mph(m_s)    : ((m_s) / 0.44704)   : EndMacro
  Macro mph_to_m_s(mph)    : ((mph) * 0.44704)   : EndMacro
  
  ; Direct conversion between km/h and mph
  ; 1 mph = 1.609344 km/h
  Macro km_h_to_mph(km_h)   : ((km_h) / 1.609344) : EndMacro
  Macro mph_to_km_h(mph)    : ((mph) * 1.609344) : EndMacro
  
  ; ============================================================================
  ;-  GROUP 6: VOLUME & AREA CONVERSIONS (Base: m³ / m²)
  ; ============================================================================
  
  ; --- Volume ---
  Macro l_to_m3(l)         : ((l) / 1000.0)      : EndMacro
  Macro m3_to_l(m3)        : ((m3) * 1000.0)     : EndMacro
  Macro cm3_to_l(cm3)      : ((cm3) / 1000.0)     : EndMacro
  Macro l_to_cm3(l)        : ((l) * 1000.0)     : EndMacro
  
  ; --- Area ---
  ; 1 m² = 1,000,000 mm²
  Macro sqmm_to_sqm(sqmm)  : ((sqmm) / 1000000.0): EndMacro
  Macro sqm_to_sqmm(sqm)   : ((sqm) * 1000000.0) : EndMacro


  ; ============================================================================
  ;- GROUP 7: FORCE & MASS CONVERSIONS (Base: Newton / kg)
  ; ============================================================================
  
  ; Uses standard Earth gravity approximation (9.81) for practical weight conversion
  Macro N_to_kg(N)         : ((N) / 9.81)        : EndMacro
  Macro kg_to_N(kg)        : ((kg) * 9.81)       : EndMacro
  Macro kg_to_t(kg)        : ((kg) / 1000.0)     : EndMacro
  Macro t_to_kg(t)         : ((t) * 1000.0)      : EndMacro

  ; ============================================================================
  ;- GROUP 8: POWER CONVERSIONS (Base: Watt)
  ; ============================================================================
  
  ; 1 HP (Imperial/Mechanical) = 745.7 Watts
  Macro hp_to_W(hp)        : ((hp) * 745.7)      : EndMacro
  Macro W_to_hp(W)         : ((W) / 745.7)       : EndMacro
  
  ; Direct kW <-> HP for quick engine scaling
  Macro kW_to_hp(kW)       : ((kW) * 1.34102)    : EndMacro
  Macro hp_to_kW(hp)       : ((hp) / 1.34102)    : EndMacro
  
  ; ============================================================================
  ;- GROUP 10: MASS FLOW CONVERSIONS (Base: kg/s)
  ; ============================================================================
  
  ; kg/s <-> kg/h (Factor: 3600)
  Macro kgs_to_kgh(kgs)    : ((kgs) * 3600.0)    : EndMacro
  Macro kgh_to_kgs(kgh)    : ((kgh) / 3600.0)    : EndMacro
  
  ; kg/s <-> lb/s (Pounds per second, Factor: 2.20462262)
  Macro kgs_to_lbs(kgs)    : ((kgs) * 2.20462262): EndMacro
  Macro lbs_to_kgs(lbs)    : ((lbs) / 2.20462262): EndMacro
  
  ; kg/s <-> lb/h (Pounds per hour, Factor: 3600 * 2.20462262 = 7936.641432)
  Macro kgs_to_lbh(kgs)    : ((kgs) * 7936.64143): EndMacro
  Macro lbh_to_kgs(lbh)    : ((lbh) / 7936.64143): EndMacro
  
  ; ============================================================================
  ;- GROUP 11: ENERGY CONVERSIONS (Base: Joule / KiloJoule)
  ; ============================================================================
  
  ; 1 kWh = 3600 kJ
  Macro kWh_to_kJ(kWh)     : ((kWh) * 3600.0)    : EndMacro  
  Macro kJ_to_kWh(kJ)      : ((kJ) / 3600.0)     : EndMacro    
  
  ; 1 kJ = 1000 Joule (J)
  Macro kJ_to_J(kJ)        : ((kJ) * 1000.0)     : EndMacro
  Macro J_to_kJ(J)         : ((J) / 1000.0)      : EndMacro
  
  ; 1 kWh = 3,600,000 Joule (J)
  Macro kWh_to_J(kWh)      : ((kWh) * 3600000.0) : EndMacro
  Macro J_to_kWh(J)        : ((J) / 3600000.0)   : EndMacro
  
  ; --- Calories (Thermochemical / International Table) ---
  ; 1 kcal = 4.1868 kJ (Standard in nutrition and engineering)
  Macro kcal_to_kJ(kcal)   : ((kcal) * 4.1868)   : EndMacro
  Macro kJ_to_kcal(kJ)     : ((kJ) / 4.1868)     : EndMacro
  
  ; 1 kcal = 0.001163 kWh
  Macro kcal_to_kWh(kcal)  : ((kcal) * 0.001163) : EndMacro
  Macro kWh_to_kcal(kWh)   : ((kWh) / 0.001163) : EndMacro
  
  ; ============================================================================
  ;- GROUP 11: MOLE CONVERSIONS (Base: mol)
  ; ============================================================================
  
  ; --- Ideal Gas Standard Constants (0°C, 1013.25 hPa) ---
  #MOLAR_VOLUME_IDEAL_LITERS = 22.414         ; Liters occupied by 1 mol of ideal gas
  #AVOGADRO_CONSTANT         = 6.02214076e23  ; Particles per mol
  
  ; --- Common Industrial Molar Masses (g/mol) ---
  #MOLAR_MASS_DRY_AIR        = 28.9644  ; Average dry air mix
  #MOLAR_MASS_N2             = 28.0134  ; Nitrogen
  #MOLAR_MASS_O2             = 31.9988  ; Oxygen
  #MOLAR_MASS_CO2            = 44.0100  ; Carbon Dioxide
  #MOLAR_MASS_H2O            = 18.0152  ; Water Vapor (crucial for humidity/dewpoint)

  ; --- Mole <-> Mass (Requires Molar Mass 'M' in g/mol) ---
  ; Mass (g) = mol * M
  Macro mol_to_g(mol, MolarMass) : ((mol) * (MolarMass)) : EndMacro
  ; mol = Mass (g) / M
  Macro g_to_mol(g, MolarMass)   : ((g) / (MolarMass))   : EndMacro
  
  ; --- Mole <-> Gas Volume (At standard conditions, default: Ideal Gas) ---
  ; Volume (l) = mol * Vm
  Macro mol_to_l_gas(mol, MolarVolume = #MOLAR_VOLUME_IDEAL_LITERS)
    ((mol) * (MolarVolume))
  EndMacro
  ; mol = Volume (l) / Vm
  Macro l_gas_to_mol(l, MolarVolume = #MOLAR_VOLUME_IDEAL_LITERS)
    ((l) / (MolarVolume))
  EndMacro

  ; --- Mole <-> Particle Count ---
  Macro mol_to_particles(mol)    : ((mol) * #AVOGADRO_CONSTANT) : EndMacro
  Macro particles_to_mol(count)  : ((count) / #AVOGADRO_CONSTANT) : EndMacro
EndDeclareModule

Module UC
  ; Macros don't require implementation 
EndModule


;- --- Usage Example ---
CompilerIf #PB_Compiler_IsMainFile
  OpenConsole("UC Module - Grouped Test")
  
  ; Test Group 2: Pressure
  Define TargetPascal.d = UC::bar_to_pa(6.0)
  PrintN("6 Bar in Pascal: " + StrD(TargetPascal, 0) + " Pa")
  
  ; Test Group 3: Temperature
  Define RoomFahrenheit.d = 68.0
  Define RoomCelsius.d    = UC::F_to_C(RoomFahrenheit)
  PrintN("68 F in Celsius: " + StrD(RoomCelsius, 1) + " C")
  
  ; Test Group 4: Volume Flow
  Define PumpLpm.d = 30.0 ; 30 Liters per minute
  Define PumpSI.d  = UC::lpm_to_m3s(PumpLpm)
  PrintN("30 lpm in m3/s: " + StrD(PumpSI, 6) + " m3/s")
  
  ; Test Group 5: Velocity
  Define WindSpeedSI.d = 15.0 ; 15 m/s
  Define WindKmH.d     = UC::m_s_to_km_h(WindSpeedSI)
  Define WindMph.d     = UC::m_s_to_mph(WindSpeedSI)
  
  PrintN("Wind speed 15 m/s is:")
  PrintN("  " + StrD(WindKmH, 1) + " km/h")
  PrintN("  " + StrD(WindMph, 1) + " mph")
  
  ; Test speed limit conversion
  Define HighwayMph.d = UC::km_h_to_mph(130.0)
  PrintN("130 km/h in US units: " + StrD(HighwayMph, 1) + " mph")
  
  Input()
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 133
; FirstLine = 90
; Folding = -------------
; DPIAware
; CPU = 5