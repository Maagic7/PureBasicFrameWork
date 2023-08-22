; ===========================================================================
;  FILE: PbFw_Module_ThermoDynamic.pb
;  NAME: Module Thermo Dynamic TD:: 
;  DESC: A Thermo dynamic library for use in
;  DESC: Air Conditioning, Vacuum Technology
;  DESC: 
;  SOURCES: td_lib from Bernd Kuemmel
;           https://www.ninelizards.com/purebasic/purebasic%2029.htm#top    "! search for TD_lib !"
;           direct download: https://www.ninelizards.com/purebasic/tdlib.zip
;           Based on: "Algorithms, Comparisons and Source References by Schlatter and Baker"
;                      https://wahiduddin.net/calc/density_algorithms.htm
;
;           "LEYBOLD Grundlagen der Vakuumtechnik Dr. Walter Umrath Koeln" from March 1997
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/30
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  It's all well known teaching knwolege and you can find ist on the web!
;             So it's free stuff for everyone!
; ===========================================================================
;{ ChangeLog: 
;   2023/08/12 S. Maag 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module


;- ---------------------------------------------------------------------------
;-  Documentation / Notes on Implementaiton
;-   ---------------------------------------------------------------------------

; Parametes usesd:
;
; T  : Ambient Temperature  [°C]
; TD : DewPoint Temperature [°C]
; P  : Pressure             [Pa] - Pascal
; rH : realtive Humidity    [%] - 0..100

DeclareModule TD          ; ThermoDynamic
  
  EnableExplicit
  
  ;- DECLARE
  
  ; ---------------------------------------------------------------------------
  ;    Pressure conversion bar <=> Pascal  
  ; ---------------------------------------------------------------------------

  ; 1Pa = 0.00001 bar +1E-5
  ; 1bar = 100.000Pa
  ; 1mbar = 100Pa
  Macro Pa_to_bar(Pa)
    Pa * 100000  
  EndMacro
  
  Macro bar_to_Pa(bar)
    bar/100000  
  EndMacro
  
  Macro Pa_to_mbar(Pa)
    Pa * 100  
  EndMacro
  
  Macro mbar_to_Pa(mBar)
    mBar/100  
  EndMacro

  ; KEYs for LatentHeat Function HEATL(KEY, TK)
  #TD_HEATL_KEY_EVAPORATION = 1   ; HEATL KEY for: EVAPORATION/CONDENSATION
  #TD_HEATL_KEY_MELTING = 2       ; HEATL KEY for: MELTING/FREEZING
  #TD_HEATL_KEY_SUBLIMATION = 3   ; HEATL KEY for: SUBLIMATION/DEPOSITION
      
  ; SATURATION VAPOR PRESSURE Functions calcualted with different aproximations  
  Declare.d ESAT(T.d)               ; SATURATION VAPOR PRESSURE ESAT  [Pa] OVER WATER (NORDQUIST ALGORITHM, 1973)
  Declare.d ESW (T.d)               ; SATURATION VAPOR PRESSURE ESW   [Pa] OVER WATER (HERMAN WOBUS POLYNOMIAL APPROXIMATION, -50..:100°C)
  Declare.d ES  (T.d)               ; SATURATION VAPOR PRESSURE ES    [Pa] OVER WATER (FORMULA BY BOLTON, DAVID, 1980 -35..35C°C)
  
  Declare.d ESICE(T.d)              ; SATURATION VAPOR PRESSURE ESICE [Pa] OVER ICE   (GOFF-GRATCH FORMULA, 1963)
  Declare.d ESILO(T.d)              ; SATURATION VAPOR PRESSURE ESILO [Pa] OVER ICE   (LOWE, PAUL R., POLYNOMIAL APPROXIMATING; 1977) 
     
  Declare.d DewPoint (T.d, rH.d)    ; DEW POINT [°C] GIVEN THE TEMPERATURE [°C] AND RELATIVE HUMIDITY [%]
  Declare.d Humidity (T.d, TD.d)    ; RELATIVE HUMIDITY [%] At GIVEN TEMPERATURE [°C] AND DEW POINT TD [°C]
   
  Declare.d LatentHeat(TK.d, Key.i=#TD_HEATL_KEY_EVAPORATION) ; LATENT HEAT OF EVAPORATION/CONDENSATION, MELTING/FREEZING, SUBLIMATION/DEPOSITION

  Declare.d Rwet(T.d, P.d, rH.d)              ; SPECIFIC GAS CONSTATN OF WET AIR [J/(kg*K)] ; by S.Maag
  Declare.d AirDensity(T.d, P.d, rH.d)        ; AIR DENSITY: OF MOIST AIR [kg/m³]           ; by S.Maag
  Declare.d AirEntalpie_kJ(T.d, P.d, rH.d)    ; AIR ENTHALPIE: OF MOIST AIR [kJ/kg]         ; by S.Maag
  Declare.d AirEntalpie_kWh(T.d, P.d, rH.d)   ; AIR ENTHALPIE: OF MOIST AIR [kWh/m³]        ; by S.Maag

  ; Functions using the LEYBOLD TABLE  with corresponding TD,  ESAT , pD %D  
  Declare.d GetDewPointFromTable(ESAT.d)     ; DEW POINT [°C], GIVEN THE SATURATION WATER VAPOR PRESSURE ESAT [Pa]
  
EndDeclareModule

;- ---------------------------------------------------------------------------
;- MODULE
;   ---------------------------------------------------------------------------

Module TD         ; ThermoDynamic
  EnableExplicit  
    
  #TD_RUni = 8.3145           ; universal gas constant 8,3145 J/(mol*K)
  #TD_Rdry = 287.058          ; specific gas constant of dry air  287,058 J/(kg*K)
  #TD_Rsteam = 461.523        ; specific gas constant of steam  : 461.523 J/(kg*K)
  
  ; SATURATION VAPOR PRESSURE OVER WATER AT 0°C [Pa]
  ; bevor 1976 ES0 was saturation varpor pressure was measured between 25.100°C and the value for 0°C was calculated with aproximations 
  #TD_ES0 = 611.21           ; Guildner, Johnson, and Jones 1976. highly accurate measurements of the vapor pressure 
  ; #TD_ES0 = 610.752         ; 1971, Wexler and Greenspan equatio
  
  #TD_CK = 273.15            ; Offset Kelvin to Celsius; Kelvon = Celsius -273.15°C
      
  Procedure.d ESAT(T.d)       ;   (NORDQUIST ALGORITHM, 1973)   
  ; ======================================================================
  ; NAME: ESAT
  ; DESC: Saturation vapor pressure over water
  ; VAR(T.d): Temperature in Celsius
  ; RET.d: ESAT [mbar]
  ; ======================================================================
    Protected TK.d, mBar.d , p1.d , p2.d , c1.d
    ;
    ; *** matches
    ;
    ;       FUNCTION ESAT(T)
    ;
    ;   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER
    ;   WATER (MB) GIVEN THE TEMPERATURE (CELSIUS).
    ;   THE ALGORITHM IS DUE To NORDQUIST, W.S.,1973: "NUMERICAL APPROXIMA-
    ;   TIONS OF SELECTED METEORLOLGICAL PARAMETERS For CLOUD PHYSICS PROB-
    ;   LEMS," ECOM-5475, ATMOSPHERIC SCIENCES LABORATORY, U.S. ARMY
    ;   ELECTRONICS COMMAND, WHITE SANDS MISSILE RANGE, NEW MEXICO 88002.
    ;
    ;         TK = T+273.15
    ;
    TK = T + #TD_CK
    ;
    ;         P1 = 11.344-0.0303998*TK
    ;
    p1 = 11.344 - 0.0303998 * TK
    ;
    ;         P2 = 3.49149-1302.8844/TK
    ;
    p2 = 3.49149 - 1302.8844 / TK
    ;
    ;         C1 = 23.832241-5.02808*ALOG10(TK)
    ;
    c1 = 23.832241 - 5.028208 * Log10(TK)
    ;
    ;         ESAT[mbar] = 10.**(C1-1.3816E-7*10.**P1+8.1328E-3*10.**P2-2949.076/TK)
    ;
    mBar = Pow(10, (c1 - 1.3816E-7 * Pow(10, p1) + 8.1328E-3 * Pow(10, p2) - 2949.076 / TK ))
    
     ProcedureReturn mBar *100                           
  EndProcedure
  
  Procedure.d ESW(T.d)  ; (HERMAN WOBUS POLYNOMIAL APPROXIMATION, -50..:100°C)
  ; ======================================================================
  ; NAME: ESW
  ; DESC: Saturation vapor pressure over water
  ; VAR(T.d): Temperature [°C] 
  ; RET.d: Pressure [Pa]
  ; ======================================================================
    Protected pol.d
    ;
    ; *** matches
    ;
    ;       FUNCTION ESW(T)
    ;
    ;   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE ESW (MILLIBARS)
    ;   OVER LIQUID WATER GIVEN THE TEMPERATURE T (CELSIUS). THE POLYNOMIAL
    ;   APPROXIMATION BELOW IS DUE To HERMAN WOBUS, A MATHEMATICIAN WHO
    ;   WORKED AT THE NAVY WEATHER RESEARCH FACILITY, NORFOLK, VIRGINIA,
    ;   BUT WHO IS NOW RETIRED. THE COEFFICIENTS OF THE POLYNOMIAL WERE
    ;   CHOSEN To FIT THE VALUES IN TABLE 94 ON PP. 351-353 OF THE SMITH-
    ;   SONIAN METEOROLOGICAL TABLES BY ROLAND List (6TH EDITION). THE
    ;   APPROXIMATION IS VALID For -50 < T < 100C.
    ;
    ;   ES0 = SATURATION VAPOR RESSURE OVER LIQUID WATER AT 0C
    ;
    ;       Data ES0/6.1078/
    ;
    ;
    ;       POL = 0.99999683       + T*(-0.90826951E-02 +
    ;    1     T*(0.78736169E-04   + T*(-0.61117958E-06 +
    ;    2     T*(0.43884187E-08   + T*(-0.29883885E-10 +
    ;    3     T*(0.21874425E-12   + T*(-0.17892321E-14 +
    ;    4     T*(0.11112018E-16   + T*(-0.30994571E-19)))))))))
    ;
    ;
    pol = T * ( 0.11112018E-16 + T * (-0.30994571E-19 ))
    pol = T * ( 0.21874425E-12 + T * (-0.17892321E-14 + pol ))
    pol = T * ( 0.43884187E-08 + T * (-0.29883885E-10 + pol ))
    pol = T * ( 0.78736169E-04 + T * (-0.61117958E-06 + pol ))
    pol = 0.99999683 + T * ( -0.90826951E-02 + pol )
    ;
    ; #ES0= 6.1078 ; old ES0 from the 1960,
    ; ESW = ES0/POL**8
  
    ; ESW = 6.1078 / Pow(pol, 8)  ; mBar
    ; ESW = 610.78 / Pow(pol, 8)  ; Pa
    ;
    ProcedureReturn 610.78 / Pow(pol, 8)                                     
  EndProcedure
  
  Procedure.d ES(T.d)       ; (FORMULA BY BOLTON, DAVID, 1980 -35..35C°C)
  ; ======================================================================
  ; NAME: ES
  ; DESC: saturation vapor pression over liquid water
  ; VAR(T.d): Temeprature [°C]
  ; RET.d: Pressure [Pa]
  ; ======================================================================
    Protected ES.d
    ;
    ; *** matches
    ;
    ;       FUNCTION ES(T)
    ;
    ;   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE ES (MB) OVER
    ;   LIQUID WATER GIVEN THE TEMPERATURE T (CELSIUS). THE FORMULA APPEARS
    ;   IN BOLTON, DAVID, 1980: "THE COMPUTATION OF EQUIVALENT POTENTIAL
    ;   TEMPERATURE," MONTHLY WEATHER REVIEW, VOL. 108, NO. 7 (JULY),
    ;   P. 1047, EQ.(10). THE QUOTED ACCURACY IS 0.3% Or BETTER For
    ;   -35 < T < 35C.
    ;
    ;
    ;   ES0 = SATURATION VAPOR PRESSURE OVER LIQUID WATER AT 0°C
    ;
    ;       Data ES0/6.1121/
    ;       ES = ES0*Exp(17.67*T/(T+243.5))
    ;       Return
    ;       End
    ;
    ; -35..35°C
    #A = 17.67
    #B = 243.5
    
    ; -45..60°C
    ;#A = 17.62
    ;#B = 243.12
    
    ; -30..70°C
    ;#A = 17.5043
    ;#B = 241.2

    ;ES = 6.1121 * Exp( #A * T / ( T + #B ))  ; mBar
    ES = #TD_ES0 * Exp( #A * T / ( T + #B ))  ; Pa
    
   ProcedureReturn ES                                       
  EndProcedure  
  
  Procedure.d ESICE(T.d)   ; (GOFF-GRATCH FORMULA, 1963)
  ; ======================================================================
  ; NAME: ESICE
  ; DESC: Saturation vapor pressure over ice
  ; VAR(T.d): Temeprature [°C]
  ; RET.d: Pressure [mbar]
  ; ======================================================================
   
    #ES0 = 6.1071 ; SATURATION VAPOR PRESSURE (mbar) OVER A WATER-ICE MIXTURE AT 0°C
    #C1 = 9.09718
    #C2 = 3.56654
    #C3 = 0.876793
    
    Protected.d TF, TK, RHS, ESI
    
    ; 
    ;    THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE With RESPECT To
    ;    ICE ESICE (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS).
    ;    THE FORMULA USED IS BASED UPON THE INTEGRATION OF THE CLAUSIUS-
    ;    CLAPEYRON EQUATION BY GOFF And GRATCH.  THE FORMULA APPEARS ON P.350
    ;    OF THE SMITHSONIAN METEOROLOGICAL TABLES, SIXTH REVISED EDITION,
    ;    1963.
    
    ;         Data CTA,EIS/273.15,6.1071/
    ; 
    ;    CTA = DIFFERENCE BETWEEN KELVIN And CELSIUS TEMPERATURE
    ;    EIS = SATURATION VAPOR PRESSURE (MB) OVER A WATER-ICE MIXTURE AT 0C
    ; 
    ;         Data C1,C2,C3/9.09718,3.56654,0.876793/
    ; 
    ;    C1,C2,C3 = EMPIRICAL COEFFICIENTS IN THE GOFF-GRATCH FORMULA
    ; 
    ;         If (T.LE.0.) GO To 5
    ;         ESICE = 99999.
    ;         WRITE(6,3)ESICE
    ;         UNLOCK (6)
    ;     3   FORMAT(' SATURATION VAPOR PRESSURE FOR ICE CANNOT BE COMPUTED',
    ;     1         /' FOR TEMPERATURE > 0C. ESICE =',F7.0)
    ;         Return
    ;     5   Continue
    ; 
    ;    TF FREEZING POINT OF WATER (K)
    ;         TF = CTA
    ;         TK = T+CTA
    ; 
    ;    GOFF-GRATCH FORMULA
    ; 
    ;         RHS = -C1*(TF/TK-1.)-C2*ALOG10(TF/TK)+C3*(1.-TK/TF)+ALOG10(EIS)
    ;         ESI = 10.**RHS
    ;         If (ESI.LT.0.) ESI = 0.
    ;         ESICE = ESI
    ;         Return
    ;         End
  
    If T < 0
      ; SATURATION VAPOR PRESSURE FOR ICE CANNOT BE COMPUTED! TEMPERTURE TO HIGH!
      ProcedureReturn NaN()   ; Not a Number or Infinity() of a float or double
      ; you can test the validty of Calculation in your Code with PureBasic Command IsNaN() - Is_Not_a_Number!
    Else 
      
      TF = #TD_CK         ; FREEZING POINT OF WATER (K)
      TK = T + #TD_CK     ; Temperatur T °C => T Kelvin
      
      ; GOFF-GRATCH FORMULA
  
      RHS = -#C1*(TF/TK -1) - #C2 * Log10(TF/TK) + #C3*(1-TK/TF) + Log10(#ES0)
      ESI = Pow(10, RHS)
      
      If ESI < 0 : ESI = 0 : EndIf
      
      ProcedureReturn ESI
      
    EndIf
    
   EndProcedure
      
  Procedure.d ESILO(T.d)  ; (LOWE, PAUL R., POLYNOMIAL APPROXIMATING; 1977)
  ; ======================================================================
  ; NAME: ESILO
  ; DESC: Saturation vapor pressure over ice
  ; VAR(T.d): Temeprature [°C]
  ; RET.d: Pressure [mbar]
  ; ======================================================================
     
    #A0=6.109177956
    #A1=5.034698970E-01
    #A2=1.886013408E-02
    #A3=4.176223716E-04
    #A4=5.824720280E-06     
    #A5=4.838803174E-08
    #A6=1.838826904E-10
   
      ; C   THIS FUNCTION RETURNS THE SATURATION VAPOR PRESSURE OVER ICE
      ; C   ESILO (MILLIBARS) GIVEN THE TEMPERATURE T (CELSIUS). THE FORMULA
      ; C   IS DUE To LOWE, PAUL R., 1977: AN APPROXIMATING POLYNOMIAL For 
      ; C   THE COMPUTATION OF SATURATION VAPOR PRESSURE, JOURNAL OF APPLIED
      ; C   METEOROLOGY, VOL. 16, NO. 1 (JANUARY), PP. 100-103.
      ; C   THE POLYNOMIAL COEFFICIENTS ARE A0 THROUGH A6.
      ; 
      ;         Data A0,A1,A2,A3,A4,A5,A6
      ;      1  /6.109177956,     5.034698970E-01, 1.886013408E-02,
      ;      2   4.176223716E-04, 5.824720280E-06, 4.838803174E-08,
      ;      3   1.838826904E-10/
      ;         If (T.LE.0.) GO To 5
      ;         ESILO = 9999.
      ;         WRITE(6,3)ESILO
      ;         UNLOCK (6)
      ;      3   FORMAT(' SATURATION VAPOR PRESSURE OVER ICE IS UNDEFINED FOR',
      ;      1  /' TEMPERATURE > 0C. ESILO =',F6.0)
      ;         Return
      ;      5  Continue
      ;         ESILO = A0+T*(A1+T*(A2+T*(A3+T*(A4+T*(A5+A6*T)))))
      ;         Return
      ;         End

    If T < 0
      ; SATURATION VAPOR PRESSURE FOR ICE CANNOT BE COMPUTED! TEMPERTURE TO HIGH!
      ProcedureReturn NaN()   ; Not a Number or Infinity() of a float or double
      ; you can test the validty of Calculation in your Code with PureBasic Command IsNaN() - Is_Not_a_Number!
    Else 
      ProcedureReturn #A0+T*(#A1+T*(#A2+T*(#A3+T*(#A4+T*(#A5+#A6*T)))))
    EndIf
        
  EndProcedure
    
  Procedure.d DewPoint(T.d, rH.d)
  ; ======================================================================
  ; NAME: DewPoint
  ; DESC: Dew point
  ; VAR(T.d): Temperature [°C] 
  ; VAR(rH.d): Relavie humidity [%]
  ; RET.d: Dew Point Temperature TD [°C]
  ; ======================================================================
    
    Protected dpd.d, x.d
    ;
    ; *** matches
    ;
    ;       FUNCTION DWPT(T,RH)
    ;
     ;   THIS FUNCTION RETURNS THE DEW Point (°C) GIVEN THE TEMPERATURE
    ;   (CELSIUS) And RELATIVE HUMIDITY (%). THE FORMULA IS USED IN THE
    ;   PROCESSING OF U.S. RAWINSONDE Data And IS REFERENCED IN PARRY, H.
    ;   DEAN, 1969: "THE SEMIAUTOMATIC COMPUTATION OF RAWINSONDES,"
    ;   TECHNICAL MEMORANDUM WBTM EDL 10, U.S. DEPARTMENT OF COMMERCE,
    ;   ENVIRONMENTAL SCIENCE SERVICES ADMINISTRATION, WEATHER BUREAU,
    ;   OFFICE OF SYSTEMS DEVELOPMENT, EQUIPMENT DEVELOPMENT LABORATORY,
    ;   SILVER SPRING, MD (OCTOBER), PAGE 9 And PAGE II-4, LINE 460.
    ;
    ;       X = 1.-0.01*RH
    ;
    x = 1 - 0.01 * rH
    ;
    ;   COMPUTE DEW POINT DEPRESSION.
    ;
    ;       DPD =(14.55+0.114*T)*X+((2.5+0.007*T)*X)**3+(15.9+0.117*T)*X**14
    ;
    dpd =( 14.55 + 0.114 * T ) * x + Pow((( 2.5 + 0.007 * T ) * x ) , 3) + ( 15.9 + 0.117 * T ) * Pow( x , 14 )
    ;
    ;       DWPT = T-DPD
    ;       Return
    ;       End
 
    ProcedureReturn T - dpd                                        
  EndProcedure
  
  Procedure.d Humidity(T.d, TD.d) 
  ; ======================================================================
  ; NAME: Humidity
  ; DESC: relative humidity
  ; VAR(T.d): Temeprature [°C]
  ; VAR(TD.d): dew point [°C]
  ; RET.d: relative humidity rH [%]
  ; ======================================================================
   Protected HUM.d
    ;
    ; *** matches
    ;
    ;       FUNCTION HUM(T,TD)
    ;
    ;   THIS FUNCTION RETURNS RELATIVE HUMIDITY (%) GIVEN THE
    ;   TEMPERATURE T And DEW POINT TD (CELSIUS).  As CALCULATED HERE,
    ;   RELATIVE HUMIDITY IS THE RATIO OF THE ACTUAL VAPOR PRESSURE To
    ;   THE SATURATION VAPOR PRESSURE.
    ;
    ;       HUM= 100.*(ESAT(TD)/ESAT(T))
    ;
    ;
    ;       Return
    ;       End
    ;
    ProcedureReturn  ESAT(TD) / ESAT(T) * 100                                       
  EndProcedure
       
  Procedure EP(T.d, rH.d)
  ; ======================================================================
  ; NAME: EP
  ; DESC: Calculates the partical pressure of the steam in the air at given 
  ; DESC: Temperatrure and Humidity
  ; DESC: (In a mixture of non-reacting gases, the total pressure exerted
  ; DESC: is equal to the sum of the partial pressures of the individual gases)
  ; VAR(T.d): Temperature [°C]
  ; VAR(rH.d): Relative humidity [%] 0..100
  ; RET.d: specific gas constand of wet Air [J/(kg*K)]
  ; ======================================================================
   
    ; Partical Pressure of wet air
    ; EP = ESAT * rH/100
    
    ProcedureReturn ESAT(T) * rH * 0.01
  EndProcedure
  
  Procedure AbsoutHumidity(T.d, rH.d)   ; [kg/m³] 
    ; ======================================================================
    ; NAME: AbsoutHumidity
    ; DESC: Calculates the max water content in air at given
    ; DESC: Temperatrure and relative Humidity
    ; VAR(T.d): Temperature [°C]
    ; VAR(rH.d): Relative humidity [%] 0..100
    ; RET.d: specific gas constand of wet Air [J/(kg*K)]
    ; ======================================================================
    
    ; ep : partial pressure (Pa]
    ; Rsteam: specific gas constant of steam
    ; TK : Temperature in Kelvin
    ;
    ;                 ep                    
    ;   pD = --------------------
    ;         Rsteam * T_Kelvin
    ;  
    ;   
    ;   pD := ep / (Rsteam * TK);
    
    Protected.d TK
    
    TK = T + #TD_CK
    
    ProcedureReturn EP(T, rH) / (#TD_Rsteam * TK)
  EndProcedure
    
  Procedure.d Rwet(T.d, P.d, rH.d)      ; by S. Maag
  ; ======================================================================
  ; NAME: Rwet
  ; DESC: Calculates the specific gas constand of wet Air
  ; VAR(T.d): Temperature [°C]
  ; VAR(P.d): Pressure [Pa] 
  ; VAR(rH.d): Relative humidity [%] 0..100
  ; RET.d: specific gas constand of wet Air [J/(kg*K)]
  ; ======================================================================
    
  ; Rdry   = gas constant of dry Air 287,058 J/(kg*K)
  ; Rsteam = gas constand of Steam   461.523 J/(kg*K)
  ; P = ambient pressure [Pa]  (100Pa = 1mbar)
    
  ;                         Rdry
  ; Rwet =  ---------------------------------------------
  ;            (   esat *rH/100                      )
  ;        1 - ( ---------------- * (1- Rdry/Rsteam) )
  ;            (      P                              )

    Protected esat.d, Rwet.d
    
    esat = ESAT(T)   ; saturation varpour pressure
    
   ;Rwet = #Rdry / ( 1- (esat * rH/100 /P) *(1-#Rdry/#Rsteam) ) 
    
   Rwet = #TD_Rdry / ( 1- (esat * rH *0.01 / P)  *(1-#TD_Rdry/#TD_Rsteam) ) 
    
    ProcedureReturn Rwet
  EndProcedure
  
  Procedure.d LatentHeat(T.d, Key.i=#TD_HEATL_KEY_EVAPORATION)
  ; ======================================================================
  ; NAME: HEATL
  ; DESC: RETURNS THE LATENT HEAT OF
  ; DESC:     EVAPORATION/CONDENSATION 
  ; DESC:     MELTING/FREEZING         
  ; DESC:     SUBLIMATION/DEPOSITION   
  ; DESC: FOR WATER. THE LATENT HEAT HEATL (J/kg) IS A
  ; DESC: FUNCTION OF TEMPERATURE T (°C). THE FORMULAS ARE POLYNOMIAL
  ; DESC: APPROXIMATIONS To THE VALUES IN TABLE 92, P. 343 OF THE SMITHSONIAN
  ; DESC: METEOROLOGICAL TABLES, SIXTH REVISED EDITION, 1963 BY ROLAND List.
  ; DESC: THE APPROXIMATIONS WERE DEVELOPED BY ERIC SMITH AT COLORADO STATE
  ; DESC: UNIVERSITY.
  ; VAR(Key)
  ; VAR(T.d): Temperature [°C]
  ; RET.d: J/kg
  ; ======================================================================
    
    ;         FUNCTION HEATL(KEY,T)
    ;
    ; C   THIS FUNCTION RETURNS THE LATENT HEAT OF
    ; C               EVAPORATION/CONDENSATION         For KEY=1
    ; C               MELTING/FREEZING                 For KEY=2
    ; C               SUBLIMATION/DEPOSITION           For KEY=3
    ; C   For WATER. THE LATENT HEAT HEATL (JOULES PER KILOGRAM) IS A
    ; C   FUNCTION OF TEMPERATURE T (CELSIUS). THE FORMULAS ARE POLYNOMIAL
    ; C   APPROXIMATIONS To THE VALUES IN TABLE 92, P. 343 OF THE SMITHSONIAN
    ; C   METEOROLOGICAL TABLES, SIXTH REVISED EDITION, 1963 BY ROLAND List.
    ; C   THE APPROXIMATIONS WERE DEVELOPED BY ERIC SMITH AT COLORADO STATE
    ; C   UNIVERSITY.
    ; C   POLYNOMIAL COEFFICIENTS
    ;
    ;         Data A0,A1,A2/ 3337118.5,-3642.8583, 2.1263947/
    ;         Data B0,B1,B2/-1161004.0, 9002.2648,-12.931292/
    ;         Data C0,C1,C2/ 2632536.8, 1726.9659,-3.6248111/
    ;         HLTNT = 0.
    ;         TK = T+273.15
    ;         If (KEY.EQ.1) HLTNT=A0+A1*TK+A2*TK*TK
    ;         If (KEY.EQ.2) HLTNT=B0+B1*TK+B2*TK*TK
    ;         If (KEY.EQ.3) HLTNT=C0+C1*TK+C2*TK*TK
    ;         HEATL = HLTNT
    ;         Return
    ;         End
    
    Protected.d a, b, c
    Protected.d TK= T+ #TD_CK

    Select Key
        
      Case #TD_HEATL_KEY_EVAPORATION
        Restore HEATL_EVAPORATION
        
      Case #TD_HEATL_KEY_MELTING
        Restore HEATL_MELTING
        
      Case #TD_HEATL_KEY_SUBLIMATION
        Restore HEATL_SUBLIMATION
        
      Default
        
    EndSelect
    
    ; READ POLYNOMIAL COEFFICIENTS FROM DataSection
    Read.d a
    Read.d b
    Read.d c
    
    ; HEATL = a + b*TK + c*TK²
    ProcedureReturn a + b * TK + c * TK * TK
    
    DataSection     ; PB supports Private DataSection in Procedure
      HEATL_EVAPORATION:
      Data.d  3337118.5,-3642.8583, 2.1263947   ; A0,A1,A2
      
      HEATL_MELTING:
      Data.d -1161004.0, 9002.2648,-12.931292   ; B0,B1,B2
      
      HEATL_SUBLIMATION:
      Data.d  2632536.8, 1726.9659,-3.6248111   ; C0,C1,C2
    EndDataSection
  
  EndProcedure

  Procedure.d AirDensity(T.d, P.d, rH.d)  
  ; ======================================================================
  ; NAME: AirDensity
  ; DESC: Air Density of moist air
  ; VAR(T.d): Temperature [°C]
  ; VAR(P.d]: Pressure [Pa]
  ; VAR(rH.d): Relative humidity [%] 0..100
  ; RET.d: Density [kg/m³]
  ; ======================================================================
    
    ; AD   : Density of wet air [kg/m³]
    ; P    : Pressure [Pa]  100Pa = 1mbar
    ; rH   : relative Humidity [0..100%]
    ; TK   : Temperature Kelvin
    ; Rwet : specific gas constant wet wet air
  
    ; AD =  P / (Rwet * TK)   ; density of wet air [kg/m³]  
       
    Protected.d  Rw
    
    Rw = Rwet(T, P, rH)   ; calculate the specific gas constant of wet air
    
    ProcedureReturn P / Rw * (T + #TD_CK)  ;  AD: density of wet air [kg/m³]  
    
  EndProcedure
  
  Procedure.d AirEntalpie_kJ(T.d, P.d, rH.d) 
  ; ======================================================================
  ; NAME: AirEntalpie_kJ
  ; DESC: Air Enthalpie H of moist air [kJ/kg]
  ; VAR(T.d): Temperature [°C]
  ; VAR(P.d]: Pressure [mbar]
  ; VAR(rH.d): Relative humidity [%] 0..100
  ; RET.d: Enthalpie, Energie [kJ/kg]
  ; ======================================================================
    ; // ----------------------------------------------------------------------
    ; //  Enthalphie [kJ/kg] 
    ; // ----------------------------------------------------------------------
    ; 
    ;     (*
    ;     Wärmekapazität Luft               : 1.005 kJ/kg
    ;     spez. Wärmekapazität Wasserdampf  : 1.86  kJ/(kg*K)
    ;     Verdampfungswärme Wasser          : 2500  kJ/kg
    ;    
    ;     H = (1.005 * T°C) +  pD*(2500+1.86 * T°C)
    ;     *)
    ;     
    ;     H := (1.005 * rTmpC) +  pD*(2500+1.86 * rTmpC);
    
    Protected.d H, PD
    
    ; PD =  
    
    H = (1.005 * T) + PD * (2500 + 1.86 * T)  
    
    ProcedureReturn H
  EndProcedure
  
  Procedure.d AirEntalpie_kWh(T.d, P.d, rH.d)  
  ; ======================================================================
  ; NAME: AirEntalpie_Wh
  ; DESC: Air Enthalpie H of moist air [kWh/m³]
  ; VAR(T.d): Temperature [°C]
  ; VAR(P.d]: Pressure [mbar]
  ; VAR(rH.d): Relative humidity [%] 0..100
  ; RET.d: Enthalpie, Energie [kWh/m³]
  ; ======================================================================
    ; // ----------------------------------------------------------------------
    ; //  Power [Wh/m³]
    ; // ----------------------------------------------------------------------
    ; 
    ;     (*
    ;     Wärmekapazität Luft               : 1.005 kJ/kg
    ;     spez. Wärmekapazität Wasserdampf  : 1.86  kJ/(kg*K)
    ;     Verdampfungswärme Wasser          : 2500  kJ/kg
    ;    
    ;     H = (1.005 * T°C) +  pD*(2500+1.86 * T°C)
    ;     *)
    ;     
    ;     H := (1.005 * rTmpC) +  pD*(2500+1.86 * rTmpC);
    ; 
    ;     // Umrechung Enthalpie => WattStunden pro m³  1J = 1Ws
    ;     // Pwr[Ws/kg] = H*1000/3600s
    ;     // PWR[Ws/m³] = H*1000/3600s * Dichte[kg/m³)
    ; 
    ;     PWR := H /3600 * AD; //[Wh/m³]
    
     
  EndProcedure

  ;- ---------------------------------------------------------------------------
  ;- Functions using LEYBOLD TABLE {TD, Pesat, %D}  
  ;- ---------------------------------------------------------------------------
  
  Structure TDataTable    ; Structure of DataTable Entries
    TD.d
    ESAT.d
    pD.d
  EndStructure
  
  Structure pDataTable    ; Pointer on DataTableStructrue = VirtualArray
    TAB.TDataTable[0]  
  EndStructure
  
  #TABLE_ESAT_ENTRIES = 241  ; -100 .. +140
  
  Define *Tab.pDataTable = ?TABLE_ESAT    ; Pointer to TABLE_ESAT as Array of TDataTable
  
  Procedure GetEsatFromTable(T.d) ; -100..140°C
    Shared *Tab.pDataTable ; Share the Pointer to TABLE_ESAT as Array 
    Protected I
    
    
  EndProcedure
  
  Procedure.d GetDewPointFromTable(P.d)
  ; ======================================================================
  ; NAME: GetDewPointFromTable
  ; DESC: Searchs the DewPointTemperature to a given Air-pressure
  ; DESC: in the AirSaturatioin Table (TABLE_ESAT:)
  ; DESC: the more exact values between a AirTemp of [-100°C..+140°C]
  ; VAR(P.d): Pressure [Pa] (saturation varpour pressure) 
  ; RET.i: Dew Point Temperature TD [°C]
  ; ======================================================================
     
    Shared *Tab.pDataTable ; Share the Pointer to TABLE_ESAT as Array 
    Protected TD.d
    Protected I, J, Size
    
    Size =  #TABLE_ESAT_ENTRIES - 1
    Debug "Size = " + Size
    
    If P < *Tab\TAB[0]\ESAT 
      TD = *Tab\TAB[0]\TD
      
    ElseIf P > *Tab\TAB[Size]\ESAT
      TD = *Tab\TAB[Size]\TD
      
    Else
      
      J=0 : I = 0
      Repeat 
        I + 10    
        Debug "Repeat I= " + I + " : ESAT = " + *Tab\TAB[I]\ESAT
      Until (I > Size) Or (P < *Tab\TAB[I]\ESAT)
      
      If I > Size 
        J = SIZE
      Else
        J = I-1
      EndIf
          
      Debug "J = " +J
      
      For I = J To 0  Step -1 
        Debug I
        If P >= *Tab\TAB[I]\ESAT
          TD = *Tab\TAB[I]\TD
          Break
        EndIf
      Next
      
    EndIf
    
    ProcedureReturn TD
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------------------
  ; Tabelle Temperatur Sättignungsdamfdruck max. Wassergehalt Temp{-100..+140}
  ; ----------------------------------------------------------------------------------------------------  
  ; Aus: LEYBOLD Grundlagen der Vakuumtechnik Dr. Walter Umrath Köln, im März 1997; Seite 150
  ; org. Quelle: Smithsonian Meteorological Tables 6th. ed. (1971) und VDI-Wasserdampftafeln 6. Ausgabe (1963).
  
  ; Tabelle XIII: Sättigungsdampfdruck ps und Dampfdichte %D von Wasser im Temperaturbereich – 100°C + 140°C
  
  ; Sättigunsdampfdruck und max. Wassergehalt bei gegebener Temperatur 
  ; Das kann verwendet werden um unter Vakuum den Wassergehalt bei einem bestimmten Druck zu ermitteln!
  ; Vakuumtrocknung: Dabei wird der Druck bestimmt durch den Restwassergehalt. Solange Wasser verdampft
  ; geht der Druck nicht nach unten. Anhand es Vakuummanometers lässt sich so der Wassergehalt der Luft ermitteln.
  ; Dies wird z.B. beim Trocken von Hochspannungstranformatoren verwendet
  ; ----------------------------------------------------------------------------------------------------

  DataSection
    ;{
 
; Saturation vapor pressure over Water fom 0..100°C original NIST Table Arnold Wexler 1776
DataSection
  TAB_ESAT_OverIce  ; -100..-1°C ; From: "LEYBOLD Grundlagen der Vakuumtechnik Dr. Walter Umrath Koeln, 1997" Page 150
  ;       °C ,  Pesat[Pa]  
  Data.d -100, 0.001403   ; -100°C ; 1.403e-5 mbar, 1.756e-5 g/m³ (max. Wassergehalt)
  Data.d -99,  0.001719
  Data.d -98,  0.002101
  Data.d -97,  0.002561
  Data.d -96,  0.003117
  Data.d -95,  0.003784
  Data.d -94,  0.004584
  Data.d -93,  0.005542
  Data.d -92,  0.006685
  Data.d -91,  0.008049
  Data.d -90,  0.009672
  Data.d -89,  0.01160
  Data.d -88,  0.01388
  Data.d -87,  0.01658
  Data.d -86,  0.01799
  Data.d -85,  0.02353
  Data.d -84,  0.02796
  Data.d -83,  0.03316
  Data.d -82,  0.03925
  Data.d -81,  0.04638
  Data.d -80,  0.05473
  Data.d -79,  0.06444
  Data.d -78,  0.07577
  Data.d -77,  0.08894
  Data.d -76,  0.1042
  Data.d -75,  0.1220
  Data.d -74,  0.1425
  Data.d -73,  0.1662
  Data.d -72,  0.1936
  Data.d -71,  0.2252
  Data.d -70,  0.2615
  Data.d -69,  0.3032
  Data.d -68,  0.3511
  Data.d -67,  0.4060
  Data.d -66,  0.4688
  Data.d -65,  0.5406
  Data.d -64,  0.6225
  Data.d -63,  0.7195
  Data.d -62,  0.8223
  Data.d -61,  0.9432
  Data.d -60,  1.080
  Data.d -59,  1.236
  Data.d -58,  1.413
  Data.d -57,  1.612
  Data.d -56,  1.838
  Data.d -55,  2.092
  Data.d -54,  2.380
  Data.d -53,  2.703
  Data.d -52,  3.067
  Data.d -51,  3.476
  Data.d -50,  3.935
  Data.d -49,  4.449
  Data.d -48,  5.026
  Data.d -47,  5.671
  Data.d -46,  6.393
  Data.d -45,  7.198
  Data.d -44,  8.097
  Data.d -43,  9.09
  Data.d -42,  10.21
  Data.d -41,  11.45
  Data.d -40,  12.83
  Data.d -39,  14.36
  Data.d -38,  16.06
  Data.d -37,  17.94
  Data.d -36,  20.02
  Data.d -35,  22.33
  Data.d -34,  24.88
  Data.d -33,  27.69
  Data.d -32,  30.79
  Data.d -31,  34.21
  Data.d -30,  37.98
  Data.d -29,  42.13
  Data.d -28,  46.69
  Data.d -27,  51.70
  Data.d -26,  57.20
  Data.d -25,  63.23
  Data.d -24,  69.85
  Data.d -23,  77.09
  Data.d -22,  85.02
  Data.d -21,  93.70
  Data.d -20,  103.20
  Data.d -19,  113.50
  
  Data.d -18,  124.80
  Data.d -17,  137.10
  Data.d -16,  150.60
  Data.d -15,  165.20
  Data.d -14,  181.10
  Data.d -13,  198.40
  Data.d -12,  217.20
  Data.d -11,  237.60
  Data.d -10,  259.70
  Data.d  -9,  283.70
  Data.d  -8,  309.70
  Data.d  -7,  337.90
  Data.d  -6,  368.50
  Data.d  -5,  401.50
  Data.d  -4,  437.20
  Data.d  -3,  457.50
  Data.d  -2,  517.30
  Data.d  -1,  562.30

  TAB_ESAT_100:  ; Temperature [°C] = Pressure [Pa] ; Values form original NIST Table 1976 
  ;      °C,       .0 ,       .1 ,       .2 ,       .3 ,       .4 ,       .5 ,       .6 ,       .7 ,       .8 ,      .9 ,
  Data.d  0,    611.21,    615.67,    620.15,    624.66,    629.20,    633.77,    638.37,    643.00,    647.66,    652.35
  Data.d  1,    657.07,    661.82,    666.60,    671.41,    676.25,    681.12,    686.02,    690.96,    695.92,    700.92
  Data.d  2,    705.95,    711.01,    716.10,    721.23,    726.39,    731.58,    736.80,    742.06,    747.34,    752.67
  Data.d  3,    758.02,    763.41,    768.84,    774.29,    779.79,    785.31,    790.87,    796.47,    802.10,    807.77
  Data.d  4,    813.47,    819.20,    824.98,    830.79,    836.63,    842.51,    848.43,    854.38,    860.38,    866.40
  Data.d  5,    872.47,    878.57,    884.71,    890.89,    897.11,    903.36,    909.66,    915.99,    922.36,    928.77
  Data.d  6,    935.22,    941.71,    948.24,    954.81,    961.42,    968.07,    974.76,    981.49,    988.26,    995.08
  Data.d  7,   1001.93,   1008.83,   1015.76,   1022.74,   1029.77,   1036.83,   1043.94,   1051.09,   1058.29,   1065.52
  Data.d  8,   1072.80,   1080.13,   1087.50,   1094.91,   1102.37,   1109.87,   1117.42,   1125.01,   1132.65,   1140.33
  Data.d  9,   1148.06,   1155.84,   1163.66,   1171.53,   1179.45,   1187.41,   1195.42,   1203.48,   1211.58,   1219.74
  Data.d 10,   1227.94,   1236.19,   1244.49,   1252.84,   1261.24,   1269.68,   1278.18,   1286.73,   1295.33,   1303.97
  Data.d 11,   1312.67,   1321.42,   1330.22,   1339.08,   1347.98,   1356.94,   1365.95,   1375.01,   1384.12,   1393.29
  Data.d 12,   1402.51,   1411.79,   1421.11,   1430.50,   1439.93,   1449.43,   1458.97,   1468.58,   1478.23,   1487.95
  Data.d 13,   1497.72,   1507.54,   1517.43,   1527.36,   1537.36,   1547.42,   1557.53,   1567.70,   1577.93,   1588.21
  Data.d 14,   1598.56,   1608.96,   1619.43,   1629.95,   1640.54,   1651.18,   1661.89,   1672.65,   1683.48,   1694.37
  Data.d 15,   1705.32,   1716.33,   1727.41,   1738.54,   1749.75,   1761.01,   1772.34,   1783.73,   1795.18,   1806.70
  Data.d 16,   1818.29,   1829.94,   1841.66,   1853.44,   1865.29,   1877.20,   1889.18,   1901.23,   1913.34,   1925.53
  Data.d 17,   1937.78,   1950.10,   1962.48,   1974.94,   1987.47,   2000.06,   2012.73,   2025.46,   2038.27,   2051.14
  Data.d 18,   2064.09,   2077.11,   2090.20,   2103.37,   2116.61,   2129.92,   2143.30,   2156.75,   2170.29,   2183.89
  Data.d 19,   2197.57,   2211.32,   2225.15,   2239.06,   2253.04,   2267.10,   2281.23,   2295.44,   2309.73,   2324.10
  Data.d 20,   2338.54,   2353.07,   2367.67,   2382.35,   2397.11,   2411.95,   2426.88,   2441.88,   2456.94,   2472.13
  Data.d 21,   2487.37,   2502.70,   2518.11,   2533.61,   2549.18,   2564.85,   2580.59,   2596.42,   2612.33,   2628.33
  Data.d 22,   2644.42,   2660.59,   2676.85,   2693.19,   2709.62,   2726.14,   2742.75,   2759.45,   2776.23,   2793.10
  Data.d 23,   2810.06,   2827.12,   2844.26,   2861.49,   2878.82,   2896.23,   2913.74,   2931.34,   2949.04,   2966.82
  Data.d 24,   2984.70,   3002.68,   3020.74,   3038.91,   3057.17,   3075.52,   3093.97,   3112.52,   3131.16,   3149.90
  Data.d 25,   3168.74,   3187.68,   3206.71,   3225.85,   3245.08,   3264.41,   3283.85,   3303.38,   3323.02,   3342.76
  Data.d 26,   3362.60,   3382.54,   3402.59,   3422.73,   3442.99,   3463.34,   3483.81,   3504.37,   3525.05,   3545.83
  Data.d 27,   3566.71,   3587.71,   3608.81,   3630.02,   3651.33,   3672.76,   3694.29,   3715.94,   3737.69,   3759.56
  Data.d 28,   3781.54,   3803.63,   3825.83,   3848.14,   3870.57,   3893.11,   3915.77,   3938.54,   3961.42,   3984.42
  Data.d 29,   4007.54,   4030.77,   4054.12,   4077.59,   4101.18,   4124.88,   4148.71,   4172.65,   4196.71,   4220.90
  Data.d 30,   4245.20,   4269.63,   4294.18,   4318.85,   4343.64,   4368.56,   4393.60,   4418.77,   4444.06,   4469.48
  Data.d 31,   4495.02,   4520.69,   4546.49,   4572.42,   4598.47,   4624.65,   4650.96,   4677.41,   4703.98,   4730.68
  Data.d 32,   4757.52,   4784.48,   4811.58,   4838.81,   4866.18,   4893.68,   4921.32,   4949.09,   4976.99,   5005.04
  Data.d 33,   5033.22,   5061.53,   5089.99,   5118.58,   5147.32,   5176.19,   5205.20,   5234.36,   5263.65,   5293.09
  Data.d 34,   5322.67,   5352.39,   5382.26,   5412.27,   5442.43,   5472.73,   5503.18,   5533.78,   5564.52,   5595.41
  Data.d 35,   5626.45,   5657.64,   5688.97,   5720.46,   5752.10,   5783.89,   5815.83,   5847.93,   5880.17,   5912.58
  Data.d 36,   5945.13,   5977.84,   6010.71,   6043.73,   6076.91,   6110.25,   6143.75,   6177.40,   6211.22,   6245.19
  Data.d 37,   6279.33,   6313.62,   6348.08,   6382.70,   6417.48,   6452.43,   6487.54,   6522.82,   6558.26,   6593.87
  Data.d 38,   6629.65,   6665.59,   6701.71,   6737.99,   6774.44,   6811.06,   6847.85,   6884.82,   6921.95,   6959.26
  Data.d 39,   6996.75,   7034.40,   7072.24,   7110.24,   7148.43,   7186.79,   7225.33,   7264.04,   7302.94,   7342.02
  Data.d 40,   7381.27,   7420.71,   7460.33,   7500.13,   7540.12,   7580.28,   7620.64,   7661.18,   7701.90,   7742.81
  Data.d 41,   7783.91,   7825.20,   7866.67,   7908.34,   7950.19,   7992.24,   8034.47,   8076.90,   8119.53,   8162.34
  Data.d 42,   8205.36,   8248.56,   8291.96,   8335.56,   8379.36,   8423.36,   8467.55,   8511.94,   8556.54,   8601.33
  Data.d 43,   8646.33,   8691.53,   8736.93,   8782.54,   8828.35,   8874.37,   8920.59,   8967.02,   9013.66,   9060.51
  Data.d 44,   9107.57,   9154.84,   9202.32,   9250.01,   9297.91,   9346.03,   9394.36,   9442.91,   9491.67,   9540.65
  Data.d 45,   9589.84,   9639.25,   9688.89,   9738.74,   9788.81,   9839.11,   9889.62,   9940.36,   9991.32,  10042.51
  Data.d 46,  10093.92,  10145.56,  10197.43,  10249.52,  10301.84,  10354.39,  10407.18,  10460.19,  10513.43,  10566.91
  Data.d 47,  10620.62,  10674.57,  10728.75,  10783.16,  10837.82,  10892.71,  10947.84,  11003.21,  11058.82,  11114.67
  Data.d 48,  11170.76,  11227.10,  11283.68,  11340.50,  11397.57,  11454.88,  11512.45,  11570.26,  11628.32,  11686.63
  Data.d 49,  11745.19,  11804.00,  11863.07,  11922.38,  11981.96,  12041.78,  12101.87,  12162.21,  12222.81,  12283.66  
  Data.d 50,  12344.78,  12406.16,  12467.79,  12529.70,  12591.86,  12654.29,  12716.98,  12779.94,  12843.17,  12906.66
  Data.d 51,  12970.42,  13034.46,  13098.76,  13163.33,  13228.18,  13293.30,  13358.70,  13424.37,  13490.32,  13556.54
  Data.d 52,  13623.04,  13689.82,  13756.88,  13824.23,  13891.85,  13959.76,  14027.95,  14096.43,  14165.19,  14234.24
  Data.d 53,  14303.57,  14373.20,  14443.11,  14513.32,  14583.82,  14654.61,  14725.69,  14797.07,  14868.74,  14940.72
  Data.d 54,  15012.98,  15085.55,  15158.42,  15231.59,  15305.06,  15378.83,  15452.90,  15527.28,  15601.97,  15676.96
  Data.d 55,  15752.26,  15827.87,  15903.79,  15980.02,  16056.57,  16133.42,  16210.59,  16288.07,  16365.87,  16443.99
  Data.d 56,  16522.43,  16601.18,  16680.26,  16759.65,  16839.37,  16919.41,  16999.78,  17080.47,  17161.49,  17242.84
  Data.d 57,  17324.51,  17406.52,  17488.86,  17571.52,  17654.53,  17737.86,  17821.53,  17905.54,  17989.88,  18074.57
  Data.d 58,  18159.59,  18244.95,  18330.66,  18416.71,  18503.10,  18589.84,  18676.92,  18764.35,  18852.13,  18940.26
  Data.d 59,  19028.74,  19117.58,  19206.76,  19296.30,  19386.20,  19476.45,  19567.06,  19658.03,  19749.35,  19841.04
  Data.d 60,  19933.09,  20025.51,  20118.29,  20211.43,  20304.95,  20398.82,  20493.07,  20587.69,  20682.68,  20778.05
  Data.d 61,  20873.78,  20969.90,  21066.39,  21163.25,  21260.50,  21358.12,  21456.13,  21554.51,  21653.28,  21752.44
  Data.d 62,  21851.98,  21951.91,  22052.23,  22152.93,  22254.03,  22355.52,  22457.40,  22559.68,  22662.35,  22765.42
  Data.d 63,  22868.89,  22972.75,  23077.02,  23181.69,  23286.76,  23392.23,  23498.12,  23604.40,  23711.10,  23818.20
  Data.d 64,  23925.72,  24033.65,  24141.99,  24250.74,  24359.91,  24469.50,  24579.51,  24689.93,  24800.78,  24912.04
  Data.d 65,  25023.74,  25135.85,  25248.39,  25361.36,  25474.76,  25588.58,  25702.84,  25817.53,  25932.66,  26048.22
  Data.d 66,  26164.21,  26280.64,  26397.52,  26514.83,  26632.58,  26750.78,  26869.42,  26988.51,  27108.04,  27228.02
  Data.d 67,  27348.46,  27469.34,  27590.68,  27712.46,  27834.71,  27957.41,  28080.57,  28204.19,  28328.26,  28452.80
  Data.d 68,  28577.81,  28703.28,  28829.21,  28955.61,  29082.48,  29209.82,  29337.64,  29465.92,  29594.68,  29723.92
  Data.d 69,  29853.63,  29983.82,  30114.49,  30245.65,  30377.28,  30509.40,  30642.01,  30775.10,  30908.68,  31042.75
  Data.d 70,  31177.32,  31312.37,  31447.92,  31583.97,  31720.51,  31857.55,  31995.09,  32133.14,  32271.68,  32410.73
  Data.d 71,  32550.29,  32690.35,  32830.93,  32972.01,  33113.61,  33255.71,  33398.34,  33541.48,  33685.13,  33829.31
  Data.d 72,  33974.01,  34119.23,  34264.97,  34411.24,  34558.03,  34705.36,  34853.21,  35001.59,  35150.51,  35299.96
  Data.d 73,  35449.95,  35600.47,  35751.54,  35903.14,  36055.29,  36207.98,  36361.21,  36514.99,  36669.32,  36824.20
  Data.d 74,  36979.63,  37135.61,  37292.15,  37449.24,  37606.89,  37765.10,  37923.87,  38083.21,  38243.10,  38403.56
  Data.d 75,  38564.59,  38726.19,  38888.36,  39051.10,  39214.41,  39378.30,  39542.76,  39707.80,  39873.42,  40039.63
  Data.d 76,  40206.41,  40373.78,  40541.74,  40710.28,  40879.42,  41049.14,  41219.46,  41390.37,  41561.88,  41733.99
  Data.d 77,  41906.69,  42080.00,  42253.91,  42428.42,  42603.54,  42779.27,  42955.61,  43132.55,  43310.11,  43488.29
  Data.d 78,  43667.08,  43846.48,  44026.51,  44207.16,  44388.43,  44570.33,  44752.85,  44936.00,  45119.77,  45304.18
  Data.d 79,  45489.23,  45674.91,  45861.22,  46048.17,  46235.76,  46424.00,  46612.87,  46802.39,  46992.56,  47183.38
  Data.d 80,  47374.85,  47566.97,  47759.74,  47953.17,  48147.25,  48342.00,  48537.40,  48733.47,  48930.20,  49127.60
  Data.d 81,  49325.67,  49524.40,  49723.81,  49923.89,  50124.64,  50326.08,  50528.19,  50730.98,  50934.45,  51138.61
  Data.d 82,  51343.45,  51548.98,  51755.20,  51962.11,  52169.72,  52378.01,  52587.01,  52796.70,  53007.10,  53218.20
  Data.d 83,  53430.00,  53642.50,  53855.72,  54069.64,  54284.28,  54499.63,  54715.69,  54932.47,  55149.97,  55368.19
  Data.d 84,  55587.13,  55806.80,  56027.20,  56248.32,  56470.17,  56692.76,  56916.08,  57140.13,  57364.92,  57590.45
  Data.d 85,  57816.73,  58043.74,  58271.51,  58500.02,  58729.27,  58959.28,  59190.05,  59421.57,  59653.84,  59886.87
  Data.d 86,  60120.67,  60355.23,  60590.55,  60826.64,  61063.50,  61301.12,  61539.52,  61778.70,  62018.65,  62259.38
  Data.d 87,  62500.89,  62743.18,  62986.26,  63230.12,  63474.78,  63720.22,  63966.45,  64213.48,  64461.31,  64709.93
  Data.d 88,  64959.35,  65209.58,  65460.61,  65712.45,  65965.09,  66218.55,  66472.82,  66727.90,  66983.80,  67240.52
  Data.d 89,  67498.06,  67756.42,  68015.60,  68275.62,  68536.46,  68798.13,  69060.64,  69323.98,  69588.15,  69853.17
  Data.d 90,  70119.03,  70385.73,  70653.28,  70921.67,  71190.91,  71461.01,  71731.96,  72003.76,  72276.42,  72549.95
  Data.d 91,  72824.33,  73099.58,  73375.70,  73652.68,  73930.54,  74209.27,  74488.87,  74769.35,  75050.71,  75332.95
  Data.d 92,  75616.07,  75900.08,  76184.98,  76470.77,  76757.44,  77045.02,  77333.49,  77622.86,  77913.13,  78204.30
  Data.d 93,  78496.38,  78789.36,  79083.26,  79378.06,  79673.78,  79970.42,  80267.97,  80566.45,  80865.85,  81166.17
  Data.d 94,  81467.42,  81769.60,  82072.71,  82376.75,  82681.73,  82987.65,  83294.51,  83602.31,  83911.06,  84220.75
  Data.d 95,  84531.40,  84842.99,  85155.54,  85469.05,  85783.51,  86098.94,  86415.33,  86732.68,  87051.00,  87370.29
  Data.d 96,  87690.56,  88011.80,  88334.01,  88657.20,  88981.38,  89306.54,  89632.68,  89959.82,  90287.94,  90617.06
  Data.d 97,  90947.17,  91278.28,  91610.39,  91943.50,  92277.62,  92612.74,  92948.87,  93286.02,  93624.18,  93963.35
  Data.d 98,  94303.54,  94644.76,  94986.99,  95330.26,  95674.55,  96019.87,  96366.23,  96713.62,  97062.05,  97411.51
  Data.d 99,  97762.02,  98113.58,  98466.18,  98819.83,  99174.54,  99530.30,  99887.11, 100244.99, 100603.93, 100963.93
  
  TAB_ESAT_140  ; From: "LEYBOLD Grundlagen der Vakuumtechnik Dr. Walter Umrath Koeln, 1997" Page 150
  Data.d 100, 101325 
  Data.d 101, 105000
  Data.d 102, 108800
  Data.d 103, 112700
  Data.d 104, 116700
  Data.d 105, 120800
  Data.d 106, 125000
  Data.d 107, 129400
  Data.d 108, 133900
  Data.d 109, 138500
  Data.d 110, 143300
  Data.d 111, 148100
  Data.d 112, 153200
  Data.d 113, 158300
  Data.d 114, 163600
  Data.d 115, 169100
  Data.d 116, 174600
  Data.d 117, 180400
  Data.d 118, 186300
  Data.d 119, 192300
  Data.d 120, 198500
  Data.d 121, 204900
  Data.d 122, 211400
  Data.d 123, 218200
  Data.d 124, 225000
  Data.d 125, 232100
  Data.d 126, 239300
  Data.d 127, 246700
  Data.d 128, 254300
  Data.d 129, 262100
  Data.d 130, 270100
  Data.d 131, 278300
  Data.d 132, 286700
  Data.d 133, 295300
  Data.d 134, 304100
  Data.d 135, 313100
  Data.d 136, 322300
  Data.d 137, 331700
  Data.d 138, 341400
  Data.d 139, 351200
  Data.d 140, 361400
  
  ; BOSCH Wasser-DAmpf-Tafel : Stoffwerte für Wasser und Dampf nach IAPWS IF-97
  ; PO : Over Presssure             [bar]
  ; PA : Absolute Pressure          [bar]
  ; TB : Boiling Temperature        [°C]
  ; HW : Enthalpie Water            [kJ/kgK]  h'
  ; HS : Enthalpie saturated Steam  [kJ/kgK]  h''
  ; HV : Enthalpie Vaporisation     [kJ/kgK]
  ; DW : Density Water              [kg/m³]   p'
  ; DS : Density saturated Steam    [kg/m³]   p''
  
  ; dVW : dynamic viscosity Water         [uPas]  n'
  ; dVS : dynamic viscosity sat. Steam    [uPas]  n''
  ; tCW : thermal conductivity Water      [W/mK]  l'   (lambda')
  ; tCS : thermal conductivity sat. Steam [W/mK]  l''
  
  BOSCH_STEAM_TABLE:
  ;       PO ,  PA ,    TB ,      HW ,    HS ,     HV ,    DW ,     DW,    dVW ,   dVS ,    tCW ,    tCS
  Data.d –0.9,  0.1,   45.8,   191.8,  2583.9,  2392.1,  989.8,  0.0682,  587.5,  10.49,  0.6357,  0.0199
  Data.d –0.8,  0.2,   60.1,   251.4,  2608.9,  2357.5,  983.1,  0.1308,  465.9,  10.94,  0.6508,  0.0211
  Data.d –0.7,  0.3,   69.1,   289.2,  2624.6,  2335.3,  978.3,  0.1913,  408.9,  11.23,  0.6588,  0.0219
  Data.d –0.6,  0.4,   75.9,   317.6,  2636.1,  2318.5,  974.3,  0.2504,  373.5,  11.45,  0.6641,  0.0225
  Data.d –0.5,  0.5,   81.3,   340.5,  2645.2,  2304.7,  971.0,  0.3086,  348.6,  11.64,  0.6678,  0.0230
  Data.d –0.4,  0.6,   85.9,   359.8,  2652.9,  2293.0,  968.0,  0.3661,  329.7,  11.79,  0.6707,  0.0234
  Data.d –0.3,  0.7,   89.9,   376.7,  2659.4,  2282.7,  965.4,  0.4229,  314.7,  11.93,  0.6730,  0.0238
  Data.d –0.2,  0.8,   93.5,   391.6,  2665.2,  2273.5,  962.9,  0.4791,  302.3,  12.05,  0.6748,  0.0241
  Data.d –0.1,  0.9,   96.7,   405.1,  2670.3,  2265.2,  960.7,  0.5349,  291.9,  12.16,  0.6763,  0.0245
  Data.d  0.0,  1.0,   99.6,   417.4,  2674.9,  2257.5,  958.6,  0.5903,  282.9,  12.26,  0.6776,  0.0248
  Data.d  0.1,  1.1,  102.3,   428.8,  2679.2,  2250.4,  956.7,  0.6453,  275.1,  12.35,  0.6787,  0.0250
  Data.d  0.2,  1.2,  104.8,   439.3,  2683.1,  2243.8,  954.9,  0.7001,  268.2,  12.43,  0.6796,  0.0253
  Data.d  0.3,  1.3,  107.1,   449.1,  2686.6,  2237.5,  953.1,  0.7545,  262.0,  12.51,  0.6804,  0.0255
  Data.d  0.4,  1.4,  109.3,   458.4,  2690.0,  2231.6,  951.5,  0.8086,  256.4,  12.59,  0.6811,  0.0258
  Data.d  0.5,  1.5,  111.4,   467.1,  2693.1,  2226.0,  949.9,  0.8625,  251.4,  12.66,  0.6817,  0.0260
  Data.d  0.6,  1.6,  113.3,   475.3,  2696.0,  2220.7,  948.4,  0.9162,  246.8,  12.73,  0.6822,  0.0262
  Data.d  0.7,  1.7,  115.1,   483.2,  2698.8,  2215.6,  947.0,  0.9697,  242.5,  12.79,  0.6826,  0.0264
  Data.d  0.8,  1.8,  116.9,   490.7,  2701.4,  2210.7,  945.6,  1.0230,  238.6,  12.85,  0.6830,  0.0266
  Data.d  0.9,  1.9,  118.6,   497.8,  2703.9,  2206.1,  944.2,  1.0761,  235.0,  12.91,  0.6834,  0.0268
  Data.d  1.0,  2.0,  120.2,   504.7,  2706.2,  2201.6,  942.9,  1.1290,  231.6,  12.96,  0.6836,  0.0270
  Data.d  1.5,  2.5,  127.4,   535.4,  2716.5,  2181.2,  937.0,  1.3914,  217.5,  13.21,  0.6846,  0.0278
  Data.d  2.0,  3.0,  133.5,   561.5,  2724.9,  2163.4,  931.8,  1.6507,  206.8,  13.42,  0.6849,  0.0286
  Data.d  2.5,  3.5,  138.9,   584.3,  2732.0,  2147.7,  927.1,  1.9077,  198.3,  13.61,  0.6849,  0.0293
  Data.d  3.0,  4.0,  143.6,   604.7,  2738.1,  2133.3,  922.9,  2.1627,  191.2,  13.77,  0.6846,  0.0299
  Data.d  3.5,  4.5,  147.9,   623.2,  2743.4,  2120.2,  919.0,  2.4160,  185.2,  13.92,  0.6842,  0.0305
  Data.d  4.0,  5.0,  151.8,   640.2,  2748.1,  2107.9,  915.3,  2.6681,  180.1,  14.05,  0.6836,  0.0310
  Data.d  4.5,  5.5,  155.5,   655.9,  2752.3,  2096.5,  911.8,  2.9189,  175.5,  14.18,  0.6829,  0.0316
  Data.d  5.0,  6.0,  158.8,   670.5,  2756.1,  2085.6,  908.6,  3.1688,  171.6,  14.30,  0.6821,  0.0320
  Data.d  6.0,  7.0,  165.0,   697.1,  2762.7,  2065.6,  902.6,  3.6662,  164.7,  14.51,  0.6804,  0.0330
  Data.d  7.0,  8.0,  170.4,   721.0,  2768.3,  2047.3,  897.0,  4.1610,  159.1,  14.70,  0.6786,  0.0338
  Data.d  8.0,  9.0,  175.4,   742.7,  2773.0,  2030.3,  891.9,  4.6539,  154.3,  14.87,  0.6766,  0.0346
  Data.d  9.0, 10.0,  179.9,   762.7,  2777.1,  2014.4,  887.1,  5.1454,  150.2,  15.02,  0.6747,  0.0354
  Data.d 10.0, 11.0,  184.1,   781.2,  2780.7,  1999.5,  882.6,  5.6358,  146.6,  15.17,  0.6726,  0.0361
  Data.d 11.0, 12.0,  188.0,   798.5,  2783.8,  1985.3,  878.3,  6.1256,  143.4,  15.30,  0.6706,  0.0368
  Data.d 12.0, 13.0,  191.6,   814.8,  2786.5,  1971.7,  874.3,  6.6149,  140.5,  15.43,  0.6686,  0.0375
  Data.d 13.0, 14.0,  195.0,   830.1,  2788.9,  1958.8,  870.4,  7.1039,  137.9,  15.54,  0.6665,  0.0381
  Data.d 14.0, 15.0,  198.3,   844.7,  2791.0,  1946.3,  866.6,  7.5929,  135.5,  15.66,  0.6645,  0.0388
  Data.d 15.0, 16.0,  201.4,   858.6,  2792.9,  1934.3,  863.1,  8.0820,  133.3,  15.76,  0.6625,  0.0394
  Data.d 16.0, 17.0,  204.3,   871.9,  2794.5,  1922.6,  859.6,  8.5713,  131.3,  15.86,  0.6604,  0.0400
  Data.d 17.0, 18.0,  207.1,   884.6,  2796.0,  1911.4,  856.2,  9.0611,  129.5,  15.96,  0.6584,  0.0405
  Data.d 18.0, 19.0,  209.8,   896.8,  2797.3,  1900.4,  853.0,  9.5513,  127.7,  16.05,  0.6564,  0.0411
  Data.d 19.0, 20.0,  212.4,   908.6,  2798.4,  1889.8,  849.8, 10.0421,  126.1,  16.14,  0.6544,  0.0416
  Data.d 20.0, 21.0,  214.9,   920.0,  2799.4,  1879.4,  846.7, 10.5336,  124.6,  16.23,  0.6525,  0.0422
  Data.d 21.0, 22.0,  217.3,   931.0,  2800.2,  1869.2,  843.7, 11.0259,  123.1,  16.31,  0.6505,  0.0427
  Data.d 22.0, 23.0,  219.6,   941.6,  2800.9,  1859.3,  840.8, 11.5191,  121.8,  16.40,  0.6486,  0.0432
  Data.d 23.0, 24.0,  221.8,   952.0,  2801.5,  1849.6,  837.9, 12.0132,  120.5,  16.47,  0.6466,  0.0438
  Data.d 24.0, 25.0,  224.0,   962.0,  2802.0,  1840.1,  835.1, 12.5082,  119.3,  16.55,  0.6447,  0.0443
  Data.d 25.0, 26.0,  226.1,   971.7,  2802.5,  1830.7,  832.4, 13.0044,  118.1,  16.62,  0.6428,  0.0448
  Data.d 26.0, 27.0,  228.1,   981.2,  2802.8,  1821.5,  829.7, 13.5016,  117.0,  16.70,  0.6409,  0.0453
  Data.d 27.0, 28.0,  230.1,   990.5,  2803.0,  1812.5,  827.0, 14.0000,  115.9,  16.77,  0.6390,  0.0457
  Data.d 28.0, 29.0,  232.0,   999.5,  2803.2,  1803.6,  824.4, 14.4997,  114.9,  16.84,  0.6372,  0.0462
  Data.d 29.0, 30.0,  233.9,  1008.4,  2803.3,  1794.9,  821.9, 15.0006,  114.0,  16.90,  0.6353,  0.0467
  Data.d 30.0, 31.0,  235.7,  1017.0,  2803.3,  1786.3,  819.4, 15.5028,  113.0,  16.97,  0.6335,  0.0472
  Data.d 31.0, 32.0,  237.5,  1025.5,  2803.2,  1777.8,  816.9, 16.0064,  112.1,  17.03,  0.6316,  0.0476
  Data.d 32.0, 33.0,  239.2,  1033.7,  2803.1,  1769.4,  814.5, 16.5115,  111.3,  17.10,  0.6298,  0.0481
  Data.d 33.0, 34.0,  240.9,  1041.8,  2803.0,  1761.1,  812.1, 17.0180,  110.4,  17.16,  0.6280,  0.0486
  Data.d 34.0, 35.0,  242.6,  1049.8,  2802.7,  1753.0,  809.7, 17.5260,  109.6,  17.22,  0.6262,  0.0490
   
EndDataSection


EndModule

 ;- ----------------------------------------------------------------------
 ;-  M O D U L E   T E S T   C O D E
 ;- ---------------------------------------------------------------------- 

CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  UseModule TD

  
  UnuseModule TD
  
CompilerEndIf


; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 136
; FirstLine = 103
; Folding = 0----
; Optimizer
; Executable = K:\purebasic\_projects\wallx\wallx98.exe
; CPU = 5
; CurrentDirectory = C:\software\purebasic\_projects\
; EnableCompileCount = 80
; EnableBuildCount = 2
; EnableExeConstant