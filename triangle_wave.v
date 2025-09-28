// ============================================================
// TRIANGLE WAVE GENERATOR - triangle_wave.v
// ============================================================
module triangle_wave (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] step,
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

    // Generate triangle wave
    always @(posedge clk) begin
        if (phase_acc[15] == 1'b0) begin
            // Rising half: 0 to 7FFF
            wave_out <= {1'b0, phase_acc[14:0]};
        end else begin
            // Falling half: 7FFF to 0 (inverted)
            wave_out <= {1'b0, ~phase_acc[14:0]};
        end
    end
endmodule