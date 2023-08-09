; ===========================================================================
;  FILE : PbFw_Module_STRING.pb
;  NAME : Module String [STR::]
;  DESC : Provides extended String Functions 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/08
; VERSION  :  0.1 untested Developer Version
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
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile ""

DeclareModule STR
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  ; PB-Compiler use only #PB_Compiler_Unicode to specify Unicode or ASCII Mode
  ; PB 5.5 and higher use Unicode as Standard Mode
  ; older Versions use ASCII-Mode as standard for the EXE
  CompilerIf #PB_Compiler_Unicode
    #PbFw_STR_CharMode = #PB_Unicode       ; Application CharacterMode = Unicode
    #PbFw_STR_CharModeName = "Unicode"     ; Application CharacterModeName
  CompilerElse
    #PbFw_STR_CharMode = #PB_Ascii         ; Application CharacterMode = ASCII 
    #PbFw_STR_CharModeName = "ASCII"       ; Application CharacterModeName
  CompilerEndIf
  #PbFw_STR_CharSize = SizeOf(Character)   ; Application CharacterSize = 2 Bytes
   
  EnumerationBinary
    #PbFw_STR_xDoubleQuotes      
    #PbFw_STR_xSingleQuotes
  EndEnumeration
  
  #PbFw_STR_CHAR_TAB         =  9    ; TAB
  #PbFw_STR_CHAR_SPACE       = 32    ; ' '
  #PbFw_STR_CHAR_DoubleQuote = 34    ; "
  #PbFw_STR_CHAR_SingleQuote = 39    ; '
  
  ; Structure for indexing Words in Strings
  Structure TWordIndex
    WordStart.i     ; Character number of first char [1..]
    Length.i        ; Length in Characters
  EndStructure

  Prototype.i ReplaceChar(String$, cSearch.c, cReplace.c) ; ProtoType-Function for ReplaceChar
  Global ReplaceChar.ReplaceChar                 ; define Prototype-Handler for CountChar

  Prototype.i CountChar(String$, cSearch.c)  ; ProtoType-Function for CountChar
  Global CountChar.CountChar                 ; define Prototype-Handler for CountChar
 
  Prototype.i CountWords(*String, cSeparator.c=' ', IngnoreSpaces=#True)
  Global CountWords.CountWords               ; define Prototype-Handler for CountWords
  
  Prototype.s AddQuotes(String$, cQuote.c=#PbFw_STR_CHAR_DoubleQuote)
  Global AddQuotes.AddQuotes                 ; define Prototype-Handler for AddQuotes
  
  Prototype.s RemoveQuotes(String$, QuoteType=#PbFw_STR_xDoubleQuotes, xTrim=#True)
  Global RemoveQuotes.RemoveQuotes                 ; define Prototype-Handler for AddQuotes
  
  Declare RemoveCharFast(*String, Char.c)
  Declare.i RemoveChars(*String.String, Char1.c, Char2.c=0, xTrim=#False)

  Declare.s RemoveTabsAndDoubleSpace(String$)

  Prototype CreateWordIndex(String$, List WordIndex.TWordIndex(), cSeparator.c=' ', UnQuoteMode = 0, xTrim=#True)
  Global CreateWordIndex.CreateWordIndex 
  

  Declare.s FileToString(FileName.s, CharMode.i = #PB_Default, ReadUnsupportedModeAsASCII=#True)
  Declare.i FileToStringList(FileName.s, List StringList.s(), CharMode = #PB_Default, ReadUnsupportedModeAsASCII=#True)
  Declare.i FileToStringMap(FileName.s, Map StringMap.s(), CharMode = #PB_Default, ReadUnsupportedModeAsASCII=#True)
  
  Declare.s HexStringFromBuffer(*Buffer, Bytes)           ; creates a Hex-Value String from a Buffer/Memory  
  
  Prototype.i HexStringToBuffer(HexStr.s, *Buffer, Bytes=#PB_All)   ; converts a Hex-Value String back to a Byte-Buffer
  Global  HexStringToBuffer.HexStringToBuffer
  
  ; My2ByteString = BufferToString(*MyBuffer)
  Macro BufferAsciiToString(ptrBuffer)
  ; ============================================================================
  ; NAME: BufferAsciiToString
  ; DESC: Read an Ascii-string out of a ByteBuffer
  ; VAR(ptrBuffer): Pointer to the Ascii Buffer
  ; ============================================================================
    PeekS(ptrBuffer, #PB_Default, #PB_Ascii)  
  EndMacro
  
  Macro StringToAsciiBuffer(String, ptrBuffer)
  ; ============================================================================
  ; NAME: StringToAsciiBuffer
  ; DESC: Write a String into an Ascii Buffer
  ; VAR(String):  String to copy to Buffer
  ; VAR(ptrBuffer): Pointer to the Ascii Buffer
  ; ============================================================================
    PokeS(String, ptrBuffer, #PB_Ascii)  
  EndMacro
  
 EndDeclareModule

Module STR      ; Module STRING [STR::]
    
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
   
  Structure pChar   ; virtual CHAR-ARRAY, used as Pointer to overlay on strings 
    a.a[0]          ; fixed ARRAY Of CHAR Length 0
    c.c[0]          
  EndStructure
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  Macro LCaseChar(Char, ReturnChar)
    #DeltaChar= 'a' - 'A'  ;  a[97]-A[65]=32
    If char >='A' And char <='Z'
      ReturnChar = Char + #DeltaChar   ; add 32 to LCase Char
    Else
      ReturnChar = Char
    EndIf
  EndMacro

  Procedure.s _GetCharModeName(CharMode.i = #PB_Default)
    
    Protected RET.s
    If CharMode = #PB_Default
      ; #PbFw_STR_CharMode is [#PB_Unicode or #PB_Ascii]
      CharMode = #PbFw_STR_CharMode    
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
  
  Procedure _UnQoteWord(*String, *ret.TWordIndex, PosStart=0, PosEnd=0, UnQuoteMode=#PbFw_STR_xDoubleQuotes, xTrim=#True)
  ; ============================================================================
  ; NAME: _UnQoteWord
  ; DESC: Removes the Quotes from a String/Word by calculating the PositionIndex
  ; DESC: so we can use Mid$(TWordIndex\WordStart, TWordIndex\Length) to get
  ; DESC: the unquotet String out of the complete String. 
  ; VAR(*String): Pointer to the String
  ; VAR(**ret.TWordIndex): Return Value with the Position Data of the unquoted String
  ; VAR(PosStart): StartPosition 0-based [0..] is used as a kind of ArrayIndex 
  ; VAR(PosEnd): EndPosition 0-based [0..] were the Word ends
  ;              If EndPos = 0 the String will be searched until EndOfString
  ;              StartPos and EndPos <> is for pre indexed WordLists
  ; VAR(*ret.TWordIndex): the returned WordIndex
  ;                       \WordStart is the CharacterNo were the unquoted Word starts [1..]
  ;                       \Length  Lenghth of unquoted Word in Characters
  ; RET.s : String without Quotes
  ; ============================================================================
    
    Protected *char.pChar   ; Pointer to a virutal Char-Array
    Protected I, newStart, NewEnd
    Protected xQuoteLeftFound, xQuoteRightFound
    Protected xDoubleQuoteFound, xSingleQuoteFound
     
    *char = *String         ; overlay the String with a virtual Char-Array        
    If Not *char            ; If *Pointer to String is #Null, so Return a #Null$
      ProcedureReturn 0
    EndIf
    Debug "UnQuoteMode = " + Str(UnQuoteMode)
    I = PosStart
    newStart  = PosStart
    Debug "NewStart = " + Str(newStart)
     
    ; ----------------------------------------------------------------------
    ; Searching quotes at left side of String and skip Spaces if xTrim=#True
    ; ----------------------------------------------------------------------   
    While *char\c[I] And Not xQuoteLeftFound            
         
      ; Debug Str(I) + " : " + Str(*char\c[I] )
      Select *char\c[I]
        Case #PbFw_STR_CHAR_DoubleQuote
          ; Debug "DoubleQuote at : " + Str(I)
           
          If Not xQuoteLeftFound
            If UnQuoteMode & #PbFw_STR_xDoubleQuotes
              Debug "DoubleQuote Left at : " + Str(I)
              xQuoteLeftFound = #True
              xDoubleQuoteFound = #True
              newStart = I + 1
             EndIf
          EndIf
        
        Case #PbFw_STR_CHAR_SingleQuote
           
          If Not xQuoteLeftFound
            If UnQuoteMode & #PbFw_STR_xSingleQuotes
              Debug "SingleQuote Left at : " + Str(I)
              xQuoteLeftFound = #True
              xSingleQuoteFound =#True
              newStart = I + 1
            EndIf
          EndIf
          
        Case  #PbFw_STR_CHAR_SPACE
          ; Skip Spaces
          If xTrim 
            newStart = I + 1
          EndIf
          
        Default
          Break 
      EndSelect
      I+1  
    Wend
    
    Debug "NewStart = " + Str(newStart)
    Debug xQuoteLeftFound
    Debug xSingleQuoteFound
    Debug xDoubleQuoteFound
    
    ; ----------------------------------------------------------------------
    ; if PosEnd = 0, we must search for EndOfString and Set PosEnd to LastChar
    ; ----------------------------------------------------------------------
    ;Debug "PosEndOfString = " + Str(PosEnd) + " I= " + Str(I)
    If PosEnd = 0 
      PosEnd = I-1
      While *char\c[I]    ; Up to EndOfString
        ;Debug *char\c[I]
        PosEnd = I
        I + 1
      Wend
    EndIf
    Debug "PosEndOfString = " + Str(PosEnd)
    
    ; ----------------------------------------------------------------------
    ; Searching quotes from right side of String and skip Spaces if Trim=#True
    ; ----------------------------------------------------------------------    
    newEnd = PosEnd
    
    If xQuoteLeftFound   ; if Left Quote was found, search for right Quote
      I = PosEnd         ; Start at PosEnd on right side
      
      While *char\c[I]  And (Not xQuoteRightFound) ; And (I > newStart)          ; until end of String
        Debug Str(I) + " : " + Str(*char\c[I] )
        
        Select *char\c[I] 
            
          Case #PbFw_STR_CHAR_DoubleQuote
            If xDoubleQuoteFound And (Not xQuoteRightFound)
              Debug "DoubleQuote Right at : " + Str(I)
              xQuoteRightFound = #True 
              newEnd= I-1
            EndIf
            
          Case #PbFw_STR_CHAR_SingleQuote
            If xSingleQuoteFound And (Not xQuoteRightFound)
              Debug "SingleQuote Right at : " + Str(I)
              xQuoteRightFound = #True  
              newEnd= I-1
            EndIf
           
          Case  #PbFw_STR_CHAR_SPACE
            If xTrim 
              newEnd= I-1
            EndIf
          
          Default
            Break   
          
        EndSelect
        I - 1
      Wend
    EndIf      ; no left Quote was found, 
        
    ; Calulate the ReturnVar WordIndex
    ; With the WordIndex we can Use Mid(String$, WordIndex\WordStart, WordIndex\Length)
    ; to read out the Word from the String
    With *ret
      Debug "_UnQuoteWord : Start / End :" + Str(newStart) + " / " + Str(NewEnd) 
      \WordStart = newStart + 1  ; No of first Character of Word in the String [1..]
      \Length = (NewEnd - newStart) + 1
    EndWith
    
    ProcedureReturn *ret\Length   
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions as Protytypes
  ;- ---------------------------------------------------------------------- 
  
  Procedure.i _ReplaceChar(*String, cSearch.c, cReplace.c)
  ; ============================================================================
  ; NAME: _ReplaceChar
  ; DESC: !PointerVersion! use it as ProtoType ReplaceChar()
  ; DESC: Replace a Character in a String with an other Character
  ; DESC: To replace all ',' with a '.' use : ReplaceChar(@MyString, ',', '.')
  ; DESC: This a replacement for ReplaceString() only for a single Char
  ; DESC: and with direct *String Access. This is 2-3 tiems faster than
  ; DESC: ReplaceString().
  ; DESC: To UCase a single char use ReplaceChar(MyString, 'e', 'E')
  ; DESC: RepleaceChar is 5-times faster than ReplaceString with Mode 
  ; DESC: #PB_String_InPlace 
  ; VAR(String$) : The String
  ; VAR(cSearch) : Character to search for and replace
  ; VAR(cReplace): the Replace Charcter (new Character)
  ; VAR(*RetVal_NoOfChars.Integer): Place here a Pointer to a PB Integer-Struct
  ;                               to get back the NoOfCharsFound/Replaced
  ; RET.s : The new String
  ; ============================================================================
    Protected *char.Character   ; Pointer to a virutal Char-Struct
    Protected N
    
    *char = *String         
    If *char    
      While *char\c               ; until end of String
        If *char\c =  cSearch
          *char\c = cReplace    ; replace the Char
          N + 1
        EndIf
        *char + #PbFw_STR_CharSize   ; Index to next Char
      Wend
    EndIf
    ProcedureReturn N
  EndProcedure
  ReplaceChar = @_ReplaceChar()     ; Bind ProcedureAdress to the PrototypeHandler

  ; for Strings we can use the PB CountString()
  Procedure.i _CountChar(*String, cSearch.c)
  ; ============================================================================
  ; NAME: _CountChar
  ; DESC: !PointerVersion! use it as ProtoType CountChar()
  ; DESC: Counts the number of found Characters of cSearch Character
  ; VAR(String$) : The String
  ; VAR(cSearch) : Character to count
  ; RET.i : Number of Characters found
  ; ============================================================================
    
    Protected *char.Character    ; Pointer to a virutal Char-Array
    Protected N
    
    *char = *String               ; overlay the String with a virtual Char-Array
    If *char        
      While *char\c               ; until end of String
        If *char\c =  cSearch 
          N + 1                   ; count the Char
        EndIf
        *char + #PbFw_STR_CharSize     ; Index to next Char
      Wend
    EndIf
    ProcedureReturn N  ; return the number of Chars found
  EndProcedure
  CountChar = @_CountChar()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.i _CountWords(*String, cSeparator.c=' ', IngnoreSpaces=#True)
  ; ============================================================================
  ; NAME: _CountWords
  ; DESC: !PointerVersion! use it as ProtoType CountWords()
  ; DESC: Count the number of Words in a String separated by cSepartor
  ; VAR(*String) : Pointer to the String
  ; VARcSeparator.c(): Character which seperatates the Words
  ; VAR(IngnoreSpaces): #True: Spaces are ignored (skiped), this is irrelevant
  ;                     if the Sperator is a SPACE. 
  ;                     #FLASE SPACE can be the first Char of a Word
  ;                     "Text,  , otherText"; cSperator=','; IgnoreSpace=#True
  ;                     => NoOfWords=2; With IgnoreSpace=#False NoOfWords=3
  ;                     The Spaces between ", ," is count as a Word
  ; RET.i : Number of Words found
  ; ============================================================================
    
    Protected *char.Character     ; Pointer to a virutal Char-Array
    Protected  N
    Protected  xWordStart
   
    *char = *String          ; overlay the String with a virtual Char-Array        
    If Not *char             ; If *Pointer to String is #Null
      ProcedureReturn 0
    EndIf
    
    While *char\c         ; until end of String
      Select *char\c
          
        Case cSeparator         
          If xWordStart
            N + 1     ; count the Word
            xWordStart = #False  
          EndIf
          
        Case #PbFw_STR_CHAR_SPACE    ; if the Separator is not ' ' we must handle Spaces seperatly
          ; Attention this CASE will only be processed if the Seperator it'n not a SPACE
          If Not IngnoreSpaces
             xWordStart = #True  ; if we do not ignore Spaces it is a WordStart
             ; Debug "Ignored Space"  
          EndIf
          
        Default 
          xWordStart = #True
      EndSelect      
       *char + #PbFw_STR_CharSize              ; Index to next Char
    Wend
    
    ; If a Word was started And we reached the End of String, we have To count this last Word
    If xWordStart 
      N + 1
    EndIf   
    ProcedureReturn N   
  EndProcedure
  CountWords = @_CountWords()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.s _AddQuotes(*String, cQuote.c=#PbFw_STR_CHAR_DoubleQuote)  ; 
  ; ============================================================================
  ; NAME: _AddQuotes
  ; DESC: !PointerVersion! use it as ProtoType AddQuotes()
  ; DESC: Add Quotes to a String on left and right side
  ; VAR(String$): The String
  ; VAR(QuoteType): #PbFw_STR_xDoubleQuotes, #PbFw_STR_xSingleQuotes
  ; RET.s : String without Quotes
  ; ============================================================================
    ; ASCII-34 = ", ASCII-39 = '
    ProcedureReturn Chr(cQuote) + PeekS(*String) + Chr(cQuote)
  EndProcedure
  AddQuotes = @_AddQuotes()     ; Bind ProcedureAdress to the PrototypeHandler
      
  Procedure.s _RemoveQuotes(*String, UnQuoteMode=#PbFw_STR_xDoubleQuotes, xTrim=#True)
  ; ============================================================================
  ; NAME: RemoveQuotes
  ; DESC: !PointerVersion! use it as ProtoType RemoveQuotes()
  ; DESC: Remove Quotes from a String on left and right side
  ; VAR(String$): The String
  ; VAR(UnQuoteMode): #PbFw_STR_xDoubleQuotes, #PbFw_STR_xSingleQuotes or cmbination of both
  ; VAR(xTrim): #True: Remove SPACEs inside the Quotes / #FalseÖ keep SPACEs
  ;             Spaces outside the Quotes are removed always
  ; RET.s : String without Quotes
  ; ============================================================================
   
    Protected TWordIndex.TWordIndex
    Protected lchr = SizeOf(Character)
    Protected ret, *pWord
    
    ; _UnQoteWord returns the Position-Data of the unquoted String AS TWordIndex
    ret = _UnQoteWord(*String, TWordIndex, 0, 0, UnQuoteMode, xTrim)
    ; ret = Length of unquoted String in Characters
    
    If ret 
      With TWordIndex
        ; Debug Str(\WordStart) + " : " + Str(\Length)
   
        ; because WordStart is the NumberOfFirstChar [1..] we have to 
        ; subtract 1 to get a 0-based Pointer for PeekS()
        *pWord = *String + (\WordStart-1) * #PbFw_STR_CharSize
        
        ProcedureReturn PeekS(*pWord, \Length)
        
        ; alternative we can use Mid$, but maybe with Mid$, the complete String is copied to STACK
        ; what makes it ineffective for very long Strings. Maybe ask this issue at PB-Forum!
        ; Result MidString do not copy the String to STACK it use direkt Pointer, but we can't see
        ; this! It's similar issue like the ProtoTypes which use directly the Pointer
        ; ProcedureReturn Mid(String$, \WordStart, \Length)
      EndWith
    Else
      ProcedureReturn PeekS(*String)
    EndIf
  EndProcedure
  RemoveQuotes = @_RemoveQuotes()     ; Bind ProcedureAdress to the PrototypeHandler
    
  Procedure.i RemoveCharFast(*String, Char.c)
  ; ============================================================================
  ; NAME: RemoveChars
  ; NAME: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Removes a Character from the String
  ; DESC: The String will be shorter after
  ; VAR(*String) : Pointer to String
  ; VAR(Char.c) : The Character to remove
  ; RET: - 
  ; ============================================================================
    
   Protected *pWrite.Character = *String
   Protected *pRead.Character = *String
  	    
    If (Not *String) Or (Not Char)
      ProcedureReturn
    EndIf
    
 	  While *pRead\c     ; While Not NullChar    
   	  If  *pRead\c <> Char  	      
   	    If *pWrite <> *pRead     ; if  WritePosition <> ReadPosition
          *pWrite\c = *pRead\c   ; Copy the Character from ReadPosition to WritePosition => compacting the String
        EndIf
        *pWrite + SizeOf(Character) ; set new Write-Position          
      EndIf           
      *pRead + SizeOf(Character) ; Set Pointer to NextChar
    Wend
  	
  	; If *pWrite is not at end of orignal *pRead,
  	; we removed some char and must write a 0-Termination as new EndOfString 
  	If *pRead <> *pWrite
  		*pWrite\c = 0
  	EndIf
  	
  	ProcedureReturn (*pRead - *pWrite)/SizeOf(Character) ; Number of characters removed
  EndProcedure
  
  Procedure RemoveNonWordChars(*String.Character)
    ; ============================================================================
    ; NAME: RemoveNonWordChars
    ; NAME: Attention! This is a Pointer-Version! Be sure to call it with a
    ; DESC: correct String-Pointer
    ; DESC: Removes a NonWord Characters from the String
    ; DESC: The String will be shorter after
    ; DESC: (question at PB-Forum: https://www.purebasic.fr/english/viewtopic.php?t=82139)
    ; VAR(*String) : Pointer to String
    ; RET: - 
    ; ============================================================================
    
    Protected *pWrite.Character = *String
  	
    Macro RemoveNonWordChars_KeepChar()
    	If *pWrite <> *String     ; if  WritePosition <> ReadPosition
    		*pWrite\c = *String\c   ; Copy the Character from ReadPosition to WritePosition => compacting the String
    	EndIf
    	*pWrite + SizeOf(Character) ; set new Write-Position 
    EndMacro
    
    If Not *String
      ProcedureReturn
    EndIf
    
  	While *String\c     ; While Not NullChar
  	  
  	  Select *String\c
  	      
        ; ----------------------------------------------------------------------
        ; Characters to keep
        ; ----------------------------------------------------------------------             
  	      
        ; If we check for the most probably Chars first, we speed up the operation
        ; because we minimze the number of checks to do!
        Case 'a' To 'z'   ; keep  a to z
          RemoveNonWordChars_KeepChar()		; local Macro _KeppChar()
          
        Case 'A' To 'Z'   ; keep  A to Z
          RemoveNonWordChars_KeepChar()				
                 
   	    Case '0' To '9'   ; keep 0 to 9
          RemoveNonWordChars_KeepChar()				
          
        Case '_'          ; keep '_'
          RemoveNonWordChars_KeepChar()				
                        
      EndSelect
      
      *String + SizeOf(Character) ; Set Pointer to NextChar
  		
    Wend
  	
  	; If *pWrite is not at end of orignal *String,
  	; we removed some char and must write a 0-Termination as new EndOfString 
  	If *String <> *pWrite
  		*pWrite\c = 0
  	EndIf
  
  EndProcedure

  Procedure.s RemoveTabsAndDoubleSpace(String$)
  ; ============================================================================
  ; NAME: RemoveTabsAndDoubleSpace
  ; DESC: Removes TABS and double SPACE from a String
  ; DESC: Left and Right Space are removed to. We do not need a separate Trim() 
  ; VAR(String$) : The String
  ; RET.s: The trimmed String
  ; ============================================================================
    Protected I, *pC.pChar
    Protected cnt, lastSpace
    
    #cst_repChar = 1
    
    *pC = @String$    ; Set the CharPointer = StartOfString
    
    While *pC\c[I] = #PbFw_STR_CHAR_SPACE
      *pC\c[I] = #cst_repChar    ; mark leading spaces to remove
      I+1
    Wend
    
    ;While *pC\c[I]      ; While Not EndOfString
    Repeat
      Select *pC\c[I]   ; Switch for the CharType
                    
        Case #PbFw_STR_CHAR_TAB   ; TAB         
          If cnt > 0                  ; If there was a Space befor
            *pC\c[I] = #cst_repChar   ; mark it to remove
          Else                        ; No Space befor
            *pC\c[I] = #PbFw_STR_CHAR_SPACE     ; TAB => SPACE
            lastSpace = I             ; save position of last Space
            cnt + 1                   ; Cnt the Space
          EndIf          
          
        Case #PbFw_STR_CHAR_SPACE  ; SPACE         
          If cnt > 0 
            *pC\c[I] = #cst_repChar 
          Else
            lastSpace = I     ; save Position of last Space            
            cnt + 1
          EndIf
          
        Case 0
          Break
         
        Default     ; Any other Character
          cnt = 0   ; SpaceCount = 0
          
      EndSelect  
      I + 1 
    ;Wend
    ForEver
    If cnt  ; if there is a open Space at the End, mark it to remove
      *pC\c[lastSpace] = #cst_repChar
    EndIf
    
    ProcedureReturn ReplaceString(String$, Chr(#cst_repChar), "")  ; now remove the marked Characters
    
    ; _RemoveChars is same speed as ReplaceString() - so there is no advantage
    ;_RemoveChars(@String$, #cst_repChar)
    ;ProcedureReturn String$
  EndProcedure
  ; 2016
 
  Procedure _CreateWordIndex(*String, List WordIndex.TWordIndex(), cSeparator.c=' ', UnQuoteMode = 0, xTrim=#True)
  ; ============================================================================
  ; NAME: _CreateWordIndex
  ; DESC: !PointerVersion! use it as ProtoType CreateWordIndex()
  ; VAR(*String) : Pointer to the String from which a WordIndex will be created
  ; VAR(List WordIndex.TWordIndex()): Your List() which should hold the WordIndex  
  ; VAR(cSeparator.c) : Character which seperatres the Words
  ;                     Double characters are igored
  ; VAR(UnQuoteMode): #PbFw_STR_xDoubleQuotes, #PbFw_STR_xSingleQuotes or cmbination of both
  ; VAR(xTrim): #True: Remove SPACEs inside the Quotes / #FalseÖ keep SPACEs
  ;             Spaces outside the Quotes are removed always
  ; RET.i : Number of Words found; ListSize(WordIndex())
  ; ============================================================================
     
    Protected *char.pChar   ; Pointer to a virutal Char-Array
    Protected I, N
    Protected xWordStart, PosStart, PosEnd
    Protected idx.TWordIndex
    
    *char = *String         ; overlay the String with a virtual Char-Array
        
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0
    EndIf
    
    While *char\c[I]         ; until end of String
      Select *char\c[I]
          
        Case cSeparator         
          If xWordStart
            N + 1     ; count the Word
            xWordStart = #False  
            PosEnd = I-1
         EndIf
          
        Case #PbFw_STR_CHAR_SPACE    ; if the Separator is not ' ' we must handle Spaces seperatly
          ; Attention this CASE will only be processed if the Seperator it'n not a SPACE
          If Not xTrim
            xWordStart = #True  ; if we do not ignore Spaces it is a WordStart
            PosStart = I
          EndIf
          
        Default 
          xWordStart = #True
      EndSelect
      
      If PosEnd
        
        If UnQuoteMode
          
        Else
          
        EndIf
        
        PosEnd=0
        PosStart=0
      EndIf      
      I + 1                     ; Index to next Char
    Wend
    ProcedureReturn ListSize(WordIndex())
  EndProcedure
  CreateWordIndex = @_CreateWordIndex()     ; Bind ProcedureAdress to the PrototypeHandler
  

  Procedure _SplitStringToList(String$, List Result.s(), cSeparator.c=' ', UnQuoteMode = 0, IgnoreSpaces=#True)
    Protected *char.pChar   ; Pointer to a virutal Char-Array
    Protected I, N
    Protected xWordStart, xAddElement
    Protected PosStart, PosEnd, StringStart, StringLenth
    Protected Word$
      
    *char = @String$         ; overlay the String with a virtual Char-Array
        
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0
    EndIf
        
    While *char\c[I]        ; until end of String
      
      Select *char\c[I]
        Case cSeparator         
          If xWordStart
            N + 1           ; count the Word
            xWordStart = #False 
            PosEnd = I-1
          EndIf
          
        Case #PbFw_STR_CHAR_SPACE     ; if the Separator is not ' ' we must handle Spaces seperatly
          ; Attention this CASE will only be processed if the Seperator it'n not a SPACE
          If Not IgnoreSpaces
            xWordStart = #True   ; if we do not ignore Spaces it is a WordStart
            PosStart = I
          EndIf
                      
        Default 
          xWordStart = #True
          PosStart = I
      EndSelect
      
      If PosEnd
        StringStart = PosStart+1  ; +1 because Array Starts at [0] and Mid needs CharacterPosition [1...] 
        StringLenth = PosEnd-PosStart + 1
        
        If StringLenth
          If UnQuoteMode
            Word$ = STR::RemoveQuotes(Mid(String$, StringStart, StringLenth), UnQuoteMode, IgnoreSpaces)
           Else
            Word$ = Mid(String$, StringStart, StringLenth)
          EndIf
          AddElement(Result()) 
          Result()=Word$
        EndIf
        
        PosEnd=0
        PosStart=0
      EndIf      
      I + 1                     ; Index to next Char
    Wend
    
    ProcedureReturn ListSize(Result())
  EndProcedure 
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ---------------------------------------------------------------------- 
 
  Procedure SplitStringList(String$, Separator$, List Result.s(), DQuote = #False)
    Protected *String.character, *Separator.character
    Protected *Start, *End, exit, lock, do, dq, len
    
    ClearList(Result())
    *String = @String$
    *Separator = @Separator$
    *Start = *String
    *End = *String
    
    If DQuote
      Repeat
        If *String\c = 0
          exit = #True
          do = #True
          If Not dq
            *End = *String
          EndIf
        Else
          If *String\c = #PbFw_STR_CHAR_DoubleQuote
            If Not lock
              lock = #True
              dq = #True
              *Start = *String + SizeOf(character)
            Else
              lock = #False
              *End = *String
            EndIf
          EndIf
          If *String\c = *Separator\c And Not lock
            do = #True
            If Not dq
              *End = *String
            EndIf
          EndIf
        EndIf
        
        If do
          AddElement(Result()) 
          len = (*End - *Start) / SizeOf(character)
          If Len > 0
            Result() = PeekS(*Start, len) 
          EndIf
          *Start = *String + SizeOf(character)
          do = #False
          dq = #False
        EndIf
        *String + SizeOf(character)
      Until exit
      
    Else  
      Repeat
        If *String\c = 0
          exit = #True
          do = #True
          *End = *String
        Else
          If *String\c = *Separator\c
            do = #True
            *End = *String
          EndIf
        EndIf
        If do
          AddElement(Result()) 
          len = (*End - *Start) / SizeOf(character)
          If Len > 0
            Result() = PeekS(*Start, len) 
          EndIf
          *Start = *String + SizeOf(character)
          do = #False
        EndIf
        *String + SizeOf(character)
      Until exit
    EndIf
    ProcedureReturn ListSize(Result())
  EndProcedure

 Procedure.s FileToString(FileName.s, CharMode.i=#PB_Default, ReadUnsupportedModeAsASCII=#True)
  ; ============================================================================
  ; NAME: FileToString
  ; DESC: Reads a (Text)-File into a String variable
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(CharMode.i) : Character Mode [#PB_Ascii, #PB_Unicode, #PB_UTF8]
  ; VAR( ReadUnsupportedModeAsASCII): #True: if CharMode is unsuported use #PB_Ascii
  ; RET.s : The String
  ; ============================================================================
   
    Protected Text.s    
    Protected FileNo.i  ; File number

    FileNo= ReadFile(#PB_Any, FileName) ; OpenFile for read
    
    If FileNo
            
      Select CharMode
          
        Case #PB_Ascii, #PB_Unicode, #PB_UTF8   ; PB supported Character Modes
          ; OK
          
        Case #PB_Default  ; if CharMode is #PB_Default (-1), try to Read the correct format from File         
          CharMode =_ReadFileBOM(FileNo, ReadUnsupportedModeAsASCII)
           
        Default                                       ; every other value is unsupported
          If ReadUnsupportedModeAsASCII
             CharMode = #PB_Ascii
          Else
            CharMode = #Null
          EndIf
          
      EndSelect
            
      If CharMode
        Text = ReadString(FileNo, CharMode | #PB_File_IgnoreEOL)
      Else
        Text = #Null$
      EndIf
      
      CloseFile(FileNo)
    EndIf
    
    ProcedureReturn Text
  EndProcedure
  
  Procedure.i FileToStringList(FileName.s, List StringList.s(), CharMode = #PB_Default, ReadUnsupportedModeAsASCII=#True)
  ; ============================================================================
  ; NAME: FileToStringList
  ; DESC: Reads a (Text)-File Line by Line into a StringList()
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(List StringList.s()): String-List() which receives the data 
  ; VAR(CharMode.i) : Character Mode [#PB_Ascii, #PB_Unicode, #PB_UTF8]
  ; VAR( ReadUnsupportedModeAsASCII): #True: if CharMode is unsuported use #PB_Ascii
  ; RET.i : Returns the number of Lines
  ; ============================================================================
    
    Protected FileNo
    Protected sLine.s
    
    ClearList(StringList())               ; clears all elements from List()

    FileNo = ReadFile(#PB_Any, FileName)  ; open File for read
    
    If FileNo      
      
      Select CharMode
          
        Case #PB_Ascii, #PB_Unicode, #PB_UTF8   ; PB supported Character Modes
          ; OK
          
        Case #PB_Default  ; if CharMode is #PB_Default (-1), try to Read the correct format from File         
          CharMode =_ReadFileBOM(FileNo, ReadUnsupportedModeAsASCII)
           
        Default                                       ; every other value is unsupported
          If ReadUnsupportedModeAsASCII
             CharMode = #PB_Ascii
          Else
            CharMode = #Null
          EndIf
          
      EndSelect
      
      While (Not Eof(FileNo))
        sLine = Trim(ReadString(FileNo,CharMode))     ; removes Spaces left and right
        
        If sLine      ; in PureBasic this works like: if sLine <> #Null$
          AddElement(StringList())
          StringList() = sLine
        EndIf
      Wend
      
      CloseFile(FileNo)
    EndIf
  
    ProcedureReturn (ListSize(StringList()))  ; returns the number of Lines
  EndProcedure

  Procedure.i FileToStringMap(FileName.s, Map StringMap.s(), CharMode = #PB_Default, ReadUnsupportedModeAsASCII=#True)
  ; ============================================================================
  ; NAME: FileToStringMap
  ; DESC: Reads a Text-File Line by Line into a StringMAP()
  ; DESC: Use This function to read TextFiles which contains a strored MAP
  ; DESC: with the following Text-Format
  ; DESC: [KeyValue]=[Text];  0815=This is the Text for Key 0815
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(LMap StringMap.s(): String-MAP() which receives the data 
  ; VAR(CharMode.i) : Character Mode [#PB_Ascii, #PB_Unicode, #PB_UTF8]
  ; VAR( ReadUnsupportedModeAsASCII): #True: if CharMode is unsuported use #PB_Ascii
  ; RET.i : Returns the number of Lines
  ; ============================================================================
    
    Protected FileNo, I
    Protected sLine.s
    
    ClearMap(StringMap()) ; clears all elements from MAP()
    
    FileNo = ReadFile(#PB_Any, FileName) ; open File for read
    
    If FileNo
      
      Select CharMode
          
        Case #PB_Ascii, #PB_Unicode, #PB_UTF8   ; PB supported Character Modes
          ; OK
          
        Case #PB_Default  ; if CharMode is #PB_Default (-1), try to Read the correct format from File         
          CharMode =_ReadFileBOM(FileNo, ReadUnsupportedModeAsASCII)
           
        Default                                       ; every other value is unsupported
          If ReadUnsupportedModeAsASCII
             CharMode = #PB_Ascii
          Else
            CharMode = #Null
          EndIf
          
      EndSelect
            
      While (Not Eof(FileNo))
        sLine = Trim(ReadString(FileNo, CharMode))
        
        If sLine
          ; Textformat: [KEY] = [TEXT]
          I = FindString(sLine, "=")
          If I
            AddMapElement(StringMap(), Left(sLine, I-1))
            StringMap() = Mid(sLine, I+1)
          EndIf
        EndIf
        
      Wend
      CloseFile(FileNo)
    EndIf
    
    ProcedureReturn (MapSize(StringMap())) ; returns the number of Lines
  EndProcedure
    
  Procedure.s HexStringFromBuffer(*Buffer, Bytes)    
  ; ============================================================================
  ; NAME: HexStringFromBuffer
  ; DESC: Converts a Buffer to a Hex-String
  ; DESC: Convert each Byte to a 2-char-Hex-String
  ; VAR(*Buffer) : Pointer to the Buffer
  ; VAR(Bytes) : Number of Bytes to convert    
  ; RET.s: The String with the Bytes Hex-Values
  ; ============================================================================
   Protected I, *src.pChar, *dest.pChar
   Protected hiNibble.a, loNibble.a 
   Protected sRet.s
      
   If *Buffer
      sRet.s = Space(Bytes * #PbFw_STR_CharSize)
      *dest = @sRet
      *src = *Buffer  
       
      For I=0 To (Bytes-1)
        hiNibble =  (*src\a[I] >> 4)  + '0'  ; Add Ascii-Code of '0'
        If hiNibble > '9' : hiNibble  + 7 : EndIf ; If 'A..F', we must add 7 for the correct Ascii-Code
        
        loNibble =  (*src\a[I] & $0F) + '0'
        If loNibble > '9' : loNibble  + 7 : EndIf
        
        *dest\c[I * #PbFw_STR_CharSize]   = hiNibble         
        *dest\c[I * #PbFw_STR_CharSize +1]= loNibble
      Next
    
      ProcedureReturn sRet
    EndIf  
    ProcedureReturn #Null$
  EndProcedure
  
  Procedure.i _HexStringToBuffer(HexStr.s, *Buffer, Bytes=#PB_All)    
  ; ============================================================================
  ; NAME: HexStringToBuffer
  ; DESC: !PointerVersion! use it as ProtoType ReplaceChar()
  ; DESC: Converts a Hex-String
  ; DESC: Convert each 2Char HEX into a Byte
  ; DESC: The String with the Hex-Value Stream, 2 Chars per Byte {00..FF}
  ; VAR(*Buffer) : Pointer to the Buffer
  ; VAR(Bytes) : Number of Bytes to convert    
  ; RET.i: Number of Bytes copied
  ; ============================================================================    
    Protected I, *src.pChar, *dest.pChar 
    Protected hiNibble.a, loNibble.a 
        
    If *Buffer        
      *src = @HexStr
      *dest = *Buffer
      
      If Bytes =#PB_All : Bytes = 2147483647 : EndIf
      Debug "Bytes : " + Bytes
      
      While Bytes 
        hiNibble = (*src\c[I * #PbFw_STR_CharSize]) ; read HexChar from String
         
        If hiNibble           
          If hiNibble >'F'
            Debug "HexStringToBuffer: " + Chr(hiNibble) + " is not a valid HEX-Digit!"
            hiNibble = (hiNibble -'0' - 7) & $0F                     
          ElseIf hiNibble > '9' 
            hiNibble - '0' - 7            
          Else 
            hiNibble - '0'                         
          EndIf           
        Else      ; EndOfString
          Break   ; leave While          
        EndIf
        
        loNibble = (*src\c[I * #PbFw_STR_CharSize +1]) 
        ;Debug "hi : " + hiNibble + " / lo : " + Chr(loNibble)
        If loNibble          
          If loNibble >'F'
            Debug "HexStringToBuffer: " + Chr(loNibble) + " is not a valid HEX-Digit!"
            loNibble = (loNibble -'0' - 7) & $0F                    
          ElseIf loNibble > '9' 
            loNibble - '0' - 7           
          Else 
            loNibble - '0'                         
          EndIf 
        Else     ; EndOfString
          Break  ; leave While
        EndIf
        
        *dest\a[I] = (hiNibble << 4) | loNibble         
        I + 1       ; Increment Position Counter
        Bytes -1    ; Decrement number of Bytes left
      Wend
    EndIf  
    ProcedureReturn I
  EndProcedure
  HexStringToBuffer = @_HexStringToBuffer()     ; Bind ProcedureAdress to the PrototypeHandler
  
 
EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule STR
  
  #AllQuotes = #PbFw_STR_xDoubleQuotes | #PbFw_STR_xSingleQuotes
  Define s.s, ret.s
  Define I
  Define T1, T2, T3
  
  s = "   I am 'a'  String  1  2    3 "
;   Debug "The String : " + s
;   Debug ""
;   Debug "Without Trim"
;   ret = AddQuotes(s,#PbFw_STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + ret
;   ret = RemoveQuotes(ret, #AllQuotes, #False)  
;   Debug "Remove double Quotes : " + ret
  
  #cst_LOOPs = 1000000
  
  T1 = ElapsedMilliseconds()
  For I = 1 To #cst_LOOPs
    ;ret = ReplaceString(s," ", ".", #PB_String_InPlace)
    ret = RemoveTabsAndDoubleSpace(s)
  Next
  T1 = ElapsedMilliseconds() - T1
  
  T2 = ElapsedMilliseconds()
  For I = 1 To #cst_LOOPs Step 2
    ReplaceChar(s, 32, '.')
    ReplaceChar(s, '.', 32)
   RemoveCharFast(@s, 32)
  Next
  T2 = ElapsedMilliseconds() - T2
  
  Debug ret
  Debug s
  
 
  MessageRequester("Times", "RelaceString = " + T1 + #CRLF$ + "ReplaceChar = " + T2)
  
  ;   Debug "Add single Quotes : " + ret
;   ret = RemoveQuotes(ret, #AllQuotes, #False)  
;   Debug "Remove all Quotes : " + ret
;   Debug ""
;   ret = AddQuotes(s,#PbFw_STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + ret
;   ret = RemoveQuotes(ret,#AllQuotes, #False)
;   Debug "Remove all Quotes : " + ret
;   Debug ""
;   Debug "With Trim"
;     ret = AddQuotes(s,#PbFw_STR_xSingleQuotes)
;   Debug "Add single Quotes : " + ret
;   ret = RemoveQuotes(ret, #AllQuotes)  
;   Debug "Remove all Quotes : " + ret
;   Debug ""
;   ret = AddQuotes(s,#PbFw_STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + ret
;   ret = RemoveQuotes(ret,#AllQuotes)
;   Debug "Remove all Quotes : " + ret
;   Debug ""
;   ret = AddQuotes(s,#PbFw_STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + ret
;   Debug "Try what happens without QuoteType"
;   ret = RemoveQuotes(ret,0)
;   Debug "Without QuoteType : " + ret
;   
;   Debug " ==========  Count Words =============="
;   s = "I,   ,am, a, String"
;   Debug " Space as Separator"
;   Debug s + " : Words =" + Str(CountWords(s,' '))
;   Debug ""
;   Debug "Komma as Separator; IgnoreSpaces=#True"
;   Debug s + " : Words = " + Str(CountWords(s,','))
;   Debug "Komma As Separator; IgnoreSpaces=#False"
;   Debug s + " : Words = " + Str(CountWords(s,',',#False))
  
;   https://www.purebasic.fr/german/viewtopic.php?t=25244&hilit=MidString&start=40
;   Macro ErsetzeString2(string, pos, laenge, ersatz)
;     PeekS(@string, pos - 1) + ersatz + PeekS(@string + SizeOf(Character) * (pos + laenge - 1))
;   EndMacro

CompilerEndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 22
; Folding = -----
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)