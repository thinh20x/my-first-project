library verilog;
use verilog.vl_types.all;
entity i2c_controller is
    generic(
        LAST_STAGE      : vl_logic_vector(0 to 4) := (Hi1, Hi1, Hi1, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        i2c_sclk        : out    vl_logic;
        i2c_sdat        : inout  vl_logic;
        start           : in     vl_logic;
        done            : out    vl_logic;
        ack             : out    vl_logic;
        i2c_data        : in     vl_logic_vector(23 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of LAST_STAGE : constant is 1;
end i2c_controller;
