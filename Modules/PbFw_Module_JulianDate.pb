; ===========================================================================
;  FILE : PbFw_Module_JulianDate.pb
;  NAME: Module Julian Date, [JDate::]
;  DESC: Julian Calendar Date Calculations 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/08/23
; VERSION  :  0.5  Developer Version
; COMPILER :  PureBasic 6.11
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{
; }            
; ============================================================================


;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::     FrameWork control Module

DeclareModule JDate
  EnableExplicit
  
  Declare.d JDayFraction(hh, mm, ss)  ; Julian Day Fraction
  Declare.i JDN_fromGregorian(Y, M, D) ; Julian Day Number from gegorian Date
  Declare.d CreateJulianDate(JDN, hh, mm, ss)

EndDeclareModule

Module JDate
  EnableExplicit
  ;- ----------------------------------------------------------------------
  ;- PbFw Module local configurations
  ;  ----------------------------------------------------------------------
  
;   #PbFwCfg_Module_CheckPointerException = #True     ; This constant must have same Name in all Modules. On/Off PoninterExeption for this Module
; 
;   PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  Procedure.d JDayFraction(hh, mm, ss)  ; Julian Day Fraction
    ; because Julian Day as Integer is 12:00 (pm, middle of the day)
    ; we have to subtract 0.5 for a half day  to get 00:00 
    ProcedureReturn (hh*3600 + mm*60 + ss)/86400 - 0.5 
  EndProcedure
  
  Procedure.i JDN_fromGregorian(Y, M, D) ; Julian Day Number from gegorian Date
    ; Return a Julian day for a Gregorian calendar date.
    
    ; keep in mind if you handle Julian Dates with TimeOfDay:
    ; the JulianDayNo as Integer is at 12:00 (pm: middle of the day)
    ; for 00:00 we have to subtract 0.5
    
    Protected.i day, itmp 
    Protected.i m14 = (M-14)/12
    
    ;day = Int((1461 * (Y + 4800 + Int((M - 14) / 12))) / 4) + Int((367 * (M - 2 - 12 * Int((M - 14) / 12))) / 12) - Int((3 * Int((Y + 4900 + Int((M - 14) / 12)) / 100)) / 4) + D - 32075
    ; because PB do not have an seperate operator to force integer division
    ; we have to split into more steps to be sure PB calcualtes all as Integer without any additional float conversion
    day = (1461 * (Y + 4800 + m14)) / 4
    itmp = (367 * (M-2 - 12 * m14)) / 12 
    day + itmp
    itmp = (Y + 4900 + m14) /100
    itmp = (itmp * 3)/4
    day = day - itmp + D - 32075 
    ProcedureReturn day        
  EndProcedure
 
  Procedure.d CreateJulianDate(JDN, hh, mm, ss)
    ProcedureReturn JDN + JDayFraction(hh,mm,ss)
  EndProcedure
 
EndModule

CompilerIf #PB_Compiler_IsMainFile
  UseModule JDate
  Define d1, d2
  ; 2000/01/01 = 2.451.545
  d1 = JDN_fromGregorian(2000, 1, 1)
  d2 = JDN_fromGregorian(1970, 1, 1)
  OpenConsole()
  PrintN(Str(d1))
  PrintN(Str(d2))
  Input()
CompilerEndIf
; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 2
; Folding = --
; Optimizer
; CPU = 5