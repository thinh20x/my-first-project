library verilog;
use verilog.vl_types.all;
entity audio_codec is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        sample_end      : out    vl_logic_vector(1 downto 0);
        sample_req      : out    vl_logic_vector(1 downto 0);
        audio_output    : in     vl_logic_vector(15 downto 0);
        audio_input     : out    vl_logic_vector(15 downto 0);
        channel_sel     : in     vl_logic_vector(1 downto 0);
        AUD_ADCLRCK     : out    vl_logic;
        AUD_ADCDAT      : in     vl_logic;
        AUD_DACLRCK     : out    vl_logic;
        AUD_DACDAT      : out    vl_logic;
        AUD_BCLK        : out    vl_logic
    );
end audio_codec;
