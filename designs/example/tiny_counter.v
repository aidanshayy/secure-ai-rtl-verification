module tiny_counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    output reg  [3:0] count,
    output wire       rollover
);

assign rollover = enable && (count == 4'hf);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 4'h0;
    end else if (enable) begin
        count <= count + 4'h1;
    end
end

endmodule
