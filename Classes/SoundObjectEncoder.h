//
//  SoundObjectEncoder.h
//  Vertices
//
//  Created by James O'Neill on 10/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#define kTouchesBegan 1
//#define kTouchesMoved 2
//#define kTouchesEnded 3
#define TAG @"SoundObjectEncoder "

#import <Foundation/Foundation.h>
#import "TouchTracker.h"
#import "SoundObjectNode.h"

@interface SoundObjectEncoder : NSObject {

	NSMutableArray* data;
	double startTime;
	
	@public
	NSData* dataToSend;
	unsigned char *dataArray;
	int dataArrayI;
	int dataArrayStartSize;
	BOOL isLooped;
	TouchTracker* touchTracker;
	SoundObjectNode* editModePreviousNode;

}

+ (double) timestamp;
- (void) recordStartIsEditMode;
- (void) recordEnd;
- (void) addTouches:(NSSet*)touches withAction:(unsigned char)action atTime:(double)time;
- (NSData*) serializeSoundObject;
- (void) addSON:(SoundObjectNode*)son;


@property (nonatomic, retain) NSData* dataToSend;
@property (nonatomic, retain) TouchTracker* touchTracker;
@property (nonatomic, retain) SoundObjectNode* editModePreviousNode;
@end
