-- Simple generic RAM Model
--
-- Modified for the mu0 processor by Ben Howes
-- * added write control line
--
-- +-----------------------------+
-- |    Copyright 2008 DOULOS    |
-- |   designer :  JK            |
-- +-----------------------------+

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity sync_ram is
  port (
    clock   : in  std_logic;
    MEMRQ : in std_logic;
    RNW      : in  std_logic;
    address : in  std_logic_vector;
    data_in  : in  std_logic_vector;
    data_out : out std_logic_vector
  );
end entity sync_ram;

architecture RTL of sync_ram is

   type ram_type is array (0 to 1048) of std_logic_vector(data_in'range);
   signal ram : ram_type := 
   (
    -- INSTRUCTIONS
    -- Start with 0 in A and add &257, &259 times, saving the result in 258
    0 => x"0100", -- LDA 256
    1 => x"2101", -- ADD 257
    2 => x"1102", -- STO 258
    3 => x"0103", -- LDA 259
    4 => x"3104", -- SUB 260
    5 => x"1103", -- STO 259
    6 => x"4000", -- JNE 0
    7 => x"7000", -- STOP
    -- DATA
    256 => x"0000", -- 2
    257 => x"0004", -- 4
    259 => x"0010", -- 8 (number of times to loop)
    260 => x"0001", -- 1 (decrement value)
    others => x"0000"
   );
begin

  RamProc: process(clock, address, RNW, MEMRQ) is

  begin
    if rising_edge(clock) then
      if (MEMRQ = '1' AND RNW = '0') then -- write
        ram(to_integer(unsigned(address))) <= data_in;
      end if;
      
    end if;
  end process RamProc;
  
  dataout : process(MEMRQ, address, data_in, clock, RNW) --change the output aysnc
   variable op : std_logic_vector (1 downto 0);
   begin
   op := MEMRQ & RNW;
   case op is
    when "11" => data_out <= ram(to_integer(unsigned(address)));
    when others => data_out <= "ZZZZZZZZZZZZZZZZ";
   end case;
  end process dataout;
  
end architecture RTL;
