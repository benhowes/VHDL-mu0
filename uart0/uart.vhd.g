-- Ben Howes - 02/03/11
-- Serial unit comprising of the rx,tx and associated buffers and control logic.
--
-- The addressing for this unit starts at 0xEE0. This is done to keep it in the lower 12 bits of the addressing space.
-- NOTE: all the ports use the lower half of the words, due to the serial bus only transfering 8 bits at a time.
-- 0xEE0 

entity uart is port(
  -- processor interfaces
  clk : in std_logic;
  reset : in std_logic;
  ser_clk: in std_logic;
  data_in : in std_logic_vector (15 downto 0);
  data_out : out std_logic_vector (15 downto 0);
  addr : in std_logic_vector (15 downto 0);
  --serial interfaces
  rx: in std_logic;
  tx: out std_logic;
  );
end;

architecture struct of uart is

component serrx is
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
        rxd : in std_logic; -- 
        rxdone : in std_logic; 
        rxdata : out std_logic_vector(7 downto 0); 
        frerr : out std_logic; -- frame error
        overr : out std_logic; -- overrun error
        rxrdy : out std_logic
      );
end component;

component sertx is
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
        ldtx : in std_logic;
        txda : in std_logic_vector(7 downto 0);
        txdone : out std_logic; -- overrun error
        txd : out std_logic
      );
end component;  

signal cntrl : std_logic_vector (15 downto 0); -- the control registers
signal clear, rxdone, frerr, overr, txdone, rx_out_en, rx_read_lock, tx_write_lock, ldtx, rxrdy : std_logic;
signal int_rx, int_tx : std_logic_vector (7 downto 0);

begin

-- mappings to control register.
cntrl(15) <= clear;
cntrl(14) <= frerr OR overr;
cntrl(13) <= frerr;
cntrl(12) <= overerr;
cntrl(11) <= tx_in_en;
cntrl(10) <= rx_out_en;
cntrl(9) <= tx_write_lock;
cntrl(8) <= rx_read_lock;
cntrl(7) <= ldtx;
cntrl(6) <= rxrdy;
cntrl(0) <= rxdone;
cntrl(1) <= txdone;


rx_unit : serrx port map(
  clk => clk,
  clear => clear,
  reset => reset,
  rxd => rx,
  rxdone => rxdone,
  rxdata => int_rx,
  frerr => frerr,
  overr => overr,
  rxrdy => rxrdy
);

tx_unit : sertx port map(
  clk => clk,
  clear => clear,
  reset => reset,
  ldtx => ldtx,
  txda => int_tx,
  txdone => txdone,
  txd => tx
);

proc : process(clk) -- the sync process, which will act like a few ram locations.
variable v_int_tx : std_logic_vector (7 downto 0);
begin
  if rising_egde(clk) then
    if(reset = '1') then
      cntrl <= (others => '0');
    else -- do the right ting...
      case addr is
        when x"EE0" => 
          cntrl <= data_in;
        when x"EE1" => 
          if(tx_write_lock = '0') then
            v_int_tx <= data_in (7 downto 0);
            v_tx_in_en <= '1';
          endif;
        when x"EE2" =>
          data_out(7 downto 0) <= int_rx;
    endif;
    
    cntrl <=
    
  endif;
end process;

rx_proc : process(ser_clk)
begin
  if(rising_edge(ser_clk) AND rxdone ='0' AND ) then
  endif;

end process;

tx_proc : process(ser_clk)

end process;

end struct;
  