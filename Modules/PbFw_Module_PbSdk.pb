; https://github.com/tajmone/purebasic-archives/blob/master/syntax-highlighting/highlight/purebasic.lang

; ===========================================================================
; FILE : PbFw_Module_PbSdk.pb
; NAME : PureBasic Framework : Module PB SDK [PbSdk::]
; DESC : Module PureBasic Software Developemnt Kit!
; DESC : The Module uses some funcitons of PB's Backend.
; DESC : The offical C-Header-Files defining this functions you can 
; DESC : find in \PureBasic\SDK\[C, ViusalC]\PureLibraries.
; DESC : Object.h : Enumerating Windows, Gadgets, Images and Fonts
; DESC : Map.h : MapHash() and PB_FindNumericMapElement()
; DESC :  -  to calculate the Hash of Key$ and find a Element directly with 
; DESC :     key instead of Key$. We can use this for craeting Key-Index Lists!
;
; SOURCES: Link DE : https://www.purebasic.fr/german/viewtopic.php?f=8&t=31380
;          Link EN : https://www.purebasic.fr/english/viewtopic.php?f=12&t=72980
; ===========================================================================
;
; AUTHOR   :  mk-soft : SMaag
; DATE     :  2019/03/30
; VERSION  :  v1.09.2
; COMPILER :  PureBasic 6.0
; OS       :  All
; ===========================================================================
; ChangeLog: 
;{ 
;  2025/02/12 S.Maag : added Map SDK functions 
;  2022/01/07 S.Maag : added comments and changed VAR-Names for Handels
;                      (like WindowID to hWindows) to see it is a OS-Handle
;  2021/12/10 mk-soft 
;}
; ===========================================================================

;{ ====================      M I T   L I C E N S E       ====================
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, SUBlicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, SUBject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or SUBstantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule PbSdk
  ;- ----------------------------------------------------------------------
  ;- Declare Module
  ;- ----------------------------------------------------------------------
  
  Declare WindowPB(WindowID)
  Declare GadgetPB(GadgetID)
  Declare ImagePB(ImageID)
  Declare FontPB(FontID)
  
  Declare GetParentWindowID(Gadget)
  Declare GetPreviousGadget(Gadget, WindowID)
  Declare GetNextGadget(Gadget, WindowID)
  
  Declare GetWindowList(List Windows())
  Declare GetGadgetList(List Gadgets(), WindowID=0)
  Declare GetImageList(List Images())
  Declare GetFontList(List Fonts())
  
  Declare MouseOver()
  
  ; Map ; 
  Prototype MapHash(Key$, CaseSensitive=#True)
  Global MapHash.MapHash
  
EndDeclareModule

; ---------------------------------------------------------------------------------------

Module PbSdk
  ;- Begin of Module
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;-- Import internal function
  
  ; Force Import Font Objects
  If 0 : LoadFont(0, "", 9) : EndIf
  
  ; ---------------------------------------------------------------------------------------
  
  ; to find the defintions of this SDK Functions you have to 
  ; go to PureBasic\SDK\[C, ViusalC]\PureLibraries. There you
  ; can find the offical C-Header files!
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Import ""
      ; Object.h
      PB_Object_EnumerateStart(PB_Objects)
      PB_Object_EnumerateNext(PB_Objects, *ID.Integer)
      PB_Object_EnumerateAbort(PB_Objects)
      PB_Object_GetObject(PB_Object , DynamicOrArrayID)
      PB_Window_Objects
      PB_Gadget_Objects
      PB_Image_Objects
      PB_Font_Objects
      
      ; Map.h
      PB_Map_Hash(*Str)
      PB_Map_HashCaseInsensitive(*Str)
      PB_FindNumericMapElement(*PB_Map, intKey);
    EndImport
    
  CompilerElse
    ImportC ""
      ; Object.h
      PB_Object_EnumerateStart(PB_Objects)
      PB_Object_EnumerateNext(PB_Objects, *ID.Integer)
      PB_Object_EnumerateAbort(PB_Objects)
      PB_Object_GetObject(PB_Object , DynamicOrArrayID)
      PB_Window_Objects.i
      PB_Gadget_Objects.i
      PB_Image_Objects.i
      PB_Font_Objects.i
      
      ; Map SDK
      PB_Map_Hash(*Str)
      PB_Map_HashCaseInsensitive(*Str)
      PB_FindNumericMapElement(*PB_Map, intKey);
    EndImport
    
  CompilerEndIf
  
   CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    ; PB Internal Structure Gadget MacOS
    Structure sdkGadget
      *gadget
      *container
      *vt
      UserData.i
      Window.i
      Type.i
      Flags.i
      
      ; Map SDK
      PB_Map_Hash(*Str)
      PB_Map_HashCaseInsensitive(*Str)
      PB_FindNumericMapElement(*PB_Map, intKey);
    EndStructure
  CompilerEndIf
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure.i WindowPB(hWindow.i) ; Find pb-id over handle   
  ; ============================================================================
  ; NAME: WindowPB
  ; DESC: Gets the PB-WindowNo form OS-Window-Handle
  ; VAR(hWindow.i): OS Window handle (hwnd)
  ; RET.i : PureBasic ID of the Windows
  ; ============================================================================
    Protected window
    Protected result=-1
   
    PB_Object_EnumerateStart(PB_Window_Objects)
    While PB_Object_EnumerateNext(PB_Window_Objects, @window)
      If hWindow = WindowID(window)
        result = window
        Break
      EndIf
    Wend
    PB_Object_EnumerateAbort(PB_Window_Objects)
    ProcedureReturn result
  EndProcedure
    
  Procedure.i GadgetPB(hGadget.i) ; Find pb-id over handle
  ; ============================================================================
  ; NAME: GadgetPB
  ; DESC: Gets the PB-GadgetNo form OS-Window-Handle
  ; VAR(hGadget.i): OS Window handle of the Gadget (hwnd)
  ; RET.i : PureBasic ID of the Gadget
  ; ============================================================================
    Protected gadget
    Protected result=-1
    
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @gadget)
      If hGadget = GadgetID(gadget)
        result = gadget
        Break
      EndIf
    Wend
    PB_Object_EnumerateAbort(PB_Gadget_Objects)
    ProcedureReturn result
  EndProcedure
  
  Procedure.i ImagePB(hImage.i) ; Find pb-id over handle
  ; ============================================================================
  ; NAME: ImagePB
  ; DESC: Gets the PB-IamgeNo form OS-Window-Handle
  ; VAR(hImage.i): OS Window handle of the Image (hwnd)
  ; RET.i : PureBasic ID of the Image
  ; ============================================================================   
    Protected image
    Protected result=-1
   
    PB_Object_EnumerateStart(PB_Image_Objects)
    While PB_Object_EnumerateNext(PB_Image_Objects, @image)
      If hImage = ImageID(image)
        result = image
        Break
      EndIf
    Wend
    PB_Object_EnumerateAbort(PB_Image_Objects)
    ProcedureReturn result
  EndProcedure
  
  Procedure.i FontPB(hFont.i) ; Find pb-id over handle
  ; ============================================================================
  ; NAME: FontPB
  ; DESC: Gets the PB-FontNo form OS-Window-Handle
  ; VAR(hFont.i): OS Window handle of the Font (hwnd)
  ; RET.i : PureBasic ID of the Font
  ; ============================================================================   
    Protected font
    Protected result=-1
   
    PB_Object_EnumerateStart(PB_Font_Objects)
    While PB_Object_EnumerateNext(PB_Font_Objects, @font)
      If hFont = FontID(font)
        result = font
        Break
      EndIf
    Wend
    PB_Object_EnumerateAbort(PB_Font_Objects)
    ProcedureReturn result
  EndProcedure
  
  Procedure.i GetParentWindowID(Gadget.i) ; Retval handle
  ; ============================================================================
  ; NAME: GetParentWindowID
  ; DESC: Gets the handle of the Gadgets parent Window
  ; VAR(Gadget.i): PureBasic GadgetNo
  ; RET.i : OS-Handle of the parent Window (hwnd)
  ; ============================================================================    
    Protected hWindow
    
    If IsGadget(Gadget)
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_MacOS
          Protected *Gadget.sdkGadget = IsGadget(Gadget)
          hWindow = WindowID(*Gadget\Window)
        CompilerCase #PB_OS_Linux
          hWindow = gtk_widget_get_toplevel_(GadgetID(Gadget))
        CompilerCase #PB_OS_Windows           
          hWindow = GetAncestor_(GadgetID(Gadget), #GA_ROOT)
      CompilerEndSelect
    EndIf
    ProcedureReturn hWindow
  EndProcedure
  
  Procedure.i GetPreviousGadget(Gadget.i, hWindow.i) ; Retval pb-id
  ; ============================================================================
  ; NAME: GetPreviousGadget
  ; DESC: Gets the PureBasic-No of the previous Gadget in the Window (parent Window)
  ; VAR(Gadget.i): PureBasic GadgetNo
  ; VAR(hWindow.i): Window handle (hwnd)
  ; RET.i : Purebasic-No of the previous Gadget
  ; ============================================================================   
    Protected object, type   
    Protected prev_id = -1
    
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
      type = GadgetType(object)
      If type <> #PB_GadgetType_Text And type <> #PB_GadgetType_Frame
        If GetParentWindowID(object) = hWindow
          If gadget = object
            If prev_id >= 0
              PB_Object_EnumerateAbort(PB_Gadget_Objects)
              Break
            EndIf
          Else
            prev_id = object
          EndIf
        EndIf
      EndIf
    Wend
    ProcedureReturn prev_id
  EndProcedure
  
  Procedure.i GetNextGadget(Gadget, hWindow) ; Retval pb-id
  ; ============================================================================
  ; NAME: GetNextGadget
  ; DESC: Gets the PureBasic-No of the next Gadget in the parent Window
  ; VAR(Gadget.i): PureBasic GadgetNo
  ; VAR(hWindow.i): Window handle (hwnd)
  ; RET.i : Purebasic-No of the next Gadget
  ; ============================================================================   
    Protected object, type    
    Protected next_id = -1
    
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
      type = GadgetType(object)
      
      If type <> #PB_GadgetType_Text And type <> #PB_GadgetType_Frame
        If GetParentWindowID(object) = hWindow
          
          If next_id < 0
            next_id = object
          EndIf
          
          If gadget = object
            If PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
              If GetParentWindowID(object) = hWindow
                next_id = object
                PB_Object_EnumerateAbort(PB_Gadget_Objects)
                Break
              EndIf
            EndIf
          EndIf
          
        EndIf
      EndIf
    Wend
    
    ProcedureReturn next_id
  EndProcedure
   
  Procedure.i GetWindowList(List Windows()) ; Retval count of windows
  ; ============================================================================
  ; NAME: GetWindowList
  ; DESC: Lists all Windows As Purebasic Window No
  ; VAR(List Windows()): List to retrieve the WindowsNo 
  ; RET.i : No of Windows, WindowCount
  ; ============================================================================   
    Protected object
    ClearList(Windows())
    PB_Object_EnumerateStart(PB_Window_Objects)
    While PB_Object_EnumerateNext(PB_Window_Objects, @object)
      AddElement(Windows())
      Windows() = object
    Wend
    ProcedureReturn ListSize(Windows())
  EndProcedure
  
  Procedure.i GetGadgetList(List Gadgets(), hWindow=0) ; Retval count of gadgets
  ; ============================================================================
  ; NAME: GetGadgetList
  ; DESC: Lists all Gadgets or all Gadgets of a Window As Purebasic GadgetNo
  ; VAR(List Gadgets()): List to retrieve the Gadget numbers 
  ; VAR(hWindow=0): 0: lists all Gadgets of the Project; hwnd: lists Gadgets of Window 
  ; RET.i : No of Gadgets, GadgetCount
  ; ============================================================================   
    Protected object
    ClearList(Gadgets())
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    
    If hWindow = 0
      While PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
        AddElement(Gadgets())
        Gadgets() = object
      Wend
    Else 
      While PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
        If GetParentWindowID(object) = hWindow
          AddElement(Gadgets())
          Gadgets() = object
        EndIf
      Wend
    EndIf
    ProcedureReturn ListSize(Gadgets())
  EndProcedure
  
  Procedure.i GetImageList(List Images()) ; Retval count of images
  ; ============================================================================
  ; NAME: GetImageList
  ; DESC: Lists all Images As Purebasic ImageNo
  ; VAR(List Images()): List to retrieve the ImagesNo
  ; RET.i : No of Windows, WindowCount
  ; ============================================================================  
    Protected object
    ClearList(Images())
    PB_Object_EnumerateStart(PB_Image_Objects)
    While PB_Object_EnumerateNext(PB_Image_Objects, @object)
      AddElement(Images())
      Images() = object
    Wend
    ProcedureReturn ListSize(Images())
  EndProcedure
  
  Procedure.i GetFontList(List Fonts()) ; Retval count of fonts
  ; ============================================================================
  ; NAME: GetFontList
  ; DESC: Lists all Fonts As Purebasic FontNo
  ; VAR(List Fonts()): List to retrieve the FontNo
  ; RET.i : No of Fonts, FontCount
  ; ============================================================================    
    Protected object
    ClearList(Fonts())
    PB_Object_EnumerateStart(PB_Font_Objects)
    While PB_Object_EnumerateNext(PB_Font_Objects, @object)
      AddElement(Fonts())
      Fonts() = object
    Wend
    ProcedureReturn ListSize(Fonts())
  EndProcedure
  
  Procedure.i MouseOver() ; Retval handle
  ; ============================================================================
  ; NAME: MouseOver
  ; DESC: Find the handle of Object under the Cursor
  ; RET.i : OS-Window-Handle of the object (hwnd)
  ; ============================================================================    
    Protected handle, window
    window = GetActiveWindow()
    
    If window < 0
      ProcedureReturn 0
    EndIf
    
    ; Get handle under mouse
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
        Protected pt.q
        GetCursorPos_(@pt)
        handle = WindowFromPoint_(pt)   ; Windows-API GetWindowFromPoint; PureBasic Predefined
        
      CompilerCase #PB_OS_MacOS
        Protected win_id, win_cv, pt.NSPoint
        win_id = WindowID(window)
        win_cv = CocoaMessage(0, win_id, "contentView")
        CocoaMessage(@pt, win_id, "mouseLocationOutsideOfEventStream")
        handle = CocoaMessage(0, win_cv, "hitTest:@", @pt)
        
      CompilerCase #PB_OS_Linux
        Protected desktop_x, desktop_y, *GdkWindow.GdkWindowObject
        
        *GdkWindow.GdkWindowObject = gdk_window_at_pointer_(@desktop_x,@desktop_y)
        If *GdkWindow
          gdk_window_get_user_data_(*GdkWindow, @handle)
        Else
          handle = 0
        EndIf
        
    CompilerEndSelect
    ProcedureReturn handle
  EndProcedure
  
  Procedure _MapHash(*KeyStr, CaseSensitve=#True)
  ; ============================================================================
  ; NAME: _MapHash
  ; DESC: Calculate the Map's Hash for a KeyString
  ; VAR(*KeyStr): Pointer to the KeyString
  ; VAR(CaseSensitive): #True: Casesensitive Hash, #False: Caseinsensitive Hash
  ; RET.i : The Map Hash value
  ; ============================================================================    
    If CaseSensitve
      ProcedureReturn PB_Map_Hash(*KeyStr)
    Else
      ProcedureReturn PB_Map_HashCaseInsensitive(*KeyStr)  
    EndIf    
  EndProcedure
  MapHash=@_MapHash()

  ; ---------------------------------------------------------------------------
  
  ;- End Of Module
  
  
EndModule

EnableExplicit

;- Example
CompilerIf #PB_Compiler_IsMainFile
  
  UseModule PbSdk
  
  Define txt$ = "TestMapHash"
  
  Debug "MapHash = " + MapHash(txt$)
  txt$ = "TestMapHash1"
  Debug "MapHash = " + MapHash(txt$)
  
  txt$ = "testmaphash1"
  Debug "MapHash = " + MapHash(txt$)
  Debug "MapHash = " + MapHash(txt$, #False)
  ; ----
  
  Procedure CheckMouseOver()
    Static last_handle = 0
    Static last_gadget = -1
    
    Protected handle, gadget
    
    handle = MouseOver()
    If handle <> last_handle
      last_handle = handle
      If last_gadget >= 0
        If GadgetType(last_gadget) <> #PB_GadgetType_Canvas
          PostEvent(#PB_Event_Gadget, GetActiveWindow(), last_gadget, #PB_EventType_MouseLeave)
        EndIf
        last_gadget = -1
      EndIf
      If handle
        gadget = GadgetPB(handle)
        If gadget >= 0
          If GadgetType(gadget) <> #PB_GadgetType_Canvas
            PostEvent(#PB_Event_Gadget, GetActiveWindow(), gadget, #PB_EventType_MouseEnter)
          EndIf
          last_gadget = gadget
        EndIf
      EndIf
    EndIf
    
    ProcedureReturn last_gadget
    
  EndProcedure
  
  ; ----
  
  Procedure DoEventGadget()
    Select EventType()
      Case #PB_EventType_MouseEnter
        Debug "Mouse enter: Window = " + EventWindow() + " / Gadget = " + EventGadget()
      Case #PB_EventType_MouseLeave
        Debug "Mouse leave: Window = " + EventWindow() + " / Gadget = " + EventGadget()
    EndSelect
  EndProcedure
  
  ; ----
  
  LoadFont(1, "Arial", 12)
  
  OpenWindow(#PB_Any, 0, 0, 0, 0, "Events", #PB_Window_Invisible)
  
  Define handle.i
  
  If OpenWindow(1, 0, 0, 222, 280, "ButtonGadgets", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    ButtonGadget(0, 10, 10, 200, 25, "Standard Button")
    ButtonGadget(1, 10, 40, 200, 25, "Left Button", #PB_Button_Left)
    ButtonGadget(2, 10, 70, 200, 25, "Right Button", #PB_Button_Right)
    ButtonGadget(3, 10,100, 200, 60, "Multiline Button  (längerer Text wird automatisch umgebrochen)", #PB_Button_MultiLine)
    ButtonGadget(4, 10,170, 200, 25, "Toggle Button", #PB_Button_Toggle)
    ButtonImageGadget(5, 10, 200, 200, 60, LoadImage(2, #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp"))
    
    SetGadgetFont(4, FontID(1))
    
    handle = WindowID(1)
    Debug "Window = " + WindowPB(handle)
    Debug "Gadget = " + GadgetPB(GadgetID(4))
    
    NewList Gadgets()
    Debug "Count of Gadgegts = " + GetGadgetList(Gadgets())
    ForEach Gadgets()
      Debug "Text of Gadget " + Gadgets() + " = " + GetGadgetText(Gadgets())
    Next
    
    handle = GetParentWindowID(3)
    Debug "Parent window handle from gadget 3 = " + GetParentWindowID(3)
    Debug "PB WindowID from handle " + handle + " = " + WindowPB(handle)
    
    handle = GetGadgetAttribute(5, #PB_Button_Image)
    Debug "Image handle from gadget 5 = " + handle
    Debug "PB ImageID from handle " + handle + " = " + ImagePB(handle)
    
    Debug "PB FontID from Gadget 4 = " + FontPB(GetGadgetFont(4))
    
    BindEvent(#PB_Event_Gadget, @DoEventGadget())
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          CloseWindow(1)
          Break
        Case #PB_Event_Gadget
          Select EventGadget()
            Case 0
              Select EventType()
                Case #PB_EventType_LeftClick
                  Debug "Standard Button - LeftClick"
                Case #PB_EventType_MouseEnter
                  Debug "Standard Button - MouseEnter"
                Case #PB_EventType_MouseLeave
                  Debug "Standard Button - MouseLeave"
              EndSelect
          EndSelect
          
        Default
          CheckMouseOver()
          
      EndSelect
    ForEver  
  EndIf
CompilerEndIf
; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 44
; FirstLine = 366
; Folding = ----
; Optimizer
; Executable = SystemTest.exe
; CPU = 5