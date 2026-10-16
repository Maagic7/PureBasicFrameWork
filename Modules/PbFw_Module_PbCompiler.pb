; ===========================================================================
;  FILE : PbFw_Module_PbCompiler.pb
;  NAME : Module PureBasic Compiler Functions PbComp::
;  DESC : 
;  DESC : 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2025/08/16
; VERSION  :  0.5 untested Developer Version
; COMPILER :  PB6.0+
; OS       :  Win!, Linux?, Mac?
; ===========================================================================
; ChangeLog:
;{
; 2025/08/16 S.Maag : 
;}
;{ TODO:
;}
; ===========================================================================

; XIncludeFile "PbFw_Module_PbCompiler.pb"          ; PX::      Purebasic Extention Module

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module
XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module

 
DeclareModule PbComp
  
EnableExplicit
  ;- Declare Public Functions
  Declare CompilerStop()
  Declare.i CompilerStart(TimeOut_ms=2000)
  Declare CompilerWrite(command$, Mode=#PB_Ascii)
  Declare.s CompilerRead(Mode=#PB_Ascii)
  Declare.s CompilerRead_NoDebug(Mode=#PB_Ascii)
  Declare.i CompilerReadList(List lstOut.s(), AddSpacesLeft=0, Mode=#PB_Ascii)

  Declare GetConstantsList(List lstOut.s())
  Declare GetStructureList(List lstOut.s())
  Declare GetProcedureList(List lstOut.s())
  Declare GetInterfaceList(List lstOut.s())
  Declare GetStructureInfo(struct$,List lstOut.s())
  Declare GetInterfaceInfo(interf$,List lstOut.s())

EndDeclareModule

Module PbComp
  EnableExplicit
  
  CompilerIf Defined(PbFw, #PB_Module)
    PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  CompilerEndIf 
  
  #CompilerProg = #PB_Compiler_Home + "compilers\pbcompiler.exe"
  #Compiler_OutputEnd$ = ~"OUTPUT\tCOMPLETE"    ; OUTPUT + TAB$ + COMPLETE
  
  Global m_hCompiler   ; Program handle for the Compiler
  
  Procedure CompilerStop()
  ; ============================================================================
  ; NAME: CompilerStop
  ; DESC: Stop and unload the compiler
  ; DESC: 
  ; RET : -
  ; ============================================================================
    If ProgramRunning(m_hCompiler)
      WriteProgramStringN(m_hCompiler, "END")
      WaitProgram(m_hCompiler, 5000)
      CloseProgram(m_hCompiler)
    EndIf
    m_hCompiler=0
  EndProcedure

  Procedure.i CompilerStart(TimeOut_ms=2000)
  ; ============================================================================
  ; NAME: CompilerStart
  ; DESC: Start the Compiler and wait for Compiler ready
  ; RET.i : Program handle, m_hCompiler
  ; ============================================================================
    
    Protected hComp, msg$, tim
    
    m_hCompiler = RunProgram(#CompilerProg, "/STANDBY", "", #PB_Program_Open|#PB_Program_Read|#PB_Program_Write|#PB_Program_Hide)
    Debug "hComp = " + m_hCompiler
    
    If m_hCompiler
      ; wait for Compiler ready
      tim = ElapsedMilliseconds()
      Delay(100)
      Repeat
        msg$ = CompilerRead()
        Debug "Compiler Read : " + msg$
        If (ElapsedMilliseconds()-tim) > TimeOut_ms
          Debug "Compiler Start TimeOut"
          ; TimeOut
          If ProgramRunning(m_hCompiler)
            CompilerStop()
          EndIf
          m_hCompiler = 0
          Break
        EndIf         
        Delay(10)
      Until msg$="READY" Or Left(msg$,5)="ERROR"
      
      Debug "CompilerStart"
    EndIf   
    ProcedureReturn m_hCompiler
  EndProcedure
  
  Procedure CompilerWrite(command$, Mode = #PB_Ascii)
  ; ============================================================================
  ; NAME: CompilerWrite
  ; DESC: send/write a command to the Compiler
  ; VAR(command$): The command
  ; VAR(Mode): The Character Mode    
  ; RET : -
  ; ============================================================================
    If ProgramRunning(m_hCompiler)
      WriteProgramStringN(m_hCompiler, command$, Mode)
      Debug "CompilerWrite : " + command$
    EndIf
  EndProcedure
  
  ; this is token from PB-IDE! Seems to be a helper var for switch of de
  Define _CompilerRead_FirstNoDebug
  
  Procedure.s CompilerRead(Mode=#PB_Ascii)
  ; ============================================================================
  ; NAME: CompilerRead
  ; DESC: read a line of the Compiler output
  ; VAR(Mode): The Character Mode    
  ; RET.s : String with Compiler output
  ; ============================================================================
    Shared _CompilerRead_FirstNoDebug
    Protected msg$
    
    _CompilerRead_FirstNoDebug = #True
    Debug "hCompiler = " + m_hCompiler
    Debug "Mode = " + Mode
    If AvailableProgramOutput(m_hCompiler)
      msg$ = ReadProgramString(m_hCompiler, Mode)
      Debug "[COMPILER  READ] " + ReplaceString(msg$, Chr(9), "<T>")
      ProcedureReturn msg$
    EndIf
  EndProcedure
  
  Procedure.s CompilerRead_NoDebug(Mode = #PB_Ascii)
    Shared _CompilerRead_FirstNoDebug
    
    If _CompilerRead_FirstNoDebug
      Debug "[COMPILER      ] Skipping display of read data."
      _CompilerRead_FirstNoDebug = #False
    EndIf   
    If AvailableProgramOutput(m_hCompiler)
      ProcedureReturn ReadProgramString(m_hCompiler, Mode)
    EndIf
    ProcedureReturn #Null$
  EndProcedure

  Procedure.i CompilerReadList(List lstOut.s(), AddSpacesLeft=0, Mode=#PB_Ascii)
  ; ============================================================================
  ; NAME: CompilerReadList
  ; DESC: Get the RAW Compiler output as String List
  ; DESC: Attention this is the direct and unrpocessed output. 
  ; VAR(List lstOut.s()): The list to retrieve the Compiler output  
  ; VAR(AddSpacesLeft=0) : add No of Spaces at left. Use it for Structure Elements
  ; RET.i : No of Elements read
  ; ============================================================================
    Protected msg$, N, I 
    Protected space$ = Space(AddSpacesLeft)
    
    ; Info token from PB-IDE SourceCode
    msg$=CompilerRead_NoDebug(Mode)    ; first Output is NoOfElements
    N= Val(msg$)      ; Don't use this number as it was broken before 5.40. We don't need it anyway.
    Debug "compiler message = " + msg$
    
    Repeat
      msg$=CompilerRead()
      Debug msg$      
      If msg$= #Compiler_OutputEnd$ Or Left(msg$,5)<>"ERROR"
        Break
      EndIf
      I+1
      AddElement(lstOut())
      If AddSpacesLeft
        lstOut()=Space(AddSpacesLeft)+msg$
      Else
        lstOut()=msg$
      EndIf    
    ForEver  
    
    If I<> N
      Debug "CompilerRead NoOfElements should read = " + Str(N)
      Debug "CompilerRead NoOfElements total read  = " + Str(I)
    EndIf
    
    ProcedureReturn I
  EndProcedure
  
  Procedure.i GetConstantsList(List lstOut.s())
  ; ============================================================================
  ; NAME: GetConstantsList
  ; DESC: Get the full Constant List from the Compiler
  ; DESC: Constants are in PB-Code like: #TAB=Chr(9), #CRLF=Chr(13)+Chr(10)
  ; VAR(List lstOut.s()): The list to retrieve the Compiler output  
  ; RET.i : No of Elements read
  ; ============================================================================
    Protected msg$, name$, value$, mem
    Protected *pChar.Character
    
    NewList TempList.s()
    
    CompilerWrite("CONSTANTLIST")

    Protected NbConstants$ = CompilerRead() ; Don't use this number as it was broken before 5.40. We don't need it anyway.
    ; Debug msg$
    Repeat
      msg$ = CompilerRead_NoDebug(#PB_UTF8)
      
      If msg$ = #Compiler_OutputEnd$ ; End of list: '~' indicates a literal String '\t' is replaced with #TAB  
        Break
      Else
        ; The same handling for all type (float/string/long)
        ; We don't unescape the strings, as it is only for display in the structure viewer and it's better to see '\n' then a blank char
        ;
        name$ = StringField(msg$, 2, #TAB$)
        value$ = StringField(msg$, 3, #TAB$)
        
        If Right(name$,1) = "$"
          ; unescape String
          mem = Bool(Left(value$, 1) = "\")      
          If mem
            ;value$ = UnescapeString(value$)  ; this cause Problems with doulbes like \r\n and \n\r
            value$ = ReplaceString(value$, "\r", "Chr(13)+")  
            value$ = ReplaceString(value$, "\n", "Chr(10)+") 
            If Right(value$,1) = "+"
              value$ = Left(value$, Len(value$)-1)
            EndIf
          ;EndIf  
          Else
            *pChar = @value$
            Select *pChar\c
              Case 34                       ; *** #DQUOTES ***
                value$ = "Chr(34)"
              Case 1 To 32, 127 To 160      ; *** non printable Chars ***
                mem = *pChar\c
                ;Debug msg$
                value$ = "Chr(" + Str(mem) + ")"
                Debug name$ + " : " + Str(mem) + " : " + value$
              Default
                value$ = Chr(34) + value$ + Chr(34)    ; *** Quote the Text ***
            EndSelect
            
            Select name$
              ; because there is/was a problem with TAB value detected as 0, not as 9
              Case "HT$", "TAB$" 
                value$ = "Chr(9)"
            EndSelect    
          EndIf
                                      
        EndIf
        AddElement(TempList())
        TempList() = "#" + name$ + "=" + value$
        ;Debug TempList()
      EndIf
    ForEver
     
    ForEach TempList()
      mem = FindString(TempList(), "=", 1)
      
      ; invalid entries
      If mem = 0 Or Left(TempList(), mem-1) = "#"
         
        ; Note: In the constant list, there is "#CR" and "#CR$". The $ is sorted wrong, because
        ;  we append <name>=<value> for easy sorting, and "=" > "$" in lexical order,
        ;  so the $-name sorts before the non-$ one, which is wrong (And causes problems With later item comparrison)
        ;
        ; Solution: Detect the $, replace it with a char that is > "=", but < all alpha chars,
        ;  so the sorting is correct. later undo this replace below.
        ;
;       ElseIf Mid(TempList(), mem-1, 1) = "$"
;         AddElement(lstOut())
;         lstOut() = UnescapeString(TempList())
      Else
        AddElement(lstOut())
        lstOut() = TempList()
       EndIf
    Next TempList()
    SortList(lstOut(), #PB_Sort_Ascending)
    
    ProcedureReturn ListSize(lstOut())   
  EndProcedure
 
  Procedure GetStructureList(List lstOut.s())
    If ProgramRunning(m_hCompiler)
      CompilerWrite("STRUCTURELIST")
      CompilerReadList(lstOut())
    EndIf
  EndProcedure
  
  Procedure GetProcedureList(List lstOut.s())
    If ProgramRunning(m_hCompiler)
      CompilerWrite("FUNCTIONLIST")
      CompilerReadList(lstOut())
    EndIf
  EndProcedure
  
  Procedure GetInterfaceList(List lstOut.s())
    If ProgramRunning(m_hCompiler)
      CompilerWrite("INTERFACELIST")
      CompilerReadList(lstOut())
    EndIf
  EndProcedure
  
  Procedure GetStructureInfo(struct$,List lstOut.s())
    If ProgramRunning(m_hCompiler)
      CompilerWrite("STRUCTURE"+#TAB$+struct$)
      CompilerReadList(lstOut(),4)
    EndIf
  EndProcedure
  
  Procedure GetInterfaceInfo(interf$,List lstOut.s())
    If ProgramRunning(m_hCompiler)
      CompilerWrite("INTERFACE"+#TAB$+interf$)
      CompilerReadList(lstOut(),4)
    EndIf
  EndProcedure
  
;   Procedure CompileWithDebug(compiler, code$, bProgress = 0)
;     Protected out$,prog,Output$
;     Protected temp$ = GetTemporaryDirectory()
;     Protected source$ = temp$ + "temp"
;     Protected fn = CreateFile(-1, source$ + ".pb")
;     
;     ;Print(code$) 
;     
;     If fn
;       If Not FindString(code$,"EnableExplicit") 
;         WriteStringN(fn,"EnableExplicit") 
;       EndIf   
;       WriteStringN(fn,"Calldebugger")
;       WriteString(fn, code$, #PB_UTF8)
;       CloseFile(fn)
;       SendCompilerCommand(Compiler, "SOURCE" + Chr(9) + source$ + ".pb")
;       SendCompilerCommand(Compiler, "TARGET" + Chr(9) + source$ + ".exe")
;       SendCompilerCommand(Compiler, "COMPILE" + Chr(9) + "PROGRESS" + Chr(9) + "DEBUGGER" + Chr(9) +"PURIFIER")
;       
;       While out$ <> "SUCCESS" And Left(out$, 5) <> "ERROR"
;         out$ = GetCompilerOutput(compiler)
;         
;         If out$ <> ""
;           If bProgress
;             PrintN(out$)
;           EndIf
;         EndIf
;       Wend
;       
;       If out$ = "SUCCESS"
;         RunProgram(#PB_Compiler_Home+"compilers/PBDebugger.exe", source$+".exe","")
;         RunProgram(source$ + ".pb")
;       EndIf
;       
;     EndIf
;   EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  UseModule PbComp
   
  Define  pb, msg$
  Define Folder$ = "D:\PureBasic\PbFrameWork\PB_Predefined\"
  Define res
  NewList lstConstants.s()
  NewList lstStructures.s()
  NewList lstProcedures.s()
  NewList lstInterfaces.s()
  
  NewList structureInfo.s()
  NewList interfaceInfo.s()
  
  Global log.s
  
  Debug "Start"
  
  pb = CompilerStart()
  
  If pb
    
;    res = GetConstantsList(lstConstants())
;    log + "found "+Str(ListSize(lstConstants()))+" constants"+#LF$
;    SortList(lstConstants(),#PB_Sort_Ascending|#PB_Sort_NoCase)
;    Debug "*** Constants found = " + ListSize(lstConstants())
;    Debug "res = " + res
;    Debug "------------------------------"
  
   res = GetStructureList(lstStructures())
   log + "found "+Str(ListSize(lstStructures()))+" structures"+#LF$
   Debug "------------------------------"
   Debug "*** Structures found = " + Str(ListSize(lstStructures()))
   Debug "res = " + res
   Debug "------------------------------"
;    
;    res = GetProcedureList(lstProcedures())
;    log + "found "+Str(ListSize(lstProcedures()))+" procedures"+#LF$
;    Debug log
;    Debug "*** Procedures found = " + ListSize(lstProcedures())
;    Debug "res = " + res
;    Debug "------------------------------"
;    
;    res = GetInterfaceList(lstInterfaces())
;    log + "found "+Str(ListSize(lstInterfaces()))+" interfaces"+#LF$
;    Debug "*** Interfaces found = " + ListSize(lstInterfaces())
;    Debug "res = " + res
;    Debug "------------------------------"
;    
;    ClearList(structureInfo())
;    ForEach lstStructures()
;     AddElement(structureInfo())
;     structureInfo()="Structure "+lstStructures()
;     GetStructureInfo(lstStructures(),structureInfo())
;     AddElement(structureInfo())
;     structureInfo()="EndStructure"
;     AddElement(structureInfo())
;     structureInfo()=""
;    Next
;    
;    ClearList(interfaceInfo())
;    ForEach lstInterfaces()
;     AddElement(interfaceInfo())
;     interfaceInfo()="Interface "+lstInterfaces()
;     GetInterfaceInfo(lstInterfaces(),interfaceInfo())
;     AddElement(interfaceInfo())
;     interfaceInfo()="EndInterface"
;     AddElement(interfaceInfo())
;     interfaceInfo()=""
;    Next
;    
;    If CreateFile(0,Folder$+ "pb"+#PB_Compiler_Version+" Structures.txt")
;     ForEach structureInfo()
;      WriteStringN(0,structureInfo())
;     Next
;     CloseFile(0)
;    EndIf
;    
;    If CreateFile(0,Folder$+ "pb"+#PB_Compiler_Version+" Interfaces.txt")
;     ForEach interfaceInfo()
;      WriteStringN(0,interfaceInfo())
;     Next
;     CloseFile(0)
;    EndIf
;    
;    If CreateFile(0,Folder$+ "pb"+#PB_Compiler_Version+" Constants.txt")
;     ForEach lstConstants()
;      WriteStringN(0,lstConstants())
;     Next
;     CloseFile(0)
;    EndIf
;    
;    If CreateFile(0,Folder$+ "pb"+#PB_Compiler_Version+" Procedures.txt")
;     ForEach lstProcedures()
;      WriteStringN(0,lstProcedures())
;     Next
;     CloseFile(0)
;    EndIf
;    
;    If CreateFile(0,Folder$+ "pb"+#PB_Compiler_Version+".log")
;     WriteString(0,log)
;     CloseFile(0)
;    EndIf
   
;    res = GetConstantsList(lstConstants())
;    Debug "res = " + res
;    Debug "------------------------------"
;    Define txt$
;    ForEach lstConstants()
;     txt$ = txt$ + lstConstants() + #CRLF$
;     ; txt$ = txt$ + procedures() + #CRLF$  
;    Next
;    SetClipboardText(txt$)
   
   ;GetProcedureList(lstProcedures())
   CompilerStop()
   ; MessageRequester( "GetPBInfo","Done, open the folder to view the results.")
   
 EndIf
 
CompilerEndIf
; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 132
; FirstLine = 358
; Folding = ----
; DPIAware
; CPU = 5
; Compiler = PureBasic 6.30 (Windows - x64)