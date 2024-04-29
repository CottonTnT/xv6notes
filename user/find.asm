
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "user/user.h"

char* fmtname(char* path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
    static char buf[DIRSIZ + 1];
    char* p;

    // Find first character after last slash.
    for (p = path + strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	3a0080e7          	jalr	928(ra) # 3b0 <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
        ;
    p++;
  36:	00178493          	addi	s1,a5,1

    // Return blank-padded name.
    if (strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	374080e7          	jalr	884(ra) # 3b0 <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
        return p;
    memmove(buf, p, strlen(p));
    memset(buf + strlen(p), '\0', DIRSIZ - strlen(p));
    return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
    memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	352080e7          	jalr	850(ra) # 3b0 <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	b4298993          	addi	s3,s3,-1214 # ba8 <buf.1107>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	4b2080e7          	jalr	1202(ra) # 528 <memmove>
    memset(buf + strlen(p), '\0', DIRSIZ - strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	330080e7          	jalr	816(ra) # 3b0 <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	322080e7          	jalr	802(ra) # 3b0 <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	4581                	li	a1,0
  a2:	01298533          	add	a0,s3,s2
  a6:	00000097          	auipc	ra,0x0
  aa:	334080e7          	jalr	820(ra) # 3da <memset>
    return buf;
  ae:	84ce                	mv	s1,s3
  b0:	bf71                	j	4c <fmtname+0x4c>

00000000000000b2 <find>:

void find(char* path, char* target)
{
  b2:	d8010113          	addi	sp,sp,-640
  b6:	26113c23          	sd	ra,632(sp)
  ba:	26813823          	sd	s0,624(sp)
  be:	26913423          	sd	s1,616(sp)
  c2:	27213023          	sd	s2,608(sp)
  c6:	25313c23          	sd	s3,600(sp)
  ca:	25413823          	sd	s4,592(sp)
  ce:	25513423          	sd	s5,584(sp)
  d2:	25613023          	sd	s6,576(sp)
  d6:	23713c23          	sd	s7,568(sp)
  da:	0500                	addi	s0,sp,640
  dc:	892a                	mv	s2,a0
  de:	89ae                	mv	s3,a1
    int fd = open(path, O_RDONLY);
  e0:	4581                	li	a1,0
  e2:	00000097          	auipc	ra,0x0
  e6:	53c080e7          	jalr	1340(ra) # 61e <open>
    if (fd < 0)
  ea:	04054f63          	bltz	a0,148 <find+0x96>
  ee:	84aa                	mv	s1,a0
    {
        fprintf(2, "can`t open %s\n", path);
        exit(0);
    }
    struct stat st;
    if (fstat(fd, &st) < 0)
  f0:	f9840593          	addi	a1,s0,-104
  f4:	00000097          	auipc	ra,0x0
  f8:	542080e7          	jalr	1346(ra) # 636 <fstat>
  fc:	06054563          	bltz	a0,166 <find+0xb4>
    {
        close(fd);
        fprintf(2, "can`t stat %s\n", path);
        exit(0);
    }
    switch (st.type)
 100:	fa041783          	lh	a5,-96(s0)
 104:	0007869b          	sext.w	a3,a5
 108:	4705                	li	a4,1
 10a:	08e68263          	beq	a3,a4,18e <find+0xdc>
 10e:	4709                	li	a4,2
 110:	14e68363          	beq	a3,a4,256 <find+0x1a4>
                printf("%s\n", path);
            }
            break;
        }
    }
    close(fd);
 114:	8526                	mv	a0,s1
 116:	00000097          	auipc	ra,0x0
 11a:	4f0080e7          	jalr	1264(ra) # 606 <close>
}
 11e:	27813083          	ld	ra,632(sp)
 122:	27013403          	ld	s0,624(sp)
 126:	26813483          	ld	s1,616(sp)
 12a:	26013903          	ld	s2,608(sp)
 12e:	25813983          	ld	s3,600(sp)
 132:	25013a03          	ld	s4,592(sp)
 136:	24813a83          	ld	s5,584(sp)
 13a:	24013b03          	ld	s6,576(sp)
 13e:	23813b83          	ld	s7,568(sp)
 142:	28010113          	addi	sp,sp,640
 146:	8082                	ret
        fprintf(2, "can`t open %s\n", path);
 148:	864a                	mv	a2,s2
 14a:	00001597          	auipc	a1,0x1
 14e:	9ae58593          	addi	a1,a1,-1618 # af8 <malloc+0xe4>
 152:	4509                	li	a0,2
 154:	00000097          	auipc	ra,0x0
 158:	7d4080e7          	jalr	2004(ra) # 928 <fprintf>
        exit(0);
 15c:	4501                	li	a0,0
 15e:	00000097          	auipc	ra,0x0
 162:	480080e7          	jalr	1152(ra) # 5de <exit>
        close(fd);
 166:	8526                	mv	a0,s1
 168:	00000097          	auipc	ra,0x0
 16c:	49e080e7          	jalr	1182(ra) # 606 <close>
        fprintf(2, "can`t stat %s\n", path);
 170:	864a                	mv	a2,s2
 172:	00001597          	auipc	a1,0x1
 176:	99658593          	addi	a1,a1,-1642 # b08 <malloc+0xf4>
 17a:	4509                	li	a0,2
 17c:	00000097          	auipc	ra,0x0
 180:	7ac080e7          	jalr	1964(ra) # 928 <fprintf>
        exit(0);
 184:	4501                	li	a0,0
 186:	00000097          	auipc	ra,0x0
 18a:	458080e7          	jalr	1112(ra) # 5de <exit>
            if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf)
 18e:	854a                	mv	a0,s2
 190:	00000097          	auipc	ra,0x0
 194:	220080e7          	jalr	544(ra) # 3b0 <strlen>
 198:	2541                	addiw	a0,a0,16
 19a:	20000793          	li	a5,512
 19e:	00a7fb63          	bgeu	a5,a0,1b4 <find+0x102>
                printf("find: path too long\n");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	97650513          	addi	a0,a0,-1674 # b18 <malloc+0x104>
 1aa:	00000097          	auipc	ra,0x0
 1ae:	7ac080e7          	jalr	1964(ra) # 956 <printf>
                break;
 1b2:	b78d                	j	114 <find+0x62>
            strcpy(buf, path);
 1b4:	85ca                	mv	a1,s2
 1b6:	d9840513          	addi	a0,s0,-616
 1ba:	00000097          	auipc	ra,0x0
 1be:	1ae080e7          	jalr	430(ra) # 368 <strcpy>
            char* p = buf + strlen(path);
 1c2:	854a                	mv	a0,s2
 1c4:	00000097          	auipc	ra,0x0
 1c8:	1ec080e7          	jalr	492(ra) # 3b0 <strlen>
 1cc:	02051913          	slli	s2,a0,0x20
 1d0:	02095913          	srli	s2,s2,0x20
 1d4:	d9840793          	addi	a5,s0,-616
 1d8:	993e                	add	s2,s2,a5
            *p = '/';
 1da:	02f00793          	li	a5,47
 1de:	00f90023          	sb	a5,0(s2)
            p++;
 1e2:	00190b93          	addi	s7,s2,1
                if (!strcmp(de.name, "."))
 1e6:	00001a97          	auipc	s5,0x1
 1ea:	94aa8a93          	addi	s5,s5,-1718 # b30 <malloc+0x11c>
                if (!strcmp(de.name, ".."))
 1ee:	00001b17          	auipc	s6,0x1
 1f2:	94ab0b13          	addi	s6,s6,-1718 # b38 <malloc+0x124>
                if (!strcmp(de.name, "."))
 1f6:	d8a40a13          	addi	s4,s0,-630
            while (read(fd, &de, sizeof de) == sizeof de)
 1fa:	4641                	li	a2,16
 1fc:	d8840593          	addi	a1,s0,-632
 200:	8526                	mv	a0,s1
 202:	00000097          	auipc	ra,0x0
 206:	3f4080e7          	jalr	1012(ra) # 5f6 <read>
 20a:	47c1                	li	a5,16
 20c:	f0f514e3          	bne	a0,a5,114 <find+0x62>
                if (de.inum == 0)
 210:	d8845783          	lhu	a5,-632(s0)
 214:	d3fd                	beqz	a5,1fa <find+0x148>
                if (!strcmp(de.name, "."))
 216:	85d6                	mv	a1,s5
 218:	8552                	mv	a0,s4
 21a:	00000097          	auipc	ra,0x0
 21e:	16a080e7          	jalr	362(ra) # 384 <strcmp>
 222:	dd61                	beqz	a0,1fa <find+0x148>
                if (!strcmp(de.name, ".."))
 224:	85da                	mv	a1,s6
 226:	8552                	mv	a0,s4
 228:	00000097          	auipc	ra,0x0
 22c:	15c080e7          	jalr	348(ra) # 384 <strcmp>
 230:	d569                	beqz	a0,1fa <find+0x148>
                memmove(p, de.name, DIRSIZ);
 232:	4639                	li	a2,14
 234:	d8a40593          	addi	a1,s0,-630
 238:	855e                	mv	a0,s7
 23a:	00000097          	auipc	ra,0x0
 23e:	2ee080e7          	jalr	750(ra) # 528 <memmove>
                p[DIRSIZ] = 0;
 242:	000907a3          	sb	zero,15(s2)
                find(buf, target);
 246:	85ce                	mv	a1,s3
 248:	d9840513          	addi	a0,s0,-616
 24c:	00000097          	auipc	ra,0x0
 250:	e66080e7          	jalr	-410(ra) # b2 <find>
 254:	b75d                	j	1fa <find+0x148>
            if (!strcmp(fmtname(path), target))
 256:	854a                	mv	a0,s2
 258:	00000097          	auipc	ra,0x0
 25c:	da8080e7          	jalr	-600(ra) # 0 <fmtname>
 260:	85ce                	mv	a1,s3
 262:	00000097          	auipc	ra,0x0
 266:	122080e7          	jalr	290(ra) # 384 <strcmp>
 26a:	ea0515e3          	bnez	a0,114 <find+0x62>
                printf("%s\n", path);
 26e:	85ca                	mv	a1,s2
 270:	00001517          	auipc	a0,0x1
 274:	8d050513          	addi	a0,a0,-1840 # b40 <malloc+0x12c>
 278:	00000097          	auipc	ra,0x0
 27c:	6de080e7          	jalr	1758(ra) # 956 <printf>
 280:	bd51                	j	114 <find+0x62>

0000000000000282 <main>:
int main(int argc, char* argv[])
{
 282:	715d                	addi	sp,sp,-80
 284:	e486                	sd	ra,72(sp)
 286:	e0a2                	sd	s0,64(sp)
 288:	fc26                	sd	s1,56(sp)
 28a:	f84a                	sd	s2,48(sp)
 28c:	f44e                	sd	s3,40(sp)
 28e:	0880                	addi	s0,sp,80
    if (argc > 3)
 290:	478d                	li	a5,3
 292:	02a7d063          	bge	a5,a0,2b2 <main+0x30>
    {
        fprintf(2, "useage:find from_path filename");
 296:	00001597          	auipc	a1,0x1
 29a:	8b258593          	addi	a1,a1,-1870 # b48 <malloc+0x134>
 29e:	4509                	li	a0,2
 2a0:	00000097          	auipc	ra,0x0
 2a4:	688080e7          	jalr	1672(ra) # 928 <fprintf>
        exit(0);
 2a8:	4501                	li	a0,0
 2aa:	00000097          	auipc	ra,0x0
 2ae:	334080e7          	jalr	820(ra) # 5de <exit>
 2b2:	84ae                	mv	s1,a1
    }
    char* path = argv[1];
 2b4:	0085b983          	ld	s3,8(a1)
    int fd = open(path, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	854e                	mv	a0,s3
 2bc:	00000097          	auipc	ra,0x0
 2c0:	362080e7          	jalr	866(ra) # 61e <open>
 2c4:	892a                	mv	s2,a0
    if (fd < 0)
 2c6:	02054a63          	bltz	a0,2fa <main+0x78>
    {
        fprintf(2, "can`t open %s\n", path);
        exit(0);
    }
    struct stat st;
    if (fstat(fd, &st) < 0)
 2ca:	fb840593          	addi	a1,s0,-72
 2ce:	00000097          	auipc	ra,0x0
 2d2:	368080e7          	jalr	872(ra) # 636 <fstat>
 2d6:	04054163          	bltz	a0,318 <main+0x96>
    {
        fprintf(2, "can`t stat %s\n", path);
        close(fd);
        exit(0);
    }
    if (st.type == T_FILE)
 2da:	fc041703          	lh	a4,-64(s0)
 2de:	4789                	li	a5,2
 2e0:	06f70063          	beq	a4,a5,340 <main+0xbe>
    {
        fprintf(2, "%s is not directory\n", path);
        close(fd);
        exit(0);
    }
    find(path, argv[2]);
 2e4:	688c                	ld	a1,16(s1)
 2e6:	854e                	mv	a0,s3
 2e8:	00000097          	auipc	ra,0x0
 2ec:	dca080e7          	jalr	-566(ra) # b2 <find>
    exit(0);
 2f0:	4501                	li	a0,0
 2f2:	00000097          	auipc	ra,0x0
 2f6:	2ec080e7          	jalr	748(ra) # 5de <exit>
        fprintf(2, "can`t open %s\n", path);
 2fa:	864e                	mv	a2,s3
 2fc:	00000597          	auipc	a1,0x0
 300:	7fc58593          	addi	a1,a1,2044 # af8 <malloc+0xe4>
 304:	4509                	li	a0,2
 306:	00000097          	auipc	ra,0x0
 30a:	622080e7          	jalr	1570(ra) # 928 <fprintf>
        exit(0);
 30e:	4501                	li	a0,0
 310:	00000097          	auipc	ra,0x0
 314:	2ce080e7          	jalr	718(ra) # 5de <exit>
        fprintf(2, "can`t stat %s\n", path);
 318:	864e                	mv	a2,s3
 31a:	00000597          	auipc	a1,0x0
 31e:	7ee58593          	addi	a1,a1,2030 # b08 <malloc+0xf4>
 322:	4509                	li	a0,2
 324:	00000097          	auipc	ra,0x0
 328:	604080e7          	jalr	1540(ra) # 928 <fprintf>
        close(fd);
 32c:	854a                	mv	a0,s2
 32e:	00000097          	auipc	ra,0x0
 332:	2d8080e7          	jalr	728(ra) # 606 <close>
        exit(0);
 336:	4501                	li	a0,0
 338:	00000097          	auipc	ra,0x0
 33c:	2a6080e7          	jalr	678(ra) # 5de <exit>
        fprintf(2, "%s is not directory\n", path);
 340:	864e                	mv	a2,s3
 342:	00001597          	auipc	a1,0x1
 346:	82658593          	addi	a1,a1,-2010 # b68 <malloc+0x154>
 34a:	4509                	li	a0,2
 34c:	00000097          	auipc	ra,0x0
 350:	5dc080e7          	jalr	1500(ra) # 928 <fprintf>
        close(fd);
 354:	854a                	mv	a0,s2
 356:	00000097          	auipc	ra,0x0
 35a:	2b0080e7          	jalr	688(ra) # 606 <close>
        exit(0);
 35e:	4501                	li	a0,0
 360:	00000097          	auipc	ra,0x0
 364:	27e080e7          	jalr	638(ra) # 5de <exit>

0000000000000368 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e422                	sd	s0,8(sp)
 36c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 36e:	87aa                	mv	a5,a0
 370:	0585                	addi	a1,a1,1
 372:	0785                	addi	a5,a5,1
 374:	fff5c703          	lbu	a4,-1(a1)
 378:	fee78fa3          	sb	a4,-1(a5)
 37c:	fb75                	bnez	a4,370 <strcpy+0x8>
    ;
  return os;
}
 37e:	6422                	ld	s0,8(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret

0000000000000384 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 384:	1141                	addi	sp,sp,-16
 386:	e422                	sd	s0,8(sp)
 388:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 38a:	00054783          	lbu	a5,0(a0)
 38e:	cb91                	beqz	a5,3a2 <strcmp+0x1e>
 390:	0005c703          	lbu	a4,0(a1)
 394:	00f71763          	bne	a4,a5,3a2 <strcmp+0x1e>
    p++, q++;
 398:	0505                	addi	a0,a0,1
 39a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 39c:	00054783          	lbu	a5,0(a0)
 3a0:	fbe5                	bnez	a5,390 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3a2:	0005c503          	lbu	a0,0(a1)
}
 3a6:	40a7853b          	subw	a0,a5,a0
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret

00000000000003b0 <strlen>:

uint
strlen(const char *s)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e422                	sd	s0,8(sp)
 3b4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3b6:	00054783          	lbu	a5,0(a0)
 3ba:	cf91                	beqz	a5,3d6 <strlen+0x26>
 3bc:	0505                	addi	a0,a0,1
 3be:	87aa                	mv	a5,a0
 3c0:	4685                	li	a3,1
 3c2:	9e89                	subw	a3,a3,a0
 3c4:	00f6853b          	addw	a0,a3,a5
 3c8:	0785                	addi	a5,a5,1
 3ca:	fff7c703          	lbu	a4,-1(a5)
 3ce:	fb7d                	bnez	a4,3c4 <strlen+0x14>
    ;
  return n;
}
 3d0:	6422                	ld	s0,8(sp)
 3d2:	0141                	addi	sp,sp,16
 3d4:	8082                	ret
  for(n = 0; s[n]; n++)
 3d6:	4501                	li	a0,0
 3d8:	bfe5                	j	3d0 <strlen+0x20>

00000000000003da <memset>:

void*
memset(void *dst, int c, uint n)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e422                	sd	s0,8(sp)
 3de:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3e0:	ce09                	beqz	a2,3fa <memset+0x20>
 3e2:	87aa                	mv	a5,a0
 3e4:	fff6071b          	addiw	a4,a2,-1
 3e8:	1702                	slli	a4,a4,0x20
 3ea:	9301                	srli	a4,a4,0x20
 3ec:	0705                	addi	a4,a4,1
 3ee:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3f4:	0785                	addi	a5,a5,1
 3f6:	fee79de3          	bne	a5,a4,3f0 <memset+0x16>
  }
  return dst;
}
 3fa:	6422                	ld	s0,8(sp)
 3fc:	0141                	addi	sp,sp,16
 3fe:	8082                	ret

0000000000000400 <strchr>:

char*
strchr(const char *s, char c)
{
 400:	1141                	addi	sp,sp,-16
 402:	e422                	sd	s0,8(sp)
 404:	0800                	addi	s0,sp,16
  for(; *s; s++)
 406:	00054783          	lbu	a5,0(a0)
 40a:	cb99                	beqz	a5,420 <strchr+0x20>
    if(*s == c)
 40c:	00f58763          	beq	a1,a5,41a <strchr+0x1a>
  for(; *s; s++)
 410:	0505                	addi	a0,a0,1
 412:	00054783          	lbu	a5,0(a0)
 416:	fbfd                	bnez	a5,40c <strchr+0xc>
      return (char*)s;
  return 0;
 418:	4501                	li	a0,0
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  return 0;
 420:	4501                	li	a0,0
 422:	bfe5                	j	41a <strchr+0x1a>

0000000000000424 <gets>:

char*
gets(char *buf, int max)
{
 424:	711d                	addi	sp,sp,-96
 426:	ec86                	sd	ra,88(sp)
 428:	e8a2                	sd	s0,80(sp)
 42a:	e4a6                	sd	s1,72(sp)
 42c:	e0ca                	sd	s2,64(sp)
 42e:	fc4e                	sd	s3,56(sp)
 430:	f852                	sd	s4,48(sp)
 432:	f456                	sd	s5,40(sp)
 434:	f05a                	sd	s6,32(sp)
 436:	ec5e                	sd	s7,24(sp)
 438:	1080                	addi	s0,sp,96
 43a:	8baa                	mv	s7,a0
 43c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 43e:	892a                	mv	s2,a0
 440:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 442:	4aa9                	li	s5,10
 444:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 446:	89a6                	mv	s3,s1
 448:	2485                	addiw	s1,s1,1
 44a:	0344d863          	bge	s1,s4,47a <gets+0x56>
    cc = read(0, &c, 1);
 44e:	4605                	li	a2,1
 450:	faf40593          	addi	a1,s0,-81
 454:	4501                	li	a0,0
 456:	00000097          	auipc	ra,0x0
 45a:	1a0080e7          	jalr	416(ra) # 5f6 <read>
    if(cc < 1)
 45e:	00a05e63          	blez	a0,47a <gets+0x56>
    buf[i++] = c;
 462:	faf44783          	lbu	a5,-81(s0)
 466:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 46a:	01578763          	beq	a5,s5,478 <gets+0x54>
 46e:	0905                	addi	s2,s2,1
 470:	fd679be3          	bne	a5,s6,446 <gets+0x22>
  for(i=0; i+1 < max; ){
 474:	89a6                	mv	s3,s1
 476:	a011                	j	47a <gets+0x56>
 478:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 47a:	99de                	add	s3,s3,s7
 47c:	00098023          	sb	zero,0(s3)
  return buf;
}
 480:	855e                	mv	a0,s7
 482:	60e6                	ld	ra,88(sp)
 484:	6446                	ld	s0,80(sp)
 486:	64a6                	ld	s1,72(sp)
 488:	6906                	ld	s2,64(sp)
 48a:	79e2                	ld	s3,56(sp)
 48c:	7a42                	ld	s4,48(sp)
 48e:	7aa2                	ld	s5,40(sp)
 490:	7b02                	ld	s6,32(sp)
 492:	6be2                	ld	s7,24(sp)
 494:	6125                	addi	sp,sp,96
 496:	8082                	ret

0000000000000498 <stat>:

int
stat(const char *n, struct stat *st)
{
 498:	1101                	addi	sp,sp,-32
 49a:	ec06                	sd	ra,24(sp)
 49c:	e822                	sd	s0,16(sp)
 49e:	e426                	sd	s1,8(sp)
 4a0:	e04a                	sd	s2,0(sp)
 4a2:	1000                	addi	s0,sp,32
 4a4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4a6:	4581                	li	a1,0
 4a8:	00000097          	auipc	ra,0x0
 4ac:	176080e7          	jalr	374(ra) # 61e <open>
  if(fd < 0)
 4b0:	02054563          	bltz	a0,4da <stat+0x42>
 4b4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4b6:	85ca                	mv	a1,s2
 4b8:	00000097          	auipc	ra,0x0
 4bc:	17e080e7          	jalr	382(ra) # 636 <fstat>
 4c0:	892a                	mv	s2,a0
  close(fd);
 4c2:	8526                	mv	a0,s1
 4c4:	00000097          	auipc	ra,0x0
 4c8:	142080e7          	jalr	322(ra) # 606 <close>
  return r;
}
 4cc:	854a                	mv	a0,s2
 4ce:	60e2                	ld	ra,24(sp)
 4d0:	6442                	ld	s0,16(sp)
 4d2:	64a2                	ld	s1,8(sp)
 4d4:	6902                	ld	s2,0(sp)
 4d6:	6105                	addi	sp,sp,32
 4d8:	8082                	ret
    return -1;
 4da:	597d                	li	s2,-1
 4dc:	bfc5                	j	4cc <stat+0x34>

00000000000004de <atoi>:

int
atoi(const char *s)
{
 4de:	1141                	addi	sp,sp,-16
 4e0:	e422                	sd	s0,8(sp)
 4e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4e4:	00054603          	lbu	a2,0(a0)
 4e8:	fd06079b          	addiw	a5,a2,-48
 4ec:	0ff7f793          	andi	a5,a5,255
 4f0:	4725                	li	a4,9
 4f2:	02f76963          	bltu	a4,a5,524 <atoi+0x46>
 4f6:	86aa                	mv	a3,a0
  n = 0;
 4f8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4fa:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4fc:	0685                	addi	a3,a3,1
 4fe:	0025179b          	slliw	a5,a0,0x2
 502:	9fa9                	addw	a5,a5,a0
 504:	0017979b          	slliw	a5,a5,0x1
 508:	9fb1                	addw	a5,a5,a2
 50a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 50e:	0006c603          	lbu	a2,0(a3)
 512:	fd06071b          	addiw	a4,a2,-48
 516:	0ff77713          	andi	a4,a4,255
 51a:	fee5f1e3          	bgeu	a1,a4,4fc <atoi+0x1e>
  return n;
}
 51e:	6422                	ld	s0,8(sp)
 520:	0141                	addi	sp,sp,16
 522:	8082                	ret
  n = 0;
 524:	4501                	li	a0,0
 526:	bfe5                	j	51e <atoi+0x40>

0000000000000528 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 528:	1141                	addi	sp,sp,-16
 52a:	e422                	sd	s0,8(sp)
 52c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 52e:	02b57663          	bgeu	a0,a1,55a <memmove+0x32>
    while(n-- > 0)
 532:	02c05163          	blez	a2,554 <memmove+0x2c>
 536:	fff6079b          	addiw	a5,a2,-1
 53a:	1782                	slli	a5,a5,0x20
 53c:	9381                	srli	a5,a5,0x20
 53e:	0785                	addi	a5,a5,1
 540:	97aa                	add	a5,a5,a0
  dst = vdst;
 542:	872a                	mv	a4,a0
      *dst++ = *src++;
 544:	0585                	addi	a1,a1,1
 546:	0705                	addi	a4,a4,1
 548:	fff5c683          	lbu	a3,-1(a1)
 54c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 550:	fee79ae3          	bne	a5,a4,544 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 554:	6422                	ld	s0,8(sp)
 556:	0141                	addi	sp,sp,16
 558:	8082                	ret
    dst += n;
 55a:	00c50733          	add	a4,a0,a2
    src += n;
 55e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 560:	fec05ae3          	blez	a2,554 <memmove+0x2c>
 564:	fff6079b          	addiw	a5,a2,-1
 568:	1782                	slli	a5,a5,0x20
 56a:	9381                	srli	a5,a5,0x20
 56c:	fff7c793          	not	a5,a5
 570:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 572:	15fd                	addi	a1,a1,-1
 574:	177d                	addi	a4,a4,-1
 576:	0005c683          	lbu	a3,0(a1)
 57a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 57e:	fee79ae3          	bne	a5,a4,572 <memmove+0x4a>
 582:	bfc9                	j	554 <memmove+0x2c>

0000000000000584 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 584:	1141                	addi	sp,sp,-16
 586:	e422                	sd	s0,8(sp)
 588:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 58a:	ca05                	beqz	a2,5ba <memcmp+0x36>
 58c:	fff6069b          	addiw	a3,a2,-1
 590:	1682                	slli	a3,a3,0x20
 592:	9281                	srli	a3,a3,0x20
 594:	0685                	addi	a3,a3,1
 596:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 598:	00054783          	lbu	a5,0(a0)
 59c:	0005c703          	lbu	a4,0(a1)
 5a0:	00e79863          	bne	a5,a4,5b0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5a4:	0505                	addi	a0,a0,1
    p2++;
 5a6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5a8:	fed518e3          	bne	a0,a3,598 <memcmp+0x14>
  }
  return 0;
 5ac:	4501                	li	a0,0
 5ae:	a019                	j	5b4 <memcmp+0x30>
      return *p1 - *p2;
 5b0:	40e7853b          	subw	a0,a5,a4
}
 5b4:	6422                	ld	s0,8(sp)
 5b6:	0141                	addi	sp,sp,16
 5b8:	8082                	ret
  return 0;
 5ba:	4501                	li	a0,0
 5bc:	bfe5                	j	5b4 <memcmp+0x30>

00000000000005be <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5be:	1141                	addi	sp,sp,-16
 5c0:	e406                	sd	ra,8(sp)
 5c2:	e022                	sd	s0,0(sp)
 5c4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5c6:	00000097          	auipc	ra,0x0
 5ca:	f62080e7          	jalr	-158(ra) # 528 <memmove>
}
 5ce:	60a2                	ld	ra,8(sp)
 5d0:	6402                	ld	s0,0(sp)
 5d2:	0141                	addi	sp,sp,16
 5d4:	8082                	ret

00000000000005d6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5d6:	4885                	li	a7,1
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <exit>:
.global exit
exit:
 li a7, SYS_exit
 5de:	4889                	li	a7,2
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5e6:	488d                	li	a7,3
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5ee:	4891                	li	a7,4
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <read>:
.global read
read:
 li a7, SYS_read
 5f6:	4895                	li	a7,5
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <write>:
.global write
write:
 li a7, SYS_write
 5fe:	48c1                	li	a7,16
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <close>:
.global close
close:
 li a7, SYS_close
 606:	48d5                	li	a7,21
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <kill>:
.global kill
kill:
 li a7, SYS_kill
 60e:	4899                	li	a7,6
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <exec>:
.global exec
exec:
 li a7, SYS_exec
 616:	489d                	li	a7,7
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <open>:
.global open
open:
 li a7, SYS_open
 61e:	48bd                	li	a7,15
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 626:	48c5                	li	a7,17
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 62e:	48c9                	li	a7,18
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 636:	48a1                	li	a7,8
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <link>:
.global link
link:
 li a7, SYS_link
 63e:	48cd                	li	a7,19
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 646:	48d1                	li	a7,20
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 64e:	48a5                	li	a7,9
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <dup>:
.global dup
dup:
 li a7, SYS_dup
 656:	48a9                	li	a7,10
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 65e:	48ad                	li	a7,11
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 666:	48b1                	li	a7,12
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 66e:	48b5                	li	a7,13
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 676:	48b9                	li	a7,14
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <putc>:
 * @Param char:
 * @Return:
*/
static void
putc(int fd, char c)
{
 67e:	1101                	addi	sp,sp,-32
 680:	ec06                	sd	ra,24(sp)
 682:	e822                	sd	s0,16(sp)
 684:	1000                	addi	s0,sp,32
 686:	feb407a3          	sb	a1,-17(s0)
    write(fd, &c, 1);
 68a:	4605                	li	a2,1
 68c:	fef40593          	addi	a1,s0,-17
 690:	00000097          	auipc	ra,0x0
 694:	f6e080e7          	jalr	-146(ra) # 5fe <write>
}
 698:	60e2                	ld	ra,24(sp)
 69a:	6442                	ld	s0,16(sp)
 69c:	6105                	addi	sp,sp,32
 69e:	8082                	ret

00000000000006a0 <printint>:
 * @Param sgn: 1 为 signed，0 为 unsigned
 * @Return:
*/
static void
printint(int fd, int xx, int base, int sgn)
{
 6a0:	7139                	addi	sp,sp,-64
 6a2:	fc06                	sd	ra,56(sp)
 6a4:	f822                	sd	s0,48(sp)
 6a6:	f426                	sd	s1,40(sp)
 6a8:	f04a                	sd	s2,32(sp)
 6aa:	ec4e                	sd	s3,24(sp)
 6ac:	0080                	addi	s0,sp,64
 6ae:	84aa                	mv	s1,a0
    char buf[16];
    int i, neg;
    uint x;

    neg = 0;
    if (sgn && xx < 0) {
 6b0:	c299                	beqz	a3,6b6 <printint+0x16>
 6b2:	0805c863          	bltz	a1,742 <printint+0xa2>
        neg = 1;
        x = -xx;
    } else {
        x = xx;
 6b6:	2581                	sext.w	a1,a1
    neg = 0;
 6b8:	4881                	li	a7,0
 6ba:	fc040693          	addi	a3,s0,-64
    }

    i = 0;
 6be:	4701                	li	a4,0
    do {
        buf[i++] = digits[x % base];
 6c0:	2601                	sext.w	a2,a2
 6c2:	00000517          	auipc	a0,0x0
 6c6:	4c650513          	addi	a0,a0,1222 # b88 <digits>
 6ca:	883a                	mv	a6,a4
 6cc:	2705                	addiw	a4,a4,1
 6ce:	02c5f7bb          	remuw	a5,a1,a2
 6d2:	1782                	slli	a5,a5,0x20
 6d4:	9381                	srli	a5,a5,0x20
 6d6:	97aa                	add	a5,a5,a0
 6d8:	0007c783          	lbu	a5,0(a5)
 6dc:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
 6e0:	0005879b          	sext.w	a5,a1
 6e4:	02c5d5bb          	divuw	a1,a1,a2
 6e8:	0685                	addi	a3,a3,1
 6ea:	fec7f0e3          	bgeu	a5,a2,6ca <printint+0x2a>
    if (neg)
 6ee:	00088b63          	beqz	a7,704 <printint+0x64>
        buf[i++] = '-';
 6f2:	fd040793          	addi	a5,s0,-48
 6f6:	973e                	add	a4,a4,a5
 6f8:	02d00793          	li	a5,45
 6fc:	fef70823          	sb	a5,-16(a4)
 700:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
 704:	02e05863          	blez	a4,734 <printint+0x94>
 708:	fc040793          	addi	a5,s0,-64
 70c:	00e78933          	add	s2,a5,a4
 710:	fff78993          	addi	s3,a5,-1
 714:	99ba                	add	s3,s3,a4
 716:	377d                	addiw	a4,a4,-1
 718:	1702                	slli	a4,a4,0x20
 71a:	9301                	srli	a4,a4,0x20
 71c:	40e989b3          	sub	s3,s3,a4
        putc(fd, buf[i]);
 720:	fff94583          	lbu	a1,-1(s2)
 724:	8526                	mv	a0,s1
 726:	00000097          	auipc	ra,0x0
 72a:	f58080e7          	jalr	-168(ra) # 67e <putc>
    while (--i >= 0)
 72e:	197d                	addi	s2,s2,-1
 730:	ff3918e3          	bne	s2,s3,720 <printint+0x80>
}
 734:	70e2                	ld	ra,56(sp)
 736:	7442                	ld	s0,48(sp)
 738:	74a2                	ld	s1,40(sp)
 73a:	7902                	ld	s2,32(sp)
 73c:	69e2                	ld	s3,24(sp)
 73e:	6121                	addi	sp,sp,64
 740:	8082                	ret
        x = -xx;
 742:	40b005bb          	negw	a1,a1
        neg = 1;
 746:	4885                	li	a7,1
        x = -xx;
 748:	bf8d                	j	6ba <printint+0x1a>

000000000000074a <vprintf>:
        putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void vprintf(int fd, const char* fmt, va_list ap)
{
 74a:	7119                	addi	sp,sp,-128
 74c:	fc86                	sd	ra,120(sp)
 74e:	f8a2                	sd	s0,112(sp)
 750:	f4a6                	sd	s1,104(sp)
 752:	f0ca                	sd	s2,96(sp)
 754:	ecce                	sd	s3,88(sp)
 756:	e8d2                	sd	s4,80(sp)
 758:	e4d6                	sd	s5,72(sp)
 75a:	e0da                	sd	s6,64(sp)
 75c:	fc5e                	sd	s7,56(sp)
 75e:	f862                	sd	s8,48(sp)
 760:	f466                	sd	s9,40(sp)
 762:	f06a                	sd	s10,32(sp)
 764:	ec6e                	sd	s11,24(sp)
 766:	0100                	addi	s0,sp,128
    char* s;
    int c, i, state;

    state = 0;
    for (i = 0; fmt[i]; i++) {
 768:	0005c903          	lbu	s2,0(a1)
 76c:	18090f63          	beqz	s2,90a <vprintf+0x1c0>
 770:	8aaa                	mv	s5,a0
 772:	8b32                	mv	s6,a2
 774:	00158493          	addi	s1,a1,1
    state = 0;
 778:	4981                	li	s3,0
            if (c == '%') {
                state = '%';
            } else {
                putc(fd, c);
            }
        } else if (state == '%') {
 77a:	02500a13          	li	s4,37
            if (c == 'd') {
 77e:	06400c13          	li	s8,100
                printint(fd, va_arg(ap, int), 10, 1);
            } else if (c == 'l') {
 782:	06c00c93          	li	s9,108
                //todo:seems bugs here.can`t print ULL_MAX as the param is int
                printint(fd, va_arg(ap, uint64), 10, 0);
            } else if (c == 'x') {
 786:	07800d13          	li	s10,120
                printint(fd, va_arg(ap, int), 16, 0);
            } else if (c == 'p') {
 78a:	07000d93          	li	s11,112
        putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 78e:	00000b97          	auipc	s7,0x0
 792:	3fab8b93          	addi	s7,s7,1018 # b88 <digits>
 796:	a839                	j	7b4 <vprintf+0x6a>
                putc(fd, c);
 798:	85ca                	mv	a1,s2
 79a:	8556                	mv	a0,s5
 79c:	00000097          	auipc	ra,0x0
 7a0:	ee2080e7          	jalr	-286(ra) # 67e <putc>
 7a4:	a019                	j	7aa <vprintf+0x60>
        } else if (state == '%') {
 7a6:	01498f63          	beq	s3,s4,7c4 <vprintf+0x7a>
    for (i = 0; fmt[i]; i++) {
 7aa:	0485                	addi	s1,s1,1
 7ac:	fff4c903          	lbu	s2,-1(s1)
 7b0:	14090d63          	beqz	s2,90a <vprintf+0x1c0>
        c = fmt[i] & 0xff;
 7b4:	0009079b          	sext.w	a5,s2
        if (state == 0) {
 7b8:	fe0997e3          	bnez	s3,7a6 <vprintf+0x5c>
            if (c == '%') {
 7bc:	fd479ee3          	bne	a5,s4,798 <vprintf+0x4e>
                state = '%';
 7c0:	89be                	mv	s3,a5
 7c2:	b7e5                	j	7aa <vprintf+0x60>
            if (c == 'd') {
 7c4:	05878063          	beq	a5,s8,804 <vprintf+0xba>
            } else if (c == 'l') {
 7c8:	05978c63          	beq	a5,s9,820 <vprintf+0xd6>
            } else if (c == 'x') {
 7cc:	07a78863          	beq	a5,s10,83c <vprintf+0xf2>
            } else if (c == 'p') {
 7d0:	09b78463          	beq	a5,s11,858 <vprintf+0x10e>
                printptr(fd, va_arg(ap, uint64));
            } else if (c == 's') {
 7d4:	07300713          	li	a4,115
 7d8:	0ce78663          	beq	a5,a4,8a4 <vprintf+0x15a>
                    s = "(null)";
                while (*s != 0) {
                    putc(fd, *s);
                    s++;
                }
            } else if (c == 'c') {
 7dc:	06300713          	li	a4,99
 7e0:	0ee78e63          	beq	a5,a4,8dc <vprintf+0x192>
                putc(fd, va_arg(ap, uint));
            } else if (c == '%') {
 7e4:	11478863          	beq	a5,s4,8f4 <vprintf+0x1aa>
                putc(fd, c);
            } else {
                // Unknown % sequence.  Print it to draw attention.
                putc(fd, '%');
 7e8:	85d2                	mv	a1,s4
 7ea:	8556                	mv	a0,s5
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e92080e7          	jalr	-366(ra) # 67e <putc>
                putc(fd, c);
 7f4:	85ca                	mv	a1,s2
 7f6:	8556                	mv	a0,s5
 7f8:	00000097          	auipc	ra,0x0
 7fc:	e86080e7          	jalr	-378(ra) # 67e <putc>
            }
            state = 0;
 800:	4981                	li	s3,0
 802:	b765                	j	7aa <vprintf+0x60>
                printint(fd, va_arg(ap, int), 10, 1);
 804:	008b0913          	addi	s2,s6,8
 808:	4685                	li	a3,1
 80a:	4629                	li	a2,10
 80c:	000b2583          	lw	a1,0(s6)
 810:	8556                	mv	a0,s5
 812:	00000097          	auipc	ra,0x0
 816:	e8e080e7          	jalr	-370(ra) # 6a0 <printint>
 81a:	8b4a                	mv	s6,s2
            state = 0;
 81c:	4981                	li	s3,0
 81e:	b771                	j	7aa <vprintf+0x60>
                printint(fd, va_arg(ap, uint64), 10, 0);
 820:	008b0913          	addi	s2,s6,8
 824:	4681                	li	a3,0
 826:	4629                	li	a2,10
 828:	000b2583          	lw	a1,0(s6)
 82c:	8556                	mv	a0,s5
 82e:	00000097          	auipc	ra,0x0
 832:	e72080e7          	jalr	-398(ra) # 6a0 <printint>
 836:	8b4a                	mv	s6,s2
            state = 0;
 838:	4981                	li	s3,0
 83a:	bf85                	j	7aa <vprintf+0x60>
                printint(fd, va_arg(ap, int), 16, 0);
 83c:	008b0913          	addi	s2,s6,8
 840:	4681                	li	a3,0
 842:	4641                	li	a2,16
 844:	000b2583          	lw	a1,0(s6)
 848:	8556                	mv	a0,s5
 84a:	00000097          	auipc	ra,0x0
 84e:	e56080e7          	jalr	-426(ra) # 6a0 <printint>
 852:	8b4a                	mv	s6,s2
            state = 0;
 854:	4981                	li	s3,0
 856:	bf91                	j	7aa <vprintf+0x60>
                printptr(fd, va_arg(ap, uint64));
 858:	008b0793          	addi	a5,s6,8
 85c:	f8f43423          	sd	a5,-120(s0)
 860:	000b3983          	ld	s3,0(s6)
    putc(fd, '0');
 864:	03000593          	li	a1,48
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	e14080e7          	jalr	-492(ra) # 67e <putc>
    putc(fd, 'x');
 872:	85ea                	mv	a1,s10
 874:	8556                	mv	a0,s5
 876:	00000097          	auipc	ra,0x0
 87a:	e08080e7          	jalr	-504(ra) # 67e <putc>
 87e:	4941                	li	s2,16
        putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 880:	03c9d793          	srli	a5,s3,0x3c
 884:	97de                	add	a5,a5,s7
 886:	0007c583          	lbu	a1,0(a5)
 88a:	8556                	mv	a0,s5
 88c:	00000097          	auipc	ra,0x0
 890:	df2080e7          	jalr	-526(ra) # 67e <putc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 894:	0992                	slli	s3,s3,0x4
 896:	397d                	addiw	s2,s2,-1
 898:	fe0914e3          	bnez	s2,880 <vprintf+0x136>
                printptr(fd, va_arg(ap, uint64));
 89c:	f8843b03          	ld	s6,-120(s0)
            state = 0;
 8a0:	4981                	li	s3,0
 8a2:	b721                	j	7aa <vprintf+0x60>
                s = va_arg(ap, char*);
 8a4:	008b0993          	addi	s3,s6,8
 8a8:	000b3903          	ld	s2,0(s6)
                if (s == 0)
 8ac:	02090163          	beqz	s2,8ce <vprintf+0x184>
                while (*s != 0) {
 8b0:	00094583          	lbu	a1,0(s2)
 8b4:	c9a1                	beqz	a1,904 <vprintf+0x1ba>
                    putc(fd, *s);
 8b6:	8556                	mv	a0,s5
 8b8:	00000097          	auipc	ra,0x0
 8bc:	dc6080e7          	jalr	-570(ra) # 67e <putc>
                    s++;
 8c0:	0905                	addi	s2,s2,1
                while (*s != 0) {
 8c2:	00094583          	lbu	a1,0(s2)
 8c6:	f9e5                	bnez	a1,8b6 <vprintf+0x16c>
                s = va_arg(ap, char*);
 8c8:	8b4e                	mv	s6,s3
            state = 0;
 8ca:	4981                	li	s3,0
 8cc:	bdf9                	j	7aa <vprintf+0x60>
                    s = "(null)";
 8ce:	00000917          	auipc	s2,0x0
 8d2:	2b290913          	addi	s2,s2,690 # b80 <malloc+0x16c>
                while (*s != 0) {
 8d6:	02800593          	li	a1,40
 8da:	bff1                	j	8b6 <vprintf+0x16c>
                putc(fd, va_arg(ap, uint));
 8dc:	008b0913          	addi	s2,s6,8
 8e0:	000b4583          	lbu	a1,0(s6)
 8e4:	8556                	mv	a0,s5
 8e6:	00000097          	auipc	ra,0x0
 8ea:	d98080e7          	jalr	-616(ra) # 67e <putc>
 8ee:	8b4a                	mv	s6,s2
            state = 0;
 8f0:	4981                	li	s3,0
 8f2:	bd65                	j	7aa <vprintf+0x60>
                putc(fd, c);
 8f4:	85d2                	mv	a1,s4
 8f6:	8556                	mv	a0,s5
 8f8:	00000097          	auipc	ra,0x0
 8fc:	d86080e7          	jalr	-634(ra) # 67e <putc>
            state = 0;
 900:	4981                	li	s3,0
 902:	b565                	j	7aa <vprintf+0x60>
                s = va_arg(ap, char*);
 904:	8b4e                	mv	s6,s3
            state = 0;
 906:	4981                	li	s3,0
 908:	b54d                	j	7aa <vprintf+0x60>
        }
    }
}
 90a:	70e6                	ld	ra,120(sp)
 90c:	7446                	ld	s0,112(sp)
 90e:	74a6                	ld	s1,104(sp)
 910:	7906                	ld	s2,96(sp)
 912:	69e6                	ld	s3,88(sp)
 914:	6a46                	ld	s4,80(sp)
 916:	6aa6                	ld	s5,72(sp)
 918:	6b06                	ld	s6,64(sp)
 91a:	7be2                	ld	s7,56(sp)
 91c:	7c42                	ld	s8,48(sp)
 91e:	7ca2                	ld	s9,40(sp)
 920:	7d02                	ld	s10,32(sp)
 922:	6de2                	ld	s11,24(sp)
 924:	6109                	addi	sp,sp,128
 926:	8082                	ret

0000000000000928 <fprintf>:

void fprintf(int fd, const char* fmt, ...)
{
 928:	715d                	addi	sp,sp,-80
 92a:	ec06                	sd	ra,24(sp)
 92c:	e822                	sd	s0,16(sp)
 92e:	1000                	addi	s0,sp,32
 930:	e010                	sd	a2,0(s0)
 932:	e414                	sd	a3,8(s0)
 934:	e818                	sd	a4,16(s0)
 936:	ec1c                	sd	a5,24(s0)
 938:	03043023          	sd	a6,32(s0)
 93c:	03143423          	sd	a7,40(s0)
    va_list ap;

    va_start(ap, fmt);
 940:	fe843423          	sd	s0,-24(s0)
    vprintf(fd, fmt, ap);
 944:	8622                	mv	a2,s0
 946:	00000097          	auipc	ra,0x0
 94a:	e04080e7          	jalr	-508(ra) # 74a <vprintf>
}
 94e:	60e2                	ld	ra,24(sp)
 950:	6442                	ld	s0,16(sp)
 952:	6161                	addi	sp,sp,80
 954:	8082                	ret

0000000000000956 <printf>:

void printf(const char* fmt, ...)
{
 956:	711d                	addi	sp,sp,-96
 958:	ec06                	sd	ra,24(sp)
 95a:	e822                	sd	s0,16(sp)
 95c:	1000                	addi	s0,sp,32
 95e:	e40c                	sd	a1,8(s0)
 960:	e810                	sd	a2,16(s0)
 962:	ec14                	sd	a3,24(s0)
 964:	f018                	sd	a4,32(s0)
 966:	f41c                	sd	a5,40(s0)
 968:	03043823          	sd	a6,48(s0)
 96c:	03143c23          	sd	a7,56(s0)
    va_list ap;

    va_start(ap, fmt);
 970:	00840613          	addi	a2,s0,8
 974:	fec43423          	sd	a2,-24(s0)
    vprintf(1, fmt, ap);
 978:	85aa                	mv	a1,a0
 97a:	4505                	li	a0,1
 97c:	00000097          	auipc	ra,0x0
 980:	dce080e7          	jalr	-562(ra) # 74a <vprintf>
}
 984:	60e2                	ld	ra,24(sp)
 986:	6442                	ld	s0,16(sp)
 988:	6125                	addi	sp,sp,96
 98a:	8082                	ret

000000000000098c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 98c:	1141                	addi	sp,sp,-16
 98e:	e422                	sd	s0,8(sp)
 990:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 992:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 996:	00000797          	auipc	a5,0x0
 99a:	20a7b783          	ld	a5,522(a5) # ba0 <freep>
 99e:	a805                	j	9ce <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a0:	4618                	lw	a4,8(a2)
 9a2:	9db9                	addw	a1,a1,a4
 9a4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a8:	6398                	ld	a4,0(a5)
 9aa:	6318                	ld	a4,0(a4)
 9ac:	fee53823          	sd	a4,-16(a0)
 9b0:	a091                	j	9f4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9b2:	ff852703          	lw	a4,-8(a0)
 9b6:	9e39                	addw	a2,a2,a4
 9b8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9ba:	ff053703          	ld	a4,-16(a0)
 9be:	e398                	sd	a4,0(a5)
 9c0:	a099                	j	a06 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c2:	6398                	ld	a4,0(a5)
 9c4:	00e7e463          	bltu	a5,a4,9cc <free+0x40>
 9c8:	00e6ea63          	bltu	a3,a4,9dc <free+0x50>
{
 9cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ce:	fed7fae3          	bgeu	a5,a3,9c2 <free+0x36>
 9d2:	6398                	ld	a4,0(a5)
 9d4:	00e6e463          	bltu	a3,a4,9dc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9d8:	fee7eae3          	bltu	a5,a4,9cc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9dc:	ff852583          	lw	a1,-8(a0)
 9e0:	6390                	ld	a2,0(a5)
 9e2:	02059713          	slli	a4,a1,0x20
 9e6:	9301                	srli	a4,a4,0x20
 9e8:	0712                	slli	a4,a4,0x4
 9ea:	9736                	add	a4,a4,a3
 9ec:	fae60ae3          	beq	a2,a4,9a0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9f0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9f4:	4790                	lw	a2,8(a5)
 9f6:	02061713          	slli	a4,a2,0x20
 9fa:	9301                	srli	a4,a4,0x20
 9fc:	0712                	slli	a4,a4,0x4
 9fe:	973e                	add	a4,a4,a5
 a00:	fae689e3          	beq	a3,a4,9b2 <free+0x26>
  } else
    p->s.ptr = bp;
 a04:	e394                	sd	a3,0(a5)
  freep = p;
 a06:	00000717          	auipc	a4,0x0
 a0a:	18f73d23          	sd	a5,410(a4) # ba0 <freep>
}
 a0e:	6422                	ld	s0,8(sp)
 a10:	0141                	addi	sp,sp,16
 a12:	8082                	ret

0000000000000a14 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a14:	7139                	addi	sp,sp,-64
 a16:	fc06                	sd	ra,56(sp)
 a18:	f822                	sd	s0,48(sp)
 a1a:	f426                	sd	s1,40(sp)
 a1c:	f04a                	sd	s2,32(sp)
 a1e:	ec4e                	sd	s3,24(sp)
 a20:	e852                	sd	s4,16(sp)
 a22:	e456                	sd	s5,8(sp)
 a24:	e05a                	sd	s6,0(sp)
 a26:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a28:	02051493          	slli	s1,a0,0x20
 a2c:	9081                	srli	s1,s1,0x20
 a2e:	04bd                	addi	s1,s1,15
 a30:	8091                	srli	s1,s1,0x4
 a32:	0014899b          	addiw	s3,s1,1
 a36:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a38:	00000517          	auipc	a0,0x0
 a3c:	16853503          	ld	a0,360(a0) # ba0 <freep>
 a40:	c515                	beqz	a0,a6c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a42:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a44:	4798                	lw	a4,8(a5)
 a46:	02977f63          	bgeu	a4,s1,a84 <malloc+0x70>
 a4a:	8a4e                	mv	s4,s3
 a4c:	0009871b          	sext.w	a4,s3
 a50:	6685                	lui	a3,0x1
 a52:	00d77363          	bgeu	a4,a3,a58 <malloc+0x44>
 a56:	6a05                	lui	s4,0x1
 a58:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a5c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a60:	00000917          	auipc	s2,0x0
 a64:	14090913          	addi	s2,s2,320 # ba0 <freep>
  if(p == (char*)-1)
 a68:	5afd                	li	s5,-1
 a6a:	a88d                	j	adc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a6c:	00000797          	auipc	a5,0x0
 a70:	14c78793          	addi	a5,a5,332 # bb8 <base>
 a74:	00000717          	auipc	a4,0x0
 a78:	12f73623          	sd	a5,300(a4) # ba0 <freep>
 a7c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a7e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a82:	b7e1                	j	a4a <malloc+0x36>
      if(p->s.size == nunits)
 a84:	02e48b63          	beq	s1,a4,aba <malloc+0xa6>
        p->s.size -= nunits;
 a88:	4137073b          	subw	a4,a4,s3
 a8c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a8e:	1702                	slli	a4,a4,0x20
 a90:	9301                	srli	a4,a4,0x20
 a92:	0712                	slli	a4,a4,0x4
 a94:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a96:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a9a:	00000717          	auipc	a4,0x0
 a9e:	10a73323          	sd	a0,262(a4) # ba0 <freep>
      return (void*)(p + 1);
 aa2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 aa6:	70e2                	ld	ra,56(sp)
 aa8:	7442                	ld	s0,48(sp)
 aaa:	74a2                	ld	s1,40(sp)
 aac:	7902                	ld	s2,32(sp)
 aae:	69e2                	ld	s3,24(sp)
 ab0:	6a42                	ld	s4,16(sp)
 ab2:	6aa2                	ld	s5,8(sp)
 ab4:	6b02                	ld	s6,0(sp)
 ab6:	6121                	addi	sp,sp,64
 ab8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 aba:	6398                	ld	a4,0(a5)
 abc:	e118                	sd	a4,0(a0)
 abe:	bff1                	j	a9a <malloc+0x86>
  hp->s.size = nu;
 ac0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ac4:	0541                	addi	a0,a0,16
 ac6:	00000097          	auipc	ra,0x0
 aca:	ec6080e7          	jalr	-314(ra) # 98c <free>
  return freep;
 ace:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ad2:	d971                	beqz	a0,aa6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ad6:	4798                	lw	a4,8(a5)
 ad8:	fa9776e3          	bgeu	a4,s1,a84 <malloc+0x70>
    if(p == freep)
 adc:	00093703          	ld	a4,0(s2)
 ae0:	853e                	mv	a0,a5
 ae2:	fef719e3          	bne	a4,a5,ad4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ae6:	8552                	mv	a0,s4
 ae8:	00000097          	auipc	ra,0x0
 aec:	b7e080e7          	jalr	-1154(ra) # 666 <sbrk>
  if(p == (char*)-1)
 af0:	fd5518e3          	bne	a0,s5,ac0 <malloc+0xac>
        return 0;
 af4:	4501                	li	a0,0
 af6:	bf45                	j	aa6 <malloc+0x92>
