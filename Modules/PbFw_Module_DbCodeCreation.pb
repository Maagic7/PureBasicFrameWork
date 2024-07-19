; ===========================================================================
;  FILE : PbFw_Module_DbCodeCreation.pb
;  NAME : Module BUFFER [DBCC::]
;  DESC : DataBase CodeCreation Module
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/07/17
; VERSION  :  0.1 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;   2024/07/17 S.Maag: created the Module based on my DB_CodeCreater.pb from 2022
;              now use CodeCreation Module CC:: for better control of the Code 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

 XIncludeFile "PbFw_Module_PbFw.pb"             ; PbFw::   FrameWork control Module
 XIncludeFile "PbFw_Module_CodeCreation.pb"     ; CC::     CodeCreation Module

DeclareModule DBCC
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  Structure TDBField
    ID.i
    Name.s
    Type.i        ; DataType #PB_Database_[Long, String, Float, Double, Quad, Blob]
    ByteSize.i     ; FieldSize in Bytes! Das funktioniert leider nicht / noch nicht
  EndStructure
  
  Structure TDBTable
    Name.s
    List Fields.TDBField()
  EndStructure
  
  Structure ThDB
    hDB.i
    DBFile.s
    List lstTables.TDBTable()
    IsOpen.i
  EndStructure
  
  Declare.s Get_TypeConstantName(Type = #PB_Database_Long)
  Declare.s Get_TypeDataTye(Type = #PB_Database_Long)
  Declare.s GetCMD_GetDatabase(Type = #PB_Database_Long)
  Declare.s GetCMD_SetDatabase(Type = #PB_Database_Long)
  
  Declare CreateCode_CopyToClipBpard()

EndDeclareModule


Module DBCC
 
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  
  ; Global NewList DBTables.TDBTable() ; List with the Table Names
  
  Global hDB    ;  DataBase Handle
  Global DB_Name.s
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------

  Procedure.s Get_TypeConstantName(Type = #PB_Database_Long)
    ; Returns the Name of the ConstatType as String
    Select Type
      Case #PB_Database_Long  
        ProcedureReturn "Long"
        
      Case #PB_Database_String
        ProcedureReturn "String"
        
      Case #PB_Database_Float 
        ProcedureReturn "Float"
        
      Case #PB_Database_Double
        ProcedureReturn "Double"
        
      Case #PB_Database_Quad  
        ProcedureReturn "Quad"
        
      Case #PB_Database_Blob  
        ProcedureReturn "Blob"
    EndSelect
  EndProcedure 
  
  Procedure.s Get_TypeDataTye(Type = #PB_Database_Long)
    ; returns the corresponding PureBasic DataType-Defintion for a DataBase Field-Type
    Select Type
      Case #PB_Database_Long  
        ProcedureReturn ".l"
        
      Case #PB_Database_String
        ProcedureReturn ".s"
        
      Case #PB_Database_Float 
        ProcedureReturn ".f"
        
      Case #PB_Database_Double
        ProcedureReturn ".d"
        
      Case #PB_Database_Quad  
        ProcedureReturn ".q"
        
      Case #PB_Database_Blob  
        ProcedureReturn ".i"  ; Blob is a Binary DataField, so we must use a Pointer to a Memory 
    EndSelect
  EndProcedure 
  
  Procedure.s GetCMD_GetDatabase(Type = #PB_Database_Long)
    ; Get the correct PureBasic Database Command for a FieldType
    Select Type
      Case #PB_Database_Long  
        ProcedureReturn "GetDatabaseLong"
        
      Case #PB_Database_String
        ProcedureReturn "GetDatabaseString"
        
      Case #PB_Database_Float 
        ProcedureReturn "GetDatabaseFloat"
        
      Case #PB_Database_Double
        ProcedureReturn "GetDatabaseDouble"
        
      Case #PB_Database_Quad  
        ProcedureReturn "GetDatabaseQuad"
        
      Case #PB_Database_Blob  
        ProcedureReturn "GetDatabaseBlob"  ; Blob is a Binary Field
    EndSelect
  EndProcedure 
  
  Procedure.s GetCMD_SetDatabase(Type = #PB_Database_Long)
    ; Get the correct PureBasic Database Command for a FieldType
   
    Select Type
      Case #PB_Database_Long  
        ProcedureReturn "SetDatabaseLong"
        
      Case #PB_Database_String
        ProcedureReturn "SetDatabaseString"
        
      Case #PB_Database_Float 
        ProcedureReturn "SetDatabaseFloat"
        
      Case #PB_Database_Double
        ProcedureReturn "SetDatabaseDouble"
        
      Case #PB_Database_Quad  
        ProcedureReturn "SetDatabaseQuad"
        
      Case #PB_Database_Blob  
        ProcedureReturn "SetDatabaseBlob"  ; Blob is a Binary Field
    EndSelect
  EndProcedure 
  
  Procedure Load_DBTableFields(*hDB.ThDB)
  ; ======================================================================
  ; NAME: Load_DBTableFields
  ; DESC: Add the Fields of all Database USER-Tabels to Lists
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; RET:  -
  ; ======================================================================
    
    Protected sSQL.s, sTab.s,  sCol.s        
    Protected I, N
    
    ResetList(*hDB\lstTables())
    
    
    ForEach *hDB\lstTables()
      sTab = *hDB\lstTables()\Name
      
      sSQL ="select * from " + sTab + " limit 1"  
      
      If DatabaseQuery(hDB, sSQL)
        
        N=DatabaseColumns(hDB)
        Debug sTab + " : Columns = " + Str(N)
        NextDatabaseRow(hDB)           ; alle Einträge durchlaufen
        
        For I = 0 To N-1
          AddElement(*hDB\lstTables()\Fields()) 
          
          With *hDB\lstTables()\Fields()
            \ID = I
            \Name = DatabaseColumnName(hDB, I)
            \Type = DatabaseColumnType(hdb, I) ;  #PB_Database_Long, #PB_Database_Quad, #PB_Database_String, ...
            ; \ByteSize = DatabaseColumnSize (hdb, I) ; das funktioniert nicht!
            Debug "   " + Str(\ID) + " : " + \Name + " : " + Get_TypeConstantName(\Type) + " : Size =" + Str(\ByteSize)
          EndWith
        Next
        
        FinishDatabaseQuery(hDB)
      Else 
        Debug "Query Error"
      EndIf
    Next
    
  EndProcedure
  
  Procedure.i Load_DBTables(*hDB.ThDB)
  ; ======================================================================
  ; NAME: Load_DBTables
  ; DESC: Loads all Names of the User-Tables in the DataBase into
  ; DESC: our List DBTables()
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; RET.i: Number of loaded Tables
  ; ======================================================================
    Protected sTxt.s, sSQL.s
    Protected I
    
    ; SQL Query to get a List of all User Tabels
    ;sSQL = "Select name FROM sqlite_master WHERE type = 'table'"
    sSQL = "Select name FROM sqlite_master WHERE type IN ('table','view') And name Not LIKE 'sqlite_%' UNION ALL Select name FROM sqlite_temp_master WHERE type IN ('table','view') ORDER BY 1"
    
    If DatabaseQuery(*hDB\hDB, sSQL)
      While NextDatabaseRow(hDB)           ; alle Einträge durchlaufen
        sTxt = GetDatabaseString(*hDB\hDB, 0)   ; Inhalt vom ersten Feld anzeigen
        AddElement(*hDB\lstTables())
        *hDB\lstTables()\Name = sTxt
        I+1
        ; Debug Str(I) + " : " + sTxt  
      Wend
      FinishDatabaseQuery(*hDB\hDB)
      Load_DBTableFields(*hDB)
    Else 
      Debug "Query Error"
    EndIf
    
    ProcedureReturn I
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Code Generation Procedures
  ;- ----------------------------------------------------------------------
  
  Procedure CreateCode_AllTableStructures(*hDB.ThDB, xClear=#False)
  ; ======================================================================
  ; NAME: CreateCode_AllTableStructures
  ; DESC: Create PureBasic Code: 
  ; DESC: Structure of each Table 'Structure [TableName]'
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; VAR(xClear) : #True = Clear the Code() List first, #False= Add the Code
  ; RET:  -
  ; ======================================================================
    
  ;  creates Structure with all Fields in the Table   
  ;   Structure TRec_PERSON
  ;     ID.q
  ;     NAME.s
  ;     VORNAME.s
  ;     STRASSE.s
  ;     ORT.s
  ;     TELEFON.s
  ;     MOBILE.s
  ;     FAX.s
  ;     EMAIL.s
  ;   EndStructure
  
    Protected sTxt.s
  
    ResetList(*hDB\lstTables())
    
    UseModule CC
  
    If xClear
      ClearCode()     ; CC::CleareCode()
    EndIf
    
    ADD() ; Add an empty line 
    ADD(";- ----------------------------------------------------------------------")
    ADD(";- STRUCTURES for Recordsets")
    ADD(";- ----------------------------------------------------------------------")
      
    ForEach *hDB\lstTables()
      sTxt = *hDB\lstTables()\Name
      ResetList(*hDB\lstTables()\Fields())
      
      ADD()
      ADD(";- " + sTxt)      ; Index in the IDE's Procedure
      ADD("Structure TRec_" + sTxt, #PbFw_CC_SHR_AFTER)
      With *hDB\lstTables()
        ResetList(\Fields())
        ForEach \Fields()           ; add each Field from the Table to the Structure
          sTxt = \Fields()\Name + Get_TypeDataTye(\Fields()\Type)
          ADD(sTxt)
        Next
      EndWith
      ADE(#PbFw_CC_CMD_EndStructure)
    Next
    UnuseModule CC
  EndProcedure
  
  Procedure CreateCode_ReadRec(*hDB.ThDB, xClear=#False)
  ; ======================================================================
  ; NAME: CreateCode_AllTableStructures
  ; DESC: Create PureBasic Code: 
  ; DESC: for all Procedure ReadRec_[TableName]
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; VAR(xClear) : #True = Clear the Code() List first, #False= Add the Code
  ; RET:  -
  ; ======================================================================
    
    Protected sTxt.s, sCmd.s, sStr.s
    
    ResetList(*hDB\lstTables())
    
    UseModule CC
  
    If xClear
      ClearCode()     ; CC::CleareCode()
    EndIf
    
    ADD() 
    ADD(";- ----------------------------------------------------------------------")
    ADD(";- PROCEDURES ReadRec")
    ADD(";- ----------------------------------------------------------------------")
    
    ForEach*hDB\lstTables()
      sTxt = *hDB\lstTables()\Name
      ResetList(*hDB\lstTables()\Fields())
      
      ADD()
      PRC("ReadRec_"+ sTxt, "PbDbNo, sField.s, sVal.s, *Rec.TRec_" + sTxt, "")
      ADD(  "Protected ret = #True ", #PbFw_CC_SHR_BEFORE)
      ADD(  "Protected SQL.s ")
      ADD()
      
      sStr = "%Select * from " + sTxt + " WHERE % + sField + % = % + sVal"
      sStr = ReplaceString(sStr, "%", #DQUOTE$)
       
      ADD(  "SQL = " + sStr)
      ADD()
     
      ADD(  "If DatabaseQuery(hdb,SQL)", #PbFw_CC_SHR_AFTER)
        
      ADD(    "If NextDatabaseRow(PbDbNo) ", #PbFw_CC_SHR_AFTER)
      ADD(      "With *Rec ", #PbFw_CC_SHR_AFTER)
      
      ForEach *hDB\lstTables()\Fields()
        With *hDB\lstTables()\Fields()
          sTxt = \Name
          sCmd = GetCMD_GetDatabase(\Type)
          
          If \Type = #PB_Database_Blob
            sCmd ="GetDatabaseQuad"                  ; *****   für BLOB noch anpassen - hat mehr Parmaeter****
            sStr = "\" + \Name + " = " + sCmd + "(hdb, " + \ID + ")"
            ADD(sStr)   
          Else
            sStr = "\" + \Name + " = " + sCmd + "(hdb, " + \ID + ")"
            ADD(sStr)   
          EndIf
          
        EndWith
      Next
  
      ADE(      #PbFw_CC_CMD_EndWith)     ; ADE = AddEasy with automatic shift
      ADE(    #PbFw_CC_CMD_Else)
      ADD(      "ret = #False ") 
      ADE(    #PbFw_CC_CMD_EndIf)
      ADD(    "FinishDatabaseQuery(PbDbNo)")
      ADE(  #PbFw_CC_CMD_Else)
      ADD(    "ret = #False ")
      ADE(  #PbFw_CC_CMD_EndIf)
      ADD()  
      ADD(  "ProcedureReturn ret ")
      ADE(#PbFw_CC_CMD_EndProcedure)

    Next
    UnuseModule CC
  EndProcedure
  
  Procedure CreateCode_WriteRec(*hDB.ThDB, xClear=#False)
  ; ======================================================================
  ; NAME: CreateCode_WriteRec
  ; DESC: Create PureBasic Code: 
  ; DESC: for all Procedure WriteRec_[TableName]
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; VAR(xClear) : #True = Clear the Code() List first, #False= Add the Code
  ; RET:  -
  ; ======================================================================
    
    Protected sTxt.s, sCmd.s, sStr.s
    
    ResetList(*hDB\lstTables())
    
    UseModule CC
  
    If xClear
      ClearCode()     ; CC::CleareCode()
    EndIf
    
    ADD() 
    ADD(";- ----------------------------------------------------------------------")
    ADD(";- PROCEDURES WriteRec")
    ADD(";- ----------------------------------------------------------------------")
    
    ForEach *hDB\lstTables()
      sTxt = *hDB\lstTables()\Name
      ResetList(*hDB\lstTables()\Fields())
      
      ADD("")
      PRC("WriteRec_"+ sTxt, "PbDbNo, sField.s, sVal.s, *Rec.TRec_" + sTxt)
      ADD(  "Protected ret = #True ", #PbFw_CC_SHR_BEFORE)
      ADD(  "Protected SQL.s ")
      ADD()
      
      sStr = "%Select * from " + sTxt + " WHERE % + sField + % = % + sVal"
      sStr = ReplaceString(sStr, "%", #DQUOTE$)
       
      ADD(  "SQL = " + sStr)
      ADD()
     
      ADD(  "If DatabaseQuery(hdb,SQL)", #PbFw_CC_SHR_AFTER)
        
      ADD(    "If NextDatabaseRow(PbDbNo)", #PbFw_CC_SHR_AFTER)
      ADD(      "With *Rec ", #PbFw_CC_SHR_AFTER)
      
      ForEach *hDB\lstTables()\Fields()
        With *hDB\lstTables()\Fields()
          sTxt = \Name
          sCmd = GetCMD_SetDatabase(\Type)
          
          If \Type = #PB_Database_Blob
            sCmd ="SetDatabaseQuad"                  ; *****   für BLOB noch anpassen - hat mehr Parmaeter****
            sStr = "        " + sCmd + "(hdb, " + \ID + ", *Rec\"+ \Name + ")" 
            sStr = ReplaceString(sStr, "%", #DQUOTE$)
            ADD(sStr)   
         Else
            sStr = "        \" + \Name + " = " + sCmd + "(hdb, " + \ID + ")"
            ; SetDatabaseXY(hdb,     \ID,    *Rec\Fieldame)
            sStr = "        " + sCmd + "(hdb, " + \ID + ", *Rec\"+ \Name + ")" 
            sStr = ReplaceString(sStr, "%", #DQUOTE$)
            ADD(sStr)   
          EndIf
          
        EndWith
      Next
  
      ADE(      #PbFw_CC_CMD_EndWith)     ; ADE = AddEasy with automatic shift
      ADE(    #PbFw_CC_CMD_Else)
      ADD(      "ret = #False ") 
      ADE(    #PbFw_CC_CMD_EndIf)
        
      ADD(    "FinishDatabaseQuery(PbDbNo) ")
      ADE(  #PbFw_CC_CMD_Else)
      ADD(    "ret = #False ")
      ADE(  #PbFw_CC_CMD_EndIf)
      ADD()  
      ADD(  "ProcedureReturn ret ")
      ADE(#PbFw_CC_CMD_EndProcedure)
    Next
    UnuseModule CC
  EndProcedure
  
  Procedure CreateCode_ReadWriteProtoypes(*hDB.ThDB, xClear=#False)
  ; ======================================================================
  ; NAME: CreateCode_ReadWriteProtoypes
  ; DESC: Create PureBasic Code: 
  ; DESC: Prototype Procedures for the Mapping ReadRec->ReadRec_[TableName],
  ; DESC: WriteRec->WriteRec_[TableName] 
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; VAR(xClear) : #True = Clear the Code() List first, #False= Add the Code
  ; RET:  -
  ; ======================================================================
    
    Protected sTxt.s, sCmd.s, sStr.s
    ; #DQUOTE$ = Chr(34)  ; It is a predefined PB constant
    
    UseModule CC
  
    If xClear
      ClearCode()     ; CC::CleareCode()
    EndIf
    
    ADD() 
    ADD(";- ----------------------------------------------------------------------")
    ADD(";- PROCEDURES WriteRec")
    ADD(";- ----------------------------------------------------------------------")
    
    ADD() 
    ADD(";- ----------------------------------------------------------------------")
    ADD(";- PROTOTYPES")
    ADD(";- ----------------------------------------------------------------------")
  
    ADD()  
    ADD("Prototype.i TProcDBReadRec(PbDbNo, sField.s, sVal.s, *Rec) ")
    ADD("Prototype.i TProcDBWriteRec(PbDbNo, sField.s, sVal.s, *Rec) ")
    ADD() 
    ADD("Global NewMap pReadRec.i()      ; Map with Pointer for all ReadRec-Functions ")
    ADD("Global NewMap pWriteRec.i()     ; Map with Pointer for all WriteRec-Functions ")
    ADD()
    ADD("; Add all Functions Pointer of ReadRec-, WriteRec- TabNames to the MAPs pReadRec(), pWriteRec()")
    
    ResetList(*hDB\lstTables())
  
    ForEach *hDB\lstTables()
      sTxt = *hDB\lstTables()\Name
      
      ADD("")
      sStr = " pReadRec(%" + sTxt + "%) =  @ReadRec_" + sTxt + "()"
      sStr = ReplaceString(sStr, "%", #DQUOTE$)
      ADD(sStr)
      sStr = " pWriteRec(%" + sTxt + "%) = @WriteRec_" + sTxt +"()"
      sStr = ReplaceString(sStr, "%", #DQUOTE$)
      ADD(sStr)
   
    Next
    ; WriteRec Protoype Procedure
    ADD("")
    PRC("ReadRec", "TabName.s, PbDbNo, sField.s, sVal.s, *Rec")
    ADD(  "Protected DBReadRec.TProcDBReadRec ", #PbFw_CC_SHR_BEFORE)
    ADD()
    ADD(  "If FindMapElement(pReadRec(), TabName)", #PbFw_CC_SHR_AFTER)
    ADD(    "DBReadRec = pReadRec()              ; Get the Pointer to the correct ReadRec_[TableName]")
    ADD(    "DBReadRec(hdb, sField, sVal, *Rec)  ; Call the correct Function ReadRec_[TableName]")
    ADE(  #PbFw_CC_CMD_EndIf)
    ADD()  
    ADD(  "ProcedureReturn ret ")
    ADE(#PbFw_CC_CMD_EndProcedure)
    
    UnuseModule CC
  EndProcedure
  
  
  Procedure CreateCode_CreateGadgets(*hDB.ThDB, TabName.s, xClear=#False)   
  ; ======================================================================
  ; NAME: CreateCode_CreateGadgets
  ; DESC: Create PureBasic Code: 
  ; DESC: 1 Label and 1 TextEdit(String) Gadget for each Field in the Table 
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; VAR(TabName): Name of the Database Table
  ; VAR(xClear) : #True = Clear the Code() List first, #False= Add the Code
  ; RET:  -
  ; ======================================================================
    ; Create PureBasic Code Editing a Record from TabName. Creats all Label and StringGadgets
    Protected sTxt.s, sCmd.s, sStr.s
    
    UseModule CC
  
    If xClear
      ClearCode()     ; CC::CleareCode()
    EndIf
  
    ResetList(*hDB\lstTables())
    
    ForEach *hDB\lstTables()
      If *hDB\lstTables()\Name = TabName
        Break
      EndIf
    Next
    
    sTxt = *hDB\lstTables()\Name 
    ADD("; " + sTxt )
    
    ResetList(*hDB\lstTables()\Fields())
    
    ADD("Procedure Create_Gadgets_" + sTxt + "() ")
    ADD(  "Protected x, y, w, h, dx, dy ", #PbFw_CC_SHR_BEFORE)
    ADD()  
    ADD(  "x= 10: y=10: w=150: h=26 ")
    ADD()   
    ADD(  "dx=w+20 ")
    ADD(  "dy=h+10 ")
    ADD()  
    ADD(  "With Gadgets_" + sTxt, #PbFw_CC_SHR_AFTER)
    ForEach *hDB\lstTables()\Fields()
      With *hDB\lstTables()\Fields()
        sStr = "\lbl_"+\Name + " = TextGadget(#PB_Any, x, y, w, h, %" + \Name +"%) ; Label"
        sStr = ReplaceString(sStr, "%", #DQUOTE$)
        ADD(sStr)
        
        sStr = "\txt_"+\Name + " = StringGadget(#PB_Any, x+dx, y, w, h, %Text%)  ; Text"
        sStr = ReplaceString(sStr, "%", #DQUOTE$)
        ADD(sStr)
        ADD("y+dy")
        ;ADD()
        
      EndWith
    Next
    
    ADE(  #PbFw_CC_CMD_EndWith)
    ADE(#PbFw_CC_CMD_EndProcedure)
    
    UnuseModule CC
  EndProcedure
  
  Procedure CreateCode_GadgetStructs(*hDB.ThDB, TabName.s, xClear=#False)   
  ; ======================================================================
  ; NAME: CreateCode_GadgetStructs
  ; DESC: Create PureBasic Code: 
  ; DESC: a Structure 'TGadgets_[TableName]' for Each Table which contains
  ; DESC: a handle for each Gadget
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; VAR(TabName): Name of the Database Table
  ; VAR(xClear) : #True = Clear the Code() List first, #False= Add the Code
  ; RET:  -
  ; ======================================================================
   
    Protected sTxt.s, sCmd.s, sStr.s
    
    UseModule CC
  
    If xClear
      ClearCode()     ; CC::CleareCode()
    EndIf
  
    ResetList(*hDB\lstTables())
    
    ForEach *hDB\lstTables()
      If *hDB\lstTables()\Name = TabName
        Break
      EndIf
    Next
    sTxt = *hDB\lstTables()\Name 
    ADD(";- " + sTxt )
    
    ResetList(*hDB\lstTables()\Fields())
    
  ;  ADD()  
    ADD("Structure TGadgets_" + sTxt +" ; Structure for Recordset Gadgets", #PbFw_CC_SHR_AFTER)    
    
    ForEach *hDB\lstTables()\Fields()
      With *hDB\lstTables()\Fields()
        ADD("lbl_" + \Name + ".i")   ; the Label Gadget
        ADD("txt_" + \Name + ".i")   ; the String Gadget
      EndWith
    Next
    ADE(#PbFw_CC_CMD_EndStructure)
    ADD("Global Gadgets_" + sTxt + ".TGadgets_" +sTxt)
    
    ; ADD("")  
    ; ADD("Structure TMe ; This", #PbFw_CC_SHR_AFTER)    
    ; ADD(  "RecGadgets.TGadgets_" +sTxt )
    ; ADD("EndStructure", , #PbFw_CC_SHL_BEFORE)
    ; ADD("Global Me.TMe")
    
    UnuseModule CC
  EndProcedure
  
  Procedure CreateCode_AllGatgetStructers(*hDB.ThDB)
  ; ======================================================================
  ; NAME: CreateCode_AllGatgetStructers
  ; DESC: Create PureBasic Code: 
  ; DESC: Steps trough all Tabels and create the Structure with
  ; DESC: the Gadget Handles
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; RET:  -
  ; ======================================================================
    Protected sTxt.s, sCmd.s, sStr.s
    
    UseModule CC
  
    ADD() 
    ADD(";- ----------------------------------------------------------------------")
    ADD(";- STRUCTURES for Gadgets ")
    ADD(";- ----------------------------------------------------------------------")
  
    ResetList(*hDB\lstTables())
    
    ForEach *hDB\lstTables()
      PushListPosition(*hDB\lstTables())
      sTxt = *hDB\lstTables()\Name
      CreateCode_GadgetStructs(*hDB, sTxt)
      ADD()
      PopListPosition(*hDB\lstTables())
    Next
    
    UnuseModule CC
  EndProcedure
  
  Procedure CreateCode_RecToGadgets(*hDB.ThDB, TabName.s, xClear=#False)   
  ; ======================================================================
  ; NAME: CreateCode_RecToGadgets
  ; DESC: Create PureBasic Code: 
  ; DESC: Steps trough all Tabels and create a Procedure
  ; DESC: which copies a internal RECORD to the Gadgets
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; VAR(TabName): Name of the Database Table
  ; VAR(xClear) : #True = Clear the Code() List first, #False= Add the Code
  ; RET:  -
  ; ======================================================================
    ; Create PureBasic Code Structure for Editing Gadgets
    Protected sTxt.s, sCmd.s, sStr.s
    
    UseModule CC
  
    If xClear
      ClearCode()     ; CC::CleareCode()
    EndIf
  
    ResetList(*hDB\lstTables())
    
    ForEach *hDB\lstTables()
      If *hDB\lstTables()\Name = TabName
        Break
      EndIf
    Next
    
    sTxt = *hDB\lstTables()\Name
    ADD("; " +sTxt )
    
    ResetList(*hDB\lstTables()\Fields())
    
    PRC("RecToGadgets_" +sTxt, "*Rec.TRec_" + sTxt)
   ; ADD()
    ADD("With Gadgets_" + sTxt, #PbFw_CC_SHR_BEFORE )
    
    ForEach *hDB\lstTables()\Fields()
      With *hDB\lstTables()\Fields()
        Select \Type  
          Case  #PB_Database_Blob
            
          Case #PB_Database_String
            ; SetGadgetItemText(\txt_ANBAUORT, 0, *Rec\ANBAUORT)
            sStr= "SetGadgetItemText(\txt_" +\Name + ", 0, *Rec\" + \Name +")"
            
          Default
            sStr= "SetGadgetItemText(\txt_" +\Name + ", 0, Str(*Rec\" + \Name +"))"
           
        EndSelect   
        ADD(sStr)
      EndWith
    Next
    
    ADE(  #PbFw_CC_CMD_EndWith)
    ADE(#PbFw_CC_CMD_EndProcedure)
   
  EndProcedure
  
  Procedure CreateCode_AllGadgetCode(*hDB.ThDB)
  ; ======================================================================
  ; NAME: CreateCode_AllGadgetCode
  ; DESC: Create PureBasic Code: 
  ; DESC: All Code Gadgets: Procedures for creating the Gadgets
  ; DESC: Procedures to copy a RECORD to the Gadgets and back
  ; VAR(*hDB.ThDB) : Pointer to our DataBase Handle Structure
  ; RET:  -
  ; ======================================================================
    Protected sTxt.s, sCmd.s, sStr.s
      
    ResetList(*hDB\lstTables())
    
    UseModule CC
  
    ADD() 
    ADD(";- ----------------------------------------------------------------------")
    ADD(";- CREATE GADGETS " )
    ADD(";- ----------------------------------------------------------------------")
    
    ForEach *hDB\lstTables()
      sTxt = *hDB\lstTables()\Name
      PushListPosition(*hDB\lstTables())
      CreateCode_CreateGadgets(*hDB, sTxt)
      ADD()      ; add an empty Line to Code()
      PopListPosition(*hDB\lstTables())
    Next
  
    ResetList(*hDB\lstTables())
    
    ADD() 
    ADD(";- ----------------------------------------------------------------------")
    ADD(";- RECORD TO GADGETS " )
    ADD(";- ----------------------------------------------------------------------")
    
    ForEach *hDB\lstTables()
      sTxt = *hDB\lstTables()\Name
      PushListPosition(*hDB\lstTables())
      CreateCode_RecToGadgets(*hDB, sTxt)
      ADD()
      PopListPosition(*hDB\lstTables())
    Next   
  EndProcedure
  
  Procedure CreateCode_CopyToClipBpard()
  ; ======================================================================
  ; NAME: CreateCode_CopyToClipBpard
  ; DESC: Copy the generated Code in the CodeList to ClipBoard 
  ; RET:  -
  ; ======================================================================
    CC::CopyToClipBoard()
  EndProcedure
  
EndModule


CompilerIf  #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  UseModule DBEx
  
  
CompilerEndIf

; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 64
; FirstLine = 14
; Folding = ----
; Optimizer
; CPU = 5