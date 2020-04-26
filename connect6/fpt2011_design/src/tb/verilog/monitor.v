//--------------------------------------------------------------------------------------------
//    module      :    monitor
//    top module  :   
//    author      :    vipin k
//    description :    Test bench file, which monitors the placements of the FPGA.
//    revision    :
//    17-8-2011   :    Initial draft
//--------------------------------------------------------------------------------------------

`timescale 1ns/1ps
module monitor();

reg flag;

reg [7:0] byte1;
reg [7:0] byte2;
reg [7:0] byte3;
reg [7:0] byte4;
integer file;
reg first_flag;

initial
begin
    wait(connect6.w_uart_rx_data_valid);
	@(posedge connect6.i_clk)
	if(connect6.w_uart_rx_data != 'h57) //fpga is black
	begin
	    wait(connect6.w_uart_tx_data_en);
		file = $fopen("fpga_out","w");
        @(posedge connect6.i_clk)
		byte1 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk)
		byte2 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk)
		byte3 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk)
		byte4 = connect6.w_uart_tx_data-'h30;	
        $display("FPGA Placed at ROW    : %d",byte1*10+byte2);
		$display("FPGA Placed at COLUMN : %d",byte3*10+byte4);
		$fwrite(file,"%0d\n",byte1*10+byte2);
		$fwrite(file,"%0d\n",byte3*10+byte4);
		@(posedge connect6.i_clk);
		@(posedge connect6.i_clk);	
        $fclose(file); 		
	end
    forever
	begin
        wait(connect6.w_uart_tx_data_en);
		file = $fopen("fpga_out","w");	//Each time file is opened and closed due to some simulator limitations    
        @(posedge connect6.i_clk);      //Values written in this file is used by the TCL script to update the gui
		byte1 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk);
		byte2 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk);
		byte3 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk);
		byte4 = connect6.w_uart_tx_data-'h30;	
        $display("FPGA Placed at ROW    : %d",byte1*10+byte2);
		$display("FPGA Placed at COLUMN : %d",byte3*10+byte4);
		$fwrite(file,"%0d\n",byte1*10+byte2);
		$fwrite(file,"%0d\n",byte3*10+byte4);
		#10;
		wait(connect6.w_uart_tx_data_en); 
		@(posedge connect6.i_clk);
		byte1 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk);
		byte2 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk);
		byte3 = connect6.w_uart_tx_data-'h30;
        @(posedge connect6.i_clk);
		byte4 = connect6.w_uart_tx_data-'h30;	
		@(posedge connect6.i_clk);
		@(posedge connect6.i_clk);
        $display("FPGA Placed at ROW    : %d",byte1*10+byte2);
		$display("FPGA Placed at COLUMN : %d",byte3*10+byte4);
		$fwrite(file,"%0d\n",byte1*10+byte2);
		$fwrite(file,"%0d\n",byte3*10+byte4);
		$fclose(file); 
	end
end



endmodule
