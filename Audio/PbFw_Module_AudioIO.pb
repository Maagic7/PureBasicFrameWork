; ===========================================================================
;  FILE : PbFw_Module_AudioIO.pb
;  NAME : Module AudioIO [AudioIO::]
;  DESC : Low-latency Audio Input/Output Streaming Module using Win32 API
;  DESC : Perfect for real-time DSP processing (Filtering, Synthesizers).
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; COAUTHOR :  Google Gemini
; DATE     :  2026/10/06
; VERSION  :  0.5  Developer Version
; COMPILER :  PureBasic 6.0
; OS       :  Windows
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;}
;{ TODO:
;}
; ===========================================================================


; ============================================================================
; USED WINDOWS CORE API 
; ============================================================================
; 1. API: waveOut (MMSYSTEM / winmm.dll)
;    DESC: Part of the legacy Windows Multimedia API. It provides a direct,
;          low-level C-interface for raw PCM audio playback. Uses a linear
;          double-buffering queue system to maintain continuous audio streams.
;          Extremely stable and does not require complex COM architectures.
;
; 2. API: waveIn (MMSYSTEM / winmm.dll)
;    DESC: The input counterpart to waveOut. It manages audio capture devices
;          like Microphones or Line-In hardware. It works by filling empty
;          user-allocated memory buffers via an interrupt-driven clock cycle.
;
; 3. SYNCHRONIZATION: Mutex API (kernel32.dll)
;    DESC: Utilizes PureBasic's built-in Mutex commands (which map to native 
;          Win32 CRITICAL_SECTION APIs). This prevents thread collisions and 
;          race conditions between the Windows high-priority audio callback
;          threads and the main application thread.
; ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "../Modules/PbFw_Module_PX.pb"           ; PX::     Purebasic Extention Module
; XIncludeFile "../Modules/PbFw_Module_PbFw.pb"         ; PbFw::   FrameWork control Module
; XIncludeFile "../Modules/PbFw_Module_Debug.pb"        ; DBG::    Debug Module

DeclareModule AudioIO
  EnableExplicit

  ;- --- PROTOTYPES ---
  ; Callback signature for rendering audio to the output stream (Soundcard)
  Prototype protoPlayCallback(*Buffer, Length)
  
  ; Callback signature for receiving audio from the input stream (Microphone)
  Prototype protoRecordCallback(*Buffer, Length)

  ;- --- PUBLIC FUNCTIONS ---
  ; Initializes the audio format configuration
  Declare.i Init(SampleRate = 44100, Channels.w = 2, Bits.w = 16)
  
  ; Starts the output audio stream and registers the DSP render callback
  Declare.i SartPlay(*procPlayCallback)
  Declare   StopPlay()
  
  ; Starts the input audio stream and registers the DSP recording callback
  Declare.i StartRecord(*procRecordCallback)
  Declare   StopRecord()
  
  ; Safely stops all streams, unregisters headers, and releases allocated memory
  Declare   Release()
EndDeclareModule

Module AudioIO
  ;- --- PRIVATE CONSTANTS & STRUCTURES ---
  #NUM_BUFFERS     = 2     ; Double-Buffering for stable streaming
  #BUFFER_DURATION = 0.05  ; Buffer duration in seconds (0.05 = 50ms latency)

;   Structure WAVEFORMATEX
;     wFormatTag.w
;     nChannels.w
;     nSamplesPerSec.l
;     nAvgBytesPerSec.l
;     nBlockAlign.w
;     wBitsPerSample.w
;     cbSize.w
;   EndStructure
  
;   Structure WAVEHDR
;     *lpData
;     dwBufferLength.l
;     dwBytesRecorded.l
;     dwUser.i
;     dwFlags.l
;     dwLoops.l
;     *lpNext
;     Reserved.i
;   EndStructure

  ;- --- PRIVATE GLOBALS ---
  Global hWaveOut.i = 0
  Global hWaveIn.i  = 0
  
  ; we use double Buffering for continous Streaming
  Global Dim outHeader.WAVEHDR(#NUM_BUFFERS - 1)    ; Header for Buffer(0..1)
  Global Dim outBufferPtr.i(#NUM_BUFFERS - 1)       ; Pointer to Buffer(0..1)
  
  ; we use double Buffering for continous Streaming
  Global Dim inHeader.WAVEHDR(#NUM_BUFFERS - 1)     ; Header for Buffer(0.1)
  Global Dim inBufferPtr.i(#NUM_BUFFERS - 1)        ; Pointer to Buffer(0..1)
  
  Global glWaveFormat.WAVEFORMATEX
  Global glBufferSize = 0
  
  Global procPlayCallback.protoPlayCallback = 0
  Global procRecordCallback.protoRecordCallback   = 0
  
  Global isOutRunning = #False
  Global isInRunning  = #False
  Global mutex        = 0

  ;- --- PRIVATE C-CALLBACKS ---
  
  ; Low-level Windows C-Callback for Audio Output
  ProcedureC waveOutProc(hwo, uMsg, dwInstance, dwParam1, dwParam2)
  ; ============================================================================
  ; NAME: waveOutProc
  ; DESC: Low-level Windows C-Callback for audio output. Automatically triggered
  ; DESC: by the OS when a buffer has finished playing and requires refilling.
  ; VAR(hwo): Handle to the wave-out device.
  ; VAR(uMsg): Wave-out message identifier (e.g., #WOM_DONE).
  ; VAR(dwInstance): User instance data passed to waveOutOpen.
  ; VAR(dwParam1): Pointer to the WAVEHDR structure of the finished buffer.
  ; VAR(dwParam2): Message-specific parameter (unused for #WOM_DONE).
  ; RET: None (Void C-Function).
  ; ============================================================================

    Protected *hdr.WAVEHDR = dwParam1
    
    ; #WOM_DONE indicates that Windows finished playing a buffer and needs new data
    If uMsg = #WOM_DONE And isOutRunning = #True
      LockMutex(mutex)
      If procPlayCallback
        ; Fetch new samples from the DSP library callback
        procPlayCallback(*hdr\lpData, *hdr\dwBufferLength)
      Else
        ; Fill with silence if no callback is registered
        FillMemory(*hdr\lpData, *hdr\dwBufferLength, 0)
      EndIf
      
      ; Send the refilled buffer back to the soundcard queue
      waveOutWrite_(hWaveOut, *hdr, SizeOf(WAVEHDR))
      UnlockMutex(mutex)
    EndIf
  EndProcedure

  ; Low-level Windows C-Callback for Audio Input
  ProcedureC waveInProc(hwi, uMsg, dwInstance, dwParam1, dwParam2)
  ; ============================================================================
  ; NAME: waveInProc
  ; DESC: Low-level Windows C-Callback for audio input. Automatically triggered
  ; DESC: by the OS when a buffer has been completely filled with raw microphone data.
  ; VAR(hwi): Handle to the wave-in device.
  ; VAR(uMsg): Wave-in message identifier (e.g., #WIM_DATA).
  ; VAR(dwInstance): User instance data passed to waveInOpen.
  ; VAR(dwParam1): Pointer to the WAVEHDR structure containing the recorded data.
  ; VAR(dwParam2): Message-specific parameter (unused for #WIM_DATA).
  ; RET: None (Void C-Function).
  ; ============================================================================    Protected *hdr.WAVEHDR = dwParam1
    
    Protected *hdr.WAVEHDR = dwParam1
    
    ; #WIM_DATA indicates that Windows filled a buffer with microphone data
    If uMsg = #WIM_DATA And isInRunning = #True
      LockMutex(mutex)
      If procRecordCallback
        ; Forward the recorded buffer directly to the DSP library
        procRecordCallback(*hdr\lpData, *hdr\dwBytesRecorded)
      EndIf
      
      ; Re-queue the empty buffer back to the recording hardware
      waveInAddBuffer_(hWaveIn, *hdr, SizeOf(WAVEHDR))
      UnlockMutex(mutex)
    EndIf
  EndProcedure

  ;- --- PUBLIC MODULE IMPLEMENTATION ---

  Procedure.i Init(SampleRate = 44100, Channels.w = 2, Bits.w = 16)
  ; ============================================================================
  ; NAME: Init
  ; DESC: Initializes the global PCM audio format structure and calculates
  ; DESC: the optimal streaming buffer size based on the target duration.
  ; VAR(SampleRate): Audio sampling frequency in Hz (e.g., 44100).
  ; VAR(Channels): Number of audio channels (1 = Mono, 2 = Stereo).
  ; VAR(Bits): Bit depth per sample (typically 8, 16, or 24).
  ; RET: #True if initialization succeeded and the internal mutex was created.
  ; ============================================================================
    If mutex = 0
      mutex = CreateMutex()
    EndIf
    
    ; 1. Define the linear PCM format structure
    With glWaveFormat
      \wFormatTag      = #WAVE_FORMAT_PCM
      \nChannels       = Channels
      \nSamplesPerSec  = SampleRate
      \wBitsPerSample  = Bits
      \nBlockAlign     = (Channels * Bits) / 8
      \nAvgBytesPerSec = SampleRate * \nBlockAlign
      \cbSize          = 0
    
      ; 2. Calculate optimal buffer size based on duration and block alignment
      Protected rawSize = SampleRate * #BUFFER_DURATION * \nBlockAlign
      ; Align buffer size to block boundaries
      glBufferSize = rawSize - (rawSize % \nBlockAlign)
    EndWith
   
    ProcedureReturn #True
  EndProcedure

  Procedure.i SartPlay(*procPlayCallback)
  ; ============================================================================
  ; NAME: SartPlay
  ; DESC: Opens the native Windows playback device, prepares the double-buffers,
  ; DESC: fills them with initial audio data, and starts the output stream.
  ; VAR(*procPlayCallback): Pointer to the external DSP function used to render audio samples.
  ; RET: #True if the output stream successfully started, #False otherwise.
  ; ============================================================================
    Protected I
    
    If isOutRunning : ProcedureReturn #False : EndIf
    procPlayCallback = *procPlayCallback
    
    ; 1. Open Output Device using the C Callback Function convention
    If waveOutOpen_(@hWaveOut, #WAVE_MAPPER, @glWaveFormat, @waveOutProc(), 0, #CALLBACK_FUNCTION) <> #MMSYSERR_NOERROR
      ProcedureReturn #False
    EndIf
    
    isOutRunning = #True
    
    ; 2. Allocate, prepare, and pre-fill streaming buffers
    For I = 0 To #NUM_BUFFERS - 1
      outBufferPtr(I) = AllocateMemory(glBufferSize)
      
      If procPlayCallback
        procPlayCallback(outBufferPtr(I), glBufferSize)
      Else
        FillMemory(outBufferPtr(I), glBufferSize, 0)
      EndIf
      
      outHeader(I)\lpData         = outBufferPtr(I)
      outHeader(I)\dwBufferLength = glBufferSize
      outHeader(I)\dwFlags        = 0
      
      waveOutPrepareHeader_(hWaveOut, @outHeader(I), SizeOf(WAVEHDR))
      waveOutWrite_(hWaveOut, @outHeader(I), SizeOf(WAVEHDR))
    Next
    
    ProcedureReturn #True
  EndProcedure

  Procedure StopPlay()
  ; ============================================================================
  ; NAME: StopPlay
  ; DESC: Stops audio playback, flushes the Windows hardware queue,
  ; DESC: unprepares all output headers, and releases allocated buffer memory.
  ; RET: None.
  ; ============================================================================
    Protected I
    If isOutRunning = #False : ProcedureReturn : EndIf
    
    LockMutex(mutex)
    isOutRunning = #False
    waveOutReset_(hWaveOut) ; Instantly stops playback and marks all buffers as done
    
    ; Clean up headers and memory
    For I = 0 To #NUM_BUFFERS - 1
      waveOutUnprepareHeader_(hWaveOut, @outHeader(I), SizeOf(WAVEHDR))
      If outBufferPtr(I)
        FreeMemory(outBufferPtr(I))
        outBufferPtr(I) = 0
      EndIf
    Next
    
    waveOutClose_(hWaveOut)
    hWaveOut = 0
    UnlockMutex(mutex)
  EndProcedure

  Procedure.i StartRecord(*procRecordCallback)
  ; ============================================================================
  ; NAME: StartRecord
  ; DESC: Opens the native Windows recording device, allocates raw capture buffers,
  ; DESC: queues them up to the hardware, and engages the audio capture clock.
  ; VAR(+procRecordCallback): Pointer to the external DSP function that processes recorded data.
  ; RET: #True if the input recording stream successfully started, #False otherwise.
  ; ============================================================================
    Protected I
    
    If isInRunning : ProcedureReturn #False : EndIf
    procRecordCallback = *procRecordCallback
    
    ; 1. Open Input Device using the C Callback Function convention
    If waveInOpen_(@hWaveIn, #WAVE_MAPPER, @glWaveFormat, @waveInProc(), 0, #CALLBACK_FUNCTION) <> #MMSYSERR_NOERROR
      ProcedureReturn #False
    EndIf
    
    isInRunning = #True
    
    ; 2. Allocate, prepare, and queue raw recording buffers
    For i = 0 To #NUM_BUFFERS - 1
      inBufferPtr(i) = AllocateMemory(glBufferSize)
      
      inHeader(i)\lpData         = inBufferPtr(i)
      inHeader(i)\dwBufferLength = glBufferSize
      inHeader(i)\dwFlags        = 0
      
      waveInPrepareHeader_(hWaveIn, @inHeader(i), SizeOf(WAVEHDR))
      waveInAddBuffer_(hWaveIn, @inHeader(i), SizeOf(WAVEHDR))
    Next
    
    ; 3. Explicitly start the Windows hardware audio capture clock
    waveInStart_(hWaveIn)
    
    ProcedureReturn #True
  EndProcedure

  Procedure StopRecord()
  ; ============================================================================
  ; NAME: StopRecord
  ; DESC: Safely terminates the hardware recording clock, flushes internal queues,
  ; DESC: clears input headers, and frees all allocated recording memory.
  ; RET: None.
  ; ============================================================================
   Protected I
    If isInRunning = #False : ProcedureReturn : EndIf
    
    LockMutex(mutex)
    isInRunning = #False
    waveInStop_(hWaveIn)    ; Stop recording clock
    waveInReset_(hWaveIn)   ; Clear internal windows queues
    
    ; Clean up headers and memory
    For I = 0 To #NUM_BUFFERS - 1
      waveInUnprepareHeader_(hWaveIn, @inHeader(I), SizeOf(WAVEHDR))
      If inBufferPtr(I)
        FreeMemory(inBufferPtr(I))
        inBufferPtr(I) = 0
      EndIf
    Next
    
    waveInClose_(hWaveIn)
    hWaveIn = 0
    UnlockMutex(mutex)
  EndProcedure

  Procedure Release()
  ; ============================================================================
  ; NAME: Release
  ; DESC: Master cleanup function. Halts both input and output streams, releases
  ; DESC: all active hardware buffers, and destroys the thread-synchronization mutex.
  ; RET: None.
  ; ============================================================================
    StopPlay()
    StopRecord()
    If mutex
      FreeMutex(mutex)
      mutex = 0
    EndIf
  EndProcedure
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
; ============================================================================
;  NAME: AudioIO_Stereo_Test.pb
;  DESC: Simple verification script for the AudioIO module. 
;        Generates a continuous real-time stereo sine wave.
; ============================================================================

  ; XIncludeFile "PbFw_Module_AudioIO.pbi" 
  
  Global phase.f = 0.0
  
  ; ============================================================================
  ; NAME: Play_Callback
  ; DESC: Real-time audio playback callback. Triggered by the AudioIO module
  ; DESC: whenever the soundcard requires a new block of raw PCM samples.
  ; VAR(*Buffer): Pointer to the raw memory buffer provided by Windows.
  ; VAR(Length): Total size of the buffer in bytes.
  ; RET: None (Void C-Function).
  ; ============================================================================
  ProcedureC Play_Callback(*Buffer, Length)    
    Protected I
    Protected *Ptr.Word = *Buffer ; Interpret memory as 16-Bit signed integers (Words)
    
    Protected frequencyLeft.f  = 440.0 ; Left Channel: 440 Hz (A)
    Protected frequencyRight.f = 660.0 ; Right Channel: 660 Hz (E)
    
    ; 16-Bit Stereo uses 4 bytes per sample block (2 channels * 2 bytes)
    Protected totalSamples = Length / 4 
    
    For I = 0 To totalSamples - 1
      ; --- LEFT CHANNEL ---
      ; 16-Bit range is -32768 to 32767. Using 25000 for a clear, safe volume.
      *Ptr\w = 25000 * Sin(phase)
      *Ptr + 2
      
      ; --- RIGHT CHANNEL ---
      ; Using a slightly faster phase/frequency for the right ear
      *Ptr\w = 25000 * Sin(phase * (frequencyRight / frequencyLeft))
      *Ptr + 2
      
      ; Advance phase based on the standard 44100 Hz sample rate
      phase + (2.0 * #PI * frequencyLeft / 44100.0)
      If phase > 2.0 * #PI 
        phase - (2.0 * #PI) 
      EndIf
    Next
  EndProcedure
  
  ; ============================================================================
  ; NAME: Record_Callback
  ; DESC: Real-time audio capture callback. Receives stereo input and shows 
  ; DESC: how to separate or select the Left or Right channel for DSP processing.
  ; VAR(*Buffer): Pointer to the raw memory buffer containing recorded data.
  ; VAR(Length): Total size of the recorded data in bytes.
  ; RET: None (Void C-Function).
  ; ============================================================================
  ProcedureC Record_Callback(*Buffer, Length)
    Protected i.l
    Protected *SamplePtr.Word = *Buffer
    Protected totalSampleBlocks.l = Length / 4 ; 16-Bit Stereo = 4 Bytes per Block
    
    Protected leftChannelSample.w
    Protected rightChannelSample.w
    
    For i = 0 To totalSampleBlocks - 1
      
      ; 1. Read the interleaved channels from the stream
      leftChannelSample  = *SamplePtr\w : *SamplePtr + 2
      rightChannelSample = *SamplePtr\w : *SamplePtr + 2
      
      ; 2. CHOOSE YOUR CHANNEL FOR YOUR DSP LIBRARY HERE:
      ; If you only want to process the Left Channel:
      ; MyDSP_ApplyFilter(leftChannelSample)
      
      ; If you only want to process the Right Channel:
      ; MyDSP_ApplyFilter(rightChannelSample)
      
    Next
  EndProcedure
  
  ; --- MAIN APPLICATION EXECUTION ---
  
  ; 1. Initialize the module (44.1kHz, 2 Channels, 16-Bit)
  If AudioIO::Init(44100, 2, 16)
    
    ; 2. Pass our DSP function pointer to the output stream
    If AudioIO::SartPlay(@Play_Callback())
      
      ; 3. Create a simple window to keep the application and thread alive
      OpenWindow(0, 0, 0, 360, 120, "AudioIO Stereo Test", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
      TextGadget(0, 10, 45, 340, 30, "Stereo Stream is running..." + #LF$ + "Close window to stop.", #PB_Text_Center)
      
      Define NoOfAudioOutputs = waveOutGetNumDevs_()
      Define NoOfAusioInputs  = waveInGetNumDevs_()
      Debug "Number of availible Audio output devices = " + NoOfAudioOutputs 
      Debug "Number of availible Audio input  devices = " + NoOfAusioInputs 
       
      ; Main event loop
      Repeat
      Until WaitWindowEvent() = #PB_Event_CloseWindow
      
      ; 4. Clean up everything on exit
      AudioIO::Release()
      
    Else
      MessageRequester("Error", "Failed to start the audio output stream!", #PB_MessageRequester_Error)
    EndIf
    
  Else
    MessageRequester("Error", "Failed to initialize AudioIO device!", #PB_MessageRequester_Error)
  EndIf

CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 329
; FirstLine = 378
; Folding = ---
; DPIAware
; CPU = 5