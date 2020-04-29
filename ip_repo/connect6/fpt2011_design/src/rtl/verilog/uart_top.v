//--------------------------------------------------------------------------------------------
//    module      :    uart_top
//    top module  :    connect6
//    author      :    vipin k
//    description :    top module containing uart rx and tx sections
//    revision    :
//    17-8-2011   :    Initial draft
//--------------------------------------------------------------------------------------------
`define baud_rate    115200
`define sys_clk      100000000 
`define cnt_val      `sys_clk/(`baud_rate*16)

module uart_top(
input   wire       i_clk,
input   wire       i_rst,
input   wire       i_rx_data,
output  wire       o_tx_data,
output  wire [7:0] o_rx_data,
input   wire [7:0] i_tx_data,
output  wire       o_rx_data_valid,
input   wire       i_tx_data_valid,
input   wire       i_rx_data_read
);

integer counter;
reg baud_en;

uart_tx u1
  (
  .data_in(i_tx_data),
  .write_buffer(i_tx_data_valid),
  .reset_buffer(i_rst),
  .en_16_x_baud(baud_en),
  .clk(i_clk),
  .serial_out(o_tx_data),
  .buffer_full(),
  .buffer_half_full()
  ); 
  

uart_rx u2
  (
  .serial_in(i_rx_data),
  .read_buffer(i_rx_data_read),
  .reset_buffer(i_rst),
  .en_16_x_baud(baud_en),
  .clk(i_clk),
  .data_out(o_rx_data),
  .buffer_data_present(o_rx_data_valid),
  .buffer_full(),
  .buffer_half_full()
  ); 
 
  
always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst)
	begin
		counter <= 0;
		baud_en <= 1'b0;
	end
    else if(counter == `cnt_val) //baud_en should be 16 times the baud_rate
	begin
	    baud_en <= 1'b1;
		counter <= 0;
	end		 
	else	 
	begin
	    baud_en <= 1'b0;
	    counter <= counter + 1;
	end
end
  
endmodule
