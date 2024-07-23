; ===========================================================================
;  FILE : PbFw_Module_Bits.pbi
;  NAME: Extended Bit Operation Functions Bits::
;  DESC: Implements Bit-Operation-Functions which are not part of 
;  DESC: the standard PureBasic dialect
;  DESC: Such functions are needed for industrial Software, when 
;  DESC: dealing with data from PLC-Controlers like Simens S7 or others
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2021/04/02
; VERSION  :  0.5  Developer Version
; COMPILER :  PureBasic 5.73
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{
; 2023/03/19  Added C-Backend optimations according to
;             https://www.purebasic.fr/english/viewtopic.php?t=77563
; 2023/03/12: Added GrayCode Encoder and Decoder
; 2022/12/04: Wrapped all in a Modulue and added it to Purebasic Framework
; 2021/04/02: Moved the BitFunctions from other libraries to their own library 
;             Added BitRotation functions  
; }            
; ============================================================================

; Some important Assembler Instructions
; BSF : Bit Scan Forward
; BSR : Bit Scan Reverse
; BT  : Bit Test
; BTC : Bit Test and Complement
; BTS : Bit Test and Set
; BTR : Bit Test and Reset
; BSWAP : Byte Swap
; POPCNT : Return the Count of Number of Bits Set to 1

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"       ; DBG::      Debug Module

; XIncludeFile ""

DeclareModule Bits
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  Structure Int128 
    l.q
    h.q
  EndStructure   
  
  Declare.i GrayEncode(N.i)
  Declare.i GrayDecode(G.i)
    
  ; DECLARE Functions
  Declare.i BitCount16 (value.u)  
  Declare.i BitCount32 (value.l)
  Declare.i BitCount64 (value.q)
  
  Declare.u BSWAP16(Value.u)
  Declare.l BSWAP32(Value.l)
  Declare.q BSWAP64(Value.q)
  Declare.i BSWAP128(*Value.Int128, *Out.Int128 = 0)  

  
  Declare BSWAP_Mem16(*Mem)
  Declare BSWAP_Mem32(*Mem)
  Declare BSWAP_Mem64(*Mem)
  
  Declare.l ROL32(value.l, cnt.i = 1)
  Declare.l ROR32(value.l, cnt.i = 1)
  Declare.q ROL64(value.q, cnt.i = 1)
  Declare.q ROR64(value.q, cnt.i = 1)  
  
EndDeclareModule


Module Bits
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Enumeration
    #PbFw_BIT_Classic                   ; use Classic PB Code
    #PbFw_BIT_ASMx32                    ; x32 Bit Assembler
    #PbFw_BIT_ASMx64                    ; x64 Bit Assembler
    #PbFw_BIT_C_Backend                 ; use optimations for C-Backend
  EndEnumeration
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
    
    ; **********  32 BIT  **********
    CompilerIf #PB_Compiler_32Bit
      #PbFw_BIT_UseCode = #PbFw_BIT_ASMx32
      
    ; **********  64 BIT  **********
    CompilerElseIf #PB_Compiler_64Bit
      #PbFw_BIT_UseCode = #PbFw_BIT_ASMx64
      
    ; **********  Classic Code  **********
    CompilerElse
      #PbFw_BIT_UseCode = #PbFw_BIT_Classic
      
    CompilerEndIf
      
  CompilerElseIf    #PB_Compiler_Backend = #PB_Backend_C
    #PbFw_BIT_UseCode = #PbFw_BIT_C_Backend
      
  CompilerElse
    #PbFw_BIT_UseCode = #PbFw_BIT_Classic
      
  CompilerEndIf 
    
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  Structure pSwap ; Pointer Structure for swapping
    a.a[0]    ; unsigned Byte-Value
    u.u[0]    ; unsigned WORD-Value
  EndStructure
  
  ; BitCount Macros for PB-Classic
  ; According to AMD Code Oprimation Guide
  ; unrolling Loops is much faster, because of
  ; better code forecast!

  Macro mac_BitCount16(val)
    Protected cnt.i            
    If (val & 1)    : cnt +1 : EndIf
    If (val & 1<<1) : cnt +1 : EndIf
    If (val & 1<<2) : cnt +1 : EndIf
    If (val & 1<<3) : cnt +1 : EndIf
    If (val & 1<<4) : cnt +1 : EndIf
    If (val & 1<<5) : cnt +1 : EndIf
    If (val & 1<<6) : cnt +1 : EndIf
    If (val & 1<<7) : cnt +1 : EndIf
    If (val & 1<<8) : cnt +1 : EndIf
    If (val & 1<<9) : cnt +1 : EndIf
    If (val & 1<<10) : cnt +1 : EndIf
    If (val & 1<<11) : cnt +1 : EndIf
    If (val & 1<<12) : cnt +1 : EndIf
    If (val & 1<<13) : cnt +1 : EndIf
    If (val & 1<<14) : cnt +1 : EndIf
    If (val & 1<<15) : cnt +1 : EndIf 
    ProcedureReturn cnt
  EndMacro
  
  Macro mac_BitCount32(val)
    Protected cnt.i   
    ; according to AMD Code Oprimation Guide
    ; unrolling Loops is much faster
    If (val & 1)    : cnt +1 : EndIf
    If (val & 1<<1) : cnt +1 : EndIf
    If (val & 1<<2) : cnt +1 : EndIf
    If (val & 1<<3) : cnt +1 : EndIf
    If (val & 1<<4) : cnt +1 : EndIf
    If (val & 1<<5) : cnt +1 : EndIf
    If (val & 1<<6) : cnt +1 : EndIf
    If (val & 1<<7) : cnt +1 : EndIf
    If (val & 1<<8) : cnt +1 : EndIf
    If (val & 1<<9) : cnt +1 : EndIf
    If (val & 1<<10) : cnt +1 : EndIf
    If (val & 1<<11) : cnt +1 : EndIf
    If (val & 1<<12) : cnt +1 : EndIf
    If (val & 1<<13) : cnt +1 : EndIf
    If (val & 1<<14) : cnt +1 : EndIf
    If (val & 1<<15) : cnt +1 : EndIf 
    
    If (val & 1<<16) : cnt +1 : EndIf
    If (val & 1<<17) : cnt +1 : EndIf
    If (val & 1<<18) : cnt +1 : EndIf
    If (val & 1<<19) : cnt +1 : EndIf
    If (val & 1<<20) : cnt +1 : EndIf
    If (val & 1<<21) : cnt +1 : EndIf
    If (val & 1<<22) : cnt +1 : EndIf
    If (val & 1<<23) : cnt +1 : EndIf
    If (val & 1<<24) : cnt +1 : EndIf
    If (val & 1<<25) : cnt +1 : EndIf
    If (val & 1<<26) : cnt +1 : EndIf
    If (val & 1<<27) : cnt +1 : EndIf
    If (val & 1<<28) : cnt +1 : EndIf
    If (val & 1<<29) : cnt +1 : EndIf
    If (val & 1<<30) : cnt +1 : EndIf
    If (val & 1<<31) : cnt +1 : EndIf
    ProcedureReturn cnt
  EndMacro
  
  Macro mac_BitCount64(val)
    Protected cnt.i   
    If (val & 1)    : cnt +1 : EndIf
    If (val & 1<<1) : cnt +1 : EndIf
    If (val & 1<<2) : cnt +1 : EndIf
    If (val & 1<<3) : cnt +1 : EndIf
    If (val & 1<<4) : cnt +1 : EndIf
    If (val & 1<<5) : cnt +1 : EndIf
    If (val & 1<<6) : cnt +1 : EndIf
    If (val & 1<<7) : cnt +1 : EndIf
    If (val & 1<<8) : cnt +1 : EndIf
    If (val & 1<<9) : cnt +1 : EndIf
    If (val & 1<<10) : cnt +1 : EndIf
    If (val & 1<<11) : cnt +1 : EndIf
    If (val & 1<<12) : cnt +1 : EndIf
    If (val & 1<<13) : cnt +1 : EndIf
    If (val & 1<<14) : cnt +1 : EndIf
    If (val & 1<<15) : cnt +1 : EndIf 
    
    If (val & 1<<16) : cnt +1 : EndIf
    If (val & 1<<17) : cnt +1 : EndIf
    If (val & 1<<18) : cnt +1 : EndIf
    If (val & 1<<19) : cnt +1 : EndIf
    If (val & 1<<20) : cnt +1 : EndIf
    If (val & 1<<21) : cnt +1 : EndIf
    If (val & 1<<22) : cnt +1 : EndIf
    If (val & 1<<23) : cnt +1 : EndIf
    If (val & 1<<24) : cnt +1 : EndIf
    If (val & 1<<25) : cnt +1 : EndIf
    If (val & 1<<26) : cnt +1 : EndIf
    If (val & 1<<27) : cnt +1 : EndIf
    If (val & 1<<28) : cnt +1 : EndIf
    If (val & 1<<29) : cnt +1 : EndIf
    If (val & 1<<30) : cnt +1 : EndIf
    If (val & 1<<31) : cnt +1 : EndIf
    
    If (val & 1<<32) : cnt +1 : EndIf
    If (val & 1<<33) : cnt +1 : EndIf
    If (val & 1<<34) : cnt +1 : EndIf
    If (val & 1<<35) : cnt +1 : EndIf
    If (val & 1<<36) : cnt +1 : EndIf
    If (val & 1<<37) : cnt +1 : EndIf
    If (val & 1<<38) : cnt +1 : EndIf
    If (val & 1<<39) : cnt +1 : EndIf
    If (val & 1<<40) : cnt +1 : EndIf
    If (val & 1<<41) : cnt +1 : EndIf
    If (val & 1<<42) : cnt +1 : EndIf
    If (val & 1<<43) : cnt +1 : EndIf
    If (val & 1<<44) : cnt +1 : EndIf
    If (val & 1<<45) : cnt +1 : EndIf
    If (val & 1<<46) : cnt +1 : EndIf
    If (val & 1<<47) : cnt +1 : EndIf
    
    If (val & 1<<48) : cnt +1 : EndIf
    If (val & 1<<49) : cnt +1 : EndIf
    If (val & 1<<50) : cnt +1 : EndIf
    If (val & 1<<51) : cnt +1 : EndIf
    If (val & 1<<52) : cnt +1 : EndIf
    If (val & 1<<53) : cnt +1 : EndIf
    If (val & 1<<54) : cnt +1 : EndIf
    If (val & 1<<55) : cnt +1 : EndIf
    If (val & 1<<56) : cnt +1 : EndIf
    If (val & 1<<57) : cnt +1 : EndIf
    If (val & 1<<58) : cnt +1 : EndIf
    If (val & 1<<59) : cnt +1 : EndIf
    If (val & 1<<60) : cnt +1 : EndIf
    If (val & 1<<61) : cnt +1 : EndIf
    If (val & 1<<62) : cnt +1 : EndIf
    If (val & 1<<63) : cnt +1 : EndIf
    ProcedureReturn cnt
  EndMacro
  
  ; Brainstorming: Code fragments from PB Forum
  Procedure.i _Popcount64(x.i)
    x = x - (x >> 1) &  $5555555555555555           
    x = (x & $3333333333333333) + ((x >> 2) & $3333333333333333)
    x = (x + (x >> 4)) & $0F0F0F0F0F0F0F0F
    x= x * $0101010101010101
    x >> 56
    ProcedureReturn x   
  EndProcedure 
  
  Procedure _PopCount128_Addr(*Int128)
    ; move [*Int128] to registers
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      !popcnt rax, rcx      ; x64 Windows
      !popcnt r8 , rdx
    CompilerElse
      !popcnt rax, rdi      ; x64 macOS and Linux
      !popcnt r8 , rsi
    CompilerEndIf
    !add rax, r8
    ProcedureReturn
  EndProcedure
  
  ; other versions for Bitcount!
  ; should be tested
  Procedure _BitCount32(value.q)
    ; Count the number of set bits (1s) in a 32-bit unsigned integer using Kernighan's algorithm
    Protected.i count
    
    value & $FFFFFFFF
    
    While value
      count +1
      value & (value - 1)
    Wend
    
    ProcedureReturn count
  EndProcedure
  
  Procedure _BitCount64_(value.q)
    ; Count the number of set bits (1s) in a 32-bit unsigned integer using Kernighan's algorithm
    Protected.i count
     
      While value
        count +1
        value & (value - 1)
      Wend
    
    ProcedureReturn count
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.i GrayEncode(N.i)
  ; ======================================================================
  ;  NAME: GrayEncode
  ;  DESC: Enocode Gray: converts binary coded Values to CrayCode
  ;  DESC: In GrayCode only 1 Bit changes from value to value +/- 1
  ;  DESC: Gray Code is very common in industrial sensors (Positon Encoders)
  ;  VAR(N.i): The number to Encode in Gray
  ;  RET.i:  Gray encoded value of N
  ; ====================================================================== 
    
  ; TODO! Maybe wrong because of PB's atithmetic Shift    
    ProcedureReturn N ! (N >> 1) ; N XOR ShiftRight(N,1)
  EndProcedure
  
  Procedure.i GrayDecode(G.i)
  ; ======================================================================
  ;  NAME: GrayDecode
  ;  DESC: Decode Gray encoded value
  ;  DESC: In GrayCode only 1 Bit change from value to value +/- 1
  ;  VAR(G.i): The Gray encoded value
  ;  RET.i:  the decoded Integer value
  ; ======================================================================   
    Protected.i Mask = G 
    ; https://de.wikipedia.org/wiki/Gray-Code
    
   ; TODO! Maybe wrong because of PB's atithmetic Shift      
    While Mask > 0
      Mask >> 1   ;  ShiftRight(Mask, 1)
      G ! Mask    ;  G XOR Mask
    Wend
    ProcedureReturn G
  EndProcedure

  Procedure.i BitCount16 (value.u)
  ; ======================================================================
  ;  NAME: BitCount16
  ;  DESC: Counts the number of Hi bits in a 16 Bit Value
  ;  RET.i:  Number of Hi Bits
  ; ====================================================================== 
    
    CompilerSelect #PbFw_BIT_UseCode
       ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on! 
      CompilerCase #PbFw_BIT_ASMx32
        !xor    eax, eax
        !mov    ax, word [p.v_value]
        !popcnt ax, ax
        ProcedureReturn
     
      CompilerCase #PbFw_BIT_ASMx64
        !xor    rax, rax
        !mov    ax, word [p.v_value]
        !popcnt ax, ax
        ProcedureReturn       
        
      CompilerCase #PbFw_BIT_C_Backend
        mac_BitCount16(value)
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
        mac_BitCount16(value)
        
    CompilerEndSelect
     
  EndProcedure
  
  Procedure.i BitCount32 (value.l)
  ; ======================================================================
  ;  NAME: BitCount32
  ;  DESC: Counts the number of Hi bits in a 32 Bit Value
  ;  RET.i: Number of Hi Bits 
  ; ====================================================================== 
         
    CompilerSelect #PbFw_BIT_UseCode
      ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on!         
      CompilerCase #PbFw_BIT_ASMx32
        !mov    eax, dword [p.v_value]
        !popcnt eax, eax
       ProcedureReturn
       
      CompilerCase #PbFw_BIT_ASMx64
        !xor    rax, rax
        !mov    eax, dword [p.v_value]
        !popcnt eax, eax
       ProcedureReturn
           
      CompilerCase #PbFw_BIT_C_Backend
        mac_BitCount32(value)
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
        mac_BitCount32(value)
        
    CompilerEndSelect

  EndProcedure
  
  Procedure.i BitCount64 (value.q)
  ; ======================================================================
  ;  NAME: BitCount64
  ;  DESC: Counts the number of Hi bits in a 64 Bit Value
  ;  RET.i: Number of Hi Bits
  ; ======================================================================     
    
    CompilerSelect #PbFw_BIT_UseCode
       ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on!   
      CompilerCase #PbFw_BIT_ASMx32  ; at x32 programms we must do 2x32Bit POPCNT and ADD
        !lea ecx, [p.v_value]
        !mov edx, dword [ecx]         ; load hi 32 Bits to EDX-Register
        !mov eax, dword [ecx +4]      ; load lo 32 Bits to EAX-Register
        !popcnt edx, edx              ; count Hi-Bits in EDX
        !popcnt eax, eax              ; count Hi-Bits in EAX
        !add eax, edx                 ; Add the 2 values
        ProcedureReturn
        
      CompilerCase #PbFw_BIT_ASMx64
        !mov rax, qword [p.v_value]
        !popcnt rax, rax
        ProcedureReturn
               
      CompilerCase #PbFw_BIT_C_Backend
        mac_BitCount64(value)
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
        mac_BitCount64(value)
        
    CompilerEndSelect

  EndProcedure
  

  Procedure.u BSWAP16(Value.u)
  ; ======================================================================
  ;  NAME: BSWAP16
  ;  DESC: LittleEndian<=>BigEndian conversion for 16Bit values
  ;  DESC: Swaps the Bytes of a 16 Bit value
  ;  VAR(Value.u): 16-Bit-Word Value
  ;  RET.u: Byte swapped 16-Bit value
  ; ====================================================================== 
    
    CompilerSelect #PbFw_BIT_UseCode
       
    CompilerCase #PbFw_BIT_ASMx32
      !xor eax, eax
      !mov ax, word [p.v_Value]
      !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
      ProcedureReturn
      
    CompilerCase #PbFw_BIT_ASMx64
      !xor rax, rax
      !mov ax, word [p.v_Value]
      !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
      ProcedureReturn
     
    CompilerCase #PbFw_BIT_C_Backend
      !return __builtin_bswap16(v_Value);
      ProcedureReturn
      
    CompilerDefault     ; Classic Code without ASM or C optimations       
      Protected *Swap.pSwap
      *Swap = @Value
      Swap *Swap\a[0], *Swap\a[1]
      ProcedureReturn Value
     
    CompilerEndSelect
       
  EndProcedure
  
  Procedure.l BSWAP32(Value.l)
  ; ======================================================================
  ;  NAME: BSWAP32
  ;  DESC: LittleEndian<=>BigEndian conversion for 32Bit values
  ;  DESC: Swaps the Bytes of a 32 Bit value
  ;  VAR(Value.l): 32-Bit-Long Value
  ;  RET.l:  Byte swapped 32-Bit value
  ; ====================================================================== 
  
    CompilerSelect #PbFw_BIT_UseCode
         
      CompilerCase #PbFw_BIT_ASMx32
        !mov eax, dword [p.v_Value]
        !bswap eax
        ProcedureReturn   
        
      CompilerCase #PbFw_BIT_ASMx64
        !xor rax, rax
        !mov eax, dword [p.v_Value]
        !bswap eax
        ProcedureReturn    
        
      CompilerCase #PbFw_BIT_C_Backend
        !return __builtin_bswap32(v_Value);
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
        Protected *Swap.pSwap
        *Swap = @Value
        Swap *Swap\a[0], *Swap\a[3]
        Swap *Swap\a[1], *Swap\a[2]
        
    CompilerEndSelect
      
  EndProcedure
  
  Procedure.q BSWAP64(Value.q)
  ; ======================================================================
  ;  NAME: BSWAP64
  ;  DESC: LittleEndian<=>BigEndian conversion for 64Bit values
  ;  DESC: Swaps the Bytes of a 64 Bit value
  ;  DESC: direct in memory.
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ======================================================================   
    
    CompilerSelect #PbFw_BIT_UseCode
       
      CompilerCase #PbFw_BIT_ASMx32
        !lea ecx, [p.v_Value]   ; load effective address of Value (:= @Value)
        !mov edx, dword [ecx]
        !mov eax, dword [ecx +4]
        !bswap edx
        !bswap eax
        ProcedureReturn         ; 64Bit Return use EAX and EDX Register
        
      CompilerCase #PbFw_BIT_ASMx64
        !mov rax, qword [p.v_Value]
        !bswap rax
        ProcedureReturn
        
      CompilerCase #PbFw_BIT_C_Backend
        !return __builtin_bswap64(v_value);
       
      CompilerDefault     ; Classic Code without ASM or C optimations       
        Protected *Swap.pSwap
        *Swap = @Value
        Swap *Swap\a[0], *Swap\a[7]
        Swap *Swap\a[1], *Swap\a[6]
        Swap *Swap\a[2], *Swap\a[5]
        Swap *Swap\a[3], *Swap\a[4]
      
    CompilerEndSelect
    
   EndProcedure
   
  Procedure.i BSWAP128(*Value.Int128, *Out.Int128 = 0 )  
  ; ======================================================================
  ;  NAME: BSWAP128
  ;  DESC: LittleEndian<=>BigEndian conversion for 128 Bit values
  ;  DESC: Swaps the Bytes of a 128 Bit value
  ;  DESC: direct in memory or return it in *Out
  ;  DESC: Code from: https://www.purebasic.fr/english/viewtopic.php?t=77563
  ;  VAR(*Value): Pointer to the value
  ;  VAR(*Out): Pointer to the optional RetrurnValue  
  ;             If *Out = 0 Then Swap directly in *Value
  ;             Eles Return swaped value in *Out (don't touch Value)
  ;  RET: *Out
  ; ======================================================================   
    
    DBG::mac_CheckPointer(*Value)    ; Check Pointer Exception
    
    Protected low.q = *Value\l  
    Protected high.q = *Value\h 

    CompilerSelect #PbFw_BIT_UseCode
        
      CompilerCase #PbFw_BIT_ASMx32
        ; ATTENTION That's wrong
        !mov edx, dword [p.v_high]
        !mov eax, dword [p.v_high + 4]
        !bswap edx
        !bswap eax
        !mov [p.v_high], dword eax 
        !mov [p.v_high + 4], dword edx 
        !xor eax,eax 
        !xor edx,edx 
        !mov edx, dword [p.v_low]
        !mov eax, dword [p.v_low + 4]
        !bswap edx
        !bswap eax
        !mov [p.v_low], dword eax 
        !mov [p.v_low + 4], dword edx 
        
      CompilerCase #PbFw_BIT_ASMx64
        !mov rdx,[p.v_high] 
        !mov rax,[p.v_low] 
        !bswap rax 
        !bswap rdx 
        !mov [p.v_low],rax 
        !mov [p.v_high],rdx 
        
      CompilerCase #PbFw_BIT_C_Backend
        !v_high = __builtin_bswap64(v_high) 
        !v_low  = __builtin_bswap64(v_low)
     
      CompilerDefault     ; Classic Code without ASM or C optimations       
        Protected *Swap.pSwap
        *Swap = @low
        Swap *Swap\a[0], *Swap\a[7]
        Swap *Swap\a[1], *Swap\a[6]
        Swap *Swap\a[2], *Swap\a[5]
        Swap *Swap\a[3], *Swap\a[4]
        
        *Swap = @high
        Swap *Swap\a[0], *Swap\a[7]
        Swap *Swap\a[1], *Swap\a[6]
        Swap *Swap\a[2], *Swap\a[5]
        Swap *Swap\a[3], *Swap\a[4]
           
    CompilerEndSelect
    
    If *Out
      *Out\h = low 
      *Out\l = high
    Else
      *Value\h = low 
      *Value\l = high
    EndIf  
    
    ProcedureReturn *Out 
    
  EndProcedure 

  Procedure BSWAP_Mem16(*Mem)
  ; ======================================================================
  ;  NAME: BSWAp_Mem16
  ;  DESC: LittleEndian<=>BigEndian conversion of a 16Bit value
  ;  DESC: direct in memory.
  ;  DESC: Swaps the Bytes of a 16 Bit value
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ====================================================================== 
    
    DBG::mac_CheckPointer(*Mem)    ; Check Pointer Exception

    CompilerSelect #PbFw_BIT_UseCode
         
      CompilerCase #PbFw_BIT_ASMx32
        !mov ecx, [p.p_Mem]       ; load pointer to ECX
        !xor eax, eax
        !mov ax, word [ecx]       ; load value, (content of pointer)
        !xchg al, ah              ; for 16 Bit ByteSwap it's the Exchange command 
        ; !rol ax, 8  ; alternative way with RotateLeft 8Bit
        !mov word [ecx], ax
        ; ProcedureReturn ; do not Return
        
      CompilerCase #PbFw_BIT_ASMx64
        !mov rcx, [p.p_Mem]
        !xor rax, rax
        !mov ax, word [rcx]
        !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
        ; !rol ax, 8  ; alternative way with RotateLeft 8Bit
        !mov word [rcx], ax          
        ; ProcedureReturn ; do not Return
        
      CompilerCase #PbFw_BIT_C_Backend
        !p_Mem = __builtin_bswap16(p_Mem);
          
      CompilerDefault     ; Classic Code without ASM or C optimations       
        Protected *Swap.pSwap
        *Swap = *Mem
        Swap *Swap\a[0], *Swap\a[1]
        
    CompilerEndSelect    
     
  EndProcedure
  
  Procedure BSWAP_Mem32(*Mem)
  ; ======================================================================
  ;  NAME: BSWAp_Mem32
  ;  DESC: LittleEndian<=>BigEndian conversion of a 32Bit value
  ;  DESC: Swaps the Bytes of a 32 Bit value
  ;  DESC: direct in memory.
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ====================================================================== 
  
    DBG::mac_CheckPointer(*Mem)    ; Check Pointer Exception
    
    CompilerSelect #PbFw_BIT_UseCode
           
      CompilerCase #PbFw_BIT_ASMx32
        !mov ecx, [p.p_Mem]
        !mov eax, dword [ecx]
        !bswap eax
        !mov dword [ecx], eax
        ; ProcedureReturn ; do not Return
        
     CompilerCase #PbFw_BIT_ASMx64
        !mov rcx, [p.p_Mem]
        !xor rax, rax
        !mov eax, dword [rcx]
        !bswap eax
        !mov dword [rcx], eax
        ; ProcedureReturn ; do not Return
        
     CompilerCase #PbFw_BIT_C_Backend
        !p_Mem = __builtin_bswap32(p_Mem);
         
      CompilerDefault     ; Classic Code without ASM or C optimations       
        Protected *Swap.pSwap
        *Swap = *Mem
        Swap *Swap\a[0], *Swap\a[3]
        Swap *Swap\a[1], *Swap\a[2]
        
    CompilerEndSelect
          
  EndProcedure
  
  Procedure BSWAP_Mem64(*Mem)
  ; ======================================================================
  ;  NAME: BSWAp_Mem64
  ;  DESC: LittleEndian<=>BigEndian conversion of a 64Bit value
  ;  DESC: Swaps the Bytes of a 64 Bit value
  ;  DESC: direct in memory.
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ======================================================================   
    
    DBG::mac_CheckPointer(*Mem)    ; Check Pointer Exception
    
    CompilerSelect #PbFw_BIT_UseCode
         
      CompilerCase #PbFw_BIT_ASMx32
        !mov ecx, [p.p_Mem]
        !mov edx, dword [ecx]
        !mov eax, dword [ecx +4]
        !bswap edx
        !bswap eax
        !mov dword [ecx + 4], eax
        !mov dword [ecx], edx
        ; ProcedureReturn ; do not Return
        
      CompilerCase #PbFw_BIT_ASMx64
        !mov rcx, [p.p_Mem]
        !mov rax, qword [rcx]
        !bswap rax
        !mov qword [rcx], rax
        ; ProcedureReturn ; do not Return
        
      CompilerCase #PbFw_BIT_C_Backend
        !p_Mem = __builtin_bswap64(p_Mem);
         
      CompilerDefault     ; Classic Code without ASM or C optimations       
        Protected *Swap.pSwap
        *Swap = *Mem
        Swap *Swap\a[0], *Swap\a[7]
        Swap *Swap\a[1], *Swap\a[6]
        Swap *Swap\a[2], *Swap\a[5]
        Swap *Swap\a[3], *Swap\a[4]
        
    CompilerEndSelect  

  EndProcedure
  
  Procedure.l ROL32(value.l, cnt.i = 1)
  ; ======================================================================
  ;  NAME: ROL32
  ;  DESC: RotateLeft32; rotates left a number of bits in a 32Bit Value
  ;  VAR(value.l): the value to shift
  ;  VAR(cnt.i): No of bits to shift
  ;  RET.l: Bit rotated value
  ; ====================================================================== 
        
    CompilerSelect #PbFw_BIT_UseCode
        
      CompilerCase #PbFw_BIT_ASMx32
        !mov ecx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov eax, dword [p.v_value] 
        !rol eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #PbFw_BIT_ASMx64
        !mov rcx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov rax, dword [p.v_value] 
        !rol eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #PbFw_BIT_C_Backend
        ProcedureReturn (value << cnt) | (value >> (32-cnt))
       
      CompilerDefault     ; Classic Code without ASM or C optimations       
        ProcedureReturn (value << cnt) | (value >> (32-cnt))
        
    CompilerEndSelect

  EndProcedure
  
  Procedure.l ROR32(value.l, cnt.i = 1)
  ; ======================================================================
  ;  NAME: ROR32
  ;  DESC: RotateRight32; rotates right a number of bits in a 32Bit Value
  ;  VAR(value.l): the value to shift
  ;  VAR(cnt.i): No of bits to shift
  ;  RET.l: Bit rotated value
  ; ====================================================================== 
        
    CompilerSelect #PbFw_BIT_UseCode
        
      CompilerCase #PbFw_BIT_ASMx32
        !mov ecx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov eax, dword [p.v_value] 
        !ror eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
     
      CompilerCase #PbFw_BIT_ASMx64
        !mov rcx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov rax, dword [p.v_value] 
        !ror eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #PbFw_BIT_C_Backend
        ProcedureReturn  (value >> cnt) | (value << (32-cnt))
       
      CompilerDefault     ; Classic Code without ASM or C optimations       
        ProcedureReturn  (value >> cnt) | (value << (32-cnt))
        
    CompilerEndSelect

  EndProcedure
  
  Procedure.q ROL64(value.q, cnt.i = 1)
  ; ======================================================================
  ;  NAME: ROL64
  ;  DESC: RotateLeft64; rotates left a number of bits in a 64Bit Value
  ;  VAR(value.q): the value to shift
  ;  VAR(cnt.i): No of bits to shift
  ;  RET.q: Bit rotated value
  ; ====================================================================== 
      
    CompilerSelect #PbFw_BIT_UseCode
        
      ; CompilerCase #PbFw_BIT_ASMx32
        ; use Default Code
        
      CompilerCase #PbFw_BIT_ASMx64
        !mov rcx, qword [p.v_cnt]
        !mov rax, qword [p.v_value]
        !rol rax, cl
        ProcedureReturn
     
      CompilerCase #PbFw_BIT_C_Backend
        ProcedureReturn (value << cnt) | (value >> (64-cnt))
        
      CompilerDefault  ; Classic Code without ASM or C optimations       
        ProcedureReturn (value << cnt) | (value >> (64-cnt))
         
    CompilerEndSelect

  EndProcedure
  
  Procedure.q ROR64(value.q, cnt.i = 1)
  ; ======================================================================
  ;  NAME: ROR64
  ;  DESC: RotateRight64; rotates right a number of bits in a 64Bit Value
  ;  VAR(value.q): the value to shift
  ;  VAR(cnt.i): No of bits to shift
  ;  RET.q: Bit rotated value
  ; ====================================================================== 
            
    CompilerSelect #PbFw_BIT_UseCode
        
      ; CompilerCase #PbFw_BIT_ASMx32
        ; use Default Code
        
      CompilerCase #PbFw_BIT_ASMx64
        !mov rcx, qword [p.v_cnt]
        !mov rax, qword [p.v_value]
        !ror rax, cl
        ProcedureReturn
     
      CompilerCase #PbFw_BIT_C_Backend
        ProcedureReturn  (value >> cnt) | (value << (64-cnt))
       
      CompilerDefault     ; Classic Code without ASM or C optimations       
        ProcedureReturn  (value >> cnt) | (value << (64-cnt))
        
    CompilerEndSelect

  EndProcedure
  
EndModule

CompilerIf #PB_Compiler_IsMainFile    
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------

  EnableExplicit
  UseModule Bits
  
  Macro HexW(_var_)
    RSet(Hex(_var_, #PB_Word), 4, "0")
  EndMacro

  Macro HexL(_var_)
    RSet(Hex(_var_, #PB_Long), 8, "0")
  EndMacro
  
  Macro HexQ(_var_)
    RSet(Hex(_var_, #PB_Quad), 16, "0")
  EndMacro

  Procedure Test_BSWAP()
    
    Protected a1.q, r1.q
  
    Debug "bswap16"
    a1 = $1234
    r1 = bswap16(a1)
    Debug HexW(r1)
    
    Debug "bswap32"
    a1 = $01020304
    r1 = bswap32(a1)
    Debug HexL(r1)
    
    Debug "bswap64"
    a1 = $01020304AABBCCDD
    r1 = bswap64(a1)
    Debug HexQ(r1)
    
    Debug "bswap128"
    Define a128.Int128, r128.Int128 
    
    ;a128\h = $FFEEDDCCBBAA9988 : a128\l = $7766554433221100
    a128\h = $0011223344556677 : a128\l = $8899AABBCCDDEEFF
    
    ;ShowMemoryViewer(a128, 16) 
    bswap128(a128, r128) 
    Debug HexQ(a128\h) + HexQ(a128\l) 
    Debug HexQ(r128\h) + HexQ(r128\l) 
    ;ShowMemoryViewer(r128, 16) 
   
  EndProcedure
  
  Procedure Test_BitCoung()
    Protected n, Q.q

    n=BitCount16(3)
    Debug n
    Q = ROR64(7,1)
    Debug Hex(Q) 
  EndProcedure
  
  Test_BSWAP()  
  
  DataSection
    GrayCode:
    Data.i 000000 ; 0
    Data.i 000001
    Data.i 000011
    Data.i 000010
    Data.i 000110
    Data.i 000111
    Data.i 000101
    Data.i 000100
    Data.i 001100
    Data.i 001101
    Data.i 001111 ; 10
    Data.i 001110
    Data.i 001010
    Data.i 001011
    Data.i 001001
    Data.i 001000
    Data.i 011000
    Data.i 011001
    Data.i 011011
    Data.i 011010
    Data.i 011110 ; 20
    Data.i 011111
    Data.i 011101
    Data.i 011100
    Data.i 010100
    Data.i 010101
    Data.i 010111
    Data.i 010110
    Data.i 010010
    Data.i 010011
    Data.i 010001 ; 30
    Data.i 010000
    Data.i 110000
    Data.i 110001
    Data.i 110011
    Data.i 110010
    Data.i 110110
    Data.i 110111
    Data.i 110101
    Data.i 110100
    Data.i 111100 ; 40
    Data.i 111101
    Data.i 111111
    Data.i 111110
    Data.i 111010
    Data.i 111011
    Data.i 111001
    Data.i 111000
    Data.i 101000
    Data.i 101001
    Data.i 101011 ; 50
    Data.i 101010
    Data.i 101110
    Data.i 101111
    Data.i 101101
    Data.i 101100
    Data.i 100100
    Data.i 100101
    Data.i 100111
    Data.i 100110
    Data.i 100010 ; 60
    Data.i 100011
    Data.i 100001
    Data.i 100000 ; 63
  EndDataSection
  
CompilerEndIf

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 839
; FirstLine = 833
; Folding = ------
; Markers = 334,349
; Optimizer
; EnableXP
; CPU = 5