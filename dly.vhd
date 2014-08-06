-------------------------------------------------------------------------------
-- (C) P. Crosthwaite, University of Queensland (2010)
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library gen_util;
use gen_util.util.all;

--delay an N bit signal by T clock cycles

entity delay is
	generic (
		N : integer := 5;
		T : integer := 2;
		DEFAULT : std_logic := '0'
	);
	port (
		ipt : in std_logic_vector(N-1 downto 0);
		opt : out std_logic_vector(N-1 downto 0);
		clk : in std_logic;
		rst : in std_logic
		--clk_rst_GCR : GCR
	);
end delay;

architecture Behavioral of delay is

	--alias clk is clk_rst_GCR.clk;
	--alias rst is clk_rst_GCR.rst;

	type PIPE_TYPE is array (T downto 0) of std_logic_vector(N-1 downto 0);
	signal pipe : PIPE_TYPE;

begin

	pipe(0) <= ipt;
	opt <= pipe(T);

	generate_pipe : for I in 1 to T generate

		process (clk, rst) begin
			if (rst = '1') then
				pipe(I) <= (others => DEFAULT);
			elsif (clk'event and clk = '1') then
				pipe(I) <= pipe(I-1);
			end if;
		end process;

	end generate;

end Behavioral;

