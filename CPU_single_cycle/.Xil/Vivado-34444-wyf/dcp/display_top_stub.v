// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module display_top(CLK, clr, button, pos_ctrl, num_ctrl);
  input CLK;
  input clr;
  input button;
  output [3:0]pos_ctrl;
  output [7:0]num_ctrl;
endmodule
