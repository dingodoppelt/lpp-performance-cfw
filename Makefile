BUILDDIR = build

TOOLS = tools

SOURCES += src/aftertouch/aftertouch.c
SOURCES += src/flash/stm32f10x_imports.c src/flash/write.c src/flash/flash.c src/flash/settings.c
SOURCES += src/led/led.c src/led/palettes.c
SOURCES += src/send/send.c
SOURCES += src/sysex/sysex.c
SOURCES += src/other/conversion.c src/other/tempo.c

SOURCES += src/modes/mode.c
SOURCES += src/modes/normal/performance.c src/modes/normal/ableton.c src/modes/normal/note.c src/modes/normal/drum.c src/modes/normal/fader.c src/modes/normal/programmer.c src/modes/normal/piano.c src/modes/normal/custom.c src/modes/normal/chord.c src/modes/normal/text.c
SOURCES += src/modes/special/boot.c src/modes/special/setup.c src/modes/special/editor.c src/modes/special/scale.c src/modes/special/puyo.c src/modes/special/idle.c

SOURCES += src/app.c

INCLUDES += -Iinclude -I

LIB = lib/launchpad_pro.a

OBJECTS = $(addprefix $(BUILDDIR)/, $(addsuffix .o, $(basename $(SOURCES))))

# output files
SYX = $(BUILDDIR)/cfw.syx
ELF = $(BUILDDIR)/cfw.elf
HEX = $(BUILDDIR)/cfw.hex
HEXTOSYX = $(BUILDDIR)/hextosyx
SIMULATOR = $(BUILDDIR)/simulator

# tools
HOST_GPP = g++
HOST_GCC = gcc
CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

CFLAGS  = -O2 -Wall -I.\
-D_STM32F103RBT6_  -D_STM3x_  -D_STM32x_ -mthumb -mcpu=cortex-m3 -fcommon \
-fsigned-char  -DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER -DHSE_VALUE=6000000UL \
-DCMSIS -DUSE_GLOBAL_CONFIG -ffunction-sections -std=c99  -mlittle-endian \
$(INCLUDES) -o

LDSCRIPT = stm32_flash.ld

LDFLAGS += -T$(LDSCRIPT) -u _start -u _Minimum_Stack_Size  -mcpu=cortex-m3 -mthumb -specs=nano.specs -specs=nosys.specs -nostdlib -Wl,-static -N -nostartfiles -Wl,--gc-sections

all: $(SYX)

# build the final sysex file from the ELF - run the simulator first
$(SYX): $(HEX) $(HEXTOSYX)
	./$(HEXTOSYX) $(HEX) $(SYX)

# build the tool for conversion of ELF files to sysex, ready for upload to the unit
$(HEXTOSYX):
	$(HOST_GPP) -Ofast -std=c++0x -I./$(TOOLS)/libintelhex/include ./$(TOOLS)/libintelhex/src/intelhex.cc $(TOOLS)/hextosyx.cpp -o $(HEXTOSYX)

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(ELF): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS) $(LIB)

DEPENDS := $(OBJECTS:.o=.d)

-include $(DEPENDS)

$(BUILDDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) -MMD -o $@ $<

clean:
	rm -rf $(BUILDDIR)
