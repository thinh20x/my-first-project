module lab1_top (
    input  wire CLOCK_50,
    input  wire [3:0] KEY,
    input  wire [9:0] SW,
    output wire [9:0] LED,
    // Audio interface
    output wire AUD_XCK,
    output wire AUD_BCLK,
    output wire AUD_DACDAT,
    output wire AUD_DACLRCK,
    inout  wire I2C_SDAT,
    output wire I2C_SCLK
);

    // ==================================
    // PLL for Audio Clock
    // ==================================
    wire audio_clk;
    pll pll_inst (
        .refclk(CLOCK_50),
        .rst(~KEY[0]),
        .outclk_0(audio_clk),   // 12.288 MHz
        .locked()
    );
    assign AUD_XCK = audio_clk;

    // ==================================
    // Phase step control (frequency adjust)
    // ==================================
    reg [15:0] step;
    always @(posedge CLOCK_50 or negedge KEY[0]) begin
        if (!KEY[0]) step <= 16'd128;
        else begin
            if (!KEY[1]) step <= step + 16'd16; // freq up
            if (!KEY[2]) step <= step - 16'd16; // freq down
        end
    end

    // ==================================
    // Waveform generators
    // ==================================
    wire [15:0] sine_out, tri_out, saw_out, sq_out, ecg_out;

    sine_wave sine_gen(.clk(CLOCK_50), .reset(~KEY[0]), .step(step), .wave_out(sine_out));
    triangle_wave tri_gen(.clk(CLOCK_50), .reset(~KEY[0]), .step(step), .wave_out(tri_out));
    sawtooth_wave saw_gen(.clk(CLOCK_50), .reset(~KEY[0]), .step(step), .wave_out(saw_out));
    square_wave sq_gen(.clk(CLOCK_50), .reset(~KEY[0]), .step(step), .duty(SW[5:4]), .wave_out(sq_out));
    ecg_wave ecg_gen(.clk(CLOCK_50), .reset(~KEY[0]), .step(step), .wave_out(ecg_out));

    reg [15:0] wave_sel;
    always @(*) begin
        case (SW[3:1])
            3'b000: wave_sel = sine_out;
            3'b001: wave_sel = sq_out;
            3'b010: wave_sel = ecg_out;
            3'b011: wave_sel = tri_out;
            3'b110: wave_sel = saw_out;
            default: wave_sel = sine_out;
        endcase
    end

    // ==================================
    // Amplitude scaling
    // ==================================
    reg [15:0] amp_out;
    always @(*) begin
        case (SW[7:6])
            2'b00: amp_out = wave_sel;                // 100%
            2'b01: amp_out = wave_sel >>> 1;          // 50%
            2'b10: amp_out = (wave_sel * 3) >>> 2;    // 75%
            2'b11: amp_out = wave_sel >>> 2;          // 25%
        endcase
    end

    // ==================================
    // Noise injection
    // ==================================
    wire [15:0] noise;
    noise_generator noise_inst(
        .clk(CLOCK_50),
        .reset(~KEY[0]),
        .enable(SW[9]),
        .noise_level(SW[9:8]),
        .noise_out(noise)
    );

    wire [15:0] audio_data = amp_out + noise;

    // ==================================
    // Codec interface
    // ==================================
    audio_codec_interface audio_if (
        .clk(audio_clk),
        .reset(~KEY[0]),
        .pcm_in(audio_data),
        .AUD_BCLK(AUD_BCLK),
        .AUD_DACDAT(AUD_DACDAT),
        .AUD_DACLRCK(AUD_DACLRCK)
    );

    // ==================================
    // I2C config for WM8731
    // ==================================
    i2c_controller i2c_cfg (
        .clk(CLOCK_50),
        .reset(~KEY[0]),
        .scl(I2C_SCLK),
        .sda(I2C_SDAT)
    );

    assign LED = SW;

endmodule
