TARGET=ecp5_jtag
TOP=Ecp5JtagDemo

OBJS+=../spinal/$(TOP).v 
#OBJS+=../verilog/$(TOP).v 

#TRELLIS=/usr/local/share/trellis
TRELLIS=/opt/prjtrellis/share/trellis

all: ${TARGET}.bit

$(TARGET).json: $(OBJS)
	yosys -p "synth_ecp5 -json $@" $(OBJS)

$(TARGET)_out.config: $(TARGET).json $(TARGET).lpf
	nextpnr-ecp5 --25k --package CABGA381 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf --freq 65

$(TARGET).bit: $(TARGET)_out.config
	ecppack $< $@

prog:
	ecpdap prog --freq 5000 $(TARGET).bit

clean:
	rm -f *.svf *.bit *.config *.ys *.json

.PHONY: prog clean
