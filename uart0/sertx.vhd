
----------------------------------------------------------------------------
--  This file is a part of the peak detector VHDL model
--  Copyright (C) 2005  Jose Luis Nunez

--------------------------------------
--  entity       = sertx			         --
--  version      = 1.0              --
--  last update  = 22/07/05         --
--  author       = Jose Nunez       --
--------------------------------------


-- serial transmitter

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";



entity sertx is
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
        ldtx : in std_logic;
        txda : in std_logic_vector(7 downto 0);
        txdone : out std_logic; -- overrun error
        txd : out std_logic
      );
end;  

architecture struct of sertx is

type buf2con_type is (waitldtx,send,waitsent,wtnewldtx,wtnotldtx,charwaiting); 

type stcont_type is (wtsend,txstartbit,tx4evenbits,tx1stopbit,tx4oddbits); 

type state_register_type is record
	buf2con_state : buf2con_type;
	stcont_state : stcont_type;
end record;

signal r, r_in: state_register_type; -- state register
signal td,cnt,q : std_logic_vector(7 downto 0);
signal ldreg,ssend,ldsr,shft,start,rcnt,sent,done : std_logic;




begin

buf2con_process: process(r,ldtx,sent)

variable v : state_register_type;
variable vdone,vldreg,vsend : std_logic;

begin

vdone := '0';
vldreg := '0';
vsend := '0';
v.buf2con_state := r.buf2con_state;


case v.buf2con_state is

	when waitsent => 
		if (sent = '1') then 
			v.buf2con_state := waitldtx;
		end if;
	when waitldtx =>
		vdone := '1';
		if (ldtx = '1') then
			vldreg := '1';
			v.buf2con_state := send;
		end if;
	when  send =>
		vsend := '1';
		v.buf2con_state := wtnotldtx;
	when  wtnotldtx =>
		if (ldtx = '0' and sent = '1') then
			v.buf2con_state := waitldtx;
		elsif (ldtx = '0' and sent = '0') then
			v.buf2con_state := wtnewldtx;
		end if;
	when wtnewldtx =>
		--vdone := '1';
		if (sent = '1') then
			v.buf2con_state := waitldtx;
		elsif (ldtx = '1' and sent = '0') then
			v.buf2con_state := charwaiting;
			vldreg := '1';
		end if;
	when charwaiting =>
		vsend := '1';
		if (sent = '1') then
			v.buf2con_state := wtnotldtx;
		end if;
	when others => null;
end case;	

r_in.buf2con_state <= v.buf2con_state;
done <= vdone;
ldreg <= vldreg;
ssend <= vsend;

end process buf2con_process;		

txdone <= done;


stcont_process : process(r,ssend,cnt) 

variable v : state_register_type;
variable vrcnt, vstart,vsent,vshft,vldsr : std_logic;


begin

v.stcont_state := r.stcont_state;
vrcnt := '0';
vstart := '0';
vsent := '0';
vshft := '0';
vldsr := '0';


case v.stcont_state is

	when wtsend =>  
		vsent := '1';
		vrcnt := '1';
		if (ssend = '1') then
			vldsr := '1';
			v.stcont_state := txstartbit;
		end if;
	when  txstartbit => 
		if (cnt(4) = '0') then
			vstart := '1';
		end if;
		if (cnt(4) = '1') then
			vshft := '1';
			v.stcont_state := tx4evenbits;
		end if;
	when  tx4evenbits =>
		if (cnt(4) = '0') then
			vshft := '1';
			v.stcont_state := tx4oddbits;
		end if;
 	when  tx4oddbits =>
 		if (cnt(4) = '1' and cnt(7) = '0') then
 			vshft := '1';
 			v.stcont_state := tx4evenbits;
 		elsif (cnt(4) = '1' and cnt(7) = '1') then
 			vshft := '1';
 			v.stcont_state := tx1stopbit;
 		end if;
 	when  tx1stopbit => 
 		if (cnt(4 downto 0) = "11111" and ssend = '0') then
 			v.stcont_state := wtsend;
 			vsent := '1';
 		elsif (cnt(4 downto 0) = "11111" and ssend = '1') then
 			vsent := '1';
 			vrcnt := '1';
 			vldsr := '1';
 			v.stcont_state := txstartbit;
 		end if;
	when others => null;
	
end case;

rcnt <= vrcnt;
start <= vstart;
sent <= vsent;
shft <= vshft;
ldsr <= vldsr; 
r_in.stcont_state <= v.stcont_state;
	
end process stcont_process;



-- sequential part

regs: process (clk,clear)

begin

if (clear = '0') then
	r.buf2con_state <= waitsent;
	r.stcont_state <= wtsend;
	cnt <= (others => '0');
	td <= (others => '0');
	q <= (others => '0'); 
	txd <= '0';
elsif rising_edge(clk) then
	if (reset = '0') then
		r.buf2con_state <= waitsent;
		r.stcont_state <= wtsend;
		cnt <= (others => '0');
		td <= (others => '0');
		q <= (others => '0');
		txd <= '0';
	else
		r <= r_in;
		if (ldsr = '1') then
			q <= td;
		elsif (shft = '1') then
			q <= '1' & q (7 downto 1);
		end if;
		if (rcnt = '1') then
			txd <= '1';
		elsif (start = '1') then
			txd <= '0';
		elsif (shft = '1') then
			txd <= q(0);
		end if;
		if (rcnt = '1') then
			cnt <= (others => '0');
		else
			cnt <= cnt + 1;
		end if;
		if (ldreg = '1') then
			td <= txda;
		end if;
	end if;
end if;

end process regs;

end;









       