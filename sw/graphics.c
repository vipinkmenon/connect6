/*
 * imageProcess.c
 *
 *  Created on: Apr 13, 2020
 *      Author: VIPIN
 */

#include "graphics.h"

#include "font.h"



/*****************************************************************************/
/**
 * This function copies the buffer data from image buffer to video buffer
 *
 * @param	displayHSize is Horizontal size of video in pixels
 * @param   displayVSize is Vertical size of video in pixels
 * @param	imageHSize is Horizontal size of image in pixels
 * @param   imageVSize is Vertical size of image in pixels
 * @param   hOffset is horizontal position in the video frame where image should be displayed
 * @param   vOffset is vertical position in the video frame where image should be displayed
 * @param   imagePointer pointer to the image buffer
 * @return
 * 		-  0 if successfully copied
 * 		- -1 if copying failed
 *****************************************************************************/
int drawImage(u32 displayHSize,u32 displayVSize,u32 imageHSize,u32 imageVSize,u32 hOffset, u32 vOffset,int numColors,char *imagePointer,char *videoFramePointer){
	Xil_DCacheInvalidateRange((u32)imagePointer,(imageHSize*imageVSize));
	for(int i=0;i<displayVSize;i++){
		for(int j=0;j<displayHSize;j++){
			if(i<vOffset || i >= vOffset+imageVSize){
				videoFramePointer[(i*displayHSize*3)+(j*3)]   = 0x00;
				videoFramePointer[(i*displayHSize*3)+(j*3)+1] = 0x00;
				videoFramePointer[(i*displayHSize*3)+(j*3)+2] = 0x00;
			}
			else if(j<hOffset || j >= hOffset+imageHSize){
				videoFramePointer[(i*displayHSize*3)+(j*3)]   = 0x00;
				videoFramePointer[(i*displayHSize*3)+(j*3)+1] = 0x00;
				videoFramePointer[(i*displayHSize*3)+(j*3)+2] = 0x00;
			}
			else {
				if(numColors==1){
					videoFramePointer[(i*displayHSize*3)+j*3]     = *imagePointer/16;
					videoFramePointer[(i*displayHSize*3)+(j*3)+1] = *imagePointer/16;
					videoFramePointer[(i*displayHSize*3)+(j*3)+2] = *imagePointer/16;
					imagePointer++;
				}
				else if(numColors==3){
					videoFramePointer[(i*displayHSize*3)+j*3]     = *imagePointer/16;
					videoFramePointer[(i*displayHSize*3)+(j*3)+1] = *(imagePointer++)/16;
					videoFramePointer[(i*displayHSize*3)+(j*3)+2] = *(imagePointer++)/16;
					imagePointer++;
				}
			}
		}
	}
	Xil_DCacheFlush();
	return 0;
}


int drawFrame(u32 displayHSize,u32 displayVSize,u32 grdSize,u32 frameVOffset,u32 frameHOffset,u32 framewidth,u32 color,char* videoFramePointer){
	//Top line
	u32 vOffset = frameVOffset*grdSize;
	u32 hOffset = frameHOffset*grdSize;
	u32 width = framewidth*grdSize;
	for(int i=vOffset;i<vOffset+width;i++){
		for(int j=hOffset;j<displayHSize-hOffset;j++){
			videoFramePointer[(i*displayHSize*3)+(j*3)]   = color&0xff;
			videoFramePointer[(i*displayHSize*3)+(j*3)+1] = (color&0x00ff00)>>8;
			videoFramePointer[(i*displayHSize*3)+(j*3)+2] = (color&0xff0000)>>16;
		}
	}
   //Bottom line
	for(int i=(displayVSize-vOffset-width);i<displayVSize-vOffset;i++){
		for(int j=hOffset;j<displayHSize-hOffset;j++){
			videoFramePointer[(i*displayHSize*3)+(j*3)]   = color&0xff;
			videoFramePointer[(i*displayHSize*3)+(j*3)+1] = (color&0x00ff00)>>8;
			videoFramePointer[(i*displayHSize*3)+(j*3)+2] = (color&0xff0000)>>16;
		}
	}
   //Left line
	for(int i=width+vOffset;i<displayVSize-width-vOffset;i++){
		for(int j=hOffset;j<hOffset+width;j++){
			videoFramePointer[(i*displayHSize*3)+(j*3)]   = color&0xff;
			videoFramePointer[(i*displayHSize*3)+(j*3)+1] = (color&0x00ff00)>>8;
			videoFramePointer[(i*displayHSize*3)+(j*3)+2] = (color&0xff0000)>>16;
		}
	}
	//Right line
	for(int i=width+vOffset;i<displayVSize-width-vOffset;i++){
		for(int j=displayHSize-width-hOffset;j<displayHSize-hOffset;j++){
			videoFramePointer[(i*displayHSize*3)+(j*3)]   = color&0xff;
			videoFramePointer[(i*displayHSize*3)+(j*3)+1] = (color&0x00ff00)>>8;
			videoFramePointer[(i*displayHSize*3)+(j*3)+2] = (color&0xff0000)>>16;
		}
	}
	Xil_DCacheFlush();
	return 0;
}

/*int printChar(u32 displayHSize,u32 displayVSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 zoom,char* videoFramePointer ){
	for(int i=0;i<8*zoom;i++){
		for(int j=0;j<8*zoom;j++){
			videoFramePointer[((i+vOffset)*displayHSize*3)+((j+hOffset)*3)]   = *(charBitMap+(i/zoom)*8+(j/zoom));
			videoFramePointer[((i+vOffset)*displayHSize*3)+((j+hOffset)*3)+1] = *(charBitMap+(i/zoom)*8+(j/zoom));
			videoFramePointer[((i+vOffset)*displayHSize*3)+((j+hOffset)*3)+2] = *(charBitMap+(i/zoom)*8+(j/zoom));
			//xil_printf("%0x,%0x,%d,%d\n\r",*(charBitMap+(i/zoom)*(zoom*8)+(j/zoom)),(charBitMap+(i/zoom)*(zoom*8)+(j/zoom)),i,j);
		}
	}
	Xil_DCacheFlush();
	return 0;
}*/


void printString(u32 displayHSize,char *printString,u32 hOffset, u32 vOffset,u32 zoom,u32 color,char* videoFramePointer){
	u32 charPos = hOffset;
	u32 charArrayPos;
	while(*printString != 0){
		charArrayPos = (*printString-32)*8;
		printChar(displayHSize,(char *)&fontBitMat[charArrayPos],charPos,vOffset,zoom,color,videoFramePointer);
		charPos += zoom*8;
		printString++;
	}
}


void printChar(u32 displayHSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 zoom,u32 color,char* videoFramePointer ){
	for(int i=0;i<8*zoom;i++){ //columnwise
		for(int j=0;j<8*zoom;j++){//rowwise
			videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)]   = ((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*(color&0xff);
			videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)+1] = ((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*(color&0x00ff00)>>8;
			videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)+2] = ((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*(color&0xff0000)>>16;
			//xil_printf("%d. i=%d j=%d %0d %0x %0x \n\r",i*8+j,i,j,((*(charBitMap+i))&0x01)>>j,*(charBitMap+i),(*(charBitMap+i)>>j)&0x1);
		}
	}
	Xil_DCacheFlush();
}

/*void readGridData(u32 displayHSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 zoom,char* videoFramePointer ){
	char data;
	for(int i=0;i<8*zoom;i++){ //columnwise
		data = 0;
		for(int j=0;j<8*zoom;j++){//rowwise
			data = data|((videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)])&0x1)<<(j/zoom);
		}
		charBitMap[i/zoom] = data;
	}
}*/

void readGridData(u32 displayHSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 pntrSize,char* videoFramePointer ){
	for(int i=0;i<pntrSize;i++){
		for(int j=0;j<pntrSize;j++){
			charBitMap[i*pntrSize*3+j*3]   = videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)];
			charBitMap[i*pntrSize*3+j*3+1] = videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)+1];
			charBitMap[i*pntrSize*3+j*3+2] = videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)+2];
		}
	}
}

void writeGridData(u32 displayHSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 grdSize,char* videoFramePointer ){
	for(int i=0;i<grdSize;i++){ //columnwise
		for(int j=0;j<grdSize;j++){//rowwise
			videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)]   = charBitMap[i*grdSize*3+j*3];
			videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)+1] = charBitMap[i*grdSize*3+j*3+1];
			videoFramePointer[((j+vOffset)*displayHSize*3)+((i+hOffset)*3)+2] = charBitMap[i*grdSize*3+j*3+2];
			//xil_printf("%d. i=%d j=%d %0d %0x %0x \n\r",i*8+j,i,j,((*(charBitMap+i))&0x01)>>j,*(charBitMap+i),(*(charBitMap+i)>>j)&0x1);
		}
	}
	Xil_DCacheFlush();
}


int drawSquare(u16 xPos, u16 yPos,u32 grdSize,u32 displayHSize,char* videoFramePointer,u32 color){
	for(int i=1;i<grdSize-1;i++){
		for(int j=1;j<grdSize-1;j++){
			videoFramePointer[((i+yPos*grdSize)*displayHSize*3)+((j+xPos*grdSize)*3)]   = color&0xff;
			videoFramePointer[((i+yPos*grdSize)*displayHSize*3)+((j+xPos*grdSize)*3)+1] = (color&0x00ff00)>>8;;
			videoFramePointer[((i+yPos*grdSize)*displayHSize*3)+((j+xPos*grdSize)*3)+2] = (color&0xff0000)>>16;;
			//xil_printf("%0x,%0x,%d,%d\n\r",*(charBitMap+(i/zoom)*(zoom*8)+(j/zoom)),(charBitMap+(i/zoom)*(zoom*8)+(j/zoom)),i,j);
		}
	}
	Xil_DCacheFlush();
	return 0;
}

void drawPointer(u16 xPos,u16 yPos,u32 pntrSize,u32 displayHSize,char *videoFramePointer){
	u32 zoom = pntrSize/8;
	char *charBitMap = (char *)&fontBitMat[0];
	for(int i=0;i<8*zoom;i++){ //columnwise
		for(int j=0;j<8*zoom;j++){//rowwise
			videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)]   = (((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*0xff)|videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)];
			videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+1] = (((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*0xff)|videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+1];
			videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+2] = (((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*0xff)|videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+2];
			//xil_printf("%d. i=%d j=%d %0d %0x %0x \n\r",i*8+j,i,j,((*(charBitMap+i))&0x01)>>j,*(charBitMap+i),(*(charBitMap+i)>>j)&0x1);
		}
	}
	Xil_DCacheFlush();
}

void placeStone(u16 xPos,u16 yPos,u32 grdSize,u32 displayHSize,u32 color,char *videoFramePointer){
	u32 zoom = grdSize/8;
	char *charBitMap = (char *)&fontBitMat[('O'-32)*8];
	if(color == whiteColor){
		for(int i=0;i<8*zoom;i++){ //columnwise
			for(int j=0;j<8*zoom;j++){//rowwise
				videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)]   = (((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*0xff)|videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)];
				videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+1] = (((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*0xff)|videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+1];
				videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+2] = (((*(charBitMap+(i/zoom))>>(j/zoom))&0x1)*0xff)|videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+2];
			//xil_printf("%d. i=%d j=%d %0d %0x %0x \n\r",i*8+j,i,j,((*(charBitMap+i))&0x01)>>j,*(charBitMap+i),(*(charBitMap+i)>>j)&0x1);
			}
		}
	}
	else{
		//char *charBitMap = (char *)&fontBitMat[('P'-32)*8];
		for(int i=0;i<8*zoom;i++){ //columnwise
			for(int j=0;j<8*zoom;j++){//rowwise
				videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)]   = (((((0xff-*(charBitMap+(i/zoom)))>>(j/zoom))&0x1)*0xff)&videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)]);
				videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+1] = (((((0xff-*(charBitMap+(i/zoom)))>>(j/zoom))&0x1)*0xff)&videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+1]);
				videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+2] = (((((0xff-*(charBitMap+(i/zoom)))>>(j/zoom))&0x1)*0xff)&videoFramePointer[((j+yPos)*displayHSize*3)+((i+xPos)*3)+2]);
			//xil_printf("%d. i=%d j=%d %0d %0x %0x \n\r",i*8+j,i,j,((*(charBitMap+i))&0x01)>>j,*(charBitMap+i),(*(charBitMap+i)>>j)&0x1);
			}
		}
	}
	Xil_DCacheFlush();
}

void drawPlayTable(char *Buffer,u32 FrameSize,u32 HSize,u32 VSize,u32 grdSize){
	memset(Buffer,blackColor,FrameSize);
	for(int i=(HSize/grdSize-18)/2;i<(HSize/grdSize-18)/2+18;i++){
		for(int j=(VSize/grdSize-18)/2;j<(VSize/grdSize-18)/2+18;j++){
			drawSquare(i,j,grdSize,HSize,Buffer,orangeColor);
		}
	}
}
