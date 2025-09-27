library verilog;
use verilog.vl_types.all;
entity triangle_wave is
    generic(
        SINE            : integer := 0;
        FEEDBACK        : integer := 1
    );
    port(
        clk             : in     vl_logic;
        sample_end      : in     vl_logic;
        sample_req      : in     vl_logic;
        audio_output    : out    vl_logic_vector(15 downto 0);
        audio_input     : in     vl_logic_vector(15 downto 0);
        control         : in     vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SINE : constant is 1;
    attribute mti_svvh_generic_type of FEEDBACK : constant is 1;
end triangle_wave;
