// ============================================================
// SAWTOOTH WAVE GENERATOR - sawtooth_wave.v
// ============================================================
module sawtooth_wave (
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

    // Output sawtooth wave (rising ramp)
    always @(posedge clk) begin
        wave_out <= phase_acc; // Direct use of phase accumulator
    end
endmodule