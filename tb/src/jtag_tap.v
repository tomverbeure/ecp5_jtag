`default_nettype none

module jtag_tap(
        input  wire tck, tms, tdi,
    
        output wire test_logic_reset,
        output wire run_test_idle,
        output wire capture_dr,
        output wire shift_dr,
        output wire update_dr,
        output wire capture_ir,
        output wire shift_ir,
        output wire update_ir
        );

    reg [3:0] cur_jtag_state = 0, nxt_jtag_state;

    localparam fsm_test_logic_reset     = 0;
    localparam fsm_run_test_idle        = 1;
    localparam fsm_select_dr_scan       = 2;
    localparam fsm_capture_dr           = 3;
    localparam fsm_shift_dr             = 4;
    localparam fsm_exit1_dr             = 5;
    localparam fsm_pause_dr             = 6;
    localparam fsm_exit2_dr             = 7;
    localparam fsm_update_dr            = 8;
    localparam fsm_select_ir_scan       = 9;
    localparam fsm_capture_ir           = 10;
    localparam fsm_shift_ir             = 11;
    localparam fsm_exit1_ir             = 12;
    localparam fsm_pause_ir             = 13;
    localparam fsm_exit2_ir             = 14;
    localparam fsm_update_ir            = 15;

    always @* begin
        case(cur_jtag_state)
            fsm_test_logic_reset:   nxt_jtag_state = tms ? fsm_test_logic_reset : fsm_run_test_idle;
            fsm_run_test_idle:      nxt_jtag_state = tms ? fsm_select_dr_scan   : fsm_run_test_idle;
            fsm_select_dr_scan:     nxt_jtag_state = tms ? fsm_select_ir_scan   : fsm_capture_dr;
            fsm_capture_dr:         nxt_jtag_state = tms ? fsm_exit1_dr         : fsm_shift_dr;
            fsm_shift_dr:           nxt_jtag_state = tms ? fsm_exit1_dr         : fsm_shift_dr;
            fsm_exit1_dr:           nxt_jtag_state = tms ? fsm_update_dr        : fsm_pause_dr;
            fsm_pause_dr:           nxt_jtag_state = tms ? fsm_exit2_dr         : fsm_pause_dr;
            fsm_exit2_dr:           nxt_jtag_state = tms ? fsm_update_dr        : fsm_shift_dr;
            fsm_update_dr:          nxt_jtag_state = tms ? fsm_select_dr_scan   : fsm_run_test_idle;

            fsm_select_ir_scan:     nxt_jtag_state = tms ? fsm_test_logic_reset : fsm_capture_ir;
            fsm_capture_ir:         nxt_jtag_state = tms ? fsm_exit1_ir         : fsm_shift_ir;
            fsm_shift_ir:           nxt_jtag_state = tms ? fsm_exit1_ir         : fsm_shift_ir;
            fsm_exit1_ir:           nxt_jtag_state = tms ? fsm_update_ir        : fsm_pause_ir;
            fsm_pause_ir:           nxt_jtag_state = tms ? fsm_exit2_ir         : fsm_pause_ir;
            fsm_exit2_ir:           nxt_jtag_state = tms ? fsm_update_ir        : fsm_shift_ir;
            fsm_update_ir:          nxt_jtag_state = tms ? fsm_select_dr_scan   : fsm_run_test_idle;
        endcase
    end

    reg [20*8-1:0] cur_jtag_state_text;

`ifndef SYNTHESIS
    always @* begin
        case(cur_jtag_state)
            fsm_test_logic_reset:   cur_jtag_state_text = "test_logic_reset";
            fsm_run_test_idle:      cur_jtag_state_text = "run_test_idle";
            fsm_select_dr_scan:     cur_jtag_state_text = "select_dr_scan";
            fsm_capture_dr:         cur_jtag_state_text = "capture_dr";
            fsm_shift_dr:           cur_jtag_state_text = "shift_dr";
            fsm_exit1_dr:           cur_jtag_state_text = "exit1_dr";
            fsm_pause_dr:           cur_jtag_state_text = "pause_dr";
            fsm_exit2_dr:           cur_jtag_state_text = "exit2_dr";
            fsm_update_dr:          cur_jtag_state_text = "update_dr";

            fsm_select_ir_scan:     cur_jtag_state_text = "select_ir_scan";
            fsm_capture_ir:         cur_jtag_state_text = "capture_ir";
            fsm_shift_ir:           cur_jtag_state_text = "shift_ir";
            fsm_exit1_ir:           cur_jtag_state_text = "exit1_ir";
            fsm_pause_ir:           cur_jtag_state_text = "pause_ir";
            fsm_exit2_ir:           cur_jtag_state_text = "exit2_ir";
            fsm_update_ir:          cur_jtag_state_text = "update_ir";
        endcase
    end
`endif

    always @(posedge tck) begin
        cur_jtag_state   <= nxt_jtag_state;
    end

    assign test_logic_reset = cur_jtag_state == fsm_test_logic_reset;
    assign run_test_idle    = cur_jtag_state == fsm_run_test_idle;
    assign capture_dr       = cur_jtag_state == fsm_capture_dr;
    assign shift_dr         = cur_jtag_state == fsm_shift_dr;
    assign update_dr        = cur_jtag_state == fsm_update_dr;
    assign capture_ir       = cur_jtag_state == fsm_capture_ir;
    assign shift_ir         = cur_jtag_state == fsm_shift_ir;
    assign update_ir        = cur_jtag_state == fsm_update_ir;

endmodule
