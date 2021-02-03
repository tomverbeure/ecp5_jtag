
SRCS += ../verilog/top.v src/JTAGG.v src/jtag_tap.v src/tb.v

all: tb
	./tb

tb: $(SRCS)
	iverilog $^ -o $@ 

waves:
	gtkwave waves.vcd
