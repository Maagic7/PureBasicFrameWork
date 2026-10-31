; ===========================================================================
;  FILE : PbFw_Module_Scope.pb
;  NAME : Module SCOPE [SCOPE::]
;  DESC : A 4 Channel Digital Oscilloscope
;  DESC : 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/10/20
; VERSION  :  0.1 untested Developer Version
; COMPILER :  I hope all versions!
; OS       :  all
; ===========================================================================
; ChangeLog:
;{
;}
;{ TODO:
;}
; ===========================================================================

XIncludeFile "..\PbFw_Module_RingBuffer.pb"

DeclareModule SCOPE
  
  EnableExplicit 
  
  ;- ----------------------------------------------------------------------
  ;- CONSTANTS
  ;- ----------------------------------------------------------------------
  #CH1 = 0
  #CH2 = 1
  #CH3 = 2
  #CH4 = 3
  
  #TriggerMode_None   = 0
  #TriggerMode_Auto   = 1
  #TriggerMode_Normal = 2
  
  #TriggerEdge_Rising  = 0
  #TriggerEdge_Falling = 1
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES
  ;- ----------------------------------------------------------------------
  
  Structure TAxisParameter
    Scale.d         ; Volts/Div equivalent (amplitude multiplier)
    Offset.d        ; Zero-line offset in pixels from top
  EndStructure
  
  Structure TChannel
    Name.s          ; e.g., "CH 1"
    Color.l         ; RGBA Drawing Color
    IsActive.i      ; #True / #False toggle
    
    ; Ring Buffer object
    RBUF.RBUF::TRingBuffer
    Array DataBuf.d(0)
    
    ; Linear snapshot array used exclusively for high-speed plotting
    Array DisplayBuffer.d(0)
    
    SampleRate.d    
    AxisY.TAxisParameter 
  EndStructure
  
  Structure TTrigger
    Mode.i          
    Edge.i          
    Level.d         
    Channel.i       ; Source channel index (#CH1 to #CH4)
  EndStructure
  
  Structure TGrid
    DivisionsX.i
    DivisionsY.i
    SubDivisions.i
    ShowTicks.i
  EndStructure
  
  Structure TSCOPE
    pbGadget.i              ; Canvas ID
    Width.l                 ; Canvas cached width
    Height.l                ; Canvas cached height
    BackColor.l               ; Background Color
    GridColor.l             ; Grid Overlay Color
    
    Grid.TGrid              ; Grid layout parameters
    AxisX.TAxisParameter    ; Shared horizontal timebase Axis
    Trigger.TTrigger        ; Trigger subsystem setup
    
    ; --- MOUSE INTERACTION TRACKING VARIABLES ---
    SelectedChannel.i       ; Stores the active dragged channel index (-1 = None, 99 = Trigger)
    IsDragging.i            ; Boolean flag indicating if mouse drag is currently active
    
    ; Array for the 4 channels
    Array Channel.TChannel(3)
  EndStructure
  
  ;- ----------------------------------------------------------------------
  ;- PROCEDURES (Public API)
  ;- ----------------------------------------------------------------------
  Declare.i InitScope(*SCP.TScope, pbGadget.i)
  Declare.i SetupChannel(*SCP.TScope, ChannelNo.i, Name.s, Color.l, NoOfSamples.i, SampleRate.d)
  Declare   ClearScope(*SCP.TScope)
  Declare   RenderScope(*SCP.TScope)
  Declare   HandleMouseEvents(*SCP.TScope)
  
EndDeclareModule


Module SCOPE
  EnableExplicit  
  
  Procedure HandleMouseEvents(*SCP.TScope)
  ; ============================================================================
  ; NAME: HandleMouseEvents
  ; DESC: Process Canvas mouse actions including Channel Offsets and Trigger Level
  ; ============================================================================
    Protected MouseX.i, MouseY.i, EType.i, i.i
    Protected.d Distance, OffsetY, StepY, NearestGridY, GridDist
    Protected *TChan.TChannel
    Protected TriggerY.d
    
    If Not (*SCP And IsGadget(*SCP\pbGadget)) : ProcedureReturn : EndIf
    
    ; Query current mouse state from the active Canvas context
    EType  = EventType()
    MouseX = GetGadgetAttribute(*SCP\pbGadget, #PB_Canvas_MouseX)
    MouseY = GetGadgetAttribute(*SCP\pbGadget, #PB_Canvas_MouseY)
    
    ; Get a pointer to the current trigger source channel
    *TChan = @*SCP\Channel(*SCP\Trigger\Channel)
    
    Select EType
        
      Case #PB_EventType_LeftButtonDown
        *SCP\SelectedChannel = -1
        *SCP\IsDragging      = #False
        
        ; 1. First check if user clicked near the Trigger Marker on the RIGHT edge
        TriggerY = *TChan\AxisY\Offset - (*SCP\Trigger\Level * *TChan\AxisY\Scale)
        If MouseX >= *SCP\Width - 25 And Abs(MouseY - TriggerY) <= 12.0
          *SCP\SelectedChannel = 99 ; 99 is our internal ID for the Trigger Level
          *SCP\IsDragging      = #True
        Else
          ; 2. If not the Trigger, check Channel baseline markers on the LEFT edge
          For i = 0 To 3
            If *SCP\Channel(i)\IsActive
              OffsetY  = *SCP\Channel(i)\AxisY\Offset
              If MouseX <= 25 And Abs(MouseY - OffsetY) <= 12.0
                *SCP\SelectedChannel = i
                *SCP\IsDragging      = #True
                Break ; Grab the first channel matching the criteria
              EndIf
            EndIf
          Next i
        EndIf
        
      Case #PB_EventType_MouseMove
        ; If active dragging is running, update coordinates dynamically
        If *SCP\IsDragging And *SCP\SelectedChannel <> -1
          ; Lock boundary movement inside canvas limits
          If MouseY < 0 : MouseY = 0 : EndIf
          If MouseY > *SCP\Height : MouseY = *SCP\Height : EndIf
          
          ; Calculate grid steps for the snapping feature
          StepY = *SCP\Height / *SCP\Grid\DivisionsY
          NearestGridY = Round(MouseY / StepY, #PB_Round_Nearest) * StepY
          
          ; --- CASE A: DRAGGING THE TRIGGER LEVEL (ID 99) ---
          If *SCP\SelectedChannel = 99
            ; Snap magnet to the channel's zero baseline (Ground)
            If Abs(MouseY - *TChan\AxisY\Offset) <= 8.0
              MouseY = *TChan\AxisY\Offset
            ; Snap magnet to horizontal division lines
            ElseIf Abs(MouseY - NearestGridY) <= 8.0
              MouseY = NearestGridY
            EndIf
            
            ; Reverse-calculate pixel coordinate back into original Double values
            If *TChan\AxisY\Scale <> 0.0
              *SCP\Trigger\Level = (*TChan\AxisY\Offset - MouseY) / *TChan\AxisY\Scale
            EndIf
            
          ; --- CASE B: DRAGGING A REGULAR CHANNEL BASELINE ---
          Else
            ; Snap magnet to horizontal division lines
            If Abs(MouseY - NearestGridY) <= 8.0
              *SCP\Channel(*SCP\SelectedChannel)\AxisY\Offset = NearestGridY
            Else
              *SCP\Channel(*SCP\SelectedChannel)\AxisY\Offset = MouseY
            EndIf
          EndIf
          
          ; Instantly trigger re-render for seamless realtime updates
          RenderScope(*SCP)
        EndIf
        
      Case #PB_EventType_LeftButtonUp, #PB_EventType_MouseLeave
        ; Release tracking state safely
        *SCP\SelectedChannel = -1
        *SCP\IsDragging      = #False
        
    EndSelect
  EndProcedure
  
  ; Internal helper function (Private)
  Procedure.i FindTriggerIndex(*SCP.TScope, *Chan.TChannel)
    Protected TargetIdx.i = -1
    Protected CurrIdx.i, PrevIdx.i
    Protected SearchLimit.i, i.i
    Protected VCurr.d, VPrev.d
    Protected TriggerVal.d = *SCP\Trigger\Level
    Protected Hysteresis.d = 0.02 
    Protected WriteIdx.i = RBUF::GetIndex(*Chan\RBUF)
    Protected BufSize.i  = *Chan\RBUF\ByteSize
    
    ProcedureReturn  0
    
    If *SCP\Trigger\Mode = #TriggerMode_None
      ProcedureReturn WriteIdx
    EndIf
    
    ; --- Define a safe historical starting point for the search ---
    ; We calculate how many samples the screen window will consume at max
    Protected ScreenSamples.i = *SCP\Width * *SCP\AxisX\Scale
    
    ; We start looking for the trigger event safely BEHIND the write cursor,
    ; ensuring that even the rightmost pixel on the screen stays in valid written memory.
    
    CurrIdx = RBUF::GetPrevIndex(*Chan\RBUF, ScreenSamples - 16)
    ; Handle ring wrap-around for the starting index
    
    ; Limit the search to the available buffer history
    SearchLimit = BufSize - ScreenSamples - 32
    
    ; --- The search loop stays identical, but operates in the safe zone ---
    For i = 0 To SearchLimit
      PrevIdx = CurrIdx - 1
      If PrevIdx < 0 : PrevIdx = BufSize - 1 : EndIf
      
       VCurr = *Chan\RBUF\pBuf\d[CurrIdx]
       VPrev = *Chan\RBUF\pBuf\d[PrevIdx]
      
      If *SCP\Trigger\Edge = #TriggerEdge_Rising
        If VPrev <= (TriggerVal - Hysteresis) And VCurr > TriggerVal
          TargetIdx = PrevIdx
          Break
        EndIf
      ElseIf *SCP\Trigger\Edge = #TriggerEdge_Falling
        If VPrev >= (TriggerVal + Hysteresis) And VCurr < TriggerVal
          TargetIdx = PrevIdx
          Break
        EndIf
      EndIf
      
      CurrIdx = PrevIdx
    Next i
    
    ; Fallback strategy if no edge was hit
    If TargetIdx = -1
      If *SCP\Trigger\Mode = #TriggerMode_Auto
        Protected SafeDistance.i = ScreenSamples + 128
        Protected FallbackIdx.i = WriteIdx - SafeDistance
        If FallbackIdx < 0 : FallbackIdx + BufSize : EndIf
        ProcedureReturn FallbackIdx
      Else
        ProcedureReturn -1 
      EndIf
    EndIf
    
    ProcedureReturn TargetIdx
  EndProcedure
  
  Procedure.i InitScope(*SCP.TScope, pbGadget.i)
    If *SCP And IsGadget(pbGadget)
      *SCP\pbGadget  = pbGadget
      *SCP\Width     = GadgetWidth(pbGadget)
      *SCP\Height    = GadgetHeight(pbGadget)
      *SCP\BackColor   = RGBA(10, 15, 10, 255)     
      *SCP\GridColor = RGBA(0, 140, 0, 90)       
      
      *SCP\Grid\DivisionsX   = 10
      *SCP\Grid\DivisionsY   = 8
      *SCP\Grid\SubDivisions = 5                 
      *SCP\Grid\ShowTicks    = #True
      
      *SCP\AxisX\Scale   = 1.0
      *SCP\AxisX\Offset  = 0.0
      
      *SCP\Trigger\Mode    = #TriggerMode_Auto
      *SCP\Trigger\Edge    = #TriggerEdge_Rising
      *SCP\Trigger\Level   = 0.0
      *SCP\Trigger\Channel = #CH1 
      
      *SCP\SelectedChannel = -1
      *SCP\IsDragging      = #False
      
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetupChannel(*SCP.TScope, ChannelNo.i, Name.s, Color.l, NoOfRingBufferItems.i, SampleRate.d)
  ; ============================================================================
  ; NAME: SetupChannel
  ; DESC: Initializes channel attributes and links up the standalone high-speed RingBuffer
  ; ============================================================================
    
    If *SCP And ChannelNo >= 0 And ChannelNo <= 3 And NoOfRingBufferItems > 0
      
      With *SCP\Channel(ChannelNo)
        \Name       = Name
        \Color      = Color
        \IsActive   = #True
        \SampleRate = SampleRate
        
        \AxisY\Scale  = 1.0
        \AxisY\Offset = *SCP\Height / 2.0
        
        ; Allocate the Ringbuffers Memory and assign it to our RingBuffer object
        Dim \DataBuf(NoOfRingBufferItems)
        RBUF::Init(\RBUF, @\DataBuf(0), NoOfRingBufferItems, #PB_Double) 
        
        ; linear Data Array to desplay the curve -> a linear arranged copy of the Datas from the Ringbuffer
        Dim \DisplayBuffer(*SCP\Width)
           
      EndWith
    
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure DrawGrid(*SCP.TScope)
    Protected i.i
    Protected.d StepX, StepY, CurrPos
    Protected CenterX.i, CenterY.i
    Protected TickSize.i = 4
    
    StepX = *SCP\Width / *SCP\Grid\DivisionsX
    StepY = *SCP\Height / *SCP\Grid\DivisionsY
    CenterX = *SCP\Width / 2
    CenterY = *SCP\Height / 2
    
    For i = 1 To *SCP\Grid\DivisionsX - 1
      CurrPos = i * StepX
      Line(CurrPos, 0, 1, *SCP\Height, *SCP\GridColor)
    Next i
    For i = 1 To *SCP\Grid\DivisionsY - 1
      CurrPos = i * StepY
      Line(0, CurrPos, *SCP\Width, 1, *SCP\GridColor)
    Next i
    
    If *SCP\Grid\ShowTicks
      Protected.d TickStepX = StepX / *SCP\Grid\SubDivisions
      Protected.d TickStepY = StepY / *SCP\Grid\SubDivisions
      For i = 1 To (*SCP\Grid\DivisionsX * *SCP\Grid\SubDivisions) - 1
        CurrPos = i * TickStepX
        Line(CurrPos, CenterY - TickSize / 2, 1, TickSize, *SCP\GridColor)
      Next i
      For i = 1 To (*SCP\Grid\DivisionsY * *SCP\Grid\SubDivisions) - 1
        CurrPos = i * TickStepY
        Line(CenterX - TickSize / 2, CurrPos, TickSize, 1, *SCP\GridColor)
      Next i
    EndIf
  EndProcedure

  Procedure RenderScope(*SCP.TScope)
  ; ============================================================================
  ; NAME: RenderScope
  ; DESC: The definitive, rock-solid rendering loop using linear CopyMemory blocks
  ; ============================================================================
    Protected.i X, i, SamplesRead
    Protected.d TargetY1, TargetY2
    Protected *Chan.TChannel
    Protected TriggerBaseIdx.i, TriggerShiftItems
    Protected BaseAlpha.i
    
    If Not (*SCP And IsGadget(*SCP\pbGadget)) : ProcedureReturn : EndIf
    
    ; Step 1: Secure the base sync trigger index from the active source
    TriggerBaseIdx = FindTriggerIndex(*SCP, @*SCP\Channel(*SCP\Trigger\Channel))
    If TriggerBaseIdx = -1 
      ProcedureReturn 
    EndIf
    
    ; TriggerBaseIdx = 0
    
    ; Step 2: Open graphics pipe and paint screen elements
    If StartDrawing(CanvasOutput(*SCP\pbGadget))
      
      Box(0, 0, *SCP\Width, *SCP\Height, *SCP\BackColor)
      DrawGrid(*SCP)
      
      ; Step 3: Extract and plot the 4 channels completely linearly
      For i = 0 To 3
        *Chan = *SCP\Channel(i)
        
        If *Chan\IsActive
          Debug "*SCP\Width = " + *SCP\Width
          ; REVOLUTIONARY: Instantly pull a time-consistent clean block using CopyMemory!
          SamplesRead = RBUF::MultiReadDouble(*Chan\RBUF, *Chan\DisplayBuffer(), *SCP\Width, TriggerShiftItems)
          ; Only render if we have enough linear elements extracted
          If SamplesRead > 0
            Debug "Samples Read = " + SamplesRead
            ; Draw permanent Zero-Baseline Indicators
            BaseAlpha = 40
            If *SCP\IsDragging And *SCP\SelectedChannel = i
              BaseAlpha = 150
            EndIf
            Line(0, *Chan\AxisY\Offset, *SCP\Width, 1, RGBA(Red(*Chan\Color), Green(*Chan\Color), Blue(*Chan\Color), BaseAlpha))
            Line(0, *Chan\AxisY\Offset - 1, 15, 3, *Chan\Color)
            
            ; 100% stable plotting: Pure linear indexing, zero complex circular math!
            For X = 0 To SamplesRead - 2
              Debug "X = " + X
              TargetY1 = *Chan\AxisY\Offset - (*Chan\DisplayBuffer(X) * *Chan\AxisY\Scale)
              TargetY2 = *Chan\AxisY\Offset - (*Chan\DisplayBuffer(X + 1) * *Chan\AxisY\Scale)
              
              ; Boundary Clipping
              If TargetY1 < 0 : TargetY1 = 0 : EndIf
              If TargetY1 > *SCP\Height : TargetY1 = *SCP\Height : EndIf
              If TargetY2 < 0 : TargetY2 = 0 : EndIf
              If TargetY2 > *SCP\Height : TargetY2 = *SCP\Height : EndIf
              
              LineXY(X, TargetY1, X + 1, TargetY2, *Chan\Color)
              ;Plot(X, TargetY1, *Chan\Color)
            Next X
            
          EndIf
        EndIf
      Next i
      
      ; --- Draw OSD Text Info ---
      DrawingMode(#PB_2DDrawing_Transparent)
      Protected Txt.s = "TRG: "
      Select *SCP\Trigger\Mode
        Case #TriggerMode_None   : Txt + "FREE RUN"
        Case #TriggerMode_Auto   : Txt + "AUTO"
        Case #TriggerMode_Normal : Txt + "NORMAL"
      EndSelect
      Txt + " [CH " + Str(*SCP\Trigger\Channel + 1) + "]"
      DrawText(15, 15, Txt, RGB(180, 180, 180))
      
      Protected ChanX.i = 15, ChanY.i = *SCP\Height - 25
      For i = 0 To 3
        *Chan = @*SCP\Channel(i)
        Txt = "CH" + Str(i + 1) + ": "
        If *Chan\IsActive
          Txt + StrD(*Chan\AxisY\Scale, 1) + " V/Div"
          DrawText(ChanX, ChanY, Txt, RGB(Red(*Chan\Color), Green(*Chan\Color), Blue(*Chan\Color)))
        Else
          Txt + "OFF"
          DrawText(ChanX, ChanY, Txt, RGB(80, 85, 80))
        EndIf
        ChanX + 130
      Next i
      
      ; --- Draw Trigger-Level Indicator ---
      Protected TriggerChan.i = *SCP\Trigger\Channel
      Protected *TChan.TChannel = @*SCP\Channel(TriggerChan)
      Protected TriggerY.d = *TChan\AxisY\Offset - (*SCP\Trigger\Level * *TChan\AxisY\Scale)
      
      If TriggerY >= 0 And TriggerY <= *SCP\Height
        Protected TriggerAlpha.i = 50
        If *SCP\IsDragging And *SCP\SelectedChannel = 99
          TriggerAlpha = 160
        EndIf
        Line(0, TriggerY, *SCP\Width, 1, RGBA(255, 255, 255, TriggerAlpha))
        Protected RightX.i = *SCP\Width - 15
        Line(RightX, TriggerY - 1, 15, 3, RGB(255, 140, 0))
        Line(RightX, TriggerY - 5, 1, 11, RGB(255, 140, 0))
        Line(RightX, TriggerY - 5, 5, 1, RGB(255, 140, 0))
      EndIf
      
      StopDrawing()
    EndIf
  EndProcedure
  
  Procedure AddSingleSample(*Chan.TChannel, Value.d)
  ; ============================================================================
  ; NAME: AddSingleSample
  ; DESC: Forwarding function to push a single sample into the encapsulated RBUF
  ; ============================================================================
    If *Chan
      ; Call the public API of the RBUF module directly
      RBUF::AddDouble(*Chan\RBUF, Value)
    EndIf
  EndProcedure
  
 Procedure AddMultiSample(*Chan.TChannel, Array SampleArray.d(1), Count.i)
  ; ============================================================================
  ; NAME: AddMultiSample
  ; DESC: Forwarding function to push an array block into the encapsulated RBUF
  ; ============================================================================
    If *Chan And SampleArray() And Count > 0
      RBUF::MultiAddDouble(*Chan\RBUF, SampleArray(), Count)
    EndIf
  EndProcedure
  
  Procedure ClearScope(*SCP.TScope)
    If *SCP And IsGadget(*SCP\pbGadget)
      If StartDrawing(CanvasOutput(*SCP\pbGadget))
        Box(0, 0, *SCP\Width, *SCP\Height, *SCP\BackColor)
        DrawGrid(*SCP)
        StopDrawing()
      EndIf
    EndIf
  EndProcedure

EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 21
; FirstLine = 20
; Folding = ---
; DPIAware
; CPU = 5