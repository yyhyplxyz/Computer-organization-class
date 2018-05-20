-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_top is
  Port ( 
    CLK : in STD_LOGIC;
    clr : in STD_LOGIC;
    button : in STD_LOGIC;
    pos_ctrl : out STD_LOGIC_VECTOR ( 3 downto 0 );
    num_ctrl : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end display_top;

architecture stub of display_top is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
begin
end;
