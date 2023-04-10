#include "bsp.h"
#include "printf.h"

#define		RM_ADR		0x809ff8
#define		RM_CMD		0x809ffc
#define		RM_DAT		0x80a000
#define		RM_STA		0x809ff0

#define		SWIRE_DAT	0x8000b0
#define		SWIRE_STA	0x8000b1
#define		SWIRE_DIV	0x8000b2
#define		SWIRE_SET	0x8000b3

#define		MSPI_DAT	0x0c
#define		MSPI_CTL	0x0d
#define		MCU_CTL		0x602
#define		ADR_IO		0x800000
#define		ADR_UART	0x80bf80

#define		CMD_CORE	1
#define		CMD_ANALOG	2
#define		CMD_OTP		3
#define		CMD_FLASH	4
#define		CMD_ERASE	5
#define		CMD_UART	6
#define		CMD_SUSB	7
#define		CMD_RST		8
#define		CMD_STALL	9
#define		CMD_BOOT	10
#define		CMD_CONT	11
#define		CMD_BP		12

//**********************************************
//this is interrupt function
//**********************************************
void lwr_irq_hdlr() {
}

void WaitMs (short ms)
{
	int i;
	write_reg32 (TICK0, 0);
	for (i=0; i<10000000; i++)
		if (read_reg32(TICK0) > (ms * 30000)) return;
}

/////////////////////////////////////////////////////
// write analog register
/////////////////////////////////////////////////////
void WriteAnalogReg (unsigned char adr, unsigned char dat)
{
	write_reg8(0x8000b8,adr);
	write_reg8(0x8000b9,dat);  
	write_reg8(0x8000ba,0x60);
	while((read_reg8(0x8000ba) & 0x01) != 0x00); 
}


/////////////////////////////////////////////////////
// system initial
/////////////////////////////////////////////////////

void SysInit ()
{
	write_reg32(0x800060,0xff000000);	//release reset and turn on clock
	write_reg16(0x800064,0x07ff);		//
	write_reg8(0x8005b2,0x00);		//change GPIO20 to input mode
	write_reg8(0x8005ae,0x00);		//disable GPIO20 pullup
	write_reg8 (CLKSET, 0x28);	//PLL clock: 240/8=30M
	write_reg8 (SWIRE_DIV, 0x02);	//Set SWIRE clock speed
	write_reg8 (TMRCTRL0, 1);	// enable timer 0
           
	WriteAnalogReg (0x01, 0x14);
	WriteAnalogReg (0x02, 0x87);

	write_reg16(0x808008,0x00);	//
	UART_Init ();
}

//*******************************************************

void main(){
	int i;

	SysInit ();

	while (1) {
		WaitMs (10);
		i++;
		printf ("Main loop %d\n", i);
	} // end of main loop
}
