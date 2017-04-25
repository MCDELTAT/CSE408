### Serial Communication with Matlab

1. Create a serial port object
  * obj = serial('port', 'property name', property value, 'property name', property value...)
    * port: port name/Number
    * property_name: baudrate (bits/s)
    * property_name: databits
1. Open the object or file
  * fopen(filename);
1. Read the file
  * data = fread(filename, count);
    * count: number of elements
1. Close the file
  * fclose(filename);
1. Handle errors with try/catch
```
  try
    fclose(filename)
  catch  
  end  
```

### TinyOS Active Message Format
00 FF FF 00 00 04 22 06 00 02 00 03   

#### Reading Left to Right the Values Are:
1. 00 = null header
1. FF FF = destination address
1. 00 00 = link source address
1. 04 = length of payload in bytes, (blinkToRadio 2 bytes dest, 2 bytes counter )
1. 22 = group id
1. 06 = AM handler ID (the Amp. Mod type)
1. 00 02 = node id
1. 00 03 = counter Values

### Example 2 of Active message
7E 45 00 FF FF 00 01 04 00 63 03 AD 00 00 1B DB 7E

1. 7E = frame synchronization byte
1. 45 = packet byte
1. 03 AD 00 00 = payload
1. 1B DB = CRC byte (cyclic redundancy check)
