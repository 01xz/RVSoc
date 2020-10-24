SHELL = bash

MAKE = make
PYTHON = python3

INCLUDES = .\

# 16k x 32bit -> 2^14
MEMORY_SIZE = 16384

TOOLCHAIN_PREFIX = /opt/riscv32imc/bin/riscv32-unknown-elf-
CCFLAGS = -march=rv32i -mabi=ilp32 -Wall

FIRMWARE_OBJS = start.o main.o firmware.o


# Using makehex.py
firmware.hex: firmware.bin
	$(PYTHON) makehex.py $^ $(MEMORY_SIZE) > $@

firmware.bin: firmware.elf firmware.elf.S
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@;
	wc -c firmware.bin
	size firmware.elf
	chmod -x $@

firmware.elf.S: firmware.elf
	$(TOOLCHAIN_PREFIX)objdump $< -s -d > $@

firmware.elf: $(FIRMWARE_OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc $(CCFLAGS) -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,sections.lds \
		$(FIRMWARE_OBJS) -lgcc
	chmod -x $@

start.o: start.S
	$(TOOLCHAIN_PREFIX)gcc -c $(CCFLAGS) -o $@ $<

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c $(CCFLAGS) -Os -ffreestanding -nostdlib -o $@ $<


clean:
	rm -f *.coe *.bin *.elf.S
	rm -vrf $(FIRMWARE_OBJS)
	rm -f *.o
