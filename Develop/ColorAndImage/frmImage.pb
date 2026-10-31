

DeclareModule frmImage
  EnableExplicit
  
  Structure TThis  
    wndPB.i     ; Our Window  
    
    ; info about the loaded image
    Image.i
    ImageGifAnimated.i
    ; gadget numbers
    ScrollAreaGadget.i
    ImageGadget.i
  EndStructure
  
  Declare.i New(ImgNo, wndPB_Parent = #PB_Default)
  Declare.i Destroy(*This.TThis)
  Declare.i Resize(*This.TThis)
  Declare.i Update(*This.TThis)
  Declare.i Events(*This.TThis, Event)

EndDeclareModule


Module frmImage
  EnableExplicit
  
  ;- ------------------------------
  ;- Private Functions
  ;- ------------------------------
  
  Procedure _Event_ImageGadget(EventType)
    Select EventType
      Case #PB_EventType_LeftClick        
        
      Case #PB_EventType_RightClick       
        
      Case #PB_EventType_LeftDoubleClick  
        
      Case #PB_EventType_RightDoubleClick 
        
      Case #PB_EventType_Focus            
        
      Case #PB_EventType_LostFocus        
        
      Case #PB_EventType_Change    
        
      Case #PB_EventType_DragStart        
        
    EndSelect
    
  EndProcedure
  
  ;- ------------------------------
  ;- Public Methodes
  ;- ------------------------------
  
  Procedure.i New(ImgNo, wndPB_Parent = #PB_Default)
  ; ======================================================================
  ; NAME: New  
  ; DESC: Create a New Instance of the Form
  ; DESC: Call it: *myFrm=ModuleName::NEW()  
  ; RET.i: *This; The Pointer to the allocated memory or 0 if 
  ;        could not get the memory from OS
  ; ======================================================================
    Protected *obj.TThis
    Protected wndPB, ParentID
    Protected _x, _y, _w, _h, _wndFlags      
    
    If Not IsImage(ImgNo)
      ProcedureReturn 0  
    EndIf
    
    *obj = AllocateStructure(TThis)
    
    If *obj
      With *obj
        If wndPB_Parent<>#PB_Default
          If IsWindow(wndPB_Parent) 
            ParentID=WindowID(wndPB_Parent)
            _x = WindowX(wndPB_Parent, #PB_Window_InnerCoordinate) 
            _y = WindowY(wndPB_Parent, #PB_Window_InnerCoordinate)
            _w = WindowWidth(wndPB_Parent, #PB_Window_InnerCoordinate)
            _h = WindowHeight(wndPB_Parent, #PB_Window_InnerCoordinate)
          EndIf      
        EndIf
  
        #_wndFlags = #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_Tool
        wndPB=OpenWindow(#PB_Any, _x, _y, _w, _h, "Image Editor", #_wndFlags, ParentID)
        
        If wndPB
          \wndPB = wndPB
          _x = WindowX(wndPB, #PB_Window_InnerCoordinate) 
          _y = WindowY(wndPB, #PB_Window_InnerCoordinate)
          _w = WindowWidth(wndPB, #PB_Window_InnerCoordinate)
          _h = WindowHeight(wndPB, #PB_Window_InnerCoordinate)
          
          \ImageGadget=ImageGadget(#PB_Any, _x, _y, _w, _h, ImageID(ImgNo))
          \ScrollAreaGadget = ScrollAreaGadget(#PB_Any, 0, 0, _w, _h, ImageWidth(ImgNo), ImageHeight(ImgNo), 10)

          *obj\wndPB = wndPB
        Else
          FreeStructure(*obj)         
        EndIf     
      EndWith
    EndIf
    
    ProcedureReturn *obj
  EndProcedure
  
  Procedure.i Destroy(*This.TThis)
  ; ======================================================================
  ; NAME: Destroy  
  ; DESC: Destroy the Form
  ; DESC: Call it: *myFrm=ModuleName::Destroy(*myFrm)  
  ; RET.i: 0 
  ; ======================================================================
    CloseWindow(*This\wndPB)
    FreeStructure(*This)
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i Resize(*This.TThis)
  ; ======================================================================
  ; NAME: Resize  
  ; DESC: Resize the Form. Implement your resize code here
  ; DESC: Call it: ModuleName::Resize(*myFrm)  
  ; RET.i: 0 
  ; ======================================================================
    Protected x, y, w, h
    With *This
      x = WindowX(\wndPB, #PB_Window_InnerCoordinate) 
      y = WindowY(\wndPB, #PB_Window_InnerCoordinate)
      w = WindowWidth(\wndPB, #PB_Window_InnerCoordinate)
      h = WindowHeight(\wndPB, #PB_Window_InnerCoordinate)
      ResizeGadget(\ImageGadget, 0, 0, w, h)
    EndWith
  
    ResizeGadget(*This\ImageGadget, x,y,w,h)
    
    ProcedureReturn *This
  EndProcedure
  
  Procedure.i Update(*This.TThis)
  ; ======================================================================
  ; NAME: Update  
  ; DESC: Update routine. Implement your personal code here
  ; DESC: Call it: ModuleName::Update(*myFrm)  
  ; RET.i:  
  ; ======================================================================
    SetGadgetState(*This\ImageGadget, GetGadgetState(*This\ImageGadget))
    ProcedureReturn *This
  EndProcedure
  
  Procedure Events(*This.TThis, Event)
  ; ======================================================================
  ; NAME: Events  
  ; DESC: The forms Event Proc
  ; DESC: Call it: ModuleName::Events(*myFrm)  
  ; RET.i: 0 
  ; ======================================================================
    Protected Quit
    Protected NoGadget, evtType
    
    Select Event
      Case #PB_Event_CloseWindow
        Destroy(*This)   
        Quit = #True
        
      Case #PB_Event_SizeWindow      
        
      Case #PB_Event_MoveWindow      
        
      Case #PB_Event_MoveWindow      
        
      Case #PB_Event_MinimizeWindow  
        
      Case #PB_Event_MaximizeWindow 
        
      Case #PB_Event_MaximizeWindow   
        
      Case #PB_Event_Repaint  
        
      Case #PB_Event_Menu
        
      Case #PB_Event_Gadget
        NoGadget = EventGadget()
        evtType = EventType()
        
        If NoGadget = *This\ImageGadget
          _Event_ImageGadget(evtType)         
        EndIf
        
    EndSelect
    
    ProcedureReturn *This
  EndProcedure
  

EndModule

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 172
; FirstLine = 36
; Folding = --
; DPIAware
; CPU = 5