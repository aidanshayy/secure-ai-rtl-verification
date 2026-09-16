`timescale 1ns/1ps

module d_ff(
    input  logic clk,
    input  logic rst_n,
    input  logic d,
    output logic q
);

    // Synchronous active-low reset.
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            q <= 1'b0;
        end else begin
            q <= d;
        end
    end

endmodule
