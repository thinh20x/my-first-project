// ============================================================
// CLOCK PLL - clock_pll.v
// ============================================================
module clock_pll (
    input  wire        refclk,     // Input clock (50 MHz từ OSC_50_B8A)
    input  wire        rst,        // Reset signal
    input  wire [1:0]  freq_sel,   // Frequency selection (for future use)
    output wire        outclk_0,   // Audio clock (12.288 MHz)
    output wire        outclk_1    // Main clock (50 MHz passthrough)
);

// Simple clock divider implementation
// For proper implementation, use Quartus PLL IP
reg [7:0] div_counter = 8'd0;
reg clk_div = 1'b0;

// Divide 50MHz by ~4 to get approximately 12.5MHz
// For exact 12.288MHz, you should use Quartus PLL IP
always @(posedge refclk or posedge rst) begin
    if (rst) begin
        div_counter <= 8'd0;
        clk_div <= 1'b0;
    end else begin
        if (div_counter >= 8'd1) begin // Divide by 4 approximately
            div_counter <= 8'd0;
            clk_div <= ~clk_div;
        end else begin
            div_counter <= div_counter + 1'b1;
        end
    end
end

// Output assignments
assign outclk_0 = clk_div;     // ~12.5 MHz (use PLL IP for exact 12.288MHz)
assign outclk_1 = refclk;      // 50 MHz passthrough

endmodule

// ============================================================
// NOTE: For production design, replace this with Quartus PLL IP:
// 
// 1. Open Quartus Prime
// 2. Tools -> IP Catalog
// 3. Search for "PLL"
// 4. Select "FPGA PLL (Phase Locked Loop)"
// 5. Configure:
//    - Reference clock: 50 MHz
//    - Output clock 0: 12.288 MHz
//    - Output clock 1: 50 MHz (optional)
// 6. Generate and instantiate the IP
// ============================================================