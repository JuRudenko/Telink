GCCPATH = /opt/tc32/bin/tc32
AS      = $(GCCPATH)-elf-as
CC      = $(GCCPATH)-elf-gcc
LD      = $(GCCPATH)-elf-ld
NM      = $(GCCPATH)-elf-nm
OBJCOPY = $(GCCPATH)-elf-objcopy
OBJDUMP = $(GCCPATH)-elf-objdump


TARGET 		= boot
CFLAGS_T       = -c -O2 
#CFLAGS_T       = -c -g -O0 
LDFLAGS		= -T boot.link
NMFLAGS		= -n
ASMFLAGS	= 

OBJS    = cstartup.o main.o div_mod_hw.o printf.o
LIBS    = 
all: $(TARGET).mot

clean:
	rm -rf *.mot *.elf *.map *.lst *.o *.bin  *.txt *.s *.ll *.bc

$(TARGET).mot:$(TARGET).elf $(TARGET).map
	$(OBJCOPY) -O srec $< $@
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin
	$(OBJDUMP) -x -D -l -S $(TARGET).elf > $(TARGET)-.lst

$(TARGET).elf:$(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

$(TARGET).map:$(TARGET).elf
	$(NM) $(NMFLAGS) $< > $@

cstartup.o: cstartup.S
	$(CC) $*.S $(CFLAGS_T) -o $*.o
	$(OBJDUMP) -x -D -l -S $*.o > $*.lst
	
main.o: main.c
	$(CC) $*.c $(CFLAGS_T) -o $*.o
	$(OBJDUMP) -x -D -l -S $*.o > $*.lst	

printf.o: printf.c
	$(CC) $*.c $(CFLAGS_T) -o $*.o
	$(OBJDUMP) -x -D -l -S $*.o > $*.lst	

div_mod_hw.o: div_mod_hw.S
	$(CC) $*.S $(CFLAGS_T) -o $*.o
	$(OBJDUMP) -x -D -l -S $*.o > $*.lst	

