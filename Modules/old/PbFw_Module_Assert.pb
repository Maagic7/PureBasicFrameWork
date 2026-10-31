;// ********************************************************************************
;// PbFw_Moule_Assert.pb
;// An ASSERT macro on steroids.
;// by Luis, PB 5.10
;// > slightly changed by Little John for usage with modules (PB 5.20+)
;//
;// Use #PB_Editor_WordWrap (PB 5.10) instead of API, and a bigger font size for OSX
;//
;// forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=50842
;// ********************************************************************************


; if #ASSERT_ENABLED is not defined in your main program, automagically defaults to #ASSERT_ENABLED = 0
CompilerIf Not Defined(ASSERT_ENABLED, #PB_Constant) ; = 0
   #ASSERT_ENABLED = 0
CompilerEndIf


CompilerIf #ASSERT_ENABLED
  
  EnableExplicit
  
  DeclareModule Assert
    #ASSERT_TITLE$ = "ASSERT"
    
    Global NewMap AssertFlags.i()
    
    Macro _ASSERT_DQ_
       "
    EndMacro
    
    Declare.i AssertProcedure (Exp$, File$, Proc$, iLine, Msg$)
    
    
    ; [DESC]
    ; Check the validity of the expression and if not true stops the execution showing a warning window.
    ;
    ; [INPUT]
    ; exp : The expression to be checked.
    ; msg: An optional message to show if the assert fails.
    ;
    ; [NOTES]
    ; Asserts can be used both in the debugged program and the final exe, and are inserted in the code only if #ASSERT_ENABLED = 1
    ;
    ; If a check fails the user has three options:
    ; - continue
    ; - continue skipping further notifications by this specific assert
    ; - stop the program at the offending line through a call to CallDebugger() or End it if the debugger is disabled.
    ;
    ; You can't use string literals in the expression to be evaluated, shouldn't be a problem in practice.
    ; You can't use more than one ASSERT for each line.

    Macro ASSERT (exp, msg = "")       
       If Not (exp)
          If AssertProcedure (_ASSERT_DQ_#exp#_ASSERT_DQ_, #PB_Compiler_File, #PB_Compiler_Procedure, #PB_Compiler_Line, msg)
             CallDebugger
          EndIf
       EndIf
    EndMacro
  EndDeclareModule
   
   
   Module Assert
     
    EnableExplicit
     
    Procedure.i AssertProcedure (Exp$, File$, Proc$, iLine, Msg$)
       ; This is called when Exp$ is false (see ASSERT macro)
       
       Protected Text$, StopText$, Title$
       Protected iRetCode, iEvent, nWin
       Protected nBtnContinue, nBtnSkipAsserts, nBtnStop, nEditor, nLabel
       Protected nFontEdit, nFontTitle, flgExit
       Protected w = 400, h = 240
       
       iRetCode = 0
       
       If FindMapElement(AssertFlags(), File$ + "_" + Str(iLine)) = 0
          ; This is better than
          ; If AssertFlags(File$ + "_" + Str(iLine)) = 0
          ; because it does not allocate data if an ASSERT has not been disabled.
          
          Title$ = #ASSERT_TITLE$
          
          CompilerIf #PB_Compiler_Debugger = 1
             StopText$ = " Call Debugger "
             Title$ + " (debug)"
          CompilerElse
             StopText$ = " End "
          CompilerEndIf
          
          If Proc$ : Proc$ + "()" : EndIf
          
          nWin = OpenWindow(#PB_Any, 0, 0, w, h, Title$, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
          
          If nWin
             StickyWindow(nWin, 1)
             
             nFontTitle = LoadFont(#PB_Any, "Arial", 16, #PB_Font_Bold)
             
             CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
                nFontEdit = LoadFont(#PB_Any, "Courier New", 12) ; suggested by WilliamL
             CompilerElse
                nFontEdit = LoadFont(#PB_Any, "Courier New", 9)   
             CompilerEndIf                 
             
             nLabel= TextGadget(#PB_Any, 10, 8, w-20, 20, "ASSERT FAILED !", #PB_Text_Center)
             
             nEditor = EditorGadget(#PB_Any, 10, 40, w-20, 155, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
             nBtnContinue = ButtonGadget(#PB_Any, 10, h-35, 120, 30, " Continue ")
             nBtnSkipAsserts = ButtonGadget(#PB_Any, 140, h-35, 120, 30, " Disable this ASSERT ")
             nBtnStop = ButtonGadget(#PB_Any, 270, h-35, 120, 30, StopText$, #PB_Button_Default)
             
             
             Text$ = "Expr: " + Exp$ + #LF$ + #LF$
             Text$ + "File: " + GetFilePart(File$) + #LF$ +#LF$         
             Text$ + "Proc: " + Proc$ + #LF$ + #LF$ 
             Text$ + "Line: " + Str(iLine)   
             
             If Msg$
                Text$ + #LF$ + #LF$ + Msg$
             EndIf
             
             SetGadgetFont(nLabel, FontID(nFontTitle))
             SetGadgetFont(nEditor, FontID(nFontEdit))
             SetGadgetText(nEditor, Text$)
             
             Repeat
                iEvent = WaitWindowEvent()
                
                Select iEvent
                   Case #PB_Event_CloseWindow
                      iRetCode = 0
                      flgExit = 1               
                   Case #PB_Event_Gadget
                      Select EventGadget()
                         Case nBtnContinue
                            iRetCode = 0
                            flgExit = 1
                         Case nBtnSkipAsserts
                            AssertFlags(File$ + "_" + Str(iLine)) = 1
                            iRetCode = 0
                            flgExit = 1
                         Case nBtnStop
                            CompilerIf #PB_Compiler_Debugger = 1
                               iRetCode = 1
                               flgExit = 1
                            CompilerElse
                               End
                            CompilerEndIf                                           
                      EndSelect
                EndSelect       
             Until flgExit = 1
             
             CloseWindow(nWin)
             
             FreeFont(nFontTitle)
             FreeFont(nFontEdit)       
          EndIf         
       EndIf
       
       ProcedureReturn iRetCode
    EndProcedure
  EndModule
   
CompilerElse
   
   DeclareModule Assert
      Macro ASSERT (exp, msg = "")
      EndMacro
   EndDeclareModule
   
   Module Assert
   EndModule
 CompilerEndIf
 

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 56
; Folding = ---
; Optimizer
; CPU = 5