GDB   = $(TRGT)gdb
OPENOCD=openocd

OPENOCD_IFACE+=-f interface/stlink-v1.cfg -f target/stm32f1x_stlink.cfg

OPENOCD_LOADFILE+=$(BUILDDIR)/$(PROJECT).elf
# debug level
OPENOCD_CMD=-d0
# interface and board/target settings (using the OOCD target-library here)
OPENOCD_CMD+=$(OPENOCD_IFACE)
# initialize
OPENOCD_CMD+=-c init
# show the targets
OPENOCD_CMD+=-c targets
# commands to prepare flash-write
OPENOCD_CMD+= -c "reset halt"
# flash erase
OPENOCD_CMD+=-c "stm32f1x mass_erase 0"
# flash-write
OPENOCD_CMD+=-c "flash write_image $(OPENOCD_LOADFILE)"
# Verify
OPENOCD_CMD+=-c "verify_image $(OPENOCD_LOADFILE)"
# reset target
OPENOCD_CMD+=-c "reset run"
# terminate OOCD after programming
OPENOCD_CMD+=-c shutdown

openocd:
	$(OPENOCD) $(OPENOCD_IFACE)

stlink:
	st-util -m -p 3333

load: $(PROJECT).elf
	$(GDB) -x ${COMMON}/fw_load.gdb $<

stload: $(PROJECT).elf
	@echo Usage: 'load', 'break main', 'run', 'continue'
	$(GDB) -x ${COMMON}/fw_stload.gdb $<

prog program: $(OPENOCD_LOADFILE)
	@echo "Programming with OPENOCD"
	$(OPENOCD) $(OPENOCD_CMD)

tags: 
	ctags -R --c++-kinds=+p --fields=+iaS --extra=+q . ${CHIBIOS}/os ${BOARDINC}

.PHONY: tags openocd stlink load
