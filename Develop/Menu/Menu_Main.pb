; Modul Menu develp

; --------------------------------------------------
; Include Files
; --------------------------------------------------

XIncludeFile "..\..\Modules\PbFw_Module_PbFw.pb"        ; PbFw::   FrameWork control Module
XIncludeFile "..\..\Modules\PbFw_Module_PX.pb"          ; PB::     PureBasic extention Module
XIncludeFile "..\..\Modules\PbFw_Module_Menu.pb"        ; Menu:: Module Menu

XIncludeFile "frmMain.pb"

EnableExplicit

; --------------------------------------------------
; Create Main Form 
; --------------------------------------------------
Debug "Programm Start"

Define *fMain.frmMain::TThis    ; Define Pointer to MainWindow Data Structure This
*fMain = frmMain::New()         ; create the new MainWindow

; Define *fM2.frmMain::TThis    ; Define Pointer to MainWindow Data Structure This
; *fM2 = frmMain::New()         ; create the new MainWindow

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
  
  Select EventWindow()
    Case *fMain\wndPB
      Quit = frmMain::Events(*fMain, Event)   ; Call the Main Form Event Loop
      
;     Case *fM2\wndPB
;       frmMain::Events(*fM2, Event) 
      
  EndSelect
  
Until Quit = #True                        ; Quit if the Main From is closed

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 8
; DPIAware
; CPU = 5