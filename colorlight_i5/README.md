
# ECP5_JTAG Example & Reverse Engineering

This directory compiles the generated SpinalHDL Verilog (in `../spinal`)
into a bitstream for the Colorlight i5 board.

The design makes it possible to blink an LED with JTAG commands.

To compile:

```sh
# Generate verilog
pushd ../spinal
make
popd

# Build bitstream
make

# Program bitstream to device
make prog

# Blink LED
./openocd_blink.sh
```

The signals that come out of the ECP5 `JTAGG` cell are routed to
the FPGA GPIOs so that they can be recorded with a logic analyzer.

The recordings are in the `../traces` directory. I used Saleae Logic-2.3.16 to
capture the traces.

In addition to the blink trace, I also recorded traces where I send random
data for various selected instruction registers. See `./tdi_toggle.tcl`. 
Run `./openocd_tdi_toggle.sh` to play this file.

