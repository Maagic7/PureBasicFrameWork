; =====================================================================
; Module Name:  Log (Universal Multi-Instance Logging Framework)
; Description:  A highly efficient, object-like logging engine supporting
;               multiple parallel instances, verbosity levels, and targets.
; Style:        PascalCase Structures, English comments and naming.
; =====================================================================

DeclareModule LOG
  EnableExplicit
 
  ;- Enumerations
  Enumeration LogLevels 1
    #Log_Level_Info     ; Informational system tracking pulses
    #Log_Level_Warning  ; Non-fatal unexpected operational anomalies
    #Log_Level_Error    ; Severe processing execution failure states
  EndEnumeration

  ;- Structures
  Structure TLogBag
    FileHandle.i        ; The active PB file object identifier handle
    FilePath.s          ; Destination log storage file path string
    MinLevel.i          ; The current filter threshold matching LogLevels
    ConsoleEcho.i       ; Flag determining active routing to compiler debugger
  EndStructure

  ;- Public Interface Procedures
  Declare.i CreateLog(FilePath.s, MinLevel.i = #Log_Level_Info, ConsoleEcho.i = #True)
  Declare.i FreeLog(*This.TLogBag)
  Declare.i WriteLog(*This.TLogBag, Level.i, Facility.s, Message.s)
  Declare.i SetLevel(*This.TLogBag, MinLevel.i)
  
EndDeclareModule

Module LOG
  
  EnableExplicit
  
  ; ======================================================================
  ; NAME : CreateLog
  ; DESC : Instantiates a new independent log tracking instance entity
  ; VAR(FilePath.s) : Target disk destination storage file path text layout
  ; VAR(MinLevel.i) : Minimum severity level mask constraint to process entry
  ; VAR(ConsoleEcho.i) : Flag to simultaneously dump stream tracking data to debug
  ; RET.i : Pointer to the newly allocated TLogBag instance block framework
  ; ======================================================================
  Procedure.i CreateLog(FilePath.s, MinLevel.i = #Log_Level_Info, ConsoleEcho.i = #True)
    Protected *NewLog.TLogBag = AllocateStructure(TLogBag)
    
    If *NewLog
      *NewLog\FilePath    = FilePath
      *NewLog\MinLevel    = MinLevel
      *NewLog\ConsoleEcho = ConsoleEcho
      
      ; Initialize file cluster path layout if directory tree structure checks match
      If FilePath <> ""
        *NewLog\FileHandle = OpenFile(#PB_Any, FilePath, #PB_File_Append | #PB_File_SharedWrite | #PB_File_SharedRead)
      EndIf
      
      ProcedureReturn *NewLog
    EndIf
    ProcedureReturn #False
  EndProcedure

  ; ======================================================================
  ; NAME : FreeLog
  ; DESC : Safely flushes active disk I/O buffers and releases object allocations
  ; VAR(*This.TLogBag) : Pointer to the target active logging bag descriptor
  ; RET.i : True if cleanup stack processed without critical blockages, else False
  ; ======================================================================
  Procedure.i FreeLog(*This.TLogBag)
    If *This
      If *This\FileHandle <> 0 And IsFile(*This\FileHandle)
        CloseFile(*This\FileHandle)
      EndIf
      FreeStructure(*This)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  ; ======================================================================
  ; NAME : WriteLog
  ; DESC : Commits an isolated transaction tracking packet statement string to streams
  ; VAR(*This.TLogBag) : Pointer to the target active logging bag descriptor
  ; VAR(Level.i) : Entry severity index token matching LogLevels definitions
  ; VAR(Facility.s) : Subsystem origin module context tracking label identifier
  ; VAR(Message.s) : Practical description text reporting the operation incident
  ; RET.i : True if statement packet was authorized and routed, else False
  ; ======================================================================
  Procedure.i WriteLog(*This.TLogBag, Level.i, Facility.s, Message.s)
    Protected Timestamp.s, LevelStr.s, FormattedLine.s
    
    If Not *This : ProcedureReturn #False : EndIf
    
    ; Enforce threshold filter restrictions immediately to save processor resources
    If Level < *This\MinLevel : ProcedureReturn #False : EndIf
    
    ; Generate standardized standard date runtime formatting layout components
    Timestamp = FormatDate("%YYYY-%MM-%DD %HH:%II:%SS", Date())
    
    Select Level
      Case #Log_Level_Info    : LevelStr = "INFO"
      Case #Log_Level_Warning : LevelStr = "WARN"
      Case #Log_Level_Error   : LevelStr = "ERR "
      Default                  : LevelStr = "UNKN"
    EndSelect
    
    ; Assemble structured single operational log trace tracking line
    FormattedLine = "[" + Timestamp + "] [" + LevelStr + "] [" + UCase(Facility) + "] " + Message
    
    ; Route stream package to terminal console debug echo outputs if authorized
    If *This\ConsoleEcho
      PrintN(FormattedLine)
    EndIf
    
    ; Commit and sync text allocation down onto permanent local file layer
    If *This\FileHandle <> 0 And IsFile(*This\FileHandle)
      WriteStringN(*This\FileHandle, FormattedLine)
      FlushFileBuffers(*This\FileHandle) ; Enforce operational safety against system crashes
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  ; ======================================================================
  ; NAME : SetLevel
  ; DESC : Dynamically reconfigures the threshold authorization level modifier
  ; VAR(*This.TLogBag) : Pointer to the target active logging bag descriptor
  ; VAR(MinLevel.i) : The new baseline filtering constraint index token
  ; RET.i : True if configuration adjustment parameters validated, else False
  ; ======================================================================
  Procedure.i SetLevel(*This.TLogBag, MinLevel.i)
    If *This
      *This\MinLevel = MinLevel
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

EndModule


;- =====================================================================
;- REAL EXECUTION TEST CODE (Parallel Logging Engine Verification)
;- =====================================================================

CompilerIf #PB_Compiler_IsMainFile
  
  OpenConsole("Multi-Instance Logging Sandbox Architecture")
  
  Define FileSystemLog.s = GetTemporaryDirectory() + "system_core.log"
  Define FileNetworkLog.s = GetTemporaryDirectory() + "network_traffic.log"
  
  ; 1. Spin up two entirely isolated logging streams running concurrently
  Define *SysLog.Log::TLogBag = Log::CreateLog(FileSystemLog, Log::#Log_Level_Info, #True)
  Define *NetLog.Log::TLogBag = Log::CreateLog(FileNetworkLog, Log::#Log_Level_Warning, #True) ; Ignores INFO
  
  Debug "==> PHASE 1: Simulating independent engine executions..."
  
  ; Test core tracking execution writes
  Log::WriteLog(*SysLog, Log::#Log_Level_Info, "Engine", "Kernel initialization vector sequences loaded.")
  Log::WriteLog(*SysLog, Log::#Log_Level_Warning, "Memory", "Garbage collection threshold reached 82% capacity.")
  
  ; This next line will print to SysLog, but network module will test filtering logic
  Log::WriteLog(*NetLog, Log::#Log_Level_Info, "Socket", "Attempting connection handshake to port 443.") ; Hidden!
  Log::WriteLog(*NetLog, Log::#Log_Level_Error, "SSL", "Handshake negotiation handshake failed timeout boundary.") ; Printed!
  
  Debug "==> PHASE 2: Adjusting filter limits at runtime dynamically..."
  Log::SetLevel(*NetLog, Log::#Log_Level_Info) ; Lower boundary check constraint
  Log::WriteLog(*NetLog, Log::#Log_Level_Info, "Socket", "Retry protocol sequence engaged successfully.") ; Now printed!
  
  ; 2. Wipe environment resource layers clean
  Log::FreeLog(*SysLog)
  Log::FreeLog(*NetLog)
  
  Debug "Verification finished. Files saved cleanly to system temp directories."
  Input()
  
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 55
; FirstLine = 22
; Folding = --
; DPIAware
; CPU = 5