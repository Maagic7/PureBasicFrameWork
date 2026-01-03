; ===========================================================================
;  FILE : PbFw_Module_Hash.pb
;  NAME : Module Hash::
;  DESC : Implements Standard Hash Functions in a Modul
;  DESC :
;  SOURCE : https://rurban.github.io/smhasher/doc/ryzen3.html
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2025/12/27
; VERSION  :  0.5 untested Developer Version
; COMPILER :  PureBasic 6.0+
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{ 2025/12/31 Changed C-Backend implementation from PB-Code to dirct C-implementation 
;  2025/12/27 changed from PB-Include-File To Module implementation
;             added a PB implementation to work in ASM and C-Backend 
;}
;{ TODO:
;}
; ============================================================================


;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
; XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

DeclareModule Hash
  EnableExplicit
  
  Declare.q FNV64(*buf, lenB)
  
  Prototype.q FNV64s(String$, *outLength.Integer=0)
  Global FNV64s.FNV64s
  
  CompilerIf  #PB_Compiler_Backend = #PB_Backend_C
    ; https://www.purebasic.fr/english/viewtopic.php?p=644541&hilit=Fasthash64#p644541
    PrototypeC.q FastHash64(*buf, lenB.i, seed.i=0)  ; Prototype function  
  CompilerElse
    Prototype.q FastHash64(*buf, lenB.i, seed.i=0)   ; Prototype function
  CompilerEndIf
  Global FastHash64.FastHash64                ; Global var for Prototype 
  
  Declare.q FastHash64_PB(*Buffer, lenB.i, Seed.i=0)

EndDeclareModule

Module Hash
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- FNV (Fowler–Noll–Vo) hash function
  ;- ----------------------------------------------------------------------
  
  Procedure.q FNV64(*buf, lenB)
  ; ============================================================================
  ; NAME: FNV64
  ; DESC: Calculates the 64 Bit FNV-1a hash of a Buffer
  ; DESC: https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
  ; VAR(*buf): Pointer to Data Buffer
  ; VAR(lenB): length in Byte
  ; RET.i : Hash value
  ; ============================================================================
    
  ; algorithm fnv-1a is
  ;   hash := FNV_offset_basis
  ; 
  ;   For each byte_of_data To be hashed do
  ;     hash := hash XOr byte_of_data 
  ;     hash := hash × FNV_prime
  ;   return hash 
    
    Protected hash.q = $CBF29CE484222325
    Protected *pRead.Ascii = *buf
    Protected *pEnd = *buf + lenB
    
    While *pRead < *pEnd
      hash = (hash ! *pRead\a) * 1099511628211
      *pRead + 1   
    Wend
    
    ProcedureReturn hash
  EndProcedure
  
  Procedure.q _FNV64s(*String, *outLength.Integer=0)
  ; ============================================================================
  ; NAME: FNV64s
  ; DESC: Calculates the 64 Bit FNV-1a hash of a String
  ; DESC: Attention: the FNV64s for Unicode Strings differs from FNV64
  ; VAR(*String): The String Pointer
  ; VAR(*outLength.Integer): Optional a Pointer to an Int to receive the Length
  ; RET.i : Hash value
  ; ============================================================================
    
    Protected hash.q = $CBF29CE484222325
    Protected *pRead.Character = *String
    
    While *pRead\c
      hash = (hash ! *pRead\c) * 1099511628211
      *pRead + SizeOf(Character)
    Wend
    
    If *outLength
      *outLength\i = (*pRead - *String)/SizeOf(Character)
    EndIf
    
    ProcedureReturn  hash
  EndProcedure
  FNV64s=@_FNV64s()    ; Bind Procedure Address to Prototype

  ;- ----------------------------------------------------------------------
  ;- FastHash
  ;- ----------------------------------------------------------------------
    
  ; FastHash64 algorithm by Zilong Tan
  ; FastHash64 (x64)
  ; uint64_t fasthash64(const void *buf, size_t len, uint64_t seed) { 
  
  ; #define mix(h) ({				      	  \
  ; 		(h) ^= (h) >> 23;		          \
  ; 		(h) *= 0x2127599bf4325c37ULL;	\
  ; 		(h) ^= (h) >> 47; })
  
  ; 	const uint64_t    m = 0x880355f21e6d1965ULL;
  ; 	const uint64_t *pos = (const uint64_t *)buf;
  ; 	const uint64_t *End = pos + (len / 8);
  ; 	const unsigned char *pos2;
  ; 	uint64_t h = seed ^ (len * m);
  ; 	uint64_t v;
  ; 
  ; 	While (pos != End) {
  ; 		v  = *pos++;
  ; 		h ^= mix(v);
  ; 		h *= m; 
  ;    }
  ; 	pos2 = (const unsigned char*)pos;
  ; 	v = 0;
  ; 
  ; 	switch (len & 7) {
  ; 	Case 7: v ^= (uint64_t)pos2[6] << 48;
  ; 	Case 6: v ^= (uint64_t)pos2[5] << 40;
  ; 	Case 5: v ^= (uint64_t)pos2[4] << 32;
  ; 	Case 4: v ^= (uint64_t)pos2[3] << 24;
  ; 	Case 3: v ^= (uint64_t)pos2[2] << 16;
  ; 	Case 2: v ^= (uint64_t)pos2[1] << 8;
  ; 	Case 1: v ^= (uint64_t)pos2[0];
  ; 		h ^= mix(v);
  ; 		h *= m;
  ; 	} 
  ; 	Return mix(h);
  ; } 
  
  Macro _mac_FastHash_PB_Mix(_h)
    _h = (_h>>23 &#_MaskShr23) ! _h *$2127599bf4325c37
    _h = (_h>>47 &#_MaskShr47) ! _h
  EndMacro

  Procedure.q FastHash64_PB(*Buffer, lenB.i, Seed.i=0)
  ; ============================================================================
  ; NAME: FastHash64_PB
  ; DESC: FastHash64 in PB Syntax
  ; VAR((*Buffer) : Pointer to Data Buffer
  ; VAR(lenB) : Length of Data in Bytes 
  ; VAR(Seed) : Start value for hash
  ; RET.q : The hash
  ; ============================================================================
    
    ; in ASM-Backend the PB-Code version is slow, but in C-Backend it is same speed as the ASM-Version 
    
    Protected.q hash, v
    Protected.i n
    Protected *pRead.Quad
    
    #_fh_m = $880355f21e6d1965
    #_MaskShr23 = $1FFFFFFFFFF  ; 41 Bit 
    #_MaskShr47 = $1FFFF        ; 17 Bit
     
    *pRead = *Buffer
    hash = (lenB * #_fh_m) ! Seed
    
    n = lenB >> 3  
    Debug "8-ByteBlocks = " + n
    While n
      v = *pRead\q
      _mac_FastHash_PB_Mix(v)
      hash = (hash ! v) * #_fh_m
      *pRead + 8
      n - 1
    Wend
    
    n = lenB &7
    Debug "RestBytes = " + n
    If n
      v = 0 
      While n
        n-1
        v = (v<<8)
        v = v | PeekA(*pRead+n) ; because of little endian, we have to read the last Byte first
      Wend
      _mac_FastHash_PB_Mix(v)
      hash = (hash ! v) * #_fh_m
    EndIf
    
    _mac_FastHash_PB_Mix(hash) 
    
    ProcedureReturn hash
  EndProcedure
  ; FastHash64=@_FastHash64_PB()    ; now in C-Backend we use the direct C implementation by idle

  CompilerIf  #PB_Compiler_Backend = #PB_Backend_C
    ; https://www.purebasic.fr/english/viewtopic.php?p=644541&hilit=Fasthash64#p644541
    ; by idle
    ;prefix local parameters p_ pointer v_ variables 
    !integer fasthash64_c(integer p_buf,integer v_len,integer v_seed) {
    ! typedef unsigned long long uint64_t; 
    ! #define mix(h) ({				      	  \
    ! 			(h) ^= (h) >> 23;		          \
    ! 			(h) *= 0x2127599bf4325c37ULL;	\
    ! 			(h) ^= (h) >> 47; })
    ! 	const uint64_t m = 0x880355f21e6d1965ULL;
    ! 	const uint64_t *pos = (const uint64_t *)p_buf;
    ! 	const uint64_t *end = pos + (v_len / 8);
    ! 	const unsigned char *pos2;
    ! 	uint64_t h = v_seed ^ (v_len * m);
    ! 	uint64_t v;
    !  uint64_t result; 
    ! 	while (pos != end) {
    ! 		v  = *pos++;
    ! 		h ^= mix(v);
    ! 		h *= m;
    ! 	}
    ! 	pos2 = (const unsigned char*)pos;
    ! 	v = 0;
    ! 	switch (v_len & 7) {
    ! 	case 7: v ^= (uint64_t)pos2[6] << 48;
    ! 	case 6: v ^= (uint64_t)pos2[5] << 40;
    ! 	case 5: v ^= (uint64_t)pos2[4] << 32;
    ! 	case 4: v ^= (uint64_t)pos2[3] << 24;
    ! 	case 3: v ^= (uint64_t)pos2[2] << 16;
    ! 	case 2: v ^= (uint64_t)pos2[1] << 8;
    ! 	case 1: v ^= (uint64_t)pos2[0];
    ! 		h ^= mix(v);
    ! 		h *= m;
    ! 	}
    ! 	return mix(h);
    ! } 
  
    ;assign C function address to prototype 
    ;Attention because we are in a Module, PB add a Prefix ModuleName+X+g+VariableName
    ;if the Modulename change, we have to change the varibale name too!
    ;g_fasthash64 = &fasthash64c;  
    !hashXg_fasthash64 = &fasthash64_c;  
    
  CompilerElse
  
    ;   ! #define mix(h) ({				      	  \
    ;   ! 			(h) ^= (h) >> 23;		          \
    ;   ! 			(h) *= 0x2127599bf4325c37ULL;	\
    ;   ! 			(h) ^= (h) >> 47; })
    
    Macro _mac_FastHash_ASM_Mix(_REG1, _REG2)
      !MOV _REG2, _REG1
      !SHR _REG2, 23
      !XOR _REG1, _REG2     ; (h) ^= (h) >> 23	
      !IMUL _REG1, R10      ; (h) *= 0x2127599bf4325c37
      !MOV _REG2, _REG1
      !SHR _REG2, 47
      !XOR _REG1, _REG2     ; (h) ^= (h) >> 47
    EndMacro
    
    Procedure.q _FastHash64_ASM(*Buffer, lenB.i, Seed.i=0)
    ; ============================================================================
    ; NAME: FastHash64_ASM
    ; DESC: FastHash64 in x64 Assembler
    ; VAR((*Buffer) : Pointer to Data Buffer
    ; VAR(lenB) : Length of Data in Bytes 
    ; VAR(Seed) : Start value for hash
    ; RET.q : The hash
    ; ============================================================================
       
      ; Used Registers:
      ;   RAX : Mix(v1) REG1
      ;   RCX : Loop counter
      ;   RDX : hash
      ;   R8  : Mix(v1) REG2
      ;   R9  : *Buffer
      ;   R10 : 0x2127599bf4325c37
      ;   R11 : 0x880355f21e6d1965
      
      ;   R12..R15 : 'non volatile'
      
      ; R10:R11 	Volatile, must be preserved as needed by caller; used in syscall/sysret instructions
      ; because we are in a Procedure and do not use system funcitons, we don't have to preserve R10,R11
      
      !MOV R10, 0x2127599bf4325c37
      !MOV R11, 0x880355f21e6d1965  ; m
      
      !XOR RAX, RAX
      !MOV R9, [p.p_Buffer]         ; Pointer Data
      !TEST R9, R9
      !JZ .err                      ; If *Buffer = 0 Then Goto .err
      
      ; --------------------------------------------------
      ; h = v_seed ^ (v_len * m) 
      !MOV RCX, [p.v_lenB]
      !MOV RAX, RCX         ; RAX = lenB
      !IMUL RAX, R11        ; RAX = lenB * m
      !MOV R8, [p.v_Seed]
      !XOR RAX, R8          ; RAX = Seed ! (len *m)
      !MOV RDX, RAX         ; save it as hash start value  
      ; --------------------------------------------------
      ; // Process all 8 Byte Blocks!
      ;	While (pos != End) {
      ;		v  = *pos++;
      ;		h ^= mix(v);
      ;		h *= m;
      ;	}
      
      !SHR RCX, 3           ; Check for No of 8 Byte Blocks
      !JZ .rest             ; If 0 Then Goto check rest bytes 
        !@@:                ; Repeat
          !MOV RAX, [R9]      ; load 8 Bytes -> v
          _mac_FastHash_ASM_Mix(RAX, R8)   ; RAX = mix(v)
          !XOR RDX, RAX       ; h = h ! mix(v)
          !IMUL RDX, R11      ; h * 0x880355f21e6d1965     
          !ADD R9, 8          ; Address Pointer to next 8 Bytes
        !Loop @b            ; Until NoOf_8_Byteblocks in RCX = 0 
      ; --------------------------------------------------   
      !.rest:
      ; Read final Bytes in reverse order (Little Endian!) 
      ;   switch (v_len & 7) {
      ;    	case 7: v ^= (uint64_t)pos2[6] << 48;
      ;    	case 6: v ^= (uint64_t)pos2[5] << 40;
      ;    	case 5: v ^= (uint64_t)pos2[4] << 32;
      ;    	case 4: v ^= (uint64_t)pos2[3] << 24;
      ;    	case 3: v ^= (uint64_t)pos2[2] << 16;
      ;    	case 2: v ^= (uint64_t)pos2[1] << 8;
      ;    	case 1: v ^= (uint64_t)pos2[0];
      
      !MOV RCX, [p.v_lenB]
      !AND RCX, 7           ; Rest Bytes 0..7
      !JZ .return
        !XOR RAX, RAX         ; RAX = 0
        ; Little Endian => Read last Byte first! It's the upper Part of Value
        !DEC R9               ; Because Pointer = R9+(LenB &7)-1
        !@@:                  ; Loop loading final Bytes
          !SHL RAX, 8
          !MOV AL, BYTE[R9+RCX]
        !LOOP @b  
        ; now RAX contains the final Bytes  
        ; -------------------------------------------------- 
        ; h ^= mix(v);
        ; h *= m;
        _mac_FastHash_ASM_Mix(RAX, R8)     ; RAX = Mix(RAX)
        !XOR RDX, RAX         ; h = h ! mix(v)
        !IMUL RDX, R11        ; h * 0x880355f21e6d1965
        ; --------------------------------------------------  
      !.return:
      ;  return mix(h) 
      !MOV RAX, RDX
      _mac_FastHash_ASM_Mix(RAX, R8)
      !.err:      ; Return RAX=0
      ProcedureReturn  
    EndProcedure
    FastHash64 = @_FastHash64_ASM()
  CompilerEndIf
 
EndModule

CompilerIf  #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  UseModule Hash
  
  Define Backend$
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
    Backend$ = "ASM - Backend"  
  CompilerElse
     Backend$ = "C - Backend"     
  CompilerEndIf
   
  Debug Backend$ 
  Debug ""
  
  Define txt$ = " I'm a simple text to Test Hash Functions!.," 
  Define len = Len(txt$)
  Define lenB = StringByteLength(txt$)
  Define *Data = @txt$
  Define hash
  Debug "StringByteLength = " + Str(lenB)
  
  Define lStr
  
  Debug "Text to hash = " + txt$
  Debug "------------------------------"
  Debug "  FNV Hash"
  Debug "------------------------------"
  hash = FNV64(*Data, lenB)
  Debug "bytewise      = " + Hex(hash)
  
  hash = FNV64s(txt$)
  Debug "characterwise = " + Hex(hash)
  
  Debug ""
  Debug "------------------------------"
  Debug "  FastHash64"
  Debug "------------------------------"
 
  hash = FastHash64(*Data, lenB)
  Debug "FastHash    = " + Hex(hash)
  
  hash = FastHash64_PB(*Data, lenB)
  Debug "FastHash_PB = " + Hex(hash)

 
  CompilerIf #PB_Compiler_Debugger = 0
    Define I, t1,t2,t3, t4
    #Loops = 1000000 * 1
    
    Global Dim aryTxt.s(#Loops)
    For I = 0 To #Loops
      aryTxt(I) = txt$
      If lenB <> StringByteLength(aryTxt(I))
        MessageRequester("Error at", Str(I))
      EndIf
      
    Next
    
    hash = FNV64s(txt$)
    t1 = ElapsedMilliseconds()
      For I = 0 To #Loops
        hash = FNV64s(aryTxt(I))
      Next
    t1 = ElapsedMilliseconds() - t1
    
    hash = FastHash64(*data, lenB, 0)
    t2 = ElapsedMilliseconds()
      For I = 0 To #Loops
        ; hash = FastHash64(@aryTxt(I), StringByteLength(aryTxt(I)), 0)
        ; lenB = StringByteLength(aryTxt(I))
        hash = FastHash64(@aryTxt(I), lenB, 0)
      Next
    t2 = ElapsedMilliseconds() - t2
                    
    OpenConsole()
    PrintN(Backend$)
    PrintN("")
    PrintN("FNV64 Hash ms       = " +Str(t1))
    PrintN("Fast Hash ms        = " +Str(t2))
    PrintN("")
    PrintN("press a key to exit")
    Input()
  
  CompilerEndIf

CompilerEndIf
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 264
; FirstLine = 214
; Folding = ---
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.21 - C Backend (Windows - x64)