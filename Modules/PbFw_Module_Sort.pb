; ===========================================================================
;  FILE: PbFw_Module_Sort.pb
;  NAME: Module Sort [Sort::]
;  DESC: Sorting functions 
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://www.happycoders.eu/de/algorithmen/quicksort/ 
;     https://www.happycoders.eu/de/algorithmen/mergesort/
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/04/11
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.01
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
; 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_PB.pb"          ; PB::      Purebasic Extention Module
XIncludeFile "PbFw_Module_Debug.pb"       ; DBG::     Debug Module

; XIncludeFile ""

DeclareModule Sort
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  Structure pChar   ; virtual CHAR-ARRAY, used as Pointer to overlay on strings 
    a.a
    c.c
    aa.a[0]          ; fixed ARRAY Of CHAR Length 0
    cc.c[0]          
  EndStructure
  
  Prototype NaturalCompareString (StringA$, StringB$, Mode=#PB_String_CaseSensitive)
  Global NaturalCompareString.NaturalCompareString
  
  Declare.i QuickSortIntArray(Array IntArray(1), IndexStart=0, IndexEnd=#PB_Default, PbSort=#PB_Sort_Ascending)
  Declare.i QuickSortStringArray(Array StrArray(1), IndexStart=0, IndexEnd=#PB_Default, PbSort=#PB_Sort_Ascending|#PB_String_CaseSensitive)

EndDeclareModule


Module Sort
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;- ----------------------------------------------------------------------
  ;- Module private Functions
  ;- ----------------------------------------------------------------------
  
  Procedure _QuickSortIntArray_Asc(Array IntArray(1), IndexStart, IndexEnd)
  ; ============================================================================
  ; NAME: _QuickSortIntArray_Asc
  ; DESC: Private recursive function to Quicksort an Integer Array ascending
  ; VAR(Array IntArray(1)) : The 1-dimensional Integer Array
  ; VAR(IndexStart): Start sorting at Index  
  ; VAR(IndexEnd)  : End sorting at Index  
  ; RET: - 
  ; ============================================================================
    
    Protected.i Pivot  = IntArray((IndexStart + IndexEnd) / 2)    ; Value of the Pivot Element (SplittingElement)
    Protected.i idxUp  = IndexStart       ; Index to count up from IndexStart
    Protected.i idxDown  = IndexEnd       ; Index to count down from IndexEnd
        
    Repeat   
      While IntArray(idxDown) > Pivot ; search first element which is lower or equal than pivot
        idxDown - 1
      Wend   
      
      While IntArray(idxUp) < Pivot  ; search first element which is greater or equal than pivot
        idxUp + 1
      Wend   
      
      If idxUp <= idxDown  ; if index of first greater element [idxUp] is higher than first lower element THEN SWAP
        Swap IntArray(idxDown), IntArray(idxUp)
        idxUp + 1 : idxDown - 1
      EndIf   
    Until idxUp > idxDown
    
    ; if presorting is ready, split again the lo and hi side of the presorted Array
    If IndexStart < idxDown
      _QuickSortIntArray_Asc(IntArray(), IndexStart, idxDown) ; recursive split into 2 parts
    EndIf   
    If idxUp < IndexEnd
      _QuickSortIntArray_Asc(IntArray(), idxUp, IndexEnd) ; recursive split into 2 parts
    EndIf   
  EndProcedure
  
  Procedure _QuickSortIntArray_Des(Array IntArray(1), IndexStart, IndexEnd)
  ; ============================================================================
  ; NAME: _QuickSortIntArray_Des
  ; DESC: Private recursive function to Quicksort an Integer Array descending
  ; VAR(Array IntArray(1)) : The 1-dimensional Integer Array
  ; VAR(IndexStart): Start sorting at Index  
  ; VAR(IndexEnd)  : End sorting at Index  
  ; RET: - 
  ; ============================================================================
    
    Protected.i Pivot  = IntArray((IndexStart + IndexEnd) / 2)    ; Value of the Pivot Element (SplittingElement)
    Protected.i idxUp  = IndexStart       ; Index to count up from IndexStart
    Protected.i idxDown  = IndexEnd       ; Index to count down from IndexEnd
        
    Repeat   
      While IntArray(idxDown) < Pivot ; search first element which is lower or equal than pivot
        idxDown - 1
      Wend   
      
      While IntArray(idxUp) > Pivot  ; search first element which is greater or equal than pivot
        idxUp + 1
      Wend   
      
      If idxUp <= idxDown  ; if index of first greater element [idxUp] is higher than first lower element THEN SWAP
        Swap IntArray(idxDown), IntArray(idxUp)
        idxUp + 1 : idxDown - 1
      EndIf   
    Until idxUp > idxDown
    
    ; if presorting is ready, split again the lo and hi side of the presorted Array
    If IndexStart < idxDown
      _QuickSortIntArray_Des(IntArray(), IndexStart, idxDown) ; recursive split into 2 parts
    EndIf   
    If idxUp < IndexEnd
      _QuickSortIntArray_Des(IntArray(), idxUp, IndexEnd) ; recursive split into 2 parts
    EndIf   
  EndProcedure
  
  Procedure _QuickSortStringArray_Asc(Array StrArray(1), IndexStart, IndexEnd)
  ; ============================================================================
  ; NAME: _QuickSortStringArray_Asc
  ; DESC: Private recursive function to Quicksort an String Array ascending
  ; VAR(Array StrArray(1)) : The 1-dimensional String Array
  ; VAR(IndexStart): Start sorting at Index  
  ; VAR(IndexEnd)  : End sorting at Index  
  ; RET: - 
  ; ============================================================================
    
    Protected.i Pivot  = StrArray((IndexStart + IndexEnd) / 2)    ; Value of the Pivot Element (SplittingElement)
    Protected.i idxUp  = IndexStart       ; Index to count up from IndexStart
    Protected.i idxDown  = IndexEnd       ; Index to count down from IndexEnd
        
    Repeat   
      While StrArray(idxDown) > Pivot ; search first element which is lower or equal than pivot
        idxDown - 1
      Wend   
      
      While StrArray(idxUp) < Pivot  ; search first element which is greater or equal than pivot
        idxUp + 1
      Wend   
      
      If idxUp <= idxDown  ; if index of first greater element [idxUp] is higher than first lower element THEN SWAP
        Swap StrArray(idxDown), StrArray(idxUp)
        idxUp + 1 : idxDown - 1
      EndIf   
    Until idxUp > idxDown
    
    ; if presorting is ready, split again the lo and hi side of the presorted Array
    If IndexStart < idxDown
      _QuickSortIntArray_Asc(StrArray(), IndexStart, idxDown) ; recursive split into 2 parts
    EndIf   
    If idxUp < IndexEnd
      _QuickSortIntArray_Asc(StrArray(), idxUp, IndexEnd) ; recursive split into 2 parts
    EndIf   
  EndProcedure

  Procedure.i _NaturalCompare_Right(*A.PB::pChar, *B.PB::pChar)
  ; ============================================================================
  ; NAME: _NaturalCompare_Right
  ; DESC: helper function for NaturalCompareString
  ; DESC: 
  ; VAR(*A.pChar) : Pointer to 1st String (interpreted as pointerChar)
  ; VAR(*B.pChar) : Pointer to 2nd String (interpreted as pointerChar)
  ; RET.i: {#PB_String_Lower, #PB_String_Equal, #PB_String_Greater}, {-1,0,1}
  ; ============================================================================
    Protected bias  
    
    ; The longest run of digits wins.  That aside, the greatest
    ; value wins, but we can't know that it will until we've scanned
    ; both numbers To know that they have the same magnitude, so we
    ; remember it in BIAS.
    
    While *A\c And *B\c
      
      If (Not PB::IsDecChar(*A\c)) And (Not PB::IsDecChar(*B\c))
        ProcedureReturn bias
        
      ElseIf (Not PB::IsDecChar(*A\c))
        ProcedureReturn #PB_String_Lower
        
      ElseIf (Not PB::IsDecChar(*B\c))
        ProcedureReturn #PB_String_Greater
        
      ElseIf *A\c < *B\c
        If Not bias
          bias = #PB_String_Lower
        EndIf
        
      ElseIf *A\c > *B\c
        If Not bias
          bias = #PB_String_Greater
        EndIf
        
      ElseIf (Not *A\c) And (Not *B\c)
        ProcedureReturn bias
      EndIf
   	  PB::INCC(*A)    ; increment CharPointer
  	  PB::INCC(*B)    ; increment CharPointer
   Wend
    
    ProcedureReturn #PB_String_Equal
  EndProcedure
  
  Procedure.i _NaturalCompare_Left(*A.PB::pChar, *B.PB::pChar)
  ; ============================================================================
  ; NAME: _NaturalCompare_Left
  ; DESC: helper function for NaturalCompareString
  ; DESC: 
  ; VAR(*A.pChar) : Pointer to 1st String (interpreted as pointerChar)
  ; VAR(*B.pChar) : Pointer to 2nd String (interpreted as pointerChar)
  ; RET.i: {#PB_String_Lower, #PB_String_Equal, #PB_String_Greater}, {-1,0,1}
  ; ============================================================================
     
    ; Compare two left-aligned numbers: the first To have a
    ; different value wins.
    
    While *A\c And *B\c
      
      If (Not PB::IsDecChar(*A\c)) And (Not PB::IsDecChar(*B\c)) ; both not a Decimal
        ProcedureReturn #PB_String_Equal
        
      ElseIf Not PB::IsDecChar(*A\c)
        ProcedureReturn #PB_String_Lower
        
      ElseIf Not PB::IsDecChar(*B\c)
        ProcedureReturn #PB_String_Greater
        
      ElseIf *A\c  < *B\c
        ProcedureReturn #PB_String_Lower
        
      ElseIf *A\c  > *B\c
        ProcedureReturn #PB_String_Greater
      EndIf
      
  	  PB::INCC(*A)    ; increment CharPointer
  	  PB::INCC(*B)    ; increment CharPointer
    Wend
    
    ProcedureReturn #PB_String_Equal
  EndProcedure
  
  Procedure.i _NaturalCompareString(*A.PB::pChar, *B.PB::pChar, Mode=#PB_String_CaseSensitive )
  ; ============================================================================
  ; NAME: _NaturalCompareString
  ; DESC: !PointerVersion! use it as ProtoType NaturalCompareString()
  ; DESC: 
  ; VAR(*A.pChar) : Pointer to 1st String (interpreted as pointerChar)
  ; VAR(*B.pChar) : Pointer to 2nd String (interpreted as pointerChar)
  ; RET.i: {#PB_String_Lower, #PB_String_Equal, #PB_String_Greater}, {-1,0,1}
  ; ============================================================================
    Protected.i result
   
    While *A\c And *B\c
      
      ; Skip Tabs and Spaces at A
      While PB::IsSpaceTabChar(*A\c)
 	      PB::INCC(*A)    ; increment CharPointer
      Wend
      
      ; Skip Tabs and Spaces at B
      While PB::IsSpaceTabChar(*B\c)
 	      PB::INCC(*B)    ; increment CharPointer
      Wend
      
      ; both at EndOfString -> only SPACE and TAB -> Strings are equal!
      If (Not *A\c) And (Not *B\c) ; C++ If (!ca && !cb) {
  	    ProcedureReturn #PB_String_Equal    
  	  EndIf
     
   	  ; process compare digits
  	  If PB::IsDecChar(*A\c) And PB::IsDecChar(*B\c)
  	    If *A\c ='0' Or *B\c = '0'  ; if  (ca == '0' || cb == '0'); one of both is a '0'      
  	      result = _NaturalCompare_Left(*A, *B)	      
  	      If result 
  	        ProcedureReturn result  
  	      EndIf 	      
  	    Else	      
  	      result = _NaturalCompare_Right(*A, *B)
  	      If result
  	        ProcedureReturn result  
  	      EndIf	      
  	    EndIf
  	  EndIf 
  	  
  	  If Mode <> #PB_String_CaseSensitive
  	    PB::SetCharLo(*A\c)
  	    PB::SetCharLo(*B\c)
  	  EndIf
    
  	  If *A\c < *B\c
  	    ProcedureReturn #PB_String_Lower
  	  ElseIf *A\c > *B\c
  	    ProcedureReturn #PB_String_Greater
  	  EndIf 	  
  	  PB::INCC(*A)    ; increment CharPointer
  	  PB::INCC(*B)    ; increment CharPointer
  	Wend
  	
  	ProcedureReturn #PB_String_Equal
  EndProcedure  
  NaturalCompareString = @_NaturalCompareString()     ; Bind ProcedureAdress to the PrototypeHandler

  ;- ----------------------------------------------------------------------
  ;- Module public Functions
  ;- ----------------------------------------------------------------------

  Procedure.i QuickSortIntArray(Array IntArray(1), IndexStart=0, IndexEnd=#PB_Default, PbSort=#PB_Sort_Ascending)
  ; ============================================================================
  ; NAME: QuickSortIntArray
  ; DESC: Quicksort an Integer Array
  ; VAR(Array IntArray(1)) : The 1-dimensional Integer Array
  ; VAR(IndexStart): Start sorting at Index  
  ; VAR(IndexEnd)  : End sorting at Index  
  ; RET: - 
  ; ============================================================================
   Protected Size
    
    Size = ArraySize(IntArray())
    
    If Size
      
      If IndexEnd = #PB_Default ; -1
        IndexEnd = Size
      EndIf
      
      If IndexStart < 0
        IndexStart = 0
      EndIf
      
      If PbSort = #PB_Sort_Ascending
        _QuickSortIntArray_Asc(IntArray(),IndexStart,IndexEnd)     
      Else
        _QuickSortIntArray_Des(IntArray(),IndexStart,IndexEnd)             
      EndIf
    
       ProcedureReturn #True
     Else
       ProcedureReturn #False   
    EndIf
  EndProcedure
  
  Procedure.i QuickSortStringArray(Array StrArray(1), IndexStart=0, IndexEnd=#PB_Default, PbSort=#PB_Sort_Ascending|#PB_String_CaseSensitive )
  ; ============================================================================
  ; NAME: QuickSortIntArray
  ; DESC: Quicksort an Integer Array
  ; VAR(Array IntArray(1)) : The 1-dimensional Integer Array
  ; VAR(IndexStart): Start sorting at Index  
  ; VAR(IndexEnd)  : End sorting at Index  
  ; RET: - 
  ; ============================================================================
    Protected Size
    
    Size = ArraySize(StrArray())
    
    If Size     
      If IndexEnd = #PB_Default ; -1
        IndexEnd = Size
      EndIf
      
      PB::LimitToNull(IndexStart)
            
      If PbSort & #PB_Sort_Ascending
        _QuickSortStringArray_Asc(StrArray(),IndexStart,IndexEnd)     
      Else
        ;_QuickSortStringArray_Des(StrArray(),IndexStart,IndexEnd)             
      EndIf    
      ProcedureReturn #True
    Else
      ProcedureReturn #False   
    EndIf
  EndProcedure
  

EndModule


CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  UseModule Sort
  
CompilerEndIf
; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 322
; FirstLine = 278
; Folding = ---
; Optimizer
; CPU = 5