; ===========================================================================
;  FILE : PbFw_Module_Bit.pb
;  NAME: Extended Bit Operation Functions [BIT::]
;  DESC: Implements Bit-Operation-Functions which are not part of 
;  DESC: the standard PureBasic dialect
;  DESC: Such functions are needed for industrial Software, when 
;  DESC: dealing with data from PLC-Controlers like Simens S7 or others
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2021/04/02
; VERSION  :  0.54  Developer Version
; COMPILER :  PB 6.0 and higher
; OS       :  all
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{
; 2025/06/29  S.Maag: some small changes
; 2025/02/06  S.Maag: added BitCountINT
; 2025/01/30  S.Maag: solved Bug in ASMx32 BSWAP_Mem64()! Swap of Lo-Hi DWORD was missing!
; 2024/09/06  S.Maag: added INTtoBCD(), BCDtoINT(), IsBCD()
; 2024/08/31  S.Maag: changed BitCount Classic Macros from If to faster add version
; 2024/08/28  S.Maag: added ByteToBitField, BitFieldToByte
;                           WordToBitField, BitFieldToWord, BitShuffle8/16
; 2023/03/19  S.Maag: Added C-Backend optimations according to
;             https://www.purebasic.fr/english/viewtopic.php?t=77563
; 2023/03/12: S.Maag: Added GrayCode Encoder and Decoder
; 2022/12/04: S.Maag: Wrapped all in a Module and added it to Purebasic Framework
; 2021/04/02: S.Maag: Moved the BitFunctions from other libraries to their own library 
;             Added BitRotation functions  
; }            
; ============================================================================

; Bitmanipulation Assembler Instructions
; BEXTR: Bit Field Extract
; BLSI: Extract Lowest Set Isolated Bit
; BLSR: Reset Lowest Set Bit
; BSF : Bit Scan Forward
; BSR : Bit Scan Reverse
; BT  : Bit Test
; BTC : Bit Test and Complement
; BTS : Bit Test and Set
; BTR : Bit Test and Reset
; BZHI : Zero High Bits Starting with Specified Bit Position
; BSWAP : Byte Swap
; POPCNT : Return the Count of Number of Bits Set to 1
; PEXT   : Parallel Bit-Extrakt
; PDEP   : Parallel Bit-Deposit
;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_Bit.pb"        ; Bit::      Bit Module

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"       ; DBG::      Debug Module

; XIncludeFile ""

DeclareModule BIT
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  #BIT_SHF_REVERSE_8 = $0001020304050607    ; Bit Shuffle Mask to reverse 8 Bits
  
  #BIT_SHF_REVERSE_16_hi= $0001020304050607 ; Bit Shuffle Mask hiQuad to reverse 16 Bits
  #BIT_SHF_REVERSE_16_lo= $08090A0B0C0D0E0F ; Bit Shuffle Mask loQuad to reverse 16 Bits
 
  Structure TBitField8  ; Byte Representation of 8 Bits
    StructureUnion
      q.q         ; a 8 Byte Quad
      a.a[8]      ; 8 Bytes [0..7] 
    EndStructureUnion
  EndStructure
  
  Structure TBitField16  ; Byte Representation of 16 Bits
    StructureUnion
      q.q[2]       ; 2x 8 Byte Quads
      a.a[16]      ; 16 Bytes [0..15] 
    EndStructureUnion
  EndStructure
  
  Structure TBitField32  ; Byte Representation of 32 Bits
    StructureUnion
      q.q[4]       ; 4x 8 Byte Quads
      a.a[32]      ; 32 Bytes [0..31] 
    EndStructureUnion
  EndStructure
  
  Structure TBitField64  ; Byte Representation of 64 Bits
    StructureUnion
      q.q[8]       ; 8x 8 Byte Quads
      a.a[64]      ; 64 Bytes [0..63] 
    EndStructureUnion
  EndStructure
 
  Structure Int128 
    l.q
    h.q
  EndStructure   
  
  ; DECLARE public Functions

  Declare.i GrayEncode(N.i)
  Declare.i GrayDecode(G.i)
  
  Declare.i BCDtoINT(BCD, Sign=#False)
  Declare.i INTtoBCD(Value)
  Declare.i IsBCD(BCD)

  Declare.i ByteToBitField(*OutBF.TBitField8, Byte.a)
  Declare.a BitFieldToByte(*BF.TBitField8)
  Declare.i WordToBitField(*OutBF.TBitField16, Word.u)
  Declare.u BitFieldToWord(*BF.TBitField16)
  Declare.a BitShuffle8(ByteVal.a, ShuffleMask.q)
  Declare.u BitShuffle16(WordVal.u, *ShuffleMask.TBitField16)

  Declare.i BitCount16 (value.u)  
  Declare.i BitCount32 (value.l)
  Declare.i BitCount64 (value.q)
  Declare.i BitCountINT (value.i)
 
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

Module BIT
  
  EnableExplicit
  CompilerIf Defined(PbFw, #PB_Module)
    PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
    ;- ----------------------------------------------------------------------
    ;- PbFw Module local configurations
    ;  ----------------------------------------------------------------------
    ; This constants must have same Name in all Modules
    
    ; ATTENTION: with the PbFw::CONST Macro the PB-IDE Intellisense do not registrate the ConstantName
    
    ; #PbFwCfg_Module_CheckPointerException = #True     ; On/Off PoninterExeption for this Module
    PbFw::CONST(PbFwCfg_Module_CheckPointerException, #True)
    
    ; #PbFwCfg_Module_ASM_Enable = #True                ; On/Off Assembler Versions when compling in ASM Backend
    PbFw::CONST(PbFwCfg_Module_ASM_Enable, #True)
  CompilerEndIf 
 
  ; -----------------------------------------------------------------------
      
  ; ************************************************************************
  ; PbFw::mac_CompilerModeSettting      ; using Macro for CompilerSetting is a problem for the IDE
  ; so better use the MacroCode directly
  ; Do not change! Must be changed globaly in PbFw:: and then copied to each Module
  Enumeration
    #PbFwCfg_Module_Compile_Classic                 ; use Classic PB Code
    #PbFwCfg_Module_Compile_ASM32                   ; x32 Bit Assembler
    #PbFwCfg_Module_Compile_ASM64                   ; x64 Bit Assembler
    #PbFwCfg_Module_Compile_C                       ; use optimations for C-Backend
  EndEnumeration
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm And #PbFwCfg_Module_ASM_Enable And PbFw::#PbFwCfg_Global_ASM_Enable 
    ; A S M   B A C K E N D
    CompilerIf #PB_Compiler_32Bit
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM32     
    ; **********  64 BIT  **********
    CompilerElseIf #PB_Compiler_64Bit
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM64     
    ; **********  Classic Code  **********
    CompilerElse
      #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
    CompilerEndIf
      
  CompilerElseIf  #PB_Compiler_Backend = #PB_Backend_C
    ;  C - B A C K E N D
     #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_C     
  CompilerElse
    Debug "Classic" 
    ;  To force Classic Code Compilation
    #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_Classic     
  CompilerEndIf 
  ; ************************************************************************
  ;Debug "PbFwCfg_Module_Compile = " + #PbFwCfg_Module_Compile
  
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  CompilerIf #PB_Compiler_32Bit
    #_MaskOutSign = $7FFFFFFF
  CompilerElse
    #_MaskOutSign = $7FFFFFFFFFFFFFFF   
  CompilerEndIf
  
  Structure pSwap ; Pointer Structure for swapping
    a.a[0]    ; unsigned Byte-Value
    u.u[0]    ; unsigned WORD-Value
  EndStructure
  
  ; BitCount Macros for PB-Classic
  ; According to AMD Code Oprimation Guide
  ; unrolling Loops is much faster, because of
  ; better code forecast!
  
  Macro mac_BitCount8(val)
    Protected cnt.i            
    cnt= Bool(val& $1)  + Bool(val&   $2)+ Bool(val&   $4)+ Bool(val&   $8)+
         Bool(val&$10)  + Bool(val&  $20)+ Bool(val&  $40)+ Bool(val&  $80)+
    ProcedureReturn cnt
  EndMacro

  Macro mac_BitCount16(val)
    Protected cnt.i            
    cnt= Bool(val& $1)  + Bool(val&   $2)+ Bool(val&   $4)+ Bool(val&   $8)+
         Bool(val&$10)  + Bool(val&  $20)+ Bool(val&  $40)+ Bool(val&  $80)+
         Bool(val&$100) + Bool(val& $200)+ Bool(val& $400)+ Bool(val& $800)+
         Bool(val&$1000)+ Bool(val&$2000)+ Bool(val&$4000)+ Bool(val&$8000)
    ProcedureReturn cnt
  EndMacro
  
  Macro mac_BitCount32(val)
    Protected cnt.i   
    cnt= Bool(val& $1)  + Bool(val&   $2)+ Bool(val&   $4)+ Bool(val&   $8)+
         Bool(val&$10)  + Bool(val&  $20)+ Bool(val&  $40)+ Bool(val&  $80)+
         Bool(val&$100) + Bool(val& $200)+ Bool(val& $400)+ Bool(val& $800)+
         Bool(val&$1000)+ Bool(val&$2000)+ Bool(val&$4000)+ Bool(val&$8000)
    
    cnt+ Bool(val&   $10000)+ Bool(val&   $20000)+ Bool(val&   $40000)+ Bool(val&   $80000)+
         Bool(val&  $100000)+ Bool(val&  $200000)+ Bool(val&  $400000)+ Bool(val&  $800000)+
         Bool(val& $1000000)+ Bool(val& $2000000)+ Bool(val& $4000000)+ Bool(val& $8000000)+
         Bool(val&$10000000)+ Bool(val&$20000000)+ Bool(val&$40000000)+ Bool(val&$80000000)
    
    ProcedureReturn cnt
  EndMacro
  
  Macro mac_BitCount64(val)
    Protected cnt.i   
    cnt= Bool(val& $1)  + Bool(val&   $2)+ Bool(val&   $4)+ Bool(val&   $8)+
         Bool(val&$10)  + Bool(val&  $20)+ Bool(val&  $40)+ Bool(val&  $80)+
         Bool(val&$100) + Bool(val& $200)+ Bool(val& $400)+ Bool(val& $800)+
         Bool(val&$1000)+ Bool(val&$2000)+ Bool(val&$4000)+ Bool(val&$8000)
    
    cnt+ Bool(val&   $10000)+ Bool(val&   $20000)+ Bool(val&   $40000)+ Bool(val&   $80000)+
         Bool(val&  $100000)+ Bool(val&  $200000)+ Bool(val&  $400000)+ Bool(val&  $800000)+
         Bool(val& $1000000)+ Bool(val& $2000000)+ Bool(val& $4000000)+ Bool(val& $8000000)+
         Bool(val&$10000000)+ Bool(val&$20000000)+ Bool(val&$40000000)+ Bool(val&$80000000)
    
    cnt+ Bool(val&   $100000000)+ Bool(val&   $20000000)+ Bool(val&   $400000000)+ Bool(val&   $800000000)
         Bool(val&  $1000000000)+ Bool(val&  $200000000)+ Bool(val&  $4000000000)+ Bool(val&  $8000000000)
         Bool(val& $10000000000)+ Bool(val& $2000000000)+ Bool(val& $40000000000)+ Bool(val& $80000000000)
         Bool(val&$100000000000)+ Bool(val&$20000000000)+ Bool(val&$400000000000)+ Bool(val&$800000000000)
         
    cnt+ Bool(val&   $1000000000000)+ Bool(val&   $2000000000000)+ Bool(val&   $4000000000000)+ Bool(val&   $8000000000000)
         Bool(val&  $10000000000000)+ Bool(val&  $20000000000000)+ Bool(val&  $40000000000000)+ Bool(val&  $80000000000000)
         Bool(val& $100000000000000)+ Bool(val& $200000000000000)+ Bool(val& $400000000000000)+ Bool(val& $800000000000000)
         Bool(val&$1000000000000000)+ Bool(val&$2000000000000000)+ Bool(val&$4000000000000000)+ Bool(val&$8000000000000000)
                                                                                                         
    ProcedureReturn cnt
  EndMacro
  
  ; https://mirror.isoc.org.il/pub/netbsd/misc/joerg/XEN3DOMU/src/src/common/lib/libc/string/popcount64.c.html
  ; Brainstorming: Code fragments from PB Forum
;   Procedure.i _Popcount64(x.i)
;     x = x - (x >> 1) &  $5555555555555555           
;     x = (x & $3333333333333333) + ((x >> 2) & $3333333333333333)
;     x = (x + (x >> 4)) & $0F0F0F0F0F0F0F0F
;     x= x * $0101010101010101
;     x >> 56           ; 64-8
;     ProcedureReturn x   
;   EndProcedure 
  
; unsigned int popcount64(unsigned long long x)
; {
;     x = (x & 0x5555555555555555ULL) + ((x >> 1) & 0x5555555555555555ULL);
;     x = (x & 0x3333333333333333ULL) + ((x >> 2) & 0x3333333333333333ULL);
;     x = (x & 0x0F0F0F0F0F0F0F0FULL) + ((x >> 4) & 0x0F0F0F0F0F0F0F0FULL);
;     Return (x * 0x0101010101010101ULL) >> 56;
; }  
  
;   Procedure popcount9(Value.l)
;     Protected J.i
;     J = (Value >> 1) & $55555555;
;     Value = Value - J; // (A)
;     Value = (Value & $33333333) + ((Value >> 2) & $33333333); // (B)
;     Value = (Value & $0F0F0F0F) + ((Value >> 4) & $0F0F0F0F); // (C)
;     Value = Value * $01010101; // (D)
;     ProcedureReturn Value >> 24;      ; 24=32-8
;   EndProcedure
 
;   Procedure _PopCount128_Addr(*Int128)
;     ; move [*Int128] to registers
;     
;     CompilerIf #PB_Compiler_OS = #PB_OS_Windows
;       !popcnt rax, rcx      ; x64 Windows
;       !popcnt r8 , rdx
;     CompilerElse
;       !popcnt rax, rdi      ; x64 macOS and Linux
;       !popcnt r8 , rsi
;     CompilerEndIf
;     !add rax, r8
;     ProcedureReturn
;   EndProcedure
  
;   popcount32(uint32_t v)
; {
; 	unsigned int c;
; 	v = v - ((v >> 1) & 0x55555555U);
; 	v = (v & 0x33333333U) + ((v >> 2) & 0x33333333U);
; 	v = (v + (v >> 4)) & 0x0f0f0f0fU;
; 	c = (v * 0x01010101U) >> 24;
; 	/*
; 	 * v = (v >> 16) + v;
; 	 * v = (v >> 8) + v;
; 	 * c = v & 255;
; 	 */
; 	Return c;
; }
  
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
        
    ; This should solve the arithmetic Shift problem! Not tested yet!
    If N >= 0
      ProcedureReturn N ! (N >>1) ; N XOR ShiftRight(N,1)
    Else
      ProcedureReturn N ! ((N >>1) & #_MaskOutSign) ; N XOR ShiftRight(N,1)   
    EndIf
    
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
        
    ; This should solve the arithmetic Shift problem! Not tested yet!
    If mask < 0
      Mask = (Mask >> 1) & #_MaskOutSign  ;  ShiftRight(Mask, 1)
      G ! Mask    ;  G XOR Mask
    EndIf
      
    While Mask 
      Mask >> 1       ;  ShiftRight(Mask, 1)
      G ! Mask        ;  G XOR Mask
    Wend
    ProcedureReturn G
  EndProcedure
   
  Procedure.i INTtoBCD(Value)
  ; ============================================================================
  ; NAME: INTtoBCD
  ; DESC: Convert INT to BCD 
  ; DESC: Negative values will be converted as positive, becaus BCD do not
  ; DESC: support sign. Sometimes '$FF' is used as sign but better you
  ; DESC: check the sing by yourself if you need!
  ; VAR(Value) : The Integer to convert, max digits = 8 at x32  16 at x64
  ; RET.i : BCD Value or -1 if Error (to much digits) 
  ; ============================================================================
  Protected ret, SHL
  
    If Value <0
      Value = - Value
    EndIf
    
    CompilerIf #PB_Compiler_32Bit
      If Value > 99999999           ; max 8 digits at x32
        ProcedureReturn -1
      EndIf   
    CompilerElse
      If Value > 9999999999999999   ; max 16 digits at x64
        ProcedureReturn -1
      EndIf     
    CompilerEndIf
      
    While Value >0      
      ; C-Backend removes the DIV completely and use 
      ; opitmized inverse INT muliplication
      Protected mem
      mem= Value 
      Value = Value /10
      ;ret = ret +(   Remainder   ) << SHL 
      ret = ret + (mem - Value *10) << SHL
      SHL = SHL + 4         
    Wend
    
    ProcedureReturn ret  
  EndProcedure

  Procedure.i BCDtoINT(BCD, Sign=#False)
  ; ============================================================================
  ; NAME: BCDtoINT
  ; DESC: Converts a BCD with max 8/16 digits x32/x64 into an INT 
  ; DESC: check the sing by yourself if you need!
  ; VAR(BCD) : The BCD value
  ; VAR(Sign=#False) : The sign Bit -> use #True to get a negative INT
  ; RET.i : Integer value
  ; ============================================================================
    Protected ret
    Protected mul = 1
    
    While BCD 
      ret = ret + (BCD & $F)*mul
      BCD>>4
      mul * 10
    Wend
    
    If Sign
      ret=-ret
    EndIf
    
    ProcedureReturn ret   
  EndProcedure
  
  Procedure.i IsBCD(BCD)
  ; ============================================================================
  ; NAME: IsBCD
  ; DESC: Checks the BCD value for correct BCD encoding. No ByteValues > 9 allowed!
  ; VAR(BCD) : The BCD value
  ; RET.i : #True for correct BCD encoding (all Bytes <=9) 
  ; ============================================================================
    Protected ret = #True 
    
    CompilerIf  #PB_Compiler_32Bit          ; 8 digits at x32
      #_BCD_Bit8_Check = $88888888    
      #_BCD_Bit42_Check = $66666666   
    CompilerElse                            ; 16 digits at x64
      #_BCD_Bit8_Check = $8888888888888888   
      #_BCD_Bit42_Check = $6666666666666666  
    CompilerEndIf
    
    If (BCD & #_BCD_Bit8_Check)     ; if in a Byte the 8Bit is set     
      If (BCD & #_BCD_Bit42_Check)  ; we must check for the Bit 4 + 2 set
        ret= #False                 ; if a 4 or 2 Bit is set BCD Byte >= 10 
      EndIf     
    EndIf
    
    ProcedureReturn ret     ; valid BCD 8 Bit is not set so Byte < 8    
  EndProcedure

  Procedure.i ByteToBitField(*OutBF.TBitField8, ByteVal.a)
  ; ============================================================================
  ; NAME: ByteToBitField
  ; DESC: Converts the 8 Bits of a Byte in a 8 Byte BitField-Structure
  ; DESC: -> ByteRepresentaton of the Bits
  ; VAR(*OutBF.TBitField8) : Pointer to retrun BitField
  ; VAR(ByteVal) : The Byte to convert into BitField
  ; RET.i : *OutBF
  ; ============================================================================
    
    CompilerSelect #PbFwCfg_Module_Compile
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        
        ; PDEP 	Parallel Bit-Deposit, need CPU Flag BMI2 (BitManipulatonInstructions2)
        ; PDEP is the 'opposite ' function to PEXT. It's a kind of BitShuffle!
        ; 0x000000001234CAFE  | x0011   ; Input Value
        ; 0xFFFF0000FFFF0000  ; x0101   ; Mask
        ; ------------------------------------
        ; 0x12340000CAFE0000	; x0101   ;Result
        
        ; load Byte and zero expand it to full register size
        !MOVZX RCX, BYTE [p.v_ByteVal]  ; RCX = Byte
        !MOV RDX, $0101010101010101     ; RDX = mask
        !MOV RAX, [p.p_OutBF]           ; RAX = *OutBF       
         
        !PDEP RCX, RCX, RDX         ; RCX <- 8x Bool
        
        !TEST  RAX, RAX             ; TEST *OutBF=0 ?
        !JZ @f                      ; JumpIfZero
          !MOV [RAX], RCX           ; *OutBF\q = RAX
        !@@:
        ProcedureReturn             ; RAX = *OutBF
         
      CompilerDefault   
       
        Protected val = ByteVal        
        If *OutBF
          ; In ASM Backend it's the 2nd best after the ASM Version
          ; In C-Backend it's the best and with the ASM Version it's a head to head race. 
           With *OutBF
             \q = (val &1)        + ((val>>1)&1)<<8 +  ((val>>2)&1)<<16 + ((val>>3)&1)<<24 +
                 ((val>>4)&1)<<32 + ((val>>5)&1)<<40 + ((val>>6)&1)<<48 + ((val>>7)&1)<<56    
          EndWith
        EndIf       
        ProcedureReturn *OutBF
        
    CompilerEndSelect
  EndProcedure
    
  Procedure.a BitFieldToByte(*BF.TBitField8)
  ; ============================================================================
  ; NAME: ByteToBitField
  ; DESC: Converts a Byte BitField Structure into a Byte -> Bitrepresentation
  ; DESC: 
  ; VAR(*BF.TBitField8) : The BitField Structure
  ; RET.a : unsingned BYTE
  ; ============================================================================
     CompilerSelect #PbFwCfg_Module_Compile       
       
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        
        ; PEXT Parallel Bit-Extrakt 
        ; PEXT result, source, mask ; extract the bits fom soure masked with mask
        ; and store the extracted Bits in loByte of result. 
        ; this can be used for converting 8 ByteBool to a single Byte
        
        ; ------------------------------------
        ; 0x12345678CAFEBABE	; Value
        ; 0xFFFF0000FFFF0000  ; Mask
        ;   1234    CAFE      ; Value AND Mask    
        ; ------------------------------------
        ; 0x000000001234CAFE  ; Result (the masked Bits are moved to lo)
        ; 
        !MOV RAX, [p.p_BF]          ; RAX =*BF
        !MOV RCX, [RAX]             ; RCX = *BF\q
        !MOV RDX, $0101010101010101 ; RDX = mask
        !PEXT RAX, RCX, RDX         ; extract lo Bit from each Byte and compact it as Byte
        ProcedureReturn
        
      CompilerDefault
       
        Protected val     
        With *BF
          val = (\a[7] &1)<<7 + (\a[6] &1)<<6 + (\a[5] &1)<<5 + (\a[4] &1)<<4 +
                (\a[3] &1)<<3 + (\a[2] &1)<<2 + (\a[1] &1)<<1 +  \a[0]
        EndWith    
        ProcedureReturn val
        
    CompilerEndSelect    
  EndProcedure
 
  Procedure.i WordToBitField(*OutBF.TBitField16, WordVal.u)
  ; ============================================================================
  ; NAME: WordToBitField
  ; DESC: Converts the 16 Bits of a Word in a 16 Byte BitField-Structure
  ; DESC: -> ByteRepresentaton of the Bits
  ; VAR(*OutBF.TBitField16) : Pointer to retrun BitField
  ; VAR(WordVal) : The Word to convert into BitField
  ; RET.i : *OutBF
  ; ============================================================================
    
    CompilerSelect #PbFwCfg_Module_Compile       
       
      CompilerCase #PbFwCfg_Module_Compile_ASM64
           
        ; PDEP 	Parallel Bit-Deposit, need CPU Flag BMI2 (BitManipulatonInstructions2)
        ; PDEP is the 'opposite ' function to PEXT. It's a kind of ByteShuffle!
        ; 0x000000001234CAFE  | x11     ; Input Value
        ; 0xFFFF0000FFFF0000  ; x0101   ; Mask
        ; ------------------------------------
        ; 0x12340000CAFE0000	; x0101   ;Result
        
        ; RAX : operating Register
        ; RCX : loByte operation
        ; RDX : mask 
        ; R8  : hiByte operation
        
        ; load Byte and zero expand it to full register size
        !MOVZX RCX, WORD [p.v_WordVal]  ; RCX = Word
        !MOV RDX, $0101010101010101     ; RDX = mask
        !MOV RAX, [p.p_OutBF]           ; RAX = *OutBF      
        !MOV R8, RCX
        !SHRX R8,8                      ; ShiftRight without Carry
        
        !PDEP RCX, RCX, RDX         ; RCX <- 8x Bool from loByte
        !PDEP R8, R8, RDX           ; R8  <- 8x Bool from hiByte
        
        !TEST  RAX, RAX             ; TEST *OutBF=0 ?
        !JZ @f                      ; JumpIfZero
          !MOV [RAX], RCX           ; *OutBF\q[0] = RAX : loByte
          !MOV [RAX+8], R8          ; *OutBF\q]1] = R8  : hiByte      
        !@@:
        ProcedureReturn             ; RAX = *OutBF
         
      CompilerDefault
        
        Protected val 
        If *OutBF
          With *OutBF
            val = WordVal & $FF        ; lo Byte
            \q[0] = (val &1)        + ((val>>1)&1)<<8  + ((val>>2)&1)<<16 + ((val>>3)&1)<<24 +
                   ((val>>4)&1)<<32 + ((val>>5)&1)<<40 + ((val>>6)&1)<<48 + ((val>>7)&1)<<56    
            
            val = (WordVal >> 8) & $FF ; hi Byte
            \q[1] = (val &1)        + ((val>>1)&1)<<8  + ((val>>2)&1)<<16 + ((val>>3)&1)<<24 +
                   ((val>>4)&1)<<32 + ((val>>5)&1)<<40 + ((val>>6)&1)<<48 + ((val>>7)&1)<<56    
          EndWith
        EndIf
        ProcedureReturn *OutBF
        
    CompilerEndSelect
  EndProcedure

  Procedure.u BitFieldToWord(*BF.TBitField16)
  ; ============================================================================
  ; NAME: BitFieldToWord
  ; DESC: Converts a Byte BitField Structure into a Word -> Bitrepresentation
  ; DESC: 
  ; VAR(*BF.TBitField16) : The BitField Structure
  ; RET.u : unsingned WORD
  ; ============================================================================
     CompilerSelect #PbFwCfg_Module_Compile       
       
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        
        ; PEXT 	Parallel Bit-Extrakt 
        ; PEXT result, source, mask ; extract the bits fom soure masked with mask
        ; and store the extracted Bits in loByte of result. 
        ; this can be used for converting 8 ByteBool to a single byte
        
        ; ------------------------------------
        ; 0x12345678CAFEBABE	; Value
        ; 0xFFFF0000FFFF0000  ; Mask
        ;   1234    CAFE      ; Value AND Mask    
        ; ------------------------------------
        ; 0x000000001234CAFE  ; Result (the masked Bits are moved to lo)
        ; 
        !MOV R8, [p.p_OutBF]   ; RDX = *BF
        !MOV RCX, [R8]         ; RCX = *BF\q[0]
        !MOV R9, [R8+8]        ; R9  = *BF\q[1]
        !MOV RDX, $0101010101010101 ; RDX = mask
        
        !PEXT R8, R9, RDX      ; *BF\q[1] -> HiByte
        !PEXT RAX, RCX, RDX    ; *BF\q[0] -> LoByte
        
        !SHL R8, 8             ; -> Shift to Hi
        !OR RAX, R8            ; create Word from 2 Bytes
        ProcedureReturn
        
      CompilerDefault
        
        Protected val 
        With *BF
          val = (\a[15] &1)<<15 + (\a[14] &1)<<14 + (\a[13] &1)<<13 + (\a[12] &1)<<12 +
                (\a[11] &1)<<11 + (\a[10] &1)<<10 + (\a[9] &1) <<9  + (\a[8] &1)<<8
          
          val=val+ (\a[7] &1)<<7 + (\a[6] &1)<<6 + (\a[5] &1)<<5 + (\a[4] &1)<<4 +
                   (\a[3] &1)<<3 + (\a[2] &1)<<2 + (\a[1] &1)<<1 +  \a[0]
        EndWith     
        ProcedureReturn val
        
    CompilerEndSelect   
  EndProcedure
  
  Procedure.a BitShuffle8(ByteVal.a, ShuffleMask.q)
  ; ============================================================================
  ; NAME: BitShuffle8
  ; DESC: Shuffles 8 Bits in a Byte according to the ShuffleMask
  ; DESC: The ShuffleMask is an '8 Byte Array' with the Bitpositons to take from!
  ; DESC: #BIT_SHF_REVERSE_8 = $0001020304050607 reverses the Bitorder
  ; DESC: the lowest Byte of this Shufflemask is $07 what means the OutBitPosition[0]
  ; DESC: will be filled with the Bit[7] of the input ...
  ; DESC: To create the ShuffleMask you can use the TBitField16 Structure
  ; DESC: Which produce the Quads from 8 Bytes!
  ; VAR(ByteVal) : The Byte to shuffle
  ; VAR(ShuffleMask.q) : The shuffle mask
  ; RET.a : The shuffled unsigned Byte Value
  ; ============================================================================
    
    CompilerIf #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM64
        
      ; Used Registers:
      ;   RAX : operating Register
      ;   RCX : Shuffeld Bytes
      ;   RDX : [filt]
      ;   R8  : -
      ;   R9  : -
      ;   XMM0 : operation Register
      ;   XMM1 : ByteVal shuffled to all Bytes
      ;   XMM2 : [mask]    
      ;   XMM3 : [filt]
      ;   XMM4 : ShuffleMask
      
      ; How to shuffle Bits! Example for Byteval = 7
      ; first we load the '7' to XMM-Register than Shuffle the '7' to all Bytes of XMM
      ; so we get for the lo 8 Bytes in XMM: (and the same for the 8 hi Bytes!)
      
      ; Byte value       | 07 | 07 | 07 | 07 | 07 | 07 | 07 | 07 | Byte shuffled to all Bytes
      ; AND Mask         | 80 | 40 | 20 | 10 | 08 | 04 | 02 | 01 | this filters Bit 7..0
      ; ---------------------------------------------------------
      ; Result           | 00 | 00 | 00 | 00 | 00 | 04 | 02 | 01 | here we get the mask if Bit was 1
      ; ---------------------------------------------------------    
      ; Compare with Mask| 00 | 00 | 00 | 00 | 00 | FF | FF | FF |
      ; AND filt         | 01 | 01 | 01 | 01 | 01 | 01 | 01 | 01 |
      ; ---------------------------------------------------------    
      ; Bool results     | 00 | 00 | 00 | 00 | 00 | 01 | 01 | 01 |  Thats the BitFild.a()
      
      !MOVQ XMM2, [mask]          ; XMM2 = [mask] ; 8 Byte load from DataSection
      !MOVQ XMM3, [filt]          ; XMM3 = [filt] ; 8 Byte load from DataSection
      !MOV RDX, XMM3              ; RDX =  [filt]
      !PXOR XMM0, XMM0            ; XMM0 = 0
       
      !MOVZX RAX, BYTE[p.v_ByteVal] ; load with zero expand to full Register size
      !MOVQ XMM1, RAX             ; XMM1 = ByteVal
      !PSHUFB XMM1, XMM0          ; loByte to all Bytes
       
      !MOV RAX, [p.v_ShuffleMask]
      !MOVQ XMM4, RAX             ; XMM4 = ShuffleMask
      !MOVQ XMM0, [lim7]          ; XMM0 = [lim7]-Mask
      !PAND XMM4, XMM0            ; limit each Byte in ShuffleMask to 7
      
      !PAND XMM1, XMM2            ; Filter Bit[0..7] from Byte
      !PCMPEQB XMM1, XMM2         ; compare with mask ->  Byte[0..7] = Bit[0..7]
      !PSHUFB XMM1, XMM4          ; Shuffle the Bytes containing the BitValues
      !MOVQ RCX, XMM1             ; transfer shuffeld bytes back to x64 regs
      !PEXT RAX, RCX, RDX         ; extract lo Bit from each Byte and compact it to a Byte in RAX
      ProcedureReturn             ; RAX contians shuffeld Bits
      
      ; DataSection now after the BitShuffle Functions. Because double use in BitShuffle8 and BitShuffle16
;       DataSection
;         ; Attention: FASM nees a leading 0 for hex values
;         ; 16 Byte Mask to be prepared for 16 Bit Shuffle too
;         !mask:  dq 08040201008040201h   ; mask to filter in each byte 1 Bit higher
;         !filt:  dq 00101010101010101h   ; Filter to creat BOOLs with value 1
;         !lim:   dq 00707070707070707h   ; Limit Mask for ShuffleMask 
;       EndDataSection
    
    CompilerElse
      
      Protected BF.TBitField8, SH.TBitField8 
      Protected val = ByteVal 
      
      SH\q = ShuffleMask & $0707070707070707 ; limit all Bytes in the ShuffleMask to 7
      
      ; convert Byte to BitField
      With BF
        \q= (val &1)        + ((val>>1)&1)<<8  + ((val>>2)&1)<<16 + ((val>>3)&1)<<24 +
           ((val>>4)&1)<<32 + ((val>>5)&1)<<40 + ((val>>6)&1)<<48 + ((val>>7)&1)<<56    
      EndWith       
      
      ; convert BitField with shuffling back to a Byte value
      With BF
        val = \a[ SH\a[0] ]    + \a[ SH\a[1] ]<<1 + \a[ SH\a[2] ]<<2 + \a[ SH\a[3] ]<<3 +
              \a[ SH\a[4] ]<<4 + \a[ SH\a[5] ]<<5 + \a[ SH\a[6] ]<<6 + \a[ SH\a[7] ]<<7
      EndWith    
      
      ProcedureReturn val & $FF
      
    CompilerEndIf    
  EndProcedure

  Procedure.u BitShuffle16(WordVal.u, *ShuffleMask.TBitField16)
  ; ============================================================================
  ; NAME: BitShuffle16
  ; DESC: Shuffles 16 Bits in a Word acording to the ShuffleMask
  ; DESC: The ShuffleMask is an '16 Byte Array' with the Bitpositons to take from!
  ; DESC: #BIT_SHF_REVERSE_16_hi = $0001020304050607
  ; DESC: #BIT_SHF_REVERSE_16_lo = $08090A0B0C0D0E0F reverses the Bitorder
  ; DESC: the lowest Byte of this Shufflemask is $0F what means the OutBitPosition[0]
  ; DESC: will be filled with the Bit[15] of the input ...
  ; DESC: To create the ShuffleMask you have use the TBitField16 Structure
  ; DESC: Which produce the 2 Quads from 16 Bytes!
  ; VAR(WordVal) : The Byte to shuffle
  ; VAR(*ShuffleMask.TBitField16) : The shuffle mask as TBitField16 Byte&Quad-Array
  ; RET.u : the suffled unsigned Word Value
  ; ============================================================================
    
    CompilerIf #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM64
        
      ; Used Registers:
      ;   RAX : operating Register
      ;   RCX : Shuffeld Bytes
      ;   RDX : [filt]
      ;   R8  : operating Register
      ;   R9  : -
      ;   XMM0 : operation Register
      ;   XMM1 : ByteVal shuffled to all Bytes
      ;   XMM2 : [mask]    
      ;   XMM3 : [filt]
      ;   XMM4 : ShuffleMask
      
      ; How to shuffle Bits! Example for Byteval = 7
      ; first we load the '7' to XMM-Register than Shuffle the '7' to all Bytes of XMM
      ; so we get for the lo 8 Bytes in XMM: (and the same for the 8 hi Bytes!)
      
      ; Byte value    .. | 0F | 0F | 0F | 0F | 0F | 0F | 0F | 0F | Byte shuffled to all Bytes
      ; AND Mask      .. | 80 | 40 | 20 | 10 | 08 | 04 | 02 | 01 | this filters Bit 15..0
      ; ---------------------------------------------------------
      ; Result        .. | 00 | 00 | 00 | 00 | 00 | 04 | 02 | 01 | here we get the mask if Bit was 1
      ; ---------------------------------------------------------    
      ; Compare with Mask| 00 | 00 | 00 | 00 | 00 | FF | FF | FF |
      ; AND filt      .. | 01 | 01 | 01 | 01 | 01 | 01 | 01 | 01 |
      ; ---------------------------------------------------------    
      ; Bool results  .. | 00 | 00 | 00 | 00 | 00 | 01 | 01 | 01 |  Thats the BitFild.a()
      
      ; for ASM 16Bit Shuffle we have to change the 8 Byte MOVQ to 16 Byte MOVDQU (doubleQuad unaligned)
      !MOVDQU XMM2, [mask]        ; XMM2 = [mask]   ; load 16 Bytes from DataSection
      !MOVDQU XMM3, [filt]        ; XMM3 = [filt]   ; load 16 Bytes from DataSection
      !MOVQ RDX, XMM3             ; RDX =  [filt]
      !PXOR XMM0, XMM0            ; XMM0 = 0
       
      !MOVZX RAX, WORD[p.v_WordVal] ; load with zero expand to full Register size
      !MOVQ XMM1, RAX             ; XMM1 = ByteVal
      !PSHUFW XMM1, XMM0          ; loWord to all Words
       
      !MOV RAX, [p.p_ShuffleMask] ; RAX = *ShuffleMask
      !MOVQU XMM4, [RAX]          ; XMM4 = ShuffleMask, 16Bytes
      !MOVQU XMM0, [limF]         ; XMM0 = [limF]-Mask
      !PAND XMM4, XMM0            ; limit each Byte in ShuffleMask to 7
      
      !PAND XMM1, XMM2            ; Filter Bit[0..7] from Byte
      !PCMPEQB XMM1, XMM2         ; compare with mask ->  Byte[0..7] = Bit[0..7]
      !PSHUFB XMM1, XMM4          ; Shuffle the Bytes containing the BitValues
      !MOVLPS RCX, XMM1           ; transfer shuffled 8 lo bytes back to RCX
      !MOVHPS R8, XMM1            ; transfer shuffled 8 hi bytes back to R8
      !PEXT R8, R8, RDX           ; extract lo Bit from 8 hi Bytes and compact it to a Byte in R8
      !PEXT RAX, RCX, RDX         ; extract lo Bit from 8 lo Bytes and compact it to a Byte in RAX
      !SHL R8, 8                  ; Shift left lo to hi
      !OR RAX, R8                 ; connect hi and lo in RAX
      ProcedureReturn             ; RAX contians shuffeld 16 Bits
      
;       DataSection
;         ; Attention: FASM nees a leading 0 for hex values
;         ; 16 Byte Mask to be prepared for 16 Bit Shuffle too
;         !mask:  dq 08040201008040201h   ; mask to filter in each byte 1 Bit higher
;         !filt:  dq 00101010101010101h   ; Filter to creat BOOLs with value 1
;         !lim:   dq 00F0F0F0F0F0F0F0Fh   ; Limit Mask for ShuffleMask 
;       EndDataSection
    
    CompilerElse
      
      Protected BF.TBitField16, SH.TBitField16 
      Protected val 
      
      SH\q[0] = *ShuffleMask\q[0] & $0F0F0F0F0F0F0F0F ; limit all Bytes in the ShuffleMask to F
      SH\q[1] = *ShuffleMask\q[1] & $0F0F0F0F0F0F0F0F ; limit all Bytes in the ShuffleMask to F
      
      ; convert Byte to BitField
      With BF
           val = WordVal & $FF        ; lo Byte
            \q[0] = (val &1)         + ((val>>1)&1)<<8  + ((val>>2)&1)<<16 + ((val>>3)&1)<<24 +
                    ((val>>4)&1)<<32 + ((val>>5)&1)<<40 + ((val>>6)&1)<<48 + ((val>>7)&1)<<56    
            
            val = (WordVal >> 8) & $FF ; hi Byte
            \q[1] = (val &1)         + ((val>>1)&1)<<8  + ((val>>2)&1)<<16 + ((val>>3)&1)<<24 +
                    ((val>>4)&1)<<32 + ((val>>5)&1)<<40 + ((val>>6)&1)<<48 + ((val>>7)&1)<<56    
      EndWith       
      
      ; convert BitField with shuffling back to a Byte value
      With BF
        val = \a[ SH\a[0] ]     + \a[ SH\a[1] ]<<1  + \a[ SH\a[2] ]<<2   + \a[ SH\a[3] ]<<3 +
              \a[ SH\a[4] ]<<4  + \a[ SH\a[5] ]<<5  + \a[ SH\a[6] ]<<6   + \a[ SH\a[7] ]<<7 +
              \a[ SH\a[8] ]<<8  + \a[ SH\a[9] ]<<9  + \a[ SH\a[10] ]<<10 + \a[ SH\a[11] ]<<11 +
              \a[ SH\a[12] ]<<12+ \a[ SH\a[13] ]<<13+ \a[ SH\a[14] ]<<14 + \a[ SH\a[15] ]<<15             
      EndWith
      
      ProcedureReturn val & $FFFF
      
    CompilerEndIf 
  EndProcedure
  
  ;- DataSection for BitShuffle8 and BitShuffle16
  CompilerIf #PbFwCfg_Module_Compile = #PbFwCfg_Module_Compile_ASM64
    DataSection
    ; Attention: FASM nees a leading 0 for hex values
    ; 16 Byte Mask to be prepared for 16 Bit Shuffle too
    ; dq : define quad
    !mask:  dq 08040201008040201h   ; mask to filter in each byte 1 Bit higher
    !filt:  dq 00101010101010101h   ; Filter to create BOOLs with value 1
    !lim7:  dq 00707070707070707h   ; Limit Mask 7 for ShuffleMask 
    !limF:  dq 00F0F0F0F0F0F0F0Fh   ; Limit Mask F for ShuffleMask 
    EndDataSection
  
  CompilerEndIf
  
  Procedure.i BitCount16 (value.u)
  ; ======================================================================
  ;  NAME: BitCount16
  ;  DESC: Counts the number of Hi bits in a 16 Bit value
  ;  RET.i:  Number of Hi Bits
  ; ====================================================================== 
    
    CompilerSelect #PbFwCfg_Module_Compile
       ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on! 
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !xor    eax, eax
        !mov    ax, word [p.v_value]
        !popcnt ax, ax
        ProcedureReturn
     
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !xor    rax, rax
        !mov    ax, word [p.v_value]
        !popcnt ax, ax
        ProcedureReturn       
        
      CompilerCase #PbFwCfg_Module_Compile_C
        ; mac_BitCount16(value)
        ; __builtin_popcountl(long number);
        !return __builtin_popcountl(v_value & $FFFF);
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
        mac_BitCount16(value)
        
    CompilerEndSelect   
  EndProcedure
  
  Procedure.i BitCount32 (value.l)
  ; ======================================================================
  ;  NAME: BitCount32
  ;  DESC: Counts the number of Hi bits in a 32 Bit value
  ;  RET.i: Number of Hi Bits 
  ; ====================================================================== 
         
    CompilerSelect #PbFwCfg_Module_Compile
      ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on!         
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !mov    eax, dword [p.v_value]
        !popcnt eax, eax
       ProcedureReturn
       
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !xor    rax, rax
        !mov    eax, dword [p.v_value]
        !popcnt eax, eax
       ProcedureReturn
           
      CompilerCase #PbFwCfg_Module_Compile_C
        ; mac_BitCount32(value)
        ; __builtin_popcountl(long number);
        !return __builtin_popcountl(v_value);
      CompilerDefault     ; Classic Code without ASM or C optimations       
        mac_BitCount32(value)
        
    CompilerEndSelect
  EndProcedure
  
  Procedure.i BitCount64 (value.q)
  ; ======================================================================
  ;  NAME: BitCount64
  ;  DESC: Counts the number of Hi bits in a 64 Bit value
  ;  RET.i: Number of Hi Bits
  ; ======================================================================     
    
    CompilerSelect #PbFwCfg_Module_Compile
       ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on!   
      CompilerCase #PbFwCfg_Module_Compile_ASM32  ; at x32 programms we must do 2x32Bit POPCNT and ADD
        !lea ecx, [p.v_value]
        !mov edx, dword [ecx]         ; load hi 32 Bits to EDX-Register
        !mov eax, dword [ecx +4]      ; load lo 32 Bits to EAX-Register
        !popcnt edx, edx              ; count Hi-Bits in EDX
        !popcnt eax, eax              ; count Hi-Bits in EAX
        !add eax, edx                 ; Add the 2 values
        ProcedureReturn
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rax, qword [p.v_value]
        !popcnt rax, rax
        ProcedureReturn
               
      CompilerCase #PbFwCfg_Module_Compile_C
        ; mac_BitCount64(value)
        ;__builtin_popcountll(long long number)
        !retrun __builtin_popcountll(v_value)  
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
        mac_BitCount64(value)
        
    CompilerEndSelect
  EndProcedure
  
  Procedure.i BitCountINT (value.i)
  ; ======================================================================
  ;  NAME: BitCountINT
  ;  DESC: Counts the number of Hi bits in an INT 32/64 Bit 
  ;  RET.i: Number of Hi Bits
  ; ======================================================================     
    
    CompilerSelect #PbFwCfg_Module_Compile
       ; popcnt was introduced with the Intel MMX Extention, at AMD from K10 on!   
      CompilerCase #PbFwCfg_Module_Compile_ASM32  ; at x32 programms we must do 2x32Bit POPCNT and ADD
        !mov    eax, dword [p.v_value]
        !popcnt eax, eax
        ProcedureReturn
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rax, qword [p.v_value]
        !popcnt rax, rax
        ProcedureReturn
               
      CompilerCase #PbFwCfg_Module_Compile_C
        ; mac_BitCount64(value)
        ;__builtin_popcountll(long long number)
        !retrun __builtin_popcountll(v_value)  
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
         CompilerIf SizeOf(Integer) = 8
          mac_BitCount64(value)
        CompilerElse
          mac_BitCount32(value)
        CompilerEndIf
       
    CompilerEndSelect
  EndProcedure

  Procedure.u BSWAP16(value.u)
  ; ======================================================================
  ;  NAME: BSWAP16
  ;  DESC: LittleEndian<=>BigEndian conversion for 16Bit values
  ;  DESC: Swaps the Bytes of a 16 Bit value
  ;  VAR(value.u): 16-Bit-Word value
  ;  RET.u: Byte swapped 16-Bit value
  ; ====================================================================== 
    
    CompilerSelect #PbFwCfg_Module_Compile
       
    CompilerCase #PbFwCfg_Module_Compile_ASM32
      !xor eax, eax
      !mov ax, word [p.v_value]
      !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
      ProcedureReturn
      
    CompilerCase #PbFwCfg_Module_Compile_ASM64
      !xor rax, rax
      !mov ax, word [p.v_value]
      !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
      ProcedureReturn
     
    CompilerCase #PbFwCfg_Module_Compile_C
      !return __builtin_bswap16(v_value);
      ProcedureReturn
      
    CompilerDefault     ; Classic Code without ASM or C optimations       
      Protected *Swap.pSwap
      *Swap = @value
      Swap *Swap\a[0], *Swap\a[1]
      ProcedureReturn value
     
    CompilerEndSelect      
  EndProcedure
  
  Procedure.l BSWAP32(value.l)
  ; ======================================================================
  ;  NAME: BSWAP32
  ;  DESC: LittleEndian<=>BigEndian conversion for 32Bit values
  ;  DESC: Swaps the Bytes of a 32 Bit value
  ;  VAR(value.l): 32-Bit-Long value
  ;  RET.l:  Byte swapped 32-Bit value
  ; ====================================================================== 
  
    CompilerSelect #PbFwCfg_Module_Compile
         
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !mov eax, dword [p.v_value]
        !bswap eax
        ProcedureReturn   
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !xor rax, rax
        !mov eax, dword [p.v_value]
        !bswap eax
        ProcedureReturn    
        
      CompilerCase #PbFwCfg_Module_Compile_C
        !return __builtin_bswap32(v_value);
        
      CompilerDefault     ; Classic Code without ASM or C optimations       
        Protected *Swap.pSwap
        *Swap = @value
        Swap *Swap\a[0], *Swap\a[3]
        Swap *Swap\a[1], *Swap\a[2]
        
    CompilerEndSelect     
  EndProcedure
  
  Procedure.q BSWAP64(value.q)
  ; ======================================================================
  ;  NAME: BSWAP64
  ;  DESC: LittleEndian<=>BigEndian conversion for 64Bit values
  ;  DESC: Swaps the Bytes of a 64 Bit value
  ;  DESC: direct in memory.
  ;  VAR(*Mem): Pointer to the value
  ;  RET:  -
  ; ======================================================================   
    
    CompilerSelect #PbFwCfg_Module_Compile
       
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !lea ecx, [p.v_value]   ; load effective address of value (:= @value)
        !mov edx, dword [ecx]
        !mov eax, dword [ecx +4]
        !bswap edx
        !bswap eax
        ProcedureReturn         ; 64Bit Return use EAX and EDX Register
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rax, qword [p.v_value]
        !bswap rax
        ProcedureReturn
        
      CompilerCase #PbFwCfg_Module_Compile_C
        !return __builtin_bswap64(v_value);
       
      CompilerDefault     ; Classic Code without ASM or C optimations       
        Protected *Swap.pSwap
        *Swap = @value
        Swap *Swap\a[0], *Swap\a[7]
        Swap *Swap\a[1], *Swap\a[6]
        Swap *Swap\a[2], *Swap\a[5]
        Swap *Swap\a[3], *Swap\a[4]
        ProcedureReturn value
        
    CompilerEndSelect  
   EndProcedure
   
  Procedure.i BSWAP128(*Value.Int128, *Out.Int128 = 0)  
  ; ======================================================================
  ;  NAME: BSWAP128
  ;  DESC: LittleEndian<=>BigEndian conversion for 128 Bit values
  ;  DESC: Swaps the Bytes of a 128 Bit value
  ;  DESC: direct in memory or return it in *Out
  ;  DESC: Code from: https://www.purebasic.fr/english/viewtopic.php?t=77563
  ;  VAR(*Value): Pointer to the value
  ;  VAR(*Out): Pointer to the optional RetrurnValue  
  ;             If *Out = 0 Then Swap directly in *Value
  ;             Else Return swaped value in *Out (don't touch Value)
  ;  RET: *Out
  ; ======================================================================   
    
    DBG::mac_CheckPointer(*Value)    ; Check Pointer Exception
    
    Protected low.q = *Value\l  
    Protected high.q = *Value\h 

    CompilerSelect #PbFwCfg_Module_Compile
      ; ASM Code from PB-Forum 
      CompilerCase #PbFwCfg_Module_Compile_ASM32
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
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rdx,[p.v_high] 
        !mov rax,[p.v_low] 
        !bswap rax 
        !bswap rdx 
        !mov [p.v_low],rax 
        !mov [p.v_high],rdx 
        
      CompilerCase #PbFwCfg_Module_Compile_C
        !v_high = __builtin_bswap64(v_high);
        !v_low  = __builtin_bswap64(v_low);
     
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

    CompilerSelect #PbFwCfg_Module_Compile
         
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !mov ecx, [p.p_Mem]       ; load pointer to ECX
        !xor eax, eax
        !mov ax, word [ecx]       ; load value, (content of pointer)
        !xchg al, ah              ; for 16 Bit ByteSwap it's the Exchange command 
        ; !rol ax, 8  ; alternative way with RotateLeft 8Bit
        !mov word [ecx], ax
        ; ProcedureReturn ; do not Return
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rcx, [p.p_Mem]
        !xor rax, rax
        !mov ax, word [rcx]
        !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
        ; !rol ax, 8  ; alternative way with RotateLeft 8Bit
        !mov word [rcx], ax          
        ; ProcedureReturn ; do not Return
        
      CompilerCase #PbFwCfg_Module_Compile_C
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
    
    CompilerSelect #PbFwCfg_Module_Compile
           
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !mov ecx, [p.p_Mem]
        !mov eax, dword [ecx]
        !bswap eax
        !mov dword [ecx], eax
        ; ProcedureReturn ; do not Return
        
     CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rcx, [p.p_Mem]
        !movzx rax, dword [rcx]   ; move with zero expand to full register
        !bswap eax
        !mov dword [rcx], eax
        ; ProcedureReturn ; do not Return
        
     CompilerCase #PbFwCfg_Module_Compile_C
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
    
    CompilerSelect #PbFwCfg_Module_Compile
         
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !mov ecx, [p.p_Mem]
        !mov edx, dword [ecx]
        !mov eax, dword [ecx +4]
        !bswap edx
        !bswap eax
        !mov dword [ecx + 4], edx
        !mov dword [ecx], eax
        ; ProcedureReturn ; do not Return
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rcx, [p.p_Mem]
        !mov rax, qword [rcx]
        !bswap rax
        !mov qword [rcx], rax
        ; ProcedureReturn ; do not Return
        
      CompilerCase #PbFwCfg_Module_Compile_C
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
        
    CompilerSelect #PbFwCfg_Module_Compile
        
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !mov ecx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov eax, dword [p.v_value] 
        !rol eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rcx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov rax, dword [p.v_value] 
        !rol eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #PbFwCfg_Module_Compile_C
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
        
    CompilerSelect #PbFwCfg_Module_Compile
        
      CompilerCase #PbFwCfg_Module_Compile_ASM32
        !mov ecx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov eax, dword [p.v_value] 
        !ror eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
     
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rcx, dword [p.v_cnt]   ; move NoOfBits to rotated in C-Register
        !mov rax, dword [p.v_value] 
        !ror eax, cl                ; Rotate use only the lo 8 Bits of C-Register
        ProcedureReturn
        
      CompilerCase #PbFwCfg_Module_Compile_C
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
      
    CompilerSelect #PbFwCfg_Module_Compile
        
      ; CompilerCase #PbFwCfg_Module_Compile_ASM32
        ; use Default Code
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rcx, qword [p.v_cnt]
        !mov rax, qword [p.v_value]
        !rol rax, cl
        ProcedureReturn
     
      CompilerCase #PbFwCfg_Module_Compile_C
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
            
    CompilerSelect #PbFwCfg_Module_Compile
        
      ; CompilerCase #PbFwCfg_Module_Compile_ASM32
        ; use Default Code
        
      CompilerCase #PbFwCfg_Module_Compile_ASM64
        !mov rcx, qword [p.v_cnt]
        !mov rax, qword [p.v_value]
        !ror rax, cl
        ProcedureReturn
     
      CompilerCase #PbFwCfg_Module_Compile_C
        ProcedureReturn  (value >> cnt) | (value << (64-cnt))
       
      CompilerDefault     ; Classic Code without ASM or C optimations       
        ProcedureReturn  (value >> cnt) | (value << (64-cnt))
        
    CompilerEndSelect
  EndProcedure
  
  ;- ----------------------------------------------------------------------
;- MSB LSB - not ready  
  Procedure.i MSB(x.i)
    ; Number of most significant bit: [0..63]
    !MOV RAX, [p.v_x]
    !BSR RAX, RAX
    ProcedureReturn
  EndProcedure
  
  Procedure.i LSB(x.i)
    ; Number of least significant bit: [0..63]
    !MOV RAX, [p.v_x]
    !BSF RAX, RAX
    ProcedureReturn
  EndProcedure

;   Debug MSB(0)
;   Debug MSB(1)
;   Debug MSB(2)
;   Debug MSB(3)
;   Debug MSB(4)
;   Debug MSB(8)
;   Debug MSB(16)

EndModule

CompilerIf #PB_Compiler_IsMainFile    
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------

  EnableExplicit
  UseModule Bit
  
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
  
  Procedure Test_BitCount()
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

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 399
; FirstLine = 364
; Folding = ---------
; Optimizer
; EnableXP
; CPU = 5