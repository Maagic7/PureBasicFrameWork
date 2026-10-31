; DoubleMetaphone - A phonetic search algorithm, much better than Soundex() 
; Reduces alphabet to the 14 consonant sounds: 
; X S K J T F H L M N P R 0 W 
; drop vowels except at the beginning 

XIncludeFile "..\..\Modules\PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

DeclareModule MTF
  
  Structure TDoubleMetaphone 
    strI.s 
    strII.s 
    n.i 
  EndStructure 
  
EndDeclareModule


Module MTF
  
  #vowels = "AEIOUY" 
  Macro _IsVowels(_CharValue)
    Bool(_CharValue)='A' Or _CharValue)='E' Or _CharValue)='I' Or _CharValue)='O' Or _CharValue)='U' Or _CharValue)='Y')  
  EndMacro
  
  Macro _AddCharS1(_CharValue)
    *pS1\c = _CharValue
    *pS1 + SizeOf(Character)
  EndMacro
  
  Macro _AddCharS2(_CharValue)
    *pS2\c = _CharValue  
    *pS1 + SizeOf(Character)
  EndMacro
 
  Procedure.i EncodeDoubleMetaphone(String$, *outDblMTF.TDoubleMetaphone)
    Protected *pC.PX::pChar, *pRd.PX::pChar 
    Protected *pS1.Character, *pS2.Character
    Protected xSlavoGermanic, L
    Protected S1$, S2$
    
    
    S1$ = Space(6)
    *pS1 = @S1$
    S2$ = Space(6)
    *pS2 = @S2$
    
    String$ = UCase(String$)
    *pC=@String$
    
    PX::CSkipSpaceTab(*pC)
    
    Select *pC\c
      Case 'G', 'K', 'P'    ; GN, KN, PN
        If *pC\c[1] = 'N'   
          PX::CInc(*pC)     ; Skip
        EndIf
               
      Case 'W'              ; WR
        If *pC\c[1] = 'R'
          PX::CInc(*pC)     ; Skip
        EndIf
        
      Case 'P'              ; PS
        If *pC\c[1] = 'S'
          PX::CInc(*pC)     ; Skip
        EndIf
        
      Case 'A', 'E', 'I', 'O', 'U', 'Y'  
        ; vowels
        _AddCharS1('A')
        _AddCharS2('A')
        PX::CInc(*pC)     ; Skip
       
      Case 'X'
        _AddCharS1('S')
        _AddCharS2('S')
         PX::CInc(*pC)     ; Skip
       
      Case 'C'
        If PeekS(*pC, 6) = "CAESAR"
          PX::CInc(*pC,5)  
          _AddCharS1('S')
          _AddCharS2('S')
          PX::CInc(*pC,2)     ; Skip  
        EndIf
        
    EndSelect
    
   
    *pRd=@String$
    ; Check for SlavoGermanic if "W", "K", "CZ", or "WITZ" is in the String
    While *pRd\c
      Select *pRd\c
        Case 'K', 'W'
          xSlavoGermanic = #True
          Break
          
        Case 'C'
          If *pRd\c[1] = 'Z'  
            xSlavoGermanic = #True
            Break
          EndIf
      EndSelect
    Wend
    
    ;- --------------------------------------------------
    ;- conversion
    ;- --------------------------------------------------
   
    While *pC\c
      Select *pC\c
          
        Case 'B'    ;-B 
          If *pC\c[1] = *pC\c : PX::CInc(*pC) : EndIf
          _AddCharS1('P')
          _AddCharS2('P')
          
        Case 'Ç'    ;-Ç 
          
        Case 'C'
          
        Case 'X' 
          
        Case 'Z'
          
          
      EndSelect
      
    Wend
    
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 118
; FirstLine = 71
; Folding = --
; DPIAware
; CPU = 5