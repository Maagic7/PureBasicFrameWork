; ===========================================================================
;  FILE : PbFw_Module_X11Colors.pb
;  NAME : PureBasic Framework : Module X11Col::
;  DESC : X11 standard Colors are 145 predefined Color values with Names
;  DESC : This colors are used in many programs
;  SOURCES: https://en.wikipedia.org/wiki/X11_color_names
;           https://en.wikipedia.org/wiki/X11_color_names#Clashes_between_web_and_X11_colors_in_the_CSS_color_scheme
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/09/19
; VERSION  :  0.11 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{ 
; 2025/01/31 S.Maag :  Module PX:: included. Solved the Color oder Problem!
;                       
;}
;{ TODO:
;}
; ============================================================================


;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw:: FrameWork control Module
XIncludeFile "PbFw_Module_PX.pb"          ; PX::   PureBasic extention Module

DeclareModule X11Col
  EnableExplicit
    
  Structure TX11Color
    Name.s
    ID.i
    RGB.l
  EndStructure
  
  Structure TX11ColorDetail
    RGB.l       ; RGB Color value
    Hue.l       ; Hue ist identical for HSV and HSL ColorSpace
    HSV_S.l     ; Saturation in HSV ColorSpace
    HSV_V.l     ; Value in HSV ColorSpace
    HSL_S.l     ; Saturation in HSL ColorSpace
    HSL_L.l     ; Light in HSL ColorSpace
  EndStructure
      
  Declare Test()

  ;- ----------------------------------------------------------------------
  ;- X11 Predefined Standard COLORS
  ;- ----------------------------------------------------------------------

  Enumeration EX11ColorID 1   ; Attention! has to be same order as in DataSection; Colors are orderd by RGB-Value
   ;{ Color IDs [1..145]
    #X11Col_ID_Black
    #X11Col_ID_NavyBlue
    #X11Col_ID_DarkBlue
    #X11Col_ID_MediumBlue
    #X11Col_ID_Blue
    #X11Col_ID_DarkGreen
    #X11Col_ID_WebGreen
    #X11Col_ID_Teal
    #X11Col_ID_DarkCyan
    #X11Col_ID_DeepSkyBlue
    #X11Col_ID_DarkTurquoise
    #X11Col_ID_MediumSpringGreen
    #X11Col_ID_Green
    #X11Col_ID_Lime
    #X11Col_ID_SpringGreen
    #X11Col_ID_Aqua
    #X11Col_ID_Cyan
    #X11Col_ID_MidnightBlue
    #X11Col_ID_DodgerBlue
    #X11Col_ID_LightSeaGreen
    #X11Col_ID_ForestGreen
    #X11Col_ID_SeaGreen
    #X11Col_ID_DarkSlateGray
    #X11Col_ID_LimeGreen
    #X11Col_ID_MediumSeaGreen
    #X11Col_ID_Turquoise
    #X11Col_ID_RoyalBlue
    #X11Col_ID_SteelBlue
    #X11Col_ID_DarkSlateBlue
    #X11Col_ID_MediumTurquoise
    #X11Col_ID_Indigo
    #X11Col_ID_DarkOliveGreen
    #X11Col_ID_CadetBlue
    #X11Col_ID_CornflowerBlue
    #X11Col_ID_RebeccaPurple
    #X11Col_ID_MediumAquamarine
    #X11Col_ID_DimGray
    #X11Col_ID_SlateBlue
    #X11Col_ID_OliveDrab
    #X11Col_ID_SlateGray
    #X11Col_ID_LightSlateGray
    #X11Col_ID_MediumSlateBlue
    #X11Col_ID_LawnGreen
    #X11Col_ID_Chartreuse
    #X11Col_ID_Aquamarine
    #X11Col_ID_WebMaroon
    #X11Col_ID_WebPurple
    #X11Col_ID_Olive
    #X11Col_ID_WebGray
    #X11Col_ID_SkyBlue
    #X11Col_ID_LightSkyBlue
    #X11Col_ID_BlueViolet
    #X11Col_ID_DarkRed
    #X11Col_ID_DarkMagenta
    #X11Col_ID_SaddleBrown
    #X11Col_ID_DarkSeaGreen
    #X11Col_ID_LightGreen
    #X11Col_ID_MediumPurple
    #X11Col_ID_DarkViolet
    #X11Col_ID_PaleGreen
    #X11Col_ID_DarkOrchid
    #X11Col_ID_YellowGreen
    #X11Col_ID_Purple
    #X11Col_ID_Sienna
    #X11Col_ID_Brown
    #X11Col_ID_DarkGray
    #X11Col_ID_LightBlue
    #X11Col_ID_GreenYellow
    #X11Col_ID_PaleTurquoise
    #X11Col_ID_Maroon
    #X11Col_ID_LightSteelBlue
    #X11Col_ID_PowderBlue
    #X11Col_ID_Firebrick
    #X11Col_ID_DarkGoldenrod
    #X11Col_ID_MediumOrchid
    #X11Col_ID_RosyBrown
    #X11Col_ID_DarkKhaki
    #X11Col_ID_Gray
    #X11Col_ID_Silver
    #X11Col_ID_MediumVioletRed
    #X11Col_ID_IndianRed
    #X11Col_ID_Peru
    #X11Col_ID_Chocolate
    #X11Col_ID_Tan
    #X11Col_ID_LightGray
    #X11Col_ID_Thistle
    #X11Col_ID_Orchid
    #X11Col_ID_Goldenrod
    #X11Col_ID_PaleVioletRed
    #X11Col_ID_Crimson
    #X11Col_ID_Gainsboro
    #X11Col_ID_Plum
    #X11Col_ID_Burlywood
    #X11Col_ID_LightCyan
    #X11Col_ID_Lavender
    #X11Col_ID_DarkSalmon
    #X11Col_ID_Violet
    #X11Col_ID_PaleGoldenrod
    #X11Col_ID_LightCoral
    #X11Col_ID_Khaki
    #X11Col_ID_AliceBlue
    #X11Col_ID_Honeydew
    #X11Col_ID_Azure
    #X11Col_ID_SandyBrown
    #X11Col_ID_Wheat
    #X11Col_ID_Beige
    #X11Col_ID_WhiteSmoke
    #X11Col_ID_MintCream
    #X11Col_ID_GhostWhite
    #X11Col_ID_Salmon
    #X11Col_ID_AntiqueWhite
    #X11Col_ID_Linen
    #X11Col_ID_LightGoldenrod
    #X11Col_ID_OldLace
    #X11Col_ID_Red
    #X11Col_ID_Fuchsia
    #X11Col_ID_Magenta
    #X11Col_ID_DeepPink
    #X11Col_ID_OrangeRed
    #X11Col_ID_Tomato
    #X11Col_ID_HotPink
    #X11Col_ID_Coral
    #X11Col_ID_DarkOrange
    #X11Col_ID_LightSalmon
    #X11Col_ID_Orange
    #X11Col_ID_LightPink
    #X11Col_ID_Pink
    #X11Col_ID_Gold
    #X11Col_ID_PeachPuff
    #X11Col_ID_NavajoWhite
    #X11Col_ID_Moccasin
    #X11Col_ID_Bisque
    #X11Col_ID_MistyRose
    #X11Col_ID_BlanchedAlmond
    #X11Col_ID_PapayaWhip
    #X11Col_ID_LavenderBlush
    #X11Col_ID_Seashell
    #X11Col_ID_Cornsilk
    #X11Col_ID_LemonChiffon
    #X11Col_ID_FloralWhite
    #X11Col_ID_Snow
    #X11Col_ID_Yellow
    #X11Col_ID_LightYellow
    #X11Col_ID_Ivory
    #X11Col_ID_White
  ;}
  EndEnumeration  
  
  Declare.i GetColorList(List *ColorList.TX11Color())
  Declare.i SearchColorByName(Name.s)       ; Returns the ColorID for GetColorDetails
  Declare.i SearchColorByRGB(RGB.l)         ; Returns the ColorID for GetColorDetails
  Declare.i SearchColorByHSV(H.l, S.l, V.l) ; Returns the ColorID for GetColorDetails
  Declare.i SearchColorByHSL(H.l, S.l, L.l) ; Returns the ColorID for GetColorDetails
  Declare.s GetColorName(ColorID)           ; Returns the Name of the Color
  Declare.l GetRGB(ColorID, Alpha=255)      ; Returns the RGB ColorValue and add Alpha
  Declare.i GetColorDetails(*OutTColorTableEntry, ColorID)
  Declare.i GetMaxColorID()                 ; Returns the maximum ColorID [1..145]
  
  Macro mac_X11Col(ColorID)
    X11::ColTable(ColorID)  
  EndMacro
  
EndDeclareModule 

Module X11Col
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)   ; Lists the Module in the ModuleList (for statistics)
   
  ;- ----------------------------------------------------------------------
  ;- private
  ;- ----------------------------------------------------------------------

  Structure TX11ColorEntry
    Name.s
    *Details.TX11ColorDetail      ; TX11ColorDetail is a public Structure
  EndStructure
  
  Structure pColorTable  ; virtual Array Structure to overlay on Datasection X11_Colors
    row.TX11ColorDetail[0]  
  EndStructure
    
  ; TODO! Change #ColTableEntries if you change NoOfColors in DataSection!
  #ColTableEntries = 145  ; [1..145]
  Global Dim ColorTable.TX11ColorEntry(#ColTableEntries)
  Global Dim IndexTable_Name.i(#ColTableEntries) ; This Array contains the ID's sorted by the ColorNames
  
  Procedure _Init()
  ; ============================================================================
  ; NAME: _Init
  ; DESC: Init the ColorTable Array
  ; RET : -
  ; ============================================================================
    Protected I, sName$
    Protected *pTab.pColorTable  ; Pointer to ColorDetails in DataSection
    Protected NewList ColorLst.TX11Color()
    
    Debug "**** INIT ****"
     
    ; ----------------------------------------------------------------------
    ; Read Datasection Strings until End [""] is reached 
    ; and add Names to a temporary List()
    ; ----------------------------------------------------------------------
    Restore X11_Names  ; Jump to Datasection X11_Names:
    For I = 1 To #ColTableEntries
      Read.s sName$                 ; Read Next Entry in Datasection
      AddElement(ColorLst())        ; add new Element to ColorLst
      ColorLst()\Name = sName$
      ColorLst()\ID = I
    Next
           
    ; ----------------------------------------------------------------------
    ; create the ColorTable() Array    
    ; ----------------------------------------------------------------------
    *pTab  = ?X11_Colors            ; overlay virtual Structre-Array on Datasection, ColorDetails of X11 colors 
    ; Debug "?X11_Colors = " + Str(*pTab)
    I=0    
    ForEach ColorLst()
      With ColorTable(I)
        \Name = ColorLst()\Name
        \Details = *pTab\row[I]     ; Details is a Pointer *Details! Set the *Details = PointerOf (DataRow) 
      EndWith
      ColorLst()\RGB = ColorTable(I)\Details\RGB
      I + 1
    Next
        
    ; ----------------------------------------------------------------------
    ; create IndexTable_Name with ID sorted by ColorNames 
    ; this IndexTable is used for SearchColorByName
    ; ----------------------------------------------------------------------
    SortStructuredList(ColorLst(), #PB_Sort_Ascending + #PB_Sort_NoCase, OffsetOf(TX11Color\Name), TypeOf(TX11Color\Name))
    
    ; Debug " **** Sorted Colors **** "
    I = 0
    ForEach ColorLst()
      IndexTable_Name(I) = ColorLst()\ID  
      ; Debug Str(I) + " : " + IndexTable_Name(I) + " : " + ColorLst()\Name  
      I +1
    Next
  EndProcedure
  
  Structure TX11ColorFull
    ID.i
    Name.s
    RGB.l       ; RGB Color value
    Hue.l       ; Hue ist identical for HSV and HSL ColorSpace
    HSV_S.l     ; Saturation in HSV ColorSpace
    HSV_V.l     ; Value in HSV ColorSpace
    HSL_S.l     ; Saturation in HSL ColorSpace
    HSL_L.l     ; Light in HSL ColorSpace
  EndStructure
  
  Procedure.s Format(Value.l, L=3)
    Protected txt.s 
    Protected n
    
    txt = Str(Value)
    n = L-Len(txt)
    If n > 0
      txt = Space(n) + txt  
    EndIf
    
    ProcedureReturn txt   
  EndProcedure
  
  Procedure.s FormatHex(Value.l, L=6)
    Protected txt.s 
    Protected n
    
    txt = Hex(Value)
    n = L-Len(txt)
    If n > 0
      txt = Space(n) + txt
      txt = ReplaceString(txt, " ", "0")
    EndIf
    ProcedureReturn "$" + txt   
  EndProcedure
   
  
  Procedure CreateDataSection()
    Protected NewList Lst.TX11ColorFull()
    Protected I 
    Protected.s ClipBoard, row
    
    For I = 0 To #ColTableEntries -1 
      AddElement(Lst())
      With Lst()
        \ID = I+1
        \Name = ColorTable(I)\Name
        \RGB = ColorTable(I)\Details\RGB
        \Hue = ColorTable(I)\Details\Hue
        \HSV_S = ColorTable(I)\Details\HSV_S
        \HSV_V = ColorTable(I)\Details\HSV_V
        \HSL_S = ColorTable(I)\Details\HSL_S
        \HSL_L = ColorTable(I)\Details\HSL_L
      EndWith    
    Next
    
    SortStructuredList(lst(),#PB_Sort_Ascending, OffsetOf(TX11ColorFull\RGB), TypeOf(TX11ColorFull\RGB))
    
    ;      RGB, Hue[°], HSV_S[%], HSV_V[%], HSL_S[%], HSL_L[%]           
   ; Data.l $F0F8FF, 208,   6, 100, 100,  97 ; Alice Blue

    Debug ""
    Debug "*****   RGB Sorted List ****"
    ForEach Lst()
      With lst()
        Debug Hex(\RGB,#PB_Long) + " : " + \Name   
        
        ; row = "#X11Col_ID_" + ReplaceString(\Name," ", "")
        ; row = "Data.s " + Chr('"') + \Name + Chr('"')
        row = "Data.l " + FormatHex(\RGB) + ", " + Format(\Hue) + ", " + Format(\HSV_V) + ", " + Format(\HSV_S) + ", " + Format(\HSL_S) + ", "  + Format(\HSL_L)
        row + " ; " + \Name
        ClipBoard = ClipBoard + row +  #CRLF$
      EndWith
     
    Next
    SetClipboardText(ClipBoard)
    
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Public
  ;- ----------------------------------------------------------------------
  
  Procedure.i GetColorList(List *ColorList.TX11Color())
  ; ============================================================================
  ; NAME: GetColorList
  ; DESC: Get a full List of X11 Colors with Name, ID, RGB
  ; VAR(List *ColorList.TX11Color) : Pointer to the retrurn List
  ; RET.i : Number of Colors in the List
  ; ============================================================================
    Protected I
    
    If *ColorList()
      ClearList(*ColorList()) 
      For I = 0 To #ColTableEntries
        AddElement(*ColorList())
        With *ColorList()
          \ID = I +1
          \Name = ColorTable(I)\Name
          \RGB = ColorTable(I)\Details\RGB
        EndWith       
      Next
      ProcedureReturn I+1  
    EndIf
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i SearchColorByName(Name.s)
  ; ============================================================================
  ; NAME: SearchColorByName
  ; DESC: Search the X11 Color by Name and return the Color ID
  ; VAR(Name.s) : ColorName
  ; RET.i : X11 Color ID [1..145], 0 if Color do not exist in the X11 Table
  ; ============================================================================
    Protected I, start, up
    
    start = (#ColTableEntries-1) >> 1    ; starting in the middle of the table
    
    Name = LCase(ReplaceString(Name, " ", ""))
    
    If Name < LCase(ColorTable(IndexTable_Name(start))\Name)  ; Search form the middle down
      ; RGB < than middle element => Step down in 50% steps  
      While start > 0 And Name <  LCase(ColorTable(IndexTable_Name(start))\Name)
        start >> 1    ; / 2
      Wend
      
      For I = start To Start * 2
        If  Name =  LCase(ColorTable(IndexTable_Name(start))\Name)
          ProcedureReturn I +1
        EndIf    
      Next     
    Else      ; Search form the middle up
     
      up = #ColTableEntries >> 2 ; / 4 = 50% of half
      
      While start < #ColTableEntries-1 And Name >  LCase(ColorTable(IndexTable_Name(start))\Name)
        start + up  
        up >> 1   ; up/2 => 50% step up
        If up = 0
          start = #ColTableEntries-1   ; set StartSearch to last element of table
          Break 
        EndIf  
      Wend
      
      For I = start To (#ColTableEntries-1)>>1 Step - 1
        If  Name =  LCase(ColorTable(IndexTable_Name(start))\Name)
          ProcedureReturn I +1
        EndIf    
      Next    
    EndIf

;     For I = 0 To #ColTableEntries
;       If Name = ColorTable(I)\Name
;         ProcedureReturn I +1  
;       EndIf
;     Next
    
    ProcedureReturn  0
  EndProcedure
    
  Procedure.i SearchColorByRGB(RGB.l)
  ; ============================================================================
  ; NAME: SearchColorByRGB
  ; DESC: Search the X11 Color by the RGB Value and return the Color ID
  ; VAR(RGB.l) : RGB Color Value. Alpha will be ignored!
  ; RET.i : X11 Color ID [1..145], 0 if Color do not exist in the X11 Table
  ; ============================================================================
    Protected I, start, up
    ;Protected n  ; number of search steps, for debug only
    
    ; because it is a RGB sorted table, we can start in the middle for an
    ; effectiv search
    
    RGB = PX::SetAlpha(RGB, 0)     ; Remove Alpha Channel

    start = (#ColTableEntries-1) >> 1    ; starting in the middle of the table
    
     If RGB < ColorTable(start)\Details\RGB       ; Search form the middle down

      ; RGB < than middle element => Step down in 50% steps  
      While start > 0 And RGB < ColorTable(start)\Details\RGB
        start >> 1    ; / 2
        ; n + 1
      Wend
      ; Debug "Start = " + Str(start)
      
      For I = start To Start *2
        ; n + 1
        If  RGB = ColorTable(I)\Details\RGB
          ; Debug "Search Steps = " + Str(n)
         ProcedureReturn I +1
        EndIf    
      Next     
      
    Else        ; Search form the middle up

      up = #ColTableEntries >> 2 ; / 4 = 50% of half
      
      While start < #ColTableEntries-1 And RGB > ColorTable(start)\Details\RGB
 ;       Debug Hex(RGB) + " : " + Hex(ColorTable(start)\Details\RGB) + " : " + Str(start) + " : up = " +Str(up)
        ; n + 1
        start + up  
        up >> 1   ; up/2 => 50% step up
        If up = 0
          start = #ColTableEntries-1 ; set StartSearch to last element of table
          Break 
        EndIf  
      Wend
      
      ; Debug "Start single step search at = " +start 
      For I = start To (#ColTableEntries-1)>>1 Step - 1
       ; n + 1
       If  RGB = ColorTable(I)\Details\RGB
         ; Debug "Search Steps = " + Str(n)
          ProcedureReturn I +1
        EndIf    
      Next    
    EndIf
      
    ; Debug "Search Steps = " + Str(n)
    ProcedureReturn  0
  EndProcedure 
  
  Procedure.i SearchColorByHSV(H.l, S.l, V.l)
  ; ============================================================================
  ; NAME: SearchColorByHSV
  ; DESC: Search the X11 Color by the HSV Values and return the Color ID
  ; VAR(H.l) : Hue
  ; VAR(S.l) : Saturation
  ; VAR(V.l) : Value   
  ; RET.i : X11 Color ID [1..145], 0 if Color do not exist in the X11 Table
  ; ============================================================================
   Protected I
        
    For I = 0 To #ColTableEntries
      With ColorTable(I)\Details
        If  H = \Hue
          If S = \HSV_S And V = \HSV_V
            ProcedureReturn I +1
          EndIf
        EndIf
      EndWith
    Next
    ProcedureReturn  0
  EndProcedure
  
  Procedure.i SearchColorByHSL(H.l, S.l, L.l)
  ; ============================================================================
  ; NAME: SearchColorByHSL
  ; DESC: Search the X11 Color by the HSV Values and return the Color ID
  ; VAR(H.l) : Hue
  ; VAR(S.l) : Saturation
  ; VAR(L.l) : Light   
  ; RET.i : X11 Color ID [1..145], 0 if Color do not exist in the X11 Table
  ; ============================================================================
    Protected I
        
    For I = 0 To #ColTableEntries
      With ColorTable(I)\Details
        If  H = \Hue
          If S = \HSL_S And L = \HSL_L
            ProcedureReturn I +1
          EndIf
        EndIf
      EndWith
    Next
    ProcedureReturn  0
  EndProcedure 
  
  Procedure.s GetColorName(ColorID)  
  ; ============================================================================
  ; NAME: GetColorName
  ; DESC: Get the ColorName by ColorID
  ; VAR(ColorID) : The Color ID [1..145] or #X11Col_ID_AliceBlue ...
  ; RET.s : X11 Color Name like "Alice Blue"
  ; ============================================================================
    If ColorID >0 And ColorID <= #ColTableEntries
      ProcedureReturn ColorTable(ColorID-1)\Name
    EndIf
  EndProcedure
  
  Procedure.l GetRGB(ColorID, Alpha=255)
  ; ============================================================================
  ; NAME: GetRGB
  ; DESC: Get the Color RGB Value by ColorID
  ; VAR(ColorID) : The Color ID [1..145] or #X11Col_ID_AliceBlue ...
  ; RET.l : RGB-Color-Value, Alpha = 0 Name like "Alice Blue"
  ; ============================================================================
    Protected col.l
    
    If ColorID >0 And ColorID <= #ColTableEntries
      col = ColorTable(ColorID)\Details\RGB
      If Alpha
        col = PX::SetAlpha(col, Alpha)
      EndIf      
    EndIf
    
    ProcedureReturn col
  EndProcedure

  Procedure.i GetColorDetails(ColorID, *Out.TX11ColorDetail)
  ; ============================================================================
  ; NAME: GetColorDetails
  ; DESC: Get the Color Details as Structure 
  ; VAR(ColorID) : The Color ID [1..145] or #X11Col_ID_AliceBlue ...
  ; VAR(*Out.TX11ColorDetail) : Pointer to the Return Variable
  ; RET.i : *Out
  ; ============================================================================
    
    If *Out
      If ColorID >0 And ColorID <= #ColTableEntries
        CopyStructure(ColorTable(ColorID), *Out, TX11ColorDetail)
        ProcedureReturn *Out
      EndIf
    EndIf
    
    ProcedureReturn  0
  EndProcedure

  Procedure.i GetMaxColorID()
  ; ============================================================================
  ; NAME: GetMaxColorID
  ; DESC: Return the maximumn ColorID
  ; RET.i : Max Color ID = [145]
  ; ============================================================================
    ProcedureReturn #ColTableEntries
  EndProcedure
   
 ; ----------------------------------------------------------
  
  Procedure Test()
    
    CreateDataSection()
    
     
  EndProcedure
   
  _Init()
  
  ; X11 color names
  ; ----------------------------------------------------------
   
  DataSection ; RGB sorted ColorList
    ; https://en.wikipedia.org/wiki/X11_color_names#Clashes_between_web_and_X11_colors_in_the_CSS_color_scheme
    X11_Names: 
    Data.s "Black"
    Data.s "Navy Blue"
    Data.s "Dark Blue"
    Data.s "Medium Blue"
    Data.s "Blue"
    Data.s "Dark Green"
    Data.s "Web Green"
    Data.s "Teal"
    Data.s "Dark Cyan"
    Data.s "Deep Sky Blue"
    Data.s "Dark Turquoise"
    Data.s "Medium Spring Green"
    Data.s "Green"
    Data.s "Lime"
    Data.s "Spring Green"
    Data.s "Aqua"
    Data.s "Cyan"
    Data.s "Midnight Blue"
    Data.s "Dodger Blue"
    Data.s "Light Sea Green"
    Data.s "Forest Green"
    Data.s "Sea Green"
    Data.s "Dark Slate Gray"
    Data.s "Lime Green"
    Data.s "Medium Sea Green"
    Data.s "Turquoise"
    Data.s "Royal Blue"
    Data.s "Steel Blue"
    Data.s "Dark Slate Blue"
    Data.s "Medium Turquoise"
    Data.s "Indigo"
    Data.s "Dark Olive Green"
    Data.s "Cadet Blue"
    Data.s "Cornflower Blue"
    Data.s "Rebecca Purple"
    Data.s "Medium Aquamarine"
    Data.s "Dim Gray"
    Data.s "Slate Blue"
    Data.s "Olive Drab"
    Data.s "Slate Gray"
    Data.s "Light Slate Gray"
    Data.s "Medium Slate Blue"
    Data.s "Lawn Green"
    Data.s "Chartreuse"
    Data.s "Aquamarine"
    Data.s "Web Maroon"
    Data.s "Web Purple"
    Data.s "Olive"
    Data.s "Web Gray"
    Data.s "Sky Blue"
    Data.s "Light Sky Blue"
    Data.s "Blue Violet"
    Data.s "Dark Red"
    Data.s "Dark Magenta"
    Data.s "Saddle Brown"
    Data.s "Dark Sea Green"
    Data.s "Light Green"
    Data.s "Medium Purple"
    Data.s "Dark Violet"
    Data.s "Pale Green"
    Data.s "Dark Orchid"
    Data.s "Yellow Green"
    Data.s "Purple"
    Data.s "Sienna"
    Data.s "Brown"
    Data.s "Dark Gray"
    Data.s "Light Blue"
    Data.s "Green Yellow"
    Data.s "Pale Turquoise"
    Data.s "Maroon"
    Data.s "Light Steel Blue"
    Data.s "Powder Blue"
    Data.s "Firebrick"
    Data.s "Dark Goldenrod"
    Data.s "Medium Orchid"
    Data.s "Rosy Brown"
    Data.s "Dark Khaki"
    Data.s "Gray"
    Data.s "Silver"
    Data.s "Medium Violet Red"
    Data.s "Indian Red"
    Data.s "Peru"
    Data.s "Chocolate"
    Data.s "Tan"
    Data.s "Light Gray"
    Data.s "Thistle"
    Data.s "Orchid"
    Data.s "Goldenrod"
    Data.s "Pale Violet Red"
    Data.s "Crimson"
    Data.s "Gainsboro"
    Data.s "Plum"
    Data.s "Burlywood"
    Data.s "Light Cyan"
    Data.s "Lavender"
    Data.s "Dark Salmon"
    Data.s "Violet"
    Data.s "Pale Goldenrod"
    Data.s "Light Coral"
    Data.s "Khaki"
    Data.s "Alice Blue"
    Data.s "Honeydew"
    Data.s "Azure"
    Data.s "Sandy Brown"
    Data.s "Wheat"
    Data.s "Beige"
    Data.s "White Smoke"
    Data.s "Mint Cream"
    Data.s "Ghost White"
    Data.s "Salmon"
    Data.s "Antique White"
    Data.s "Linen"
    Data.s "Light Goldenrod"
    Data.s "Old Lace"
    Data.s "Red"
    Data.s "Fuchsia"
    Data.s "Magenta"
    Data.s "Deep Pink"
    Data.s "Orange Red"
    Data.s "Tomato"
    Data.s "Hot Pink"
    Data.s "Coral"
    Data.s "Dark Orange"
    Data.s "Light Salmon"
    Data.s "Orange"
    Data.s "Light Pink"
    Data.s "Pink"
    Data.s "Gold"
    Data.s "Peach Puff"
    Data.s "Navajo White"
    Data.s "Moccasin"
    Data.s "Bisque"
    Data.s "Misty Rose"
    Data.s "Blanched Almond"
    Data.s "Papaya Whip"
    Data.s "Lavender Blush"
    Data.s "Seashell"
    Data.s "Cornsilk"
    Data.s "Lemon Chiffon"
    Data.s "Floral White"
    Data.s "Snow"
    Data.s "Yellow"
    Data.s "Light Yellow"
    Data.s "Ivory"
    Data.s "White"
    Data.s ""               ; End! Use "" because #Null$ do not work correctly here
    
    X11_Colors: ; RGB sorted ColorList - Attention Unix notation $RGB, for Windows we need $BGR
     ;     $BGR, Hue[°], HSV_S[%], HSV_V[%], HSL_S[%], HSL_L[%]           
    Data.l $000000,   0,   0,   0,   0,   0 ; Black
    Data.l $000080, 240,  50, 100, 100,  25 ; Navy Blue
    Data.l $00008B, 240,  55, 100, 100,  27 ; Dark Blue
    Data.l $0000CD, 240,  80, 100, 100,  40 ; Medium Blue
    Data.l $0000FF, 240, 100, 100, 100,  50 ; Blue
    Data.l $006400, 120,  39, 100, 100,  20 ; Dark Green
    Data.l $008000, 120,  50, 100, 100,  25 ; Web Green
    Data.l $008080, 180,  50, 100, 100,  25 ; Teal
    Data.l $008B8B, 180,  55, 100, 100,  27 ; Dark Cyan
    Data.l $00BFFF, 195, 100, 100, 100,  50 ; Deep Sky Blue
    Data.l $00CED1, 181,  82, 100, 100,  41 ; Dark Turquoise
    Data.l $00FA9A, 157,  98, 100, 100,  49 ; Medium Spring Green
    Data.l $00FF00, 120, 100, 100, 100,  50 ; Green
    Data.l $00FF00, 120, 100, 100, 100,  50 ; Lime
    Data.l $00FF7F, 150, 100, 100, 100,  50 ; Spring Green
    Data.l $00FFFF, 180, 100, 100, 100,  50 ; Aqua
    Data.l $00FFFF, 180, 100, 100, 100,  50 ; Cyan
    Data.l $191970, 240,  44,  78,  64,  27 ; Midnight Blue
    Data.l $1E90FF, 210, 100,  88, 100,  56 ; Dodger Blue
    Data.l $20B2AA, 177,  70,  82,  70,  41 ; Light Sea Green
    Data.l $228B22, 120,  55,  76,  61,  34 ; Forest Green
    Data.l $2E8B57, 146,  55,  67,  50,  36 ; Sea Green
    Data.l $2F4F4F, 180,  31,  41,  25,  25 ; Dark Slate Gray
    Data.l $32CD32, 120,  80,  76,  61,  50 ; Lime Green
    Data.l $3CB371, 147,  70,  66,  50,  47 ; Medium Sea Green
    Data.l $40E0D0, 174,  88,  71,  72,  57 ; Turquoise
    Data.l $4169E1, 225,  88,  71,  73,  57 ; Royal Blue
    Data.l $4682B4, 207,  71,  61,  44,  49 ; Steel Blue
    Data.l $483D8B, 248,  55,  56,  39,  39 ; Dark Slate Blue
    Data.l $48D1CC, 178,  82,  66,  60,  55 ; Medium Turquoise
    Data.l $4B0082, 275,  51, 100, 100,  26 ; Indigo
    Data.l $556B2F,  82,  42,  56,  39,  30 ; Dark Olive Green
    Data.l $5F9EA0, 182,  63,  41,  26,  50 ; Cadet Blue
    Data.l $6495ED, 219,  93,  58,  79,  66 ; Cornflower Blue
    Data.l $663399, 270,  60,  67,  50,  40 ; Rebecca Purple
    Data.l $66CDAA, 160,  80,  50,  51,  60 ; Medium Aquamarine
    Data.l $696969,   0,  41,   0,   0,  41 ; Dim Gray
    Data.l $6A5ACD, 248,  80,  56,  54,  58 ; Slate Blue
    Data.l $6B8E23,  80,  56,  75,  61,  35 ; Olive Drab
    Data.l $708090, 210,  56,  22,  13,  50 ; Slate Gray
    Data.l $778899, 210,  60,  22,  14,  53 ; Light Slate Gray
    Data.l $7B68EE, 249,  93,  56,  80,  67 ; Medium Slate Blue
    Data.l $7CFC00,  90,  99, 100, 100,  49 ; Lawn Green
    Data.l $7FFF00,  90, 100, 100, 100,  50 ; Chartreuse
    Data.l $7FFFD4, 160, 100,  50, 100,  75 ; Aquamarine
    Data.l $800000,   0,  50, 100, 100,  25 ; Web Maroon
    Data.l $800080, 300,  50, 100, 100,  25 ; Web Purple
    Data.l $808000,  60,  50, 100, 100,  25 ; Olive
    Data.l $808080,   0,  50,   0,   0,  50 ; Web Gray
    Data.l $87CEEB, 197,  92,  43,  71,  73 ; Sky Blue
    Data.l $87CEFA, 203,  98,  46,  92,  76 ; Light Sky Blue
    Data.l $8A2BE2, 271,  89,  81,  76,  53 ; Blue Violet
    Data.l $8B0000,   0,  55, 100, 100,  27 ; Dark Red
    Data.l $8B008B, 300,  55, 100, 100,  27 ; Dark Magenta
    Data.l $8B4513,  25,  55,  86,  76,  31 ; Saddle Brown
    Data.l $8FBC8F, 120,  74,  24,  25,  65 ; Dark Sea Green
    Data.l $90EE90, 120,  93,  39,  73,  75 ; Light Green
    Data.l $9370DB, 260,  86,  49,  60,  65 ; Medium Purple
    Data.l $9400D3, 282,  83, 100, 100,  41 ; Dark Violet
    Data.l $98FB98, 120,  98,  39,  93,  79 ; Pale Green
    Data.l $9932CC, 280,  80,  75,  61,  50 ; Dark Orchid
    Data.l $9ACD32,  80,  80,  76,  61,  50 ; Yellow Green
    Data.l $A020F0, 277,  94,  87,  87,  53 ; Purple
    Data.l $A0522D,  19,  63,  72,  56,  40 ; Sienna
    Data.l $A52A2A,   0,  65,  75,  59,  41 ; Brown
    Data.l $A9A9A9,   0,  66,   0,   0,  66 ; Dark Gray
    Data.l $ADD8E6, 195,  90,  25,  53,  79 ; Light Blue
    Data.l $ADFF2F,  84, 100,  82, 100,  59 ; Green Yellow
    Data.l $AFEEEE, 180,  93,  26,  65,  81 ; Pale Turquoise
    Data.l $B03060, 338,  69,  73,  57,  44 ; Maroon
    Data.l $B0C4DE, 214,  87,  21,  41,  78 ; Light Steel Blue
    Data.l $B0E0E6, 187,  90,  23,  52,  80 ; Powder Blue
    Data.l $B22222,   0,  70,  81,  68,  42 ; Firebrick
    Data.l $B8860B,  43,  72,  94,  89,  38 ; Dark Goldenrod
    Data.l $BA55D3, 288,  83,  60,  59,  58 ; Medium Orchid
    Data.l $BC8F8F,   0,  74,  24,  25,  65 ; Rosy Brown
    Data.l $BDB76B,  56,  74,  43,  38,  58 ; Dark Khaki
    Data.l $BEBEBE,   0,  75,   0,   0,  75 ; Gray
    Data.l $C0C0C0,   0,  75,   0,   0,  75 ; Silver
    Data.l $C71585, 322,  78,  89,  81,  43 ; Medium Violet Red
    Data.l $CD5C5C,   0,  80,  55,  53,  58 ; Indian Red
    Data.l $CD853F,  30,  80,  69,  59,  53 ; Peru
    Data.l $D2691E,  25,  82,  86,  75,  47 ; Chocolate
    Data.l $D2B48C,  34,  82,  33,  44,  69 ; Tan
    Data.l $D3D3D3,   0,  83,   0,   0,  83 ; Light Gray
    Data.l $D8BFD8, 300,  85,  12,  24,  80 ; Thistle
    Data.l $DA70D6, 302,  85,  49,  59,  65 ; Orchid
    Data.l $DAA520,  43,  85,  85,  74,  49 ; Goldenrod
    Data.l $DB7093, 340,  86,  49,  60,  65 ; Pale Violet Red
    Data.l $DC143C, 348,  86,  91,  83,  47 ; Crimson
    Data.l $DCDCDC,   0,  86,   0,   0,  86 ; Gainsboro
    Data.l $DDA0DD, 300,  87,  28,  47,  75 ; Plum
    Data.l $DEB887,  34,  87,  39,  57,  70 ; Burlywood
    Data.l $E0FFFF, 180, 100,  12, 100,  94 ; Light Cyan
    Data.l $E6E6FA, 240,  98,   8,  67,  94 ; Lavender
    Data.l $E9967A,  15,  91,  48,  72,  70 ; Dark Salmon
    Data.l $EE82EE, 300,  93,  45,  76,  72 ; Violet
    Data.l $EEE8AA,  55,  93,  29,  67,  80 ; Pale Goldenrod
    Data.l $F08080,   0,  94,  47,  79,  72 ; Light Coral
    Data.l $F0E68C,  54,  94,  42,  77,  75 ; Khaki
    Data.l $F0F8FF, 208, 100,   6, 100,  97 ; Alice Blue
    Data.l $F0FFF0, 120, 100,   6, 100,  97 ; Honeydew
    Data.l $F0FFFF, 180, 100,   6, 100,  97 ; Azure
    Data.l $F4A460,  28,  96,  61,  87,  67 ; Sandy Brown
    Data.l $F5DEB3,  39,  96,  27,  77,  83 ; Wheat
    Data.l $F5F5DC,  60,  96,  10,  56,  91 ; Beige
    Data.l $F5F5F5,   0,  96,   0,   0,  96 ; White Smoke
    Data.l $F5FFFA, 150, 100,   4, 100,  98 ; Mint Cream
    Data.l $F8F8FF, 240, 100,   3, 100,  99 ; Ghost White
    Data.l $FA8072,   6,  98,  54,  93,  71 ; Salmon
    Data.l $FAEBD7,  34,  98,  14,  78,  91 ; Antique White
    Data.l $FAF0E6,  30,  98,   8,  67,  94 ; Linen
    Data.l $FAFAD2,  60,  98,  16,  80,  90 ; Light Goldenrod
    Data.l $FDF5E6,  39,  99,   9,  85,  95 ; Old Lace
    Data.l $FF0000,   0, 100, 100, 100,  50 ; Red
    Data.l $FF00FF, 300, 100, 100, 100,  50 ; Fuchsia
    Data.l $FF00FF, 300, 100, 100, 100,  50 ; Magenta
    Data.l $FF1493, 328, 100,  92, 100,  54 ; Deep Pink
    Data.l $FF4500,  16, 100, 100, 100,  50 ; Orange Red
    Data.l $FF6347,   9, 100,  72, 100,  64 ; Tomato
    Data.l $FF69B4, 330, 100,  59, 100,  71 ; Hot Pink
    Data.l $FF7F50,  16, 100,  69, 100,  66 ; Coral
    Data.l $FF8C00,  33, 100, 100, 100,  50 ; Dark Orange
    Data.l $FFA07A,  17, 100,  52, 100,  74 ; Light Salmon
    Data.l $FFA500,  39, 100, 100, 100,  50 ; Orange
    Data.l $FFB6C1, 351, 100,  29, 100,  86 ; Light Pink
    Data.l $FFC0CB, 350, 100,  25, 100,  88 ; Pink
    Data.l $FFD700,  51, 100, 100, 100,  50 ; Gold
    Data.l $FFDAB9,  28, 100,  27, 100,  86 ; Peach Puff
    Data.l $FFDEAD,  36, 100,  32, 100,  84 ; Navajo White
    Data.l $FFE4B5,  38, 100,  29, 100,  86 ; Moccasin
    Data.l $FFE4C4,  33, 100,  23, 100,  88 ; Bisque
    Data.l $FFE4E1,   6, 100,  12, 100,  94 ; Misty Rose
    Data.l $FFEBCD,  36, 100,  20, 100,  90 ; Blanched Almond
    Data.l $FFEFD5,  37, 100,  16, 100,  92 ; Papaya Whip
    Data.l $FFF0F5, 340, 100,   6, 100,  97 ; Lavender Blush
    Data.l $FFF5EE,  25, 100,   7, 100,  97 ; Seashell
    Data.l $FFF8DC,  48, 100,  14, 100,  93 ; Cornsilk
    Data.l $FFFACD,  54, 100,  20, 100,  90 ; Lemon Chiffon
    Data.l $FFFAF0,  40, 100,   6, 100,  97 ; Floral White
    Data.l $FFFAFA,   0, 100,   2, 100,  99 ; Snow
    Data.l $FFFF00,  60, 100, 100, 100,  50 ; Yellow
    Data.l $FFFFE0,  60, 100,  12, 100,  94 ; Light Yellow
    Data.l $FFFFF0,  60, 100,   6, 100,  97 ; Ivory
    Data.l $FFFFFF,   0, 100,   0,   0, 100 ; White
  EndDataSection

EndModule

; X11Col::Test()
UseModule X11Col

Define I, ID, name.s, col

Debug " *** Search results ****"

For I = 0 To 144
  col  = GetRGB(I+1)
  ID = SearchColorByRGB(col)
  name = GetColorName(ID)
  
  Debug Str(ID) + " : " + Hex(col, #PB_Long) + " : " + name 
Next

; Debug "single"
; ID = SearchColorByRGB($FFFFFF)
; Debug ID

; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 799
; FirstLine = 780
; Folding = ----
; Optimizer
; CPU = 5