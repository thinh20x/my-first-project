module sine_wave (
    input  wire clk,
    input  wire reset,
    input  wire [15:0] step,
    output reg  [15:0] wave_out
);
    reg [15:0] phase_acc;
    reg [15:0] sine_rom [0:255];

    initial $readmemh("sine_lut.hex", sine_rom);

    always @(posedge clk or posedge reset) begin
        if (reset) phase_acc <= 0;
        else phase_acc <= phase_acc + step;
    end

    always @(posedge clk) begin
        wave_out <= sine_rom[phase_acc[15:8]];
    end
endmodule
