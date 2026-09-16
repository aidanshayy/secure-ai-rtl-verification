`timescale 1ns/1ps

module tb;

    logic clk;
    logic rst_n;
    logic d;
    logic q;

    d_ff dut (
        .clk   (clk),
        .rst_n (rst_n),
        .d     (d),
        .q     (q)
    );

    // Ten time units per clock period.
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Begin in reset.
        rst_n = 1'b0;
        d     = 1'b0;

        @(posedge clk);
        #1;
        if (q !== 1'b0) $fatal(1, "Reset failed: q is not 0");

        // Release reset and capture a 1.
        @(negedge clk);
        rst_n = 1'b1;
        d     = 1'b1;

        @(posedge clk);
        #1;
        if (q !== 1'b1) $fatal(1, "Data capture failed: q is not 1");

        // Capture a 0 on the next rising edge.
        @(negedge clk);
        d = 1'b0;

        @(posedge clk);
        #1;
        if (q !== 1'b0) $fatal(1, "Data capture failed: q is not 0");

        // Assert reset again and confirm it dominates d at the clock edge.
        @(negedge clk);
        rst_n = 1'b0;
        d     = 1'b1;

        @(posedge clk);
        #1;
        if (q !== 1'b0) $fatal(1, "Second reset failed: q is not 0");

        // Release reset and confirm normal operation resumes.
        @(negedge clk);
        rst_n = 1'b1;

        @(posedge clk);
        #1;
        if (q !== 1'b1) $fatal(1, "Post-reset capture failed: q is not 1");

        $display("PASS: d_ff reset and data-capture checks completed");
        $finish;
    end

endmodule
