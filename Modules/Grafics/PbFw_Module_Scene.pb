; ===========================================================================
;  FILE: PbFw_Module_Scene.pb
;  NAME: 3D-Scene functions
;  DESC: Implements functions for 3D scene drawing
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/02/18
; VERSION  :  0.0  Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
; 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "..\PbFw_Module_PbFw.pb"          ; PbFw::     FrameWork control Module
XIncludeFile "..\PbFw_Module_Debug.pb"         ; DBG::      Debug Module
XIncludeFile "..\Grafics\PbFw_Module_VECTORf.pb"       ; VECf::     Single presicion Vector Module
XIncludeFile "PbFw_Module_VectorColor.pb"   ; VecCol::   Vector Color Module

DeclareModule Scene
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  UseModule VECf
   
  Structure TLight
	  DirVec.TVector                ; Direction/Normal-Vector
	  VecCol.VecCol::TVectorColor   ; Color as VectorColor (packed float Color format)
  EndStructure

  Structure TScene3D
    Orientation.TMatrix     ; Orientation of the scene
    CmaeraPos.TVector       ; Camera position
    Distance.f              ;
    Size.TVector            ; Vector with the SceneSize (Width=X and Height=X)
    Center.TVector          ; Vector with the SceneCenterPoit
    List Light.TLight()     ; List with all lights   
  EndStructure
  
EndDeclareModule

Module Scene
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)

  ;- ----------------------------------------------------------------------
  ;- Module Private
  ;- ----------------------------------------------------------------------
  
  
EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 27
; Folding = -
; Optimizer
; CPU = 5