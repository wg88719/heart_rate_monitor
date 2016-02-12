`timescale 1 ns / 10 ps

module tb_data_rom(
);
 
`include "constants.v"

//inputs
reg clk;
reg rst;
reg start;
//outputs
wire [NBIT-1:0] sample;
wire [31:0] address;
wire over;

data_rom DUT(
        .clk(clk),
        .rst(rst),
        .start(start),
        .sample(sample),
        .over(over)
);

initial
begin
        clk <= 1'b0;
        rst <= 1'b1; //reset
        start <= 1'b0; //don't start yet
        #23
        rst <= 1'b0;
        #23
        start <= 1'b1;
end

always @(posedge(clk))
begin 
        if (start)
                $display("%d",sample);
end

always //clock generation
begin 
        #10 // clock frequency of 50MHz
        clk <= ~clk;
end

always @(over)
begin
        if(over)
                $finish; //stop simulations
end

endmodule
