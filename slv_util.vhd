-------------------------------------------------------------------------------
-- (C) P. Crosthwaite, University of Queensland (2011)
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library gen_util;
use gen_util.util.all;

package slv_util is

	--find the minimum unsigned std_logic_vector length to represent the number A

	function util_length_req (A : integer) return integer;

	--zero extend a std_logic_vector to a specified width

	function util_zero_ext_slv(a : std_logic_vector; width : integer) return std_logic_vector;
	function util_zero_ext_slv(a : std_logic; width : integer) return std_logic_vector;

	--sign extend a std_logic_vector to a specified width

	function util_sign_ext_slv(a : std_logic_vector; width : integer) return std_logic_vector;
	function util_sign_ext_slv(a : std_logic; width : integer) return std_logic_vector;

	--return an std_logic_vector of all ones, all zeros or all don't-cares

	function util_ones(w : integer) return std_logic_vector;
	function util_zeros(w : integer) return std_logic_vector;
	function util_dcs(w : integer) return std_logic_vector;

	--determine if two std_logic vectors match subject to a set of don't cares
	--The range of b must match or superset a. 
	--The range of dont_care must match or superset a.

	function util_match_slv(
		a : std_logic_vector;
		b : std_logic_vector;
		dont_care : std_logic_vector
	) return boolean;

	--count the number of ones in a std_logic vector

	function count_ones (a : std_logic_vector) return integer;

	--rebase a slv to be downto 0, rather than downto n where n is non-zero
	function slv_dt0_slice (a : std_logic_vector) return std_logic_vector;

        --do a don't care or function between two slvs
	function util_dc_or_slv(a : std_logic_vector; b : std_logic_vector) return std_logic_vector;

	--bit reverse a slv
	function util_slv_reverse(a : std_logic_vector) return std_logic_vector;
	
	--truncate a slv and assign it to another
	procedure util_slv_trunc_assign(variable a : out std_logic_vector; constant b : in std_logic_vector);
	procedure util_slv_trunc_assign(variable a : out std_logic; constant b : in std_logic_vector);
	
	--conv_integer without simulation noise
	function util_conv_integer_quiet(a : std_logic_vector) return integer;

	--Signed Relational Adjustment. adjust a slv for use with relational operators when interpreting it as signed
	function util_SRA(a : std_logic_vector) return std_logic_vector;

	function util_signed_negative(a : std_logic_vector) return boolean;

end slv_util;

package body slv_util is

	function util_length_req (A : integer) return integer is
		variable w : integer := A;
		variable ret : integer := 0;
	begin
		while w /= 0 loop
			ret := ret + 1;
			w := w / 2;
		end loop;
		return ret;
	end;

	function util_zero_ext_slv(a : std_logic_vector; width : integer) return std_logic_vector is
	begin
		if (width = a'length) then
			return a;
		else
			return conv_std_logic_vector(0, width - a'length) & a;
		end if;
	end;

	function util_zero_ext_slv(a : std_logic; width : integer) return std_logic_vector is
		variable aslv : std_logic_vector(0 downto 0) := (others => a);
	begin
		return util_zero_ext_slv(aslv, width);
	end;

	function util_sign_ext_slv(a : std_logic_vector; width : integer) return std_logic_vector is
		variable ret : std_logic_vector(width-1 downto 0);
	begin
		if (width = a'length) then
			return a;
		else
			ret(a'length-1 downto 0) := a;
			ret(width-1 downto a'length) := (others => ret(a'length-1));
			return ret;
		end if;
	end;
	
	function util_sign_ext_slv(a : std_logic; width : integer) return std_logic_vector is
		variable aslv : std_logic_vector(0 downto 0) := (others => a);
	begin
		return util_sign_ext_slv(aslv, width);
	end;

	function util_ones(w : integer) return std_logic_vector is
		variable ret : std_logic_vector(w-1 downto 0);
	begin
		ret := (others => '1');
		return ret;
	end;

	function util_zeros(w : integer) return std_logic_vector is
		variable ret : std_logic_vector(w-1 downto 0);
	begin
		ret := (others => '0');
		return ret;
	end;

	function util_dcs(w : integer) return std_logic_vector is
		variable ret : std_logic_vector(w-1 downto 0);
	begin
		ret := (others => 'X');
		return ret;
	end;

	function util_match_slv(
		a : std_logic_vector;
		b : std_logic_vector;
		dont_care : std_logic_vector
	) return boolean is
	    constant a0 : std_logic_vector(a'length-1 downto 0) := slv_dt0_slice(a);
	    constant b0 : std_logic_vector(a'length-1 downto 0) := slv_dt0_slice(b);
	    constant d0 : std_logic_vector(a'length-1 downto 0) := slv_dt0_slice(dont_care);
	begin
		for I in a'range loop
			if (d0(I) = '0' and (a0(I) /= b0(I))) then
				return false; 
			end if;
		end loop;
		return true;
	end function;

	function count_ones (a : std_logic_vector) return integer is
		variable ret : integer range 0 to a'length := 0;
	begin
		for I in a'range loop
			if (a(I) = '1') then ret := ret + 1; end if;
		end loop;
		return ret;
	end function;

	function slv_dt0_slice (a : std_logic_vector) return std_logic_vector is
		variable ret : std_logic_vector(a'length-1 downto 0);
	begin
		ret := a; return ret;
	end;

	function util_dc_or_slv(a : std_logic_vector; b : std_logic_vector) return std_logic_vector is
		variable a_dt_0 : std_logic_vector(a'length-1 downto 0) := a;
		variable b_dt_0 : std_logic_vector(b'length-1 downto 0) := b;
		variable ret : std_logic_vector(a'length -1 downto 0);
	begin
		for I in a'range loop
			ret(I) := util_dc_or(a_dt_0(I), b_dt_0(I));
		end loop;
		return ret;
	end function;

	function util_conv_integer_quiet(a : std_logic_vector) return integer is
		variable bogus : boolean := false;
	begin
		for I in a'range loop
			if (a(I) /= '1' and a(I) /= '0') then
				bogus := true;
			end if;
		end loop;
		if (bogus) then
			return 0;
		else
			return conv_integer(a);
		end if;
	end function;

	function util_slv_reverse(a : std_logic_vector) return std_logic_vector is
		variable ret : std_logic_vector(a'range);
	begin
		for i in a'range loop
			ret(a'low + i) := a(a'high - i);
		end loop;
		return ret;
	end;

	procedure util_slv_trunc_assign(variable a : out std_logic_vector; constant b : in std_logic_vector) is
		variable b_dt_0 : std_logic_vector (b'length-1 downto 0) := slv_dt0_slice(b);
	begin
		a := b_dt_0(a'length-1 downto 0);
	end;
	
	procedure util_slv_trunc_assign(variable a : out std_logic; constant b : in std_logic_vector) is
		variable b_dt_0 : std_logic_vector (b'length-1 downto 0) := slv_dt0_slice(b);
	begin
		a := b_dt_0(0);
	end;
	
	function util_SRA(a : std_logic_vector) return std_logic_vector is
		variable ret : std_logic_vector(a'length-1 downto 0) := a;
	begin
		ret(ret'left) := not ret(ret'left);
		return ret;
	end;


	function util_signed_negative(a : std_logic_vector) return boolean is begin
		return (a(a'left) = '1');
	end;

end slv_util;
