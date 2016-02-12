module data_rom(
        clk,
        rst,
        start,
        sample,
        over
);
 
`include "constants.v"

input clk;
input rst;
input start;
output reg [NBIT-1:0] sample;
output reg over;

reg [NBIT-1:0] rom [0:NSAMPLES-1];
integer addr; //to acess the rom

initial
begin
        $readmemh("../data/Xecg.dat",rom,0,NSAMPLES-1);
end

always @(posedge(clk))
begin
        if (rst) //active high, synchronous reset
        begin
                over <= 1'b0;
                addr <= 0;
                sample <= 0; 
                //sample <= rom[0]; 
        end
        else if (start)
        begin
                if (addr < NSAMPLES )
                begin
                        sample <= rom[addr];
                        addr <= addr + 1;
                end
                else //if (addr >= NSAMPLES)
                begin
                        addr <= 0;
                        over <= 1'b1;
                end
        end
end

endmodule


