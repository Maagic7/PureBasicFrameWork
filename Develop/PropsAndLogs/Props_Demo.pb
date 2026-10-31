XIncludeFile "..\..\Modules\PbFw_Module_Props.pb"
XIncludeFile "..\..\Modules\PbFw_Module_LOG.pb"
XIncludeFile "PbFw_Module_PropsEditor.pb"

; Ensure native PB decoders are active for asset loading testing
UsePNGImageDecoder()
UseJPEGImageDecoder()
InitSound()
UseOGGSoundDecoder()
UseFLACSoundDecoder()

; Props Modul demo with LiveEdit (Extended Multimedia & MsgBox Test Suite)
CompilerIf #PB_Compiler_IsMainFile
  
  #Win_Main = 0
  #G_Main_String = 10
  #G_Main_Button = 11
  
  ; Media Test Gadgets
  #G_Main_Canvas = 12 
  #G_Main_Play   = 13 
  #G_Main_SndLbl = 14 
  
  ; --- NEW: Message Box Trigger Buttons ---
  #G_Main_BtnMsg1 = 15
  #G_Main_BtnMsg2 = 16

  ; 1. Initialize active configurations bag
  Define *GlobalConfig.Props::TPropBag = Props::NewBag()
  
  Props::SetPropLong(*GlobalConfig, "Setup/Network/BindPort",    9000, "Main socket port mapping.")
  Props::SetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg",  RGB($34, $49, $5E), "Primary window background.")
  Props::SetPropColor(*GlobalConfig, "Visuals/Colors/TextAccent", RGB($F1, $C4, $0F), "High visibility text color.")
  Props::SetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel",  "Arial,13,Bold", "Base typography definition.")
  
  Props::SetPropImage(*GlobalConfig, "Assets/Images/MainLogo", "logo.png", "Application header logo asset.")
  Props::SetPropSound(*GlobalConfig, "Assets/Sounds/Welcome",  "welcome.ogg", "Localization welcome chime audio.")
  
  ; --- NEW: Pre-define Localization Tokens for Message Boxes ---
  ; Key, Title, MessageText
  Props::SetPropMsgBox(*GlobalConfig, "Dialogs/Messages/InfoBox", "System Notification", "This is a static localization message text string.")
  Props::SetPropMsgBox(*GlobalConfig, "Dialogs/Messages/UserGreet", "Welcome Back", "Hello {PARAM1}! Your security clearing is level {PARAM2}.")

  ; Procedure to safely redraw the image asset onto our test canvas
  Procedure UpdateCanvasPreview(*Config.Props::TPropBag)
    Protected pbImg.i = Props::GetPropImage(*Config, "Assets/Images/MainLogo")
    
    If StartDrawing(CanvasOutput(#G_Main_Canvas))
      Box(0, 0, GadgetWidth(#G_Main_Canvas), GadgetHeight(#G_Main_Canvas), $EFEFEF)
      
      If pbImg And IsImage(pbImg)
        DrawImage(ImageID(pbImg), 5, 5, GadgetWidth(#G_Main_Canvas)-10, GadgetHeight(#G_Main_Canvas)-10)
      Else
        DrawText(10, 20, "[ No Image Loaded ]", $0000FF, $EFEFEF)
      EndIf
      StopDrawing()
    EndIf
  EndProcedure

  ; 2. Build the main window (Height increased to 580 to fit the new buttons)
  If OpenWindow(#Win_Main, 100, 100, 500, 580, "Main Production Workspace Application View", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    SetWindowColor(#Win_Main, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
    
    StringGadget(#G_Main_String, 20, 20, 460, 40, "Current App Port: " + Str(Props::GetPropLong(*GlobalConfig, "Setup/Network/BindPort")), #PB_String_ReadOnly)
    ButtonGadget(#G_Main_Button, 20, 80, 460, 45, "Open Hierarchical Configuration Center (PropsEditor)")
    
    ; Media UI Layout Controls
    CanvasGadget(#G_Main_Canvas, 20, 145, 460, 180)
    TextGadget(#G_Main_SndLbl, 20, 345, 460, 25, "Sound Path: " + Props::GetPropString(*GlobalConfig, "Assets/Sounds/Welcome"), #PB_Text_Center)
    ButtonGadget(#G_Main_Play, 20, 380, 460, 45, "🎵 Play Localization Sound Resource")
    
    ; --- NEW: Message Box Test Buttons ---
    ButtonGadget(#G_Main_BtnMsg1, 20, 445, 460, 45, "💬 Trigger Static MessageBox (InfoBox)")
    ButtonGadget(#G_Main_BtnMsg2, 20, 505, 460, 45, "💬 Trigger Dynamic Parameter MessageBox (UserGreet)")
    
    ; Initial UI Theming Setup
    SetGadgetColor(#G_Main_String, #PB_Gadget_BackColor,  Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
    SetGadgetColor(#G_Main_String, #PB_Gadget_FrontColor, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/TextAccent"))
    SetGadgetColor(#G_Main_SndLbl, #PB_Gadget_BackColor,  Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
    SetGadgetColor(#G_Main_SndLbl, #PB_Gadget_FrontColor, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/TextAccent"))
    
    If Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel")
      SetGadgetFont(#G_Main_String, Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel"))
      SetGadgetFont(#G_Main_SndLbl, Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel"))
    EndIf
    
    UpdateCanvasPreview(*GlobalConfig)
    
    ; 3. Single Main Loop Framework
    Repeat
      Define AppEvent.i = WaitWindowEvent()
      Define EditorStatus.i = 0
      
      ; Route events to the editor if it is currently open
      If PropsEditor::IsOpen()
        EditorStatus = PropsEditor::ProcessEvent(AppEvent)
        
        If EditorStatus = 1 ; Save was clicked inside the editor
          Debug "Changes committed successfully! Live-updating main UI layouts & media pipelines..."
          
          ; Live Update the UI metrics & colors
          SetWindowColor(#Win_Main, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
          SetGadgetColor(#G_Main_String, #PB_Gadget_BackColor,  Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
          SetGadgetColor(#G_Main_String, #PB_Gadget_FrontColor, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/TextAccent"))
          SetGadgetColor(#G_Main_SndLbl, #PB_Gadget_BackColor,  Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
          SetGadgetColor(#G_Main_SndLbl, #PB_Gadget_FrontColor, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/TextAccent"))
          
          SetGadgetText(#G_Main_String, "Current App Port: " + Str(Props::GetPropLong(*GlobalConfig, "Setup/Network/BindPort")))
          SetGadgetText(#G_Main_SndLbl, "Sound Path: " + Props::GetPropString(*GlobalConfig, "Assets/Sounds/Welcome"))
          
          If Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel")
            SetGadgetFont(#G_Main_String, Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel"))
            SetGadgetFont(#G_Main_SndLbl, Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel"))
          EndIf
          
          UpdateCanvasPreview(*GlobalConfig)
          
        ElseIf EditorStatus = -1
          Debug "Editor closed. Changes discarded."
        EndIf
      EndIf
      
      ; Handle Events for the Main Window (Window 0)
      If EventWindow() = #Win_Main
        Select AppEvent
          Case #PB_Event_Gadget
            Select EventGadget()
                
              Case #G_Main_Button
                If Not PropsEditor::IsOpen()
                  PropsEditor::Open(*GlobalConfig, #Win_Main)
                EndIf
                
               Case #G_Main_Play
                ; 1. Extract the dynamic sound pointer via the SndMgr backend pipeline
                Define pbSound.i = Props::GetPropSound(*GlobalConfig, "Assets/Sounds/Welcome")
                
                If pbSound And IsSound(pbSound)
                  
                  ; --- NEW: Toggle Play / Stop Logik based on current runtime status ---
                  If SoundStatus(pbSound) = #PB_Sound_Playing
                    StopSound(pbSound)
                    SetGadgetText(#G_Main_Play, "🎵 Play Localization Sound Resource")
                    Debug "Sound playback stopped by user interaction."
                  Else
                    PlaySound(pbSound)
                    SetGadgetText(#G_Main_Play, "⏹️ Stop Sound Resource Playback")
                    Debug "Playing audio token via SndMgr pipeline handle: #" + Str(pbSound)
                  EndIf
                  
                Else
                  Debug "Sound toggle failed: Audio asset file not found or invalid format."
                EndIf
                
              ; --- NEW: Handle MessageBox Triggers ---
              Case #G_Main_BtnMsg1
                ; Triggers the static text messagebox
                Props::MsgBox(*GlobalConfig, "Dialogs/Messages/InfoBox", #PB_MessageRequester_Info)
                
              Case #G_Main_BtnMsg2
                ; Triggers the dynamic text messagebox with real-time parameter injection
                Props::MsgBox(*GlobalConfig, "Dialogs/Messages/UserGreet", #PB_MessageRequester_Warning, "Developer", "Alpha-9")
                
            EndSelect
            
          Case #PB_Event_CloseWindow
            Break
            
        EndSelect
      EndIf
      
    ForEver
    
    Props::FreeBag(*GlobalConfig)
    CloseWindow(#Win_Main)
    Debug "Safe unified shutdown concluded."
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 42
; Folding = -
; Optimizer
; DPIAware
; Executable = Props_Demo.exe
; CPU = 5
; Compiler = PureBasic 6.41 - C Backend (Windows - x64)