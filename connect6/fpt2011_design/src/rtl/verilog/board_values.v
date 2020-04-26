//--------------------------------------------------------------------------------------------
//    module      :    board_values
//    top module  :    threat_detector
//    author      :    vipin k
//    description :    Contains the weights for each location on the board. Higher weight for
//                     locations close the the centre.
//    revision    :
//    21-9-2011   :    Initial draft
//--------------------------------------------------------------------------------------------

module board_values(
input   wire    [4:0]    i_row,
input   wire    [4:0]    i_column,
output  wire    [4:0]    o_board_weight
);

reg    [4:0]   board[18:0][18:0];

assign    o_board_weight   =    board[i_row-1][i_column-1];

initial
begin
    board[0][0]    =  0;
    board[0][1]    =  0;
    board[0][2]    =  1;
    board[0][3]    =  2;
    board[0][4]    =  3;
    board[0][5]    =  4;
    board[0][6]    =  5;
    board[0][7]    =  6;
    board[0][8]    =  7;
    board[0][9]    =  8;
    board[0][10]   =  7;
    board[0][11]   =  6;
    board[0][12]   =  5;
    board[0][13]   =  4;
    board[0][14]   =  3;
    board[0][15]   =  2;
    board[0][16]   =  1;
    board[0][17]   =  0;
    board[0][18]   =  0;
    board[1][0]    =  0;
    board[1][1]    =  1;
    board[1][2]    =  2;
    board[1][3]    =  3;
    board[1][4]    =  4;
    board[1][5]    =  5;
    board[1][6]    =  6;
    board[1][7]    =  7;
    board[1][8]    =  8;
    board[1][9]    =  9;
    board[1][10]   =  8;
    board[1][11]   =  7;
    board[1][12]   =  6;
    board[1][13]   =  5;
    board[1][14]   =  4;
    board[1][15]   =  3;
    board[1][16]   =  2;
    board[1][17]   =  1;
    board[1][18]   =  0; 
	board[2][0]    =  1;
    board[2][1]    =  2;
    board[2][2]    =  3;
    board[2][3]    =  4;
    board[2][4]    =  5;
    board[2][5]    =  6;
    board[2][6]    =  7;
    board[2][7]    =  8;
    board[2][8]    =  9;
    board[2][9]    =  10;
    board[2][10]   =  9;
    board[2][11]   =  8;
    board[2][12]   =  7;
    board[2][13]   =  6;
    board[2][14]   =  5;
    board[2][15]   =  4;
    board[2][16]   =  3;
    board[2][17]   =  2;
    board[2][18]   =  1;  
	board[3][0]    =  2;
    board[3][1]    =  3;
    board[3][2]    =  4;
    board[3][3]    =  5;
    board[3][4]    =  6;
    board[3][5]    =  7;
    board[3][6]    =  8;
    board[3][7]    =  9;
    board[3][8]    =  10;
    board[3][9]    =  11;
    board[3][10]   =  10;
    board[3][11]   =  9;
    board[3][12]   =  8;
    board[3][13]   =  7;
    board[3][14]   =  6;
    board[3][15]   =  5;
    board[3][16]   =  4;
    board[3][17]   =  3;
    board[3][18]   =  2;	                 
	board[4][0]    =  3;
    board[4][1]    =  4;
    board[4][2]    =  5;
    board[4][3]    =  6;
    board[4][4]    =  7;
    board[4][5]    =  8;
    board[4][6]    =  9;
    board[4][7]    =  10;
    board[4][8]    =  11;
    board[4][9]    =  12;
    board[4][10]   =  11;
    board[4][11]   =  10;
    board[4][12]   =  9;
    board[4][13]   =  8;
    board[4][14]   =  7;
    board[4][15]   =  6;
    board[4][16]   =  5;
    board[4][17]   =  4;
    board[4][18]   =  3;
    board[5][0]    =  4;
    board[5][1]    =  5;
    board[5][2]    =  6;
    board[5][3]    =  7;
    board[5][4]    =  8;
    board[5][5]    =  9;
    board[5][6]    =  10;
    board[5][7]    =  11;
    board[5][8]    =  12;
    board[5][9]    =  13;
    board[5][10]   =  12;
    board[5][11]   =  11;
    board[5][12]   =  10;
    board[5][13]   =  9;
    board[5][14]   =  8;
    board[5][15]   =  7;
    board[5][16]   =  6;
    board[5][17]   =  5;
    board[5][18]   =  4;
    board[6][0]    =  5;
    board[6][1]    =  6;
    board[6][2]    =  7;
    board[6][3]    =  8;
    board[6][4]    =  9;
    board[6][5]    =  10;
    board[6][6]    =  11;
    board[6][7]    =  12;
    board[6][8]    =  13;
    board[6][9]    =  14;
    board[6][10]   =  13;
    board[6][11]   =  12;
    board[6][12]   =  11;
    board[6][13]   =  10;
    board[6][14]   =  9;
    board[6][15]   =  8;
    board[6][16]   =  7;
    board[6][17]   =  6;
    board[6][18]   =  5;
    board[7][0]    =  6;
    board[7][1]    =  7;
    board[7][2]    =  8;
    board[7][3]    =  9;
    board[7][4]    =  10;
    board[7][5]    =  11;
    board[7][6]    =  12;
    board[7][7]    =  13;
    board[7][8]    =  14;
    board[7][9]    =  17;
    board[7][10]   =  14;
    board[7][11]   =  13;
    board[7][12]   =  12;
    board[7][13]   =  11;
    board[7][14]   =  10;
    board[7][15]   =  9;
    board[7][16]   =  8;
    board[7][17]   =  7;
    board[7][18]   =  6;
    board[8][0]    =  7;
    board[8][1]    =  8;
    board[8][2]    =  9;
    board[8][3]    =  10;
    board[8][4]    =  11;
    board[8][5]    =  12;
    board[8][6]    =  13;
    board[8][7]    =  14;
    board[8][8]    =  20;
    board[8][9]    =  16;
    board[8][10]   =  20;
    board[8][11]   =  14;
    board[8][12]   =  13;
    board[8][13]   =  12;
    board[8][14]   =  11;
    board[8][15]   =  10;
    board[8][16]   =  9;
    board[8][17]   =  8;
    board[8][18]   =  7;
    board[9][0]    =  8;
    board[9][1]    =  9;
    board[9][2]    =  10;
    board[9][3]    =  11;
    board[9][4]    =  12;
    board[9][5]    =  13;
    board[9][6]    =  14;
    board[9][7]    =  17;
    board[9][8]    =  16;
    board[9][9]    =  30;
    board[9][10]   =  16;
    board[9][11]   =  17;
    board[9][12]   =  14;
    board[9][13]   =  13;
    board[9][14]   =  12;
    board[9][15]   =  11;
    board[9][16]   =  10;
    board[9][17]   =  9;
    board[9][18]   =  8;	
    board[10][0]   =  7;
    board[10][1]   =  8;
    board[10][2]   =  9;
    board[10][3]   =  10;
    board[10][4]   =  11;
    board[10][5]   =  12;
    board[10][6]   =  13;
    board[10][7]   =  14;
    board[10][8]   =  20;
    board[10][9]   =  16;
    board[10][10]  =  20;
    board[10][11]  =  14;
    board[10][12]  =  13;
    board[10][13]  =  12;
    board[10][14]  =  11;
    board[10][15]  =  10;
    board[10][16]  =  9;
    board[10][17]  =  8;
    board[10][18]  =  7;
    board[11][0]   =  6;
    board[11][1]   =  7;
    board[11][2]   =  8;
    board[11][3]   =  9;
    board[11][4]   =  10;
    board[11][5]   =  11;
    board[11][6]   =  12;
    board[11][7]   =  13;
    board[11][8]   =  14;
    board[11][9]   =  17;
    board[11][10]  =  14;
    board[11][11]  =  13;
    board[11][12]  =  12;
    board[11][13]  =  11;
    board[11][14]  =  10;
    board[11][15]  =  9;
    board[11][16]  =  8;
    board[11][17]  =  7;
    board[11][18]  =  6;
    board[12][0]   =  5;
    board[12][1]   =  6;
    board[12][2]   =  7;
    board[12][3]   =  8;
    board[12][4]   =  9;
    board[12][5]   =  10;
    board[12][6]   =  11;
    board[12][7]   =  12;
    board[12][8]   =  13;
    board[12][9]   =  14;
    board[12][10]  =  13;
    board[12][11]  =  12;
    board[12][12]  =  11;
    board[12][13]  =  10;
    board[12][14]  =  9;
    board[12][15]  =  8;
    board[12][16]  =  7;
    board[12][17]  =  6;
    board[12][18]  =  5;
    board[13][0]   =  4;
    board[13][1]   =  5;
    board[13][2]   =  6;
    board[13][3]   =  7;
    board[13][4]   =  8;
    board[13][5]   =  9;
    board[13][6]   =  10;
    board[13][7]   =  11;
    board[13][8]   =  12;
    board[13][9]   =  13;
    board[13][10]  =  12;
    board[13][11]  =  11;
    board[13][12]  =  10;
    board[13][13]  =  9;
    board[13][14]  =  8;
    board[13][15]  =  7;
    board[13][16]  =  6;
    board[13][17]  =  5;
    board[13][18]  =  4;
    board[14][0]   =  3;
    board[14][1]   =  4;
    board[14][2]   =  5;
    board[14][3]   =  6;
    board[14][4]   =  7;
    board[14][5]   =  8;
    board[14][6]   =  9;
    board[14][7]   =  10;
    board[14][8]   =  11;
    board[14][9]   =  12;
    board[14][10]  =  11;
    board[14][11]  =  10;
    board[14][12]  =  9;
    board[14][13]  =  8;
    board[14][14]  =  7;
    board[14][15]  =  6;
    board[14][16]  =  5;
    board[14][17]  =  4;
    board[14][18]  =  3;
    board[15][0]   =  2;
    board[15][1]   =  3;
    board[15][2]   =  4;
    board[15][3]   =  5;
    board[15][4]   =  6;
    board[15][5]   =  7;
    board[15][6]   =  8;
    board[15][7]   =  9;
    board[15][8]   =  10;
    board[15][9]   =  11;
    board[15][10]  =  10;
    board[15][11]  =  9;
    board[15][12]  =  8;
    board[15][13]  =  7;
    board[15][14]  =  6;
    board[15][15]  =  5;
    board[15][16]  =  4;
    board[15][17]  =  3;
    board[15][18]  =  2;	
    board[16][0]   =   1;
    board[16][1]   =   2;
    board[16][2]   =   3;
    board[16][3]   =   4;
    board[16][4]   =   5;
    board[16][5]   =   6;
    board[16][6]   =   7;
    board[16][7]   =   8;
    board[16][8]   =   9;
    board[16][9]   =  10;
    board[16][10]  =  11;
    board[16][11]  =  12;
    board[16][12]  =  13;
    board[16][13]  =  14;
    board[16][14]  =  15;
    board[16][15]  =  16;
    board[16][16]  =  17;
    board[16][17]  =  18;
    board[16][18]  =  19; 
    board[17][0]   =  0;
    board[17][1]   =  1;
    board[17][2]   =  2;
    board[17][3]   =  3;
    board[17][4]   =  4;
    board[17][5]   =  5;
    board[17][6]   =  6;
    board[17][7]   =  7;
    board[17][8]   =  8;
    board[17][9]   =  9;
    board[17][10]  =  8;
    board[17][11]  =  7;
    board[17][12]  =  6;
    board[17][13]  =  5;
    board[17][14]  =  4;
    board[17][15]  =  3;
    board[17][16]  =  2;
    board[17][17]  =  1;
    board[17][18]  =  0;
    board[18][0]   =  0;
    board[18][1]   =  0;
    board[18][2]   =  1;
    board[18][3]   =  2;
    board[18][4]   =  3;
    board[18][5]   =  4;
    board[18][6]   =  5;
    board[18][7]   =  6;
    board[18][8]   =  7;
    board[18][9]   =  8;
    board[18][10]  =  7;
    board[18][11]  =  6;
    board[18][12]  =  5;
    board[18][13]  =  4;
    board[18][14]  =  3;
    board[18][15]  =  2;
    board[18][16]  =  1;
    board[18][17]  =  0;
    board[18][18]  =  0;
end	
	
endmodule	