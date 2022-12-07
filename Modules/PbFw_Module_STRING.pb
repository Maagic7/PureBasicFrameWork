; ===========================================================================
;  FILE : Module_STRING.pb
;  NAME : Module String [STR::]
;  DESC : Provides extended String Functions 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/08
; VERSION  :  0.1
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog: 
;{
;}
; ===========================================================================

;{ ====================      M I T   L I C E N S E        ====================
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile ""

DeclareModule STR
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  ; PB-Compiler use only #PB_Compiler_Unicode to specify Unicode or ASCII Mode
  ; PB 5.5 and higher use Unicode as Standard Mode
  ; older Versions use ASCII-Mode as standard for the EXE
  CompilerIf #PB_Compiler_Unicode
    #STR_CharMode = #PB_Unicode       ; Application CharacterMode = Unicode
    #STR_CharModeName = "Unicode"     ; Application CharacterModeName
  CompilerElse
    #STR_CharMode = #PB_Ascii         ; Application CharacterMode = ASCII 
    #STR_CharModeName = "ASCII"       ; Application CharacterModeName
  CompilerEndIf
  #STR_CharSize = SizeOf(Character)   ; Application CharacterSize = 2 Bytes
   
  EnumerationBinary
    #STR_xDoubleQuotes      
    #STR_xSingleQuotes
  EndEnumeration
  
  #STR_CHAR_SPACE       = 32    ; ' '
  #STR_CHAR_DoubleQuote = 34    ; "
  #STR_CHAR_SingleQuote = 39    ; '
  
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
  
  Prototype.s AddQuotes(String$, cQuote.c=#STR_CHAR_DoubleQuote)
  Global AddQuotes.AddQuotes                 ; define Prototype-Handler for CountWords
  
  Prototype.s RemoveQuotes(String$, QuoteType=#STR_xDoubleQuotes, xTrim=#True)
  Global RemoveQuotes.RemoveQuotes                 ; define Prototype-Handler for CountWords
  
  Prototype CreateWordIndex(String$, List WordIndex.TWordIndex(), cSeparator.c=' ', UnQuoteMode = 0, xTrim=#True)
  Global CreateWordIndex.CreateWordIndex 
  
  Declare.s FileToString(FileName.s, CharMode.i = #PB_Default, ReadUnsupportedModeAsASCII=#True)
  Declare.i FileToStringList(FileName.s, List StringList.s(), CharMode = #PB_Default, ReadUnsupportedModeAsASCII=#True)
  Declare.i FileToStringMap(FileName.s, Map StringMap.s(), CharMode = #PB_Default, ReadUnsupportedModeAsASCII=#True)
    
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
   
  Structure pChar   ; virtual CHAR-ARRAY, used as Pointer to overlay on strings 
    c.c[0]          ; fixed ARRAY Of CHAR Length 0
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
      ; #STR_CharMode is [#PB_Unicode or #PB_Ascii]
      CharMode = #STR_CharMode    
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
  
  Procedure _UnQoteWord(*String, *ret.TWordIndex, PosStart=0, PosEnd=0, UnQuoteMode=#STR_xDoubleQuotes, xTrim=#True)
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
        Case #STR_CHAR_DoubleQuote
          ; Debug "DoubleQuote at : " + Str(I)
           
          If Not xQuoteLeftFound
            If UnQuoteMode & #STR_xDoubleQuotes
              Debug "DoubleQuote Left at : " + Str(I)
              xQuoteLeftFound = #True
              xDoubleQuoteFound = #True
              newStart = I + 1
             EndIf
          EndIf
        
        Case #STR_CHAR_SingleQuote
           
          If Not xQuoteLeftFound
            If UnQuoteMode & #STR_xSingleQuotes
              Debug "SingleQuote Left at : " + Str(I)
              xQuoteLeftFound = #True
              xSingleQuoteFound =#True
              newStart = I + 1
            EndIf
          EndIf
          
        Case  #STR_CHAR_SPACE
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
            
          Case #STR_CHAR_DoubleQuote
            If xDoubleQuoteFound And (Not xQuoteRightFound)
              Debug "DoubleQuote Right at : " + Str(I)
              xQuoteRightFound = #True 
              newEnd= I-1
            EndIf
            
          Case #STR_CHAR_SingleQuote
            If xSingleQuoteFound And (Not xQuoteRightFound)
              Debug "SingleQuote Right at : " + Str(I)
              xQuoteRightFound = #True  
              newEnd= I-1
            EndIf
           
          Case  #STR_CHAR_SPACE
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
        *char + #STR_CharSize   ; Index to next Char
      Wend
    EndIf
    ProcedureReturn N
  EndProcedure
  ReplaceChar = @_ReplaceChar()     ; Bind ProcedureAdress to the PrototypeHandler

  ; for String we can use the PB CountString()
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
        *char + #STR_CharSize     ; Index to next Char
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
          
        Case #STR_CHAR_SPACE    ; if the Separator is not ' ' we must handle Spaces seperatly
          ; Attention this CASE will only be processed if the Seperator it'n not a SPACE
          If Not IngnoreSpaces
             xWordStart = #True  ; if we do not ignore Spaces it is a WordStart
             ; Debug "Ignored Space"  
          EndIf
          
        Default 
          xWordStart = #True
      EndSelect      
       *char + #STR_CharSize              ; Index to next Char
    Wend
    
    ; If a Word was started And we reached the End of String, we have To count this last Word
    If xWordStart 
      N + 1
    EndIf   
    ProcedureReturn N   
  EndProcedure
  CountWords = @_CountWords()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.s _AddQuotes(*String, cQuote.c=#STR_CHAR_DoubleQuote)  ; 
  ; ============================================================================
  ; NAME: _AddQuotes
  ; DESC: !PointerVersion! use it as ProtoType AddQuotes()
  ; DESC: Add Quotes to a String on left and right side
  ; VAR(String$): The String
  ; VAR(QuoteType): #STR_xDoubleQuotes, #STR_xSingleQuotes
  ; RET.s : String without Quotes
  ; ============================================================================
    ; ASCII-34 = ", ASCII-39 = '
    ProcedureReturn Chr(cQuote) + PeekS(*String) + Chr(cQuote)
  EndProcedure
  AddQuotes = @_AddQuotes()     ; Bind ProcedureAdress to the PrototypeHandler
      
  Procedure.s _RemoveQuotes(*String, UnQuoteMode=#STR_xDoubleQuotes, xTrim=#True)
  ; ============================================================================
  ; NAME: RemoveQuotes_
  ; DESC: !PointerVersion! use it as ProtoType RemoveQuotes()
  ; DESC: Remove Quotes from a String on left and right side
  ; VAR(String$): The String
  ; VAR(UnQuoteMode): #STR_xDoubleQuotes, #STR_xSingleQuotes or cmbination of both
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
        *pWord = *String + (\WordStart-1) * #STR_CharSize
        
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

  Procedure _CreateWordIndex(*String, List WordIndex.TWordIndex(), cSeparator.c=' ', UnQuoteMode = 0, xTrim=#True)
  ; ============================================================================
  ; NAME: _CreateWordIndex
  ; DESC: !PointerVersion! use it as ProtoType CreateWordIndex()
  ; DESC: !!! PointerVersion !!! Use it if know what you are doing
  ; VAR(*String) : Pointer to the String from which a WordIndex will be created
  ; VAR(List WordIndex.TWordIndex()): Your List() which should hold the WordIndex  
  ; VAR(cSeparator.c) : Character which seperatres the Words
  ;                     Double characters are igored
  ; VAR(UnQuoteMode): #STR_xDoubleQuotes, #STR_xSingleQuotes or cmbination of both
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
          
        Case #STR_CHAR_SPACE    ; if the Separator is not ' ' we must handle Spaces seperatly
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
          
        Case #STR_CHAR_SPACE     ; if the Separator is not ' ' we must handle Spaces seperatly
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
          If *String\c = #STR_CHAR_DoubleQuote
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
    
    ; BufferLength = StringByteLength(Text, #PB_Unicode) + LengthOfNullCahr 
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule STR
  
  #AllQuotes = #STR_xDoubleQuotes | #STR_xSingleQuotes
  Define s.s, t.s
  s = "   I am 'a' String   "
  Debug "The String : " + s
  Debug ""
  Debug "Without Trim"
  t = AddQuotes(s,#STR_xDoubleQuotes)
  Debug "Add double Quotes : " + t
  t = RemoveQuotes(t, #AllQuotes, #False)  
  Debug "Remove double Quotes : " + t
  
  ;   Debug "Add single Quotes : " + t
;   t = RemoveQuotes(t, #AllQuotes, #False)  
;   Debug "Remove all Quotes : " + t
;   Debug ""
;   t = AddQuotes(s,#STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + t
;   t = RemoveQuotes(t,#AllQuotes, #False)
;   Debug "Remove all Quotes : " + t
;   Debug ""
;   Debug "With Trim"
;     t = AddQuotes(s,#STR_xSingleQuotes)
;   Debug "Add single Quotes : " + t
;   t = RemoveQuotes(t, #AllQuotes)  
;   Debug "Remove all Quotes : " + t
;   Debug ""
;   t = AddQuotes(s,#STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + t
;   t = RemoveQuotes(t,#AllQuotes)
;   Debug "Remove all Quotes : " + t
;   Debug ""
;   t = AddQuotes(s,#STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + t
;   Debug "Try what happens without QuoteType"
;   t = RemoveQuotes(t,0)
;   Debug "Without QuoteType : " + t
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
; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 19
; FirstLine = 14
; Folding = ----
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)