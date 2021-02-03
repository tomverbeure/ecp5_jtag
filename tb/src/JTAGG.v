`default_nettype none

module JTAGG (
        input  wire TCK, 
        input  wire TMS,
        input  wire TDI,
        output wire TDO,
    
        output wire JTCK, 
        output reg  JTDI, 
        output wire JSHIFT, 
        output wire JUPDATE, 
        output reg  JRSTN,
        output wire JCE1, 
        output wire JCE2, 
        output wire JRTI1, 
        output wire JRTI2, 
        input  wire JTDO1, 
        input  wire JTDO2
    );

    parameter ER1 = "ENABLED";
    parameter ER2 = "ENABLED";

    wire test_logic_reset;
    wire run_test_idle;
    wire capture_ir, shift_ir, update_ir;
    wire capture_dr, shift_dr, update_dr;

    jtag_tap u_jtag_tap(
        .tck(TCK), 
        .tms(TMS), 
        .tdi(TDI), 
        .test_logic_reset(test_logic_reset),
        .run_test_idle(run_test_idle),
        .capture_ir(capture_ir),
        .shift_ir(shift_ir),
        .update_ir(update_ir),
        .capture_dr(capture_dr),
        .shift_dr(shift_dr),
        .update_dr(update_dr)
    );

    reg [7:0] ir_shift_reg, ir_shadow_reg;

    always @(posedge TCK or posedge test_logic_reset) begin
        if (test_logic_reset) begin
            ir_shift_reg    <= 8'h00;
            ir_shadow_reg   <= 8'h00;
        end
        else begin
            if (capture_ir) begin
                ir_shift_reg    <= ir_shadow_reg;
            end
    
            if (shift_ir) begin
                ir_shift_reg    <= { TDI, ir_shift_reg[7:1] };
            end
    
            if (update_ir) begin
                ir_shadow_reg   <= ir_shift_reg;
            end
        end
    end

    always @(posedge TCK) begin
        JTDI    <= TDI;
    end

    reg tdo_reg;
    reg drive_tdo;

    always @(negedge TCK) begin
        drive_tdo   <= shift_ir || shift_dr;

        if (shift_ir) begin
            tdo_reg     <= ir_shadow_reg[0];
        end
        else if (shift_dr && ir_shadow_reg == 8'h32) begin
            tdo_reg     <= JTDO1;
        end
        else if (shift_dr && ir_shadow_reg == 8'h38) begin
            tdo_reg     <= JTDO2;
        end

        JRSTN   <= !test_logic_reset;
    end

    assign TDO  = drive_tdo ? tdo_reg : 1'bz;

    assign JTCK     = TCK;
    assign JSHIFT   = shift_dr  && (ir_shadow_reg == 8'h32 || ir_shadow_reg == 8'h38);
    assign JUPDATE  = update_dr && (ir_shadow_reg == 8'h32 || ir_shadow_reg == 8'h38);
    assign JCE1     = (capture_dr || shift_dr) && (ir_shadow_reg == 8'h32);
    assign JCE2     = (capture_dr || shift_dr) && (ir_shadow_reg == 8'h38);
    assign JRTI1    = run_test_idle && (ir_shadow_reg == 8'h32);
    assign JRTI2    = run_test_idle && (ir_shadow_reg == 8'h38);

endmodule
