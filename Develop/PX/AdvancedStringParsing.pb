
; A very simple Demo for advanced String parsing with pChar Structure

; pChar is part of PX::
; An adapted version of pAny especally for character use
;   Structure pChar   ; ATTENTION! Only use as Pointer Strukture! Do not define as a normal Var!
;     StructureUnion
;       a.a         ; ASCII   : 8 Bit unsigned  [0..255] 
;       c.c         ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
;       u.u         ; UNICODE : 2 Byte unsigned [0..65535]
;       aa.a[0]     ; ASCII   : 8 Bit unsigned  [0..255] 
;       cc.c[0]     ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
;       uu.u[0]     ; UNICODE : 2 Byte unsigned [0..65535]
;     EndStructureUnion
;   EndStructure 

; Last modified: 2025/08/14

EnableExplicit

; please download Module PX from:
; https://github.com/Maagic7/PureBasicFrameWork/blob/main/Modules/PbFw_Module_PX.pb

XIncludeFile "..\..\PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

UseModule PX

Enumeration
  #PbCmd_unknown
  #PbCmd_Procedure
  #PbCmd_Protected
  #PbCmd_Prototype
EndEnumeration

Dim txt.s(10)

Define *pC.PX::pChar
Define cnt

txt(0) = "  Procedure.l MyTestProc (*out.TTestSruct, Testvalue.i, config=#True)"
txt(1) = "    Procedure.d MyTestProc *out.TTestSruct, Testvalue.i, config=#True)"
txt(2) = "      Procedure.d MyTestProc (*out.TTestSruct, Testvalue.i, config=#True"

Define I
For I = 0 To 2
  *pC = @txt(I)
  Debug "***** Test " + Str(i) + " *****"
  Debug txt(I)
  Debug ""
  
  ; ------------------------------------------------------------
  ; first check Len(txt) with *pC - don't move the Pointer
  ; ------------------------------------------------------------
  ; This Methode of Len is slower than PB's Len() if the String is longer than 2 Characters 
  cnt = 0
  While *pC\c[cnt]
    cnt+1
  Wend
  Debug "pChar Len(txt) = " + cnt + " : PB Len() = " + Len(txt(I))
  
  Debug ""
  ; ------------------------------------------------------------
  ; Count Spaces and Tabs - don't move the Pointer
  ; ------------------------------------------------------------
  cnt = 0
  While IsSpaceTabChar(*pC\c[cnt])
    cnt +1
  Wend
  Debug "leading Spaces and Tabs = " +cnt
  
  ; ------------------------------------------------------------
  ; Skip Spaces and Tabs - move the Pointer
  ; ------------------------------------------------------------
  Debug ""
  Debug "Pointer to Text " + Str(*pC)
  Debug "Now skip Space and Tab -> move Pointer to first character"
  While IsSpaceTabChar(*pC\c)
    INCC(*pC)  ; INCC is the Macro to Increase a CharPointer 'INCCharPointer' 
  Wend
  Debug "Pointer of first Letter = " + Str(*pC) + " : Char = " + Chr(*pC\c)
  
  Debug ""
  Debug "Now we check for Procedure, Protected or Prototype"
  
  Define cmd
  
  Select LCaseChar(*pC\c) 
    Case 'p'
      If CompareMemoryString(*pC, @"procedure", #PB_String_NoCase, 9) = #PB_String_Equal
        ; ----------
        ; Procedure
        ; ----------
       cmd = #PbCmd_Procedure
        Debug "First word is " + PeekS(*pC, 9)
        INCC(*pC,9)    ; set Pointer to first Char after Procedure
        
      ElseIf CompareMemoryString(*pC, @"protected", #PB_String_NoCase, 9) = #PB_String_Equal
        ; ----------
        ; Protected
        ; ----------
        cmd = #PbCmd_Protected
        Debug "First word is " + PeekS(*pC, 9)
        INCC(*pC,9) ; set Pointer to first Char after Protected
         
      ElseIf CompareMemoryString(*pC, @"prototype", #PB_String_NoCase, 9) = #PB_String_Equal
        ; ----------
        ; Prototype
        ; ----------
        cmd = #PbCmd_Prototype
        Debug "First word is " + PeekS(*pC, 9)
        INCC(*pC,9) ; set Pointer to first Char after Prototype
        
      Else    ; no PB command found 
        
      EndIf
      
    ; Case 'e' 
      
    Default
     
  EndSelect
  
  Debug ""
  Select cmd
    Case #PbCmd_Procedure
      
      Select LCaseChar(*pC\c)
        Case 32 ; Space
          Debug "Procedure retrun type = i" 
          InCC(*pC) ; set Pointer after Type
        Case '.'
          Debug "Procedure retrun type = " + Chr(*pC\c[1]) 
          InCC(*pC,2) ; set Pointer after Type
      EndSelect
      
      ; now Skip Space and Tab, so we are at first character of ProcedureName    
      While IsSpaceTabChar(*pC\c)
        INCC(*pC)
      Wend
      
      Debug "First Char of ProcedureName = " + Chr(*pC\c)
      
      ; now find end of ProcedureName
      
      cnt=0
      ; stop if '(' or Space or Tab found
      While  *pC\c[cnt]<>'(' And (Not IsSpaceTabChar(*pC\c[cnt]) )
        If *pC\c[cnt] = 0    ; EndOf String Found
          Debug "Error missing bracket '('"
          Break
        EndIf      
        cnt + 1
      Wend
      Debug "ProcedureName = " + PeekS(*pC, cnt)
      InCC(*pC,cnt)
      
      ; now Skip Space and Tab, so we are at first character of Parameter '('   
      While IsSpaceTabChar(*pC\c)
        INCC(*pC)
      Wend
      
      ; if we skipped Space and Tab, the first Char now should be the bracket '('
      If *pC\c <> '('
        Debug "Error missing bracket '('"
      Else
        INCC(*pC) ; move to first Char after '('
        ; search for ')' and print Parameter List
        cnt=0
        While *pC\c[cnt] <> ')'
          If *pC\c[cnt] = 0    ; EndOfString reached
            Debug "Error: missing ')'" 
            Break
          EndIf       
          cnt+1
        Wend
        
        Debug "Parameter list : " + PeekS(*pC, cnt)
        
      EndIf
      
    Case #PbCmd_Protected
      
    Case #PbCmd_Prototype
      
    Default
      
  EndSelect
Next

Define DC.l
Define QC.q

CompilerIf Not #PB_Compiler_Debugger
Debug ""
Debug "------------------------------------------------------------"
Debug ""

;txt(0) = "12"
*pC = @txt(0)
cnt=0

;DisableDebugger
Define t1, t2, t3, t4, t5, n
Define l1, l2, l3, l4, l5
#Loops = 1000000
cnt = Len(txt(0))

t1 = ElapsedMicroseconds()
For I = 0 To #Loops
  cnt = Len(txt(0))
Next
t1 = ElapsedMicroseconds()-t1
l1 = cnt

t2 = ElapsedMicroseconds()
For I = 0 To #Loops
  cnt = MemoryStringLength(*pC)  
Next
t2 = ElapsedMicroseconds()-t2

l2 = cnt

t3 = ElapsedMicroseconds()
For I = 0 To #Loops
  cnt = 0
  While *pC\c[cnt]
    cnt+1
  Wend
Next
t3 = ElapsedMicroseconds()-t3
l3 = cnt

t4 = ElapsedMicroseconds()
For I = 0 To #Loops
  cnt = 0
  While DblCharEOS(*pC\dcc[cnt]) = 0
    cnt+1
  Wend
  cnt = cnt*2 + DblCharEOS(*pC\dcc[cnt])-1
Next
t4 = ElapsedMicroseconds()-t4
l4 = cnt

t5 = ElapsedMicroseconds()
For I = 0 To #Loops
  cnt = 0
  While QCharEOS(*pC\qcc[cnt]) = 0  ; ----------------------------------------------------------------------

    cnt+1
  Wend
  cnt = cnt*4 + QCharEOS(*pC\qcc[cnt])-1
Next
t5 = ElapsedMicroseconds()-t5
l5 = cnt

;EnableDebugger
OpenConsole()
PrintN("PB Len:   = " + Str(l1) + " :t1 =" + StrF(t1/1000,3))
PrintN("PB MemLen = " + Str(l2) + " :t2 =" + StrF(t2/1000,3))
PrintN("*pC\c[]  = " + Str(l3) + " :t3 =" + StrF(t3/1000,3))
PrintN("*pC\dcc[] = " + Str(l4) + " :t4 =" + StrF(t4/1000,3))
PrintN("*pC\qcc[] = " + Str(l5) + " :t5 =" + StrF(t5/1000,3))
PrintN("Press any key")
Input()
CompilerEndIf


; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 259
; FirstLine = 190
; Folding = -
; DPIAware
; CPU = 5