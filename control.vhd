-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- Control Logic                         --
-- Ben Howes 2011                        --
-------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity control is
  port(
    CLK : in std_logic;
    RST, ACC_Z, ACC_15, EX_IN : in std_logic;
    OP_CODE : in std_logic_vector (3 downto 0);
    IR_CE, ACC_CE, IP_CE, ACC_OE, MEMRQ, RNW, ASEL, BSEL, A_EN, B_INV, C_IN, EX_O : out std_logic
   );
end;

architecture struct of control is
  
signal next_state : std_logic;
signal v_out : std_logic_vector (11 downto 0);
begin
  
proc : process(ACC_Z, ACC_15, EX_IN, OP_CODE, RST, CLK) 

  variable op : std_logic_vector (3 downto 0);
  
  begin
  op := OP_CODE;

  case op is
  
    when "0000" => -- LDA
      v_out <= "010011110001";    
    when "0001" => -- STO
      v_out <= "000110100001";  
    when "0010" => -- ADD
      v_out <= "010011111001";
    when "0011" => -- SUB
      v_out <= "010011111111";
    when "0100" => -- JMP
      v_out <= "101011100010";
    when "0101" => -- JGE
      if(ACC_15 = '0') then
        v_out <= "101011100010";
      else
        v_out <= "101011000010";
      end if;
    when "0110" => -- JNE
      if(ACC_Z = '0') then
        v_out <= "101011100010";
      else
        v_out <= "101011000010";
      end if;
    when others => -- STOP or undefined instruction
      v_out <= "000001100000";
  end case;
    
  -- special cases when op code is XXXX
  if(RST = '1') then -- we are going to do a reset
    v_out <= "101011000010";
  elsif(EX_IN = '1') then -- fetch phase
    v_out <= "101011000010";
  end if;  
  
      --assign the output signals
    IR_CE <= v_out(11);
    ACC_CE <= v_out(10);
    IP_CE <= v_out(9);
    ACC_OE <= v_out(8);
    MEMRQ <= v_out(7);
    RNW <= v_out(6);
    ASEL <= v_out(5);
    BSEL <= v_out(4);
    A_EN <= v_out(3);
    B_INV <= v_out(2);
    C_IN <= v_out(1);
    next_state <= v_out(0);
    
    
  end process;
  
clocked : process(CLK) -- state stuff
  begin
  if( rising_edge(CLK)) then --only do it on the rising edge, not the falling edge... 
    -- perform the d-type action
    EX_O <= next_state;
  end if;
  
end process;
  
end struct;
 