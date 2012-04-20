//
//  VoiceTracker.m
//  Vertices
//
//  Created by Scott on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VoiceTracker.h"

static VoiceTracker *myVoiceTracker = nil;

@implementation VoiceTracker


- (id)init 
{
	if ((self = [super init])) 
	{
		voiceQueue = [[Queue alloc] init];
		priorityQueue = [[Queue alloc] init];
		
		for (int i = 0; i < MAX_VOICES; i+=1)
		{
			[voiceQueue addObject:[NSNumber numberWithInteger:i+1]];
		}
	}
	return self;
}

// Static method to get a reference to the VoiceTracker object
+ (id)getVoiceTracker
{
	@synchronized(self)
	{
		if (myVoiceTracker == nil)
			myVoiceTracker = [[self alloc] init];
	}
	
	return myVoiceTracker;
}

- (void)dealloc
{
	[voiceQueue release];
	[priorityQueue release];
	
	[super dealloc];
}

- (int)getAvailableVoice:(NSMutableArray *)playingDecoders
{	
	int voiceNumber = -1;
	
	// check if there's an voice available in queue
	if (![voiceQueue isEmpty])
	{
		NSNumber *voiceNum = [voiceQueue pop];
		[priorityQueue addObject:voiceNum];
		voiceNumber = [voiceNum integerValue];
	}
	else // voice steal from oldest voice
	{
		NSNumber *voiceNum = [priorityQueue pop];
		[priorityQueue addObject:voiceNum];
		voiceNumber = [voiceNum integerValue];
	}
	
	// If there are any currently playing voices that have the voice number chosen from above
	// then tell that voice to stop and set the voice number to -1
	for (SoundObjectDecoder *v in playingDecoders)
	{
		if (v->voice == voiceNumber)
		{
			v->stopFromRecView = YES;
			v->voice = -1;
			break;
		}
	}
	
	return voiceNumber;
}

- (void)makeVoiceAvailable:(int)voiceNum
{
	// check if voice not already in available in queue
	[voiceQueue addObject:[NSNumber numberWithInteger:voiceNum]];
	[priorityQueue removeObjectAtIndex:voiceNum];
}

@end
