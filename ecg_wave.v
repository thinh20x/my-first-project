// ecg_wave.sv
// ROM-based ECG sample playback. Reads ecg_lut.hex
module ecg_wave (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] step,
    output reg  [15:0] wave_out
);
    reg [31:0] phase_acc;
    localparam LUT_BITS = 8; // 256 entries
    localparam LUT_DEPTH = (1 << LUT_BITS);
    reg signed [15:0] ecg_rom [0:LUT_DEPTH-1];

    initial begin
        $readmemh("ecg_lut.hex", ecg_rom);
    end

    always @(posedge clk or posedge reset) begin
        if (reset) phase_acc <= 0;
        else phase_acc <= phase_acc + {16'd0, step};
    end

    wire [LUT_BITS-1:0] idx = phase_acc[31:32-LUT_BITS];
    always @(posedge clk) begin
        wave_out <= ecg_rom[idx];
    end
endmodule
