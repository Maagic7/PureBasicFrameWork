; ===========================================================================
;  FILE: PbFw_Module_RubberbandDrawing.pb
;  NAME: Module RubberbandDrawing [RBDrw::]
;  DESC: Rubberband drawing on a Cnavas Gadget
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
XIncludeFile "PbFw_Module_VDraw.pb"        ; VDraw::    Vector Drawing Module

DeclareModule RBDrw  ; RubberBandDraw
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
      
  Structure TRubberBand
    X1.d
    Y1.d
    X2.d
    Y2.d
    Image.i
    Start.i
    PbNo.i
    Col.l
  EndStructure
  
  Declare.i RBStart(*hRBD.TRubberBand, PbNo, GetMouseStart=#True) 
  Declare.i RBStop(*hRBD.TRubberBand)
  
  Declare.i RBDraw_Line(*hRBD.TRubberBand) 
  Declare.i RBDraw_Rect(*hRBD.TRubberBand)
  Declare.i RBDraw_Circle(*hRBD.TRubberBand)
  
EndDeclareModule

Module RBDrw  ; RubberBandDraw  
    
  Procedure.i RBStart(*hRBD.TRubberBand, PbNo, GetMouseStart=#True)   
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
                  
         
    ; Attention: for shoting a foto of the actual screen, we have to use  
    ; 2D-Drawing function. 
    ; We use StartDrawing (VectorDrawing is not possible)
        
    If IsGadget(PbNo)
      If GadgetType(PbNo) = #PB_GadgetType_Canvas           
        
        If StartDrawing(CanvasOutput(PbNo))
          ret = #True
          With *hrBd  
            \X1 = GetGadgetAttribute(PbNo, #PB_Canvas_MouseX) 
            \Y1 = GetGadgetAttribute(PbNo, #PB_Canvas_MouseY) 
             \PbNo = PbNo
            \Start = #True
            \Image = GrabDrawingImage(#PB_Any, 0, 0, OutputWidth(), OutputHeight())
          EndWith
          StopDrawing()   
        EndIf
        
      EndIf
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
    Protected ret
    
    With *hRBD
      
      If \Start
        \Start=#False
      
        If StartVectorDrawing(CanvasVectorOutput(\PbNo))
          DrawVectorImage(ImageID(\Image))
          StopVectorDrawing()
          FreeImage(\Image)
        EndIf
      
        ret= #True
      EndIf
    EndWith  
  
    ProcedureReturn ret
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
        \X2 = GetGadgetAttribute(\PbNo, #PB_Canvas_MouseX) 
        \Y2 = GetGadgetAttribute(\PbNo, #PB_Canvas_MouseY) 
           
        If StartVectorDrawing(CanvasVectorOutput(\PbNo))
          DrawVectorImage(ImageID(\Image))
        
          MovePathCursor(\X1, \Y1)
          AddPathLine(\X2, \Y2)
        
          VectorSourceColor($ffFF0000)
          DashPath(1,5)
          StopVectorDrawing()
        EndIf
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
        \X2 = GetGadgetAttribute(\PbNo, #PB_Canvas_MouseX) 
        \Y2 = GetGadgetAttribute(\PbNo, #PB_Canvas_MouseY) 
           
        If StartVectorDrawing(CanvasVectorOutput(\PbNo))
          DrawVectorImage(ImageID(\Image))
        
          AddPathBox(\X1, \Y1, \X2-\X1, \Y2-\Y1)
          VectorSourceColor($ffFF0000)
          DashPath(1,5)
          StopVectorDrawing()
        EndIf
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
        \X2 = GetGadgetAttribute(\PbNo, #PB_Canvas_MouseX) 
        \Y2 = GetGadgetAttribute(\PbNo, #PB_Canvas_MouseY) 
           
        If StartVectorDrawing(CanvasVectorOutput(\PbNo))
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
          DashPath(1,5)
          StopVectorDrawing()
        EndIf
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
          
          RBDrw::RBStart(hRB, 1, #True)
          
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
        
    EndSelect
    
  Until Event=#PB_Event_CloseWindow
  
  Debug "ID = " + Str(CanvasVectorOutput(1))
CompilerEndIf

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 308
; FirstLine = 202
; Folding = ---
; Optimizer
; CPU = 5