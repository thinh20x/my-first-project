// noise_generator.sv
// 16-bit LFSR pseudo-random noise, scaled by level
module noise_generator (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire [1:0]  noise_level, // 00 none, 01 low, 10 mid, 11 high
    output reg  [15:0] noise_out
);
    reg [15:0] lfsr;

    always @(posedge clk or posedge reset) begin
        if (reset) lfsr <= 16'hABCD; // seed
        else lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end

    always @(*) begin
        if (!enable) noise_out = 16'd0;
        else begin
            case(noise_level)
                2'b01: noise_out = {1'b0, lfsr[14:0]} >>> 4; // low: /16
                2'b10: noise_out = {1'b0, lfsr[14:0]} >>> 3; // mid: /8
                2'b11: noise_out = {1'b0, lfsr[14:0]} >>> 2; // high: /4
                default: noise_out = 16'd0;
            endcase
        end
    end
endmodule
