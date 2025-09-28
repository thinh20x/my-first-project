// ============================================================
// AUDIO CODEC INTERFACE - audio_codec_interface.v
// ============================================================
module audio_codec_interface (
    input  wire        clk,        // 12.288 MHz MCLK
    input  wire        reset,
    input  wire [15:0] pcm_in,     // 16-bit PCM sample
    output reg         AUD_BCLK,   // Bit clock (1.536 MHz)
    output reg         AUD_DACDAT, // Serial audio data
    output reg         AUD_DACLRCK // Left/Right clock (48 kHz)
);
    // Clock dividers for I2S timing
    // MCLK = 12.288 MHz, BCLK = 1.536 MHz (div by 8), LRCK = 48 kHz (div by 256)
    
    reg [2:0] bclk_counter = 3'd0;
    reg [7:0] lrck_counter = 8'd0;
    reg [4:0] bit_counter = 5'd0;
    reg [15:0] shift_register = 16'd0;
    reg lrck_reg = 1'b0;
    
    // Generate BCLK (divide MCLK by 8)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bclk_counter <= 3'd0;
            AUD_BCLK <= 1'b0;
        end else begin
            bclk_counter <= bclk_counter + 1'b1;
            if (bclk_counter == 3'd3) begin
                AUD_BCLK <= ~AUD_BCLK;
                bclk_counter <= 3'd0;
            end
        end
    end
    
    // Generate LRCK and handle data transmission
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lrck_counter <= 8'd0;
            bit_counter <= 5'd0;
            shift_register <= 16'd0;
            AUD_DACLRCK <= 1'b0;
            AUD_DACDAT <= 1'b0;
            lrck_reg <= 1'b0;
        end else if (bclk_counter == 3'd3 && AUD_BCLK == 1'b0) begin // Rising edge of BCLK
            lrck_counter <= lrck_counter + 1'b1;
            
            // Generate LRCK (48 kHz)
            if (lrck_counter == 8'hFF) begin
                lrck_reg <= ~lrck_reg;
                AUD_DACLRCK <= lrck_reg;
                
                // Load new sample at the beginning of each frame
                shift_register <= pcm_in;
                bit_counter <= 5'd15; // Start with MSB
            end else begin
                // Shift out data MSB first
                if (bit_counter > 5'd0) begin
                    AUD_DACDAT <= shift_register[bit_counter];
                    bit_counter <= bit_counter - 1'b1;
                end else begin
                    AUD_DACDAT <= 1'b0;
                end
            end
        end
    end
endmodule