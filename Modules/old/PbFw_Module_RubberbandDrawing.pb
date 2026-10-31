; ===========================================================================
;  FILE: PbFw_Module_RubberbandDrawing.pb
;  NAME: Module RubberbandDrawing [RBDrw::]
;  DESC: 
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/08/19
; VERSION  :  0.0 Brainstorming version 
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
; 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
; XIncludeFile ""

DeclareModule RBDrw  ; RubberBandDraw
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  Enumeration EOutputType
    #RB_CanvasOutput
    #RB_ImageOutput
    #RB_WindowOutput
  EndEnumeration
    
  Structure TRubberBand
    X1.d
    Y1.d
    X2.d
    Y2.d
    Image.i
    Start.i
    OutPutType.i
    PbNo.i
    Col.l
  EndStructure
  
  Declare.i RBStart(*hRBD.TRubberBand, PbNo, OutPutType = #RB_CanvasOutput, GetMouseStart=#True) 
  Declare.i RBStop(*hRBD.TRubberBand)
  
  Declare.i RBDraw_Line(*hRBD.TRubberBand) 
  Declare.i RBDraw_Rect(*hRBD.TRubberBand)
  Declare.i RBDraw_Circle(*hRBD.TRubberBand)
  
EndDeclareModule



Module RBDrw  ; RubberBandDraw
  
  Prototype RB_EventCallBack_(X1.d, Y1.d, X2.d, Y2.d)
  Global RB_EventCallBack.RB_EventCallBack_
  
  ; private
  Procedure RB_StartVectorDrawing_(PbNo, OutPutType)
  ; ============================================================================
  ; NAME: RB_StartVectorDrawing_
  ; DESC: Private function to start VectorDrawing
  ; VAR(PbNo): PureBasic No for: Canvas: #Gadget, Window: #Window, Image: #Image 
  ; VAR(OutPutType =#RB_CanvasOutput): Canvas, Window or Image Output
  ; RET.i : #True if Vectordrawing successfully started
  ; ============================================================================
  
    Select OutPutType
      Case #RB_CanvasOutput
        StartVectorDrawing(CanvasVectorOutput(PbNo))
        Debug "StartVectorDrawing (CanvasOutput(" +Str(PbNo) + ") )"
        
      Case #RB_ImageOutput
        StartVectorDrawing(ImageVectorOutput(PbNo))
        
      Case #RB_WindowOutput
        StartVectorDrawing(WindowVectorOutput(PbNo))
        
      Default
        ProcedureReturn #False
      EndSelect
    
    ProcedureReturn #True
  EndProcedure
  
  ; private
  Procedure RB_GetMouse_(PbNo, OutPutType, *MouseX.Double, *MouseY.Double)
  ; ============================================================================
  ; NAME: RB_GetMouse_
  ; DESC: Private function to get actual Mouse position
  ; VAR(PbNo): PureBasic No for: Canvas: #Gadget, Window: #Window, Image: #Image 
  ; VAR(OutPutType =#RB_CanvasOutput): Canvas, Window or Image Output
  ; VAR(*MouseX.Double): Pointer to Mouse-X As Double
  ; VAR(*MouseY.Double): Pointer to Mouse-Y As Double   
  ; RET.i : #True if Vectordrawing successfully started
  ; ============================================================================
   
    If *MouseX And *MouseY        
      Select OutPutType
        Case #RB_CanvasOutput
          *MouseX\d = GetGadgetAttribute(PbNo, #PB_Canvas_MouseX) 
          *MouseY\d = GetGadgetAttribute(PbNo, #PB_Canvas_MouseY) 
         
        Case #RB_ImageOutput
          ExamineMouse()
          *MouseX\d = MouseX()
          *MouseY\d = MouseY()
          
        Case #RB_WindowOutput
          ; ExamineMouse()
          *MouseX\d = WindowMouseX(PbNo)
          *MouseY\d = WindowMouseY(PbNo)
    
      EndSelect
    EndIf
   
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i RBStart(*hRBD.TRubberBand, PbNo, OutPutType =#RB_CanvasOutput, GetMouseStart=#True)   
  ; ============================================================================
  ; NAME: RBStart
  ; DESC: Start Rubberband Drawing
  ; VAR(*hRBD.TRubberBand): Handle RubberBand Data Structure
  ; VAR(PbNo): PureBasic No for: Canvas: #Gadget, Window: #Window, Image: #Image 
  ; VAR(OutPutType =#RB_CanvasOutput): Canvas, Window or Image Output
  ; RET.i : #True if successfully started
  ; ============================================================================

    Protected ret 
    
    If Not *hRBD
      ProcedureReturn #False
    EndIf
                  
    Select OutPutType
        
      ; Attention: for shoting a foto of the actual screen, we have to use  
      ; 2D-Drawing function. 
      ; We use StartDrawing (VectorDrawing is not possible)
      Case #RB_CanvasOutput
        
        If IsGadget(PbNo)
          If GadgetType(PbNo) = #PB_GadgetType_Canvas           
              If StartDrawing(CanvasOutput(PbNo))
              ret = #True
              Debug "CanvasOutput(" +Str(PbNo) + ")"
            EndIf
          EndIf
        EndIf
        
      Case #RB_ImageOutput
        
        If IsImage(PbNo)
          If StartDrawing(ImageOutput(PbNo))
            ret = #True
            Debug "ImageOutput(" +Str(PbNo) + ")"
          EndIf
       EndIf
        
     Case #RB_WindowOutput
       
       If IsWindow(PbNo)           
        If StartDrawing(WindowOutput(PbNo))
          ret = #True
          Debug "WindowOutput(" +Str(PbNo) + ")"
       EndIf
      EndIf
      
      Default
        ProcedureReturn #False
        
    EndSelect
      
    If ret
      With *hRBD
        If GetMouseStart
          RB_GetMouse_(PbNO, OutPutType, @\X1, @\Y1)
        EndIf
      
        \OutPutType = OutPutType
        \PbNo = PbNo
        \Start = #True
        \Image = GrabDrawingImage(#PB_Any, 0, 0, OutputWidth(), OutputHeight())
        StopDrawing()    

      EndWith
    EndIf
          
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i RBStop(*hRBD.TRubberBand)
  ; ============================================================================
  ; NAME: RBStop
  ; DESC: Stop Rubberband Drawing
  ; VAR(*hRBD.TRubberBand): Handle RubberBand Data Structure
  ; RET.i : #True
  ; ============================================================================
    Debug "Stop"
    
    With *hRBD
      If \Start
        \Start=#False
        
        RB_StartVectorDrawing_(\PbNo, \OutPutType)
        DrawVectorImage(ImageID(\Image))
        StopVectorDrawing()
        FreeImage(\Image)
        
        ProcedureReturn #True
      EndIf
    EndWith  
  
    ProcedureReturn #False
  EndProcedure

  Procedure.i RBDraw_Line(*hRBD.TRubberBand) ; call when MouseMove
  ; ============================================================================
  ; NAME: RBDraw_Line
  ; DESC: Rubberband Drawing a line
  ; VAR(*hRBD.TRubberBand): Handle RubberBand Data Structure
  ; RET.i : #True
  ; ============================================================================
    Debug "Draw"
    
    With *hRBD  
      If \Start=#True
         RB_GetMouse_(\PbNo, \OutPutType, @\X2, @\Y2)
        ; neue Mausposition
          
        ;Zuerst das vorige Bild, dann den typischen Strichelrahmen
        RB_StartVectorDrawing_(\PbNo, \OutPutType)
        DrawVectorImage(ImageID(\Image))
        
        MovePathCursor(\X1, \Y1)
        AddPathLine(\X2, \Y2)
        
        VectorSourceColor($ffFF0000)
        ;FillPath()
        DashPath(1,5)
       ; DotPath(1,5)
        StopVectorDrawing()
      EndIf
    EndWith
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i RBDraw_Rect(*hRBD.TRubberBand) ; call when MouseMove
  ; ============================================================================
  ; NAME: RBDraw_Rect
  ; DESC: Rubberband Drawing a rectangle
  ; VAR(*hRBD.TRubberBand): Handle RubberBand Data Structure
  ; RET.i : #True
  ; ============================================================================
   Debug "Draw"
    
    With *hRBD  
      If \Start=#True
         RB_GetMouse_(\PbNo, \OutPutType, @\X2, @\Y2)
        ; neue Mausposition
          
        ;Zuerst das vorige Bild, dann den typischen Strichelrahmen
        RB_StartVectorDrawing_(\PbNo, \OutPutType)
        DrawVectorImage(ImageID(\Image))
        
        AddPathBox(\X1, \Y1, \X2-\X1, \Y2-\Y1)
         VectorSourceColor($ffFF0000)
        ;FillPath()
        DashPath(1,5)
       ; DotPath(1,5)
        StopVectorDrawing()
      EndIf
    EndWith
    
  EndProcedure
  
  Procedure.i RBDraw_Circle(*hRBD.TRubberBand) ; call when MouseMove
  ; ============================================================================
  ; NAME: RBDraw_Circle
  ; DESC: Rubberband Drawing a circle
  ; VAR(*hRBD.TRubberBand): Handle RubberBand Data Structure
  ; RET.i : #True
  ; ============================================================================
    Debug "Draw"
    
    With *hRBD  
      If \Start=#True
         RB_GetMouse_(\PbNo, \OutPutType, @\X2, @\Y2)
        ; neue Mausposition
          
        ;Zuerst das vorige Bild, dann den typischen Strichelrahmen
        RB_StartVectorDrawing_(\PbNo, \OutPutType)
        DrawVectorImage(ImageID(\Image))
        
        ;AddPathBox(x1, y1, x2-x1, y2-y1)
        MovePathCursor(\X1, \Y1)
        AddPathLine(\X2, \Y2)
        
        Protected r, dx, dy
        dx = Abs(\X2 - \X1) 
        dy = Abs(\Y2 - \Y1)
       
        r= Sqr(dx*dx + dy*dy)
        
        AddPathCircle(\X1, \Y1, r)
        VectorSourceColor($ffFF0000)
        ;FillPath()
        DashPath(1,5)
       ; DotPath(1,5)
        StopVectorDrawing()
      EndIf
    EndWith
    
  EndProcedure
 
EndModule

CompilerIf #PB_Compiler_IsMainFile
 ;- ----------------------------------------------------------------------
 ;-  M O D U L E   T E S T   C O D E
 ;-  ---------------------------------------------------------------------- 
 
  ;UseModule RBDrw
  
  Global hRB.RBDrw::TRubberBand
  Global PolyLineStart
  
  Procedure Draw()
    
    With hRB
      StartVectorDrawing(CanvasVectorOutput(\PbNo))
      MovePathCursor(\X1, \Y1)
      AddPathLine(\X2, \Y2)
      
      VectorSourceColor($ffFF0000)
      StrokePath(1)
      StopVectorDrawing()
    EndWith
  EndProcedure
  
  Procedure Window_Event()
    
         
    Select EventType()
      
      Case #PB_EventType_LeftDoubleClick
        ; Stop Multiline Drawing
        PolyLineStart = #False 
        
      Case #PB_EventType_LeftClick
       
        If hRB\Start  
          
           If RBDrw::RBStop(hRB)
            Draw()
          EndIf
          
        Else
          
          RBDrw::RBStart(hRB, 1, RBDRW::#RB_CanvasOutput, #True)
          
        EndIf
                
      Case #PB_EventType_MouseMove
        ;RBDrw::RBDraw_Circle(RB)
        ;RBDrw::RBDraw_Rect(RB)
        RBDrw::RBDraw_Line(hRB)        
      
    EndSelect
                 
  EndProcedure

  
  Procedure Canvas_Event()
    
    Select EventType()
        
      Case #PB_EventType_LeftDoubleClick
        ; Stop Multiline Drawing
        PolyLineStart = #False 
        
      Case #PB_EventType_LeftClick
        
        If hRB\Start  
          
           If RBDrw::RBStop(hRB)
            Draw()
          EndIf
          
        Else
          
          RBDrw::RBStart(hRB, 1, RBDRW::#RB_CanvasOutput, #True)
          
        EndIf
                
      Case #PB_EventType_MouseMove
        ;RBDrw::RBDraw_Circle(RB)
        ;RBDrw::RBDraw_Rect(RB)
        RBDrw::RBDraw_Line(hRB)        
        
    EndSelect
    
  EndProcedure
  
  OpenWindow(1, 10, 10, 640, 480, "")
  CanvasGadget(1, 0, 0, WindowWidth(1)/2, WindowHeight(1)/2, #PB_Canvas_Keyboard|#PB_Canvas_ClipMouse|#PB_Canvas_Border)
  
  SetGadgetAttribute(1, #PB_Canvas_Cursor, #PB_Cursor_Cross)
  
;   If StartDrawing(CanvasOutput(1))
;     Box(10, 10, 200, 100, #Green)
;     DrawingMode(#PB_2DDrawing_XOr)
;     Box(100, 50, 500, 400, #Blue)
;     DrawingMode(#PB_2DDrawing_Default)
;     Circle(350, 250, 100, #Red)
;     StopDrawing()
;   EndIf
  
  Repeat
    Event=WaitWindowEvent()
    
    Select Event
        
      Case  #PB_Event_Gadget
        
        Select EventGadget()
          Case 1
            Canvas_Event()
           
        EndSelect
        
      Default 
        Window_Event()    
    EndSelect
    
  Until Event=#PB_Event_CloseWindow
  
  Debug "ID = " + Str(CanvasVectorOutput(1))
CompilerEndIf

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 313
; FirstLine = 96
; Folding = ---
; Optimizer
; CPU = 5