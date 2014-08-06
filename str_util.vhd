-------------------------------------------------------------------------------
-- (C) P. Crosthwaite, University of Queensland (2011)

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library gen_util;
use gen_util.util.all;
use gen_util.slv_util.all;

package str_util is

	function util_spaces(a : integer) return string;
	function util_tab (a : integer) return string;
	function util_boolean_to_string (a : boolean) return string;
	function util_std_logic_to_string (a : std_logic) return string;
	function util_int_to_str (a : integer) return string;
	function util_slv_to_str_bin (a : std_logic_vector) return string;
	function util_slv_to_str_bin_nibbles(ar : std_logic_vector) return string; 
	function util_slv_to_str_hex (ar : std_logic_vector) return string;
	function util_slv_to_str_hex_and_bin (a : std_logic_vector) return string;

end str_util;

package body str_util is

	constant TAB_SIZE : integer := 4;

	function util_tab (a : integer) return string is begin
		return util_spaces(a * TAB_SIZE);
	end function;

	function util_spaces (a : integer) return string is begin
		if (a < 2) then
			return " ";
		else
			return util_spaces(roof_div(a, 2)) & util_spaces(a/2);
		end if;
	end function;

	function util_boolean_to_string (a : boolean) return string is begin
		return util_select_str(a, "T", "F");
	end;
	
	function util_std_logic_to_string (a : std_logic) return string is begin
		return util_select_str(
			(a /= '1') and (a /= '0'),
			"X",
			util_select_str((a = '1'), "1", "0")
		);
	end;

	--TODO: support multiple radixes
	function util_int_to_str (a : integer) return string is begin
		if (a < 10) then
			case a is
				when 0 => return "0";
				when 1 => return "1";
				when 2 => return "2";
				when 3 => return "3";
				when 4 => return "4";
				when 5 => return "5";
				when 6 => return "6";
				when 7 => return "7";
				when 8 => return "8";
				when 9 => return "9";
				when others => return "X";
			end case;
		else
			return util_int_to_str(a / 10) & util_int_to_str(a mod 10);
		end if;
	end;

	--LISP style!!
	
	function util_slv_to_str_hex (ar : std_logic_vector) return string is
		constant DIVISOR : integer := ((ar'length)/4+1) /2;
		constant a : std_logic_vector := slv_dt0_slice(ar);
		variable aw : std_logic_vector(3 downto 0);
	begin
		if (a'length = 4) then
			aw := a(3 downto 0);
			case aw is
				when x"0" => return "0";
				when x"1" => return "1";
				when x"2" => return "2";
				when x"3" => return "3";
				when x"4" => return "4";
				when x"5" => return "5";
				when x"6" => return "6";
				when x"7" => return "7";
				when x"8" => return "8";
				when x"9" => return "9";
				when x"a" => return "a";
				when x"b" => return "b";
				when x"c" => return "c";
				when x"d" => return "d";
				when x"e" => return "e";
				when x"f" => return "f";
				when others => return "X";
			end case;
		end if;
		return 
			util_slv_to_str_hex(slv_dt0_slice(a(a'length-1 downto DIVISOR*4))) & 
			util_slv_to_str_hex(slv_dt0_slice(a(DIVISOR*4-1 downto 0)));
	end;
	
	function util_slv_to_str_bin (a : std_logic_vector) return string is
		constant DIVISOR : integer := ((a'length)+1) / 2;
	begin
		if (a'length = 1) then return util_std_logic_to_string(a(0)); end if;
		return 
			util_slv_to_str_bin(slv_dt0_slice(a(a'length-1 downto DIVISOR))) & 
			util_slv_to_str_bin(slv_dt0_slice(a(DIVISOR-1 downto 0)));
	end;


	function util_slv_to_str_bin_nibbles(ar : std_logic_vector) return string is 
		constant a :std_logic_vector := slv_dt0_slice(ar);
	begin
		if (a'length > 4) then
			return util_slv_to_str_bin_nibbles(a(a'length-1 downto 4)) &
				"_" & util_slv_to_str_bin(a(3 downto 0));
		else
			return util_slv_to_str_bin(a(a'length-1 downto 0));
		end if;
	end function;

	function util_slv_to_str_hex_and_bin (a : std_logic_vector) return string is begin
		return util_slv_to_str_bin_nibbles(a) & "(" & util_slv_to_str_hex(a) & ")";
	end function;

end str_util;
