# Makefile to build UPduino v3.0 rgb_blink.v  with icestorm toolchain
# Original Makefile is taken from: 
# https://github.com/tomverbeure/upduino/tree/master/blink
# On Linux, copy the included upduinov3.rules to /etc/udev/rules.d/ so that we don't have
# to use sudo to flash the bit file.

rgb_blink.bin: rgb_blink.asc
	icepack rgb_blink.asc rgb_blink.bin

rgb_blink.asc: rgb_blink.json upduino.pcf
	nextpnr-ice40 --up5k --package sg48 --json rgb_blink.json --pcf upduino.pcf --freq 1 --asc rgb_blink.asc   # run place and route

rgb_blink.json: rgb_blink.v my_pll.v
	yosys -q -p "synth_ice40 -json rgb_blink.json" rgb_blink.v

my_pll.v: Makefile
	icepll -i 12 -o 16 -m -f my_pll.v

.PHONY: flash cram
flash:
	iceprog rgb_blink.bin

cram:
	iceprog -S rgb_blink.bin

.PHONY: clean
clean:
	$(RM) -f rgb_blink.json rgb_blink.asc rgb_blink.bin rgb_blink.hex abc.history
