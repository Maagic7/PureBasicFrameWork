; ===========================================================================
;   DSP_AudioIO.pb - PureBasic Autonomous Virtual Audio I/O Engine
; ===========================================================================
; Description: Simulates a real-time hardware audio callback stream using a
;              high-priority background thread. Zero external DLL dependencies.
; Co-authored by Google Gemini.
; ===========================================================================

XIncludeFile "..\..\Modules\PbFw_Module_DSP.pb"

DeclareModule DSP_AudioIO
  EnableExplicit
 ; Starts the background audio rendering engine thread
  Declare.i StartEngine(SampleRate.d = 44100.0, BlockSize.i = 512)
  
  ; Safely stops and terminates the audio engine thread
  Declare.i StopEngine()
  
  ; Toggles the playback audio processing state on/off
  Declare.i SetActive(IsActive.i)
  
  ; Registers a user-defined processing callback procedure pointer
  ; The callback signature must be: YourProc(Array Left.d(1), Array Right.d(1), Length.i)
  Declare.i RegisterCallback(*ProcessingProc)
  
  ; Safely fetches the latest processed mono block for the GUI visualization thread
  Declare.i GetLatestDisplayBlock(Array OutputSignal.d(1))
  
 
EndDeclareModule

Module DSP_AudioIO
  
  EnableExplicit
  
  Prototype ProtoAudioCallback(Array CH_Left.d(1), Array CH_Right.d(1), Length.i)
 
  Structure TAudioEnginePrivate
    ThreadID.i
    MutexID.i
    IsRunning.i
    IsActive.i
    SampleRate.d
    BlockSize.i
    *Callback.ProtoAudioCallback
    
    OscState.DSP::TOscillatorState
    ; Shared thread-safe array for the GUI scope visualization
    Array DisplayBuffer.d(1)
  EndStructure

  Global Engine.TAudioEnginePrivate

  ; --- The Virtual Hardware Audio Callback (Background Thread) ---
  Procedure _AudioEngineThread(*Context)
    Protected.i i, frames
    Protected.d sleepTimeMs
    
    ; Setup dedicated signal source oscillators locally for this virtual driver
    ; to feed continuous synthetic audio into the processing pipe
    Protected.d phase = 0.0
    Protected.d phaseInc = 440.0 / Engine\SampleRate ; Default 440 Hz test tone sine
    
    ; Calculate the exact sleep time in milliseconds for one audio block duration
    ; For 512 samples at 44.1 kHz, this is approx. 11.6 milliseconds
    sleepTimeMs = (Engine\BlockSize / Engine\SampleRate) * 1000.0
    
    ; Allocate local scratchpad arrays for processing
    Dim LeftBlock.d(Engine\BlockSize - 1)
    Dim RightBlock.d(Engine\BlockSize - 1)
    
   While Engine\IsRunning
    ; Safe reading zone for the background thread
    LockMutex(Engine\MutexID)
    
    ; FETCH FROM MAIN MODULE: Read the live values from the central configuration
    ; We pass a local state for the oscillator phase (@Engine\OscState) which stays private to the thread
    DSP::Osc_GenerateBlock(LeftBlock(), Engine\BlockSize, Engine\SampleRate, Main::DSP_Params\OscType, Main::DSP_Params\GenFrequency, 0.5, @Engine\OscState)
    
    CopyArray(LeftBlock(), RightBlock())
    
    ; Execute your DSP processing chain (Filters, Compressor, etc.)
    If Engine\IsActive And Engine\Callback <> #Null
      Engine\Callback(LeftBlock(), RightBlock(), Engine\BlockSize)
    EndIf
    
    ; Copy processed block to display buffer
    Dim Engine\DisplayBuffer(Engine\BlockSize - 1)
    CopyArray(LeftBlock(), Engine\DisplayBuffer())
    
    UnlockMutex(Engine\MutexID)
    Delay(Int(sleepTimeMs))
  Wend  
EndProcedure

  ; --- Public Interface Functions ---

  Procedure.i StartEngine(SampleRate.d = 44100.0, BlockSize.i = 512)
    If Engine\IsRunning : ProcedureReturn #False : EndIf
    
    Engine\SampleRate = SampleRate
    Engine\BlockSize  = BlockSize
    Engine\IsRunning  = #True
    Engine\IsActive   = #False
    Engine\MutexID    = CreateMutex()
    
    Dim Engine\DisplayBuffer(BlockSize - 1)
    
    ; Fire up the high-priority simulation thread
    Engine\ThreadID = CreateThread(@_AudioEngineThread(), #Null)
    If Engine\ThreadID
      ProcedureReturn #True
    Else
      Engine\IsRunning = #False
      FreeMutex(Engine\MutexID)
      ProcedureReturn #False
    EndIf
  EndProcedure

  Procedure.i StopEngine()
    If Not Engine\IsRunning : ProcedureReturn #False : EndIf
    
    Engine\IsRunning = #False
    If WaitThread(Engine\ThreadID, 2000) = 0
      KillThread(Engine\ThreadID) ; Hard kill if thread locks up
    EndIf
    
    FreeMutex(Engine\MutexID)
    Engine\ThreadID = #Null
    Engine\MutexID  = #Null
    ProcedureReturn #True
  EndProcedure

  Procedure.i SetActive(IsActive.i)
    LockMutex(Engine\MutexID)
    Engine\IsActive = IsActive
    UnlockMutex(Engine\MutexID)
    ProcedureReturn #True
  EndProcedure

  Procedure.i RegisterCallback(*ProcessingProc)
    LockMutex(Engine\MutexID)
    Engine\Callback = *ProcessingProc
    UnlockMutex(Engine\MutexID)
    ProcedureReturn #True
  EndProcedure

  Procedure.i GetLatestDisplayBlock(Array OutputSignal.d(1))
    LockMutex(Engine\MutexID)
    ; In-Place fast array duplicate for the drawing engine
    Dim OutputSignal(ArraySize(Engine\DisplayBuffer()))
    CopyArray(Engine\DisplayBuffer(), OutputSignal())
    UnlockMutex(Engine\MutexID)
    ProcedureReturn ArraySize(OutputSignal()) + 1
  EndProcedure

EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 15
; Folding = --
; DPIAware
; CPU = 5