library verilog;
use verilog.vl_types.all;
entity i2c_av_config is
    generic(
        LAST_INDEX      : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        i2c_sclk        : out    vl_logic;
        i2c_sdat        : inout  vl_logic;
        status          : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of LAST_INDEX : constant is 1;
end i2c_av_config;
