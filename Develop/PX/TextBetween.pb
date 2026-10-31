
; Test PX::TextBetween

EnableExplicit


XIncludeFile "..\..\Modules\PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

Define txt$ = "---<11>dfakdsfk<12>dfasdf<13>fdfsdafsadfjjfd<14><15"

Debug "--------------------------------------------------"
Debug "TextBetween"
Debug "--------------------------------------------------"

Debug PX::TextBetween(txt$, "<", ">")

NewList lstTxt.s()

PX::TextBetweenList(lstTxt(), txt$, "<", ">")
Debug "TextBetweenList"
ForEach lstTxt()
  Debug lstTxt()  
Next

Dim aryTxt.s(0)
Define I, N

N = PX::TextBetweenArray(aryTxt(), txt$, "<", ">")
Debug "TextBetweenArray"
For I = 0 To N-1
  Debug aryTxt(I)  
Next

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 6
; DPIAware
; CPU = 5