; ============================================================================
;  FILE: PbFw_AllModules_TestSuite.pb
;  NAME: Full Framework Integration Test
;  DESC: Complete test execution suite for the engineering open-source modules
; ============================================================================
;  AUTHOR   :  MyName
;  DATE     :  2026/10/26
;  COAUTHOR :  AI Assistant (Gemini)
; ============================================================================


; 1. Core Utilities and Thermodynamics Base
XIncludeFile "PbFw_Module_UnitConversion.pb"
; XIncludeFile "PbFw_Module_Thermodynamics.pb" ; Uncomment when connecting your TD module

; 2. Physics and Fluid Dynamics Modules
XIncludeFile "PbFw_Module_Wind.pb"
XIncludeFile "PbFw_Module_Duct.pb"
XIncludeFile "PbFw_Module_Water.pb"

; 3. Automation and Actuator Systems
XIncludeFile "PbFw_Module_AffinityLaws.pb"
XIncludeFile "PbFw_Module_Valves.pb"

; 4. Technical Acoustics
XIncludeFile "PbFw_Module_Acoustics.pb"

; ============================================================================

CompilerIf #PB_Compiler_IsMainFile
  
  ; Fixed reference baseline for standard environmental test conditions
  Define rho.d = 1.25 
  Define CurrentDensity.d = 1.20 ; Mimicking a typical calibrated indoor flow density
  Define WaterDensity.d = 983.2  ; Typical hot water density at approx. 60°C
  
  ; ============================================================================
  ; TEST 1: FAN PERFORMANCE AND FREE-SPACE DYNAMIC WIND PRESSURE
  ; ============================================================================
  Define FanVelocity.d = 15.0 ; 15 m/s (approx. 54 km/h)
  Define DynamicPressure.d = Wind::GetBasicVelocityPressure(FanVelocity, rho)
  
  Debug "=== TEST 1: FAN AIR STREAM COMPARISON ==="
  Debug "A fan producing a velocity of " + StrD(FanVelocity, 1) + " m/s creates a raw dynamic pressure of:"
  Debug "-> " + StrD(DynamicPressure, 1) + " Pa (N/m²)"
  Debug "If this stream hits a flat plate of 2m² head-on (c_pe = 1.2 for isolated plates):"
  Debug "-> Force: " + StrD(Wind::GetSurfaceForce(DynamicPressure, 2.0, 1.2), 1) + " Newton"
  Debug "**********************************************************************"
  Debug ""
  
  ; ============================================================================
  ; TEST 2: STANDARD BUILDING WIND LOADS (EUROCODE 1 REF)
  ; ============================================================================
  ; A small industrial building, 8 meters high, located in a commercial area (Category III)
  Define BaseWind.d   = 15.0  ; Same 15 m/s base wind zone speed
  Define Height.d     = 8.0   ; 8m building height
  Define WallArea.d   = 50.0  ; 50 m² front wall facing the wind
  Define RoofArea.d   = 100.0 ; 100 m² flat roof
  Define Loads.Wind::TBuildingLoad
  
  Wind::GetStandardTBuildingLoads(Height, Wind::#WIND_Terrain_III, BaseWind, WallArea, RoofArea, @Loads, rho)
  Define q_p.d = Wind::GetPeakVelocityPressure(Height, Wind::#WIND_Terrain_III, BaseWind, rho)
  
  Debug "=== TEST 2: BUILDING WIND LOADS (EUROCODE 1 REFERENCE) ==="
  Debug "Building Height: " + StrD(Height, 1) + "m in Terrain Category III"
  Debug "Base Wind Speed: " + StrD(BaseWind, 1) + " m/s"
  Debug "The terrain and height amplify the pressure (Peak Velocity Pressure q_p):"
  Debug "-> q_p at 8m: " + StrD(q_p, 1) + " Pa (N/m²)"
  Debug ""
  Debug "Estimated resulting structural loads for planning orientation:"
  Debug "-> Direct Windward Wall Pressure (Luv):  " + StrD(Loads\PressureWall, 0) + " N (~" + StrD(Loads\PressureWall / 9.81, 0) + " kg load)"
  Debug "-> Leeward Wall Suction (Lee):           " + StrD(Loads\SuctionWall, 0) + " N"
  Debug "-> Total Roof Uplift Force (Lifting):    " + StrD(Loads\SuctionRoof, 0) + " N"
  Debug "**********************************************************************"
  Debug "" 

  ; ============================================================================
  ; TEST 3: DETAILED ROOF ZONING (FLAT ROOF)
  ; ============================================================================
  Define DachHoehe.d = 12.0      ; 12 meters high
  Define WindZoneGeschw.d = 25.0 ; 25 m/s base wind
  Define FlaecheRand.d = 30.0   ; 30 m² edge zone
  Define FlaecheMitte.d = 120.0 ; 120 m² inner zone
  
  Define q_p_roof.d = Wind::GetPeakVelocityPressure(DachHoehe, Wind::#WIND_Terrain_III, WindZoneGeschw, rho)
  Define KraftRand.d  = Wind::GetSurfaceForce(q_p_roof, FlaecheRand, -1.8)
  Define KraftMitte.d = Wind::GetSurfaceForce(q_p_roof, FlaecheMitte, -0.6)
  Define GesamtSog.d  = KraftRand + KraftMitte
  
  Debug "=== TEST 3: DETAILED ROOF WIND LOAD CALCULATION ==="
  Debug "Peak Velocity Pressure (q_p) at " + StrD(DachHoehe, 1) + "m Height: " + StrD(q_p_roof, 1) + " Pa (N/m²)"
  Debug "----------------------------------------"
  Debug "Suction Force Edge Zones (30 m²):  " + StrD(Abs(KraftRand), 0) + " N (~" + StrD(Abs(KraftRand)/9.81, 0) + " kg)"
  Debug "Suction Force Inner Zones (120 m²): " + StrD(Abs(KraftMitte), 0) + " N (~" + StrD(Abs(KraftMitte)/9.81, 0) + " kg)"
  Debug "----------------------------------------"
  Debug "Total Uplift Force on the Roof:     " + StrD(Abs(GesamtSog), 0) + " N (~" + StrD(Abs(GesamtSog)/9.81, 0) + " kg)"
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 4: ROOF GEOMETRY COMPARISON (PITCHED VS SHED ROOF)
  ; ============================================================================
  Define v_wind_ref.d = 24.0  ; 24 m/s base wind
  Define h_building.d = 10.0  ; 10m high building
  Define TotalArea.d = 120.0  ; 120 m² roof surface
  Define Pitch.d = 45.0       ; 45 degrees pitch
  Define RoofRes.Wind::TRoofLoad
  
  Debug "=== TEST 4: PLANNER ROOF COMPARISON (Base Wind: " + StrD(v_wind_ref, 1) + " m/s) ==="
  Debug ""
  
  ; ============================================================================
  ; TEST 4: ROOF GEOMETRY COMPARISON (PITCHED VS SHED ROOF)
  ; ============================================================================
  Define v_wind_ref.d = 24.0  ; 24 m/s base wind
  Define h_building.d = 10.0  ; 10m high building
  Define TotalArea.d = 120.0  ; 120 m² roof surface
  Define Pitch.d = 45.0       ; 45 degrees pitch
  Define RoofRes.Wind::TRoofLoad
  
  Debug "=== TEST 4: PLANNER ROOF COMPARISON (Base Wind: " + StrD(v_wind_ref, 1) + " m/s) ==="
  Debug ""
  
  ; 4a: Pitched Roof
  Wind::GetStandardTRoofLoads(h_building, Wind::#WIND_Terrain_III, v_wind_ref, Wind::#Roof_Pitched, Pitch, TotalArea, @RoofRes, rho)
  Debug "--- SATTELDACH (Gable Roof) @ 45° ---"
  Debug "Luv Side Force (Pressure): " + StrD(RoofRes\LuvForce, 0) + " N (Wind pushes down on 60m²)"
  Debug "Lee Side Force (Suction):  " + StrD(RoofRes\LeeForce, 0) + " N (Wind pulls up on 60m²)"
  Debug "Net Vertical Force:        " + StrD(RoofRes\TotalVertical, 0) + " N"
  If RoofRes\TotalVertical < 0
    Debug "-> Result: Net UPLIFT. The roof wants to LIFT off by ~" + StrD(Abs(RoofRes\TotalVertical)/9.81, 0) + " kg!"
  Else
    Debug "-> Result: Net PRESSURE. The roof is pushed DOWN onto the walls by ~" + StrD(RoofRes\TotalVertical/9.81, 0) + " kg."
  EndIf
  Debug ""
  
  ; 4b: Shed Roof
  Wind::GetStandardTRoofLoads(h_building, Wind::#WIND_Terrain_III, v_wind_ref, Wind::#Roof_Shed, Pitch, TotalArea, @RoofRes, rho)
  Debug "--- PULTDACH (Shed/Monoslope) @ 45° ---"
  Debug "Total Surface Force: " + StrD(RoofRes\LuvForce, 0) + " N (Wind hits full 120m² head-on)"
  Debug "Net Vertical Force:  " + StrD(RoofRes\TotalVertical, 0) + " N"
  If RoofRes\TotalVertical < 0
    Debug "-> Result: Net UPLIFT."
  Else
    Debug "-> Result: Net PRESSURE. Pushed DOWN by ~" + StrD(RoofRes\TotalVertical/9.81, 0) + " kg."
  EndIf
  Debug "**********************************************************************"
  Debug ""  
  
  
  ; ============================================================================
  ; TEST 5: VOLUME FLOW TO DUCT VELOCITY & PRESSURE
  ; ============================================================================
  Define FanFlow.d = 25000.0   ; Large industrial fan: 25,000 m³/h
  Define DuctDiameter.d = 0.8  ; 80 cm diameter
  Define DuctArea.d = #PI * (DuctDiameter * DuctDiameter) / 4.0
  
  Define FlowVelocity.d = Wind::VolumeFlowToVelocity(FanFlow, DuctArea)
  Define FanPressure.d = Wind::GetBasicVelocityPressure(FlowVelocity, rho)
  
  Debug "=== TEST 5: FAN TO VELOCITY & PRESSURE ==="
  Debug "Fan Volume Flow:       " + StrD(FanFlow, 0) + " m³/h"
  Debug "Duct Cross Section:    " + StrD(DuctArea, 3) + " m² (Diameter: " + StrD(DuctDiameter, 2) + "m)"
  Debug "Flow Velocity in Duct: " + StrD(FlowVelocity, 2) + " m/s (~" + StrD(FlowVelocity * 3.6, 1) + " km/h)"
  Debug "Resulting Dynamic Pressure: " + StrD(FanPressure, 1) + " Pa (N/m²)"
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 6: BACK-CALCULATING FORCE TO EQUIVALENT WIND SPEED
  ; ============================================================================
  ; Using the 90,034 N total uplift force calculated in Test 3
  Define TargetForce.d = 90034.0
  Define TargetRoofArea.d = 150.0
  Define CpeRoof.d = -0.7
  
  Define EquivWind.d = Wind::GetEquivalentWindVelocity(TargetForce, TargetRoofArea, CpeRoof, rho)
  
  Debug "=== TEST 6: WIND VELOCITY EQUIVALENT ==="
  Debug "To create an uplift force of " + StrD(TargetForce, 0) + " N on a " + StrD(TargetRoofArea, 0) + " m² flat roof:"
  Debug "A continuous free-field wind velocity of " + StrD(EquivWind, 1) + " m/s (~" + StrD(EquivWind * 3.6, 1) + " km/h) is required."
  Debug "**********************************************************************"
  Debug ""


  ; ============================================================================
  ; TEST 7: HYDRAULIC RECTANGULAR TO ROUND CONVERSION
  ; ============================================================================
  Define DuctWidth.d  = 0.40  ; 400 mm
  Define DuctHeight.d = 0.30  ; 300 mm
  Define EquivDiameter.d = Duct::GetHydraulicDiameter(DuctWidth, DuctHeight)
  
  Debug "=== TEST 7: HYDRAULIC CONVERSION FOR RECTANGULAR DUCTS ==="
  Debug "Duct Geometry: " + StrD(DuctWidth*1000, 0) + "mm x " + StrD(DuctHeight*1000, 0) + "mm"
  Debug "Calculated Hydraulic Diameter: " + StrD(EquivDiameter, 3) + " m (Matches a " + StrD(EquivDiameter*1000, 1) + "mm round pipe)"
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 8: TURBULENCE STATE AND FLOW FRICTION COEFFICIENT
  ; ============================================================================
  Define AirSpeed.d = 6.5 
  Define Re.d = Duct::GetReynoldsNumber(AirSpeed, EquivDiameter, CurrentDensity)
  Define Lambda.d = Duct::GetFrictionFactor(Re, Duct::#ROUGHNESS_STEEL_GALV, EquivDiameter)
  
  Debug "=== TEST 8: FLUID REGIME AND TURBULENCE ANALYSIS ==="
  Debug "Flow Velocity: " + StrD(AirSpeed, 1) + " m/s"
  Debug "Reynolds Number (Re): " + StrD(Re, 0)
  If Re > 2300.0
    Debug "-> Flow Regime: TURBULENT (Standard for air ventilation)"
  Else
    Debug "-> Flow Regime: LAMINAR"
  EndIf
  Debug "Calculated Darcy Friction Factor (Lambda): " + StrD(Lambda, 5)
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 9: TOTAL NETWORK PRESSURE LOSS ESTIMATION (LIVE FIELD CALCULATION)
  ; ============================================================================
  Define StretchLength.d = 25.0 
  Define LinearLoss.d = Duct::GetLinearPressureLoss(StretchLength, EquivDiameter, AirSpeed, Lambda, CurrentDensity)
  
  Define TotalZeta.d = 3.0 * 0.3 ; 3 x 90-degree duct bends
  Define ComponentLoss.d = Duct::GetLocalPressureLoss(TotalZeta, AirSpeed, CurrentDensity)
  Define TotalLoss.d = LinearLoss + ComponentLoss
  
  Debug "=== TEST 9: COMPLETE SYSTEM PRESSURE DROP OVERVIEW ==="
  Debug "Straight Duct Section Run (" + StrD(StretchLength, 1) + "m): " + StrD(LinearLoss, 1) + " Pa loss"
  Debug "Local Fittings Resistance (3x 90° Bends):        " + StrD(ComponentLoss, 1) + " Pa loss"
  Debug "----------------------------------------------------------------------"
  Debug "TOTAL STATIC PRESS DROP REQUIRED BY FAN:          " + StrD(TotalLoss, 1) + " Pa"
  Debug "**********************************************************************"
  Debug ""


  ; ============================================================================
  ; TEST 10: PURE WATER THERMAL COOLING CAPACITY
  ; ============================================================================
  Define FlowRate.d = 12.0  ; 12 m³/h flow meter measurement
  Define T_Inlet.d  = 12.0  ; 12°C return fluid
  Define T_Outlet.d = 6.0   ; 6°C supply fluid
  Define PowerWater.d = Water::GetThermalPower_kW(FlowRate, T_Inlet, T_Outlet, Water::#Glycol_None, 0.0)
  
  Debug "=== TEST 10: PURE WATER THERMAL POWER ==="
  Debug "Flow Rate: " + StrD(FlowRate, 1) + " m³/h with DeltaT: " + StrD(Abs(T_Inlet - T_Outlet), 1) + " K"
  Debug "Calculated Cooling Power: " + StrD(PowerWater, 1) + " kW"
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 11: PROPYLENE GLYCOL MIXTURE CORRECTION (SOLAR / HVAC STANDARD)
  ; ============================================================================
  Define PowerGlycol.d
  Define AntifreezePercent.d = 35.0
  PowerGlycol = Water::GetThermalPower_kW(FlowRate, T_Inlet, T_Outlet, Water::#Glycol_Propylene, AntifreezePercent)
  
  Debug "=== TEST 11: GLYCOL MIXTURE CORRECTION (35% PROPYLENE) ==="
  Debug "Flow Rate: " + StrD(FlowRate, 1) + " m³/h with DeltaT: " + StrD(Abs(T_Inlet - T_Outlet), 1) + " K"
  Debug "Calculated Cooling Power: " + StrD(PowerGlycol, 1) + " kW"
  Debug "-> Actual thermal performance dropped by: " + StrD(PowerWater - PowerGlycol, 1) + " kW (" + StrD(((PowerWater-PowerGlycol)/PowerWater)*100,1) + " % reduction!)"
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 12: HYDRAULIC PIPE FLOW VELOCITY CHECKS
  ; ============================================================================
  Define PipeDN.d = 0.065 ; DN65 Pipe
  Define WaterVelocity.d = Water::VolumeFlowToVelocity(FlowRate, PipeDN)
  
  Debug "=== TEST 12: HYDRAULIC PIPE FLOW VELOCITY ==="
  Debug "Flow Rate: " + StrD(FlowRate, 1) + " m³/h through DN65 Pipe"
  Debug "Velocity: " + StrD(WaterVelocity, 2) + " m/s"
  Debug "**********************************************************************"
  Debug ""


  ; ============================================================================
  ; TEST 13: THE ECO-MODE DEMO (SPEED REDUCTION TO 40 HZ)
  ; ============================================================================
  Define NominalHz.d = 50.0
  Define NominalFlow.d = 8000.0   
  Define NominalPress.d = 600.0   
  Define NominalPower.d = 4.0     
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
  Debug "-> That is a massive " + StrD(((NominalPower - EcoResult\NewPower)/NominalPower)*100, 1) + "% energy reduction!"
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 14: TARGET SETPOINT BACK-CALCULATION
  ; ============================================================================
  Define TargetFlow.d = 10000.0
  Define RequiredHz.d = AffinityLaws::GetRequiredSpeedForFlow(NominalHz, NominalFlow, TargetFlow)
  Define RequiredPower.d = AffinityLaws::GetNewPower(NominalPower, NominalHz, RequiredHz)
  
  Debug "=== TEST 14: SPEED BACK-CALCULATION FOR TARGET FLOW ==="
  Debug "Desired Volume Flow Target: " + StrD(TargetFlow, 0) + " m³/h"
  Debug "----------------------------------------------------------------------"
  Debug "Required Frequency on Frequency Inverter: " + StrD(RequiredHz, 2) + " Hz"
  Debug "Estimated New Power Consumption:          " + StrD(RequiredPower, 2) + " kW"
  Debug "**********************************************************************"
  Debug ""


  ; ============================================================================
  ; TEST 15: VALVE SIZING AND DYNAMIC KV CALCULATION
  ; ============================================================================
  Define MeasuredFlow.d  = 5.0    
  Define Valve_dp.d      = 15000.0 
  Define Loop_dp_total.d = 100000.0 
  Define InstalledKvs.d  = 16.0   
  Define RequiredKv.d = Valves::CalculateKv(MeasuredFlow, Valve_dp, WaterDensity)
  
  Debug "=== TEST 15: LIVE CONTROL VALVE ANALYSIS ==="
  Debug "Measured Flow: " + StrD(MeasuredFlow, 1) + " m³/h | Valve deltaP: " + StrD(Valve_dp/1000, 1) + " kPa"
  Debug "-> Required Kv: " + StrD(RequiredKv, 2) + " m³/h"
  Debug "The physically installed valve size has a max capacity of: Kvs " + StrD(InstalledKvs, 1)
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 16: HYDRAULIC VALVE AUTHORITY
  ; ============================================================================
  Define Authority.d = Valves::GetValveAuthority(Valve_dp, Loop_dp_total)
  Define OpeningPercent.d = Valves::GetLinearOpeningPercent(RequiredKv, InstalledKvs)
  
  Debug "=== TEST 16: VALVE AUTHORITY & STABILITY CHECK ==="
  Debug "Calculated Valve Authority (a): " + StrD(Authority, 2)
  Debug "Effective control valve opening position for this flow: " + StrD(OpeningPercent, 1) + " %"
  Debug "**********************************************************************"
  Debug ""


  ; ============================================================================
  ; TEST 17: LOGARITHMIC SOUND LEVEL ADDITION
  ; ============================================================================
  Define SingleMachineLevel.d = 65.0 
  Define CombinedLevel.d = Acoustics::AddTwoSoundLevels(SingleMachineLevel, SingleMachineLevel)
  
  Debug "=== TEST 17: LOGARITHMIC SOUND ADDITION ==="
  Debug "One running machine emits:   " + StrD(SingleMachineLevel, 1) + " dB"
  Debug "Two identical machines emit: " + StrD(CombinedLevel, 1) + " dB"
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 18: DISTANCE DISSIPATION (FREE FIELD ENVIRONMENT)
  ; ============================================================================
  Define MachineRoomLevel.d = 85.0 
  Define EvaluationDistance.d = 15.0 
  Define ResidentialLevel.d = Acoustics::GetDistanceAttenuation(MachineRoomLevel, EvaluationDistance)
  
  Debug "=== TEST 18: SOUND ATTENUATION OVER DISTANCE ==="
  Debug "Sound level at 1 meter: " + StrD(MachineRoomLevel, 1) + " dB"
  Debug "Calculated level at " + StrD(EvaluationDistance, 1) + " meters distance: " + StrD(ResidentialLevel, 1) + " dB"
  Debug "**********************************************************************"
  Debug ""
  
  
  ; ============================================================================
  ; TEST 19: AERODYNAMIC DUCT REGENERATION AIRFLOW NOISE
  ; ============================================================================
  Define AirVelocity.d = 9.5  
  Define DuctSection.d = 0.5 * 0.4 
  Define GeneratedNoise.d = Acoustics::EstimateDuctAirflowNoise(AirVelocity, DuctSection)
  
  Debug "=== TEST 19: AERODYNAMIC FLOW REGENERATION NOISE ==="
  Debug "Duct Air Velocity: " + StrD(AirVelocity, 1) + " m/s through a " + StrD(DuctSection, 2) + " m² channel section"
  Debug "Estimated resulting flow-generated noise level (L_w): " + StrD(GeneratedNoise, 1) + " dB"
  Debug "**********************************************************************"
  Debug ""
  
  ; ============================================================================
  ; TEST 20: COMPARISON - GALVANIZED RECTANGULAR VS STAINLESS ROUND KAMINROHR
  ; ============================================================================
  Define SystemFlow.d = 3000.0
  Define PipeRunLength.d = 20.0
  ; Option A: Rectangular Galvanized
  Define RectArea.d = 0.5 * 0.3
  Define RectHydrDiam.d = Duct::GetHydraulicDiameter(0.5, 0.3)
  Define RectVel.d = (SystemFlow / 3600.0) / RectArea
  Define Lambda_Rect.d = Duct::GetFrictionFactor(Duct::GetReynoldsNumber(RectVel, RectHydrDiam, CurrentDensity), Duct::#ROUGHNESS_STEEL_GALV, RectHydrDiam)
  Define Loss_Rect.d = Duct::GetLinearPressureLoss(PipeRunLength, RectHydrDiam, RectVel, Lambda_Rect, CurrentDensity)
  ; Option B: Round Stainless Kaminrohr
  Define RoundDiam.d = 0.40
  Define RoundArea.d = Duct::GetRoundPipeArea(RoundDiam)
  Define RoundVel.d = (SystemFlow / 3600.0) / RoundArea
  Define Lambda_Round.d = Duct::GetFrictionFactor(Duct::GetReynoldsNumber(RoundVel, RoundDiam, CurrentDensity), Duct::#ROUGHNESS_STEEL_STAIN, RoundDiam)
  Define Loss_Round.d = Duct::GetLinearPressureLoss(PipeRunLength, RoundDiam, RoundVel, Lambda_Round, CurrentDensity)
  Debug "=== TEST 20: RECTANGULAR GALVANIZED VS ROUND STAINLESS (KAMINROHR) ==="
  Debug "Volume Flow Rate: " + StrD(SystemFlow, 0) + " m³/h over " + StrD(PipeRunLength, 1) + " meters"
  Debug "----------------------------------------------------------------------"
  Debug "OPTION A: Galvanized Rectangular Duct (500x300mm) Loss: " + StrD(Loss_Rect, 1) + " Pa"
  Debug "OPTION B: Round Stainless Steel Kaminrohr (DN400) Loss: " + StrD(Loss_Round, 1) + " Pa"
  Debug "-> Friction pressure drop reduction: " + StrD(((Loss_Rect-Loss_Round)/Loss_Rect) * 100, 1) + "%!"
  Debug "*********************************************************************"
  Debug ""
  
  ; ============================================================================
  ; TEST 21: EMBEDDED DATASECTION INITIALIZATION (DUCT DB)
  ; ============================================================================
  Define ItemsLoaded.i = Duct::InitDatabase()
  Debug "=== TEST 21: EMBEDDED DATASECTION INITIALIZATION ==="
  Debug "Successfully loaded " + Str(ItemsLoaded) + " components into memory."
  Debug "----------------------------------------------------------------------"
  ForEach Duct::Fittings()
  Debug "-> Component: " + LSet(Duct::Fittings()\Name, 35) + " | Zeta: " + StrD(Duct::Fittings()\Zeta, 2)
  Next
  Debug "**********************************************************************"
  Debug ""
  
  ; ============================================================================
  ; TEST 22: LIVE FIELD DATABASE QUERY
  ; ============================================================================
  Define SelectedComponent.s = "90° Bend (Standard R=D)"
  Define TestVelocity.d = 5.0
  Define FoundZeta.d = Duct::GetZetaByName(SelectedComponent)
  Define ComponentPressureDrop.d = Duct::GetLocalPressureLoss(FoundZeta, TestVelocity, CurrentDensity)
  Debug "=== TEST 22: LIVE FIELD DATABASE QUERY ==="
  Debug "User selected component: '" + SelectedComponent + "'"
  Debug "Retrieved Zeta Value:    " + StrD(FoundZeta, 2)
  Debug "Calculated component loss at " + StrD(TestVelocity, 1) + " m/s: " + StrD(ComponentPressureDrop, 1) + " Pa"
  Debug "**********************************************************************"
  Debug ""
  
  ; ============================================================================
  ; TEST 23: GEOMETRY DATABASE FILTERING FOR GUI COMBOBOXES
  ; ============================================================================
  
  ; We create a local list for the filtered output
  NewList GuiDropdownList.Duct::Fitting()
  
  ; The user selected "Round Pipe" in the UI -> we filter exclusively for #Geom_Round
  Define Matches.i = Duct::FilterFittings(Duct::#Geom_Round, GuiDropdownList())
  
  Debug "=== TEST 23: DYNAMIC GEOMETRY FILTERING FOR UI ==="
  Debug "Filtering database for ROUND pipe components..."
  Debug "Found " + Str(Matches) + " matching components."
  Debug "----------------------------------------------------------------------"
  
  ForEach GuiDropdownList()
    ; The names are now clean, without ugly prefixes!
    Debug "-> UI ComboBox Entry: " + LSet(GuiDropdownList()\Name, 32) + " | Zeta: " + StrD(GuiDropdownList()\Zeta, 2)
  Next
  Debug "**********************************************************************"
  Debug ""

CompilerEndIf
; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 112
; FirstLine = 94
; Folding = -
; DPIAware
; CPU = 5