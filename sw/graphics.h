#ifndef IMGPROCESS_H_   /* prevent circular inclusions */
#define IMGPROCESS_H_

#include "xil_types.h"
#include "xil_cache.h"
#include "xscugic.h"

//#define HSize 1920
//#define VSize 1080
//#define FrameSize HSize*VSize*3

#define blackColor 0x000000
#define whiteColor 0xffffff
#define redColor 0x0000ff
#define greenColor 0x00ff00
#define blueColor 0xff0000
#define brownColor 0x214365
#define orangeColor 0x00a5ff

//#define getSnakeHeadPosition Xil_In16(XPAR_SNAKETRACKER_0_S00_AXI_BASEADDR+4);

//Function for copying image from one buffer to another buffer
int drawImage(u32 displayHSize,u32 displayVSize,u32 imageHSize,u32 imageVSize,u32 hOffset, u32 vOffset,int numColors,char *imagePointer,char *videoFramePointer);
int drawFrame(u32 displayHSize,u32 displayVSize,u32 grdSize,u32 frameVOffset,u32 frameHOffset,u32 width,u32 color,char* videoFramePointer);
void printChar(u32 displayHSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 zoom,u32 color,char* videoFramePointer );
void printString(u32 displayHSize,char *printString,u32 hOffset, u32 vOffset,u32 zoom,u32 color,char* videoFramePointer);
int drawSquare(u16 xPos, u16 yPos,u32 grdSize,u32 displayHSize,char* videoFramePointer,u32 color);
//void showGameOver();
void drawPointer(u16 xPos,u16 yPos,u32 pntrSize,u32 displayHSize,char *videoFramePointer);
void placeStone(u16 xPos,u16 yPos,u32 grdSize,u32 displayHSize,u32 color,char *videoFramePointer);

void waitRestart();
void initGame();
void checkPause();

void readGridData(u32 displayHSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 pntrSize,char* videoFramePointer);
void writeGridData(u32 displayHSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 grdSize,char* videoFramePointer);

void drawPlayTable(char *Buffer,u32 FSize,u32 hSize,u32 vSize,u32 grdSize);
#endif /* end of protection macro */
