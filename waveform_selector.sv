
// ============================================================
// WAVEFORM SELECTOR - waveform_selector.sv
// ============================================================
module waveform_selector (
    input  wire [15:0] sine_in,
    input  wire [15:0] square_in,
    input  wire [15:0] triangle_in,
    input  wire [15:0] sawtooth_in,
    input  wire [15:0] ecg_in,
    input  wire [2:0]  waveform_sel,
    output reg  [15:0] wave_out
);
    always @(*) begin
        case (waveform_sel)
            3'b000: wave_out = sine_in;     // Sine
            3'b001: wave_out = square_in;   // Square
            3'b010: wave_out = triangle_in; // Triangle
            3'b011: wave_out = sawtooth_in; // Sawtooth
            3'b100: wave_out = ecg_in;      // ECG
            default: wave_out = 16'd0;      // Silence
        endcase
    end
endmodule