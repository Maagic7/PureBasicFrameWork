; ===========================================================================
; FILE : PbFw_Module_Libnodave.pb
; NAME : PureBasic Framework : Module Libnodave [libNoDave::]
; DESC : The Modul version of snap7.pbi
; DESC : Libnodave is an open source library for connecting with Siemens S7 PLC
; DESC : Attention Libondave is a 32Bit Dll! You have to use PureBasic x32 to work with Libnodave
; DESC : for x64 it is possible to use the modified version bei Jochen Kühner, libnodave_jfkmod64.dll
;  
; SOURCES: https://sourceforge.net/projects/libnodave/
;          https://github.com/dotnetprojects/DotNetSiemensPLCToolBoxLibrary/tree/master/externalDlls/libnodave    
; ===========================================================================
;
; AUTHOR   :  Stefan Maag (porting the libnodave.pbi to Module version) 
; DATE     :  2025/03/20
; VERSION  :  
; OS       :  all
; LICENCE  :  Libnodave is free software under the terms of the GNU Library 
;             General Public License
;             
; ===========================================================================
; ChangeLog: 
;{ 
;}
; ===========================================================================

;{ ----- Notes on libnodave! -----
; Attention Libondave is a 32Bit Dll! You have to use PureBasic x32 to work with Libnodave
;  for x64 it is possible to use the modified version bei Jochen Kühner, libnodave_jfkmod64.dll
;  https://github.com/dotnetprojects/DotNetSiemensPLCToolBoxLibrary/tree/master/externalDlls/libnodave

;/ Libnodave Module File for PureBasic V5.7x and higher
;/ PureBasic Version by Andreas Schweitzer
; PureBasic Module libNoDave by S.Maag 2025/02/20
;
; Part of Libnodave, a free communication libray For Siemens S7 200/300/400 via
; the MPI adapter 6ES7 972-0CA22-0XAC
; or  MPI adapter 6ES7 972-0CA23-0XAC
; or  TS  adapter 6ES7 972-0CA33-0XAC
; or  MPI adapter 6ES7 972-0CA11-0XAC,
; IBH/MHJ-NetLink or CPs 243, 343 and 443
; or VIPA Speed7 with builtin ethernet support.
;
; (C) Thomas Hergenhahn (thomas.hergenhahn@web.de) 2005
;
; Libnodave is free software; you can redistribute it and/or modify
; it under the terms of the GNU Library General Public License as published by
; the Free Software Foundation; either version 2, or (at your option)
; any later version.
;
; Libnodave is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU Library General Public License
; along with Libnodave; see the file COPYING.  If not, write to
; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;}

DeclareModule libNoDave

  EnableExplicit
  
  ; Optional Globals - uncomment it if you like
  ; Global DAVE_PH.i
  ; Global DAVE_DI.i
  ; Global DAVE_DC.i
  
  ; Protocol types to be used with newInterface:
  #daveProtoMPI           = 0    ; MPI for S7 300/400
  #daveProtoMPI2          = 1    ; MPI for S7 300/400, "Andrew's version"
  #daveProtoMPI3          = 2    ; MPI For S7 300/400, Step 7 Version, Not yet implemented
  #daveProtoPPI           = 10  ; PPI for S7 200
  #daveProtoAS511         = 20  ; S5 via programming Interface
  #daveProtoS7online      = 50  ; S7 using Siemens libraries & drivers for transport
  #daveProtoISOTCP        = 122  ; ISO over TCP
  #daveProtoISOTCP243     = 123  ; ISO over TCP with CP243
  #daveProtoMPI_IBH       = 223  ; MPI with IBH NetLink MPI to ethernet gateway
  #daveProtoPPI_IBH       = 224  ; PPI with IBH NetLink PPI to ethernet gateway
  #daveProtoUserTransport = 255  ; Libnodave will pass the PDUs of S7 Communication to user defined call back functions.
  
  ; ProfiBus speed constants:
  #daveSpeed9k    = 0
  #daveSpeed19k   = 1
  #daveSpeed187k  = 2
  #daveSpeed500k  = 3
  #daveSpeed1500k = 4
  #daveSpeed45k   = 5
  #daveSpeed93k   = 6
  
  ; S7 specific constants:
  #daveBlockType_OB  = "8"
  #daveBlockType_DB  = "A"
  #daveBlockType_SDB = "B"
  #daveBlockType_FC  = "C"
  #daveBlockType_SFC = "D"
  #daveBlockType_FB  = "E"
  #daveBlockType_SFB = "F"
  
  ; Use these constants for parameter "area" in daveReadBytes and daveWriteBytes
  #daveSysInfo       = $3  ; System info of 200 family
  #daveSysFlags      = $5  ; System flags of 200 family
  #daveAnaIn         = $6  ; analog inputs of 200 family
  #daveAnaOut        = $7  ; analog outputs of 200 family
  #daveP             = $80 ; direct access to peripheral adresses
  #daveInputs        = $81
  #daveOutputs       = $82
  #daveFlags         = $83
  #daveDB            = $84 ; data blocks
  #daveDI            = $85 ; instance data blocks
  #daveV             = $87 ; don't know what it is
  #daveCounter       = 28  ; S7 counters
  #daveTimer         = 29  ; S7 timers
  #daveCounter200    = 30  ; IEC counters (200 family)
  #daveTimer200      = 31  ; IEC timers (200 family)
  
  #daveOrderCodeSize = 21 ; Length of order code (MLFB number)
  
  ; Library specific:
  ;
  ; Result codes. Genarally, 0 means ok,
  ; >0 are results (also errors) reported by the PLC
  ; <0 means error reported by library code.
  ;
  #daveResOK                       = 0     ; means all ok
  #daveResNoPeripheralAtAddress    = 1     ; CPU tells there is no peripheral at address
  #daveResMultipleBitsNotSupported = 6     ; CPU tells it does not support to read a bit block with a
                                           ; length other than 1 bit.
  #daveResItemNotAvailable200      = 3     ; means a a piece of data is not available in the CPU, e.g.
                                           ; when trying to read a non existing DB or bit bloc of length<>1
                                           ; This code seems to be specific to 200 family.
  #daveResItemNotAvailable         = 10    ; means a a piece of data is not available in the CPU, e.g.
                                           ; when trying to read a non existing DB
  #daveAddressOutOfRange           = 5     ; means the data address is beyond the CPUs address range
  #daveWriteDataSizeMismatch       = 7     ; means the write data size doesn't fit item size
  #daveResCannotEvaluatePDU        = -123
  #daveResCPUNoData                = -124
  #daveUnknownError                = -125
  #daveEmptyResultError            = -126
  #daveEmptyResultSetError         = -127
  #daveResUnexpectedFunc           = -128
  #daveResUnknownDataUnitSize      = -129
  #daveResShortPacket              = -1024
  #daveResTimeout                  = -1025
  
  ; Max number of bytes in a single message.
  #daveMaxRawLen = 2048
  
  ; Some definitions for debugging:
  #daveDebugRawRead        = $1     ; Show the single bytes received
  #daveDebugSpecialChars   = $2     ; Show when special chars are read
  #daveDebugRawWrite       = $4     ; Show the single bytes written
  #daveDebugListReachables = $8     ; Show the steps when determine devices in MPI net
  #daveDebugInitAdapter    = $10    ; Show the steps when Initilizing the MPI adapter
  #daveDebugConnect        = $20    ; Show the steps when connecting a PLC
  #daveDebugPacket         = $40
  #daveDebugByte           = $80
  #daveDebugCompare        = $100
  #daveDebugExchange       = $200
  #daveDebugPDU            = $400   ; debug PDU handling
  #daveDebugUpload         = $800   ; debug PDU loading program blocks from PLC
  #daveDebugMPI            = $1000
  #daveDebugPrintErrors    = $2000  ; Print error messages
  #daveDebugPassive        = $4000
  #daveDebugErrorReporting = $8000
  #daveDebugOpen           = $8000
  #daveDebugAll            = $1FFFF
  
  ; Set and read debug level:
  Prototype daveSetDebug(level.i)
  Prototype.i daveGetDebug()
  
  Prototype.i daveStrerror(en.i)
  ; This function is still not useful without some code araound it, so I call it "internal"
  Prototype daveStringCopy(internalPointer.i, s.s)
  
  ; Setup a new interface structure using a handle to an open port or socket:
  Prototype.i daveNewInterface(fd1.i, fd2.i, ptrName.i, localMPI.i, protocol.i, speed.i)
  
  ; Setup a new connection structure using an initialized daveInterface and PLC's MPI address.
  ; Note: The parameter di must have been obtained from daveNewinterface.
  Prototype.i daveNewConnection(di.i, mpi.i, Rack.i, Slot.i)
  
  ; PDU handling:
  ; PDU is the central structure present in S7 communication.
  ; It is composed of a 10 or 12 byte header,a parameter block and a data block.
  ; When reading or writing values, the data field is itself composed of a data
  ; header followed by payload data
  ;
  ; retrieve the answer:
  ; Note: The parameter dc must have been obtained from daveNewConnection.
  Prototype.i daveGetResponse(dc.i)
  
  ; send PDU to PLC
  ; Note: The parameter dc must have been obtained from daveNewConnection,
  ;       The parameter pdu must have been obtained from daveNewPDU.
  Prototype.i daveSendMessage(dc.i, pdu.i)
  
  ;******
  ;
  ;Utilities:
  ;
  ;****
  ;*
  ; Hex dump PDU:
  ;
  Prototype daveDumpPDU(pdu.i) 
  ; Hex dump. Write the name followed by len bytes written in hex and a newline:
  Prototype daveDump(name.s, pdu.i, length.i)
  
  ; names for PLC objects. This is again the intenal function. Use the wrapper code below.
  Prototype.i daveAreaName(en.i)
  Prototype.i daveBlockName(en.i)
  
  ; swap functions. They change the byte order, if byte order on the computer differs from
  ; PLC byte order:
  Prototype.l daveSwapIed_16(x.l)
  Prototype.l daveSwapIed_32(x.l)
  
  ; Data conversion convenience functions. The older set has been removed.
  ; Newer conversion routines. As the terms WORD, INT, INTEGER etc have different meanings
  ; for users of different programming languages and compilers, I choose to provide a new
  ; set of conversion routines named according to the bit length of the value used. The 'U'
  ; or 'S' stands for unsigned or signed.
  ;
  ; Get a value from the position b points to. B is typically a pointer to a buffer that has
  ; been filled with daveReadBytes:
  Prototype.f toPLCfloat(f.f)
  Prototype.l daveToPLCfloat(f.f)
  
  ; Copy and convert value of 8,16,or 32 bit, signed or unsigned at position pos
  ; from internal buffer:
  Prototype.i daveGetS8from(ptrBuffer.i)
  Prototype.i daveGetU8from(ptrBuffer.i)
  Prototype.i daveGetS16from(ptrBuffer.i)
  Prototype.i daveGetU16from(ptrBuffer.i)
  Prototype.i daveGetS32from(ptrBuffer.i)
  Prototype.q daveGetU32from(ptrBuffer.i)
  Prototype.f daveGetFloatfrom(ptrBuffer.i)
  
  ; Copy and convert a value of 8,16,or 32 bit, signed or unsigned from internal buffer. These
  ; functions increment an internal buffer position. This buffer position is set to zero by
  ; daveReadBytes, daveReadBits, daveReadSZL.
  Prototype.i daveGetS8(dc.i)
  Prototype.i daveGetU8(dc.i)
  Prototype.i daveGetS16(dc.i)
  Prototype.i daveGetU16(dc.i)
  Prototype.i daveGetS32(dc.i)
  Prototype.q daveGetU32(dc.i)
  Prototype.f daveGetFloat(dc.i)
  
  ; Read a value of 8,16,or 32 bit, signed or unsigned at position pos from internal buffer:
  Prototype.i daveGetS8At(dc.i, pos.i)
  Prototype.i daveGetU8At(dc.i, pos.i)
  Prototype.i daveGetS16At(dc.i, pos.i)
  Prototype.i daveGetU16At(dc.i, pos.i)
  Prototype.i daveGetS32At(dc.i, pos.i)
  Prototype.q daveGetU32At(dc.i, pos.i)
  Prototype.f daveGetFloatAt(dc.i, pos.i)
  
  ; Copy and convert a value of 8,16,or 32 bit, signed or unsigned into a buffer. The buffer
  ; is usually used by daveWriteBytes, daveWriteBits later.
  Prototype.i davePut8(ptrBuffer.i, value.i)
  Prototype.i davePut16(ptrBuffer.i, value.i)
  Prototype.i davePut32(ptrBuffer.i, value.i)
  Prototype.l davePutFloat(ptrBuffer.i, value.f)
  
  ; Copy and convert a value of 8,16,or 32 bit, signed or unsigned to position pos of a buffer.
  ; The buffer is usually used by daveWriteBytes, daveWriteBits later.
  Prototype.i davePut8At(ptrBuffer.i, pos.i, value.i)
  Prototype.i davePut16At(ptrBuffer.i, pos.i, value.i)
  Prototype.i davePut32At(ptrBuffer.i, pos.i, value.i)
  Prototype.i davePutFloatAt(ptrBuffer.i, pos.i, value.f)
  
  ; Takes a timer value and converts it into seconds:
  Prototype.f daveGetSeconds(dc.i)
  Prototype.f daveGetSecondsAt(dc.i, pos.i)
  
  ; Takes a counter value and converts it to integer:
  Prototype.i daveGetCounterValue(dc.i)
  Prototype.i daveGetCounterValueAt(dc.i, pos.i)
  
  ; Get the order code (MLFB number) from a PLC. Does NOT work with 200 family.
  Prototype.i daveGetOrderCode(en.i, ptrBuffer.i)
  
  ; Connect to a PLC.
  Prototype.i daveConnectPLC(dc.i)
  
  ; Read a value or a block of values from PLC.
  Prototype.i daveReadBytes(dc.i, area .i, areaNumber.i, start.i, numBytes.i, buffer.i)
   
  ; Read a long block of values from PLC. Long means too long to transport in a single PDU.
  Prototype.i daveManyReadBytes(dc.i, area.i, areaNumber.i, start.i, numBytes.i, buffer.i)
  
  ; Write a value or a block of values to PLC.
  Prototype.i daveWriteBytes(dc.i, area.i, areaNumber.i, start.i, numBytes.i, ptrBuffer.i)
  
  ; Write a long block of values to PLC. Long means too long to transport in a single PDU.
  Prototype.i daveWriteManyBytes(dc.i, area.i, areaNumber.i, start.i, numBytes.i, ptrBuffer.i)
  
  ; Read a bit from PLC. numBytes must be exactly one with all PLCs tested.
  ; Start is calculated as 8*byte number+bit number.
  Prototype.i daveReadBits(dc.i, area.i, areaNumber.i, start.i, numBytes.i, buffer.i)
  
  ; Write a bit to PLC. numBytes must be exactly one with all PLCs tested.
  Prototype.i daveWriteBits(dc.i, area.i, areaNumber.i, start.i, numBytes.i, ptrBuffer.i)
  
  ; Set a bit in PLC to 1.
  Prototype.i daveSetBit(dc.i, area.i, areaNumber.i, start.i, byteAddress.i, bitAddress.i)
  
  ; Set a bit in PLC to 0.
  Prototype.i daveClrBit(dc.i, area.i, areaNumber.i, start.i, byteAddress.i, bitAddress.i)
  
  ; Read a diagnostic list (SZL) from PLC. Does NOT work with 200 family.
  Prototype.i daveReadSZL(dc.i, ID.i, index.i, ptrBuffer.i, buflen.i)
  
  Prototype.i daveListBlocksOfType(dc.i, type.i, ptrBuffer.i)
  Prototype.i daveListBlocks(dc.i, ptrBuffer.i)
  Prototype.i DaveGetBlockInfo(dc.i, ptrBuffer.i, type.i, number.i)
  
  Prototype.i daveGetProgramBlock(dc.i, blockType.i, number.i, ptrBuffer.i, ptrLength.i)
  
  ; Start or Stop a PLC:
  Prototype.i daveStart(dc.i)
  Prototype.i daveStop(dc.i)
  
  ; Set outputs (digital or analog ones) of an S7-200 that is in stop mode:
  Prototype.i daveForce200(dc.i, area.i, start.i, value.i)
  
  ; Initialize a multivariable read request.
  ; The parameter PDU must have been obtained from daveNew PDU:
  Prototype davePrepareReadRequest(dc.i, pdu.i)
  
  ; Add a new variable to a prepared request:
  Prototype daveAddVarToReadRequest(pdu.i, area.i, areaNumber.i, start.i, numBytes.i)
  
  ; Executes the entire request:
  Prototype.i daveExecReadRequest(dc.i, pdu.i, rs.i)
  
  ; Use the n-th result. This lets the functions daveGet<data type> work on that part of the
  ; internal buffer that contains the n-th result:
  Prototype.i daveUseResult(dc.i, rs.i, resultNumber.i)
  
  ; Frees the memory occupied by single results in the result structure. After that, you can reuse
  ; the resultSet in another call to daveExecReadRequest.
  Prototype daveFreeResults(rs.i)
  
  ; Adds a new bit variable to a prepared request. As with daveReadBits, numBytes must be one for
  ; all tested PLCs.
  Prototype daveAddBitVarToReadRequest(pdu.i, area.i, areaNumber.i, start.i, numBytes.i)
  
  ; Initialize a multivariable write request.
  ; The parameter PDU must have been obtained from daveNew PDU:
  Prototype davePrepareWriteRequest(dc.i, pdu.i)
  
  ; Add a new variable to a prepared write request:
  Prototype daveAddVarToWriteRequest(pdu.i, area.i, areaNumber.i, start.i, numBytes.i, ptrBuffer.i)
  
  ; Add a new bit variable to a prepared write request:
  Prototype daveAddBitVarToWriteRequest(pdu.i, area.i, areaNumber.i, start.i, numBytes.i, ptrBuffer.i)
  
  ; Execute the entire write request:
  Prototype.i daveExecWriteRequest(dc.i, pdu.i, rs.i)
  
  ; Initialize an MPI Adapter or NetLink Ethernet MPI gateway.
  ; While some protocols do not need this, I recommend to allways use it. It will do nothing if
  ; the protocol doesn't need it. But you can change protocols without changing your program code.
  Prototype.i daveInitAdapter(di.i)
  
  ; Disconnect from a PLC. While some protocols do not need this, I recommend to allways use it.
  ; It will do nothing if the protocol doesn't need it. But you can change protocols without
  ; changing your program code.
  Prototype.i daveDisconnectPLC(dc.i)
  
  ; Disconnect from an MPI Adapter or NetLink Ethernet MPI gateway.
  ; While some protocols do not need this, I recommend to allways use it.
  ; It will do nothing if the protocol doesn't need it. But you can change protocols without
  ; changing your program code.
  Prototype.i daveDisconnectAdapter(dc.i)
  
  ; List nodes on an MPI or Profibus Network:
  Prototype.i daveListReachablePartners(dc.i, ptrBuffer.i)
  
  ; Set/change the timeout for an interface:
  Prototype daveSetTimeout(di.i, maxTime.i)
  
  ; Read the timeout setting for an interface:
  Prototype.i daveGetTimeout(di.i)
  
  ; Get the name of an interface. Do NOT use this, but the wrapper function defined below!
  Prototype.i daveGetName(en.i)
  
  ; Get the MPI address of a connection.
  Prototype.i daveGetMPIAdr(dc.i)
  
  ; Get the length (in bytes) of the last data received on a connection.
  Prototype.i daveGetAnswLen(dc.i)
  
  ; Get the maximum length of a communication packet (PDU).
  ; This value depends on your CPU and connection type. It is negociated in daveConnectPLC.
  ; A simple read can read MaxPDULen-18 bytes.
  Prototype.i daveGetMaxPDULen(dc.i)
  
  ; Reserve memory for a resultSet and get a handle to it:
  Prototype.i daveNewResultSet()
  
  ; Destroy handles to daveInterface, daveConnections, PDUs and resultSets
  ; Free the memory reserved for them.
  Prototype daveFree(item.i)
  
  ; Reserve memory for a PDU and get a handle to it:
  Prototype.i daveNewPDU()
  
  ; Get the error code of the n-th single result in a result set:
  Prototype.i daveGetErrorOfResult(resultSet.i, resultNumber.i)
  
  Prototype.i daveForceDisconnectIBH(di.i, src.i, dest.i, mpi.i)
  
  ; Helper functions to open serial ports and IP connections. You can use others if you want and
  ; pass their results to daveNewInterface.
  ;
  ; Open a serial port using name, baud rate and parity. Everything else is set automatically:
  Prototype.i setPort(portName.s, baudrate.s, parity.b)
  
  ; Open a TCP/IP connection using port number (1099 for NetLink, 102 for ISO over TCP) and
  ; IP address. You must use an IP address, NOT a hostname!
  Prototype.i openSocket(port.i, ptrStrPeer.i)
  
  ; Open an access point. This is a name in you can add in the "set Programmer/PLC interface" dialog.
  ; To the access point, you can assign an interface like MPI adapter, CP511 etc.
  Prototype.i openS7online(ptrStrPeer.i)
  
  ; Close connections and serial ports opened with above functions:
  Prototype.i closePort(fh.i)
  
  ; Close handle opende by opens7online:
  Prototype.i closeS7online(fh.i)
  
  ; Read Clock time from PLC:
  Prototype.i daveReadPLCTime(dc.i)
  
  ; set clock to a value given by user
  Prototype.i daveSetPLCTime(dc.i, ptrTimestamp.i)
  
  ; set clock to PC system clock:
  Prototype.i daveSetPLCTimeToSystime(dc.i)
  
  ; BCD conversions:
  Prototype.i daveToBCD(dc.i)
  Prototype.i daveFromBCD(dc.i)
  
  Global daveSetDebug.daveSetDebug
    
  Global daveGetDebug.daveGetDebug
    
  Global daveStrerror.daveStrerror
  Global daveStringCopy.daveStringCopy
    
  Global daveNewConnection.daveNewConnection
    
  Global daveGetResponse.daveGetResponse
  Global daveSendMessage.daveSendMessage
    
  Global daveDumpPDU.daveDumpPDU 
  Global daveDump.daveDump
    
  Global daveAreaName.daveAreaName 
  Global daveBlockName.daveBlockName 
    
  Global daveSwapIed_16.daveSwapIed_16 
  Global daveSwapIed_32.daveSwapIed_32 
  Global toPLCfloat.toPLCfloat 
  Global daveToPLCfloat.daveToPLCfloat 
    
  Global daveGetS8from.daveGetS8from 
  Global daveGetU8from.daveGetU8from 
  Global daveGetS16from.daveGetS16from 
  Global daveGetU16from.daveGetU16from
  Global daveGetS32from.daveGetS32from 
  Global daveGetU32from.daveGetU32from 
  Global daveGetFloatfrom.daveGetFloatfrom 
    
  Global daveGetS8.daveGetS8
  Global daveGetU8.daveGetU8 
  Global daveGetS16.daveGetS16
  Global daveGetU16.daveGetU16
  Global daveGetS32.daveGetS32
  Global daveGetU32.daveGetU32
  Global daveGetFloat.daveGetFloat
    
  Global daveGetS8At.daveGetS8At
  Global daveGetU8At.daveGetU8At
  Global daveGetS16At.daveGetS16At
  Global daveGetU16At.daveGetU16At
  Global daveGetS32At.daveGetS32At
  Global daveGetU32At.daveGetU32At
  Global daveGetFloatAt.daveGetFloatAt
    
  Global davePut8.davePut8
  Global davePut16.davePut16
  Global davePut32.davePut32
  Global davePutFloat.davePutFloat
    
  Global davePut8At.davePut8At
  Global davePut16At.davePut16At
  Global davePut32At.davePut32At
  Global davePutFloatAt.davePutFloatAt
    
  Global daveGetSeconds.daveGetSeconds
  Global daveGetSecondsAt.daveGetSecondsAt
    
  Global daveGetCounterValue.daveGetCounterValue
  Global daveGetCounterValueAt.daveGetCounterValueAt
    
  Global daveGetOrderCode.daveGetOrderCode
    
  Global daveConnectPLC.daveConnectPLC
    
  Global daveReadBytes.daveReadBytes
  Global daveManyReadBytes.daveManyReadBytes
    
  Global daveWriteBytes.daveWriteBytes
  Global daveWriteManyBytes.daveWriteManyBytes
    
  Global daveReadBits.daveReadBits
  Global daveWriteBits.daveWriteBits
    
  Global daveSetBit.daveSetBit
  Global daveClrBit.daveClrBit
    
  Global daveReadSZL.daveReadSZL
    
  Global daveListBlocksOfType.daveListBlocksOfType
  Global daveListBlocks.daveListBlocks
  Global DaveGetBlockInfo.DaveGetBlockInfo
    
  Global daveGetProgramBlock.daveGetProgramBlock
    
  Global daveStart.daveStart
  Global daveStop.daveStop
    
  Global daveForce200.daveForce200
    
  Global davePrepareReadRequest.davePrepareReadRequest
  Global daveAddVarToReadRequest.daveAddVarToReadRequest
  Global daveExecReadRequest.daveExecReadRequest
  Global daveUseResult.daveUseResult
  Global daveFreeResults.daveFreeResults
  Global daveAddBitVarToReadRequest.daveAddBitVarToReadRequest
  Global davePrepareWriteRequest.davePrepareWriteRequest
  Global daveAddVarToWriteRequest.daveAddVarToWriteRequest
  Global daveAddBitVarToWriteRequest.daveAddBitVarToWriteRequest
  Global daveExecWriteRequest.daveExecWriteRequest
  Global daveInitAdapter.daveInitAdapter
  Global daveDisconnectPLC.daveDisconnectPLC
  Global daveDisconnectAdapter.daveDisconnectAdapter
  Global daveListReachablePartners.daveListReachablePartners
    
  Global daveSetTimeout.daveSetTimeout
  Global daveGetTimeout.daveGetTimeout
  Global daveGetName.daveGetName
  Global daveGetMPIAdr.daveGetMPIAdr
    
  Global daveGetAnswLen.daveGetAnswLen
  Global daveGetMaxPDULen.daveGetMaxPDULen
    
  Global daveNewResultSet.daveNewResultSet
  Global daveFree.daveFree
    
  Global daveNewPDU.daveNewPDU
  Global daveGetErrorOfResult.daveGetErrorOfResult
  Global daveForceDisconnectIBH.daveForceDisconnectIBH
    
  Global setPort.setPort
  Global openSocket.openSocket
  Global openS7online.openS7online
  Global closePort.closePort
  Global closeS7online.closeS7online
   
  Global daveReadPLCTime.daveReadPLCTime
  Global daveSetPLCTime.daveSetPLCTime
  Global daveSetPLCTimeToSystime.daveSetPLCTimeToSystime
  Global daveToBCD.daveToBCD
  Global daveFromBCD.daveFromBCD
  
EndDeclareModule

Module libNoDave
  ;- ----------------------------------------
  ;- Module Code
  ;- ----------------------------------------
  EnableExplicit 
    
  CompilerSelect  #PB_Compiler_OS 
      
    CompilerCase #PB_OS_Windows
      
      CompilerIf #PB_Compiler_32Bit
        #_libnodaveFileName = "libnodave.dll"
        ; #_libnodaveFileName = "libnodave_jfkmod.dll"
        
      CompilerElse
         #_libnodaveFileName ="libnodave_jfkmod64.dll"
         
      CompilerEndIf
      
    CompilerCase #PB_OS_Linux
       CompilerError "Module Libnodave: Linux support is not integrated at the moment"
     
    CompilerCase #PB_OS_MacOS
      CompilerError "libnodave PLC library do not support Mac OSX"
      
  CompilerEndSelect
  
  Global hDLL.i 

  Procedure dave_CloseDLL()
    If hDLL <> 0
      If IsLibrary(hDLL)
        CloseLibrary(hDLL)
      EndIf
      hDLL = 0
    EndIf
  EndProcedure
  
  Procedure.i dave_OpenDLL()
  
    hDLL = OpenLibrary(#PB_Any, #_libnodaveFileName)
    
    If hDLL = 0
      MessageRequester("Error!", "Can not load " + #_libnodaveFileName)
      ProcedureReturn #False
    EndIf
    
    daveSetDebug.daveSetDebug = GetFunction(hDLL, "daveSetDebug")
    
    daveGetDebug.daveGetDebug = GetFunction(hDLL, "daveGetDebug")
    
    daveStrerror.daveStrerror = GetFunction(hDLL, "daveStrerror")
    daveStringCopy.daveStringCopy = GetFunction(hDLL, "daveStringCopy")
    
    daveNewConnection.daveNewConnection = GetFunction(hDLL, "daveNewConnection")
    
    daveGetResponse.daveGetResponse = GetFunction(hDLL, "daveGetResponse")
    daveSendMessage.daveSendMessage = GetFunction(hDLL, "daveSendMessage")
    
    daveDumpPDU.daveDumpPDU = GetFunction(hDLL, "daveDumpPDU")
    daveDump.daveDump = GetFunction(hDLL, "daveDump")
    
    daveAreaName.daveAreaName = GetFunction(hDLL, "daveAreaName")
    daveBlockName.daveBlockName = GetFunction(hDLL, "daveBlockName")
    
    daveSwapIed_16.daveSwapIed_16 = GetFunction(hDLL, "daveSwapIed_16")
    daveSwapIed_32.daveSwapIed_32 = GetFunction(hDLL, "daveSwapIed_32")
    toPLCfloat.toPLCfloat = GetFunction(hDLL, "toPLCfloat")
    daveToPLCfloat.daveToPLCfloat = GetFunction(hDLL, "daveToPLCfloat")
    
    daveGetS8from.daveGetS8from = GetFunction(hDLL, "daveGetS8from")
    daveGetU8from.daveGetU8from = GetFunction(hDLL, "daveGetU8from")
    daveGetS16from.daveGetS16from = GetFunction(hDLL, "daveGetS16from")
    daveGetU16from.daveGetU16from = GetFunction(hDLL, "daveGetU16from")
    daveGetS32from.daveGetS32from = GetFunction(hDLL, "daveGetS32from")
    daveGetU32from.daveGetU32from = GetFunction(hDLL, "daveGetU32from")
    daveGetFloatfrom.daveGetFloatfrom = GetFunction(hDLL, "daveGetFloatfrom")
    
    daveGetS8.daveGetS8 = GetFunction(hDLL, "daveGetS8")
    daveGetU8.daveGetU8 = GetFunction(hDLL, "daveGetU8")
    daveGetS16.daveGetS16 = GetFunction(hDLL, "daveGetS16")
    daveGetU16.daveGetU16 = GetFunction(hDLL, "daveGetU16")
    daveGetS32.daveGetS32 = GetFunction(hDLL, "daveGetS32")
    daveGetU32.daveGetU32 = GetFunction(hDLL, "daveGetU32")
    daveGetFloat.daveGetFloat = GetFunction(hDLL, "daveGetFloat")
    
    daveGetS8At.daveGetS8At = GetFunction(hDLL, "daveGetS8At")
    daveGetU8At.daveGetU8At = GetFunction(hDLL, "daveGetU8At")
    daveGetS16At.daveGetS16At = GetFunction(hDLL, "daveGetS16At")
    daveGetU16At.daveGetU16At = GetFunction(hDLL, "daveGetU16At")
    daveGetS32At.daveGetS32At = GetFunction(hDLL, "daveGetS32At")
    daveGetU32At.daveGetU32At = GetFunction(hDLL, "daveGetU32At")
    daveGetFloatAt.daveGetFloatAt = GetFunction(hDLL, "daveGetFloatAt")
    
    davePut8.davePut8 = GetFunction(hDLL, "davePut8")
    davePut16.davePut16 = GetFunction(hDLL, "davePut16")
    davePut32.davePut32 = GetFunction(hDLL, "davePut32")
    davePutFloat.davePutFloat = GetFunction(hDLL, "davePutFloat")
    
    davePut8At.davePut8At = GetFunction(hDLL, "davePut8At")
    davePut16At.davePut16At = GetFunction(hDLL, "davePut16At")
    davePut32At.davePut32At = GetFunction(hDLL, "davePut32At")
    davePutFloatAt.davePutFloatAt = GetFunction(hDLL, "davePutFloatAt")
    
    daveGetSeconds.daveGetSeconds = GetFunction(hDLL, "daveGetSeconds")
    daveGetSecondsAt.daveGetSecondsAt = GetFunction(hDLL, "daveGetSecondsAt")
    
    daveGetCounterValue.daveGetCounterValue = GetFunction(hDLL, "daveGetCounterValue")
    daveGetCounterValueAt.daveGetCounterValueAt = GetFunction(hDLL, "daveGetCounterValueAt")
    
    daveGetOrderCode.daveGetOrderCode = GetFunction(hDLL, "daveGetOrderCode")
    
    daveConnectPLC.daveConnectPLC = GetFunction(hDLL, "daveConnectPLC")
    
    daveReadBytes.daveReadBytes = GetFunction(hDLL, "daveReadBytes")
    daveManyReadBytes.daveManyReadBytes = GetFunction(hDLL, "daveManyReadBytes")
    
    daveWriteBytes.daveWriteBytes = GetFunction(hDLL, "daveWriteBytes")
    daveWriteManyBytes.daveWriteManyBytes = GetFunction(hDLL, "daveWriteManyBytes")
    
    daveReadBits.daveReadBits = GetFunction(hDLL, "daveReadBits")
    daveWriteBits.daveWriteBits = GetFunction(hDLL, "daveWriteBits")
    
    daveSetBit.daveSetBit = GetFunction(hDLL, "daveSetBit")
    daveClrBit.daveClrBit = GetFunction(hDLL, "daveClrBit")
    
    daveReadSZL.daveReadSZL = GetFunction(hDLL, "daveReadSZL")
    
    daveListBlocksOfType.daveListBlocksOfType = GetFunction(hDLL, "daveListBlocksOfType")
    daveListBlocks.daveListBlocks = GetFunction(hDLL, "daveListBlocks")
    DaveGetBlockInfo.DaveGetBlockInfo = GetFunction(hDLL, "DaveGetBlockInfo")
    
    daveGetProgramBlock.daveGetProgramBlock = GetFunction(hDLL, "daveGetProgramBlock")
    
    daveStart.daveStart = GetFunction(hDLL, "daveStart")
    daveStop.daveStop = GetFunction(hDLL, "daveStop")
    
    daveForce200.daveForce200 = GetFunction(hDLL, "daveForce200")
    
    davePrepareReadRequest.davePrepareReadRequest = GetFunction(hDLL, "davePrepareReadRequest")
    daveAddVarToReadRequest.daveAddVarToReadRequest = GetFunction(hDLL, "daveAddVarToReadRequest")
    daveExecReadRequest.daveExecReadRequest = GetFunction(hDLL, "daveExecReadRequest")
    daveUseResult.daveUseResult = GetFunction(hDLL, "daveUseResult")
    daveFreeResults.daveFreeResults = GetFunction(hDLL, "daveFreeResults")
    daveAddBitVarToReadRequest.daveAddBitVarToReadRequest = GetFunction(hDLL, "daveAddBitVarToReadRequest")
    davePrepareWriteRequest.davePrepareWriteRequest = GetFunction(hDLL, "davePrepareWriteRequest")
    daveAddVarToWriteRequest.daveAddVarToWriteRequest = GetFunction(hDLL, "daveAddVarToWriteRequest")
    daveAddBitVarToWriteRequest.daveAddBitVarToWriteRequest = GetFunction(hDLL, "daveAddBitVarToWriteRequest")
    daveExecWriteRequest.daveExecWriteRequest = GetFunction(hDLL, "daveExecWriteRequest")
    daveInitAdapter.daveInitAdapter = GetFunction(hDLL, "daveInitAdapter")
    daveDisconnectPLC.daveDisconnectPLC = GetFunction(hDLL, "daveDisconnectPLC")
    daveDisconnectAdapter.daveDisconnectAdapter = GetFunction(hDLL, "daveDisconnectAdapter")
    daveListReachablePartners.daveListReachablePartners = GetFunction(hDLL, "daveListReachablePartners")
    
    daveSetTimeout.daveSetTimeout = GetFunction(hDLL, "daveSetTimeout")
    daveGetTimeout.daveGetTimeout = GetFunction(hDLL, "daveGetTimeout")
    daveGetName.daveGetName = GetFunction(hDLL, "daveGetName")
    daveGetMPIAdr.daveGetMPIAdr = GetFunction(hDLL, "daveGetMPIAdr")
    
    daveGetAnswLen.daveGetAnswLen = GetFunction(hDLL, "daveGetAnswLen")
    daveGetMaxPDULen.daveGetMaxPDULen = GetFunction(hDLL, "daveGetMaxPDULen")
    
    daveNewResultSet.daveNewResultSet = GetFunction(hDLL, "daveNewResultSet")
    daveFree.daveFree = GetFunction(hDLL, "daveFree")
    
    daveNewPDU.daveNewPDU = GetFunction(hDLL, "daveNewPDU")
    daveGetErrorOfResult.daveGetErrorOfResult = GetFunction(hDLL, "daveGetErrorOfResult")
    daveForceDisconnectIBH.daveForceDisconnectIBH = GetFunction(hDLL, "daveForceDisconnectIBH")
    
    setPort.setPort = GetFunction(hDLL, "setPort")
    openSocket.openSocket = GetFunction(hDLL, "openSocket")
    openS7online.openS7online = GetFunction(hDLL, "openS7online")
    closePort.closePort = GetFunction(hDLL, "closePort")
    closeS7online.closeS7online = GetFunction(hDLL, "closeS7online")
    daveReadPLCTime.daveReadPLCTime = GetFunction(hDLL, "daveReadPLCTime")
    daveSetPLCTime.daveSetPLCTime = GetFunction(hDLL, "daveSetPLCTime")
    daveSetPLCTimeToSystime.daveSetPLCTimeToSystime = GetFunction(hDLL, "daveSetPLCTimeToSystime")
    daveToBCD.daveToBCD = GetFunction(hDLL, "daveToBCD")
    daveFromBCD.daveFromBCD = GetFunction(hDLL, "daveFromBCD")
    
    ProcedureReturn #True
  EndProcedure
  
EndModule


; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 40
; Folding = --
; EnableXP
; CPU = 5