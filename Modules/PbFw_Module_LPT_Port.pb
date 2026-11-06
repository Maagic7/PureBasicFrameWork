; ==============================================================================
; NAME: Parallel Port Module 
; DESC: Modul zum Handling eines Parallel-Ports (Pseudo-OOP mit *This)
; VB6 konvertiert nach PB
; ==============================================================================

; ===========================================================================
;  Weitere benötigte Dateien:
; ===========================================================================
;
;  Die inpout32.dll in der Version für Windows 9x und NT/2k
;  https://github.com/ellysh/InpOut32

; ===========================================================================
;  LPT-Port Adressen
; ===========================================================================
;
;  ein LPT-Port ist an 3 Adressen möglich, normalerweise wie folgt, es ist
;  jedoch möglich, dass LPT1 nicht an 378h zu finden ist sondern an einer
;  der beiden Anderen. Die Adresse 3BCh ist angeblich kritisch, da
;  diese teilweise auch für Video statt LPT verwendet werden kann!

;     378h  : LPT1
;     278h  : LPT2
;     3BCh  : reserviert für in Videoadapter integrierte LPT-Controller
;             hier werden keine zusätzlichen ECP/EPP-Register unterstützt
;

;  Das Bios schreibt die PortAdressen der LPT;s in den Speicher:
;  nur leider kann man das zumidest unter Windows-NT-Plattformen
;  nicht direkt mit CopyMemory auslesen
;
;     408h  : LPT1 Basisadresse
;     40Ah  : LPT2 Basisadresse
;     40Ch  : LPT3 Basisadresse
;     40Eh  : LPT4 Basisadresse - 40Eh wird in PS/2 oder neuerem Bios meist für
;                                 die Extented Bios Area verwendet und ist daher
;                                 für LPT ungültig
;

; ===========================================================================
;   Zuordnung LPT-Port-Pins zu den Register-Bits
; ===========================================================================

; Register 0 = DatenRegister   : Adr 378
; Register 1 = StatusRegister  : Adr 379
; Register 2 = ControlRegister : Adr 37A

; BASE ADDRESS  (PDR) Data register (Read or Write)

;  Bit 0 - Pin 2 - Data Output 1
;  Bit 1 - Pin 3 - Data Output 2
;  Bit 2 - Pin 4 - Data Output 3
;  Bit 3 - Pin 5 - Data Output 4
;  Bit 4 - Pin 6 - Data Output 5
;  Bit 5 - Pin 7 - Data Output 6
;  Bit 6 - Pin 8 - Data Output 7
;  Bit 7 - Pin 9 - Data Output 8

; BASE ADDRESS + 1     (PSR) Status register (Read Only)

;  Bit 0 -        - Not used
;  Bit 1 -        - Not used
;  Bit 2 -        - Not used
;  Bit 3 - Pin 15 - ERROR Input
;  Bit 4 - Pin 13 - SELECT Input
;  Bit 5 - Pin 12 - PAPER END Input
;  Bit 6 - Pin 10 - ACKNOWLEDGE Input
;  Bit 7 - Pin 11 - BUSY Input

; BASE ADDRESS + 2     (PCR) Control register (Read or Write)

;  Bit 0 - Pin  1 - DATA STROBE Output
;  Bit 1 - Pin 14 - AUTO LINE FEED Output
;  Bit 2 - Pin 16 - INITIALIZE PRINTER Output
;  Bit 3 - Pin 17 - SELECT INPUT Output
;  Bit 4 -        - 0 = disable interrupt, 1 = enable interrupt
;  Bit 5 -
;  Bit 6 -
;  Bit 7 -


; ===========================================================================
;  SPP - Register
; ===========================================================================

; ------------------------------------------------------------------------
; Address         |  Register Name                       |  Read/Write
; ------------------------------------------------------------------------
; Base            |  Data Register                       |  Read/Write
; Base + 1        |  Status Register                     |  (Read)/Write
; Base + 2        |  Control Register                    |  Read/Write
; ------------------------------------------------------------------------

; ========================================================================
;           Status Register Bit Definitions : Base + 1
; ------------------------------------------------------------------------
;  Bit   |  Function                |  Low                  | High
; ------------------------------------------------------------------------
;  7     |  Busy (Low-Active!!!)    |  Busy                 | Not Busy
;  6     |  Acknowledge             |  Nack                 | Ack
;  5     |  Paper Status            |  No Paper             | Paper
;  4     |  Selection Status        |  Not Selected         | Selected
;  3     |  Error Status            |  No Error             | Error
;  2     |  Not Used                |  -                    | -
;  1     |  Not Used                |  -                    | -
; ------------------------------------------------------------------------
;  0     |  SPP: Not Used           |  -                    | -
;        |  EPP: TimeOut            |                       |
; ------------------------------------------------------------------------
; ACHTUNG: Bit 7 des Statusregisters (Busy) ist Low-Active, d.h. +5 Volt
;          auf dieser Leitung führen zu einer 0 im Bit, 0V zu einer 1.
;          Alle anderen Bits sind High-Active
; ========================================================================


; ========================================================================
;           Control Register Bit Definitions : Base + 2
; ------------------------------------------------------------------------
;  Bit   |  Function                |  Low                  | High
; ------------------------------------------------------------------------
;  7     |  (MSB) Not Used          |  -                    | -
;  6     |  Not Used                |  -                    | -
; ------------------------------------------------------------------------
;  5     |  SPP     : Not Used      |  -                    | -
;        |  EPP/ECP : DataMode      | Output                | Input
; ------------------------------------------------------------------------
;  4     |  Interrupt Control       | Interrupts Disabled   | Interrupts Enabled
;  3     |  Select                  | Not Selected          | Selcted
;  2     |  Initialize              | False                 | True
;  1     |  Auto Feed               | True                  | False
;  0     | (LSB) Strobe (Active-Low)| True                  | False
; ------------------------------------------------------------------------
; ACHTUNG: Bit 5 des Controlregisters ist im Standard SPP Mode nicht
;          verwendet, im falle eines Bidirektionalen Ports schaltet
;          es zwischen Daten Output und Input um!
; ========================================================================


; ========================================================================
;                             ECP - Register
; ========================================================================

; ------------------------------------------------------------------------
; Address         |  Port Name                           |  Read/Write
; ------------------------------------------------------------------------
; Base + 0        |  Data Port (SPP)                     |  Write
;                 |  ECP Address FIFO (ECP MODE)         |  Read/Write
; ------------------------------------------------------------------------
; Base + 1        |  Status Port (All Modes)             |  Read/Write
; ------------------------------------------------------------------------
; Base + 2        |  Control Port (All Modes)            |  Read/Write
; ------------------------------------------------------------------------
; Base + 400h     |  Data FIFO (Parallel Port FIFO Mode) |  Read/Write
;                 |  Data FIFO (ECP Mode)                |  Read/Write
;                 |  Test FIFO (Test Mode)               |  Read/Write
;                 |  Configuration Register A            |
;                 |  (Configuration Mode)                |  Read/Write
; ------------------------------------------------------------------------
; Base + 401h     |  Configuration Register B            |
;                 |  (Configuration Mode)                |  Read/Write
; ------------------------------------------------------------------------
; Base + 402h     |  Extended Control Register (ECR)     |
;                 |  (Used by all modes)                 |  Read/Write
; ========================================================================


; ========================================================================
;       Funktionen des Extended Control Register (ECR) : Base + 402h
; ------------------------------------------------------------------------
;  Bit      |  Function
; ------------------------------------------------------------------------
;  7:5      |  Selects Current Mode of Operation
;           |  000    Standard Mode, SPP
;           |  001    Byte Mode
;           |  010    Parallel Port FIFO Mode, Fast Centronics
;           |  011    ECP FIFO Mode
;           |  100    EPP Mode
;           |  101    Reserved
;           |  110    FIFO Test Mode
;           |  111    Configuration Mode
; ------------------------------------------------------------------------
;  4        |  ECP Interrupt Bit
; ------------------------------------------------------------------------
;  3        |  DMA Enable Bit
; ------------------------------------------------------------------------
;  2        |  ECP Service Bit
; ------------------------------------------------------------------------
;  1        |  FIFO Full
; ------------------------------------------------------------------------
;  0 (LSB)  |  FIFO Empty
; ========================================================================


; ========================================================================
;     ECP Configuration Register A : Base + 400h : nur im Config-Mode
; ------------------------------------------------------------------------
;  Bit      |  Function
; ------------------------------------------------------------------------
;  7        |  1 : Interrupts are level triggered
;           |  0 : Interrupts are edge triggered (Pulses)
; ------------------------------------------------------------------------
;  6:4      |  00h      Accepts Max. 16 Bit wide words
;           |  01h      Accepts Max.  8 Bit wide words
;           |  02h      Accepts Max. 32 Bit wide words
;           |  03h:07h  Reserved for future expansion
; ------------------------------------------------------------------------
;  3        |  Reserved
; ------------------------------------------------------------------------
;  2        |  Host Recovery : Pipeline/Transmitter Byte included in FIFO?
;           |  0 : In forward direction, the 1 byte in the
;           |      transmitter pipeline doesn;t affect FIFO Full.
;           |  1 : In forward direction, the 1 byte in the
;           |      transmitter pipeline is include as part of FIFO Full.
; ------------------------------------------------------------------------
;  1:0 (LSB)|  Host Recovery : Unsent byte(s) left in FIFO
;           |  00    Complete Pword
;           |  01    1 Valid Byte
;           |  10    2 Valid Bytes
;           |  11    3 Valid Bytes
; ========================================================================


; ========================================================================
;  ECP Configuration Register B : Base + 401h : nur im Config-Mode
; ------------------------------------------------------------------------
;  Bit      |  Function
; ------------------------------------------------------------------------
;  7        |  1  Compress outgoing Data Using RLE
;           |  0  Do Not compress Data
; ------------------------------------------------------------------------
;  6        |  Interrupt Status - Shows the Current Status of the IRQ Pin
; ------------------------------------------------------------------------
;  5:3      | Selects or Displays Status of Interrupt Request Line.
;           |  000   Interrupt Selected Via Jumper
;           |  001   IRQ 7
;           |  010   IRQ 9
;           |  011   IRQ 10
;           |  100   IRQ 11
;           |  101   IRQ 14
;           |  110   IRQ 15
;           |  111   IRQ 5
; ------------------------------------------------------------------------
;  2:0 (LSB)| Selects or Displays Status of the DMA Channel the Printer Card Uses
;           |  000   Uses a Jumpered 8 Bit DMA Channel
;           |  001   DMA Channel 1
;           |  010   DMA Channel 2
;           |  011   DMA Channel 3
;           |  100   Uses a Jumpered 16 Bit DMA Channel
;           |  101   DMA Channel 5
;           |  110   DMA Channel 6
;           |  111   DMA Channel 7
; ========================================================================


; ===========================================================================
;  EPP - Register
; ===========================================================================

; ------------------------------------------------------------------------
; Address         |  Port Name                           |  Read/Write
; ------------------------------------------------------------------------
;  Base + 0       |  Data Port    (SPP)                  |  Write
;  Base + 1       |  Status Port  (SPP)                  |  Read
;  Base + 2       |  Control Port (SPP)                  |  Write
;  Base + 3       |  Address Port (EPP)                  |  Read/Write
;  Base + 4       |  Data Port    (EPP)                  |  Read/Write
;  Base + 5       |  Undefined (16/32bit Transfers)      |
;  Base + 6       |  Undefined (32bit Transfers)         |
;  Base + 7       |  Undefined (32bit Transfers)         |
; ------------------------------------------------------------------------

; ===========================================================================
; Welcher Porttyp?
;                    SPP : Standard Parallel Port
;                    EPP : Extended Parallel Port
;                    ECP : Extended Centronics Port
; ===========================================================================

; - Übersetztung aus Jan;s Parallelport FAQ

; SPP (original), PS/2 (simple bidirectional), EPP, or ECP.
; Es gibt also verschiedene Porttypen und somit auch unterschiedliche Ansteuerungen
; Der Test erkennt nur den PortTyp der aktiviert ist. Wenn die erweiterten Einstellungen
; des ControllerChips abgeschaltet sind, werden diese nicht erkannt.
; Eigentlich alle neuen Controller bieten die Möglichkeit den Standart SPP-Mode zu simulieren
; Nun denkt man, man beginnt mit der Prüfung auf SPP und arbeitet sich langsam bis zum ECP hoch.
; Aber wenn der ECP Controller im Simulationmodus für SPP ist, fällt der Test auf  PS/2 bidirectional
; negativ aus.
;
; Also geht man den umgekehrten Weg und Testet zuerst auf ECP und arbeitet sich nach unten.
; So wie es Microsoft ECP Dokument (auf der Developer;s Network CD) beschreib.
;
; *** ECP erkennen: ***
;
; 1. extended ECP Control-Register (ECR) an der BasisAdresse + 402h lesen und überprüfen, ob
;    Bit 0 (fifo emty) =1 und Bit 1 (fifo full) =0 ist. Diese Bits sollten getrennt von den
;    Bits 0 und 1 im Control-Register an der BasisAdresse + 2 sein. Man kann das überprüfen,
;    indem man eines der Bits im Control-Register setzt und schaut, ob sich das entsprechende
;    Bit im ECP Register ändert.
;
; 2. Ein weiterer Test ist 34h ins ECR-Register zu schreiben und zurückzulesen. Die Bits 0 und 1
;    sind ReadOnly. Also wenn man 35h zurückliest hat man einen ECP-Port. Wenn man nun einen ECP
;    Port hat, kann man den internen Mode im ECP-Register setzen

;    ACHTUNG: ich habe festgestellt, daß man das Schreiben eines wilkürlichen Wertes in das
;             ECP-Control-Register bleiben lassen sollte, wenn man nachher nicht explicit
;             einen der folgenden Modes setzt. Da 34h den ECP mode setzt, unabhängig ob vorher
;             etwas anderes eingestellt war!

;     Interne ECP Modes:
;
;     000 SPP
;     001 Byte
;     010 Fast Centronics
;     011 ECP
;     100 EPP
;     101 Reserved
;     110 Test
;     111 Config


; *** EPP erkennen: ***
;
; zusätzlich zu den 3 Registern des Standard SPP hat ein ECP 4 weitere Register
; an der BasisAdresse +3 bis +6. Diese zusätzlichen Register bieten eine Möglichkeit
; auf EPP zu testen, indem man einige Werte in eines der EPP-Register schreibt und
; zurückliest, ähnlich wie man die Standardregister des SPP testet.
; Sind die Lesezugriffe erfolgreich, hat man wahrscheinlichst einen EPP Port.
; Es ist nicht ganz sicher, ob dieser Test bei allen EPPs arbeitet, da das EPP
; Handshake nicht komplett ist. Es gibt also keine Garantie für den Inhalt der Register
; nach dem Transfer-Timeout. Sicherheitshalber löscht man das EPP Timeout-Bit
; (Bit 0 des Statusports an BasisAdresse +1) nach jedem Schreib- oder Lesezugriff.
; Leider variert die Methode zum löschen des Bits mit den Controllern. Bei einigen
; Ports löscht man indem man eine 1 schreibt, andere löschen ganz einfach automatisch
; beim lesen des Statusregisters. Aber es gibt eigentlich keine, die das Bit in
; konventioneller Weise löschen, indem man eine 0 schreibt. Trotzdem sollte man dies
; auch tun, um ganz sicher zu gehen.

; Achtung 1: bei SMC chips (vielleicht auch anderen) kann ein gesetztes Timeoutbit den
;            Port bis zu einem Hardwarereset oder unbrachbar machen. Oder man löscht das Bit wieder

; Achtung 2: Man sollte nicht versuchen an der Adresse 3BCh auf EPP zu Testen. Dieses Register ist
;            nicht immer an dieser Adresse verfügbar und kann für Video verwendet werden.


; *** SPP erkennen: ***
;
; Für den SPP Test nimmt man auch die Try And Error Methode, indem man zwei Werte in das
; Datenregister schreibt und zurückliest. Dieser Test prüft nur das Datenregister nicht
; die Status und Control-Register. Dies sollte aber trotzdem reichen.
; die anderen Port-Typen EPP, ECP und PS/2 sollten diesen Test auch bestehen.

; *** PS/2 Port erkennen: ***
;
; Um einen einfachen Test auf Bidirectional auszuführen versucht man zuerst den Port
; in den Inputmode zu schalten, indem man eine 1 in Bit 5 des Control-Register
; (BasisAdresse + 2) schreibt. Ist der Port bidirektional, so geht der Portoutput in
; TriState. Dann schreibt man 2 Werte in das Datenregister und liest jeden zurück.
; Wenn der Ausgang TriState ist, dann schlagen die Leseversuche fehl und man hat
; meist sicher einen bidirektionalen Port. Liest man hingegen zurück, was man geschieben
; hat, verblieb der Port im Output-Zustand und ist nicht bidirektional.
; Aber man sollte nur auf PS/2 testen, nachdem man festgestellt hat, daß ein Port
; SPP, EPP oder ECP vorhanden ist, da man einen Fehler dazu verwendet um PS/2 zu erkennen.
; Ein nicht vorhandener Port würde den Test auf PS/2 bestehen!

DeclareModule LPT
  
  #LPT_notPresent             = 0     ; LPT Port not present
  #LPT_SPP                    = 1     ; SPP Standard Parallel Port
  #LPT_EPP                    = 2     ; EPP-Port : Extended Parallel Port
  #LPT_ECP                    = 3     ; ECP-Port : Extended Centronics Port
  
  #SPP_DataRegister           = 0     ; Offset of standard Data-Register (All Modes)
  #SPP_StatusRegister          = 1    ; Offset of standard Staus-Register (All Modes)
  #SPP_Controlregister         = 2    ; Offset of standard Control-Register (All Modes)
  #EPP_AddressRegister         = 3    ; Offset of EPP Address Register (EPP only)
  #EPP_DataRegister1           = 4    ; Offset of EPP Data-Register 1 (EPP only)
  #EPP_DataRegister2           = 5    ; Offset of EPP Data-Register 2 (EPP only)
  #EPP_DataRegister3           = 6    ; Offset of EPP Data-Register 3 (EPP only)
  #EPP_DataRegister4           = 7    ; Offset of EPP Data-Register 1 (EPP only)
  #ECP_DataFifoRegister        = $400 ; Offset of ECP FIFO-Data-Register (ECP only)
  #ECP_ExtendedControlRegister = $402 ; Offset of Extended-Control-Register
  
  #ECP_Mode_SPP               = 0     ; Standard SPP (normal)
  #ECP_Mode_Byte              = 1     ; Byte-Mode
  #ECP_Mode_FastCentronic     = 2     ; Fast Centronic - PS/2 Bidirectional
  #ECP_Mode_ECP               = 3     ; Extended Centronic Port
  #ECP_Mode_EPP               = 4     ; EPP
  #ECP_Mode_Reserved          = 5     ; reserved
  #ECP_Mode_FifoTest          = 6     ; FIFO Test Mode
  #ECP_Mode_Config            = 7     ; Configuration Mode

  ; --- Die Objekt-Struktur (Zustand/Datenhaltung) ---
  Structure TLPT
    DLL_ID.i                      ; Handle InpOut DLL
    m_PortAddress.w               ; Port address (Word in PB)
    b_Init.i                      ; init done
    m_Error.l                     ; Error Code
    m_ECP_RegisterPresent.i       ; ECP present
    m_EPP_RegisterPresent.i       ; EPP present
    m_SPP_RegisterPresent.i       ; SPP present
    m_IsBidirectional.i           ; Bidirektional
    m_DataModeOutput.i            ; True=Output, False=Input
  EndStructure

  ; --- Pseudo-OOP Interface (Methoden) ---
  Declare.i New(InitialAddress.w = $378)
  Declare   Free(*This.TLPT)
  
  ; Property Get / Set
  Declare.w Get_PortAddress(*This.TLPT)
  Declare   Set_PortAddress(*This.TLPT, New_Address.w)
  Declare.i Get_ECP_RegisterPresent(*This.TLPT)
  Declare.i Get_EPP_RegisterPresent(*This.TLPT)
  Declare.i Get_SPP_RegisterPresent(*This.TLPT)
  Declare.i Get_PortExist(*This.TLPT)
  Declare.i Get_IsBidirectional(*This.TLPT)
  Declare.i Get_ECP_internalMode(*This.TLPT)
  Declare   Set_ECP_internalMode(*This.TLPT, New_Mode.i)
  Declare.i Get_DataModeOutput(*This.TLPT)
  Declare   Set_DataModeOutput(*This.TLPT, New_Value.i)
  Declare.i Get_RegisterValue(*This.TLPT, Register.i)
  Declare   Set_RegisterValue(*This.TLPT, Register.i, New_Value.i)
  Declare.l Get_Error(*This.TLPT)
  Declare   Set_Error(*This.TLPT, New_Error.l)
  
  ; Public Methods
  Declare.i GetLptPortType(*This.TLPT)
  Declare   CheckPort(*This.TLPT)

EndDeclareModule

; ==============================================================================
; NAME: Parallel Port Module (Teil 2: Implementierung - Core)
; ==============================================================================

Module LPT
  
  ; Prototypen für DLL-Funktionen (InpOut32 / InpOutx64)
  Prototype.w ProtoOut32(PortAddress.w, Value.w)
  Prototype.w ProtoInp32(PortAddress.w)
  
  Global Out32.ProtoOut32
  Global Inp32.ProtoInp32
  Global DLL_Ref_Count.i = 0 
  Global Global_DLL_ID.i = 0

  ; Load DLL
  Procedure.i LoadInpOutDLL()
    If Global_DLL_ID = 0
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        Global_DLL_ID = OpenLibrary(#PB_Any, "inpoutx64.dll")
      CompilerElse
        Global_DLL_ID = OpenLibrary(#PB_Any, "inpout32.dll")
      CompilerEndIf
      
      If Global_DLL_ID
        Out32 = GetFunction(Global_DLL_ID, "Out32")
        Inp32 = GetFunction(Global_DLL_ID, "Inp32")
        If Not (Out32 And Inp32)
          CloseLibrary(Global_DLL_ID)
          Global_DLL_ID = 0
          ProcedureReturn #False
        EndIf
      Else
        ProcedureReturn #False
      EndIf
    EndIf
    DLL_Ref_Count + 1
    ProcedureReturn #True
  EndProcedure

  Procedure UnloadInpOutDLL()
    DLL_Ref_Count - 1
    If DLL_Ref_Count <= 0 And Global_DLL_ID <> 0
      CloseLibrary(Global_DLL_ID)
      Global_DLL_ID = 0
      Out32 = #Null
      Inp32 = #Null
    EndIf
  EndProcedure

  ; --- Private Register-Checks ---

  Procedure.i CheckRegisterECP(*This.TLPT, PortADR.w)
    Protected b1.w, b.w
    If Not Inp32 : ProcedureReturn #False : EndIf
    
    b1 = Inp32(PortADR + $402) & $FF
    If (b1 & 1) = 1 And (b1 & 2) = 0
      ProcedureReturn #True
    Else
      Out32(PortADR + $402, 0)
      b = Inp32(PortADR + $402) & $FF
      If (b & 1) = 1 And (b & 2) = 0
        ProcedureReturn #True
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i CheckRegisterEPP(*This.TLPT, PortADR.w)
    Protected b1.b, b2.b
    Protected bTest1.b = $AA
    Protected bTest2.b = $55
    If Not Out32 Or Not Inp32 : ProcedureReturn #False : EndIf
    
    Out32(PortADR + 3, bTest1 & $FF)
    b1 = Inp32(PortADR + 3) & $FF
    Out32(PortADR + 3, bTest2 & $FF)
    b2 = Inp32(PortADR + 3) & $FF
    
    If b1 = (bTest1 & $FF) And b2 = (bTest2 & $FF)
      Out32(PortADR + 1, 1)
      Out32(PortADR + 1, 0)
      Inp32(PortADR + 1)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i CheckRegisterSPP(*This.TLPT, PortADR.w)
    Protected b.w, b1.b, b2.b
    Protected bTest1.b = $AA
    Protected bTest2.b = $55
    If Not Out32 Or Not Inp32 : ProcedureReturn #False : EndIf
    
    b = Inp32(PortADR + 2) & $FF
    b = b & (~32) 
    Out32(PortADR + 2, b)
    
    Out32(PortADR, 0)
    Out32(PortADR, bTest1 & $FF)
    b1 = Inp32(PortADR) & $FF
    Out32(PortADR, bTest2 & $FF)
    b2 = Inp32(PortADR) & $FF
    Out32(PortADR, 0)
    
    If b1 = (bTest1 & $FF) And b2 = (bTest2 & $FF)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i CheckBidirectional(*This.TLPT, PortADR.w)
    Protected b.w, b1.b, b2.b
    Protected bTest1.b = $AA
    Protected bTest2.b = $55
    If Not Out32 Or Not Inp32 : ProcedureReturn #False : EndIf
    
    b = Inp32(PortADR + 2) & $FF
    b = b | 32
    Out32(PortADR + 2, b)
    
    Out32(PortADR, bTest1 & $FF)
    b1 = Inp32(PortADR) & $FF
    Out32(PortADR, bTest2 & $FF)
    b2 = Inp32(PortADR) & $FF
    
    b = b & (~32)
    Out32(PortADR + 2, b)
    Out32(PortADR, 0)
    
    If Not (b1 = ($AA & $FF) And b2 = 0)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i GetECPMode(*This.TLPT, PortADR.w)
    Protected b.w
    If Inp32
      b = Inp32(PortADR + $402) & $FF
      ProcedureReturn (b >> 5) 
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure SetECPMode(*This.TLPT, PortADR.w, Mode.i)
    Protected b.w
    If Out32
      b = Mode & 7
      b = b << 5 
      Out32(PortADR + $402, b)
      CheckPort(*This)
    EndIf
  EndProcedure

  ; --- Public Konstruktor / Destruktor ---

  Procedure.i New(InitialAddress.w = $378)
    Protected *This.TLPT = AllocateStructure(TLPT)
    If *This
      If LoadInpOutDLL()
        *This\m_PortAddress = InitialAddress
        CheckPort(*This)
        ProcedureReturn *This
      Else
        FreeStructure(*This)
      EndIf
    EndIf
    ProcedureReturn #Null
  EndProcedure

  Procedure Free(*This.TLPT)
    If *This
      UnloadInpOutDLL()
      FreeStructure(*This)
    EndIf
  EndProcedure

  ; --- Public Methods & Properties ---

  Procedure CheckPort(*This.TLPT)
    Protected b.w
    If *This
      *This\m_ECP_RegisterPresent = CheckRegisterECP(*This, *This\m_PortAddress)
      *This\m_EPP_RegisterPresent = CheckRegisterEPP(*This, *This\m_PortAddress)
      *This\m_SPP_RegisterPresent = CheckRegisterSPP(*This, *This\m_PortAddress)
      
      If *This\m_SPP_RegisterPresent
        *This\m_IsBidirectional = CheckBidirectional(*This, *This\m_PortAddress)
      Else
        *This\m_IsBidirectional = #False
      EndIf
      
      If *This\m_IsBidirectional
        b = Inp32(*This\m_PortAddress + 2) & $FF
        If (b & 32) = 0 
          *This\m_DataModeOutput = #True 
        Else
          *This\m_DataModeOutput = #False
        EndIf
      Else
        *This\m_DataModeOutput = #False
      EndIf
      *This\b_Init = #True
    EndIf
  EndProcedure

  Procedure.w Get_PortAddress(*This.TLPT) 
    If *This
      ProcedureReturn *This\m_PortAddress
    EndIf
  EndProcedure

  Procedure Set_PortAddress(*This.TLPT, New_Address.w)
    If *This And New_Address <> *This\m_PortAddress
      *This\m_PortAddress = New_Address
      CheckPort(*This)
    EndIf
  EndProcedure

  Procedure.i Get_ECP_RegisterPresent(*This.TLPT) 
    If *This 
      If Not *This\b_Init 
        CheckPort(*This) 
      EndIf 
      ProcedureReturn *This\m_ECP_RegisterPresent 
  EndIf : EndProcedure
    
      
  Procedure.i Get_EPP_RegisterPresent(*This.TLPT)
    If *This
      If Not *This\b_Init
        CheckPort(*This)
      EndIf
      ProcedureReturn *This\m_EPP_RegisterPresent
    EndIf 
  EndProcedure
  
  Procedure.i Get_SPP_RegisterPresent(*This.TLPT)
    If *This
      If Not *This\b_Init
        CheckPort(*This)
      EndIf
      ProcedureReturn *This\m_SPP_RegisterPresent
  EndIf : EndProcedure
  
  Procedure.i Get_IsBidirectional(*This.TLPT)
    If *This
      If Not *This\b_Init
        CheckPort(*This)
      EndIf
      ProcedureReturn *This\m_IsBidirectional
    EndIf
  EndProcedure

  Procedure.i Get_PortExist(*This.TLPT)
    If *This
      If Not *This\b_Init : CheckPort(*This) : EndIf
      ProcedureReturn Bool(*This\m_SPP_RegisterPresent Or *This\m_EPP_RegisterPresent Or *This\m_ECP_RegisterPresent)
    EndIf
  EndProcedure

  Procedure.i Get_ECP_internalMode(*This.TLPT)
    If *This
      If Not *This\b_Init : CheckPort(*This) : EndIf
      If *This\m_ECP_RegisterPresent 
        ProcedureReturn GetECPMode(*This, *This\m_PortAddress) 
      Else
        *This\m_Error = 2 
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure Set_ECP_internalMode(*This.TLPT, New_Mode.i)
    If *This
      If Not *This\b_Init : CheckPort(*This) : EndIf
      If *This\m_ECP_RegisterPresent 
        SetECPMode(*This, *This\m_PortAddress, New_Mode) 
      Else 
        *This\m_Error = 2 
      EndIf
    EndIf
  EndProcedure

  Procedure.i Get_DataModeOutput(*This.TLPT) 
    If *This
      ProcedureReturn *This\m_DataModeOutput 
    EndIf
  EndProcedure

  Procedure Set_DataModeOutput(*This.TLPT, New_Value.i)
    Protected b.w
    If *This
      If *This\m_DataModeOutput = New_Value 
        ProcedureReturn
      EndIf
      
      *This\m_DataModeOutput = New_Value
      
      b = Inp32(*This\m_PortAddress + 2) & $FF
      If New_Value 
        b = b & (~35) 
      Else 
        b = b & (~3) 
        b = b | 32 
      EndIf
      
      Out32(*This\m_PortAddress, 0)
      Out32(*This\m_PortAddress + 2, b)
    EndIf
  EndProcedure

  Procedure.i Get_RegisterValue(*This.TLPT, Register.i)
    If *This And Inp32
      ProcedureReturn Inp32(*This\m_PortAddress + Register) & $FF
    EndIf
  EndProcedure
  
  Procedure Set_RegisterValue(*This.TLPT, Register.i, New_Value.i)
    If *This And Out32
      Out32(*This\m_PortAddress + Register, New_Value & $FF)
    EndIf 
  EndProcedure
  
  Procedure.l Get_Error(*This.TLPT) 
    If *This
      ProcedureReturn *This\m_Error
    EndIf
  EndProcedure
  
  Procedure Set_Error(*This.TLPT, New_Error.l)
    If *This 
      *This\m_Error = New_Error
    EndIf
  EndProcedure

  Procedure.i GetLptPortType(*This.TLPT)
    If *This
      If Not *This\b_Init : CheckPort(*This) : EndIf
      If *This\m_ECP_RegisterPresent    : ProcedureReturn #LPT_ECP : EndIf
      If *This\m_EPP_RegisterPresent    : ProcedureReturn #LPT_EPP : EndIf
      If *This\m_SPP_RegisterPresent    : ProcedureReturn #LPT_SPP : EndIf
    EndIf
    ProcedureReturn #LPT_notPresent
  EndProcedure

EndModule

; ### Wichtige Details zur Übersetzung:
; 1. **Bitweise Operatoren:** In VB6 wird `And Not` zur Bitmaskierung genutzt. 
; In PureBasic verwendet man hierfür das Tilde-Zeichen (`~`) für die bitweise Negation.
; Beispiel: `b And Not 35` wurde zu `b & (~35)`.
; 2. **Datentypen: ** 
;   Die VB6-Datentypen wurden an PureBasic angepasst: 
;      `Integer` (16-Bit in VB6) wird zu `.w` (Word) und `Long` (32-Bit in VB6) zu `.l` (Long).
; 3. **DLL-Kapselung:** 
;   Das Modul prüft beim Erzeugen der Instanz automatisch (`CompilerIf`), 
;   ob das Programm in 32-Bit oder 64-Bit kompiliert wird, und wählt die passende `inpout32.dll` 
;   bzw. `inpoutx64.dll`. Ein interner `DLL_Ref_Count` sorgt dafür, dass die DLL erst entladen wird, 
;   wenn das letzte Port-Objekt mit `Free()` zerstört wurde.
; 4. **Shift-Operationen:** 
;   VB6 löst Shifts mathematisch über Divisionen/Multiplikationen (`\ 32` und `* 32`).
;   In PureBasic wurde das performant durch echte Bit-Shifts (`>> 5` und `<< 5`) ersetzt.
; 
; ### Kurzes Anwendungsbeispiel im neuen Code:
; 
; ```purebasic
EnableExplicit

; Instanz erstellen (ruft intern direkt CheckPort auf)
Define *MyPort.LPT::TLPT = LPT::New($378)

If *MyPort
  ; Erkennung abfragen
  If LPT::Get_PortExist(*MyPort)
    Debug "Port-Typ: " + Str(LPT::GetLptPortType(*MyPort))
    
    ; Register schreiben (DataRegister)
    LPT::Set_RegisterValue(*MyPort, LPT::#SPP_DataRegister, $FF)
    
    ; Register lesen (StatusRegister)
    Define status.i = LPT::Get_RegisterValue(*MyPort, LPT::#SPP_StatusRegister)
    Debug "Status: " + Str(status)
  Else
    Debug "Kein Parallelport an dieser Adresse gefunden."
  EndIf
  
  ; Objekt zerstören
  LPT::Free(*MyPort)
  
Else
    Debug "Kein Parallelport an dieser Adresse gefunden."
  
EndIf
; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 791
; FirstLine = 772
; Folding = ------
; DPIAware
; CPU = 5