;
; Primo test
; must assemble to address 0
;



;
; out register at address 0
;
; out register bits:
; 7 - NMI enable (enabled by 1)
; 6 - joystick CLK?
; 5 - tape device control (turn on tape by 0)
; 4 - buzzer output
; 3 - video A/B plane switch (0 - lower, 1 - upper)
; 2 - RSR232 output
; 1 - tape signal output #1
; 0 - tape signal output #2
;
; default value: 00101001b
;

vplane  equ     0


oport   equ     0
defval  equ     00100001b | (vplane << 3)
beeptm  equ     200
beepln  equ     200
beepon  equ     00010000b
scrbeg  equ     #4800 + (#2000 * vplane)
scrlen  equ     #1800

rambeg  equ     #4000

rombeg  equ     #0000
romend  equ     #4000

tstcnt  equ     0


DELAY   macro(ticks)
        exx
        ld      hl,ticks
dloop:
        dec     hl
        ld      a,l
        or      h
        jp      nz,dloop
        exx
        mend

BEEP    macro()
        ld      b,beepln
bloop:
        ld      a,defval
        out     (oport),a
        DELAY(beeptm)
        ld      a,defval+beepon
        out     (oport),a
        DELAY(beeptm)
        djnz    bloop
        mend


BEEPS   macro(n)
        ld      c,n
bsloop:
        BEEP()
        DELAY(beeptm * beepln)
        dec     c
        jp      nz,bsloop
        ld      b,4
sloop:
        DELAY(beeptm * beepln)
        djnz    sloop
        mend



        org     0

        ld      a,defval
        out     (oport),a

        BEEPS(1)


;
; initial screen "counting"
;

        ld      a,tstcnt

cntloop:
        ex      af,af'

        ld      hl,scrbeg
        ld      bc,scrlen
cl0:
        ex      af,af'
        ld      (hl),a
        ex      af,af'
        inc     hl
        dec     bc
        ld      a,c
        or      b
        jp      nz,cl0

        DELAY(#1000)

        ex      af,af'
        dec     a
        jp      nz,cntloop


;
; ROM filled data read and check
;
        ld      b,tstcnt

romloop:
        exx

        ld      hl,fill
        ld      bc,chksum-fill
        ld      de,chkss
rl0:
        ld      a,(hl)
        add     e
        ld      e,a
        jp      nc,rl1
        inc     d
rl1:
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,rl0

        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a

        add     hl,de
        ld      a,l
        or      h
        jp      nz,romerr

        exx
        djnz    romloop


;
; screen inverting test
;

invfill:
        ld      hl,scrbeg
        ld      bc,scrlen

il0:
        ld      (hl),#f0
        inc     hl
        dec     bc
        ld      a,c
        or      b
        jp      nz,il0

        ld      a,tstcnt
invloop:
        ex      af,af'

        ld      hl,scrbeg
        ld      bc,scrlen
il1:
        ld      a,#ff
        xor     (hl)
        ld      (hl),a
        inc     hl
        dec     bc
        ld      a,c
        or      b
        jp      nz,il1

        DELAY(#1000)

        ex      af,af'
        dec     a
        jp      nz,invloop


;
; RAM filled data read and check
;

        ld      b,tstcnt

ramloop:
        exx

ramfill:
        ld      hl,rambeg
        ld      de,rombeg
        ld      bc,romend-rombeg

af0:
        ld      a,(de)
        xor     #ff
        ld      (hl),a
        inc     hl
        inc     de
        dec     bc
        ld      a,c
        or      b
        jp      nz,af0

        ld      hl,rambeg+fill-rombeg
        ld      bc,chksum-fill
        ld      de,chkss
al0:
        ld      a,(hl)
        xor     #ff
        add     e
        ld      e,a
        jp      nc,al1
        inc     d
al1:
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,al0

        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        xor     #ff
        ld      l,a
        ld      a,h
        xor     #ff
        ld      h,a

        add     hl,de
        ld      a,l
        or      h
        jp      nz,ramerr

        exx
        djnz    ramloop


;
; sequencing test (address test)
;

        ld      b,tstcnt

seqloop:
        exx

        ld      hl,fill
        ld      bc,chksum-fill
        ld      e,rands
ql0:
        ld      a,(hl)
        cp      e
        jp      nz,seqerr

        srl     e
        jp      nc,ql1
        ld      a,poly
        xor     e
        ld      e,a
ql1:

        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,ql0

        exx
        djnz    seqloop

        jp      rombeg

        halt


romerr:
        BEEPS(2)
        DELAY(0)
        jp      0


ramerr:
        BEEPS(3)
        DELAY(0)
        jp      0


seqerr:
        BEEPS(4)
        DELAY(0)
        jp      0



        noflow

fill:
        rands = #12
        chkss = #1234

        chks = chkss
        rand = rands
        poly = #b8

        repeat
                db      rand
                chks = (chks + rand)
                carry = (rand and 1)
                rand = rand / 2
                if carry
                        rand = rand xor poly
                endif
        until . >= romend - 2

chksum:
        dw      -chks



output_bin "primotest1.rom", rombeg, romend
output_intel "primotest1.hex", rombeg, romend


