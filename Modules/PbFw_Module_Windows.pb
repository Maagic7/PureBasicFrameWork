; ===========================================================================
;  FILE: PbFw_Module_Windows.pb
;  NAME: Module Windows 
;  DESC: 
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://www.rsbasic.de/winapi-library/
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/01/01
; VERSION  :  0.51 Develper Version
; COMPILER :  PureBasic 6.0 and higher
; OS       :  Windows
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 

;  2026/10/16 S.Maag : added MemoryPage validation! Added PeekS to solve Stringlength at >=PB6.40
;  2026/10/10 S.Maag : added 'Desktop and Windwos' section. Added ScreenShot section
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"            ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"           ; DBG::     Debug Module
XIncludeFile "PbFw_Module_OperatingSystem.pb" ; OS::      OperatingSystem    

DeclareModule Win
 
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  Structure ProcessMemoryResult
    RAMUsage.q       ; Echter RAM-Verbrauch (Working Set Size) in Bytes
    VirtualUsage.q   ; Virtuell reservierter Speicher (Commit Size / Pagefile) in Bytes
  EndStructure
  
  ; ----------------------------------------------------------------------
  ; Memory
  ; ---------------------------------------------------------------------
 
  Declare.i GetFullMemoryStatus(*memex.MEMORYSTATUSEX)
  Declare.i GetMemoryBusWidth()
  
  Declare.q GetRamSize()
  Declare.q GetUsedRamSize()
  Declare.i GetRamUsedRamPercent()
  Declare.q GetFreeRamSize()
  Declare.q GetVirtualMemorySize()
  Declare.q GetVirtualMemoryUsed()
  Declare.q GetVirtualMemoryFree()
  Declare.q GetSwapFileSize()
  Declare.q GetSwapFileUsed()
  Declare.q GetSwapFileFree()
  
  Declare.q GetOwnMemoryUsage()
  Declare.q GetWindowProcessMemoryUsage(hWnd.i)
  Declare.i GetOwnMemoryUsageEx(*outResult.ProcessMemoryResult)
  Declare.i GetWindowProcessMemoryUsageEx(hWnd.i, *outResult.ProcessMemoryResult)
  
  Declare.i IsValidMem(*mem, xWriteAccess.i=#False)
  Declare.i IsValidMemRange(*mem, NoOfBytes.i=SizeOf(Integer), xWriteAccess.i=#False)

  ; ----------------------------------------------------------------------
  ;  Desktop and Windows
  ; ---------------------------------------------------------------------
  
  Declare.i GetVirtualScreenRect(*outRect.RECT)
  Declare.i GetVirtualScreenWidth()
  Declare.i GetVirtualScreenHeight()
  Declare.i GetVirtualScreenLeft()
  Declare.i GetVirtualScreenTop()
  
  Declare.i GetCurrentMonitorRect(*outRect.RECT)
  Declare.i GetWindowClientRect(hWnd.i, *outRect.RECT)
  Declare.i GetWindowScreenRect(hWnd.i, *outRect.RECT)
  
  Declare.i GetAbsoluteMousePos(*outPt.POINT)
  Declare.l GetColorFromPoint(*pt.POINT)
  Declare.i GetWindowFromPoint(*pt.POINT)
  Declare.s GetWindowTitel(hWnd.i)
  Declare.s GetWindowClassName(hWnd.i)  
  
  Declare.i ClientToScreenPoint(hWnd.i, *pt.POINT)
  Declare.i ScreenToClientPoint(hWnd.i, *pt.POINT)
  Declare.i ClientToScreenRect(hWnd.i, *rect.RECT)
  Declare.i ScreenToClientRect(hWnd.i, *rect.RECT)
  
  Declare.i DrawSelectionRect(*rect.RECT)
  Declare.i EraseSelectionRect(*rect.RECT)
  
  ;- ----------------------------------------------------------------------
  ;-  ScreenShot
  ;- ---------------------------------------------------------------------
  
  Declare.i CaptureVirtualScreenRect(ImageNo, *SourceRect.RECT, rop.l=#SRCCOPY)
  Declare.i CaptureVirtualScreen(ImageNo)
  Declare.i CaptureCurrentMonitor(ImageNo)
  Declare.i CaptureWindow(ImageNo, hWnd.i, CaptureClientOnly.i = #True)
  
  ; ----------------------------------------------------------------------
  ;  Miscellaneous
  ; ---------------------------------------------------------------------
  
  Declare.s GetRealPath(FileName$)
  Declare.i SendString (String$)

  Declare GetAllUsers()
  Declare.s GetUserName()
  Declare.i GetGraphicCardName()
  Declare.s GetWinVerString()
  
  ; ----------------------------------------------------------------------
  ;  Product Key
  ; ---------------------------------------------------------------------

   Declare.s GetWindowsProductKey()

EndDeclareModule


Module Win
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  Import "Comctl32.lib" 
    ; 
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      SetWindowSubclass(hWnd, *fnSubclass, uIdSubclass, dwRefData)  As "SetWindowSubclass" 
      GetWindowSubclass(hWnd, *fnSubclass, uIdSubclass, *dwRefData) As "GetWindowSubclass"
      RemoveWindowSubclass(hWnd, *fnSubclass, uIdSubclass)          As "RemoveWindowSubclass"
      DefSubclassProc(hWnd, uMsg, wParam, lParam)                   As "DefSubclassProc"
    CompilerElse
      SetWindowSubclass(hWnd, *fnSubclass, uIdSubclass, dwRefData)  As "_SetWindowSubclass@16" 
      GetWindowSubclass(hWnd, *fnSubclass, uIdSubclass, *dwRefData) As "_GetWindowSubclass@16"
      RemoveWindowSubclass(hWnd, *fnSubclass, uIdSubclass)          As "_RemoveWindowSubclass@12"
      DefSubclassProc(hWnd, uMsg, wParam, lParam)                   As "_DefSubclassProc@16" 
    CompilerEndIf
  EndImport 
 
  ;- ----------------------------------------------------------------------
  ;- Memory
  ;- ---------------------------------------------------------------------
  
  ; now PB has a MempryStatus() Command. It's not necessary to use API calls
  
  ; Result.q = MemoryStatus(Type)
  ;   #PB_System_TotalPhysical: the total amount of installed memory, in bytes
  ;   #PB_System_FreePhysical : the available memory, in bytes
  ;   #PB_System_TotalVirtual : the total virtual memory size, in bytes (Windows only)
  ;   #PB_System_FreeVirtual  : the available virtual memory size, in bytes (Windows only)
  ;   #PB_System_TotalSwap    : the total Swap memory size, in bytes (Windows And Linux only)
  ;   #PB_System_FreeSwap     : the available Swap memory size, in bytes (Windows And Linux only)
  ;   #PB_System_PageSize     : the memory page size, in bytes (usually 4KB).

  
  
;   Structure MEMORYSTATUS   ; PB predifined Structure
;     dwLength.l
;     dwMemoryLoad.l
;     dwTotalPhys.i
;     dwAvailPhys.i
;     dwTotalPageFile.i
;     dwAvailPageFile.i
;     dwTotalVirtual.i
;     dwAvailVirtual.i
;   EndStructure
  
  
  Procedure.i GetFullMemoryStatus(*memex.MEMORYSTATUSEX)
    
    If *memex
      *memex\dwLength = SizeOf(MEMORYSTATUSEX)
      GlobalMemoryStatusEx_(*memex)
      ProcedureReturn #True  
    Else
      ProcedureReturn #False       
    EndIf
    
  EndProcedure
  
  Procedure.i GetMemoryBusWidth()
    Protected mem.MEMORYSTATUS
    mem\dwLength = SizeOf(MEMORYSTATUS)
    GlobalMemoryStatus_(mem)
    ProcedureReturn mem\dwLength
  EndProcedure
  
  Procedure.q GetRamSize()
  ; ============================================================================
  ; NAME: GetRamSize
  ; DESC: Retrieves the total amount of physical memory (RAM) in bytes.
  ; RET.q: The total physical memory in bytes (64-bit Quad).
  ; ============================================================================
    Protected memex.MEMORYSTATUSEX
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusEx_(@memex)
    ProcedureReturn memex\ullTotalPhys
    
  EndProcedure
  
  Procedure.q GetUsedRamSize()
  ; ============================================================================
  ; NAME: GetUsedRamSize
  ; DESC: Calculates the currently used amount of physical memory (RAM) in bytes.
  ; RET.q: The used physical memory in bytes (64-bit Quad).
  ; ============================================================================
    Protected memex.MEMORYSTATUSEX
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusEx_(@memex)
    ProcedureReturn memex\ullTotalPhys-memex\ullAvailPhys
  EndProcedure
  
  Procedure.i GetRamUsedRamPercent()
    Protected memex.MEMORYSTATUSEX
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusEx_(@memex)
    ProcedureReturn memex\dwMemoryLoad
  EndProcedure
  
  Procedure.q GetFreeRamSize()
    Protected memex.MEMORYSTATUSEX
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusEx_(@memex)
    ProcedureReturn memex\ullAvailPhys
  EndProcedure
  
  Procedure.q GetVirtualMemorySize()
    Protected memex.MEMORYSTATUSEX   
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusEx_(@memex)
    ProcedureReturn memex\ullTotalVirtual
  EndProcedure
  
  Procedure.q GetVirtualMemoryUsed()
    Protected memex.MEMORYSTATUSEX
    
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusEx_(@memex)
    ProcedureReturn memex\ullTotalVirtual-memex\ullAvailVirtual
  EndProcedure
  
  Procedure.q GetVirtualMemoryFree()
    Protected memex.MEMORYSTATUSEX
    
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusEx_(@memex)
    ; MessageRequester("","Virtueller Speicher (frei): "+Str(memex\ullAvailVirtual/1024/1024)+" MB",0)   
    ProcedureReturn memex\ullAvailVirtual
  EndProcedure
  
  Procedure.q GetSwapFileSize()
    Protected memex.MEMORYSTATUSEX
    
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusex_(@memex)
    ProcedureReturn memex\ullTotalPageFile
  EndProcedure
  
  Procedure.q GetSwapFileUsed()
    Protected memex.MEMORYSTATUSEX    
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusex_(@memex)
    ProcedureReturn memex\ullTotalPageFile-memex\ullAvailPageFile
  EndProcedure
  
  Procedure.q GetSwapFileFree()
    Protected memex.MEMORYSTATUSEX
    memex\dwLength = SizeOf(MEMORYSTATUSEX)
    GlobalMemoryStatusex_(@memex)
    ProcedureReturn memex\ullAvailPageFile
  EndProcedure
  
  Procedure.q GetOwnMemoryUsage()
  ; ============================================================================
  ; NAME: GetOwnMemoryUsage
  ; DESC: Retrieves the current physical memory (RAM) usage of this program in bytes.
  ; RET.q: The memory usage in bytes (64-bit Quad), or 0 on failure.
  ; ============================================================================
    Protected pmc.PROCESS_MEMORY_COUNTERS
    Protected hProcess.i
    Protected result.q
    
    ; 1. Ein Handle auf das eigene Programm holen
    hProcess = GetCurrentProcess_()
    
    If hProcess
      pmc\cb = SizeOf(PROCESS_MEMORY_COUNTERS)
      ; 2. Speicherdaten auslesen
      If GetProcessMemoryInfo_(hProcess, @pmc, SizeOf(PROCESS_MEMORY_COUNTERS))
        result = pmc\WorkingSetSize
      EndIf
      ; GetCurrentProcess_() gibt ein Pseudo-Handle zurück, das nicht geschlossen werden muss.
    EndIf
    
    ProcedureReturn result
  EndProcedure
  
  Procedure.q GetWindowProcessMemoryUsage(hWnd.i)
  ; ============================================================================
  ; NAME: GetWindowProcessMemoryUsage
  ; DESC: Retrieves the physical memory (RAM) usage of the process belonging
  ; DESC: to a specific hWnd.
  ; VAR(hWnd.i): Handle to a window of the target process (e.g., WinCC Runtime).
  ; RET.q: The memory usage in bytes (64-bit Quad), or 0 on failure.
  ; ============================================================================
    Protected pmc.PROCESS_MEMORY_COUNTERS
    Protected processID.l  ; lpDWORD
    Protected hProcess.i
    Protected result.q
    
    If hWnd And IsWindow_(hWnd)
      ; 1. Die Process-ID aus dem Fenster-Handle (hWnd) ermitteln
      GetWindowThreadProcessId_(hWnd, @processID)
      
      If processID
        ; 2. Den Prozess mit den nötigen Rechten öffnen (#PROCESS_QUERY_INFORMATION | #PROCESS_VM_READ)
        hProcess = OpenProcess_($0400 | $0010, #False, processID)
        
        If hProcess
          pmc\cb = SizeOf(PROCESS_MEMORY_COUNTERS)
          ; 3. Speicherdaten des fremden Prozesses auslesen
          If GetProcessMemoryInfo_(hProcess, @pmc, SizeOf(PROCESS_MEMORY_COUNTERS))
            result = pmc\WorkingSetSize
          EndIf
          ; 4. Das geöffnete Prozess-Handle wieder sauber schließen
          CloseHandle_(hProcess)
        EndIf
      EndIf
    EndIf
    
    ProcedureReturn result
  EndProcedure
  
  ; Virtual Memory usage, is the complete Memory reserved. Shard ram is not included in VirtualUsage
  ; RAM usage, is the actual used RAM including shared RAM Memory.

  Procedure.i GetOwnMemoryUsageEx(*outResult.ProcessMemoryResult)
  ; ============================================================================
  ; NAME: GetOwnMemoryUsageEx
  ; DESC: Retrieves both physical RAM and virtual memory usage of this program.
  ; VAR(*outResult.ProcessMemoryResult): Pointer to the structure receiving the sizes.
  ; RET.i: #True on success, or #False on failure.
  ; ============================================================================
    Protected pmc.PROCESS_MEMORY_COUNTERS
    Protected hProcess.i
    Protected result.i
    
    If *outResult = 0
      ProcedureReturn #False
    EndIf
    
    hProcess = GetCurrentProcess_()
    If hProcess
      pmc\cb = SizeOf(PROCESS_MEMORY_COUNTERS)
      If GetProcessMemoryInfo_(hProcess, @pmc, SizeOf(PROCESS_MEMORY_COUNTERS))
        *outResult\RAMUsage     = pmc\WorkingSetSize
        *outResult\VirtualUsage = pmc\PagefileUsage
        result = #True
      EndIf
    EndIf
    
    ProcedureReturn result
  EndProcedure
  
  Procedure.i GetWindowProcessMemoryUsageEx(hWnd.i, *outResult.ProcessMemoryResult)
  ; ============================================================================
  ; NAME: GetWindowProcessMemoryUsageEx
  ; DESC: Retrieves both physical RAM and virtual memory usage of a target hWnd process.
  ; VAR(hWnd.i): Handle to a window of the target process (e.g., WinCC Runtime).
  ; VAR(*outResult.ProcessMemoryResult): Pointer to the structure receiving the sizes.
  ; RET.i: #True on success, or #False on failure.
  ; ============================================================================
    Protected pmc.PROCESS_MEMORY_COUNTERS
    Protected processID.l
    Protected hProcess.i
    Protected result.i = #False
    
    If *outResult = 0 : ProcedureReturn #False : EndIf
    
    If hWnd And IsWindow_(hWnd)
      GetWindowThreadProcessId_(hWnd, @processID)
      
      If processID
        ; Open process with query and read permissions (#PROCESS_QUERY_INFORMATION | #PROCESS_VM_READ)
        hProcess = OpenProcess_($0400 | $0010, #False, processID)
        
        If hProcess
          pmc\cb = SizeOf(PROCESS_MEMORY_COUNTERS)
          If GetProcessMemoryInfo_(hProcess, @pmc, SizeOf(PROCESS_MEMORY_COUNTERS))
            *outResult\RAMUsage     = pmc\WorkingSetSize
            *outResult\VirtualUsage = pmc\PagefileUsage
            result = #True
          EndIf
          CloseHandle_(hProcess)
        EndIf
      EndIf
    EndIf
    
    ProcedureReturn result
  EndProcedure
  
  ; #MEM_COMMIT = $1000
  ; Structure MEMORY_BASIC_INFORMATION
  ;   *BaseAddress
  ;   *AllocationBase
  ;   AllocationProtect.l
  ;   RegionSize.i
  ;   State.l
  ;   Protect.l
  ;   Type.l
  ; EndStructure
  
  #_MEM_PROTECTED = #PAGE_NOACCESS | #PAGE_GUARD
  #_MEM_WRITEABLE = #PAGE_READWRITE | #PAGE_WRITECOPY | #PAGE_EXECUTE_READWRITE | #PAGE_EXECUTE_WRITECOPY
    
  Procedure.i IsValidMem(*mem, xWriteAccess.i=#False)
  ; ============================================================================
  ; NAME: IsValidMem
  ; DESC: Prüft, ob ein Pointer im virtuellen Adressraum der eigenen App liegt
  ;       und ob darauf lesend (oder optional schreibend) zugegriffen werden darf.
  ; VAR: *mem - Die zu prüfende Speicheradresse
  ;        xWriteAccess - #True, wenn auch Schreibrechte geprüft werden sollen
  ; RET.i: #True (1) wenn gültig, sonst #False (0)
  ; ============================================================================
    Protected mbi.MEMORY_BASIC_INFORMATION
    
    ; Null-Pointer direkt ausschließen
    If Not *mem : ProcedureReturn #False : EndIf
    
    ; VirtualQuery fragt den Status der Speicherseite ab, in der der Pointer liegt
    If VirtualQuery_(*mem, @mbi, SizeOf(MEMORY_BASIC_INFORMATION)) = 0
      ProcedureReturn #False ; Fehler beim API-Aufruf -> Ungültige Adresse
    EndIf
    
    ; 1. Der Speicherbereich MUSS "committed" (zugewiesen) sein
    If mbi\State <> #MEM_COMMIT
      ProcedureReturn #False
    EndIf
    
    ; 2. Schutzrechte (ProtectionFlags) analysieren
    ; Schließe "No Access" und "Guard Pages" (wichtig für Stack-Enden) grundsätzlich aus
    If (mbi\Protect & #_MEM_PROTECTED)
      ProcedureReturn #False
    EndIf
    
    ; 3. Falls Schreibzugriff verlangt wird, explizit auf Schreibrechte prüfen
    If xWriteAccess
      If (mbi\Protect & #_MEM_WRITEABLE)
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
    EndIf
    
    ; Wenn wir hier landen und xWriteAccess=#False war, ist der Speicher zumindest lesbar
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i IsValidMemRange(*mem, NoOfBytes.i=SizeOf(Integer), xWriteAccess.i=#False)
  ; ============================================================================
  ; NAME: IsValidPointerEx
  ; DESC: Prüft den Start- und optional den Endpointer eines Speicherbereichs.
  ; VAR: *mem   - Die Startadresse
  ;        Length     - Länge des Bereichs in Bytes (Standard: 1 Byte)
  ;        xWriteAccess- #True, wenn auch Schreibrechte geprüft werden sollen
  ; RET.i: #True (1) wenn der gesamte Bereich gültig ist, sonst #False (0)
  ; ============================================================================
    
    ; 1. Startpointer prüfen (nutzt die bestehende VirtualQuery-Logik)
    If Not IsValidMem(*mem, xWriteAccess)
      ProcedureReturn #False
    EndIf
    
    ; 2. Falls eine Länge angegeben wurde, auch den Endpointer prüfen
    If NoOfBytes > SizeOf(Integer)
      Protected *pMemEnd = *mem + (Length - 1)
      
      If Not IsValidMem(*pMemEnd, xWriteAccess)
        ProcedureReturn #False
      EndIf
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;-  Desktop and Windows
  ;- ---------------------------------------------------------------------
  
  Procedure.i GetVirtualScreenRect(*outRect.RECT)
  ; ============================================================================
  ; NAME: GetVirtualScreenRect
  ; DESC: Retrieves the absolute bounds of the full virtual screen (all monitors).
  ; VAR(*outRect.RECT): Pointer to the RECT structure to receive the coordinates.
  ; RET.i: #True on success, or #False if the pointer is null.
  ; ============================================================================
    If *outRect
      ; #SM_XVIRTUALSCREEN = 76, #SM_YVIRTUALSCREEN = 77
      *outRect\left   = GetSystemMetrics_(#SM_XVIRTUALSCREEN) 
      *outRect\top    = GetSystemMetrics_(#SM_YVIRTUALSCREEN) 
      
      ; #SM_CXVIRTUALSCREEN = 78, #SM_CYVIRTUALSCREEN = 79
      ; right and bottom must be absolute endpoints (Start + Size)
      *outRect\right  = *outRect\left + GetSystemMetrics_(#SM_CXVIRTUALSCREEN) 
      *outRect\bottom = *outRect\top  + GetSystemMetrics_(#SM_CYVIRTUALSCREEN)
      
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure  
  
  Procedure.i GetVirtualScreenWidth()
  ; ============================================================================
  ; NAME: GetVirtualScreenWidth
  ; DESC: Returns the With of the virutal Desktop over all Monitors
  ; RET.i: Width in Pixel
  ; ============================================================================
   
   ; #SM_CXVIRTUALSCREEN = 78
    ProcedureReturn GetSystemMetrics_(#SM_CXVIRTUALSCREEN) 
  EndProcedure
  
  Procedure.i GetVirtualScreenHeight()
  ; ============================================================================
  ; NAME: GetVirtualScreenHeight
  ; DESC: Returns the Height of the virutal Desktop over all Monitors
  ; RET.i: Height in Pixel
  ; ============================================================================
    
    ; #SM_CYVIRTUALSCREEN = 79
    ProcedureReturn GetSystemMetrics_(#SM_CYVIRTUALSCREEN)
  EndProcedure
  
  Procedure.i GetVirtualScreenLeft()
  ; ============================================================================
  ; NAME: GetVirtualScreenLeft
  ; DESC: Returns the left x coordinate of the virutal Desktop over all Monitors
  ; DESC: Important if there is a Monitor left from the Main Monitor
  ; RET.i: Left x
  ; ============================================================================
    ; #SM_XVIRTUALSCREEN = 76
    ProcedureReturn GetSystemMetrics_(#SM_XVIRTUALSCREEN)
  EndProcedure
  
  Procedure.i GetVirtualScreenTop()
  ; ============================================================================
  ; NAME: GetVirtualScreenTop
  ; DESC: Returns the Top y coordinate of the virutal Desktop over all Monitors
  ; DESC: Important if there is a Monitor above from the Main Monitor
  ; RET.i: Top y
  ; ============================================================================
    ; #SM_YVIRTUALSCREEN = 77
    ProcedureReturn GetSystemMetrics_(#SM_YVIRTUALSCREEN)
  EndProcedure
  
  Procedure.i GetCurrentMonitorRect(*outRect.RECT)
  ; ============================================================================
  ; NAME: GetCurrentMonitorRect
  ; DESC: Returns the coordinates of the actual monitor (where the Mouse is)
  ; DESC: Coordinates of the monitor inside the full virtual Monitor
  ; VAR(*outRect.RECT)
  ; RET.i: #True on success
  ; ============================================================================
    Protected pt.POINT
    Protected hMonitor
    Protected info.MONITORINFO
    
    GetCursorPos_(pt)
    ; #MONITOR_DEFAULTTONULL    = 0
    ; #MONITOR_DEFAULTTOPRIMARY = 1
    ; #MONITOR_DEFAULTTONEAREST = 2 (search the nearest monitor if mouse is outside of virtual screen)
    hMonitor = MonitorFromPoint_(pt, #MONITOR_DEFAULTTONEAREST) 
    
    If hMonitor And *outRect
      info\cbSize = SizeOf(MONITORINFO)
      If GetMonitorInfo_(hMonitor, info)
        ; info\rcMonitor enthält die absoluten Koordinaten des getroffenen Bildschirms
        CopyMemory(@info\rcMonitor, *outRect, SizeOf(RECT))
        ProcedureReturn #True
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i GetWindowClientRect(hWnd.i, *outRect.RECT)
  ; ============================================================================
  ; NAME: GetWindowClientRect
  ; DESC: Returns the coordinates of the client rectangle
  ; DESC: The inner bound of the Window
  ; VAR(*outRect.RECT): Pointer to the POINT structure to receive coordinates
  ; RET.i: #True on success
  ; ============================================================================
   If hWnd And *outRect
      ProcedureReturn GetClientRect_(hWnd, *outRect)
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i GetWindowScreenRect(hWnd.i, *outRect.RECT)
  ; ============================================================================
  ; NAME: GetWindowScreenRect
  ; DESC: Returns the coordinates of the outer rectangle
  ; DESC: The outer bound of the Window
  ; VAR(*outRect.RECT): Pointer to the POINT structure to receive coordinates
  ; RET.i: #True on success
  ; ============================================================================
    If hWnd And *outRect
      ProcedureReturn GetWindowRect_(hWnd, *outRect)
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i GetAbsoluteMousePos(*outPt.POINT)
  ; ============================================================================
  ; NAME: GetAbsoluteMousePos
  ; DESC: Get the absolut Mouse position on the full virtual Screen
  ; VAR(*outPt.POINT): Pointer to POINT Structure to receive the Mouse position
  ; RET.l: #True on success
  ; ============================================================================
    If *outPt
      ProcedureReturn GetCursorPos_(*outPt)
    EndIf
    ProcedureReturn #False
  EndProcedure  

  Procedure.l GetColorFromPoint(*pt.POINT)
  ; ============================================================================
  ; NAME: GetColorFromPoint
  ; DESC: Returns color of the specified Point on the Screen/Desktop
  ; VAR(*pt.POINT): Pointer to POINT Structure *pt\x. *pt\y
  ; RET.l: The RGB Color
  ; ============================================================================
    Protected hdc, color.l
    
    If pt
      hdc = GetDC_(0)       ; Device Context (DC) of Desktop (0 = Desktop)
      
      If hdc
        color = GetPixel_(hdc, *pt\x, *pt\y)    ; The Color of the Pixel at x,y
        ReleaseDC_(0, hdc)              ; Release the DeviceContext
      EndIf
    EndIf
  
    ProcedureReturn color
  EndProcedure
    
  Procedure.i GetWindowFromPoint(*pt.POINT)
  ; ============================================================================
  ; NAME: GetWindowFromPoint
  ; DESC: Returns the Window Handle of the Window containing the specified  
  ; DESC: Point on the Screen/Desktop
  ; VAR(*pt.POINT): Pointer to the POINT structure *pt\x. *pt\y
  ; RET.i: hWnd or 0
  ; ============================================================================
    Protected *ptQ.Quad ; Pointer to get a Quad by value
    If *pt
      *ptQ = *pt  ; to get POINT as QUAD Value
      ; API WindowFromPoint(ByVal POINT) 
      ProcedureReturn WindowFromPoint_(*ptQ\q)
    EndIf
    ProcedureReturn 0
  EndProcedure
  
  Procedure.s GetWindowTitel(hWnd.i)
  ; ============================================================================
  ; NAME: GetWindowTitel
  ; DESC: Retrieves the title text of the specified window.
  ; RET.s: The window title string (empty string if failed).
  ; ============================================================================
    Protected length.l
    Protected title.s
    
    If hWnd
      ; Length of the window Titel +1 for the Null
      length = GetWindowTextLength_(hWnd) + 1
      
      If length > 1
        ; String-Buffer
        title = Space(length)
        ; Copy Titel to the String-Buffer
        GetWindowText_(hWnd, @title, length)
        ProcedureReturn PeekS(@title) ; PeekS needed for new StringLib >=PB6.40
      EndIf
    EndIf
    ProcedureReturn ""
  EndProcedure
  
  Procedure.s GetWindowClassName(hWnd.i)
  ; ============================================================================
  ; NAME: GetWindowClassName
  ; DESC: Retrieves the internal Win32 class name of the specified window.
  ; RET.s: The class name string (empty string if failed).
  ; ============================================================================
    Protected className.s = Space(256) 
    
    If hWnd
      If GetClassName_(hWnd, @className, 256)
        ProcedureReturn PeekS(@className) ; PeekS needed for new Stringlib >=PB6.40
      EndIf
    EndIf
    ProcedureReturn #Null$
  EndProcedure
  
  Procedure.i ClientToScreenPoint(hWnd.i, *pt.POINT)
  ; ============================================================================
  ; NAME: ClientToScreenPoint
  ; DESC: Converts the client-area coordinates of a specified point to screen coordinates.
  ; VAR(hWnd.i): Handle to the window whose client area is used for the conversion.
  ; VAR(*pt.POINT): Pointer to the POINT structure containing the coordinates to convert.
  ; RET.i: #True on success, or #False on failure.
  ; ============================================================================
    If hWnd And *pt
      ProcedureReturn ClientToScreen_(hWnd, *pt)
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i ScreenToClientPoint(hWnd.i, *pt.POINT)
  ; ============================================================================
  ; NAME: ScreenToClientPoint
  ; DESC: Converts the screen coordinates of a specified point to client-area coordinates.
  ; VAR(hWnd.i): Handle to the window whose client area is used for the conversion.
  ; VAR(*pt.POINT): Pointer to the POINT structure containing the coordinates to convert.
  ; RET.i: #True on success, or #False on failure.
  ; ============================================================================
    If hWnd And *pt
      ProcedureReturn ScreenToClient_(hWnd, *pt)
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i ClientToScreenRect(hWnd.i, *rect.RECT)
  ; ============================================================================
  ; NAME: ClientToScreenRect
  ; DESC: Converts the client-area coordinates of a RECT to absolute screen coordinates.
  ; VAR(hWnd.i): Handle to the window whose client area is used for the conversion.
  ; VAR(*rect.RECT): Pointer to the RECT structure to convert.
  ; RET.i: #True on success, or #False on failure.
  ; ============================================================================
    Protected topLeft.POINT
    Protected bottomRight.POINT
    
    If hWnd And *rect
      ; extract the 2 Points from rect
      topLeft\x = *rect\left
      topLeft\y = *rect\top
      bottomRight\x = *rect\right
      bottomRight\y = *rect\bottom
      
      If ClientToScreen_(hWnd, topLeft) And ClientToScreen_(hWnd, bottomRight)
        ; fill rect with the new data
        *rect\left   = topLeft\x
        *rect\top    = topLeft\y
        *rect\right  = bottomRight\x
        *rect\bottom = bottomRight\y
        ProcedureReturn #True
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i ScreenToClientRect(hWnd.i, *rect.RECT)
  ; ============================================================================
  ; NAME: ScreenToClientRect
  ; DESC: Converts absolute screen coordinates of a RECT to window client-area coordinates.
  ; VAR(hWnd.i): Handle to the window whose client area is used for the conversion.
  ; VAR(*rect.RECT): Pointer to the RECT structure to convert.
  ; RET.i: #True on success, or #False on failure.
  ; ============================================================================
    Protected topLeft.POINT
    Protected bottomRight.POINT
    
    If hWnd And *rect
       ; extract the 2 Points from rect
      topLeft\x = *rect\left
      topLeft\y = *rect\top
      bottomRight\x = *rect\right
      bottomRight\y = *rect\bottom
      
      If ScreenToClient_(hWnd, topLeft) And ScreenToClient_(hWnd, bottomRight)
        ; fill rect with the new data
        *rect\left   = topLeft\x
        *rect\top    = topLeft\y
        *rect\right  = bottomRight\x
        *rect\bottom = bottomRight\y
        ProcedureReturn #True
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
    
  Procedure.i DrawSelectionRect(*rect.RECT)
  ; ============================================================================
  ; NAME: DrawSelectionRect
  ; DESC: Draws a dotted selection rectangle directly onto the virtual screen.
  ; DESC: Calling this a second time with identical coordinates will ERASE it.
  ; VAR(*rect.RECT): Pointer to the RECT structure containing the absolute coordinates.
  ; RET.i: #True on success, or #False on failure.
  ; ============================================================================
    Protected dcWnd.i
    Protected result.i = #False
    
    If *rect
      dcWnd = GetDC_(0)   ; get the DC of the full virtual Screen 
      
      If dcWnd
        ; Draw a focus rectangle in the XOR MOde
        result = DrawFocusRect_(dcWnd, *rect)
        ReleaseDC_(0, dcWnd)
      EndIf
    EndIf
    
    ProcedureReturn result
  EndProcedure
  
  Procedure.i EraseSelectionRect(*rect.RECT)
    ; ============================================================================
    ; NAME: EraseSelectionRect
    ; DESC: Erases an existing selection rectangle by redrawing it.
    ; VAR(*rect.RECT): Pointer to the RECT structure used when drawing the rectangle.
    ; RET.i: #True on success, or #False on failure.
    ; ============================================================================
    ; Da DrawFocusRect im XOR-Modus arbeitet, ist das Löschen identisch mit dem Zeichnen
    ProcedureReturn DrawSelectionRect(*rect)
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;-  ScreenShot
  ;- ---------------------------------------------------------------------

  Procedure.i CaptureVirtualScreenRect(ImageNo, *SourceRect.RECT, rop.l=#SRCCOPY)
  ; ============================================================================
  ; NAME: CaptureVirtualScreenRect
  ; DESC: Capture the area specified by a RECT structure from the virtual screen
  ; VAR(ImageNo): The PB Image No to receive the ScreenShot (or #PB_Any)
  ; VAR(*SourceRect.RECT): Pointer to the RECT structure containing the coordinates
  ; VAR(rop.l): Raster operation code (e.g., #SRCCOPY)   
  ; RET.i: The PB Image ID (HBITMAP) on success, or 0 on failure
  ; ============================================================================
    Protected hImg.i, dcImg.i, dcWnd.i
    Protected width.l, height.l
    
    If  Not *SourceRect 
      ProcedureReturn 
    EndIf
    
    ; calculate width and heigt
    width  = *SourceRect\right - *SourceRect\left
    height = *SourceRect\bottom - *SourceRect\top
    
    ; saftey check of size
    If width <= 0 Or height <= 0 
      ProcedureReturn 0 
    EndIf
    
    hImg = CreateImage(ImageNo, width, height) 
    
    If hImg
      dcImg = StartDrawing(ImageOutput(ImageNo)) 
      If dcImg
        dcWnd = GetDC_(0)   
        If dcWnd
          ; copy the source rect into our PB Image
          BitBlt_(dcImg, 0, 0, width, height, dcWnd, *SourceRect\left, *SourceRect\top, rop) 
          ReleaseDC_(0, dcWnd) 
        EndIf
        StopDrawing() 
      EndIf
    EndIf
    
    ProcedureReturn hImg 
  EndProcedure
    
  Procedure.i CaptureVirtualScreen(ImageNo)
  ; ============================================================================
  ; NAME: CaptureVirtualScreen
  ; DESC: Capture the full virtual screen over all Monitors
  ; VAR(ImageNo): The PB ImageNo to receive the ScreenShot (or #PB_Any)
  ; RET.i: The PB Image ID (HBITMAP) on success, or 0 on failure
  ; ============================================================================
    Protected rect.RECT
    
    If GetVirtualScreenRect(rect) ; get full Size of virtual screen
      ProcedureReturn CaptureVirtualScreenRect(ImageNo, rect) ; do a full size capture
    EndIf
    
    ProcedureReturn 0
  EndProcedure  
  
  Procedure.i CaptureCurrentMonitor(ImageNo)
  ; ============================================================================
  ; NAME: CaptureCurrentMonitor
  ; DESC: Captures the full screen of the monitor where the mouse cursor is currently located.
  ; VAR(ImageNo): The PB ImageNo to receive the ScreenShot (or #PB_Any)
  ; RET.i: The PB Image ID (HBITMAP) on success, or 0 on failure.
  ; ============================================================================
    Protected rect.RECT
    
    If GetCurrentMonitorRect(@rect)   ; coordinates of current Monitor (with Mouse or nearest Monitor to Mouse
      ProcedureReturn CaptureVirtualScreenRect(ImageNo, @rect)
    EndIf
    
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i CaptureWindow(ImageNo, hWnd.i, CaptureClientOnly.i = #True)
  ; ============================================================================
  ; NAME: CaptureWindow
  ; DESC: Captures either the client area or the full area of a specified window.
  ; VAR(ImageNo): The PB ImageNo to receive the ScreenShot (or #PB_Any).
  ; VAR(hWnd.i): The handle of the target window.
  ; VAR(CaptureClientOnly.i): #True for inner area only, #False for full window including borders.
  ; RET.i: The PB Image ID (HBITMAP) on success, or 0 on failure.
  ; ============================================================================
    Protected rect.RECT
    Protected pt.POINT
    
    If Not IsWindow_(hWnd) 
      ProcedureReturn 0 
    EndIf
    
    If CaptureClientOnly = #False
      ; Get full window coordinates (already in absolute screen coordinates)
      If Not GetWindowRect_(hWnd, rect) 
        ProcedureReturn 0 
      EndIf
      
    Else
      ; Get client area coordinates (relative to the window itself)
      If Not GetClientRect_(hWnd, rect) 
        ProcedureReturn 0 
      EndIf
      
      ; Convert the top-left corner of the client area to absolute screen coordinates
      pt\x = rect\left
      pt\y = rect\top
      ClientToScreen_(hWnd, pt)
      
      ; Shift the RECT structure to the absolute screen position
      rect\right  = pt\x + (rect\right - rect\left)
      rect\bottom = pt\y + (rect\bottom - rect\top)
      rect\left   = pt\x
      rect\top    = pt\y
    EndIf
    
    ; 3. Pass the calculated RECT to the existing screen capture function
    ProcedureReturn CaptureVirtualScreenRect(ImageNo, @rect)
  EndProcedure
   
  ;- ----------------------------------------------------------------------
  ;-  Miscellaneous
  ;- ---------------------------------------------------------------------
  
  Import "shell32.lib"
    GetFinalPathNameByHandleW.l(hFile.i, *lpszFilePath, cchFilePath.l, dwFlags.l)
  EndImport
  
   
  Procedure.s GetRealPath(FileName$)
  ; ============================================================================
  ; NAME: GetRealPath
  ; DESC: Resolves symbolic links and returns the final, absolute path of a file.
  ; VAR(FileName$): The path or filename to check.
  ; RET.s: The fully resolved real path, or an empty string if failed.
  ; ============================================================================
    
    ;#FILE_NAME_OPENED = $8
    ;https://www.purebasic.fr/english/viewtopic.php?t=84664
    
    Protected file.i, pathLen.i
    Protected path$
    Protected *pathBuf
    Protected bufSizeInBytes.i = 4096 ; 4KB 
    Protected bufSizeInChars.i = bufSizeInBytes / SizeOf(Character) ; No of Charcters
    
    ; 1. Open the file to get a valid Windows Handle
    file = ReadFile(#PB_Any, FileName$)
    If file
      *pathBuf = AllocateMemory(bufSizeInBytes)
      If *pathBuf
        ; #FILE_NAME_NORMALIZED = 0 -> Resolves paths to their cleanest canonical form
        pathLen = GetFinalPathNameByHandleW(FileID(file), *pathBuf, bufSizeInChars, 0)
        
        If pathLen > 0
          ; Read the string from the buffer using the returned character length
          path$ = PeekS(*pathBuf, pathLen)
          
          ; 2. Windows specific cleanup: Remove the extended path prefix '\\?\' if present
          If Left(path$, 4) = "\\?\"
            path$ = Mid(path$, 5)
          EndIf
        EndIf
        
        FreeMemory(*pathBuf)
      EndIf
      CloseFile(file)
    EndIf
    
    ProcedureReturn path$
  EndProcedure

  Procedure.i SendString (String$)
   ; -- sends a Unicode string to the foreground window
   ; in : String$: Unicode-String (may contain characters outside of the BMP)
   ; out: number of events that were successfully inserted into the input stream
   ;
   ; <https://stackoverflow.com/questions/50420514/sendinput-wont-send-basic-unicode-to-some-windows>
  
    #KEYEVENTF_UNICODE = 4
    Protected.Character *char, *char2
    Protected.i i=0, nEvents=2*Len(String$)
     
    If OSVersion() < #PB_OS_Windows_2000 Or nEvents = 0
      ProcedureReturn 0
    EndIf
    
    Protected Dim send.Input(nEvents-1)
    *char = @String$
    
    While *char\c <> 0
      If *char\c < $D800 Or *char\c > $DFFF
        send(i)\type = #INPUT_KEYBOARD
        send(i)\ki\wVk = 0
        send(i)\ki\wScan = *char\c
        send(i)\ki\dwFlags = #KEYEVENTF_UNICODE  ; Mit diesem Flag muss \wVk = 0 sein.
        i + 1
        
        send(i)\type = #INPUT_KEYBOARD
        send(i)\ki\wVk = 0
        send(i)\ki\wScan = *char\c
        send(i)\ki\dwFlags = #KEYEVENTF_UNICODE | #KEYEVENTF_KEYUP
        i + 1
         
      Else
        *char2 = *char + SizeOf(Character)
        
        send(i)\type = #INPUT_KEYBOARD
        send(i)\ki\wVk = 0
        send(i)\ki\wScan = *char\c
        send(i)\ki\dwFlags = #KEYEVENTF_UNICODE
        i + 1
        
        send(i)\type = #INPUT_KEYBOARD
        send(i)\ki\wVk = 0
        send(i)\ki\wScan = *char2\c
        send(i)\ki\dwFlags = #KEYEVENTF_UNICODE
        i + 1
        
        send(i)\type = #INPUT_KEYBOARD
        send(i)\ki\wVk = 0
        send(i)\ki\wScan = *char\c
        send(i)\ki\dwFlags = #KEYEVENTF_UNICODE | #KEYEVENTF_KEYUP
        i + 1
        
        send(i)\type = #INPUT_KEYBOARD
        send(i)\ki\wVk = 0
        send(i)\ki\wScan = *char2\c
        send(i)\ki\dwFlags = #KEYEVENTF_UNICODE | #KEYEVENTF_KEYUP
        i + 1
        
        *char = *char2
      EndIf
      
      *char + SizeOf(Character)
    Wend
    
    ProcedureReturn SendInput_(nEvents, @send(), SizeOf(Input))
  EndProcedure

;   Structure USER_INFO_3
  ;     *usri3_name
  ;     *usri3_password
  ;     usri3_password_age.l
  ;     usri3_priv.l
  ;     *usri3_home_dir
  ;     *usri3_comment
  ;     usri3_flags.l
  ;     PB_Alignment1.b[4]
  ;     *usri3_script_path
  ;     usri3_auth_flags.l
  ;     PB_Alignment2.b[4]
  ;     *usri3_full_name
  ;     *usri3_usr_comment
  ;     *usri3_parms
  ;     *usri3_workstations
  ;     usri3_last_logon.l
  ;     usri3_last_logoff.l
  ;     usri3_acct_expires.l
  ;     usri3_max_storage.l
  ;     usri3_units_per_week.l
  ;     PB_Alignment3.b[4]
  ;     *usri3_logon_hours
  ;     usri3_bad_pw_count.l
  ;     usri3_num_logons.l
  ;     *usri3_logon_server
  ;     usri3_country_code.l
  ;     usri3_code_page.l
  ;     usri3_user_id.l
  ;     usri3_primary_group_id.l
  ;     *usri3_profile
  ;     *usri3_home_dir_drive
  ;     usri3_password_expired.l
  ;     PB_Alignment4.b[4]
  ;   EndStructure

  Procedure GetAllUsers()
    #MAX_PREFERRED_LENGTH = $FFFFFFFF

    Protected *bufptr, entriesread, totalentries
    Protected i, *buffer.USER_INFO_3
    
    If Not NetUserEnum_(0, 3, 0, @*bufptr, #MAX_PREFERRED_LENGTH, @entriesread, @totalentries, 0)
      *buffer = *bufptr
      For i = 1 To totalentries
        Debug ""
        Debug PeekS(*buffer\usri3_name, -1, #PB_Unicode)        
        Debug "UserID: " + *buffer\usri3_user_id
        Debug "Logon Server: " + PeekS(*buffer\usri3_logon_server, -1, #PB_Unicode)
        Debug "Last logon: " + FormatDate("%dd.%mm.%yyyy %hh:%ii", *buffer\usri3_last_logon)
        *buffer + SizeOf(USER_INFO_3)
        Debug "===================================================="
      Next
      NetApiBufferFree_(*bufptr)
    EndIf
  EndProcedure
  
  Procedure.s GetUserName()
    ProcedureReturn UserName()  ; UserName() is a PB built in command
  EndProcedure
  
;   Structure DISPLAY_DEVICE
;     cb.l
;     DeviceName.c[32]
;     DeviceString.c[128]
;     StateFlags.l
;     DeviceID.c[128]
;     DeviceKey.c[128]
;   EndStructure

  
  Procedure.i GetGraphicCardName()
    Protected device.DISPLAY_DEVICE
    Protected settings.DEVMODE
    device\cb = SizeOf(DISPLAY_DEVICE)
    settings\dmSize = SizeOf(DEVMODE)
    EnumDisplayDevices_(#Null,#Null,device,#Null)
    MessageRequester("","GraphicCard: "+PeekS(@device\DeviceString,128),0)
  EndProcedure
  
  Procedure.s GetWinVerString()   
  	ProcedureReturn OS::GetOsVersionString()
  EndProcedure
 
  ;- ----------------------------------------------------------------------
  ;-  Product Key
  ;- ---------------------------------------------------------------------

   ;   ; BNFPX-G8F3K-PGY24-Q6M6C-CKCKF
  ; BNFPX-G8F3K-PGY24-Q6M6C-CKCKF
  
;   Procedure.s GetBiosProductKey()
;     Protected ProviderSignature.l = 'ACPI' ; ACPI-Tabellen anfordern
;     Protected TableID.l = 'MDSM'           ; Spezifisch die MSDM-Tabelle (Achtung: Windows-API erwartet 'MDSM' oft byteweise gedreht)
;     Protected BufferSize, BytesRead
;     Protected Result.s = ""
;     
;     ; Da PureBasic-Kompilate Signaturen als Little-Endian speichern, 
;     ; müssen wir sicherstellen, dass die IDs korrekt an die Win-API übergeben werden.
;     ; 'ACPI' -> $49504341, 'MSDM' -> $4D44534D
;     Protected SignatureReg = $49504341
;     Protected TableReg     = $4D44534D
;     
;     ; 1. Puffergröße ermitteln (Funktion mit NULL-Buffer aufrufen)
;     BufferSize = GetSystemFirmwareTable_(SignatureReg, TableReg, #Null, 0)
;     
;     If BufferSize > 0
;       ; Speicher dynamisch reservieren
;       Protected *Buffer = AllocateMemory(BufferSize)
;       
;       If *Buffer
;         ; 2. Die eigentliche Tabelle aus dem BIOS in den Speicher einlesen
;         BytesRead = GetSystemFirmwareTable_(SignatureReg, TableReg, *Buffer, BufferSize)
;         
;         ; Die MSDM-Tabelle muss laut Microsoft-Spezifikation mindestens 56 Bytes Header 
;         ; plus 25 Bytes Key-Länge haben (insgesamt meist 81 Bytes).
;         If BytesRead >= 81
;           ; Der Key beginnt im Datenstrom exakt ab Byte 56 (Offset 56) und ist 25 Zeichen lang
;           ; Da er im BIOS als ASCII hinterlegt ist, lesen wir ihn passend aus
;           Result = PeekS(*Buffer + 56, 25, #PB_Ascii)
;           
;           ; Formatierungs-Validierung: Prüfen, ob sinnvolle Zeichen gelesen wurden
;           ; (Falls kein Key hinterlegt ist, stehen dort oft Nullen oder Müll)
;           If FindString(Result, " ") Or Len(Result) < 25
;             Result = ""
;           Else
;             ; Bindestriche einfügen, um das Standardformat zu erzeugen: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
;           Result = Mid(Result, 1, 5) + "-" + Mid(Result, 6, 5) + "-" + Mid(Result, 11, 5) + "-" + Mid(Result, 16, 5) + "-" + Mid(Result, 21, 5)
;           EndIf
;         EndIf
;         
;         FreeMemory(*Buffer)
;       EndIf
;     EndIf
;     
;     If Result = ""
;       Result = "Kein OEM-Hardware-Key im BIOS/UEFI vorhanden."
;     EndIf
;     
;     ProcedureReturn Result
;   EndProcedure

; Debug "Bios Product key = " + GetBiosProductKey()
           

  ; --- Test-Aufruf ---
  ; Hinweis: Zum Auslesen von Firmware-Tabellen benötigt das Programm unter Windows Admin-Rechte!
  ; Debug "Echter Hardware-Key: " + GetBiosProductKey()


 Procedure.s GetWindowsProductKey()
  #_KEY_WOW64_64KEY = $100
  Protected hKey, Res, size = 0, type = 0
  Protected I, J, x, IsWin8OrNewer, KeyContainsN, Last
  Protected Result.s = ""
  
  ; Registry öffnen
  Res = RegOpenKeyEx_(#HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", 0, #KEY_READ | #_KEY_WOW64_64KEY, @hKey)
  
  If Res = #ERROR_SUCCESS
    ; 1. Zuerst die tatsächliche Puffergröße ermitteln
    If RegQueryValueEx_(hKey, "DigitalProductId", 0, @type, #Null, @size) = #ERROR_SUCCESS And size > 0
      
      ; Speicher dynamisch anhand der echten Größe reservieren
      Protected *mem = AllocateMemory(size)
      
      If *mem
        ; Daten tatsächlich einlesen
        If RegQueryValueEx_(hKey, "DigitalProductId", 0, @type, *mem, @size) = #ERROR_SUCCESS
          
          ; Digits-Tabelle als fixer String (sicherer als Speicher-Poking)
          Protected Digits.s = "BCDFGHJKMPQRTVWXY2346789"
          Protected Dim KeyDigits(24)
          
          ; Prüfen, ob es sich um Windows 8/10/11 handelt (Größe des Eintrags ist dann meist > 100 Bytes)
          If size >= 115
            IsWin8OrNewer = 1
          Else
            IsWin8OrNewer = 0
          EndIf
          
          ; Offsets festlegen basierend auf der Windows-Version
          Protected KeyStartOffset = 52; If IsWin8OrNewer : 80 : Else : 52 : EndIf
          Protected KeyEndOffset   = 66; ?If IsWin8OrNewer : 94 : Else : 66 : EndIf
          
          ; Bei Windows 8/10/11 prüfen, ob das "N"-Flag gesetzt ist
          If IsWin8OrNewer
            KeyContainsN = (PeekA(*mem + 66) / 6) & 1
            PokeA(*mem + 66, (PeekA(*mem + 66) & $F7) | ((KeyContainsN & 2) << 2))
          Else
            KeyContainsN = 0
          EndIf
          
          ; Der eigentliche Entschlüsselungs-Algorithmus (Base24)
          For I = 24 To 0 Step -1
            x = 0
            For J = KeyEndOffset To KeyStartOffset Step -1
              x = (x << 8) | PeekA(*mem + J)
              PokeA(*mem + J, x / 24)
              x % 24
            Next
            KeyDigits(I) = x
          Next
          
          ; Den decodierten String zusammensetzen
          Protected KeyString.s = ""
          For I = 0 To 24
            KeyString + Mid(Digits, KeyDigits(I) + 1, 1)
          Next
          
          ; Wenn das "N"-Flag aktiv war, muss das 'N' an die richtige Stelle gerückt werden
          If KeyContainsN
            Last = KeyDigits(0)
            KeyString = Mid(KeyString, 2)
            Protected NPos = FindString(KeyString, Mid(Digits, Last + 1, 1))
            If NPos
              KeyString = InsertString(KeyString, "N", NPos + 1)
            Else
              KeyString = "N" + KeyString
            EndIf
          EndIf
          
          ; Bindestriche einfügen (XXXXX-XXXXX-XXXXX-XXXXX-XXXXX)
          Result = Mid(KeyString, 1, 5) + "-" + Mid(KeyString, 6, 5) + "-" + Mid(KeyString, 11, 5) + "-" + Mid(KeyString, 16, 5) + "-" + Mid(KeyString, 21, 5)
          
        EndIf
        FreeMemory(*mem)
      EndIf
    EndIf
    RegCloseKey_(hKey)
  EndIf
  
  ProcedureReturn Result
EndProcedure

Procedure.s GetWindowsProductKey2()
  #_KEY_WOW64_64KEY = $100
  Protected hKey, Res, size = 0, type = 0
  Protected I, J, x, IsWin8OrNewer, KeyContainsN, Last
  Protected Result.s = ""
  
  Res = RegOpenKeyEx_(#HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", 0, #KEY_READ | #_KEY_WOW64_64KEY, @hKey)
  
  If Res = #ERROR_SUCCESS
    If RegQueryValueEx_(hKey, "DigitalProductId", 0, @type, #Null, @size) = #ERROR_SUCCESS And size > 0
      
      Protected *mem = AllocateMemory(size)
      
      If *mem
        If RegQueryValueEx_(hKey, "DigitalProductId", 0, @type, *mem, @size) = #ERROR_SUCCESS
          
          Protected Digits.s = "BCDFGHJKMPQRTVWXY2346789"
          Protected Dim KeyDigits(24)
          
          ; Ermitteln, ob es Windows 8/10/11 Verschlüsselung ist
          If size >= 115
            IsWin8OrNewer = 1
          Else
            IsWin8OrNewer = 0
          EndIf
          
          ; Wichtig: Das Start-Offset verschiebt sich bei Windows 8/10/11 auf Byte 80!
          Protected KeyStartOffset = 52
          If IsWin8OrNewer : KeyStartOffset = 80 : EndIf
          
          Protected KeyEndOffset = KeyStartOffset + 14
          
          If IsWin8OrNewer
            KeyContainsN = (PeekA(*mem + 66) / 6) & 1
            PokeA(*mem + 66, (PeekA(*mem + 66) & $F7) | ((KeyContainsN & 2) << 2))
          Else
            KeyContainsN = 0
          EndIf
          
          ; Base24-Entschlüsselung
          For I = 24 To 0 Step -1
            x = 0
            For J = KeyEndOffset To KeyStartOffset Step -1
              x = (x << 8) | PeekA(*mem + J)
              PokeA(*mem + J, x / 24)
              x % 24
            Next
            KeyDigits(I) = x
          Next
          
          ; String aus Digits bauen
          Protected KeyString.s = ""
          For I = 0 To 24
            KeyString + Mid(Digits, KeyDigits(I) + 1, 1)
          Next
          
          ; Windows 10/11 "N"-Modifikation via PureBasic Mid() gelöst:
          If KeyContainsN
            Last = KeyDigits(0)
            ; Erstes Zeichen abschneiden (entspricht deinem Mid ab Pos 2)
            KeyString = Mid(KeyString, 2) 
            
            Protected NPos = FindString(KeyString, Mid(Digits, Last + 1, 1))
            If NPos
              KeyString = Mid(KeyString, 1, NPos) + "N" + Mid(KeyString, NPos + 1)
            Else
              KeyString = "N" + KeyString
            EndIf
          EndIf
          
          ; Formatierung (XXXXX-XXXXX-XXXXX-XXXXX-XXXXX)
          Result = Mid(KeyString, 1, 5) + "-" + Mid(KeyString, 6, 5) + "-" + Mid(KeyString, 11, 5) + "-" + Mid(KeyString, 16, 5) + "-" + Mid(KeyString, 21, 5)
          
          ; Sicherheitscheck: Wenn der Key nur aus "B"s besteht, wurde er von Windows gelöscht!
          If Result = "BBBBB-BBBBB-BBBBB-BBBBB-BBBBB" Or Result = "BNBBB-BBBBB-BBBBB-BBBBB-BBBBD"
            Result = "Kein Key in Registry hinterlegt (Digitale Lizenz / OEM)"
          EndIf
          
        EndIf
        FreeMemory(*mem)
      EndIf
    EndIf
    RegCloseKey_(hKey)
  EndIf
  
  ProcedureReturn Result
EndProcedure

Debug GetWindowsProductKey()

; --- Test-Aufruf ---
Debug "Windows Product Key: " + GetWindowsProductKey()
  
  
EndModule

;- ----------------------------------------------------------------------
;- Test Code
;  ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; UseModule 
  Debug Win::GetWindowsProductKey()
  Debug Win::GetWinVerString()
  OpenConsole()
  
  Define ver$, key$
  key$ = Win::GetWindowsProductKey()
  ver$ = Win::GetWinVerString()
 
  PrintN( key$ )
  PrintN( ver$ )
  Input()
  
  ; Win::GetAllUsers()
  ;Win::GetGraphicCardName()
  DisableExplicit
CompilerEndIf


; Default_UserDir$ = GetPathPart( GetEnvironmentVariable("userprofile") ) + "Default\"
; Debug Default_UserDir$
; Debug GetEnvironmentVariable("public")


; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 35
; FirstLine = 15
; Folding = ----------
; Optimizer
; Executable = ..\..\WinKey.exe
; CPU = 5