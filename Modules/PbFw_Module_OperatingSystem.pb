; ===========================================================================
;  FILE: PbFw_Module_OperatingSystem.pb
;  NAME: Module OperatingSystem OS::
;  DESC: 
;  DESC: 
;  DESC: 
;  DESC: 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/08/20
; VERSION  :  0.1 Brainstorming Version
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

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule OS
  EnableExplicit
  
  Macro PathSeperator()
    #PS$  
  EndMacro
  
  Declare.s GetOsVersionString()
  
EndDeclareModule

Module OS
  EnableExplicit
  
  Procedure.s GetOsVersionString()   
  ; ============================================================================
  ; NAME: GetOsVersionString
  ; DESC: Returns a String with the OS Version
  ; DESC: for all OS and PB Compiler Version > 500
  ; RET.s: String with OS-Version
  ; ============================================================================
    
    Protected Os$, OsNewer$
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; ----------------------------------------------------------------------        
    ;   W I N D O W S
    ; ----------------------------------------------------------------------        
      
      ; if on older compilers the constant for the OS is undefined
      
      CompilerIf Not Defined(PB_OS_Windows_10,#PB_Constant)
     	  #PB_OS_Windows_10 = 110
     	  #_OsNewer = #True
        OsNewer$ ="Windows 10 or newer"   
    	CompilerEndIf    	
    	    	
    	CompilerIf Not Defined(PB_OS_Windows_11,#PB_Constant)
    	  #PB_OS_Windows_11 = 120
    	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	  #_OsNewer = #True
   	      OsNewer$ ="Windows 11 or newer" 
    	  CompilerEndIf 
    	CompilerEndIf
    	
   	  CompilerIf Not Defined(PB_OS_Windows_12,#PB_Constant)
    	  #PB_OS_Windows_12 = 130
     	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	  #_OsNewer = #True
   	      OsNewer$ ="Windows 12 or newer" 
    	  CompilerEndIf 
    	CompilerEndIf
    	
   	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
        #_OsNewer = #True
   	    OsNewer$ ="Windows 12 or newer" 
  	  CompilerEndIf 

      Select OSVersion()
    		Case #PB_OS_Windows_NT3_51          : Os$="Windows NT 3.5"
    		Case #PB_OS_Windows_95              : Os$="Windows 95"
    		Case #PB_OS_Windows_NT_4            : Os$="Windows NT 4"
    		Case #PB_OS_Windows_98              : Os$="Windows 98"
    		Case #PB_OS_Windows_ME              : Os$="Windows ME"
    		Case #PB_OS_Windows_2000            : Os$="Windows 2000"
    		Case #PB_OS_Windows_XP              : Os$="Windows XP"
    		Case #PB_OS_Windows_Server_2003     : Os$="Windows Sever 2003"
    		Case #PB_OS_Windows_Vista           : Os$="Windows Vista"
    		Case #PB_OS_Windows_Server_2008     : Os$="Windows Server 2008"
    		Case #PB_OS_Windows_7               : Os$="Windows 7"
    		Case #PB_OS_Windows_Server_2008_R2  : Os$="Windows Server 2008 R2"
    		Case #PB_OS_Windows_8               : Os$="Windows 8"
    		Case #PB_OS_Windows_Server_2012     : Os$="Windows Server 2012"
    		Case #PB_OS_Windows_8_1             : Os$="Windows 8.1"
    		Case #PB_OS_Windows_Server_2012_R2  : Os$="Windows Server 2012 R2"
    		Case #PB_OS_Windows_10              : Os$="Windows 10"   		  
   			Case #PB_OS_Windows_11              : Os$="Windows 11"
   			Case #PB_OS_Windows_12              : Os$="Windows 12"
        Case #PB_OS_Windows_Future  : Os$ = OsNewer$
    	  
    	  Default 
    	    Os$="unkown Windows"
    	    
    	CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux   
      ; ----------------------------------------------------------------------        
      ;   L I N U X
      ; ----------------------------------------------------------------------        
    	  
    	  Select OSVersion()
    	    Case #PB_OS_Linux_2_2     : Os$="Linux 2-2"
    	    Case #PB_OS_Linux_2_4     : Os$="Linux 2-4"
    	    Case #PB_OS_Linux_2_6     : Os$="Linux 2-6"      
    	    Case #PB_OS_Linux_Future  : Os$="Linux 2-8 or newer"
    	    Default : Os$="unknown Linux"
    	  EndSelect
        
    	CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS   
      ; ----------------------------------------------------------------------        
      ;   M A C   O S
      ; ----------------------------------------------------------------------        
    	  
    	  ; if on older compilers the constant for the OS is undefined
   	     	  
    	  CompilerIf Not Defined(PB_OS_MacOSX_10_13,#PB_Constant)
    	    #PB_OS_MacOSX_10_13 = 10130
     	    CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	    #_OsNewer = #True
            OsNewer$ ="Mac OS 10.13 or newer"
    	    CompilerEndIf 
    	  CompilerEndIf    	       	     	  
    	     	    
   	    CompilerIf Not Defined(PB_OS_MacOSX_10_14,#PB_Constant)
    	    #PB_OS_MacOSX_10_14 = 10140
     	    CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	    #_OsNewer = #True
            OsNewer$ ="Mac OS 10.14 or newer"
    	    CompilerEndIf 
    	  CompilerEndIf   	  
    	    	  
    	  CompilerIf Not Defined(PB_OS_MacOSX_10_15,#PB_Constant)
    	    #PB_OS_MacOSX_10_15 = 10150
      	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	    #_OsNewer = #True
            OsNewer$ ="Mac OS 10.15 or newer"
    	    CompilerEndIf 
   	    CompilerEndIf  	  
    	  
    	  CompilerIf Not Defined(PB_OS_MacOSX_11,#PB_Constant)
    	    #PB_OS_MacOSX_11 = 11000
      	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	    #_OsNewer = #True
            OsNewer$ ="Mac OS 11 or newer"
    	    CompilerEndIf 
    	  CompilerEndIf  	  
    	  
    	  CompilerIf Not Defined(PB_OS_MacOSX_12,#PB_Constant)
    	    #PB_OS_MacOSX_12 = 12000
      	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	    #_OsNewer = #True
            OsNewer$ ="Mac OS 12 or newer"
    	    CompilerEndIf 
   	    CompilerEndIf 	  
    	  
    	  CompilerIf Not Defined(PB_OS_MacOSX_13,#PB_Constant)
    	    #PB_OS_MacOSX_13 = 13000
       	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	    #_OsNewer = #True
            OsNewer$ ="Mac OS 13 or newer"
    	    CompilerEndIf 
    	  CompilerEndIf
   	  
    	  CompilerIf Not Defined(PB_OS_MacOSX_14,#PB_Constant)
    	    #PB_OS_MacOSX_14 = 14000
      	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	    #_OsNewer = #True
            OsNewer$ ="Mac OS 14 or newer"
    	    CompilerEndIf 
   	    CompilerEndIf
    	  
    	  CompilerIf Not Defined(PB_OS_MacOSX_15,#PB_Constant)
    	    #PB_OS_MacOSX_15 = 15000
          OsNewer$ ="Mac OS 15 or newer"
   	    CompilerEndIf
   	  
    	  CompilerIf Not Defined(PB_OS_MacOSX_16,#PB_Constant)
    	    #PB_OS_MacOSX_16 = 16000
      	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
      	    #_OsNewer = #True
            OsNewer$ ="Mac OS 16 or newer"
    	    CompilerEndIf 
   	    CompilerEndIf
    	  
    	  CompilerIf Not Defined(_OsNewer,#PB_Constant)
          #_OsNewer = #True
    	    OsNewer$ ="Mac OS 16 or newer"
  	    CompilerEndIf 
   	  
    	  Select OSVersion()
          Case #PB_OS_MacOSX_10_0   : Os$="Mac OSX 10.0 - Cheetah"          
          Case #PB_OS_MacOSX_10_1   : Os$="Mac OSX 10.1 - Puma"         
          Case #PB_OS_MacOSX_10_2   : Os$="Mac OSX 10.2 - Jaguar"          
          Case #PB_OS_MacOSX_10_3   : Os$="Mac OSX 10.3 - Panther"          
          Case #PB_OS_MacOSX_10_4   : Os$="Mac OSX 10.4 - Tiger"          
          Case #PB_OS_MacOSX_10_5   : Os$="Mac OSX 10.5 - Leopard"           
          Case #PB_OS_MacOSX_10_6   : Os$="Mac OSX 10.6 - Snow Leopard"           
          Case #PB_OS_MacOSX_10_7   : Os$="Mac OSX 10.7 - Lion"          
          Case #PB_OS_MacOSX_10_8   : Os$="Mac OSX 10.8 - Mountain Lion"            
          Case #PB_OS_MacOSX_10_9   : Os$="Mac OSX 10.9 - Mavericks"          
          Case #PB_OS_MacOSX_10_10  : Os$="Mac OSX 10.10 - Yosemite"           
          Case #PB_OS_MacOSX_10_11  : Os$="Mac OSX 10.11 - El Capitan"          
          Case #PB_OS_MacOSX_10_12  : Os$="Mac OSX 10.12 - Sierra             
          Case #PB_OS_MacOSX_10_13  : Os$="Mac OSX 10.13 - High Sierra"           
          Case #PB_OS_MacOSX_10_14  : Os$="Mac OSX 10.14 - Mojave"            
          Case #PB_OS_MacOSX_10_15  : Os$="Mac OSX 10.15 - Catalina"            
          Case #PB_OS_MacOSX_11     : Os$="Mac OSX 11 - Big Sur"       
          Case #PB_OS_MacOSX_12     : Os$="Mac OSX 12 - Monterey"
          Case #PB_OS_MacOSX_13     : Os$="Mac OSX 13 - Ventura"
          Case #PB_OS_MacOSX_14     : Os$="Mac OSX 14 - Sonoma"
          Case #PB_OS_MacOSX_15     : Os$="Mac OSX 15 - Sequoia"
          Case #PB_OS_MacOSX_16     : Os$="Mac OSX 16 - "
          
          Case #PB_OS_MacOSX_Future : Os$=OsNewer$
     	    Default : Os$ = "unknown Mac OS" 	      
        EndSelect
  	      	  
    	CompilerEndIf
    	
    EndSelect
       
  	ProcedureReturn Os$
  	
  EndProcedure
  
EndModule

         
Debug OS::GetOsVersionString()
; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 62
; FirstLine = 33
; Folding = ------
; Optimizer
; CPU = 5