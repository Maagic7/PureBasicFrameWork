
; CPU_Main.pb

IncludeFile "..\..\Modules\PbFw_Module_CPU.pb"         ; CPU::     CPUl Module


Define f1.f

f1 = CPU::CPU_Mhz(10)
Debug "F = " + StrF(f1)

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 8
; DPIAware
; CPU = 5