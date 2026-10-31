
; Color Modules Develop Main

; --------------------------------------------------
; Include Files
; --------------------------------------------------

XIncludeFile "..\..\Modules\PbFw_Module_PbFw.pb"        ; PbFw::   FrameWork control Module
XIncludeFile "..\..\Modules\PbFw_Module_PX.pb"          ; PB::     PureBasic extention Module
XIncludeFile "..\..\Modules\PbFw_Module_COLOR.pb"       ; COLOR::  Color Module
XIncludeFile "..\..\Modules\PbFw_Module_VectorColor.pb" ; VecCol:: Vector Color Module
XIncludeFile "..\..\Modules\PbFw_Module_Menu.pb"        ; Menu:: Module Menu
XIncludeFile "..\..\Modules\PbFw_Module_CodeCreation.pb"; CC:: Module Code Creation

XIncludeFile "frmImage.pb"
XIncludeFile "frmMain.pb"

EnableExplicit

; --------------------------------------------------
; Create Main Form 
; --------------------------------------------------

Define *fMain.frmMain::TThis    ; Define Pointer to MainWindow Data Structure This
*fMain = frmMain::New()         ; create the new MainWindow

If *fMain = 0                   ; Window created?
  MessageRequester("Error!", "Creating the Main Window failed! Unknown reason!")
  End                           ; End Program if Window was not created
EndIf

; --------------------------------------------------
; Main Event Loop
; --------------------------------------------------
Repeat
  Define Quit
  Define Event = WaitWindowEvent()        ; wait for a Window Event
  
  Quit = frmMain::Events(*fMain, Event)   ; Call the Main Form Event Loop
  
Until Quit = #True                        ; Quit if the Main From is closed

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 12
; Optimizer
; CPU = 5