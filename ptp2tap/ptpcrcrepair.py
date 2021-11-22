import argparse
import os


ap = argparse.ArgumentParser()

ap.add_argument("infiles", nargs="+", help="input filenames")
ap.add_argument("-v", "--verbose", action="store_true", help="detailed output during converting")
ap.add_argument("-s", "--split", action="store_true", help="split to multiple output files")
args = vars(ap.parse_args())


for inname in args["infiles"]:
    print("Opening {}".format(inname))
    ouname = os.path.splitext(inname)[0]

    infile = open(inname, "rb")
    tap = b''
    ptpfile = infile.read()
    ptpslice = 1

    while ptpfile:
        if ptpfile[0] != 0xFF:
            print("Header error")
            break

        tap += ptpfile[:3]

        ptplen = (ptpfile[1] + (ptpfile[2] << 8)) - 3
        ptpdata = ptpfile[3:3+ptplen]
        ptpfile = ptpfile[3+ptplen:]   

        while ptpdata:
            if not (ptpdata[0] in (0x55, 0xAA)):
                print("Blocktype error")
                break

            ptpblk = ptpdata[0]
            blklen = ptpdata[1] + (ptpdata[2] << 8)
            blkdata = ptpdata[3:blklen+3]
            ptpdata = ptpdata[3+blklen:]
            blktyp = blkdata[0]
            blknum = blkdata[1]
            chksum = 0
            for i in blkdata[1:-1]:
                chksum += i
            chksum &= 0xFF

            if args["verbose"]:
                print("Block #{:02x} (type={:02x}H, len={:03x}H)".format(blknum, blktyp, blklen))
                print("              (checksum calc={:02x}H, file={:02x}H)".format(chksum, blkdata[-1]))

            tap += bytes([ptpblk, blklen & 0xFF, blklen >> 8])
            tap += bytes(blkdata[:-1]) + bytes([chksum])
            
    oufile = open(ouname + ".corr.ptp", "wb")
    oufile.write(tap)
    oufile.close()

    infile.close()
      
    
