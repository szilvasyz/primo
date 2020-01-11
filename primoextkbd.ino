#define MA0 2
#define MA1 10
#define MA2 4
#define MA3 5
#define MA4 6
#define MA5 7
#define MWR 8
#define MDT 9

#define PS2CLK 3
#define PS2DTA 11





#define BUFFER_SIZE 45
#define BREAK 0x100
static volatile uint8_t buffer[BUFFER_SIZE];
static volatile uint8_t head, tail;
static volatile uint8_t brkcode = 0;





static int primokbd[64] = {
  26, //y
  117, //up
  27, //s
  18, //sht
  36, //e
  88, //upp
  29, //w
  20, //ctr
  35, //d
  38, //3
  34, //x
  30, //2
  21, //q
  22, //1
  28, //a
  114, //dn

  33, //c
  255, //???
  43, //f
  255, //???
  45, //r
  255, //???
  44, //t
  61, //7
  51, //h
  41, //sp
  50, //b
  54, //6
  52, //g
  46, //5
  42, //v
  37, //4

  49, //n
  62, //8
  53, //z
  93, //+
  60, //u
  14, //0
  59, //j
  97, //<
  75, //l
  74, //-
  66, //k
  73, //.
  58, //m
  70, //9
  67, //i
  65, //,

  78, //ü
  84, //'
  77, //p
  91, //ú
  68, //o
  13, //cls
  255, //???
  90, //ret
  255, //???
  107, //lt
  76, //é
  85, //ó
  82, //á
  116, //rt
  69, //ö
  118 //brk
};




void ps2interrupt(void) {
  static uint8_t bitcount=0;
  static uint8_t incoming=0;
  static uint32_t prev_ms=0;
  uint32_t now_ms;
  uint8_t n, val;

  digitalWrite(LED_BUILTIN, HIGH);

  val = digitalRead(PS2DTA);
  now_ms = millis();
  if (now_ms - prev_ms > 250) {
    bitcount = 0;
    incoming = 0;
  }
  prev_ms = now_ms;
  n = bitcount - 1;
  if (n <= 7) {
    incoming |= (val << n);
  }
  bitcount++;
  if (bitcount == 11) {
    uint8_t i = head + 1;
    if (i >= BUFFER_SIZE) i = 0;
    if (i != tail) {
      buffer[i] = incoming;
      head = i;
    }
    bitcount = 0;
    incoming = 0;
  }

  digitalWrite(LED_BUILTIN, LOW);

}



static inline uint16_t get_scan_code(void) {
  uint16_t c, i;

  i = tail;
  if (i == head) return 0;
  i++;
  if (i >= BUFFER_SIZE) i = 0;
  c = buffer[i];
  tail = i;
  if (c == 240) {
    brkcode = 1;
    return 0;
  }

  if (brkcode) {
    c |= BREAK;
    brkcode = 0;
  }
  return c;
}





void setaddr(int a) {
  digitalWrite(MA0, (a & 0x01) == 0 ? 0 : 1);
  digitalWrite(MA1, (a & 0x02) == 0 ? 0 : 1);
  digitalWrite(MA2, (a & 0x04) == 0 ? 0 : 1);
  digitalWrite(MA3, (a & 0x08) == 0 ? 0 : 1);
  digitalWrite(MA4, (a & 0x10) == 0 ? 0 : 1);
  digitalWrite(MA5, (a & 0x20) == 0 ? 0 : 1);
}


void writedta(int a, int d) {
  setaddr(a);
  digitalWrite(MDT, d == 0 ? 0 : 1);
  digitalWrite(MWR, 0);
  digitalWrite(MWR, 1);
}


void clearkbd() {
  int a;

  for (a = 0; a < 64; a++) {
    writedta(a, 0);
  }
}





void setup() {

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(MA0, OUTPUT);
  pinMode(MA1, OUTPUT);
  pinMode(MA2, OUTPUT);
  pinMode(MA3, OUTPUT);
  pinMode(MA4, OUTPUT);
  pinMode(MA5, OUTPUT);
  pinMode(MWR, OUTPUT);
  pinMode(MDT, OUTPUT);

  clearkbd();

  Serial.begin(9600);

  pinMode(PS2CLK, INPUT_PULLUP);
  pinMode(PS2DTA, INPUT_PULLUP);

  head = 0;
  tail = 0;
  attachInterrupt(digitalPinToInterrupt(PS2CLK), ps2interrupt, FALLING);

  digitalWrite(LED_BUILTIN, LOW);
}

void loop() {
  uint16_t scan,make;
  int i;
  
  scan = get_scan_code();
  make = (scan & BREAK) ? 0 : 1;
  scan = scan & (~BREAK);

  for (i = 0; i < 64; i++) {
    if (primokbd[i] == scan) {
      writedta(i, make);
    }
  }

//  if (scan != 0) {
//    Serial.print(make);
//    Serial.print(" ");
//    Serial.println(scan);
//  }
//  delay(100);
}
