;
; Primo test
; must be assembled to address 0
;



;
; out register at address 0
;
OPORT   equ     0

;
; out register bits
;
; 7 - NMI enable (enabled by 1)
; 6 - joystick CLK?
; 5 - tape device control (turn on tape by 0)
; 4 - buzzer output
; 3 - video A/B plane switch (0 - lower, 1 - upper)
; 2 - RSR232 output
; 1 - tape signal output #1
; 0 - tape signal output #2

;
; default values for out register bits
;
BIT7_NMI                equ     0
BIT6_JCK                equ     0
BIT5_TC                 equ     1
BIT4_BUZ                equ     0
BIT3_VP                 equ     1
BIT2_RS                 equ     0
BIT1_T1                 equ     0
BIT0_T0                 equ     1

;
; default out register value
;
DEFVAL  equ     ((BIT7_NMI << 7) |
                 (BIT6_JCK << 6) |
                 (BIT5_TC  << 5) |
                 (BIT4_BUZ << 4) |
                 (BIT3_VP  << 3) |
                 (BIT2_RS  << 2) |
                 (BIT1_T1  << 1) |
                 (BIT0_T0  << 0))


;
; ROM beep parameters
;
BEEPTM          equ     100
BEEPLN          equ     200
BEEPON          equ     00010000b




;
; ROM addresses,sizes
;
ROMBEG          equ     #0000
ROMLEN          equ     #4000

ROM0BEG         equ     #0000
ROM0LEN         equ     #1000
ROM1BEG         equ     #1000
ROM1LEN         equ     #1000
ROM2BEG         equ     #2000
ROM2LEN         equ     #1000
ROM3BEG         equ     #3000
ROM3LEN         equ     #1000-8


RAMBEG  equ     #4000
SCRLEN  equ     #1800


; test loop count
TSTCNT  equ     1



; ROM macros for beep and delay
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
        ld      b,BEEPLN
bloop:
        ld      a,DEFVAL
        out     (OPORT),a
        DELAY(BEEPTM)
        ld      a,DEFVAL | BEEPON
        out     (OPORT),a
        DELAY(BEEPTM)
        djnz    bloop
        mend


BEEPS   macro(n)
        ld      c,n
bsloop:
        BEEP()
        DELAY(BEEPTM * BEEPLN)
        dec     c
        jp      nz,bsloop
        ld      b,4
sloop:
        DELAY(BEEPTM * BEEPLN)
        djnz    sloop
        mend




        segment code = $0000,$4000
        segment data = $4000,$0100


segment data

ramlen  ds      2
scrbeg  ds      2



segment code

;
;
; start main code
;
;

        org     0

start:
        ld      a,DEFVAL
        out     (OPORT),a

        BEEPS(1)


;
; ROM data read and check
;

; ROM0
        ld      b,TSTCNT

rom0loop:
        exx

        ld      hl,ROM0BEG
        ld      bc,ROM0LEN
        ld      de,0
rl0:
        ld      a,(hl)
        add     e
        ld      e,a

        ld      a,(hl)
        xor     d
        ld      d,a

        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,rl0

        ld      a,(chksum)
        cp      d
        jp      nz,rom0err

        ld      a,(chksum+1)
        cp      e
        jp      nz,rom0err

        exx
        djnz    rom0loop


; ROM1
        ld      b,TSTCNT

rom1loop:
        exx

        ld      hl,ROM1BEG
        ld      bc,ROM1LEN
        ld      de,0
rl1:
        ld      a,(hl)
        add     e
        ld      e,a

        ld      a,(hl)
        xor     d
        ld      d,a

        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,rl1

        ld      a,(chksum+2)
        cp      d
        jp      nz,rom1err

        ld      a,(chksum+3)
        cp      e
        jp      nz,rom1err

        exx
        djnz    rom1loop


; ROM2
        ld      b,TSTCNT

rom2loop:
        exx

        ld      hl,ROM2BEG
        ld      bc,ROM2LEN
        ld      de,0
rl2:
        ld      a,(hl)
        add     e
        ld      e,a

        ld      a,(hl)
        xor     d
        ld      d,a

        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,rl2

        ld      a,(chksum+4)
        cp      d
        jp      nz,rom2err

        ld      a,(chksum+5)
        cp      e
        jp      nz,rom2err

        exx
        djnz    rom2loop


; ROM3
        ld      b,TSTCNT

rom3loop:
        exx

        ld      hl,ROM3BEG
        ld      bc,ROM3LEN
        ld      de,0
rl3:
        ld      a,(hl)
        add     e
        ld      e,a

        ld      a,(hl)
        xor     d
        ld      d,a

        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,rl3

        ld      a,(chksum+6)
        cp      d
        jp      nz,rom3err

        ld      a,(chksum+7)
        cp      e
        jp      nz,rom3err

        exx
        djnz    rom3loop



; RAM test for "page 0" - 256 bytes from RAM start


        ld      c,TSTCNT

ramloop:
        ld      hl,RAMBEG
        ld      b,0

raml0:
        ld      (hl),c
        ld      a,c
        cp      (hl)
        jp      nz,ramerr

        inc     hl
        djnz    raml0

        dec     c
        jp      nz,ramloop


;
; RAM page 0 is usable, setting up stack
;

        ld      hl,RAMBEG
        inc     h
        dec     hl
        dec     hl
        ld      sp,hl

;
; sizing RAM
;

        ld      hl,RAMBEG
        inc     h
sizloop:
        ld      e,(hl)

        ld      a,#55
        ld      (hl),a
        cp      (hl)
        ld      (hl),e
        jp      nz,sizend

        ld      a,#AA
        ld      (hl),a
        cp      (hl)
        ld      (hl),e
        jp      nz,sizend

        ld      a,#CC
        ld      (hl),a
        cp      (hl)
        ld      (hl),e
        jp      nz,sizend

        ld      a,#33
        ld      (hl),a
        cp      (hl)
        ld      (hl),e
        jp      nz,sizend

        inc     hl
        ld      a,l
        or      h
        jp      nz,sizloop

sizend:
        ; emulator fix
        ld      a,h
        and     #c0
        ld      h,a
        ld      a,#0
        ld      l,a

        ld      de,-RAMBEG
        add     hl,de
        ld      (ramlen),hl

        ld      de,-SCRLEN
        add     hl,de
        ld      de,RAMBEG
        add     hl,de
        ld      (scrbeg),hl


;
; initial screen "counting"
;

        ld      a,TSTCNT

cntloop:
        ex      af,af'

        ld      hl,(scrbeg)
        ld      bc,SCRLEN
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
; screen inverting test
;

invfill:
        ld      hl,(scrbeg)
        ld      bc,SCRLEN

il0:
        ld      (hl),#f0
        inc     hl
        dec     bc
        ld      a,c
        or      b
        jp      nz,il0

        ld      a,TSTCNT
invloop:
        ex      af,af'

        ld      hl,(scrbeg)
        ld      bc,SCRLEN
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


        jp      start


; error beeps

rom0err:
        BEEPS(2)
        DELAY(0)
        jp      start

rom1err:
        BEEPS(3)
        DELAY(0)
        jp      start

rom2err:
        BEEPS(4)
        DELAY(0)
        jp      start

rom3err:
        BEEPS(5)
        DELAY(0)
        jp      start


ramerr:
        BEEPS(6)
        DELAY(0)
        jp      start



        noflow

fill:
        repeat
                db      zeusrand
        until . >= ROMLEN - 8

chksum:
        db      xor_mem(ROM0BEG,ROM0LEN)
        db      sum_mem(ROM0BEG,ROM0LEN)
        db      xor_mem(ROM1BEG,ROM1LEN)
        db      sum_mem(ROM1BEG,ROM1LEN)
        db      xor_mem(ROM2BEG,ROM2LEN)
        db      sum_mem(ROM2BEG,ROM2LEN)
        db      xor_mem(ROM3BEG,ROM3LEN)
        db      sum_mem(ROM3BEG,ROM3LEN)



output_bin "primotest2.rom", ROMBEG, ROMLEN
output_intel "primotest2.hex", ROMBEG, ROMLEN


