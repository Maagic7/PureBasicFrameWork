
XIncludeFile "..\..\Modules\PbFw_Module_Props.pb"

; =====================================================================
; Module Name:  PropsEditor (Single Event-Loop Compatible Version)
; Description:  Provides a tree navigation GUI that runs safely inside
;               the application's single main event loop.
; Style:        PascalCase Structures, English comments and naming.
; =====================================================================

DeclareModule PropsEditor
  EnableExplicit
  ;- Constants for Windows & Gadgets
  #Win_Editor = 100
  
 Enumeration EditorGadgets
    #G_Tree_Nav = 100
    #G_Scroll_Edit       ; CHANGED: ScrollArea instead of Container for flexible splitting
    #G_Splitter          ; NEW: Splitter separating left tree and right panel
    #G_Status            ; NEW: Statusbar at the bottom
    
    #G_Txt_Key
    #G_Txt_Flags
    
    ; --- The 2 Universal Input Fields ---
    #G_Lbl_Value
    #G_Input_String
    
    #G_Lbl_Text
    #G_Input_Text
    
    ; --- RECT Inputs ---
    #G_Lbl_Rect
    #G_Input_RectX
    #G_Input_RectY
    #G_Input_RectW
    #G_Input_RectH
    
    ; --- Action Triggers ---
    #G_Btn_Action
    #G_Canvas_ColorPreview
    #G_Btn_Save
    #G_Btn_Cancel
  EndEnumeration
  ;- Public Interface Procedures
  Declare.i Open(*Bag.Props::TPropBag, ParentWindow.i = 0)
  Declare.i ProcessEvent(Event.i)
  Declare.i IsOpen()
  
EndDeclareModule

Module PropsEditor
  EnableExplicit
  ;- Private Globals
  Global *ActiveBag.Props::TPropBag 
  Global *ActiveItem.Props::TPropItem
  Global ActiveKey.s
  Global IsEditorVisible.i
  
   ; ======================================================================
  ; NAME : HideAllEditorGadgets
  ; DESC : Internal helper to reset the visibility status of the workspace
  ; ======================================================================
  Procedure HideAllEditorGadgets()
    HideGadget(#G_Lbl_Value, #True)
    HideGadget(#G_Input_String, #True)
    HideGadget(#G_Lbl_Text, #True)
    HideGadget(#G_Input_Text, #True)
    HideGadget(#G_Lbl_Rect, #True)
    HideGadget(#G_Input_RectX, #True) : HideGadget(#G_Input_RectY, #True)
    HideGadget(#G_Input_RectW, #True) : HideGadget(#G_Input_RectH, #True)
    HideGadget(#G_Btn_Action, #True)
    HideGadget(#G_Canvas_ColorPreview, #True)
  EndProcedure
  
  ; ======================================================================
  ; NAME : RefreshList
  ; DESC : Internal helper to clear and reload the Tree Navigation
  ; ======================================================================
   Procedure RefreshList()
    Protected idx.i
    If Not *ActiveBag : ProcedureReturn : EndIf
    Props::BuildTree(*ActiveBag, #G_Tree_Nav)
    For idx = 0 To CountGadgetItems(#G_Tree_Nav) - 1
      SetGadgetItemState(#G_Tree_Nav, idx, #PB_Tree_Expanded)
    Next idx
  EndProcedure

  ; ======================================================================
  ; NAME : Open
  ; DESC : Initializes and displays the Editor Window without blocking code execution
  ; ======================================================================
  Procedure.i Open(*Bag.Props::TPropBag, ParentWindow.i = 0)
    Protected WinWidth.i = 750, WinHeight.i = 460, WindowFlags.i
    
    If Not *Bag : ProcedureReturn #False : EndIf
    
    *ActiveBag = *Bag
    *ActiveItem = 0
    ActiveKey = ""
    
    ; NEW: Added #PB_Window_SizeGadget and #PB_Window_MaximizeGadget for resizing support
    WindowFlags = #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_WindowCentered | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget
    
    If OpenWindow(#Win_Editor, #PB_Ignore, #PB_Ignore, WinWidth, WinHeight, "Universal Property Tree Configuration Center", WindowFlags, ParentWindow)
      
      ; Create the two child controls for the splitter first (without absolute positions, splitter handles it)
      TreeGadget(#G_Tree_Nav, 0, 0, 0, 0, #PB_Tree_AlwaysShowSelection)
      
      ; CHANGED: ScrollAreaGadget ensures controls remain accessible when the splitter is moved tightly
      ScrollAreaGadget(#G_Scroll_Edit, 0, 0, 0, 0, 415, 350, 10, #PB_ScrollArea_BorderLess)
        TextGadget(#G_Txt_Key, 10, 10, 395, 25, "Select an item...", #PB_Text_Border)
        TextGadget(#G_Txt_Flags, 10, 45, 395, 25, "", #PB_Text_Border) 
        
        TextGadget(#G_Lbl_Value, 10, 80, 395, 15, "Property Value (Value$):")
        StringGadget(#G_Input_String, 10, 95, 395, 25, "")
        
        TextGadget(#G_Lbl_Text, 10, 130, 395, 15, "Property Context / Message Text (Text$):")
        EditorGadget(#G_Input_Text, 10, 145, 395, 85)
        
        TextGadget(#G_Lbl_Rect, 10, 240, 395, 15, "Layout Boundaries (X / Y / W / H):")
        StringGadget(#G_Input_RectX, 10,  260, 85, 25, "", #PB_String_Numeric)
        StringGadget(#G_Input_RectY, 105, 260, 85, 25, "", #PB_String_Numeric)
        StringGadget(#G_Input_RectW, 200, 260, 85, 25, "", #PB_String_Numeric)
        StringGadget(#G_Input_RectH, 295, 260, 85, 25, "", #PB_String_Numeric)
        
        ButtonGadget(#G_Btn_Action, 10, 315, 180, 30, "Choose Resource...")
        CanvasGadget(#G_Canvas_ColorPreview, 200, 315, 30, 30)
      CloseGadgetList()
      
      ; NEW: Create the SplitterGadget to bond left tree and right scroll panel together dynamically
      SplitterGadget(#G_Splitter, 10, 10, WinWidth - 20, WinHeight - 75, #G_Tree_Nav, #G_Scroll_Edit, #PB_Splitter_Vertical)
      SetGadgetState(#G_Splitter, 260) ; Set default left panel split width
      
      ; --- BOTTOM CONTROL BAR BUTTONS --- (Positions managed dynamically via resize event)
      ButtonGadget(#G_Btn_Save, WinWidth - 240, WinHeight - 80, 110, 35, "Save Changes")
      ButtonGadget(#G_Btn_Cancel, WinWidth - 120, WinHeight - 80, 110, 35, "Cancel")
      
      ; NEW: Create the native bottom StatusBar
      CreateStatusBar(#G_Status, WindowID(#Win_Editor))
      AddStatusBarField(#PB_Ignore) ; Stretchable information field
      StatusBarText(#G_Status, 0, " Ready. Select a node to begin.")
      
      DisableGadget(#G_Scroll_Edit, #True)
      HideAllEditorGadgets()
      
      RefreshList()
      IsEditorVisible = #True
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  ; ======================================================================
  ; NAME : IsOpen
  ; DESC : Returns whether the editor window is currently active
  ; ======================================================================
  Procedure.i IsOpen()
    ProcedureReturn IsEditorVisible
  EndProcedure
 
  Procedure _UpdateColorPreview(Color.i)
    If StartDrawing(CanvasOutput(#G_Canvas_ColorPreview))
      Box(0, 0, 30, 30, Color) ; Die eigentliche Farbe zeichnen
      
      ; Einen feinen, dunklen Rahmen ziehen, falls die Farbe sehr hell/weiß ist
      DrawingMode(#PB_2DDrawing_Outlined )
      Box(0, 0, 30, 30, $A0A0A0)
      
      StopDrawing()
    EndIf
  EndProcedure
  
  ; ======================================================================
  ; NAME : _ShowWorkspaceItem
  ; DESC : Internal helper to dynamically switch and populate UI panels
  ; ======================================================================
  Procedure _ShowWorkspaceItem(IsReadOnly.i)
    ; 1. Zuerst alle Eingabefelder unsichtbar machen
    HideAllEditorGadgets()
    
    ; --- FIXED: Die Flag-Ausgabe muss IMMER sichtbar geschaltet werden! ---
    HideGadget(#G_Txt_Flags, #False) 
    
    ; Activate the 2 universal text controls for almost all types
    If Not (*ActiveItem\Flags & Props::#Prop_Flag_RECT)
      HideGadget(#G_Lbl_Value, #False)
      HideGadget(#G_Input_String, #False)
      HideGadget(#G_Lbl_Text, #False)
      HideGadget(#G_Input_Text, #False)
      DisableGadget(#G_Input_String, IsReadOnly)
      DisableGadget(#G_Input_Text, IsReadOnly)
    EndIf
    
    ; Labeling & Tuning based on Type
    If *ActiveItem\Flags & Props::#Prop_Flag_RECT
      HideGadget(#G_Lbl_Rect, #False)
      HideGadget(#G_Input_RectX, #False) : HideGadget(#G_Input_RectY, #False)
      HideGadget(#G_Input_RectW, #False) : HideGadget(#G_Input_RectH, #False)
      SetGadgetText(#G_Input_RectX, Str(*ActiveItem\DataL))
      SetGadgetText(#G_Input_RectY, Str(*ActiveItem\DataL))
      SetGadgetText(#G_Input_RectW, Str(*ActiveItem\DataL))
      SetGadgetText(#G_Input_RectH, Str(*ActiveItem\DataL))
      DisableGadget(#G_Input_RectX, IsReadOnly) : DisableGadget(#G_Input_RectY, IsReadOnly)
      DisableGadget(#G_Input_RectW, IsReadOnly) : DisableGadget(#G_Input_RectH, IsReadOnly)
      
    ElseIf *ActiveItem\Flags & Props::#Prop_Flag_MsgBox
      SetGadgetItemText(#G_Lbl_Value, -1, "MessageBox Title (Value$):")
      SetGadgetItemText(#G_Lbl_Text, -1, "MessageBox Body Text (Text$):")
      SetGadgetText(#G_Input_String, *ActiveItem\Value$)
      SetGadgetText(#G_Input_Text, *ActiveItem\Text$)
      
    ElseIf *ActiveItem\Flags & Props::#Prop_Flag_Font
      SetGadgetItemText(#G_Lbl_Value, -1, "Font Descriptor (Source$):")
      SetGadgetItemText(#G_Lbl_Text, -1, "Font Metadata / Description (Text$):")
      SetGadgetText(#G_Btn_Action, "Font...") ; <-- UPDATED: Text is now "Font..."
      SetGadgetText(#G_Input_String, *ActiveItem\Source$)
      SetGadgetText(#G_Input_Text, *ActiveItem\Text$)
      
    ElseIf *ActiveItem\Flags & (Props::#Prop_Flag_Image | Props::#Prop_Flag_Sound)
      SetGadgetItemText(#G_Lbl_Value, -1, "Resource File Path (Source$):")
      SetGadgetItemText(#G_Lbl_Text, -1, "Asset Description (Text$):")
      HideGadget(#G_Btn_Action, IsReadOnly)
      SetGadgetText(#G_Btn_Action, "Browse Files...")
      SetGadgetText(#G_Input_String, *ActiveItem\Source$)
      SetGadgetText(#G_Input_Text, *ActiveItem\Text$)
      
    ElseIf *ActiveItem\Flags & Props::#Prop_Flag_Color
      SetGadgetItemText(#G_Lbl_Value, -1, "Color Code (Hex):")
      SetGadgetItemText(#G_Lbl_Text, -1, "Color Metadata (Text$):") ; <-- HIER KORRIGIERT: #G_Lbl_Text statt #G_Front_Text
      HideGadget(#G_Btn_Action, IsReadOnly)
      HideGadget(#G_Canvas_ColorPreview, #False)
      
      SetGadgetText(#G_Btn_Action, "Color...")
      SetGadgetText(#G_Input_String, "$" + Hex(*ActiveItem\DataL))
      DisableGadget(#G_Input_String, #True)
      SetGadgetText(#G_Input_Text, *ActiveItem\Text$)
      _UpdateColorPreview(*ActiveItem\DataL)
      
    Else
      ; Standard Text Strings or Longs
      SetGadgetItemText(#G_Lbl_Value, -1, "Value Data (Value$ / DataL):")
      SetGadgetItemText(#G_Lbl_Text, -1, "Property Description (Text$):")
      If *ActiveItem\Flags & Props::#Prop_Flag_String
        SetGadgetText(#G_Input_String, *ActiveItem\Value$)
      Else
        SetGadgetText(#G_Input_String, Str(*ActiveItem\DataL))
      EndIf
      SetGadgetText(#G_Input_Text, *ActiveItem\Text$)
    EndIf
  EndProcedure
  
  ; ======================================================================
  ; NAME : _CommitWorkspaceChanges
  ; DESC : Internal helper to sync UI element states back into memory models
  ; ======================================================================
  Procedure _CommitWorkspaceChanges()
    If ActiveKey = "" Or *ActiveItem = 0 Or (*ActiveItem\Flags & Props::#Prop_Flag_ReadOnly)
      ProcedureReturn
    EndIf
    
    If *ActiveItem\Flags & Props::#Prop_Flag_RECT
      *ActiveItem\DataL = Val(GetGadgetText(#G_Input_RectX))
      *ActiveItem\DataL = Val(GetGadgetText(#G_Input_RectY))
      *ActiveItem\DataL = Val(GetGadgetText(#G_Input_RectW))
      *ActiveItem\DataL = Val(GetGadgetText(#G_Input_RectH))
      
    Else
      ; Always save the secondary text/description for all non-RECT types
      *ActiveItem\Text$ = GetGadgetText(#G_Input_Text)
      
      ; Save the primary value mapping based on type
      If *ActiveItem\Flags & Props::#Prop_Flag_MsgBox
        *ActiveItem\Value$ = GetGadgetText(#G_Input_String)
        
      ElseIf *ActiveItem\Flags & (Props::#Prop_Flag_Font | Props::#Prop_Flag_Image | Props::#Prop_Flag_Sound)
        If *ActiveItem\Flags & Props::#Prop_Flag_Font  And *ActiveItem\pbHandle : FntMgr::ReleaseFont(*ActiveItem\pbHandle)  : EndIf
        If *ActiveItem\Flags & Props::#Prop_Flag_Image And *ActiveItem\pbHandle : ImgMgr::ReleaseImage(*ActiveItem\pbHandle) : EndIf
        If *ActiveItem\Flags & Props::#Prop_Flag_Sound And *ActiveItem\pbHandle : SndMgr::ReleaseSound(*ActiveItem\pbHandle) : EndIf
        
        *ActiveItem\Source$  = GetGadgetText(#G_Input_String)
        *ActiveItem\pbHandle = 0
        *ActiveItem\osHandle = 0
        
      ElseIf *ActiveItem\Flags & Props::#Prop_Flag_String
        *ActiveItem\Value$ = GetGadgetText(#G_Input_String)
        
      Else
        ; Numeric elements
        *ActiveItem\DataL = Val(GetGadgetText(#G_Input_String))
      EndIf
    EndIf
  EndProcedure

  ; ======================================================================
  ; NAME : ProcessEvent
  ; DESC : Process events targeting the Editor Window.
  ; ======================================================================
  Procedure.i ProcessEvent(Event.i)
    Protected SelectedItem.i, TempColor.i, NewColor.i, NewAsset.s, TargetFont.i
    Protected Result.i = 0
    Protected WinW.i, WinH.i
    
    If Not IsEditorVisible : ProcedureReturn 0 : EndIf
    If EventWindow() <> #Win_Editor       : ProcedureReturn 0 : EndIf
    
    Select Event
      Case #PB_Event_CloseWindow
        CloseWindow(#Win_Editor)
        IsEditorVisible = #False
        Result = -1
        
      ; --- NEW: Handle Dynamic Window Resizing Layout Corrections ---
      Case #PB_Event_SizeWindow
        WinW = WindowWidth(#Win_Editor)
        WinH = WindowHeight(#Win_Editor)
        
        ; 1. Resize the core Splitter system
        ResizeGadget(#G_Splitter, 10, 10, WinW - 20, WinH - 100) ; Slightly adjusted height for splitter too
        
        ; 2. Keep right-side inner controls matching viewport width
        Protected PanelW.i = GadgetWidth(#G_Scroll_Edit)
        SetGadgetAttribute(#G_Scroll_Edit, #PB_ScrollArea_InnerWidth, PanelW - 5)
        
        ; 3. FIXED: Changed from WinH - 55 to WinH - 80 to lock positions perfectly above the status bar
        ResizeGadget(#G_Btn_Save, WinW - 240, WinH - 80, #PB_Ignore, #PB_Ignore)
        ResizeGadget(#G_Btn_Cancel, WinW - 120, WinH - 80, #PB_Ignore, #PB_Ignore)        
        
      Case #PB_Event_Gadget
        Select EventGadget()
            
          Case #G_Tree_Nav
            If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_Change
              SelectedItem = GetGadgetState(#G_Tree_Nav)
              If SelectedItem <> -1
                *ActiveItem = GetGadgetItemData(#G_Tree_Nav, SelectedItem)
                
                If *ActiveItem <> 0
                  DisableGadget(#G_Scroll_Edit, #False)
                  ActiveKey = *ActiveItem\Key$
                  
                  StatusBarText(#G_Status, 0, " Editing: " + ActiveKey) ; Update StatusBar context
                  ; We request the fully formatted string straight from the data module core
                  Protected FlagStr.s = Props::GetFlagsAsString(*ActiveItem\Flags)
                 
                  Protected IsReadOnly.i = #False
                                   
                  SetGadgetText(#G_Txt_Key, " Active Parameter Path: " + ActiveKey)
                  SetGadgetText(#G_Txt_Flags, FlagStr) 
                  
                  _ShowWorkspaceItem(IsReadOnly)
                Else
                  ActiveKey = "" : *ActiveItem = 0
                  HideAllEditorGadgets()
                  SetGadgetText(#G_Txt_Key, " Category Folder Node Selected")
                  
                  ; FIXED: Auch hier sichtbar schalten, aber Text leeren
                  HideGadget(#G_Txt_Flags, #False)
                  SetGadgetText(#G_Txt_Flags, "[ Types: None ]")
                  
                  HideGadget(#G_Lbl_Text, #False)
                  HideGadget(#G_Input_Text, #False)
                  SetGadgetText(#G_Input_Text, "Select a leaf element item below this path to open the workspace editor properties.")
                  DisableGadget(#G_Input_Text, #True)
                  
                  DisableGadget(#G_Scroll_Edit, #True)
                EndIf
              EndIf
            EndIf
            
          Case #G_Btn_Action
            If ActiveKey <> "" And *ActiveItem And Not (*ActiveItem\Flags & Props::#Prop_Flag_ReadOnly)
              If *ActiveItem\Flags & Props::#Prop_Flag_Color
                TempColor = *ActiveItem\DataL
                NewColor = ColorRequester(TempColor)
                If NewColor <> -1
                  *ActiveItem\DataL = NewColor
                  SetGadgetText(#G_Input_String, "$" + Hex(NewColor))
                  _UpdateColorPreview(NewColor)
                EndIf
              ElseIf *ActiveItem\Flags & Props::#Prop_Flag_Image
                NewAsset = OpenFileRequester("Select Image Resource", GetGadgetText(#G_Input_String), "Images (*.png;*.jpg;*.bmp)|*.png;*.jpg;*.bmp", 0)
                If NewAsset <> "" : SetGadgetText(#G_Input_String, NewAsset) : EndIf
              ElseIf *ActiveItem\Flags & Props::#Prop_Flag_Sound
                NewAsset = OpenFileRequester("Select Sound Resource", GetGadgetText(#G_Input_String), "Audio (*.wav;*.ogg;*.flac)|*.wav;*.ogg;*.flac", 0)
                If NewAsset <> "" : SetGadgetText(#G_Input_String, NewAsset) : EndIf
              EndIf
            EndIf
            
          Case #G_Btn_Save
            _CommitWorkspaceChanges()
            CloseWindow(#Win_Editor)
            IsEditorVisible = #False
            Result = 1 
            
          Case #G_Btn_Cancel
            CloseWindow(#Win_Editor)
            IsEditorVisible = #False
            Result = -1
            
        EndSelect
    EndSelect
    
    ProcedureReturn Result
  EndProcedure  
EndModule


; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 302
; FirstLine = 341
; Folding = --
; DPIAware
; CPU = 5