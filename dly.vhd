-------------------------------------------------------------------------------
-- (C) P. Crosthwaite, University of Queensland (2010)

--This library is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 3.0 of the License, or (at your option) any later version.

--This library is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--Lesser General Public License for more details.

--You should have received a copy of the GNU Lesser General Public
--License along with this library.
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
		DEFAULT : std_logic := 'X'
	);
	port (
		ipt : in std_logic_vector(N-1 downto 0);
		opt : out std_logic_vector(N-1 downto 0);
		vld_i : in std_logic := '1';
		rdy_i : out std_logic;
		vld_o : out std_logic;
		rdy_o : in std_logic := '1';
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

	signal vld_stages, rdy_stages : std_logic_vector(T downto 0);

begin

	pipe(0) <= ipt when vld_i = '1' else (others => DEFAULT);
	vld_stages(0) <= vld_i;
	rdy_i <= rdy_stages(0);

	vld_o <= vld_stages(T);
	rdy_stages(T) <= rdy_o;
	opt <= pipe(T);

	generate_pipe : for I in 1 to T generate

		rdy_stages(I-1) <= not vld_stages(I) or rdy_stages(I);

		process (clk) begin if (clk'event and clk = '1') then
			if (rdy_stages(I-1)) then
				pipe(I) <= pipe(I-1);
				vld_stages(I) <= vld_stages(I-1);
			end if;

			if (rst = '1') then
				pipe(I) <= (others => DEFAULT);
			end if;
		end process;

	end generate;

end Behavioral;

