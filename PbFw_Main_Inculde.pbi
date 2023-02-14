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


; Module for Buffer handling  
; XIncludeFile "Modules\PbFw_Module_BUFFER.pb"        ; Buffer::
; 
; ; Module for Clima and Thermo Dynamic calculations   
; XIncludeFile "Modules\PbFw_Module_CLIMA.pb"         ; Clima::
; 
; ; Module for Color handling: RGB, HSV   
; XIncludeFile "Modules\PbFw_Module_COLOR.pb"         ; Color::
; 
; ; Module for CSV File and Data handling   
; XIncludeFile "Modules\PbFw_Module_CSV.pb"           ; CSV::
; 
; ; Exception handler
; XIncludeFile "Modules\Module_Exception.pb"          ; Exception::
; 
; ; Module for File System Functions
; XIncludeFile "Modules\PbFw_Module_FileSystem.pb"    ; FS::
; 
; ;Numeric String Functions 
; XIncludeFile "Modules\PbFw_Module_IsNumeric.pb"     ; IsNum::
; 
; ;Mathematic Functions Library
; XIncludeFile "Modules\PbFw_Module_Math.pb"          ; Math::
; 
; ;Functions using the Multi-Media-Extentions
; ; MMX, SSE
; XIncludeFile "Modules\PbFw_Module_MMX.pb"           ; MMX::

; Because of new DPI scaling in PB6.00, the Function ToolbarStandardButton
; does not longer exist. The Problem is the OS integrated images for the
; ToolBarStandarButtons (open, save, print ...) are in a to lo quality for
; DPI scaling. Now higher resolution images are shipped with Purebasic 6.
; But this Images must be integrated manually. This Module from the PB
; Forum simulates the old ToolBarStandardButton Command
XIncludeFile "Modules\PbFw_Module_MyToolBarStandard.pb"

; Module for Roman numerals
XIncludeFile "Modules\PbFw_Module_Roman.pb"         ; ROM::

; Module for 3D STL Files
XIncludeFile "Modules\PbFw_Module_STL.pb"           ; STL::

; Module for 3D STP Files
XIncludeFile "Modules\PbFw_Module_STEP3D.pb"        ; STEP3D::

; Module for String handling
XIncludeFile "Modules\PbFw_Module_STRING.pb"        ; STR::

; PureBasic Sytem Functions by MK-SOFT; 
; it's a kind of PureBasic Extention
XIncludeFile "Modules\PbFw_Module_System.pb"        ; System::

; Thread Control Module
XIncludeFile "Modules\PbFw_Module_Thread.pb"        ; Thread::


; This module provides the capsuled VectorDrawing commands
; It handels the drawing on the Screen (and Printer)
XIncludeFile "Modules\PbFw_Module_VDraw.pb"  

;- ----------------------------------------------------------------------
;-   I N C L U D E   F I L E S  F O R   O O P
;  ----------------------------------------------------------------------


;- ----------------------------------------------------------------------
;-   I N C L U D E   F I L E S  F O R   G A D G E T S
;  ----------------------------------------------------------------------

; XIncludeFile ""    ; 


; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 66
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)