; ===========================================================================
;  FILE : PbFw_Module_CPU.pb
;  NAME : Purebasic FrameWork Module CPU [CPU::]
;  DESC : CPU indentification und Featuer Flags
;  DESC : 
;  DESC : Instuction sets: https://en.wikipedia.org/wiki/X86_instruction_listings
;  SOURCES:
;   https://wiki.osdev.org/SSE
;   https://hjlebbink.github.io/x86doc/
;   https://c9x.me/x86/html/file_module_x86_id_45.html
;   https://www.lowlevel.eu/wiki/CPUID
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/12/08
; VERSION  :  0.5  Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{ 
; 2025/08/09 S.Maag : added Feature Datasection and reworked functions
;                     added AVX512 Flags
; 2024/01/20 S.Maag : added EAX=07h feateures like SHA, AVX2
;                     added GetRegisterSet_x64
; 2023/02/16 S.Maag : removed some Bugs in Constant Names
;}             
; ============================================================================

; 

;x64 Registers
; RAX 	Akkumulator
; RBX 	Base Register
; RCX 	Counter
; RDX 	Data Register
; RBP 	Base-Pointer
; RSI 	Source-Index
; RDI 	Destination-Index
; RSP 	Stack-Pointer 
; R8…R15 	Register 8 bis 15 

;- --------------------------------------------------
;- Include Files
;- --------------------------------------------------

XIncludeFile "PbFw_Module_PX.pb"           ; PX::   PureBasic Extention Module
XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module

DeclareModule CPU
  EnableExplicit
    
  ;  --------------------------------------------------
  ;- CPU Feature Constants
  ;- --------------------------------------------------
  
  ; ATTENTION: This Enumeration is Autogeneratred and copied to ClipBoard when this Module
  ;            is started as MainFile in PB. It is generated from the DataSection entries of 
  ;            the CPUFeatureFlags. To get the Enumeration Code, paste it anywhere from ClipBoard
  
  ; To add a new Feature: add it to Datasection, start Module in PB as Mainfile and past Code for Enumeration
  
	Enumeration eCPU_Feature
		#CPU_FEAT_ACPI              ;  0 : EDX[22] FC=1 : Onboard thermal control MSRs For ACPI
		#CPU_FEAT_ADX               ;  1 : EBX[19] FC=7 : ADX
		#CPU_FEAT_AES               ;  2 : ECX[25] FC=1 : AES instruction set
		#CPU_FEAT_APIC              ;  3 : EDX[ 9] FC=1 : Onboard Advanced Programmable Interrupt Controller
		#CPU_FEAT_AVX               ;  4 : ECX[28] FC=1 : Advanced Vector Extensions
		#CPU_FEAT_AVX2              ;  5 : EBX[ 5] FC=7 : AVX2 (AVX256 extended instruction set)
		#CPU_FEAT_AVX512BITALG      ;  6 : ECX[12] FC=7 : AVX512BITALG
		#CPU_FEAT_AVX512BW          ;  7 : EBX[30] FC=7 : AVX512ER
		#CPU_FEAT_AVX512CD          ;  8 : EBX[28] FC=7 : AVX512CD
		#CPU_FEAT_AVX512DQ          ;  9 : EBX[17] FC=7 : AVX512DQ
		#CPU_FEAT_AVX512ER          ; 10 : EBX[27] FC=7 : AVX512ER
		#CPU_FEAT_AVX512F           ; 11 : EBX[16] FC=7 : AVX512F
		#CPU_FEAT_AVX512FMA         ; 12 : EBX[21] FC=7 : AVX512, fused multiply add
		#CPU_FEAT_AVX512FMAPS       ; 13 : EDX[ 3] FC=7 : AVX512FMAPS
		#CPU_FEAT_AVX512PF          ; 14 : EBX[26] FC=7 : AVX512PF
		#CPU_FEAT_AVX512POPCNT      ; 15 : ECX[14] FC=7 : AVX512POPCNT
		#CPU_FEAT_AVX512VBMI        ; 16 : ECX[ 0] FC=7 : AVX512VBMI
		#CPU_FEAT_AVX512VBMI2       ; 17 : ECX[ 6] FC=7 : AVX512VBMI2
		#CPU_FEAT_AVX512VL          ; 18 : EBX[31] FC=7 : AVX512CD
		#CPU_FEAT_AVX512VNNI        ; 19 : ECX[11] FC=7 : AVX512VNNI
		#CPU_FEAT_BMI1              ; 20 : EBX[ 3] FC=7 : BMI1
		#CPU_FEAT_BMI2              ; 21 : EBX[ 8] FC=7 : BMI2
		#CPU_FEAT_CLFLUSHOPT        ; 22 : EBX[23] FC=7 : CLFLUSHOPT
		#CPU_FEAT_CLFSH             ; 23 : EDX[19] FC=1 : CLFLUSH instruction (SSE2)
		#CPU_FEAT_CMOV              ; 24 : EDX[15] FC=1 : Conditional move And FCMOV instructions
		#CPU_FEAT_CNXTID            ; 25 : ECX[10] FC=1 : L1 Context ID
		#CPU_FEAT_CX16              ; 26 : ECX[13] FC=1 : CMPXCHG16B instruction
		#CPU_FEAT_CX8               ; 27 : EDX[ 8] FC=1 : CMPXCHG8 (compare-And-Swap) instruction
		#CPU_FEAT_DCA               ; 28 : ECX[18] FC=1 : Direct cache access For DMA writes[10][11]
		#CPU_FEAT_DE                ; 29 : EDX[ 2] FC=1 : Debugging extensions (CR4 bit 3)
		#CPU_FEAT_DS                ; 30 : EDX[21] FC=1 : Debug store: save trace of executed jumps
		#CPU_FEAT_DSCPL             ; 31 : ECX[ 4] FC=1 : CPL qualified Debug store
		#CPU_FEAT_DTES64            ; 32 : ECX[ 2] FC=1 : 64-bit Debug store (edx bit 21)
		#CPU_FEAT_EST               ; 33 : ECX[ 7] FC=1 : Enhanced SpeedStep
		#CPU_FEAT_F16C              ; 34 : ECX[29] FC=1 : F16C (half-precision) FP support
		#CPU_FEAT_FDP_EXCPTN_ONLY   ; 35 : EBX[ 6] FC=7 : x87 FPU Data Pointer updated only on x87 exceptions
		#CPU_FEAT_FMA               ; 36 : ECX[12] FC=1 : Fused multiply-add (FMA3)
		#CPU_FEAT_FPU               ; 37 : EDX[ 0] FC=1 : Onboard x87 FPU
		#CPU_FEAT_FSGSBASE          ; 38 : EBX[ 0] FC=7 : RDFSBASE/RDGSBASE/WRFSBASE/WRGSBASE
		#CPU_FEAT_FXSR              ; 39 : EDX[24] FC=1 : FXSAVE, FXRESTOR instructions, CR4 bit 9
		#CPU_FEAT_HLE               ; 40 : EBX[ 4] FC=7 : HLE
		#CPU_FEAT_HTT               ; 41 : EDX[28] FC=1 : Hyper-threading
		#CPU_FEAT_HYPERVISOR        ; 42 : ECX[31] FC=1 : Running on a hypervisor (always 0 on a real CPU, but also With some hypervisors)
		#CPU_FEAT_IA32_TSC_ADJUST   ; 43 : EBX[ 1] FC=7 : Intel Itanium TSC Adjust
		#CPU_FEAT_IA64              ; 44 : EDX[30] FC=1 : IA64 processor emulating x86
		#CPU_FEAT_INVPCID           ; 45 : EBX[10] FC=7 : INVPCID instruction For system software that manages process-context identifiers
		#CPU_FEAT_MCA               ; 46 : EDX[14] FC=1 : Machine check architecture
		#CPU_FEAT_MCE               ; 47 : EDX[ 7] FC=1 : Machine Check Exception
		#CPU_FEAT_MMX               ; 48 : EDX[23] FC=1 : MMX instructions
		#CPU_FEAT_MONITOR           ; 49 : ECX[ 3] FC=1 : MONITOR And MWAIT instructions (SSE3)
		#CPU_FEAT_MOVBE             ; 50 : ECX[22] FC=1 : MOVBE instruction (big-endian)
		#CPU_FEAT_MPX               ; 51 : EBX[14] FC=7 : Intel® Memory Protection Extensions
		#CPU_FEAT_MSR               ; 52 : EDX[ 5] FC=1 : Model-specific registers
		#CPU_FEAT_MTRR              ; 53 : EDX[12] FC=1 : Memory Type Range Registers
		#CPU_FEAT_OSXSAVE           ; 54 : ECX[27] FC=1 : XSAVE enabled by OS
		#CPU_FEAT_PAE               ; 55 : EDX[ 6] FC=1 : Physical Address Extension
		#CPU_FEAT_PAT               ; 56 : EDX[16] FC=1 : Page Attribute Table (reserved)
		#CPU_FEAT_PBE               ; 57 : EDX[31] FC=1 : Pending Break Enable (PBE#PB_CPU_ pin) wakeup support
		#CPU_FEAT_PCID              ; 58 : ECX[17] FC=1 : Process context identifiers (CR4 bit 17)
		#CPU_FEAT_PCMULQDQ          ; 59 : ECX[ 1] FC=1 : PCLMULQDQ support
		#CPU_FEAT_PDCM              ; 60 : ECX[15] FC=1 : Perfmon & Debug capability
		#CPU_FEAT_PGE               ; 61 : EDX[13] FC=1 : Page Global Enable bit in CR4
		#CPU_FEAT_POPCNT            ; 62 : ECX[23] FC=1 : Population Count instruction. Count No of Bits set
		#CPU_FEAT_PSE               ; 63 : EDX[ 3] FC=1 : Page Size Extension
		#CPU_FEAT_PSE36             ; 64 : EDX[17] FC=1 : 36-bit page size extension
		#CPU_FEAT_PSN               ; 65 : EDX[18] FC=1 : Processor Serial Number
		#CPU_FEAT_RDRND             ; 66 : ECX[30] FC=1 : RDRAND (on-chip random number generator) support
		#CPU_FEAT_RDSEED            ; 67 : EBX[18] FC=7 : RDSEED
		#CPU_FEAT_RDTA              ; 68 : EBX[15] FC=7 : Intel® Resource Director Technology (Intel® RDT) Allocation capability
		#CPU_FEAT_RDTM              ; 69 : EBX[12] FC=7 : Intel® Resource Director Technology (Intel® RDT) Monitoring capability
		#CPU_FEAT_REP               ; 70 : EBX[ 9] FC=7 : Enhanced REP MOVSB/STOSB
		#CPU_FEAT_RTM               ; 71 : EBX[11] FC=7 : RTM
		#CPU_FEAT_SDBG              ; 72 : ECX[11] FC=1 : IA32 Debug
		#CPU_FEAT_SEP               ; 73 : EDX[11] FC=1 : SYSENTER And SYSEXIT instructions
		#CPU_FEAT_SGX               ; 74 : EBX[ 2] FC=7 : Intel® Software Guard Extensions
		#CPU_FEAT_SHA               ; 75 : EBX[29] FC=7 : SHA Instruction support
		#CPU_FEAT_SMAP              ; 76 : EBX[20] FC=7 : SMAP
		#CPU_FEAT_SMEP              ; 77 : EBX[ 7] FC=7 : Supervisor-Mode Execution Prevention
		#CPU_FEAT_SMX               ; 78 : ECX[ 6] FC=1 : Safer Mode Extensions (LaGrande)
		#CPU_FEAT_SS                ; 79 : EDX[27] FC=1 : CPU cache supports self-snoop
		#CPU_FEAT_SSE               ; 80 : EDX[25] FC=1 : SSE instructions (a.k.a. Katmai New Instructions)
		#CPU_FEAT_SSE2              ; 81 : EDX[26] FC=1 : SSE2 instructions
		#CPU_FEAT_SSE3              ; 82 : ECX[ 0] FC=1 : Prescott New Instructions-SSE3 (PNI)
		#CPU_FEAT_SSE41             ; 83 : ECX[19] FC=1 : SSE4.1 instructions
		#CPU_FEAT_SSE42             ; 84 : ECX[20] FC=1 : SSE4.2 instructions
		#CPU_FEAT_SSSE3             ; 85 : ECX[ 9] FC=1 : SSSE3 Supplemental SSE3 instructions
		#CPU_FEAT_TM                ; 86 : EDX[29] FC=1 : Thermal monitor automatically limits temperature
		#CPU_FEAT_TM2               ; 87 : ECX[ 8] FC=1 : Thermal Monitor 2
		#CPU_FEAT_TSC               ; 88 : EDX[ 4] FC=1 : Time Stamp Counter
		#CPU_FEAT_TSCDEADLINE       ; 89 : ECX[24] FC=1 : APIC supports one-shot operation using a TSC deadline value
		#CPU_FEAT_VME               ; 90 : EDX[ 1] FC=1 : Virtual 8086 mode extensions (such As VIF, VIP, PIV)
		#CPU_FEAT_VMX               ; 91 : ECX[ 5] FC=1 : Virtual Machine eXtensions
		#CPU_FEAT_X2APIC            ; 92 : ECX[21] FC=1 : x2APIC support
		#CPU_FEAT_XSAVE             ; 93 : ECX[26] FC=1 : XSAVE, XRESTOR, XSETBV, XGETBV
		#CPU_FEAT_XTPR              ; 94 : ECX[14] FC=1 : Can disable sending task priority messages
	EndEnumeration
	
  #CPU_TotalNoOfFeatures = #PB_Compiler_EnumerationValue
  Debug "Total No of Features listed = " + #CPU_TotalNoOfFeatures
  
  ; ----------------------------------------
  ; Vendor strings from CPUs.
  ; ----------------------------------------
  ; The VendorID is a fix 12 Character long Text
  ; When CPUID is called With EAX = 0, CPUID returns the VendorID String in EBX, EDX And ECX (4 char in each register)
  ; Writing it to memory in this order the result is a 12-character string which can be tested against known Vendor ID strings  
  #CPU_VENDOR_AMD           = "AuthenticAMD"
  #CPU_VENDOR_AMD_OLD       = "AMDisbetter!" ; Early engineering samples of AMD K5 processor
  #CPU_VENDOR_INTEL         = "GenuineIntel"
  #CPU_VENDOR_VIA           = "VIA VIA VIA "
  #CPU_VENDOR_TRANSMETA     = "GenuineTMx86"
  #CPU_VENDOR_TRANSMETA_OLD = "TransmetaCPU"
  #CPU_VENDOR_CYRIX         = "CyrixInstead"
  #CPU_VENDOR_CENTAUR       = "CentaurHauls"
  #CPU_VENDOR_NEXGEN        = "NexGenDriven"
  #CPU_VENDOR_UMC           = "UMC UMC UMC "
  #CPU_VENDOR_SIS           = "SiS SiS SiS "
  #CPU_VENDOR_NSC           = "Geode by NSC"
  #CPU_VENDOR_RISE          = "RiseRiseRise"
  #CPU_VENDOR_VORTEX        = "Vortex86 SoC"
  #CPU_VENDOR_AO486         = "MiSTer AO486"
  #CPU_VENDOR_AO486_OLD     = "GenuineAO486"
  #CPU_VENDOR_ZHAOXIN       = "  Shanghai  "
  #CPU_VENDOR_HYGON         = "HygonGenuine"
  #CPU_VENDOR_ELBRUS        = "E2K MACHINE "  
  ; Vendor strings from hypervisors.
  #CPU_VENDOR_QEMU          = "TCGTCGTCGTCG"
  #CPU_VENDOR_KVM           = " KVMKVMKVM  "
  #CPU_VENDOR_VMWARE        = "VMwareVMware"
  #CPU_VENDOR_VIRTUALBOX    = "VBoxVBoxVBox"
  #CPU_VENDOR_XEN           = "XenVMMXenVMM"
  #CPU_VENDOR_HYPERV        = "Microsoft Hv"
  #CPU_VENDOR_PARALLELS     = " prl hyperv "
  #CPU_VENDOR_PARALLELS_ALT = " lrpepyh vr "  ; Sometimes Parallels incorrectly encodes "prl hyperv" As "lrpepyh vr" due To an endianness mismatch.
  #CPU_VENDOR_BHYVE         = "bhyve bhyve "
  #CPU_VENDOR_QNX           = " QNXQVMBSQG "  
      
  ; --------------------------------------------------
  ; INPUT EAX = 01H: Returns Feature Information in ECX And EDX
  ; --------------------------------------------------
  
  ; ---ECX---
  ;   SSE3         0    ; SSE3 instructions
  ;   PCLMULQDQ    1    ; support PCLMULQDQ instruction
  ;   DTES64       2    ; supports DS area using 64-bit layout.
  ;   MONITOR      3    ; support Mointor Wait instruction
  ;   DSCPL        4    ; Extended Debug-Memory Feature
  ;   VMX          5    ; VMX, Virtual Machine Extention
  ;   SMX          6    ; Saver Mode Extention
  ;   EST          7    ; Enhanced Speed Step
  ;   TM2          8    ; Thermal Monitoring 2
  ;   SSSE3        9    ; SSS3 support, Supplement Streaming Extention
  ;   CID          10   ; L1-Cache-Mode adaptive or shared
  ;   SDBG         11   ; IA32 Debug
  ;   FMA          12   ; supports FMA3 instructions
  ;   CX16         13   ; supports CMPXCHG16B instruction
  ;   XTPR         14   ; xTPR Update Control
  ;   PDCM         15   ; Perfmon and Debug Capability.
  ;   
  ;   ; Reserved
  ;   PCID         17   ; Process-context identifiers
  ;   DCA          18   ; prefetch data from a memory mapped device
  ;   SSE41        19   ; SSE4.1 Instructions
  ;   SSE42        20   ; SSE4.2 Instructions
  ;   X2APIC       21   ; x2APIC feature
  ;   MOVBE        22   ; supports MOVBE instruction
  ;   POPCNT       23   ; supports the POPCNT instruction
  ;   TSC          24   ; local APIC timer supports one-shot operation using a TSC deadline value
  ;   AES          25   ; supports the AESNI instruction extensions
  ;   XSAVE        26   ; upports the XSAVE/XRSTOR processor extended states feature
  ;   OSXSAVE      27   ; has set CR4.OSXSAVE[bit 18] to enable XSETBV/XGETBV
  ;   AVX          28   ; supports AVX instructions operating on 256-bit YMM
  ;   F16C         29   ; supports 16-bit floating-point conversion instructions
  ;   RDRAND       30   ; supports RDRAND instruction
  ;   HYPERVISOR   31
  
  ; ---EDX---
  ;   FPU          0    ; OnChip Floating-point Unit 
  ;   VME          1    ; Virtual 8086 Mode Enhancements
  ;   DE           2    ; Debugging Extensions
  ;   PSE          3    ; Page Size Extension. Large pages of size 4 MByte are supported,
  ;   TSC          4    ; Time Stamp Counter. The RDTSC instruction is supported
  ;   MSR          5    ; Model Specific Registers RDMSR and WRMSR Instructions
  ;   PAE          6    ; Physical Address Extension. Physical addresses greater than 32 bits are supported
  ;   MCE          7    ; Machine Check Exception. Exception 18 is defined for Machine Checks, including CR4.MC
  ;   CX8          8    ; CMPXCHG8B Instruction. The compare-and-exchange 8 bytes (64 bits) instruction is supported
  ;   APIC         9    ; APIC On-Chip.
  ;                                           ; Reserved
  ;   SEP          11   ; SYSENTER and SYSEXIT Instructions.
  ;   MTRR         12   ; Memory Type Range Registers. MTRRs are supported
  ;   PGE          13   ; Page Global Bit. The global bit is supported in paging-structure entries that map a page
  ;   MCA          14   ; Machine Check Architecture
  ;   CMOV         15   ; Conditional Move Instructions
  ;   PAT          16   ; Page Attribute Table. Page Attribute Table is supported.
  ;   PSE36        17   ; 36-Bit Page Size Extension. 4-MByte pages addressing physical memory beyond 4 GBytes are supported with 32-bit paging
  ;   PSN          18   ; Processor Serial Number. The processor supports the 96-bit processor identification number feature and it's enabled
  ;   CLFLUSH      19   ; CLFLUSH Instruction
  ;   DS           21   ; Debug Store. The processor supports the ability to write debug information into a memory resident buffer
  ;   ACPI         22   ; Thermal Monitor and Software Controlled Clock Facilities
  ;   MMX          23   ; Intel MMX Technology. The processor supports the Intel MMX technology
  ;   FXSR         24   ; FXSAVE and FXRSTOR Instructions
  ;   SSE          25   ; SSE extensions
  ;   SSE2         26   ; SSE2 extensions
  ;   SS           27   ; Self Snoop
  ;   HTT          28   ; Max APIC IDs reserved field is Valid.
  ;   TM           29   ; The processor implements the thermal monitor automatic thermal control circuitry (TCC)
  ;   IA64         30   ; Intel Itanium 64
  ;   PBE          31   ; Pending Break Enable
    
  
  ; --------------------------------------------------
  ; INPUT EAX = 07h AND ECX = 0h: Returns Feature Information 
  ; --------------------------------------------------
  ; Returns in EAX: Bits 31 - 00: Reports the maximum input value for supported leaf 7 sub-leaves. 
  ; Retruns in EBX, ECX, EDX:
  
  ;   ---EBX---  
  ;   FSGSBASE           0    ; Supports RDFSBASE/RDGSBASE/WRFSBASE/WRGSBASE 
  ;   IA32_TSC_ADJUST    1    ; Intel Itanium TSC Adjust
  ;   SGX                2    ; Supports Intel® Software Guard Extensions
  ;   BMI1               3    ; BMI1
  ;   HLE                4    ; HLE
  ;   AVX2               5    ; AVX2 (AVX256 extended instruction set)
  ;   FDP_EXCPTN_ONLY    6    ; x87 FPU Data Pointer updated only on x87 exceptions
  ;   FDP_SMEP           7    ; Supports Supervisor-Mode Execution Prevention
  ;   FDP_BMI2           8    ; BMI2
  ;   FDP_REB            9    ; spports Enhanced REP MOVSB/STOSB
  ;   FDP_INVPCID        10   ; supports INVPCID instruction For system software that manages process-context identifiers
  ;   FDP_RTM            11   ; RTM???
  ;   FDP_RDTM           12   ; Supports Intel® Resource Director Technology (Intel® RDT) Monitoring capability
  ;   
  ;   FDP_MPX            14   ; Supports Intel® Memory Protection Extensions
  ;   FDP_RDTA           15   ; Supports Intel® Resource Director Technology (Intel® RDT) Allocation capability
  ;   
  ;   AVX512F            16
  ;   AVX512DQ           17   
  ;   FDP_RDSEED         18   ; RDSEED ??? 
  ;   FDP_ADX            19   ; ADX ??? 
  ;   FDP_SMAP           20   ; Supports Supervisor-Mode Access Prevention (And the CLAC/STAC instructions)
  ;   AVX512FMA          21
  ;   
  ;   FDP_CLFLUSHOPT     23   ; CLFLUSHOPT ???
  ;   
  ;   AVX512PF           26
  ;   AVX512ER           27
  ;   AVX512CD           28
  ;   SHA                29   ; SHA Instruction support
  ;   AVX512BW           30
  ;   AVX512VL           31
  ;   
  ;   ---ECX---
  ;   AVX512VBMI         0    ; AVX512VBMI
  ;   AVX512VBMI2        6    ; AVX512VBMI2
  ;   AVX512VNNI         11   ; AVX512VNNI
  ;   AVX512BITALG       12   ; AVX512BITALG
  ;   AVX512POPCNT       14   ; AVX512POPCNT
  ;   
  ;   ---EDX---
  ;   AAVX512FMAPS        3    ; AVX512FMAPS

  ;  --------------------------------------------------
  ;- Structure Definitions
  ;- --------------------------------------------------
  
  Structure TCPU_Feature
    Name.s
    Description.s
    Register.s{3}     ; CPUID return Feature in Register EAX, EBX, ECX, EDX
    FC.l              ; CPUID Functiion Code, CPUID(FC)
    BitNo.l           ; Feature BitNo
    xState.l          ; Feature supported = State[#False, #True]
  EndStructure
  
  Structure TCPU_Info
    xCpuIdSupported.i
    CPU_VendorID.s
    CPU_String.s
    CPU_SerialNo.q
    CPU_Cores.l         ; No of Cores (physical cors incl. hypertreaded)
    CPU_Stepping.l
    CPU_Model.l
    CPU_Family.l
    CPU_Type.l  
  EndStructure
  
  ;  --------------------------------------------------
  ;- Declare Puclic Functions
  ;- --------------------------------------------------
  
  Declare.i CPUID (function.l, *EAX, *EBX, *ECX, *EDX) ; This wraps the CPUID instruction.
  
  Declare.i CpuFeature(Feature=#CPU_FEAT_SSE)
  Declare.i GetCpuInfo(*out.TCPU_Info)
    
  Declare.i GetFeatureList(List lstFeatures.TCPU_Feature(), cfgOnlyActive_Features=#True)
  Declare.i GetActiveCoreNo()

  Declare.q ReadTimeStampCounter()     ; RDTSC
  Declare.i CPU_MHz(CalculationTime_ms.d = 10)
 
EndDeclareModule

Module CPU
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Global _CPU_Info.TCPU_Info
  Global Dim _CPU_Features.TCPU_Feature(#CPU_TotalNoOfFeatures-1)
  
  ;  --------------------------------------------------
  ;- Module Implementation
  ;- --------------------------------------------------

  Procedure.i _CPUID_IsSupported()
  ; ======================================================================
  ;  NAME: _CPUID_IsSupported
  ;  DESC: Checks if CPUID is supported
  ;  DESC: on AMD/Intel x64 Processors CPUID is always supported
  ;  DESC: It was introduced in 1993 with the Pentium CPUs
  ;  DESC: But better to do a check bevor calling !CPUID functions
  ;  RET : #TRUE if supported
  ; ====================================================================== 
    
    DisableDebugger
    
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
        !JNE @f
          !XOR EAX, EAX   ; ProcedureReturn #False
          !RET
        !@@:
        !MOV EAX, 1       ; ProcedureReturn #True
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
      
    CompilerElse
      
      ProcedureReturn #False
      
    CompilerEndIf
    EnableDebugger
  EndProcedure    
  
  Procedure.i CPUID (Function.l, *EAX.Integer, *EBX.Integer, *ECX.Integer, *EDX.Integer)
  ; ======================================================================
  ;  NAME: CPUID
  ;  DESC: This wraps the CPUID instruction. And copies the return values
  ;  DESC: from CPUID to 4 Variables. CPID returns the values direct in
  ;  DESC: the x86 Registers EAX, EBX, ECX, EDX
  ;  VAR(function.l): the numerical ID of the requested level of information 
  ;  VAR(*EAX): Pointer to an .Integer to receive EAX after !CPUID
  ;  VAR(*EBX): Pointer to an .Integer to receive EBX after !CPUID
  ;  VAR(*ECX): Pointer to an .Integer to receive ECX after !CPUID
  ;  VAR(*EDX): Pointer to an .Integer to receive EDX after !CPUID
  ;  RET : TRUE if succseed
  ; ====================================================================== 
    
    DisableDebugger
    
    Static xInit, xCpuIdSupported

    ; more informations for the CPUID instruction you can find here:
    ; https://c9x.me/x86/html/file_module_x86_id_45.html
    ; https://www.lowlevel.eu/wiki/CPUID
    If *EAX And *EBX And *ECX And *EDX
      
      If Not xInit
        xCpuIdSupported = _CPUID_IsSupported()
        xInit = #True
      EndIf
      
      If xCpuIdSupported
        
        CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
          CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)  
            !MOV EAX, DWORD [p.v_Function]
            !XOR ECX, ECX     ; Subleave = 0
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
            !XOR ECX, ECX     ; Subleave = 0
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
          Protected reg_a, reg_b, reg_c, reg_d        
          ; !unsigned int reg_a, reg_b, reg_c, reg_d;       
          
          !asm volatile ("cpuid;"  
          !: "=a" (v_reg_a), "=b" (v_reg_b), "=c" (v_reg_c), "=d" (v_reg_d)	
          !: "0" (v_function)
          !);
          ; !p_eax->f_i=v_reg_a;
          ; !p_ebx->f_i=v_reg_b;
          ; !p_ecx->f_i=v_reg_c;
          ; !p_edx->f_i=v_reg_d;
          
          *EAX\i = reg_a
          *EBX\i = reg_b
          *ECX\i = reg_c
          *EDX\i = reg_d
         CompilerEndIf
        ProcedureReturn #True
        
      Else
        *EAX = 0 : *EBX = 0 : *ECX = 0 : *EDX = 0 
        ProcedureReturn #False
      EndIf
      
    Else 
      ProcedureReturn #False
    EndIf
    
    EnableDebugger   
  EndProcedure
  
  Procedure.i CpuFeature(Feature=#CPU_FEAT_SSE)
  ; ======================================================================
  ;  NAME: CpuFeature
  ;  DESC: Returns Feature present or not
  ;  VAR(Feature) : Feature Constant #CPU_FEAT_{FeatureName}  
  ;  RET.i : #True If Feature is supported
  ; ====================================================================== 
    Protected xRet
    
    If Feature <= (#CPU_TotalNoOfFeatures-1)
     ; Debug Feature
      ProcedureReturn _CPU_Features(Feature)\xState
    EndIf
    
    ProcedureReturn 0 
  EndProcedure
  
  Procedure.i GetCpuInfo(*out.TCPU_Info)
  ; ======================================================================
  ;  NAME: GetCpuInfo
  ;  DESC: Get the CPU Info Sturcture
  ;  VAR(*out) : Pointer to TCPU_Info Structure to receive the data
  ;  RET.i : *out
  ; ====================================================================== 
    
    If *out
      CopyStructure(_CPU_Info, *out, TCPU_Info)  
    EndIf
    
    ProcedureReturn *out
  EndProcedure
  
  Procedure.i GetFeatureList(List lstFeatures.TCPU_Feature(), xSupportedFeaturesOnly=#True)
  ; ======================================================================
  ;  NAME: GetFeatureList
  ;  DESC: Get all Features of the CPU in a List
  ;  DESC: 
  ;  VAR(List lstFeatures) : List to receive the Features
  ;  VAR(xSupportedFeaturesOnly) : #False: get all Features, #True get only supported Featuers
  ;  RET.i : #TRUE if CPUID is supported
  ; ====================================================================== 
    Protected I 
    
    ClearList(lstFeatures())
    
    For I = 0 To ArraySize(_CPU_Features())
      If _CPU_Features(I)\xState Or (Not xSupportedFeaturesOnly)
        AddElement(lstFeatures())
        lstFeatures() = _CPU_Features(I)
      EndIf
    Next
    
    ProcedureReturn _CPU_Info\xCpuIdSupported
  EndProcedure
  
  Procedure.i GetActiveCoreNo()
  ; ======================================================================
  ;  NAME: GetActiveCoreNo
  ;  DESC: Get the actual active CoreNo
  ;  DESC: 
  ;  RET.i : Active CPU Core No 
  ; ====================================================================== 
    Protected mEAX, mEBX, mECX, mEDX     
    Protected ActiveCoreNo
    ; FunctionCode = 1
    ; EBX[24..31] = InitialAPICID; Active CoreNo    
    If CPUID(1, @mEAX, @mEBX, @mECX, @mEDX)
      ActiveCoreNo = (mEBX >> 24) & $FF
    EndIf
    
    ProcedureReturn ActiveCoreNo
  EndProcedure
   
  Procedure.q ReadTimeStampCounter()     ; RDTSC
  ; ======================================================================
  ;  NAME: ReadTimeStampCounter
  ;  DESC: Reads the CPU Tick Counter
  ;  DESC: A counter incremented +1 at each CPU cycle
  ;  RET.q : CPU ticks counted with the CPU's operating frequency 
  ; ====================================================================== 
    DisableDebugger
    
    CompilerIf #PB_Compiler_Backend=#PB_Backend_C
    ; --------------------------------------------------
    ;   C-Backend
    ; --------------------------------------------------
    
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64 Or #PB_Compiler_Processor = #PB_Processor_x86 
        
        Protected t.q
        !unsigned hi, lo;
        !__asm__ __volatile__ ("lfence\n rdtsc\n lfence" : "=a"(lo), "=d"(hi));
        !v_t =((unsigned long long)lo)|(((unsigned long long)hi)<<32 );
        ProcedureReturn t
         
      CompilerElseIf #PB_Compiler_Processor = #PB_Processor_Arm64 Or #PB_Compiler_Processor = #PB_Processor_Arm32 
        ; ARM x32/x64
        Protected pmuseren.l,pmcntenset.l,pmccntr.l;
        !asm volatile("mrc p15, 0, %0, c9, c14, 0" : "=r"(v_pmuseren));
        If pmuseren & 1 
          !asm volatile("mrc p15, 0, %0, c9, c12, 1" : "=r"(v_pmcntenset));
          If pmcntenset & $80000000 
            !asm volatile("mrc p15, 0, %0, c9, c13, 0" : "=r"(v_pmccntr));
            t = pmccntr
            ProcedureReturn t << 6 
          EndIf 
        EndIf 
         
      CompilerEndIf 
     
    CompilerElse
      
    ; --------------------------------------------------
    ;   ASM-Backend x64 / x32
    ; --------------------------------------------------
      
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        
        ; RDTSC transfers TimeStampCounter to EDX, EAX (on x32 and x 64)
        !RDTSC
        ; on x64 a Quad is returned as RAX, so we have to combine hi and lo in RAX
        !SHL RDX, 32   ; EDX to RDX_Hi
        !OR RAX, RDX
        ProcedureReturn
          
      CompilerElse  ; x32
        
        ; RDTSC transfers TimeStampCounter to EDX, EAX (on x32 and x 64)
        !RDTSC
        ; on x32 a Quad is returned as EDX, EAX
        ProcedureReturn ; return the TimeStampCounter [EDX, EAX} on x32 [RAX] on x64
         
      CompilerEndIf
    
    CompilerEndIf
    EnableDebugger
  EndProcedure
    
  Procedure.i CPU_Mhz(CalculationTime_ms.d = 10)
  ; ======================================================================
  ; NAME: CPU_Mhz
  ; DESC: Calcualtes the CPU Mhz in an exact way
  ; VAR(CalculationTime_ms.d = 10): Time in [ms] used for calculaton
  ; RET.i : CPU Mhz rounded to full Mhz
  ; ====================================================================== 
    Protected.q ticks, ms
    Protected ret.d
    
    ; to calculate the ecact Frequency we use the Microsecond Timer
    ; and count both, microseconds and ticks.
    ; if we devide ticks/microseconds we get F[Mhz]
    ms = PX::ElapsedMicroseconds()
    ticks = ReadRuntimeCounter()
    
    Delay(CalculationTime_ms)
    
    ms = PX::ElapsedMicroseconds() -ms
    ticks = ReadRuntimeCounter() - ticks
    ms = PX::AbsQ(ms)
    ticks = PX::AbsQ(ticks)
    
    ret = ticks/ms
    
;     Debug "msec = " + Str(ms)
;     Debug "tcks = " + Str(ticks)
;     Debug "F = " + StrD(ret)
    
    ; Ticks/Microseconds = F[Mhz]
    ProcedureReturn Round(ret, #PB_Round_Nearest)
  EndProcedure

  ;- --------------------------------------------------
  ;- Initalisation
  ;- --------------------------------------------------
     
  Procedure _Init()
    Protected mEAX, mEBX, mECX, mEDX     
    Protected I, BitNo, FC, FeatureFlag, xSupported
    Protected HighestLeaf, HighestLeafEx
    Protected Name$, No$, Text$
    Protected NewList lstFeatures.TCPU_Feature()
   
    With _CPU_Info
      \xCpuIdSupported = #False
      \CPU_VendorID = #Null$
      \CPU_String = #Null$
      \CPU_SerialNo = 0
      \CPU_Cores = 0 ; CountCPUs()
    EndWith
    
    If CPUID(0, @mEAX, @mEBX, @mECX, @mEDX)
      HighestLeaf = mEAX 
      
      With _CPU_Info
        \xCpuIdSupported  = #True 
        \CPU_VendorID = PeekS(@mEBX, 4, #PB_Ascii) + PeekS(@mEDX, 4, #PB_Ascii) + PeekS(@mECX, 4, #PB_Ascii)
      EndWith
      
      ; **************************************************
      ;  Features CPUID(1)
      ; **************************************************      
      FC = 1
      If CPUID(FC, @mEAX, @mEBX, @mECX, @mEDX)
        ; FunctionCode 1:
        ; EAX[0..3] = SteppingID;
        ; EAX[4..7] = Model;
        ; EAX[8..11] = Family;
        ; EAX[12..13] = ProcessorType;
        ; EAX[14..15] = Reserved;
        ; EAX[16..19] = ExtendedModel;
        ; EAX[20..23] = ExtendedFamily;
        ; EAX[24..31] = Reserved;
          
        ; EBX[0..7] = BrandIndex;
        ; EBX[8..15] = CLFLUSHLineSize;
        ; EBX[16..23] = Reserved or Number or Cores;
        ; EBX[24..31] = InitialAPICID; Active CoreNo
        ; ECX = FeatureFlags;
        ; EDX = FeatureFlags;
  
        With _CPU_Info
          ; EAX
          \CPU_Stepping = mEAX & $F           ; Bit [0..3]
          \CPU_Model =    mEAX>>4 & $F        ; Bit [4..7]  Base Model
          \CPU_Model = \CPU_Model | ((mEAX>>16 & $F)<<4) ; Bit [16..19] Extended Model
          \CPU_Family =   mEAX>>8 & $F        ; Bit [8..11] Base Family
          \CPU_Family =   \CPU_Family + mEAX>>20 & $FF     ; Bit [20..27] Extended Family
          \CPU_Type =     mEAX>>12 & $F     ; Bit [12..13]
          ; EBX
          \CPU_Cores =    mEBX>>16 & $FF    ; Bit [16..23]        
        EndWith
        
        ; --------------------------------------------------
        ;  Feature Flags from ECX Register
        ; --------------------------------------------------
        Restore FeatECX   
        Repeat
          Read.s Name$
          If Name$ = #EOT$
            Break
          EndIf
          
          Read.s No$
          Read.s Text$
          
          BitNo = Val(No$)
          FeatureFlag = 1 << BitNo
          xSupported = Bool(mECX & FeatureFlag)
          
          AddElement(lstFeatures())
          With lstFeatures()
            \Name = Name$
            \Register = "ECX"
            \FC = FC
            \BitNo = BitNo
            \Description = Text$
            \xState = xSupported
          EndWith      
        ForEver
        
        ; --------------------------------------------------
        ;  Feature Flags from EDX Register
        ; --------------------------------------------------
        Restore FeatEDX    
        Repeat
          Read.s Name$
          If Name$ = #EOT$
            Break
          EndIf
          
          Read.s No$
          Read.s Text$
          
          BitNo = Val(No$)
          FeatureFlag = 1 << BitNo
          xSupported = Bool(mEDX & FeatureFlag)
          
          AddElement(lstFeatures())
          With lstFeatures()
            \Name = Name$
            \Register = "EDX"
            \FC = FC
            \BitNo = BitNo  
            \Description = Text$
            \xState = xSupported
          EndWith      
        ForEver
      EndIf ; CPUID(1)
    
      ; **************************************************
      ;  Features CPUID(7)
      ; **************************************************
      FC = 7
      If CPUID(FC, @mEAX, @mEBX, @mECX, @mEDX) 
        
        ; --------------------------------------------------
        ;  Flags from EBX Register
        ; --------------------------------------------------
        Restore FeatExEBX
        Repeat
          Read.s Name$
          If Name$ = #EOT$
            Break
          EndIf
          
          Read.s No$
          Read.s Text$
          
          BitNo = Val(No$)
          FeatureFlag = 1 << BitNo
          xSupported = Bool(mEBX & FeatureFlag)
          
          AddElement(lstFeatures())
          With lstFeatures()
            \Name = Name$
            \Register = "EBX"
            \FC = FC
            \BitNo = BitNo  
            \Description = Text$
            \xState = xSupported
          EndWith      
        ForEver
        
        ; --------------------------------------------------
        ;  Flags from ECX Register
        ; --------------------------------------------------
        Restore FeatExECX
        Repeat
          Read.s Name$
          If Name$ = #EOT$
            Break
          EndIf
          
          Read.s No$
          Read.s Text$
          
          BitNo = Val(No$)
          FeatureFlag = 1 << BitNo
          xSupported = Bool(mECX & FeatureFlag)
          
          AddElement(lstFeatures())
          With lstFeatures()
            \Name = Name$
            \Register = "ECX"
            \FC = FC
            \BitNo = BitNo  
            \Description = Text$
            \xState = xSupported
          EndWith      
        ForEver
        
        ; --------------------------------------------------
        ;  Flags from EDX Register
        ; --------------------------------------------------
        Restore FeatExEDX
        Repeat
          Read.s Name$
          If Name$ = #EOT$
            Break
          EndIf
          
          Read.s No$
          Read.s Text$
          
          BitNo = Val(No$)
          FeatureFlag = 1 << BitNo
    ;       Debug "BitNO = " + BitNo
    ;       Debug "FeatureFlag = %" + Bin(FeatureFlag)
    
          xSupported = Bool(mEDX & FeatureFlag)
          
          AddElement(lstFeatures())
          With lstFeatures()
            \Name = Name$
            \Register = "EDX"
            \FC = FC
            \BitNo = BitNo  
            \Description = Text$
            \xState = xSupported
          EndWith      
        ForEver
        
      EndIf ; If CPUID(7)
        
      ; $80000000 : GetHighestExtendedLeaf
      If CPUID($80000000, @mEAX, @mEBX, @mECX, @mEDX)        
        HighestLeafEx = mEAX & $7FFFFFFF
        
        Text$ = #Null$
        If HighestLeafEx >= 4      ; checks if the required leaves are supported
          For I = $80000002 To $80000004
            If CPUID(I, @mEAX, @mEBX, @mECX, @mEDX)
              Text$ = Text$ + PeekS(@mEAX, 4, #PB_Ascii) + PeekS(@mEBX, 4, #PB_Ascii) + PeekS(@mECX, 4, #PB_Ascii) + PeekS(@mEDX, 4, #PB_Ascii)         
            EndIf  
          Next
          _CPU_Info\CPU_String = Text$ 
        EndIf       
      EndIf
      
      ; CPU Serial No
      If HighestLeafEx >= 3      ; checks if the required leaves are supported
        CPU::CPUID ($80000003, @mEAX, @mEBX, @mECX, @mEDX)
        PokeL(@_CPU_Info\CPU_SerialNo, mECX)
        PokeL(@_CPU_Info\CPU_SerialNo+4, mEDX)      
      EndIf
      
      Debug "internal CPU_Feature Array Debug from Procedure _Init()"
      SortStructuredList(lstFeatures(), #PB_Sort_Ascending, OffsetOf(TCPU_Feature\Name), TypeOf(TCPU_Feature\Name))
      I=0
      ForEach lstFeatures()
        _CPU_Features(I) = lstFeatures()
        Debug Str(I) + " : " + _CPU_Features(I)\Name + " = " + Str(_CPU_Features(I)\xState)
        I+1
      Next
      
    EndIf  ; If CPUID(0)
  EndProcedure
  
  _Init()
  
  ;- --------------------------------------------------
  ;- Datasection
  ;- --------------------------------------------------
  
  DataSection
    ; EDX  FlagName, BitNo, Description
    ; Features CPUID(FC = 1)
    FeatEDX:
    Data.s "FPU",   "0","Onboard x87 FPU"
    Data.s "VME",   "1", "Virtual 8086 mode extensions (such As VIF, VIP, PIV)"
    Data.s "DE",    "2", "Debugging extensions (CR4 bit 3)"
    Data.s "PSE",   "3", "Page Size Extension" 
    Data.s "TSC",   "4", "Time Stamp Counter" 
    Data.s "MSR",   "5", "Model-specific registers"
    Data.s "PAE",   "6", "Physical Address Extension"
    Data.s "MCE",   "7", "Machine Check Exception"
    Data.s "CX8",   "8", "CMPXCHG8 (compare-And-Swap) instruction" 
    Data.s "APIC",  "9", "Onboard Advanced Programmable Interrupt Controller" 
    ; Data.s "10", "10", "reserved"    
    Data.s "SEP",   "11", "SYSENTER And SYSEXIT instructions"
    Data.s "MTRR",  "12", "Memory Type Range Registers" 
    Data.s "PGE",   "13", "Page Global Enable bit in CR4" 
    Data.s "MCA",   "14", "Machine check architecture" 
    Data.s "CMOV",  "15", "Conditional move And FCMOV instructions" 
    Data.s "PAT",   "16", "Page Attribute Table (reserved)"
    Data.s "PSE36", "17", "36-bit page size extension"
    Data.s "PSN",   "18", "Processor Serial Number"
    Data.s "CLFSH", "19", "CLFLUSH instruction (SSE2)"
    
    ; Data.s "20", "20", "reserved"  
    Data.s "DS",    "21", "Debug store: save trace of executed jumps"
    Data.s "ACPI",  "22", "Onboard thermal control MSRs For ACPI"
    Data.s "MMX",   "23", "MMX instructions" 
    Data.s "FXSR",  "24", "FXSAVE, FXRESTOR instructions, CR4 bit 9"
    Data.s "SSE",   "25", "SSE instructions (a.k.a. Katmai New Instructions)"
    Data.s "SSE2",  "26", "SSE2 instructions" 
    Data.s "SS",    "27", "CPU cache supports self-snoop" 
    Data.s "HTT",   "28", "Hyper-threading" 
    Data.s "TM",    "29", "Thermal monitor automatically limits temperature"
    Data.s "IA64",  "30", "IA64 processor emulating x86" 
    Data.s "PBE",   "31", "Pending Break Enable (PBE#PB_CPU_ pin) wakeup support"
    Data.s #EOT$
    
    ; ECX
    FeatECX:
    Data.s "SSE3",    "0", "Prescott New Instructions-SSE3 (PNI)"
    Data.s "PCMULQDQ","1", "PCLMULQDQ support"
    Data.s "DTES64",  "2", "64-bit Debug store (edx bit 21)"
    Data.s "MONITOR", "3", "MONITOR And MWAIT instructions (SSE3)"
    Data.s "DSCPL",   "4", "CPL qualified Debug store"
    Data.s "VMX",     "5", "Virtual Machine eXtensions"
    Data.s "SMX",     "6", "Safer Mode Extensions (LaGrande)"
    Data.s "EST",     "7", "Enhanced SpeedStep"
    Data.s "TM2",     "8", "Thermal Monitor 2"
    Data.s "SSSE3",   "9", "SSSE3 Supplemental SSE3 instructions"
    Data.s "CNXTID",  "10", "L1 Context ID"
    Data.s "SDBG",    "11", "IA32 Debug"
    Data.s "FMA",     "12", "Fused multiply-add (FMA3)"
    Data.s "CX16",    "13", "CMPXCHG16B instruction"
    Data.s "XTPR",    "14", "Can disable sending task priority messages"
    Data.s "PDCM",    "15", "Perfmon & Debug capability"
    
    ; Data.s "16",    "16", "reserved"  
    Data.s "PCID",    "17", "Process context identifiers (CR4 bit 17)"
    Data.s "DCA",     "18", "Direct cache access For DMA writes[10][11]"
    Data.s "SSE41",   "19", "SSE4.1 instructions"
    Data.s "SSE42",   "20", "SSE4.2 instructions"
    Data.s "X2APIC",  "21", "x2APIC support"
    Data.s "MOVBE",   "22", "MOVBE instruction (big-endian)"
    Data.s "POPCNT",  "23", "Population Count instruction. Count No of Bits set"
    Data.s "TSCDEADLINE", "24", "APIC supports one-shot operation using a TSC deadline value"
    Data.s "AES",     "25", "AES instruction set"
    Data.s "XSAVE",   "26", "XSAVE, XRESTOR, XSETBV, XGETBV"
    Data.s "OSXSAVE", "27", "XSAVE enabled by OS"
    Data.s "AVX",     "28", "Advanced Vector Extensions"
    Data.s "F16C",    "29", "F16C (half-precision) FP support"
    Data.s "RDRND",   "30", "RDRAND (on-chip random number generator) support"
    Data.s "HYPERVISOR", "31", "Running on a hypervisor (always 0 on a real CPU, but also With some hypervisors)"
    Data.s #EOT$
    
    ; Extended features CPUID(FC = 7)
    FeatExEBX:
    Data.s "FSGSBASE","0", "RDFSBASE/RDGSBASE/WRFSBASE/WRGSBASE"
    Data.s "IA32_TSC_ADJUST", "1", "Intel Itanium TSC Adjust"
    Data.s "SGX",     "2", "Intel® Software Guard Extensions"
    Data.s "BMI1",    "3", "BMI1"
    Data.s "HLE",     "4", "HLE"
    Data.s "AVX2",    "5", "AVX2 (AVX256 extended instruction set)"
    Data.s "FDP_EXCPTN_ONLY", "6", "x87 FPU Data Pointer updated only on x87 exceptions"
    Data.s "SMEP",    "7", "Supervisor-Mode Execution Prevention"
    Data.s "BMI2",    "8", "BMI2"
    Data.s "REP",     "9", "Enhanced REP MOVSB/STOSB"
    Data.s "INVPCID", "10", "INVPCID instruction For system software that manages process-context identifiers"
    Data.s "RTM",     "11", "RTM"
    Data.s "RDTM",    "12", "Intel® Resource Director Technology (Intel® RDT) Monitoring capability"
    
    Data.s "MPX",     "14", "Intel® Memory Protection Extensions"
    Data.s "RDTA",    "15", "Intel® Resource Director Technology (Intel® RDT) Allocation capability"
    Data.s "AVX512F", "16", "AVX512F"
    Data.s "AVX512DQ","17", "AVX512DQ"
    
    Data.s "RDSEED",  "18", "RDSEED"
    Data.s "ADX",     "19", "ADX"
    Data.s "SMAP",    "20", "SMAP"
    Data.s "AVX512FMA","21", "AVX512, fused multiply add"
   
    Data.s "CLFLUSHOPT", "23", "CLFLUSHOPT"
    
    Data.s "AVX512PF","26", "AVX512PF"
    Data.s "AVX512ER","27", "AVX512ER"
    Data.s "AVX512CD","28", "AVX512CD"  
    Data.s "SHA",     "29", "SHA Instruction support"
    Data.s "AVX512BW","30", "AVX512ER"
    Data.s "AVX512VL","31", "AVX512CD"
    Data.s #EOT$
    
    FeatExECX:
    Data.s "AVX512VBMI",  "0", "AVX512VBMI"
    Data.s "AVX512VBMI2", "6", "AVX512VBMI2"
    Data.s "AVX512VNNI",  "11", "AVX512VNNI"
    Data.s "AVX512BITALG","12", "AVX512BITALG"
    Data.s "AVX512POPCNT","14", "AVX512POPCNT"
    Data.s #EOT$
    
    FeatExEDX:
    Data.s "AVX512FMAPS",  "3", "AVX512FMAPS"
    Data.s #EOT$

  EndDataSection
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; --------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; -------------------------------------------------- 
  
  EnableExplicit
  UseModule CPU
  Define I
  Define text$, backend$, leaf
  Define EAX, EBX, ECX, EDX
  Define.l HighestExt
  
  Define cc$, l$, Bit$    ; code, line and Bit-string

  
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
  
  backend$ + " : PB Version : " + #PB_Compiler_Version
  
  text$ = "Backend : " + backend$ 
  Debug "Code run in : " + text$
  Debug ""
  
  Define CPU_Info.TCPU_Info
  
  GetCpuInfo(CPU_Info)
  
  Debug "--- CPU Info ---"
  If CPU_Info\xCpuIdSupported
    text$ + #CRLF$ + "CPUID is supported."        
  Else
    text$ = "CPUID is not supported."
  EndIf
  
  With CPU_Info
    Debug "Vendor ID = " + \CPU_VendorID
    Debug "CPU String = " + \CPU_String
    Debug "No of Cores = " + \CPU_Cores
    Debug "SerialNo = $" + Hex(\CPU_SerialNo, #PB_Quad)
    Debug "Family = " + \CPU_Family
    Debug "Model = " + \CPU_Model
    Debug "Stepping = " + \CPU_Stepping
    Debug "Type  = " + \CPU_Type
  EndWith
  Debug "-----------------"
  Debug "Running on Core " + GetActiveCoreNo()
  Debug "F = " + CPU_MHz() + " Mhz"
  
  NewList lstFeatures.TCPU_Feature()  
  GetFeatureList(lstFeatures(), #True) 
  SortStructuredList(lstFeatures(), #PB_Sort_Ascending, OffsetOf(TCPU_Feature\Name), TypeOf(TCPU_Feature\Name))
  Debug ""
  Debug "--- CPU Featurelist --- formated to Table Columns with PX::ColumnText()"

  I=0
  ForEach lstFeatures()
    With lstFeatures()
      ; PX::ColumnText creates a fixed spaced String to use for printout Table Columns
      Bit$ = PX::ColumnText(Str(\BitNo), 2, PX::#PX_AlignRight)
      l$ = PX::ColumnText(\Name, 12, PX::#PX_AlignLeft) + ": "
      l$ + PX::ColumnText(\Register + "[" + Bit$ + "]", 8, PX::#PX_AlignLeft) + ": "
      l$ + \Description
      Debug l$
      ; Debug \Name + " : " + \Description + " : " + \Register + "[" + Str(\BitNo) +"]"
    EndWith
    I + 1
  Next
  Debug "------------------------"
    
  Macro mac_FCst(name)
    #CPU_FEAT_#name  
  EndMacro
  
  Macro mac_DbgCpuFeat(_name_)
    Debug Str(mac_FCst(_name_)) + " : CPU has " + PX::QuoteIt(_name_) + " = " + Str(CpuFeature(mac_FCst(_name_)))
  EndMacro
  
  ; Test CPUHas Function to get supported Features
  Debug ""
  Debug Str(#CPU_FEAT_MMX) + " : CPU has MMX = " + Str(CpuFeature(#CPU_FEAT_MMX))
  ;mac_DbgCpuFeat(MMX)
  mac_DbgCpuFeat(SSE)
  mac_DbgCpuFeat(SSE2)
  mac_DbgCpuFeat(SSE3)
  mac_DbgCpuFeat(SSE41)
  mac_DbgCpuFeat(SSE42)
    
  ; --------------------------------------------------
  ; Create Enumeration eCPU_Feature and copy it to ClipBoard
  ; --------------------------------------------------
  GetFeatureList(lstFeatures(), #False) ; GetAllFeatures
  SortStructuredList(lstFeatures(), #PB_Sort_Ascending, OffsetOf(TCPU_Feature\Name), TypeOf(TCPU_Feature\Name))
  
  cc$ = #TAB$ + "Enumeration eCPU_Feature" + #CRLF$
  I=0
  ForEach lstFeatures()
    With lstFeatures()
      ; PX::ColumnText creates a fixed spaced String to use for printout Table Columns
      Bit$ = PX::ColumnText(Str(\BitNo), 2, PX::#PX_AlignRight)
      l$ = PX::ColumnText("#CPU_FEAT_" + \Name, 28, PX::#PX_AlignLeft) + ";"
      l$ + PX::ColumnText(Str(I), 3, PX::#PX_AlignRight) + " : "
      l$ + PX::ColumnText(\Register + "[" + Bit$ + "]", 8, PX::#PX_AlignLeft)
      l$ + PX::ColumnText("FC=" + Str(\FC), 4, PX::#PX_AlignLeft) + " : " + \Description
      ;l$ = "#CPU_FEAT_" + \Name + Space(20-Len(\Name)) +"; " + Str(I) + " : " + \Register + "[" + Bit$ + "]" + Space(3-Len(Bit$)) +"FC=" + Str(\FC) + " : " + \Description
      cc$ = cc$ + #TAB$ + #TAB$ + l$ + #CRLF$
    EndWith
    I+1
  Next
  cc$ + #TAB$ + "EndEnumeration" + #CRLF$
  
  SetClipboardText(cc$)
  ; --------------------------------------------------
 
  
  Define f.d
  f= CPU_MHz()
  Debug "CPU Frequency ="+ StrD(f) +"MHz"
  ; MessageRequester("CPU Frequency", StrD(f) +"MHz")
CompilerEndIf

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 363
; FirstLine = 315
; Folding = -----
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.21 - C Backend (Windows - x64)