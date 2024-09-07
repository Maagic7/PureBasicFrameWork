; ===========================================================================
;  FILE : PbFw_Module_PureBasic.pb
;  NAME : Module PureBasic [PB::]
;  DESC : 
;  DESC : 
;  DESC : 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/08/24
; VERSION  :  0.1 Brainstorming Version
; COMPILER :  PureBasic 6.11
; ===========================================================================
; ChangeLog:
;             
; ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"          ; PbFw::   FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"         ; DBG::    Debug Module
XIncludeFile "PbFw_Module_CodeCreation.pb"  ; CC::     Code Creation Module
XIncludeFile "PbFw_Module_String.pb"        ; STR::    String Module
XIncludeFile "PbFw_Module_FileSystem.pb"    ; FS::     FileSystem Module

;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------
DeclareModule PB
 
  EnableExplicit
  ;- ----------------------------------------------------------------------
  ;- PbFw Module local configurations
  ;- ----------------------------------------------------------------------
  #PbFwCfg_Module_CheckPointerException = #True     ; This constant must have same Name in all Modules. On/Off PoninterExeption for this Module
 
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
  
  ;- Keyword constants
  ;
  ; NOTE: These constants must be in sync with the below data section, as they
  ;   represent the numerical index of the keyword in the keywords array.
  ;   This is 1 based as the keyword array is 1 based too
  ;
  ; Used by: The Source Parser/resolving of related keywords features, as
  ;   it is faster to refer to keywords by index than by name
  Enumeration KeyWords 1
  ;{  
    #PbFw_PB_KW_Align
    #PbFw_PB_KW_And
  	#PbFw_PB_KW_Array
  	#PbFw_PB_KW_As
  
  	#PbFw_PB_KW_Break
  
  	#PbFw_PB_KW_CallDebugger
  	#PbFw_PB_KW_Case
  	#PbFw_PB_KW_CompilerCase
  	#PbFw_PB_KW_CompilerDefault
  	#PbFw_PB_KW_CompilerElse
  	#PbFw_PB_KW_CompilerElseIf
  	#PbFw_PB_KW_CompilerEndIf
  	#PbFw_PB_KW_CompilerEndSelect
  	#PbFw_PB_KW_CompilerError
  	#PbFw_PB_KW_CompilerIf
  	#PbFw_PB_KW_CompilerSelect
  	#PbFw_PB_KW_CompilerWarning
  	#PbFw_PB_KW_Continue
  
  	#PbFw_PB_KW_Data
  	#PbFw_PB_KW_DataSection
  	#PbFw_PB_KW_Debug
  	#PbFw_PB_KW_DebugLevel
  	#PbFw_PB_KW_Declare
  	#PbFw_PB_KW_DeclareC
  	#PbFw_PB_KW_DeclareCDLL
  	#PbFw_PB_KW_DeclareDLL
  	#PbFw_PB_KW_DeclareModule
  	#PbFw_PB_KW_Default
  	#PbFw_PB_KW_Define
  	#PbFw_PB_KW_Dim
  	#PbFw_PB_KW_DisableASM
  	#PbFw_PB_KW_DisableDebugger
  	#PbFw_PB_KW_DisableExplicit
  
  	#PbFw_PB_KW_Else
  	#PbFw_PB_KW_ElseIf
  	#PbFw_PB_KW_EnableASM
  	#PbFw_PB_KW_EnableDebugger
  	#PbFw_PB_KW_EnableExplicit
  	#PbFw_PB_KW_End
  	#PbFw_PB_KW_EndDataSection
  	#PbFw_PB_KW_EndDeclareModule
  	#PbFw_PB_KW_EndEnumeration
  	#PbFw_PB_KW_EndIf
  	#PbFw_PB_KW_EndImport
  	#PbFw_PB_KW_EndInterface
  	#PbFw_PB_KW_EndMacro
  	#PbFw_PB_KW_EndModule
  	#PbFw_PB_KW_EndProcedure
  	#PbFw_PB_KW_EndSelect
  	#PbFw_PB_KW_EndStructure
  	#PbFw_PB_KW_EndStructureUnion
  	#PbFw_PB_KW_EndWith
  	#PbFw_PB_KW_Enumeration
  	#PbFw_PB_KW_EnumerationBinary
  	#PbFw_PB_KW_Extends
  
  	#PbFw_PB_KW_FakeReturn
  	#PbFw_PB_KW_For
  	#PbFw_PB_KW_ForEach
  	#PbFw_PB_KW_ForEver
  
  	#PbFw_PB_KW_Global
  	#PbFw_PB_KW_Gosub
  	#PbFw_PB_KW_Goto
  
  	#PbFw_PB_KW_If
  	#PbFw_PB_KW_Import
  	#PbFw_PB_KW_ImportC
  	#PbFw_PB_KW_IncludeBinary
  	#PbFw_PB_KW_IncludeFile
  	#PbFw_PB_KW_IncludePath
  	#PbFw_PB_KW_Interface
  
  	#PbFw_PB_KW_List
  
  	#PbFw_PB_KW_Macro
  	#PbFw_PB_KW_MacroExpandedCount
  	#PbFw_PB_KW_Map
  	#PbFw_PB_KW_Module
  
  	#PbFw_PB_KW_NewList
  	#PbFw_PB_KW_NewMap
  	#PbFw_PB_KW_Next
  	#PbFw_PB_KW_Not
  
  	#PbFw_PB_KW_Or
  
  	#PbFw_PB_KW_Procedure
  	#PbFw_PB_KW_ProcedureC
  	#PbFw_PB_KW_ProcedureCDLL
  	#PbFw_PB_KW_ProcedureDLL
  	#PbFw_PB_KW_ProcedureReturn
  	#PbFw_PB_KW_Protected
  	#PbFw_PB_KW_Prototype
  	#PbFw_PB_KW_PrototypeC
  
  	#PbFw_PB_KW_ReDim
  	#PbFw_PB_KW_Read
  	#PbFw_PB_KW_Repeat
  	#PbFw_PB_KW_Restore
  	#PbFw_PB_KW_Return
  	#PbFw_PB_KW_Runtime
  
  	#PbFw_PB_KW_Select
  	#PbFw_PB_KW_Shared
  	#PbFw_PB_KW_Static
  	#PbFw_PB_KW_Step
  	#PbFw_PB_KW_Structure
  	#PbFw_PB_KW_StructureUnion
  	#PbFw_PB_KW_Swap
  
  	#PbFw_PB_KW_Threaded
  	#PbFw_PB_KW_To
  
  	#PbFw_PB_KW_UndefineMacro
  	#PbFw_PB_KW_Until
  	#PbFw_PB_KW_UnuseModule
  	#PbFw_PB_KW_UseModule
  
  	#PbFw_PB_KW_Wend
  	#PbFw_PB_KW_While
  	#PbFw_PB_KW_With
  
  	#PbFw_PB_KW_XIncludeFile
  	#PbFw_PB_KW_XOr
  EndEnumeration
  ;}
  
  ; Save the number of KeyWords in a Constant  ; 111 for PureBasic
  #NoOf_KEYWORDS = #PB_Compiler_EnumerationValue -1 
  
  Debug "NoOfKeyWords = " + Str(#NoOf_KEYWORDS)
  
  ; Structure to hold PureBasic KeyWord
  Structure TKeyWord
    ID.i
    len.i   ; The KeyWord lenght in No of Characters
    Text.s
  EndStructure
          
  Declare Init()
  Declare.s GetKeyWordFromID(KeyWordID)
  Declare.I IsKeyWord(Word$, NextChar.c=32)
  Declare.s GetKeyWordFromID(KeyWordID)
  Declare GetKeyWortList(List lst.TKeyWord())

EndDeclareModule

Module PB
  EnableExplicit
  
  Global NewList lstKeyWord.TKeyWord() ; List with all PureBasic KeyWords
  Global NewMap mapKeyWord.i()          ; Pointer-Map to TKeyWord-Structure
    
  Procedure Init()
  ; ============================================================================
  ; NAME: Init
  ; DESC: Loads all the Keywords from DataSection
  ; DESC: to lstKeyWord(), Sort the List and remove
  ; DESC: all double KeyWords like 'EndIf', 'EndDatasection', ...
  ; ============================================================================
  
    Protected mem.s, txt.s, I, firstChar.c
    
    ClearList(lstKeyWord())
    ClearMap(mapKeyWord())
    
    I = 0
    Restore BasicKeywords:
    
    Repeat
      
      Read.s txt
      txt = Trim(txt," ")
      firstChar = Asc(txt) ; GetFirstChar
      
      If firstChar >= 'A' And firstChar <= 'Z'
        I + 1
        
        AddElement(lstKeyWord())
        With lstKeyWord()
          \Text =txt
          \len = Len(txt)
          ; \ID = I ; don't index the keywords here, we have to remove double once first!
          ; Debug Str(I) + ": " + txt 
        EndWith
      EndIf    
    Until txt="XOr"
    
    SortStructuredList(lstKeyWord(), #PB_Sort_Ascending, OffsetOf(TKeyWord\Text), #PB_String)
    mem = ""
    
    ; Remove double KeyWords, because of original DataSection from PureBasic-IDE 
    ; where in the 2nd column are all the END -Commands once more
    I = 0
    ForEach lstKeyWord()
      With lstKeyWord()
        txt = \Text
        If txt = mem
          DeleteElement(lstKeyWord())
        Else
          I + 1
          \ID = I  ; start with first KeyWord_ID = 1
          AddMapElement(mapKeyWord(),\Text)   ; Add a new elelment Key = KyWordName
          mapKeyWord()=@lstKeyWord()         ; Map-Value = Pointer to Structure TKeyWord
        EndIf
          mem = txt
      EndWith
    Next
        
  EndProcedure

  Procedure.I IsKeyWord(Word$, NextChar.c=32)
  ; ============================================================================
  ; NAME: IsKeyWord()
  ; DESC: Tests a Word whether it is a Keyword or not
  ; VAR(Word$) : KeyWord
  ; VAR(NextChar) : Next Char after the Keyword
  ; RET : Returns the ID of the KeyWord #PbFw_PB_KW_xyz
  ; ============================================================================
    Protected ret
    Protected *pKeyWord.TKeyWord 
    
    ret = FindMapElement(mapKeyWord(), Word$)
    
    If ret    ; Keyword found
      *pKeyWord = mapKeyWord()        ; get Pointer to TKeyWord Structrue
      ProcedureReturn *pKeyWord\ID    ; Return the KeyWord ID
    EndIf
    
  EndProcedure
  
  Procedure.s GetKeyWordFromID(KeyWordID)
  ; ============================================================================
  ; NAME: GetKeyWordFromID
  ; DESC: Returns the KeyWord Text for a #PbFw_PB_KW_xyz Constant 
  ; DESC: (to get ID for a KeyWord use IsKeyWord() function)
  ; VAR(KeyWordID): the KeyWord Constant like #PbFw_PB_KW_If
  ; RET : The Text of the Keword like 'If'
  ; ============================================================================
  
    Protected ret.s
    If KeyWordID >0 And KeywordID <= #PbFw_PB_KW_Xor
      SelectElement(lstKeyWord(), KeywordID-1)
      ret = lstKeyWord()\Text
    EndIf
    ProcedureReturn ret
  EndProcedure   
  
  Procedure GetKeyWortList(List lst.TKeyWord())
    CopyList(lstKeyWord(), lst())   
  EndProcedure
  
  Structure pChar
    Cn.c[0]  
    c.c
  EndStructure
  
  Procedure.s ParseLineForPbKeyWord(Line$)
    Protected *pc.pChar, ch.c
    Protected I, IStart, kw
    Protected xWordStart, xKeyWord, xRem, xInQuotes
    Protected kw$
    Protected m$ = LCase(Line$)
     
    *pc = @m$
    
    With *pc\c
      ch = *pc\c    ; This gives especally the C-Compiler the chance to use Var in Register
      
      While ch
        
        If ch ='"'
          If xInQuotes 
            xInQuotes = #False
          Else
            xInQuotes = #True
            xWordStart = #False
          EndIf
        EndIf
        
        If Not xInQuotes
          Select ch
              
            Case 9, 32    ; TAB, SPACE
              If xWordStart
                xWordStart = #False ; WordEnd  
              EndIf 
                                    
            Case 'a' To 'x'  ; possible PB KeyWord
              
              If Not xWordStart 
                xWordStart = #True 
                IStart = I
                ; PB Keywords don't start with "h,j,k,q,v,y,z"
                If ch='h' Or ch='j' Or ch='k' Or ch='q' Or ch='v' Or ch='y' Or ch='z'
                Else
                  xKeyWord = #True 
                EndIf
              
              EndIf 
              
            Case ';'    ; found comment marker -> Stop parsing!
              xRem = #True 
              If xWordStart
                xWordStart = #False ; WordEnd             
              EndIf
              
            Case '"'    ; Quotes
              If xInQuotes 
                xInQuotes = #False
              Else
                xInQuotes = #True 
              EndIf
              
            Default 
              
              If xWordStart
                xWordStart = #False ; WordEnd             
              Else
                xWordStart = #True  
                xKeyWord = #False
             EndIf
              
          EndSelect
          
          If xKeyWord And Not xWordStart
            ;possible Keyword found
            kw$ = Mid(m$,IStart+1, I-IStart)
            ProcedureReturn kw$
          EndIf
          
          If xRem
            Break
          EndIf 
        EndIf
        
        I + 1
        *pc + SizeOf(Character)
      Wend   
    EndWith
    ProcedureReturn kw$
  EndProcedure
  
  DataSection
  
    ;- Keywords - BASIC
  
    ; Note: First is the Keyword in real Case, then the corresponding end-keyword
    ;       (for autocomplete), then whether the tag should include a trailing
    ;       space in autocomplete (if enabled).
    ;       Keywords must be sorted here!
  
    ; Note: Keep these definitions in sync with the corresponding constants
    ;       defined in "HighlightingEngine.pb".
  
    BasicKeywords:
    Data$ "Align", "", " "
    Data$ "And", "", " "
    Data$ "Array", "", " "
    Data$ "As", "", " "
  
    Data$ "Break", "", ""
  
    Data$ "CallDebugger"     , "", ""
    Data$ "Case"             , "", " "
    Data$ "CompilerCase"     , "", " "
    Data$ "CompilerDefault"  , "", ""
    Data$ "CompilerElse"     , "", ""
    Data$ "CompilerElseIf"   , "", " "
    Data$ ""    , "", ""
    Data$ "CompilerEndIf", "", ""
    Data$ "CompilerError"    , "", " "
    Data$ "CompilerIf"       , ""    , " "
    Data$ "CompilerSelect"   , "CompilerEndSelect", " "
    Data$ "CompilerWarning"  , "", " "
    Data$ "Continue"         , "", ""
  
    Data$ "Data"           , "", " "
    Data$ "DataSection"    , "EndDataSection", ""
    Data$ "Debug"          , "", " "
    Data$ "DebugLevel"     , "", " "
    Data$ "Declare"        , "", ""
    
    Data$ "DeclareC"       , "", ""
    Data$ "DeclareCDLL"    , "", ""
    Data$ "DeclareDLL"     , "", ""   
    Data$ "DeclareModule"  , "EndDeclareModule", " "
    Data$ "Default"        , "", ""
    Data$ "Define"         , "", " "
    Data$ "Dim"            , "", " "    
    Data$ "DisableASM"     , "", ""   
    Data$ "DisableDebugger", "", ""
    Data$ "DisableExplicit", "", ""
  
    Data$ "Else"              , "", ""
    Data$ "ElseIf"            , "", " "   
    Data$ "EnableASM"         , "", "" 
    Data$ "EnableDebugger"    , "", ""
    Data$ "EnableExplicit"    , "", ""
    Data$ "End"               , "", ""
    Data$ "EndDataSection"    , "", ""
    Data$ "EndDeclareModule"  , "", ""
    Data$ "EndEnumeration"    , "", ""
    Data$ "EndIf"             , "", ""
    Data$ "EndImport"         , "", ""
    Data$ "EndInterface"      , "", ""
    Data$ "EndMacro"          , "", ""
    Data$ "EndModule"         , "", ""
    Data$ "EndProcedure"      , "", ""
    Data$ "EndSelect"         , "", ""
    Data$ "EndStructure"      , "", ""
    
    Data$ "EndStructureUnion" , "", ""
    
    Data$ "EndWith"           , "", ""
    Data$ "Enumeration"       , "EndEnumeration", " "
    Data$ "EnumerationBinary" , "EndEnumeration", " "
    Data$ "Extends"           , "", " "
    
    Data$ "FakeReturn"   , "", ""    
    Data$ "For"          , "Next", " "
    Data$ "ForEach"      , "Next", " "
    Data$ "ForEver"      , "", ""
  
    Data$ "Global", "", " "  
    Data$ "Gosub" , "", " "
    Data$ "Goto"  , "", " "
    
    Data$ "If"            , "EndIf", " "
    Data$ "Import"        , "EndImport", " "    
    Data$ "ImportC"       , "EndImport", " "    
    Data$ "IncludeBinary" , "", " "    
    Data$ "IncludeFile"   , "", " "
    Data$ "IncludePath"   , "", " "
    Data$ "Interface"     , "EndInterface", " "
  
    Data$ "List", "", " "
  
    Data$ "Macro", "EndMacro", " "
    Data$ "MacroExpandedCount", "", ""
    Data$ "Map", "", " "
    Data$ "Module"  , "EndModule", " "
  
    Data$ "NewList", "", " "
    Data$ "NewMap",  "", " "
    Data$ "Next"   , "", ""
    Data$ "Not"    , "", " "
  
    Data$ "Or", "", " "
  
    Data$ "Procedure"      , "EndProcedure", " "   
    Data$ "ProcedureC"     , "EndProcedure", " "
    Data$ "ProcedureCDLL"  , "EndProcedure", " "
    Data$ "ProcedureDLL"   , "EndProcedure", " "  
    Data$ "ProcedureReturn", "", " "
    Data$ "Protected"      , "", " "
    Data$ "Prototype"      , "", " "    
    Data$ "PrototypeC"     , "", " "
     
    Data$ "Read"   , "", " "
    Data$ "ReDim"  , "", " "
    Data$ "Repeat" , "Until ", ""
    Data$ "Restore", "", " "    
    Data$ "Return" , "", ""   
    Data$ "Runtime" , "", ""
  
    Data$ "Select"        , "EndSelect", " "
    Data$ "Shared"        , "", " "
    Data$ "Static"        , "", " "
    Data$ "Step"          , "", " "
    Data$ "Structure"     , "EndStructure", " "
    Data$ "StructureUnion", "EndStructureUnion", ""
    Data$ "Swap"          , "", " "
    
    Data$ "Threaded", "", " "    
    Data$ "To", "", " "
  
    Data$ "UndefineMacro", "", " "
    Data$ "Until", "", " "
    Data$ "UnuseModule", "", " "
    Data$ "UseModule", "", " "
  
    Data$ "Wend" , "", ""
    Data$ "While", "Wend", " "
    Data$ "With" , "EndWith", " "
  
    Data$ "XIncludeFile", "", " "
    Data$ "XOr"         , "", " "
  EndDataSection
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ; ----------------------------------------------------------------------
  
  ;- ---------------------------------------------------------------------------
  ;-  Code Creation Procedures 
  ;- ---------------------------------------------------------------------------
   
  Procedure CreateCode_Enumeration_KeyWords()
  ; ============================================================================
  ; NAME: CreateCode_Enumeration_KeyWords
  ; DESC: Creates the PureBasic Enumeration Section for KeyWords
  ; DESC: and copyies the generated code to the ClipBoard
  ; DESC: use [CTRL+V] to paste it anywhere
  ; ============================================================================
    
    Protected mem.s
    Protected I
    Protected NewList lstKW.PB::TKeyWord()
    Protected.c firstChar = 'A' ; Remember the first Char of the Last Keyword  
    
    PB::GetKeyWortList(lstKW())   ; Get All Keywords as List
    
    UseModule CC    ; CodeCreation Module
    ClearCode()     ; Clear All Code first
    Add("Enumeration EKeyWords 1", #PbFw_CC_SHR_AFTER)
    
    ForEach lstKW()
      mem = lstKW()\Text
      If Asc(mem) <> firstChar      ;  Empty Line if first character change
        Add("")
        firstChar = Asc(mem)
      EndIf
      Add("#PbFw_PB_KW_"+mem)       ; Add a Linie for Each KeyWord Konstant
    Next
    ADE(#PbFw_CC_CMD_EndEnumeration)  ; Add EndEnumeration with ShiftLeft
    CopyToClipBoard()
    UnuseModule CC
  EndProcedure
  
  Procedure GetPbLibCommands()
    Protected NewList lstD.s()    ; Sections in Directories
    Protected NewList lstF.s()    ; For each command a File
    Protected grp$, cmd$
    Protected ret
    Debug "--- GetPbLibCommands ---"
    
    #_StartDir = "C:\temp"
    
    ret = FS::ListDirectories(#_StartDir, lstD())
    ; ret = FS::ListFiles(#_StartDir, lstD(),"", #True)
    
    Debug ret
    
    UseModule CC
    ClearCode()
    
    ForEach lstD()
      
      grp$=lstD() 
      
      Select LCase(grp$)
        Case "examples", "reference"
          ; ignore
          
        Default
          
          Add("[" + grp$ + "]")   ; Add [Groupe$] to the Code
          
          ; List all Files (.html) in the Groupe Directory
          FS::ListFiles(#_StartDir + "\" + lstD(), lstF())
          
           ForEach lstF()
            cmd$ = GetFilePart(lstF(), #PB_FileSystem_NoExtension)
            
            Select LCase(cmd$)
              Case "index"
                ; ignore index.html
              Default       
                Add(GetFilePart(lstF(), #PB_FileSystem_NoExtension))
            EndSelect
        
          Next
          Add("")
      EndSelect
    Next
    CopyToClipBoard()
    UnuseModule CC
    
  EndProcedure
  

  PB::Init()     ; First Init the PB-Module
  
  ; CreateCode_Enumeration_KeyWords() ; Create the Keywords Enumeration section 
  
  GetPbLibCommands()
CompilerEndIf


; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 11
; Folding = --
; Optimizer
; EnableXP
; CPU = 2