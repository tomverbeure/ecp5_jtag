
package ecp5_jtag

import spinal.core._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.com.jtag._
import blackbox.lattice.ecp5.{JTAGG,JtaggGeneric}

// https://github.com/SpinalHDL/SpinalHDL/blob/dev/lib/src/main/scala/spinal/lib/com/jtag/JtagTapFactory.scala

class Ecp5JtagDemo(isSim: Boolean) extends Component 
{
    val io = new Bundle {

        val osc_clk_in      = in(Bool)

        val led0            = out(Bool)

        val jtck            = out(Bool)
        val jrstn           = out(Bool)
        val jtdi            = out(Bool)
        val jshift          = out(Bool)
        val jupdate         = out(Bool)
        val jce1            = out(Bool)
        val jce2            = out(Bool)
        val jrti1           = out(Bool)
        val jrti2           = out(Bool)
        val jtdo1           = out(Bool)
        val jtdo2           = out(Bool)
    }

    noIoPrefix()


    // JTAGG is the black box that will be instantiated in the Verilog.
    // JtaggGeneric are the generic parameters of the black box.
    val jtagg = new JTAGG(JtaggGeneric().copy())

    io.jtck       := jtagg.io.JTCK
    io.jrstn      := jtagg.io.JRSTN
    io.jtdi       := jtagg.io.JTDI
    io.jshift     := jtagg.io.JSHIFT
    io.jupdate    := jtagg.io.JUPDATE
    io.jce1       := jtagg.io.JCE1
    io.jce2       := jtagg.io.JCE2
    io.jrti1      := jtagg.io.JRTI1
    io.jrti2      := jtagg.io.JRTI2
    io.jtdo1      := jtagg.io.JTDO1
    io.jtdo2      := jtagg.io.JTDO2

    val debugtap = ClockDomain(
            jtagg.io.JTCK, 
            jtagg.io.JRSTN, 
            config = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW))(
        new Area{
            // JtagTapFactory returns a JTAG TAP controller.
            // Depending on its first parameter, this could be a generic JTAG TAP controller made
            // out of soft gates. 
            // If it's called with a JTAGG object, a Lattice-specific JTAG TAP-like controller controller
            // is created. 
            val tap = JtagTapFactory(jtagg, 8)

            // JTAGG only supports 2 instructions: 0x32 and 0x38
            val readArea  = tap.read(B(0xAE, 8 bits))(0x38)
            val writeArea = tap.write(io.led0, cleanUpdate=true)(0x32)
        })

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

