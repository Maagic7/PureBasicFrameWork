; ==============================================================================
;  Module:       EDRV (Electrical Drive Systems & Motion Scaling)
;  Filename:     PbFw_Module_ElectricalDrive.pb
;  Description:  Calculates the entire industrial drive chain from VFD settings 
;                and motor specs down to gear ratios and linear conveyor motion.
;  License:      MIT (Open Source)
; ==============================================================================

DeclareModule EDRV
  EnableExplicit 

  ; --- Public Function Declarations ---
  #EDRV_Unit_Ms  = 0
  #EDRV_Unit_Mmin = 1
  
  ; Electrical & Inverter Base Functions
  Declare.d GetMotorElectricalPower(U.d, I.d, CosPhi.d = 1.0, Efficiency.d = 1.0)
  Declare.d GetMotorRpmFromFrequency(FrequencyHz.d, PolePairs.i)
  Declare.d GetFrequencyFromRequiredRpm(RequiredOutputRpm.d, PolePairs.i, GearRatio.d = 1.0)
  Declare.d GetNominalTorqueFromSpecs(NominalPowerKW.d, NominalRpm.d)
  Declare.d GetTorque(PowerWatts.d, Rpm.d)
  Declare.d GetEfficiencyFromSpecs(NominalPowerKW.d, U.d, I.d, CosPhi.d = 1.0)
  
  ; Advanced VFD Characteristics (87Hz / 95Hz Extended Field Operations)
  Declare.d GetHzDeltaVoltage(CurrentFreqHz.d, CornerFreqHz.d, MaxGridVoltage.d = 400.0)
  Declare.d GetHzDeltaAvailableTorque(CurrentFreqHz.d, CornerFreqHz.d, NominalTorqueNm.d)
  
  ; Transmission & Gearbox (Forward / Reverse)
  Declare.d GetOutputRpmFromMotor(MotorRpm.d, GearRatio.d)
  Declare.d GetMotorRpmFromOutput(OutputRpm.d, GearRatio.d)
  Declare.d GetGearOutputTorque(InputTorqueNm.d, GearRatio.d, Efficiency.d = 0.95)
  
  ; Linear Motion & Conveyor Scaling (Forward / Reverse)
  Declare.d GetLinearVelocityFromRpm(RollerRpm.d, RollerDiameterM.d, TargetUnit.i = #EDRV_Unit_Ms)
  Declare.d GetRpmFromLinearVelocity(LinearVelocity.d, RollerDiameterM.d, SourceUnit.i = #EDRV_Unit_Ms)

EndDeclareModule

Module EDRV
  EnableExplicit
  
  ; ============================================================================
  ; NAME: GetMotorElectricalPower
  ; DESC: Calculates the electrical active power drawn by the motor, optionally 
  ;       including motor efficiency to get the mechanical shaft power.
  ; VAR(U.d)          : Line-to-Line Voltage in Volts [V] (e.g., 400V)
  ; VAR(I.d)          : Line Current in Amperes [A]
  ; VAR(CosPhi.d)     : Power factor (dimensionless, usually 0.8 to 1.0)
  ; VAR(Efficiency.d) : Conductor efficiency rating (0.0 to 1.0). Set to 1.0 for pure electrical power.
  ; RET.d             : The calculated power in Watts [W]
  ; ============================================================================
  Procedure.d GetMotorElectricalPower(U.d, I.d, CosPhi.d = 1.0, Efficiency.d = 1.0)
    ProcedureReturn U * I * Sqr(3.0) * CosPhi * Efficiency
  EndProcedure

  ; ============================================================================
  ; NAME: GetMotorRpmFromFrequency
  ; DESC: Computes the synchronous motor speed based on the dynamic VFD output frequency.
  ; VAR(FrequencyHz.d): Current output frequency of the inverter in Hertz [Hz]
  ; VAR(PolePairs.i)  : Number of motor pole pairs (e.g., 2 for a standard 1500rpm motor)
  ; RET.d             : Synchronous motor speed in revolutions per minute [rpm]
  ; ============================================================================
  Procedure.d GetMotorRpmFromFrequency(FrequencyHz.d, PolePairs.i)
    If PolePairs <= 0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn (FrequencyHz * 60.0) / PolePairs
  EndProcedure

  ; ============================================================================
  ; NAME: GetFrequencyFromRequiredRpm
  ; DESC: Calculates the frequency the VFD needs to supply to reach a desired 
  ;       output speed, accounting for motor pole pairs and gearbox transmission.
  ; VAR(RequiredOutputRpm.d): The targeted rotational speed at the gearbox output/roller in [rpm]
  ; VAR(PolePairs.i)         : Number of motor pole pairs (e.g., 2 for a standard 1500rpm motor)
  ; VAR(GearRatio.d)         : The transmission gear ratio (i) (Default: 1.0 for direct drive)
  ; RET.d                    : The required inverter frequency in Hertz [Hz]
  ; ============================================================================
  Procedure.d GetFrequencyFromRequiredRpm(RequiredOutputRpm.d, PolePairs.i, GearRatio.d = 1.0)
    If PolePairs <= 0 : ProcedureReturn 0.0 : EndIf
    
    ; Step 1: Scale the slower output RPM up to the fast required motor RPM
    Protected RequiredMotorRpm.d = RequiredOutputRpm * GearRatio
    
    ; Step 2: Calculate electrical frequency: f = (n * p) / 60
    ProcedureReturn (RequiredMotorRpm * PolePairs) / 60.0
  EndProcedure

  ; ============================================================================
  ; NAME: GetTorque
  ; DESC: Calculates the available mechanical torque (M) from speed and power.
  ; VAR(PowerWatts.d) : The mechanical shaft power in Watts [W]
  ; VAR(Rpm.d)        : The actual rotational shaft speed in [rpm]
  ; RET.d             : The mechanical torque in Newton-Meters [Nm]
  ; ============================================================================
  Procedure.d GetTorque(PowerWatts.d, Rpm.d)
    If Rpm = 0.0 : ProcedureReturn 0.0 : EndIf
    ; Standard physical torque conversion: M = P / omega = P / (2 * PI * n / 60)
    ProcedureReturn PowerWatts / (2.0 * #PI * (Rpm / 60.0))
  EndProcedure
  
  ; ============================================================================
  ; NAME: GetEfficiencyFromSpecs
  ; DESC: Calculates the nominal motor efficiency (Eta) directly from standard 
  ;       nameplate data (Power in kW, Voltage, Current, and CosPhi).
  ; VAR(NominalPowerKW.d): The rated mechanical shaft power in Kilowatts [kW] (e.g., 5.5)
  ; VAR(U.d)             : Rated Line-to-Line Voltage in Volts [V] (e.g., 400.0)
  ; VAR(I.d)             : Rated Line Current in Amperes [A] (e.g., 11.0)
  ; VAR(CosPhi.d)        : Rated power factor from the nameplate (e.g., 0.82)
  ; RET.d                : The calculated nominal efficiency (dimensionless, 0.0 to 1.0)
  ; ============================================================================
  Procedure.d GetEfficiencyFromSpecs(NominalPowerKW.d, U.d, I.d, CosPhi.d = 1.0)
    ; Calculate total electrical active power drawn from the grid
    Protected ElectricalPowerWatts.d = U * I * Sqr(3.0) * CosPhi
    
    If ElectricalPowerWatts = 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; Convert mechanical kW to Watts
    Protected MechanicalPowerWatts.d = NominalPowerKW * 1000.0
    
    ; Efficiency = P_mech / P_el
    Protected Efficiency.d = MechanicalPowerWatts / ElectricalPowerWatts
    
    ; Safety clamp: An electric motor cannot exceed 100% efficiency
    If Efficiency > 1.0 : ProcedureReturn 1.0 : EndIf
    
    ProcedureReturn Efficiency
  EndProcedure

  ; ============================================================================
  ; NAME: GetOutputRpmFromMotor
  ; DESC: Calculates the slower output speed after the gearbox transmission (Forward).
  ; VAR(MotorRpm.d)  : The fast rotational speed of the motor shaft in [rpm]
  ; VAR(GearRatio.d) : The transmission gear ratio (i) (e.g., 15.0 for 15:1 reduction)
  ; RET.d            : The slower output speed at the drive roller in [rpm]
  ; ============================================================================
  Procedure.d GetOutputRpmFromMotor(MotorRpm.d, GearRatio.d)
    If GearRatio = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn MotorRpm / GearRatio
  EndProcedure

  ; ============================================================================
  ; NAME: GetMotorRpmFromOutput
  ; DESC: Calculates the required fast motor speed needed for a targeted output speed (Reverse).
  ; VAR(OutputRpm.d) : The desired slower speed at the drive roller in [rpm]
  ; VAR(GearRatio.d) : The transmission gear ratio (i)
  ; RET.d            : The required motor shaft speed in revolutions per minute [rpm]
  ; ============================================================================
  Procedure.d GetMotorRpmFromOutput(OutputRpm.d, GearRatio.d)
    ProcedureReturn OutputRpm * GearRatio
  EndProcedure

  ; ============================================================================
  ; NAME: GetGearOutputTorque
  ; DESC: Calculates the increased mechanical torque available after the gearbox.
  ; VAR(InputTorqueNm.d) : The raw motor torque entering the gearbox in [Nm]
  ; VAR(GearRatio.d)     : The transmission gear ratio (i)
  ; VAR(Efficiency.d)    : Gearbox mechanical efficiency rating (0.0 to 1.0, e.g., 0.95)
  ; RET.d                : The torque available at the output shaft in Newton-Meters [Nm]
  ; ============================================================================
  Procedure.d GetGearOutputTorque(InputTorqueNm.d, GearRatio.d, Efficiency.d = 0.95)
    ProcedureReturn InputTorqueNm * GearRatio * Efficiency
  EndProcedure

  ; ============================================================================
  ; NAME: GetLinearVelocityFromRpm
  ; DESC: Converts the rotational speed of the drive roller into linear conveyor speed.
  ;       Supports both m/s and m/min output through a unit flag.
  ; VAR(RollerRpm.d)       : The rotational speed of the final drive roller in [rpm]
  ; VAR(RollerDiameterM.d) : The outer diameter of the conveyor pulley/roller in meters [m]
  ; VAR(TargetUnit.i)      : The requested speed unit constant (#EDRV_Unit_Ms or #EDRV_Unit_Mmin)
  ; RET.d                  : The linear transport velocity in the selected unit
  ; ============================================================================
  Procedure.d GetLinearVelocityFromRpm(RollerRpm.d, RollerDiameterM.d, TargetUnit.i = #EDRV_Unit_Ms)
    ; Base calculation in m/s: v = pi * d * n / 60
    Protected VelocityMs.d = #PI * RollerDiameterM * (RollerRpm / 60.0)
    
    Select TargetUnit
      Case #EDRV_Unit_Mmin
        ProcedureReturn VelocityMs * 60.0 ; Convert m/s to m/min
      Default
        ProcedureReturn VelocityMs        ; Standard m/s
    EndSelect
  EndProcedure

  ; ============================================================================
  ; NAME: GetRpmFromLinearVelocity
  ; DESC: Calculates how fast the drive roller must spin to hit a target transport speed.
  ;       Accepts input speed in either m/s or m/min through a unit flag.
  ; VAR(LinearVelocity.d)  : The targeted linear transport velocity
  ; VAR(RollerDiameterM.d) : The outer diameter of the conveyor pulley/roller in meters [m]
  ; VAR(SourceUnit.i)      : The unit constant of the input velocity (#EDRV_Unit_Ms or #EDRV_Unit_Mmin)
  ; RET.d                  : The required roller rotational speed in revolutions per minute [rpm]
  ; ============================================================================
  Procedure.d GetRpmFromLinearVelocity(LinearVelocity.d, RollerDiameterM.d, SourceUnit.i = #EDRV_Unit_Ms)
    Protected Circumference.d = #PI * RollerDiameterM
    If Circumference = 0.0 : ProcedureReturn 0.0 : EndIf
    
    Protected VelocityMs.d = LinearVelocity
    
    ; Convert input to m/s if it was supplied in m/min
    If SourceUnit = #EDRV_Unit_Mmin
      VelocityMs = LinearVelocity / 60.0
    EndIf
    
    ; n = (v * 60) / (pi * d)
    ProcedureReturn (VelocityMs * 60.0) / Circumference
  EndProcedure
  
  ; ============================================================================
  ; NAME: GetHzDeltaVoltage
  ; DESC: Calculates the dynamic voltage output of a VFD operating on an over-frequency 
  ;       characteristic (e.g. 87Hz or 95Hz delta clipping).
  ; VAR(CurrentFreqHz.d) : The actual running frequency of the VFD in Hertz [Hz]
  ; VAR(CornerFreqHz.d)  : The programmed corner frequency where max voltage is reached (e.g., 87.0 or 95.0)
  ; VAR(MaxGridVoltage.d): The maximum output voltage of the VFD in Volts [V] (typically 400.0V)
  ; RET.d                : The required output voltage for the current speed in Volts [V]
  ; ============================================================================
  Procedure.d GetHzDeltaVoltage(CurrentFreqHz.d, CornerFreqHz.d, MaxGridVoltage.d = 400.0)
    If CornerFreqHz <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; If we exceed the corner frequency, voltage clips at maximum grid capability
    If CurrentFreqHz >= CornerFreqHz
      ProcedureReturn MaxGridVoltage
    EndIf
    
    ; Linear U/f scaling up to the corner frequency
    ProcedureReturn (CurrentFreqHz / CornerFreqHz) * MaxGridVoltage
  EndProcedure

  ; ============================================================================
  ; NAME: GetHzDeltaAvailableTorque
  ; DESC: Calculates the maximum available torque under VFD operation, perfectly 
  ;       accounting for extended constant torque zones (87Hz/95Hz) and field weakening.
  ; VAR(CurrentFreqHz.d) : The actual running frequency of the VFD in Hertz [Hz]
  ; VAR(CornerFreqHz.d)  : The programmed corner frequency (e.g., 87.0 or 95.0 Hz)
  ; VAR(NominalTorqueNm.d): The rated motor torque at nominal base conditions in [Nm]
  ; RET.d                : The maximum safe available torque at current speed in [Nm]
  ; ============================================================================
  Procedure.d GetHzDeltaAvailableTorque(CurrentFreqHz.d, CornerFreqHz.d, NominalTorqueNm.d)
    If CurrentFreqHz <= 0.0 Or CornerFreqHz <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; Up to the corner frequency (e.g. 87Hz), torque remains 100% stable and constant!
    If CurrentFreqHz <= CornerFreqHz
      ProcedureReturn NominalTorqueNm
    Else
      ; Above the corner frequency, field weakening starts (torque drops linearly/quadratically)
      ProcedureReturn NominalTorqueNm * (CornerFreqHz / CurrentFreqHz)
    EndIf
  EndProcedure
  
  ; ============================================================================
  ; NAME: GetNominalTorqueFromSpecs
  ; DESC: Calculates the rated nominal motor torque (Mn) directly from the motor 
  ;       nameplate specifications (Nominal Power in kW and Nominal Speed in RPM).
  ; VAR(NominalPowerKW.d): The rated motor power in Kilowatts [kW] (e.g., 5.5 kW)
  ; VAR(NominalRpm.d)    : The rated motor speed under load in [rpm] (e.g., 1440 rpm)
  ; RET.d                : The resulting nominal torque in Newton-Meters [Nm]
  ; ============================================================================
  Procedure.d GetNominalTorqueFromSpecs(NominalPowerKW.d, NominalRpm.d)
    If NominalRpm = 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; Convert kW to Watts for standard SI calculation
    Protected PowerWatts.d = NominalPowerKW * 1000.0
    
    ; M = P / (2 * PI * n / 60)
    ProcedureReturn PowerWatts / (2.0 * #PI * (NominalRpm / 60.0))
  EndProcedure
  

EndModule

;- --- Verification Unit Test ---
;- --- Verification Unit Test ---
CompilerIf #PB_Compiler_IsMainFile
  OpenConsole("EDRV Module - Complete Drive Chain Test")
  
  PrintN("========================================================================")
  PrintN(" EDRV MODULE - ADVANCED INTEGRATED VERIFICATION TESTS")
  PrintN("========================================================================")
  PrintN("")

  ; --- TEST 1: Motor Efficiency & Nominal Torque from Nameplate ---
  PrintN("--- Test 1: Motor Nameplate Analysis ---")
  ; Example: 4-pole motor with 5.5 kW, 1440 rpm, 400V, 11.0A, cos phi 0.85
  Define BaseTorque.d = EDRV::GetNominalTorqueFromSpecs(5.5, 1440.0)
  Define MotorEta.d   = EDRV::GetEfficiencyFromSpecs(5.5, 400.0, 11.0, 0.85)
  
  PrintN("  Calculated Nominal Torque : " + StrD(BaseTorque, 2) + " Nm")
  PrintN("  Calculated Motor Efficiency: " + StrD(MotorEta * 100.0, 1) + " %")
  PrintN("")

  ; --- TEST 2: REVERSE CALCULATION WITH UNIT FLAGS & GEAR PATTERN (Auslegung / Rückwärts) ---
  PrintN("--- Test 2: Reverse Engineering (Target Motion -> VFD Frequency) ---")
  ; Goal: A conveyor belt needs to move at exactly 45.0 m/min (Industrial Unit).
  ; The drive roller has a diameter of 200mm (0.2m). The gearbox has a ratio of i = 15.0.
  Define TargetV_Mmin.d  = 45.0
  Define RollerD.d       = 0.2
  Define Ratio.d         = 15.0
  
  ; Step A: Get required roller speed from linear velocity (Passing the Mmin Unit Flag)
  Define ReqRollerRpm.d  = EDRV::GetRpmFromLinearVelocity(TargetV_Mmin, RollerD, EDRV::#EDRV_Unit_Mmin)
  ; Step B: Calculate what frequency the VFD must output, including the Gear Ratio directly
  Define ReqVfdFreq.d    = EDRV::GetFrequencyFromRequiredRpm(ReqRollerRpm, 2, Ratio)

  PrintN("  Target Belt Velocity       : " + StrD(TargetV_Mmin, 2) + " m/min")
  PrintN("  Required Drive Roller Speed: " + StrD(ReqRollerRpm, 1) + " rpm")
  PrintN("  Gearbox Reduction Ratio (i): " + StrD(Ratio, 1))
  PrintN("  >> VFD Output Frequency    : " + StrD(ReqVfdFreq, 2) + " Hz")
  PrintN("")

  ; --- TEST 3: FORWARD CALCULATION WITH SPEEDS (Betrieb / Vorwärts) ---
  PrintN("--- Test 3: Forward Velocity Unit Check ---")
  ; Roller spins at 60 RPM. Let's verify the linear speeds in different units.
  Define SampleRpm.d     = 60.0
  Define SpeedMs.d       = EDRV::GetLinearVelocityFromRpm(SampleRpm, RollerD, EDRV::#EDRV_Unit_Ms)
  Define SpeedMmin.d     = EDRV::GetLinearVelocityFromRpm(SampleRpm, RollerD, EDRV::#EDRV_Unit_Mmin)
  
  PrintN("  Rotational Speed at Roller : " + StrD(SampleRpm, 1) + " rpm")
  PrintN("  Resulting Speed in m/s     : " + StrD(SpeedMs, 3) + " m/s")
  PrintN("  Resulting Speed in m/min   : " + StrD(SpeedMmin, 2) + " m/min")
  PrintN("")

  ; --- TEST 4: 87Hz / 95Hz Extended Delta Operations ---
  PrintN("--- Test 4: Advanced 87Hz Drive Control ---")
  ; The motor is configured for an 87Hz delta characteristic (400V grid limit).
  Define Volt50.d  = EDRV::GetHzDeltaVoltage(50.0, 87.0, 400.0)
  Define Torq87.d  = EDRV::GetHzDeltaAvailableTorque(87.0, 87.0, BaseTorque)
  Define Torq100.d = EDRV::GetHzDeltaAvailableTorque(100.0, 87.0, BaseTorque)
  
  PrintN("  VFD Voltage Output at 50Hz : " + StrD(Volt50, 1) + " V (~230V Delta Matching)")
  PrintN("  Available Torque at 87Hz   : " + StrD(Torq87, 2) + " Nm (100% Constant Torque)")
  PrintN("  Available Torque at 100Hz  : " + StrD(Torq100, 2) + " Nm (Field Weakening Active)")
  PrintN("")

  PrintN("========================================================================")
  PrintN("Press ENTER to close.")
  Input()
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 337
; FirstLine = 264
; Folding = ---
; DPIAware
; CPU = 5