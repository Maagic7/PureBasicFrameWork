; ===========================================================================
;  FILE: PbFw_Module_Duct.pb
;  NAME: Module Duct [Duct::]
;  DESC: Modul for fluid dynamics, duct pressure loss & embedded fittings database
;  DESC: 
;  SOURCES: 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/10/26
; COAUTHOR :  AI Assistant (Gemini)
; VERSION  :  0.5 pretested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;   2026/10/26 - Initial structured version including hydraulic conversions,
;                Reynolds turbulence analysis, and linear/local friction drops.
;}
;{ TODO:
;   - Cross-check duplicate constants when integrating with internal Fluid modules.
;}
; ===========================================================================

DeclareModule Duct
  EnableExplicit
  
  ; Standard absolute roughness (k) in mm for typical materials
  #ROUGHNESS_PVC_PLASTIC = 0.005 ; Smooth plastic pipes
  #ROUGHNESS_STEEL_STAIN = 0.015 ; Smooth stainless steel pipes (Modern Chimney/Kaminrohr)
  #ROUGHNESS_STEEL_GALV  = 0.15  ; Standard galvanized spiral seam ducts (Wickelfalzrohr)
  #ROUGHNESS_CONCRETE    = 2.0   ; Rough concrete shafts
  
  ; Dynamic viscosity of standard air at 20°C in Pa*s
  #AIR_VISCOSITY_20C = 0.0000182

  ; Geometry Flags for Fittings Filtering
  Enumeration GeometryType
    #Geom_All   = 0
    #Geom_Round = 1
    #Geom_Rect  = 2
    #Geom_Oval  = 3 ; Reserved for future extension
  EndEnumeration

  ; Structure for embedded fitting database (Updated with Type)
  Structure Fitting
    Name.s
    Zeta.d
    Type.i ; Holds #Geom_Round or #Geom_Rect
  EndStructure

  ; Public Functions - Fitting Database Access (GUI Ready)
  Declare.i InitDatabase()
  Declare.d GetZetaByName(FittingName.s)
  Declare.i FilterFittings(GeometryFilter.i, List OutputList.Fitting())

  ; Public Functions - Geometry & Fluids
  Declare.d GetHydraulicDiameter(Width.d, Height.d)
  Declare.d GetRoundPipeArea(Diameter_m.d)
  Declare.d GetReynoldsNumber(Velocity.d, Diameter_m.d, AirDensity.d)
  Declare.d GetFrictionFactor(Reynolds.d, Roughness_mm.d, Diameter_m.d)
  Declare.d GetLinearPressureLoss(Length.d, Diameter_m.d, Velocity.d, FrictionFactor.d, AirDensity.d)
  Declare.d GetLocalPressureLoss(Zeta.d, Velocity.d, AirDensity.d)
    
  ; Global list that holds the pre-loaded data
  Global NewList Fittings.Fitting()
  
EndDeclareModule

Module Duct
  EnableExplicit
  
  ; Geometry and fluid procedures
  Procedure.d GetHydraulicDiameter(Width.d, Height.d)
  ; ======================================================================
  ; NAME: GetHydraulicDiameter
  ; DESC: Calculates the hydraulic diameter for rectangular ducts: D_h = 4*A / P
  ; VAR(Width.d): Duct inner width [m]
  ; VAR(Height.d): Duct inner height [m]
  ; RET.d: Hydraulic diameter [m] (Equivalent to a round pipe size)
  ; ======================================================================
   If (Width + Height) <= 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn (4.0 * (Width * Height)) / (2.0 * (Width + Height))
  EndProcedure

  Procedure.d GetRoundPipeArea(Diameter_m.d)
  ; ======================================================================
  ; NAME: GetRoundPipeArea
  ; DESC: Calculates the cross-section area of a round pipe: A = PI * r²
  ; VAR(Diameter_m.d): Pipe inner diameter [m]
  ; RET.d: Cross-section area [m²]
  ; ======================================================================
    If Diameter_m <= 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn #PI * (Diameter_m * Diameter_m) / 4.0
  EndProcedure

  Procedure.d GetReynoldsNumber(Velocity.d, Diameter_m.d, AirDensity.d)
  ; ======================================================================
  ; NAME: GetReynoldsNumber
  ; DESC: Calculates Reynolds number to check fluid turbulence state:
  ;       Re = (rho * v * d) / eta
  ; VAR(Velocity.d): Fluid speed inside the duct [m/s]
  ; VAR(Diameter_m.d): Round pipe or hydraulic diameter [m]
  ; VAR(AirDensity.d): Current air density [kg/m³]
  ; RET.d: Dimensionless Reynolds Number [-]
  ; ======================================================================
    If AirDensity <= 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn (AirDensity * Velocity * Diameter_m) / #AIR_VISCOSITY_20C
  EndProcedure

  Procedure.d GetFrictionFactor(Reynolds.d, Roughness_mm.d, Diameter_m.d)
  ; ======================================================================
  ; NAME: GetFrictionFactor
  ; DESC: Calculates lambda friction coefficient via Swamee-Jain approximation
  ; VAR(Reynolds.d): Reynolds number from GetReynoldsNumber() [-]
  ; VAR(Roughness_mm.d): Absolute material roughness [mm] (e.g., #ROUGHNESS_STEEL_STAIN)
  ; VAR(Diameter_m.d): Duct diameter [m]
  ; RET.d: Dimensionless Darcy friction factor lambda [-]
  ; ======================================================================
   Protected Roughness_m.d, Term1.d, Term2.d
    If Reynolds < 2300.0
      If Reynolds <= 0.0 : ProcedureReturn 0.0 : EndIf
      ProcedureReturn 64.0 / Reynolds 
    EndIf
    Roughness_m = Roughness_mm / 1000.0
    Term1 = Roughness_m / (3.7 * Diameter_m)
    Term2 = 5.74 / Pow(Reynolds, 0.9)
    ProcedureReturn 0.25 / Pow(Log10(Term1 + Term2), 2.0)
  EndProcedure

  Procedure.d GetLinearPressureLoss(Length.d, Diameter_m.d, Velocity.d, FrictionFactor.d, AirDensity.d)
  ; ======================================================================
  ; NAME: GetLinearPressureLoss
  ; DESC: Calculates Darcy-Weisbach pressure loss along straight duct stretches
  ; VAR(Length.d): Length of the straight duct line [m]
  ; VAR(Diameter_m.d): Round pipe or hydraulic diameter [m]
  ; VAR(Velocity.d): Air flow velocity [m/s]
  ; VAR(FrictionFactor.d): Lambda factor from GetFrictionFactor() [-]
  ; VAR(AirDensity.d): Current air density [kg/m³]
  ; RET.d: Dynamic straight pressure loss [Pa]
  ; ======================================================================
    If Diameter_m <= 0.0 : ProcedureReturn 0.0 : EndIf
    Protected DynamicPressure.d = 0.5 * AirDensity * (Velocity * Velocity)
    ProcedureReturn FrictionFactor * (Length / Diameter_m) * DynamicPressure
  EndProcedure

  Procedure.d GetLocalPressureLoss(Zeta.d, Velocity.d, AirDensity.d)
  ; ======================================================================
  ; NAME: GetLocalPressureLoss
  ; DESC: Calculates component pressure loss for local fittings via Zeta
  ; VAR(Zeta.d): Local resistance coefficient [-]
  ; VAR(Velocity.d): Air velocity inside the fitting [m/s]
  ; VAR(AirDensity.d): Current air density [kg/m³]
  ; RET.d: Component pressure drop [Pa]
  ; ======================================================================
    Protected DynamicPressure.d = 0.5 * AirDensity * (Velocity * Velocity)
    ProcedureReturn Zeta * DynamicPressure
  EndProcedure

; ======================================================================
  ; NAME: InitDatabase
  ; DESC: Reads embedded DataSection and populates the global Fittings list
  ; RET.i: Number of loaded items
  ; ======================================================================
  Procedure.i InitDatabase()
    ClearList(Fittings())
    Restore ZetaData
    
    Protected Count.i = 0
    Protected Name.s, Zeta.d, Type.i
    
    Read.i Count ; First element in DataSection is the total amount
    
    Protected i.i
    For i = 1 To Count
      Read.s Name
      Read.d Zeta
      Read.i Type ; Now reading the associated geometry type flag
      
      AddElement(Fittings())
      Fittings()\Name = Name
      Fittings()\Zeta = Zeta
      Fittings()\Type = Type
    Next i
    
    ProcedureReturn Count
  EndProcedure

  ; ======================================================================
  ; NAME: GetZetaByName
  ; DESC: Searches the database for a fitting name and returns its Zeta value
  ; VAR(FittingName.s): Name string to search for
  ; RET.d: Zeta coefficient, or 0.0 if not found
  ; ======================================================================
  Procedure.d GetZetaByName(FittingName.s)
    ForEach Fittings()
      If Fittings()\Name = FittingName
        ProcedureReturn Fittings()\Zeta
      EndIf
    Next
    ProcedureReturn 0.0
  EndProcedure

  ; ======================================================================
  ; NAME: FilterFittings
  ; DESC: Filters the master database by geometry type into a temporary output list
  ; VAR(GeometryFilter.i): #Geom_Round, #Geom_Rect, or #Geom_All
  ; VAR(OutputList.Fitting()): Target list to be filled with filtered results
  ; RET.i: Number of items matched and copied
  ; ======================================================================
  Procedure.i FilterFittings(GeometryFilter.i, List OutputList.Fitting())
    ClearList(OutputList())
    Protected MatchCount.i = 0
    
    ForEach Fittings()
      ; If filter is ALL, or the type matches the filter exactly
      If GeometryFilter = #Geom_All Or Fittings()\Type = GeometryFilter
        AddElement(OutputList())
        OutputList()\Name = Fittings()\Name
        OutputList()\Zeta = Fittings()\Zeta
        OutputList()\Type = Fittings()\Type
        MatchCount + 1
      EndIf
    Next
    
    ProcedureReturn MatchCount
  EndProcedure

  ; --- Embedded Datasection holding typical Round and Rectangular fittings ---
  DataSection
    ZetaData:
    Data.i 19 ; Total Number of elements
    
    ; === ROUND PIPE / CHIMNEY COMPONENTS ===
    Data.s "90° Bend (Sharp / Segmented)" : Data.d 0.60 : Data.i #Geom_Round
    Data.s "90° Bend (Standard R=D)"      : Data.d 0.30 : Data.i #Geom_Round
    Data.s "90° Bend (Smooth R=1.5D)"     : Data.d 0.20 : Data.i #Geom_Round
    Data.s "45° Bend (Standard)"          : Data.d 0.15 : Data.i #Geom_Round
    Data.s "45° Bend (Smooth Run)"        : Data.d 0.10 : Data.i #Geom_Round
    Data.s "T-Piece 90° (Branch Flow)"    : Data.d 1.20 : Data.i #Geom_Round
    Data.s "T-Piece 90° (Straight Run)"   : Data.d 0.20 : Data.i #Geom_Round
    Data.s "Conical Reduction (Smooth)"   : Data.d 0.05 : Data.i #Geom_Round
    Data.s "Sudden Contraction (Sharp)"   : Data.d 0.50 : Data.i #Geom_Round
    Data.s "Duct Outlet Grid / Louver"    : Data.d 1.50 : Data.i #Geom_Round
    Data.s "Rain Cap (Kaminhaube)"        : Data.d 0.80 : Data.i #Geom_Round
    
    ; === RECTANGULAR DUCT COMPONENTS ===
    Data.s "90° Mitred Bend (Sharp Corner)" : Data.d 1.20 : Data.i #Geom_Rect
    Data.s "90° Curved Bend (Standard)"     : Data.d 0.45 : Data.i #Geom_Rect
    Data.s "45° Mitred Bend"                : Data.d 0.50 : Data.i #Geom_Rect
    Data.s "45° Curved Bend"                : Data.d 0.20 : Data.i #Geom_Rect
    Data.s "T-Piece 90° (Branch Flow)"      : Data.d 1.50 : Data.i #Geom_Rect
    Data.s "T-Piece 90° (Straight Run)"     : Data.d 0.30 : Data.i #Geom_Rect
    Data.s "Symmetrical Transformation"     : Data.d 0.15 : Data.i #Geom_Rect
    Data.s "Air Intake / Exhaust Louver"    : Data.d 2.00 : Data.i #Geom_Rect
    
  EndDataSection
EndModule



CompilerIf #PB_Compiler_IsMainFile
  
  ; Fixed reference baseline for standard environmental fluid test conditions
  Define CurrentDensity.d = 1.20 ; Mimicking a typical calibrated indoor flow density
  
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
  Debug "-> Friction pressure drop reduction: " + StrD(((Loss_Rect-Loss_Round)/Loss_Rect)*100, 1) + "%!"
  Debug "**********************************************************************"
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
; CursorPosition = 41
; Folding = ---
; DPIAware
; CPU = 5