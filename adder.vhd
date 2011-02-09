-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- ALU 16bit                             --
-- Ben Howes 2011                        --
-------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity ALU is
  port (IN_A, IN_B: in std_logic_vector (15 downto 0);
        B_INV, C_IN, A_EN, RST: in std_logic;
        OUTPUT : out std_logic_vector (15 downto 0)
  );
end;

architecture struct of ALU is
  
begin
  
get_output : process(IN_A, IN_B, B_INV, C_IN, A_EN, RST)
  variable v_out, v_b : std_logic_vector (15 downto 0);
  
  begin
    
  if(B_INV = '1') then --invert B
    v_b := (- signed(IN_B) );
  else
    v_b := IN_B;
  end if;
  
  if(A_EN = '0') then -- disable A
    null;
  else
    v_out := signed(IN_A) + signed(v_b);
  end if;
  
  if(C_IN = '1') then -- we have a carry in
    v_out := signed(v_out) + '1' ;
  end if;
  
  if(RST = '1') then
    v_out := "0000000000000000";
  end if;
  
  OUTPUT <= v_out;
  
end process;
  
end struct;