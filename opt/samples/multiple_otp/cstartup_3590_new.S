


	.code	16
@********************************************************************************************************
@                                           MACROS AND DEFINIITIONS
@********************************************************************************************************

					@ Mode, correspords to bits 0-5 in CPSR
	.equ MODE_BITS,		0x1F	@ Bit mask for mode bits in CPSR
	.equ IRQ_MODE, 		0x12	@ Interrupt Request mode
	.equ SVC_MODE, 		0x13	@ Supervisor mode

	.equ IRQ_STK_SIZE,	0x100
	
@********************************************************************************************************
@                                            TC32 EXCEPTION VECTORS
@********************************************************************************************************

	.section	.vectors,"ax"
	.global		__reset
	.global	 	__irq
	.global 	__start

__start:					@ MUST,  referenced by boot.link

	.extern irq_handler

	.org 0x0
	tj	__reset
	.org 0x8
	.word	(0x544c4e4b)
	.word	(0x00880100)

	.org 0x10
	tj		__irq
	.org 0x18
@********************************************************************************************************
@                                   LOW-LEVEL INITIALIZATION
@********************************************************************************************************
	.extern  main
@	.extern rotp  /*read data/code from otp----disable for optimize*/

	.org 0x20
__reset:
	


@	tloadr	r0, FLL_D
@	tloadr	r1, FLL_D+4
@	tloadr	r2, FLL_D+8
	
@FLL_STK:
@	tcmp	r1, r2
@	tjge	FLL_STK_END
@	tstorer r0, [r1, #0]
@	tadd    r1, #4
@	tj		FLL_STK
@FLL_STK_END:



	tloadr	r0, DAT0
	tmcsr	r0			
	tloadr	r0, DAT0 + 8
	tmov	r13, r0  

	tloadr	r0, DAT0 + 4
	tmcsr	r0	
	tloadr	r0, DAT0 + 12
	tmov	r13, r0  




@	tloadr	r1, DAT0 + 28
@	tloadr	r2, DAT0 + 32
@
@ZERO_TAG:
@	tcmp	r1, r2
@	tjge	ZERO_TAG_END
@	tstorer	r0, [r1, #0]
@	tadd    r1, #4
@	tj		ZERO_TAG
@ZERO_TAG_END:
	
SETIC:
	tloadr     r1, DAT0 + 24
	tmov	r0, #64;           /* LDW modify */
	tstorerb	r0, [r1, #0]
	tmov	r0, #64;		   /* LDW modify */
	tstorerb	r0, [r1, #1]
	@tmov		r0, #0;
	@tstorerb	r0, [r1, #2]


@	tjl	rotp       /* LDW add--- disable for optimize*/
	tjl ROTP


	tmov	r0, #0
	tloadr	r1, DAT0 + 16
	tloadr	r2, DAT0 + 20

ZERO:
	tcmp	r1, r2
	tjge	ZERO_END
	tstorer	r0, [r1, #0]
	tadd    r1, #4
	tj		ZERO
ZERO_END:



	tloadr		r1, DATA_I
	tloadr		r2, DATA_I+4
	tloadr		r3, DATA_I+8

COPY_DATA:
	tcmp		r2, r3
	tjge		COPY_DATA_END
	tloadr		r0, [r1, #0]
	tstorer 	r0, [r2, #0]
	tadd    	r1, #4
	tadd		r2, #4
	tj			COPY_DATA
COPY_DATA_END:

@	tjl	rotp    /*LDW added*/
	tjl	main
END:	tj	END

	.balign	4
DAT0:
	.word	0x12			    @IRQ    @0
	.word	0x13			    @SVC    @4
	.word	(irq_stk + IRQ_STK_SIZE)
	.word	(0x80c000)		    @12  stack end   /* LDW modify */
	.word	(_start_bss_)               @16
	.word	(_end_bss_)                 @20
	.word   (0x80060c)                  @24
	.word   (0x808500)                  @28
	.word   (0x808600)                  @32
DATA_I:
	.word	_dstored_            /* LDW data store position */
	.word	_start_data_
	.word	_end_data_

FLL_D:
	.word	0xffffffff
	.word	(_start_data_)
	.word	(0x80be00)                            /* LDW modify */


	.align 4
__irq:
	tpush    	{r14}
	tpush    	{r0, r1, r2, r3}
	tmrss    	r0
	tpush    	{r0}

	tpush		{r4, r5, r6, r7}
	tmov		r7, r9
	tmov		r6, r10
	tmov		r5, r11
	tmov		r4, r12
	tpush		{r4, r5, r6, r7}

	@ tmov		r0, ip
	@ tpush   	{r0}

	tjl      	irq_handler

	tpop		{r4, r5, r6, r7}
	tmov		r9,r7
	tmov		r10,r6
	tmov		r11,r5
	tmov		r12,r4

	@tpop     	{r0}
	@tmov		ip, r0
	tpop		{r4, r5, r6, r7}
	tpop     	{r0}
	tmssr    	r0
	tpop     	{r0, r1, r2, r3}
	treti    	{r15}

	.org 256
@@@@@add by QS and i use the Os level and then make use O2
ROTP:
tpush	{r4, r5, r6, r7, lr}
	tloadr	r3, .L51
	tmov	r2, #196
	tstorerb	r2, [r3]
	tloadr	r3, .L51+4
	tmov	r2, #1
	tstorer	r2, [r3]
	tloadr	r0, .L51+8
	tmov	r3, #1
	tneg	r3, r3
	tstorerh	r3, [r0]
	tadd	r1, r3, #0
	tloadr	r3, .L51+12
	tstorerb	r1, [r3]
	tsub	r3, r3, #89
	tstorerb	r2, [r3]
	tloadr	r3, .L51+16
	tloadr	r2, [r3]
	tsub	sp, sp, #12
.L3:
	tloadr	r1, [r3]
	tsub	r1, r1, r2
	tcmp	r1, #47
	tjls	.L3
	tloadr	r3, .L51+20
	tmov	r2, #0
	tstorerb	r2, [r3]
	tloadr	r2, .L51+24
	tmov	r1, #3
	tstorerb	r1, [r2]
	tmov	r1, r3
	tmov	r3, #16
.L4:
	tloadrb	r2, [r1]
	tand	r2, r3
	tjne	.L4
	tloadr	r3, .L51+24
	tloadr	r1, .L51+20
	tstorerb	r2, [r3]
	tmov	r3, #16
.L5:
	tloadrb	r2, [r1]
	tand	r2, r3
	tjne	.L5
	tloadr	r3, .L51+24
	tloadr	r1, .L51+20
	tstorerb	r2, [r3]
	tmov	r3, #16
.L6:
	tloadrb	r2, [r1]
	tand	r2, r3
	tjne	.L6
	tloadr	r3, .L51+24
	tloadr	r1, .L51+20
	tstorerb	r2, [r3]
	tmov	r3, #16
.L7:
	tloadrb	r2, [r1]
	tand	r2, r3
	tjne	.L7
	tloadr	r3, .L51+24
	tloadr	r1, .L51+20
	tstorerb	r2, [r3]
	tmov	r2, #16
.L8:
	tloadrb	r0, [r1]
	tloadr	r3, .L51+20
	tnand	r2, r0
	tjne	.L8
	tmov	r2, #10
	tstorerb	r2, [r3]
	tmov	r2, #16
.L9:
	tloadrb	r1, [r3]
	tnand	r2, r1
	tjne	.L9
	tloadr	r3, .L51+24
	tloadr	r1, .L51+20
	tloadrb	r2, [r3]
	tmov	r3, #16
.L10:
	tloadrb	r0, [r1]
	tnand	r3, r0
	tjne	.L10
	tloadr	r3, .L51+24
	tloadr	r0, .L51+20
	tloadrb	r1, [r3]
	tmov	r3, #16
.L11:
	tloadrb	r4, [r0]
	tnand	r3, r4
	tjne	.L11
	tmov	r3, #128
	tshftl	r3, r3, #16
	tstorerb	r2, [r3]
	tloadr	r3, .L51+28
	tstorerb	r1, [r3]
	tcmp	r1, #255
	tjeq	.L12
	tcmp	r2, #255
	tjeq	.L12
	tloadr	r3, .L51+32
	tloadr	r4, .L51+24
	tloadr	r0, .L51+20
	tloadr	r2, .L51+36
	tmov	r1, #16
.L14:
	tloadrb	r5, [r4]
	tstorerb	r5, [r3]
	tadd	r3, r3, #1
.L13:
	tloadrb	r5, [r0]
	tnand	r1, r5
	tjne	.L13
	tcmp	r3, r2
	tjne	.L14
	tj	.L2
.L12:
	tloadr	r3, .L51+40
	tmov	r2, #126
	tstorerb	r2, [r3]
	tloadr	r2, .L51+44
	tmov	r3, #255
	tshftl	r3, r3, #24
	tstorer	r3, [r2]
	tmov	r3, #1
	tneg	r3, r3
	tadd	r2, r2, #4
	tstorerh	r3, [r2]
	tloadr	r3, .L51+4
	tmov	r2, #1
	tstorerb	r2, [r3]
	tloadr	r2, .L51+48
	tloadr	r3, .L51+52
	tloadr	r0, [r2]
	tloadr	r1, .L51+56
.L17:
	tloadr	r4, [r2]
	tsub	r4, r4, r0
	tcmp	r4, r1
	tjhi	.L16
	tsub	r3, r3, #1
	tcmp	r3, #0
	tjne	.L17
.L16:
	tloadr	r3, .L51+60
	tmov	r2, #128
	tstorerb	r2, [r3]
	tloadr	r2, .L51+48
	tloadr	r3, .L51+52
	tloadr	r0, [r2]
	tloadr	r1, .L51+64
.L19:
	tloadr	r4, [r2]
	tsub	r4, r4, r0
	tcmp	r4, r1
	tjhi	.L18
	tsub	r3, r3, #1
	tcmp	r3, #0
	tjne	.L19
.L18:
	tloadr	r3, .L51+68
	tmov	r2, #216
	tstorerb	r2, [r3]
	tloadr	r2, .L51+48
	tloadr	r3, .L51+52
	tloadr	r0, [r2]
	tloadr	r1, .L51+64
.L21:
	tloadr	r4, [r2]
	tsub	r4, r4, r0
	tcmp	r4, r1
	tjhi	.L20
	tsub	r3, r3, #1
	tcmp	r3, #0
	tjne	.L21
.L20:
	tloadr	r3, .L51+72
	tmov	r2, #68
	tstorerb	r2, [r3]
	tloadr	r2, .L51+48
	tloadr	r3, .L51+52
	tloadr	r0, [r2]
	tloadr	r1, .L51+64
.L23:
	tloadr	r4, [r2]
	tsub	r4, r4, r0
	tcmp	r4, r1
	tjhi	.L29
	tsub	r3, r3, #1
	tcmp	r3, #0
	tjne	.L23
.L29:
	tmov	r1, #192
	tloadr	r0, .L51+76
	tshftl	r1, r1, #8
	tj	.L49
.L30:
	tmov	r0, r2
.L49:
	tshftl	r3, r1, #16
	tshftr	r3, r3, #16
	tstorer	r3, [sp]
	tloadr	r2, .L51+80
	tloadr	r3, .L51+84
	tmov	r4, #0
	tstorerh	r0, [r2]
	tloadr	r7, .L51+88
	tstorerb	r4, [r3]
	tmov	r2, sp
	tloadrb	r4, [r7]
	tadd	r2, r2, #11
	tstorerb	r4, [r2]
	tmov	r5, #128
	tshftl	r5, r5, #16
	tloadrb	r4, [r5]
	tstorerb	r4, [r2]
	tloadr	r4, .L51+92
	tloadrb	r6, [r4]
	tstorerb	r6, [r2]
	tloadrb	r6, [r4]
	tstorerb	r6, [r2]
	tloadrb	r6, [r2]
	tstorer	r6, [sp, #4]
	tadd	r6, r0, #1
	tloadr	r3, .L51+80
	tshftl	r6, r6, #16
	tshftr	r6, r6, #16
	tstorerh	r6, [r3]
	tmov	r6, #0
	tadd	r3, r3, #10
	tstorerb	r6, [r3]
	tloadrb	r7, [r7]
	tstorerb	r7, [r2]
	tloadrb	r5, [r5]
	tstorerb	r5, [r2]
	tloadrb	r5, [r4]
	tstorerb	r5, [r2]
	tloadrb	r4, [r4]
	tstorerb	r4, [r2]
	tloadrb	r2, [r2]
	tcmp	r2, #255
	tjeq	.L31
	tloadr	r2, [sp, #4]
	tcmp	r2, #255
	tjne	.L50
.L31:
	tloadr	r3, .L51+96
	tadd	r2, r0, r3
	tshftl	r2, r2, #16
	tadd	r1, r1, r3
	tshftr	r2, r2, #16
	tcmp	r1, r3
	tjne	.L30
	tmov	r3, r0
	tj	.L24
.L50:
	tloadr	r3, [sp]
.L24:
	tloadr	r4, .L51+100
	tadd	r2, r3, r4
	tcmp	r2, #0
	tjeq	.L26
	tloadr	r5, .L51+104
	tadd	r2, r3, r5
	tcmp	r2, #0
	tjeq	.L26
	tcmp	r3, #0
	tjeq	.L26
	tloadr	r6, .L51+96
	tadd	r2, r3, r6
	tcmp	r2, #0
	tjeq	.L26
	tmov	r3, #128
	tshftl	r3, r3, #8
.L26:
	tsub	r0, r3, #4
	tshftl	r0, r0, #16
	tmov	r2, sp
	tloadr	r1, .L51+108
	tloadr	r7, .L51+80
	tloadr	r6, .L51+84
	tshftr	r0, r0, #16
	tadd	r2, r2, #11
.L27:
	tmov	r4, #0
	tstorerh	r0, [r7]
	tloadr	r5, .L51+88
	tstorerb	r4, [r6]
	tloadrb	r4, [r5]
	tstorerb	r4, [r2]
	tmov	r4, #128
	tshftl	r4, r4, #16
	tloadrb	r4, [r4]
	tstorerb	r4, [r2]
	tloadr	r4, .L51+92
	tloadrb	r5, [r4]
	tstorerb	r5, [r2]
	tloadrb	r4, [r4]
	tstorerb	r4, [r2]
	tloadrb	r4, [r2]
	tadd	r0, r0, #1
	tstorerb	r4, [r1]
	tloadr	r4, .L51+112
	tshftl	r0, r0, #16
	tadd	r1, r1, #1
	tshftr	r0, r0, #16
	tcmp	r1, r4
	tjne	.L27
	tloadr	r6, .L51+116
	tadd	r3, r3, r6
	tshftl	r3, r3, #16
	tmov	r2, sp
	tloadr	r1, .L51+120
	tloadr	r7, .L51+80
	tloadr	r6, .L51+84
	tshftr	r3, r3, #16
	tmov	r5, #0
	tadd	r2, r2, #11
.L28:
	tstorerh	r3, [r7]
	tloadr	r4, .L51+88
	tstorerb	r5, [r6]
	tloadrb	r0, [r4]
	tstorerb	r0, [r2]
	tmov	r0, #128
	tshftl	r0, r0, #16
	tloadrb	r0, [r0]
	tstorerb	r0, [r2]
	tloadr	r0, .L51+92
	tloadrb	r4, [r0]
	tstorerb	r4, [r2]
	tloadrb	r0, [r0]
	tstorerb	r0, [r2]
	tloadrb	r0, [r2]
	tadd	r3, r3, #1
	tstorerb	r0, [r1]
	tloadr	r0, .L51+36
	tshftl	r3, r3, #16
	tadd	r1, r1, #1
	tshftr	r3, r3, #16
	tcmp	r1, r0
	tjne	.L28
.L2:
	tadd	sp, sp, #12
	@ sp needed for prologue
	tpop	{r4, r5, r6, r7, pc}
.L52:
	.align	2
.L51:
	.word	8388712
	.word	8390176
	.word	8388708
	.word	8388710
	.word	8390192
	.word	8388621
	.word	8388620
	.word	8388609
	.word	8421378
	.word	8432640
	.word	8388626
	.word	8388704
	.word	9438768
	.word	1000000
	.word	42000
	.word	8388713
	.word	12600
	.word	8389662
	.word	8389692
	.word	49148
	.word	8388624
	.word	8388634
	.word	8388627
	.word	8388633
	.word	-16384
	.word	-32768
	.word	-49152
	.word	8421376
	.word	8421632
	.word	1276
	.word	8422656
ASMEND:

	.section .bss
	.align 4
	.lcomm irq_stk, IRQ_STK_SIZE
	.end

