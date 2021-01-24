
# Lattice ECP5 User JTAG

Most FPGAs have a mechanism to bridge the standard JTAG IO pins of the FPGA into the user domain:

* Intel has Virtual JTAG, probably the most advanced system with almost an unlimited number of user JTAG slave blocks.
* Xilinx has the BSCAN class of cell primitives. For example, Xilinx 7 has the BSCANE2 cell, which there can be a maximum of 4, each for a different USER JTAG instruction.
* Lattice has the JTAGx primitive.

The JTAGx primitives are listed in the Lattice [FPGA Libraries Reference Guide](http://www.latticesemi.com/view_document?document_id=52656).  
There are currently 6 different versions: 

* JTAGA: LatticeSC/M architecture
* JTAGB: LatticeECP/ECP and LatticeXP architecture
* JTAGC: LatticeECP2/M architecture
* JTAGD: LatticeECP2/M architecture
* JTAGE: LatticeECP3 and LatticeXP2 architectures
* JTAGF: MachXO2, MachX03D, MachX03L, and Platform Manager 2 architectures
* JTAGG: LatticeECP5 architecture

Except for JTAGA, the pins of these primitives are mostly the same. 

The primitive manual describes the functionality of these cells pretty well, except for ECP5, which says:

> The JTAGG element is used to provide access to internal JTAG signals from
> within the FPGA fabric. This element is used for some cores, such as Reveal
> Logic Analyzer, and other purposes. Most users would typically not use this
> component directly. 

However, since the pinout of JTAGG is identical to the one of earlier primitives, you can simply use those descriptions
and it works just fine.

Note that using the JTAGG primitive will probably result in the inability to use Lattice REveal Logic Analyzer, but
that's OK if you're using the Yosys/NextPnR-based open source tool flow.

I googled a bit around for projects that use the JTAGG primitive. You can check those out below in the resources section.

Fundamentally, the cell is pretty simple:

It supports 2 8-bit JTAG instructions: ER1 (0x32) and ER2 (0x38).

The user defined core logic can attach whichever scan logic it wants to these 2 instructions.

The JTAGG primitive has the following IO pins:

* JTCK: output. Connected to the the external TCK and TDI pins.
* JSHIFT: output. High when the FPGA TAP is in Shift-DR state. 
* JUPDATE: output. High when the FPGA TAP is in Update-DR state.
* JRSTN: output. Low when the TAP is in Test-Logic-Reset state.
* JCE1: output. High when the ER1 instruction is selected and the TAP is in Capture-DR or Shift-DR state.
* JCE2: output. High when the ER2 instruction is selected and the TAP is in Capture-DR or Shift-DR state.
* JRT1: output. High when the ER1 instruction is selected and the TAP is in Run-Test/Idle state.
* JRT2: output. High when the ER2 instruction is selected and the TAP is in Run-Test/Idle state.
* JTDO1: input. Connected to TDO when ER1 instruction is selected.
* JTDO2: input. Connected to TDO when ER2 instruction is selected.

The pins above are sufficient to add shift data in and out of the TAP when ER1 or ER2 instructions are selected.

## SpinalHDL Example

In the [`./spinal](./spinal) directory, you can find a SpinalHDL example that uses the JTAGG primitive. In typical
SpinalHDL fashion, there are lot of abstraction layers that make thing sometimes hard to follow, but it also allows
easily porting over an example from one FPGA family to another. 

The code requires SpinalHDL version 1.4.2 (as I write this, this is the latest release.)

## Resources:

* [FPGA Libraries Reference Guide](http://www.latticesemi.com/view_document?document_id=52656)

* [Hackaday Superconference 2019 Badge](https://github.com/Spritetm/hadbadge2019_fpgasoc/) uses the JTAGG cell.

    * [JTAGG instantiation in top_fpga.v](https://github.com/Spritetm/hadbadge2019_fpgasoc/blob/9b24c061f50e22a111c7a73bfdd24c0d52ca5b5d/soc/top_fpga.v#L311-L322)
    * [jdreg_send, jdreg_done, jdsel_done, and jdreg_update](https://github.com/Spritetm/hadbadge2019_fpgasoc/blob/9b24c061f50e22a111c7a73bfdd24c0d52ca5b5d/soc/top_fpga.v#L223-L226) go to the `dbgreg` port of the `soc` module
    * `dbgreg` port is used to [write into the SOC RAM](https://github.com/Spritetm/hadbadge2019_fpgasoc/blob/9b24c061f50e22a111c7a73bfdd24c0d52ca5b5d/soc/soc.v#L260-L307)

    I don't think this functionality is enabled in the final version.

    The C code to create JTAG instructions for some JTAG interface (unknown) is 
    [here](https://github.com/Spritetm/hadbadge2019_fpgasoc/blob/master/soc/jtagload/main.c).

* ULX3S has a [`jtag_slave`](https://github.com/emard/ulx3s-misc/blob/27338b0081b3b441f2fa77769350fa777bd3bcf9/examples/jtag_slave/hdl/top/top_jtagg_slave.v) example.
    
    This design seems to intercept all JTAG traffic on TDI, and display it in hex on an OLED. 
    
    It doesn't use JCE1, JCE2, JUPDATE etc.

* MaSoCist project uses [JTAGG](https://github.com/hackfin/MaSoCist/commit/bada5fc5f78a87e48e8325db545c71a50052d785) to control something.

* SpinalHDL has a [JtaggGeneric](https://javadoc.io/static/com.github.spinalhdl/spinalhdl-lib_2.11/1.4.0/index.html#spinal.lib.blackbox.lattice.ecp5.JtaggGeneric) block

    There's even [some documentation](https://github.com/SpinalHDL/SpinalHDL/blob/dev/lib/src/main/scala/spinal/lib/blackbox/lattice/ecp5/debug.scala).

