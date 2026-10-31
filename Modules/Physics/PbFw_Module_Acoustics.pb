; ===========================================================================
;  FILE: PbFw_Module_Acoustics.pb
;  NAME: Module Acoustics [Acoustics::]
;  DESC: Modul for acoustic log calculations, sound addition and duct airflow noise
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
;   2026/10/26 - Initial interface design for logarithmic decibel addition,
;                distance attenuation, and aerodynamic duct regeneration noise.
;}
;{ TODO:
;}
; ===========================================================================

DeclareModule Acoustics
  EnableExplicit

  ; Public Functions
  Declare.d AddTwoSoundLevels(Level1.d, Level2.d)
  Declare.d AddMultipleSoundLevels(Array Levels.d(1))
  Declare.d GetDistanceAttenuation(SourceLevel.d, Distance_m.d)
  Declare.d EstimateDuctAirflowNoise(Velocity.d, CrossSectionArea.d)
  
EndDeclareModule

Module Acoustics
  EnableExplicit

  Procedure.d AddTwoSoundLevels(Level1.d, Level2.d)
  ; ======================================================================
  ; NAME: AddTwoSoundLevels
  ; DESC: Logarithmically adds two sound pressure levels: L = 10 * log10(10^(L1/10) + 10^(L2/10))
  ; VAR(Level1.d): First sound level [dB] or [dB(A)]
  ; VAR(Level2.d): Second sound level [dB] or [dB(A)]
  ; RET.d: Combined sound level [dB]
  ; ======================================================================
    Protected Sum.d
    Sum = Pow(10.0, Level1 / 10.0) + Pow(10.0, Level2 / 10.0)
    ProcedureReturn 10.0 * Log10(Sum)
  EndProcedure

  Procedure.d AddMultipleSoundLevels(Array Levels.d(1))
  ; ======================================================================
  ; NAME: AddMultipleSoundLevels
  ; DESC: Logarithmically adds an array of sound levels
  ; VAR(Levels.d(1)): 1D Array containing all individual sound levels [dB]
  ; RET.d: Combined total sound level [dB]
  ; ======================================================================
    Protected i.i, Size.i
    Protected Sum.d = 0.0
    
    Size = ArraySize(Levels())
    For i = 0 To Size
      Sum + Pow(10.0, Levels(i) / 10.0)
    Next i
    
    If Sum <= 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn 10.0 * Log10(Sum)
  EndProcedure

  Procedure.d GetDistanceAttenuation(SourceLevel.d, Distance_m.d)
  ; ======================================================================
  ; NAME: GetDistanceAttenuation
  ; DESC: Calculates free-field spherical sound dissipation over distance
  ; VAR(SourceLevel.d): Sound pressure level directly at the source (1m) [dB]
  ; VAR(Distance_m.d): Target distance to evaluated receiver [m]
  ; RET.d: Resulting sound pressure level at target distance [dB]
  ; ======================================================================
    If Distance_m <= 1.0 : ProcedureReturn SourceLevel : EndIf
    ; Sound drops by 6 dB per doubling of distance in a spherical free field
    ProcedureReturn SourceLevel - 20.0 * Log10(Distance_m)
  EndProcedure

  Procedure.d EstimateDuctAirflowNoise(Velocity.d, CrossSectionArea.d)
  ; ======================================================================
  ; NAME: EstimateDuctAirflowNoise
  ; DESC: Approximates flow-generated aerodynamic noise inside a straight duct stretch (VDI 2081 alternate)
  ; VAR(Velocity.d): Air stream velocity inside the duct [m/s]
  ; VAR(CrossSectionArea.d): Duct or pipe cross-section area [m²] (from Wind/Duct module)
  ; RET.d: Estimated flow-generated sound power level L_w [dB]
  ; ======================================================================
    If Velocity <= 1.0 Or CrossSectionArea <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; Engineering approximation: L_w = 10 * log10(A) + 60 * log10(v) + 10
    ; The v^6 relationship (60 * log10(v)) dominates aerodynamic flow noise drastically!
    ProcedureReturn 10.0 * Log10(CrossSectionArea) + 60.0 * Log10(Velocity) + 10.0
  EndProcedure

EndModule

; --- Complete Module Test Application for Open-Source Release ---
CompilerIf #PB_Compiler_IsMainFile
  
  ; ============================================================================
  ; TEST 17: LOGARITHMIC SOUND LEVEL ADDITION
  ; ============================================================================
  Define SingleMachineLevel.d = 65.0 ; 65 dB(A)
  Define CombinedLevel.d = Acoustics::AddTwoSoundLevels(SingleMachineLevel, SingleMachineLevel)
  
  Debug "=== TEST 17: LOGARITHMIC SOUND ADDITION ==="
  Debug "One running machine emits:   " + StrD(SingleMachineLevel, 1) + " dB"
  Debug "Two identical machines emit: " + StrD(CombinedLevel, 1) + " dB"
  Debug "-> Live Insight: Doubling the sound sources physically increases the level"
  Debug "   by exlclusively +3.0 dB, not by doubling the numerical value!"
  Debug "**********************************************************************"
  
  
  ; ============================================================================
  ; TEST 18: DISTANCE DISSIPATION (FREE FIELD ENVIRONMENT)
  ; ============================================================================
  Define MachineRoomLevel.d = 85.0 ; 85 dB at 1 meter
  Define EvaluationDistance.d = 15.0 ; 15 meters away
  Define ResidentialLevel.d = Acoustics::GetDistanceAttenuation(MachineRoomLevel, EvaluationDistance)
  
  Debug "=== TEST 18: SOUND ATTENUATION OVER DISTANCE ==="
  Debug "Sound level at 1 meter: " + StrD(MachineRoomLevel, 1) + " dB"
  Debug "Calculated level at " + StrD(EvaluationDistance, 1) + " meters distance: " + StrD(ResidentialLevel, 1) + " dB"
  Debug "**********************************************************************"
  
  
  ; ============================================================================
  ; TEST 19: AERODYNAMIC DUCT REGENERATION AIRFLOW NOISE
  ; ============================================================================
  Define AirVelocity.d = 9.5  ; High velocity: 9.5 m/s
  Define DuctSection.d = 0.5 * 0.4 ; 500x400mm Hauptkanal = 0.2 m²
  Define GeneratedNoise.d = Acoustics::EstimateDuctAirflowNoise(AirVelocity, DuctSection)
  
  Debug "=== TEST 19: AERODYNAMIC FLOW REGENERATION NOISE ==="
  Debug "Duct Air Velocity: " + StrD(AirVelocity, 1) + " m/s through a " + StrD(DuctSection, 2) + " m² channel section"
  Debug "Estimated resulting flow-generated noise level (L_w): " + StrD(GeneratedNoise, 1) + " dB"
  
  If AirVelocity > 7.0
    Debug "-> LIVE DEFENSE STATEMENT: The duct air velocity is too high (" + StrD(AirVelocity, 1) + " m/s > 7.0 m/s)!"
    Debug "   The massive noise level of " + StrD(GeneratedNoise, 1) + " dB is regenerated purely by the speed"
    Debug "   and turbulence inside the duct geometry. Altering the motor frequency or software parameters"
    Debug "   will NOT fix this design flaw; the system requires structural acoustic silencers!"
  EndIf
  Debug "**********************************************************************"

CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 2
; FirstLine = 70
; Folding = --
; DPIAware
; CPU = 5