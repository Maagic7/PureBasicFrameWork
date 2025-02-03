; ===========================================================================
;  FILE : String_Main.pb
;  NAME : String Project Main
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/12/29
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


IncludeFile "..\..\PbFw_Module_String.pb"


Define Text$ = "This is a xxxx to test SetMid-Function"

Define Pos = FindString(Text$, "xxxx")
Debug pos
Str::SetMid(Text$, "text", Pos)

Debug Text$
; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 17
; Folding = -
; Optimizer
; CPU = 5