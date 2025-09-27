library verilog;
use verilog.vl_types.all;
entity lab1 is
    port(
        OSC_50_B8A      : in     vl_logic;
        AUD_ADCLRCK     : inout  vl_logic;
        AUD_ADCDAT      : in     vl_logic;
        AUD_DACLRCK     : inout  vl_logic;
        AUD_DACDAT      : out    vl_logic;
        AUD_XCK         : out    vl_logic;
        AUD_BCLK        : inout  vl_logic;
        AUD_I2C_SCLK    : out    vl_logic;
        AUD_I2C_SDAT    : inout  vl_logic;
        AUD_MUTE        : out    vl_logic;
        KEY             : in     vl_logic_vector(3 downto 0);
        SW              : in     vl_logic_vector(9 downto 0);
        LED             : out    vl_logic_vector(3 downto 0)
    );
end lab1;
