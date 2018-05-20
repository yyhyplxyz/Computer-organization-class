`timescale 1ns / 1ps

module display_top(
    input CLK,
    input nclr,
    input CLK_190hz,
    input button,
    output [3:0] pos_ctrl,
    output [3:0] num_ctrl
);

reg [15:0] display_data;

    clkdiv_190hz(
        .CLK(CLK),
        .nclr(nclr),
        .CLK_190hz(CLK_190hz)
    );

    displayReg(
        .CLK_190hz,
        .disp_data(display_data),
        .nclr(nclr),
        .pos_ctrl(pos_ctrl),
        .num_ctrl(num_ctrl)
    );

    initial begin 
        display_data = 16'habc7;
    end

endmodule