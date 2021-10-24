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
BIT0_US_HS = 1248
BIT1_US_HS = 416


import argparse
import os


def writebytes(b):
    byt = b""

    for bb in b:
        for i in range(8):
            byt += bit1 if (bb & (0x80 >> i)) else bit0
    return byt
    
def writetap(tapname, dta):
    oufile = open(tapname,"wb")
    lt = len(dta)
    tap = taphead
    tap += bytes([lt & 0xFF, (lt >> 8) & 0xFF, (lt >> 16) & 0xFF, (lt >> 24) & 0xFF])
    tap += dta
    oufile.write(tap)
    oufile.close()
    print("{} written, {} bytes".format(tapname, len(tap)))
    

ap = argparse.ArgumentParser()

ap.add_argument("infiles", nargs="+", help="input filenames")
ap.add_argument("-v", "--verbose", action="store_true", help="detailed output during converting")
ap.add_argument("-s", "--split", action="store_true", help="split to multiple output files")
ap.add_argument("-H", "--highspeed", action="store_true", help="high-speed (3.75MHz) Primo timings")
ap.add_argument("-S", "--silence", type=int, default=SILENCE_MS, help="silence in ms before program header")
ap.add_argument("-C", "--clock", type=int, default=CLOCK_HZ, help="tap file clock frequency in Hz")
args = vars(ap.parse_args())


# setting up representation of 0 and 1 bits in Primo TAP output
bit0us = BIT0_US_HS if args["highspeed"] else BIT0_US
bit1us = BIT1_US_HS if args["highspeed"] else BIT1_US
bit0 = bytes([int(bit0us * args["clock"] / 1000000 / CLK_PER_TICK)])
bit1 = bytes([int(bit1us * args["clock"] / 1000000 / CLK_PER_TICK)])

# TAP file header
taphead = b"C64-TAPE-RAW" + bytes([0x01, 0x00, 0x00, 0x00])

# silence representation in TAP file
sillen = int(args["silence"] * args["clock"] / 1000 / CLK_PER_TICK)
silence = bytes([0x00, sillen & 0xFF, (sillen >> 8) & 0xFF, (sillen >> 16) & 0xFF])

# building a Primo file header
header = b""
for i in range(HEADER_LEN):
    header += writebytes(bytes([HEADER_DTA]))
    
# building up a Primo block synchron sequence
blksyn = b""
for i in range(SYNC_LEN):
    blksyn += writebytes(bytes([SYNC_DTA]))
blksyn += writebytes(bytes(SYNC_END))


for inname in args["infiles"]:
    print("Opening {}".format(inname))
    ouname = os.path.splitext(inname)[0]

    infile = open(inname,"rb")
    tap = b''
    ptpfile = infile.read()
    ptpslice = 1

    while ptpfile:
        if ptpfile[0] != 0xFF:
            print("Header error")
            break
        
        ptplen = (ptpfile[1] + (ptpfile[2] << 8)) - 3
        ptpdata = ptpfile[3:3+ptplen]
        ptpfile = ptpfile[3+ptplen:]   

        tap += silence
        tap += header
    
        while ptpdata:
            if not (ptpdata[0] in (0x55, 0xAA)):
                print("Blocktype error")
                break
        
            blklen = ptpdata[1] + (ptpdata[2] << 8)
            blkdata = ptpdata[3:blklen+3]
            ptpdata = ptpdata[3+blklen:]
            blktyp = blkdata[0]
            blknum = blkdata[1]
        
            if args["verbose"]:
                print("Block #{:02x} (type={:02x}H, len={:03x}H)".format(blknum, blktyp, blklen))
        
            tap += blksyn
            tap += writebytes(blkdata)
            
        else:
            if args["split"]:
                writetap(ouname + "_[{:02d}].tap".format(ptpslice), tap)
                ptpslice += 1
                tap = b''
                

    if not args["split"]:
        writetap(ouname + ".tap", tap)
        
    infile.close()
      
    
