; Metaphone 3

;{
 ; Copyright 2010, Lawrence Philips
 ; All rights reserved.
  
 ; Redistribution and use in source and binary forms, with or without
 ; modification, are permitted provided that the following conditions are
 ; met:
  
 ;    * Redistributions of source code must retain the above copyright
 ; notice, this list of conditions and the following disclaimer.
 ;    * Redistributions in binary form must reproduce the above
 ; copyright notice, this list of conditions and the following disclaimer
 ; in the documentation and/or other materials provided with the
 ; distribution.
 ;    * Neither the name of Google Inc. nor the names of its
 ; contributors may be used to endorse or promote products derived from
 ; this software without specific prior written permission.
 
 ; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 ; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 ; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 ; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 ; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,           
 ; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY           
 ; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 ; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 ; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


 ;
 ; A request from the author: Please comment and sign any changes you make to 
 ; the Metaphone 3 reference implementation.
 ; 
 ; Please do NOT reformat this module to Refine's coding standard,
 ; but instead keep the original format so that it can be more easily compared
 ; to any modified fork of the original.
 ;/

 ;
 ; Metaphone 3
 ; VERSION 2.1.3
 ; 
 ; by Lawrence Philips
 ; 
 ; Metaphone 3 is designed to return an approximate phonetic key (and an
 ; alternate approximate phonetic key when appropriate) that should be the same
 ; for English words, and most names familiar in the United States, that are
 ; pronounced ;similarly;. The key value is ;not; intended to be an ;exact;
 ; phonetic, or even phonemic, representation of the word. This is because a
 ; certain degree of 'fuzziness' has proven to be useful in compensating for
 ; variations in pronunciation, as well as misheard pronunciations. For example,
 ; although americans are not usually aware of it, the letter 's' is normally
 ; pronounced 'z' at the end of words such as "sounds".
 ; 
 ; The 'approximate' aspect of the encoding is implemented according to the
 ; following rules:
 ; 
 ; (1) All vowels are encoded to the same value - 'A'. If the parameter
 ; encodeVowels is set to false, only *initial* vowels will be encoded at all.
 ; If encodeVowels is set to true, 'A' will be encoded at all places in the word
 ; that any vowels are normally pronounced. 'W' as well as 'Y' are treated as
 ; vowels. Although there are differences in the pronunciation of 'W' and 'Y' in
 ; different circumstances that lead to their being classified as vowels under
 ; some circumstances and as consonants in others, for the purposes of the
 ; 'fuzziness' component of the Soundex and Metaphone family of algorithms they
 ; will be always be treated here as vowels.
 ; 
 ;
 ; (2) Voiced and un-voiced consonant pairs are mapped to the same encoded
 ; value. This means that:
 ; 'D' and 'T' -> 'T'
 ; 'B' and 'P' -> 'P'
 ; 'G' and 'K' -> 'K'
 ; 'Z' and 'S' -> 'S'
 ; 'V' and 'F' -> 'F'
 ; 
 ;
 ; - In addition to the above voiced/unvoiced rules, 'CH' and 'SH' -> 'X', where
 ; 'X' represents the "-SH-" and "-CH-" sounds in Metaphone 3 encoding.
 ; 
 ;
 ; - Also, the sound that is spelled as "TH" in English is encoded to '0' (zero
 ; symbol). (Although Americans are not usually aware of it, "TH" is pronounced
 ; in a voiced (e.g. "that") as well as an unvoiced (e.g. "theater") form, which
 ; are naturally mapped to the same encoding.)
 ; 
 ; 
 ; The encodings in this version of Metaphone 3 are according to pronunciations
 ; common in the United States. This means that they will be inaccurate for
 ; consonant pronunciations that are different in the United Kingdom, for
 ; example "tube" -> "CHOOBE" -> XAP rather than american TAP.
 ; 
 ;
 ; Metaphone 3 was preceded by by Soundex, patented in 1919, and Metaphone and
 ; Double Metaphone, developed by Lawrence Philips. All of these algorithms
 ; resulted in a significant number of incorrect encodings. Metaphone3 was
 ; tested against a database of about 100 thousand English words, names common
 ; in the United States, and non-English words found in publications in the
 ; United States, with an emphasis on words that are commonly mispronounced,
 ; prepared by the Moby Words website, but with the Moby Words 'phonetic'
 ; encodings algorithmically mapped to Double Metaphone encodings. Metaphone3
 ; increases the accuracy of encoding of english words, common names, and
 ; non-English words found in american publications from the 89% for Double
 ; Metaphone, to over 98%.
 ; 
 ;
 ; DISCLAIMER: Anthropomorphic Software LLC claims only that Metaphone 3 will
 ; return correct encodings, within the 'fuzzy' definition of correct as above,
 ; for a very high percentage of correctly spelled English and commonly
 ; recognized non-English words. Anthropomorphic Software LLC warns the user
 ; that a number of words remain incorrectly encoded, that misspellings may not
 ; be encoded 'properly', and that people often have differing ideas about the
 ; pronunciation of a word. Therefore, Metaphone 3 is not guaranteed to return
 ; correct results every time, and so a desired target word may very well be
 ; missed. Creators of commercial products should keep in mind that systems like
 ; Metaphone 3 produce a 'best guess' result, and should condition the
 ; expectations of end users accordingly.
 ; 
 ;
 ; METAPHONE3 IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND. LAWRENCE PHILIPS
 ; AND ANTHROPOMORPHIC SOFTWARE LLC MAKE NO WARRANTIES, EXPRESS OR IMPLIED, THAT
 ; IT IS FREE OF ERROR, OR ARE CONSISTENT WITH ANY PARTICULAR STANDARD OF
 ; MERCHANTABILITY, OR THAT IT WILL MEET YOUR REQUIREMENTS FOR ANY PARTICULAR
 ; APPLICATION. LAWRENCE PHILIPS AND ANTHROPOMORPHIC SOFTWARE LLC DISCLAIM ALL
 ; LIABILITY FOR DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES RESULTING FROM USE
 ; OF THIS SOFTWARE.
 ;
;}       
 
DeclareModule MTF3
  EnableExplicit
  
  Declare.i EncodeMTF3(String$, xEncodeExact=#True)

EndDeclareModule

Module MTF3
  
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- Structures and Constants
  ;- ----------------------------------------------------------------------
  
  Structure TWord
    *str.String       ; String
    l.i               ; StringLength
  EndStructure
  
  Structure pChar     ; ATTENTION! Only use as Pointer Structure! Do not define as a normal Var!
    StructureUnion
      c.c[0]          ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
;       s1.s{1}[0]
;       s2.s{2}[0]
;       s3.s{3}[0]
;       s4.s{4}[0]
    EndStructureUnion
  EndStructure 
  
  Global vowel$ = "AEIOUYÀÁÂÃÄÅÆÈÉÊËÌÍÎÏÒÓÔÕÖØÙÚÛÜÝ"
   
  Global EncodeExact    ; Modul global EncodeExact
  Global idx, lastIdx   ; Index of current Character
  Global *pS.pChar      ; Pointer to StringStart
  Global *pC.pChar
  Global EncodeVowels
  Global lenIn
  
  ;  ----------------------------------------------------------------------
  ;- Macros
  ;- ----------------------------------------------------------------------
  
  Macro CInc(_pChar, _cnt=1)
    _pChar + _cnt*2
  EndMacro
  
  Macro _IsVowel(_CharValue)
    FindString(vowel$, Chr(_CharValue))    
  EndMacro
  
  Macro _IsVowelAt(_at)
    FindString(vowel$, Chr(*pS\c[idx+_at]))    
  EndMacro

  Macro _metaphAdd(_CHAR)
    
  EndMacro
  
  Macro _metaphAddAlt(_prim, second_)
    
  EndMacro
 
  Macro _metaphAddStr(_prim, _second)
    
  EndMacro
  
  Macro _metaphAddExactApprox(_eaxact, _main)
    If EncodeExact
      _metaphAddStr(_eaxact, _eaxact)  
    Else
      _metaphAddStr(_main, _main)  
    EndIf   
  EndMacro
  
  Macro _INC_idx(_cnt=1)
    idx + _cnt
    *pC = *pS + idx*2
  EndMacro
  
  Macro _advanceCounter(noEncodeVowel, encodeVowel)  
    If EncodeVowels 
      idx + encodeVowel
    Else
      idx + noEncodeVowel
    EndIf   
  EndMacro
  
  Macro _SkipDblChar()
    If *pS\c[idx] = *pS\c[idx+1]
      idx + 1  
    EndIf
  EndMacro
          
  Macro _SetCurentCharPointerTo(_at)
    *pC = *pS + (_at)*2  
  EndMacro
    
  ;- ----------------------------------------------------------------------
  ;- stringAt functions
  ;- ----------------------------------------------------------------------
  
  Macro _stringStart(_len, _str)
    CompareMemoryString(*pS, @_str, #PB_String_CaseSensitive, _len)
  EndMacro
  
  Macro _stringsStart(_len, _str)
    FindString(_str, PeekS(*pS, _len))   
  EndMacro  
  
  Macro _stringExact(_str)
    CompareMemoryString(*pS, @_str)    
  EndMacro
  
  Macro _stringsExact(_str)
    FindString(_str, PeekS(*pS))  
  EndMacro
  
  ; stringAt returns true if one of the given substrings is located at the
  ; relative offset (relative to current idx) given.  The vals must be given in order of
  ; length, shortest to longest, all caps.
  Procedure.i _stringAt(offset, _len, str$)
    Protected start = idx + offset
    
    ; basic bounds check on our start plus
    ; if our shortest input would make us run out of chars then none of our inputs could match
    If (start <0) Or (start => lenIn) Or ((start + _len)>lenIn) 
      ProcedureReturn #False    
    EndIf
    
    ProcedureReturn CompareMemoryString(*pS + start *2, @str$, #PB_String_CaseSensitive, _len)
  EndProcedure
  
  Procedure.i _stringsAt(offset, _len, str$)
    Protected start = idx + offset
    
    ; basic bounds check on our start plus
    ; if our shortest input would make us run out of chars then none of our inputs could match
    If (start <0) Or (start > lenIn) Or ((start + _len)>lenIn) 
      ProcedureReturn #False    
    EndIf
    
    ProcedureReturn FindString(str$, PeekS(*pS + start *2, _len))
  EndProcedure

  ; stringAtEnd returns true if one of the given substrings is located at the
  ; relative offset (relative to current idx) given and uses all the remaining
  ; letters of the input.  The vals must be given in order of length, shortest to longest, all caps.
  Procedure.i _stringAtEnd(offset, _len, str$)
    Protected start = idx + offset
    
    ; basic bounds check on our start plus
    ; if our shortest input would make us run out of chars then none of our inputs could match
    If (start <0) Or (start > lenIn) Or ((start + _len)>lenIn) 
      ProcedureReturn #False    
    EndIf
    
    ProcedureReturn CompareMemoryString(*pS + start *2, @str$, #PB_String_CaseSensitive)
  EndProcedure
  
  Procedure.i _stringsAtEnd(offset, _len, str$)
    Protected start = idx + offset
    
    ; basic bounds check on our start plus
    ; if our shortest input would make us run out of chars then none of our inputs could match
    If (start <0) Or (start > lenIn) Or ((start + _len)>lenIn) 
      ProcedureReturn #False    
    EndIf
    
    ProcedureReturn FindString(str$, PeekS(*pS + start *2))
  EndProcedure
  
  Procedure.i _stringEnd(_len, str$)
    Protected start = lastIdx - _len +1
    
    If (start <0) Or (start + _len)>lenIn 
      ProcedureReturn #False    
    EndIf
    
    CompareMemoryString(*pS + start *2, @str$, #PB_String_CaseSensitive, _len)
  EndProcedure
  
  Procedure.i _stringsEnd(_len, str$)
    Protected start = lastIdx - _len +1
    
    If (start <0) Or (start + _len)>lenIn 
      ProcedureReturn #False    
    EndIf
    
    ProcedureReturn FindString(str$, PeekS(*ps + start *2, _len))   
  EndProcedure
  
  Procedure.i _charAt(offset, _char.c)
    Protected pos = idx + offset
    
    If pos >= lenIn
      ProcedureReturn #False
    EndIf
      
    ProcedureReturn Bool(*pS\c[pos] = _char)
  EndProcedure
   
  ;- ----------------------------------------------------------------------
  ;- helper functions
  ;- ----------------------------------------------------------------------
  
  ; Tests whether the word is the root or a regular english inflection
  ; of it, e.g. "ache", "achy", "aches", "ached", "aching", "achingly"
  ; This is for cases where we want to match only the root and corresponding
  ; inflected forms, and not completely different words which may have the
  ; same substring in them.
  Procedure.i RootOrInflections(*inWord.pChar, root.s) 
    Protected lenDiff, last
    Protected *pRoot.pChar
    
    last = Len(root)
    lenDiff = MemoryStringLength(*inWord) - last
    
    If lendiff <0     ; if root is longer than inWord -> quit
      ProcedureReturn #False
    EndIf
    
    *pRoot = @root
    
    last-1
    
    ; check if the 2 Strings are equal until the second last char of root
    If Not CompareMemoryString(*inWord, @root, #PB_String_CaseSensitive, last)
      ProcedureReturn #False
    EndIf
    
    ; set the 2 Charpointer to the last Char of root, which is not compared until now
    CInc(*inWord, last)  ; Charpointer inkrement
    CInc(*inWord, last)
       
    ; at this point we know they start the same way
    ; except the last rune of root that we didn't check, so check that now
    ; check our last letter and simple plural
    
    If *inWord\c = *pRoot\c
      If lenDiff = 0
        ; exact match
        ProcedureReturn #True
      ElseIf lenDiff = 1 And *inWord\c[1] = 'S'
        ; match with extra S
        ProcedureReturn #True
      EndIf
    EndIf
    
    ; different paths if the last letter is 'E' or not
    If *pRoot\c = 'E'
      ; check ED
      If lenDiff = 1 And *inWord\c = 'E' And *inWord\c[1] = 'D'
        ProcedureReturn #True
      EndIf
      lenDiff + 1
    Else
      ; check +ES
      ; check +ED
      ; the last character must match if the root doesn't end in E
      If *inWord\c <> *pRoot\c
        ProcedureReturn #False
      EndIf
      
      If lenDiff = 2 And *inWord\c[1]='E' And (*inWord\c[2]='S' Or *inWord\c[2]='D')
        ProcedureReturn #True
      EndIf
      
      ; we know the last letter matches, so chop it off
      CInc(*inWord)
    EndIf
    
    ; at this point our root and inWord match, so now we're just checking the endings
    ; of the inWord starting at index "last"
    
    If lenDiff = 3 And CompareMemoryString(*inWord, @"ING", #PB_String_CaseSensitive, 3)
      ; check ING
      ProcedureReturn #True
    ElseIf lenDiff = 5 And CompareMemoryString(*inWord, @"INGLY", #PB_String_CaseSensitive, 5)
      ; check INGLY
      ProcedureReturn #True
    ElseIf lenDiff = 1 And *inWord\c = 'Y'
      ; check Y
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False      
  EndProcedure
  ; -------------------------------------------------- 
 
  Procedure.i SkipVowels(at)
    Protected.c it
    Protected.i off
    
    If at < 0
      ProcedureReturn 0
    ElseIf at > lenIn
      ProcedureReturn lenIn
    EndIf
    
    it = *pS\c[at]
    off = at - idx
    
    While _IsVowel(it) Or it ='W'
      If _stringsAt(off, 4, "WICZ,WITZ,WIAK") Or
         _stringsAt(off, 5, "EWSKI,EWSKY,OWSKI,OWSKY") Or  
         _stringsAt(off, 5, "WICKI,WACKI") 
        Break
      EndIf
      
      off +1
      
      If _charAt(off-1, 'W') And _charAt(off, 'H')
        ; And Not !e.stringAt(off, "HOP", "HIDE" ...
        If Not (_stringAt(off, 3, "HOP") Or 
                _stringsAt(off, 4, "HIDE,HARD,HEAD,HAWK,HERD,HOOK,HAND,HOLE") Or
                _stringsAt(off, 5, "HEART,HOUSE,HOUND") Or
                _stringsAt(off, 5, "HEART,HOUSE,HOUND") Or
                _stringAt(off, 6, "HAMMER"))
          off +1
        EndIf
      
        If idx + off > lastIdx
          Break
        EndIf
        it = *pS\c[idx + off] 
      EndIf
    Wend
    
    ProcedureReturn idx+off-1
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure IsSlavoGermanic()
    If _stringStart(3, "SCH") Or _stringStart(2, "SW") Or *pS\c[0] = 'J' Or *pS\c[0] = 'W' 
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  ;- ----------------------------------------------------------------------     
  Procedure Encode_SilentB()
    ; Silent B : debt, doubt, dubtle
    If _stringAt(-2, 4, "DEBT") Or
       _stringAt(-2, 5, "SUBTL") Or
       _stringAt(-3, 5, "DOUBT")
      
      _metaphAdd('T')
      _INC_idx()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  ;- -------------------------------------------------- 
  ;-Encode B
  ; -------------------------------------------------- 
  Procedure Encode_B()    
    Protected match = #True
    
    If Encode_SilentB()
      ProcedureReturn
    EndIf
    
    ; "-mb", e.g, "dumb", already skipped over under
    ; 'M', altho it should really be handled here...
    
    _metaphAddExactApprox("B", "P")
    
    ; skip double B, or BPx where X isn't H
    If *pC\c[1] = 'B' Or *pC\c[1] = 'P'
      If (idx + 2) < lenIn And *pC\c[2]='H'
        _INC_idx()
      EndIf
    EndIf
    
  EndProcedure
  
  ;- -------------------------------------------------- 
  ;-Encode C
  ; -------------------------------------------------- 
  
  Procedure.i Encode_CaToS()
   	; Special case: 'caesar'.
  	; Also, where cedilla not used, as in "linguica" => LNKS   
    If idx = 0      ; Start of String ?
      If _stringsAt(0, 4, "CAES,CAEC,CAEM") Or
         _stringStart(6, "FACADE") Or
         _stringsStart(8, "FRANCAIS,FRANCAIX,LINGUICA") Or
         _stringsStart(9, "GONCALVES,PROVENCAL")
        
        _metaphAdd('S')
        _advanceCounter(1, 0)
        ProcedureReturn #True  
      EndIf
    EndIf
    ProcedureReturn #False          
  EndProcedure 
  ; -------------------------------------------------- 
 
  Procedure.i Encode_CoToS()
     
    If (_stringAt(0, 4, "COEL") And _IsVowelAt(4)) Or
       (idx+3 = lastIdx) Or
       _stringsAt(0, 5, "COENA,COENO") Or
       _stringStart(6, "GARCON") Or
       _stringsStart(8, "FRANCOIS,MELANCON")                
      
      _metaphAdd('S')
      _advanceCounter(2, 0)
      ProcedureReturn #True  
    EndIf
    ProcedureReturn #False  
  EndProcedure
  ; -------------------------------------------------- 
 
  ; Encodes reliably italian "-CCIA-"
  Procedure.i Encode_Ccia()
    Protected match = #True
    ; e.g., 'focaccia'
    If _stringAt(-1, 3, "CIA")
      _metaphAddAlt('X', 'S')
      _INC_idx()
      ProcedureReturn #True
    EndIf  
    ProcedureReturn #False 
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_Cc()
    Protected match = #True
    ; double 'C', but not if e.g. 'McClellan'
    If _stringAt(0, 2, "CC") And Not (idx=1 And *pS\c ='M')
      ; exception
      If _stringAt(-3, 7, "FLACCID")
        _metaphAdd('S')
        _advanceCounter(2 ,1)
        ProcedureReturn #True
      EndIf
      
      ; 'bacci', 'bertucci', other italian
      If _stringAtEnd(2, 1, "I") Or
         _stringAtEnd(2, 2, "IO") Or
         _stringsAtEnd(2, 3, "INO,INI")
         
         _metaphAdd('X')
        _advanceCounter(2, 1)
        ProcedureReturn #True
      EndIf
  
      ; 'accident', 'accede' 'succeed'
      If _stringsAt(2, 1, "I,E,Y")
        ; except 'bellocchio','bacchus', 'soccer' get K
        If Not _charAt(2, 'H') And _stringAt(2, 6, "SOCCER")
          _metaphAddStr("KS", "KS")
          _advanceCounter(2, 1)
          ProcedureReturn #True
        EndIf
      EndIf
      ; Pierce's rule
      _metaphAdd('K')
      _INC_idx()   
      ProcedureReturn #True  
    EndIf
    
    ProcedureReturn #False 
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_CkCgCq()
    If _stringsAt(0, 2, "CK,CG,CQ")
      ; eastern european spelling e.g. 'gorecki' == 'goresky'
      If lenIn > 6
        If _stringsAtEnd(0, 3, "CKI,CKY")
          _metaphAddStr("K", "SK")
        Else
          _metaphAdd('K')
        EndIf
        _INC_idx()
        ; if there's a C[KGQ][KGQ] then skip that second one too
        If _stringsAt(1, 1, "K,G,Q")
          _INC_idx()
        EndIf
        ProcedureReturn #True
      EndIf  
    EndIf
    ProcedureReturn #False 
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_BritishSilentCE()
    ; english place names like e.g.'gloucester' pronounced glo-ster
    If _stringAtEnd(1, 5, "ESTER") Or
       _stringAt(1, 10, "ESTERSHIRE")
      
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
    
  Procedure.i Encode_Ce()
    ; 'ocean', 'commercial', 'provincial', 'cello', 'fettucini', 'medici'
    If (_stringAt(1, 4, "EAN") And _IsVowelAt(-1)) Or
       (_stringAt(-1, 4, "ACEA") And _stringStart(7, "PANACEA")) Or
       _stringsAt(1, 4, "ELLI,ERTO,EORL") Or
       _stringAtEnd(-3, 5, "CROCE") Or
       _stringAtEnd(-3, 5, "DOLCE") Or
       _stringAtEnd(1, 4, "ELLO")
      
      _metaphAddAlt('X', 'S')  
      ProcedureReturn #True  
    EndIf
    ProcedureReturn #False  
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure Encode_Ci()
    ; with consonant before C
    ; e.g. 'fettucini', but exception for the americanized pronunciation of 'mancini'
    
    If (_stringAtEnd(1, 3, "INI") And Not _stringExact("MANCINI")) Or
       _stringAtEnd(-1, 3, "ICI") Or 
       _stringsAt(-1, 5, "RCIAL,NCIAL,RCIAN,UCIUS") Or
       _stringAt(-3, 6, "MARCIA") Or
       _stringAt(-2, 7, "ANCIENT")
      
      ProcedureReturn #True
    EndIf
    
    ; exception
    If _stringAt(-4, 8, "COERCION")
      _metaphAdd('J')
      ProcedureReturn #True
    EndIf
    
    ; with vowel before C (or at beginning?)
    If (_stringsAt(0, 3, "CIO,CIE,CIA") And _IsVowelAt(-1)) Or
       _stringAt(1, 3, "IAO")
      
      If _stringsAt(0, 4, "CIAN,CIAL,CIAO,CIES,CIOL,CION") Or
         _stringAt(-3, 7, "GLACIER") Or
         _stringsAt(0, 5, "CIENT,CIENC,CIOUS,CIATE,CIATI,CIATO,CIABL,CIARY") Or
         _stringsAtEnd(0, 4, "CIA,CIO") Or
         _stringsAtEnd(0, 5, "CIAS, CIOS")
        
        ; AND NOT: !(stringAt(-4, "ASSOCIATION") || e.stringStart("OCIE")
        If _stringAt(-4, 11, "ASSOCIATION") Or
           _stringStart(4, "OCIE") Or
           _stringsAt (-2, 5, "LUCIO,SOCIO,SOCIE") Or
           _stringAt(-2, 6, "MACIAS") Or
           _stringAt(-2, 7, "LUCIANO") Or
           _stringAt(-2, 8, "HACIENDA") Or
           _stringsAt (-3, 6, "GRACIE,GRACIA") Or
           _stringAt(-3, 8, "MARCIANO") Or
           _stringAt(-4, 7, "PALACIO") Or
           _stringAt(-4, 8, "POLICIES") Or
           _stringAt(-4, 9, "FELICIANO") Or
           _stringAt(-5, 8, "MAURICIO") Or
           _stringAt(-6, 9, "ANDALUCIA") Or
           _stringAt(-7, 11, "ENCARNACION")
        Else
          _metaphAddAlt('X', 'S') ; at Else Path because it is a Not operation
        EndIf
        
      Else
        _metaphAddAlt('S', 'X')
      EndIf
      ProcedureReturn #True
    EndIf   
    ProcedureReturn #False  
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure Encode_LatinateSuffixes()
    If _stringsAt(1, 4, "EOUS,IOUS")
      _metaphAddAlt('X', 'S')
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
  
   Procedure.i Encode_CFrontVowel()
    If _stringsAt(0, 2, "CI,CE,CY")
      If Encode_BritishSilentCE() Or
         Encode_Ce() Or
         Encode_Ci() Or
         Encode_LatinateSuffixes()
        
        _advanceCounter(1, 0)
        ProcedureReturn #True
      EndIf
      _metaphAdd('S')
		  _advanceCounter(1, 0)
		  ProcedureReturn #True  
    EndIf
    
    ProcedureReturn #False 
  EndProcedure
  ; --------------------------------------------------   
 
  Procedure.i Encode_SilentCAtBeginning()
    If idx =0 
      If _stringsAt(0, 2, "CT,CN")
        ProcedureReturn #True
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
 
  Procedure Encode_SilentC()
    If _stringsAt(1, 1, "T,S") And
       (_stringsStart(6, "INDICT,TUCSON") Or _stringStart(11, "CONNECTICUT"))
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False   
  EndProcedure
  ; -------------------------------------------------- 
  
  ; Encodes slavic spellings or transliterations
  ; written as "-CZ-"
  Procedure Encode_Cz()
    If _stringAt(1, 1, "Z") And Not _stringAt(-1, 6, "ECZEMA")
      If _stringAt(0, 4, "CZAR")
        _metaphAdd('S')
      Else
        ; otherwise most likely a czech word...
        _metaphAdd('X')
      EndIf 
      _INC_idx()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False    
  EndProcedure
  ; -------------------------------------------------- 
 
  Procedure Encode_Cs()
    ; give an 'etymological' 2nd
    ; encoding for "kovacs" so that it matches "kovach"
    
    If _stringStart(6, "KOVACS")
      _metaphAddStr("KS", "X")
      _INC_idx()
      ProcedureReturn #True
    EndIf
    
    If _stringAtEnd(-1, 3, "ACS") And Not _stringAtEnd(-4, 6, "ISAACS")
      _metaphAdd('X')
      _INC_idx()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  ; -------------------------------------------------- 
   
  Procedure.i Encode_Chae()
    ; e.g. 'michael'   
    If idx >0 And _stringAt(2, 2, "AE")
      If _stringStart(7, "RACHAEL")
        _metaphAdd('X')
      ElseIf _stringsAt(-1, 1, "C,K,G,Q")
        _metaphAdd('K')  
      EndIf
      _advanceCounter(3, 1)
      ProcedureReturn #True      
    EndIf   
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
 
  ; Encodes transliterations from the hebrew where the
  ; sound 'kh' is represented as "-CH-". The normal pronounciation
  ; of this in english is either 'h' or 'kh', and alternate
  ; spellings most often use "-H-"
  Procedure.i Encode_ChToH()
    ; hebrew => 'H', e.g. 'channukah', 'chabad'
    If idx=0
      If _stringsAt(2, 3, "AIM,ETH,ELM") Or
         _stringsAt(2, 3, "ASID, AZAN") Or
         _stringsAt(2, 5, "UPPAH,UTZPA,ALLAH,ALUTZ,AMETZ") Or       
         _stringsAt(2, 6, "ESHVAN,ADARIM,ANUKAH") Or       
         _stringsAt(2, 7, "ALLLOTH,ANNUKAH,AROSETH") Or
         _stringAt (-3, 7, "CLACHAN") 
        
        _metaphAdd('H')
        _advanceCounter(2, 1)
        ProcedureReturn #True  
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
 
  Procedure Encode_SilentCh()
    Protected match = #True
    
    If _stringAt(-2, 5, "YACHT") Or
       _stringAt(-2, 7, "FUCHSIA") Or
       _stringsStart(8, "STRACHAN,CRICHTON") Or
       (_stringAt(-3, 6, "DRACHM") And Not _stringAt(-3, 7, "DRACHMA"))
      
      _INC_idx()
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False    
  EndProcedure
  ; -------------------------------------------------- 
 
  Procedure Encode_ChToX()
     
    ; e.g. 'approach', 'beach'
   
    If (_stringsAt(-2, 4, "OACH,EACH,EECH,OUCH,OOCH,MUCH,SUCH") And Not _stringAt(-3, 6, "JOACH")) Or
       _stringsAtEnd(-1, 4, "ACHA,ACHO") Or
       _stringsAtEnd(0, 4, "CHOT,CHOD,CHAT") Or
       (_stringAtEnd(-1, 4, "OCHE") And Not _stringAt(-2, 5, "DOCHE")) Or
       _stringsAt(-4, 6, "ATTACH,DETACH,KOVACH") Or
       _stringAt (-5, 6, "SPINACH") Or
       _stringAt (-5, 7, "MASSACHU") Or
       _stringStart(6, "MACHAU") Or
       (_stringAt(-3, 5, "THACH") And Not _stringAt(2, 1, "E")) Or
       _stringAt (-1, 6, "VACHON")
      
       _metaphAdd('X')
      _INC_idx()
      ProcedureReturn #True
    EndIf   
    ProcedureReturn #False  
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure Encode_EnglishChToK()
    Protected match = #True
    
    ; 'ache', 'echo', alternate spelling of 'michael' 
    If (idx =1 And RootOrInflections(*pS, "ACHE")) Or
        idx =3 And RootOrInflections(*pS +(idx-1)*2, "ACHE") And
        (_stringStart(3, "EAR") Or _stringsStart(4, "HEAD,BACK") Or _stringsStart(5, "HEART,BELLY,TOOTH")) Or
        _stringAt(-1, 4, "ECHO") Or
        _stringAt(-2, 7, "MICHEAL") Or
        _stringAt(-2, 7, "JERICHO") Or
        _stringAt(-2, 7, "LEPRECH")
        
      _metaphAddAlt('K', 'X')
      _INC_idx()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False           
  EndProcedure
  ; -------------------------------------------------- 
  
  ; Encode "-ARCH-". Some occurances are from greek roots and therefore encode
  ; to 'K', others are from english words and therefore encode to 'X'
  Procedure Encode_Arch()
    Protected match
    
    If _stringAt(-2, 4, "ARCH")
      ; "-ARCH-" has many combining forms where "-CH-" => K because of its
      ; derivation from the greek
      If _stringsAt(2, 1, "A,I,O,U,Y") Or   
         _stringsAt(2, 2, "EA,EG,EO,ET,EL,ES,EP,EM,EN") Or
         _stringAtEnd(-2, 4, "ARCH") Or _stringStart(7, "MENARCH") And 
         (Not RootOrInflections(*pS, "ARCH") And 
          Not _stringsAt(-4, 6, "SEARCH,POARCH") And
          Not (_stringsStart(6, "ARCHER,ARCHIE") Or _stringsStart(9, "ARCHENEMY,ARCHIBALD,ARCHULETA,ARCHAMBAU")) And
          Not((((_stringsAt(-3, 4, "LARCH,MARCH,PARCH") Or 
                 _stringAt (-4, 6, "STARCH")) And
                Not (_stringStart(6, "EPARCH") Or _stringStart(7, "NOMARCH") Or 
                     _stringsStart(8, "EXILARCH,HIPPARCH,MARCHESE") Or 
                     _stringStart(9, "ARISTARCH,MARCHETTI"))) Or
                RootOrInflections(*pS, "STARCH")) And 
                (Not _stringsAt(-2, 5, "ARCHU,ARCHY") Or _stringStart(7, "STARCHY"))))
             
          match = #True   
      EndIf               
       
      If match 
        _metaphAddAlt('K', 'X')
      Else
        _metaphAdd('X')
      EndIf
      
      _INC_idx(2)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_GermanicChToK()    
    Protected match = #True
    ; various germanic
    ; "<consonant><vowel>CH-"implies a german word where 'ch' => K    
    If idx > 1 And _IsVowelAt(-2) And _stringAt(-1, 3, "ACH") And
       _stringsAt(-2, 7, "MACHADO,MACHUCA,LACHANC,LACHAPE,KACHATU") And
       _stringAt(-3, 7, "KHACHAT") And
       (Not _charAt(2, 'I') And Not _charAt(2, 'E') Or
        _stringsAt(-2, 6, "BACHER,MACHER,MACHEN,LACHER"))
      
    ; e.g. 'brecht', 'fuchs' 
    ElseIf _stringsAt(2, 1, "T,S") And Not _stringStart(9, "LUNCHTIME") And Not _stringStart(11, "WHICHSOEVER")
    ElseIf _stringStart(4, "SCHR")
    ElseIf idx > 2 And _stringAt(-2, 5, "MACHE")
    ElseIf idx = 2 And _stringAt(-2, 4, "ZACH")
    ElseIf _stringAt(-4, 6, "SCHACH")
    ElseIf _stringAt(-1, 5, "ACHEN")
    ElseIf _stringAt(-3, 5, "SPICH,ZURCH,BUECH")
    ElseIf _stringAt(-3, 5, "KIRCH,JOACH,BLECH,MALCH") And (Not _stringAt(-3, 8, "KIRCHNER") Or idx +1 = lastIdx)
    ElseIf _stringAtEnd(-2, 4, "NICH,LICH,BACH")
    ElseIf _stringAtEnd(-3, 5, "URICH,BRICH,ERICH,DRICH,NRICH") And 
           Not _stringAtEnd(-5, 7, "ALDRICH") And 
           Not _stringAtEnd(-6, 8, "GOODRICH") And
           Not _stringAtEnd(-7, 9, "GINGERICH")
    ElseIf _stringAtEnd(-4, 6, "ULRICH,LFRICH,LLRICH,EMRICH,ZURICH,EYRICH")
      
    ; e.g., 'wachtler', 'wechsler', but not 'tichner' 
    ElseIf (_stringAt(-1, 1, "A,O,U,E") Or idx=0) And _stringAt(2, 1, "L,R,N,M,B,H,F,V,W")
    Else
      match = #False
    EndIf   
      
    If match 
      ; "CHR/L-" e.g. 'chris' do not get
      ; alt pronunciation of 'X'
      If _stringsAt(2, 1, "R,L") Or isSlavoGermanic()
        _metaphAdd('K')
      Else
        _metaphAddAlt('K', 'X')
      EndIf
      _INC_idx()
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False  
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure Encode_GreekCHInitial()
    ; greek roots e.g. 'chemistry', 'chorus', ch at beginning of root
    If (_stringsAt(0, 6, "CHAMOM,CHARAC,CHARIS,CHARTO,CHARTU,CHARYB,CHRIST,CHEMIC,CHILIA") Or
        _stringsAt(0, 5, "CHEMI,CHEMO,CHEMU,CHEMY,CHOND,CHONA,CHONI,CHOIR,CHASM,CHARO,CHROM,CHROI,CHAMA,CHALC,CHALD,CHAET,CHIRO,CHILO,CHELA,CHOUS,CHEIL,CHEIR,CHEIM,CHITI,CHEOP") And
        Not (_stringAt(0, 6, "CHEMIN") Or _stringAt(-2, 8, "ANCHONDO"))) Or
        _stringsAt(0, 5, "CHISM,CHELI") And
        Not (_stringStart(6, "MICHEL") Or _stringStart(8, "MACHISMO") Or _stringsStart(9, "RICHELIEU") Or _stringsStart(10, "REVANCHISM") Or 
            _stringExact("CHISM"))) Or 
       _stringsAt(0, 4, "CHOR,CHOL,CHYM,CHYL,CHLO,CHOS,CHUS,CHOE") And Not _stringsStart(6, "CHOLLO,CHOLLA,CHORIZ")) Or 
       _stringAt (0, 4, "CHAO") And idx +3 = lastIdx) Or
       _stringAt (0, 4, "CHIA") And Not (_stringStart(7,"CHIAPAS") Or _stringStart(10,"APPALACHIA"))) Or   
       _stringsAt(0, 7, "CHIMERA,CHIMAER,CHIMERI") Or
       _stringsStart(5, "CHAME,CHELO,CHITO") Or
       ((idx+4=lastIdx Or idx+5 = lastIdx) And _stringAt(-1, 6, "OCHETE"))) And
       Not (_stringsExact("CHORE,CHOLO,CHOLA") Or
            _stringsAt(0, 5, "CHORT,CHOSE") Or
            _stringAt(-3, 7, "CROCHET") Or      
            _stringsStart(7, "CHEMISE,CHARISE,CHARISS,CHAROLE"))        
      
      If _stringsAt(2, 1, "R,L")
        _metaphAdd('K'
      Else
        _metaphAddAlt('K', 'X')
      EndIf
      _INC_idx(
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_CH()
    Protected match = #True
    
    If Not _stringAt(0, 2, "CH")
      ProcedureReturn #False
    EndIf
    
    If     Encode_Chae()
    ElseIf Encode_ChToH()
    ElseIf Encode_SilentCh() 
    ElseIf Encode_Arch() 
    ElseIf Encode_ChToX() 
    ElseIf Encode_EnglishChToK() 
    ElseIf Encode_GermanicChToK()
    ElseIf Encode_GreekChInitial()    
    ElseIf Encode_GreekChNonInitial()
    Else
      match =#False
    EndIf
    
    If match
      ProcedureReturn #True
    EndIf
    
    If idx > 0 
      If _stringsStart(2, "MC") And idx =1
        ; e.g., "McHugh"
        _metaphAdd('K')
      Else
        _metaphAddAlt('X', 'K')
      EndIf
    Else
      _metaphAdd('X')
    EndIf
    
    _INC_idx()
    ProcedureReturn #True
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure Encode_C()
    Protected match = #True
    
    If     Encode_SilentCAtBeginning()  
    ElseIf Encode_CaToS()
    ElseIf Encode_CoToS()
    ElseIf Encode_Ch()
    ElseIf Encode_Ccia() 
    ElseIf Encode_Cc()
    ElseIf Encode_CkCgCq()
    ElseIf Encode_CFrontVowel()
    ElseIf Encode_SilentC()
    ElseIf Encode_Cz()
    ElseIf Encode_Cs()
    Else
      match = #False
    EndIf
    
    If match 
      ProcedureReturn
    EndIf
    
    If _stringsAt(-1, 1, "C,K,G,Q")
      _metaphAdd('K')
    EndIf
    
    ; name sent in 'mac caffrey', 'mac gregor      
    If _stringsAt(1, 2, " C, K, G, Q")
      _INC_idx()
    Else
      If _stringsAt(1, 1, "C,K,Q") 
        If Not _stringsAt(1, 2, "CE,CI")
          _INC_idx() ;increment 1 here, so adjust offsets below
          ; account for combinations such as Ro-ckc-liffe
          If Not _stringsAt(2, 2, "CE,CI")
            _INC_idx()  
          EndIf
        EndIf
      EndIf
    EndIf
        
  EndProcedure
  
  ;- -------------------------------------------------- 
  ;-Encode D
  ; -------------------------------------------------- 
  
  Procedure.i Encode_Dg()
    
    If _stringAt(0, 2, "DG")
      ; excludes exceptions e.g. 'edgar',
      ; or cases where 'g' is first letter of combining form
      ; e.g. 'handgun', 'waldglas'
      If _stringsAt(2, 1, "A,O") Or
         _stringsAt(2, 3, "GUN,GUT") Or
         _stringsAt(2, 4, "GEAR,GLAS,GRIP,GREN,GILL,GRAF") Or
         _stringsAt(2, 5, "GUARD,GUILT,GRAVE,GRASS") Or
         _stringAt (2, 6, "GROUSE"") 
        ; e.g. "midgut", "handgrip", "mudgard", "woodgrouse"
        _metaphAddExactApprox("DG, "TK")
      Else
        _metaphAdd('J')
      EndIf
      _INC_idx()
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_Dj()
    ; e.g. "adjacent"
    If _stringAt(0, "DJ")
      _metaphAdd('J')
      _INC_idx()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  ; -------------------------------------------------- 

  Procedure.i Encode_DtDd()
    ; eat redundant 'T' Or 'D'
    If _stringsAt(0, 2, "DT,DD")
      If _stringAt(0, 3, "DTH")
        _metaphAddExactApprox("DO,TO"=
        _INC_idx(2)
      Else
        If EncodeExact
          ; devoice it
          If _stringAt(0, 2, "DT")
            _metaphAdd('T')
          Else
            _metaphAdd('D')
          EndIf
        Else
          _metaphAdd('T')
        EndIf
        _INC_idx()
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #True
  EndProcedure
  ; -------------------------------------------------- 
 
  Procedure.i Encode_DToJ()
    ; e.g. "module", "adulate"
    If (_stringAt(0,3,"DUL") And _IsVowelAt(-1) And _IsVowelAt(3)) Or
       _stringsAtEnd(-1,5, "LDIER,NDEUR,EDURE,RDURE") Or
       _stringAt(-3,7,"CORDIAL") Or
       _stringsAt(-1,4,"ADUA,IDUA,IDUU") Or
       _stringsAt(-1,4,"NDULA,NDULU,EDUCA")
       
      _metaphAddExactApproxAlt("J", "D", "J", "T")
      _advanceCounter(1,0)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
 
  Procedure.i Encode_Dous()
     ; e.g. "assiduous", "arduous"
    If _stringAt(1,"UOUS")
      _metaphAddExactApproxAlt("J", "D", "J", "T")
      _advanceCounter(3,0)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
 
  Procedure.i Encode_SilentD()
    ; silent 'D' e.g. 'wednesday', 'handsome'
    If _stringAt(-2,9, "WEDNESDAY") Or
       _stringsAt(-3,7, "HANDKER,HANDSOM,WINDSOR") Or 
       _stringsEnd(6, "PERNOD", "ARTAUD", "RENAUD") Or 
       _stringsEnd(7, "RIMBAUD", "MICHAUD", "BICHAUD")
      
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 

  Procedure Encode_D()
    Protected match = #True
    
    If     Encode_Dg()
    ElseIf Encode_Dj()
    ElseIf Encode_DtDd()
    ElseIf Encode_DToJ()
    ElseIf Encode_Dous()
    ElseIf Encode_SilentD()
    Else
      match = #False  
    EndIf
    
    If match
      ProcedureReturn
    EndIf
    
    If EncodeExact
      ; "final de-voicing" in this case
      ; e.g. 'missed' == 'mist'
      If _stringAtEnd(-3, 4, "SSED")
        _metaphAdd('T')
      Else
        _metaphAdd('D')
      EndIf
    Else
      _metaphAdd('T')
    EndIf
      
  EndProcedure
  
  ;- -------------------------------------------------- 
  ;-Encode F
  ; -------------------------------------------------- 
  Procedure Encode_F()
    
    Protected match
    
    If _stringAt(-1, 5, "OFTEN")
      _metaphAddStr("F", "FT")
      _INC_idx()
      ProcedureReturn
    EndIf          
    
    _SkipDblChar()
    _metaphAdd('F')
    
  EndProcedure
  
  ; -------------------------------------------------- 
  ;-Encode G
  ; -------------------------------------------------- 
  
  Procedure.i Encode_SilentGAtBeginning()
    ProcedureReturn _stringsStart(0, "GN")   
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure Encode_Gg()
    If _charAt(1,'G')
      ; italian e.g, 'loggia', 'caraveggio', also 'suggest' and 'exaggerate'
      If _stringsAt(-1,5, "AGGIA,OGGIA,AGGIO,EGGIO,EGGIA,IGGIO"= Or
        (_stringAt(-1,5, "UGGI") And Not (idx+3 = lastIdx Or idx+4=lastIdx)) Or
        _stringsAtEnd(-1,4, "AGGI,OGGI") Or
        _stringsAt(-2,6, "SUGGES,XAGGER,REGGIE")                   
        
        ; expection where "-GG-" => KJ
        If _stringAt(-2,7, "SUGGEST")
          _metaphAddExactApprox("G", "K")
        EndIf
        _metaphAdd('J')
        _advanceCounter(2,1)
      Else
        _metaphAddExactApprox("G", "K")
        _INC_idx()
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_GK()
    ; 'gingko'
    If _charAt(1, 'K')
      _metaphAdd('K')
      _INC_idx()
      ProcedureReturn #True
    EndIf
    Procedurer #False 
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_GhAfterConsonant()
  	; e.g. 'burgher', 'bingham'
  	If idx > 0 And Not  _isVowelAt(-1) And Not _stringAtEnd(-3,5,"HALGH") 
  		; Not e.g. 'greenhalgh'
  		
  		_metaphAddExactApprox("G", "K")
  		_INC_idx()
  		ProcedureReturn #True
  	EndIf
	  ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 

  Procedure.i Encode_InitialGh()
	  If idx = 0 
		  ; e.g. "ghislane", "ghiradelli"
		  If _charAt(2, 'I') 
			  _metaphAdd('J')
		  Else {
			  _metaphAddExactApprox("G", "K")
		  EndIf
		  _INC_idx()
		  ProcedureReturn #True
	  EndIf
	  ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_GhToJ()
	  ; e.g., 'greenhalgh', 'dunkenhalgh', english names
	  If _stringAtEnd(-2,4, "ALGH")
		  _metaphAddAlt('J', '')
		  _INC_idx()
		  ProcedureReturn #True
	  EndIf
	  ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_GhToH()
	  ; special cases
	  ; e.g., 'donoghue', 'donaghy'
    If (_stringsAt(-4,4, "DONO,DONA") And _isVowelAt(2)) Or
       _stringAt(-5,9, "CALLAGHAN")
      
		  _metaphAdd('H')
		  _INC_idx()
		  ProcedureReturn #True
	  EndIf
	  ProcedureReturn #False
  EndProcedure
  ; -------------------------------------------------- 

  Procedure Encode_Gh()
    Protected match = #True
    
    If _charAt(1, 'H')
      If     Encode_GhAfterConsonant()
      ElseIf Encode_InitialGh()
      ElseIf Encode_GhToJ()
      ElseIf Encode_GhToH()
      ElseIf Encode_Ught()
      ElseIf Encode_GhHPartOfOtherWord()
      ElseIf Encode_SilentGh()
      ElseIf Encode_GhToF()
      Else
        match = #False  
      EndIf
      
      If match 
        ProcedureReturn
      EndIf
      
      _metaphAddExactApprox("G", "K")
      _INC_idx()
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  ; -------------------------------------------------- 
  
  Procedure.i Encode_Ger()
  ; Only check if we are past the first character
  If idx > 0 And _stringsAt(1, 2, "ER")
    
    ; Complex exceptions list
    If ((idx = 2 And _isVowelAt(-1) And Not _isVowelAt(-2) And
         Not _stringsAt(-2, 5, "PAGER,WAGER,NIGER,ROGER,LEGER,CAGER") Or
         _stringsAt(-2, 4, "AUGER,EAGER,INGER,YAGER")) Or
        _stringsAt(-3, 6, "SEEGER,JAEGER,GEIGER,KRUGER,SAUGER,BURGER,MEAGER,MARGER,RIEGER,YAEGER,STEGER,PRAGER,SWIGER,YERGER,TORGER,FERGER,HILGER,ZEIGER,YARGER,COWGER,CREGER,KROGER,KREGER,GRAGER,STIGER,BERGER")) Or
        _stringsAtEnd(-3, 6, "BERGER") Or
        _stringsAt(-4, 6, "KREIGER,KRUEGER,METZGER,KRIEGER,KROEGER,STEIGER,DRAEGER,BUERGER,BOERGER,FIBIGER")) Or
        (_stringsAt(-3, 6, "BARGER") And idx > 4) Or
        (_stringsAt(0, 6, "GERBER") And idx > 0) Or
        _stringsAt(-5, 8, "SCHWAGER,LYBARGER,SPRENGER,GALLAGER,WILLIGER") Or
        _stringsStart(6, "HARGER") Or
        _stringsExact(4, "AGER,EGER") Or
        _stringsAt(-1, 6, "YGERNE") Or
        _stringsAt(-6, 9, "SCHWEIGER")) And
        Not (_stringsAt(-5, 10, "BELLIGEREN") Or _stringsStart(7, "MARGERY") Or _stringsAt(-3, 8, "BERGERAC"))
      
      ; Slavo-Germanic branch
      If _isSlavoGermanic()
        _metaphAddExactApprox("G", "K")
      Else
        _metaphAddExactApproxAlt("G", "J", "K", "J")
      EndIf
    Else
      _metaphAddExactApproxAlt("J", "G", "J", "K")
    EndIf

    _advanceCounter(1, 0)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure
  Procedure Encode_G()
     
   
  EndProcedure
  ; -------------------------------------------------- 
  
  ;-Encode H
  Procedure Encode_H()
    
    
  EndProcedure
  
  ;- -------------------------------------------------- 
  ;-Encode J
  
  
  Procedure namesBeginningWithJThatGetAltY()
    Protected match
    Protected txt$
    
    Restore _J
    Repeat
      Read.s txt$  
      If txt$ = #EOT$
        Break
      EndIf  
      match = CompareMemoryString(*pS, @txt$)
    Until match
    ProcedureReturn match
  
    DataSection
      _J:
      Data.s "JAN", "JON", "JUN", "JIN", "JEN"
      Data.s "JUHL", "JULY", "JOEL", "JOHN", "JOSH", "JUDE", "JUNE", "JONI", "JULI", "JENA"
      Data.s "JUNG", "JINA", "JANA", "JENI", "JOEL", "JANN", "JONA", "JENE", "JULE", "JANI", "JONG", "JOHN"
     	Data.s "JEAN", "JUNG", "JONE", "JARA", "JUST", "JOST", "JAHN", "JACO", "JANG", "JUDE", "JONE"
    	Data.s "JOANN", "JANEY", "JANAE", "JOANA", "JUTTA", "JULEE", "JANAY", "JANEE", "JETTA"
     	Data.s "JOHNA", "JOANE", "JAYNA", "JANES", "JONAS", "JONIE", "JUSTA", "JUNIE", "JUNKO", "JENAE"
    	Data.s "JULIO", "JINNY", "JOHNS", "JACOB", "JETER", "JAFFE", "JESKE", "JANKE", "JAGER", "JANIK"
    	Data.s "JANDA", "JOSHI", "JULES", "JANTZ", "JEANS", "JUDAH", "JANUS", "JENNY", "JENEE", "JONAH"
    	Data.s "JONAS", "JACOB", "JOSUE", "JOSEF", "JULES", "JULIE", "JULIA", "JANIE", "JANIS", "JENNA"
    	Data.s "JANNA", "JEANA", "JENNI", "JEANE", "JONNA", "JAKOB"
    	Data.s "JORDAN", "JORDON", "JOSEPH", "JOSHUA", "JOSIAH", "JOSPEH", "JUDSON", "JULIAN"
    	Data.s "JULIUS", "JUNIOR", "JUDITH", "JOESPH", "JOHNIE", "JOANNE", "JEANNE", "JOANNA", "JOSEFA"
    	Data.s "JULIET", "JANNIE", "JANELL", "JASMIN", "JANINE", "JOHNNY", "JEANIE", "JEANNA", "JOHNNA"
    	Data.s "JOELLE", "JOVITA", "JOSEPH", "JONNIE", "JANEEN", "JANINA", "JOANIE", "JAZMIN", "JOHNIE"
    	Data.s "JANENE", "JOHNNY", "JONELL", "JENELL", "JANETT", "JANETH", "JENINE", "JOELLA", "JOEANN"
    	Data.s "JULIAN", "JOHANA", "JENICE", "JANNET", "JANISE", "JULENE", "JOSHUA", "JANEAN", "JAIMEE"
    	Data.s "JOETTE", "JANYCE", "JENEVA", "JORDAN", "JACOBS", "JENSEN", "JOSEPH", "JANSEN", "JORDON"
    	Data.s "JULIAN", "JAEGER", "JACOBY", "JENSON", "JARMAN", "JOSLIN", "JESSEN", "JAHNKE", "JACOBO"
    	Data.s "JULIEN", "JOSHUA", "JEPSON", "JULIUS", "JANSON", "JACOBI", "JUDSON", "JARBOE", "JOHSON"
    	Data.s "JANZEN", "JETTON", "JUNKER", "JONSON", "JAROSZ", "JENNER", "JAGGER", "JASMIN", "JEPSEN"
    	Data.s "JORDEN", "JANNEY", "JUHASZ", "JERGEN"
    	Data.s "JOHNSON", "JOHNNIE", "JASMINE", "JEANNIE", "JOHANNA", "JANELLE", "JANETTE"
    	Data.s "JULIANA", "JUSTINA", "JOSETTE", "JOELLEN", "JENELLE", "JULIETA", "JULIANN", "JULISSA"
    	Data.s "JENETTE", "JANETTA", "JOSELYN", "JONELLE", "JESENIA", "JANESSA", "JAZMINE", "JEANENE"
    	Data.s "JOANNIE", "JADWIGA", "JOLANDA", "JULIANE", "JANUARY", "JEANICE", "JANELLA", "JEANETT"
    	Data.s "JENNINE", "JOHANNE", "JOHNSIE", "JANIECE", "JOHNSON", "JENNELL", "JAMISON", "JANSSEN"
    	Data.s "JOHNSEN", "JARDINE", "JAGGERS", "JURGENS", "JOURDAN", "JULIANO", "JOSEPHS", "JHONSON"
    	Data.s "JOZWIAK", "JANICKI", "JELINEK", "JANSSON", "JOACHIM", "JANELLE", "JACOBUS", "JENNING"
    	Data.s "JANTZEN", "JOHNNIE"
    	Data.s "JOSEFINA", "JEANNINE", "JULIANNE", "JULIANNA", "JONATHAN", "JONATHON", "JEANETTE"
    	Data.s "JANNETTE", "JEANETTA", "JOHNETTA", "JENNEFER", "JULIENNE", "JOSPHINE", "JEANELLE", "JOHNETTE"
    	Data.s "JULIEANN", "JOSEFINE", "JULIETTA", "JOHNSTON", "JACOBSON", "JACOBSEN", "JOHANSEN", "JOHANSON"
    	Data.s "JAWORSKI", "JENNETTE", "JELLISON", "JOHANNES", "JASINSKI", "JUERGENS", "JARNAGIN", "JEREMIAH"
    	Data.s "JEPPESEN", "JARNIGAN", "JANOUSEK"
    	Data.s "JOHNATHAN", "JOHNATHON", "JORGENSEN", "JEANMARIE", "JOSEPHINA", "JEANNETTE"
    	Data.s "JOSEPHINE", "JEANNETTA", "JORGENSON", "JANKOWSKI", "JOHNSTONE", "JABLONSKI", "JOSEPHSON"
    	Data.s "JOHANNSEN", "JURGENSEN", "JIMMERSON", "JOHANSSON", "JAKUBOWSKI"
    	Data.s #EOT$
    EndDataSection
  EndProcedure
  ; --------------------------------------------------  
  
  Procedure Encode_J()
    
    
  EndProcedure
  ; -------------------------------------------------- 
 
  ;-Encode K
  Procedure Encode_K()
    
    
  EndProcedure
  ; -------------------------------------------------- 
 
  ;-Encode L
  Procedure Encode_L()
    
    
  EndProcedure
  ; -------------------------------------------------- 
 
  ;-Encode M
  Procedure Encode_M()
    
    
  EndProcedure
  
  ;-Encode N
  Procedure Encode_N()
     
   
  EndProcedure
  
  ;-Encode P
  Procedure Encode_P()
    
    
  EndProcedure
  
  ;-Encode Q
  Procedure Encode_Q()
    
    
  EndProcedure
  
  ;-Encode R
  Procedure Encode_R()
     
   
  EndProcedure
  
  ;-Encode S
  Procedure Encode_S()
    
    
  EndProcedure

  ;-Encode T
  
  Procedure.i Encode_ThPronouncedSeparately()
  
    ; Grouped by length for faster comparison
    If idx > 0
      ; 4-letter endings
      If _stringsAt(1, 4, "HOOD,HEAD,HEID,HAND,HILL,HOLD,HAWK,HEAP,HERD,HOLE,HOOK,HUNT,HUMO,HAUS,HOFF,HARD") And
         Not _stringsAt(-3, 5, "SOUTH,NORTH")
        Goto AddT
      EndIf
      
      ; 5-letter endings
      If _stringsAt(1, 5, "HOUSE,HEART,HASTE,HYPNO,HEQUE")
        Goto AddT
      EndIf
      
      ; 4-letter endings at the end of string
      If _stringsAtEnd(1, 4, "HALL") And Not _stringsAt(-3, 5, "SOUTH,NORTH")
        Goto AddT
      EndIf
      
      ; 3-letter endings at the end of string, avoiding specific starts
      If _stringsAtEnd(1, 3, "HAM") And Not _stringsStart(6, "GOTHAM,WITHAM,LATHAM,BENTHAM,WALTHAM,WORTHAM,GRANTHAM")
        Goto AddT
      EndIf
      
      ; 5-letter special cases
      If _stringsAt(1, 5, "HATCH") And Not (idx = 0 Or _stringsAt(-2, 7, "UNTHATCH"))
        Goto AddT
      EndIf
      
      ; 6-letter prefixes
      If _stringsAt(-3, 6, "GOETHE,WARTHOG")
        Goto AddT
      EndIf
      
      ; 6-letter special names
      If _stringsAt(-2, 6, "ESTHER,NATHALIE")
        Goto AddT
      EndIf
      
      ProcedureReturn #False
    EndIf
  
    ProcedureReturn #False
  
  AddT:
    ; Special case: 'POSTHUM'
    If _stringsAt(-3, 7, "POSTHUM")
      _metaphAdd('X')
    Else
      _metaphAdd('T')
    EndIf
    
    idx + 1
    ProcedureReturn #True
  EndProcedure
  
  Procedure Encode_T()
    
    
  EndProcedure
  
  ;-Encode V
  Procedure Encode_V()
    
    
  EndProcedure
  
  ;-Encode W
  
  Procedure germanicOrSlavicNameBeginningWithW()
    If _stringsStart(3, "WEE,WIX,WAX") Or
       _stringsStart(4, "WOLF,WEIS,WAHL,WALZ,WEIL,WERT,WINE,WILK,WALT,WOLL,WADA,WULF,WEHR,WURM,WYSE,WENZ,WIRT,WOLK,WEIN,WYSS,WASS,WANN,WINT,WINK,WILE,WIKE,WIER,WELK,WISE") Or
       
      _stringsStart(5, "WIRTH,WIESE,WITTE,WENTZ,WOLFF,WENDT,WERTZ,WILKE,WALTZ,WEISE,WOOLF,WERTH,WEESE,WURTH,WINES,WARGO,WIMER,WISER,WAGER") Or 
      _stringsStart(5, "WILLE,WILDS,WAGAR,WERTS,WITTY,WIENS,WIEBE,WIRTZ,WYMER,WULFF,WIBLE,WINER,WIEST,WALKO,WALLA,WEBRE,WEYER,WYBLE,WOMAC,WILTZ") Or
      
; 		"WURST", "WOLAK", "WELKE", "WEDEL", "WEIST", "WYGAN", "WUEST", "WEISZ", "WALCK", "WEITZ",
; 		"WYDRA", "WANDA", "WILMA", "WEBER",
; 		"WETZEL", "WEINER", "WENZEL", "WESTER", "WALLEN", "WENGER", "WALLIN", "WEILER",
; 		"WIMMER", "WEIMER", "WYRICK", "WEGNER", "WINNER", "WESSEL", "WILKIE", "WEIGEL", "WOJCIK",
; 		"WENDEL", "WITTER", "WIENER", "WEISER", "WEXLER", "WACKER", "WISNER", "WITMER", "WINKLE",
; 		"WELTER", "WIDMER", "WITTEN", "WINDLE", "WASHER", "WOLTER", "WILKEY", "WIDNER", "WARMAN",
; 		"WEYANT", "WEIBEL", "WANNER", "WILKEN", "WILTSE", "WARNKE", "WALSER", "WEIKEL", "WESNER",
; 		"WITZEL", "WROBEL", "WAGNON", "WINANS", "WENNER", "WOLKEN", "WILNER", "WYSONG", "WYCOFF",
; 		"WUNDER", "WINKEL", "WIDMAN", "WELSCH", "WEHNER", "WEIGLE", "WETTER", "WUNSCH", "WHITTY",
; 		"WAXMAN", "WILKER", "WILHAM", "WITTIG", "WITMAN", "WESTRA", "WEHRLE", "WASSER", "WILLER",
; 		"WEGMAN", "WARFEL", "WYNTER", "WERNER", "WAGNER", "WISSER",
; 		"WISEMAN", "WINKLER", "WILHELM", "WELLMAN", "WAMPLER", "WACHTER", "WALTHER",
; 		"WYCKOFF", "WEIDNER", "WOZNIAK", "WEILAND", "WILFONG", "WIEGAND", "WILCHER", "WIELAND",
; 		"WILDMAN", "WALDMAN", "WORTMAN", "WYSOCKI", "WEIDMAN", "WITTMAN", "WIDENER", "WOLFSON",
; 		"WENDELL", "WEITZEL", "WILLMAN", "WALDRUP", "WALTMAN", "WALCZAK", "WEIGAND", "WESSELS",
; 		"WIDEMAN", "WOLTERS", "WIREMAN", "WILHOIT", "WEGENER", "WOTRING", "WINGERT", "WIESNER",
; 		"WAYMIRE", "WHETZEL", "WENTZEL", "WINEGAR", "WESTMAN", "WYNKOOP", "WALLICK", "WURSTER",
; 		"WINBUSH", "WILBERT", "WALLACH", "WYNKOOP", "WALLICK", "WURSTER", "WINBUSH", "WILBERT",
; 		"WALLACH", "WEISSER", "WEISNER", "WINDERS", "WILLMON", "WILLEMS", "WIERSMA", "WACHTEL",
; 		"WARNICK", "WEIDLER", "WALTRIP", "WHETSEL", "WHELESS", "WELCHER", "WALBORN", "WILLSEY",
; 		"WEINMAN", "WAGAMAN", "WOMMACK", "WINGLER", "WINKLES", "WIEDMAN", "WHITNER", "WOLFRAM",
; 		"WARLICK", "WEEDMAN", "WHISMAN", "WINLAND", "WEESNER", "WARTHEN", "WETZLER", "WENDLER",
; 		"WALLNER", "WOLBERT", "WITTMER", "WISHART", "WILLIAM",
; 		"WESTPHAL", "WICKLUND", "WEISSMAN", "WESTLUND", "WOLFGANG", "WILLHITE", "WEISBERG",
; 		"WALRAVEN", "WOLFGRAM", "WILHOITE", "WECHSLER", "WENDLING", "WESTBERG", "WENDLAND", "WININGER",
; 		"WHISNANT", "WESTRICK", "WESTLING", "WESTBURY", "WEITZMAN", "WEHMEYER", "WEINMANN", "WISNESKI",
; 		"WHELCHEL", "WEISHAAR", "WAGGENER", "WALDROUP", "WESTHOFF", "WIEDEMAN", "WASINGER", "WINBORNE",
; 		"WHISENANT", "WEINSTEIN", "WESTERMAN", "WASSERMAN", "WITKOWSKI", "WEINTRAUB",
; 		"WINKELMAN", "WINKFIELD", "WANAMAKER", "WIECZOREK", "WIECHMANN", "WOJTOWICZ", "WALKOWIAK",
; 		"WEINSTOCK", "WILLEFORD", "WARKENTIN", "WEISINGER", "WINKLEMAN", "WILHEMINA",
; 		"WISNIEWSKI", "WUNDERLICH", "WHISENHUNT", "WEINBERGER", "WROBLEWSKI", "WAGUESPACK",
; 		"WEISGERBER", "WESTERVELT", "WESTERLUND", "WASILEWSKI", "WILDERMUTH", "WESTENDORF",
; 		"WESOLOWSKI", "WEINGARTEN", "WINEBARGER", "WESTERBERG", "WANNAMAKER", "WEISSINGER",
; 		"WALDSCHMIDT", "WEINGARTNER", "WINEBRENNER",
; 		"WOLFENBARGER", "WOJCIECHOWSKI")
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
    
    DataSection
      Data.s "WEE", "WIX", "WAX"
      
      Data.s "WOLF", "WEIS", "WAHL", "WALZ", "WEIL", "WERT", "WINE", "WILK", "WALT", "WOLL"
      Data.s "WADA", "WULF", "WEHR", "WURM", "WYSE", "WENZ", "WIRT", "WOLK", "WEIN", "WYSS", "WASS", "WANN"
      Data.s "WINT", "WINK", "WILE", "WIKE", "WIER", "WELK", "WISE"
      
      Data.s "WIRTH", "WIESE", "WITTE", "WENTZ", "WOLFF", "WENDT", "WERTZ", "WILKE", "WALTZ"
      Data.s "WEISE", "WOOLF", "WERTH", "WEESE", "WURTH", "WINES", "WARGO", "WIMER", "WISER", "WAGER"
      Data.s "WILLE", "WILDS", "WAGAR", "WERTS", "WITTY", "WIENS", "WIEBE", "WIRTZ", "WYMER", "WULFF"
      Data.s "WIBLE", "WINER", "WIEST", "WALKO", "WALLA", "WEBRE", "WEYER", "WYBLE", "WOMAC", "WILTZ"
      Data.s "WURST", "WOLAK", "WELKE", "WEDEL", "WEIST", "WYGAN", "WUEST", "WEISZ", "WALCK", "WEITZ"
      Data.s "WYDRA", "WANDA", "WILMA", "WEBER"
      
      Data.s "WETZEL", "WEINER", "WENZEL", "WESTER", "WALLEN", "WENGER", "WALLIN", "WEILER"
      Data.s "WIMMER", "WEIMER", "WYRICK", "WEGNER", "WINNER", "WESSEL", "WILKIE", "WEIGEL", "WOJCIK"
      Data.s "WENDEL", "WITTER", "WIENER", "WEISER", "WEXLER", "WACKER", "WISNER", "WITMER", "WINKLE"
      Data.s "WELTER", "WIDMER", "WITTEN", "WINDLE", "WASHER", "WOLTER", "WILKEY", "WIDNER", "WARMAN"
      Data.s "WEYANT", "WEIBEL", "WANNER", "WILKEN", "WILTSE", "WARNKE", "WALSER", "WEIKEL", "WESNER"
      Data.s "WITZEL", "WROBEL", "WAGNON", "WINANS", "WENNER", "WOLKEN", "WILNER", "WYSONG", "WYCOFF"
      Data.s "WUNDER", "WINKEL", "WIDMAN", "WELSCH", "WEHNER", "WEIGLE", "WETTER", "WUNSCH", "WHITTY"
      Data.s "WAXMAN", "WILKER", "WILHAM", "WITTIG", "WITMAN", "WESTRA", "WEHRLE", "WASSER", "WILLER"
      Data.s "WEGMAN", "WARFEL", "WYNTER", "WERNER", "WAGNER", "WISSER"
      
      Data.s "WISEMAN", "WINKLER", "WILHELM", "WELLMAN", "WAMPLER", "WACHTER", "WALTHER"
      Data.s "WYCKOFF", "WEIDNER", "WOZNIAK", "WEILAND", "WILFONG", "WIEGAND", "WILCHER", "WIELAND"
      Data.s "WILDMAN", "WALDMAN", "WORTMAN", "WYSOCKI", "WEIDMAN", "WITTMAN", "WIDENER", "WOLFSON"
      Data.s "WENDELL", "WEITZEL", "WILLMAN", "WALDRUP", "WALTMAN", "WALCZAK", "WEIGAND", "WESSELS"
      Data.s "WIDEMAN", "WOLTERS", "WIREMAN", "WILHOIT", "WEGENER", "WOTRING", "WINGERT", "WIESNER"
      Data.s "WAYMIRE", "WHETZEL", "WENTZEL", "WINEGAR", "WESTMAN", "WYNKOOP", "WALLICK", "WURSTER"
      Data.s "WINBUSH", "WILBERT", "WALLACH", "WYNKOOP", "WALLICK", "WURSTER", "WINBUSH", "WILBERT"
      Data.s "WALLACH", "WEISSER", "WEISNER", "WINDERS", "WILLMON", "WILLEMS", "WIERSMA", "WACHTEL"
      Data.s "WARNICK", "WEIDLER", "WALTRIP", "WHETSEL", "WHELESS", "WELCHER", "WALBORN", "WILLSEY"
      Data.s "WEINMAN", "WAGAMAN", "WOMMACK", "WINGLER", "WINKLES", "WIEDMAN", "WHITNER", "WOLFRAM"
      Data.s "WARLICK", "WEEDMAN", "WHISMAN", "WINLAND", "WEESNER", "WARTHEN", "WETZLER", "WENDLER"
      Data.s "WALLNER", "WOLBERT", "WITTMER", "WISHART", "WILLIAM"
      
      Data.s "WESTPHAL", "WICKLUND", "WEISSMAN", "WESTLUND", "WOLFGANG", "WILLHITE", "WEISBERG"
      Data.s "WALRAVEN", "WOLFGRAM", "WILHOITE", "WECHSLER", "WENDLING", "WESTBERG", "WENDLAND", "WININGER"
      Data.s "WHISNANT", "WESTRICK", "WESTLING", "WESTBURY", "WEITZMAN", "WEHMEYER", "WEINMANN", "WISNESKI"
      Data.s "WHELCHEL", "WEISHAAR", "WAGGENER", "WALDROUP", "WESTHOFF", "WIEDEMAN", "WASINGER", "WINBORNE"
      
      Data.s "WHISENANT", "WEINSTEIN", "WESTERMAN", "WASSERMAN", "WITKOWSKI", "WEINTRAUB"
      Data.s "WINKELMAN", "WINKFIELD", "WANAMAKER", "WIECZOREK", "WIECHMANN", "WOJTOWICZ", "WALKOWIAK"
      Data.s "WEINSTOCK", "WILLEFORD", "WARKENTIN", "WEISINGER", "WINKLEMAN", "WILHEMINA"
      
      Data.s "WISNIEWSKI", "WUNDERLICH", "WHISENHUNT", "WEINBERGER", "WROBLEWSKI", "WAGUESPACK"
      Data.s "WEISGERBER", "WESTERVELT", "WESTERLUND", "WASILEWSKI", "WILDERMUTH", "WESTENDORF"
      Data.s "WESOLOWSKI", "WEINGARTEN", "WINEBARGER", "WESTERBERG", "WANNAMAKER", "WEISSINGER"
      
      Data.s "WALDSCHMIDT", "WEINGARTNER", "WINEBRENNER"
      Data.s "WOLFENBARGER", "WOJCIECHOWSKI"
      Data.s #EOT$
    EndDataSection

  EndProcedure
  
  Procedure Encode_W()
    
    
  EndProcedure

  ;-Encode X
  Procedure Encode_X()
     
   
  EndProcedure
  
    ;-Encode Z
  Procedure Encode_Z()
    
    
  EndProcedure
  
  Procedure Encode_Vowels()
    
    
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- The public MTF3 Encoder functions
  ;- ----------------------------------------------------------------------
 
  Procedure.i EncodeMTF3(String$, xEncodeExact=#True)
       
    lenIn = Len(String$)
    EncodeExact = xEncodeExact
    *pC = @String$
    idx = 0
    
    While *pC\c
      Select *pC\c
        Case 'B' : Encode_B()
        Case 'ß', 'Ç' : _metaphAdd('S')  
        Case 'C' : Encode_C()  
        Case 'D' : Encode_D()  
        Case 'F' : Encode_F()  
        Case 'G' : Encode_G()  
        Case 'H' : Encode_H()  
        Case 'J' : Encode_J()  
        Case 'K' : Encode_K()  
        Case 'L' : Encode_L()  
        Case 'M' : Encode_M()  
        Case 'N' : Encode_N()
        Case 'Ñ' :_metaphAdd('N')
        Case 'P' : Encode_P()  
        Case 'Q' : Encode_Q()  
        Case 'R' : Encode_R()  
        Case 'S' : Encode_S()  
        Case 'T' : Encode_T()
        Case 'Ð', 'Þ' : _metaphAdd('0')
        Case 'V' : Encode_V()  
        Case 'W' : Encode_W()  
        Case 'X' : Encode_X()  
        Case 'Z' : Encode_X()  
          
        Default
          If _IsVowel(*pC\c)
            Encode_V()
          EndIf
          
      EndSelect
    Wend   
    
  EndProcedure
        
EndModule

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 1397
; FirstLine = 1215
; Folding = +---------------
; DPIAware
; CPU = 5