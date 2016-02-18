`timescale 1 ns / 10 ps
module tb_diff();
`include "constants.v"
//inputs
reg clk, rst;
wire [NBIT-1:0] din;
//outputs
wire signed [NBIT-1:0] dout;
wire signed [NBIT-1:0] diff_out;
wire [NBIT-1:0] diff_in ;

//intermediate
wire over;
reg start;

integrator DUT (
        .clk(clk),
        .rst(rst),
        .din(diff_out),
        .dout(dout)
);

differentiator DIFF (
        .clk(clk),
        .rst(rst),
        .din(diff_in),
        .dout(diff_out)
);

data_rom MEM (
        .clk(clk),
        .rst(rst),
        .start(start),
        .sample(diff_in),
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

