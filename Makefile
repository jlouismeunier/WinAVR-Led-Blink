
### Makefile with jtagice clone


##########------------------------------------------------------##########
##########              Project-specific Details                ##########
##########    Check these every time you start a new project    ##########
##########------------------------------------------------------##########

MCU   = atmega16
AVR_MCU = m16
F_CPU = 1000000  
BAUD  = 19200

##for windows users, open device manager to determine com port
 DEVICE = com4

## A directory for common code (usart.c, ...).
LIBTOOLS = ../toolbox

##########------------------------------------------------------##########
##########                 Programmer Defaults                  ##########
##########------------------------------------------------------##########

PROGRAMMER_TYPE = jtag1
# extra arguments to avrdude: baud rate, chip type, -F flag, etc.
PROGRAMMER_ARGS = -p $(AVR_MCU) -P $(DEVICE) -b $(BAUD)


##########------------------------------------------------------##########
##########                  Program Locations                   ##########
##########     Won't need to change if they're in your PATH     ##########
##########------------------------------------------------------##########

CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
AVRSIZE = avr-size
AVRDUDE = avrdude

##########------------------------------------------------------##########
##########      Configuration of compiler / linker              ##########
##########------------------------------------------------------##########

## The name of your project (without the .c)
# TARGET = 
## Or name it automatically after the enclosing directory
TARGET = $(lastword $(subst /, ,$(CURDIR)))


# Object files: will find all .c/.h files in current directory
#  and in LIBTOOLS.  If you have any other (sub-)directories with code,
#  you can add them in to SOURCES below in the wildcard statement.
SOURCES=$(wildcard *.c $(LIBTOOLS)/*.c)
OBJECTS=$(SOURCES:.c=.o)
HEADERS=$(SOURCES:.c=.h)

## Compilation options, type man avr-gcc if you're curious.
TARGET_ARCH = -mmcu=$(MCU)
CPPFLAGS = -I. -I$(LIBTOOLS)
CFLAGS = -Os -g -std=gnu99 -Wall
## Use short (8-bit) data types 
CFLAGS += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums 
## Splits up object files per function
CFLAGS += -ffunction-sections -fdata-sections 
LDFLAGS = -Wl,-Map,$(TARGET).map 
## Optional, but often ends up with smaller code
LDFLAGS += -Wl,--gc-sections 
## Relax shrinks code even more, but makes disassembly messy
## LDFLAGS += -Wl,--relax
## LDFLAGS += -Wl,-u,vfprintf -lprintf_flt -lm  ## for floating-point printf
## LDFLAGS += -Wl,-u,vfprintf -lprintf_min      ## for smaller printf


## Explicit pattern rules:
##  To make .o files from .c files 
%.o: %.c $(HEADERS) Makefile
	 $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c -o $@ $<;

$(TARGET).elf: $(OBJECTS)
	$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LDLIBS) -o $@

%.hex: %.elf
	 $(OBJCOPY) -j .text -j .data -O ihex $< $@

%.eeprom: %.elf
	$(OBJCOPY) -j .eeprom --change-section-lma .eeprom=0 -O ihex $< $@ 

%.lst: %.elf
	$(OBJDUMP) -S $< > $@

## These targets don't have files named after them
.PHONY: all disassemble disasm eeprom size clean squeaky_clean flash fuses




#######################################################
## Targets you can call to compile 
######################################################

all: $(TARGET).hex 

debug:
	@echo
	@echo "MCU, F_CPU, BAUD: "  $(MCU), $(F_CPU), $(BAUD)
	@echo "Source files: "   $(SOURCES)
	@echo	"Objects : " $(OBJECTS)
	@echo "Headers : " $(HEADERS)
	@echo "LDLIBS : " $(LDLIBS)

clean:
	rm -f $(TARGET).elf $(TARGET).hex $(TARGET).obj \
	$(TARGET).o $(TARGET).d $(TARGET).eep $(TARGET).lst \
	$(TARGET).lss $(TARGET).sym $(TARGET).map $(TARGET)~ \
	$(TARGET).eeprom


#######################################################
## Targets you can call to flash
######################################################

flash: $(TARGET).hex 
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) $(PROGRAMMER_ARGS) -U flash:w:$< -v

flash_eeprom: $(TARGET).eeprom
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) $(PROGRAMMER_ARGS) -U eeprom:w:$<

avrdude_terminal:
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) $(PROGRAMMER_ARGS) -nt


#######################################################
## Targets you can call for fuses
######################################################

## Mega 48, 88, 168, 328 default values
#LFUSE = 0x62
#HFUSE = 0xdf
#EFUSE = 0x00

## Mega32A default values
#LFUSE = 0xE1
#HFUSE = 0x99
#EFUSE = 0xFF

show_fuses:
	$(AVRDUDE) -c $(PROGRAMMER_TYPE) -p $(MCU) $(PROGRAMMER_ARGS) -nv	
