-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- Test bench                            --
-- Ben Howes 2011                        --
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tb_comp is END;

architecture tb_comp_arch of tb_comp is
  
  component comp
  port (
    CLOCK : in std_logic;
    DATA : out std_logic_vector (15 downto 0);
    ADDR : out std_logic_vector (15 downto 0);
    RESET : in std_logic
  );
  end component;
  
  -- signals
  signal CLOCK : std_logic;
  signal DATA : std_logic_vector (15 downto 0);
  signal ADDR : std_logic_vector (15 downto 0);
  signal RESET : std_logic;

  begin
    
    uut : comp port map(
      CLOCK => CLOCK,
      DATA => DATA,
      ADDR => ADDR,
      RESET => RESET
    );
    
    tb_clock : process --clock with 100ns timeperiod
    begin
      wait for 50 ns;
        CLOCK <= '1';
      wait for 50 ns;
        CLOCK <= '0';
    end process;
    
    --PROCESS : POWER UP RESET
   p_reset: process
   begin
      reset<='1';
      wait for 400 ns;
      reset<='0';
      wait;  --wait forever
   end process;
   
   -- because there is no external memory interface currently, the program has to be hard coded into the primary memory file.
   
 end tb_comp_arch;