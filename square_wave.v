module square_wave (
    input  wire clk,
    input  wire reset,
    input  wire [15:0] step,
    input  wire [1:0] duty,
    output reg  [15:0] wave_out
);
    reg [15:0] phase_acc;

    always @(posedge clk or posedge reset) begin
        if (reset) phase_acc <= 0;
        else phase_acc <= phase_acc + step;
    end

    always @(*) begin
        case(duty)
            2'b00: wave_out = (phase_acc[15:8] < 64)  ? 16'h7FFF : 16'h8000; // 25%
            2'b01: wave_out = (phase_acc[15:8] < 128) ? 16'h7FFF : 16'h8000; // 50%
            2'b10: wave_out = (phase_acc[15:8] < 192) ? 16'h7FFF : 16'h8000; // 75%
            2'b11: wave_out = (phase_acc[15:8] < 230) ? 16'h7FFF : 16'h8000; // 90%
        endcase
    end
endmodule
