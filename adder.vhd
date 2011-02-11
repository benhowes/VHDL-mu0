-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- ALU 16bit                             --
-- Ben Howes 2011                        --
-------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
  port (IN_A, IN_B: in std_logic_vector (15 downto 0);
        B_INV, C_IN, A_EN, RST: in std_logic;
        OUTPUT : out std_logic_vector (15 downto 0)
  );
end;

architecture struct of ALU is
  signal op : std_logic_vector (3 downto 0);
  
begin
  
get_output : process(IN_A, IN_B, B_INV, C_IN, A_EN, RST)
  
  constant cin_ext : std_logic_vector(15 downto 1) := (others => '0'); 
  begin
  op <= RST & A_EN & B_INV & C_IN;
  
  case op is
    when "1XXX" => OUTPUT <= "0000000000000000";
    when "0100" | "0101" => -- A+B+C
      OUTPUT <= std_logic_vector((unsigned(IN_A) + unsigned(IN_B) + unsigned(cin_ext & C_IN)));
    when "0110" | "0111" => 
      OUTPUT <= std_logic_vector((unsigned(IN_A) - unsigned(IN_B) + unsigned(cin_ext & C_IN)));
    when "0000" | "0001" =>
      OUTPUT <= std_logic_vector((unsigned(IN_B) + unsigned(cin_ext & C_IN)));
    when "0010" | "0011" =>
      OUTPUT <= std_logic_vector((0 - unsigned(IN_B) + unsigned(cin_ext & C_IN)));
    when others => --undefined functions.
      OUTPUT <= "0000000000000000";
  end case;

end process;

  
end struct;