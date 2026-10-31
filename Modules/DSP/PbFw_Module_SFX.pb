
; =====================================================================
; MODULE: SFX (Extended Retro Sound Effects)
; =====================================================================
; A unified Double-precision audio synthesis Engine for Retro Games.
; This module provides instantly usable 8-bit / 16-bit sound effects
; by orchestrating your custom core oscillator and sweep architectures.
; All internal functions process in high-precision Double arrays.
; =====================================================================

; =====================================================================
; DSP RETRO GAME SOUND GENERATION TEMPLATE
; =====================================================================
; This template demonstrates how to orchestrate your custom 
; oscillator and biquad filter routines to create iconic 8-bit / 16-bit 
; sound effects (Laser Swoosh, Coin Collect, and Low-Pass Noise Explosion).
; =====================================================================

; =================================================================================
; CONCEPTUAL GUIDE: RETRO GAME AUDIO SYNTHESIS & SIGNAL DESIGN
; =================================================================================
; This documentation explains how classic 8-bit and 16-bit arcade/console systems
; (such as the Nintendo NES, Game Boy, Sega Mega Drive, and Commodore 64) 
; synthesized audio waveforms in real-time, and how to replicate those textures 
; using your custom PureBasic Double-precision DSP library.
;
; Since vintage sound chips lacked the memory to stream digital audio files (MP3/WAV),
; sound designers manipulated raw oscillator parameters and primitive filters 
; dynamically to evoke specific physical events.
; =================================================================================
;
; 1. THE CLASSIC LASER SOUND (The "Laser Swoosh" / Sci-Fi Zap)
;    -----------------------------------------------------------------------------
;    * Phenomenon: A bright, biting projectile acoustic effect.
;    * DSP Formula: An ultra-fast downward linear frequency sweep applied to a 
;      highly harmonic wave shape.
;    * Execution: 
;      - Waveform: #Oscillator_Sawtooth or a narrow #Oscillator_Rectangle (Pulse). 
;        These shapes are rich in odd and even harmonics, cutting through a mix.
;      - Parameters: Set StartFreq high (~1500 Hz to 2000 Hz) and plunge instantly 
;        down to a low EndFreq (~60 Hz to 100 Hz).
;      - Timing: Keep the entire block duration extremely tight (~0.10 to 0.18 seconds).
;    * Retro Vibe: Instant "Space Invaders" or "Galaga" style weapon fire.
;
; 2. THE COIN & POWER-UP SOUNDS (The "Arpeggio / Note-Hopping" Trick)
;    -----------------------------------------------------------------------------
;    * Phenomenon: A rewarding, bright acoustic feedback signal indicating a score.
;    * DSP Formula: Instantaneous step-wise pitch progression using precise pulse-width 
;      waveforms without any pitch interpolation or crossfading.
;    * Execution:
;      - Waveform: #Oscillator_Rectangle. 
;        Crucial Trick: Shrink the PulseWidth parameter away from a standard 0.5 
;        square down to ~0.12 or 0.15. This alters the duty cycle, creating a 
;        thin, nasal, metallic "chime" characteristic of the Nintendo Game Boy.
;      - Logic: Render a brief block at a fundamental note (e.g., C5 for 0.05 seconds), 
;        then immediately switch the frequency to a perfect interval harmonic 
;        (e.g., E6 or G6 for 0.20 seconds) without wrapping or phase resetting.
;    * Retro Vibe: Ikonische "Super Mario" coin-collect chimes.
;
; 3. EXPLOSIONS, TREMORS & IMPACTS (Filtered Noise Sweeps)
;    -----------------------------------------------------------------------------
;    * Phenomenon: Low-end destruction, rumble, or tactile impact soundscapes.
;    * DSP Formula: White Noise (random uniform signal data amplitude) processed 
;      by a dynamically closing Biquad Low-Pass Filter.
;    * Execution:
;      - Waveform: A raw white noise buffer (un-interpolated randomized float data).
;      - Logic: Raw noise sounds like high-pitched static or television snow. To turn 
;        it into an explosion, pass it through your IIR Biquad Low-Pass Filter. 
;        Divide your rendering loop into micro-chunks (e.g., 256 samples). For each 
;        chunk, recalculate your filter coefficients, actively sweeping the cutoff 
;        frequency downward from ~1200 Hz (bright crackle) to ~30 Hz (sub-bass rumble).
;      - Amplitude: Concurrently apply a linear or exponential volume envelope decay 
;        over the block duration (~0.5 to 1.0 seconds) so the rumble realistically fades out.
;    * Retro Vibe: Heavy arcade-style explosions, mortar impacts, and seismic thuds.
;
; 4. THE CHIPTUNE ESTHETIC RULES
;    -----------------------------------------------------------------------------
;    * Hard Transitions: Avoid smooth polynomial curves or windowed crossfades when 
;      changing pitches or triggering notes. Vintage hardware changed register values 
;      instantly, creating charming, jagged micro-clicks and raw note transitions.
;    * Digital Clipping & Normalization: Keep your DSP Double-to-Float buffers within 
;      the predictable safe amplitude zones before passing them to LAME to prevent 
;      unwanted harsh non-linear digital clipping, preserving the crisp 8-bit clarity.
; =================================================================================

XIncludeFile "PbFw_Module_DSP.pb"           ; DSP::       Digital Signal Processing
XIncludeFile "PbFw_Module_DOSC.pb"          ; DOSC::      Digital Oscillator

DeclareModule SFX
  ; Standard effects from previous session
  Declare.i GenerateCoin(Array SoundBuffer.d(1), SampleRate.d)
  Declare.i GenerateLaser(Array SoundBuffer.d(1), SampleRate.d)
  Declare.i GenerateExplosion(Array SoundBuffer.d(1), SampleRate.d, *FilterCoeffs, *FilterState)
  
  ; NEW: Classic 8-bit platformer jump sound
  Declare.i GenerateJump(Array SoundBuffer.d(1), SampleRate.d)
  
  ; NEW: Low-pitch degradation sound when taking damage or losing a life
  Declare.i GenerateDamage(Array SoundBuffer.d(1), SampleRate.d)
  
  Declare.i GeneratePropeller(Array SoundBuffer.d(1), LengthSamples.i, SampleRate.d, EngineRPM.d)
  Declare.i GenerateFlyby(Array SoundBuffer.d(1), DurationSecs.d, SampleRate.d, BaseFreq.d, CarSpeedKmh.d, ClosestDistanceMeters.d)
  
    ; Generates a massive naval cannon blast (returns total samples)
  Declare.i GenerateNavalCannon(Array SoundBuffer.d(1), SampleRate.d, *FilterCoeffs, *FilterState)
  
  ; Generates a burst of machine gun fire based on shot count (returns total samples)
  Declare.i GenerateMachineGun(Array SoundBuffer.d(1), SampleRate.d, ShotCount.i)

EndDeclareModule

Module SFX
; --- 1. THE CLASSIC LASER SOUND (Laser Swoosh) ---
; Concept: A lightning-fast downward frequency sweep using a harsh waveform.
Procedure.i GenerateLaser(Array SoundBuffer.d(1), SampleRate.d)
  Protected SweepState.DOSC::TOscillatorSweepState
  Protected.d durationSecs = 0.15 ; Very short, punchy duration
  Protected.d startFreq    = 1600.0
  Protected.d endFreq      = 80.0
  Protected.i blockSize    = durationSecs * SampleRate
  
  ; Initialize the frequency sweep (Linear works best for that classic sci-fi zap)
  DOSC::Osc_InitSweep(@SweepState, startFreq, endFreq, durationSecs, SampleRate, #False)
  
  ; Process the block using a sharp Sawtooth or high-resonance Rectangle wave
  DOSC::OscSweep_ProcessBlock(SoundBuffer(), blockSize, SampleRate, DOSC::#DOSC_Wave_SawTooth, 0.5, @SweepState)
  
  ; Optional: Apply a tiny volume decay loop at the end of the buffer to prevent clicking
  ProcedureReturn blockSize
EndProcedure


; --- 2. THE COIN COLLECT SOUND (Arpeggio Trick) ---
; Concept: Rapid step-wise note hopping on a tight pulse-width rectangle channel.
Procedure.i GenerateCoin(Array SoundBuffer.d(1), SampleRate.d)
  Protected State.DOSC::TOscillatorState
  Protected.i sampleIndex = 0
  Protected.i I
  
  ; Total duration is 0.25 seconds split into two distinct pitch phases
  Protected.d totalDuration = 0.25
  Protected.i totalSamples  = totalDuration * SampleRate
  Dim SoundBuffer(totalSamples - 1)
  
  ; Part 1: Play a low note (e.g., C5 = 523.25 Hz) for the first 0.05 seconds
  Protected.i part1Samples = 0.05 * SampleRate
  Protected.i part1Length  = part1Samples
  Dim TempBuffer.d(0)
  
  State\Phase = 0.0 ; Reset oscillator phase
  DOSC::Osc_ProcessBlock(TempBuffer(), part1Length, SampleRate, DOSC::#DOSC_Wave_Rectangle, 523.25, 0.15, @State)
  
  ; Copy part 1 into main buffer
  For I = 0 To part1Length - 1
    SoundBuffer(sampleIndex) = TempBuffer(I)
    sampleIndex + 1
  Next
  
  ; Part 2: Play a high note (e.g., E6 = 1318.51 Hz) for the remaining 0.20 seconds
  ; The crisp pitch transition happens instantly without any smoothing/sweeping
  Protected.i part2Length = totalSamples - part1Length
  DOSC::Osc_ProcessBlock(TempBuffer(), part2Length, SampleRate, DOSC::#DOSC_Wave_Rectangle, 1318.51, 0.15, @State)
  
  ; Copy part 2 into main buffer
  For I = 0 To part2Length - 1
    SoundBuffer(sampleIndex) = TempBuffer(I)
    sampleIndex + 1
  Next
  
  ProcedureReturn totalSamples
EndProcedure


; --- 3. THE 8-BIT EXPLOSION (Filtered Noise Sweep) ---
; Concept: White noise passed through a dynamically closing Biquad Low-Pass filter.
Procedure.i GenerateExplosion(Array SoundBuffer.d(1), SampleRate.d, *FilterCoeffs.DSP::TBiquadCoeffs, *FilterState.DSP::TBiquadState)
  Protected.d durationSecs = 0.6 ; Sustained impact tail
  Protected.i totalSamples  = durationSecs * SampleRate
  Dim SoundBuffer(totalSamples - 1)
  
  Protected.i I, chunkIndex
  Protected.i chunkSize = 256 ; Small chunks allow smooth, fast filter parameter sweeping
  Dim ChunkBuffer.d(chunkSize - 1)
  
  Protected.d currentCutoff = 1200.0 ; Start with a slightly bright crunch
  Protected.d targetCutoff  = 30.0   ; Fade down to a sub-bass rumble
  Protected.d cutoffStep    = (targetCutoff - currentCutoff) / (totalSamples / chunkSize)
  
  ; Outer loop: Process the overall audio stream in small blocks
  For chunkIndex = 0 To (totalSamples / chunkSize) - 1
    
    ; 1. Generate Raw White Noise for this chunk
    For I = 0 To chunkSize - 1
      ; Generate random values ranging uniformly between -1.0 and +1.0
      ChunkBuffer(I) = (Random(20000) / 10000.0) - 1.0
    Next
    
    ; 2. Dynamically re-calculate filter coefficients for the current cutoff step
    ; [YOUR DSP LOGIC]: ComputeLowPassCoefficients(*FilterCoeffs, currentCutoff, SampleRate, 0.707)
    
    ; 3. Process the noise chunk using your native IIR Filter
    DSP::IIR_ProcessBlock(ChunkBuffer(), chunkSize, *FilterCoeffs, *FilterState)
    
    ; 4. Apply a linear volume envelope decay directly onto the filtered samples
    Protected.d volumeFactor = 1.0 - ( (chunkIndex * chunkSize) / totalSamples )
    
    ; 5. Copy the fully processed chunk into the master output buffer
    For I = 0 To chunkSize - 1
      Protected.i targetIndex = (chunkIndex * chunkSize) + I
      If targetIndex < totalSamples
        SoundBuffer(targetIndex) = ChunkBuffer(I) * volumeFactor
      EndIf
    Next
    
    ; Sweep the cutoff frequency down for the next iteration step
    currentCutoff + cutoffStep
    If currentCutoff < 20.0 : currentCutoff = 20.0 : EndIf
  Next
  
  ProcedureReturn totalSamples
EndProcedure

  ; --- 4. THE CLASSIC JUMP SOUND ---
  ; Concept: A rapid upward frequency sweep mimicking the physics of an upward leap.
  Procedure.i GenerateJump(Array SoundBuffer.d(1), SampleRate.d)
    Protected SweepState.DOSC::TOscillatorSweepState
    Protected.d durationSecs = 0.16 ; Short, responsive trigger
    Protected.d startFreq    = 140.0  ; Start low
    Protected.d endFreq      = 650.0  ; Sweep into high registers
    Protected.i totalSamples = durationSecs * SampleRate
    
    ; Prepare a linear upward sweep
    DOSC::Osc_InitSweep(@SweepState, startFreq, endFreq, durationSecs, SampleRate, #False)
    
    ; Using Triangle wave yields a softer, iconic 'mario-like' fluid texture. 
    ; Switch to #Oscillator_Rectangle for a harsher, more aggressive arcade bounce.
    DOSC::OscSweep_ProcessBlock(SoundBuffer(), totalSamples, SampleRate, DOSC::#DOSC_Wave_Triangle, 0.5, @SweepState)
    
    ProcedureReturn totalSamples
  EndProcedure

  ; --- 5. THE DAMAGE / HIT SOUND (Power-Down) ---
  ; Concept: A stepped, collapsing pitch drop with rapid volume decay.
  Procedure.i GenerateDamage(Array SoundBuffer.d(1), SampleRate.d)
    Protected State.DOSC::TOscillatorState
    Protected.i sampleIndex = 0
    Protected.i I, stepIndex
    
    ; We simulate 5 distinct descending pitch steps to create a retro 'stuttering' breakdown
    Protected.i totalSteps   = 5
    Protected.d stepDuration = 0.05 ; 50ms per pitch step
    Protected.i stepSamples  = stepDuration * SampleRate
    Protected.i totalSamples = totalSteps * stepSamples
    Dim SoundBuffer(totalSamples - 1)
    
    Dim TempBuffer.d(0)
    Protected.d baseFreq = 480.0
    
    For stepIndex = 0 To totalSteps - 1
      ; Progressively lower the pitch for each sequential step
      Protected.d currentFreq = baseFreq - (stepIndex * 90.0)
      If currentFreq < 40.0 : currentFreq = 40.0 : EndIf
      
      ; Reset local oscillator phase to make each pitch step bite hard (retro feel)
      State\Phase = 0.0
      DOSC::Osc_ProcessBlock(TempBuffer(), stepSamples, SampleRate, DOSC::#DOSC_Wave_SawTooth, currentFreq, 0.5, @State)
      
      ; Apply volume attenuation based on the total timeline (fading out)
      For I = 0 To stepSamples - 1
        Protected.d volumeEnvelope = 1.0 - ( (sampleIndex) / totalSamples )
        SoundBuffer(sampleIndex) = TempBuffer(I) * volumeEnvelope
        sampleIndex + 1
      Next
    Next
    
    ProcedureReturn totalSamples
  EndProcedure
  
    ; --- 6. CONTINUOUS PROPELLER ENGINE SOUND ---
  ; Concept: A low-frequency mechanical rumble modulated by a rapid volume LFO 
  ;          to simulate the physical chopping of air by rotating blades.
  ; LengthSamples: Since this sound loops, you define how long one buffer chunk should be.
  ; EngineRPM: Controls the speed of the propeller (e.g., 1200.0 to 3000.0 RPM)
  Procedure.i GeneratePropeller(Array SoundBuffer.d(1), LengthSamples.i, SampleRate.d, EngineRPM.d)
    Protected StateEngine.DOSC::TOscillatorState
    Protected StateLFO.DOSC::TOscillatorState
    Protected.i I
    
    If LengthSamples <= 0 Or SampleRate <= 0.0 : ProcedureReturn 0 : EndIf
    
    ; Resize the target array for this audio chunk
    Dim SoundBuffer(LengthSamples - 1)
    
    ; Calculate frequencies based on Engine RPM (Revolutions Per Minute)
    ; 1. The main engine rumble frequency (e.g., 2400 RPM / 60 = 40 Hz base tone)
    Protected.d baseEngineFreq = EngineRPM / 60.0
    
    ; 2. The air-chopping frequency (LFO). Propellers usually have 2-4 blades.
    ;    We multiply the base frequency to simulate multiple blades hitting the air per rotation.
    Protected.d bladeChoppingFreq = baseEngineFreq * 3.0 ; Simulating a 3-blade propeller
    
    ; Allocate temporary buffers for both oscillators
    Dim EngineChunk.d(0)
    Dim LfoChunk.d(0)
    
    ; Generate the raw low-end motor rumble (Sawtooth gives a great mechanical crunch)
    StateEngine\Phase = 0.0
    DOSC::Osc_ProcessBlock(EngineChunk(), LengthSamples, SampleRate, DOSC::#DOSC_Wave_SawTooth, baseEngineFreq, 0.5, @StateEngine)
    
    ; Generate the volume modulation wave (Sine wave mapped to positive values works best)
    StateLFO\Phase = 0.0
    DOSC::Osc_ProcessBlock(LfoChunk(), LengthSamples, SampleRate, DOSC::#DOSC_Wave_Sine, bladeChoppingFreq, 0.5, @StateLFO)
    
    ; Combine the signals directly inside your PureBasic DSP loop
    For I = 0 To LengthSamples - 1
      ; Un-bias the sine LFO from [-1.0, +1.0] to a safe volume multiplier range [0.1, 1.0]
      Protected.d volumeModulator = ((LfoChunk(I) + 1.0) * 0.45) + 0.1
      
      ; Apply the rapid volume chopping onto the low-end engine hum
      SoundBuffer(I) = EngineChunk(I) * volumeModulator
    Next
    
    ProcedureReturn LengthSamples
  EndProcedure
  
  ; --- 7. RACING CAR FLYBY EFFECT (Doppler + Distance Attenuation) ---
  ; Concept: Simulates a racing car passing a stationary observer at a constant speed.
  ; BaseFreq:             The stationary engine idle pitch (e.g., 80.0 Hz for a deep V8 rumble).
  ; CarSpeedKmh:          Speed of the car in km/h (e.g., 200.0 km/h).
  ; ClosestDistanceMeters: How close the car gets to the observer at the apex (e.g., 5.0 meters).
  Procedure.i GenerateFlyby(Array SoundBuffer.d(1), DurationSecs.d, SampleRate.d, BaseFreq.d, CarSpeedKmh.d, ClosestDistanceMeters.d)
    Protected StateEngine.DOSC::TOscillatorState
    Protected.i I
    Protected.i totalSamples = DurationSecs * SampleRate
    Dim SoundBuffer(totalSamples - 1)
    
    #SPEED_OF_SOUND = 343.0 ; Speed of sound in meters per second
    Protected.d v_car = (CarSpeedKmh / 3.6) ; Convert km/h to meters per second
    
    ; We simulate the car moving along a straight line from left to right.
    ; At t = 0, the car starts far away. At t = midpoint, it is at the closest distance.
    Protected.d halfDuration = DurationSecs / 2.0
    Protected.d timeStep, t, x, distance, speedVector, volume, currentFreq, phaseInc
    
    ; Local state caching
    Protected.d currentPhase = 0.0
    
    For I = 0 To totalSamples - 1
      ; 1. Calculate the current time 't' relative to the passing apex (t=0 is the exact moment of passing)
      t = (I / SampleRate) - halfDuration
      
      ; 2. Calculate the car's linear position along the track (x)
      x = v_car * t
      
      ; 3. Calculate absolute line-of-sight distance to the observer via Pythagoras
      distance = Sqr((x * x) + (ClosestDistanceMeters * ClosestDistanceMeters))
      
      ; 4. Calculate the speed component directly towards or away from the observer
      ;    This is the dot product projection of the velocity vector
      speedVector = v_car * (x / distance)
      
      ; 5. THE DOPPLER SHIFT FORMULA
      ;    F_observed = F_source * (SpeedOfSound / (SpeedOfSound + SpeedVector))
      currentFreq = BaseFreq * (#SPEED_OF_SOUND / (#SPEED_OF_SOUND + speedVector))
      
      ; 6. DISTANCE ATTENUATION (Inverse Square Law approximation for volume)
      ;    We add 1.0 to prevent division by zero at closest approach
      volume = 1.0 / (1.0 + (distance * 0.1)) 
      
      ; 7. Generate the audio sample (Sawtooth wave gives that perfect aggressive engine buzz)
      phaseInc = currentFreq / SampleRate
      
      ; Replicating your basic Sawtooth formula but applying the dynamic volume envelope
      SoundBuffer(I) = (2.0 * currentPhase - 1.0) * volume
      
      ; Phase wrapping update
      currentPhase + phaseInc
      If currentPhase >= 1.0 : currentPhase - 1.0 : EndIf
    Next
    
    ProcedureReturn totalSamples
  EndProcedure
  
    ; --- 8. NAVAL CANNON BLAST ---
  ; Concept: A devastating heavy artillery blast blending a low-end sine pressure pop 
  ;          with white noise, all reshaped by a plunging low-pass biquad filter envelope.
  Procedure.i GenerateNavalCannon(Array SoundBuffer.d(1), SampleRate.d, *FilterCoeffs, *FilterState)
    Protected.d durationSecs = 1.2 ; Heavy cannons have a very long low-end rumble tail
    Protected.i totalSamples = durationSecs * SampleRate
    Dim SoundBuffer(totalSamples - 1)
    
    Protected.i I, chunkIndex
    Protected.i chunkSize = 256
    Dim ChunkBuffer.d(chunkSize - 1)
    
    ; Setup the dynamic low-pass filter sweep
    Protected.d currentCutoff = 2500.0 ; Start with a piercing muzzle blast bite
    Protected.d targetCutoff  = 25.0   ; Fade out into sea-shaking sub-bass
    Protected.d cutoffStep    = (targetCutoff - currentCutoff) / (totalSamples / chunkSize)
    
    ; Internal sine oscillator state for the initial pressure-wave punch
    Protected.d sinePhase = 0.0
    Protected.d sineFreq  = 180.0 ; Starting impact frequency
    
    For chunkIndex = 0 To (totalSamples / chunkSize) - 1
      Protected.i currentTimelineSample = chunkIndex * chunkSize
      
      ; 1. Synthesize raw components into the chunk
      For I = 0 To chunkSize - 1
        ; Generate white noise background fraction
        Protected.d noise = (Random(20000) / 10000.0) - 1.0
        
        ; Calculate dynamic sine pressure wave (collapses quickly after the first 60ms)
        Protected.d sineComponent = 0.0
        If currentTimelineSample < (0.06 * SampleRate)
          sineFreq - 1.5 ; Swift pitch drop for the shockwave explosion body
          If sineFreq < 40.0 : sineFreq = 40.0 : EndIf
          sineComponent = Sin(sinePhase * 2.0 * #PI)
          sinePhase + (sineFreq / SampleRate)
          If sinePhase >= 1.0 : sinePhase - 1.0 : EndIf
        EndIf
        
        ; Combine transient impact punch with sustained explosive smoke noise
        ChunkBuffer(I) = (sineComponent * 0.6) + (noise * 0.4)
      Next
      
      ; 2. Update filter coefficients for this micro-chunk
      ; [YOUR DSP LOGIC]: ComputeLowPassCoefficients(*FilterCoeffs, currentCutoff, SampleRate, 0.8)
      
      ; 3. Process through your native IIR Filter
      DSP::IIR_ProcessBlock(ChunkBuffer(), chunkSize, *FilterCoeffs, *FilterState)
      
      ; 4. Apply heavy exponential volume decay envelope
      Protected.d progress = currentTimelineSample / totalSamples
      Protected.d volumeEnvelope = Pow(1.0 - progress, 3.0) ; Aggressive curve for sudden blast decay
      
      ; 5. Commit chunk into master buffer
      For I = 0 To chunkSize - 1
        Protected.i targetIndex = currentTimelineSample + I
        If targetIndex < totalSamples
          SoundBuffer(targetIndex) = ChunkBuffer(I) * volumeEnvelope
        EndIf
      Next
      
      currentCutoff + cutoffStep
      If currentCutoff < 20.0 : currentCutoff = 20.0 : EndIf
    Next
    
    ProcedureReturn totalSamples
  EndProcedure

  ; --- 9. RHYTHMIC MACHINE GUN BURST ---
  ; Concept: Rapid loop triggering snappy high-amplitude transients followed by brief metallic noise bursts.
  ; ShotCount: Number of rounds fired in this single burst execution (e.g., 5 or 10 shots).
  Procedure.i GenerateMachineGun(Array SoundBuffer.d(1), SampleRate.d, ShotCount.i)
    Protected StateOsc.DOSC::TOscillatorState
    Protected.i I, shot, sampleIndex = 0
    
    Protected.d shotDuration = 0.09  ; Time window for one single bullet report (90ms = rapid fire)
    Protected.i shotSamples  = shotDuration * SampleRate
    Protected.i totalSamples = ShotCount * shotSamples
    Dim SoundBuffer(totalSamples - 1)
    
    Dim SingleShotBuffer.d(shotSamples - 1)
    
    ; Render loop for every sequential bullet fired
    For shot = 0 To ShotCount - 1
      StateOsc\Phase = 0.0 ; Lock phase at zero for every shot to guarantee uniform snappy mechanical crackle
      
      ; Render a very fast cracking engine utilizing your raw Sawtooth or Rectangle algorithm
      ; This simulates the high-velocity metal bolt action snapping forward
      DOSC::Osc_ProcessBlock(SingleShotBuffer(), shotSamples, SampleRate, DOSC::#DOSC_Wave_SawTooth, 320.0, 0.5, @StateOsc)
      
      For I = 0 To shotSamples - 1
        ; Generate a layer of randomized gas expansion powder noise
        Protected.d powderNoise = (Random(20000) / 10000.0) - 1.0
        
        ; Combine raw mechanical sawtooth punch with structural white noise gun-powder gas
        Protected.d mixedSignal = (SingleShotBuffer(I) * 0.5) + (powderNoise * 0.5)
        
        ; Apply a hyper-fast volume decay envelope specific to this single bullet discharge
        Protected.d shotProgress = I / shotSamples
        Protected.d shotEnvelope = Pow(1.0 - shotProgress, 4.0) ; Dropping incredibly sharp
        
        ; Write directly to master stream index
        SoundBuffer(sampleIndex) = mixedSignal * shotEnvelope
        sampleIndex + 1
      Next
    Next
    
    ProcedureReturn totalSamples
  EndProcedure

EndModule
; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 471
; FirstLine = 405
; Folding = --
; DPIAware
; CPU = 5