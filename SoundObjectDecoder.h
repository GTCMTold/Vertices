//
//  SoundObjectDecoder.h
//  Vertices
//
//  Created by James O'Neill on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import "SoundObjectNode.h"


@interface SoundObjectDecoder : NSObject {

	@public
	NSMutableArray* soundObject;
	NSNumber* startTime;
	NSNumber* isPlaying;
	int size;
	int voice;
	BOOL isLooped;
	BOOL stopFromRecView;
	id delegate;
	int nodeIndex;
	int userNodeIDtoPlayingID[MAX_TOUCHES];

}

- (id)initWithData:(NSData*)data andDelegate:(id)del;
- (void)setDelegate:(id)del;
- (void)cueForTimestamp:(double)time;

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSMutableArray* soundObject;
@property (nonatomic, retain) NSNumber* startTime;
@property (retain) NSNumber* isPlaying;
@end
