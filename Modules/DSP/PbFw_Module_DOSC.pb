; ===========================================================================
;  FILE: PbFw_Module_DOSC.pb
;  NAME: Module Digital Oscillator 
;  DESC: 
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; COAUTHOR :  Google Gemini (free version with Browser frontend)
; DATE     :  2026/10/19
; VERSION  :  0.5 untested Developer Version
; COMPILER :  PureBasic 6.0 and higher
; OS       :  All
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 

; 2026/10/19 S.Maag : Moved the Oscillator functions from Module DSP to seperate
;                     Module DOSC       

;}
;{ TODO: a lot!
;}
; ===========================================================================


; digital Oscialltor Modul. Moved from DSP Modul to seperate Module
DeclareModule DOSC
  EnableExplicit

  Enumeration eOscillatorType
    #DOSC_Wave_Sine     
    #DOSC_Wave_Triangle 
    #DOSC_Wave_SawTooth 
    #DOSC_Wave_Rectangle
  EndEnumeration
  
  Enumeration eNoiseTyoe
    #DOSC_Noise_White 
    #DOSC_Noise_Pink
  EndEnumeration
  
  Structure TOscillatorState
    Phase.d ; Persistent phase accumulator (0.0 to 1.0)
  EndStructure

  Declare Osc_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, Type.i, Frequency.d, PulseWidth.d, *State.TOscillatorState)
  
  ; ----------------------------------------------------------------------
 
  Structure TOscillatorSweepState
    Phase.d           ; Deine bestehende Phase (0.0 bis 1.0)
    CurrentSample.d   ; Aktueller Fortschritt im Sweep (in Samples)
    DurationSamples.d ; Gesamtdauer des Sweeps (in Samples)
    StartFreq.d       ; Startfrequenz in Hz
    EndFreq.d         ; Endfrequenz in Hz
    IsLogarithmic.i   ; #True = musikalisch logarithmisch, #False = linear
  EndStructure
  
  Declare.i Osc_InitSweep(*State.TOscillatorSweepState, startFreq.d, endFreq.d, durationSecs.d, SampleRate.d, xLog_Linear)

    ; Generates a block of audio samples with a continuous frequency sweep.
  ; Type:       #DOSC_Wave_Sine, etc.
  ; *State:     Pointer to the persistent TOscillatorSweepState tracker
  Declare OscSweep_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, Type.i, PulseWidth.d, *State.TOscillatorSweepState)
  
  ; ----------------------------------------------------------------------
   
  Structure TNoiseState
    Rows.d[16]    ; Persistent rows for the Voss-McCartney Pink Noise generator
    RunningSum.d  ; Running sum of the rows for Pink Noise
    Index.i       ; Sequence index to determine which row to update
  EndStructure

  Declare Noise_InitState(*State.TNoiseState)
  Declare Noise_ProcessBlock(Array Signal.d(1), Length.i, Type.i, *State.TNoiseState)
 
EndDeclareModule

Module DOSC
  
  EnableExplicit
  
  ; Generates a block of audio samples using a phase-locked oscillator.
  ; Signal():   The output array to fill with the generated waveform (Mono)
  ; Length:     Number of samples to generate
  ; SampleRate: The target sampling rate (e.g., 44100.0)
  ; Type:       The waveform type (#DOSC_Wave_Sine, etc.)
  ; Frequency:  The target oscillator frequency in Hz
  ; PulseWidth: Only for #DOSC_Wave_Rectangle (0.01 to 0.99, standard square is 0.5)
  ; *State:     Pointer to the persistent oscillator state tracker
  Procedure Osc_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, Type.i, Frequency.d, PulseWidth.d, *State.TOscillatorState)
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
        
      Case #DOSC_Wave_Sine
        ; Standard Sine Wave via 2*PI mapping
        Protected.d twoPi = 2.0 * #PI
        For I = 0 To Length - 1
          Signal(I) = Sin(currentPhase * twoPi)
          
          currentPhase + phaseInc
          If currentPhase >= 1.0 : currentPhase - 1.0 : EndIf
        Next
        
      Case #DOSC_Wave_Triangle
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
        
      Case #DOSC_Wave_SawTooth
        ; Standard ramp-up Sawtooth Wave from -1.0 to +1.0
        For I = 0 To Length - 1
          Signal(I) = 2.0 * currentPhase - 1.0
          
          currentPhase + phaseInc
          If currentPhase >= 1.0 : currentPhase - 1.0 : EndIf
        Next
        
      Case #DOSC_Wave_Rectangle
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
    
  ; Generates a block of audio samples with a continuous frequency sweep.
  ; Type:       #DOSC_Wave_Sine, etc.
  ; *State:     Pointer to the persistent TOscillatorSweepState tracker
  ; Konstanten-Definitionen (als Platzhalter für deinen Code)
    
  Procedure.i Osc_InitSweep(*State.TOscillatorSweepState, startFreq.d, endFreq.d, durationSecs.d, SampleRate.d, xLog_Linear)
    If *State
      With *State
        \StartFreq       = startFreq
        \EndFreq         = endFreq
        \DurationSamples = durationSecs * SampleRate
        \IsLogarithmic   = xLog_Linear  ; <- FEHLER BEHOBEN: Jetzt wird es zugewiesen!
        \CurrentSample   = 0.0          ; <- FEHLER BEHOBEN: Reset für neuen Sweep
        \Phase           = 0.0          ; <- FEHLER BEHOBEN: Phase initialisieren
      EndWith
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  ; Generates a block of audio samples with a continuous frequency sweep.
  Procedure OscSweep_ProcessBlock(Array Signal.d(1), Length.i, SampleRate.d, Type.i, PulseWidth.d, *State.TOscillatorSweepState)
    Protected.i I
    Protected.d p, curFreq, phaseInc
    
    If Length <= 0 Or SampleRate <= 0.0 Or *State = 0 : ProcedureReturn : EndIf
    
    ; Resize array to match output length
    Dim Signal(Length - 1)
    
    ; Local caching for maximum speed
    Protected.d currentPhase  = *State\Phase
    Protected.d currentSample = *State\CurrentSample
    Protected.d duration      = *State\DurationSamples
    Protected.d fStart        = *State\StartFreq
    Protected.d fEnd          = *State\EndFreq
    Protected.i isLog         = *State\IsLogarithmic
    Protected.d factor, logFactor
    
    ; Vorberechnen des Log-Faktors für Speed (Pow ist langsam in Schleifen!)
    If isLog And fStart > 0.0
      logFactor = fEnd / fStart
    EndIf
    
    ; Limit pulse width for safety inside the rectangle loop
    If PulseWidth <= 0.01 : PulseWidth = 0.01 : EndIf
    If PulseWidth >= 0.99 : PulseWidth = 0.99 : EndIf
    
    Protected.d twoPi = 2.0 * #PI
    
    ; Main Loop over all Samples
    For I = 0 To Length - 1
      
      ; 1. calculate dynamic frequency
      If currentSample >= duration
        curFreq = fEnd
      Else
        factor = currentSample / duration
        If isLog And fStart > 0.0
          curFreq = fStart * Pow(logFactor, factor)
        Else
          curFreq = fStart + (fEnd - fStart) * factor
        EndIf
        currentSample + 1.0
      EndIf
      
      ; Phase increment
      phaseInc = curFreq / SampleRate
      
      ; 2. Generate wave form  
      Select Type
          
        Case #DOSC_Wave_Sine                      ; Sinus
          Signal(I) = Sin(currentPhase * twoPi)
          
        Case #DOSC_Wave_Triangle                  ; Dreieck
          p = currentPhase
          If p < 0.5
            Signal(I) = 4.0 * p - 1.0
          Else
            Signal(I) = 3.0 - 4.0 * p
          EndIf
          
        Case #DOSC_Wave_SawTooth                  ; Sägezahn
          Signal(I) = 2.0 * currentPhase - 1.0
          
        Case #DOSC_Wave_Rectangle                 ; Rechteck
          If currentPhase < PulseWidth
            Signal(I) = 1.0
          Else
            Signal(I) = -1.0
          EndIf
          
      EndSelect
      
      ; 3. Phase-Update
      currentPhase + phaseInc
      If currentPhase >= 1.0 : currentPhase - 1.0 : EndIf
    Next I
    
    ; Save local registers back to persistent structure
    *State\Phase         = currentPhase
    *State\CurrentSample = currentSample
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
  Procedure Noise_ProcessBlock(Array Signal.d(1), Length.i, Type.i, *State.TNoiseState)
    Protected.i I, J, r, blank
    Protected.d r1, r2
    
    If Length <= 0 : ProcedureReturn : EndIf
    
    ; Resize array to match output length
    Dim Signal(Length - 1)
    
    ; Pre-calculated inversion factor for our high-speed random floating workaround
    Protected.d invRandom = 1.0 / 100000.0
    
    Select Type
        
      Case #DOSC_Noise_White
        ; White Noise: Completely independent random samples between -1.0 and +1.0
        For I = 0 To Length - 1
          ; Using your optimized random approach: scale to 0..2, then subtract 1.0
          Signal(I) = (Random(200000) * invRandom) - 1.0
        Next
        
      Case #DOSC_Noise_Pink
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
  
EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 95
; FirstLine = 132
; Folding = --
; DPIAware
; CPU = 5