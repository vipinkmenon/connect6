//--------------------------------------------------------------------------------------------
//    module      :    master_sm
//    top module  :    connect6
//    author      :    vipin k
//    description :    The master state machine
//    revision    :
//    17-8-2011   :    Initial draft
//    16-9-2011   :    Corrected bug in threat detection
//--------------------------------------------------------------------------------------------

`define empty_cell 2'b00
`define my_cell    2'b01
`define enemy_cell 2'b10

module master_sm(
input    wire       i_clk,
input    wire       i_rst,
(* keep = "true" *)
input    wire       i_uart_data_avail,
(* keep = "true" *)
input    wire [7:0] i_uart_rd_data,
output   reg  [7:0] o_uart_wr_data,
output   reg        o_uart_wr_en,
output   reg        o_uart_rd_en,
output   reg        o_sb_wr_en,
(* keep = "true" *)
output   reg  [1:0] o_sb_wr_data,
(* keep = "true" *)
output   reg  [4:0] o_sb_wr_row,
(* keep = "true" *)
output   reg  [4:0] o_sb_wr_col,
output   reg        o_chk_succ,
input    wire       i_chk_succ_done,
input    wire       i_succ_possible,
input    wire [4:0] i_td_row_addr1,
input    wire [4:0] i_td_col_addr1,
input    wire [4:0] i_td_row_addr2,
input    wire [4:0] i_td_col_addr2,
output   reg        o_chk_thrt,
output   reg        o_chk_pm,
input    wire       i_chk_pm_done,
input    wire       i_chk_thrt_done,
input    wire       i_thrt_detected,
output   reg        o_fpga_act,
output   reg        o_thrt_ack,
input    wire       i_single_place
);


wire   [7:0]    rand_cntr_value;
reg    [5:0]    state;
reg    [7:0]    uart_wr_buff[7:0];
reg    [3:0]    uart_rd_buff[2:0];
reg             thrt_flag;
reg    [1:0]    threat_cnt;
reg             pm_flag;
parameter       START      =    0,
                IDLE       =    1,
				TX1B1      =    2,
				TX1B2      =    3,
				TX1B3      =    4,
				TX1B4      =    5,
				TX2B1      =    6,
				TX2B2      =    7,
				TX2B3      =    8,
				TX2B4      =    9,
				RX1B1      =    10,
				RX1B2      =    11,
				RX1B3      =    12,
				RX1B4      =    13,
				RX2B1      =    14,
				RX2B2      =    15,
				RX2B3      =    16,
				RX2B4      =    17,
				CHK_SUCC   =    18,
			    CHK_TRT    =    19,
			    CHK_PM1    =    20,
			    CHK_PM2    =    21;

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst)
	begin
	    state         <=    START;
		o_uart_wr_en  <=    1'b0;
		o_uart_rd_en  <=    1'b0;
		o_fpga_act    <=    1'b0;
		o_chk_succ    <=    1'b0;
		o_chk_pm      <=    1'b0;
		thrt_flag     <=    1'b0;
		o_thrt_ack    <=    1'b0;
		threat_cnt    <=    0;
		o_uart_wr_data<=    0; 
		o_sb_wr_en    <=    0;
		o_sb_wr_data  <=    `empty_cell;
		o_chk_thrt    <=    1'b0;
		pm_flag       <=    1'b0;
	end
	else
	begin
	    case(state)
		    START:begin
			    if(i_uart_data_avail)   //Wait until the rafaree indication.
				begin
				    o_uart_rd_en    <=    1'b1;
					if(o_uart_rd_en & i_uart_rd_data == 'h44)   //FPGA is playing black
					begin                              //Replace if the initial placement needs to be random. Now always (10,10)
					    uart_wr_buff[4]    <=    8'h31;//{4'h3,3'h0,rand_cntr_value[0]};
					    uart_wr_buff[5]    <=    8'h30;//{4'h3,1'h0,rand_cntr_value[3:2],1'h1};
					    uart_wr_buff[6]    <=    8'h31;//{4'h3,3'h0,rand_cntr_value[1]};
					    uart_wr_buff[7]    <=    8'h30;//{4'h3,1'h0,rand_cntr_value[5:4],1'h1};
						o_uart_rd_en       <=    1'b0;
						state              <=    TX2B1;
					end
					else if(o_uart_rd_en)                         //FPGA is playing white so wait for first move
					begin
					    state         <=    RX2B1;
						o_uart_rd_en  <=    1'b0;
					end
				end
			end
			IDLE:begin
				o_sb_wr_en   <=    1'b0;
				o_fpga_act   <=    1'b0;
				o_uart_wr_en <=    1'b0;
				o_uart_rd_en <=    1'b0;
				threat_cnt   <=    0;
				if(i_uart_data_avail)
			        state        <=    RX1B1;
			end
			TX1B1:begin
                o_uart_wr_en    <=    1'b1;
				o_uart_wr_data  <=    uart_wr_buff[0];
                state           <=    TX1B2;
                o_fpga_act      <=    1'b1;				
			end
			TX1B2:begin
				o_uart_wr_data  <=    uart_wr_buff[1];
                state           <=    TX1B3;
                o_fpga_act      <=    1'b1;					
			end
			TX1B3:begin
				o_uart_wr_data  <=    uart_wr_buff[2];
                state           <=    TX1B4;
                o_fpga_act      <=    1'b1;				
			end
			TX1B4:begin
				o_uart_wr_data  <=    uart_wr_buff[3];

                o_fpga_act      <=    1'b1;	
                o_sb_wr_en      <=    1'b1;
                o_sb_wr_row     <=    uart_wr_buff[0][0]*10 + uart_wr_buff[1][3:0];
                o_sb_wr_col     <=    uart_wr_buff[2][0]*10 + uart_wr_buff[3][3:0];		
                o_sb_wr_data    <=    `my_cell;	
                state           <=    TX2B1;				
			end
			TX2B1:begin
			    o_uart_wr_en    <=    1'b1;
				o_sb_wr_en      <=    1'b0;
				o_uart_wr_data  <=    uart_wr_buff[4];
                state           <=    TX2B2;	
                o_fpga_act      <=    1'b1;	
                o_thrt_ack      <=    1'b0;				
			end
			TX2B2:begin
				o_uart_wr_data  <=    uart_wr_buff[5];
                state           <=    TX2B3;	
                o_fpga_act      <=    1'b1;				
			end
			TX2B3:begin
				o_uart_wr_data  <=    uart_wr_buff[6];
                state           <=    TX2B4;
                o_fpga_act      <=    1'b1;				
			end
			TX2B4:begin
				o_uart_wr_data  <=    uart_wr_buff[7];
				if(thrt_flag)
				begin
				    thrt_flag   <=    1'b0;
					state       <=    CHK_TRT;
				end
				else if(pm_flag)
				begin
                    state       <=    CHK_PM2;
					pm_flag     <=    0;
				end	
                else				
                    state       <=    IDLE;	
                o_fpga_act      <=    1'b1;		
                o_sb_wr_en      <=    1'b1;
                o_sb_wr_row     <=    uart_wr_buff[4][0]*10 + uart_wr_buff[5][3:0];
                o_sb_wr_col     <=    uart_wr_buff[6][0]*10 + uart_wr_buff[7][3:0];	
                o_sb_wr_data    <=    `my_cell;			
                o_chk_succ      <=    1'b0;				
			end
			RX1B1:begin
			    if(i_uart_data_avail)  
				begin
				    uart_rd_buff[0] <=    i_uart_rd_data[3:0];
				    o_uart_rd_en    <=    1'b1;
					if(o_uart_rd_en)
					begin
					    state         <=    RX1B2;
						o_uart_rd_en  <=    1'b0;
                        o_fpga_act    <=    1'b1;						
					end	
				end	
			end
			RX1B2:begin
			    if(i_uart_data_avail)   
				begin
				    o_uart_rd_en    <=    1'b1;
					uart_rd_buff[1] <=    i_uart_rd_data[3:0];
					if(o_uart_rd_en)
					begin
					    state         <=    RX1B3;
						o_uart_rd_en  <=    1'b0;
						o_fpga_act    <=    1'b1;
					end	
				end	
			end
			RX1B3:begin
			    if(i_uart_data_avail)   
				begin
				    o_uart_rd_en    <=    1'b1;
					uart_rd_buff[2] <=    i_uart_rd_data[3:0];
					if(o_uart_rd_en)
					begin
					    state         <=    RX1B4;
						o_uart_rd_en  <=    1'b0;
						o_fpga_act    <=    1'b1;
					end	
				end	
			end
			RX1B4:begin
			    if(i_uart_data_avail)   
				begin
				    o_uart_rd_en    <=    1'b1;
					if(o_uart_rd_en)
					begin
					    state         <=    RX2B1;
						o_uart_rd_en  <=    1'b0;
						o_sb_wr_en    <=    1'b1;
						o_sb_wr_row   <=    uart_rd_buff[0]*10 + uart_rd_buff[1];
						o_sb_wr_col   <=    uart_rd_buff[2]*10 + i_uart_rd_data[3:0];
						o_sb_wr_data  <=    `enemy_cell;
						o_fpga_act    <=    1'b1;
					end	
				end	
			end
			RX2B1:begin
			    o_sb_wr_en    <=    1'b0;
			    if(i_uart_data_avail)   
				begin
				    uart_rd_buff[0] <=    i_uart_rd_data[3:0];
				    o_uart_rd_en    <=    1'b1;
					if(o_uart_rd_en)
					begin
					    state         <=    RX2B2;
						o_uart_rd_en  <=    1'b0;
						o_fpga_act    <=    1'b1;
					end	
				end	
			end
			RX2B2:begin
			    if(i_uart_data_avail) 
				begin
				    o_uart_rd_en    <=    1'b1;
					uart_rd_buff[1] <=    i_uart_rd_data[3:0];
					if(o_uart_rd_en)
					begin
					    state         <=    RX2B3;
						o_uart_rd_en  <=    1'b0;
						o_fpga_act    <=    1'b1;
					end	
				end	
			end
			RX2B3:begin
			    if(i_uart_data_avail)  
				begin
				    o_uart_rd_en    <=    1'b1;
					uart_rd_buff[2] <=    i_uart_rd_data[3:0];
					if(o_uart_rd_en)
					begin
					    state         <=    RX2B4;
						o_uart_rd_en  <=    1'b0;
						o_fpga_act    <=    1'b1;
					end	
				end	
			end
			RX2B4:begin
			    if(i_uart_data_avail)  
				begin
				    o_uart_rd_en      <=    1'b1;
					if(o_uart_rd_en)
					begin
					    state         <=    CHK_SUCC;
						o_chk_succ    <=    1'b1;
						o_uart_rd_en  <=    1'b0;
						o_sb_wr_en    <=    1'b1;
						o_sb_wr_row   <=    uart_rd_buff[0]*10 + uart_rd_buff[1];
						o_sb_wr_col   <=    uart_rd_buff[2]*10 + i_uart_rd_data[3:0];
						o_sb_wr_data  <=    `enemy_cell;
						o_fpga_act    <=    1'b1;
					end	
				end	
			end
		    CHK_SUCC:begin
			    o_sb_wr_en    <=    1'b0;
				if(i_succ_possible)
				begin
				    if(i_td_row_addr1 > 9)
					begin
					    uart_wr_buff[0] <= 'h31;  //1
						uart_wr_buff[1] <= 'h30 + (i_td_row_addr1 - 10);
					end
					else
					begin
					    uart_wr_buff[0] <= 'h30;  //0
						uart_wr_buff[1] <= 'h30 + i_td_row_addr1;
					end
					if(i_td_col_addr1 > 9)
					begin
					    uart_wr_buff[2] <= 'h31;  //1
						uart_wr_buff[3] <= 'h30 + (i_td_col_addr1 - 10);
					end
					else
					begin
					    uart_wr_buff[2] <= 'h30;  //0
						uart_wr_buff[3] <= 'h30 + i_td_col_addr1;
					end
					if(i_single_place)
					begin
						if(i_td_row_addr2 > 9)
						begin
						    uart_wr_buff[4] <= 'h31;  //1
							uart_wr_buff[5] <= 'h30 + (i_td_row_addr1 - 10);
						end
						else
						begin
						    uart_wr_buff[4] <= 'h30;  //0
							uart_wr_buff[5] <= 'h30 + i_td_row_addr1;
						end
						if(i_td_col_addr2 > 9)
						begin
						    uart_wr_buff[6] <= 'h31;  //1
							uart_wr_buff[7] <= 'h30 + (i_td_col_addr1 - 10);
						end
						else
						begin
						    uart_wr_buff[6] <= 'h30;  //0
							uart_wr_buff[7] <= 'h30 + i_td_col_addr1;
						end
						state    <=     TX2B1;
					end	
					else
					begin
						if(i_td_row_addr2 > 9)
						begin
						    uart_wr_buff[4] <= 'h31;  //1
							uart_wr_buff[5] <= 'h30 + (i_td_row_addr2 - 10);
						end
						else
						begin
						    uart_wr_buff[4] <= 'h30;  //0
							uart_wr_buff[5] <= 'h30 + i_td_row_addr2;
						end
						if(i_td_col_addr2 > 9)
						begin
						    uart_wr_buff[6] <= 'h31;  //1
							uart_wr_buff[7] <= 'h30 + (i_td_col_addr2 - 10);
						end
						else
						begin
						    uart_wr_buff[6] <= 'h30;  //0
							uart_wr_buff[7] <= 'h30 + i_td_col_addr2;
						end
						state    <=     TX1B1;
					end
				end
				else if(i_chk_succ_done)
				begin
				    state       <=   CHK_TRT;
                    o_chk_thrt  <=   1'b1;		
                    o_chk_succ  <=   1'b0;					
				end	
			end
			CHK_TRT:begin
			    o_sb_wr_en    <=    1'b0;
				o_uart_wr_en  <=    1'b0;
			    if(i_thrt_detected & threat_cnt != 2 )
				begin
				    if(i_td_row_addr1 > 9)
					begin
					    uart_wr_buff[4] <= 'h31;  //1
						uart_wr_buff[5] <= 'h30 + (i_td_row_addr1 - 10);
					end
					else
					begin
					    uart_wr_buff[4] <= 'h30;  //0
						uart_wr_buff[5] <= 'h30 + i_td_row_addr1;
					end
					if(i_td_col_addr1 > 9)
					begin
					    uart_wr_buff[6] <= 'h31;  //1
						uart_wr_buff[7] <= 'h30 + (i_td_col_addr1 - 10);
					end
					else
					begin
					    uart_wr_buff[6] <= 'h30;  //0
						uart_wr_buff[7] <= 'h30 + i_td_col_addr1;
					end
					state      <=    TX2B1;
					thrt_flag  <=    1'b1;
					threat_cnt <=    threat_cnt + 1;
				end
			    else if(i_chk_thrt_done)
				begin
				    o_chk_thrt    <=    1'b0;
					if(threat_cnt == 0)
					begin
                        state         <=    CHK_PM1;
                        o_chk_pm      <=    1'b1;					
					end
                    else if(threat_cnt == 1)
                    begin
					    state         <=    CHK_PM2;
                        o_chk_pm      <=    1'b1;
                    end
                    else
                        state         <=    IDLE;					
				end
				if(i_thrt_detected)
				    o_thrt_ack        <=    1'b1;
				o_fpga_act    <=    1'b1;
			end
			CHK_PM1:begin
			    if(i_chk_pm_done)
				begin
				    o_chk_pm      <=    1'b0;
				    if(i_td_row_addr1 > 9)
					begin
					    uart_wr_buff[4] <= 'h31;  //1
						uart_wr_buff[5] <= 'h30 + (i_td_row_addr1 - 10);
					end
					else
					begin
					    uart_wr_buff[4] <= 'h30;  //0
						uart_wr_buff[5] <= 'h30 + i_td_row_addr1;
					end
					if(i_td_col_addr1 > 9)
					begin
					    uart_wr_buff[6] <= 'h31;  //1
						uart_wr_buff[7] <= 'h30 + (i_td_col_addr1 - 10);
					end
					else
					begin
					    uart_wr_buff[6] <= 'h30;  //0
						uart_wr_buff[7] <= 'h30 + i_td_col_addr1;
					end
                        state    <=     TX2B1;
						pm_flag  <=     1'b1;
				end
				o_fpga_act    <=    1'b1;
			end
			CHK_PM2:begin
			    o_chk_pm        <=     1'b1;
				o_uart_wr_en    <=     1'b0;
				o_sb_wr_en      <=     1'b0;
			    if(i_chk_pm_done)
				begin
				    o_chk_pm      <=    1'b0;
				    if(i_td_row_addr1 > 9)
					begin
					    uart_wr_buff[4] <= 'h31;  //1
						uart_wr_buff[5] <= 'h30 + (i_td_row_addr1 - 10);
					end
					else
					begin
					    uart_wr_buff[4] <= 'h30;  //0
						uart_wr_buff[5] <= 'h30 + i_td_row_addr1;
					end
					if(i_td_col_addr1 > 9)
					begin
					    uart_wr_buff[6] <= 'h31;  //1
						uart_wr_buff[7] <= 'h30 + (i_td_col_addr1 - 10);
					end
					else
					begin
					    uart_wr_buff[6] <= 'h30;  //0
						uart_wr_buff[7] <= 'h30 + i_td_col_addr1;
					end
					    state         <=    TX2B1;
				end
				o_fpga_act    <=    1'b1;
			end
		endcase
	end
end

//Uncomment to make the initial placement random when FPGA is playing black

/*counter rand_cntr(
  .i_clk(i_clk),
  .i_rst(i_rst),
  .o_value(rand_cntr_value)
);*/

endmodule
