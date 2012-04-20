//
//  VoiceTracker.h
//  Vertices
//
//  Created by Scott on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Queue.h"
#import "SoundObjectDecoder.h"

/*
 *
 *	Singleton class to handle allocation of voices.
 *
 */

@interface VoiceTracker : NSObject {

	Queue *voiceQueue;
	Queue *priorityQueue;
}

- (int)getAvailableVoice:(NSMutableArray *)playingDecoders;
- (void)makeVoiceAvailable:(int)voiceNum;
+ (id)getVoiceTracker;

@end
