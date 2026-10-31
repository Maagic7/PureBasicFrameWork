  EnableExplicit
  
  ;XIncludeFile "..\..\PbFw_Module_FastString_new.pb"        ; FStr::    Fast String Module
  
  ; An adapted version of pAny especally for character use
  Structure pChar   ; ATTENTION! Only use as Pointer Strukture! Do not define as a normal Var!
    StructureUnion
      a.a         ; ASCII   : 8 Bit unsigned  [0..255] 
      c.c         ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      u.u         ; UNICODE : 2 Byte unsigned [0..65535]
      aa.a[0]     ; ASCII   : 8 Bit unsigned  [0..255] 
      cc.c[0]     ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      uu.u[0]     ; UNICODE : 2 Byte unsigned [0..65535]
    EndStructureUnion
  EndStructure 

  ; with the Prototype trick, PB pass directly the Stringpointer and do not copy the String!
  Prototype SplitStringArray(Array Out.s(1), String$, Separator$, DQuote=#False, ArrayRedimStep=10)
  Global SplitStringArray.SplitStringArray
  
  Prototype SplitStringList(List Out.s(), String$, Separator$, DQuote=#False, clrList= #True)
  Global SplitStringList.SplitStringList
  
  Prototype SplitStringList2(List Out.s(), String$, Separator$, clrList= #True)
  Global SplitStringList2.SplitStringList2
  
  Procedure.i _SplitStringArray(Array Out.s(1), *String, *Separator, DQuote=#False, ArrayRedimStep=10)
  ; ============================================================================
  ; NAME: _SplitStringArray
  ; DESC: Split a String into multiple Strings
  ; DESC: 
  ; VAR(Out.s())    : Array to return the Substrings (ArraySize >= Substrings)
  ; VAR(*String)    : Pointer to String 
  ; VAR(*Separator) : Pointer to Separator String 
  ; VAR(DQuote)     : #True=skip search for Separator in quoted text, #Flase=search everywhere  
  ; VAR(ArrayRedimStep) : How may entries are added to the String each ReDim
  ;                       if you know the exact No of Substrings before, use it here!
  ;                       this prevents from ReDim.
  ; RET.i           : No of Substrings
  ; ============================================================================
    
    Protected lsep, I, xDo, N, ASize
    Protected *pStart 
    Protected *pRead.pChar
    Protected *pSep.pChar
    
    If Not *String
      ProcedureReturn 0
    EndIf
    
    *pRead = *String        ; ReadPointer
    *pStart = *String       ; Pointer of search Start
    *pSep = *Separator      ; Pointer of Separator
         
    If *Separator
      ; lsep = Len(Separator)
      While *pSep\c[lsep]    ; Trick to get length with indexed pChar
        lsep + 1
      Wend
    EndIf
    
    ASize = ArraySize(Out())    
    
    If *Separator=0 Or lsep=0
      If ASize = -1         ; not Dim
         Dim Out(0)
      EndIf            
      Out(0) = PeekS(*String)
      ProcedureReturn 1
    EndIf
    
    If ASize = -1         ; not Dim
      ASize = ArrayRedimStep
      Dim Out(ASize)
    EndIf            
        
    Repeat      
      ; ----------------------------------------------------------------------
      If DQuote  ; skip qutoed Text for search Separator -> do not split in quotes
      ; ----------------------------------------------------------------------  
        ; move *pRead to first matching Character
        While *pRead\c <> *pSep\c
          Select *pRead\c
            Case 0    ; Break if EndOfString
              Break 
              
            Case '"'  ; DoubleQuote
              ; move *pRead to 2nd " to ignore Text in Quotes
              *pRead + SizeOf(Character)  ; Char after "
              While *pRead\c <> '"'
                *pRead + SizeOf(Character)
                If *pRead\c = 0
                  Break 2
                EndIf
              Wend             
          EndSelect
          *pRead + SizeOf(Character)
        Wend        
      ; ----------------------------------------------------------------------
      Else    ; do not check for Text in Quotes
      ; ----------------------------------------------------------------------      
        ; move *pRead to first matching Character
        While *pRead\c <> *pSep\c
          If *pRead\c = 0    ; Break if EndOfString
            Break 
          EndIf   
          *pRead + SizeOf(Character)
        Wend
        
      EndIf
      ; ----------------------------------------------------------------------
    
      If *pRead\c ; If Not EndOfString -> we found a Separator
        If lsep = 1
          ; if Len(Separator) = 1 -> split here
          xDo = #True
        Else         
          xDo = #True
          ; Check if all Characters matching?
          For I = 1 To lsep-1 ; we can start at 2nd char because 1st char is steill checked for equal
            If *pRead\c[I] <> *pSep\c[I]
              xDo = #False  ; Character do not Match -> Separator not found!
            EndIf
          Next
        EndIf
      
        ; If CompareMemoryString(*pRead, *Separator, #PB_String_CaseSensitive, lsep)= #PB_String_Equal
        If xDo  
          If ASize < N
            ASize + ArrayRedimStep
            ReDim Out(ASize)
          EndIf
        
          Out(N) = PeekS(*pStart, (*pRead - *pStart)/SizeOf(Character))
          N+1
          *pRead + lsep * SizeOf(Character)
          *pStart = *pRead
        EndIf 
      Else
        Break
      EndIf
      
    ForEver ; Until *pRead\c = 0 
    
    ; return last Element
    If ASize < N
      ASize + 1
      ReDim Out(ASize)
;     ElseIf Asize > N
;       ReDim Out(N)
    EndIf  
    Out(N) = PeekS(*pStart) 
    N+1      
    ProcedureReturn N     ; Number of Substrings        
  EndProcedure 
  SplitStringArray = @_SplitStringArray()   ; Bind ProcedureAddress to Prototype

;   Procedure.i _SplitStringArray(Array Out.s(1), *String, *Separator, ArrayRedimStep=10)
;   ; ============================================================================
;   ; NAME: _SplitStringArray
;   ; DESC: Split a String into multiple Strings
;   ; DESC: 
;   ; VAR(Out.s()) : Array to return the Substrings (ArraySize >= Substrings)
;   ; VAR(*String) : Pointer to String 
;   ; VAR(*Separator) : Pointer to Separator String 
;   ; VAR(ArrayRedimStep) : How may entries are added to the String each ReDim
;   ; RET.i : No of Substrings
;   ; ============================================================================
;         
;     Protected lsep, N, Pos, ASize
;     Protected Str.String, *pStr.Integer ; for hooking *String into Str.String 
;     Protected Sep.String, *pSep.Integer ; for hooking *Separator into Sep.String 
;         
;     If Not *String
;       ProcedureReturn 0
;     EndIf
;     
;     ASize = ArraySize(Out())    
;     If ASize = -1         ; not Dim
;       ASize = ArrayRedimStep
;       Dim Out(ASize)
;     EndIf            
; 
;     If Not *Separator
;       Out(0) = PeekS(*String)
;       ProcedureReturn 1     
;     EndIf
;     
;     ; because FindString() do not accept Pointers, we have to hook the 
;     ; *String and *Separator into a String-Structure, The trick is to overlay
;     ; an Integer Structure over the String Structure - this is like StructureUnion
;     ; but hand made!
;     *pStr = @Str            ; Overlay IntergerStructure on String Structure
;     *pStr\i = *String       ; Hook String into Str\s => PokeI(@Str, *String))
;     
;     *pSep = @Sep            ; Overlay IntergerStructure on String Structure
;     *pSep\i = *Separator    ; Hook Separator into Sep\s => PokeI(@Sep, *Separator))
;      
;     lsep = MemoryStringLength(*Separator)
;      
;     Pos = FindString(Str\s, Sep\s)  
;     While pos     
;       If ASize < N
;         ASize + ArrayRedimStep
;         ReDim Out(ASize)
;       EndIf            
;       Pos -1      ; because the length in characters is Pos-1
;       Out(N) = PeekS(*pStr\i, Pos)
;       ; because *pStr is an overlay on Str.String, we can move the Stringpointer
;       ; @Str\s directly by manipulating *pStr\i what is same as the Pointer of the String
;        *pStr\i = *pStr\i + (Pos + lsep)*SizeOf(Character) ; move @Str\s to new Startposition
;       N + 1       
;       pos = FindString(Str\s, Sep\s)      
;     Wend 
;     
;     Out(N) = PeekS(*pStr\i)
;     
;     ; befor leaving the Procedure we have to unhook the Strings, otherwise PB will delete
;     ; the original String allocated Memory and the original String Point to non allocated
;     ; Memory.
;     *pStr\i = 0   ; Unhook String
;     *pSep\i = 0   ; Unhook Seperator
; 
;     ProcedureReturn N+1     ; Number of Substrings       
;   EndProcedure
;   SplitStringArray = @_SplitStringArray()   ; Bind ProcedureAddress to Prototype
  
  Procedure.i _SplitStringList(List Out.s(), *String, *Separator, DQuote = #False, clrList= #True)
  ; ============================================================================
  ; NAME: _SplitStringList
  ; DESC: Split a String into multiple Strings
  ; DESC: 
  ; VAR(Out.s())   : List to return the Substrings 
  ; VAR(*String)   : Pointer to String 
  ; VAR(*Separator): Pointer to Separator String 
  ; VAR(DQuote)    : #True=skip search for Separator in quoted text, #Flase=search everywhere  
  ; VAR(clrList)   : #False: Append Splits to List; #True: Clear List first
  ; RET.i          : No of Substrings
  ; ============================================================================
    
    Protected lsep, I, xDo
    Protected *pStart 
    Protected *pRead.pChar
    Protected *pSep.pChar
    
    If Not *String
      ProcedureReturn 0
    EndIf
    
    If clrList
      ClearList(Out())  
    EndIf
    
    *pRead = *String        ; ReadPointer
    *pStart = *String       ; Pointer of search Start
    *pSep = *Separator      ; Pointer of Separator
   
    If *Separator
      ; lsep = Len(Separator)
      While *pSep\c[lsep]    ; Trick to get length with indexed pChar
        lsep + 1
      Wend
    EndIf
    
    If *Separator=0 Or lsep=0
      AddElement(Out())
      Out() = PeekS(*String)
      ProcedureReturn 1
    EndIf
           
    Repeat      
      ; ----------------------------------------------------------------------
      If DQuote  ; skip qutoed Text for search Separator -> do not split in quotes
      ; ----------------------------------------------------------------------  
        ; move *pRead to first matching Character
        While *pRead\c <> *pSep\c
          Select *pRead\c
            Case 0    ; Break if EndOfString
              Break 
              
            Case '"'  ; DoubleQuote
              ; move *pRead to 2nd " to ignore Text in Quotes
              *pRead + SizeOf(Character)  ; Char after "
              While *pRead\c <> '"'
                *pRead + SizeOf(Character)
                If *pRead\c = 0
                  Break 2
                EndIf
              Wend             
          EndSelect
          *pRead + SizeOf(Character)
        Wend        
      ; ----------------------------------------------------------------------
      Else    ; do not check for Text in Quotes
      ; ----------------------------------------------------------------------      
        ; move *pRead to first matching Character
        While *pRead\c <> *pSep\c
          If *pRead\c = 0    ; Break if EndOfString
            Break 
          EndIf   
          *pRead + SizeOf(Character)
        Wend
        
      EndIf
      ; ----------------------------------------------------------------------
    
      If *pRead\c ; If Not EndOfString -> we found a Separator
        If lsep = 1
          ; if Len(Separator) = 1 -> split here
          xDo = #True
        Else         
          xDo = #True
          ; Check if all Characters matching?
          For I = 1 To lsep-1 ; we can start at 2nd char because 1st char is steill checked for equal
            If *pRead\c[I] <> *pSep\c[I]
              xDo = #False  ; Character do not Match -> Separator not found!
            EndIf
          Next
        EndIf
      
        ; If CompareMemoryString(*pRead, *Separator, #PB_String_CaseSensitive, lsep)= #PB_String_Equal
        If xDo  
          AddElement(Out())
          Out() = PeekS(*pStart, (*pRead - *pStart)/SizeOf(Character))      
          *pRead + lsep * SizeOf(Character)
          *pStart = *pRead
        EndIf 
      Else
         Break
      EndIf
      
    ForEver ; Until *pRead\c = 0 
    
    ; return last Element
    AddElement(Out())
    Out() = PeekS(*pStart)      
       
    ProcedureReturn ListSize(Out())     ; Number of Substrings        
  EndProcedure 
  SplitStringList = @_SplitStringList()   ; Bind ProcedureAddress to Prototype

;   Procedure.i _SplitStringList(List Out.s(), *String, *Separator, clrList= #True)
;   ; ============================================================================
;   ; NAME: _SplitStringList
;   ; DESC: Split a String into multiple Strings
;   ; DESC: 
;   ; VAR(Out.s())   : List to return the Substrings 
;   ; VAR(*String)   : Pointer to String 
;   ; VAR(*Separator): Pointer to Separator String 
;   ; VAR(clrList)   : #False: Append Splits to List; #True: Clear List first
;   ; RET.i          : No of Substrings
;   ; ============================================================================
;     
;     Protected lsep, N, Pos
;     Protected Str.String, *pStr.Integer ; for hooking *String into Str.String 
;     Protected Sep.String, *pSep.Integer ; for hooking *Separator into Sep.String 
;     Protected *pC.Character
;     
;     If Not *String
;       ProcedureReturn 0
;     EndIf
;     
;     If clrList
;       ClearList(Out())  
;     EndIf
;     
;     If Not *Separator
;       AddElement(Out())
;       Out() = PeekS(*String)
;       ProcedureReturn 1
;     EndIf
;     
;     ; because FindString() do not accept Pointers, we have to hook the 
;     ; *String and *Separator into a String-Structure, The trick is to overlay
;     ; an Integer Structure over the String Structure - this is like StructureUnion
;     ; but hand made!
;     *pStr = @Str            ; Overlay IntergerStructure on String Structure
;     *pStr\i = *String       ; Hook String into Str\s => PokeI(@Str, *String))
;     *pC = *String
;     
;     *pSep = @Sep            ; Overlay IntergerStructure on String Structure
;     *pSep\i = *Separator    ; Hook Separator into Sep\s => PokeI(@Sep, *Separator))
;         
;     lsep = MemoryStringLength(*Separator)
;      
;     Pos = FindString(Str\s, Sep\s) 
;     
;     While pos 
;       Pos -1      ; because the length in characters is Pos-1
;       AddElement(Out())
;       Out() = PeekS(*pStr\i, Pos)
;       ; because *pStr is an overlay on Str.String, we can move the Stringpointer
;       ; @Str\s directly by manipulating *pStr\i what is same as the Pointer of the String
;        *pStr\i = *pStr\i + (Pos + lsep)*SizeOf(Character) ; move @Str\s to new Startposition
;       N + 1       
;       Pos = FindString(Str\s, Sep\s) 
;     Wend 
;     
;     AddElement(Out())
;     Out() = PeekS(*pStr\i)
;     
;     ; befor leaving the Procedure we have to unhook the Strings, otherwise PB will delete
;     ; the original String allocated Memory and the original String Point to non allocated
;     ; Memory.
;     *pStr\i = 0   ; Unhook String -> delete the Pointer of the String in Str\s
;     *pSep\i = 0   ; Unhook Seperator -> delete the Pointer of the String in Sep\s
; 
;     ProcedureReturn N+1     ; Number of Substrings        
;   EndProcedure 
;   SplitStringList = @_SplitStringList()   ; Bind ProcedureAddress to Prototype
  
  ; this is code from mk-soft from 
  ; https://www.purebasic.fr/english/viewtopic.php?t=69557;
  Procedure SplitStringList_mk(String.s, Separator.s, List Result.s(), DQuote = #False)
  Protected *String.character, *Separator.character
  Protected *Start, *End, exit, lock, do, dq, len
  
  ClearList(Result())
  *String = @String
  *Separator = @Separator
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
        If *String\c = '"'
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

; This is the modified version of mk-soft version with Protoype and Pointer
Prototype SplitStringList2_mk(Str$, Sep$, List Result.s(), DQuote = #False)
Global SplitStringList2_mk.SplitStringList2_mk

Procedure _SplitStringList2_mk(*Str, *Sep, List Result.s(), DQuote = #False)
  Protected *String.character, *Separator.character
  Protected *Start, *End, exit, lock, do, dq, len
  
  ClearList(Result())
  *String = *Str
  *Separator = *Sep
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
        If *String\c = '"'
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
SplitStringList2_mk = @_SplitStringList2_mk()

  Procedure.i _SplitStringList2(List Out.s(), *String, *Separator, clrList= #True)
  ; ============================================================================
  ; NAME: _SplitStringList
  ; DESC: Split a String into multiple Strings
  ; DESC: 
  ; VAR(Out.s())   : List to return the Substrings 
  ; VAR(*String)   : Pointer to String 
  ; VAR(*Separator): Pointer to Separator String 
  ; VAR(clrList)   : #False: Append Splits to List; #True: Clear List first
  ; RET.i          : No of Substrings
  ; ============================================================================
    
    Protected *ptrString.Character = *String          ; Pointer to String
    Protected *ptrSeperator.Character = *Separator    ; Pointer to Separator
    Protected *Start.Character = *String              ; Pointer to Start of SubString   
    Protected xEqual, lenSep, N, L
    
    If *String=0
      ProcedureReturn 0
    EndIf
    
    If clrList
      ClearList(Out())  
    EndIf
   
    If *Separator   
      lenSep = MemoryStringLength(*Separator)           ; Length of Separator
    EndIf
    
    Select lenSep
      Case 0
        AddElement(Out())
        Out() = PeekS(*String)
        ProcedureReturn 0
        
      Case 1      ; Seperator is only one char
          
        While *ptrString\c
        ; ----------------------------------------------------------------------
        ;  Outer Loop: Stepping trough *String
        ; ----------------------------------------------------------------------
          
          If  *ptrString\c = *ptrSeperator\c ; 1st Character of Seperator in String   
            ; Debug "Equal : " +  Chr(*ptrString\c)
            ; Length of the String from Start up to Separator
            L =  (*ptrString - *Start)/SizeOf(Character)
            AddElement(Out())
            If L
              Out() = PeekS(*Start, L)
            EndIf
            *Start = *ptrString + SizeOf(Character)        ; the New Startposition
            ; Debug "Start\c= " + Str(*Start\c) + " : " + Chr(*Start\c)
             N + 1             
          EndIf   
          *ptrString + SizeOf(Character)        ; NextChar in String
        Wend
     
      Default   ; Seperator is a String
      
        While *ptrString\c
        ; ----------------------------------------------------------------------
        ;  Outer Loop: Stepping trough *String
        ; ----------------------------------------------------------------------
        ; ATTENTION! Bug with splitting double Characters like "//" or ".."
          
          If  *ptrString\c = *ptrSeperator\c ; 1st Character of Seperator in String   
            ; Debug "Equal : " +  Chr(*ptrString\c)
            xEqual =#True
           
            While *ptrSeperator\c
            ; ------------------------------------------------------------------
            ;  Inner Loop: Char by Char compare Separator with String
            ; ------------------------------------------------------------------
              If *ptrString\c 
                If *ptrString\c <> *ptrSeperator\c
                  xEqual = #False     ; Not Equal
                  Break               ; Exit While
                EndIf
              Else 
                xEqual =#False        ; Not Equal
                Break                 ; Exit While
              EndIf
              *ptrSeperator + SizeOf(Character)  ; NextChar Separator
              *ptrString + SizeOf(Character)     ; NextChar String  
            Wend
            
            ; If we found the complete Separator in String
            If xEqual
              ; Length of the String from Start up to Separator
              L = (*ptrString - *Start)/SizeOf(Character) - lenSep 
              Debug "L = " + L
              AddElement(Out())
              If L
                Out() = PeekS(*Start, L)
              EndIf
              *Start = *ptrString             ; the New Startposition
              ; Debug "Start\c= " + Str(*Start\c) + " : " + Chr(*Start\c)
              ;*ptrString - SizeOf(Character)  ; go back 1 char to detected double single separators like ,,
               N + 1   
             Else
               *ptrString + SizeOf(Character)        ; NextChar in String 
             EndIf          
          Else   
            *ptrSeperator = *Separator            ; Reset Pointer of Seperator to 1st Char
            *ptrString + SizeOf(Character)        ; NextChar in String
          EndIf
        Wend
      
    EndSelect
    
    AddElement(Out())
    Out() = PeekS(*Start)  ; Part after the last Separator
    ProcedureReturn N+1     ; Number of Substrings
        
  EndProcedure 
  
  SplitStringList2 = @_SplitStringList2()   ; Bind ProcedureAddress to Prototype
  
  Procedure SplitStringMList(String.s, Separator.s, List Result.s(), DQuote = #False)
  Protected *String.character, *Separator.character
  Protected *Start, *End, exit, lock, do, dq, len, LenSeparator
  
  ClearList(Result())
  *String = @String
  *Separator = @Separator
  If *String\c And *Separator\c
    *Start = *String
    *End = *String
    LenSeparator = Len(Separator)
    If DQuote
      Repeat
        If *String\c = 0
          exit = #True
          do = #True
          If Not dq
            *End = *String
          EndIf
        Else
          If *String\c = '"'
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
            If LenSeparator = 1 Or (MemoryStringLength(*String) >= LenSeparator And CompareMemoryString(*String, *Separator, #PB_String_CaseSensitive, LenSeparator) = #PB_String_Equal)
              do = #True
              If Not dq
                *End = *String
              EndIf
            EndIf
          EndIf
        EndIf
        If do
          AddElement(Result()) 
          len = (*End - *Start) / SizeOf(character)
          If Len > 0
            Result() = PeekS(*Start, len) 
          EndIf
          *String + LenSeparator * SizeOf(character)
          *Start = *String
          do = #False
          dq = #False
        Else
          *String + SizeOf(character)
        EndIf
      Until exit
    Else
      Repeat
        If *String\c = 0
          exit = #True
          do = #True
          *End = *String
        Else
          If *String\c = *Separator\c
            If LenSeparator = 1 Or (MemoryStringLength(*String) >= LenSeparator And CompareMemoryString(*String, *Separator, #PB_String_CaseSensitive, LenSeparator) = #PB_String_Equal)
              do = #True
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
          *String + LenSeparator * SizeOf(character)
          *Start = *String
          do = #False
        Else
          *String + SizeOf(character)
        EndIf
      Until exit
    EndIf
  EndIf
  ProcedureReturn ListSize(Result())
EndProcedure

  ;- ------------------------------
  ;-  Function Test Code
  ; ------------------------------

  Define.s txt1, txt2, txt3
  txt1 = "I am a String for tests : Splitting a String is not integrated in PureBasic"
  #Search1 =" "
  txt2 = "123//225// 8809 // 1.25 // 3e-6 // 1.0033456 //// 111.1"
  #Search2 ="//"
  txt3 = ";100;200;300;400;500;600;70.0;80.8;90"
  #Search3 =";"

  
  Dim Split.s(10)
  NewList lstSplit.s()
  Define I, N
    
  
  Debug "*** Test 1 ***"
  Debug txt1
  Debug "--- SplitStringArray ---"
  N=SplitStringArray(Split(), txt1, #Search1)
  For I = 0 To N-1
    Debug Str(I+1) + " : " + Split(I)  
  Next
  
  Debug ""
  Debug "--- SplitStringList ---"
  N=SplitStringList(lstSplit(), txt1, #Search1)
  I = 1
  ForEach lstSplit()
    Debug Str(I) + " : " + lstSplit()
    I +1
  Next
    
  Debug ""
  Debug "--- SplitStringList_mk ---"
  N=SplitStringList2_mk(txt1, #Search1, lstSplit())
  I = 1
  ForEach lstSplit()
    Debug Str(I) + " : " + lstSplit()
    I +1
  Next
  
  Debug ""
  Debug "*** Test 2 ***"
  Debug txt2
  Debug "--- SplitStringArray ---"
  N=SplitStringArray(Split(), txt2, #Search2)
  For I = 0 To N-1
    Debug Str(I+1) + " : " + Split(I)  
  Next
  
  Debug ""
  Debug "--- SplitStringList ---"
  N=SplitStringList(lstSplit(), txt2, #Search2)
  I = 1
  ForEach lstSplit()
    Debug Str(I) + " : " + lstSplit()
    I +1
  Next
    
  N=SplitStringList_mk(txt2, #Search2, lstSplit())
  Debug ""
  Debug "--- SplitStringList_mk ---"
  N=SplitStringList2_mk(txt2, #Search2, lstSplit())
  I = 1
  ForEach lstSplit()
    Debug Str(I) + " : " + lstSplit()
    I +1
  Next
  
  Debug ""
  Debug "*** Test 3 ***"
  Debug txt3
  Debug "--- SplitStringArray ---"
  N=SplitStringArray(Split(), txt3, #Search3)
  For I = 0 To N-1
    Debug Str(I+1) + " : " + Split(I)  
  Next
  
  Debug ""
  Debug "--- SplitStringList ---"
  N=SplitStringList(lstSplit(), txt3, #Search3)
  I = 1
  ForEach lstSplit()
    Debug Str(I) + " : " + lstSplit()
    I +1
  Next
    
  Debug ""
  Debug "--- SplitStringList_mk ---"
  N=SplitStringList2_mk(txt3, #Search3, lstSplit())
  I = 1
  ForEach lstSplit()
    Debug Str(I) + " : " + lstSplit()
    I +1
  Next
  
   
  CompilerIf Not #PB_Compiler_Debugger
  ;- ------------------------------
  ;-  Speed Test Code
  ; ------------------------------
   ; Timing Test
    Define t1, t2, t3, t4
    Define n1, n2, n3
    #Loops = 1000 * 100
    Dim aTxt1.s(#Loops+1)
    Dim aTxt2.s(#Loops+1)
    Dim aTxt3.s(#Loops+1)
   
    ; create an Array of Text so we can test the speed in C-Backend
    For I = 0 To #Loops
      aTxt1(I) = txt1  
      aTxt2(I) = txt2  
      aTxt3(I) = txt3  
    Next
    
    t1=ElapsedMilliseconds()
    For I = 0 To #Loops
      n1=SplitStringArray(Split(), aTxt1(I), #Search1)
      n2=SplitStringArray(Split(), aTxt2(I), #Search2)
      n3=SplitStringArray(Split(), aTxt3(I), #Search3)
    Next
    t1=ElapsedMilliseconds()-t1
  
    t2=ElapsedMilliseconds()
    For I = 0 To #Loops
      n1=SplitStringList(lstSplit(), aTxt1(I), #Search1)
      n2=SplitStringList(lstSplit(), aTxt2(I), #Search2)
      n3=SplitStringList(lstSplit(), aTxt3(I), #Search3)
    Next
    t2=ElapsedMilliseconds()-t2
    
    t3=ElapsedMilliseconds()
    For I = 0 To #Loops
      n1=SplitStringMList(aTxt1(I), #Search1, lstSplit(), #True)
      n2=SplitStringMList(aTxt2(I), #Search2, lstSplit(), #True)
      n3=SplitStringMList(aTxt3(I), #Search3, lstSplit(), #True)
    Next
    t3=ElapsedMilliseconds()-t3
    
    t4=ElapsedMilliseconds()
    For I = 0 To #Loops
      n1=SplitStringList2_mk(aTxt1(I), #Search1, lstSplit())
      n2=SplitStringList2_mk(aTxt2(I), #Search2, lstSplit())
      n3=SplitStringList2_mk(aTxt3(I), #Search3, lstSplit())
    Next
    t4=ElapsedMilliseconds()-t4
    
    OpenConsole("Timing")
    PrintN("SplitStringArray ms = " + t1)
    PrintN("SplitStringList  ms = " + t2)
    PrintN("SplitStringMList_mk ms = " + t3)
    PrintN("SplitStringList2_mk ms = " + t4)
    PrintN("")
    PrintN("Press any key")
    Input()
  CompilerEndIf
  
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 314
; FirstLine = 311
; Folding = --
; Optimizer
; DPIAware
; CPU = 5