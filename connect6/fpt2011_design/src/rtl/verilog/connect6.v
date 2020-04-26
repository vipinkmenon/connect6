//--------------------------------------------------------------------------------------------
//    module      :    connect6
//    top module  :
//    author      :    vipin k
//    description :    top most module
//    revision    :
//    18-8-2011   :    Initial draft
//--------------------------------------------------------------------------------------------
module connect6(
input    wire    i_clk,
input    wire    i_rst,
input    wire    i_uart_rx_data,
output   wire    o_uart_tx_data,
output   wire    o_fpga_act
);

wire    [7:0]    w_uart_rx_data;
wire    [7:0]    w_uart_tx_data;
wire             w_uart_rx_data_valid;
wire             w_uart_tx_data_en;
wire             w_uart_rx_data_read;
wire             w_msm_sb_wr_en;
wire    [1:0]    w_msm_sb_wr_data;
wire    [4:0]    w_msm_sb_wr_row;
wire    [4:0]    w_msm_sb_wr_col;
wire             w_msm_td_chk_thrt;
wire             w_td_msm_thrt_detected;
wire    [4:0]    w_td_sb_rd_row;
wire    [4:0]    w_td_sb_rd_col;
wire    [1:0]    w_sb_td_data;
wire             w_msm_td_thrt_ack;
wire    [4:0]    w_td_msm_row_addr1;
wire    [4:0]    w_td_msm_col_addr1;
wire    [4:0]    w_td_msm_row_addr2;
wire    [4:0]    w_td_msm_col_addr2;
wire             w_msm_td_chk_pm;
wire             w_msm_td_chk_pm_done;
wire             w_td_msm_chk_thrt_done;
wire             w_td_msm_chk_pm_done;
wire             w_td_msm_single_place;
wire             w_msm_td_chk_succ;
wire             w_td_msm_chk_succ_done;
wire             w_td_msm_succ_possible;

master_sm msm(
 .i_clk(i_clk),
 .i_rst(i_rst),
 .i_uart_data_avail(w_uart_rx_data_valid),
 .i_uart_rd_data(w_uart_rx_data),
 .o_uart_wr_data(w_uart_tx_data),
 .o_uart_wr_en(w_uart_tx_data_en),
 .o_uart_rd_en(w_uart_rx_data_read),
 .o_sb_wr_en(w_msm_sb_wr_en),
 .o_sb_wr_data(w_msm_sb_wr_data),
 .o_sb_wr_row(w_msm_sb_wr_row),
 .o_sb_wr_col(w_msm_sb_wr_col),
 .o_chk_succ(w_msm_td_chk_succ),
 .i_chk_succ_done(w_td_msm_chk_succ_done),
 .i_succ_possible(w_td_msm_succ_possible),
 .i_td_row_addr1(w_td_msm_row_addr1),
 .i_td_col_addr1(w_td_msm_col_addr1),
 .i_td_row_addr2(w_td_msm_row_addr2),
 .i_td_col_addr2(w_td_msm_col_addr2),
 .o_chk_thrt(w_msm_td_chk_thrt),
 .o_chk_pm(w_msm_td_chk_pm),
 .i_chk_pm_done(w_td_msm_chk_pm_done),
 .i_chk_thrt_done(w_td_msm_chk_thrt_done),
 .i_thrt_detected(w_td_msm_thrt_detected),
 .o_fpga_act(o_fpga_act),
 .o_thrt_ack(w_msm_td_thrt_ack),
 .i_single_place(w_td_msm_single_place)
);


shadow_board sb(
  .i_clk(i_clk),
  .i_rst(i_rst),
  .i_ms_wr_data(w_msm_sb_wr_data),
  .i_ms_wr_en(w_msm_sb_wr_en),
  .i_ms_wr_row(w_msm_sb_wr_row),
  .i_ms_wr_col(w_msm_sb_wr_col),
  .i_rd_row(w_td_sb_rd_row),
  .i_rd_col(w_td_sb_rd_col),
  .o_rd_data(w_sb_td_data)
);


threat_detector td(
  .i_clk(i_clk),
  .i_rst(i_rst),
  .i_chk_succ(w_msm_td_chk_succ),
  .o_chk_succ_done(w_td_msm_chk_succ_done),
  .o_succ_possible(w_td_msm_succ_possible),
  .o_td_row_addr1(w_td_msm_row_addr1),
  .o_td_col_addr1(w_td_msm_col_addr1),
  .o_td_row_addr2(w_td_msm_row_addr2),
  .o_td_col_addr2(w_td_msm_col_addr2),
  .i_chk_thrt(w_msm_td_chk_thrt),
  .i_chk_pm(w_msm_td_chk_pm),
  .o_chk_pm_done(w_td_msm_chk_pm_done),
  .o_chk_thrt_done(w_td_msm_chk_thrt_done),
  .o_thrt_detected(w_td_msm_thrt_detected),
  .i_thrt_ack(w_msm_td_thrt_ack),
  .o_sb_rd_row(w_td_sb_rd_row),
  .o_sb_rd_col(w_td_sb_rd_col),
  .i_sb_rd_data(w_sb_td_data),
  .o_single_place(w_td_msm_single_place)
);

`ifndef SIM  //In simulation, UART module is not used.
uart_top uart(
 .i_clk(i_clk),
 .i_rst(i_rst),
 .i_rx_data(i_uart_rx_data),
 .o_tx_data(o_uart_tx_data),
 .o_rx_data(w_uart_rx_data),
 .i_tx_data(w_uart_tx_data),
 .o_rx_data_valid(w_uart_rx_data_valid),
 .i_tx_data_valid(w_uart_tx_data_en),
 .i_rx_data_read(w_uart_rx_data_read)
);
`endif


endmodule
