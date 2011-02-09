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
   signal ram : ram_type;

begin

  RamProc: process(clock) is

  begin
      --put some instructions in the RAM here!
  ram(0) <= "0000000100000000"; -- LDA 512
  ram(1) <= "0010000100000001"; -- ADD 513
  ram(2) <= "0001000100000010"; -- STO 514
  ram(3) <= "0111000000000000"; -- STOP
  
  --data space
  ram(256) <= "0000000000000010"; -- 2
  ram(257) <= "0000000000000100"; -- 4
    if rising_edge(clock) then
      if (MEMRQ = '1' AND RNW = '0') then -- write
        ram(to_integer(unsigned(address))) <= data_in;
      elsif (MEMRQ = '1' AND RNW = '1') then --read
        data_out <= ram(to_integer(unsigned(address)));
      else
        null;
      end if;
      
    end if;
  end process RamProc;

end architecture RTL;
