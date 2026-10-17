; ===========================================================================
;  FILE: PbFw_Module_DSP.pb
;  NAME: Module Digital Signal Processing 
;  DESC: 
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://rosettacode.org/wiki/Fast_Fourier_transform#VBA
;     https://en.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; COAUTHOR :  Google Gemini
; DATE     :  2025/04/21
; VERSION  :  0.5 untested Developer Version
; COMPILER :  PureBasic 6.0 and higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 

; 2026/10/16 S.Maag : first public version for Testers and Develpers
;}
;{ TODO: a lot!
;}
; ===========================================================================

; Notes on implementation
; I used Google Gemini in the free version only with the browser front end!

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "..\Modules\PbFw_Module_PX.pb"            ; PX::        Purebasic Extention Module
XIncludeFile "..\Modules\PbFw_Module_PbFw.pb"          ; PbFw::      FrameWork control Module
XIncludeFile "..\Modules\PbFw_Module_Debug.pb"         ; DBG::       Debug Module
XIncludeFile "..\Modules\PbFw_Module_Complex.pb"       ; Complex::   Complex Math Module
XIncludeFile "..\Modules\PbFw_Module_Bit.pb"           ; Bit::       Bit operations

; XIncludeFile ""

DeclareModule DSP
  
  EnableExplicit 
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
   Enumeration eFiltWinType
    #FiltWinType_None                  ; 0
    #FiltWinType_Bartlett              ; 1
    #FiltWinType_Bartlett_Hann         ; 2
    #FiltWinType_Blackman              ; 3
    #FiltWinType_Blackman_Harris       ; 4
    #FiltWinType_Blackman_Nuttal       ; 5
    #FiltWinType_Flat_Top              ; 6
    #FiltWinType_Gauss                 ; 7
    #FiltWinType_Hamming_Generalized   ; 8
    #FiltWinType_Hamming               ; 9
    #FiltWinType_Hanning               ; 10
    #FiltWinType_Kaiser                ; 11
    #FiltWinType_Lanczos               ; 12
    #FiltWinType_Nuttal                ; 13
    #FiltWinType_Rettangolare          ; 14
    #FiltWinType_Triangolare           ; 15
    #FiltWinType_Tukey                 ; 16
    #FiltWinType_Weber                 ; 17
    #FiltWinType_Welch                 ; 18
  EndEnumeration
  #_FiltWinType_MaxIndex = #PB_Compiler_EnumerationValue -1 
  
  Structure TFilterWindowData 
    Name.s      ; Name della "Window":
    PMin.d      ; Valore Min. del Parametro associato.
    PMax.d      ; Valore Max. del Parametro associato.
    PCor.d      ; Valore corrente del Parametro associato.
  EndStructure
  
  ; https://de.wikipedia.org/wiki/Fensterfunktion
  ; https://en.wikipedia.org/wiki/Window_function
  
  ; Filter Window Types
  
  ; None/Rectangular: Passes the signal unmodified, offering maximum frequency resolution but high spectral leakage
  ;                   Best for transients and short pulses where edge damping would distort total signal energy
  
  ; Bartlett        : A simple triangular-shaped profile that linearly tapers the signal down To zero at the edges
  ;                   Used for basic smoothing when low computational complexity is preferred over sidelobe suppression
  
  ; Bartlett-Hann   : Combines the Bartlett And Hann formulas To achieve lower side-lobes without widening the main-lobe
  ;                   Applied in general spectral analysis where a narrower mainlobe than Blackman is required.
  
  ; Blackman        : Uses a three-term cosine sum To provide significantly higher side-lobe suppression than Hamming
  ;                   Ideal for general harmonic analysis where reducing spectral leakage is more critical than frequency resolution
  
  ; Blackman-Harris : A high-performance four-term window designed For excellent side-lobe attenuation in measurement instruments
  ;                   The industry standard for high-dynamic range measurements to detect small signals near strong carriers
  
  ; Blackman-Nuttall: Optimizes the Blackman-Harris coefficients To achieve the fastest possible side-lobe decay rate
  ;                   Perfect for high-resolution instrumentation requiring the fastest possible sidelobe decay rate.
  
  ; Flat Top        : A specialized window With a wide peak that ensures maximum amplitude measurement accuracy For sinusoids
  ;                   Mandatory for precision calibration systems where absolute voltage or current amplitude accuracy is required
  
  ; Gauss           : A bell-shaped curve based on the Gaussian distribution where the width is controlled by a parameter
  ;                   Excellent for time-frequency analysis (Gabor transform) due to its mathematically minimal time-bandwidth product
  
  ; Hamming Generalized: A flexible cosine-taper window where the alpha coefficient can be dynamically tuned via a parameter
  ;                      Used in adaptive filtering algorithms where the window shape needs To be tuned dynamically
  
  ; Hamming         : A classic all-rounder window optimized To cancel the first prominent side-lobe of a rectangular window
  ;                   Widely used in telecommunications and speech processing to optimize the separation of closely spaced frequencies
  
  ; Hanning/Hann    : A smooth, raised-cosine profile that drops strictly To zero at both edges To minimize leakage
  ;                   The standard choice for power grid harmonic distortion (THD) and audio spectrum analysis
  
  ; Kaiser          : An advanced window utilizing the modified Bessel function To flexibly trade main-lobe width For side-lobe attenuation
  ;                   Perfect For advanced FIR filter design And variable systems requiring on-the-fly tuning of sidelobe attenuation
  
  ; Lanczos         : Based on the central section of a Sinc function, commonly used To smoothly truncate infinite impulse responses
  ;                   Primarily used in digital image processing, resampling, and spatial reconstruction algorithms to minimize artifacts
  
  ; Nuttall         : A highly optimized four-term cosine window focused on achieving a very narrow main-lobe With deep dämpfung
  ;                   Chosen for high-resolution spectral monitoring where suppressing distant sidelobes is highly critica
  
  ; Triangular      : Similar To Bartlett but can be configured To maintain non-zero values at the very first And last sample
  ;                 Used in time-domain interpolation and statistical signal smoothing where boundary zeroing is optional
  
  ; Tukey           : A tapered cosine window that transitions dynamically from a flat rectangular center To smooth Hann edges
  ;                   Ideal for analyzing burst signals, machine vibrations, or radar pulses while tapering only the outermost edges
  
  ; Weber           : A specialized window designed To optimize energy concentration inside the main-lobe For specific filter designs
  ;                   Specialized for communications engineering to maximize energy efficiency within a strictly limited bandwidth
  
  ; Welch           : A simple parabolic curve that drops To zero at the boundaries, offering low computational complexity
  ;                   Excellent for real-time mobile DSP applications due to its extremely low mathematical and CPU complexity
  
  ; ----------------------------------------------------------------------
  ;- FFT Fast Fourier Transformation
  ; ----------------------------------------------------------------------

  ; --- Window Functions ---
  ; Applies the selected window function directly to the complex data array (In-Place).
  Declare.i ApplyFilterWindow(Array Z.Complex::TComplex(1), N.i, FiltWinType.i, Parameter.d = 0.0)

  ; --- Fourier Transformations ---
  ; Performs a forward Fast Fourier Transformation (In-Place, Radix-2 Cooley-Tukey).
  Declare.i FFT_Radix2(Array Z.Complex::TComplex(1), N.l)
  
  ; Performs an inverse Fast Fourier Transformation (In-Place, Radix-2 Cooley-Tukey).
  Declare.i IFFT_Radix2(Array Z.Complex::TComplex(1), N.l)
  
  ; Computes a flat 2D magnitude spectrum (dB scale) across a shifting time-domain signal.
  Declare.i STFT(Array InputSignal.d(1), SignalLength.i, WindowSize.i, HopSize.i, FiltWinType.i, WindowParam.d, Array OutputMag.d(1))
  
  ; Extracts the magnitude spectrum (Linear or Decibel) from the complex FFT array.
  Declare.i GetMagnitudeSpectrum(Array Z.Complex::TComplex(1), N.i, Array Mag.d(1), AsDecibels.i = #False, RefLevel.d = 1.0)

  ; ----------------------------------------------------------------------
  ;- Digital Filters
  ; ----------------------------------------------------------------------
  
  Structure TBiquadCoeffs       ; IIR Biquad Filters
    b0.d
    b1.d
    b2.d
    a1.d
    a2.d
  EndStructure
  
  ; Biquad Filter State (it's the Filters Static Data. Like a Filter_This)
  Structure TBiquadState        
    x1.d ; Input sample t-1
    x2.d ; Input sample t-2
    y1.d ; Output sample t-1
    y2.d ; Output sample t-2
  EndStructure
  
  ; --- IIR Biquad Filters --- 
  ; Setup helpers for various IIR Biquad filter types
  Declare.i IIR_SetupLowPass(*Coeffs.TBiquadCoeffs, SampleRate.d, CutoffHz.d, Q.d = 0.7071)
  Declare.i IIR_SetupHighPass(*Coeffs.TBiquadCoeffs, SampleRate.d, CutoffHz.d, Q.d = 0.7071)
  Declare.i IIR_SetupBandPass(*Coeffs.TBiquadCoeffs, SampleRate.d, CenterHz.d, Q.d = 1.0)
  Declare.i IIR_SetupNotch(*Coeffs.TBiquadCoeffs, SampleRate.d, NotchHz.d, Q.d = 10.0)
  Declare.i IIR_SetupLowShelf(*Coeffs.TBiquadCoeffs, SampleRate.d, CutoffHz.d, GainDB.d, Q.d = 0.7071)
  Declare.i IIR_SetupHighShelf(*Coeffs.TBiquadCoeffs, SampleRate.d, CutoffHz.d, GainDB.d, Q.d = 0.7071)
  Declare.i IIR_SetupPeakingEQ(*Coeffs.TBiquadCoeffs, SampleRate.d, CenterHz.d, GainDB.d, Q.d = 1.0)
  ; Main processing loop for applying any pre-calculated Biquad filter coefficients (In-Place).
  Declare.i IIR_ProcessBlock(Array Signal.d(1), Length.i, *Coeffs.TBiquadCoeffs, *State.TBiquadState)
  
  ; ----------------------------------------------------------------------

  ; --- Allpass Filters (Phase modulation & Reverb design) ---
  Structure TAllpassConfig
    Gain.d
    DelaySamples.i
  EndStructure

  Structure TAllpassState
    Array Buffer.d(1)
    BufferSize.i
    WriteIdx.i
  EndStructure

  Declare.i Allpass_InitState(*State.TAllpassState, DelaySamples.i)
  Declare.i Allpass_ProcessBlock(Array Signal.d(1), Length.i, *Cfg.TAllpassConfig, *State.TAllpassState)
  
   ;-  Dynamics Processing 
  ; ----------------------------------------------------------------------

  ; --- Dynamics Processing (Compressor / Expander) ---
  Structure TDynamicsConfig
    ThresholdDB.d ; Threshold in dB (e.g., -20.0 dB)
    Ratio.d       ; Compression ratio (e.g., 4.0 for 4:1) or Expansion ratio (e.g., 0.5 for 1:2)
    KneeDB.d      ; Soft-knee width in dB (0.0 = hard knee)
    AttackMs.d    ; Attack time in milliseconds
    ReleaseMs.d   ; Release time in milliseconds
    IsExpander.i  ; #True for Expander mode, #False for Compressor mode
  EndStructure

  Structure TDynamicsState
    Envelope.d    ; Current persistent envelope detector level (linear)
  EndStructure
  
  ; Pre-calculates detector coefficients to avoid complex math in the audio loop
  ; AttackCoef / ReleaseCoef convert MS time into an exponential smoothing factor per sample
  Declare Dynamics_CalcCoefs(SampleRate.d, AttackMs.d, ReleaseMs.d, *AttCoef.Double, *RelCoef.Double)

  ; Applies dynamic range compression or expansion to an audio block (In-Place).
  Declare.i Dynamics_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TDynamicsConfig, *State.TDynamicsState)
  
  ; ----------------------------------------------------------------------
  
  ; --- Brickwall Limiter ---
  Structure TLimiterConfig
    CeilingDB.d    ; Maximum output level in dB (e.g., -0.1 dB)
    ThresholdDB.d  ; Input threshold / drive in dB (lower values boost loudness)
    ReleaseMs.d    ; Release time in milliseconds (e.g., 50.0 ms)
    LookAheadMs.d  ; Look-ahead time in milliseconds (e.g., 2.0 ms)
  EndStructure

  Structure TLimiterState
    Array Buffer.d(1)  ; Ring buffer for look-ahead delay
    BufferSize.i       ; Allocated size of the buffer
    WriteIdx.i         ; Current write pointer position
    GainEnv.d          ; Persistent gain reduction envelope
  EndStructure
  
  ; High-speed Look-Ahead brickwall limiter for peak clipping prevention (In-Place).
  Declare.i Limiter_InitState(*State.TLimiterState, SampleRate.d, LookAheadMs.d)
  Declare.i Limiter_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TLimiterConfig, *State.TLimiterState)
  
  ; ----------------------------------------------------------------------
 
   ; --- Noise Gate ---
  Structure TGateConfig
    ThresholdDB.d ; Threshold in dB (signals below this will be muted)
    FloorDB.d     ; Range / Gain floor in dB (e.g., -80.0 dB for silence)
    AttackMs.d    ; Time taken to open the gate in milliseconds
    HoldMs.d      ; Time the gate stays open after signal drops below threshold
    ReleaseMs.d   ; Time taken to close the gate in milliseconds
  EndStructure

  Structure TGateState
    Envelope.d    ; Persistent signal level detector
    GainEnv.d     ; Persistent gain envelope (0.0 to 1.0)
    HoldSamples.i ; Dynamic countdown counter for the hold phase
  EndStructure
  
  ; Downward Noise Gate to mute or attenuate signal levels in quiet sections (In-Place).
  Declare.i Gate_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TGateConfig, *State.TGateState)

  ; ----------------------------------------------------------------------
  ;-  Delay and Modulation 
  ; ----------------------------------------------------------------------
  
  ; --- Delay & Echo ---
  Structure TDelayConfig
    DelayMs.d     ; Delay time in milliseconds (e.g., 300.0 ms)
    Feedback.d    ; Feedback factor (0.0 to 0.95)
    Mix.d         ; Wet/Dry Mix (0.0 = clean, 1.0 = wet only)
  EndStructure

  Structure TDelayState
    Array Buffer.d(1)  ; Ring buffer holding past audio samples
    BufferSize.i       ; Maximum allocated size of the buffer
    WriteIdx.i         ; Current write position
  EndStructure
  
  ; --- Time Domain & Modulation Effects ---
  ; Basic Ring-Buffer based Feedback Delay and Echo effect (In-Place).
  Declare.i Delay_InitState(*State.TDelayState, SampleRate.d, MaxDelayMs.d = 2000.0)
  Declare.i Delay_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TDelayConfig, *State.TDelayState)
  
  ; ----------------------------------------------------------------------

  ; --- Modulation Effects (Chorus / Flanger) ---
  Structure TModulationConfig
    Type.i        ; 0 = Chorus, 1 = Flanger
    RateHz.d      ; LFO Modulation frequency in Hz
    DepthMs.d     ; Modulation intensity in milliseconds
    BaseDelayMs.d ; Static offset delay in milliseconds
    Feedback.d    ; Feedback factor (mainly for Flanger)
    Mix.d         ; Wet/Dry Mix (0.0 to 1.0)
  EndStructure

  Structure TModulationState
    Array Buffer.d(1)  ; Ring buffer for the delay line
    BufferSize.i       ; Maximum allocated size
    WriteIdx.i         ; Current write position
    LfoPhase.d         ; Persistent phase of the LFO oscillator (0.0 to 2*PI)
  EndStructure 
  
  ; Unfused LFO-driven Chorus and Flanger modulation processor (In-Place).
  Declare.i Mod_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TModulationConfig, *State.TModulationState)
  Declare.i Mod_InitState(*State.TModulationState, SampleRate.d)
  
  ; ----------------------------------------------------------------------

  ; --- Time-Domain Pitch Shifter ---
  Structure TPitchShifterConfig
    PitchFactor.d  ; Pitch shift factor (e.g., 2.0 = octave up, 0.5 = down)
    WindowSizeMs.d ; Size of the delay window in milliseconds (30.0 - 100.0)
  EndStructure

  Structure TPitchShifterState
    Array Buffer.d(1)  ; Ring buffer for the delay line
    BufferSize.i       ; Maximum allocated size
    WriteIdx.i         ; Current write position
    Phase0.d           ; Playback phase for pointer 0 (0.0 to 1.0)
  EndStructure

  ; Time-Domain Pitch Shifter using dual crossfaded linear-interpolated taps (In-Place).
  Declare.i Pitch_InitState(*State.TPitchShifterState, SampleRate.d, WindowSizeMs.d = 50.0)
  Declare.i Pitch_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TPitchShifterConfig, *State.TPitchShifterState)
      
  ; ----------------------------------------------------------------------
  ;- Signal Correction & Metering
  ; ----------------------------------------------------------------------

  ; --- DC Offset Removal ---
  Structure TDCOffsetConfig
    CutoffHz.d ; Cutoff frequency (typically 1.0 Hz to 5.0 Hz)
  EndStructure

  Structure TDCOffsetState
    x1.d ; Previous input sample
    y1.d ; Previous output sample
  EndStructure

  ; Ultra-fast 1-pole high-pass filter to remove DC offset / centering issues (In-Place).
  Declare.i DCOffset_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TDCOffsetConfig, *State.TDCOffsetState)
  ; Phase inversion utility (flips signal polarity, In-Place).
  Declare.i Phase_Invert(Array Signal.d(1), Length.i)
  ; High-resolution TPDF dither and conversion into exportable 16-Bit Signed Integer arrays.
  Declare.i Dither_To16Bit(Array FloatSignal.d(1), Length.i, Array Int16Output.w(1))
  
   ; --- Level Metering ---
  Structure TLevelMeterResult
    PeakDB.d   ; Highest peak level in dBFS
    RmsDB.d    ; Root Mean Square energy level in dBFS
    PeakLin.d  ; Linear peak value (0.0 to 1.0)
    RmsLin.d   ; Linear RMS value (0.0 to 1.0)
  EndStructure
  
  ; Measures peak amplitude and Root Mean Square (RMS) energy levels transformed to dBFS.
  Declare.i Measure_Levels(Array Signal.d(1), Length.i, *Result.TLevelMeterResult)
  
  ; ----------------------------------------------------------------------
  ;- FIR Finite Impulse Response
  ; ----------------------------------------------------------------------
  
  Structure TFirConfig
    Array Taps.d(1)   ; Impulse response coefficients
    NumTaps.i         ; Number of taps
  EndStructure

  Structure TFirState
    Array History.d(1); Ring buffer for past input samples
    BufferSize.i      ; Must match NumTaps
    WriteIdx.i        ; Current write pointer position
  EndStructure
  
   ; Standard time-domain FIR convolution filter for short impulse responses (In-Place).
  Declare.i FIR_InitState(*State.TFirState, NumTaps.i)
  Declare.i FIR_ProcessBlock(Array Signal.d(1), Length.i, *Cfg.TFirConfig, *State.TFirState)
  
  ; ----------------------------------------------------------------------

  ; --- Fast Frequency-Domain Convolution ---
  Structure TFastConvConfig
    Array IrFFT.Complex::TComplex(1) ; Pre-computed FFT of the impulse response
    FFTSize.i                         ; Full FFT length (2 * BlockSize)
  EndStructure

  Structure TFastConvState
    Array OverlapBuffer.d(1)          ; Overlapping tail from previous block
    OverlapSize.i                     ; Size of the tail (equals BlockSize)
  EndStructure
  
  ; Fast frequency-domain overlap-add convolution reverb for long room acoustics (In-Place).
  Declare.i FastConv_PrepareIR(Array RawIR.d(1), IrLen.i, *Cfg.TFastConvConfig, BlockSize.i)
  Declare.i FastConv_ProcessBlock(Array Signal.d(1), Length.i, *Cfg.TFastConvConfig, *State.TFastConvState)

  ; ----------------------------------------------------------------------
  ;- Singal Generators
  ; ----------------------------------------------------------------------

  Enumeration eOscillatorType
    #Oscillator_Sine     
    #Oscillator_Triangle 
    #Oscillator_Sawtooth 
    #Oscillator_Rectangle
  EndEnumeration
  
  ; --- resampling  ---
  Enumeration eResampleType
    #Resample_Linear
    #Resample_Sinc 
  EndEnumeration
  
  Enumeration eNoiseTyoe
    #Noise_White 
    #Noise_Pink
  EndEnumeration
  
  Structure TOscillatorState
    Phase.d ; Persistent phase accumulator (0.0 to 1.0)
  EndStructure
  
  Structure TNoiseState
    Rows.d[16]    ; Persistent rows for the Voss-McCartney Pink Noise generator
    RunningSum.d  ; Running sum of the rows for Pink Noise
    Index.i       ; Sequence index to determine which row to update
  EndStructure
  
  Declare Osc_GenerateBlock(Array Signal.d(1), Length.i, SampleRate.d, Type.i, Frequency.d, PulseWidth.d, *State.TOscillatorState)
  Declare Noise_InitState(*State.TNoiseState)
  Declare Noise_GenerateBlock(Array Signal.d(1), Length.i, Type.i, *State.TNoiseState)
  
  ; ----------------------------------------------------------------------
  ;- Extented Analysis
  ; ----------------------------------------------------------------------

  ; Measures the Crest Factor (dynamic density) either as a linear ratio or in decibels (dB).
  Declare.d Measure_CrestFactor(Array Signal.d(1), Length.i, AsDecibels.i = #True)
  ; Detects the fundamental pitch (fundamental frequency in Hz) of a monophonic signal.
  Declare.d Detect_Pitch_ACF(Array Signal.d(1), Length.i, SampleRate.d, MinFreqHz.d = 60.0, MaxFreqHz.d = 800.0, Threshold.d = 0.80)

EndDeclareModule

Module DSP
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ; ----------------------------------------------------------------------
  ; STRUCTURES and CONSTANTS
  ; ----------------------------------------------------------------------  
  
  Procedure.i FilterWindowType(Array outWinType.TFilterWindowData(1))
    Protected.i I
    
    ; check Array Size
    If ArraySize(outWinType()) < #_FiltWinType_MaxIndex
      ReDim outWinType(#_FiltWinType_MaxIndex)
    EndIf
    
    ; Set Datasectopm Pointer
    Restore FilterWindowData
    
    ; Daten strukturiert einlesen
    For I = 0 To #_FiltWinType_MaxIndex
      Read.s outWinType(I)\Name
      Read.d outWinType(I)\PMin
      Read.d outWinType(I)\PMax
      Read.d outWinType(I)\PCor
    Next I
    
    ProcedureReturn #_FiltWinType_MaxIndex +1
    
  EndProcedure
  
  DataSection
    FilterWindowData:
    ; This are the Min/Max Datas for Filter functions. Use it for the GUI Filter Parameter Slider
    ;      Name / Parameter (PMin, PMax, PCor)
    Data.s "None"
    Data.d -1.0, -1.0, 0.0      
    
    Data.s "Bartlett"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Bartlett-Hann"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Blackman"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Blackman-Harris"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Blackman-Nuttal"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Flat top"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Gauss"
    Data.d 0.05, 0.5, 0.2
    
    Data.s "Hamming Generalized"
    Data.d 0.5, 1.0, 0.5
    
    Data.s "Hamming"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Hanning"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Kaiser"
    Data.d 0.5, 20.0, 10.0
    
    Data.s "Lanczos"
    Data.d 0.5, 3.5, 1.4
    
    Data.s "Nuttal"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Rettangolare"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Triangolare"
    Data.d -1.0, -1.0, 0.0
    
    Data.s "Tukey"
    Data.d 0.5, 1.0, 1.0
    
    Data.s "Weber"
    Data.d 0.5, 1.0, 1.0
    
    Data.s "Welch"
    Data.d 0.5, -1.0, -1.0
  EndDataSection
  
  ; Zeroth-order modified Bessel function of the first kind I0(x)
  ; Uses a highly efficient Taylor series expansion for numerical stability.
  Procedure.d _BesselI0(x.d)
    Protected.d sum = 1.0, ds = 1.0, d
    Protected.i k = 1
    
    x = x * 0.5  ; x = x / 2.0
    While ds > 1e-12 And k < 100
      d = x / k
      ds = ds * d * d
      sum = sum + ds
      k + 1
    Wend
    
    ProcedureReturn sum
  EndProcedure
  
  
  Procedure ApplyFilterWindow(Array Z.Complex::TComplex(1), N.i, FiltWinType.i, Parameter.d = 0.0)
    Protected.i I
    Protected.d term, alpha, beta, bessel_denom, k_term
    
    ; Windowing mathematisch erfordert mindestens 2 Elemente
    If N <= 1 : ProcedureReturn : EndIf
    
    ; Einmalige Vorausberechnung der zentralen Dimensionen als Double
    Protected.d dN    = N - 1
    Protected.d HalfN  = dN / 2.0
    Protected.d InvH   = 1.0 / HalfN
    
    ; Vorausberechnete Faktoren für die trigonometrischen Fenster, um Divisionen in der Schleife zu sparen
    Protected.d f2pi = (2.0 * #PI) / dN
    Protected.d f4pi = f2pi * 2.0
    Protected.d f6pi = f2pi * 3.0
    Protected.d f8pi = f2pi * 4.0
    
    Select FiltWinType
        
      Case #FiltWinType_Bartlett ; Triangular window with zero endpoints
        For I = 0 To N - 1
          term = 1.0 - Abs((I - HalfN) * InvH)
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Hanning ; Classic Von-Hann raised cosine window
        For I = 0 To N - 1
          term = 0.5 * (1.0 - Cos(I * f2pi))
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Hamming ; Standard Hamming window
        For I = 0 To N - 1
          term = 0.54 - 0.46 * Cos(I * f2pi)
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Hamming_Generalized ; Generalized Hamming window
        alpha = Parameter
        Protected.d one_minus_alpha = 1.0 - alpha
        
        For I = 0 To N - 1
          term = alpha - one_minus_alpha * Cos(I * f2pi)
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Blackman ; Blackman window
        For I = 0 To N - 1
          term = 0.42 - 0.5 * Cos(I * f2pi) + 0.08 * Cos(I * f4pi)
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Blackman_Harris ; 4-term Blackman-Harris window
        For I = 0 To N - 1
          term = 0.35875 - 0.48829 * Cos(I * f2pi) + 0.14128 * Cos(I * f4pi) - 0.01168 * Cos(I * f6pi)
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Flat_Top ; High amplitude measurement accuracy
        For I = 0 To N - 1
          term = 0.21557895 - 0.41663158 * Cos(I * f2pi) + 0.27726315 * Cos(I * f4pi) - 0.08357894 * Cos(I * f6pi) + 0.00694736 * Cos(I * f8pi)
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Gauss ; Gaussian window
        If Parameter <= 0.0 : Parameter = 0.2 : EndIf
        Protected.d inv_sigma_halfN = 1.0 / (Parameter * HalfN)
        For I = 0 To N - 1
          k_term = (I - HalfN) * inv_sigma_halfN
          term = Exp(-0.5 * k_term * k_term)
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Welch ; Parabolic window profile
        For I = 0 To N - 1
          k_term = (I - HalfN) * InvH
          term = 1.0 - k_term * k_term
          Z(I)\re * term
          Z(I)\im * term
        Next
        
      Case #FiltWinType_Tukey ; Tapered Cosine window
        alpha = Parameter
        If alpha <= 0.0
          ; Entspricht Rectangular (nichts tun, da w = 1.0)
          ProcedureReturn
        ElseIf alpha >= 1.0
          ; Entspricht exakt dem Hann-Fenster
          For I = 0 To N - 1
            term = 0.5 * (1.0 - Cos(I * f2pi))
            Z(I)\re * term
            Z(I)\im * term
          Next
        Else
          Protected.d tukey_edge = dN * alpha / 2.0
          Protected.d inv_tukey_edge = 1.0 / tukey_edge
          Protected.d tukey_factor = 2.0 * #PI * inv_tukey_edge
          For I = 0 To N - 1
            If I < tukey_edge
              term = 0.5 * (1.0 - Cos(I * tukey_factor))
            ElseIf I > dN - tukey_edge
              term = 0.5 * (1.0 - Cos((dN - I) * tukey_factor))
            Else
              term = 1.0
            EndIf
            Z(I)\re * term
            Z(I)\im * term
          Next
        EndIf
        
      Case #FiltWinType_Kaiser ; Kaiser window
        beta = Parameter
        If beta <= 0.0 : beta = 6.0 : EndIf 
        bessel_denom = _BesselI0(beta)
        
        If bessel_denom <> 0.0
          Protected.d inv_bessel_denom = 1.0 / bessel_denom
          For I = 0 To N - 1
            k_term = (I - HalfN) * InvH
            term = _BesselI0(beta * Sqr(1.0 - k_term * k_term)) * inv_bessel_denom
            Z(I)\re * term
            Z(I)\im * term
          Next
        EndIf
        
    EndSelect
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- FFT
  ;- ----------------------------------------------------------------------

  ; https://en.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm

  ; Radix-2-FFT: Cooley und Tukey : N = 2^n
  ; Core Concept: Divide And Conquer
  ; Radix 2 is a massive speed boost compared to recurive FFT (4x to 8x faster)
  ;
  ; The Iterative Radix-2 FFT delivers the exact same mathematical result As the recursive version, 
  ; but it is highly optimized for real-world hardware, making it the absolute standard for 
  ; DSP (Digital Signal Processing) and electrical engineering software.
  
  ; The algorithm speeds up the Discrete Fourier Transform (DFT) from \(\mathcal{O}(N^2)\)
  ; to \(\mathcal{O}(N \log_2 N)\) complexity by breaking down a large problem into smaller pieces. 
  ; It strictly requires \(N\) To be a power of 2 (\(N = 2^n\)).
  ; The input data array is reordered using Bit-Reversal Permutation.
  ; This separates the Data points based on their binary index parity (even/odd sorting down To single elements) 
  ; Purpose: Arranges the memory so the calculation can be performed completely In-Place without needing additional memory templates.
  ; Once all \(\log _{2}N\) structural stages are completed, the original time-domain Array contains the combined frequency spectrum.
  ; For physical systems (like Electrical Engineering), the array is finally scaled by \(1/N\) to normalize the actual 
  ; spectral amplitudes (e.g., in Volts Or Amperes) 
  
  ; Recursive FFT: 
  ;   Processing high-resolution electrical signals 
  ;   (e.g., N = 8192 samples Or higher) creates a deeply nested call tree. 
  ;   This easily triggers a Stack Overflow, crashing your application.
  
  ; Iterative FFT: 
  ;   The stack footprint is completely static. 
  ;   It will handle a million data points just as safely as eight data points.
     ; Applies the selected window function directly to the complex data array (In-Place).
  ; Z():         The input signal array (Time domain)
  ; N:           The number of samples (Must be a power of 2)
  ; FiltWinType:  The ID from eFiltWinType (#FiltWinType_Hamming, etc.)
  ; Parameter:   The active configuration value (PCor) for parametric windows

  Procedure FFT_Radix2(Array Z.Complex::TComplex(1), N.l)
    Protected.i I, J, k, bits, stepSize, halfStep
    Protected.d phi, t_re, t_im, c_re, c_im
    Protected.i idx1, idx2
    
    ; 1. Bit-Reversal-Permutation
    bits = Int(Round(Log(N) / Log(2), #PB_Round_Nearest))
    For I = 0 To N - 1
      J = (Bit::BitReverse32(I) >> (32 - bits)) & $FFFFFFFF
      If I < J
        ; Using PureBasic's highly optimized built-in Swap statement
        Swap Z(I)\re, Z(J)\re
        Swap Z(I)\im, Z(J)\im
      EndIf
    Next
    
    ; 2. Iterative Butterfly-Operation (Cooley-Tukey)
    stepSize = 2
    
    While stepSize <= N
      halfStep = stepSize / 2  
      
      ; Outer loop runs through the butterfly legs
      For I = 0 To halfStep - 1
        ; Twiddle factor calculated only ONCE per 'I'
        phi = (-2.0 * #PI * I) / stepSize
        t_re = Cos(phi)
        t_im = Sin(phi)
        
        ; Inner loop steps through the array using 'While' 
        ; because PureBasic does not support dynamic step sizes in 'For' loops
        k = 0
        While k < N
          idx1 = k + I
          idx2 = idx1 + halfStep
          
          ; Inlined Complex::CMul for maximum speed (avoids procedure call overhead)
          c_re = t_re * Z(idx2)\re - t_im * Z(idx2)\im
          c_im = t_im * Z(idx2)\re + t_re * Z(idx2)\im
          
          ; Butterfly operation directly inside the array
          Z(idx2)\re = Z(idx1)\re - c_re
          Z(idx2)\im = Z(idx1)\im - c_im
          
          Z(idx1)\re = Z(idx1)\re + c_re
          Z(idx1)\im = Z(idx1)\im + c_im
          
          k + stepSize ; Dynamic stepping via variable addition
        Wend
      Next
      
      stepSize * 2
    Wend
    
    ; 3. Amplitude scaling (1/N) via multiplication
    Protected.d invN = 1.0 / N
    For I = 0 To N - 1
      Z(I)\re * invN
      Z(I)\im * invN
    Next
  EndProcedure
  
  ; Inverse FFT
  Procedure IFFT_Radix2(Array Z.Complex::TComplex(1), N.l)
    Protected.i I, J, k, bits, stepSize, halfStep
    Protected.d phi, t_re, t_im, c_re, c_im
    Protected.i idx1, idx2
    
    ; 1. Bit-Reversal-Permutation (Identical to forward FFT)
    bits = Int(Round(Log(N) / Log(2), #PB_Round_Nearest))
    For I = 0 To N - 1
      J = (Bit::BitReverse32(I) >> (32 - bits)) & $FFFFFFFF
      If I < J
        ; Using PureBasic's highly optimized built-in Swap statement
        Swap Z(I)\re, Z(J)\re
        Swap Z(I)\im, Z(J)\im
      EndIf
    Next
    
    ; 2. Iterative Butterfly-Operation (Cooley-Tukey)
    stepSize = 2
    
    While stepSize <= N
      halfStep = stepSize / 2  
      
      ; Outer loop runs through the butterfly legs
      For I = 0 To halfStep - 1
        ; Twiddle factor: Angle is POSITIVE for the Inverse FFT (+2.0 * #PI)
        phi = (2.0 * #PI * I) / stepSize
        t_re = Cos(phi)
        t_im = Sin(phi)
        
        ; Inner loop steps through the array using 'While' 
        k = 0
        While k < N
          idx1 = k + I
          idx2 = idx1 + halfStep
          
          ; Inlined Complex::CMul for maximum speed
          c_re = t_re * Z(idx2)\re - t_im * Z(idx2)\im
          c_im = t_im * Z(idx2)\re + t_re * Z(idx2)\im
          
          ; Butterfly operation directly inside the array
          Z(idx2)\re = Z(idx1)\re - c_re
          Z(idx2)\im = Z(idx1)\im - c_im
          
          Z(idx1)\re = Z(idx1)\re + c_re
          Z(idx1)\im = Z(idx1)\im + c_im
          
          k + stepSize ; Dynamic stepping via variable addition
        Wend
      Next
      
      stepSize * 2
    Wend
    
    ; Note: No amplitude scaling (1/N) here, because the forward FFT 
    ; already took care of the 1/N scaling.
  EndProcedure
 
  
  ; Performs a Short-Time Fourier Transformation (STFT) on a 1D input signal.
  ; InputSignal():  The raw input audio data (Time domain, mono)
  ; SignalLength:  Total number of samples in the input signal
  ; WindowSize:    The size of the FFT window (e.g., 1024, 2048 - must be power of 2)
  ; HopSize:       The step size between frames (e.g., WindowSize / 4 for 75% overlap)
  ; FiltWinType:    The window function ID to use for ApplyFilterWindow()
  ; WindowParam:   Optional parameter for parametric windows (like Kaiser/Gauss)
  ; OutputMag():   1D Output array containing the flat 2D magnitude spectrum.
  ;                Layout: [Frame 0 (halfN elements), Frame 1 (halfN elements), ...]
  ; Returns:       The total number of generated time frames.
  Procedure.i STFT(Array InputSignal.d(1), SignalLength.i, WindowSize.i, HopSize.i, FiltWinType.i, WindowParam.d, Array OutputMag.d(1))
    Protected.i I, sampleIdx, frameIdx, totalFrames
    Protected.i halfN = WindowSize / 2
    
    ; Safety checks
    If SignalLength < WindowSize Or WindowSize <= 2 Or HopSize <= 0 : ProcedureReturn 0 : EndIf
    
    ; Calculate how many frames will fit into the signal
    totalFrames = 1 + Int((SignalLength - WindowSize) / HopSize)
    If totalFrames <= 0 : ProcedureReturn 0 : EndIf
    
    ; Allocate the flat 2D output array for magnitudes (only storing the positive frequencies up to Nyquist)
    ; The size is totalFrames * (halfN + 1)
    Dim OutputMag(totalFrames * (halfN + 1) - 1)
    
    ; Allocate a temporary complex array for the active FFT frame
    Dim WorkFrame.Complex::TComplex(WindowSize - 1)
    
    ; Pre-calculate dB conversion factors to speed up the inner loop
    Protected.d log10_factor = 20.0 / Log(10.0)
    Protected.d min_threshold = 1e-7
    
    ; Process the signal frame by frame
    For frameIdx = 0 To totalFrames - 1
      sampleIdx = frameIdx * HopSize
      
      ; 1. Extract samples from input signal into complex workspace
      For I = 0 To WindowSize - 1
        WorkFrame(I)\re = InputSignal(sampleIdx + I)
        WorkFrame(I)\im = 0.0 ; Real input signal has no imaginary part initially
      Next
      
      ; 2. Apply the window function (in-place)
      ApplyFilterWindow(WorkFrame(), WindowSize, FiltWinType, WindowParam)
      
      ; 3. Execute the forward FFT (in-place)
      FFT_Radix2(WorkFrame(), WindowSize)
      
      ; 4. Calculate magnitudes directly into the flat 2D output array
      Protected.i outputOffset = frameIdx * (halfN + 1)
      Protected.d r, im, mag
      
      For I = 0 To halfN
        r = WorkFrame(I)\re
        im = WorkFrame(I)\im
        mag = Sqr(r * r + im * im)
        
        ; Convert to dB scale for visual representation (Spectrogram)
        If mag < min_threshold
          mag = min_threshold
        EndIf
        
        OutputMag(outputOffset + I) = Log(mag) * log10_factor
      Next
    Next frameIdx
    
    ProcedureReturn totalFrames
  EndProcedure
  
  ; Calculates the magnitude spectrum from the complex FFT data.
  ; Z():          The complex data array after FFT
  ; N:            The full FFT size (Must match the size used in FFT)
  ; Mag():        The output array for the magnitude values. 
  ;               It will automatically be resized to N/2 (Nyquist frequency)
  ; AsDecibels:   If #True, converts the values to log-scale (dB)
  ; RefLevel:     Reference level for 0 dB calculation (commonly 1.0)
  Procedure GetMagnitudeSpectrum(Array Z.Complex::TComplex(1), N.i, Array Mag.d(1), AsDecibels.i = #False, RefLevel.d = 1.0)
    Protected.i I, halfN
    Protected.d real, imag, magnitude
    
    If N <= 2 : ProcedureReturn : EndIf
    
    ; For real input signals, the spectrum is symmetric.
    ; We only need the first half (from 0 to Nyquist frequency).
    halfN = N / 2
    Dim Mag(halfN)
    
    If AsDecibels
      ; Pre-calculate constant factor for dB translation: 20 * Log10(x)
      ; In PureBasic, Log(x) is the natural logarithm (ln). 
      ; To get Log10, we divide by Log(10).
      Protected.d log10_factor = 20.0 / Log(10.0)
      Protected.d inv_ref = 1.0 / RefLevel
      
      ; Avoid Log(0) errors by introducing a tiny threshold (-140 dB baseline)
      Protected.d min_threshold = 1e-7 
      
      For I = 0 To halfN
        real = Z(I)\re
        imag = Z(I)\im
        
        ; Calculate Euclidean distance (Magnitude = Sqr(Re^2 + Im^2))
        magnitude = Sqr(real * real + imag * imag)
        
        ; Apply reference and scale to Decibels (dBFS)
        magnitude * inv_ref
        If magnitude < min_threshold
          magnitude = min_threshold
        EndIf
        
        Mag(I) = Log(magnitude) * log10_factor
      Next
      
    Else
      ; Linear Magnitude scale
      For I = 0 To halfN
        real = Z(I)\re
        imag = Z(I)\im
        Mag(I) = Sqr(real * real + imag * imag)
      Next
    EndIf
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Digital Filters
  ;- ----------------------------------------------------------------------
  
  ; Calculates the coefficients for a standard Low-Pass Filter (LPF).
  ; Coeffs:   Pointer to the structure receiving the computed coefficients
  ; SampleRate: The sampling rate of the audio (e.g., 44100.0)
  ; CutoffHz:   The desired cutoff frequency in Hz
  ; Q:          Quality factor (0.7071 is standard Butterworth / flat response)
  Procedure IIR_SetupLowPass(*Coeffs.TBiquadCoeffs, SampleRate.d, CutoffHz.d, Q.d = 0.7071)
    Protected.d omega, sn, cs, alpha, a0
    
    ; Safety boundary to prevent division by zero or invalid frequencies
    If CutoffHz >= SampleRate / 2.0 : CutoffHz = (SampleRate / 2.0) - 1.0 : EndIf
    If CutoffHz <= 0.0 : CutoffHz = 1.0 : EndIf
    If Q <= 0.0 : Q = 0.7071 : EndIf
    
    omega = 2.0 * #PI * CutoffHz / SampleRate
    sn    = Sin(omega)
    cs    = Cos(omega)
    alpha = sn / (2.0 * Q)
    
    ; a0 is the normalization factor
    a0 = 1.0 / (1.0 + alpha)
    
    ; Calculate and normalize the coefficients directly
    *Coeffs\b0 = ((1.0 - cs) / 2.0) * a0
    *Coeffs\b1 = (1.0 - cs) * a0
    *Coeffs\b2 = ((1.0 - cs) / 2.0) * a0
    *Coeffs\a1 = (-2.0 * cs) * a0
    *Coeffs\a2 = (1.0 - alpha) * a0
  EndProcedure
  
  ; Calculates the coefficients for a standard High-Pass Filter (HPF).
  Procedure IIR_SetupHighPass(*Coeffs.TBiquadCoeffs, SampleRate.d, CutoffHz.d, Q.d = 0.7071)
    Protected.d omega, sn, cs, alpha, a0
    
    If CutoffHz >= SampleRate / 2.0 : CutoffHz = (SampleRate / 2.0) - 1.0 : EndIf
    If CutoffHz <= 0.0 : CutoffHz = 1.0 : EndIf
    If Q <= 0.0 : Q = 0.7071 : EndIf
    
    omega = 2.0 * #PI * CutoffHz / SampleRate
    sn    = Sin(omega)
    cs    = Cos(omega)
    alpha = sn / (2.0 * Q)
    
    a0 = 1.0 / (1.0 + alpha)
    
    *Coeffs\b0 = ((1.0 + cs) / 2.0) * a0
    *Coeffs\b1 = -(1.0 + cs) * a0
    *Coeffs\b2 = ((1.0 + cs) / 2.0) * a0
    *Coeffs\a1 = (-2.0 * cs) * a0
    *Coeffs\a2 = (1.0 - alpha) * a0
  EndProcedure
    
  ; Calculates the coefficients for a standard Band-Pass Filter (BPF).
  ; This variant uses constant 0 dB peak gain.
  ; Coeffs:     Pointer to the structure receiving the computed coefficients
  ; SampleRate: The sampling rate of the audio (e.g., 44100.0)
  ; CenterHz:   The center frequency of the band in Hz
  ; Q:          Quality factor (Higher values result in a narrower band)
  Procedure IIR_SetupBandPass(*Coeffs.TBiquadCoeffs, SampleRate.d, CenterHz.d, Q.d = 1.0)
    Protected.d omega, sn, cs, alpha, a0
    
    ; Safety boundaries
    If CenterHz >= SampleRate / 2.0 : CenterHz = (SampleRate / 2.0) - 1.0 : EndIf
    If CenterHz <= 0.0 : CenterHz = 1.0 : EndIf
    If Q <= 0.0 : Q = 1.0 : EndIf
    
    omega = 2.0 * #PI * CenterHz / SampleRate
    sn    = Sin(omega)
    cs    = Cos(omega)
    alpha = sn / (2.0 * Q)
    
    ; Inverted normalization factor
    a0 = 1.0 / (1.0 + alpha)
    
    *Coeffs\b0 = alpha * a0
    *Coeffs\b1 = 0.0
    *Coeffs\b2 = -alpha * a0
    *Coeffs\a1 = (-2.0 * cs) * a0
    *Coeffs\a2 = (1.0 - alpha) * a0
  EndProcedure
  
  ; Calculates the coefficients for a standard Notch (Band-Reject) Filter.
  ; Used to eliminate specific unwanted frequencies (e.g., 50 Hz hum).
  ; Coeffs:     Pointer to the structure receiving the computed coefficients
  ; SampleRate: The sampling rate of the audio (e.g., 44100.0)
  ; NotchHz:    The specific frequency to be completely cut out
  ; Q:          Quality factor (Higher values result in a narrower, sharper cut)
  Procedure IIR_SetupNotch(*Coeffs.TBiquadCoeffs, SampleRate.d, NotchHz.d, Q.d = 10.0)
    Protected.d omega, sn, cs, alpha, a0
    
    ; Safety boundaries
    If NotchHz >= SampleRate / 2.0 : NotchHz = (SampleRate / 2.0) - 1.0 : EndIf
    If NotchHz <= 0.0 : NotchHz = 1.0 : EndIf
    If Q <= 0.0 : Q = 10.0 : EndIf
    
    omega = 2.0 * #PI * NotchHz / SampleRate
    sn    = Sin(omega)
    cs    = Cos(omega)
    alpha = sn / (2.0 * Q)
    
    ; Inverted normalization factor
    a0 = 1.0 / (1.0 + alpha)
    
    *Coeffs\b0 = 1.0 * a0
    *Coeffs\b1 = (-2.0 * cs) * a0
    *Coeffs\b2 = 1.0 * a0
    *Coeffs\a1 = (-2.0 * cs) * a0
    *Coeffs\a2 = (1.0 - alpha) * a0
  EndProcedure
  
  ; Calculates the coefficients for a Low-Shelf Filter (Bass control).
  ; Coeffs:     Pointer to the structure receiving the computed coefficients
  ; SampleRate: The sampling rate of the audio (e.g., 44100.0)
  ; CutoffHz:   The shelf turnover frequency in Hz
  ; GainDB:     The amount of boost or cut in decibels (e.g., +6.0 for bass boost, -6.0 for cut)
  ; Q:          Quality factor (Controls the slope steepness at the transition, 0.7071 is standard)
  Procedure IIR_SetupLowShelf(*Coeffs.TBiquadCoeffs, SampleRate.d, CutoffHz.d, GainDB.d, Q.d = 0.7071)
    Protected.d omega, sn, cs, alpha, a0, A, beta
    
    ; Safety boundaries
    If CutoffHz >= SampleRate / 2.0 : CutoffHz = (SampleRate / 2.0) - 1.0 : EndIf
    If CutoffHz <= 0.0 : CutoffHz = 1.0 : EndIf
    If Q <= 0.0 : Q = 0.7071 : EndIf
    
    omega = 2.0 * #PI * CutoffHz / SampleRate
    sn    = Sin(omega)
    cs    = Cos(omega)
    
    ; A represents the linear amplitude ratio derived from GainDB
    A     = Pow(10.0, GainDB / 40.0)
    beta  = Sqr(A) / Q
    alpha = sn / 2.0 * beta
    
    ; Inverted normalization factor
    a0 = 1.0 / ((A + 1.0) + (A - 1.0) * cs + 2.0 * Sqr(A) * alpha)
    
    *Coeffs\b0 = (A * ((A + 1.0) - (A - 1.0) * cs + 2.0 * Sqr(A) * alpha)) * a0
    *Coeffs\b1 = (2.0 * A * ((A - 1.0) - (A + 1.0) * cs)) * a0
    *Coeffs\b2 = (A * ((A + 1.0) - (A - 1.0) * cs - 2.0 * Sqr(A) * alpha)) * a0
    *Coeffs\a1 = (-2.0 * ((A - 1.0) + (A + 1.0) * cs)) * a0
    *Coeffs\a2 = ((A + 1.0) + (A - 1.0) * cs - 2.0 * Sqr(A) * alpha) * a0
  EndProcedure
  
  ; Calculates the coefficients for a High-Shelf Filter (Treble control).
  Procedure IIR_SetupHighShelf(*Coeffs.TBiquadCoeffs, SampleRate.d, CutoffHz.d, GainDB.d, Q.d = 0.7071)
    Protected.d omega, sn, cs, alpha, a0, A, beta
    
    ; Safety boundaries
    If CutoffHz >= SampleRate / 2.0 : CutoffHz = (SampleRate / 2.0) - 1.0 : EndIf
    If CutoffHz <= 0.0 : CutoffHz = 1.0 : EndIf
    If Q <= 0.0 : Q = 0.7071 : EndIf
    
    omega = 2.0 * #PI * CutoffHz / SampleRate
    sn    = Sin(omega)
    cs    = Cos(omega)
    
    A     = Pow(10.0, GainDB / 40.0)
    beta  = Sqr(A) / Q
    alpha = sn / 2.0 * beta
    
    ; Inverted normalization factor
    a0 = 1.0 / ((A + 1.0) - (A - 1.0) * cs + 2.0 * Sqr(A) * alpha)
    
    *Coeffs\b0 = (A * ((A + 1.0) + (A - 1.0) * cs + 2.0 * Sqr(A) * alpha)) * a0
    *Coeffs\b1 = (-2.0 * A * ((A - 1.0) + (A + 1.0) * cs)) * a0
    *Coeffs\b2 = (A * ((A + 1.0) + (A - 1.0) * cs - 2.0 * Sqr(A) * alpha)) * a0
    *Coeffs\a1 = (2.0 * ((A - 1.0) - (A + 1.0) * cs)) * a0
    *Coeffs\a2 = ((A + 1.0) - (A - 1.0) * cs - 2.0 * Sqr(A) * alpha) * a0
  EndProcedure
  
  ; Calculates the coefficients for a Parametric Peaking Equalizer Filter.
  ; Coeffs:     Pointer to the structure receiving the computed coefficients
  ; SampleRate: The sampling rate of the audio (e.g., 44100.0)
  ; CenterHz:   The center frequency of the EQ band in Hz
  ; GainDB:     The amount of boost or cut in decibels (e.g., +3.5 dB or -6.0 dB)
  ; Q:          Quality factor (Higher values mean a narrower, sharper EQ bell curve)
  Procedure IIR_SetupPeakingEQ(*Coeffs.TBiquadCoeffs, SampleRate.d, CenterHz.d, GainDB.d, Q.d = 1.0)
    Protected.d omega, sn, cs, alpha, a0, A
    
    ; Safety boundaries
    If CenterHz >= SampleRate / 2.0 : CenterHz = (SampleRate / 2.0) - 1.0 : EndIf
    If CenterHz <= 0.0 : CenterHz = 1.0 : EndIf
    If Q <= 0.0 : Q = 1.0 : EndIf
    
    omega = 2.0 * #PI * CenterHz / SampleRate
    sn    = Sin(omega)
    cs    = Cos(omega)
    alpha = sn / (2.0 * Q)
    
    ; A represents the linear amplitude ratio derived from GainDB
    A     = Pow(10.0, GainDB / 40.0)
    
    ; Inverted normalization factor (divided by alpha/A for matching boost/cut symmetry)
    a0 = 1.0 / (1.0 + alpha / A)
    
    *Coeffs\b0 = (1.0 + alpha * A) * a0
    *Coeffs\b1 = (-2.0 * cs) * a0
    *Coeffs\b2 = (1.0 - alpha * A) * a0
    *Coeffs\a1 = (-2.0 * cs) * a0
    *Coeffs\a2 = (1.0 - alpha / A) * a0
  EndProcedure
  ; Example 3-Band-EQ:
  ; IIR_ProcessBlock(Signal(), Length, @CoeffsBand1, @StateBand1)
  ; IIR_ProcessBlock(Signal(), Length, @CoeffsBand2, @StateBand2)
  ; IIR_ProcessBlock(Signal(), Length, @CoeffsBand3, @StateBand3)
  
  
  ; Processes a block of samples (In-Place) using the Biquad filter.
  ; Signal(): The array of input/output samples (Mono)
  ; Length:   Number of samples to process
  ; *Coeffs:  Pointer to the pre-calculated coefficients
  ; *State:   Pointer to the persistent filter state (must be cleared for a new stream)
  Procedure IIR_ProcessBlock(Array Signal.d(1), Length.i, *Coeffs.TBiquadCoeffs, *State.TBiquadState)
    Protected.i I
    Protected.d in, out
    
    ; Local caching of coefficients for speed (keeps them in CPU registers)
    Protected.d b0 = *Coeffs\b0
    Protected.d b1 = *Coeffs\b1
    Protected.d b2 = *Coeffs\b2
    Protected.d a1 = *Coeffs\a1
    Protected.d a2 = *Coeffs\a2
    
    ; Local caching of the historical states
    Protected.d x1 = *State\x1
    Protected.d x2 = *State\x2
    Protected.d y1 = *State\y1
    Protected.d y2 = *State\y2
    
    For I = 0 To Length - 1
      in = Signal(I)
      
      ; Standard Direct Form I Biquad difference equation
      out = (b0 * in) + (b1 * x1) + (b2 * x2) - (a1 * y1) - (a2 * y2)
      
      ; Shift history
      x2 = x1
      x1 = in
      y2 = y1
      y1 = out
      
      ; Write output back to array
      Signal(I) = out
    Next
    
    ; Write local history cache back to the persistent state structure
    *State\x1 = x1
    *State\x2 = x2
    *State\y1 = y1
    *State\y2 = y2
  EndProcedure
  
  ; Ein Allpass-Filter ist ein faszinierendes mathematisches Werkzeug in der DSP. 
  ; Seine Besonderheit: Wenn man ein weißes Rauschen durchschickst, bleibt die Lautstärke über 
  ; den gesamten Frequenzbereich exakt gleich (daher der Name „All-Pass“). 
  ; Allerdings verschiebt der Filter die Phase der Frequenzen abhängig von der Frequenz.
  ; 
  ; Wozu?
  ; 
  ; 1. Phaser-Effekt: Wenn man Allpass-gefilterte Signal mit dem Originalsignal mischst,
  ; entstehen durch die Phasenverschiebungen Auslöschungen (Kammfilter). 
  ; Moduliert man nun die Allpässe, wandern diese Auslöschungen – der klassische „Phaser“-Sound entsteht.
  ; 
  ; 2. Künstlicher Hall (Schroeder-Reverb): 
  ; Ein einfaches Echo (Delay) klingt metallisch und flach. Schaltet man jedoch Allpass-Filter in Reihe,
  ; brechen diese die harten Echos auf und erzeugen eine extrem dichte, natürliche Echodichte,
  ; die für die Simulation von Raumhall unerlässlich ist.
  ; In der Praxis (besonders im Hall-Design) nutzt man meistens den Schroeder-Allpass im Zeitbereich.
  ; Dieser kombiniert eine kurze Verzögerungsleitung (Delay-Line) mit einer internen Vorwärts- und Rückwärtskopplung.
  

  ; Initializes the internal ring buffer for the Allpass filter
  Procedure Allpass_InitState(*State.TAllpassState, DelaySamples.i)
    If DelaySamples < 1 : DelaySamples = 1 : EndIf
    
    *State\BufferSize = DelaySamples
    Dim *State\Buffer(DelaySamples - 1)
    *State\WriteIdx = 0
  EndProcedure
  
  ; Processes a block of samples (In-Place) through a Schroeder Allpass Filter.
  ; Signal(): The array of input/output samples (Mono)
  ; Length:   Number of samples to process
  ; *Cfg:     Pointer to the configuration structure
  ; *State:   Pointer to the persistent ring buffer state
  Procedure Allpass_ProcessBlock(Array Signal.d(1), Length.i, *Cfg.TAllpassConfig, *State.TAllpassState)
    Protected.i I, bufSize, writeIdx
    Protected.d in, out, bufOut, g
    
    ; Fetch configuration
    g = *Cfg\Gain
    Protected.i delaySamples = *Cfg\DelaySamples
    If delaySamples <= 0 : ProcedureReturn : EndIf
    
    ; Auto-init buffer if not allocated yet
    bufSize = *State\BufferSize
    If bufSize = 0
      Allpass_InitState(*State, delaySamples)
      bufSize = *State\BufferSize
    EndIf
    
    writeIdx = *State\WriteIdx
    
    ; Highly optimized core loop utilizing cached local registers
    For I = 0 To Length - 1
      in = Signal(I)
      
      ; 1. Read delayed sample from the circular buffer
      bufOut = *State\Buffer(writeIdx)
      
      ; 2. Standard Schroeder Allpass difference equation:
      ; out = -g * in + bufOut
      out = (-g * in) + bufOut
      
      ; 3. Feed forward/backward back into the ring buffer:
      ; bufIn = in + g * bufOut
      *State\Buffer(writeIdx) = in + (g * bufOut)
      
      ; Write output back to the active signal block
      Signal(I) = out
      
      ; Advance circular write index
      writeIdx + 1
      If writeIdx >= bufSize : writeIdx = 0 : EndIf
    Next
    
    ; Save back the persistent state pointer
    *State\WriteIdx = writeIdx
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Dynamic processors
  ;- ----------------------------------------------------------------------
  
  ; Pre-calculates detector coefficients to avoid complex math in the audio loop
  ; AttackCoef / ReleaseCoef convert MS time into an exponential smoothing factor per sample
  Procedure Dynamics_CalcCoefs(SampleRate.d, AttackMs.d, ReleaseMs.d, *AttCoef.Double, *RelCoef.Double)
    If AttackMs <= 0.0  : AttackMs = 0.1  : EndIf
    If ReleaseMs <= 0.0 : ReleaseMs = 1.0 : EndIf
    
    ; Exponential time constants
    *AttCoef\d = Exp(-1.0 / (SampleRate * (AttackMs / 1000.0)))
    *RelCoef\d = Exp(-1.0 / (SampleRate * (ReleaseMs / 1000.0)))
  EndProcedure
  
  ; Processes a block of samples (In-Place) with compression or expansion.
  ; Signal():   The array of input/output samples (Mono)
  ; Length:     Number of samples to process
  ; SampleRate: The sampling rate of the audio (e.g., 44100.0)
  ; *Cfg:       Pointer to the configuration structure
  ; *State:     Pointer to the persistent sidechain state
  Procedure Dynamics_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TDynamicsConfig, *State.TDynamicsState)
    Protected.i I
    Protected.d in, abs_in, env, envDB, gainDB, gainLin
    Protected.d attCoef, relCoef
    
    ; Local caching of coefficients for speed
    Protected.d thresh = *Cfg\ThresholdDB
    Protected.d ratio  = *Cfg\Ratio
    Protected.d knee   = *Cfg\KneeDB
    Protected.i isExp  = *Cfg\IsExpander
    
    ; Get smoothed time constants
    Dynamics_CalcCoefs(SampleRate, *Cfg\AttackMs, *Cfg\ReleaseMs, @attCoef, @relCoef)
    
    ; Local caching of persistent envelope detector state
    Protected.d currentEnv = *State\Envelope
    
    ; Constants for DB conversion
    Protected.d log10_factor = 20.0 / Log(10.0)
    Protected.d inv_log10    = 1.0 / log10_factor
    Protected.d min_threshold = 1e-7
    
    For I = 0 To Length - 1
      in = Signal(I)
      abs_in = Abs(in)
      
      ; 1. Sidechain Envelope Detector (Ballistics)
      ; Peak detector with decoupled attack and release
      If abs_in > currentEnv
        currentEnv = attCoef * currentEnv + (1.0 - attCoef) * abs_in
      Else
        currentEnv = relCoef * currentEnv + (1.0 - relCoef) * abs_in
      EndIf
      
      ; Prevent Log(0)
      env = currentEnv
      If env < min_threshold : env = min_threshold : EndIf
      
      ; Convert envelope detector to decibels
      envDB = Log(env) * log10_factor
      
      ; 2. Gain Computer (Static Transfer Function)
      gainDB = 0.0
      
      If isExp = #False
        ; --- COMPRESSOR MODE ---
        If knee > 0.0 And envDB > (thresh - knee / 2.0) And envDB < (thresh + knee / 2.0)
          ; Soft Knee Compression region
          Protected.d knee_term = (envDB - thresh + knee / 2.0)
          gainDB = (1.0 / ratio - 1.0) * (knee_term * knee_term) / (2.0 * knee)
        ElseIf envDB > thresh
          ; Standard Hard Knee Compression
          gainDB = (envDB - thresh) * (1.0 / ratio - 1.0)
        EndIf
      Else
        ; --- EXPANDER MODE ---
        If knee > 0.0 And envDB > (thresh - knee / 2.0) And envDB < (thresh + knee / 2.0)
          ; Soft Knee Expansion region
          Protected.d knee_term_exp = (envDB - thresh - knee / 2.0)
          gainDB = (1.0 / ratio - 1.0) * (knee_term_exp * knee_term_exp) / (2.0 * knee)
        ElseIf envDB < thresh
          ; Standard Hard Knee Expansion (Attenuate signals below threshold)
          ; Note: ratio > 1.0 expansion slope (e.g. 1:2 means ratio = 2.0)
          gainDB = (envDB - thresh) * (ratio - 1.0)
        EndIf
      EndIf
      
      ; 3. Apply Gain Reduction
      ; Convert gain from dB back to linear factor
      gainLin = Exp(gainDB * inv_log10)
      
      ; Apply to the signal
      Signal(I) = in * gainLin
    Next
    
    ; Save back the persistent state
    *State\Envelope = currentEnv
  EndProcedure
    
  ; Initializes or resizes the look-ahead buffer based on the configured time
  Procedure Limiter_InitState(*State.TLimiterState, SampleRate.d, LookAheadMs.d)
    If LookAheadMs <= 0.0 : LookAheadMs = 2.0 : EndIf ; Default 2ms look-ahead
    
    ; Calculate required buffer size in samples
    *State\BufferSize = Int(SampleRate * (LookAheadMs / 1000.0))
    If *State\BufferSize < 1 : *State\BufferSize = 1 : EndIf
    
    ; Allocate ring buffer and reset pointers
    Dim *State\Buffer(*State\BufferSize - 1)
    *State\WriteIdx = 0
    *State\GainEnv  = 1.0 ; Target gain starts at 1.0 (no reduction)
  EndProcedure
  
  ; Processes a block of samples (In-Place) with Look-Ahead Limiting
  Procedure Limiter_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TLimiterConfig, *State.TLimiterState)
    Protected.i I, readIdx
    Protected.d in, delayedIn, abs_in, targetGain, ReleaseCoef
    
    ; Local caching of config values
    Protected.d ceilingLin = Pow(10.0, *Cfg\CeilingDB / 20.0)
    Protected.d driveLin   = Pow(10.0, -*Cfg\ThresholdDB / 20.0) ; Input gain drive
    
    ; Calculate exponential release coefficient
    Protected.d relMs = *Cfg\ReleaseMs
    If relMs <= 0.0 : relMs = 50.0 : EndIf
    ReleaseCoef = Exp(-1.0 / (SampleRate * (relMs / 1000.0)))
    
    ; Local caching of state and buffer metrics
    Protected.i bufSize  = *State\BufferSize
    Protected.i writeIdx = *State\WriteIdx
    Protected.d gainEnv  = *State\GainEnv
    
    ; If buffer wasn't initialized, do it now on the fly
    If bufSize = 0
      Limiter_InitState(*State, SampleRate, *Cfg\LookAheadMs)
      bufSize  = *State\BufferSize
      writeIdx = *State\WriteIdx
      gainEnv  = *State\GainEnv
    EndIf
    
    For I = 0 To Length - 1
      ; 1. Apply input drive (Threshold parameter drives the signal into the limiter)
      in = Signal(I) * driveLin
      
      ; 2. Push current signal into Look-Ahead Ring Buffer
      *State\Buffer(writeIdx) = in
      
      ; 3. Calculate Read Pointer (Delayed signal)
      readIdx = writeIdx + 1
      If readIdx >= bufSize : readIdx = 0 : EndIf
      delayedIn = *State\Buffer(readIdx)
      
      ; 4. Peak Detector on the NON-DELAYED input (Looking ahead!)
      abs_in = Abs(in)
      
      ; Determine ideal target gain to keep the signal below ceiling
      If abs_in > ceilingLin
        targetGain = ceilingLin / abs_in
      Else
        targetGain = 1.0
      EndIf
      
      ; 5. Gain Ballistics (Instant Attack, Exponential Release)
      ; Attack is immediate because we are looking ahead.
      If targetGain < gainEnv
        gainEnv = targetGain ; Instant attack to catch the peak
      Else
        ; Smooth recovery via release coefficient
        gainEnv = ReleaseCoef * gainEnv + (1.0 - ReleaseCoef) * targetGain
      EndIf
      
      ; 6. Apply the calculated Gain Envelope to the DELAYED signal
      Signal(I) = delayedIn * gainEnv
      
      ; Move write pointer forward
      writeIdx + 1
      If writeIdx >= bufSize : writeIdx = 0 : EndIf
    Next
    
    ; Save local register states back to persistent structures
    *State\WriteIdx = writeIdx
    *State\GainEnv  = gainEnv
  EndProcedure
    
  ; Processes a block of samples (In-Place) acting as a Noise Gate
  Procedure Gate_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TGateConfig, *State.TGateState)
    Protected.i I
    Protected.d in, abs_in, env, envDB, targetGain
    Protected.d attCoef, relCoef
    Protected.i holdSamplesMax
    
    ; Local caching of config values
    Protected.d threshDB = *Cfg\ThresholdDB
    Protected.d floorLin = Pow(10.0, *Cfg\FloorDB / 20.0) ; Convert floor attenuation to linear factor
    
    ; Calculate exponential time constants
    Protected.d attMs = *Cfg\AttackMs : If attMs <= 0.0 : attMs = 1.0 : EndIf
    Protected.d relMs = *Cfg\ReleaseMs : If relMs <= 0.0 : relMs = 50.0 : EndIf
    attCoef = Exp(-1.0 / (SampleRate * (attMs / 1000.0)))
    relCoef = Exp(-1.0 / (SampleRate * (relMs / 1000.0)))
    
    ; Calculate max hold samples
    holdSamplesMax = Int(SampleRate * (*Cfg\HoldMs / 1000.0))
    
    ; Local caching of persistent states
    Protected.d currentEnv  = *State\Envelope
    Protected.d currentGain = *State\GainEnv
    Protected.i holdCounter = *State\HoldSamples
    
    ; Constants for DB conversion
    Protected.d log10_factor  = 20.0 / Log(10.0)
    Protected.d min_threshold = 1e-7
    
    For I = 0 To Length - 1
      in = Signal(I)
      abs_in = Abs(in)
      
      ; 1. Signal Envelope Detector (Slight smoothing to avoid rapid chattering)
      If abs_in > currentEnv
        currentEnv = 0.1 * currentEnv + 0.9 * abs_in ; Ultra-fast tracking for gate input
      Else
        currentEnv = 0.95 * currentEnv + 0.05 * abs_in
      EndIf
      
      ; Prevent Log(0)
      env = currentEnv
      If env < min_threshold : env = min_threshold : EndIf
      envDB = Log(env) * log10_factor
      
      ; 2. Gate Logic & Hold Timer
      If envDB >= threshDB
        targetGain  = 1.0            ; Gate should be wide open
        holdCounter = holdSamplesMax ; Reset/Refresh the hold timer
      Else
        ; Signal is below threshold
        If holdCounter > 0
          targetGain = 1.0           ; Keep gate open during hold phase
          holdCounter - 1            ; Countdown
        Else
          targetGain = floorLin      ; Hold finished, target is the quiet floor
        EndIf
      EndIf
      
      ; 3. Gain Ballistics (Smoothing out the open/close actions)
      If targetGain > currentGain
        ; Opening the gate (Attack phase)
        currentGain = attCoef * currentGain + (1.0 - attCoef) * targetGain
      Else
        ; Closing the gate (Release phase)
        currentGain = relCoef * currentGain + (1.0 - relCoef) * targetGain
      EndIf
      
      ; 4. Apply Gain Envelope to the audio sample
      Signal(I) = in * currentGain
    Next
    
    ; Save back the persistent state
    *State\Envelope    = currentEnv
    *State\GainEnv     = currentGain
    *State\HoldSamples = holdCounter
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Delay and Modulation
  ;- ----------------------------------------------------------------------
    
  ; Initializes or resizes the delay buffer to support the maximum required delay time.
  ; MaxDelayMs: The maximum delay time this buffer should ever hold (e.g., 2000.0 ms)
  Procedure Delay_InitState(*State.TDelayState, SampleRate.d, MaxDelayMs.d = 2000.0)
    If MaxDelayMs <= 0.0 : MaxDelayMs = 2000.0 : EndIf
    
    ; Calculate buffer size based on sample rate and max time
    *State\BufferSize = Int(SampleRate * (MaxDelayMs / 1000.0)) + 2 ; +2 safety margin for interpolation
    If *State\BufferSize < 4 : *State\BufferSize = 4 : EndIf
    
    ; Allocate array and reset write pointer
    Dim *State\Buffer(*State\BufferSize - 1)
    *State\WriteIdx = 0
  EndProcedure
  
  ; Processes a block of samples (In-Place) creating a configurable Delay/Echo effect.
  Procedure Delay_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TDelayConfig, *State.TDelayState)
    Protected.i I, idxA, idxB
    Protected.d in, out, delayedSample, frac
    Protected.d readIdxF
    
    ; Local caching of config values
    Protected.d fb  = *Cfg\Feedback
    Protected.d mix = *Cfg\Mix
    
    ; Calculate exact delay length in fractional samples
    Protected.d delaySamples = SampleRate * (*Cfg\DelayMs / 1000.0)
    
    ; Local caching of state variables
    Protected.i bufSize  = *State\BufferSize
    Protected.i writeIdx = *State\WriteIdx
    
    ; Auto-init if state is unallocated
    If bufSize = 0
      Delay_InitState(*State, SampleRate, *Cfg\DelayMs)
      bufSize  = *State\BufferSize
      writeIdx = *State\WriteIdx
    EndIf
    
    ; Prevent invalid configurations from causing crashes
    If delaySamples < 0.0 : delaySamples = 0.0 : EndIf
    If delaySamples > bufSize - 2 : delaySamples = bufSize - 2 : EndIf
    
    For I = 0 To Length - 1
      in = Signal(I)
      
      ; 1. Calculate continuous floating-point read index for sub-sample delay
      readIdxF = writeIdx - delaySamples
      If readIdxF < 0.0
        readIdxF + bufSize
      EndIf
      
      ; 2. Linear Interpolation between the two adjacent sample points
      idxA = Int(readIdxF)
      idxB = idxA + 1
      If idxB >= bufSize : idxB = 0 : EndIf
      
      frac = readIdxF - idxA
      
      ; Fetch and blend the samples: out = sampleA * (1 - frac) + sampleB * frac
      delayedSample = *State\Buffer(idxA) + frac * (*State\Buffer(idxB) - *State\Buffer(idxA))
      
      ; 3. Write back into the ring buffer (Input signal + Feedback loop)
      *State\Buffer(writeIdx) = in + (delayedSample * fb)
      
      ; 4. Standard Wet/Dry Mix linear crossfade
      out = (in * (1.0 - mix)) + (delayedSample * mix)
      Signal(I) = out
      
      ; Move write pointer forward
      writeIdx + 1
      If writeIdx >= bufSize : writeIdx = 0 : EndIf
    Next 
    
    ; Save back the persistent state pointer
    *State\WriteIdx = writeIdx
  EndProcedure
  
  ; ----------------------------------------------------------------------
  
  ; Initializes the modulation ring buffer based on max expected delay + depth
  Procedure Mod_InitState(*State.TModulationState, SampleRate.d)
    ; Allocate enough space for max settings (e.g., 50ms is plenty for Chorus/Flanger)
    *State\BufferSize = Int(SampleRate * 0.050) + 4
    Dim *State\Buffer(*State\BufferSize - 1)
    *State\WriteIdx = 0
    *State\LfoPhase = 0.0
  EndProcedure
  
  ; Processes a block of samples (In-Place) executing either a Chorus or Flanger effect
  Procedure Mod_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TModulationConfig, *State.TModulationState)
    Protected.i I, idxA, idxB
    Protected.d in, out, delayedSample, frac, readIdxF
    Protected.d currentDelaySamples, modSamples, baseSamples
    
    ; Local caching of state and configuration
    Protected.i bufSize  = *State\BufferSize
    Protected.i writeIdx = *State\WriteIdx
    Protected.d lfoPhase = *State\LfoPhase
    
    Protected.d fb   = *Cfg\Feedback
    Protected.d mix  = *Cfg\Mix
    Protected.d rate = *Cfg\RateHz
    
    ; Auto-init if buffer is empty
    If bufSize = 0
      Mod_InitState(*State, SampleRate)
      bufSize  = *State\BufferSize
      writeIdx = *State\WriteIdx
      lfoPhase = *State\LfoPhase
    EndIf
    
    ; Pre-calculate LFO phase increment per sample step to avoid division inside the loop
    Protected.d lfoPhaseInc = (2.0 * #PI * rate) / SampleRate
    Protected.d twoPi       = 2.0 * #PI
    
    ; Convert milliseconds configuration to sample counts before entering the loop
    baseSamples = SampleRate * (*Cfg\BaseDelayMs / 1000.0)
    modSamples  = SampleRate * (*Cfg\DepthMs / 1000.0)
    
    For I = 0 To Length - 1
      in = Signal(I)
      
      ; 1. Calculate the dynamically changing delay time using the Sinus LFO
      ; The LFO oscillates between -1.0 and +1.0, shifting the delay position
      currentDelaySamples = baseSamples + Sin(lfoPhase) * modSamples
      
      ; Safety clipping against buffer boundaries
      If currentDelaySamples < 0.0 : currentDelaySamples = 0.0 : EndIf
      If currentDelaySamples > bufSize - 2 : currentDelaySamples = bufSize - 2 : EndIf
      
      ; 2. Calculate fractional read pointer
      readIdxF = writeIdx - currentDelaySamples
      If readIdxF < 0.0
        readIdxF + bufSize
      EndIf
      
      ; 3. Perform Sub-Sample Linear Interpolation (crucial to prevent click artifacts during modulation)
      idxA = Int(readIdxF)
      idxB = idxA + 1
      If idxB >= bufSize : idxB = 0 : EndIf
      frac = readIdxF - idxA
      
      delayedSample = *State\Buffer(idxA) + frac * (*State\Buffer(idxB) - *State\Buffer(idxA))
      
      ; 4. Write input + filtered feedback back to the circular buffer
      *State\Buffer(writeIdx) = in + (delayedSample * fb)
      
      ; 5. Crossfade between dry input and wet modulated output
      out = (in * (1.0 - mix)) + (delayedSample * mix)
      Signal(I) = out
      
      ; 6. Advance LFO phase and keep it bounded within 0.0 to 2*PI
      lfoPhase + lfoPhaseInc
      If lfoPhase >= twoPi
        lfoPhase - twoPi
      EndIf
      
      ; Advance ring buffer write index
      writeIdx + 1
      If writeIdx >= bufSize : writeIdx = 0 : EndIf
    Next
    
    ; Store cached register values back into persistent memory
    *State\WriteIdx = writeIdx
    *State\LfoPhase = lfoPhase
  EndProcedure
  
  ; ----------------------------------------------------------------------

  ; Initializes the pitch shifter ring buffer based on the configured window size
  Procedure Pitch_InitState(*State.TPitchShifterState, SampleRate.d, WindowSizeMs.d = 50.0)
    If WindowSizeMs <= 0.0 : WindowSizeMs = 50.0 : EndIf
    
    ; Allocate enough space for the delay window plus safety margin
    *State\BufferSize = Int(SampleRate * (WindowSizeMs / 1000.0)) * 2 + 10
    Dim *State\Buffer(*State\BufferSize - 1)
    *State\WriteIdx = 0
    *State\Phase0   = 0.0
  EndProcedure
  
  ; Processes a block of samples (In-Place) shifting the pitch in the time domain
  Procedure Pitch_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TPitchShifterConfig, *State.TPitchShifterState)
    Protected.i I, idx0A, idx0B, idx1A, idx1B
    Protected.i bufSize, writeIdx
    Protected.d in, out, phase0, phase1, phaseInc
    Protected.d windowSizeSamples, delay0, delay1
    Protected.d readIdx0F, readIdx1F, frac0, frac1
    Protected.d sample0, sample1, w0, w1
    
    ; Local caching of config values
    Protected.d pitch = *Cfg\PitchFactor
    If pitch <= 0.0 : pitch = 1.0 : EndIf
    
    ; Auto-init if buffer is empty
    bufSize = *State\BufferSize
    If bufSize = 0
      Pitch_InitState(*State, SampleRate, *Cfg\WindowSizeMs)
      bufSize = *State\BufferSize
    EndIf
    
    writeIdx = *State\WriteIdx
    phase0   = *State\Phase0
    
    ; Calculate the size of the modulation window in samples
    windowSizeSamples = SampleRate * (*Cfg\WindowSizeMs / 1000.0)
    If windowSizeSamples < 10.0 : windowSizeSamples = 10.0 : EndIf
    
    ; Phase increment matches the relative speed difference: (1.0 - pitch)
    ; Divided by windowSizeSamples so that the phase covers 0.0 to 1.0 in exactly one window length
    phaseInc = (1.0 - pitch) / windowSizeSamples
    
    For I = 0 To Length - 1
      in = Signal(I)
      
      ; Write current sample to circular buffer
      *State\Buffer(writeIdx) = in
      
      ; Pointer 1 runs exactly 180 degrees (0.5 phase) out of phase to Pointer 0
      phase1 = phase0 + 0.5
      If phase1 >= 1.0 : phase1 - 1.0 : EndIf
      If phase1 < 0.0  : phase1 + 1.0 : EndIf
      
      ; 1. Calculate dynamic delay times for both reading pointers
      delay0 = phase0 * windowSizeSamples
      delay1 = phase1 * windowSizeSamples
      
      ; 2. Calculate fractional read pointers for Sub-Sample Interpolation
      readIdx0F = writeIdx - delay0
      If readIdx0F < 0.0 : readIdx0F + bufSize : EndIf
      
      readIdx1F = writeIdx - delay1
      If readIdx1F < 0.0 : readIdx1F + bufSize : EndIf
      
      ; 3. Interpolation for Pointer 0
      idx0A = Int(readIdx0F)
      idx0B = idx0A + 1
      If idx0B >= bufSize : idx0B = 0 : EndIf
      frac0 = readIdx0F - idx0A
      sample0 = *State\Buffer(idx0A) + frac0 * (*State\Buffer(idx0B) - *State\Buffer(idx0A))
      
      ; 4. Interpolation for Pointer 1
      idx1A = Int(readIdx1F)
      idx1B = idx1A + 1
      If idx1B >= bufSize : idx1B = 0 : EndIf
      frac1 = readIdx1F - idx1A
      sample1 = *State\Buffer(idx1A) + frac1 * (*State\Buffer(idx1B) - *State\Buffer(idx1A))
      
      ; 5. Crossfading Window generation (Triangle Window)
      ; Ensures that when a pointer hits the boundary (where clipping occurs), its volume is 0
      w0 = 1.0 - Abs((phase0 - 0.5) / 0.5)
      w1 = 1.0 - Abs((phase1 - 0.5) / 0.5)
      
      ; 6. Sum up the weighted crossfaded samples
      out = (sample0 * w0) + (sample1 * w1)
      Signal(I) = out
      
      ; 7. Update phase and wrap around boundaries
      phase0 + phaseInc
      If phase0 >= 1.0
        phase0 - 1.0
      ElseIf phase0 < 0.0
        phase0 + 1.0
      EndIf
      
      ; Advance ring buffer pointer
      writeIdx + 1
      If writeIdx >= bufSize : writeIdx = 0 : EndIf
    Next
    
    ; Save cached states back to persistent structures
    *State\WriteIdx = writeIdx
    *State\Phase0   = phase0
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Signal Correction & Metering
  ;- ----------------------------------------------------------------------
  
  ; Processes a block of samples (In-Place) to remove any DC offset.
  ; Signal():   The array of input/output samples (Mono)
  ; Length:     Number of samples to process
  ; SampleRate: The sampling rate of the audio (e.g., 44100.0)
  ; *Cfg:       Pointer to the configuration structure
  ; *State:     Pointer to the persistent filter state
  Procedure DCOffset_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, *Cfg.TDCOffsetConfig, *State.TDCOffsetState)
    Protected.i I
    Protected.d in, out
    
    ; Calculate the pole/filter coefficient alpha based on the cutoff frequency
    ; Standard formula for a 1-pole high-pass filter: alpha = 1 / (1 + 2*PI * f / SR)
    ; For 1.0 Hz at 44.1 kHz, alpha will be extremely close to 1.0 (approx. 0.99985)
    Protected.d cutoff = *Cfg\CutoffHz
    If cutoff <= 0.0 : cutoff = 1.0 : EndIf
    
    Protected.d alpha = 1.0 / (1.0 + (2.0 * #PI * cutoff / SampleRate))
    
    ; Local caching of historical states for maximum CPU register speed
    Protected.d x1 = *State\x1
    Protected.d y1 = *State\y1
    
    For I = 0 To Length - 1
      in = Signal(I)
      
      ; 1-pole High-Pass Filter difference equation:
      ; y(n) = alpha * (y(n-1) + x(n) - x(n-1))
      out = alpha * (y1 + in - x1)
      
      ; Update history
      x1 = in
      y1 = out
      
      ; Write cleaned sample back to array
      Signal(I) = out
    Next 
    
    ; Save back the persistent state
    *State\x1 = x1
    *State\y1 = y1
  EndProcedure
  
  ; Performs an In-Place Phase Inversion (Polarity Flip) on the audio signal.
  ; Signal(): The array of audio samples (Mono)
  ; Length:   Number of samples to process
  Procedure Phase_Invert(Array Signal.d(1), Length.i)
    Protected.i I
    
    ; Simply multiply every sample by -1.0 to flip the polarity
    For I = 0 To Length - 1
      Signal(I) * -1.0
    Next
  EndProcedure
    
  ; Calculates the RMS and Peak levels of an audio block.
  ; Signal(): The array of audio samples (Mono)
  ; Length:   Number of samples to process
  ; *Result:  Pointer to the structure receiving the calculated levels
  Procedure Measure_Levels(Array Signal.d(1), Length.i, *Result.TLevelMeterResult)
    Protected.i I
    Protected.d sample, abs_sample
    Protected.d max_peak = 0.0
    Protected.d sum_squares = 0.0
    
    ; Safety check for empty blocks
    If Length <= 0
      *Result\PeakDB  = -140.0 : *Result\RmsDB  = -140.0
      *Result\PeakLin = 0.0    : *Result\RmsLin = 0.0
      ProcedureReturn
    EndIf
    
    ; Constants for fast DB conversion
    Protected.d log10_factor  = 20.0 / Log(10.0)
    Protected.d min_threshold = 1e-7 ; Represents -140 dBFS baseline
    
    ; Core measurement loop
    For I = 0 To Length - 1
      sample = Signal(I)
      abs_sample = Abs(sample)
      
      ; 1. Track absolute peak
      If abs_sample > max_peak
        max_peak = abs_sample
      EndIf
      
      ; 2. Accumulate squared values for RMS calculation
      sum_squares + (sample * sample)
    Next
    
    ; Compute linear values
    *Result\PeakLin = max_peak
    *Result\RmsLin  = Sqr(sum_squares / Length)
    
    ; Convert linear values to Decibel scale (dBFS)
    ; Peak dB
    If *Result\PeakLin < min_threshold
      *Result\PeakDB = -140.0
    Else
      *Result\PeakDB = Log(*Result\PeakLin) * log10_factor
    EndIf
    
    ; RMS dB
    If *Result\RmsLin < min_threshold
      *Result\RmsDB = -140.0
    Else
      *Result\RmsDB = Log(*Result\RmsLin) * log10_factor
    EndIf
  EndProcedure
  
  ; Performs In-Place TPDF (Triangular Probability Density Function) Dithering 
  ; and quantizes the floating-point signal into a standard 16-bit Signed Integer array.
  ; FloatSignal(): The input high-resolution double/float array (Mono, scaled from -1.0 to +1.0)
  ; Length:        Number of samples to process
  ; Int16Output(): The target array receiving the dithered 16-bit integer values (-32768 to 32767)
  Procedure Dither_To16Bit(Array FloatSignal.d(1), Length.i, Array Int16Output.w(1))
    Protected.i I
    Protected.d in, r1, r2, ditherNoise, ditheredSample
    Protected.i quantized
    
    ; Resize output array to match the signal length
    Dim Int16Output(Length - 1)
    
    ; 16-bit quantization scaling factor (Peak amplitude for signed 16-bit is 32768.0)
    Protected.d scale16 = 32768.0
    Protected.d invScale16 = 1.0 / scale16
    
    ; The amplitude of one Least Significant Bit (LSB) in the float domain
    Protected.d lsb = 1.0 / scale16
    
    ; PureBasic's Random() generates values from 0.0 to 1.0. 
    ; We want our random generators to output centered values.
    
    For I = 0 To Length - 1
      in = FloatSignal(I)
      
      #_fRandom = 100000
      Protected.d invRandom = 1.0 / #_fRandom ; Division pre-calculated for speed
      
      ; 1. Generate integer between 0 and 100000
      ; 2. Multiply by invRandom to get 0.0 to 1.0
      ; 3. Subtract 0.5 to shift the range exactly to -0.5 to +0.5
      r1 = Random(#_fRandom) * invRandom - 0.5
      r2 = Random(#_fRandom) * invRandom - 0.5      
      
      ; Combining them creates the triangular distribution (TPDF) spanning exactly -1.0 to +1.0 LSB
      ditherNoise = (r1 + r2) * lsb
      
      ; Add the noise floor to the high-resolution sample
      ditheredSample = in + ditherNoise
      
      ; Scale up to 16-bit integer range
      ditheredSample * scale16
      
      ; Round to the nearest integer
      quantized = Round(ditheredSample, #PB_Round_Nearest)
      
      ; Hard clipping to prevent illegal overflows if the signal was hitting exactly 1.0 or -1.0
      If quantized > 32767
        quantized = 32767
      ElseIf quantized < -32768
        quantized = -32768
      EndIf
      
      ; Write into the 16-bit Word array (.w)
      Int16Output(I) = quantized
    Next
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- FIR - Finite Impulse Response Filter
  ;- ----------------------------------------------------------------------
  
  ;- Convolution for linear filtering
    
  ; Initializes the history buffer for the FIR filter based on the number of taps
  Procedure FIR_InitState(*State.TFirState, NumTaps.i)
    If NumTaps <= 0 : ProcedureReturn : EndIf
    
    *State\BufferSize = NumTaps
    Dim *State\History(NumTaps - 1)
    *State\WriteIdx = 0
  EndProcedure
  
  ; Processes a block of samples (In-Place) using Time-Domain FIR Convolution.
  ; Signal(): The array of input/output samples (Mono)
  ; Length:   Number of samples in the active block
  ; *Cfg:     Pointer to the configuration structure containing the FIR taps
  ; *State:   Pointer to the persistent history ring buffer
  Procedure FIR_ProcessBlock(Array Signal.d(1), Length.i, *Cfg.TFirConfig, *State.TFirState)
    Protected.i I, J, readIdx
    Protected.d in, out
    
    ; Local caching of configuration metrics
    Protected.i numTaps = *Cfg\NumTaps
    If numTaps <= 0 : ProcedureReturn : EndIf
    
    ; Auto-init history state if not already done
    If *State\BufferSize = 0
      FIR_InitState(*State, numTaps)
    EndIf
    
    Protected.i bufSize  = *State\BufferSize
    Protected.i writeIdx = *State\WriteIdx
    
    ; Core block processing loop
    For I = 0 To Length - 1
      in = Signal(I)
      
      ; 1. Insert the newest sample into the history ring buffer
      *State\History(writeIdx) = in
      
      ; 2. Perform the Convolution (Dot product of history and FIR Taps)
      out = 0.0
      readIdx = writeIdx
      
      ; Loop through all filter coefficients
      For J = 0 To numTaps - 1
        ; Multiply tap with the corresponding past sample
        out + (*Cfg\Taps(J) * *State\History(readIdx))
        
        ; Move backward in history (circular wrap-around)
        readIdx - 1
        If readIdx < 0
          readIdx = bufSize - 1
        EndIf
      Next
      
      ; Write the filtered result back to the signal array
      Signal(I) = out
      
      ; Advance the write pointer forward for the next sample
      writeIdx + 1
      If writeIdx >= bufSize
        writeIdx = 0
      EndIf
    Next
    
    ; Save back the persistent write pointer position
    *State\WriteIdx = writeIdx
  EndProcedure
  
  ;- Reverb/Hall
    
  ; Pre-computes the FFT of a raw time-domain impulse response.
  ; RawIR():    Input array with the time-domain room impulse response (e.g. loaded from WAV)
  ; IrLen:      Number of samples in RawIR()
  ; *Cfg:       Pointer to the configuration structure to initialize
  ; BlockSize:  The processing block size you intend to use (e.g., 512, 1024, 2048)
  Procedure FastConv_PrepareIR(Array RawIR.d(1), IrLen.i, *Cfg.TFastConvConfig, BlockSize.i)
    Protected.i I
    
    ; FFTSize must be exactly 2 * BlockSize to allow clean linear convolution without time-aliasing
    *Cfg\FFTSize = BlockSize * 2
    Dim *Cfg\IrFFT(*Cfg\FFTSize - 1)
    
    ; Copy the IR into the complex array and zero-pad the rest
    For I = 0 To *Cfg\FFTSize - 1
      If I < IrLen
        *Cfg\IrFFT(I)\re = RawIR(I)
      Else
        *Cfg\IrFFT(I)\re = 0.0
      EndIf
      *Cfg\IrFFT(I)\im = 0.0
    Next
    
    ; Process the IR into the frequency domain once (No scaling needed here)
    ; Note: Since our FFT routine scales by 1/N, we bypass it or multiply back later.
    ; To match your FFT_Radix2 scaling, we run it and then scale it up by FFTSize 
    ; so the forward transformation behaves as an unscaled reference.
    FFT_Radix2(*Cfg\IrFFT(), *Cfg\FFTSize)
    
    Protected.d fftSizeD = *Cfg\FFTSize
    For I = 0 To *Cfg\FFTSize - 1
      *Cfg\IrFFT(I)\re * fftSizeD
      *Cfg\IrFFT(I)\im * fftSizeD
    Next
  EndProcedure
  
  ; Processes a block of samples (In-Place) using Fast Frequency-Domain Convolution.
  ; Signal():   The active audio block (Size MUST match BlockSize used in PrepareIR)
  ; Length:     Number of samples in the block (Must be exactly BlockSize)
  ; *Cfg:       Pointer to the pre-prepared IR configuration
  ; *State:     Pointer to the persistent overlap state buffer
  Procedure FastConv_ProcessBlock(Array Signal.d(1), Length.i, *Cfg.TFastConvConfig, *State.TFastConvState)
    Protected.i I, fftSize
    Protected.d c_re, c_im
    
    fftSize = *Cfg\FFTSize
    
    ; Auto-init overlap buffer if empty
    If *State\OverlapSize = 0
      *State\OverlapSize = Length
      Dim *State\OverlapBuffer(Length - 1)
    EndIf
    
    ; Allocate temporary complex workspace for the block
    Dim Work.Complex::TComplex(fftSize - 1)
    
    ; 1. Load active signal block and apply Zero-Padding to the second half
    For I = 0 To fftSize - 1
      If I < Length
        Work(I)\re = Signal(I)
      Else
        Work(I)\re = 0.0
      EndIf
      Work(I)\im = 0.0
    Next
    
    ; 2. Transform the active block into the frequency domain
    FFT_Radix2(Work(), fftSize)
    
    ; 3. Complex point-by-point multiplication (Inlined Complex::CMul for speed)
    ; Work(I) = Work(I) * IrFFT(I)
    For I = 0 To fftSize - 1
      c_re = Work(I)\re * *Cfg\IrFFT(I)\re - Work(I)\im * *Cfg\IrFFT(I)\im
      c_im = Work(I)\im * *Cfg\IrFFT(I)\re + Work(I)\re * *Cfg\IrFFT(I)\im
      Work(I)\re = c_re
      Work(I)\im = c_im
    Next
    
    ; 4. Transform back into the time domain
    IFFT_Radix2(Work(), fftSize)
    
    ; 5. Overlap-Add section
    For I = 0 To Length - 1
      ; Output = Current IFFT result + Overlap Tail from previous block
      Signal(I) = Work(I)\re + *State\OverlapBuffer(I)
      
      ; Store the new tail (second half of the IFFT result) into the persistent overlap buffer
      *State\OverlapBuffer(I) = Work(Length + I)\re
    Next
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Signal generator
  ;- ----------------------------------------------------------------------
  
  ; Generates a block of audio samples using a phase-locked oscillator.
  ; Signal():   The output array to fill with the generated waveform (Mono)
  ; Length:     Number of samples to generate
  ; SampleRate: The target sampling rate (e.g., 44100.0)
  ; Type:       The waveform type (#Oscillator_Sine, etc.)
  ; Frequency:  The target oscillator frequency in Hz
  ; PulseWidth: Only for #Oscillator_Rectangle (0.01 to 0.99, standard square is 0.5)
  ; *State:     Pointer to the persistent oscillator state tracker
  Procedure Osc_GenerateBlock(Array Signal.d(1), Length.i, SampleRate.d, Type.i, Frequency.d, PulseWidth.d, *State.TOscillatorState)
    Protected.i I
    Protected.d p
    
    If Length <= 0 Or SampleRate <= 0.0 : ProcedureReturn : EndIf
    
    ; Resize array to match output length
    Dim Signal(Length - 1)
    
    ; Calculate phase increment per sample step to avoid division inside loops
    Protected.d phaseInc = Frequency / SampleRate
    
    ; Local caching of the persistent phase for speed
    Protected.d currentPhase = *State\Phase
    
    ; Limit pulse width for safety inside the rectangle loop
    If PulseWidth <= 0.01 : PulseWidth = 0.01 : EndIf
    If PulseWidth >= 0.99 : PulseWidth = 0.99 : EndIf
    
    Select Type
        
      Case #Oscillator_Sine
        ; Standard Sine Wave via 2*PI mapping
        Protected.d twoPi = 2.0 * #PI
        For I = 0 To Length - 1
          Signal(I) = Sin(currentPhase * twoPi)
          
          currentPhase + phaseInc
          If currentPhase >= 1.0 : currentPhase - 1.0 : EndIf
        Next
        
      Case #Oscillator_Triangle
        ; Bipolar Triangle Wave scaling from -1.0 to +1.0
        For I = 0 To Length - 1
          p = currentPhase
          If p < 0.5
            Signal(I) = 4.0 * p - 1.0
          Else
            Signal(I) = 3.0 - 4.0 * p
          EndIf
          
          currentPhase + phaseInc
          If currentPhase >= 1.0 : currentPhase - 1.0 : EndIf
        Next
        
      Case #Oscillator_Sawtooth
        ; Standard ramp-up Sawtooth Wave from -1.0 to +1.0
        For I = 0 To Length - 1
          Signal(I) = 2.0 * currentPhase - 1.0
          
          currentPhase + phaseInc
          If currentPhase >= 1.0 : currentPhase - 1.0 : EndIf
        Next
        
      Case #Oscillator_Rectangle
        ; Variable Pulse Width (PWM) Square/Rectangle Wave
        For I = 0 To Length - 1
          If currentPhase < PulseWidth
            Signal(I) = 1.0
          Else
            Signal(I) = -1.0
          EndIf
          
          currentPhase + phaseInc
          If currentPhase >= 1.0 : currentPhase - 1.0 : EndIf
        Next
        
    EndSelect
    
    ; Save local register phase back to persistent structure
    *State\Phase = currentPhase
  EndProcedure
  
  ; Initializes the Pink Noise generator state with fresh random seed data
  Procedure Noise_InitState(*State.TNoiseState)
    Protected.i I
    Protected.d invRandom = 1.0 / 100000.0
    
    *State\RunningSum = 0.0
    *State\Index = 0
    
    ; Pre-fill the rows with initial random data to prevent a ramp-up artifact
    For I = 0 To 15
      *State\Rows[I] = (Random(100000) * invRandom) - 0.5
      *State\RunningSum + *State\Rows[I]
    Next
  EndProcedure
  
  ; Generates a block of audio samples containing either White or Pink Noise.
  ; Signal():   The output array to fill with noise (Mono)
  ; Length:     Number of samples to generate
  ; Type:       The noise type (#Noise_White or #Noise_Pink)
  ; *State:     Pointer to the persistent noise state tracker
  Procedure Noise_GenerateBlock(Array Signal.d(1), Length.i, Type.i, *State.TNoiseState)
    Protected.i I, J, r, blank
    Protected.d r1, r2
    
    If Length <= 0 : ProcedureReturn : EndIf
    
    ; Resize array to match output length
    Dim Signal(Length - 1)
    
    ; Pre-calculated inversion factor for our high-speed random floating workaround
    Protected.d invRandom = 1.0 / 100000.0
    
    Select Type
        
      Case #Noise_White
        ; White Noise: Completely independent random samples between -1.0 and +1.0
        For I = 0 To Length - 1
          ; Using your optimized random approach: scale to 0..2, then subtract 1.0
          Signal(I) = (Random(200000) * invRandom) - 1.0
        Next
        
      Case #Noise_Pink
        ; Pink Noise: Voss-McCartney algorithm
        ; Auto-init if the system hasn't been set up yet
        If *State\RunningSum = 0.0 And *State\Index = 0
          Noise_InitState(*State)
        EndIf
        
        ; Local caching of state variables for performance
        Protected.d runningSum = *State\RunningSum
        Protected.i index      = *State\Index
        
        For I = 0 To Length - 1
          index + 1
          ; Find the number of trailing zeros in the index using bitwise operations
          ; This determines which row in the tree gets updated this sample.
          blank = index
          r = 0
          While (blank & 1) = 0
            blank >> 1
            r + 1
          Wend
          
          ; Keep the row index bounded to our maximum row count (16 rows)
          r = r & 15
          
          ; Replace the old row value with a new random value
          runningSum - *State\Rows[r]
          *State\Rows[r] = (Random(100000) * invRandom) - 0.5
          runningSum + *State\Rows[r]
          
          ; Add an additional raw white noise sample to smooth out the steps (Voss refinement)
          Protected.d extraWhite = (Random(100000) * invRandom) - 0.5
          
          ; The sum of 16 rows + 1 extra sample yields a stable Pink Noise distribution.
          ; Scale down by approximately 1/8.5 to keep the amplitude neatly within -1.0 and +1.0
          Signal(I) = (runningSum + extraWhite) * 0.115
        Next
        
        ; Save persistent variables back to memory
        *State\RunningSum = runningSum
        *State\Index      = index
        
    EndSelect
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Resampling, Stereo Split & Merge
  ;- ----------------------------------------------------------------------
   
  ; Performs Resampling (Sample Rate Conversion) from an input buffer to an output buffer.
  ; InputSignal():  The source audio array (Mono)
  ; InputLength:    Number of samples in the input array
  ; SourceRate:     The original sample rate (e.g., 44100.0)
  ; TargetRate:     The desired sample rate (e.g., 48000.0)
  ; Method:         The interpolation method (#Resample_Linear or #Resample_Sinc)
  ; OutputSignal(): The target array that will automatically be resized to hold the result
  ; Returns:        The total number of samples generated in OutputSignal()
  Procedure.i Resample_Block(Array InputSignal.d(1), InputLength.i, SourceRate.d, TargetRate.d, Method.i, Array OutputSignal.d(1))
    Protected.i I, J, outLength, srcIdxInt
    Protected.d srcIdx, frac, outSample, sincArg, sincVal, window, weightSum, weight
    
    If InputLength <= 0 Or SourceRate <= 0.0 Or TargetRate <= 0.0 : ProcedureReturn 0 : EndIf
    
    ; Calculate the resampling ratio and the resulting output length
    Protected.d ratio = SourceRate / TargetRate
    outLength = Int(InputLength / ratio)
    If outLength <= 0 : ProcedureReturn 0 : EndIf
    
    ; Automatically resize the output buffer
    Dim OutputSignal(outLength - 1)
    
    Select Method
        
      Case #Resample_Linear
        ; High-speed Linear Interpolation
        For I = 0 To outLength - 1
          ; Map output index back to fractional source index
          srcIdx = I * ratio
          srcIdxInt = Int(srcIdx)
          frac = srcIdx - srcIdxInt
          
          ; Edge case handling at the end of the buffer
          If srcIdxInt >= InputLength - 1
            OutputSignal(I) = InputSignal(InputLength - 1)
          Else
            ; Fast linear blend: A + frac * (B - A)
            OutputSignal(I) = InputSignal(srcIdxInt) + frac * (InputSignal(srcIdxInt + 1) - InputSignal(srcIdxInt))
          EndIf
        Next
        
      Case #Resample_Sinc
        ; Professional Windowed Sinc Interpolation (Lanczos-style kernel)
        ; KernelSize defines the quality/width of the sinc filter. 
        ; 8 to 16 is a great balance between pristine audio quality and CPU speed.
        Protected.i kernelSize = 12 
        Protected.d piTerm = #PI
        
        For I = 0 To outLength - 1
          srcIdx = I * ratio
          srcIdxInt = Int(srcIdx)
          frac = srcIdx - srcIdxInt
          
          outSample = 0.0
          weightSum = 0.0
          
          ; Convolve the local neighborhood with the windowed sinc kernel
          For J = -kernelSize To kernelSize
            Protected.I tapIdx = srcIdxInt + J
            
            ; Keep indices strictly bounded within source data
            If tapIdx >= 0 And tapIdx < InputLength
              ; Calculate distance to the ideal continuous sample point
              Protected.d x = J - frac
              
              If x = 0.0
                sincVal = 1.0
                window  = 1.0
              Else
                ; Normalized Sinc: Sin(PI * x) / (PI * x)
                sincArg = piTerm * x
                sincVal = Sin(sincArg) / sincArg
                
                ; Hanning Window to smoothly taper the sinc kernel edges off to zero
                window = 0.5 * (1.0 + Cos(piTerm * x / kernelSize))
              EndIf
              
              weight = sincVal * window
              outSample + (InputSignal(tapIdx) * weight)
              weightSum + weight
            EndIf
          Next
          
          ; Normalize amplitude against the total filter weight sum to prevent volume shifts
          If weightSum <> 0.0
            OutputSignal(I) = outSample / weightSum
          Else
            OutputSignal(I) = 0.0
          EndIf
        Next
        
    EndSelect
    
    ProcedureReturn outLength
  EndProcedure
  
  ; Splits an interleaved stereo buffer (L/R/L/R) into two separate mono buffers (Left and Right).
  ; InterleavedInput(): Source array containing interleaved stereo samples
  ; TotalStereoSamples: Total number of float elements in the interleaved array (2 * Frames)
  ; LeftOutput():       Target mono array for the Left channel (automatically resized)
  ; RightOutput():      Target mono array for the Right channel (automatically resized)
  ; Returns:            The number of audio frames per channel
  Procedure.i Stereo_Split(Array InterleavedInput.d(1), TotalStereoSamples.i, Array LeftOutput.d(1), Array RightOutput.d(1))
    Protected.i I, frames, srcIdx
    
    If TotalStereoSamples <= 1 : ProcedureReturn 0 : EndIf
    
    ; Number of audio frames is exactly half of the total interleaved elements
    frames = TotalStereoSamples / 2
    
    ; Automatically resize the mono target buffers
    Dim LeftOutput(frames - 1)
    Dim RightOutput(frames - 1)
    
    ; High-speed demultiplexing loop
    For I = 0 To frames - 1
      srcIdx = I * 2
      LeftOutput(I)  = InterleavedInput(srcIdx)
      RightOutput(I) = InterleavedInput(srcIdx + 1)
    Next
    
    ProcedureReturn frames
  EndProcedure
  
  ; Merges two separate mono buffers (Left and Right) back into a single interleaved stereo buffer (L/R/L/R).
  ; LeftInput():         Source mono array for the Left channel
  ; RightInput():        Source mono array for the Right channel
  ; MonoLength:          Number of samples inside each mono array (Frames)
  ; InterleavedOutput(): Target array that will automatically be resized to hold the interleaved stereo data
  ; Returns:             The total number of stereo elements generated (2 * MonoLength)
  Procedure.i Stereo_Merge(Array LeftInput.d(1), Array RightInput.d(1), MonoLength.i, Array InterleavedOutput.d(1))
    Protected.i I, destIdx, totalElements
    
    If MonoLength <= 0 : ProcedureReturn 0 : EndIf
    
    totalElements = MonoLength * 2
    
    ; Automatically resize the interleaved target buffer
    Dim InterleavedOutput(totalElements - 1)
    
    ; High-speed multiplexing loop
    For I = 0 To MonoLength - 1
      destIdx = I * 2
      InterleavedOutput(destIdx)     = LeftInput(I)
      InterleavedOutput(destIdx + 1) = RightInput(I)
    Next
    
    ProcedureReturn totalElements
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Extented Analysis
  ;- ----------------------------------------------------------------------
  
  ; Der Crest-Faktor ist eine mathematische Kennzahl, die das Verhältnis zwischen dem Spitzenwert (Peak) 
  ;  und dem Effektivwert (RMS) eines Audiosignals beschreibt. Er zeigt dir präzise an, wie „dynamisch“ 
  ; oder wie stark „komprimiert“ ein Signal ist. Ein hoher Crest-Faktor steht für hohe Dynamik 
  ; (z. B. klassische Musik oder Live-Drums), während ein niedriger Crest-Faktor auf ein stark limitiertes
  ; oder komprimiertes Signal hindeutet (typisch für den modernen „Loudness War“).
  
  ; Calculates the Crest Factor of an audio block to evaluate its dynamic density.
  ; Signal(): The array of audio samples (Mono)
  ; Length:   Number of samples to process
  ; AsDecibels: If #True, returns the Crest Factor in dB. If #False, returns the linear ratio.
  ; Returns:   The Crest Factor (Linear ratio >= 1.0, or Decibel value >= 0.0 dB)
  Procedure.d Measure_CrestFactor(Array Signal.d(1), Length.i, AsDecibels.i = #True)
    Protected.i I
    Protected.d sample, abs_sample
    Protected.d max_peak = 0.0
    Protected.d sum_squares = 0.0
    Protected.d rms_lin, crest_lin
    
    ; Safety check for empty or invalid blocks
    If Length <= 0 : ProcedureReturn 0.0 : EndIf
    
    ; Core loop to fetch peak and energy accumulator in a single pass
    For I = 0 To Length - 1
      sample = Signal(I)
      abs_sample = Abs(sample)
      
      If abs_sample > max_peak
        max_peak = abs_sample
      EndIf
      
      sum_squares + (sample * sample)
    Next
    
    ; Compute linear RMS
    rms_lin = Sqr(sum_squares / Length)
    
    ; Avoid division by zero if the block contains absolute silence
    If rms_lin <= 0.0
      ProcedureReturn 0.0
    EndIf
    
    ; Linear Crest Factor is Peak divided by RMS
    crest_lin = max_peak / rms_lin
    
    If AsDecibels
      ; Convert the linear ratio to Decibels: 20 * Log10(Crest_Linear)
      Protected.d log10_factor = 20.0 / Log(10.0)
      
      ; Safety boundary for log calculation
      If crest_lin < 1.0 : crest_lin = 1.0 : EndIf
      
      ProcedureReturn Log(crest_lin) * log10_factor
    Else
      ProcedureReturn crest_lin
    EndIf
  EndProcedure
  
  ; Die Autokorrelation (YIN- oder klassische ACF-Methode) ist das bewährteste mathematische Werkzeug im Zeitbereich,
  ; um die Grundfrequenz (Pitch / Tonhöhe in Hz) eines monophonen Signals (wie Gesang, Gitarre oder Flöte) in Echtzeit zu bestimmen.
  ; Das Prinzip ist einfach: Das Audiosignal wird schrittweise im Speicher gegen sich selbst verschoben (Lag).
  ; Wenn die Verschiebung exakt der Periodendauer der Grundwelle entspricht, decken sich die Wellenformen perfekt,
  ; und das mathematische Ergebnis (das Skalarprodukt) schlägt maximal aus. Der Kehrwert dieser Periodendauer liefert die Frequenz in Hz.
  ; Um typische Fehler wie die "Oktavverwechslung" (Octave Doubling) zu vermeiden, sucht ein robuster Echtzeit-Algorithmus 
  ; nach dem ersten signifikanten lokalen Maximum nach dem Nullpunkt, das eine bestimmte Schwelle überschreitet.
  
  ; Detects the fundamental pitch (fundamental frequency in Hz) of a monophonic signal.
  ; Signal():      The array containing the audio frame (Mono, should be at least 1024 or 2048 samples)
  ; Length:        Number of samples inside the active block
  ; SampleRate:    The sampling rate of the audio (e.g., 44100.0)
  ; MinFreqHz:     Lower frequency boundary to detect (e.g., 50.0 Hz for bass notes)
  ; MaxFreqHz:     Upper frequency boundary to detect (e.g., 1000.0 Hz)
  ; Threshold:     Confidence threshold for peak validation (typically 0.70 to 0.90)
  ; Returns:       The detected fundamental frequency in Hz, or 0.0 if unpitched/silent
  Procedure.d Detect_Pitch_ACF(Array Signal.d(1), Length.i, SampleRate.d, MinFreqHz.d = 60.0, MaxFreqHz.d = 800.0, Threshold.d = 0.80)
    Protected.i I, lag, minLag, maxLag, bestLag
    Protected.d sumSquares = 0.0, rms, r_zero, r_lag, maxR
    
    ; 1. Safety check & Voice activity check (Ignore absolute silence)
    If Length <= 0 Or SampleRate <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    For I = 0 To Length - 1
      sumSquares + (Signal(I) * Signal(I))
    Next
    rms = Sqr(sumSquares / Length)
    If rms < 0.005 : ProcedureReturn 0.0 : EndIf ; Signal too quiet to track pitch reliably
    
    ; 2. Convert frequency boundaries to sample lag offsets
    ; Lower frequency limits mean larger lags (e.g., 44100 / 50 Hz = 882 samples lag)
    maxLag = Int(SampleRate / MinFreqHz)
    minLag = Int(SampleRate / MaxFreqHz)
    
    ; Safely bound lags against the provided block size
    If maxLag >= Length : maxLag = Length - 1 : EndIf
    If minLag < 1 : minLag = 1 : EndIf
    
    ; Allocate temporary buffer for the Autocorrelation Function (ACF) results
    Dim R.d(maxLag)
    
    ; 3. Calculate Autocorrelation for Lag 0 (The reference baseline energy)
    r_zero = 0.0
    For I = 0 To Length - maxLag - 1
      r_zero + (Signal(I) * Signal(I))
    Next
    If r_zero <= 0.0 : ProcedureReturn 0.0 : EndIf
    
    ; 4. Compute ACF coefficients across the searchable lag region
    bestLag = 0
    maxR = -1.0
    
    For lag = minLag To maxLag
      r_lag = 0.0
      ; Dot product shift loop
      For I = 0 To Length - maxLag - 1
        r_lag + (Signal(I) * Signal(I + lag))
      Next
      
      ; Normalize the correlation coefficient against the base energy
      R(lag) = r_lag / r_zero
    Next lag
    
    ; 5. Peak picking with peak-tracking logic
    ; Search for the first local maximum that crosses the threshold criteria
    For lag = minLag + 1 To maxLag - 1
      If R(lag) > Threshold
        ; Check if it's a true local peak (higher than its neighbors)
        If R(lag) > R(lag - 1) And R(lag) > R(lag + 1)
          If R(lag) > maxR
            maxR = R(lag)
            bestLag = lag
            ; Found a strong localized candidate, break out early to avoid octave sub-harmonics
            Break
          EndIf
        EndIf
      EndIf
    Next lag
    
    ; If no peak passed the threshold, fall back to the absolute global maximum in the zone
    If bestLag = 0
      maxR = -1.0
      For lag = minLag + 1 To maxLag - 1
        If R(lag) > R(lag - 1) And R(lag) > R(lag + 1)
          If R(lag) > maxR
            maxR = R(lag)
            bestLag = lag
          EndIf
        EndIf
      Next lag
    EndIf
    
    ; 6. Convert the winning sample period interval into Frequency (Hz)
    If bestLag > 0 And maxR > 0.35 ; Final check for weak unpitched noise
      ProcedureReturn SampleRate / bestLag
    Else
      ProcedureReturn 0.0 ; Signal is unpitched (e.g. sibilants like 's' or drum noise)
    EndIf
  EndProcedure
    
EndModule

;- ----------------------------------------------------------------------
;- Test Code
;  ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; (Falls du die FFT-Prozedur in ein Modul namens 'DSP' gepackt hast)
  UseModule DSP
  
  Procedure show(r.i, txt.s, Array buf.Complex::TComplex(1))
    Protected I
    Debug txt
    For I = 0 To ArraySize(buf())
      ; Ausgabe von Real- und Imaginärteil
      Debug "[" + Str(I) + "] " + StrD(buf(I)\re, 4) + " | " + StrD(buf(I)\im, 4)
    Next
    Debug "---------------------------------------"
  EndProcedure
  
  Procedure testFFT()
    Protected.i r, I, N
    
    ; Array-Größe festlegen (8 Elemente, Indizes 0 bis 7)
    N = 8
    Dim buf.Complex::TComplex(N - 1)
  
    ; Test-Eingangssignal definieren (ein einfaches Rechtecksignal)
    buf(0)\re = 1.0 
    buf(1)\re = 1.0 
    buf(2)\re = 1.0
    buf(3)\re = 1.0
    ; Indizes 4 bis 7 bleiben automatisch auf 0.0 (Gleichanteil/Pause)
  
    r = 0
    show(r, "--- INPUT (Zeitbereich: re, im) ---", buf())
    
    ; Da es "In-Place" rechnet, arbeiten wir direkt auf 'buf'
    Debug "N = " + N
    Debug "arraysize = " + ArraySize(buf())
    FFT_Radix2(buf(), N)
    
    r + 1
    show(r, "--- OUTPUT (Frequenzbereich mit Normierung 1/N) ---", buf())
  EndProcedure
  
  testFFT()
CompilerEndIf




; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 39
; Folding = ---------
; Optimizer
; CPU = 5