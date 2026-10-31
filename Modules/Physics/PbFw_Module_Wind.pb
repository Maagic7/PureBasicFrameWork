; ===========================================================================
;  FILE: PbFw_Module_Wind.pb
;  NAME: Module Wind [Wind::]
;  DESC: Modul for Wind and Airflow calculations
;  DESC: 
;  SOURCES: td_lib from Bernd Kuemmel
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

; XIncludeFile "PbFw_Module_Wind.pb"         ; Wind::     Wind and Airflow calculations

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_AIR.pb"         ; AIR::     Air Thermodynamics 

DeclareModule Wind
  EnableExplicit
  
  ; Standard air density at sea level and 15°C in kg/m³
  #WIND_DEFAULT_AIR_DENSITY = 1.25 
  
  ; Terrain Categories according to Eurocode 1 (EN 1991-1-4)
  Enumeration TerrainCategory
    #WIND_Terrain_I   ; Lakes or area with negligible vegetation
    #WIND_Terrain_II  ; Area with low vegetation and isolated obstacles (e.g. fields)
    #WIND_Terrain_III ; Area with regular cover of vegetation or buildings (e.g. villages, suburbs)
    #WIND_Terrain_IV  ; Area with dense city structures (at least 15% of surface > 15m height)
  EndEnumeration
  
  ; Standard Aerodynamic Shape Coefficients (c_pe) for quick planning reference
  #WIND_CPE_WALL_PRESSURE =  0.8 ; Windward side (Luv)
  #WIND_CPE_WALL_SUCTION  = -0.5 ; Leeward side (Lee)
  #WIND_CPE_ROOF_SUCTION  = -0.7 ; Average suction on flat/standard roofs

  ; Structures
  Structure TBuildingLoad
    PressureWall.d ; Direct pressure force on windward wall [N]
    SuctionWall.d  ; Suction force on leeward wall [N]
    SuctionRoof.d  ; Suction force lifting the roof [N]
  EndStructure

  ; Public Functions - Structural & Pressure (Bauphysik)
  Declare.d GetBasicVelocityPressure(Velocity.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  Declare.d GetExposureFactor(Height.d, Category.i)
  Declare.d GetPeakVelocityPressure(Height.d, Category.i, BasicVelocity.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  Declare.d GetSurfaceForce(Pressure.d, Area.d, cpe.d)
  Declare.i GetStandardTBuildingLoads(Height.d, Category.i, BasicVelocity.d, WallArea.d, RoofArea.d, *outLoads.TBuildingLoad, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  Declare.d GetConvectiveHeatTransferCoefficient(Velocity.d)
  Declare.d GetHeatFlowRate(Area.d, TempSurface.d, TempFluid.d, Velocity.d)
  
  ; Public Functions - Mass & Flow (Fans / Ventilatoren)
  Declare.d GetVolumeFlowRate(Area.d, Velocity.d)
  Declare.d GetMassFlowRate(Area.d, Velocity.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  Declare.d GetKineticPower(Area.d, Velocity.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  
    ; Roof types for aerodynamic distinction
  Enumeration RoofType
    #Roof_Flat        ; Flat roof (< 5 degrees)
    #Roof_Shed        ; Pultdach (Monoslope / Shed roof)
    #Roof_Pitched     ; Satteldach / Spitzdach (Gable / Pitched roof)
  EndEnumeration

  ; Structure to output specific roof wind forces
  Structure TRoofLoad
    LuvForce.d        ; Force on windward slope [N] (Positive = Pressure, Negative = Suction)
    LeeForce.d        ; Force on leeward slope [N] (Always Suction/Negative, 0 for Pultdach)
    TotalVertical.d   ; Resulting net vertical force [N] (Negative = Uplift/Lifting force)
  EndStructure

  Declare.i GetStandardTRoofLoads(Height.d, Category.i, BasicVelocity.d, RoofType.i, Angle.d, RoofArea.d, *outLoads.TRoofLoad, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  
  Declare.d VolumeFlowToVelocity(VolumeFlow_m3h.d, CrossSectionAreaM2.d)
  Declare.d GetEquivalentWindVelocity(Force.d, Area.d, cpe.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)

EndDeclareModule

Module Wind
  EnableExplicit
  
  Structure TerrainParam
    z0.d
    zmin.d
  EndStructure

  Procedure _GetTerrainParameters(Category.i, *Params.TerrainParam)
  ; ======================================================================
  ; NAME: GetTerrainParameters
  ; DESC: Internal helper to fetch Eurocode 1 terrain roughness settings
  ; VAR(Category.i): Terrain category enumeration (#Terrain_I to #Terrain_IV)
  ; VAR(*Params.TerrainParam): Pointer to target structure receiving parameters
  ; RET: None
  ; ======================================================================
    Select Category
      Case #WIND_Terrain_I   
        *Params\z0 = 0.01 
        *Params\zmin = 1.0
      Case #WIND_Terrain_III 
        *Params\z0 = 0.3  
        *Params\zmin = 5.0
      Case #WIND_Terrain_IV  
        *Params\z0 = 1.0 
        *Params\zmin = 10.0
      Default           
        *Params\z0 = 0.05 
        *Params\zmin = 2.0 ; Category II (Standard Reference)
    EndSelect
  EndProcedure

  Procedure.d GetBasicVelocityPressure(Velocity.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  ; ======================================================================
  ; NAME: GetBasicVelocityPressure
  ; DESC: Calculates raw dynamic wind pressure without obstacle distortion
  ; VAR(Velocity.d): Wind speed [m/s]
  ; VAR(AirDensity.d): Density of air [kg/m³] (Defaults to 1.25)
  ; RET.d: Basic velocity pressure q_b [Pa] (N/m²)
  ; ======================================================================
    ProcedureReturn 0.5 * AirDensity * (Velocity * Velocity)
  EndProcedure
  
  Procedure.d GetExposureFactor(Height.d, Category.i)
  ; ======================================================================
  ; NAME: GetExposureFactor
  ; DESC: Calculates terrain exposure factor c_e(z) according to EN 1991-1-4
  ; VAR(Height.d): Building height above ground [m]
  ; VAR(Category.i): Terrain category enumeration (#Terrain_I to #Terrain_IV)
  ; RET.d: Dimensionless exposure factor c_e(z)
  ; ======================================================================
    Protected Params.TerrainParam
    Protected z0_II.d = 0.05 ; Reference roughness for Category II
    Protected kr.d, cr.d, z.d
    
    _GetTerrainParameters(Category, Params)
    
    ; Boundary height checks according to Eurocode standards
    z = Height
    If z < Params\zmin : z = Params\zmin : EndIf
    If z > 200.0       : z = 200.0       : EndIf
    
    ; kr: Terrain factor / cr: Roughness factor
    kr = 0.19 * Pow(Params\z0 / z0_II, 0.07)
    cr = kr * Log(z / Params\z0)
    
    ; Returns c_e(z) assuming flat or moderately sloped ground conditions
    ProcedureReturn (cr * cr) + (7.0 * kr * cr)
  EndProcedure

  Procedure.d GetPeakVelocityPressure(Height.d, Category.i, BasicVelocity.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  ; ======================================================================
  ; NAME: GetPeakVelocityPressure
  ; DESC: Calculates peak velocity pressure q_p(z) including gusts (EN 1991-1-4)
  ; VAR(Height.d): Structural evaluation height [m]
  ; VAR(Category.i): Terrain category enumeration (#Terrain_I to #Terrain_IV)
  ; VAR(BasicVelocity.d): Reference wind velocity zone speed [m/s]
  ; VAR(AirDensity.d): Density of air [kg/m³] (Defaults to 1.25)
  ; RET.d: Peak velocity pressure q_p [Pa] (N/m²)
  ; ======================================================================
    ProcedureReturn GetExposureFactor(Height, Category) * GetBasicVelocityPressure(BasicVelocity, AirDensity)
  EndProcedure
  
  Procedure.d GetSurfaceForce(Pressure.d, Area.d, cpe.d)
  ; ======================================================================
  ; NAME: GetSurfaceForce
  ; DESC: Converts pressure into physical force acting on a defined area
  ; VAR(Pressure.d): Wind pressure acting on the zone [Pa]
  ; VAR(Area.d): Surface area size [m²]
  ; VAR(cpe.d): Aerodynamic external pressure shape coefficient [-]
  ; RET.d: Resulting total force [N]
  ; ======================================================================
    ProcedureReturn Pressure * Area * cpe
  EndProcedure
  
  Procedure.i GetStandardTBuildingLoads(Height.d, Category.i, BasicVelocity.d, WallArea.d, RoofArea.d, *outLoads.TBuildingLoad, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  ; ======================================================================
  ; NAME: GetStandardBuildingLoads
  ; DESC: Rough estimation of main wind forces on flat standard buildings
  ; VAR(Height.d): Building height [m]
  ; VAR(Category.i): Terrain category enumeration (#Terrain_I to #Terrain_IV)
  ; VAR(BasicVelocity.d): Base wind zone velocity [m/s]
  ; VAR(WallArea.d): Area of the front/rear wall vertical profile [m²]
  ; VAR(RoofArea.d): Area of the horizontal roof layout [m²]
  ; VAR(*Loads.BuildingLoad): Pointer to structure receiving the output values
  ; VAR(AirDensity.d): Density of air [kg/m³] (Defaults to 1.25)
  ; RET.i: #True if successful, #False if pointer is invalid
  ; ======================================================================
    Protected q_p.d = GetPeakVelocityPressure(Height, Category, BasicVelocity, AirDensity)
    
    If *outLoads = 0 : ProcedureReturn #False : EndIf
    
    *outLoads\PressureWall = GetSurfaceForce(q_p, WallArea, #WIND_CPE_WALL_PRESSURE)
    *outLoads\SuctionWall  = GetSurfaceForce(q_p, WallArea, #WIND_CPE_WALL_SUCTION)
    *outLoads\SuctionRoof  = GetSurfaceForce(q_p, RoofArea, #WIND_CPE_ROOF_SUCTION)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.d GetConvectiveHeatTransferCoefficient(Velocity.d)
  ; ======================================================================
  ; NAME: GetConvectiveHeatTransferCoefficient
  ; DESC: Estimates convective heat coefficient alpha based on air velocity
  ; VAR(Velocity.d): Air stream velocity over the surface [m/s]
  ; RET.d: Heat transfer coefficient alpha [W/(m²K)]
  ; ======================================================================
    If Velocity < 5.0
      ProcedureReturn 4.0 + (4.0 * Velocity)
    Else
      ProcedureReturn 7.3 * Pow(Velocity, 0.78)
    EndIf
  EndProcedure
  
  Procedure.d GetHeatFlowRate(Area.d, TempSurface.d, TempFluid.d, Velocity.d)
  ; ======================================================================
  ; NAME: GetHeatFlowRate
  ; DESC: Calculates active convective heat energy flow between solid and fluid
  ; VAR(Area.d): Surface area where transmission happens [m²]
  ; VAR(TempSurface.d): Temperature of the solid surface [°C] or [K]
  ; VAR(TempFluid.d): Temperature of the moving air [°C] or [K]
  ; VAR(Velocity.d): Air stream velocity [m/s]
  ; RET.d: Thermal heat flow power Q_dot [W]
  ; ======================================================================
    ProcedureReturn GetConvectiveHeatTransferCoefficient(Velocity) * Area * Abs(TempSurface - TempFluid)
  EndProcedure
  
  Procedure.d GetVolumeFlowRate(Area.d, Velocity.d)
  ; ======================================================================
  ; NAME: GetVolumeFlowRate
  ; DESC: Calculates air volume displacement per second through an opening
  ; VAR(Area.d): Fan or opening cross-section area [m²]
  ; VAR(Velocity.d): Flow velocity through the cross-section [m/s]
  ; RET.d: Volume flow rate V_dot [m³/s]
  ; ======================================================================
    ProcedureReturn Area * Velocity
  EndProcedure
  
  Procedure.d GetMassFlowRate(Area.d, Velocity.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  ; ======================================================================
  ; NAME: GetMassFlowRate
  ; DESC: Calculates total air weight moving through a system per second
  ; VAR(Area.d): Fan opening cross-section area [m²]
  ; VAR(Velocity.d): Flow velocity [m/s]
  ; VAR(AirDensity.d): Density of air [kg/m³] (Defaults to 1.25)
  ; RET.d: Mass flow rate m_dot [kg/s]
  ; ======================================================================
    ProcedureReturn GetVolumeFlowRate(Area, Velocity) * AirDensity
  EndProcedure
  
  Procedure.d GetKineticPower(Area.d, Velocity.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  ; ======================================================================
  ; NAME: GetKineticPower
  ; DESC: Calculates total raw kinetic energy available inside the moving air
  ; VAR(Area.d): Effective cross-section area [m²]
  ; VAR(Velocity.d): Flow velocity [m/s]
  ; VAR(AirDensity.d): Density of air [kg/m³] (Defaults to 1.25)
  ; RET.d: Kinetic power P_kin [W]
  ; ======================================================================
    ProcedureReturn 0.5 * GetMassFlowRate(Area, Velocity, AirDensity) * (Velocity * Velocity)
  EndProcedure
  
  Procedure.i GetStandardTRoofLoads(Height.d, Category.i, BasicVelocity.d, RoofType.i, Angle.d, RoofArea.d, *outLoads.TRoofLoad, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  ; ======================================================================
  ; NAME: GetStandardRoofLoads
  ; DESC: Calculates reference wind forces on roofs based on type and slope angle
  ; VAR(Height.d): Height of the roof structure above ground [m]
  ; VAR(Category.i): Terrain category enumeration (#Terrain_I to #Terrain_IV)
  ; VAR(BasicVelocity.d): Base wind zone velocity [m/s]
  ; VAR(RoofType.i): Type of roof (#Roof_Flat, #Roof_Shed, #Roof_Pitched)
  ; VAR(Angle.d): Roof inclination angle in degrees [°]
  ; VAR(RoofArea.d): Total true surface area of the roof [m²]
  ; VAR(*Loads.RoofLoad): Pointer to structure receiving the output forces
  ; VAR(AirDensity.d): Density of air [kg/m³] (Defaults to 1.25)
  ; RET.i: #True if calculation successful, #False if pointer is invalid
  ; ======================================================================
    Protected q_p.d = GetPeakVelocityPressure(Height, Category, BasicVelocity, AirDensity)
    Protected cpe_luv.d = 0.0
    Protected cpe_lee.d = 0.0
    Protected AreaLuv.d = RoofArea
    Protected AreaLee.d = 0.0
    
    If *outLoads = 0 : ProcedureReturn #False : EndIf
    
    ; Force flat roof handling if angle is negligible
    If Angle < 5.0 : RoofType = #Roof_Flat : EndIf
    
    Select RoofType
        
      Case #Roof_Flat
        cpe_luv = -0.7 ; Uniform suction over flat area
        cpe_lee = 0.0
        AreaLuv = RoofArea
        AreaLee = 0.0
        
      Case #Roof_Shed ; --- PULTDACH ---
        ; Interpolated approximation for monoslope roofs (Wind hitting low side blowing up)
        If Angle <= 15.0
          cpe_luv = -0.5
        ElseIf Angle <= 30.0
          cpe_luv = 0.2  ; Shift to wind pressure
        Else
          cpe_luv = 0.5  ; High wind pressure
        EndIf
        cpe_lee = 0.0    ; Monoslope has only one primary roof surface
        AreaLuv = RoofArea
        AreaLee = 0.0
        
      Case #Roof_Pitched ; --- SATTELDACH / SPITZDACH ---
        ; Roof is split into two halves (Luv and Lee)
        AreaLuv = RoofArea * 0.5
        AreaLee = RoofArea * 0.5
        
        ; Leeward side always experiences suction
        cpe_lee = -0.4
        
        ; Windward side depends strictly on pitch angle
        If Angle <= 15.0
          cpe_luv = -0.3 ; Slight suction due to aerodynamic lift
        ElseIf Angle <= 30.0
          cpe_luv = 0.2  ; Moderate transition to pressure
        Else
          cpe_luv = 0.6  ; Heavy direct frontal pressure
        EndIf
        
    EndSelect
    
    ; 1. Calculate absolute surface forces
    *outLoads\LuvForce = GetSurfaceForce(q_p, AreaLuv, cpe_luv)
    *outLoads\LeeForce = GetSurfaceForce(q_p, AreaLee, cpe_lee)
    
    ; 2. Calculate net vertical force component (relevant for roof anchoring/weight)
    ; Force vector points perpendicular to slope -> Cos(Angle) projects to vertical
    Protected RadAngle.d = Angle * (#PI / 180.0)
    *outLoads\TotalVertical = (*outLoads\LuvForce + *outLoads\LeeForce) * Cos(RadAngle)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.d VolumeFlowToVelocity(VolumeFlow_m3h.d, CrossSectionAreaM2.d)
  ; ======================================================================
  ; NAME: VolumeFlowToVelocity
  ; DESC: Calculates the flow velocity from a given volume flow and area
  ; VAR(VolumeFlow_m3h.d): Volume flow rate [m³/h]
  ; VAR(CrossSectionArea.d): Cross-section area of fan/duct [m²]
  ; RET.d: Resulting flow velocity [m/s]
  ; ======================================================================
   Protected VolumeFlow_m3s.d
    
    If CrossSectionAreaM2 <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; Convert m³/h to m³/s (Internal conversion / Division by 3600)
    VolumeFlow_m3s = VolumeFlow_m3h / 3600.0
    
    ; v = V_dot / A
    ProcedureReturn VolumeFlow_m3s / CrossSectionAreaM2
  EndProcedure

  Procedure.d GetEquivalentWindVelocity(Force.d, Area.d, cpe.d, AirDensity.d = #WIND_DEFAULT_AIR_DENSITY)
  ; ======================================================================
  ; NAME: GetEquivalentWindVelocity
  ; DESC: Calculates the wind speed required to generate a specific force
  ; VAR(Force.d): The target force acting on the surface [N]
  ; VAR(Area.d): The surface area [m²]
  ; VAR(cpe.d): Aerodynamic shape coefficient [-]
  ; VAR(AirDensity.d): Density of air [kg/m³] (Defaults to 1.25)
  ; RET.d: Required wind velocity [m/s]
  ; ======================================================================
    Protected RequiredPressure.d
    
    If Area <= 0.0 Or cpe = 0.0 Or AirDensity <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; F = q * A * cpe  ->  q = F / (A * cpe)
    RequiredPressure = Abs(Force) / (Area * Abs(cpe))
    
    ; q = 0.5 * rho * v² ->  v = Sqrt(2 * q / rho)
    ProcedureReturn Sqr((2.0 * RequiredPressure) / AirDensity)
  EndProcedure

EndModule

; --- Complete Module Test Application ---
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  Procedure Test_DE()
    ; --- Complete Module Test Application GERMAN ---
    
    Define rho.d = 1.25 
    
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
    
    Debug "=== TEST 3: DETAIL-WINDLASTBERECHNUNG DACH ==="
    Debug "Spitzendruck (q_p) in " + StrD(DachHoehe, 1) + "m Höhe: " + StrD(q_p_roof, 1) + " Pa (N/m²)"
    Debug "----------------------------------------"
    Debug "Sogkraft Randbereiche (30 m²): " + StrD(Abs(KraftRand), 0) + " N (~" + StrD(Abs(KraftRand)/9.81, 0) + " kg)"
    Debug "Sogkraft Innenbereich (120 m²): " + StrD(Abs(KraftMitte), 0) + " N (~" + StrD(Abs(KraftMitte)/9.81, 0) + " kg)"
    Debug "----------------------------------------"
    Debug "Gesamte Abhebekraft auf das Dach: " + StrD(Abs(GesamtSog), 0) + " N (~" + StrD(Abs(GesamtSog)/9.81, 0) + " kg)"
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
    Debug "Fan Volume Flow:     " + StrD(FanFlow, 0) + " m³/h"
    Debug "Duct Cross Section:  " + StrD(DuctArea, 3) + " m² (Diameter: " + StrD(DuctDiameter, 2) + "m)"
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
  EndProcedure
  
  Procedure Test_EN()
  ; --- Complete Module Test Application ENGLISH ---
  
    ; Standard air density as a fixed baseline for these reference tests
    Define rho.d = 1.25 
    
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
    
    ; 4a: Pitched Roof (Gable Roof)
    Wind::GetStandardTRoofLoads(h_building, Wind::#WIND_Terrain_III, v_wind_ref, Wind::#Roof_Pitched, Pitch, TotalArea, @RoofRes, rho)
    Debug "--- GABLE ROOF (Satteldach) @ 45° ---"
    Debug "Luv Side Force (Pressure): " + StrD(RoofRes\LuvForce, 0) + " N (Wind pushes down on 60m²)"
    Debug "Lee Side Force (Suction):  " + StrD(RoofRes\LeeForce, 0) + " N (Wind pulls up on 60m²)"
    Debug "Net Vertical Force:        " + StrD(RoofRes\TotalVertical, 0) + " N"
    If RoofRes\TotalVertical < 0
      Debug "-> Result: Net UPLIFT. The roof wants to LIFT off by ~" + StrD(Abs(RoofRes\TotalVertical)/9.81, 0) + " kg!"
    Else
      Debug "-> Result: Net PRESSURE. The roof is pushed DOWN onto the walls by ~" + StrD(RoofRes\TotalVertical/9.81, 0) + " kg."
    EndIf
    Debug ""
    
    ; 4b: Shed Roof (Monoslope Roof)
    Wind::GetStandardTRoofLoads(h_building, Wind::#WIND_Terrain_III, v_wind_ref, Wind::#Roof_Shed, Pitch, TotalArea, @RoofRes, rho)
    Debug "--- SHED ROOF (Pultdach) @ 45° ---"
    Debug "Total Surface Force: " + StrD(RoofRes\LuvForce, 0) + " N (Wind hits full 120m² head-on)"
    Debug "Net Vertical Force:  " + StrD(RoofRes\TotalVertical, 0) + " N"
    If RoofRes\TotalVertical < 0
      Debug "-> Result: Net UPLIFT."
    Else
      Debug "-> Result: Net PRESSURE. Pushed DOWN by ~" + StrD(RoofRes\TotalVertical/9.81, 0) + " kg."
    EndIf
    Debug "**********************************************************************"
    
    
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
  EndProcedure
  
  ; Test_DE()
  Test_EN()
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 29
; FirstLine = 5
; Folding = ----
; DPIAware
; CPU = 5