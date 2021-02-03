`default_nettype none

module tb;

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb);
    end

    reg tck, tms, tdi;
    wire tdo;
    wire led0;

    Ecp5JtagDemo u_dut(
        .led0(led0),
        .tck(tck),
        .tms(tms),
        .tdi(tdi),
        .tdo(tdo) 
    );

    task tck_toggle;
    begin
        #10 tck = 1;
        #10 tck = 0;
    end
    endtask

    task jtag_reset;
    begin
        tms     <= 1;
        repeat(5) 
            tck_toggle;
    end
    endtask

    integer i;

    task jtag_shift_ir(input [7:0] ir);
    begin
        for(i=0;i<8;i=i+1) begin
            tms     <= 0;
            tdi     <= ir[i];

            if (i==7) begin
                tms <= 1;
            end
            tck_toggle;
            tdi     <= 1'bz;
        end
    end
    endtask

    initial begin
        tdi     <= 1'bz;
        tms     <= 0;
        repeat(20)
            tck_toggle;

        jtag_reset;

        #200;

        // TLR to SHIFT-IR
        tms     <= 0;
        tck_toggle;
        tms     <= 1;
        tck_toggle;
        tms     <= 1;
        tck_toggle;
        tms     <= 0;
        tck_toggle;
        tms     <= 0;
        tck_toggle;

        // Shift 8 bits, then move to EXIT1-IR
        jtag_shift_ir(8'h32);

        // EXIT1-IR to SHIFT-DR
        tms     <= 1;
        tck_toggle;
        tms     <= 1;
        tck_toggle;
        tms     <= 0;
        tck_toggle;
        tms     <= 0;
        tck_toggle;

        // Shift 1 into LED, then move to EXIT1-DR
        tdi     <= 1;
        tms     <= 1;
        tck_toggle;
        tdi     <= 1'bz;

        // EXIT1-DR to SHIFT-DR
        tms     <= 1;
        tck_toggle;
        tms     <= 1;
        tck_toggle;
        tms     <= 0;
        tck_toggle;
        tms     <= 0;
        tck_toggle;

        // Shift 0 into LED, then move to EXIT1-DR
        tdi     <= 0;
        tms     <= 1;
        tck_toggle;
        tdi     <= 1'bz;

        // EXIT1-DR to SHIFT-DR
        tms     <= 1;
        tck_toggle;
        tms     <= 1;
        tck_toggle;
        tms     <= 0;
        tck_toggle;
        tms     <= 0;
        tck_toggle;

        // Shift 1 into LED, then move to EXIT1-DR
        tdi     <= 1;
        tms     <= 1;
        tck_toggle;
        tdi     <= 1'bz;

        // EXIT1-DR to TLR
        tms     <= 1;
        tck_toggle;
        tms     <= 1;
        tck_toggle;
        tms     <= 1;
        tck_toggle;
        tms     <= 1;
        tck_toggle;

        #1000;


        $finish;
    end

endmodule
