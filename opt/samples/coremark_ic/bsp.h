#ifndef BSP_H
#define BSP_H

#define BIT0                            0x1
#define BIT1                            0x2
#define BIT2                            0x4
#define BIT3                            0x8
#define BIT4                            0x10
#define BIT5                            0x20
#define BIT6                            0x40
#define BIT7                            0x80
#define BIT8                            0x100
#define BIT9                            0x200
#define BIT10                           0x400
#define BIT11                           0x800
#define BIT12                           0x1000
#define BIT13                           0x2000
#define BIT14                           0x4000
#define BIT15                           0x8000
#define BIT16                           0x10000
#define BIT17                           0x20000
#define BIT18                           0x40000
#define BIT19                           0x80000
#define BIT20                           0x100000
#define BIT21                           0x200000
#define BIT22                           0x400000
#define BIT23                           0x800000
#define BIT24                           0x1000000
#define BIT25                           0x2000000
#define BIT26                           0x4000000
#define BIT27                           0x8000000
#define BIT28                           0x10000000
#define BIT29                           0x20000000
#define BIT30                           0x40000000
#define BIT31                           0x80000000

#define write_reg32(addr,data)          (*(volatile unsigned long  *)(addr)=data)
#define write_reg16(addr,data)          (*(volatile unsigned short *)(addr)=data)
#define write_reg8(addr,data)           (*(volatile unsigned char  *)(addr)=data)
#define read_reg32(addr)                (*(volatile unsigned long  *)(addr))
#define read_reg16(addr)                (*(volatile unsigned short *)(addr))
#define read_reg8(addr)                 (*(volatile unsigned char  *)(addr))

#define IRQTMR0                         BIT0
#define IRQTMR1                         BIT1
#define IRQTMR2                         BIT2
#define IRQUSBPWDN                      BIT3
#define IRQDMA                          BIT4
#define IRQDFIFO                        BIT5
#define IRQSBC                          BIT6
#define IRQHOSTCMD                      BIT7
#define IRQEDP0SETUP                    BIT8
#define IRQEDP0DATA                     BIT9
#define IRQEDP0STATUS                   BIT10
#define IRQEDP0SETINTf                  BIT11
#define IRQEDPS                         BIT12

#define TMREN                           (0x1 << 0)
#define MTCK                            (0x1 << 1)

//register address
#define IOBASE                          0x800000

#define I2CID                           0x800001
#define I2CSTAT                         0x800002
#define I2CMODE                         0x800003
#define I2CDAT0                         0x800004 
#define I2CDAT1                         0x800005
#define I2CCTRL                         0x800007

#define RSTEN0                          0x800060
#define RSTEN1                          0x800061
#define RSTEN2                          0x800062
#define CLKEN0                          0x800063
#define CLKEN1                          0x800064
#define CLKEN2                          0x800065
#define ACLKSTEP                        0x800067
#define ACLKMODE                        0x800068
#define DMCLKSTEP                       0x80006c
#define DMCLKMODE                       0x80006d

#define EDP0_PTR                        0x800100
#define EDP0_DAT                        0x800101
#define EDP0_CTL                        0x800102
#define EDP0_STA                        0x800103
#define USB_MODE                        0x800104
#define USB_ISO                         0x800138
#define EDPS_IRQ                        0x800139
#define USBMASK                         0x80013a
#define USBFIFO                         0x80013d
#define USBFIFOTH                       0x80013c

#define EDPS_PTR                        0x800110
#define EDPS_DAT                        0x800118
#define EDPS_CTL                        0x800120

#define AUDIO_CC0                       0x800560
#define AUDIO_CC1                       0x800564

#define GPIOCTRL0                       0x80058c
#define GPIOCTRL1                       0x80058d
#define GPIOCTRL2                       0x80058e

#define TMRCTRL0                        0x800620
#define TMRCTRL1                        0x800621
#define TMRCTRL2                        0x800622
#define TMRSTAT                         0x800623
#define TMRCAPT0                        0x800624
#define TMRCAPT1                        0x800628
#define TMRCAPT2                        0x80062c
#define TICK0                           0x800630
#define TICK1                           0x800634
#define TICK2                           0x800638

#define IRQMSK                          0x800640
#define IRQIP                           0x800644
#define IRQSRC                          0x800648

#define FIFO0BADR                       0x800b00
#define FIFO0SIZE                       0x800b02
#define FIFO1BADR                       0x800b04
#define FIFO1SIZE                       0x800b06
#define FIFO2BADR                       0x800b08
#define FIFO2SIZE                       0x800b0a

#define FIFO0LT                         0x800b0c
#define FIFO0HT                         0x800b0d
#define FIFO1LT                         0x800b0e
#define FIFO2LT                         0x800b0f
#define FIFOMODE                        0x800b10
#define AINMODE                         0x800b11
#define CICSETTING                      0x800b12
#define FIFOIRQSTAT                     0x800b13

#endif //#ifndef BSP_H
