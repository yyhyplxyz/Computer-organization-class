`timescale 1ns / 1ps

module display_top(
    input CLK,
    input clr,
    input button,
    output [3:0] pos_ctrl,
    output [7:0] num_ctrl
);
    
    wire CLK_190hz;
    wire out_button;
    wire disp_data;
    reg [15:0] display_data;
    
    initial begin
        display_data = 16'h1234;
    end


    clkdiv_190hz my_clkdiv_190hz(
        .CLK(CLK),
//        .clr(clr),
        .CLK_190hz(CLK_190hz)
    );

    displayReg my_displayReg(
        .CLK_190hz(CLK_190hz),
        .disp_data(disp_data),
        .clr(clr),
        .pos_ctrl(pos_ctrl),
        .num_ctrl(num_ctrl)
    );

    debouncing my_debouncing(
         .rst(clr),
         .clk(CLK),
        .key_n(button),
        .key_pulse(out_button)
    );

endmodule