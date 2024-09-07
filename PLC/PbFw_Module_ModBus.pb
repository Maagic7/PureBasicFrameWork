; ===========================================================================
; FILE : PbFw_Module_ModBus.pb
; NAME : PureBasic Framework : Module ModBus [ModBus::]
; DESC : This is a implementation from scratch according to the 
; DESC : MODBUS Application Protocol Specification V1.1b3 from 2012
; DESC : 
; DESC : 
; DESC :
; SOURCES: offical Modbus_Application_Protocol_V1_1b3.pdf from April 2012
;          https://www.modbus.org/docs/Modbus_Application_Protocol_V1_1b3.pdf
;
;          https://www.purebasic.fr/english/viewtopic.php?t=85050
;          https://github.com/stephane/libmodbus
;          https://www.simplymodbus.ca/FAQ.htm
; ===========================================================================
;
; AUTHOR   :  Stefan Maag 
; DATE     :  2023/04/28
; VERSION  :  0.12  Brainstorming Version
; COMPILER :  all
; OS       :  all
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 2024/09/04 S.Maag addes RegisterSet Functions for Modbus Client/Slave
;  2024/09/03 S.Maag TCP/RTU GetADU_Header send/receive
;}
; ===========================================================================


;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------
;XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
;XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::      Debug Module

; XIncludeFile "..\Modules\PbFw_Module_Bits.pb"               ; Bits::    Extended Bit Operation
XIncludeFile "..\Modules\PbFw_Module_RealTimeCounter.pb"    ; RTC::     RealTimeCounter

;- ----------------------------------------------------------------------
;-   Documentation
;- ----------------------------------------------------------------------

;{ Documentation

; ModBus Functions  
  ; 01: Read Coils
  ; 02: Read Discret Inputs
  ; 03: Read Holding OutRegisters
  ; 04: Read Input OutRegisters
  ; 05: Write Singel Coil
  ; 06: Write Single Register
  ; 15: Write Multiple Coil
  ; 16: Write Multiple Register

  ; --------------------------------------------------------------------------------
  ;- READ_COILS : 01
  ; --------------------------------------------------------------------------------  
  ;         Implement Modbus function code 01.
  ;         "This function code is used to read from 1 to 2000 contiguous status of
  ;         coils in a remote device. The Request PDU specifies the starting
  ;         address, i.e. the address of the first coil specified, And the number
  ;         of coils. In the PDU Coils are addressed starting at zero. Therefore
  ;         coils numbered 1-16 are addressed As 0-15.
  ;         The coils in the response message are packed As one coil per bit of the
  ;         Data field. Status is indicated As 1= ON And 0= OFF. The LSB of the
  ;         first Data byte contains the output addressed in the query. The other
  ;         coils follow toward the high order End of this byte, And from low order
  ;         To high order in subsequent bytes.
  ;         If the returned output quantity is Not a multiple of eight, the
  ;         remaining bits in the final Data byte will be padded With zeros (toward
  ;         the high order End of the byte). The Byte Count field specifies the
  ;         quantity of complete bytes of Data."
  ;         -- MODBUS Application Protocol Specification V1.1b3, chapter 6.1
  ;     The request PDU With function code 01 must be 5 bytes:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Starting address 2
  ;         Quantity         2
  ;         ================ ===============
  ;     The PDU can unpacked To this:
  ;     ..
  ;         Note: the backslash in the bytes below are escaped using an extra back
  ;         slash. Without escaping the bytes aren't printed correctly in the HTML
  ;         output of this docs.
  ;         To work With the bytes in Python you need To remove the escape sequences.
  ;         `b'\\x01\\x00d` -> `b\x01\x00d`
  ;     .. code-block:: python
  ;         >>> struct.unpack('>BHH', b'\\x01\\x00d\\x00\\x03')
  ;         (1, 100, 3)
  ;     The reponse PDU varies in length, depending on the request. Each 8 coils
  ;     require 1 byte. The amount of bytes needed represent status of the coils To
  ;     can be calculated With: bytes = ceil(quantity / 8). This response
  ;     contains ceil(3 / 8) = 1 byte To describe the status of the coils. The
  ;     Structure of a compleet response PDU looks like this:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Byte count       1
  ;         Coil status      n
  ;         ================ ===============
  ;     Assume the status of 102 is 0, 101 is 1 And 100 is also 1. This is binary
  ;     011 which is decimal 3.
  ;     The PDU can packed like this::
  ;         >>> struct.pack('>BBB', function_code, byte_count, 3)
  ;         b'\\x01\\x01\\x03'
  
  ; --------------------------------------------------------------------------------
  ;-  READ_DISCRETE_INPUTS : 02
  ; -------------------------------------------------------------------------------- 
  ;         Implement Modbus function code 02.
  ;         "This function code is used to read from 1 to 2000 contiguous status of
  ;         discrete inputs in a remote device. The Request PDU specifies the
  ;         starting address, i.e. the address of the first input specified, And
  ;         the number of inputs. In the PDU Discrete Inputs are addressed starting
  ;         at zero. Therefore Discrete inputs numbered 1-16 are addressed As
  ;         0-15.
  ;         The discrete inputs in the response message are packed As one input per
  ;         bit of the Data field.  Status is indicated As 1= ON; 0= OFF. The LSB
  ;         of the first Data byte contains the input addressed in the query. The
  ;         other inputs follow toward the high order End of this byte, And from
  ;         low order To high order in subsequent bytes.
  ;         If the returned input quantity is Not a multiple of eight, the
  ;         remaining bits in the final d ata byte will be padded With zeros
  ;         (toward the high order End of the byte). The Byte Count field specifies
  ;         the quantity of complete bytes of Data."
  ;         -- MODBUS Application Protocol Specification V1.1b3, chapter 6.2
  ;     The request PDU With function code 02 must be 5 bytes:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Starting address 2
  ;         Quantity         2
  ;         ================ ===============
  ;     The PDU can unpacked To this:
  ;     ..
  ;         Note: the backslash in the bytes below are escaped using an extra back
  ;         slash. Without escaping the bytes aren't printed correctly in the HTML
  ;         output of this docs.
  ;         To work With the bytes in Python you need To remove the escape sequences.
  ;         `b'\\x01\\x00d` -> `b\x01\x00d`
  ;     .. code-block:: python
  ;         >>> struct.unpack('>BHH', b'\\x02\\x00d\\x00\\x03')
  ;         (2, 100, 3)
  ;     The reponse PDU varies in length, depending on the request. 8 inputs
  ;     require 1 byte. The amount of bytes needed represent status of the inputs
  ;     To can be calculated With: bytes = ceil(quantity / 8). This response
  ;     contains ceil(3 / 8) = 1 byte To describe the status of the inputs. The
  ;     Structure of a compleet response PDU looks like this:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Byte count       1
  ;         Coil status      n
  ;         ================ ===============
  ;     Assume the status of 102 is 0, 101 is 1 And 100 is also 1. This is binary
  ;     011 which is decimal 3.
  ;     The PDU can packed like this::
  ;         >>> struct.pack('>BBB', function_code, byte_count, 3)
  ;         b'\\x02\\x01\\x03'
  
  ; --------------------------------------------------------------------------------
  ;- READ_HOLDING_REGISTERS : 03
  ; --------------------------------------------------------------------------------  
  ;         Implement Modbus function code 03.
  ;         "This function code is used to read the contents of a contiguous block
  ;         of holding registers in a remote device. The Request PDU specifies the
  ;         starting register address And the number of registers. In the PDU
  ;         OutRegisters are addressed starting at zero. Therefore registers numbered
  ;         1-16 are addressed As 0-15.
  ;         The register Data in the response message are packed As two bytes per
  ;         register, With the binary contents right justified within each byte.
  ;         For each register, the first byte contains the high order bits And the
  ;         second contains the low order bits."
  ;         -- MODBUS Application Protocol Specification V1.1b3, chapter 6.3
  ;     The request PDU With function code 03 must be 5 bytes:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Starting address 2
  ;         Quantity         2
  ;         ================ ===============
  ;     The PDU can unpacked To this:
  ;     ..
  ;         Note: the backslash in the bytes below are escaped using an extra back
  ;         slash. Without escaping the bytes aren't printed correctly in the HTML
  ;         output of this docs.
  ;         To work With the bytes in Python you need To remove the escape sequences.
  ;         `b'\\x01\\x00d` -> `b\x01\x00d`
  ;     .. code-block:: python
  ;         >>> struct.unpack('>BHH', b'\\x03\\x00d\\x00\\x03')
  ;         (3, 100, 3)
  ;     The reponse PDU varies in length, depending on the request. By Default,
  ;     holding registers are 16 bit (2 bytes) values. So values of 3 holding
  ;     registers is expressed in 2 * 3 = 6 bytes.
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Byte count       1
  ;         Register values  Quantity * 2
  ;         ================ ===============
  ;     Assume the value of 100 is 8, 101 is 0 And 102 is also 15.
  ;     The PDU can packed like this::
  ;         >>> Data = [8, 0, 15]
  ;         >>> struct.pack('>BBHHH', function_code, Len(Data) * 2, *data)
  ;         b'\\x03\\x06\\x00\\x08\\x00\\x00\\x00\\x0f'
  
  ; --------------------------------------------------------------------------------
  ;- READ_INPUT_REGISTERS : 04
  ; -------------------------------------------------------------------------------- 
  ;         Implement Modbus function code 04.
  ;         "This function code is used to read from 1 to 125 contiguous input
  ;         registers in a remote device. The Request PDU specifies the starting
  ;         register address And the number of registers. In the PDU OutRegisters are
  ;         addressed starting at zero. Therefore input registers numbered 1-16 are
  ;         addressed As 0-15.
  ;         The register Data in the response message are packed As two bytes per
  ;         register, With the binary contents right justified within each byte.
  ;         For each register, the first byte contains the high order bits And the
  ;         second contains the low order bits."
  ;         -- MODBUS Application Protocol Specification V1.1b3, chapter 6.4
  ;     The request PDU With function code 04 must be 5 bytes:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Starting address 2
  ;         Quantity         2
  ;         ================ ===============
  ;     The PDU can unpacked To this:
  ;     ..
  ;         Note: the backslash in the bytes below are escaped using an extra back
  ;         slash. Without escaping the bytes aren't printed correctly in the HTML
  ;         output of this docs.
  ;         To work With the bytes in Python you need To remove the escape sequences.
  ;         `b'\\x01\\x00d` -> `b\x01\x00d`
  ;     .. code-block:: python
  ;         >>> struct.unpack('>BHH', b'\\x04\\x00d\\x00\\x03')
  ;         (4, 100, 3)
  ;     The reponse PDU varies in length, depending on the request. By Default,
  ;     holding registers are 16 bit (2 bytes) values. So values of 3 holding
  ;     registers is expressed in 2 * 3 = 6 bytes.
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Byte count       1
  ;         Register values  Quantity * 2
  ;         ================ ===============
  ;     Assume the value of 100 is 8, 101 is 0 And 102 is also 15.
  ;     The PDU can packed like this::
  ;         >>> Data = [8, 0, 15]
  ;         >>> struct.pack('>BBHHH', function_code, Len(Data) * 2, *data)
  ;         b'\\x04\\x06\\x00\\x08\\x00\\x00\\x00\\x0f'
  
  ; --------------------------------------------------------------------------------
  ;- WRITE_SINGLE_COIL : 5
  ; --------------------------------------------------------------------------------         
  ;        Implement Modbus function code 05.
  ;         "This function code is used to write a single output to either ON or
  ;         OFF in a remote device. The requested ON/OFF state is specified by a
  ;         constant in the request Data field. A value of FF 00 hex requests the
  ;         output To be ON.  A value of 00 00 requests it To be OFF. All other
  ;         values are illegal And will Not affect the output.
  ;         The Request PDU specifies the address of the coil To be forced. Coils
  ;         are addressed starting at zero. Therefore coil numbered 1 is addressed
  ;         As 0.  The requested ON/OFF state is specified by a constant in the
  ;         Coil Value field. A value of 0XFF00 requests the coil To be ON. A value
  ;         of 0X0000 requests the coil To be off. All other values are illegal And
  ;         will Not affect the coil.
  ;         The normal response is an echo of the request, returned after the coil
  ;         state has been written."
  ;         -- MODBUS Application Protocol Specification V1.1b3, chapter 6.5
  ;     The request PDU With function code 05 must be 5 bytes:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Address          2
  ;         Value            2
  ;         ================ ===============
  ;     The PDU can unpacked To this:
  ;     ..
  ;         Note: the backslash in the bytes below are escaped using an extra back
  ;         slash. Without escaping the bytes aren't printed correctly in the HTML
  ;         output of this docs.
  ;         To work With the bytes in Python you need To remove the escape sequences.
  ;         `b'\\x01\\x00d` -> `b\x01\x00d`
  ;     .. code-block:: python
  ;         >>> struct.unpack('>BHH', b'\\x05\\x00d\\xFF\\x00')
  ;         (5, 100, 65280)
  ;     The reponse PDU is a copy of the request PDU.
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Address          2
  ;         Value            2
  ;         ================ ===============
  
  ; --------------------------------------------------------------------------------
  ;- WRITE_SINGLE_REGISTER : 06
  ; --------------------------------------------------------------------------------  
  ;         Implement Modbus function code 06.
  ;         "This function code is used to write a single holding register in a
  ;         remote device. The Request PDU specifies the address of the register To
  ;         be written. OutRegisters are addressed starting at zero. Therefore
  ;         register numbered 1 is addressed As 0. The normal response is an echo
  ;         of the request, returned after the register contents have been
  ;         written."
  ;         -- MODBUS Application Protocol Specification V1.1b3, chapter 6.6
  ;     The request PDU With function code 06 must be 5 bytes:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Address          2
  ;         Value            2
  ;         ================ ===============
  ;     The PDU can unpacked To this:
  ;     ..
  ;         Note: the backslash in the bytes below are escaped using an extra back
  ;         slash. Without escaping the bytes aren't printed correctly in the HTML
  ;         output of this docs.
  ;         To work With the bytes in Python you need To remove the escape sequences.
  ;         `b'\\x01\\x00d` -> `b\x01\x00d`
  ;     .. code-block:: python
  ;         >>> struct.unpack('>BHH', b'\\x06\\x00d\\x00\\x03')
  ;         (6, 100, 3)
  ;     The reponse PDU is a copy of the request PDU.
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Address          2
  ;         Value            2
  ;         ================ ===============
  
  ; --------------------------------------------------------------------------------
  ;- WRITE_MULTIPLE_COILS : 15
  ; -------------------------------------------------------------------------------- 
  ;         Implement Modbus function 15 (0x0F) Write Multiple Coils.
  ;         "This function code is used to force each coil in a sequence of coils
  ;         To either ON Or OFF in a remote device. The Request PDU specifies the
  ;         coil references To be forced. Coils are addressed starting at zero.
  ;         Therefore coil numbered 1 is addressed As 0.
  ;         The requested ON/OFF states are specified by contents of the request
  ;         Data field. A logical '1' in a bit position of the field requests the
  ;         corresponding output To be ON. A logical '0' requests it To be OFF.
  ;         The normal response returns the function code, starting address, And
  ;         quantity of coils forced."
  ;         -- MODBUS Application Protocol Specification V1.1b3, chapter 6.11
  ;     The request PDU With function code 15 must be at least 7 bytes:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Starting Address 2
  ;         Quantity         2
  ;         Byte count       1
  ;         Value            n
  ;         ================ ===============
  ;     The PDU can unpacked To this:
  ;     ..
  ;         Note: the backslash in the bytes below are escaped using an extra back
  ;         slash. Without escaping the bytes aren't printed correctly in the HTML
  ;         output of this docs.
  ;         To work With the bytes in Python you need To remove the escape sequences.
  ;         `b'\\x01\\x00d` -> `b\x01\x00d`
  ;     .. code-block:: python
  ;         >>> struct.unpack('>BHHBB', b'\\x0f\\x00d\\x00\\x03\\x01\\x05')
  ;         (16, 100, 3, 1, 5)
  ;     The reponse PDU is 5 bytes And contains following Structure:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Starting address 2
  ;         Quantity         2
  ;         ================ ===============
  
  ; --------------------------------------------------------------------------------
  ;- WRITE_MULTIPLE_REGISTERS : 16
  ; --------------------------------------------------------------------------------
  
  ;         Implement Modbus function 16 (0x10) Write Multiple OutRegisters.
  ;         "This function code is used to write a block of contiguous registers (1
  ;         To 123 registers) in a remote device.
  ;         The requested written values are specified in the request Data field.
  ;         Data is packed As two bytes per register.
  ;         The normal response returns the function code, starting address, And
  ;         quantity of registers written."
  ;         -- MODBUS Application Protocol Specification V1.1b3, chapter 6.12
  ;     The request PDU With function code 16 must be at least 8 bytes:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Starting Address 2
  ;         Quantity         2
  ;         Byte count       1
  ;         Value            Quantity * 2
  ;         ================ ===============
  ;     The PDU can unpacked To this:
  ;     ..
  ;         Note: the backslash in the bytes below are escaped using an extra back
  ;         slash. Without escaping the bytes aren't printed correctly in the HTML
  ;         output of this docs.
  ;         To work With the bytes in Python you need To remove the escape sequences.
  ;         `b'\\x01\\x00d` -> `b\x01\x00d`
  ;     .. code-block:: python
  ;         >>> struct.unpack('>BHHBH', b'\\x10\\x00d\\x00\\x01\\x02\\x00\\x05')
  ;         (16, 100, 1, 2, 5)
  ;     The reponse PDU is 5 bytes And contains following Structure:
  ;         ================ ===============
  ;         Field            Length (bytes)
  ;         ================ ===============
  ;         Function code    1
  ;         Starting address 2
  ;         Quantity         2
  ;         ================ ===============

  ; ----------------------------------------------------------------------
  ;-  ADU: Aplication Data Unit
  ; ----------------------------------------------------------------------
  ; The ADU covers the PDU with Adress+PDU+Checksum
  
  ; ADU for RTU
  ; -------------------------------------
  ; |  1Byte   |  max 253    |   2Byte  |
  ; |----------|-------------|----------|
  ; | DeviceID |  FC | Data  | Checksum |
  ; -------------------------------------
  ;            |    PDU      |
  ; -------------------------------------
   
  ; ADU Frame for TCP : 7 Byte ADU Frame + PDU
  ; -----------------------------------------------------------------------------------
  ; |             Modbus TCP ADU-HEADER                    |        Modbus PDU        |
  ; -----------------------------------------------------------------------------------
  ; |    [0..1]   |   [2..3]    |    [4..5]     |   [6]    | [7] | [8..9] | [10..259] |
  ; -----------------------------------------------------------------------------------
  ; | Transaction | Protocol ID | MessageLength | DeviceID | FC  |  ADR   |   DATA    |
  ; -----------------------------------------------------------------------------------
  ; |                                                      | [7] | [8] |  [9..259]    |
  ; |                    for the response                  ----------------------------
  ; |                                                      | FC  |  NB |    DATA      |   
  ; -----------------------------------------------------------------------------------
  ; MessageLength = Len(DeviceID) + Len(PDU); NB : NumberOfBytes follow
  
  ; the Transaction ID is an 'unique' user defined ID for each transaction
  ; it will be returned in the response to indentify the transaction
  
  ; The protocol identifier is normally zero, but you can use it To expand the behavior of the protocol.
  ; The length field is used by the protocol To delineate the length of the rest of the packet. 
  ; The location of this element also indicates the dependency of this header format on a reliable networking layer.
  ; Because TCP packets have built-in error checking And ensure Data coherency And delivery, packet length
  ; can be located anywhere in the header. On a less inherently reliable network such As a serial network,
  ; a packet could be lost, having the effect that even If the stream of Data Read by the application included
  ; valid transaction and protocol information, corrupted length information would make the header invalid.
  ; TCP provides a reasonable amount of protection against this situation.

  ; The Unit ID is typically unused For TCP/IP devices. However, Modbus is such a common protocol that many gateways
  ; are developed, which convert the Modbus protocol into another protocol. In the original intended use Case, 
  ; a Modbus TCP/IP To serial gateway could be used To allow connection between new TCP/IP networks and older serial networks.
  ; In such an environment, the Unit ID is used To determine the address of the slave device that the PDU is actually intended for.

  ; Finally, the ADU includes a PDU. The length of this PDU is still limited To 253 bytes For the standard protocol.
    
  ; ============================================================
  ; Example PDU For reading Coils with Request and Response
  ; ============================================================
  ; Byte |	Request                |Byte | Response
  ; ------------------------------------------------------------
  ; (Hex)|	Fieldname	             |(Hex)| Fieldname
  ; ------------------------------------------------------------
  ; 01   | Transactoion ID         | 01  | Transactoion ID
  ; 02   |                         | 02  |
  ; ------------------------------------------------------------
  ; 00   | Protocol                | 00  | Protocol
  ; 00   | (always 00 or User def) | 00  |
  ; ------------------------------------------------------------
  ; 00   |  Message Length         | 00  | Message Length
  ; 06   |                         | 04  |
  ; ------------------------------------------------------------
  ; 01   | DeviceID, Address       | 01  | DeviceID, Address
  ; ------------------------------------------------------------
  ; 01   | Function Code           | 01  | Function Code
  ; ------------------------------------------------------------
  ; 00   | Addr Hi                 | 01  | No of Data Bytes follow
  ; ------------------------------------------------------------
  ; 00   | Addr Lo                 | 02  | Values of DO0 und DO1
  ; ------------------------------------------------------------
  ; 00   | No of OutRegisters Hi Byte | 01  |	
  ; 02   | No of OutRegisters Hi Byte | 02  |
  ; ------------------------------------------------------------
    
  ; https://ipc2u.de/artikel/wissenswertes/detaillierte-beschreibung-des-modbus-tcp-protokolls-mit-befehlsbeispielen/#0x01

;}
 
;- ----------------------------------------------------------------------
;- Declare Module
;- ----------------------------------------------------------------------

DeclareModule ModBus
  
  EnableExplicit
   
  ; ----------------------------------------------------------------------
  ;- Declare Constants and Structures
  ; ----------------------------------------------------------------------
  
  ; ModBus Functions  
  ; 01: Read Coils
  ; 02: Read Discret Inputs
  ; 03: Read Holding OutRegisters
  ; 04: Read Input OutRegisters
  ; 05: Write Singel Coil
  ; 06: Write Single Register
  ; 15: Write Multiple Coil
  ; 16: Write Multiple Register

  ; ----------------------------------------------------------------------
  ;   Constants according to Modbus specification
  ; ---------------------------------------------------------------------- 
  ; Modbus Function Codes
  ; MODBUS Application Protocol Specification V1.1b3 page 11/50
  
  #MODBUS_FC_READ_COILS                     = 1 
  #MODBUS_FC_READ_DISCRETE_INPUTS           = 2 
  #MODBUS_FC_READ_HOLDING_REGISTERS         = 3 
  #MODBUS_FC_READ_INPUT_REGISTERS           = 4 
  #MODBUS_FC_WRITE_SINGLE_COIL              = 5 
  #MODBUS_FC_WRITE_SINGLE_REGISTER          = 6 
   
  #MODBUS_FC_WRITE_MULTIPLE_COILS           = 15 
  #MODBUS_FC_WRITE_MULTIPLE_REGISTERS       = 16 
  #MODBUS_FC_MASK_WRITE_REGISTER            = 22 
  #MODBUS_FC_READ_WRITE_MULTIPLE_REGISTERS  = 23 
  #MODBUS_FC_READ_FIFO_QUEUE                = 24 
  
  ; Diagnostic Functions
  #MODBUS_FC_DIAG_READ_EXCEPTION_STATUS     = 7     ; ModBus RTU only
  #MODBUS_FC_DIAG_DIAGNOSTIC                = 8     ; ModBus RTU only
  #MODBUS_FC_DIAG_GET_COM_EVENT_COUNTER     = 11    ; ModBus RTU only
  #MODBUS_FC_DIAG_GET_COM_EVENT_LOG         = 12    ; ModBus RTU only
  #MODBUS_FC_DIAG_REPORT_SERVER_ID          = 17    ; ModBus RTU only : Report SERVER/SLAVE ID what it the same!
  #MODBUS_FC_DIAG_READ_DEVICE_ID            = 43

  ; Modbus Exception Codes
  #MODBUS_EXCEPTION_ILLEGAL_FUNCTION        = 1
  #MODBUS_EXCEPTION_ILLEGAL_DATA_ADDRESS    = 2
  #MODBUS_EXCEPTION_ILLEGAL_DATA_VALUE      = 3
  #MODBUS_EXCEPTION_SLAVE_OR_SERVER_FAILURE = 4
  #MODBUS_EXCEPTION_ACKNOWLEDGE             = 5
  #MODBUS_EXCEPTION_SLAVE_OR_SERVER_BUSY    = 6
  #MODBUS_EXCEPTION_NEGATIVE_ACKNOWLEDGE    = 7
  #MODBUS_EXCEPTION_MEMORY_PARITY           = 8
  #MODBUS_EXCEPTION_NOT_DEFINED             = 9
  #MODBUS_EXCEPTION_GATEWAY_PATH            =10
  #MODBUS_EXCEPTION_GATEWAY_TARGET          =11
  #MODBUS_EXCEPTION_MAX                     =12
  
  ; Max limits for read/write in a single PDU  
  #MODBUS_MAX_READ_BITS  = 2000         ; 2000/8 = 250 (+1Byte Function +2Byte CRC =253 = #MODBUS_MAX_PDU_LENGTH
  #MODBUS_MAX_WRITE_BITS = 1968
  #MODBUS_MAX_READ_REGISTERS  = 125      ; $7D : 250 Byte 
  #MODBUS_MAX_WRITE_REGISTERS = 123
  ; for the Modbus Functions 23 #MODBUS_FC_READ_WRITE_MULTIPLE_REGISTERS
  #MODBUS_MAX_WR_READ_REGISTERS  = 125    
  #MODBUS_MAX_WR_WRITE_REGISTERS = 121
   
  ; General Register Address space
  #MODBUS_MAX_DATA_ADDRESS = 65535      ; 64k Address space [0..65535], [0..$FFFF]
  
  ; max Length of ADU PDU Block
  #MODBUS_MAX_PDU_LENGTH = 253      ; max Lenght of ModBus Data 3 Bytes Frame + 250 Byte user data
  #MODBUS_MAX_ADU_LENGTH = 260      ; ADU Frame 7 Bytes + 253 Byte PDU
 
  #MODBUS_BROADCAST_ADDRESS = 0
  #MODBUS_TCP_PORT = 502    ; Modbus stadard Port = 502
  ; ----------------------------------------------------------------------

  ; It's user defined! Not part of the Modbus specification
  #MODBUS_STANDARD_TIMEOUT = 1000   ; Standard TimeOut value = 1000ms
    

  #_BufferSizeByte = #MODBUS_MAX_ADU_LENGTH
  #_BufferMaxIdx = #_BufferSizeByte - 1
  
  ; a full Modbus Register set is 144kB
  ; internal we use PB standard  LittleEndian, BigEndian is only requestet for Datatransfers
  Structure TModbusRegisterSet
    Array Coils.u (#MODBUS_MAX_DATA_ADDRESS/16) ; [0..4095]  Registers for Coils  -> 8kB 
    Array Inputs.u(#MODBUS_MAX_DATA_ADDRESS/16) ; [0..4095]  Registers for Inputs -> 8kB
    Array HRegs.u (#MODBUS_MAX_DATA_ADDRESS)    ; [0..65535] Holding Registers    -> 128kB
  EndStructure

  Structure TModbusRTU_Header
    DeviceID.a
    FunctionCode.a
    Address.u             ; for Request [8..9] = DataAddress
    NoOfBytesFollow.a     ; for Response [8] = NoOfBytesFollow
    CRC.u
  EndStructure

  Structure TModbusTCP_Header
    Transaction.u
    Protocol.u
    MsgLength.u
    DeviceID.a
    FunctionCode.a
    Address.u             ; for Request [8..9] = DataAddress
    NoOfBytesFollow.a     ; for Response [8] = NoOfBytesFollow
  EndStructure

  Structure TModbusStatus
    timSend.q             ; Timestamp last send    : Date()*1000+ms
    timReceive.q          ; Timestamp last receive : Date()*1000+ms
    TransactionID.u       ; TransactionID
    BytesToSend.i         ; Total No of bytes to send (ADU Block length)
    BytesReceived.i
    LastFunction.i 
  EndStructure
    
  ; Modbus *This Base
  Structure TModbusBase 
    DeviceID.i            ; Modbus Device ID
    TimeOut.i             ; configuration for TimeOut in ms
    Status.TModbusStatus
    Array SendBuffer.a(#_BufferMaxIdx)
    Array ReceiveBuffer.a(#_BufferMaxIdx)
  EndStructure
  
  ; RTU_This
  Structure TModbusRTU Extends TModbusBase
    ComPort.i             ; No of Com-Port
  EndStructure
  
  ;TCP_This
  Structure TModbusTCP Extends TModbusBase
    IP.i
    SubNetMask.i
    Port.i                ; Modbus Port = 502
    ConnectionID.i        ; the Connection ID from OpenNetworkConnection(), 0 if not connected
  EndStructure  
  
  ;- Declare Register Set Functions
  Declare.i GetCoil(*RS.TModbusRegisterSet, CoilNo)
  Declare.i SetCoil(*RS.TModbusRegisterSet, CoilNo, State=#True)
  Declare.i GetInput(*RS.TModbusRegisterSet, InputNo)
  Declare.i SetInput(*RS.TModbusRegisterSet, InputNo, State=#True)
  Declare.f GetFloat(*RS.TModbusRegisterSet, StartRegister)
  Declare.f SetFloat(*RS.TModbusRegisterSet, StartRegister, Value.f)
  Declare.l GetInt32(*RS.TModbusRegisterSet, StartRegister)
  Declare.l SetInt32(*RS.TModbusRegisterSet, StartRegister, Value.l)
  Declare.q GetUInt32(*RS.TModbusRegisterSet, StartRegister)
  Declare.q SetUInt32(*RS.TModbusRegisterSet, StartRegister, Value.q)

  ;- Declare ModBus RTU Functions
  Declare.i RTU_GetADU_Header_Send(*Modbus.TModbusRTU, *OutHeader.TModbusRTU_Header)
  Declare.i RTU_GetADU_Header_Receive(*Modbus.TModbusRTU, *OutHeader.TModbusRTU_Header)
  Declare.i RTU_ReadCoils(*Modbus.TModbusRTU, StartCoil, NoOfCoils, Array OutBools.a(1))
  Declare.i RTU_ReadDiscreteInputs(*Modbus.TModbusRTU, StartInput, NoOfInputs, Array OutBools.a(1))
  Declare.i RTU_ReadHoldingOutRegisters(*Modbus.TModbusRTU, StartRegister, NoORegisters, Array OutRegisters.u(1))
  Declare.i RTU_ReadInputOutRegisters(*Modbus.TModbusRTU, StartRegister, NoORegisters, Array OutRegisters.u(1))
  Declare.i RTU_WriteSingleCoil(*Modbus.TModbusRTU, Coil.i, Value)
  Declare.i RTU_WriteSingleRegister(*Modbus.TModbusRTU, Register.i, Value)
  Declare.i RTU_WriteMultipleCoils(*Modbus.TModbusRTU, StartCoil, NoOfCoils, Array Values.a(1))
  Declare.i RTU_WriteMultipleOutRegisters(*Modbus.TModbusRTU, StartRegister, NoORegisters, Array Values.u(1))
  Declare.i RTU_ReadExceptionStatus(*Modbus.TModbusRTU) 
  
  ;- Declare ModBus TCP Functions
  Declare.i TCP_GetADU_Header_Send(*Modbus.TModbusTCP, *OutHeader.TModbusTCP_Header)  
  Declare.i TCP_GetADU_Header_Receive(*Modbus.TModbusTCP, *OutHeader.TModbusTCP_Header)  
  Declare.i TCP_ReadCoils(*Modbus.TModbusTCP, StartCoil, NoOfCoils, Array OutBools.a(1))
  Declare.i TCP_ReadDiscreteInputs(*Modbus.TModbusTCP, StartInput, NoOfInputs, Array OutBools.a(1))
  Declare.i TCP_ReadHoldingOutRegisters(*Modbus.TModbusTCP, DeviceID, StartRegister, NoORegisters, Array OutRegisters.u(1))
  Declare.i TCP_ReadInputOutRegisters(*Modbus.TModbusTCP, StartRegister, NoORegisters, Array OutRegisters.u(1))
  Declare.i TCP_WriteSingleCoil(*Modbus.TModbusTCP, Coil, Value)
  Declare.i TCP_WriteSingleRegister(*Modbus.TModbusTCP, Register, Value)
  Declare.i TCP_WriteMultipleCoils(*Modbus.TModbusTCP, StartCoil, NoOfCoils, Array Values.a(1))
  Declare.i TCP_WriteMultipleOutRegisters(*Modbus.TModbusTCP, DeviceID, StartRegister, NoORegisters, Array Values.u(1))
  Declare.i TCP_ReadExceptionStatus(*Modbus.TModbusTCP)

EndDeclareModule

Module ModBus
  
  EnableExplicit
  
  ;- Protocol StartPositions in Buffer, ByteAddress
  
  ; at Request and Response
  #RTU_idx_ADU = 0    ; ADU StartPostion in Buffer start with DeviceID
  #RTU_idx_PDU = #RTU_idx_ADU + 1 ; 1
  
  ; at Request and Response
  #TCP_idx_ADU = 0    ; BufferPostion of Transaction , starts at Byte 0
  #TCP_idx_PDU = #TCP_idx_ADU + 7 ; 7

  Structure pBuffer
    a.a[0]
    u.u[0]
    w.w[0]
    l.l[0]
    f.f[0]
  EndStructure
    
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  Macro _SwapBytes(val)
     ((val & $FF)<< 8) + (val >>8)&FF)  
  EndMacro
  
  Macro _HighByte(val)
    ((val>>8) & $FF)  
  EndMacro
  
  Macro _LoByte(val)
    (val & $FF)  
  EndMacro
  
  Macro _NoOfBytesToStoreBits(NoOfBits)
    (NoOfBits/8 + Bool(NoOfBits %8))  
  EndMacro
  
  ; maybe MinDeviceID = 1 not =0, because 0 is ModbusBroadcastAddress
  ; how to handle that is not clear until now!
  Macro _IsValidDeviceID(DevID)
    Bool(DevID >=0 And DevID <=255)  
  EndMacro
  
  Procedure.i _CalcNoOfDataBytes(FC, NoOfElements)  
    ; Calculates the NoOfDataBytes necessary to store NoOfElemenst according to the 
    ; Modbus FunctionCode FC. 
    ; This is different for:
    ;   - Bit based Functions:      NoOfBytes = NoOfBytesToStoreBits(NoOfBits)
    ;   - Reg/WORD based Functions: NoOfBytes = NoOfElements * 2
    
    Select FC      
        
     ; Bit based Functions
     Case #MODBUS_FC_READ_COILS,
          #MODBUS_FC_READ_DISCRETE_INPUTS,
          #MODBUS_FC_WRITE_SINGLE_COIL,
          #MODBUS_FC_WRITE_MULTIPLE_COILS
         ProcedureReturn _NoOfBytesToStoreBits(NoOfElements)  
         
       Default 
        ; WORD/Register based Functions
        ProcedureReturn NoOfElements *2
    EndSelect  
  EndProcedure
  
  Procedure.u _CalcCRC(*Ptr, Len.i)
    ; Code form PB-Forum: by Infratec
    Protected CRC_Value.u  = $FFFF
    Protected i.i
    
    Len - 1
    For i = 0 To Len
      CRC_Value = (CRC_Value >> 8) ! PeekU(?ModBus_CRCTable + (PeekA(*Ptr + i) ! (CRC_Value & $FF)) << 1)
    Next i
    
    ProcedureReturn CRC_Value   
  EndProcedure
  
  Procedure.i _CheckCRC(*Ptr, Len.i)
    ; Code form PB-Forum: by Infratec
   Protected Result.i, _CalcCRC.u
      
    Len - 2
    _CalcCRC = _CalcCRC(*Ptr, Len)
    ;Debug Hex(_CalcCRC)
    ;Debug Hex(PeekU(*Ptr + Len))
    If _CalcCRC = PeekU(*Ptr + Len)
      Result = #True
    EndIf
    
    ProcedureReturn Result    
  EndProcedure
  
  Procedure _WordToBuffer(Value, Array Buffer.a(1), ByteAddress)
  ; ============================================================================
  ; NAME: _WordToBuffer
  ; DESC: writes a 16Bit value into the Buffer as BigEndian ByteOrder,
  ; DESC: start at ByteAdress. BigEndian means with a ByteSwap from Little- to Big-
  ; DESC:
  ; VAR(Value): the Value to write into the Buffer 
  ; VAR(Array Buffer.a(1)): The ByteBuffer
  ; VAR(ByteAddress) : 0-based StartAddress in Buffer 
  ; RET : -
  ; ============================================================================
    
    ; Modbus BigEndian: Hi first
    Buffer(ByteAddress) = (Value >> 8) & $FF  ; High Byte
    Buffer(ByteAddress+1) = Value & $FF       ; Lo-Byte
  EndProcedure
  
  Procedure.i _WordFromBuffer(Array Buffer.a(1), ByteAddress)
  ; ============================================================================
  ; NAME: _WordFromBuffer
  ; DESC: reads a 16Bit value from the Buffer as LttleEndian ByteOrder,
  ; DESC: start at ByteAdress. LittleEndian means with a ByteSwap from Big- to Little-
  ; DESC:
  ; VAR(Array Buffer.a(1)): The ByteBuffer
  ; VAR(ByteAddress) : 0-based StartAddress in Buffer 
  ; RET : The Value read from Buffer and swaped to LittleEndian 
  ; ============================================================================
    
    ; Return as BigEndian Lo first
    ;                          Lo                      Hi            
    ProcedureReturn (Buffer(ByteAddress+1)<<8) + Buffer(ByteAddress)
  EndProcedure
   
  Procedure.u _SetNewTransactionID(*Modbus.TModbusBase)   
  ; ============================================================================
  ; NAME: _SetNewTransactionID
  ; DESC: Set a new TransactionID for the specified Modbus direct in the 
  ; DESC: *Modbus\TransactionID +1 and returns this new ID
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; RET.i : The new Transcation ID
  ; ============================================================================
    *Modbus\Status\TransactionID +1
    ProcedureReturn *Modbus\Status\TransactionID
  EndProcedure
  
  Procedure _ClearSendBuffer(*Modbus.TModbusBase)   
  ; ============================================================================
  ; NAME: _ClearSendBuffer
  ; DESC: SendBuffer()=0
  ; RET : - 
  ; ============================================================================
    With *Modbus
      FillMemory(@\SendBuffer(), #_BufferMaxIdx, 0, #PB_Byte) 
    EndWith       
  EndProcedure
  
  Procedure _ClearReceiveBuffer(*Modbus.TModbusBase)
  ; ============================================================================
  ; NAME: _ClearReceiveBuffer
  ; DESC: ReceiveBuffer()=0
  ; RET : - 
  ; ============================================================================
    With *Modbus
      FillMemory(@\ReceiveBuffer(), #_BufferMaxIdx, 0, #PB_Byte) 
    EndWith          
  EndProcedure
  
  Procedure.i _IsDataAddressValid(Address, NumberOfBytes)
  ; ============================================================================
  ; NAME: _IsDataAddressValid
  ; DESC: checks for a valid DataAddress: StartAddress and EndAddress  
  ; RET : #True if DataAddress is valid 
  ; ============================================================================
            
    If Address >=0 And (Address + NumberOfBytes) <= #MODBUS_MAX_DATA_ADDRESS
      ProcedureReturn #True  
    EndIf   
    
    ProcedureReturn #False 
  EndProcedure
    
  ;- ----------------------------------------------------------------------
  ;- Slave/Client Protocol Functions
  ;- ----------------------------------------------------------------------

  Procedure.i Modbus_CheckRequest(*ModBus.TModbusBase)
    ; Modbus transcaction state diagram
    ; MODBUS Application Protocol Specification V1.1b3 page 9/50 
    
    Protected FC, DeviceID, DataAddr
    Protected ret   ; ModBus Return Value
    
    Protected FC_valid, DataAddr_valid, Data_valid, ModBus_Function_ReturnCode
    
    ; TODO! finish Brainstorming implementation 
    If FC_valid
      
      If DataAddr_valid
        
        If Data_valid
          ; Execute ModBus Function
          ret = ModBus_Function_ReturnCode ; {4,5,6}
        Else
          ret = #MODBUS_EXCEPTION_ILLEGAL_DATA_VALUE
        EndIf
        
      Else
        ret = #MODBUS_EXCEPTION_ILLEGAL_DATA_ADDRESS 
      EndIf
      
    Else
      ret = #MODBUS_EXCEPTION_ILLEGAL_FUNCTION ; 1
    EndIf  
    
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Register Set Functions
  ;- ----------------------------------------------------------------------
  
  ; In the RegisterSet we store all values as LittleEndian what is standard for
  ; PB. The BigEndian ByteOrder for Modbus is requested only for Datatransfer.
  ; So we are conform with the specification.
  
  Procedure.i GetCoil(*RS.TModbusRegisterSet, CoilNo)
  ; ============================================================================
  ; NAME: GetCoil
  ; DESC: Returns the actual state of a single Coil
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(CoilNo) : The Coil Number  
  ; RET.i : State of Coil : #False/#True 
  ; ============================================================================
    Protected reg, mask 
    
    reg = CoilNo / 16           ; Register No.
    mask = 1 << (CoilNo %16)    ; Mask of BitNo
    
    With *RS
      ProcedureReturn  Bool(\Coils(reg) & mask)
    EndWith    
  EndProcedure
  
  Procedure.i SetCoil(*RS.TModbusRegisterSet, CoilNo, State=#True)
  ; ============================================================================
  ; NAME: SetCoil
  ; DESC: Set the state of a single Coil
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(CoilNo) : The Coil Number  
  ; VAR(State) : The state to set (#False/#True)
  ; RET.i : The former state of the Coil : #False/#True 
  ; ============================================================================
    Protected ret, reg, mask 
    
    reg = CoilNo / 16             ; Register No.
    mask = 1 << (CoilNo %16)      ; Mask of BitNo
    
    With *RS
      ret = Bool(\Coils(reg) & mask)
      If State
        \Coils(reg)= \Coils(reg) | mask       ; Set Bit
      Else
        \Coils(reg)= \Coils(reg) & (~mask)    ; Reset Bit    
      EndIf    
    EndWith    
    ProcedureReturn ret ; return the former state  
  EndProcedure 
  ; ----------------------------------------
  
  Procedure.i GetInput(*RS.TModbusRegisterSet, InputNo)
  ; ============================================================================
  ; NAME: GetInput
  ; DESC: Returns the actual state of a single Input
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(InputNo) : The Input Number  
  ; RET.i : State of Coil : #False/#True 
  ; ============================================================================
    Protected reg, mask 
    
    reg = InputNo / 16            ; Register No.
    mask = 1 << (InputNo %16)     ; Mask of BitNo
    
    With *RS
      ProcedureReturn  Bool(\Inputs(reg) & mask)
    EndWith    
  EndProcedure
  
  Procedure.i SetInput(*RS.TModbusRegisterSet, InputNo, State=#True)
  ; ============================================================================
  ; NAME: SetInput
  ; DESC: Set the state of a single Input
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(InputNo) : The Input Number  
  ; VAR(State) : The state to set (#False/#True)
  ; RET.i : The former state of the Input : #False/#True 
  ; ============================================================================
    Protected ret, reg, mask 
    
    reg = InputNo / 16            ; Register No.
    mask = 1 << (InputNo %16)     ; Mask of BitNo
    
    With *RS
      ret = Bool(\Inputs(reg) & mask)
      If State
        \Inputs(reg)= \Inputs(reg) | mask       ; Set Bit
      Else
        \Inputs(reg)= \Inputs(reg) & (~mask)    ; Reset Bit    
      EndIf
      
    EndWith    
    ProcedureReturn ret ; return the former state  
  EndProcedure
  ; ----------------------------------------
  
  Procedure.f GetFloat(*RS.TModbusRegisterSet, StartRegister)
  ; ============================================================================
  ; NAME: GetFloat
  ; DESC: Returns a 32 Bit Float what needs 2 Registers
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(StartRegister) : The No. of the first Register containing the Float  
  ; RET.f : The Float value 
  ; ============================================================================
    Protected *Buf.pBuffer
    
    With *RS
      *Buf=\HRegs(StartRegister)  
     EndWith    
     ProcedureReturn *Buf\f[0]  ; return the actual vlaue  
  EndProcedure
  
  Procedure.f SetFloat(*RS.TModbusRegisterSet, StartRegister, Value.f)
  ; ============================================================================
  ; NAME: GetFloat
  ; DESC: Set a 32 Bit Float what needs 2 Registers
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(StartRegister) : The No. of the first Register containing the Float 
  ; VAR(Value.f) : The Float value
  ; RET.f : The former Float value 
  ; ============================================================================
    Protected ret.f, *Buf.pBuffer
 
    With *RS
      *Buf=\HRegs(StartRegister)  
      ret = *Buf\f[0]
      *Buf\f[0] = Value
    EndWith   
    ProcedureReturn ret ; return the former vlaue
  EndProcedure
  ; ----------------------------------------
 
  Procedure.l GetInt32(*RS.TModbusRegisterSet, StartRegister)
  ; ============================================================================
  ; NAME: GetInt32
  ; DESC: Returns a 32 Bit singed Integer what needs 2 Registers
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(StartRegister) : The No. of the first Register containing the Integer  
  ; RET.l : The signed Integer value 
  ; ============================================================================
    Protected *Buf.pBuffer
    
    With *RS
      *Buf=\HRegs(StartRegister)  
    EndWith 
    ProcedureReturn *Buf\l[0] ; return the actual vlaue  
  EndProcedure
  
  Procedure.l SetInt32(*RS.TModbusRegisterSet, StartRegister, Value.l)
  ; ============================================================================
  ; NAME: SetInt32
  ; DESC: Set a 32 Bit singed Integer what needs 2 Registers
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(StartRegister) : The No. of the first Register containing the Integer 
  ; VAR(Value.l) : The signed Integer value
  ; RET.l : The former signed Integer value 
  ; ============================================================================
    Protected ret.l, *Buf.pBuffer
    
    With *RS
      *Buf=\HRegs(StartRegister) 
      ret = *Buf\l[0]
      *Buf\l[0] = Value
    EndWith 
    
    ProcedureReturn ret ; return the former vlaue
  EndProcedure
  ; ----------------------------------------
  
  Procedure.q GetUInt32(*RS.TModbusRegisterSet, StartRegister)
  ; ============================================================================
  ; NAME: GetUInt32
  ; DESC: Returns a 32 Bit unssinged Integer what needs 2 Registers
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(StartRegister) : The No. of the first Register containing the Integer  
  ; RET.l : The unsigned Integer value 
  ; ============================================================================
  ; unsigned Int 32  
    Protected *Buf.pBuffer
    
     With *RS
      *Buf=\HRegs(StartRegister) 
      ProcedureReturn (*Buf\l[0] & $FFFFFFFF)   ; With (& $FFFFFFFF) PB ignore the sign Bit
    EndWith 
  EndProcedure
  
  Procedure.q SetUInt32(*RS.TModbusRegisterSet, StartRegister, Value.q)
  ; ============================================================================
  ; NAME: SetUInt32
  ; DESC: Set a 32 Bit unsinged Integer what needs 2 Registers
  ; VAR(*RS.TModbusRegisterSet): Pointer to ModBusRegisterSet Structure
  ; VAR(StartRegister) : The No. of the first Register containing the Integer 
  ; VAR(Value.q) : The unsigned Integer value
  ; RET.q : The former unsigned Integer value 
  ; ============================================================================
    Protected ret.q, *Buf.pBuffer
    
     With *RS
      *Buf=\HRegs(StartRegister) 
      ret = *Buf\l[0] & $FFFFFFFF               ; With (& $FFFFFFFF) PB ignore the sign Bit
      *Buf\l[0] = Value & $FFFFFFFF    
    EndWith 
      
    ProcedureReturn ret ; return the former vlaue
  EndProcedure
  ; ----------------------------------------
 
  ;- ----------------------------------------------------------------------
  ;- ModBus RTU
  ;- ----------------------------------------------------------------------
  
  ; List COM Ports 
  ; https://www.purebasic.fr/german/viewtopic.php?p=366387&sid=6bbd84f0834c8cd81d0a0140999a8401#p366387
  
  Procedure.i _RTU_Send(*Modbus.TModbusRTU)
    Protected ret
    
    ProcedureReturn ret  
  EndProcedure
    
  Procedure _RTU_ClearSendBuffer(*Modbus.TModbusRTU)   
    With *Modbus
      FillMemory(@\SendBuffer(), #_BufferMaxIdx, 0, #PB_Byte) 
    EndWith       
  EndProcedure
  
  Procedure _RTU_ClearReceiveBuffer(*Modbus.TModbusRTU)
    With *Modbus
      FillMemory(@\ReceiveBuffer(), #_BufferMaxIdx, 0, #PB_Byte) 
    EndWith          
  EndProcedure
  
  Procedure.i _RTU_IsFunctionCodeValid(ModbusFunctionCode)
  ; ============================================================================
  ; NAME: _RTU_IsFunctionCodeValid
  ; DESC: checks for a valid Modbus FunctionCode for Modbus RTU
  ; RET : #True if ModbusFunctionCode is valid 
  ; ============================================================================
  
    Select ModbusFunctionCode       ; Data Access, single access
      Case 1 To 6  
        ; #MODBUS_FC_READ_COILS                     = 1 
        ; #MODBUS_FC_READ_DISCRETE_INPUTS           = 2 
        ; #MODBUS_FC_READ_HOLDING_REGISTERS         = 3 
        ; #MODBUS_FC_READ_INPUT_REGISTERS           = 4 
        ; #MODBUS_FC_WRITE_SINGLE_COIL              = 5 
        ; #MODBUS_FC_WRITE_SINGLE_REGISTER          = 6 
        ProcedureReturn #True
        
      Case 15, 16, 22, 23, 24       ; Data Access, multiple access 
        ; #MODBUS_FC_WRITE_MULTIPLE_COILS           = 15 
        ; #MODBUS_FC_WRITE_MULTIPLE_REGISTERS       = 16 
        ; #MODBUS_FC_MASK_WRITE_REGISTER            = 22 
        ; #MODBUS_FC_READ_WRITE_MULTIPLE_REGISTERS  = 23 
        ; #MODBUS_FC_READ_FIFO_QUEUE                = 24 
         ProcedureReturn #True
         
       Case 7, 8, 11, 12, 17, 43    ; Diagnostig Functions 
        ; #MODBUS_FC_DIAG_READ_EXCEPTION_STATUS     = 7     ; ModBus RTU only
        ; #MODBUS_FC_DIAG_DIAGNOSTIC                = 8     ; ModBus RTU only
        ; #MODBUS_FC_DIAG_GET_COM_EVENT_COUNTER     = 11    ; ModBus RTU only
        ; #MODBUS_FC_DIAG_GET_COM_EVENT_LOG         = 12    ; ModBus RTU only
        ; #MODBUS_FC_DIAG_REPORT_SERVER_ID          = 17    ; ModBus RTU only : Report SERVER/SLAVE ID what it the same!
        ; #MODBUS_FC_DIAG_READ_DEVICE_ID            = 43
          ProcedureReturn #True
       
    EndSelect
    ProcedureReturn #False
  EndProcedure
  
  ;- --------------------
  ;-  RTU Public
  ;- --------------------
 
  Procedure.i RTU_GetADU_Header_Send(*Modbus.TModbusRTU, *OutHeader.TModbusRTU_Header)
  ; ============================================================================
  ; NAME: RTU_GetADU_Header_Send
  ; DESC: Reads the complete Header Data from the SendBuffer as a compact 
  ; DESC: Structure with the correct endianess for PureBasic - LittleEndian
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(*OutHeader.TModbusRTU_Header) : Pointer to the return Structure
  ; RET : *OutHeader 
  ; ============================================================================
    
    Protected NoOfElements ; NumberOfElements to calculate NoOfBytesFollow
        
    ; at RTU we do not have the MsgLength like at TCP, so we can not calculate 
    ; NB with MsgLength. We have to use an other way!
    
    ; The first WORD of the DATA is at a request, the NumberOfLements
    ; NumberOfElements we have to transfer into NoOfBytes according the FunctionCode
    ; for Register Functions, WORD it is NumberOfElements * 2
    ; for BitBased Functions Coils, Inputs it is the NumberOfBytes needed to store the Bits
    
    NoOfElements =  _WordFromBuffer(*Modbus\SendBuffer(), #RTU_idx_PDU+3)  ; NumberOfElements
    
    If *OutHeader
      With *OutHeader
        \DeviceID     = *Modbus\SendBuffer(#RTU_idx_ADU)
        \FunctionCode = _WordFromBuffer(*Modbus\SendBuffer(), #RTU_idx_PDU)
        \Address      = _WordFromBuffer(*Modbus\SendBuffer(), #RTU_idx_PDU +1)      
        
        \NoOfBytesFollow = _CalcNoOfDataBytes(\FunctionCode, NoOfElements)      
    
        ; CRC follows after the PDU as 2 Byte CRC-Sum
        \CRC = _WordFromBuffer(*Modbus\SendBuffer(), #RTU_idx_PDU + 3 + \NoOfBytesFollow)
      EndWith
    EndIf
    
    ProcedureReturn *OutHeader
  EndProcedure
  
  Procedure.i RTU_GetADU_Header_Receive(*Modbus.TModbusRTU, *OutHeader.TModbusRTU_Header)
  ; ============================================================================
  ; NAME: RTU_GetADU_Header_Receive
  ; DESC: Reads the complete Header Data from the ReceiveBuffer as a compact  
  ; DESC: Structure with the correct endianess for PureBasic - LittleEndian
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(*OutHeader.TModbusRTU_Header) : Pointer to the return Structure
  ; RET : *OutHeader 
  ; ============================================================================
    
    With *OutHeader
      \DeviceID     = *Modbus\ReceiveBuffer(#RTU_idx_ADU)
      \FunctionCode = _WordFromBuffer(*Modbus\ReceiveBuffer(), #RTU_idx_PDU)
      \Address = -1 ; #PB_Default, not relevant at request
      \NoOfBytesFollow = *Modbus\ReceiveBuffer(#RTU_idx_PDU +1) ; Bytes follow after Address
      
      ; CRC follows after the PDU as 2 Byte CRC-Sum
      \CRC = _WordFromBuffer(*Modbus\ReceiveBuffer(), #RTU_idx_PDU + 2 + \NoOfBytesFollow)
    EndWith
    
    ProcedureReturn *OutHeader
  EndProcedure
  
  Procedure.i RTU_ReadCoils(*Modbus.TModbusRTU, StartCoil, NoOfCoils, Array OutBools.a(1))
  ; ============================================================================
  ; NAME: RTU_ReadCoils
  ; DESC: Modbus RTU-ReadCoils
  ; DESC: FunctionCode = 0 : #MODBUS_FC_READ_COILS
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(StartCoil) : [1..65535]
  ; VAR(NoOfCoils) : [1..2000]
  ; RET.i : Modbus Result
  ; ============================================================================
   
    Protected MRes.i    
    
    ProcedureReturn MRes 
    
   EndProcedure
  
  Procedure.i RTU_ReadDiscreteInputs(*Modbus.TModbusRTU, StartInput, NoOfInputs, Array OutBools.a(1))
  ; ============================================================================
  ; NAME: RTU_ReadDiscreteInputs
  ; DESC: Modbus RTU-ReadDiscreteInputs
  ; DESC: FunctionCode = 1 : #MODBUS_FC_READ_DISCRETE_INPUTS
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(StartInput) : [1..65535]
  ; VAR(NoOfInputs) : [1.2000]
  ; RET.i : Modbus Result
  ; ============================================================================
    
    Protected MRes.i    
    
    ProcedureReturn MRes 
  EndProcedure

  Procedure.i RTU_ReadHoldingOutRegisters(*Modbus.TModbusRTU, StartRegister, NoORegisters, Array OutRegisters.u(1))
  ; ============================================================================
  ; NAME: RTU_ReadHoldingOutRegisters
  ; DESC: Modbus RTU-ReadHoldingOutRegisters
  ; DESC: FunctionCode = 3 : #MODBUS_FC_READ_HOLDING_REGISTERS
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(StartRegister) : [1..65535]
  ; VAR(NoORegisters) : [1..125]
  ; RET.i : Modbus Result
  ; ============================================================================
    Protected MRes.i    
    
    ProcedureReturn MRes   
  EndProcedure
  
  Procedure.i RTU_ReadInputOutRegisters(*Modbus.TModbusRTU, StartRegister, NoORegisters, Array OutRegisters.u(1))
  ; ============================================================================
  ; NAME: RTU_ReadInputOutRegisters
  ; DESC: Modbus RTU-ReadInputOutRegisters
  ; DESC: FunctionCode = 4 : #MODBUS_FC_READ_INPUT_REGISTERS
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(StartRegister) : [1..65535]
  ; VAR(NoORegisters) : [1..125]
  ; RET.i : Modbus Result
  ; ============================================================================
    Protected MRes.i    
    
    ProcedureReturn MRes     
  EndProcedure
  
  Procedure.i RTU_WriteSingleCoil(*Modbus.TModbusRTU, Coil.i, Value)
  ; ============================================================================
  ; NAME: RTU_WriteSingleCoil
  ; DESC: Modbus RTU-WriteSingleCoil
  ; DESC: FunctionCode = 5 : #MODBUS_FC_WRITE_SINGLE_COIL
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(Coil) : [1..65535]
  ; VAR(Value) : 
  ; RET.i : Modbus Result
  ; ============================================================================
   
    Protected MRes.i    
    
    ProcedureReturn MRes     
  EndProcedure
  
  Procedure.i RTU_WriteSingleRegister(*Modbus.TModbusRTU, Register.i, Value)
  ; ============================================================================
  ; NAME: RTU_WriteSingleRegister
  ; DESC: Modbus RTU-WriteSingleRegister
  ; DESC: FunctionCode = 6 : #MODBUS_FC_WRITE_SINGLE_REGISTER
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(Register) : [1..65535]
  ; VAR(Value) : 
  ; RET.i : Modbus Result
  ; ============================================================================
    
    Protected MRes.i    
    
    ProcedureReturn MRes    
  EndProcedure
     
  Procedure.i RTU_WriteMultipleCoils(*Modbus.TModbusRTU, StartCoil, NoOfCoils, Array Values.a(1))
  ; ============================================================================
  ; NAME: RTU_WriteMultipleCoils
  ; DESC: Modbus RTU-WriteMultipleCoils
  ; DESC: FunctionCode = 15 : #MODBUS_FC_WRITE_MULTIPLE_COILS
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(StartCoil) : [1..65535]
  ; VAR(NoOfCoils) : [1..1968]
  ; RET.i : Modbus Result
  ; ============================================================================
   
    Protected MRes.i    
    
    ProcedureReturn MRes 
  EndProcedure
  
  Procedure.i RTU_WriteMultipleOutRegisters(*Modbus.TModbusRTU, StartRegister, NoORegisters, Array Values.u(1))
  ; ============================================================================
  ; NAME: RTU_WriteMultipleOutRegisters
  ; DESC: Modbus RTU-WriteMultipleOutRegisters
  ; DESC: FunctionCode = 16 : ##MODBUS_FC_WRITE_MULTIPLE_REGISTERS
  ; VAR(*Modbus.TModbusRTU) : Modbus *This Data
  ; VAR(StartRegister) : [1..65535]
  ; VAR(NoORegisters) : [1..123]
  ; RET.i : Modbus Result
  ; ============================================================================
    
  EndProcedure
  
  Procedure.i RTU_ReadExceptionStatus(*Modbus.TModbusRTU)
  ; ============================================================================
  ; NAME: TCP_ReadExceptionStatus
  ; DESC: Modbus TCP-ReadExceptionStatus
  ; DESC: FunctionCode = 7 : #MODBUS_FC_READ_EXCEPTION_STATUS
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; RET.i : Modbus Result
  ; ============================================================================
   
    Protected MRes.i    
    
    ProcedureReturn MRes 
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- ModBus TCP
  ;- ----------------------------------------------------------------------
  
  ; Buffer Address for ADU 
  ; Adr :  Value
  ; -----------------------
  ; 0   : Transaction_ID (2Byte)
  ; 2   : ProtocolID     (2Byte)
  ; 4   : Message Lenth  (2Byte)
  ; 6   : DeviceAddress  (1Byte)
  ; 7   : Function Code  (1Byte)
  ; 8   : Adress         (2Byte)
  ; 10  : NoOfElements   (2Byte)
  
  ; -----------------------------------------------------------------------------------
  ; |             Modbus TCP ADU-HEADER                    |        Modbus PDU        |
  ; -----------------------------------------------------------------------------------
  ; |    [0..1]   |   [2..3]    |    [4..5]     |   [6]    | [7] | [8..9] | [10..259] |
  ; -----------------------------------------------------------------------------------
  ; | Transaction | Protocol ID | MessageLength | DeviceID | FC  |  ADR   |   DATA    |
  ; -----------------------------------------------------------------------------------
  ; |                                                      | [7] | [8] |  [9..259]    |
  ; |                    for the response                  ----------------------------
  ; |                                                      | FC  |  NB |    DATA      |   
  ; -----------------------------------------------------------------------------------
  ; MessageLength = Len(DeviceID) + Len(PDU); NB : NumberOfBytes follow
    
  Procedure.i _TCP_IsFunctionCodeValid(ModbusFunctionCode)
  ; ============================================================================
  ; NAME: _TCP_IsFunctionCodeValid
  ; DESC: checks for a valid Modbus FunctionCode for Modbus TCP
  ; RET : #True if ModbusFunctionCode is valid 
  ; ============================================================================
  
    Select ModbusFunctionCode       ; Data Access, single access
      Case 1 To 6  
        ; #MODBUS_FC_READ_COILS                     = 1 
        ; #MODBUS_FC_READ_DISCRETE_INPUTS           = 2 
        ; #MODBUS_FC_READ_HOLDING_REGISTERS         = 3 
        ; #MODBUS_FC_READ_INPUT_REGISTERS           = 4 
        ; #MODBUS_FC_WRITE_SINGLE_COIL              = 5 
        ; #MODBUS_FC_WRITE_SINGLE_REGISTER          = 6 
        ProcedureReturn #True
        
      Case 15, 16, 22, 23, 24       ; Data Access, multiple access 
        ; #MODBUS_FC_WRITE_MULTIPLE_COILS           = 15 
        ; #MODBUS_FC_WRITE_MULTIPLE_REGISTERS       = 16 
        ; #MODBUS_FC_MASK_WRITE_REGISTER            = 22 
        ; #MODBUS_FC_READ_WRITE_MULTIPLE_REGISTERS  = 23 
        ; #MODBUS_FC_READ_FIFO_QUEUE                = 24 
         ProcedureReturn #True
         
       Case 43    ; Diagnostig Functions 
        ; #MODBUS_FC_DIAG_READ_EXCEPTION_STATUS     = 7     ; ModBus RTU only
        ; #MODBUS_FC_DIAG_DIAGNOSTIC                = 8     ; ModBus RTU only
        ; #MODBUS_FC_DIAG_GET_COM_EVENT_COUNTER     = 11    ; ModBus RTU only
        ; #MODBUS_FC_DIAG_GET_COM_EVENT_LOG         = 12    ; ModBus RTU only
        ; #MODBUS_FC_DIAG_REPORT_SERVER_ID          = 17    ; ModBus RTU only : Report SERVER/SLAVE ID what it the same!
        ; #MODBUS_FC_DIAG_READ_DEVICE_ID            = 43
          ProcedureReturn #True
       
    EndSelect
    ProcedureReturn #False
  EndProcedure

  Procedure _TCP_GetReceivedBitField(*Modbus.TModbusTCP, Array OutBools.a(1), NoOfElements)
  ; ============================================================================
  ; NAME: _TCP_GetReceivedBitField
  ; DESC: Extracts the received Bits from the ReceiveBuffer  
  ; DESC: 
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(retBytes.a()) : return ByteArray
  ; RET.i : NoOfReceived Bits
  ; ============================================================================
    Protected nb, bval, I, J, cnt
    
    With *Modbus
      nb = \ReceiveBuffer(#TCP_idx_PDU+1)
      If nb > 0
        Dim retBytes(NoOfElements-1)
        
        cnt=0 
        For I = 0 To nb-1   ; Step trough all received Bytes
          bval = \ReceiveBuffer(#TCP_idx_PDU+2 +I) 
          
          For J = 0 To 7    ; Step trough the 8 Bits. Convert Byte to OutBools
            OutBools(cnt) = Bool(bval&1)
            bval >> 1
            cnt + 1
            If cnt >= NoOfElements    ; End of valid Received Bits reached
              Break 2 ; Exit the 2 For Next
            EndIf         
          Next
        Next
        
      Else
        nb = 0          ; Number of Bytes read = 0
      EndIf
    EndWith
    
    ProcedureReturn nb  ; Number of Bytes read
  EndProcedure

  Procedure _TCP_GetReceivedDataBytes(*Modbus.TModbusTCP, Array retBytes.a(1))
  ; ============================================================================
  ; NAME: _TCP_GetReceivedDataBytes
  ; DESC: Extracts the received Bytes from the ReceiveBuffer  
  ; DESC: 
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(retBytes.a()) : return ByteArray
  ; RET.i : NoOfReceived Bytes
  ; ============================================================================
    Protected nb, ret, I
    
    With *Modbus
      nb = \ReceiveBuffer(#TCP_idx_PDU+1)
      If nb > 0
        Dim retBytes(nb-1)
        For I = 0 To nb-1
          retBytes(I) = \ReceiveBuffer(#TCP_idx_PDU+2 +I)      
        Next
      Else
        nb = 0          ; Number of Bytes read = 0
      EndIf
    EndWith
    
    ProcedureReturn nb  ; Number of Bytes read
  EndProcedure
  
  Procedure _TCP_GetReceivedDataWords(*Modbus.TModbusTCP, Array retWords.u(1))
  ; ============================================================================
  ; NAME: _TCP_GetReceivedDataBytes
  ; DESC: Extracts the received Bytes from the ReceiveBuffer  
  ; DESC: 
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(retWords.u()) : return WordArray
  ; RET.i : NoOfReceived Words
  ; ============================================================================
    Protected nb, I
    
    With *Modbus
      nb = \ReceiveBuffer(#TCP_idx_PDU+1) ; NoOf DataBytes received
      If nb >= 2    ; for Word we need minimu 2 Bytes
        nb / 2      ; NoOfBytes to NoOfWords
        Dim retBytes(nb-1)
        For I = 0 To nb-1   ; NoOfWords
          retWords(I) = _WordFromBuffer(\ReceiveBuffer(), #TCP_idx_PDU+2 + I*2)      
        Next
      Else
        nb = 0          ; Number of Words read = 0
      EndIf
    EndWith
    
    ProcedureReturn nb  ; Number of Words read
  EndProcedure

  Procedure.i _TCP_OpenNetworkConnection(*Modbus.TModbusTCP)
  ; ============================================================================
  ; NAME: _TCP_OpenNetworkConnection
  ; DESC: open a Network Connection for the specified *Modbus Object to   
  ; DESC: send Data over TCP.
  ; DESC: If succeed *Modbus\ConnectionID is set to ConnectionID
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; RET.i : ConnectionID or 0 if Error
  ; ============================================================================
    Protected ret
    
    With  *Modbus
      ret = OpenNetworkConnection(IPString(\IP), \Port)
      If ret
        \ConnectionID = ret  
      Else
        MessageRequester("Modul Modbus : _TCP_OpenNetworkConnection", "can not open connection to " + IPString(\ip))
      EndIf
      
    EndWith
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i _TCP_CloseNetworkConnection(*Modbus.TModbusTCP)
  ; ============================================================================
  ; NAME: _TCP_CloseNetworkConnection
  ; DESC: close the Network Connection for the specified *Modbus Object   
  ; DESC: *Modbus\ConnectionID is set to 0
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; RET.i : Number of the ConnectionID closed
  ; ============================================================================
    Protected ret
    
    With *Modbus
      ret = \ConnectionID
      If ret
        CloseNetworkConnection(ret)
        \ConnectionID = 0
      EndIf
    EndWith
 
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i _TCP_Send(*Modbus.TModbusTCP)
  ; ============================================================================
  ; NAME: _TCP_Send
  ; DESC: Sends the ADU block over TCP and wait for the response
  ; DESC: 
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; RET.i : Modubs Exception or 0
  ; ============================================================================
    Protected MRes, ret, TimeOut, BytesReceived
    
    With *ModBus
      ret = SendNetworkData(\ConnectionID, \SendBuffer(), \Status\BytesToSend)
      If ret = \Status\BytesToSend
        
        *Modbus\Status\timSend = RTC::GetTimeStamp()     ; Save the TimeStamp send in Modbus Structrue
        
        If \TimeOut <= 0 : \TimeOut = #MODBUS_STANDARD_TIMEOUT : EndIf ; 1000ms
        TimeOut = \TimeOut 
        
        Repeat
          Delay(1)      ; wait a ms for the response
          Timeout - 1
          
          If NetworkClientEvent(*Modbus\ConnectionID) = #PB_NetworkEvent_Data
     
            BytesReceived = ReceiveNetworkData(\ConnectionID, \ReceiveBuffer(), #_BufferSizeByte)
            *Modbus\Status\timReceive = RTC::GetTimeStamp()     ; Save the TimeStamp receive in Modbus Structrue
 
            If BytesReceived > 6
              \Status\BytesReceived = BytesReceived
            Else
              \Status\BytesReceived = 0
            EndIf
            
            Break   ; Exit Repeat
          EndIf
        Until Timeout = 0
        
        If Timeout = 0
          MRes = #MODBUS_EXCEPTION_GATEWAY_TARGET ; 11
        EndIf
        
      Else
        MRes = #MODBUS_EXCEPTION_GATEWAY_PATH ; 10
      EndIf
    EndWith
    ProcedureReturn MRes  
  EndProcedure
  
  Procedure.i _TCP_Build_Request(*Modbus.TModbusBase, ModbusFunctionID, StartAddress, NoOfElements)
  ; ============================================================================
  ; NAME: _TCP_Build_Request
  ; DESC: Builds the ADU BaseBlock for a ModBus Request
  ; DESC: 
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(StartAddress) : (Range: unsigned Word [0..65535])
  ; VAR(NoOfElements) : (Range: unsigned Byte [0..225])
  ; RET : TransactionID
  ; ============================================================================
   
    Protected *pBuf.pBuffer = *Modbus\SendBuffer()
    Protected MessageLength
    
    Protected TrID = _SetNewTransactionID(*Modbus)  ; set a New TransactionID *Modbus\TransactionID +1
    
    _ClearSendBuffer(*Modbus)
    
    ; -----------------------------------------------------------------------------------
    ; |             Modbus TCP ADU-HEADER                    |        Modbus PDU        |
    ; -----------------------------------------------------------------------------------
    ; |    [0..1]   |   [2..3]    |    [4..5]     |   [6]    | [7] | [8..9] | [10..259] |
    ; -----------------------------------------------------------------------------------
    ; | Transaction | Protocol ID | MessageLength | DeviceID | FC  |  ADR   |   DATA    |
    ; -----------------------------------------------------------------------------------
    ; |                                                      | [7] | [8] |  [9..259]    |
    ; |                    for the response                  ----------------------------
    ; |                                                      | FC  |  NB |    DATA      |   
    ; -----------------------------------------------------------------------------------
    ; MessageLength = Len(PDU) + 1 {Len(DeviceID=1) ; NB : NumberOfBytes follow
    
     
    Select ModbusFunctionID
      Case 0
        MessageLength = 12      ; add here correct length for special FunctionCodes different from MsgLength 12
      Default
        MessageLength = 12      ; the default lenght for a request is 12 byte
    EndSelect
        
    With *Modbus
      ; WordToBuffer writes the 16Bit Value with ByteSwap
      _WordToBuffer(TrID, *Modbus\SendBuffer(), #TCP_idx_ADU)     ; TransactionID
      _WordToBuffer(0, *Modbus\SendBuffer(), #TCP_idx_ADU +2)     ; Protocol
      _WordToBuffer(MessageLength, *Modbus\SendBuffer(), #TCP_idx_ADU +4)       ; MessageLenght in Bytes
      *pBuf\a[#TCP_idx_ADU+ 6] = \DeviceID & $FF
      *pBuf\a[#TCP_idx_PDU] = ModbusFunctionID & $FF
      _WordToBuffer(StartAddress, *Modbus\SendBuffer(), #TCP_idx_PDU+1)  ; Register, Coil .. Address
      ; NoOfElements is the first Byte of Data
      _WordToBuffer(NoOfElements, *Modbus\SendBuffer(), #TCP_idx_PDU+3)  ; Number of elements to read
      
      \Status\LastFunction = ModbusFunctionID
      \Status\BytesToSend = MessageLength  
    EndWith
    ProcedureReturn TrID
  EndProcedure
  
  Procedure _TCP_Build_Response(*Modbus.TModbusTCP, ModbusFunctionID)
  ; ============================================================================
  ; NAME: _TCP_Build_Response
  ; DESC: Builds the ADU BaseBlock for a ModBus Response (Client/Slave only)
  ; DESC: As you you like to name Master-Slave or Client-Server 
  ; DESC: (Client or Slave is the Field I/O), Master or Server is the 'PLC' 
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(StartAddress) : (Range: unsigned Word [0..65535])
  ; VAR(NoOfElements) : (Range: unsigned Byte [0..225])
  ; RET : TransactionID
  ; ============================================================================
    
    Protected *pBuf.pBuffer = *Modbus\ReceiveBuffer()   
    Protected TrID 
    
    _ClearReceiveBuffer(*Modbus)
    
    With *Modbus
      ; WordToBuffer writes the 16Bit Value with ByteSwap
    EndWith
    
    ProcedureReturn TrID
  EndProcedure
  
  ;- --------------------
  ;-  TCP Public
  ;- --------------------
  
  Procedure.i TCP_GetADU_Header_Send(*Modbus.TModbusTCP, *OutHeader.TModbusTCP_Header)
  ; ============================================================================
  ; NAME: TCP_GetADU_Header_Send
  ; DESC: Reads the complete Header Data from the SendBuffer as a compact 
  ; DESC: Structure with the correct endianess for PureBasic - LittleEndian
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(*OutHeader.TModbusTCP_Header) : Pointer to the return Structure
  ; RET : *OutHeader 
  ; ============================================================================
        
    If *OutHeader
      With *OutHeader
        \Transaction  = _WordFromBuffer(*Modbus\SendBuffer(), #TCP_idx_ADU)
        \Protocol     = _WordFromBuffer(*Modbus\SendBuffer(), #TCP_idx_ADU +2)
        \MsgLength    = _WordFromBuffer(*Modbus\SendBuffer(), #TCP_idx_ADU +4)
        \DeviceID     = *Modbus\SendBuffer(#TCP_idx_ADU+ 6)
        \FunctionCode = _WordFromBuffer(*Modbus\SendBuffer(), #TCP_idx_PDU)
        \Address      = _WordFromBuffer(*Modbus\SendBuffer(), #TCP_idx_PDU +1)
        \NoOfBytesFollow = \MsgLength - 4 ; 4 Bytes = DevieID{1} + FC{1} + Addr{2} 
      EndWith
    EndIf
    
    ProcedureReturn *OutHeader
  EndProcedure
  
  Procedure.i TCP_GetADU_Header_Receive(*Modbus.TModbusTCP, *OutHeader.TModbusTCP_Header)
  ; ============================================================================
  ; NAME: TCP_GetADU_Header_Receive
  ; DESC: Reads the complete Header Data from the ReceiveBuffer as a compact  
  ; DESC: Structure with the correct endianess for PureBasic - LittleEndian
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(*OutHeader.TModbusTCP_Header) : Pointer to the return Structure
  ; RET : *OutHeader 
  ; ============================================================================
    
    With *OutHeader
      \Transaction  = _WordFromBuffer(*Modbus\ReceiveBuffer(), #TCP_idx_ADU)
      \Protocol     = _WordFromBuffer(*Modbus\ReceiveBuffer(), #TCP_idx_ADU +2)
      \MsgLength    = _WordFromBuffer(*Modbus\ReceiveBuffer(), #TCP_idx_ADU +4)
      \DeviceID     = *Modbus\ReceiveBuffer(#TCP_idx_ADU+ 6)
      \FunctionCode = _WordFromBuffer(*Modbus\ReceiveBuffer(), #TCP_idx_PDU)
      \Address = -1 ; #PB_Default, not relevant at request
      ; NoOfBytesFollow at receive = MsgLength - 3 : DevieID{1} + FC{1} +NB{1}
      \NoOfBytesFollow = *Modbus\ReceiveBuffer(#TCP_idx_PDU +1) ; received NB
      ; Option: compare NB with (MsgLength-3)
    EndWith
    
    ProcedureReturn *OutHeader
  EndProcedure

  Procedure.i TCP_ReadCoils(*Modbus.TModbusTCP, StartCoil, NoOfCoils, Array OutBools.a(1))
  ; ============================================================================
  ; NAME: TCP_ReadCoils
  ; DESC: Modbus TCP-ReadCoils
  ; DESC: FunctionCode = 0 : #MODBUS_FC_READ_COILS
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(StartCoil) : [1..65535]
  ; VAR(NoOfCoils) : [1..2000]
  ; RET.i : Modbus Result
  ; ============================================================================
   
    Protected MRes, TrID_send, TrID_rec, I, nb   
       
    ; build the base ADU and PDU Frame in the Buffer and return the TransactionID for this request
    TrID_send = _TCP_Build_Request(*Modbus, #MODBUS_FC_READ_COILS, StartCoil, NoOfCoils)
          
    MRes = _TCP_Send(*Modbus)
    
    If MRes = 0
      With *Modbus
        TrID_rec = _WordFromBuffer(\ReceiveBuffer(), #TCP_idx_ADU) 
        
        If TrID_send = TrID_rec
          _TCP_GetReceivedBitField(*Modbus, OutBools(), NoOfCoils)         
        Else
          ; wrong Transaction ID  
        EndIf        
      EndWith  
    Else
      
      ; Error : Nothing returnd! TimeOut  
    EndIf
    
    ProcedureReturn Mres
  EndProcedure
   
  Procedure.i TCP_ReadDiscreteInputs(*Modbus.TModbusTCP, StartInput, NoOfInputs, Array OutBools.a(1))
  ; ============================================================================
  ; NAME: TCP_ReadDiscreteInputs
  ; DESC: Modbus TCP-ReadDiscreteInputs
  ; DESC: FunctionCode = 1 : #MODBUS_FC_READ_DISCRETE_INPUTS
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(StartInput) : [1..65535]
  ; VAR(NoOfInputs) : [1..2000]
  ; RET.i : Modbus Result
  ; ============================================================================
    
    Protected MRes, TrID_send, TrID_rec, I, nb
            
    ; build the base ADU and PDU Frame in the Buffer and return the TransactionID for this request
    TrID_send = _TCP_Build_Request(*Modbus, #MODBUS_FC_READ_DISCRETE_INPUTS, StartInput, NoOfInputs)     
     
    MRes = _TCP_Send(*Modbus)
    
    If MRes = 0
      With *Modbus
        TrID_rec = _WordFromBuffer(\ReceiveBuffer(), #TCP_idx_ADU) 
        
        If TrID_send = TrID_rec
          _TCP_GetReceivedDataBytes(*Modbus, OutBools())         
        Else
          ; wrong Transaction ID  
        EndIf      
      EndWith  
    Else
      
      ; Error : Nothing returnd! TimeOut  
    EndIf
    
    ProcedureReturn MRes   
  EndProcedure
   
  Procedure.i TCP_ReadHoldingOutRegisters(*Modbus.TModbusTCP, DeviceID, StartRegister, NoORegisters, Array OutRegisters.u(1))
  ; ============================================================================
  ; NAME: TCP_ReadHoldingOutRegisters
  ; DESC: Modbus TCP-ReadHoldingOutRegisters
  ; DESC: FunctionCode = 3 : #MODBUS_FC_READ_HOLDING_REGISTERS
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(StartRegister) : [1..65535]
  ; VAR(NoORegisters) : [1..125]
  ; RET.i : Modbus Result
  ; ============================================================================
    
    Protected MRes, TrID_send, TrID_rec, I
            
    ; build the base ADU and PDU Frame in the Buffer and return the TransactionID for this request
    TrID_send = _TCP_Build_Request(*Modbus, #MODBUS_FC_READ_HOLDING_REGISTERS, StartRegister, NoORegisters)
          
    MRes = _TCP_Send(*Modbus)
    
    If MRes = 0
      With *Modbus
        TrID_rec = _WordFromBuffer(\ReceiveBuffer(), #TCP_idx_ADU) 
        
        If TrID_send = TrID_rec
          _TCP_GetReceivedDataWords(*Modbus, OutRegisters())
                    
        Else
          ; wrong Transaction ID  
        EndIf      
      EndWith  
    Else
      
      ; Error : Nothing returnd! TimeOut  
    EndIf
      
    ProcedureReturn MRes   
  EndProcedure
   
  Procedure.i TCP_ReadInputOutRegisters(*Modbus.TModbusTCP, StartRegister, NoORegisters, Array OutRegisters.u(1))
  ; ============================================================================
  ; NAME: TCP_ReadInputOutRegisters
  ; DESC: Modbus TCP-ReadInputOutRegisters
  ; DESC: FunctionCode = 4 : #MODBUS_FC_READ_INPUT_REGISTERS
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(StartRegister) : [1..65535]
  ; VAR(NoORegisters) : [1..125]
  ; RET.i : Modbus Result
  ; ============================================================================
   
    Protected MRes, TrID_send, TrID_rec, I
            
    ; build the base ADU and PDU Frame in the Buffer and return the TransactionID for this request
    TrID_send = _TCP_Build_Request(*Modbus, #MODBUS_FC_READ_INPUT_REGISTERS, StartRegister, NoORegisters)
          
    MRes = _TCP_Send(*Modbus)
    
    If MRes = 0
      With *Modbus
        TrID_rec = _WordFromBuffer(\ReceiveBuffer(), #TCP_idx_ADU) 
        
        If TrID_send = TrID_rec
          _TCP_GetReceivedDataWords(*Modbus, OutRegisters())
                    
        Else
          ; wrong Transaction ID  
        EndIf      
      EndWith  
    Else
      
      ; Error : Nothing returnd! TimeOut  
    EndIf
      
    ProcedureReturn MRes   
  EndProcedure 
    
  Procedure.i TCP_WriteSingleCoil(*Modbus.TModbusTCP, Coil, Value)
  ; ============================================================================
  ; NAME: TCP_WriteSingleCoil
  ; DESC: Modbus TCP-WriteSingleCoil
  ; DESC: FunctionCode = 5 : #MODBUS_FC_WRITE_SINGLE_COIL
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(Coil) : [1..65535]
  ; VAR(Value): 
  ; RET.i : Modbus Result
  ; ============================================================================
    
    Protected MRes.i   
    
    ProcedureReturn MRes   
  EndProcedure
   
  Procedure.i TCP_WriteSingleRegister(*Modbus.TModbusTCP, Register, Value)
  ; ============================================================================
  ; NAME: TCP_WriteSingleRegister
  ; DESC: Modbus TCP-WriteSingleRegister
  ; DESC: FunctionCode = 6 : #MODBUS_FC_WRITE_SINGLE_REGISTER
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(Register) : [1..65535]
  ; VAR(Value) : 
  ; RET.i : Modbus Result
  ; ============================================================================
    
    Protected MRes.i   
    
    ProcedureReturn MRes    
  EndProcedure
  
   
  Procedure.i TCP_WriteMultipleCoils(*Modbus.TModbusTCP, StartCoil, NoOfCoils, Array Values.a(1))
  ; ============================================================================
  ; NAME: TCP_WriteMultipleCoils
  ; DESC: Modbus TCP-WriteMultipleCoils
  ; DESC: FunctionCode = 15 : #MODBUS_FC_WRITE_MULTIPLE_COILS
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(StartCoil) : [1..65535]
  ; VAR(NoOfCoils) : [1..1968]
  ; RET.i : Modbus Result
  ; ============================================================================
    
    Protected MRes.i
        
    ProcedureReturn MRes
  EndProcedure
   
  Procedure.i TCP_WriteMultipleOutRegisters(*Modbus.TModbusTCP, DeviceID, StartRegister, NoORegisters, Array Values.u(1))
  ; ============================================================================
  ; NAME: TCP_WriteMultipleOutRegisters
  ; DESC: Modbus TCP-WriteMultipleOutRegisters
  ; DESC: FunctionCode = 16 : ##MODBUS_FC_WRITE_MULTIPLE_REGISTERS
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; VAR(StartRegister) : [1..65535]
  ; VAR(NoORegisters) : [1..123]
  ; RET.i : Modbus Result
  ; ============================================================================
       
  EndProcedure
  
  Procedure.i TCP_ReadExceptionStatus(*Modbus.TModbusTCP)
  ; ============================================================================
  ; NAME: TCP_ReadExceptionStatus
  ; DESC: Modbus TCP-ReadExceptionStatus
  ; DESC: FunctionCode = 7 : #MODBUS_FC_READ_EXCEPTION_STATUS
  ; VAR(*Modbus.TModbusTCP) : Modbus *This Data
  ; RET.i : Modbus Result
  ; ============================================================================
   
    Protected MRes.i    
    
    ProcedureReturn MRes 
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- DataSection
  ;- ----------------------------------------------------------------------

  DataSection
    ModBus_CRCTable: ; for BigEndian Data
    Data.u $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241
    Data.u $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440     
    Data.u $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40     
    Data.u $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841     
    Data.u $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40     
    Data.u $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41     
    Data.u $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641     
    Data.u $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040     
    Data.u $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240     
    Data.u $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441     
    Data.u $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41    
    Data.u $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840
    Data.u $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41
    Data.u $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40     
    Data.u $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640
    Data.u $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041
    Data.u $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240
    Data.u $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441
    Data.u $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41
    Data.u $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840
    Data.u $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41
    Data.u $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40
    Data.u $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640
    Data.u $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041
    Data.u $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241
    Data.u $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440
    Data.u $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40
    Data.u $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841
    Data.u $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40
    Data.u $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41
    Data.u $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641
    Data.u $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040

    ModBusExceptions:
    Data.s "Illegal function",      "The function code received in the request is not allowed on the server!"
    Data.s "Illegal data adress",   "The data address received in the request is not allowed on the server!"
    Data.s "Illegal data value",    "The value contained in the request data field is not allowed on the server!"
    Data.s "Slave or server failure", "An unrecoverable error occurred!"
    Data.s "Acknowledge failure",   "The server has accepted the requests and it processing it, but a long duration of time will be required To do so!"
    Data.s "Slave or server busy",  "The server is engaged in a long-duration program command!"
    Data.s "Negative acknowledge",  "Negative acknowledge "
    Data.s "Memroy parity failure", "The server attempted to read record file, but detected a parity error in memory!"
    Data.s "Not definded", " "
    Data.s "Gateway path unavailabel",  "The gateway is probably misconfigured or overloaded!"
    Data.s "Gateway target failure",    "Didn't get a response from target device!"
    Data.s "Exception max",             "Exception max "
    Data.s #Null$
  EndDataSection

EndModule


; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 1205
; FirstLine = 1179
; Folding = -----------
; Optimizer
; CPU = 5