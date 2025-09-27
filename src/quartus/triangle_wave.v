// triangle_wave.sv
// Uses phase accumulator and maps to triangle shape
module triangle_wave (
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

    // map phase to triangle: use top 16 bits of phase
    wire [15:0] top = phase_acc[31:16];
    always @(posedge clk) begin
        if (top[15] == 1'b0) begin
            // rising half
            wave_out <= {1'b0, top[14:0]}; // scale as needed
        end else begin
            // falling half
            wave_out <= ~{1'b0, top[14:0]}; // invert
        end
    end
endmodule
