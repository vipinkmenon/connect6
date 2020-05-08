/*
 * connect6.h
 *
 *  Created on: Apr 28, 2020
 *      Author: VIPIN
 */

#ifndef SRC_CONNECT6_H_
#define SRC_CONNECT6_H_

#include "xil_types.h"
#include "xuartps.h"

#define boardXSize 19
#define boardYSize 19

#define gridSize 50
#define pointerSize 16

#define emptyCell 0
#define playerCell 1
#define fpgaCell 2

#define fpgaBlack 0
#define fpgaWhite 1

//Mouse pointer structure
typedef struct{
	char gridData[3*pointerSize*pointerSize]; //Amount of data in a grid
	char init;
	u32  xPos;
	u32  yPos;
	u8 disableMouseClick;
}pointer;

//Shadow board structure
typedef struct{
	u8 numRows;
	u8 numColumns;
	char boardData[boardYSize+1][boardXSize+1];
}shadowBoard;

//Connect6 structure
typedef struct{
	shadowBoard shBoard;
	XUartPs uart;
}connect6;



void showWelcome();
void clearBoard(connect6 *connect6Inst);
void startGame(connect6 *connect6Inst,u8 initData);
int  fpgaPlay();
int userPlay();
void updateBoard(connect6 *connect6Inst,u8 row,u8 column,u8 data);
void initBoard(shadowBoard *playBoard);
void printBoard(shadowBoard *playBoard);
int checkGameOver(connect6 *connect6Inst,u8 row,u8 column);
int checkValidPlacement(connect6 *connect6Inst,u8 row,u8 column);
int initConnect6(connect6 *connect6Inst,u32 uartID);
void uartBlockTransmitByte(XUartPs *myUart,u8 sendData);
u8 uartBlockReceiveByte(XUartPs *myUart);
u8 getCoordinate(connect6 *connect6Inst);
void sendCoordinate(connect6 *connect6Inst,u8 coordinate);



#endif /* SRC_CONNECT6_H_ */
