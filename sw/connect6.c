/*
 * connect6.c
 *
 *  Created on: Apr 28, 2020
 *      Author: VIPIN
 */

#include "connect6.h"
#include <xil_printf.h>

void updateBoard(connect6 *connect6Inst,u8 row,u8 column,u8 data){
	connect6Inst->shBoard.boardData[row][column] = data;
}

void clearBoard(connect6 *connect6Inst){
	initBoard(&(connect6Inst->shBoard));
}

void initBoard(shadowBoard *playBoard){
	playBoard->numRows = boardYSize;
	playBoard->numColumns = boardXSize;
	for(int i=0;i<playBoard->numRows;i++)
		for(int j=0;j<playBoard->numColumns;j++)
			playBoard->boardData[i][j] = emptyCell;
}

void startGame(connect6 *connect6Inst,u8 initData){
	if(initData == fpgaBlack)
		uartBlockTransmitByte(&(connect6Inst->uart),0x44);
	else if(initData == fpgaWhite)
		uartBlockTransmitByte(&(connect6Inst->uart),0x48);
}

void printBoard(shadowBoard *playBoard){
	for(int i=0;i<playBoard->numRows;i++){
		for(int j=0;j<playBoard->numColumns;j++){
			xil_printf("%d |",playBoard->boardData[i][j]);
		}
		print("\n\r");
	}
}

int checkGameOver(connect6 *connect6Inst,u8 row,u8 column){

	u8 won;
	//column wise
	for(int i=0;i<6;i++){
		won = 1;
		for(int j=0;j<5;j++){
			//xil_printf("%d %d %d %d %d\n\r",row,column,j,playBoard->boardData[row][column-i+j],playBoard->boardData[row][column-i+j+1]);
				if(connect6Inst->shBoard.boardData[row][column-i+j] != connect6Inst->shBoard.boardData[row][column-i+j+1])
					won = 0;
		}
		if(won==1)
			return 1;
	}
   //row wise
	for(int i=0;i<6;i++){
		won = 1;
		for(int j=0;j<5;j++){
			//xil_printf("%d %d %d %d %d\n\r",row,column,j,playBoard->boardData[row-i+j][column],playBoard->boardData[row-i+j+1][column]);
			if(connect6Inst->shBoard.boardData[row-i+j][column] != connect6Inst->shBoard.boardData[row-i+j+1][column])
				won = 0;
		}
		if(won==1)
			return 1;
	}
	//right diagonal
	for(int i=0;i<6;i++){
		won = 1;
		for(int j=0;j<5;j++){
			//xil_printf("%d %d %d %d %d\n\r",row,column,j,playBoard->boardData[row-i+j][column+i-j],playBoard->boardData[row-i+j+1][column+i-j-1]);
			if(connect6Inst->shBoard.boardData[row-i+j][column+i-j] != connect6Inst->shBoard.boardData[row-i+j+1][column+i-j-1])
				won = 0;
		}
		if(won==1)
			return 1;
	}

	//left diagonal
	for(int i=0;i<6;i++){
		won = 1;
		for(int j=0;j<5;j++){
			//xil_printf("%d %d %d %d %d\n\r",row,column,j,playBoard->boardData[row-i+j][column+i-j],playBoard->boardData[row-i+j+1][column+i-j-1]);
			if(connect6Inst->shBoard.boardData[row+i-j][column+i-j] != connect6Inst->shBoard.boardData[row+i-j-1][column+i-j-1])
				won = 0;
		}
		if(won==1)
			return 1;
	}

	return 0;
}

int checkValidPlacement(connect6 *connect6Inst,u8 row,u8 column){
	//xil_printf("In valid check %d %d %d",row,column,playBoard->boardData[row][column]);
	if(connect6Inst->shBoard.boardData[row][column] == 0)
		return 0;
	else
		return -1;
}

int initConnect6(connect6 *connect6Inst,u32 uartID){
	u32 status;
	XUartPs_Config *myUartConfig;
	myUartConfig = XUartPs_LookupConfig(uartID);
	status = XUartPs_CfgInitialize(&(connect6Inst->uart), myUartConfig, myUartConfig->BaseAddress);
	if(status != XST_SUCCESS)
		print("Uart initialization failed...\n\r");
	status = XUartPs_SetBaudRate(&(connect6Inst->uart), 115200);
	if(status != XST_SUCCESS)
		print("Baudrate init failed....\n\r");

	initBoard(&(connect6Inst->shBoard));

	return status;
}

void uartBlockTransmitByte(XUartPs *myUart,u8 sendData){
	u32 transmittedBytes = 0;
	while(!transmittedBytes){
		transmittedBytes =  XUartPs_Send(myUart,&sendData,1);
	}
}

void sendCoordinate(connect6 *connect6Inst,u8 coordinate){
	uartBlockTransmitByte(&(connect6Inst->uart),coordinate/10+'0');
	uartBlockTransmitByte(&(connect6Inst->uart),coordinate%10+'0');
}

u8 uartBlockReceiveByte(XUartPs *myUart){
	u32 receivedBytes = 0;
	u8 receivedData;
	while(!receivedBytes){
		receivedBytes =  XUartPs_Recv(myUart,&receivedData,1);
	}
	return receivedData;
}


u8 getCoordinate(connect6 *connect6Inst){
	u8 byte1,byte2;
	byte1 = uartBlockReceiveByte(&(connect6Inst->uart));
	byte2 = uartBlockReceiveByte(&(connect6Inst->uart));
	return (byte1-'0')*10+(byte2-'0');
}





