/*
 * video.h
 *
 *  Created on: Apr 17, 2020
 *      Author: VIPIN
 */

#ifndef SRC_VIDEO_H_
#define SRC_VIDEO_H_

#include "xil_types.h"
#include "xscugic.h"
#include "xaxivdma.h"

//These are hardware dependent definitions. Do not modify unless you modify it in hardware



int initVideo(char *Buffer,u32 VSize,u32 HSize,XScuGic *Intc);
int initIntrController(XScuGic *Intc);
int SetupVideoIntrSystem(XAxiVdma *AxiVdmaPtr, u16 ReadIntrId, XScuGic *Intc);
//void ReadCallBack(void *CallbackRef, u32 Mask);
//void readGridData(u32 displayHSize,char *charBitMap,u32 hOffset, u32 vOffset,u32 zoom,char* videoFramePointer );
#endif /* SRC_VIDEO_H_ */

