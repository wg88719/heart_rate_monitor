module differentiator(
        clk,
        rst,
        din,
        dout,
);

`include "constants.v"

input clk, rst;
input [NBIT-1:0] din;
output reg signed [NBIT-1:0] dout;

reg [NBIT-1:0] pipe [0:ND-1];
integer i; //generic index

always  @(posedge(clk))
begin
        if (rst)
        begin
                for (i = 0; i < ND; i = i + 1)
                        pipe[i] <= 0;
                dout <= 0;
       end
       else
       begin
               pipe[0] <= din;
               for (i = 1; i < ND; i = i + 1)
                       pipe[i] <= pipe[i-1];
       end
end

always @(din or pipe[ND-1])
begin
        dout = din - pipe[ND-1];
end

endmodule
