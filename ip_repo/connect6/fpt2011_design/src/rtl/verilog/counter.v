//--------------------------------------------------------------------------------------------
//    module      :    counter
//    top module  :    master_sm
//    author      :    vipin k
//    description :    counter for generating initial random placement when FPGA is playing black
//    revision    :
//    17-8-2011   :    Initial draft
//--------------------------------------------------------------------------------------------

module counter(
input    wire      i_clk,
input    wire      i_rst,
output   reg [7:0] o_value
);

always @(posedge i_clk)
begin
    if(i_rst)
	    o_value    <=    0;
	else
        o_value    <=    o_value + 1'b1;	
end

endmodule
