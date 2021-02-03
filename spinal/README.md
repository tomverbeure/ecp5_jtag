
# JTAG and SpinalHDL

## User Visible JTAG Aspects

The key think that you need is a JTAG test access port (TAP). This TAP is what will
be used to attach features: read registers, write registers etc.

A SpinalHDL TAP does not have to be a 'real' JTAG TAP as narrowly defined by the spec.
It's a block that has some higher level traits against which you design your JTAG related
features.

In SpinalHDL, `JtagTapFactory` currently creates 2 kinds of JtagTaps: one generic `JtagTap` one,
which implements the standard TAP FSM and everything that surrounds is, and one specific
for ECP5, JtagTap_Lattice_ECP5, that instantiates a JTAGG library primitive.

Both `JtagTap` and `JtagTap_Lattice_ECP5` inherit traits from `JtagTapFunctions`, which
defines the "API" that will be used by the user who uses `JtagTapFactory` to implement
JTAG functions. Currently, this API consists of:

```scala
trait JtagTapFunctions {
  //Instruction wrappers
  def idcode(value: Bits)(instructionId: Int)
  def read[T <: Data](data: T, light : Boolean)(instructionId: Int)
  def write[T <: Data](data: T, cleanUpdate: Boolean = true, readable: Boolean = true)(instructionId: Int)
  def flowFragmentPush[T <: Data](sink : Flow[Fragment[Bits]], sinkClockDomain : ClockDomain)(instructionId: Int)
//  def hasUpdate(now : Bool)(instructionId : Int): Unit
}
```

So now, let's go line by line through the code that's used to attach JTAG functionality to
an ECP5 FPGA.

```scala
    val jtagg = new JTAGG(JtaggGeneric().copy())
```

This instantiates a `JTAGG` cell in the design. The `JtaggGeneric` is a tiny wrapper around a
SpinalHdl `Generic()` that's used by a `BlackBox()`. By default, the `JtaggGeneric()` enables
both the `ER1` and the `ER2` port.

```scala
    val debugtap = ClockDomain(
            jtagg.io.JTCK, 
            jtagg.io.JRSTN, 
            config = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW))(
        ...
```
We create a clock domain that uses `JTCK` and `JRSTN` as clock and reset. According to the ECP5
manual, the `JTCK` and `JRSTN` outputs are connected straight to their respective JTAG pins on
the FPGA package.

```scala
        ...
        new Area{
            val tap = JtagTapFactory(jtagg, 8)
        ...
```
We now create the TAP. `JtagTapFactory` has (currently) 2 overloaded `apply` functions. One expects
a `Jtag` IO bundle which contains all the regular JTAG IO signals) as first argument, the other 
expects an object of the `JTAGG` class. `JtagTapFactory` will then create a generic `JtagTap` or a
`JtagTap_Lattice_ECP5` object.

```scala
        ...
            val readArea  = tap.read(B(0xAE, 8 bits))(0x38)
            val writeArea = tap.write(io.led0, cleanUpdate=true)(0x32)
        })
```

The 2 lines above create a read JTAG data register, and a write JTAG data register. 

In the code above, the read register is an 8-bit wide that always returns a fixed value of 0xAE, 
but the first argument of `read` is a templated argument, so you could give it pretty much anything.
The read register is selected by a JTAG IR value of 0x38.

The write register is only 1 bits long and connected straight to LED0. It's selected with an IR value of
0x32.

In the case of ECP5, only IR values of 0x32 and 0x38 are allowed: if you specificy a different value, 
SpinalHDL will complain. This is because the JTAGG primitive only supports ER1 (0x32) and ER2 (0x38) as
user selectable data registers.

As seen earlier, a SpinalHDL JtagTap has currently 4 API calls:

```scala
  def idcode(value: Bits)(instructionId: Int)
  def read[T <: Data](data: T, light : Boolean)(instructionId: Int)
  def write[T <: Data](data: T, cleanUpdate: Boolean = true, readable: Boolean = true)(instructionId: Int)
  def flowFragmentPush[T <: Data](sink : Flow[Fragment[Bits]], sinkClockDomain : ClockDomain)(instructionId: Int)
```

* `idcode` is use to set the IDCODE of your device. When using it on an ECP5, this will error out because
  that's obviously not allows. (Again: only user chains ER1 and ER2 are supported.)
* `flowFragmentPush` allows for pushing data to a target clock domain, without back-pressure.

    According to the interface, it accepts a generic data fragment, but right now, it errors out with
    anything other than 1 bit data. And that 1 bit data is mapped a 'valid'...

* `read` has the following extra parameters: 
    * `light`: 
        * `false`: `data` is double-buffered: it's copied into a shadow register during the Capture-DR 
           phase, after which the contents of this shadow register are shifted out.
        * `true`: `data` is shifted out directly. If `data` changes during a shift, different fields 
           of `data` might become inconsistent.
* `write`
    * `readable`:
        * `true`: during Capture-DR, the current value of `data` is copied and shifted out, while the
          new value is being shifted in.
    * `cleanUpdate`: 
        * `false`: `data` is assigned directly to the shift register. During the shift operation, the value
          of `data` will change each clock cycle.
        * `true`: during Update-DR phase, the shift register is copied into a shadow register. `data` is
          the output of this shadow register.

    If `readable` is set to `false`, `cleanUpdate` can't be true, because `cleanUpdate` uses a register
    that's created by `readable.

There is currently no expand the API in a way that works for different `JtagTap` classes: that's because the
generc JtagTap and the ECP5 specific JtagTap are implemented different, with their own `read`, `write` etc
methods, and thus also with any other new method that you might want to add.

## Under the Hood of the ECP5 JtagTap

Both the generic and ECP5 TAP use a `JtagTapInstructionCtrl` bundle as the main data and control signals
to determine when to shift, update etc.

The definition is as follows:

```scala
case class JtagTapInstructionCtrl() extends Bundle with IMasterSlave {
  val tdi = Bool()
  val enable = Bool()
  val capture = Bool()
  val shift = Bool()
  val update = Bool()
  val reset = Bool()
  val tdo = Bool()
```

In the case of ECP5 the state signals are derived from a combination of the JTAGG outputs. (In the generic case,
it's pretty much a direct connection to the one-hot states of the canonical TAP FSM.)

The ECP5 JtagTap itself is straightforward, with each API call implemented with `Area` objects like
`JtagTapInstructionWrite`, `JtagTapInstructionRead`, etc. These API implementation are *also*
straightforward. 

However, inside these API implementations, there's always a `JtaggShifter` object. It's just a shift
register that takes a `JtagTapInstructionCtrl` interface parameter, but 
[implementation](https://github.com/SpinalHDL/SpinalHDL/blob/1d55a06c19219c47feffd377aa3c71a2ab5e333b/lib/src/main/scala/spinal/lib/com/jtag/lattice/ecp5/JtagTapCommands.scala#L25) 
is very convoluted.

Everything seems to be centered around the fact that "...ECP5 JTAGG has a buffer already implemented 
at the TDI signal...". I suspect that this has consequences wrt data coming 1 clock cycle later
than expect or something of that sort.

To be investigated...

Here's now I currently understand `JtagTapInstructionFlowFragmentPush`: it doesn't contain a shift register inside 
JtagTap, but each bit that gets scanned in, is converted into a single bit fragment with a .last attribute that 
gets asserted at the end of Shift-DR. This single bit fragment gets immediately synchronized to the destination clock 
domain. It is up to the destination to convert this fragment stream into a parallel message, and to use the .last 
attribute as final update.

`StreamFragmentBitsDispatcherElement` is an example of that.

This will only work if the destination clock is at least 2x faster than the JTAG clock, which will usually be the case.
If you want to use JtagTapInstructionFlowFragmentPush with a slower destination clock domain, then you'd have to improve 
the code so that you put a shift register in the JTAG clock domain, and only transfer a fragment to the other side whenever 
that shift register is full.

