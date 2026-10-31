; ==========================================================
; Module Sektion: GEdit - Runtime Layout Engine Gadget Editor
; ==========================================================

XIncludeFile "PbFw_Module_PbSdk.pb"        ; PbSdk::    PureBasic SDK

DeclareModule GEdit
  
  ;- ----------------------------------------------------------------------
  ;- Public Structures
  ;- ----------------------------------------------------------------------
  
  ; Bounding box geometry for tracking elements
  Structure TBox
    X.i
    Y.i
    W.i
    H.i
  EndStructure
  
  ; This-Structure: Holds the entire state of an editor instance
  Structure TGEdit
    IsActive.i         ; #True if Edit-Mode is currently enabled
    GridSize.i         ; Current grid spacing value (e.g., 8, 10, 16)
    TargetGadget.i     ; The real PureBasic Gadget ID currently being modified (-1 = none)
    ActiveAnchor.i     ; 0 = moving whole body, 1..8 = resize anchors, -1 = none
    
    ; Mouse and Object tracking states
    DragStartMouseX.i  ; Mouse X position when left click occurred
    DragStartMouseY.i  ; Mouse Y position when left click occurred
    
    OrigObjectX.i      ; Unsnapped original X position of the target gadget
    OrigObjectY.i      ; Unsnapped original Y position of the target gadget
    OrigObjectW.i      ; Unsnapped original Width of the target gadget
    OrigObjectH.i      ; Unsnapped original Height of the target gadget
    ; Preview coordinates for rendering lines and alignment boxes
    Preview.TBox
    
    ; Fixed internal Array for the 8 resize anchor canvases
    AnchorIDs.i[8]
    AnchorSize.i       ; Box dimensions of the anchors (e.g., 7 pixels)
    AnchorHalf.i       ; Offset caching helper (AnchorSize / 2)
    
     
   ; Alignment Guide States
    ShowXLine.i        ; #True if a vertical line should be drawn
    ShowYLine.i        ; #True if a horizontal line should be drawn
    GuideLineX.i       ; The X coordinate where the vertical line is rendered
    GuideLineY.i       ; The Y coordinate where the horizontal line is rendered
  EndStructure

  ;- ----------------------------------------------------------------------
  ;- Public Functions (Interface with Object Pointer)
  ;- ----------------------------------------------------------------------
  
  ; Initializes the instance (creates anchor canvases and cache variables)
  Declare Initialize(*GEdit.TGEdit, AnchorBoxSize.i = 7)
  
  ; Activates or deactivates the editor state for this instance
  Declare SetActive(*GEdit.TGEdit, State.i, Grid.i = 8)
  
  ; Hooks a specific real PureBasic Gadget into the selection frame
  Declare SelectGadget(*GEdit.TGEdit, GadgetID.i)
  
  ; Clears any current selection state and hides the frame handles
  Declare ClearSelection(*GEdit.TGEdit)
  
  ; Triggers a complete redraw sequence for alignment guides and borders
  Declare RedrawGuides(*GEdit.TGEdit)
  
  ; Automatic operational stream handler. Call this inside your WaitWindowEvent() loop.
  Declare.i ProcessEvents(*GEdit.TGEdit, Event.i, EventGadget.i, EventType.i)
  
  ; Performs clean environment memory stack sweeps when freeing the instance
  Declare FreeEditor(*GEdit.TGEdit)

EndDeclareModule

Module GEdit
  
  ; Private Enum for the fixed array indexing mapping
  Enumeration
    #Anchor_TL = 0      ; Top Left
    #Anchor_TC          ; Top Center
    #Anchor_TR          ; Top Right
    #Anchor_RC          ; Right Center
    #Anchor_BR          ; Bottom Right
    #Anchor_BC          ; Bottom Cener
    #Anchor_BL          ; Bottom Left
    #Anchor_LC          ; Left Center
  EndEnumeration
  
  ; --- Private Helper: Scan all gadgets and calculate Lazarus-style alignment snaps ---
  Procedure _CalculateAlignmentGuides(*GEdit.TGEdit)
    Protected NewList AllGadgets.i()
    Protected CurrentGadget.i
    Protected SnapThreshold.i = 5 ; Snap tolerance in pixels
    
    ; Reset guide states
    *GEdit\ShowXLine = #False
    *GEdit\ShowYLine = #False
    
    ; TODO!
    ; 1. Fetch all living gadgets on the current window using your SDK method
    ; (Make sure to prefix with your actual SDK module name, e.g., PbSdk::GetGadgetList)
    PbSdk::GetGadgetList(AllGadgets()) ; GadGetliste um Ausrichtlinien zu Berechnen
    
    ; 2. Extract boundaries of our currently dragged preview object
    Protected px.i = *GEdit\Preview\X
    Protected py.i = *GEdit\Preview\Y
    Protected pw.i = *GEdit\Preview\W
    Protected ph.i = *GEdit\Preview\H
    
    ForEach AllGadgets()
      CurrentGadget = AllGadgets()
      
      ; Skip the target gadget itself and our 8 internal anchors
      Protected isAnchor.i = #False
      Protected i.i
      For i = 0 To 7
        If CurrentGadget = *GEdit\AnchorIDs[i] : isAnchor = #True : Break : EndIf
      Next i
      
      If CurrentGadget <> *GEdit\TargetGadget And Not isAnchor And IsGadget(CurrentGadget)
        ; Extract static neighbor boundaries
        Protected gx.i = GadgetX(CurrentGadget)
        Protected gy.i = GadgetY(CurrentGadget)
        Protected gw.i = GadgetWidth(CurrentGadget)
        Protected gh.i = GadgetHeight(CurrentGadget)
        
        ; --- VERTICAL ALIGNMENT (X-Axis Snapping) ---
        If Not *GEdit\ShowXLine
          ; Match Left to Left
          If Abs(px - gx) <= SnapThreshold
            *GEdit\Preview\X = gx : *GEdit\ShowXLine = #True : *GEdit\GuideLineX = gx
          ; Match Right to Left
          ElseIf Abs((px + pw) - gx) <= SnapThreshold
            *GEdit\Preview\X = gx - pw : *GEdit\ShowXLine = #True : *GEdit\GuideLineX = gx
          ; Match Left to Right
          ElseIf Abs(px - (gx + gw)) <= SnapThreshold
            *GEdit\Preview\X = gx + gw : *GEdit\ShowXLine = #True : *GEdit\GuideLineX = gx + gw
          ; Match Right to Right
          ElseIf Abs((px + pw) - (gx + gw)) <= SnapThreshold
            *GEdit\Preview\X = (gx + gw) - pw : *GEdit\ShowXLine = #True : *GEdit\GuideLineX = gx + gw
          EndIf
        EndIf
        
        ; --- HORIZONTAL ALIGNMENT (Y-Axis Snapping) ---
        If Not *GEdit\ShowYLine
          ; Match Top to Top
          If Abs(py - gy) <= SnapThreshold
            *GEdit\Preview\Y = gy : *GEdit\ShowYLine = #True : *GEdit\GuideLineY = gy
          ; Match Bottom to Top
          ElseIf Abs((py + ph) - gy) <= SnapThreshold
            *GEdit\Preview\Y = gy - ph : *GEdit\ShowYLine = #True : *GEdit\GuideLineY = gy
          ; Match Top to Bottom
          ElseIf Abs(py - (gy + gh)) <= SnapThreshold
            *GEdit\Preview\Y = gy + gh : *GEdit\ShowYLine = #True : *GEdit\GuideLineY = gy
          ; Match Bottom to Bottom
          ElseIf Abs((py + ph) - (gy + gh)) <= SnapThreshold
            *GEdit\Preview\Y = (gy + gh) - ph : *GEdit\ShowYLine = #True : *GEdit\GuideLineY = gy
          EndIf
        EndIf
        
        ; If both lines are found, we can break early to maximize performance
        If *GEdit\ShowXLine And *GEdit\ShowYLine : Break : EndIf
      EndIf
    Next
  EndProcedure
  
  ; --- Private Helper: Renders the blue/white grip layout box onto an anchor canvas ---
  Procedure _DrawAnchorBox(CanvasID.i, Size.i)
    If StartDrawing(CanvasOutput(CanvasID))
      Box(0, 0, Size, Size, RGB(255, 255, 255))
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, Size, Size, RGB(0, 102, 204))
      StopDrawing()
    EndIf
  EndProcedure

  ; --- Public: Initialize a specific GEdit Instance ---
  Procedure Initialize(*GEdit.TGEdit, AnchorBoxSize.i = 7)
    Protected i.i
    Protected CursorType.i
    
    If *GEdit = 0 : ProcedureReturn #False : EndIf
    
    *GEdit\AnchorSize = AnchorBoxSize
    *GEdit\AnchorHalf = AnchorBoxSize / 2
    *GEdit\TargetGadget = -1
    *GEdit\ActiveAnchor = -1
    *GEdit\IsActive = #False
    
    ; Allocate the 8 canvases dynamically via #PB_Any to prevent ID collisions
    For i = 0 To 7
      *GEdit\AnchorIDs[i] = CanvasGadget(#PB_Any, 0, 0, *GEdit\AnchorSize, *GEdit\AnchorSize)
      HideGadget(*GEdit\AnchorIDs[i], #True)
      _DrawAnchorBox(*GEdit\AnchorIDs[i], *GEdit\AnchorSize)
      
      ; Assign system native context mouse pointers
      Select i
        Case #Anchor_TL, #Anchor_BR : CursorType = #PB_Cursor_LeftUpRightDown
        Case #Anchor_TR, #Anchor_BL : CursorType = #PB_Cursor_LeftDownRightUp
        Case #Anchor_TC, #Anchor_BC : CursorType = #PB_Cursor_UpDown
        Case #Anchor_RC, #Anchor_LC : CursorType = #PB_Cursor_LeftRight
      EndSelect
      SetGadgetAttribute(*GEdit\AnchorIDs[i], #PB_Canvas_Cursor, CursorType)
    Next i
    
    ProcedureReturn #True
  EndProcedure

  ; --- Public: Trigger Redraw Sequence for Handles and Vector Lines ---
  Procedure RedrawGuides(*GEdit.TGEdit)
    Protected i.i
    Protected h.i
    
    If *GEdit = 0 Or *GEdit\TargetGadget = -1 : ProcedureReturn #False : EndIf
    
    ; Cache sizing offsets
    h = *GEdit\AnchorHalf
    Define.i x = *GEdit\Preview\X
    Define.i y = *GEdit\Preview\Y
    Define.i w = *GEdit\Preview\W
    Define.i hg = *GEdit\Preview\H
    
    ; 1. Move the 8 fixed array canvas anchor nodes synchronously
    ResizeGadget(*GEdit\AnchorIDs[#Anchor_TL], x - h,       y - h,        #PB_Ignore, #PB_Ignore)
    ResizeGadget(*GEdit\AnchorIDs[#Anchor_TC], x + w/2 - h, y - h,        #PB_Ignore, #PB_Ignore)
    ResizeGadget(*GEdit\AnchorIDs[#Anchor_TR], x + w - h,   y - h,        #PB_Ignore, #PB_Ignore)
    ResizeGadget(*GEdit\AnchorIDs[#Anchor_RC], x + w - h,   y + hg/2 - h, #PB_Ignore, #PB_Ignore)
    ResizeGadget(*GEdit\AnchorIDs[#Anchor_BR], x + w - h,   y + hg - h,   #PB_Ignore, #PB_Ignore)
    ResizeGadget(*GEdit\AnchorIDs[#Anchor_BC], x + w/2 - h, y + hg - h,   #PB_Ignore, #PB_Ignore)
    ResizeGadget(*GEdit\AnchorIDs[#Anchor_BL], x - h,       y + hg - h,   #PB_Ignore, #PB_Ignore)
    ResizeGadget(*GEdit\AnchorIDs[#Anchor_LC], x - h,       y + hg/2 - h, #PB_Ignore, #PB_Ignore)
    
    ; 2. Render bounding boxes and alignment paths directly onto the active Window target
    ; (Note: If using an overlay window/canvas glass pane, swap WindowOutput with CanvasOutput)
    If StartDrawing(WindowOutput(GetActiveWindow()))
      
      ; Draw the main highlight bounding outline frame
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(x, y, w, hg, RGB(255, 0, 0))
      
      ; TODO!

      ; PLACEHOLDER FOR ALIGNMENT GUIDES (Lazarus docking lines will be rendered here later)
;       If *GEdit\ShowXLine
;         ; Draw a vertical dotted or solid guide line (Magenta/Purple looks very professional)
;         Line(*GEdit\GuideLineX, 0, 1, GadgetHeight(#Canvas_Designer), RGB(255, 0, 255))
;       EndIf
;       
;       If *GEdit\ShowYLine
;         ; Draw a horizontal guide line
;         Line(0, *GEdit\GuideLineY, GadgetWidth(#Canvas_Designer), 1, RGB(255, 0, 255))
;       EndIf    
      
      StopDrawing()
    EndIf
    
    ; Reveal the anchors if they were hidden
    For i = 0 To 7
      If GadgetToolTip(*GEdit\AnchorIDs[i], "") ; Small sanity check
        HideGadget(*GEdit\AnchorIDs[i], #False)
      EndIf
    Next i
  EndProcedure

  ; --- Public: Clear Selection Context ---
  Procedure ClearSelection(*GEdit.TGEdit)
    Protected i.i
    If *GEdit = 0 : ProcedureReturn #False : EndIf
    
    *GEdit\TargetGadget = -1
    *GEdit\ActiveAnchor = -1
    
    ; Hide all anchor grips cleanly away
    For i = 0 To 7
      If IsGadget(*GEdit\AnchorIDs[i])
        HideGadget(*GEdit\AnchorIDs[i], #True)
      EndIf
    Next i
    
    ; Force window repaint to erase remaining gezeichnete red frames
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      InvalidateRect_(WindowID(GetActiveWindow()), 0, #True)
    CompilerEndIf
  EndProcedure

  ; --- Public: Turn Instance State On or Off ---
  Procedure SetActive(*GEdit.TGEdit, State.i, Grid.i = 8)
    If *GEdit = 0 : ProcedureReturn #False : EndIf
    *GEdit\IsActive = State
    *GEdit\GridSize = Grid
    If State = #False
      ClearSelection(*GEdit)
    EndIf
  EndProcedure
  
  ; --- Public: Hook a specific real PureBasic Gadget into the selection frame ---
  Procedure SelectGadget(*GEdit.TGEdit, GadgetID.i)
    Protected i.i
    
    If *GEdit = 0 : ProcedureReturn #False : EndIf
    
    ; 1. If target is invalid or clear requested (-1), wipe selection context cleanly
    If GadgetID = -1 Or Not IsGadget(GadgetID)
      ClearSelection(*GEdit)
      ProcedureReturn #True
    EndIf
    
    ; 2. Assign the active object ID to our object pointer
    *GEdit\TargetGadget = GadgetID
    *GEdit\ActiveAnchor = -1
    
    ; 3. Pull actual physical coordinates directly from the living OS control
    *GEdit\Preview\X = GadgetX(GadgetID)
    *GEdit\Preview\Y = GadgetY(GadgetID)
    *GEdit\Preview\W = GadgetWidth(GadgetID)
    *GEdit\Preview\H = GadgetHeight(GadgetID)
    
    ; Cache initial unsnapped dimensions to secure pure delta calculations during drags
    *GEdit\OrigObjectX = *GEdit\Preview\X
    *GEdit\OrigObjectY = *GEdit\Preview\Y
    *GEdit\OrigObjectW = *GEdit\Preview\W
    *GEdit\OrigObjectH = *GEdit\Preview\H
    
    ; 4. Make all anchor handles visible before executing positioning layout updates
    For i = 0 To 7
      If IsGadget(*GEdit\AnchorIDs[i])
        HideGadget(*GEdit\AnchorIDs[i], #False)
      EndIf
    Next i
    
    ; 5. Trigger layout routing framework to snap grips into active coordinates
    RedrawGuides(*GEdit)
    
    ProcedureReturn #True
  EndProcedure
  
  ; --- Private Helper: Snap coordinate values to the specified grid boundary ---
  Procedure.i Private_SnapToGrid(Value.i, Grid.i)
    If Grid <= 1 : ProcedureReturn Value : EndIf
    ProcedureReturn Round(Value / Grid, #PB_Round_Nearest) * Grid
  EndProcedure

; --- Public: Core Stream Handler for Intercepting Layout Events ---
  ; Call this inside your main window event loop. 
  ; Returns #True if GEdit consumed and processed the event, #False if your app should handle it.
  Procedure.i ProcessEvents(*GEdit.TGEdit, Event.i, EventGadget.i, EventType.i)
    Protected i.i
    Protected mx.i, my.i
    Protected DeltaX.i, DeltaY.i
    Protected NewX.i, NewY.i, NewW.i, NewH.i
    Protected Handled.i = #False
    
    ; Safety check: if editor is inactive, let the app handle events
    If *GEdit = 0 Or *GEdit\IsActive = #False : ProcedureReturn #False : EndIf
    
    ; Grab relative mouse positions from the active window context
    mx = WindowMouseX(GetActiveWindow())
    my = WindowMouseY(GetActiveWindow())
    
    Select Event
        
      Case #PB_Event_Gadget
        
        ; A) CHECK ANCHOR SELECTION (User clicks down on one of our 8 canvas grips)
        If EventType = #PB_EventType_LeftButtonDown
          
          ; First check if an anchor handle was clicked
          For i = 0 To 7
            If EventGadget = *GEdit\AnchorIDs[i]
              *GEdit\ActiveAnchor = i
              *GEdit\DragStartMouseX = mx
              *GEdit\DragStartMouseY = my
              
              ; Snapshot current geometric states before transformation
              *GEdit\OrigObjectX = GadgetX(*GEdit\TargetGadget)
              *GEdit\OrigObjectY = GadgetY(*GEdit\TargetGadget)
              *GEdit\OrigObjectW = GadgetWidth(*GEdit\TargetGadget)
              *GEdit\OrigObjectH = GadgetHeight(*GEdit\TargetGadget)
              
              Handled = #True
              Break
            EndIf
          Next i
          
          ; B) BODY DRAG START (If no anchor was hit, but a target gadget is active and clicked)
          ; This integrates with your PbSdk logic when selecting the item body area
          If *GEdit\ActiveAnchor = -1 And EventGadget = *GEdit\TargetGadget
            *GEdit\ActiveAnchor = 0 ; 0 represents moving the entire body area
            *GEdit\DragStartMouseX = mx - GadgetX(*GEdit\TargetGadget)
            *GEdit\DragStartMouseY = my - GadgetY(*GEdit\TargetGadget)
            
            *GEdit\OrigObjectX = GadgetX(*GEdit\TargetGadget)
            *GEdit\OrigObjectY = GadgetY(*GEdit\TargetGadget)
            *GEdit\OrigObjectW = GadgetWidth(*GEdit\TargetGadget)
            *GEdit\OrigObjectH = GadgetHeight(*GEdit\TargetGadget)
            
            Handled = #True
          EndIf
        EndIf
        
        ; C) MOUSE DRAG / TRANSFORMATION MATRIX PROCESSING
        If EventType = #PB_EventType_MouseMove And *GEdit\TargetGadget <> -1 And *GEdit\ActiveAnchor <> -1
          
          NewX = *GEdit\OrigObjectX : NewY = *GEdit\OrigObjectY
          NewW = *GEdit\OrigObjectW : NewH = *GEdit\OrigObjectH
          
          If *GEdit\ActiveAnchor = 0
            ; --- Action Type: Drag whole element layout position ---
            NewX = Private_SnapToGrid(mx - *GEdit\DragStartMouseX, *GEdit\GridSize)
            NewY = Private_SnapToGrid(my - *GEdit\DragStartMouseY, *GEdit\GridSize)
            
            *GEdit\Preview\X = NewX
            *GEdit\Preview\Y = NewY
            
            ; TODO!
            ; _CalculateAlignmentGuides(*GEdit)  ; für Linienausrichtung an anderen Gadgets OPTION
            
            ResizeGadget(*GEdit\TargetGadget, NewX, NewY, #PB_Ignore, #PB_Ignore)
            RedrawGuides(*GEdit)
            
          Else
            ; --- Action Type: Resize item transformation vector via 8 anchors ---
            DeltaX = mx - *GEdit\DragStartMouseX
            DeltaY = my - *GEdit\DragStartMouseY
            
            Select *GEdit\ActiveAnchor
              Case #Anchor_TL ; Top Left
                NewX = Private_SnapToGrid(*GEdit\OrigObjectX + DeltaX, *GEdit\GridSize)
                NewW = Private_SnapToGrid(*GEdit\OrigObjectW - (NewX - *GEdit\OrigObjectX), *GEdit\GridSize)
                NewY = Private_SnapToGrid(*GEdit\OrigObjectY + DeltaY, *GEdit\GridSize)
                NewH = Private_SnapToGrid(*GEdit\OrigObjectH - (NewY - *GEdit\OrigObjectY), *GEdit\GridSize)
              Case #Anchor_TC ; Top Center
                NewY = Private_SnapToGrid(*GEdit\OrigObjectY + DeltaY, *GEdit\GridSize)
                NewH = Private_SnapToGrid(*GEdit\OrigObjectH - (NewY - *GEdit\OrigObjectY), *GEdit\GridSize)
              Case #Anchor_TR ; Top Right
                NewW = Private_SnapToGrid(*GEdit\OrigObjectW + DeltaX, *GEdit\GridSize)
                NewY = Private_SnapToGrid(*GEdit\OrigObjectY + DeltaY, *GEdit\GridSize)
                NewH = Private_SnapToGrid(*GEdit\OrigObjectH - (NewY - *GEdit\OrigObjectY), *GEdit\GridSize)
              Case #Anchor_RC ; Right Center
                NewW = Private_SnapToGrid(*GEdit\OrigObjectW + DeltaX, *GEdit\GridSize)
              Case #Anchor_BR ; Bottom Right
                NewW = Private_SnapToGrid(*GEdit\OrigObjectW + DeltaX, *GEdit\GridSize)
                NewH = Private_SnapToGrid(*GEdit\OrigObjectH + DeltaY, *GEdit\GridSize)
              Case #Anchor_BC ; Bottom Center
                NewH = Private_SnapToGrid(*GEdit\OrigObjectH + DeltaY, *GEdit\GridSize)
              Case #Anchor_BL ; Bottom Left
                NewX = Private_SnapToGrid(*GEdit\OrigObjectX + DeltaX, *GEdit\GridSize)
                NewW = Private_SnapToGrid(*GEdit\OrigObjectW - (NewX - *GEdit\OrigObjectX), *GEdit\GridSize)
                NewH = Private_SnapToGrid(*GEdit\OrigObjectH + DeltaY, *GEdit\GridSize)
              Case #Anchor_LC ; Left Center
                NewX = Private_SnapToGrid(*GEdit\OrigObjectX + DeltaX, *GEdit\GridSize)
                NewW = Private_SnapToGrid(*GEdit\OrigObjectW - (NewX - *GEdit\OrigObjectX), *GEdit\GridSize)
            EndSelect
            
            ; Enforce boundary layout protection rules
            If NewW >= *GEdit\GridSize And NewH >= *GEdit\GridSize
              *GEdit\Preview\X = NewX : *GEdit\Preview\Y = NewY
              *GEdit\Preview\W = NewW : *GEdit\Preview\H = NewH
              
              ResizeGadget(*GEdit\TargetGadget, NewX, NewY, NewW, NewH)
              RedrawGuides(*GEdit)
            EndIf
          EndIf
          
          Handled = #True
        EndIf
        
        ; D) RELEASE TRANSFORM STATE (User lifts left click over an anchor or body area)
        If EventType = #PB_EventType_LeftButtonUp And *GEdit\ActiveAnchor <> -1
          *GEdit\ActiveAnchor = -1
          RedrawGuides(*GEdit)
          Handled = #True
        EndIf
        
    EndSelect
    
    ProcedureReturn Handled
  EndProcedure  
   
  ; --- Public: Free all allocated components cleanly ---
  Procedure FreeEditor(*GEdit.TGEdit)
    Protected i.i
    If *GEdit = 0 : ProcedureReturn #False : EndIf
    ClearSelection(*GEdit)
    For i = 0 To 7
      If IsGadget(*GEdit\AnchorIDs[i])
        FreeGadget(*GEdit\AnchorIDs[i])
      EndIf
    Next i
  EndProcedure

EndModule


CompilerIf #False
  ;In deiner Event-Schleife nutzt du nun deine PbSdk-Erkennung. Klickt der User
  ;ein Element an, sagst du dem Modul, welches Gadget aktiv sein soll:
  ; Inside your main application loop
  
  ; --- Inside your main application event loop ---
  Repeat
    Define Event.i       = WaitWindowEvent()
    Define EventGadget.i = EventGadget()
    Define EventType.i   = EventType()
    
    ; 1. Let the GEdit module process active dragging and resizing automatically
    If GEdit::ProcessEvents(@MyEditor, Event, EventGadget, EventType)
      Continue ; Event was handled by the editor framework, skip app processing
    EndIf
    
    ; 2. Handle component selection when a left click occurs in Edit Mode
    If MyEditor\IsActive And Event = #PB_Event_Gadget And EventType = #PB_EventType_LeftButtonDown
      
      ; Use your SDK combination to instantly find the PB ID under the mouse pointer
      Define HoverHandle.i = PbSdk::CheckMouseOver()
      If HoverHandle
        Define ClickedGadgetNo.i = PbSdk::GadgetPB(HoverHandle)
        
        ; If a valid gadget was found and it's not already selected, target it!
        If ClickedGadgetNo >= 0 And ClickedGadgetNo <> MyEditor\TargetGadget
          GEdit::SelectGadget(@MyEditor, ClickedGadgetNo)
        EndIf
      EndIf
      
    EndIf
    
    ; Your normal non-edit mode application events continue here...
  Until Event = #PB_Event_CloseWindow  
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 223
; FirstLine = 201
; Folding = ---
; DPIAware
; CPU = 5