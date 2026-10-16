; ===========================================================================
;  FILE: PbFw_Module_Ohm.pb
;  NAME: Module Ohm 
;  DESC: Implements eclectrical calculations like Resistance, Impedance...
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/08/08
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

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
XIncludeFile "PbFw_Module_Complex.pb"      ; Complex::  Complex Number calculations

; U = R * I

DeclareModule Ohm
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  Enumeration EOhmMaterial
    #PbFw_Ohm_Material_Cu = 0
    #PbFw_Ohm_Material_Al 
    #PbFw_Ohm_Material_Fe
    #PbFw_Ohm_Material_Constantan
  EndEnumeration
  
  
EndDeclareModule


Module Ohm
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Structure TMaterialProperty
    Resistance.d      ; specific resistance [Ohm*mm²/m] at 20°C
    Density.d         ; Material density [kg/dm³] at 20°C
    Tcoeff_R.d        ; Temperature coefficient of resistance
    Tcoeff_D.d        ; Temperature coefficient of density
  EndStructure
  
  Macro mac_Omega(Frequency)
    (#PI * Frequency * 2)  ; 2*Pi*f
  EndMacro

  ; Debug #PB_Compiler_EnumerationValue 
  Global Dim MaterialProperty.TMaterialProperty(#PB_Compiler_EnumerationValue-1)
  
  ;- ----------------------------------------------------------------------
  ;- Basic calculations
  ;- ----------------------------------------------------------------------

  Procedure.d R_Parallel(R1.d, R2.d)
  ; ============================================================================
  ; NAME: R_Parallel
  ; DESC: Calculates the resistance of 2 resistors in parallel connectionsp
  ; VAR(R1.d): Resistance 1 [Ohm]
  ; VAR(R2.d): Resistance 2 [Ohm]
  ; RET.d: Resistance [Ohm]
  ; ============================================================================
    
    ; 1/R = 1/R1 + 1/R2  = R1*R2/(R1+R2)
    ProcedureReturn R1*R2/(R1+R2)
  EndProcedure
  
  Procedure R_Serial(R1.d, R2.d)
  ; ============================================================================
  ; NAME: R_Serial
  ; DESC: Calculates the resistance of 2 resistors in serial connection
  ; VAR(R1.d): Resistance 1 [Ohm]
  ; VAR(R2.d): Resistance 2 [Ohm]
  ; RET.d: Resistance  [Ohm]
  ; ============================================================================
    
    ProcedureReturn R1 + R2
  EndProcedure
  
  Procedure C_Parallel(C1.d, C2.d)
  ; ============================================================================
  ; NAME: C_Parallel
  ; DESC: Calculates the capacity of 2 capacitors in parallel connection
  ; VAR(C1.d): Capacity 1 [F]
  ; VAR(C2.d): Capacity 2 [F]
  ; RET.d: Capacity [F]
  ; ============================================================================
    
    ProcedureReturn C1 + C2
  EndProcedure

  Procedure.d C_Serial(C1.d, C2.d)
  ; ============================================================================
  ; NAME: C_Serial
  ; DESC: Calculates the capacity of 2 capacitors in serial connection
  ; VAR(C1.d): Capacity 1 [F]
  ; VAR(C2.d): Capacity 2 [F]
  ; RET.d: Capacity [F]
  ; ============================================================================
    
    ProcedureReturn C1*C2/(C1+C2)
  EndProcedure
  
  Procedure L_Parallel(L1.d, L2.d)
  ; ============================================================================
  ; NAME: L_Parallel
  ; DESC: Calculates the inductivity of 2 coils in parallel connection
  ; VAR(L1.d): Inductivity 1 [H]
  ; VAR(L2.d): Inductivity 2 [H]
  ; RET.d: Inductivity [H]
  ; ============================================================================
    
    ProcedureReturn L1*L2/(L1+L2)
  EndProcedure
  
  Procedure L_Serial(L1.d, L2.d)
  ; ============================================================================
  ; NAME: L_Serial
  ; DESC: Calculates the inductivity of 2 coils in serial connection
  ; VAR(L1.d): Inductivity 1 [H]
  ; VAR(L2.d): Inductivity 2 [H]
  ; RET.d: Inductivity [H]
  ; ============================================================================
    
    ProcedureReturn L1+L2
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Complex calculations
  ;- ----------------------------------------------------------------------

  Procedure.i Z_Parallel(*Out.Complex::TComplex, *Z1.Complex::TComplex, *Z2.Complex::TComplex)
  ; ============================================================================
  ; NAME: 
  ; DESC: Calculate the parallel combination of complex impedances Z1 And Z2
  ; VAR(): 
  ; RET.i: *Out
  ; ============================================================================
  ;
   
    ; ChatGPT
    ; Calculate the product of Z1 and Z2
    *Out\re = (*Z1\re * *Z2\re + *Z1\im * *Z2\im) / (*Z1\re + *Z2\re)
    *Out\im = (*Z1\im * *Z2\re - *Z1\re * *Z2\im) / (*Z1\re + *Z2\re)

    ProcedureReturn *Out
  EndProcedure
  
  Procedure.i Z_Serial(*Out.Complex::TComplex, *Z1.Complex::TComplex, *Z2.Complex::TComplex)
  ; ============================================================================
  ; NAME: 
  ; DESC: Calculate the serial combination of complex impedances Z1 and Z2
  ; VAR() : 
  ; RET.i: *Out
  ; ============================================================================
    
    ; ChatGPT
    ; Z_serial = Z1 + Z2

    *Out\re = *Z1\re + *Z2\re
    *Out\im = *Z1\im + *Z2\im

    ProcedureReturn *Out
  EndProcedure

  Procedure.i Z_Capacitor(*Out.Complex::TComplex, Capacity_uF.d, Frequency_Hz.d)
  ; ============================================================================
  ; NAME: 
  ; DESC: 
  ; VAR() : 
  ; RET.i: *Out
  ; ============================================================================
    ; Calculate the impedance of a capacitor
    ; Z_capacitor = -j / (2 * PI * f * C)

    *Out\re = 0.0
    *Out\im = -1.0 / (2.0 * #PI * Frequency_Hz * Capacity_uF * 1e-6) ; Convert Capacity_uF to Farads

    ProcedureReturn *Out
  EndProcedure
  
  Procedure.i Z_Coil(*Out.Complex::TComplex, Inductance_uH.d, Frequency_Hz.d)
 ; ============================================================================
  ; NAME: 
  ; DESC: 
  ; VAR(L) :  Inductivity [H]
  ; RET.i: *Out
  ; ============================================================================
    ; Calculate the impedance of a coil
    ; Z_coil = j * 2 * PI * f * L

    ; Const j.d = Sqr(-1) ; Imaginary unit

    *Out\re = 0.0
    *Out\im = 2.0 * #PI * Frequency_Hz * Inductance_uH * 1e-6 ; Convert Inductance_uH to Henrys

    ProcedureReturn *Out
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Wire and Cable calculations
  ;- ----------------------------------------------------------------------
  
  ; Datas for AWG Wire-System
  ; see also Lapp conversion Table AWG to metric and metric to AWG
  ; AWG   d[mm]   A[mm²]  Ohm/km  metr.mm²
  ; 1     7,35	  42,41	  0,42	  50
  ; 2	    6,54	  33,63	  0,53	  35
  ; 3	    5,83	  26,67	  0,67	  -
  ; 4	    5,19	  21,15	  0,84	  25
  ; 5	    4,62	  16,77	  1,06	  -
  ; 6	    4,12	  13,30	  1,34	  16
  ; 7	    3,66	  10,55	  1,69	  -
  ; 8	    3,26	  8,37	  2,13	  10
  ; 9	    2,91	  6,63	  2,68	  -
  ; 10	  2,59	  5,26	  3,38	  6
  ; 11	  2,30	  4,17	  4,27	  -
  ; 12	  2,05	  3,31	  5,38	  4
  ; 13	  1,83	  2,62	  6,78	  -
  ; 14	  1,63	  2,08	  8,55	  2,5
  ; 15	  1,45	  1,65	  10,8	  -
  ; 16	  1,29	  1,31	  13,6	  1,5
  ; 17	  1,15	  1,04	  17,1	  -
  ; 18	  1,0237	0,823	  21,6	  1
  ; 19	  0,9116	0,653	  27,3	  0,75
  ; 20	  0,8118	0,518	  34,4	  0,75
  ; 21	  0,7229	0,410	  43,4	  0,5
  ; 22	  0,6438	0,326	  54,7	  0,34
  ; 23	  0,5733	0,258	  67	    -
  ; 24	  0,5106	0,205	  87	    0,25
  ; 25	  0,4547	0,162	  110	    -
  ; 26	  0,4049	0,129	  138	    0,14
  ; 27	  0,3606	0,102	  174	    -
  ; 28	  0,3211	0,081	  220	    0,09
  
  Procedure.d AWGtoSqureMM(AWG.d)
    
    ; https://de.wikipedia.org/wiki/American_Wire_Gauge  Protected.d D
    Protected.d D
    ; E = (36.0 - AWG) /39
    D= 0.127 * Pow(92.0, (36.0 - AWG) /39)
    
    ProcedureReturn D*D * #PI/4
  EndProcedure

  Procedure.d Cable_AWG_to_mm2(AWG.i)
  ; ============================================================================
  ; NAME: Cable_AWG_to_mm2
  ; DESC: Converts the AWG cable to mm² Cable
  ; VAR(AWG.i) : Cable AWG value
  ; RET.d : Use Cable with wire cross section [mm²]
  ; ============================================================================
    Protected *ptr.Double
    
    If AWG => 1 And  AWG <= 26
      *ptr = ?AWGtoMM         ; Pointer to the conversion Table start
      *ptr = *ptr + (AWG-1) * SizeOf(Double)  ; Pointer to Entry
      ProcedureReturn *ptr\d
    Else
      ProcedureReturn 0  
    EndIf
    
    DataSection
     AWGtoMM:
     ; cable mm² : AWG : exact mm²
      Data.d 50   ; 1  : 42,41
      Data.d 35   ; 2  : 33,63
      Data.d 35   ; 3  : 26,67
      Data.d 25   ; 4  : 21,15
      Data.d 16   ; 5  : 16,77
      
      Data.d 16   ; 6  : 13,30
      Data.d 10   ; 7  : 10,55 
      Data.d 10   ; 8  : 8,366
      Data.d 6    ; 9  : 6,634
      Data.d 6    ; 10 : 5,261
      
      Data.d 6    ; 11 : 4,172
      Data.d 4    ; 12 : 3,309
      Data.d 2.5  ; 13 : 2,624
      Data.d 2.5  ; 14 : 2,081
      Data.d 2.5  ; 15 : 1,650
            
      Data.d 1.5  ; 16 : 1,309
      Data.d 1.0  ; 17 : 1,038
      Data.d 1.0  ; 18 : 0,8230
      Data.d 0.75 ; 19 : 0,6527
      Data.d 0.75 ; 20 : 0,5176
      
      Data.d 0.5  ; 21 : 0,4105
      Data.d 0.34 ; 22 : 0,3255
      Data.d 0.25 ; 23 : 0,2582 
      Data.d 0.25 ; 24 : 0,2047
      Data.d 0.25 ; 25 : 0,1624
      
      Data.d 0.14 ; 26 : 0,1288
    EndDataSection
    
  EndProcedure
  
  ; From ChatGPT
  Procedure.i mm2_to_AWG(mm2.f)
  ; Convert square millimeters (mm²) to American Wire Gauge (AWG)

  EndProcedure
  
  Procedure.i SquareMM_to_AWG(A_mm.d)
  ; ============================================================================
  ; NAME: SquareMM_to_AWG 
  ; DESC: Wire square [mm²] to American Wire Gauge [AWG]
  ; VAR(Square_mm.d) : Wire square [mm²]
  ; RET.i : AWG value
  ; ============================================================================
    
  EndProcedure
  
  #Resistivity_Cu = 0.00000168
  #Resistivity_Al = 0.00000282

  Procedure.d GetWireSquare(R.d, Length_m.d, Material=#PbFw_Ohm_Material_CU)
  ; ============================================================================
  ; NAME: GetWireSquare
  ; DESC: Calculates the wire square for a given resistance and length
  ; DESC: Use ist to get the minimum wire square for a cable 
  ; VAR(R.d): Resistance [Ohm]
  ; VAR(Length_m.d) : Wire length [m]
  ; VAR(Material=#PbFw_Ohm_Material_CU): the wire material
  ; RET.d : Wire cross section [mm²]
  ; ============================================================================
     Protected Resistivity.d
    ; Chat GPT Code
    
    ; Select the resistivity based on the provided material
    Select Material
      Case #PbFw_Ohm_Material_Cu: Resistivity = #Resistivity_Cu
      Case #PbFw_Ohm_Material_Al: Resistivity = #Resistivity_Al
      Default: Resistivity = 0.0 ; Invalid material
    EndSelect

    ; Calculate wire cross-sectional area using the formula
    ProcedureReturn (Resistivity * Length_m) / R

  EndProcedure
   
  Procedure.d GetWireResistance(L_m.d, A_mm2.d, Material=#PbFw_Ohm_Material_CU)
  ; ============================================================================
  ; NAME: GetWireResistance
  ; DESC: Calculates the wire resistance from a given length and square
  ; VAR(L_m.d) : Length [m]
  ; VAR(A_mm2.d): Wire cross section [mm²]
  ; VAR(Material=#PbFw_Ohm_Material_CU): the wire material
  ; RET.d : Wire Resistance [Ohm]
  ; ============================================================================
    
    ; Chat GPT Code
    ; Constants for resistivity (in Ohm * mm² / m)
    Protected Resistivity.d
    
;     #Resistivity_Cu.d = 0.00000168
;     #Resistivity_Al.d = 0.00000282
;     #Resistivity_Fe.d = 0.000005
;     #Resistivity_Constantan.d = 0.00049
  
    ; Select the resistivity based on the provided material
    Select Material
      Case #PbFw_Ohm_Material_Cu: Resistivity = #Resistivity_Cu
      Case #PbFw_Ohm_Material_Al: Resistivity = #Resistivity_Al
      Default: Resistivity = 0.0 ; Invalid material
    EndSelect

    ; Calculate wire resistance using the formula
    ProcedureReturn (Resistivity * L_m) / A_mm2
  EndProcedure
  
  Procedure.d GetWireLengthFromResistance(R.d, A_mm2.d, Material=#PbFw_Ohm_Material_CU)
  ; ============================================================================
  ; NAME: GetWireLengthFromResistance
  ; DESC: Calculates the wire length form a given resistance an sectinal Area
  ; VAR(R.d): Resistance [Ohm]
  ; VAR(A_mm2.d): Wire cross section [mm²]
  ; VAR(Material=#PbFw_Ohm_Material_CU): the wire material
  ; RET.d : Wire Length [m]
  ; ============================================================================
    
    ; Chat GPT Code
    Protected Resistivity.d
    
;     #Resistivity_Cu.d = 0.00000168
;     #Resistivity_Al.d = 0.00000282
;     #Resistivity_Fe.d = 0.000005
;     #Resistivity_Constantan.d = 0.00049
    
    ; Select the resistivity based on the provided material
    Select Material
      Case #PbFw_Ohm_Material_Cu: Resistivity = #Resistivity_Cu
      Case #PbFw_Ohm_Material_Al: Resistivity = #Resistivity_Al
      Default: Resistivity = 0.0 ; Invalid material
    EndSelect

    ; Calculate wire length using the formula
    ProcedureReturn (R * A_mm2) / Resistivity

  EndProcedure
  
  
  Procedure GetDeltaR_Temp(R.d, dT.d, Material=#PbFw_Ohm_Material_CU)
  ; Widerstandsänderung nach Temperatur a = Tcoeff_R
  ; R(T) = R(T0) * (1+α*(T-T0)) = R(T) = R(To) + RTo(a*dT)
  ; dR = R * a*dT
    ProcedureReturn R * MaterialProperty(Material)\Tcoeff_R * dT  
  EndProcedure
  
  Procedure Init()
    
    ; Datas at 20°C
    ; TODO! Werte nochmals im Elektro Tabellenbuch nachsehen, da widersprüchlie Angaben im Web  
    
    ; Copper
    With MaterialProperty(#PbFw_Ohm_Material_Cu)
      \Density = 8.92         ; [kg/dm³]=[g/cm³]
      \Resistance =  0.0169   ; Ohm * mm² / m
      \Tcoeff_D = 16.5e-6     ; 1/K
      \Tcoeff_R = 0.0039      ; 1/K;
    EndWith
    
    ; Aluminium
    With MaterialProperty(#PbFw_Ohm_Material_Al)
      \Density = 2.7          ; [kg/dm³]=[g/cm³]
      \Resistance = 0.0265    ; Ohm * mm² / m
      \Tcoeff_D = 23.1e-6     ; 1/K
      \Tcoeff_R = 0.0036      ; 1/K
    EndWith
    
    ; Iron 
    With MaterialProperty(#PbFw_Ohm_Material_Fe)
      \Density = 7.874        ; [kg/dm³]=[g/cm³]
      \Resistance = 0.1       ; Ohm * mm² / m
      \Tcoeff_D = 11.8e-6     ; 1/K
      \Tcoeff_R = 0.0056      ; 1/K (valid for Iron and Steel)
    EndWith
    
    ; Constantan; Konstantan, Widerstandsdraht (Kupfer 53-57%, Nickel 43-45%, Mangan 0.5-1.2%)
    With MaterialProperty(#PbFw_Ohm_Material_Constantan)
      \Density = 8.9          ; [kg/dm³]=[g/cm³]
      \Resistance = 0.5       ; Ohm * mm² / m
      \Tcoeff_D = 13.5e-6     ; 1/K
      \Tcoeff_R = 2.5e-5      ; 1/K  1e-5 .. 5e-5
    EndWith

  EndProcedure
  
  Init()
  
EndModule

 ;- ----------------------------------------------------------------------
 ;-  M O D U L E   T E S T   C O D E
 ;  ---------------------------------------------------------------------- 

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; UseModule 
  
  DisableExplicit
CompilerEndIf




; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 327
; FirstLine = 406
; Folding = -----
; Optimizer
; CPU = 5