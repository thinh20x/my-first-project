// ============================================================
// TOP MODULE - lab1.sv (CORRECTED)
// ============================================================
module lab1 (
    // Clock and Reset
    input  wire        OSC_50_B8A,     // 50MHz clock
    input  wire [3:0]  KEY,            // Push buttons (active low)
    input  wire [9:0]  SW,             // Switches
    
    // LED outputs for debug
    output wire [9:0]  LED,
    
    // Audio CODEC interface
    output wire        AUD_XCK,        // Audio master clock
    output wire        AUD_BCLK,       // Audio bit clock
    output wire        AUD_DACDAT,     // Audio DAC data
    output wire        AUD_DACLRCK,    // Audio DAC LR clock
    input  wire        AUD_ADCDAT,     // Audio ADC data (unused)
    output wire        AUD_ADCLRCK,    // Audio ADC LR clock (unused)
    
    // I2C interface for CODEC configuration
    output wire        AUD_I2C_SCLK,   // I2C clock
    inout  wire        AUD_I2C_SDAT    // I2C data
);

    // ================================
    // Clock and Reset Management
    // ================================
    wire clk_50m = OSC_50_B8A;
    wire reset_n = KEY[0];
    wire reset = ~reset_n;
    
    // PLL for audio clock generation
    wire audio_clk;
    
    clock_pll audio_pll (
        .refclk(clk_50m),
        .rst(reset),
        .freq_sel(2'b01),        // Fixed for 12.288MHz audio
        .outclk_0(audio_clk),    // ~12MHz audio clock
        .outclk_1()              // Unused
    );
    
    assign AUD_XCK = audio_clk;

    // ================================
    // Control Signal Processing (theo yêu cầu prelab1)
    // ================================
    wire [2:0] waveform_sel = SW[2:0];    // SW[2:0]: waveform selection
    wire [1:0] freq_sel = SW[6:5];        // SW[6:5]: frequency selection  
    wire [1:0] amp_sel = SW[4:3];         // SW[4:3]: amplitude selection
    wire noise_enable = SW[7];            // SW[7]: noise enable
    wire noise_amp_sel = SW[8];           // SW[8]: noise amplitude
    wire noise_freq_sel = SW[9];          // SW[9]: noise frequency
    
    // Button debouncing for duty cycle control (KEY[2])
    wire duty_button_clean;
    button_debouncer duty_debounce (
        .clk(clk_50m),
        .reset(reset),
        .button_in(~KEY[2]),      // KEY[2] for duty cycle
        .button_clean(duty_button_clean)
    );
    
    // Duty cycle counter (cycles through 25%, 50%, 75%)
    reg [1:0] duty_cycle = 2'b01;  // Start with 50%
    wire duty_edge;
    
    edge_detector duty_edge_det (
        .clk(clk_50m),
        .signal_in(duty_button_clean),
        .edge_pulse(duty_edge)
    );
    
    always @(posedge clk_50m or posedge reset) begin
        if (reset)
            duty_cycle <= 2'b01; // Start with 50%
        else if (duty_edge)
            duty_cycle <= duty_cycle + 1'b1;
    end

    // ================================
    // Frequency Control
    // ================================
    wire [15:0] phase_step;
    frequency_controller freq_ctrl (
        .freq_sel(freq_sel),
        .phase_step(phase_step)
    );

    // ================================
    // Waveform Generators
    // ================================
    wire [15:0] sine_out, square_out, triangle_out, sawtooth_out, ecg_out;
    
    sine_wave sine_gen (
        .clk(clk_50m),
        .reset(reset),
        .step(phase_step),
        .wave_out(sine_out)
    );
    
    square_wave square_gen (
        .clk(clk_50m),
        .reset(reset),
        .step(phase_step),
        .duty(duty_cycle),
        .wave_out(square_out)
    );
    
    triangle_wave triangle_gen (
        .clk(clk_50m),
        .reset(reset),
        .step(phase_step),
        .wave_out(triangle_out)
    );
    
    sawtooth_wave sawtooth_gen (
        .clk(clk_50m),
        .reset(reset),
        .step(phase_step),
        .wave_out(sawtooth_out)
    );
    
    ecg_wave ecg_gen (
        .clk(clk_50m),
        .reset(reset),
        .step(phase_step),
        .wave_out(ecg_out)
    );

    // ================================
    // Waveform Selection
    // ================================
    wire [15:0] selected_wave;
    waveform_selector wave_sel (
        .sine_in(sine_out),
        .square_in(square_out),
        .triangle_in(triangle_out),
        .sawtooth_in(sawtooth_out),
        .ecg_in(ecg_out),
        .waveform_sel(waveform_sel),
        .wave_out(selected_wave)
    );

    // ================================
    // Amplitude Control
    // ================================
    wire [15:0] amplitude_controlled;
    amplitude_controller amp_ctrl (
        .wave_in(selected_wave),
        .amp_sel(amp_sel),
        .wave_out(amplitude_controlled)
    );

    // ================================
    // Noise Generation and Mixing
    // ================================
    wire [15:0] noise_out;
    noise_generator noise_gen (
        .clk(clk_50m),
        .reset(reset),
        .enable(noise_enable),
        .noise_level({noise_freq_sel, noise_amp_sel}),
        .noise_out(noise_out)
    );
    
    wire [15:0] mixed_audio;
    audio_mixer mixer (
        .signal_in(amplitude_controlled),
        .noise_in(noise_out),
        .noise_enable(noise_enable),
        .mixed_out(mixed_audio)
    );

    // ================================
    // Audio Interface
    // ================================
    audio_codec_interface audio_if (
        .clk(audio_clk),
        .reset(reset),
        .pcm_in(mixed_audio),
        .AUD_BCLK(AUD_BCLK),
        .AUD_DACDAT(AUD_DACDAT),
        .AUD_DACLRCK(AUD_DACLRCK)
    );

    // ================================
    // I2C Configuration
    // ================================
    wire [3:0] i2c_status;
    i2c_av_config i2c_config (
        .clk(clk_50m),
        .reset(reset),
        .i2c_sclk(AUD_I2C_SCLK),
        .i2c_sdat(AUD_I2C_SDAT),
        .status(i2c_status)
    );

    // ================================
    // Status and Debug LEDs (theo yêu cầu prelab1)
    // ================================
    assign LED[3:0] = i2c_status;           // I2C configuration status
    assign LED[6:4] = waveform_sel;         // Current waveform
    assign LED[7] = noise_enable;           // Noise enable status
    assign LED[8] = |mixed_audio[15:14];    // Audio activity indicator
    assign LED[9] = duty_edge;              // Duty cycle change indicator
    
    assign AUD_ADCLRCK = 1'b0; // Unused

endmodule