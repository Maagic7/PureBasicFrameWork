; ===========================================================================
; FILE : PbFw_Module_StringSSE.pb
; NAME : PureBasic Framework : Module String SSE [StrSSE::]
; DESC : 
; DESC : using the MMX, SSE Registers, to speed up String operations
; DESC :
; SOURCES:  https://en.wikibooks.org/wiki/X86_Assembly/SSE#The_Four_Instructions
;           https://en.wikibooks.org/wiki/X86_Assembly/SSE
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/04
; VERSION  :  0.1 Brainstorming  Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
 ; 2023/07/31 S.Maag : SSE_StringCompare Bug fixed

;} 
;{ TODO: 
; Implement all the SSE optimations for the C-Backend on x86
; propably by using the C intrinsic Macros
;}
; ===========================================================================

;{ Description PCmpIStrI

; PCmpIStrI arg1, arg2, IMM8

; modified Flags
;     CF is reset If IntRes2 is zero, set otherwise
;     ZF is set If a null terminating character is found in arg2, reset otherwise
;     SF is set If a null terminating character is found in arg1, reset otherwise
;     OF is set To IntRes2[0]
;     AF is reset
;     PF is reset
; ----------------------------------------------------------------------
; IMM8[1:0] specifies the format of the 128-bit source data
; ----------------------------------------------------------------------
; 00b 	unsigned bytes(16 packed unsigned bytes)
; 01b 	unsigned words(8 packed unsigned words)
; 10b 	signed bytes(16 packed signed bytes)
; 11b 	signed words(8 packed signed words) 

; ----------------------------------------------------------------------
; IMM8[3:2] specifies the aggregation operation whose result will 
;           be placed in intermediate result 1, which we will refer to 
;           as IntRes1. The size of IntRes1 will depend on the format
;           of the source Data, 16-bit for packed bytes and 
;           8-bit For packed words: 
; ----------------------------------------------------------------------
; 00b Equal Any, arg1 is a character set, arg2 is the string to search in.
;     IntRes1[i] is set To 1 If arg2[i] is in the set represented by arg1
;
;       arg1    = "aeiou"
;       arg2    = "Example string 1"
;       IntRes1 =  0010001000010000

; 01b Ranges, arg1 is a set of character ranges i.e. "09az" means all
;     characters from 0 To 9 And from a To z., arg2 is the string To search over. 
;     IntRes1[i] is set To 1 If arg[i] is in any of the ranges represented by arg
;
;         arg1    = "09az"
;         arg2    = "Testing 1 2 3, T"
;         IntRes1 =  0111111010101000

; 10b Equal Each, arg1 is string one and arg2 is string two. 
;     IntRes1[i] is set To 1 If arg1[i] == arg2[i]
;
;         arg1    = "The quick brown "
;         arg2    = "The quack green "
;         IntRes1 =  1111110111010011

; 11b Equal Ordered, arg1 is a substring string to search for, arg2 is the 
;     string To search within. IntRes1[i] is set To 1 If the substring arg1 
;     can be found at position arg2[i]: 

;         arg1    = "he"
;         arg2    = ", he helped her "
;         IntRes1 =  0010010000001000

; ----------------------------------------------------------------------
; IMM8[5:4] specifies the polarity or the processing of IntRes1, into 
;           intermediate result 2, which will be referred To As IntRes2
; ----------------------------------------------------------------------
; 00b  Positive Polarity 	IntRes2 = IntRes1
; 01b  Negative Polarity 	IntRes2 = -1 XOr IntRes1
; 10b  Masked Positive 	  IntRes2 = IntRes1
; 11b  Masked Negative 	  IntRes2 = IntRes1 If reg/mem[i] is invalid Else ~IntRes1

; ----------------------------------------------------------------------
; IMM8[6] specifies the output selection, or how IntRes2 will be processed
;         into the output. For PCMPESTRI And PCMPISTRI, the output is an
;         index into the Data currently referenced by arg2
; ----------------------------------------------------------------------
; 0b 	Least Significant Index 	ECX contains the least significant set bit in IntRes2
; 1b 	Most Significant Index 	  ECX contains the most significant set bit in IntRes2 

; ----------------------------------------------------------------------
; IMM8[6] For PCMPESTRM and PCMPISTRM, the output is a mask reflecting 
;         all the set bits in IntRes2
; ----------------------------------------------------------------------
; 0b 	Least Significant Index 	Bit Mask, the least significant bits 
;                               of XMM0 contain the IntRes2 16(8) bit mask. 
;                               XMM0 is zero extended To 128-bits.
; 1b 	Most Significant Index 	  Byte/Word Mask, XMM0 contains IntRes2 expanded into byte/word mask 
; ----------------------------------------------------------------------

; EQUAL_ANY	        =   0000b
; RANGES		        =   0100b
; EQUAL_EACH	      =   1000b
; EQUAL_ORDERED	    =   1100b
; NEGATIVE_POLARITY = 010000b
; BYTE_MASK	       = 1000000b
;}

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
XIncludeFile "PbFw_Module_CPU.pb"          ; CPU::      CPU Module

DeclareModule StrSSE
  
  EnableExplicit
   
  ; ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;- ----------------------------------------------------------------------
  
  Declare.i SSE_LenAscii(*String)
  Declare.i SSE_LenStr(*String)
  Declare.i SSE_StringCompare(*String1, *String2)

EndDeclareModule

Module StrSSE
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  ;- ----------------------------------------------------------------------
  ;- Module Private
  ;- ----------------------------------------------------------------------

  Procedure.i SSE_LenAscii(*String)
    ; ============================================================================
    ; NAME: SSE_LenAscii
    ; DESC: Length in number of characters of Ascii Strings
    ; DESC: Use SSE PCmpIStrI operation. This is aprox. 3 times faster than PB Len()
    ; VAR(*String): Pointer to String 1
    ; RET.i: Number of Characters
    ; ============================================================================
     ;
  	; IMM8[1:0]	= 00b
    ;	Src data is unsigned bytes(16 packed unsigned bytes)
    
  	; IMM8[3:2]	= 10b
    ; 	We are using Equal Each aggregation
    
  	; IMM8[5:4]	= 00b
    ;	Positive Polarity, IntRes2	= IntRes1
    
  	; IMM8[6]	= 0b
  	;	ECX contains the least significant set bit in IntRes2
  	;
    ; XMM0 XMM1 XMM2 XMM3 XMM4
    ; XMM1 = [String1] : XMM2=[String2] : XMM3=WideCharMask
    
    DisableDebugger
    CompilerIf #PB_Compiler_64Bit
      
      !MOV RDX, [p.p_String] 
      !PXOR XMM0, XMM0
      !MOV RAX, -16
      
      !loop_strLenAscii:  
        !ADD RAX, 16    
        !PCMPISTRI XMM0, [RDX+RAX], 0001010b ; EQUAL_EACH, Unis
      !JNZ loop_strLenAscii
      ; ECX will contain the offset from edx+eax where the first null
    	; terminating character was found.
      !ADD RAX, RCX    
      
    CompilerElse   
      !MOV EDX, [p.p_String] 
      !PXOR XMM0, XMM0
      !MOV EAX, -16
      
      !loop_strLenAscii:  
        !ADD EAX, 16    
        !PCMPISTRI XMM0, [EDX+EAX], 0001000b ; EQUAL_EACH
      !JNZ loop_strLenAscii
      ; ECX will contain the offset from edx+eax where the first null
    	; terminating character was found.
      !ADD EAX, ECX
    CompilerEndIf 
    
    ProcedureReturn
    EnableDebugger
  EndProcedure
  
  Procedure.i SSE_LenStr(*String)
    ; ============================================================================
    ; NAME: SSE_LenStr
    ; DESC: Length in number of characters of 2-Byte Char Strings
    ; DESC: Use SSE PCmpIStrI operation. This is aprox. 3 times faster than PB Len()
    ; VAR(*String): Pointer to String
    ; RET.i: Number of Characters
    ; ============================================================================
    ;
  	; IMM8[1:0]	= 00b
  	;	Src data is unsigned bytes(16 packed unsigned bytes)
  	; IMM8[3:2]	= 10b
  	; 	We are using Equal Each aggregation
  	; IMM8[5:4]	= 00b
  	;	Positive Polarity, IntRes2	= IntRes1
  	; IMM8[6]	= 0b
  	;	ECX contains the least significant set bit in IntRes2
    
    ; XMM0 XMM1 XMM2 XMM3 XMM4
    ; XMM1 = [String1] : XMM2=[String2] : XMM3=WideCharMask
    
    DisableDebugger
    CompilerIf #PB_Compiler_64Bit 
      
      !MOV RDX, [p.p_String] 
      !PXOR XMM0, XMM0
      !MOV RAX, -16
      
      !loop_strlen:  
        !ADD RAX, 16
        !MOVDQU XMM1, DQWORD[RDX+RAX]
        !PCMPISTRI XMM0, XMM1, 0001001b  ; EQUAL_EACH WORD
      !JNZ loop_strlen
      
      ; RCX will contain the offset from RDX+RAX where the first null
    	; terminating character was found.
      !SHR RAX, 1
      !ADD RAX, RCX
      ProcedureReturn
    CompilerElse
      
      !MOV EDX, [p.p_String] 
      !PXOR XMM0, XMM0
      !MOV EAX, -16
      
      !loop_strlen:  
        !ADD EAX, 16
        !MOVDQU XMM1, DQWORD[EDX+EAX]
        !PCMPISTRI XMM0, XMM1, 0001001b  ; EQUAL_EACH WORD
      !JNZ loop_strlen
      
      ; RCX will contain the offset from edx+eax where the first null
      ; terminating character was found.
      !SHR EAX, 1
      !ADD EAX, ECX
      ProcedureReturn
      
    CompilerEndIf
    EnableDebugger
  EndProcedure
  
  Procedure.i SSE_StringCompare(*String1, *String2)
    ; ============================================================================
    ; NAME: SSE_StringCompare
    ; DESC: Compares 2 Strings with SSE operation (PCmpIStrI)
    ; VAR(*String1): Pointer to String 1
    ; VAR(*String2): Pointer to String 2
    ; RET.i: 0 = (S1=S2), >0 = (S1>S2), <0 = (S1<S2)
    ; ============================================================================
        
    ; XMM0 XMM1 XMM2 XMM3 XMM4
    ; XMM1 = [String1] : XMM2=[String2]
    DisableDebugger
    CompilerIf #PB_Backend_Asm
      CompilerIf #PB_Compiler_64Bit 
  
        !MOV RAX, [p.p_String1]
        !MOV RDX, [p.p_String2]
        ; Subtract s2(RDX) from s1(RAX). This admititedly looks odd, but we
      	; can now use RDX to index into s1 and s2. As we adjust RDX to move
      	; forward into s2, we can then add RDX to RAX and this will give us
      	; the comparable offset into s1 i.e. if we take RDX + 16 then:
      	;
      	;	RDX     = RDX + 16		        = RDX + 16
      	;	RAX+RDX	= RAX -RDX + RDX + 16	= RAX + 16
      	;
      	; therefore RDX points to s2 + 16 and RAX + RDX points to s1 + 16.
      	; We only need one index, convoluted but effective.
      
      	!SUB RAX, RDX
      	!SUB RDX, 16		; Avoid extra jump in main loop 
           
        !strcmpLoop:
         	!ADD	RDX, 16
         	!MOVDQU XMM2, DQWORD[RDX]
         	
         	!MOVDQU XMM1, DQWORD[RDX+RAX]
      
        	; IMM8[1:0]	= 00b
        	  ;	00b: Src data is unsigned bytes(16 packed unsigned bytes)
         	  ;	01b: Src data is unsigned words( 8 packed unsigned words)
        	
         	; IMM8[3:2]	= 10b
        	; 	We are using Equal Each aggregation
        	; IMM8[5:4]	= 01b
        	;	Negative Polarity, IntRes2	= -1 XOR IntRes1
        	; IMM8[6]	= 0b
        	;	RCX contains the least significant set bit in IntRes2  	
         	
        	!PCMPISTRI XMM2, XMM1, 0011001b ; EQUAL_EACH + NEGATIVE_POLARITY + UNSIGNED_WORDS  	
        	; Loop while ZF=0 and CF=0:
        	;	1) We find a null in s1(RDX+RAX) ZF=1
        	;	2) We find a char that does not match CF=1  	
        !JA	strcmpLoop ; IF CF=0 And ZF=0     	
      	; Jump if CF=1, we found a mismatched char
      	!JC	strcmpDiff ; IF CF=1
      
      	; We terminated loop due to a null character i.e. CF=0 and ZF=1
        ; The Strings are equal
      	!XOR RAX, RAX
      	!jmp exitStrcmp	
      
      	!strcmpDiff:
          !ADD RAX, RDX	  ; Set offset into s1 to match s2
          
          ; RCX is offset from current poition in chars where two strings do not match,
        	; so copy the respective non-matching char into RAX and RDX and fill
        	; in remaining bits w/ zero. Because of 2ByteChar we have convert Word to Byte
          ; to get the correct AdressOffset by RCX*2
          
          !ADD RCX, RCX  ; Number of Chars to Adress Offset
          
          !MOVZX	RAX, WORD[RAX+RCX]
         	!MOVZX	RDX, WORD[RDX+RCX]
        	; If S1=S2 : Return (0) ; #PB_String_Equal
          ; If S1>S2 : Return (+) ; #PB_String_Greater
          ; If S1<S2 : Return (-) ; #PB_String_Lower
         	!SUB	RAX, RDX 
         	;!MOV RAX, RCX ; for test only, return Adress Offset
        !exitStrcmp:
        ProcedureReturn
        
      CompilerElse
        
        !MOV EAX, [p.p_String1]
        !MOV EDX, [p.p_String2]
      	!SUB EAX, EDX
      	!SUB EDX, 16		; Avoid extra jump in main loop 
           
        !strcmpLoop:
         	!ADD	EDX, 16
         	!MOVDQU XMM2, DQWORD[EDX]
         	
         	!MOVDQU XMM1, DQWORD[EDX+EAX]
       	  !PCMPISTRI XMM2, XMM1, 0011001b ; EQUAL_EACH + NEGATIVE_POLARITY + UNSIGNED_WORDS  	
        	; Loop while ZF=0 and CF=0:
        	;	1) We find a null in s1(EDX+EAX) ZF=1
        	;	2) We find a char that does not match CF=1  	
        !JA	strcmpLoop ; IF CF=0 And ZF=0   	
      	; Jump if CF=1, we found a mismatched char
      	!JC	strcmpDiff ; IF CF=1
      
      	; We terminated loop due to a null character i.e. CF=0 and ZF=1
        ; The Strings are equal
      	!XOR EAX, EAX
      	!jmp exitStrcmp	
      
      	!strcmpDiff:
          !ADD EAX, EDX	  ; Set offset into s1 to match s2             
          !ADD ECX, ECX  ; Number of Chars to Adress Offset       
          !MOVZX	EAX, WORD[EAX+ECX]
         	!MOVZX	EDX, WORD[EDX+ECX]
        	; If S1=S2 : Return (0) ; #PB_String_Equal
          ; If S1>S2 : Return (+) ; #PB_String_Greater
          ; If S1<S2 : Return (-) ; #PB_String_Lower
         	!SUB	EAX, EDX 
         	;!MOV EAX, ECX ; for test only, return Adress Offset
        !exitStrcmp:
        ProcedureReturn
        
      CompilerEndIf
      
    CompilerElse
      
  CompilerEndIf
    EnableDebugger
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Initalisation
  ;- ----------------------------------------------------------------------
  
  ; PCmpIStrI needs SSE4.2
  If CPU::CpuMultiMediaFeatures\SSE4_2
    Debug "SSE4.2 is supported"
  EndIf
  
EndModule

CompilerIf #PB_Compiler_IsMainFile    
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------
  
  EnableExplicit

  UseModule StrSSE
  
  Define sTest.s, sTest2.s, sASC.s
  Define sDbg.s
  Define I
  
  Dim bChar.b(255)  ; ASCII CHAR Array
  
  For I=0 To 99     ; Fill Char Array with 100 Ascii Chars
    bChar(i) = 33+I
  Next  
    
  sTest= Space(255)   ; Fill TestString with 255 Spaces
  
  sDbg= "PB: Len() = "  + Len(sTest)
  Debug sDbg
  sDbg = "SSE Len = " + Str(SSE_LenStr(@sTest))
  Debug sDbg
  sDbg = "ASCII Len() = " + Str(SSE_LenAscii(@bChar(0)))
  Debug sDbg
  
  Define S1.s, S2.s
  Define ret
  S1 = "Ich bin ein langer String, in welchem man nach 1234 suchen kann 5677"
  S2 = "Ich bin ein langer String, in welchem man nach 1234 suchen kann 5679"
  ; S1 = "01234567"
  ; S2 = "01234568"
  
  ret = SSE_StringCompare(@S1, @S2)
  Debug "SSE-StringCompare = " + ret
  
  ; ----------------------------------------------------------------------
  ; TIMING TEST
  ; ----------------------------------------------------------------------
  
  #cst_Loops = 10000000
  
  Define T1, T2, txtStrLen.s, txtStrCompare.s
  
  Debug "Stringlength"
  Debug Str(@S1 % 32) + " : " + Hex(@S1)
  Debug Str(@S2 % 16) + " : " + Hex(@S2)
  
  ; ----------------    StringLength ----------------------
  ; SSE Assembler Version
  T1 = ElapsedMilliseconds()
  For I = 1 To #cst_Loops
    ret = SSE_LenStr(@S1) 
  Next
  T1 = ElapsedMilliseconds() - T1
  
  ; Standard PB StringLenth
  T2 = ElapsedMilliseconds()
  For I = 1 To #cst_Loops
    ;ret = Len(S1)
    ret = MemoryStringLength(@S1)
  Next
  T2 = ElapsedMilliseconds() - T2
  
  txtStrLen = "StringLength  " + #cst_Loops + " Calls : ASM SSE = " + T1 + " / " + "PB Version = " + T2
  
  
  ; ----------------    StringCompare ----------------------
  
  ; SSE Assembler Version
  T1 = ElapsedMilliseconds()
  For I = 1 To #cst_Loops
    ret = SSE_StringCompare(@S1, @S2)
  Next
  T1 = ElapsedMilliseconds() - T1
  
  ; Standard PB StringLenth
  T2 = ElapsedMilliseconds()
  For I = 1 To #cst_Loops
    ret = CompareMemoryString(@S1, @S2)
  Next
  T2 = ElapsedMilliseconds() - T2
  
  txtStrCompare = "StringCompare " + #cst_Loops + " Calls : ASM SSE = " + T1 + " / " + "PB Version = " + T2
  
  MessageRequester("Timing results", txtStrLen + #CRLF$ + txtStrCompare)
  
CompilerEndIf

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 203
; FirstLine = 293
; Folding = 8--
; Optimizer
; CPU = 5