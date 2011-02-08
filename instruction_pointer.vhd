-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- Direction buffer 16bit                --
-- Ben Howes 2011                        --
-------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
-- use IEE.std_logic_unsigned."="

entity instruction_pointer is
  port ( CLK : in std_logic;