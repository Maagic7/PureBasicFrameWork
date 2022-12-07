; ===========================================================================
;  FILE : Module_FileSystem.pb
;  NAME : Module FileSystem [FS::]
;  DESC : File-System Functions 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/15
; VERSION  :  0.1
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog: 
;{
;}
; ===========================================================================

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

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile ""

DeclareModule FS
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------

  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; ------------------------------------------------------------
    ;  Windows Attributes
    ; -----------------------------------------------------------  
    ; #PB_FileSystem_Archive    ; 32
    ; #PB_FileSystem_Hidden     ; 2
    ; #PB_FileSystem_Compressed ; 2048 
    ; #PB_FileSystem_Normal     ; 128
    ; #PB_FileSystem_ReadOnly   ; 1
    ; #PB_FileSystem_System     ; 4
  
    #FS_Files_All = #PB_FileSystem_Archive|#PB_FileSystem_Hidden|#PB_FileSystem_Compressed|#PB_FileSystem_Normal|#PB_FileSystem_ReadOnly|#PB_FileSystem_System 
  
    #FS_Files_Only_Archive     = #PB_FileSystem_Archive
    #FS_Files_Only_Hidden      = #PB_FileSystem_Hidden
    #FS_Files_Only_Compressed  = #PB_FileSystem_Compressed 
    #FS_Files_Only_Normal      = #PB_FileSystem_Normal
    #FS_Files_Only_ReadOnly    = #PB_FileSystem_ReadOnly
    #FS_Files_Only_System      = #PB_FileSystem_System
    
    #FS_Files_Ignore_Archive   = #FS_Files_All & ~#PB_FileSystem_Archive
    #FS_Files_Ignore_Hidden    = #FS_Files_All & ~#PB_FileSystem_Hidden
    #FS_Files_Ignore_Compressed= #FS_Files_All & ~#PB_FileSystem_Compressed
    #FS_Files_Ignore_Normal    = #FS_Files_All & ~#PB_FileSystem_Normal
    #FS_Files_Ignore_ReadOnly  = #FS_Files_All & ~#PB_FileSystem_ReadOnly
    #FS_Files_Ignore_System    = #FS_Files_All & ~#PB_FileSystem_System
    #FS_Files_Ignore_HiddenAndSystem = #FS_Files_All & ~#PB_FileSystem_Hidden & ~#PB_FileSystem_System
    
  CompilerElse
    ; ------------------------------------------------------------
    ;  Linux, MAC
    ; ------------------------------------------------------------   
    ;  #PB_FileSystem_Link
    ;  #PB_FileSystem_ReadUser
    ;  #PB_FileSystem_WriteUser
    ;  #PB_FileSystem_ExecUser
    ;  #PB_FileSystem_ReadGroup
    ;  #PB_FileSystem_WriteGroup
    ;  #PB_FileSystem_ExecGroup
    ;  #PB_FileSystem_ReadAll
    ;  #PB_FileSystem_WriteAll
    ;  #PB_FileSystem_ExecAll
    
    #FS_Files_All = #PB_FileSystem_Link|#PB_FileSystem_ReadUser|#PB_FileSystem_WriteUser|#PB_FileSystem_ExecUser|#PB_FileSystem_ReadGroup|#PB_FileSystem_WriteGroup|#PB_FileSystem_ReadAll|#PB_FileSystem_WriteAll|#PB_FileSystem_ExecAll
    
    #PB_Files_Only_Link       = #PB_FileSystem_Link
    #PB_Files_Only_ReadUser   = #PB_FileSystem_ReadUser
    #PB_Files_Only_WriteUser  = #PB_FileSystem_WriteUser
    #PB_Files_Only_ExecUser   = #PB_FileSystem_ExecUser
    #PB_Files_Only_ReadGroup  = #PB_FileSystem_ReadGroup
    #PB_Files_Only_WriteGroup = #PB_FileSystem_WriteGroup
    #PB_Files_Only_ReadAll    = #PB_FileSystem_ReadAll
    #PB_Files_Only_WriteAll   = #PB_FileSystem_WriteAll
    #PB_Files_Only_ExecAll    = #PB_FileSystem_ExecAll
    
    #FS_Files_Ignore_Link       = #FS_Files_All & ~#PB_FileSystem_Link
    #FS_Files_Ignore_ReadUser   = #FS_Files_All & ~#PB_FileSystem_ReadUser
    #FS_Files_Ignore_WriteUser  = #FS_Files_All & ~#PB_FileSystem_WriteUser
    #FS_Files_Ignore_ExecUser   = #FS_Files_All & ~#PB_FileSystem_ExecUser
    #FS_Files_Ignore_ReadGroup  = #FS_Files_All & ~#PB_FileSystem_ReadGroup
    #FS_Files_Ignore_WriteGroup = #FS_Files_All & ~#PB_FileSystem_WriteGroup
    #FS_Files_Ignore_ReadAll    = #FS_Files_All & ~#PB_FileSystem_ReadAll
    #FS_Files_Ignore_WriteAll   = #FS_Files_All & ~#PB_FileSystem_WriteAll
    #FS_Files_Ignore_ExecAll    = #FS_Files_All & ~#PB_FileSystem_ExecAll
    
  CompilerEndIf
  
  ; Structure to list directory entries
  Structure TDirectoryEntry
    Name.s              ; Name of File or Directory
    Size.q              ; Size of File or Directory
    Attributes.i        ; Atrributes Hidden, System ...; Linux/Mac ReadUse, WriteUser ...
    DateCreated.i       
    DateAccessed.i
    DateModified.i
    EntryType.i         ; #PB_DirectoryEntry_File, #PB_DirectoryEntry_Directory
  EndStructure
  
  Prototype.i FileFilterCallback(*TDirectoryEntry.TDirectoryEntry)

  Declare.i  ListFilesEx(Directory$, List Files.TDirectoryEntry(), SubDirLevel=#PB_Default, RegExpr$="", Flags=#FS_Files_All, *FileFilterCallback=#Null)
  Declare.s GetAttributesText(Attrib)
  Declare.i CreatePath(Path.s)
  
  Macro FileExist(FileName)
  ; ===========================================================================
  ;  NAME : FileExist
  ;  DESC : Macro FileExist
  ;  VAR(FileName) : Full Filename with full path
  ;  RET : #True if exists
  ; =========================================================================== 
    Bool(FileSize(sFileName) >= 0)  
       
    ; FileSize ReturnValue
    ;  -1: Datei wurde nicht gefunden.
    ;  -2: Datei ist ein Verzeichnis.
  EndMacro
  
  Macro DirectoryExist(Directory)
  ; ===========================================================================
  ;  NAME : DirectoryExist
  ;  DESC : Macro DirectoryExist
  ;  VAR(Directory) : Full Directory Name
  ;  RET : #True if exists
  ; =========================================================================== 
   Bool(FileSize(Directory) = -2)
  EndMacro

EndDeclareModule

  
Module FS
  
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
    
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
  
    
  Procedure.s GetAttributesText(Attrib)
  ; ===========================================================================
  ;  NAME : GetAttributesText
  ;  DESC : creates a String with all the attributes
  ;  DESC : Windows: "R-H-S-N-A-C"
  ;  DESC : Linux/Mac : "Lnk/Urd/Uwrt/Uexe/Grd/Gwrt/Gexe/Ard/Awrt/Aexe"
  ;  VAR(Attrib) : The File Attributes (FLAGs)
  ;  RET.s : Attribut String
  ; =========================================================================== 
    Protected ret.s
    
    #SEP = " : "
    #Off = "x"
    #Off3 ="---"
    #Off4 ="----"
    
    ; we must select OS-Type because This PB Constants 
    ; for Windows are undifined in Linux and in Linux Windows constans
    ; are undefined
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows   
      
      ret ="R-H-S-N-A-C" ; 8x'-' for 8 Flags R,H,S,A,N,C
      ; ------------------------------------------------------------
      ;  Windows Attributes
      ; ------------------------------------------------------------        
      If Not (Attrib & #PB_FileSystem_ReadOnly)   : ret = ReplaceString(ret, "R", #Off) : EndIf
      If Not (Attrib & #PB_FileSystem_Hidden)     : ret = ReplaceString(ret, "H", #Off) : EndIf
      If Not (Attrib & #PB_FileSystem_System)     : ret = ReplaceString(ret, "S", #Off) : EndIf
      If Not (Attrib & #PB_FileSystem_Archive)    : ret = ReplaceString(ret, "A", #Off) : EndIf
      If Not (Attrib & #PB_FileSystem_Normal)     : ret = ReplaceString(ret, "N", #Off) : EndIf
      If Not (Attrib & #PB_FileSystem_Compressed) : ret = ReplaceString(ret, "C", #Off) : EndIf
  
    CompilerElse
      ; ------------------------------------------------------------
      ;  Linux, MAC
      ; ------------------------------------------------------------       
      ret ="Lnk/Urd/Uwrt/Uexe/Grd/Gwrt/Gexe/Ard/Awrt/Aexe" ; 8x'-' for 8 Flags R,H,S,A,N,C
      
      If (Attrib & #PB_FileSystem_Link)      : ret = ReplaceString(ret, "Lnk", #Off3) : EndIf
      ; User
      If (Attrib & #PB_FileSystem_ReadUser)  : ret = ReplaceString(ret, "Urd", #Off3) : EndIf
      If (Attrib & #PB_FileSystem_WriteUser) : ret = ReplaceString(ret, "Uwrt", #Off4) : EndIf
      If (Attrib & #PB_FileSystem_ExecUser)  : ret = ReplaceString(ret, "Uexe", #Off4) : EndIf
      
    CompilerEndIf
    ProcedureReturn ret
  EndProcedure
  
  Structure TSharedParams       ; ListFilesRecursive Shared Parameters
    hRegExp.i
    ActSubLevel.i
    MaxSubLevel.i
    Flags.i
    FileCount.i                 ; File Counter
    DirCount.i                  ; Directory Counter
    pFileFilterCallback.i       ; FilterCallback Preoedure
  EndStructure 
  
  Define SharedParams.TSharedParams
  
  Procedure _ListFilesRecursive(*Dir.String, List Files.TDirectoryEntry())
  ; ===========================================================================
  ; NAME : _ListFilesRecursive
  ; DESC : This is the recursive functions what calls itself
  ; DESC : to path trough the Directory-Tree 
  ; DESC : Attention! Don't call this Function directly
  ; DESC : it is called by the User-Function ListFiles()
  ; VAR(Dir.String) : actual Directory Name as String-Type
  ; VAR(List Files()) : List() to hold the Directory Entries
  ; VAR(*TShareParams.TSharedParams) Pointer to shard Parameter Type  
  ; VAR(*FileFilterCallback=#Null): Callback-Adress for User FileFilterFunction
  ; RET : -
  ; =========================================================================== 
    
    Shared SharedParams
    
    Protected hDir, xMatch, Attribute            
    Protected FileName.s
    Protected TDE.TDirectoryEntry
    
    NewList SubDir.String()        ; List of SubDirectories
    
    If Right(*Dir\s, 1) <> #PS$ ; #PS$ ="\" in Windows "/" in Linux
      *Dir\s + #PS$
    EndIf
    ; ClearList(Files()) ; ATTENTION! Do not ClearList because we use Recursive calls what will destroy our List
        
    hDir = ExamineDirectory(#PB_Any, *Dir\s, "") ; *TShareParams\RegExpr$)
    
    If hDir
      ;Debug Directory$
      SharedParams\DirCount + 1      ; Count the Directory
      
      While NextDirectoryEntry(hDir)        ; Steps trough all entries
                                               
        If DirectoryEntryType(hDir)=#PB_DirectoryEntry_File 
          
          Attribute = DirectoryEntryAttributes(hDir) ; Read File Attributes
          ;Debug GetAttributeText(Attribute)           
          If (Attribute & SharedParams\Flags)  ; List only Selected                          
            With TDE
              \Name = *Dir\s + DirectoryEntryName(hDir)
              \Attributes = Attribute
              \Size = DirectoryEntrySize(hDir)
              \DateCreated = DirectoryEntryDate(hDir, #PB_Date_Created)
              \DateAccessed = DirectoryEntryDate(hDir, #PB_Date_Accessed)   
              \DateModified = DirectoryEntryDate(hDir, #PB_Date_Modified) 
              \EntryType   = #PB_DirectoryEntry_File
            EndWith 
            
            With SharedParams
              xMatch = #True      
              ; Test the Regular Expression
              If \hRegExp              
                xMatch= MatchRegularExpression(\hRegExp, TDE\Name)
              EndIf
              ; if xMatch is still #True, test the User-Filter          
              If xMatch And \pFileFilterCallback            ; if a Callback is specified, send the datas over the users Filter Funtion                
                Protected MyFilterProc.FileFilterCallback   ; Prototype FileFilterCallback
                MyFilterProc = \pFileFilterCallback         ; Bind Adress of Users Callback Function                
                xMatch= MyFilterProc(TDE)                   ; Call the Users FilterProc, returns #False/#True
              EndIf          
              ; if xMatch is still #True, we can add the File to our List()
              If xMatch
                AddElement(Files())   ; Add new Element to our FileList  
                Files()=TDE
                \FileCount + 1  ; Count Files                                                       
              EndIf                       
            EndWith  
          EndIf 
           
        Else  ; DirectoryEntryType(hDir)= #PB_DirectoryEntry_Directory  ; it is a SubDirectory
              
          ; List SubDirectories 
          Select DirectoryEntryName(hDir)
            Case ".", ".."
              ; ignore 
            Default
              AddElement(SubDir())      
              SubDir()\s = *Dir\s + DirectoryEntryName(hDir)
              ; Debug SubDir()
          EndSelect              
        EndIf              
      Wend
    
      FinishDirectory(hDir)       ; finish this ExamineDirectory (release the Memory)      
      ; Debug "Sub Level = " + *TShareParams\ActSubLevel  + " : Max = " + *TShareParams\MaxSubLevel
      With SharedParams
      ; check if the max depth of Subdirectories reached, at #PB_Default (-1) we search for all
        If (\MaxSubLevel = #PB_Default) Or (\ActSubLevel < \MaxSubLevel)
          
          \ActSubLevel + 1  ; now we enter next SubDirctory Level in depth
          ForEach SubDir()
            _ListFilesRecursive(SubDir(), Files())     ; rekursive call of ListFiles for all Subdirectories
          Next
          \ActSubLevel - 1 ; when a SubDirctory Level is finished, we go back in depth 
        EndIf
      EndWith
    Else 
      ; Debug "Access denied : " + *Dir\s
    EndIf
  EndProcedure
 
  Procedure.i ListFilesEx(Directory$, List Files.TDirectoryEntry(), SubDirLevel=#PB_Default, RegExpr$="", Flags=#FS_Files_All, *FileFilterCallback=#Null)
  ; ===========================================================================
  ; NAME : ListFilesEx
  ; DESC : This is the main function to list the Files
  ; DESC : it calls the recursive Function _ListFiles which
  ; DESC : path trough the Directory-Tree
  ; DESC : 
  ; VAR(Directory$) : Start Directory
  ; VAR(List Files()) : List() to hold the Directory Entries
  ; VAR(SubDirLevel): Scan Subdirectories to this deep
  ;                   #PB_Default (-1) = Scan All
  ;                   0 = do not scan subdirecotries
  ; VAR(RegExpr$) : a Regular expression to filter the File-Names
  ; VAR(Flags) : Flags to select the FileTypes 
  ;              #FS_Files_Only_Hidden : lists only hidden files
  ;              #FS_Files_Ignore_HiddenAndSystem : ignores system an hidden files
  ; VAR(*FileFilterCallback=#Null): Callback-Adress for User FileFilterFunction
  ; RET.i : Number of files listed
  ; =========================================================================== 
    
    Shared SharedParams
    Protected StartDir.String
    
    Debug Directory$
    ;Shared Shared_Flags, Shared_SubDirLevel, Shared_Pattern$, Shared_ActualSubLevel
    
    ; Flags=0 would list nothing, because we set to ListAll
    
    With SharedParams
      If Flags=0 
        \Flags = #FS_Files_All
      Else
        \Flags = Flags 
      EndIf
     
     ;\RegExpr$ = RegExpr$
     \MaxSubLevel = SubDirLevel
     \ActSubLevel = 0
     \hRegExp = 0
     \pFileFilterCallback = *FileFilterCallback
     
      ; because Pattern$ like "*.pdf" for ExamineDirectory hide Directories and Files which are not matching the Pattern
      ; so we can't go deeper into SubDirectories because we don't get it with ExamineDirectory
      ; 2 solutions: 
      ;   a) we do ExamineDirecotry twice : once without Pattern To get Subdirectories And a second time For filtering
      ;   b) we use Regular Expressions instead of Patterns because this is more powerful
      ;      but *.pdf do not match! We have to use .pdf
      If RegExpr$
        Debug RegExpr$
        If Left(RegExpr$,1) = "*"
          RegExpr$ = Mid(RegExpr$,2)
        EndIf
        If RegExpr$ <> #Null$
          \hRegExp = CreateRegularExpression(#PB_Any, RegExpr$)
        EndIf
      EndIf
    EndWith
    
    StartDir\s = Directory$
    _ListFilesRecursive(StartDir, Files())    ; call the recursive Function
    ProcedureReturn ListSize(Files())
    
    If SharedParams\hRegExp 
      FreeRegularExpression(SharedParams\hRegExp)
    EndIf
  EndProcedure
  
  Procedure ListFiles(Dir$, List Files.s(), Pattern$="", SearchInSubDirecotries=#False)
    Protected NewList DirList.s(), hDir
    AddElement(DirList())
    DirList()=Dir$
    
    While ListSize(DirList())
      FirstElement(DirList())
      Dir$=DirList()
      
      hDir=ExamineDirectory(#PB_Any,Dir$, Pattern$)
      If hDir
        While NextDirectoryEntry(hDir)          
          If DirectoryEntryType(hDir)=#PB_DirectoryEntry_File
            AddElement(Files())
            Files()=Dir$ + #PS$ + DirectoryEntryName(hDir)
          Else
            If SearchInSubDirecotries
              Select DirectoryEntryName(hDir)
                Case ".", ".."
                  ; ignore
                Default
                 AddElement(DirList())
                 DirList()=Dir$ + #PS$ + DirectoryEntryName(hDir)
              EndSelect 
            EndIf  
          EndIf
        Wend
        FinishDirectory(hDir)
      EndIf
      FirstElement(DirList())
      DeleteElement(DirList())
    Wend
  EndProcedure

  Procedure.i CreatePath(Path.s)
  ; ===========================================================================
  ; NAME : CreatePath
  ; DESC : Creates all directories in the Path if they do not exist
  ; VAR(Path.s): Path to create
  ; RET.i : #True if completely created
  ; =========================================================================== 
  
    Protected ret, pos, Folder$  
    ret=#True
    
    If Right(Path,1) <> #PS$    ; if Right() <> "\"
      Path = GetPathPart(Path)  ; Remove the File-Part from Path
    EndIf
    
    pos = 3 
    While pos
      pos = FindString(Path, #PS$, pos+1) ;#PS$ ="\" OS-specific separator
      Debug pos
      If pos 
        Folder$ = Left(Path,pos)
        Debug Str(pos) + " : " + Folder$
        If DirectoryExist(Folder$)  ; it is an existing Driectory
          ; we don't have to crate it
        Else
            
          If CreateDirectory(Folder$)
            ; ok  
          Else
            ret =#False
          EndIf
        EndIf
    
      EndIf
    Wend
    ProcedureReturn ret
  EndProcedure 

EndModule 


CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule FS
  
  CreatePath("D:\Temp\PureBasic\Test\CreatePath\MyPath\")
  
CompilerEndIf
; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 19
; Folding = ---
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)