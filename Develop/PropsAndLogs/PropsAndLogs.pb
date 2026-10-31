XIncludeFile "..\..\Modules\PbFw_Module_Props.pb"
XIncludeFile "..\..\Modules\PbFw_Module_LOG.pb"
XIncludeFile "PbFw_Module_PropsEditor.pb"

;- =====================================================================
;- REAL EXECUTION TEST CODE (Combining Props and Log Modules)
;- =====================================================================

; CompilerIf #PB_Compiler_IsMainFile
;   
;   OpenConsole("Combined Framework: Props & Log Synergy Test")
;   
;   ; 1. Setup the Property Bag for system messages (simulating a language file)
;   Define *LogTexts.Props::TPropBag = Props::CreateBag()
;   
;   ; Populate our central message database
;   Props::SetProperty(*LogTexts, "Msg_Init_Success", Props::#Prop_String, 0, "Application engine initialized successfully completed.", "Boot pulse")
;   Props::SetProperty(*LogTexts, "Err_Db_Timeout",   Props::#Prop_String, 0, "Database connection dropped due to response timeout constraint.", "Critical DB failure")
;   Props::SetProperty(*LogTexts, "Warn_Mem_High",     Props::#Prop_String, 0, "System heap memory usage exceeded baseline warning threshold parameters.", "Memory notice")
;   
;   ; 2. Setup the Log Bag targeting a disk file
;   Define LogFile.s = GetTemporaryDirectory() + "production_runtime.log"
;   Define *AppLog.Log::TLogBag = Log::CreateLog(LogFile, Log::#TLog_Level_Info, #True)
;   
;   Debug "==> EXECUTION: Routing dynamic messages from Props storage directly into Log pipelines..."
;   Debug ""
;   
;   ; 3. Execute Logging using exclusively predefined properties
;   ; Look how clean, standardized, and professional the code execution reads now!
;   
;   Log::WriteLog(*AppLog, Log::#TLog_Level_Info, "Engine", Props::GetString(*LogTexts, "Msg_Init_Success"))
;   
;   Log::WriteLog(*AppLog, Log::#TLog_Level_Warning, "Memory", Props::GetString(*LogTexts, "Warn_Mem_High"))
;   
;   Log::WriteLog(*AppLog, Log::#TLog_Level_Error, "Database", Props::GetString(*LogTexts, "Err_Db_Timeout"))
;   
;   ; 4. What happens if a key is missing? The default parameter safeguards it!
;   Log::WriteLog(*AppLog, Log::#TLog_Level_Error, "Security", Props::GetString(*LogTexts, "Unknown_Key_Fallthrough", "Unauthorized system execution vector detected!"))
;   
;   ; Clean up environment layers cleanly
;   Props::FreeBag(*LogTexts)
;   Log::FreeLog(*AppLog)
;   
;   Debug ""
;   Debug "Framework execution successful. Inspection file written cleanly to disk."
;   Input()
;   
; CompilerEndIf

;- =====================================================================
;- REAL EXECUTION TEST CODE (Architecture with Single Main Loop)
;- =====================================================================

CompilerIf #PB_Compiler_IsMainFile
  
  #Win_Main = 0
  #G_Main_String = 10
  #G_Main_Button = 11

  ; 1. Initialize active configurations bag
  Define *GlobalConfig.Props::TPropBag = Props::NewBag()
  
  Props::SetPropLong(*GlobalConfig, "Setup/Network/BindPort",    9000, "Main socket port mapping.")
  Props::SetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg",  RGB($34, $49, $5E), "Primary window background.")
  Props::SetPropColor(*GlobalConfig, "Visuals/Colors/TextAccent", RGB($F1, $C4, $0F), "High visibility text color.")
  Props::SetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel",  "Arial,13,Bold", "Base typography definition.")

  ; 2. Build the main window (Window 0)
  If OpenWindow(#Win_Main, 100, 100, 500, 200, "Main Production Workspace Application View", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    SetWindowColor(#Win_Main, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
    
    StringGadget(#G_Main_String, 20, 30, 460, 40, "Current App Port: " + Str(Props::GetPropLong(*GlobalConfig, "Setup/Network/BindPort")), #PB_String_ReadOnly)
    ButtonGadget(#G_Main_Button, 20, 100, 460, 45, "Open Hierarchical Configuration Center (PropsEditor)")
    
    SetGadgetColor(#G_Main_String, #PB_Gadget_BackColor,  Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
    SetGadgetColor(#G_Main_String, #PB_Gadget_FrontColor, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/TextAccent"))
    
    If Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel")
      SetGadgetFont(#G_Main_String, Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel"))
    EndIf
    
    ; 3. Single Main Loop Framework
    Repeat
      Define AppEvent.i = WaitWindowEvent()
      Define EditorStatus.i = 0
      
      ; Route events to the editor if it is currently open
      If PropsEditor::IsOpen()
        EditorStatus = PropsEditor::ProcessEvent(AppEvent)
        
        If EditorStatus = 1 ; Save was clicked inside the editor
          Debug "Changes committed successfully! Live-updating main UI layout..."
          
          ; Live Update the main window with new data
          SetWindowColor(#Win_Main, Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
          SetGadgetColor(#G_Main_String, #PB_Gadget_BackColor,  Props::GetPropColor(*GlobalConfig, "Visuals/Colors/SurfaceBg"))
          SetGadgetColor(#G_Main_String, #PB_Gadget_FrontColor, Props::GetPropLong(*GlobalConfig, "Visuals/Colors/TextAccent"))
          SetGadgetText(#G_Main_String, "Current App Port: " + Str(Props::GetPropLong(*GlobalConfig, "Setup/Network/BindPort")))
          
          If Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel")
            SetGadgetFont(#G_Main_String, Props::GetPropFont(*GlobalConfig, "Visuals/Fonts/BaseLabel"))
          EndIf
          
        ElseIf EditorStatus = -1 ; Cancel or Close was clicked inside the editor
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
                
            EndSelect
            
          Case #PB_Event_CloseWindow
            Break ; Close main application cleanly
            
        EndSelect
      EndIf
      
    ForEver
    
    Props::FreeBag(*GlobalConfig)
    CloseWindow(#Win_Main)
    Debug "Safe unified shutdown concluded."
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 44
; Folding = -
; DPIAware
; CPU = 5