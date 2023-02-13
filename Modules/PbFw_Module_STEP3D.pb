; ===========================================================================
;  FILE : Module_STEP3D.pb
;  NAME : Module STEP3D STEP3d::
;  DESC : Implements 3D STEP File Import 
;  DESC : Supports STEP Files according to ISO-10303 
;  DESC : STEP-Format is a 3D Solid Format used by the most 3D CAD
;  DESC : Systems
;  DESC : STEP is much harder to implement as STL, for STEP 
;  DESC : implementation to original documentation of STEP is necessary
;  DESC : The STEP documentaion is not an open source document.
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/10
; VERSION  :  0.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;{
;}
; ============================================================================

;{ ====================      M I T   L I C E N S E        ====================
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

; OGRE Physik Engine STEP-FILE Importer

; https://assimp.sourceforge.net/main_downloads.html
; https://www.purebasic.fr/english/viewtopic.php?p=401729#p401729
;}

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

  XIncludeFile "Module_BUFFER.pb"  ; Module for Buffer handling
  XIncludeFile "Module_STRING.pb"  ; Module for extended String handling

  DeclareModule STEP3D
    
  ; Header represents the Data stored in the header section of a Step file:
  ; fileDescription should be an informal description of the contents of the file.
  ; fileName may be the file name of the actual file, Or it may be an abstract name For the contents of the file used when cross-referencing between files
  ; timeStamp should be an ISO 8601-formatted date And time
  ; author should include the name And address of the person who created the file
  ; organization should be the organization that the author is associated with.
  ; One of preprocessorVersion or originatingSystem should identify what CAD program was used to generate the file. This does not seem to be used terribly consistently
  ; authorization should include the name and address of whoever authorized sending the file
  ; schemaIdentifiers identifies the EXPRESS schema used by entities in the file.
  ;  - This will usually be a list containing a single string, which may be either a simple string like "IFC2X3" or an 'object identifier' such as "AUTOMOTIVE_DESIGN { 1 0 10303 214 1 1 1 1 }" (more commonly known as AP214
    
  Structure STEP_Header
    fileDescription : List String
    fileName : String
    timeStamp : String
    author : List String
    organization : List String
    preprocessorVersion : String
    originatingSystem : String
    authorization : String
    schemaIdentifiers : List String
  EndStructure
  
  Enumeration STEP_AttributeType
    #attDefault     ; The special 'default value' attribute (* in the resulting STEP file)
    #attNull        ; The special 'null value' attribute ($ in the resulting STEP file)
    #attINT         ; Construct an integer-valued attribute
    #attFLOAT       ; Construct a real-valued attribute
    #attSTRING      ; Construct a string-valued attribute
    #attReference   ; Construct a reference to another STEP entity (will end up being encoded using an integer ID in the resulting STEP file, e.g. #123)
    #attENUM        ; onstruct an attribute that refers to an enumeration value defined in an EXPRESS schema. Enumeration values are always encoded as all-caps with leading and trailing periods, like .STEEL.
    #attBINARY      ; Construct a binary-valued attribute. The provided string is assumed to already be hex encoded as required by the STEP standard
    #attLIST        ; Construct an attribute which is itself a list of other attribute
  EndEnumeration
  
  Enumeration TopolgieEntities
    #vertices
    #edges
    #loops
    #faces
    #shells
    #solids 
  EndEnumeration
  
  Enumeration Geomentry
    #points
    #vector
    #direction
    #curve
    #surface
    #triangulation
  EndEnumeration
  
  Enumeration STEP_PPOINTS
    #circle 	
    #ellipse 	
    #hyperbola 	
    #line 	
    #parabola 	 	
    #pcurve 	
    #curve_replica 	
    #offset_curve_3d 	
    #trimmed_curve 	
    #b_spline_curve 
    #b_spline_curve_with_knots 	
    #bezier_curve 	
    #rational_b_spline_curve 	
    #uniform_curve 	
    #quasi_ uniform_curve 	
    #surface_curve 	
    #seam_curve 	
    #composite_curve_segment 	
    #composite_curve 	
    #composite_curve_on_surface 
    #boundary_curve 
  EndEnumeration
  
  Enumeration Surface
    #b_spline_surface
    #b_spline_surface_with_knots
    #bezier_surface
    #conical_surface
    #cylindrical_surface
    #offset_surface
    #surface_replica
    #plane
    #rational_b_spline_surface
    #rectangular_trimmed_surface
    #spherical_surface
    #surface_of_linear_extrusion
    #surface_of_revolution
    #toroidal_surface
    #degenerate_toroidal_surface
    #uniform_surface
    #quasi_uniform_surface
    #rectangular_composite_surface
    #curve_bounded_surface
  EndEnumeration
  
;ISO 10303-11 explains the EXPRESS schema, which is the language used To articulate abstract structures And relationships within ISO 10303.

;ISO 10303-21 explains the concrete format of a Step file. Or rather, how you get from the EXPRESS schema To the file format.

;ISO 10303-42 has all the math of curves, surfaces, etc, all expressed in the EXPRESS schema language.
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
  
  IncludeFile PbFw_Module_STEP3D_KeyWords.pb  
EndModule

CompilerIf #PB_Compiler_IsMainFile
  
  ; Testcode
  
CompilerEndIf

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 4
; Folding = --
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)