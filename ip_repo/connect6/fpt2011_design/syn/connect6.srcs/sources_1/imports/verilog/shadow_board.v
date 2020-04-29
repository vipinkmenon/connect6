//--------------------------------------------------------------------------------------------
//    module      :    shadow_board
//    top module  :    connect6
//    author      :    vipin k
//    description :    Local copy of the playing board
//    revision    :
//    17-8-2011   :    Initial draft
//--------------------------------------------------------------------------------------------
`define empty_cell 2'b00
`define my_cell    2'b01
`define enemy_cell 2'b10


module shadow_board(
input    wire        i_clk,
input    wire        i_rst,
input    wire [1:0]  i_ms_wr_data,
input    wire        i_ms_wr_en,
input    wire [4:0]  i_ms_wr_row,
input    wire [4:0]  i_ms_wr_col,
input    wire [4:0]  i_rd_row,
input    wire [4:0]  i_rd_col,
output   wire [1:0]  o_rd_data
);


reg [1:0] mem [1:19][1:19];
integer i;
integer j;

assign    o_rd_data    =    mem[i_rd_row][i_rd_col];

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst)
	begin
	    for(i=1;i<20;i=i+1)
		begin
		    for(j=1;j<20;j=j+1)
			begin
	            mem[i][j]    <=   `empty_cell; 
			end	
		end	
	end
	else
	begin
	    if(i_ms_wr_en)
		    mem[i_ms_wr_row][i_ms_wr_col]    <=    i_ms_wr_data;
	end
end

endmodule
