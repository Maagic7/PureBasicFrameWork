; ===========================================================================
;  FILE: PbFw_Module_Phonetics.pb
;  NAME: Module Phnonetics 
;  DESC: Phonetic algorithms which assigns to words a sequence of digits,
;  DESC: the phonetic code. The aim of this function ist that identical sounding
;  DESC: words have the same code assigned to them.
;  DESC: The algorithm can be used to perform a similarity search between words.
;  DESC: 
;  DESC: Soundex algorithm: is the most common used and well adapted to
;  DESC: english. With different encoding tabels it can be used with good
;  DESC: results for other languages too.
;  DESC: 
;  DESC: The Cologne Phonetic algorithm is adapted to match the German language
;  DESC: and it is not a good choice for english. It was published in 
;  DESC: 1969 because the german modified Soundex coding did not deliver
;  DESC: optimal results in many cases.
;  SOURCES:  
;     https://de.wikipedia.org/wiki/K%C3%B6lner_Phonetik
;     https://en.wikipedia.org/wiki/Cologne_phonetics
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2025/01/23
; VERSION  :  0.51 Developer Version
; COMPILER :  PureBasic 6.0 and higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;   2025/01/23 : added SoundexEN/DE with englisch and german encoding table
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"       ; DBG::      Debug Module

; XIncludeFile ""

DeclareModule Phonetics
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  Structure TWord
    ID.i
    Word.s
    ArticleID.i ; Verweis der, die, das, -
    TypeID.i    ; Substantiv, Verb, Adjectiv
    BaseID.i    ; Wortstamm : Pointer zum Stammwort
  EndStructure
  
  Declare.s EncodeCologne(String$)
  
  Declare.s EncodeSoundexEN(String$)
  Declare.s EncodeSoundexDE(String$)

EndDeclareModule


Module Phonetics
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Structure pChar
    StructureUnion
      a.a       ; ASCII   : 8 Bit unsigned  [0..255] 
      c.c       ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      u.u       ; UNICODE : 2 Byte unsigned [0..65535]
      aa.a[0]   ; ASCII   : 8 Bit unsigned  [0..255] 
      cc.c[0]   ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      uu.u[0]   ; UNICODE : 2 Byte unsigned [0..65535]
    EndStructureUnion
  EndStructure
  
  Macro UCaseChar(MyChar, ReturnChar)  
    Select MyChar
      Case 'a' To 'z'
        ReturnChar = MyChar - 32  ; a[97]-A[65]=32                
       Case 224 To 254            ; 'À'..254
        ReturnChar = MyChar - 32  ; 254-222 = 32      
      Default
        ReturnChar = MyChar
    EndSelect
  EndMacro

  Macro mac_KeepChar()          ; Macro for compacting Strings when removing Chars
  	If *pWrite <> *pRead        ; If  WritePosition <> ReadPosition
  		*pWrite\c = *pRead\c      ; Copy the Character from ReadPosition to WritePosition => compacting the String
  	EndIf
  	*pWrite + SizeOf(Character) ; Set new Write-Position 
  EndMacro
  
  ;- ----------------------------------------------------------------------
  ;- Cologne Phonetcis / Koelner Phonetik
  ;- ----------------------------------------------------------------------
  
  ; Cologne phonetics is the better algorithm for german 
  
  ; This is the encoding table from Wikipedia
  ; modified from value based to character based!
  ; that's much better for programming
  
  ; Cologne Encdoing Table
  ; ------------------------------------------------
  ; H                      -  ignore!
  ; A, E, I, J, O, U, Y 	= 0
  ; B                     = 1
  ; P vor H               = 3  sonst 1 
  ; D, T   vor C, S, Z    = 8  sonst 2
  ; F, V, W               = 3
  ; G, K, Q               = 4
  ; L                     = 5
  ; M, N                  = 6
  ; R                     = 7
  ; S, Z                  = 8
  ; X  nach C, K, Q       = 8 sonst 48
  
  ; C im Anlaut (1. Buchstabe Wort/Silbe)
  ;   vor A,H,K,L,O,Q,R,U,X   = 4 sonst 8
  
  ; C innerhalb Wort/Silbe 
  ;   nach S, Z               = 8 
  ;   sonst vor A,H,K,O,Q,U,X = 4
  ;   sonst                   = 8
  
  Procedure.s EncodeCologne(String$)
  ; ============================================================================
  ; NAME: EncodeCologne
  ; DESC: Cologne phonetic encoding of a String
  ; DESC: Cologne phonetics is a phonetic algorithm which assigns to words 
  ; DESC: a sequence of digits, the phonetic code. The aim of this procedure is
  ; DESC: that identical sounding words have the same code assigned to them.
  ; DESC: The algorithm can be used to perform a similarity search between words.
  ; DESC: For example, it is possible in a name list to find entries like
  ; DESC: "Meier" under different spellings such as "Maier", "Mayer", or "Mayr".
  ; DESC: The Cologne phonetics is related to the well known Soundex phonetic 
  ; DESC: algorithm but is optimized to match the German language.
  ; DESC: The algorithm was published in 1969 by Hans Joachim Postel.
  ;  
  ; VAR(String$) : The String to encode
  ; RET.s : The encoded String
  ; ============================================================================
    
    Protected xEncoded, xFirstChar = #True
    Protected phon$
    Protected *pC.pChar, *pPh.pChar
           
    String$ = LCase(String$)
    phon$ = Space(Len(String$)*2)
    
    *pC  = @String$
    *pPh = @phon$ 
    
    ; ----------------------------------------------------------------------
    ; Step 1: Character wise phonetic encoding
    ; ----------------------------------------------------------------------
 
    While *pC\c   ; While Not EndOfString
      
      xEncoded = #True
      
      Select *pC\c
        ; --------------------------------------------------  
        Case 'a', 'e', 'i', 'j', 'o', 'u', 'y'    ; according to conversion table
          *pPh\c ='0'
          ; additional conversion found in a SQL implementation
          ; this looks like a good extention
        Case  'ä', 'ö', 'ü', 'é', 'è', 'à', 'ç' 
          *pPh\c ='0'
        ; --------------------------------------------------  
          
        Case 'b'
          *pPh\c ='1'
        ; --------------------------------------------------  
          
        Case 'p'
          If *pC\cc[1] ='h'   ; 'p' followed by 'h'
            *pPh\c ='3'
          Else                ; if single p, it's same as b
            *pPh\c ='1'  
          EndIf
        ; --------------------------------------------------  
          
        Case 'd', 't'
          
          Select *pC\cc[1]    ; check following Char
            Case 'c', 's', 'z'
              *pPh\c ='8'     ; d,t followed by c,s,z
            Default
              *pPh\c ='2'     ; d,t as single Char
          EndSelect
        ; --------------------------------------------------  
          
        Case 'f', 'v', 'w'
          *pPh\c ='3'
        ; --------------------------------------------------  
         
        Case 'g', 'k', 'q'
          *pPh\c ='4'
        ; --------------------------------------------------  
         
        Case 'l' 
          *pPh\c ='5'
        ; --------------------------------------------------  
          
        Case 'm', 'n' 
          *pPh\c ='6'
        ; --------------------------------------------------  
          
        Case 'r' 
          *pPh\c ='7'
        ; --------------------------------------------------  
         
        Case 's', 'z' 
          *pPh\c ='8'
        ; --------------------------------------------------  
          
        Case 'ß' ; = 'ss'
          ; 88
          *pPh\c ='8'
          *pPh + SizeOf(Character)      ; move one char forward
          *pPh\c ='8'         
        ; --------------------------------------------------  
          
        Case 'c'
           
          ; in the initial sound of a word or a syllable
          ; DE: Anlautprüfung : Anlaut ist der erste Buchstabe eines Wortes oder einer Silbe
          ;     ganz korrekt währe wahrscheinlich zuerst eine Silbentrennung druchzuführen!
          
          If xFirstChar       ; --- 'c' is the first char ---
            
            Select *pC\cc[1]    ; check following char
              Case 'a', 'h', 'k', 'l', 'o', 'q', 'r', 'u', 'x'
                *pPh\c ='4'
              Default
                *pPh\c ='8' 
            EndSelect
            
          Else                ; --- 'c' is not the first char ---
            
            ; c after 's', 'z' is always 8
            If  *pC\cc[-1] = 's' Or *pC\cc[-1] = 'z'
              *pPh\c ='8'
            Else             
              Select *pC\cc[1]  ; check following Char
                Case 'a', 'h', 'k', 'o', 'q', 'u', 'x'
                  *pPh\c ='4'
                Default
                  *pPh\c ='8'
              EndSelect         
            EndIf                      
          EndIf               ; --- xFirstChar ---     
        ; --------------------------------------------------  
          
        Case 'x'
          
          ; X=48 if it is the first Char or not after c,k,q
          ; so first set 48 and correct later if x is after c,k,q
          *pPh\c ='4' 
          *pPh + SizeOf(Character)      ; move one char forward
          *pPh\c ='8'          
          
          If Not xFirstChar
            Select *pC\cc[-1]               ; check previous Char
              Case 'c', 'k', 'q'            ; x after c,k,q 
                *pPh - SizeOf(Character)    ; move one char back to the 4 
                *pPh\c ='8'                 ; overwerite the 4 with 8                    
            EndSelect
          EndIf
        
        ; --------------------------------------------------         
          
        Case '-', 32          ; Silbentrennungszeichen oder Worttrennzeichen
          xFirstChar = #True  ; Reset to first char to inital sound encoding of 'c'
          xEncoded = #False   ; the Char is not encoded         
        ; --------------------------------------------------              
          
        Default
          xEncoded = #False   ; the Char is not encoded          
        ; --------------------------------------------------         
      EndSelect
      
      *pC + SizeOf(Character)       ; Pointer String to Next Char
      
      If xEncoded                   ; If it was a char to encode
        *pPh + SizeOf(Character)    ; Pointer phonetic encoded String to Next Char
      EndIf
      
      xFirstChar =#False
    Wend
    
    ; Debug "Encoding without CleanUp = " + phon$
    
    If #True   ; if the CleanUp is activated 
      ; ----------------------------------------------------------------------
      ; CleanUp: to compare 2 Words the CleanUp has to be done first
      ;          without cleanup is only for debug and test
      ; Step 2: remove all double digits from phonetic String
      ; Step 3: Remove all '0' except at the beginning
      ; ----------------------------------------------------------------------
      
      Protected *pRead.pChar
      Protected *pWrite.pChar
  
      *pRead = @phon$   ; set the Read Pointer To start of phonetic string
      *pRead + SizeOf(Character)  ; set Pointer to 2nd Char -> never remove 1st Char
      *pWrite = *pRead
            
      ; we start at second char with removing duplicates and '0'
      ; removing the Chars is done by compacting the String
      While *pRead\c   ; While Not EndOfString
        Select *pRead\c
          Case '0'
            ; remove Char
          Default 
            If *pRead\c = *pRead\cc[-1]   ; identical with previous char
              ; remove Char
            Else
              ; keep Char
              mac_KeepChar()
            EndIf
        EndSelect  
        *pRead + SizeOf(Character)
      Wend
      *pWrite\c = 0   ; Add EndOfString
      ; ----------------------------------------------------------------------
    EndIf
    
    ProcedureReturn phon$
  EndProcedure
   
  ;- ----------------------------------------------------------------------
  ;- Soundex Phonetics
  ;- ----------------------------------------------------------------------
  ; 
  ; https://de.wikipedia.org/wiki/Soundex
  
  ; Soundex is the most common algorithm for english
  ; With modified character table is possible to use for german too.
  ; But Cologne Phonetics is the better choice for german!
  
  ; A Soundex encoding is always for Characters long
  ; It is the first Char + 3 different digits according to encoding table.
  ; Duplicate digits are ignored!
  ; Britney -> to encode Brtn -> B635
  
  ; Soundex Encoding table!
  ; Basic encoding english
  ; -------------------------
  ; 1 |	b, f, p, v
  ; 2 |	c, g, j, k, q, s, x, z
  ; 3 |	d, t
  ; 4 |	l
  ; 5 |	m, n
  ; 6 |	r 
  ; the rest is ignored
  
  ; German encoding
  ; -------------------------
  ; 0 |	a, e, i, o, u, ä, ö, ü, y, j, h
  ; 1 |	b, p, f, v, w
  ; 2 |	c, g, k, q, x, s, z, ß
  ; 3 |	d, t
  ; 4 |	l
  ; 5 |	m, n
  ; 6 |	r
  ; 7 |	ch 
  
  Procedure.s EncodeSoundexEN(String$)
    ; ============================================================================
    ; NAME: EncodeSoundexEN
    ; DESC: Soundex phonetic encoding of a String with the english
    ; DESC: encoding table
    ; DESC: 
    ;  
    ; VAR(String$) : The String to encode
    ; RET.s : The soundex encoded String
    ; ============================================================================
     
    Protected length, cnt, xEncoded
    Protected *pC.pChar, *pPh.pChar
    
    Protected phon$ = "0000"    ; Soundex phonetic is always 4 characters long
           
    String$ = LCase(String$)
    length = Len(String$)
    
    If length = 0
      ProcedureReturn  #Null$
    EndIf
        
    *pC  = @String$
    *pPh = @phon$ 
    
    ; ----------------------------------------------------------------------
    ; Step 1: Keep the first Character of Text in Phon$
    ; ----------------------------------------------------------------------
    
    ; *pPh\c = Asc(UCase(Chr(*pC\c)))   ; ! Change to UCaseChar Macro !
    UCaseChar(*pC\c, *pPh\c)    ; UCaseChar Macro
    *pPh + SizeOf(Character)
    *pC + SizeOf(Character)
    cnt + 1       ; Number of valid characters encoded
    
    ; ----------------------------------------------------------------------
    ; Step 2: Character wise phonetic encoding
    ; ----------------------------------------------------------------------
 
    While *pC\c   ; While Not EndOfString
      
      xEncoded = #True
      
      Select *pC\c
        ; --------------------------------------------------  
        Case 'b', 'f', 'p', 'v'    ; according to conversion table
          *pPh\c ='1'
          ; --------------------------------------------------  
          
        Case 'c', 'g', 'j', 'k', 'q', 's', 'x', 'z'
          *pPh\c ='2'
        ; --------------------------------------------------  
          
        Case 'd', 't'
          *pPh\c ='3'       
        ; --------------------------------------------------  
                    
        Case 'l'
          *pPh\c ='4'
        ; --------------------------------------------------  
         
        Case 'm', 'n'
          *pPh\c ='5'
        ; --------------------------------------------------  
         
        Case 'r'
          *pPh\c ='6'
       ; --------------------------------------------------  
          
        Case 'r' 
          *pPh\c ='7'
        ; --------------------------------------------------  
                   
        Default
          xEncoded = #False   ; the Char is not encoded          
        ; --------------------------------------------------         
      EndSelect
      
       
      If xEncoded                     ; If it was a char to encode  
        If *pPh\c = *pPh\cc[-1]
          ; double digit -> ignor it! Do nothing!
        Else
          *pPh + SizeOf(Character)    ; Pointer phonetic encoded String to Next Char
          cnt + 1                     ; Count the number of valid encodings and quit if Len(phon$)=4
        EndIf      
      EndIf
      
      If cnt = 4 : Break : EndIf    ; Stop at Len(phon$)=4
      *pC + SizeOf(Character)       ; Pointer String to Next Char
    Wend
    
    ProcedureReturn phon$
  EndProcedure
   
  Procedure.s EncodeSoundexDE(String$)
    ; ============================================================================
    ; NAME: EncodeSoundexDE
    ; DESC: Soundex phonetic encoding of a String with the german
    ; DESC: encoding table
    ; DESC: 
    ;  
    ; VAR(String$) : The String to encode
    ; RET.s : The soundex encoded String
    ; ============================================================================
     
    Protected length, cnt, xEncoded
    Protected *pC.pChar, *pPh.pChar
    
    Protected phon$ = "0000"    ; Soundex phonetic is always 4 characters long
           
    String$ = LCase(String$)
    length = Len(String$)
    
    If length = 0
      ProcedureReturn  #Null$
    EndIf
        
    *pC  = @String$
    *pPh = @phon$ 
    
    ; ----------------------------------------------------------------------
    ; Step 1: Keep the first Character
    ; ----------------------------------------------------------------------
    
    ; *pPh\c = Asc(UCase(Chr(*pC\c)))   ; ! Change to UCaseChar Macro !
    UCaseChar(*pC\c, *pPh\c)    ; UCaseChar Macro
    *pPh + SizeOf(Character)
    *pC + SizeOf(Character)
    cnt + 1       ; Number of valid characters encoded
    
    ; ----------------------------------------------------------------------
    ; Step 2: Character wise phonetic encoding
    ; ----------------------------------------------------------------------
 
    While *pC\c   ; While Not EndOfString
      
      xEncoded = #True
      
      Select *pC\c      
        ; --------------------------------------------------  
        Case 'a', 'e', 'i', 'o', 'u', 'ä', 'ö', 'ü', 'y', 'j', 'h' 
          *pPh\c ='0' 
        ; -------------------------------------------------- 
          
        Case 'b', 'f', 'p', 'v', 'w'    ; according to conversion table
          *pPh\c ='1'
        ; --------------------------------------------------  
          
        Case 'g', 'k', 'q', 's', 'x', 'z', 'ß'
          *pPh\c ='2'
        ; --------------------------------------------------  
          
        Case 'c'
          If *pC\cc[1] = 'h'   ; c followed by h = ch  
            *pPh\c ='7'        ; 'ch'
            *pc + SizeOf(Character)  ; step 1 Char forward because 2 Chars 'ch'
          Else
            *pPh\c ='2'    ; 'c'
          EndIf
        
        Case 'd', 't'
          *pPh\c ='3'       
        ; --------------------------------------------------  
                    
        Case 'l'
          *pPh\c ='4'
        ; --------------------------------------------------  
         
        Case 'm', 'n'
          *pPh\c ='5'
        ; --------------------------------------------------  
                   
        Case 'r'
          *pPh\c ='6'
        ; --------------------------------------------------  
                             
        Default
          xEncoded = #False   ; the Char is not encoded          
        ; --------------------------------------------------         
      EndSelect
      
       
      If xEncoded                     ; If it was a char to encode  
        If *pPh\c = *pPh\cc[-1] 
          ; double digit -> ignor it! Do nothing!
        Else
          *pPh + SizeOf(Character)    ; Pointer phonetic encoded String to Next Char
          cnt + 1                     ; Count the number of valid encodings and quit if Len(phon$)=4
        EndIf      
      EndIf
      
      If cnt = 4 : Break : EndIf    ; Stop at Len(phon$)=4
      *pC + SizeOf(Character)       ; Pointer String to Next Char
    Wend
    
    ProcedureReturn phon$
  EndProcedure
   
EndModule
   

;- ----------------------------------------------------------------------
;- Test Code
;  ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  UseModule Phonetics 
  
  Define txt$, res$, Cologn$, SoundexEN$, SounexDE$
  
  Debug ""
  Debug "Soundex EN/DE and Cologne"
  Debug ""
  
  Restore Words
  Read.s txt$
  
  Repeat   
    While txt$ <> ""   
      Cologn$    = EncodeCologne(txt$)
      SoundexEN$ = EncodeSoundexEN(txt$)         ; phonetic encoding Soundex english            
      SounexDE$  = EncodeSoundexDE(txt$)         ; phonetic encoding Soundex german      
      
      Debug "EN = " + SoundexEN$ + " : " + "DE = " + SounexDE$ + " : " + "Cologne = " + Cologn$ + " : " +txt$      
      
      Read.s txt$
    Wend
    Debug ""
    Read.s txt$
  Until txt$ ="%%"
  
  
  DataSection
    Words:
    ; mr, slze, wr = Lautstamm d.h. alles mit diesem Lautstamm wird phontisch codiert den gleichen Wert haben
    Data.s "mr", "Mayer", "Meier", "Meyer", "Maier", "Meyr", "Majer", "Geier", ""
    Data.s "slz", "Schulze", "Schultze", "Sülze", "Sültze", "Scholze", "Schalze", ""  
    Data.s "wr", "wer", "war", "wor", "wur", "weir", "wir", "wat", ""
    Data.s "Meier-Schulze", "Schulze-Meier", ""
    Data.s "Britney", "Spears", "Superzicke", ""
    Data.s "charta", "carta", "machen", "macen", ""
    Data.s "Lee", "Tee", "See", ""
    Data.s "%%"   ; End
  EndDataSection
 
CompilerEndIf

; für Silbenphonetik 
DataSection
  Data.s "ba", "be", "bi", "bo", "bu", "bai"   ; b, p
  Data.s "da", "de", "di", "do", "du", "dai"
  Data.s "ha", "he", "hi", "ho", "hu", "hai"
  Data.s "fa", "fe", "fi", "fo", "fu", "fai"   ; f, v
  Data.s "ka", "ke", "ki", "ko", "ku", "kai"   ; k
  Data.s "la", "le", "li", "lo", "lu", "lai"
  Data.s "ma", "me", "mi", "mo", "mu", "mai"
  Data.s "na", "ne", "ni", "no", "nu", "nai"
  Data.s "sa", "se", "si", "so", "su", "sai" ; s,c,z
  Data.s "tscha", "tsche", "tschi", "tscho", "tschu"
  Data.s "schta", "schte", "schti", "schto", "schtu", "schtai"
  Data.s "scha", "sche", "schi", "scho", "schu", "schai"
EndDataSection


; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 281
; FirstLine = 232
; Folding = --
; Optimizer
; CPU = 5