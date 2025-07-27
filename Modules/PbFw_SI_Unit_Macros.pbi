; International Unit conversion Macros

;- ----------------------------------------------------------------------
;- Macros for Length conversion
;- ----------------------------------------------------------------------

Macro mm_to_cm(mm)
  (mm/10)  
EndMacro

Macro mm_to_dm(mm)
  (mm/100)
EndMacro

Macro mm_to_m(mm)
  (mm/1000)
EndMacro

Macro mm_to_km(mm)
  (mm/1000000)
EndMacro

; 1in = 25.4mm
Macro mm_to_in(mm)
  (mm/25.4)
EndMacro

; 1ft = 12in = 12*25.4mm = 304.8mm
Macro mm_to_ft(mm)
  (mm/304.8)
EndMacro


Macro cm_to_mm(cm)
  (cm*10)  
EndMacro

Macro dm_to_mm(dm)
  (dm*100)  
EndMacro

Macro m_to_mm(m)
  (m*1000)  
EndMacro

Macro km_to_mm(km)
  (km*1000000)  
EndMacro

Macro in_to_mm(in)
  (in*25.4)
EndMacro

Macro ft_to_mm(ft)
  (ft*304.8)  
EndMacro
    
;- ----------------------------------------------------------------------
;- Macros pressure conversion
;- ----------------------------------------------------------------------

Macro bar_to_mbar(bar)
  (bar*1000)
EndMacro

; bar to pascal
Macro bar_to_pa(bar)
  ()
EndMacro

; bar to hecto pascal
Macro bar_to_hpa(bar)
  ()
EndMacro

; bar to Newton/m²
Macro bar_to_N_sqm
  ()
EndMacro

;- ----------------------------------------------------------------------
;- Macros temperature conversion
;- ----------------------------------------------------------------------

; https://de.wikipedia.org/wiki/Grad_Fahrenheit
#T0_Celcius = -273.15

Macro K_to_C(T_Kelvin)
  (T_Kelvin - 273.15)    
EndMacro

Macro C_to_K(T_Celsius)
  (T_Celsius + 273.15)    
EndMacro

Macro F_to_C(T_Fahrenheit)
  ((T_Fahrenheit-32)*(5/9))
EndMacro

Macro C_to_F(T_Celsius)
  ((T_Celsius*(9/5)+32)
EndMacro

Macro F_to_K(T_Fahrenheit)
  ((T_Fahrenheit+459.67)*(5/9))
EndMacro

Macro K_to_F(T_Kelvin)
  ((T_Kelvin*(9/5)-459.67)
EndMacro

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 77
; FirstLine = 42
; Folding = ----
; DPIAware
; CPU = 5