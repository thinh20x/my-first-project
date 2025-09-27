// sawtooth_wave.sv
// Directly use phase accumulator top 16 bits as sawtooth
module sawtooth_wave (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] step,
    output reg  [15:0] wave_out
);
    reg [31:0] phase_acc;

    always @(posedge clk or posedge reset) begin
        if (reset) phase_acc <= 0;
        else phase_acc <= phase_acc + {16'd0, step};
    end

    always @(posedge clk) begin
        wave_out <= phase_acc[31:16]; // rising ramp
    end
endmodule
