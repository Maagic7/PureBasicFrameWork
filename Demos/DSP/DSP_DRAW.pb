; ===========================================================================
;   DspDrw.pb - PbFw Extension Module
; ===========================================================================
; Description: VectorDrawing helper functions for displaying
;              waveforms and FFT spectrums on PureBasic CanvasGadgets.
; Co-authored by Google Gemini.
; ===========================================================================

DeclareModule DspDrw
  ; Renders a time-domain waveform (Oscilloscope style) onto a CanvasGadget
  Declare.i DrawWaveform(CanvasGadget.i, Array Signal.d(1), Length.i, LineColor.i = $FF00FF00)
  
  ; Renders a frequency-domain spectrum (Analyzer style) onto a CanvasGadget with log scaling
  Declare.i DrawSpectrum(CanvasGadget.i, Array Mag.d(1), MagLength.i, GridColor.i = $FF444444, LineColor.i = $FFFF9900)
EndDeclareModule

Module DspDrw

  ; Helper to setup VectorDrawing context safely
   ; Optimized Helper to setup VectorDrawing context safely
  Procedure.i _StartVectorDrawing(CanvasGadget.i, *W.Integer, *H.Integer)
    ; 1. Check if the gadget exists in PureBasic memory
    If Not IsGadget(CanvasGadget) 
      ProcedureReturn #False
    EndIf
    
    *W\i = GadgetWidth(CanvasGadget)
    *H\i = GadgetHeight(CanvasGadget)
    
    ; 2. Fetch the output channel
    Protected.i output = CanvasVectorOutput(CanvasGadget)
    
    If Not output 
      ProcedureReturn #False
    EndIf ; Safety check if OS output is ready
    
    ; 3. Attempt to initialize drawing context
    Protected.i context = StartVectorDrawing(output)
    If Not context
      Debug "Warning: Vector drawing context initialization failed (Thread collision or OS lock)."
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn context
  EndProcedure

  ; --- Time Domain: Oscilloscope ---
  Procedure.i DrawWaveform(CanvasGadget.i, Array Signal.d(1), Length.i, LineColor.i = $FF00FF00)
    Protected.i w, h, i
    Protected.d stepX, midY, x, y
    
    If Length <= 1 : ProcedureReturn #False : EndIf
    
    If _StartVectorDrawing(CanvasGadget, @w, @h)
      ; Clear background (Dark gray studio theme)
      VectorSourceColor($FF1A1A1A)
      FillVectorOutput()
      
      midY  = h / 2.0
      stepX = w / (Length - 1)
      
      ; Draw Center Zero-Line
      VectorSourceColor($FF333333)
      MovePathCursor(0, midY)
      AddPathLine(w, midY)
      StrokePath(1.0, #PB_Path_Default       )
      
      ; Generate wave path
      VectorSourceColor(LineColor)
      x = 0.0
      y = midY - (Signal(0) * midY)
      MovePathCursor(x, y)
      
      For i = 1 To Length - 1
        x + stepX
        ; Scale signal amplitude against window boundaries (clipped at -1.0 to 1.0)
        Protected.d sample = Signal(i)
        If sample > 1.0  : sample = 1.0  : EndIf
        If sample < -1.0 : sample = -1.0 : EndIf
        
        y = midY - (sample * midY)
        AddPathLine(x, y)
      Next i
      
      StrokePath(1.5)
      StopVectorDrawing()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  ; --- Frequency Domain: Logarithmic Analyzer ---
  Procedure.i DrawSpectrum(CanvasGadget.i, Array Mag.d(1), MagLength.i, GridColor.i = $FF444444, LineColor.i = $FFFF9900)
    Protected.i w, h, i, db
    Protected.d x, y, normX, logMin, logMax, logRange
    
    If MagLength <= 2 : ProcedureReturn #False : EndIf
    
    If _StartVectorDrawing(CanvasGadget, @w, @h)
      ; Clear background
      VectorSourceColor($FF1A1A1A)
      FillVectorOutput()
      
      ; 1. Draw Horizontal dB Grid Lines (-60 dB to 0 dB in steps of 10 dB)
      ; Assumes input Mag() is scaled in dBFS where 0.0 is maximum down to -100+ dB
      VectorSourceColor(GridColor)
      For db = 0 To 60 Step 10
        ; Map dB values (-60 to 0) to Y pixels (h to 0)
        y = (db / 60.0) * h
        MovePathCursor(0, y)
        AddPathLine(w, y)
      Next db
      StrokePath(1.0, #PB_Path_Default       )
      
      ; 2. Draw Vertical Logarithmic Frequency Grid Lines (20 Hz, 100 Hz, 1 kHz, 10 kHz, 20 kHz)
      ; Log mapping variables using normalization endpoints
      logMin   = Log(1.0) ; Index 1 baseline boundary
      logMax   = Log(MagLength)
      logRange = logMax - logMin
      
      ; Pre-defined fractional frequencies for standard studio grids
      ; We match standard positions visually across the window width
      Protected Dim GridFractions.d(4)
      GridFractions(0) = 0.05  ; ~50 Hz
      GridFractions(1) = 0.20  ; ~200 Hz
      GridFractions(2) = 0.50  ; ~1 kHz
      GridFractions(3) = 0.82  ; ~5 kHz
      GridFractions(4) = 0.95  ; ~15 kHz
      
      For i = 0 To 4
        x = GridFractions(i) * w
        MovePathCursor(x, 0)
        AddPathLine(x, h)
      Next i
      StrokePath(1.0, #PB_Path_Default       )
      
      ; 3. Generate and Render the Spectrum Curve
      ; First point configuration
      y = Mag(0) ; Fetch dB value
      ; Clamp visual floor to -60 dB to keep inside canvas window
      If y < -60.0 : y = -60.0 : EndIf
      If y > 0.0   : y = 0.0   : EndIf
      y = h - ((y + 60.0) / 60.0) * h ; Translate dB to Y pixel
      
      MovePathCursor(0, y)
      
      ; Loop through frequency bins using logarithmic X-axis scaling
      For i = 1 To MagLength - 1
        ; Logarithmic mapping ensures bass frequencies get more visual space
        normX = (Log(i) - logMin) / logRange
        x = normX * w
        
        y = Mag(i)
        If y < -60.0 : y = -60.0 : EndIf
        If y > 0.0   : y = 0.0   : EndIf
        y = h - ((y + 60.0) / 60.0) * h
        
        AddPathLine(x, y)
      Next i
      
      ; Visual style: Solid curve with a subtle alpha gradient underneath
      StrokePath(1.8, #PB_Path_RoundEnd)
      
      StopVectorDrawing()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 118
; Folding = -
; DPIAware
; CPU = 5