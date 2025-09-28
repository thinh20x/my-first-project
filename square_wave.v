// ============================================================
// SQUARE WAVE GENERATOR - square_wave.v
// ============================================================
module square_wave (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] step,
    input  wire [1:0]  duty,
    output reg  [15:0] wave_out
);
    reg [15:0] phase_acc;

    // Phase accumulator
    always @(posedge clk or posedge reset) begin
        if (reset) 
            phase_acc <= 16'd0;
        else 
            phase_acc <= phase_acc + step;
    end

    // Generate square wave with variable duty cycle
    always @(*) begin
        case(duty)
            2'b00: wave_out = (phase_acc[15:8] < 8'd64)  ? 16'h7FFF : 16'h8000; // 25%
            2'b01: wave_out = (phase_acc[15:8] < 8'd128) ? 16'h7FFF : 16'h8000; // 50%
            2'b10: wave_out = (phase_acc[15:8] < 8'd192) ? 16'h7FFF : 16'h8000; // 75%
            2'b11: wave_out = (phase_acc[15:8] < 8'd230) ? 16'h7FFF : 16'h8000; // 90%
        endcase
    end
endmodule