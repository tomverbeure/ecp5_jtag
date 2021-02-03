
#SRCS += ../verilog/top.v
SRCS += ../verilog/Ecp5JtagDemo.v
SRCS += src/JTAGG.v src/jtag_tap.v src/tb.v

all: tb
	./tb

tb: $(SRCS)
	iverilog $^ -o $@ 

waves:
	gtkwave waves.vcd

clean:
	rm -f tb
