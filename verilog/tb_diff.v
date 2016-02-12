`timescale 1 ns / 10 ps
module tb_diff();
`include "constants.v"
//inputs
reg clk, rst;
wire [NBIT-1:0] din;
//outputs
wire signed [NBIT-1:0] dout;

//intermediate
wire over;
reg start;

differentiator DUT (
        .clk(clk),
        .rst(rst),
        .din(din),
        .dout(dout)
);

data_rom MEM (
        .clk(clk),
        .rst(rst),
        .start(start),
        .sample(din),
        .over(over)
);

initial
begin
        clk <= 1'b0;
        rst <= 1'b1;
        start <= 1'b0;
        #23
        rst <= 1'b0;
        start <= 1'b1;

end

always @(posedge(clk))
begin 
        if (start)
                $display("%d",dout);
end

always @(over)
begin
        if(over)
                $finish; //stop simulations
end

always 
begin
        #10
        clk <= ~clk;
end

endmodule

