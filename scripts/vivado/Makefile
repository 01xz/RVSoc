# Run in Windows

VIVADO_DIR = C:\Users\liaml\Xilinx\Vivado\2020.1\bin
FIRMWARE_ELF = .\..\..\firmware\firmware.elf
MMI_FILE = .\bram.mmi


build:
	$(VIVADO_DIR)\vivado -mode tcl -source non_project.tcl


program: top_new.bit
	$(VIVADO_DIR)\vivado -mode tcl -source program_dev.tcl


top_new.bit: .\build\top.bit
	$(VIVADO_DIR)\updatemem --debug --force --meminfo $(MMI_FILE) --data $(FIRMWARE_ELF) --proc dummy --bit $^ --out $@


# Run make clean in WSL
clean:
	rm -rf ./build
	rm -rf ./.hbs
	rm -rf ./.Xil
	rm -rf ./*.jou
	rm -rf ./*.log
	rm -rf ./*.html
	rm -rf ./*.xml
	rm -rf ./*.mmi
	rm -rf ./*.bit


clean_bit:
	rm -rf ./*.bit
