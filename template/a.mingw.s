
a.mingw.elf:     file format elf32-m68k


Disassembly of section .text:

00000000 <_start>:
}

int main();

__attribute__((used)) __attribute__((section(".text.unlikely"))) void _start() {
	main();
   0:	4ef9 0000 0006 	jmp 6 <main>

00000006 <main>:
	hw->intreq=(1<<INTB_VERTB); hw->intreq=(1<<INTB_VERTB); //reset vbl req. twice for a4000 bug.

	bgcolor++;
}

int main() {
   6:	4fef fff4      	lea -12(sp),sp
   a:	48e7 3132      	movem.l d2-d3/d7/a2-a3/a6,-(sp)
	SysBase = *((struct ExecBase**)4UL);
   e:	2c78 0004      	movea.l 4 <_start+0x4>,a6
  12:	23ce 0000 27e0 	move.l a6,27e0 <SysBase>
	hw = (struct Custom*)0xdff000;
  18:	23fc 00df f000 	move.l #14675968,27dc <hw>
  1e:	0000 27dc 

	// We will use the graphics library only to locate and restore the system copper list once we are through.
	GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",0);
  22:	43f9 0000 0774 	lea 774 <KPutCharX+0x56>,a1
  28:	7000           	moveq #0,d0
  2a:	4eae fdd8      	jsr -552(a6)
  2e:	23c0 0000 27d8 	move.l d0,27d8 <GfxBase>
	if (!GfxBase)
  34:	6700 02ca      	beq.w 300 <main+0x2fa>
		Exit(0);

	// used for printing
	DOSBase = (struct DosLibrary*)OpenLibrary("dos.library", 0);
  38:	2c79 0000 27e0 	movea.l 27e0 <SysBase>,a6
  3e:	43f9 0000 0785 	lea 785 <KPutCharX+0x67>,a1
  44:	7000           	moveq #0,d0
  46:	4eae fdd8      	jsr -552(a6)
  4a:	2c40           	movea.l d0,a6
  4c:	23c0 0000 27d4 	move.l d0,27d4 <DOSBase>
	if (!DOSBase)
  52:	6700 029c      	beq.w 2f0 <main+0x2ea>
		Exit(0);

	KPrintF("Hello debugger from Amiga!\n");
  56:	4879 0000 0791 	pea 791 <KPutCharX+0x73>
  5c:	4eb9 0000 041a 	jsr 41a <KPrintF>
	Write(Output(), "Hello console!\n", 15);
  62:	4eae ffc4      	jsr -60(a6)
  66:	2c79 0000 27d4 	movea.l 27d4 <DOSBase>,a6
  6c:	2200           	move.l d0,d1
  6e:	243c 0000 07ad 	move.l #1965,d2
  74:	760f           	moveq #15,d3
  76:	4eae ffd0      	jsr -48(a6)
	Delay(50);
  7a:	2c79 0000 27d4 	movea.l 27d4 <DOSBase>,a6
  80:	7232           	moveq #50,d1
  82:	4eae ff3a      	jsr -198(a6)

void warpmode(int on) 
{ // bool
	long(*UaeConf)(long mode, int index, const char* param, int param_len, char* outbuf, int outbuf_len);
	UaeConf = (void *)0xf0ff60;
	if(*((ULONG *)UaeConf)) {
  86:	247c 00f0 ff60 	movea.l #15794016,a2
  8c:	588f           	addq.l #4,sp
  8e:	4a92           	tst.l (a2)
  90:	6718           	beq.s aa <main+0xa4>
  92:	4878 0001      	pea 1 <_start+0x1>
  96:	47f9 0000 0378 	lea 378 <warpmode.part.0>,a3
  9c:	4e93           	jsr (a3)
  9e:	588f           	addq.l #4,sp
  a0:	4a92           	tst.l (a2)
  a2:	6706           	beq.s aa <main+0xa4>
  a4:	42a7           	clr.l -(sp)
  a6:	4e93           	jsr (a3)
  a8:	588f           	addq.l #4,sp
	ActiView=GfxBase->ActiView; //store current view
  aa:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
  b0:	23ee 0022 0000 	move.l 34(a6),27c0 <_edata>
  b6:	27c0 
	OwnBlitter();
  b8:	4eae fe38      	jsr -456(a6)
	WaitBlit();	
  bc:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
  c2:	4eae ff1c      	jsr -228(a6)
	Disable();
  c6:	2c79 0000 27e0 	movea.l 27e0 <SysBase>,a6
  cc:	4eae ff88      	jsr -120(a6)
	SystemADKCON=hw->adkconr;
  d0:	2479 0000 27dc 	movea.l 27dc <hw>,a2
  d6:	302a 0010      	move.w 16(a2),d0
  da:	33c0 0000 27c4 	move.w d0,27c4 <SystemADKCON>
	SystemInts=hw->intenar;
  e0:	302a 001c      	move.w 28(a2),d0
  e4:	33c0 0000 27c8 	move.w d0,27c8 <SystemInts>
	SystemDMA=hw->dmaconr;
  ea:	302a 0002      	move.w 2(a2),d0
  ee:	33c0 0000 27c6 	move.w d0,27c6 <SystemDMA>
	hw->intena=0x7fff;//disable all interrupts
  f4:	357c 7fff 009a 	move.w #32767,154(a2)
	hw->intreq=0x7fff;//Clear any interrupts that were pending
  fa:	357c 7fff 009c 	move.w #32767,156(a2)
	WaitVbl();
 100:	47f9 0000 0468 	lea 468 <WaitVbl>,a3
 106:	4e93           	jsr (a3)
	WaitVbl();
 108:	4e93           	jsr (a3)
	hw->dmacon=0x7fff;//Clear all DMA channels
 10a:	357c 7fff 0096 	move.w #32767,150(a2)
	for(int a=0;a<32;a++)
 110:	7200           	moveq #0,d1
		hw->color[a]=0;
 112:	2001           	move.l d1,d0
 114:	0680 0000 00c0 	addi.l #192,d0
 11a:	d080           	add.l d0,d0
 11c:	35bc 0000 0800 	move.w #0,(0,a2,d0.l)
	for(int a=0;a<32;a++)
 122:	5281           	addq.l #1,d1
 124:	7020           	moveq #32,d0
 126:	b081           	cmp.l d1,d0
 128:	66e8           	bne.s 112 <main+0x10c>
	LoadView(0);
 12a:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
 130:	93c9           	suba.l a1,a1
 132:	4eae ff22      	jsr -222(a6)
	WaitTOF();
 136:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
 13c:	4eae fef2      	jsr -270(a6)
	WaitTOF();
 140:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
 146:	4eae fef2      	jsr -270(a6)
	WaitVbl();
 14a:	4e93           	jsr (a3)
	WaitVbl();
 14c:	4e93           	jsr (a3)
	UWORD getvbr[] = { 0x4e7a, 0x0801, 0x4e73 }; // MOVEC.L VBR,D0 RTE
 14e:	3f7c 4e7a 001e 	move.w #20090,30(sp)
 154:	3f7c 0801 0020 	move.w #2049,32(sp)
 15a:	3f7c 4e73 0022 	move.w #20083,34(sp)
	if (SysBase->AttnFlags & AFF_68010) 
 160:	2c79 0000 27e0 	movea.l 27e0 <SysBase>,a6
 166:	082e 0000 0129 	btst #0,297(a6)
 16c:	6700 01be      	beq.w 32c <main+0x326>
		vbr = (APTR)Supervisor((void*)getvbr);
 170:	7e1e           	moveq #30,d7
 172:	de8f           	add.l sp,d7
 174:	cf8d           	exg d7,a5
 176:	4eae ffe2      	jsr -30(a6)
 17a:	cf8d           	exg d7,a5
	VBR=GetVBR();
 17c:	23c0 0000 27d0 	move.l d0,27d0 <VBR>
	return *(volatile APTR*)(((UBYTE*)VBR)+0x6c);
 182:	2079 0000 27d0 	movea.l 27d0 <VBR>,a0
 188:	2428 006c      	move.l 108(a0),d2
	SystemIrq=GetInterruptHandler(); //store interrupt register
 18c:	23c2 0000 27ca 	move.l d2,27ca <SystemIrq>
	warpmode(1);
	// TODO: precalc stuff here
	warpmode(0);

	TakeSystem();
	WaitVbl();
 192:	4e93           	jsr (a3)
	*(volatile APTR*)(((UBYTE*)VBR)+0x6c) = interrupt;
 194:	2079 0000 27d0 	movea.l 27d0 <VBR>,a0
 19a:	217c 0000 043e 	move.l #1086,108(a0)
 1a0:	006c 

	// DEMO
	SetInterruptHandler((APTR)interruptHandler);
	hw->intena=(1<<INTB_SETCLR)|(1<<INTB_INTEN)|(1<<INTB_VERTB);
 1a2:	2479 0000 27dc 	movea.l 27dc <hw>,a2
 1a8:	357c c020 009a 	move.w #-16352,154(a2)
	hw->intreq=1<<INTB_VERTB;//reset vbl req
 1ae:	357c 0020 009c 	move.w #32,156(a2)
inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
 1b4:	1039 00bf e001 	move.b bfe001 <gcc8_c_support.c.85bb0846+0xbfa298>,d0

	while(!MouseLeft()) {
 1ba:	0800 0006      	btst #6,d0
 1be:	675a           	beq.s 21a <main+0x214>
		volatile ULONG vpos=*(volatile ULONG*)&hw->vposr;
 1c0:	202a 0004      	move.l 4(a2),d0
 1c4:	2f40 001e      	move.l d0,30(sp)
		vpos&=0x1ff00;
 1c8:	202f 001e      	move.l 30(sp),d0
 1cc:	0280 0001 ff00 	andi.l #130816,d0
 1d2:	2f40 001e      	move.l d0,30(sp)
		if (vpos!=(311<<8))
 1d6:	202f 001e      	move.l 30(sp),d0
 1da:	0c80 0001 3700 	cmpi.l #79616,d0
 1e0:	67de           	beq.s 1c0 <main+0x1ba>
		volatile ULONG vpos=*(volatile ULONG*)&hw->vposr;
 1e2:	202a 0004      	move.l 4(a2),d0
 1e6:	2f40 001a      	move.l d0,26(sp)
		vpos&=0x1ff00;
 1ea:	202f 001a      	move.l 26(sp),d0
 1ee:	0280 0001 ff00 	andi.l #130816,d0
 1f4:	2f40 001a      	move.l d0,26(sp)
		if (vpos==(311<<8))
 1f8:	202f 001a      	move.l 26(sp),d0
 1fc:	0c80 0001 3700 	cmpi.l #79616,d0
 202:	66de           	bne.s 1e2 <main+0x1dc>
		WaitVbl();
		hw->color[0] = bgcolor;
 204:	3039 0000 27ce 	move.w 27ce <bgcolor>,d0
 20a:	3540 0180      	move.w d0,384(a2)
inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
 20e:	1039 00bf e001 	move.b bfe001 <gcc8_c_support.c.85bb0846+0xbfa298>,d0
	while(!MouseLeft()) {
 214:	0800 0006      	btst #6,d0
 218:	66a6           	bne.s 1c0 <main+0x1ba>
	WaitVbl();
 21a:	4e93           	jsr (a3)
	UWORD tst=*(volatile UWORD*)&hw->dmaconr; //for compatiblity a1000
 21c:	302a 0002      	move.w 2(a2),d0
	while (*(volatile UWORD*)&hw->dmaconr&(1<<14)) {} //blitter busy wait
 220:	302a 0002      	move.w 2(a2),d0
 224:	0800 000e      	btst #14,d0
 228:	66f6           	bne.s 220 <main+0x21a>
	hw->intena=0x7fff;//disable all interrupts
 22a:	357c 7fff 009a 	move.w #32767,154(a2)
	hw->intreq=0x7fff;//Clear any interrupts that were pending
 230:	357c 7fff 009c 	move.w #32767,156(a2)
	hw->dmacon=0x7fff;//Clear all DMA channels
 236:	357c 7fff 0096 	move.w #32767,150(a2)
	*(volatile APTR*)(((UBYTE*)VBR)+0x6c) = interrupt;
 23c:	2079 0000 27d0 	movea.l 27d0 <VBR>,a0
 242:	2142 006c      	move.l d2,108(a0)
	hw->cop1lc=(ULONG)GfxBase->copinit;
 246:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
 24c:	256e 0026 0080 	move.l 38(a6),128(a2)
	hw->cop2lc=(ULONG)GfxBase->LOFlist;
 252:	256e 0032 0084 	move.l 50(a6),132(a2)
	hw->copjmp1=0x7fff; //start coppper
 258:	357c 7fff 0088 	move.w #32767,136(a2)
	hw->intena=SystemInts|0x8000;
 25e:	3039 0000 27c8 	move.w 27c8 <SystemInts>,d0
 264:	0040 8000      	ori.w #-32768,d0
 268:	3540 009a      	move.w d0,154(a2)
	hw->dmacon=SystemDMA|0x8000;
 26c:	3039 0000 27c6 	move.w 27c6 <SystemDMA>,d0
 272:	0040 8000      	ori.w #-32768,d0
 276:	3540 0096      	move.w d0,150(a2)
	hw->adkcon=SystemADKCON|0x8000;
 27a:	3039 0000 27c4 	move.w 27c4 <SystemADKCON>,d0
 280:	0040 8000      	ori.w #-32768,d0
 284:	3540 009e      	move.w d0,158(a2)
	LoadView(ActiView);
 288:	2279 0000 27c0 	movea.l 27c0 <_edata>,a1
 28e:	4eae ff22      	jsr -222(a6)
	WaitTOF();
 292:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
 298:	4eae fef2      	jsr -270(a6)
	WaitTOF();
 29c:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
 2a2:	4eae fef2      	jsr -270(a6)
	WaitBlit();	
 2a6:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
 2ac:	4eae ff1c      	jsr -228(a6)
	DisownBlitter();
 2b0:	2c79 0000 27d8 	movea.l 27d8 <GfxBase>,a6
 2b6:	4eae fe32      	jsr -462(a6)
	Enable();
 2ba:	2c79 0000 27e0 	movea.l 27e0 <SysBase>,a6
 2c0:	4eae ff82      	jsr -126(a6)
	}

	// END
	FreeSystem();

	CloseLibrary((struct Library*)DOSBase);
 2c4:	2c79 0000 27e0 	movea.l 27e0 <SysBase>,a6
 2ca:	2279 0000 27d4 	movea.l 27d4 <DOSBase>,a1
 2d0:	4eae fe62      	jsr -414(a6)
	CloseLibrary((struct Library*)GfxBase);
 2d4:	2c79 0000 27e0 	movea.l 27e0 <SysBase>,a6
 2da:	2279 0000 27d8 	movea.l 27d8 <GfxBase>,a1
 2e0:	4eae fe62      	jsr -414(a6)
}
 2e4:	7000           	moveq #0,d0
 2e6:	4cdf 4c8c      	movem.l (sp)+,d2-d3/d7/a2-a3/a6
 2ea:	4fef 000c      	lea 12(sp),sp
 2ee:	4e75           	rts
		Exit(0);
 2f0:	7200           	moveq #0,d1
 2f2:	4eae ff70      	jsr -144(a6)
 2f6:	2c79 0000 27d4 	movea.l 27d4 <DOSBase>,a6
 2fc:	6000 fd58      	bra.w 56 <main+0x50>
		Exit(0);
 300:	2c79 0000 27d4 	movea.l 27d4 <DOSBase>,a6
 306:	7200           	moveq #0,d1
 308:	4eae ff70      	jsr -144(a6)
	DOSBase = (struct DosLibrary*)OpenLibrary("dos.library", 0);
 30c:	2c79 0000 27e0 	movea.l 27e0 <SysBase>,a6
 312:	43f9 0000 0785 	lea 785 <KPutCharX+0x67>,a1
 318:	7000           	moveq #0,d0
 31a:	4eae fdd8      	jsr -552(a6)
 31e:	2c40           	movea.l d0,a6
 320:	23c0 0000 27d4 	move.l d0,27d4 <DOSBase>
	if (!DOSBase)
 326:	6600 fd2e      	bne.w 56 <main+0x50>
 32a:	60c4           	bra.s 2f0 <main+0x2ea>
	APTR vbr = 0;
 32c:	7000           	moveq #0,d0
	VBR=GetVBR();
 32e:	23c0 0000 27d0 	move.l d0,27d0 <VBR>
	return *(volatile APTR*)(((UBYTE*)VBR)+0x6c);
 334:	2079 0000 27d0 	movea.l 27d0 <VBR>,a0
 33a:	2428 006c      	move.l 108(a0),d2
	SystemIrq=GetInterruptHandler(); //store interrupt register
 33e:	23c2 0000 27ca 	move.l d2,27ca <SystemIrq>
	WaitVbl();
 344:	4e93           	jsr (a3)
	*(volatile APTR*)(((UBYTE*)VBR)+0x6c) = interrupt;
 346:	2079 0000 27d0 	movea.l 27d0 <VBR>,a0
 34c:	217c 0000 043e 	move.l #1086,108(a0)
 352:	006c 
	hw->intena=(1<<INTB_SETCLR)|(1<<INTB_INTEN)|(1<<INTB_VERTB);
 354:	2479 0000 27dc 	movea.l 27dc <hw>,a2
 35a:	357c c020 009a 	move.w #-16352,154(a2)
	hw->intreq=1<<INTB_VERTB;//reset vbl req
 360:	357c 0020 009c 	move.w #32,156(a2)
inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
 366:	1039 00bf e001 	move.b bfe001 <gcc8_c_support.c.85bb0846+0xbfa298>,d0
	while(!MouseLeft()) {
 36c:	0800 0006      	btst #6,d0
 370:	6600 fe4e      	bne.w 1c0 <main+0x1ba>
 374:	6000 fea4      	bra.w 21a <main+0x214>

00000378 <warpmode.part.0>:
void warpmode(int on) 
 378:	598f           	subq.l #4,sp
 37a:	2f02           	move.l d2,-(sp)
		char outbuf;
		UaeConf(82, -1, on ? "warp true" : "warp false", 0, &outbuf, 1);
 37c:	4aaf 000c      	tst.l 12(sp)
 380:	674c           	beq.s 3ce <warpmode.part.0+0x56>
 382:	4878 0001      	pea 1 <_start+0x1>
 386:	740b           	moveq #11,d2
 388:	d48f           	add.l sp,d2
 38a:	2f02           	move.l d2,-(sp)
 38c:	42a7           	clr.l -(sp)
 38e:	4879 0000 075f 	pea 75f <KPutCharX+0x41>
 394:	4878 ffff      	pea ffffffff <gcc8_c_support.c.85bb0846+0xffffc296>
 398:	4878 0052      	pea 52 <main+0x4c>
 39c:	4eb9 00f0 ff60 	jsr f0ff60 <gcc8_c_support.c.85bb0846+0xf0c1f7>
 3a2:	4fef 0018      	lea 24(sp),sp
		UaeConf(82, -1, on ? "blitter_cycle_exact false" : "blitter_cycle_exact true", 0, &outbuf, 1);
 3a6:	203c 0000 0745 	move.l #1861,d0
 3ac:	4878 0001      	pea 1 <_start+0x1>
 3b0:	2f02           	move.l d2,-(sp)
 3b2:	42a7           	clr.l -(sp)
 3b4:	2f00           	move.l d0,-(sp)
 3b6:	4878 ffff      	pea ffffffff <gcc8_c_support.c.85bb0846+0xffffc296>
 3ba:	4878 0052      	pea 52 <main+0x4c>
 3be:	4eb9 00f0 ff60 	jsr f0ff60 <gcc8_c_support.c.85bb0846+0xf0c1f7>
	}
}
 3c4:	4fef 0018      	lea 24(sp),sp
 3c8:	241f           	move.l (sp)+,d2
 3ca:	588f           	addq.l #4,sp
 3cc:	4e75           	rts
		UaeConf(82, -1, on ? "warp true" : "warp false", 0, &outbuf, 1);
 3ce:	4878 0001      	pea 1 <_start+0x1>
 3d2:	740b           	moveq #11,d2
 3d4:	d48f           	add.l sp,d2
 3d6:	2f02           	move.l d2,-(sp)
 3d8:	42a7           	clr.l -(sp)
 3da:	4879 0000 0769 	pea 769 <KPutCharX+0x4b>
 3e0:	4878 ffff      	pea ffffffff <gcc8_c_support.c.85bb0846+0xffffc296>
 3e4:	4878 0052      	pea 52 <main+0x4c>
 3e8:	4eb9 00f0 ff60 	jsr f0ff60 <gcc8_c_support.c.85bb0846+0xf0c1f7>
 3ee:	4fef 0018      	lea 24(sp),sp
		UaeConf(82, -1, on ? "blitter_cycle_exact false" : "blitter_cycle_exact true", 0, &outbuf, 1);
 3f2:	203c 0000 072c 	move.l #1836,d0
 3f8:	4878 0001      	pea 1 <_start+0x1>
 3fc:	2f02           	move.l d2,-(sp)
 3fe:	42a7           	clr.l -(sp)
 400:	2f00           	move.l d0,-(sp)
 402:	4878 ffff      	pea ffffffff <gcc8_c_support.c.85bb0846+0xffffc296>
 406:	4878 0052      	pea 52 <main+0x4c>
 40a:	4eb9 00f0 ff60 	jsr f0ff60 <gcc8_c_support.c.85bb0846+0xf0c1f7>
}
 410:	4fef 0018      	lea 24(sp),sp
 414:	241f           	move.l (sp)+,d2
 416:	588f           	addq.l #4,sp
 418:	4e75           	rts

0000041a <KPrintF>:
{
 41a:	48e7 0032      	movem.l a2-a3/a6,-(sp)
	RawDoFmt(fmt, vl, KPutCharX, 0);
 41e:	2c79 0000 27e0 	movea.l 27e0 <SysBase>,a6
 424:	206f 0010      	movea.l 16(sp),a0
 428:	43ef 0014      	lea 20(sp),a1
 42c:	45f9 0000 071e 	lea 71e <KPutCharX>,a2
 432:	97cb           	suba.l a3,a3
 434:	4eae fdf6      	jsr -522(a6)
}
 438:	4cdf 4c00      	movem.l (sp)+,a2-a3/a6
 43c:	4e75           	rts

0000043e <interruptHandler>:
static __attribute__((interrupt)) void interruptHandler() {
 43e:	2f08           	move.l a0,-(sp)
 440:	2f00           	move.l d0,-(sp)
	hw->intreq=(1<<INTB_VERTB); hw->intreq=(1<<INTB_VERTB); //reset vbl req. twice for a4000 bug.
 442:	2079 0000 27dc 	movea.l 27dc <hw>,a0
 448:	317c 0020 009c 	move.w #32,156(a0)
 44e:	317c 0020 009c 	move.w #32,156(a0)
	bgcolor++;
 454:	3039 0000 27ce 	move.w 27ce <bgcolor>,d0
 45a:	5240           	addq.w #1,d0
 45c:	33c0 0000 27ce 	move.w d0,27ce <bgcolor>
}
 462:	201f           	move.l (sp)+,d0
 464:	205f           	movea.l (sp)+,a0
 466:	4e73           	rte

00000468 <WaitVbl>:
void WaitVbl() {
 468:	518f           	subq.l #8,sp
		volatile ULONG vpos=*(volatile ULONG*)&hw->vposr;
 46a:	2079 0000 27dc 	movea.l 27dc <hw>,a0
 470:	2028 0004      	move.l 4(a0),d0
 474:	2e80           	move.l d0,(sp)
		vpos&=0x1ff00;
 476:	2017           	move.l (sp),d0
 478:	0280 0001 ff00 	andi.l #130816,d0
 47e:	2e80           	move.l d0,(sp)
		if (vpos!=(311<<8))
 480:	2017           	move.l (sp),d0
 482:	0c80 0001 3700 	cmpi.l #79616,d0
 488:	67e6           	beq.s 470 <WaitVbl+0x8>
		volatile ULONG vpos=*(volatile ULONG*)&hw->vposr;
 48a:	2028 0004      	move.l 4(a0),d0
 48e:	2f40 0004      	move.l d0,4(sp)
		vpos&=0x1ff00;
 492:	202f 0004      	move.l 4(sp),d0
 496:	0280 0001 ff00 	andi.l #130816,d0
 49c:	2f40 0004      	move.l d0,4(sp)
		if (vpos==(311<<8))
 4a0:	202f 0004      	move.l 4(sp),d0
 4a4:	0c80 0001 3700 	cmpi.l #79616,d0
 4aa:	66de           	bne.s 48a <WaitVbl+0x22>
}
 4ac:	508f           	addq.l #8,sp
 4ae:	4e75           	rts

000004b0 <memcpy>:
{
 4b0:	48e7 3820      	movem.l d2-d4/a2,-(sp)
 4b4:	202f 0014      	move.l 20(sp),d0
 4b8:	226f 0018      	movea.l 24(sp),a1
 4bc:	222f 001c      	move.l 28(sp),d1
	while(len--)
 4c0:	2601           	move.l d1,d3
 4c2:	5383           	subq.l #1,d3
 4c4:	4a81           	tst.l d1
 4c6:	6762           	beq.s 52a <memcpy+0x7a>
 4c8:	2040           	movea.l d0,a0
 4ca:	5888           	addq.l #4,a0
 4cc:	b1c9           	cmpa.l a1,a0
 4ce:	53c2           	sl.s d2
 4d0:	4402           	neg.b d2
 4d2:	41e9 0004      	lea 4(a1),a0
 4d6:	b1c0           	cmpa.l d0,a0
 4d8:	53c4           	sl.s d4
 4da:	4404           	neg.b d4
 4dc:	8404           	or.b d4,d2
 4de:	7808           	moveq #8,d4
 4e0:	b883           	cmp.l d3,d4
 4e2:	55c4           	sc.s d4
 4e4:	4404           	neg.b d4
 4e6:	c404           	and.b d4,d2
 4e8:	6746           	beq.s 530 <memcpy+0x80>
 4ea:	2409           	move.l a1,d2
 4ec:	8480           	or.l d0,d2
 4ee:	7803           	moveq #3,d4
 4f0:	c484           	and.l d4,d2
 4f2:	663c           	bne.s 530 <memcpy+0x80>
 4f4:	2049           	movea.l a1,a0
 4f6:	2440           	movea.l d0,a2
 4f8:	74fc           	moveq #-4,d2
 4fa:	c481           	and.l d1,d2
 4fc:	d489           	add.l a1,d2
		*d++ = *s++;
 4fe:	24d8           	move.l (a0)+,(a2)+
 500:	b488           	cmp.l a0,d2
 502:	66fa           	bne.s 4fe <memcpy+0x4e>
 504:	74fc           	moveq #-4,d2
 506:	c481           	and.l d1,d2
 508:	2040           	movea.l d0,a0
 50a:	d1c2           	adda.l d2,a0
 50c:	d3c2           	adda.l d2,a1
 50e:	9682           	sub.l d2,d3
 510:	b481           	cmp.l d1,d2
 512:	6716           	beq.s 52a <memcpy+0x7a>
 514:	1091           	move.b (a1),(a0)
	while(len--)
 516:	4a83           	tst.l d3
 518:	6710           	beq.s 52a <memcpy+0x7a>
		*d++ = *s++;
 51a:	1169 0001 0001 	move.b 1(a1),1(a0)
	while(len--)
 520:	5383           	subq.l #1,d3
 522:	6706           	beq.s 52a <memcpy+0x7a>
		*d++ = *s++;
 524:	1169 0002 0002 	move.b 2(a1),2(a0)
}
 52a:	4cdf 041c      	movem.l (sp)+,d2-d4/a2
 52e:	4e75           	rts
 530:	2040           	movea.l d0,a0
 532:	d289           	add.l a1,d1
		*d++ = *s++;
 534:	10d9           	move.b (a1)+,(a0)+
	while(len--)
 536:	b289           	cmp.l a1,d1
 538:	67f0           	beq.s 52a <memcpy+0x7a>
		*d++ = *s++;
 53a:	10d9           	move.b (a1)+,(a0)+
	while(len--)
 53c:	b289           	cmp.l a1,d1
 53e:	66f4           	bne.s 534 <memcpy+0x84>
 540:	60e8           	bra.s 52a <memcpy+0x7a>

00000542 <memset>:
{
 542:	48e7 3f30      	movem.l d2-d7/a2-a3,-(sp)
 546:	202f 0024      	move.l 36(sp),d0
 54a:	2a2f 0028      	move.l 40(sp),d5
 54e:	226f 002c      	movea.l 44(sp),a1
	while(len-- > 0)
 552:	2809           	move.l a1,d4
 554:	5384           	subq.l #1,d4
 556:	b2fc 0000      	cmpa.w #0,a1
 55a:	6700 00ae      	beq.w 60a <memset+0xc8>
 55e:	1e05           	move.b d5,d7
 560:	2200           	move.l d0,d1
 562:	4481           	neg.l d1
 564:	7403           	moveq #3,d2
 566:	c282           	and.l d2,d1
 568:	7c05           	moveq #5,d6
		*ptr++ = val;
 56a:	2440           	movea.l d0,a2
 56c:	bc84           	cmp.l d4,d6
 56e:	646a           	bcc.s 5da <memset+0x98>
 570:	4a81           	tst.l d1
 572:	6724           	beq.s 598 <memset+0x56>
 574:	14c5           	move.b d5,(a2)+
	while(len-- > 0)
 576:	5384           	subq.l #1,d4
 578:	7401           	moveq #1,d2
 57a:	b481           	cmp.l d1,d2
 57c:	671a           	beq.s 598 <memset+0x56>
		*ptr++ = val;
 57e:	2440           	movea.l d0,a2
 580:	548a           	addq.l #2,a2
 582:	2040           	movea.l d0,a0
 584:	1145 0001      	move.b d5,1(a0)
	while(len-- > 0)
 588:	5384           	subq.l #1,d4
 58a:	7403           	moveq #3,d2
 58c:	b481           	cmp.l d1,d2
 58e:	6608           	bne.s 598 <memset+0x56>
		*ptr++ = val;
 590:	528a           	addq.l #1,a2
 592:	1145 0002      	move.b d5,2(a0)
	while(len-- > 0)
 596:	5384           	subq.l #1,d4
 598:	2609           	move.l a1,d3
 59a:	9681           	sub.l d1,d3
 59c:	7c00           	moveq #0,d6
 59e:	1c05           	move.b d5,d6
 5a0:	2406           	move.l d6,d2
 5a2:	4842           	swap d2
 5a4:	4242           	clr.w d2
 5a6:	2042           	movea.l d2,a0
 5a8:	2406           	move.l d6,d2
 5aa:	e14a           	lsl.w #8,d2
 5ac:	4842           	swap d2
 5ae:	4242           	clr.w d2
 5b0:	e18e           	lsl.l #8,d6
 5b2:	2646           	movea.l d6,a3
 5b4:	2c08           	move.l a0,d6
 5b6:	8486           	or.l d6,d2
 5b8:	2c0b           	move.l a3,d6
 5ba:	8486           	or.l d6,d2
 5bc:	1407           	move.b d7,d2
 5be:	2040           	movea.l d0,a0
 5c0:	d1c1           	adda.l d1,a0
 5c2:	72fc           	moveq #-4,d1
 5c4:	c283           	and.l d3,d1
 5c6:	d288           	add.l a0,d1
		*ptr++ = val;
 5c8:	20c2           	move.l d2,(a0)+
 5ca:	b1c1           	cmpa.l d1,a0
 5cc:	66fa           	bne.s 5c8 <memset+0x86>
 5ce:	72fc           	moveq #-4,d1
 5d0:	c283           	and.l d3,d1
 5d2:	d5c1           	adda.l d1,a2
 5d4:	9881           	sub.l d1,d4
 5d6:	b283           	cmp.l d3,d1
 5d8:	6730           	beq.s 60a <memset+0xc8>
 5da:	1485           	move.b d5,(a2)
	while(len-- > 0)
 5dc:	4a84           	tst.l d4
 5de:	672a           	beq.s 60a <memset+0xc8>
		*ptr++ = val;
 5e0:	1545 0001      	move.b d5,1(a2)
	while(len-- > 0)
 5e4:	7201           	moveq #1,d1
 5e6:	b284           	cmp.l d4,d1
 5e8:	6720           	beq.s 60a <memset+0xc8>
		*ptr++ = val;
 5ea:	1545 0002      	move.b d5,2(a2)
	while(len-- > 0)
 5ee:	7402           	moveq #2,d2
 5f0:	b484           	cmp.l d4,d2
 5f2:	6716           	beq.s 60a <memset+0xc8>
		*ptr++ = val;
 5f4:	1545 0003      	move.b d5,3(a2)
	while(len-- > 0)
 5f8:	7c03           	moveq #3,d6
 5fa:	bc84           	cmp.l d4,d6
 5fc:	670c           	beq.s 60a <memset+0xc8>
		*ptr++ = val;
 5fe:	1545 0004      	move.b d5,4(a2)
	while(len-- > 0)
 602:	5984           	subq.l #4,d4
 604:	6704           	beq.s 60a <memset+0xc8>
		*ptr++ = val;
 606:	1545 0005      	move.b d5,5(a2)
}
 60a:	4cdf 0cfc      	movem.l (sp)+,d2-d7/a2-a3
 60e:	4e75           	rts

00000610 <strlen>:
{
 610:	206f 0004      	movea.l 4(sp),a0
	unsigned long t=0;
 614:	7000           	moveq #0,d0
	while(*s++)
 616:	4a10           	tst.b (a0)
 618:	6708           	beq.s 622 <strlen+0x12>
		t++;
 61a:	5280           	addq.l #1,d0
	while(*s++)
 61c:	4a30 0800      	tst.b (0,a0,d0.l)
 620:	66f8           	bne.s 61a <strlen+0xa>
}
 622:	4e75           	rts

00000624 <__mulsi3>:
 
	.text
	FUNC(__mulsi3)
	.globl	SYM (__mulsi3)
SYM (__mulsi3):
	movew	sp@(4), d0	/* x0 -> d0 */
 624:	302f 0004      	move.w 4(sp),d0
	muluw	sp@(10), d0	/* x0*y1 */
 628:	c0ef 000a      	mulu.w 10(sp),d0
	movew	sp@(6), d1	/* x1 -> d1 */
 62c:	322f 0006      	move.w 6(sp),d1
	muluw	sp@(8), d1	/* x1*y0 */
 630:	c2ef 0008      	mulu.w 8(sp),d1
	addw	d1, d0
 634:	d041           	add.w d1,d0
	swap	d0
 636:	4840           	swap d0
	clrw	d0
 638:	4240           	clr.w d0
	movew	sp@(6), d1	/* x1 -> d1 */
 63a:	322f 0006      	move.w 6(sp),d1
	muluw	sp@(10), d1	/* x1*y1 */
 63e:	c2ef 000a      	mulu.w 10(sp),d1
	addl	d1, d0
 642:	d081           	add.l d1,d0

	rts
 644:	4e75           	rts

00000646 <__udivsi3>:

	.text
	FUNC(__udivsi3)
	.globl	SYM (__udivsi3)
SYM (__udivsi3):
	movel	d2, sp@-
 646:	2f02           	move.l d2,-(sp)
	movel	sp@(12), d1	/* d1 = divisor */
 648:	222f 000c      	move.l 12(sp),d1
	movel	sp@(8), d0	/* d0 = dividend */
 64c:	202f 0008      	move.l 8(sp),d0

	cmpl	IMM (0x10000), d1 /* divisor >= 2 ^ 16 ?   */
 650:	0c81 0001 0000 	cmpi.l #65536,d1
	jcc	3f		/* then try next algorithm */
 656:	6416           	bcc.s 66e <__udivsi3+0x28>
	movel	d0, d2
 658:	2400           	move.l d0,d2
	clrw	d2
 65a:	4242           	clr.w d2
	swap	d2
 65c:	4842           	swap d2
	divu	d1, d2          /* high quotient in lower word */
 65e:	84c1           	divu.w d1,d2
	movew	d2, d0		/* save high quotient */
 660:	3002           	move.w d2,d0
	swap	d0
 662:	4840           	swap d0
	movew	sp@(10), d2	/* get low dividend + high rest */
 664:	342f 000a      	move.w 10(sp),d2
	divu	d1, d2		/* low quotient */
 668:	84c1           	divu.w d1,d2
	movew	d2, d0
 66a:	3002           	move.w d2,d0
	jra	6f
 66c:	6030           	bra.s 69e <__udivsi3+0x58>

3:	movel	d1, d2		/* use d2 as divisor backup */
 66e:	2401           	move.l d1,d2
4:	lsrl	IMM (1), d1	/* shift divisor */
 670:	e289           	lsr.l #1,d1
	lsrl	IMM (1), d0	/* shift dividend */
 672:	e288           	lsr.l #1,d0
	cmpl	IMM (0x10000), d1 /* still divisor >= 2 ^ 16 ?  */
 674:	0c81 0001 0000 	cmpi.l #65536,d1
	jcc	4b
 67a:	64f4           	bcc.s 670 <__udivsi3+0x2a>
	divu	d1, d0		/* now we have 16-bit divisor */
 67c:	80c1           	divu.w d1,d0
	andl	IMM (0xffff), d0 /* mask out divisor, ignore remainder */
 67e:	0280 0000 ffff 	andi.l #65535,d0

/* Multiply the 16-bit tentative quotient with the 32-bit divisor.  Because of
   the operand ranges, this might give a 33-bit product.  If this product is
   greater than the dividend, the tentative quotient was too large. */
	movel	d2, d1
 684:	2202           	move.l d2,d1
	mulu	d0, d1		/* low part, 32 bits */
 686:	c2c0           	mulu.w d0,d1
	swap	d2
 688:	4842           	swap d2
	mulu	d0, d2		/* high part, at most 17 bits */
 68a:	c4c0           	mulu.w d0,d2
	swap	d2		/* align high part with low part */
 68c:	4842           	swap d2
	tstw	d2		/* high part 17 bits? */
 68e:	4a42           	tst.w d2
	jne	5f		/* if 17 bits, quotient was too large */
 690:	660a           	bne.s 69c <__udivsi3+0x56>
	addl	d2, d1		/* add parts */
 692:	d282           	add.l d2,d1
	jcs	5f		/* if sum is 33 bits, quotient was too large */
 694:	6506           	bcs.s 69c <__udivsi3+0x56>
	cmpl	sp@(8), d1	/* compare the sum with the dividend */
 696:	b2af 0008      	cmp.l 8(sp),d1
	jls	6f		/* if sum > dividend, quotient was too large */
 69a:	6302           	bls.s 69e <__udivsi3+0x58>
5:	subql	IMM (1), d0	/* adjust quotient */
 69c:	5380           	subq.l #1,d0

6:	movel	sp@+, d2
 69e:	241f           	move.l (sp)+,d2
	rts
 6a0:	4e75           	rts

000006a2 <__divsi3>:

	.text
	FUNC(__divsi3)
	.globl	SYM (__divsi3)
SYM (__divsi3):
	movel	d2, sp@-
 6a2:	2f02           	move.l d2,-(sp)

	moveq	IMM (1), d2	/* sign of result stored in d2 (=1 or =-1) */
 6a4:	7401           	moveq #1,d2
	movel	sp@(12), d1	/* d1 = divisor */
 6a6:	222f 000c      	move.l 12(sp),d1
	jpl	1f
 6aa:	6a04           	bpl.s 6b0 <__divsi3+0xe>
	negl	d1
 6ac:	4481           	neg.l d1
	negb	d2		/* change sign because divisor <0  */
 6ae:	4402           	neg.b d2
1:	movel	sp@(8), d0	/* d0 = dividend */
 6b0:	202f 0008      	move.l 8(sp),d0
	jpl	2f
 6b4:	6a04           	bpl.s 6ba <__divsi3+0x18>
	negl	d0
 6b6:	4480           	neg.l d0
	negb	d2
 6b8:	4402           	neg.b d2

2:	movel	d1, sp@-
 6ba:	2f01           	move.l d1,-(sp)
	movel	d0, sp@-
 6bc:	2f00           	move.l d0,-(sp)
	PICCALL	SYM (__udivsi3)	/* divide abs(dividend) by abs(divisor) */
 6be:	6186           	bsr.s 646 <__udivsi3>
	addql	IMM (8), sp
 6c0:	508f           	addq.l #8,sp

	tstb	d2
 6c2:	4a02           	tst.b d2
	jpl	3f
 6c4:	6a02           	bpl.s 6c8 <__divsi3+0x26>
	negl	d0
 6c6:	4480           	neg.l d0

3:	movel	sp@+, d2
 6c8:	241f           	move.l (sp)+,d2
	rts
 6ca:	4e75           	rts

000006cc <__modsi3>:

	.text
	FUNC(__modsi3)
	.globl	SYM (__modsi3)
SYM (__modsi3):
	movel	sp@(8), d1	/* d1 = divisor */
 6cc:	222f 0008      	move.l 8(sp),d1
	movel	sp@(4), d0	/* d0 = dividend */
 6d0:	202f 0004      	move.l 4(sp),d0
	movel	d1, sp@-
 6d4:	2f01           	move.l d1,-(sp)
	movel	d0, sp@-
 6d6:	2f00           	move.l d0,-(sp)
	PICCALL	SYM (__divsi3)
 6d8:	61c8           	bsr.s 6a2 <__divsi3>
	addql	IMM (8), sp
 6da:	508f           	addq.l #8,sp
	movel	sp@(8), d1	/* d1 = divisor */
 6dc:	222f 0008      	move.l 8(sp),d1
	movel	d1, sp@-
 6e0:	2f01           	move.l d1,-(sp)
	movel	d0, sp@-
 6e2:	2f00           	move.l d0,-(sp)
	PICCALL	SYM (__mulsi3)	/* d0 = (a/b)*b */
 6e4:	6100 ff3e      	bsr.w 624 <__mulsi3>
	addql	IMM (8), sp
 6e8:	508f           	addq.l #8,sp
	movel	sp@(4), d1	/* d1 = dividend */
 6ea:	222f 0004      	move.l 4(sp),d1
	subl	d0, d1		/* d1 = a - (a/b)*b */
 6ee:	9280           	sub.l d0,d1
	movel	d1, d0
 6f0:	2001           	move.l d1,d0
	rts
 6f2:	4e75           	rts

000006f4 <__umodsi3>:

	.text
	FUNC(__umodsi3)
	.globl	SYM (__umodsi3)
SYM (__umodsi3):
	movel	sp@(8), d1	/* d1 = divisor */
 6f4:	222f 0008      	move.l 8(sp),d1
	movel	sp@(4), d0	/* d0 = dividend */
 6f8:	202f 0004      	move.l 4(sp),d0
	movel	d1, sp@-
 6fc:	2f01           	move.l d1,-(sp)
	movel	d0, sp@-
 6fe:	2f00           	move.l d0,-(sp)
	PICCALL	SYM (__udivsi3)
 700:	6100 ff44      	bsr.w 646 <__udivsi3>
	addql	IMM (8), sp
 704:	508f           	addq.l #8,sp
	movel	sp@(8), d1	/* d1 = divisor */
 706:	222f 0008      	move.l 8(sp),d1
	movel	d1, sp@-
 70a:	2f01           	move.l d1,-(sp)
	movel	d0, sp@-
 70c:	2f00           	move.l d0,-(sp)
	PICCALL	SYM (__mulsi3)	/* d0 = (a/b)*b */
 70e:	6100 ff14      	bsr.w 624 <__mulsi3>
	addql	IMM (8), sp
 712:	508f           	addq.l #8,sp
	movel	sp@(4), d1	/* d1 = dividend */
 714:	222f 0004      	move.l 4(sp),d1
	subl	d0, d1		/* d1 = a - (a/b)*b */
 718:	9280           	sub.l d0,d1
	movel	d1, d0
 71a:	2001           	move.l d1,d0
	rts
 71c:	4e75           	rts

0000071e <KPutCharX>:
	.text
	FUNC(KPutCharX)
	.globl	SYM (KPutCharX)

SYM(KPutCharX):
    move.l  a6, -(sp)
 71e:	2f0e           	move.l a6,-(sp)
    move.l  4.w, a6
 720:	2c78 0004      	movea.l 4 <_start+0x4>,a6
    jsr     -0x204(a6)
 724:	4eae fdfc      	jsr -516(a6)
    movea.l (sp)+, a6
 728:	2c5f           	movea.l (sp)+,a6
    rts
 72a:	4e75           	rts