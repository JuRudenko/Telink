
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

int main(void){


#ifdef WIN32
//	reg_simu_init();
//	rega_simu_init();
#endif
//	usb_simu_init();

#ifdef WIN32
	ut_unit_test();
#endif

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
	return 0;
}

#endif

