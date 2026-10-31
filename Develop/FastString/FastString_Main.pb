; ===========================================================================
;  FILE : FastString_Main.pb
;  NAME : FastString Project Main
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/02/07
; VERSION  :  0.5 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;}
;
;{ TODO:
;}
; ===========================================================================


IncludeFile "..\..\Modules\PbFw_Module_FastString.pb"
IncludeFile "..\..\Modules\PbFw_Module_String.pb"
EnableExplicit

Define I
Define.s txt, res
Define t1, t2

CompilerIf #PB_Compiler_Debugger
  #Loops = 1000 * 100
  
  txt = "Search in a String for a text between (Bracketes)!"
  t1=ElapsedMilliseconds()
  For I = 0 To #Loops
    res = PX::TextBetween(txt, "(", ")")  
  Next
  t1=ElapsedMilliseconds()-t1
  
  
  t2=ElapsedMilliseconds()
  For I = 0 To #Loops
    res = PX::TextBetween(txt, "(", ")")  
  Next
  t2=ElapsedMilliseconds()-t2
  
  OpenConsole("Timing")
  PrintN("FStr:TextBetween ms = " + t1)
  PrintN("Str:TextBetween  ms = " + t2)
  PrintN("")
  PrintN("Press any key")
  Input()
CompilerEndIf
; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 32
; Folding = -
; Optimizer
; CPU = 5