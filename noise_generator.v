// ============================================================
// NOISE GENERATOR - noise_generator.v
// ============================================================
module noise_generator (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire [1:0]  noise_level,
    output reg  [15:0] noise_out
);
    // 16-bit Linear Feedback Shift Register
    reg [15:0] lfsr = 16'hACE1; // Non-zero seed
    wire feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];
    
    // Noise frequency control
    reg [7:0] noise_counter = 8'd0;
    wire noise_update = (noise_counter == 8'd255);
    
    // LFSR update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 16'hACE1;
            noise_counter <= 8'd0;
        end else begin
            noise_counter <= noise_counter + 1'b1;
            
            if (noise_update) begin
                lfsr <= {lfsr[14:0], feedback};
            end
        end
    end
    
    // Scale noise amplitude
    always @(*) begin
        if (!enable) begin
            noise_out = 16'd0;
        end else begin
            case (noise_level)
                2'b00: noise_out = 16'd0;                          // Off
                2'b01: noise_out = {1'b0, lfsr[14:0]} >>> 3;       // Low (12.5%)
                2'b10: noise_out = {1'b0, lfsr[14:0]} >>> 2;       // Medium (25%)
                2'b11: noise_out = {1'b0, lfsr[14:0]} >>> 1;       // High (50%)
                default: noise_out = 16'd0;
            endcase
        end
    end
endmodule