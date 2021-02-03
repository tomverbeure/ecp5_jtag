`default_nettype none

`define DIAMOND

module Ecp5JtagDemo(
        output wire led0,

`ifdef DIAMOND
		input wire		tck,
		input wire 		tms,
		input wire		tdi,
		output wire 	tdo,
`endif
    
        output wire jtck,
        output wire jtdi,
        output wire jshift,
        output wire jupdate,
        output wire jrstn,
        output wire jce1,
        output wire jce2,
        output wire jrti1,
        output wire jrti2,
        output reg  jtdo1,
        output reg  jtdo2
    );

    JTAGG u_jtagg(
`ifdef DIAMOND
        .TCK(tck),
        .TMS(tms),
        .TDI(tdi),
        .TDO(tdo),
`endif
        .JTCK(jtck),
        .JTDI(jtdi),
        .JSHIFT(jshift),
        .JUPDATE(jupdate),
        .JRSTN(jrstn),
        .JCE1(jce1),
        .JCE2(jce2),
        .JRTI1(jrti1),
        .JRTI2(jrti2),
        .JTDO1(jtdo1),
        .JTDO2(jtdo2)
    );

    reg [0:0] dr_shift, dr_shift_nxt, dr_shadow, dr_shadow_nxt;
    reg jshift_dly;

    // TDI gets its value 1/2 clock cycle after the TAP goes into
    // Shift-DR. However, JTDI is reclocked on the posedge, so the first TDI
    // value arrives on JTDI 1 clock cycle after JSHIFT goes high.

    always @(*) begin
        dr_shift_nxt    = dr_shift;
        dr_shadow_nxt   = dr_shadow;

        jtdo1           = 0;
        jtdo2           = 0;

        if (jshift && !jshift_dly) begin
            // First cycle of JSHIFT being high. The first JTDI bit isn't
            // there yet, so ignore JTDI and only drive TDO.
            jtdo1           = dr_shift;
            jtdo2           = dr_shift;
        end
        else if (!jshift && jshift_dly) begin
            // TAP has just left Shift-DR state, but JTDI has the last bit, so
            // capture that.
            dr_shift_nxt    = jtdi;
        end
        else if (jshift) begin
            // In the middle of Shift-DR state. Capture JTDI.
            // JTDO is JTDI instead of dr_shift because otherwise, TDO would
            // have an additional delay.
            dr_shift_nxt    = jtdi;
            jtdo1           = jtdi;
            jtdo2           = jtdi;
        end

        if (jupdate) begin
            dr_shadow_nxt   = dr_shift;
        end

        if (jce1) begin
            dr_shift_nxt    = dr_shadow;
        end
    end

    always @(posedge jtck or negedge jrstn) begin
        if (!jrstn) begin
            jshift_dly  <= 0;
            dr_shift    <= 0;
            dr_shadow   <= 0;
        end
        else begin
            jshift_dly  <= jshift;
            dr_shift    <= dr_shift_nxt;
            dr_shadow   <= dr_shadow_nxt;
        end
    end

    assign led0 = dr_shift;

endmodule
