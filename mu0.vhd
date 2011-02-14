-------------------------------------------
-- VHDL implementation of mu0 processor  --
-- processor level                       --
-- Ben Howes 2011                        --
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity mu0 is
  port (
    CLK : in std_logic;
    DATA_IN : in std_logic_vector (15 downto 0);
    DATA_OUT : out std_logic_vector (15 downto 0);
    ADDR : out std_logic_vector (15 downto 0);
    RESET : in std_logic;
    MEMRQ, RNW : out std_logic -- control lines for the memory
  );
end;
  
-- map the components up!
architecture mu0_arch of mu0 is
  
  component accumulator
    port(
      CLK, EN : in std_logic;
      INPUT : in std_logic_vector (15 downto 0);
      Z, NEG : out std_logic;
      OUTPUT : out std_logic_vector (15 downto 0)
      );
  end component;
  
  component instruction_pointer
    port(
      CLK, EN : in std_logic;
      INPUT : in std_logic_vector (15 downto 0);
      OUTPUT : out std_logic_vector (15 downto 0)
    );
  end component;
  
  component instruction_register
    port(
      CLK, EN : in std_logic;
      INPUT : in std_logic_vector (15 downto 0);
      OUTPUT : out std_logic_vector (15 downto 0)
    );
  end component;
  
  component mux
    port(
      IN_A, IN_B : in std_logic_vector (15 downto 0);
      SEL_B : in std_logic;
      OUTPUT : out std_logic_vector (15 downto 0)
    );
  end component;
  
  component buff
    port(
      IN_A: in std_logic_vector (15 downto 0);
      EN: in std_logic;
      OUT_A : out std_logic_vector (15 downto 0)
    );
  end component;
  
  component control is
    port(
      CLK : in std_logic;
      RST, ACC_Z, ACC_15, EX_IN : in std_logic;
      OP_CODE : in std_logic_vector (3 downto 0);
      IR_CE, ACC_CE, IP_CE, ACC_OE, MEMRQ, RNW, ASEL, BSEL, A_EN, B_INV, C_IN, EX_O : out std_logic
    );
  end component;
  
  component ALU is
    port (IN_A, IN_B: in std_logic_vector (15 downto 0);
          B_INV, C_IN, A_EN, RST: in std_logic;
          OUTPUT : out std_logic_vector (15 downto 0)
    );
  end component;
  
  --SIGNALS
  --major busses
  signal dbus: std_logic_vector (15 downto 0);
  signal abus: std_logic_vector (15 downto 0);
  signal acc_bus : std_logic_vector (15 downto 0);
  signal r_bus : std_logic_vector (15 downto 0);
  signal b_bus : std_logic_vector (15 downto 0);
  signal pc_bus : std_logic_vector (15 downto 0);
  signal ir_bus : std_logic_vector (15 downto 0); --has to be split
  
  -- pc/ir mux special signal
  signal pc_ir_mux_bus : std_logic_vector (15 downto 0);
  
  -- control signals
  --input to control
  signal rst : std_logic;
  signal acc_z : std_logic;
  signal acc_15 : std_logic;

  --output from control
  signal ir_ce : std_logic;
  signal acc_ce : std_logic;
  signal ip_ce : std_logic;
  signal acc_oe : std_logic;
  signal asel : std_logic;
  signal bsel : std_logic;
  signal a_en : std_logic;
  signal b_inv : std_logic;
  signal c_in : std_logic;
  
  signal ex : std_logic;
  
  begin
  -- define split up signals
  pc_ir_mux_bus <= "0000" & ir_bus (11 downto 0);
  rst <= RESET;
  dbus <= DATA_IN;
  ADDR <= abus;
  ---------------------------
  -- port mappings
  ---------------------------
    
  ACC : accumulator
  port map(
    CLK => CLK,
    EN => acc_ce,
    INPUT => r_bus,
    Z => acc_z,
    NEG => acc_15,
    OUTPUT => acc_bus
  );
  
  IP : instruction_pointer
  port map(
    CLK => CLK,
    EN => ip_ce,
    INPUT => r_bus,
    OUTPUT => pc_bus
  );
  
  IR : instruction_register 
  port map(
    CLK => CLK,
    EN => ir_ce,
    INPUT => DATA_IN,
    OUTPUT => ir_bus
  );
  
  CNTL : control
  port map(
    CLK => CLK,
    RST => rst,
    ACC_Z => acc_z,
    ACC_15 => ACC_15,
    EX_IN => ex,
    OP_CODE => ir_bus (15 downto 12),
    IR_CE => ir_ce,
    ACC_CE => acc_ce,
    IP_CE => ip_ce,
    ACC_OE => acc_oe,
    MEMRQ => memrq,
    RNW => rnw,
    ASEL => asel,
    BSEL => bsel,
    A_EN => a_en,
    B_INV => b_inv,
    C_IN => c_in,
    EX_O => ex
  );
  
  ADDER : ALU
  port map(
    IN_A => acc_bus,
    IN_B => b_bus,
    B_INV => b_inv,
    C_IN => c_in,
    A_EN => a_en,
    RST => rst,
    OUTPUT => r_bus
  );
  
  IR_PC_MUX : mux
  port map(
     IN_A => pc_bus,
     IN_B => pc_ir_mux_bus,
     SEL_B => asel,
     OUTPUT => abus
   );
   
   DBUS_ABUS_MUX : mux
   port map(
     IN_A => abus,
     IN_B => DATA_IN,
     SEL_B => bsel,
     OUTPUT => b_bus
   );
  
  ACC_DBUF : buff
  port map(
    IN_A => acc_bus,
    EN => acc_oe,
    OUT_A => DATA_OUT
  );
end mu0_arch;
  