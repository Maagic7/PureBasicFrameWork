; DSP DEMO Main


; ===========================================================================
;   DSP_Main.pb - Main Application GUI & Processing Pipeline
; ===========================================================================
; Description: Native PureBasic GUI featuring real-time visualizers
;              (Oscilloscope & Log Analyzer) and dynamic DSP parameter controls.
; Demo Project for Module DSP Digital Signal Processing from the Purebasic Framwork

; Co-authored by Google Gemini.
; ===========================================================================

XIncludeFile "..\..\Audio\PbFw_Module_DSP.pb"

; Main Parameter Modul
DeclareModule Main
  EnableExplicit  
  
  ; --- The central state of the entire application ---
  Structure TMainAppDSP
    ; Bypass flags
    BypassFilter.i
    BypassComp.i
    BypassDelay.i
    BypassPitch.i
    
    ; Live parameters from GUI
    CutoffHz.d
    FilterQ.d
    CompThresholdDB.d
    CompRatio.d
    DelayMs.d
    DelayFeedback.d
    PitchFactor.d
    OscType.i
    GenFrequency.d
    
    ; Shared configurations & Filter designs
    LowPassCfg.DSP::TBiquadCoeffs
    CompCfg.DSP::TDynamicsConfig
    DelayCfg.DSP::TDelayConfig
    PitchCfg.DSP::TPitchShifterConfig
    
    ; Persistent history states (Separate for Left/Right channels)
    LowPassStateL.DSP::TBiquadState     : LowPassStateR.DSP::TBiquadState
    CompStateL.DSP::TDynamicsState       : CompStateR.DSP::TDynamicsState
    DelayStateL.DSP::TDelayState         : DelayStateR.DSP::TDelayState
    PitchStateL.DSP::TPitchShifterState : PitchStateR.DSP::TPitchShifterState
    
    OscState.DSP::TOscillatorState
  EndStructure

  ; Globally accessible across all files via Main::DSP_Params
  Global DSP_Params.TMainAppDSP
EndDeclareModule

Module Main
  EnableExplicit 
  ; Internal app logic could go here later
EndModule

XIncludeFile "DSP_Draw.pb" ; Your DspDrw module
XIncludeFile "DSP_AudioIO.pb"       ; The virtual soundcard engine
; XIncludeFile "DSP_Core.pbi"        ; Include your core DSP module here if separate

; --- Enumerations for Gadgets & Windows ---
Enumeration Windows
  #Win_Main
EndEnumeration

Enumeration Gadgets
  #Pan_Controls
  ; Visualizers
  #Can_Scope
  #Can_Spectrum
  ; Filter Controls
  #Txt_Cutoff  : #Sld_Cutoff
  #Txt_FilterQ : #Sld_FilterQ
  #Chk_BypassFilter
  ; Compressor Controls
  #Txt_Thresh  : #Sld_Thresh
  #Txt_Ratio   : #Sld_Ratio
  #Chk_BypassComp
  ; Delay & Pitch Controls
  #Txt_Delay   : #Sld_Delay
  #Txt_Feedback: #Sld_Feedback
  #Txt_Pitch   : #Sld_Pitch
  #Chk_BypassDelay
  #Chk_BypassPitch
  #Txt_GenType : #Cmb_GenType
  #Txt_GenFreq : #Sld_GenFreq

EndEnumeration

Enumeration Timers
  #Tim_RefreshVisuals
EndEnumeration

; --- The Core Audio Processing Callback (Runs inside the Audio Background Thread) ---
Procedure AudioProcessingCallback(Array CH_Left.d(1), Array CH_Right.d(1), Length.i)
  ; 1. Apply Parametric Low-Pass Filter
  
  With Main::DSP_Params
    If Not \BypassFilter
      ; Dynamically recalculate coefficients if parameters were updated by GUI
      ; (Safe to do on-the-fly as it doesn't clear the sample history state)
      DSP::IIR_SetupLowPass(\LowPassCfg, 44100.0, \CutoffHz, \FilterQ)
      DSP::IIR_ProcessBlock(CH_Left(),  Length, \LowPassCfg, \LowPassStateL)
      DSP::IIR_ProcessBlock(CH_Right(), Length, \LowPassCfg, \LowPassStateR)
    EndIf
    
    ; 2. Apply Dynamic Range Compression
    If Not \BypassComp
      \CompCfg\ThresholdDB = \CompThresholdDB
      \CompCfg\Ratio       = \CompRatio
      DSP::Dynamics_ProcessBlock(CH_Left(),  Length, 44100.0, \CompCfg, \CompStateL)
      DSP::Dynamics_ProcessBlock(CH_Right(), Length, 44100.0, \CompCfg, \CompStateR)
    EndIf
    
    ; 3. Apply Pitch Shifting
    If Not \BypassPitch
      \PitchCfg\PitchFactor = \PitchFactor
      DSP::Pitch_ProcessBlock(CH_Left(),  Length, 44100.0, \PitchCfg, \PitchStateL)
      DSP::Pitch_ProcessBlock(CH_Right(), Length, 44100.0, \PitchCfg, \PitchStateR)
    EndIf
    
    ; 4. Apply Delay / Echo Loop
    If Not \BypassDelay
      \DelayCfg\DelayMs  = \DelayMs
      \DelayCfg\Feedback = \DelayFeedback
      DSP::Delay_ProcessBlock(CH_Left(),  Length, 44100.0, \DelayCfg, \DelayStateL)
      DSP::Delay_ProcessBlock(CH_Right(), Length, 44100.0, \DelayCfg, \DelayStateR)
    EndIf
  EndWith
EndProcedure

; --- Update GUI Sliders & Labels ---
Procedure UpdateGUI()
  With Main::DSP_Params
    ; 1. Generator updates
    \OscType      = GetGadgetState(#Cmb_GenType)
    \GenFrequency = GetGadgetState(#Sld_GenFreq)
    
    ; This line updates the label on the screen!
    SetGadgetText(#Txt_GenFreq, "Generator Frequency: " + Str(\GenFrequency) + " Hz")
    
    ; 2. Filter updates
    \CutoffHz = GetGadgetState(#Sld_Cutoff)
    \FilterQ  = GetGadgetState(#Sld_FilterQ) / 100.0
    SetGadgetText(#Txt_Cutoff, "Cutoff Frequency: " + Str(\CutoffHz) + " Hz")
    SetGadgetText(#Txt_FilterQ, "Filter Q-Factor: " + StrD(\FilterQ, 2))
    
    ; 3. Compressor updates
    \CompThresholdDB = -GetGadgetState(#Sld_Thresh)
    \CompRatio       = GetGadgetState(#Sld_Ratio) / 10.0
    SetGadgetText(#Txt_Thresh, "Threshold: " + StrD(\CompThresholdDB, 1) + " dB")
    SetGadgetText(#Txt_Ratio, "Compression Ratio: " + StrD(\CompRatio, 1) + ":1")
    
    ; 4. Delay & Pitch updates
    \DelayMs       = GetGadgetState(#Sld_Delay)
    \DelayFeedback = GetGadgetState(#Sld_Feedback) / 100.0
    \PitchFactor   = GetGadgetState(#Sld_Pitch) / 100.0
    SetGadgetText(#Txt_Delay, "Delay Time: " + Str(\DelayMs) + " ms")
    SetGadgetText(#Txt_Feedback, "Feedback Loop: " + Str(GetGadgetState(#Sld_Feedback)) + " %")
    SetGadgetText(#Txt_Pitch, "Pitch Factor: " + StrD(\PitchFactor, 2) + "x")
  EndWith

EndProcedure

; --- Initialize Default Application States ---
Procedure InitDSPDefaults()
  
  With Main::DSP_Params
    \CutoffHz        = 2000.0
    \FilterQ         = 0.71
    \CompThresholdDB = -20.0
    \CompRatio       = 4.0
    \DelayMs         = 300.0
    \DelayFeedback   = 0.40
    \PitchFactor     = 1.0
  
  ; Compressor basic configuration setup
    \CompCfg\AttackMs  = 10.0
    \CompCfg\ReleaseMs = 100.0
    \CompCfg\KneeDB    = 3.0
    \CompCfg\IsExpander = #False
  
  ; Delay default sizing initialization
    \DelayCfg\Mix = 0.50 ; Balanced 50/50 Wet/Dry
  
  ; Pitch shifter window defaults
    \PitchCfg\WindowSizeMs = 50.0
  
    \OscType      = DSP::#Oscillator_Sine
    \GenFrequency = 440.0
    \OscState\Phase = 0.0
 EndWith
 
EndProcedure

; --- Adjusted Main GUI Build with proper AddGadgetItem syntax ---
; --- Complete Main GUI Build Procedure (All Tabs Integrated) ---
Procedure OpenMainWindow()
  ; Open the main window centered on screen
  If OpenWindow(#Win_Main, 0, 0, 960, 600, "DSP Digial Singal Processing Demo", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    ; 1. The Screen Visualizers (Stacked Layout on the Left Side)
    CanvasGadget(#Can_Scope,     10, 10,  480, 275)
    CanvasGadget(#Can_Spectrum,  10, 295, 480, 275)
    
    ; 2. The Control Parameter Panel (Tabbed System on the Right Side)
    PanelGadget(#Pan_Controls, 500, 10, 440, 560)
      
      ; --- TAB 1: SIGNAL GENERATOR ---
      AddGadgetItem(#Pan_Controls, -1, "Signal Generator")
        TextGadget(#Txt_GenType, 20, 20, 380, 20, "Waveform Type:")
        ComboBoxGadget(#Cmb_GenType, 20, 45, 380, 25)
          AddGadgetItem(#Cmb_GenType, -1, "Sine Wave")
          AddGadgetItem(#Cmb_GenType, -1, "Triangle Wave")
          AddGadgetItem(#Cmb_GenType, -1, "Sawtooth Wave")
          AddGadgetItem(#Cmb_GenType, -1, "Square Wave (50% PWM)")
        SetGadgetState(#Cmb_GenType, 0) ; Default: Sine
        
        TextGadget(#Txt_GenFreq, 20, 95, 380, 20, "Generator Frequency: 440 Hz")
        TrackBarGadget(#Sld_GenFreq, 20, 120, 380, 40, 40, 2000, #PB_TrackBar_Ticks)
        SetGadgetState(#Sld_GenFreq, 440)
      
      ; --- TAB 2: PARAMETRIC FILTER ---
      AddGadgetItem(#Pan_Controls, -1, "IIR Filter")
        CheckBoxGadget(#Chk_BypassFilter, 20, 20, 200, 25, "Bypass Filter Stage")
        
        TextGadget(#Txt_Cutoff, 20, 70, 380, 20, "Cutoff Frequency: 2000 Hz")
        TrackBarGadget(#Sld_Cutoff, 20, 95, 380, 40, 40, 15000, #PB_TrackBar_Ticks)
        SetGadgetState(#Sld_Cutoff, 2000)
        
        TextGadget(#Txt_FilterQ, 20, 160, 380, 20, "Filter Q-Factor: 0.71")
        TrackBarGadget(#Sld_FilterQ, 20, 185, 380, 40, 10, 500, #PB_TrackBar_Ticks)
        SetGadgetState(#Sld_FilterQ, 71)
        
      ; --- TAB 3: DYNAMICS COMPRESSOR ---
      AddGadgetItem(#Pan_Controls, -1, "Dynamics")
        CheckBoxGadget(#Chk_BypassComp, 20, 20, 200, 25, "Bypass Compressor Stage")
        
        TextGadget(#Txt_Thresh, 20, 70, 380, 20, "Threshold: -20.0 dB")
        TrackBarGadget(#Sld_Thresh, 20, 95, 380, 40, 0, 60, #PB_TrackBar_Ticks)
        SetGadgetState(#Sld_Thresh, 20) ; Representing negative values (0 to -60)
        
        TextGadget(#Txt_Ratio, 20, 160, 380, 20, "Compression Ratio: 4.0:1")
        TrackBarGadget(#Sld_Ratio, 20, 185, 380, 40, 10, 200, #PB_TrackBar_Ticks)
        SetGadgetState(#Sld_Ratio, 40) ; Representing 1.0 to 20.0 (multiplied by 10)
        
      ; --- TAB 4: TIME & MODULATION ---
      AddGadgetItem(#Pan_Controls, -1, "Time & Pitch")
        CheckBoxGadget(#Chk_BypassDelay, 20, 20, 200, 25, "Bypass Delay Loop")
        CheckBoxGadget(#Chk_BypassPitch, 20, 50, 200, 25, "Bypass Pitch Shifter")
        
        TextGadget(#Txt_Delay, 20, 100, 380, 20, "Delay Time: 300 ms")
        TrackBarGadget(#Sld_Delay, 20, 125, 380, 40, 50, 1000, #PB_TrackBar_Ticks)
        SetGadgetState(#Sld_Delay, 300)
        
        TextGadget(#Txt_Feedback, 20, 180, 380, 20, "Feedback Loop: 40 %")
        TrackBarGadget(#Sld_Feedback, 20, 205, 380, 40, 0, 95, #PB_TrackBar_Ticks)
        SetGadgetState(#Sld_Feedback, 40)
        
        TextGadget(#Txt_Pitch, 20, 260, 380, 20, "Pitch Factor: 1.00x")
        TrackBarGadget(#Sld_Pitch, 20, 285, 380, 40, 50, 200, #PB_TrackBar_Ticks)
        SetGadgetState(#Sld_Pitch, 100) ; Representing 0.5x to 2.0x
        
    CloseGadgetList() ; Properly closes the PanelGadget container hierarchy
    
    ; Add system refresh timer running at ~33 FPS (every 30 milliseconds)
    AddWindowTimer(#Win_Main, #Tim_RefreshVisuals, 30)
  EndIf
EndProcedure


; --- Main Application Entry Point ---
InitDSPDefaults()
OpenMainWindow()
UpdateGUI()

; Setup processing sample arrays for visualization extraction
Dim DisplaySamples.d(1)

; Startup the virtual hardware engine at standard 44.1 kHz studio clock with 512 buffer frames
DSP_AudioIO::StartEngine(44100.0, 512)
DSP_AudioIO::RegisterCallback(@AudioProcessingCallback())
DSP_AudioIO::SetActive(#True)

; --- Main Event Loop ---
Define Event, EventGadget
Repeat
  Event = WaitWindowEvent()
  
  Select Event
    Case #PB_Event_Timer
      If EventTimer() = #Tim_RefreshVisuals
        Define.i currentBlockSize = DSP_AudioIO::GetLatestDisplayBlock(DisplaySamples())
        If currentBlockSize > 0
          DspDrw::DrawWaveform(#Can_Scope, DisplaySamples(), currentBlockSize)
          
          Dim ComplexBuffer.Complex::TComplex(currentBlockSize - 1)
          Dim MagnitudeBuffer.d(1)
          
          Define.i k
          For k = 0 To currentBlockSize - 1
            ComplexBuffer(k)\re = DisplaySamples(k)
            ComplexBuffer(k)\im = 0.0
          Next k
          
          DSP::FFT_Radix2(ComplexBuffer(), currentBlockSize)
          DSP::GetMagnitudeSpectrum(ComplexBuffer(), currentBlockSize, MagnitudeBuffer(), #True, 1.0)
          
          DspDrw::DrawSpectrum(#Can_Spectrum, MagnitudeBuffer(), ArraySize(MagnitudeBuffer()) + 1)
        EndIf
      EndIf
      
    Case #PB_Event_Gadget
      EventGadget = EventGadget()
      
      Select EventGadget
        ; HERE IS THE FIX: Every change to a slider or the combobox calls UpdateGUI() immediately!
        Case #Sld_GenFreq, #Cmb_GenType, #Sld_Cutoff, #Sld_FilterQ, #Sld_Thresh, #Sld_Ratio, #Sld_Delay, #Sld_Feedback, #Sld_Pitch
          UpdateGUI()
          
        Case #Chk_BypassFilter
          Main::DSP_Params\BypassFilter = GetGadgetState(#Chk_BypassFilter)
        Case #Chk_BypassComp
          Main::DSP_Params\BypassComp   = GetGadgetState(#Chk_BypassComp)
        Case #Chk_BypassDelay
          Main::DSP_Params\BypassDelay  = GetGadgetState(#Chk_BypassDelay)
        Case #Chk_BypassPitch
          Main::DSP_Params\BypassPitch  = GetGadgetState(#Chk_BypassPitch)
      EndSelect
      
    Case #PB_Event_CloseWindow
      DSP_AudioIO::StopEngine()
      Break
  EndSelect
Until Event = #PB_Event_CloseWindow

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 29
; Folding = --
; DPIAware
; CPU = 5