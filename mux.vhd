-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- Multiplexer 16bit                     --
-- Ben Howes 2011                        --
-------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
-- use IEE.std_logic_unsigned."="

entity mux is
  port (in_a, in_b: in std_logic (15 downto 0),
        sel_b: in std_logic,
        output : out std_logic (15 downto 0)
  );
end;

architecture struct of mux is
  
begin
  
get_output : process(in_a, in_b, sel_b)
  v_out : std_logic (15 downto 0);
  
  begin
  
  if(sel_b = '0') then
    v_out := in_a;
  else
    v_out := in_b;
  end if;
  
  output <= v_out;
  
end process;
  
end struct;