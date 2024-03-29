
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

    // Bring out the JTAGG signals to the FPGA pins to connect it to a logic analyzer.
    io.jtck       := (if (true) jtagg.io.JTCK    else False)
    io.jrstn      := (if (true) jtagg.io.JRSTN   else False)
    io.jtdi       := (if (true) jtagg.io.JTDI    else False)
    io.jshift     := (if (true) jtagg.io.JSHIFT  else False)
    io.jupdate    := (if (false) jtagg.io.JUPDATE else False)
    io.jce1       := (if (true) jtagg.io.JCE1    else False)
    io.jce2       := (if (true) jtagg.io.JCE2    else False)
    io.jrti1      := (if (true) jtagg.io.JRTI1   else False)
    io.jrti2      := (if (true) jtagg.io.JRTI2   else False)
    io.jtdo1      := (if (false) jtagg.io.JTDO1   else False)
    io.jtdo2      := (if (false) jtagg.io.JTDO2   else False)

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

