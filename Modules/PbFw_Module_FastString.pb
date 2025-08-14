; ===========================================================================
;  FILE : PbFw_Module_FastString.pb
;  NAME : Module Fast String [FStr:]
;  DESC : Provides fast String and Char Functions with ASM optimations in x64.
;  DESC : This Modul is a combination of former Str::, FStr:: and FChar::
;  DESC : because all Modulues did similar things.
;  DESC : Now the Assembler optimations are used for x64 ASM Backend only.
;  DESC : So the user do not have to choose the right Module.
;  DESC
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/08
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0+
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;  2025/08/05 S.Maag : combined the Modules Str::, FStr:: and FChar:: in FStr::
;                      Now each functions which steps trough the complete String optionally
;                      returns Length in *outLength
;
;  old Module FStr::
;  2025/07/31 S.Maag : rework of FindCharReverse() - changed to standard ASM template
;                      and tested in ASM and PB-Version
;  2025/05/16 S.Maag : corrected wrong Shufflemask load in ASMx64_ChangeByteOrder
;  2024/01/28 S.Maag : added ASM x64 optiomations for CountChar, ReplaceChar
;                      added Fast LenStr_x64() function and Macro LenStrFast()
;                        to use it only at x64!
;  2024/01/20 S.Maag : added ToggleStringEndianess()
;                      faster Version for RemoveTabsAndDoubleSpace()
;                      RemoveTabsAndDoubleSpaceFast(*String); Pointer Version
;                      moved String File-Functions to Module FileSystem FS::
;  old Modul Str::
;  2025/07/25 S.Maag : moved SetMid() to PB-Extention Module PX::
;                      changed Fast Functions to Prototype-Version
;  2025/02/28 S.Maag : Added ReplaceAccents, CharHistogram
;  2024/12/30 S.Maag : Added SetMid(); changed pChar Definition
;  2024/12/25 S.Maag : Added StringArray <-> StringList functions
;  2024/12/08 S.Maag : Added StringsBetween Functions from PB Forum by mk_soft
;  2024/12/04 S.Maag : Added simple TextBetween Function to search for Text in brackets
;  2024/08/20 S.Maag : Bug in JonList : need ListSize to get elements not Len()
;  2024/03/08 S.Maag : moved Assembler Functions to new Module FastString FStr::
;                      added Split and Join Functions

;}
;{ TODO:
;}
; ===========================================================================
;- --------------------------------------------------
;- Include Files
;  --------------------------------------------------

;XIncludeFile "PbFw_Module_FastString.pb"        ; FStr::    Fast String Module

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module
; XIncludeFile ""

DeclareModule FStr
  
  ;- --------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  --------------------------------------------------
  
  ; PB-Compiler use only #PB_Compiler_Unicode to specify Unicode or ASCII Mode
  ; PB 5.5 and higher use Unicode as Standard Mode
  ; older Versions use ASCII-Mode as standard for the EXE
  CompilerIf #PB_Compiler_Unicode
    #FStr_CharMode = #PB_Unicode       ; Application CharacterMode = Unicode
    #FStr_CharModeName = "Unicode"     ; Application CharacterModeName
  CompilerElse
    #FStr_CharMode = #PB_Ascii         ; Application CharacterMode = ASCII 
    #FStr_CharModeName = "ASCII"       ; Application CharacterModeName
  CompilerEndIf
  ;#FStr_CharSize = SizeOf(Character)   ; Application CharacterSize = 2 Bytes
  
  EnumerationBinary eCharTypeFlags      ; Character classification Flags
    #FStr_Flag_Lo           ; 0
    #FStr_Flag_Up           ; 1
  	#FStr_Flag_Letter       ; 2
  	#FStr_Flag_Accent       ; 3
   	#FStr_Flag_Dec          ; 4
  	#FStr_Flag_Bin          ; 5
  	#FStr_Flag_Hex          ; 6
  	#FStr_Flag_Visible      ; 7
  
  	#FStr_Flag_Numeric      ; 8
  	#FStr_Flag_Math         ; 9
  	#FStr_Flag_Punctuation  ; 10
  	#FStr_Flag_SpecialChar  ; 11
   	#FStr_Flag_Control      ; 12
  	#FStr_Flag_SpaceTab     ; 13    ; Tab or Space
  	#FStr_Flag_Ascii        ; 14    ; Ascii-Char   <=255
  	#FStr_Flag_UniCode      ; 15    ; UniCode-Char >=256
  
  	#FStr_Flag_GermanExt    ; 16
  	#FStr_Flag_FrenchExt    ; 17
  	#FStr_Flag_SpanishExt   ; 18
  	#FStr_Flag_19           ; 19
  	#FStr_Flag_20           ; 20
  	#FStr_Flag_21           ; 21
  	#FStr_Flag_22           ; 22
  	#FStr_Flag_23           ; 23
  
  	#FStr_Flag_User_0       ; 24
  	#FStr_Flag_User_1       ; 25
  	#FStr_Flag_User_2       ; 26
  	#FStr_Flag_User_3       ; 27
  	#FStr_Flag_User_4       ; 28
  	#FStr_Flag_User_5       ; 29
  	#FStr_Flag_User_6       ; 30
  	#FStr_Flag_User_7       ; 31
  EndEnumeration  
  
  ; --------------------------------------------------
  ; Flag combinations of eCharTypeFlags
  ; --------------------------------------------------
  
  #FStr_Flags_LetterLo = #FStr_Flag_Letter | #FStr_Flag_Lo
  #FStr_Flags_LetterUp = #FStr_Flag_Letter | #FStr_Flag_Up
  
  #FStr_Flags_AccentLo = #FStr_Flag_Accent | #FStr_Flag_Lo
  #FStr_Flags_AccentUp = #FStr_Flag_Accent | #FStr_Flag_Up
  
  #FStr_Flags_GermanLetter = #FStr_Flag_Letter | #FStr_Flag_GermanExt
  #FStr_Flags_GermanLetterLo = #FStr_Flag_Letter | #FStr_Flag_GermanExt | #FStr_Flag_Lo
  #FStr_Flags_GermanLetterUp = #FStr_Flag_Letter | #FStr_Flag_GermanExt | #FStr_Flag_Up
  
  #FStr_Flags_FrenchLetter = #FStr_Flag_Letter | #FStr_Flag_FrenchExt
  #FStr_Flags_FrenchLetterLo = #FStr_Flag_Letter | #FStr_Flag_FrenchExt | #FStr_Flag_Lo
  #FStr_Flags_FrenchLetterUp = #FStr_Flag_Letter | #FStr_Flag_FrenchExt | #FStr_Flag_Up
  
  #FStr_Flags_SpanishLetter = #FStr_Flag_Letter | #FStr_Flag_SpanishExt
  #FStr_Flags_SpanishLetterLo = #FStr_Flag_Letter | #FStr_Flag_SpanishExt | #FStr_Flag_Lo
  #FStr_Flags_SpanishLetterUp = #FStr_Flag_Letter | #FStr_Flag_SpanishExt | #FStr_Flag_Up
  
  Global Dim FlagTable.l(255)   ; Array [0..255] for Flags, FlagTable

  ;#TAB is PB integrated
  #FStr_CHAR_SPACE       = 32    ; ' '
  #FStr_CHAR_DoubleQuote = 34    ; "
  #FStr_CHAR_SingleQuote = 39    ; '

  ; ============================================================================
  ; NAME: BufferAsciiToString
  ; DESC: Read an Ascii-string out of a ByteBuffer
  ; VAR(ptrBuffer): Pointer to the Ascii Buffer
  ; ============================================================================
  ; My2ByteString = BufferToString(*MyBuffer)
  Macro BufferAsciiToString(ptrBuffer)
    PeekS(ptrBuffer, #PB_Default, #PB_Ascii)  
  EndMacro
  
  ; ============================================================================
  ; NAME: StringToAsciiBuffer
  ; DESC: Write a String into an Ascii Buffer
  ; VAR(String):  String to copy to Buffer
  ; VAR(ptrBuffer): Pointer to the Ascii Buffer
  ; ============================================================================
  Macro StringToBufferAscii(String, ptrBuffer)
    PokeS(String, ptrBuffer, #PB_Ascii)  
  EndMacro

  ;- --------------------------------------------------
  ;- Char based Macros
  ;- -------------------------------------------------- 
  ; <<5 <-> *32
  Macro mac_UCaseChar255(CharValue)
    (CharValue - Bool(CharValue<255)*(Bool(FChr::FlagTable(CharValue & $FF) & FChr::#FStr_CharLo)<<5))
  EndMacro
  
  Macro mac_LCaseChar255(CharValue)
    (CharValue +Bool(CharValue<255)*(Bool(FChr::FlagTable(CharValue & $FF) & FChr::#FStr_CharUp)<<5))
  EndMacro
  
  Macro mac_IsHexChar(CharValue)
    Bool(FChr::FlagTable(CharValue & $FF) & FChr::#FStr_Hex * Bool(CharValue<255))
  EndMacro
  
  Macro mac_IsDecChar(CharValue)
    Bool(FChr::FlagTable(CharValue & $FF) & FChr::#FStr_Dec) * Bool(CharValue<255))
  EndMacro
  
  CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_64Bit And #PB_Compiler_Unicode
    Macro LenFast(String)
      LenSSE(@String)  
    EndMacro
  CompilerElse
    Macro LenFast(String)
      Len(String)
    EndMacro     
  CompilerEndIf  

  ;- --------------------------------------------------
  ;- Declare Public
  ; -------------------------------------------------- 
  
  ; Some of the following Functions exist in two versions:
  ;   - the Fast version [F]: The passed strings are modified directly in memory.
  ;   - the standard version: The strings are copied twice. A Copy is
  ;     passed to the function and an other copy will be returned. Thats the
  ;     PB standard way of processing Strings but slower!
  
  ; -------------------------------------
  ; --- Control and helper Functoions ---
  ; -------------------------------------
  Declare.s GetVisibleAsciiCharset()
  
  Declare.s GetSpecialCharName(Char.c)
  Declare.i SetCharUserFlag(Char.c, UserFlag=#FStr_Flag_User_7, FlagValue=#True)
  
  Prototype.i CharHistogram(String$, Array hist(1), Mode=#PB_Ascii, *outLength.Integer=0)
  Global CharHistogram.CharHistogram
  
  Declare.i LenSSE(*String)
  
  Prototype.i ToggleStringEndianessF(String$, *outLength.Integer=0)
  Global ToggleStringEndianessF.ToggleStringEndianessF
  Prototype.s ToggleStringEndianess(String$, *outLength.Integer=0)
  
  ; -----------------------
  ; --- LCase and UCase ---
  ; -----------------------
  Declare.c LCaseChar255(Char.c)
  Declare.c UCaseChar255(Char.c)    
  
  Prototype LCase255F(String$, *outLength.Integer=0)
  Global LCase255F.LCase255F
  Declare.s LCase255(String$, *outLength.Integer=0)
  
  Prototype UCase255F(String$, *outLength.Integer=0)
  Global UCase255F.UCase255F
  Declare.s UCase255(String$, *outLength.Integer=0)
  
  ; ------------------------
  ; --- Find and Replace ---
  ; ------------------------
  Prototype.i CountChar(String$, cSearch.c, *outLength.Integer=0) ; ProtoType-Function for CountChar
  Global CountChar.CountChar                      ; Define Prototype-Handler For CountChar
  
  Prototype.i FindChar(String$, cSearch.c)
  Global FindChar.FindChar                        ; define Prototype-Handler for FindChar
  
  Prototype.i FindCharReverse(String$, cSearch.c, *outLength.Integer=0)
  Global FindCharReverse.FindCharReverse          ; define Prototype-Handler for FindCharReverse
  
  Prototype.i ReplaceCharF(String$, cSearch.c, cReplace.c, *outLength.Integer=0)  ; The Fast version (in Memory)
  Global ReplaceCharF.ReplaceCharF                                                ; define Prototype-Handler for ReplaceCharF
  Declare.s ReplaceChar(String$, cSearch.c, cReplace.c, *outLength.Integer=0)     ; The standard version
  
  Prototype.i ReplaceAccentsF(String$, *outLength.Integer=0)
  Global ReplaceAccentsF.ReplaceAccentsF
  Declare.s ReplaceAccents(String$, *outLength.Integer=0)
  
  ; ---------------
  ; --- Remove ---
  ; ---------------
  Prototype.i RemoveCharF(String$, Char.c, *outLength.Integer=0)
  Global RemoveCharF.RemoveCharF                                
  Declare.s RemoveChar(String$, Char.c, *outLength.Integer=0)

  Prototype.i RemoveCharsF(String$, Char1.c, Char2.c=0, xTrim=#False, *outLength.Integer=0)
  Global RemoveCharsF.RemoveCharsF
  Declare.s RemoveChars(String$, Char1.c, Char2.c=0, xTrim=#False, *outLength.Integer=0)
    
  Prototype.i RemoveTabsAndDoubleSpaceF(String$, *outLength.Integer=0)
  Global RemoveTabsAndDoubleSpaceF.RemoveTabsAndDoubleSpaceF
  Declare.s RemoveTabsAndDoubleSpace(String$, *outLength.Integer=0)  
  
  Prototype.i _RemoveCharsWithFlagF(String$, Flags=#FStr_Flag_Accent, *outLength.Integer=0)
  Global RemoveCharsWithFlagF._RemoveCharsWithFlagF
  Declare.s RemoveCharsWithFlag(String$, Flags=#FStr_Flag_Accent, *outLength.Integer=0)
  
  Prototype.i _KeepCharsWithFlagF(String$, Flags=#FStr_Flag_Accent, *outLength.Integer=0)
  Global KeepCharsWithFlagF._KeepCharsWithFlagF
  Declare.s KeepCharsWithFlag(String$, Flags=#FStr_Flag_Accent, *outLength.Integer=0)
 
 EndDeclareModule

Module FStr

  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- PbFw Module local configurations
  ;  ----------------------------------------------------------------------
  ; This constants must have same Name in all Modules
  
  ; ATTENTION: with the PbFw::CONST Macro the PB-IDE Intellisense do not registrate the ConstantName
  
  ; #PbFwCfg_Module_CheckPointerException = #True     ; On/Off PoninterExeption for this Module
  PbFw::CONST(PbFwCfg_Module_CheckPointerException, #True)
  
  ;#PbFwCfg_Module_ASM_Enable = #True                ; On/Off Assembler Versions when compling in ASM Backend
  PbFw::CONST(PbFwCfg_Module_ASM_Enable, #True)
 
  ; -----------------------------------------------------------------------
      
  ; ************************************************************************
  ; PbFw::mac_CompilerModeSettting      ; using Macro for CompilerSetting is a problem for the IDE
  ; so better use the MacroCode directly
  ; Do not change! Must be changed globaly in PbFw:: and then copied to each Module
  Enumeration
    #PbFwCfg_Module_Compile_Classic                 ; use Classic PB Code
    #PbFwCfg_Module_Compile_ASM32                   ; x32 Bit Assembler
    #PbFwCfg_Module_Compile_ASM64                   ; x64 Bit Assembler
    #PbFwCfg_Module_Compile_C                       ; use optimations for C-Backend
  EndEnumeration
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm And #PbFwCfg_Module_ASM_Enable And PbFw::#PbFwCfg_Global_ASM_Enable 
    ; A S M   B A C K E N D
    CompilerIf #PB_Compiler_32Bit
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM32     
    ; **********  64 BIT  **********
    CompilerElseIf #PB_Compiler_64Bit
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM64     
    ; **********  Classic Code  **********
    CompilerElse
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
    CompilerEndIf
      
  CompilerElseIf  #PB_Compiler_Backend = #PB_Backend_C
    ;  C - B A C K E N D
     #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_C     
  CompilerElse
    Debug "Classic" 
    ;  To force Classic Code Compilation
    #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
  CompilerEndIf 
  ; ************************************************************************
  ;Debug "PbFwCfg_Module_Compile = " + #PbFwCfg_Module_Compile
  
  ; ----------------------------------------------------------------------
  
  PbFw::ListModule(#PB_Compiler_Module)   ; Lists the Module in the ModuleList (for statistics)
  
  IncludeFile "PbFw_ASM_Macros.pbi"       ; Standard Assembler Macros
  
  ;- ----------------------------------------------------------------------
  ;- Module Private
  ;- ----------------------------------------------------------------------
  
  Procedure.s _GetCharModeName(CharMode.i = #PB_Default)
    
    Protected RET.s
    If CharMode = #PB_Default
      ; #FStr_CharMode is [#PB_Unicode or #PB_Ascii]
      CharMode = #FStr_CharMode    
    EndIf
    
    Select CharMode
      Case #PB_Ascii
        RET = "ASCII"       
      Case #PB_Unicode
         RET = "Unicode"
      Case #PB_UTF8
         RET = "UTF-8"
      Case #PB_UTF16BE
         RET = "UTF-16 BE"
      Case #PB_UTF32
         RET = "UTF-32"
      Case #PB_UTF32BE
         RET = "UTF-32 BE"
      Default
         RET = ""   
    EndSelect
     
    ProcedureReturn RET
  EndProcedure
  
  Procedure.l _AnalyzeChar(Char.c)
    ; Analyze the Char and return all the classification Flags
    
    Protected.l ret
    
    ; --------------------------------------------------
    ;   Ascii of Unicode
    ; --------------------------------------------------       
    If Char <=255
      ret | #FStr_Flag_Ascii  
    Else
      ret | #FStr_Flag_Unicode        
    EndIf
    
    ; --------------------------------------------------
    ;   CharLo/CharUp
    ; --------------------------------------------------       
    If Char <> 255 ; LCase(Chr(255)) = 376 -> this is unicode not ASCII
      If Chr(Char) <> UCase(Chr(Char))      ; If an UpChar exists
        ret | #FStr_Flag_Lo 
      ElseIf Chr(Char) <> LCase(Chr(Char))  ; If an LoChar exists
        ret | #FStr_Flag_Up
      EndIf
    EndIf
    
    ; --------------------------------------------------
    ;   Letter
    ; --------------------------------------------------
    Select Char 
      Case 'A' To 'Z'
        ret | #FStr_Flag_Letter
      Case 'a' To 'z'
        ret | #FStr_Flag_Letter
    EndSelect
    
    ; --------------------------------------------------  
    ;   Chars with accent
    ; --------------------------------------------------  
    Select Char
      Case 192 To 223
        ret | #FStr_Flag_Accent      
      Case 224 To 252
        ret | #FStr_Flag_Accent       
    EndSelect
    
    ; --------------------------------------------------
    ;   Decimal, Binary, Hex Char
    ; --------------------------------------------------
    Select Char
      Case '0' To '9'
        ret | #FStr_Flag_Dec
        ret | #FStr_Flag_Hex
       
        If char <= '1'
          ret | #FStr_Flag_Bin 
        EndIf
        
      Case 'A' To 'F'
        ret | #FStr_Flag_Hex        
    EndSelect
    
    ; --------------------------------------------------  
    ;   Numeric Char
    ; --------------------------------------------------          
      Select Char
        Case '.', ',', '-', '+', 'E', 'e'    
          ret | #FStr_Flag_Numeric  
        Default
          If (ret & #FStr_Flag_Dec) ; if it's Decimal, it's Numeric too
            ret | #FStr_Flag_Numeric          
          EndIf
      EndSelect     
        
    ; --------------------------------------------------
    ;  visible/printable Char
    ; --------------------------------------------------   
    Select Char
      Case 32 To 127
        ret | #FStr_Flag_Visible      
      Case 161 To 255
        ret | #FStr_Flag_Visible       
    EndSelect
                
    ; --------------------------------------------------  
    ;   Mathematical Char
    ; --------------------------------------------------    
    Select Char
      Case '-', '+', '*', '/', '='
        ret | #FStr_Flag_Math 
      Case '(', ')'
        ret | #FStr_Flag_Math         
    EndSelect
      
    ; --------------------------------------------------  
    ;   Punctuation Char
    ; --------------------------------------------------    
    Select Char
      Case '.', ',', ';', '!', '?', ':'
        ret | #FStr_Flag_Punctuation 
      Case '¿', '¡'
        ret | #FStr_Flag_Punctuation     ; spanish punctuation extention
        
    EndSelect
      
    ; --------------------------------------------------  
    ;   Special Char
    ; --------------------------------------------------    
    Select Char
      Case 33 To 47       ; '!' to '/'
        ret | #FStr_Flag_SpecialChar 
      Case 58 To 64       ; ':' to '@'
        ret | #FStr_Flag_SpecialChar 
      Case 91 To 96       ; '[' to '`'
        ret | #FStr_Flag_SpecialChar 
      Case 123 To 126       ; '{' to '~'
        ret | #FStr_Flag_SpecialChar 
      Case '§'
        ret | #FStr_Flag_SpecialChar      
    EndSelect
    
    ; --------------------------------------------------  
    ;   TAB or SPACE
    ; --------------------------------------------------    
    Select Char
      Case 9, 32
        ret | #FStr_Flag_SpaceTab
    EndSelect
    
    ; --------------------------------------------------
    ;   ControlChar
    ; --------------------------------------------------
    Select Char 
      Case 0 To 31
        ret | #FStr_Flag_Control
      Case 127 To 159
        ret | #FStr_Flag_Control
    EndSelect
    
    ; --------------------------------------------------  
    ;   German Extention Char
    ; --------------------------------------------------      
    Select Char
      Case 'Ä', 'Ü', 'Ö'
        ret | #FStr_Flag_GermanExt
      Case 'ä', 'ü', 'ö', 'ß'
        ret | #FStr_Flag_GermanExt
    EndSelect
    
    ; --------------------------------------------------  
    ;   French Extention Char
    ; --------------------------------------------------      
    Select Char
      Case 'é'                      ; Accent aigu
        ret | #FStr_Flag_FrenchExt
      Case 'à', 'è', 'ù'            ; Accent grave
        ret | #FStr_Flag_FrenchExt  
      Case 'â', 'ê', 'î', 'ô', 'û'  ; Accent circonflexe
        ret | #FStr_Flag_FrenchExt       
      Case 'ë', 'ï', '?', 'ÿ'       ; le tréma
        ret | #FStr_Flag_FrenchExt    
      Case 'Ç', 'ç'                 ; la cédille
        ret | #FStr_Flag_FrenchExt    
    EndSelect
    
    ; --------------------------------------------------  
    ;   Spanish Extention Char
    ; --------------------------------------------------      
    Select Char
      Case 'ñ', 'á', 'é', 'í', 'ó', 'ú'
        ret | #FStr_Flag_SpanishExt
      Case 'Ñ', 'Á', 'É', 'Í', 'Ó', 'Ú'
        ret | #FStr_Flag_SpanishExt
;       Case '¿', '¡'
;         ret | #FStr_SpanishExt ; spanish punctuation extention
    EndSelect

    ProcedureReturn ret
  EndProcedure
  
  Procedure _Init()
    Protected I    
    For I = 0 To 255
      FlagTable(I) = _AnalyzeChar(I)  
    Next    
  EndProcedure

  Procedure.i _ReadFileBOM(FileNo, ReadUnsupportedModeAsASCII=#True)
  ; ============================================================================
  ; NAME: _ReadFileBOM
  ; DESC: Read File Byte Order Mark and return the detected CharMode
  ; VAR(FileNo.i) : PureBasic File Number
  ; VAR( ReadUnsupportedModeAsASCII): #True: if CharMode is unsuported use #PB_Ascii
  ; RET.i : CharMode [#PB_Ascii, #PB_Unicode, #PB_UTF8] nativ supported by PB
  ;                  [#PB_UTF16BE, #PB_UTF32,  #PB_UTF32BE] unsupported by PB
  ;                  or #Null
  ; ============================================================================
   
    Protected BOM.i     ; ByteOrderMark : see PB Help for ReadStringFormat
    Protected RET.i
    ; ReadStringFormat(#File) Try to dedect the ByteOrderMark BOM of Strings 
    ; in a File and returns one of the follwoing valus
    
    ;   #PB_Ascii  : BOM not found. This is standard Text File with ASCII Byte code
    ;   #PB_UTF8   : UTF-8 BOM found.
    ;   #PB_Unicode: UTF-16 (Little Endian) BOM found
    ;   
    ;   The following BOMs are not supported in PureBasic ReadString()
    ;   #PB_UTF16BE: UTF-16 (Big Endian) BOM gefunden.
    ;   #PB_UTF32  : UTF-32 (Little Endian) BOM gefunden.
    ;   #PB_UTF32BE: UTF-32 (Big Endian) BOM gefunden.
    
    If FileNo
      BOM= ReadStringFormat(FileNo)   ; Try to read the ByteOrderMark of the File
      
      Select BOM                                  ; BOM is the Auto detected CharMode
        Case #PB_Ascii, #PB_Unicode, #PB_UTF8     ; PB supported Character Modes
          RET = BOM
        
        Case #PB_UTF16BE, #PB_UTF32,  #PB_UTF32BE ; unsupported Charcter Modes
          RET = #Null
        
        Default                                   ; every other value is unsupported
          RET = #Null           
      EndSelect
      
      If RET = #Null 
        If ReadUnsupportedModeAsASCII
          RET = #PB_Ascii
        EndIf
      EndIf

    EndIf
    
    ProcedureReturn RET
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- *** Modul Public ***
  ;- Control and helper Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.s GetVisibleAsciiCharset()
  ; ============================================================================
  ; NAME: GetVisibleAsciiCharset
  ; DESC: Get a String with all visible Ascii Chars
  ; DESC: form 32..127 and 161..255  => 191 Chars
  ; RET.i : String with all visible Ascii Chars  Len()=191
  ; ============================================================================
    Protected I
    Protected ret$ = Space(255)
    Protected *pC.Character = @ret$
    
    For I = 32 To 127
      *pC\c = I
      *pC + SizeOf(Character)
    Next
    
    For I = 161 To 255
      *pC\c = I
      *pC + SizeOf(Character)
    Next 
    ; Add EndOfString
    *pC\c = 0
  ;   Debug Len(ret$)
  ;   Debug Asc(Mid(ret$,191))
    ProcedureReturn PeekS(@ret$)
  EndProcedure
  
  Procedure.s GetSpecialCharName(Char.c)
  ; ============================================================================
  ; NAME: GetSpecialCharName
  ; DESC: Get the special CharName
  ; DESC: Control Chars have special names. Chr(3)='ETX' EndOfText
  ; DESC: This Functions returns the full Character Name for ControlChars
  ; DESC: and the CHR(Char) for normal (visible chars)
  ; VAR(Char.c): The Character Value
  ; RET.s : The special Char Name
  ; ============================================================================
    Protected n.s
    
    If Char <= 32
      Select Char 
        Case 0 : n = "EOS"    
        Case 1 : n = "SOH"
        Case 2 : n = "STX"
        Case 3 : n = "ETX"    ; EndOfText
        Case 4 : n = "EOT"
        Case 5 : n = "ENO"
        Case 6 : n = "ACK"
        Case 7 : n = "BEL"
        Case 8 : n = "BS"
        Case 9 : n = "TAB"
        Case 10 : n = "LF"
        Case 11 : n = "VT"
        Case 12 : n = "FF"
        Case 13 : n = "CR"
        Case 14 : n = "SO"
        Case 15 : n = "SI"
        Case 16 : n = "DLE"
        Case 17 : n = "DC1"
        Case 18 : n = "DC2"
        Case 19 : n = "DC3"
        Case 20 : n = "DC4"
        Case 21 : n = "NAK"
        Case 22 : n = "SYN"
        Case 23 : n = "ETB"
        Case 24 : n = "CAN"
        Case 25 : n = "EM"
        Case 26 : n = "SUB"
        Case 27 : n = "ESC"
        Case 28 : n = "FS"
        Case 29 : n = "GS"
        Case 30 : n = "RS"
        Case 31 : n = "US"
        Case 32 : n = "SPC"  ; Space
      EndSelect     
      
    ElseIf Char >= 127 And Char <= 160 
      
      Select Char
        Case 127 : n = "DEL"    
        Case 128 : n = "PAD"
        Case 129 : n = "HOP"
        Case 130 : n = "BPH"
        Case 131 : n = "NBH"
        Case 132 : n = "IND"
        Case 133 : n = "NEL"
        Case 134 : n = "SSA"
        Case 135 : n = "ESA"
        Case 136 : n = "HTS"
        Case 137 : n = "HTJ"
        Case 138 : n = "LTS"
        Case 139 : n = "PLD"
        Case 140 : n = "PLU"
        Case 141 : n = "RI"
        Case 142 : n = "SS2"
        Case 143 : n = "SS3"
        Case 144 : n = "DCS"
        Case 145 : n = "PU1"
        Case 146 : n = "PU2"
        Case 147 : n = "STS"
        Case 148 : n = "CCH"
        Case 149 : n = "MW"
        Case 150 : n = "SPA"
        Case 151 : n = "EPA"
        Case 152 : n = "SOS"
        Case 153 : n = "SGCI"
        Case 154 : n = "SCI"
        Case 155 : n = "CSI"
        Case 156 : n = "ST"
        Case 157 : n = "OSC"
        Case 158 : n = "PM"
        Case 159 : n = "APC"
        Case 160 : n = "NBS"  ; Non-breaking Space       
      EndSelect     
    Else
      n = Chr(Char) 
    EndIf
    
    ProcedureReturn n      
  EndProcedure
  
  Procedure.i SetCharUserFlag(Char.c, UserFlag=#FStr_Flag_User_7, FlagValue=#True)
    Protected ret
    
    If UserFlag >= #FStr_Flag_User_0 Or UserFlag = #FStr_Flag_User_7 ; #FStr_User_7 might be negative, if passed as .l 
      If Char <= 255  ; Char is unsigned -> no need Check Char>0
        ret = #True 
        
        If FlagValue  ; Set
          FlagTable(Char) = FlagTable(Char) | UserFlag
        Else          ; Reset
          FlagTable(Char) = FlagTable(Char) & ~UserFlag  
        EndIf
        
      Else
        ; raise execption
      EndIf
    Else
       ; raise execption      
    EndIf
  
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i _CharHistogram(*String, Array hist(1), Mode=#PB_Ascii, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: CharHistogram
  ; DESC: !PointerVersion! use it as ProtoType CharHistogram()
  ; DESC: Counts the number of all Character
  ; VAR(String$) : The String
  ; VAR( Array hist()) : Array to receive the Character counts
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : max Array Index; 255 for ASCII or 65535 for Unicode Strings
  ; ============================================================================
    Protected *pRead.Character   ; Pointer to a virutal Char-Struct
    Protected ret
    
    *pRead = *String
   
    If *pRead      
      If Mode = #PB_Ascii
        Dim hist(255)
        ret = 255
      Else
        Dim hist(65535)
        ret = 65535
      EndIf
     
      If Mode = #PB_Ascii
        While *pRead
          If *pRead\c <=255 
            hist(*pRead\c) + 1
          EndIf
          *pRead + SizeOf(Character)
        Wend
      Else
        While *pRead
          hist(*pRead\c) + 1
          *pRead + SizeOf(Character)
        Wend       
      EndIf   
    EndIf    
    
    If *outLength       ; If Return Length
      *outLength\i = (*pRead - *String)/SizeOf(Character)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  CharHistogram = @_CharHistogram()     ; Bind ProcedureAddress to the PrototypeHandler
  
  Procedure.i LenSSE(*String)
  ; ============================================================================
  ; NAME: LenSSE
  ; DESC: Length in number of characters of 2-Byte Char Strings
  ; DESC: Use SSE PCmpIStrI operation. This is aprox. 3 times faster than PB Len()
  ; DESC: This functions needs CPU SSE4.2 support, introduced 2012.
  ; DESC: Better do not use it direct. Use it with Macro LenFast(String)
  ; VAR(*String): Pointer to String
  ; RET.i: Number of Characters
  ; ============================================================================
     
    DisableDebugger
   
    ; **********************************************************************
    CompilerIf #PbFwCfg_Module_Compile=#PbFwCfg_Module_Compile_ASM64 And #PB_Compiler_Unicode
    ; **********************************************************************
	            
      ; IMM8[1:0]	= 00b
    	;	Src data is unsigned bytes(16 packed unsigned bytes)
    	; IMM8[3:2]	= 10b
    	; 	We are using Equal Each aggregation
    	; IMM8[5:4]	= 00b
    	;	Positive Polarity, IntRes2	= IntRes1
    	; IMM8[6]	= 0b
    	;	ECX contains the least significant set bit in IntRes2
      
      ; XMM0 XMM1 XMM2 XMM3 XMM4
      ; XMM1 = [String1] : XMM2=[String2] : XMM3=WideCharMask
                           
      !XOR RDX, RDX
      !XOR RCX, RCX
      !MOV RAX, [p.p_String] 
      !Test RAX, RAX            ; If *String = 0
      !JZ .Exit                 ; Exit -> Retrun 0    

      !@@:
      !TEST RAX, 0Fh            ; Test for 16Byte align
      !JZ @f                    ; If NOT aligned
        !MOV DX, WORD [RAX]     ;   process Char by Char until aligned
        !TEST RDX, RDX          ;   Check for EndOfString
        !JZ .Return             ;   Break if EndOfString
        !INC RAX                ;   Pointer to NextChar
      !JMP @b                   ; Jump back to @@   
      !@@:                      ; from here we have 16Byte aligned address
      
      !PXOR XMM0, XMM0          ; XMM0 = 0
      !SUB RAX, 16              ; *String -16
      
      !@@:  
        !ADD RAX, 16            ; *String +16
        !PCMPISTRI XMM0, [RAX], 0001001b  ; EQUAL_EACH WORD
      !JNZ @b
      
      ; RCX will contain the offset from RAX where the first null
    	; terminating character was found.
      !SHL RCX, 1               ; Word to Byte
      !ADD RAX, RCX
      
      !.Return:
      !SUB RAX, [p.p_String]
      !SHR RAX, 1               ; ByteCounter to Word
      !.Exit:
      ProcedureReturn
                
    ; **********************************************************************
    ; CompilerElseIf #PbFwCfg_Module_Compile=#PbFwCfg_Module_Compile_C And #PB_Compiler_Unicode  ; C-Backend
    ; **********************************************************************
  
    ; **********************************************************************
    CompilerElse                                 ; Classic Version
    ; **********************************************************************                
      ProcedureReturn MemoryStringLength(*String)               
    CompilerEndIf   
    
    EnableDebugger   
  EndProcedure
  
  Procedure.i _ToggleStringEndianessF(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: ToggleStringEndianessF
  ; DESC: !PointerVersion! use it as ProtoType ToggleStringEndianessF()
  ; DESC: Toggles the endianess of a 2Byte Character String between 
  ; DESC: BigEndian/Motorola <=> LittleEndian/Intel. 
  ; DESC: Each call changes the Endianess directly in memory.
  ; VAR(*String) : Pointer to the String
  ; VAR(*outLength.Integer): Optional a Pointer To an Int To receive the Length
  ; RET.i : *String 
  ; ============================================================================

   CompilerSelect #PbFwCfg_Module_Compile
	    
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_ASM64      ; ASM x64 Version             
	  ; **********************************************************************    
               
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
   
      ; SingleChar Version
      Protected *pRead.PX::pChar = *String 
      While *pRead\u 
        ; Swap *pRead\aa[0], *pRead\aa[1]
        *pRead\u = PX::BSwap16(*pRead\u)
        *pRead + 2   ; do not use SizeOf(Character) otherwise you can't use function in older Ascii String Versions of PB
      Wend
      
      If *outLength       ; If Return Length
        *outLength\i = (*pRead - *String)/SizeOf(Character)
      EndIf
      
      ProcedureReturn *String
     
    CompilerEndSelect   
  EndProcedure
  ToggleStringEndianessF=@_ToggleStringEndianessF()
  
  Procedure.s ToggleStringEndianess(String$, *outLength.Integer=0)
    _ToggleStringEndianessF(@String$, *outLength)
    ProcedureReturn String$
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- LCase and UCase
  ;- ----------------------------------------------------------------------
 
  Procedure.c LCaseChar255(Char.c)    
  ; ============================================================================
  ; NAME: LCaseChar255
  ; DESC: LCase an ASCii Char <255, Unicode Characters Char>255 are ignored
  ; VAR(Char.c) : The Character
  ; RET.c : UCase(Char)
  ; ============================================================================
    If Char <255
      If FlagTable(Char) & #FStr_Flag_Up
        ProcedureReturn Char + 32
      EndIf      
    EndIf    
    ProcedureReturn Char    
  EndProcedure
  
  Procedure.c UCaseChar255(Char.c)    
  ; ============================================================================
  ; NAME: UCaseChar255
  ; DESC: UCase an ASCii Char <255, Unicode Characters Char>255 are ignored
  ; VAR(Char.c) : The Character
  ; RET.c : UCase(Char)
  ; ============================================================================
    If Char <255
      If FlagTable(Char) & #FStr_Flag_Lo
        ProcedureReturn Char - 32
      EndIf      
    EndIf
    ProcedureReturn Char    
  EndProcedure
  
  Procedure _LCase255F(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: LCase255F
  ; DESC: LCase only ASCii Chars in Strings (Chars<255) 
  ; DESC: Fast means directly in Memory. String is not copied!
  ; VAR(*String) : Pointer to String$
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.- :
  ; ============================================================================
    Protected *pChar.Character = *String
    
    While *pChar\c
      If *pChar\c <255
        If FlagTable(*pChar\c) & #FStr_Flag_Up
          *pChar\c +32  
        EndIf
      EndIf             
      *pChar + SizeOf(Character)
    Wend   
    
    If *outLength   ; optional return Len(String)
      *outLength\i = (*pChar - *String)/SizeOf(Character)  
    EndIf
  EndProcedure
  LCase255F = @_LCase255F()
  
  Procedure.s LCase255(String$, *outLength.Integer=0)
    _LCase255F(@String$, *outLength)
    ProcedureReturn String$
  EndProcedure
  
  Procedure _UCase255F(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: UCase255F
  ; DESC: UCase only ASCii Chars in Strings (Chars<255) 
  ; DESC: Fast means directly in Memory. String is not copied!
  ; VAR(*String) : Pointer to String$
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.- :
  ; ============================================================================
    Protected *pChar.Character = *String
    
    While *pChar\c
      If *pChar\c <255
        If FlagTable(*pChar\c) & #FStr_Flag_Lo
          *pChar\c -32  
        EndIf
      EndIf 
      *pChar + SizeOf(Character)
    Wend   
    
    If *outLength   ; optional return Len(String)
      *outLength\i = (*pChar - *String)/SizeOf(Character)  
    EndIf   
  EndProcedure
  UCase255F = @_UCase255F()
  
  Procedure.s UCase255(String$, *outLength.Integer=0)
    _UCase255F(@String$, *outLength)
    ProcedureReturn String$
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;-  Find and Replace
  ;- ----------------------------------------------------------------------

  Procedure _CountChar(*String, cSearch.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: CountChar
  ; DESC: Counts Characters in a String
  ; DESC: Attention! Pointerversion! Call over Prototype definition!
  ; DESC: 
  ; VAR(*String) : Pointer to the String
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : Number of Characters found
  ; ============================================================================
    
	CompilerSelect #PbFwCfg_Module_Compile
	    
    ; **********************************************************************
    CompilerCase #PbFwCfg_Module_Compile_ASM64      ; ASM x64 Version             
	  ; **********************************************************************
     
      ; Used Registers:
      ;   RAX : Pointer *String
      ;   RCX : operating Register and Bool: 1 if NullChar was found
      ;   RDX : operating Register
      ;   R8  : Counter
      ;   R9  : operating Register
      
      ;   XMM0 : the 4 Chars
      ;   XMM1 : cSearch shuffeled to all Words
      ;   XMM2 : 0 to search for EndOfString
      ;   XMM3 : the 4 Chars Backup
      
      ; If you use XMM4..XMM7 you have to backup it first
      ;   XMM4 : 
      ;   XMM5 : 
      ;   XMM6 :
      ;   XMM7 :
      
      ; ASM_PUSH_XMM_4to5(RDX)     ; optional PUSH() see PbFw_ASM_Macros.pbi
      
      ; ----------------------------------------------------------------------
      ; Check *String-Pointer and MOV it to RAX as operating register
      ; ----------------------------------------------------------------------
      !MOV RAX, [p.p_String]    ; load String address
      !Test RAX, RAX            ; If *String = 0
      !JZ .Return               ; Exit    
      !SUB RAX, 8               ; Sub 8 to start with Add 8 in the Loop     
      ; ----------------------------------------------------------------------
      ; Setup start parameter for registers 
      ; ----------------------------------------------------------------------     
      ; your indiviual setup parameters
      !MOVZX RDX, WORD [p.v_cSearch] ; ZeroExpanded load of 1 Word
      !MOVQ XMM1, RDX
      !PSHUFLW XMM1, XMM1, 0    ; Shuffle/Copy Word0 to all Words 
      
      ; here are the standard setup parameters
      !XOR RCX, RCX             ; operating Register and BOOL for EndOfStringFound
      !XOR R8, R8               ; Counter = 0
      !PXOR XMM2, XMM2          ; XMM2 = 0 ; Mask to search for NullChar = EndOfString         
      ; ----------------------------------------------------------------------
      ; Main Loop
      ; ----------------------------------------------------------------------     
      !.Loop:
        !ADD RAX, 8                     ; *String + 8 => NextChars    
        !MOVQ XMM0, [RAX]               ; load 4 Chars to XMM0  
        !MOVQ XMM3, [RAX]               ; load 4 Chars to XMM3
        !PCMPEQW XMM0, XMM2             ; Compare with 0
        !MOVQ RDX, XMM0                 ; RDX CompareResult contains FFFF for each NullChar 
        !TEST RDX, RDX                  ; If 0 : No NullChar found
        !JZ .EndIf                      ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
        ; If EndOfStringFound  
          ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
          !BSF RDX, RDX                 ; BitSanForward => No of the LSB   
          !SHR RDX, 3                   ; BitNo to ByteNo
          !ADD RAX, RDX                 ; Actual StringPointer + OffsetOf_NullChar
          !MOV RCX, RDX                 ; Save ByteOfsett of NullChar in RCX
          !SUB RAX, [p.p_String]        ; RAX *EndOfString - *String
          !SHR RAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
          ;check for Return of Length and and move it to *outLength 
          !MOV RDX, [p.p_outLength]
          !TEST RDX, RDX
          !JZ @f                        ; If *outLength
            !MOV [RDX], RAX             ;   *outLength = Len()
          !@@:                          ; Endif
        
          ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
          ; In RCX ist the Backup of the ByteOffset of NullChahr
          !CMP RCX, 6                   ; If NullChar is the last Char : Byte[7,6]=Word[3]
          !JGE @f                       ;  => we don't have to eliminate chars from testing
            ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 48..63 = Word 3
            !SHL RCX, 3                   ; ByteNo to BitNo
            !NEG RCX                      ; RCX = -LSB 
            !ADD RCX, 63                  ; RCX = (63-LSB)
            !XOR RDX, RDX                 ; RDX = 0
            !BTS RDX, 63                  ; set Bit 63 => RDX = 8000000000000000h
            !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
            !NOT RDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
            !MOVQ XMM0, RDX               ; Now move this Mask to XMM0, the operating Register
            !PAND XMM3, XMM0              ; XMM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
          !@@:
          
          !MOV RCX, 1                     ; BOOL EndOfStringFound = #TRUE
        !.EndIf:                     ; Endif ; EndOfStringFound    
        
        ; ------------------------------------------------------------
        ; Start of function individual code! Do not use RCX here!
        ; ------------------------------------------------------------
        ; Count number of found Chars
        !MOVQ XMM0, XMM3              ; Load the 4 Chars to operating Register
        !PCMPEQW XMM0, XMM1           ; Compare the 4 Chars with cSearch
        !MOVQ RDX, XMM0               ; CompareResult to RDX
        !TEST RDX, RDX
        !JZ @f                        ; Jump to Endif if cSearch not found
          !POPCNT RDX, RDX            ; Count number of set Bits (16 for each found Char)
          !SHR RDX, 4                 ; NoOfBits [0..64] to NoOfWords [0..4]
          !ADD R8, RDX                ; ADD NoOfFoundChars to Counter R8
        !@@: 
        ; ------------------------------------------------------------
        
        !TEST RCX, RCX                ; Check BOOL EndOfStringFound      
      !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
      
      ; ----------------------------------------------------------------------
      ; Handle Return value an POP-Registers
      ; ----------------------------------------------------------------------     
      !MOV RAX, R8      ; ReturnValue to RAX
      !.Return:
      
      ; ASM_POP_XMM_4to5(RDX)     ; POP non volatile Registers we PUSH'ed at start
      
      ProcedureReturn   ; RAX
               
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
        
      Protected *pRead.Character = *String
      Protected N
        
      If Not *String
        ProcedureReturn 0
      EndIf
      
      While *pRead\c    ; Step trough the String
        If *pRead\c = cSearch.c
          N + 1
        EndIf
        *pRead + SizeOf(Character)
      Wend
     
      If *outLength       ; If Return Length
        *outLength\i = (*pRead - *String)/SizeOf(Character)
      EndIf
      ProcedureReturn N		
 
    CompilerEndSelect   
  EndProcedure
  CountChar = @_CountChar()
  
  Procedure _FindChar(*String, cSearch.c)
  ; ============================================================================
  ; NAME: FindChar
  ; DESC: Find a Characters in a String
  ; DESC: Attention! Pointerversion! Call over Prototype definition!
  ; DESC: 
  ; VAR(*String) : Pointer to the String
  ; RET.i : Position found [1..n] or 0 if not found
  ; ============================================================================
    
	CompilerSelect #PbFwCfg_Module_Compile
	    
    ; **********************************************************************
    CompilerCase #PbFwCfg_Module_Compile_ASM64      ; ASM x64 Version             
	  ; **********************************************************************
     
      ; Used Registers:
      ;   RAX : Pointer *String
      ;   RCX : operating Register and Bool: 1 if NullChar was found
      ;   RDX : operating Register
      ;   R8  : Position of Character found
      ;   R9  : operating Register
      
      ;   XMM0 : the 4 Chars
      ;   XMM1 : cSearch shuffeled to all Words
      ;   XMM2 : 0 to search for EndOfString
      ;   XMM3 : the 4 Chars Backup
      
      ; If you use XMM4..XMM7 you have to backup it first
      ;   XMM4 : 
      ;   XMM5 : 
      ;   XMM6 :
      ;   XMM7 :
      
      ; ASM_PUSH_XMM_4to5(RDX)     ; optional PUSH() see PbFw_ASM_Macros.pbi
      
      ; ----------------------------------------------------------------------
      ; Check *String-Pointer and MOV it to RAX as operating register
      ; ----------------------------------------------------------------------
      !MOV RAX, [p.p_String]    ; load String address
      !Test RAX, RAX            ; If *String = 0
      !JZ .Return               ; Exit    
      !SUB RAX, 8               ; Sub 8 to start with Add 8 in the Loop     
      ; ----------------------------------------------------------------------
      ; Setup start parameter for registers 
      ; ----------------------------------------------------------------------     
      ; your indiviual setup parameters
      !MOVZX RDX, WORD [p.v_cSearch] ; ZeroExpanded load of 1 Word
      !MOVQ XMM1, RDX
      !PSHUFLW XMM1, XMM1, 0    ; Shuffle/Copy Word0 to all Words 
      
      ; here are the standard setup parameters
      !XOR RCX, RCX             ; operating Register and BOOL for EndOfStringFound
      !XOR R8, R8               ; Counter = 0
      !PXOR XMM2, XMM2          ; XMM2 = 0 ; Mask to search for NullChar = EndOfString         
      ; ----------------------------------------------------------------------
      ; Main Loop
      ; ----------------------------------------------------------------------     
      !.Loop:
        !ADD RAX, 8                     ; *String + 8 => NextChars    
        !MOVQ XMM0, [RAX]               ; load 4 Chars to XMM0  
        !MOVQ XMM3, [RAX]               ; load 4 Chars to XMM3
        !PCMPEQW XMM0, XMM2             ; Compare with 0
        !MOVQ RDX, XMM0                 ; RDX CompareResult contains FFFF for each NullChar 
        !TEST RDX, RDX                  ; If 0 : No NullChar found
        !JZ .EndIf                      ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
        ; If EndOfStringFound  
          ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
          !BSF RDX, RDX                 ; BitSanForward => No of the LSB   
          !SHR RDX, 3                   ; BitNo to ByteNo
          !MOV R9, RAX                  ; because we have to keep Pointer in RAX, we use R9
          !ADD R9, RDX                  ; Actual StringPointer + OffsetOf_NullChar
          !MOV RCX, RDX                 ; Save ByteOfsett of NullChar in RCX        
          ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
          ; In RCX ist the Backup of the ByteOffset of NullChahr
          !CMP RCX, 6                   ; If NullChar is the last Char : Byte[7,6]=Word[3]
          !JGE @f                       ;  => we don't have to eliminate chars from testing
            ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 48..63 = Word 3
            !SHL RCX, 3                   ; ByteNo to BitNo
            !NEG RCX                      ; RCX = -LSB 
            !ADD RCX, 63                  ; RCX = (63-LSB)
            !XOR RDX, RDX                 ; RDX = 0
            !BTS RDX, 63                  ; set Bit 63 => RDX = 8000000000000000h
            !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
            !NOT RDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
            !MOVQ XMM0, RDX               ; Now move this Mask to XMM0, the operating Register
            !PAND XMM3, XMM0              ; XMM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
          !@@:
          
          !MOV RCX, 1                     ; BOOL EndOfStringFound = #TRUE
        !.EndIf:                     ; Endif ; EndOfStringFound    
        
        ; ------------------------------------------------------------
        ; Start of function individual code! Do not use RCX here!
        ; ------------------------------------------------------------
        ; Calculate position of Char found [1..n]
        !MOVQ XMM0, XMM3              ; Load the 4 Chars to operating Register
        !PCMPEQW XMM0, XMM1           ; Compare the 4 Chars with cSearch
        !MOVQ RDX, XMM0               ; CompareResult to RDX
        !TEST RDX, RDX
        !JZ @f                        ; Jump to Endif if cSearch not found
          !BSF RDX, RDX               ; Find first set Bit
          !SHR RDX, 3                 ; BitNo to ByteNo
          !MOV R8, RDX                ; R8 = ByteNo
          !ADD R8, RAX                ; R8 = ByteNo + ActualStringPointer
          !SUB R8, [p.p_String]       ; distance in Bytes
          !SHR R8, 1                  ; NoOfWords
          !INC R8                     ; because Position is[1..n], Add1
          !MOV RAX, R8                ; Position to RAX for return
          !JMP .Return
        !@@: 
        ; ------------------------------------------------------------
        !TEST RCX, RCX                ; Check BOOL EndOfStringFound      
      !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
      
      ; ----------------------------------------------------------------------
      ; Handle Return value an POP-Registers
      ; ----------------------------------------------------------------------     
      !MOV RAX, R8      ; ReturnValue to RAX
      !.Return:
      
      ; ASM_POP_XMM_4to5(RDX)     ; POP non volatile Registers we PUSH'ed at start
      
      ProcedureReturn   ; RAX
               
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
        
      Protected *pRead.Character = *String
      Protected N, pos
        
      If Not *String
        ProcedureReturn 0
      EndIf
      
      While *pRead\c    ; Step trough the String
        If *pRead\c = cSearch.c
          pos = N
          Break
        EndIf
        *pRead + SizeOf(Character)
        N+1
      Wend
     
      ProcedureReturn pos		
 
    CompilerEndSelect   
  EndProcedure
  FindChar = @_FindChar()
 
  Procedure.i _FindCharReverse(*String.Character, cSearch.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: FindCharReverse
  ; DESC: !PointerVersion! use it as ProtoType FindCharReverse()
  ; DESC: Finds the first psoition of Char from reverse
  ; DESC: 
  ; VAR(*String.Character) : Pointer to the String
  ; VAR(cSearch) : Character to find
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : Character Position 1..n of cSearch, or 0 if no Char found 
  ; ============================================================================ 
    
    ; 2025/07/30 S.Maag: changed ASM Code to standard template for search Chars and tested in ASM and PB version
    ; 2025/07/31 S.Maag: changed BitScanForward BSF to BitScanReverse BSR, because we need Character form right
    ;                    this caused a problem with duble chars like "file..dat"- > returned firs Dot not last!
  
    
 	  CompilerSelect #PbFwCfg_Module_Compile
	    
      ; **********************************************************************
      CompilerCase #PbFwCfg_Module_Compile_ASM64      ; ASM x64 Version             
	    ; **********************************************************************
      
        ; Used Registers:
        ;   RAX : Pointer *String
        ;   RCX : operating Register and Bool: 1 if NullChar was found
        ;   RDX : operating Register
        ;   R8  : *pCharFound -> NoOfChars
        ;   R9  : operating Register
        ;   R10 :
        
        ;   XMM0 : the 4 Chars
        ;   XMM1 : cSearch shuffeled to all Words
        ;   XMM2 : 0 to search for EndOfString
        ;   XMM3 : the 4 Chars Backup
        
        ; If you use XMM4..XMM7 you have to backup it first
        ;   XMM4 : 
        ;   XMM5 : 
        ;   XMM6 :
        ;   XMM7 :
        
        ; ASM_PUSH_XMM_4to5(RDX)     ; optional PUSH() see PbFw_ASM_Macros.pbi
     
        ; ----------------------------------------------------------------------
        ; Check *String-Pointer and MOV it to RAX as operating register
        ; ----------------------------------------------------------------------
        !MOV RAX, [p.p_String]    ; load String address
        !Test RAX, RAX            ; If *String = 0
        !JZ .Return               ; Exit    
        !SUB RAX, 8               ; Sub 8 to start with Add 8 in the Loop     
        ; ----------------------------------------------------------------------
        ; Setup start parameter for registers 
        ; ----------------------------------------------------------------------     
        ; your indiviual setup parameters
        !MOVZX RDX, WORD [p.v_cSearch] ; ZeroExpanded load of 1 Word = load Char
        !MOVQ XMM1, RDX
        !PSHUFLW XMM1, XMM1, 0    ; Shuffle/Copy Word0 to all Words 
        
        ; here are the standard setup parameters
        !XOR RCX, RCX             ; operating Register and BOOL for EndOfStringFound
        !XOR R8, R8               ; *pCharFound = 0
        !PXOR XMM2, XMM2          ; XMM2 = 0 ; Mask to search for NullChar = EndOfString         
        ; ----------------------------------------------------------------------
        ; Main Loop
        ; ----------------------------------------------------------------------     
        !.Loop:
          !ADD RAX, 8                     ; *String + 8 => NextChars    
          !MOVQ XMM0, [RAX]               ; load 4 Chars to XMM0  
          !MOVQ XMM3, [RAX]               ; load 4 Chars to XMM3
          !PCMPEQW XMM0, XMM2             ; Compare with 0
          !MOVQ RDX, XMM0                 ; RDX CompareResult contains FFFF for each NullChar 
          !TEST RDX, RDX                  ; If 0 : No NullChar found
          !JZ .EndIf                      ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
          ; If EndOfStringFound  
            ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
            !BSF RDX, RDX                 ; BitSanForward => No of the LSB   
            !SHR RDX, 3                   ; BitNo to ByteNo            
            !MOV R9, RAX                  ; because we have to keep Pointer in RAX, we use R9
            !ADD R9, RDX                  ; Actual StringPointer + OffsetOf_NullChar
            !MOV RCX, RDX                 ; Save ByteOfsett of NullChar in RCX                    
            !SUB R9, [p.p_String]         ; RAX *EndOfString - *String
            !SHR R9, 1                    ; NoOfBytes to NoOfWord => Len(String)
            ; ------------------------------------------------------------
            ; check for Return of Length and and move it to *outLength 
            ; ------------------------------------------------------------
            !MOV RDX, [p.p_outLength]
            !TEST RDX, RDX
            !JZ @f                        ; If *outLength
              !MOV [RDX], R9             ;   *outLength = Len()
            !@@:                          ; Endif
            ; ------------------------------------------------------------      
            
            ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
            ; In RCX ist the Backup of the ByteOffset of NullChahr
            !CMP RCX, 6                   ; If NullChar is the last Char : Byte[7,6]=Word[3]
            !JGE @f                       ;  => we don't have to eliminate chars from testing
              ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 48..63 = Word 3
              !SHL RCX, 3                   ; ByteNo to BitNo
              !NEG RCX                      ; RCX = -LSB 
              !ADD RCX, 63                  ; RCX = (63-LSB)
              !XOR RDX, RDX                 ; RDX = 0
              !BTS RDX, 63                  ; set Bit 63 => RDX = 8000000000000000h
              !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
              !NOT RDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
              !MOVQ XMM0, RDX               ; Now move this Mask to XMM0, the operating Register
              !PAND XMM3, XMM0              ; XMM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
            !@@:
            
            !MOV RCX, 1                     ; BOOL EndOfStringFound = #TRUE
          !.EndIf:                        ; Endif ; EndOfStringFound    
          
          ; ------------------------------------------------------------
          ; Start of function individual code! Do not use RCX here!
          ; ------------------------------------------------------------
          ; Count number of found Chars
          !MOVQ XMM0, XMM3              ; Load the 4 Chars to operating Register
          !PCMPEQW XMM0, XMM1           ; Compare the 4 Chars with cSearch
          !MOVQ RDX, XMM0               ; CompareResult to RDX
          !TEST RDX, RDX
          !JZ @f                          ; Jump to Endif if cSearch not found
            ; because we need Character from right, we have to use BSR, not BSF
            !BSR RDX, RDX                 ; BitScan finds the MSB Bitposition
            !SHR RDX, 3                   ; BitNo => ByteNO
            !MOV R8, RAX                  ; R8 = *pCharFound
            !ADD R8, RDX                  ; ADD ByteNo to *String
          !@@: 
          ; ------------------------------------------------------------
          
          !TEST RCX, RCX                ; Check BOOL EndOfStringFound      
        !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
        
        ; ----------------------------------------------------------------------
        ; Handle Return value and POP-Registers
        ; ----------------------------------------------------------------------         
        
        !XOR RAX, RAX             ; RAX = 0
        !TEST R8, R8              ; TEST *pCharFound = 0
        !JZ .Return               ; If *pCharFound = 0 Then .Return 0
        ; Else Return NoOfChars
        !MOV RAX, R8              ; RAX = *pCharFound
        !SUB RAX, [p.p_String]    ; RAX = *pCharFound - *String
        !SHR RAX, 1               ; Bytes -> Chars
        !INC RAX
        !.Return:
        
        ProcedureReturn   ; RAX
           
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
      
      ; ----------------------------------------------------------------------
      ;  PB-Standard-Code
      ; ----------------------------------------------------------------------         
      
      Protected *pChar.Character = *String
      Protected *LastChar
     
      If Not *pChar
        ProcedureReturn 0
      EndIf
      
      While *pChar\c
        If *pChar\c = cSearch
          *LastChar = *pChar
        EndIf
        *pChar + SizeOf(Character)
      Wend
            
      If *outLength
        *outLength\i = (*pChar - *String) / SizeOf(Character)
      EndIf
      
      If *LastChar=0 
        ProcedureReturn 0
      Else
        ProcedureReturn (*LastChar - *String) / SizeOf(Character) + 1
      EndIf
          
    CompilerEndSelect   
  EndProcedure
  FindCharReverse = @_FindCharReverse()   ; Bind ProcedureAddress to the PrototypeHandler
  
  Procedure.i _ReplaceCharF(*String, cSearch.c, cReplace.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: _ReplaceCharF
  ; DESC: !PointerVersion! use it as ProtoType ReplaceChar()
  ; DESC: Replace a Character in a String with an other Character
  ; DESC: To replace all ',' with a '.' use : _ReplaceChar(@MyString, ',', '.')
  ; DESC: This a replacement for ReplaceString() only for a single Char
  ; DESC: and with direct *String Access. This is 2-3 tiems faster than
  ; DESC: ReplaceString() with #PB_String_InPlace 
  ; DESC: To UCase a single char use ReplaceChar(MyString, 'e', 'E')
  ; VAR(String$) : The String
  ; VAR(cSearch) : Character to search for and replace
  ; VAR(cReplace): the Replace Character (new Character)
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : Number of Chars replaced
  ; ============================================================================
          
	CompilerSelect #PbFwCfg_Module_Compile
	    
	  ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_ASM64      ; ASM x64 Version             
	  ; **********************************************************************
	    
	    ; !!! not ready implemented in ASM!!!
	    
      ; Used Registers:
      ;   RAX : Pointer *String
      ;   RCX : operating Register and Bool: 1 if NullChar was found
      ;   RDX : operating Register
      ;   R8  : Counter
      ;   R9  : operating Register
      
      ;   XMM0 : the 4 Chars
      ;   XMM1 : operating Register
      ;   XMM2 : 0 to search for EndOfString
      ;   XMM3 : the 4 Chars Backup
      
      ; If you use XMM4..XMM7 you have to backup it first
      ;   XMM4 : cSearch shuffeled to all Words
      ;   XMM5 :
      ;   XMM6 :
      ;   XMM7 :
      
      ; ASM_PUSH_XMM_4to5(RDX)     ; optional PUSH() see PbFw_ASM_Macros.pbi
     
      ; ----------------------------------------------------------------------
      ; Check *String-Pointer and MOV it to RAX as operating register
      ; ----------------------------------------------------------------------
      !MOV RAX, [p.p_String]    ; load String address
      !TEST RAX, RAX            ; If *String = 0
      !JZ .Return               ; Exit    
      !SUB RAX, 8               ; Sub 8 to start with Add 8 in the Loop     
      ; ----------------------------------------------------------------------
      ; Setup start parameter for registers 
      ; ----------------------------------------------------------------------     
      ; your indiviual setup parameters
      !MOVZX RDX, WORD [p.v_cSearch] ; ZeroExpanded load of 1 Word
      !MOVQ XMM4, RDX
      !PSHUFLW XMM4, XMM4, 0    ; Shuffle/Copy Word0 to all Words 
      
      ; here are the standard setup parameters
      !XOR RCX, RCX             ; operating Register and BOOL for EndOfStringFound
      !XOR R8, R8               ; Counter = 0
      !PXOR XMM2, XMM2          ; XMM2 = 0 ; Mask to search for NullChar = EndOfString         
      ; ----------------------------------------------------------------------
      ; Main Loop
      ; ----------------------------------------------------------------------     
      !.Loop:
        !ADD RAX, 8                     ; *String + 8 => NextChars    
        !MOVQ XMM0, [RAX]               ; load 4 Chars to XMM0  
        !MOVQ XMM3, [RAX]               ; load 4 Chars to XMM3
        !PCMPEQW XMM0, XMM2             ; Compare with 0
        !MOVQ RDX, XMM0                 ; RDX CompareResult contains FFFF for each NullChar 
        !TEST RDX, RDX                  ; If 0 : No NullChar found
        !JZ .EndIf                      ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
        ; If EndOfStringFound  
          ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
          !BSF RDX, RDX                 ; BitSanForward => No of the LSB   
          !SHR RDX, 3                   ; BitNo to ByteNo
          !ADD RAX, RDX                 ; Actual StringPointer + OffsetOf_NullChar
          !SUB RAX, [p.p_String]        ; RAX *EndOfString - *String
          !SHR RAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
          ;check for Return of Length and and move it to *outLength 
          !MOV RDX, [p.p_outLength]
          !TEST RDX, RDX
          !JZ @f                        ; If *outLength
            !MOV [RDX], RAX             ;   *outLength = Len()
          !@@:                          ; Endif
        
          ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
          !MOVQ RCX, XMM0               ; Load compare Result of 4xChars=0 to RCX
          !BSF RCX, RCX                 ; Find No of LSB [0..63] (if no Bit found it returns 0 too)
          !CMP RCX, 48                  ; If LSB >= 48 the EndOfString is the last of the 4 Chars
          !JGE @f                       ;  => we don't have to eliminate chars from testing
          ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 48..63 = Word 3
            !NEG RCX                      ; RCX = -LSB 
            !ADD RCX, 63                  ; RCX = (63-LSB)
            !XOR RDX, RDX                 ; RDX = 0
            !BTS RDX, 63                  ; set Bit 63 => RDX = 8000000000000000h
            !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
            !NOT RDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
            !MOVQ XMM0, RDX               ; Now move this Mask to XMM0, the operating Register
            !PAND XMM3, XMM0              ; XMM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
          !@@:
          
          !MOV RCX, 1                     ; BOOL EndOfStringFound = #TRUE
        !.EndIf:                        ; Endif ; EndOfStringFound    
        
        ; ------------------------------------------------------------
        ; Start of function individual code! Do not use RCX here!
        ; ------------------------------------------------------------
        ; Replace the Chars
        ; TODO! Implement CODE!
        ; ------------------------------------------------------------
        
        !TEST RCX, RCX                  ; Check BOOL EndOfStringFound      
      !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
       
      ; ----------------------------------------------------------------------
      ; Handle Return value an POP-Registers
      ; ----------------------------------------------------------------------     
      !MOV RAX, R8      ; ReturnValue to RAX
      !.Return:
      
      ; ASM_POP_XMM_4to5(RDX)     ; POP non volatile Registers we PUSH'ed at start
     
      ProcedureReturn   ; RAX     
             
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
        
      Protected *pRead.Character   ; Pointer to a virutal Char-Struct
      Protected N
      
      *pRead = *String         
      If *pRead    
        While *pRead\c                ; until end of String
          If *pRead\c =  cSearch
            *pRead\c = cReplace       ; replace the Char
            N + 1
          EndIf
          *pRead + SizeOf(Character)  ; Index to next Char
        Wend
      EndIf     
      
      If *outLength
        *outLength\i = (*pRead - *String) / SizeOf(Character)
      EndIf
      
      ProcedureReturn N   
      
    CompilerEndSelect   
  EndProcedure
  ReplaceCharF = @_ReplaceCharF()     ; Bind ProcedureAddress to the PrototypeHandler
  
  Procedure.s ReplaceChar(String$, cSearch.c, cReplace.c, *outLength.Integer=0)
    _ReplaceCharF(@String$,cSearch, cReplace, *outLength)
    ProcedureReturn PeekS(@String$)  
  EndProcedure
  
  Procedure.i _ReplaceAccentsF(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: ReplaceAccents
  ; DESC: Replace accent characters with their base characters
  ; DESC: áàä..->a, éè..->e, ìí..->i ...
  ; DESC: Removes all accent characters in the ASCII Table >=192 with the base
  ; DESC: characters.
  ; VAR(*String) : Pointer to the String with accent characters
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i: *String
  ; ============================================================================
    
  CompilerSelect #PbFwCfg_Module_Compile
	    
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_ASM64    ; ASM x64 Version             
	  ; **********************************************************************    
              
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
    
      Protected *pRead.Character = *String
      
      If *pRead 	
        While *pRead\c
          If *pRead\c >= 192   ; Accent chars start at 192 with 'À'    
            
            Select *pRead\c
    
         			Case 224 To 230   ; 'a' with accents
                *pRead\c = 'a'            
              Case 232 To 235   ; 'e' with accents
                *pRead\c = 'e'              
              Case 236 To 239   ; 'i' with accents
                *pRead\c = 'i'             
              Case 242 To 246   ; 'o' with accents
        				*pRead\c = 'o'             
              Case 249 To 252   ; 'u' with accents
        				*pRead\c = 'u'
        				
        			Case 192 To 198   ; 'A' with accents
                *pRead\c = 'A'
              Case 200 To 203   ; 'E' with accents
                *pRead\c = 'E'           
              Case 204 To 207   ; 'I' with accents
                *pRead\c = 'I'
              Case 210 To 214   ; 'O' with accents
        				*pRead\c = 'O'
              Case 217 To 220   ; 'U' with accents
        				*pRead\c = 'U'
        				                      				
          		Case 241          ; 'n' with accent 
          	    *pRead\c = 'n'
        			Case 209          ; 'N' with accent
         				*pRead\c = 'N'
         				
         			Case 221          ; 'Y' with accent
        			  *pRead\c = 'Y'
        			Case 253, 255     ; 'y' with accents
         				*pRead\c = 'y'    				     			  
         		EndSelect
        	EndIf     	
        	*pRead + SizeOf(Character)
      	Wend
      EndIf
      
      If *outLength       ; If Return Length
        *outLength\i = (*pRead - *String)/SizeOf(Character)
      EndIf

      ProcedureReturn *String
              
    CompilerEndSelect   
  EndProcedure
  ReplaceAccentsF = @_ReplaceAccentsF()
  
  Procedure.s ReplaceAccents(String$, *outLength.Integer=0)
    _ReplaceAccentsF(@String$, *outLength)
    ProcedureReturn PeekS(@String$)  
  EndProcedure  
 
  ;- ----------------------------------------------------------------------
  ;-  Remove
  ;- ----------------------------------------------------------------------

  Macro mac_RemoveChar_KeepChar()
  	If *pWrite <> *pRead     ; if  WritePosition <> ReadPosition
  		*pWrite\c = *pRead\c   ; Copy the Character from ReadPosition to WritePosition => compacting the String
  	EndIf
  	*pWrite + SizeOf(Character) ; set new Write-Position 
  EndMacro

  Procedure.i _RemoveCharF(*String, Char.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: RemoveCharF
  ; NAME: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Removes a Character from the String
  ; DESC: The String will be shorter after
  ; VAR(*String) : Pointer to String
  ; VAR(Char.c) : The Character to remove
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i: Number of removed Chars 
  ; ============================================================================
    
  CompilerSelect #PbFwCfg_Module_Compile
      
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_ASM64    ; ASM x64 Version             
	  ; **********************************************************************
           
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
            
      Protected *pRead.Character = *String
      Protected *pWrite.Character = *String
    	    
      If (Not *String) Or (Not Char)
        ProcedureReturn
      EndIf
      
   	  While *pRead\c                ; While Not NullChar    
   	    If *pRead\c <> Char
   	      mac_RemoveChar_KeepChar()
        EndIf           
        *pRead +SizeOf(Character)   ; Set Pointer to NextChar
      Wend
    	
    	; If *pWrite is not at end of orignal *pRead,
    	; we removed some char and must write a 0-Termination as new EndOfString 
    	If *pRead <> *pWrite
    		*pWrite\c = 0
    	EndIf
    	
    	If *outLength         ; If Return Length
        *outLength\i = (*pRead - *String)/SizeOf(Character)
      EndIf
    	
    	ProcedureReturn (*pRead - *pWrite)/SizeOf(Character) ; Number of characters removed
    	
    CompilerEndSelect   
  EndProcedure
  RemoveCharF = @_RemoveCharF()
  
  Procedure.s RemoveChar(String$, Char.c, *outLength.Integer=0)
    _RemoveCharF(@String$, Char, *outLength)
    ProcedureReturn PeekS(@String$)
  EndProcedure
  
  Procedure.i _RemoveCharsF(*String, Char1.c, Char2.c=0, xTrim=#False, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: RemoveCharsF
  ; DESC: Removes up to 2 different Character from a String
  ; DESC: The String will be shorter after
  ; DESC: Example: str\s= " ..This, is a, Test.! " : RemoveChars(str\s, '.' , ',' ,#True)
  ; DESC: =>              "This is a Test!"
  ; VAR(*String.String) : Pointer to String-Struct
  ; VAR(Char1.c) : The first Character to remove
  ; VAR(Char2.c) : The second Character to remove 
  ; VAR(xTrim=#False): Do a left and right Trim (remove leading Spaces)
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i: Number of removed Characters
  ; ============================================================================
    
  CompilerSelect #PbFwCfg_Module_Compile
	    
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_ASM64      ; ASM x64 Version             
	  ; **********************************************************************
     
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
    
      Protected *pRead.Character = *String  	
      Protected *pWrite.Character = *String  	
      Protected cnt
      
      If Not *String Or Not Char1
        ProcedureReturn 0
      EndIf
      
      If Char2 = 0      ; for the routine, Char2 can't be 0
        Char2 = Char1
      EndIf 
  
      ; ----------------------------------------------------------------------
      ; If xTrim Then !remove leading characters {Space, TAB}
      ; ----------------------------------------------------------------------
      If xTrim     ; if remove leading Space AND char
        While PX::IsSpaceTabChar(*pRead\c)
          PX::INCC(*pRead)  ; Set the ReadPositon to next Character
          cnt +1            ; count removed Characters           
        Wend 
      EndIf  
      
      ; ----------------------------------------------------------------------
      ; Removing Char1, Char2
      ; ----------------------------------------------------------------------  
     	While *pRead\c     ; While Not NullChar  	  
    	  Select *pRead\c	        	      
    	    Case Char1, Char2   ;  don't keep  Char
            ; do nothing removes the Char
    	      cnt +1            ; count removed Characters 
          Default             ; keep Char
            mac_RemoveChar_KeepChar()			
        EndSelect
        PX::INCC(*pRead)      ; Set Pointer to NextChar
      Wend
      
      ; ----------------------------------------------------------------------
      ; If xTrim Then !remove characters {Space, TAB} at right
      ; ----------------------------------------------------------------------  
      If xTrim
        PX::DECC(*pRead)    ; Decrement CharPointer
        While PX::IsSpaceTabChar(*pRead\c)
          *pRead\c = 0      ; Write EndOfString
          PX::DECC(*pRead)  ; Decrement CharPointer
          cnt +1            ; count removed Characters 
        Wend
      EndIf
    
      ; If Write Postion *pWrite <> Readpostion *pRead Then Write a NullChar at the end
      If *pWrite <> *pRead
        *pWrite\c = 0  
      EndIf
      
      If *outLength         ; If Return Length
        *outLength\i = (*pRead - *String)/SizeOf(Character)
      EndIf
      
      ProcedureReturn cnt
      
    CompilerEndSelect   
  EndProcedure
  RemoveCharsF = @_RemoveCharsF()
  
  Procedure.s RemoveChars(String$, Char1.c, Char2.c=0, xTrim=#False, *outLength.Integer=0)
    _RemoveCharsF(@String$, Char1, Char2, xTrim, *outLength)
    ProcedureReturn PeekS(@String$)
  EndProcedure
       
  Procedure.i _RemoveTabsAndDoubleSpaceF(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: RemoveTabsAndDoubleSpaceF
  ; DESC: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Removes all TABs and all double SPACEs from the String dirctly
  ; DESC: in memory by keeping allocated memory. The String will be shorter after!
  ; VAR(*String) : Pointer to String
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i: *String 
  ; ============================================================================
    
  CompilerSelect #PbFwCfg_Module_Compile
 
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_ASM64      ; ASM x64 Version             
	  ; **********************************************************************    
               
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
    
      Protected *pWrite.Character = *String
      Protected *pRead.PX::pChar = *String
           	  
      If Not *String
        ProcedureReturn
      EndIf
      
      ; Trim leading TABs and Spaces
      While *pRead\c
        If PX::IsSpaceTabChar(*pRead\c)
        Else
           Break
        EndIf    
        PX::INCC(*pRead) ; increment CharPointer
      Wend
      
    	While *pRead\c     ; While Not NullChar
    	  
    	  Select *pRead\c   	       	      
          ; If we check for the most probably Chars first, we speed up the operation
          ; because we minimze the number of checks to do!
          Case #TAB
            
            If PX::IsSpaceTabChar(*pRead\cc[1])
              ; if NextChar = 'SPACE or TAB) Then remove   
            Else
              ; if NextChar <> SPACE And NextChar <> TAB   
              *pRead\c = #FStr_CHAR_SPACE   ; Change TAB to SPACE
              mac_RemoveChar_KeepChar()     ; keep the Char
            EndIf
              
          Case #FStr_CHAR_SPACE
            
            If *pRead\cc[1] = #FStr_CHAR_SPACE        
             ; if NextChar = SPACE Then remove   
            Else
              mac_RemoveChar_KeepChar()   ; keep the Char
            EndIf          
            
          Default
            mac_RemoveChar_KeepChar()		; local Macro _KeepChar()         
        EndSelect
        
        PX::INCC(*pRead)    ; Set Pointer to NextChar 		
      Wend
    	
    	; If *pWrite is not at end of orignal *String,
    	; we removed some char and must write a 0-Termination as new EndOfString 
    	If *pRead <> *pWrite
    		*pWrite\c = 0
    	EndIf
    	
    	; Remove last Char if it is a SPACE -> RightTrim
    	PX::DECC(*pWrite)
    	If *pWrite\c = #FStr_CHAR_SPACE
    	  *pWrite\c = 0
    	EndIf
    	
      If *outLength       ; If Return Length
        *outLength\i = (*pRead - *String)/SizeOf(Character)
      EndIf

   	  ProcedureReturn *String
   	  
    CompilerEndSelect   
  EndProcedure
  RemoveTabsAndDoubleSpaceF=@_RemoveTabsAndDoubleSpaceF()
  
  Procedure.s RemoveTabsAndDoubleSpace(String$, *outLength.Integer=0)    
    _RemoveTabsAndDoubleSpaceF(@String$, *outLength)
 	  ProcedureReturn PeekS(@String$)
  EndProcedure
  
  Procedure.i _RemoveCharsWithFlagF(*String, Flags=#FStr_Flag_Accent, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: _RemoveCharsWithFlagF
  ; NAME: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Removes Characters with activated Flags from the String
  ; DESC: The String will be shorter after
  ; DESC: (question at PB-Forum: https://www.purebasic.fr/english/viewtopic.php?t=82139)
  ; VAR(*String) : Pointer to String
  ; VAR(Flags) : Value with the Character Flags to remove
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i: *String 
  ; ============================================================================
    
    Protected *pRead.Character = *String  	
    Protected *pWrite.Character = *String
  	    
    If Not *String
      ProcedureReturn
    EndIf
    
  	While *pRead\c     ; While Not NullChar  	  
  	  If *pRead <= 255
  	    If FlagTable(*pRead\c) & Flags
  	      mac_RemoveChar_KeepChar()
  	    EndIf
  	  Else
   	     mac_RemoveChar_KeepChar()
	    EndIf
	  Wend
	  
  	; If *pWrite is not at end of orignal *pRead,
  	; we removed some char and must write a 0-Termination as new EndOfString 
  	If *pRead <> *pWrite
  		*pWrite\c = 0
  	EndIf
  	
    If *outLength         ; If Return Length
      *outLength\i = (*pRead - *String)/SizeOf(Character)
    EndIf

    ProcedureReturn *String
  EndProcedure
  RemoveCharsWithFlagF = @_RemoveCharsWithFlagF()
  
  Procedure.s RemoveCharsWithFlag(String$, Flags=#FStr_Flag_Accent, *outLength.Integer=0)
    _RemoveCharsWithFlagF(@String$, Flags, *outLength)
    ProcedureReturn PeekS(@String$)
  EndProcedure
  
  Procedure.i _KeepCharsWithFlagF(*String, Flags=#FStr_Flag_Accent, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: _KeepCharsWithFlagF
  ; NAME: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Keeps Characters with activated Flags in the String and remove all others
  ; DESC: The String will be shorter after
  ; DESC: (question at PB-Forum: https://www.purebasic.fr/english/viewtopic.php?t=82139)
  ; VAR(*String) : Pointer to String
  ; VAR(Flags) : Value with the Character Flags to remove
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i: *String 
  ; ============================================================================
    
    Protected *pRead.Character = *String  	
    Protected *pWrite.Character = *String
  	    
    If Not *String
      ProcedureReturn
    EndIf
    
  	While *pRead\c     ; While Not NullChar  	  
  	  If *pRead <= 255
  	    If Not(FlagTable(*pRead\c) & Flags)
  	      mac_RemoveChar_KeepChar()
  	    EndIf
  	  Else
   	    mac_RemoveChar_KeepChar()
	    EndIf
	  Wend
	  
  	; If *pWrite is not at end of orignal *pRead,
  	; we removed some char and must write a 0-Termination as new EndOfString 
  	If *pRead <> *pWrite
  		*pWrite\c = 0
  	EndIf
  	
    If *outLength         ; If Return Length
      *outLength\i = (*pRead - *String)/SizeOf(Character)
    EndIf

    ProcedureReturn *String
  EndProcedure
  KeepCharsWithFlagF = @_KeepCharsWithFlagF()
  
  Procedure.s KeepCharsWithFlag(String$, Flags=#FStr_Flag_Accent, *outLength.Integer=0)
    _KeepCharsWithFlagF(@String$, Flags, *outLength)
    ProcedureReturn PeekS(@String$)
  EndProcedure

  _Init()     ; initialize Character FlagTable
EndModule

; ================================================================================


CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule FStr
  
  Define I
  Define txt.s
  txt = "12,345.6789"
  Debug @txt
  Debug "Test FindChar"
  Debug FindChar(txt, '1')
  Debug FindChar(txt, '2')
  Debug FindChar(txt, '3')
  Debug FindChar(txt, '4')
  Debug FindChar(txt, '5')
  Debug FindChar(txt, '.')
  Debug FindChar(txt, '6') 
  Debug FindChar(txt, '7')
  Debug FindChar(txt, '8')
  Debug FindChar(txt, '9')
  
  Debug FindChar("PureBasic", 32)
  
CompilerEndIf

CompilerIf #False
  
  ; Template for CompilerSelect
  
  CompilerSelect #PbFwCfg_Module_Compile
	    
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_ASM64      ; ASM x64 Version             
	  ; **********************************************************************    
               
    ; **********************************************************************
    ; CompilerCase #PbFwCfg_Module_Compile_C        ; C-Backend
    ; **********************************************************************

    ; **********************************************************************
    CompilerDefault                                 ; Classic Version
    ; **********************************************************************
         
  CompilerEndSelect   
  
CompilerEndIf


; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 153
; FirstLine = 153
; Folding = ----------
; DPIAware
; CPU = 5