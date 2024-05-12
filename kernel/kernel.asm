
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a2013103          	ld	sp,-1504(sp) # 80008a20 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	db478793          	addi	a5,a5,-588 # 80005e10 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e6278793          	addi	a5,a5,-414 # 80000f08 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b4e080e7          	jalr	-1202(ra) # 80000c5a <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	4b6080e7          	jalr	1206(ra) # 800025dc <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	7aa080e7          	jalr	1962(ra) # 800008e0 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	bc0080e7          	jalr	-1088(ra) # 80000d0e <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7119                	addi	sp,sp,-128
    80000170:	fc86                	sd	ra,120(sp)
    80000172:	f8a2                	sd	s0,112(sp)
    80000174:	f4a6                	sd	s1,104(sp)
    80000176:	f0ca                	sd	s2,96(sp)
    80000178:	ecce                	sd	s3,88(sp)
    8000017a:	e8d2                	sd	s4,80(sp)
    8000017c:	e4d6                	sd	s5,72(sp)
    8000017e:	e0da                	sd	s6,64(sp)
    80000180:	fc5e                	sd	s7,56(sp)
    80000182:	f862                	sd	s8,48(sp)
    80000184:	f466                	sd	s9,40(sp)
    80000186:	f06a                	sd	s10,32(sp)
    80000188:	ec6e                	sd	s11,24(sp)
    8000018a:	0100                	addi	s0,sp,128
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8aae                	mv	s5,a1
    80000190:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	abc080e7          	jalr	-1348(ra) # 80000c5a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	89a6                	mv	s3,s1
    800001b0:	00011917          	auipc	s2,0x11
    800001b4:	71890913          	addi	s2,s2,1816 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ba:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001bc:	4da9                	li	s11,10
  while(n > 0){
    800001be:	07405863          	blez	s4,8000022e <consoleread+0xc0>
    while(cons.r == cons.w){
    800001c2:	0984a783          	lw	a5,152(s1)
    800001c6:	09c4a703          	lw	a4,156(s1)
    800001ca:	02f71463          	bne	a4,a5,800001f2 <consoleread+0x84>
      if(myproc()->killed){
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	942080e7          	jalr	-1726(ra) # 80001b10 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	146080e7          	jalr	326(ra) # 80002324 <sleep>
    while(cons.r == cons.w){
    800001e6:	0984a783          	lw	a5,152(s1)
    800001ea:	09c4a703          	lw	a4,156(s1)
    800001ee:	fef700e3          	beq	a4,a5,800001ce <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f2:	0017871b          	addiw	a4,a5,1
    800001f6:	08e4ac23          	sw	a4,152(s1)
    800001fa:	07f7f713          	andi	a4,a5,127
    800001fe:	9726                	add	a4,a4,s1
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000208:	079c0663          	beq	s8,s9,80000274 <consoleread+0x106>
    cbuf = c;
    8000020c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	f8f40613          	addi	a2,s0,-113
    80000216:	85d6                	mv	a1,s5
    80000218:	855a                	mv	a0,s6
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	36c080e7          	jalr	876(ra) # 80002586 <either_copyout>
    80000222:	01a50663          	beq	a0,s10,8000022e <consoleread+0xc0>
    dst++;
    80000226:	0a85                	addi	s5,s5,1
    --n;
    80000228:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022a:	f9bc1ae3          	bne	s8,s11,800001be <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022e:	00011517          	auipc	a0,0x11
    80000232:	60250513          	addi	a0,a0,1538 # 80011830 <cons>
    80000236:	00001097          	auipc	ra,0x1
    8000023a:	ad8080e7          	jalr	-1320(ra) # 80000d0e <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	ac2080e7          	jalr	-1342(ra) # 80000d0e <release>
        return -1;
    80000254:	557d                	li	a0,-1
}
    80000256:	70e6                	ld	ra,120(sp)
    80000258:	7446                	ld	s0,112(sp)
    8000025a:	74a6                	ld	s1,104(sp)
    8000025c:	7906                	ld	s2,96(sp)
    8000025e:	69e6                	ld	s3,88(sp)
    80000260:	6a46                	ld	s4,80(sp)
    80000262:	6aa6                	ld	s5,72(sp)
    80000264:	6b06                	ld	s6,64(sp)
    80000266:	7be2                	ld	s7,56(sp)
    80000268:	7c42                	ld	s8,48(sp)
    8000026a:	7ca2                	ld	s9,40(sp)
    8000026c:	7d02                	ld	s10,32(sp)
    8000026e:	6de2                	ld	s11,24(sp)
    80000270:	6109                	addi	sp,sp,128
    80000272:	8082                	ret
      if(n < target){
    80000274:	000a071b          	sext.w	a4,s4
    80000278:	fb777be3          	bgeu	a4,s7,8000022e <consoleread+0xc0>
        cons.r--;
    8000027c:	00011717          	auipc	a4,0x11
    80000280:	64f72623          	sw	a5,1612(a4) # 800118c8 <cons+0x98>
    80000284:	b76d                	j	8000022e <consoleread+0xc0>

0000000080000286 <consputc>:
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e406                	sd	ra,8(sp)
    8000028a:	e022                	sd	s0,0(sp)
    8000028c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028e:	10000793          	li	a5,256
    80000292:	00f50a63          	beq	a0,a5,800002a6 <consputc+0x20>
    uartputc_sync(c);
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	564080e7          	jalr	1380(ra) # 800007fa <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	552080e7          	jalr	1362(ra) # 800007fa <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	546080e7          	jalr	1350(ra) # 800007fa <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	53c080e7          	jalr	1340(ra) # 800007fa <uartputc_sync>
    800002c6:	bfe1                	j	8000029e <consputc+0x18>

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	55a50513          	addi	a0,a0,1370 # 80011830 <cons>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	97c080e7          	jalr	-1668(ra) # 80000c5a <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	336080e7          	jalr	822(ra) # 80002632 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	a02080e7          	jalr	-1534(ra) # 80000d0e <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	50870713          	addi	a4,a4,1288 # 80011830 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	f3c080e7          	jalr	-196(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4de78793          	addi	a5,a5,1246 # 80011830 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5487a783          	lw	a5,1352(a5) # 800118c8 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	49c70713          	addi	a4,a4,1180 # 80011830 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	48c48493          	addi	s1,s1,1164 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	ebc080e7          	jalr	-324(ra) # 80000286 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	45070713          	addi	a4,a4,1104 # 80011830 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4cf72d23          	sw	a5,1242(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e84080e7          	jalr	-380(ra) # 80000286 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	e72080e7          	jalr	-398(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	41478793          	addi	a5,a5,1044 # 80011830 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	48c7a623          	sw	a2,1164(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	48050513          	addi	a0,a0,1152 # 800118c8 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	05a080e7          	jalr	90(ra) # 800024aa <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00008597          	auipc	a1,0x8
    80000466:	bae58593          	addi	a1,a1,-1106 # 80008010 <etext+0x10>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	3c650513          	addi	a0,a0,966 # 80011830 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	758080e7          	jalr	1880(ra) # 80000bca <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00021797          	auipc	a5,0x21
    80000486:	72e78793          	addi	a5,a5,1838 # 80021bb0 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	ce470713          	addi	a4,a4,-796 # 8000016e <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	c5870713          	addi	a4,a4,-936 # 800000ec <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	b7c60613          	addi	a2,a2,-1156 # 80008040 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d60080e7          	jalr	-672(ra) # 80000286 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3807ae23          	sw	zero,924(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	abc50513          	addi	a0,a0,-1348 # 80008018 <etext+0x18>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5250513          	addi	a0,a0,-1198 # 800080c8 <digits+0x88>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	32cdad83          	lw	s11,812(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	16050263          	beqz	a0,80000744 <printf+0x1b2>
    800005e4:	4481                	li	s1,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b13          	li	s6,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00008b97          	auipc	s7,0x8
    800005f4:	a50b8b93          	addi	s7,s7,-1456 # 80008040 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2d650513          	addi	a0,a0,726 # 800118d8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	650080e7          	jalr	1616(ra) # 80000c5a <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	a1450513          	addi	a0,a0,-1516 # 80008028 <etext+0x28>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	c62080e7          	jalr	-926(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2485                	addiw	s1,s1,1
    8000062e:	009a07b3          	add	a5,s4,s1
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050763          	beqz	a0,80000744 <printf+0x1b2>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2485                	addiw	s1,s1,1
    80000640:	009a07b3          	add	a5,s4,s1
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000064c:	cfe5                	beqz	a5,80000744 <printf+0x1b2>
    switch(c){
    8000064e:	05678a63          	beq	a5,s6,800006a2 <printf+0x110>
    80000652:	02fb7663          	bgeu	s6,a5,8000067e <printf+0xec>
    80000656:	09978963          	beq	a5,s9,800006e8 <printf+0x156>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79863          	bne	a5,a4,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	0b578263          	beq	a5,s5,80000722 <printf+0x190>
    80000682:	0b879663          	bne	a5,s8,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bd0080e7          	jalr	-1072(ra) # 80000286 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	bc4080e7          	jalr	-1084(ra) # 80000286 <consputc>
    800006ca:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c9d793          	srli	a5,s3,0x3c
    800006d0:	97de                	add	a5,a5,s7
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	bb0080e7          	jalr	-1104(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0992                	slli	s3,s3,0x4
    800006e0:	397d                	addiw	s2,s2,-1
    800006e2:	fe0915e3          	bnez	s2,800006cc <printf+0x13a>
    800006e6:	b799                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	0007b903          	ld	s2,0(a5)
    800006f8:	00090e63          	beqz	s2,80000714 <printf+0x182>
      for(; *s; s++)
    800006fc:	00094503          	lbu	a0,0(s2)
    80000700:	d515                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b84080e7          	jalr	-1148(ra) # 80000286 <consputc>
      for(; *s; s++)
    8000070a:	0905                	addi	s2,s2,1
    8000070c:	00094503          	lbu	a0,0(s2)
    80000710:	f96d                	bnez	a0,80000702 <printf+0x170>
    80000712:	bf29                	j	8000062c <printf+0x9a>
        s = "(null)";
    80000714:	00008917          	auipc	s2,0x8
    80000718:	90c90913          	addi	s2,s2,-1780 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000071c:	02800513          	li	a0,40
    80000720:	b7cd                	j	80000702 <printf+0x170>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b62080e7          	jalr	-1182(ra) # 80000286 <consputc>
      break;
    8000072c:	b701                	j	8000062c <printf+0x9a>
      consputc('%');
    8000072e:	8556                	mv	a0,s5
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b56080e7          	jalr	-1194(ra) # 80000286 <consputc>
      consputc(c);
    80000738:	854a                	mv	a0,s2
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b4c080e7          	jalr	-1204(ra) # 80000286 <consputc>
      break;
    80000742:	b5ed                	j	8000062c <printf+0x9a>
  if(locking)
    80000744:	020d9163          	bnez	s11,80000766 <printf+0x1d4>
}
    80000748:	70e6                	ld	ra,120(sp)
    8000074a:	7446                	ld	s0,112(sp)
    8000074c:	74a6                	ld	s1,104(sp)
    8000074e:	7906                	ld	s2,96(sp)
    80000750:	69e6                	ld	s3,88(sp)
    80000752:	6a46                	ld	s4,80(sp)
    80000754:	6aa6                	ld	s5,72(sp)
    80000756:	6b06                	ld	s6,64(sp)
    80000758:	7be2                	ld	s7,56(sp)
    8000075a:	7c42                	ld	s8,48(sp)
    8000075c:	7ca2                	ld	s9,40(sp)
    8000075e:	7d02                	ld	s10,32(sp)
    80000760:	6de2                	ld	s11,24(sp)
    80000762:	6129                	addi	sp,sp,192
    80000764:	8082                	ret
    release(&pr.lock);
    80000766:	00011517          	auipc	a0,0x11
    8000076a:	17250513          	addi	a0,a0,370 # 800118d8 <pr>
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	5a0080e7          	jalr	1440(ra) # 80000d0e <release>
}
    80000776:	bfc9                	j	80000748 <printf+0x1b6>

0000000080000778 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000778:	1101                	addi	sp,sp,-32
    8000077a:	ec06                	sd	ra,24(sp)
    8000077c:	e822                	sd	s0,16(sp)
    8000077e:	e426                	sd	s1,8(sp)
    80000780:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000782:	00011497          	auipc	s1,0x11
    80000786:	15648493          	addi	s1,s1,342 # 800118d8 <pr>
    8000078a:	00008597          	auipc	a1,0x8
    8000078e:	8ae58593          	addi	a1,a1,-1874 # 80008038 <etext+0x38>
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	436080e7          	jalr	1078(ra) # 80000bca <initlock>
  pr.locking = 1;
    8000079c:	4785                	li	a5,1
    8000079e:	cc9c                	sw	a5,24(s1)
}
    800007a0:	60e2                	ld	ra,24(sp)
    800007a2:	6442                	ld	s0,16(sp)
    800007a4:	64a2                	ld	s1,8(sp)
    800007a6:	6105                	addi	sp,sp,32
    800007a8:	8082                	ret

00000000800007aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b2:	100007b7          	lui	a5,0x10000
    800007b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ba:	f8000713          	li	a4,-128
    800007be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c2:	470d                	li	a4,3
    800007c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d0:	469d                	li	a3,7
    800007d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007da:	00008597          	auipc	a1,0x8
    800007de:	87e58593          	addi	a1,a1,-1922 # 80008058 <digits+0x18>
    800007e2:	00011517          	auipc	a0,0x11
    800007e6:	11650513          	addi	a0,a0,278 # 800118f8 <uart_tx_lock>
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	3e0080e7          	jalr	992(ra) # 80000bca <initlock>
}
    800007f2:	60a2                	ld	ra,8(sp)
    800007f4:	6402                	ld	s0,0(sp)
    800007f6:	0141                	addi	sp,sp,16
    800007f8:	8082                	ret

00000000800007fa <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
    80000804:	84aa                	mv	s1,a0
  push_off();
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	408080e7          	jalr	1032(ra) # 80000c0e <push_off>

  if(panicked){
    8000080e:	00008797          	auipc	a5,0x8
    80000812:	7f27a783          	lw	a5,2034(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081a:	c391                	beqz	a5,8000081e <uartputc_sync+0x24>
    for(;;)
    8000081c:	a001                	j	8000081c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000822:	0ff7f793          	andi	a5,a5,255
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dbf5                	beqz	a5,8000081e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f793          	andi	a5,s1,255
    80000830:	10000737          	lui	a4,0x10000
    80000834:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	476080e7          	jalr	1142(ra) # 80000cae <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	7ba7a783          	lw	a5,1978(a5) # 80009004 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	7b672703          	lw	a4,1974(a4) # 80009008 <uart_tx_w>
    8000085a:	08f70263          	beq	a4,a5,800008de <uartstart+0x94>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000874:	00011a17          	auipc	s4,0x11
    80000878:	084a0a13          	addi	s4,s4,132 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	78848493          	addi	s1,s1,1928 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	78498993          	addi	s3,s3,1924 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	0ff77713          	andi	a4,a4,255
    80000894:	02077713          	andi	a4,a4,32
    80000898:	cb15                	beqz	a4,800008cc <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    8000089a:	00fa0733          	add	a4,s4,a5
    8000089e:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008a2:	2785                	addiw	a5,a5,1
    800008a4:	41f7d71b          	sraiw	a4,a5,0x1f
    800008a8:	01b7571b          	srliw	a4,a4,0x1b
    800008ac:	9fb9                	addw	a5,a5,a4
    800008ae:	8bfd                	andi	a5,a5,31
    800008b0:	9f99                	subw	a5,a5,a4
    800008b2:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008b4:	8526                	mv	a0,s1
    800008b6:	00002097          	auipc	ra,0x2
    800008ba:	bf4080e7          	jalr	-1036(ra) # 800024aa <wakeup>
    
    WriteReg(THR, c);
    800008be:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008c2:	409c                	lw	a5,0(s1)
    800008c4:	0009a703          	lw	a4,0(s3)
    800008c8:	fcf712e3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008cc:	70e2                	ld	ra,56(sp)
    800008ce:	7442                	ld	s0,48(sp)
    800008d0:	74a2                	ld	s1,40(sp)
    800008d2:	7902                	ld	s2,32(sp)
    800008d4:	69e2                	ld	s3,24(sp)
    800008d6:	6a42                	ld	s4,16(sp)
    800008d8:	6aa2                	ld	s5,8(sp)
    800008da:	6121                	addi	sp,sp,64
    800008dc:	8082                	ret
    800008de:	8082                	ret

00000000800008e0 <uartputc>:
{
    800008e0:	7179                	addi	sp,sp,-48
    800008e2:	f406                	sd	ra,40(sp)
    800008e4:	f022                	sd	s0,32(sp)
    800008e6:	ec26                	sd	s1,24(sp)
    800008e8:	e84a                	sd	s2,16(sp)
    800008ea:	e44e                	sd	s3,8(sp)
    800008ec:	e052                	sd	s4,0(sp)
    800008ee:	1800                	addi	s0,sp,48
    800008f0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008f2:	00011517          	auipc	a0,0x11
    800008f6:	00650513          	addi	a0,a0,6 # 800118f8 <uart_tx_lock>
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	360080e7          	jalr	864(ra) # 80000c5a <acquire>
  if(panicked){
    80000902:	00008797          	auipc	a5,0x8
    80000906:	6fe7a783          	lw	a5,1790(a5) # 80009000 <panicked>
    8000090a:	c391                	beqz	a5,8000090e <uartputc+0x2e>
    for(;;)
    8000090c:	a001                	j	8000090c <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000090e:	00008717          	auipc	a4,0x8
    80000912:	6fa72703          	lw	a4,1786(a4) # 80009008 <uart_tx_w>
    80000916:	0017079b          	addiw	a5,a4,1
    8000091a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000091e:	01b6d69b          	srliw	a3,a3,0x1b
    80000922:	9fb5                	addw	a5,a5,a3
    80000924:	8bfd                	andi	a5,a5,31
    80000926:	9f95                	subw	a5,a5,a3
    80000928:	00008697          	auipc	a3,0x8
    8000092c:	6dc6a683          	lw	a3,1756(a3) # 80009004 <uart_tx_r>
    80000930:	04f69263          	bne	a3,a5,80000974 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000934:	00011a17          	auipc	s4,0x11
    80000938:	fc4a0a13          	addi	s4,s4,-60 # 800118f8 <uart_tx_lock>
    8000093c:	00008497          	auipc	s1,0x8
    80000940:	6c848493          	addi	s1,s1,1736 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	00008917          	auipc	s2,0x8
    80000948:	6c490913          	addi	s2,s2,1732 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000094c:	85d2                	mv	a1,s4
    8000094e:	8526                	mv	a0,s1
    80000950:	00002097          	auipc	ra,0x2
    80000954:	9d4080e7          	jalr	-1580(ra) # 80002324 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00092703          	lw	a4,0(s2)
    8000095c:	0017079b          	addiw	a5,a4,1
    80000960:	41f7d69b          	sraiw	a3,a5,0x1f
    80000964:	01b6d69b          	srliw	a3,a3,0x1b
    80000968:	9fb5                	addw	a5,a5,a3
    8000096a:	8bfd                	andi	a5,a5,31
    8000096c:	9f95                	subw	a5,a5,a3
    8000096e:	4094                	lw	a3,0(s1)
    80000970:	fcf68ee3          	beq	a3,a5,8000094c <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000974:	00011497          	auipc	s1,0x11
    80000978:	f8448493          	addi	s1,s1,-124 # 800118f8 <uart_tx_lock>
    8000097c:	9726                	add	a4,a4,s1
    8000097e:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000982:	00008717          	auipc	a4,0x8
    80000986:	68f72323          	sw	a5,1670(a4) # 80009008 <uart_tx_w>
      uartstart();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	ec0080e7          	jalr	-320(ra) # 8000084a <uartstart>
      release(&uart_tx_lock);
    80000992:	8526                	mv	a0,s1
    80000994:	00000097          	auipc	ra,0x0
    80000998:	37a080e7          	jalr	890(ra) # 80000d0e <release>
}
    8000099c:	70a2                	ld	ra,40(sp)
    8000099e:	7402                	ld	s0,32(sp)
    800009a0:	64e2                	ld	s1,24(sp)
    800009a2:	6942                	ld	s2,16(sp)
    800009a4:	69a2                	ld	s3,8(sp)
    800009a6:	6a02                	ld	s4,0(sp)
    800009a8:	6145                	addi	sp,sp,48
    800009aa:	8082                	ret

00000000800009ac <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ac:	1141                	addi	sp,sp,-16
    800009ae:	e422                	sd	s0,8(sp)
    800009b0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009b2:	100007b7          	lui	a5,0x10000
    800009b6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ba:	8b85                	andi	a5,a5,1
    800009bc:	cb91                	beqz	a5,800009d0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009be:	100007b7          	lui	a5,0x10000
    800009c2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009ca:	6422                	ld	s0,8(sp)
    800009cc:	0141                	addi	sp,sp,16
    800009ce:	8082                	ret
    return -1;
    800009d0:	557d                	li	a0,-1
    800009d2:	bfe5                	j	800009ca <uartgetc+0x1e>

00000000800009d4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009d4:	1101                	addi	sp,sp,-32
    800009d6:	ec06                	sd	ra,24(sp)
    800009d8:	e822                	sd	s0,16(sp)
    800009da:	e426                	sd	s1,8(sp)
    800009dc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009de:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e0:	00000097          	auipc	ra,0x0
    800009e4:	fcc080e7          	jalr	-52(ra) # 800009ac <uartgetc>
    if(c == -1)
    800009e8:	00950763          	beq	a0,s1,800009f6 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	8dc080e7          	jalr	-1828(ra) # 800002c8 <consoleintr>
  while(1){
    800009f4:	b7f5                	j	800009e0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f6:	00011497          	auipc	s1,0x11
    800009fa:	f0248493          	addi	s1,s1,-254 # 800118f8 <uart_tx_lock>
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	25a080e7          	jalr	602(ra) # 80000c5a <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	2fc080e7          	jalr	764(ra) # 80000d0e <release>
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <kfree>:
// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void* pa)
{
    80000a24:	1101                	addi	sp,sp,-32
    80000a26:	ec06                	sd	ra,24(sp)
    80000a28:	e822                	sd	s0,16(sp)
    80000a2a:	e426                	sd	s1,8(sp)
    80000a2c:	e04a                	sd	s2,0(sp)
    80000a2e:	1000                	addi	s0,sp,32
    struct run* r;

    if (((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a30:	03451793          	slli	a5,a0,0x34
    80000a34:	ebb9                	bnez	a5,80000a8a <kfree+0x66>
    80000a36:	84aa                	mv	s1,a0
    80000a38:	00025797          	auipc	a5,0x25
    80000a3c:	5c878793          	addi	a5,a5,1480 # 80026000 <end>
    80000a40:	04f56563          	bltu	a0,a5,80000a8a <kfree+0x66>
    80000a44:	47c5                	li	a5,17
    80000a46:	07ee                	slli	a5,a5,0x1b
    80000a48:	04f57163          	bgeu	a0,a5,80000a8a <kfree+0x66>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a4c:	6605                	lui	a2,0x1
    80000a4e:	4585                	li	a1,1
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	306080e7          	jalr	774(ra) # 80000d56 <memset>

    //embeded the run struct in free pmem
    r = (struct run*)pa;

    acquire(&kmem.lock);
    80000a58:	00011917          	auipc	s2,0x11
    80000a5c:	ed890913          	addi	s2,s2,-296 # 80011930 <kmem>
    80000a60:	854a                	mv	a0,s2
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	1f8080e7          	jalr	504(ra) # 80000c5a <acquire>
    r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
    release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	298080e7          	jalr	664(ra) # 80000d0e <release>
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6902                	ld	s2,0(sp)
    80000a86:	6105                	addi	sp,sp,32
    80000a88:	8082                	ret
        panic("kfree");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	5d650513          	addi	a0,a0,1494 # 80008060 <digits+0x20>
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	ab6080e7          	jalr	-1354(ra) # 80000548 <panic>

0000000080000a9a <freerange>:
{
    80000a9a:	7179                	addi	sp,sp,-48
    80000a9c:	f406                	sd	ra,40(sp)
    80000a9e:	f022                	sd	s0,32(sp)
    80000aa0:	ec26                	sd	s1,24(sp)
    80000aa2:	e84a                	sd	s2,16(sp)
    80000aa4:	e44e                	sd	s3,8(sp)
    80000aa6:	e052                	sd	s4,0(sp)
    80000aa8:	1800                	addi	s0,sp,48
    p = (char*)PGROUNDUP((uint64)pa_start);
    80000aaa:	6785                	lui	a5,0x1
    80000aac:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ab0:	94aa                	add	s1,s1,a0
    80000ab2:	757d                	lui	a0,0xfffff
    80000ab4:	8ce9                	and	s1,s1,a0
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab6:	94be                	add	s1,s1,a5
    80000ab8:	0095ee63          	bltu	a1,s1,80000ad4 <freerange+0x3a>
    80000abc:	892e                	mv	s2,a1
        kfree(p);
    80000abe:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	6985                	lui	s3,0x1
        kfree(p);
    80000ac2:	01448533          	add	a0,s1,s4
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f5e080e7          	jalr	-162(ra) # 80000a24 <kfree>
    for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ace:	94ce                	add	s1,s1,s3
    80000ad0:	fe9979e3          	bgeu	s2,s1,80000ac2 <freerange+0x28>
}
    80000ad4:	70a2                	ld	ra,40(sp)
    80000ad6:	7402                	ld	s0,32(sp)
    80000ad8:	64e2                	ld	s1,24(sp)
    80000ada:	6942                	ld	s2,16(sp)
    80000adc:	69a2                	ld	s3,8(sp)
    80000ade:	6a02                	ld	s4,0(sp)
    80000ae0:	6145                	addi	sp,sp,48
    80000ae2:	8082                	ret

0000000080000ae4 <kinit>:
{
    80000ae4:	1141                	addi	sp,sp,-16
    80000ae6:	e406                	sd	ra,8(sp)
    80000ae8:	e022                	sd	s0,0(sp)
    80000aea:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000aec:	00007597          	auipc	a1,0x7
    80000af0:	57c58593          	addi	a1,a1,1404 # 80008068 <digits+0x28>
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	e3c50513          	addi	a0,a0,-452 # 80011930 <kmem>
    80000afc:	00000097          	auipc	ra,0x0
    80000b00:	0ce080e7          	jalr	206(ra) # 80000bca <initlock>
    freerange(end, (void*)PHYSTOP);
    80000b04:	45c5                	li	a1,17
    80000b06:	05ee                	slli	a1,a1,0x1b
    80000b08:	00025517          	auipc	a0,0x25
    80000b0c:	4f850513          	addi	a0,a0,1272 # 80026000 <end>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	f8a080e7          	jalr	-118(ra) # 80000a9a <freerange>
}
    80000b18:	60a2                	ld	ra,8(sp)
    80000b1a:	6402                	ld	s0,0(sp)
    80000b1c:	0141                	addi	sp,sp,16
    80000b1e:	8082                	ret

0000000080000b20 <kalloc>:

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void* kalloc(void)
{
    80000b20:	1101                	addi	sp,sp,-32
    80000b22:	ec06                	sd	ra,24(sp)
    80000b24:	e822                	sd	s0,16(sp)
    80000b26:	e426                	sd	s1,8(sp)
    80000b28:	1000                	addi	s0,sp,32
    struct run* r;

    acquire(&kmem.lock);
    80000b2a:	00011497          	auipc	s1,0x11
    80000b2e:	e0648493          	addi	s1,s1,-506 # 80011930 <kmem>
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	126080e7          	jalr	294(ra) # 80000c5a <acquire>
    r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
    if (r)
    80000b3e:	c885                	beqz	s1,80000b6e <kalloc+0x4e>
        kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00011517          	auipc	a0,0x11
    80000b46:	dee50513          	addi	a0,a0,-530 # 80011930 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	1c2080e7          	jalr	450(ra) # 80000d0e <release>

    if (r)
        memset((char*)r, 5, PGSIZE); // fill with junk
    80000b54:	6605                	lui	a2,0x1
    80000b56:	4595                	li	a1,5
    80000b58:	8526                	mv	a0,s1
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	1fc080e7          	jalr	508(ra) # 80000d56 <memset>
    return (void*)r;
}
    80000b62:	8526                	mv	a0,s1
    80000b64:	60e2                	ld	ra,24(sp)
    80000b66:	6442                	ld	s0,16(sp)
    80000b68:	64a2                	ld	s1,8(sp)
    80000b6a:	6105                	addi	sp,sp,32
    80000b6c:	8082                	ret
    release(&kmem.lock);
    80000b6e:	00011517          	auipc	a0,0x11
    80000b72:	dc250513          	addi	a0,a0,-574 # 80011930 <kmem>
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	198080e7          	jalr	408(ra) # 80000d0e <release>
    if (r)
    80000b7e:	b7d5                	j	80000b62 <kalloc+0x42>

0000000080000b80 <count_free_kmem>:

uint64 count_free_kmem()
{
    80000b80:	1101                	addi	sp,sp,-32
    80000b82:	ec06                	sd	ra,24(sp)
    80000b84:	e822                	sd	s0,16(sp)
    80000b86:	e426                	sd	s1,8(sp)
    80000b88:	1000                	addi	s0,sp,32
    acquire(&kmem.lock);
    80000b8a:	00011497          	auipc	s1,0x11
    80000b8e:	da648493          	addi	s1,s1,-602 # 80011930 <kmem>
    80000b92:	8526                	mv	a0,s1
    80000b94:	00000097          	auipc	ra,0x0
    80000b98:	0c6080e7          	jalr	198(ra) # 80000c5a <acquire>
    struct run* r = kmem.freelist;
    80000b9c:	6c9c                	ld	a5,24(s1)
    uint64 freepage_num = 0;
    while (r)
    80000b9e:	c785                	beqz	a5,80000bc6 <count_free_kmem+0x46>
    uint64 freepage_num = 0;
    80000ba0:	4481                	li	s1,0
    {
        freepage_num++;
    80000ba2:	0485                	addi	s1,s1,1
        r = r->next;
    80000ba4:	639c                	ld	a5,0(a5)
    while (r)
    80000ba6:	fff5                	bnez	a5,80000ba2 <count_free_kmem+0x22>
    }
    release(&kmem.lock);
    80000ba8:	00011517          	auipc	a0,0x11
    80000bac:	d8850513          	addi	a0,a0,-632 # 80011930 <kmem>
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	15e080e7          	jalr	350(ra) # 80000d0e <release>
    return freepage_num * PGSIZE;
    80000bb8:	00c49513          	slli	a0,s1,0xc
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    uint64 freepage_num = 0;
    80000bc6:	4481                	li	s1,0
    80000bc8:	b7c5                	j	80000ba8 <count_free_kmem+0x28>

0000000080000bca <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bca:	1141                	addi	sp,sp,-16
    80000bcc:	e422                	sd	s0,8(sp)
    80000bce:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bd0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bd2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bd6:	00053823          	sd	zero,16(a0)
}
    80000bda:	6422                	ld	s0,8(sp)
    80000bdc:	0141                	addi	sp,sp,16
    80000bde:	8082                	ret

0000000080000be0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000be0:	411c                	lw	a5,0(a0)
    80000be2:	e399                	bnez	a5,80000be8 <holding+0x8>
    80000be4:	4501                	li	a0,0
  return r;
}
    80000be6:	8082                	ret
{
    80000be8:	1101                	addi	sp,sp,-32
    80000bea:	ec06                	sd	ra,24(sp)
    80000bec:	e822                	sd	s0,16(sp)
    80000bee:	e426                	sd	s1,8(sp)
    80000bf0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bf2:	6904                	ld	s1,16(a0)
    80000bf4:	00001097          	auipc	ra,0x1
    80000bf8:	f00080e7          	jalr	-256(ra) # 80001af4 <mycpu>
    80000bfc:	40a48533          	sub	a0,s1,a0
    80000c00:	00153513          	seqz	a0,a0
}
    80000c04:	60e2                	ld	ra,24(sp)
    80000c06:	6442                	ld	s0,16(sp)
    80000c08:	64a2                	ld	s1,8(sp)
    80000c0a:	6105                	addi	sp,sp,32
    80000c0c:	8082                	ret

0000000080000c0e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c0e:	1101                	addi	sp,sp,-32
    80000c10:	ec06                	sd	ra,24(sp)
    80000c12:	e822                	sd	s0,16(sp)
    80000c14:	e426                	sd	s1,8(sp)
    80000c16:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c18:	100024f3          	csrr	s1,sstatus
    80000c1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c20:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c22:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c26:	00001097          	auipc	ra,0x1
    80000c2a:	ece080e7          	jalr	-306(ra) # 80001af4 <mycpu>
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	cf89                	beqz	a5,80000c4a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	ec2080e7          	jalr	-318(ra) # 80001af4 <mycpu>
    80000c3a:	5d3c                	lw	a5,120(a0)
    80000c3c:	2785                	addiw	a5,a5,1
    80000c3e:	dd3c                	sw	a5,120(a0)
}
    80000c40:	60e2                	ld	ra,24(sp)
    80000c42:	6442                	ld	s0,16(sp)
    80000c44:	64a2                	ld	s1,8(sp)
    80000c46:	6105                	addi	sp,sp,32
    80000c48:	8082                	ret
    mycpu()->intena = old;
    80000c4a:	00001097          	auipc	ra,0x1
    80000c4e:	eaa080e7          	jalr	-342(ra) # 80001af4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8085                	srli	s1,s1,0x1
    80000c54:	8885                	andi	s1,s1,1
    80000c56:	dd64                	sw	s1,124(a0)
    80000c58:	bfe9                	j	80000c32 <push_off+0x24>

0000000080000c5a <acquire>:
{
    80000c5a:	1101                	addi	sp,sp,-32
    80000c5c:	ec06                	sd	ra,24(sp)
    80000c5e:	e822                	sd	s0,16(sp)
    80000c60:	e426                	sd	s1,8(sp)
    80000c62:	1000                	addi	s0,sp,32
    80000c64:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	fa8080e7          	jalr	-88(ra) # 80000c0e <push_off>
  if(holding(lk))
    80000c6e:	8526                	mv	a0,s1
    80000c70:	00000097          	auipc	ra,0x0
    80000c74:	f70080e7          	jalr	-144(ra) # 80000be0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c78:	4705                	li	a4,1
  if(holding(lk))
    80000c7a:	e115                	bnez	a0,80000c9e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7c:	87ba                	mv	a5,a4
    80000c7e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c82:	2781                	sext.w	a5,a5
    80000c84:	ffe5                	bnez	a5,80000c7c <acquire+0x22>
  __sync_synchronize();
    80000c86:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c8a:	00001097          	auipc	ra,0x1
    80000c8e:	e6a080e7          	jalr	-406(ra) # 80001af4 <mycpu>
    80000c92:	e888                	sd	a0,16(s1)
}
    80000c94:	60e2                	ld	ra,24(sp)
    80000c96:	6442                	ld	s0,16(sp)
    80000c98:	64a2                	ld	s1,8(sp)
    80000c9a:	6105                	addi	sp,sp,32
    80000c9c:	8082                	ret
    panic("acquire");
    80000c9e:	00007517          	auipc	a0,0x7
    80000ca2:	3d250513          	addi	a0,a0,978 # 80008070 <digits+0x30>
    80000ca6:	00000097          	auipc	ra,0x0
    80000caa:	8a2080e7          	jalr	-1886(ra) # 80000548 <panic>

0000000080000cae <pop_off>:

void
pop_off(void)
{
    80000cae:	1141                	addi	sp,sp,-16
    80000cb0:	e406                	sd	ra,8(sp)
    80000cb2:	e022                	sd	s0,0(sp)
    80000cb4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb6:	00001097          	auipc	ra,0x1
    80000cba:	e3e080e7          	jalr	-450(ra) # 80001af4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cbe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cc2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cc4:	e78d                	bnez	a5,80000cee <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc6:	5d3c                	lw	a5,120(a0)
    80000cc8:	02f05b63          	blez	a5,80000cfe <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000ccc:	37fd                	addiw	a5,a5,-1
    80000cce:	0007871b          	sext.w	a4,a5
    80000cd2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cd4:	eb09                	bnez	a4,80000ce6 <pop_off+0x38>
    80000cd6:	5d7c                	lw	a5,124(a0)
    80000cd8:	c799                	beqz	a5,80000ce6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cde:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ce2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ce6:	60a2                	ld	ra,8(sp)
    80000ce8:	6402                	ld	s0,0(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret
    panic("pop_off - interruptible");
    80000cee:	00007517          	auipc	a0,0x7
    80000cf2:	38a50513          	addi	a0,a0,906 # 80008078 <digits+0x38>
    80000cf6:	00000097          	auipc	ra,0x0
    80000cfa:	852080e7          	jalr	-1966(ra) # 80000548 <panic>
    panic("pop_off");
    80000cfe:	00007517          	auipc	a0,0x7
    80000d02:	39250513          	addi	a0,a0,914 # 80008090 <digits+0x50>
    80000d06:	00000097          	auipc	ra,0x0
    80000d0a:	842080e7          	jalr	-1982(ra) # 80000548 <panic>

0000000080000d0e <release>:
{
    80000d0e:	1101                	addi	sp,sp,-32
    80000d10:	ec06                	sd	ra,24(sp)
    80000d12:	e822                	sd	s0,16(sp)
    80000d14:	e426                	sd	s1,8(sp)
    80000d16:	1000                	addi	s0,sp,32
    80000d18:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d1a:	00000097          	auipc	ra,0x0
    80000d1e:	ec6080e7          	jalr	-314(ra) # 80000be0 <holding>
    80000d22:	c115                	beqz	a0,80000d46 <release+0x38>
  lk->cpu = 0;
    80000d24:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d28:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d2c:	0f50000f          	fence	iorw,ow
    80000d30:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d34:	00000097          	auipc	ra,0x0
    80000d38:	f7a080e7          	jalr	-134(ra) # 80000cae <pop_off>
}
    80000d3c:	60e2                	ld	ra,24(sp)
    80000d3e:	6442                	ld	s0,16(sp)
    80000d40:	64a2                	ld	s1,8(sp)
    80000d42:	6105                	addi	sp,sp,32
    80000d44:	8082                	ret
    panic("release");
    80000d46:	00007517          	auipc	a0,0x7
    80000d4a:	35250513          	addi	a0,a0,850 # 80008098 <digits+0x58>
    80000d4e:	fffff097          	auipc	ra,0xfffff
    80000d52:	7fa080e7          	jalr	2042(ra) # 80000548 <panic>

0000000080000d56 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d5c:	ce09                	beqz	a2,80000d76 <memset+0x20>
    80000d5e:	87aa                	mv	a5,a0
    80000d60:	fff6071b          	addiw	a4,a2,-1
    80000d64:	1702                	slli	a4,a4,0x20
    80000d66:	9301                	srli	a4,a4,0x20
    80000d68:	0705                	addi	a4,a4,1
    80000d6a:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d6c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d70:	0785                	addi	a5,a5,1
    80000d72:	fee79de3          	bne	a5,a4,80000d6c <memset+0x16>
  }
  return dst;
}
    80000d76:	6422                	ld	s0,8(sp)
    80000d78:	0141                	addi	sp,sp,16
    80000d7a:	8082                	ret

0000000080000d7c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d7c:	1141                	addi	sp,sp,-16
    80000d7e:	e422                	sd	s0,8(sp)
    80000d80:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d82:	ca05                	beqz	a2,80000db2 <memcmp+0x36>
    80000d84:	fff6069b          	addiw	a3,a2,-1
    80000d88:	1682                	slli	a3,a3,0x20
    80000d8a:	9281                	srli	a3,a3,0x20
    80000d8c:	0685                	addi	a3,a3,1
    80000d8e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d90:	00054783          	lbu	a5,0(a0)
    80000d94:	0005c703          	lbu	a4,0(a1)
    80000d98:	00e79863          	bne	a5,a4,80000da8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d9c:	0505                	addi	a0,a0,1
    80000d9e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000da0:	fed518e3          	bne	a0,a3,80000d90 <memcmp+0x14>
  }

  return 0;
    80000da4:	4501                	li	a0,0
    80000da6:	a019                	j	80000dac <memcmp+0x30>
      return *s1 - *s2;
    80000da8:	40e7853b          	subw	a0,a5,a4
}
    80000dac:	6422                	ld	s0,8(sp)
    80000dae:	0141                	addi	sp,sp,16
    80000db0:	8082                	ret
  return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	bfe5                	j	80000dac <memcmp+0x30>

0000000080000db6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000db6:	1141                	addi	sp,sp,-16
    80000db8:	e422                	sd	s0,8(sp)
    80000dba:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dbc:	00a5f963          	bgeu	a1,a0,80000dce <memmove+0x18>
    80000dc0:	02061713          	slli	a4,a2,0x20
    80000dc4:	9301                	srli	a4,a4,0x20
    80000dc6:	00e587b3          	add	a5,a1,a4
    80000dca:	02f56563          	bltu	a0,a5,80000df4 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dce:	fff6069b          	addiw	a3,a2,-1
    80000dd2:	ce11                	beqz	a2,80000dee <memmove+0x38>
    80000dd4:	1682                	slli	a3,a3,0x20
    80000dd6:	9281                	srli	a3,a3,0x20
    80000dd8:	0685                	addi	a3,a3,1
    80000dda:	96ae                	add	a3,a3,a1
    80000ddc:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000dde:	0585                	addi	a1,a1,1
    80000de0:	0785                	addi	a5,a5,1
    80000de2:	fff5c703          	lbu	a4,-1(a1)
    80000de6:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dea:	fed59ae3          	bne	a1,a3,80000dde <memmove+0x28>

  return dst;
}
    80000dee:	6422                	ld	s0,8(sp)
    80000df0:	0141                	addi	sp,sp,16
    80000df2:	8082                	ret
    d += n;
    80000df4:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000df6:	fff6069b          	addiw	a3,a2,-1
    80000dfa:	da75                	beqz	a2,80000dee <memmove+0x38>
    80000dfc:	02069613          	slli	a2,a3,0x20
    80000e00:	9201                	srli	a2,a2,0x20
    80000e02:	fff64613          	not	a2,a2
    80000e06:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e08:	17fd                	addi	a5,a5,-1
    80000e0a:	177d                	addi	a4,a4,-1
    80000e0c:	0007c683          	lbu	a3,0(a5)
    80000e10:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e14:	fec79ae3          	bne	a5,a2,80000e08 <memmove+0x52>
    80000e18:	bfd9                	j	80000dee <memmove+0x38>

0000000080000e1a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e1a:	1141                	addi	sp,sp,-16
    80000e1c:	e406                	sd	ra,8(sp)
    80000e1e:	e022                	sd	s0,0(sp)
    80000e20:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e22:	00000097          	auipc	ra,0x0
    80000e26:	f94080e7          	jalr	-108(ra) # 80000db6 <memmove>
}
    80000e2a:	60a2                	ld	ra,8(sp)
    80000e2c:	6402                	ld	s0,0(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e422                	sd	s0,8(sp)
    80000e36:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e38:	ce11                	beqz	a2,80000e54 <strncmp+0x22>
    80000e3a:	00054783          	lbu	a5,0(a0)
    80000e3e:	cf89                	beqz	a5,80000e58 <strncmp+0x26>
    80000e40:	0005c703          	lbu	a4,0(a1)
    80000e44:	00f71a63          	bne	a4,a5,80000e58 <strncmp+0x26>
    n--, p++, q++;
    80000e48:	367d                	addiw	a2,a2,-1
    80000e4a:	0505                	addi	a0,a0,1
    80000e4c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e4e:	f675                	bnez	a2,80000e3a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e50:	4501                	li	a0,0
    80000e52:	a809                	j	80000e64 <strncmp+0x32>
    80000e54:	4501                	li	a0,0
    80000e56:	a039                	j	80000e64 <strncmp+0x32>
  if(n == 0)
    80000e58:	ca09                	beqz	a2,80000e6a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e5a:	00054503          	lbu	a0,0(a0)
    80000e5e:	0005c783          	lbu	a5,0(a1)
    80000e62:	9d1d                	subw	a0,a0,a5
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret
    return 0;
    80000e6a:	4501                	li	a0,0
    80000e6c:	bfe5                	j	80000e64 <strncmp+0x32>

0000000080000e6e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e6e:	1141                	addi	sp,sp,-16
    80000e70:	e422                	sd	s0,8(sp)
    80000e72:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e74:	872a                	mv	a4,a0
    80000e76:	8832                	mv	a6,a2
    80000e78:	367d                	addiw	a2,a2,-1
    80000e7a:	01005963          	blez	a6,80000e8c <strncpy+0x1e>
    80000e7e:	0705                	addi	a4,a4,1
    80000e80:	0005c783          	lbu	a5,0(a1)
    80000e84:	fef70fa3          	sb	a5,-1(a4)
    80000e88:	0585                	addi	a1,a1,1
    80000e8a:	f7f5                	bnez	a5,80000e76 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e8c:	00c05d63          	blez	a2,80000ea6 <strncpy+0x38>
    80000e90:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e92:	0685                	addi	a3,a3,1
    80000e94:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e98:	fff6c793          	not	a5,a3
    80000e9c:	9fb9                	addw	a5,a5,a4
    80000e9e:	010787bb          	addw	a5,a5,a6
    80000ea2:	fef048e3          	bgtz	a5,80000e92 <strncpy+0x24>
  return os;
}
    80000ea6:	6422                	ld	s0,8(sp)
    80000ea8:	0141                	addi	sp,sp,16
    80000eaa:	8082                	ret

0000000080000eac <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eac:	1141                	addi	sp,sp,-16
    80000eae:	e422                	sd	s0,8(sp)
    80000eb0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eb2:	02c05363          	blez	a2,80000ed8 <safestrcpy+0x2c>
    80000eb6:	fff6069b          	addiw	a3,a2,-1
    80000eba:	1682                	slli	a3,a3,0x20
    80000ebc:	9281                	srli	a3,a3,0x20
    80000ebe:	96ae                	add	a3,a3,a1
    80000ec0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ec2:	00d58963          	beq	a1,a3,80000ed4 <safestrcpy+0x28>
    80000ec6:	0585                	addi	a1,a1,1
    80000ec8:	0785                	addi	a5,a5,1
    80000eca:	fff5c703          	lbu	a4,-1(a1)
    80000ece:	fee78fa3          	sb	a4,-1(a5)
    80000ed2:	fb65                	bnez	a4,80000ec2 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ed4:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ed8:	6422                	ld	s0,8(sp)
    80000eda:	0141                	addi	sp,sp,16
    80000edc:	8082                	ret

0000000080000ede <strlen>:

int
strlen(const char *s)
{
    80000ede:	1141                	addi	sp,sp,-16
    80000ee0:	e422                	sd	s0,8(sp)
    80000ee2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ee4:	00054783          	lbu	a5,0(a0)
    80000ee8:	cf91                	beqz	a5,80000f04 <strlen+0x26>
    80000eea:	0505                	addi	a0,a0,1
    80000eec:	87aa                	mv	a5,a0
    80000eee:	4685                	li	a3,1
    80000ef0:	9e89                	subw	a3,a3,a0
    80000ef2:	00f6853b          	addw	a0,a3,a5
    80000ef6:	0785                	addi	a5,a5,1
    80000ef8:	fff7c703          	lbu	a4,-1(a5)
    80000efc:	fb7d                	bnez	a4,80000ef2 <strlen+0x14>
    ;
  return n;
}
    80000efe:	6422                	ld	s0,8(sp)
    80000f00:	0141                	addi	sp,sp,16
    80000f02:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f04:	4501                	li	a0,0
    80000f06:	bfe5                	j	80000efe <strlen+0x20>

0000000080000f08 <main>:
 * @Param:
 * @Param:
 * @Return:
*/
void main()
{
    80000f08:	1141                	addi	sp,sp,-16
    80000f0a:	e406                	sd	ra,8(sp)
    80000f0c:	e022                	sd	s0,0(sp)
    80000f0e:	0800                	addi	s0,sp,16
    if (cpuid() == 0)
    80000f10:	00001097          	auipc	ra,0x1
    80000f14:	bd4080e7          	jalr	-1068(ra) # 80001ae4 <cpuid>
        __sync_synchronize();
        started = 1;
    }
    else
    {
        while (started == 0)
    80000f18:	00008717          	auipc	a4,0x8
    80000f1c:	0f470713          	addi	a4,a4,244 # 8000900c <started>
    if (cpuid() == 0)
    80000f20:	c139                	beqz	a0,80000f66 <main+0x5e>
        while (started == 0)
    80000f22:	431c                	lw	a5,0(a4)
    80000f24:	2781                	sext.w	a5,a5
    80000f26:	dff5                	beqz	a5,80000f22 <main+0x1a>
            ;
        __sync_synchronize();
    80000f28:	0ff0000f          	fence
        printf("hart %d starting\n", cpuid());
    80000f2c:	00001097          	auipc	ra,0x1
    80000f30:	bb8080e7          	jalr	-1096(ra) # 80001ae4 <cpuid>
    80000f34:	85aa                	mv	a1,a0
    80000f36:	00007517          	auipc	a0,0x7
    80000f3a:	18250513          	addi	a0,a0,386 # 800080b8 <digits+0x78>
    80000f3e:	fffff097          	auipc	ra,0xfffff
    80000f42:	654080e7          	jalr	1620(ra) # 80000592 <printf>
        kvminithart(); // turn on paging
    80000f46:	00000097          	auipc	ra,0x0
    80000f4a:	0d8080e7          	jalr	216(ra) # 8000101e <kvminithart>
        trapinithart(); // install kernel trap vector
    80000f4e:	00002097          	auipc	ra,0x2
    80000f52:	878080e7          	jalr	-1928(ra) # 800027c6 <trapinithart>
        plicinithart(); // ask PLIC for device interrupts
    80000f56:	00005097          	auipc	ra,0x5
    80000f5a:	efa080e7          	jalr	-262(ra) # 80005e50 <plicinithart>
    }

    scheduler();
    80000f5e:	00001097          	auipc	ra,0x1
    80000f62:	0ea080e7          	jalr	234(ra) # 80002048 <scheduler>
        consoleinit();
    80000f66:	fffff097          	auipc	ra,0xfffff
    80000f6a:	4f4080e7          	jalr	1268(ra) # 8000045a <consoleinit>
        printfinit();
    80000f6e:	00000097          	auipc	ra,0x0
    80000f72:	80a080e7          	jalr	-2038(ra) # 80000778 <printfinit>
        printf("\n");
    80000f76:	00007517          	auipc	a0,0x7
    80000f7a:	15250513          	addi	a0,a0,338 # 800080c8 <digits+0x88>
    80000f7e:	fffff097          	auipc	ra,0xfffff
    80000f82:	614080e7          	jalr	1556(ra) # 80000592 <printf>
        printf("xv6 kernel is booting\n");
    80000f86:	00007517          	auipc	a0,0x7
    80000f8a:	11a50513          	addi	a0,a0,282 # 800080a0 <digits+0x60>
    80000f8e:	fffff097          	auipc	ra,0xfffff
    80000f92:	604080e7          	jalr	1540(ra) # 80000592 <printf>
        printf("\n");
    80000f96:	00007517          	auipc	a0,0x7
    80000f9a:	13250513          	addi	a0,a0,306 # 800080c8 <digits+0x88>
    80000f9e:	fffff097          	auipc	ra,0xfffff
    80000fa2:	5f4080e7          	jalr	1524(ra) # 80000592 <printf>
        kinit(); // physical page allocator
    80000fa6:	00000097          	auipc	ra,0x0
    80000faa:	b3e080e7          	jalr	-1218(ra) # 80000ae4 <kinit>
        kvminit(); // create kernel page table
    80000fae:	00000097          	auipc	ra,0x0
    80000fb2:	2a0080e7          	jalr	672(ra) # 8000124e <kvminit>
        kvminithart(); // turn on paging
    80000fb6:	00000097          	auipc	ra,0x0
    80000fba:	068080e7          	jalr	104(ra) # 8000101e <kvminithart>
        procinit(); // process table
    80000fbe:	00001097          	auipc	ra,0x1
    80000fc2:	a56080e7          	jalr	-1450(ra) # 80001a14 <procinit>
        trapinit(); // trap vectors
    80000fc6:	00001097          	auipc	ra,0x1
    80000fca:	7d8080e7          	jalr	2008(ra) # 8000279e <trapinit>
        trapinithart(); // install kernel trap vector
    80000fce:	00001097          	auipc	ra,0x1
    80000fd2:	7f8080e7          	jalr	2040(ra) # 800027c6 <trapinithart>
        plicinit(); // set up interrupt controller
    80000fd6:	00005097          	auipc	ra,0x5
    80000fda:	e64080e7          	jalr	-412(ra) # 80005e3a <plicinit>
        plicinithart(); // ask PLIC for device interrupts
    80000fde:	00005097          	auipc	ra,0x5
    80000fe2:	e72080e7          	jalr	-398(ra) # 80005e50 <plicinithart>
        binit(); // buffer cache
    80000fe6:	00002097          	auipc	ra,0x2
    80000fea:	fee080e7          	jalr	-18(ra) # 80002fd4 <binit>
        iinit(); // inode cache
    80000fee:	00002097          	auipc	ra,0x2
    80000ff2:	67e080e7          	jalr	1662(ra) # 8000366c <iinit>
        fileinit(); // file table
    80000ff6:	00003097          	auipc	ra,0x3
    80000ffa:	618080e7          	jalr	1560(ra) # 8000460e <fileinit>
        virtio_disk_init(); // emulated hard disk
    80000ffe:	00005097          	auipc	ra,0x5
    80001002:	f5a080e7          	jalr	-166(ra) # 80005f58 <virtio_disk_init>
        userinit(); // first user process
    80001006:	00001097          	auipc	ra,0x1
    8000100a:	dd4080e7          	jalr	-556(ra) # 80001dda <userinit>
        __sync_synchronize();
    8000100e:	0ff0000f          	fence
        started = 1;
    80001012:	4785                	li	a5,1
    80001014:	00008717          	auipc	a4,0x8
    80001018:	fef72c23          	sw	a5,-8(a4) # 8000900c <started>
    8000101c:	b789                	j	80000f5e <main+0x56>

000000008000101e <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    8000101e:	1141                	addi	sp,sp,-16
    80001020:	e422                	sd	s0,8(sp)
    80001022:	0800                	addi	s0,sp,16
    w_satp(MAKE_SATP(kernel_pagetable));
    80001024:	00008797          	auipc	a5,0x8
    80001028:	fec7b783          	ld	a5,-20(a5) # 80009010 <kernel_pagetable>
    8000102c:	83b1                	srli	a5,a5,0xc
    8000102e:	577d                	li	a4,-1
    80001030:	177e                	slli	a4,a4,0x3f
    80001032:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001034:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001038:	12000073          	sfence.vma
    sfence_vma();
}
    8000103c:	6422                	ld	s0,8(sp)
    8000103e:	0141                	addi	sp,sp,16
    80001040:	8082                	ret

0000000080001042 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t*
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001042:	7139                	addi	sp,sp,-64
    80001044:	fc06                	sd	ra,56(sp)
    80001046:	f822                	sd	s0,48(sp)
    80001048:	f426                	sd	s1,40(sp)
    8000104a:	f04a                	sd	s2,32(sp)
    8000104c:	ec4e                	sd	s3,24(sp)
    8000104e:	e852                	sd	s4,16(sp)
    80001050:	e456                	sd	s5,8(sp)
    80001052:	e05a                	sd	s6,0(sp)
    80001054:	0080                	addi	s0,sp,64
    80001056:	84aa                	mv	s1,a0
    80001058:	89ae                	mv	s3,a1
    8000105a:	8ab2                	mv	s5,a2
    if (va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	4a79                	li	s4,30
        panic("walk");

    for (int level = 2; level > 0; level--)
    80001062:	4b31                	li	s6,12
    if (va >= MAXVA)
    80001064:	04b7f263          	bgeu	a5,a1,800010a8 <walk+0x66>
        panic("walk");
    80001068:	00007517          	auipc	a0,0x7
    8000106c:	06850513          	addi	a0,a0,104 # 800080d0 <digits+0x90>
    80001070:	fffff097          	auipc	ra,0xfffff
    80001074:	4d8080e7          	jalr	1240(ra) # 80000548 <panic>
        {
            pagetable = (pagetable_t)PTE2PA(*pte);
        }
        else
        {
            if (!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001078:	060a8663          	beqz	s5,800010e4 <walk+0xa2>
    8000107c:	00000097          	auipc	ra,0x0
    80001080:	aa4080e7          	jalr	-1372(ra) # 80000b20 <kalloc>
    80001084:	84aa                	mv	s1,a0
    80001086:	c529                	beqz	a0,800010d0 <walk+0x8e>
                return 0;
            memset(pagetable, 0, PGSIZE);
    80001088:	6605                	lui	a2,0x1
    8000108a:	4581                	li	a1,0
    8000108c:	00000097          	auipc	ra,0x0
    80001090:	cca080e7          	jalr	-822(ra) # 80000d56 <memset>
            *pte = PA2PTE(pagetable) | PTE_V;
    80001094:	00c4d793          	srli	a5,s1,0xc
    80001098:	07aa                	slli	a5,a5,0xa
    8000109a:	0017e793          	ori	a5,a5,1
    8000109e:	00f93023          	sd	a5,0(s2)
    for (int level = 2; level > 0; level--)
    800010a2:	3a5d                	addiw	s4,s4,-9
    800010a4:	036a0063          	beq	s4,s6,800010c4 <walk+0x82>
        pte_t* pte = &pagetable[PX(level, va)];
    800010a8:	0149d933          	srl	s2,s3,s4
    800010ac:	1ff97913          	andi	s2,s2,511
    800010b0:	090e                	slli	s2,s2,0x3
    800010b2:	9926                	add	s2,s2,s1
        if (*pte & PTE_V)
    800010b4:	00093483          	ld	s1,0(s2)
    800010b8:	0014f793          	andi	a5,s1,1
    800010bc:	dfd5                	beqz	a5,80001078 <walk+0x36>
            pagetable = (pagetable_t)PTE2PA(*pte);
    800010be:	80a9                	srli	s1,s1,0xa
    800010c0:	04b2                	slli	s1,s1,0xc
    800010c2:	b7c5                	j	800010a2 <walk+0x60>
        }
    }
    return &pagetable[PX(0, va)];
    800010c4:	00c9d513          	srli	a0,s3,0xc
    800010c8:	1ff57513          	andi	a0,a0,511
    800010cc:	050e                	slli	a0,a0,0x3
    800010ce:	9526                	add	a0,a0,s1
}
    800010d0:	70e2                	ld	ra,56(sp)
    800010d2:	7442                	ld	s0,48(sp)
    800010d4:	74a2                	ld	s1,40(sp)
    800010d6:	7902                	ld	s2,32(sp)
    800010d8:	69e2                	ld	s3,24(sp)
    800010da:	6a42                	ld	s4,16(sp)
    800010dc:	6aa2                	ld	s5,8(sp)
    800010de:	6b02                	ld	s6,0(sp)
    800010e0:	6121                	addi	sp,sp,64
    800010e2:	8082                	ret
                return 0;
    800010e4:	4501                	li	a0,0
    800010e6:	b7ed                	j	800010d0 <walk+0x8e>

00000000800010e8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
    pte_t* pte;
    uint64 pa;

    if (va >= MAXVA)
    800010e8:	57fd                	li	a5,-1
    800010ea:	83e9                	srli	a5,a5,0x1a
    800010ec:	00b7f463          	bgeu	a5,a1,800010f4 <walkaddr+0xc>
        return 0;
    800010f0:	4501                	li	a0,0
        return 0;
    if ((*pte & PTE_U) == 0)
        return 0;
    pa = PTE2PA(*pte);
    return pa;
}
    800010f2:	8082                	ret
{
    800010f4:	1141                	addi	sp,sp,-16
    800010f6:	e406                	sd	ra,8(sp)
    800010f8:	e022                	sd	s0,0(sp)
    800010fa:	0800                	addi	s0,sp,16
    pte = walk(pagetable, va, 0);
    800010fc:	4601                	li	a2,0
    800010fe:	00000097          	auipc	ra,0x0
    80001102:	f44080e7          	jalr	-188(ra) # 80001042 <walk>
    if (pte == 0)
    80001106:	c105                	beqz	a0,80001126 <walkaddr+0x3e>
    if ((*pte & PTE_V) == 0)
    80001108:	611c                	ld	a5,0(a0)
    if ((*pte & PTE_U) == 0)
    8000110a:	0117f693          	andi	a3,a5,17
    8000110e:	4745                	li	a4,17
        return 0;
    80001110:	4501                	li	a0,0
    if ((*pte & PTE_U) == 0)
    80001112:	00e68663          	beq	a3,a4,8000111e <walkaddr+0x36>
}
    80001116:	60a2                	ld	ra,8(sp)
    80001118:	6402                	ld	s0,0(sp)
    8000111a:	0141                	addi	sp,sp,16
    8000111c:	8082                	ret
    pa = PTE2PA(*pte);
    8000111e:	00a7d513          	srli	a0,a5,0xa
    80001122:	0532                	slli	a0,a0,0xc
    return pa;
    80001124:	bfcd                	j	80001116 <walkaddr+0x2e>
        return 0;
    80001126:	4501                	li	a0,0
    80001128:	b7fd                	j	80001116 <walkaddr+0x2e>

000000008000112a <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    8000112a:	1101                	addi	sp,sp,-32
    8000112c:	ec06                	sd	ra,24(sp)
    8000112e:	e822                	sd	s0,16(sp)
    80001130:	e426                	sd	s1,8(sp)
    80001132:	1000                	addi	s0,sp,32
    80001134:	85aa                	mv	a1,a0
    uint64 off = va % PGSIZE;
    80001136:	1552                	slli	a0,a0,0x34
    80001138:	03455493          	srli	s1,a0,0x34
    pte_t* pte;
    uint64 pa;

    pte = walk(kernel_pagetable, va, 0);
    8000113c:	4601                	li	a2,0
    8000113e:	00008517          	auipc	a0,0x8
    80001142:	ed253503          	ld	a0,-302(a0) # 80009010 <kernel_pagetable>
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	efc080e7          	jalr	-260(ra) # 80001042 <walk>
    if (pte == 0)
    8000114e:	cd09                	beqz	a0,80001168 <kvmpa+0x3e>
        panic("kvmpa");
    if ((*pte & PTE_V) == 0)
    80001150:	6108                	ld	a0,0(a0)
    80001152:	00157793          	andi	a5,a0,1
    80001156:	c38d                	beqz	a5,80001178 <kvmpa+0x4e>
        panic("kvmpa");
    pa = PTE2PA(*pte);
    80001158:	8129                	srli	a0,a0,0xa
    8000115a:	0532                	slli	a0,a0,0xc
    return pa + off;
}
    8000115c:	9526                	add	a0,a0,s1
    8000115e:	60e2                	ld	ra,24(sp)
    80001160:	6442                	ld	s0,16(sp)
    80001162:	64a2                	ld	s1,8(sp)
    80001164:	6105                	addi	sp,sp,32
    80001166:	8082                	ret
        panic("kvmpa");
    80001168:	00007517          	auipc	a0,0x7
    8000116c:	f7050513          	addi	a0,a0,-144 # 800080d8 <digits+0x98>
    80001170:	fffff097          	auipc	ra,0xfffff
    80001174:	3d8080e7          	jalr	984(ra) # 80000548 <panic>
        panic("kvmpa");
    80001178:	00007517          	auipc	a0,0x7
    8000117c:	f6050513          	addi	a0,a0,-160 # 800080d8 <digits+0x98>
    80001180:	fffff097          	auipc	ra,0xfffff
    80001184:	3c8080e7          	jalr	968(ra) # 80000548 <panic>

0000000080001188 <mappages>:
 * @Param:uint64 pa
 * @Param:uint64 perm
 * @Return:
*/
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001188:	715d                	addi	sp,sp,-80
    8000118a:	e486                	sd	ra,72(sp)
    8000118c:	e0a2                	sd	s0,64(sp)
    8000118e:	fc26                	sd	s1,56(sp)
    80001190:	f84a                	sd	s2,48(sp)
    80001192:	f44e                	sd	s3,40(sp)
    80001194:	f052                	sd	s4,32(sp)
    80001196:	ec56                	sd	s5,24(sp)
    80001198:	e85a                	sd	s6,16(sp)
    8000119a:	e45e                	sd	s7,8(sp)
    8000119c:	0880                	addi	s0,sp,80
    8000119e:	8aaa                	mv	s5,a0
    800011a0:	8b3a                	mv	s6,a4
    uint64 a, last;
    pte_t* pte;

    a = PGROUNDDOWN(va);
    800011a2:	777d                	lui	a4,0xfffff
    800011a4:	00e5f7b3          	and	a5,a1,a4
    last = PGROUNDDOWN(va + size - 1);
    800011a8:	167d                	addi	a2,a2,-1
    800011aa:	00b609b3          	add	s3,a2,a1
    800011ae:	00e9f9b3          	and	s3,s3,a4
    a = PGROUNDDOWN(va);
    800011b2:	893e                	mv	s2,a5
    800011b4:	40f68a33          	sub	s4,a3,a5
        if (*pte & PTE_V)
            panic("remap");
        *pte = PA2PTE(pa) | perm | PTE_V;
        if (a == last)
            break;
        a += PGSIZE;
    800011b8:	6b85                	lui	s7,0x1
    800011ba:	012a04b3          	add	s1,s4,s2
        if ((pte = walk(pagetable, a, 1)) == 0)
    800011be:	4605                	li	a2,1
    800011c0:	85ca                	mv	a1,s2
    800011c2:	8556                	mv	a0,s5
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	e7e080e7          	jalr	-386(ra) # 80001042 <walk>
    800011cc:	c51d                	beqz	a0,800011fa <mappages+0x72>
        if (*pte & PTE_V)
    800011ce:	611c                	ld	a5,0(a0)
    800011d0:	8b85                	andi	a5,a5,1
    800011d2:	ef81                	bnez	a5,800011ea <mappages+0x62>
        *pte = PA2PTE(pa) | perm | PTE_V;
    800011d4:	80b1                	srli	s1,s1,0xc
    800011d6:	04aa                	slli	s1,s1,0xa
    800011d8:	0164e4b3          	or	s1,s1,s6
    800011dc:	0014e493          	ori	s1,s1,1
    800011e0:	e104                	sd	s1,0(a0)
        if (a == last)
    800011e2:	03390863          	beq	s2,s3,80001212 <mappages+0x8a>
        a += PGSIZE;
    800011e6:	995e                	add	s2,s2,s7
        if ((pte = walk(pagetable, a, 1)) == 0)
    800011e8:	bfc9                	j	800011ba <mappages+0x32>
            panic("remap");
    800011ea:	00007517          	auipc	a0,0x7
    800011ee:	ef650513          	addi	a0,a0,-266 # 800080e0 <digits+0xa0>
    800011f2:	fffff097          	auipc	ra,0xfffff
    800011f6:	356080e7          	jalr	854(ra) # 80000548 <panic>
            return -1;
    800011fa:	557d                	li	a0,-1
        pa += PGSIZE;
    }
    return 0;
}
    800011fc:	60a6                	ld	ra,72(sp)
    800011fe:	6406                	ld	s0,64(sp)
    80001200:	74e2                	ld	s1,56(sp)
    80001202:	7942                	ld	s2,48(sp)
    80001204:	79a2                	ld	s3,40(sp)
    80001206:	7a02                	ld	s4,32(sp)
    80001208:	6ae2                	ld	s5,24(sp)
    8000120a:	6b42                	ld	s6,16(sp)
    8000120c:	6ba2                	ld	s7,8(sp)
    8000120e:	6161                	addi	sp,sp,80
    80001210:	8082                	ret
    return 0;
    80001212:	4501                	li	a0,0
    80001214:	b7e5                	j	800011fc <mappages+0x74>

0000000080001216 <kvmmap>:
{
    80001216:	1141                	addi	sp,sp,-16
    80001218:	e406                	sd	ra,8(sp)
    8000121a:	e022                	sd	s0,0(sp)
    8000121c:	0800                	addi	s0,sp,16
    8000121e:	8736                	mv	a4,a3
    if (mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001220:	86ae                	mv	a3,a1
    80001222:	85aa                	mv	a1,a0
    80001224:	00008517          	auipc	a0,0x8
    80001228:	dec53503          	ld	a0,-532(a0) # 80009010 <kernel_pagetable>
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	f5c080e7          	jalr	-164(ra) # 80001188 <mappages>
    80001234:	e509                	bnez	a0,8000123e <kvmmap+0x28>
}
    80001236:	60a2                	ld	ra,8(sp)
    80001238:	6402                	ld	s0,0(sp)
    8000123a:	0141                	addi	sp,sp,16
    8000123c:	8082                	ret
        panic("kvmmap");
    8000123e:	00007517          	auipc	a0,0x7
    80001242:	eaa50513          	addi	a0,a0,-342 # 800080e8 <digits+0xa8>
    80001246:	fffff097          	auipc	ra,0xfffff
    8000124a:	302080e7          	jalr	770(ra) # 80000548 <panic>

000000008000124e <kvminit>:
{
    8000124e:	1101                	addi	sp,sp,-32
    80001250:	ec06                	sd	ra,24(sp)
    80001252:	e822                	sd	s0,16(sp)
    80001254:	e426                	sd	s1,8(sp)
    80001256:	1000                	addi	s0,sp,32
    kernel_pagetable = (pagetable_t)kalloc();
    80001258:	00000097          	auipc	ra,0x0
    8000125c:	8c8080e7          	jalr	-1848(ra) # 80000b20 <kalloc>
    80001260:	00008797          	auipc	a5,0x8
    80001264:	daa7b823          	sd	a0,-592(a5) # 80009010 <kernel_pagetable>
    memset(kernel_pagetable, 0, PGSIZE);
    80001268:	6605                	lui	a2,0x1
    8000126a:	4581                	li	a1,0
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	aea080e7          	jalr	-1302(ra) # 80000d56 <memset>
    kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001274:	4699                	li	a3,6
    80001276:	6605                	lui	a2,0x1
    80001278:	100005b7          	lui	a1,0x10000
    8000127c:	10000537          	lui	a0,0x10000
    80001280:	00000097          	auipc	ra,0x0
    80001284:	f96080e7          	jalr	-106(ra) # 80001216 <kvmmap>
    kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001288:	4699                	li	a3,6
    8000128a:	6605                	lui	a2,0x1
    8000128c:	100015b7          	lui	a1,0x10001
    80001290:	10001537          	lui	a0,0x10001
    80001294:	00000097          	auipc	ra,0x0
    80001298:	f82080e7          	jalr	-126(ra) # 80001216 <kvmmap>
    kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000129c:	4699                	li	a3,6
    8000129e:	6641                	lui	a2,0x10
    800012a0:	020005b7          	lui	a1,0x2000
    800012a4:	02000537          	lui	a0,0x2000
    800012a8:	00000097          	auipc	ra,0x0
    800012ac:	f6e080e7          	jalr	-146(ra) # 80001216 <kvmmap>
    kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012b0:	4699                	li	a3,6
    800012b2:	00400637          	lui	a2,0x400
    800012b6:	0c0005b7          	lui	a1,0xc000
    800012ba:	0c000537          	lui	a0,0xc000
    800012be:	00000097          	auipc	ra,0x0
    800012c2:	f58080e7          	jalr	-168(ra) # 80001216 <kvmmap>
    kvmmap(KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800012c6:	00007497          	auipc	s1,0x7
    800012ca:	d3a48493          	addi	s1,s1,-710 # 80008000 <etext>
    800012ce:	46a9                	li	a3,10
    800012d0:	80007617          	auipc	a2,0x80007
    800012d4:	d3060613          	addi	a2,a2,-720 # 8000 <_entry-0x7fff8000>
    800012d8:	4585                	li	a1,1
    800012da:	05fe                	slli	a1,a1,0x1f
    800012dc:	852e                	mv	a0,a1
    800012de:	00000097          	auipc	ra,0x0
    800012e2:	f38080e7          	jalr	-200(ra) # 80001216 <kvmmap>
    kvmmap((uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800012e6:	4699                	li	a3,6
    800012e8:	4645                	li	a2,17
    800012ea:	066e                	slli	a2,a2,0x1b
    800012ec:	8e05                	sub	a2,a2,s1
    800012ee:	85a6                	mv	a1,s1
    800012f0:	8526                	mv	a0,s1
    800012f2:	00000097          	auipc	ra,0x0
    800012f6:	f24080e7          	jalr	-220(ra) # 80001216 <kvmmap>
    kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012fa:	46a9                	li	a3,10
    800012fc:	6605                	lui	a2,0x1
    800012fe:	00006597          	auipc	a1,0x6
    80001302:	d0258593          	addi	a1,a1,-766 # 80007000 <_trampoline>
    80001306:	04000537          	lui	a0,0x4000
    8000130a:	157d                	addi	a0,a0,-1
    8000130c:	0532                	slli	a0,a0,0xc
    8000130e:	00000097          	auipc	ra,0x0
    80001312:	f08080e7          	jalr	-248(ra) # 80001216 <kvmmap>
}
    80001316:	60e2                	ld	ra,24(sp)
    80001318:	6442                	ld	s0,16(sp)
    8000131a:	64a2                	ld	s1,8(sp)
    8000131c:	6105                	addi	sp,sp,32
    8000131e:	8082                	ret

0000000080001320 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001320:	715d                	addi	sp,sp,-80
    80001322:	e486                	sd	ra,72(sp)
    80001324:	e0a2                	sd	s0,64(sp)
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	f84a                	sd	s2,48(sp)
    8000132a:	f44e                	sd	s3,40(sp)
    8000132c:	f052                	sd	s4,32(sp)
    8000132e:	ec56                	sd	s5,24(sp)
    80001330:	e85a                	sd	s6,16(sp)
    80001332:	e45e                	sd	s7,8(sp)
    80001334:	0880                	addi	s0,sp,80
    uint64 a;
    pte_t* pte;

    if ((va % PGSIZE) != 0)
    80001336:	03459793          	slli	a5,a1,0x34
    8000133a:	e795                	bnez	a5,80001366 <uvmunmap+0x46>
    8000133c:	8a2a                	mv	s4,a0
    8000133e:	892e                	mv	s2,a1
    80001340:	8ab6                	mv	s5,a3
        panic("uvmunmap: not aligned");

    for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001342:	0632                	slli	a2,a2,0xc
    80001344:	00b609b3          	add	s3,a2,a1
    {
        if ((pte = walk(pagetable, a, 0)) == 0)
            panic("uvmunmap: walk");
        if ((*pte & PTE_V) == 0)
            panic("uvmunmap: not mapped");
        if (PTE_FLAGS(*pte) == PTE_V)
    80001348:	4b85                	li	s7,1
    for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    8000134a:	6b05                	lui	s6,0x1
    8000134c:	0735e863          	bltu	a1,s3,800013bc <uvmunmap+0x9c>
            uint64 pa = PTE2PA(*pte);
            kfree((void*)pa);
        }
        *pte = 0;
    }
}
    80001350:	60a6                	ld	ra,72(sp)
    80001352:	6406                	ld	s0,64(sp)
    80001354:	74e2                	ld	s1,56(sp)
    80001356:	7942                	ld	s2,48(sp)
    80001358:	79a2                	ld	s3,40(sp)
    8000135a:	7a02                	ld	s4,32(sp)
    8000135c:	6ae2                	ld	s5,24(sp)
    8000135e:	6b42                	ld	s6,16(sp)
    80001360:	6ba2                	ld	s7,8(sp)
    80001362:	6161                	addi	sp,sp,80
    80001364:	8082                	ret
        panic("uvmunmap: not aligned");
    80001366:	00007517          	auipc	a0,0x7
    8000136a:	d8a50513          	addi	a0,a0,-630 # 800080f0 <digits+0xb0>
    8000136e:	fffff097          	auipc	ra,0xfffff
    80001372:	1da080e7          	jalr	474(ra) # 80000548 <panic>
            panic("uvmunmap: walk");
    80001376:	00007517          	auipc	a0,0x7
    8000137a:	d9250513          	addi	a0,a0,-622 # 80008108 <digits+0xc8>
    8000137e:	fffff097          	auipc	ra,0xfffff
    80001382:	1ca080e7          	jalr	458(ra) # 80000548 <panic>
            panic("uvmunmap: not mapped");
    80001386:	00007517          	auipc	a0,0x7
    8000138a:	d9250513          	addi	a0,a0,-622 # 80008118 <digits+0xd8>
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	1ba080e7          	jalr	442(ra) # 80000548 <panic>
            panic("uvmunmap: not a leaf");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	d9a50513          	addi	a0,a0,-614 # 80008130 <digits+0xf0>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	1aa080e7          	jalr	426(ra) # 80000548 <panic>
            uint64 pa = PTE2PA(*pte);
    800013a6:	8129                	srli	a0,a0,0xa
            kfree((void*)pa);
    800013a8:	0532                	slli	a0,a0,0xc
    800013aa:	fffff097          	auipc	ra,0xfffff
    800013ae:	67a080e7          	jalr	1658(ra) # 80000a24 <kfree>
        *pte = 0;
    800013b2:	0004b023          	sd	zero,0(s1)
    for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    800013b6:	995a                	add	s2,s2,s6
    800013b8:	f9397ce3          	bgeu	s2,s3,80001350 <uvmunmap+0x30>
        if ((pte = walk(pagetable, a, 0)) == 0)
    800013bc:	4601                	li	a2,0
    800013be:	85ca                	mv	a1,s2
    800013c0:	8552                	mv	a0,s4
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	c80080e7          	jalr	-896(ra) # 80001042 <walk>
    800013ca:	84aa                	mv	s1,a0
    800013cc:	d54d                	beqz	a0,80001376 <uvmunmap+0x56>
        if ((*pte & PTE_V) == 0)
    800013ce:	6108                	ld	a0,0(a0)
    800013d0:	00157793          	andi	a5,a0,1
    800013d4:	dbcd                	beqz	a5,80001386 <uvmunmap+0x66>
        if (PTE_FLAGS(*pte) == PTE_V)
    800013d6:	3ff57793          	andi	a5,a0,1023
    800013da:	fb778ee3          	beq	a5,s7,80001396 <uvmunmap+0x76>
        if (do_free)
    800013de:	fc0a8ae3          	beqz	s5,800013b2 <uvmunmap+0x92>
    800013e2:	b7d1                	j	800013a6 <uvmunmap+0x86>

00000000800013e4 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013e4:	1101                	addi	sp,sp,-32
    800013e6:	ec06                	sd	ra,24(sp)
    800013e8:	e822                	sd	s0,16(sp)
    800013ea:	e426                	sd	s1,8(sp)
    800013ec:	1000                	addi	s0,sp,32
    pagetable_t pagetable;
    pagetable = (pagetable_t)kalloc();
    800013ee:	fffff097          	auipc	ra,0xfffff
    800013f2:	732080e7          	jalr	1842(ra) # 80000b20 <kalloc>
    800013f6:	84aa                	mv	s1,a0
    if (pagetable == 0)
    800013f8:	c519                	beqz	a0,80001406 <uvmcreate+0x22>
        return 0;
    memset(pagetable, 0, PGSIZE);
    800013fa:	6605                	lui	a2,0x1
    800013fc:	4581                	li	a1,0
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	958080e7          	jalr	-1704(ra) # 80000d56 <memset>
    return pagetable;
}
    80001406:	8526                	mv	a0,s1
    80001408:	60e2                	ld	ra,24(sp)
    8000140a:	6442                	ld	s0,16(sp)
    8000140c:	64a2                	ld	s1,8(sp)
    8000140e:	6105                	addi	sp,sp,32
    80001410:	8082                	ret

0000000080001412 <uvminit>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvminit(pagetable_t pagetable, uchar* src, uint sz)
{
    80001412:	7179                	addi	sp,sp,-48
    80001414:	f406                	sd	ra,40(sp)
    80001416:	f022                	sd	s0,32(sp)
    80001418:	ec26                	sd	s1,24(sp)
    8000141a:	e84a                	sd	s2,16(sp)
    8000141c:	e44e                	sd	s3,8(sp)
    8000141e:	e052                	sd	s4,0(sp)
    80001420:	1800                	addi	s0,sp,48
    char* mem;

    if (sz >= PGSIZE)
    80001422:	6785                	lui	a5,0x1
    80001424:	04f67863          	bgeu	a2,a5,80001474 <uvminit+0x62>
    80001428:	8a2a                	mv	s4,a0
    8000142a:	89ae                	mv	s3,a1
    8000142c:	84b2                	mv	s1,a2
        panic("inituvm: more than a page");
    mem = kalloc();
    8000142e:	fffff097          	auipc	ra,0xfffff
    80001432:	6f2080e7          	jalr	1778(ra) # 80000b20 <kalloc>
    80001436:	892a                	mv	s2,a0
    memset(mem, 0, PGSIZE);
    80001438:	6605                	lui	a2,0x1
    8000143a:	4581                	li	a1,0
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	91a080e7          	jalr	-1766(ra) # 80000d56 <memset>
    mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    80001444:	4779                	li	a4,30
    80001446:	86ca                	mv	a3,s2
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	8552                	mv	a0,s4
    8000144e:	00000097          	auipc	ra,0x0
    80001452:	d3a080e7          	jalr	-710(ra) # 80001188 <mappages>
    memmove(mem, src, sz);
    80001456:	8626                	mv	a2,s1
    80001458:	85ce                	mv	a1,s3
    8000145a:	854a                	mv	a0,s2
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	95a080e7          	jalr	-1702(ra) # 80000db6 <memmove>
}
    80001464:	70a2                	ld	ra,40(sp)
    80001466:	7402                	ld	s0,32(sp)
    80001468:	64e2                	ld	s1,24(sp)
    8000146a:	6942                	ld	s2,16(sp)
    8000146c:	69a2                	ld	s3,8(sp)
    8000146e:	6a02                	ld	s4,0(sp)
    80001470:	6145                	addi	sp,sp,48
    80001472:	8082                	ret
        panic("inituvm: more than a page");
    80001474:	00007517          	auipc	a0,0x7
    80001478:	cd450513          	addi	a0,a0,-812 # 80008148 <digits+0x108>
    8000147c:	fffff097          	auipc	ra,0xfffff
    80001480:	0cc080e7          	jalr	204(ra) # 80000548 <panic>

0000000080001484 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001484:	1101                	addi	sp,sp,-32
    80001486:	ec06                	sd	ra,24(sp)
    80001488:	e822                	sd	s0,16(sp)
    8000148a:	e426                	sd	s1,8(sp)
    8000148c:	1000                	addi	s0,sp,32
    if (newsz >= oldsz)
        return oldsz;
    8000148e:	84ae                	mv	s1,a1
    if (newsz >= oldsz)
    80001490:	00b67d63          	bgeu	a2,a1,800014aa <uvmdealloc+0x26>
    80001494:	84b2                	mv	s1,a2

    if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    80001496:	6785                	lui	a5,0x1
    80001498:	17fd                	addi	a5,a5,-1
    8000149a:	00f60733          	add	a4,a2,a5
    8000149e:	767d                	lui	a2,0xfffff
    800014a0:	8f71                	and	a4,a4,a2
    800014a2:	97ae                	add	a5,a5,a1
    800014a4:	8ff1                	and	a5,a5,a2
    800014a6:	00f76863          	bltu	a4,a5,800014b6 <uvmdealloc+0x32>
        int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
        uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    }

    return newsz;
}
    800014aa:	8526                	mv	a0,s1
    800014ac:	60e2                	ld	ra,24(sp)
    800014ae:	6442                	ld	s0,16(sp)
    800014b0:	64a2                	ld	s1,8(sp)
    800014b2:	6105                	addi	sp,sp,32
    800014b4:	8082                	ret
        int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014b6:	8f99                	sub	a5,a5,a4
    800014b8:	83b1                	srli	a5,a5,0xc
        uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014ba:	4685                	li	a3,1
    800014bc:	0007861b          	sext.w	a2,a5
    800014c0:	85ba                	mv	a1,a4
    800014c2:	00000097          	auipc	ra,0x0
    800014c6:	e5e080e7          	jalr	-418(ra) # 80001320 <uvmunmap>
    800014ca:	b7c5                	j	800014aa <uvmdealloc+0x26>

00000000800014cc <uvmalloc>:
    if (newsz < oldsz)
    800014cc:	0ab66163          	bltu	a2,a1,8000156e <uvmalloc+0xa2>
{
    800014d0:	7139                	addi	sp,sp,-64
    800014d2:	fc06                	sd	ra,56(sp)
    800014d4:	f822                	sd	s0,48(sp)
    800014d6:	f426                	sd	s1,40(sp)
    800014d8:	f04a                	sd	s2,32(sp)
    800014da:	ec4e                	sd	s3,24(sp)
    800014dc:	e852                	sd	s4,16(sp)
    800014de:	e456                	sd	s5,8(sp)
    800014e0:	0080                	addi	s0,sp,64
    800014e2:	8aaa                	mv	s5,a0
    800014e4:	8a32                	mv	s4,a2
    oldsz = PGROUNDUP(oldsz);
    800014e6:	6985                	lui	s3,0x1
    800014e8:	19fd                	addi	s3,s3,-1
    800014ea:	95ce                	add	a1,a1,s3
    800014ec:	79fd                	lui	s3,0xfffff
    800014ee:	0135f9b3          	and	s3,a1,s3
    for (a = oldsz; a < newsz; a += PGSIZE)
    800014f2:	08c9f063          	bgeu	s3,a2,80001572 <uvmalloc+0xa6>
    800014f6:	894e                	mv	s2,s3
        mem = kalloc();
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	628080e7          	jalr	1576(ra) # 80000b20 <kalloc>
    80001500:	84aa                	mv	s1,a0
        if (mem == 0)
    80001502:	c51d                	beqz	a0,80001530 <uvmalloc+0x64>
        memset(mem, 0, PGSIZE);
    80001504:	6605                	lui	a2,0x1
    80001506:	4581                	li	a1,0
    80001508:	00000097          	auipc	ra,0x0
    8000150c:	84e080e7          	jalr	-1970(ra) # 80000d56 <memset>
        if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W | PTE_X | PTE_R | PTE_U) != 0)
    80001510:	4779                	li	a4,30
    80001512:	86a6                	mv	a3,s1
    80001514:	6605                	lui	a2,0x1
    80001516:	85ca                	mv	a1,s2
    80001518:	8556                	mv	a0,s5
    8000151a:	00000097          	auipc	ra,0x0
    8000151e:	c6e080e7          	jalr	-914(ra) # 80001188 <mappages>
    80001522:	e905                	bnez	a0,80001552 <uvmalloc+0x86>
    for (a = oldsz; a < newsz; a += PGSIZE)
    80001524:	6785                	lui	a5,0x1
    80001526:	993e                	add	s2,s2,a5
    80001528:	fd4968e3          	bltu	s2,s4,800014f8 <uvmalloc+0x2c>
    return newsz;
    8000152c:	8552                	mv	a0,s4
    8000152e:	a809                	j	80001540 <uvmalloc+0x74>
            uvmdealloc(pagetable, a, oldsz);
    80001530:	864e                	mv	a2,s3
    80001532:	85ca                	mv	a1,s2
    80001534:	8556                	mv	a0,s5
    80001536:	00000097          	auipc	ra,0x0
    8000153a:	f4e080e7          	jalr	-178(ra) # 80001484 <uvmdealloc>
            return 0;
    8000153e:	4501                	li	a0,0
}
    80001540:	70e2                	ld	ra,56(sp)
    80001542:	7442                	ld	s0,48(sp)
    80001544:	74a2                	ld	s1,40(sp)
    80001546:	7902                	ld	s2,32(sp)
    80001548:	69e2                	ld	s3,24(sp)
    8000154a:	6a42                	ld	s4,16(sp)
    8000154c:	6aa2                	ld	s5,8(sp)
    8000154e:	6121                	addi	sp,sp,64
    80001550:	8082                	ret
            kfree(mem);
    80001552:	8526                	mv	a0,s1
    80001554:	fffff097          	auipc	ra,0xfffff
    80001558:	4d0080e7          	jalr	1232(ra) # 80000a24 <kfree>
            uvmdealloc(pagetable, a, oldsz);
    8000155c:	864e                	mv	a2,s3
    8000155e:	85ca                	mv	a1,s2
    80001560:	8556                	mv	a0,s5
    80001562:	00000097          	auipc	ra,0x0
    80001566:	f22080e7          	jalr	-222(ra) # 80001484 <uvmdealloc>
            return 0;
    8000156a:	4501                	li	a0,0
    8000156c:	bfd1                	j	80001540 <uvmalloc+0x74>
        return oldsz;
    8000156e:	852e                	mv	a0,a1
}
    80001570:	8082                	ret
    return newsz;
    80001572:	8532                	mv	a0,a2
    80001574:	b7f1                	j	80001540 <uvmalloc+0x74>

0000000080001576 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    80001576:	7179                	addi	sp,sp,-48
    80001578:	f406                	sd	ra,40(sp)
    8000157a:	f022                	sd	s0,32(sp)
    8000157c:	ec26                	sd	s1,24(sp)
    8000157e:	e84a                	sd	s2,16(sp)
    80001580:	e44e                	sd	s3,8(sp)
    80001582:	e052                	sd	s4,0(sp)
    80001584:	1800                	addi	s0,sp,48
    80001586:	8a2a                	mv	s4,a0
    // there are 2^9 = 512 PTEs in a page table.
    for (int i = 0; i < 512; i++)
    80001588:	84aa                	mv	s1,a0
    8000158a:	6905                	lui	s2,0x1
    8000158c:	992a                	add	s2,s2,a0
    {
        pte_t pte = pagetable[i];
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    8000158e:	4985                	li	s3,1
    80001590:	a821                	j	800015a8 <freewalk+0x32>
        {
            // this PTE points to a lower-level page table.
            uint64 child = PTE2PA(pte);
    80001592:	8129                	srli	a0,a0,0xa
            freewalk((pagetable_t)child);
    80001594:	0532                	slli	a0,a0,0xc
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	fe0080e7          	jalr	-32(ra) # 80001576 <freewalk>
            pagetable[i] = 0;
    8000159e:	0004b023          	sd	zero,0(s1)
    for (int i = 0; i < 512; i++)
    800015a2:	04a1                	addi	s1,s1,8
    800015a4:	03248163          	beq	s1,s2,800015c6 <freewalk+0x50>
        pte_t pte = pagetable[i];
    800015a8:	6088                	ld	a0,0(s1)
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800015aa:	00f57793          	andi	a5,a0,15
    800015ae:	ff3782e3          	beq	a5,s3,80001592 <freewalk+0x1c>
        }
        else if (pte & PTE_V)
    800015b2:	8905                	andi	a0,a0,1
    800015b4:	d57d                	beqz	a0,800015a2 <freewalk+0x2c>
        {
            panic("freewalk: leaf");
    800015b6:	00007517          	auipc	a0,0x7
    800015ba:	bb250513          	addi	a0,a0,-1102 # 80008168 <digits+0x128>
    800015be:	fffff097          	auipc	ra,0xfffff
    800015c2:	f8a080e7          	jalr	-118(ra) # 80000548 <panic>
        }
    }
    kfree((void*)pagetable);
    800015c6:	8552                	mv	a0,s4
    800015c8:	fffff097          	auipc	ra,0xfffff
    800015cc:	45c080e7          	jalr	1116(ra) # 80000a24 <kfree>
}
    800015d0:	70a2                	ld	ra,40(sp)
    800015d2:	7402                	ld	s0,32(sp)
    800015d4:	64e2                	ld	s1,24(sp)
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	69a2                	ld	s3,8(sp)
    800015da:	6a02                	ld	s4,0(sp)
    800015dc:	6145                	addi	sp,sp,48
    800015de:	8082                	ret

00000000800015e0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015e0:	1101                	addi	sp,sp,-32
    800015e2:	ec06                	sd	ra,24(sp)
    800015e4:	e822                	sd	s0,16(sp)
    800015e6:	e426                	sd	s1,8(sp)
    800015e8:	1000                	addi	s0,sp,32
    800015ea:	84aa                	mv	s1,a0
    if (sz > 0)
    800015ec:	e999                	bnez	a1,80001602 <uvmfree+0x22>
        uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    freewalk(pagetable);
    800015ee:	8526                	mv	a0,s1
    800015f0:	00000097          	auipc	ra,0x0
    800015f4:	f86080e7          	jalr	-122(ra) # 80001576 <freewalk>
}
    800015f8:	60e2                	ld	ra,24(sp)
    800015fa:	6442                	ld	s0,16(sp)
    800015fc:	64a2                	ld	s1,8(sp)
    800015fe:	6105                	addi	sp,sp,32
    80001600:	8082                	ret
        uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001602:	6605                	lui	a2,0x1
    80001604:	167d                	addi	a2,a2,-1
    80001606:	962e                	add	a2,a2,a1
    80001608:	4685                	li	a3,1
    8000160a:	8231                	srli	a2,a2,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	d12080e7          	jalr	-750(ra) # 80001320 <uvmunmap>
    80001616:	bfe1                	j	800015ee <uvmfree+0xe>

0000000080001618 <uvmcopy>:
    pte_t* pte;
    uint64 pa, i;
    uint flags;
    char* mem;

    for (i = 0; i < sz; i += PGSIZE)
    80001618:	c679                	beqz	a2,800016e6 <uvmcopy+0xce>
{
    8000161a:	715d                	addi	sp,sp,-80
    8000161c:	e486                	sd	ra,72(sp)
    8000161e:	e0a2                	sd	s0,64(sp)
    80001620:	fc26                	sd	s1,56(sp)
    80001622:	f84a                	sd	s2,48(sp)
    80001624:	f44e                	sd	s3,40(sp)
    80001626:	f052                	sd	s4,32(sp)
    80001628:	ec56                	sd	s5,24(sp)
    8000162a:	e85a                	sd	s6,16(sp)
    8000162c:	e45e                	sd	s7,8(sp)
    8000162e:	0880                	addi	s0,sp,80
    80001630:	8b2a                	mv	s6,a0
    80001632:	8aae                	mv	s5,a1
    80001634:	8a32                	mv	s4,a2
    for (i = 0; i < sz; i += PGSIZE)
    80001636:	4981                	li	s3,0
    {
        if ((pte = walk(old, i, 0)) == 0)
    80001638:	4601                	li	a2,0
    8000163a:	85ce                	mv	a1,s3
    8000163c:	855a                	mv	a0,s6
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	a04080e7          	jalr	-1532(ra) # 80001042 <walk>
    80001646:	c531                	beqz	a0,80001692 <uvmcopy+0x7a>
            panic("uvmcopy: pte should exist");
        if ((*pte & PTE_V) == 0)
    80001648:	6118                	ld	a4,0(a0)
    8000164a:	00177793          	andi	a5,a4,1
    8000164e:	cbb1                	beqz	a5,800016a2 <uvmcopy+0x8a>
            panic("uvmcopy: page not present");
        pa = PTE2PA(*pte);
    80001650:	00a75593          	srli	a1,a4,0xa
    80001654:	00c59b93          	slli	s7,a1,0xc
        flags = PTE_FLAGS(*pte);
    80001658:	3ff77493          	andi	s1,a4,1023
        if ((mem = kalloc()) == 0)
    8000165c:	fffff097          	auipc	ra,0xfffff
    80001660:	4c4080e7          	jalr	1220(ra) # 80000b20 <kalloc>
    80001664:	892a                	mv	s2,a0
    80001666:	c939                	beqz	a0,800016bc <uvmcopy+0xa4>
            goto err;
        memmove(mem, (char*)pa, PGSIZE);
    80001668:	6605                	lui	a2,0x1
    8000166a:	85de                	mv	a1,s7
    8000166c:	fffff097          	auipc	ra,0xfffff
    80001670:	74a080e7          	jalr	1866(ra) # 80000db6 <memmove>
        if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001674:	8726                	mv	a4,s1
    80001676:	86ca                	mv	a3,s2
    80001678:	6605                	lui	a2,0x1
    8000167a:	85ce                	mv	a1,s3
    8000167c:	8556                	mv	a0,s5
    8000167e:	00000097          	auipc	ra,0x0
    80001682:	b0a080e7          	jalr	-1270(ra) # 80001188 <mappages>
    80001686:	e515                	bnez	a0,800016b2 <uvmcopy+0x9a>
    for (i = 0; i < sz; i += PGSIZE)
    80001688:	6785                	lui	a5,0x1
    8000168a:	99be                	add	s3,s3,a5
    8000168c:	fb49e6e3          	bltu	s3,s4,80001638 <uvmcopy+0x20>
    80001690:	a081                	j	800016d0 <uvmcopy+0xb8>
            panic("uvmcopy: pte should exist");
    80001692:	00007517          	auipc	a0,0x7
    80001696:	ae650513          	addi	a0,a0,-1306 # 80008178 <digits+0x138>
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	eae080e7          	jalr	-338(ra) # 80000548 <panic>
            panic("uvmcopy: page not present");
    800016a2:	00007517          	auipc	a0,0x7
    800016a6:	af650513          	addi	a0,a0,-1290 # 80008198 <digits+0x158>
    800016aa:	fffff097          	auipc	ra,0xfffff
    800016ae:	e9e080e7          	jalr	-354(ra) # 80000548 <panic>
        {
            kfree(mem);
    800016b2:	854a                	mv	a0,s2
    800016b4:	fffff097          	auipc	ra,0xfffff
    800016b8:	370080e7          	jalr	880(ra) # 80000a24 <kfree>
        }
    }
    return 0;

err:
    uvmunmap(new, 0, i / PGSIZE, 1);
    800016bc:	4685                	li	a3,1
    800016be:	00c9d613          	srli	a2,s3,0xc
    800016c2:	4581                	li	a1,0
    800016c4:	8556                	mv	a0,s5
    800016c6:	00000097          	auipc	ra,0x0
    800016ca:	c5a080e7          	jalr	-934(ra) # 80001320 <uvmunmap>
    return -1;
    800016ce:	557d                	li	a0,-1
}
    800016d0:	60a6                	ld	ra,72(sp)
    800016d2:	6406                	ld	s0,64(sp)
    800016d4:	74e2                	ld	s1,56(sp)
    800016d6:	7942                	ld	s2,48(sp)
    800016d8:	79a2                	ld	s3,40(sp)
    800016da:	7a02                	ld	s4,32(sp)
    800016dc:	6ae2                	ld	s5,24(sp)
    800016de:	6b42                	ld	s6,16(sp)
    800016e0:	6ba2                	ld	s7,8(sp)
    800016e2:	6161                	addi	sp,sp,80
    800016e4:	8082                	ret
    return 0;
    800016e6:	4501                	li	a0,0
}
    800016e8:	8082                	ret

00000000800016ea <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    800016ea:	1141                	addi	sp,sp,-16
    800016ec:	e406                	sd	ra,8(sp)
    800016ee:	e022                	sd	s0,0(sp)
    800016f0:	0800                	addi	s0,sp,16
    pte_t* pte;

    pte = walk(pagetable, va, 0);
    800016f2:	4601                	li	a2,0
    800016f4:	00000097          	auipc	ra,0x0
    800016f8:	94e080e7          	jalr	-1714(ra) # 80001042 <walk>
    if (pte == 0)
    800016fc:	c901                	beqz	a0,8000170c <uvmclear+0x22>
        panic("uvmclear");
    *pte &= ~PTE_U;
    800016fe:	611c                	ld	a5,0(a0)
    80001700:	9bbd                	andi	a5,a5,-17
    80001702:	e11c                	sd	a5,0(a0)
}
    80001704:	60a2                	ld	ra,8(sp)
    80001706:	6402                	ld	s0,0(sp)
    80001708:	0141                	addi	sp,sp,16
    8000170a:	8082                	ret
        panic("uvmclear");
    8000170c:	00007517          	auipc	a0,0x7
    80001710:	aac50513          	addi	a0,a0,-1364 # 800081b8 <digits+0x178>
    80001714:	fffff097          	auipc	ra,0xfffff
    80001718:	e34080e7          	jalr	-460(ra) # 80000548 <panic>

000000008000171c <copyout>:
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char* src, uint64 len)
{
    uint64 n, va0, pa0;

    while (len > 0)
    8000171c:	c6bd                	beqz	a3,8000178a <copyout+0x6e>
{
    8000171e:	715d                	addi	sp,sp,-80
    80001720:	e486                	sd	ra,72(sp)
    80001722:	e0a2                	sd	s0,64(sp)
    80001724:	fc26                	sd	s1,56(sp)
    80001726:	f84a                	sd	s2,48(sp)
    80001728:	f44e                	sd	s3,40(sp)
    8000172a:	f052                	sd	s4,32(sp)
    8000172c:	ec56                	sd	s5,24(sp)
    8000172e:	e85a                	sd	s6,16(sp)
    80001730:	e45e                	sd	s7,8(sp)
    80001732:	e062                	sd	s8,0(sp)
    80001734:	0880                	addi	s0,sp,80
    80001736:	8b2a                	mv	s6,a0
    80001738:	8c2e                	mv	s8,a1
    8000173a:	8a32                	mv	s4,a2
    8000173c:	89b6                	mv	s3,a3
    {
        va0 = PGROUNDDOWN(dstva);
    8000173e:	7bfd                	lui	s7,0xfffff
        pa0 = walkaddr(pagetable, va0);
        if (pa0 == 0)
            return -1;
        n = PGSIZE - (dstva - va0);
    80001740:	6a85                	lui	s5,0x1
    80001742:	a015                	j	80001766 <copyout+0x4a>
        if (n > len)
            n = len;
        memmove((void*)(pa0 + (dstva - va0)), src, n);
    80001744:	9562                	add	a0,a0,s8
    80001746:	0004861b          	sext.w	a2,s1
    8000174a:	85d2                	mv	a1,s4
    8000174c:	41250533          	sub	a0,a0,s2
    80001750:	fffff097          	auipc	ra,0xfffff
    80001754:	666080e7          	jalr	1638(ra) # 80000db6 <memmove>

        len -= n;
    80001758:	409989b3          	sub	s3,s3,s1
        src += n;
    8000175c:	9a26                	add	s4,s4,s1
        dstva = va0 + PGSIZE;
    8000175e:	01590c33          	add	s8,s2,s5
    while (len > 0)
    80001762:	02098263          	beqz	s3,80001786 <copyout+0x6a>
        va0 = PGROUNDDOWN(dstva);
    80001766:	017c7933          	and	s2,s8,s7
        pa0 = walkaddr(pagetable, va0);
    8000176a:	85ca                	mv	a1,s2
    8000176c:	855a                	mv	a0,s6
    8000176e:	00000097          	auipc	ra,0x0
    80001772:	97a080e7          	jalr	-1670(ra) # 800010e8 <walkaddr>
        if (pa0 == 0)
    80001776:	cd01                	beqz	a0,8000178e <copyout+0x72>
        n = PGSIZE - (dstva - va0);
    80001778:	418904b3          	sub	s1,s2,s8
    8000177c:	94d6                	add	s1,s1,s5
        if (n > len)
    8000177e:	fc99f3e3          	bgeu	s3,s1,80001744 <copyout+0x28>
    80001782:	84ce                	mv	s1,s3
    80001784:	b7c1                	j	80001744 <copyout+0x28>
    }
    return 0;
    80001786:	4501                	li	a0,0
    80001788:	a021                	j	80001790 <copyout+0x74>
    8000178a:	4501                	li	a0,0
}
    8000178c:	8082                	ret
            return -1;
    8000178e:	557d                	li	a0,-1
}
    80001790:	60a6                	ld	ra,72(sp)
    80001792:	6406                	ld	s0,64(sp)
    80001794:	74e2                	ld	s1,56(sp)
    80001796:	7942                	ld	s2,48(sp)
    80001798:	79a2                	ld	s3,40(sp)
    8000179a:	7a02                	ld	s4,32(sp)
    8000179c:	6ae2                	ld	s5,24(sp)
    8000179e:	6b42                	ld	s6,16(sp)
    800017a0:	6ba2                	ld	s7,8(sp)
    800017a2:	6c02                	ld	s8,0(sp)
    800017a4:	6161                	addi	sp,sp,80
    800017a6:	8082                	ret

00000000800017a8 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char* dst, uint64 srcva, uint64 len)
{
    uint64 n, va0, pa0;

    while (len > 0)
    800017a8:	c6bd                	beqz	a3,80001816 <copyin+0x6e>
{
    800017aa:	715d                	addi	sp,sp,-80
    800017ac:	e486                	sd	ra,72(sp)
    800017ae:	e0a2                	sd	s0,64(sp)
    800017b0:	fc26                	sd	s1,56(sp)
    800017b2:	f84a                	sd	s2,48(sp)
    800017b4:	f44e                	sd	s3,40(sp)
    800017b6:	f052                	sd	s4,32(sp)
    800017b8:	ec56                	sd	s5,24(sp)
    800017ba:	e85a                	sd	s6,16(sp)
    800017bc:	e45e                	sd	s7,8(sp)
    800017be:	e062                	sd	s8,0(sp)
    800017c0:	0880                	addi	s0,sp,80
    800017c2:	8b2a                	mv	s6,a0
    800017c4:	8a2e                	mv	s4,a1
    800017c6:	8c32                	mv	s8,a2
    800017c8:	89b6                	mv	s3,a3
    {
        va0 = PGROUNDDOWN(srcva);
    800017ca:	7bfd                	lui	s7,0xfffff
        pa0 = walkaddr(pagetable, va0);
        if (pa0 == 0)
            return -1;
        n = PGSIZE - (srcva - va0);
    800017cc:	6a85                	lui	s5,0x1
    800017ce:	a015                	j	800017f2 <copyin+0x4a>
        if (n > len)
            n = len;
        memmove(dst, (void*)(pa0 + (srcva - va0)), n);
    800017d0:	9562                	add	a0,a0,s8
    800017d2:	0004861b          	sext.w	a2,s1
    800017d6:	412505b3          	sub	a1,a0,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	fffff097          	auipc	ra,0xfffff
    800017e0:	5da080e7          	jalr	1498(ra) # 80000db6 <memmove>

        len -= n;
    800017e4:	409989b3          	sub	s3,s3,s1
        dst += n;
    800017e8:	9a26                	add	s4,s4,s1
        srcva = va0 + PGSIZE;
    800017ea:	01590c33          	add	s8,s2,s5
    while (len > 0)
    800017ee:	02098263          	beqz	s3,80001812 <copyin+0x6a>
        va0 = PGROUNDDOWN(srcva);
    800017f2:	017c7933          	and	s2,s8,s7
        pa0 = walkaddr(pagetable, va0);
    800017f6:	85ca                	mv	a1,s2
    800017f8:	855a                	mv	a0,s6
    800017fa:	00000097          	auipc	ra,0x0
    800017fe:	8ee080e7          	jalr	-1810(ra) # 800010e8 <walkaddr>
        if (pa0 == 0)
    80001802:	cd01                	beqz	a0,8000181a <copyin+0x72>
        n = PGSIZE - (srcva - va0);
    80001804:	418904b3          	sub	s1,s2,s8
    80001808:	94d6                	add	s1,s1,s5
        if (n > len)
    8000180a:	fc99f3e3          	bgeu	s3,s1,800017d0 <copyin+0x28>
    8000180e:	84ce                	mv	s1,s3
    80001810:	b7c1                	j	800017d0 <copyin+0x28>
    }
    return 0;
    80001812:	4501                	li	a0,0
    80001814:	a021                	j	8000181c <copyin+0x74>
    80001816:	4501                	li	a0,0
}
    80001818:	8082                	ret
            return -1;
    8000181a:	557d                	li	a0,-1
}
    8000181c:	60a6                	ld	ra,72(sp)
    8000181e:	6406                	ld	s0,64(sp)
    80001820:	74e2                	ld	s1,56(sp)
    80001822:	7942                	ld	s2,48(sp)
    80001824:	79a2                	ld	s3,40(sp)
    80001826:	7a02                	ld	s4,32(sp)
    80001828:	6ae2                	ld	s5,24(sp)
    8000182a:	6b42                	ld	s6,16(sp)
    8000182c:	6ba2                	ld	s7,8(sp)
    8000182e:	6c02                	ld	s8,0(sp)
    80001830:	6161                	addi	sp,sp,80
    80001832:	8082                	ret

0000000080001834 <copyinstr>:
int copyinstr(pagetable_t pagetable, char* dst, uint64 srcva, uint64 max)
{
    uint64 n, va0, pa0;
    int got_null = 0;

    while (got_null == 0 && max > 0)
    80001834:	c6c5                	beqz	a3,800018dc <copyinstr+0xa8>
{
    80001836:	715d                	addi	sp,sp,-80
    80001838:	e486                	sd	ra,72(sp)
    8000183a:	e0a2                	sd	s0,64(sp)
    8000183c:	fc26                	sd	s1,56(sp)
    8000183e:	f84a                	sd	s2,48(sp)
    80001840:	f44e                	sd	s3,40(sp)
    80001842:	f052                	sd	s4,32(sp)
    80001844:	ec56                	sd	s5,24(sp)
    80001846:	e85a                	sd	s6,16(sp)
    80001848:	e45e                	sd	s7,8(sp)
    8000184a:	0880                	addi	s0,sp,80
    8000184c:	8a2a                	mv	s4,a0
    8000184e:	8b2e                	mv	s6,a1
    80001850:	8bb2                	mv	s7,a2
    80001852:	84b6                	mv	s1,a3
    {
        va0 = PGROUNDDOWN(srcva);
    80001854:	7afd                	lui	s5,0xfffff
        pa0 = walkaddr(pagetable, va0);
        if (pa0 == 0)
            return -1;
        n = PGSIZE - (srcva - va0);
    80001856:	6985                	lui	s3,0x1
    80001858:	a035                	j	80001884 <copyinstr+0x50>
        char* p = (char*)(pa0 + (srcva - va0));
        while (n > 0)
        {
            if (*p == '\0')
            {
                *dst = '\0';
    8000185a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000185e:	4785                	li	a5,1
            dst++;
        }

        srcva = va0 + PGSIZE;
    }
    if (got_null)
    80001860:	0017b793          	seqz	a5,a5
    80001864:	40f00533          	neg	a0,a5
    }
    else
    {
        return -1;
    }
}
    80001868:	60a6                	ld	ra,72(sp)
    8000186a:	6406                	ld	s0,64(sp)
    8000186c:	74e2                	ld	s1,56(sp)
    8000186e:	7942                	ld	s2,48(sp)
    80001870:	79a2                	ld	s3,40(sp)
    80001872:	7a02                	ld	s4,32(sp)
    80001874:	6ae2                	ld	s5,24(sp)
    80001876:	6b42                	ld	s6,16(sp)
    80001878:	6ba2                	ld	s7,8(sp)
    8000187a:	6161                	addi	sp,sp,80
    8000187c:	8082                	ret
        srcva = va0 + PGSIZE;
    8000187e:	01390bb3          	add	s7,s2,s3
    while (got_null == 0 && max > 0)
    80001882:	c8a9                	beqz	s1,800018d4 <copyinstr+0xa0>
        va0 = PGROUNDDOWN(srcva);
    80001884:	015bf933          	and	s2,s7,s5
        pa0 = walkaddr(pagetable, va0);
    80001888:	85ca                	mv	a1,s2
    8000188a:	8552                	mv	a0,s4
    8000188c:	00000097          	auipc	ra,0x0
    80001890:	85c080e7          	jalr	-1956(ra) # 800010e8 <walkaddr>
        if (pa0 == 0)
    80001894:	c131                	beqz	a0,800018d8 <copyinstr+0xa4>
        n = PGSIZE - (srcva - va0);
    80001896:	41790833          	sub	a6,s2,s7
    8000189a:	984e                	add	a6,a6,s3
        if (n > max)
    8000189c:	0104f363          	bgeu	s1,a6,800018a2 <copyinstr+0x6e>
    800018a0:	8826                	mv	a6,s1
        char* p = (char*)(pa0 + (srcva - va0));
    800018a2:	955e                	add	a0,a0,s7
    800018a4:	41250533          	sub	a0,a0,s2
        while (n > 0)
    800018a8:	fc080be3          	beqz	a6,8000187e <copyinstr+0x4a>
    800018ac:	985a                	add	a6,a6,s6
    800018ae:	87da                	mv	a5,s6
            if (*p == '\0')
    800018b0:	41650633          	sub	a2,a0,s6
    800018b4:	14fd                	addi	s1,s1,-1
    800018b6:	9b26                	add	s6,s6,s1
    800018b8:	00f60733          	add	a4,a2,a5
    800018bc:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800018c0:	df49                	beqz	a4,8000185a <copyinstr+0x26>
                *dst = *p;
    800018c2:	00e78023          	sb	a4,0(a5)
            --max;
    800018c6:	40fb04b3          	sub	s1,s6,a5
            dst++;
    800018ca:	0785                	addi	a5,a5,1
        while (n > 0)
    800018cc:	ff0796e3          	bne	a5,a6,800018b8 <copyinstr+0x84>
            dst++;
    800018d0:	8b42                	mv	s6,a6
    800018d2:	b775                	j	8000187e <copyinstr+0x4a>
    800018d4:	4781                	li	a5,0
    800018d6:	b769                	j	80001860 <copyinstr+0x2c>
            return -1;
    800018d8:	557d                	li	a0,-1
    800018da:	b779                	j	80001868 <copyinstr+0x34>
    int got_null = 0;
    800018dc:	4781                	li	a5,0
    if (got_null)
    800018de:	0017b793          	seqz	a5,a5
    800018e2:	40f00533          	neg	a0,a5
}
    800018e6:	8082                	ret

00000000800018e8 <vmprint_dfs>:

void vmprint_dfs(const pagetable_t pagetable, int level)
{
    if (level >= 3)
    800018e8:	4789                	li	a5,2
    800018ea:	0ab7c863          	blt	a5,a1,8000199a <vmprint_dfs+0xb2>
{
    800018ee:	711d                	addi	sp,sp,-96
    800018f0:	ec86                	sd	ra,88(sp)
    800018f2:	e8a2                	sd	s0,80(sp)
    800018f4:	e4a6                	sd	s1,72(sp)
    800018f6:	e0ca                	sd	s2,64(sp)
    800018f8:	fc4e                	sd	s3,56(sp)
    800018fa:	f852                	sd	s4,48(sp)
    800018fc:	f456                	sd	s5,40(sp)
    800018fe:	f05a                	sd	s6,32(sp)
    80001900:	ec5e                	sd	s7,24(sp)
    80001902:	e862                	sd	s8,16(sp)
    80001904:	e466                	sd	s9,8(sp)
    80001906:	e06a                	sd	s10,0(sp)
    80001908:	1080                	addi	s0,sp,96
    8000190a:	8b2e                	mv	s6,a1
    8000190c:	892a                	mv	s2,a0
    {
        return;
    }
    for (int i = 0; i < 512; i++)
    8000190e:	4481                	li	s1,0
        {
            for (int j = 0; j < level; j++)
            {
                printf("..  ");
            }
            printf("..%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    80001910:	00007c97          	auipc	s9,0x7
    80001914:	8c0c8c93          	addi	s9,s9,-1856 # 800081d0 <digits+0x190>
            uint64 child = PTE2PA(pte);
            vmprint_dfs((pagetable_t)child, level + 1);
    80001918:	00158c1b          	addiw	s8,a1,1
                printf("..  ");
    8000191c:	00007b97          	auipc	s7,0x7
    80001920:	8acb8b93          	addi	s7,s7,-1876 # 800081c8 <digits+0x188>
            for (int j = 0; j < level; j++)
    80001924:	4d09                	li	s10,2
    for (int i = 0; i < 512; i++)
    80001926:	20000a93          	li	s5,512
    8000192a:	a81d                	j	80001960 <vmprint_dfs+0x78>
                printf("..  ");
    8000192c:	855e                	mv	a0,s7
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	c64080e7          	jalr	-924(ra) # 80000592 <printf>
            printf("..%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    80001936:	00a9da13          	srli	s4,s3,0xa
    8000193a:	0a32                	slli	s4,s4,0xc
    8000193c:	86d2                	mv	a3,s4
    8000193e:	864e                	mv	a2,s3
    80001940:	85a6                	mv	a1,s1
    80001942:	8566                	mv	a0,s9
    80001944:	fffff097          	auipc	ra,0xfffff
    80001948:	c4e080e7          	jalr	-946(ra) # 80000592 <printf>
            vmprint_dfs((pagetable_t)child, level + 1);
    8000194c:	85e2                	mv	a1,s8
    8000194e:	8552                	mv	a0,s4
    80001950:	00000097          	auipc	ra,0x0
    80001954:	f98080e7          	jalr	-104(ra) # 800018e8 <vmprint_dfs>
    for (int i = 0; i < 512; i++)
    80001958:	2485                	addiw	s1,s1,1
    8000195a:	0921                	addi	s2,s2,8
    8000195c:	03548163          	beq	s1,s5,8000197e <vmprint_dfs+0x96>
        pte_t pte = pagetable[i];
    80001960:	00093983          	ld	s3,0(s2) # 1000 <_entry-0x7ffff000>
        if ((pte & PTE_V))
    80001964:	0019f793          	andi	a5,s3,1
    80001968:	dbe5                	beqz	a5,80001958 <vmprint_dfs+0x70>
            for (int j = 0; j < level; j++)
    8000196a:	fd6056e3          	blez	s6,80001936 <vmprint_dfs+0x4e>
                printf("..  ");
    8000196e:	855e                	mv	a0,s7
    80001970:	fffff097          	auipc	ra,0xfffff
    80001974:	c22080e7          	jalr	-990(ra) # 80000592 <printf>
            for (int j = 0; j < level; j++)
    80001978:	fbab0ae3          	beq	s6,s10,8000192c <vmprint_dfs+0x44>
    8000197c:	bf6d                	j	80001936 <vmprint_dfs+0x4e>
        }
    }
}
    8000197e:	60e6                	ld	ra,88(sp)
    80001980:	6446                	ld	s0,80(sp)
    80001982:	64a6                	ld	s1,72(sp)
    80001984:	6906                	ld	s2,64(sp)
    80001986:	79e2                	ld	s3,56(sp)
    80001988:	7a42                	ld	s4,48(sp)
    8000198a:	7aa2                	ld	s5,40(sp)
    8000198c:	7b02                	ld	s6,32(sp)
    8000198e:	6be2                	ld	s7,24(sp)
    80001990:	6c42                	ld	s8,16(sp)
    80001992:	6ca2                	ld	s9,8(sp)
    80001994:	6d02                	ld	s10,0(sp)
    80001996:	6125                	addi	sp,sp,96
    80001998:	8082                	ret
    8000199a:	8082                	ret

000000008000199c <vmprint>:

void vmprint(pagetable_t pagetable, int level, VmPrintFunc call)
{
    8000199c:	1101                	addi	sp,sp,-32
    8000199e:	ec06                	sd	ra,24(sp)
    800019a0:	e822                	sd	s0,16(sp)
    800019a2:	e426                	sd	s1,8(sp)
    800019a4:	e04a                	sd	s2,0(sp)
    800019a6:	1000                	addi	s0,sp,32
    800019a8:	84aa                	mv	s1,a0
    800019aa:	8932                	mv	s2,a2
    printf("page table %p\n", pagetable);
    800019ac:	85aa                	mv	a1,a0
    800019ae:	00007517          	auipc	a0,0x7
    800019b2:	83a50513          	addi	a0,a0,-1990 # 800081e8 <digits+0x1a8>
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	bdc080e7          	jalr	-1060(ra) # 80000592 <printf>
    call(pagetable, 0);
    800019be:	4581                	li	a1,0
    800019c0:	8526                	mv	a0,s1
    800019c2:	9902                	jalr	s2
    800019c4:	60e2                	ld	ra,24(sp)
    800019c6:	6442                	ld	s0,16(sp)
    800019c8:	64a2                	ld	s1,8(sp)
    800019ca:	6902                	ld	s2,0(sp)
    800019cc:	6105                	addi	sp,sp,32
    800019ce:	8082                	ret

00000000800019d0 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc* p)
{
    800019d0:	1101                	addi	sp,sp,-32
    800019d2:	ec06                	sd	ra,24(sp)
    800019d4:	e822                	sd	s0,16(sp)
    800019d6:	e426                	sd	s1,8(sp)
    800019d8:	1000                	addi	s0,sp,32
    800019da:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800019dc:	fffff097          	auipc	ra,0xfffff
    800019e0:	204080e7          	jalr	516(ra) # 80000be0 <holding>
    800019e4:	c909                	beqz	a0,800019f6 <wakeup1+0x26>
        panic("wakeup1");
    if (p->chan == p && p->state == SLEEPING)
    800019e6:	749c                	ld	a5,40(s1)
    800019e8:	00978f63          	beq	a5,s1,80001a06 <wakeup1+0x36>
    {
        p->state = RUNNABLE;
    }
}
    800019ec:	60e2                	ld	ra,24(sp)
    800019ee:	6442                	ld	s0,16(sp)
    800019f0:	64a2                	ld	s1,8(sp)
    800019f2:	6105                	addi	sp,sp,32
    800019f4:	8082                	ret
        panic("wakeup1");
    800019f6:	00007517          	auipc	a0,0x7
    800019fa:	80250513          	addi	a0,a0,-2046 # 800081f8 <digits+0x1b8>
    800019fe:	fffff097          	auipc	ra,0xfffff
    80001a02:	b4a080e7          	jalr	-1206(ra) # 80000548 <panic>
    if (p->chan == p && p->state == SLEEPING)
    80001a06:	4c98                	lw	a4,24(s1)
    80001a08:	4785                	li	a5,1
    80001a0a:	fef711e3          	bne	a4,a5,800019ec <wakeup1+0x1c>
        p->state = RUNNABLE;
    80001a0e:	4789                	li	a5,2
    80001a10:	cc9c                	sw	a5,24(s1)
}
    80001a12:	bfe9                	j	800019ec <wakeup1+0x1c>

0000000080001a14 <procinit>:
{
    80001a14:	715d                	addi	sp,sp,-80
    80001a16:	e486                	sd	ra,72(sp)
    80001a18:	e0a2                	sd	s0,64(sp)
    80001a1a:	fc26                	sd	s1,56(sp)
    80001a1c:	f84a                	sd	s2,48(sp)
    80001a1e:	f44e                	sd	s3,40(sp)
    80001a20:	f052                	sd	s4,32(sp)
    80001a22:	ec56                	sd	s5,24(sp)
    80001a24:	e85a                	sd	s6,16(sp)
    80001a26:	e45e                	sd	s7,8(sp)
    80001a28:	0880                	addi	s0,sp,80
    initlock(&pid_lock, "nextpid");
    80001a2a:	00006597          	auipc	a1,0x6
    80001a2e:	7d658593          	addi	a1,a1,2006 # 80008200 <digits+0x1c0>
    80001a32:	00010517          	auipc	a0,0x10
    80001a36:	f1e50513          	addi	a0,a0,-226 # 80011950 <pid_lock>
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	190080e7          	jalr	400(ra) # 80000bca <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001a42:	00010917          	auipc	s2,0x10
    80001a46:	32690913          	addi	s2,s2,806 # 80011d68 <proc>
        initlock(&p->lock, "proc");
    80001a4a:	00006b97          	auipc	s7,0x6
    80001a4e:	7beb8b93          	addi	s7,s7,1982 # 80008208 <digits+0x1c8>
        uint64 va = KSTACK((int)(p - proc));
    80001a52:	8b4a                	mv	s6,s2
    80001a54:	00006a97          	auipc	s5,0x6
    80001a58:	5aca8a93          	addi	s5,s5,1452 # 80008000 <etext>
    80001a5c:	040009b7          	lui	s3,0x4000
    80001a60:	19fd                	addi	s3,s3,-1
    80001a62:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001a64:	00016a17          	auipc	s4,0x16
    80001a68:	f04a0a13          	addi	s4,s4,-252 # 80017968 <tickslock>
        initlock(&p->lock, "proc");
    80001a6c:	85de                	mv	a1,s7
    80001a6e:	854a                	mv	a0,s2
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	15a080e7          	jalr	346(ra) # 80000bca <initlock>
        char* pa = kalloc();
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	0a8080e7          	jalr	168(ra) # 80000b20 <kalloc>
    80001a80:	85aa                	mv	a1,a0
        if (pa == 0)
    80001a82:	c929                	beqz	a0,80001ad4 <procinit+0xc0>
        uint64 va = KSTACK((int)(p - proc));
    80001a84:	416904b3          	sub	s1,s2,s6
    80001a88:	8491                	srai	s1,s1,0x4
    80001a8a:	000ab783          	ld	a5,0(s5)
    80001a8e:	02f484b3          	mul	s1,s1,a5
    80001a92:	2485                	addiw	s1,s1,1
    80001a94:	00d4949b          	slliw	s1,s1,0xd
    80001a98:	409984b3          	sub	s1,s3,s1
        kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a9c:	4699                	li	a3,6
    80001a9e:	6605                	lui	a2,0x1
    80001aa0:	8526                	mv	a0,s1
    80001aa2:	fffff097          	auipc	ra,0xfffff
    80001aa6:	774080e7          	jalr	1908(ra) # 80001216 <kvmmap>
        p->kstack = va;
    80001aaa:	04993023          	sd	s1,64(s2)
    for (p = proc; p < &proc[NPROC]; p++)
    80001aae:	17090913          	addi	s2,s2,368
    80001ab2:	fb491de3          	bne	s2,s4,80001a6c <procinit+0x58>
    kvminithart();
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	568080e7          	jalr	1384(ra) # 8000101e <kvminithart>
}
    80001abe:	60a6                	ld	ra,72(sp)
    80001ac0:	6406                	ld	s0,64(sp)
    80001ac2:	74e2                	ld	s1,56(sp)
    80001ac4:	7942                	ld	s2,48(sp)
    80001ac6:	79a2                	ld	s3,40(sp)
    80001ac8:	7a02                	ld	s4,32(sp)
    80001aca:	6ae2                	ld	s5,24(sp)
    80001acc:	6b42                	ld	s6,16(sp)
    80001ace:	6ba2                	ld	s7,8(sp)
    80001ad0:	6161                	addi	sp,sp,80
    80001ad2:	8082                	ret
            panic("kalloc");
    80001ad4:	00006517          	auipc	a0,0x6
    80001ad8:	73c50513          	addi	a0,a0,1852 # 80008210 <digits+0x1d0>
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	a6c080e7          	jalr	-1428(ra) # 80000548 <panic>

0000000080001ae4 <cpuid>:
{
    80001ae4:	1141                	addi	sp,sp,-16
    80001ae6:	e422                	sd	s0,8(sp)
    80001ae8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001aea:	8512                	mv	a0,tp
}
    80001aec:	2501                	sext.w	a0,a0
    80001aee:	6422                	ld	s0,8(sp)
    80001af0:	0141                	addi	sp,sp,16
    80001af2:	8082                	ret

0000000080001af4 <mycpu>:
{
    80001af4:	1141                	addi	sp,sp,-16
    80001af6:	e422                	sd	s0,8(sp)
    80001af8:	0800                	addi	s0,sp,16
    80001afa:	8792                	mv	a5,tp
    struct cpu* c = &cpus[id];
    80001afc:	2781                	sext.w	a5,a5
    80001afe:	079e                	slli	a5,a5,0x7
}
    80001b00:	00010517          	auipc	a0,0x10
    80001b04:	e6850513          	addi	a0,a0,-408 # 80011968 <cpus>
    80001b08:	953e                	add	a0,a0,a5
    80001b0a:	6422                	ld	s0,8(sp)
    80001b0c:	0141                	addi	sp,sp,16
    80001b0e:	8082                	ret

0000000080001b10 <myproc>:
{
    80001b10:	1101                	addi	sp,sp,-32
    80001b12:	ec06                	sd	ra,24(sp)
    80001b14:	e822                	sd	s0,16(sp)
    80001b16:	e426                	sd	s1,8(sp)
    80001b18:	1000                	addi	s0,sp,32
    push_off();
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	0f4080e7          	jalr	244(ra) # 80000c0e <push_off>
    80001b22:	8792                	mv	a5,tp
    struct proc* p = c->proc;
    80001b24:	2781                	sext.w	a5,a5
    80001b26:	079e                	slli	a5,a5,0x7
    80001b28:	00010717          	auipc	a4,0x10
    80001b2c:	e2870713          	addi	a4,a4,-472 # 80011950 <pid_lock>
    80001b30:	97ba                	add	a5,a5,a4
    80001b32:	6f84                	ld	s1,24(a5)
    pop_off();
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	17a080e7          	jalr	378(ra) # 80000cae <pop_off>
}
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	60e2                	ld	ra,24(sp)
    80001b40:	6442                	ld	s0,16(sp)
    80001b42:	64a2                	ld	s1,8(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret

0000000080001b48 <forkret>:
{
    80001b48:	1141                	addi	sp,sp,-16
    80001b4a:	e406                	sd	ra,8(sp)
    80001b4c:	e022                	sd	s0,0(sp)
    80001b4e:	0800                	addi	s0,sp,16
    release(&myproc()->lock);
    80001b50:	00000097          	auipc	ra,0x0
    80001b54:	fc0080e7          	jalr	-64(ra) # 80001b10 <myproc>
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	1b6080e7          	jalr	438(ra) # 80000d0e <release>
    if (first)
    80001b60:	00007797          	auipc	a5,0x7
    80001b64:	db07a783          	lw	a5,-592(a5) # 80008910 <first.1677>
    80001b68:	eb89                	bnez	a5,80001b7a <forkret+0x32>
    usertrapret();
    80001b6a:	00001097          	auipc	ra,0x1
    80001b6e:	c74080e7          	jalr	-908(ra) # 800027de <usertrapret>
}
    80001b72:	60a2                	ld	ra,8(sp)
    80001b74:	6402                	ld	s0,0(sp)
    80001b76:	0141                	addi	sp,sp,16
    80001b78:	8082                	ret
        first = 0;
    80001b7a:	00007797          	auipc	a5,0x7
    80001b7e:	d807ab23          	sw	zero,-618(a5) # 80008910 <first.1677>
        fsinit(ROOTDEV);
    80001b82:	4505                	li	a0,1
    80001b84:	00002097          	auipc	ra,0x2
    80001b88:	a68080e7          	jalr	-1432(ra) # 800035ec <fsinit>
    80001b8c:	bff9                	j	80001b6a <forkret+0x22>

0000000080001b8e <allocpid>:
{
    80001b8e:	1101                	addi	sp,sp,-32
    80001b90:	ec06                	sd	ra,24(sp)
    80001b92:	e822                	sd	s0,16(sp)
    80001b94:	e426                	sd	s1,8(sp)
    80001b96:	e04a                	sd	s2,0(sp)
    80001b98:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001b9a:	00010917          	auipc	s2,0x10
    80001b9e:	db690913          	addi	s2,s2,-586 # 80011950 <pid_lock>
    80001ba2:	854a                	mv	a0,s2
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	0b6080e7          	jalr	182(ra) # 80000c5a <acquire>
    pid = nextpid;
    80001bac:	00007797          	auipc	a5,0x7
    80001bb0:	d6878793          	addi	a5,a5,-664 # 80008914 <nextpid>
    80001bb4:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001bb6:	0014871b          	addiw	a4,s1,1
    80001bba:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001bbc:	854a                	mv	a0,s2
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	150080e7          	jalr	336(ra) # 80000d0e <release>
}
    80001bc6:	8526                	mv	a0,s1
    80001bc8:	60e2                	ld	ra,24(sp)
    80001bca:	6442                	ld	s0,16(sp)
    80001bcc:	64a2                	ld	s1,8(sp)
    80001bce:	6902                	ld	s2,0(sp)
    80001bd0:	6105                	addi	sp,sp,32
    80001bd2:	8082                	ret

0000000080001bd4 <proc_pagetable>:
{
    80001bd4:	1101                	addi	sp,sp,-32
    80001bd6:	ec06                	sd	ra,24(sp)
    80001bd8:	e822                	sd	s0,16(sp)
    80001bda:	e426                	sd	s1,8(sp)
    80001bdc:	e04a                	sd	s2,0(sp)
    80001bde:	1000                	addi	s0,sp,32
    80001be0:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001be2:	00000097          	auipc	ra,0x0
    80001be6:	802080e7          	jalr	-2046(ra) # 800013e4 <uvmcreate>
    80001bea:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001bec:	c121                	beqz	a0,80001c2c <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bee:	4729                	li	a4,10
    80001bf0:	00005697          	auipc	a3,0x5
    80001bf4:	41068693          	addi	a3,a3,1040 # 80007000 <_trampoline>
    80001bf8:	6605                	lui	a2,0x1
    80001bfa:	040005b7          	lui	a1,0x4000
    80001bfe:	15fd                	addi	a1,a1,-1
    80001c00:	05b2                	slli	a1,a1,0xc
    80001c02:	fffff097          	auipc	ra,0xfffff
    80001c06:	586080e7          	jalr	1414(ra) # 80001188 <mappages>
    80001c0a:	02054863          	bltz	a0,80001c3a <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c0e:	4719                	li	a4,6
    80001c10:	05893683          	ld	a3,88(s2)
    80001c14:	6605                	lui	a2,0x1
    80001c16:	020005b7          	lui	a1,0x2000
    80001c1a:	15fd                	addi	a1,a1,-1
    80001c1c:	05b6                	slli	a1,a1,0xd
    80001c1e:	8526                	mv	a0,s1
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	568080e7          	jalr	1384(ra) # 80001188 <mappages>
    80001c28:	02054163          	bltz	a0,80001c4a <proc_pagetable+0x76>
}
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	60e2                	ld	ra,24(sp)
    80001c30:	6442                	ld	s0,16(sp)
    80001c32:	64a2                	ld	s1,8(sp)
    80001c34:	6902                	ld	s2,0(sp)
    80001c36:	6105                	addi	sp,sp,32
    80001c38:	8082                	ret
        uvmfree(pagetable, 0);
    80001c3a:	4581                	li	a1,0
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	00000097          	auipc	ra,0x0
    80001c42:	9a2080e7          	jalr	-1630(ra) # 800015e0 <uvmfree>
        return 0;
    80001c46:	4481                	li	s1,0
    80001c48:	b7d5                	j	80001c2c <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c4a:	4681                	li	a3,0
    80001c4c:	4605                	li	a2,1
    80001c4e:	040005b7          	lui	a1,0x4000
    80001c52:	15fd                	addi	a1,a1,-1
    80001c54:	05b2                	slli	a1,a1,0xc
    80001c56:	8526                	mv	a0,s1
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	6c8080e7          	jalr	1736(ra) # 80001320 <uvmunmap>
        uvmfree(pagetable, 0);
    80001c60:	4581                	li	a1,0
    80001c62:	8526                	mv	a0,s1
    80001c64:	00000097          	auipc	ra,0x0
    80001c68:	97c080e7          	jalr	-1668(ra) # 800015e0 <uvmfree>
        return 0;
    80001c6c:	4481                	li	s1,0
    80001c6e:	bf7d                	j	80001c2c <proc_pagetable+0x58>

0000000080001c70 <proc_freepagetable>:
{
    80001c70:	1101                	addi	sp,sp,-32
    80001c72:	ec06                	sd	ra,24(sp)
    80001c74:	e822                	sd	s0,16(sp)
    80001c76:	e426                	sd	s1,8(sp)
    80001c78:	e04a                	sd	s2,0(sp)
    80001c7a:	1000                	addi	s0,sp,32
    80001c7c:	84aa                	mv	s1,a0
    80001c7e:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c80:	4681                	li	a3,0
    80001c82:	4605                	li	a2,1
    80001c84:	040005b7          	lui	a1,0x4000
    80001c88:	15fd                	addi	a1,a1,-1
    80001c8a:	05b2                	slli	a1,a1,0xc
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	694080e7          	jalr	1684(ra) # 80001320 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c94:	4681                	li	a3,0
    80001c96:	4605                	li	a2,1
    80001c98:	020005b7          	lui	a1,0x2000
    80001c9c:	15fd                	addi	a1,a1,-1
    80001c9e:	05b6                	slli	a1,a1,0xd
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	67e080e7          	jalr	1662(ra) # 80001320 <uvmunmap>
    uvmfree(pagetable, sz);
    80001caa:	85ca                	mv	a1,s2
    80001cac:	8526                	mv	a0,s1
    80001cae:	00000097          	auipc	ra,0x0
    80001cb2:	932080e7          	jalr	-1742(ra) # 800015e0 <uvmfree>
}
    80001cb6:	60e2                	ld	ra,24(sp)
    80001cb8:	6442                	ld	s0,16(sp)
    80001cba:	64a2                	ld	s1,8(sp)
    80001cbc:	6902                	ld	s2,0(sp)
    80001cbe:	6105                	addi	sp,sp,32
    80001cc0:	8082                	ret

0000000080001cc2 <freeproc>:
{
    80001cc2:	1101                	addi	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	1000                	addi	s0,sp,32
    80001ccc:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001cce:	6d28                	ld	a0,88(a0)
    80001cd0:	c509                	beqz	a0,80001cda <freeproc+0x18>
        kfree((void*)p->trapframe);
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	d52080e7          	jalr	-686(ra) # 80000a24 <kfree>
    p->trapframe = 0;
    80001cda:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001cde:	68a8                	ld	a0,80(s1)
    80001ce0:	c511                	beqz	a0,80001cec <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001ce2:	64ac                	ld	a1,72(s1)
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	f8c080e7          	jalr	-116(ra) # 80001c70 <proc_freepagetable>
    p->pagetable = 0;
    80001cec:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001cf0:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001cf4:	0204ac23          	sw	zero,56(s1)
    p->parent = 0;
    80001cf8:	0204b023          	sd	zero,32(s1)
    p->name[0] = 0;
    80001cfc:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001d00:	0204b423          	sd	zero,40(s1)
    p->killed = 0;
    80001d04:	0204a823          	sw	zero,48(s1)
    p->xstate = 0;
    80001d08:	0204aa23          	sw	zero,52(s1)
    p->state = UNUSED;
    80001d0c:	0004ac23          	sw	zero,24(s1)
}
    80001d10:	60e2                	ld	ra,24(sp)
    80001d12:	6442                	ld	s0,16(sp)
    80001d14:	64a2                	ld	s1,8(sp)
    80001d16:	6105                	addi	sp,sp,32
    80001d18:	8082                	ret

0000000080001d1a <allocproc>:
{
    80001d1a:	1101                	addi	sp,sp,-32
    80001d1c:	ec06                	sd	ra,24(sp)
    80001d1e:	e822                	sd	s0,16(sp)
    80001d20:	e426                	sd	s1,8(sp)
    80001d22:	e04a                	sd	s2,0(sp)
    80001d24:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001d26:	00010497          	auipc	s1,0x10
    80001d2a:	04248493          	addi	s1,s1,66 # 80011d68 <proc>
    80001d2e:	00016917          	auipc	s2,0x16
    80001d32:	c3a90913          	addi	s2,s2,-966 # 80017968 <tickslock>
        acquire(&p->lock);
    80001d36:	8526                	mv	a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	f22080e7          	jalr	-222(ra) # 80000c5a <acquire>
        if (p->state == UNUSED)
    80001d40:	4c9c                	lw	a5,24(s1)
    80001d42:	cf81                	beqz	a5,80001d5a <allocproc+0x40>
            release(&p->lock);
    80001d44:	8526                	mv	a0,s1
    80001d46:	fffff097          	auipc	ra,0xfffff
    80001d4a:	fc8080e7          	jalr	-56(ra) # 80000d0e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001d4e:	17048493          	addi	s1,s1,368
    80001d52:	ff2492e3          	bne	s1,s2,80001d36 <allocproc+0x1c>
    return 0;
    80001d56:	4481                	li	s1,0
    80001d58:	a0b9                	j	80001da6 <allocproc+0x8c>
    p->pid = allocpid();
    80001d5a:	00000097          	auipc	ra,0x0
    80001d5e:	e34080e7          	jalr	-460(ra) # 80001b8e <allocpid>
    80001d62:	dc88                	sw	a0,56(s1)
    if ((p->trapframe = (struct trapframe*)kalloc()) == 0)
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	dbc080e7          	jalr	-580(ra) # 80000b20 <kalloc>
    80001d6c:	892a                	mv	s2,a0
    80001d6e:	eca8                	sd	a0,88(s1)
    80001d70:	c131                	beqz	a0,80001db4 <allocproc+0x9a>
    p->pagetable = proc_pagetable(p);
    80001d72:	8526                	mv	a0,s1
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	e60080e7          	jalr	-416(ra) # 80001bd4 <proc_pagetable>
    80001d7c:	892a                	mv	s2,a0
    80001d7e:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001d80:	c129                	beqz	a0,80001dc2 <allocproc+0xa8>
    memset(&p->context, 0, sizeof(p->context));
    80001d82:	07000613          	li	a2,112
    80001d86:	4581                	li	a1,0
    80001d88:	06048513          	addi	a0,s1,96
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	fca080e7          	jalr	-54(ra) # 80000d56 <memset>
    p->context.ra = (uint64)forkret;
    80001d94:	00000797          	auipc	a5,0x0
    80001d98:	db478793          	addi	a5,a5,-588 # 80001b48 <forkret>
    80001d9c:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001d9e:	60bc                	ld	a5,64(s1)
    80001da0:	6705                	lui	a4,0x1
    80001da2:	97ba                	add	a5,a5,a4
    80001da4:	f4bc                	sd	a5,104(s1)
}
    80001da6:	8526                	mv	a0,s1
    80001da8:	60e2                	ld	ra,24(sp)
    80001daa:	6442                	ld	s0,16(sp)
    80001dac:	64a2                	ld	s1,8(sp)
    80001dae:	6902                	ld	s2,0(sp)
    80001db0:	6105                	addi	sp,sp,32
    80001db2:	8082                	ret
        release(&p->lock);
    80001db4:	8526                	mv	a0,s1
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	f58080e7          	jalr	-168(ra) # 80000d0e <release>
        return 0;
    80001dbe:	84ca                	mv	s1,s2
    80001dc0:	b7dd                	j	80001da6 <allocproc+0x8c>
        freeproc(p);
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	00000097          	auipc	ra,0x0
    80001dc8:	efe080e7          	jalr	-258(ra) # 80001cc2 <freeproc>
        release(&p->lock);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	f40080e7          	jalr	-192(ra) # 80000d0e <release>
        return 0;
    80001dd6:	84ca                	mv	s1,s2
    80001dd8:	b7f9                	j	80001da6 <allocproc+0x8c>

0000000080001dda <userinit>:
{
    80001dda:	1101                	addi	sp,sp,-32
    80001ddc:	ec06                	sd	ra,24(sp)
    80001dde:	e822                	sd	s0,16(sp)
    80001de0:	e426                	sd	s1,8(sp)
    80001de2:	1000                	addi	s0,sp,32
    p = allocproc();
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	f36080e7          	jalr	-202(ra) # 80001d1a <allocproc>
    80001dec:	84aa                	mv	s1,a0
    initproc = p;
    80001dee:	00007797          	auipc	a5,0x7
    80001df2:	22a7b523          	sd	a0,554(a5) # 80009018 <initproc>
    uvminit(p->pagetable, initcode, sizeof(initcode));
    80001df6:	03400613          	li	a2,52
    80001dfa:	00007597          	auipc	a1,0x7
    80001dfe:	b2658593          	addi	a1,a1,-1242 # 80008920 <initcode>
    80001e02:	6928                	ld	a0,80(a0)
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	60e080e7          	jalr	1550(ra) # 80001412 <uvminit>
    p->sz = PGSIZE;
    80001e0c:	6785                	lui	a5,0x1
    80001e0e:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0; // user program counter
    80001e10:	6cb8                	ld	a4,88(s1)
    80001e12:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001e16:	6cb8                	ld	a4,88(s1)
    80001e18:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e1a:	4641                	li	a2,16
    80001e1c:	00006597          	auipc	a1,0x6
    80001e20:	3fc58593          	addi	a1,a1,1020 # 80008218 <digits+0x1d8>
    80001e24:	15848513          	addi	a0,s1,344
    80001e28:	fffff097          	auipc	ra,0xfffff
    80001e2c:	084080e7          	jalr	132(ra) # 80000eac <safestrcpy>
    p->cwd = namei("/");
    80001e30:	00006517          	auipc	a0,0x6
    80001e34:	3f850513          	addi	a0,a0,1016 # 80008228 <digits+0x1e8>
    80001e38:	00002097          	auipc	ra,0x2
    80001e3c:	1dc080e7          	jalr	476(ra) # 80004014 <namei>
    80001e40:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001e44:	4789                	li	a5,2
    80001e46:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001e48:	8526                	mv	a0,s1
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	ec4080e7          	jalr	-316(ra) # 80000d0e <release>
}
    80001e52:	60e2                	ld	ra,24(sp)
    80001e54:	6442                	ld	s0,16(sp)
    80001e56:	64a2                	ld	s1,8(sp)
    80001e58:	6105                	addi	sp,sp,32
    80001e5a:	8082                	ret

0000000080001e5c <growproc>:
{
    80001e5c:	1101                	addi	sp,sp,-32
    80001e5e:	ec06                	sd	ra,24(sp)
    80001e60:	e822                	sd	s0,16(sp)
    80001e62:	e426                	sd	s1,8(sp)
    80001e64:	e04a                	sd	s2,0(sp)
    80001e66:	1000                	addi	s0,sp,32
    80001e68:	84aa                	mv	s1,a0
    struct proc* p = myproc();
    80001e6a:	00000097          	auipc	ra,0x0
    80001e6e:	ca6080e7          	jalr	-858(ra) # 80001b10 <myproc>
    80001e72:	892a                	mv	s2,a0
    sz = p->sz;
    80001e74:	652c                	ld	a1,72(a0)
    80001e76:	0005861b          	sext.w	a2,a1
    if (n > 0)
    80001e7a:	00904f63          	bgtz	s1,80001e98 <growproc+0x3c>
    else if (n < 0)
    80001e7e:	0204cc63          	bltz	s1,80001eb6 <growproc+0x5a>
    p->sz = sz;
    80001e82:	1602                	slli	a2,a2,0x20
    80001e84:	9201                	srli	a2,a2,0x20
    80001e86:	04c93423          	sd	a2,72(s2)
    return 0;
    80001e8a:	4501                	li	a0,0
}
    80001e8c:	60e2                	ld	ra,24(sp)
    80001e8e:	6442                	ld	s0,16(sp)
    80001e90:	64a2                	ld	s1,8(sp)
    80001e92:	6902                	ld	s2,0(sp)
    80001e94:	6105                	addi	sp,sp,32
    80001e96:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    80001e98:	9e25                	addw	a2,a2,s1
    80001e9a:	1602                	slli	a2,a2,0x20
    80001e9c:	9201                	srli	a2,a2,0x20
    80001e9e:	1582                	slli	a1,a1,0x20
    80001ea0:	9181                	srli	a1,a1,0x20
    80001ea2:	6928                	ld	a0,80(a0)
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	628080e7          	jalr	1576(ra) # 800014cc <uvmalloc>
    80001eac:	0005061b          	sext.w	a2,a0
    80001eb0:	fa69                	bnez	a2,80001e82 <growproc+0x26>
            return -1;
    80001eb2:	557d                	li	a0,-1
    80001eb4:	bfe1                	j	80001e8c <growproc+0x30>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001eb6:	9e25                	addw	a2,a2,s1
    80001eb8:	1602                	slli	a2,a2,0x20
    80001eba:	9201                	srli	a2,a2,0x20
    80001ebc:	1582                	slli	a1,a1,0x20
    80001ebe:	9181                	srli	a1,a1,0x20
    80001ec0:	6928                	ld	a0,80(a0)
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	5c2080e7          	jalr	1474(ra) # 80001484 <uvmdealloc>
    80001eca:	0005061b          	sext.w	a2,a0
    80001ece:	bf55                	j	80001e82 <growproc+0x26>

0000000080001ed0 <fork>:
{
    80001ed0:	7179                	addi	sp,sp,-48
    80001ed2:	f406                	sd	ra,40(sp)
    80001ed4:	f022                	sd	s0,32(sp)
    80001ed6:	ec26                	sd	s1,24(sp)
    80001ed8:	e84a                	sd	s2,16(sp)
    80001eda:	e44e                	sd	s3,8(sp)
    80001edc:	e052                	sd	s4,0(sp)
    80001ede:	1800                	addi	s0,sp,48
    struct proc* p = myproc();
    80001ee0:	00000097          	auipc	ra,0x0
    80001ee4:	c30080e7          	jalr	-976(ra) # 80001b10 <myproc>
    80001ee8:	892a                	mv	s2,a0
    if ((np = allocproc()) == 0)
    80001eea:	00000097          	auipc	ra,0x0
    80001eee:	e30080e7          	jalr	-464(ra) # 80001d1a <allocproc>
    80001ef2:	c575                	beqz	a0,80001fde <fork+0x10e>
    80001ef4:	89aa                	mv	s3,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001ef6:	04893603          	ld	a2,72(s2)
    80001efa:	692c                	ld	a1,80(a0)
    80001efc:	05093503          	ld	a0,80(s2)
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	718080e7          	jalr	1816(ra) # 80001618 <uvmcopy>
    80001f08:	04054c63          	bltz	a0,80001f60 <fork+0x90>
    np->sz = p->sz;
    80001f0c:	04893783          	ld	a5,72(s2)
    80001f10:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
    np->parent = p;
    80001f14:	0329b023          	sd	s2,32(s3)
    np->syscall_mask = p->syscall_mask;
    80001f18:	16892783          	lw	a5,360(s2)
    80001f1c:	16f9a423          	sw	a5,360(s3)
    *(np->trapframe) = *(p->trapframe);
    80001f20:	05893683          	ld	a3,88(s2)
    80001f24:	87b6                	mv	a5,a3
    80001f26:	0589b703          	ld	a4,88(s3)
    80001f2a:	12068693          	addi	a3,a3,288
    80001f2e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f32:	6788                	ld	a0,8(a5)
    80001f34:	6b8c                	ld	a1,16(a5)
    80001f36:	6f90                	ld	a2,24(a5)
    80001f38:	01073023          	sd	a6,0(a4)
    80001f3c:	e708                	sd	a0,8(a4)
    80001f3e:	eb0c                	sd	a1,16(a4)
    80001f40:	ef10                	sd	a2,24(a4)
    80001f42:	02078793          	addi	a5,a5,32
    80001f46:	02070713          	addi	a4,a4,32
    80001f4a:	fed792e3          	bne	a5,a3,80001f2e <fork+0x5e>
    np->trapframe->a0 = 0;
    80001f4e:	0589b783          	ld	a5,88(s3)
    80001f52:	0607b823          	sd	zero,112(a5)
    80001f56:	0d000493          	li	s1,208
    for (i = 0; i < NOFILE; i++)
    80001f5a:	15000a13          	li	s4,336
    80001f5e:	a03d                	j	80001f8c <fork+0xbc>
        freeproc(np);
    80001f60:	854e                	mv	a0,s3
    80001f62:	00000097          	auipc	ra,0x0
    80001f66:	d60080e7          	jalr	-672(ra) # 80001cc2 <freeproc>
        release(&np->lock);
    80001f6a:	854e                	mv	a0,s3
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	da2080e7          	jalr	-606(ra) # 80000d0e <release>
        return -1;
    80001f74:	54fd                	li	s1,-1
    80001f76:	a899                	j	80001fcc <fork+0xfc>
            np->ofile[i] = filedup(p->ofile[i]);
    80001f78:	00002097          	auipc	ra,0x2
    80001f7c:	728080e7          	jalr	1832(ra) # 800046a0 <filedup>
    80001f80:	009987b3          	add	a5,s3,s1
    80001f84:	e388                	sd	a0,0(a5)
    for (i = 0; i < NOFILE; i++)
    80001f86:	04a1                	addi	s1,s1,8
    80001f88:	01448763          	beq	s1,s4,80001f96 <fork+0xc6>
        if (p->ofile[i])
    80001f8c:	009907b3          	add	a5,s2,s1
    80001f90:	6388                	ld	a0,0(a5)
    80001f92:	f17d                	bnez	a0,80001f78 <fork+0xa8>
    80001f94:	bfcd                	j	80001f86 <fork+0xb6>
    np->cwd = idup(p->cwd);
    80001f96:	15093503          	ld	a0,336(s2)
    80001f9a:	00002097          	auipc	ra,0x2
    80001f9e:	88c080e7          	jalr	-1908(ra) # 80003826 <idup>
    80001fa2:	14a9b823          	sd	a0,336(s3)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80001fa6:	4641                	li	a2,16
    80001fa8:	15890593          	addi	a1,s2,344
    80001fac:	15898513          	addi	a0,s3,344
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	efc080e7          	jalr	-260(ra) # 80000eac <safestrcpy>
    pid = np->pid;
    80001fb8:	0389a483          	lw	s1,56(s3)
    np->state = RUNNABLE;
    80001fbc:	4789                	li	a5,2
    80001fbe:	00f9ac23          	sw	a5,24(s3)
    release(&np->lock);
    80001fc2:	854e                	mv	a0,s3
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	d4a080e7          	jalr	-694(ra) # 80000d0e <release>
}
    80001fcc:	8526                	mv	a0,s1
    80001fce:	70a2                	ld	ra,40(sp)
    80001fd0:	7402                	ld	s0,32(sp)
    80001fd2:	64e2                	ld	s1,24(sp)
    80001fd4:	6942                	ld	s2,16(sp)
    80001fd6:	69a2                	ld	s3,8(sp)
    80001fd8:	6a02                	ld	s4,0(sp)
    80001fda:	6145                	addi	sp,sp,48
    80001fdc:	8082                	ret
        return -1;
    80001fde:	54fd                	li	s1,-1
    80001fe0:	b7f5                	j	80001fcc <fork+0xfc>

0000000080001fe2 <reparent>:
{
    80001fe2:	7179                	addi	sp,sp,-48
    80001fe4:	f406                	sd	ra,40(sp)
    80001fe6:	f022                	sd	s0,32(sp)
    80001fe8:	ec26                	sd	s1,24(sp)
    80001fea:	e84a                	sd	s2,16(sp)
    80001fec:	e44e                	sd	s3,8(sp)
    80001fee:	e052                	sd	s4,0(sp)
    80001ff0:	1800                	addi	s0,sp,48
    80001ff2:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80001ff4:	00010497          	auipc	s1,0x10
    80001ff8:	d7448493          	addi	s1,s1,-652 # 80011d68 <proc>
            pp->parent = initproc;
    80001ffc:	00007a17          	auipc	s4,0x7
    80002000:	01ca0a13          	addi	s4,s4,28 # 80009018 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002004:	00016997          	auipc	s3,0x16
    80002008:	96498993          	addi	s3,s3,-1692 # 80017968 <tickslock>
    8000200c:	a029                	j	80002016 <reparent+0x34>
    8000200e:	17048493          	addi	s1,s1,368
    80002012:	03348363          	beq	s1,s3,80002038 <reparent+0x56>
        if (pp->parent == p)
    80002016:	709c                	ld	a5,32(s1)
    80002018:	ff279be3          	bne	a5,s2,8000200e <reparent+0x2c>
            acquire(&pp->lock);
    8000201c:	8526                	mv	a0,s1
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	c3c080e7          	jalr	-964(ra) # 80000c5a <acquire>
            pp->parent = initproc;
    80002026:	000a3783          	ld	a5,0(s4)
    8000202a:	f09c                	sd	a5,32(s1)
            release(&pp->lock);
    8000202c:	8526                	mv	a0,s1
    8000202e:	fffff097          	auipc	ra,0xfffff
    80002032:	ce0080e7          	jalr	-800(ra) # 80000d0e <release>
    80002036:	bfe1                	j	8000200e <reparent+0x2c>
}
    80002038:	70a2                	ld	ra,40(sp)
    8000203a:	7402                	ld	s0,32(sp)
    8000203c:	64e2                	ld	s1,24(sp)
    8000203e:	6942                	ld	s2,16(sp)
    80002040:	69a2                	ld	s3,8(sp)
    80002042:	6a02                	ld	s4,0(sp)
    80002044:	6145                	addi	sp,sp,48
    80002046:	8082                	ret

0000000080002048 <scheduler>:
{
    80002048:	715d                	addi	sp,sp,-80
    8000204a:	e486                	sd	ra,72(sp)
    8000204c:	e0a2                	sd	s0,64(sp)
    8000204e:	fc26                	sd	s1,56(sp)
    80002050:	f84a                	sd	s2,48(sp)
    80002052:	f44e                	sd	s3,40(sp)
    80002054:	f052                	sd	s4,32(sp)
    80002056:	ec56                	sd	s5,24(sp)
    80002058:	e85a                	sd	s6,16(sp)
    8000205a:	e45e                	sd	s7,8(sp)
    8000205c:	e062                	sd	s8,0(sp)
    8000205e:	0880                	addi	s0,sp,80
    80002060:	8792                	mv	a5,tp
    int id = r_tp();
    80002062:	2781                	sext.w	a5,a5
    c->proc = 0;
    80002064:	00779b13          	slli	s6,a5,0x7
    80002068:	00010717          	auipc	a4,0x10
    8000206c:	8e870713          	addi	a4,a4,-1816 # 80011950 <pid_lock>
    80002070:	975a                	add	a4,a4,s6
    80002072:	00073c23          	sd	zero,24(a4)
                swtch(&c->context, &p->context);
    80002076:	00010717          	auipc	a4,0x10
    8000207a:	8fa70713          	addi	a4,a4,-1798 # 80011970 <cpus+0x8>
    8000207e:	9b3a                	add	s6,s6,a4
                p->state = RUNNING;
    80002080:	4c0d                	li	s8,3
                c->proc = p;
    80002082:	079e                	slli	a5,a5,0x7
    80002084:	00010a17          	auipc	s4,0x10
    80002088:	8cca0a13          	addi	s4,s4,-1844 # 80011950 <pid_lock>
    8000208c:	9a3e                	add	s4,s4,a5
        for (p = proc; p < &proc[NPROC]; p++)
    8000208e:	00016997          	auipc	s3,0x16
    80002092:	8da98993          	addi	s3,s3,-1830 # 80017968 <tickslock>
                found = 1;
    80002096:	4b85                	li	s7,1
    80002098:	a899                	j	800020ee <scheduler+0xa6>
                p->state = RUNNING;
    8000209a:	0184ac23          	sw	s8,24(s1)
                c->proc = p;
    8000209e:	009a3c23          	sd	s1,24(s4)
                swtch(&c->context, &p->context);
    800020a2:	06048593          	addi	a1,s1,96
    800020a6:	855a                	mv	a0,s6
    800020a8:	00000097          	auipc	ra,0x0
    800020ac:	68c080e7          	jalr	1676(ra) # 80002734 <swtch>
                c->proc = 0;
    800020b0:	000a3c23          	sd	zero,24(s4)
                found = 1;
    800020b4:	8ade                	mv	s5,s7
            release(&p->lock);
    800020b6:	8526                	mv	a0,s1
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	c56080e7          	jalr	-938(ra) # 80000d0e <release>
        for (p = proc; p < &proc[NPROC]; p++)
    800020c0:	17048493          	addi	s1,s1,368
    800020c4:	01348b63          	beq	s1,s3,800020da <scheduler+0x92>
            acquire(&p->lock);
    800020c8:	8526                	mv	a0,s1
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	b90080e7          	jalr	-1136(ra) # 80000c5a <acquire>
            if (p->state == RUNNABLE)
    800020d2:	4c9c                	lw	a5,24(s1)
    800020d4:	ff2791e3          	bne	a5,s2,800020b6 <scheduler+0x6e>
    800020d8:	b7c9                	j	8000209a <scheduler+0x52>
        if (found == 0)
    800020da:	000a9a63          	bnez	s5,800020ee <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020de:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020e2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020e6:	10079073          	csrw	sstatus,a5
            asm volatile("wfi");
    800020ea:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020f2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020f6:	10079073          	csrw	sstatus,a5
        int found = 0;
    800020fa:	4a81                	li	s5,0
        for (p = proc; p < &proc[NPROC]; p++)
    800020fc:	00010497          	auipc	s1,0x10
    80002100:	c6c48493          	addi	s1,s1,-916 # 80011d68 <proc>
            if (p->state == RUNNABLE)
    80002104:	4909                	li	s2,2
    80002106:	b7c9                	j	800020c8 <scheduler+0x80>

0000000080002108 <sched>:
{
    80002108:	7179                	addi	sp,sp,-48
    8000210a:	f406                	sd	ra,40(sp)
    8000210c:	f022                	sd	s0,32(sp)
    8000210e:	ec26                	sd	s1,24(sp)
    80002110:	e84a                	sd	s2,16(sp)
    80002112:	e44e                	sd	s3,8(sp)
    80002114:	1800                	addi	s0,sp,48
    struct proc* p = myproc();
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	9fa080e7          	jalr	-1542(ra) # 80001b10 <myproc>
    8000211e:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	ac0080e7          	jalr	-1344(ra) # 80000be0 <holding>
    80002128:	c93d                	beqz	a0,8000219e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000212a:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    8000212c:	2781                	sext.w	a5,a5
    8000212e:	079e                	slli	a5,a5,0x7
    80002130:	00010717          	auipc	a4,0x10
    80002134:	82070713          	addi	a4,a4,-2016 # 80011950 <pid_lock>
    80002138:	97ba                	add	a5,a5,a4
    8000213a:	0907a703          	lw	a4,144(a5)
    8000213e:	4785                	li	a5,1
    80002140:	06f71763          	bne	a4,a5,800021ae <sched+0xa6>
    if (p->state == RUNNING)
    80002144:	4c98                	lw	a4,24(s1)
    80002146:	478d                	li	a5,3
    80002148:	06f70b63          	beq	a4,a5,800021be <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000214c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002150:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002152:	efb5                	bnez	a5,800021ce <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002154:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    80002156:	0000f917          	auipc	s2,0xf
    8000215a:	7fa90913          	addi	s2,s2,2042 # 80011950 <pid_lock>
    8000215e:	2781                	sext.w	a5,a5
    80002160:	079e                	slli	a5,a5,0x7
    80002162:	97ca                	add	a5,a5,s2
    80002164:	0947a983          	lw	s3,148(a5)
    80002168:	8792                	mv	a5,tp
    swtch(&p->context, &mycpu()->context);
    8000216a:	2781                	sext.w	a5,a5
    8000216c:	079e                	slli	a5,a5,0x7
    8000216e:	00010597          	auipc	a1,0x10
    80002172:	80258593          	addi	a1,a1,-2046 # 80011970 <cpus+0x8>
    80002176:	95be                	add	a1,a1,a5
    80002178:	06048513          	addi	a0,s1,96
    8000217c:	00000097          	auipc	ra,0x0
    80002180:	5b8080e7          	jalr	1464(ra) # 80002734 <swtch>
    80002184:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002186:	2781                	sext.w	a5,a5
    80002188:	079e                	slli	a5,a5,0x7
    8000218a:	97ca                	add	a5,a5,s2
    8000218c:	0937aa23          	sw	s3,148(a5)
}
    80002190:	70a2                	ld	ra,40(sp)
    80002192:	7402                	ld	s0,32(sp)
    80002194:	64e2                	ld	s1,24(sp)
    80002196:	6942                	ld	s2,16(sp)
    80002198:	69a2                	ld	s3,8(sp)
    8000219a:	6145                	addi	sp,sp,48
    8000219c:	8082                	ret
        panic("sched p->lock");
    8000219e:	00006517          	auipc	a0,0x6
    800021a2:	09250513          	addi	a0,a0,146 # 80008230 <digits+0x1f0>
    800021a6:	ffffe097          	auipc	ra,0xffffe
    800021aa:	3a2080e7          	jalr	930(ra) # 80000548 <panic>
        panic("sched locks");
    800021ae:	00006517          	auipc	a0,0x6
    800021b2:	09250513          	addi	a0,a0,146 # 80008240 <digits+0x200>
    800021b6:	ffffe097          	auipc	ra,0xffffe
    800021ba:	392080e7          	jalr	914(ra) # 80000548 <panic>
        panic("sched running");
    800021be:	00006517          	auipc	a0,0x6
    800021c2:	09250513          	addi	a0,a0,146 # 80008250 <digits+0x210>
    800021c6:	ffffe097          	auipc	ra,0xffffe
    800021ca:	382080e7          	jalr	898(ra) # 80000548 <panic>
        panic("sched interruptible");
    800021ce:	00006517          	auipc	a0,0x6
    800021d2:	09250513          	addi	a0,a0,146 # 80008260 <digits+0x220>
    800021d6:	ffffe097          	auipc	ra,0xffffe
    800021da:	372080e7          	jalr	882(ra) # 80000548 <panic>

00000000800021de <exit>:
{
    800021de:	7179                	addi	sp,sp,-48
    800021e0:	f406                	sd	ra,40(sp)
    800021e2:	f022                	sd	s0,32(sp)
    800021e4:	ec26                	sd	s1,24(sp)
    800021e6:	e84a                	sd	s2,16(sp)
    800021e8:	e44e                	sd	s3,8(sp)
    800021ea:	e052                	sd	s4,0(sp)
    800021ec:	1800                	addi	s0,sp,48
    800021ee:	8a2a                	mv	s4,a0
    struct proc* p = myproc();
    800021f0:	00000097          	auipc	ra,0x0
    800021f4:	920080e7          	jalr	-1760(ra) # 80001b10 <myproc>
    800021f8:	89aa                	mv	s3,a0
    if (p == initproc)
    800021fa:	00007797          	auipc	a5,0x7
    800021fe:	e1e7b783          	ld	a5,-482(a5) # 80009018 <initproc>
    80002202:	0d050493          	addi	s1,a0,208
    80002206:	15050913          	addi	s2,a0,336
    8000220a:	02a79363          	bne	a5,a0,80002230 <exit+0x52>
        panic("init exiting");
    8000220e:	00006517          	auipc	a0,0x6
    80002212:	06a50513          	addi	a0,a0,106 # 80008278 <digits+0x238>
    80002216:	ffffe097          	auipc	ra,0xffffe
    8000221a:	332080e7          	jalr	818(ra) # 80000548 <panic>
            fileclose(f);
    8000221e:	00002097          	auipc	ra,0x2
    80002222:	4d4080e7          	jalr	1236(ra) # 800046f2 <fileclose>
            p->ofile[fd] = 0;
    80002226:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    8000222a:	04a1                	addi	s1,s1,8
    8000222c:	01248563          	beq	s1,s2,80002236 <exit+0x58>
        if (p->ofile[fd])
    80002230:	6088                	ld	a0,0(s1)
    80002232:	f575                	bnez	a0,8000221e <exit+0x40>
    80002234:	bfdd                	j	8000222a <exit+0x4c>
    begin_op();
    80002236:	00002097          	auipc	ra,0x2
    8000223a:	fea080e7          	jalr	-22(ra) # 80004220 <begin_op>
    iput(p->cwd);
    8000223e:	1509b503          	ld	a0,336(s3)
    80002242:	00001097          	auipc	ra,0x1
    80002246:	7dc080e7          	jalr	2012(ra) # 80003a1e <iput>
    end_op();
    8000224a:	00002097          	auipc	ra,0x2
    8000224e:	056080e7          	jalr	86(ra) # 800042a0 <end_op>
    p->cwd = 0;
    80002252:	1409b823          	sd	zero,336(s3)
    acquire(&initproc->lock);
    80002256:	00007497          	auipc	s1,0x7
    8000225a:	dc248493          	addi	s1,s1,-574 # 80009018 <initproc>
    8000225e:	6088                	ld	a0,0(s1)
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	9fa080e7          	jalr	-1542(ra) # 80000c5a <acquire>
    wakeup1(initproc);
    80002268:	6088                	ld	a0,0(s1)
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	766080e7          	jalr	1894(ra) # 800019d0 <wakeup1>
    release(&initproc->lock);
    80002272:	6088                	ld	a0,0(s1)
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	a9a080e7          	jalr	-1382(ra) # 80000d0e <release>
    acquire(&p->lock);
    8000227c:	854e                	mv	a0,s3
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	9dc080e7          	jalr	-1572(ra) # 80000c5a <acquire>
    struct proc* original_parent = p->parent;
    80002286:	0209b483          	ld	s1,32(s3)
    release(&p->lock);
    8000228a:	854e                	mv	a0,s3
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	a82080e7          	jalr	-1406(ra) # 80000d0e <release>
    acquire(&original_parent->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	9c4080e7          	jalr	-1596(ra) # 80000c5a <acquire>
    acquire(&p->lock);
    8000229e:	854e                	mv	a0,s3
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	9ba080e7          	jalr	-1606(ra) # 80000c5a <acquire>
    reparent(p);
    800022a8:	854e                	mv	a0,s3
    800022aa:	00000097          	auipc	ra,0x0
    800022ae:	d38080e7          	jalr	-712(ra) # 80001fe2 <reparent>
    wakeup1(original_parent);
    800022b2:	8526                	mv	a0,s1
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	71c080e7          	jalr	1820(ra) # 800019d0 <wakeup1>
    p->xstate = status;
    800022bc:	0349aa23          	sw	s4,52(s3)
    p->state = ZOMBIE;
    800022c0:	4791                	li	a5,4
    800022c2:	00f9ac23          	sw	a5,24(s3)
    release(&original_parent->lock);
    800022c6:	8526                	mv	a0,s1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	a46080e7          	jalr	-1466(ra) # 80000d0e <release>
    sched();
    800022d0:	00000097          	auipc	ra,0x0
    800022d4:	e38080e7          	jalr	-456(ra) # 80002108 <sched>
    panic("zombie exit");
    800022d8:	00006517          	auipc	a0,0x6
    800022dc:	fb050513          	addi	a0,a0,-80 # 80008288 <digits+0x248>
    800022e0:	ffffe097          	auipc	ra,0xffffe
    800022e4:	268080e7          	jalr	616(ra) # 80000548 <panic>

00000000800022e8 <yield>:
{
    800022e8:	1101                	addi	sp,sp,-32
    800022ea:	ec06                	sd	ra,24(sp)
    800022ec:	e822                	sd	s0,16(sp)
    800022ee:	e426                	sd	s1,8(sp)
    800022f0:	1000                	addi	s0,sp,32
    struct proc* p = myproc();
    800022f2:	00000097          	auipc	ra,0x0
    800022f6:	81e080e7          	jalr	-2018(ra) # 80001b10 <myproc>
    800022fa:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	95e080e7          	jalr	-1698(ra) # 80000c5a <acquire>
    p->state = RUNNABLE;
    80002304:	4789                	li	a5,2
    80002306:	cc9c                	sw	a5,24(s1)
    sched();
    80002308:	00000097          	auipc	ra,0x0
    8000230c:	e00080e7          	jalr	-512(ra) # 80002108 <sched>
    release(&p->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	9fc080e7          	jalr	-1540(ra) # 80000d0e <release>
}
    8000231a:	60e2                	ld	ra,24(sp)
    8000231c:	6442                	ld	s0,16(sp)
    8000231e:	64a2                	ld	s1,8(sp)
    80002320:	6105                	addi	sp,sp,32
    80002322:	8082                	ret

0000000080002324 <sleep>:
{
    80002324:	7179                	addi	sp,sp,-48
    80002326:	f406                	sd	ra,40(sp)
    80002328:	f022                	sd	s0,32(sp)
    8000232a:	ec26                	sd	s1,24(sp)
    8000232c:	e84a                	sd	s2,16(sp)
    8000232e:	e44e                	sd	s3,8(sp)
    80002330:	1800                	addi	s0,sp,48
    80002332:	89aa                	mv	s3,a0
    80002334:	892e                	mv	s2,a1
    struct proc* p = myproc();
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	7da080e7          	jalr	2010(ra) # 80001b10 <myproc>
    8000233e:	84aa                	mv	s1,a0
    if (lk != &p->lock)
    80002340:	05250663          	beq	a0,s2,8000238c <sleep+0x68>
        acquire(&p->lock); //DOC: sleeplock1
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	916080e7          	jalr	-1770(ra) # 80000c5a <acquire>
        release(lk);
    8000234c:	854a                	mv	a0,s2
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	9c0080e7          	jalr	-1600(ra) # 80000d0e <release>
    p->chan = chan;
    80002356:	0334b423          	sd	s3,40(s1)
    p->state = SLEEPING;
    8000235a:	4785                	li	a5,1
    8000235c:	cc9c                	sw	a5,24(s1)
    sched();
    8000235e:	00000097          	auipc	ra,0x0
    80002362:	daa080e7          	jalr	-598(ra) # 80002108 <sched>
    p->chan = 0;
    80002366:	0204b423          	sd	zero,40(s1)
        release(&p->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	9a2080e7          	jalr	-1630(ra) # 80000d0e <release>
        acquire(lk);
    80002374:	854a                	mv	a0,s2
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	8e4080e7          	jalr	-1820(ra) # 80000c5a <acquire>
}
    8000237e:	70a2                	ld	ra,40(sp)
    80002380:	7402                	ld	s0,32(sp)
    80002382:	64e2                	ld	s1,24(sp)
    80002384:	6942                	ld	s2,16(sp)
    80002386:	69a2                	ld	s3,8(sp)
    80002388:	6145                	addi	sp,sp,48
    8000238a:	8082                	ret
    p->chan = chan;
    8000238c:	03353423          	sd	s3,40(a0)
    p->state = SLEEPING;
    80002390:	4785                	li	a5,1
    80002392:	cd1c                	sw	a5,24(a0)
    sched();
    80002394:	00000097          	auipc	ra,0x0
    80002398:	d74080e7          	jalr	-652(ra) # 80002108 <sched>
    p->chan = 0;
    8000239c:	0204b423          	sd	zero,40(s1)
    if (lk != &p->lock)
    800023a0:	bff9                	j	8000237e <sleep+0x5a>

00000000800023a2 <wait>:
{
    800023a2:	715d                	addi	sp,sp,-80
    800023a4:	e486                	sd	ra,72(sp)
    800023a6:	e0a2                	sd	s0,64(sp)
    800023a8:	fc26                	sd	s1,56(sp)
    800023aa:	f84a                	sd	s2,48(sp)
    800023ac:	f44e                	sd	s3,40(sp)
    800023ae:	f052                	sd	s4,32(sp)
    800023b0:	ec56                	sd	s5,24(sp)
    800023b2:	e85a                	sd	s6,16(sp)
    800023b4:	e45e                	sd	s7,8(sp)
    800023b6:	e062                	sd	s8,0(sp)
    800023b8:	0880                	addi	s0,sp,80
    800023ba:	8b2a                	mv	s6,a0
    struct proc* p = myproc();
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	754080e7          	jalr	1876(ra) # 80001b10 <myproc>
    800023c4:	892a                	mv	s2,a0
    acquire(&p->lock);
    800023c6:	8c2a                	mv	s8,a0
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	892080e7          	jalr	-1902(ra) # 80000c5a <acquire>
        havekids = 0;
    800023d0:	4b81                	li	s7,0
                if (np->state == ZOMBIE)
    800023d2:	4a11                	li	s4,4
        for (np = proc; np < &proc[NPROC]; np++)
    800023d4:	00015997          	auipc	s3,0x15
    800023d8:	59498993          	addi	s3,s3,1428 # 80017968 <tickslock>
                havekids = 1;
    800023dc:	4a85                	li	s5,1
        havekids = 0;
    800023de:	875e                	mv	a4,s7
        for (np = proc; np < &proc[NPROC]; np++)
    800023e0:	00010497          	auipc	s1,0x10
    800023e4:	98848493          	addi	s1,s1,-1656 # 80011d68 <proc>
    800023e8:	a08d                	j	8000244a <wait+0xa8>
                    pid = np->pid;
    800023ea:	0384a983          	lw	s3,56(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char*)&np->xstate, sizeof(np->xstate)) < 0)
    800023ee:	000b0e63          	beqz	s6,8000240a <wait+0x68>
    800023f2:	4691                	li	a3,4
    800023f4:	03448613          	addi	a2,s1,52
    800023f8:	85da                	mv	a1,s6
    800023fa:	05093503          	ld	a0,80(s2)
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	31e080e7          	jalr	798(ra) # 8000171c <copyout>
    80002406:	02054263          	bltz	a0,8000242a <wait+0x88>
                    freeproc(np);
    8000240a:	8526                	mv	a0,s1
    8000240c:	00000097          	auipc	ra,0x0
    80002410:	8b6080e7          	jalr	-1866(ra) # 80001cc2 <freeproc>
                    release(&np->lock);
    80002414:	8526                	mv	a0,s1
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	8f8080e7          	jalr	-1800(ra) # 80000d0e <release>
                    release(&p->lock);
    8000241e:	854a                	mv	a0,s2
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	8ee080e7          	jalr	-1810(ra) # 80000d0e <release>
                    return pid;
    80002428:	a8a9                	j	80002482 <wait+0xe0>
                        release(&np->lock);
    8000242a:	8526                	mv	a0,s1
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	8e2080e7          	jalr	-1822(ra) # 80000d0e <release>
                        release(&p->lock);
    80002434:	854a                	mv	a0,s2
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	8d8080e7          	jalr	-1832(ra) # 80000d0e <release>
                        return -1;
    8000243e:	59fd                	li	s3,-1
    80002440:	a089                	j	80002482 <wait+0xe0>
        for (np = proc; np < &proc[NPROC]; np++)
    80002442:	17048493          	addi	s1,s1,368
    80002446:	03348463          	beq	s1,s3,8000246e <wait+0xcc>
            if (np->parent == p)
    8000244a:	709c                	ld	a5,32(s1)
    8000244c:	ff279be3          	bne	a5,s2,80002442 <wait+0xa0>
                acquire(&np->lock);
    80002450:	8526                	mv	a0,s1
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	808080e7          	jalr	-2040(ra) # 80000c5a <acquire>
                if (np->state == ZOMBIE)
    8000245a:	4c9c                	lw	a5,24(s1)
    8000245c:	f94787e3          	beq	a5,s4,800023ea <wait+0x48>
                release(&np->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	8ac080e7          	jalr	-1876(ra) # 80000d0e <release>
                havekids = 1;
    8000246a:	8756                	mv	a4,s5
    8000246c:	bfd9                	j	80002442 <wait+0xa0>
        if (!havekids || p->killed)
    8000246e:	c701                	beqz	a4,80002476 <wait+0xd4>
    80002470:	03092783          	lw	a5,48(s2)
    80002474:	c785                	beqz	a5,8000249c <wait+0xfa>
            release(&p->lock);
    80002476:	854a                	mv	a0,s2
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	896080e7          	jalr	-1898(ra) # 80000d0e <release>
            return -1;
    80002480:	59fd                	li	s3,-1
}
    80002482:	854e                	mv	a0,s3
    80002484:	60a6                	ld	ra,72(sp)
    80002486:	6406                	ld	s0,64(sp)
    80002488:	74e2                	ld	s1,56(sp)
    8000248a:	7942                	ld	s2,48(sp)
    8000248c:	79a2                	ld	s3,40(sp)
    8000248e:	7a02                	ld	s4,32(sp)
    80002490:	6ae2                	ld	s5,24(sp)
    80002492:	6b42                	ld	s6,16(sp)
    80002494:	6ba2                	ld	s7,8(sp)
    80002496:	6c02                	ld	s8,0(sp)
    80002498:	6161                	addi	sp,sp,80
    8000249a:	8082                	ret
        sleep(p, &p->lock); //DOC: wait-sleep
    8000249c:	85e2                	mv	a1,s8
    8000249e:	854a                	mv	a0,s2
    800024a0:	00000097          	auipc	ra,0x0
    800024a4:	e84080e7          	jalr	-380(ra) # 80002324 <sleep>
        havekids = 0;
    800024a8:	bf1d                	j	800023de <wait+0x3c>

00000000800024aa <wakeup>:
{
    800024aa:	7139                	addi	sp,sp,-64
    800024ac:	fc06                	sd	ra,56(sp)
    800024ae:	f822                	sd	s0,48(sp)
    800024b0:	f426                	sd	s1,40(sp)
    800024b2:	f04a                	sd	s2,32(sp)
    800024b4:	ec4e                	sd	s3,24(sp)
    800024b6:	e852                	sd	s4,16(sp)
    800024b8:	e456                	sd	s5,8(sp)
    800024ba:	0080                	addi	s0,sp,64
    800024bc:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    800024be:	00010497          	auipc	s1,0x10
    800024c2:	8aa48493          	addi	s1,s1,-1878 # 80011d68 <proc>
        if (p->state == SLEEPING && p->chan == chan)
    800024c6:	4985                	li	s3,1
            p->state = RUNNABLE;
    800024c8:	4a89                	li	s5,2
    for (p = proc; p < &proc[NPROC]; p++)
    800024ca:	00015917          	auipc	s2,0x15
    800024ce:	49e90913          	addi	s2,s2,1182 # 80017968 <tickslock>
    800024d2:	a821                	j	800024ea <wakeup+0x40>
            p->state = RUNNABLE;
    800024d4:	0154ac23          	sw	s5,24(s1)
        release(&p->lock);
    800024d8:	8526                	mv	a0,s1
    800024da:	fffff097          	auipc	ra,0xfffff
    800024de:	834080e7          	jalr	-1996(ra) # 80000d0e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800024e2:	17048493          	addi	s1,s1,368
    800024e6:	01248e63          	beq	s1,s2,80002502 <wakeup+0x58>
        acquire(&p->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	76e080e7          	jalr	1902(ra) # 80000c5a <acquire>
        if (p->state == SLEEPING && p->chan == chan)
    800024f4:	4c9c                	lw	a5,24(s1)
    800024f6:	ff3791e3          	bne	a5,s3,800024d8 <wakeup+0x2e>
    800024fa:	749c                	ld	a5,40(s1)
    800024fc:	fd479ee3          	bne	a5,s4,800024d8 <wakeup+0x2e>
    80002500:	bfd1                	j	800024d4 <wakeup+0x2a>
}
    80002502:	70e2                	ld	ra,56(sp)
    80002504:	7442                	ld	s0,48(sp)
    80002506:	74a2                	ld	s1,40(sp)
    80002508:	7902                	ld	s2,32(sp)
    8000250a:	69e2                	ld	s3,24(sp)
    8000250c:	6a42                	ld	s4,16(sp)
    8000250e:	6aa2                	ld	s5,8(sp)
    80002510:	6121                	addi	sp,sp,64
    80002512:	8082                	ret

0000000080002514 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002514:	7179                	addi	sp,sp,-48
    80002516:	f406                	sd	ra,40(sp)
    80002518:	f022                	sd	s0,32(sp)
    8000251a:	ec26                	sd	s1,24(sp)
    8000251c:	e84a                	sd	s2,16(sp)
    8000251e:	e44e                	sd	s3,8(sp)
    80002520:	1800                	addi	s0,sp,48
    80002522:	892a                	mv	s2,a0
    struct proc* p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002524:	00010497          	auipc	s1,0x10
    80002528:	84448493          	addi	s1,s1,-1980 # 80011d68 <proc>
    8000252c:	00015997          	auipc	s3,0x15
    80002530:	43c98993          	addi	s3,s3,1084 # 80017968 <tickslock>
    {
        acquire(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	724080e7          	jalr	1828(ra) # 80000c5a <acquire>
        if (p->pid == pid)
    8000253e:	5c9c                	lw	a5,56(s1)
    80002540:	01278d63          	beq	a5,s2,8000255a <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002544:	8526                	mv	a0,s1
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	7c8080e7          	jalr	1992(ra) # 80000d0e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000254e:	17048493          	addi	s1,s1,368
    80002552:	ff3491e3          	bne	s1,s3,80002534 <kill+0x20>
    }
    return -1;
    80002556:	557d                	li	a0,-1
    80002558:	a829                	j	80002572 <kill+0x5e>
            p->killed = 1;
    8000255a:	4785                	li	a5,1
    8000255c:	d89c                	sw	a5,48(s1)
            if (p->state == SLEEPING)
    8000255e:	4c98                	lw	a4,24(s1)
    80002560:	4785                	li	a5,1
    80002562:	00f70f63          	beq	a4,a5,80002580 <kill+0x6c>
            release(&p->lock);
    80002566:	8526                	mv	a0,s1
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	7a6080e7          	jalr	1958(ra) # 80000d0e <release>
            return 0;
    80002570:	4501                	li	a0,0
}
    80002572:	70a2                	ld	ra,40(sp)
    80002574:	7402                	ld	s0,32(sp)
    80002576:	64e2                	ld	s1,24(sp)
    80002578:	6942                	ld	s2,16(sp)
    8000257a:	69a2                	ld	s3,8(sp)
    8000257c:	6145                	addi	sp,sp,48
    8000257e:	8082                	ret
                p->state = RUNNABLE;
    80002580:	4789                	li	a5,2
    80002582:	cc9c                	sw	a5,24(s1)
    80002584:	b7cd                	j	80002566 <kill+0x52>

0000000080002586 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void* src, uint64 len)
{
    80002586:	7179                	addi	sp,sp,-48
    80002588:	f406                	sd	ra,40(sp)
    8000258a:	f022                	sd	s0,32(sp)
    8000258c:	ec26                	sd	s1,24(sp)
    8000258e:	e84a                	sd	s2,16(sp)
    80002590:	e44e                	sd	s3,8(sp)
    80002592:	e052                	sd	s4,0(sp)
    80002594:	1800                	addi	s0,sp,48
    80002596:	84aa                	mv	s1,a0
    80002598:	892e                	mv	s2,a1
    8000259a:	89b2                	mv	s3,a2
    8000259c:	8a36                	mv	s4,a3
    struct proc* p = myproc();
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	572080e7          	jalr	1394(ra) # 80001b10 <myproc>
    if (user_dst)
    800025a6:	c08d                	beqz	s1,800025c8 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    800025a8:	86d2                	mv	a3,s4
    800025aa:	864e                	mv	a2,s3
    800025ac:	85ca                	mv	a1,s2
    800025ae:	6928                	ld	a0,80(a0)
    800025b0:	fffff097          	auipc	ra,0xfffff
    800025b4:	16c080e7          	jalr	364(ra) # 8000171c <copyout>
    else
    {
        memmove((char*)dst, src, len);
        return 0;
    }
}
    800025b8:	70a2                	ld	ra,40(sp)
    800025ba:	7402                	ld	s0,32(sp)
    800025bc:	64e2                	ld	s1,24(sp)
    800025be:	6942                	ld	s2,16(sp)
    800025c0:	69a2                	ld	s3,8(sp)
    800025c2:	6a02                	ld	s4,0(sp)
    800025c4:	6145                	addi	sp,sp,48
    800025c6:	8082                	ret
        memmove((char*)dst, src, len);
    800025c8:	000a061b          	sext.w	a2,s4
    800025cc:	85ce                	mv	a1,s3
    800025ce:	854a                	mv	a0,s2
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	7e6080e7          	jalr	2022(ra) # 80000db6 <memmove>
        return 0;
    800025d8:	8526                	mv	a0,s1
    800025da:	bff9                	j	800025b8 <either_copyout+0x32>

00000000800025dc <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void* dst, int user_src, uint64 src, uint64 len)
{
    800025dc:	7179                	addi	sp,sp,-48
    800025de:	f406                	sd	ra,40(sp)
    800025e0:	f022                	sd	s0,32(sp)
    800025e2:	ec26                	sd	s1,24(sp)
    800025e4:	e84a                	sd	s2,16(sp)
    800025e6:	e44e                	sd	s3,8(sp)
    800025e8:	e052                	sd	s4,0(sp)
    800025ea:	1800                	addi	s0,sp,48
    800025ec:	892a                	mv	s2,a0
    800025ee:	84ae                	mv	s1,a1
    800025f0:	89b2                	mv	s3,a2
    800025f2:	8a36                	mv	s4,a3
    struct proc* p = myproc();
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	51c080e7          	jalr	1308(ra) # 80001b10 <myproc>
    if (user_src)
    800025fc:	c08d                	beqz	s1,8000261e <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    800025fe:	86d2                	mv	a3,s4
    80002600:	864e                	mv	a2,s3
    80002602:	85ca                	mv	a1,s2
    80002604:	6928                	ld	a0,80(a0)
    80002606:	fffff097          	auipc	ra,0xfffff
    8000260a:	1a2080e7          	jalr	418(ra) # 800017a8 <copyin>
    else
    {
        memmove(dst, (char*)src, len);
        return 0;
    }
}
    8000260e:	70a2                	ld	ra,40(sp)
    80002610:	7402                	ld	s0,32(sp)
    80002612:	64e2                	ld	s1,24(sp)
    80002614:	6942                	ld	s2,16(sp)
    80002616:	69a2                	ld	s3,8(sp)
    80002618:	6a02                	ld	s4,0(sp)
    8000261a:	6145                	addi	sp,sp,48
    8000261c:	8082                	ret
        memmove(dst, (char*)src, len);
    8000261e:	000a061b          	sext.w	a2,s4
    80002622:	85ce                	mv	a1,s3
    80002624:	854a                	mv	a0,s2
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	790080e7          	jalr	1936(ra) # 80000db6 <memmove>
        return 0;
    8000262e:	8526                	mv	a0,s1
    80002630:	bff9                	j	8000260e <either_copyin+0x32>

0000000080002632 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002632:	715d                	addi	sp,sp,-80
    80002634:	e486                	sd	ra,72(sp)
    80002636:	e0a2                	sd	s0,64(sp)
    80002638:	fc26                	sd	s1,56(sp)
    8000263a:	f84a                	sd	s2,48(sp)
    8000263c:	f44e                	sd	s3,40(sp)
    8000263e:	f052                	sd	s4,32(sp)
    80002640:	ec56                	sd	s5,24(sp)
    80002642:	e85a                	sd	s6,16(sp)
    80002644:	e45e                	sd	s7,8(sp)
    80002646:	0880                	addi	s0,sp,80
        [ZOMBIE] "zombie"
    };
    struct proc* p;
    char* state;

    printf("\n");
    80002648:	00006517          	auipc	a0,0x6
    8000264c:	a8050513          	addi	a0,a0,-1408 # 800080c8 <digits+0x88>
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	f42080e7          	jalr	-190(ra) # 80000592 <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002658:	00010497          	auipc	s1,0x10
    8000265c:	86848493          	addi	s1,s1,-1944 # 80011ec0 <proc+0x158>
    80002660:	00015917          	auipc	s2,0x15
    80002664:	46090913          	addi	s2,s2,1120 # 80017ac0 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002668:	4b11                	li	s6,4
            state = states[p->state];
        else
            state = "???";
    8000266a:	00006997          	auipc	s3,0x6
    8000266e:	c2e98993          	addi	s3,s3,-978 # 80008298 <digits+0x258>
        printf("%d %s %s", p->pid, state, p->name);
    80002672:	00006a97          	auipc	s5,0x6
    80002676:	c2ea8a93          	addi	s5,s5,-978 # 800082a0 <digits+0x260>
        printf("\n");
    8000267a:	00006a17          	auipc	s4,0x6
    8000267e:	a4ea0a13          	addi	s4,s4,-1458 # 800080c8 <digits+0x88>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002682:	00006b97          	auipc	s7,0x6
    80002686:	c56b8b93          	addi	s7,s7,-938 # 800082d8 <states.1717>
    8000268a:	a00d                	j	800026ac <procdump+0x7a>
        printf("%d %s %s", p->pid, state, p->name);
    8000268c:	ee06a583          	lw	a1,-288(a3)
    80002690:	8556                	mv	a0,s5
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	f00080e7          	jalr	-256(ra) # 80000592 <printf>
        printf("\n");
    8000269a:	8552                	mv	a0,s4
    8000269c:	ffffe097          	auipc	ra,0xffffe
    800026a0:	ef6080e7          	jalr	-266(ra) # 80000592 <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800026a4:	17048493          	addi	s1,s1,368
    800026a8:	03248163          	beq	s1,s2,800026ca <procdump+0x98>
        if (p->state == UNUSED)
    800026ac:	86a6                	mv	a3,s1
    800026ae:	ec04a783          	lw	a5,-320(s1)
    800026b2:	dbed                	beqz	a5,800026a4 <procdump+0x72>
            state = "???";
    800026b4:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b6:	fcfb6be3          	bltu	s6,a5,8000268c <procdump+0x5a>
    800026ba:	1782                	slli	a5,a5,0x20
    800026bc:	9381                	srli	a5,a5,0x20
    800026be:	078e                	slli	a5,a5,0x3
    800026c0:	97de                	add	a5,a5,s7
    800026c2:	6390                	ld	a2,0(a5)
    800026c4:	f661                	bnez	a2,8000268c <procdump+0x5a>
            state = "???";
    800026c6:	864e                	mv	a2,s3
    800026c8:	b7d1                	j	8000268c <procdump+0x5a>
    }
}
    800026ca:	60a6                	ld	ra,72(sp)
    800026cc:	6406                	ld	s0,64(sp)
    800026ce:	74e2                	ld	s1,56(sp)
    800026d0:	7942                	ld	s2,48(sp)
    800026d2:	79a2                	ld	s3,40(sp)
    800026d4:	7a02                	ld	s4,32(sp)
    800026d6:	6ae2                	ld	s5,24(sp)
    800026d8:	6b42                	ld	s6,16(sp)
    800026da:	6ba2                	ld	s7,8(sp)
    800026dc:	6161                	addi	sp,sp,80
    800026de:	8082                	ret

00000000800026e0 <count_unused_proc>:
 * @Param:
 * @Param:
 * @Return:
*/
uint64 count_unused_proc()
{
    800026e0:	7179                	addi	sp,sp,-48
    800026e2:	f406                	sd	ra,40(sp)
    800026e4:	f022                	sd	s0,32(sp)
    800026e6:	ec26                	sd	s1,24(sp)
    800026e8:	e84a                	sd	s2,16(sp)
    800026ea:	e44e                	sd	s3,8(sp)
    800026ec:	1800                	addi	s0,sp,48
    uint64 num = 0;
    struct proc* p;
    for (p = proc; p < &proc[NPROC]; p++)
    800026ee:	0000f497          	auipc	s1,0xf
    800026f2:	67a48493          	addi	s1,s1,1658 # 80011d68 <proc>
    uint64 num = 0;
    800026f6:	4901                	li	s2,0
    for (p = proc; p < &proc[NPROC]; p++)
    800026f8:	00015997          	auipc	s3,0x15
    800026fc:	27098993          	addi	s3,s3,624 # 80017968 <tickslock>
    {
        acquire(&p->lock); // just a read lock here
    80002700:	8526                	mv	a0,s1
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	558080e7          	jalr	1368(ra) # 80000c5a <acquire>
        if (p->state != UNUSED)
    8000270a:	4c9c                	lw	a5,24(s1)
        {
            num = num + 1;
    8000270c:	00f037b3          	snez	a5,a5
    80002710:	993e                	add	s2,s2,a5
        }
        release(&p->lock);
    80002712:	8526                	mv	a0,s1
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	5fa080e7          	jalr	1530(ra) # 80000d0e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000271c:	17048493          	addi	s1,s1,368
    80002720:	ff3490e3          	bne	s1,s3,80002700 <count_unused_proc+0x20>
    }
    return num;
    80002724:	854a                	mv	a0,s2
    80002726:	70a2                	ld	ra,40(sp)
    80002728:	7402                	ld	s0,32(sp)
    8000272a:	64e2                	ld	s1,24(sp)
    8000272c:	6942                	ld	s2,16(sp)
    8000272e:	69a2                	ld	s3,8(sp)
    80002730:	6145                	addi	sp,sp,48
    80002732:	8082                	ret

0000000080002734 <swtch>:
    80002734:	00153023          	sd	ra,0(a0)
    80002738:	00253423          	sd	sp,8(a0)
    8000273c:	e900                	sd	s0,16(a0)
    8000273e:	ed04                	sd	s1,24(a0)
    80002740:	03253023          	sd	s2,32(a0)
    80002744:	03353423          	sd	s3,40(a0)
    80002748:	03453823          	sd	s4,48(a0)
    8000274c:	03553c23          	sd	s5,56(a0)
    80002750:	05653023          	sd	s6,64(a0)
    80002754:	05753423          	sd	s7,72(a0)
    80002758:	05853823          	sd	s8,80(a0)
    8000275c:	05953c23          	sd	s9,88(a0)
    80002760:	07a53023          	sd	s10,96(a0)
    80002764:	07b53423          	sd	s11,104(a0)
    80002768:	0005b083          	ld	ra,0(a1)
    8000276c:	0085b103          	ld	sp,8(a1)
    80002770:	6980                	ld	s0,16(a1)
    80002772:	6d84                	ld	s1,24(a1)
    80002774:	0205b903          	ld	s2,32(a1)
    80002778:	0285b983          	ld	s3,40(a1)
    8000277c:	0305ba03          	ld	s4,48(a1)
    80002780:	0385ba83          	ld	s5,56(a1)
    80002784:	0405bb03          	ld	s6,64(a1)
    80002788:	0485bb83          	ld	s7,72(a1)
    8000278c:	0505bc03          	ld	s8,80(a1)
    80002790:	0585bc83          	ld	s9,88(a1)
    80002794:	0605bd03          	ld	s10,96(a1)
    80002798:	0685bd83          	ld	s11,104(a1)
    8000279c:	8082                	ret

000000008000279e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000279e:	1141                	addi	sp,sp,-16
    800027a0:	e406                	sd	ra,8(sp)
    800027a2:	e022                	sd	s0,0(sp)
    800027a4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800027a6:	00006597          	auipc	a1,0x6
    800027aa:	b5a58593          	addi	a1,a1,-1190 # 80008300 <states.1717+0x28>
    800027ae:	00015517          	auipc	a0,0x15
    800027b2:	1ba50513          	addi	a0,a0,442 # 80017968 <tickslock>
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	414080e7          	jalr	1044(ra) # 80000bca <initlock>
}
    800027be:	60a2                	ld	ra,8(sp)
    800027c0:	6402                	ld	s0,0(sp)
    800027c2:	0141                	addi	sp,sp,16
    800027c4:	8082                	ret

00000000800027c6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800027c6:	1141                	addi	sp,sp,-16
    800027c8:	e422                	sd	s0,8(sp)
    800027ca:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027cc:	00003797          	auipc	a5,0x3
    800027d0:	5b478793          	addi	a5,a5,1460 # 80005d80 <kernelvec>
    800027d4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027d8:	6422                	ld	s0,8(sp)
    800027da:	0141                	addi	sp,sp,16
    800027dc:	8082                	ret

00000000800027de <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027de:	1141                	addi	sp,sp,-16
    800027e0:	e406                	sd	ra,8(sp)
    800027e2:	e022                	sd	s0,0(sp)
    800027e4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027e6:	fffff097          	auipc	ra,0xfffff
    800027ea:	32a080e7          	jalr	810(ra) # 80001b10 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027f4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800027f8:	00005617          	auipc	a2,0x5
    800027fc:	80860613          	addi	a2,a2,-2040 # 80007000 <_trampoline>
    80002800:	00005697          	auipc	a3,0x5
    80002804:	80068693          	addi	a3,a3,-2048 # 80007000 <_trampoline>
    80002808:	8e91                	sub	a3,a3,a2
    8000280a:	040007b7          	lui	a5,0x4000
    8000280e:	17fd                	addi	a5,a5,-1
    80002810:	07b2                	slli	a5,a5,0xc
    80002812:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002814:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002818:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000281a:	180026f3          	csrr	a3,satp
    8000281e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002820:	6d38                	ld	a4,88(a0)
    80002822:	6134                	ld	a3,64(a0)
    80002824:	6585                	lui	a1,0x1
    80002826:	96ae                	add	a3,a3,a1
    80002828:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000282a:	6d38                	ld	a4,88(a0)
    8000282c:	00000697          	auipc	a3,0x0
    80002830:	13868693          	addi	a3,a3,312 # 80002964 <usertrap>
    80002834:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002836:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002838:	8692                	mv	a3,tp
    8000283a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000283c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002840:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002844:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002848:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000284c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000284e:	6f18                	ld	a4,24(a4)
    80002850:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002854:	692c                	ld	a1,80(a0)
    80002856:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002858:	00005717          	auipc	a4,0x5
    8000285c:	83870713          	addi	a4,a4,-1992 # 80007090 <userret>
    80002860:	8f11                	sub	a4,a4,a2
    80002862:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002864:	577d                	li	a4,-1
    80002866:	177e                	slli	a4,a4,0x3f
    80002868:	8dd9                	or	a1,a1,a4
    8000286a:	02000537          	lui	a0,0x2000
    8000286e:	157d                	addi	a0,a0,-1
    80002870:	0536                	slli	a0,a0,0xd
    80002872:	9782                	jalr	a5
}
    80002874:	60a2                	ld	ra,8(sp)
    80002876:	6402                	ld	s0,0(sp)
    80002878:	0141                	addi	sp,sp,16
    8000287a:	8082                	ret

000000008000287c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000287c:	1101                	addi	sp,sp,-32
    8000287e:	ec06                	sd	ra,24(sp)
    80002880:	e822                	sd	s0,16(sp)
    80002882:	e426                	sd	s1,8(sp)
    80002884:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002886:	00015497          	auipc	s1,0x15
    8000288a:	0e248493          	addi	s1,s1,226 # 80017968 <tickslock>
    8000288e:	8526                	mv	a0,s1
    80002890:	ffffe097          	auipc	ra,0xffffe
    80002894:	3ca080e7          	jalr	970(ra) # 80000c5a <acquire>
  ticks++;
    80002898:	00006517          	auipc	a0,0x6
    8000289c:	78850513          	addi	a0,a0,1928 # 80009020 <ticks>
    800028a0:	411c                	lw	a5,0(a0)
    800028a2:	2785                	addiw	a5,a5,1
    800028a4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800028a6:	00000097          	auipc	ra,0x0
    800028aa:	c04080e7          	jalr	-1020(ra) # 800024aa <wakeup>
  release(&tickslock);
    800028ae:	8526                	mv	a0,s1
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	45e080e7          	jalr	1118(ra) # 80000d0e <release>
}
    800028b8:	60e2                	ld	ra,24(sp)
    800028ba:	6442                	ld	s0,16(sp)
    800028bc:	64a2                	ld	s1,8(sp)
    800028be:	6105                	addi	sp,sp,32
    800028c0:	8082                	ret

00000000800028c2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800028c2:	1101                	addi	sp,sp,-32
    800028c4:	ec06                	sd	ra,24(sp)
    800028c6:	e822                	sd	s0,16(sp)
    800028c8:	e426                	sd	s1,8(sp)
    800028ca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028cc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800028d0:	00074d63          	bltz	a4,800028ea <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800028d4:	57fd                	li	a5,-1
    800028d6:	17fe                	slli	a5,a5,0x3f
    800028d8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800028da:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028dc:	06f70363          	beq	a4,a5,80002942 <devintr+0x80>
  }
}
    800028e0:	60e2                	ld	ra,24(sp)
    800028e2:	6442                	ld	s0,16(sp)
    800028e4:	64a2                	ld	s1,8(sp)
    800028e6:	6105                	addi	sp,sp,32
    800028e8:	8082                	ret
     (scause & 0xff) == 9){
    800028ea:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800028ee:	46a5                	li	a3,9
    800028f0:	fed792e3          	bne	a5,a3,800028d4 <devintr+0x12>
    int irq = plic_claim();
    800028f4:	00003097          	auipc	ra,0x3
    800028f8:	594080e7          	jalr	1428(ra) # 80005e88 <plic_claim>
    800028fc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028fe:	47a9                	li	a5,10
    80002900:	02f50763          	beq	a0,a5,8000292e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002904:	4785                	li	a5,1
    80002906:	02f50963          	beq	a0,a5,80002938 <devintr+0x76>
    return 1;
    8000290a:	4505                	li	a0,1
    } else if(irq){
    8000290c:	d8f1                	beqz	s1,800028e0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000290e:	85a6                	mv	a1,s1
    80002910:	00006517          	auipc	a0,0x6
    80002914:	9f850513          	addi	a0,a0,-1544 # 80008308 <states.1717+0x30>
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	c7a080e7          	jalr	-902(ra) # 80000592 <printf>
      plic_complete(irq);
    80002920:	8526                	mv	a0,s1
    80002922:	00003097          	auipc	ra,0x3
    80002926:	58a080e7          	jalr	1418(ra) # 80005eac <plic_complete>
    return 1;
    8000292a:	4505                	li	a0,1
    8000292c:	bf55                	j	800028e0 <devintr+0x1e>
      uartintr();
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	0a6080e7          	jalr	166(ra) # 800009d4 <uartintr>
    80002936:	b7ed                	j	80002920 <devintr+0x5e>
      virtio_disk_intr();
    80002938:	00004097          	auipc	ra,0x4
    8000293c:	a0e080e7          	jalr	-1522(ra) # 80006346 <virtio_disk_intr>
    80002940:	b7c5                	j	80002920 <devintr+0x5e>
    if(cpuid() == 0){
    80002942:	fffff097          	auipc	ra,0xfffff
    80002946:	1a2080e7          	jalr	418(ra) # 80001ae4 <cpuid>
    8000294a:	c901                	beqz	a0,8000295a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000294c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002950:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002952:	14479073          	csrw	sip,a5
    return 2;
    80002956:	4509                	li	a0,2
    80002958:	b761                	j	800028e0 <devintr+0x1e>
      clockintr();
    8000295a:	00000097          	auipc	ra,0x0
    8000295e:	f22080e7          	jalr	-222(ra) # 8000287c <clockintr>
    80002962:	b7ed                	j	8000294c <devintr+0x8a>

0000000080002964 <usertrap>:
{
    80002964:	1101                	addi	sp,sp,-32
    80002966:	ec06                	sd	ra,24(sp)
    80002968:	e822                	sd	s0,16(sp)
    8000296a:	e426                	sd	s1,8(sp)
    8000296c:	e04a                	sd	s2,0(sp)
    8000296e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002970:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002974:	1007f793          	andi	a5,a5,256
    80002978:	e3ad                	bnez	a5,800029da <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000297a:	00003797          	auipc	a5,0x3
    8000297e:	40678793          	addi	a5,a5,1030 # 80005d80 <kernelvec>
    80002982:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002986:	fffff097          	auipc	ra,0xfffff
    8000298a:	18a080e7          	jalr	394(ra) # 80001b10 <myproc>
    8000298e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002990:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002992:	14102773          	csrr	a4,sepc
    80002996:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002998:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000299c:	47a1                	li	a5,8
    8000299e:	04f71c63          	bne	a4,a5,800029f6 <usertrap+0x92>
    if(p->killed)
    800029a2:	591c                	lw	a5,48(a0)
    800029a4:	e3b9                	bnez	a5,800029ea <usertrap+0x86>
    p->trapframe->epc += 4;
    800029a6:	6cb8                	ld	a4,88(s1)
    800029a8:	6f1c                	ld	a5,24(a4)
    800029aa:	0791                	addi	a5,a5,4
    800029ac:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029b2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029b6:	10079073          	csrw	sstatus,a5
    syscall();
    800029ba:	00000097          	auipc	ra,0x0
    800029be:	2e0080e7          	jalr	736(ra) # 80002c9a <syscall>
  if(p->killed)
    800029c2:	589c                	lw	a5,48(s1)
    800029c4:	ebc1                	bnez	a5,80002a54 <usertrap+0xf0>
  usertrapret();
    800029c6:	00000097          	auipc	ra,0x0
    800029ca:	e18080e7          	jalr	-488(ra) # 800027de <usertrapret>
}
    800029ce:	60e2                	ld	ra,24(sp)
    800029d0:	6442                	ld	s0,16(sp)
    800029d2:	64a2                	ld	s1,8(sp)
    800029d4:	6902                	ld	s2,0(sp)
    800029d6:	6105                	addi	sp,sp,32
    800029d8:	8082                	ret
    panic("usertrap: not from user mode");
    800029da:	00006517          	auipc	a0,0x6
    800029de:	94e50513          	addi	a0,a0,-1714 # 80008328 <states.1717+0x50>
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	b66080e7          	jalr	-1178(ra) # 80000548 <panic>
      exit(-1);
    800029ea:	557d                	li	a0,-1
    800029ec:	fffff097          	auipc	ra,0xfffff
    800029f0:	7f2080e7          	jalr	2034(ra) # 800021de <exit>
    800029f4:	bf4d                	j	800029a6 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800029f6:	00000097          	auipc	ra,0x0
    800029fa:	ecc080e7          	jalr	-308(ra) # 800028c2 <devintr>
    800029fe:	892a                	mv	s2,a0
    80002a00:	c501                	beqz	a0,80002a08 <usertrap+0xa4>
  if(p->killed)
    80002a02:	589c                	lw	a5,48(s1)
    80002a04:	c3a1                	beqz	a5,80002a44 <usertrap+0xe0>
    80002a06:	a815                	j	80002a3a <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a08:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a0c:	5c90                	lw	a2,56(s1)
    80002a0e:	00006517          	auipc	a0,0x6
    80002a12:	93a50513          	addi	a0,a0,-1734 # 80008348 <states.1717+0x70>
    80002a16:	ffffe097          	auipc	ra,0xffffe
    80002a1a:	b7c080e7          	jalr	-1156(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a1e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a22:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a26:	00006517          	auipc	a0,0x6
    80002a2a:	95250513          	addi	a0,a0,-1710 # 80008378 <states.1717+0xa0>
    80002a2e:	ffffe097          	auipc	ra,0xffffe
    80002a32:	b64080e7          	jalr	-1180(ra) # 80000592 <printf>
    p->killed = 1;
    80002a36:	4785                	li	a5,1
    80002a38:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002a3a:	557d                	li	a0,-1
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	7a2080e7          	jalr	1954(ra) # 800021de <exit>
  if(which_dev == 2)
    80002a44:	4789                	li	a5,2
    80002a46:	f8f910e3          	bne	s2,a5,800029c6 <usertrap+0x62>
    yield();
    80002a4a:	00000097          	auipc	ra,0x0
    80002a4e:	89e080e7          	jalr	-1890(ra) # 800022e8 <yield>
    80002a52:	bf95                	j	800029c6 <usertrap+0x62>
  int which_dev = 0;
    80002a54:	4901                	li	s2,0
    80002a56:	b7d5                	j	80002a3a <usertrap+0xd6>

0000000080002a58 <kerneltrap>:
{
    80002a58:	7179                	addi	sp,sp,-48
    80002a5a:	f406                	sd	ra,40(sp)
    80002a5c:	f022                	sd	s0,32(sp)
    80002a5e:	ec26                	sd	s1,24(sp)
    80002a60:	e84a                	sd	s2,16(sp)
    80002a62:	e44e                	sd	s3,8(sp)
    80002a64:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a66:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a6a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a6e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a72:	1004f793          	andi	a5,s1,256
    80002a76:	cb85                	beqz	a5,80002aa6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a7c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a7e:	ef85                	bnez	a5,80002ab6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a80:	00000097          	auipc	ra,0x0
    80002a84:	e42080e7          	jalr	-446(ra) # 800028c2 <devintr>
    80002a88:	cd1d                	beqz	a0,80002ac6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a8a:	4789                	li	a5,2
    80002a8c:	06f50a63          	beq	a0,a5,80002b00 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a90:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a94:	10049073          	csrw	sstatus,s1
}
    80002a98:	70a2                	ld	ra,40(sp)
    80002a9a:	7402                	ld	s0,32(sp)
    80002a9c:	64e2                	ld	s1,24(sp)
    80002a9e:	6942                	ld	s2,16(sp)
    80002aa0:	69a2                	ld	s3,8(sp)
    80002aa2:	6145                	addi	sp,sp,48
    80002aa4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002aa6:	00006517          	auipc	a0,0x6
    80002aaa:	8f250513          	addi	a0,a0,-1806 # 80008398 <states.1717+0xc0>
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	a9a080e7          	jalr	-1382(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ab6:	00006517          	auipc	a0,0x6
    80002aba:	90a50513          	addi	a0,a0,-1782 # 800083c0 <states.1717+0xe8>
    80002abe:	ffffe097          	auipc	ra,0xffffe
    80002ac2:	a8a080e7          	jalr	-1398(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002ac6:	85ce                	mv	a1,s3
    80002ac8:	00006517          	auipc	a0,0x6
    80002acc:	91850513          	addi	a0,a0,-1768 # 800083e0 <states.1717+0x108>
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	ac2080e7          	jalr	-1342(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002adc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ae0:	00006517          	auipc	a0,0x6
    80002ae4:	91050513          	addi	a0,a0,-1776 # 800083f0 <states.1717+0x118>
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	aaa080e7          	jalr	-1366(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002af0:	00006517          	auipc	a0,0x6
    80002af4:	91850513          	addi	a0,a0,-1768 # 80008408 <states.1717+0x130>
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	a50080e7          	jalr	-1456(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	010080e7          	jalr	16(ra) # 80001b10 <myproc>
    80002b08:	d541                	beqz	a0,80002a90 <kerneltrap+0x38>
    80002b0a:	fffff097          	auipc	ra,0xfffff
    80002b0e:	006080e7          	jalr	6(ra) # 80001b10 <myproc>
    80002b12:	4d18                	lw	a4,24(a0)
    80002b14:	478d                	li	a5,3
    80002b16:	f6f71de3          	bne	a4,a5,80002a90 <kerneltrap+0x38>
    yield();
    80002b1a:	fffff097          	auipc	ra,0xfffff
    80002b1e:	7ce080e7          	jalr	1998(ra) # 800022e8 <yield>
    80002b22:	b7bd                	j	80002a90 <kerneltrap+0x38>

0000000080002b24 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b24:	1101                	addi	sp,sp,-32
    80002b26:	ec06                	sd	ra,24(sp)
    80002b28:	e822                	sd	s0,16(sp)
    80002b2a:	e426                	sd	s1,8(sp)
    80002b2c:	1000                	addi	s0,sp,32
    80002b2e:	84aa                	mv	s1,a0
    struct proc* p = myproc();
    80002b30:	fffff097          	auipc	ra,0xfffff
    80002b34:	fe0080e7          	jalr	-32(ra) # 80001b10 <myproc>
    switch (n)
    80002b38:	4795                	li	a5,5
    80002b3a:	0497e163          	bltu	a5,s1,80002b7c <argraw+0x58>
    80002b3e:	048a                	slli	s1,s1,0x2
    80002b40:	00006717          	auipc	a4,0x6
    80002b44:	9c870713          	addi	a4,a4,-1592 # 80008508 <states.1717+0x230>
    80002b48:	94ba                	add	s1,s1,a4
    80002b4a:	409c                	lw	a5,0(s1)
    80002b4c:	97ba                	add	a5,a5,a4
    80002b4e:	8782                	jr	a5
    {
        case 0:
            return p->trapframe->a0;
    80002b50:	6d3c                	ld	a5,88(a0)
    80002b52:	7ba8                	ld	a0,112(a5)
        case 5:
            return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002b54:	60e2                	ld	ra,24(sp)
    80002b56:	6442                	ld	s0,16(sp)
    80002b58:	64a2                	ld	s1,8(sp)
    80002b5a:	6105                	addi	sp,sp,32
    80002b5c:	8082                	ret
            return p->trapframe->a1;
    80002b5e:	6d3c                	ld	a5,88(a0)
    80002b60:	7fa8                	ld	a0,120(a5)
    80002b62:	bfcd                	j	80002b54 <argraw+0x30>
            return p->trapframe->a2;
    80002b64:	6d3c                	ld	a5,88(a0)
    80002b66:	63c8                	ld	a0,128(a5)
    80002b68:	b7f5                	j	80002b54 <argraw+0x30>
            return p->trapframe->a3;
    80002b6a:	6d3c                	ld	a5,88(a0)
    80002b6c:	67c8                	ld	a0,136(a5)
    80002b6e:	b7dd                	j	80002b54 <argraw+0x30>
            return p->trapframe->a4;
    80002b70:	6d3c                	ld	a5,88(a0)
    80002b72:	6bc8                	ld	a0,144(a5)
    80002b74:	b7c5                	j	80002b54 <argraw+0x30>
            return p->trapframe->a5;
    80002b76:	6d3c                	ld	a5,88(a0)
    80002b78:	6fc8                	ld	a0,152(a5)
    80002b7a:	bfe9                	j	80002b54 <argraw+0x30>
    panic("argraw");
    80002b7c:	00006517          	auipc	a0,0x6
    80002b80:	89c50513          	addi	a0,a0,-1892 # 80008418 <states.1717+0x140>
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	9c4080e7          	jalr	-1596(ra) # 80000548 <panic>

0000000080002b8c <fetchaddr>:
{
    80002b8c:	1101                	addi	sp,sp,-32
    80002b8e:	ec06                	sd	ra,24(sp)
    80002b90:	e822                	sd	s0,16(sp)
    80002b92:	e426                	sd	s1,8(sp)
    80002b94:	e04a                	sd	s2,0(sp)
    80002b96:	1000                	addi	s0,sp,32
    80002b98:	84aa                	mv	s1,a0
    80002b9a:	892e                	mv	s2,a1
    struct proc* p = myproc();
    80002b9c:	fffff097          	auipc	ra,0xfffff
    80002ba0:	f74080e7          	jalr	-140(ra) # 80001b10 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz)
    80002ba4:	653c                	ld	a5,72(a0)
    80002ba6:	02f4f863          	bgeu	s1,a5,80002bd6 <fetchaddr+0x4a>
    80002baa:	00848713          	addi	a4,s1,8
    80002bae:	02e7e663          	bltu	a5,a4,80002bda <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char*)ip, addr, sizeof(*ip)) != 0)
    80002bb2:	46a1                	li	a3,8
    80002bb4:	8626                	mv	a2,s1
    80002bb6:	85ca                	mv	a1,s2
    80002bb8:	6928                	ld	a0,80(a0)
    80002bba:	fffff097          	auipc	ra,0xfffff
    80002bbe:	bee080e7          	jalr	-1042(ra) # 800017a8 <copyin>
    80002bc2:	00a03533          	snez	a0,a0
    80002bc6:	40a00533          	neg	a0,a0
}
    80002bca:	60e2                	ld	ra,24(sp)
    80002bcc:	6442                	ld	s0,16(sp)
    80002bce:	64a2                	ld	s1,8(sp)
    80002bd0:	6902                	ld	s2,0(sp)
    80002bd2:	6105                	addi	sp,sp,32
    80002bd4:	8082                	ret
        return -1;
    80002bd6:	557d                	li	a0,-1
    80002bd8:	bfcd                	j	80002bca <fetchaddr+0x3e>
    80002bda:	557d                	li	a0,-1
    80002bdc:	b7fd                	j	80002bca <fetchaddr+0x3e>

0000000080002bde <fetchstr>:
{
    80002bde:	7179                	addi	sp,sp,-48
    80002be0:	f406                	sd	ra,40(sp)
    80002be2:	f022                	sd	s0,32(sp)
    80002be4:	ec26                	sd	s1,24(sp)
    80002be6:	e84a                	sd	s2,16(sp)
    80002be8:	e44e                	sd	s3,8(sp)
    80002bea:	1800                	addi	s0,sp,48
    80002bec:	892a                	mv	s2,a0
    80002bee:	84ae                	mv	s1,a1
    80002bf0:	89b2                	mv	s3,a2
    struct proc* p = myproc();
    80002bf2:	fffff097          	auipc	ra,0xfffff
    80002bf6:	f1e080e7          	jalr	-226(ra) # 80001b10 <myproc>
    int err = copyinstr(p->pagetable, buf, addr, max);
    80002bfa:	86ce                	mv	a3,s3
    80002bfc:	864a                	mv	a2,s2
    80002bfe:	85a6                	mv	a1,s1
    80002c00:	6928                	ld	a0,80(a0)
    80002c02:	fffff097          	auipc	ra,0xfffff
    80002c06:	c32080e7          	jalr	-974(ra) # 80001834 <copyinstr>
    if (err < 0)
    80002c0a:	00054763          	bltz	a0,80002c18 <fetchstr+0x3a>
    return strlen(buf);
    80002c0e:	8526                	mv	a0,s1
    80002c10:	ffffe097          	auipc	ra,0xffffe
    80002c14:	2ce080e7          	jalr	718(ra) # 80000ede <strlen>
}
    80002c18:	70a2                	ld	ra,40(sp)
    80002c1a:	7402                	ld	s0,32(sp)
    80002c1c:	64e2                	ld	s1,24(sp)
    80002c1e:	6942                	ld	s2,16(sp)
    80002c20:	69a2                	ld	s3,8(sp)
    80002c22:	6145                	addi	sp,sp,48
    80002c24:	8082                	ret

0000000080002c26 <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int* ip)
{
    80002c26:	1101                	addi	sp,sp,-32
    80002c28:	ec06                	sd	ra,24(sp)
    80002c2a:	e822                	sd	s0,16(sp)
    80002c2c:	e426                	sd	s1,8(sp)
    80002c2e:	1000                	addi	s0,sp,32
    80002c30:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002c32:	00000097          	auipc	ra,0x0
    80002c36:	ef2080e7          	jalr	-270(ra) # 80002b24 <argraw>
    80002c3a:	c088                	sw	a0,0(s1)
    return 0;
}
    80002c3c:	4501                	li	a0,0
    80002c3e:	60e2                	ld	ra,24(sp)
    80002c40:	6442                	ld	s0,16(sp)
    80002c42:	64a2                	ld	s1,8(sp)
    80002c44:	6105                	addi	sp,sp,32
    80002c46:	8082                	ret

0000000080002c48 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int argaddr(int n, uint64* ip)
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	e426                	sd	s1,8(sp)
    80002c50:	1000                	addi	s0,sp,32
    80002c52:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002c54:	00000097          	auipc	ra,0x0
    80002c58:	ed0080e7          	jalr	-304(ra) # 80002b24 <argraw>
    80002c5c:	e088                	sd	a0,0(s1)
    return 0;
}
    80002c5e:	4501                	li	a0,0
    80002c60:	60e2                	ld	ra,24(sp)
    80002c62:	6442                	ld	s0,16(sp)
    80002c64:	64a2                	ld	s1,8(sp)
    80002c66:	6105                	addi	sp,sp,32
    80002c68:	8082                	ret

0000000080002c6a <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char* buf, int max)
{
    80002c6a:	1101                	addi	sp,sp,-32
    80002c6c:	ec06                	sd	ra,24(sp)
    80002c6e:	e822                	sd	s0,16(sp)
    80002c70:	e426                	sd	s1,8(sp)
    80002c72:	e04a                	sd	s2,0(sp)
    80002c74:	1000                	addi	s0,sp,32
    80002c76:	84ae                	mv	s1,a1
    80002c78:	8932                	mv	s2,a2
    *ip = argraw(n);
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	eaa080e7          	jalr	-342(ra) # 80002b24 <argraw>
    uint64 addr;
    if (argaddr(n, &addr) < 0)
        return -1;
    return fetchstr(addr, buf, max);
    80002c82:	864a                	mv	a2,s2
    80002c84:	85a6                	mv	a1,s1
    80002c86:	00000097          	auipc	ra,0x0
    80002c8a:	f58080e7          	jalr	-168(ra) # 80002bde <fetchstr>
}
    80002c8e:	60e2                	ld	ra,24(sp)
    80002c90:	6442                	ld	s0,16(sp)
    80002c92:	64a2                	ld	s1,8(sp)
    80002c94:	6902                	ld	s2,0(sp)
    80002c96:	6105                	addi	sp,sp,32
    80002c98:	8082                	ret

0000000080002c9a <syscall>:
    [SYS_trace] "trace",
    [SYS_sysinfo] "sysinfo",
};

void syscall(void)
{
    80002c9a:	7179                	addi	sp,sp,-48
    80002c9c:	f406                	sd	ra,40(sp)
    80002c9e:	f022                	sd	s0,32(sp)
    80002ca0:	ec26                	sd	s1,24(sp)
    80002ca2:	e84a                	sd	s2,16(sp)
    80002ca4:	e44e                	sd	s3,8(sp)
    80002ca6:	1800                	addi	s0,sp,48
    int num;
    struct proc* p = myproc();
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	e68080e7          	jalr	-408(ra) # 80001b10 <myproc>
    80002cb0:	84aa                	mv	s1,a0

    num = p->trapframe->a7; // get the syscall number
    80002cb2:	05853903          	ld	s2,88(a0)
    80002cb6:	0a893783          	ld	a5,168(s2)
    80002cba:	0007899b          	sext.w	s3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002cbe:	37fd                	addiw	a5,a5,-1
    80002cc0:	4759                	li	a4,22
    80002cc2:	04f76863          	bltu	a4,a5,80002d12 <syscall+0x78>
    80002cc6:	00399713          	slli	a4,s3,0x3
    80002cca:	00006797          	auipc	a5,0x6
    80002cce:	85678793          	addi	a5,a5,-1962 # 80008520 <syscalls>
    80002cd2:	97ba                	add	a5,a5,a4
    80002cd4:	639c                	ld	a5,0(a5)
    80002cd6:	cf95                	beqz	a5,80002d12 <syscall+0x78>
    {
        p->trapframe->a0 = syscalls[num]();
    80002cd8:	9782                	jalr	a5
    80002cda:	06a93823          	sd	a0,112(s2)
        if ((p->syscall_mask >> num) & 1)
    80002cde:	1684a783          	lw	a5,360(s1)
    80002ce2:	4137d7bb          	sraw	a5,a5,s3
    80002ce6:	8b85                	andi	a5,a5,1
    80002ce8:	c7a1                	beqz	a5,80002d30 <syscall+0x96>
        {
            printf("%d: syscall %s -> %d\n", p->pid, syscallname[num], p->trapframe->a0);
    80002cea:	6cb8                	ld	a4,88(s1)
    80002cec:	098e                	slli	s3,s3,0x3
    80002cee:	00006797          	auipc	a5,0x6
    80002cf2:	c6a78793          	addi	a5,a5,-918 # 80008958 <syscallname>
    80002cf6:	99be                	add	s3,s3,a5
    80002cf8:	7b34                	ld	a3,112(a4)
    80002cfa:	0009b603          	ld	a2,0(s3)
    80002cfe:	5c8c                	lw	a1,56(s1)
    80002d00:	00005517          	auipc	a0,0x5
    80002d04:	72050513          	addi	a0,a0,1824 # 80008420 <states.1717+0x148>
    80002d08:	ffffe097          	auipc	ra,0xffffe
    80002d0c:	88a080e7          	jalr	-1910(ra) # 80000592 <printf>
    80002d10:	a005                	j	80002d30 <syscall+0x96>
        }
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80002d12:	86ce                	mv	a3,s3
    80002d14:	15848613          	addi	a2,s1,344
    80002d18:	5c8c                	lw	a1,56(s1)
    80002d1a:	00005517          	auipc	a0,0x5
    80002d1e:	71e50513          	addi	a0,a0,1822 # 80008438 <states.1717+0x160>
    80002d22:	ffffe097          	auipc	ra,0xffffe
    80002d26:	870080e7          	jalr	-1936(ra) # 80000592 <printf>
            p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80002d2a:	6cbc                	ld	a5,88(s1)
    80002d2c:	577d                	li	a4,-1
    80002d2e:	fbb8                	sd	a4,112(a5)
    }
}
    80002d30:	70a2                	ld	ra,40(sp)
    80002d32:	7402                	ld	s0,32(sp)
    80002d34:	64e2                	ld	s1,24(sp)
    80002d36:	6942                	ld	s2,16(sp)
    80002d38:	69a2                	ld	s3,8(sp)
    80002d3a:	6145                	addi	sp,sp,48
    80002d3c:	8082                	ret

0000000080002d3e <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    80002d3e:	1101                	addi	sp,sp,-32
    80002d40:	ec06                	sd	ra,24(sp)
    80002d42:	e822                	sd	s0,16(sp)
    80002d44:	1000                	addi	s0,sp,32
    int n;
    if (argint(0, &n) < 0)
    80002d46:	fec40593          	addi	a1,s0,-20
    80002d4a:	4501                	li	a0,0
    80002d4c:	00000097          	auipc	ra,0x0
    80002d50:	eda080e7          	jalr	-294(ra) # 80002c26 <argint>
        return -1;
    80002d54:	57fd                	li	a5,-1
    if (argint(0, &n) < 0)
    80002d56:	00054963          	bltz	a0,80002d68 <sys_exit+0x2a>
    exit(n);
    80002d5a:	fec42503          	lw	a0,-20(s0)
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	480080e7          	jalr	1152(ra) # 800021de <exit>
    return 0; // not reached
    80002d66:	4781                	li	a5,0
}
    80002d68:	853e                	mv	a0,a5
    80002d6a:	60e2                	ld	ra,24(sp)
    80002d6c:	6442                	ld	s0,16(sp)
    80002d6e:	6105                	addi	sp,sp,32
    80002d70:	8082                	ret

0000000080002d72 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d72:	1141                	addi	sp,sp,-16
    80002d74:	e406                	sd	ra,8(sp)
    80002d76:	e022                	sd	s0,0(sp)
    80002d78:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80002d7a:	fffff097          	auipc	ra,0xfffff
    80002d7e:	d96080e7          	jalr	-618(ra) # 80001b10 <myproc>
}
    80002d82:	5d08                	lw	a0,56(a0)
    80002d84:	60a2                	ld	ra,8(sp)
    80002d86:	6402                	ld	s0,0(sp)
    80002d88:	0141                	addi	sp,sp,16
    80002d8a:	8082                	ret

0000000080002d8c <sys_fork>:

uint64
sys_fork(void)
{
    80002d8c:	1141                	addi	sp,sp,-16
    80002d8e:	e406                	sd	ra,8(sp)
    80002d90:	e022                	sd	s0,0(sp)
    80002d92:	0800                	addi	s0,sp,16
    return fork();
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	13c080e7          	jalr	316(ra) # 80001ed0 <fork>
}
    80002d9c:	60a2                	ld	ra,8(sp)
    80002d9e:	6402                	ld	s0,0(sp)
    80002da0:	0141                	addi	sp,sp,16
    80002da2:	8082                	ret

0000000080002da4 <sys_wait>:

uint64
sys_wait(void)
{
    80002da4:	1101                	addi	sp,sp,-32
    80002da6:	ec06                	sd	ra,24(sp)
    80002da8:	e822                	sd	s0,16(sp)
    80002daa:	1000                	addi	s0,sp,32
    uint64 p;
    if (argaddr(0, &p) < 0)
    80002dac:	fe840593          	addi	a1,s0,-24
    80002db0:	4501                	li	a0,0
    80002db2:	00000097          	auipc	ra,0x0
    80002db6:	e96080e7          	jalr	-362(ra) # 80002c48 <argaddr>
    80002dba:	87aa                	mv	a5,a0
        return -1;
    80002dbc:	557d                	li	a0,-1
    if (argaddr(0, &p) < 0)
    80002dbe:	0007c863          	bltz	a5,80002dce <sys_wait+0x2a>
    return wait(p);
    80002dc2:	fe843503          	ld	a0,-24(s0)
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	5dc080e7          	jalr	1500(ra) # 800023a2 <wait>
}
    80002dce:	60e2                	ld	ra,24(sp)
    80002dd0:	6442                	ld	s0,16(sp)
    80002dd2:	6105                	addi	sp,sp,32
    80002dd4:	8082                	ret

0000000080002dd6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002dd6:	7179                	addi	sp,sp,-48
    80002dd8:	f406                	sd	ra,40(sp)
    80002dda:	f022                	sd	s0,32(sp)
    80002ddc:	ec26                	sd	s1,24(sp)
    80002dde:	1800                	addi	s0,sp,48
    int addr;
    int n;

    if (argint(0, &n) < 0)
    80002de0:	fdc40593          	addi	a1,s0,-36
    80002de4:	4501                	li	a0,0
    80002de6:	00000097          	auipc	ra,0x0
    80002dea:	e40080e7          	jalr	-448(ra) # 80002c26 <argint>
    80002dee:	87aa                	mv	a5,a0
        return -1;
    80002df0:	557d                	li	a0,-1
    if (argint(0, &n) < 0)
    80002df2:	0207c063          	bltz	a5,80002e12 <sys_sbrk+0x3c>
    addr = myproc()->sz;
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	d1a080e7          	jalr	-742(ra) # 80001b10 <myproc>
    80002dfe:	4524                	lw	s1,72(a0)
    if (growproc(n) < 0)
    80002e00:	fdc42503          	lw	a0,-36(s0)
    80002e04:	fffff097          	auipc	ra,0xfffff
    80002e08:	058080e7          	jalr	88(ra) # 80001e5c <growproc>
    80002e0c:	00054863          	bltz	a0,80002e1c <sys_sbrk+0x46>
        return -1;
    return addr;
    80002e10:	8526                	mv	a0,s1
}
    80002e12:	70a2                	ld	ra,40(sp)
    80002e14:	7402                	ld	s0,32(sp)
    80002e16:	64e2                	ld	s1,24(sp)
    80002e18:	6145                	addi	sp,sp,48
    80002e1a:	8082                	ret
        return -1;
    80002e1c:	557d                	li	a0,-1
    80002e1e:	bfd5                	j	80002e12 <sys_sbrk+0x3c>

0000000080002e20 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e20:	7139                	addi	sp,sp,-64
    80002e22:	fc06                	sd	ra,56(sp)
    80002e24:	f822                	sd	s0,48(sp)
    80002e26:	f426                	sd	s1,40(sp)
    80002e28:	f04a                	sd	s2,32(sp)
    80002e2a:	ec4e                	sd	s3,24(sp)
    80002e2c:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    if (argint(0, &n) < 0)
    80002e2e:	fcc40593          	addi	a1,s0,-52
    80002e32:	4501                	li	a0,0
    80002e34:	00000097          	auipc	ra,0x0
    80002e38:	df2080e7          	jalr	-526(ra) # 80002c26 <argint>
        return -1;
    80002e3c:	57fd                	li	a5,-1
    if (argint(0, &n) < 0)
    80002e3e:	06054563          	bltz	a0,80002ea8 <sys_sleep+0x88>
    acquire(&tickslock);
    80002e42:	00015517          	auipc	a0,0x15
    80002e46:	b2650513          	addi	a0,a0,-1242 # 80017968 <tickslock>
    80002e4a:	ffffe097          	auipc	ra,0xffffe
    80002e4e:	e10080e7          	jalr	-496(ra) # 80000c5a <acquire>
    ticks0 = ticks;
    80002e52:	00006917          	auipc	s2,0x6
    80002e56:	1ce92903          	lw	s2,462(s2) # 80009020 <ticks>
    while (ticks - ticks0 < n)
    80002e5a:	fcc42783          	lw	a5,-52(s0)
    80002e5e:	cf85                	beqz	a5,80002e96 <sys_sleep+0x76>
        if (myproc()->killed)
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    80002e60:	00015997          	auipc	s3,0x15
    80002e64:	b0898993          	addi	s3,s3,-1272 # 80017968 <tickslock>
    80002e68:	00006497          	auipc	s1,0x6
    80002e6c:	1b848493          	addi	s1,s1,440 # 80009020 <ticks>
        if (myproc()->killed)
    80002e70:	fffff097          	auipc	ra,0xfffff
    80002e74:	ca0080e7          	jalr	-864(ra) # 80001b10 <myproc>
    80002e78:	591c                	lw	a5,48(a0)
    80002e7a:	ef9d                	bnez	a5,80002eb8 <sys_sleep+0x98>
        sleep(&ticks, &tickslock);
    80002e7c:	85ce                	mv	a1,s3
    80002e7e:	8526                	mv	a0,s1
    80002e80:	fffff097          	auipc	ra,0xfffff
    80002e84:	4a4080e7          	jalr	1188(ra) # 80002324 <sleep>
    while (ticks - ticks0 < n)
    80002e88:	409c                	lw	a5,0(s1)
    80002e8a:	412787bb          	subw	a5,a5,s2
    80002e8e:	fcc42703          	lw	a4,-52(s0)
    80002e92:	fce7efe3          	bltu	a5,a4,80002e70 <sys_sleep+0x50>
    }
    release(&tickslock);
    80002e96:	00015517          	auipc	a0,0x15
    80002e9a:	ad250513          	addi	a0,a0,-1326 # 80017968 <tickslock>
    80002e9e:	ffffe097          	auipc	ra,0xffffe
    80002ea2:	e70080e7          	jalr	-400(ra) # 80000d0e <release>
    return 0;
    80002ea6:	4781                	li	a5,0
}
    80002ea8:	853e                	mv	a0,a5
    80002eaa:	70e2                	ld	ra,56(sp)
    80002eac:	7442                	ld	s0,48(sp)
    80002eae:	74a2                	ld	s1,40(sp)
    80002eb0:	7902                	ld	s2,32(sp)
    80002eb2:	69e2                	ld	s3,24(sp)
    80002eb4:	6121                	addi	sp,sp,64
    80002eb6:	8082                	ret
            release(&tickslock);
    80002eb8:	00015517          	auipc	a0,0x15
    80002ebc:	ab050513          	addi	a0,a0,-1360 # 80017968 <tickslock>
    80002ec0:	ffffe097          	auipc	ra,0xffffe
    80002ec4:	e4e080e7          	jalr	-434(ra) # 80000d0e <release>
            return -1;
    80002ec8:	57fd                	li	a5,-1
    80002eca:	bff9                	j	80002ea8 <sys_sleep+0x88>

0000000080002ecc <sys_kill>:

uint64
sys_kill(void)
{
    80002ecc:	1101                	addi	sp,sp,-32
    80002ece:	ec06                	sd	ra,24(sp)
    80002ed0:	e822                	sd	s0,16(sp)
    80002ed2:	1000                	addi	s0,sp,32
    int pid;

    if (argint(0, &pid) < 0)
    80002ed4:	fec40593          	addi	a1,s0,-20
    80002ed8:	4501                	li	a0,0
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	d4c080e7          	jalr	-692(ra) # 80002c26 <argint>
    80002ee2:	87aa                	mv	a5,a0
        return -1;
    80002ee4:	557d                	li	a0,-1
    if (argint(0, &pid) < 0)
    80002ee6:	0007c863          	bltz	a5,80002ef6 <sys_kill+0x2a>
    return kill(pid);
    80002eea:	fec42503          	lw	a0,-20(s0)
    80002eee:	fffff097          	auipc	ra,0xfffff
    80002ef2:	626080e7          	jalr	1574(ra) # 80002514 <kill>
}
    80002ef6:	60e2                	ld	ra,24(sp)
    80002ef8:	6442                	ld	s0,16(sp)
    80002efa:	6105                	addi	sp,sp,32
    80002efc:	8082                	ret

0000000080002efe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002efe:	1101                	addi	sp,sp,-32
    80002f00:	ec06                	sd	ra,24(sp)
    80002f02:	e822                	sd	s0,16(sp)
    80002f04:	e426                	sd	s1,8(sp)
    80002f06:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80002f08:	00015517          	auipc	a0,0x15
    80002f0c:	a6050513          	addi	a0,a0,-1440 # 80017968 <tickslock>
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	d4a080e7          	jalr	-694(ra) # 80000c5a <acquire>
    xticks = ticks;
    80002f18:	00006497          	auipc	s1,0x6
    80002f1c:	1084a483          	lw	s1,264(s1) # 80009020 <ticks>
    release(&tickslock);
    80002f20:	00015517          	auipc	a0,0x15
    80002f24:	a4850513          	addi	a0,a0,-1464 # 80017968 <tickslock>
    80002f28:	ffffe097          	auipc	ra,0xffffe
    80002f2c:	de6080e7          	jalr	-538(ra) # 80000d0e <release>
    return xticks;
}
    80002f30:	02049513          	slli	a0,s1,0x20
    80002f34:	9101                	srli	a0,a0,0x20
    80002f36:	60e2                	ld	ra,24(sp)
    80002f38:	6442                	ld	s0,16(sp)
    80002f3a:	64a2                	ld	s1,8(sp)
    80002f3c:	6105                	addi	sp,sp,32
    80002f3e:	8082                	ret

0000000080002f40 <sys_trace>:

uint64
sys_trace(void)
{
    80002f40:	1101                	addi	sp,sp,-32
    80002f42:	ec06                	sd	ra,24(sp)
    80002f44:	e822                	sd	s0,16(sp)
    80002f46:	1000                	addi	s0,sp,32
    int syscall_mask;
    if (argint(0, &syscall_mask) < 0)
    80002f48:	fec40593          	addi	a1,s0,-20
    80002f4c:	4501                	li	a0,0
    80002f4e:	00000097          	auipc	ra,0x0
    80002f52:	cd8080e7          	jalr	-808(ra) # 80002c26 <argint>
    {
        return -1;
    80002f56:	57fd                	li	a5,-1
    if (argint(0, &syscall_mask) < 0)
    80002f58:	00054b63          	bltz	a0,80002f6e <sys_trace+0x2e>
    }
    struct proc* p = myproc();
    80002f5c:	fffff097          	auipc	ra,0xfffff
    80002f60:	bb4080e7          	jalr	-1100(ra) # 80001b10 <myproc>
    p->syscall_mask = syscall_mask;
    80002f64:	fec42783          	lw	a5,-20(s0)
    80002f68:	16f52423          	sw	a5,360(a0)
    return 0;
    80002f6c:	4781                	li	a5,0
}
    80002f6e:	853e                	mv	a0,a5
    80002f70:	60e2                	ld	ra,24(sp)
    80002f72:	6442                	ld	s0,16(sp)
    80002f74:	6105                	addi	sp,sp,32
    80002f76:	8082                	ret

0000000080002f78 <sys_sysinfo>:

uint64
sys_sysinfo(void)
{
    80002f78:	7179                	addi	sp,sp,-48
    80002f7a:	f406                	sd	ra,40(sp)
    80002f7c:	f022                	sd	s0,32(sp)
    80002f7e:	1800                	addi	s0,sp,48
    uint64 u_dst;
    if (argaddr(0, &u_dst) < 0)
    80002f80:	fe840593          	addi	a1,s0,-24
    80002f84:	4501                	li	a0,0
    80002f86:	00000097          	auipc	ra,0x0
    80002f8a:	cc2080e7          	jalr	-830(ra) # 80002c48 <argaddr>
    80002f8e:	87aa                	mv	a5,a0
    {
        return -1;
    80002f90:	557d                	li	a0,-1
    if (argaddr(0, &u_dst) < 0)
    80002f92:	0207cd63          	bltz	a5,80002fcc <sys_sysinfo+0x54>
    }
    struct sysinfo k_src;
    k_src.freemem = count_free_kmem();
    80002f96:	ffffe097          	auipc	ra,0xffffe
    80002f9a:	bea080e7          	jalr	-1046(ra) # 80000b80 <count_free_kmem>
    80002f9e:	fca43c23          	sd	a0,-40(s0)
    k_src.nproc = count_unused_proc();
    80002fa2:	fffff097          	auipc	ra,0xfffff
    80002fa6:	73e080e7          	jalr	1854(ra) # 800026e0 <count_unused_proc>
    80002faa:	fea43023          	sd	a0,-32(s0)
    struct proc* p = myproc();
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	b62080e7          	jalr	-1182(ra) # 80001b10 <myproc>
    if (copyout(p->pagetable, u_dst, (char*)&k_src, sizeof(k_src)) < 0)
    80002fb6:	46c1                	li	a3,16
    80002fb8:	fd840613          	addi	a2,s0,-40
    80002fbc:	fe843583          	ld	a1,-24(s0)
    80002fc0:	6928                	ld	a0,80(a0)
    80002fc2:	ffffe097          	auipc	ra,0xffffe
    80002fc6:	75a080e7          	jalr	1882(ra) # 8000171c <copyout>
    80002fca:	957d                	srai	a0,a0,0x3f
        return -1;
    return 0;
    80002fcc:	70a2                	ld	ra,40(sp)
    80002fce:	7402                	ld	s0,32(sp)
    80002fd0:	6145                	addi	sp,sp,48
    80002fd2:	8082                	ret

0000000080002fd4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fd4:	7179                	addi	sp,sp,-48
    80002fd6:	f406                	sd	ra,40(sp)
    80002fd8:	f022                	sd	s0,32(sp)
    80002fda:	ec26                	sd	s1,24(sp)
    80002fdc:	e84a                	sd	s2,16(sp)
    80002fde:	e44e                	sd	s3,8(sp)
    80002fe0:	e052                	sd	s4,0(sp)
    80002fe2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fe4:	00005597          	auipc	a1,0x5
    80002fe8:	5fc58593          	addi	a1,a1,1532 # 800085e0 <syscalls+0xc0>
    80002fec:	00015517          	auipc	a0,0x15
    80002ff0:	99450513          	addi	a0,a0,-1644 # 80017980 <bcache>
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	bd6080e7          	jalr	-1066(ra) # 80000bca <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ffc:	0001d797          	auipc	a5,0x1d
    80003000:	98478793          	addi	a5,a5,-1660 # 8001f980 <bcache+0x8000>
    80003004:	0001d717          	auipc	a4,0x1d
    80003008:	be470713          	addi	a4,a4,-1052 # 8001fbe8 <bcache+0x8268>
    8000300c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003010:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003014:	00015497          	auipc	s1,0x15
    80003018:	98448493          	addi	s1,s1,-1660 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    8000301c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000301e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003020:	00005a17          	auipc	s4,0x5
    80003024:	5c8a0a13          	addi	s4,s4,1480 # 800085e8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80003028:	2b893783          	ld	a5,696(s2)
    8000302c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000302e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003032:	85d2                	mv	a1,s4
    80003034:	01048513          	addi	a0,s1,16
    80003038:	00001097          	auipc	ra,0x1
    8000303c:	4ac080e7          	jalr	1196(ra) # 800044e4 <initsleeplock>
    bcache.head.next->prev = b;
    80003040:	2b893783          	ld	a5,696(s2)
    80003044:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003046:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000304a:	45848493          	addi	s1,s1,1112
    8000304e:	fd349de3          	bne	s1,s3,80003028 <binit+0x54>
  }
}
    80003052:	70a2                	ld	ra,40(sp)
    80003054:	7402                	ld	s0,32(sp)
    80003056:	64e2                	ld	s1,24(sp)
    80003058:	6942                	ld	s2,16(sp)
    8000305a:	69a2                	ld	s3,8(sp)
    8000305c:	6a02                	ld	s4,0(sp)
    8000305e:	6145                	addi	sp,sp,48
    80003060:	8082                	ret

0000000080003062 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003062:	7179                	addi	sp,sp,-48
    80003064:	f406                	sd	ra,40(sp)
    80003066:	f022                	sd	s0,32(sp)
    80003068:	ec26                	sd	s1,24(sp)
    8000306a:	e84a                	sd	s2,16(sp)
    8000306c:	e44e                	sd	s3,8(sp)
    8000306e:	1800                	addi	s0,sp,48
    80003070:	89aa                	mv	s3,a0
    80003072:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003074:	00015517          	auipc	a0,0x15
    80003078:	90c50513          	addi	a0,a0,-1780 # 80017980 <bcache>
    8000307c:	ffffe097          	auipc	ra,0xffffe
    80003080:	bde080e7          	jalr	-1058(ra) # 80000c5a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003084:	0001d497          	auipc	s1,0x1d
    80003088:	bb44b483          	ld	s1,-1100(s1) # 8001fc38 <bcache+0x82b8>
    8000308c:	0001d797          	auipc	a5,0x1d
    80003090:	b5c78793          	addi	a5,a5,-1188 # 8001fbe8 <bcache+0x8268>
    80003094:	02f48f63          	beq	s1,a5,800030d2 <bread+0x70>
    80003098:	873e                	mv	a4,a5
    8000309a:	a021                	j	800030a2 <bread+0x40>
    8000309c:	68a4                	ld	s1,80(s1)
    8000309e:	02e48a63          	beq	s1,a4,800030d2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030a2:	449c                	lw	a5,8(s1)
    800030a4:	ff379ce3          	bne	a5,s3,8000309c <bread+0x3a>
    800030a8:	44dc                	lw	a5,12(s1)
    800030aa:	ff2799e3          	bne	a5,s2,8000309c <bread+0x3a>
      b->refcnt++;
    800030ae:	40bc                	lw	a5,64(s1)
    800030b0:	2785                	addiw	a5,a5,1
    800030b2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030b4:	00015517          	auipc	a0,0x15
    800030b8:	8cc50513          	addi	a0,a0,-1844 # 80017980 <bcache>
    800030bc:	ffffe097          	auipc	ra,0xffffe
    800030c0:	c52080e7          	jalr	-942(ra) # 80000d0e <release>
      acquiresleep(&b->lock);
    800030c4:	01048513          	addi	a0,s1,16
    800030c8:	00001097          	auipc	ra,0x1
    800030cc:	456080e7          	jalr	1110(ra) # 8000451e <acquiresleep>
      return b;
    800030d0:	a8b9                	j	8000312e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030d2:	0001d497          	auipc	s1,0x1d
    800030d6:	b5e4b483          	ld	s1,-1186(s1) # 8001fc30 <bcache+0x82b0>
    800030da:	0001d797          	auipc	a5,0x1d
    800030de:	b0e78793          	addi	a5,a5,-1266 # 8001fbe8 <bcache+0x8268>
    800030e2:	00f48863          	beq	s1,a5,800030f2 <bread+0x90>
    800030e6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030e8:	40bc                	lw	a5,64(s1)
    800030ea:	cf81                	beqz	a5,80003102 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030ec:	64a4                	ld	s1,72(s1)
    800030ee:	fee49de3          	bne	s1,a4,800030e8 <bread+0x86>
  panic("bget: no buffers");
    800030f2:	00005517          	auipc	a0,0x5
    800030f6:	4fe50513          	addi	a0,a0,1278 # 800085f0 <syscalls+0xd0>
    800030fa:	ffffd097          	auipc	ra,0xffffd
    800030fe:	44e080e7          	jalr	1102(ra) # 80000548 <panic>
      b->dev = dev;
    80003102:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003106:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000310a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000310e:	4785                	li	a5,1
    80003110:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003112:	00015517          	auipc	a0,0x15
    80003116:	86e50513          	addi	a0,a0,-1938 # 80017980 <bcache>
    8000311a:	ffffe097          	auipc	ra,0xffffe
    8000311e:	bf4080e7          	jalr	-1036(ra) # 80000d0e <release>
      acquiresleep(&b->lock);
    80003122:	01048513          	addi	a0,s1,16
    80003126:	00001097          	auipc	ra,0x1
    8000312a:	3f8080e7          	jalr	1016(ra) # 8000451e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000312e:	409c                	lw	a5,0(s1)
    80003130:	cb89                	beqz	a5,80003142 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003132:	8526                	mv	a0,s1
    80003134:	70a2                	ld	ra,40(sp)
    80003136:	7402                	ld	s0,32(sp)
    80003138:	64e2                	ld	s1,24(sp)
    8000313a:	6942                	ld	s2,16(sp)
    8000313c:	69a2                	ld	s3,8(sp)
    8000313e:	6145                	addi	sp,sp,48
    80003140:	8082                	ret
    virtio_disk_rw(b, 0);
    80003142:	4581                	li	a1,0
    80003144:	8526                	mv	a0,s1
    80003146:	00003097          	auipc	ra,0x3
    8000314a:	f56080e7          	jalr	-170(ra) # 8000609c <virtio_disk_rw>
    b->valid = 1;
    8000314e:	4785                	li	a5,1
    80003150:	c09c                	sw	a5,0(s1)
  return b;
    80003152:	b7c5                	j	80003132 <bread+0xd0>

0000000080003154 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003154:	1101                	addi	sp,sp,-32
    80003156:	ec06                	sd	ra,24(sp)
    80003158:	e822                	sd	s0,16(sp)
    8000315a:	e426                	sd	s1,8(sp)
    8000315c:	1000                	addi	s0,sp,32
    8000315e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003160:	0541                	addi	a0,a0,16
    80003162:	00001097          	auipc	ra,0x1
    80003166:	456080e7          	jalr	1110(ra) # 800045b8 <holdingsleep>
    8000316a:	cd01                	beqz	a0,80003182 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000316c:	4585                	li	a1,1
    8000316e:	8526                	mv	a0,s1
    80003170:	00003097          	auipc	ra,0x3
    80003174:	f2c080e7          	jalr	-212(ra) # 8000609c <virtio_disk_rw>
}
    80003178:	60e2                	ld	ra,24(sp)
    8000317a:	6442                	ld	s0,16(sp)
    8000317c:	64a2                	ld	s1,8(sp)
    8000317e:	6105                	addi	sp,sp,32
    80003180:	8082                	ret
    panic("bwrite");
    80003182:	00005517          	auipc	a0,0x5
    80003186:	48650513          	addi	a0,a0,1158 # 80008608 <syscalls+0xe8>
    8000318a:	ffffd097          	auipc	ra,0xffffd
    8000318e:	3be080e7          	jalr	958(ra) # 80000548 <panic>

0000000080003192 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003192:	1101                	addi	sp,sp,-32
    80003194:	ec06                	sd	ra,24(sp)
    80003196:	e822                	sd	s0,16(sp)
    80003198:	e426                	sd	s1,8(sp)
    8000319a:	e04a                	sd	s2,0(sp)
    8000319c:	1000                	addi	s0,sp,32
    8000319e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031a0:	01050913          	addi	s2,a0,16
    800031a4:	854a                	mv	a0,s2
    800031a6:	00001097          	auipc	ra,0x1
    800031aa:	412080e7          	jalr	1042(ra) # 800045b8 <holdingsleep>
    800031ae:	c92d                	beqz	a0,80003220 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800031b0:	854a                	mv	a0,s2
    800031b2:	00001097          	auipc	ra,0x1
    800031b6:	3c2080e7          	jalr	962(ra) # 80004574 <releasesleep>

  acquire(&bcache.lock);
    800031ba:	00014517          	auipc	a0,0x14
    800031be:	7c650513          	addi	a0,a0,1990 # 80017980 <bcache>
    800031c2:	ffffe097          	auipc	ra,0xffffe
    800031c6:	a98080e7          	jalr	-1384(ra) # 80000c5a <acquire>
  b->refcnt--;
    800031ca:	40bc                	lw	a5,64(s1)
    800031cc:	37fd                	addiw	a5,a5,-1
    800031ce:	0007871b          	sext.w	a4,a5
    800031d2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031d4:	eb05                	bnez	a4,80003204 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031d6:	68bc                	ld	a5,80(s1)
    800031d8:	64b8                	ld	a4,72(s1)
    800031da:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031dc:	64bc                	ld	a5,72(s1)
    800031de:	68b8                	ld	a4,80(s1)
    800031e0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031e2:	0001c797          	auipc	a5,0x1c
    800031e6:	79e78793          	addi	a5,a5,1950 # 8001f980 <bcache+0x8000>
    800031ea:	2b87b703          	ld	a4,696(a5)
    800031ee:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031f0:	0001d717          	auipc	a4,0x1d
    800031f4:	9f870713          	addi	a4,a4,-1544 # 8001fbe8 <bcache+0x8268>
    800031f8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031fa:	2b87b703          	ld	a4,696(a5)
    800031fe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003200:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003204:	00014517          	auipc	a0,0x14
    80003208:	77c50513          	addi	a0,a0,1916 # 80017980 <bcache>
    8000320c:	ffffe097          	auipc	ra,0xffffe
    80003210:	b02080e7          	jalr	-1278(ra) # 80000d0e <release>
}
    80003214:	60e2                	ld	ra,24(sp)
    80003216:	6442                	ld	s0,16(sp)
    80003218:	64a2                	ld	s1,8(sp)
    8000321a:	6902                	ld	s2,0(sp)
    8000321c:	6105                	addi	sp,sp,32
    8000321e:	8082                	ret
    panic("brelse");
    80003220:	00005517          	auipc	a0,0x5
    80003224:	3f050513          	addi	a0,a0,1008 # 80008610 <syscalls+0xf0>
    80003228:	ffffd097          	auipc	ra,0xffffd
    8000322c:	320080e7          	jalr	800(ra) # 80000548 <panic>

0000000080003230 <bpin>:

void
bpin(struct buf *b) {
    80003230:	1101                	addi	sp,sp,-32
    80003232:	ec06                	sd	ra,24(sp)
    80003234:	e822                	sd	s0,16(sp)
    80003236:	e426                	sd	s1,8(sp)
    80003238:	1000                	addi	s0,sp,32
    8000323a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000323c:	00014517          	auipc	a0,0x14
    80003240:	74450513          	addi	a0,a0,1860 # 80017980 <bcache>
    80003244:	ffffe097          	auipc	ra,0xffffe
    80003248:	a16080e7          	jalr	-1514(ra) # 80000c5a <acquire>
  b->refcnt++;
    8000324c:	40bc                	lw	a5,64(s1)
    8000324e:	2785                	addiw	a5,a5,1
    80003250:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003252:	00014517          	auipc	a0,0x14
    80003256:	72e50513          	addi	a0,a0,1838 # 80017980 <bcache>
    8000325a:	ffffe097          	auipc	ra,0xffffe
    8000325e:	ab4080e7          	jalr	-1356(ra) # 80000d0e <release>
}
    80003262:	60e2                	ld	ra,24(sp)
    80003264:	6442                	ld	s0,16(sp)
    80003266:	64a2                	ld	s1,8(sp)
    80003268:	6105                	addi	sp,sp,32
    8000326a:	8082                	ret

000000008000326c <bunpin>:

void
bunpin(struct buf *b) {
    8000326c:	1101                	addi	sp,sp,-32
    8000326e:	ec06                	sd	ra,24(sp)
    80003270:	e822                	sd	s0,16(sp)
    80003272:	e426                	sd	s1,8(sp)
    80003274:	1000                	addi	s0,sp,32
    80003276:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003278:	00014517          	auipc	a0,0x14
    8000327c:	70850513          	addi	a0,a0,1800 # 80017980 <bcache>
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	9da080e7          	jalr	-1574(ra) # 80000c5a <acquire>
  b->refcnt--;
    80003288:	40bc                	lw	a5,64(s1)
    8000328a:	37fd                	addiw	a5,a5,-1
    8000328c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000328e:	00014517          	auipc	a0,0x14
    80003292:	6f250513          	addi	a0,a0,1778 # 80017980 <bcache>
    80003296:	ffffe097          	auipc	ra,0xffffe
    8000329a:	a78080e7          	jalr	-1416(ra) # 80000d0e <release>
}
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	64a2                	ld	s1,8(sp)
    800032a4:	6105                	addi	sp,sp,32
    800032a6:	8082                	ret

00000000800032a8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032a8:	1101                	addi	sp,sp,-32
    800032aa:	ec06                	sd	ra,24(sp)
    800032ac:	e822                	sd	s0,16(sp)
    800032ae:	e426                	sd	s1,8(sp)
    800032b0:	e04a                	sd	s2,0(sp)
    800032b2:	1000                	addi	s0,sp,32
    800032b4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032b6:	00d5d59b          	srliw	a1,a1,0xd
    800032ba:	0001d797          	auipc	a5,0x1d
    800032be:	da27a783          	lw	a5,-606(a5) # 8002005c <sb+0x1c>
    800032c2:	9dbd                	addw	a1,a1,a5
    800032c4:	00000097          	auipc	ra,0x0
    800032c8:	d9e080e7          	jalr	-610(ra) # 80003062 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032cc:	0074f713          	andi	a4,s1,7
    800032d0:	4785                	li	a5,1
    800032d2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032d6:	14ce                	slli	s1,s1,0x33
    800032d8:	90d9                	srli	s1,s1,0x36
    800032da:	00950733          	add	a4,a0,s1
    800032de:	05874703          	lbu	a4,88(a4)
    800032e2:	00e7f6b3          	and	a3,a5,a4
    800032e6:	c69d                	beqz	a3,80003314 <bfree+0x6c>
    800032e8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032ea:	94aa                	add	s1,s1,a0
    800032ec:	fff7c793          	not	a5,a5
    800032f0:	8ff9                	and	a5,a5,a4
    800032f2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800032f6:	00001097          	auipc	ra,0x1
    800032fa:	100080e7          	jalr	256(ra) # 800043f6 <log_write>
  brelse(bp);
    800032fe:	854a                	mv	a0,s2
    80003300:	00000097          	auipc	ra,0x0
    80003304:	e92080e7          	jalr	-366(ra) # 80003192 <brelse>
}
    80003308:	60e2                	ld	ra,24(sp)
    8000330a:	6442                	ld	s0,16(sp)
    8000330c:	64a2                	ld	s1,8(sp)
    8000330e:	6902                	ld	s2,0(sp)
    80003310:	6105                	addi	sp,sp,32
    80003312:	8082                	ret
    panic("freeing free block");
    80003314:	00005517          	auipc	a0,0x5
    80003318:	30450513          	addi	a0,a0,772 # 80008618 <syscalls+0xf8>
    8000331c:	ffffd097          	auipc	ra,0xffffd
    80003320:	22c080e7          	jalr	556(ra) # 80000548 <panic>

0000000080003324 <balloc>:
{
    80003324:	711d                	addi	sp,sp,-96
    80003326:	ec86                	sd	ra,88(sp)
    80003328:	e8a2                	sd	s0,80(sp)
    8000332a:	e4a6                	sd	s1,72(sp)
    8000332c:	e0ca                	sd	s2,64(sp)
    8000332e:	fc4e                	sd	s3,56(sp)
    80003330:	f852                	sd	s4,48(sp)
    80003332:	f456                	sd	s5,40(sp)
    80003334:	f05a                	sd	s6,32(sp)
    80003336:	ec5e                	sd	s7,24(sp)
    80003338:	e862                	sd	s8,16(sp)
    8000333a:	e466                	sd	s9,8(sp)
    8000333c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000333e:	0001d797          	auipc	a5,0x1d
    80003342:	d067a783          	lw	a5,-762(a5) # 80020044 <sb+0x4>
    80003346:	cbd1                	beqz	a5,800033da <balloc+0xb6>
    80003348:	8baa                	mv	s7,a0
    8000334a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000334c:	0001db17          	auipc	s6,0x1d
    80003350:	cf4b0b13          	addi	s6,s6,-780 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003354:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003356:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003358:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000335a:	6c89                	lui	s9,0x2
    8000335c:	a831                	j	80003378 <balloc+0x54>
    brelse(bp);
    8000335e:	854a                	mv	a0,s2
    80003360:	00000097          	auipc	ra,0x0
    80003364:	e32080e7          	jalr	-462(ra) # 80003192 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003368:	015c87bb          	addw	a5,s9,s5
    8000336c:	00078a9b          	sext.w	s5,a5
    80003370:	004b2703          	lw	a4,4(s6)
    80003374:	06eaf363          	bgeu	s5,a4,800033da <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003378:	41fad79b          	sraiw	a5,s5,0x1f
    8000337c:	0137d79b          	srliw	a5,a5,0x13
    80003380:	015787bb          	addw	a5,a5,s5
    80003384:	40d7d79b          	sraiw	a5,a5,0xd
    80003388:	01cb2583          	lw	a1,28(s6)
    8000338c:	9dbd                	addw	a1,a1,a5
    8000338e:	855e                	mv	a0,s7
    80003390:	00000097          	auipc	ra,0x0
    80003394:	cd2080e7          	jalr	-814(ra) # 80003062 <bread>
    80003398:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000339a:	004b2503          	lw	a0,4(s6)
    8000339e:	000a849b          	sext.w	s1,s5
    800033a2:	8662                	mv	a2,s8
    800033a4:	faa4fde3          	bgeu	s1,a0,8000335e <balloc+0x3a>
      m = 1 << (bi % 8);
    800033a8:	41f6579b          	sraiw	a5,a2,0x1f
    800033ac:	01d7d69b          	srliw	a3,a5,0x1d
    800033b0:	00c6873b          	addw	a4,a3,a2
    800033b4:	00777793          	andi	a5,a4,7
    800033b8:	9f95                	subw	a5,a5,a3
    800033ba:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033be:	4037571b          	sraiw	a4,a4,0x3
    800033c2:	00e906b3          	add	a3,s2,a4
    800033c6:	0586c683          	lbu	a3,88(a3)
    800033ca:	00d7f5b3          	and	a1,a5,a3
    800033ce:	cd91                	beqz	a1,800033ea <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033d0:	2605                	addiw	a2,a2,1
    800033d2:	2485                	addiw	s1,s1,1
    800033d4:	fd4618e3          	bne	a2,s4,800033a4 <balloc+0x80>
    800033d8:	b759                	j	8000335e <balloc+0x3a>
  panic("balloc: out of blocks");
    800033da:	00005517          	auipc	a0,0x5
    800033de:	25650513          	addi	a0,a0,598 # 80008630 <syscalls+0x110>
    800033e2:	ffffd097          	auipc	ra,0xffffd
    800033e6:	166080e7          	jalr	358(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033ea:	974a                	add	a4,a4,s2
    800033ec:	8fd5                	or	a5,a5,a3
    800033ee:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800033f2:	854a                	mv	a0,s2
    800033f4:	00001097          	auipc	ra,0x1
    800033f8:	002080e7          	jalr	2(ra) # 800043f6 <log_write>
        brelse(bp);
    800033fc:	854a                	mv	a0,s2
    800033fe:	00000097          	auipc	ra,0x0
    80003402:	d94080e7          	jalr	-620(ra) # 80003192 <brelse>
  bp = bread(dev, bno);
    80003406:	85a6                	mv	a1,s1
    80003408:	855e                	mv	a0,s7
    8000340a:	00000097          	auipc	ra,0x0
    8000340e:	c58080e7          	jalr	-936(ra) # 80003062 <bread>
    80003412:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003414:	40000613          	li	a2,1024
    80003418:	4581                	li	a1,0
    8000341a:	05850513          	addi	a0,a0,88
    8000341e:	ffffe097          	auipc	ra,0xffffe
    80003422:	938080e7          	jalr	-1736(ra) # 80000d56 <memset>
  log_write(bp);
    80003426:	854a                	mv	a0,s2
    80003428:	00001097          	auipc	ra,0x1
    8000342c:	fce080e7          	jalr	-50(ra) # 800043f6 <log_write>
  brelse(bp);
    80003430:	854a                	mv	a0,s2
    80003432:	00000097          	auipc	ra,0x0
    80003436:	d60080e7          	jalr	-672(ra) # 80003192 <brelse>
}
    8000343a:	8526                	mv	a0,s1
    8000343c:	60e6                	ld	ra,88(sp)
    8000343e:	6446                	ld	s0,80(sp)
    80003440:	64a6                	ld	s1,72(sp)
    80003442:	6906                	ld	s2,64(sp)
    80003444:	79e2                	ld	s3,56(sp)
    80003446:	7a42                	ld	s4,48(sp)
    80003448:	7aa2                	ld	s5,40(sp)
    8000344a:	7b02                	ld	s6,32(sp)
    8000344c:	6be2                	ld	s7,24(sp)
    8000344e:	6c42                	ld	s8,16(sp)
    80003450:	6ca2                	ld	s9,8(sp)
    80003452:	6125                	addi	sp,sp,96
    80003454:	8082                	ret

0000000080003456 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003456:	7179                	addi	sp,sp,-48
    80003458:	f406                	sd	ra,40(sp)
    8000345a:	f022                	sd	s0,32(sp)
    8000345c:	ec26                	sd	s1,24(sp)
    8000345e:	e84a                	sd	s2,16(sp)
    80003460:	e44e                	sd	s3,8(sp)
    80003462:	e052                	sd	s4,0(sp)
    80003464:	1800                	addi	s0,sp,48
    80003466:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003468:	47ad                	li	a5,11
    8000346a:	04b7fe63          	bgeu	a5,a1,800034c6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000346e:	ff45849b          	addiw	s1,a1,-12
    80003472:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003476:	0ff00793          	li	a5,255
    8000347a:	0ae7e363          	bltu	a5,a4,80003520 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000347e:	08052583          	lw	a1,128(a0)
    80003482:	c5ad                	beqz	a1,800034ec <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003484:	00092503          	lw	a0,0(s2)
    80003488:	00000097          	auipc	ra,0x0
    8000348c:	bda080e7          	jalr	-1062(ra) # 80003062 <bread>
    80003490:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003492:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003496:	02049593          	slli	a1,s1,0x20
    8000349a:	9181                	srli	a1,a1,0x20
    8000349c:	058a                	slli	a1,a1,0x2
    8000349e:	00b784b3          	add	s1,a5,a1
    800034a2:	0004a983          	lw	s3,0(s1)
    800034a6:	04098d63          	beqz	s3,80003500 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034aa:	8552                	mv	a0,s4
    800034ac:	00000097          	auipc	ra,0x0
    800034b0:	ce6080e7          	jalr	-794(ra) # 80003192 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034b4:	854e                	mv	a0,s3
    800034b6:	70a2                	ld	ra,40(sp)
    800034b8:	7402                	ld	s0,32(sp)
    800034ba:	64e2                	ld	s1,24(sp)
    800034bc:	6942                	ld	s2,16(sp)
    800034be:	69a2                	ld	s3,8(sp)
    800034c0:	6a02                	ld	s4,0(sp)
    800034c2:	6145                	addi	sp,sp,48
    800034c4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034c6:	02059493          	slli	s1,a1,0x20
    800034ca:	9081                	srli	s1,s1,0x20
    800034cc:	048a                	slli	s1,s1,0x2
    800034ce:	94aa                	add	s1,s1,a0
    800034d0:	0504a983          	lw	s3,80(s1)
    800034d4:	fe0990e3          	bnez	s3,800034b4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034d8:	4108                	lw	a0,0(a0)
    800034da:	00000097          	auipc	ra,0x0
    800034de:	e4a080e7          	jalr	-438(ra) # 80003324 <balloc>
    800034e2:	0005099b          	sext.w	s3,a0
    800034e6:	0534a823          	sw	s3,80(s1)
    800034ea:	b7e9                	j	800034b4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800034ec:	4108                	lw	a0,0(a0)
    800034ee:	00000097          	auipc	ra,0x0
    800034f2:	e36080e7          	jalr	-458(ra) # 80003324 <balloc>
    800034f6:	0005059b          	sext.w	a1,a0
    800034fa:	08b92023          	sw	a1,128(s2)
    800034fe:	b759                	j	80003484 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003500:	00092503          	lw	a0,0(s2)
    80003504:	00000097          	auipc	ra,0x0
    80003508:	e20080e7          	jalr	-480(ra) # 80003324 <balloc>
    8000350c:	0005099b          	sext.w	s3,a0
    80003510:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003514:	8552                	mv	a0,s4
    80003516:	00001097          	auipc	ra,0x1
    8000351a:	ee0080e7          	jalr	-288(ra) # 800043f6 <log_write>
    8000351e:	b771                	j	800034aa <bmap+0x54>
  panic("bmap: out of range");
    80003520:	00005517          	auipc	a0,0x5
    80003524:	12850513          	addi	a0,a0,296 # 80008648 <syscalls+0x128>
    80003528:	ffffd097          	auipc	ra,0xffffd
    8000352c:	020080e7          	jalr	32(ra) # 80000548 <panic>

0000000080003530 <iget>:
{
    80003530:	7179                	addi	sp,sp,-48
    80003532:	f406                	sd	ra,40(sp)
    80003534:	f022                	sd	s0,32(sp)
    80003536:	ec26                	sd	s1,24(sp)
    80003538:	e84a                	sd	s2,16(sp)
    8000353a:	e44e                	sd	s3,8(sp)
    8000353c:	e052                	sd	s4,0(sp)
    8000353e:	1800                	addi	s0,sp,48
    80003540:	89aa                	mv	s3,a0
    80003542:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003544:	0001d517          	auipc	a0,0x1d
    80003548:	b1c50513          	addi	a0,a0,-1252 # 80020060 <icache>
    8000354c:	ffffd097          	auipc	ra,0xffffd
    80003550:	70e080e7          	jalr	1806(ra) # 80000c5a <acquire>
  empty = 0;
    80003554:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003556:	0001d497          	auipc	s1,0x1d
    8000355a:	b2248493          	addi	s1,s1,-1246 # 80020078 <icache+0x18>
    8000355e:	0001e697          	auipc	a3,0x1e
    80003562:	5aa68693          	addi	a3,a3,1450 # 80021b08 <log>
    80003566:	a039                	j	80003574 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003568:	02090b63          	beqz	s2,8000359e <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000356c:	08848493          	addi	s1,s1,136
    80003570:	02d48a63          	beq	s1,a3,800035a4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003574:	449c                	lw	a5,8(s1)
    80003576:	fef059e3          	blez	a5,80003568 <iget+0x38>
    8000357a:	4098                	lw	a4,0(s1)
    8000357c:	ff3716e3          	bne	a4,s3,80003568 <iget+0x38>
    80003580:	40d8                	lw	a4,4(s1)
    80003582:	ff4713e3          	bne	a4,s4,80003568 <iget+0x38>
      ip->ref++;
    80003586:	2785                	addiw	a5,a5,1
    80003588:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000358a:	0001d517          	auipc	a0,0x1d
    8000358e:	ad650513          	addi	a0,a0,-1322 # 80020060 <icache>
    80003592:	ffffd097          	auipc	ra,0xffffd
    80003596:	77c080e7          	jalr	1916(ra) # 80000d0e <release>
      return ip;
    8000359a:	8926                	mv	s2,s1
    8000359c:	a03d                	j	800035ca <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000359e:	f7f9                	bnez	a5,8000356c <iget+0x3c>
    800035a0:	8926                	mv	s2,s1
    800035a2:	b7e9                	j	8000356c <iget+0x3c>
  if(empty == 0)
    800035a4:	02090c63          	beqz	s2,800035dc <iget+0xac>
  ip->dev = dev;
    800035a8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035ac:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035b0:	4785                	li	a5,1
    800035b2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035b6:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800035ba:	0001d517          	auipc	a0,0x1d
    800035be:	aa650513          	addi	a0,a0,-1370 # 80020060 <icache>
    800035c2:	ffffd097          	auipc	ra,0xffffd
    800035c6:	74c080e7          	jalr	1868(ra) # 80000d0e <release>
}
    800035ca:	854a                	mv	a0,s2
    800035cc:	70a2                	ld	ra,40(sp)
    800035ce:	7402                	ld	s0,32(sp)
    800035d0:	64e2                	ld	s1,24(sp)
    800035d2:	6942                	ld	s2,16(sp)
    800035d4:	69a2                	ld	s3,8(sp)
    800035d6:	6a02                	ld	s4,0(sp)
    800035d8:	6145                	addi	sp,sp,48
    800035da:	8082                	ret
    panic("iget: no inodes");
    800035dc:	00005517          	auipc	a0,0x5
    800035e0:	08450513          	addi	a0,a0,132 # 80008660 <syscalls+0x140>
    800035e4:	ffffd097          	auipc	ra,0xffffd
    800035e8:	f64080e7          	jalr	-156(ra) # 80000548 <panic>

00000000800035ec <fsinit>:
fsinit(int dev) {
    800035ec:	7179                	addi	sp,sp,-48
    800035ee:	f406                	sd	ra,40(sp)
    800035f0:	f022                	sd	s0,32(sp)
    800035f2:	ec26                	sd	s1,24(sp)
    800035f4:	e84a                	sd	s2,16(sp)
    800035f6:	e44e                	sd	s3,8(sp)
    800035f8:	1800                	addi	s0,sp,48
    800035fa:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035fc:	4585                	li	a1,1
    800035fe:	00000097          	auipc	ra,0x0
    80003602:	a64080e7          	jalr	-1436(ra) # 80003062 <bread>
    80003606:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003608:	0001d997          	auipc	s3,0x1d
    8000360c:	a3898993          	addi	s3,s3,-1480 # 80020040 <sb>
    80003610:	02000613          	li	a2,32
    80003614:	05850593          	addi	a1,a0,88
    80003618:	854e                	mv	a0,s3
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	79c080e7          	jalr	1948(ra) # 80000db6 <memmove>
  brelse(bp);
    80003622:	8526                	mv	a0,s1
    80003624:	00000097          	auipc	ra,0x0
    80003628:	b6e080e7          	jalr	-1170(ra) # 80003192 <brelse>
  if(sb.magic != FSMAGIC)
    8000362c:	0009a703          	lw	a4,0(s3)
    80003630:	102037b7          	lui	a5,0x10203
    80003634:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003638:	02f71263          	bne	a4,a5,8000365c <fsinit+0x70>
  initlog(dev, &sb);
    8000363c:	0001d597          	auipc	a1,0x1d
    80003640:	a0458593          	addi	a1,a1,-1532 # 80020040 <sb>
    80003644:	854a                	mv	a0,s2
    80003646:	00001097          	auipc	ra,0x1
    8000364a:	b38080e7          	jalr	-1224(ra) # 8000417e <initlog>
}
    8000364e:	70a2                	ld	ra,40(sp)
    80003650:	7402                	ld	s0,32(sp)
    80003652:	64e2                	ld	s1,24(sp)
    80003654:	6942                	ld	s2,16(sp)
    80003656:	69a2                	ld	s3,8(sp)
    80003658:	6145                	addi	sp,sp,48
    8000365a:	8082                	ret
    panic("invalid file system");
    8000365c:	00005517          	auipc	a0,0x5
    80003660:	01450513          	addi	a0,a0,20 # 80008670 <syscalls+0x150>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	ee4080e7          	jalr	-284(ra) # 80000548 <panic>

000000008000366c <iinit>:
{
    8000366c:	7179                	addi	sp,sp,-48
    8000366e:	f406                	sd	ra,40(sp)
    80003670:	f022                	sd	s0,32(sp)
    80003672:	ec26                	sd	s1,24(sp)
    80003674:	e84a                	sd	s2,16(sp)
    80003676:	e44e                	sd	s3,8(sp)
    80003678:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000367a:	00005597          	auipc	a1,0x5
    8000367e:	00e58593          	addi	a1,a1,14 # 80008688 <syscalls+0x168>
    80003682:	0001d517          	auipc	a0,0x1d
    80003686:	9de50513          	addi	a0,a0,-1570 # 80020060 <icache>
    8000368a:	ffffd097          	auipc	ra,0xffffd
    8000368e:	540080e7          	jalr	1344(ra) # 80000bca <initlock>
  for(i = 0; i < NINODE; i++) {
    80003692:	0001d497          	auipc	s1,0x1d
    80003696:	9f648493          	addi	s1,s1,-1546 # 80020088 <icache+0x28>
    8000369a:	0001e997          	auipc	s3,0x1e
    8000369e:	47e98993          	addi	s3,s3,1150 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800036a2:	00005917          	auipc	s2,0x5
    800036a6:	fee90913          	addi	s2,s2,-18 # 80008690 <syscalls+0x170>
    800036aa:	85ca                	mv	a1,s2
    800036ac:	8526                	mv	a0,s1
    800036ae:	00001097          	auipc	ra,0x1
    800036b2:	e36080e7          	jalr	-458(ra) # 800044e4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036b6:	08848493          	addi	s1,s1,136
    800036ba:	ff3498e3          	bne	s1,s3,800036aa <iinit+0x3e>
}
    800036be:	70a2                	ld	ra,40(sp)
    800036c0:	7402                	ld	s0,32(sp)
    800036c2:	64e2                	ld	s1,24(sp)
    800036c4:	6942                	ld	s2,16(sp)
    800036c6:	69a2                	ld	s3,8(sp)
    800036c8:	6145                	addi	sp,sp,48
    800036ca:	8082                	ret

00000000800036cc <ialloc>:
{
    800036cc:	715d                	addi	sp,sp,-80
    800036ce:	e486                	sd	ra,72(sp)
    800036d0:	e0a2                	sd	s0,64(sp)
    800036d2:	fc26                	sd	s1,56(sp)
    800036d4:	f84a                	sd	s2,48(sp)
    800036d6:	f44e                	sd	s3,40(sp)
    800036d8:	f052                	sd	s4,32(sp)
    800036da:	ec56                	sd	s5,24(sp)
    800036dc:	e85a                	sd	s6,16(sp)
    800036de:	e45e                	sd	s7,8(sp)
    800036e0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036e2:	0001d717          	auipc	a4,0x1d
    800036e6:	96a72703          	lw	a4,-1686(a4) # 8002004c <sb+0xc>
    800036ea:	4785                	li	a5,1
    800036ec:	04e7fa63          	bgeu	a5,a4,80003740 <ialloc+0x74>
    800036f0:	8aaa                	mv	s5,a0
    800036f2:	8bae                	mv	s7,a1
    800036f4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036f6:	0001da17          	auipc	s4,0x1d
    800036fa:	94aa0a13          	addi	s4,s4,-1718 # 80020040 <sb>
    800036fe:	00048b1b          	sext.w	s6,s1
    80003702:	0044d593          	srli	a1,s1,0x4
    80003706:	018a2783          	lw	a5,24(s4)
    8000370a:	9dbd                	addw	a1,a1,a5
    8000370c:	8556                	mv	a0,s5
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	954080e7          	jalr	-1708(ra) # 80003062 <bread>
    80003716:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003718:	05850993          	addi	s3,a0,88
    8000371c:	00f4f793          	andi	a5,s1,15
    80003720:	079a                	slli	a5,a5,0x6
    80003722:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003724:	00099783          	lh	a5,0(s3)
    80003728:	c785                	beqz	a5,80003750 <ialloc+0x84>
    brelse(bp);
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	a68080e7          	jalr	-1432(ra) # 80003192 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003732:	0485                	addi	s1,s1,1
    80003734:	00ca2703          	lw	a4,12(s4)
    80003738:	0004879b          	sext.w	a5,s1
    8000373c:	fce7e1e3          	bltu	a5,a4,800036fe <ialloc+0x32>
  panic("ialloc: no inodes");
    80003740:	00005517          	auipc	a0,0x5
    80003744:	f5850513          	addi	a0,a0,-168 # 80008698 <syscalls+0x178>
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	e00080e7          	jalr	-512(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    80003750:	04000613          	li	a2,64
    80003754:	4581                	li	a1,0
    80003756:	854e                	mv	a0,s3
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	5fe080e7          	jalr	1534(ra) # 80000d56 <memset>
      dip->type = type;
    80003760:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003764:	854a                	mv	a0,s2
    80003766:	00001097          	auipc	ra,0x1
    8000376a:	c90080e7          	jalr	-880(ra) # 800043f6 <log_write>
      brelse(bp);
    8000376e:	854a                	mv	a0,s2
    80003770:	00000097          	auipc	ra,0x0
    80003774:	a22080e7          	jalr	-1502(ra) # 80003192 <brelse>
      return iget(dev, inum);
    80003778:	85da                	mv	a1,s6
    8000377a:	8556                	mv	a0,s5
    8000377c:	00000097          	auipc	ra,0x0
    80003780:	db4080e7          	jalr	-588(ra) # 80003530 <iget>
}
    80003784:	60a6                	ld	ra,72(sp)
    80003786:	6406                	ld	s0,64(sp)
    80003788:	74e2                	ld	s1,56(sp)
    8000378a:	7942                	ld	s2,48(sp)
    8000378c:	79a2                	ld	s3,40(sp)
    8000378e:	7a02                	ld	s4,32(sp)
    80003790:	6ae2                	ld	s5,24(sp)
    80003792:	6b42                	ld	s6,16(sp)
    80003794:	6ba2                	ld	s7,8(sp)
    80003796:	6161                	addi	sp,sp,80
    80003798:	8082                	ret

000000008000379a <iupdate>:
{
    8000379a:	1101                	addi	sp,sp,-32
    8000379c:	ec06                	sd	ra,24(sp)
    8000379e:	e822                	sd	s0,16(sp)
    800037a0:	e426                	sd	s1,8(sp)
    800037a2:	e04a                	sd	s2,0(sp)
    800037a4:	1000                	addi	s0,sp,32
    800037a6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037a8:	415c                	lw	a5,4(a0)
    800037aa:	0047d79b          	srliw	a5,a5,0x4
    800037ae:	0001d597          	auipc	a1,0x1d
    800037b2:	8aa5a583          	lw	a1,-1878(a1) # 80020058 <sb+0x18>
    800037b6:	9dbd                	addw	a1,a1,a5
    800037b8:	4108                	lw	a0,0(a0)
    800037ba:	00000097          	auipc	ra,0x0
    800037be:	8a8080e7          	jalr	-1880(ra) # 80003062 <bread>
    800037c2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037c4:	05850793          	addi	a5,a0,88
    800037c8:	40c8                	lw	a0,4(s1)
    800037ca:	893d                	andi	a0,a0,15
    800037cc:	051a                	slli	a0,a0,0x6
    800037ce:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037d0:	04449703          	lh	a4,68(s1)
    800037d4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800037d8:	04649703          	lh	a4,70(s1)
    800037dc:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800037e0:	04849703          	lh	a4,72(s1)
    800037e4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800037e8:	04a49703          	lh	a4,74(s1)
    800037ec:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800037f0:	44f8                	lw	a4,76(s1)
    800037f2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037f4:	03400613          	li	a2,52
    800037f8:	05048593          	addi	a1,s1,80
    800037fc:	0531                	addi	a0,a0,12
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	5b8080e7          	jalr	1464(ra) # 80000db6 <memmove>
  log_write(bp);
    80003806:	854a                	mv	a0,s2
    80003808:	00001097          	auipc	ra,0x1
    8000380c:	bee080e7          	jalr	-1042(ra) # 800043f6 <log_write>
  brelse(bp);
    80003810:	854a                	mv	a0,s2
    80003812:	00000097          	auipc	ra,0x0
    80003816:	980080e7          	jalr	-1664(ra) # 80003192 <brelse>
}
    8000381a:	60e2                	ld	ra,24(sp)
    8000381c:	6442                	ld	s0,16(sp)
    8000381e:	64a2                	ld	s1,8(sp)
    80003820:	6902                	ld	s2,0(sp)
    80003822:	6105                	addi	sp,sp,32
    80003824:	8082                	ret

0000000080003826 <idup>:
{
    80003826:	1101                	addi	sp,sp,-32
    80003828:	ec06                	sd	ra,24(sp)
    8000382a:	e822                	sd	s0,16(sp)
    8000382c:	e426                	sd	s1,8(sp)
    8000382e:	1000                	addi	s0,sp,32
    80003830:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003832:	0001d517          	auipc	a0,0x1d
    80003836:	82e50513          	addi	a0,a0,-2002 # 80020060 <icache>
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	420080e7          	jalr	1056(ra) # 80000c5a <acquire>
  ip->ref++;
    80003842:	449c                	lw	a5,8(s1)
    80003844:	2785                	addiw	a5,a5,1
    80003846:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003848:	0001d517          	auipc	a0,0x1d
    8000384c:	81850513          	addi	a0,a0,-2024 # 80020060 <icache>
    80003850:	ffffd097          	auipc	ra,0xffffd
    80003854:	4be080e7          	jalr	1214(ra) # 80000d0e <release>
}
    80003858:	8526                	mv	a0,s1
    8000385a:	60e2                	ld	ra,24(sp)
    8000385c:	6442                	ld	s0,16(sp)
    8000385e:	64a2                	ld	s1,8(sp)
    80003860:	6105                	addi	sp,sp,32
    80003862:	8082                	ret

0000000080003864 <ilock>:
{
    80003864:	1101                	addi	sp,sp,-32
    80003866:	ec06                	sd	ra,24(sp)
    80003868:	e822                	sd	s0,16(sp)
    8000386a:	e426                	sd	s1,8(sp)
    8000386c:	e04a                	sd	s2,0(sp)
    8000386e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003870:	c115                	beqz	a0,80003894 <ilock+0x30>
    80003872:	84aa                	mv	s1,a0
    80003874:	451c                	lw	a5,8(a0)
    80003876:	00f05f63          	blez	a5,80003894 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000387a:	0541                	addi	a0,a0,16
    8000387c:	00001097          	auipc	ra,0x1
    80003880:	ca2080e7          	jalr	-862(ra) # 8000451e <acquiresleep>
  if(ip->valid == 0){
    80003884:	40bc                	lw	a5,64(s1)
    80003886:	cf99                	beqz	a5,800038a4 <ilock+0x40>
}
    80003888:	60e2                	ld	ra,24(sp)
    8000388a:	6442                	ld	s0,16(sp)
    8000388c:	64a2                	ld	s1,8(sp)
    8000388e:	6902                	ld	s2,0(sp)
    80003890:	6105                	addi	sp,sp,32
    80003892:	8082                	ret
    panic("ilock");
    80003894:	00005517          	auipc	a0,0x5
    80003898:	e1c50513          	addi	a0,a0,-484 # 800086b0 <syscalls+0x190>
    8000389c:	ffffd097          	auipc	ra,0xffffd
    800038a0:	cac080e7          	jalr	-852(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038a4:	40dc                	lw	a5,4(s1)
    800038a6:	0047d79b          	srliw	a5,a5,0x4
    800038aa:	0001c597          	auipc	a1,0x1c
    800038ae:	7ae5a583          	lw	a1,1966(a1) # 80020058 <sb+0x18>
    800038b2:	9dbd                	addw	a1,a1,a5
    800038b4:	4088                	lw	a0,0(s1)
    800038b6:	fffff097          	auipc	ra,0xfffff
    800038ba:	7ac080e7          	jalr	1964(ra) # 80003062 <bread>
    800038be:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038c0:	05850593          	addi	a1,a0,88
    800038c4:	40dc                	lw	a5,4(s1)
    800038c6:	8bbd                	andi	a5,a5,15
    800038c8:	079a                	slli	a5,a5,0x6
    800038ca:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038cc:	00059783          	lh	a5,0(a1)
    800038d0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038d4:	00259783          	lh	a5,2(a1)
    800038d8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038dc:	00459783          	lh	a5,4(a1)
    800038e0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038e4:	00659783          	lh	a5,6(a1)
    800038e8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038ec:	459c                	lw	a5,8(a1)
    800038ee:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038f0:	03400613          	li	a2,52
    800038f4:	05b1                	addi	a1,a1,12
    800038f6:	05048513          	addi	a0,s1,80
    800038fa:	ffffd097          	auipc	ra,0xffffd
    800038fe:	4bc080e7          	jalr	1212(ra) # 80000db6 <memmove>
    brelse(bp);
    80003902:	854a                	mv	a0,s2
    80003904:	00000097          	auipc	ra,0x0
    80003908:	88e080e7          	jalr	-1906(ra) # 80003192 <brelse>
    ip->valid = 1;
    8000390c:	4785                	li	a5,1
    8000390e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003910:	04449783          	lh	a5,68(s1)
    80003914:	fbb5                	bnez	a5,80003888 <ilock+0x24>
      panic("ilock: no type");
    80003916:	00005517          	auipc	a0,0x5
    8000391a:	da250513          	addi	a0,a0,-606 # 800086b8 <syscalls+0x198>
    8000391e:	ffffd097          	auipc	ra,0xffffd
    80003922:	c2a080e7          	jalr	-982(ra) # 80000548 <panic>

0000000080003926 <iunlock>:
{
    80003926:	1101                	addi	sp,sp,-32
    80003928:	ec06                	sd	ra,24(sp)
    8000392a:	e822                	sd	s0,16(sp)
    8000392c:	e426                	sd	s1,8(sp)
    8000392e:	e04a                	sd	s2,0(sp)
    80003930:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003932:	c905                	beqz	a0,80003962 <iunlock+0x3c>
    80003934:	84aa                	mv	s1,a0
    80003936:	01050913          	addi	s2,a0,16
    8000393a:	854a                	mv	a0,s2
    8000393c:	00001097          	auipc	ra,0x1
    80003940:	c7c080e7          	jalr	-900(ra) # 800045b8 <holdingsleep>
    80003944:	cd19                	beqz	a0,80003962 <iunlock+0x3c>
    80003946:	449c                	lw	a5,8(s1)
    80003948:	00f05d63          	blez	a5,80003962 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000394c:	854a                	mv	a0,s2
    8000394e:	00001097          	auipc	ra,0x1
    80003952:	c26080e7          	jalr	-986(ra) # 80004574 <releasesleep>
}
    80003956:	60e2                	ld	ra,24(sp)
    80003958:	6442                	ld	s0,16(sp)
    8000395a:	64a2                	ld	s1,8(sp)
    8000395c:	6902                	ld	s2,0(sp)
    8000395e:	6105                	addi	sp,sp,32
    80003960:	8082                	ret
    panic("iunlock");
    80003962:	00005517          	auipc	a0,0x5
    80003966:	d6650513          	addi	a0,a0,-666 # 800086c8 <syscalls+0x1a8>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	bde080e7          	jalr	-1058(ra) # 80000548 <panic>

0000000080003972 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003972:	7179                	addi	sp,sp,-48
    80003974:	f406                	sd	ra,40(sp)
    80003976:	f022                	sd	s0,32(sp)
    80003978:	ec26                	sd	s1,24(sp)
    8000397a:	e84a                	sd	s2,16(sp)
    8000397c:	e44e                	sd	s3,8(sp)
    8000397e:	e052                	sd	s4,0(sp)
    80003980:	1800                	addi	s0,sp,48
    80003982:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003984:	05050493          	addi	s1,a0,80
    80003988:	08050913          	addi	s2,a0,128
    8000398c:	a021                	j	80003994 <itrunc+0x22>
    8000398e:	0491                	addi	s1,s1,4
    80003990:	01248d63          	beq	s1,s2,800039aa <itrunc+0x38>
    if(ip->addrs[i]){
    80003994:	408c                	lw	a1,0(s1)
    80003996:	dde5                	beqz	a1,8000398e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003998:	0009a503          	lw	a0,0(s3)
    8000399c:	00000097          	auipc	ra,0x0
    800039a0:	90c080e7          	jalr	-1780(ra) # 800032a8 <bfree>
      ip->addrs[i] = 0;
    800039a4:	0004a023          	sw	zero,0(s1)
    800039a8:	b7dd                	j	8000398e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039aa:	0809a583          	lw	a1,128(s3)
    800039ae:	e185                	bnez	a1,800039ce <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039b0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039b4:	854e                	mv	a0,s3
    800039b6:	00000097          	auipc	ra,0x0
    800039ba:	de4080e7          	jalr	-540(ra) # 8000379a <iupdate>
}
    800039be:	70a2                	ld	ra,40(sp)
    800039c0:	7402                	ld	s0,32(sp)
    800039c2:	64e2                	ld	s1,24(sp)
    800039c4:	6942                	ld	s2,16(sp)
    800039c6:	69a2                	ld	s3,8(sp)
    800039c8:	6a02                	ld	s4,0(sp)
    800039ca:	6145                	addi	sp,sp,48
    800039cc:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039ce:	0009a503          	lw	a0,0(s3)
    800039d2:	fffff097          	auipc	ra,0xfffff
    800039d6:	690080e7          	jalr	1680(ra) # 80003062 <bread>
    800039da:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039dc:	05850493          	addi	s1,a0,88
    800039e0:	45850913          	addi	s2,a0,1112
    800039e4:	a811                	j	800039f8 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800039e6:	0009a503          	lw	a0,0(s3)
    800039ea:	00000097          	auipc	ra,0x0
    800039ee:	8be080e7          	jalr	-1858(ra) # 800032a8 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800039f2:	0491                	addi	s1,s1,4
    800039f4:	01248563          	beq	s1,s2,800039fe <itrunc+0x8c>
      if(a[j])
    800039f8:	408c                	lw	a1,0(s1)
    800039fa:	dde5                	beqz	a1,800039f2 <itrunc+0x80>
    800039fc:	b7ed                	j	800039e6 <itrunc+0x74>
    brelse(bp);
    800039fe:	8552                	mv	a0,s4
    80003a00:	fffff097          	auipc	ra,0xfffff
    80003a04:	792080e7          	jalr	1938(ra) # 80003192 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a08:	0809a583          	lw	a1,128(s3)
    80003a0c:	0009a503          	lw	a0,0(s3)
    80003a10:	00000097          	auipc	ra,0x0
    80003a14:	898080e7          	jalr	-1896(ra) # 800032a8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a18:	0809a023          	sw	zero,128(s3)
    80003a1c:	bf51                	j	800039b0 <itrunc+0x3e>

0000000080003a1e <iput>:
{
    80003a1e:	1101                	addi	sp,sp,-32
    80003a20:	ec06                	sd	ra,24(sp)
    80003a22:	e822                	sd	s0,16(sp)
    80003a24:	e426                	sd	s1,8(sp)
    80003a26:	e04a                	sd	s2,0(sp)
    80003a28:	1000                	addi	s0,sp,32
    80003a2a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a2c:	0001c517          	auipc	a0,0x1c
    80003a30:	63450513          	addi	a0,a0,1588 # 80020060 <icache>
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	226080e7          	jalr	550(ra) # 80000c5a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a3c:	4498                	lw	a4,8(s1)
    80003a3e:	4785                	li	a5,1
    80003a40:	02f70363          	beq	a4,a5,80003a66 <iput+0x48>
  ip->ref--;
    80003a44:	449c                	lw	a5,8(s1)
    80003a46:	37fd                	addiw	a5,a5,-1
    80003a48:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a4a:	0001c517          	auipc	a0,0x1c
    80003a4e:	61650513          	addi	a0,a0,1558 # 80020060 <icache>
    80003a52:	ffffd097          	auipc	ra,0xffffd
    80003a56:	2bc080e7          	jalr	700(ra) # 80000d0e <release>
}
    80003a5a:	60e2                	ld	ra,24(sp)
    80003a5c:	6442                	ld	s0,16(sp)
    80003a5e:	64a2                	ld	s1,8(sp)
    80003a60:	6902                	ld	s2,0(sp)
    80003a62:	6105                	addi	sp,sp,32
    80003a64:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a66:	40bc                	lw	a5,64(s1)
    80003a68:	dff1                	beqz	a5,80003a44 <iput+0x26>
    80003a6a:	04a49783          	lh	a5,74(s1)
    80003a6e:	fbf9                	bnez	a5,80003a44 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a70:	01048913          	addi	s2,s1,16
    80003a74:	854a                	mv	a0,s2
    80003a76:	00001097          	auipc	ra,0x1
    80003a7a:	aa8080e7          	jalr	-1368(ra) # 8000451e <acquiresleep>
    release(&icache.lock);
    80003a7e:	0001c517          	auipc	a0,0x1c
    80003a82:	5e250513          	addi	a0,a0,1506 # 80020060 <icache>
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	288080e7          	jalr	648(ra) # 80000d0e <release>
    itrunc(ip);
    80003a8e:	8526                	mv	a0,s1
    80003a90:	00000097          	auipc	ra,0x0
    80003a94:	ee2080e7          	jalr	-286(ra) # 80003972 <itrunc>
    ip->type = 0;
    80003a98:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a9c:	8526                	mv	a0,s1
    80003a9e:	00000097          	auipc	ra,0x0
    80003aa2:	cfc080e7          	jalr	-772(ra) # 8000379a <iupdate>
    ip->valid = 0;
    80003aa6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003aaa:	854a                	mv	a0,s2
    80003aac:	00001097          	auipc	ra,0x1
    80003ab0:	ac8080e7          	jalr	-1336(ra) # 80004574 <releasesleep>
    acquire(&icache.lock);
    80003ab4:	0001c517          	auipc	a0,0x1c
    80003ab8:	5ac50513          	addi	a0,a0,1452 # 80020060 <icache>
    80003abc:	ffffd097          	auipc	ra,0xffffd
    80003ac0:	19e080e7          	jalr	414(ra) # 80000c5a <acquire>
    80003ac4:	b741                	j	80003a44 <iput+0x26>

0000000080003ac6 <iunlockput>:
{
    80003ac6:	1101                	addi	sp,sp,-32
    80003ac8:	ec06                	sd	ra,24(sp)
    80003aca:	e822                	sd	s0,16(sp)
    80003acc:	e426                	sd	s1,8(sp)
    80003ace:	1000                	addi	s0,sp,32
    80003ad0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	e54080e7          	jalr	-428(ra) # 80003926 <iunlock>
  iput(ip);
    80003ada:	8526                	mv	a0,s1
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	f42080e7          	jalr	-190(ra) # 80003a1e <iput>
}
    80003ae4:	60e2                	ld	ra,24(sp)
    80003ae6:	6442                	ld	s0,16(sp)
    80003ae8:	64a2                	ld	s1,8(sp)
    80003aea:	6105                	addi	sp,sp,32
    80003aec:	8082                	ret

0000000080003aee <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003aee:	1141                	addi	sp,sp,-16
    80003af0:	e422                	sd	s0,8(sp)
    80003af2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003af4:	411c                	lw	a5,0(a0)
    80003af6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003af8:	415c                	lw	a5,4(a0)
    80003afa:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003afc:	04451783          	lh	a5,68(a0)
    80003b00:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b04:	04a51783          	lh	a5,74(a0)
    80003b08:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b0c:	04c56783          	lwu	a5,76(a0)
    80003b10:	e99c                	sd	a5,16(a1)
}
    80003b12:	6422                	ld	s0,8(sp)
    80003b14:	0141                	addi	sp,sp,16
    80003b16:	8082                	ret

0000000080003b18 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b18:	457c                	lw	a5,76(a0)
    80003b1a:	0ed7e863          	bltu	a5,a3,80003c0a <readi+0xf2>
{
    80003b1e:	7159                	addi	sp,sp,-112
    80003b20:	f486                	sd	ra,104(sp)
    80003b22:	f0a2                	sd	s0,96(sp)
    80003b24:	eca6                	sd	s1,88(sp)
    80003b26:	e8ca                	sd	s2,80(sp)
    80003b28:	e4ce                	sd	s3,72(sp)
    80003b2a:	e0d2                	sd	s4,64(sp)
    80003b2c:	fc56                	sd	s5,56(sp)
    80003b2e:	f85a                	sd	s6,48(sp)
    80003b30:	f45e                	sd	s7,40(sp)
    80003b32:	f062                	sd	s8,32(sp)
    80003b34:	ec66                	sd	s9,24(sp)
    80003b36:	e86a                	sd	s10,16(sp)
    80003b38:	e46e                	sd	s11,8(sp)
    80003b3a:	1880                	addi	s0,sp,112
    80003b3c:	8baa                	mv	s7,a0
    80003b3e:	8c2e                	mv	s8,a1
    80003b40:	8ab2                	mv	s5,a2
    80003b42:	84b6                	mv	s1,a3
    80003b44:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b46:	9f35                	addw	a4,a4,a3
    return 0;
    80003b48:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b4a:	08d76f63          	bltu	a4,a3,80003be8 <readi+0xd0>
  if(off + n > ip->size)
    80003b4e:	00e7f463          	bgeu	a5,a4,80003b56 <readi+0x3e>
    n = ip->size - off;
    80003b52:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b56:	0a0b0863          	beqz	s6,80003c06 <readi+0xee>
    80003b5a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b5c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b60:	5cfd                	li	s9,-1
    80003b62:	a82d                	j	80003b9c <readi+0x84>
    80003b64:	020a1d93          	slli	s11,s4,0x20
    80003b68:	020ddd93          	srli	s11,s11,0x20
    80003b6c:	05890613          	addi	a2,s2,88
    80003b70:	86ee                	mv	a3,s11
    80003b72:	963a                	add	a2,a2,a4
    80003b74:	85d6                	mv	a1,s5
    80003b76:	8562                	mv	a0,s8
    80003b78:	fffff097          	auipc	ra,0xfffff
    80003b7c:	a0e080e7          	jalr	-1522(ra) # 80002586 <either_copyout>
    80003b80:	05950d63          	beq	a0,s9,80003bda <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003b84:	854a                	mv	a0,s2
    80003b86:	fffff097          	auipc	ra,0xfffff
    80003b8a:	60c080e7          	jalr	1548(ra) # 80003192 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b8e:	013a09bb          	addw	s3,s4,s3
    80003b92:	009a04bb          	addw	s1,s4,s1
    80003b96:	9aee                	add	s5,s5,s11
    80003b98:	0569f663          	bgeu	s3,s6,80003be4 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b9c:	000ba903          	lw	s2,0(s7)
    80003ba0:	00a4d59b          	srliw	a1,s1,0xa
    80003ba4:	855e                	mv	a0,s7
    80003ba6:	00000097          	auipc	ra,0x0
    80003baa:	8b0080e7          	jalr	-1872(ra) # 80003456 <bmap>
    80003bae:	0005059b          	sext.w	a1,a0
    80003bb2:	854a                	mv	a0,s2
    80003bb4:	fffff097          	auipc	ra,0xfffff
    80003bb8:	4ae080e7          	jalr	1198(ra) # 80003062 <bread>
    80003bbc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bbe:	3ff4f713          	andi	a4,s1,1023
    80003bc2:	40ed07bb          	subw	a5,s10,a4
    80003bc6:	413b06bb          	subw	a3,s6,s3
    80003bca:	8a3e                	mv	s4,a5
    80003bcc:	2781                	sext.w	a5,a5
    80003bce:	0006861b          	sext.w	a2,a3
    80003bd2:	f8f679e3          	bgeu	a2,a5,80003b64 <readi+0x4c>
    80003bd6:	8a36                	mv	s4,a3
    80003bd8:	b771                	j	80003b64 <readi+0x4c>
      brelse(bp);
    80003bda:	854a                	mv	a0,s2
    80003bdc:	fffff097          	auipc	ra,0xfffff
    80003be0:	5b6080e7          	jalr	1462(ra) # 80003192 <brelse>
  }
  return tot;
    80003be4:	0009851b          	sext.w	a0,s3
}
    80003be8:	70a6                	ld	ra,104(sp)
    80003bea:	7406                	ld	s0,96(sp)
    80003bec:	64e6                	ld	s1,88(sp)
    80003bee:	6946                	ld	s2,80(sp)
    80003bf0:	69a6                	ld	s3,72(sp)
    80003bf2:	6a06                	ld	s4,64(sp)
    80003bf4:	7ae2                	ld	s5,56(sp)
    80003bf6:	7b42                	ld	s6,48(sp)
    80003bf8:	7ba2                	ld	s7,40(sp)
    80003bfa:	7c02                	ld	s8,32(sp)
    80003bfc:	6ce2                	ld	s9,24(sp)
    80003bfe:	6d42                	ld	s10,16(sp)
    80003c00:	6da2                	ld	s11,8(sp)
    80003c02:	6165                	addi	sp,sp,112
    80003c04:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c06:	89da                	mv	s3,s6
    80003c08:	bff1                	j	80003be4 <readi+0xcc>
    return 0;
    80003c0a:	4501                	li	a0,0
}
    80003c0c:	8082                	ret

0000000080003c0e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c0e:	457c                	lw	a5,76(a0)
    80003c10:	10d7e663          	bltu	a5,a3,80003d1c <writei+0x10e>
{
    80003c14:	7159                	addi	sp,sp,-112
    80003c16:	f486                	sd	ra,104(sp)
    80003c18:	f0a2                	sd	s0,96(sp)
    80003c1a:	eca6                	sd	s1,88(sp)
    80003c1c:	e8ca                	sd	s2,80(sp)
    80003c1e:	e4ce                	sd	s3,72(sp)
    80003c20:	e0d2                	sd	s4,64(sp)
    80003c22:	fc56                	sd	s5,56(sp)
    80003c24:	f85a                	sd	s6,48(sp)
    80003c26:	f45e                	sd	s7,40(sp)
    80003c28:	f062                	sd	s8,32(sp)
    80003c2a:	ec66                	sd	s9,24(sp)
    80003c2c:	e86a                	sd	s10,16(sp)
    80003c2e:	e46e                	sd	s11,8(sp)
    80003c30:	1880                	addi	s0,sp,112
    80003c32:	8baa                	mv	s7,a0
    80003c34:	8c2e                	mv	s8,a1
    80003c36:	8ab2                	mv	s5,a2
    80003c38:	8936                	mv	s2,a3
    80003c3a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c3c:	00e687bb          	addw	a5,a3,a4
    80003c40:	0ed7e063          	bltu	a5,a3,80003d20 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c44:	00043737          	lui	a4,0x43
    80003c48:	0cf76e63          	bltu	a4,a5,80003d24 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c4c:	0a0b0763          	beqz	s6,80003cfa <writei+0xec>
    80003c50:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c52:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c56:	5cfd                	li	s9,-1
    80003c58:	a091                	j	80003c9c <writei+0x8e>
    80003c5a:	02099d93          	slli	s11,s3,0x20
    80003c5e:	020ddd93          	srli	s11,s11,0x20
    80003c62:	05848513          	addi	a0,s1,88
    80003c66:	86ee                	mv	a3,s11
    80003c68:	8656                	mv	a2,s5
    80003c6a:	85e2                	mv	a1,s8
    80003c6c:	953a                	add	a0,a0,a4
    80003c6e:	fffff097          	auipc	ra,0xfffff
    80003c72:	96e080e7          	jalr	-1682(ra) # 800025dc <either_copyin>
    80003c76:	07950263          	beq	a0,s9,80003cda <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	77a080e7          	jalr	1914(ra) # 800043f6 <log_write>
    brelse(bp);
    80003c84:	8526                	mv	a0,s1
    80003c86:	fffff097          	auipc	ra,0xfffff
    80003c8a:	50c080e7          	jalr	1292(ra) # 80003192 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c8e:	01498a3b          	addw	s4,s3,s4
    80003c92:	0129893b          	addw	s2,s3,s2
    80003c96:	9aee                	add	s5,s5,s11
    80003c98:	056a7663          	bgeu	s4,s6,80003ce4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c9c:	000ba483          	lw	s1,0(s7)
    80003ca0:	00a9559b          	srliw	a1,s2,0xa
    80003ca4:	855e                	mv	a0,s7
    80003ca6:	fffff097          	auipc	ra,0xfffff
    80003caa:	7b0080e7          	jalr	1968(ra) # 80003456 <bmap>
    80003cae:	0005059b          	sext.w	a1,a0
    80003cb2:	8526                	mv	a0,s1
    80003cb4:	fffff097          	auipc	ra,0xfffff
    80003cb8:	3ae080e7          	jalr	942(ra) # 80003062 <bread>
    80003cbc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cbe:	3ff97713          	andi	a4,s2,1023
    80003cc2:	40ed07bb          	subw	a5,s10,a4
    80003cc6:	414b06bb          	subw	a3,s6,s4
    80003cca:	89be                	mv	s3,a5
    80003ccc:	2781                	sext.w	a5,a5
    80003cce:	0006861b          	sext.w	a2,a3
    80003cd2:	f8f674e3          	bgeu	a2,a5,80003c5a <writei+0x4c>
    80003cd6:	89b6                	mv	s3,a3
    80003cd8:	b749                	j	80003c5a <writei+0x4c>
      brelse(bp);
    80003cda:	8526                	mv	a0,s1
    80003cdc:	fffff097          	auipc	ra,0xfffff
    80003ce0:	4b6080e7          	jalr	1206(ra) # 80003192 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003ce4:	04cba783          	lw	a5,76(s7)
    80003ce8:	0127f463          	bgeu	a5,s2,80003cf0 <writei+0xe2>
      ip->size = off;
    80003cec:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003cf0:	855e                	mv	a0,s7
    80003cf2:	00000097          	auipc	ra,0x0
    80003cf6:	aa8080e7          	jalr	-1368(ra) # 8000379a <iupdate>
  }

  return n;
    80003cfa:	000b051b          	sext.w	a0,s6
}
    80003cfe:	70a6                	ld	ra,104(sp)
    80003d00:	7406                	ld	s0,96(sp)
    80003d02:	64e6                	ld	s1,88(sp)
    80003d04:	6946                	ld	s2,80(sp)
    80003d06:	69a6                	ld	s3,72(sp)
    80003d08:	6a06                	ld	s4,64(sp)
    80003d0a:	7ae2                	ld	s5,56(sp)
    80003d0c:	7b42                	ld	s6,48(sp)
    80003d0e:	7ba2                	ld	s7,40(sp)
    80003d10:	7c02                	ld	s8,32(sp)
    80003d12:	6ce2                	ld	s9,24(sp)
    80003d14:	6d42                	ld	s10,16(sp)
    80003d16:	6da2                	ld	s11,8(sp)
    80003d18:	6165                	addi	sp,sp,112
    80003d1a:	8082                	ret
    return -1;
    80003d1c:	557d                	li	a0,-1
}
    80003d1e:	8082                	ret
    return -1;
    80003d20:	557d                	li	a0,-1
    80003d22:	bff1                	j	80003cfe <writei+0xf0>
    return -1;
    80003d24:	557d                	li	a0,-1
    80003d26:	bfe1                	j	80003cfe <writei+0xf0>

0000000080003d28 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d28:	1141                	addi	sp,sp,-16
    80003d2a:	e406                	sd	ra,8(sp)
    80003d2c:	e022                	sd	s0,0(sp)
    80003d2e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d30:	4639                	li	a2,14
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	100080e7          	jalr	256(ra) # 80000e32 <strncmp>
}
    80003d3a:	60a2                	ld	ra,8(sp)
    80003d3c:	6402                	ld	s0,0(sp)
    80003d3e:	0141                	addi	sp,sp,16
    80003d40:	8082                	ret

0000000080003d42 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d42:	7139                	addi	sp,sp,-64
    80003d44:	fc06                	sd	ra,56(sp)
    80003d46:	f822                	sd	s0,48(sp)
    80003d48:	f426                	sd	s1,40(sp)
    80003d4a:	f04a                	sd	s2,32(sp)
    80003d4c:	ec4e                	sd	s3,24(sp)
    80003d4e:	e852                	sd	s4,16(sp)
    80003d50:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d52:	04451703          	lh	a4,68(a0)
    80003d56:	4785                	li	a5,1
    80003d58:	00f71a63          	bne	a4,a5,80003d6c <dirlookup+0x2a>
    80003d5c:	892a                	mv	s2,a0
    80003d5e:	89ae                	mv	s3,a1
    80003d60:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d62:	457c                	lw	a5,76(a0)
    80003d64:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d66:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d68:	e79d                	bnez	a5,80003d96 <dirlookup+0x54>
    80003d6a:	a8a5                	j	80003de2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d6c:	00005517          	auipc	a0,0x5
    80003d70:	96450513          	addi	a0,a0,-1692 # 800086d0 <syscalls+0x1b0>
    80003d74:	ffffc097          	auipc	ra,0xffffc
    80003d78:	7d4080e7          	jalr	2004(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003d7c:	00005517          	auipc	a0,0x5
    80003d80:	96c50513          	addi	a0,a0,-1684 # 800086e8 <syscalls+0x1c8>
    80003d84:	ffffc097          	auipc	ra,0xffffc
    80003d88:	7c4080e7          	jalr	1988(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d8c:	24c1                	addiw	s1,s1,16
    80003d8e:	04c92783          	lw	a5,76(s2)
    80003d92:	04f4f763          	bgeu	s1,a5,80003de0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d96:	4741                	li	a4,16
    80003d98:	86a6                	mv	a3,s1
    80003d9a:	fc040613          	addi	a2,s0,-64
    80003d9e:	4581                	li	a1,0
    80003da0:	854a                	mv	a0,s2
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	d76080e7          	jalr	-650(ra) # 80003b18 <readi>
    80003daa:	47c1                	li	a5,16
    80003dac:	fcf518e3          	bne	a0,a5,80003d7c <dirlookup+0x3a>
    if(de.inum == 0)
    80003db0:	fc045783          	lhu	a5,-64(s0)
    80003db4:	dfe1                	beqz	a5,80003d8c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003db6:	fc240593          	addi	a1,s0,-62
    80003dba:	854e                	mv	a0,s3
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	f6c080e7          	jalr	-148(ra) # 80003d28 <namecmp>
    80003dc4:	f561                	bnez	a0,80003d8c <dirlookup+0x4a>
      if(poff)
    80003dc6:	000a0463          	beqz	s4,80003dce <dirlookup+0x8c>
        *poff = off;
    80003dca:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003dce:	fc045583          	lhu	a1,-64(s0)
    80003dd2:	00092503          	lw	a0,0(s2)
    80003dd6:	fffff097          	auipc	ra,0xfffff
    80003dda:	75a080e7          	jalr	1882(ra) # 80003530 <iget>
    80003dde:	a011                	j	80003de2 <dirlookup+0xa0>
  return 0;
    80003de0:	4501                	li	a0,0
}
    80003de2:	70e2                	ld	ra,56(sp)
    80003de4:	7442                	ld	s0,48(sp)
    80003de6:	74a2                	ld	s1,40(sp)
    80003de8:	7902                	ld	s2,32(sp)
    80003dea:	69e2                	ld	s3,24(sp)
    80003dec:	6a42                	ld	s4,16(sp)
    80003dee:	6121                	addi	sp,sp,64
    80003df0:	8082                	ret

0000000080003df2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003df2:	711d                	addi	sp,sp,-96
    80003df4:	ec86                	sd	ra,88(sp)
    80003df6:	e8a2                	sd	s0,80(sp)
    80003df8:	e4a6                	sd	s1,72(sp)
    80003dfa:	e0ca                	sd	s2,64(sp)
    80003dfc:	fc4e                	sd	s3,56(sp)
    80003dfe:	f852                	sd	s4,48(sp)
    80003e00:	f456                	sd	s5,40(sp)
    80003e02:	f05a                	sd	s6,32(sp)
    80003e04:	ec5e                	sd	s7,24(sp)
    80003e06:	e862                	sd	s8,16(sp)
    80003e08:	e466                	sd	s9,8(sp)
    80003e0a:	1080                	addi	s0,sp,96
    80003e0c:	84aa                	mv	s1,a0
    80003e0e:	8b2e                	mv	s6,a1
    80003e10:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e12:	00054703          	lbu	a4,0(a0)
    80003e16:	02f00793          	li	a5,47
    80003e1a:	02f70363          	beq	a4,a5,80003e40 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e1e:	ffffe097          	auipc	ra,0xffffe
    80003e22:	cf2080e7          	jalr	-782(ra) # 80001b10 <myproc>
    80003e26:	15053503          	ld	a0,336(a0)
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	9fc080e7          	jalr	-1540(ra) # 80003826 <idup>
    80003e32:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e34:	02f00913          	li	s2,47
  len = path - s;
    80003e38:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003e3a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e3c:	4c05                	li	s8,1
    80003e3e:	a865                	j	80003ef6 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e40:	4585                	li	a1,1
    80003e42:	4505                	li	a0,1
    80003e44:	fffff097          	auipc	ra,0xfffff
    80003e48:	6ec080e7          	jalr	1772(ra) # 80003530 <iget>
    80003e4c:	89aa                	mv	s3,a0
    80003e4e:	b7dd                	j	80003e34 <namex+0x42>
      iunlockput(ip);
    80003e50:	854e                	mv	a0,s3
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	c74080e7          	jalr	-908(ra) # 80003ac6 <iunlockput>
      return 0;
    80003e5a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e5c:	854e                	mv	a0,s3
    80003e5e:	60e6                	ld	ra,88(sp)
    80003e60:	6446                	ld	s0,80(sp)
    80003e62:	64a6                	ld	s1,72(sp)
    80003e64:	6906                	ld	s2,64(sp)
    80003e66:	79e2                	ld	s3,56(sp)
    80003e68:	7a42                	ld	s4,48(sp)
    80003e6a:	7aa2                	ld	s5,40(sp)
    80003e6c:	7b02                	ld	s6,32(sp)
    80003e6e:	6be2                	ld	s7,24(sp)
    80003e70:	6c42                	ld	s8,16(sp)
    80003e72:	6ca2                	ld	s9,8(sp)
    80003e74:	6125                	addi	sp,sp,96
    80003e76:	8082                	ret
      iunlock(ip);
    80003e78:	854e                	mv	a0,s3
    80003e7a:	00000097          	auipc	ra,0x0
    80003e7e:	aac080e7          	jalr	-1364(ra) # 80003926 <iunlock>
      return ip;
    80003e82:	bfe9                	j	80003e5c <namex+0x6a>
      iunlockput(ip);
    80003e84:	854e                	mv	a0,s3
    80003e86:	00000097          	auipc	ra,0x0
    80003e8a:	c40080e7          	jalr	-960(ra) # 80003ac6 <iunlockput>
      return 0;
    80003e8e:	89d2                	mv	s3,s4
    80003e90:	b7f1                	j	80003e5c <namex+0x6a>
  len = path - s;
    80003e92:	40b48633          	sub	a2,s1,a1
    80003e96:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003e9a:	094cd463          	bge	s9,s4,80003f22 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003e9e:	4639                	li	a2,14
    80003ea0:	8556                	mv	a0,s5
    80003ea2:	ffffd097          	auipc	ra,0xffffd
    80003ea6:	f14080e7          	jalr	-236(ra) # 80000db6 <memmove>
  while(*path == '/')
    80003eaa:	0004c783          	lbu	a5,0(s1)
    80003eae:	01279763          	bne	a5,s2,80003ebc <namex+0xca>
    path++;
    80003eb2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003eb4:	0004c783          	lbu	a5,0(s1)
    80003eb8:	ff278de3          	beq	a5,s2,80003eb2 <namex+0xc0>
    ilock(ip);
    80003ebc:	854e                	mv	a0,s3
    80003ebe:	00000097          	auipc	ra,0x0
    80003ec2:	9a6080e7          	jalr	-1626(ra) # 80003864 <ilock>
    if(ip->type != T_DIR){
    80003ec6:	04499783          	lh	a5,68(s3)
    80003eca:	f98793e3          	bne	a5,s8,80003e50 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ece:	000b0563          	beqz	s6,80003ed8 <namex+0xe6>
    80003ed2:	0004c783          	lbu	a5,0(s1)
    80003ed6:	d3cd                	beqz	a5,80003e78 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ed8:	865e                	mv	a2,s7
    80003eda:	85d6                	mv	a1,s5
    80003edc:	854e                	mv	a0,s3
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	e64080e7          	jalr	-412(ra) # 80003d42 <dirlookup>
    80003ee6:	8a2a                	mv	s4,a0
    80003ee8:	dd51                	beqz	a0,80003e84 <namex+0x92>
    iunlockput(ip);
    80003eea:	854e                	mv	a0,s3
    80003eec:	00000097          	auipc	ra,0x0
    80003ef0:	bda080e7          	jalr	-1062(ra) # 80003ac6 <iunlockput>
    ip = next;
    80003ef4:	89d2                	mv	s3,s4
  while(*path == '/')
    80003ef6:	0004c783          	lbu	a5,0(s1)
    80003efa:	05279763          	bne	a5,s2,80003f48 <namex+0x156>
    path++;
    80003efe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f00:	0004c783          	lbu	a5,0(s1)
    80003f04:	ff278de3          	beq	a5,s2,80003efe <namex+0x10c>
  if(*path == 0)
    80003f08:	c79d                	beqz	a5,80003f36 <namex+0x144>
    path++;
    80003f0a:	85a6                	mv	a1,s1
  len = path - s;
    80003f0c:	8a5e                	mv	s4,s7
    80003f0e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f10:	01278963          	beq	a5,s2,80003f22 <namex+0x130>
    80003f14:	dfbd                	beqz	a5,80003e92 <namex+0xa0>
    path++;
    80003f16:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f18:	0004c783          	lbu	a5,0(s1)
    80003f1c:	ff279ce3          	bne	a5,s2,80003f14 <namex+0x122>
    80003f20:	bf8d                	j	80003e92 <namex+0xa0>
    memmove(name, s, len);
    80003f22:	2601                	sext.w	a2,a2
    80003f24:	8556                	mv	a0,s5
    80003f26:	ffffd097          	auipc	ra,0xffffd
    80003f2a:	e90080e7          	jalr	-368(ra) # 80000db6 <memmove>
    name[len] = 0;
    80003f2e:	9a56                	add	s4,s4,s5
    80003f30:	000a0023          	sb	zero,0(s4)
    80003f34:	bf9d                	j	80003eaa <namex+0xb8>
  if(nameiparent){
    80003f36:	f20b03e3          	beqz	s6,80003e5c <namex+0x6a>
    iput(ip);
    80003f3a:	854e                	mv	a0,s3
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	ae2080e7          	jalr	-1310(ra) # 80003a1e <iput>
    return 0;
    80003f44:	4981                	li	s3,0
    80003f46:	bf19                	j	80003e5c <namex+0x6a>
  if(*path == 0)
    80003f48:	d7fd                	beqz	a5,80003f36 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f4a:	0004c783          	lbu	a5,0(s1)
    80003f4e:	85a6                	mv	a1,s1
    80003f50:	b7d1                	j	80003f14 <namex+0x122>

0000000080003f52 <dirlink>:
{
    80003f52:	7139                	addi	sp,sp,-64
    80003f54:	fc06                	sd	ra,56(sp)
    80003f56:	f822                	sd	s0,48(sp)
    80003f58:	f426                	sd	s1,40(sp)
    80003f5a:	f04a                	sd	s2,32(sp)
    80003f5c:	ec4e                	sd	s3,24(sp)
    80003f5e:	e852                	sd	s4,16(sp)
    80003f60:	0080                	addi	s0,sp,64
    80003f62:	892a                	mv	s2,a0
    80003f64:	8a2e                	mv	s4,a1
    80003f66:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f68:	4601                	li	a2,0
    80003f6a:	00000097          	auipc	ra,0x0
    80003f6e:	dd8080e7          	jalr	-552(ra) # 80003d42 <dirlookup>
    80003f72:	e93d                	bnez	a0,80003fe8 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f74:	04c92483          	lw	s1,76(s2)
    80003f78:	c49d                	beqz	s1,80003fa6 <dirlink+0x54>
    80003f7a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f7c:	4741                	li	a4,16
    80003f7e:	86a6                	mv	a3,s1
    80003f80:	fc040613          	addi	a2,s0,-64
    80003f84:	4581                	li	a1,0
    80003f86:	854a                	mv	a0,s2
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	b90080e7          	jalr	-1136(ra) # 80003b18 <readi>
    80003f90:	47c1                	li	a5,16
    80003f92:	06f51163          	bne	a0,a5,80003ff4 <dirlink+0xa2>
    if(de.inum == 0)
    80003f96:	fc045783          	lhu	a5,-64(s0)
    80003f9a:	c791                	beqz	a5,80003fa6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f9c:	24c1                	addiw	s1,s1,16
    80003f9e:	04c92783          	lw	a5,76(s2)
    80003fa2:	fcf4ede3          	bltu	s1,a5,80003f7c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fa6:	4639                	li	a2,14
    80003fa8:	85d2                	mv	a1,s4
    80003faa:	fc240513          	addi	a0,s0,-62
    80003fae:	ffffd097          	auipc	ra,0xffffd
    80003fb2:	ec0080e7          	jalr	-320(ra) # 80000e6e <strncpy>
  de.inum = inum;
    80003fb6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fba:	4741                	li	a4,16
    80003fbc:	86a6                	mv	a3,s1
    80003fbe:	fc040613          	addi	a2,s0,-64
    80003fc2:	4581                	li	a1,0
    80003fc4:	854a                	mv	a0,s2
    80003fc6:	00000097          	auipc	ra,0x0
    80003fca:	c48080e7          	jalr	-952(ra) # 80003c0e <writei>
    80003fce:	872a                	mv	a4,a0
    80003fd0:	47c1                	li	a5,16
  return 0;
    80003fd2:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fd4:	02f71863          	bne	a4,a5,80004004 <dirlink+0xb2>
}
    80003fd8:	70e2                	ld	ra,56(sp)
    80003fda:	7442                	ld	s0,48(sp)
    80003fdc:	74a2                	ld	s1,40(sp)
    80003fde:	7902                	ld	s2,32(sp)
    80003fe0:	69e2                	ld	s3,24(sp)
    80003fe2:	6a42                	ld	s4,16(sp)
    80003fe4:	6121                	addi	sp,sp,64
    80003fe6:	8082                	ret
    iput(ip);
    80003fe8:	00000097          	auipc	ra,0x0
    80003fec:	a36080e7          	jalr	-1482(ra) # 80003a1e <iput>
    return -1;
    80003ff0:	557d                	li	a0,-1
    80003ff2:	b7dd                	j	80003fd8 <dirlink+0x86>
      panic("dirlink read");
    80003ff4:	00004517          	auipc	a0,0x4
    80003ff8:	70450513          	addi	a0,a0,1796 # 800086f8 <syscalls+0x1d8>
    80003ffc:	ffffc097          	auipc	ra,0xffffc
    80004000:	54c080e7          	jalr	1356(ra) # 80000548 <panic>
    panic("dirlink");
    80004004:	00005517          	auipc	a0,0x5
    80004008:	80c50513          	addi	a0,a0,-2036 # 80008810 <syscalls+0x2f0>
    8000400c:	ffffc097          	auipc	ra,0xffffc
    80004010:	53c080e7          	jalr	1340(ra) # 80000548 <panic>

0000000080004014 <namei>:

struct inode*
namei(char *path)
{
    80004014:	1101                	addi	sp,sp,-32
    80004016:	ec06                	sd	ra,24(sp)
    80004018:	e822                	sd	s0,16(sp)
    8000401a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000401c:	fe040613          	addi	a2,s0,-32
    80004020:	4581                	li	a1,0
    80004022:	00000097          	auipc	ra,0x0
    80004026:	dd0080e7          	jalr	-560(ra) # 80003df2 <namex>
}
    8000402a:	60e2                	ld	ra,24(sp)
    8000402c:	6442                	ld	s0,16(sp)
    8000402e:	6105                	addi	sp,sp,32
    80004030:	8082                	ret

0000000080004032 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004032:	1141                	addi	sp,sp,-16
    80004034:	e406                	sd	ra,8(sp)
    80004036:	e022                	sd	s0,0(sp)
    80004038:	0800                	addi	s0,sp,16
    8000403a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000403c:	4585                	li	a1,1
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	db4080e7          	jalr	-588(ra) # 80003df2 <namex>
}
    80004046:	60a2                	ld	ra,8(sp)
    80004048:	6402                	ld	s0,0(sp)
    8000404a:	0141                	addi	sp,sp,16
    8000404c:	8082                	ret

000000008000404e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000404e:	1101                	addi	sp,sp,-32
    80004050:	ec06                	sd	ra,24(sp)
    80004052:	e822                	sd	s0,16(sp)
    80004054:	e426                	sd	s1,8(sp)
    80004056:	e04a                	sd	s2,0(sp)
    80004058:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000405a:	0001e917          	auipc	s2,0x1e
    8000405e:	aae90913          	addi	s2,s2,-1362 # 80021b08 <log>
    80004062:	01892583          	lw	a1,24(s2)
    80004066:	02892503          	lw	a0,40(s2)
    8000406a:	fffff097          	auipc	ra,0xfffff
    8000406e:	ff8080e7          	jalr	-8(ra) # 80003062 <bread>
    80004072:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004074:	02c92683          	lw	a3,44(s2)
    80004078:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000407a:	02d05763          	blez	a3,800040a8 <write_head+0x5a>
    8000407e:	0001e797          	auipc	a5,0x1e
    80004082:	aba78793          	addi	a5,a5,-1350 # 80021b38 <log+0x30>
    80004086:	05c50713          	addi	a4,a0,92
    8000408a:	36fd                	addiw	a3,a3,-1
    8000408c:	1682                	slli	a3,a3,0x20
    8000408e:	9281                	srli	a3,a3,0x20
    80004090:	068a                	slli	a3,a3,0x2
    80004092:	0001e617          	auipc	a2,0x1e
    80004096:	aaa60613          	addi	a2,a2,-1366 # 80021b3c <log+0x34>
    8000409a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000409c:	4390                	lw	a2,0(a5)
    8000409e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040a0:	0791                	addi	a5,a5,4
    800040a2:	0711                	addi	a4,a4,4
    800040a4:	fed79ce3          	bne	a5,a3,8000409c <write_head+0x4e>
  }
  bwrite(buf);
    800040a8:	8526                	mv	a0,s1
    800040aa:	fffff097          	auipc	ra,0xfffff
    800040ae:	0aa080e7          	jalr	170(ra) # 80003154 <bwrite>
  brelse(buf);
    800040b2:	8526                	mv	a0,s1
    800040b4:	fffff097          	auipc	ra,0xfffff
    800040b8:	0de080e7          	jalr	222(ra) # 80003192 <brelse>
}
    800040bc:	60e2                	ld	ra,24(sp)
    800040be:	6442                	ld	s0,16(sp)
    800040c0:	64a2                	ld	s1,8(sp)
    800040c2:	6902                	ld	s2,0(sp)
    800040c4:	6105                	addi	sp,sp,32
    800040c6:	8082                	ret

00000000800040c8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040c8:	0001e797          	auipc	a5,0x1e
    800040cc:	a6c7a783          	lw	a5,-1428(a5) # 80021b34 <log+0x2c>
    800040d0:	0af05663          	blez	a5,8000417c <install_trans+0xb4>
{
    800040d4:	7139                	addi	sp,sp,-64
    800040d6:	fc06                	sd	ra,56(sp)
    800040d8:	f822                	sd	s0,48(sp)
    800040da:	f426                	sd	s1,40(sp)
    800040dc:	f04a                	sd	s2,32(sp)
    800040de:	ec4e                	sd	s3,24(sp)
    800040e0:	e852                	sd	s4,16(sp)
    800040e2:	e456                	sd	s5,8(sp)
    800040e4:	0080                	addi	s0,sp,64
    800040e6:	0001ea97          	auipc	s5,0x1e
    800040ea:	a52a8a93          	addi	s5,s5,-1454 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040ee:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040f0:	0001e997          	auipc	s3,0x1e
    800040f4:	a1898993          	addi	s3,s3,-1512 # 80021b08 <log>
    800040f8:	0189a583          	lw	a1,24(s3)
    800040fc:	014585bb          	addw	a1,a1,s4
    80004100:	2585                	addiw	a1,a1,1
    80004102:	0289a503          	lw	a0,40(s3)
    80004106:	fffff097          	auipc	ra,0xfffff
    8000410a:	f5c080e7          	jalr	-164(ra) # 80003062 <bread>
    8000410e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004110:	000aa583          	lw	a1,0(s5)
    80004114:	0289a503          	lw	a0,40(s3)
    80004118:	fffff097          	auipc	ra,0xfffff
    8000411c:	f4a080e7          	jalr	-182(ra) # 80003062 <bread>
    80004120:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004122:	40000613          	li	a2,1024
    80004126:	05890593          	addi	a1,s2,88
    8000412a:	05850513          	addi	a0,a0,88
    8000412e:	ffffd097          	auipc	ra,0xffffd
    80004132:	c88080e7          	jalr	-888(ra) # 80000db6 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004136:	8526                	mv	a0,s1
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	01c080e7          	jalr	28(ra) # 80003154 <bwrite>
    bunpin(dbuf);
    80004140:	8526                	mv	a0,s1
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	12a080e7          	jalr	298(ra) # 8000326c <bunpin>
    brelse(lbuf);
    8000414a:	854a                	mv	a0,s2
    8000414c:	fffff097          	auipc	ra,0xfffff
    80004150:	046080e7          	jalr	70(ra) # 80003192 <brelse>
    brelse(dbuf);
    80004154:	8526                	mv	a0,s1
    80004156:	fffff097          	auipc	ra,0xfffff
    8000415a:	03c080e7          	jalr	60(ra) # 80003192 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000415e:	2a05                	addiw	s4,s4,1
    80004160:	0a91                	addi	s5,s5,4
    80004162:	02c9a783          	lw	a5,44(s3)
    80004166:	f8fa49e3          	blt	s4,a5,800040f8 <install_trans+0x30>
}
    8000416a:	70e2                	ld	ra,56(sp)
    8000416c:	7442                	ld	s0,48(sp)
    8000416e:	74a2                	ld	s1,40(sp)
    80004170:	7902                	ld	s2,32(sp)
    80004172:	69e2                	ld	s3,24(sp)
    80004174:	6a42                	ld	s4,16(sp)
    80004176:	6aa2                	ld	s5,8(sp)
    80004178:	6121                	addi	sp,sp,64
    8000417a:	8082                	ret
    8000417c:	8082                	ret

000000008000417e <initlog>:
{
    8000417e:	7179                	addi	sp,sp,-48
    80004180:	f406                	sd	ra,40(sp)
    80004182:	f022                	sd	s0,32(sp)
    80004184:	ec26                	sd	s1,24(sp)
    80004186:	e84a                	sd	s2,16(sp)
    80004188:	e44e                	sd	s3,8(sp)
    8000418a:	1800                	addi	s0,sp,48
    8000418c:	892a                	mv	s2,a0
    8000418e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004190:	0001e497          	auipc	s1,0x1e
    80004194:	97848493          	addi	s1,s1,-1672 # 80021b08 <log>
    80004198:	00004597          	auipc	a1,0x4
    8000419c:	57058593          	addi	a1,a1,1392 # 80008708 <syscalls+0x1e8>
    800041a0:	8526                	mv	a0,s1
    800041a2:	ffffd097          	auipc	ra,0xffffd
    800041a6:	a28080e7          	jalr	-1496(ra) # 80000bca <initlock>
  log.start = sb->logstart;
    800041aa:	0149a583          	lw	a1,20(s3)
    800041ae:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041b0:	0109a783          	lw	a5,16(s3)
    800041b4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041b6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041ba:	854a                	mv	a0,s2
    800041bc:	fffff097          	auipc	ra,0xfffff
    800041c0:	ea6080e7          	jalr	-346(ra) # 80003062 <bread>
  log.lh.n = lh->n;
    800041c4:	4d3c                	lw	a5,88(a0)
    800041c6:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041c8:	02f05563          	blez	a5,800041f2 <initlog+0x74>
    800041cc:	05c50713          	addi	a4,a0,92
    800041d0:	0001e697          	auipc	a3,0x1e
    800041d4:	96868693          	addi	a3,a3,-1688 # 80021b38 <log+0x30>
    800041d8:	37fd                	addiw	a5,a5,-1
    800041da:	1782                	slli	a5,a5,0x20
    800041dc:	9381                	srli	a5,a5,0x20
    800041de:	078a                	slli	a5,a5,0x2
    800041e0:	06050613          	addi	a2,a0,96
    800041e4:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800041e6:	4310                	lw	a2,0(a4)
    800041e8:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800041ea:	0711                	addi	a4,a4,4
    800041ec:	0691                	addi	a3,a3,4
    800041ee:	fef71ce3          	bne	a4,a5,800041e6 <initlog+0x68>
  brelse(buf);
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	fa0080e7          	jalr	-96(ra) # 80003192 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800041fa:	00000097          	auipc	ra,0x0
    800041fe:	ece080e7          	jalr	-306(ra) # 800040c8 <install_trans>
  log.lh.n = 0;
    80004202:	0001e797          	auipc	a5,0x1e
    80004206:	9207a923          	sw	zero,-1742(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    8000420a:	00000097          	auipc	ra,0x0
    8000420e:	e44080e7          	jalr	-444(ra) # 8000404e <write_head>
}
    80004212:	70a2                	ld	ra,40(sp)
    80004214:	7402                	ld	s0,32(sp)
    80004216:	64e2                	ld	s1,24(sp)
    80004218:	6942                	ld	s2,16(sp)
    8000421a:	69a2                	ld	s3,8(sp)
    8000421c:	6145                	addi	sp,sp,48
    8000421e:	8082                	ret

0000000080004220 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004220:	1101                	addi	sp,sp,-32
    80004222:	ec06                	sd	ra,24(sp)
    80004224:	e822                	sd	s0,16(sp)
    80004226:	e426                	sd	s1,8(sp)
    80004228:	e04a                	sd	s2,0(sp)
    8000422a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000422c:	0001e517          	auipc	a0,0x1e
    80004230:	8dc50513          	addi	a0,a0,-1828 # 80021b08 <log>
    80004234:	ffffd097          	auipc	ra,0xffffd
    80004238:	a26080e7          	jalr	-1498(ra) # 80000c5a <acquire>
  while(1){
    if(log.committing){
    8000423c:	0001e497          	auipc	s1,0x1e
    80004240:	8cc48493          	addi	s1,s1,-1844 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004244:	4979                	li	s2,30
    80004246:	a039                	j	80004254 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004248:	85a6                	mv	a1,s1
    8000424a:	8526                	mv	a0,s1
    8000424c:	ffffe097          	auipc	ra,0xffffe
    80004250:	0d8080e7          	jalr	216(ra) # 80002324 <sleep>
    if(log.committing){
    80004254:	50dc                	lw	a5,36(s1)
    80004256:	fbed                	bnez	a5,80004248 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004258:	509c                	lw	a5,32(s1)
    8000425a:	0017871b          	addiw	a4,a5,1
    8000425e:	0007069b          	sext.w	a3,a4
    80004262:	0027179b          	slliw	a5,a4,0x2
    80004266:	9fb9                	addw	a5,a5,a4
    80004268:	0017979b          	slliw	a5,a5,0x1
    8000426c:	54d8                	lw	a4,44(s1)
    8000426e:	9fb9                	addw	a5,a5,a4
    80004270:	00f95963          	bge	s2,a5,80004282 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004274:	85a6                	mv	a1,s1
    80004276:	8526                	mv	a0,s1
    80004278:	ffffe097          	auipc	ra,0xffffe
    8000427c:	0ac080e7          	jalr	172(ra) # 80002324 <sleep>
    80004280:	bfd1                	j	80004254 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004282:	0001e517          	auipc	a0,0x1e
    80004286:	88650513          	addi	a0,a0,-1914 # 80021b08 <log>
    8000428a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000428c:	ffffd097          	auipc	ra,0xffffd
    80004290:	a82080e7          	jalr	-1406(ra) # 80000d0e <release>
      break;
    }
  }
}
    80004294:	60e2                	ld	ra,24(sp)
    80004296:	6442                	ld	s0,16(sp)
    80004298:	64a2                	ld	s1,8(sp)
    8000429a:	6902                	ld	s2,0(sp)
    8000429c:	6105                	addi	sp,sp,32
    8000429e:	8082                	ret

00000000800042a0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042a0:	7139                	addi	sp,sp,-64
    800042a2:	fc06                	sd	ra,56(sp)
    800042a4:	f822                	sd	s0,48(sp)
    800042a6:	f426                	sd	s1,40(sp)
    800042a8:	f04a                	sd	s2,32(sp)
    800042aa:	ec4e                	sd	s3,24(sp)
    800042ac:	e852                	sd	s4,16(sp)
    800042ae:	e456                	sd	s5,8(sp)
    800042b0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042b2:	0001e497          	auipc	s1,0x1e
    800042b6:	85648493          	addi	s1,s1,-1962 # 80021b08 <log>
    800042ba:	8526                	mv	a0,s1
    800042bc:	ffffd097          	auipc	ra,0xffffd
    800042c0:	99e080e7          	jalr	-1634(ra) # 80000c5a <acquire>
  log.outstanding -= 1;
    800042c4:	509c                	lw	a5,32(s1)
    800042c6:	37fd                	addiw	a5,a5,-1
    800042c8:	0007891b          	sext.w	s2,a5
    800042cc:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042ce:	50dc                	lw	a5,36(s1)
    800042d0:	efb9                	bnez	a5,8000432e <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800042d2:	06091663          	bnez	s2,8000433e <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800042d6:	0001e497          	auipc	s1,0x1e
    800042da:	83248493          	addi	s1,s1,-1998 # 80021b08 <log>
    800042de:	4785                	li	a5,1
    800042e0:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042e2:	8526                	mv	a0,s1
    800042e4:	ffffd097          	auipc	ra,0xffffd
    800042e8:	a2a080e7          	jalr	-1494(ra) # 80000d0e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042ec:	54dc                	lw	a5,44(s1)
    800042ee:	06f04763          	bgtz	a5,8000435c <end_op+0xbc>
    acquire(&log.lock);
    800042f2:	0001e497          	auipc	s1,0x1e
    800042f6:	81648493          	addi	s1,s1,-2026 # 80021b08 <log>
    800042fa:	8526                	mv	a0,s1
    800042fc:	ffffd097          	auipc	ra,0xffffd
    80004300:	95e080e7          	jalr	-1698(ra) # 80000c5a <acquire>
    log.committing = 0;
    80004304:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004308:	8526                	mv	a0,s1
    8000430a:	ffffe097          	auipc	ra,0xffffe
    8000430e:	1a0080e7          	jalr	416(ra) # 800024aa <wakeup>
    release(&log.lock);
    80004312:	8526                	mv	a0,s1
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	9fa080e7          	jalr	-1542(ra) # 80000d0e <release>
}
    8000431c:	70e2                	ld	ra,56(sp)
    8000431e:	7442                	ld	s0,48(sp)
    80004320:	74a2                	ld	s1,40(sp)
    80004322:	7902                	ld	s2,32(sp)
    80004324:	69e2                	ld	s3,24(sp)
    80004326:	6a42                	ld	s4,16(sp)
    80004328:	6aa2                	ld	s5,8(sp)
    8000432a:	6121                	addi	sp,sp,64
    8000432c:	8082                	ret
    panic("log.committing");
    8000432e:	00004517          	auipc	a0,0x4
    80004332:	3e250513          	addi	a0,a0,994 # 80008710 <syscalls+0x1f0>
    80004336:	ffffc097          	auipc	ra,0xffffc
    8000433a:	212080e7          	jalr	530(ra) # 80000548 <panic>
    wakeup(&log);
    8000433e:	0001d497          	auipc	s1,0x1d
    80004342:	7ca48493          	addi	s1,s1,1994 # 80021b08 <log>
    80004346:	8526                	mv	a0,s1
    80004348:	ffffe097          	auipc	ra,0xffffe
    8000434c:	162080e7          	jalr	354(ra) # 800024aa <wakeup>
  release(&log.lock);
    80004350:	8526                	mv	a0,s1
    80004352:	ffffd097          	auipc	ra,0xffffd
    80004356:	9bc080e7          	jalr	-1604(ra) # 80000d0e <release>
  if(do_commit){
    8000435a:	b7c9                	j	8000431c <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000435c:	0001da97          	auipc	s5,0x1d
    80004360:	7dca8a93          	addi	s5,s5,2012 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004364:	0001da17          	auipc	s4,0x1d
    80004368:	7a4a0a13          	addi	s4,s4,1956 # 80021b08 <log>
    8000436c:	018a2583          	lw	a1,24(s4)
    80004370:	012585bb          	addw	a1,a1,s2
    80004374:	2585                	addiw	a1,a1,1
    80004376:	028a2503          	lw	a0,40(s4)
    8000437a:	fffff097          	auipc	ra,0xfffff
    8000437e:	ce8080e7          	jalr	-792(ra) # 80003062 <bread>
    80004382:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004384:	000aa583          	lw	a1,0(s5)
    80004388:	028a2503          	lw	a0,40(s4)
    8000438c:	fffff097          	auipc	ra,0xfffff
    80004390:	cd6080e7          	jalr	-810(ra) # 80003062 <bread>
    80004394:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004396:	40000613          	li	a2,1024
    8000439a:	05850593          	addi	a1,a0,88
    8000439e:	05848513          	addi	a0,s1,88
    800043a2:	ffffd097          	auipc	ra,0xffffd
    800043a6:	a14080e7          	jalr	-1516(ra) # 80000db6 <memmove>
    bwrite(to);  // write the log
    800043aa:	8526                	mv	a0,s1
    800043ac:	fffff097          	auipc	ra,0xfffff
    800043b0:	da8080e7          	jalr	-600(ra) # 80003154 <bwrite>
    brelse(from);
    800043b4:	854e                	mv	a0,s3
    800043b6:	fffff097          	auipc	ra,0xfffff
    800043ba:	ddc080e7          	jalr	-548(ra) # 80003192 <brelse>
    brelse(to);
    800043be:	8526                	mv	a0,s1
    800043c0:	fffff097          	auipc	ra,0xfffff
    800043c4:	dd2080e7          	jalr	-558(ra) # 80003192 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043c8:	2905                	addiw	s2,s2,1
    800043ca:	0a91                	addi	s5,s5,4
    800043cc:	02ca2783          	lw	a5,44(s4)
    800043d0:	f8f94ee3          	blt	s2,a5,8000436c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043d4:	00000097          	auipc	ra,0x0
    800043d8:	c7a080e7          	jalr	-902(ra) # 8000404e <write_head>
    install_trans(); // Now install writes to home locations
    800043dc:	00000097          	auipc	ra,0x0
    800043e0:	cec080e7          	jalr	-788(ra) # 800040c8 <install_trans>
    log.lh.n = 0;
    800043e4:	0001d797          	auipc	a5,0x1d
    800043e8:	7407a823          	sw	zero,1872(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800043ec:	00000097          	auipc	ra,0x0
    800043f0:	c62080e7          	jalr	-926(ra) # 8000404e <write_head>
    800043f4:	bdfd                	j	800042f2 <end_op+0x52>

00000000800043f6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043f6:	1101                	addi	sp,sp,-32
    800043f8:	ec06                	sd	ra,24(sp)
    800043fa:	e822                	sd	s0,16(sp)
    800043fc:	e426                	sd	s1,8(sp)
    800043fe:	e04a                	sd	s2,0(sp)
    80004400:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004402:	0001d717          	auipc	a4,0x1d
    80004406:	73272703          	lw	a4,1842(a4) # 80021b34 <log+0x2c>
    8000440a:	47f5                	li	a5,29
    8000440c:	08e7c063          	blt	a5,a4,8000448c <log_write+0x96>
    80004410:	84aa                	mv	s1,a0
    80004412:	0001d797          	auipc	a5,0x1d
    80004416:	7127a783          	lw	a5,1810(a5) # 80021b24 <log+0x1c>
    8000441a:	37fd                	addiw	a5,a5,-1
    8000441c:	06f75863          	bge	a4,a5,8000448c <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004420:	0001d797          	auipc	a5,0x1d
    80004424:	7087a783          	lw	a5,1800(a5) # 80021b28 <log+0x20>
    80004428:	06f05a63          	blez	a5,8000449c <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000442c:	0001d917          	auipc	s2,0x1d
    80004430:	6dc90913          	addi	s2,s2,1756 # 80021b08 <log>
    80004434:	854a                	mv	a0,s2
    80004436:	ffffd097          	auipc	ra,0xffffd
    8000443a:	824080e7          	jalr	-2012(ra) # 80000c5a <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000443e:	02c92603          	lw	a2,44(s2)
    80004442:	06c05563          	blez	a2,800044ac <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004446:	44cc                	lw	a1,12(s1)
    80004448:	0001d717          	auipc	a4,0x1d
    8000444c:	6f070713          	addi	a4,a4,1776 # 80021b38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004450:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004452:	4314                	lw	a3,0(a4)
    80004454:	04b68d63          	beq	a3,a1,800044ae <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004458:	2785                	addiw	a5,a5,1
    8000445a:	0711                	addi	a4,a4,4
    8000445c:	fec79be3          	bne	a5,a2,80004452 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004460:	0621                	addi	a2,a2,8
    80004462:	060a                	slli	a2,a2,0x2
    80004464:	0001d797          	auipc	a5,0x1d
    80004468:	6a478793          	addi	a5,a5,1700 # 80021b08 <log>
    8000446c:	963e                	add	a2,a2,a5
    8000446e:	44dc                	lw	a5,12(s1)
    80004470:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004472:	8526                	mv	a0,s1
    80004474:	fffff097          	auipc	ra,0xfffff
    80004478:	dbc080e7          	jalr	-580(ra) # 80003230 <bpin>
    log.lh.n++;
    8000447c:	0001d717          	auipc	a4,0x1d
    80004480:	68c70713          	addi	a4,a4,1676 # 80021b08 <log>
    80004484:	575c                	lw	a5,44(a4)
    80004486:	2785                	addiw	a5,a5,1
    80004488:	d75c                	sw	a5,44(a4)
    8000448a:	a83d                	j	800044c8 <log_write+0xd2>
    panic("too big a transaction");
    8000448c:	00004517          	auipc	a0,0x4
    80004490:	29450513          	addi	a0,a0,660 # 80008720 <syscalls+0x200>
    80004494:	ffffc097          	auipc	ra,0xffffc
    80004498:	0b4080e7          	jalr	180(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    8000449c:	00004517          	auipc	a0,0x4
    800044a0:	29c50513          	addi	a0,a0,668 # 80008738 <syscalls+0x218>
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	0a4080e7          	jalr	164(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800044ac:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800044ae:	00878713          	addi	a4,a5,8
    800044b2:	00271693          	slli	a3,a4,0x2
    800044b6:	0001d717          	auipc	a4,0x1d
    800044ba:	65270713          	addi	a4,a4,1618 # 80021b08 <log>
    800044be:	9736                	add	a4,a4,a3
    800044c0:	44d4                	lw	a3,12(s1)
    800044c2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044c4:	faf607e3          	beq	a2,a5,80004472 <log_write+0x7c>
  }
  release(&log.lock);
    800044c8:	0001d517          	auipc	a0,0x1d
    800044cc:	64050513          	addi	a0,a0,1600 # 80021b08 <log>
    800044d0:	ffffd097          	auipc	ra,0xffffd
    800044d4:	83e080e7          	jalr	-1986(ra) # 80000d0e <release>
}
    800044d8:	60e2                	ld	ra,24(sp)
    800044da:	6442                	ld	s0,16(sp)
    800044dc:	64a2                	ld	s1,8(sp)
    800044de:	6902                	ld	s2,0(sp)
    800044e0:	6105                	addi	sp,sp,32
    800044e2:	8082                	ret

00000000800044e4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044e4:	1101                	addi	sp,sp,-32
    800044e6:	ec06                	sd	ra,24(sp)
    800044e8:	e822                	sd	s0,16(sp)
    800044ea:	e426                	sd	s1,8(sp)
    800044ec:	e04a                	sd	s2,0(sp)
    800044ee:	1000                	addi	s0,sp,32
    800044f0:	84aa                	mv	s1,a0
    800044f2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044f4:	00004597          	auipc	a1,0x4
    800044f8:	26458593          	addi	a1,a1,612 # 80008758 <syscalls+0x238>
    800044fc:	0521                	addi	a0,a0,8
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	6cc080e7          	jalr	1740(ra) # 80000bca <initlock>
  lk->name = name;
    80004506:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000450a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000450e:	0204a423          	sw	zero,40(s1)
}
    80004512:	60e2                	ld	ra,24(sp)
    80004514:	6442                	ld	s0,16(sp)
    80004516:	64a2                	ld	s1,8(sp)
    80004518:	6902                	ld	s2,0(sp)
    8000451a:	6105                	addi	sp,sp,32
    8000451c:	8082                	ret

000000008000451e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000451e:	1101                	addi	sp,sp,-32
    80004520:	ec06                	sd	ra,24(sp)
    80004522:	e822                	sd	s0,16(sp)
    80004524:	e426                	sd	s1,8(sp)
    80004526:	e04a                	sd	s2,0(sp)
    80004528:	1000                	addi	s0,sp,32
    8000452a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000452c:	00850913          	addi	s2,a0,8
    80004530:	854a                	mv	a0,s2
    80004532:	ffffc097          	auipc	ra,0xffffc
    80004536:	728080e7          	jalr	1832(ra) # 80000c5a <acquire>
  while (lk->locked) {
    8000453a:	409c                	lw	a5,0(s1)
    8000453c:	cb89                	beqz	a5,8000454e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000453e:	85ca                	mv	a1,s2
    80004540:	8526                	mv	a0,s1
    80004542:	ffffe097          	auipc	ra,0xffffe
    80004546:	de2080e7          	jalr	-542(ra) # 80002324 <sleep>
  while (lk->locked) {
    8000454a:	409c                	lw	a5,0(s1)
    8000454c:	fbed                	bnez	a5,8000453e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000454e:	4785                	li	a5,1
    80004550:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004552:	ffffd097          	auipc	ra,0xffffd
    80004556:	5be080e7          	jalr	1470(ra) # 80001b10 <myproc>
    8000455a:	5d1c                	lw	a5,56(a0)
    8000455c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000455e:	854a                	mv	a0,s2
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	7ae080e7          	jalr	1966(ra) # 80000d0e <release>
}
    80004568:	60e2                	ld	ra,24(sp)
    8000456a:	6442                	ld	s0,16(sp)
    8000456c:	64a2                	ld	s1,8(sp)
    8000456e:	6902                	ld	s2,0(sp)
    80004570:	6105                	addi	sp,sp,32
    80004572:	8082                	ret

0000000080004574 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004574:	1101                	addi	sp,sp,-32
    80004576:	ec06                	sd	ra,24(sp)
    80004578:	e822                	sd	s0,16(sp)
    8000457a:	e426                	sd	s1,8(sp)
    8000457c:	e04a                	sd	s2,0(sp)
    8000457e:	1000                	addi	s0,sp,32
    80004580:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004582:	00850913          	addi	s2,a0,8
    80004586:	854a                	mv	a0,s2
    80004588:	ffffc097          	auipc	ra,0xffffc
    8000458c:	6d2080e7          	jalr	1746(ra) # 80000c5a <acquire>
  lk->locked = 0;
    80004590:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004594:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004598:	8526                	mv	a0,s1
    8000459a:	ffffe097          	auipc	ra,0xffffe
    8000459e:	f10080e7          	jalr	-240(ra) # 800024aa <wakeup>
  release(&lk->lk);
    800045a2:	854a                	mv	a0,s2
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	76a080e7          	jalr	1898(ra) # 80000d0e <release>
}
    800045ac:	60e2                	ld	ra,24(sp)
    800045ae:	6442                	ld	s0,16(sp)
    800045b0:	64a2                	ld	s1,8(sp)
    800045b2:	6902                	ld	s2,0(sp)
    800045b4:	6105                	addi	sp,sp,32
    800045b6:	8082                	ret

00000000800045b8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045b8:	7179                	addi	sp,sp,-48
    800045ba:	f406                	sd	ra,40(sp)
    800045bc:	f022                	sd	s0,32(sp)
    800045be:	ec26                	sd	s1,24(sp)
    800045c0:	e84a                	sd	s2,16(sp)
    800045c2:	e44e                	sd	s3,8(sp)
    800045c4:	1800                	addi	s0,sp,48
    800045c6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045c8:	00850913          	addi	s2,a0,8
    800045cc:	854a                	mv	a0,s2
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	68c080e7          	jalr	1676(ra) # 80000c5a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045d6:	409c                	lw	a5,0(s1)
    800045d8:	ef99                	bnez	a5,800045f6 <holdingsleep+0x3e>
    800045da:	4481                	li	s1,0
  release(&lk->lk);
    800045dc:	854a                	mv	a0,s2
    800045de:	ffffc097          	auipc	ra,0xffffc
    800045e2:	730080e7          	jalr	1840(ra) # 80000d0e <release>
  return r;
}
    800045e6:	8526                	mv	a0,s1
    800045e8:	70a2                	ld	ra,40(sp)
    800045ea:	7402                	ld	s0,32(sp)
    800045ec:	64e2                	ld	s1,24(sp)
    800045ee:	6942                	ld	s2,16(sp)
    800045f0:	69a2                	ld	s3,8(sp)
    800045f2:	6145                	addi	sp,sp,48
    800045f4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045f6:	0284a983          	lw	s3,40(s1)
    800045fa:	ffffd097          	auipc	ra,0xffffd
    800045fe:	516080e7          	jalr	1302(ra) # 80001b10 <myproc>
    80004602:	5d04                	lw	s1,56(a0)
    80004604:	413484b3          	sub	s1,s1,s3
    80004608:	0014b493          	seqz	s1,s1
    8000460c:	bfc1                	j	800045dc <holdingsleep+0x24>

000000008000460e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000460e:	1141                	addi	sp,sp,-16
    80004610:	e406                	sd	ra,8(sp)
    80004612:	e022                	sd	s0,0(sp)
    80004614:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004616:	00004597          	auipc	a1,0x4
    8000461a:	15258593          	addi	a1,a1,338 # 80008768 <syscalls+0x248>
    8000461e:	0001d517          	auipc	a0,0x1d
    80004622:	63250513          	addi	a0,a0,1586 # 80021c50 <ftable>
    80004626:	ffffc097          	auipc	ra,0xffffc
    8000462a:	5a4080e7          	jalr	1444(ra) # 80000bca <initlock>
}
    8000462e:	60a2                	ld	ra,8(sp)
    80004630:	6402                	ld	s0,0(sp)
    80004632:	0141                	addi	sp,sp,16
    80004634:	8082                	ret

0000000080004636 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004636:	1101                	addi	sp,sp,-32
    80004638:	ec06                	sd	ra,24(sp)
    8000463a:	e822                	sd	s0,16(sp)
    8000463c:	e426                	sd	s1,8(sp)
    8000463e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004640:	0001d517          	auipc	a0,0x1d
    80004644:	61050513          	addi	a0,a0,1552 # 80021c50 <ftable>
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	612080e7          	jalr	1554(ra) # 80000c5a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004650:	0001d497          	auipc	s1,0x1d
    80004654:	61848493          	addi	s1,s1,1560 # 80021c68 <ftable+0x18>
    80004658:	0001e717          	auipc	a4,0x1e
    8000465c:	5b070713          	addi	a4,a4,1456 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    80004660:	40dc                	lw	a5,4(s1)
    80004662:	cf99                	beqz	a5,80004680 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004664:	02848493          	addi	s1,s1,40
    80004668:	fee49ce3          	bne	s1,a4,80004660 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000466c:	0001d517          	auipc	a0,0x1d
    80004670:	5e450513          	addi	a0,a0,1508 # 80021c50 <ftable>
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	69a080e7          	jalr	1690(ra) # 80000d0e <release>
  return 0;
    8000467c:	4481                	li	s1,0
    8000467e:	a819                	j	80004694 <filealloc+0x5e>
      f->ref = 1;
    80004680:	4785                	li	a5,1
    80004682:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004684:	0001d517          	auipc	a0,0x1d
    80004688:	5cc50513          	addi	a0,a0,1484 # 80021c50 <ftable>
    8000468c:	ffffc097          	auipc	ra,0xffffc
    80004690:	682080e7          	jalr	1666(ra) # 80000d0e <release>
}
    80004694:	8526                	mv	a0,s1
    80004696:	60e2                	ld	ra,24(sp)
    80004698:	6442                	ld	s0,16(sp)
    8000469a:	64a2                	ld	s1,8(sp)
    8000469c:	6105                	addi	sp,sp,32
    8000469e:	8082                	ret

00000000800046a0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046a0:	1101                	addi	sp,sp,-32
    800046a2:	ec06                	sd	ra,24(sp)
    800046a4:	e822                	sd	s0,16(sp)
    800046a6:	e426                	sd	s1,8(sp)
    800046a8:	1000                	addi	s0,sp,32
    800046aa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046ac:	0001d517          	auipc	a0,0x1d
    800046b0:	5a450513          	addi	a0,a0,1444 # 80021c50 <ftable>
    800046b4:	ffffc097          	auipc	ra,0xffffc
    800046b8:	5a6080e7          	jalr	1446(ra) # 80000c5a <acquire>
  if(f->ref < 1)
    800046bc:	40dc                	lw	a5,4(s1)
    800046be:	02f05263          	blez	a5,800046e2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046c2:	2785                	addiw	a5,a5,1
    800046c4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046c6:	0001d517          	auipc	a0,0x1d
    800046ca:	58a50513          	addi	a0,a0,1418 # 80021c50 <ftable>
    800046ce:	ffffc097          	auipc	ra,0xffffc
    800046d2:	640080e7          	jalr	1600(ra) # 80000d0e <release>
  return f;
}
    800046d6:	8526                	mv	a0,s1
    800046d8:	60e2                	ld	ra,24(sp)
    800046da:	6442                	ld	s0,16(sp)
    800046dc:	64a2                	ld	s1,8(sp)
    800046de:	6105                	addi	sp,sp,32
    800046e0:	8082                	ret
    panic("filedup");
    800046e2:	00004517          	auipc	a0,0x4
    800046e6:	08e50513          	addi	a0,a0,142 # 80008770 <syscalls+0x250>
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	e5e080e7          	jalr	-418(ra) # 80000548 <panic>

00000000800046f2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046f2:	7139                	addi	sp,sp,-64
    800046f4:	fc06                	sd	ra,56(sp)
    800046f6:	f822                	sd	s0,48(sp)
    800046f8:	f426                	sd	s1,40(sp)
    800046fa:	f04a                	sd	s2,32(sp)
    800046fc:	ec4e                	sd	s3,24(sp)
    800046fe:	e852                	sd	s4,16(sp)
    80004700:	e456                	sd	s5,8(sp)
    80004702:	0080                	addi	s0,sp,64
    80004704:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004706:	0001d517          	auipc	a0,0x1d
    8000470a:	54a50513          	addi	a0,a0,1354 # 80021c50 <ftable>
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	54c080e7          	jalr	1356(ra) # 80000c5a <acquire>
  if(f->ref < 1)
    80004716:	40dc                	lw	a5,4(s1)
    80004718:	06f05163          	blez	a5,8000477a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000471c:	37fd                	addiw	a5,a5,-1
    8000471e:	0007871b          	sext.w	a4,a5
    80004722:	c0dc                	sw	a5,4(s1)
    80004724:	06e04363          	bgtz	a4,8000478a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004728:	0004a903          	lw	s2,0(s1)
    8000472c:	0094ca83          	lbu	s5,9(s1)
    80004730:	0104ba03          	ld	s4,16(s1)
    80004734:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004738:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000473c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004740:	0001d517          	auipc	a0,0x1d
    80004744:	51050513          	addi	a0,a0,1296 # 80021c50 <ftable>
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	5c6080e7          	jalr	1478(ra) # 80000d0e <release>

  if(ff.type == FD_PIPE){
    80004750:	4785                	li	a5,1
    80004752:	04f90d63          	beq	s2,a5,800047ac <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004756:	3979                	addiw	s2,s2,-2
    80004758:	4785                	li	a5,1
    8000475a:	0527e063          	bltu	a5,s2,8000479a <fileclose+0xa8>
    begin_op();
    8000475e:	00000097          	auipc	ra,0x0
    80004762:	ac2080e7          	jalr	-1342(ra) # 80004220 <begin_op>
    iput(ff.ip);
    80004766:	854e                	mv	a0,s3
    80004768:	fffff097          	auipc	ra,0xfffff
    8000476c:	2b6080e7          	jalr	694(ra) # 80003a1e <iput>
    end_op();
    80004770:	00000097          	auipc	ra,0x0
    80004774:	b30080e7          	jalr	-1232(ra) # 800042a0 <end_op>
    80004778:	a00d                	j	8000479a <fileclose+0xa8>
    panic("fileclose");
    8000477a:	00004517          	auipc	a0,0x4
    8000477e:	ffe50513          	addi	a0,a0,-2 # 80008778 <syscalls+0x258>
    80004782:	ffffc097          	auipc	ra,0xffffc
    80004786:	dc6080e7          	jalr	-570(ra) # 80000548 <panic>
    release(&ftable.lock);
    8000478a:	0001d517          	auipc	a0,0x1d
    8000478e:	4c650513          	addi	a0,a0,1222 # 80021c50 <ftable>
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	57c080e7          	jalr	1404(ra) # 80000d0e <release>
  }
}
    8000479a:	70e2                	ld	ra,56(sp)
    8000479c:	7442                	ld	s0,48(sp)
    8000479e:	74a2                	ld	s1,40(sp)
    800047a0:	7902                	ld	s2,32(sp)
    800047a2:	69e2                	ld	s3,24(sp)
    800047a4:	6a42                	ld	s4,16(sp)
    800047a6:	6aa2                	ld	s5,8(sp)
    800047a8:	6121                	addi	sp,sp,64
    800047aa:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047ac:	85d6                	mv	a1,s5
    800047ae:	8552                	mv	a0,s4
    800047b0:	00000097          	auipc	ra,0x0
    800047b4:	372080e7          	jalr	882(ra) # 80004b22 <pipeclose>
    800047b8:	b7cd                	j	8000479a <fileclose+0xa8>

00000000800047ba <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047ba:	715d                	addi	sp,sp,-80
    800047bc:	e486                	sd	ra,72(sp)
    800047be:	e0a2                	sd	s0,64(sp)
    800047c0:	fc26                	sd	s1,56(sp)
    800047c2:	f84a                	sd	s2,48(sp)
    800047c4:	f44e                	sd	s3,40(sp)
    800047c6:	0880                	addi	s0,sp,80
    800047c8:	84aa                	mv	s1,a0
    800047ca:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047cc:	ffffd097          	auipc	ra,0xffffd
    800047d0:	344080e7          	jalr	836(ra) # 80001b10 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047d4:	409c                	lw	a5,0(s1)
    800047d6:	37f9                	addiw	a5,a5,-2
    800047d8:	4705                	li	a4,1
    800047da:	04f76763          	bltu	a4,a5,80004828 <filestat+0x6e>
    800047de:	892a                	mv	s2,a0
    ilock(f->ip);
    800047e0:	6c88                	ld	a0,24(s1)
    800047e2:	fffff097          	auipc	ra,0xfffff
    800047e6:	082080e7          	jalr	130(ra) # 80003864 <ilock>
    stati(f->ip, &st);
    800047ea:	fb840593          	addi	a1,s0,-72
    800047ee:	6c88                	ld	a0,24(s1)
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	2fe080e7          	jalr	766(ra) # 80003aee <stati>
    iunlock(f->ip);
    800047f8:	6c88                	ld	a0,24(s1)
    800047fa:	fffff097          	auipc	ra,0xfffff
    800047fe:	12c080e7          	jalr	300(ra) # 80003926 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004802:	46e1                	li	a3,24
    80004804:	fb840613          	addi	a2,s0,-72
    80004808:	85ce                	mv	a1,s3
    8000480a:	05093503          	ld	a0,80(s2)
    8000480e:	ffffd097          	auipc	ra,0xffffd
    80004812:	f0e080e7          	jalr	-242(ra) # 8000171c <copyout>
    80004816:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000481a:	60a6                	ld	ra,72(sp)
    8000481c:	6406                	ld	s0,64(sp)
    8000481e:	74e2                	ld	s1,56(sp)
    80004820:	7942                	ld	s2,48(sp)
    80004822:	79a2                	ld	s3,40(sp)
    80004824:	6161                	addi	sp,sp,80
    80004826:	8082                	ret
  return -1;
    80004828:	557d                	li	a0,-1
    8000482a:	bfc5                	j	8000481a <filestat+0x60>

000000008000482c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000482c:	7179                	addi	sp,sp,-48
    8000482e:	f406                	sd	ra,40(sp)
    80004830:	f022                	sd	s0,32(sp)
    80004832:	ec26                	sd	s1,24(sp)
    80004834:	e84a                	sd	s2,16(sp)
    80004836:	e44e                	sd	s3,8(sp)
    80004838:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000483a:	00854783          	lbu	a5,8(a0)
    8000483e:	c3d5                	beqz	a5,800048e2 <fileread+0xb6>
    80004840:	84aa                	mv	s1,a0
    80004842:	89ae                	mv	s3,a1
    80004844:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004846:	411c                	lw	a5,0(a0)
    80004848:	4705                	li	a4,1
    8000484a:	04e78963          	beq	a5,a4,8000489c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000484e:	470d                	li	a4,3
    80004850:	04e78d63          	beq	a5,a4,800048aa <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004854:	4709                	li	a4,2
    80004856:	06e79e63          	bne	a5,a4,800048d2 <fileread+0xa6>
    ilock(f->ip);
    8000485a:	6d08                	ld	a0,24(a0)
    8000485c:	fffff097          	auipc	ra,0xfffff
    80004860:	008080e7          	jalr	8(ra) # 80003864 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004864:	874a                	mv	a4,s2
    80004866:	5094                	lw	a3,32(s1)
    80004868:	864e                	mv	a2,s3
    8000486a:	4585                	li	a1,1
    8000486c:	6c88                	ld	a0,24(s1)
    8000486e:	fffff097          	auipc	ra,0xfffff
    80004872:	2aa080e7          	jalr	682(ra) # 80003b18 <readi>
    80004876:	892a                	mv	s2,a0
    80004878:	00a05563          	blez	a0,80004882 <fileread+0x56>
      f->off += r;
    8000487c:	509c                	lw	a5,32(s1)
    8000487e:	9fa9                	addw	a5,a5,a0
    80004880:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004882:	6c88                	ld	a0,24(s1)
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	0a2080e7          	jalr	162(ra) # 80003926 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000488c:	854a                	mv	a0,s2
    8000488e:	70a2                	ld	ra,40(sp)
    80004890:	7402                	ld	s0,32(sp)
    80004892:	64e2                	ld	s1,24(sp)
    80004894:	6942                	ld	s2,16(sp)
    80004896:	69a2                	ld	s3,8(sp)
    80004898:	6145                	addi	sp,sp,48
    8000489a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000489c:	6908                	ld	a0,16(a0)
    8000489e:	00000097          	auipc	ra,0x0
    800048a2:	418080e7          	jalr	1048(ra) # 80004cb6 <piperead>
    800048a6:	892a                	mv	s2,a0
    800048a8:	b7d5                	j	8000488c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048aa:	02451783          	lh	a5,36(a0)
    800048ae:	03079693          	slli	a3,a5,0x30
    800048b2:	92c1                	srli	a3,a3,0x30
    800048b4:	4725                	li	a4,9
    800048b6:	02d76863          	bltu	a4,a3,800048e6 <fileread+0xba>
    800048ba:	0792                	slli	a5,a5,0x4
    800048bc:	0001d717          	auipc	a4,0x1d
    800048c0:	2f470713          	addi	a4,a4,756 # 80021bb0 <devsw>
    800048c4:	97ba                	add	a5,a5,a4
    800048c6:	639c                	ld	a5,0(a5)
    800048c8:	c38d                	beqz	a5,800048ea <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800048ca:	4505                	li	a0,1
    800048cc:	9782                	jalr	a5
    800048ce:	892a                	mv	s2,a0
    800048d0:	bf75                	j	8000488c <fileread+0x60>
    panic("fileread");
    800048d2:	00004517          	auipc	a0,0x4
    800048d6:	eb650513          	addi	a0,a0,-330 # 80008788 <syscalls+0x268>
    800048da:	ffffc097          	auipc	ra,0xffffc
    800048de:	c6e080e7          	jalr	-914(ra) # 80000548 <panic>
    return -1;
    800048e2:	597d                	li	s2,-1
    800048e4:	b765                	j	8000488c <fileread+0x60>
      return -1;
    800048e6:	597d                	li	s2,-1
    800048e8:	b755                	j	8000488c <fileread+0x60>
    800048ea:	597d                	li	s2,-1
    800048ec:	b745                	j	8000488c <fileread+0x60>

00000000800048ee <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048ee:	00954783          	lbu	a5,9(a0)
    800048f2:	14078563          	beqz	a5,80004a3c <filewrite+0x14e>
{
    800048f6:	715d                	addi	sp,sp,-80
    800048f8:	e486                	sd	ra,72(sp)
    800048fa:	e0a2                	sd	s0,64(sp)
    800048fc:	fc26                	sd	s1,56(sp)
    800048fe:	f84a                	sd	s2,48(sp)
    80004900:	f44e                	sd	s3,40(sp)
    80004902:	f052                	sd	s4,32(sp)
    80004904:	ec56                	sd	s5,24(sp)
    80004906:	e85a                	sd	s6,16(sp)
    80004908:	e45e                	sd	s7,8(sp)
    8000490a:	e062                	sd	s8,0(sp)
    8000490c:	0880                	addi	s0,sp,80
    8000490e:	892a                	mv	s2,a0
    80004910:	8aae                	mv	s5,a1
    80004912:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004914:	411c                	lw	a5,0(a0)
    80004916:	4705                	li	a4,1
    80004918:	02e78263          	beq	a5,a4,8000493c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000491c:	470d                	li	a4,3
    8000491e:	02e78563          	beq	a5,a4,80004948 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004922:	4709                	li	a4,2
    80004924:	10e79463          	bne	a5,a4,80004a2c <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004928:	0ec05e63          	blez	a2,80004a24 <filewrite+0x136>
    int i = 0;
    8000492c:	4981                	li	s3,0
    8000492e:	6b05                	lui	s6,0x1
    80004930:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004934:	6b85                	lui	s7,0x1
    80004936:	c00b8b9b          	addiw	s7,s7,-1024
    8000493a:	a851                	j	800049ce <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000493c:	6908                	ld	a0,16(a0)
    8000493e:	00000097          	auipc	ra,0x0
    80004942:	254080e7          	jalr	596(ra) # 80004b92 <pipewrite>
    80004946:	a85d                	j	800049fc <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004948:	02451783          	lh	a5,36(a0)
    8000494c:	03079693          	slli	a3,a5,0x30
    80004950:	92c1                	srli	a3,a3,0x30
    80004952:	4725                	li	a4,9
    80004954:	0ed76663          	bltu	a4,a3,80004a40 <filewrite+0x152>
    80004958:	0792                	slli	a5,a5,0x4
    8000495a:	0001d717          	auipc	a4,0x1d
    8000495e:	25670713          	addi	a4,a4,598 # 80021bb0 <devsw>
    80004962:	97ba                	add	a5,a5,a4
    80004964:	679c                	ld	a5,8(a5)
    80004966:	cff9                	beqz	a5,80004a44 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004968:	4505                	li	a0,1
    8000496a:	9782                	jalr	a5
    8000496c:	a841                	j	800049fc <filewrite+0x10e>
    8000496e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004972:	00000097          	auipc	ra,0x0
    80004976:	8ae080e7          	jalr	-1874(ra) # 80004220 <begin_op>
      ilock(f->ip);
    8000497a:	01893503          	ld	a0,24(s2)
    8000497e:	fffff097          	auipc	ra,0xfffff
    80004982:	ee6080e7          	jalr	-282(ra) # 80003864 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004986:	8762                	mv	a4,s8
    80004988:	02092683          	lw	a3,32(s2)
    8000498c:	01598633          	add	a2,s3,s5
    80004990:	4585                	li	a1,1
    80004992:	01893503          	ld	a0,24(s2)
    80004996:	fffff097          	auipc	ra,0xfffff
    8000499a:	278080e7          	jalr	632(ra) # 80003c0e <writei>
    8000499e:	84aa                	mv	s1,a0
    800049a0:	02a05f63          	blez	a0,800049de <filewrite+0xf0>
        f->off += r;
    800049a4:	02092783          	lw	a5,32(s2)
    800049a8:	9fa9                	addw	a5,a5,a0
    800049aa:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049ae:	01893503          	ld	a0,24(s2)
    800049b2:	fffff097          	auipc	ra,0xfffff
    800049b6:	f74080e7          	jalr	-140(ra) # 80003926 <iunlock>
      end_op();
    800049ba:	00000097          	auipc	ra,0x0
    800049be:	8e6080e7          	jalr	-1818(ra) # 800042a0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800049c2:	049c1963          	bne	s8,s1,80004a14 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800049c6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800049ca:	0349d663          	bge	s3,s4,800049f6 <filewrite+0x108>
      int n1 = n - i;
    800049ce:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800049d2:	84be                	mv	s1,a5
    800049d4:	2781                	sext.w	a5,a5
    800049d6:	f8fb5ce3          	bge	s6,a5,8000496e <filewrite+0x80>
    800049da:	84de                	mv	s1,s7
    800049dc:	bf49                	j	8000496e <filewrite+0x80>
      iunlock(f->ip);
    800049de:	01893503          	ld	a0,24(s2)
    800049e2:	fffff097          	auipc	ra,0xfffff
    800049e6:	f44080e7          	jalr	-188(ra) # 80003926 <iunlock>
      end_op();
    800049ea:	00000097          	auipc	ra,0x0
    800049ee:	8b6080e7          	jalr	-1866(ra) # 800042a0 <end_op>
      if(r < 0)
    800049f2:	fc04d8e3          	bgez	s1,800049c2 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800049f6:	8552                	mv	a0,s4
    800049f8:	033a1863          	bne	s4,s3,80004a28 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049fc:	60a6                	ld	ra,72(sp)
    800049fe:	6406                	ld	s0,64(sp)
    80004a00:	74e2                	ld	s1,56(sp)
    80004a02:	7942                	ld	s2,48(sp)
    80004a04:	79a2                	ld	s3,40(sp)
    80004a06:	7a02                	ld	s4,32(sp)
    80004a08:	6ae2                	ld	s5,24(sp)
    80004a0a:	6b42                	ld	s6,16(sp)
    80004a0c:	6ba2                	ld	s7,8(sp)
    80004a0e:	6c02                	ld	s8,0(sp)
    80004a10:	6161                	addi	sp,sp,80
    80004a12:	8082                	ret
        panic("short filewrite");
    80004a14:	00004517          	auipc	a0,0x4
    80004a18:	d8450513          	addi	a0,a0,-636 # 80008798 <syscalls+0x278>
    80004a1c:	ffffc097          	auipc	ra,0xffffc
    80004a20:	b2c080e7          	jalr	-1236(ra) # 80000548 <panic>
    int i = 0;
    80004a24:	4981                	li	s3,0
    80004a26:	bfc1                	j	800049f6 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004a28:	557d                	li	a0,-1
    80004a2a:	bfc9                	j	800049fc <filewrite+0x10e>
    panic("filewrite");
    80004a2c:	00004517          	auipc	a0,0x4
    80004a30:	d7c50513          	addi	a0,a0,-644 # 800087a8 <syscalls+0x288>
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	b14080e7          	jalr	-1260(ra) # 80000548 <panic>
    return -1;
    80004a3c:	557d                	li	a0,-1
}
    80004a3e:	8082                	ret
      return -1;
    80004a40:	557d                	li	a0,-1
    80004a42:	bf6d                	j	800049fc <filewrite+0x10e>
    80004a44:	557d                	li	a0,-1
    80004a46:	bf5d                	j	800049fc <filewrite+0x10e>

0000000080004a48 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a48:	7179                	addi	sp,sp,-48
    80004a4a:	f406                	sd	ra,40(sp)
    80004a4c:	f022                	sd	s0,32(sp)
    80004a4e:	ec26                	sd	s1,24(sp)
    80004a50:	e84a                	sd	s2,16(sp)
    80004a52:	e44e                	sd	s3,8(sp)
    80004a54:	e052                	sd	s4,0(sp)
    80004a56:	1800                	addi	s0,sp,48
    80004a58:	84aa                	mv	s1,a0
    80004a5a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a5c:	0005b023          	sd	zero,0(a1)
    80004a60:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a64:	00000097          	auipc	ra,0x0
    80004a68:	bd2080e7          	jalr	-1070(ra) # 80004636 <filealloc>
    80004a6c:	e088                	sd	a0,0(s1)
    80004a6e:	c551                	beqz	a0,80004afa <pipealloc+0xb2>
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	bc6080e7          	jalr	-1082(ra) # 80004636 <filealloc>
    80004a78:	00aa3023          	sd	a0,0(s4)
    80004a7c:	c92d                	beqz	a0,80004aee <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a7e:	ffffc097          	auipc	ra,0xffffc
    80004a82:	0a2080e7          	jalr	162(ra) # 80000b20 <kalloc>
    80004a86:	892a                	mv	s2,a0
    80004a88:	c125                	beqz	a0,80004ae8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a8a:	4985                	li	s3,1
    80004a8c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a90:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a94:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a98:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a9c:	00004597          	auipc	a1,0x4
    80004aa0:	9d458593          	addi	a1,a1,-1580 # 80008470 <states.1717+0x198>
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	126080e7          	jalr	294(ra) # 80000bca <initlock>
  (*f0)->type = FD_PIPE;
    80004aac:	609c                	ld	a5,0(s1)
    80004aae:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ab2:	609c                	ld	a5,0(s1)
    80004ab4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ab8:	609c                	ld	a5,0(s1)
    80004aba:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004abe:	609c                	ld	a5,0(s1)
    80004ac0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ac4:	000a3783          	ld	a5,0(s4)
    80004ac8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004acc:	000a3783          	ld	a5,0(s4)
    80004ad0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ad4:	000a3783          	ld	a5,0(s4)
    80004ad8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004adc:	000a3783          	ld	a5,0(s4)
    80004ae0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ae4:	4501                	li	a0,0
    80004ae6:	a025                	j	80004b0e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ae8:	6088                	ld	a0,0(s1)
    80004aea:	e501                	bnez	a0,80004af2 <pipealloc+0xaa>
    80004aec:	a039                	j	80004afa <pipealloc+0xb2>
    80004aee:	6088                	ld	a0,0(s1)
    80004af0:	c51d                	beqz	a0,80004b1e <pipealloc+0xd6>
    fileclose(*f0);
    80004af2:	00000097          	auipc	ra,0x0
    80004af6:	c00080e7          	jalr	-1024(ra) # 800046f2 <fileclose>
  if(*f1)
    80004afa:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004afe:	557d                	li	a0,-1
  if(*f1)
    80004b00:	c799                	beqz	a5,80004b0e <pipealloc+0xc6>
    fileclose(*f1);
    80004b02:	853e                	mv	a0,a5
    80004b04:	00000097          	auipc	ra,0x0
    80004b08:	bee080e7          	jalr	-1042(ra) # 800046f2 <fileclose>
  return -1;
    80004b0c:	557d                	li	a0,-1
}
    80004b0e:	70a2                	ld	ra,40(sp)
    80004b10:	7402                	ld	s0,32(sp)
    80004b12:	64e2                	ld	s1,24(sp)
    80004b14:	6942                	ld	s2,16(sp)
    80004b16:	69a2                	ld	s3,8(sp)
    80004b18:	6a02                	ld	s4,0(sp)
    80004b1a:	6145                	addi	sp,sp,48
    80004b1c:	8082                	ret
  return -1;
    80004b1e:	557d                	li	a0,-1
    80004b20:	b7fd                	j	80004b0e <pipealloc+0xc6>

0000000080004b22 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b22:	1101                	addi	sp,sp,-32
    80004b24:	ec06                	sd	ra,24(sp)
    80004b26:	e822                	sd	s0,16(sp)
    80004b28:	e426                	sd	s1,8(sp)
    80004b2a:	e04a                	sd	s2,0(sp)
    80004b2c:	1000                	addi	s0,sp,32
    80004b2e:	84aa                	mv	s1,a0
    80004b30:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	128080e7          	jalr	296(ra) # 80000c5a <acquire>
  if(writable){
    80004b3a:	02090d63          	beqz	s2,80004b74 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b3e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b42:	21848513          	addi	a0,s1,536
    80004b46:	ffffe097          	auipc	ra,0xffffe
    80004b4a:	964080e7          	jalr	-1692(ra) # 800024aa <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b4e:	2204b783          	ld	a5,544(s1)
    80004b52:	eb95                	bnez	a5,80004b86 <pipeclose+0x64>
    release(&pi->lock);
    80004b54:	8526                	mv	a0,s1
    80004b56:	ffffc097          	auipc	ra,0xffffc
    80004b5a:	1b8080e7          	jalr	440(ra) # 80000d0e <release>
    kfree((char*)pi);
    80004b5e:	8526                	mv	a0,s1
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	ec4080e7          	jalr	-316(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    80004b68:	60e2                	ld	ra,24(sp)
    80004b6a:	6442                	ld	s0,16(sp)
    80004b6c:	64a2                	ld	s1,8(sp)
    80004b6e:	6902                	ld	s2,0(sp)
    80004b70:	6105                	addi	sp,sp,32
    80004b72:	8082                	ret
    pi->readopen = 0;
    80004b74:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b78:	21c48513          	addi	a0,s1,540
    80004b7c:	ffffe097          	auipc	ra,0xffffe
    80004b80:	92e080e7          	jalr	-1746(ra) # 800024aa <wakeup>
    80004b84:	b7e9                	j	80004b4e <pipeclose+0x2c>
    release(&pi->lock);
    80004b86:	8526                	mv	a0,s1
    80004b88:	ffffc097          	auipc	ra,0xffffc
    80004b8c:	186080e7          	jalr	390(ra) # 80000d0e <release>
}
    80004b90:	bfe1                	j	80004b68 <pipeclose+0x46>

0000000080004b92 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b92:	7119                	addi	sp,sp,-128
    80004b94:	fc86                	sd	ra,120(sp)
    80004b96:	f8a2                	sd	s0,112(sp)
    80004b98:	f4a6                	sd	s1,104(sp)
    80004b9a:	f0ca                	sd	s2,96(sp)
    80004b9c:	ecce                	sd	s3,88(sp)
    80004b9e:	e8d2                	sd	s4,80(sp)
    80004ba0:	e4d6                	sd	s5,72(sp)
    80004ba2:	e0da                	sd	s6,64(sp)
    80004ba4:	fc5e                	sd	s7,56(sp)
    80004ba6:	f862                	sd	s8,48(sp)
    80004ba8:	f466                	sd	s9,40(sp)
    80004baa:	f06a                	sd	s10,32(sp)
    80004bac:	ec6e                	sd	s11,24(sp)
    80004bae:	0100                	addi	s0,sp,128
    80004bb0:	84aa                	mv	s1,a0
    80004bb2:	8cae                	mv	s9,a1
    80004bb4:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004bb6:	ffffd097          	auipc	ra,0xffffd
    80004bba:	f5a080e7          	jalr	-166(ra) # 80001b10 <myproc>
    80004bbe:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004bc0:	8526                	mv	a0,s1
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	098080e7          	jalr	152(ra) # 80000c5a <acquire>
  for(i = 0; i < n; i++){
    80004bca:	0d605963          	blez	s6,80004c9c <pipewrite+0x10a>
    80004bce:	89a6                	mv	s3,s1
    80004bd0:	3b7d                	addiw	s6,s6,-1
    80004bd2:	1b02                	slli	s6,s6,0x20
    80004bd4:	020b5b13          	srli	s6,s6,0x20
    80004bd8:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004bda:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004bde:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004be2:	5dfd                	li	s11,-1
    80004be4:	000b8d1b          	sext.w	s10,s7
    80004be8:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004bea:	2184a783          	lw	a5,536(s1)
    80004bee:	21c4a703          	lw	a4,540(s1)
    80004bf2:	2007879b          	addiw	a5,a5,512
    80004bf6:	02f71b63          	bne	a4,a5,80004c2c <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004bfa:	2204a783          	lw	a5,544(s1)
    80004bfe:	cbad                	beqz	a5,80004c70 <pipewrite+0xde>
    80004c00:	03092783          	lw	a5,48(s2)
    80004c04:	e7b5                	bnez	a5,80004c70 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004c06:	8556                	mv	a0,s5
    80004c08:	ffffe097          	auipc	ra,0xffffe
    80004c0c:	8a2080e7          	jalr	-1886(ra) # 800024aa <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c10:	85ce                	mv	a1,s3
    80004c12:	8552                	mv	a0,s4
    80004c14:	ffffd097          	auipc	ra,0xffffd
    80004c18:	710080e7          	jalr	1808(ra) # 80002324 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c1c:	2184a783          	lw	a5,536(s1)
    80004c20:	21c4a703          	lw	a4,540(s1)
    80004c24:	2007879b          	addiw	a5,a5,512
    80004c28:	fcf709e3          	beq	a4,a5,80004bfa <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c2c:	4685                	li	a3,1
    80004c2e:	019b8633          	add	a2,s7,s9
    80004c32:	f8f40593          	addi	a1,s0,-113
    80004c36:	05093503          	ld	a0,80(s2)
    80004c3a:	ffffd097          	auipc	ra,0xffffd
    80004c3e:	b6e080e7          	jalr	-1170(ra) # 800017a8 <copyin>
    80004c42:	05b50e63          	beq	a0,s11,80004c9e <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c46:	21c4a783          	lw	a5,540(s1)
    80004c4a:	0017871b          	addiw	a4,a5,1
    80004c4e:	20e4ae23          	sw	a4,540(s1)
    80004c52:	1ff7f793          	andi	a5,a5,511
    80004c56:	97a6                	add	a5,a5,s1
    80004c58:	f8f44703          	lbu	a4,-113(s0)
    80004c5c:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004c60:	001d0c1b          	addiw	s8,s10,1
    80004c64:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004c68:	036b8b63          	beq	s7,s6,80004c9e <pipewrite+0x10c>
    80004c6c:	8bbe                	mv	s7,a5
    80004c6e:	bf9d                	j	80004be4 <pipewrite+0x52>
        release(&pi->lock);
    80004c70:	8526                	mv	a0,s1
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	09c080e7          	jalr	156(ra) # 80000d0e <release>
        return -1;
    80004c7a:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004c7c:	8562                	mv	a0,s8
    80004c7e:	70e6                	ld	ra,120(sp)
    80004c80:	7446                	ld	s0,112(sp)
    80004c82:	74a6                	ld	s1,104(sp)
    80004c84:	7906                	ld	s2,96(sp)
    80004c86:	69e6                	ld	s3,88(sp)
    80004c88:	6a46                	ld	s4,80(sp)
    80004c8a:	6aa6                	ld	s5,72(sp)
    80004c8c:	6b06                	ld	s6,64(sp)
    80004c8e:	7be2                	ld	s7,56(sp)
    80004c90:	7c42                	ld	s8,48(sp)
    80004c92:	7ca2                	ld	s9,40(sp)
    80004c94:	7d02                	ld	s10,32(sp)
    80004c96:	6de2                	ld	s11,24(sp)
    80004c98:	6109                	addi	sp,sp,128
    80004c9a:	8082                	ret
  for(i = 0; i < n; i++){
    80004c9c:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004c9e:	21848513          	addi	a0,s1,536
    80004ca2:	ffffe097          	auipc	ra,0xffffe
    80004ca6:	808080e7          	jalr	-2040(ra) # 800024aa <wakeup>
  release(&pi->lock);
    80004caa:	8526                	mv	a0,s1
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	062080e7          	jalr	98(ra) # 80000d0e <release>
  return i;
    80004cb4:	b7e1                	j	80004c7c <pipewrite+0xea>

0000000080004cb6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cb6:	715d                	addi	sp,sp,-80
    80004cb8:	e486                	sd	ra,72(sp)
    80004cba:	e0a2                	sd	s0,64(sp)
    80004cbc:	fc26                	sd	s1,56(sp)
    80004cbe:	f84a                	sd	s2,48(sp)
    80004cc0:	f44e                	sd	s3,40(sp)
    80004cc2:	f052                	sd	s4,32(sp)
    80004cc4:	ec56                	sd	s5,24(sp)
    80004cc6:	e85a                	sd	s6,16(sp)
    80004cc8:	0880                	addi	s0,sp,80
    80004cca:	84aa                	mv	s1,a0
    80004ccc:	892e                	mv	s2,a1
    80004cce:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004cd0:	ffffd097          	auipc	ra,0xffffd
    80004cd4:	e40080e7          	jalr	-448(ra) # 80001b10 <myproc>
    80004cd8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004cda:	8b26                	mv	s6,s1
    80004cdc:	8526                	mv	a0,s1
    80004cde:	ffffc097          	auipc	ra,0xffffc
    80004ce2:	f7c080e7          	jalr	-132(ra) # 80000c5a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ce6:	2184a703          	lw	a4,536(s1)
    80004cea:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cee:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cf2:	02f71463          	bne	a4,a5,80004d1a <piperead+0x64>
    80004cf6:	2244a783          	lw	a5,548(s1)
    80004cfa:	c385                	beqz	a5,80004d1a <piperead+0x64>
    if(pr->killed){
    80004cfc:	030a2783          	lw	a5,48(s4)
    80004d00:	ebc1                	bnez	a5,80004d90 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d02:	85da                	mv	a1,s6
    80004d04:	854e                	mv	a0,s3
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	61e080e7          	jalr	1566(ra) # 80002324 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d0e:	2184a703          	lw	a4,536(s1)
    80004d12:	21c4a783          	lw	a5,540(s1)
    80004d16:	fef700e3          	beq	a4,a5,80004cf6 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d1a:	09505263          	blez	s5,80004d9e <piperead+0xe8>
    80004d1e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d20:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004d22:	2184a783          	lw	a5,536(s1)
    80004d26:	21c4a703          	lw	a4,540(s1)
    80004d2a:	02f70d63          	beq	a4,a5,80004d64 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d2e:	0017871b          	addiw	a4,a5,1
    80004d32:	20e4ac23          	sw	a4,536(s1)
    80004d36:	1ff7f793          	andi	a5,a5,511
    80004d3a:	97a6                	add	a5,a5,s1
    80004d3c:	0187c783          	lbu	a5,24(a5)
    80004d40:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d44:	4685                	li	a3,1
    80004d46:	fbf40613          	addi	a2,s0,-65
    80004d4a:	85ca                	mv	a1,s2
    80004d4c:	050a3503          	ld	a0,80(s4)
    80004d50:	ffffd097          	auipc	ra,0xffffd
    80004d54:	9cc080e7          	jalr	-1588(ra) # 8000171c <copyout>
    80004d58:	01650663          	beq	a0,s6,80004d64 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d5c:	2985                	addiw	s3,s3,1
    80004d5e:	0905                	addi	s2,s2,1
    80004d60:	fd3a91e3          	bne	s5,s3,80004d22 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d64:	21c48513          	addi	a0,s1,540
    80004d68:	ffffd097          	auipc	ra,0xffffd
    80004d6c:	742080e7          	jalr	1858(ra) # 800024aa <wakeup>
  release(&pi->lock);
    80004d70:	8526                	mv	a0,s1
    80004d72:	ffffc097          	auipc	ra,0xffffc
    80004d76:	f9c080e7          	jalr	-100(ra) # 80000d0e <release>
  return i;
}
    80004d7a:	854e                	mv	a0,s3
    80004d7c:	60a6                	ld	ra,72(sp)
    80004d7e:	6406                	ld	s0,64(sp)
    80004d80:	74e2                	ld	s1,56(sp)
    80004d82:	7942                	ld	s2,48(sp)
    80004d84:	79a2                	ld	s3,40(sp)
    80004d86:	7a02                	ld	s4,32(sp)
    80004d88:	6ae2                	ld	s5,24(sp)
    80004d8a:	6b42                	ld	s6,16(sp)
    80004d8c:	6161                	addi	sp,sp,80
    80004d8e:	8082                	ret
      release(&pi->lock);
    80004d90:	8526                	mv	a0,s1
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	f7c080e7          	jalr	-132(ra) # 80000d0e <release>
      return -1;
    80004d9a:	59fd                	li	s3,-1
    80004d9c:	bff9                	j	80004d7a <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d9e:	4981                	li	s3,0
    80004da0:	b7d1                	j	80004d64 <piperead+0xae>

0000000080004da2 <exec>:
#include "elf.h"

static int loadseg(pde_t* pgdir, uint64 addr, struct inode* ip, uint offset, uint sz);

int exec(char* path, char** argv)
{
    80004da2:	df010113          	addi	sp,sp,-528
    80004da6:	20113423          	sd	ra,520(sp)
    80004daa:	20813023          	sd	s0,512(sp)
    80004dae:	ffa6                	sd	s1,504(sp)
    80004db0:	fbca                	sd	s2,496(sp)
    80004db2:	f7ce                	sd	s3,488(sp)
    80004db4:	f3d2                	sd	s4,480(sp)
    80004db6:	efd6                	sd	s5,472(sp)
    80004db8:	ebda                	sd	s6,464(sp)
    80004dba:	e7de                	sd	s7,456(sp)
    80004dbc:	e3e2                	sd	s8,448(sp)
    80004dbe:	ff66                	sd	s9,440(sp)
    80004dc0:	fb6a                	sd	s10,432(sp)
    80004dc2:	f76e                	sd	s11,424(sp)
    80004dc4:	0c00                	addi	s0,sp,528
    80004dc6:	84aa                	mv	s1,a0
    80004dc8:	dea43c23          	sd	a0,-520(s0)
    80004dcc:	e0b43023          	sd	a1,-512(s0)
    uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    struct elfhdr elf;
    struct inode* ip;
    struct proghdr ph;
    pagetable_t pagetable = 0, oldpagetable;
    struct proc* p = myproc();
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	d40080e7          	jalr	-704(ra) # 80001b10 <myproc>
    80004dd8:	892a                	mv	s2,a0

    begin_op();
    80004dda:	fffff097          	auipc	ra,0xfffff
    80004dde:	446080e7          	jalr	1094(ra) # 80004220 <begin_op>

    if ((ip = namei(path)) == 0)
    80004de2:	8526                	mv	a0,s1
    80004de4:	fffff097          	auipc	ra,0xfffff
    80004de8:	230080e7          	jalr	560(ra) # 80004014 <namei>
    80004dec:	c92d                	beqz	a0,80004e5e <exec+0xbc>
    80004dee:	84aa                	mv	s1,a0
    {
        end_op();
        return -1;
    }
    ilock(ip);
    80004df0:	fffff097          	auipc	ra,0xfffff
    80004df4:	a74080e7          	jalr	-1420(ra) # 80003864 <ilock>

    // Check ELF header
    if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004df8:	04000713          	li	a4,64
    80004dfc:	4681                	li	a3,0
    80004dfe:	e4840613          	addi	a2,s0,-440
    80004e02:	4581                	li	a1,0
    80004e04:	8526                	mv	a0,s1
    80004e06:	fffff097          	auipc	ra,0xfffff
    80004e0a:	d12080e7          	jalr	-750(ra) # 80003b18 <readi>
    80004e0e:	04000793          	li	a5,64
    80004e12:	00f51a63          	bne	a0,a5,80004e26 <exec+0x84>
        goto bad;
    if (elf.magic != ELF_MAGIC)
    80004e16:	e4842703          	lw	a4,-440(s0)
    80004e1a:	464c47b7          	lui	a5,0x464c4
    80004e1e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e22:	04f70463          	beq	a4,a5,80004e6a <exec+0xc8>
bad:
    if (pagetable)
        proc_freepagetable(pagetable, sz);
    if (ip)
    {
        iunlockput(ip);
    80004e26:	8526                	mv	a0,s1
    80004e28:	fffff097          	auipc	ra,0xfffff
    80004e2c:	c9e080e7          	jalr	-866(ra) # 80003ac6 <iunlockput>
        end_op();
    80004e30:	fffff097          	auipc	ra,0xfffff
    80004e34:	470080e7          	jalr	1136(ra) # 800042a0 <end_op>
    }
    return -1;
    80004e38:	557d                	li	a0,-1
}
    80004e3a:	20813083          	ld	ra,520(sp)
    80004e3e:	20013403          	ld	s0,512(sp)
    80004e42:	74fe                	ld	s1,504(sp)
    80004e44:	795e                	ld	s2,496(sp)
    80004e46:	79be                	ld	s3,488(sp)
    80004e48:	7a1e                	ld	s4,480(sp)
    80004e4a:	6afe                	ld	s5,472(sp)
    80004e4c:	6b5e                	ld	s6,464(sp)
    80004e4e:	6bbe                	ld	s7,456(sp)
    80004e50:	6c1e                	ld	s8,448(sp)
    80004e52:	7cfa                	ld	s9,440(sp)
    80004e54:	7d5a                	ld	s10,432(sp)
    80004e56:	7dba                	ld	s11,424(sp)
    80004e58:	21010113          	addi	sp,sp,528
    80004e5c:	8082                	ret
        end_op();
    80004e5e:	fffff097          	auipc	ra,0xfffff
    80004e62:	442080e7          	jalr	1090(ra) # 800042a0 <end_op>
        return -1;
    80004e66:	557d                	li	a0,-1
    80004e68:	bfc9                	j	80004e3a <exec+0x98>
    if ((pagetable = proc_pagetable(p)) == 0)
    80004e6a:	854a                	mv	a0,s2
    80004e6c:	ffffd097          	auipc	ra,0xffffd
    80004e70:	d68080e7          	jalr	-664(ra) # 80001bd4 <proc_pagetable>
    80004e74:	8baa                	mv	s7,a0
    80004e76:	d945                	beqz	a0,80004e26 <exec+0x84>
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80004e78:	e6842983          	lw	s3,-408(s0)
    80004e7c:	e8045783          	lhu	a5,-384(s0)
    80004e80:	c7ad                	beqz	a5,80004eea <exec+0x148>
    uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80004e82:	4901                	li	s2,0
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80004e84:	4b01                	li	s6,0
        if (ph.vaddr % PGSIZE != 0)
    80004e86:	6c85                	lui	s9,0x1
    80004e88:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e8c:	def43823          	sd	a5,-528(s0)
    80004e90:	a4b1                	j	800050dc <exec+0x33a>

    for (i = 0; i < sz; i += PGSIZE)
    {
        pa = walkaddr(pagetable, va + i);
        if (pa == 0)
            panic("loadseg: address should exist");
    80004e92:	00004517          	auipc	a0,0x4
    80004e96:	92650513          	addi	a0,a0,-1754 # 800087b8 <syscalls+0x298>
    80004e9a:	ffffb097          	auipc	ra,0xffffb
    80004e9e:	6ae080e7          	jalr	1710(ra) # 80000548 <panic>
        if (sz - i < PGSIZE)
            n = sz - i;
        else
            n = PGSIZE;
        if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004ea2:	8756                	mv	a4,s5
    80004ea4:	012d86bb          	addw	a3,s11,s2
    80004ea8:	4581                	li	a1,0
    80004eaa:	8526                	mv	a0,s1
    80004eac:	fffff097          	auipc	ra,0xfffff
    80004eb0:	c6c080e7          	jalr	-916(ra) # 80003b18 <readi>
    80004eb4:	2501                	sext.w	a0,a0
    80004eb6:	1caa9a63          	bne	s5,a0,8000508a <exec+0x2e8>
    for (i = 0; i < sz; i += PGSIZE)
    80004eba:	6785                	lui	a5,0x1
    80004ebc:	0127893b          	addw	s2,a5,s2
    80004ec0:	77fd                	lui	a5,0xfffff
    80004ec2:	01478a3b          	addw	s4,a5,s4
    80004ec6:	21897263          	bgeu	s2,s8,800050ca <exec+0x328>
        pa = walkaddr(pagetable, va + i);
    80004eca:	02091593          	slli	a1,s2,0x20
    80004ece:	9181                	srli	a1,a1,0x20
    80004ed0:	95ea                	add	a1,a1,s10
    80004ed2:	855e                	mv	a0,s7
    80004ed4:	ffffc097          	auipc	ra,0xffffc
    80004ed8:	214080e7          	jalr	532(ra) # 800010e8 <walkaddr>
    80004edc:	862a                	mv	a2,a0
        if (pa == 0)
    80004ede:	d955                	beqz	a0,80004e92 <exec+0xf0>
            n = PGSIZE;
    80004ee0:	8ae6                	mv	s5,s9
        if (sz - i < PGSIZE)
    80004ee2:	fd9a70e3          	bgeu	s4,s9,80004ea2 <exec+0x100>
            n = sz - i;
    80004ee6:	8ad2                	mv	s5,s4
    80004ee8:	bf6d                	j	80004ea2 <exec+0x100>
    uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80004eea:	4901                	li	s2,0
    iunlockput(ip);
    80004eec:	8526                	mv	a0,s1
    80004eee:	fffff097          	auipc	ra,0xfffff
    80004ef2:	bd8080e7          	jalr	-1064(ra) # 80003ac6 <iunlockput>
    end_op();
    80004ef6:	fffff097          	auipc	ra,0xfffff
    80004efa:	3aa080e7          	jalr	938(ra) # 800042a0 <end_op>
    p = myproc();
    80004efe:	ffffd097          	auipc	ra,0xffffd
    80004f02:	c12080e7          	jalr	-1006(ra) # 80001b10 <myproc>
    80004f06:	8aaa                	mv	s5,a0
    uint64 oldsz = p->sz;
    80004f08:	04853d03          	ld	s10,72(a0)
    sz = PGROUNDUP(sz);
    80004f0c:	6785                	lui	a5,0x1
    80004f0e:	17fd                	addi	a5,a5,-1
    80004f10:	993e                	add	s2,s2,a5
    80004f12:	757d                	lui	a0,0xfffff
    80004f14:	00a977b3          	and	a5,s2,a0
    80004f18:	e0f43423          	sd	a5,-504(s0)
    if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE)) == 0)
    80004f1c:	6609                	lui	a2,0x2
    80004f1e:	963e                	add	a2,a2,a5
    80004f20:	85be                	mv	a1,a5
    80004f22:	855e                	mv	a0,s7
    80004f24:	ffffc097          	auipc	ra,0xffffc
    80004f28:	5a8080e7          	jalr	1448(ra) # 800014cc <uvmalloc>
    80004f2c:	8b2a                	mv	s6,a0
    ip = 0;
    80004f2e:	4481                	li	s1,0
    if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE)) == 0)
    80004f30:	14050d63          	beqz	a0,8000508a <exec+0x2e8>
    uvmclear(pagetable, sz - 2 * PGSIZE);
    80004f34:	75f9                	lui	a1,0xffffe
    80004f36:	95aa                	add	a1,a1,a0
    80004f38:	855e                	mv	a0,s7
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	7b0080e7          	jalr	1968(ra) # 800016ea <uvmclear>
    stackbase = sp - PGSIZE;
    80004f42:	7c7d                	lui	s8,0xfffff
    80004f44:	9c5a                	add	s8,s8,s6
    for (argc = 0; argv[argc]; argc++)
    80004f46:	e0043783          	ld	a5,-512(s0)
    80004f4a:	6388                	ld	a0,0(a5)
    80004f4c:	c535                	beqz	a0,80004fb8 <exec+0x216>
    80004f4e:	e8840993          	addi	s3,s0,-376
    80004f52:	f8840c93          	addi	s9,s0,-120
    sp = sz;
    80004f56:	895a                	mv	s2,s6
        sp -= strlen(argv[argc]) + 1;
    80004f58:	ffffc097          	auipc	ra,0xffffc
    80004f5c:	f86080e7          	jalr	-122(ra) # 80000ede <strlen>
    80004f60:	2505                	addiw	a0,a0,1
    80004f62:	40a90933          	sub	s2,s2,a0
        sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f66:	ff097913          	andi	s2,s2,-16
        if (sp < stackbase)
    80004f6a:	15896463          	bltu	s2,s8,800050b2 <exec+0x310>
        if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f6e:	e0043d83          	ld	s11,-512(s0)
    80004f72:	000dba03          	ld	s4,0(s11)
    80004f76:	8552                	mv	a0,s4
    80004f78:	ffffc097          	auipc	ra,0xffffc
    80004f7c:	f66080e7          	jalr	-154(ra) # 80000ede <strlen>
    80004f80:	0015069b          	addiw	a3,a0,1
    80004f84:	8652                	mv	a2,s4
    80004f86:	85ca                	mv	a1,s2
    80004f88:	855e                	mv	a0,s7
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	792080e7          	jalr	1938(ra) # 8000171c <copyout>
    80004f92:	12054463          	bltz	a0,800050ba <exec+0x318>
        ustack[argc] = sp;
    80004f96:	0129b023          	sd	s2,0(s3)
    for (argc = 0; argv[argc]; argc++)
    80004f9a:	0485                	addi	s1,s1,1
    80004f9c:	008d8793          	addi	a5,s11,8
    80004fa0:	e0f43023          	sd	a5,-512(s0)
    80004fa4:	008db503          	ld	a0,8(s11)
    80004fa8:	c911                	beqz	a0,80004fbc <exec+0x21a>
        if (argc >= MAXARG)
    80004faa:	09a1                	addi	s3,s3,8
    80004fac:	fb3c96e3          	bne	s9,s3,80004f58 <exec+0x1b6>
    sz = sz1;
    80004fb0:	e1643423          	sd	s6,-504(s0)
    ip = 0;
    80004fb4:	4481                	li	s1,0
    80004fb6:	a8d1                	j	8000508a <exec+0x2e8>
    sp = sz;
    80004fb8:	895a                	mv	s2,s6
    for (argc = 0; argv[argc]; argc++)
    80004fba:	4481                	li	s1,0
    ustack[argc] = 0;
    80004fbc:	00349793          	slli	a5,s1,0x3
    80004fc0:	f9040713          	addi	a4,s0,-112
    80004fc4:	97ba                	add	a5,a5,a4
    80004fc6:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
    sp -= (argc + 1) * sizeof(uint64);
    80004fca:	00148693          	addi	a3,s1,1
    80004fce:	068e                	slli	a3,a3,0x3
    80004fd0:	40d90933          	sub	s2,s2,a3
    sp -= sp % 16;
    80004fd4:	ff097913          	andi	s2,s2,-16
    if (sp < stackbase)
    80004fd8:	01897663          	bgeu	s2,s8,80004fe4 <exec+0x242>
    sz = sz1;
    80004fdc:	e1643423          	sd	s6,-504(s0)
    ip = 0;
    80004fe0:	4481                	li	s1,0
    80004fe2:	a065                	j	8000508a <exec+0x2e8>
    if (copyout(pagetable, sp, (char*)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80004fe4:	e8840613          	addi	a2,s0,-376
    80004fe8:	85ca                	mv	a1,s2
    80004fea:	855e                	mv	a0,s7
    80004fec:	ffffc097          	auipc	ra,0xffffc
    80004ff0:	730080e7          	jalr	1840(ra) # 8000171c <copyout>
    80004ff4:	0c054763          	bltz	a0,800050c2 <exec+0x320>
    p->trapframe->a1 = sp;
    80004ff8:	058ab783          	ld	a5,88(s5)
    80004ffc:	0727bc23          	sd	s2,120(a5)
    for (last = s = path; *s; s++)
    80005000:	df843783          	ld	a5,-520(s0)
    80005004:	0007c703          	lbu	a4,0(a5)
    80005008:	cf11                	beqz	a4,80005024 <exec+0x282>
    8000500a:	0785                	addi	a5,a5,1
        if (*s == '/')
    8000500c:	02f00693          	li	a3,47
    80005010:	a029                	j	8000501a <exec+0x278>
    for (last = s = path; *s; s++)
    80005012:	0785                	addi	a5,a5,1
    80005014:	fff7c703          	lbu	a4,-1(a5)
    80005018:	c711                	beqz	a4,80005024 <exec+0x282>
        if (*s == '/')
    8000501a:	fed71ce3          	bne	a4,a3,80005012 <exec+0x270>
            last = s + 1;
    8000501e:	def43c23          	sd	a5,-520(s0)
    80005022:	bfc5                	j	80005012 <exec+0x270>
    safestrcpy(p->name, last, sizeof(p->name));
    80005024:	4641                	li	a2,16
    80005026:	df843583          	ld	a1,-520(s0)
    8000502a:	158a8513          	addi	a0,s5,344
    8000502e:	ffffc097          	auipc	ra,0xffffc
    80005032:	e7e080e7          	jalr	-386(ra) # 80000eac <safestrcpy>
    oldpagetable = p->pagetable;
    80005036:	050ab503          	ld	a0,80(s5)
    p->pagetable = pagetable;
    8000503a:	057ab823          	sd	s7,80(s5)
    p->sz = sz;
    8000503e:	056ab423          	sd	s6,72(s5)
    p->trapframe->epc = elf.entry; // initial program counter = main
    80005042:	058ab783          	ld	a5,88(s5)
    80005046:	e6043703          	ld	a4,-416(s0)
    8000504a:	ef98                	sd	a4,24(a5)
    p->trapframe->sp = sp; // initial stack pointer
    8000504c:	058ab783          	ld	a5,88(s5)
    80005050:	0327b823          	sd	s2,48(a5)
    proc_freepagetable(oldpagetable, oldsz);
    80005054:	85ea                	mv	a1,s10
    80005056:	ffffd097          	auipc	ra,0xffffd
    8000505a:	c1a080e7          	jalr	-998(ra) # 80001c70 <proc_freepagetable>
    if (p->pid == 1)
    8000505e:	038aa703          	lw	a4,56(s5)
    80005062:	4785                	li	a5,1
    80005064:	00f70563          	beq	a4,a5,8000506e <exec+0x2cc>
    return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005068:	0004851b          	sext.w	a0,s1
    8000506c:	b3f9                	j	80004e3a <exec+0x98>
        vmprint(p->pagetable, 0, vmprint_dfs);
    8000506e:	ffffd617          	auipc	a2,0xffffd
    80005072:	87a60613          	addi	a2,a2,-1926 # 800018e8 <vmprint_dfs>
    80005076:	4581                	li	a1,0
    80005078:	050ab503          	ld	a0,80(s5)
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	920080e7          	jalr	-1760(ra) # 8000199c <vmprint>
    80005084:	b7d5                	j	80005068 <exec+0x2c6>
    80005086:	e1243423          	sd	s2,-504(s0)
        proc_freepagetable(pagetable, sz);
    8000508a:	e0843583          	ld	a1,-504(s0)
    8000508e:	855e                	mv	a0,s7
    80005090:	ffffd097          	auipc	ra,0xffffd
    80005094:	be0080e7          	jalr	-1056(ra) # 80001c70 <proc_freepagetable>
    if (ip)
    80005098:	d80497e3          	bnez	s1,80004e26 <exec+0x84>
    return -1;
    8000509c:	557d                	li	a0,-1
    8000509e:	bb71                	j	80004e3a <exec+0x98>
    800050a0:	e1243423          	sd	s2,-504(s0)
    800050a4:	b7dd                	j	8000508a <exec+0x2e8>
    800050a6:	e1243423          	sd	s2,-504(s0)
    800050aa:	b7c5                	j	8000508a <exec+0x2e8>
    800050ac:	e1243423          	sd	s2,-504(s0)
    800050b0:	bfe9                	j	8000508a <exec+0x2e8>
    sz = sz1;
    800050b2:	e1643423          	sd	s6,-504(s0)
    ip = 0;
    800050b6:	4481                	li	s1,0
    800050b8:	bfc9                	j	8000508a <exec+0x2e8>
    sz = sz1;
    800050ba:	e1643423          	sd	s6,-504(s0)
    ip = 0;
    800050be:	4481                	li	s1,0
    800050c0:	b7e9                	j	8000508a <exec+0x2e8>
    sz = sz1;
    800050c2:	e1643423          	sd	s6,-504(s0)
    ip = 0;
    800050c6:	4481                	li	s1,0
    800050c8:	b7c9                	j	8000508a <exec+0x2e8>
        if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050ca:	e0843903          	ld	s2,-504(s0)
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    800050ce:	2b05                	addiw	s6,s6,1
    800050d0:	0389899b          	addiw	s3,s3,56
    800050d4:	e8045783          	lhu	a5,-384(s0)
    800050d8:	e0fb5ae3          	bge	s6,a5,80004eec <exec+0x14a>
        if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050dc:	2981                	sext.w	s3,s3
    800050de:	03800713          	li	a4,56
    800050e2:	86ce                	mv	a3,s3
    800050e4:	e1040613          	addi	a2,s0,-496
    800050e8:	4581                	li	a1,0
    800050ea:	8526                	mv	a0,s1
    800050ec:	fffff097          	auipc	ra,0xfffff
    800050f0:	a2c080e7          	jalr	-1492(ra) # 80003b18 <readi>
    800050f4:	03800793          	li	a5,56
    800050f8:	f8f517e3          	bne	a0,a5,80005086 <exec+0x2e4>
        if (ph.type != ELF_PROG_LOAD)
    800050fc:	e1042783          	lw	a5,-496(s0)
    80005100:	4705                	li	a4,1
    80005102:	fce796e3          	bne	a5,a4,800050ce <exec+0x32c>
        if (ph.memsz < ph.filesz)
    80005106:	e3843603          	ld	a2,-456(s0)
    8000510a:	e3043783          	ld	a5,-464(s0)
    8000510e:	f8f669e3          	bltu	a2,a5,800050a0 <exec+0x2fe>
        if (ph.vaddr + ph.memsz < ph.vaddr)
    80005112:	e2043783          	ld	a5,-480(s0)
    80005116:	963e                	add	a2,a2,a5
    80005118:	f8f667e3          	bltu	a2,a5,800050a6 <exec+0x304>
        if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000511c:	85ca                	mv	a1,s2
    8000511e:	855e                	mv	a0,s7
    80005120:	ffffc097          	auipc	ra,0xffffc
    80005124:	3ac080e7          	jalr	940(ra) # 800014cc <uvmalloc>
    80005128:	e0a43423          	sd	a0,-504(s0)
    8000512c:	d141                	beqz	a0,800050ac <exec+0x30a>
        if (ph.vaddr % PGSIZE != 0)
    8000512e:	e2043d03          	ld	s10,-480(s0)
    80005132:	df043783          	ld	a5,-528(s0)
    80005136:	00fd77b3          	and	a5,s10,a5
    8000513a:	fba1                	bnez	a5,8000508a <exec+0x2e8>
        if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000513c:	e1842d83          	lw	s11,-488(s0)
    80005140:	e3042c03          	lw	s8,-464(s0)
    for (i = 0; i < sz; i += PGSIZE)
    80005144:	f80c03e3          	beqz	s8,800050ca <exec+0x328>
    80005148:	8a62                	mv	s4,s8
    8000514a:	4901                	li	s2,0
    8000514c:	bbbd                	j	80004eca <exec+0x128>

000000008000514e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000514e:	7179                	addi	sp,sp,-48
    80005150:	f406                	sd	ra,40(sp)
    80005152:	f022                	sd	s0,32(sp)
    80005154:	ec26                	sd	s1,24(sp)
    80005156:	e84a                	sd	s2,16(sp)
    80005158:	1800                	addi	s0,sp,48
    8000515a:	892e                	mv	s2,a1
    8000515c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000515e:	fdc40593          	addi	a1,s0,-36
    80005162:	ffffe097          	auipc	ra,0xffffe
    80005166:	ac4080e7          	jalr	-1340(ra) # 80002c26 <argint>
    8000516a:	04054063          	bltz	a0,800051aa <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000516e:	fdc42703          	lw	a4,-36(s0)
    80005172:	47bd                	li	a5,15
    80005174:	02e7ed63          	bltu	a5,a4,800051ae <argfd+0x60>
    80005178:	ffffd097          	auipc	ra,0xffffd
    8000517c:	998080e7          	jalr	-1640(ra) # 80001b10 <myproc>
    80005180:	fdc42703          	lw	a4,-36(s0)
    80005184:	01a70793          	addi	a5,a4,26
    80005188:	078e                	slli	a5,a5,0x3
    8000518a:	953e                	add	a0,a0,a5
    8000518c:	611c                	ld	a5,0(a0)
    8000518e:	c395                	beqz	a5,800051b2 <argfd+0x64>
    return -1;
  if(pfd)
    80005190:	00090463          	beqz	s2,80005198 <argfd+0x4a>
    *pfd = fd;
    80005194:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005198:	4501                	li	a0,0
  if(pf)
    8000519a:	c091                	beqz	s1,8000519e <argfd+0x50>
    *pf = f;
    8000519c:	e09c                	sd	a5,0(s1)
}
    8000519e:	70a2                	ld	ra,40(sp)
    800051a0:	7402                	ld	s0,32(sp)
    800051a2:	64e2                	ld	s1,24(sp)
    800051a4:	6942                	ld	s2,16(sp)
    800051a6:	6145                	addi	sp,sp,48
    800051a8:	8082                	ret
    return -1;
    800051aa:	557d                	li	a0,-1
    800051ac:	bfcd                	j	8000519e <argfd+0x50>
    return -1;
    800051ae:	557d                	li	a0,-1
    800051b0:	b7fd                	j	8000519e <argfd+0x50>
    800051b2:	557d                	li	a0,-1
    800051b4:	b7ed                	j	8000519e <argfd+0x50>

00000000800051b6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051b6:	1101                	addi	sp,sp,-32
    800051b8:	ec06                	sd	ra,24(sp)
    800051ba:	e822                	sd	s0,16(sp)
    800051bc:	e426                	sd	s1,8(sp)
    800051be:	1000                	addi	s0,sp,32
    800051c0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051c2:	ffffd097          	auipc	ra,0xffffd
    800051c6:	94e080e7          	jalr	-1714(ra) # 80001b10 <myproc>
    800051ca:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051cc:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    800051d0:	4501                	li	a0,0
    800051d2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051d4:	6398                	ld	a4,0(a5)
    800051d6:	cb19                	beqz	a4,800051ec <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800051d8:	2505                	addiw	a0,a0,1
    800051da:	07a1                	addi	a5,a5,8
    800051dc:	fed51ce3          	bne	a0,a3,800051d4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051e0:	557d                	li	a0,-1
}
    800051e2:	60e2                	ld	ra,24(sp)
    800051e4:	6442                	ld	s0,16(sp)
    800051e6:	64a2                	ld	s1,8(sp)
    800051e8:	6105                	addi	sp,sp,32
    800051ea:	8082                	ret
      p->ofile[fd] = f;
    800051ec:	01a50793          	addi	a5,a0,26
    800051f0:	078e                	slli	a5,a5,0x3
    800051f2:	963e                	add	a2,a2,a5
    800051f4:	e204                	sd	s1,0(a2)
      return fd;
    800051f6:	b7f5                	j	800051e2 <fdalloc+0x2c>

00000000800051f8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051f8:	715d                	addi	sp,sp,-80
    800051fa:	e486                	sd	ra,72(sp)
    800051fc:	e0a2                	sd	s0,64(sp)
    800051fe:	fc26                	sd	s1,56(sp)
    80005200:	f84a                	sd	s2,48(sp)
    80005202:	f44e                	sd	s3,40(sp)
    80005204:	f052                	sd	s4,32(sp)
    80005206:	ec56                	sd	s5,24(sp)
    80005208:	0880                	addi	s0,sp,80
    8000520a:	89ae                	mv	s3,a1
    8000520c:	8ab2                	mv	s5,a2
    8000520e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005210:	fb040593          	addi	a1,s0,-80
    80005214:	fffff097          	auipc	ra,0xfffff
    80005218:	e1e080e7          	jalr	-482(ra) # 80004032 <nameiparent>
    8000521c:	892a                	mv	s2,a0
    8000521e:	12050f63          	beqz	a0,8000535c <create+0x164>
    return 0;

  ilock(dp);
    80005222:	ffffe097          	auipc	ra,0xffffe
    80005226:	642080e7          	jalr	1602(ra) # 80003864 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000522a:	4601                	li	a2,0
    8000522c:	fb040593          	addi	a1,s0,-80
    80005230:	854a                	mv	a0,s2
    80005232:	fffff097          	auipc	ra,0xfffff
    80005236:	b10080e7          	jalr	-1264(ra) # 80003d42 <dirlookup>
    8000523a:	84aa                	mv	s1,a0
    8000523c:	c921                	beqz	a0,8000528c <create+0x94>
    iunlockput(dp);
    8000523e:	854a                	mv	a0,s2
    80005240:	fffff097          	auipc	ra,0xfffff
    80005244:	886080e7          	jalr	-1914(ra) # 80003ac6 <iunlockput>
    ilock(ip);
    80005248:	8526                	mv	a0,s1
    8000524a:	ffffe097          	auipc	ra,0xffffe
    8000524e:	61a080e7          	jalr	1562(ra) # 80003864 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005252:	2981                	sext.w	s3,s3
    80005254:	4789                	li	a5,2
    80005256:	02f99463          	bne	s3,a5,8000527e <create+0x86>
    8000525a:	0444d783          	lhu	a5,68(s1)
    8000525e:	37f9                	addiw	a5,a5,-2
    80005260:	17c2                	slli	a5,a5,0x30
    80005262:	93c1                	srli	a5,a5,0x30
    80005264:	4705                	li	a4,1
    80005266:	00f76c63          	bltu	a4,a5,8000527e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000526a:	8526                	mv	a0,s1
    8000526c:	60a6                	ld	ra,72(sp)
    8000526e:	6406                	ld	s0,64(sp)
    80005270:	74e2                	ld	s1,56(sp)
    80005272:	7942                	ld	s2,48(sp)
    80005274:	79a2                	ld	s3,40(sp)
    80005276:	7a02                	ld	s4,32(sp)
    80005278:	6ae2                	ld	s5,24(sp)
    8000527a:	6161                	addi	sp,sp,80
    8000527c:	8082                	ret
    iunlockput(ip);
    8000527e:	8526                	mv	a0,s1
    80005280:	fffff097          	auipc	ra,0xfffff
    80005284:	846080e7          	jalr	-1978(ra) # 80003ac6 <iunlockput>
    return 0;
    80005288:	4481                	li	s1,0
    8000528a:	b7c5                	j	8000526a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000528c:	85ce                	mv	a1,s3
    8000528e:	00092503          	lw	a0,0(s2)
    80005292:	ffffe097          	auipc	ra,0xffffe
    80005296:	43a080e7          	jalr	1082(ra) # 800036cc <ialloc>
    8000529a:	84aa                	mv	s1,a0
    8000529c:	c529                	beqz	a0,800052e6 <create+0xee>
  ilock(ip);
    8000529e:	ffffe097          	auipc	ra,0xffffe
    800052a2:	5c6080e7          	jalr	1478(ra) # 80003864 <ilock>
  ip->major = major;
    800052a6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800052aa:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800052ae:	4785                	li	a5,1
    800052b0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052b4:	8526                	mv	a0,s1
    800052b6:	ffffe097          	auipc	ra,0xffffe
    800052ba:	4e4080e7          	jalr	1252(ra) # 8000379a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052be:	2981                	sext.w	s3,s3
    800052c0:	4785                	li	a5,1
    800052c2:	02f98a63          	beq	s3,a5,800052f6 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800052c6:	40d0                	lw	a2,4(s1)
    800052c8:	fb040593          	addi	a1,s0,-80
    800052cc:	854a                	mv	a0,s2
    800052ce:	fffff097          	auipc	ra,0xfffff
    800052d2:	c84080e7          	jalr	-892(ra) # 80003f52 <dirlink>
    800052d6:	06054b63          	bltz	a0,8000534c <create+0x154>
  iunlockput(dp);
    800052da:	854a                	mv	a0,s2
    800052dc:	ffffe097          	auipc	ra,0xffffe
    800052e0:	7ea080e7          	jalr	2026(ra) # 80003ac6 <iunlockput>
  return ip;
    800052e4:	b759                	j	8000526a <create+0x72>
    panic("create: ialloc");
    800052e6:	00003517          	auipc	a0,0x3
    800052ea:	4f250513          	addi	a0,a0,1266 # 800087d8 <syscalls+0x2b8>
    800052ee:	ffffb097          	auipc	ra,0xffffb
    800052f2:	25a080e7          	jalr	602(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    800052f6:	04a95783          	lhu	a5,74(s2)
    800052fa:	2785                	addiw	a5,a5,1
    800052fc:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005300:	854a                	mv	a0,s2
    80005302:	ffffe097          	auipc	ra,0xffffe
    80005306:	498080e7          	jalr	1176(ra) # 8000379a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000530a:	40d0                	lw	a2,4(s1)
    8000530c:	00003597          	auipc	a1,0x3
    80005310:	4dc58593          	addi	a1,a1,1244 # 800087e8 <syscalls+0x2c8>
    80005314:	8526                	mv	a0,s1
    80005316:	fffff097          	auipc	ra,0xfffff
    8000531a:	c3c080e7          	jalr	-964(ra) # 80003f52 <dirlink>
    8000531e:	00054f63          	bltz	a0,8000533c <create+0x144>
    80005322:	00492603          	lw	a2,4(s2)
    80005326:	00003597          	auipc	a1,0x3
    8000532a:	4ca58593          	addi	a1,a1,1226 # 800087f0 <syscalls+0x2d0>
    8000532e:	8526                	mv	a0,s1
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	c22080e7          	jalr	-990(ra) # 80003f52 <dirlink>
    80005338:	f80557e3          	bgez	a0,800052c6 <create+0xce>
      panic("create dots");
    8000533c:	00003517          	auipc	a0,0x3
    80005340:	4bc50513          	addi	a0,a0,1212 # 800087f8 <syscalls+0x2d8>
    80005344:	ffffb097          	auipc	ra,0xffffb
    80005348:	204080e7          	jalr	516(ra) # 80000548 <panic>
    panic("create: dirlink");
    8000534c:	00003517          	auipc	a0,0x3
    80005350:	4bc50513          	addi	a0,a0,1212 # 80008808 <syscalls+0x2e8>
    80005354:	ffffb097          	auipc	ra,0xffffb
    80005358:	1f4080e7          	jalr	500(ra) # 80000548 <panic>
    return 0;
    8000535c:	84aa                	mv	s1,a0
    8000535e:	b731                	j	8000526a <create+0x72>

0000000080005360 <sys_dup>:
{
    80005360:	7179                	addi	sp,sp,-48
    80005362:	f406                	sd	ra,40(sp)
    80005364:	f022                	sd	s0,32(sp)
    80005366:	ec26                	sd	s1,24(sp)
    80005368:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000536a:	fd840613          	addi	a2,s0,-40
    8000536e:	4581                	li	a1,0
    80005370:	4501                	li	a0,0
    80005372:	00000097          	auipc	ra,0x0
    80005376:	ddc080e7          	jalr	-548(ra) # 8000514e <argfd>
    return -1;
    8000537a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000537c:	02054363          	bltz	a0,800053a2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005380:	fd843503          	ld	a0,-40(s0)
    80005384:	00000097          	auipc	ra,0x0
    80005388:	e32080e7          	jalr	-462(ra) # 800051b6 <fdalloc>
    8000538c:	84aa                	mv	s1,a0
    return -1;
    8000538e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005390:	00054963          	bltz	a0,800053a2 <sys_dup+0x42>
  filedup(f);
    80005394:	fd843503          	ld	a0,-40(s0)
    80005398:	fffff097          	auipc	ra,0xfffff
    8000539c:	308080e7          	jalr	776(ra) # 800046a0 <filedup>
  return fd;
    800053a0:	87a6                	mv	a5,s1
}
    800053a2:	853e                	mv	a0,a5
    800053a4:	70a2                	ld	ra,40(sp)
    800053a6:	7402                	ld	s0,32(sp)
    800053a8:	64e2                	ld	s1,24(sp)
    800053aa:	6145                	addi	sp,sp,48
    800053ac:	8082                	ret

00000000800053ae <sys_read>:
{
    800053ae:	7179                	addi	sp,sp,-48
    800053b0:	f406                	sd	ra,40(sp)
    800053b2:	f022                	sd	s0,32(sp)
    800053b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053b6:	fe840613          	addi	a2,s0,-24
    800053ba:	4581                	li	a1,0
    800053bc:	4501                	li	a0,0
    800053be:	00000097          	auipc	ra,0x0
    800053c2:	d90080e7          	jalr	-624(ra) # 8000514e <argfd>
    return -1;
    800053c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053c8:	04054163          	bltz	a0,8000540a <sys_read+0x5c>
    800053cc:	fe440593          	addi	a1,s0,-28
    800053d0:	4509                	li	a0,2
    800053d2:	ffffe097          	auipc	ra,0xffffe
    800053d6:	854080e7          	jalr	-1964(ra) # 80002c26 <argint>
    return -1;
    800053da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053dc:	02054763          	bltz	a0,8000540a <sys_read+0x5c>
    800053e0:	fd840593          	addi	a1,s0,-40
    800053e4:	4505                	li	a0,1
    800053e6:	ffffe097          	auipc	ra,0xffffe
    800053ea:	862080e7          	jalr	-1950(ra) # 80002c48 <argaddr>
    return -1;
    800053ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053f0:	00054d63          	bltz	a0,8000540a <sys_read+0x5c>
  return fileread(f, p, n);
    800053f4:	fe442603          	lw	a2,-28(s0)
    800053f8:	fd843583          	ld	a1,-40(s0)
    800053fc:	fe843503          	ld	a0,-24(s0)
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	42c080e7          	jalr	1068(ra) # 8000482c <fileread>
    80005408:	87aa                	mv	a5,a0
}
    8000540a:	853e                	mv	a0,a5
    8000540c:	70a2                	ld	ra,40(sp)
    8000540e:	7402                	ld	s0,32(sp)
    80005410:	6145                	addi	sp,sp,48
    80005412:	8082                	ret

0000000080005414 <sys_write>:
{
    80005414:	7179                	addi	sp,sp,-48
    80005416:	f406                	sd	ra,40(sp)
    80005418:	f022                	sd	s0,32(sp)
    8000541a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000541c:	fe840613          	addi	a2,s0,-24
    80005420:	4581                	li	a1,0
    80005422:	4501                	li	a0,0
    80005424:	00000097          	auipc	ra,0x0
    80005428:	d2a080e7          	jalr	-726(ra) # 8000514e <argfd>
    return -1;
    8000542c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000542e:	04054163          	bltz	a0,80005470 <sys_write+0x5c>
    80005432:	fe440593          	addi	a1,s0,-28
    80005436:	4509                	li	a0,2
    80005438:	ffffd097          	auipc	ra,0xffffd
    8000543c:	7ee080e7          	jalr	2030(ra) # 80002c26 <argint>
    return -1;
    80005440:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005442:	02054763          	bltz	a0,80005470 <sys_write+0x5c>
    80005446:	fd840593          	addi	a1,s0,-40
    8000544a:	4505                	li	a0,1
    8000544c:	ffffd097          	auipc	ra,0xffffd
    80005450:	7fc080e7          	jalr	2044(ra) # 80002c48 <argaddr>
    return -1;
    80005454:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005456:	00054d63          	bltz	a0,80005470 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000545a:	fe442603          	lw	a2,-28(s0)
    8000545e:	fd843583          	ld	a1,-40(s0)
    80005462:	fe843503          	ld	a0,-24(s0)
    80005466:	fffff097          	auipc	ra,0xfffff
    8000546a:	488080e7          	jalr	1160(ra) # 800048ee <filewrite>
    8000546e:	87aa                	mv	a5,a0
}
    80005470:	853e                	mv	a0,a5
    80005472:	70a2                	ld	ra,40(sp)
    80005474:	7402                	ld	s0,32(sp)
    80005476:	6145                	addi	sp,sp,48
    80005478:	8082                	ret

000000008000547a <sys_close>:
{
    8000547a:	1101                	addi	sp,sp,-32
    8000547c:	ec06                	sd	ra,24(sp)
    8000547e:	e822                	sd	s0,16(sp)
    80005480:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005482:	fe040613          	addi	a2,s0,-32
    80005486:	fec40593          	addi	a1,s0,-20
    8000548a:	4501                	li	a0,0
    8000548c:	00000097          	auipc	ra,0x0
    80005490:	cc2080e7          	jalr	-830(ra) # 8000514e <argfd>
    return -1;
    80005494:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005496:	02054463          	bltz	a0,800054be <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000549a:	ffffc097          	auipc	ra,0xffffc
    8000549e:	676080e7          	jalr	1654(ra) # 80001b10 <myproc>
    800054a2:	fec42783          	lw	a5,-20(s0)
    800054a6:	07e9                	addi	a5,a5,26
    800054a8:	078e                	slli	a5,a5,0x3
    800054aa:	97aa                	add	a5,a5,a0
    800054ac:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800054b0:	fe043503          	ld	a0,-32(s0)
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	23e080e7          	jalr	574(ra) # 800046f2 <fileclose>
  return 0;
    800054bc:	4781                	li	a5,0
}
    800054be:	853e                	mv	a0,a5
    800054c0:	60e2                	ld	ra,24(sp)
    800054c2:	6442                	ld	s0,16(sp)
    800054c4:	6105                	addi	sp,sp,32
    800054c6:	8082                	ret

00000000800054c8 <sys_fstat>:
{
    800054c8:	1101                	addi	sp,sp,-32
    800054ca:	ec06                	sd	ra,24(sp)
    800054cc:	e822                	sd	s0,16(sp)
    800054ce:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054d0:	fe840613          	addi	a2,s0,-24
    800054d4:	4581                	li	a1,0
    800054d6:	4501                	li	a0,0
    800054d8:	00000097          	auipc	ra,0x0
    800054dc:	c76080e7          	jalr	-906(ra) # 8000514e <argfd>
    return -1;
    800054e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054e2:	02054563          	bltz	a0,8000550c <sys_fstat+0x44>
    800054e6:	fe040593          	addi	a1,s0,-32
    800054ea:	4505                	li	a0,1
    800054ec:	ffffd097          	auipc	ra,0xffffd
    800054f0:	75c080e7          	jalr	1884(ra) # 80002c48 <argaddr>
    return -1;
    800054f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054f6:	00054b63          	bltz	a0,8000550c <sys_fstat+0x44>
  return filestat(f, st);
    800054fa:	fe043583          	ld	a1,-32(s0)
    800054fe:	fe843503          	ld	a0,-24(s0)
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	2b8080e7          	jalr	696(ra) # 800047ba <filestat>
    8000550a:	87aa                	mv	a5,a0
}
    8000550c:	853e                	mv	a0,a5
    8000550e:	60e2                	ld	ra,24(sp)
    80005510:	6442                	ld	s0,16(sp)
    80005512:	6105                	addi	sp,sp,32
    80005514:	8082                	ret

0000000080005516 <sys_link>:
{
    80005516:	7169                	addi	sp,sp,-304
    80005518:	f606                	sd	ra,296(sp)
    8000551a:	f222                	sd	s0,288(sp)
    8000551c:	ee26                	sd	s1,280(sp)
    8000551e:	ea4a                	sd	s2,272(sp)
    80005520:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005522:	08000613          	li	a2,128
    80005526:	ed040593          	addi	a1,s0,-304
    8000552a:	4501                	li	a0,0
    8000552c:	ffffd097          	auipc	ra,0xffffd
    80005530:	73e080e7          	jalr	1854(ra) # 80002c6a <argstr>
    return -1;
    80005534:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005536:	10054e63          	bltz	a0,80005652 <sys_link+0x13c>
    8000553a:	08000613          	li	a2,128
    8000553e:	f5040593          	addi	a1,s0,-176
    80005542:	4505                	li	a0,1
    80005544:	ffffd097          	auipc	ra,0xffffd
    80005548:	726080e7          	jalr	1830(ra) # 80002c6a <argstr>
    return -1;
    8000554c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000554e:	10054263          	bltz	a0,80005652 <sys_link+0x13c>
  begin_op();
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	cce080e7          	jalr	-818(ra) # 80004220 <begin_op>
  if((ip = namei(old)) == 0){
    8000555a:	ed040513          	addi	a0,s0,-304
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	ab6080e7          	jalr	-1354(ra) # 80004014 <namei>
    80005566:	84aa                	mv	s1,a0
    80005568:	c551                	beqz	a0,800055f4 <sys_link+0xde>
  ilock(ip);
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	2fa080e7          	jalr	762(ra) # 80003864 <ilock>
  if(ip->type == T_DIR){
    80005572:	04449703          	lh	a4,68(s1)
    80005576:	4785                	li	a5,1
    80005578:	08f70463          	beq	a4,a5,80005600 <sys_link+0xea>
  ip->nlink++;
    8000557c:	04a4d783          	lhu	a5,74(s1)
    80005580:	2785                	addiw	a5,a5,1
    80005582:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005586:	8526                	mv	a0,s1
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	212080e7          	jalr	530(ra) # 8000379a <iupdate>
  iunlock(ip);
    80005590:	8526                	mv	a0,s1
    80005592:	ffffe097          	auipc	ra,0xffffe
    80005596:	394080e7          	jalr	916(ra) # 80003926 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000559a:	fd040593          	addi	a1,s0,-48
    8000559e:	f5040513          	addi	a0,s0,-176
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	a90080e7          	jalr	-1392(ra) # 80004032 <nameiparent>
    800055aa:	892a                	mv	s2,a0
    800055ac:	c935                	beqz	a0,80005620 <sys_link+0x10a>
  ilock(dp);
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	2b6080e7          	jalr	694(ra) # 80003864 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055b6:	00092703          	lw	a4,0(s2)
    800055ba:	409c                	lw	a5,0(s1)
    800055bc:	04f71d63          	bne	a4,a5,80005616 <sys_link+0x100>
    800055c0:	40d0                	lw	a2,4(s1)
    800055c2:	fd040593          	addi	a1,s0,-48
    800055c6:	854a                	mv	a0,s2
    800055c8:	fffff097          	auipc	ra,0xfffff
    800055cc:	98a080e7          	jalr	-1654(ra) # 80003f52 <dirlink>
    800055d0:	04054363          	bltz	a0,80005616 <sys_link+0x100>
  iunlockput(dp);
    800055d4:	854a                	mv	a0,s2
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	4f0080e7          	jalr	1264(ra) # 80003ac6 <iunlockput>
  iput(ip);
    800055de:	8526                	mv	a0,s1
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	43e080e7          	jalr	1086(ra) # 80003a1e <iput>
  end_op();
    800055e8:	fffff097          	auipc	ra,0xfffff
    800055ec:	cb8080e7          	jalr	-840(ra) # 800042a0 <end_op>
  return 0;
    800055f0:	4781                	li	a5,0
    800055f2:	a085                	j	80005652 <sys_link+0x13c>
    end_op();
    800055f4:	fffff097          	auipc	ra,0xfffff
    800055f8:	cac080e7          	jalr	-852(ra) # 800042a0 <end_op>
    return -1;
    800055fc:	57fd                	li	a5,-1
    800055fe:	a891                	j	80005652 <sys_link+0x13c>
    iunlockput(ip);
    80005600:	8526                	mv	a0,s1
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	4c4080e7          	jalr	1220(ra) # 80003ac6 <iunlockput>
    end_op();
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	c96080e7          	jalr	-874(ra) # 800042a0 <end_op>
    return -1;
    80005612:	57fd                	li	a5,-1
    80005614:	a83d                	j	80005652 <sys_link+0x13c>
    iunlockput(dp);
    80005616:	854a                	mv	a0,s2
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	4ae080e7          	jalr	1198(ra) # 80003ac6 <iunlockput>
  ilock(ip);
    80005620:	8526                	mv	a0,s1
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	242080e7          	jalr	578(ra) # 80003864 <ilock>
  ip->nlink--;
    8000562a:	04a4d783          	lhu	a5,74(s1)
    8000562e:	37fd                	addiw	a5,a5,-1
    80005630:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	164080e7          	jalr	356(ra) # 8000379a <iupdate>
  iunlockput(ip);
    8000563e:	8526                	mv	a0,s1
    80005640:	ffffe097          	auipc	ra,0xffffe
    80005644:	486080e7          	jalr	1158(ra) # 80003ac6 <iunlockput>
  end_op();
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	c58080e7          	jalr	-936(ra) # 800042a0 <end_op>
  return -1;
    80005650:	57fd                	li	a5,-1
}
    80005652:	853e                	mv	a0,a5
    80005654:	70b2                	ld	ra,296(sp)
    80005656:	7412                	ld	s0,288(sp)
    80005658:	64f2                	ld	s1,280(sp)
    8000565a:	6952                	ld	s2,272(sp)
    8000565c:	6155                	addi	sp,sp,304
    8000565e:	8082                	ret

0000000080005660 <sys_unlink>:
{
    80005660:	7151                	addi	sp,sp,-240
    80005662:	f586                	sd	ra,232(sp)
    80005664:	f1a2                	sd	s0,224(sp)
    80005666:	eda6                	sd	s1,216(sp)
    80005668:	e9ca                	sd	s2,208(sp)
    8000566a:	e5ce                	sd	s3,200(sp)
    8000566c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000566e:	08000613          	li	a2,128
    80005672:	f3040593          	addi	a1,s0,-208
    80005676:	4501                	li	a0,0
    80005678:	ffffd097          	auipc	ra,0xffffd
    8000567c:	5f2080e7          	jalr	1522(ra) # 80002c6a <argstr>
    80005680:	18054163          	bltz	a0,80005802 <sys_unlink+0x1a2>
  begin_op();
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	b9c080e7          	jalr	-1124(ra) # 80004220 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000568c:	fb040593          	addi	a1,s0,-80
    80005690:	f3040513          	addi	a0,s0,-208
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	99e080e7          	jalr	-1634(ra) # 80004032 <nameiparent>
    8000569c:	84aa                	mv	s1,a0
    8000569e:	c979                	beqz	a0,80005774 <sys_unlink+0x114>
  ilock(dp);
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	1c4080e7          	jalr	452(ra) # 80003864 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056a8:	00003597          	auipc	a1,0x3
    800056ac:	14058593          	addi	a1,a1,320 # 800087e8 <syscalls+0x2c8>
    800056b0:	fb040513          	addi	a0,s0,-80
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	674080e7          	jalr	1652(ra) # 80003d28 <namecmp>
    800056bc:	14050a63          	beqz	a0,80005810 <sys_unlink+0x1b0>
    800056c0:	00003597          	auipc	a1,0x3
    800056c4:	13058593          	addi	a1,a1,304 # 800087f0 <syscalls+0x2d0>
    800056c8:	fb040513          	addi	a0,s0,-80
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	65c080e7          	jalr	1628(ra) # 80003d28 <namecmp>
    800056d4:	12050e63          	beqz	a0,80005810 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056d8:	f2c40613          	addi	a2,s0,-212
    800056dc:	fb040593          	addi	a1,s0,-80
    800056e0:	8526                	mv	a0,s1
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	660080e7          	jalr	1632(ra) # 80003d42 <dirlookup>
    800056ea:	892a                	mv	s2,a0
    800056ec:	12050263          	beqz	a0,80005810 <sys_unlink+0x1b0>
  ilock(ip);
    800056f0:	ffffe097          	auipc	ra,0xffffe
    800056f4:	174080e7          	jalr	372(ra) # 80003864 <ilock>
  if(ip->nlink < 1)
    800056f8:	04a91783          	lh	a5,74(s2)
    800056fc:	08f05263          	blez	a5,80005780 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005700:	04491703          	lh	a4,68(s2)
    80005704:	4785                	li	a5,1
    80005706:	08f70563          	beq	a4,a5,80005790 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000570a:	4641                	li	a2,16
    8000570c:	4581                	li	a1,0
    8000570e:	fc040513          	addi	a0,s0,-64
    80005712:	ffffb097          	auipc	ra,0xffffb
    80005716:	644080e7          	jalr	1604(ra) # 80000d56 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000571a:	4741                	li	a4,16
    8000571c:	f2c42683          	lw	a3,-212(s0)
    80005720:	fc040613          	addi	a2,s0,-64
    80005724:	4581                	li	a1,0
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	4e6080e7          	jalr	1254(ra) # 80003c0e <writei>
    80005730:	47c1                	li	a5,16
    80005732:	0af51563          	bne	a0,a5,800057dc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005736:	04491703          	lh	a4,68(s2)
    8000573a:	4785                	li	a5,1
    8000573c:	0af70863          	beq	a4,a5,800057ec <sys_unlink+0x18c>
  iunlockput(dp);
    80005740:	8526                	mv	a0,s1
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	384080e7          	jalr	900(ra) # 80003ac6 <iunlockput>
  ip->nlink--;
    8000574a:	04a95783          	lhu	a5,74(s2)
    8000574e:	37fd                	addiw	a5,a5,-1
    80005750:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005754:	854a                	mv	a0,s2
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	044080e7          	jalr	68(ra) # 8000379a <iupdate>
  iunlockput(ip);
    8000575e:	854a                	mv	a0,s2
    80005760:	ffffe097          	auipc	ra,0xffffe
    80005764:	366080e7          	jalr	870(ra) # 80003ac6 <iunlockput>
  end_op();
    80005768:	fffff097          	auipc	ra,0xfffff
    8000576c:	b38080e7          	jalr	-1224(ra) # 800042a0 <end_op>
  return 0;
    80005770:	4501                	li	a0,0
    80005772:	a84d                	j	80005824 <sys_unlink+0x1c4>
    end_op();
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	b2c080e7          	jalr	-1236(ra) # 800042a0 <end_op>
    return -1;
    8000577c:	557d                	li	a0,-1
    8000577e:	a05d                	j	80005824 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005780:	00003517          	auipc	a0,0x3
    80005784:	09850513          	addi	a0,a0,152 # 80008818 <syscalls+0x2f8>
    80005788:	ffffb097          	auipc	ra,0xffffb
    8000578c:	dc0080e7          	jalr	-576(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005790:	04c92703          	lw	a4,76(s2)
    80005794:	02000793          	li	a5,32
    80005798:	f6e7f9e3          	bgeu	a5,a4,8000570a <sys_unlink+0xaa>
    8000579c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057a0:	4741                	li	a4,16
    800057a2:	86ce                	mv	a3,s3
    800057a4:	f1840613          	addi	a2,s0,-232
    800057a8:	4581                	li	a1,0
    800057aa:	854a                	mv	a0,s2
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	36c080e7          	jalr	876(ra) # 80003b18 <readi>
    800057b4:	47c1                	li	a5,16
    800057b6:	00f51b63          	bne	a0,a5,800057cc <sys_unlink+0x16c>
    if(de.inum != 0)
    800057ba:	f1845783          	lhu	a5,-232(s0)
    800057be:	e7a1                	bnez	a5,80005806 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057c0:	29c1                	addiw	s3,s3,16
    800057c2:	04c92783          	lw	a5,76(s2)
    800057c6:	fcf9ede3          	bltu	s3,a5,800057a0 <sys_unlink+0x140>
    800057ca:	b781                	j	8000570a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800057cc:	00003517          	auipc	a0,0x3
    800057d0:	06450513          	addi	a0,a0,100 # 80008830 <syscalls+0x310>
    800057d4:	ffffb097          	auipc	ra,0xffffb
    800057d8:	d74080e7          	jalr	-652(ra) # 80000548 <panic>
    panic("unlink: writei");
    800057dc:	00003517          	auipc	a0,0x3
    800057e0:	06c50513          	addi	a0,a0,108 # 80008848 <syscalls+0x328>
    800057e4:	ffffb097          	auipc	ra,0xffffb
    800057e8:	d64080e7          	jalr	-668(ra) # 80000548 <panic>
    dp->nlink--;
    800057ec:	04a4d783          	lhu	a5,74(s1)
    800057f0:	37fd                	addiw	a5,a5,-1
    800057f2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057f6:	8526                	mv	a0,s1
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	fa2080e7          	jalr	-94(ra) # 8000379a <iupdate>
    80005800:	b781                	j	80005740 <sys_unlink+0xe0>
    return -1;
    80005802:	557d                	li	a0,-1
    80005804:	a005                	j	80005824 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005806:	854a                	mv	a0,s2
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	2be080e7          	jalr	702(ra) # 80003ac6 <iunlockput>
  iunlockput(dp);
    80005810:	8526                	mv	a0,s1
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	2b4080e7          	jalr	692(ra) # 80003ac6 <iunlockput>
  end_op();
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	a86080e7          	jalr	-1402(ra) # 800042a0 <end_op>
  return -1;
    80005822:	557d                	li	a0,-1
}
    80005824:	70ae                	ld	ra,232(sp)
    80005826:	740e                	ld	s0,224(sp)
    80005828:	64ee                	ld	s1,216(sp)
    8000582a:	694e                	ld	s2,208(sp)
    8000582c:	69ae                	ld	s3,200(sp)
    8000582e:	616d                	addi	sp,sp,240
    80005830:	8082                	ret

0000000080005832 <sys_open>:

uint64
sys_open(void)
{
    80005832:	7131                	addi	sp,sp,-192
    80005834:	fd06                	sd	ra,184(sp)
    80005836:	f922                	sd	s0,176(sp)
    80005838:	f526                	sd	s1,168(sp)
    8000583a:	f14a                	sd	s2,160(sp)
    8000583c:	ed4e                	sd	s3,152(sp)
    8000583e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005840:	08000613          	li	a2,128
    80005844:	f5040593          	addi	a1,s0,-176
    80005848:	4501                	li	a0,0
    8000584a:	ffffd097          	auipc	ra,0xffffd
    8000584e:	420080e7          	jalr	1056(ra) # 80002c6a <argstr>
    return -1;
    80005852:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005854:	0c054163          	bltz	a0,80005916 <sys_open+0xe4>
    80005858:	f4c40593          	addi	a1,s0,-180
    8000585c:	4505                	li	a0,1
    8000585e:	ffffd097          	auipc	ra,0xffffd
    80005862:	3c8080e7          	jalr	968(ra) # 80002c26 <argint>
    80005866:	0a054863          	bltz	a0,80005916 <sys_open+0xe4>

  begin_op();
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	9b6080e7          	jalr	-1610(ra) # 80004220 <begin_op>

  if(omode & O_CREATE){
    80005872:	f4c42783          	lw	a5,-180(s0)
    80005876:	2007f793          	andi	a5,a5,512
    8000587a:	cbdd                	beqz	a5,80005930 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000587c:	4681                	li	a3,0
    8000587e:	4601                	li	a2,0
    80005880:	4589                	li	a1,2
    80005882:	f5040513          	addi	a0,s0,-176
    80005886:	00000097          	auipc	ra,0x0
    8000588a:	972080e7          	jalr	-1678(ra) # 800051f8 <create>
    8000588e:	892a                	mv	s2,a0
    if(ip == 0){
    80005890:	c959                	beqz	a0,80005926 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005892:	04491703          	lh	a4,68(s2)
    80005896:	478d                	li	a5,3
    80005898:	00f71763          	bne	a4,a5,800058a6 <sys_open+0x74>
    8000589c:	04695703          	lhu	a4,70(s2)
    800058a0:	47a5                	li	a5,9
    800058a2:	0ce7ec63          	bltu	a5,a4,8000597a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058a6:	fffff097          	auipc	ra,0xfffff
    800058aa:	d90080e7          	jalr	-624(ra) # 80004636 <filealloc>
    800058ae:	89aa                	mv	s3,a0
    800058b0:	10050263          	beqz	a0,800059b4 <sys_open+0x182>
    800058b4:	00000097          	auipc	ra,0x0
    800058b8:	902080e7          	jalr	-1790(ra) # 800051b6 <fdalloc>
    800058bc:	84aa                	mv	s1,a0
    800058be:	0e054663          	bltz	a0,800059aa <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058c2:	04491703          	lh	a4,68(s2)
    800058c6:	478d                	li	a5,3
    800058c8:	0cf70463          	beq	a4,a5,80005990 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058cc:	4789                	li	a5,2
    800058ce:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800058d2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800058d6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800058da:	f4c42783          	lw	a5,-180(s0)
    800058de:	0017c713          	xori	a4,a5,1
    800058e2:	8b05                	andi	a4,a4,1
    800058e4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058e8:	0037f713          	andi	a4,a5,3
    800058ec:	00e03733          	snez	a4,a4
    800058f0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058f4:	4007f793          	andi	a5,a5,1024
    800058f8:	c791                	beqz	a5,80005904 <sys_open+0xd2>
    800058fa:	04491703          	lh	a4,68(s2)
    800058fe:	4789                	li	a5,2
    80005900:	08f70f63          	beq	a4,a5,8000599e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005904:	854a                	mv	a0,s2
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	020080e7          	jalr	32(ra) # 80003926 <iunlock>
  end_op();
    8000590e:	fffff097          	auipc	ra,0xfffff
    80005912:	992080e7          	jalr	-1646(ra) # 800042a0 <end_op>

  return fd;
}
    80005916:	8526                	mv	a0,s1
    80005918:	70ea                	ld	ra,184(sp)
    8000591a:	744a                	ld	s0,176(sp)
    8000591c:	74aa                	ld	s1,168(sp)
    8000591e:	790a                	ld	s2,160(sp)
    80005920:	69ea                	ld	s3,152(sp)
    80005922:	6129                	addi	sp,sp,192
    80005924:	8082                	ret
      end_op();
    80005926:	fffff097          	auipc	ra,0xfffff
    8000592a:	97a080e7          	jalr	-1670(ra) # 800042a0 <end_op>
      return -1;
    8000592e:	b7e5                	j	80005916 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005930:	f5040513          	addi	a0,s0,-176
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	6e0080e7          	jalr	1760(ra) # 80004014 <namei>
    8000593c:	892a                	mv	s2,a0
    8000593e:	c905                	beqz	a0,8000596e <sys_open+0x13c>
    ilock(ip);
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	f24080e7          	jalr	-220(ra) # 80003864 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005948:	04491703          	lh	a4,68(s2)
    8000594c:	4785                	li	a5,1
    8000594e:	f4f712e3          	bne	a4,a5,80005892 <sys_open+0x60>
    80005952:	f4c42783          	lw	a5,-180(s0)
    80005956:	dba1                	beqz	a5,800058a6 <sys_open+0x74>
      iunlockput(ip);
    80005958:	854a                	mv	a0,s2
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	16c080e7          	jalr	364(ra) # 80003ac6 <iunlockput>
      end_op();
    80005962:	fffff097          	auipc	ra,0xfffff
    80005966:	93e080e7          	jalr	-1730(ra) # 800042a0 <end_op>
      return -1;
    8000596a:	54fd                	li	s1,-1
    8000596c:	b76d                	j	80005916 <sys_open+0xe4>
      end_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	932080e7          	jalr	-1742(ra) # 800042a0 <end_op>
      return -1;
    80005976:	54fd                	li	s1,-1
    80005978:	bf79                	j	80005916 <sys_open+0xe4>
    iunlockput(ip);
    8000597a:	854a                	mv	a0,s2
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	14a080e7          	jalr	330(ra) # 80003ac6 <iunlockput>
    end_op();
    80005984:	fffff097          	auipc	ra,0xfffff
    80005988:	91c080e7          	jalr	-1764(ra) # 800042a0 <end_op>
    return -1;
    8000598c:	54fd                	li	s1,-1
    8000598e:	b761                	j	80005916 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005990:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005994:	04691783          	lh	a5,70(s2)
    80005998:	02f99223          	sh	a5,36(s3)
    8000599c:	bf2d                	j	800058d6 <sys_open+0xa4>
    itrunc(ip);
    8000599e:	854a                	mv	a0,s2
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	fd2080e7          	jalr	-46(ra) # 80003972 <itrunc>
    800059a8:	bfb1                	j	80005904 <sys_open+0xd2>
      fileclose(f);
    800059aa:	854e                	mv	a0,s3
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	d46080e7          	jalr	-698(ra) # 800046f2 <fileclose>
    iunlockput(ip);
    800059b4:	854a                	mv	a0,s2
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	110080e7          	jalr	272(ra) # 80003ac6 <iunlockput>
    end_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	8e2080e7          	jalr	-1822(ra) # 800042a0 <end_op>
    return -1;
    800059c6:	54fd                	li	s1,-1
    800059c8:	b7b9                	j	80005916 <sys_open+0xe4>

00000000800059ca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059ca:	7175                	addi	sp,sp,-144
    800059cc:	e506                	sd	ra,136(sp)
    800059ce:	e122                	sd	s0,128(sp)
    800059d0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	84e080e7          	jalr	-1970(ra) # 80004220 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059da:	08000613          	li	a2,128
    800059de:	f7040593          	addi	a1,s0,-144
    800059e2:	4501                	li	a0,0
    800059e4:	ffffd097          	auipc	ra,0xffffd
    800059e8:	286080e7          	jalr	646(ra) # 80002c6a <argstr>
    800059ec:	02054963          	bltz	a0,80005a1e <sys_mkdir+0x54>
    800059f0:	4681                	li	a3,0
    800059f2:	4601                	li	a2,0
    800059f4:	4585                	li	a1,1
    800059f6:	f7040513          	addi	a0,s0,-144
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	7fe080e7          	jalr	2046(ra) # 800051f8 <create>
    80005a02:	cd11                	beqz	a0,80005a1e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	0c2080e7          	jalr	194(ra) # 80003ac6 <iunlockput>
  end_op();
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	894080e7          	jalr	-1900(ra) # 800042a0 <end_op>
  return 0;
    80005a14:	4501                	li	a0,0
}
    80005a16:	60aa                	ld	ra,136(sp)
    80005a18:	640a                	ld	s0,128(sp)
    80005a1a:	6149                	addi	sp,sp,144
    80005a1c:	8082                	ret
    end_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	882080e7          	jalr	-1918(ra) # 800042a0 <end_op>
    return -1;
    80005a26:	557d                	li	a0,-1
    80005a28:	b7fd                	j	80005a16 <sys_mkdir+0x4c>

0000000080005a2a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a2a:	7135                	addi	sp,sp,-160
    80005a2c:	ed06                	sd	ra,152(sp)
    80005a2e:	e922                	sd	s0,144(sp)
    80005a30:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	7ee080e7          	jalr	2030(ra) # 80004220 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a3a:	08000613          	li	a2,128
    80005a3e:	f7040593          	addi	a1,s0,-144
    80005a42:	4501                	li	a0,0
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	226080e7          	jalr	550(ra) # 80002c6a <argstr>
    80005a4c:	04054a63          	bltz	a0,80005aa0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a50:	f6c40593          	addi	a1,s0,-148
    80005a54:	4505                	li	a0,1
    80005a56:	ffffd097          	auipc	ra,0xffffd
    80005a5a:	1d0080e7          	jalr	464(ra) # 80002c26 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a5e:	04054163          	bltz	a0,80005aa0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005a62:	f6840593          	addi	a1,s0,-152
    80005a66:	4509                	li	a0,2
    80005a68:	ffffd097          	auipc	ra,0xffffd
    80005a6c:	1be080e7          	jalr	446(ra) # 80002c26 <argint>
     argint(1, &major) < 0 ||
    80005a70:	02054863          	bltz	a0,80005aa0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a74:	f6841683          	lh	a3,-152(s0)
    80005a78:	f6c41603          	lh	a2,-148(s0)
    80005a7c:	458d                	li	a1,3
    80005a7e:	f7040513          	addi	a0,s0,-144
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	776080e7          	jalr	1910(ra) # 800051f8 <create>
     argint(2, &minor) < 0 ||
    80005a8a:	c919                	beqz	a0,80005aa0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	03a080e7          	jalr	58(ra) # 80003ac6 <iunlockput>
  end_op();
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	80c080e7          	jalr	-2036(ra) # 800042a0 <end_op>
  return 0;
    80005a9c:	4501                	li	a0,0
    80005a9e:	a031                	j	80005aaa <sys_mknod+0x80>
    end_op();
    80005aa0:	fffff097          	auipc	ra,0xfffff
    80005aa4:	800080e7          	jalr	-2048(ra) # 800042a0 <end_op>
    return -1;
    80005aa8:	557d                	li	a0,-1
}
    80005aaa:	60ea                	ld	ra,152(sp)
    80005aac:	644a                	ld	s0,144(sp)
    80005aae:	610d                	addi	sp,sp,160
    80005ab0:	8082                	ret

0000000080005ab2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ab2:	7135                	addi	sp,sp,-160
    80005ab4:	ed06                	sd	ra,152(sp)
    80005ab6:	e922                	sd	s0,144(sp)
    80005ab8:	e526                	sd	s1,136(sp)
    80005aba:	e14a                	sd	s2,128(sp)
    80005abc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005abe:	ffffc097          	auipc	ra,0xffffc
    80005ac2:	052080e7          	jalr	82(ra) # 80001b10 <myproc>
    80005ac6:	892a                	mv	s2,a0
  
  begin_op();
    80005ac8:	ffffe097          	auipc	ra,0xffffe
    80005acc:	758080e7          	jalr	1880(ra) # 80004220 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ad0:	08000613          	li	a2,128
    80005ad4:	f6040593          	addi	a1,s0,-160
    80005ad8:	4501                	li	a0,0
    80005ada:	ffffd097          	auipc	ra,0xffffd
    80005ade:	190080e7          	jalr	400(ra) # 80002c6a <argstr>
    80005ae2:	04054b63          	bltz	a0,80005b38 <sys_chdir+0x86>
    80005ae6:	f6040513          	addi	a0,s0,-160
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	52a080e7          	jalr	1322(ra) # 80004014 <namei>
    80005af2:	84aa                	mv	s1,a0
    80005af4:	c131                	beqz	a0,80005b38 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	d6e080e7          	jalr	-658(ra) # 80003864 <ilock>
  if(ip->type != T_DIR){
    80005afe:	04449703          	lh	a4,68(s1)
    80005b02:	4785                	li	a5,1
    80005b04:	04f71063          	bne	a4,a5,80005b44 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b08:	8526                	mv	a0,s1
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	e1c080e7          	jalr	-484(ra) # 80003926 <iunlock>
  iput(p->cwd);
    80005b12:	15093503          	ld	a0,336(s2)
    80005b16:	ffffe097          	auipc	ra,0xffffe
    80005b1a:	f08080e7          	jalr	-248(ra) # 80003a1e <iput>
  end_op();
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	782080e7          	jalr	1922(ra) # 800042a0 <end_op>
  p->cwd = ip;
    80005b26:	14993823          	sd	s1,336(s2)
  return 0;
    80005b2a:	4501                	li	a0,0
}
    80005b2c:	60ea                	ld	ra,152(sp)
    80005b2e:	644a                	ld	s0,144(sp)
    80005b30:	64aa                	ld	s1,136(sp)
    80005b32:	690a                	ld	s2,128(sp)
    80005b34:	610d                	addi	sp,sp,160
    80005b36:	8082                	ret
    end_op();
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	768080e7          	jalr	1896(ra) # 800042a0 <end_op>
    return -1;
    80005b40:	557d                	li	a0,-1
    80005b42:	b7ed                	j	80005b2c <sys_chdir+0x7a>
    iunlockput(ip);
    80005b44:	8526                	mv	a0,s1
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	f80080e7          	jalr	-128(ra) # 80003ac6 <iunlockput>
    end_op();
    80005b4e:	ffffe097          	auipc	ra,0xffffe
    80005b52:	752080e7          	jalr	1874(ra) # 800042a0 <end_op>
    return -1;
    80005b56:	557d                	li	a0,-1
    80005b58:	bfd1                	j	80005b2c <sys_chdir+0x7a>

0000000080005b5a <sys_exec>:

uint64
sys_exec(void)
{
    80005b5a:	7145                	addi	sp,sp,-464
    80005b5c:	e786                	sd	ra,456(sp)
    80005b5e:	e3a2                	sd	s0,448(sp)
    80005b60:	ff26                	sd	s1,440(sp)
    80005b62:	fb4a                	sd	s2,432(sp)
    80005b64:	f74e                	sd	s3,424(sp)
    80005b66:	f352                	sd	s4,416(sp)
    80005b68:	ef56                	sd	s5,408(sp)
    80005b6a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b6c:	08000613          	li	a2,128
    80005b70:	f4040593          	addi	a1,s0,-192
    80005b74:	4501                	li	a0,0
    80005b76:	ffffd097          	auipc	ra,0xffffd
    80005b7a:	0f4080e7          	jalr	244(ra) # 80002c6a <argstr>
    return -1;
    80005b7e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b80:	0c054a63          	bltz	a0,80005c54 <sys_exec+0xfa>
    80005b84:	e3840593          	addi	a1,s0,-456
    80005b88:	4505                	li	a0,1
    80005b8a:	ffffd097          	auipc	ra,0xffffd
    80005b8e:	0be080e7          	jalr	190(ra) # 80002c48 <argaddr>
    80005b92:	0c054163          	bltz	a0,80005c54 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005b96:	10000613          	li	a2,256
    80005b9a:	4581                	li	a1,0
    80005b9c:	e4040513          	addi	a0,s0,-448
    80005ba0:	ffffb097          	auipc	ra,0xffffb
    80005ba4:	1b6080e7          	jalr	438(ra) # 80000d56 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ba8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005bac:	89a6                	mv	s3,s1
    80005bae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bb0:	02000a13          	li	s4,32
    80005bb4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bb8:	00391513          	slli	a0,s2,0x3
    80005bbc:	e3040593          	addi	a1,s0,-464
    80005bc0:	e3843783          	ld	a5,-456(s0)
    80005bc4:	953e                	add	a0,a0,a5
    80005bc6:	ffffd097          	auipc	ra,0xffffd
    80005bca:	fc6080e7          	jalr	-58(ra) # 80002b8c <fetchaddr>
    80005bce:	02054a63          	bltz	a0,80005c02 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005bd2:	e3043783          	ld	a5,-464(s0)
    80005bd6:	c3b9                	beqz	a5,80005c1c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005bd8:	ffffb097          	auipc	ra,0xffffb
    80005bdc:	f48080e7          	jalr	-184(ra) # 80000b20 <kalloc>
    80005be0:	85aa                	mv	a1,a0
    80005be2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005be6:	cd11                	beqz	a0,80005c02 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005be8:	6605                	lui	a2,0x1
    80005bea:	e3043503          	ld	a0,-464(s0)
    80005bee:	ffffd097          	auipc	ra,0xffffd
    80005bf2:	ff0080e7          	jalr	-16(ra) # 80002bde <fetchstr>
    80005bf6:	00054663          	bltz	a0,80005c02 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005bfa:	0905                	addi	s2,s2,1
    80005bfc:	09a1                	addi	s3,s3,8
    80005bfe:	fb491be3          	bne	s2,s4,80005bb4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c02:	10048913          	addi	s2,s1,256
    80005c06:	6088                	ld	a0,0(s1)
    80005c08:	c529                	beqz	a0,80005c52 <sys_exec+0xf8>
    kfree(argv[i]);
    80005c0a:	ffffb097          	auipc	ra,0xffffb
    80005c0e:	e1a080e7          	jalr	-486(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c12:	04a1                	addi	s1,s1,8
    80005c14:	ff2499e3          	bne	s1,s2,80005c06 <sys_exec+0xac>
  return -1;
    80005c18:	597d                	li	s2,-1
    80005c1a:	a82d                	j	80005c54 <sys_exec+0xfa>
      argv[i] = 0;
    80005c1c:	0a8e                	slli	s5,s5,0x3
    80005c1e:	fc040793          	addi	a5,s0,-64
    80005c22:	9abe                	add	s5,s5,a5
    80005c24:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c28:	e4040593          	addi	a1,s0,-448
    80005c2c:	f4040513          	addi	a0,s0,-192
    80005c30:	fffff097          	auipc	ra,0xfffff
    80005c34:	172080e7          	jalr	370(ra) # 80004da2 <exec>
    80005c38:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c3a:	10048993          	addi	s3,s1,256
    80005c3e:	6088                	ld	a0,0(s1)
    80005c40:	c911                	beqz	a0,80005c54 <sys_exec+0xfa>
    kfree(argv[i]);
    80005c42:	ffffb097          	auipc	ra,0xffffb
    80005c46:	de2080e7          	jalr	-542(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c4a:	04a1                	addi	s1,s1,8
    80005c4c:	ff3499e3          	bne	s1,s3,80005c3e <sys_exec+0xe4>
    80005c50:	a011                	j	80005c54 <sys_exec+0xfa>
  return -1;
    80005c52:	597d                	li	s2,-1
}
    80005c54:	854a                	mv	a0,s2
    80005c56:	60be                	ld	ra,456(sp)
    80005c58:	641e                	ld	s0,448(sp)
    80005c5a:	74fa                	ld	s1,440(sp)
    80005c5c:	795a                	ld	s2,432(sp)
    80005c5e:	79ba                	ld	s3,424(sp)
    80005c60:	7a1a                	ld	s4,416(sp)
    80005c62:	6afa                	ld	s5,408(sp)
    80005c64:	6179                	addi	sp,sp,464
    80005c66:	8082                	ret

0000000080005c68 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c68:	7139                	addi	sp,sp,-64
    80005c6a:	fc06                	sd	ra,56(sp)
    80005c6c:	f822                	sd	s0,48(sp)
    80005c6e:	f426                	sd	s1,40(sp)
    80005c70:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c72:	ffffc097          	auipc	ra,0xffffc
    80005c76:	e9e080e7          	jalr	-354(ra) # 80001b10 <myproc>
    80005c7a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005c7c:	fd840593          	addi	a1,s0,-40
    80005c80:	4501                	li	a0,0
    80005c82:	ffffd097          	auipc	ra,0xffffd
    80005c86:	fc6080e7          	jalr	-58(ra) # 80002c48 <argaddr>
    return -1;
    80005c8a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005c8c:	0e054063          	bltz	a0,80005d6c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005c90:	fc840593          	addi	a1,s0,-56
    80005c94:	fd040513          	addi	a0,s0,-48
    80005c98:	fffff097          	auipc	ra,0xfffff
    80005c9c:	db0080e7          	jalr	-592(ra) # 80004a48 <pipealloc>
    return -1;
    80005ca0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ca2:	0c054563          	bltz	a0,80005d6c <sys_pipe+0x104>
  fd0 = -1;
    80005ca6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005caa:	fd043503          	ld	a0,-48(s0)
    80005cae:	fffff097          	auipc	ra,0xfffff
    80005cb2:	508080e7          	jalr	1288(ra) # 800051b6 <fdalloc>
    80005cb6:	fca42223          	sw	a0,-60(s0)
    80005cba:	08054c63          	bltz	a0,80005d52 <sys_pipe+0xea>
    80005cbe:	fc843503          	ld	a0,-56(s0)
    80005cc2:	fffff097          	auipc	ra,0xfffff
    80005cc6:	4f4080e7          	jalr	1268(ra) # 800051b6 <fdalloc>
    80005cca:	fca42023          	sw	a0,-64(s0)
    80005cce:	06054863          	bltz	a0,80005d3e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cd2:	4691                	li	a3,4
    80005cd4:	fc440613          	addi	a2,s0,-60
    80005cd8:	fd843583          	ld	a1,-40(s0)
    80005cdc:	68a8                	ld	a0,80(s1)
    80005cde:	ffffc097          	auipc	ra,0xffffc
    80005ce2:	a3e080e7          	jalr	-1474(ra) # 8000171c <copyout>
    80005ce6:	02054063          	bltz	a0,80005d06 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cea:	4691                	li	a3,4
    80005cec:	fc040613          	addi	a2,s0,-64
    80005cf0:	fd843583          	ld	a1,-40(s0)
    80005cf4:	0591                	addi	a1,a1,4
    80005cf6:	68a8                	ld	a0,80(s1)
    80005cf8:	ffffc097          	auipc	ra,0xffffc
    80005cfc:	a24080e7          	jalr	-1500(ra) # 8000171c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d00:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d02:	06055563          	bgez	a0,80005d6c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d06:	fc442783          	lw	a5,-60(s0)
    80005d0a:	07e9                	addi	a5,a5,26
    80005d0c:	078e                	slli	a5,a5,0x3
    80005d0e:	97a6                	add	a5,a5,s1
    80005d10:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d14:	fc042503          	lw	a0,-64(s0)
    80005d18:	0569                	addi	a0,a0,26
    80005d1a:	050e                	slli	a0,a0,0x3
    80005d1c:	9526                	add	a0,a0,s1
    80005d1e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d22:	fd043503          	ld	a0,-48(s0)
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	9cc080e7          	jalr	-1588(ra) # 800046f2 <fileclose>
    fileclose(wf);
    80005d2e:	fc843503          	ld	a0,-56(s0)
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	9c0080e7          	jalr	-1600(ra) # 800046f2 <fileclose>
    return -1;
    80005d3a:	57fd                	li	a5,-1
    80005d3c:	a805                	j	80005d6c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005d3e:	fc442783          	lw	a5,-60(s0)
    80005d42:	0007c863          	bltz	a5,80005d52 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005d46:	01a78513          	addi	a0,a5,26
    80005d4a:	050e                	slli	a0,a0,0x3
    80005d4c:	9526                	add	a0,a0,s1
    80005d4e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d52:	fd043503          	ld	a0,-48(s0)
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	99c080e7          	jalr	-1636(ra) # 800046f2 <fileclose>
    fileclose(wf);
    80005d5e:	fc843503          	ld	a0,-56(s0)
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	990080e7          	jalr	-1648(ra) # 800046f2 <fileclose>
    return -1;
    80005d6a:	57fd                	li	a5,-1
}
    80005d6c:	853e                	mv	a0,a5
    80005d6e:	70e2                	ld	ra,56(sp)
    80005d70:	7442                	ld	s0,48(sp)
    80005d72:	74a2                	ld	s1,40(sp)
    80005d74:	6121                	addi	sp,sp,64
    80005d76:	8082                	ret
	...

0000000080005d80 <kernelvec>:
    80005d80:	7111                	addi	sp,sp,-256
    80005d82:	e006                	sd	ra,0(sp)
    80005d84:	e40a                	sd	sp,8(sp)
    80005d86:	e80e                	sd	gp,16(sp)
    80005d88:	ec12                	sd	tp,24(sp)
    80005d8a:	f016                	sd	t0,32(sp)
    80005d8c:	f41a                	sd	t1,40(sp)
    80005d8e:	f81e                	sd	t2,48(sp)
    80005d90:	fc22                	sd	s0,56(sp)
    80005d92:	e0a6                	sd	s1,64(sp)
    80005d94:	e4aa                	sd	a0,72(sp)
    80005d96:	e8ae                	sd	a1,80(sp)
    80005d98:	ecb2                	sd	a2,88(sp)
    80005d9a:	f0b6                	sd	a3,96(sp)
    80005d9c:	f4ba                	sd	a4,104(sp)
    80005d9e:	f8be                	sd	a5,112(sp)
    80005da0:	fcc2                	sd	a6,120(sp)
    80005da2:	e146                	sd	a7,128(sp)
    80005da4:	e54a                	sd	s2,136(sp)
    80005da6:	e94e                	sd	s3,144(sp)
    80005da8:	ed52                	sd	s4,152(sp)
    80005daa:	f156                	sd	s5,160(sp)
    80005dac:	f55a                	sd	s6,168(sp)
    80005dae:	f95e                	sd	s7,176(sp)
    80005db0:	fd62                	sd	s8,184(sp)
    80005db2:	e1e6                	sd	s9,192(sp)
    80005db4:	e5ea                	sd	s10,200(sp)
    80005db6:	e9ee                	sd	s11,208(sp)
    80005db8:	edf2                	sd	t3,216(sp)
    80005dba:	f1f6                	sd	t4,224(sp)
    80005dbc:	f5fa                	sd	t5,232(sp)
    80005dbe:	f9fe                	sd	t6,240(sp)
    80005dc0:	c99fc0ef          	jal	ra,80002a58 <kerneltrap>
    80005dc4:	6082                	ld	ra,0(sp)
    80005dc6:	6122                	ld	sp,8(sp)
    80005dc8:	61c2                	ld	gp,16(sp)
    80005dca:	7282                	ld	t0,32(sp)
    80005dcc:	7322                	ld	t1,40(sp)
    80005dce:	73c2                	ld	t2,48(sp)
    80005dd0:	7462                	ld	s0,56(sp)
    80005dd2:	6486                	ld	s1,64(sp)
    80005dd4:	6526                	ld	a0,72(sp)
    80005dd6:	65c6                	ld	a1,80(sp)
    80005dd8:	6666                	ld	a2,88(sp)
    80005dda:	7686                	ld	a3,96(sp)
    80005ddc:	7726                	ld	a4,104(sp)
    80005dde:	77c6                	ld	a5,112(sp)
    80005de0:	7866                	ld	a6,120(sp)
    80005de2:	688a                	ld	a7,128(sp)
    80005de4:	692a                	ld	s2,136(sp)
    80005de6:	69ca                	ld	s3,144(sp)
    80005de8:	6a6a                	ld	s4,152(sp)
    80005dea:	7a8a                	ld	s5,160(sp)
    80005dec:	7b2a                	ld	s6,168(sp)
    80005dee:	7bca                	ld	s7,176(sp)
    80005df0:	7c6a                	ld	s8,184(sp)
    80005df2:	6c8e                	ld	s9,192(sp)
    80005df4:	6d2e                	ld	s10,200(sp)
    80005df6:	6dce                	ld	s11,208(sp)
    80005df8:	6e6e                	ld	t3,216(sp)
    80005dfa:	7e8e                	ld	t4,224(sp)
    80005dfc:	7f2e                	ld	t5,232(sp)
    80005dfe:	7fce                	ld	t6,240(sp)
    80005e00:	6111                	addi	sp,sp,256
    80005e02:	10200073          	sret
    80005e06:	00000013          	nop
    80005e0a:	00000013          	nop
    80005e0e:	0001                	nop

0000000080005e10 <timervec>:
    80005e10:	34051573          	csrrw	a0,mscratch,a0
    80005e14:	e10c                	sd	a1,0(a0)
    80005e16:	e510                	sd	a2,8(a0)
    80005e18:	e914                	sd	a3,16(a0)
    80005e1a:	710c                	ld	a1,32(a0)
    80005e1c:	7510                	ld	a2,40(a0)
    80005e1e:	6194                	ld	a3,0(a1)
    80005e20:	96b2                	add	a3,a3,a2
    80005e22:	e194                	sd	a3,0(a1)
    80005e24:	4589                	li	a1,2
    80005e26:	14459073          	csrw	sip,a1
    80005e2a:	6914                	ld	a3,16(a0)
    80005e2c:	6510                	ld	a2,8(a0)
    80005e2e:	610c                	ld	a1,0(a0)
    80005e30:	34051573          	csrrw	a0,mscratch,a0
    80005e34:	30200073          	mret
	...

0000000080005e3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e3a:	1141                	addi	sp,sp,-16
    80005e3c:	e422                	sd	s0,8(sp)
    80005e3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e40:	0c0007b7          	lui	a5,0xc000
    80005e44:	4705                	li	a4,1
    80005e46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e48:	c3d8                	sw	a4,4(a5)
}
    80005e4a:	6422                	ld	s0,8(sp)
    80005e4c:	0141                	addi	sp,sp,16
    80005e4e:	8082                	ret

0000000080005e50 <plicinithart>:

void
plicinithart(void)
{
    80005e50:	1141                	addi	sp,sp,-16
    80005e52:	e406                	sd	ra,8(sp)
    80005e54:	e022                	sd	s0,0(sp)
    80005e56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e58:	ffffc097          	auipc	ra,0xffffc
    80005e5c:	c8c080e7          	jalr	-884(ra) # 80001ae4 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e60:	0085171b          	slliw	a4,a0,0x8
    80005e64:	0c0027b7          	lui	a5,0xc002
    80005e68:	97ba                	add	a5,a5,a4
    80005e6a:	40200713          	li	a4,1026
    80005e6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e72:	00d5151b          	slliw	a0,a0,0xd
    80005e76:	0c2017b7          	lui	a5,0xc201
    80005e7a:	953e                	add	a0,a0,a5
    80005e7c:	00052023          	sw	zero,0(a0)
}
    80005e80:	60a2                	ld	ra,8(sp)
    80005e82:	6402                	ld	s0,0(sp)
    80005e84:	0141                	addi	sp,sp,16
    80005e86:	8082                	ret

0000000080005e88 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e88:	1141                	addi	sp,sp,-16
    80005e8a:	e406                	sd	ra,8(sp)
    80005e8c:	e022                	sd	s0,0(sp)
    80005e8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e90:	ffffc097          	auipc	ra,0xffffc
    80005e94:	c54080e7          	jalr	-940(ra) # 80001ae4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e98:	00d5179b          	slliw	a5,a0,0xd
    80005e9c:	0c201537          	lui	a0,0xc201
    80005ea0:	953e                	add	a0,a0,a5
  return irq;
}
    80005ea2:	4148                	lw	a0,4(a0)
    80005ea4:	60a2                	ld	ra,8(sp)
    80005ea6:	6402                	ld	s0,0(sp)
    80005ea8:	0141                	addi	sp,sp,16
    80005eaa:	8082                	ret

0000000080005eac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005eac:	1101                	addi	sp,sp,-32
    80005eae:	ec06                	sd	ra,24(sp)
    80005eb0:	e822                	sd	s0,16(sp)
    80005eb2:	e426                	sd	s1,8(sp)
    80005eb4:	1000                	addi	s0,sp,32
    80005eb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005eb8:	ffffc097          	auipc	ra,0xffffc
    80005ebc:	c2c080e7          	jalr	-980(ra) # 80001ae4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ec0:	00d5151b          	slliw	a0,a0,0xd
    80005ec4:	0c2017b7          	lui	a5,0xc201
    80005ec8:	97aa                	add	a5,a5,a0
    80005eca:	c3c4                	sw	s1,4(a5)
}
    80005ecc:	60e2                	ld	ra,24(sp)
    80005ece:	6442                	ld	s0,16(sp)
    80005ed0:	64a2                	ld	s1,8(sp)
    80005ed2:	6105                	addi	sp,sp,32
    80005ed4:	8082                	ret

0000000080005ed6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ed6:	1141                	addi	sp,sp,-16
    80005ed8:	e406                	sd	ra,8(sp)
    80005eda:	e022                	sd	s0,0(sp)
    80005edc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005ede:	479d                	li	a5,7
    80005ee0:	04a7cc63          	blt	a5,a0,80005f38 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005ee4:	0001d797          	auipc	a5,0x1d
    80005ee8:	11c78793          	addi	a5,a5,284 # 80023000 <disk>
    80005eec:	00a78733          	add	a4,a5,a0
    80005ef0:	6789                	lui	a5,0x2
    80005ef2:	97ba                	add	a5,a5,a4
    80005ef4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005ef8:	eba1                	bnez	a5,80005f48 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005efa:	00451713          	slli	a4,a0,0x4
    80005efe:	0001f797          	auipc	a5,0x1f
    80005f02:	1027b783          	ld	a5,258(a5) # 80025000 <disk+0x2000>
    80005f06:	97ba                	add	a5,a5,a4
    80005f08:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f0c:	0001d797          	auipc	a5,0x1d
    80005f10:	0f478793          	addi	a5,a5,244 # 80023000 <disk>
    80005f14:	97aa                	add	a5,a5,a0
    80005f16:	6509                	lui	a0,0x2
    80005f18:	953e                	add	a0,a0,a5
    80005f1a:	4785                	li	a5,1
    80005f1c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f20:	0001f517          	auipc	a0,0x1f
    80005f24:	0f850513          	addi	a0,a0,248 # 80025018 <disk+0x2018>
    80005f28:	ffffc097          	auipc	ra,0xffffc
    80005f2c:	582080e7          	jalr	1410(ra) # 800024aa <wakeup>
}
    80005f30:	60a2                	ld	ra,8(sp)
    80005f32:	6402                	ld	s0,0(sp)
    80005f34:	0141                	addi	sp,sp,16
    80005f36:	8082                	ret
    panic("virtio_disk_intr 1");
    80005f38:	00003517          	auipc	a0,0x3
    80005f3c:	92050513          	addi	a0,a0,-1760 # 80008858 <syscalls+0x338>
    80005f40:	ffffa097          	auipc	ra,0xffffa
    80005f44:	608080e7          	jalr	1544(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005f48:	00003517          	auipc	a0,0x3
    80005f4c:	92850513          	addi	a0,a0,-1752 # 80008870 <syscalls+0x350>
    80005f50:	ffffa097          	auipc	ra,0xffffa
    80005f54:	5f8080e7          	jalr	1528(ra) # 80000548 <panic>

0000000080005f58 <virtio_disk_init>:
{
    80005f58:	1101                	addi	sp,sp,-32
    80005f5a:	ec06                	sd	ra,24(sp)
    80005f5c:	e822                	sd	s0,16(sp)
    80005f5e:	e426                	sd	s1,8(sp)
    80005f60:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f62:	00003597          	auipc	a1,0x3
    80005f66:	92658593          	addi	a1,a1,-1754 # 80008888 <syscalls+0x368>
    80005f6a:	0001f517          	auipc	a0,0x1f
    80005f6e:	13e50513          	addi	a0,a0,318 # 800250a8 <disk+0x20a8>
    80005f72:	ffffb097          	auipc	ra,0xffffb
    80005f76:	c58080e7          	jalr	-936(ra) # 80000bca <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f7a:	100017b7          	lui	a5,0x10001
    80005f7e:	4398                	lw	a4,0(a5)
    80005f80:	2701                	sext.w	a4,a4
    80005f82:	747277b7          	lui	a5,0x74727
    80005f86:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f8a:	0ef71163          	bne	a4,a5,8000606c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005f8e:	100017b7          	lui	a5,0x10001
    80005f92:	43dc                	lw	a5,4(a5)
    80005f94:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f96:	4705                	li	a4,1
    80005f98:	0ce79a63          	bne	a5,a4,8000606c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f9c:	100017b7          	lui	a5,0x10001
    80005fa0:	479c                	lw	a5,8(a5)
    80005fa2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fa4:	4709                	li	a4,2
    80005fa6:	0ce79363          	bne	a5,a4,8000606c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005faa:	100017b7          	lui	a5,0x10001
    80005fae:	47d8                	lw	a4,12(a5)
    80005fb0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fb2:	554d47b7          	lui	a5,0x554d4
    80005fb6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005fba:	0af71963          	bne	a4,a5,8000606c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fbe:	100017b7          	lui	a5,0x10001
    80005fc2:	4705                	li	a4,1
    80005fc4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fc6:	470d                	li	a4,3
    80005fc8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005fca:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005fcc:	c7ffe737          	lui	a4,0xc7ffe
    80005fd0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005fd4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fd6:	2701                	sext.w	a4,a4
    80005fd8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fda:	472d                	li	a4,11
    80005fdc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fde:	473d                	li	a4,15
    80005fe0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005fe2:	6705                	lui	a4,0x1
    80005fe4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005fe6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005fea:	5bdc                	lw	a5,52(a5)
    80005fec:	2781                	sext.w	a5,a5
  if(max == 0)
    80005fee:	c7d9                	beqz	a5,8000607c <virtio_disk_init+0x124>
  if(max < NUM)
    80005ff0:	471d                	li	a4,7
    80005ff2:	08f77d63          	bgeu	a4,a5,8000608c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ff6:	100014b7          	lui	s1,0x10001
    80005ffa:	47a1                	li	a5,8
    80005ffc:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005ffe:	6609                	lui	a2,0x2
    80006000:	4581                	li	a1,0
    80006002:	0001d517          	auipc	a0,0x1d
    80006006:	ffe50513          	addi	a0,a0,-2 # 80023000 <disk>
    8000600a:	ffffb097          	auipc	ra,0xffffb
    8000600e:	d4c080e7          	jalr	-692(ra) # 80000d56 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006012:	0001d717          	auipc	a4,0x1d
    80006016:	fee70713          	addi	a4,a4,-18 # 80023000 <disk>
    8000601a:	00c75793          	srli	a5,a4,0xc
    8000601e:	2781                	sext.w	a5,a5
    80006020:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006022:	0001f797          	auipc	a5,0x1f
    80006026:	fde78793          	addi	a5,a5,-34 # 80025000 <disk+0x2000>
    8000602a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000602c:	0001d717          	auipc	a4,0x1d
    80006030:	05470713          	addi	a4,a4,84 # 80023080 <disk+0x80>
    80006034:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006036:	0001e717          	auipc	a4,0x1e
    8000603a:	fca70713          	addi	a4,a4,-54 # 80024000 <disk+0x1000>
    8000603e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006040:	4705                	li	a4,1
    80006042:	00e78c23          	sb	a4,24(a5)
    80006046:	00e78ca3          	sb	a4,25(a5)
    8000604a:	00e78d23          	sb	a4,26(a5)
    8000604e:	00e78da3          	sb	a4,27(a5)
    80006052:	00e78e23          	sb	a4,28(a5)
    80006056:	00e78ea3          	sb	a4,29(a5)
    8000605a:	00e78f23          	sb	a4,30(a5)
    8000605e:	00e78fa3          	sb	a4,31(a5)
}
    80006062:	60e2                	ld	ra,24(sp)
    80006064:	6442                	ld	s0,16(sp)
    80006066:	64a2                	ld	s1,8(sp)
    80006068:	6105                	addi	sp,sp,32
    8000606a:	8082                	ret
    panic("could not find virtio disk");
    8000606c:	00003517          	auipc	a0,0x3
    80006070:	82c50513          	addi	a0,a0,-2004 # 80008898 <syscalls+0x378>
    80006074:	ffffa097          	auipc	ra,0xffffa
    80006078:	4d4080e7          	jalr	1236(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    8000607c:	00003517          	auipc	a0,0x3
    80006080:	83c50513          	addi	a0,a0,-1988 # 800088b8 <syscalls+0x398>
    80006084:	ffffa097          	auipc	ra,0xffffa
    80006088:	4c4080e7          	jalr	1220(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    8000608c:	00003517          	auipc	a0,0x3
    80006090:	84c50513          	addi	a0,a0,-1972 # 800088d8 <syscalls+0x3b8>
    80006094:	ffffa097          	auipc	ra,0xffffa
    80006098:	4b4080e7          	jalr	1204(ra) # 80000548 <panic>

000000008000609c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000609c:	7119                	addi	sp,sp,-128
    8000609e:	fc86                	sd	ra,120(sp)
    800060a0:	f8a2                	sd	s0,112(sp)
    800060a2:	f4a6                	sd	s1,104(sp)
    800060a4:	f0ca                	sd	s2,96(sp)
    800060a6:	ecce                	sd	s3,88(sp)
    800060a8:	e8d2                	sd	s4,80(sp)
    800060aa:	e4d6                	sd	s5,72(sp)
    800060ac:	e0da                	sd	s6,64(sp)
    800060ae:	fc5e                	sd	s7,56(sp)
    800060b0:	f862                	sd	s8,48(sp)
    800060b2:	f466                	sd	s9,40(sp)
    800060b4:	f06a                	sd	s10,32(sp)
    800060b6:	0100                	addi	s0,sp,128
    800060b8:	892a                	mv	s2,a0
    800060ba:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060bc:	00c52c83          	lw	s9,12(a0)
    800060c0:	001c9c9b          	slliw	s9,s9,0x1
    800060c4:	1c82                	slli	s9,s9,0x20
    800060c6:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800060ca:	0001f517          	auipc	a0,0x1f
    800060ce:	fde50513          	addi	a0,a0,-34 # 800250a8 <disk+0x20a8>
    800060d2:	ffffb097          	auipc	ra,0xffffb
    800060d6:	b88080e7          	jalr	-1144(ra) # 80000c5a <acquire>
  for(int i = 0; i < 3; i++){
    800060da:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800060dc:	4c21                	li	s8,8
      disk.free[i] = 0;
    800060de:	0001db97          	auipc	s7,0x1d
    800060e2:	f22b8b93          	addi	s7,s7,-222 # 80023000 <disk>
    800060e6:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800060e8:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800060ea:	8a4e                	mv	s4,s3
    800060ec:	a051                	j	80006170 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800060ee:	00fb86b3          	add	a3,s7,a5
    800060f2:	96da                	add	a3,a3,s6
    800060f4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800060f8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800060fa:	0207c563          	bltz	a5,80006124 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800060fe:	2485                	addiw	s1,s1,1
    80006100:	0711                	addi	a4,a4,4
    80006102:	23548d63          	beq	s1,s5,8000633c <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80006106:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006108:	0001f697          	auipc	a3,0x1f
    8000610c:	f1068693          	addi	a3,a3,-240 # 80025018 <disk+0x2018>
    80006110:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006112:	0006c583          	lbu	a1,0(a3)
    80006116:	fde1                	bnez	a1,800060ee <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006118:	2785                	addiw	a5,a5,1
    8000611a:	0685                	addi	a3,a3,1
    8000611c:	ff879be3          	bne	a5,s8,80006112 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006120:	57fd                	li	a5,-1
    80006122:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006124:	02905a63          	blez	s1,80006158 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006128:	f9042503          	lw	a0,-112(s0)
    8000612c:	00000097          	auipc	ra,0x0
    80006130:	daa080e7          	jalr	-598(ra) # 80005ed6 <free_desc>
      for(int j = 0; j < i; j++)
    80006134:	4785                	li	a5,1
    80006136:	0297d163          	bge	a5,s1,80006158 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000613a:	f9442503          	lw	a0,-108(s0)
    8000613e:	00000097          	auipc	ra,0x0
    80006142:	d98080e7          	jalr	-616(ra) # 80005ed6 <free_desc>
      for(int j = 0; j < i; j++)
    80006146:	4789                	li	a5,2
    80006148:	0097d863          	bge	a5,s1,80006158 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000614c:	f9842503          	lw	a0,-104(s0)
    80006150:	00000097          	auipc	ra,0x0
    80006154:	d86080e7          	jalr	-634(ra) # 80005ed6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006158:	0001f597          	auipc	a1,0x1f
    8000615c:	f5058593          	addi	a1,a1,-176 # 800250a8 <disk+0x20a8>
    80006160:	0001f517          	auipc	a0,0x1f
    80006164:	eb850513          	addi	a0,a0,-328 # 80025018 <disk+0x2018>
    80006168:	ffffc097          	auipc	ra,0xffffc
    8000616c:	1bc080e7          	jalr	444(ra) # 80002324 <sleep>
  for(int i = 0; i < 3; i++){
    80006170:	f9040713          	addi	a4,s0,-112
    80006174:	84ce                	mv	s1,s3
    80006176:	bf41                	j	80006106 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006178:	4785                	li	a5,1
    8000617a:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000617e:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80006182:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006186:	f9042983          	lw	s3,-112(s0)
    8000618a:	00499493          	slli	s1,s3,0x4
    8000618e:	0001fa17          	auipc	s4,0x1f
    80006192:	e72a0a13          	addi	s4,s4,-398 # 80025000 <disk+0x2000>
    80006196:	000a3a83          	ld	s5,0(s4)
    8000619a:	9aa6                	add	s5,s5,s1
    8000619c:	f8040513          	addi	a0,s0,-128
    800061a0:	ffffb097          	auipc	ra,0xffffb
    800061a4:	f8a080e7          	jalr	-118(ra) # 8000112a <kvmpa>
    800061a8:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    800061ac:	000a3783          	ld	a5,0(s4)
    800061b0:	97a6                	add	a5,a5,s1
    800061b2:	4741                	li	a4,16
    800061b4:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061b6:	000a3783          	ld	a5,0(s4)
    800061ba:	97a6                	add	a5,a5,s1
    800061bc:	4705                	li	a4,1
    800061be:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800061c2:	f9442703          	lw	a4,-108(s0)
    800061c6:	000a3783          	ld	a5,0(s4)
    800061ca:	97a6                	add	a5,a5,s1
    800061cc:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800061d0:	0712                	slli	a4,a4,0x4
    800061d2:	000a3783          	ld	a5,0(s4)
    800061d6:	97ba                	add	a5,a5,a4
    800061d8:	05890693          	addi	a3,s2,88
    800061dc:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    800061de:	000a3783          	ld	a5,0(s4)
    800061e2:	97ba                	add	a5,a5,a4
    800061e4:	40000693          	li	a3,1024
    800061e8:	c794                	sw	a3,8(a5)
  if(write)
    800061ea:	100d0a63          	beqz	s10,800062fe <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800061ee:	0001f797          	auipc	a5,0x1f
    800061f2:	e127b783          	ld	a5,-494(a5) # 80025000 <disk+0x2000>
    800061f6:	97ba                	add	a5,a5,a4
    800061f8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061fc:	0001d517          	auipc	a0,0x1d
    80006200:	e0450513          	addi	a0,a0,-508 # 80023000 <disk>
    80006204:	0001f797          	auipc	a5,0x1f
    80006208:	dfc78793          	addi	a5,a5,-516 # 80025000 <disk+0x2000>
    8000620c:	6394                	ld	a3,0(a5)
    8000620e:	96ba                	add	a3,a3,a4
    80006210:	00c6d603          	lhu	a2,12(a3)
    80006214:	00166613          	ori	a2,a2,1
    80006218:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000621c:	f9842683          	lw	a3,-104(s0)
    80006220:	6390                	ld	a2,0(a5)
    80006222:	9732                	add	a4,a4,a2
    80006224:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006228:	20098613          	addi	a2,s3,512
    8000622c:	0612                	slli	a2,a2,0x4
    8000622e:	962a                	add	a2,a2,a0
    80006230:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006234:	00469713          	slli	a4,a3,0x4
    80006238:	6394                	ld	a3,0(a5)
    8000623a:	96ba                	add	a3,a3,a4
    8000623c:	6589                	lui	a1,0x2
    8000623e:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80006242:	94ae                	add	s1,s1,a1
    80006244:	94aa                	add	s1,s1,a0
    80006246:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006248:	6394                	ld	a3,0(a5)
    8000624a:	96ba                	add	a3,a3,a4
    8000624c:	4585                	li	a1,1
    8000624e:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006250:	6394                	ld	a3,0(a5)
    80006252:	96ba                	add	a3,a3,a4
    80006254:	4509                	li	a0,2
    80006256:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000625a:	6394                	ld	a3,0(a5)
    8000625c:	9736                	add	a4,a4,a3
    8000625e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006262:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006266:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000626a:	6794                	ld	a3,8(a5)
    8000626c:	0026d703          	lhu	a4,2(a3)
    80006270:	8b1d                	andi	a4,a4,7
    80006272:	2709                	addiw	a4,a4,2
    80006274:	0706                	slli	a4,a4,0x1
    80006276:	9736                	add	a4,a4,a3
    80006278:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    8000627c:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006280:	6798                	ld	a4,8(a5)
    80006282:	00275783          	lhu	a5,2(a4)
    80006286:	2785                	addiw	a5,a5,1
    80006288:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000628c:	100017b7          	lui	a5,0x10001
    80006290:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006294:	00492703          	lw	a4,4(s2)
    80006298:	4785                	li	a5,1
    8000629a:	02f71163          	bne	a4,a5,800062bc <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    8000629e:	0001f997          	auipc	s3,0x1f
    800062a2:	e0a98993          	addi	s3,s3,-502 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800062a6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800062a8:	85ce                	mv	a1,s3
    800062aa:	854a                	mv	a0,s2
    800062ac:	ffffc097          	auipc	ra,0xffffc
    800062b0:	078080e7          	jalr	120(ra) # 80002324 <sleep>
  while(b->disk == 1) {
    800062b4:	00492783          	lw	a5,4(s2)
    800062b8:	fe9788e3          	beq	a5,s1,800062a8 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    800062bc:	f9042483          	lw	s1,-112(s0)
    800062c0:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    800062c4:	00479713          	slli	a4,a5,0x4
    800062c8:	0001d797          	auipc	a5,0x1d
    800062cc:	d3878793          	addi	a5,a5,-712 # 80023000 <disk>
    800062d0:	97ba                	add	a5,a5,a4
    800062d2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800062d6:	0001f917          	auipc	s2,0x1f
    800062da:	d2a90913          	addi	s2,s2,-726 # 80025000 <disk+0x2000>
    free_desc(i);
    800062de:	8526                	mv	a0,s1
    800062e0:	00000097          	auipc	ra,0x0
    800062e4:	bf6080e7          	jalr	-1034(ra) # 80005ed6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800062e8:	0492                	slli	s1,s1,0x4
    800062ea:	00093783          	ld	a5,0(s2)
    800062ee:	94be                	add	s1,s1,a5
    800062f0:	00c4d783          	lhu	a5,12(s1)
    800062f4:	8b85                	andi	a5,a5,1
    800062f6:	cf89                	beqz	a5,80006310 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    800062f8:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800062fc:	b7cd                	j	800062de <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800062fe:	0001f797          	auipc	a5,0x1f
    80006302:	d027b783          	ld	a5,-766(a5) # 80025000 <disk+0x2000>
    80006306:	97ba                	add	a5,a5,a4
    80006308:	4689                	li	a3,2
    8000630a:	00d79623          	sh	a3,12(a5)
    8000630e:	b5fd                	j	800061fc <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006310:	0001f517          	auipc	a0,0x1f
    80006314:	d9850513          	addi	a0,a0,-616 # 800250a8 <disk+0x20a8>
    80006318:	ffffb097          	auipc	ra,0xffffb
    8000631c:	9f6080e7          	jalr	-1546(ra) # 80000d0e <release>
}
    80006320:	70e6                	ld	ra,120(sp)
    80006322:	7446                	ld	s0,112(sp)
    80006324:	74a6                	ld	s1,104(sp)
    80006326:	7906                	ld	s2,96(sp)
    80006328:	69e6                	ld	s3,88(sp)
    8000632a:	6a46                	ld	s4,80(sp)
    8000632c:	6aa6                	ld	s5,72(sp)
    8000632e:	6b06                	ld	s6,64(sp)
    80006330:	7be2                	ld	s7,56(sp)
    80006332:	7c42                	ld	s8,48(sp)
    80006334:	7ca2                	ld	s9,40(sp)
    80006336:	7d02                	ld	s10,32(sp)
    80006338:	6109                	addi	sp,sp,128
    8000633a:	8082                	ret
  if(write)
    8000633c:	e20d1ee3          	bnez	s10,80006178 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006340:	f8042023          	sw	zero,-128(s0)
    80006344:	bd2d                	j	8000617e <virtio_disk_rw+0xe2>

0000000080006346 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006346:	1101                	addi	sp,sp,-32
    80006348:	ec06                	sd	ra,24(sp)
    8000634a:	e822                	sd	s0,16(sp)
    8000634c:	e426                	sd	s1,8(sp)
    8000634e:	e04a                	sd	s2,0(sp)
    80006350:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006352:	0001f517          	auipc	a0,0x1f
    80006356:	d5650513          	addi	a0,a0,-682 # 800250a8 <disk+0x20a8>
    8000635a:	ffffb097          	auipc	ra,0xffffb
    8000635e:	900080e7          	jalr	-1792(ra) # 80000c5a <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006362:	0001f717          	auipc	a4,0x1f
    80006366:	c9e70713          	addi	a4,a4,-866 # 80025000 <disk+0x2000>
    8000636a:	02075783          	lhu	a5,32(a4)
    8000636e:	6b18                	ld	a4,16(a4)
    80006370:	00275683          	lhu	a3,2(a4)
    80006374:	8ebd                	xor	a3,a3,a5
    80006376:	8a9d                	andi	a3,a3,7
    80006378:	cab9                	beqz	a3,800063ce <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000637a:	0001d917          	auipc	s2,0x1d
    8000637e:	c8690913          	addi	s2,s2,-890 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006382:	0001f497          	auipc	s1,0x1f
    80006386:	c7e48493          	addi	s1,s1,-898 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000638a:	078e                	slli	a5,a5,0x3
    8000638c:	97ba                	add	a5,a5,a4
    8000638e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006390:	20078713          	addi	a4,a5,512
    80006394:	0712                	slli	a4,a4,0x4
    80006396:	974a                	add	a4,a4,s2
    80006398:	03074703          	lbu	a4,48(a4)
    8000639c:	ef21                	bnez	a4,800063f4 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000639e:	20078793          	addi	a5,a5,512
    800063a2:	0792                	slli	a5,a5,0x4
    800063a4:	97ca                	add	a5,a5,s2
    800063a6:	7798                	ld	a4,40(a5)
    800063a8:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800063ac:	7788                	ld	a0,40(a5)
    800063ae:	ffffc097          	auipc	ra,0xffffc
    800063b2:	0fc080e7          	jalr	252(ra) # 800024aa <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800063b6:	0204d783          	lhu	a5,32(s1)
    800063ba:	2785                	addiw	a5,a5,1
    800063bc:	8b9d                	andi	a5,a5,7
    800063be:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063c2:	6898                	ld	a4,16(s1)
    800063c4:	00275683          	lhu	a3,2(a4)
    800063c8:	8a9d                	andi	a3,a3,7
    800063ca:	fcf690e3          	bne	a3,a5,8000638a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063ce:	10001737          	lui	a4,0x10001
    800063d2:	533c                	lw	a5,96(a4)
    800063d4:	8b8d                	andi	a5,a5,3
    800063d6:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800063d8:	0001f517          	auipc	a0,0x1f
    800063dc:	cd050513          	addi	a0,a0,-816 # 800250a8 <disk+0x20a8>
    800063e0:	ffffb097          	auipc	ra,0xffffb
    800063e4:	92e080e7          	jalr	-1746(ra) # 80000d0e <release>
}
    800063e8:	60e2                	ld	ra,24(sp)
    800063ea:	6442                	ld	s0,16(sp)
    800063ec:	64a2                	ld	s1,8(sp)
    800063ee:	6902                	ld	s2,0(sp)
    800063f0:	6105                	addi	sp,sp,32
    800063f2:	8082                	ret
      panic("virtio_disk_intr status");
    800063f4:	00002517          	auipc	a0,0x2
    800063f8:	50450513          	addi	a0,a0,1284 # 800088f8 <syscalls+0x3d8>
    800063fc:	ffffa097          	auipc	ra,0xffffa
    80006400:	14c080e7          	jalr	332(ra) # 80000548 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
