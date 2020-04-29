//--------------------------------------------------------------------------------------------
//    module      :    threat_detector
//    top module  :    connect6
//    author      :    vipin k
//    description :    Module which checks threat and finds the best placement.
//    revision    :
//    19-8-2011   :    Initial draft
//    24-8-2011   :    Added threat detection algorithm
//    07-9-2011   :    Added logic to check winning possibility
//    08-9-2011   :    Added placement weight function
//    21-9-2011   :    Updated placement weight function and threat generation logic
//--------------------------------------------------------------------------------------------

`define empty_cell 2'b00
`define my_cell    2'b01
`define enemy_cell 2'b10

module threat_detector(
input    wire       i_clk,
input    wire       i_rst,
input    wire       i_chk_succ,
output   reg        o_chk_succ_done,
output   reg        o_succ_possible,
output   reg  [4:0] o_td_row_addr1,
output   reg  [4:0] o_td_col_addr1,
output   reg  [4:0] o_td_row_addr2,
output   reg  [4:0] o_td_col_addr2,
input    wire       i_chk_thrt,
input    wire       i_chk_pm,
output   reg        o_chk_pm_done,
output   reg        o_chk_thrt_done,
output   reg        o_thrt_detected,
input    wire       i_thrt_ack,
output   reg  [4:0] o_sb_rd_row,
output   reg  [4:0] o_sb_rd_col,
input    wire [1:0] i_sb_rd_data,
output   reg        o_single_place
);

wire   [4:0]    board_weight;
reg    [4:0]    curr_board_weight;
reg    [4:0]    state;
reg    [4:0]    sm_state;
reg    [4:0]    curr_row;
reg    [4:0]    curr_col;
reg             check_row;
reg             check_col;
reg             check_d;
reg             check_c;
reg             check_row_done;
reg             check_col_done;
reg             check_d_done;
reg             check_c_done;
reg    [2:0]    cnt;
reg    [2:0]    my_cnt;
reg    [2:0]    enemy_cnt;
reg    [4:0]    empty_cell_col_1;
reg    [4:0]    empty_cell_row_1;
reg    [4:0]    empty_cell_col_2;
reg    [4:0]    empty_cell_row_2;
reg    [4:0]    row_cnt;
reg    [4:0]    col_cnt;
reg    [4:0]    free_cnt;
reg             flag1;
reg             find_empty;
reg    [7:0]    cell_my_wgt;
reg    [7:0]    cell_enemy_wgt;
reg             find_empty_done;
reg             cell_not_empty;
reg    [6:0]    row_my_wgt_cnt;
reg    [6:0]    col_my_wgt_cnt;
reg    [6:0]    d1_my_wgt_cnt;
reg    [6:0]    d2_my_wgt_cnt;
reg    [3:0]    row_my_total_cnt;
reg    [3:0]    col_my_total_cnt;
reg    [3:0]    d1_my_total_cnt;
reg    [3:0]    d2_my_total_cnt;
reg    [6:0]    row_enemy_wgt_cnt;
reg    [6:0]    col_enemy_wgt_cnt;
reg    [6:0]    d1_enemy_wgt_cnt;
reg    [6:0]    d2_enemy_wgt_cnt;
reg    [3:0]    row_enemy_total_cnt;
reg    [3:0]    col_enemy_total_cnt;
reg    [3:0]    d1_enemy_total_cnt;
reg    [3:0]    d2_enemy_total_cnt;
reg    [3:0]    row_my_cnt;
reg    [3:0]    col_my_cnt;
reg    [3:0]    d1_my_cnt;
reg    [3:0]    d2_my_cnt;
reg    [3:0]    row_enemy_cnt;
reg    [3:0]    col_enemy_cnt;
reg    [3:0]    d1_enemy_cnt;
reg    [3:0]    d2_enemy_cnt;
reg    [5:0]    curr_cell_wgt;
reg    [4:0]    best_cell_row;
reg    [4:0]    best_cell_col;
reg             chk_pm_done;
reg             enemy_cell_flag;
reg             my_cell_flag;
reg             first_flag;
reg             enemy_cell_assigned;
reg             cell_assn_flag;
reg             en_cell_assn_flag;
reg    [2:0]    threat_cnt;
reg    [2:0]    curr_threat_cnt;
reg             first_place;
//State machine parameters. Used by two SMs.
parameter   IDLE     =    0,
            ROW_CHK  =    1,
			COL_CHK  =    2,
			WAIT_ACK =    3,
			D1_CHK   =    4,
			D2_CHK   =    5,
			C1_CHK   =    6,
			C2_CHK   =    7,
			FND_E1   =    8,
			CALC_WT  =    9,
			ADD1     =    10,
			ADD2     =    11,
			ADD3     =    12,
			ADD4     =    13,
			COMP_WGT =    14,
			ROW_L    =    15,
			ROW_R    =    16,
			COL_U    =    17,
			COL_D    =    18,
			D_TR     =    19,
			D_BL     =    20,
			D_TL     =    21,
			D_BR     =    22,
			SND_PM   =    23;
			
//This state machine generates control signals based on signals from master state machine.			
			
always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst)
	begin
	    state               <= IDLE;
		curr_row            <= 1;
		curr_col            <= 1;
		check_row           <= 1'b0;
		check_col           <= 1'b0;
		check_d             <= 1'b0;
		check_c             <= 1'b0;
		o_chk_thrt_done     <= 1'b0;
		flag1               <= 1'b0;  	
        row_cnt             <= 1;
        col_cnt             <= 1;		
		find_empty          <= 1'b0;
		o_chk_succ_done     <= 1'b0;
		cell_my_wgt         <= 0;
		cell_enemy_wgt      <= 0;
		curr_cell_wgt       <= 0;
		best_cell_col       <= 1;
		best_cell_row       <= 1;
		first_flag          <= 1'b0;
		enemy_cell_assigned <= 1'b0;
		cell_assn_flag      <= 1'b0;
		en_cell_assn_flag   <= 1'b0;
		threat_cnt          <= 0;
		curr_threat_cnt     <= 0;
		first_place         <= 1'b1;
	end
	else
	begin
	    case(state)
	        IDLE:begin
			    curr_row            <=    1;
				curr_col            <=    1;
				chk_pm_done         <=    1'b0;
				curr_cell_wgt       <=    0;
				enemy_cell_assigned <=    1'b0;
				threat_cnt          <=    0;
				curr_threat_cnt     <=    0;
				curr_board_weight   <=    0;
				first_place         <=    1'b1;
		        if(i_chk_thrt & ~o_chk_thrt_done)
			    begin
			        state    <=    ROW_CHK; 
                    o_chk_succ_done <= 1'b0;					
			    end
				else if(i_chk_succ & ~o_chk_succ_done)
				begin
				    state    <=    ROW_CHK;
				end
				else if(i_chk_pm)
				begin
					state         <=    FND_E1;
					curr_col      <=    0;
				end
				if(i_chk_pm|i_chk_succ)
				    o_chk_thrt_done    <=    1'b0;
		    end
			ROW_CHK:begin
			    check_row    <=    1'b1;
				if(check_row_done)
				begin
				    if((curr_row == 19) && ((o_thrt_detected && (empty_cell_col_1 + 1) > 14) || (~o_thrt_detected & (curr_col >= 14))))
					begin
					    state      <=    COL_CHK;
						check_row  <=    1'b0;
						curr_row   <=    1;
						curr_col   <=    1;
					end	
					else if((o_thrt_detected && (empty_cell_col_1 + 1) > 14) || (~o_thrt_detected & (curr_col >= 14)))
                    begin
					    curr_row    <=  curr_row + 1;
						curr_col    <=  1;
						state       <=  ROW_CHK;
                    end					
					else if(o_thrt_detected)
					begin
                        curr_col    <=  empty_cell_col_1+1;
						state       <=  ROW_CHK;
					end	
                    else
					begin
                        curr_col    <=  curr_col + 1;					
						state       <=  ROW_CHK;
					end	
				end	
			end
			COL_CHK:begin
			    check_col    <=    1'b1;
				if(check_col_done)
				begin
				    if((curr_col == 19) && ((o_thrt_detected && (empty_cell_row_1 + 1) > 14) || (~o_thrt_detected & (curr_row >= 14))))
					begin
					    state     <=    D1_CHK;
						check_col <=    1'b0;
						curr_row  <=    1;
						curr_col  <=    1;
						row_cnt   <=    1;
					end	
					else if((o_thrt_detected && (empty_cell_row_1 + 1) > 14) || (~o_thrt_detected & (curr_row >= 14)))
                    begin
					    curr_col    <=  curr_col + 1;
						curr_row    <=  1;
						state       <=  COL_CHK;
                    end					
					else if(o_thrt_detected)
					begin
                        curr_row    <=  empty_cell_row_1+1;
						state       <=  COL_CHK;
					end	
                    else
					begin
                        curr_row    <=  curr_row + 1;					
						state       <=  COL_CHK;
					end	
				end				
			end
			D1_CHK:begin
			    check_d    <=    1'b1;
				if(check_d_done)
				begin
				    if(curr_row == 15 && curr_col == 1)
					begin
					    state    <=    D2_CHK;
						curr_row <=    1;
						curr_col <=    2;
						col_cnt  <=    2;
						check_d <=    1'b0;
                    end
                    else if((o_thrt_detected && (empty_cell_row_1 + 1) > 14 ) || (~o_thrt_detected & (curr_row >= 14)))
                    begin
					    curr_row <=    row_cnt +  1;
						row_cnt  <=    row_cnt +  1;
						curr_col <=    1;
						state    <=    D1_CHK;
                    end	
                    else if(o_thrt_detected)
                    begin
                        curr_row    <=  empty_cell_row_1+1;
						curr_col    <=  empty_cell_col_1+1;
						state       <=  D1_CHK;					
                    end
                    else
                    begin
					    curr_row    <=  curr_row + 1;
						curr_col    <=  curr_col + 1;
						state       <=  D1_CHK;
                    end					
				end
			end
			D2_CHK:begin
			    check_d    <=    1'b1;
				if(check_d_done)
				begin
				    if(curr_col == 15 && curr_row == 1)
					begin
					    state    <=    C1_CHK;
						check_d  <=    1'b0;
						col_cnt  <=    1;
						curr_row <=    19;
						curr_col <=    1;
                    end
                    else if((o_thrt_detected && (empty_cell_col_1 + 1) > 14 ) || (~o_thrt_detected & (curr_col >= 14)))
                    begin
					    curr_col <=    col_cnt +  1;
						col_cnt  <=    col_cnt +  1;
						curr_row <=    1;
						state    <=    D2_CHK;
                    end	
                    else if(o_thrt_detected)
                    begin
                        curr_row    <=  empty_cell_row_1+1;
						curr_col    <=  empty_cell_col_1+1;
						state       <=  D2_CHK;					
                    end
                    else
                    begin
					    curr_row    <=  curr_row + 1;
						curr_col    <=  curr_col + 1;
						state       <=  D2_CHK;
                    end					
				end
			end
			C1_CHK:begin
			    check_c    <=    1'b1;
				if(check_c_done)
				begin
				    if(curr_col == 15 && curr_row == 19)
					begin
					    state    <=    C2_CHK;
						check_c  <=    1'b0;
						row_cnt  <=    18;
						curr_row <=    18;
						curr_col <=    1;
                    end
                    else if((o_thrt_detected && (empty_cell_col_1 + 1) > 14 ) || (~o_thrt_detected & (curr_col >= 14)))
                    begin
					    curr_col <=    col_cnt +  1;
						col_cnt  <=    col_cnt +  1;
						curr_row <=    19;
						state    <=    C1_CHK;
                    end	
                    else if(o_thrt_detected)
                    begin
                        curr_row    <=  empty_cell_row_1-1;
						curr_col    <=  empty_cell_col_1+1;
						state       <=  C1_CHK;					
                    end
                    else
                    begin
					    curr_row    <=  curr_row - 1;
						curr_col    <=  curr_col + 1;
						state       <=  C1_CHK;
                    end					
				end			
			end
			C2_CHK:begin
			    check_c    <=    1'b1;
				if(check_c_done)
				begin
				    if(curr_col == 1 && curr_row == 5)
					begin
					    state    <=    IDLE;
						check_c  <=    1'b0;
                        o_chk_thrt_done <= i_chk_thrt;
						o_chk_succ_done <= i_chk_succ;
                    end
                    else if((o_thrt_detected && (empty_cell_row_1 - 1) < 6 ) || (~o_thrt_detected & (curr_row <= 6)))
                    begin
					    curr_col <=    1;
						curr_row <=    row_cnt - 1;
						row_cnt  <=    row_cnt - 1;
						state    <=    C2_CHK;
                    end	
                    else if(o_thrt_detected)
                    begin
                        curr_row    <=  empty_cell_row_1-1;
						curr_col    <=  empty_cell_col_1+1;
						state       <=  C2_CHK;					
                    end
                    else
                    begin
					    curr_row    <=  curr_row - 1;
						curr_col    <=  curr_col + 1;
						state       <=  C2_CHK;
                    end					
				end			
			end
			FND_E1:begin
                find_empty        <= 1'b1;
				cell_assn_flag    <= 1'b0;
				en_cell_assn_flag <= 1'b0;
				threat_cnt        <= 0;
				if(curr_row == 19 && curr_col ==  19)
				begin
				    state         <=    WAIT_ACK;
					find_empty    <=    1'b0;
					chk_pm_done   <=    1'b1;
				end	
				else if(curr_col == 19)
                begin
                    curr_row    <=     curr_row +  1;
                    curr_col    <=     1'b1;					
			        state       <=     CALC_WT;
					cell_my_wgt <=     0;
					cell_enemy_wgt <=  0;
				end
                else
				begin
                    curr_col    <=     curr_col + 1;				
			        state       <=     CALC_WT;
					cell_my_wgt <=     0;
					cell_enemy_wgt <=  0;
				end	
			end
			CALC_WT:begin
			    if(find_empty_done)
				begin
				    find_empty    <=    1'b0;
				    if(cell_not_empty)
					    state    <=    FND_E1;
					else
                    begin
					    state            <=  ADD1;
						if(first_place)
						begin
		                    best_cell_row    <=  curr_row;
					        best_cell_col    <=  curr_col;
							first_place      <=  1'b0;
						end	
                    end					
				end
			end
			ADD1:begin
			    if(d2_my_total_cnt >= 6) //success is possible
				begin
                    if((d2_my_wgt_cnt >= row_my_wgt_cnt) && (d2_my_wgt_cnt >= col_my_wgt_cnt) && ((d2_my_wgt_cnt >= d1_my_wgt_cnt)))
                    begin
					    cell_my_wgt    <=    d2_my_wgt_cnt;
						cell_assn_flag <=    1'b1;
                    end	
					else
					    cell_my_wgt    <=    d2_my_cnt;
					if(d2_my_cnt == 3 & (d2_my_wgt_cnt > 6))
                        threat_cnt     <=    threat_cnt + 1;					
				end		
				if(d2_enemy_total_cnt >= 6)
                begin
                    if((d2_enemy_wgt_cnt >= row_enemy_wgt_cnt) && (d2_enemy_wgt_cnt >= col_enemy_wgt_cnt) && ((d2_enemy_wgt_cnt >= d1_enemy_wgt_cnt)))
                    begin
					    cell_enemy_wgt    <=    d2_enemy_wgt_cnt;
						en_cell_assn_flag <=    1'b1;
                    end	
					else
					    cell_enemy_wgt    <=    d2_enemy_cnt;
				end						
                state    <=     ADD2;					
			end
			ADD2:begin
			    if(d1_my_total_cnt >= 6)
				begin
                   	if(cell_assn_flag)
                        cell_my_wgt    <=     cell_my_wgt +  d1_my_cnt;
					else if((d1_my_wgt_cnt >= row_my_wgt_cnt) && (d1_my_wgt_cnt >= col_my_wgt_cnt) && ((d1_my_wgt_cnt >= d2_my_wgt_cnt)))
                    begin
					    cell_my_wgt    <=    cell_my_wgt + d1_my_wgt_cnt;
						cell_assn_flag <=    1'b1;
                    end	
					else
					    cell_my_wgt    <=    cell_my_wgt + d1_my_cnt;
					if(d1_my_cnt == 3 & (d1_my_wgt_cnt > 6))
                        threat_cnt     <=    threat_cnt + 1;							
				end		
				if(d1_enemy_total_cnt >= 6)
                begin
				    if(en_cell_assn_flag)
					    cell_enemy_wgt    <=    cell_enemy_wgt + d1_enemy_cnt;
					else if((d1_enemy_wgt_cnt >= row_enemy_wgt_cnt) && (d1_enemy_wgt_cnt >= col_enemy_wgt_cnt) && ((d1_enemy_wgt_cnt >= d2_enemy_wgt_cnt)))
                    begin
					    cell_enemy_wgt    <=    cell_enemy_wgt + d1_enemy_wgt_cnt;
						en_cell_assn_flag <=    1'b1;
                    end	
					else
					     cell_enemy_wgt    <=    cell_enemy_wgt + d1_enemy_cnt;
				end					
                state    <=     ADD3;					
			end	
			ADD3:begin
			    if(col_my_total_cnt >= 6)
				begin
				    if(cell_assn_flag)
                        cell_my_wgt    <=     cell_my_wgt +  col_my_cnt;
					else if((col_my_wgt_cnt >= row_my_wgt_cnt) && (col_my_wgt_cnt >= d1_my_wgt_cnt) && ((col_my_wgt_cnt >= d2_my_wgt_cnt)))
                    begin
					    cell_my_wgt    <=    cell_my_wgt + col_my_wgt_cnt;
						cell_assn_flag <=    1'b1;
                    end	
					else
					    cell_my_wgt    <=    cell_my_wgt + col_my_cnt;
					if(col_my_cnt == 3 & (col_my_wgt_cnt > 6))
                        threat_cnt     <=    threat_cnt + 1;	
                end					
				if(col_enemy_total_cnt >= 6)
                begin
				    if(en_cell_assn_flag)
					    cell_enemy_wgt    <=    cell_enemy_wgt + col_enemy_cnt;
					else if((col_enemy_wgt_cnt >= row_enemy_wgt_cnt) && (col_enemy_wgt_cnt >= d1_enemy_wgt_cnt) && ((col_enemy_wgt_cnt >= d2_enemy_wgt_cnt)))
                    begin
					    cell_enemy_wgt    <=    cell_enemy_wgt + col_enemy_wgt_cnt;
						en_cell_assn_flag <=    1'b1;
                    end	
					else
					     cell_enemy_wgt    <=    cell_enemy_wgt + col_enemy_cnt;
                end					
                state    <=     ADD4;					
			end
			ADD4:begin
			    if(row_my_total_cnt >= 6)
				begin
				    if(cell_assn_flag)
                        cell_my_wgt    <=     cell_my_wgt +  row_my_cnt;
				    else if((row_my_wgt_cnt >= col_my_wgt_cnt) && (row_my_wgt_cnt >= d1_my_wgt_cnt) && ((row_my_wgt_cnt >= d2_my_wgt_cnt)))
					begin
                        cell_my_wgt    <=     cell_my_wgt + row_my_wgt_cnt;
					end	
					else
					    cell_my_wgt    <=     cell_my_wgt + row_my_cnt;
					if(row_my_cnt == 3 & (row_my_wgt_cnt > 6))
                        threat_cnt     <=    threat_cnt + 1;		
				end	
				if(row_enemy_total_cnt >= 6)
                begin
					if(en_cell_assn_flag)
					    cell_enemy_wgt    <=    cell_enemy_wgt + row_enemy_cnt;
				    else if((row_enemy_wgt_cnt >= col_enemy_wgt_cnt) && (row_enemy_wgt_cnt >= d1_enemy_wgt_cnt) && ((row_enemy_wgt_cnt >= d2_enemy_wgt_cnt)))
					begin
                        cell_enemy_wgt    <=     cell_enemy_wgt + row_enemy_wgt_cnt;
						en_cell_assn_flag <=    1'b1;
					end	
					else
					    cell_enemy_wgt    <=    cell_enemy_wgt + row_enemy_cnt;
				end					
                state    <=     COMP_WGT;					
			end
			COMP_WGT:begin
			    if(~first_flag)
				begin
                    curr_cell_wgt    <=    cell_my_wgt;					
					best_cell_row    <=    curr_row;
					best_cell_col    <=    curr_col;
					first_flag       <=    1'b1;
				end
				else if((threat_cnt >= curr_threat_cnt) & threat_cnt != 0)
				begin
				    if(threat_cnt > curr_threat_cnt)
					begin
				        best_cell_row    <=    curr_row;
					    best_cell_col    <=    curr_col;    
					    enemy_cell_assigned <= 1'b1;
					    curr_cell_wgt    <=    cell_enemy_wgt + cell_my_wgt;
					    curr_threat_cnt  <=    threat_cnt;
						curr_board_weight <=   board_weight;
					end	
					else
					begin
					    if((cell_enemy_wgt + cell_my_wgt) > curr_cell_wgt)
					    begin
					        best_cell_row    <=    curr_row;
					        best_cell_col    <=    curr_col;    
					        enemy_cell_assigned <= 1'b1;
					        curr_cell_wgt    <=    cell_enemy_wgt + cell_my_wgt;
					        curr_threat_cnt  <=    threat_cnt;  
                            curr_board_weight <=   board_weight;							
					    end
						else if((cell_enemy_wgt + cell_my_wgt) == curr_cell_wgt)
						begin
						    if(board_weight > curr_board_weight)
							begin
							    best_cell_row    <=    curr_row;
					            best_cell_col    <=    curr_col;    
					            enemy_cell_assigned <= 1'b1;
					            curr_cell_wgt    <=    cell_enemy_wgt + cell_my_wgt;
					            curr_threat_cnt  <=    threat_cnt;  
								curr_board_weight <=   board_weight;
							end
						end
					end
				end
				else if((cell_enemy_wgt > 14 & ~enemy_cell_assigned) || (cell_enemy_wgt > 14 & enemy_cell_assigned & (cell_enemy_wgt > curr_cell_wgt)))
				begin
					curr_cell_wgt    <=    cell_enemy_wgt;
					best_cell_row    <=    curr_row;
					best_cell_col    <=    curr_col;	
                    enemy_cell_assigned <= 1'b1;					
				end
				else if((cell_my_wgt >= curr_cell_wgt) & ~enemy_cell_assigned & (row_my_cnt != 4) & (col_my_cnt != 4) & (d1_my_cnt != 4) & (d2_my_cnt != 4))
				begin
				    if(cell_my_wgt > curr_cell_wgt)
					begin
					    curr_cell_wgt    <=    cell_my_wgt;
					    best_cell_row    <=    curr_row;
					    best_cell_col    <=    curr_col;	
                        curr_board_weight <=   board_weight;						
					end
                    else
                    begin
					    if(board_weight > curr_board_weight)
						begin
						    curr_cell_wgt    <=    cell_my_wgt;
					        best_cell_row    <=    curr_row;
					        best_cell_col    <=    curr_col;	
                            curr_board_weight <=   board_weight;
						end
                    end					
				end
				state    <=    FND_E1;
			end
			WAIT_ACK:begin
			    if(o_chk_pm_done)
				begin
				    state       <=    IDLE;
					chk_pm_done <=    0;
				end	
			end
		endcase	
	end
end

//This state machine is controlled by the signals from the previous state machine.
//This SM reads data from shadow board and calculated the weights for each cell in all directions.
always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst)
	begin
	    sm_state          <= IDLE;
		cnt               <= 0;
		check_row_done    <= 1'b0;
		check_col_done    <= 1'b0;
		check_d_done      <= 1'b0;
		check_c_done      <= 1'b0;
		cnt               <= 0;
		enemy_cnt         <= 0;
		my_cnt            <= 0;
		free_cnt          <= 0;
		o_sb_rd_row       <= 1;
		o_sb_rd_col       <= 1;
		o_td_row_addr1    <= 1;
		o_td_col_addr1    <= 1;
		o_td_row_addr2    <= 1;
		o_td_col_addr2    <= 1;
		o_thrt_detected   <= 1'b0;
		empty_cell_col_1  <= 1;
		empty_cell_row_1  <= 1;
		empty_cell_col_2  <= 1;
		empty_cell_row_2  <= 1;
		o_single_place    <= 1'b0;
		o_succ_possible   <= 1'b0;
		o_chk_pm_done     <= 1'b0;
	    row_my_wgt_cnt    <= 0;
		col_my_wgt_cnt    <= 0;
		d1_my_wgt_cnt     <= 0;
		d2_my_wgt_cnt     <= 0;
	    row_enemy_wgt_cnt <= 0;
		col_enemy_wgt_cnt <= 0;
		d1_enemy_wgt_cnt  <= 0;
		d2_enemy_wgt_cnt  <= 0;
		row_my_total_cnt  <= 0;
		col_my_total_cnt  <= 0;
		d1_my_total_cnt   <= 0;
		d2_my_total_cnt   <= 0;
		row_enemy_total_cnt <= 0;
		col_enemy_total_cnt <= 0;
		d1_enemy_total_cnt<= 0;
		d2_enemy_total_cnt<= 0;
		row_my_cnt        <= 0;
		col_my_cnt        <= 0;
		d1_my_cnt         <= 0;
		d2_my_cnt         <= 0;
		row_enemy_cnt     <= 0;
		col_enemy_cnt     <= 0;
		d1_enemy_cnt      <= 0;
		d2_enemy_cnt      <= 0;
		my_cell_flag      <= 0;
		enemy_cell_flag   <= 0;
	end
	else
	begin
	    case(sm_state)
		    IDLE:begin
			    check_row_done    <=    1'b0;
				check_col_done    <=    1'b0;
				check_d_done      <=    1'b0;
				check_c_done      <=    1'b0;
				find_empty_done   <=    1'b0;
				cell_not_empty    <=    1'b0;
				o_sb_rd_row       <=    curr_row;
				o_sb_rd_col       <=    curr_col;
				cnt               <=    0;
				enemy_cnt         <=    0;
				my_cnt            <=    0;
				free_cnt          <=    0;
				o_chk_pm_done     <=    1'b0;
			    if(check_row & ~check_row_done)
				begin
				    sm_state    <=    ROW_CHK;
				end	
				else if(check_col & ~check_col_done)
				begin
				    sm_state    <=    COL_CHK;
				end
				else if(check_d & ~check_d_done)
				begin
				    sm_state    <=    D1_CHK;
				end
				else if(check_c & ~check_c_done)
				begin
				    sm_state    <=    C1_CHK;
				end
				else if(find_empty & ~find_empty_done)
				begin
				   sm_state          <= FND_E1;
				   row_my_total_cnt  <= 0;
		           col_my_total_cnt  <= 0;
		           d1_my_total_cnt   <= 0;
		           d2_my_total_cnt   <= 0;
				   row_my_wgt_cnt    <= 0;
		           col_my_wgt_cnt    <= 0;
		           d1_my_wgt_cnt     <= 0;
		           d2_my_wgt_cnt     <= 0;
				   row_enemy_wgt_cnt <= 0;
		           col_enemy_wgt_cnt <= 0;
		           d1_enemy_wgt_cnt  <= 0;
		           d2_enemy_wgt_cnt  <= 0;
				   row_enemy_total_cnt <= 0;
		           col_enemy_total_cnt <= 0;
		           d1_enemy_total_cnt<= 0;
		           d2_enemy_total_cnt<= 0;
				   row_my_cnt        <= 0;
				   col_my_cnt        <= 0;
				   d1_my_cnt         <= 0;
				   d2_my_cnt         <= 0;
				   row_enemy_cnt     <= 0;
				   col_enemy_cnt     <= 0;
				   d1_enemy_cnt      <= 0;
				   d2_enemy_cnt      <= 0;
				end             
				else if(chk_pm_done & ~o_chk_pm_done)
				begin
				   sm_state     <=    SND_PM;
				end
			end
			ROW_CHK:begin
			    if(cnt == 6)
				begin
				    check_row_done     <=    1'b1;
				    if((enemy_cnt >= 4 && my_cnt ==0) & i_chk_thrt)
					begin
					    o_thrt_detected    <=    i_chk_thrt;
						sm_state           <=    WAIT_ACK;
						o_td_row_addr1     <=    empty_cell_row_1;
						o_td_col_addr1     <=    empty_cell_col_1;
					end
					else if((my_cnt >= 4 && enemy_cnt == 0) & i_chk_succ)
					begin
					    o_succ_possible    <=    i_chk_succ;
						sm_state           <=    WAIT_ACK;
						o_td_row_addr1     <=    empty_cell_row_1;
						o_td_col_addr1     <=    empty_cell_col_1;
						o_td_row_addr2     <=    empty_cell_row_2;
						o_td_col_addr2     <=    empty_cell_col_2;
						if(free_cnt == 1)
						begin
						    o_single_place    <=    1'b1;
						end
						else
						begin
						    o_single_place    <=    1'b0;    
						end
					end
					else
				        sm_state    <=    IDLE;
				end
				else
				begin
				    if(i_sb_rd_data == `enemy_cell)
					    enemy_cnt   <=    enemy_cnt + 1;
					else if(i_sb_rd_data == `my_cell)
                        my_cnt      <=    my_cnt + 1;
                    else
					begin
					    if(free_cnt == 0)
						begin
                            empty_cell_row_1	<=	o_sb_rd_row;			
                            empty_cell_col_1	<=	o_sb_rd_col;
							empty_cell_row_2	<=	o_sb_rd_row;			
                            empty_cell_col_2	<=	o_sb_rd_col;
                            free_cnt            <=  free_cnt + 1;						
						end	
						else
						begin
						    empty_cell_row_1	<=	o_sb_rd_row;			
                            empty_cell_col_1	<=	o_sb_rd_col;
							free_cnt            <=  free_cnt + 1;
						end
					end	
					cnt    <=    cnt + 1;	
					o_sb_rd_col <= o_sb_rd_col + 1;
                end						
			end
			COL_CHK:begin
			    if(cnt == 6)
				begin
				    check_col_done     <=    1'b1;
				    if((enemy_cnt >= 4 && my_cnt ==0) & i_chk_thrt)
					begin
					    o_thrt_detected    <=    i_chk_thrt;
						sm_state           <=    WAIT_ACK;
						o_td_row_addr1     <=    empty_cell_row_1;
						o_td_col_addr1     <=    empty_cell_col_1;
					end
					else if((my_cnt >= 4 && enemy_cnt == 0) & i_chk_succ)
					begin
					    o_succ_possible    <=    i_chk_succ;
						sm_state           <=    WAIT_ACK;
						o_td_row_addr1     <=    empty_cell_row_1;
						o_td_col_addr1     <=    empty_cell_col_1;
						o_td_row_addr2     <=    empty_cell_row_2;
						o_td_col_addr2     <=    empty_cell_col_2;
						if(free_cnt == 1)
						begin
						    o_single_place    <=    1'b1;
						end
						else
						begin
						    o_single_place    <=    1'b0;    
						end
					end
					else
				        sm_state    <=    IDLE;
				end
				else
				begin
				    if(i_sb_rd_data == `enemy_cell)
					    enemy_cnt   <=    enemy_cnt + 1;
					else if(i_sb_rd_data == `my_cell)
                        my_cnt      <=    my_cnt + 1;
                    else
					begin
					    if(free_cnt == 0)
						begin
                            empty_cell_row_1	<=	o_sb_rd_row;			
                            empty_cell_col_1	<=	o_sb_rd_col;
							empty_cell_row_2	<=	o_sb_rd_row;			
                            empty_cell_col_2	<=	o_sb_rd_col;
                            free_cnt            <=  free_cnt + 1;						
						end	
						else
						begin
						    empty_cell_row_1	<=	o_sb_rd_row;			
                            empty_cell_col_1	<=	o_sb_rd_col;
							free_cnt            <=  free_cnt + 1;
						end		
					end	
					cnt         <= cnt + 1;	
					o_sb_rd_row <= o_sb_rd_row + 1;
                end						
			end
			D1_CHK:begin
			    if(cnt == 6)
				begin
				    check_d_done     <=    1'b1;
				    if((enemy_cnt >= 4 && my_cnt ==0) & i_chk_thrt)
					begin
					    o_thrt_detected    <=    i_chk_thrt;
						sm_state           <=    WAIT_ACK;
						o_td_row_addr1     <=    empty_cell_row_1;
						o_td_col_addr1     <=    empty_cell_col_1;
					end
					else if((my_cnt >= 4 && enemy_cnt == 0) & i_chk_succ)
					begin
					    o_succ_possible    <=    i_chk_succ;
						sm_state           <=    WAIT_ACK;
						o_td_row_addr1     <=    empty_cell_row_1;
						o_td_col_addr1     <=    empty_cell_col_1;
						o_td_row_addr2     <=    empty_cell_row_2;
						o_td_col_addr2     <=    empty_cell_col_2;
						if(free_cnt == 1)
						begin
						    o_single_place    <=    1'b1;
						end
						else
						begin
						    o_single_place    <=    1'b0;    
						end
					end
					else
				        sm_state    <=    IDLE;
				end
				else
				begin
				    if(i_sb_rd_data == `enemy_cell)
					    enemy_cnt   <=    enemy_cnt + 1;
					else if(i_sb_rd_data == `my_cell)
                        my_cnt      <=    my_cnt + 1;
                    else
					begin
					    if(free_cnt == 0)
						begin
                            empty_cell_row_1	<=	o_sb_rd_row;			
                            empty_cell_col_1	<=	o_sb_rd_col;
							empty_cell_row_2	<=	o_sb_rd_row;			
                            empty_cell_col_2	<=	o_sb_rd_col;
                            free_cnt            <=  free_cnt + 1;						
						end	
						else
						begin
						    empty_cell_row_1	<=	o_sb_rd_row;			
                            empty_cell_col_1	<=	o_sb_rd_col;
							free_cnt            <=  free_cnt + 1;
						end	
					end	
					cnt         <= cnt + 1;	
					o_sb_rd_row <= o_sb_rd_row + 1;
					o_sb_rd_col <= o_sb_rd_col + 1;
                end						
			end
			C1_CHK:begin
			    if(cnt == 6)
				begin
				    check_c_done     <=    1'b1;
				    if((enemy_cnt >= 4 && my_cnt ==0) & i_chk_thrt)
					begin
					    o_thrt_detected    <=    i_chk_thrt;
						sm_state           <=    WAIT_ACK;
						o_td_row_addr1     <=    empty_cell_row_1;
						o_td_col_addr1     <=    empty_cell_col_1;
					end
					else if((my_cnt >= 4 && enemy_cnt == 0) & i_chk_succ)
					begin
					    o_succ_possible    <=    i_chk_succ;
						sm_state           <=    WAIT_ACK;
						o_td_row_addr1     <=    empty_cell_row_1;
						o_td_col_addr1     <=    empty_cell_col_1;
						o_td_row_addr2     <=    empty_cell_row_2;
						o_td_col_addr2     <=    empty_cell_col_2;
						if(free_cnt == 1)
						begin
						    o_single_place    <=    1'b1;
						end
						else
						begin
						    o_single_place    <=    1'b0;    
						end
					end
					else
				        sm_state    <=    IDLE;
				end
				else
				begin
				    if(i_sb_rd_data == `enemy_cell)
					    enemy_cnt   <=    enemy_cnt + 1;
					else if(i_sb_rd_data == `my_cell)
                        my_cnt      <=    my_cnt + 1;
                    else
					begin
					    if(free_cnt == 0)
						begin
                            empty_cell_row_1	<=	o_sb_rd_row;			
                            empty_cell_col_1	<=	o_sb_rd_col;
							empty_cell_row_2	<=	o_sb_rd_row;			
                            empty_cell_col_2	<=	o_sb_rd_col;
                            free_cnt            <=  free_cnt + 1;						
						end	
						else
						begin
						    empty_cell_row_1	<=	o_sb_rd_row;			
                            empty_cell_col_1	<=	o_sb_rd_col;
							free_cnt            <=  free_cnt + 1;
						end		
					end	
					cnt         <= cnt + 1;	
					o_sb_rd_row <= o_sb_rd_row - 1;
					o_sb_rd_col <= o_sb_rd_col + 1;
                end						
			end
			WAIT_ACK:begin
			    check_row_done     <=    1'b0;
				check_col_done     <=    1'b0;
				check_d_done       <=    1'b0;
				check_c_done       <=    1'b0;
			    if(i_thrt_ack)
				begin
				    o_thrt_detected    <=    1'b0;
					sm_state           <=    IDLE;
				end
			end
			FND_E1:begin
                if(i_sb_rd_data != `empty_cell)
				begin
				    cell_not_empty    <=    1'b1;
					sm_state          <=    IDLE;
					find_empty_done   <=    1'b1;
				end
				else if(curr_row == 1 || curr_col == 1 || curr_row == 19 || curr_col == 19)
				begin
				    sm_state          <=    IDLE;
					find_empty_done   <=    1;
				end
			    else
				begin
					cnt               <=    5;
					enemy_cell_flag   <=    1'b0;
					my_cell_flag      <=    1'b0;
					sm_state          <=    ROW_L;
				    o_sb_rd_col       <=    curr_col - 1;
				end
			end
			ROW_L:begin
			    if(i_sb_rd_data == `my_cell & ~enemy_cell_flag)
				begin
				    row_my_cnt       <=   row_my_cnt + 1;
					row_my_wgt_cnt   <=   row_my_wgt_cnt + cnt;
					row_my_total_cnt <=   row_my_total_cnt + 1;
				end	
				else if(i_sb_rd_data == `empty_cell)
				begin
				    if(~enemy_cell_flag)
				        row_my_total_cnt   <=  row_my_total_cnt + 1;
					if(~my_cell_flag)
                        row_enemy_total_cnt  <=   row_enemy_total_cnt + 1;					
				end	
				else if(i_sb_rd_data == `enemy_cell & ~my_cell_flag)
				begin
				    row_enemy_cnt      <=   row_enemy_cnt + 1;
					row_enemy_wgt_cnt  <=   row_enemy_wgt_cnt + cnt;	
					row_enemy_total_cnt  <=   row_enemy_total_cnt + 1;	
				end
				if(i_sb_rd_data == `my_cell)
				    my_cell_flag     <=   1'b1;
				if(i_sb_rd_data == `enemy_cell)
				    enemy_cell_flag    <=   1'b1;
				if(cnt == 1 || o_sb_rd_col == 1)
                begin
				    cnt         <=    5;
					sm_state    <=    ROW_R;
				    o_sb_rd_col <=    curr_col + 1;
					enemy_cell_flag <= 1'b0;
					my_cell_flag <=   1'b0;
                end
                else
                begin
				    cnt         <=    cnt -  1;
					sm_state    <=    ROW_L;
					o_sb_rd_col <=    o_sb_rd_col - 1;
                end				
			end
			ROW_R:begin
			    if(i_sb_rd_data == `my_cell & ~enemy_cell_flag)
				begin
				    row_my_cnt     <=    row_my_cnt + 1;
					row_my_wgt_cnt <=    row_my_wgt_cnt + cnt;
					row_my_total_cnt <=   row_my_total_cnt + 1;
				end	
				else if(i_sb_rd_data == `empty_cell)
				begin
				    if(~enemy_cell_flag)
				        row_my_total_cnt  <=  row_my_total_cnt + 1;
					if(~my_cell_flag)
                        row_enemy_total_cnt  <=   row_enemy_total_cnt + 1;					
				end		
				else if(i_sb_rd_data == `enemy_cell & ~my_cell_flag)
				begin
				    row_enemy_cnt   <=   row_enemy_cnt + 1;
					row_enemy_wgt_cnt  <=   row_enemy_wgt_cnt + cnt;
					row_enemy_total_cnt  <=   row_enemy_total_cnt + 1;
				end
				if(i_sb_rd_data == `my_cell)
				    my_cell_flag     <=   1'b1;
				if(i_sb_rd_data == `enemy_cell)
				    enemy_cell_flag    <=   1'b1;
				if(cnt == 1 || o_sb_rd_col == 19)
                begin
				    cnt         <=    5;
					sm_state    <=    COL_U;
					o_sb_rd_col <=    curr_col;
					o_sb_rd_row <=    curr_row - 1;
					enemy_cell_flag <= 1'b0;
					my_cell_flag <=   1'b0;
                end
                else
                begin
				    cnt         <=    cnt -  1;
					sm_state    <=    ROW_R;
					o_sb_rd_col <=    o_sb_rd_col + 1;
                end				
			end
			COL_U:begin
				if(i_sb_rd_data == `my_cell & ~enemy_cell_flag)
				begin
				    col_my_cnt       <=   col_my_cnt + 1;
					col_my_wgt_cnt   <=   col_my_wgt_cnt + cnt;
					col_my_total_cnt <=   col_my_total_cnt + 1;
				end	
				else if(i_sb_rd_data == `empty_cell)
				begin
				    if(~enemy_cell_flag)
				        col_my_total_cnt  <=  col_my_total_cnt + 1;
					if(~my_cell_flag)
                        col_enemy_total_cnt  <=   col_enemy_total_cnt + 1;					
				end	
				else if(i_sb_rd_data == `enemy_cell & ~my_cell_flag)
				begin
				    col_enemy_cnt   <=   col_enemy_cnt + 1;
					col_enemy_wgt_cnt  <=   col_enemy_wgt_cnt + cnt;
					col_enemy_total_cnt  <=   col_enemy_total_cnt + 1;
				end
				if(i_sb_rd_data == `my_cell)
				    my_cell_flag     <=   1'b1;
				if(i_sb_rd_data == `enemy_cell)
				    enemy_cell_flag  <=   1'b1;
				if(cnt == 1 || o_sb_rd_row == 1)
                begin
				    cnt         <=    5;
					sm_state    <=    COL_D;
					o_sb_rd_col <=    curr_col;
					o_sb_rd_row <=    curr_row + 1;
					enemy_cell_flag <= 1'b0;
					my_cell_flag <=   1'b0;
				end	
                else
                begin
				    cnt         <=    cnt -  1;
					sm_state    <=    COL_U;
					o_sb_rd_row <=    o_sb_rd_row - 1;
                end				
			end
			COL_D:begin
				if(i_sb_rd_data == `my_cell & ~enemy_cell_flag)
				begin
				    col_my_cnt       <=   col_my_cnt + 1;
					col_my_wgt_cnt   <=   col_my_wgt_cnt + cnt;
					col_my_total_cnt <=   col_my_total_cnt + 1;
				end	
				else if(i_sb_rd_data == `empty_cell)
				begin
				    if(~enemy_cell_flag)
				        col_my_total_cnt   <=  col_my_total_cnt + 1;
					if(~my_cell_flag)
                        col_enemy_total_cnt  <=   col_enemy_total_cnt + 1;					
				end	
				else if(i_sb_rd_data == `enemy_cell & ~my_cell_flag)
				begin
				    col_enemy_cnt   <=   col_enemy_cnt + 1;
					col_enemy_wgt_cnt  <=   col_enemy_wgt_cnt + cnt;
					col_enemy_total_cnt  <=   col_enemy_total_cnt + 1;	
				end
				if(i_sb_rd_data == `my_cell)
				    my_cell_flag     <=   1'b1;
				if(i_sb_rd_data == `enemy_cell)
				    enemy_cell_flag    <=   1'b1;
				if(cnt == 1 || o_sb_rd_row == 19)
                begin
				    cnt         <=    5;
				    sm_state    <=    D_TR;
					o_sb_rd_col <=    curr_col + 1;
					o_sb_rd_row <=    curr_row - 1;
					enemy_cell_flag <= 1'b0;
					my_cell_flag <=   1'b0;
				end
                else
                begin
				    cnt         <=    cnt -  1;
					sm_state    <=    COL_D;
					o_sb_rd_row <=    o_sb_rd_row + 1;
                end				
			end	
            D_TR:begin
			    if(i_sb_rd_data == `my_cell & ~enemy_cell_flag)
				begin
				    d1_my_cnt       <=    d1_my_cnt + 1;
					d1_my_wgt_cnt   <=    d1_my_wgt_cnt + cnt;
					d1_my_total_cnt <=    d1_my_total_cnt + 1;
				end	
				else if(i_sb_rd_data == `empty_cell)
				begin
				    if(~enemy_cell_flag)
				        d1_my_total_cnt <=    d1_my_total_cnt + 1;
					if(~my_cell_flag)
                        d1_enemy_total_cnt  <=   d1_enemy_total_cnt + 1;					
				end	
				else if(i_sb_rd_data == `enemy_cell & ~my_cell_flag)
				begin
				    d1_enemy_cnt   <=   d1_enemy_cnt + 1;
					d1_enemy_wgt_cnt  <=   d1_enemy_wgt_cnt + cnt;
					d1_enemy_total_cnt  <=   d1_enemy_total_cnt + 1;
				end			
				if(i_sb_rd_data == `my_cell)
				    my_cell_flag     <=   1'b1;
				if(i_sb_rd_data == `enemy_cell)
				    enemy_cell_flag  <=   1'b1;				
                if(cnt == 1 || o_sb_rd_row == 1 || o_sb_rd_col == 19)
                begin
				    cnt        <=    5;
					sm_state   <=    D_BL;
					o_sb_rd_col <=   curr_col - 1;
					o_sb_rd_row <=   curr_row + 1;
					enemy_cell_flag <= 1'b0;
					my_cell_flag <=   1'b0;
                end				
				else
                begin
                    cnt         <=    cnt - 1;
                    sm_state    <=    D_TR;
                    o_sb_rd_col	<=    o_sb_rd_col + 1;
                    o_sb_rd_row <=    o_sb_rd_row - 1;
                end					
            end
            D_BL:begin
			    if(i_sb_rd_data == `my_cell & ~enemy_cell_flag)
				begin
				    d1_my_cnt       <=    d1_my_cnt + 1;
					d1_my_wgt_cnt   <=    d1_my_wgt_cnt + cnt;
					d1_my_total_cnt <=    d1_my_total_cnt + 1;
				end	
				else if(i_sb_rd_data == `empty_cell)
				begin
				    if(~enemy_cell_flag)
				        d1_my_total_cnt <=    d1_my_total_cnt + 1;
					if(~my_cell_flag)
                        d1_enemy_total_cnt  <=   d1_enemy_total_cnt + 1;					
				end	
				else if(i_sb_rd_data == `enemy_cell & ~my_cell_flag)
				begin
				    d1_enemy_cnt   <=   d1_enemy_cnt + 1;
					d1_enemy_wgt_cnt  <=   d1_enemy_wgt_cnt + cnt;
					d1_enemy_total_cnt  <=   d1_enemy_total_cnt + 1;
				end
				if(i_sb_rd_data == `my_cell)
				    my_cell_flag     <=   1'b1;
				if(i_sb_rd_data == `enemy_cell)
				    enemy_cell_flag    <=   1'b1;
                if(cnt == 1 || o_sb_rd_row == 19 || o_sb_rd_col == 1)
                begin
				    cnt        <=    5;
					sm_state   <=    D_TL;
					o_sb_rd_col <=   curr_col - 1;
					o_sb_rd_row <=   curr_row - 1;
					enemy_cell_flag <= 1'b0;
					my_cell_flag <=   1'b0;
                end				
				else
                begin
                    cnt         <=    cnt - 1;
                    sm_state    <=    D_BL;
                    o_sb_rd_col	<=    o_sb_rd_col - 1;
                    o_sb_rd_row <=    o_sb_rd_row + 1;
                end					
            end			
			D_TL:begin
			    if(i_sb_rd_data == `my_cell & ~enemy_cell_flag)
				begin
				    d2_my_cnt       <=  d2_my_cnt + 1;
					d2_my_wgt_cnt   <=  d2_my_wgt_cnt + cnt;
					d2_my_total_cnt <= d2_my_total_cnt + 1;
				end	
				else if(i_sb_rd_data == `empty_cell)
				begin
				    if(~enemy_cell_flag)
				        d2_my_total_cnt <= d2_my_total_cnt + 1;
					if(~my_cell_flag)
                        d2_enemy_total_cnt  <=   d2_enemy_total_cnt + 1;					
				end	
				else if(i_sb_rd_data == `enemy_cell & ~my_cell_flag)
				begin
				    d2_enemy_cnt   <=   d2_enemy_cnt + 1;
					d2_enemy_wgt_cnt  <=   d2_enemy_wgt_cnt + cnt;
					d2_enemy_total_cnt  <=   d2_enemy_total_cnt + 1;
				end
				if(i_sb_rd_data == `my_cell)
				    my_cell_flag     <=   1'b1;
				if(i_sb_rd_data == `enemy_cell)
				    enemy_cell_flag    <=   1'b1;
                if(cnt == 1 || o_sb_rd_row == 1 || o_sb_rd_col == 1)
                begin
				    cnt        <=    5;
					sm_state   <=    D_BR;
					o_sb_rd_col <=   curr_col + 1;
					o_sb_rd_row <=   curr_row + 1;
					enemy_cell_flag <= 1'b0;
					my_cell_flag <=   1'b0;
                end				
				else
                begin
                    cnt         <=    cnt - 1;
                    sm_state    <=    D_TL;
                    o_sb_rd_col	<=    o_sb_rd_col - 1;
                    o_sb_rd_row <=    o_sb_rd_row - 1;
                end					
            end
			D_BR:begin
			    if(i_sb_rd_data == `my_cell & ~enemy_cell_flag)
				begin
				    d2_my_cnt       <=  d2_my_cnt + 1;
					d2_my_wgt_cnt   <=  d2_my_wgt_cnt + cnt;
					d2_my_total_cnt <=  d2_my_total_cnt + 1;
				end	
				else if(i_sb_rd_data == `empty_cell)
				begin
				    if(~enemy_cell_flag)
				        d2_my_total_cnt <=  d2_my_total_cnt + 1;
					if(~my_cell_flag)
                        d2_enemy_total_cnt  <=   d2_enemy_total_cnt + 1;					
				end	
				else if(i_sb_rd_data == `enemy_cell & ~my_cell_flag)
				begin
				    d2_enemy_cnt   <=   d2_enemy_cnt + 1;
					d2_enemy_wgt_cnt  <=   d2_enemy_wgt_cnt + cnt;
					d2_enemy_total_cnt  <=   d2_enemy_total_cnt + 1;
				end
				if(i_sb_rd_data == `my_cell)
				    my_cell_flag     <=   1'b1;
				if(i_sb_rd_data == `enemy_cell)
				    enemy_cell_flag    <=   1'b1;
                if(cnt == 1 || o_sb_rd_row == 19 || o_sb_rd_col == 19)
                begin
				    cnt        <=    5;
					sm_state   <=    IDLE;
					find_empty_done <= 1'b1;
					enemy_cell_flag <= 1'b0;
					my_cell_flag <=   1'b0;
                end				
				else
                begin
                    cnt         <=    cnt - 1;
                    sm_state    <=    D_BR;
                    o_sb_rd_col	<=    o_sb_rd_col + 1;
                    o_sb_rd_row <=    o_sb_rd_row + 1;
                end							
            end
            SND_PM:begin
			    o_chk_pm_done   <=    1'b1;
				o_td_row_addr1  <=    best_cell_row;
				o_td_col_addr1  <=    best_cell_col;
				sm_state        <=    IDLE;
            end			
		endcase
	end
end


board_values bv(
  .i_row(curr_row),
  .i_column(curr_col),
  .o_board_weight(board_weight)
);

endmodule
