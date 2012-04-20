//
//  SoundObjectDecoder.m
//  Vertices
//
//  Created by James O'Neill on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundObjectDecoder.h"


@implementation SoundObjectDecoder
@synthesize delegate;
@synthesize soundObject;
@synthesize startTime;
@synthesize isPlaying;

- (id)initWithData:(NSData*)data andDelegate:(id)del {
	
	if (self = [super init])
    {
		
		self->stopFromRecView = NO;
		[self setIsPlaying:[NSNumber numberWithBool:YES]];
		[self setDelegate:del];
		self->voice = -1;
		nodeIndex = 0;
		soundObject = [[NSMutableArray alloc] init];

		//unpack all the things
		unsigned char *dataArray;
		int length = [data length];
		//dataArray = (unsigned char*)malloc(length * sizeof(char));
		dataArray = (unsigned char*)[data bytes];
		int count;
		int type;
		int runningTouchCount = 0;
		NSMutableArray* runningTouchIDs = [[NSMutableArray alloc] init];
		NSMutableArray* runningXCoords = [[NSMutableArray alloc] init];
		NSMutableArray* runningYCoords = [[NSMutableArray alloc] init];
		
		if((unsigned char) dataArray[0] == 0) {
			self->isLooped = NO;
		}
		else {
			self->isLooped = YES;
		}
		int c = 1; //c = 1 is the 'looped' boolean 
		while (c < length) {
			
			SoundObjectNode* node = [[SoundObjectNode alloc] init];
			
			count = (int)((dataArray[c] & 0x1C) >> 2); //00011100 >> 2  
			type = (int)(dataArray[c] & 0x03);  //00000011
			unsigned short timeTemp = 0;
			timeTemp += (unsigned short) dataArray[c+1];
			timeTemp = timeTemp << 8;
			timeTemp += (unsigned short) dataArray[c+2];
			c += 3;
		
			node->type = type;
			[node setTime:[NSNumber numberWithDouble:(double)(timeTemp/1000.0)]];
			NSNumber* x;
			NSNumber* y;
			NSNumber* tID;
			
			for(int i = 0; i < count; i+=1) {
				tID = [NSNumber numberWithInt:(int)dataArray[c]];
				x = [NSNumber numberWithFloat: ((float)dataArray[c+1]) / 255.0 * 320.0 ];
				y = [NSNumber numberWithFloat: ((float)dataArray[c+2]) / 255.0 * 480.0 ];
				//NSNumbers will autorelease 
				
				if (type == kTouchesBegan) {
					runningTouchCount += 1;
					
					[runningTouchIDs addObject:tID];
					[runningXCoords addObject:x];
					[runningYCoords addObject:y];
				}
				else if (type == kTouchesMoved) {
					for (int j = 0; j < [runningTouchIDs count]; j+=1) {
						if([[runningTouchIDs objectAtIndex:j] intValue] == [tID intValue]) {
							[runningXCoords replaceObjectAtIndex:j withObject:x];
							[runningYCoords replaceObjectAtIndex:j withObject:y];
							break;
						}
					}
				}
				else if (type == kTouchesEnded) {
					runningTouchCount -= 1;
					
					for (int j = 0; j < [runningTouchIDs count]; j+=1) {
						if([[runningTouchIDs objectAtIndex:j] intValue] == [tID intValue]) {
							[runningTouchIDs removeObjectAtIndex:j];
							[runningXCoords removeObjectAtIndex:j];
							[runningYCoords removeObjectAtIndex:j];
							break;
						}
					}
					
				}
				
				c += 3;
			
			node->runningTouchCount = runningTouchCount;
			[node setRunningTouchIDs:[[NSMutableArray alloc] initWithArray:runningTouchIDs copyItems:YES]];
			[node setRunningXCoords:[[NSMutableArray alloc] initWithArray:runningXCoords copyItems:YES]];
			[node setRunningYCoords:[[NSMutableArray alloc] initWithArray:runningYCoords copyItems:YES]];
			
			[soundObject addObject:node];
			[node release];
		}
	}
		
		size = [soundObject count]; 
		
}
    return self;

}


//The delegate class (which will probably be EditViewController in this case) needs to implement processNode: and removeDecoder:
//processNode will send the correct messages to pd, and removeDecoder will use isEqual to have to delegate remove the decoder from its decoder array
//The delegate (EditViewController) will also work out voicing
//note that there is a setDelegate method because of @property/@synthesize. So when an object makes a SoundObjectDecoder with NSData from bluetooth, it will call setDelegate(whatever) on it

- (void)cueForTimestamp:(double)time {
	
	if([self isPlaying]) {
	
		if(self->stopFromRecView == YES) {
		
			[[self delegate] stopPlayingFromRecView:self];
			self->stopFromRecView = NO;
		}
		else {
		
			if( nodeIndex >= size) {
		
				[[self delegate] stopPlaying:self];	
			}	
			else if ( [[[[self soundObject] objectAtIndex:nodeIndex] time] doubleValue] < time) {
		
				//double timeTest = [[[[self soundObject] objectAtIndex:nodeIndex] time] doubleValue];
				
				//[[self delegate ] processNode:[[self soundObject] objectAtIndex:nodeIndex]];
				[[self delegate] processNode:[[self soundObject] objectAtIndex:nodeIndex] withVoice:self->voice];
				nodeIndex += 1;
		
		}
		
		}		
	}
}

- (void)editModeCueForTimestamp:(double)time {
	
	if([self isPlaying]) {
			
			if( nodeIndex >= size) {
				
				//[[self delegate] stopPlaying:self];	
				[[self delegate] editModeStopPlaying:self];
			}	
			else if ( [[[[self soundObject] objectAtIndex:nodeIndex] time] doubleValue] < time) {
				
				//double timeTest = [[[[self soundObject] objectAtIndex:nodeIndex] time] doubleValue];
				
				//[[self delegate ] processNode:[[self soundObject] objectAtIndex:nodeIndex]];
				SoundObjectNode* son = [[self soundObject] objectAtIndex:nodeIndex];
				[[self delegate] mergeNode:son];
				[[self delegate] processNode:son withVoice:self->voice];
				[[self delegate] editModeUpdateNodeToDraw:son];
				if([[self delegate] isRecording])
					[[[self delegate] recorder] addSON:son];
					
				nodeIndex += 1;
			}
	}
}

@end
