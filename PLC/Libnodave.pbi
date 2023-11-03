;/ Libnodave Include File for PureBasic V4.xx and higher
;/ PureBasic Version by Andreas Schweitzer
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
;
;
EnableExplicit

Global DAVE_LIB.l
; Optional Globals - uncomment it if you like
; Global DAVE_PH.l
; Global DAVE_DI.l
; Global DAVE_DC.l

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

DAVE_LIB = OpenLibrary(#PB_Any, "libnodave.dll")

If DAVE_LIB
  ;MessageRequester("lib", Str(DAVE_LIB),0)
  
  ; Set and read debug level:
  Prototype daveSetDebug(level.l)
  Global daveSetDebug.daveSetDebug = GetFunction(DAVE_LIB, "daveSetDebug")
  Prototype.l daveGetDebug()
  Global daveGetDebug.daveGetDebug = GetFunction(DAVE_LIB, "daveGetDebug")

  ; You may wonder what sense it might make to set debug level, as you cannot see
  ; messages when you opened excel or some VB application from Windows GUI.
  ; You can invoke Excel from the console or from a batch file with:
  ; <myPathToExcel>\Excel.Exe <MyPathToXLS-File>VBATest.XLS >ExcelOut
  ; This will start Excel with VBATest.XLS and all debug messages (and a few from Excel itself)
  ; go into the file ExcelOut.
  ;
  ; Error code to message string conversion:
  ; Call this function to get an explanation for error codes returned by other functions.
  ;
  ; The folowing doesn't work properly. A VB string is something different from a pointer To char:
  ;
  ; Private Declare Function daveStrerror Lib "libnodave.dll" Alias "daveStrerror" (ByVal en As Long) As String
  Prototype.l daveStrerror(en.l)
  Global daveStrerror.daveStrerror = GetFunction(DAVE_LIB, "daveStrerror")

  ; So, I added another function to libnodave wich copies the text into a VB String.
  ; This function is still not useful without some code araound it, so I call it "internal"
  Prototype daveStringCopy(internalPointer.l, s.s)
  Global daveStringCopy.daveStringCopy = GetFunction(DAVE_LIB, "daveStringCopy")

  ; Setup a new interface structure using a handle to an open port or socket:
  Prototype.l daveNewInterface(fd1.l, fd2.l, ptrName.l, localMPI.l, protocol.l, speed.l)
  Global daveNewInterface.daveNewInterface = GetFunction(DAVE_LIB, "daveNewInterface")

  ; Setup a new connection structure using an initialized daveInterface and PLC's MPI address.
  ; Note: The parameter di must have been obtained from daveNewinterface.
  Prototype.l daveNewConnection(di.l, mpi.l, Rack.l, Slot.l)
  Global daveNewConnection.daveNewConnection = GetFunction(DAVE_LIB, "daveNewConnection")

  ; PDU handling:
  ; PDU is the central structure present in S7 communication.
  ; It is composed of a 10 or 12 byte header,a parameter block and a data block.
  ; When reading or writing values, the data field is itself composed of a data
  ; header followed by payload data
  ;
  ; retrieve the answer:
  ; Note: The parameter dc must have been obtained from daveNewConnection.
  Prototype.l daveGetResponse(dc.l)
  Global daveGetResponse.daveGetResponse = GetFunction(DAVE_LIB, "daveGetResponse")

  ; send PDU to PLC
  ; Note: The parameter dc must have been obtained from daveNewConnection,
  ;       The parameter pdu must have been obtained from daveNewPDU.
  Prototype.l daveSendMessage(dc.l, pdu.l)
  Global daveSendMessage.daveSendMessage = GetFunction(DAVE_LIB, "daveSendMessage")

  ;******
  ;
  ;Utilities:
  ;
  ;****
  ;*
  ; Hex dump PDU:
  ;
  Prototype daveDumpPDU(pdu.l)
  Global daveDumpPDU.daveDumpPDU = GetFunction(DAVE_LIB, "daveDumpPDU")

  ; Hex dump. Write the name followed by len bytes written in hex and a newline:
  Prototype daveDump(name.s, pdu.l, length.l)
  Global daveDump.daveDump = GetFunction(DAVE_LIB, "daveDump")

  ; names for PLC objects. This is again the intenal function. Use the wrapper code below.
  Prototype.l daveAreaName(en.l)
  Global daveAreaName.daveAreaName = GetFunction(DAVE_LIB, "daveAreaName")
  Prototype.l daveBlockName(en.l)
  Global daveBlockName.daveBlockName = GetFunction(DAVE_LIB, "daveBlockName")

  ; swap functions. They change the byte order, if byte order on the computer differs from
  ; PLC byte order:
  Prototype.l daveSwapIed_16(x.l)
  Global daveSwapIed_16.daveSwapIed_16 = GetFunction(DAVE_LIB, "daveSwapIed_16")
  Prototype.l daveSwapIed_32(x.l)
  Global daveSwapIed_32.daveSwapIed_32 = GetFunction(DAVE_LIB, "daveSwapIed_32")

  ; Data conversion convenience functions. The older set has been removed.
  ; Newer conversion routines. As the terms WORD, INT, INTEGER etc have different meanings
  ; for users of different programming languages and compilers, I choose to provide a new
  ; set of conversion routines named according to the bit length of the value used. The 'U'
  ; or 'S' stands for unsigned or signed.
  ;
  ; Get a value from the position b points to. B is typically a pointer to a buffer that has
  ; been filled with daveReadBytes:
  Prototype.f toPLCfloat(f.f)
  Global toPLCfloat.toPLCfloat = GetFunction(DAVE_LIB, "toPLCfloat")
  Prototype.l daveToPLCfloat(f.f)
  Global daveToPLCfloat.daveToPLCfloat = GetFunction(DAVE_LIB, "daveToPLCfloat")

  ; Copy and convert value of 8,16,or 32 bit, signed or unsigned at position pos
  ; from internal buffer:
  Prototype.l daveGetS8from(ptrBuffer.i)
  Global daveGetS8from.daveGetS8from = GetFunction(DAVE_LIB, "daveGetS8from")
  Prototype.l daveGetU8from(ptrBuffer.i)
  Global daveGetU8from.daveGetU8from = GetFunction(DAVE_LIB, "daveGetU8from")
  Prototype.l daveGetS16from(ptrBuffer.i)
  Global daveGetS16from.daveGetS16from = GetFunction(DAVE_LIB, "daveGetS16from")
  Prototype.l daveGetU16from(ptrBuffer.i)
  Global daveGetU16from.daveGetU16from = GetFunction(DAVE_LIB, "daveGetU16from")
  Prototype.l daveGetS32from(ptrBuffer.i)
  Global daveGetS32from.daveGetS32from = GetFunction(DAVE_LIB, "daveGetS32from")
;   Prototype.l daveGetU32from(*ptrBuffer.i) ; This doesn't work.
;   Global daveGetU32from.daveGetU32from = GetFunction(DAVE_LIB, "daveGetU32from")
  Prototype.f daveGetFloatfrom(ptrBuffer.i)
  Global daveGetFloatfrom.daveGetFloatfrom = GetFunction(DAVE_LIB, "daveGetFloatfrom")

  ; Copy and convert a value of 8,16,or 32 bit, signed or unsigned from internal buffer. These
  ; functions increment an internal buffer position. This buffer position is set to zero by
  ; daveReadBytes, daveReadBits, daveReadSZL.
  Prototype.l daveGetS8(dc.l)
  Global daveGetS8.daveGetS8 = GetFunction(DAVE_LIB, "daveGetS8")
  Prototype.l daveGetU8(dc.l)
  Global daveGetU8.daveGetU8 = GetFunction(DAVE_LIB, "daveGetU8")
  Prototype.l daveGetS16(dc.l)
  Global daveGetS16.daveGetS16 = GetFunction(DAVE_LIB, "daveGetS16")
  Prototype.l daveGetU16(dc.l)
  Global daveGetU16.daveGetU16 = GetFunction(DAVE_LIB, "daveGetU16")
  Prototype.l daveGetS32(dc.l)
  Global daveGetS32.daveGetS32 = GetFunction(DAVE_LIB, "daveGetS32")
;   Prototype.l daveGetU32(dc.l) ; This doesn't work.
;   Global daveGetU32.daveGetU32 = GetFunction(DAVE_LIB, "daveGetU32")
  Prototype.f daveGetFloat(dc.l)
  Global daveGetFloat.daveGetFloat = GetFunction(DAVE_LIB, "daveGetFloat")

  ; Read a value of 8,16,or 32 bit, signed or unsigned at position pos from internal buffer:
  Prototype.l daveGetS8At(dc.l, pos.l)
  Global daveGetS8At.daveGetS8At = GetFunction(DAVE_LIB, "daveGetS8At")
  Prototype.l daveGetU8At(dc.l, pos.l)
  Global daveGetU8At.daveGetU8At = GetFunction(DAVE_LIB, "daveGetU8At")
  Prototype.l daveGetS16At(dc.l, pos.l)
  Global daveGetS16At.daveGetS16At = GetFunction(DAVE_LIB, "daveGetS16At")
  Prototype.l daveGetU16At(dc.l, pos.l)
  Global daveGetU16At.daveGetU16At = GetFunction(DAVE_LIB, "daveGetU16At")
  Prototype.l daveGetS32At(dc.l, pos.l)
  Global daveGetS32At.daveGetS32At = GetFunction(DAVE_LIB, "daveGetS32At")
;   Prototype.l daveGetU32At(dc.l, pos.l) ; This doesn't work.
;   Global daveGetU32At.daveGetU32At = GetFunction(DAVE_LIB, "daveGetU32At")
  Prototype.f daveGetFloatAt(dc.l, pos.l)
  Global daveGetFloatAt.daveGetFloatAt = GetFunction(DAVE_LIB, "daveGetFloatAt")

  ; Copy and convert a value of 8,16,or 32 bit, signed or unsigned into a buffer. The buffer
  ; is usually used by daveWriteBytes, daveWriteBits later.
  Prototype.l davePut8(ptrBuffer.i, value.l)
  Global davePut8.davePut8 = GetFunction(DAVE_LIB, "davePut8")
  Prototype.l davePut16(ptrBuffer.i, value.l)
  Global davePut16.davePut16 = GetFunction(DAVE_LIB, "davePut16")
  Prototype.l davePut32(ptrBuffer.i, value.l)
  Global davePut32.davePut32 = GetFunction(DAVE_LIB, "davePut32")
  Prototype.l davePutFloat(ptrBuffer.i, value.f)
  Global davePutFloat.davePutFloat = GetFunction(DAVE_LIB, "davePutFloat")

  ; Copy and convert a value of 8,16,or 32 bit, signed or unsigned to position pos of a buffer.
  ; The buffer is usually used by daveWriteBytes, daveWriteBits later.
  Prototype.l davePut8At(ptrBuffer.i, pos.l, value.l)
  Global davePut8At.davePut8At = GetFunction(DAVE_LIB, "davePut8At")
  Prototype.l davePut16At(ptrBuffer.i, pos.l, value.l)
  Global davePut16At.davePut16At = GetFunction(DAVE_LIB, "davePut16At")
  Prototype.l davePut32At(ptrBuffer.i, pos.l, value.l)
  Global davePut32At.davePut32At = GetFunction(DAVE_LIB, "davePut32At")
  Prototype.l davePutFloatAt(ptrBuffer.i, pos.l, value.f)
  Global davePutFloatAt.davePutFloatAt = GetFunction(DAVE_LIB, "davePutFloatAt")

  ; Takes a timer value and converts it into seconds:
  Prototype.f daveGetSeconds(dc.l)
  Global daveGetSeconds.daveGetSeconds = GetFunction(DAVE_LIB, "daveGetSeconds")
  Prototype.f daveGetSecondsAt(dc.l, pos.l)
  Global daveGetSecondsAt.daveGetSecondsAt = GetFunction(DAVE_LIB, "daveGetSecondsAt")

  ; Takes a counter value and converts it to integer:
  Prototype.l daveGetCounterValue(dc.l)
  Global daveGetCounterValue.daveGetCounterValue = GetFunction(DAVE_LIB, "daveGetCounterValue")
  Prototype.l daveGetCounterValueAt(dc.l, pos.l)
  Global daveGetCounterValueAt.daveGetCounterValueAt = GetFunction(DAVE_LIB, "daveGetCounterValueAt")

  ; Get the order code (MLFB number) from a PLC. Does NOT work with 200 family.
  Prototype.l daveGetOrderCode(en.l, ptrBuffer.i)
  Global daveGetOrderCode.daveGetOrderCode = GetFunction(DAVE_LIB, "daveGetOrderCode")

  ; Connect to a PLC.
  Prototype.l daveConnectPLC(dc.l)
  Global daveConnectPLC.daveConnectPLC = GetFunction(DAVE_LIB, "daveConnectPLC")

  ; Read a value or a block of values from PLC.
  Prototype.l daveReadBytes(dc.l, area .l, areaNumber.l, start.l, numBytes.l, buffer.l)
  Global daveReadBytes.daveReadBytes = GetFunction(DAVE_LIB, "daveReadBytes")

  ; Read a long block of values from PLC. Long means too long to transport in a single PDU.
  Prototype.l daveManyReadBytes(dc.l, area.l, areaNumber.l, start.l, numBytes.l, buffer.l)
  Global daveManyReadBytes.daveManyReadBytes = GetFunction(DAVE_LIB, "daveManyReadBytes")

  ; Write a value or a block of values to PLC.
  Prototype.l daveWriteBytes(dc.l, area.l, areaNumber.l, start.l, numBytes.l, ptrBuffer.i)
  Global daveWriteBytes.daveWriteBytes = GetFunction(DAVE_LIB, "daveWriteBytes")

  ; Write a long block of values to PLC. Long means too long to transport in a single PDU.
  Prototype.l daveWriteManyBytes(dc.l, area.l, areaNumber.l, start.l, numBytes.l, ptrBuffer.i)
  Global daveWriteManyBytes.daveWriteManyBytes = GetFunction(DAVE_LIB, "daveWriteManyBytes")

  ; Read a bit from PLC. numBytes must be exactly one with all PLCs tested.
  ; Start is calculated as 8*byte number+bit number.
  Prototype.l daveReadBits(dc.l, area.l, areaNumber.l, start.l, numBytes.l, buffer.l)
  Global daveReadBits.daveReadBits = GetFunction(DAVE_LIB, "daveReadBits")

  ; Write a bit to PLC. numBytes must be exactly one with all PLCs tested.
  Prototype.l daveWriteBits(dc.l, area.l, areaNumber.l, start.l, numBytes.l, ptrBuffer.i)
  Global daveWriteBits.daveWriteBits = GetFunction(DAVE_LIB, "daveWriteBits")

  ; Set a bit in PLC to 1.
  Prototype.l daveSetBit(dc.l, area.l, areaNumber.l, start.l, byteAddress.l, bitAddress.l)
  Global daveSetBit.daveSetBit = GetFunction(DAVE_LIB, "daveSetBit")

  ; Set a bit in PLC to 0.
  Prototype.l daveClrBit(dc.l, area.l, areaNumber.l, start.l, byteAddress.l, bitAddress.l)
  Global daveClrBit.daveClrBit = GetFunction(DAVE_LIB, "daveClrBit")

  ; Read a diagnostic list (SZL) from PLC. Does NOT work with 200 family.
  Prototype.l daveReadSZL(dc.l, ID.l, index.l, ptrBuffer.i, buflen.l)
  Global daveReadSZL.daveReadSZL = GetFunction(DAVE_LIB, "daveReadSZL")

  Prototype.l daveListBlocksOfType(dc.l, type.l, ptrBuffer.i)
  Global daveListBlocksOfType.daveListBlocksOfType = GetFunction(DAVE_LIB, "daveListBlocksOfType")
  Prototype.l daveListBlocks(dc.l, ptrBuffer.i)
  Global daveListBlocks.daveListBlocks = GetFunction(DAVE_LIB, "daveListBlocks")
  Prototype.l DaveGetBlockInfo(dc.l, ptrBuffer.i, type.l, number.l)
  Global DaveGetBlockInfo.DaveGetBlockInfo = GetFunction(DAVE_LIB, "DaveGetBlockInfo")

  Prototype.l daveGetProgramBlock(dc.l, blockType.l, number.l, ptrBuffer.i, ptrLength.i)
  Global daveGetProgramBlock.daveGetProgramBlock = GetFunction(DAVE_LIB, "daveGetProgramBlock")

  ; Start or Stop a PLC:
  Prototype.l daveStart(dc.l)
  Global daveStart.daveStart = GetFunction(DAVE_LIB, "daveStart")
  Prototype.l daveStop(dc.l)
  Global daveStop.daveStop = GetFunction(DAVE_LIB, "daveStop")

  ; Set outputs (digital or analog ones) of an S7-200 that is in stop mode:
  Prototype.l daveForce200(dc.l, area.l, start.l, value.l)
  Global daveForce200.daveForce200 = GetFunction(DAVE_LIB, "daveForce200")

  ; Initialize a multivariable read request.
  ; The parameter PDU must have been obtained from daveNew PDU:
  Prototype davePrepareReadRequest(dc.l, pdu.l)
  Global davePrepareReadRequest.davePrepareReadRequest = GetFunction(DAVE_LIB, "davePrepareReadRequest")

  ; Add a new variable to a prepared request:
  Prototype daveAddVarToReadRequest(pdu.l, area.l, areaNumber.l, start.l, numBytes.l)
  Global daveAddVarToReadRequest.daveAddVarToReadRequest = GetFunction(DAVE_LIB, "daveAddVarToReadRequest")

  ; Executes the entire request:
  Prototype.l daveExecReadRequest(dc.l, pdu.l, rs.l)
  Global daveExecReadRequest.daveExecReadRequest = GetFunction(DAVE_LIB, "daveExecReadRequest")

  ; Use the n-th result. This lets the functions daveGet<data type> work on that part of the
  ; internal buffer that contains the n-th result:
  Prototype.l daveUseResult(dc.l, rs.l, resultNumber.l)
  Global daveUseResult.daveUseResult = GetFunction(DAVE_LIB, "daveUseResult")

  ; Frees the memory occupied by single results in the result structure. After that, you can reuse
  ; the resultSet in another call to daveExecReadRequest.
  Prototype daveFreeResults(rs.l)
  Global daveFreeResults.daveFreeResults = GetFunction(DAVE_LIB, "daveFreeResults")

  ; Adds a new bit variable to a prepared request. As with daveReadBits, numBytes must be one for
  ; all tested PLCs.
  Prototype daveAddBitVarToReadRequest(pdu.l, area.l, areaNumber.l, start.l, numBytes.l)
  Global daveAddBitVarToReadRequest.daveAddBitVarToReadRequest = GetFunction(DAVE_LIB, "daveAddBitVarToReadRequest")

  ; Initialize a multivariable write request.
  ; The parameter PDU must have been obtained from daveNew PDU:
  Prototype davePrepareWriteRequest(dc.l, pdu.l)
  Global davePrepareWriteRequest.davePrepareWriteRequest = GetFunction(DAVE_LIB, "davePrepareWriteRequest")

  ; Add a new variable to a prepared write request:
  Prototype daveAddVarToWriteRequest(pdu.l, area.l, areaNumber.l, start.l, numBytes.l, ptrBuffer.i)
  Global daveAddVarToWriteRequest.daveAddVarToWriteRequest = GetFunction(DAVE_LIB, "daveAddVarToWriteRequest")

  ; Add a new bit variable to a prepared write request:
  Prototype daveAddBitVarToWriteRequest(pdu.l, area.l, areaNumber.l, start.l, numBytes.l, ptrBuffer.i)
  Global daveAddBitVarToWriteRequest.daveAddBitVarToWriteRequest = GetFunction(DAVE_LIB, "daveAddBitVarToWriteRequest")

  ; Execute the entire write request:
  Prototype.l daveExecWriteRequest(dc.l, pdu.l, rs.l)
  Global daveExecWriteRequest.daveExecWriteRequest = GetFunction(DAVE_LIB, "daveExecWriteRequest")

  ; Initialize an MPI Adapter or NetLink Ethernet MPI gateway.
  ; While some protocols do not need this, I recommend to allways use it. It will do nothing if
  ; the protocol doesn't need it. But you can change protocols without changing your program code.
  Prototype.l daveInitAdapter(di.l)
  Global daveInitAdapter.daveInitAdapter = GetFunction(DAVE_LIB, "daveInitAdapter")

  ; Disconnect from a PLC. While some protocols do not need this, I recommend to allways use it.
  ; It will do nothing if the protocol doesn't need it. But you can change protocols without
  ; changing your program code.
  Prototype.l daveDisconnectPLC(dc.l)
  Global daveDisconnectPLC.daveDisconnectPLC = GetFunction(DAVE_LIB, "daveDisconnectPLC")

  ; Disconnect from an MPI Adapter or NetLink Ethernet MPI gateway.
  ; While some protocols do not need this, I recommend to allways use it.
  ; It will do nothing if the protocol doesn't need it. But you can change protocols without
  ; changing your program code.
  Prototype.l daveDisconnectAdapter(dc.l)
  Global daveDisconnectAdapter.daveDisconnectAdapter = GetFunction(DAVE_LIB, "daveDisconnectAdapter")

  ; List nodes on an MPI or Profibus Network:
  Prototype.l daveListReachablePartners(dc.l, ptrBuffer.i)
  Global daveListReachablePartners.daveListReachablePartners = GetFunction(DAVE_LIB, "daveListReachablePartners")

  ; Set/change the timeout for an interface:
  Prototype daveSetTimeout(di.l, maxTime.l)
  Global daveSetTimeout.daveSetTimeout = GetFunction(DAVE_LIB, "daveSetTimeout")

  ; Read the timeout setting for an interface:
  Prototype.l daveGetTimeout(di.l)
  Global daveGetTimeout.daveGetTimeout = GetFunction(DAVE_LIB, "daveGetTimeout")

  ; Get the name of an interface. Do NOT use this, but the wrapper function defined below!
  Prototype.l daveGetName(en.l)
  Global daveGetName.daveGetName = GetFunction(DAVE_LIB, "daveGetName")

  ; Get the MPI address of a connection.
  Prototype.l daveGetMPIAdr(dc.l)
  Global daveGetMPIAdr.daveGetMPIAdr = GetFunction(DAVE_LIB, "daveGetMPIAdr")

  ; Get the length (in bytes) of the last data received on a connection.
  Prototype.l daveGetAnswLen(dc.l)
  Global daveGetAnswLen.daveGetAnswLen = GetFunction(DAVE_LIB, "daveGetAnswLen")

  ; Get the maximum length of a communication packet (PDU).
  ; This value depends on your CPU and connection type. It is negociated in daveConnectPLC.
  ; A simple read can read MaxPDULen-18 bytes.
  Prototype.l daveGetMaxPDULen(dc.l)
  Global daveGetMaxPDULen.daveGetMaxPDULen = GetFunction(DAVE_LIB, "daveGetMaxPDULen")

  ; Reserve memory for a resultSet and get a handle to it:
  Prototype.l daveNewResultSet()
  Global daveNewResultSet.daveNewResultSet = GetFunction(DAVE_LIB, "daveNewResultSet")

  ; Destroy handles to daveInterface, daveConnections, PDUs and resultSets
  ; Free the memory reserved for them.
  Prototype daveFree(item.l)
  Global daveFree.daveFree = GetFunction(DAVE_LIB, "daveFree")

  ; Reserve memory for a PDU and get a handle to it:
  Prototype.l daveNewPDU()
  Global daveNewPDU.daveNewPDU = GetFunction(DAVE_LIB, "daveNewPDU")

  ; Get the error code of the n-th single result in a result set:
  Prototype.l daveGetErrorOfResult(resultSet.l, resultNumber.l)
  Global daveGetErrorOfResult.daveGetErrorOfResult = GetFunction(DAVE_LIB, "daveGetErrorOfResult")

  Prototype.l daveForceDisconnectIBH(di.l, src.l, dest.l, mpi.l)
  Global daveForceDisconnectIBH.daveForceDisconnectIBH = GetFunction(DAVE_LIB, "daveForceDisconnectIBH")

  ; Helper functions to open serial ports and IP connections. You can use others if you want and
  ; pass their results to daveNewInterface.
  ;
  ; Open a serial port using name, baud rate and parity. Everything else is set automatically:
  Prototype.l setPort(portName.s, baudrate.s, parity.b)
  Global setPort.setPort = GetFunction(DAVE_LIB, "setPort")

  ; Open a TCP/IP connection using port number (1099 for NetLink, 102 for ISO over TCP) and
  ; IP address. You must use an IP address, NOT a hostname!
  Prototype.l openSocket(port.l, ptrStrPeer.i)
  Global openSocket.openSocket = GetFunction(DAVE_LIB, "openSocket")

  ; Open an access point. This is a name in you can add in the "set Programmer/PLC interface" dialog.
  ; To the access point, you can assign an interface like MPI adapter, CP511 etc.
  Prototype.l openS7online(ptrStrPeer.i)
  Global openS7online.openS7online = GetFunction(DAVE_LIB, "openS7online")

  ; Close connections and serial ports opened with above functions:
  Prototype.l closePort(fh.l)
  Global closePort.closePort = GetFunction(DAVE_LIB, "closePort")

  ; Close handle opende by opens7online:
  Prototype.l closeS7online(fh.l)
  Global closeS7online.closeS7online = GetFunction(DAVE_LIB, "closeS7online")

  ; Read Clock time from PLC:
  Prototype.l daveReadPLCTime(dc.l)
  Global daveReadPLCTime.daveReadPLCTime = GetFunction(DAVE_LIB, "daveReadPLCTime")

  ; set clock to a value given by user
  Prototype.l daveSetPLCTime(dc.l, ptrTimestamp.i)
  Global daveSetPLCTime.daveSetPLCTime = GetFunction(DAVE_LIB, "daveSetPLCTime")

  ; set clock to PC system clock:
  Prototype.l daveSetPLCTimeToSystime(dc.l)
  Global daveSetPLCTimeToSystime.daveSetPLCTimeToSystime = GetFunction(DAVE_LIB, "daveSetPLCTimeToSystime")

  ; BCD conversions:
  Prototype.l daveToBCD(dc.l)
  Global daveToBCD.daveToBCD = GetFunction(DAVE_LIB, "daveToBCD")
  Prototype.l daveFromBCD(dc.l)
  Global daveFromBCD.daveFromBCD = GetFunction(DAVE_LIB, "daveFromBCD")

EndIf

DisableExplicit

; *****************************************************
;  End of interface declarations and helper functions.
; *****************************************************
; IDE Options = PureBasic 5.61 (Windows - x86)
; CursorPosition = 143
; FirstLine = 123
; EnableXP