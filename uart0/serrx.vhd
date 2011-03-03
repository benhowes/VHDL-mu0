
----------------------------------------------------------------------------
--  This file is a part of the peak detector VHDL model
--  Copyright (C) 2005  Jose Luis Nunez

--------------------------------------
--  entity       = serrx			         --
--  version      = 1.0              --
--  last update  = 22/07/05         --
--  author       = Jose Nunez       --
--------------------------------------


-- serial receiver

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";



entity serrx is
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
end;  

architecture struct of serrx is

type srcont_type is (waitforsihigh,wtforstart,chkstartlow,wtchtaken,wtnextbit,shiftbitonc3,chkstopvalid,wtfrerrack);

type srcontx_type is (wtstart,notrdy,datardy,wtack,datardy2,overerr,ovfrerr,frerr2,frerr1); 

type state_register_type is record
	srcont_state : srcont_type;
	srcontx_state : srcontx_type;
end record;

signal r, r_in: state_register_type; -- state register
signal rpd,c : std_logic_vector(7 downto 0);
signal chrdy,frer,newch,clrbcnt,si,chtkn,ensr : std_logic;


begin

si <= rxd;

srcont_process: process(r,c,si,chtkn)

variable v : state_register_type;
variable vchrdy,vfrer,vnewch,vrcnt,vensr : std_logic;

begin

vchrdy := '0';
vfrer := '0';
vnewch := '0';
vrcnt := '0';
vensr := '0'; 
v.srcont_state := r.srcont_state;


case v.srcont_state is

	when waitforsihigh => 
		vrcnt := '1';
		if (si = '1') then 
			v.srcont_state := wtforstart;
		end if;
	when wtforstart =>
		vrcnt := '1';  
		if (si = '0') then 
			v.srcont_state := chkstartlow;
		end if;
	when chkstartlow =>
		if(c(3) = '1' and si = '0') then 
				vnewch := '1';
				v.srcont_state := wtnextbit;
		elsif (c(3) = '1' and si = '1') then
				v.srcont_state := wtforstart;
		end if;
	when wtnextbit =>
		if(c(3) = '0') then --searching for 0d
			v.srcont_state := shiftbitonc3;
		end if;
	when shiftbitonc3 => 
		if (c(3) = '1' and c(7) = '0') then
			vensr := '1';
			v.srcont_state := wtnextbit;
		elsif (c(3) = '1' and c(7) = '1') then
			vensr := '1';
			v.srcont_state := chkstopvalid;
		end if;
	when chkstopvalid =>
		if (c(3) = '1' and c(4) = '1' and si = '1') then
			v.srcont_state := wtchtaken;
		elsif (c(3) = '1' and c(4) = '1' and si = '0') then
			v.srcont_state := wtfrerrack;
		end if;
	when wtchtaken =>
	       vchrdy := '1';
	       if (chtkn = '1') then
	          v.srcont_state := wtforstart;
	       end if; 
	when wtfrerrack =>
		vfrer := '1';
		vchrdy := '1';
		if (chtkn = '1') then
			v.srcont_state := waitforsihigh;
		end if;
	when others => null;
end case;	

r_in.srcont_state <= v.srcont_state;
chrdy <= vchrdy;
frer <= vfrer;
newch <= vnewch;
clrbcnt <= vrcnt;
ensr <= vensr; 
		
end process srcont_process;		


srcontx_process : process(r,frer,chrdy,newch,rxdone) 

variable v : state_register_type;
variable vdrdy,voverr,vfrerr : std_logic;


begin

v.srcontx_state := r.srcontx_state;
vdrdy := '0';
voverr := '0';
vfrerr := '0';

case v.srcontx_state is

	when wtstart =>  -- waiting for start
		if(chrdy = '0' and frer= '0') then 
			v.srcontx_state := notrdy;
		end if;
	when  notrdy => 
		if (frer = '1' and chrdy = '1') then
			v.srcontx_state := frerr1;
		elsif (chrdy ='1' and frer = '0') then
			v.srcontx_state := datardy;
		end if; 
	when  frerr1 =>
		vdrdy := '1';
		vfrerr := '1';
		if (rxdone = '1') then
			v.srcontx_state := wtack;
		elsif (newch = '1' and rxdone = '0') then
			v.srcontx_state := frerr2;
		end if;
 	when  frerr2 =>
 		vdrdy := '1';
 		vfrerr := '1';
 		if (chrdy = '1' and rxdone = '0') then
 			v.srcontx_state := ovfrerr;
 		elsif (rxdone = '1') then
 			v.srcontx_state := wtack;
 		end if; 
 	when  ovfrerr =>
 		vdrdy := '1';
 		voverr := '1';
 		vfrerr := '1';
 		if (rxdone = '1') then
 			v.srcontx_state := wtack;
 		end if;
 	when  wtack =>
 		if (rxdone = '0') then
 			v.srcontx_state := notrdy;
 		end if;
 	when datardy =>
 		vdrdy := '1';
 		if (rxdone = '1') then
 			v.srcontx_state := wtack;
 		elsif (newch = '1' and rxdone = '0') then
 			v.srcontx_state := datardy2;
 		end if;
 	when datardy2 =>
 		vdrdy := '1';
 		if (rxdone = '1') then
 			v.srcontx_state := wtack;
 		elsif (rxdone = '0' and frer = '1') then
 			v.srcontx_state := ovfrerr;
 		elsif (chrdy = '1' and rxdone = '0') then
 			v.srcontx_state := overerr;
 		end if;
 	when overerr =>
 		vdrdy := '1';
 		voverr := '1';
 		if (rxdone = '1') then
 			v.srcontx_state := wtack;
 		end if;
 		 
	when others => null;
	
end case;

chtkn <= vdrdy;
overr <= voverr;
frerr <= vfrerr;
r_in.srcontx_state <= v.srcontx_state;
	
		
end process srcontx_process;


rxrdy <= chtkn;




-- sequential part

regs: process (clk,clear)

begin

if (clear = '0') then
	r.srcontx_state <= wtstart;
	r.srcont_state <= waitforsihigh;
	rxdata <= (others => '0');
	rpd <= (others => '0');
	c <= (others => '0');
elsif rising_edge(clk) then
	if (reset = '0') then
		rpd <= (others => '0');
		rxdata <= (others => '0');
		r.srcontx_state <= wtstart;
		r.srcont_state <= waitforsihigh;
		c <= (others => '0');
	else
		if (clrbcnt = '1') then
			c <= (others => '0');
		else
			c <= c + 1;
		end if;
		if (ensr = '1') then
			rpd <= rxd & rpd(7 downto 1);
		end if;
		if (chrdy = '1') then
			rxdata <= rpd;
		end if;
		
		r <= r_in;
	end if;
end if;

end process regs;

end struct;









       