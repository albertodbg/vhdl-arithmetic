--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dff is
	port(
	  rst: in std_logic;
	  clk: in std_logic;
	  load: in std_logic;
		d: in std_logic;
		q: out std_logic
	);
end dff;


architecture beh of dff is
begin
    process(rst,clk)
    begin
      if (rst='1') then
        q <= '0';
      else
        if (clk='1' and clk'event) then
          if (load='1') then
            q <= d;
          end if;
        end if;
      end if;
    end process;
end beh;





