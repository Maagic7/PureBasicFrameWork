; ===========================================================================
;  FILE : PbFw_Module_String.pb
;  NAME : Module String [STR::]
;  DESC : Provides extended String Functions 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/08
; VERSION  :  0.20 untested Developer Version
; COMPILER :  PureBasic 6.0+
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
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

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module
; XIncludeFile ""

DeclareModule STR
  
  ;- --------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  --------------------------------------------------
  
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
  ;#STR_CharSize = SizeOf(Character)   ; Application CharacterSize = 2 Bytes
  
  ;#TAB is PB integrated
  #STR_CHAR_SPACE       = 32    ; ' '
  #STR_CHAR_DoubleQuote = 34    ; "
  #STR_CHAR_SingleQuote = 39    ; '
  
  ; Structure for indexing Words in Strings
  Structure TWordIndex
    WordStart.i     ; Character number of first char [1..]
    Length.i        ; Length in Characters
  EndStructure
  

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
  Macro StringToAsciiBuffer(String, ptrBuffer)
    PokeS(String, ptrBuffer, #PB_Ascii)  
  EndMacro

  ; --------------------------------------------------
  ; Char based Funcitons
  ; -------------------------------------------------- 
 
  Declare.s GetVisibleAsciiCharset()
  
  Prototype.i CountChar(String$, cSearch.c)     ; ProtoType-Function for CountChar
  Global CountChar.CountChar                    ; define Prototype-Handler for CountChar
  
  Prototype.i CharHistogram(String$, Array hist(1), Mode=#PB_Ascii)
  Global CharHistogram.CharHistogram
  
  ; ----------------------------------------------------------------------
  ; The following Functions exist in two versions:
  ;   - the Fast version: the passed strings are modified directly in memory.
  ;   - the standard version: The strings are copied twice. A Copy is
  ;     passed to the function and a other copy will be returned. Thats the
  ;     PB standard way of processing Strings
  ; ----------------------------------------------------------------------
  Prototype.i ReplaceCharFast(String$, cSearch.c, cReplace.c)   ; The Fast version (in Memory)
  Global ReplaceCharFast.ReplaceCharFast                        ; define Prototype-Handler for ReplaceCharFast
  Declare.s ReplaceChar(String$, cSearch.c, cReplace.c)         ; The standard version
   
  Prototype.i RemoveCharFast(String$, Char.c)
  Global RemoveCharFast.RemoveCharFast                          ; define Prototype-Handler for RemoveCharFast
  Declare.s RemoveChar(String$, Char.c)

  Prototype.i RemoveCharsFast(String$, Char1.c, Char2.c=0, xTrim=#False)
  Global RemoveCharsFast.RemoveCharsFast
  Declare.s RemoveChars(String$, Char1.c, Char2.c=0, xTrim=#False)
  
  Prototype.i RemoveNonWordCharsFast(*String)
  Global RemoveNonWordCharsFast.RemoveNonWordCharsFast
  Declare.s RemoveNonWordChars(String$)
  
  Prototype.i RemoveTabsAndDoubleSpaceFast(String$)
  Global RemoveTabsAndDoubleSpaceFast.RemoveTabsAndDoubleSpaceFast
  Declare.s RemoveTabsAndDoubleSpace(String$)  
  
  Prototype.i ReplaceAccentsFast(String$)
  Global ReplaceAccentsFast.ReplaceAccentsFast
  Declare.s ReplaceAccents(String$)
  
  ; --------------------------------------------------
  ; CSV Functions
  ; -------------------------------------------------- 
  
  Prototype SplitCsvToArray(Array Out.s(1), String$, Separator.c=';', cQuotes.c='"')
  Global SplitCsvToArray.SplitCsvToArray
 
  Prototype SplitCsvToList(List Out.s(), String$, Separator.c=';', cQuotes.c='"')
  Global SplitCsvToList.SplitCsvToList
    
  ; ----------------------------------------------------------------------
  ; HEX String Functions
  ; ---------------------------------------------------------------------- 
  
  Declare.s HexStringFromBuffer(*Buffer, Bytes)           ; creates a Hex-Value String from a Buffer/Memory  
  
  Prototype.i HexStringToBuffer(HexStr.s, *Buffer, Bytes=#PB_All)   ; converts a Hex-Value String back to a Byte-Buffer
  Global  HexStringToBuffer.HexStringToBuffer
  
  ; --------------------------------------------------
  ;  Miscellaneous
  ; -------------------------------------------------- 
  
  Prototype.s AddQuotes(String$, cQuotes.c=#STR_CHAR_DoubleQuote)
  Global AddQuotes.AddQuotes              ; define Prototype-Handler for AddQuotes
  
  Prototype.s UnQuote(String$, xDoubleQuotes = #True, xSingleQuotes=#True, xTrim=#True)  ; 
  Global UnQuote.UnQuote                  ; define Prototype-Handler for UnQuote
  
  Prototype.i CountWords(String$, cSeparator.c=' ', IngnoreSpaces=#True)
  Global CountWords.CountWords            ; define Prototype-Handler for CountWords
  
  Prototype CreateWordIndex(String$, List WordIndex.TWordIndex(), cSeparator.c=' ', UnQuoteMode = 0, xTrim=#True)
  Global CreateWordIndex.CreateWordIndex  ; define Prototype-Handler for CreateWordIndex
  
  ; --------------------------------------------------
  ;  StringsBetween
  ; -------------------------------------------------- 
  Declare.s TextBetween(String$, Left$, Right$)
  Declare.i StringsBetweenList(String$, Left$, Right$, List Result.s())
  Declare.i StringsBetweenArray(String$, Left$, Right$, Array Result.s(1))
  
  ; --------------------------------------------------
  ;  Array<=>List
  ; -------------------------------------------------- 
  Declare.i StringArrayToList(Array aryStr.s(1), List lstStr.s())
  Declare.i StringListToArray(List lstStr.s(), Array aryStr.s(1))

 EndDeclareModule

Module STR      ; Module STRING [STR::]
    
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
     
  #_ArrayRedimStep = 10                   ; Redim-Step if Arraysize is to small

  ;- --------------------------------------------------
  ;- Module Private Functions
  ;- --------------------------------------------------
   
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
  
  ;- --------------------------------------------------
  ;- Char based Functions
  ;- -------------------------------------------------- 
  
  Procedure.s GetVisibleAsciiCharset()
  ; ============================================================================
  ; NAME: GetVisibleAsciiCharset
  ; DESC: Get a String with all visible Ascii Chars
  ; DESC: form 32..127 and 161..255  => 191 Chars
  ; RET.i : String with all visible Ascii Chars  Len()=191
  ; ============================================================================
    Protected I
    Protected ret$ = Space(255)
    Protected *String.Character = @ret$
    
    For I = 32 To 127
      *String\c = I
      *String + SizeOf(Character)
    Next
    
    For I = 161 To 255
      *String\c = I
      *String + SizeOf(Character)
    Next 
    ; Add EndOfString
    *String\c = 0
  ;   Debug Len(ret$)
  ;   Debug Asc(Mid(ret$,191))
    ProcedureReturn PeekS(@ret$)
  EndProcedure
  
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
        *char + SizeOf(Character)     ; Index to next Char
      Wend
    EndIf
    ProcedureReturn N  ; return the number of Chars found  
  EndProcedure
  CountChar = @_CountChar()     ; Bind ProcedureAddress to the PrototypeHandler
  
  Procedure.i _CharHistogram(*String, Array hist(1), Mode=#PB_Ascii)
  ; ============================================================================
  ; NAME: CharHistogram
  ; DESC: !PointerVersion! use it as ProtoType CharHistogram()
  ; DESC: Counts the number of all Character
  ; VAR(String$) : The String
  ; VAR( Array hist()) : Array to receive the Character counts
  ; RET.i : max Array Index; 255 for ASCII or 65535 for Unicode Strings
  ; ============================================================================
    Protected *c.Character   ; Pointer to a virutal Char-Struct
    Protected ret
    
    *c = *String
   
    If *c      
      If Mode = #PB_Ascii
        Dim hist(255)
        ret = 255
      Else
        Dim hist(65535)
        ret = 65535
      EndIf
     
      If Mode = #PB_Ascii
        While *c
          If *c\c <=255 
            hist(*c\c) + 1
          EndIf
          *c + SizeOf(Character)
        Wend
      Else
        While *c
          hist(*c\c) + 1
          *c + SizeOf(Character)
        Wend       
      EndIf   
    EndIf    
    
    ProcedureReturn ret
  EndProcedure
  CharHistogram = @_CharHistogram()     ; Bind ProcedureAddress to the PrototypeHandler
       
  Procedure.i _ReplaceCharFast(*String, cSearch.c, cReplace.c)
  ; ============================================================================
  ; NAME: _ReplaceCharFast
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
  ; RET.i : Number of Chars replaced
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
        *char + SizeOf(Character)   ; Index to next Char
      Wend
    EndIf
    
    ProcedureReturn N     
  EndProcedure
  ReplaceCharFast = @_ReplaceCharFast()     ; Bind ProcedureAddress to the PrototypeHandler
  
  Procedure.s ReplaceChar(String$, cSearch.c, cReplace.c)
    _ReplaceCharFast(@String$,cSearch, cReplace)
    ProcedureReturn PeekS(@String$)  
  EndProcedure
  
   
  ; ----------------------------------------------------------------------------
  Macro mac_RemoveChar_KeepChar()
  	If *pWrite <> *pRead     ; if  WritePosition <> ReadPosition
  		*pWrite\c = *pRead\c   ; Copy the Character from ReadPosition to WritePosition => compacting the String
  	EndIf
  	*pWrite + SizeOf(Character) ; set new Write-Position 
  EndMacro

  Procedure.i _RemoveCharFast(*String, Char.c)
  ; ============================================================================
  ; NAME: RemoveCharFast
  ; NAME: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Removes a Character from the String
  ; DESC: The String will be shorter after
  ; VAR(*String) : Pointer to String
  ; VAR(Char.c) : The Character to remove
  ; RET.i: Number of removed Chars 
  ; ============================================================================
    
   Protected *pRead.Character = *String
   Protected *pWrite.Character = *String
  	    
    If (Not *String) Or (Not Char)
      ProcedureReturn
    EndIf
    
 	  While *pRead\c     ; While Not NullChar    
 	    If *pRead\c <> Char
 	      mac_RemoveChar_KeepChar()
      EndIf           
      PX::INCC(*pRead)  ; Set Pointer to NextChar
    Wend
  	
  	; If *pWrite is not at end of orignal *pRead,
  	; we removed some char and must write a 0-Termination as new EndOfString 
  	If *pRead <> *pWrite
  		*pWrite\c = 0
  	EndIf
  	
  	ProcedureReturn (*pRead - *pWrite)/SizeOf(Character) ; Number of characters removed
  EndProcedure
  RemoveCharFast = @_RemoveCharFast()
  
  Procedure.s RemoveChar(String$, Char.c)
    _RemoveCharFast(@String$, Char)
    ProcedureReturn PeekS(@String$)
  EndProcedure
  
  Procedure.i _RemoveCharsFast(*String, Char1.c, Char2.c=0, xTrim=#False)
  ; ============================================================================
  ; NAME: RemoveCharsFast
  ; DESC: Removes up to 2 different Character from a String
  ; DESC: The String will be shorter after
  ; DESC: Example: str\s= " ..This, is a, Test.! " : RemoveChars(str\s, '.' , ',' ,#True)
  ; DESC: =>              "This is a Test!"
  ; VAR(*String.String) : Pointer to String-Struct
  ; VAR(Char1.c) : The first Character to remove
  ; VAR(Char2.c) : The second Character to remove 
  ; VAR(xTrim=#False): Do a left and right Trim (remove leading Spaces)
  ; RET.i: Number of removed Characters
  ; ============================================================================
    
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
    
    ProcedureReturn cnt
  EndProcedure
  RemoveCharsFast = @_RemoveCharsFast()
  
  Procedure.s RemoveChars(String$, Char1.c, Char2.c=0, xTrim=#False)
    _RemoveCharsFast(@String$, Char1, Char2, xTrim)
    ProcedureReturn PeekS(@String$)
  EndProcedure

  Procedure.i _RemoveNonWordCharsFast(*String)
  ; ============================================================================
  ; NAME: RemoveNonWordCharsFast
  ; NAME: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Removes NonWord Characters from the String
  ; DESC: The String will be shorter after
  ; DESC: (question at PB-Forum: https://www.purebasic.fr/english/viewtopic.php?t=82139)
  ; VAR(*String) : Pointer to String
  ; RET.i: *String 
  ; ============================================================================
    
    Protected *pRead.Character = *String  	
    Protected *pWrite.Character = *String
  	    
    If Not *String
      ProcedureReturn
    EndIf
    
  	While *pRead\c     ; While Not NullChar
  	  
  	  Select *pRead\c
  	      
        ; ----------------------------------------------------------------------
        ; Characters to keep
        ; ----------------------------------------------------------------------             
  	      
        ; If we check for the most probably Chars first, we speed up the operation
        ; because we minimze the number of checks to do!
        Case 'a' To 'z'   ; keep  a to z
          mac_RemoveChar_KeepChar()		; local Macro _KeepChar()
          
        Case 'A' To 'Z'   ; keep  A to Z
          mac_RemoveChar_KeepChar()				
                 
   	    Case '0' To '9'   ; keep 0 to 9
          mac_RemoveChar_KeepChar()				
          
        Case '_'          ; keep '_'
          mac_RemoveChar_KeepChar()				
                        
      EndSelect
      
      *pRead + SizeOf(Character) ; Set Pointer to NextChar
  		
    Wend
  	
  	; If *pWrite is not at end of orignal *pRead,
  	; we removed some char and must write a 0-Termination as new EndOfString 
  	If *pRead <> *pWrite
  		*pWrite\c = 0
  	EndIf
    ProcedureReturn *String
  EndProcedure
  RemoveNonWordCharsFast = @_RemoveNonWordCharsFast()
  
  Procedure.s RemoveNonWordChars(String$)
    _RemoveNonWordCharsFast(@String$)
    ProcedureReturn PeekS(@String$)
  EndProcedure
   
  ; ----------------------------------------------------------------------------
  Macro mac_RemoveTabsAndDoubleSpace_KeepChar()
  	If *pWrite <> *pRead          ; if  WritePosition <> ReadPosition
  		*pWrite\c = *pRead\c        ; Copy the Character from ReadPosition to WritePosition => compacting the String
  	EndIf
  	*pWrite + SizeOf(Character)   ; set new Write-Position 
  EndMacro
  
  Procedure.i _RemoveTabsAndDoubleSpaceFast(*String)
  ; ============================================================================
  ; NAME: RemoveTabsAndDoubleSpaceFast
  ; DESC: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Removes all TABs and all double SPACEs from the String dirctly
  ; DESC: in memory by keeping allocated memory. The String will be shorter after!
  ; VAR(*String) : Pointer to String
  ; RET.i: *String 
  ; ============================================================================
    
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
            *pRead\c = #STR_CHAR_SPACE    ; Change TAB to SPACE
            mac_RemoveTabsAndDoubleSpace_KeepChar()   ; keep the Char
          EndIf
            
        Case #STR_CHAR_SPACE
          
          If *pRead\cc[1] = #STR_CHAR_SPACE        
           ; if NextChar = SPACE Then remove   
          Else
            mac_RemoveTabsAndDoubleSpace_KeepChar()   ; keep the Char
          EndIf          
          
        Default
          mac_RemoveTabsAndDoubleSpace_KeepChar()		; local Macro _KeepChar()
         
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
  	If *pWrite\c = #STR_CHAR_SPACE
  		*pWrite\c = 0
 	  EndIf
 	  ProcedureReturn *String
  EndProcedure
  RemoveTabsAndDoubleSpaceFast=@_RemoveTabsAndDoubleSpaceFast()
  
  Procedure.s RemoveTabsAndDoubleSpace(String$)
  ; ============================================================================
  ; NAME: RemoveTabsAndDoubleSpace
  ; DESC: correct String-Pointer
  ; DESC: Removes all TABs and all double SPACEs from the String
  ; DESC: This is ths Standard-Version where PB creats a copy ot the String
  ; DESC: and return a String.
  ; DESC: A fast version which modifies the String in Memory is 
  ; DESC: RemoveTabsAndDoubleSpaceFast()
  ; VAR(String$) : The String
  ; RET.s: The new String 
  ; ============================================================================
    
    _RemoveTabsAndDoubleSpaceFast(@String$)
 	  ProcedureReturn PeekS(@String$)
  EndProcedure

  Procedure.i _ReplaceAccentsFast(*String)
  ; ============================================================================
  ; NAME: ReplaceAccents
  ; DESC: Replace accent characters with their base characters
  ; DESC: áàä..->a, éè..->e, ìí..->i ...
  ; DESC: Removes all accent characters in the ASCII Table >=192 with the base
  ; DESC: characters.
  ; VAR(*String) : Pointer to the String with accent characters
  ; RET.i: *String
  ; ============================================================================
    
    Protected *c.Character = *String
    
    If *c 	
      While *c\c
        If *c\c >= 192   ; Accent chars start at 192 with 'À'    
          
          Select *c\c
            Case 224 To 230   ; 'a' with accents
              *c\c = 'a'            
            Case 232 To 235   ; 'e' with accents
              *c\c = 'e'              
            Case 236 To 239   ; 'i' with accents
              *c\c = 'i'             
            Case 242 To 246   ; 'o' with accents
      				*c\c = 'o'             
            Case 249 To 252   ; 'u' with accents
      				*c\c = 'u'
  
            Case 192 To 198   ; 'A' with accents
              *c\c = 'A'
            Case 200 To 203   ; 'E' with accents
              *c\c = 'E'           
            Case 204 To 207   ; 'I' with accents
              *c\c = 'I'
            Case 210 To 214   ; 'O' with accents
      				*c\c = 'O'
            Case 217 To 220   ; 'U' with accents
      				*c\c = 'U'
                    				
        		Case 241          ; 'n' with accent 
        	    *c\c = 'n'
      			Case 209          ; 'N' with accent
       				*c\c = 'N'
       				
       			Case 221          ; 'Y' with accent
      			  *c\c = 'Y'
      			Case 253, 255     ; 'y' with accents
       				*c\c = 'y'    				     			  
       		EndSelect
      	EndIf     	
      	*c + SizeOf(Character)
    	Wend
    EndIf
    ProcedureReturn *String
  EndProcedure
  ReplaceAccentsFast = @_ReplaceAccentsFast()
  
  Procedure.s ReplaceAccents(String$)
    _ReplaceAccentsFast(@String$)
    ProcedureReturn PeekS(@String$)  
  EndProcedure
  
 ; The Macro for SplitCsvToArray to LeftTrim TAB, SPACE and Quotes by adjusting the Pointer
  Macro _mac_LeftTrimCSV()
     While *Start\c
        Select *Start\c
          Case 9, 32                    ; TAB or SPACE or Quotes
            *Start + SizeOf(Character)
          Case cQuotes
            *Start + SizeOf(Character)
          Default
            Break
        EndSelect
      Wend  
  EndMacro
  
  ; The Macro for SplitCsvToArray to RightTrim TAB, SPACE and Quotes by adjusting the Pointer
  Macro _mac_RightTrimCSV()
    While *End > *Start
      Select *End\c
        Case 9, 32       ; TAB or SPACE
          *End - SizeOf(Character)
        Case  cQuotes      ; Quotes
          *End - SizeOf(Character)
        Default
          Break       
      EndSelect    
    Wend
  EndMacro
   
  Procedure.i _SplitCsvToArray(Array Out.s(1), *String, cSeparator.c=';', cQuotes.c='"')
  ; ============================================================================
  ; NAME: SplitCsvToArray
  ; DESC: SplitString optimized for CSV-File Lines
  ; DESC: Split a String into multiple Strings with left and right Trim
  ; DESC; of TAB, SPACE and Quotes
  ; VAR(Out.s()) : Array to return the Substrings: longer than NoOfSubstrings 
  ;                Use For I=0 to N-1 to Step trough all Substrings or
  ;                Redim(Out(N-1)). This gives more speed if you know how
  ;                much Substrings you get (that's normal for .CSV)
  ; VAR(*String)    : Pointer to String 
  ; VAR(*cSeparator) : Separator Character; typical ';' or ','
  ; VAR(cQuotes)     : 0 to deacivate or Quotes to remove " (34) or ' (39) 
  ; RET.i           : No of Substrings
  ; ============================================================================

    Protected *ptrString.Character = *String        ; Pointer to String      
    Protected *Start.Character = *String            ; Pointer to Start of SubString
    Protected *End.Character                        ; Pointer to End of Substring   
    Protected xEqual, N, ASize, L
            
    ASize = ArraySize(Out())
    
    While *ptrString\c                          ; Stepping trough *String
       
      If  *ptrString\c = cSeparator             ; Seperator found in String                       
        _mac_LeftTrimCSV()                      ; LeftTrim TAB, SPACE, Quotes    
        *End = *ptrString - SizeOf(Character)
        ;Debug "EndChar= " + Chr(*End\c)
        _mac_RightTrimCSV()                     ; RightTrim TAB, SPACE, Quotes
                  
        ; Length of the String from trimed Start to trimmed End
        L =  (*End - *Start)/SizeOf(Character) + 1
        Out(N) = PeekS(*Start, L)
        *Start = *ptrString + SizeOf(Character) ; The new Sart position
        N + 1   
        If ASize < N                            ; Check ArraySize and Redim it
          ASize + #_ArrayRedimStep              ; Add 10 elements
          ReDim Out(ASize)
        EndIf              
      EndIf   
      
      *ptrString + SizeOf(Character)      
    Wend
    
    _mac_LeftTrimCSV()                          ; LeftTrim TAB, SPACE, Quotes
    
    L = MemoryStringLength(*Start)
    If L > 0
      *End = *Start + (L-1) * SizeOf(Character)
      ; Debug "End= " +Str(*End)  + " : Start= " + Str(*Start)
      _mac_RightTrimCSV()
      ; Debug "End= " +Str(*End)  + " : Start= " + Str(*Start)
      Out(N) = PeekS(*Start, (*End - *Start)/SizeOf(Character)+1)
      ; Debug Out(N)
    Else
      Out(N)=""  
    EndIf
    
    ProcedureReturn N+1                   ; Number of Substrings
  EndProcedure
  SplitCsvToArray = @_SplitCsvToArray()     ; Bind ProcedureAddress to Prototype
  
  Procedure.i _SplitCsvToList(List Out.s(), *String, cSeparator.c=';', cQuotes.c='"', clrList= #True)
  ; ============================================================================
  ; NAME: SplitCsvToList
  ; DESC: SplitString optimized for CSV-File Lines
  ; DESC: Split a String into multiple Strings with left and right Trim
  ; DESC; of TAB, SPACE and Quotes
  ; VAR(Out.s()) : List to return the Substrings
  ; VAR(*String) : Pointer to String 
  ; VAR(cSeparator) : Separator Character; typical ';' or ','
  ; VAR(cQuotes)  : 0 to deacivate or Quotes to remove " (34) or ' (39) 
  ; VAR(clrList) : #False: Append Splits to List; #True: Clear List first
  ; RET.i : No of Substrings
  ; ============================================================================

    Protected *ptrString.Character = *String        ; Pointer to String      
    Protected *Start.Character = *String            ; Pointer to Start of SubString
    Protected *End.Character                        ; Pointer to End of Substring   
    Protected xEqual, N, L  
        
    If clrList
      ClearList(Out())  
    EndIf
    
    While *ptrString\c                          ; Stepping trough *String
       
      If  *ptrString\c = cSeparator              ; Seperator found in String                       
        _mac_LeftTrimCSV()                      ; LeftTrim TAB, SPACE, Quotes    
        *End = *ptrString - SizeOf(Character)
        ;Debug "EndChar= " + Chr(*End\c)
        _mac_RightTrimCSV()                     ; RightTrim TAB, SPACE, Quotes
                  
        ; Length of the String from trimed Start to trimmed End
        L =  (*End - *Start)/SizeOf(Character) + 1
        AddElement(Out())
        Out() = PeekS(*Start, L)
        *Start = *ptrString + SizeOf(Character) ; The new Sart position
        N + 1   
       EndIf   
      
      *ptrString + SizeOf(Character)      
    Wend
    
    _mac_LeftTrimCSV()                          ; LeftTrim TAB, SPACE, Quotes
    
    L = MemoryStringLength(*Start)
    If L > 0
      *End = *Start + (L-1) * SizeOf(Character)
      ; Debug "End= " +Str(*End)  + " : Start= " + Str(*Start)
      _mac_RightTrimCSV()
      ; Debug "End= " +Str(*End)  + " : Start= " + Str(*Start)
      AddElement(Out())
      Out() = PeekS(*Start, (*End - *Start)/SizeOf(Character)+1)
      ; Debug Out(N)
    Else
     AddElement(Out())
     Out()=""  
    EndIf
    
    ProcedureReturn N+1                   ; Number of Substrings
  EndProcedure
  SplitCsvToList = @_SplitCsvToList()     ; Bind ProcedureAddress to Prototype  
    
  ;- ----------------------------------------------------------------------
  ;- HEX String Functions
  ;- ---------------------------------------------------------------------- 
        
  Procedure.s HexStringFromBuffer(*Buffer, Bytes)    
  ; ============================================================================
  ; NAME: HexStringFromBuffer
  ; DESC: Converts a Buffer to a Hex-String
  ; DESC: Convert each Byte to a 2-char-Hex-String
  ; VAR(*Buffer) : Pointer to the Buffer
  ; VAR(Bytes) : Number of Bytes to convert    
  ; RET.s: The String with the Bytes Hex-Values
  ; ============================================================================
   Protected I, *src.PX::pChar, *dest.PX::pChar
   Protected hiNibble.a, loNibble.a 
   Protected sRet.s
      
   If *Buffer
      sRet.s = Space(Bytes * 2) ; for each Byte we need to HEX digits 255=FFh
      *dest = @sRet
      *src = *Buffer  
       
      For I=0 To (Bytes-1)
        hiNibble =  (*src\aa[I] >> 4)  + '0'  ; Add Ascii-Code of '0'
        If hiNibble > '9' : hiNibble  + 7 : EndIf ; If 'A..F', we must add 7 for the correct Ascii-Code
        
        loNibble =  (*src\aa[I] & $0F) + '0'
        If loNibble > '9' : loNibble  + 7 : EndIf
        
        *dest\cc[I]   = hiNibble         
        *dest\cc[I+1] = loNibble
      Next
    
      ProcedureReturn sRet
    EndIf  
    ProcedureReturn #Null$
  EndProcedure
  
  Procedure.i _HexStringToBuffer(HexStr.s, *Buffer, Bytes=#PB_All)    
  ; ============================================================================
  ; NAME: HexStringToBuffer
  ; DESC: !PointerVersion! use it as ProtoType HexStringToBuffer()
  ; DESC: Converts a back Hex-String to Data
  ; DESC: Convert each 2Char HEX into a Byte
  ; DESC: The String with the Hex-Value Stream, 2 Chars per Byte {00..FF}
  ; VAR(*Buffer) : Pointer to the Buffer
  ; VAR(Bytes) : Number of Bytes to convert    
  ; RET.i: Number of Bytes copied
  ; ============================================================================    
    Protected I, *src.PX::pChar, *dest.PX::pChar 
    Protected hiNibble.a, loNibble.a 
        
    If *Buffer        
      *src = @HexStr
      *dest = *Buffer
      
      If Bytes =#PB_All : Bytes = 2147483647 : EndIf
      Debug "Bytes : " + Bytes
      
      While Bytes 
        hiNibble = (*src\cc[I * SizeOf(Character)]) ; read HexChar from String
         
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
        
        loNibble = (*src\cc[I * SizeOf(Character) +1]) 
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
        
        *dest\aa[I] = (hiNibble << 4) | loNibble         
        I + 1       ; Increment Position Counter
        Bytes -1    ; Decrement number of Bytes left
      Wend
    EndIf  
    ProcedureReturn I
  EndProcedure
  HexStringToBuffer = @_HexStringToBuffer()     ; Bind ProcedureAddress to the PrototypeHandler
  
  ;- --------------------------------------------------
  ;-  Miscellaneous
  ;- -------------------------------------------------- 
  
  Procedure.s _AddQuotes(*String, cQuotes.c=#STR_CHAR_DoubleQuote)  ; 
  ; ============================================================================
  ; NAME: _AddQuotes
  ; DESC: !PointerVersion! use it as ProtoType AddQuotes()
  ; DESC: Add Quotes to a String on left and right side
  ; VAR(String$): The String
  ; VAR(QuoteType): #STR_xDoubleQuotes, #STR_xSingleQuotes
  ; RET.s : String without Quotes
  ; ============================================================================
    ; ASCII-34 = ", ASCII-39 = '
    ProcedureReturn Chr(cQuotes) + PeekS(*String) + Chr(cQuotes)
  EndProcedure
  AddQuotes = @_AddQuotes()     ; Bind ProcedureAddress to the PrototypeHandler
  
  Procedure.s _UnQuote(*String, xDoubleQuotes = #True, xSingleQuotes=#True, xTrim=#True)  ; 
  ; ============================================================================
  ; NAME: _RemoveQuotes
  ; DESC: !PointerVersion! use it as ProtoType RemoveQuotes()
  ; DESC: Remove Quotes from a String on left and right side
  ; DESC: It do not touch quotes after the first text character
  ; DESC: If you want to remove all quotes inside the text use RemoveChar() 
  ; VAR(*String): Pointer to String
  ; VAR(xDoubleQuotes): Accept single Quotes
  ; VAR(xSingleQuotes): Accept double Quotes
  ; RET.s : Unquoted String
  ; ============================================================================
    Protected *pRead.Character, L.i
    Protected *pStart, *pEnd
    Protected.c cQuotes
         
    *pRead = *String
    
    ; search for Quotes until found or TextChar found
    While *pRead\c
      
      If *pRead\c = #STR_CHAR_DoubleQuote And xDoubleQuotes
        *pStart = *pRead + SizeOf(Character)
        cQuotes = #STR_CHAR_DoubleQuote
        Break
      ElseIf *pRead\c = #STR_CHAR_SingleQuote And xSingleQuotes
        *pStart = *pRead + SizeOf(Character)
        cQuotes = #STR_CHAR_SingleQuote
        Break
      ElseIf *pRead\c >= #STR_CHAR_SPACE  ; TextChar found
        *pStart = *String
        Break
      EndIf          
      
      *pRead + SizeOf(Character)
    Wend
    
    If cQuotes ; Quotes found
      
      If xTrim
        While *pRead\c
          If PX::IsSpaceTabChar(*pRead\c)
            ; do nothing
          Else
            *pStart = *pRead
            Break            
          EndIf                 
          PX::INCC(*pRead) ; increment CharPointer
        Wend
      EndIf      
      
      *pRead = *String + MemoryStringLength(*String) * SizeOf(Character) - SizeOf(Character)
            
      While *pRead > *pStart
        
        Select *pRead\c
          Case cQuotes 
            *pEnd = *pRead - SizeOf(Character)
            If Not xTrim
              Break
            EndIf
            
          Case  #STR_CHAR_SPACE, #TAB 
            *pEnd = *pRead - SizeOf(Character)
            
          Default
            *pEnd = *pRead
            Break
        EndSelect
        PX::DECC(*pRead) ; decrement CharPointer  
        
      Wend
            
      L = (*pEnd-*pStart) / SizeOf(Character)
      
      ProcedureReturn PeekS(*pRead, L)
     
    Else
      ProcedureReturn PeekS(*String)
    EndIf

  EndProcedure
  UnQuote = @_UnQuote()     ; Bind ProcedureAddress to the PrototypeHandler
  
  Procedure.i _CountWords(*String, cSeparator.c=' ', IngnoreSpaces=#True)
  ; ============================================================================
  ; NAME: _CountWords
  ; DESC: !PointerVersion! use it as ProtoType CountWords()
  ; DESC: Count the number of Words in a String separated by cSepartor
  ; VAR(*String) : Pointer to the String
  ; VARcSeparator.c(): Character which seperatates the Words
  ; VAR(IngnoreSpaces): #True: Spaces are ignored (skiped), this is irrelevant
  ;                     if the Sperator is a SPACE. 
  ;                     #FALSE SPACE can be the first Char of a Word
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
       *char + SizeOf(Character)     ; Index to next Char
    Wend
    
    ; If a Word was started And we reached the End of String, we have To count this last Word
    If xWordStart 
      N + 1
    EndIf   
    ProcedureReturn N   
  EndProcedure
  CountWords = @_CountWords()     ; Bind ProcedureAddress to the PrototypeHandler

  Procedure _CreateWordIndex(*String, List WordIndex.TWordIndex(), cSeparator.c=' ', UnQuoteMode = 0, xTrim=#True)
  ; ============================================================================
  ; NAME: _CreateWordIndex
  ; DESC: !PointerVersion! use it as ProtoType CreateWordIndex()
  ; VAR(*String) : Pointer to the String from which a WordIndex will be created
  ; VAR(List WordIndex.TWordIndex()): Your List() which should hold the WordIndex  
  ; VAR(cSeparator.c) : Character which seperatres the Words
  ;                     Double characters are igored
  ; VAR(UnQuoteMode): #STR_xDoubleQuotes, #STR_xSingleQuotes or cmbination of both
  ; VAR(xTrim): #True: Remove SPACEs inside the Quotes / #FalseÖ keep SPACEs
  ;             Spaces outside the Quotes are removed always
  ; RET.i : Number of Words found; ListSize(WordIndex())
  ; ============================================================================
     
    Protected *char.PX::pChar   ; Pointer to a virutal Char-Array
    Protected I, N
    Protected xWordStart, PosStart, PosEnd
    Protected idx.TWordIndex
    
    *char = *String         ; overlay the String with a virtual Char-Array
        
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0
    EndIf
    
    While *char\cc[I]         ; until end of String
      Select *char\cc[I]
          
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
  CreateWordIndex = @_CreateWordIndex()     ; Bind ProcedureAddress to the PrototypeHandler
    
  ;- --------------------------------------------------
  ;-  StringsBetween
  ;- -------------------------------------------------- 

  Procedure.s TextBetween(String$, Left$, Right$)
  ; ============================================================================
  ; NAME: TextBetween
  ; DESC: Gets the Text between two String elements Left$ and Right$
  ; DESC: Attention it is an easy version which do not support cascaded between 
  ; DESC: like in brackets "((InBrackets))". TextBetween will deliver "(InBrackets"
  ; VAR(String$) : The String
  ; VAR(Left$) : The left side like "("
  ; VAR(Right$) : The right side like ")"
  ; RET.s : The Text between Left$ and Right$
  ; ============================================================================
    
    Protected posLeft, posRight
    
    posLeft = FindString(String$, Left$)
    
    If posLeft
      posLeft + Len(Left$)
      posRight = FindString(String$, Right$, posLeft)
      
      If posRight
        ProcedureReturn Mid(String$, posLeft, posRight - posLeft)
      EndIf
    EndIf
      
    ProcedureReturn #Null$
  EndProcedure
  
  Procedure.i StringsBetweenList(String$, Left$, Right$, List Result.s())
  ; ============================================================================
  ; NAME: StringsBetweenList
  ; DESC: Gets the Strings between two String elements Left$ and Right$
  ; DESC: as a List. It can be used to get get the text between '<' '>'
  ; DESC: in html files. And for many other use. 
  ; DESC: This code is from the PB forum by mk_soft. 
  ; VAR(String$) : The String
  ; VAR(Left$) : The left side like "("
  ; VAR(Right$) : The right side like ")"
  ; VAR(List Result.s()) : The List with the found Strings
  ; RET.i : The nuber of found Strings (it is identical with the ListSize)
  ; ============================================================================
    Protected pos1, pos2, len1, len2
    
    ClearList(Result())
    len1 = Len(Left$)
    len2 = Len(Right$)
    
    Repeat
      pos1 = FindString(String$, Left$, pos1)     
      If pos1
        pos1 + len1
        pos2 = FindString(String$, Right$, pos1)
        If pos2
          AddElement(Result())
          Result() = Mid(String$, pos1, pos2 - pos1)
          pos1 = pos2 + len2
        Else
          Break
        EndIf
      Else
        Break
      EndIf       
    ForEver
    
    ProcedureReturn ListSize(Result())
  EndProcedure
  
  Procedure.i StringsBetweenArray(String$, Left$, Right$, Array Result.s(1))
  ; ============================================================================
  ; NAME: StringsBetweenArray
  ; DESC: Gets the Strings between two String elements Left$ and Right$
  ; DESC: as an Array of Strings. It can be used to get get the text 
  ; DESC: between '<' '>' in html files. And for many other use. 
  ; DESC: This code is from the PB forum by mk_soft. 
  ; VAR(String$) : The String
  ; VAR(Left$) : The left side like "("
  ; VAR(Right$) : The right side like ")"
  ; VAR(Array Result.s(1)) : The Array with the found Strings
  ; RET.i : The number of found Strings (it is identical with ArraySize-1)
  ; ============================================================================
    Protected pos1, pos2, len1, len2, size, count
    
    Dim Result(0)
    len1 = Len(Left$)
    len2 = Len(Right$)
    
    Repeat
      pos1 = FindString(String$, Left$, pos1)
      If pos1
        pos1 + len1
        pos2 = FindString(String$, Right$, pos1)
        If pos2
          If size < count
            size + 8
            ReDim Result(size)
          EndIf
          Result(count) = Mid(String$, pos1, pos2 - pos1)
          count + 1
          pos1 = pos2 + len2
        Else
          Break
        EndIf
      Else
        Break
      EndIf
    ForEver
    If count > 0
      ReDim Result(count - 1)
    EndIf  
    ProcedureReturn count
  EndProcedure
  
  ;- --------------------------------------------------
  ;-  Array <-> List
  ;- -------------------------------------------------- 
  
  Procedure.i StringArrayToList(Array aryStr.s(1), List lstStr.s())
  ; ============================================================================
  ; NAME: StringArrayToList
  ; DESC: Copies a String-Array to a StringList
  ; VAR(Array aryStr.s(1)) : The StringArray with 1 dimension
  ; VAR(List lstStr.s()) : The StringList
  ; RET.i : The number of found Strings copied
  ; ============================================================================
    Protected I, N
    
    N = ArraySize(aryStr())
    
    If N
      ClearList(lstStr())
      
      For I = 0 To N 
        AddElement(lstStr())
        lstStr() = aryStr(I)
      Next
    EndIf
  
    ProcedureReturn N+1
  EndProcedure
  
  Procedure.i StringListToArray(List lstStr.s(), Array aryStr.s(1))
  ; ============================================================================
  ; NAME: StringListToArray
  ; DESC: Copies a StringList to a String-Array
  ; VAR(List lstStr.s()) : The StringList
  ; VAR(Array aryStr.s(1)) : The StringArray with 1 dimension
  ; RET.i : The number of found Strings copied
  ; ============================================================================
    Protected I, N
    
    N = ListSize(lstStr())
    
    If N
      Dim aryStr(N-1)
      ForEach  lstStr()
        aryStr(I) = lstStr()
        I + 1 
      Next
    EndIf
    
    ProcedureReturn N
  EndProcedure
  
EndModule


CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule STR
  
  ;#AllQuotes = #STR_xDoubleQuotes | #STR_xSingleQuotes
  Define s.s, ret.s
  Define I
  Define T1, T2, T3
  
  s = "   I am 'a'  String  1  2    3 "
;   Debug "The String : " + s
;   Debug ""
;   Debug "Without Trim"
;   ret = AddQuotes(s,#STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + ret
;   ret = RemoveQuotes(ret, #AllQuotes, #False)  
;   Debug "Remove double Quotes : " + ret
  
  CompilerIf Not #PB_Compiler_Debugger
    #cst_LOOPs = 1000000
    
    T1 = ElapsedMilliseconds()
    For I = 1 To #cst_LOOPs
      ret = ReplaceString(s," ", ".", #PB_String_InPlace)
      ;ret = RemoveTabsAndDoubleSpace(s)
    Next
    T1 = ElapsedMilliseconds() - T1
    
    T2 = ElapsedMilliseconds()
    For I = 1 To #cst_LOOPs Step 2
      ReplaceChar(s, 32, '.')
      ReplaceChar(s, '.', 32)
      ;RemoveCharFast(@s, 32)
    Next
    T2 = ElapsedMilliseconds() - T2
    MessageRequester("Times", "RelaceString = " + T1 + #CRLF$ + "ReplaceChar = " + T2)
  CompilerEndIf

  Debug ret
  Debug s
  
 
   
;   Debug "Add single Quotes : " + ret
;   ret = RemoveQuotes(ret, #AllQuotes, #False)  
;   Debug "Remove all Quotes : " + ret
;   Debug ""
;   ret = AddQuotes(s,#STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + ret
;   ret = RemoveQuotes(ret,#AllQuotes, #False)
;   Debug "Remove all Quotes : " + ret
;   Debug ""
;   Debug "With Trim"
;     ret = AddQuotes(s,#STR_xSingleQuotes)
;   Debug "Add single Quotes : " + ret
;   ret = RemoveQuotes(ret, #AllQuotes)  
;   Debug "Remove all Quotes : " + ret
;   Debug ""
;   ret = AddQuotes(s,#STR_xDoubleQuotes)
;   Debug "Add double Quotes : " + ret
;   ret = RemoveQuotes(ret,#AllQuotes)
;   Debug "Remove all Quotes : " + ret
;   Debug ""
;   ret = AddQuotes(s,#STR_xDoubleQuotes)
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


; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 169
; FirstLine = 138
; Folding = --------
; Optimizer
; CPU = 5