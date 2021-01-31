
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

General conclusion:

The `JTAGG` cell has a FF that registers the `TDI` pin before sending it to 
`JTDI`. As a result, the last bit of a `Shift-DR` operation only appears
on `JTDI` when the JTAG FSM is in the `Exit1-DR1` state (and when JSHIFT has
gone low.)

This is something that must be taken into account when designing logic
that's attached to the `JTAGG` cell.

