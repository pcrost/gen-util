-------------------------------------------------------------------------------
-- (C) P. Crosthwaite, University of Queensland (2011)
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package util is

	--arrays of primative types

	type BOOL_ARRAY is array(natural range <>) of boolean;
	
	--TODO: move to a another util file

	type INT_ARRAY is array(natural range <>) of integer;	
	
		--determine if an int array contains an element. only valid with 0 based arrays
		function util_int_array_contains (a : INT_ARRAY; e : integer) return boolean;
		--return the index of the first occurance of a particular element in an int array
		--onyl valid with 0 based arrays
		function util_int_array_index_of(a : INT_ARRAY; e : integer) return integer;
		--determine if two int arrays are equal. false on length mismatch
		function util_int_array_equals(a : INT_ARRAY; b : INT_ARRAY) return boolean;

	--equivalents of (? :) operator in c, for various types

	function util_select_boolean(c : boolean; t_val : boolean; f_val : boolean) return boolean;
	function util_select_int(c : boolean; t_val : integer; f_val : integer) return integer;
	function util_select_sl(c : boolean; t_val : std_logic; f_val : std_logic) return std_logic;
	function util_select_slv(c : boolean; t_val : std_logic_vector; f_val : std_logic_vector) return std_logic_vector;
	function util_select_str(c : boolean; t_val : string; f_val : string) return string;

	--bundle a clock and reset together
	type GCR is record
		clk : std_logic;
		rst : std_logic;
	end record;

	--get the base 2 log of an integer (only guaranteed correct for powers of two)
	--TODO: merge this with util_length_req
	function log2 (n : integer) return integer;	

	--convert a boolean to a std logic (true = 1, false = 0)
	function conv_std_logic (b : boolean) return std_logic;

	--convert a boolean to an integer (0 or 1)

	function conv_bool_to_integer (b : boolean) return integer;

	function roof_div (a : integer; b : integer) return integer;

	function util_max_int(a : integer; b : integer) return integer;
	function util_min_int(a : integer; b : integer) return integer;

	function util_dc_or(a : std_logic; b : std_logic) return std_logic;

	-- Forces the integer to a power of 2, the next power of 2 higher than or equal to a
	function util_force_pow2(a : integer) return integer;

end util;

package body util is

	function util_select_boolean(c : boolean; t_val : boolean; f_val : boolean) return boolean is begin
		if (c) then	return t_val; else return f_val; end if;
	end;
	
	function util_select_int(c : boolean; t_val : integer; f_val : integer) return integer is begin
		if (c) then	return t_val; else return f_val; end if;
	end;

	function util_select_slv(c : boolean; t_val : std_logic_vector; f_val : std_logic_vector) return std_logic_vector is begin
		if (c) then	return t_val; else return f_val; end if;
	end;

	function util_select_str(c : boolean; t_val : string; f_val : string) return string is begin
		if (c) then	return t_val; else return f_val; end if;
	end;

	function util_select_sl(c : boolean; t_val : std_logic; f_val : std_logic) return std_logic is begin
		if (c) then return t_val; else return f_val; end if;
	end;
	
	function log2 (n : integer) return integer is
		variable v : integer;
		variable ret : integer;
	begin
		v := n;
		ret := 0;
		while (v > 1) loop
			ret := ret + 1;
			v := v / 2;
		end loop;		
		return ret;
	end function;

	function conv_std_logic (b : boolean) return std_logic is begin
                return util_select_sl(b, '1', '0');
	end function;

	function conv_bool_to_integer (b : boolean) return integer is begin
                return util_select_int(b, 1, 0);
	end function;

	function util_int_array_contains (a : INT_ARRAY; e : integer) return boolean is begin
		for I in a'range loop
			if (a(I) = e) then return true; end if;
		end loop;
		return false;
	end function;
	
	function util_int_array_index_of(a : INT_ARRAY; e : integer) return integer is begin
		for I in a'range loop
			if (a(I) = e) then return I; end if;
		end loop;
		return a'length;
	end function;
		
	function util_int_array_equals(a : INT_ARRAY; b : INT_ARRAY) return boolean is begin
		if (a'length /= b'length) then return false; end if;
		for I in a'range loop
			if (a(I) /= b(I)) then return false; end if;
		end loop;
		return true;
	end function;	

	function roof_div (a : integer; b : integer) return integer is begin
		if ((a mod b) = 0) then
			return a/b;
		else
			return a/b+1;
		end if;
	end function;
	
	function util_max_int(a : integer; b : integer) return integer is begin
		return util_select_int(a > b, a, b);
	end function;

	function util_min_int(a : integer; b : integer) return integer is begin
		return util_select_int(a < b, a, b);
	end function;

	function util_dc_or(a : std_logic; b : std_logic) return std_logic is begin
		if (a /= '0' and a /= '1') then
			return b;
		elsif (b /='0' and b /= '1') then
			return a;
		else
			return (a or b);
		end if;
	end function;

	function util_force_pow2(a : integer) return integer is
		variable ret : integer;
	begin
		ret := 2;
		while (ret < a) loop
			ret := ret * 2;
		end loop;
		return ret;
	end function;

end util;
