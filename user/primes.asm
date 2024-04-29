
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <create_right_process>:
int lhs[2];
int rhs[2];
int has_right = 0;

void create_right_process(int prime)
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
  12:	89aa                	mv	s3,a0
    int ret = fork();
  14:	00000097          	auipc	ra,0x0
  18:	460080e7          	jalr	1120(ra) # 474 <fork>
    if (ret < 0)
  1c:	00054d63          	bltz	a0,36 <create_right_process+0x36>
    {
        printf("can`t fork now\n");
        exit(0);
    }
    else if (ret > 0)
  20:	02a05863          	blez	a0,50 <create_right_process+0x50>
    {
        close(rhs[1]);
        wait(0);
    }
    exit(0);
}
  24:	60a6                	ld	ra,72(sp)
  26:	6406                	ld	s0,64(sp)
  28:	74e2                	ld	s1,56(sp)
  2a:	7942                	ld	s2,48(sp)
  2c:	79a2                	ld	s3,40(sp)
  2e:	7a02                	ld	s4,32(sp)
  30:	6ae2                	ld	s5,24(sp)
  32:	6161                	addi	sp,sp,80
  34:	8082                	ret
        printf("can`t fork now\n");
  36:	00001517          	auipc	a0,0x1
  3a:	96250513          	addi	a0,a0,-1694 # 998 <malloc+0xe6>
  3e:	00000097          	auipc	ra,0x0
  42:	7b6080e7          	jalr	1974(ra) # 7f4 <printf>
        exit(0);
  46:	4501                	li	a0,0
  48:	00000097          	auipc	ra,0x0
  4c:	434080e7          	jalr	1076(ra) # 47c <exit>
    lhs[0] = rhs[0];
  50:	00001797          	auipc	a5,0x1
  54:	9c878793          	addi	a5,a5,-1592 # a18 <lhs>
  58:	00001717          	auipc	a4,0x1
  5c:	9b870713          	addi	a4,a4,-1608 # a10 <rhs>
  60:	4314                	lw	a3,0(a4)
  62:	c394                	sw	a3,0(a5)
    lhs[1] = rhs[1];
  64:	4348                	lw	a0,4(a4)
  66:	c3c8                	sw	a0,4(a5)
    close(lhs[1]);
  68:	00000097          	auipc	ra,0x0
  6c:	43c080e7          	jalr	1084(ra) # 4a4 <close>
    printf("prime %d\n", prime);
  70:	85ce                	mv	a1,s3
  72:	00001517          	auipc	a0,0x1
  76:	93650513          	addi	a0,a0,-1738 # 9a8 <malloc+0xf6>
  7a:	00000097          	auipc	ra,0x0
  7e:	77a080e7          	jalr	1914(ra) # 7f4 <printf>
    int has_right = 0;
  82:	4481                	li	s1,0
    while (read(lhs[0], &num, sizeof(int)))
  84:	00001a17          	auipc	s4,0x1
  88:	994a0a13          	addi	s4,s4,-1644 # a18 <lhs>
            if (pipe(rhs) < 0)
  8c:	00001917          	auipc	s2,0x1
  90:	98490913          	addi	s2,s2,-1660 # a10 <rhs>
        write(rhs[1], &num, sizeof(int));
  94:	4a85                	li	s5,1
    while (read(lhs[0], &num, sizeof(int)))
  96:	a081                	j	d6 <create_right_process+0xd6>
                printf("can`t create pipe now\n");
  98:	00001517          	auipc	a0,0x1
  9c:	92050513          	addi	a0,a0,-1760 # 9b8 <malloc+0x106>
  a0:	00000097          	auipc	ra,0x0
  a4:	754080e7          	jalr	1876(ra) # 7f4 <printf>
                close(lhs[0]);
  a8:	00001517          	auipc	a0,0x1
  ac:	97052503          	lw	a0,-1680(a0) # a18 <lhs>
  b0:	00000097          	auipc	ra,0x0
  b4:	3f4080e7          	jalr	1012(ra) # 4a4 <close>
                exit(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	3c2080e7          	jalr	962(ra) # 47c <exit>
        write(rhs[1], &num, sizeof(int));
  c2:	4611                	li	a2,4
  c4:	fbc40593          	addi	a1,s0,-68
  c8:	00492503          	lw	a0,4(s2)
  cc:	00000097          	auipc	ra,0x0
  d0:	3d0080e7          	jalr	976(ra) # 49c <write>
  d4:	84d6                	mv	s1,s5
    while (read(lhs[0], &num, sizeof(int)))
  d6:	4611                	li	a2,4
  d8:	fbc40593          	addi	a1,s0,-68
  dc:	000a2503          	lw	a0,0(s4)
  e0:	00000097          	auipc	ra,0x0
  e4:	3b4080e7          	jalr	948(ra) # 494 <read>
  e8:	c91d                	beqz	a0,11e <create_right_process+0x11e>
        if (num % prime == 0)
  ea:	fbc42783          	lw	a5,-68(s0)
  ee:	0337e7bb          	remw	a5,a5,s3
  f2:	d3f5                	beqz	a5,d6 <create_right_process+0xd6>
        if (!has_right)
  f4:	f4f9                	bnez	s1,c2 <create_right_process+0xc2>
            if (pipe(rhs) < 0)
  f6:	854a                	mv	a0,s2
  f8:	00000097          	auipc	ra,0x0
  fc:	394080e7          	jalr	916(ra) # 48c <pipe>
 100:	f8054ce3          	bltz	a0,98 <create_right_process+0x98>
            create_right_process(num);
 104:	fbc42503          	lw	a0,-68(s0)
 108:	00000097          	auipc	ra,0x0
 10c:	ef8080e7          	jalr	-264(ra) # 0 <create_right_process>
            close(rhs[0]);
 110:	00092503          	lw	a0,0(s2)
 114:	00000097          	auipc	ra,0x0
 118:	390080e7          	jalr	912(ra) # 4a4 <close>
 11c:	b75d                	j	c2 <create_right_process+0xc2>
    close(lhs[0]);
 11e:	00001517          	auipc	a0,0x1
 122:	8fa52503          	lw	a0,-1798(a0) # a18 <lhs>
 126:	00000097          	auipc	ra,0x0
 12a:	37e080e7          	jalr	894(ra) # 4a4 <close>
    if (has_right)
 12e:	e491                	bnez	s1,13a <create_right_process+0x13a>
    exit(0);
 130:	4501                	li	a0,0
 132:	00000097          	auipc	ra,0x0
 136:	34a080e7          	jalr	842(ra) # 47c <exit>
        close(rhs[1]);
 13a:	00001517          	auipc	a0,0x1
 13e:	8da52503          	lw	a0,-1830(a0) # a14 <rhs+0x4>
 142:	00000097          	auipc	ra,0x0
 146:	362080e7          	jalr	866(ra) # 4a4 <close>
        wait(0);
 14a:	4501                	li	a0,0
 14c:	00000097          	auipc	ra,0x0
 150:	338080e7          	jalr	824(ra) # 484 <wait>
 154:	bff1                	j	130 <create_right_process+0x130>

0000000000000156 <main>:
int main()
{
 156:	7179                	addi	sp,sp,-48
 158:	f406                	sd	ra,40(sp)
 15a:	f022                	sd	s0,32(sp)
 15c:	ec26                	sd	s1,24(sp)
 15e:	e84a                	sd	s2,16(sp)
 160:	1800                	addi	s0,sp,48
    if (pipe(rhs) == -1)
 162:	00001517          	auipc	a0,0x1
 166:	8ae50513          	addi	a0,a0,-1874 # a10 <rhs>
 16a:	00000097          	auipc	ra,0x0
 16e:	322080e7          	jalr	802(ra) # 48c <pipe>
 172:	57fd                	li	a5,-1
 174:	06f50c63          	beq	a0,a5,1ec <main+0x96>
    {
        printf("cant`t create pipe now\n");
        exit(0);
    }
    create_right_process(2);
 178:	4509                	li	a0,2
 17a:	00000097          	auipc	ra,0x0
 17e:	e86080e7          	jalr	-378(ra) # 0 <create_right_process>
    close(rhs[0]);
 182:	00001517          	auipc	a0,0x1
 186:	88e52503          	lw	a0,-1906(a0) # a10 <rhs>
 18a:	00000097          	auipc	ra,0x0
 18e:	31a080e7          	jalr	794(ra) # 4a4 <close>
    for (int i = 3; i < 36; i++)
 192:	478d                	li	a5,3
 194:	fcf42e23          	sw	a5,-36(s0)
    {
        write(rhs[1], &i, sizeof(int));
 198:	00001917          	auipc	s2,0x1
 19c:	87890913          	addi	s2,s2,-1928 # a10 <rhs>
    for (int i = 3; i < 36; i++)
 1a0:	02300493          	li	s1,35
        write(rhs[1], &i, sizeof(int));
 1a4:	4611                	li	a2,4
 1a6:	fdc40593          	addi	a1,s0,-36
 1aa:	00492503          	lw	a0,4(s2)
 1ae:	00000097          	auipc	ra,0x0
 1b2:	2ee080e7          	jalr	750(ra) # 49c <write>
    for (int i = 3; i < 36; i++)
 1b6:	fdc42783          	lw	a5,-36(s0)
 1ba:	2785                	addiw	a5,a5,1
 1bc:	0007871b          	sext.w	a4,a5
 1c0:	fcf42e23          	sw	a5,-36(s0)
 1c4:	fee4d0e3          	bge	s1,a4,1a4 <main+0x4e>
    }
    close(rhs[1]);
 1c8:	00001517          	auipc	a0,0x1
 1cc:	84c52503          	lw	a0,-1972(a0) # a14 <rhs+0x4>
 1d0:	00000097          	auipc	ra,0x0
 1d4:	2d4080e7          	jalr	724(ra) # 4a4 <close>
    wait(0);
 1d8:	4501                	li	a0,0
 1da:	00000097          	auipc	ra,0x0
 1de:	2aa080e7          	jalr	682(ra) # 484 <wait>
    exit(0);
 1e2:	4501                	li	a0,0
 1e4:	00000097          	auipc	ra,0x0
 1e8:	298080e7          	jalr	664(ra) # 47c <exit>
        printf("cant`t create pipe now\n");
 1ec:	00000517          	auipc	a0,0x0
 1f0:	7e450513          	addi	a0,a0,2020 # 9d0 <malloc+0x11e>
 1f4:	00000097          	auipc	ra,0x0
 1f8:	600080e7          	jalr	1536(ra) # 7f4 <printf>
        exit(0);
 1fc:	4501                	li	a0,0
 1fe:	00000097          	auipc	ra,0x0
 202:	27e080e7          	jalr	638(ra) # 47c <exit>

0000000000000206 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 20c:	87aa                	mv	a5,a0
 20e:	0585                	addi	a1,a1,1
 210:	0785                	addi	a5,a5,1
 212:	fff5c703          	lbu	a4,-1(a1)
 216:	fee78fa3          	sb	a4,-1(a5)
 21a:	fb75                	bnez	a4,20e <strcpy+0x8>
    ;
  return os;
}
 21c:	6422                	ld	s0,8(sp)
 21e:	0141                	addi	sp,sp,16
 220:	8082                	ret

0000000000000222 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 228:	00054783          	lbu	a5,0(a0)
 22c:	cb91                	beqz	a5,240 <strcmp+0x1e>
 22e:	0005c703          	lbu	a4,0(a1)
 232:	00f71763          	bne	a4,a5,240 <strcmp+0x1e>
    p++, q++;
 236:	0505                	addi	a0,a0,1
 238:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 23a:	00054783          	lbu	a5,0(a0)
 23e:	fbe5                	bnez	a5,22e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 240:	0005c503          	lbu	a0,0(a1)
}
 244:	40a7853b          	subw	a0,a5,a0
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret

000000000000024e <strlen>:

uint
strlen(const char *s)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 254:	00054783          	lbu	a5,0(a0)
 258:	cf91                	beqz	a5,274 <strlen+0x26>
 25a:	0505                	addi	a0,a0,1
 25c:	87aa                	mv	a5,a0
 25e:	4685                	li	a3,1
 260:	9e89                	subw	a3,a3,a0
 262:	00f6853b          	addw	a0,a3,a5
 266:	0785                	addi	a5,a5,1
 268:	fff7c703          	lbu	a4,-1(a5)
 26c:	fb7d                	bnez	a4,262 <strlen+0x14>
    ;
  return n;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret
  for(n = 0; s[n]; n++)
 274:	4501                	li	a0,0
 276:	bfe5                	j	26e <strlen+0x20>

0000000000000278 <memset>:

void*
memset(void *dst, int c, uint n)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 27e:	ce09                	beqz	a2,298 <memset+0x20>
 280:	87aa                	mv	a5,a0
 282:	fff6071b          	addiw	a4,a2,-1
 286:	1702                	slli	a4,a4,0x20
 288:	9301                	srli	a4,a4,0x20
 28a:	0705                	addi	a4,a4,1
 28c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 28e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 292:	0785                	addi	a5,a5,1
 294:	fee79de3          	bne	a5,a4,28e <memset+0x16>
  }
  return dst;
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret

000000000000029e <strchr>:

char*
strchr(const char *s, char c)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	cb99                	beqz	a5,2be <strchr+0x20>
    if(*s == c)
 2aa:	00f58763          	beq	a1,a5,2b8 <strchr+0x1a>
  for(; *s; s++)
 2ae:	0505                	addi	a0,a0,1
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	fbfd                	bnez	a5,2aa <strchr+0xc>
      return (char*)s;
  return 0;
 2b6:	4501                	li	a0,0
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
  return 0;
 2be:	4501                	li	a0,0
 2c0:	bfe5                	j	2b8 <strchr+0x1a>

00000000000002c2 <gets>:

char*
gets(char *buf, int max)
{
 2c2:	711d                	addi	sp,sp,-96
 2c4:	ec86                	sd	ra,88(sp)
 2c6:	e8a2                	sd	s0,80(sp)
 2c8:	e4a6                	sd	s1,72(sp)
 2ca:	e0ca                	sd	s2,64(sp)
 2cc:	fc4e                	sd	s3,56(sp)
 2ce:	f852                	sd	s4,48(sp)
 2d0:	f456                	sd	s5,40(sp)
 2d2:	f05a                	sd	s6,32(sp)
 2d4:	ec5e                	sd	s7,24(sp)
 2d6:	1080                	addi	s0,sp,96
 2d8:	8baa                	mv	s7,a0
 2da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2dc:	892a                	mv	s2,a0
 2de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2e0:	4aa9                	li	s5,10
 2e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2e4:	89a6                	mv	s3,s1
 2e6:	2485                	addiw	s1,s1,1
 2e8:	0344d863          	bge	s1,s4,318 <gets+0x56>
    cc = read(0, &c, 1);
 2ec:	4605                	li	a2,1
 2ee:	faf40593          	addi	a1,s0,-81
 2f2:	4501                	li	a0,0
 2f4:	00000097          	auipc	ra,0x0
 2f8:	1a0080e7          	jalr	416(ra) # 494 <read>
    if(cc < 1)
 2fc:	00a05e63          	blez	a0,318 <gets+0x56>
    buf[i++] = c;
 300:	faf44783          	lbu	a5,-81(s0)
 304:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 308:	01578763          	beq	a5,s5,316 <gets+0x54>
 30c:	0905                	addi	s2,s2,1
 30e:	fd679be3          	bne	a5,s6,2e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 312:	89a6                	mv	s3,s1
 314:	a011                	j	318 <gets+0x56>
 316:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 318:	99de                	add	s3,s3,s7
 31a:	00098023          	sb	zero,0(s3)
  return buf;
}
 31e:	855e                	mv	a0,s7
 320:	60e6                	ld	ra,88(sp)
 322:	6446                	ld	s0,80(sp)
 324:	64a6                	ld	s1,72(sp)
 326:	6906                	ld	s2,64(sp)
 328:	79e2                	ld	s3,56(sp)
 32a:	7a42                	ld	s4,48(sp)
 32c:	7aa2                	ld	s5,40(sp)
 32e:	7b02                	ld	s6,32(sp)
 330:	6be2                	ld	s7,24(sp)
 332:	6125                	addi	sp,sp,96
 334:	8082                	ret

0000000000000336 <stat>:

int
stat(const char *n, struct stat *st)
{
 336:	1101                	addi	sp,sp,-32
 338:	ec06                	sd	ra,24(sp)
 33a:	e822                	sd	s0,16(sp)
 33c:	e426                	sd	s1,8(sp)
 33e:	e04a                	sd	s2,0(sp)
 340:	1000                	addi	s0,sp,32
 342:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 344:	4581                	li	a1,0
 346:	00000097          	auipc	ra,0x0
 34a:	176080e7          	jalr	374(ra) # 4bc <open>
  if(fd < 0)
 34e:	02054563          	bltz	a0,378 <stat+0x42>
 352:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 354:	85ca                	mv	a1,s2
 356:	00000097          	auipc	ra,0x0
 35a:	17e080e7          	jalr	382(ra) # 4d4 <fstat>
 35e:	892a                	mv	s2,a0
  close(fd);
 360:	8526                	mv	a0,s1
 362:	00000097          	auipc	ra,0x0
 366:	142080e7          	jalr	322(ra) # 4a4 <close>
  return r;
}
 36a:	854a                	mv	a0,s2
 36c:	60e2                	ld	ra,24(sp)
 36e:	6442                	ld	s0,16(sp)
 370:	64a2                	ld	s1,8(sp)
 372:	6902                	ld	s2,0(sp)
 374:	6105                	addi	sp,sp,32
 376:	8082                	ret
    return -1;
 378:	597d                	li	s2,-1
 37a:	bfc5                	j	36a <stat+0x34>

000000000000037c <atoi>:

int
atoi(const char *s)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e422                	sd	s0,8(sp)
 380:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 382:	00054603          	lbu	a2,0(a0)
 386:	fd06079b          	addiw	a5,a2,-48
 38a:	0ff7f793          	andi	a5,a5,255
 38e:	4725                	li	a4,9
 390:	02f76963          	bltu	a4,a5,3c2 <atoi+0x46>
 394:	86aa                	mv	a3,a0
  n = 0;
 396:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 398:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 39a:	0685                	addi	a3,a3,1
 39c:	0025179b          	slliw	a5,a0,0x2
 3a0:	9fa9                	addw	a5,a5,a0
 3a2:	0017979b          	slliw	a5,a5,0x1
 3a6:	9fb1                	addw	a5,a5,a2
 3a8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3ac:	0006c603          	lbu	a2,0(a3)
 3b0:	fd06071b          	addiw	a4,a2,-48
 3b4:	0ff77713          	andi	a4,a4,255
 3b8:	fee5f1e3          	bgeu	a1,a4,39a <atoi+0x1e>
  return n;
}
 3bc:	6422                	ld	s0,8(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret
  n = 0;
 3c2:	4501                	li	a0,0
 3c4:	bfe5                	j	3bc <atoi+0x40>

00000000000003c6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3c6:	1141                	addi	sp,sp,-16
 3c8:	e422                	sd	s0,8(sp)
 3ca:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3cc:	02b57663          	bgeu	a0,a1,3f8 <memmove+0x32>
    while(n-- > 0)
 3d0:	02c05163          	blez	a2,3f2 <memmove+0x2c>
 3d4:	fff6079b          	addiw	a5,a2,-1
 3d8:	1782                	slli	a5,a5,0x20
 3da:	9381                	srli	a5,a5,0x20
 3dc:	0785                	addi	a5,a5,1
 3de:	97aa                	add	a5,a5,a0
  dst = vdst;
 3e0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3e2:	0585                	addi	a1,a1,1
 3e4:	0705                	addi	a4,a4,1
 3e6:	fff5c683          	lbu	a3,-1(a1)
 3ea:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3ee:	fee79ae3          	bne	a5,a4,3e2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3f2:	6422                	ld	s0,8(sp)
 3f4:	0141                	addi	sp,sp,16
 3f6:	8082                	ret
    dst += n;
 3f8:	00c50733          	add	a4,a0,a2
    src += n;
 3fc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3fe:	fec05ae3          	blez	a2,3f2 <memmove+0x2c>
 402:	fff6079b          	addiw	a5,a2,-1
 406:	1782                	slli	a5,a5,0x20
 408:	9381                	srli	a5,a5,0x20
 40a:	fff7c793          	not	a5,a5
 40e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 410:	15fd                	addi	a1,a1,-1
 412:	177d                	addi	a4,a4,-1
 414:	0005c683          	lbu	a3,0(a1)
 418:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 41c:	fee79ae3          	bne	a5,a4,410 <memmove+0x4a>
 420:	bfc9                	j	3f2 <memmove+0x2c>

0000000000000422 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 422:	1141                	addi	sp,sp,-16
 424:	e422                	sd	s0,8(sp)
 426:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 428:	ca05                	beqz	a2,458 <memcmp+0x36>
 42a:	fff6069b          	addiw	a3,a2,-1
 42e:	1682                	slli	a3,a3,0x20
 430:	9281                	srli	a3,a3,0x20
 432:	0685                	addi	a3,a3,1
 434:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 436:	00054783          	lbu	a5,0(a0)
 43a:	0005c703          	lbu	a4,0(a1)
 43e:	00e79863          	bne	a5,a4,44e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 442:	0505                	addi	a0,a0,1
    p2++;
 444:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 446:	fed518e3          	bne	a0,a3,436 <memcmp+0x14>
  }
  return 0;
 44a:	4501                	li	a0,0
 44c:	a019                	j	452 <memcmp+0x30>
      return *p1 - *p2;
 44e:	40e7853b          	subw	a0,a5,a4
}
 452:	6422                	ld	s0,8(sp)
 454:	0141                	addi	sp,sp,16
 456:	8082                	ret
  return 0;
 458:	4501                	li	a0,0
 45a:	bfe5                	j	452 <memcmp+0x30>

000000000000045c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 45c:	1141                	addi	sp,sp,-16
 45e:	e406                	sd	ra,8(sp)
 460:	e022                	sd	s0,0(sp)
 462:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 464:	00000097          	auipc	ra,0x0
 468:	f62080e7          	jalr	-158(ra) # 3c6 <memmove>
}
 46c:	60a2                	ld	ra,8(sp)
 46e:	6402                	ld	s0,0(sp)
 470:	0141                	addi	sp,sp,16
 472:	8082                	ret

0000000000000474 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 474:	4885                	li	a7,1
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <exit>:
.global exit
exit:
 li a7, SYS_exit
 47c:	4889                	li	a7,2
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <wait>:
.global wait
wait:
 li a7, SYS_wait
 484:	488d                	li	a7,3
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 48c:	4891                	li	a7,4
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <read>:
.global read
read:
 li a7, SYS_read
 494:	4895                	li	a7,5
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <write>:
.global write
write:
 li a7, SYS_write
 49c:	48c1                	li	a7,16
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <close>:
.global close
close:
 li a7, SYS_close
 4a4:	48d5                	li	a7,21
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <kill>:
.global kill
kill:
 li a7, SYS_kill
 4ac:	4899                	li	a7,6
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4b4:	489d                	li	a7,7
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <open>:
.global open
open:
 li a7, SYS_open
 4bc:	48bd                	li	a7,15
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4c4:	48c5                	li	a7,17
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4cc:	48c9                	li	a7,18
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4d4:	48a1                	li	a7,8
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <link>:
.global link
link:
 li a7, SYS_link
 4dc:	48cd                	li	a7,19
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4e4:	48d1                	li	a7,20
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ec:	48a5                	li	a7,9
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4f4:	48a9                	li	a7,10
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4fc:	48ad                	li	a7,11
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 504:	48b1                	li	a7,12
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 50c:	48b5                	li	a7,13
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 514:	48b9                	li	a7,14
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <putc>:
 * @Param char:
 * @Return:
*/
static void
putc(int fd, char c)
{
 51c:	1101                	addi	sp,sp,-32
 51e:	ec06                	sd	ra,24(sp)
 520:	e822                	sd	s0,16(sp)
 522:	1000                	addi	s0,sp,32
 524:	feb407a3          	sb	a1,-17(s0)
    write(fd, &c, 1);
 528:	4605                	li	a2,1
 52a:	fef40593          	addi	a1,s0,-17
 52e:	00000097          	auipc	ra,0x0
 532:	f6e080e7          	jalr	-146(ra) # 49c <write>
}
 536:	60e2                	ld	ra,24(sp)
 538:	6442                	ld	s0,16(sp)
 53a:	6105                	addi	sp,sp,32
 53c:	8082                	ret

000000000000053e <printint>:
 * @Param sgn: 1 为 signed，0 为 unsigned
 * @Return:
*/
static void
printint(int fd, int xx, int base, int sgn)
{
 53e:	7139                	addi	sp,sp,-64
 540:	fc06                	sd	ra,56(sp)
 542:	f822                	sd	s0,48(sp)
 544:	f426                	sd	s1,40(sp)
 546:	f04a                	sd	s2,32(sp)
 548:	ec4e                	sd	s3,24(sp)
 54a:	0080                	addi	s0,sp,64
 54c:	84aa                	mv	s1,a0
    char buf[16];
    int i, neg;
    uint x;

    neg = 0;
    if (sgn && xx < 0) {
 54e:	c299                	beqz	a3,554 <printint+0x16>
 550:	0805c863          	bltz	a1,5e0 <printint+0xa2>
        neg = 1;
        x = -xx;
    } else {
        x = xx;
 554:	2581                	sext.w	a1,a1
    neg = 0;
 556:	4881                	li	a7,0
 558:	fc040693          	addi	a3,s0,-64
    }

    i = 0;
 55c:	4701                	li	a4,0
    do {
        buf[i++] = digits[x % base];
 55e:	2601                	sext.w	a2,a2
 560:	00000517          	auipc	a0,0x0
 564:	49050513          	addi	a0,a0,1168 # 9f0 <digits>
 568:	883a                	mv	a6,a4
 56a:	2705                	addiw	a4,a4,1
 56c:	02c5f7bb          	remuw	a5,a1,a2
 570:	1782                	slli	a5,a5,0x20
 572:	9381                	srli	a5,a5,0x20
 574:	97aa                	add	a5,a5,a0
 576:	0007c783          	lbu	a5,0(a5)
 57a:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
 57e:	0005879b          	sext.w	a5,a1
 582:	02c5d5bb          	divuw	a1,a1,a2
 586:	0685                	addi	a3,a3,1
 588:	fec7f0e3          	bgeu	a5,a2,568 <printint+0x2a>
    if (neg)
 58c:	00088b63          	beqz	a7,5a2 <printint+0x64>
        buf[i++] = '-';
 590:	fd040793          	addi	a5,s0,-48
 594:	973e                	add	a4,a4,a5
 596:	02d00793          	li	a5,45
 59a:	fef70823          	sb	a5,-16(a4)
 59e:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
 5a2:	02e05863          	blez	a4,5d2 <printint+0x94>
 5a6:	fc040793          	addi	a5,s0,-64
 5aa:	00e78933          	add	s2,a5,a4
 5ae:	fff78993          	addi	s3,a5,-1
 5b2:	99ba                	add	s3,s3,a4
 5b4:	377d                	addiw	a4,a4,-1
 5b6:	1702                	slli	a4,a4,0x20
 5b8:	9301                	srli	a4,a4,0x20
 5ba:	40e989b3          	sub	s3,s3,a4
        putc(fd, buf[i]);
 5be:	fff94583          	lbu	a1,-1(s2)
 5c2:	8526                	mv	a0,s1
 5c4:	00000097          	auipc	ra,0x0
 5c8:	f58080e7          	jalr	-168(ra) # 51c <putc>
    while (--i >= 0)
 5cc:	197d                	addi	s2,s2,-1
 5ce:	ff3918e3          	bne	s2,s3,5be <printint+0x80>
}
 5d2:	70e2                	ld	ra,56(sp)
 5d4:	7442                	ld	s0,48(sp)
 5d6:	74a2                	ld	s1,40(sp)
 5d8:	7902                	ld	s2,32(sp)
 5da:	69e2                	ld	s3,24(sp)
 5dc:	6121                	addi	sp,sp,64
 5de:	8082                	ret
        x = -xx;
 5e0:	40b005bb          	negw	a1,a1
        neg = 1;
 5e4:	4885                	li	a7,1
        x = -xx;
 5e6:	bf8d                	j	558 <printint+0x1a>

00000000000005e8 <vprintf>:
        putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void vprintf(int fd, const char* fmt, va_list ap)
{
 5e8:	7119                	addi	sp,sp,-128
 5ea:	fc86                	sd	ra,120(sp)
 5ec:	f8a2                	sd	s0,112(sp)
 5ee:	f4a6                	sd	s1,104(sp)
 5f0:	f0ca                	sd	s2,96(sp)
 5f2:	ecce                	sd	s3,88(sp)
 5f4:	e8d2                	sd	s4,80(sp)
 5f6:	e4d6                	sd	s5,72(sp)
 5f8:	e0da                	sd	s6,64(sp)
 5fa:	fc5e                	sd	s7,56(sp)
 5fc:	f862                	sd	s8,48(sp)
 5fe:	f466                	sd	s9,40(sp)
 600:	f06a                	sd	s10,32(sp)
 602:	ec6e                	sd	s11,24(sp)
 604:	0100                	addi	s0,sp,128
    char* s;
    int c, i, state;

    state = 0;
    for (i = 0; fmt[i]; i++) {
 606:	0005c903          	lbu	s2,0(a1)
 60a:	18090f63          	beqz	s2,7a8 <vprintf+0x1c0>
 60e:	8aaa                	mv	s5,a0
 610:	8b32                	mv	s6,a2
 612:	00158493          	addi	s1,a1,1
    state = 0;
 616:	4981                	li	s3,0
            if (c == '%') {
                state = '%';
            } else {
                putc(fd, c);
            }
        } else if (state == '%') {
 618:	02500a13          	li	s4,37
            if (c == 'd') {
 61c:	06400c13          	li	s8,100
                printint(fd, va_arg(ap, int), 10, 1);
            } else if (c == 'l') {
 620:	06c00c93          	li	s9,108
                //todo:seems bugs here.can`t print ULL_MAX as the param is int
                printint(fd, va_arg(ap, uint64), 10, 0);
            } else if (c == 'x') {
 624:	07800d13          	li	s10,120
                printint(fd, va_arg(ap, int), 16, 0);
            } else if (c == 'p') {
 628:	07000d93          	li	s11,112
        putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 62c:	00000b97          	auipc	s7,0x0
 630:	3c4b8b93          	addi	s7,s7,964 # 9f0 <digits>
 634:	a839                	j	652 <vprintf+0x6a>
                putc(fd, c);
 636:	85ca                	mv	a1,s2
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	ee2080e7          	jalr	-286(ra) # 51c <putc>
 642:	a019                	j	648 <vprintf+0x60>
        } else if (state == '%') {
 644:	01498f63          	beq	s3,s4,662 <vprintf+0x7a>
    for (i = 0; fmt[i]; i++) {
 648:	0485                	addi	s1,s1,1
 64a:	fff4c903          	lbu	s2,-1(s1)
 64e:	14090d63          	beqz	s2,7a8 <vprintf+0x1c0>
        c = fmt[i] & 0xff;
 652:	0009079b          	sext.w	a5,s2
        if (state == 0) {
 656:	fe0997e3          	bnez	s3,644 <vprintf+0x5c>
            if (c == '%') {
 65a:	fd479ee3          	bne	a5,s4,636 <vprintf+0x4e>
                state = '%';
 65e:	89be                	mv	s3,a5
 660:	b7e5                	j	648 <vprintf+0x60>
            if (c == 'd') {
 662:	05878063          	beq	a5,s8,6a2 <vprintf+0xba>
            } else if (c == 'l') {
 666:	05978c63          	beq	a5,s9,6be <vprintf+0xd6>
            } else if (c == 'x') {
 66a:	07a78863          	beq	a5,s10,6da <vprintf+0xf2>
            } else if (c == 'p') {
 66e:	09b78463          	beq	a5,s11,6f6 <vprintf+0x10e>
                printptr(fd, va_arg(ap, uint64));
            } else if (c == 's') {
 672:	07300713          	li	a4,115
 676:	0ce78663          	beq	a5,a4,742 <vprintf+0x15a>
                    s = "(null)";
                while (*s != 0) {
                    putc(fd, *s);
                    s++;
                }
            } else if (c == 'c') {
 67a:	06300713          	li	a4,99
 67e:	0ee78e63          	beq	a5,a4,77a <vprintf+0x192>
                putc(fd, va_arg(ap, uint));
            } else if (c == '%') {
 682:	11478863          	beq	a5,s4,792 <vprintf+0x1aa>
                putc(fd, c);
            } else {
                // Unknown % sequence.  Print it to draw attention.
                putc(fd, '%');
 686:	85d2                	mv	a1,s4
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e92080e7          	jalr	-366(ra) # 51c <putc>
                putc(fd, c);
 692:	85ca                	mv	a1,s2
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e86080e7          	jalr	-378(ra) # 51c <putc>
            }
            state = 0;
 69e:	4981                	li	s3,0
 6a0:	b765                	j	648 <vprintf+0x60>
                printint(fd, va_arg(ap, int), 10, 1);
 6a2:	008b0913          	addi	s2,s6,8
 6a6:	4685                	li	a3,1
 6a8:	4629                	li	a2,10
 6aa:	000b2583          	lw	a1,0(s6)
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e8e080e7          	jalr	-370(ra) # 53e <printint>
 6b8:	8b4a                	mv	s6,s2
            state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b771                	j	648 <vprintf+0x60>
                printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	008b0913          	addi	s2,s6,8
 6c2:	4681                	li	a3,0
 6c4:	4629                	li	a2,10
 6c6:	000b2583          	lw	a1,0(s6)
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	e72080e7          	jalr	-398(ra) # 53e <printint>
 6d4:	8b4a                	mv	s6,s2
            state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bf85                	j	648 <vprintf+0x60>
                printint(fd, va_arg(ap, int), 16, 0);
 6da:	008b0913          	addi	s2,s6,8
 6de:	4681                	li	a3,0
 6e0:	4641                	li	a2,16
 6e2:	000b2583          	lw	a1,0(s6)
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	e56080e7          	jalr	-426(ra) # 53e <printint>
 6f0:	8b4a                	mv	s6,s2
            state = 0;
 6f2:	4981                	li	s3,0
 6f4:	bf91                	j	648 <vprintf+0x60>
                printptr(fd, va_arg(ap, uint64));
 6f6:	008b0793          	addi	a5,s6,8
 6fa:	f8f43423          	sd	a5,-120(s0)
 6fe:	000b3983          	ld	s3,0(s6)
    putc(fd, '0');
 702:	03000593          	li	a1,48
 706:	8556                	mv	a0,s5
 708:	00000097          	auipc	ra,0x0
 70c:	e14080e7          	jalr	-492(ra) # 51c <putc>
    putc(fd, 'x');
 710:	85ea                	mv	a1,s10
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e08080e7          	jalr	-504(ra) # 51c <putc>
 71c:	4941                	li	s2,16
        putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 71e:	03c9d793          	srli	a5,s3,0x3c
 722:	97de                	add	a5,a5,s7
 724:	0007c583          	lbu	a1,0(a5)
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	df2080e7          	jalr	-526(ra) # 51c <putc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 732:	0992                	slli	s3,s3,0x4
 734:	397d                	addiw	s2,s2,-1
 736:	fe0914e3          	bnez	s2,71e <vprintf+0x136>
                printptr(fd, va_arg(ap, uint64));
 73a:	f8843b03          	ld	s6,-120(s0)
            state = 0;
 73e:	4981                	li	s3,0
 740:	b721                	j	648 <vprintf+0x60>
                s = va_arg(ap, char*);
 742:	008b0993          	addi	s3,s6,8
 746:	000b3903          	ld	s2,0(s6)
                if (s == 0)
 74a:	02090163          	beqz	s2,76c <vprintf+0x184>
                while (*s != 0) {
 74e:	00094583          	lbu	a1,0(s2)
 752:	c9a1                	beqz	a1,7a2 <vprintf+0x1ba>
                    putc(fd, *s);
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	dc6080e7          	jalr	-570(ra) # 51c <putc>
                    s++;
 75e:	0905                	addi	s2,s2,1
                while (*s != 0) {
 760:	00094583          	lbu	a1,0(s2)
 764:	f9e5                	bnez	a1,754 <vprintf+0x16c>
                s = va_arg(ap, char*);
 766:	8b4e                	mv	s6,s3
            state = 0;
 768:	4981                	li	s3,0
 76a:	bdf9                	j	648 <vprintf+0x60>
                    s = "(null)";
 76c:	00000917          	auipc	s2,0x0
 770:	27c90913          	addi	s2,s2,636 # 9e8 <malloc+0x136>
                while (*s != 0) {
 774:	02800593          	li	a1,40
 778:	bff1                	j	754 <vprintf+0x16c>
                putc(fd, va_arg(ap, uint));
 77a:	008b0913          	addi	s2,s6,8
 77e:	000b4583          	lbu	a1,0(s6)
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	d98080e7          	jalr	-616(ra) # 51c <putc>
 78c:	8b4a                	mv	s6,s2
            state = 0;
 78e:	4981                	li	s3,0
 790:	bd65                	j	648 <vprintf+0x60>
                putc(fd, c);
 792:	85d2                	mv	a1,s4
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	d86080e7          	jalr	-634(ra) # 51c <putc>
            state = 0;
 79e:	4981                	li	s3,0
 7a0:	b565                	j	648 <vprintf+0x60>
                s = va_arg(ap, char*);
 7a2:	8b4e                	mv	s6,s3
            state = 0;
 7a4:	4981                	li	s3,0
 7a6:	b54d                	j	648 <vprintf+0x60>
        }
    }
}
 7a8:	70e6                	ld	ra,120(sp)
 7aa:	7446                	ld	s0,112(sp)
 7ac:	74a6                	ld	s1,104(sp)
 7ae:	7906                	ld	s2,96(sp)
 7b0:	69e6                	ld	s3,88(sp)
 7b2:	6a46                	ld	s4,80(sp)
 7b4:	6aa6                	ld	s5,72(sp)
 7b6:	6b06                	ld	s6,64(sp)
 7b8:	7be2                	ld	s7,56(sp)
 7ba:	7c42                	ld	s8,48(sp)
 7bc:	7ca2                	ld	s9,40(sp)
 7be:	7d02                	ld	s10,32(sp)
 7c0:	6de2                	ld	s11,24(sp)
 7c2:	6109                	addi	sp,sp,128
 7c4:	8082                	ret

00000000000007c6 <fprintf>:

void fprintf(int fd, const char* fmt, ...)
{
 7c6:	715d                	addi	sp,sp,-80
 7c8:	ec06                	sd	ra,24(sp)
 7ca:	e822                	sd	s0,16(sp)
 7cc:	1000                	addi	s0,sp,32
 7ce:	e010                	sd	a2,0(s0)
 7d0:	e414                	sd	a3,8(s0)
 7d2:	e818                	sd	a4,16(s0)
 7d4:	ec1c                	sd	a5,24(s0)
 7d6:	03043023          	sd	a6,32(s0)
 7da:	03143423          	sd	a7,40(s0)
    va_list ap;

    va_start(ap, fmt);
 7de:	fe843423          	sd	s0,-24(s0)
    vprintf(fd, fmt, ap);
 7e2:	8622                	mv	a2,s0
 7e4:	00000097          	auipc	ra,0x0
 7e8:	e04080e7          	jalr	-508(ra) # 5e8 <vprintf>
}
 7ec:	60e2                	ld	ra,24(sp)
 7ee:	6442                	ld	s0,16(sp)
 7f0:	6161                	addi	sp,sp,80
 7f2:	8082                	ret

00000000000007f4 <printf>:

void printf(const char* fmt, ...)
{
 7f4:	711d                	addi	sp,sp,-96
 7f6:	ec06                	sd	ra,24(sp)
 7f8:	e822                	sd	s0,16(sp)
 7fa:	1000                	addi	s0,sp,32
 7fc:	e40c                	sd	a1,8(s0)
 7fe:	e810                	sd	a2,16(s0)
 800:	ec14                	sd	a3,24(s0)
 802:	f018                	sd	a4,32(s0)
 804:	f41c                	sd	a5,40(s0)
 806:	03043823          	sd	a6,48(s0)
 80a:	03143c23          	sd	a7,56(s0)
    va_list ap;

    va_start(ap, fmt);
 80e:	00840613          	addi	a2,s0,8
 812:	fec43423          	sd	a2,-24(s0)
    vprintf(1, fmt, ap);
 816:	85aa                	mv	a1,a0
 818:	4505                	li	a0,1
 81a:	00000097          	auipc	ra,0x0
 81e:	dce080e7          	jalr	-562(ra) # 5e8 <vprintf>
}
 822:	60e2                	ld	ra,24(sp)
 824:	6442                	ld	s0,16(sp)
 826:	6125                	addi	sp,sp,96
 828:	8082                	ret

000000000000082a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82a:	1141                	addi	sp,sp,-16
 82c:	e422                	sd	s0,8(sp)
 82e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 830:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 834:	00000797          	auipc	a5,0x0
 838:	1ec7b783          	ld	a5,492(a5) # a20 <freep>
 83c:	a805                	j	86c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 83e:	4618                	lw	a4,8(a2)
 840:	9db9                	addw	a1,a1,a4
 842:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 846:	6398                	ld	a4,0(a5)
 848:	6318                	ld	a4,0(a4)
 84a:	fee53823          	sd	a4,-16(a0)
 84e:	a091                	j	892 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 850:	ff852703          	lw	a4,-8(a0)
 854:	9e39                	addw	a2,a2,a4
 856:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 858:	ff053703          	ld	a4,-16(a0)
 85c:	e398                	sd	a4,0(a5)
 85e:	a099                	j	8a4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 860:	6398                	ld	a4,0(a5)
 862:	00e7e463          	bltu	a5,a4,86a <free+0x40>
 866:	00e6ea63          	bltu	a3,a4,87a <free+0x50>
{
 86a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86c:	fed7fae3          	bgeu	a5,a3,860 <free+0x36>
 870:	6398                	ld	a4,0(a5)
 872:	00e6e463          	bltu	a3,a4,87a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 876:	fee7eae3          	bltu	a5,a4,86a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 87a:	ff852583          	lw	a1,-8(a0)
 87e:	6390                	ld	a2,0(a5)
 880:	02059713          	slli	a4,a1,0x20
 884:	9301                	srli	a4,a4,0x20
 886:	0712                	slli	a4,a4,0x4
 888:	9736                	add	a4,a4,a3
 88a:	fae60ae3          	beq	a2,a4,83e <free+0x14>
    bp->s.ptr = p->s.ptr;
 88e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 892:	4790                	lw	a2,8(a5)
 894:	02061713          	slli	a4,a2,0x20
 898:	9301                	srli	a4,a4,0x20
 89a:	0712                	slli	a4,a4,0x4
 89c:	973e                	add	a4,a4,a5
 89e:	fae689e3          	beq	a3,a4,850 <free+0x26>
  } else
    p->s.ptr = bp;
 8a2:	e394                	sd	a3,0(a5)
  freep = p;
 8a4:	00000717          	auipc	a4,0x0
 8a8:	16f73e23          	sd	a5,380(a4) # a20 <freep>
}
 8ac:	6422                	ld	s0,8(sp)
 8ae:	0141                	addi	sp,sp,16
 8b0:	8082                	ret

00000000000008b2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b2:	7139                	addi	sp,sp,-64
 8b4:	fc06                	sd	ra,56(sp)
 8b6:	f822                	sd	s0,48(sp)
 8b8:	f426                	sd	s1,40(sp)
 8ba:	f04a                	sd	s2,32(sp)
 8bc:	ec4e                	sd	s3,24(sp)
 8be:	e852                	sd	s4,16(sp)
 8c0:	e456                	sd	s5,8(sp)
 8c2:	e05a                	sd	s6,0(sp)
 8c4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c6:	02051493          	slli	s1,a0,0x20
 8ca:	9081                	srli	s1,s1,0x20
 8cc:	04bd                	addi	s1,s1,15
 8ce:	8091                	srli	s1,s1,0x4
 8d0:	0014899b          	addiw	s3,s1,1
 8d4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d6:	00000517          	auipc	a0,0x0
 8da:	14a53503          	ld	a0,330(a0) # a20 <freep>
 8de:	c515                	beqz	a0,90a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e2:	4798                	lw	a4,8(a5)
 8e4:	02977f63          	bgeu	a4,s1,922 <malloc+0x70>
 8e8:	8a4e                	mv	s4,s3
 8ea:	0009871b          	sext.w	a4,s3
 8ee:	6685                	lui	a3,0x1
 8f0:	00d77363          	bgeu	a4,a3,8f6 <malloc+0x44>
 8f4:	6a05                	lui	s4,0x1
 8f6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fe:	00000917          	auipc	s2,0x0
 902:	12290913          	addi	s2,s2,290 # a20 <freep>
  if(p == (char*)-1)
 906:	5afd                	li	s5,-1
 908:	a88d                	j	97a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 90a:	00000797          	auipc	a5,0x0
 90e:	11e78793          	addi	a5,a5,286 # a28 <base>
 912:	00000717          	auipc	a4,0x0
 916:	10f73723          	sd	a5,270(a4) # a20 <freep>
 91a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 91c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 920:	b7e1                	j	8e8 <malloc+0x36>
      if(p->s.size == nunits)
 922:	02e48b63          	beq	s1,a4,958 <malloc+0xa6>
        p->s.size -= nunits;
 926:	4137073b          	subw	a4,a4,s3
 92a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92c:	1702                	slli	a4,a4,0x20
 92e:	9301                	srli	a4,a4,0x20
 930:	0712                	slli	a4,a4,0x4
 932:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 934:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 938:	00000717          	auipc	a4,0x0
 93c:	0ea73423          	sd	a0,232(a4) # a20 <freep>
      return (void*)(p + 1);
 940:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 944:	70e2                	ld	ra,56(sp)
 946:	7442                	ld	s0,48(sp)
 948:	74a2                	ld	s1,40(sp)
 94a:	7902                	ld	s2,32(sp)
 94c:	69e2                	ld	s3,24(sp)
 94e:	6a42                	ld	s4,16(sp)
 950:	6aa2                	ld	s5,8(sp)
 952:	6b02                	ld	s6,0(sp)
 954:	6121                	addi	sp,sp,64
 956:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 958:	6398                	ld	a4,0(a5)
 95a:	e118                	sd	a4,0(a0)
 95c:	bff1                	j	938 <malloc+0x86>
  hp->s.size = nu;
 95e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 962:	0541                	addi	a0,a0,16
 964:	00000097          	auipc	ra,0x0
 968:	ec6080e7          	jalr	-314(ra) # 82a <free>
  return freep;
 96c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 970:	d971                	beqz	a0,944 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 972:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 974:	4798                	lw	a4,8(a5)
 976:	fa9776e3          	bgeu	a4,s1,922 <malloc+0x70>
    if(p == freep)
 97a:	00093703          	ld	a4,0(s2)
 97e:	853e                	mv	a0,a5
 980:	fef719e3          	bne	a4,a5,972 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 984:	8552                	mv	a0,s4
 986:	00000097          	auipc	ra,0x0
 98a:	b7e080e7          	jalr	-1154(ra) # 504 <sbrk>
  if(p == (char*)-1)
 98e:	fd5518e3          	bne	a0,s5,95e <malloc+0xac>
        return 0;
 992:	4501                	li	a0,0
 994:	bf45                	j	944 <malloc+0x92>
