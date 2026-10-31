XIncludeFile "..\..\Modules\PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

EnableExplicit

NewList lstW.s()
NewList lstCode.s()


Define code$


code$ = GetClipboardText()
; Debug code$

PX::SplitStringList(lstCode(), code$, #CRLF$)

Debug "Lines = " + ListSize(lstCode())
Define p

ForEach lstCode()
  ;Debug lstCode()
  
  code$ = lstCode()
  p = FindString(code$, "//")
  If p
    code$ = Left(code$, p)   
  EndIf
  PX::TextBetweenList(lstW(), code$, Chr(34), Chr(34), 3, #True)
 
Next

Define *pC.PX::pChar
ForEach lstW()
  code$ = lstW()
  *pC = @code$
  
  If *pC\c[1] >='A' And *pC\c[1] <= 'Z'
    
  Else
    Debug "-> " + lstW()
    DeleteElement(lstW()) 
  EndIf
  
Next

Debug "No = " + ListSize(lstW())
Debug "-----------------------------"

SortList(lstW(), #PB_Sort_Ascending)

ForEach lstW()
  Debug lstW()
Next



; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 41
; DPIAware
; CPU = 5