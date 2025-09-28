// ============================================================
// FREQUENCY CONTROLLER - frequency_controller.sv
// ============================================================
module frequency_controller (
    input  wire [1:0]  freq_sel,
    output reg  [15:0] phase_step
);
    // Calculate phase step for different frequencies
    // For 50MHz clock and target frequencies:
    // step = (target_freq * 2^16) / 50MHz
    always @(*) begin
        case (freq_sel)
            2'b00: phase_step = 16'd2048;  // ~1.5625 kHz
            2'b01: phase_step = 16'd4096;  // ~3.125 kHz  
            2'b10: phase_step = 16'd8192;  // ~6.25 kHz
            2'b11: phase_step = 16'd16384; // ~12.5 kHz
            default: phase_step = 16'd4096;
        endcase
    end
endmodule


// ============================================================
// AMPLITUDE CONTROLLER - amplitude_controller.sv
// ============================================================
module amplitude_controller (
    input  wire [15:0] wave_in,
    input  wire [1:0]  amp_sel,
    output reg  [15:0] wave_out
);
    always @(*) begin
        case (amp_sel)
            2'b00: wave_out = wave_in >>> 2;           // 25%
            2'b01: wave_out = wave_in >>> 1;           // 50%
            2'b10: wave_out = (wave_in >>> 1) + (wave_in >>> 2); // 75%
            2'b11: wave_out = wave_in;                 // 100%
            default: wave_out = wave_in >>> 1;
        endcase
    end
endmodule

// ============================================================
// AUDIO MIXER - audio_mixer.sv
// ============================================================
module audio_mixer (
    input  wire [15:0] signal_in,
    input  wire [15:0] noise_in,
    input  wire        noise_enable,
    output wire [15:0] mixed_out
);
    wire signed [16:0] sum = $signed(signal_in) + $signed(noise_in);
    
    // Saturation to prevent overflow
    assign mixed_out = noise_enable ? 
                       ((sum > $signed(16'h7FFF)) ? 16'h7FFF :
                        (sum < $signed(16'h8000)) ? 16'h8000 : sum[15:0]) :
                       signal_in;
endmodule

// ============================================================
// BUTTON DEBOUNCER - button_debouncer.sv
// ============================================================
module button_debouncer #(
    parameter DEBOUNCE_TIME = 20 // 20ms at 50MHz
)(
    input  wire clk,
    input  wire reset,
    input  wire button_in,
    output reg  button_clean
);
    localparam COUNT_MAX = DEBOUNCE_TIME * 50000; // 50MHz clock
    
    reg [19:0] counter = 20'd0;
    reg button_sync = 1'b0;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 20'd0;
            button_sync <= 1'b0;
            button_clean <= 1'b0;
        end else begin
            button_sync <= button_in;
            
            if (button_sync == button_clean) begin
                counter <= 20'd0;
            end else begin
                counter <= counter + 1'b1;
                if (counter >= COUNT_MAX) begin
                    button_clean <= button_sync;
                    counter <= 20'd0;
                end
            end
        end
    end
endmodule

// ============================================================
// EDGE DETECTOR - edge_detector.sv
// ============================================================
module edge_detector (
    input  wire clk,
    input  wire signal_in,
    output wire edge_pulse
);
    reg signal_d1 = 1'b0;
    
    always @(posedge clk) begin
        signal_d1 <= signal_in;
    end
    
    assign edge_pulse = signal_in & ~signal_d1; // Rising edge
endmodule