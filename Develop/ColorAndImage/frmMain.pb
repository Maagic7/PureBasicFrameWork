
;XIncludeFile "frmImage.pb"

DeclareModule frmMain
  EnableExplicit
    
  Structure TThis
    wndPB.i
  EndStructure
  
  Declare.i New(wndPB_Parent = #PB_Default)
  Declare.i Destroy(*This.TThis)
  Declare.i Resize(*This.TThis)
  Declare.i Update(*This.TThis)
  Declare.i Events(*This.TThis, Event)
  
  Enumeration eMenu
    ; --------------------------------------------------
    ; MENU "File"
    ; --------------------------------------------------
    #MENU_FILE_Open
    #MENU_FILE_Close
    #MENU_FILE_CloseAll
    #MENU_FILE_Quit
    
    ; --------------------------------------------------
    ; MENU "Edit"
    ; --------------------------------------------------
     
    ; --------------------------------------------------
    ; MENU "Window"
    ; --------------------------------------------------
    #MENU_WINDOW_TileV
    #MENU_WINDOW_TileH
    #MENU_WINDOW_Cascade
    #MENU_WINDOW_Arrange
    #MENU_WINDOW_Previous
    #MENU_WINDOW_Next   
  EndEnumeration

EndDeclareModule


Module frmMain
  EnableExplicit
  
  Structure TImages
    imgPB.i
    *frmImage
  EndStructure
  
  Global NewList lstImages.TImages()
  
  ;- ------------------------------
  ;- Private Functions
  ;- ------------------------------
  Procedure _Load_Image(*This.TThis)
    Protected FileName$, DefaultFile$, imgPB, *frmImg
    
    FileName$ = OpenFileRequester("Open Image", DefaultFile$, "Image Files (*.bmp,*.jpg,*.tiff,*.png,*.tga,*.gif)|*.bmp;*.jpg;*.tiff;*.png;*.tga;*.gif|All Files (*.*)|*.*", 0, #PB_Requester_MultiSelection)
    
    While FileName$
      DefaultFile$ = FileName$
      
      imgPB = LoadImage(#PB_Any, FileName$)
      ; Debug Image
      
      If imgPB
        *frmImg = frmImage::New(imgPB, *This\wndPB) ; open New Image Form with the Image
        If *frmImg
          AddElement(lstImages())
          lstImages()\imgPB=imgPB
          lstImages()\frmImage=*frmImg  
        Else 
          FreeImage(imgPB)
        EndIf
 
      Else
        MessageRequester("Image Viewer","Could not load image: "+FileName$)
      EndIf            
      
      FileName$ = NextSelectedFilename()
    Wend
  EndProcedure
  
  ;- ------------------------------
  ;- Public Methodes
  ;- ------------------------------

  Procedure.i New(wndPB_Parent = #PB_Default)
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
    
    *obj = AllocateStructure(TThis)
    
    If *obj
      ExamineDesktops()
      
      _h = DesktopHeight(0) / 2
      _w = DesktopWidth(0) / 2
      _x=0 
      _y=0
      
      If wndPB_Parent<>#PB_Default
        If IsWindow(wndPB_Parent) 
          ParentID=WindowID(wndPB_Parent)
        EndIf      
      EndIf
      
      _wndFlags = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered
         
      wndPB=OpenWindow(#PB_Any, _x, _y, _w, _h, "Image and Color Develop", _wndFlags, ParentID)
     
      
      If wndPB
        CreateMenu(#PB_Any, WindowID(wndPB))
        
        *obj\wndPB = wndPB
        ; --------------------------------------------------
        ; MENU "File"
        ; --------------------------------------------------
        With *obj
          MenuTitle("File")
          MenuItem(#MENU_FILE_Open, "Open")
          MenuItem(#MENU_FILE_Close, "Close")
          MenuItem(#MENU_FILE_CloseAll, "Close All")
          MenuBar()
          MenuItem(#MENU_FILE_Quit, "Quit")      
                      
          ; --------------------------------------------------
          ; MENU "Window"
          ; --------------------------------------------------
          MenuTitle("Windows")
          MenuItem(#MENU_WINDOW_TileV, "Tile vertically")
          MenuItem(#MENU_WINDOW_TileH, "Tile horizontally")
          MenuItem(#MENU_WINDOW_Cascade, "Cascade")
          MenuItem(#MENU_WINDOW_Previous, "Previous")
          MenuItem(#MENU_WINDOW_Next, "Next")
        EndWith
      Else
        FreeStructure(*obj)  
      EndIf     
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
    EndWith
    
    ProcedureReturn *This      
  EndProcedure
  
  Procedure.i Update(*This.TThis)
  ; ======================================================================
  ; NAME: Update  
  ; DESC: Update routine. Implement your personal code here
  ; DESC: Call it: ModuleName::Update(*myFrm)  
  ; RET.i:  
  ; ======================================================================
    
  EndProcedure
  
  Procedure Events(*This.TThis, Event)
  ; ======================================================================
  ; NAME: Events  
  ; DESC: The forms Event Proc
  ; DESC: Call it: ModuleName::Events(*myFrm)  
  ; RET.i: 0 
  ; ======================================================================
    Protected Quit, memImgNo
    Protected wndPB = EventWindow()
    
      If wndPB= *This\wndPB
        
        Select Event
          Case  #PB_Event_CloseWindow                
            Destroy(*This)
            Quit = #True
            
          Case #PB_Event_SizeWindow      
            
          Case #PB_Event_MoveWindow      
            
          Case #PB_Event_MoveWindow      
            
          Case #PB_Event_MinimizeWindow  
            
          Case #PB_Event_MaximizeWindow 
            
          Case #PB_Event_MaximizeWindow   
            
          Case #PB_Event_Repaint  
            
          Case  #PB_Event_Menu            
        EndSelect
        
      Else
        ForEach lstImages()
          If wndPB = lstImages()\frmImage
            memImgNo = lstImages()\imgPB
            
            Quit = frmImage::Events(lstImages()\frmImage, Event)  
            
            If Quit
              FreeImage(memImgNo)
              DeleteElement(lstImages())    
            EndIf
            
          EndIf
          
        Next
        
      EndIf
      
  
    ProcedureReturn Quit
  EndProcedure
  

EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 64
; Folding = --
; DPIAware
; CPU = 5