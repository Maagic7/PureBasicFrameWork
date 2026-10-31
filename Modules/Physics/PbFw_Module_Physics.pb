; ===========================================================================
;  FILE: PbFw_Module_Physics.pb
;  NAME: Module Physics 
;  DESC: Implements physical calculations like ...
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/02/24
; VERSION  :  0.0 Brainstorming Version
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

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

;XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
;XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
;XIncludeFile "PbFw_Module_Complex.pb"      ; Complex::  Complex Number calculations

DeclareModule PHYSICS
  
  EnableExplicit
  
  ; --- Physical Constants ---
  #G_EARTH              = 9.81274      ; Gravitational acceleration on Earth in m/s²
  #C_LIGHT              = 299792458.0  ; Speed of light in a vacuum in m/s
  #C_LIGHT_SQ           = #C_LIGHT * #C_LIGHT
  #DENSITY_AIR_SEA_LEVEL = 1.225        ; Air density at sea level (15°C) in kg/m³
  
  ; --- Common Drag Coefficients (Cd / Cw Values) ---
  #CD_SPHERE            = 0.47
  #CD_CUBE              = 1.05
  #CD_STREAMLINED_BODY  = 0.04
  #CD_CAR_AVERAGE       = 0.30
  #CD_SKYDIVER_BELLY    = 1.00
  
  ; --- Structures for 2D Spatial Physics ---
  Structure Vector2D
    x.d
    y.d
  EndStructure

  ; --- Inline Macros (Optimized for Performance) ---
  Macro mac_AngularFrequency(Frequency)
    (#PI * 2.0 * (Frequency))  
  EndMacro
  
  Macro mac_KineticEnergy(Mass, Velocity)
    (0.5 * (Mass) * (Velocity) * (Velocity))
  EndMacro

  ; --- Public Function Declarations ---
  
  ; Kinematics: Uniform Motion (Constant Velocity)
  Declare.d Kinematics_UniformDisplacement(Velocity.d, Time.d)
  Declare.d Kinematics_UniformVelocity(Displacement.d, Time.d)
  Declare.d Kinematics_UniformTime(Displacement.d, Velocity.d)
  
  ; Kinematics: Uniformly Accelerated Motion
  Declare.d Kinematics_FinalVelocity(InitialVelocity.d, Acceleration.d, Time.d)
  Declare.d Kinematics_Displacement(InitialVelocity.d, Acceleration.d, Time.d)
  Declare.d Kinematics_VelocityFromDistance(InitialVelocity.d, Acceleration.d, Displacement.d)
  
  ; Circular Motion
  Declare.d Circular_TangentialVelocity(Radius.d, AngularFrequency.d)
  Declare.d Circular_CentripetalAcceleration(Radius.d, AngularFrequency.d)
  Declare.d Circular_CentripetalForce(Mass.d, Radius.d, AngularFrequency.d)
  Declare.d Circular_PeriodToFrequency(Period.d)
  Declare.d Circular_FrequencyToPeriod(Frequency.d)
  
  ; Special Relativity
  Declare.d Relativity_LorentzFactor(Velocity.d)
  Declare.d Relativity_TimeDilation(ProperTime.d, Velocity.d)
  Declare.d Relativity_LengthContraction(ProperLength.d, Velocity.d)
  Declare.d Relativity_RelativisticMass(RestMass.d, Velocity.d)
  Declare.d Relativity_Energy(Mass.d, Velocity.d = 0.0)
  
  ; Classical Mechanics (Work, Energy, Power, Springs, Friction, Fluid Drag)
  Declare.d Mechanics_Work(Force.d, Displacement.d)
  Declare.d Mechanics_KineticEnergy(Mass.d, Velocity.d)
  Declare.d Mechanics_PotentialEnergy(Mass.d, Height.d, Gravity.d = #G_EARTH)
  Declare.d Mechanics_Power(WorkOrEnergy.d, Time.d)
  Declare.d Mechanics_Efficiency(EnergyOutput.d, EnergyInput.d)
  Declare.d Mechanics_HookesLawForce(SpringConstant.d, Displacement.d)
  Declare.d Mechanics_SpringConstant(Force.d, Displacement.d)
  Declare.d Mechanics_SpringEnergy(SpringConstant.d, Displacement.d)
  Declare.d Mechanics_FrictionForce(FrictionCoefficient.d, NormalForce.d)
  Declare.d Mechanics_DragForce(DragCoefficient.d, CrossSectionalArea.d, Velocity.d, FluidDensity.d = #DENSITY_AIR_SEA_LEVEL)
  Declare.d Mechanics_TerminalVelocity(Mass.d, DragCoefficient.d, CrossSectionalArea.d, FluidDensity.d = #DENSITY_AIR_SEA_LEVEL, Gravity.d = #G_EARTH)
  
  ; Dynamics & Collisions
  Declare.d Force(Mass.d, Acceleration.d)
  Declare.d WeightForce(Mass.d, Gravity.d = #G_EARTH)
  Declare.d Momentum(Mass.d, Velocity.d)
  Declare ElasticCollision1D(Mass1.d, *Velocity1.Double, Mass2.d, *Velocity2.Double)
EndDeclareModule

Module PHYSICS
   EnableExplicit
 
  ; --- Kinematics: Uniform Motion ---
  
  Procedure.d Kinematics_UniformDisplacement(Velocity.d, Time.d)
    ProcedureReturn Velocity * Time
  EndProcedure
  
  Procedure.d Kinematics_UniformVelocity(Displacement.d, Time.d)
    If Time = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn Displacement / Time
  EndProcedure
  
  Procedure.d Kinematics_UniformTime(Displacement.d, Velocity.d)
    If Velocity = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn Displacement / Velocity
  EndProcedure
  
  ; --- Kinematics: Uniformly Accelerated Motion ---
  
  Procedure.d Kinematics_FinalVelocity(InitialVelocity.d, Acceleration.d, Time.d)
    ProcedureReturn InitialVelocity + (Acceleration * Time)
  EndProcedure
  
  Procedure.d Kinematics_Displacement(InitialVelocity.d, Acceleration.d, Time.d)
    ProcedureReturn (InitialVelocity * Time) + (0.5 * Acceleration * Time * Time)
  EndProcedure
  
  Procedure.d Kinematics_VelocityFromDistance(InitialVelocity.d, Acceleration.d, Displacement.d)
    Protected Radicand.d = (InitialVelocity * InitialVelocity) + (2.0 * Acceleration * Displacement)
    If Radicand < 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn Sqr(Radicand)
  EndProcedure
  
  ; --- Circular Motion ---
  
  Procedure.d Circular_TangentialVelocity(Radius.d, AngularFrequency.d)
    ProcedureReturn AngularFrequency * Radius
  EndProcedure
  
  Procedure.d Circular_CentripetalAcceleration(Radius.d, AngularFrequency.d)
    ProcedureReturn AngularFrequency * AngularFrequency * Radius
  EndProcedure
  
  Procedure.d Circular_CentripetalForce(Mass.d, Radius.d, AngularFrequency.d)
    ProcedureReturn Mass * Circular_CentripetalAcceleration(Radius, AngularFrequency)
  EndProcedure
  
  Procedure.d Circular_PeriodToFrequency(Period.d)
    If Period = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn 1.0 / Period
  EndProcedure
  
  Procedure.d Circular_FrequencyToPeriod(Frequency.d)
    If Frequency = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn 1.0 / Frequency
  EndProcedure
  
  ; --- Special Relativity ---
  
  Procedure.d Relativity_LorentzFactor(Velocity.d)
    If Abs(Velocity) >= #C_LIGHT
      ProcedureReturn Infinity()
    EndIf
    Protected BetaSq.d = (Velocity * Velocity) / #C_LIGHT_SQ
    ProcedureReturn 1.0 / Sqr(1.0 - BetaSq)
  EndProcedure
  
  Procedure.d Relativity_TimeDilation(ProperTime.d, Velocity.d)
    ProcedureReturn ProperTime * Relativity_LorentzFactor(Velocity)
  EndProcedure
  
  Procedure.d Relativity_LengthContraction(ProperLength.d, Velocity.d)
    Protected Gamma.d = Relativity_LorentzFactor(Velocity)
    If Gamma = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn ProperLength / Gamma
  EndProcedure
  
  Procedure.d Relativity_RelativisticMass(RestMass.d, Velocity.d)
    ProcedureReturn RestMass * Relativity_LorentzFactor(Velocity)
  EndProcedure
  
  Procedure.d Relativity_Energy(Mass.d, Velocity.d = 0.0)
    Protected EffectiveMass.d = Mass
    If Velocity <> 0.0
      EffectiveMass = Relativity_RelativisticMass(Mass, Velocity)
    EndIf
    ProcedureReturn EffectiveMass * #C_LIGHT_SQ
  EndProcedure
  
  ; --- Classical Mechanics ---
  
  Procedure.d Mechanics_Work(Force.d, Displacement.d)
    ProcedureReturn Force * Displacement
  EndProcedure
  
  Procedure.d Mechanics_KineticEnergy(Mass.d, Velocity.d)
    ProcedureReturn 0.5 * Mass * Velocity * Velocity
  EndProcedure
  
  Procedure.d Mechanics_PotentialEnergy(Mass.d, Height.d, Gravity.d = #G_EARTH)
    ProcedureReturn Mass * Gravity * Height
  EndProcedure
  
  Procedure.d Mechanics_Power(WorkOrEnergy.d, Time.d)
    If Time = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn WorkOrEnergy / Time
  EndProcedure
  
  Procedure.d Mechanics_Efficiency(EnergyOutput.d, EnergyInput.d)
    If EnergyInput = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn EnergyOutput / EnergyInput
  EndProcedure
  
  Procedure.d Mechanics_HookesLawForce(SpringConstant.d, Displacement.d)
    ProcedureReturn -SpringConstant * Displacement
  EndProcedure
  
  Procedure.d Mechanics_SpringConstant(Force.d, Displacement.d)
    If Displacement = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn Abs(Force / Displacement)
  EndProcedure
  
  Procedure.d Mechanics_SpringEnergy(SpringConstant.d, Displacement.d)
    ProcedureReturn 0.5 * SpringConstant * Displacement * Displacement
  EndProcedure
  
  Procedure.d Mechanics_FrictionForce(FrictionCoefficient.d, NormalForce.d)
    ProcedureReturn FrictionCoefficient * NormalForce
  EndProcedure
  
  ; Fd = 0.5 * rho * v² * Cd * A
  Procedure.d Mechanics_DragForce(DragCoefficient.d, CrossSectionalArea.d, Velocity.d, FluidDensity.d = #DENSITY_AIR_SEA_LEVEL)
    ProcedureReturn 0.5 * FluidDensity * Velocity * Velocity * DragCoefficient * CrossSectionalArea
  EndProcedure
  
  ; vt = Sqr((2 * m * g) / (rho * A * Cd))
  Procedure.d Mechanics_TerminalVelocity(Mass.d, DragCoefficient.d, CrossSectionalArea.d, FluidDensity.d = #DENSITY_AIR_SEA_LEVEL, Gravity.d = #G_EARTH)
    Protected Denominator.d = FluidDensity * CrossSectionalArea * DragCoefficient
    If Denominator = 0.0 : ProcedureReturn 0.0 : EndIf
    ProcedureReturn Sqr((2.0 * Mass * Gravity) / Denominator)
  EndProcedure
  
  ; --- Dynamics ---
  
  Procedure.d Force(Mass.d, Acceleration.d)
    ProcedureReturn Mass * Acceleration
  EndProcedure
  
  Procedure.d WeightForce(Mass.d, Gravity.d = #G_EARTH)
    ProcedureReturn Mass * Gravity
  EndProcedure
  
  Procedure.d Momentum(Mass.d, Velocity.d)
    ProcedureReturn Mass * Velocity
  EndProcedure
  
  ; --- Collision Mechanics ---
  
  Procedure ElasticCollision1D(Mass1.d, *Velocity1.Double, Mass2.d, *Velocity2.Double)
    Protected v1_old.d = *Velocity1\d
    Protected v2_old.d = *Velocity2\d
    
    *Velocity1\d = ((Mass1 - Mass2) * v1_old + 2.0 * Mass2 * v2_old) / (Mass1 + Mass2)
    *Velocity2\d = ((Mass2 - Mass1) * v2_old + 2.0 * Mass1 * v1_old) / (Mass1 + Mass2)
  EndProcedure

EndModule

;- --- Usage Example ---
CompilerIf #PB_Compiler_IsMainFile
  OpenConsole("Physics Module - Fluid Drag Test")
  
  ; Example 1: A sports car driving at 36 m/s (approx. 130 km/h)
  ; Frontal area A = 2.2 m², Cd = 0.3
  Define CarCd.d   = Physics::#CD_CAR_AVERAGE
  Define CarArea.d = 2.2
  Define CarSpeed.d = 36.0
  Define Drag.d    = Physics::Mechanics_DragForce(CarCd, CarArea, CarSpeed)
  PrintN("Air drag opposing the car at 130 km/h: " + StrD(Drag, 2) + " Newtons")
  ; Example 2: Terminal velocity of a skydiver (80 kg) in belly-to-earth position
  ; Frontal area A = 0.7 m², Cd = 1.0
  Define DiverMass.d = 80.0
  Define DiverCd.d   = Physics::#CD_SKYDIVER_BELLY
  Define DiverArea.d = 0.7
  Define TermVel.d   = Physics::Mechanics_TerminalVelocity(DiverMass, DiverCd, DiverArea)
  PrintN("Terminal velocity of the skydiver: " + StrD(TermVel, 2) + " m/s (" + StrD(TermVel * 3.6, 1) + " km/h)")
  Input()
CompilerEndIf
; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 2
; FirstLine = 35
; Folding = -------
; DPIAware
; CPU = 5