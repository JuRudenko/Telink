	.code	16
@********************************************************************************************************
@                                           MACROS AND DEFINIITIONS
@********************************************************************************************************

                            @Mode, correspords to bits 0-5 in CPSR
	.equ MODE_BITS,		0x1F	@ Bit mask for mode bits in CPSR
	.equ IRQ_MODE, 		0x12	@ Interrupt Request mode
	.equ SVC_MODE, 		0x13	@ Supervisor mode

#ifdef SSS
	.equ SVC_STK_SIZE,	SSS
#else
	.equ SVC_STK_SIZE,	0x300
#endif
#ifdef ISS
	.equ IRQ_STK_SIZE,	ISS
#else
	.equ IRQ_STK_SIZE,	0x100
#endif
	
@********************************************************************************************************
@                                            TC32 EXCEPTION VECTORS
@********************************************************************************************************

	.section .vectors,"ax"
	.global __reset
	.global __irq

	.extern lwr_irq_hdlr

	.org 0x0
	tj	__reset
	.org 0x7
	.byte(0x54)
	.short(1024)
	.byte(0x88)

	.org 0x10
	tj	__irq
	
@********************************************************************************************************
@                                   LOW-LEVEL INITIALIZATION
@********************************************************************************************************
	.extern  ?main

	.balign 4
__reset:

	tloadr	r0, FLL_D
	tloadr	r1, FLL_D+4
	tloadr	r2, FLL_D+8
	
FLL_STK:
	tstorer   r0, [r1, #0]
	tadd     r1, #4
	tcmp	r1, r2
	tjle	FLL_STK

	tloadr	r0, DAT0
	tmcsr	r0			
	tloadr	r0, DAT0 + 8
	tmov	r13, r0  

	tloadr	r0, DAT0 + 4
	tmcsr	r0	
	tloadr	r0, DAT0 + 12
	tmov	r13, r0  

	tmov	r0, #0
	tloadr	r1, DAT0 + 16
	tloadr	r2, DAT0 + 20

ZERO:
	tstorer	r0, [r1, #0]
	tadd     r1, #4
	tcmp	r1, r2
	tjle	ZERO

	tloadr	r1, DAT0 + 28
	tloadr	r2, DAT0 + 32

ZERO_TAG:
	tstorer	r0, [r1, #0]
	tadd     r1, #4
	tcmp	r1, r2
	tjle	ZERO_TAG

SETIC:
	tloadr     r1, DAT0 + 24
	tmov	r0, #3;
	tstorerb	r0, [r1, #0]
	tmov	r0, #5;
	tstorerb	r0, [r1, #1]
	tmov	r0, #1;
	tstorerb	r0, [r1, #2]


	tloadr	r1, DATA_I
	tloadr	r2, DATA_I+4
	tloadr	r3, DATA_I+8
	
COPY_DATA:
	tloadr	r0, [r1, #0]
	tstorer   r0, [r2, #0]
	tadd     r1, #4
	tadd     r2, #4
	tcmp	r2, r3
	tjle	COPY_DATA

	tjl	main
END:	tj	END

	.balign	4
DAT0:
	.word	0x12				@IRQ
	.word	0x13				@SVC
	@.word	(irq_stk + IRQ_STK_SIZE)	
	@.word	(svc_stk + SVC_STK_SIZE)	
	.word	(0x80bff0)	
	.word	(0x80b8f0)	
	.word	(_start_bss_)
	.word	(_end_bss_)
	.word   (0x80060c)
	.word   (0x808300)
	.word   (0x808500)
DATA_I:	
	.word	_dstored_
	.word	_start_data_
	.word	_end_data_
	
FLL_D:
	.word	0xdeadface
	.word      (0x808C00)	
	.word	(0x809FF0)	
	

        .align 4
__irq:
        tpush    {r14}
        tpush    {r0, r1, r2, r3}
        tmrss    r0
        tpush    {r0}

        tjl      lwr_irq_hdlr

        tpop     {r0}
        tmssr    r0
        tpop     {r0, r1, r2, r3}
        treti    {r15}

	.org 256
ASMEND:

	.section .bss
	.align 4
	.lcomm irq_stk, IRQ_STK_SIZE
	.lcomm svc_stk, SVC_STK_SIZE
	.end
