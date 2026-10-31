; ============================================================================
; TITLE: PureBasic 4-Channel Oscilloscope - Main Test Application
; LICENSE: Open Source / MIT
; ============================================================================

XIncludeFile "..\..\Modules\DSP\PbFw_Module_Scope.pb" ; Make sure your module code is saved in this file name
XIncludeFile "..\..\Modules\PbFw_Module_RingBuffer.pb" ; Make sure your module code is saved in this file name


EnableExplicit

#WindowWidth  = 840 ; Slightly wider to accommodate side control panels if needed
#WindowHeight = 680 
#CanvasID     = 0
#TimerID      = 1

; UI Gadget Enumerations
Enumeration 10
  ; Channel Buttons
  #Btn_CH1
  #Btn_CH2
  #Btn_CH3
  #Btn_CH4
  
  ; Trigger Mode Text & Option Gadgets
  #Txt_TrigMode
  #Opt_TrigNone
  #Opt_TrigAuto
  #Opt_TrigNormal
  
  ; Trigger Source Combo Box
  #Txt_TrigSrc
  #Cmb_TrigSrc
EndEnumeration

Define MyScope.SCOPE::TScope

; Macro to easily toggle booleans in PureBasic structure fields (Thanks to your optimization!)
Macro ToggleBool(_value)
  Bool(_value = 0)
EndMacro

; Helper Procedure to refresh Channel Button Visuals
Procedure RefreshButtonState(*SCP.SCOPE::TScope, ButtonID.i, ChannelNo.i, ActiveColor.l)
  If *SCP\Channel(ChannelNo)\IsActive
    SetGadgetText(ButtonID, *SCP\Channel(ChannelNo)\Name + " (ON)")
    SetGadgetColor(ButtonID, #PB_Gadget_BackColor, ActiveColor)
    SetGadgetColor(ButtonID, #PB_Gadget_FrontColor, RGB(0, 0, 0))
  Else
    SetGadgetText(ButtonID, *SCP\Channel(ChannelNo)\Name + " (OFF)")
    SetGadgetColor(ButtonID, #PB_Gadget_BackColor, RGB(40, 45, 40))
    SetGadgetColor(ButtonID, #PB_Gadget_FrontColor, RGB(160, 160, 160))
  EndIf
EndProcedure

; 2. Initialize PureBasic Window & UI Layout
If OpenWindow(0, 100, 100, #WindowWidth, #WindowHeight, "PB 4-Channel Digital Oscilloscope - Proof of concept!", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  ; Create the main drawing canvas
  CanvasGadget(#CanvasID, 10, 10, #WindowWidth - 20, #WindowHeight - 140)
  
  ; Layout calculation for the 4 Channel Toggle Buttons
  Define ButtonWidth.i = (#WindowWidth - 50) / 4
  Define ChannelY.i    = #WindowHeight - 120
  
  ButtonImageGadget(#Btn_CH1, 10,                   ChannelY, ButtonWidth, 35, 0)
  ButtonImageGadget(#Btn_CH2, 20 + ButtonWidth,     ChannelY, ButtonWidth, 35, 0)
  ButtonImageGadget(#Btn_CH3, 30 + (ButtonWidth*2), ChannelY, ButtonWidth, 35, 0)
  ButtonImageGadget(#Btn_CH4, 40 + (ButtonWidth*3), ChannelY, ButtonWidth, 35, 0)
  
  ; Layout for the Trigger Controls below the channel buttons
  Define ControlY.i = #WindowHeight - 75
  
  TextGadget(#Txt_TrigMode, 10, ControlY + 3, 90, 20, "Trigger Mode:")
  OptionGadget(#Opt_TrigNone,   100, ControlY, 90, 20, "Free Run (None)")
  OptionGadget(#Opt_TrigAuto,   200, ControlY, 70, 20, "Auto")
  OptionGadget(#Opt_TrigNormal, 280, ControlY, 70, 20, "Normal")
  
  ; Set Auto Mode as default checked UI option
  SetGadgetState(#Opt_TrigAuto, #True)
  
  ; Dropdown Combo box to select which channel acts as the Trigger Source
  TextGadget(#Txt_TrigSrc, 420, ControlY + 3, 100, 20, "Trigger Source:")
  ComboBoxGadget(#Cmb_TrigSrc, 520, ControlY - 2, 120, 24)
  AddGadgetItem(#Cmb_TrigSrc, SCOPE::#CH1, "Channel 1 (Yellow)")
  AddGadgetItem(#Cmb_TrigSrc, SCOPE::#CH2, "Channel 2 (Cyan)")
  AddGadgetItem(#Cmb_TrigSrc, SCOPE::#CH3, "Channel 3 (Magenta)")
  AddGadgetItem(#Cmb_TrigSrc, SCOPE::#CH4, "Channel 4 (Green)")
  SetGadgetState(#Cmb_TrigSrc, SCOPE::#CH1) ; Default to CH1
  
  ; 3. Core Initialization of the Oscilloscope System
  If SCOPE::InitScope(MyScope, #CanvasID)
    
    MyScope\BackColor   = RGBA(8, 12, 8, 255)       
    MyScope\GridColor = RGBA(0, 160, 0, 75)       
    MyScope\AxisX\Scale   = 0.4   
    
    Define ColorCH1.l = RGB(255, 230, 0)   
    Define ColorCH2.l = RGB(0, 230, 255)   
    Define ColorCH3.l = RGB(255, 0, 220)   
    Define ColorCH4.l = RGB(0, 255, 50)    
    
    #_RP_Items = 512
    
    SCOPE::SetupChannel(MyScope, SCOPE::#CH1, "CH 1", RGBA(Red(ColorCH1), Green(ColorCH1), Blue(ColorCH1), 255), #_RP_Items, 44100.0)
    SCOPE::SetupChannel(MyScope, SCOPE::#CH2, "CH 2", RGBA(Red(ColorCH2), Green(ColorCH2), Blue(ColorCH2), 255), #_RP_Items, 44100.0)
    SCOPE::SetupChannel(MyScope, SCOPE::#CH3, "CH 3", RGBA(Red(ColorCH3), Green(ColorCH3), Blue(ColorCH3), 255), #_RP_Items, 44100.0)
    SCOPE::SetupChannel(MyScope, SCOPE::#CH4, "CH 4", RGBA(Red(ColorCH4), Green(ColorCH4), Blue(ColorCH4), 255), #_RP_Items, 44100.0)
    
    MyScope\Channel(SCOPE::#CH1)\AxisY\Scale  = 100.0 : MyScope\Channel(SCOPE::#CH1)\AxisY\Offset = MyScope\Height * 0.25
    MyScope\Channel(SCOPE::#CH2)\AxisY\Scale  = 80.0  : MyScope\Channel(SCOPE::#CH2)\AxisY\Offset = MyScope\Height * 0.45
    MyScope\Channel(SCOPE::#CH3)\AxisY\Scale  = 60.0  : MyScope\Channel(SCOPE::#CH3)\AxisY\Offset = MyScope\Height * 0.65
    MyScope\Channel(SCOPE::#CH4)\AxisY\Scale  = 90.0  : MyScope\Channel(SCOPE::#CH4)\AxisY\Offset = MyScope\Height * 0.80
    
    MyScope\Trigger\Mode    = SCOPE::#TriggerMode_Auto
    MyScope\Trigger\Edge    = SCOPE::#TriggerEdge_Rising
    MyScope\Trigger\Level   = 0.0          
    MyScope\Trigger\Channel = SCOPE::#CH1  
    
    RefreshButtonState(MyScope, #Btn_CH1, SCOPE::#CH1, ColorCH1)
    RefreshButtonState(MyScope, #Btn_CH2, SCOPE::#CH2, ColorCH2)
    RefreshButtonState(MyScope, #Btn_CH3, SCOPE::#CH3, ColorCH3)
    RefreshButtonState(MyScope, #Btn_CH4, SCOPE::#CH4, ColorCH4)
  EndIf
  
  AddWindowTimer(0, #TimerID, 50)
  
  Define Event.i, GadgetID.i
  Define Quit.i = #False
  Define.d SignalTime = 0.0
  Define i.i
  
  Dim SampleBlock1.d(63)
  Dim SampleBlock2.d(63)
  Dim SampleBlock3.d(63)
  Dim SampleBlock4.d(63)
  
  ; --- Main Event Processing Loop ---
  Repeat
    Event = WaitWindowEvent()
    
    Select Event
      Case #PB_Event_CloseWindow
        Quit = #True
        
      Case #PB_Event_Gadget
        GadgetID = EventGadget()
        
        If GadgetID = #CanvasID
          SCOPE::HandleMouseEvents(MyScope) ; Implicit pointer passing
        EndIf
        
        Select GadgetID
          ; Channel Toggle Event Listeners using ToggleBool macro
          Case #Btn_CH1
            MyScope\Channel(SCOPE::#CH1)\IsActive = ToggleBool(MyScope\Channel(SCOPE::#CH1)\IsActive)
            RefreshButtonState(MyScope, #Btn_CH1, SCOPE::#CH1, ColorCH1)
          Case #Btn_CH2
            MyScope\Channel(SCOPE::#CH2)\IsActive = ToggleBool(MyScope\Channel(SCOPE::#CH2)\IsActive)
            RefreshButtonState(MyScope, #Btn_CH2, SCOPE::#CH2, ColorCH2)
          Case #Btn_CH3
            MyScope\Channel(SCOPE::#CH3)\IsActive = ToggleBool(MyScope\Channel(SCOPE::#CH3)\IsActive)
            RefreshButtonState(MyScope, #Btn_CH3, SCOPE::#CH3, ColorCH3)
          Case #Btn_CH4
            MyScope\Channel(SCOPE::#CH4)\IsActive = ToggleBool(MyScope\Channel(SCOPE::#CH4)\IsActive)
            RefreshButtonState(MyScope, #Btn_CH4, SCOPE::#CH4, ColorCH4)
            
          ; Trigger Mode Selection (Option Toggles)
          Case #Opt_TrigNone
            MyScope\Trigger\Mode = SCOPE::#TriggerMode_None
          Case #Opt_TrigAuto
            MyScope\Trigger\Mode = SCOPE::#TriggerMode_Auto
          Case #Opt_TrigNormal
            MyScope\Trigger\Mode = SCOPE::#TriggerMode_Normal
            
          ; Trigger Source Channel Combobox Changed
          Case #Cmb_TrigSrc
            MyScope\Trigger\Channel = GetGadgetState(#Cmb_TrigSrc)
            
        EndSelect
        
      Case #PB_Event_Timer
        If EventTimer() = #TimerID
          
          For i = 0 To 63
            SignalTime + 0.015
            SampleBlock1(i) = Sin(SignalTime) ;+ (Random(100) / 2500.0)
            SampleBlock2(i) = Cos(SignalTime * 1.5)
            SampleBlock3(i) = Sin(SignalTime * 4.0) * Cos(SignalTime * 0.2)
            
            If Sin(SignalTime * 0.8) > 0.0 : SampleBlock4(i) = 0.5 : Else : SampleBlock4(i) = -0.5 : EndIf
          Next i
          
          With MyScope\Channel(SCOPE::#CH1)
            RBUF::MultiAddDouble(\RBUF, SampleBlock1())
            RBUF::MultiAddDouble(\RBUF, SampleBlock2())
            RBUF::MultiAddDouble(\RBUF, SampleBlock3())
            RBUF::MultiAddDouble(\RBUF, SampleBlock4())          
          EndWith
          SCOPE::RenderScope(MyScope)
        EndIf
    EndSelect
    
  Until Quit = #True
  
  RemoveWindowTimer(0, #TimerID)
EndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 5
; FirstLine = 1
; Folding = -
; DPIAware
; CPU = 5