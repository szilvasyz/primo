CLOCK_HZ = 1000000
CLK_PER_TICK = 8

SILENCE_MS = 1000
HEADER_LEN = 512
HEADER_DTA = 0xAA

SYNC_LEN = 96
SYNC_DTA = 0xFF
SYNC_END = [0xD3, 0xD3, 0xD3]

BIT0_US = 1872
BIT1_US = 624

def writebytes(b):
    byt = b""

    for bb in b:
        for i in range(8):
            byt += bytes([int((BIT1_US if (bb & (0x80 >> i)) else  BIT0_US) * CLOCK_HZ / 1000000 / CLK_PER_TICK)])
    return byt
    

print("taphead")
taphead = b"C64-TAPE-RAW" + bytes([0x01, 0x00, 0x00, 0x00])
print("silence")
sillen = int(SILENCE_MS * CLOCK_HZ / 1000 / CLK_PER_TICK)
silence = bytes([0x00, sillen & 0xFF, (sillen >> 8) & 0xFF, (sillen >> 16) & 0xFF])
print("header")
header = b""
for i in range(HEADER_LEN):
    header += writebytes(bytes([HEADER_DTA]))
print("blksyn")
blksyn = b""
for i in range(SYNC_LEN):
    blksyn += writebytes(bytes([SYNC_DTA]))
blksyn += writebytes(bytes(SYNC_END))



print("start")


infile = open("demo.ptp","rb")
oufile = open("demo.tap","wb")
tap = b''


ptpfile = infile.read()
print(len(ptpfile))

tap += taphead


while ptpfile:
    if ptpfile[0] != 0xFF:
        print("Header error")
        exit(1)
        
    ptplen = (ptpfile[1] + (ptpfile[2] << 8)) - 3
    ptpdata = ptpfile[3:3+ptplen]
    ptpfile = ptpfile[3+ptplen:]   

    print(ptplen)

    tap += silence
    tap += header
    
    while ptpdata:
        if not (ptpdata[0] in (0x55, 0xAA)):
            print("Blocktype error")
            exit(1)
        
        blklen = ptpdata[1] + (ptpdata[2] << 8)
        blkdata = ptpdata[3:blklen+3]
        ptpdata = ptpdata[3+blklen:]
        blktyp = blkdata[0]
        blknum = blkdata[1]
        
        print("blklen={:d}, blktype={:02x}, blknum={:02x}".format(blklen, blktyp, blknum))
        
        tap += blksyn
        tap += writebytes(blkdata)

lt = len(tap)

oufile.write(taphead)
oufile.write(bytes([lt & 0xFF, (lt >> 8) & 0xFF, (lt >> 16) & 0xFF, (lt >> 24) & 0xFF]))
oufile.write(tap)
  
oufile.close()
infile.close()
      
    
