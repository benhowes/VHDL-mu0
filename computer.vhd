-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- Top level                             --
-- Ben Howes 2011                        --
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity comp is
  port (
    CLOCK : in std_logic;
    DATA : out std_logic_vector (15 downto 0);
    ADDR : out std_logic_vector (15 downto 0);
    RESET : in std_logic
  );
end;
    
architecture comp_arch of comp is
  
  component mu0
    port (
      CLK : in std_logic;
      DATA_IN : in std_logic_vector (15 downto 0);
      DATA_OUT : out std_logic_vector (15 downto 0);
      ADDR : out std_logic_vector (15 downto 0);
      RESET : in std_logic;
      MEMRQ, RNW : out std_logic
    );
  end component;

  component sync_ram
    port (
      clock   : in  std_logic;
      MEMRQ : in std_logic;
      RNW      : in  std_logic;
      address : in  std_logic_vector;
      data_in  : in  std_logic_vector;
      data_out : out std_logic_vector
    );
  end component;
  
  signal MEMRQ : std_logic;
  signal RNW : std_logic;
  signal INT_ADDR : std_logic_vector (15 downto 0);
  signal INT_DATA : std_logic_vector (15 downto 0);
  
  begin
  
  ADDR <= INT_ADDR;
  DATA <= INT_DATA;
  
  processor : mu0 port map(
    CLK => CLOCK,
    DATA_OUT => INT_DATA,
    DATA_IN => INT_DATA,
    ADDR => INT_ADDR,
    RESET => RESET,
    MEMRQ => MEMRQ,
    RNW => RNW
  );
  
  primary_memory : sync_ram port map(
    CLOCK => CLOCK,
    MEMRQ => MEMRQ,
    RNW => RNW,
    address => INT_ADDR,
    data_in => INT_DATA,
    data_out => INT_DATA
  );
end comp_arch;