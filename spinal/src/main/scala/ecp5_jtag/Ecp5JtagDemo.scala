
package ecp5_jtag

import spinal.core._
import spinal.lib._
import spinal.lib.io._

class Ecp5JtagDemo(isSim: Boolean) extends Component 
{
    val io = new Bundle {

        val osc_clk_in      = in(Bool)

        val led0            = out(Bool)
    }

    io.led0 := False

    noIoPrefix()
}

object Ecp5JtagDemoVerilogSim {
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)

        config.generateVerilog({
            val toplevel = new Ecp5JtagDemo(isSim = true)
            InOutWrapper(toplevel)
        })

    }
}

object Ecp5JtagDemoVerilogSyn {
    def main(args: Array[String]) {

        val config = SpinalConfig(anonymSignalUniqueness = true)
        config.generateVerilog({
            val toplevel = new Ecp5JtagDemo(isSim = false)
            InOutWrapper(toplevel)
            toplevel
        })
    }
}

