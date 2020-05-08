/*
 * vdmaTest.c
 *
 *  Created on: Apr 9, 2020
 *      Author: VIPIN
 */
#include "xparameters.h"
#include "video.h"
#include "sleep.h"
#include <stdio.h>
#include "zyMouse.h"
#include "xscugic.h"
#include "xil_cache.h"
#include "xuartps.h"
#include "connect6.h"
#include "graphics.h"


#define HSize 1920
#define VSize 1080
#define FrameSize HSize*VSize*3

char Buffer[FrameSize];

#define clockFreq 100000000
#define updateRate 0.005
#define CounterValue clockFreq*updateRate

connect6 myConnect6;
pointer myPointer;


u8 mouseClicks=0;
u8 firstMove=1;
int fpgaWon=0;
u8 fpgaStartGame;



int initIntrController(XScuGic *IntcInstancePtr);
void PressCallBack(void *callBackRef);
void MoveCallBack(void *callBackRef);


int main(){
	XScuGic Intc;
	zyMouse myMouse;
	u16 xPos=HSize-gridSize;
	u16 yPos=VSize-gridSize;
	u32 pos = xPos|(yPos<<16);
	initIntrController(&Intc);
	//Initializations
	initVideo(Buffer,VSize,HSize,&Intc);
	initConnect6(&myConnect6,XPAR_PS7_UART_0_DEVICE_ID);
	initZyMouse(&myMouse,XPAR_ZYMOUSE_0_S00_AXI_BASEADDR);
	setupZymouseInterrupt(&myMouse,&Intc,XPAR_FABRIC_ZYMOUSE_0_O_INTR_INTR);
	setInterruptZyMouse(&myMouse,AllInterruptMask);
	setZymouseCallBack(&myMouse,moveHandler,MoveCallBack);
	setZymouseCallBack(&myMouse,pressHandler,PressCallBack);
	setCoordinateZyMouse(&myMouse,pos);
	setTimerZymouse(&myMouse,CounterValue);
	startZymouse(&myMouse);
	showWelcome();
	fpgaStartGame=0;
	while(1){
		Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR,0x1); //reset the IP
		Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR,0x0);
		//initBoard(&myBoard);
		clearBoard(&myConnect6);
		drawPlayTable(Buffer,FrameSize,HSize,VSize,gridSize);
		MoveCallBack(&myMouse);//To show the pointer as soon as we start
		firstMove=1;
		while(1){
			if(fpgaStartGame){
				if(fpgaPlay()){
					printString(HSize,(char *)"FPGA Won!",HSize-9*8*5-10,VSize/3,5,redColor,Buffer);
					break;
				}
				if(userPlay()){
				printString(HSize,(char *)"You Won!",HSize-8*8*5-10,VSize/3,5,redColor,Buffer);
				break;
				}
			}
			else{
				if(userPlay()){
					printString(HSize,(char *)"You Won!",HSize-8*8*5-10,VSize/3,5,redColor,Buffer);
					break;
				}
				if(fpgaPlay()){
					printString(HSize,(char *)"FPGA Won!",HSize-9*8*5-10,VSize/3,5,redColor,Buffer);
					break;
				}
			}
		}
		sleep(5);
		fpgaStartGame = 1-fpgaStartGame;
		myPointer.init = 0;
	}

	return 0;
}


int initIntrController(XScuGic *IntcInstancePtr){
	int Status;
	XScuGic_Config *IntcConfig;
	IntcConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	Status =  XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig, IntcConfig->CpuBaseAddress);
	if(Status != XST_SUCCESS){
		xil_printf("Interrupt controller initialization failed..");
		return -1;
	}

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler)XScuGic_InterruptHandler,(void *)IntcInstancePtr);
	Xil_ExceptionEnable();
	return XST_SUCCESS;
}


void PressCallBack(void *callBackRef){
	u32 status;
	u16 xPos;
	u16 yPos;
	u32 pos;
	u8 xCord,yCord;
	zyMouse* zyMouseInst;
	zyMouseInst = (zyMouse*)callBackRef;
	pos = Xil_In32(zyMouseInst->baseAddress+posRegOffset);
	xPos = pos&0xffff;
	yPos = (pos&0xffff0000)>>16;
	yCord = (yPos/gridSize)-(VSize/gridSize-18)/2+1;
	xCord = (xPos/gridSize)-(HSize/gridSize-18)/2+1;
	if(xCord>=19||yCord>=19)
		return;
	//xil_printf("valid check x:%d y:%d",xCord,yCord);
	if((checkValidPlacement(&myConnect6,yCord,xCord)==0) && (myPointer.disableMouseClick==0)){
		writeGridData(HSize,(char *)myPointer.gridData,myPointer.xPos,myPointer.yPos,pointerSize,(char*) Buffer );
		if(fpgaStartGame)
			placeStone(((xPos/gridSize)*gridSize+gridSize/2),((yPos/gridSize)*gridSize+gridSize/2),gridSize,HSize,whiteColor,Buffer);
		else
			placeStone(((xPos/gridSize)*gridSize+gridSize/2),((yPos/gridSize)*gridSize+gridSize/2),gridSize,HSize,blackColor,Buffer);
		readGridData(HSize,(char *)myPointer.gridData,xPos,yPos,pointerSize,(char *)Buffer);
		drawPointer(xPos,yPos,pointerSize,HSize,Buffer); //draw the pointer
		//xil_printf("YPos %d Y cord %d\n\r",yPos,yCord);
		sendCoordinate(&myConnect6,yCord);
		//xil_printf("XPos %d X cord %d\n\r",xPos,xCord);
		sendCoordinate(&myConnect6,xCord);
		updateBoard(&myConnect6,yCord,xCord,playerCell);
		status = checkGameOver(&myConnect6,yCord,xCord);
		if(status)
			fpgaWon = 1;
		mouseClicks++;
		return;
	}
}


void MoveCallBack(void *callBackRef){
	u16 xPos;
	u16 yPos;
	u32 pos;
	zyMouse* zyMouseInst;
	zyMouseInst = (zyMouse*)callBackRef;

	pos = Xil_In32(zyMouseInst->baseAddress+posRegOffset);
	xPos = pos&0xffff;
	yPos = (pos&0xffff0000)>>16;

	if(myPointer.init == 1){
		writeGridData(HSize,(char *)myPointer.gridData,myPointer.xPos,myPointer.yPos,pointerSize,(char*) Buffer );
	}
	else{
		myPointer.init = 1;
	}
	myPointer.xPos=xPos;
	myPointer.yPos=yPos;
	readGridData(HSize,(char *)myPointer.gridData,xPos,yPos,pointerSize,(char *)Buffer);
	drawPointer(xPos,yPos,pointerSize,HSize,Buffer); //draw the pointer
}


int fpgaPlay(){
	//xil_printf("FPGA playing...\n\r");
	u8 FpgaYCord;
	u8 FpgaXCord;
	u8 xCord;
	u8 yCord;
	int stat;
	char *myString = "FPGA Turn";
	char stringSize = 9;
	char zoom=5;
	printString(HSize,(char *)myString,HSize-stringSize*8*zoom-10,VSize/3,zoom,greenColor,Buffer);


	myPointer.disableMouseClick = 1;

	if(firstMove && fpgaStartGame)
		startGame(&myConnect6,fpgaBlack);

	FpgaYCord = getCoordinate(&myConnect6);
	//xil_printf("YCord %d",FpgaYCord);
	yCord = (VSize/gridSize-18)/2+(FpgaYCord-1);
	FpgaXCord = getCoordinate(&myConnect6);
	//xil_printf("    XCord %d\n\r",FpgaXCord);
	xCord = (HSize/gridSize-18)/2+(FpgaXCord-1);
	if(fpgaStartGame)
		placeStone((xCord*gridSize+gridSize/2),(yCord*gridSize+gridSize/2),gridSize,HSize,blackColor,Buffer);
	else
		placeStone((xCord*gridSize+gridSize/2),(yCord*gridSize+gridSize/2),gridSize,HSize,whiteColor,Buffer);
	updateBoard(&myConnect6,FpgaYCord,FpgaXCord,fpgaCell);
	stat = checkGameOver(&myConnect6,FpgaYCord,FpgaXCord);
	if(stat)
		return 1;
	if(firstMove && fpgaStartGame){
		firstMove = 0;
		return 0;
	}
	FpgaYCord = getCoordinate(&myConnect6);
	//xil_printf("YCord %d",FpgaYCord);
	yCord = (VSize/gridSize-18)/2+(FpgaYCord-1);
	FpgaXCord = getCoordinate(&myConnect6);
	//xil_printf("    XCord %d\n\r",FpgaXCord);
	xCord = (HSize/gridSize-18)/2+(FpgaXCord-1);
	if(fpgaStartGame)
		placeStone((xCord*gridSize+gridSize/2),(yCord*gridSize+gridSize/2),gridSize,HSize,blackColor,Buffer);
	else
		placeStone((xCord*gridSize+gridSize/2),(yCord*gridSize+gridSize/2),gridSize,HSize,whiteColor,Buffer);
	updateBoard(&myConnect6,FpgaYCord,FpgaXCord,fpgaCell);
	stat = checkGameOver(&myConnect6,FpgaYCord,FpgaXCord);
	if(stat)
		return 1;
	return 0;
}

int userPlay(){
	//xil_printf("User playing...\n\r");
	char *myString = "Your Turn";
	char stringSize = 9;
	char zoom=5;
	printString(HSize,(char *)myString,HSize-stringSize*8*zoom-10,VSize/3,zoom,greenColor,Buffer);
	myPointer.disableMouseClick = 0;
	if(firstMove && !fpgaStartGame)
		startGame(&myConnect6,fpgaWhite);
	while(mouseClicks != 1);
	if(firstMove && !fpgaStartGame){
		firstMove = 0;
		mouseClicks = 0;
		return 0;
	}
	while(mouseClicks != 2);
	mouseClicks = 0;
	if(fpgaWon==1)
		return 1;
	else
		return 0;
}

void showWelcome(){
	char count[10];
	memset(Buffer,blackColor,FrameSize);
	char *myString = "CONNECT6";
	char stringSize = 8;
	char zoom=20;
	printString(HSize,(char *)myString,(HSize-stringSize*8*zoom)/2,VSize/3,zoom,redColor,Buffer);
	for(int i=5;i>0;i--){
		sprintf(count,"%d",i);
		printString(HSize,(char *)count,(HSize-8*zoom)/2,2*VSize/3,zoom,redColor,Buffer);
		sleep(1);
	}
	memset(Buffer,blackColor,FrameSize);
}
