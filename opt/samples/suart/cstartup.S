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
	.byte	(0x54)
	.short	(_code_size_)
	.byte   (0x88)

	.org 0x10
	tj	__irq
	
@********************************************************************************************************
@                                   LOW-LEVEL INITIALIZATION
@********************************************************************************************************
	.extern  ?main

	.balign 4
__reset:

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

SETIC:
	tloadr     r1, DAT0 + 24
	tmov	r0, #20;
	tstorerb	r0, [r1, #0]
	tmov	r0, #20;
	tstorerb	r0, [r1, #1]
	tmov	r0, #0;
	tstorerb	r0, [r1, #2]

	tjl	main
END:	tj	END

	.balign	4
DAT0:
	.word	0x12				@IRQ
	.word	0x13				@SVC
	@.word	(irq_stk + IRQ_STK_SIZE)	
	@.word	(svc_stk + SVC_STK_SIZE)	
	.word	(0x809c00)	
	.word	(0x809b00)	
	.word	(_start_bss_)
	.word	(_end_bss_)
	.word   (0x80060c)
	
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
