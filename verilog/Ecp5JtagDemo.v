// Generator : SpinalHDL v1.4.2    git head : 804c7bd7b7feaddcc1d25ecef6c208fd5f776f79
// Component : Ecp5JtagDemo
// Git hash  : 63cc835033fa0b89da24229c8c076bad8166e3d3


`define JtagTapState_binary_sequential_type [2:0]
`define JtagTapState_binary_sequential_Reset 3'b000
`define JtagTapState_binary_sequential_Idle 3'b001
`define JtagTapState_binary_sequential_Update_DR 3'b010
`define JtagTapState_binary_sequential_Capture_DR 3'b011
`define JtagTapState_binary_sequential_Shift_DR 3'b100


module Ecp5JtagDemo (
  input               osc_clk_in,
  output              led0,
  output              jtck,
  output              jrstn,
  output              jtdi,
  output              jshift,
  output              jupdate,
  output              jce1,
  output              jce2,
  output              jrti1,
  output              jrti2,
  output              jtdo1,
  output              jtdo2
);
  wire                jtagg_1_JSHIFT;
  wire                jtagg_1_JUPDATE;
  wire                jtagg_1_JRSTN;
  wire                jtagg_1_JRTI1;
  wire                jtagg_1_JRTI2;
  wire                jtagg_1_JCE1;
  wire                jtagg_1_JCE2;
  wire                jtagg_1_JTCK;
  wire                jtagg_1_JTDI;
  wire                debugtap_tap_instruction;
  reg                 debugtap_tap_tdo;
  wire       [3:0]    jtaggStateVec;
  reg        `JtagTapState_binary_sequential_type debugtap_tap_state;
  reg                 debugtap_tap_lastInstruction;
  reg                 jtagg_1_JCE1_regNext;
  reg                 jtagg_1_JCE2_regNext;
  wire       [2:0]    irSelect;
  reg                 debugtap_tap_instruction_1;
  wire                jtagg_1_JTDI_1;
  wire                irIs0x38;
  reg                 drShift;
  reg                 jtagg_1_JTDI_1_dly;
  wire       [0:0]    drChain;
  reg        [0:0]    drChainShadow;
  `ifndef SYNTHESIS
  reg [79:0] debugtap_tap_state_string;
  `endif


  JTAGG #(
    .ER1("ENABLED"),
    .ER2("ENABLED") 
  ) jtagg_1 (
    .JSHIFT     (jtagg_1_JSHIFT    ), //o
    .JUPDATE    (jtagg_1_JUPDATE   ), //o
    .JRSTN      (jtagg_1_JRSTN     ), //o
    .JRTI1      (jtagg_1_JRTI1     ), //o
    .JRTI2      (jtagg_1_JRTI2     ), //o
    .JCE1       (jtagg_1_JCE1      ), //o
    .JCE2       (jtagg_1_JCE2      ), //o
    .JTCK       (jtagg_1_JTCK      ), //o
    .JTDI       (jtagg_1_JTDI      ), //o
    .JTDO1      (debugtap_tap_tdo  ), //i
    .JTDO2      (debugtap_tap_tdo  )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(debugtap_tap_state)
      `JtagTapState_binary_sequential_Reset : debugtap_tap_state_string = "Reset     ";
      `JtagTapState_binary_sequential_Idle : debugtap_tap_state_string = "Idle      ";
      `JtagTapState_binary_sequential_Update_DR : debugtap_tap_state_string = "Update_DR ";
      `JtagTapState_binary_sequential_Capture_DR : debugtap_tap_state_string = "Capture_DR";
      `JtagTapState_binary_sequential_Shift_DR : debugtap_tap_state_string = "Shift_DR  ";
      default : debugtap_tap_state_string = "??????????";
    endcase
  end
  `endif


`ifdef TEST
  assign jtck = 1'b0;
  assign jrstn = 1'b0;
  assign jtdi = 1'b0;
  assign jshift = 1'b0;
  assign jupdate = 1'b0;
  assign jce1 = 1'b0;
  assign jce2 = 1'b0;
  assign jrti1 = 1'b0;
  assign jrti2 = 1'b0;
  assign jtdo1 = 1'b0;
  assign jtdo2 = 1'b0;
`else
  assign jtck = jtagg_1_JTCK;
  assign jrstn = jtagg_1_JRSTN;
  assign jtdi = jtagg_1_JTDI;
  assign jshift = jtagg_1_JSHIFT;
  assign jupdate = jtagg_1_JUPDATE;
  assign jce1 = jtagg_1_JCE1;
  assign jce2 = jtagg_1_JCE2;
  assign jrti1 = jtagg_1_JRTI1;
  assign jrti2 = jtagg_1_JRTI2;
  assign jtdo1 = debugtap_tap_tdo | 0;
  assign jtdo2 = debugtap_tap_tdo & 0;
`endif

  always @ (*) begin
    debugtap_tap_tdo = 1'b0;
    if(irIs0x38)begin
      debugtap_tap_tdo = drChain[0];
    end
  end

  assign jtaggStateVec = {{{jtagg_1_JRSTN,jtagg_1_JSHIFT},jtagg_1_JUPDATE},(jtagg_1_JCE1 || jtagg_1_JCE2)};
  always @ (*) begin
    if((((jtaggStateVec & 4'b1000) == 4'b0000))) begin
        debugtap_tap_state = `JtagTapState_binary_sequential_Reset;
    end else if((((jtaggStateVec & 4'b1010) == 4'b1010))) begin
        debugtap_tap_state = `JtagTapState_binary_sequential_Update_DR;
    end else if((((jtaggStateVec & 4'b1111) == 4'b1101))) begin
        debugtap_tap_state = `JtagTapState_binary_sequential_Shift_DR;
    end else if((((jtaggStateVec & 4'b1111) == 4'b1001))) begin
        debugtap_tap_state = `JtagTapState_binary_sequential_Capture_DR;
    end else begin
        debugtap_tap_state = `JtagTapState_binary_sequential_Idle;
    end
  end

  assign irSelect = {{jtagg_1_JCE1,jtagg_1_JCE2},debugtap_tap_lastInstruction};
  always @ (*) begin
    if((((irSelect & 3'b110) == 3'b100))) begin
        debugtap_tap_instruction_1 = 1'b0;
    end else if((((irSelect & 3'b110) == 3'b010))) begin
        debugtap_tap_instruction_1 = 1'b1;
    end else begin
        debugtap_tap_instruction_1 = debugtap_tap_lastInstruction;
    end
  end

  assign debugtap_tap_instruction = debugtap_tap_instruction_1;
  assign drChain = (drShift ? jtagg_1_JTDI_1 : jtagg_1_JTDI_1_dly);
  assign led0 = drChainShadow[0];
  assign jtagg_1_JTDI_1 = jtagg_1_JTDI;
  assign irIs0x38 = (debugtap_tap_instruction == 1'b0);
  always @ (posedge jtagg_1_JTCK or negedge jtagg_1_JRSTN) begin
    if (!jtagg_1_JRSTN) begin
      debugtap_tap_lastInstruction <= 1'b0;
    end else begin
      if((jtagg_1_JCE1 && (! jtagg_1_JCE1_regNext)))begin
        debugtap_tap_lastInstruction <= 1'b0;
      end
      if((jtagg_1_JCE2 && (! jtagg_1_JCE2_regNext)))begin
        debugtap_tap_lastInstruction <= 1'b1;
      end
    end
  end

  always @ (posedge jtagg_1_JTCK) begin
    jtagg_1_JCE1_regNext <= jtagg_1_JCE1;
    jtagg_1_JCE2_regNext <= jtagg_1_JCE2;
    drShift <= ((debugtap_tap_state == `JtagTapState_binary_sequential_Shift_DR) && irIs0x38);
    if(drShift)begin
      jtagg_1_JTDI_1_dly <= jtagg_1_JTDI_1;
    end
    if(irIs0x38)begin
      if((debugtap_tap_state == `JtagTapState_binary_sequential_Capture_DR))begin
        jtagg_1_JTDI_1_dly <= drChainShadow[0];
      end
      if((debugtap_tap_state == `JtagTapState_binary_sequential_Update_DR))begin
        drChainShadow <= drChain;
      end
    end
  end


endmodule
