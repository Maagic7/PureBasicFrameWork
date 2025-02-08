; ======================================================================
;  FILE  : PbFw_Main_Include.pb 
;  NAME  : Purebasic Framework Main Include File
;  DESC  : Includes all Files of the Purebasic Framwwork
;        
;  AUTHOR :  Stefan Maag
;  VERSION:  0.1
;  DATE   :  2022/12/05
; ======================================================================
;
;
; ======================================================================
; ChangeLog
;
; ======================================================================


;- ----------------------------------------------------------------------
;-   I N C L U D E   M O D U L E S
;- ----------------------------------------------------------------------



; Module for Bit Operations  
XIncludeFile "Modules\PbFw_Module_Bit.pb"             ; BIT::

; Module for Buffer handling  
XIncludeFile "Modules\PbFw_Module_Buffer.pb"          ; BUF::


; ; Module for Clima and Thermo Dynamic calculations   
; XIncludeFile "Modules\PbFw_Module_CLIMA.pb"         ; Clima::

; Code creation Module
XIncludeFile "Modules\PbFw_Module_CodeCreation.pb"    ; CC::

; Module for Color handling: RGB, HSV   
XIncludeFile "Modules\PbFw_Module_COLOR.pb"           ; Color::

; Module for Complex numbers
XIncludeFile "Modules\PbFw_Module_Complex.pb"         ; Complex::

; Module for CPU Informations
XIncludeFile "Modules\PbFw_Module_CPU.pb"             ; CPU::

; Purebasic Command extention Module
XIncludeFile "Modules\PbFw_Module_PB.pb"              ; PB::

; FrameWork Control Module
XIncludeFile "Modules\PbFw_Module_PbFw.pb"            ; PbFw::

; ; Module for CSV File and Data handling   
XIncludeFile "Modules\PbFw_Module_CSV.pb"             ; CSV::

; Code creation Module for DataBase Code
XIncludeFile "Modules\PbFw_Module_DbCodeCreation.pb"  ; DBCC::

; Debugging And Exception Handler Module
XIncludeFile "Modules\PbFw_Module_Debug.pb"           ; DBG::

; Module for fast String handling
XIncludeFile "Modules\PbFw_Module_FastString.pb"      ; FStr::

; Module for File System Functions
XIncludeFile "Modules\PbFw_Module_FileSystem.pb"      ; FS::

; Module for extented float functions
XIncludeFile "Modules\PbFw_Module_Float.pb"           ; Float::

; Module for 3D IGES Files
;XIncludeFile "Modules\PbFw_Module_IGES.pb"           ; IGES::

;Numeric String Functions 
XIncludeFile "Modules\PbFw_Module_IsNumeric.pb"       ; IsNum::

;Mathematic Functions Library
XIncludeFile "Modules\PbFw_Module_Math.pb"            ; Math::

; Operating System Module
XIncludeFile "Modules\PbFw_Module_OperatingSystem.pb" ; OS::

; Module for 3D STP Files
;XIncludeFile "Modules\PbFw_Module_STEP3D.pb"         ; STEP3D::

; Module for 3D STL Files
XIncludeFile "Modules\PbFw_Module_STL.pb"             ; STL::

; Module for String handling
XIncludeFile "Modules\PbFw_Module_STRING.pb"          ; STR::

; PureBasic Sytem Functions by MK-SOFT; 
; it's a kind of PureBasic Extention
XIncludeFile "Modules\PbFw_Module_PBSystem.pb"        ; PBS::

; Module for Roman numerals
XIncludeFile "Modules\PbFw_Module_Roman.pb"           ; ROM::

; Thread Control Module
; XIncludeFile "Modules\PbFw_Module_Thread.pb"        ; Thread::

; Trigonometric Functions in single precision
XIncludeFile "Modules\PbFw_Module_TRIGf.pb"           ; TRIGf::

; This module provides the capsuled VectorDrawing commands
; It handels the drawing on the Screen (and Printer)
XIncludeFile "Modules\PbFw_Module_VDraw.pb"           ; VDraw::

; Modul For Color handling As packed Float            
XIncludeFile "Modules\PbFw_Module_VectorColor.pb"     ; VecCol::

; Module for 4D Vector functions
; single precision VECf::
XIncludeFile "Modules\PbFw_Module_Vectorf.pb"         ; VECf::
; double precision VECd::
XIncludeFile "Modules\PbFw_Module_Vectord.pb"         ; VECd::


;- ----------------------------------------------------------------------
;-   I N C L U D E   F I L E S  F O R   O O P
;  ----------------------------------------------------------------------


;- ----------------------------------------------------------------------
;-   I N C L U D E   F I L E S  F O R   G A D G E T S
;  ----------------------------------------------------------------------

; Because of new DPI scaling in PB6.00, the Function ToolbarStandardButton
; does not longer exist. The Problem is the OS integrated images for the
; ToolBarStandarButtons (open, save, print ...) are in a to lo quality for
; DPI scaling. Now higher resolution images are shipped with Purebasic 6.
; But this Images must be integrated manually. This Module from the PB
; Forum simulates the old ToolBarStandardButton Command
XIncludeFile "Modules\PbFw_Module_MyToolBarStandard.pb"


; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 37
; FirstLine = 20
; Optimizer
; CPU = 5