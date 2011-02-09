-- Simple generic RAM Model
--
-- Modified for the mu0 processor by Ben Howes
-- * added write control line
-- * made single port, instead of having data_in and data_out
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
    data  : inout  std_logic_vector
  );
end entity sync_ram;

architecture RTL of sync_ram is

   type ram_type is array (0 to (2**address'length)-1) of std_logic_vector(data'range);
   signal ram : ram_type;
   signal read_address : std_logic_vector(address'range);

begin
  
  --put some instructions in the RAM here!
  ram(0) <= "0000000100000000"; -- LDA 512
  ram(1) <= "0010000100000001"; -- ADD 513
  ram(2) <= "0001000100000010"; -- STO 514
  ram(3) <= "0111000000000000"; -- STOP
  
  --data space
  ram(512) <= "0000000000000010"; -- 2
  ram(513) <= "0000000000000100"; -- 4

  RamProc: process(clock) is

  begin
    if rising_edge(clock) then
      if (MEMRQ = '1' AND RNW = '0') then -- write
        ram(to_integer(unsigned(address))) <= data;
      elsif (MEMRQ = '1' AND RNW = '1') then --read
        read_address <= address;
        data <= ram(to_integer(unsigned(read_address)));
      else
        null;
      end if;
      
    end if;
  end process RamProc;

end architecture RTL;
