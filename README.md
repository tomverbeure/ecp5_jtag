
# ECP5 Virtual JTAG

Resources:

* [FPGA Libraries Reference Guide](http://www.latticesemi.com/-/media/LatticeSemi/Documents/UserManuals/EI/FPGA_Libraries_Reference_Guide_39.ashx?document_id=52070)

    Simply mentions the existence of the `JTAGG` cell on page 425, but cautions that "Most users would typically not use this component directly."

* [Hackaday Superconference 2019 Badge](https://github.com/Spritetm/hadbadge2019_fpgasoc/) uses the JTAGG cell.

    * [JTAGG instantiation in top_fpga.v](https://github.com/Spritetm/hadbadge2019_fpgasoc/blob/9b24c061f50e22a111c7a73bfdd24c0d52ca5b5d/soc/top_fpga.v#L311-L322)
    * [jdreg_send, jdreg_done, jdsel_done, and jdreg_update](https://github.com/Spritetm/hadbadge2019_fpgasoc/blob/9b24c061f50e22a111c7a73bfdd24c0d52ca5b5d/soc/top_fpga.v#L223-L226) go to the `dbgreg` port of the `soc` module
    * `dbgreg` port is used to [write into the SOC RAM](https://github.com/Spritetm/hadbadge2019_fpgasoc/blob/9b24c061f50e22a111c7a73bfdd24c0d52ca5b5d/soc/soc.v#L260-L307)

    I don't think this functionality is enabled in the final version.

    The C code to create JTAG instructions for some JTAG interface (unknown) is 
    [here](https://github.com/Spritetm/hadbadge2019_fpgasoc/blob/master/soc/jtagload/main.c).

* ULX3S has a [`jtag_slave`](https://github.com/emard/ulx3s-misc/blob/27338b0081b3b441f2fa77769350fa777bd3bcf9/examples/jtag_slave/hdl/top/top_jtagg_slave.v) example.
    
    This design seems to intercept all JTAG traffic on TDI, and display it in hex on an OLED. 
    
    It doesn't use `jce1`, `jce2`, `jupdate` etc.


* MaSoCist project uses [JTAGG](https://github.com/hackfin/MaSoCist/commit/bada5fc5f78a87e48e8325db545c71a50052d785) to control something.

* SpinalHDL has a [JtaggGeneric](https://javadoc.io/static/com.github.spinalhdl/spinalhdl-lib_2.11/1.4.0/index.html#spinal.lib.blackbox.lattice.ecp5.JtaggGeneric) block

    There's even [some documentation](https://github.com/SpinalHDL/SpinalHDL/blob/dev/lib/src/main/scala/spinal/lib/blackbox/lattice/ecp5/debug.scala).

    Example of how to use it as part of a [JtagTapFactory](https://github.com/SpinalHDL/SpinalHDL/blob/dev/lib/src/main/scala/spinal/lib/com/jtag/JtagTapFactory.scala).
