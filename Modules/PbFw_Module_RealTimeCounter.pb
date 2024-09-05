; ===========================================================================
;  FILE: PbFw_Module_RealTimeCounter.pb
;  NAME: Module RealTimeCounter/Clock [RTC::]
;  DESC: Provides access to CPU's RealTime Counter/Clock, with
;  DESC: high precision!
;  DESC: The purpose is to measure cycle times in the microsecond and
;  DESC: nanosecond range. For nanseconds please note the minimum timer
;  DESC: resoltion what is usallay 100ns on modern AMD/Intel x64 CPU's.
;  DESC: Check the Timer resolution with GetRtcResolution_ns() first!
;  DESC:
;  DESC: Under Windows: QueryPerformanceFrequency(), QueryPerfomanceCounter()
;  DESC: Under Linux:   clock_getres(),              clock_gettime()
;  DESC: Under MacOS:   mach_timebase_info(),        mach_absolute_time()
;  DESC:
;  DESC: The problem of the CPU rtc-Registers is: to read it, kernel-mode
;  DESC: is necessary. Because of this it is not possible to read it with
;  DESC: a few assembler commands. We have to use the OS-functions.
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/08/26
; VERSION  :  0.23 Developer Version
; COMPILER :  all
; OS       :  all
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{  2024/08/27 S.Maag
;             - corrected GetTimeStamp() Linux And Mac call of gettimeofday()
;             - added TimeStamp Functions With ms precision
;             - for Linux and Mac tv_nsec.i not .l 
;               (tested by NickTheQuick for Linux x64. Probably same for MacOS) 
;}
;{ TODO: Test for Linux and MacOS, see TestTable at end of file
;}
; ===========================================================================

;- --------------------------------------------------
;- Include Files
;  --------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule RTC
  EnableExplicit
  
  ; Constans for the HPT 16x HighPerformanceTimer
  #RTC_STOP = 0       ; STOP Timer and return the time difference since start
  #RTC_START = 1      ; START Timer and return the StartValue in MicroSeconds or NanoSeconds
  #RTC_READ = 2       ; Read the time value [µs] (if Timer is stopped, it's the differntial time. If timer is started it is the START-Time)
  
  #RTC_MicroSeconds = 0
  #RTC_NanoSeconds = 1
  
  #RTC_MaxTimerNo = 15          ; Timers [0..#RTC_MaxTimerNo]  = [0..15]! Change this value if you need more Timers
  
  Structure TDateAndTime        ; DateAndTime Structure to convert a TimeStamp
    wYear.w
    wMonth.w
    wDay.w
    wHour.w
    wMinute.w
    wSecond.w
    wMilliseconds.w
  EndStructure

  Structure THPT                ; Structure to hold the Timer datas
    T.q[#RTC_MaxTimerNo+1]      ; Timer Value
    xRun.i[#RTC_MaxTimerNo+1]   ; Timer Run-State : #False = Stop, #True = Run
  EndStructure
  
  ; Basic Functions
  Declare.i GetRtcResolution_ns()     ; Get the NanoSeconds per TickCount : >0 if CPU and OS support RTC Function
  Declare.q ElapsedMicroseconds()     ; Elapsed MicorSeconds
  Declare.q ElapsedNanoseconds()      ; Elapsed NanoSeconds
  
  ; TimeStamp Functions
  Declare.q GetTimeStamp()            ; Get Date with ms precision : TimeStamp = Date()*1000 + ms
  Declare.i TimeStampToDateAndTime(*OutDT.TDateAndTime, Timestamp.q)
  
  ; High Performance Timer
  Declare.q HPT(cmd=#RTC_START, TimerNo=0, TimeBase=#RTC_MicroSeconds)
  Declare.q HPTcal()                    ; calibarte Timer (calculate Timer Start/Stop Time for clibartion)
  Declare.i HPTget(*HPTstruct.THPT)     ; Get a copy of the internal TimerStrucure with actual values

EndDeclareModule

Module RTC
  EnableExplicit
  
  #_MicroBase = 1e6     ;     1.000.000 = 1MHz
  #_NanoBase  = 1e9     ; 1.000.000.000 = 1GHz
   
  ; ----------------------------------------------------------------------
  ;  Import OS specific functions
  ; ----------------------------------------------------------------------
  CompilerSelect #PB_Compiler_OS
      
    CompilerCase #PB_OS_Windows 
    ; ----------------------------------------------------------------------
    ;  Windows
    ; ----------------------------------------------------------------------
    ; QueryPerformanceFrequency() : Bool
    ;     Retrieves the frequency of the performance counter.
    ;     The frequency of the performance counter is fixed at system boot
    ;     and is consistent across all processors.
    ;     Therefore, the frequency need only be queried upon application initialization,
    ;     and the result can be cached.
      
    ; QueryPerformanceCounter-Funktion() : Bool
    ;     Retrieves the current value of the performance counter, which is a high 
    ;     resolution (<1us) time stamp that can be used For time-interval measurements.
      
    CompilerCase #PB_OS_Linux 
    ; ----------------------------------------------------------------------
    ;  Linux
    ; ----------------------------------------------------------------------
     
   		;#CLOCK_REALTIME           = 0
     		; System-wide clock that measures real (i.e., wall-clock) time. 
        ; Setting this clock requires appropriate privileges.
        ; This clock is affected by discontinuous jumps in the system time
        ;(e.g., If the system administrator manually changes the clock), 
        ; And by the incremental adjustments performed by adjtime(3) And NTP.
   		#CLOCK_MONOTONIC          = 1
     		; Clock that cannot be set and represents monotonic time since some
        ; unspecified starting point. This clock is not affected by discontinuous:
        ; jumps in the system time (e.g., If the system administrator manually;
        ; changes the clock), but is affected by the incremental adjustments 
     		; performed by adjtime(3) And NTP. 

   		;#CLOCK_PROCESS_CPUTIME_ID = 2
   		  ; High-resolution per-process timer from the CPU. 
   		
   		;#CLOCK_THREAD_CPUTIME_ID  = 3
   		  ; Thread-specific CPU-time clock.
   		
   		;#CLOCK_REALTIME_HR        = 4
  		;#CLOCK_MONOTONIC_HR       = 5
    	;#CLOCK_MONOTONIC_COARSE	  = 6
    	;#CLOCK_BOOTTIME			      = 7
    	;#CLOCK_REALTIME_ALARM		  = 8
    	;#CLOCK_BOOTTIME_ALARM		  = 9
    	
;     	struct timespec {
;     	  time_t		tv_sec
;     	  long		tv_nsec 
   		

   		; TODO! Check if correct in x32 and x64, because time_t is more or less an unspecified type! 		
      Structure timespec
        tv_sec.i            
        tv_nsec.i
      EndStructure     
      
      ; struct timeval {
      ;        time_t       tv_sec;   /* seconds since Jan. 1, 1970 */
      ;        suseconds_t  tv_usec;  /* and microseconds */
      ; 
      
      Structure timeval
        tv_sec.i    ; seconds since Jan. 1, 1970 - that's indentical with PB Date
        tv_usec.i   ; and microseconds
      EndStructure
      
      ; struct timezone {
      ;        int     tz_minuteswest; /* of Greenwich */
      ;        int     tz_dsttime;     /* type of dst correction to apply */
      
      Structure timezone
        tz_minuteswest.i 
        tz_dsttime.i
      EndStructure
      
      ; gettimeofday(struct timeval *restrict tp, void *restrict tzp);
        
      ImportC ""
       ; all functions return 0 for succeeded and -1 for error on Linux
       ; clock_gettime(), clock_getres() return 0 for success, Or -1 for failure
        clock_getres.i (clock_id.i, *res.timespec )
        clock_gettime.i(clock_id.i, *tp.timespec  )
        
        ; gettimeofday(struct timeval *restrict tp, void *restrict tzp);
        gettimeofday(*tp.timeval, *tzp.timezone)      
      EndImport
           
    CompilerCase #PB_OS_MacOS     
    ; ----------------------------------------------------------------------
    ;  MacOS
    ; ----------------------------------------------------------------------
      
      ; https://developer.apple.com/documentation/driverkit/3433733-mach_timebase_info
            
      ; mach_timebase_info: Returns fraction To multiply a value in mach tick units with to convert it to nanoseconds
      ;   uint64_t mach_absolute_time(void);
      
      ; mach_absolute_time: Returns current value of a clock that increments monotonically in tick units
      ;   (starting at an arbitrary point), this clock does not increment while the system is asleep.
      ;   kern_return_t mach_timebase_info(mach_timebase_info_data_t info);
      
      ; mach_continuous_time
      ;   Returns current value of a clock that increments monotonically in tick units
      ;   (starting at an arbitrary point), including while the system is asleep.
      
      Structure mach_timespec
        tv_sec.i    ; unsigned int tv_sec;
        tv_nsec.i   ; typedef int clock_res_t;
      EndStructure
      
      ; mach_timebase_info_data_t
      ; Raw Mach Time API In general prefer to use the <time.h> API clock_gettime_nsec_np(3),
      ; which deals in the same clocks (And more) in ns units. Conversion of ns To (resp. from)
      ; tick units As returned by the mach time APIs is performed by division (resp. multiplication)
      ; with the fraction returned by mach_timebase_info().
      
      Structure mach_timebase_info_data_t
        numer.l     ; uint32_t numer;
        denom.l     ; uint32_t denom;
      EndStructure     
      
      ; struct timeval {
      ;        time_t       tv_sec;   /* seconds since Jan. 1, 1970 */
      ;        suseconds_t  tv_usec;  /* and microseconds */
      ; 
            
      Structure timeval
        tv_sec.i    ; seconds since Jan. 1, 1970  - that's indentical with PB Date
        tv_usec.i   ; and microseconds
      EndStructure
      
      ; struct timezone {
      ;        int     tz_minuteswest; /* of Greenwich */
      ;        int     tz_dsttime;     /* type of dst correction to apply */
      
      Structure timezone
        tz_minuteswest .i 
        tz_dsttime.i
      EndStructure
      
      ; gettimeofday(struct timeval *restrict tp, void *restrict tzp);
      
      ImportC ""
        ; all functions return 0 for succeeded and -1 for error on MacOS
        mach_timebase_info.i(*info.TMac_mach_timbase_info_t)
        mach_absolute_time.q()      ; counter stop in sleep mode
        ; mach_continuous_time.q()    ; counter work in sleep mode
        
        ; gettimeofday(struct timeval *restrict tp, void *restrict tzp);
        gettimeofday(*tp.timeval, *tzp.timezone)
      EndImport
      
  CompilerEndSelect
  
  ; Variable for RTC resolution in NanoSeconds (1 Tick = rtcRes_ns NanoSeconds) (on Ryzen 5800 this is 100)
  ; on Windows this is (1.000.000.000 / QueryPerformanceFrequnecy())
  Global.i rtcRes_ns    
            
  Procedure.i _Init()
  ; ============================================================================
  ; NAME: _Init
  ; DESC: Init the Tick resolution
  ; RET.i : #True if RTC is supported
  ; ============================================================================
    
    ; according to the Windows documentation of QueryPerformanceFrequency we can init once and store value!
    ; "The frequency of the performance counter is fixed at system boot and is consistent across all processors."

    rtcRes_ns = 0    ; Set RealTimeCounter resolution = 0
    
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
        Protected v.q 
        
        If Not QueryPerformanceFrequency_(@v) 
          ProcedureReturn #False 
        EndIf
        
        If v = 0                                
          ProcedureReturn #False 
        EndIf
        
        rtcRes_ns = #_NanoBase / v
        
        ProcedureReturn #True
        
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
        Protected v.timespec
        
        If clock_getres(#CLOCK_MONOTONIC,@v) 
          ProcedureReturn #False 
        EndIf
        
        ;TODO! Check this!
        ; as I understand, Linux delivers in v\tv_nsec the NanoSeconds per Tick
        ; but I'm not sure!
        rtcRes_ns =  v\tv_nsec
                         
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Protected v.mach_timebase_info_data_t
        Protected resq.q
        
        mach_timebase_info(@v)
        ; to be sure to not get problems at x32 we caclulate resultion in Quad first 
        resq =  (#_NanoBase * v\denom) / v\numer  ; calculate resolution in Quad
        rtcRes_ns = res
        
    CompilerEndSelect
  EndProcedure
  
  _Init() ; AutoInit the clock resolution

  Procedure.i GetRtcResolution_ns()
  ; ============================================================================
  ; NAME: GetRtcResolution_ns
  ; DESC: Returns the TickResolution in NanoSeconds per Tick
  ; DESC: Call this function first to check RTC support
  ; RET.i : NanoSeconds per Tick or 0 if RTC is not supported
  ; ============================================================================
    ProcedureReturn rtcRes_ns  
  EndProcedure
      
  Procedure.q ElapsedMicroseconds()
  ; ============================================================================
  ; NAME: ElapsedMicroSeconds
  ; DESC: Returns a value for ElapsedMicroSeconds starting at unspecific point
  ; RET.q : Elapsed MicroSeconds
  ; ============================================================================
    
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
        Protected v.Quad
        QueryPerformanceCounter_(v)      
        ; MicroSeconds = CounterTicks * ResolutionNanoSeconds / 1000
        ProcedureReturn (v\q * rtcRes_ns) / 1000  ; normalize value to MicroSeconds
         
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
        Protected v.timespec
        clock_gettime(#CLOCK_MONOTONIC, @v)
        
        ProcedureReturn (v\tv_sec * #_MicroBase)  + v\tv_nsec / 1000
                
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Protected v.q
        v = mach_absolute_time()      ; stop in sleep mode
        ;v = mach_continuous_time()    ; countinous count in sleep mode

        ProcedureReturn (v * rtcRes_ns) / 1000
       
    CompilerEndSelect
  
  EndProcedure
  
  Procedure.q ElapsedNanoseconds()
  ; ============================================================================
  ; NAME: ElapsedNanoSeconds
  ; DESC: Returns a value for ElapsedNanoSeconds starting at unspecific point
  ; RET.q : Elapsed NanoSeconds
  ; ============================================================================
   
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
       Protected v.Quad
        QueryPerformanceCounter_(v)      
        ; MicroSeconds = CounterTicks * ResolutionNanoSeconds / 1000
        ; Debug "QueryPerformanceCounter = " + Str(v\q)
        ProcedureReturn (v\q * rtcRes_ns) 
         
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
        Protected v.timespec
        clock_gettime(#CLOCK_MONOTONIC, @v)
        
        ProcedureReturn (v\tv_sec * #_NanoBase)  + v\tv_nsec
                
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Protected v.q
        v = mach_absolute_time()      ; stop in sleep mode
        ;v = mach_continuous_time()  ; countinous count in sleep mode

        ProcedureReturn (v * rtcRes_ns)
        
    CompilerEndSelect
  EndProcedure
  
  Procedure.q GetTimeStamp()
  ; ============================================================================
  ; NAME: GetTimeStamp
  ; DESC: Get Date with [ms] precision as Timestamp of UTC-Time (Greenwich Mean Time)
  ; DESC: Because PB do not support milliseconds in the Date() format, we
  ; DESC: have to read manualy the Sytem Time with high precision!
  ; DESC: To get get back a valid PB-Date Date= TimeStap/1000
  ; DESC: To get back the ms from TimeStamp ms= TimpeStamp%1000    
  ; RET.q : The Date with millisecond precision : Date()*1000 + ms
  ; ============================================================================
    Protected tstmp.q    ; Timestamp
    
    ; ----------------------------------------------------------------------
    ; ts = (Date() * 1000) + (ElapsedMicroseconds()/1000) % 1000
    ; ----------------------------------------------------------------------
    ; this easy Methode don't work because the ms are not sychron with 
    ; the seconds. So many times we will get a lower time later!
    ; ----------------------------------------------------------------------    
    
    ; !We have to read the CPU System Clock with ms precision!
    
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
        Protected dt.SYSTEMTIME   ; Date and Time
        
        ; Structure SYSTEMTIME    ; predefined in PB
        ;   wYear.w
        ;   wMonth.w
        ;   wDayOfWeek.w
        ;   wDay.w
        ;   wHour.w
        ;   wMinute.w
        ;   wSecond.w
        ;   wMilliseconds.w
        ; EndStructure
        
        ; changed to UTC Time because on Mac/Linux gettimeofday delivers UTC-Time 
        GetSystemTime_(@dt)     ; SystemTime - UTC()
        ; GetLocalTime_(@dt)    ; SystemTime - LocalTime
        With dt
          tstmp = Date(\wYear, \wMonth, \wDay, \wHour, \wMinute, \wSecond) * 1000 + dt\wMilliseconds
        EndWith
        
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
       Protected tim.timeval, tz.timezone
       
       ;gettimeofday(*tp.timeval, *tzp.timezone)
       gettimeofday(@tim, @tz)
       tstmp = tim\tv_sec *1000 + tim\tv_usec /1000   ; add milliseconds = microseconds /1000
                
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Protected tim.timeval, tz.timezone
        
        ;gettimeofday(*tp.timeval, *tzp.timezone)
        gettimeofday(@tim, @tz)
        tstmp = tim\tv_sec *1000 + tim\tv_usec /1000   ; add milliseconds = microseconds /1000
    CompilerEndSelect
    
    ProcedureReturn tstmp
  EndProcedure
  
  Procedure.i TimeStampToDateAndTime(*OutDT.TDateAndTime, Timestamp.q)
  ; ============================================================================
  ; NAME: TimpeStampToDateAndTime
  ; DESC: Converts the ms based TimeStamp to a DateAndTime Structure
  ; DESC: 
  ; VAR(*OutDT.TDateAndTime) : Pointer to the returned DateAndTime Structrue
  ; RET.i : *Out
  ; ============================================================================
   If *OutDT
      With *OutDT
        \wMilliseconds = Timestamp % 1000
        
        Timestamp = Timestamp / 1000  ; Now Timestamp is the second based PB Date
        
        \wYear   = Year(Timestamp)
        \wMonth  = Month(Timestamp)
        \wDay    = Day(Timestamp)
        \wHour   = Hour(Timestamp)
        \wMinute = Minute(Timestamp)
        \wSecond = Second(Timestamp)
     EndWith
    EndIf
    
    ProcedureReturn *OutDT
  EndProcedure
      
  ; private vars
  Global _HPT.THPT  ; TimerValues Structure for Timers [0..#RTC_MaxTimerNo]
  Global _HPT_Calibration.q  ; calibration ticks : Time for calling HPT() in NanoSeconds
  
  Procedure.q HPT(cmd=#RTC_START, TimerNo=0, TimeBase=#RTC_MicroSeconds)
  ; ============================================================================
  ; NAME: HPT
  ; DESC: HighPerformanceTimer, MultiTimer
  ; DESC: Provides a set of easy to use timers for software speed tests!
  ; VAR(cmd) : #RTC_START, #RTC_STOP, #RTC_READ
  ; VAR(TimerNo) : No of the Timer [0..#RTC_MaxTimerNo]
  ; VAR(TimeBase) : #RTC_NanoSeconds, #RTC_MicroSeconds
  ; RET.q : Elapsed Time according to Timers
  ; ============================================================================
         
    If TimerNo <0 Or TimerNo > #RTC_MaxTimerNo
      ProcedureReturn -1
    EndIf
    
    Select cmd
        
      Case #RTC_START       ; START Timer --> save actual value of QueryPerformanceCounter in DataSection
      ; ----------------------------------------------------------------------
      ;  Start the Timer
      ; ----------------------------------------------------------------------
        
        _HPT\T[TimerNo] = ElapsedNanoseconds()        
        _HPT\xRun[TimerNo] = #True         ; Set Run State = #True
        
        If TimeBase = #RTC_MicroSeconds
          ProcedureReturn _HPT\T[TimerNo] / 1000
        Else        ; #RTC_NanoSeconds
          ProcedureReturn _HPT\T[TimerNo]
        EndIf
         
      Case #RTC_STOP        ; STOP Timer
      ; ----------------------------------------------------------------------
      ;  Stop the Timer
      ; ----------------------------------------------------------------------
        
        _HPT\T[TimerNo] = ElapsedNanoseconds() - _HPT\T[TimerNo] - _HPT_Calibration
  
        If _HPT\T[TimerNo] < 0           ; Abs() because PB's Abs() is for floats only
          _HPT\T[TimerNo] = - _HPT\T[TimerNo] 
        EndIf
        
        _HPT\xRun[TimerNo] = #False      ; Set Run State = #False 
        If TimeBase = #RTC_MicroSeconds
          ProcedureReturn _HPT\T[TimerNo] / 1000
        Else        ; #RTC_NanoSeconds
          ProcedureReturn _HPT\T[TimerNo]
        EndIf
        
      Case #RTC_READ
      ; ----------------------------------------------------------------------
      ;  Read the Timer
      ; ----------------------------------------------------------------------
        Protected ret.q
        
        If _HPT\xRun[TimerNo]
          ret = ElapsedNanoseconds() - _HPT\T[TimerNo] - _HPT_Calibration
          If ret < 0 : ret = -ret : EndIf      
        Else
          ret= _HPT\T[TimerNo]
        EndIf
        
        If TimeBase = #RTC_MicroSeconds
          ProcedureReturn _HPT\T[TimerNo] / 1000
        Else        ; #RTC_NanoSeconds
          ProcedureReturn _HPT\T[TimerNo]
        EndIf
               
    EndSelect
         
  EndProcedure
  
  Procedure.q HPTcal()
  ; ============================================================================
  ; NAME: HPTcal
  ; DESC: HPT calibration routine to test the offset for a Timer START/STOP call 
  ; DESC: Afer a call of HPTcal() the Calibration offset will be automatically
  ; DESC: subtracted from the Time when reading a Timer.
  ; DESC: If you do not call HPTcal() the calibration value is 0ns and
  ; DESC: you get the uncalibrated TimeValue when reading a Timer.
  ; DESC: For calibration Timer(#RTC_MaxTimerNo) is used.
  ; DESC: So don't cal HPTcal() if this Timer is in operation!
  ; RET.q : Calibration offset for a Timer START/STOP call
  ; ============================================================================
    Protected tim.q
    
    ; detecet the Time for a Timer Start/STOP Call
    tim = ElapsedNanoseconds()
    HPT(#RTC_START, #RTC_MaxTimerNo, #RTC_NanoSeconds)   
    HPT(#RTC_STOP, #RTC_MaxTimerNo, #RTC_NanoSeconds)
    tim = ElapsedNanoseconds() - tim
    If tim <0 : tim = -tim : EndIf 
    
    _HPT_Calibration = tim
    ProcedureReturn tim     ; No of Ticks at QueryPerformanceFrequency
  EndProcedure
  
  Procedure.i HPTget(*HPTstruct.THPT)
  ; ============================================================================
  ; NAME: HPTget
  ; DESC: Get all the internal Timer values in a THPT Structure
  ; VAR(*HPTstruct.THP) : Pointer to Return Structure
  ; RET.i : *HPTstruct
  ; ============================================================================
    If *HPTstruct
      *HPTstruct = _HPT  
    EndIf
    
    ProcedureReturn @*HPTstruct  
  EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
;- --------------------------------------------------
;- Test Code:
;- --------------------------------------------------
  
  Procedure.s TimeStampToString(TimeStamp.q)
    Protected txt.s
    Protected DT.RTC::TDateAndTime
    Protected vDate.q = TimeStamp / 1000
    
    RTC::TimeStampToDateAndTime(DT, TimeStamp)
    
    txt = FormatDate("%yyyy/%mm/%dd-%hh:%mm:%ss", vDate) 
    txt + ":" + Str(TimeStamp%1000)
    ProcedureReturn txt   
  EndProcedure
  
  Define I, t1, t2, t3 ,cal
  Define msg.s
  
  t1 = RTC::ElapsedMicroseconds()
  Delay(10)
  t1 = RTC::ElapsedMicroseconds() - t1
  
  t2= RTC::ElapsedNanoseconds()
  Debug "Start t2 = " + Str(t2)
  Delay(10)
  t2 = RTC::ElapsedNanoseconds() - t2
  Debug "t2 = " + Str(t2)
  
  cal = RTC::HPTcal()   ; get the Calibration Value (Time for Timer START/STOP)
  RTC::HPT()            ; Start Timer[0]
  Delay(10)
  RTC::HPT(RTC::#RTC_STOP)  ; STOP Timer[0]
  
  t3 = RTC::HPT(RTC::#RTC_READ) ; Read Value of Timer[0]
  
  OpenConsole()
  PrintN("")
  PrintN("RTC Timer Resolution NanoSeconds = " + Str(RTC::GetRtcResolution_ns()))
  PrintN("")
  PrintN("------------------------------------------------------------")
  PrintN(" Test Elapsed MicroSeconds and NanoSeconds ")
  PrintN("------------------------------------------------------------")
  PrintN("ElapsedMicroSeconds of Delay(10)= " + Str(t1))
  PrintN("ElapsedNanoSeconds of Delay(10) = " + Str(t2))
  PrintN("")
  PrintN("------------------------------------------------------------")
  PrintN(" Test HPT HighPerformanceTimer Function ")
  PrintN("------------------------------------------------------------")
  PrintN("calibration Value NanoSeconds = " + Str(cal))
  PrintN("ElapsedMicroSeconds of Delay(10) = " + Str(t3))
  
  PrintN("")
  PrintN("------------------------------------------------------------")
  PrintN(" max time what can be stored in a Quad as NanoSeonds ")
  PrintN("------------------------------------------------------------")

  Define Qmax.q = 9223372036854775807   ; max of a Quad
  Define sec.q  = Qmax / 1e9       ; max Number of Seconds 
  Define days.q = sec / (3600*24)   ; max Number of Days 
  Define years.q = days /365        ; max Number of Years 
  
  PrintN( "max Sec = " +Str(sec) )
  PrintN( "max Day = " +Str(days) )
  PrintN( "max Year = " +Str(years) )
  PrintN("")
  
  PrintN("------------------------------------------------------------")
  PrintN(" GetTimeStamp with ms precision +50ms +500ms")
  PrintN("------------------------------------------------------------")
  
  Define DT.RTC::TDateAndTime
  Define tstmp.q
  tstmp = RTC::GetTimeStamp()
  RTC::TimeStampToDateAndTime(DT, tstmp)
  ; RTC::TimpeStampToDateAndTime(DT, Date()*1000)
  
  PrintN(TimeStampToString(tstmp))
  
  Delay(50)
  tstmp = RTC::GetTimeStamp()
  RTC::TimeStampToDateAndTime(DT, tstmp)
  PrintN(TimeStampToString(tstmp))
  
  Delay(500)
  tstmp = RTC::GetTimeStamp()
  RTC::TimeStampToDateAndTime(DT, tstmp)
  PrintN(TimeStampToString(tstmp))
 
  PrintN("")
  PrintN("Press a button to exit!")
  Input()
 
CompilerEndIf

;  --------------------------------------------------
;- Test results: i.O.
;- --------------------------------------------------

; Intel/AMD            | Date       | by Name
; --------------------------------------------------
; Windows x64, PBx32   | 2024/08/27 | SMaag
; Windows x64, PBx64   | 2024/08/27 | SMaag
; Windows x32, PBx32   |            |

; Linux x64, PBx32     |            |
; Linux x64, PBx64     |            |
; Linux x32, PBx32

; MaxOS x64, PBx32     |            |
; MaxOS x64, PBx64     |            |

; --------------------------------------------------
; ARM                  | Date       | by Name
; --------------------------------------------------
; RaspII x32           |            |
; RaspII x64           |            |
; MaxOS x64, PBx32     |            |
; MaxOS x64, PBx64     |            |
; --------------------------------------------------

; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 452
; FirstLine = 404
; Folding = ---
; Optimizer
; CPU = 5