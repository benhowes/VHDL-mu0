-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- instrction buffer *16bit*             --
-- Ben Howes 2011                        --
-------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."="

entity accumulator is
  port ( CLK, EN : in std_logic;
    INPUT : in std_logic_vector (15 downto 0);
    Z, NEG : out std_logic;
    OUTPUT : out std_logic_vector (15 downto 0)
  );
  
end accumulator;

architecture struct of accumulator is
  
begin
  
  control : process(INPUT, EN, CLK)
  variable v_out : std_logic_vector (15 downto 0);
  variable v_z, v_neg : std_logic;
  begin
    if(EN AND rising_edge(CLK)) then
      v_out := INPUT;
    
      if(v_out = 0) then -- we have 0 in the acc
        v_z := '1';
        v_neg := '0';
      elsif(v_out(15) = '1') then -- we have a negative number in the acc
        v_z := '0';
        v_neg := '1';
      else -- we have a positive number
        v_z := '0'; 
        v_neg := '0';
      end if;
      
      OUTPUT <= v_out;
      Z <= v_z;
      NEG <= v_neg;
      
    end if;
  end process;
    
end struct;