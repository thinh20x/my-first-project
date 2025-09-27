library verilog;
use verilog.vl_types.all;
entity noise_generator is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        noise_output    : out    vl_logic_vector(15 downto 0)
    );
end noise_generator;
