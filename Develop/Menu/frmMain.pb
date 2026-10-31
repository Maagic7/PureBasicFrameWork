

DeclareModule frmMain
  EnableExplicit
  
  Structure TFrmDropDownMenu Extends Menu::TMenu
    File.Menu::TMenuTitle
    Edit.Menu::TMenuTitle
    Project.Menu::TMenuTitle
    From.Menu::TMenuTitle
    Compiler.Menu::TMenuTitle
    Debugger.Menu::TMenuTitle
    Tools.Menu::TMenuTitle
    Help. Menu::TMenuTitle
  EndStructure 
  
  Structure TFrmGadgets
    Scintilla.i  
  EndStructure
  
  Structure TThis
    wndPB.i
    mnuDrpDwn.TFrmDropDownMenu
    Gadgets.TFrmGadgets
    StatusBar.i
  EndStructure
  
  Declare.i New(wndPB_Parent=#PB_Default, show=#True)
  Declare.i Show(*This.TThis, show=#True)
  Declare.i Destroy(*This.TThis)
  Declare.i Resize(*This.TThis)
  Declare.i Update(*This.TThis)
  Declare.i Events(*This.TThis, Event)
  
EndDeclareModule

Module frmMain
  EnableExplicit
  
  ;- ------------------------------
  ;- Private Functions
  ;- ------------------------------
  
  Procedure.s _MenuFilesCallBack(EntryName.s, n=0)    ; Resent Files
    Protected ret.s
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure _ScintillaCallBack(Gadget, *scinotify.SCNotification)
    ; Ihr Code hier
  EndProcedure

  Procedure _CreateGUI(*This.TThis, wndPB_Parent)
  ; ======================================================================
  ; NAME: _CreateGUI  
  ; DESC: Create the Window GUI
  ; VAR(*This.TThis) : Pointer to Window Instance Data
  ; VAR(wndPB_Parent) : PB Window No of Parent Window
  ; RET.i: PB WindowNo if created. 0 if the Window wasn't created 
  ; ======================================================================
   Protected wndPB, ParentID, mnuID
    Protected _x, _y, _w, _h, _wndFlags      
    Debug "CreateGUI"
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
    
    ; --------------------------------------------------
    ;   C R E A T E   W I N D O W
    ; --------------------------------------------------
    _wndFlags = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget |
                #PB_Window_SizeGadget | #PB_Window_ScreenCentered | #PB_Window_Invisible       
    
    wndPB=OpenWindow(#PB_Any, _x, _y, _w, _h, "Modul Menu Develop", _wndFlags, ParentID)
    
    If wndPB
      *This\wndPB = wndPB       ; write the WindowNo into This
      
      With *This
        ; --------------------------------------------------
        ;   C R E A T E   M E N U
        ; --------------------------------------------------
        mnuID= CreateMenu(#PB_Any, WindowID(wndPB))
        
        Menu::Menu_LoadFromDataSection(\mnuDrpDwn\File, ?mnuFile)
        Menu::Menu_LoadFromDataSection(\mnuDrpDwn\Edit, ?mnuEdit)
        Menu::Menu_LoadFromDataSection(\mnuDrpDwn\Project, ?mnuProject)
        Menu::Menu_LoadFromDataSection(\mnuDrpDwn\From, ?mnuForm)
        Menu::Menu_LoadFromDataSection(\mnuDrpDwn\Compiler, ?mnuCompiler)
        Menu::Menu_LoadFromDataSection(\mnuDrpDwn\Debugger, ?mnuDbg)
        Menu::Menu_LoadFromDataSection(\mnuDrpDwn\Tools, ?mnuTools)
        Menu::Menu_LoadFromDataSection(\mnuDrpDwn\Help, ?mnuHelp)
        
        ; This initialize the *This\mnuDrpDwn\_mnuIdxMax from the TMenuBase-Part of mnuDrpDwn
        ;   the maximal Index Number of TMenuTitle when accessing \mnuDrpDwn\MenuEntries[0.._mnuIdxMax]
        
        Menu::Init_TFrmMenu(*This\mnuDrpDwn, SizeOf(TFrmDropDownMenu))
        If mnuID
          \mnuDrpDwn\mnuPB = mnuID
          Menu::Menu_AddAllTitles(\mnuDrpDwn, mnuID)      ; create All Menu Titles, the complete Menu         
          ; Here the alternative way: creating each Titel         
            ; Menu::Menu_AddTitle(\mnuDrpDwn\File, mnuID)          
            ; Menu::Menu_AddTitle(\mnuDrpDwn\Edit, mnuID)          
            ; Menu::Menu_AddTitle(\mnuDrpDwn\Project, mnuID)
            ; Menu::Menu_AddTitle(\mnuDrpDwn\From, mnuID)
            ; Menu::Menu_AddTitle(\mnuDrpDwn\Compiler, mnuID)
            ; Menu::Menu_AddTitle(\mnuDrpDwn\Debugger, mnuID)
            ; Menu::Menu_AddTitle(\mnuDrpDwn\Tools, mnuID)
            ; Menu::Menu_AddTitle(\mnuDrpDwn\Help, mnuID)
        EndIf
        ; Menu::Menu_CreatePbCode(\mnuDrpDwn\File, wndPB)
        
        ; --------------------------------------------------
        ;   C R E A T E   G A D G E T S
        ; --------------------------------------------------       
        \StatusBar = CreateStatusBar(#PB_Any, WindowID(\wndPB))
        If \StatusBar
          AddStatusBarField(90)
          AddStatusBarField(100)
          AddStatusBarField(#PB_Ignore) ; Größe dieses Feldes automatisch anpassen
          AddStatusBarField(100)
        EndIf
        \Gadgets\Scintilla= ScintillaGadget(#PB_Any, 0, 0, 300,300, @_ScintillaCallBack())
        
      EndWith
    EndIf
    
    ProcedureReturn wndPB
  EndProcedure
  
  ;- ------------------------------
  ;- Public Methodes
  ;- ------------------------------

  Procedure.i New(wndPB_Parent=#PB_Default, show=#True)
  ; ======================================================================
  ; NAME: New  
  ; DESC: Create a New Instance of the Form
  ; DESC: Call it: *myFrm=ModuleName::NEW()  
  ; VAR(wndPB_Parent) : PB Window No of Parent Window
  ; VAR(show) : #True= Show the window, #False = Hide the Window 
  ; RET.i: *This; The Pointer to the allocated memory or 0 if 
  ;        could not get the memory from OS
  ; ======================================================================
    Protected *objThis.TThis
    Debug "frmMain::New"
    *objThis = AllocateStructure(TThis)
    
    If *objThis
      If _CreateGUI(*objThis, wndPB_Parent)
        If show
          Show(*objThis)
        EndIf
      Else
        FreeStructure(*objThis)  
      EndIf
    EndIf  
    
    ProcedureReturn *objThis   
  EndProcedure
  
  Procedure.i Show(*This.TThis, show=#True)
  ; ======================================================================
  ; NAME: Show  
  ; DESC: Show or Hide the Window
  ; VAR(*This.TThis) : Pointer to Window Instance Data
  ; VAR(show) : #True= Show the window, #False = Hide the Window 
  ; RET.i: Value of show
  ; ======================================================================
    HideWindow(*This\wndPB, Bool(show=#False))
    ProcedureReturn show
  EndProcedure
  
  Procedure.i Destroy(*This.TThis)   
  ; ======================================================================
  ; NAME: Destroy  
  ; DESC: Destroy the Form
  ; DESC: Call it: *myFrm=ModuleName::Destroy(*myFrm)  
  ; VAR(*This.TThis) : Pointer to Window Instance Data
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
  ; VAR(*This.TThis) : Pointer to Window Instance Data
  ; RET.i:  
  ; ======================================================================
    
  EndProcedure
  
  Procedure Events(*This.TThis, Event)
  ; ======================================================================
  ; NAME: Events  
  ; DESC: The forms Event Proc
  ; DESC: Call it: ModuleName::Events(*myFrm)  
  ; VAR(*This.TThis) : Pointer to Window Instance Data
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
            Debug "Menu pressed " + wndPB
        EndSelect
        
      Else
         
      EndIf
       
    ProcedureReturn Quit
  EndProcedure
  
  DataSection
    mnuFile:
    Data$ "mnuFile", "File"
    Data$   "_New",  "New", "[Ctrl+N]"
    Data$   "_Open", "Open...", "[Ctrl+O]"
    Data$   "_Save", "Save", "[Ctrl+S]"
    Data$   "_SaveAs", "Save As..."
    Data$   "_SaveAll", "Save All"
    Data$   "_Reload", "Reload"
    Data$   "_Close", "Close", "[Ctrl+W]"
    Data$   "_CloseAll", "Close All"
    Data$   "_ViewChanges", "View Changes"
    Data$   "-"
    Data$   "_ShowInFolder", "Show in Folder"
    Data$   "-"
    Data$   #LF$, "_FileFormat", "File Format"
    Data$     "_EncodingPlainText", "Encoding: Plain Text"
    Data$     "_EncodingUtf8", "Encoding Utf8"
    Data$     "-"
    Data$     "_NewLineCRLF", "Newline: Windows (CRLF)"
    Data$     "_NewLineLF", "Newline: Linux (LF)"
    Data$     "_NewlineCR", "Newline: MaxOS (CR)"       
    Data$   #CR$
    Data$   "-" 
    Data$   "_Prferences", "Preferences..."
    Data$   "-"
    Data$   "_SessionHistory", "Session History"
    Data$   #LF$, "_RecentFiles", "Recent Files"
    Data$     "_File01", "File 1", "%\m=10"
    Data$     "_File02", "File 2", "%\h"  
    Data$     "_File03", "File 3", "%\h"  
    Data$     "_File04", "File 4", "%\h"  
    Data$     "_File05", "File 5", "%\h"  
    Data$     "_File06", "File 6", "%\h"  
    Data$     "_File07", "File 7", "%\h"  
    Data$     "_File08", "File 8", "%\h"  
    Data$     "_File09", "File 9", "%\h"  
    Data$     "_File10", "File 10", "%\h"  
    Data$   #CR$
    Data$   "-"
    Data$   "_Quit", "Quit"
    Data$ #EOT$
    
    mnuEdit:    
    Data$ "mnuEdit", "Edit"
    Data$   "_Undo", "Undo", "[Ctrl+Z]"
    Data$   "_Redo", "Redo", "[Ctrl+Y]"
    Data$   "-"
    Data$   "_Cut", "Cut", "[Ctrl+X]"
    Data$   "_Copy", "Copy", "[Ctrl+C]"
    Data$   "_Paste", "Paste", "[Ctrl+V]"
    Data$   "_PasteAsComment", "Paste as comment", "[Ctrl+Shift+V]"
    Data$   "-"
    Data$   "_InsertComments", "Insert comments", "[Ctrl+B]"
    Data$   "_RemoveComments", "Remove comments", "[Ctrl+Shift+B]"
    Data$   "_FormatIntendation", "Format intendation", "[Ctrl+I]"
    Data$   "-"
    Data$   "_SelectAll", "Select All", "[Ctrl+A]"
    Data$   "-"
    Data$   "_Goto", "Goto...", "[Ctrl+G]"
    Data$   "_GotoMatchingKeyword", "Goto matching Keyword", "[Ctrl+K]"
    Data$   "_GotoRecentLine", "Goto recent Line", "[Ctrl+L]"
    Data$   "-"
    Data$   "_ToggleCurrentFold", "Toggle current fold", "[F4]"
    Data$   "_ToggleAllFolds", "Toggle all folds", "[Ctrl+F4]"
    Data$   "-"
    Data$   "_AddRemoveMarker", "Add/Remove Marker", "[Ctrl+F2]"
    Data$   "_JumpToMarker", "Jump to Marker", "[F2]"
    Data$   "_ClearMarkers", "Clear Markers"
    Data$   "-"
    Data$   "_FindReplace", "Find/Replace", "[Ctrl+F]"
    Data$   "_FindNext", "Find Next", "[F3]"
    Data$   "_FindPrevious", "Find Previous", "[Shift+F3]"
    Data$   "_FindInFiles", "Find in Files...", "[Ctrl+Shift+F]"
    Data$   "_Replace", "Replace...", "[Ctrl+H]"   
    Data$ #EOT$
    
    mnuProject:    
    Data$ "mnuProject", "Project"
    Data$   "_New", "New Project", "[Ctrl+Shift+N]"
    Data$   "_Open", "Open Project", "[Ctrl+Shift+O]"
    Data$   #LF$, "_Recent", "Recent Projects"
    Data$     "_Project01", "Project 1", "%\m=10"
    Data$     "_Project02", "Project 2", "%\h"  
    Data$     "_Project03", "Project 3", "%\h"  
    Data$     "_Project04", "Project 4", "%\h"  
    Data$     "_Project05", "Project 5", "%\h"  
    Data$     "_Project06", "Project 6", "%\h"  
    Data$     "_Project07", "Project 7", "%\h"  
    Data$     "_Project08", "Project 8", "%\h"  
    Data$     "_Project09", "Project 9", "%\h"  
    Data$     "_Project10", "Project 10", "%\h"  
    Data$   #CR$
    Data$   "_Close", "Close Project", "[Ctrl+Shift+W]"
    Data$   "-"
    Data$   "_Options", "Project Options..."
    Data$   "_AddFile", "Add File to Project", "[Ctrl+Shift+A]"
    Data$   "_RemoveFile", "Remove File from Project", "[Ctrl+Shift+R]"
    Data$   "-"
    Data$   "_OpenFolder", "Open Project Folder"
    Data$ #EOT$
    
    mnuForm:    
    Data$ "mnuForm", "Form"
    Data$   "_New", "New Form"
    Data$   "-"
    Data$   "_Switch", "Switch Code/Design View"
    Data$   "-"
    Data$   "_Duplicate", "Duplicate Object"
    Data$   "_ImgMgr", "Image Manager..."
    Data$ #EOT$
    
    mnuCompiler:    
    Data$ "mnuCompiler", "Compiler"
    Data$   "_Cmp", "Compile/Run", "[F5]"
    Data$   "_Run", "Run", "[Shift+F5]"
    Data$   "_SyntaxCheck", "Syntax check"
    Data$   "-"
    Data$   "_CmpDbg", "Compile with Debugger"
    Data$   "_CmpNoDbg", "Compile without Debugger"
    Data$   "-"
    Data$   "_ResartCmp", "Restart Compiler"
    Data$   "-"
    Data$   "_CmpOpt", "Compiler Options..."
    Data$   "_CreateExe", "Create Executable..."
    Data$   "-"
    Data$   #LF$, "_SetDefTarget", "Set Default Target"
    Data$     "_DefTarget", "Default Target"    
    Data$   #CR$
    Data$   #LF$, "_BuildTarget", "Build Target"
    Data$     "_DefTarget", "Default Target"    
    Data$   #CR$
    Data$   "_BuildAllTargets", "Build all Targets"
    Data$ #EOT$
    
    mnuDbg:    
    Data$ "mnuDgb", "Debugger"
    Data$   "_UseDbg", "Use Debugger", "%\f=C"
    Data$   "-"
    Data$   "_Stop", "Stop", "[F6]"
    Data$   "_Cont", "Continue", "[F7]", "%\f=D"
    Data$   "_Kill", "Kill Program", "%\f=D"
    Data$   "-"
    Data$   "_Step", "Step", "[F8]", "%\f=D"
    Data$   "_StepN", "Step<n>", "[Ctrl+F8]", "%\f=D"
    Data$   "_StepOver", "Step Over", "[F10]", "%\f=D"
    Data$   "_StepOut", "Step Out", "[F11]", "%\f=D"
    Data$   "-"
    Data$   "_BreakPt", "Breakpoint", "[F9]"
    Data$   "_ClrBreakPts", "Clear Breakpoints"
    Data$   "_DataBreakPts", "Data Breakpoints", "%\f=D"
    Data$   "-"
    Data$   #LF$, "_ErrorLog", "Error Log"
    Data$     "_Show", "Show Error Log"
    Data$     "-"
    Data$     "_Clr", "Clear Error Log", "%\f=D"
    Data$     "_Cpy", "Copy Error Log", "%\f=D"
    Data$     "-"
    Data$     "_ClrMasks", "Clear Error Masks" 
    Data$   #CR$
    Data$   "_DbgOutput", "Debug Output", "%\f=D"
    Data$   "_WatchList", "Watchlist", "%\f=D"
    Data$   "_VarViewer", "Variable Viewer", "%\f=D"
    Data$   "_Profiler", "Profiler", "%\f=D"
    Data$   "_CallStack", "Callstack", "%\f=D"
    Data$   "_MemViewer", "Memory Viewer", "%\f=D"
    Data$   "_LibViewer", "Library Viewer", "%\f=D"
    Data$   "_Assembley", "Assembley", "%\f=D"
    Data$   "_Purifier", "Purifier", "%\f=D"
    Data$ #EOT$
   
    mnuTools:    
    Data$ "mnuTools", "Tools"
    Data$   "_FrmDesigner", "Form Designer", "[Alt+V]"
    Data$   "_FileViewer", "File Viewer"
    Data$   "_StructViewer", "Structure Viewer", "[Alt+S]"
    Data$   "_VarViewer", "Variable Viewer"
    Data$   "_CmpFiler", "Compare Files/Folders"
    Data$   "_ProcBrowser", "Procedure Browser"
    Data$   "_IssueBrowser", "Issue Browser"
    Data$   "_ProjPanel", "Project Panel"
    Data$   "_Templates", "Templates"
    Data$   "_Explorer", "Explorer", "[Alt+X]"
    Data$   "_ColorPicker", "Color Picker"
    Data$   "_ChrTable", "Character Table", "[Alt+A]"
    Data$   "-"
    Data$   "_CfgTools", "Configure Tools..."
    Data$   "-"
    Data$ #EOT$
    
    mnuHelp:    
    Data$ "mnuHelp", "Help"
    Data$   "_Help", "Help...", "[F1]"
    Data$   "_CheckUpdates", "Check for updates"
    Data$   "_About", "About"
    Data$ #EOT$

  EndDataSection

EndModule

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 105
; FirstLine = 395
; Folding = --
; DPIAware
; CPU = 5