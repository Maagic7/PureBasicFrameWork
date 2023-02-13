; ===========================================================================
;  FILE : PbFw_Module_Bits.pbi
;  NAME: Extended Bit Operation Functions
;  DESC: Implements Bit-Operation-Functions which are not part of 
;  DESC: the standard PureBasic dialect
;  DESC: Such functions are needed for industrial Software, when 
;  DESC: dealing with data from PLC-Controlers like Simens S7 or others
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2021/04/02
; VERSION  :  0.1 untested developper version
; COMPILER :  PureBasic 5.73
; ===========================================================================
; ChangeLog:
; 2022/12/04: Wrapped all in a Modulue and added it to Purebasic Framework
; 2021/04/02: Moved the BitFunctions from other libraries to their own library 
;             Added BitRotation functions  
;             
; ============================================================================


;{ ====================      M I T   L I C E N S E        ====================
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile ""

DeclareModule Bits
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  ; DECLARE Functions
  Declare.i BitCount16 (value.u)  
  Declare.i BitCount32 (value.l)
  Declare.i BitCount64 (value.q)
  
  Declare.u BSWAP16(Value.u)
  Declare.l BSWAP32(Value.l)
  Declare.q BSWAP64(Value.q)
  
  Declare BSWAp_Mem16(*Mem)
  Declare BSWAp_Mem32(*Mem)
  Declare BSWAp_Mem64(*Mem)
  
  Declare.l ROL32(value.l, cnt.i = 1)
  Declare.l ROR32(value.l, cnt.i = 1)
  Declare.q ROL64(value.q, cnt.i = 1)
  Declare.q ROR64(value.q, cnt.i = 1)  
  
EndDeclareModule


Module Bits
  
  Enumeration
    #BIT_Classic                   ; use Classic PB Code
    #BIT_ASMx32                     ; x32 Bit Assembler
    #BIT_ASMx64                     ; x64 Bit Assembler
    #BIT_C_Backend                 ; use optimations for C-Backend
  EndEnumeration
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
    
    ; **********  32 BIT  **********
    CompilerIf #PB_Compiler_32Bit
      #BIT_UseCode = #BIT_ASMx32
      
    ; **********  64 BIT  **********
    CompilerElseIf #PB_Compiler_64Bit
      #BIT_UseCode = #BIT_ASMx64
      
    ; **********  Classic Code  **********
    CompilerElse
      #BIT_UseCode = #BIT_Classic
      
    CompilerEndIf
      
  CompilerElseIf    #PB_Compiler_Backend = #PB_Backend_C
    #BIT_UseCode = #BIT_C_Backend
      
  CompilerElse
    #BIT_UseCode = #BIT_Classic
      
  CompilerEndIf 
    
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  Structure pSwap ; Pointer Structure for swapping
    a.a[0]    ; unsigned Byte-Value
    u.u[0]    ; unsigned WORD-Value
  EndStructure
  
    ; BitCount Macros for PB-Classic Code BitCount 
    ; according to AMD Code Oprimation Guide
    ; unrolling Loops is much faster, because of
    ; better code forecast!
    ; With this If(val & 1<<n) : cnt+1
    ; PB produce this ASM Code for each Bit
    
    ;  If (val & 1<<n)  : cnt +1 : EndIf
    ;     !MOVZX  ebx,word [esp+PS0+0]
    ;     !And    ebx,1
    ;     !And    ebx,ebx
    ;     !JE    _EndIf2
    ;     !MOV    ebx,dword [esp]
    ;     !INC    ebx
    ;     !MOV    dword [esp],ebx
    ;     !_EndIf2:
        
    ;   cnt + Bool(val & 1<<n)  ; produce less effective ASM CODE
    ;     !MOV    ebx,dword [esp]
    ;     !MOV    edi,dword [esp+PS0+0]
    ;     !And    edi,1
    ;     !_Bool0:
    ;     !And    edi,edi
    ;     !JE    .False
    ;     !MOV    eax,1
    ;     !JMP   .True
    ;     !.False:
    ;     !XOr    eax,eax
    ;     !.True:
    ;     !ADD    ebx,eax
    ;     !MOV    dword [esp],ebx

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

  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------

  Procedure.i BitCount16 (value.u)
  ; ======================================================================
  ;  NAME: BitCount16
  ;  DESC: Counts the number of Hi bits in a 16 Bit Value
  ;  RET.i:  Number of Hi Bits
  ; ====================================================================== 
    
    CompilerSelect #BIT_UseCode
       ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on! 
      CompilerCase #BIT_ASMx32
        !xor    eax, eax
        !mov    ax, word [p.v_value]
        !popcnt ax, ax
        ProcedureReturn
     
      CompilerCase #BIT_ASMx64
        !xor    rax, rax
        !mov    ax, word [p.v_value]
        !popcnt ax, ax
        ProcedureReturn       
        
      CompilerCase #BIT_C_Backend
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
         
    CompilerSelect #BIT_UseCode
      ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on!         
      CompilerCase #BIT_ASMx32
        !mov    eax, dword [p.v_value]
        !popcnt eax, eax
       ProcedureReturn
       
      CompilerCase #BIT_ASMx64
        !xor    rax, rax
        !mov    eax, dword [p.v_value]
        !popcnt eax, eax
       ProcedureReturn
           
      CompilerCase #BIT_C_Backend
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
    
    CompilerSelect #BIT_UseCode
       ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on!   
      CompilerCase #BIT_ASMx32  ; at x32 programms we must do 2x32Bit POPCNT and ADD
        !lea ecx, [p.v_value]
        !mov edx, dword [ecx]         ; load hi 32 Bits to EDX-Register
        !mov eax, dword [ecx +4]      ; load lo 32 Bits to EAX-Register
        !popcnt edx, edx              ; count Hi-Bits in EDX
        !popcnt eax, eax              ; count Hi-Bits in EAX
        !add eax, edx                 ; Add the 2 values
        ProcedureReturn
        
      CompilerCase #BIT_ASMx64
        !mov rax, qword [p.v_value]
        !popcnt rax, rax
        ProcedureReturn
               
      CompilerCase #BIT_C_Backend
        mac_BitCount64(value)
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
        mac_BitCount64(value)
        
    CompilerEndSelect

  EndProcedure
  
  Procedure.u BSWAP16(Value.u)
  ; ======================================================================
  ;  NAME: BSWAP16
  ;  DESC: LittleEndian<=>BigEndian conversion of a 16Bit value
  ;  DESC: Swaps the Bytes of a 16 Bit value
  ;  VAR(Value.u): 16-Bit-Word Value
  ;  RET.u: Byte swapped 16-Bit value
  ; ====================================================================== 
    
    If *Mem
      CompilerSelect #BIT_UseCode
           
        CompilerCase #BIT_ASMx32
          !xor eax, eax
          !mov ax, word [p.v_Value]
          !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
          ProcedureReturn
          
        CompilerCase #BIT_ASMx64
          !xor rax, rax
          !mov ax, word [p.v_Value]
          !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
          ProcedureReturn
         
        CompilerCase #BIT_C_Backend
          Protected *Swap.pSwap
         *Swap = @Value
          Swap *Swap\a[0], *Swap\a[1]
          ProcedureReturn Value
          
        CompilerDefault     ; Classic Code without ASM or C optimations       
          Protected *Swap.pSwap
          *Swap = @Value
          Swap *Swap\a[0], *Swap\a[1]
          ProcedureReturn Value
         
      CompilerEndSelect
      
    Else
      ; Exception  
    EndIf
    
  EndProcedure
  
  Procedure.l BSWAP32(Value.l)
  ; ======================================================================
  ;  NAME: BSWAP32
  ;  DESC: LittleEndian<=>BigEndian conversion of a 32Bit value
  ;  DESC: Swaps the Bytes of a 32 Bit value
  ;  VAR(Value.l): 32-Bit-Long Value
  ;  RET.l:  Byte swapped 32-Bit value
  ; ====================================================================== 
  
    If *Mem
      CompilerSelect #BIT_UseCode
           
        CompilerCase #BIT_ASMx32
          !mov eax, dword [p.v_Value]
          !bswap eax
          ProcedureReturn   
          
        CompilerCase #BIT_ASMx64
          !xor rax, rax
          !mov eax, dword [p.v_Value]
          !bswap eax
          ProcedureReturn    
          
       CompilerCase #BIT_C_Backend
          Protected *Swap.pSwap
          *Swap = @Value
          Swap *Swap\a[0], *Swap\a[3]
          Swap *Swap\a[1], *Swap\a[2]
          
        CompilerDefault     ; Classic Code without ASM or C optimations       
          Protected *Swap.pSwap
          *Swap = @Value
          Swap *Swap\a[0], *Swap\a[3]
          Swap *Swap\a[1], *Swap\a[2]
          
      CompilerEndSelect
      
    Else
      ; Exception  
    EndIf
    
  EndProcedure
  
  Procedure.q BSWAP64(Value.q)
  ; ======================================================================
  ;  NAME: BSWAp_Mem64
  ;  DESC: LittleEndian<=>BigEndian conversion of a 64Bit value
  ;  DESC: Swaps the Bytes of a 64 Bit value
  ;  DESC: direct in memory.
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ======================================================================   
    
    If *Mem
      CompilerSelect #BIT_UseCode
           
        CompilerCase #BIT_ASMx32
          !lea ecx, [p.v_Value]   ; load effective address of Value (:= @Value)
          !mov edx, dword [ecx]
          !mov eax, dword [ecx +4]
          !bswap edx
          !bswap eax
          ProcedureReturn         ; 64Bit Return use EAX and EDX Register
          
        CompilerCase #BIT_ASMx64
          !mov rax, qword [p.v_Value]
          !bswap rax
          ProcedureReturn
          
        CompilerCase #BIT_C_Backend
          Protected *Swap.pSwap
          *Swap = @Value
          Swap *Swap\a[0], *Swap\a[7]
          Swap *Swap\a[1], *Swap\a[6]
          Swap *Swap\a[2], *Swap\a[5]
          Swap *Swap\a[3], *Swap\a[4]      
          
        CompilerDefault     ; Classic Code without ASM or C optimations       
          Protected *Swap.pSwap
          *Swap = @Value
          Swap *Swap\a[0], *Swap\a[7]
          Swap *Swap\a[1], *Swap\a[6]
          Swap *Swap\a[2], *Swap\a[5]
          Swap *Swap\a[3], *Swap\a[4]
          
      CompilerEndSelect
    
    Else
      ; Exception  
    EndIf

   EndProcedure

  Procedure BSWAp_Mem16(*Mem)
  ; ======================================================================
  ;  NAME: BSWAp_Mem16
  ;  DESC: LittleEndian<=>BigEndian conversion of a 16Bit value
  ;  DESC: direct in memory.
  ;  DESC: Swaps the Bytes of a 16 Bit value
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ====================================================================== 
    
    If *Mem
      CompilerSelect #BIT_UseCode
           
        CompilerCase #BIT_ASMx32
          !mov ecx, [p.p_Mem]       ; load pointer to ECX
          !xor eax, eax
          !mov ax, word [ecx]       ; load value, (content of pointer)
          !xchg al, ah              ; for 16 Bit ByteSwap it's the Exchange command 
          ; !rol ax, 8  ; alternative way with RotateLeft 8Bit
          !mov word [ecx], ax
          ; ProcedureReturn ; do not Return
          
        CompilerCase #BIT_ASMx64
          !mov rcx, [p.p_Mem]
          !xor rax, rax
          !mov ax, word [rcx]
          !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
          ; !rol ax, 8  ; alternative way with RotateLeft 8Bit
          !mov word [rcx], ax          
          ; ProcedureReturn ; do not Return
          
        CompilerCase #BIT_C_Backend
          Protected *Swap.pSwap
          *Swap = *Mem
          Swap *Swap\a[0], *Swap\a[1]
           
        CompilerDefault     ; Classic Code without ASM or C optimations       
          Protected *Swap.pSwap
          *Swap = *Mem
          Swap *Swap\a[0], *Swap\a[1]
          
      CompilerEndSelect
      
    Else
      ; Exception  
    EndIf
    
  EndProcedure
  
  Procedure BSWAp_Mem32(*Mem)
  ; ======================================================================
  ;  NAME: BSWAp_Mem32
  ;  DESC: LittleEndian<=>BigEndian conversion of a 32Bit value
  ;  DESC: Swaps the Bytes of a 32 Bit value
  ;  DESC: direct in memory.
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ====================================================================== 
  
    If *Mem
      CompilerSelect #BIT_UseCode
           
        CompilerCase #BIT_ASMx32
          !mov ecx, [p.p_Mem]
          !mov eax, dword [ecx]
          !bswap eax
          !mov dword [ecx], eax
          ; ProcedureReturn ; do not Return
          
       CompilerCase #BIT_ASMx64
          !mov rcx, [p.p_Mem]
          !xor rax, rax
          !mov eax, dword [rcx]
          !bswap eax
          !mov dword [rcx], eax
          ; ProcedureReturn ; do not Return
          
       CompilerCase #BIT_C_Backend
          Protected *Swap.pSwap
          *Swap = *Mem
          Swap *Swap\a[0], *Swap\a[3]
          Swap *Swap\a[1], *Swap\a[2]
          
        CompilerDefault     ; Classic Code without ASM or C optimations       
          Protected *Swap.pSwap
          *Swap = *Mem
          Swap *Swap\a[0], *Swap\a[3]
          Swap *Swap\a[1], *Swap\a[2]
          
      CompilerEndSelect
      
    Else
      ; Exception  
    EndIf
    
  EndProcedure
  
  Procedure BSWAp_Mem64(*Mem)
  ; ======================================================================
  ;  NAME: BSWAp_Mem64
  ;  DESC: LittleEndian<=>BigEndian conversion of a 64Bit value
  ;  DESC: Swaps the Bytes of a 64 Bit value
  ;  DESC: direct in memory.
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ======================================================================   
    
    If *Mem
      CompilerSelect #BIT_UseCode
           
        CompilerCase #BIT_ASMx32
          !mov ecx, [p.p_Mem]
          !mov edx, dword [ecx]
          !mov eax, dword [ecx +4]
          !bswap edx
          !bswap eax
          !mov dword [ecx + 4], eax
          !mov dword [ecx], edx
          ; ProcedureReturn ; do not Return
          
        CompilerCase #BIT_ASMx64
          !mov rcx, [p.p_Mem]
          !mov rax, qword [rcx]
          !bswap rax
          !mov qword [rcx], rax
          ; ProcedureReturn ; do not Return
          
        CompilerCase #BIT_C_Backend
          Protected *Swap.pSwap
          *Swap = *Mem
          Swap *Swap\a[0], *Swap\a[7]
          Swap *Swap\a[1], *Swap\a[6]
          Swap *Swap\a[2], *Swap\a[5]
          Swap *Swap\a[3], *Swap\a[4]      
          
        CompilerDefault     ; Classic Code without ASM or C optimations       
          Protected *Swap.pSwap
          *Swap = *Mem
          Swap *Swap\a[0], *Swap\a[7]
          Swap *Swap\a[1], *Swap\a[6]
          Swap *Swap\a[2], *Swap\a[5]
          Swap *Swap\a[3], *Swap\a[4]
          
      CompilerEndSelect
    
    Else
      ; Exception  
    EndIf

   EndProcedure
  
  Procedure.l ROL32(value.l, cnt.i = 1)
  ; ======================================================================
  ;  NAME: ROL32
  ;  DESC: RotateLeft32; rotates left a number of bits in a 32Bit Value
  ;  VAR(value.l): the value to shift
  ;  VAR(cnt.i): No of bits to shift
  ;  RET.l: Bit rotated value
  ; ====================================================================== 
        
    CompilerSelect #BIT_UseCode
        
      CompilerCase #BIT_ASMx32
        !mov ecx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov eax, dword [p.v_value] 
        !rol eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #BIT_ASMx64
        !mov rcx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov rax, dword [p.v_value] 
        !rol eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #BIT_C_Backend
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
        
    CompilerSelect #BIT_UseCode
        
      CompilerCase #BIT_ASMx32
        !mov ecx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov eax, dword [p.v_value] 
        !ror eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
     
      CompilerCase #BIT_ASMx64
        !mov rcx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov rax, dword [p.v_value] 
        !ror eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #BIT_C_Backend
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
      
    CompilerSelect #BIT_UseCode
        
      ; CompilerCase #BIT_ASMx32
        ; use Default Code
        
      CompilerCase #BIT_ASMx64
        !mov rcx, qword [p.v_cnt]
        !mov rax, qword [p.v_value]
        !rol rax, cl
        ProcedureReturn
     
      CompilerCase #BIT_C_Backend
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
            
    CompilerSelect #BIT_UseCode
        
      ; CompilerCase #BIT_ASMx32
        ; use Default Code
        
      CompilerCase #BIT_ASMx64
        !mov rcx, qword [p.v_cnt]
        !mov rax, qword [p.v_value]
        !ror rax, cl
        ProcedureReturn
     
      CompilerCase #BIT_C_Backend
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

  Define n, Q.q

  n=BitCount16(3)
  Debug n
  Q = ROR64(7,1)
  Debug Hex(Q)
CompilerEndIf

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 502
; FirstLine = 679
; Folding = ----
; Optimizer
; EnableXP
; CPU = 5