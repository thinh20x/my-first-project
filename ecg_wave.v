// ============================================================
// ECG WAVE GENERATOR - ecg_wave.v
// ============================================================
module ecg_wave (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] step,
    output reg  [15:0] wave_out
);
    reg [15:0] phase_acc;
    localparam LUT_BITS = 8; // 256 entries
    localparam LUT_DEPTH = (1 << LUT_BITS);
    reg signed [15:0] ecg_rom [0:LUT_DEPTH-1];

    // Initialize ROM with ECG LUT
    initial begin
        $readmemh("ecg_lut.hex", ecg_rom);
    end

    // Phase accumulator
    always @(posedge clk or posedge reset) begin
        if (reset) 
            phase_acc <= 16'd0;
        else 
            phase_acc <= phase_acc + step;
    end

    // Output ECG value from LUT
    wire [LUT_BITS-1:0] idx = phase_acc[15:8];
    always @(posedge clk) begin
        wave_out <= ecg_rom[idx];
    end
endmodule