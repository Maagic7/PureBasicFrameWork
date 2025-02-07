; ===========================================================================
;  FILE : BSwapVar_Macro.pbi
;  NAME : Universal BSwap Macro : BSwapVar to swap the bytes in a variable
;  DESC : does not matter which size the variable has!
;  DESC : 
;  DESC : Attention! There is a problem in C-Backend.  
;  DESC : In C-Backend we have to call BSwapVar always with variable name 
;  DESC : in lower case. If we define L.l and call BSwapVar(L) we get an error.
;  DESC : If we call  BSwapVar(l) it works!
;  DESC : The compiler LoCase all variables but in a Macro not!
;  DESC : But that's not a Bug, it's exactly how Macros works!
;  DESC : Because of that issue, BSwapVar() is a seperate .pbi file and
;  DESC : not integrated in Modul PB::
;  DESC : If you switch to C-Backend you get a compiler warning to use
;  DESC : use only LoCase varibales.
;  SOURCES: - 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2025/02/06
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;                      
;{ TODO:  Solve the LoCase var problem in C-Backend
;}
; ===========================================================================

CompilerIf #PB_Compiler_Backend = #PB_Backend_C
    
    ; there is a problem in C-Backend. In C-Backend we have to 
    ; call BSwapVar always with variable name in lower case
    ; if we define L.l and call BSwapVar(L) we get an error
    ; if we call  BSwapVar(l) it works!
    ; it looks like the compiler LoCase all variables but in a Macro not!
    CompilerWarning "Use of Macro BSwapVar(var) in C-Backend: Attention! Pass all variable names in LoCase : BSwapVar(myvar)! BSwapVar(MyVar) produce an Error!"
    
    Macro BSwapVar(var)          
      CompilerSelect SizeOf(var)
        CompilerCase 2
          !v_#var = __builtin_bswap16(v_#var);                   
        CompilerCase 4
          !v_#var = __builtin_bswap32(v_#var);                 
        CompilerCase 8 
          !v_#var = __builtin_bswap64(v_#var);
      CompilerEndSelect        
    EndMacro
  
  CompilerElse    ; ASM-Backend
    
    ; We use the EnableASM command only to load and save the variable
    ; because if we pass directly the 'MOV EAX, var' we have to add v_ for standard code
    ; or p.v_ for variables in a procedure. With the PB buildin ASM it is done by PB.
    Macro BSwapVar(var)
      EnableASM   
      CompilerSelect SizeOf(var)
        CompilerCase 2         
          !XOR EAX, EAX
          MOV AX, var
          !XCHG AL, AH
          MOV var, AX         
  
        CompilerCase 4          
          MOV EAX, var
          !BSWAP EAX
          MOV var, EAX          
                
        CompilerCase 8  ; Quad
          
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x64           
            MOV RAX, var
            !BSWAP RAX
            MOV var, RAX
                     
          CompilerElse   ; ASM x32         
            LEA ECX, var   ; load effective address of var : ECX= @var
            !MOV EDX, DWORD [ECX]
            !MOV EAX, DWORD [ECX +4]
            !BSWAP EDX
            !BSWAP EAX
            !MOV DWORD [ECX], EAX
            !MOV DWORD [ECX +4], EDX 
                        
          CompilerEndIf    
            
      CompilerEndSelect
      DisableASM
    EndMacro
    
  CompilerEndIf
; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 58
; FirstLine = 10
; Folding = -
; Optimizer
; CPU = 5