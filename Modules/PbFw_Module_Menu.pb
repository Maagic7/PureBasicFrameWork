; ===========================================================================
;  FILE : PbFw_Module_Menu.pb
;  NAME : Module Menu Menu::
;  DESC : Helper Functions for Creating Menues
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/11/17
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{
; 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;-  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule Menu
  
  EnableExplicit 
  
  Enumeration  ; EMenuEntryType
    #PbFw_MenuEntryType_Menu
    #PbFw_MenuEntryType_MenuBar
    #PbFw_MenuEntryType_OpenSubMenu
    #PbFw_MenuEntryType_CloseSubMenu
  EndEnumeration
  
  Structure TMenuEntry
    Name.s        ; our internal Name for identification use
    Caption.s     ; the Caption Text
    ShortCut.s    ; ShortCut for Keyboard  "[SHIFT+F6]"  (but it is just the Text to see, Function must bei programmed!)
    ItemID.i      ; The PB MenuID (MenuTitel(#ID_myMenu,)
    ImageID.i     ; Image ID if it is a ImageMenu (0 = StandardMenu)
    MenuID.i      ; The MenuID of the Menu created with CreateMenu or CreateImageMenu. It must be set by code when creating!
    Type.i        ; Typ of Menu Entry (Enumeration EMenuEntryType)
    xChecked.i    ; check Menu (v) if #TRUE / zeichnet Häckchen
    xDisabled.i   ; Disable Menu if #TRUE
    xHide.i       ; #TRUE = Hide the Menu, #FALSE = Show the Menu => used during Create MenuItem()
  EndStructure
  
  Structure TMenu
    ID.i          ; The MenuID from CreateMenu(#Menu, WindowID)
    xHide.i       ; #TRUE = Hide the Menu, #FALSE = Show the Menu
    Name.s        ; our internal Name     "mnuFile"
    Titel.s       ; Menu Titel, Caption   "File"
    List lstMnu.TMenuEntry()    ; List with Menu Entries
  EndStructure
  
  Structure TToolBarButton
    ButtonID.i
    ImageID.i
    Name.s        ; our internal Name for identification use
  EndStructure  
  
  Structure TToolBar
    ID.i
    Name.s        ; our internal Name for identification use
    List btnList.TToolBarButton()
  EndStructure
    
  Structure TGadget
    ID.i
    Text.s
    ToolTip.s
  EndStructure
  
  Macro macProc_Get_Xref_maxIndex(StructureName)
    ; Private
    Procedure.i Get_Xref_maxIndex(*DropDown.StructureName)
    ; ============================================================================
    ; NAME: Get_Xref_maxIndex
    ; DESC: Creates the Xref Index XrefMax to step trough all .TMenu Elements
    ; DESC: Xref.TMenu[0] is an virtual Array overlay on all .TMenu Elements
    ; DESC: To step trough all elements with For Next, we need the MaxIndex
    ; DESC: to not read over the end.
    ; DESC: To do this we step trough Xref[] until the Pointer @Xref[I]
    ; DESC: reaches @XrefMax - this marks the End of the virtual Array[]
    ; VAR(*DropDown.StructureName) : The DropDown Sructure variable
    ; RET.i: *DropDown
    ; ============================================================================
      Protected I
      
      ; Example with the PureBasic IDE Menus
      ; Structure TFrmDropDownMenu
      ;   MenuID.i  
      ;   Xref.TMenu[0]       ; virtual Array on .TMenu Elements
      ;   ; --------------------
      ;     File.TMenu     
      ;     Edit.TMenu
      ;     Project.TMenu
      ;     Form.TMenu
      ;     Compiler.TMenu
      ;     Debugger.TMenu
      ;     Tools.TMenu
      ;     Help.TMenu
      ;   ; --------------------  
      ;   XrefMax.i           ; Max. index to step trough all; For I = 0 To XrefMax : Xref[I] : Next
      ; EndStructure

      If Not *DropDown
        ProcedureReturn 0
      EndIf
      
      ; Counts the entries in TFrmDropDownMenu starting with Xref[0] until it reaches the end which is marked with XrefMax
      ; For the PB-IDE Menu Structure Get_Xref_maxIndex(TFrmDropDownMenu) will return 7 what is the index of 
      ; Help.Tmenu accessed by Xref[7]
      While @*DropDown\XRef[I] < @*DropDown\XrefMax   ; Step trough XRef[] until the Pointer reaches @XrefMax
        I + 1  
      Wend
      *DropDown\XrefMax = I - 1    ; Save the max index XrefMax in the Structure
      ProcedureReturn *DropDown
    EndProcedure
  EndMacro
  
  Declare MenuToList(*mnu.TMenu, Type, mnuName.s , SubName.s, Caption.s, sShortCut.s="", Image=0, Checked=#False, Disabled=#False) 

EndDeclareModule

Module Menu
  
  EnableExplicit
  
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  Procedure GetNewMenuID()
  ; ============================================================================
  ; NAME: GetNewMenuID
  ; DESC: Gets a new MenuID for Menu-Entries and ToolBar-Buttons
  ; DESC: Clicks on both are handeled in PureBasic with EventMenu()
  ; DESC: The MenuID we'll get back in the EventLoop with MenuClicked = EventMenu()
  ; ============================================================================
    Static NewMenuID = 0  ; The first MenuID will be 1 because we always add 1
    
    NewMenuID + 1
    ProcedureReturn NewMenuID
  EndProcedure

  Procedure MenuToList(*mnu.TMenu, Type, mnuName.s , SubName.s, Caption.s, sShortCut.s="", Image=0, Checked=#False, Disabled=#False) 
  ; ============================================================================
  ; NAME: MenuToList
  ; DESC: Adds the MenuEntry Structure to the MenuEntryList of 
  ; DESC: corresponding Menu in FrmDropDown.TfrmDropDownMenu
  ; DESC: AddElement(FrmDropDown\Project\lstMnu())
  ; DESC: The correct Menu is referenced by mnuName
  ; VAR(Type) : EntryType [#PbFw_MenuEntryType_[Menu, MenuBar, OpenSubMenu, CloseSubMenu] 
  ; ============================================================================
 
    Static oldName.s ; We use Static VARs To check wheater Menu changed
    
    Protected MenuEntry.TMenuEntry
    Protected xFound
    
    If mnuName <> oldName       
      ; If the Menu-Name is different, we must search it first in our List
      ForEach *mnu\lstMnu()     ; Step trough all Entries
         If *mnu\lstMnu()\Name = mnuName
          xFound = #True
          Break             ; Entry found, Exit ForEach
        EndIf
      Next
      
      If xFound           ; mnuName found in FrmDropDown 
        oldName = mnuName ; save mnuName As OldName
      Else ; if no Entry found, Reset the *mnu to 0 
        *mnu=0
      EndIf
    EndIf
    
    If *mnu   ; if we have a valid Pointer to a Menu
      
      ; create a MenuEntry from our Datas
      With MenuEntry
        \Type = Type 
        \Name = Left(mnuName+SubName, 64)
        \Caption = Left(Caption, 128)
        \xChecked = Checked
        \xDisabled = Disabled
        \ImageID = Image   
        \ShortCut = Left(sShortCut,32)
        If Type = #PbFw_MenuEntryType_Menu
          \ItemID =GetNewMenuID()   ; Get a new MenuID
        Else
          \ItemID =0
       EndIf
        
        If sShortCut <> ""
          ;                     Chr(9) = [TAB]
          \Caption = \Caption + Chr(9) + sShortCut
        EndIf
        
      EndWith
  
      With *mnu
        AddElement(\lstMnu())
        \lstMnu() = MenuEntry
      EndWith
      
    Else
       Debug "Procedure MenuToList() : can't find " + mnuName + " in MenuList lstMyMenu_xRef"
    EndIf
    
  EndProcedure
    
  Procedure CreateMenuXrefList(*TDropDown)
  EndProcedure

EndModule

CompilerIf  #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  UseModule Menu
  
  Structure TFrmDropDownMenu
    MenuID.i  
    Xref.TMenu[0]       ; virtual Array on .TMenu Elements
    ; --------------------
      Project.TMenu     
      Sheet.TMenu
      Edit.TMenu
      View.TMenu
      Text.TMenu
      Lists.TMenu
      Dictonary.TMenu
      Automatic.TMenu
      Graph.TMenu
      Options.TMenu
      DataBase.TMenu
      Symbols.TMenu
      Help.TMenu     
    ; --------------------  
    XrefMax.i           ; Max. index to step trough all; For I = 0 To XrefMax : Xref[I] : Next
  EndStructure
    
  Menu::macProc_Get_Xref_maxIndex(TFrmDropDownMenu)
    
  Global mnuDropDown.TFrmDropDownMenu
  
  Define I, J, K, N, *ptr
  
  ; get NuberOfMenus
  
  With mnuDropDown
    \MenuID = 99
    Debug "Project"
    Debug @\XRef[0]
    Debug @\Project
    
    Debug "Sheet"
    Debug @\XRef[1]
    Debug @\Sheet
       
    *ptr = @mnuDropDown + SizeOf(TFrmDropDownMenu)
    
    Get_Xref_maxIndex(mnuDropDown)
    Debug mnuDropDown\XrefMax
  EndWith
  
  
CompilerEndIf

  
 
; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 45
; FirstLine = 25
; Folding = --
; Optimizer
; CPU = 5