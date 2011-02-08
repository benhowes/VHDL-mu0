-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- instrction buffer *16bit*             --
-- Ben Howes 2011                        --
-------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
-- use IEE.std_logic_unsigned."="

entity instruction_pointer is
  port ( CLK, EN : in std_logic;
    INPUT : in std_logic_vector (15 downto 0);
    OUTPUT : out std_logic_vector (15 downto 0)
  );
  
end instruction_pointer;

architecture struct of instruction_pointer is
  
begin
  
  control : process(INPUT, EN, CLK)
  variable v_out : std_logic_vector (15 downto 0);
  begin
    if(EN AND rising_edge(CLK)) then
      v_out := INPUT;
      OUTPUT <= v_out;
    end if;
  end process;
    
end struct;