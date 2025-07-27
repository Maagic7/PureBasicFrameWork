; ===========================================================================
;  FILE : PbFw_Module_FastString.pb
;  NAME : Module String [FStr:]
;  DESC : Provides extra fast String Functions 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/02/02
; VERSION  :  0.1 Brainstroming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;  2025/05/16 S.Maag : corrected wrong Shufflemask load in ASMx64_ChangeByteOrder
;  2024/01/28 S.Maag : added ASM x64 optiomations for CountChar, ReplaceChar
;                      added Fast LenStr_x64() function and Macro LenStrFast()
;                        to use it only at x64!
;  2024/01/20 S.Maag : added ToggleStringEndianess()
;                      faster Version for RemoveTabsAndDoubleSpace()
;                      RemoveTabsAndDoubleSpaceFast(*String); Pointer Version
;                      moved String File-Functions to Module FileSystem FS::
;}
;{ TODO:
;}
; ===========================================================================

; --------------------------------------------------
; Assembler Datasection Definition
; --------------------------------------------------
; db 	Define Byte = 1 byte
; dw 	Define Word = 2 bytes
; dd 	Define Doubleword = 4 bytes
; dq 	Define Quadword = 8 bytes
; dt 	Define Ten Bytes = 10 bytes
; !label: dq 21, 22, 23
; --------------------------------------------------

;- --------------------------------------------------
;- Include Files
;  --------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile ""

DeclareModule FStr
  
  ;- --------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  --------------------------------------------------
  Enumeration ReturnMode
    #FStr_ReturnCharNo
    #FStr_ReturnPointer
  EndEnumeration

  Declare.i LenStr_x64(*String)
    
  Prototype.i ReplaceChar(String$, cSearch.c, cReplace.c) ; ProtoType-Function for ReplaceChar
  Global ReplaceChar.ReplaceChar                          ; define Prototype-Handler for CountChar

  Prototype.i CountChar(String$, cSearch.c, *outLength.Integer=0)  ; ProtoType-Function for CountChar
  Global CountChar.CountChar                 ; define Prototype-Handler for CountChar
  
  Declare.i CountUnicodeChars(*StringW, *outLength.Integer=0)
  
  Prototype.i FindCharReverse(*String.Character, cSearch.c, cfgReturnValue = #FStr_ReturnCharNo)
  Global FindCharReverse.FindCharReverse                  ; define Prototype-Handler for CountChar
  
  Declare.i ToggleStringEndianess(*String, *outLength.Integer=0)

  Declare.i LCase255(*String, *outLength.Integer=0)
  Declare.i UCase255(*String, *outLength.Integer=0)
  Declare.s GetVisibleAsciiCharset()
  
  CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_64Bit And #PB_Compiler_Unicode
    Macro LenStrFast(String)
      LenStr_x64(@String)  
    EndMacro
  CompilerElse
     Macro LenStrFast(String)
       Len(String)
     EndMacro     
  CompilerEndIf  

EndDeclareModule


Module FStr
  
  IncludeFile "PbFw_ASM_Macros.pbi"       ; Standard Assembler Macros
  
  Structure pChar   ; virtual CHAR-ARRAY, used as Pointer to overlay on strings 
    a.a[0]          ; fixed ARRAY Of CHAR Length 0
    c.c[0]          
  EndStructure

  ;- --------------------------------------------------
  ;- Len()
  ;- --------------------------------------------------

  ; Attention: Better use Macro LenStrFast(), it calls LenStr_x64 only in x64 Mode
  Procedure.i LenStr_x64(*String)  
  ; ============================================================================
  ; NAME: LenStr_x64
  ; DESC: A faster Len() function as the PB's Len()
  ; DESC: Speeding up Len() it's only faster in x64.
  ; DESC: On Ryzen 5800 it's double speed on PB 6.03
  ; DESC: !PointerVersion! Be sure to call it with LenStr_x64(@MyString)
  ; DESC: Better use the Macro LenStrFast() because this calls
  ; DESC: LenStr_x64() only at x64 ASM Backend otherwise it use PB's Len()
  ; DESC: wihout loss of speed!
  ; DESC: To not crash out of x64 ASM, LenStrW_x64() implements the 
  ; DESC: PB's Len() too. But it will be slower as using Len() directly because
  ; DESC: of extra Pointerhandling and an extra Procedure call!
  ; VAR(*String) : Pointer to String LenStrFast
  ; RET.i : Length of String; Number of Characters
  ; ============================================================================
       
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_64Bit And #PB_Compiler_Unicode
    
      ; Used Registers:
      ;   RAX : Pointer *String
      ;   RCX : -
      ;   RDX : operating Register
      ;   R8  : -
      ;   R9  : -
      ;   XMM0 : the 4 Chars
      ;   XMM1 : -
      ;   XMM2 : 0 to search for EndOfString    
      ;   XMM3 : -
     
      ; ----------------------------------------------------------------------
      ; Check *String-Pointer and MOV it to RAX as operating register
      ; ----------------------------------------------------------------------
      !MOV RAX, [p.p_String]    ; load String address
      !Test RAX, RAX            ; If *String = 0
      !JZ .Return               ;   Exit    
      !SUB RAX, 8               ; Sub 8 to start with Add 8 in the Loop     
       
      ; here are the standard setup parameters
      !PXOR XMM2, XMM2          ; XMM2 = 0 ; Mask to search for NullChar = EndOfString         
      ; ----------------------------------------------------------------------
      ; Main Loop
      ; ----------------------------------------------------------------------     
      !@@:
        !ADD RAX, 8                 ; *String + 8 => NextChars    
        !MOVQ XMM0, [RAX]           ; load 4 Chars to XMM0  
        !PCMPEQW XMM0, XMM2         ; Compare with 0
        !MOVQ RDX, XMM0             ; RDX CompareResult contains FFFF for each NullChar 
        !TEST RDX, RDX              ; If 0 : No NullChar found
      !JZ @b                        ;  Continue Loop  
      
      ; If EndOfStringFound  
      ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
      !BSF RDX, RDX                 ; BitScanForward => No of the LSB   
      !SHR RDX, 3                   ; BitNo to ByteNo
      !ADD RAX, RDX                 ; Actual StringPointer + OffsetOf(NullChar)
      !SUB RAX, [p.p_String]        ; RAX = *EndOfString - *String
      !SHR RAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
          
      !.Return:
      ProcedureReturn   ; RAX
           
    CompilerElse ; #PB_Compiler_Backend = #PB_Backend_C or Ascii
      
      ProcedureReturn MemoryStringLength(*String)
      
    CompilerEndIf
      
  EndProcedure
  
  ;- --------------------------------------------------
  ;- CountChar()
  ;- --------------------------------------------------
    
  ; **************************************************
  ; x64 Assembler Version with XMM-Registers
  ; ************************************************** 
  ; Procedure CountChar(*String, cSearch.c, *outLength.Integer=0)
  Macro ASMx64_CountChar()
    
    ; Used Registers:
    ;   RAX : Pointer *String
    ;   RCX : operating Register and Bool: 1 if NullChar was found
    ;   RDX : operating Register
    ;   R8  : Counter
    ;   R9  : operating Register
    
    ;   XMM0 : the 4 Chars
    ;   XMM1 : cSearch shuffeled to all Words
    ;   XMM2 : 0 to search for EndOfString
    ;   XMM3 : the 4 Chars Backup
    
    ; If you use XMM4..XMM7 you have to backup it first
    ;   XMM4 : 
    ;   XMM5 : 
    ;   XMM6 :
    ;   XMM7 :
    
    ASM_PUSH_XMM_4to5(RDX)     ; optional PUSH() see PbFw_ASM_Macros.pbi
    
    ; ----------------------------------------------------------------------
    ; Check *String-Pointer and MOV it to RAX as operating register
    ; ----------------------------------------------------------------------
    !MOV RAX, [p.p_String]    ; load String address
    !Test RAX, RAX            ; If *String = 0
    !JZ .Return               ; Exit    
    !SUB RAX, 8               ; Sub 8 to start with Add 8 in the Loop     
    ; ----------------------------------------------------------------------
    ; Setup start parameter for registers 
    ; ----------------------------------------------------------------------     
    ; your indiviual setup parameters
    !MOV DX, [p.v_cSearch]    ; should be DX not RDX because of 1 Word
    !MOVQ XMM1, RDX
    !PSHUFLW XMM1, XMM1, 0    ; Shuffle/Copy Word0 to all Words 
    
    ; here are the standard setup parameters
    !XOR RCX, RCX             ; operating Register and BOOL for EndOfStringFound
    !XOR R8, R8               ; Counter = 0
    !PXOR XMM2, XMM2          ; XMM2 = 0 ; Mask to search for NullChar = EndOfString         
    ; ----------------------------------------------------------------------
    ; Main Loop
    ; ----------------------------------------------------------------------     
    !.Loop:
      !ADD RAX, 8                     ; *String + 8 => NextChars    
      !MOVQ XMM0, [RAX]               ; load 4 Chars to XMM0  
      !MOVQ XMM3, [RAX]               ; load 4 Chars to XMM3
      !PCMPEQW XMM0, XMM2             ; Compare with 0
      !MOVQ RDX, XMM0                 ; RDX CompareResult contains FFFF for each NullChar 
      !TEST RDX, RDX                     ; If 0 : No NullChar found
      !JZ .EndIf                   ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
      ; If EndOfStringFound  
        ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
        !BSF RDX, RDX                 ; BitSanForward => No of the LSB   
        !SHR RDX, 3                   ; BitNo to ByteNo
        !ADD RAX, RDX                 ; Actual StringPointer + OffsetOf_NullChar
        !MOV RCX, RDX                 ; Save ByteOfsett of NullChar in RCX
        !SUB RAX, [p.p_String]        ; RAX *EndOfString - *String
        !SHR RAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
        ;check for Return of Length and and move it to *outLength 
        !MOV RDX, [p.p_outLength]
        !TEST RDX, RDX
        !JZ @f                        ; If *outLength
          !MOV [RDX], RAX             ;   *outLength = Len()
        !@@:                          ; Endif
      
        ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
        ; In RCX ist the Backup of the ByteOffset of NullChahr
        !CMP RCX, 6                   ; If NullChar is the last Char : Byte[7,6]=Word[3]
        !JGE @f                       ;  => we don't have to eliminate chars from testing
          ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 48..63 = Word 3
          !SHL RCX, 3                   ; ByteNo to BitNo
          !NEG RCX                      ; RCX = -LSB 
          !ADD RCX, 63                  ; RCX = (63-LSB)
          !XOR RDX, RDX                 ; RDX = 0
          !BTS RDX, 63                  ; set Bit 63 => RDX = 8000000000000000h
          !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
          !NOT RDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
          !MOVQ XMM0, RDX               ; Now move this Mask to XMM0, the operating Register
          !PAND XMM3, XMM0              ; XMM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
        !@@:
        
        !MOV RCX, 1                     ; BOOL EndOfStringFound = #TRUE
      !.EndIf:                     ; Endif ; EndOfStringFound    
      
      ; ------------------------------------------------------------
      ; Start of function individual code! Do not use RCX here!
      ; ------------------------------------------------------------
      ; Count number of found Chars
      !MOVQ XMM0, XMM3              ; Load the 4 Chars to operating Register
      !PCMPEQW XMM0, XMM1           ; Compare the 4 Chars with cSearch
      !MOVQ RDX, XMM0               ; CompareResult to RDX
      !TEST RDX, RDX
      !JZ @f                        ; Jump to Endif if cSearch not found
        !POPCNT RDX, RDX            ; Count number of set Bits (16 for each found Char)
        !SHR RDX, 4                 ; NoOfBits [0..64] to NoOfWords [0..4]
        !ADD R8, RDX                ; ADD NoOfFoundChars to Counter R8
      !@@: 
      ; ------------------------------------------------------------
      
      !TEST RCX, RCX                ; Check BOOL EndOfStringFound      
    !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
    
    ; ----------------------------------------------------------------------
    ; Handle Return value an POP-Registers
    ; ----------------------------------------------------------------------     
    !MOV RAX, R8      ; ReturnValue to RAX
    !.Return:
    
    ASM_POP_XMM_4to5(RDX)     ; POP non volatile Registers we PUSH'ed at start
    
    ProcedureReturn   ; RAX
    
  EndMacro
  
  ; **************************************************
  ; x32 Assembler Version with MMX-Registers
  ; **************************************************
  ; Procedure CountChar(*String, cSearch.c, *outLength.Integer=0)
  Macro ASMx32_MMX_CountChar()
    Protected eos       ; Bool EndOfString
    
    ; Used Registers:
    ;   EAX : Pointer *String
    ;   ECX : operating Register and Bool: 1 if NullChar was found
    ;   EDX : operating Register        
    
    ;   MM0 : the 4 Chars
    ;   MM1 : cSearch shuffeled to all Words
    ;   MM2 : 0 to search for EndOfString
    ;   MM3 : the 4 Chars Backup
    ;   MM4 : 
    ;   MM5 :
    ;   MM6 :
    ;   MM7 :
      
    ASM_PUSH_MM_0to3(RDX)      ; PUSH nonvolatile MMX-Registers
    ; ASM_PUSH_MM_4to5(RDX)     ; PUSH nonvolatile MMX-Registers
         
    ; ----------------------------------------------------------------------
    ; Check *String-Pointer and MOV it to EAX as operating register
    ; ----------------------------------------------------------------------
    !MOV EAX, [p.p_String]    ; load String address
    !TEST EAX, EAX            ; If *String = 0
    !JZ .Return               ; Exit    
    !SUB EAX, 4               ; Sub 4 to start with Add 8 in the Loop     
    
    ; ----------------------------------------------------------------------
    ; Setup start parameter for registers 
    ; ----------------------------------------------------------------------     
    ; your indiviual setup parameters
    !MOVZX EDX, WORD [p.v_cSearch]    ; MOV with zero extend
    !MOVD MM1, EDX
    !PSHUFLW MM1, MM1, 0      ; Shuffle/Copy Word0 to all Words 
   
    ; here are the standard setup parameters
    !PXOR MM2, MM2            ; MM2 = 0 ; Mask to search for NullChar = EndOfString         
    ; ----------------------------------------------------------------------
    ; Main Loop
    ; ----------------------------------------------------------------------     
    !.Loop:
      !ADD EAX, 4                     ; *String + 8 => NextChars    
      !MOVD MM0, [EAX]                ; load 4 Chars to MM0  
      !MOVD MM3, [EAX]                ; load 4 Chars to MM3
      !PCMPEQW MM0, MM2               ; Compare with 0
      !MOVD EDX, MM0                  ; EDX CompareResult contains FFFF for each NullChar 
      !TEST EDX, EDX                  ; If 0 : No NullChar found
      !JE .EndIf                    ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
      ; If EndOfStringFound  
        ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
        !BSF EDX, EDX                 ; BitSanForward => No of the LSB   
        !SHR EDX, 3                   ; BitNo to ByteNo
        !MOV ECX, EDX                 ; Backup ByteNo in ECX
        !ADD EAX, EDX                 ; Actual StringPointer + OffsetOf_NullChar
        !SUB EAX, [p.p_String]        ; EAX *EndOfString - *String
        !SHR EAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
        ;check for Return of Length and and move it to *outLength 
        !MOV EDX, [p.p_outLength]
        !TEST EDX, EDX
        !JZ @f                        ; If *outLength
          !MOV [EDX], EAX             ;   *outLength = Len()
        !@@:                          ; Endif
      
        ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
        !CMP ECX, 2                   ; ByteNo of NullChar >= 2 
        !JGE @f                       ;  => we don't have to eliminate chars from testing
        ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 16..31 = Word 3
          !SHL ECX, 3                   ; ByteNo to BitNo
          !NEG ECX                      ; ECX = -LSB 
          !ADD ECX, 31                  ; ECX = (31-LSB)
          !XOR EDX, EDX                 ; EDX = 0
          !BTS EDX, 31                  ; set Bit 31 => EDX = 80000000h
          !SAR EDX, CL                  ; Do an arithmetic Shift Right (31-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
          !NOT EDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
          !MOVD MM0, EDX                ; Now move this Mask to MM0, the operating Register
          !PAND MM3, MM0                ; MM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
        !@@:
                  
        !MOV [p.v_eos], DWORD 1        ; at x32 we need ECX, so Bool EndOfstring in Var 
      !.EndIf:                      ; Endif ; EndOfStringFound    
      
      ; ------------------------------------------------------------
      ; Start of function individual code! You can use ECX here!
      ; ------------------------------------------------------------
      ; Count number of found Chars
      !MOVQ MM0, MM3                ; Load the 4 Chars to operating Register
      !PCMPEQW MM0, MM1             ; Compare the 4 Chars with cSearch
      !MOVD EDX, MM0                ; CompareResult to EDX
      !TEST EDX, EDX
      !JZ @f                        ; Jump to Endif if cSearch not found
        !POPCNT EDX, EDX            ; Count number of set Bits (16 for each found Char)
        !SHR EDX, 4                 ; NoOfBits [0..64] to NoOfWords [0..4]
        !MOV ECX, DWORD [p.v_N]
        !ADD ECX, EDX               ; ADD NoOfFoundChars to Counter 
        !MOV [p.v_N], ECX
      !@@:
      ; ------------------------------------------------------------
                
      !MOV ECX, DWORD [p.v_eos]
      !Test ECX, ECX                ; Check BOOL EndOfStringFound      
    !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
              
    ;  Move yur ReturnValue to EAX, here it's the counter
    !MOV EAX, [p.v_N]         ; ReturnValue to EAX
    !.Return:
    
    ASM_POP_MM_0to3(RDX)      ; POP non volatile Registers we PUSH'ed at start
;    ASM_POP_MM_4to5(RDX)      ; POP non volatile Registers we PUSH'ed at start
    !EMMS                     ; Empty MMX Technology State, enables FPU Register use
    ProcedureReturn   ; EAX   
  EndMacro
  
  ; **************************************************
  ; x32 Assembler Version Classic 
  ; **************************************************
  ; Procedure CountChar(*String, cSearch.c, *outLength.Integer=0)
   Macro ASMx32_CountChar()     
  
    ; At x32 optimized classic ASM ist a good choice! On modern CPU like Ryzen
    ; it is nearly same speed as MMX-Code. XMM-Code is on all CPU's in x32 much 
    ; slower! On older CPU's back to 2010 AMD and Intel MMX is faster.
     
     ; @f = Jump forward to next @@;  @b = Jump backward to next @@  
    
    ; used Registers
    ;   EAX : *String
    ;   EBX : Counter
    ;   ECX : operating Register
    ;   EDX : cSearch
     
    ASM_PUSH_EBX()
    !MOV EAX, [p.p_String]      ; load String Adress
    !TEST EAX, EAX              ; If *String = 0
    !JZ .Return                 ;   Then End
    !SUB EAX, 2                 ; *String
    
    ; ----------------------------------------------------------------------
    ; Setup start parameter for registers 
    ; ----------------------------------------------------------------------     
    !XOR EBX, EBX
    !XOR ECX, ECX
    !XOR EDX, EDX
    !MOV DX, WORD[p.v_cSearch]  ; cSearch\c 
    
    !.Loop:
      !ADD EAX, 2            ; *String
      !MOV CX, WORD [EAX]    ; load Char to EDX   
      !TEST CX, CX           ; Test EndOfString
      !JZ .EndLoop
      
      ; ------------------------------------------------------------
      ; Start of function individual code!
      ; ------------------------------------------------------------
      ; Count number of found Chars 
      !CMP CX, DX 
      !JNE @f                 ; If cSearch\c found
         !INC EBX
      !@@:
      ; ------------------------------------------------------------
         
    !JMP .Loop
     
    ; optional Return Lenth
    !MOV ECX, [p.p_outLength]
    !TEST ECX, ECX
    !JZ @f
      !SUB EAX,  [p.p_String]
      !SHR EAX,1
      !MOV [ECX], EAX       ; *outLength = Len
    !@@:
    
    !.Return:
    !MOV EAX, EBX           ; Return Counter in EAX         
    ASM_POP_EBX()
    ProcedureReturn   ; counter
  EndMacro
  
  ; **************************************************
  ; Purebasic Version with *Pointer-Code
  ; **************************************************
  
  ; Procedure CountChar(*String, cSearch.c, *outLength.Integer=0)
  Macro PB_CountChar_ptr()
    Protected *pRead.Character = *String
    Protected N
      
    If Not *String
      ProcedureReturn 0
    EndIf
    
    While *pRead\c    ; Step trough the String
      If *pRead\c = cSearch.c
        N + 1
      EndIf
      *pRead + SizeOf(Character)
    Wend
   
    If *outLength       ; If Return Length
      *outLength\i = (*pRead - *String)/2
    EndIf
    ProcedureReturn N
  EndMacro
  
  ; **************************************************
  ; Purebasic Version using PB integrated functions
  ; **************************************************
  Macro PB_CountChar_PB()
    ; especally on Intel CPU's PB's CountString() and Len()
    ; performs better than the individual PB PointerCode
    Protected N
    Protected sStr.String           ; String Struct
    Protected *ptr.Integer = @sStr  ; Pointer to String Struct
      
    If *String
      *ptr\i = *String          ; Hook *String into String Struct @sStr = *String     
      N = CountString(sStr\s, Chr(cSearch))   
      If *outLength             ; If Return Length
        *outLength\i = Len(sStr\s)
      EndIf  
      *ptr\i = 0                ; Unhook String otherwise PB delete the String 
    EndIf 
    ProcedureReturn N  
  EndMacro
   
  Procedure _CountChar(*String, cSearch.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: CountChar
  ; DESC: Counts Characters in a String
  ; DESC: This example is for CountChar
  ; DESC: 
  ; VAR(*String) : Pointer to the String
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : Number of Characters found
  ; ============================================================================
 
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_Unicode
      
      CompilerIf #PB_Compiler_64Bit
      ; ************************************************************
      ; x64 Assembler
      ; ************************************************************
        ASMx64_CountChar()        ; XMM-Version
        
      CompilerElse ; #PB_Compiler_32Bit
      ; ************************************************************
      ; x32 Assembler
      ; ************************************************************
        ;ASMx32_CountChar()       ; classic x86 Assembler
        ASMx32_MMX_CountChar()    ; x32 with MMX
      CompilerEndIf 
       
    CompilerElseIf (#PB_Compiler_Backend = #PB_Backend_C) And #PB_Compiler_Unicode
       
      CompilerIf #PB_Compiler_64Bit
      ; ************************************************************
      ; x64 C
      ; ************************************************************
        PB_CountChar_ptr()
        
      CompilerElse ; #PB_Compiler_32Bit
      ; ************************************************************
      ; x32 C
      ; ************************************************************
        PB_CountChar_ptr()
        
      CompilerEndIf
      
    CompilerElse ; Ascii
    ; ************************************************************
    ; Ascii Strings < PB 5.5
    ; ************************************************************
      PB_CountChar_ptr()   
      
    CompilerEndIf 
      
  EndProcedure
  CountChar = @_CountChar()
  
  ;- --------------------------------------------------
  ;- ReplaceChar()
  ;- --------------------------------------------------
  
  ; **************************************************
  ; x64 Assembler Version with XMM-Registers
  ; ************************************************** 
  ; Procedure _ReplaceChar(*String, cSearch.c, cReplace.c, *outLength.Integer=0)
  Macro ASMx64_ReplaceChar()
    
    ; Used Registers:
    ;   RAX : Pointer *String
    ;   RCX : operating Register and Bool: 1 if NullChar was found
    ;   RDX : operating Register
    ;   R8  : Counter
    ;   R9  : operating Register
    
    ;   XMM0 : the 4 Chars
    ;   XMM1 : operating Register
    ;   XMM2 : 0 to search for EndOfString
    ;   XMM3 : the 4 Chars Backup
    
    ; If you use XMM4..XMM7 you have to backup it first
    ;   XMM4 : cSearch shuffeled to all Words
    ;   XMM5 :
    ;   XMM6 :
    ;   XMM7 :
    
    ASM_PUSH_XMM_4to5(RDX)     ; optional PUSH() see PbFw_ASM_Macros.pbi
    ASM_PUSH_XMM_6to7(RDX)     ; Push non volatile XMM-Registers
   
    ; ----------------------------------------------------------------------
    ; Check *String-Pointer and MOV it to RAX as operating register
    ; ----------------------------------------------------------------------
    !MOV RAX, [p.p_String]    ; load String address
    !TEST RAX, RAX            ; If *String = 0
    !JZ .Return               ; Exit    
    !SUB RAX, 8               ; Sub 8 to start with Add 8 in the Loop     
    ; ----------------------------------------------------------------------
    ; Setup start parameter for registers 
    ; ----------------------------------------------------------------------     
    ; your indiviual setup parameters
    !MOV DX, [p.v_cSearch]    ; should be DX not RDX because of 1 Word
    !MOVQ XMM4, RDX
    !PSHUFLW XMM4, XMM4, 0    ; Shuffle/Copy Word0 to all Words 
    
    ; here are the standard setup parameters
    !XOR RCX, RCX             ; operating Register and BOOL for EndOfStringFound
    !XOR R8, R8               ; Counter = 0
    !PXOR XMM2, XMM2          ; XMM2 = 0 ; Mask to search for NullChar = EndOfString         
    ; ----------------------------------------------------------------------
    ; Main Loop
    ; ----------------------------------------------------------------------     
    !.Loop:
      !ADD RAX, 8                     ; *String + 8 => NextChars    
      !MOVQ XMM0, [RAX]               ; load 4 Chars to XMM0  
      !MOVQ XMM3, [RAX]               ; load 4 Chars to XMM3
      !PCMPEQW XMM0, XMM2             ; Compare with 0
      !MOVQ RDX, XMM0                 ; RDX CompareResult contains FFFF for each NullChar 
      !TEST RDX, RDX                  ; If 0 : No NullChar found
      !JZ .EndIf                      ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
      ; If EndOfStringFound  
        ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
        !BSF RDX, RDX                 ; BitSanForward => No of the LSB   
        !SHR RDX, 3                   ; BitNo to ByteNo
        !ADD RAX, RDX                 ; Actual StringPointer + OffsetOf_NullChar
        !SUB RAX, [p.p_String]        ; RAX *EndOfString - *String
        !SHR RAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
        ;check for Return of Length and and move it to *outLength 
        !MOV RDX, [p.p_outLength]
        !TEST RDX, RDX
        !JZ @f                        ; If *outLength
          !MOV [RDX], RAX             ;   *outLength = Len()
        !@@:                          ; Endif
      
        ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
        !MOVQ RCX, XMM0               ; Load compare Result of 4xChars=0 to RCX
        !BSF RCX, RCX                 ; Find No of LSB [0..63] (if no Bit found it returns 0 too)
        !CMP RCX, 48                  ; If LSB >= 48 the EndOfString is the last of the 4 Chars
        !JGE @f                       ;  => we don't have to eliminate chars from testing
        ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 48..63 = Word 3
          !NEG RCX                      ; RCX = -LSB 
          !ADD RCX, 63                  ; RCX = (63-LSB)
          !XOR RDX, RDX                 ; RDX = 0
          !BTS RDX, 63                  ; set Bit 63 => RDX = 8000000000000000h
          !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
          !NOT RDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
          !MOVQ XMM0, RDX               ; Now move this Mask to XMM0, the operating Register
          !PAND XMM3, XMM0              ; XMM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
        !@@:
        
        !MOV RCX, 1                     ; BOOL EndOfStringFound = #TRUE
      !.EndIf:                        ; Endif ; EndOfStringFound    
      
      ; ------------------------------------------------------------
      ; Start of function individual code! Do not use RCX here!
      ; ------------------------------------------------------------
      ; Replace the Chars
      ; TODO! Implement CODE!
      ; ------------------------------------------------------------
      
      !TEST RCX, RCX                  ; Check BOOL EndOfStringFound      
    !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
     
    ; ----------------------------------------------------------------------
    ; Handle Return value an POP-Registers
    ; ----------------------------------------------------------------------     
    !MOV RAX, R8      ; ReturnValue to RAX
    !.Return:
    
    ASM_POP_XMM_4to5(RDX)     ; POP non volatile Registers we PUSH'ed at start
    ASM_POP_XMM_6to7(RDX)     ; POP non volatile Registers we PUSH'ed at start
    
    ProcedureReturn   ; RAX
    
  EndMacro
  
  ; **************************************************
  ; x32 Assembler Version with MMX-Registers
  ; **************************************************
  ; Procedure _ReplaceChar(*String, cSearch.c, cReplace.c, *outLength.Integer=0)
  Macro ASMx32_MMX_ReplaceChar()
    Protected eos       ; Bool EndOfString
    
    ; Used Registers:
    ;   EAX : Pointer *String
    ;   ECX : operating Register and Bool: 1 if NullChar was found
    ;   EDX : operating Register        
    
    ;   MM0 : the 4 Chars
    ;   MM1 : operating Register
    ;   MM2 : 0 to search for EndOfString
    ;   MM3 : the 4 Chars Backup
    ;   MM4 : cSearch shuffeled to all Words
    ;   MM5 :
    ;   MM6 :
    ;   MM7 :
      
    ASM_PUSH_MM_0to3(RDX)     ; PUSH nonvolatile MMX-Registers
    ASM_PUSH_MM_4to5(RDX)     ; PUSH nonvolatile MMX-Registers
             
    ; ----------------------------------------------------------------------
    ; Check *String-Pointer and MOV it to EAX as operating register
    ; ----------------------------------------------------------------------
    !MOV EAX, [p.p_String]    ; load String address
    !TEST EAX, EAX            ; If *String = 0
    !JZ .Return               ; Exit    
    !SUB EAX, 4               ; Sub 4 to start with Add 8 in the Loop     
    
    ; ----------------------------------------------------------------------
    ; Setup start parameter for registers 
    ; ----------------------------------------------------------------------     
    ; your indiviual setup parameters
    !MOV DX, [p.v_cSearch]    ; should be DX not EDX because of 1 Word
    !MOVD MM4, EDX
    !PSHUFW MM4, MM4, 0       ; Shuffle/Copy Word0 to all Words 
   
    ; here are the standard setup parameters
    !XOR ECX, ECX             ; operating Register and BOOL for EndOfStringFound
    !PXOR MM2, MM2            ; MM2 = 0 ; Mask to search for NullChar = EndOfString         
    ; ----------------------------------------------------------------------
    ; Main Loop
    ; ----------------------------------------------------------------------     
    !.Loop:
      !ADD EAX, 4                     ; *String + 8 => NextChars    
      !MOVD MM0, [EAX]                ; load 4 Chars to MM0  
      !MOVD MM3, [EAX]                ; load 4 Chars to MM3
      !PCMPEQW MM0, MM2               ; Compare with 0
      !MOVD EDX, MM0                  ; EDX CompareResult contains FFFF for each NullChar 
      !TEST EDX, EDX                  ; If 0 : No NullChar found
      !JZ .EndIf                      ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
      ; If EndOfStringFound  
        ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
        !BSF EDX, EDX                 ; BitSanForward => No of the LSB   
        !SHR EDX, 3                   ; BitNo to ByteNo
        !ADD EAX, EDX                 ; Actual StringPointer + OffsetOf_NullChar
        !SUB EAX, [p.p_String]        ; EAX *EndOfString - *String
        !SHR EAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
        ;check for Return of Length and and move it to *outLength 
        !MOV EDX, [p.p_outLength]
        !TEST EDX, EDX
        !JZ @f                        ; If *outLength
          !MOV [EDX], EAX             ;   *outLength = Len()
        !@@:                          ; Endif
      
        ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
        !MOVD ECX, MM0                ; Load compare Result of 4xChars=0 to ECX
        !BSF ECX, ECX                 ; Find No of LSB [0..31] (if no Bit found it returns 0 too)
        !CMP ECX, 16                  ; If LSB >= 16 the EndOfString is the last of the 4 Chars
        !JGE @f                       ;  => we don't have to eliminate chars from testing
        ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 16..31 = Word 3
          !NEG ECX                      ; ECX = -LSB 
          !ADD ECX, 31                  ; ECX = (31-LSB)
          !XOR EDX, EDX                 ; EDX = 0
          !BTS EDX, 31                  ; set Bit 31 => EDX = 8000000000000000h
          !SAR EDX, CL                  ; Do an arithmetic Shift Right (31-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
          !NOT EDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
          !MOVD MM0, EDX                ; Now move this Mask to MM0, the operating Register
          !PAND MM3, MM0                ; MM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
        !@@:
                  
        ;!MOV ECX, 1                   ; BOOL EndOfStringFound = #TRUE
        !MOV [p.v_eos], DWORD 1        ; at x32 we need ECX, so Bool EndOfstring in Var 
      !.EndIf:                         ; Endif ; EndOfStringFound    
      
      ; ------------------------------------------------------------
      ; Start of function individual code! You can use ECX here!
      ; ------------------------------------------------------------
      ; Count number of found Chars
      ; TODO! Implement CODE!
      ; ------------------------------------------------------------
                
      !MOV ECX, DWORD [p.v_eos]
      !TEST ECX, EXC                ; Check BOOL EndOfStringFound      
    !JZ .Loop                   ; Continue Loop if Not EndOfStringFound
                 
    ;  Move yur ReturnValue to EAX, here it's the counter
    !MOV EAX, [p.v_N]         ; ReturnValue to EAX
    !.Return:
    
    ASM_POP_MM_0to3(RDX)      ; POP non volatile Registers we PUSH'ed at start
    ASM_POP_MM_4to5(RDX)      ; POP non volatile Registers we PUSH'ed at start
    !EMMS                     ; Empty MMX Technology State, enables FPU Register use
    ProcedureReturn   ; EAX   
   
  EndMacro
  
  ; **************************************************
  ; x32 Assembler Version Classic 
  ; **************************************************
  ; Procedure _ReplaceChar(*String, cSearch.c, cReplace.c, *outLength.Integer=0)
  Macro ASMx32_ReplaceChar()
  
    ; At x32 optimized classic ASM ist a good choice! On modern CPU like Ryzen
    ; it is nearly same speed as MMX-Code. XMM-Code is on all CPU's much slower
    ; On older CPU's back to 2010 AMD and Intel MMX is faster.
    ; @f = Jump forward to next @@;  @b = Jump backward to next @@  
    
    ; used Registers
    ;   EAX : *String
    ;   EBX : Counter
    ;   ECX : operating Register
    ;   EDX : cSearch
    
    ASM_PUSH_EBX()
    
    !MOV EAX, [p.p_String]      ; load String Adress
    !TEST EAX, EAX              ; If *String = 0
    !JZ .Return                 ;   Then End
    !SUB EAX, 2                 ; *String
    
    ; ----------------------------------------------------------------------
    ; Setup start parameter for registers 
    ; ----------------------------------------------------------------------     
    !XOR EBX, EBX
    !XOR ECX, ECX
    !XOR EDX, EDX
    !MOV DX, WORD[p.v_cSearch]  ; cSearch\c 
    
    !.Loop:
      !ADD EAX, 2            ; *String
      !MOV CX, WORD [EAX]    ; load Char to EDX   
      !TEST CX, CX           ; Test EndOfString
      !JZ .EndLoop
      
      ; ------------------------------------------------------------
      ; Start of function individual code!
      ; ------------------------------------------------------------
      ; Count number of found Chars 
      !CMP CX, DX 
      !JNE @f                       ; If cSearch\c found
        !INC EBX                    ; Counter
        !MOV [EAX], [p.v_cReplace]  ; Replace the Char 
      !@@:
      ; ------------------------------------------------------------
         
      !JMP .Loop
    !.EndLoop:
    
    ; optional Return Lenth
    !MOV ECX, [p.p_outLength]
    !TEST ECX, ECX
    !JZ @f
      !SUB EAX,  [p.p_String]
      !SHR EAX,1
      !MOV [ECX], EAX       ; *outLength = Len
    !@@:
    
    !.Return:
    !MOV EAX, EBX           ; Return Counter in EAX         
    ASM_POP_EBX()
    ProcedureReturn   ; counter
  EndMacro
  
  ; **************************************************
  ; Purebasic Version with *Pointer-Code
  ; **************************************************
  
  ; Procedure ReplaceChar(*String, cSearch.c, cReplace.c, *outLength.Integer=0)
  Macro PB_ReplaceChar_ptr()
    Protected *pRead.Character = *String
    Protected N
      
    If Not *String
      ProcedureReturn 0
    EndIf
    
    While *pRead\c    ; Step trough the String
      If *pRead\c = cSearch
        *pRead\c = cReplace
        N + 1
      EndIf
      *pRead + SizeOf(Character)
    Wend
   
    If *outLength       ; If Return Length
      *outLength\i = (*pRead - *String)/2
    EndIf
    ProcedureReturn N
  EndMacro
    
  ; **************************************************
  ; Purebasic Version using PB integrated functions
  ; **************************************************
  Macro PB_ReplaceChar_PB()
    Protected N
    Protected sStr.String           ; String Struct
    Protected *ptr.Integer = @sStr  ; Pointer to String Struct
      
    If *String
      *ptr\i = *String          ; Hook *String into String Struct @sStr = *String     
      N = ReplaceString(sStr\s, Chr(cSearch), Chr(cReplace), #PB_String_CaseSensitive | #PB_String_InPlace)   
      If *outLength             ; If Return Length
        *outLength\i = Len(sStr\s)
      EndIf  
      *ptr\i = 0                ; Unhook String otherwise PB delete the String 
    EndIf 
    ProcedureReturn N    
  EndMacro

  Procedure _ReplaceChar(*String, cSearch.c, cReplace.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: _ReplaceChar
  ; DESC: !PointerVersion! use it as ProtoType ReplaceChar()
  ; DESC: Replace a Character in a String with an other Character
  ; DESC: To replace all ',' with a '.' use : _ReplaceChar(@MyString, ',', '.')
  ; DESC: This a replacement for ReplaceString() only for a single Char
  ; DESC: and with direct *String Access. This is 2-3 tiems faster than
  ; DESC: ReplaceString().
  ; DESC: To UCase a single char use ReplaceChar(MyString, 'e', 'E')
  ; DESC: RepleaceChar is 5-times faster than ReplaceString with Mode 
  ; DESC: #PB_String_InPlace 
  ; VAR(String$) : The String
  ; VAR(cSearch.c) : Character to search for and replace
  ; VAR(cReplace.c): the Replace Charcter (new Character)
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : Number of chars replaced
  ; ============================================================================
 
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_Unicode
      
      CompilerIf #PB_Compiler_64Bit
      ; ************************************************************
      ; x64 Assembler
      ; ************************************************************
        ASMx64_ReplaceChar()      ; XMM-Version
        
      CompilerElse ; #PB_Compiler_32Bit
      ; ************************************************************
      ; x32 Assembler
      ; ************************************************************
        ;ASMx32_ReplaceChar()       ; classic x86 Assembler
        ASMx32_MMX_REplaceChar()    ; x32 with MMX
        
      CompilerEndIf 
       
    CompilerElseIf (#PB_Compiler_Backend = #PB_Backend_C) And #PB_Compiler_Unicode
       
      CompilerIf #PB_Compiler_64Bit
      ; ************************************************************
      ; x64 C
      ; ************************************************************
        PB_ReplaceChar_ptr()
        
      CompilerElse ; #PB_Compiler_32Bit
      ; ************************************************************
      ; x32 C
      ; ************************************************************
        PB_ReplaceChar_ptr()
        
      CompilerEndIf
      
    CompilerElse ; Ascii
    ; ************************************************************
    ; Ascii Strings < PB 5.5
    ; ************************************************************
      PB_ReplaceChar_ptr()
       
    CompilerEndIf
    
  EndProcedure    
  ReplaceChar = @_ReplaceChar()     ; Bind ProcedureAddress to the PrototypeHandler
  
  ;- --------------------------------------------------
  ;- RemoveCharFast()
  ;- --------------------------------------------------
  
  ; **************************************************
  ; x64 Assembler Version with XMM-Registers
  ; ************************************************** 
  
  ; **************************************************
  ; x32 Assembler Version with MMX-Registers
  ; **************************************************
  
  ; **************************************************
  ; x32 Assembler Version Classic 
  ; **************************************************
  
  ; **************************************************
  ; Purebasic Version with *Pointer-Code
  ; **************************************************
  Macro PB_RemoveCharFast_ptr()
  EndMacro
  
  ; **************************************************
  ; Purebasic Version using PB integrated functions
  ; **************************************************

  Procedure.i RemoveCharFast(*String, cSearch.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: RemoveChar
  ; NAME: Attention! This is a Pointer-Version! Be sure to call it with a
  ; DESC: correct String-Pointer
  ; DESC: Removes a Character from the String
  ; DESC: The String will be shorter after
  ; VAR(*String) : Pointer to String
  ; VAR(cSearch.c) : The Character to remove
  ; RET: Number of removed Chars 
  ; ============================================================================
 
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_Unicode
      
      CompilerIf #PB_Compiler_64Bit
      ; ************************************************************
      ; x64 Assembler
      ; ************************************************************
        
        PB_RemoveCharFast_ptr()
        ;ASMx64_RemoveCharFast()      ; XMM-Version
        
      CompilerElse ; #PB_Compiler_32Bit
      ; ************************************************************
      ; x32 Assembler
      ; ************************************************************
        
        PB_RemoveCharFast_ptr()
        ;ASMx32_RemoveCharFast()       ; classic x86 Assembler
        ;ASMx32_MMX_RemoveCharFast()    ; x32 with MMX
        
      CompilerEndIf 
       
    CompilerElseIf (PB_Compiler_Backend = #PB_Backend_C) And #PB_Compiler_Unicode
       
      CompilerIf #PB_Compiler_64Bit
      ; ************************************************************
      ; x64 C
      ; ************************************************************
        PB_RemoveCharFast_ptr()
        
      CompilerElse ; #PB_Compiler_32Bit
      ; ************************************************************
      ; x32 C
      ; ************************************************************
        PB_RemoveCharFast_ptr()
        
      CompilerEndIf
      
    CompilerElse ; Ascii
    ; ************************************************************
    ; Ascii Strings < PB 5.5
    ; ************************************************************
      PB_RemoveCharFast_ptr()
       
    CompilerEndIf
    
  EndProcedure    
 
  
  ;- --------------------------------------------------
  ;- Module Public Functions as Protytypes
  ;- -------------------------------------------------- 
  
  Procedure.i _ReplaceChar_(*String, cSearch.c, cReplace.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: _ReplaceChar
  ; DESC: !PointerVersion! use it as ProtoType ReplaceChar()
  ; DESC: Replace a Character in a String with an other Character
  ; DESC: To replace all ',' with a '.' use : _ReplaceChar(@MyString, ',', '.')
  ; DESC: This a replacement for ReplaceString() only for a single Char
  ; DESC: and with direct *String Access.
  ; DESC: To UCase a single char use ReplaceChar(MyString, 'e', 'E')
  ; DESC: RepleaceChar is 5-times faster than ReplaceString with Mode 
  ; DESC: #PB_String_InPlace 
  ; VAR(String$) : The String
  ; VAR(cSearch.c) : Character to search for and replace
  ; VAR(cReplace.c): the Replace Charcter (new Character)
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : Number of chars replaced
  ; ============================================================================
    
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_64Bit And #PB_Compiler_Unicode
      
    Protected R64.TStack_32Byte
    
      ; Used Registers:
      ;   RAX : Pointer *String
      ;   RCX : operating Register and Bool: 1 if NullChar was found
      ;   RDX : operating Register
      ;   R8  : Counter
      ;   R9  : operating Register
  
      ;   MM0 : the 4 Chars
      ;   MM1 : operating Register
      ;   MM2 : 0 to search for EndOfString
      ;   MM3 : the 4 Chars Backup
      
      ; If you use MM4..MM7 you have to backup it first
      ;   MM4 : cSearch shuffeled to all Words
      ;   MM5 : cReplace shuffeld to all Words
      ;   MM6 :
      ;   MM7 :
     
      ; ----------------------------------------------------------------------
      ; Check *String-Pointer and MOV it to RAX as operating register
      ; ----------------------------------------------------------------------
      !MOV RAX, [p.p_String]    ; load String address
      !TEST RAX, RAX            ; If *String = 0
      !JZ .Return               ; Exit    
      !SUB RAX, 8               ; Sub 8 to start with Add 8 in the Loop     
      ; ----------------------------------------------------------------------
      ; Backup Registers which are not free to use (like MM4..MM7 or R10..R15)
      ; ----------------------------------------------------------------------    
      !LEA RDX, [p.v_R64]       ; RDX = @R64 = Pionter to RegisterBackupStruct
      !MOVQ [RDX], MM4
      !MOVQ [RDX+8], MM5
      !MOVQ [RDX+16], MM6
      !MOVQ [RDX+24], MM7           
      ; ----------------------------------------------------------------------
      ; Setup start parameter for registers 
      ; ----------------------------------------------------------------------     
      ; your indiviual setup parameters
      !MOV DX, [p.v_cSearch]    ; should be DX not RDX because of 1 Word
      !MOVQ MM4, RDX
      !PSHUFW MM4, MM4, 0       ; Shuffle/Copy Word0 to all Words 
      
      !MOV DX, [p.v_cReplace]   ; should be DX not RDX because of 1 Word
      !MOVQ MM5, RDX
      !PSHUFW MM5, MM5, 0       ; Shuffle/Copy Word0 to all Words 
     
      ; here are the standard setup parameters
      !XOR RCX, RCX             ; operating Register and BOOL for EndOfStringFound
      !XOR R8, R8               ; Counter = 0
      !PXOR MM2, MM2            ; MM2 = 0 ; Mask to search for NullChar = EndOfString         
      ; ----------------------------------------------------------------------
      ; Main Loop
      ; ----------------------------------------------------------------------     
      !.Loop:
        !ADD RAX, 8                     ; *String + 8 => NextChars    
        !MOVQ MM0, [RAX]                ; load 4 Chars to MM0  
        !MOVQ MM3, [RAX]                ; load 4 Chars to MM3
        !PCMPEQW MM0, MM2               ; Compare with 0
        !MOVQ RDX, MM0                  ; RDX CompareResult contains FFFF for each NullChar 
        !TEST RDX, RDX                  ; If 0 : No NullChar found
        !JZ rc_EndIf                    ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
        ; If EndOfStringFound  
          ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
          !BSF RDX, RDX                 ; BitSanForward => No of the LSB   
          !SHR RDX, 3                   ; BitNo to ByteNo
          !ADD RAX, RDX                 ; Actual StringPointer + OffsetOf_NullChar
          !SUB RAX, [p.p_String]        ; RAX *EndOfString - *String
          !SHR RAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
          ;check for Return of Length and and move it to *outLength 
          !MOV RDX, [p.p_outLength]
          !TEST RDX, RDX
          !JZ rc_LenEndif               ; If *outLength
            !MOV [RDX], RAX             ;   *outLength = Len()
          !rc_LenEndif:                 ; Endif
        
          ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
          !MOVQ RCX, MM0                ; Load compare Result of 4xChars=0 to RCX
          !BSF RCX, RCX                 ; Find No of LSB [0..63] (if no Bit found it returns 0 too)
          !CMP RCX, 48                  ; If LSB >= 48 the EndOfString is the last of the 4 Chars
          !JGE rc_MaskEndif               ;  => we don't have to eliminate chars from testing
          ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 48..63 = Word 3
            !NEG RCX                      ; RCX = -LSB 
            !ADD RCX, 63                  ; RCX = (63-LSB)
            !XOR RDX, RDX                 ; RDX = 0
            !BTS RDX, 63                  ; set Bit 63 => RDX = 8000000000000000h
            !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
            !NOT RDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
            !MOVQ MM0, RDX                ; Now move this Mask to MM0, the operating Register
            !PAND MM3, MM0                ; MM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
          !rc_MaskEndif:
                    
          !MOV RCX, 1                   ; BOOL EndOfStringFound = #TRUE
        !rc_EndIf:                      ; Endif ; EndOfStringFound    
        
        ; ------------------------------------------------------------
        ; Start of function individual code! Do not use RCX here!
        ; ------------------------------------------------------------
        ; Check for cSearch, replace with cReplace and count
        !MOVQ MM0, MM3                ; Load the 4 Chars to operating Register
        !PCMPEQW MM0, MM4             ; Compare the 4 Chars with cSearch
        !MOVQ RDX, MM0                ; CompareResult to RDX
        !TEST RDX, RDX
        !JZ @f                        ; Jump to Endif if cSearch not found
          ; Filter CharsToReplace -> MM0
          !PAND MM0, MM5              ; Filter ReplaceChars from 4xReplaeChar to get BlendMask
          ; Filter CharsToKeep -> MM1
          !MOV R9, RDX                ; CompareResultMask to R9
          !NOT R9                     ; Invert CompareResultMask (to filter characters to keep)
          !MOVQ MM1, R9               ; Move the Mask to MM1 operating Register
          !PAND MM1, MM3              ; now filter charactes to keep, FilterMask AND (4xChars)
          ; Create combination of CharsToKeep and CharsToReplace
          !POR MM0, MM1               ; combine MM0 ReplaceChars and MM1 CharctersToKeep
          !MOVQ [RAX], MM0            ; save the modified Chars back to Memory
          ; count No of replaced Chars by counting Bits in CompareResultMask
          !POPCNT RDX, RDX            ; Count number of set Bits in RDX, CompareResultMask (16 Bits set for each found Char)
          !SHR RDX, 4                 ; BitNo to ByteNo because of Words => RDX coantians the No. of found cSearch\c
          !ADD R8, RDX                ; Add number of found cSearch\c to Counter R8
        !@@:
        ; ------------------------------------------------------------
  
        !TEST RCX, RCX                ; Check BOOL EndOfStringFound      
      !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
      
      ; ----------------------------------------------------------------------
      ; Restore Registers which are not free to use (like MM4..MM7 or R10..R15)
      ; ----------------------------------------------------------------------     
      !LEA RDX, [p.v_R64]             ; RDX = @R64 = Pionter to RegisterBackupStruct
      !MOVQ [RDX], MM4
      !MOVQ [RDX+8], MM5
      !MOVQ [RDX+16], MM6
      !MOVQ [RDX+24], MM7
      
      ;  Move yur ReturnValue to RAX, here it's the counter in R8
      !MOV RAX, R8      ;  ReturnValue to RAX
      !EMMS             ; Empty MMX Technology State, enables FPU Register use
      !.Return:
      ProcedureReturn   ; RAX
      
    CompilerElse        ; C-Backend OR x32 OR Ascii
      
      Protected *pRead.Character = *String 
      Protected N
      
      If *pRead    
        While *pRead\c                ; until end of String
          If *pRead\c =  cSearch
            *pRead\c = cReplace       ; replace the Char
            N + 1
          EndIf
          *pRead + SizeOf(Character)  ; Index to next Char
        Wend
      EndIf
      
      ; optional return of String Length
      If *outLength
        *outLength\i = (*pRead - *String)/2
      EndIf
      
      ProcedureReturn N
      
    CompilerEndIf
    
  EndProcedure
  ; ReplaceChar = @_ReplaceChar()     ; Bind ProcedureAddress to the PrototypeHandler

  ; for Strings we can use the PB CountString()
  
  Procedure.i CountUnicodeChars(*StringW, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: CountUnicodeChars
  ; DESC: Count the number of Unicode Charcters, Chr(>255), in the String.
  ; DESC: This can be used for an IsUnicodeUsed test 
  ; DESC: Optional it returns the String Length!
  ; VAR(*String): Pointer to String of 2 Bytes per Character
  ; VAR(*outLength): Optional a Pointer to an Int to receive the Stringlength
  ; RET.i : Number of Unicode Characters, Chr(>255), in the String
  ; ============================================================================
      
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_64Bit 
     
    ; used Registers
    ; RAX : *String
    ; RDX : temporary Regiter
    ; RCX : Bool EndOfString found
    ; R8  : Counter
    ; R9  : Backup for MM4
    ; MM0 : Operation Register for the 4 Chars
    ; MM1 : = 0
    ; MM2 : [cuni_sat] Saturation Mask FFF.FFF.FFF.FFF
    ; MM3 : [cuni_hi]  AddMask to get saturation for Chars>255
    ; MM4 : Backup the 4 Chars
    
    ; load *String
    !MOV RAX, [p.p_StringW]
    !TEST RAX, RAX
    !JZ .Return
    !SUB RAX, 8
    
    ; save MM4 Register in free Registers R9
    !MOVQ R9, MM4
  
    !PXOR MM1, MM1                 ; MM1=0
    !MOVQ MM2, [cuni_sat]
    !MOVQ MM3, [cuni_hi]
    !XOR RCX, RCX                 ; Bool for NullCharFound 
    !XOR R8, R8
    
    !.Loop:
      !ADD RAX, 8                 ; *String +8 
      !MOVQ MM0, [RAX]            ; load 4 Chars
      !MOVQ MM4, [RAX]            ; Backup the 4 Chars
      !PCMPEQW MM0, MM1           ; Compare with 0
      !MOVQ RDX, MM0              ; RDX CompareResult
      !TEST RDX, RDX              ; If 0 : No NullChar found
      !JZ .cont
      ; If NullCharFound
         
        !MOVQ MM0, MM4
        !PCMPEQW MM0, MM1           ; Compare the 4 Chars with 0 to search EndOfString
        !MOVQ RDX, MM0              ; Compare Result Mask -> RDX, contains now FFFFh for each Word which was 0 
        ; EndOfString : calculate Length
        !BSF RDX, RDX               ; BitSanForward => No of the LSB   
        !SHR RDX, 3                 ; BitNo to ByteNo
        !ADD RAX, RDX               ; Actual StringPointer + OffsetOf_NullChar
        !SUB RAX, [p.p_StringW]     ; RAX *EndOfString - *String
        !SHR RAX, 1                 ; NoOfBytes to NoOfWord => Len(String)
        ;check for Return of Length and and move it to *outLength 
        !MOV RDX, [p.p_outLength]
        !TEST RDX, RDX
        !JZ cuni_m01
          !MOV [RDX], RAX           ; Return Length
        !cuni_m01:
        
        ; Mask out Chars after EndOfString
        !MOVQ RCX, MM0                  ; Compare Result Mask -> RDX, contains now FFFFh for each Word which was 0 
        !BSF RCX, RCX                   ; BitSan => No of the LSB      
        !CMP RCX, 47                    ; If LSB > 47 the EndOfString is the last of the 4 Chars
        !JG cuni_m02                    ;  => we don't have to eliminate chars from testing  
          !NEG RCX                      ; RCX = -LSB 
          !ADD RCX, 63                  ; RCX = (63-LSB)
          !XOR RDX, RDX                 ; RDX = 0
          !BTS RDX, 63                  ; set Bit 63, the Sign Bit
          !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-LSB)
          !NOT RDX                      ; Now invert our Mask so we get NoOfSetBits on the riht sight = LSB of compare Result
          !MOVQ MM0, RDX                ; Now move this Mask to MM0
          !PAND MM4, MM0                ; Mask out characters after EndOfString 
        !cuni_m02:
        
        !MOV RCX,1                      ; RCX = 1 => EndOfString found
      ; Endif
      !.cont:
  
      !MOVQ MM0, MM4          ; The 4 Chars back to MM0
      ; hi saturation Chars > 255
      !PADDUSW MM0, MM3       ; [cuni_hi] Add 65279 (FEFF) to each Char => we get FFFF for Each Char>255 
      !PCMPEQW MM0, MM2       ; [cuni_sat] With a compare with 65535 we get FFFF Mask for each word which is 65535, $FFFF 
      !MOVQ RDX, MM0
      !POPCNT RDX, RDX        ; Count number of Bits set (16Bits are set for each Char >255)
      !SHR RDX, 4             ; NoOfBits to NoOfWords
      !Add R8, RDX            ; Add number of found UnicodeChars
      
      !TEST RCX, RCX          ; RCX<>0 => NullChar was found
    !JZ .Loop                 ;  If RCX=0 Then Repeat Loop
         
    ; Restore MM4 Register from R9
    !MOVQ MM4, R9
    ;return counter
    !MOV RAX, R8
    !EMMS             ; Empty MMX Technology State, enables FPU Register use
    !.Return:
    ProcedureReturn  ; RAX = R = Counter
    
    DataSection
      ; Attention: FASM nees a leading 0 for hex values
      ; !lc_00:  dq 00h                  ; not needed because we use MM5=0
      !cuni_sat: dq 0FFFFFFFFFFFFFFFFh    ; Mask with saturated Character value, it's the max 16Bit value unsigned
      !cuni_hi:  dq 0FEFFFEFFFEFFFEFFh    ; FFFFh-256 = FEFF = 65279
    EndDataSection
  
   CompilerElse  ; C-Backend or x32 
     
     Debug "Classic PB Code"
      Protected *pRead.Character = *String
      Protected N
      
      If *pRead       ; Pointer <> 0
        While *pRead\c
          If *pRead\c > 255
            N + 1
          EndIf
          *pRead + 2    ; don't use SiezOf(Character)
        Wend
      EndIf
      
      ; optional return of String Length
      If *outLength
        *outLength\i = (*pRead - *String)/2
      EndIf
      
      ProcedureReturn N
      
    CompilerEndIf
  EndProcedure 
 
  Procedure.i _FindCharReverse(*String.Character, cSearch.c, cfgReturnValue = #FStr_ReturnCharNo, *outEndOfString.Integer=0)
  ; ============================================================================
  ; NAME: FindCharReverse
  ; DESC: !PointerVersion! use it as ProtoType FindCharReverse()
  ; DESC: Finds the first psoition of Char from reverse
  ; DESC: 
  ; VAR(*String.Character) : Pointer to the String
  ; VAR(cSearch) : Character to find
  ; VAR(cfgReturnValue) : #FStr_ReturnCharNo=0 => Returns Charposition 1..n or 0
  ;                       #FStr_ReturnPointer=1 => Returns address of Char or 0
  ; VAR(*outEndOfString=0) : Optional Pointer to return the address of EndOfString/NullChar
  ; RET.i : Character Position 1..n of cSearch or Pointer to cSearch  
  ; ============================================================================
    
    Protected *LastChar
    
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_64Bit And #PB_Compiler_Unicode
      
      ; Used Registers:
      ;   RAX : Pointer
      ;   RCX : temporary Var
      ;   RDX : temporary Var
      ;   R8  : Bool: 0 if NullChar was found
      ;   R9  : Pointer of last found Char
      ;   MM0 : the 4 Chars
      ;   MM1 : cSearch shuffeled to all Words
      ;   MM2 : 0 to search for EndOfString
      ;   MM3 : the 4 Chars Backup
      
      !MOV RAX, [p.p_String]    ; load String address
      !TEST RAX, RAX            ; If *String = 0
      !JZ .Return               ;   End
      
      !SUB RAX, 8               ; Sub 8 to start with Add 2 in the Loop
      !XOR RCX, RCX             ; RCX = 0
      !XOR R9, R9
      !MOV R8, RAX
      
      !MOV CX, WORD [p.v_cSearch] ; load search char to RCX
      !MOVQ MM1, RCX              ; load search char to MM1
      !PSHUFW MM1, MM1, 0         ; Copy search char to all Words of MM1
      
      !PXOR MM2, MM2              ; MM2 = 0 ; Mask to search for NullChar = EndOfString 
      
      ; PCMPEQW 
      !.Loop:
        !ADD RAX, 8                   ; *String + 8 => NextChar    
        !MOVQ MM0, [RAX]              ; load 4 Chars to MM0  
        !MOVQ MM3, [RAX]              ; load 4 Chars to MM3
        
        !PCMPEQW MM3, MM2             ; now compare the 4 Chars in MM3 with 00 to find EndOfString
        !MOVQ RCX, MM3                ; Move compare result to RCX
        !TEST RCX, RCX                   ; If CompareResult = 0 Then No NullChar found
        !JZ .cont                   ;   Goto Count cSearch\c
        
        !XOR R8, R8                   ; If a NullChar was found set RAX = 0, it's our Pointer
        
        ; if a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
        !BSF RCX, RCX                 ; Find No of LSB [0..63]
        !PUSH RCX                     ; save Bitposition for calculating ByteOffset for *outEndOfString
        !CMP RCX, 47                  ; If LSB > 47 the EndOfString is the last of the 4 Chars
        !JG .cont                     ;  => we don't have to eliminate chars from testing
          !NEG RCX                      ; RCX = -LSB 
          !ADD RCX, 63                  ; RCX = (63-LSB)
          !MOV RDX, 8000000000000000h   ; Move a 1 to Bit 63, the Sign Bit
          !SAR RDX, CL                  ; Do an arithmetic Shift Right (63-NoOfMosSignificantBit)-1
          !NOT RDX                      ; Now invert our Mask so we get NoOfSetBits on the riht sight = NoOfMostSignificantBit of compare Result
          !MOVQ MM3, RDX                ; Now move this Mask to MM4
          !PAND MM0, MM3                ; MM0 AND Mask => we select only Bits up to EndOfString included       
        !.cont:
          
        !PCMPEQW MM0, MM1           ; Compare all 4 Chars in MM0 with cSearch\c in MM1 
        !MOVQ RCX, MM0              ; now MM0 contains FFh for each char which is equal -> RCX
        !BSF RCX, RCX               ; BitScan finds the LSB Bitposition
        !SHR RCX, 3                 ; BitNo => ByteNO
        !MOV R9, RAX                ; *LastChar = Actual StringPointer
        !ADD R9, RCX                ; *LastChar + ByteNo ; Address of last found Character
        !TEST R8, R8                ; If NullChar was found RAX was set to 0 => EndOfString
      !JNZ .Loop                    ; Jump Not Equal => Repeat Until RAX = 0
      
      !.Return:   
      
      ; *outEndOfString
      !POP RCX                        ; Get back BSF result for EndOfString Offset
      !SHR RCX, 3                     ; BitNo to ByteNo
      !ADD RAX, RCX                   ; Pointer to EndOfString      
      !MOV RDX, [p.p_outEndOfString]
      !TEST RDX, RDX                  ; If Not *outEndOfString Then
      !JZ @f
        !MOV [RDX], RAX               ;   [MoveIfNotEqual] *outEndOfString\i = RAX = PointerEndOfString
      !@@:
      ; *LastChar
      !MOV RDX, [p.p_LastChar]         ; Pointer of last found Char to RDX
      !MOV [RDX], R9                   ; *LastChar = R9
      !EMMS             ; Empty MMX Technology State, enables FPU Register use
      
      If cfgReturnValue =  #FStr_ReturnPointer Or *LastChar = 0
        ProcedureReturn *LastChar
      Else
        ProcedureReturn (*LastChar - *String) / SizeOf(Character) + 1
      EndIf
     
    CompilerElse
      
      If Not *String
        ProcedureReturn 0
      EndIf
      
      While *String\c
        If *String\c = cSearch
          *LastChar = *String
        EndIf
        *String + SizeOf(Character)
      Wend
      
      If *outEndOfString
        *outEndOfString\i = *String
      EndIf
      
      If cfgReturnValue =  #FStr_ReturnPointer Or *LastChar = 0
        ProcedureReturn *LastChar
      Else
        ProcedureReturn (*LastChar - *String) / SizeOf(Character) + 1
      EndIf
      
    CompilerEndIf
    
  EndProcedure
  FindCharReverse = @_FindCharReverse()   ; Bind ProcedureAddress to the PrototypeHandler
  
  ;- --------------------------------------------------
  ;- ToggleStringEndianess()
  ;- --------------------------------------------------
  
  Macro ASMx64_ChangeByteOrder()
    ; process 4 Chars simultan (64Bit)
    
    DisableDebugger
    !MOV RAX, [p.p_String]      ; String Pointer to RAX
    !TEST RAX, RAX
    !JZ .Return
    !SUB RAX, 8                 ; Sub 16 to start with an ADD in the While Loop 
    
    !PXOR XMM2, XMM2
    !MOVLPS XMM2, [mask]     ; load Shuffle Mask
    !PXOR XMM0, XMM0            ; MM0 = 0 needed for search EndOfString
  
    !.loop:  
      !ADD RAX, 8               ; StringPointer + 8
      !MOVQ XMM1, [RAX]         ; load 8 Chars to XMM1
      !PSHUFB XMM1, XMM2        ; Shuffel a ByteSwap per Character
      !MOVQ [RAX], XMM1         ; save Characters with toggeled Endianess
      !PCMPEQW XMM1, XMM0       ; search for NullChar
      !MOVQ RDX, XMM1           ; Move the ResultMask to RDX
      !TEST RDX, RDX            ; If ResultMask = 0 ; no NullChar found
    !JZ .loop                   ;   Repeat Loop   
    
    !.Return:
    !MOV RAX, [p.p_String]      ; Return *String  
    ProcedureReturn   ; if using ASM Datasection, without PB DataSection command need a Return first
    
    DataSection   
      ; ASM DataSection
      ; Mask:   ; Shuffle Mask to xchange the 2 Bytes in each of the 4 Words form a DoublQuad
      !mask: dq 0607040502030001h
    EndDataSection  
    EnableDebugger
  EndMacro
  
  ; Procedure.i ChangeByteOrder(*String, *outLength.Integer=0)
  
  Macro ASMx32_MMX_ChangeByteOrder()
    Protected eos       ; Bool EndOfString
    
    ; Used Registers:
    ;   EAX : Pointer *String
    ;   ECX : operating Register and Bool: 1 if NullChar was found
    ;   EDX : operating Register        
    
    ;   MM0 : the 4 Chars
    ;   MM1 : Suffle Mask
    ;   MM2 : 0 to search for EndOfString
    ;   MM3 : the 4 Chars Backup
    ;   MM4 : 
    ;   MM5 :
    ;   MM6 :
    ;   MM7 :
      
    ASM_PUSH_MM_0to3(RDX)     ; PUSH nonvolatile MMX-Registers
          
    ; ----------------------------------------------------------------------
    ; Check *String-Pointer and MOV it to EAX as operating register
    ; ----------------------------------------------------------------------
    !MOV EAX, [p.p_String]    ; load String address
    !TEST EAX, EAX            ; If *String = 0
    !JZ .Return               ; Exit    
    !SUB EAX, 4               ; Sub 4 to start with Add 8 in the Loop     
    
    ; ----------------------------------------------------------------------
    ; Setup start parameter for registers 
    ; ----------------------------------------------------------------------     
    ; your indiviual setup parameters    
    !PXOR MM1, MM1
    !MOVQ MM1, [CBMM_mask]       ; load Shuffle Mask
   
    ; here are the standard setup parameters
    !PXOR MM2, MM2            ; MM2 = 0 ; Mask to search for NullChar = EndOfString         
    ; ----------------------------------------------------------------------
    ; Main Loop
    ; ----------------------------------------------------------------------     
    !.Loop:
      !ADD EAX, 4                     ; *String + 8 => NextChars    
      !MOVD MM0, [EAX]                ; load 4 Chars to MM0  
      !MOVD MM3, [EAX]                ; load 4 Chars to MM3
      !PCMPEQW MM0, MM2               ; Compare with 0
      !MOVD EDX, MM0                  ; EDX CompareResult contains FFFF for each NullChar 
      !TEST EDX, EDX                  ; If 0 : No NullChar found
      !JE .EndIf                    ; JumpIfEqual 0 => JumpToEndif if Not EndOfString  
      ; If EndOfStringFound  
        ; Caclulate the Bytepostion of EndOfString [0..3] using Bitscan
        !BSF EDX, EDX                 ; BitSanForward => No of the LSB   
        !SHR EDX, 3                   ; BitNo to ByteNo
        !MOV ECX, EDX                 ; Backup ByteNo in ECX
        !ADD EAX, EDX                 ; Actual StringPointer + OffsetOf_NullChar
        !SUB EAX, [p.p_String]        ; EAX *EndOfString - *String
        !SHR EAX, 1                   ; NoOfBytes to NoOfWord => Len(String)
        ;check for Return of Length and and move it to *outLength 
        !MOV EDX, [p.p_outLength]
        !TEST EDX, EDX
        !JZ @f                        ; If *outLength
          !MOV [EDX], EAX             ;   *outLength = Len()
        !@@:                          ; Endif
      
        ; If a Nullchar was found Then create a Bitmask for setting all Chars after the NullChar to 00h 
        !CMP ECX, 2                   ; If LSB >= 16 the EndOfString is the last of the 2 Chars
        !JGE @f                       ;  => we don't have to eliminate chars from testing
        ; If WordPos(EndOfString) <> 3  ; Word3 if EndOfString is in Bit 16..31 = Word 3
          !SHL ECX, 3                   ; ByteNo to BitNo
          !NEG ECX                      ; ECX = -LSB 
          !ADD ECX, 31                  ; ECX = (31-LSB)
          !XOR EDX, EDX                 ; EDX = 0
          !BTS EDX, 31                  ; set Bit 31 => EDX = 80000000h
          !SAR EDX, CL                  ; Do an arithmetic Shift Right (31-LSB) : EndOfString=Word2 => Mask $FFFF.FFFF.0000.0000, Word1 $FFFF.FFFF.FFFF.0000
          !NOT EDX                      ; Now invert our Mask so we get a Mask to fileter out all Chars after EndOfString $0000.0000.FFFF.FFFF or $0000.0000.0000.FFFF
          !MOVD MM0, EDX                ; Now move this Mask to MM0, the operating Register
          !PAND MM3, MM0                ; MM3 the CharBackup AND Mask => we select only Chars up to EndOfString 
        !@@:
                  
        !MOV [p.v_eos], DWORD 1        ; at x32 we need ECX, so Bool EndOfstring in Var 
      !.EndIf:                      ; Endif ; EndOfStringFound    
      
      ; ------------------------------------------------------------
      ; Start of function individual code! You can use ECX here!
      ; ------------------------------------------------------------
      
      ; Shuffle a ByteSwap per WORD
      !PSHUFB MM3, MM1              ; Shuffel a ByteSwap per Character
      !MOVD [EAX], MM3              ; Write Back to Memory 2 Chars
      ; ------------------------------------------------------------
                
      !MOV ECX, DWORD [p.v_eos]
      !Test ECX, ECX                ; Check BOOL EndOfStringFound      
    !JZ .Loop                       ; Continue Loop if Not EndOfStringFound
               
    ;  Move yur ReturnValue to EAX, here it's the counter
    !MOV EAX, [p.p_String]        ; ReturnValue to EAX
    !.Return:
    
    ASM_POP_MM_0to3(RDX)      ; POP non volatile Registers we PUSH'ed at start
    !EMMS                     ; Empty MMX Technology State, enables FPU Register use
    ProcedureReturn   ; EAX   
    
    DataSection   
      ; ASM DataSection
      ; Mask:   ; Shuffle Mask to xchange the 2 Bytes in each of the 4 Words form a DoublQuad
      !CBMM_mask: dq 0607040502030001h
    EndDataSection  
    EnableDebugger
  EndMacro

  Procedure.i ToggleStringEndianess(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: ToggleStringEndianess
  ; DESC: Toggles the endianess of a 2Byte Character String between 
  ; DESC: BigEndian/Motorola <=> LittleEndian/Intel. 
  ; DESC: Each call changes the Endianess directly in memory.
  ; VAR(*String) : Pointer to the String
  ; RET.i : *String 
  ; ============================================================================

    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm)    
      
      CompilerIf #PB_Compiler_64Bit   
        ; QuadChar Version
        ; at x64 PB-Strings are Align 8, so it is best to use MMX Suffle Command
        ; to change Byte-Order. BSWAP isn't a good choice in this case because
        ; it reverses the Char-Order
        ; Used Registers
        ;   RAX : *String
        ;   RDX : compare result
        ;   MM0 : 0, for searching NullChar
        ;   MM1 : operating Register
        ;   MM2 : Shuffle Mask
       
        !MOV RAX, [p.p_String]      ; String Pointer to RAX
        !TEST RAX, RAX              ; If *String = 0
        !JZ .Return                 ;   Exit
        !SUB RAX, 8                 ; Sub 8 to start with an ADD in the Loop 
        
        !MOVQ MM2, qword[ts_mask]   ; load Shuffle Mask
        !PXOR MM0, MM0              ; MM0 = 0 needed for search EndOfString
       
        !ts_loop:                   
          !ADD RAX, 8               ; StringPointer + 8
          !MOVQ MM1, [RAX]          ; load 8 Chars to XMM1
          !PSHUFB MM1, MM2          ; Shuffel a ByteSwap per Character
          !MOVQ [RAX], MM1          ; save Chars with changed Endianess
          !PCMPEQW MM1, MM0         ; search for NullChar
          !MOVQ RDX, MM1            ; Move the ResultMask to RDX
          !CMP RDX, 0               ; If ResultMask = 0 ; no NullChar found
          !JE ts_loop               ;   Repeat Loop   
        !EMMS             ; Empty MMX Technology State, enables FPU Register use
        
        !.Return:
        !MOV RAX, [p.p_String]      ; Return *String
        ProcedureReturn   ; if using ASM Datasection, without PB DataSection command need a Return first  
        
        DataSection 
          ; ASM DataSection
          ; !Align 8 ; dq = DataQuad   
          ; Mask:   ; Shuffle Mask to xchange the 2 Bytes in each of the 4 Words/Chars
          !ts_mask: dq 0607040502030001h
        EndDataSection
  
      CompilerElse ; #PB_Compiler_32Bit
        ; DoubleChar Version
        ; at x32 a PB_Strings are Align 4, so classic ASM-Code is the best choice
        ; Used Registers
        ;   EAX : *String
        ;   EDX : operating register
        ;   ECX : operating register

        !MOV EAX, [p.p_String]  ; *String to EAX
        !.Loop:
          !MOV EDX, DWORD[EAX]  ; 2 chars to EDX
          !MOV ECX, EDX         ; Backup the 2 chars in ECX
          !BSWAP EDX            ; do a ByteSwap
          !ROR EDX, 16          ; swap the 2 Chars because ByteSwap swaped the 2 Chars
          
          !AND ECX, FFFFh       ; Test if 1st Char = 0, EndOfString
          !JZ .Return           ; End If NullChar
          
          !MOV DWORD[EAX], EDX  ; save the Chars with changed ByteOrder
          ; because we operate 2 Chars simultan, we have to check the 2nd Char for EndOfString
          !AND EDX, 0FFFF0000h  ; Test the 2nd Char = 0
          !JZ .Return           ; End If NullChar
          !ADD EAX, 4           ; *String + 4
        !JMP .Loop          ; Repeat Loop  
        !EMMS             ; Empty MMX Technology State, enables FPU Register use
        
        !.Return:   
        !MOV EAX, [p.p_String]  ; Return *String
        ProcedureReturn
      CompilerEndIf
      
    CompilerElse
      ; SingleChar Version
      Protected *pC.pChar = *String 
      While *pC\c[0] 
        Swap *pC\a[0], *pC\a[1]
        *pC + 2   ; do not use SizeOf(Character) otherwise you can't use function in older Ascii String Versions of PB
      Wend
      ProcedureReturn *String
     
    CompilerEndIf
    
  EndProcedure
   
  Procedure.i LCase255(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: LCase255
  ; DESC: Attention: Do not use if you want to LCase Uncicode Chars>255
  ; DESC: A very fast LCase function for Characters up to Chr(255) 
  ; DESC: It's not complete compatible with PB's LCase(), because
  ; DESC: LCase() supports full unicode Charset. This needs time!
  ; DESC:
  ; DESC: LCase255() is optimated for x64 AsmBackend with MMX Code.  
  ; DESC: It works direct in memory and do not copy the String.
  ; DESC: In C-Backend or x32 it works with a PB Pointerbased code!
  ; DESC: This Pointercode needs 3x time of MMX and half of LCase()
  ; VAR(*String): Pointer to String
  ; RET.i : Len(String)
  ; ============================================================================
    
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_64Bit And #PB_Compiler_Unicode
      ; On Ryzen 5800 the MMX version is 7x faster than PB's LCase()
      Protected MMX.TStack_32Byte   ; for MMX Register Backup
      
      ; PSUBUSW Subtract Packed Unsigned Integers with Unsigned Saturation
      ; PADDUSW Add Packed Unsigned Integers with Unsigned Saturation
  
      ; used Registers
      ; RAX : *String
      ; RDX : temporary Regiter
      ; RCX : Bool EndOfString found
      ; R8  : Backup for MM4
      ; MM0 : Mask for Chars <='Z'
      ; MM1 : MASK for Chars >='A'
      ; MM2 : Mask for lo saturation with 4x'Z' 'ZZZZ'
      ; MM3 : Mask for hi saturation with 4x FFFFh-'A'
      ; MM4 : Backup Register for the 4 Chars
      ; MM5 : [lc_00] = 0
      ; MM6 : [lc_sat]
      ; MM7 : [lc_of]
         
      ; load *String
      !MOV RAX, [p.p_String]
      !TEST RAX, RAX
      !JZ .Return   ; If RAX = 0
      !SUB RAX, 8
      
      ; Save MM4..MM7 beause PB allow only MM0..MM3 for free use! MMX Registers are: MM0..MM7
      !LEA RDX, [p.v_MMX]     ; Load effective address of MMX = @MMX
      !MOVQ [RDX], MM4
      !MOVQ [RDX+8], MM5
      !MOVQ [RDX+16], MM6
      !MOVQ [RDX+24], MM7
  
      !XOR RCX, RCX             ; Bool for NullCharFound
      !PXOR MM5,MM5             ; [lc_00]  Mask 00h
      !MOVQ MM6, [lc_sat]       ; [lc_sat] Mask FFFF.FFFF.FFFF.FFFFh
      !MOVQ MM7, [lc_of]        ; [lc_of]  Mask 0020.0020.0020.0020
      
      !.Loop:
        !ADD RAX, 8             ; *String +8 
        !MOVQ MM4, [RAX]        ; load 4 Chars to Backup Register
        !MOVQ MM0, [RAX]        ; MM0 = 4 Chars
        !PCMPEQW MM0, MM5       ; [lc_00]  Compare with 0
        !MOVQ RDX, MM0          ; RDX CompareResult
        !TEST RDX, RDX          ; If 0 : No NullChar found
        !JZ @f
          !INC RCX              ; RCX = 1 => EndOfString found
        !@@:
          
        ; ----------------------------------------------------------------------
        ;  1st standard Chars 'A'..'Z'
        ; ----------------------------------------------------------------------
        
        ; Chars to operating Registers
        !MOVQ MM0, MM4          ; MM0 = 4 Chars
        !MOVQ MM1, MM4          ; MM1 = 4 Chars
        
        ; lo saturation Ascii Chars
        !PSUBUSW MM0, [lc_lo]   ; Sub 90 from all Char => Each Char <='Z' is now 0         
        !PCMPEQW MM0, MM5       ; [lc_00] Compare with 0 we get a FFFF Mask for each word which is 0 in MM0
        
        ; hi saturation Ascii Chars
        !PADDUSW MM1, [lc_hi]   ; Add 65470 (FFBE) to each Char => we get FFFF for Each Char >='A' 
        !PCMPEQW MM1, MM6       ; [lc_sat] With a compare with 65535 we get FFFF Mask for each word which is 65535, $FFFF 
        
        ; combine the Masks and Add 32 to each selected Char
        !PAND MM1, MM0          ; combine both Masks Chars <='Z' and Chars >='A'      
        !MOVQ RDX, MM1          ; combined Mask to RDX
        !TEST RDX, RDX          ; Check for 0  
        !JZ @f                  ; If Mask = 0 => No char to Lcase
          !PAND MM1, MM7        ; [lc_of] Now filter all postions for adding 32 to lowercase the Char
          !MOVQ MM0, MM4
          !PADDW MM0, MM1       ; Add 32 to each filtered Char
          !MOVQ MM4, MM0        ; save the new Chars in MM4
        !@@:
          
        ; ----------------------------------------------------------------------
        ;  2nd special Chars 'À'..Chr(222)
        ; ----------------------------------------------------------------------
        
        ; Chars to operating Registers
        !MOVQ MM0, MM4          ; MM0 = 4 Chars
        !MOVQ MM1, MM4          ; MM1 = 4 Chars 
        
        ; lo saturation special Chars
        !PSUBUSW MM0, [lc_slo]  ; Sub 222 from all Char => Each Char <=Chr(222) is now 0         
        !PCMPEQW MM0, MM5       ; [lc_00] Compare with 0 we get a FFFF Mask for each word which is 0 in MM0
  
        ; hi saturation special Chars
        !PADDUSW MM1, [lc_shi]  ; Add 65470 (FFBE) to each Char => we get FFFF for Each Char>='À' Chr(192) 
        !PCMPEQW MM1, MM6       ; [lc_sat] With a compare with 65535 we get FFFF Mask for each word which is 65535, $FFFF 
        
        ; combine the Masks and Add 32 to each selected Char
        !PAND MM1, MM0          ; combine both Masks Chars <=Chr(222) and Chars >='à' Chr(192)   
        !MOVQ RDX, MM1          ; combined Mask to RDX
        !TEST RDX, RDX          ; Check for 0  
        !JZ @f                  ; If Mask = 0 => No char to Lcase
          !PAND MM1, MM7        ; [lc_of] Now filter all postions for adding 32 to lowercase the Char
          !MOVQ MM0, MM4
          !PADDW MM0, MM1       ; Add 32 to each filtered Char
          !MOVQ MM4, MM0
        !@@:
        
        ; ----------------------------------------------------------------------
        ;  save the modified Chars back to memory
        ; ----------------------------------------------------------------------
        !MOVQ [RAX], MM4        ; save back to memory
        !TEST RCX, RCX          ; RCX<>0 => NullChar was found
      !JZ .Loop                 ;  If RCX=0 Then Repeat Loop
      
      ; Return  Len(String)
      !PCMPEQW MM4, MM5         ; Compare the 4 Chars with 0 to search EndOfString
      !MOVQ RDX, MM4            ; Compare Result Mask -> RDX, contains now FFFFh for each Word which was 0 
      !BSF RDX, RDX             ; BitSanForward => No of LSB
      !SHR RDX, 3               ; BitNo to ByteNo => Offset_Of_NullChar
      !ADD RAX, RDX             ; Actual StringPointer + OffsetOf_NullChar
      !SUB RAX, [p.p_String]    ; RAX *EndOfString - *String
      !SHR RAX, 1               ; NoOfBytes to NoOfWord => Len(String)
     
      ; Restore MM4..MM7
      !LEA RDX, [p.v_MMX]
      !MOVQ MM4, [RDX]
      !MOVQ MM5, [RDX+8]
      !MOVQ MM6, [RDX+16]
      !MOVQ MM7, [RDX+24]
      
     !EMMS             ; Empty MMX Technology State, enables FPU Register use
     !.Return:
      ProcedureReturn  ; RAX = Len(String)
      
      DataSection
        ; Attention: FASM needs a leading 0 for hex values
        ; !lc_00:  dq 00h                  ; not needed because we use MM5=0
        !lc_lo:  dq 0005A005A005A005Ah    ; 'Z' = 90 = 5A     Mask to filter Chars <=Z
        !lc_hi:  dq 0FFBEFFBEFFBEFFBEh    ; FFFFh-65 ; 'A'=65 Mask to tilter Chars >=A
        !lc_of:  dq 00020002000200020h    ; 'a'-'A' = 61h-41h Mask for Sub 32 from each Char => LCase the Char
        !lc_sat: dq 0FFFFFFFFFFFFFFFFh    ; Mask with saturated Character value, it's the max 16Bit value unsigned
        !lc_slo: dq 000DE00DE00DE00DEh    ; Chr(222) = DEh
        !lc_shi: dq 0FF3FFF3FFF3FFF3Fh    ; FFFFh-192 = FF3F = 65343
      EndDataSection
      
    CompilerElse   ; C-Backend or x32  OR Ascii
      
      ; On Ryzen 5800 the PB Pointer version is ~2x faster than PB's LCase() 
      Protected *pRead.Character = *String
    
      While *pRead\c
        If *pRead\c >='A' And *pRead\c <='Z'
          *pRead\c + 32  
        EndIf  
        If *pRead\c >=192 And *pRead\c <=222    ; special Chars À..
          *pRead\c + 32  
        EndIf  
        *pRead + SizeOf(Character)
      Wend  
      ProcedureReturn (*pRead - *String)/SizeOf(Character)    ; Return Len(String)
      
    CompilerEndIf
    
  EndProcedure
  
  Procedure.i UCase255(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: UCase255
  ; DESC: Attention: Do not use if you want to UCase Uncicode Chars>255
  ; DESC: A very fast UCase function for Characters up to Chr(255) 
  ; DESC: It's not a complete compatible with PB's UCase(), because
  ; DESC: UCase() supports full unicode Charset. This needs time!
  ; DESC: 
  ; DESC: UCase255() is optimated for x64 AsmBackend with MMX Code.  
  ; DESC: It works direct in memory and do not copy the String.
  ; DESC: In C-Backend or x32 it works with a PB Pointerbased code!
  ; DESC: This Pointercode needs 3x time of MMX and half of Ucase()
  ; VAR(*String): Pointer to String
  ; RET.i : Len(String)
  ; ============================================================================
    
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_64Bit And #PB_Compiler_Unicode
      ; On Ryzen 5800 the MMX version is 7x faster than PB's UCase()
    
      Protected MMX.TStack_32Byte   ; for MMX Register Backup
      
      ; PSUBUSW Subtract Packed Unsigned Integers with Unsigned Saturation
      ; PADDUSW Add Packed Unsigned Integers with Unsigned Saturation
  
      ; used Registers
      ; RAX : *String
      ; RDX : temporary Regiter
      ; RCX : Bool EndOfString found
      ; R8  : Backup for MM4
      ; MM0 : Mask for Chars <='z'
      ; MM1 : MASK for Chars >='a'
      ; MM2 : Mask for lo saturation with 4x'z' 'zzz'
      ; MM3 : Mask for hi saturation with 4x FFFFh-'a'
      ; MM4 : Backup Register for the 4 Chars
      ; MM5 : [lu_00] = 0
      ; MM6 : [lu_sat]
      ; MM7 : [lu_of]
     
      ; load *String
      !MOV RAX, [p.p_String]
      !TEST RAX, RAX
      !JZ .Return
      !SUB RAX, 8
      
      ; Save MM4..MM7 beause PB allow only MM0..MM3 for free use! MMX Registers are: MM0..MM7
      !LEA RDX, [p.v_MMX]     ; Load effective address of MMX = @MMX
      !MOVQ [RDX], MM4
      !MOVQ [RDX+8], MM5
      !MOVQ [RDX+16], MM6
      !MOVQ [RDX+24], MM7
      
      !XOR RCX, RCX             ; Bool for NullCharFound
      !PXOR MM5,MM5             ; [lu_00]  Mask 00h
      !MOVQ MM6, [lu_sat]       ; [lu_sat] Mask FFFF.FFFF.FFFF.FFFFh
      !MOVQ MM7, [lu_of]        ; [lu_of]  Mask 0020.0020.0020.0020
      
      !.Loop:
        !ADD RAX, 8             ; *String +8 
        !MOVQ MM4, [RAX]        ; load 4 Chars to Backup Register
        !MOVQ MM0, [RAX]        ; MM0 = 4 Chars
        !PCMPEQW MM0, MM5       ; [lu_00]  Compare with 0
        !MOVQ RDX, MM0          ; RDX CompareResult
        !TEST RDX, RDX          ; If 0 : No NullChar found
        !JZ @f
          !INC RCX              ; RCX = 1 => EndOfString found
        !@@:
          
        ; ----------------------------------------------------------------------
        ;  1st standard Chars 'a'..'z'
        ; ----------------------------------------------------------------------
        
        ; Chars to operating Registers
        !MOVQ MM0, MM4          ; MM0 = 4 Chars
        !MOVQ MM1, MM4          ; MM1 = 4 Chars
        
        ; lo saturation Ascii Chars
        !PSUBUSW MM0, [lu_lo]   ; Sub 90 from all Char => Each Char <='Z' is now 0         
        !PCMPEQW MM0, MM5       ; [lu_00] Compare with 0 we get a FFFF Mask for each word which is 0 in MM0
        
        ; hi saturation Ascii Chars FFFFh-254
        !PADDUSW MM1, [lu_hi]   ; Add 65470 (FFBE) to each Char => we get FFFF for Each Char >='A' 
        !PCMPEQW MM1, MM6       ; [lu_sat] With a compare with 65535 we get FFFF Mask for each word which is 65535, $FFFF 
        
        ; combine the Masks and Sub 32 from each selected Char
        !PAND MM1, MM0          ; combine both Masks Chars <='Z' and Chars >='A'      
        !MOVQ RDX, MM1          ; combined Mask to RDX
        !TEST RDX, RDX          ; Check for 0  
        !JZ @f                  ; If Mask = 0 => No char to Lcase
          !PAND MM1, MM7        ; [lu_of] Now filter all postions for adding 32 to lowercase the Char
          !MOVQ MM0, MM4
          !PSUBW MM0, MM1       ; Sub 32 from each filtered Char
          !MOVQ MM4, MM0        ; save the new Chars in MM4
        !@@:
        
        ; ----------------------------------------------------------------------
        ;  2nd special Chars 'à'..Chr(254)
        ; ----------------------------------------------------------------------
        
        ; Chars to operating Registers
        !MOVQ MM0, MM4          ; MM0 = 4 Chars
        !MOVQ MM1, MM4          ; MM1 = 4 Chars 
        
        ; lo saturation special Chars
        !PSUBUSW MM0, [lu_slo]  ; Sub 254 from all Char => Each Char <=Chr(254) is now 0         
        !PCMPEQW MM0, MM5       ; [lu_00] Compare with 0 we get a FFFF Mask for each word which is 0 in MM0
  
        ; hi saturation special Chars
        !PADDUSW MM1, [lu_shi]  ; Add 65313 (FF21h) to each Char => we get FFFF for Each Char>='à' 
        !PCMPEQW MM1, MM6       ; [lu_sat] With a compare with 65535 we get FFFF Mask for each word which is 65535, $FFFF 
        
        ; combine the Masks and Sub 32 from each selected Char
        !PAND MM1, MM0          ; combine both Masks Chars <=Chr(254) and Chars >='à' Chr(224)   
        !MOVQ RDX, MM1          ; combined Mask to RDX
        !TEST RDX, RDX          ; Check for 0  
        !JZ @f                  ; If Mask = 0 => No char to Lcase
          !PAND MM1, MM7        ; [lu_of] Now filter all postions for adding 32 to lowercase the Char
          !MOVQ MM0, MM4
          !PSUBW MM0, MM1       ; Sub 32 from each filtered Char
          !MOVQ MM4, MM0
        !@@:
        
        ; ----------------------------------------------------------------------
        ;  save the modified Chars back to memory
        ; ----------------------------------------------------------------------
        !MOVQ [RAX], MM4        ; save back to memory
        !TEST RCX, RCX          ; RCX<>0 => NullChar was found
      !JZ .Loop                 ;  If RCX=0 Then Repeat Loop
       
      ; Return  Len(String)
      !PCMPEQW MM4, MM5         ; Compare the 4 Chars with 0 to search EndOfString
      !MOVQ RDX, MM4            ; Compare Result Mask -> RDX, contains now FFFFh for each Word which was 0
      !BSF RDX, RDX             ; BitSanForward => No of LSB
      !SHR RDX, 3               ; BitNo to ByteNo => Offset_Of_NullChar
      !ADD RAX, RDX             ; Actual StringPointer + OffsetOf_NullChar
      !SUB RAX, [p.p_String]    ; RAX *EndOfString - *String
      !SHR RAX, 1               ; NoOfBytes to NoOfWord => Len(String)
     
      ; Restore MM4..MM7
      !LEA RDX, [p.v_MMX]
      !MOVQ MM4, [RDX]
      !MOVQ MM5, [RDX+8]
      !MOVQ MM6, [RDX+16]
      !MOVQ MM7, [RDX+24]
      
      !EMMS             ; Empty MMX Technology State, enables FPU Register use
      !.Return:
      ProcedureReturn  ; RAX = Len(String)
      
      DataSection
        ; Attention: FASM nees a leading 0 for hex values
        ; !lu_00:  dq 00h                  ; not needed because we use MM5=0
        !lu_lo:  dq 0007A007A007A007Ah    ; 'z' = 122 = 7A     Mask to filter Chars <=z
        !lu_hi:  dq 0FF9EFF9EFF9EFF9Eh    ; FFFFh-97 ; 'a'=97 Mask to tilter Chars >=a
        !lu_of:  dq 00020002000200020h    ; 'a'-'A' = 61h-41h Mask for Add 32 to each Char => UCase the Char
        !lu_sat: dq 0FFFFFFFFFFFFFFFFh    ; Mask with saturated Character value, it's the max 16Bit value unsigned
        !lu_slo: dq 000FE00FE00FE00FEh    ; Chr(254)= FEh 
        !lu_shi: dq 0FF21FF21FF21FF21h    ; FFFFh-222 = FF21h = 65313
      EndDataSection
   
    CompilerElse  ; C-Backend OR x32 OR Ascii
      
      ; On Ryzen 5800 the PB Pointer version is ~2x faster than PB's UCase() 
      Protected *pRead.Character = *String
    
      While *pRead\c
        If *pRead\c >='a' And *pRead\c <='z'
          *pRead\c - 32  
        EndIf  
        
        If *pRead\c >=224 And *pRead\c <=254    ; special Chars à..
          *pRead\c - 32  
        EndIf  
        
        *pRead + SizeOf(Character)
      Wend
      ProcedureReturn (*pRead - *String)/SizeOf(Character)    ; Return Len(String)
      
    CompilerEndIf
    
  EndProcedure

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

EndModule

; ================================================================================


CompilerIf #False
  ;- --------------------------------------------------
  ;- RemoveCharFast()
  ;- --------------------------------------------------
  
  ; **************************************************
  ; x64 Assembler Version with XMM-Registers
  ; ************************************************** 
  
  ; **************************************************
  ; x32 Assembler Version with MMX-Registers
  ; **************************************************
  
  ; **************************************************
  ; x32 Assembler Version Classic 
  ; **************************************************
  
  ; **************************************************
  ; Purebasic Version with *Pointer-Code
  ; **************************************************
  
  ; **************************************************
  ; Purebasic Version using PB PB integrated functions
  ; **************************************************

  Procedure Template(*String, cSearch.c, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: Template
  ; DESC: 
  ; DESC: 
  ; DESC: 
  ; VAR(*String) : Pointer to the String
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : 
  ; ============================================================================
 
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm) And #PB_Compiler_Unicode
      
      CompilerIf #PB_Compiler_64Bit
      ; ************************************************************
      ; x64 Assembler
      ; ************************************************************
        
      CompilerElse ; #PB_Compiler_32Bit
      ; ************************************************************
      ; x32 Assembler
      ; ************************************************************
        
      CompilerEndIf 
       
    CompilerElseIf (#PB_Compiler_Backend = #PB_Backend_C) And #PB_Compiler_Unicode
       
      CompilerIf #PB_Compiler_64Bit
      ; ************************************************************
      ; x64 C
      ; ************************************************************
        
      CompilerElse #PB_Compiler_32Bit
      ; ************************************************************
      ; x32 C
      ; ************************************************************
        
      CompilerEndIf
      
    CompilerElse ; Ascii
    ; ************************************************************
    ; Ascii Strings < PB 5.5
    ; ************************************************************
       
    CompilerEndIf 
      
  EndProcedure
  
CompilerEndIf


; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 1572
; Folding = ---------
; Markers = 680
; Optimizer
; CPU = 5