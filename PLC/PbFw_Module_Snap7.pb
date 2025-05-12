; ===========================================================================
; FILE : PbFw_Module_Snap7.pb
; NAME : PureBasic Framework : Module Snap7 [Snap7::]
; DESC : The Modul version of snap7.pbi
; DESC : Snap7 is an open source library for connecting with Siemens S7 PLC
; DESC : 
; DESC :
; SOURCES: https://snap7.sourceforge.net/
;          
; ===========================================================================
;
; AUTHOR   :  Stefan Maag (porting the snap7.pbi to Module version) 
; DATE     :  2025/03/20
; VERSION  :  1.4.2
; OS       :  all
; LICENCE  :  Snap7 is distributed as a binary shared library with full source code  
;             under GNU Library or Lesser General Public License version 3.0 (LGPLv3)
; ===========================================================================
; ChangeLog: 
;{ 
;}
; ===========================================================================


;-TOP
; Kommentar     : snap7 include
; Author        :
; Second Author :
; Datei         : snap7.pbi
; Version       : 1.4.2
; Erstellt      : 12.10.2013
; Geändert      : 28.12.2016

; http://snap7.sourceforge.net/

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

DeclareModule Snap7
  
  EnableExplicit

  ; ------------------------------------------------------------------------------
  ;                                  COMMON
  ; ------------------------------------------------------------------------------
  
  ;- COMMON
   
  #errLibInvalidParam   =  -1
  #errLibInvalidObject  =  -2
  
  ; CPU status
  #S7CpuStatusUnknown  =  $00
  #S7CpuStatusRun      =  $08
  #S7CpuStatusStop     =  $04
  
  ; ISO Errors
  #errIsoConnect           =  $00010000 ; Connection error
  #errIsoDisconnect        =  $00020000 ; Disconnect error
  #errIsoInvalidPDU        =  $00030000 ; Bad format
  #errIsoInvalidDataSize   =  $00040000 ; Bad Datasize passed to send/recv buffer is invalid
  #errIsoNullPointer       =  $00050000 ; Null passed as pointer
  #errIsoShortPacket       =  $00060000 ; A short packet received
  #errIsoTooManyFragments  =  $00070000 ; Too many packets without EoT flag
  #errIsoPduOverflow       =  $00080000 ; The sum of fragments data exceded maximum packet size
  #errIsoSendPacket        =  $00090000 ; An error occurred during send
  #errIsoRecvPacket        =  $000A0000 ; An error occurred during recv
  #errIsoInvalidParams     =  $000B0000 ; Invalid TSAP params
  #errIsoResvd_1           =  $000C0000 ; Unassigned
  #errIsoResvd_2           =  $000D0000 ; Unassigned
  #errIsoResvd_3           =  $000E0000 ; Unassigned
  #errIsoResvd_4           =  $000F0000 ; Unassigned
  
  ; Tag Struct
  Structure TS7Tag
    Area.l
    DBNumber.l
    Start.l
    Size.l
    WordLen.l 
  EndStructure 
  
  ; ------------------------------------------------------------------------------
  ;                                  PARAMS LIST
  ; ------------------------------------------------------------------------------
  
  ;- PARAMS LIST
  
  #p_u16_LocalPort      =  1
  #p_u16_RemotePort     =  2
  #p_i32_PingTimeout    =  3
  #p_i32_SendTimeout    =  4
  #p_i32_RecvTimeout    =  5
  #p_i32_WorkInterval   =  6
  #p_u16_SrcRef         =  7
  #p_u16_DstRef         =  8
  #p_u16_SrcTSap        =  9
  #p_i32_PDURequest     =  10
  #p_i32_MaxClients     =  11
  #p_i32_BSendTimeout   =  12
  #p_i32_BRecvTimeout   =  13
  #p_u32_RecoveryTime   =  14
  #p_u32_KeepAliveTime  =  15
  
  ; Client/Partner Job status
  #JobComplete  =  0
  #JobPending   =  1
  
  ;******************************************************************************
  ;                                   CLIENT
  ;******************************************************************************
  
  ;- CLIENT
  
  ; Error codes
  #errNegotiatingPDU             =  $00100000
  #errCliInvalidParams           =  $00200000
  #errCliJobPending              =  $00300000
  #errCliTooManyItems            =  $00400000
  #errCliInvalidWordLen          =  $00500000
  #errCliPartialDataWritten      =  $00600000
  #errCliSizeOverPDU             =  $00700000
  #errCliInvalidPlcAnswer        =  $00800000
  #errCliAddressOutOfRange       =  $00900000
  #errCliInvalidTransportSize    =  $00A00000
  #errCliWriteDataSizeMismatch   =  $00B00000
  #errCliItemNotAvailable        =  $00C00000
  #errCliInvalidValue            =  $00D00000
  #errCliCannotStartPLC          =  $00E00000
  #errCliAlreadyRun              =  $00F00000
  #errCliCannotStopPLC           =  $01000000
  #errCliCannotCopyRamToRom      =  $01100000
  #errCliCannotCompress          =  $01200000
  #errCliAlreadyStop             =  $01300000
  #errCliFunNotAvailable         =  $01400000
  #errCliUploadSequenceFailed    =  $01500000
  #errCliInvalidDataSizeRecvd    =  $01600000
  #errCliInvalidBlockType        =  $01700000
  #errCliInvalidBlockNumber      =  $01800000
  #errCliInvalidBlockSize        =  $01900000
  #errCliDownloadSequenceFailed  =  $01A00000
  #errCliInsertRefused           =  $01B00000
  #errCliDeleteRefused           =  $01C00000
  #errCliNeedPassword            =  $01D00000
  #errCliInvalidPassword         =  $01E00000
  #errCliNoPasswordToSetOrClear  =  $01F00000
  #errCliJobTimeout              =  $02000000
  #errCliPartialDataRead         =  $02100000
  #errCliBufferTooSmall          =  $02200000
  #errCliFunctionRefused         =  $02300000
  #errCliDestroying              =  $02400000
  #errCliInvalidParamNumber      =  $02500000
  #errCliCannotChangeParam       =  $02600000
  
  #MaxVars  =  20 ; Max vars that can be transferred with MultiRead/MultiWrite
  
  ; Client Connection Type
  #CONNTYPE_PG     =  $0001 ; Connect to the PLC as a PG
  #CONNTYPE_OP     =  $0002 ; Connect to the PLC as an OP
  #CONNTYPE_BASIC  =  $0003 ; Basic connection
  
  ; Area ID
  #S7AreaPE  =  $81
  #S7AreaPA  =  $82
  #S7AreaMK  =  $83
  #S7AreaDB  =  $84
  #S7AreaCT  =  $1C
  #S7AreaTM  =  $1D
  
  ; Word Length
  #S7WLBit      =  $01
  #S7WLByte     =  $02
  #S7WLWord     =  $04
  #S7WLDWord    =  $06
  #S7WLReal     =  $08
  #S7WLCounter  =  $1C
  #S7WLTimer    =  $1D
  
  ; Block type
  #Block_OB   =  $38
  #Block_DB   =  $41
  #Block_SDB  =  $42
  #Block_FC   =  $43
  #Block_SFC  =  $44
  #Block_FB   =  $45
  #Block_SFB  =  $46
  
  ; Sub Block Type
  #SubBlk_OB   =  $08
  #SubBlk_DB   =  $0A
  #SubBlk_SDB  =  $0B
  #SubBlk_FC   =  $0C
  #SubBlk_SFC  =  $0D
  #SubBlk_FB   =  $0E
  #SubBlk_SFB  =  $0F
  
  ; Block languages
  #BlockLangAWL    =  $01
  #BlockLangKOP    =  $02
  #BlockLangFUP    =  $03
  #BlockLangSCL    =  $04
  #BlockLangDB     =  $05
  #BlockLangGRAPH  =  $06
  
  ; Read/Write Multivars
  Structure TS7DataItem
    Area.l
    WordLen.l
    Result.l
    DBNumber.l
    Start.l
    Amount.l
    *pdata
  EndStructure
  
  ; List Blocks
  Structure TS7BlocksList
    OBCount.l
    FBCount.l
    FCCount.l
    SFBCount.l
    SFCCount.l
    DBCount.l
    SDBCount.l
  EndStructure
  
  ; Blocks info
  Structure TS7BlockInfo
    BlkType.l       ; Block Type (OB, DB)
    BlkNumber.l     ; Block number
    BlkLang.l       ; Block Language
    BlkFlags.l      ; Block flags
    MC7Size.l       ; The real size in bytes
    LoadSize.l      ; Load memory size
    LocalData.l     ; Local data
    SBBLength.l     ; SBB Length
    CheckSum.l      ; Checksum
    Version.l       ; Block version
    ; Chars info
    CodeDate.a[11]  ; Code date
    IntfDate.a[11]  ; Interface date
    Author.a[9]     ; Author
    Family.a[9]     ; Family
    Header.a[9]     ; Header   
  EndStructure 
  
  ; Order code
  Structure TS7OrderCode
    Code.a[21]
    V1.b
    V2.b
    V3.b 
  EndStructure 
  
  ; CPU Info
  Structure TS7CpuInfo
    ModuleTypeName.a[33]
    SerialNumber.a[25]
    ASName.a[25]
    Copyright.a[27]
    ModuleName.a[25]
  EndStructure 
  
  ; CP Info
  Structure TS7CpInfo
    MaxPduLengt.l
    MaxConnections.l
    MaxMpiRate.l
    MaxBusRate.l 
  EndStructure 
  
  ; See §33.1 of "System Software for S7-300/400 System and Standard Functions"
  ; and see SFC51 description too
  Structure SZL_HEADER
    LENTHDR.u
    N_DR.u
  EndStructure 
  
  Structure TS7SZL
    Header.SZL_HEADER
    Data_SZL.a[$4000-4]
  EndStructure 
  
  ; SZL List of available SZL IDs : same as SZL but List items are big-endian adjusted
  Structure TS7SZLList
    Header.SZL_HEADER
    List_SZL.u[$2000-2]
  EndStructure 
  
  ; See §33.19 of "System Software for S7-300/400 System and Standard Functions"
  Structure TS7Protection
    sch_schal.u
    sch_par.u
    sch_rel.u
    bart_sch.u
    anl_sch.u 
  EndStructure 
  
  ;******************************************************************************
  ;                                   SERVER
  ;******************************************************************************
  
  ;- SERVER
  
  #OperationRead   =  0
  #OperationWrite  =  1
  
  #mkEvent  =  0
  #mkLog    =  1
  
  ; Server Area ID  (use with Register/unregister - Lock/unlock Area)
  #srvAreaPE  =  0
  #srvAreaPA  =  1
  #srvAreaMK  =  2
  #srvAreaCT  =  3
  #srvAreaTM  =  4
  #srvAreaDB  =  5
  
  ; Errors
  #errSrvCannotStart         =  $00100000 ; Server cannot start
  #errSrvDBNullPointer       =  $00200000 ; Passed null as PData
  #errSrvAreaAlreadyExists   =  $00300000 ; Area Re-registration
  #errSrvUnknownArea         =  $00400000 ; Unknown area
  #errSrvInvalidParams       =  $00500000 ; Invalid param(s) supplied
  #errSrvTooManyDB           =  $00600000 ; Cannot register DB
  #errSrvInvalidParamNumber  =  $00700000 ; Invalid param (srv_get/set_param)
  #errSrvCannotChangeParam   =  $00800000 ; Cannot change because running
  
  ; TCP Server Event codes
  #evcServerStarted        =  $00000001
  #evcServerStopped        =  $00000002
  #evcListenerCannotStart  =  $00000004
  #evcClientAdded          =  $00000008
  #evcClientRejected       =  $00000010
  #evcClientNoRoom         =  $00000020
  #evcClientException      =  $00000040
  #evcClientDisconnected   =  $00000080
  #evcClientTerminated     =  $00000100
  #evcClientsDropped       =  $00000200
  #evcReserved_00000400    =  $00000400 ; actually unused
  #evcReserved_00000800    =  $00000800 ; actually unused
  #evcReserved_00001000    =  $00001000 ; actually unused
  #evcReserved_00002000    =  $00002000 ; actually unused
  #evcReserved_00004000    =  $00004000 ; actually unused
  #evcReserved_00008000    =  $00008000 ; actually unused
  
  ; S7 Server Event Code
  #evcPDUincoming        =  $00010000
  #evcDataRead           =  $00020000
  #evcDataWrite          =  $00040000
  #evcNegotiatePDU       =  $00080000
  #evcReadSZL            =  $00100000
  #evcClock              =  $00200000
  #evcUpload             =  $00400000
  #evcDownload           =  $00800000
  #evcDirectory          =  $01000000
  #evcSecurity           =  $02000000
  #evcControl            =  $04000000
  #evcReserved_08000000  =  $08000000 ; actually unused
  #evcReserved_10000000  =  $10000000 ; actually unused
  #evcReserved_20000000  =  $20000000 ; actually unused
  #evcReserved_40000000  =  $40000000 ; actually unused
  #evcReserved_80000000  =  $80000000 ; actually unused
  
  ; Masks to enable/disable all events
  #evcAll   =  $FFFFFFFF
  #evcNone  =  $00000000
  
  ; Event SubCodes
  #evsUnknown        =  $0000
  #evsStartUpload    =  $0001
  #evsStartDownload  =  $0001
  #evsGetBlockList   =  $0001
  #evsStartListBoT   =  $0002
  #evsListBoT        =  $0003
  #evsGetBlockInfo   =  $0004
  #evsGetClock       =  $0001
  #evsSetClock       =  $0002
  #evsSetPassword    =  $0001
  #evsClrPassword    =  $0002
  
  ; Event Params : functions group
  #grProgrammer  =  $0041
  #grCyclicData  =  $0042
  #grBlocksInfo  =  $0043
  #grSZL         =  $0044
  #grPassword    =  $0045
  #grBSend       =  $0046
  #grClock       =  $0047
  #grSecurity    =  $0045
  
  ; Event Params : control codes
  #CodeControlUnknown    =  $0000
  #CodeControlColdStart  =  $0001
  #CodeControlWarmStart  =  $0002
  #CodeControlStop       =  $0003
  #CodeControlCompress   =  $0004
  #CodeControlCpyRamRom  =  $0005
  #CodeControlInsDel     =  $0006
  
  ; Event Result
  #evrNoError            =  $0000
  #evrFragmentRejected   =  $0001
  #evrMalformedPDU       =  $0002
  #evrSparseBytes        =  $0003
  #evrCannotHandlePDU    =  $0004
  #evrNotImplemented     =  $0005
  #evrErrException       =  $0006
  #evrErrAreaNotFound    =  $0007
  #evrErrOutOfRange      =  $0008
  #evrErrOverPDU         =  $0009
  #evrErrTransportSize   =  $000A
  #evrInvalidGroupUData  =  $000B
  #evrInvalidSZL         =  $000C
  #evrDataSizeMismatch   =  $000D
  #evrCannotUpload       =  $000E
  #evrCannotDownload     =  $000F
  #evrUploadInvalidID    =  $0010
  #evrResNotFound        =  $0011
  
  Structure TSrvEvent
    EvtTime.l    ; Timestamp
    EvtSender.l  ; Sender
    EvtCode.l    ; Event code
    EvtRetCode.u ; Event result
    EvtParam1.u  ; Param 1 (if available)
    EvtParam2.u  ; Param 2 (if available)
    EvtParam3.u  ; Param 3 (if available)
    EvtParam4.u  ; Param 4 (if available)   
  EndStructure 
  
  ;******************************************************************************
  ;                                   PARTNER
  ;******************************************************************************
  
  ;- PARTNER
  
  ; Status
  #par_stopped     =  0 ; stopped
  #par_connecting  =  1 ; running and active connecting
  #par_waiting     =  2 ; running and waiting for a connection
  #par_linked      =  3 ; running and connected : linked
  #par_sending     =  4 ; sending data
  #par_receiving   =  5 ; receiving data
  #par_binderror   =  6 ; error starting passive server
  
  ; Errors
  #errParAddressInUse        =  $00200000
  #errParNoRoom              =  $00300000
  #errServerNoRoom           =  $00400000
  #errParInvalidParams       =  $00500000
  #errParNotLinked           =  $00600000
  #errParBusy                =  $00700000
  #errParFrameTimeout        =  $00800000
  #errParInvalidPDU          =  $00900000
  #errParSendTimeout         =  $00A00000
  #errParRecvTimeout         =  $00B00000
  #errParSendRefused         =  $00C00000
  #errParNegotiatingPDU      =  $00D00000
  #errParSendingBlock        =  $00E00000
  #errParRecvingBlock        =  $00F00000
  #errParBindError           =  $01000000
  #errParDestroying          =  $01100000
  #errParInvalidParamNumber  =  $01200000 ; Invalid param (par_get/set_param)
  #errParCannotChangeParam   =  $01300000 ; Cannot change because running
  #errParBufferTooSmall      =  $01400000 ; Raised by LabVIEW wrapper
    
  ;- ----------------------------------------------------------------------
  ;- Client Prototype
  ;  ----------------------------------------------------------------------
  Prototype.i Cli_ABRead(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_ABWrite(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsABRead(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsABWrite(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsCTRead(Client.i, Start.i, Amount.i, *pUsrData)
  Prototype.i Cli_AsCTWrite(Client.i, Start.i, Amount.i, *pUsrData)
  Prototype.i Cli_AsCompress(Client.i, Timeout.i)
  Prototype.i Cli_AsCopyRamToRom(Client.i, Timeout.i)
  Prototype.i Cli_AsDBFill(Client.i, DBNumber.i, FillChar.i)
  Prototype.i Cli_AsDBGet(Client.i, DBNumber.i, *pUsrData, *Size)
  Prototype.i Cli_AsDBRead(Client.i, DBNumber.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsDBWrite(Client.i, DBNumber.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsDownload(Client.i, BlockNum.i, *pUsrData, Size.i)
  Prototype.i Cli_AsEBRead(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsEBWrite(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsFullUpload(Client.i, BlockType.i, BlockNum.i, *pUsrData, *Size)
  Prototype.i Cli_AsListBlocksOfType(Client.i, BlockType.i, *pUsrData, *ItemsCount)
  Prototype.i Cli_AsMBRead(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsMBWrite(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_AsReadArea(Client.i, Area.i, DBNumber.i, Start.i, Amount.i, WordLen.i, *pUsrData)
  Prototype.i Cli_AsReadSZL(Client.i, ID.i, Index.i, *pUsrData, *Size)
  Prototype.i Cli_AsReadSZLList(Client.i, *pUsrData, *ItemsCount)
  Prototype.i Cli_AsTMRead(Client.i, Start.i, Amount.i, *pUsrData)
  Prototype.i Cli_AsTMWrite(Client.i, Start.i, Amount.i, *pUsrData)
  Prototype.i Cli_AsUpload(Client.i, BlockType.i, BlockNum.i, *pUsrData, *Size)
  Prototype.i Cli_AsWriteArea(Client.i, Area.i, DBNumber.i, Start.i, Amount.i, WordLen.i, *pUsrData)
  Prototype.i Cli_CTRead(Client.i, Start.i, Amount.i, *pUsrData)
  Prototype.i Cli_CTWrite(Client.i, Start.i, Amount.i, *pUsrData)
  Prototype.i Cli_CheckAsCompletion(Client.i, *opResult)
  Prototype.i Cli_ClearSessionPassword(Client)
  Prototype.i Cli_Compress(Client.i, Timeout.i)
  Prototype.i Cli_Connect(Client)
  Prototype.i Cli_ConnectTo(Client.i, Address.p-ascii, Rack.i, Slot.i)
  Prototype.i Cli_CopyRamToRom(Client.i, Timeout.i)
  Prototype.i Cli_Create()
  Prototype.i Cli_DBFill(Client.i, DBNumber.i, FillChar.i)
  Prototype.i Cli_DBGet(Client.i, DBNumber.i, *pUsrData, *Size)
  Prototype.i Cli_DBRead(Client.i, DBNumber.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_DBWrite(Client.i, DBNumber.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_Delete(Client.i, BlockType.i, BlockNum.i)
  Prototype.i Cli_Destroy(*Client)
  Prototype.i Cli_Disconnect(Client.i)
  Prototype.i Cli_Download(Client.i, BlockNum.i, *pUsrData, Size.i)
  Prototype.i Cli_EBRead(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_EBWrite(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_ErrorText(Error.i, *Text, TextLen.i)
  Prototype.i Cli_FullUpload(Client.i, BlockType.i, BlockNum.i, *pUsrData, *Size)
  Prototype.i Cli_GetAgBlockInfo(Client.i, BlockType.i, BlockNum.i, *pUsrData)
  Prototype.i Cli_GetConnected(Client.i, *Connected)
  Prototype.i Cli_GetCpInfo(Client.i, *pUsrData)
  Prototype.i Cli_GetCpuInfo(Client.i, *pUsrData)
  Prototype.i Cli_GetExecTime(Client.i, *Time)
  Prototype.i Cli_GetLastError(Client.i, *LastError)
  Prototype.i Cli_GetOrderCode(Client.i, *pUsrData)
  Prototype.i Cli_GetParam(Client.i, ParamNumber.i, *pValue)
  Prototype.i Cli_GetPduLength(Client.i, *Requested, *Negotiated)
  Prototype.i Cli_GetPgBlockInfo(Client.i, *pBlock, *pUsrData, Size.i)
  Prototype.i Cli_GetPlcDateTime(Client, *DateTime)
  Prototype.i Cli_GetPlcStatus(Client.i, *Status)
  Prototype.i Cli_GetProtection(Client.i, *pUsrData)
  Prototype.i Cli_IsoExchangeBuffer(Client.i, *pUsrData, *Size)
  Prototype.i Cli_ListBlocks(Client.i, *pUsrData)
  Prototype.i Cli_ListBlocksOfType(Client.i, BlockType.i, *pUsrData, *ItemsCount)
  Prototype.i Cli_MBRead(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_MBWrite(Client.i, Start.i, Size.i, *pUsrData)
  Prototype.i Cli_PlcColdStart(Client.i)
  Prototype.i Cli_PlcHotStart(Client.i)
  Prototype.i Cli_PlcStop(Client.i)
  Prototype.i Cli_ReadArea(Client.i, Area.i, DBNumber.i, Start.i, Amount.i, WordLen.i, *pUsrData)
  Prototype.i Cli_ReadMultiVars(Client.i, Item.i, ItemsCount.i)
  Prototype.i Cli_ReadSZL(Client.i, ID.i, Index.i, *pUsrData, *Size)
  Prototype.i Cli_ReadSZLList(Client.i, *pUsrData, *ItemsCount)
  Prototype.i Cli_SetAsCallback(Client.i, *pCompletion, *usrPtr)
  Prototype.i Cli_SetConnectionParams(Client.i, Address.p-ascii, LocalTSAP.u, RemoteTSAP.u)
  Prototype.i Cli_SetConnectionType(Client.i, ConnectionType.u)
  Prototype.i Cli_SetParam(Client.i, ParamNumber.i, *pValue)
  Prototype.i Cli_SetPlcDateTime(Client.i, *DateTime)
  Prototype.i Cli_SetPlcSystemDateTime(Client.i)
  Prototype.i Cli_SetSessionPassword(Client.i, *Password)
  Prototype.i Cli_TMRead(Client.i, Start.i, Amount.i, *pUsrData)
  Prototype.i Cli_TMWrite(Client.i, Start.i, Amount.i, *pUsrData)
  Prototype.i Cli_Upload(Client.i, BlockType.i, BlockNum.i, *pUsrData, *Size)
  Prototype.i Cli_WaitAsCompletion(Client.i, Timeout.i)
  Prototype.i Cli_WriteArea(Client.i, Area.i, DBNumber.i, Start.i, Amount.i, WordLen.i, *pUsrData)
  Prototype.i Cli_WriteMultiVars(Client.i, Item.i, ItemsCount.i)
  
  ; in a PB Module the Global Variables to hold the Function Pointers for Prototype Functions has to be declared 
  ; in the DeclareModule section. This is different from the snap7.pbi, wehre the Global Variables are defined
  ; in the snap7_OpenDll() Procedure
  
  ; to work with Prototypes PB needs a Var with the Type of the Prototype to hold the Function Pointer
  ; This Globals youe see in the IDE if you Type Snap7:: 
  Global Cli_ABRead.Cli_ABRead  
  Global Cli_ABWrite.Cli_ABWrite 
  Global Cli_AsABRead.Cli_AsABRead 
  Global Cli_AsABWrite.Cli_AsABWrite 
  Global Cli_AsCTRead.Cli_AsCTRead 
  Global Cli_AsCTWrite.Cli_AsCTWrite 
  Global Cli_AsCompress.Cli_AsCompress 
  Global Cli_AsCopyRamToRom.Cli_AsCopyRamToRom 
  Global Cli_AsDBFill.Cli_AsDBFill 
  Global Cli_AsDBGet.Cli_AsDBGet 
  Global Cli_AsDBRead.Cli_AsDBRead 
  Global Cli_AsDBWrite.Cli_AsDBWrite 
  Global Cli_AsDownload.Cli_AsDownload 
  Global Cli_AsEBRead.Cli_AsEBRead 
  Global Cli_AsEBWrite.Cli_AsEBWrite 
  Global Cli_AsFullUpload.Cli_AsFullUpload 
  Global Cli_AsListBlocksOfType.Cli_AsListBlocksOfType 
  Global Cli_AsMBRead.Cli_AsMBRead 
  Global Cli_AsMBWrite.Cli_AsMBWrite 
  Global Cli_AsReadArea.Cli_AsReadArea 
  Global Cli_AsReadSZL.Cli_AsReadSZL 
  Global Cli_AsReadSZLList.Cli_AsReadSZLList 
  Global Cli_AsTMRead.Cli_AsTMRead 
  Global Cli_AsTMWrite.Cli_AsTMWrite 
  Global Cli_AsUpload.Cli_AsUpload 
  Global Cli_AsWriteArea.Cli_AsWriteArea 
  Global Cli_CTRead.Cli_CTRead 
  Global Cli_CTWrite.Cli_CTWrite 
  Global Cli_CheckAsCompletion.Cli_CheckAsCompletion 
  Global Cli_ClearSessionPassword.Cli_ClearSessionPassword 
  Global Cli_Compress.Cli_Compress 
  Global Cli_Connect.Cli_Connect 
  Global Cli_ConnectTo.Cli_ConnectTo 
  Global Cli_CopyRamToRom.Cli_CopyRamToRom 
  Global Cli_Create.Cli_Create 
  Global Cli_DBFill.Cli_DBFill 
  Global Cli_DBGet.Cli_DBGet 
  Global Cli_DBRead.Cli_DBRead 
  Global Cli_DBWrite.Cli_DBWrite 
  Global Cli_Delete.Cli_Delete 
  Global Cli_Destroy.Cli_Destroy 
  Global Cli_Disconnect.Cli_Disconnect 
  Global Cli_Download.Cli_Download 
  Global Cli_EBRead.Cli_EBRead 
  Global Cli_EBWrite.Cli_EBWrite 
  Global Cli_ErrorText.Cli_ErrorText 
  Global Cli_FullUpload.Cli_FullUpload 
  Global Cli_GetAgBlockInfo.Cli_GetAgBlockInfo 
  Global Cli_GetConnected.Cli_GetConnected 
  Global Cli_GetCpInfo.Cli_GetCpInfo 
  Global Cli_GetCpuInfo.Cli_GetCpuInfo 
  Global Cli_GetExecTime.Cli_GetExecTime 
  Global Cli_GetLastError.Cli_GetLastError 
  Global Cli_GetOrderCode.Cli_GetOrderCode 
  Global Cli_GetParam.Cli_GetParam 
  Global Cli_GetPduLength.Cli_GetPduLength 
  Global Cli_GetPgBlockInfo.Cli_GetPgBlockInfo 
  Global Cli_GetPlcDateTime.Cli_GetPlcDateTime 
  Global Cli_GetPlcStatus.Cli_GetPlcStatus 
  Global Cli_GetProtection.Cli_GetProtection 
  Global Cli_IsoExchangeBuffer.Cli_IsoExchangeBuffer 
  Global Cli_ListBlocks.Cli_ListBlocks 
  Global Cli_ListBlocksOfType.Cli_ListBlocksOfType 
  Global Cli_MBRead.Cli_MBRead 
  Global Cli_MBWrite.Cli_MBWrite 
  Global Cli_PlcColdStart.Cli_PlcColdStart 
  Global Cli_PlcHotStart.Cli_PlcHotStart 
  Global Cli_PlcStop.Cli_PlcStop 
  Global Cli_ReadArea.Cli_ReadArea 
  Global Cli_ReadMultiVars.Cli_ReadMultiVars 
  Global Cli_ReadSZL.Cli_ReadSZL 
  Global Cli_ReadSZLList.Cli_ReadSZLList 
  Global Cli_SetAsCallback.Cli_SetAsCallback 
  Global Cli_SetConnectionParams.Cli_SetConnectionParams 
  Global Cli_SetConnectionType.Cli_SetConnectionType 
  Global Cli_SetParam.Cli_SetParam 
  Global Cli_SetPlcDateTime.Cli_SetPlcDateTime 
  Global Cli_SetPlcSystemDateTime.Cli_SetPlcSystemDateTime 
  Global Cli_SetSessionPassword.Cli_SetSessionPassword 
  Global Cli_TMRead.Cli_TMRead 
  Global Cli_TMWrite.Cli_TMWrite 
  Global Cli_Upload.Cli_Upload 
  Global Cli_WaitAsCompletion.Cli_WaitAsCompletion 
  Global Cli_WriteArea.Cli_WriteArea 
  Global Cli_WriteMultiVars.Cli_WriteMultiVars 
  
  ;- ----------------------------------------------------------------------
  ;- Server Prototype
  ; ----------------------------------------------------------------------
  Prototype.i Srv_ClearEvents(Server)
  Prototype.i Srv_Create()
  Prototype.i Srv_Destroy(*Server)
  Prototype.i Srv_ErrorText(Error.i, *Text, TextLen.i)
  Prototype.i Srv_EventText(*Event, *Text, TextLen.i)
  Prototype.i Srv_GetMask(Server.i, MaskKind.i, *Mask)
  Prototype.i Srv_GetParam(Server.i, ParamNumber.i, *pValue)
  Prototype.i Srv_GetStatus(Server.i, *ServerStatus, *CpuStatus, *ClientsCount)
  Prototype.i Srv_LockArea(Server.i, AreaCode.i, Index.u)
  Prototype.i Srv_PickEvent(Server.i, *pEvent, *EvtReady)
  Prototype.i Srv_RegisterArea(Server.i, AreaCode.i, Index.u, *pUsrData, Size.i)
  Prototype.i Srv_SetCpuStatus(Server.i, CpuStatus.i)
  Prototype.i Srv_SetEventsCallback(Server.i, *pCallback, *usrPtr)
  Prototype.i Srv_SetMask(Server.i, MaskKind.i, Mask.l)
  Prototype.i Srv_SetParam(Server.i, ParamNumber.i, *pValue)
  Prototype.i Srv_SetRWAreaCallback(Server.i, *pCallback, *usrPtr)
  Prototype.i Srv_SetReadEventsCallback(Server.i, *pCallback, *usrPtr)
  Prototype.i Srv_Start(Server.i)
  Prototype.i Srv_StartTo(Server, Address.p-ascii)
  Prototype.i Srv_Stop(Server.i)
  Prototype.i Srv_UnlockArea(Server.i, AreaCode.i, Index.u)
  Prototype.i Srv_UnregisterArea(Server.i, AreaCode.i, Index.u)
  
  Global Srv_ClearEvents.Srv_ClearEvents 
  Global Srv_Create.Srv_Create 
  Global Srv_Destroy.Srv_Destroy 
  Global Srv_ErrorText.Srv_ErrorText 
  Global Srv_EventText.Srv_EventText 
  Global Srv_GetMask.Srv_GetMask 
  Global Srv_GetParam.Srv_GetParam 
  Global Srv_GetStatus.Srv_GetStatus 
  Global Srv_LockArea.Srv_LockArea 
  Global Srv_PickEvent.Srv_PickEvent 
  Global Srv_RegisterArea.Srv_RegisterArea 
  Global Srv_SetCpuStatus.Srv_SetCpuStatus 
  Global Srv_SetEventsCallback.Srv_SetEventsCallback 
  Global Srv_SetMask.Srv_SetMask 
  Global Srv_SetParam.Srv_SetParam 
  Global Srv_SetRWAreaCallback.Srv_SetRWAreaCallback 
  Global Srv_SetReadEventsCallback.Srv_SetReadEventsCallback 
  Global Srv_Start.Srv_Start 
  Global Srv_StartTo.Srv_StartTo 
  Global Srv_Stop.Srv_Stop 
  Global Srv_UnlockArea.Srv_UnlockArea 
  Global Srv_UnregisterArea.Srv_UnregisterArea   
  
  ;- ----------------------------------------------------------------------
  ;- Partner Prototype
  ;- ----------------------------------------------------------------------
  Prototype.i Par_AsBSend(Partner.i, R_ID.l, *pUsrData, Size.i)
  Prototype.i Par_BRecv(Partner.i, *R_ID, *pData, *Size, Timeout.l)
  Prototype.i Par_BSend(Partner.i, R_ID.l, *pUsrData, Size.i)
  Prototype.i Par_CheckAsBRecvCompletion(Partner.i, *opResult, *R_ID, *pData, *Size)
  Prototype.i Par_CheckAsBSendCompletion(Partner.i, *opResult)
  Prototype.i Par_Create(Active.i)
  Prototype.i Par_Destroy(*Partner)
  Prototype.i Par_ErrorText(Error.i, *Text, TextLen.i)
  Prototype.i Par_GetLastError(Partner.i, *LastError)
  Prototype.i Par_GetParam(Partner.i, ParamNumber.i, *pValue)
  Prototype.i Par_GetStats(Partner.i, *BytesSent, *BytesRecv, *SendErrors, *RecvErrors)
  Prototype.i Par_GetStatus(Partner.i, *Status)
  Prototype.i Par_GetTimes(Partner.i, *SendTime, *RecvTime)
  Prototype.i Par_SetParam(Partner.i, ParamNumber.i, *pValue)
  Prototype.i Par_SetRecvCallback(Partner.i, *pCompletion, *usrPtr)
  Prototype.i Par_SetSendCallback(Partner.i, *pCompletion, *usrPtr)
  Prototype.i Par_Start(Partner.i)
  Prototype.i Par_StartTo(Partner.i, LocalAddress.p-ascii, RemoteAddress.p-ascii, LocTsap.u, RemTsap.u)
  Prototype.i Par_Stop(Partner.i)
  Prototype.i Par_WaitAsBSendCompletion(Partner.i, Timeout.l)
  
  Global Par_AsBSend.Par_AsBSend 
  Global Par_BRecv.Par_BRecv 
  Global Par_BSend.Par_BSend 
  Global Par_CheckAsBRecvCompletion.Par_CheckAsBRecvCompletion 
  Global Par_CheckAsBSendCompletion.Par_CheckAsBSendCompletion 
  Global Par_Create.Par_Create 
  Global Par_Destroy.Par_Destroy 
  Global Par_ErrorText.Par_ErrorText 
  Global Par_GetLastError.Par_GetLastError 
  Global Par_GetParam.Par_GetParam 
  Global Par_GetStats.Par_GetStats 
  Global Par_GetStatus.Par_GetStatus 
  Global Par_GetTimes.Par_GetTimes 
  Global Par_SetParam.Par_SetParam 
  Global Par_SetRecvCallback.Par_SetRecvCallback 
  Global Par_SetSendCallback.Par_SetSendCallback 
  Global Par_Start.Par_Start 
  Global Par_StartTo.Par_StartTo 
  Global Par_Stop.Par_Stop 
  Global Par_WaitAsBSendCompletion.Par_WaitAsBSendCompletion 
  
  Declare.s CliErrorText(Error.i)
  Declare.s SrvErrorText(Error.i)
  Declare.s ParErrorText(Error.i)
  Declare.s SrvEventText(*Event)
EndDeclareModule

Module Snap7
  
  EnableExplicit
  
  Global snap7_hDLL.i ; Library Handle

  Procedure.i snap7_CloseDLL()
    If snap7_hDLL <> 0
      If IsLibrary(snap7_hDLL)
        CloseLibrary(snap7_hDLL)
        snap7_hDLL  =  0    ; moved inside If : 2024/12/08 S.Maag
      EndIf
    EndIf
    ProcedureReturn snap7_hDLL  ; added return of snap7_hDLL : 2024/12/08 S.Maag
  EndProcedure
  
  Procedure.i snap7_OpenDLL()
    
    ; 024/12/08 S.Maag : changed ProcedureReturn from #False/#True to snap7_hDLL
    ;                    added a check if snap7 Dll is already loaded
    
    If snap7_hDLL ; if snap7_Dll is loaded
      ; added by S.Maag
      ProcedureReturn snap7_hDLL ; just return the snap7_hDLL
    EndIf
    
    snap7_hDLL  =  OpenLibrary(#PB_Any, "snap7.dll")
    If snap7_hDLL  =  0
      ProcedureReturn snap7_hDLL
    EndIf
    
    ; in a PB Module the Global Variables to hold the Function Pointers for Prototype Functions has to be declared 
    ; in the DeclareModule section. This is different from the snap7.pbi, wehre the Global Variables are defined
    ; hier in the snap7_OpenDll() Procedure. In the Module-Version the GLOBAL definiten of the Prototype vars
    ; has moved to the DeclareModlue Section

    Cli_ABRead.Cli_ABRead  =  GetFunction(snap7_hDLL,"Cli_ABRead")
    Cli_ABWrite.Cli_ABWrite = GetFunction(snap7_hDLL,"Cli_ABWrite")
    Cli_AsABRead.Cli_AsABRead = GetFunction(snap7_hDLL,"Cli_AsABRead")
    Cli_AsABWrite.Cli_AsABWrite = GetFunction(snap7_hDLL,"Cli_AsABWrite")
    Cli_AsCTRead.Cli_AsCTRead = GetFunction(snap7_hDLL,"Cli_AsCTRead")
    Cli_AsCTWrite.Cli_AsCTWrite = GetFunction(snap7_hDLL,"Cli_AsCTWrite")
    Cli_AsCompress.Cli_AsCompress = GetFunction(snap7_hDLL,"Cli_AsCompress")
    Cli_AsCopyRamToRom.Cli_AsCopyRamToRom = GetFunction(snap7_hDLL,"Cli_AsCopyRamToRom")
    Cli_AsDBFill.Cli_AsDBFill = GetFunction(snap7_hDLL,"Cli_AsDBFill")
    Cli_AsDBGet.Cli_AsDBGet = GetFunction(snap7_hDLL,"Cli_AsDBGet")
    Cli_AsDBRead.Cli_AsDBRead = GetFunction(snap7_hDLL,"Cli_AsDBRead")
    Cli_AsDBWrite.Cli_AsDBWrite = GetFunction(snap7_hDLL,"Cli_AsDBWrite")
    Cli_AsDownload.Cli_AsDownload = GetFunction(snap7_hDLL,"Cli_AsDownload")
    Cli_AsEBRead.Cli_AsEBRead = GetFunction(snap7_hDLL,"Cli_AsEBRead")
    Cli_AsEBWrite.Cli_AsEBWrite = GetFunction(snap7_hDLL,"Cli_AsEBWrite")
    Cli_AsFullUpload.Cli_AsFullUpload = GetFunction(snap7_hDLL,"Cli_AsFullUpload")
    Cli_AsListBlocksOfType.Cli_AsListBlocksOfType = GetFunction(snap7_hDLL,"Cli_AsListBlocksOfType")
    Cli_AsMBRead.Cli_AsMBRead = GetFunction(snap7_hDLL,"Cli_AsMBRead")
    Cli_AsMBWrite.Cli_AsMBWrite = GetFunction(snap7_hDLL,"Cli_AsMBWrite")
    Cli_AsReadArea.Cli_AsReadArea = GetFunction(snap7_hDLL,"Cli_AsReadArea")
    Cli_AsReadSZL.Cli_AsReadSZL = GetFunction(snap7_hDLL,"Cli_AsReadSZL")
    Cli_AsReadSZLList.Cli_AsReadSZLList = GetFunction(snap7_hDLL,"Cli_AsReadSZLList")
    Cli_AsTMRead.Cli_AsTMRead = GetFunction(snap7_hDLL,"Cli_AsTMRead")
    Cli_AsTMWrite.Cli_AsTMWrite = GetFunction(snap7_hDLL,"Cli_AsTMWrite")
    Cli_AsUpload.Cli_AsUpload = GetFunction(snap7_hDLL,"Cli_AsUpload")
    Cli_AsWriteArea.Cli_AsWriteArea = GetFunction(snap7_hDLL,"Cli_AsWriteArea")
    Cli_CTRead.Cli_CTRead = GetFunction(snap7_hDLL,"Cli_CTRead")
    Cli_CTWrite.Cli_CTWrite = GetFunction(snap7_hDLL,"Cli_CTWrite")
    Cli_CheckAsCompletion.Cli_CheckAsCompletion = GetFunction(snap7_hDLL,"Cli_CheckAsCompletion")
    Cli_ClearSessionPassword.Cli_ClearSessionPassword = GetFunction(snap7_hDLL,"Cli_ClearSessionPassword")
    Cli_Compress.Cli_Compress = GetFunction(snap7_hDLL,"Cli_Compress")
    Cli_Connect.Cli_Connect = GetFunction(snap7_hDLL,"Cli_Connect")
    Cli_ConnectTo.Cli_ConnectTo = GetFunction(snap7_hDLL,"Cli_ConnectTo")
    Cli_CopyRamToRom.Cli_CopyRamToRom = GetFunction(snap7_hDLL,"Cli_CopyRamToRom")
    Cli_Create.Cli_Create = GetFunction(snap7_hDLL,"Cli_Create")
    Cli_DBFill.Cli_DBFill = GetFunction(snap7_hDLL,"Cli_DBFill")
    Cli_DBGet.Cli_DBGet = GetFunction(snap7_hDLL,"Cli_DBGet")
    Cli_DBRead.Cli_DBRead = GetFunction(snap7_hDLL,"Cli_DBRead")
    Cli_DBWrite.Cli_DBWrite = GetFunction(snap7_hDLL,"Cli_DBWrite")
    Cli_Delete.Cli_Delete = GetFunction(snap7_hDLL,"Cli_Delete")
    Cli_Destroy.Cli_Destroy = GetFunction(snap7_hDLL,"Cli_Destroy")
    Cli_Disconnect.Cli_Disconnect = GetFunction(snap7_hDLL,"Cli_Disconnect")
    Cli_Download.Cli_Download = GetFunction(snap7_hDLL,"Cli_Download")
    Cli_EBRead.Cli_EBRead = GetFunction(snap7_hDLL,"Cli_EBRead")
    Cli_EBWrite.Cli_EBWrite = GetFunction(snap7_hDLL,"Cli_EBWrite")
    Cli_ErrorText.Cli_ErrorText = GetFunction(snap7_hDLL,"Cli_ErrorText")
    Cli_FullUpload.Cli_FullUpload = GetFunction(snap7_hDLL,"Cli_FullUpload")
    Cli_GetAgBlockInfo.Cli_GetAgBlockInfo = GetFunction(snap7_hDLL,"Cli_GetAgBlockInfo")
    Cli_GetConnected.Cli_GetConnected = GetFunction(snap7_hDLL,"Cli_GetConnected")
    Cli_GetCpInfo.Cli_GetCpInfo = GetFunction(snap7_hDLL,"Cli_GetCpInfo")
    Cli_GetCpuInfo.Cli_GetCpuInfo = GetFunction(snap7_hDLL,"Cli_GetCpuInfo")
    Cli_GetExecTime.Cli_GetExecTime = GetFunction(snap7_hDLL,"Cli_GetExecTime")
    Cli_GetLastError.Cli_GetLastError = GetFunction(snap7_hDLL,"Cli_GetLastError")
    Cli_GetOrderCode.Cli_GetOrderCode = GetFunction(snap7_hDLL,"Cli_GetOrderCode")
    Cli_GetParam.Cli_GetParam = GetFunction(snap7_hDLL,"Cli_GetParam")
    Cli_GetPduLength.Cli_GetPduLength = GetFunction(snap7_hDLL,"Cli_GetPduLength")
    Cli_GetPgBlockInfo.Cli_GetPgBlockInfo = GetFunction(snap7_hDLL,"Cli_GetPgBlockInfo")
    Cli_GetPlcDateTime.Cli_GetPlcDateTime = GetFunction(snap7_hDLL,"Cli_GetPlcDateTime")
    Cli_GetPlcStatus.Cli_GetPlcStatus = GetFunction(snap7_hDLL,"Cli_GetPlcStatus")
    Cli_GetProtection.Cli_GetProtection = GetFunction(snap7_hDLL,"Cli_GetProtection")
    Cli_IsoExchangeBuffer.Cli_IsoExchangeBuffer = GetFunction(snap7_hDLL,"Cli_IsoExchangeBuffer")
    Cli_ListBlocks.Cli_ListBlocks = GetFunction(snap7_hDLL,"Cli_ListBlocks")
    Cli_ListBlocksOfType.Cli_ListBlocksOfType = GetFunction(snap7_hDLL,"Cli_ListBlocksOfType")
    Cli_MBRead.Cli_MBRead = GetFunction(snap7_hDLL,"Cli_MBRead")
    Cli_MBWrite.Cli_MBWrite = GetFunction(snap7_hDLL,"Cli_MBWrite")
    Cli_PlcColdStart.Cli_PlcColdStart = GetFunction(snap7_hDLL,"Cli_PlcColdStart")
    Cli_PlcHotStart.Cli_PlcHotStart = GetFunction(snap7_hDLL,"Cli_PlcHotStart")
    Cli_PlcStop.Cli_PlcStop = GetFunction(snap7_hDLL,"Cli_PlcStop")
    Cli_ReadArea.Cli_ReadArea = GetFunction(snap7_hDLL,"Cli_ReadArea")
    Cli_ReadMultiVars.Cli_ReadMultiVars = GetFunction(snap7_hDLL,"Cli_ReadMultiVars")
    Cli_ReadSZL.Cli_ReadSZL = GetFunction(snap7_hDLL,"Cli_ReadSZL")
    Cli_ReadSZLList.Cli_ReadSZLList = GetFunction(snap7_hDLL,"Cli_ReadSZLList")
    Cli_SetAsCallback.Cli_SetAsCallback = GetFunction(snap7_hDLL,"Cli_SetAsCallback")
    Cli_SetConnectionParams.Cli_SetConnectionParams = GetFunction(snap7_hDLL,"Cli_SetConnectionParams")
    Cli_SetConnectionType.Cli_SetConnectionType = GetFunction(snap7_hDLL,"Cli_SetConnectionType")
    Cli_SetParam.Cli_SetParam = GetFunction(snap7_hDLL,"Cli_SetParam")
    Cli_SetPlcDateTime.Cli_SetPlcDateTime = GetFunction(snap7_hDLL,"Cli_SetPlcDateTime")
    Cli_SetPlcSystemDateTime.Cli_SetPlcSystemDateTime = GetFunction(snap7_hDLL,"Cli_SetPlcSystemDateTime")
    Cli_SetSessionPassword.Cli_SetSessionPassword = GetFunction(snap7_hDLL,"Cli_SetSessionPassword")
    Cli_TMRead.Cli_TMRead = GetFunction(snap7_hDLL,"Cli_TMRead")
    Cli_TMWrite.Cli_TMWrite = GetFunction(snap7_hDLL,"Cli_TMWrite")
    Cli_Upload.Cli_Upload = GetFunction(snap7_hDLL,"Cli_Upload")
    Cli_WaitAsCompletion.Cli_WaitAsCompletion = GetFunction(snap7_hDLL,"Cli_WaitAsCompletion")
    Cli_WriteArea.Cli_WriteArea = GetFunction(snap7_hDLL,"Cli_WriteArea")
    Cli_WriteMultiVars.Cli_WriteMultiVars = GetFunction(snap7_hDLL,"Cli_WriteMultiVars")
   
    Srv_ClearEvents.Srv_ClearEvents = GetFunction(snap7_hDLL,"Srv_ClearEvents")
    Srv_Create.Srv_Create = GetFunction(snap7_hDLL,"Srv_Create")
    Srv_Destroy.Srv_Destroy = GetFunction(snap7_hDLL,"Srv_Destroy")
    Srv_ErrorText.Srv_ErrorText = GetFunction(snap7_hDLL,"Srv_ErrorText")
    Srv_EventText.Srv_EventText = GetFunction(snap7_hDLL,"Srv_EventText")
    Srv_GetMask.Srv_GetMask = GetFunction(snap7_hDLL,"Srv_GetMask")
    Srv_GetParam.Srv_GetParam = GetFunction(snap7_hDLL,"Srv_GetParam")
    Srv_GetStatus.Srv_GetStatus = GetFunction(snap7_hDLL,"Srv_GetStatus")
    Srv_LockArea.Srv_LockArea = GetFunction(snap7_hDLL,"Srv_LockArea")
    Srv_PickEvent.Srv_PickEvent = GetFunction(snap7_hDLL,"Srv_PickEvent")
    Srv_RegisterArea.Srv_RegisterArea = GetFunction(snap7_hDLL,"Srv_RegisterArea")
    Srv_SetCpuStatus.Srv_SetCpuStatus = GetFunction(snap7_hDLL,"Srv_SetCpuStatus")
    Srv_SetEventsCallback.Srv_SetEventsCallback = GetFunction(snap7_hDLL,"Srv_SetEventsCallback")
    Srv_SetMask.Srv_SetMask = GetFunction(snap7_hDLL,"Srv_SetMask")
    Srv_SetParam.Srv_SetParam = GetFunction(snap7_hDLL,"Srv_SetParam")
    Srv_SetRWAreaCallback.Srv_SetRWAreaCallback = GetFunction(snap7_hDLL,"Srv_SetRWAreaCallback")
    Srv_SetReadEventsCallback.Srv_SetReadEventsCallback = GetFunction(snap7_hDLL,"Srv_SetReadEventsCallback")
    Srv_Start.Srv_Start = GetFunction(snap7_hDLL,"Srv_Start")
    Srv_StartTo.Srv_StartTo = GetFunction(snap7_hDLL,"Srv_StartTo")
    Srv_Stop.Srv_Stop = GetFunction(snap7_hDLL,"Srv_Stop")
    Srv_UnlockArea.Srv_UnlockArea = GetFunction(snap7_hDLL,"Srv_UnlockArea")
    Srv_UnregisterArea.Srv_UnregisterArea = GetFunction(snap7_hDLL,"Srv_UnregisterArea") 
   
    Par_AsBSend.Par_AsBSend = GetFunction(snap7_hDLL,"Par_AsBSend")
    Par_BRecv.Par_BRecv = GetFunction(snap7_hDLL,"Par_BRecv")
    Par_BSend.Par_BSend = GetFunction(snap7_hDLL,"Par_BSend")
    Par_CheckAsBRecvCompletion.Par_CheckAsBRecvCompletion = GetFunction(snap7_hDLL,"Par_CheckAsBRecvCompletion")
    Par_CheckAsBSendCompletion.Par_CheckAsBSendCompletion = GetFunction(snap7_hDLL,"Par_CheckAsBSendCompletion")
    Par_Create.Par_Create = GetFunction(snap7_hDLL,"Par_Create")
    Par_Destroy.Par_Destroy = GetFunction(snap7_hDLL,"Par_Destroy")
    Par_ErrorText.Par_ErrorText = GetFunction(snap7_hDLL,"Par_ErrorText")
    Par_GetLastError.Par_GetLastError = GetFunction(snap7_hDLL,"Par_GetLastError")
    Par_GetParam.Par_GetParam = GetFunction(snap7_hDLL,"Par_GetParam")
    Par_GetStats.Par_GetStats = GetFunction(snap7_hDLL,"Par_GetStats")
    Par_GetStatus.Par_GetStatus = GetFunction(snap7_hDLL,"Par_GetStatus")
    Par_GetTimes.Par_GetTimes = GetFunction(snap7_hDLL,"Par_GetTimes")
    Par_SetParam.Par_SetParam = GetFunction(snap7_hDLL,"Par_SetParam")
    Par_SetRecvCallback.Par_SetRecvCallback = GetFunction(snap7_hDLL,"Par_SetRecvCallback")
    Par_SetSendCallback.Par_SetSendCallback = GetFunction(snap7_hDLL,"Par_SetSendCallback")
    Par_Start.Par_Start = GetFunction(snap7_hDLL,"Par_Start")
    Par_StartTo.Par_StartTo = GetFunction(snap7_hDLL,"Par_StartTo")
    Par_Stop.Par_Stop = GetFunction(snap7_hDLL,"Par_Stop")
    Par_WaitAsBSendCompletion.Par_WaitAsBSendCompletion = GetFunction(snap7_hDLL,"Par_WaitAsBSendCompletion") 
   
    ProcedureReturn snap7_hDLL  ; 2024/12/08 changed from #True to snap7_hDLL
  EndProcedure
  
  ;- Text routines
  #TextLen  =  1024

  Procedure.s CliErrorText(Error.i)  
    Dim text.a(#TextLen - 1)  
    Cli_ErrorText(Error, @text(), #TextLen)  
    ProcedureReturn PeekS(@text(), -1, #PB_Ascii)
  EndProcedure 
  
  Procedure.s SrvErrorText(Error.i)   
    Dim text.a(#TextLen - 1)   
    Srv_ErrorText(Error, @text(), #TextLen) 
    ProcedureReturn PeekS(@text(), -1, #PB_Ascii)
  EndProcedure 
  
  Procedure.s ParErrorText(Error.i)   
    Dim text.a(#TextLen - 1)  
    Par_ErrorText(Error, @text(), #TextLen)   
    ProcedureReturn PeekS(@text(), -1, #PB_Ascii)
  EndProcedure 
  
  Procedure.s SrvEventText(*Event)   
    Dim text.a(#TextLen - 1)  
    Srv_EventText(*Event, @text(), #TextLen)   
    ProcedureReturn PeekS(@text(), -1, #PB_Ascii) 
  EndProcedure
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; UseModule 
  
  DisableExplicit
CompilerEndIf


; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 20
; Folding = --
; EnableXP
; CPU = 5