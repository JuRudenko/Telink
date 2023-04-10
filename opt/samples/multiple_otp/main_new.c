#include "../../proj/tl_common.h"

#if(!__PROJECT_PM_TEST__)

#include "../../proj/unit_test/ut.h"
#include "../../proj/os/ev.h"
#include "../../proj/os/sys.h"
#include "../../proj/drivers/spi.h"
#include "../../proj/drivers/syshw.h"
#include "../../proj/mcu/watchdog_i.h"
extern void user_init();
extern int process_run(void);
extern u8 rf_channel;
void gpio_user_irq_handler(void){
}

//for sample rate test
#if(DBG_MAIN_LOOP_DUR_ENABLE)
u32 g_loopcnt =0;
u32 g_time;
u32 g_duration;
u32 g_ave_dur_ploop;
#endif

/*************************************************************************************/
//QS:
//rotp is the main function to load the image ,and it has two modes
//load from flash or otp,it can judge by itself,attention it the flash
//will load first,and the func must run in ram
/*************************************************************************************/
__attribute__ ((section(".textotp"))) void rotp(void) {
#if 1
	//QS:read the data from flash to the ram.
	u8 first_flash_byte = 0xff;//QS: initialize the first two bytes
	u8 second_flash_byte = 0xff;
	reg_clk_sel = 0xc4;//QS: set the clock
	reg_tmr_ctrl = 0x01;//QS: enable timer0
	reg_clk_en0_1 = 0xFFFF;//QS:set the clock 0 1 2
	reg_clk_en2 = 0xFF;
	//QS: copy flash 0xa000  to RAM start with 0xa000 t0 0xbfff
	volatile u8 *p = reg_core8000_addr;
	reg_master_spi_ctrl = FLD_MASTER_SPI_CS;
	u32 t = reg_tmr0_tick;
	while (reg_tmr0_tick - t < 48) {
	}
	reg_master_spi_ctrl = 0;
	reg_master_spi_data = 0x03;//QS: read command
	//QS: the next is send the address (u32)0
	//mspi_wait()
	while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
		;
	//mspi_write(0)
	reg_master_spi_data = (u8) (0);//read the flash addr 0
	while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
		;
	reg_master_spi_data = (u8) (0x0);
	while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
		;
	reg_master_spi_data = (u8) (0);
	while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
		;
	reg_master_spi_data = 0x00;//QS: dummy,  to issue clock
	while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
		;
	//QS: mspi_ctrl_write(0x0a), auto mode */
	reg_master_spi_ctrl = 0x0a;
	while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
		;
	//QS: read flash to load the ram data ,we read 2Byte at flash head
	first_flash_byte = reg_master_spi_data;
	while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
		;
	second_flash_byte = reg_master_spi_data;
	while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
		;
	reg_core8000_data = first_flash_byte;
	reg_core8001_data = second_flash_byte;
	p=(volatile u8 *)(0x808002);//QS: we read the two byte at the head,so we change the address
/*QS:  --------------------we startup from the flash when the flash has data------------------------*/
	if (first_flash_byte != 0xff && second_flash_byte != 0xff) {
		for (int j = 0; j < 0x2c00-2; ++j) { //QS: from 0x8000 to 0xac00 copy 11KB to ram
			*p = reg_master_spi_data;//QS: we load the all flash data to the ram ,and startup in core
			p++;
			while (reg_master_spi_ctrl & FLD_MASTER_SPI_BUSY)
				;
		}
	}
/*QS: --------we startup from the otp when the otp have data,and the flash is the first choice-----------*/
#endif
	else
	{
		//QS: copy the otp code to ram  the ram address is 0x8000
		u16 otp_addr = 0x8000;
		u32 size = 0x2c00;//QS: the max size we load image
		u16 otp_addr_next = otp_addr + 1;
		u8 read_1_byte = 0xff;//QS: the first 2 bytes
		u8 read_2_byte = 0xff;
		volatile u8 value;
		volatile u8 *p = reg_core8000_addr;
		//QS: init the otp
		reg_otp_ctrl = FLD_OTP_OEN_PWDN | FLD_OTP_WEN_PWDN | FLD_OTP_PCEN_PWDN| FLD_OTP_CLK | FLD_OTP_OEN | FLD_OTP_FAST_CLK;
		reg_rst0_1_2_spd = SPD_RST_EN_ALL;
		reg_clk_en0_1 = FLD_CLK_EN_CLK0_1;
		reg_tmr_ctrl8 = 0x01;
		int t = reg_timer0_otp;
		int i;
		//QS: the next is the otp read
		//sleep(1000)
		for (i = 0; i < 1000000; i++) {
			if ((reg_timer0_otp - t) > (1000 * 42))
				break;
		}
		(*(volatile u8 *) (0x800069) = (u8) 0x80);//QS: enable clock
		t = reg_timer0_otp;//QS: refresh the time
		for (i = 0; i < 1000000; i++) {
			if ((reg_timer0_otp - t) > (300 * 42))
				break;
		}
		(*(volatile u8 *) (0x80041e) = (u8) 0xd8);//QS: dcdc--6.75V
		t = reg_timer0_otp;
		for (i = 0; i < 1000000; i++) {
			if ((reg_timer0_otp - t) > (300 * 42))
				break;
		}
		(*(volatile u8 *) (0x80043c) = (u8) 0x44);//QS: dc-dc switch to otp
		t = reg_timer0_otp;
		for (i = 0; i < 1000000; i++) {
			if ((reg_timer0_otp - t) > (300 * 42))
				break;
		}
		/*QS:  -------------------Auto to judge the begin of the code to load the ram --------------*/
		for (int i = 0xc000; i >= 0; i -= 0x4000) { //QS:  change from 0x4000 to 0x800  2K
			otp_addr = i;
			otp_addr_next = i + 1;
			//QS: otp read 1 byte
			otp_addr = ((otp_addr - 4) & 0xffff);
			reg_otp_addr_para = (u16) otp_addr;
			reg_otp_ptm = (u8) 0x00;
			value = reg_otp_byte_dat;
			value = reg_core8000_data;
			value = reg_otp_read_byte_dat;
			value = reg_otp_read_byte_dat;
			read_1_byte = value;
			//QS: End of read
			otp_addr_next = ((otp_addr_next - 4) & 0xffff);
			reg_otp_addr_para = (u16) otp_addr_next;
			reg_otp_ptm = (u8) 0x00;
			value = reg_otp_byte_dat;
			value = reg_core8000_data;
			value = reg_otp_read_byte_dat;
			value = reg_otp_read_byte_dat;
			read_2_byte = value;
			if (read_1_byte != 0xff && read_2_byte != 0xff) {
				otp_addr = i;
				break;
			}
		}
		//QS: decide the begin address,16kB is one part
		if (otp_addr != 0xc000 && otp_addr != 0x8000 && otp_addr != 0x4000 && otp_addr !=0x00)
		{
			otp_addr = 0x8000;//QS: default load the code at 0x8000
		}
		u16 addr_test = otp_addr;
		p = reg_core8000_addr;
		//QS: move the 0x100 byte to otp
		for (int i = 0; i < 0x100; ++i) {
			addr_test = ((addr_test - 4) & 0xffff);
			reg_otp_addr_para = (u16) addr_test;//QS£º send address
			reg_otp_ptm = (u8) 0x00;//QS: command the read otp
			value = reg_otp_byte_dat;
			value = reg_core8000_data;
			value = reg_otp_read_byte_dat;
			value = reg_otp_read_byte_dat;
			*p = value;
			otp_addr++;
			p++;
			addr_test = otp_addr;
		}
		//QS: we do not move the rotp section
		p = reg_core8500_addr ;//QS: change from reg_core8400_addr
		otp_addr = otp_addr + 0x400;//QS: attention :we add 0x100 before
		addr_test = otp_addr;
	    //QS: move to the otp 0x500
		for (int i = 0; i < size - 0x500; ++i) {
			addr_test = ((addr_test - 4) & 0xffff);
			reg_otp_addr_para = (u16) addr_test;
			reg_otp_ptm = (u8) 0x00;
			value = reg_otp_byte_dat;
			value = reg_core8000_data;
			value = reg_otp_read_byte_dat;
			value = reg_otp_read_byte_dat;
			*p = value;
			otp_addr++;
			p++;
			addr_test = otp_addr;
		}
	}

}

int main(void){
	REG_ADDR8(0x54)=0xef;
//	while(1);
#if 1
#ifdef WIN32
//	reg_simu_init();
//	rega_simu_init();
#endif
//	usb_simu_init();

#ifdef WIN32
	ut_unit_test();
#endif
	g_loopcnt = 10;
	sys_init();

	user_init();

	irq_enable();
	
#if(DBG_MAIN_LOOP_DUR_ENABLE) 
	g_time = clock_time();
	g_loopcnt = 0;
#endif	
	//int i=0x23456;
	while(1){
		//write_reg32(0x808000,i--);
		//write_reg8(0x808000,0x66);//55--0x8000
#if(MODULE_WATCHDOG_ENABLE)
		wd_clear();
#endif
		
		ev_main();

//LDW add for rate test
#if(DBG_MAIN_LOOP_DUR_ENABLE) 
		g_loopcnt++;
		if((g_loopcnt % 20)== 0)
		{
			g_duration = clock_time() - g_time;
			g_time = clock_time();
			g_ave_dur_ploop = g_duration/(20*CLOCK_SYS_CLOCK_1US);
		}
		//usb_output((u8 *)(&g_ave_dur_ploop), 4);
#endif	

	}
#endif
	return 0;
}
#endif


