
; SEE FastString at PB Forum from 2012: https://www.purebasic.fr/english/viewtopic.php?p=375376#p375376

; ===========================================================================
; FILE : PbFw_Module_StringSSE.pb
; NAME : PureBasic Framework : Module String SSE [StrSSE::]
; DESC : using the MMX, SSE Registers, to speed up String operations
; DESC : CPU SSE4.2 support is needed
; DESC : 
; SOURCES:  https://en.wikibooks.org/wiki/X86_Assembly/SSE#The_Four_Instructions
;           https://en.wikibooks.org/wiki/X86_Assembly/SSE
;           https://www.strchr.com/strcmp_and_strlen_using_sse_4.2
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/04
; VERSION  :  0.52 Developper Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
 ; 2024/03/01 S.Maag : 16 Byte Aling check and manually align unaligend Strings
 ; 2024/01/09 S.Maag : SSE_StringCompare: now return -1,0,1 instead of char difference
 ;                     to be compatible with PB Command CompareMemoryString()
 ;                     Tested and Bugfixed FindStr
 ; 2023/07/31 S.Maag : SSE_StringCompare: compare Bug fixed

;} 
;{ TODO: For the C-Backend; add functions using SSE
; here the link to the Intel Intrsics Guide for SSE4.2
; https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#ssetechs=SSE4_2&ig_expand=924

; Implement all the SSE optimations for the C-Backend on x86
; propably by using the C intrinsic Macros
;}
; ===========================================================================

;{ Description PCmpIStrI

; PCmpIStrI arg1, arg2, IMM8  ; ATTENTION PCmpIStrI/M needs 16Byte aligned Memory

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

; FLAGs
; OF : Overflow flag
; SF : Sign flag      ; #True if negative
; ZF : Zero flag      ; #True if zero
; AF: Auxillary (carry) flag
; PF: Parity flag
; CF: Carry flag
;}

;{ ----------------------------------------------------------------------
;    The Problem of 16 Byte operations on lower aligend memory
;  ----------------------------------------------------------------------

; If we process 16 Bytes on lower aligned memory we may run into an overflow at the
; end of meory pages when the end of String is located in the last bytes
; of the memory page and the following page is not allocated to our process.
; Yes this will happen very seldom but it can happen. So it is a source of
; crashes may happen in years in the future. Because it can happen, it will happen!
; It is only a question of time!

; A memory page in x64 Systems is 4096 Bytes
; We look on a 8 Byte aligned String at the end of memory page to show the problem

;  a String followed by a NullChar and a further NullChar then the page ends
;                          EndOfString at Byte 4092..93 and a void 00        
; | ..... 'I am a String at the end of a memroy page' 0000| 
; if we process 16 Bytes at 8 Byte align starting at Byte 4088 we read until Byte 4103
; we read 8 Bytes into the next page. Now it will crash if the next page is not
; allocated to our process! We can use 16 Byte PCMPISTRI operation
; only if we are not at the end of a memory page or we have a 16 Byte align memory. 
;}
;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module
;XIncludeFile "PbFw_Module_CPU.pb"          ; CPU::      CPU Module

DeclareModule StrSSE
  
  EnableExplicit
   
  ; ----------------------------------------------------------------------
  ;- DECLARE
  ;- ----------------------------------------------------------------------
  
  Declare.i SSE_LenA(*String)
  Declare.i SSE_Len(*String)
  Declare.i SSE_StringCompare(*String1, *String2, Pos=0)
  Declare.i SSE_FindStr(*String, *StringToFind)

EndDeclareModule

Module StrSSE
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  IncludeFile "PbFw_ASM_Macros.pbi"
  
  #EQUAL_ANY	        = %0000
  #RANGES		          = %0100
  #EQUAL_EACH	        = %1000
  #EQUAL_ORDERED	    = %1100
  #NEGATIVE_POLARITY  = %0010000
  #BYTE_MASK	        = %1000000
  
  Structure pChar   ; virtual CHAR-ARRAY, used as Pointer to overlay on strings 
    a.a[0]          ; fixed ARRAY Of CHAR Length 0
    c.c[0]          
  EndStructure

  ;- ----------------------------------------------------------------------
  ;- Module Public
  ;- ----------------------------------------------------------------------

  Procedure.i SSE_LenA(*String)
  ; ============================================================================
  ; NAME: SSE_LenA
  ; DESC: Length in number of characters of Ascii Strings
  ; DESC: Use SSE PCmpIStrI operation. This is aprox. 3 times faster than PB Len()
  ; VAR(*String): Pointer to String 1
  ; RET.i: Number of Characters
  ; ============================================================================
    
    ; ATTENTION PCmpIStrI needs 16Byte aligned Memory
    ; If memory isn't aligned we have to align it manually
    ; by processing unalinged bytes in classic way and
    ; start with PCmpIStrI at aligned psoition.
    ; The Problem of analigned reading is the end of memory page (4096Bytes)
    ; if the following page is not allocated by our process.
    ; Memory exception because we cand read memory or other process.
    
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
      
      !XOR RDX, RDX           ; RDX = 0
      !XOR RCX, RCX           ; RCX = 0
      !MOV RAX, [p.p_String]  ; RAX = *String
      !@@:                    ; 
      !TEST RAX, 0Fh          ; Test for 16Byte align
      !JZ @f                  ; If NOT aligned
        !MOV DL, BYTE[RAX]    ;   process Char by Char until aligned
        !TEST RDX, RDX        ;   Check for EndOfString
        !JZ .Return           ;   Break if EndOfString
        !INC RAX              ; Pointer to NextChar
      !JMP @b                 ; Jump back to @@      
      !@@:                    ; from here we have 16Byte aligned address
      
      !PXOR XMM0, XMM0    
      !SUB RAX, 16
      
      !@@:  
        !ADD RAX, 16    
        !PCMPISTRI XMM0, [RAX], 0001000b ; EQUAL_EACH, unsigned_Bytes
      !JNZ @b
      ; ECX will contain the offset from eax where the first null
    	; terminating character was found.
      !ADD RAX, RCX    
      
      !.Return:
      !SUB RAX, [p.p_String] 
      ProcedureReturn
      
    CompilerElse   
      
      !XOR EDX, EDX           ; EDX = 0
      !XOR ECX, ECX           ; RCX = 0
      !MOV EAX, [p.p_String]  ; EAX = *String
      !@@:                    ; 
      !TEST EAX, 0Fh          ; Test for 16Byte align
      !JZ @f                  ; If NOT aligned
        !MOV DL, BYTE[EAX]    ;   process Char by Char until aligned
        !TEST EDX, EDX        ;   Check for EndOfString
        !JZ .Return           ;   Break if EndOfString
        !INC EAX              ; Pointer to NextChar
      !JMP @b                 ; Jump back to @@      
      !@@:                    ; from here we have 16Byte aligned address
      
      !PXOR XMM0, XMM0    
      !SUB EAX, 16
      
      !@@:  
        !ADD EAX, 16    
        !PCMPISTRI XMM0, [EAX], 0001000b ; EQUAL_EACH, unsigned_Bytes
      !JNZ @b
      ; ECX will contain the offset from eax where the first null
    	; terminating character was found.
      !ADD EAX, ECX    
      
      !.Return:
      !SUB EAX, [p.p_String] 
      ProcedureReturn
      
    CompilerEndIf 
    
    EnableDebugger
  EndProcedure
  
  Procedure.i SSE_Len(*String)
  ; ============================================================================
  ; NAME: SSE_Len
  ; DESC: Length in number of characters of 2-Byte Char Strings
  ; DESC: Use SSE PCmpIStrI operation. This is aprox. 3 times faster than PB Len()
  ; VAR(*String): Pointer to String
  ; RET.i: Number of Characters
  ; ============================================================================
    
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
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
      
      CompilerIf #PB_Compiler_64Bit     
        
        !XOR RDX, RDX
        !XOR RCX, RCX
        !MOV RAX, [p.p_String] 
        
        !@@:
        !TEST RAX, 0Fh
        !JZ @f
          !MOV DX, WORD [RAX]
          !TEST RDX, RDX
          !JZ .Return
          !INC RAX
        !JMP @b    
        !@@:
        
        !PXOR XMM0, XMM0
        !SUB RAX, 16      
        
        !@@:  
          !ADD RAX, 16
          !PCMPISTRI XMM0, [RAX], 0001001b  ; EQUAL_EACH WORD
        !JNZ @b
        
        ; RCX will contain the offset from RAX where the first null
      	; terminating character was found.
        !SHL RCX, 1   ; Word to Byte
        !ADD RAX, RCX
        
        !.Return:
        !SUB RAX, [p.p_String]
        !SHR RAX, 1               ; ByteCounter to Word
        ProcedureReturn
        
      CompilerElse ; #PB_Compiler_32Bit       
        
        !XOR EDX, EDX
        !XOR ECX, ECX
        !MOV EAX, [p.p_String] 
        
        !@@:
        !TEST EAX, 0Fh
        !JZ @f
          !MOV DX, WORD [EAX]
          !TEST EDX, EDX
          !JZ .Return
          !INC EAX
        !JMP @b
        
        !@@:
        !PXOR XMM0, XMM0
        !SUB EAX, 16      
        
        !@@:  
          !ADD EAX, 16  
          !PCMPISTRI XMM0, [EAX], 0001001b  ; EQUAL_EACH WORD
        !JNZ @b
        
        ; ECX will contain the offset from EAX where the first null
      	; terminating character was found.
        !SHL ECX, 1   ; Word to Byte
        !ADD EAX, ECX
        
        !.Return:
        !SUB EAX, [p.p_String]
        !SHR EAX, 1               ; Byte to Word
      CompilerEndIf
      
    CompilerElse  ; #PB_Compiler_Backend = #PB_Backend_C
      
      Protected *pStr.String 
      *pStr = *String
      ProcedureReturn Len(*pStr\s)
        
    CompilerEndIf
    
    EnableDebugger
  EndProcedure

  Procedure.i SSE_StringCompare(*String1, *String2, *Pos=0)
  ; ============================================================================
  ; NAME: SSE_StringCompare
  ; DESC: Compares 2 Strings with SSE operation (PCmpIStrI)
  ; VAR(*String1): Pointer to String 1
  ; VAR(*String2): Pointer to String 2
  ; VAR(*Pos): optional Pointer to an Int to get the CharNo which do not match 
  ; RET.i: 0=(S1=S2), 1=(S1>S2), -1=(S1<S2) #PB_String_Lower/Equal/Greater
  ; ============================================================================
        
    ; XMM0 XMM1 XMM2 XMM3 XMM4
    ; XMM1 = [String1] : XMM2=[String2]
  ;  DisableDebugger
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
      CompilerIf #PB_Compiler_64Bit 
        DisableDebugger
       
        ; used Registers
        ;   RAX : *String1
        ;   R8  : *String2
        ;   RCX : operating Register
        ;   RDX : operating Register
        
        ; ----------------------------------------------------------------------
        ; Check the *String1 abd *String2 align
        ; The Problem of not aligend 16 is: Reading over the end of a 
        ; memory page. If the next page is not allocated to our programm we
        ; produce a crash! So we have to be sure do not read over the 
        ; EndOfPage if the String ends short before. PCMPISTRI process 16Bytes,
        ; so if we use PCMPISTRI at align 16 we can't read over the end of
        ; String without detecting EndOfString first!
        ; ----------------------------------------------------------------------
        !MOV RAX, [p.p_String1]
        !MOV R8, [p.p_String2]
        
        !MOV RCX, RAX           ; RCX = *String1
        !AND RCX, 0Fh           ; Filter the Aling Offset to 16Bytes      
        !MOV RDX, R8            ; RDX = *String2
        !SUB R8, RAX
        
        !AND RDX, 0Fh           ; Filter the Aling Offset to 16Bytes
        !TEST RDX, 1            ; Test for Odd align -> Align 16 not possible
        !JNZ .NotAligned        
        
        !CMP RDX, RCX           ; Test if align of String1 and String2 is identical
        !JNE .NotAligned      
        
        !TEST RCX, RCX          ; Test if it is aligend to 16Bytes (Offset ==0)
        !JZ .a16                ; aligned to 16 Bytes, we have to to nothing
        
        ; ----------------------------------------------------------------------
        ; Case I: Not aligned to 16 Bytes but it's possilbe to align manually
        ; ----------------------------------------------------------------------

        ; identical align but not to 16Bytes
        !SUB RAX, 2
        
        ; so first we compare Char by Char until the Address is 16 Byte aligned  
        !@@:                      ; Loop
          !ADD RAX, 2
          ;!ADD R8, 2
          !TEST RAX, 0Fh          ; (AND RAX, 0Fh) == 0
          !JZ .a16                ; Continue at Case III: aligend to 16 Byte
          !MOV CX, WORD[RAX]
          !CMP CX, WORD[RAX+R8]
          !JA .GREATER
          !JB .LOWER
          ; if identical check for EndOfString
          !TEST CX, 0             ; TEST results in 0 if CX==0
          !JZ .EQUAL
        !JMP @b                   ; Not EndOfString -> Repeat Loop  
        
        ; ----------------------------------------------------------------------
        ; Case II:
        ; A complete different align of *String1 and *String2, so it is not
        ; possible to aling both toghether to 16Byte. In this case we have
        ; 2 options:
        ;   I) we don't use PCMPISTRI and do a classic Char by Char compare
        ;  II) we have to check EndOfMemPage and use classic Char by Char
        ;      at end of MemoryPages (4096 Bytes). But that's more 
        ;      complicated
        ; ----------------------------------------------------------------------
        
        !.NotAligned:             ; Not aligned : a complet different align       
        !SUB RAX, 2
         
        !@@:
          !ADD RAX, 2
          !MOV CX, WORD[RAX]
          !CMP CX, WORD[RAX+R8]
          !JA .GREATER
          !JB .LOWER         
          ; if identical check for EndOfString
          !TEST CX, 0             ; TEST results in 0 if CX==0 
          !JZ .EQUAL
        !JMP @b                   ; Not EndOfString -> Repeat Loop
                       
        ; ----------------------------------------------------------------------
        ; Case III:
        ; If *String1 And *String is aligned to 16Bytes
        ; we can use PCMPISTRI what is a 16Byte operation
        ; ----------------------------------------------------------------------
        
        !.a16:
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
      
       	!SUB RAX, 16		         
        !XOR RCX, RCX   
        
        !@@:
         	!ADD RAX, 16
         	!MOVDQA XMM0, [RAX]         	
         	; IMM8[1:0]	= 00b
       	  ;	00b: Src data is unsigned bytes(16 packed unsigned bytes)
       	  ;	01b: Src data is unsigned words( 8 packed unsigned words)
        	
         	; IMM8[3:2]	= 10b
        	; 	We are using Equal Each aggregation
        	; IMM8[5:4]	= 01b
        	;	Negative Polarity, IntRes2	= -1 XOR IntRes1
        	; IMM8[6]	= 0b
        	;	ECX contains the least significant set bit in IntRes2  	
        	!PCMPISTRI XMM0, [RAX+R8], 0011001b ; EQUAL_EACH + NEGATIVE_POLARITY + UNSIGNED_WORDS  	
        	; Loop while ZF=0 and CF=0:
        	;	1) We find a null in s1(RDX+RAX) ZF=1
        	;	2) We find a char that does not match CF=1  	
        !JA	@b      ; IF CF=0 And ZF=0     	  	         
      	!JC	@f      ; IF CF=1 : Jump if CF=1, we found a mismatched char      	          
       	!JMP .EQUAL	; We terminated loop due to a null character i.e. CF=0 and ZF=1 -> The Strings are equal
       	
       	!@@:
          ; ECX is the offset from the current poition in NoOfChars where the two strings do not match,
        	; so copy the respective non-matching char into DX and compare it with the position in *String2
        	; in remaining bits w/ zero. Because of 2ByteChar we have to convert Word to Byte
          
          !SHL RCX, 1             ; Number of Chars to Adress Offset
          !ADD RAX, RCX
          !MOV DX, WORD[RAX]
         	; If S1=S2 : Return (0) ; #PB_String_Equal
          ; If S1>S2 : Return (+) ; #PB_String_Greater
          ; If S1<S2 : Return (-) ; #PB_String_Lower
          !CMP DX, WORD [RAX+R8]
          !JA .GREATER
          !JB .LOWER
          ;!JMP .EQUAL 
          
        !.EQUAL:                    ; The Strings are equal
          !MOV R8, RAX  
          !XOR RAX, RAX             ; #PB_String_Equal, 0  
          !JMP @f                      
        !.LOWER:                    ; String1 < String2
          !MOV R8, RAX  
          !XOR RAX, RAX
          !DEC RAX                  ; #PB_String_Lower, -1  
          !JMP @f                      
        !.GREATER:                  ; String1 > String2
          !MOV R8, RAX  
          !XOR RAX, RAX
          !INC RAX                  ; #PB_String_Greater, 1
        !@@:  
          ; check for Return of CharNo in Pos 
          !MOV RDX, [p.p_Pos]       ; RDX = *Pos
          !TEST RDX, RDX            ; 
          !JZ .return               ; If *Pos = 0 Then return  
            !SUB R8, [p.p_String1]
            !SHR R8, 1              ; Byte to Word
            !MOV [RDX], R8          ; Pos = CharNo which do not match
        !.return:
        ProcedureReturn ; RAX
        EnableDebugger
        
      CompilerElse  ; #PB_Compiler_32Bit
        
        DisableDebugger
       
        ; used Registers
        ;   EAX : *String1
        ;   EBX  : *String2
        ;   ECX : operating Register
        ;   EDX : operating Register
        
        ASM_PUSH_EBX()
        ; ----------------------------------------------------------------------
        ; Check the *String1 abd *String2 align
        ; The Problem of not aligend 16 is: Reading over the end of a 
        ; memory page. If the next page is not allocated to our programm we
        ; produce a crash! So we have to be sure do not read over the 
        ; EndOfPage if the String ends short before. PCMPISTRI process 16Bytes,
        ; so if we use PCMPISTRI at align 16 we can't read over the end of
        ; String without detecting EndOfString first!
        ; ----------------------------------------------------------------------
        !MOV EAX, [p.p_String1]
        !MOV EBX, [p.p_String2]
        
        !MOV EXC, EAX           ; EXC = *String1
        !AND EXC, 0Fh           ; Filter the Aling Offset to 16Bytes      
        !MOV EDX, EBX            ; EDX = *String2
        !SUB EBX, EAX
        
        !AND EDX, 0Fh           ; Filter the Aling Offset to 16Bytes
        !TEST EDX, 1            ; Test for Odd align -> Align 16 not possible
        !JNZ .NotAligned        
        
        !CMP EDX, EXC           ; Test if align of String1 and String2 is identical
        !JNE .NotAligned      
        
        !TEST EXC, EXC          ; Test if it is aligend to 16Bytes (Offset ==0)
        !JZ .a16                ; aligned to 16 Bytes, we have to to nothing
        
        ; ----------------------------------------------------------------------
        ; Case I: Not aligned to 16 Bytes but it's possilbe to align manually
        ; ----------------------------------------------------------------------

        ; identical align but not to 16Bytes
        !SUB EAX, 2
        
        ; so first we compare Char by Char until the Address is 16 Byte aligned  
        !@@:                      ; Loop
          !ADD EAX, 2
          ;!ADD EBX, 2
          !TEST EAX, 0Fh          ; (AND EAX, 0Fh) == 0
          !JZ .a16                ; Continue at Case III: aligend to 16 Byte
          !MOV CX, WORD[EAX]
          !CMP CX, WORD[EAX+EBX]
          !JA .GREATER
          !JB .LOWER
          ; if identical check for EndOfString
          !TEST CX, 0             ; TEST results in 0 if CX==0
          !JZ .EQUAL
        !JMP @b                   ; Not EndOfString -> Repeat Loop  
        
        ; ----------------------------------------------------------------------
        ; Case II:
        ; A complete different align of *String1 and *String2, so it is not
        ; possible to aling both toghether to 16Byte. In this case we have
        ; 2 options:
        ;   I) we don't use PCMPISTRI and do a classic Char by Char compare
        ;  II) we have to check EndOfMemPage and use classic Char by Char
        ;      at end of MemoryPages (4096 Bytes). But that's more 
        ;      complicated
        ; ----------------------------------------------------------------------
        
        !.NotAligned:             ; Not aligned : a complet different align       
        !SUB EAX, 2
         
        !@@:
          !ADD EAX, 2
          !MOV CX, WORD[EAX]
          !CMP CX, WORD[EAX+EBX]
          !JA .GREATER
          !JB .LOWER         
          ; if identical check for EndOfString
          !TEST CX, 0             ; TEST results in 0 if CX==0 
          !JZ .EQUAL
        !JMP @b                   ; Not EndOfString -> Repeat Loop
                       
        ; ----------------------------------------------------------------------
        ; Case III:
        ; If *String1 And *String is aligned to 16Bytes
        ; we can use PCMPISTRI what is a 16Byte operation
        ; ----------------------------------------------------------------------
        
        !.a16:
        ; Subtract s2(EDX) from s1(EAX). This admititedly looks odd, but we
      	; can now use EDX to index into s1 and s2. As we adjust EDX to move
      	; forward into s2, we can then add EDX to EAX and this will give us
      	; the comparable offset into s1 i.e. if we take EDX + 16 then:
      	;
      	;	EDX     = EDX + 16		        = EDX + 16
      	;	EAX+EDX	= EAX -EDX + EDX + 16	= EAX + 16
      	;
      	; therefore EDX points to s2 + 16 and EAX + EDX points to s1 + 16.
      	; We only need one index, convoluted but effective.
      
       	!SUB EAX, 16		         
        !XOR EXC, EXC   
        
        !@@:
         	!ADD EAX, 16
         	!MOVDQA XMM0, [EAX]         	
         	; IMM8[1:0]	= 00b
       	  ;	00b: Src data is unsigned bytes(16 packed unsigned bytes)
       	  ;	01b: Src data is unsigned words( 8 packed unsigned words)
        	
         	; IMM8[3:2]	= 10b
        	; 	We are using Equal Each aggregation
        	; IMM8[5:4]	= 01b
        	;	Negative Polarity, IntRes2	= -1 XOR IntRes1
        	; IMM8[6]	= 0b
        	;	ECX contains the least significant set bit in IntRes2  	
        	!PCMPISTRI XMM0, [EAX+EBX], 0011001b ; EQUAL_EACH + NEGATIVE_POLARITY + UNSIGNED_WORDS  	
        	; Loop while ZF=0 and CF=0:
        	;	1) We find a null in s1(EDX+EAX) ZF=1
        	;	2) We find a char that does not match CF=1  	
        !JA	@b      ; IF CF=0 And ZF=0     	  	         
      	!JC	@f      ; IF CF=1 : Jump if CF=1, we found a mismatched char      	          
       	!JMP .EQUAL	; We terminated loop due to a null character i.e. CF=0 and ZF=1 -> The Strings are equal
       	
       	!@@:
          ; ECX is the offset from the current poition in NoOfChars where the two strings do not match,
        	; so copy the respective non-matching char into DX and compare it with the position in *String2
        	; in remaining bits w/ zero. Because of 2ByteChar we have to convert Word to Byte
          
          !SHL EXC, 1             ; Number of Chars to Adress Offset
          !ADD EAX, EXC
          !MOV DX, WORD[EAX]
         	; If S1=S2 : Return (0) ; #PB_String_Equal
          ; If S1>S2 : Return (+) ; #PB_String_Greater
          ; If S1<S2 : Return (-) ; #PB_String_Lower
          !CMP DX, WORD [EAX+EBX]
          !JA .GREATER
          !JB .LOWER
          ;!JMP .EQUAL 
          
        !.EQUAL:                    ; The Strings are equal
          !MOV EBX, EAX  
          !XOR EAX, EAX             ; #PB_String_Equal, 0  
          !JMP @f                      
        !.LOWER:                    ; String1 < String2
          !MOV EBX, EAX  
          !XOR EAX, EAX
          !DEC EAX                  ; #PB_String_Lower, -1  
          !JMP @f                      
        !.GREATER:                  ; String1 > String2
          !MOV EBX, EAX  
          !XOR EAX, EAX
          !INC EAX                  ; #PB_String_Greater, 1
        !@@:  
          ; check for Return of CharNo in Pos 
          !MOV EDX, [p.p_Pos]       ; EDX = *Pos
          !TEST EDX, EDX            ; 
          !JZ .return               ; If *Pos = 0 Then return  
            !SUB EBX, [p.p_String1]
            !SHR EBX, 1              ; Byte to Word
            !MOV [EDX], EBX          ; Pos = CharNo which do not match
        !.return:     
        ASM_POP_EBX()   
        ProcedureReturn ; EAX
        EnableDebugger
        
      CompilerEndIf
      
    CompilerElse    ; C-Backend
      
      ; for now use PB CompareMemoryString. So it will work on other Platforms too.
      ; maybe provide a C optimized version in the future
      ProcedureReturn CompareMemoryString(*String1, *String2)  
      
    CompilerEndIf
    
   EndProcedure
  
  Procedure.i SSE_FindStr(*String, *StringToFind)
  ; ============================================================================
  ; NAME: SSE_FindStr
  ; DESC: Try to find StringToFind in String with SSE operation (PCmpIStrI)
  ; DESC: Search for the needle in the haystack
  ; DESC: This Function is for 2Byte Character Strings only
  ; VAR(*String): Pointer to String (Haystack)
  ; VAR(*StringToFind): Pointer to StringToFind (Needle)
  ; RET.i: If found: The startposition in Characters [1..n]. Otherwise 0
  ; ============================================================================    
        
    DisableDebugger
    
    ; TODO! Solve the 16Byte align problem
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
      
      CompilerIf #PB_Compiler_64Bit 
        Protected memRAX, memRDX
        ; Returns a pointer To the first occurrence of str2 in str1, Or a null pointer If str2 is Not part of str1. 
        ; The matching process does not include the terminating null-characters, but it stops there
        ; RAX = haystack (Heuhaufen), RDX = needle (Nadel)
        
        ; XMM0 XMM1 XMM2 XMM3 XMM4
        ; XMM1 = [String1] : XMM2=[String2]
        
        !MOV RAX, [p.p_String]        ; haystack
        !MOV RDX, [p.p_StringToFind]  ; needle
        !MOVDQU XMM2, DQWORD[RDX] ; load the first 16 bytes of neddle (String to find)
    
       	!SUB RAX, 16		; Avoid extra jump in main loop
           
        ; ----------------------------------------------------------------------
        ; Find the first possible match of 16-byte fragment in haystack
        ; ----------------------------------------------------------------------
        !FindStr_MainLoop:
          !ADD RAX, 16      ; Step up Counter
          !MOVDQU XMM1, DQWORD[RAX]
         ;!PCMPISTRI XMM2, XMM1, 1100b ; EQUAL_ORDERED ; for ASCII Strings
          !PCMPISTRI XMM2, XMM1, 1101b ; EQUAL_ORDERED + UNSIGNED_WORDS; 11001b
          ; now RCX contains the offset in WORDS where a match was found
         	; Loop while ZF=0 and CF=0:
        	;	1) We find a null in s1(RAX) ZF=1
          ;	2) We find a char that does not match CF=1 
        !JA FindStr_MainLoop
        ; Jump if CF=0, we found only matching chars  
        !JNC FindStr_StrNotFound
        
        ; possible match found at WordOffset in RCX
        !ADD RCX, RCX ; Word to Byte
        !ADD RAX, RCX ; save the possible match start
                
        !MOV [p.v_memRDX], RDX ; mov edi, edx; save RDX
        !MOV [p.v_memRAX], RAX ; mov esi, eax; save RAX
        
        ; ----------------------------------------------------------------------
        ; Compare String, at possible match postion in haystack, with needle
        ; ----------------------------------------------------------------------
        !SUB RDX, RAX
        !SUB RAX, 16  ; counter
        
        !PXOR XMM3, XMM3          ; XMM3 = 0
        
        ; compare the strings
        !FindStr_Compare:
          !ADD RAX, 16  ; Counter
          !MOVDQU XMM1, DQWORD[RAX+RDX] ; Haystack          
          ; mask out invalid bytes in the haystack
         ;!PCMPISTRM XMM3, XMM1, 1011000b   ; EQUAL_EACH + NEGATIVE_POLARITY + BYTE_MASK  ; for ASCII Strings
          !PCMPISTRM XMM3, XMM1, 1011001b   ; EQUAL_EACH + NEGATIVE_POLARITY + BYTE_MASK + UNSIGNED_WORDS
          ; PCMPISTRM writes as result a Mask To XMM0, we used BYTE_MASK
          !MOVDQU XMM4, DQWORD[RAX] ; haystack  
          !PAND XMM4, XMM0
          
         ;!PCMPISTRI XMM1, XMM4, 0011000b ; EQUAL_EACH + NEGATIVE_POLARITY ; for ASCII Strings
          !PCMPISTRI XMM1, XMM4, 0011001b ; EQUAL_EACH + NEGATIVE_POLARITY + UNSIGNED_WORDS
         	; Loop while ZF=0 and CF=0:
        	;	1) We find a null in s1(RDX+RCX) ZF=1      {JA CF=0 & ZF=0} {JE : ZF=1)
          ;	2) We find a char that does not match CF=1 {JC, JNC}
          ; 3) We find a null in s2 SF=1               {JS, JNS}
          ;!JS FindStr_StrNotFound 
        !JA FindStr_Compare ; CF=0 AND ZF=0
        
        !MOV RDX, [p.v_memRDX]
        !MOV RAX, [p.v_memRAX]
        !JNC FindStr_StrFound
        
        ;!SUB RAX, 15  ; for ASCII Strings
        !SUB RAX, 14
        !JMP FindStr_MainLoop
        
        !FindStr_StrNotFound:
          !XOR RAX, RAX
          !JMP FindStr_End
          
        !FindStr_StrFound:
          ; because RAX contains the Pointer we have to calculate the Char-No.
          !SUB RAX, [p.p_String]    ; Sub the Haystack Start-Pointer
          !SHR RAX, 1  ; Byte to Word: not needed for ASCII Strings
          !ADD RAX, 1  ; Add 1 to start with 1 as first Char-No.
        !FindStr_End:
        ProcedureReturn  ; !RAX
 
      CompilerElse  ; #PB_Compiler_32Bit
        
        Protected memEAX, memEDX
        ; Returns a pointer To the first occurrence of str2 in str1, Or a null pointer If str2 is Not part of str1. 
        ; The matching process does not include the terminating null-characters, but it stops there
        ; RAX = haystack (Heuhaufen), EDX = needle (Nadel)
        
        ; XMM0 XMM1 XMM2 XMM3 XMM4
        ; XMM1 = [String1] : XMM2=[String2]
        
        !MOV EAX, [p.p_String]        ; haystack
        !MOV EDX, [p.p_StringToFind]  ; needle
        !MOVDQU XMM2, DQWORD[EDX] ; load the first 16 bytes of neddle (String to find)
    
       	!SUB EAX, 16		; Avoid extra jump in main loop
           
        ; ----------------------------------------------------------------------
        ; Find the first possible match of 16-byte fragment in haystack
        ; ----------------------------------------------------------------------
        !FindStr_MainLoop:
          !ADD EAX, 16      ; Step up Counter
          !MOVDQU XMM1, DQWORD[EAX]
         ;!PCMPISTRI XMM2, XMM1, 1100b ; EQUAL_ORDERED ; for ASCII Strings
          !PCMPISTRI XMM2, XMM1, 1101b ; EQUAL_ORDERED + UNSIGNED_WORDS; 11001b
          ; now RCX contains the offset in WORDS where a match was found
         	; Loop while ZF=0 and CF=0:
        	;	1) We find a null in s1(EAX) ZF=1
          ;	2) We find a char that does not match CF=1 
        !JA FindStr_MainLoop
        ; Jump if CF=0, we found only matching chars  
        !JNC FindStr_StrNotFound
        
        ; possible match found at WordOffset in ECX
        !ADD ECX, ECX ; Word to Byte
        !ADD EAX, ECX ; save the possible match start
                
        !MOV [p.v_memEDX], EDX ; mov edi, edx; save EDX
        !MOV [p.v_memEAX], EAX ; mov esi, eax; save EAX
        
        ; ----------------------------------------------------------------------
        ; Compare String, at possible match postion in haystack, with needle
        ; ----------------------------------------------------------------------
        !SUB EDX, EAX
        !SUB EAX, 16  ; counter
        
        !PXOR XMM3, XMM3          ; XMM3 = 0
        
        ; compare the strings
        !FindStr_Compare:
          !ADD EAX, 16  ; Counter
          !MOVDQU XMM1, DQWORD[EAX+EDX] ; Haystack          
          ; mask out invalid bytes in the haystack
         ;!PCMPISTRM XMM3, XMM1, 1011000b   ; EQUAL_EACH + NEGATIVE_POLARITY + BYTE_MASK  ; for ASCII Strings
          !PCMPISTRM XMM3, XMM1, 1011001b   ; EQUAL_EACH + NEGATIVE_POLARITY + BYTE_MASK + UNSIGNED_WORDS
          ; PCMPISTRM writes as result a Mask To XMM0, we used BYTE_MASK
          !MOVDQU XMM4, DQWORD[EAX] ; haystack  
          !PAND XMM4, XMM0
          
         ;!PCMPISTRI XMM1, XMM4, 0011000b ; EQUAL_EACH + NEGATIVE_POLARITY ; for ASCII Strings
          !PCMPISTRI XMM1, XMM4, 0011001b ; EQUAL_EACH + NEGATIVE_POLARITY + UNSIGNED_WORDS
         	; Loop while ZF=0 and CF=0:
        	;	1) We find a null in s1(EDX+ECX) ZF=1      {JA CF=0 & ZF=0} {JE : ZF=1)
          ;	2) We find a char that does not match CF=1 {JC, JNC}
          ; 3) We find a null in s2 SF=1               {JS, JNS}
          ;!JS FindStr_StrNotFound 
        !JA FindStr_Compare ; CF=0 AND ZF=0
        
        !MOV EDX, [p.v_memEDX]
        !MOV EAX, [p.v_memEAX]
        !JNC FindStr_StrFound
        
        ;!SUB EAX, 15  ; for ASCII Strings
        !SUB EAX, 14
        !JMP FindStr_MainLoop
        
        !FindStr_StrNotFound:
          !XOR EAX, EAX
          !JMP FindStr_End
          
        !FindStr_StrFound:
          ; because EAX contains the Pointer we have to calculate the Char-No.
          !SUB EAX, [p.p_String]    ; Sub the Haystack Start-Pointer
          !SHR EAX, 1  ; Byte to Word: not needed for ASCII Strings
          !ADD EAX, 1  ; Add 1 to start with 1 as first Char-No.
        !FindStr_End:
       
        ProcedureReturn 
      CompilerEndIf  ; #PB_Compiler_32Bit
      
    CompilerElse    ; C-Backend
      
      ; for now use PB FindString. So it will work on other Platforms too.
      ; maybe provide a C optimized version in the future
      Protected *pStr.String = *String
      Protected *pStrToFind.String = *StringToFind
      
      ProcedureReturn FindString(*pStr\s, *pStrToFind\s)    
    CompilerEndIf    
    
  EndProcedure
    
  ;- ----------------------------------------------------------------------
  ;- Initalisation
  ;- ----------------------------------------------------------------------
  
;   ; PCmpIStrI needs SSE4.2
;   If CPU::CpuMultiMediaFeatures\SSE4_2
;     Debug "SSE4.2 is supported"
;   EndIf
  
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
  
  For I=0 To 98     ; Fill Char Array with 100 Ascii Chars
    bChar(i) = 33+I
  Next  
  
  Debug "--------------------------------------------------"
  Debug "String Len"
  Debug "--------------------------------------------------"

  sTest= Space(255)   ; Fill TestString with 255 Spaces
  
  sDbg= "PB: Len() = "  + Len(sTest) ; should be 255
  Debug sDbg
  sDbg = "SSE Len = " + Str(SSE_Len(@sTest)) ; should be 255
  Debug sDbg
  sDbg = "ASCII Len() = " + Str(SSE_LenA(@bChar(0)))  ; should be 100 Chars
  Debug sDbg
  
  ;- ----------------------------------------------------------------------

  Define.s S0, S1, S2, sQ
  Define ret
  Dim cmp.s(2)
  
  cmp(0) = "<"
  cmp(1) = "="
  cmp(2) = ">"
  sQ.s = Chr('"') ; Quotes
       ;1        10                                    48
  S0 = "Ich bin ein langer String, in welchem man nach 1234 suchen kann 5677"
  S1 = "Ich bin ein langer String, in welchem man nach 1234 suchen kann 5677"
  S2 = "Ich bin ein langer String, in welchem man nach 1234 suchen kann 5679"
  SL = "abcdefghijklmnopqrstuvwABCDEFGHIJKLMNOPQRSRUVW"
  SL = SL + SL + SL + SL + SL + SL + SL + SL + SL + SL + "search" + SL + SL
  
  Debug "--------------------------------------------------"
  Debug "StringCompare"
  Debug "--------------------------------------------------"
  ;Debug ""
  ret = SSE_StringCompare(@S0, @S1)   ; =
  Debug ret
  Debug sQ + S0 + sQ + "  " + cmp(ret+1) + "  " + sQ + S1 + sQ
  
  ret = SSE_StringCompare(@S0, @S2)   ; <
  Debug ret
  Debug sQ + S0 + Sq + "  " + cmp(ret+1) +  "  " + sQ + S2 + sQ
  
  ret = SSE_StringCompare(@S2, @S1)   ; <
  Debug ret
  Debug sQ + S2 + sQ + "  " + cmp(ret+1) +  "  " + sQ + S1 + sQ
  
  Debug "--------------------------------------------------"
  Debug "FindString"
  Debug "--------------------------------------------------"
  ;Debug ""
  
  Define Search$ 
  Search$ = "1234"
  ;Search$ = "bin"
  ret = SSE_FindStr(@S0, @Search$)
  Debug ret
  
  Debug "--------------------------------------------------"

  ; ----------------------------------------------------------------------
  ; TIMING TEST
  ; ----------------------------------------------------------------------
  
  #cst_Loops = 2000000  ; 2Mio
  
  Define T1, T2, txtStrLen.s, txtStrCompare.s
  
  Debug "Stringlength"
  Debug Str(@S1 % 32) + " : " + Hex(@S1)
  Debug Str(@S2 % 16) + " : " + Hex(@S2)
  
  ; ----------------    StringLength ----------------------
  ; SSE Assembler Version
  ; S1 = Space(15000)
  
  T1 = ElapsedMilliseconds()
  For I = 1 To #cst_Loops
    ret = SSE_Len(@S1) 
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

; https://www.strchr.com/strcmp_and_strlen_using_sse_4.2

; ; compile with FASM
; ; Immediate byte constants
; EQUAL_ANY	    = 0000b
; RANGES		    = 0100b
; EQUAL_EACH	    = 1000b
; EQUAL_ORDERED	    = 1100b
; NEGATIVE_POLARITY = 010000b
; BYTE_MASK	 = 1000000b
; 
; ; ==== strcmp ====
; 
; strcmp_sse42:
;   ; Using __fastcall convention, ecx = String1, edx = String2
;   mov eax, ecx
;   sub eax, edx ; eax = ecx - edx
;   sub edx, 16
; 
; STRCMP_LOOP:
;     add edx, 16
;     MovDqU    xmm0, dqword[edx]
;     ; find the first *different* bytes, hence negative polarity
;     PcmpIstrI xmm0, dqword[edx + eax], EQUAL_EACH + NEGATIVE_POLARITY
;     ja STRCMP_LOOP
; 
;   jc STRCMP_DIFF
; 
;   ; the strings are equal
;   XOr eax, eax
;   ret
; STRCMP_DIFF:
;   ; subtract the first different bytes
;   add eax, edx
;   movzx eax, byte[eax + ecx]
;   movzx edx, byte[edx + ecx]
;   sub eax, edx
;   ret
; 
; 
; ; ==== strlen ====
; strlen_sse42:
;   ; ecx = string
;   mov eax, -16
;   mov edx, ecx
;   pxor xmm0, xmm0
; 
; STRLEN_LOOP:
;     add eax, 16
;     PcmpIstrI xmm0, dqword[edx + eax], EQUAL_EACH
;     jnz STRLEN_LOOP
; 
;   add eax, ecx
;   ret
; 
; ; ==== strstr ====; FindString
; strstr_sse42:
;   ; ecx = haystack, edx = needle
; 
;   push esi
;   push edi
;   MovDqU xmm2, dqword[edx] ; load the first 16 bytes of neddle
;   Pxor xmm3, xmm3
;   lea eax, [ecx - 16]
; 
;   ; find the first possible match of 16-byte fragment in haystack
; STRSTR_MAIN_LOOP:
;     add eax, 16
;     PcmpIstrI xmm2, dqword[eax], EQUAL_ORDERED
;     ja STRSTR_MAIN_LOOP
; 
;   jnc STRSTR_NOT_FOUND
; 
;   add eax, ecx ; save the possible match start
;   mov edi, edx
;   mov esi, eax
;   sub edi, esi
;   sub esi, 16
; 
;   ; compare the strings
; @@:
;     add esi, 16
;     MovDqU    xmm1, dqword[esi + edi]
;     ; mask out invalid bytes in the haystack
;     PcmpIstrM xmm3, xmm1, EQUAL_EACH + NEGATIVE_POLARITY + BYTE_MASK
;     MovDqU xmm4, dqword[esi]
;     PAnd xmm4, xmm0
;     PcmpIstrI xmm1, xmm4, EQUAL_EACH + NEGATIVE_POLARITY
;     ja @B
; 
;   jnc STRSTR_FOUND
; 
;   ; continue searching from the next byte
;   sub eax, 15
;   jmp STRSTR_MAIN_LOOP
; 
; STRSTR_NOT_FOUND:
;   XOr eax, eax
; 
; STRSTR_FOUND:
;   pop edi
;   pop esi
;   ret
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 956
; FirstLine = 518
; Folding = ----
; Optimizer
; CPU = 5