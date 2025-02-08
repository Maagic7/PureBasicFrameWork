; ===========================================================================
;  FILE : PbFw_Module_PBSource.pb
;  NAME : Module PureBasic Source Code [PBS::]
;  DESC : 
;  DESC : 
;  DESC : 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/08/24
; VERSION  :  0.11 Brainstorming Version
; COMPILER :  PureBasic 6.11
; ===========================================================================
;{ ChangeLog: 
;  2025/01/20 S.Maag : Changed file name PbFw_Module_PureBasic to
;               PbFw_Module_PBSource and Module Name from PB to PBS
;}
;{ TODO:
;}
; ===========================================================================

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
DeclareModule PBS
 
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
    #PBS_KW_Align
    #PBS_KW_And
  	#PBS_KW_Array
  	#PBS_KW_As
  
  	#PBS_KW_Break
  
  	#PBS_KW_CallDebugger
  	#PBS_KW_Case
  	#PBS_KW_CompilerCase
  	#PBS_KW_CompilerDefault
  	#PBS_KW_CompilerElse
  	#PBS_KW_CompilerElseIf
  	#PBS_KW_CompilerEndIf
  	#PBS_KW_CompilerEndSelect
  	#PBS_KW_CompilerError
  	#PBS_KW_CompilerIf
  	#PBS_KW_CompilerSelect
  	#PBS_KW_CompilerWarning
  	#PBS_KW_Continue
  
  	#PBS_KW_Data
  	#PBS_KW_DataSection
  	#PBS_KW_Debug
  	#PBS_KW_DebugLevel
  	#PBS_KW_Declare
  	#PBS_KW_DeclareC
  	#PBS_KW_DeclareCDLL
  	#PBS_KW_DeclareDLL
  	#PBS_KW_DeclareModule
  	#PBS_KW_Default
  	#PBS_KW_Define
  	#PBS_KW_Dim
  	#PBS_KW_DisableASM
  	#PBS_KW_DisableDebugger
  	#PBS_KW_DisableExplicit
  
  	#PBS_KW_Else
  	#PBS_KW_ElseIf
  	#PBS_KW_EnableASM
  	#PBS_KW_EnableDebugger
  	#PBS_KW_EnableExplicit
  	#PBS_KW_End
  	#PBS_KW_EndDataSection
  	#PBS_KW_EndDeclareModule
  	#PBS_KW_EndEnumeration
  	#PBS_KW_EndIf
  	#PBS_KW_EndImport
  	#PBS_KW_EndInterface
  	#PBS_KW_EndMacro
  	#PBS_KW_EndModule
  	#PBS_KW_EndProcedure
  	#PBS_KW_EndSelect
  	#PBS_KW_EndStructure
  	#PBS_KW_EndStructureUnion
  	#PBS_KW_EndWith
  	#PBS_KW_Enumeration
  	#PBS_KW_EnumerationBinary
  	#PBS_KW_Extends
  
  	#PBS_KW_FakeReturn
  	#PBS_KW_For
  	#PBS_KW_ForEach
  	#PBS_KW_ForEver
  
  	#PBS_KW_Global
  	#PBS_KW_Gosub
  	#PBS_KW_Goto
  
  	#PBS_KW_If
  	#PBS_KW_Import
  	#PBS_KW_ImportC
  	#PBS_KW_IncludeBinary
  	#PBS_KW_IncludeFile
  	#PBS_KW_IncludePath
  	#PBS_KW_Interface
  
  	#PBS_KW_List
  
  	#PBS_KW_Macro
  	#PBS_KW_MacroExpandedCount
  	#PBS_KW_Map
  	#PBS_KW_Module
  
  	#PBS_KW_NewList
  	#PBS_KW_NewMap
  	#PBS_KW_Next
  	#PBS_KW_Not
  
  	#PBS_KW_Or
  
  	#PBS_KW_Procedure
  	#PBS_KW_ProcedureC
  	#PBS_KW_ProcedureCDLL
  	#PBS_KW_ProcedureDLL
  	#PBS_KW_ProcedureReturn
  	#PBS_KW_Protected
  	#PBS_KW_Prototype
  	#PBS_KW_PrototypeC
  
  	#PBS_KW_ReDim
  	#PBS_KW_Read
  	#PBS_KW_Repeat
  	#PBS_KW_Restore
  	#PBS_KW_Return
  	#PBS_KW_Runtime
  
  	#PBS_KW_Select
  	#PBS_KW_Shared
  	#PBS_KW_Static
  	#PBS_KW_Step
  	#PBS_KW_Structure
  	#PBS_KW_StructureUnion
  	#PBS_KW_Swap
  
  	#PBS_KW_Threaded
  	#PBS_KW_To
  
  	#PBS_KW_UndefineMacro
  	#PBS_KW_Until
  	#PBS_KW_UnuseModule
  	#PBS_KW_UseModule
  
  	#PBS_KW_Wend
  	#PBS_KW_While
  	#PBS_KW_With
  
  	#PBS_KW_XIncludeFile
  	#PBS_KW_XOr
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

Module PBS
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
  ; RET : Returns the ID of the KeyWord #PBS_KW_xyz
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
  ; DESC: Returns the KeyWord Text for a #PBS_KW_xyz Constant 
  ; DESC: (to get ID for a KeyWord use IsKeyWord() function)
  ; VAR(KeyWordID): the KeyWord Constant like #PBS_KW_If
  ; RET : The Text of the Keword like 'If'
  ; ============================================================================
  
    Protected ret.s
    If KeyWordID >0 And KeywordID <= #PBS_KW_Xor
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
    Protected NewList lstKW.PBS::TKeyWord()
    Protected.c firstChar = 'A' ; Remember the first Char of the Last Keyword  
    
    PBS::GetKeyWortList(lstKW())   ; Get All Keywords as List
    
    UseModule CC    ; CodeCreation Module
    ClearCode()     ; Clear All Code first
    Add("Enumeration EKeyWords 1", #CC_SHR_AFTER)
    
    ForEach lstKW()
      mem = lstKW()\Text
      If Asc(mem) <> firstChar      ;  Empty Line if first character change
        Add("")
        firstChar = Asc(mem)
      EndIf
      Add("#PBS_KW_"+mem)       ; Add a Linie for Each KeyWord Konstant
    Next
    ADE(#CC_CMD_EndEnumeration)  ; Add EndEnumeration with ShiftLeft
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
  

  PBS::Init()     ; First Init the PB-Module
  
  ; CreateCode_Enumeration_KeyWords() ; Create the Keywords Enumeration section 
  
  GetPbLibCommands()
CompilerEndIf


; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 641
; FirstLine = 577
; Folding = ---
; Optimizer
; EnableXP
; CPU = 2