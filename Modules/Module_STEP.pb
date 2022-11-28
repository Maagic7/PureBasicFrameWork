; ===========================================================================
;  FILE : Module_STEP3D.pb
;  NAME : Module STEP3D
;  DESC : Implements 3D STEP File Import 
;  DESC : Supports STEP Files according to ISO-1303-21 
;  DESC : STEP-Format is a 3D Solid Format used by the most 3D CAD
;  DESC : Systems
;  DESC : STEP is much harder to implement as STL, for STEP 
;  DESC : implementation to original documentation of STEP is necessary
;  DESC : The STEP documentaion is not an open source document.
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/10
; VERSION  :  1.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;{
;}
; ============================================================================

;{ ====================      M I T   L I C E N S E        ====================
;
; Copyright (c) 2022 Stefan Maag
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ============================================================================
;

;{ ==========     S T E P   F I L E   F O R M A T   B A S I C S      ==========

; ----------------------------------------------------------------------
;    STEP Format basics
; ----------------------------------------------------------------------

;}

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

  XIncludeFile "Module_BUFFER.pb"  ; Module for Buffer handling
  XIncludeFile "Module_STRING.pb"  ; Module for extended String handling

DeclareModule STEP3D
  
EndDeclareModule


Module STEP3D
  
  EnableExplicit  
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
  
   Procedure.i LoadSTEP(FileName.s, *Solid.TSolid)
  ; ============================================================================
  ; NAME: LoadSTEP
  ; DESC: Load a STEP-File
  ; DESC: 
  ; DESC: 
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(*Solid.TSolid) : Pointer of your TSolid Structure which receive the STL-Object
  ; RET.i : FileFormat 
  ; ============================================================================
    
    Protected hBUF.BUFFER::TBuffer    ; Buffer Handle Structure (Module BUFFER)
    
    ProcedureReturn #True
  EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
  
  ; Testcode
  
CompilerEndIf

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 81
; Folding = --
; Compiler = PureBasic 6.00 LTS (Windows - x86)