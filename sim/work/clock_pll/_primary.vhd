library verilog;
use verilog.vl_types.all;
entity clock_pll is
    port(
        refclk          : in     vl_logic;
        rst             : in     vl_logic;
        freq_sel        : in     vl_logic_vector(1 downto 0);
        outclk_0        : out    vl_logic;
        outclk_1        : out    vl_logic
    );
end clock_pll;
