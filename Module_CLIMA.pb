; ===========================================================================
;  FILE : Module_CLIMA.pb
;  NAME : Module CLIMA
;  DESC : Functions for climatic calculations
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/30
; VERSION  :  1.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;             
; ============================================================================

EnableExplicit

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

; XIncludeFile ""

DeclareModule CLIMA

EndDeclareModule


Module CLIMA
  
  #R_universal = 8.3145     ; universelle Gaskonstante 8,3145 J/(mol*K)
  #RS = 287.058             ; spez. Gaskonstante trockene Luft  287,058 J/(kg*K)
  #RD = 461.510             ; Gaskonstante Wasserdampf   : RD  = 461.510 J/(kg*K)
  #Offset_Kelvin = 273.15   ; Offset Kelvin to Celsius
  
  ; ======================================================================
  ;    Pressure conversion bar <=> Pascal  
  ; ======================================================================

  ; 1Pa = 0.00001 bar +1E-5
  ; 1bar = 100.000Pa
  Macro PacalToBar(pPascal)
    pPascal * 100000  
  EndMacro
  
  Macro BarToPascal(pBar)
    pBar/100000  
  EndProcedure
  
  
 Procedure.d AirSaturationPressure (TempCelsius.d)
  ; ======================================================================
  ; NAME: AirSaturationPressure
  ; DESC: Calculates the Air Saturation Pressure at a given Temperature
  ; VAR(TempCelsius.d) Temperature in Celsius
  ; RET: AirSaturationPressure in Pascal [Pa]
  ; ======================================================================

  ; 'Berechnet Sättigungsdampfdruck in Pascal
   
  ;     ACHTUNG: EXP zur Basis e
  ;     
  ;                          17.62 * T°C
  ;     esat = 611,2 * Exp (---------------)
  ;                          243,12 + T°C
   
   Protected esat.d
   
    ; Achtung: beides sind Näherungen, für uns passt jedoch -30..70°C besser
    ; Temperaturbereich
    ; -45°C < t < 60
    ;   esat := 611.2 * Exp( (17.62 * TempCelsius)/(243.12 + TempCelsius));

    ; Temperaturbereich
    ; -30°C < t < 70
   esat := 611.2 * Exp( 17.5043 * TempCelsius)/(241.2 + TempCelsius))
   
   ProcedureReturn esat

 EndProcedure
  
 Procedure.d pDmax(esat.d, TempCelsius.d)  ; pDmax [kg/m³]
  ; ----------------------------------------------------------------------
  ;  Wasserdampfsättigungskonzentration
  ;  Die Wasserdampfsättigungskonzentration entspricht der maximalen Menge
  ;  an Wasserdampf (f = 1,0), die ein bestimmtes Luftvolumen bei einer
  ;  bestimmten Temperatur enthalten kann.  
  ; ----------------------------------------------------------------------

   ; Wassergehalt pDmax von Luft anhand der Temperatur in °C
   
   Protected pDmax.d, TempKelvin.d
   
   TempKelvin = TempCelsius + #Offset_Kelvin ; TempCelsius +273.15
    
   ProcedureReturn esat * (#RD * TempKelvin)
  EndProcedure
 
  Procedure.d DewPoint(TempCelsis.d, humidity.d)     ; [°C] Taupunkt
  ; ======================================================================
  ; NAME: DewPoint
  ; DESC: Calculates the DewPoint of wet air at a Temperature [°C] and
  ; DESC: relative humidity [0..100%]
  ; VAR(TempCelsius.d) Temperature in Celsius
  ; VAR(humidity.d) realtive humidity [0..100%]
  ; RET: Dew Point [°C]
  ; ======================================================================
  
    ; Faustformel für Taupunkt: je 5% Fechte fällt der Taupunkt um 1°C
    ; D.h. Bei 30° und 75%rF liegt der Taupunkt bei ca. 25° (100-75)/5=5°C unter Lufttemp.
    
    ;  k = ln(Partialdruck/611,2)  // Achtung auf der Webseite ist die Formel falsch angeben, mit Sättingsdruck statt Partialdruck
    ;    
    ;                   k
    ;  Tp = 241.2 * ------------    ; Faktoren für -30..70°C;   243.12 & 17.68 für -45..60°
    ;               17,5043 - k
   
    Protected.d k, DP, ep
    
    ; ----------------------------------------------------------------------
    ;  Partialdruck ep in Pascal
    ; ----------------------------------------------------------------------
    ; ep = esat * humidtiy%/100

    ep := AirSaturationPressure(TempCelsis) * rHum /100;

    k = LN(ep/611.2)
    DP = k/(17.5043-k) * 241.2
    
    ProcedureReturn DP
  EndProcedure
 
EndModule

DisableExplicit

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 41
; Folding = -
; Optimizer
; Compiler = PureBasic 6.00 LTS (Windows - x86)