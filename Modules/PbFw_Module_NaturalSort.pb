; ===========================================================================
;  FILE : PbFw_Module_NatrualSort.pb
;  NAME : Module Natrual Sort Strings [NatSort::]
;  DESC : 
;  DESC : 
;  SOURCES:
;     https://rosettacode.org/wiki/Natural_sorting
;     https://arnehannappel.de/blog/sortieralgorithmen-vergleich
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/01/17
; VERSION  :  0.1  Brainstoruming Version
; COMPILER :  PureBasic 6.0+
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;  2025/07/26 S.Maag Integrated PB-Extention PX:: and Module STR::
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module
XIncludeFile "PbFw_Module_IsNumeric.pb"   ; IsNum::   IsNumeric Module
XIncludeFile "PbFw_Module_String.pb"      ; STR::     String Module

DeclareModule NatSort
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------

  Declare.i NaturalCompareString(*a.PX::pChar, *b.PX::pChar, Mode=#PB_String_CaseSensitive )
  Declare NaturalSortList(List lstTxt.s(), SortMode = #PB_Sort_Ascending)
  
EndDeclareModule

Module NatSort
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Structure TReplace
    sOrg.s        ; original String
    sRep.s        ; replace with this 
    Flags.i       ; some Flags
  EndStructure
  
  Define NewList MyReplaces.TReplace()
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------

  Macro mac_StringStartWithWord(MyString, MyWord)
    Bool(Left(MyString, Len(MyWord)) = MyWord)
  EndMacro
  
  Procedure.i _CreateReplaceList(List lstRepl.TReplace())
    Protected cnt.i
    ClearList(lstRepl())
    
    ProcedureReturn cnt
  EndProcedure
      
  Procedure.i _Natural_RemoveFirstWords(List lstNatStr.s(), List lstWords.s())
  ; ============================================================================
  ; NAME: _Natural_RemoveFirstWords
  ; DESC: Remove a List of first Words from the StringList
  ; DESC: This is used for sorting if we want to ignore common Words or Articeles
  ; DESC: like 'the' in englisch or 'der', 'die', 'das' in german
  ; VAR(lstNatStr.TNatural()) : The List of Strings to sort
  ; VAR(lstWords.s(): List of 1st Words to remove
  ; RET.i: Count of removes 
  ; ============================================================================
    Protected cnt, L
    Protected word.s
    
    If ListSize(lstNatStr()) And ListSize(lstWords()) ; if both Lists are not empty
      
      ResetList(lstNatStr())  ; Set List to the beginning    
      ForEach lstNatStr()     ; Step trough all entries of lstNatStr()
        
        ResetList(lstWords())       ; Set List to the beginning    
        ForEach lstWords()          ; Step trough all entries of lstWords()
          word = lstWords() + " "   ; add a Space to the word otherwisw we remove 'The' from 'Thermo'
          L=Len(word)               ; WordLength
          
          If (Left(lstNatStr(), L) = word)   ; If the Strings starts with the searched  word
            lstNatStr() = Mid(lstNatStr(), L+1)   ; Remove the word from the String 
            cnt + 1
          EndIf
        Next
      Next
    EndIf
    
    ProcedureReturn cnt   ; Return number of removed words
  EndProcedure
  
  Procedure _Natural_ReplaceAll(*Ret.String, In.s, List lstRepl.TReplace(), PbSort=#PB_Sort_Ascending|#PB_Sort_NoCase)
  ; ============================================================================
  ; NAME: _Natural_ReplaceAll
  ; DESC: Replace all parts of the String which we want to change for sorting
  ; VAR(*Ret.String) : The Return-String ByRefernce
  ; VAR(In.s):  The Input String
  ; VAR(lstRepl.TReplace()): List with Replaces ('ä'->'ae' ...)
  ; VAR(PbSort): Sorting Flags
  ; RET: - 
  ; ============================================================================
    Protected MyReplMode.i   ; #PB_String_CaseSensitive, #PB_String_NoCase,      
    
    STR::RemoveTabsAndDoubleSpaceFast(In)
    
    If PbSort & #PB_Sort_NoCase
      *Ret\s = LCase(In)
      MyReplMode = #PB_String_NoCase
    Else
      *Ret\s = In
      MyReplMode = #PB_String_CaseSensitive
    EndIf
    
    If ListSize(lstRepl())
      ResetList(lstRepl())
      ForEach lstRepl()
        *Ret\s = ReplaceString(*Ret\s, lstRepl()\sOrg, lstRepl()\sRep, MyReplMode)  
      Next
    EndIf  
     
  EndProcedure
  
  Procedure.i _NaturalCompare_Right(*a.PX::pChar, *b.PX::pChar)
  ; ============================================================================
  ; NAME: _NaturalCompare_Right
  ; DESC: 
  ; DESC: 
  ; VAR(*a.pChar) : Pointer to 1st String (interpreted as pointerChar)
  ; VAR(*a.pChar) : Pointer to 2nd String (interpreted as pointerChar)
  ; RET.i: {#PB_String_Lower, #PB_String_Equal, #PB_String_Greater}, {-1,0,1}
  ; ============================================================================
    Protected I, bias  
    
    ; The longest run of digits wins.  That aside, the greatest
    ; value wins, but we can't know that it will until we've scanned
    ; both numbers To know that they have the same magnitude, so we
    ; remember it in BIAS.
    
    While *a\cc[I] And *b\c
      
      If (Not PX::IsDecChar(*a\cc[I])) And (Not PX::IsDecChar(*b\cc[0]))
        
        ProcedureReturn bias
        
      ElseIf Not PX::IsDecChar(*a\cc[I])
        ProcedureReturn #PB_String_Lower
        
      ElseIf Not PX::IsDecChar(*b\cc[0])
        ProcedureReturn #PB_String_Greater
        
      ElseIf *a\cc[I] < *b\cc[0]
        If Not bias
          bias = #PB_String_Lower
        EndIf
        
      ElseIf *a\cc[I]  > *b\cc[0]
        If Not bias
          bias = #PB_String_Greater
        EndIf
        
      ElseIf Not *a\cc[I] And Not *b\cc[0]
        ProcedureReturn bias
      EndIf
      I + 1  
    Wend
    
    ProcedureReturn #PB_String_Equal
  EndProcedure
  
  Procedure.i _NaturalCompare_Left(*a.PX::pChar, *b.PX::pChar)
  ; ============================================================================
  ; NAME: _NaturalCompare_Left
  ; DESC: 
  ; DESC: 
  ; VAR(*a.pChar) : Pointer to 1st String (interpreted as pointerChar)
  ; VAR(*a.pChar) : Pointer to 2nd String (interpreted as pointerChar)
  ; RET.i: {#PB_String_Lower, #PB_String_Equal, #PB_String_Greater}, {-1,0,1}
  ; ============================================================================
    Protected I  
    
    ; Compare two left-aligned numbers: the first To have a
    ; different value wins.
    
    While *a\cc[I] And *b\cc[I]
      If (Not PX::IsDecChar(*a\cc[I])) And (Not PX::IsDecChar(*b\cc[0]))
        ProcedureReturn #PB_String_Equal
        
      ElseIf Not PX::IsDecChar(*a\cc[I])
        ProcedureReturn #PB_String_Lower
        
      ElseIf Not PX::IsDecChar(*b\cc[I])
        ProcedureReturn #PB_String_Greater
        
      ElseIf *a\cc[I]  < *b\cc[I]
        ProcedureReturn #PB_String_Lower
        
      ElseIf *a\cc[I]  > *b\cc[I]
        ProcedureReturn #PB_String_Greater
      EndIf
      
      I + 1  
    Wend
    
    ProcedureReturn #PB_String_Equal
  EndProcedure
 
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------

  Procedure.i NaturalCompareString(*a.PX::pChar, *b.PX::pChar, Mode=#PB_String_CaseSensitive )
  ; ============================================================================
  ; NAME: NaturalCompareString
  ; DESC: 
  ; DESC: 
  ; VAR(*a.pChar) : Pointer to 1st String (interpreted as pointerChar)
  ; VAR(*a.pChar) : Pointer to 2nd String (interpreted as pointerChar)
  ; RET.i: {#PB_String_Lower, #PB_String_Equal, #PB_String_Greater}, {-1,0,1}
  ; ============================================================================
    Protected.i aI, bI, result
    Protected.c ca, cb  
   
    While *a\cc[aI] And *b\cc[bI]
      
      ; Skip Tabs and Spaces
      While PX::IsSpaceTabChar(*a\cc[aI])
        aI + 1
      Wend
      
      ; Skip Tabs And Spaces
      While PX::IsSpaceTabChar(*b\cc[bI])
        bI + 1
      Wend
      
      ca = *a\cc[aI] 
      cb = *b\cc[bI]
      
      If (Not ca) And (Not cb) ; C++ If (!ca && !cb) {
  	    ProcedureReturn #PB_String_Equal    
  	  EndIf
     
   	  ; process compare digits
  	  If PX::IsDecChar(ca)  And  PX::IsDecChar(cb)
  	    
  	    If ca ='0' Or cb = '0'  ; if  (ca == '0' || cb == '0'); one of both is a '0'
  	      
  	      result = _NaturalCompare_Left((*a+aI), (*b+bI))	      
  	      If result 
  	        ProcedureReturn result  
  	      EndIf
  	      
  	    Else
  	      
  	      result = _NaturalCompare_Right((*a+aI), (*b+bI))
  	      If result
  	        ProcedureReturn result  
  	      EndIf
  	      
  	    EndIf
  	  EndIf 
  	  
  	  If Mode <> #PB_String_CaseSensitive
  	    PX::SetCharLo(ca)
  	    PX::SetCharLo(cb)
  	  EndIf
    
  	  If ca < cb
  	    ProcedureReturn #PB_String_Lower
  	  ElseIf ca > cb
  	    ProcedureReturn #PB_String_Greater
  	  EndIf
  	  
  	  aI + 1
  	  bI + 1
  	Wend
  	
  	ProcedureReturn #PB_String_Equal
  EndProcedure  
  
;   #PB_Sort_Ascending  ; 0
;   #PB_Sort_Descending ; 1
;   #PB_Sort_NoCase     ; 2
  
  Procedure NaturalSortList(List lstTxt.s(), SortMode = #PB_Sort_Ascending)
    Protected *Elem1, *Elem2
    Protected ret, I
    
    ResetList(lstTxt())
    
    *Elem1 = NextElement(lstTxt())
    *Elem2 = NextElement(lstTxt())
    Debug "-----------------------------------"
    
    While  *Elem1 And *Elem2
      Debug PeekS(PeekI(*Elem1))
      Debug PeekS(PeekI(*Elem2))
      I + 1
      ret = NaturalCompareString(*Elem1, *Elem2)
      
      If SortMode & #PB_Sort_Descending
        If ret = #PB_String_Greater
          SwapElements(lstTxt(), *Elem1, *Elem2)
          NextElement(lstTxt())
        EndIf    
      Else
        If ret = #PB_String_Lower
          SwapElements(lstTxt(), *Elem1, *Elem2)
          NextElement(lstTxt())
        EndIf          
      EndIf
           
      *Elem1 = NextElement(lstTxt())
      *Elem2 = NextElement(lstTxt())
    Wend
    
    Debug "I = " + I
  EndProcedure
    
EndModule

CompilerIf #PB_Compiler_IsMainFile    
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------
  
  EnableExplicit
  UseModule NatSort
  
  NewList TextList.s()
  
  Procedure CreateTestList(List lStr.s())
    Protected.s sTxt
    Protected.i I
    
    Restore Strings
    Read.s sTxt   
    While sTxt <> ""
      AddElement( lStr())
      lStr() = sTxt
      Read.s sTxt
    Wend 
  EndProcedure
  
  CreateTestList(TextList())
  
  ForEach TextList()
    Debug TextList()  
  Next
  
  NaturalSortList(TextList())
  Debug ""
  Debug "SORTED!"
  ForEach TextList()
    Debug TextList()  
  Next
  

DataSection
  Strings: 
  Data.s "Ignoring leading spaces."
  Data.s "ignore leading spaces:  2-2"
  Data.s " ignore leading spaces:  2-1"
  Data.s "  ignore leading spaces:  2+0"
  Data.s "   ignore leading spaces:  2+1"
  
  Data.s "Ignoring multiple adjacent spaces (MAS)."
  Data.s "ignore MAS spaces:  2-2"
  Data.s "ignore MAS  spaces:  2-1"
  Data.s "ignore MAS   spaces:  2+0"
  Data.s "ignore MAS    spaces:  2+1"
  
  Data.s "Equivalent whitespace characters."
  Data.s "Equiv.  spaces:     3-3"
  Data.s "Equiv. \rspaces:    3-2"
  Data.s "Equiv. \x0cspaces:  3-1"
  Data.s "Equiv. \x0bspaces:  3+0"
  Data.s "Equiv. \nspaces:    3+1"
  Data.s "Equiv. \tspaces:    3+2"
  
  Data.s "Case Independent sort."
  Data.s "cASE INDEPENDENT:  3-2"
  Data.s "caSE INDEPENDENT:  3-1"
  Data.s "casE INDEPENDENT:  3+0"
  Data.s "case INDEPENDENT:  3+1"
  
  Data.s "Numeric fields as numerics."
  Data.s "foo100bar99baz0.txt"
  Data.s "foo100bar10baz0.txt"
  Data.s "foo1000bar99baz10.txt"
  Data.s "foo1000bar99baz9.txt"
  
  Data.s "Title sorts."
  Data.s "The Wind in the Willows"
  Data.s "The 40th step more"
  Data.s "The 39 steps"
  Data.s "Wanda"
  Data.s ""
  
  Replace_DE:
  Data.s "ä", "ae", ""
  Data.s "ö", "oe", ""
  Data.s "ü", "ue", ""
  
  Data.s "A", "Ae", "#PB_String_CaseSensitive"
  Data.s "Ö", "Oe", "#PB_String_CaseSensitive"
  Data.s "Ü", "Ue", "#PB_String_CaseSensitive"
  
  Data.s "ß", "ss", ""

CompilerEndIf

  
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 123
; FirstLine = 104
; Folding = ---
; Optimizer
; CPU = 5