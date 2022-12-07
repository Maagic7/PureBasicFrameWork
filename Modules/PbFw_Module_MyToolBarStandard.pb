;-TOP
; In PB 6.0 the ToolBarStandardButton Function is removed because it 
; is not compatible with the new Hi-DPI Modes
; Include this module, which simulates ToolBarStandardButton and works for all OS.
; An alternative way is to use the ToolBarImageButton
; the Hi-DPI Images for Standard Buttuns are in #PB_Compiler_Home + "examples/sources/Data/ToolBar/
; the original ToolBarStandardButton was using the Images which are dirctly integrated in the OS
; with the Hi-DPI mode this OS images are looking very bad.

; Comment: Module MyToolBarStandard
; Author : mk-soft
; Version: v1.6.3
; Created: 28.01.2017 (MacToolBarStandard)
; Updated: 08.06.2022
; Link En: https://www.purebasic.fr/english/viewtopic.php?f=12&t=67622
; Link De: 

; ***************************************************************************************

DeclareModule MyToolBarStandard
  
  CompilerIf Not Defined(PB_ToolBarIcon_Cut, #PB_Constant)
    Enumeration
      #PB_ToolBarIcon_Cut ; 0
      #PB_ToolBarIcon_Copy ; 1
      #PB_ToolBarIcon_Paste ; 2
      #PB_ToolBarIcon_Undo ; 3
      #PB_ToolBarIcon_Redo ; 4
      #PB_ToolBarIcon_Delete ; 5
      #PB_ToolBarIcon_New ; 6
      #PB_ToolBarIcon_Open ; 7
      #PB_ToolBarIcon_Save ; 8
      #PB_ToolBarIcon_PrintPreview ; 9
      #PB_ToolBarIcon_Properties ; 10
      #PB_ToolBarIcon_Help ; 11
      #PB_ToolBarIcon_Find ; 12
      #PB_ToolBarIcon_Replace ; 13
      #PB_ToolBarIcon_Print ; 14
    EndEnumeration
  CompilerEndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    #NSWindowToolbarStyleAutomatic = 0 ; 
    #NSWindowToolbarStyleExpanded = 1 ; Top Left
    #NSWindowToolbarStylePreference = 2 ; Top Center
    #NSWindowToolbarStyleUnified = 3 ; TitleBar Large
    #NSWindowToolbarStyleUnifiedCompact = 4 ; TitleBar without text
  CompilerEndIf
  
  Declare MyCreateToolBar(ToolBar, WindowID, Flags = 0)
  Declare MyToolBarStandardButton(ButtonID, ButtonIcon, Mode = 0, Text.s = "")
  Declare SetToolBarStyle(Window, Style)
  
EndDeclareModule

Module MyToolBarStandard
  
  UsePNGImageDecoder()
  
  Global IsLarge
  
  Procedure MyCreateToolBar(ToolBar, WindowID, Flags = 0)
    IsLarge = Flags & #PB_ToolBar_Large
    ProcedureReturn CreateToolBar(ToolBar, WindowID, Flags)
  EndProcedure
  
  Procedure MyToolBarStandardButton(ButtonID, ButtonIcon, Mode = 0, Text.s = "")
    Protected Image, Image2
    
    Select ButtonIcon
      Case #PB_ToolBarIcon_New
        Image = CatchImage(#PB_Any, ?ToolBarIcon_New)
      Case #PB_ToolBarIcon_Open
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Open)
      Case #PB_ToolBarIcon_Save
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Save)
      Case #PB_ToolBarIcon_Print
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Print)
      Case #PB_ToolBarIcon_PrintPreview
        Image = CatchImage(#PB_Any, ?ToolBarIcon_PrintPreView)
      Case #PB_ToolBarIcon_Find
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Find)
      Case #PB_ToolBarIcon_Replace
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Replace)
      Case #PB_ToolBarIcon_Cut
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Cut)
      Case #PB_ToolBarIcon_Copy
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Copy)
      Case #PB_ToolBarIcon_Paste
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Paste)
      Case #PB_ToolBarIcon_Undo
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Undo)
      Case #PB_ToolBarIcon_Redo
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Redo)
      Case #PB_ToolBarIcon_Delete
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Delete)
      Case #PB_ToolBarIcon_Properties
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Properties)
      Case #PB_ToolBarIcon_Help
        Image = CatchImage(#PB_Any, ?ToolBarIcon_Help)
    EndSelect
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      If IsLarge
        ResizeImage(image, 24, 24, #PB_Image_Smooth)
        Image2 = CreateImage(#PB_Any, 36, 28, 32, #PB_Image_Transparent)
        If StartDrawing(ImageOutput(Image2))
          DrawAlphaImage(ImageID(Image), 6, 2)
          FreeImage(Image)
          Image = Image2
          StopDrawing()
        EndIf
      EndIf
    CompilerEndIf
    
    CompilerIf #PB_Compiler_Version <= 551
      result = ToolBarImageButton(ButtonID, ImageID(Image), Mode)
    CompilerElse
      result = ToolBarImageButton(ButtonID, ImageID(Image), Mode, Text)
    CompilerEndIf
    FreeImage(Image)
    ProcedureReturn result
    
  EndProcedure
  
  ; ----
  
  Procedure SetToolBarStyle(Window, Style)
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      If OSVersion() > #PB_OS_MacOSX_10_14
        CocoaMessage(0, WindowID(Window), "setToolbarStyle:", Style)
      EndIf
    CompilerEndIf
  EndProcedure
  
  ; ----
  
  DataSection
    ToolBarIcon_New:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/New.png"
    ToolBarIcon_Open:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Open.png"
    ToolBarIcon_Save:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Save.png"
    ToolBarIcon_Print:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Print.png"
    ToolBarIcon_PrintPreview:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/PrintPreview.png"
    ToolBarIcon_Find:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Find.png"
    ToolBarIcon_Replace:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Replace.png"
    ToolBarIcon_Cut:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Cut.png"
    ToolBarIcon_Copy:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Copy.png"
    ToolBarIcon_Paste:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Paste.png"
    ToolBarIcon_Undo:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Undo.png"
    ToolBarIcon_Redo:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Redo.png"
    ToolBarIcon_Delete:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Delete.png"
    ToolBarIcon_Properties:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Properties.png"
    ToolBarIcon_Help:
    IncludeBinary #PB_Compiler_Home + "examples/sources/Data/ToolBar/Help.png"
  EndDataSection
  
EndModule

; ***************************************************************************************

UseModule MyToolBarStandard

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  Macro CreateToolBar(ToolBar, WindowID, Flags = 0)
    MyCreateToolBar(ToolBar, WindowID, Flags)
  EndMacro
CompilerEndIf

Macro ToolBarStandardButton(ButtonID, ButtonIcon, Mode = 0, Text = "")
  MyToolBarStandardButton(ButtonID, ButtonIcon, Mode, Text)
EndMacro

; ***************************************************************************************

CompilerIf #PB_Compiler_IsMainFile
  
  
  If OpenWindow(0, 0, 0, 800, 150, "ToolBar", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      ; Fix on Big Sur to old style expanded
      SetToolBarStyle(0, #NSWindowToolbarStyleExpanded)
    CompilerEndIf
    
    If CreateToolBar(0, WindowID(0), #PB_ToolBar_Large); | #PB_ToolBar_Text)
      ToolBarStandardButton(0, #PB_ToolBarIcon_New, 0, "New")
      ToolBarStandardButton(1, #PB_ToolBarIcon_Open, 0, "Open")
      ToolBarStandardButton(2, #PB_ToolBarIcon_Save, 0, "Save")
      ToolBarSeparator()
      ToolBarStandardButton(10, #PB_ToolBarIcon_Copy, 0, "Copy")
      ToolBarStandardButton(11, #PB_ToolBarIcon_Cut, 0, "Cut")
      ToolBarStandardButton(12, #PB_ToolBarIcon_Delete, 0, "Delete")
      ToolBarStandardButton(13, #PB_ToolBarIcon_Paste, 0, "Paste")
      ToolBarStandardButton(14, #PB_ToolBarIcon_Replace, 0, "Replace")
      ToolBarStandardButton(15, #PB_ToolBarIcon_Find, 0, "Find")
      ToolBarSeparator()
      ToolBarStandardButton(20, #PB_ToolBarIcon_Redo, 0, "Redo")
      ToolBarStandardButton(21, #PB_ToolBarIcon_Undo, 0, "Undo")
      ToolBarSeparator()
      ToolBarStandardButton(30, #PB_ToolBarIcon_Print, 0, "Print")
      ToolBarStandardButton(31, #PB_ToolBarIcon_PrintPreview, 0, "Preview")
      ToolBarSeparator()
      ToolBarStandardButton(40, #PB_ToolBarIcon_Properties, 0, "Prop")
      ToolBarStandardButton(41, #PB_ToolBarIcon_Help, 0, "help")
      
    EndIf
    
    ;Debug "ToolBarHeight = " + ToolBarHeight(0)
    
    Repeat
    Until WaitWindowEvent() = #PB_Event_CloseWindow 
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 9
; Folding = ---
; Compiler = PureBasic 6.00 LTS (Windows - x86)