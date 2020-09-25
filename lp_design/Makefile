# Makefile to build top.v  with icestorm toolchain
# Original Makefile is taken from: 
# https://github.com/tomverbeure/upduino/tree/master/blink

top.bin: top.asc
	icepack top.asc top.bin

top.asc: top.json upduino.pcf
	nextpnr-ice40 --up5k --package sg48 --json top.json --pcf upduino.pcf --freq 1 --asc top.asc   # run place and route

top.json: top.sv
	yosys -q -p "synth_ice40 -json top.json" top.sv

my_pll.v: Makefile
	icepll -i 12 -o 16 -m -f my_pll.v

.PHONY: flash cram
flash:
	iceprog top.bin

cram:
	iceprog -S top.bin

sim:
	iverilog -g2005-sv -DSIM -s tb_top -o tb tb_top.sv top.sv $(shell yosys-config --datdir/ice40/cells_sim.v)
	vvp -N tb | tee tb.log

.PHONY: clean
clean:
	$(RM) -f top.json top.asc top.bin top.hex abc.history
