; ==============================================================================
;  Module:       VDE (Electrical Installation & Cable Calculations)
;  Filename:     PbFw_Module_VDE.pb
;  Description:  Implements DIN VDE 0298-4 current capacity tables using 
;                highly optimized PureBasic DataSections.
; ==============================================================================

; ==============================================================================
;  Module:       VDE (Electrical Installation & Cable Calculations)
;  Filename:     PbFw_Module_VDE.pb
; ==============================================================================

DeclareModule VDE
  ; --- Column Identifiers for Table 12-1 (Lapp T12) ---
  #VDE_Col_A_1Ader      = 1 
  #VDE_Col_B_MultiApp   = 2 
  #VDE_Col_C_MultiInd   = 3 
  #VDE_Col_D_Rubber1Ader = 4 

  ; --- Material Conductivity Constants ---
  #VDE_Conductivity_Copper = 56.0 

  ; --- Circuit Breaker Characteristics (Tripping Factors according to VDE 0100-410) ---
  #VDE_Breaker_B = 1 ; Type B: Instantaneous tripping at 5x nominal current
  #VDE_Breaker_C = 2 ; Type C: Instantaneous tripping at 10x nominal current (Standard for machines)
  #VDE_Breaker_D = 3 ; Type D: Instantaneous tripping at 20x nominal current (Heavy inrush loads)

  ; --- Public Function Declarations ---
  Declare.d GetBaseCurrent(CrossSectionSqmm.d, ColumnIdentifier.i)
  Declare.d GetTemperatureFactor(AmbientTemperatureCelsius.i)
  Declare.d GetBundlingFactor(CableCount.i)
  
  ; Voltage Drop & Cable Lengths
  Declare.d CalcVoltageDrop(NominalVoltage.d, Current.d, LengthM.d, CrossSectionSqmm.d, IsThreePhase.b = #True, CosPhi.d = 1.0)
  Declare.d CalcMaxCableLength(NominalVoltage.d, MaxDropPercent.d, Current.d, CrossSectionSqmm.d, IsThreePhase.b = #True, CosPhi.d = 1.0)
  
  ; Circuit Breaker Tripping & Loop Impedance
  Declare.d GetRequiredShortCircuitCurrent(NominalCurrent.d, Characteristic.i)
  Declare.d GetMaxLoopImpedance(NominalVoltage.d, NominalCurrent.d, Characteristic.i)
EndDeclareModule

Module VDE
  
  Structure VDE_Table12_1
    CrossSection.d
    Col_A.w
    Col_B.w
    Col_C.w
    Col_D.w
  EndStructure

  Structure VDE_Table12_2
    Temperature.w
    Factor.w 
  EndStructure

  Structure VDE_Table12_6
    CableCount.b
    Factor.b 
  EndStructure

  ; ... (GetBaseCurrent, GetTemperatureFactor, GetBundlingFactor, CalcVoltageDrop, CalcMaxCableLength wie zuvor) ...

  Procedure.d GetBaseCurrent(CrossSectionSqmm.d, ColumnIdentifier.i)
  ; ============================================================================
  ; NAME: GetBaseCurrent
  ; DESC: Retrieves the raw current carrying capacity (A) at 30°C ambient 
  ;       temperature from the integrated Lapp T12-1 database.
  ; VAR(CrossSectionSqmm.d) : The nominal conductor cross-section in mm²
  ; VAR(ColumnIdentifier.i) : The column constant (#VDE_Col_A_1Ader to #VDE_Col_D_Rubber1Ader)
  ; RET.d                   : The base current capacity in Amperes (0.0 if not found)
  ; ============================================================================
    Protected *Row.VDE_Table12_1 = ?VDE_Data_T12_1
    While *Row\CrossSection <> 0.0
      If *Row\CrossSection = CrossSectionSqmm
        Select ColumnIdentifier
          Case #VDE_Col_A_1Ader      : ProcedureReturn *Row\Col_A
          Case #VDE_Col_B_MultiApp   : ProcedureReturn *Row\Col_B
          Case #VDE_Col_C_MultiInd   : ProcedureReturn *Row\Col_C
          Case #VDE_Col_D_Rubber1Ader : ProcedureReturn *Row\Col_D
          Default                    : ProcedureReturn 0.0
        EndSelect
      EndIf
      *Row + SizeOf(VDE_Table12_1)
    Wend
    ProcedureReturn 0.0
  EndProcedure

  Procedure.d GetTemperatureFactor(AmbientTemperatureCelsius.i)
 ; ============================================================================
  ; NAME: GetTemperatureFactor
  ; DESC: Retrieves the derating factor for ambient temperatures deviating from 
  ;       30°C (for standard PVC lines with 70°C conductor limits).
  ; VAR(AmbientTemperatureCelsius.i) : The temperature surrounding the cable in °C
  ; RET.d                             : Multiplier factor (e.g., 0.87). Returns 0.0 if unsafe.
  ; ============================================================================
    Protected *Row.VDE_Table12_2 = ?VDE_Data_T12_2
    While *Row\Temperature <> -1
      If *Row\Temperature = AmbientTemperatureCelsius
        ProcedureReturn *Row\Factor / 100.0 
      EndIf
      *Row + SizeOf(VDE_Table12_2)
    Wend
    ProcedureReturn 0.0 
  EndProcedure

  Procedure.d GetBundlingFactor(CableCount.i)
  ; ============================================================================
  ; NAME: GetBundlingFactor
  ; DESC: Retrieves the reduction factor for bundled cables inside a conduit, 
  ;       trunking or directly on a wall according to Lapp Table 12-6 (DIN VDE 0298-4).
  ; VAR(CableCount.i) : The number of multi-core cables or AC/DC circuits in the bundle
  ; RET.d             : The reduction multiplier (0.0 to 1.0). Returns lowest factor if exceeded.
  ; ============================================================================
     
    Protected *Row.VDE_Table12_6 = ?VDE_Data_T12_6
    Protected LastFactor.d = 0.38 
    
    If CableCount <= 1 : ProcedureReturn 1.0 : EndIf
    
    While *Row\CableCount <> -1
      If *Row\CableCount = CableCount
        ProcedureReturn *Row\Factor / 100.0
      ElseIf *Row\CableCount > CableCount
        ProcedureReturn *Row\Factor / 100.0
      EndIf
      LastFactor = *Row\Factor / 100.0
      *Row + SizeOf(VDE_Table12_6)
    Wend
    ProcedureReturn LastFactor
  EndProcedure

  Procedure.d CalcVoltageDrop(NominalVoltage.d, Current.d, LengthM.d, CrossSectionSqmm.d, IsThreePhase = #True, CosPhi.d = 1.0)
  ; ============================================================================
  ; NAME: CalcVoltageDrop
  ; DESC: Calculates the percentage voltage drop over a specific cable length.
  ; VAR(NominalVoltage.d) : The nominal system voltage in Volts (e.g., 230V or 400V)
  ; VAR(Current.d)        : The operating current passing through the line in Amperes (A)
  ; VAR(LengthM.d)        : The simple length of the cable run in meters (m)
  ; VAR(CrossSectionSqmm.d): The conductor cross-section in mm²
  ; VAR(IsThreePhase)   : Set to #True for 3-phase Drehstrom, #False for single-phase Wechselstrom
  ; VAR(CosPhi.d)         : Power factor (dimensionless, usually 0.8 to 1.0)
  ; RET.d                 : The calculated voltage drop in percent (%)
  ; ============================================================================
   If NominalVoltage = 0.0 Or CrossSectionSqmm = 0.0 : ProcedureReturn 0.0 : EndIf
    Protected DropVolts.d
    If IsThreePhase
      DropVolts = (Sqr(3.0) * LengthM * Current * CosPhi) / (#VDE_Conductivity_Copper * CrossSectionSqmm)
    Else
      DropVolts = (2.0 * LengthM * Current * CosPhi) / (#VDE_Conductivity_Copper * CrossSectionSqmm)
    EndIf
    ProcedureReturn (DropVolts / NominalVoltage) * 100.0
  EndProcedure

  Procedure.d CalcMaxCableLength(NominalVoltage.d, MaxDropPercent.d, Current.d, CrossSectionSqmm.d, IsThreePhase.b = #True, CosPhi.d = 1.0)
  ; ============================================================================
  ; NAME: CalcMaxCableLength
  ; DESC: Calculates the maximum permissible cable length to stay within a defined percentage voltage drop.
  ; VAR(NominalVoltage.d) : The nominal system voltage in Volts (e.g., 230V or 400V)
  ; VAR(MaxDropPercent.d) : The maximum allowed voltage drop in percent (e.g., 3.0%)
  ; VAR(Current.d)        : The maximum operating current in Amperes (A)
  ; VAR(CrossSectionSqmm.d): The conductor cross-section in mm²
  ; VAR(IsThreePhase.b)   : Set to #True for 3-phase Drehstrom, #False for single-phase Wechselstrom
  ; VAR(CosPhi.d)         : Power factor (dimensionless, usually 0.8 to 1.0)
  ; RET.d                 : The maximum length in meters (m) before exceeding the voltage drop limit
  ; ============================================================================
    If Current = 0.0 Or CosPhi = 0.0 : ProcedureReturn 0.0 : EndIf
    Protected MaxDropVolts.d = (MaxDropPercent / 100.0) * NominalVoltage
    Protected MaxLength.d
    If IsThreePhase
      MaxLength = (MaxDropVolts * #VDE_Conductivity_Copper * CrossSectionSqmm) / (Sqr(3.0) * Current * CosPhi)
    Else
      MaxLength = (MaxDropVolts * #VDE_Conductivity_Copper * CrossSectionSqmm) / (2.0 * Current * CosPhi)
    EndIf
    ProcedureReturn MaxLength
  EndProcedure

  Procedure.d GetRequiredShortCircuitCurrent(NominalCurrent.d, Characteristic.i)
  ; ============================================================================
  ; NAME: GetRequiredShortCircuitCurrent
  ; DESC: Calculates the minimum short-circuit current (Ik) required to trigger 
  ;       the magnetic quick-release of a circuit breaker within 0.4 seconds.
  ; VAR(NominalCurrent.d) : The rated nominal current of the breaker in Amperes (A)
  ; VAR(Characteristic.i) : The breaker type constant (#VDE_Breaker_B, #VDE_Breaker_C, #VDE_Breaker_D)
  ; RET.d                 : The required fault current in Amperes (A)
  ; ============================================================================
    Select Characteristic
      Case #VDE_Breaker_B : ProcedureReturn NominalCurrent * 5.0
      Case #VDE_Breaker_C : ProcedureReturn NominalCurrent * 10.0
      Case #VDE_Breaker_D : ProcedureReturn NominalCurrent * 20.0
      Default             : ProcedureReturn 0.0
    EndSelect
  EndProcedure

  Procedure.d GetMaxLoopImpedance(NominalVoltage.d, NominalCurrent.d, Characteristic.i)
  ; ============================================================================
  ; NAME: GetMaxLoopImpedance
  ; DESC: Calculates the maximum permissible loop impedance (Zs) to guarantee 
  ;       safe circuit breaker tripping according to Ohm's law.
  ; VAR(NominalVoltage.d) : The phase-to-earth nominal voltage in Volts (typically 230V)
  ; VAR(NominalCurrent.d) : The rated nominal current of the breaker in Amperes (A)
  ; VAR(Characteristic.i) : The breaker type constant (#VDE_Breaker_B, #VDE_Breaker_C, #VDE_Breaker_D)
  ; RET.d                 : The maximum loop impedance in Ohms (Ω)
  ; ============================================================================
    Protected RequiredIk.d = GetRequiredShortCircuitCurrent(NominalCurrent, Characteristic)
    If RequiredIk = 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; Zs = U0 / Ik
    ProcedureReturn NominalVoltage / RequiredIk
  EndProcedure

  DataSection
    VDE_Data_T12_1:
    Data.d 0.08  : Data.w 2,   0,   1,   0   
    Data.d 0.14  : Data.w 3,   0,   2,   0   
    Data.d 0.25  : Data.w 5,   0,   4,   0   
    Data.d 0.34  : Data.w 8,   0,   6,   0   
    Data.d 0.50  : Data.w 12,  3,   9,   0   
    Data.d 0.75  : Data.w 15,  6,   12,  0   
    Data.d 1.00  : Data.w 19,  10,  15,  0   
    Data.d 1.50  : Data.w 24,  16,  18,  30  
    Data.d 2.50  : Data.w 32,  25,  26,  30  
    Data.d 4.00  : Data.w 42,  32,  34,  41  
    Data.w 0, 0, 0, 0, 0, 0 

    VDE_Data_T12_2:
    Data.w 10, 122 : Data.w 15, 117 : Data.w 20, 112 : Data.w 25, 106 
    Data.w 30, 100 : Data.w 35, 94  : Data.w 40, 87  : Data.w 45, 79  
    Data.w 50, 71  : Data.w 55, 61  : Data.w 60, 50  : Data.w 65, 35  
    Data.w -1, -1  

    VDE_Data_T12_6:
    Data.b 1,  100 : Data.b 2,  80 : Data.b 3,  70 : Data.b 4,  65
    Data.b 5,  60  : Data.b 6,  57 : Data.b 7,  54 : Data.b 8,  52
    Data.b 9,  50  : Data.b 12, 45 : Data.b 16, 41 : Data.b 20, 38
    Data.b -1, -1  
  EndDataSection
EndModule

;- --- Verification Unit Test ---
CompilerIf #PB_Compiler_IsMainFile
  OpenConsole("VDE Module - Complete Unit Test")
  
  PrintN("========================================================================")
  PrintN(" VDE MODULE - INTEGRATED VERIFICATION TESTS")
  PrintN("========================================================================")
  PrintN("")

  ; --- TEST 1: Current Capacity & Bundling (Lapp T12-1 / T12-6) ---
  PrintN("--- Test 1: Current Capacity & Reduction ---")
  Define BaseA.d   = VDE::GetBaseCurrent(2.5, VDE::#VDE_Col_C_MultiInd) ; Expected: 26.0 A
  Define BundleF.d = VDE::GetBundlingFactor(5)                         ; Expected: 0.60
  Define TempF.d   = VDE::GetTemperatureFactor(40)                     ; Expected: 0.87
  Define SafeA.d   = BaseA * BundleF * TempF
  
  PrintN("  Base capacity for 2.5mm2 (Category C): " + StrD(BaseA, 1) + " A")
  PrintN("  Reduction factor for 5 bundled cables: " + StrD(BundleF, 2))
  PrintN("  Temperature factor for 40 C ambient  : " + StrD(TempF, 2))
  PrintN("  >> Real safe operating current limit : " + StrD(SafeA, 2) + " A")
  PrintN("")

  ; --- TEST 2: Voltage Drop & Permissible Lengths ---
  PrintN("--- Test 2: Voltage Drop & Cable Length ---")
  ; 3-phase Drehstrom, 16 A, 50 meters run, 2.5 mm² cross-section
  Define Drop.d   = VDE::CalcVoltageDrop(400.0, 16.0, 50.0, 2.5, #True, 1.0)
  Define MaxLen.d = VDE::CalcMaxCableLength(400.0, 3.0, 16.0, 2.5, #True, 1.0)
  
  PrintN("  Voltage drop at 50m (16A, 400V Three-Phase): " + StrD(Drop, 2) + " %")
  PrintN("  >> Max allowed length for max 3.0% drop     : " + StrD(MaxLen, 1) + " meters")
  PrintN("")

  ; --- TEST 3: Breaker Tripping & Loop Impedance (VDE 0100-410) ---
  PrintN("--- Test 3: Breaker Tripping Conditions ---")
  ; Industrial standard C16 circuit breaker
  Define RequiredIk.d = VDE::GetRequiredShortCircuitCurrent(16.0, VDE::#VDE_Breaker_C)
  Define MaxZs.d      = VDE::GetMaxLoopImpedance(230.0, 16.0, VDE::#VDE_Breaker_C)
  
  PrintN("  Required short-circuit current (Ik) for C16: " + StrD(RequiredIk, 1) + " A")
  PrintN("  >> Max allowed loop impedance (Zs) at 230V : " + StrD(MaxZs, 2) + " Ohm")
  PrintN("")
  
  PrintN("========================================================================")
  PrintN("Press ENTER to close.")
  Input()
CompilerEndIf


; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 235
; FirstLine = 158
; Folding = --
; DPIAware
; CPU = 5