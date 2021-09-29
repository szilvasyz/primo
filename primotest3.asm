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
BEEPLN          equ     100
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
SCRLEN  equ     #400

DECLEN  equ     5


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
        DELAY(0)
        mend







        segment code = $0000,$4000
        segment data = $4000,$0100




segment data

rambeg  ds      2
ramend  ds      2
scrbeg  ds      2
scrlen  ds      2
scrx    ds      1
scry    ds      1
decbuf  ds      DECLEN
retncnt ds      2
kbdcnt  ds      1




;
;
; start main code
;
;


; cold start - reset, rst entries
segment code
        org     #0
        ld      a,DEFVAL
        out     (OPORT),a
        jp      start

        org     #8
        ret

        org     #10
        ret

        org     #18
        ret

        org     #20
        ret

        org     #28
        ret

        org     #30
        ret

        org     #38
        ret


; NMI entry point
segment code
        org     #66

        push    hl
        ld      hl,retncnt
        inc     (hl)
        jr      nz,retn_ret
        inc     hl
        inc     (hl)
retn_ret:
        pop     hl
        retn


; main program
segment code

start:

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



;
; RAM test for "page 0" - 256 bytes from RAM start
;

        BEEPS(2)


        ld      c,TSTCNT

ramloop:

        ld      hl,RAMBEG
        ld      b,0
rami_l0:
        ld      (hl),b
        inc     hl
        djnz    rami_l0

        DELAY(0)

        ld      hl,RAMBEG
        ld      b,0

raml0:
        ld      a,b
        ld      e,0
raml1:
        cp      a,(hl)
        jp      nz,ramerr
        dec     e
        jp      nz,raml1

        ld      a,#55
        ld      (hl),a
        ld      e,0
raml2:
        cp      a,(hl)
        jp      nz,ramerr
        dec     e
        jp      nz,raml2

        ld      a,#AA
        ld      (hl),a
        ld      e,0
raml3:
        cp      a,(hl)
        jp      nz,ramerr
        dec     e
        jp      nz,raml3

        ld      a,#CC
        ld      (hl),a
        ld      e,0
raml4:
        cp      a,(hl)
        jp      nz,ramerr
        dec     e
        jp      nz,raml4

        ld      a,#33
        ld      (hl),a
        ld      e,0
raml5:
        cp      a,(hl)
        jp      nz,ramerr
        dec     e
        jp      nz,raml5

        inc     hl
        djnz    raml0

        dec     c
        jp      nz,ramloop


;
; RAM page 0 is usable, setting up stack
;

        ld      (rambeg),hl
        dec     hl
        dec     hl
        ld      sp,hl

;
; sizing RAM
;

        BEEPS(3)

        ld      hl,(rambeg)

sizram_l0:
        call    testbyte
        jp      nz,sizend
        inc     hl
        ld      a,h
        or      l
        jp      nz,sizram_l0

sizend:
        BEEPS(4)
;        ld      l,#00
;        ld      a,#C0
;        and     h
;        ld      h,a
        dec     hl
        ld      de,SCRLEN
        ld      (scrlen),de
;        or      a
;        sbc     hl,de
        ld      (ramend),hl


testloop:
        call    kbdstest

        ld      de,(scrlen)
        ld      hl,#6000
        or      a
        sbc     hl,de

        ld      b,6
        ld      c,'0'

scrid_l0:
        push    hl
        push    bc

        ld      (scrbeg),hl
        call    scrclr
        ld      hl,txt_screen
        call    scrtxt
        pop     bc
        push    bc
        ld      a,c
        call    scrchr
        call    scrnl


        ld      hl,txt_totalram
        call    scrtxt
        ld      hl,(ramend)
        ld      de,RAMBEG
        or      a
        sbc     hl,de
        inc     hl

        ld      l,h
        srl     l
        srl     l
        ld      h,0
        call    scrdec
        call    scrnl


        ld      hl,txt_skeys
        call    scrtxt
        ld      a,(kbdcnt)
        ld      l,a
        ld      h,0
        call    scrdec
        call    scrnl


        pop     bc
        pop     hl
        ld      de,#2000
        add     hl,de
        inc     c
        djnz    scrid_l0



        ld      hl,0
        call    delay

        jp      start



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


        ld      hl,0
        call    delay

        jp      start


;
; subroutines
;

delay:
        push    af
delay_l0:
        dec     hl
        ld      a,l
        or      h
        jp      nz,delay_l0
        pop     af
        ret


testbyte:
        push    de
        ld      e,(hl)

        ld      a,#55
        ld      (hl),a
        cp      (hl)
        jr      nz,testbret

        ld      a,#AA
        ld      (hl),a
        cp      (hl)
        jr      nz,testbret

        ld      a,#CC
        ld      (hl),a
        cp      (hl)
        jr      nz,testbret

        ld      a,#33
        ld      (hl),a
        cp      (hl)
        jr      nz,testbret

testbret:
        ld      (hl),e
        pop     de
        ret


kbdstest:
        ld      bc,#4000
        ld      e,0
kbdst_l0:
        in      a,(c)
        and     1
        add     e
        ld      e,a
        inc     c
        djnz    kbdst_l0
        ld      (kbdcnt),a
        ret






;
; screen handling
;

scrclr:
        ld      hl,(scrbeg)
        ld      bc,(scrlen)
scrclr_1:
        ld      (hl),0
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,scrclr_1
        ld      a,0
        ld      (scrx),a
        ld      (scry),a
        ret


scrtxt:
        ld      a,(hl)
        or      a
        ret     z
        call    scrchr
        inc     hl
        jp      scrtxt


scrhexw:
        push    hl
        ld      a,h
        call    scrhexb
        pop     hl
        ld      a,l

scrhexb:
        push    af
        rra
        rra
        rra
        rra
        call    scrhexn
        pop     af

scrhexn:
        and     #0f
        ld      e,a
        ld      d,0
        ld      hl,txt_hexchr
        add     hl,de
        ld      a,(hl)
        jp      scrchr


        pop     hl
        ret

scrchr:
        push    hl
        push    de
        push    bc
        sub     ' '
        jp      nc,scrchr_1
        ld      a,0

scrchr_1:
        cp      #60
        jp      c,scrchr_2
        ld      a,'.'-' '

scrchr_2:
        ld      e,a
        ld      d,0
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        ld      hl,chartab
        add     hl,de
        ex      de,hl

        ld      hl,(scrbeg)
        ld      a,(scrx)
        add     h
        ld      h,a
        ld      a,(scry)
        add     l
        ld      l,a

        ld      b,8

scrchr_l1:
        ld      a,(de)
        ld      c,8
scrchr_l2:
        rla
        rr      (hl)
        dec     c
        jr      nz,scrchr_l2
        ld      a,#20
        add     a,l
        ld      l,a
        inc     de
        djnz    scrchr_l1

        ld      hl,scry
        inc     (hl)
        ld      a,(hl)
        cp      #20
        call    nc,scrnl

scrchr_ret:
        pop     bc
        pop     de
        pop     hl
        ret


scrnl:
        push    hl
        push    de
        push    bc

        ld      a,0
        ld      (scry),a
        ld      a,(scrx)
        inc     a
        ld      hl,(scrlen)
        cp      h
        jp      c,scrnl_end

        ld      hl,(scrbeg)
        ld      bc,(scrlen)
        ld      e,l
        ld      d,h
        inc     d

        dec     b
        jp      z,scrnl_l2

scrnl_l1:
        ld      a,(de)
        ld      (hl),a
        inc     de
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jp      nz,scrnl_l1

scrnl_l2:
        ld      (hl),0
        inc     hl
        djnz    scrnl_l2
        ld      a,(scrx)

scrnl_end:
        ld      (scrx),a

        pop     bc
        pop     de
        pop     hl

        ret


scrdec:
        ex      de,hl

        ld      b,DECLEN
        ld      hl,decbuf

todec_l0:
        ld      (hl),0
        inc     hl
        djnz    todec_l0

        ld      c,16

todec_l1:
        ld      b,DECLEN
        ld      hl,decbuf

todec_l2:
        ld      a,(hl)
        and     #0f
        cp      a,5
        jp      c,todec_1
        add     a,#83
todec_1:
        ld      (hl),a

        inc     hl
        djnz    todec_l2

        rl      e
        rl      d

        ld      b,DECLEN
        ld      hl,decbuf

todec_l3:
        rl      (hl)
        inc     hl
        djnz    todec_l3

        dec     c
        jp      nz,todec_l1

        ld      b,DECLEN
        ld      hl,decbuf+DECLEN

todec_l4:
        dec     hl
        ld      a,(hl)
        and     #0f
        ld      (hl),a
        add     '0'
        call    scrchr
        djnz    todec_l4

        ret

;
;
;

txt_hexchr      db      "0123456789ABCDEF"
txt_totalram    db      "RAM KB: ",0
txt_screen      db      "Screen #",0
txt_skeys       db      "Stuck keys: ",0

chartab:
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 // U+0020 (space)
        db 0x18, 0x3C, 0x3C, 0x18, 0x18, 0x00, 0x18, 0x00 // U+0021 (!)
        db 0x36, 0x36, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 // U+0022 (")
        db 0x36, 0x36, 0x7F, 0x36, 0x7F, 0x36, 0x36, 0x00 // U+0023 (#)
        db 0x0C, 0x3E, 0x03, 0x1E, 0x30, 0x1F, 0x0C, 0x00 // U+0024 ($)
        db 0x00, 0x63, 0x33, 0x18, 0x0C, 0x66, 0x63, 0x00 // U+0025 (%)
        db 0x1C, 0x36, 0x1C, 0x6E, 0x3B, 0x33, 0x6E, 0x00 // U+0026 (&)
        db 0x06, 0x06, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00 // U+0027 (')
        db 0x18, 0x0C, 0x06, 0x06, 0x06, 0x0C, 0x18, 0x00 // U+0028 (()
        db 0x06, 0x0C, 0x18, 0x18, 0x18, 0x0C, 0x06, 0x00 // U+0029 ())
        db 0x00, 0x66, 0x3C, 0xFF, 0x3C, 0x66, 0x00, 0x00 // U+002A (*)
        db 0x00, 0x0C, 0x0C, 0x3F, 0x0C, 0x0C, 0x00, 0x00 // U+002B (+)
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0x0C, 0x06 // U+002C (,)
        db 0x00, 0x00, 0x00, 0x3F, 0x00, 0x00, 0x00, 0x00 // U+002D (-)
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0x0C, 0x00 // U+002E (.)
        db 0x60, 0x30, 0x18, 0x0C, 0x06, 0x03, 0x01, 0x00 // U+002F (/)
        db 0x3E, 0x63, 0x73, 0x7B, 0x6F, 0x67, 0x3E, 0x00 // U+0030 (0)
        db 0x0C, 0x0E, 0x0C, 0x0C, 0x0C, 0x0C, 0x3F, 0x00 // U+0031 (1)
        db 0x1E, 0x33, 0x30, 0x1C, 0x06, 0x33, 0x3F, 0x00 // U+0032 (2)
        db 0x1E, 0x33, 0x30, 0x1C, 0x30, 0x33, 0x1E, 0x00 // U+0033 (3)
        db 0x38, 0x3C, 0x36, 0x33, 0x7F, 0x30, 0x78, 0x00 // U+0034 (4)
        db 0x3F, 0x03, 0x1F, 0x30, 0x30, 0x33, 0x1E, 0x00 // U+0035 (5)
        db 0x1C, 0x06, 0x03, 0x1F, 0x33, 0x33, 0x1E, 0x00 // U+0036 (6)
        db 0x3F, 0x33, 0x30, 0x18, 0x0C, 0x0C, 0x0C, 0x00 // U+0037 (7)
        db 0x1E, 0x33, 0x33, 0x1E, 0x33, 0x33, 0x1E, 0x00 // U+0038 (8)
        db 0x1E, 0x33, 0x33, 0x3E, 0x30, 0x18, 0x0E, 0x00 // U+0039 (9)
        db 0x00, 0x0C, 0x0C, 0x00, 0x00, 0x0C, 0x0C, 0x00 // U+003A (:)
        db 0x00, 0x0C, 0x0C, 0x00, 0x00, 0x0C, 0x0C, 0x06 // U+003B (;)
        db 0x18, 0x0C, 0x06, 0x03, 0x06, 0x0C, 0x18, 0x00 // U+003C (<)
        db 0x00, 0x00, 0x3F, 0x00, 0x00, 0x3F, 0x00, 0x00 // U+003D (=)
        db 0x06, 0x0C, 0x18, 0x30, 0x18, 0x0C, 0x06, 0x00 // U+003E (>)
        db 0x1E, 0x33, 0x30, 0x18, 0x0C, 0x00, 0x0C, 0x00 // U+003F (?)
        db 0x3E, 0x63, 0x7B, 0x7B, 0x7B, 0x03, 0x1E, 0x00 // U+0040 (@)
        db 0x0C, 0x1E, 0x33, 0x33, 0x3F, 0x33, 0x33, 0x00 // U+0041 (A)
        db 0x3F, 0x66, 0x66, 0x3E, 0x66, 0x66, 0x3F, 0x00 // U+0042 (B)
        db 0x3C, 0x66, 0x03, 0x03, 0x03, 0x66, 0x3C, 0x00 // U+0043 (C)
        db 0x1F, 0x36, 0x66, 0x66, 0x66, 0x36, 0x1F, 0x00 // U+0044 (D)
        db 0x7F, 0x46, 0x16, 0x1E, 0x16, 0x46, 0x7F, 0x00 // U+0045 (E)
        db 0x7F, 0x46, 0x16, 0x1E, 0x16, 0x06, 0x0F, 0x00 // U+0046 (F)
        db 0x3C, 0x66, 0x03, 0x03, 0x73, 0x66, 0x7C, 0x00 // U+0047 (G)
        db 0x33, 0x33, 0x33, 0x3F, 0x33, 0x33, 0x33, 0x00 // U+0048 (H)
        db 0x1E, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x1E, 0x00 // U+0049 (I)
        db 0x78, 0x30, 0x30, 0x30, 0x33, 0x33, 0x1E, 0x00 // U+004A (J)
        db 0x67, 0x66, 0x36, 0x1E, 0x36, 0x66, 0x67, 0x00 // U+004B (K)
        db 0x0F, 0x06, 0x06, 0x06, 0x46, 0x66, 0x7F, 0x00 // U+004C (L)
        db 0x63, 0x77, 0x7F, 0x7F, 0x6B, 0x63, 0x63, 0x00 // U+004D (M)
        db 0x63, 0x67, 0x6F, 0x7B, 0x73, 0x63, 0x63, 0x00 // U+004E (N)
        db 0x1C, 0x36, 0x63, 0x63, 0x63, 0x36, 0x1C, 0x00 // U+004F (O)
        db 0x3F, 0x66, 0x66, 0x3E, 0x06, 0x06, 0x0F, 0x00 // U+0050 (P)
        db 0x1E, 0x33, 0x33, 0x33, 0x3B, 0x1E, 0x38, 0x00 // U+0051 (Q)
        db 0x3F, 0x66, 0x66, 0x3E, 0x36, 0x66, 0x67, 0x00 // U+0052 (R)
        db 0x1E, 0x33, 0x07, 0x0E, 0x38, 0x33, 0x1E, 0x00 // U+0053 (S)
        db 0x3F, 0x2D, 0x0C, 0x0C, 0x0C, 0x0C, 0x1E, 0x00 // U+0054 (T)
        db 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x3F, 0x00 // U+0055 (U)
        db 0x33, 0x33, 0x33, 0x33, 0x33, 0x1E, 0x0C, 0x00 // U+0056 (V)
        db 0x63, 0x63, 0x63, 0x6B, 0x7F, 0x77, 0x63, 0x00 // U+0057 (W)
        db 0x63, 0x63, 0x36, 0x1C, 0x1C, 0x36, 0x63, 0x00 // U+0058 (X)
        db 0x33, 0x33, 0x33, 0x1E, 0x0C, 0x0C, 0x1E, 0x00 // U+0059 (Y)
        db 0x7F, 0x63, 0x31, 0x18, 0x4C, 0x66, 0x7F, 0x00 // U+005A (Z)
        db 0x1E, 0x06, 0x06, 0x06, 0x06, 0x06, 0x1E, 0x00 // U+005B ([)
        db 0x03, 0x06, 0x0C, 0x18, 0x30, 0x60, 0x40, 0x00 // U+005C (\)
        db 0x1E, 0x18, 0x18, 0x18, 0x18, 0x18, 0x1E, 0x00 // U+005D (])
        db 0x08, 0x1C, 0x36, 0x63, 0x00, 0x00, 0x00, 0x00 // U+005E (^)
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF // U+005F (_)
        db 0x0C, 0x0C, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00 // U+0060 (`)
        db 0x00, 0x00, 0x1E, 0x30, 0x3E, 0x33, 0x6E, 0x00 // U+0061 (a)
        db 0x07, 0x06, 0x06, 0x3E, 0x66, 0x66, 0x3B, 0x00 // U+0062 (b)
        db 0x00, 0x00, 0x1E, 0x33, 0x03, 0x33, 0x1E, 0x00 // U+0063 (c)
        db 0x38, 0x30, 0x30, 0x3e, 0x33, 0x33, 0x6E, 0x00 // U+0064 (d)
        db 0x00, 0x00, 0x1E, 0x33, 0x3f, 0x03, 0x1E, 0x00 // U+0065 (e)
        db 0x1C, 0x36, 0x06, 0x0f, 0x06, 0x06, 0x0F, 0x00 // U+0066 (f)
        db 0x00, 0x00, 0x6E, 0x33, 0x33, 0x3E, 0x30, 0x1F // U+0067 (g)
        db 0x07, 0x06, 0x36, 0x6E, 0x66, 0x66, 0x67, 0x00 // U+0068 (h)
        db 0x0C, 0x00, 0x0E, 0x0C, 0x0C, 0x0C, 0x1E, 0x00 // U+0069 (i)
        db 0x30, 0x00, 0x30, 0x30, 0x30, 0x33, 0x33, 0x1E // U+006A (j)
        db 0x07, 0x06, 0x66, 0x36, 0x1E, 0x36, 0x67, 0x00 // U+006B (k)
        db 0x0E, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x1E, 0x00 // U+006C (l)
        db 0x00, 0x00, 0x33, 0x7F, 0x7F, 0x6B, 0x63, 0x00 // U+006D (m)
        db 0x00, 0x00, 0x1F, 0x33, 0x33, 0x33, 0x33, 0x00 // U+006E (n)
        db 0x00, 0x00, 0x1E, 0x33, 0x33, 0x33, 0x1E, 0x00 // U+006F (o)
        db 0x00, 0x00, 0x3B, 0x66, 0x66, 0x3E, 0x06, 0x0F // U+0070 (p)
        db 0x00, 0x00, 0x6E, 0x33, 0x33, 0x3E, 0x30, 0x78 // U+0071 (q)
        db 0x00, 0x00, 0x3B, 0x6E, 0x66, 0x06, 0x0F, 0x00 // U+0072 (r)
        db 0x00, 0x00, 0x3E, 0x03, 0x1E, 0x30, 0x1F, 0x00 // U+0073 (s)
        db 0x08, 0x0C, 0x3E, 0x0C, 0x0C, 0x2C, 0x18, 0x00 // U+0074 (t)
        db 0x00, 0x00, 0x33, 0x33, 0x33, 0x33, 0x6E, 0x00 // U+0075 (u)
        db 0x00, 0x00, 0x33, 0x33, 0x33, 0x1E, 0x0C, 0x00 // U+0076 (v)
        db 0x00, 0x00, 0x63, 0x6B, 0x7F, 0x7F, 0x36, 0x00 // U+0077 (w)
        db 0x00, 0x00, 0x63, 0x36, 0x1C, 0x36, 0x63, 0x00 // U+0078 (x)
        db 0x00, 0x00, 0x33, 0x33, 0x33, 0x3E, 0x30, 0x1F // U+0079 (y)
        db 0x00, 0x00, 0x3F, 0x19, 0x0C, 0x26, 0x3F, 0x00 // U+007A (z)
        db 0x38, 0x0C, 0x0C, 0x07, 0x0C, 0x0C, 0x38, 0x00 // U+007B ({)
        db 0x18, 0x18, 0x18, 0x00, 0x18, 0x18, 0x18, 0x00 // U+007C (|)
        db 0x07, 0x0C, 0x0C, 0x38, 0x0C, 0x0C, 0x07, 0x00 // U+007D (})
        db 0x6E, 0x3B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 // U+007E (~)
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}    // U+007F



; error beeps

rom0err:
        BEEPS(5)
        DELAY(0)
        jp      start

rom1err:
        BEEPS(6)
        DELAY(0)
        jp      start

rom2err:
        BEEPS(7)
        DELAY(0)
        jp      start

rom3err:
        BEEPS(8)
        DELAY(0)
        jp      start


ramerr:
        BEEPS(9)
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



output_bin "primotest3.rom", ROMBEG, ROMLEN
output_intel "primotest3.hex", ROMBEG, ROMLEN


