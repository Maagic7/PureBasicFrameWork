; ===========================================================================
;  FILE: PbFw_Module_GadgetEx.pb
;  NAME: Module Gadget Extention GGX: 
;  DESC: 
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/12/21
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.0 and higher
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
XIncludeFile "PbFw_Module_FileSystem.pb"   ; FS::       FileSystem Module
XIncludeFile "PbFw_Module_PbSDK.pb"        ; PbSDK::    PureBasic System Module

; XIncludeFile ""

DeclareModule GGX
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  EnumerationBinary
    #GadgetTransformation_Position
    #GadgetTransformation_Horizontally
    #GadgetTransformation_Vertically
  EndEnumeration
   
   #GadgetTransformation_Size = #GadgetTransformation_Horizontally|#GadgetTransformation_Vertically
   #GadgetTransformation_All  = #GadgetTransformation_Position|#GadgetTransformation_Horizontally|#GadgetTransformation_Vertically

  Structure TGadgetPos
    X.i
    Y.i
    W.i
    H.i
  EndStructure
  

  Structure TAlignObj     ; Definition of the Object to align to
    hPB.i                 ; Purebasic Handle
    Dist.i                ; Align distance to Object
    DistIDE.i             ; Align distance in the IDE
  EndStructure
  
  Structure TGadgetAlign  ; Gadget Align definition
    oLeft.TAlignObj       ; Data of the Left Align Object
    oTop.TAlignObj        ; Data of the Top Align Object
    oRight.TAlignObj      ; Data of the Right Align Object
    oBottom.TAlignObj     ; Data of the Bottom Align Object
  EndStructure
      
  Structure TGadgetDataEx Extends DBG::TSafeStruct ; Extendet Gadget Data. To use extendet Gadget Data set GadgetData = Pointer(TGadgetDataEx)
;     *pThis                ; Part of DBG::TSafeStruct
;     StructID.i            ; Part of DBG::TSafeStruct
    hPB.i                 ; The PureBasics #Gadget
    ggData.i              ; The GadgetData value    : because DATA is a PB Keyword we have to use a Prefix
    GroupID.i             ; use this for grouping Gadgets
    Tag.s                 ; TAG String
    Align.TGadgetAlign    ; The Align Datas
  EndStructure
  
  Declare.i GetNextPbGadgetNo()
  Declare.i AllocateNewGadgetDataEx(GadgetNo.i)
  Declare.i GetGadgetPos(GadgetNo.i, *GadgetPos.TGadgetPos)
    
EndDeclareModule


Module GGX
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  
  #HandelSize = 5
 
  Structure TGadgetTransformation
    Gadget.i
    Handle.i[10]
    Grid.i
  EndStructure
  
  Structure DataBuffer
    Handle.i[10]
  EndStructure
   
  Global NewList GadgetTransformation.TGadgetTransformation()
   
  Global NewList lstDataEx.TGadgetDataEx()
  
  Global mem_GadgetNo.i
  
  Global TGadgetDataEx_ID = DBG::GetNextStructureID()   ; Get an unique StructureID for TGadgetDataEx
  
  Procedure.i _GridMatch(Value.i, Grid.i, Max.i=$7FFFFFFF)
      Value = Round(Value/Grid, #PB_Round_Nearest)*Grid
      If Value > Max
         ProcedureReturn Max
      Else
         ProcedureReturn Value
      EndIf
   EndProcedure

  Procedure.i GetNextPbGadgetNo()
  ; ============================================================================
  ; NAME: GetNextPbGadgetNo
  ; DESC: Gets a number for the next Gadget
  ; RET.i : 
  ; ============================================================================
    
    mem_GadgetNo + 1
    ProcedureReturn mem_GadgetNo  
  EndProcedure
  
  Procedure.i AllocateNewGadgetDataEx(GadgetNo.i)
  ; ============================================================================
  ; NAME: AllocateNewGadgetDataEx
  ; DESC: 
  ; VAR(GadgetNo.i): The PB's Gadget Number
  ; RET.i : The Pointer to the TGadgetDataEx Structure 
  ; ============================================================================
    Protected *pData.TGadgetDataEx
    
    If IsGadget(GadgetNo)
      AddElement(lstDataEx())
      *pData = lstDataEx()
      
      With *pData
        \hPB = GadgetNo
        \pThis = *pData
        \StructID = TGadgetDataEx_ID
      EndWith
      
      SetGadgetData(GadgetNo, *pData)      
    EndIf
    
    ProcedureReturn *pData
  EndProcedure
  
  Procedure.i GetGadgetPos(GadgetNo.i, *GadgetPos.TGadgetPos)
  ; ============================================================================
  ; NAME: GetGadgetPos
  ; DESC: 
  ; VAR(GadgetNo.i): The PB's Gadget Number
  ; VAR(*GadgetPos.TGadgetPos): The GadgetPos Structure
  ; RET.i : *GadgetPos if succeed or 0
  ; ============================================================================
   
    If IsGadget(GadgetNo)
      If *GadgetPos
        With *GadgetPos
          \X = GadgetX(GadgetNo)
          \Y = GadgetY(GadgetNo)
          \H = GadgetHeight(GadgetNo)
          \W = GadgetWidth(GadgetNo) 
          ProcedureReturn *GadgetPos
        EndWith      
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure
  
  Procedure GUI_EDIT_Callback()
    Static Selected.i, X.i, Y.i, OffsetX.i, OffsetY.i, GadgetX0.i, GadgetX1.i, GadgetY0.i, GadgetY1.i
    Protected *GadgetTransformation.TGadgetTransformation = GetGadgetData(EventGadget())
   
    Protected ggData.TGadgetDataEx
    Protected.i hPB, Evt
    
    hPB = EventGadget()
    Evt = EventType()
    
    With *GadgetTransformation
      
      Select EventType()
          
        Case #PB_EventType_LeftButtonDown
          
             Selected = #True
             OffsetX = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX)
             OffsetY = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY)
             GadgetX0 = GadgetX(\Gadget)
             GadgetX1 = GadgetX0 + GadgetWidth(\Gadget)
             GadgetY0 = GadgetY(\Gadget)
             GadgetY1 = GadgetY0 + GadgetHeight(\Gadget)
                 
         Case #PB_EventType_LeftButtonUp
             Selected = #False
             
         Case #PB_EventType_MouseMove
             If Selected
                X = WindowMouseX(GetActiveWindow())-OffsetX
                Y = WindowMouseY(GetActiveWindow())-OffsetY
                Select EventGadget()
                   Case \Handle[1]
                      ResizeGadget(\Gadget, _GridMatch(X+#HandelSize, \Grid, GadgetX1), #PB_Ignore, GadgetX1-_GridMatch(X+#HandelSize, \Grid, GadgetX1), _GridMatch(Y, \Grid)-GadgetY0)
                   Case \Handle[2]
                      ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, _GridMatch(Y, \Grid)-GadgetY0)
                   Case \Handle[3]
                      ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, _GridMatch(X, \Grid)-GadgetX0, _GridMatch(Y, \Grid)-GadgetY0)
                   Case \Handle[4]
                      ResizeGadget(\Gadget, _GridMatch(X+#HandelSize, \Grid, GadgetX1), #PB_Ignore, GadgetX1-_GridMatch(X+#HandelSize, \Grid, GadgetX1), #PB_Ignore)
                   Case \Handle[5]
                      ResizeGadget(\Gadget, _GridMatch(X-#HandelSize, \Grid), _GridMatch(Y+#HandelSize, \Grid), #PB_Ignore, #PB_Ignore)
                   Case \Handle[6]
                      ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, _GridMatch(X, \Grid)-GadgetX0, #PB_Ignore)
                   Case \Handle[7]
                      ResizeGadget(\Gadget, _GridMatch(X+#HandelSize, \Grid, GadgetX1), _GridMatch(Y+#HandelSize, \Grid, GadgetY1), GadgetX1-_GridMatch(X+#HandelSize, \Grid, GadgetX1), GadgetY1-_GridMatch(Y+#HandelSize, \Grid, GadgetY1))
                   Case \Handle[8]
                      ResizeGadget(\Gadget, #PB_Ignore, _GridMatch(Y+#HandelSize, \Grid, GadgetY1), #PB_Ignore, GadgetY1-_GridMatch(Y+#HandelSize, \Grid, GadgetY1))
                   Case \Handle[9]
                      ResizeGadget(\Gadget, #PB_Ignore, _GridMatch(Y+#HandelSize, \Grid, GadgetY1), _GridMatch(X, \Grid)-GadgetX0, GadgetY1-_GridMatch(Y+#HandelSize, \Grid, GadgetY1))
                EndSelect
                
                If \Handle[1]
                   ResizeGadget(\Handle[1], GadgetX(\Gadget)-#HandelSize, GadgetY(\Gadget)+GadgetHeight(\Gadget), #PB_Ignore, #PB_Ignore)
                EndIf
                If \Handle[2]
                   ResizeGadget(\Handle[2], GadgetX(\Gadget)+(GadgetWidth(\Gadget)-#HandelSize)/2, GadgetY(\Gadget)+GadgetHeight(\Gadget), #PB_Ignore, #PB_Ignore)
                EndIf
                If \Handle[3]
                   ResizeGadget(\Handle[3], GadgetX(\Gadget)+GadgetWidth(\Gadget), GadgetY(\Gadget)+GadgetHeight(\Gadget), #PB_Ignore, #PB_Ignore)
                EndIf
                If \Handle[4]
                   ResizeGadget(\Handle[4], GadgetX(\Gadget)-#HandelSize, GadgetY(\Gadget)+(GadgetHeight(\Gadget)-#HandelSize)/2, #PB_Ignore, #PB_Ignore)
                EndIf
                If \Handle[5]
                   ResizeGadget(\Handle[5], GadgetX(\Gadget)+#HandelSize, GadgetY(\Gadget)-#HandelSize, #PB_Ignore, #PB_Ignore)
                EndIf
                If \Handle[6]
                   ResizeGadget(\Handle[6], GadgetX(\Gadget)+GadgetWidth(\Gadget), GadgetY(\Gadget)+(GadgetHeight(\Gadget)-#HandelSize)/2, #PB_Ignore, #PB_Ignore)
                EndIf
                If \Handle[7]
                   ResizeGadget(\Handle[7], GadgetX(\Gadget)-#HandelSize, GadgetY(\Gadget)-#HandelSize, #PB_Ignore, #PB_Ignore)
                EndIf
                If \Handle[8]
                   ResizeGadget(\Handle[8], GadgetX(\Gadget)+(GadgetWidth(\Gadget)-#HandelSize)/2, GadgetY(\Gadget)-#HandelSize, #PB_Ignore, #PB_Ignore)
                EndIf
                If \Handle[9]
                   ResizeGadget(\Handle[9], GadgetX(\Gadget)+GadgetWidth(\Gadget), GadgetY(\Gadget)-#HandelSize, #PB_Ignore, #PB_Ignore)
                EndIf
             EndIf
       EndSelect
    EndWith
  EndProcedure
 
  Procedure EnableGadgetTransformation(Gadget.i, Flags.i=#GadgetTransformation_All, Grid.i=1)
    Protected Handle.i, I.i
    Protected *GadgetTransformation.TGadgetTransformation
    Protected *Cursors.DataBuffer = ?Cursors
    Protected *Flags.DataBuffer = ?Flags
    
    ForEach GadgetTransformation()
      If GadgetTransformation()\Gadget = Gadget
        For I = 1 To 9
          If GadgetTransformation()\Handle[I]
            FreeGadget(GadgetTransformation()\Handle[I])
          EndIf
        Next
          DeleteElement(GadgetTransformation())
      EndIf
    Next
    
    *GadgetTransformation = AddElement(GadgetTransformation())
    *GadgetTransformation\Gadget = Gadget
    *GadgetTransformation\Grid = Grid
    
    For I = 1 To 9
      If Flags & *Flags\Handle[I] = *Flags\Handle[I]
        Select I
          Case 1
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)-#HandelSize, GadgetY(Gadget)+GadgetHeight(Gadget), #HandelSize, #HandelSize)
          Case 2
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+(GadgetWidth(Gadget)-#HandelSize)/2, GadgetY(Gadget)+GadgetHeight(Gadget), #HandelSize, #HandelSize)
          Case 3
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+GadgetWidth(Gadget), GadgetY(Gadget)+GadgetHeight(Gadget), #HandelSize, #HandelSize)
          Case 4
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)-#HandelSize, GadgetY(Gadget)+(GadgetHeight(Gadget)-#HandelSize)/2, #HandelSize, #HandelSize)
          Case 5
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+#HandelSize, GadgetY(Gadget)-#HandelSize, 2*#HandelSize, #HandelSize)
          Case 6
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+GadgetWidth(Gadget), GadgetY(Gadget)+(GadgetHeight(Gadget)-#HandelSize)/2, #HandelSize, #HandelSize)
          Case 7
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)-#HandelSize, GadgetY(Gadget)-#HandelSize, #HandelSize, #HandelSize)
          Case 8
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+(GadgetWidth(Gadget)-#HandelSize)/2, GadgetY(Gadget)-#HandelSize, #HandelSize, #HandelSize)
          Case 9
            Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+GadgetWidth(Gadget), GadgetY(Gadget)-#HandelSize, #HandelSize, #HandelSize)
        EndSelect
        
        *GadgetTransformation\Handle[I] = Handle
        SetGadgetData(Handle, *GadgetTransformation)
        SetGadgetAttribute(Handle, #PB_Canvas_Cursor, *Cursors\Handle[I])
        
        If StartDrawing(CanvasOutput(Handle))
          Box(0, 0, OutputWidth(), OutputHeight(), $000000)
          Box(1, 1, OutputWidth()-2, OutputHeight()-2, $FFFFFF)
          StopDrawing()
        EndIf
        BindGadgetEvent(Handle, @GUI_EDIT_Callback())
      EndIf
    Next
    
    DataSection
      Cursors:
      Data.i 0, #PB_Cursor_LeftDownRightUp, #PB_Cursor_UpDown, #PB_Cursor_LeftUpRightDown, #PB_Cursor_LeftRight
      Data.i #PB_Cursor_Arrows, #PB_Cursor_LeftRight, #PB_Cursor_LeftUpRightDown, #PB_Cursor_UpDown, #PB_Cursor_LeftDownRightUp
      Flags:
      Data.i 0, #GadgetTransformation_Size, #GadgetTransformation_Vertically, #GadgetTransformation_Size, #GadgetTransformation_Horizontally
      Data.i #GadgetTransformation_Position, #GadgetTransformation_Horizontally, #GadgetTransformation_Size, #GadgetTransformation_Vertically, #GadgetTransformation_Size
    EndDataSection
  EndProcedure
  
  Procedure DisableGadgetTransformation(Gadget.i)
    Protected I.i, *GadgetTransformation.TGadgetTransformation
    
    ForEach GadgetTransformation()
      If GadgetTransformation()\Gadget = Gadget
        For I = 1 To 9
          If GadgetTransformation()\Handle[I]
            FreeGadget(GadgetTransformation()\Handle[I])
          EndIf
        Next
          DeleteElement(GadgetTransformation())
      EndIf
    Next
  EndProcedure
  
  Procedure.s GetGadgetTypeName(GadgetNo)
     Protected.i ggType
     Protected Type$
     
    If IsGadget(GadgetNo)
      ggType = GadgetType(GadgetNo)  
    Else
      ProcedureReturn "Not a Gadget"
    EndIf
    
    Select ggType         
      Case #PB_GadgetType_Button        : Type$ ="ButtonGadget"
      Case #PB_GadgetType_ButtonImage   : Type$ ="ButtonImageGadget"
      Case #PB_GadgetType_Calendar      : Type$ ="CalendarGadget"
      Case #PB_GadgetType_Canvas        : Type$ ="CanvasGadget"
      Case #PB_GadgetType_CheckBox      : Type$ ="CheckBoxGadget"
      Case #PB_GadgetType_ComboBox      : Type$ ="ComboBoxGadget"
      Case #PB_GadgetType_Container     : Type$ ="ContainerGadget"
      Case #PB_GadgetType_Date          : Type$ ="DateGadget"
      Case #PB_GadgetType_Editor        : Type$ ="EditorGadget"
      Case #PB_GadgetType_ExplorerCombo : Type$ ="ExplorerComboGadget"
      Case #PB_GadgetType_ExplorerList  : Type$ ="ExplorerListGadget"
      Case #PB_GadgetType_ExplorerTree  : Type$ ="ExplorerTreeGadget"
      Case #PB_GadgetType_Frame         : Type$ ="FrameGadget"
      Case #PB_GadgetType_HyperLink     : Type$ ="HyperLinkGadget"
      Case #PB_GadgetType_Image         : Type$ ="ImageGadget"
      Case #PB_GadgetType_IPAddress     : Type$ ="IPAddressGadget"
      Case #PB_GadgetType_ListIcon      : Type$ ="ListIconGadget"
      Case #PB_GadgetType_ListView      : Type$ ="ListViewGadget"
      Case #PB_GadgetType_MDI           : Type$ ="MDIGadget"
      Case #PB_GadgetType_Option        : Type$ ="OptionGadget"
      Case #PB_GadgetType_Panel         : Type$ ="PanelGadget"
      Case #PB_GadgetType_ProgressBar   : Type$ ="ProgressBarGadget"
      Case #PB_GadgetType_Scintilla     : Type$ ="ScintillaGadget"
      Case #PB_GadgetType_ScrollArea    : Type$ ="ScrollAreaGadget"
      Case #PB_GadgetType_ScrollBar     : Type$ ="ScrollBarGadget"
      Case #PB_GadgetType_Shortcut      : Type$ ="ShortcutGadget"
      Case #PB_GadgetType_Spin          : Type$ ="SpinGadget"
      Case #PB_GadgetType_Splitter      : Type$ ="SplitterGadget"
      Case #PB_GadgetType_String        : Type$ ="StringGadget"
      Case #PB_GadgetType_Text          : Type$ ="TextGadget"
      Case #PB_GadgetType_TrackBar      : Type$ ="TrackBarGadget"
      Case #PB_GadgetType_Tree          : Type$ ="TreeGadget"
      Case #PB_GadgetType_Web           : Type$ ="WebGadget"
      Case #PB_GadgetType_WebView       : Type$ ="WebViewGadget" 
      Case #PB_GadgetType_Unknown       : Type$ ="unknown"
    EndSelect
    ProcedureReturn Type$
  EndProcedure
  
  Procedure.s CreateGadgetCode(GadgetNo)
    Protected.s code, text, flags, AddFlag
    Protected ggPos.TGadgetPos
    Protected ggType, ggState
    
    #_DQ = Chr('"')
    #_AddFlag = Chr('|')
    
    If IsGadget(GadgetNo)
      ggType = GadgetType(GadgetNo)
      GetGadgetPos(GadgetNo, ggPos)
      
      With ggPos
        code = GetGadgetTypeName(GadgetNo)+ "(" + Str(GadgetNo) + "," + Str(\X) + "," + Str(\y) + "," + Str(\W) + "," + Str(\H)
      EndWith
       
      Select ggType                        
        Case #PB_GadgetType_Button
          ;- --------------------
          ;- ButtonGadget
          ;  --------------------
          
          ; #PB_Button_Right, #PB_Button_Left, #PB_Button_Default, #PB_Button_MultiLine, #PB_Button_Toggle           
          ggState = GetGadgetState(GadgetNo)    
          
          If ggState & #PB_Button_Right
            flags = "#PB_Button_Right"   
          EndIf
          
          If ggState & #PB_Button_Left
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_Button_Left"   
          EndIf
          
          If ggState & #PB_Button_Default
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_Button_Default"   
          EndIf
          
          If ggState & #PB_Button_MultiLine
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_Button_MultiLine"   
          EndIf
          
          If ggState & #PB_Button_Toggle
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_Button_Toggle"   
          EndIf
             
        Case #PB_GadgetType_ButtonImage
         ; #PB_Button_Toggle 
          ggState = GetGadgetState(GadgetNo)  
          If ggState & #PB_Button_Toggle
            flags + "#PB_Button_Toggle"   
          EndIf
          
        Case #PB_GadgetType_Calendar
          ; #PB_Calendar_Borderless 
          ggState = GetGadgetState(GadgetNo)  
          If ggState & #PB_Calendar_Borderless
            flags + "#PB_Calendar_Borderless"   
          EndIf
          
        Case #PB_GadgetType_Canvas
          ; #PB_Canvas_Border, #PB_Canvas_ClipMouse, #PB_Canvas_Keyboard, #PB_Canvas_Container
          ggState = GetGadgetState(GadgetNo)  
          
          If ggState & #PB_Canvas_Border
            flags = "#PB_Canvas_Border"   
          EndIf
          
          If ggState & #PB_Canvas_ClipMouse
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_Canvas_ClipMouse"   
          EndIf
          
          If ggState & #PB_Canvas_Keyboard
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_Canvas_Keyboard"   
          EndIf
          
          If ggState & #PB_Canvas_Container
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_Canvas_Container"   
          EndIf
          
        Case #PB_GadgetType_CheckBox
         ; #PB_CheckBox_Right, #PB_CheckBox_Center, #PB_CheckBox_ThreeState 
          ggState = GetGadgetState(GadgetNo)  
          
          If ggState & #PB_CheckBox_Right
            flags = "#PB_CheckBox_Right"   
          EndIf
          
          If ggState & #PB_CheckBox_Center
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_CheckBox_Center"   
          EndIf
          
          If ggState & #PB_CheckBox_ThreeState
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_CheckBox_ThreeState"   
          EndIf
          
        Case #PB_GadgetType_ComboBox
          ggState = GetGadgetState(GadgetNo)
          ; #PB_ComboBox_Editable, #PB_ComboBox_LowerCase, #PB_ComboBox_UpperCase, #PB_ComboBox_Image     
          
          If ggState & #PB_ComboBox_Editable
            flags = "#PB_ComboBox_Editable"   
          EndIf
          
          If ggState & #PB_ComboBox_LowerCase
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_ComboBox_LowerCase"   
          EndIf
          
          If ggState & #PB_ComboBox_UpperCase
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_ComboBox_UpperCase"   
          EndIf
          
          If ggState & #PB_ComboBox_Image
            If flags : flags + #_AddFlag : EndIf
            flags + "#PB_ComboBox_Image"   
          EndIf
          
        Case #PB_GadgetType_Container
         ggState = GetGadgetState(GadgetNo)  
          
        Case #PB_GadgetType_Date
         ggState = GetGadgetState(GadgetNo)  
          
        Case #PB_GadgetType_Editor
          
        Case #PB_GadgetType_ExplorerCombo
          
        Case #PB_GadgetType_ExplorerList
          
        Case #PB_GadgetType_ExplorerTree
          
        Case #PB_GadgetType_Frame
          
        Case #PB_GadgetType_HyperLink
          
        Case #PB_GadgetType_Image
          
        Case #PB_GadgetType_IPAddress
          
        Case #PB_GadgetType_ListIcon
          
        Case #PB_GadgetType_ListView
          
        Case #PB_GadgetType_MDI
          
        Case #PB_GadgetType_Option
          
        Case #PB_GadgetType_Panel
          
        Case #PB_GadgetType_ProgressBar
          
        Case #PB_GadgetType_Scintilla
          
        Case #PB_GadgetType_ScrollArea
          
        Case #PB_GadgetType_ScrollBar
          
        Case #PB_GadgetType_Shortcut
          
        Case #PB_GadgetType_Spin
          
        Case #PB_GadgetType_Splitter
          
        Case #PB_GadgetType_String
          
        Case #PB_GadgetType_Text
          
        Case #PB_GadgetType_TrackBar
          
        Case #PB_GadgetType_Tree
          
        Case #PB_GadgetType_Web
          
        Case #PB_GadgetType_WebView
          
        Case #PB_GadgetType_Unknown
      EndSelect
        
    EndIf
    
  EndProcedure
   
EndModule

;- ----------------------------------------------------------------------
;- Test Code
;  ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; UseModule 
  
  DisableExplicit
CompilerEndIf




; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 414
; FirstLine = 410
; Folding = ---
; Optimizer
; CPU = 5