; ===========================================================================
;  FILE : PbFw_Module_CPU.pb
;  NAME : Purebasic FrameWork Module CPU [CPU::]
;  DESC : CPU indentification und Featuer Flags
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/08
; VERSION  :  0.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;             
; ============================================================================

; Check CPUID SSE-Flags  https://wiki.osdev.org/SSE

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

; XIncludeFile ""

DeclareModule CPU
  EnableExplicit
  
  ; Application-Feature
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86 Or #PB_Compiler_Processor = #PB_Processor_x64 And  #PB_Compiler_32Bit  
    ; 32 Bit Application on AMD/INTEL x86, x64
    #CPU_APPx32_MMX = #True
    #CPU_APPx32_SSE = #True
    
    #CPU_APPx64_MMX = #False  
    #CPU_APPx64_SSE = #False
  CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64 And  #PB_Compiler_64Bit 
    ; 64 Bit Application on AMD/INTEL x64
    #CPU_APPx32_MMX = #False
    #CPU_APPx32_SSE = #False
    
    #CPU_APPx64_MMX = #True  
    #CPU_APPx64_SSE = #True
    
  CompilerElse
    #CPU_APPx32_MMX = #False
    #CPU_APPx32_SSE = #False
    
    #CPU_APPx64_MMX = #False  
    #CPU_APPx64_SSE = #False  
  CompilerEndIf
  
  ;  ----------------------------------------------------------------------
  ;- CPU Feature Constants
  ;- ----------------------------------------------------------------------

  ; The VendorID is a fix 12 Character long Text
  ; When CPUID is called With EAX = 0, CPUID returns the VendorID String in EBX, EDX And ECX (4 char in each register)
  ; Writing it to memory in this order the result is a 12-character string which can be tested against known Vendor ID strings
  
  ;Vendor strings from CPUs.
  #CPUID_VENDOR_AMD           = "AuthenticAMD"
  #CPUID_VENDOR_AMD_OLD       = "AMDisbetter!" ; Early engineering samples of AMD K5 processor
  #CPUID_VENDOR_INTEL         = "GenuineIntel"
  #CPUID_VENDOR_VIA           = "VIA VIA VIA "
  #CPUID_VENDOR_TRANSMETA     = "GenuineTMx86"
  #CPUID_VENDOR_TRANSMETA_OLD = "TransmetaCPU"
  #CPUID_VENDOR_CYRIX         = "CyrixInstead"
  #CPUID_VENDOR_CENTAUR       = "CentaurHauls"
  #CPUID_VENDOR_NEXGEN        = "NexGenDriven"
  #CPUID_VENDOR_UMC           = "UMC UMC UMC "
  #CPUID_VENDOR_SIS           = "SiS SiS SiS "
  #CPUID_VENDOR_NSC           = "Geode by NSC"
  #CPUID_VENDOR_RISE          = "RiseRiseRise"
  #CPUID_VENDOR_VORTEX        = "Vortex86 SoC"
  #CPUID_VENDOR_AO486         = "MiSTer AO486"
  #CPUID_VENDOR_AO486_OLD     = "GenuineAO486"
  #CPUID_VENDOR_ZHAOXIN       = "  Shanghai  "
  #CPUID_VENDOR_HYGON         = "HygonGenuine"
  #CPUID_VENDOR_ELBRUS        = "E2K MACHINE "  
  ; Vendor strings from hypervisors.
  #CPUID_VENDOR_QEMU          = "TCGTCGTCGTCG"
  #CPUID_VENDOR_KVM           = " KVMKVMKVM  "
  #CPUID_VENDOR_VMWARE        = "VMwareVMware"
  #CPUID_VENDOR_VIRTUALBOX    = "VBoxVBoxVBox"
  #CPUID_VENDOR_XEN           = "XenVMMXenVMM"
  #CPUID_VENDOR_HYPERV        = "Microsoft Hv"
  #CPUID_VENDOR_PARALLELS     = " prl hyperv "
  #CPUID_VENDOR_PARALLELS_ALT = " lrpepyh vr "  ; Sometimes Parallels incorrectly encodes "prl hyperv" As "lrpepyh vr" due To an endianness mismatch.
  #CPUID_VENDOR_BHYVE         = "bhyve bhyve "
  #CPUID_VENDOR_QNX           = " QNXQVMBSQG "  
   
  Enumeration eCPU_FEATURES
    ; INPUT EAX = 01H: Returns Feature Information in ECX And EDX
    #CPUID_FEAT_ECX_SSE3        = 1 << 0    ; SSE3 instructions
    #CPUID_FEAT_ECX_PCLMUL      = 1 << 1    ; support PCLMULQDQ instruction
    #CPUID_FEAT_ECX_DTES64      = 1 << 2    ; supports DS area using 64-bit layout.
    #CPUID_FEAT_ECX_MONITOR     = 1 << 3    ; support Mointor Wait instruction
    #CPUID_FEAT_ECX_DS_CPL      = 1 << 4    ; Extended Debug-Memory Feature
    #CPUID_FEAT_ECX_VMX         = 1 << 5    ; VMX, Virtual Machine Extention
    #CPUID_FEAT_ECX_SMX         = 1 << 6    ; Saver Mode Extention
    #CPUID_FEAT_ECX_EST         = 1 << 7    ; Enhanced Speed Step
    #CPUID_FEAT_ECX_TM2         = 1 << 8    ; Thermal Monitoring 2
    #CPUID_FEAT_ECX_SSSE3       = 1 << 9    ; SSS3 support, Supplement Streaming Extention
    #CPUID_FEAT_ECX_CID         = 1 << 10   ; L1-Cache-Mode adaptive or shared
    #CPUID_FEAT_ECX_SDBG        = 1 << 11   ; IA32 Debug
    #CPUID_FEAT_ECX_FMA         = 1 << 12   ; supports FMA3 instructions
    #CPUID_FEAT_ECX_CX16        = 1 << 13   ; supports CMPXCHG16B instruction
    #CPUID_FEAT_ECX_XTPR        = 1 << 14   ; xTPR Update Control
    #CPUID_FEAT_ECX_PDCM        = 1 << 15   ; Perfmon and Debug Capability.
                                            ; Reserved
    #CPUID_FEAT_ECX_PCID        = 1 << 17   ; Process-context identifiers
    #CPUID_FEAT_ECX_DCA         = 1 << 18   ; prefetch data from a memory mapped device
    #CPUID_FEAT_ECX_SSE4_1      = 1 << 19   ; SSE4.1 Instructions
    #CPUID_FEAT_ECX_SSE4_2      = 1 << 20   ; SSE4.2 Instructions
    #CPUID_FEAT_ECX_X2APIC      = 1 << 21   ; x2APIC feature
    #CPUID_FEAT_ECX_MOVBE       = 1 << 22   ; supports MOVBE instruction
    #CPUID_FEAT_ECX_POPCNT      = 1 << 23   ; upports the POPCNT instruction
    #CPUID_FEAT_ECX_TSC         = 1 << 24   ; local APIC timer supports one-shot operation using a TSC deadline value
    #CPUID_FEAT_ECX_AES         = 1 << 25   ; supports the AESNI instruction extensions
    #CPUID_FEAT_ECX_XSAVE       = 1 << 26   ; upports the XSAVE/XRSTOR processor extended states feature
    #CPUID_FEAT_ECX_OSXSAVE     = 1 << 27   ; has set CR4.OSXSAVE[bit 18] to enable XSETBV/XGETBV
    #CPUID_FEAT_ECX_AVX         = 1 << 28   ; supports AVX instructions operating on 256-bit YMM
    #CPUID_FEAT_ECX_F16C        = 1 << 29   ; supports 16-bit floating-point conversion instructions
    #CPUID_FEAT_ECX_RDRAND      = 1 << 30   ; supports RDRAND instruction
    #CPUID_FEAT_ECX_HYPERVISOR  = 1 << 31
 
    #CPUID_FEAT_EDX_FPU         = 1 << 0    ; OnChip Floating-point Unit 
    #CPUID_FEAT_EDX_VME         = 1 << 1    ; Virtual 8086 Mode Enhancements
    #CPUID_FEAT_EDX_DE          = 1 << 2    ; Debugging Extensions
    #CPUID_FEAT_EDX_PSE         = 1 << 3    ; Page Size Extension. Large pages of size 4 MByte are supported,
    #CPUID_FEAT_EDX_TSC         = 1 << 4    ; Time Stamp Counter. The RDTSC instruction is supported
    #CPUID_FEAT_EDX_MSR         = 1 << 5    ; Model Specific Registers RDMSR and WRMSR Instructions
    #CPUID_FEAT_EDX_PAE         = 1 << 6    ; Physical Address Extension. Physical addresses greater than 32 bits are supported
    #CPUID_FEAT_EDX_MCE         = 1 << 7    ; Machine Check Exception. Exception 18 is defined for Machine Checks, including CR4.MC
    #CPUID_FEAT_EDX_CX8         = 1 << 8    ; CMPXCHG8B Instruction. The compare-and-exchange 8 bytes (64 bits) instruction is supported
    #CPUID_FEAT_EDX_APIC        = 1 << 9    ; APIC On-Chip.
                                            ; Reserved
    #CPUID_FEAT_EDX_SEP         = 1 << 11   ; SYSENTER and SYSEXIT Instructions.
    #CPUID_FEAT_EDX_MTRR        = 1 << 12   ; Memory Type Range Registers. MTRRs are supported
    #CPUID_FEAT_EDX_PGE         = 1 << 13   ; Page Global Bit. The global bit is supported in paging-structure entries that map a page
    #CPUID_FEAT_EDX_MCA         = 1 << 14   ; Machine Check Architecture
    #CPUID_FEAT_EDX_CMOV        = 1 << 15   ; Conditional Move Instructions
    #CPUID_FEAT_EDX_PAT         = 1 << 16   ; Page Attribute Table. Page Attribute Table is supported.
    #CPUID_FEAT_EDX_PSE36       = 1 << 17   ; 36-Bit Page Size Extension. 4-MByte pages addressing physical memory beyond 4 GBytes are supported with 32-bit paging
    #CPUID_FEAT_EDX_PSN         = 1 << 18   ; Processor Serial Number. The processor supports the 96-bit processor identification number feature and it's enabled
    #CPUID_FEAT_EDX_CLFLUSH     = 1 << 19   ; CLFLUSH Instruction
    #CPUID_FEAT_EDX_DS          = 1 << 21   ; Debug Store. The processor supports the ability to write debug information into a memory resident buffer
    #CPUID_FEAT_EDX_ACPI        = 1 << 22   ; Thermal Monitor and Software Controlled Clock Facilities
    #CPUID_FEAT_EDX_MMX         = 1 << 23   ; Intel MMX Technology. The processor supports the Intel MMX technology
    #CPUID_FEAT_EDX_FXSR        = 1 << 24   ; FXSAVE and FXRSTOR Instructions
    #CPUID_FEAT_EDX_SSE         = 1 << 25   ; SSE extensions
    #CPUID_FEAT_EDX_SSE2        = 1 << 26   ; SSE2 extensions
    #CPUID_FEAT_EDX_SS          = 1 << 27   ; Self Snoop
    #CPUID_FEAT_EDX_HTT         = 1 << 28   ; Max APIC IDs reserved field is Valid.
    #CPUID_FEAT_EDX_TM          = 1 << 29   ; The processor implements the thermal monitor automatic thermal control circuitry (TCC)
    #CPUID_FEAT_EDX_IA64        = 1 << 30   ; Intel Itanium 64
    #CPUID_FEAT_EDX_PBE         = 1 << 31   ; Pending Break Enable
  EndEnumeration
  
  ;  ----------------------------------------------------------------------
  ;- Structure Definitions
  ;- ----------------------------------------------------------------------

  ; ATTENTION: SizeOf(pTRegister) = 0; Use it only as Pointer like *Reg.pTRegister
  Structure pTRegister ; This is a NULL-Size Structure! Only used for universal Pointers
    a.a[0]    ; ASCII   : 8 Bit unsigned  [0..255] 
    b.b[0]    ; BYTE    : 8 Bit signed    [-128..127]
    c.c[0]    ; CAHR    : 2 Byte unsigned [0..65535]
    w.w[0]    ; WORD    : 2 Byte signed   [-32768..32767]
    u.u[0]    ; UNICODE : 2 Byte unsigned [0..65535]
    l.l[0]    ; LONG    : 4 Byte signed   [-2147483648..2147483647]
    f.f[0]    ; FLOAT   : 4 Byte
    q.q[0]    ; QUAD    : 8 Byte signed   [-9223372036854775808..9223372036854775807]
    d.d[0]    ; DOUBLE  : 8 Byte float    
    i.i[0]    ; INTEGER : 4 or 8 Byte INT, depending on System 
  EndStructure
  
  Structure TCpuRegisterSet_x86
    EAX.l
    EBX.l
    ECX.l
    EDX.l
  EndStructure
  
  Structure TCpuRegisterSet_x64
    RAX.q
    RBX.q
    RCX.q
    RDX.q
  EndStructure

  Structure TCpuRegister_XMM   ; Describes 128Bit XMM-Register (16Bytes) - SSE
    ptr.pTRegister    ; 0-Bytes! Just Pointer Structure! Works like Union!
    q0.q              ; 8-Bytes
    q1.q              ; 8-Bytes
  EndStructure
  
  Structure TCpuRegister_YMM   ; Describes 256Bit YMM-Register (32Bytes) - AVX256
    ptr.pTRegister    ; 0-Bytes! Just Pointer Structure! Works like Union!
    q0.q
    q1.q
    q2.q
    q3.q
  EndStructure
  
  Structure TCpuRegister_ZMM   ; Describes 512Bit ZMM-Register (32Bytes) - AVX512
    ptr.pTRegister    ; 0-Bytes! Just Pointer Structure! Works like Union!
    q0.q
    q1.q
    q2.q
    q3.q
    q4.q
    q5.q
    q6.q
    q7.q   
  EndStructure
  
;   Debug "SizeOf(pTRegister) = " + SizeOf(pTRegister) ; 0
;   Debug "SizeOf(TCpuXmm)    = " + SizeOf(TCpuXmm)    ; 16
;   Debug "SizeOf(TCpuYmm)    = " + SizeOf(TCpuYmm)    ; 32
;   Debug "SizeOf(TCpuZmm)    = " + SizeOf(TCpuZmm)    ; 64
  
  Structure TCpuMultiMediaFeatures
    MMX.l                      ; Multimedia Extensions           ( 64 Bit  MM0..7)
    SSE.l                      ; SSE                             (128 Bit XMM0..7)
    SSE2.l                     ; SSE2
    SSE3.l                     ; SSE3
    SSE4_1.l                   ; SSE4.1 (47 Instructions)
    SSE4_2.l                   ; SSE4.2 (7 String Instructions)
    AVX.l                      ; Advanced Vector Extension       (256 Bit YMM0..15)
    AVX2.l                     ; Advanced Vector Extension 2 
    ;AVX512.l                   ; Advanced Vector Extension-512   (512 Bit ZMM0..31)
    ;AES.l                      ; Advanced Encryption Standard
  EndStructure
  
  Structure TCpuMoreFeatures
    FPU.l                       ; Onboard FPU 
    VME.l                       ; Virtual Mode Extensions
    DE.l                        ; Debugging Extensions                
    PSE.l                       ; Page Size Extensions
    TSC.l                       ; Time Stamp Counter
    PGE.l                       ; Page Global Enable
    APIC.l                      ; Onboard APIC
    SEP.l                       ; SYSENTER/SYSEXIT
    MTRR.l
    FXSR.l
    HT.l                        ; Hyper-Threading
    NX.l                        ; Execute Disable
    XStore.l
    XStore_Enabled.l
    XCrypt.l
    XCrypt_Enabled.l
    ACE2.l
    ACE2_Enabled.l
    PHE.l	
    PHE_Enabled.l	
    PMM.l	
    PMM_Enabled.l	
    DS.l		
    PEBS.l		
    CLFLUSH.l		
    BTS.l		
    gbpages.l		
    arch_perfmon.l	
    PAT.l		
    x2apic.l		
    XSave.l		
    XSaveopt.l	
    XSaves.l		
    OSXSave.l		
    Hypervisor.l	
    pclmulqdq.l	
    perfctr_core.l	
    perfctr_nb.l	
    perfctr_l2.l	
    CX8.l		
    CX16.l		
    EAGER_FPU.l	
    TOPOEXT.l		
    BPEXT.l
  EndStructure
  
  ;  ----------------------------------------------------------------------
  ;- Declare Puclic Functions
  ;- ----------------------------------------------------------------------

  Declare.i CPUID_IsSupported() ; Check if CPUID is supported by the CPU
  Declare   CPUID (function.l, *EAX, *EBX, *ECX, *EDX) ; This wraps the CPUID instruction.
  
  Declare.s GetCPUVendorID()
  Declare.i GetHighestLeaf(Extended=#False)

  
EndDeclareModule


Module CPU
  
  ;  ----------------------------------------------------------------------
  ;- Module Implementation
  ;- ----------------------------------------------------------------------
 
  Procedure.i CPUID_IsSupported()
  ; ======================================================================
  ;  NAME: CPUID_IsSupported
  ;  DESC: Checks if CPUID is supported
  ;  DESC: on AMD/Intel x64 Processors CPUID is always supported
  ;  DESC: It was introduced in 1993 with the Pentium CPUs
  ;  DESC: But better to do a check bevor calling !CPUID functions
  ;  VAR(leaf.l): the numerical id of the requested level of information 
  ;  RET : #TRUE if supported
  ; ====================================================================== 
  
    CompilerIf (#PB_Compiler_Processor = #PB_Processor_x64)
      ProcedureReturn #True  ;  on x64 CPUs CPUID is always supported
       
    CompilerElseIf (#PB_Compiler_Processor = #PB_Processor_x86)      
      
      CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
        !PUSHFD
        !POP EAX
        !MOV EDX, EAX
        !XOR EAX, 0x00200000
        !PUSH EAX
        !POPFD
        !PUSHFD
        !POP EAX
        !XOR EAX, EDX
        !JNE IsCpuid_OK
        !XOR EAX, EAX   ; ProcedureReturn #False
        !RET
        !IsCpuid_OK:
        !MOV EAX, 1     ; ProcedureReturn #True
        !RET     
        
      CompilerElseIf #PB_Compiler_Backend = #PB_Backend_C
        !asm volatile (".intel_syntax noprefix;"
        !"pushfd;"
        !"pop EAX;"
        !"mov EDX, EAX;"
        !"xor EAX, 0x00200000;"  
        !"push EAX;"
        !"popfd;"
        !"pushfd;"
        !"pop EAX;"
        !"xor EAX, EDX;"
        
        !"jne IsCpuid_OK;"
        !"mov %[retval], 0;"
        !"jmp IsCpuid_EXIT;"
        
        !"IsCpuid_OK:"
        !"mov %[retval], 1;"
        
        !"IsCpuid_EXIT:"
            
        !".att_syntax;"
        !: [retval] "=r" (r)
        !);
        
        !return r       ; ProcedureReturn r   
      CompilerEndIf
      
    CompilerEndIf
  EndProcedure    
  
  Procedure CPUID (Function.l, *EAX, *EBX, *ECX, *EDX)
  ; ======================================================================
  ;  NAME: CPUID
  ;  DESC: This wraps the CPUID instruction. And copies the return values
  ;  DESC: from CPUID to 4 Variables. CPID returns the values direct in
  ;  DESC: the x86 Registers EAX, EBX, ECX, EDX
  ;  VAR(function.l): the numerical id of the requested level of information 
  ;  VAR(*EAX): Pointer to a 32Bit Long to receive EAX after !CPUID
  ;  VAR(*EBX): Pointer to a 32Bit Long to receive EBX after !CPUID
  ;  VAR(*ECX): Pointer to a 32Bit Long to receive ECX after !CPUID
  ;  VAR(*EDX): Pointer to a 32Bit Long to receive EDX after !CPUID
  ;  RET : -
  ; ====================================================================== 
    
  ; more informations for the CPUID instruction you can find here:
    ; https://c9x.me/x86/html/file_module_x86_id_45.html
    ; https://www.lowlevel.eu/wiki/CPUID
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
      CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)  
        !MOV EAX, DWORD [p.v_Function]
        !CPUID
        !MOV EBP, DWORD [p.p_EAX]
        !MOV DWORD [EBP], EAX
        !MOV EBP, DWORD [p.p_EBX]
        !MOV DWORD [EBP], EBX
        !MOV EBP, DWORD [p.p_ECX]
        !MOV DWORD [EBP], ECX
        !MOV EBP, DWORD [p.p_EDX]
        !MOV DWORD [EBP], EDX        
      CompilerElse   
        !XOR RAX, RAX
        !MOV EAX, DWORD [p.v_Function]
        !CPUID
        !MOV RBP, QWORD [p.p_EAX]
        !MOV DWORD [RBP], EAX
        !MOV RBP, QWORD [p.p_EBX]
        !MOV DWORD [RBP], EBX
        !MOV RBP, QWORD [p.p_ECX]
        !MOV DWORD [RBP], ECX
        !MOV RBP, QWORD [p.p_EDX]
        !MOV DWORD [RBP], EDX
      CompilerEndIf  
    
    CompilerElseIf #PB_Compiler_Backend = #PB_Backend_C
      !unsigned int reg_a, reg_b, reg_c, reg_d;
      
      !asm volatile ("cpuid;"  
      !: "=a" (reg_a), "=b" (reg_b), "=c" (reg_c), "=d" (reg_d)	
      !: "0" (v_function)
      !);
      
      ! * (unsigned int *) p_EAX = reg_a;
      ! * (unsigned int *) p_EBX = reg_b;
      ! * (unsigned int *) p_ECX = reg_c;
      ! * (unsigned int *) p_EDX = reg_d;
    CompilerEndIf
  
  EndProcedure

  Procedure GetRegisterSet_x86(*RET.TCpuRegisterSet_x86)
  ; ======================================================================
  ;  NAME: GetRegisterSet_x86
  ;  DESC: ATTENTION! Do not use with active Debugger, you will get
  ;  DESC: the Register values from the Debugger not from your Application!
  ;  DESC: Copies the actual values of the x68 Registers EAX,EBX,ECX,EDX
  ;  DESC: to a Structure Variable TCpuRegisterSet_x86
  ;  VAR(*RET.TCpuRegisterSet_x86): Pointer to a TCpuRegisterSet_x86 Structure
  ;  RET: -
  ; ====================================================================== 
    
    !PUSH EDX
    !PUSH ECX
    !PUSH EBX
    !PUSH EAX
    !LEA EAX, [p.p_RET]   ; load effective Address *RET on Stack into EAX
    !ADD EAX, 16          ; because the 4 PUSH modified ESP => we must correct effective Address with 16 Bytes
    
    !MOV EAX, [EAX]       ; now load the value of *RET from Stack
    
    !POP EDX              ; POP the former EAX content into EDX
    !MOV [EAX], EDX       ; Move the former EAX to *RET\EAX
    
    !POP EDX              ; POP the former EBX content into EDX
    !MOV [EAX+4], EDX     ; Move the former EBX to *RET\EBX
    
    !POP EDX              ; POP the former ECX content into EDX
    !MOV [EAX+8], EDX     ; Move the former ECX to *RET\ECX
    
    !POP EDX              ; POP the former EDX content into EDX
    !MOV [EAX+12], EDX    ; Move the former EDX to *RET\EDX
  EndProcedure

 
  Procedure GetCpuMultiMediaFeatures(*Features.TCpuMultiMediaFeatures)
  ; ======================================================================
  ;  NAME: GetCpuMultiMediaFeatures
  ;  DESC: Returns the MultiMedia-Features of the CPU
  ;  VAR(*Features.TCpuMultiMediaFeatures) Pointer to Structure
  ;  RET: -
  ; ====================================================================== 
    
    Protected.l mEAX, mEBX, mECX, mEDX     
    
    ; Call CPUID with Function $01
    CPUID($01, @mEAX, @mEBX, @mECX, @mEDX)
    
    With *Features
      \MMX =  Bool (mEDX & #CPUID_FEAT_EDX_MMX) 
      \SSE =  Bool (mEDX & #CPUID_FEAT_EDX_SSE)
      \SSE2 = Bool (mEDX & #CPUID_FEAT_EDX_SSE2)
      \SSE3 = Bool (mECX & #CPUID_FEAT_ECX_SSE3)
      
      \SSE4_1 = Bool (mECX & #CPUID_FEAT_ECX_SSE4_1)
      \SSE4_2 = Bool (mECX & #CPUID_FEAT_ECX_SSE4_2)
      \AVX =    Bool (mECX & #CPUID_FEAT_ECX_AVX)
      \AVX2 =   0 ; ??? where to find the Flag
      ;\AVX512 = 0
      ;\AES = 0
    EndWith
    
  EndProcedure
  
  Procedure GetCpuMoreFeatures(*Features.TCpuMoreFeatures)
    With *Features
      
    EndWith
    
  EndProcedure

  Procedure.s GetCPUVendorID()
  ; ======================================================================
  ;  NAME: GetCPUVendorID
  ;  DESC: Reads the 12 Character long Vendor ID of the CPU 
  ;  RET.s: VendorID String {"AuthenticAMD", "GenuineIntel" ...}
  ; ====================================================================== 
    
    ; the VendorName contains 12 Chars in ASCII, token from the Registers EBX,EDX,ECX    
    Protected.l mEAX, mEBX, mECX, mEDX     
    
    If CPUID_IsSupported()
      CPUID(0, @mEAX, @mEBX, @mECX, @mEDX)
      ProcedureReturn PeekS(@mEBX, 4, #PB_Ascii) + PeekS(@mEDX, 4, #PB_Ascii) + PeekS(@mECX, 4, #PB_Ascii)      
    Else
      ProcedureReturn "unknown Vendor"
    EndIf
  
  EndProcedure
  
  Procedure.i GetHighestLeaf(xExtended=#False)
  ; ======================================================================
  ;  NAME: GetHighestLeaf
  ;  DESC: Get the 'highest' or 'highest extended' leaf level supported by CPUID
  ;  DESC: and optionally the manufacturer ID
  ;  VAR(xExtended): #False = HighestLeaf, #True = HighestExtendedLeaf
  ;  RET.i : HighestLeafLevel supported
  ; ====================================================================== 
     
    Protected.l mEAX, mEBX, mECX, mEDX     
    Protected.l function
    
    If CPUID_IsSupported()
      If xExtended
        function = $80000000
      EndIf
      CPUID(function, @mEAX, @mEBX, @mECX, @mEDX)
    EndIf
    
    ProcedureReturn mEAX   
  EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
  
  EnableExplicit
  UseModule CPU
  
  Define text$, backend$, leaf
  Define.l EAX, EBX, ECX, EDX
  Define.l HighestExt
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
   backend$ = "ASM"
  CompilerEndIf
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_C
   backend$ = "C"
  CompilerEndIf
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
   backend$ + " x86"
  CompilerElse   
   backend$ + " x64"
  CompilerEndIf
  
  
  backend$ + " " + #PB_Compiler_Version
  
  text$ = "Backend : " + backend$ 
  
  If CPUID_IsSupported()
  
   text$ + #CRLF$ + "CPUID is supported."
   
  ; CPU::GetHighestLeaf_1 (0, @Highest, @Manufacturer$)
   text$ + #CRLF$ + "Manufacturer ID : " + GetCPUVendorID()
   text$ + #CRLF$ + "Highest leaf : " + GetHighestLeaf()
   
   ; GetHighestLeaf_1 ($80000000, @HighestExt)
   HighestExt = GetHighestLeaf(#True)
   text$ + #CRLF$ + "Highest extended leaf : " + "0x" + Hex(HighestExt, #PB_Long)
   
   If ($80000004 & $7FFFFFFF) <= (HighestExt & $7FFFFFFF) ; checks if the required leaves are supported
      text$ + #CRLF$ + "Processor string : [" 
      For leaf = $80000002 To $80000004
          CPU::CPUID (leaf, @EAX, @EBX, @ECX, @EDX)
          text$ + PeekS(@EAX, 4, #PB_Ascii) + PeekS(@EBX, 4, #PB_Ascii) + PeekS(@ECX, 4, #PB_Ascii) + PeekS(@EDX, 4, #PB_Ascii)         
      Next
      text$ + "]"
   Else
       text$ + #CRLF$ + "The extended leaves $80000002 - $80000004 are not supported." 
   EndIf
   
  Else
   text$ = "CPUID is not supported."
  EndIf
  
  Debug CPU::GetCpuVendorID()
  Debug Hex(CPU::GetHighestLeaf(#True),#PB_Long)
  MessageRequester("CPUID", text$)
CompilerEndIf

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 45
; FirstLine = 122
; Folding = ----
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)