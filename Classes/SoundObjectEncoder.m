//
//  SoundObjectEncoder.m
//  Vertices
//
//  Created by James O'Neill on 10/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundObjectEncoder.h"
#import <mach/mach.h>
#import <mach/mach_time.h>


@implementation SoundObjectEncoder
@synthesize dataToSend;
@synthesize touchTracker;
@synthesize editModePreviousNode;

- (id) init {
	
	if (self = [super init])
    {
		//data = [[NSMutableArray alloc] init];
		dataArrayStartSize = 3000;
		dataArray = (unsigned char*)malloc(dataArrayStartSize * sizeof(char));
		editModePreviousNode = NULL;
		//dataToSend = nil;

    }
    return self;
}

- (void) recordStartIsEditMode:(BOOL)isEM {

	startTime = [SoundObjectEncoder timestamp];
	dataArrayI = 1;  //reserve 0 for looped property
	if(isEM) {
		editModePreviousNode = NULL;	
	}
}

- (void) recordEnd {
	[editModePreviousNode release];
	editModePreviousNode = NULL;
	[self setDataToSend:[self serializeSoundObject]];
}	

- (void) addTouches:(NSSet*)touches withAction:(unsigned char)action atTime:(double)time{
	
	unsigned char count = (unsigned char)[touches count];
	count = count << 2;
	//[data addObject:[NSNumber numberWithUnsignedChar:(action | count)]];
	dataArray[dataArrayI++] = (action | count);
	
	if (time - startTime > 65.535) {
		
		NSString* string = [NSString stringWithFormat:TAG, @"Max record time reached"];	
		NSLog(@"%@", string);

	}
	else {
		unsigned short relTimeShort = (unsigned short)((time - startTime)*1000.0);
		unsigned char relTimeCharLow = (unsigned char) (relTimeShort & 0x00FF);
		unsigned char relTimeCharHigh = (unsigned char) ((relTimeShort & 0xFF00) >> 8);
		//[data addObject:[NSNumber numberWithUnsignedChar:relTimeCharHigh]];
		//[data addObject:[NSNumber numberWithUnsignedChar:relTimeCharLow]];
		dataArray[dataArrayI++] = relTimeCharHigh;
		dataArray[dataArrayI++] = relTimeCharLow;
	
		unsigned char x;
		unsigned char y;
		CGPoint point;
		for (UITouch *touch in touches)
		{
			int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
			if (fingerID == -1) {
				//error
			NSLog(@"In recorder: finger ID not valid");
			}
			dataArray[dataArrayI++] = (unsigned char)fingerID;
		
			point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
			if ( (point.x <= 320.0 && point.x >= 0.0) && (point.y <= 480.0 && point.x >= 0.0) ) {
				
				NSLog(@"recorder:%f, %f", point.x, point.y);
				x = (unsigned char) (point.x / 320.0 * 255.0);
				y = (unsigned char) (point.y / 480.0 * 255.0);
				NSLog(@"compressed:%d, %d", x, y);
				dataArray[dataArrayI++] = x;
				dataArray[dataArrayI++] = y;
			
			}
			else {
				NSString* string = [NSString stringWithFormat:TAG, @"Point not in bounds"];	
				NSLog(@"%@", string);
			}	
		}
	}

}	

- (void) addSON:(SoundObjectNode*)son {
	
	unsigned char action;
	double time = [[son time] doubleValue];
	int currCount = [[son runningXCoords] count];
	int lastCount = [[editModePreviousNode runningXCoords] count];
	
	if(editModePreviousNode == NULL) {
		action = kTouchesBegan;
	}
	else {
		int lastCount = [[editModePreviousNode runningXCoords] count];
		if(currCount > lastCount) {
			action = kTouchesBegan;
		}
		else if(currCount == lastCount) {
			action = kTouchesMoved;
		}
		else action = kTouchesEnded;
	}
	NSMutableArray* touches = [[NSMutableArray alloc] init];
	NSMutableArray* touchIDs = [[NSMutableArray alloc] init];
	float x, y;
	int tID, i, j;
	if(action == kTouchesBegan) {
			//get touches that began
		BOOL tIDisNew;
		for(i = 0; i<currCount; i+=1) {
			tID = [[[son runningTouchIDs] objectAtIndex:i] intValue];
			tIDisNew = TRUE;
			for(j = 0; j<lastCount; j+=1) {
				if([[[editModePreviousNode runningTouchIDs] objectAtIndex:j] intValue] == tID) {
					tIDisNew = FALSE;
					break;
				}
			}
			if(tIDisNew) {
				x = [[[son runningXCoords] objectAtIndex:i] floatValue];
				y = [[[son runningYCoords] objectAtIndex:i] floatValue];
				[touches addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
				[touchIDs addObject:[NSNumber numberWithInt:tID]];
			}
		}
	}
	else if(action == kTouchesMoved) {
		float lastX, lastY;
		for(i = 0; i<currCount; i+=1) {
			x = [[[son runningXCoords] objectAtIndex:i] floatValue];
			y = [[[son runningYCoords] objectAtIndex:i] floatValue];
			lastX = [[[editModePreviousNode runningXCoords] objectAtIndex:i] floatValue];
			lastY = [[[editModePreviousNode runningYCoords] objectAtIndex:i] floatValue];
			if ( (x != lastX) || (y != lastY) ) {
				tID = [[[son runningTouchIDs] objectAtIndex:i] intValue];
				[touches addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
				[touchIDs addObject:[NSNumber numberWithInt:tID]];
			}
		}
	}
	else if(action == kTouchesEnded) {
		BOOL tIDisGone;
		for(i = 0; i<lastCount; i+=1) {
			tID = [[[editModePreviousNode runningTouchIDs] objectAtIndex:i] intValue];
			tIDisGone = TRUE;
			for(j = 0; j<currCount; j+=1) {
				if([[[son runningTouchIDs] objectAtIndex:j] intValue] == tID) {
					tIDisGone = FALSE;
					break;	
				}
			}
			if(tIDisGone) {
				x = [[[editModePreviousNode runningXCoords] objectAtIndex:i] floatValue];
				y = [[[editModePreviousNode runningYCoords] objectAtIndex:i] floatValue];
				[touches addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
				[touchIDs addObject:[NSNumber numberWithInt:tID]]; 
			}
		}
	}
	
	unsigned char count = (unsigned char)[touches count];
	unsigned char countShift = count << 2;
	dataArray[dataArrayI++] = (action | countShift);
	
		unsigned short relTimeShort = (unsigned short)(time*1000.0);
		unsigned char relTimeCharLow = (unsigned char) (relTimeShort & 0x00FF);
		unsigned char relTimeCharHigh = (unsigned char) ((relTimeShort & 0xFF00) >> 8);
		dataArray[dataArrayI++] = relTimeCharHigh;
		dataArray[dataArrayI++] = relTimeCharLow;
		
		unsigned char ucX;
		unsigned char ucY;
		CGPoint point;
		for (i = 0; i<count; i+=1) {
			//add tID
			dataArray[dataArrayI++] = (unsigned char)[[touchIDs objectAtIndex:i] intValue];
			point = [[touches objectAtIndex:i] CGPointValue];
			ucX = (unsigned char) (point.x / 320.0 * 255.0);
			ucY = (unsigned char) (point.y / 480.0 * 255.0);
			dataArray[dataArrayI++] = ucX;
			dataArray[dataArrayI++] = ucY;
			
		}
	
	[self setEditModePreviousNode:son];
}

- (NSData*) serializeSoundObject {
	//int size = [data count];
	//unsigned char *dataArray;
	//dataArray = (unsigned char*)malloc(size * sizeof(char));
	//size += 1;
	//	for (int i = 1; i < size; i+=1) {
	//		dataArray[i] = [[data objectAtIndex:i-1] unsignedCharValue];
	//		NSLog(@"%c", dataArray[i]);
	//	}	
	
	
	//add loop property to data - that is, waste an entire byte on one bool.
	//for BOOL, YES is #defined as 1, NO as 0
	
	dataArray[0] = (unsigned char)isLooped;
	
	NSData* dataOut = [NSData dataWithBytes: dataArray length: sizeof(char)*dataArrayI];
	//free(dataArray);
	return dataOut;
}

+ (double)timestamp
{
    // get the timebase info -- different on phone and OSX
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
	
    // get the time
    uint64_t absTime = mach_absolute_time();
	
    // apply the timebase info
    absTime *= info.numer;
    absTime /= info.denom;
	
    // convert nanoseconds into seconds and return
    return ((double) absTime / 1000000000.0);
}


@end
