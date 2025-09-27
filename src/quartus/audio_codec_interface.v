// audio_codec_interface.sv
// I2S transmitter: take 16-bit PCM samples (mono duplicated to both channels) and
// send to WM8731 via BCLK and LRCK.
// Assumptions:
//  - clk is MCLK (audio master clock), e.g. 12.288 MHz (MCLK). We derive BCLK and LRCK by divide.
//  - Word length 16 bits, I2S format (MSB first, data valid on falling edge depending).
module audio_codec_interface (
    input  wire        clk,        // MCLK (from PLL)
    input  wire        reset,
    input  wire [15:0] pcm_in,     // 16-bit sample
    output reg         AUD_BCLK,
    output reg         AUD_DACDAT,
    output reg         AUD_DACLRCK
);
    // Parameters to generate standard BCLK (32 * Fs) from MCLK.
    // If MCLK = 12.288 MHz and Fs=48k -> BCLK = 1.536 MHz, MCLK/BCLK = 8
    // We'll use a divider of 8 for BCLK (adjust if you use different PLL).
    localparam integer MCLK_TO_BCLK = 8;
    integer mcnt;
    reg bclk_r; // internal bclk
    reg [5:0] bitcnt;
    reg [15:0] shift_reg;
    reg lr; // left/right indicator: 0 = left, 1 = right

    initial begin
        mcnt = 0; bclk_r = 0; bitcnt = 0; shift_reg = 0; lr = 0;
        AUD_BCLK = 0; AUD_DACDAT = 0; AUD_DACLRCK = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mcnt <= 0;
            bclk_r <= 0;
            bitcnt <= 0;
            shift_reg <= 0;
            AUD_BCLK <= 0;
            AUD_DACDAT <= 0;
            AUD_DACLRCK <= 0;
            lr <= 0;
        end else begin
            // divide MCLK to BCLK
            if (mcnt == (MCLK_TO_BCLK/2 - 1)) begin
                mcnt <= 0;
                bclk_r <= ~bclk_r;
            end else mcnt <= mcnt + 1;

            AUD_BCLK <= bclk_r;

            // On rising edge of BCLK, shift data out (MSB first). We'll latch new sample at start of frame.
            if (bclk_r == 1'b1) begin
                if (bitcnt == 0) begin
                    // start of 32-bit frame: load left channel sample
                    shift_reg <= pcm_in;
                    AUD_DACLRCK <= lr; // LRCK toggles at frame boundary (we present it)
                    // LRCK low -> left, high -> right. We'll set lr toggled every 16 bits.
                    AUD_DACDAT <= shift_reg[15];
                    bitcnt <= 1;
                end else begin
                    AUD_DACDAT <= shift_reg[15];
                    shift_reg <= {shift_reg[14:0], 1'b0};
                    bitcnt <= bitcnt + 1;
                    if (bitcnt == 16) begin
                        // after 16 bits, switch to right channel: reuse same pcm_in (mono)
                        shift_reg <= pcm_in;
                        lr <= ~lr;
                        AUD_DACLRCK <= lr;
                        bitcnt <= 1;
                    end
                end
            end
        end
    end
endmodule
