; ===========================================================================
;  FILE : Module_CLIMA.pb
;  NAME : Module CLIMA
;  DESC : Functions for climatic calculations
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/30
; VERSION  :  0.1 untested Developer Version
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;             
; ============================================================================

EnableExplicit

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile ""

DeclareModule CLIMA
  
  Structure TAirSatTable
    Temp.d    ; Temperatur [°C]; wenn Luft max. mit Wasser gesättigt, dann ist Temp = Taupunkt
    esat.d      ; Sättigungsampfdruck [mbar]
    pD.d        ; %D max. Wassergehalt [g/m³]
  EndStructure
  
  #AirSatTable_Entries = 201

EndDeclareModule


Module CLIMA
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
 
  #CLIMA_RUni = 8.3145            ; universelle Gaskonstante 8,3145 J/(mol*K)
  #CLIMA_RS = 287.058             ; spez. Gaskonstante trockene Luft  287,058 J/(kg*K)
  #CLIMA_RD = 461.510             ; Gaskonstante Wasserdampf   : RD  = 461.510 J/(kg*K)
  #CLIMA_KelvinOffset = 273.15    ; Offset Kelvin to Celsius
  
  Global Dim AirSatTable.TAirSatTable(#AirSatTable_Entries-1)

  
  ; ======================================================================
  ;    Pressure conversion bar <=> Pascal  
  ; ======================================================================

  ; 1Pa = 0.00001 bar +1E-5
  ; 1bar = 100.000Pa
  ; 1mbar = 100Pa
  Macro PacalToBar(pPascal)
    pPascal * 100000  
  EndMacro
  
  Macro BarToPascal(pBar)
    pBar/100000  
  EndMacro
  
  
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
   esat = 611.2 * Exp( 17.5043 * TempCelsius)/(241.2 + TempCelsius)
   
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
   
   TempKelvin = TempCelsius + #CLIMA_KelvinOffset ; TempCelsius +273.15
    
   ProcedureReturn esat * (#CLIMA_RD * TempKelvin)
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

    ep = AirSaturationPressure(TempCelsis) * rHum /100;

    k = Log(ep/611.2)
    DP = k/(17.5043-k) * 241.2
    
    ProcedureReturn DP
  EndProcedure
  
  Procedure.i Load_AirSatTable(Array Table.TAirSatTable(1))
  ; ======================================================================
  ; NAME: Load_AirSatTable
  ; DESC: Load the AirSaturation Table
  ; DESC: Alle the formulas are aproximations. The Table contains
  ; DESC: the more exact values between a AirTemp of [-100°C..+140°C]
  ; VAR((Array Table.TAirSatTable(1): The Arry which should hold the Table
  ; RET-i: NoOf loaded Datasets
  ; ======================================================================
   Protected I 
    
    Restore TABLE_ESAT
    For I = 0 To #AirSatTable_Entries-1
      With Table(I)
        Read.d \Temp
        Read.d \esat
        Read.d \pD
        ;Debug "T = " + \Temp + " : esat = " + \esat + " : pD = " + \pd
      EndWith  
    Next
    
    Debug "AirSaturationTable Datasets loaded = " + I
  
    ProcedureReturn I
  EndProcedure
  
  Procedure INIT()
  ; ======================================================================
  ; NAME: Initialisation
  ; ======================================================================
    
    Load_AirSatTable(AirSatTable())
    Debug "Module CLIMA: Init done"
    
  EndProcedure
  
  Procedure.d Get_VaccumDewPoint(pS.d)
  ; ======================================================================
  ; NAME: Get_VaccumDewPoint
  ; DESC: Searchs the DewPointTemperature to a given Air-pressure
  ; DESC: in the AirSaturatioin Table (TABLE_ESAT:)
  ; DESC: the more exact values between a AirTemp of [-100°C..+140°C]
  ; VAR((esat): The Air-pressure 
  ; RET-i: NoOf loaded Datasets
  ; ======================================================================
   Protected TD.d
    Protected I, J, Size
    
    Size =  ArraySize(AirSatTable())
    Debug "Size = " + Size
    If pS < AirSatTable(0)\esat 
      TD = AirSatTable(0)\Temp
    ElseIf pS > AirSatTable(Size)\esat
      TD = AirSatTable(Size)\Temp
    Else
      
      J=0 : I = 0
      Repeat 
        I + 10    
        Debug "Repeat I= " + I + " : esat = " + AirSatTable(I)\esat
      Until (I > Size) Or (pS < AirSatTable(I)\esat)
      
      If I > Size 
        J = SIZE
      Else
        J = I-1
      EndIf
          
      Debug "J = " +J
      
      For I = J To 0  Step -1 
        Debug I
        If pS >= AirSatTable(I)\esat
          TD = AirSatTable(I)\Temp
          Break
        EndIf
      Next
      
    EndIf
    
    ProcedureReturn TD
  EndProcedure
  
  INIT()      ; Call the INIT()
  
  ; ----------------------------------------------------------------------------------------------------
  ; Tabelle Temperatur Sättignungsdamfdruck max. Wassergehalt Temp{-100..+140}
  ; ----------------------------------------------------------------------------------------------------  
  ; Aus: LEYBOLD Grundlagen der Vakuumtechnik Dr. Walter Umrath Köln, im März 1997; Seite 150
  ; org. Quelle: Smithsonian Meteorological Tables 6th. ed. (1971) und VDI-Wasserdampftafeln 6. Ausgabe (1963).
  
  ; Tabelle XIII: Sättigungsdampfdruck ps und Dampfdichte % D von Wasser im Temperaturbereich – 100°C + 140°C
  
  ; Sättigunsdampfdruck und max. Wassergehalt bei gegebener Temperatur 
  ; Das kann verwendet werden um unter Vakuum den Wassergehalt bei einem bestimmten Druck zu ermitteln!
  ; Vakuumtrocknung: Dabei wird der Druck bestimmt durch den Restwassergehalt. Solange Wasser verdampft
  ; geht der Druck nicht nach unten. Anhand es Vakuummanometers lässt sich so der Wassergehalt der Luft ermitteln.
  ; Dies wird z.B. beim Trocken von Hochspannungstranformatoren verwendet
  ; ----------------------------------------------------------------------------------------------------

  DataSection
    TABLE_ESAT:  
    ;   Temp. [°C],  Sättigungsdampfdruck esat [mbar], Dampfichte %D[g/m³]  
    ;      TD  ,  ps       , %D
    Data.d -100, 0.00001403, 0.00001756   ; -100°C ; 1.403e-5 mbar, 1.756e-5 g/m³ (max. Wassergehalt)
    Data.d -99,  0.00001719, 0.00002139
    Data.d -98,  0.00002101, 0.00002599
    Data.d -97,  0.00002561, 0.00003150
    Data.d -96,  0.00003117, 0.00003812
    Data.d -95,  0.00003784, 0.00004602
    Data.d -94,  0.00004584, 0.00005544
    Data.d -93,  0.00005542, 0.00006665
    Data.d -92,  0.00006685, 0.00007996
    Data.d -91,  0.00008049, 0.00009574
    Data.d -90,  0.00009672, 0.0001144
    Data.d -89,  0.0001160,  0.0001365
    Data.d -88,  0.0001388,  0.0001624
    Data.d -87,  0.0001658,  0.0001930
    Data.d -86,  0.0001799,  0.0002289
    Data.d -85,  0.0002353,  0.0002710
    Data.d -84,  0.0002796,  0.0003203
    Data.d -83,  0.0003316,  0.0003778
    Data.d -82,  0.0003925,  0.0004449
    Data.d -81,  0.0004638,  0.0005230
    Data.d -80,  0.0005473,  0.0006138
    Data.d -79,  0.0006444,  0.0007191
    Data.d -78,  0.0007577,  0.0008413
    Data.d -77,  0.0008894,  0.0009824
    Data.d -76,  0.001042,   0.001145
    Data.d -75,  0.001220,   0.001334
    Data.d -74,  0.001425,   0.001550
    Data.d -73,  0.001662,   0.001799
    Data.d -72,  0.001936,   0.002085
    Data.d -71,  0.002252,   0.002414
    Data.d -70,  0.002615,   0.002789
    Data.d -69,  0.003032,   0.003218
    Data.d -68,  0.003511,   0.003708
    Data.d -67,  0.004060,   0.004267
    Data.d -66,  0.004688,   0.004903
    Data.d -65,  0.005406,   0.005627
    Data.d -64,  0.006225,   0.006449
    Data.d -63,  0.007195,   0.007381
    Data.d -62,  0.008223,   0.008438
    Data.d -61,  0.009432,   0.009633
    Data.d -60,  0.01080,    0.01098
    Data.d -59,  0.01236,    0.01251
    Data.d -58,  0.01413,    0.01423
    Data.d -57,  0.01612,    0.01616
    Data.d -56,  0.01838,    0.01834
    Data.d -55,  0.02092,    0.02078
    Data.d -54,  0.02380,    0.02353
    Data.d -53,  0.02703,    0.02660
    Data.d -52,  0.03067,    0.03005
    Data.d -51,  0.03476,    0.03390
    Data.d -50,  0.03935,    0.03821
    Data.d -49,  0.04449,    0.04301
    Data.d -48,  0.05026,    0.04837
    Data.d -47,  0.05671,    0.05433
    Data.d -46,  0.06393,    0.06098
    Data.d -45,  0.07198,    0.06836
    Data.d -44,  0.08097,    0.07656
    Data.d -43,  0.0909,     0.08565
    Data.d -42,  0.1021,     0.09570
    Data.d -41,  0.1145,     0.1069
    Data.d -40,  0.1283,     0.1192
    Data.d -39,  0.1436,     0.1329
    Data.d -38,  0.1606,     0.1480
    Data.d -37,  0.1794,     0.1646
    Data.d -36,  0.2002,     0.1829
    Data.d -35,  0.2233,     0.2032
    Data.d -34,  0.2488,     0.2254
    Data.d -33,  0.2769,     0.2498
    Data.d -32,  0.3079,     0.2767
    Data.d -31,  0.3421,     0.3061
    Data.d -30,  0.3798,     0.3385
    Data.d -29,  0.4213,     0.3739
    Data.d -28,  0.4669,     0.4127
    Data.d -27,  0.5170,     0.4551
    Data.d -26,  0.5720,     0.5015
    Data.d -25,  0.6323,     0.5521
    Data.d -24,  0.6985,     0.6075
    Data.d -23,  0.7709,     0.6678
    Data.d -22,  0.8502,     0.7336
    Data.d -21,  0.9370,     0.8053
    Data.d -20,  1.0320,     0.8835
    Data.d -19,  1.1350,     0.9678
    
    Data.d -18,  1.2480,  1.060
    Data.d -17,  1.3710,  1.160
    Data.d -16,  1.5060,  1.269
    Data.d -15,  1.6520,  1.387
    Data.d -14,  1.8110,  1.515
    Data.d -13,  1.9840,  1.653
    Data.d -12,  2.1720,  1.803
    Data.d -11,  2.3760,  1.964
    Data.d -10,  2.5970,  2.139
    Data.d  -9,  2.8370,  2.328
    Data.d  -8,  3.0970,  2.532
    Data.d  -7,  3.3790,  2.752
    Data.d  -6,  3.6850,  2.990
    Data.d  -5,  4.0150,  3.246
    Data.d  -4,  4.3720,  3.521
    Data.d  -3,  4.5750,  3.817
    Data.d  -2,  5.1730,  4.163
    Data.d  -1,  5.6230,  4.479
    Data.d   0,   6.1080, 4.847
    Data.d   1,   6.566,  5.192
    Data.d   2,   7.055,  5.559
    Data.d   3,   7.575,  5.947
    Data.d   4,   8.129,  6.360
    Data.d   5,   8.719,  6.797
    Data.d   6,   9.347,  7.260
    Data.d   7,  10.01,   7.750
    Data.d   8,  10.72,   8.270
    Data.d   9,  11.47,   8.819
    Data.d  10,  12.27,   9.399
    Data.d  11,  13.12,   10.01
    Data.d  12,  14.02,   10.66
    Data.d  13,  14.97,   11.35
    Data.d  14,  15.98,   12.07
    Data.d  15,  17.04,   12.83
    Data.d  16,  18.17,   13.63
    Data.d  17,  19.37,   14.48
    Data.d  18,  20.63,   15.37
    Data.d  19,  21.96,   16.31
    Data.d  20,  23.37,   17.30
    Data.d  21,  24.86,   18.34
    Data.d  22,  26.43,   19.43
    Data.d  23,  28.09,   20.58
    Data.d  24,  29.83,   21.78
    Data.d  25,  31.67,   23.05
    Data.d  26,  33.61,   24.38
    Data.d  27,  35.65,   25.78
    Data.d  28,  37.80,   27.24
    Data.d  29,  40.06,   28.78  
    Data.d  30,  42.43,   30.38
    Data.d  31,  44.93,   32.07
    Data.d  32,  47.55,   33.83
    Data.d  33,  50.31,   35.68
    Data.d  34,  53.20,   37.61
    Data.d  35,  56.24,   39.63
    Data.d  36,  59.42,   41.75
    Data.d  37,  62.76,   43.96
    Data.d  38,  66.26,   46.26
    Data.d  39,  69.93,   48.67
    Data.d  40,  73.78,   51.19
    Data.d  41,  77.80,   53.82
    Data.d  42,  82.02,   56.56
    Data.d  43,  86.42,   59.41
    Data.d  44,  91.03,   62.39
    Data.d  45,  95.86,   65.50
    Data.d  46, 100.9,    68.73
    Data.d  47, 106.2,    72.10
    Data.d  48, 111.7,    75.61
    Data.d  49, 117.4,    79.26
    Data.d  50, 123.4,    83.06
    Data.d  51, 129.7,    87.01
    Data.d  52, 136.2,    91.12
    Data.d  53, 143.0,    95.39
    Data.d  54, 150.1,    99.83
    Data.d  55, 157.5,   104.4
    Data.d  56, 165.2,   109.2
    Data.d  57, 173.2,  114.2
    Data.d  58, 181.5,  119.4
    Data.d  59, 190.2,  124.7
    Data.d  60, 199.2,  130.2
    Data.d  61, 208.6,  135.9
    Data.d  62, 218.4,  141.9
    Data.d  63, 228.5,  148.1
    Data.d  64, 293.1,  154.5
    Data.d  65, 250.1,  161.2
    Data.d  66, 261.5,  168.1
    Data.d  67, 273.3,  175.2
    Data.d  68, 285.6,  182.6
    Data.d  69, 298.4,  190.2
    Data.d  70, 311.6,  198.1
    Data.d  71, 325.3,  206.3
    Data.d  72, 339.6,  214.7
    Data.d  73, 354.3,  223.5
    Data.d  74, 369.6,  232.5
    Data.d  75, 385.5,  241.8
    Data.d  76, 401.9,  251.5
    Data.d  77, 418.9,  261.4
    Data.d  78, 436.5,  271.7
    Data.d  79, 454.7,  282.3
    Data.d  80, 473.6,  293.3
    Data.d  81, 493.1,  304.6
    Data.d  82, 513.3,  316.3
    Data.d  83, 534.2,  328.3
    Data.d  84, 555.7,  340.7
    Data.d  85, 578.0,  353.5
    Data.d  86, 601.0,  366.6
    Data.d  87, 624.9,  380.2
    Data.d  88, 649.5,  394.2
    Data.d  89, 674.9,  408.6
    Data.d  90, 701.1,  423.5
    Data.d  91, 728.2,  438.8
    Data.d  92, 756.1,  454.5
    Data.d  93, 784.9,  470.7
    Data.d  94, 814.6,  487.4
    Data.d  95, 845.3,  504.5
    Data.d  96, 876.9,  522.1
    Data.d  97, 909.4,  540.3
    Data.d  98, 943.0,  558.9
    Data.d  99, 977.6,  578.1
    Data.d 100, 1013,  597.8
    Data.d 101, 1050,  618.0
    Data.d 102, 1088,  638.8
    Data.d 103, 1127,  660.2
    Data.d 104, 1167,  682.2
    Data.d 105, 1208,  704.7
    Data.d 106, 1250,  727.8
    Data.d 107, 1294,  751.6
    Data.d 108, 1339,  776.0
    Data.d 109, 1385,  801.0
    Data.d 110, 1433,  826.7
    Data.d 111, 1481,  853.0
    Data.d 112, 1532,  880.0
    Data.d 113, 1583,  907.7
    Data.d 114, 1636,  936.1
    Data.d 115, 1691,  965.2
    Data.d 116, 1746,  995.0
    Data.d 117, 1804, 1026
    Data.d 118, 1863, 1057
    Data.d 119, 1923, 1089
    Data.d 120, 1985, 1122
    Data.d 121, 2049, 1156
    Data.d 122, 2114, 1190
    Data.d 123, 2182, 1225
    Data.d 124, 2250, 1262
    Data.d 125, 2321, 1299
    Data.d 126, 2393, 1337
    Data.d 127, 2467, 1375
    Data.d 128, 2543, 1415
    Data.d 129, 2621, 1456
    Data.d 130, 2701, 1497
    Data.d 131, 2783, 1540
    Data.d 132, 2867, 1583
    Data.d 133, 2953, 1627
    Data.d 134, 3041, 1673
    Data.d 135, 3131, 1719
    Data.d 136, 3223, 1767
    Data.d 137, 3317, 1815
    Data.d 138, 3414, 1865
    Data.d 139, 3512, 1915
    Data.d 140, 3614, 1967
  EndDataSection

EndModule



; IDE Options = PureBasic 6.01 LTS (Windows - x86)
; CursorPosition = 9
; Folding = --
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)