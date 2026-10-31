
; FastChar_Main

; IncludeFile "..\..\Modules\PbFw_Module_FastChar.pb"
; IncludeFile "..\..\Modules\PbFw_Module_CodeCreation.pb"       ; CC::    Code creation Module
IncludeFile "..\..\Modules\PbFw_Module_PbXRef.pb"             ; PbXRef::  PB Cross-Reference

EnableExplicit
;Debug "FastChar_Main"

; https://www.purebasic.fr/english/viewtopic.php?p=643472#p643472
; Unicode NonLetter
; Dim NonLetter(65535)
; For i = 0 To 65535
;  NonLetter(i) = (((i & ~32) - 52) / 13 - 1) >> 1
; Next


; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 5
; DPIAware
; CPU = 5