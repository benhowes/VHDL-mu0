-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- Multiplexer 16bit                     --
-- Ben Howes 2011                        --
-------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
-- use IEE.std_logic_unsigned."="

entity mux is
  port (IN_A, IN_B: in std_logic_vector (15 downto 0);
        SEL_B: in std_logic;
        OUTPUT : out std_logic_vector (15 downto 0)
  );
end;

architecture struct of mux is
  
begin
  
get_output : process(IN_A, IN_B, SEL_B)
  variable v_out : std_logic_vector (15 downto 0);
  
  begin
  
  if(sel_b = '0') then
    v_out := in_a;
  else
    v_out := in_b;
  end if;
  
  OUTPUT <= v_out;
  
end process;
  
end struct;