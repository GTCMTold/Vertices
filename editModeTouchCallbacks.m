//
//  editModeTouchCallbacks.m
//  Vertices
//
//  Created by James O'Neill on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "editModeTouchCallbacks.h"


@implementation editModeTouchCallbacks
@synthesize owner;
@synthesize	view;
@synthesize touchTracker;
@synthesize pd;
@synthesize nodeToDrawObject;
@synthesize nodeFromUserTouches;
@synthesize nodeFromRecordedTouches;
@synthesize editableSOD;

@synthesize editing;
@synthesize playingNode;

- (id)initWithOwner:(EditViewController*)own {
    self = [super init];
    if (self) {
		
		[self setOwner:own];
		[self setView:(EditView*)[[self owner] view]];
		[self setTouchTracker:[[self owner] touchTracker]];
		[self setPd:[[self owner] pd]];
		[self setNodeToDrawObject:[[self owner] nodeToDrawObject]];
		
		
		//these two SOs will be used to determine the nodeToDrawObject for each node that is playing back
		[self setNodeFromRecordedTouches:[[SoundObjectNodeToDraw alloc] init]];
		[self setNodeFromUserTouches:[[SoundObjectNodeToDraw alloc] init]];
		
		
		editing = NO;
		
	}
    return self;
}

-(void)startEditModeWithDecoder:(SoundObjectDecoder *)sod {
	[self setEditableSOD:sod]; //copies the sod
	editableSOD->voice = kPreviewVoice; 
	[editableSOD setIsPlaying:[NSNumber numberWithBool:FALSE]];
	[self playEditable];
	[NSThread detachNewThreadSelector:@selector(editableObjectsPlaybackTimer) 
							 toTarget:self 
						   withObject:nil];
}


-(void)endEditMode {
	
	
}

-(void) playEditable {
	
	if (self.editableSOD != NULL) {
		[editableSOD setIsPlaying:[NSNumber numberWithBool:TRUE]];
		editableSOD->nodeIndex = 0;
		[editableSOD setStartTime:[NSNumber numberWithDouble:[EditViewController timestamp]]];
	}
}

-(void) stopEditable {
	
}

- (void)editableObjectsPlaybackTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSMutableArray* playingObjects = [receivedViewController playingSoundObjectDecoders];
	double time;
	while (TRUE) {
		[NSThread sleepForTimeInterval:0.006];	
		if(owner.scratchMode)
			break;
		else if([editableSOD isPlaying]) {
			time = [EditViewController timestamp];
			
			//MAKE NOISE
			[editableSOD editModeCueForTimestamp:time - [[editableSOD startTime] doubleValue]];
			
			/*
			for (i = 0; i<[playingObjects count]; i+=1) {
				//cue objects
				[[playingObjects objectAtIndex:i] cueForTimestamp:(time - [[[playingObjects objectAtIndex:i] startTime] doubleValue])]; 
			}
			 */
		}
	}	
	[pool release];
}


- (void)updateNodeToDrawPoints:(CGPoint)pointToUpdate withID:(int)pointID andState:(BOOL)state
{	
	if (state == YES)
	{
		[[owner nodeToDrawObject] setPointIDValue:pointID atIndex:pointID];
		[[owner nodeToDrawObject] setPointValues:pointToUpdate atIndex:pointID];
	}
	else
	{
		[[owner nodeToDrawObject] setPointIDValue:-1 atIndex:pointID];
	}
}

- (void)updateNodeFromUserTouchesPoints:(CGPoint)pointToUpdate withID:(int)pointID andState:(BOOL)state
{	
	if (state == YES)
	{
		[[self nodeFromUserTouches] setPointIDValue:pointID atIndex:pointID];
		[[self nodeFromUserTouches] setPointValues:pointToUpdate atIndex:pointID];
	}
	else
	{
		[[self nodeFromUserTouches] setPointIDValue:-1 atIndex:pointID];
	}
}


- (void)editModeUpdateNodeToDraw:(SoundObjectNode *)son {
	
	int length = [[son runningXCoords] count];
	[[owner nodeToDrawObject] setNumTouches:length];
	int tID;
	int i;
	CGPoint point;
	//add touches
	for (i = 0; i < length; i+=1) {
		point.x = [[[son runningXCoords] objectAtIndex:i] floatValue];
		point.y = [[[son runningYCoords] objectAtIndex:i] floatValue]; 
		tID = [[[son runningTouchIDs] objectAtIndex:i] intValue];
		[self updateNodeToDrawPoints:point withID:tID andState:YES];
	}
	//take away touches that may have been there - touchIDs will always be contiguous and increasing because of the way they are assigned
	for (i = length; i<MAX_TOUCHES; i+=1) {
		[self updateNodeToDrawPoints:point withID:i andState:NO];
	}
	
	[self performSelectorOnMainThread:@selector(setNeedsDisplayHook:) withObject:nil waitUntilDone:NO];
}

- (void)setNeedsDisplayHook:(NSNull*)n {
	[owner.view setNeedsDisplay];
}


- (void)mergeNode:(SoundObjectNode *)son {
	editing = YES;
	int playingIDLink, playingIndex;
	CGPoint userPoint;
	for(int i = 0; i<MAX_TOUCHES; i+=1) {
		playingIDLink = [self nodeFromUserTouches]->nodeToDraw.userNodeIDtoPlayingID[i];
		if(playingIDLink != -1) {
			playingIndex = -1;
			for(int j = 0; j<[[son runningTouchIDs] count]; j+=1) {
				if([[[son runningTouchIDs] objectAtIndex:j] intValue] == playingIDLink) {
					playingIndex = j;
					break;
				}
			}
		
			if(playingIndex == -1) {
			 //the vertex has been removed in the recording - unlink
				[self unlinkTouchForID:i];
			}else { 
			userPoint = [[self nodeFromUserTouches] getPointAtIndex:i];
			[[son runningXCoords] replaceObjectAtIndex:playingIndex withObject:[NSNumber numberWithFloat:userPoint.x]];
			[[son runningYCoords] replaceObjectAtIndex:playingIndex withObject:[NSNumber numberWithFloat:userPoint.y]];
			}
		}
	}
	
	[self setPlayingNode:son];
	
}
	 

- (void)linkTouchForID:(int)tID
{	
	int length = [[[self playingNode] runningXCoords] count];
	CGPoint newPoint = [[self nodeFromUserTouches] getPointAtIndex:tID];
	CGPoint point;
	float diffx, diffy, dist;
	int playingTID;
	BOOL touchControlled;
	//find the points that are not controlled and see if one is close enough
	for (int i = 0; i < length; i+=1) {
		playingTID = [[[[self playingNode] runningTouchIDs] objectAtIndex:i] intValue];
		
		touchControlled = NO;
		for(int j = 0; j<MAX_TOUCHES; j+=1) {
			if([self nodeFromUserTouches]->nodeToDraw.userNodeIDtoPlayingID[j] == playingTID) {
				touchControlled = YES;
				break;
			}
		}
		
	if(!touchControlled) {
		point.x = [[[[self playingNode] runningXCoords] objectAtIndex:i] floatValue];
		point.y = [[[[self playingNode] runningYCoords] objectAtIndex:i] floatValue];
		
		diffx = newPoint.x - point.x;
		diffy = newPoint.y - point.y;
		dist = sqrt(diffx * diffx + diffy * diffy);
		
		if (dist < 35.0) {
			[self nodeFromUserTouches]->nodeToDraw.userNodeIDtoPlayingID[tID] = playingTID;
			[[owner nodeToDrawObject] setEditStatusValue:1 atIndex:tID];
			return;
			//float oldValX = [[[[self playingNode] runningXCoords] objectAtIndex:i] floatValue];
			//NSLog(@"Got em': %f", dist);
			//[[[self playingNode] runningXCoords] replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:newPoint.x]];
			//[[[self playingNode] runningYCoords] replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:newPoint.y]];
			//float newValX = [[[[self playingNode] runningXCoords] objectAtIndex:i] floatValue];
			//[self updateNodeToDrawPoints:newPoint withID:tID andState:YES];
		}
	}
	}
}

- (void)unlinkTouchForID:(int)tID {
	[self nodeFromUserTouches]->nodeToDraw.userNodeIDtoPlayingID[tID] = -1;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	
	NSSet *beginTouches = [event allTouches];
	for (UITouch *touch in beginTouches)
	{
		int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
		if(fingerID > 4) {
			
			NSLog(@"shit");	
		}
		CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
		
		if (fingerID == -1)
		{
			//add it to our list
			fingerID = [touchTracker AddNewTouch:touch];
			[self updateNodeFromUserTouchesPoints:point withID:fingerID andState:YES];
			
		} else
		{
			[self updateNodeFromUserTouchesPoints:point withID:fingerID andState:YES];
			continue;
		}
		
	[self linkTouchForID:fingerID];
		
	}
		
	//ADD TO nodeFromUserTouches
	
	/*
	NSSet *beginTouches = [event allTouches];
	[owner setCurrentTouches:[event allTouches]];
	//owner->numberOfCurrentTouches += [beginTouches count];
	
	//owner->nodeToDraw.numTouches = [beginTouches count];
	[[owner nodeToDrawObject] setNumTouches:[beginTouches count]];
	
	
	//[pd numberOfTouches:(float)(owner->numberOfCurrentTouches) toVoiceWithId:kPreviewVoice];
	
	float xCentroid = 0;
	float yCentroid = 0;
	float xSum = 0;
	float ySum = 0;
	
	// Compute centroid of each coordinate
	for (UITouch *touch in beginTouches)
	{
		int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
		if(fingerID > 4) {
			
			NSLog(@"shit");	
		}
		CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
		
		if (fingerID == -1)
		{
			//add it to our list
			fingerID = [touchTracker AddNewTouch:touch];
			[self updateNodeToDrawPoints:point withID:fingerID andState:YES];
			
		} else
		{
			//already on the list.  Don't send this
			int dsfdsfsdf = 1;//LogMsg("Ignoring touch %d", fingerID);
			[self updateNodeToDrawPoints:point withID:fingerID andState:YES];
			continue;
		}
		
		//touches will already be logged for the recorder to fetch
		if(owner->record == TRUE)
			[owner.recorder addTouches:touches withAction:kTouchesBegan atTime:(double)[event timestamp]];
		
		xSum = xSum + point.x;
		ySum = ySum + point.y;
		
	}
	
	[view setNeedsDisplay];
	
	xCentroid = xSum / [[owner nodeToDrawObject] getNumTouches];
	yCentroid = ySum / [[owner nodeToDrawObject] getNumTouches];
	
	[pd sendXCentroid:xCentroid toVoiceWithId:kPreviewVoice];
	[pd sendYCentroid:yCentroid toVoiceWithId:kPreviewVoice];
	
	[pd numberOfTouches:(float)([[owner nodeToDrawObject] getNumTouches]) toVoiceWithId:kPreviewVoice];
	
	if(owner->record == TRUE)
		[owner.recorder addTouches:touches withAction:kTouchesBegan atTime:(double)[event timestamp]];
	 
	 */
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//ADD TO nodeFromUserTouches
	NSSet *movingTouches = [event allTouches];
	for (UITouch *touch in movingTouches)
	{
		int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
		if(fingerID > 4) {
			
			NSLog(@"shit");	
		}
		CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
		
		if (fingerID != -1)
		{
			[self updateNodeFromUserTouchesPoints:point withID:fingerID andState:YES];
			
		} else
		{
			fingerID = [touchTracker AddNewTouch:touch];
			[self updateNodeFromUserTouchesPoints:point withID:fingerID andState:YES];
			
			continue;
		}
		
		if([self nodeFromUserTouches]->nodeToDraw.userNodeIDtoPlayingID[fingerID] == -1)
		[self linkTouchForID:fingerID];
	}
	
	/*
	if (editing)
	{
		
		[self linkTouchIDs:movingTouches];
		
		editing = NO;
	}
	*/
	/*	
	NSSet *movingTouches = [event allTouches];
	
	[owner setCurrentTouches:movingTouches];
	
	float xCentroid = 0;
	float yCentroid = 0;
	float xSum = 0;
	float ySum = 0;
	
	// Compute centroid of each coordinate
	for (UITouch *touch in movingTouches)
	{
		int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
		if(fingerID > 4) {
			
			NSLog(@"shit");	
		}
		CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
		
		if (fingerID != -1)
		{
			[self updateNodeToDrawPoints:point withID:fingerID andState:YES];
			
		} else
		{
			int sfsdf = 1;//wasn't on our list?!
			fingerID = [touchTracker AddNewTouch:touch];
			[self updateNodeToDrawPoints:point withID:fingerID andState:YES];
			
			continue;
		}
		
		xSum = xSum + point.x;
		ySum = ySum + point.y;
	}
	
	[view setNeedsDisplay];
	
	xCentroid = xSum / [[owner nodeToDrawObject] getNumTouches];
	yCentroid = ySum / [[owner nodeToDrawObject] getNumTouches];
	
	
	[pd sendXCentroid:xCentroid toVoiceWithId:kPreviewVoice];
	[pd sendYCentroid:yCentroid toVoiceWithId:kPreviewVoice];
	
	if(owner->record == TRUE)
		[owner.recorder addTouches:touches withAction:kTouchesMoved atTime:(double)[event timestamp]];
	
	//}	
	 */
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	
	for (UITouch *touch in touches)
    {
		
		//found a touch.  Is it already on our list?
        int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
		CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
		
        if (fingerID != -1)
        {
			touchTracker->g_touchTracker[fingerID].m_touchPointer = nil;
			[self updateNodeFromUserTouchesPoints:point withID:fingerID andState:NO];
			[self unlinkTouchForID:fingerID];
			
        } else
        {
			//nothing
		}
	}
	
	/*
	if (editing)
	{
		NSSet *beginTouches = [event allTouches];
		
		[self linkTouchIDs:beginTouches];
		
		editing = NO;
	}
	//ADD TO nodeFromUserTouches
	*/
	/*
	//NSSet *endTouches = [event allTouches];
	//numberOfCurrentTouches -= [endTouches count];
	//owner->numberOfCurrentTouches -= [touches count];
	
	
	[owner setCurrentTouches:[event allTouches]]; 
	[[owner currentTouches] minusSet:touches];   //doesn't work - using numberOfCurrentTouches to check if record pressed while fingers already down
	
	[[owner nodeToDrawObject] setNumTouches:[[owner nodeToDrawObject] getNumTouches] - [touches count]];
	
	[pd numberOfTouches:[[owner nodeToDrawObject] getNumTouches] toVoiceWithId:kPreviewVoice];
	
	for (UITouch *touch in touches)
    {
		
		//found a touch.  Is it already on our list?
        int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
		CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
		
        if (fingerID != -1)
        {
			touchTracker->g_touchTracker[fingerID].m_touchPointer = nil;
			[self updateNodeToDrawPoints:point withID:fingerID andState:NO];
			
        } else
        {
            //wasn't on our list
			int sdfdsfdsfdsf = 0;
            continue;
        }
	}
	
	[view setNeedsDisplay];
	
	if (owner->record == TRUE)
		[owner.recorder addTouches:touches withAction:kTouchesEnded atTime:(double)[event timestamp]];
	 
	 */
	
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//this is probably what caused our crash in the beta demo
	/*
	 //owner->nodeToDraw.numTouches -= [touches count];
	 //[pd numberOfTouches:(float)owner->nodeToDraw.numTouches toVoiceWithId:kPreviewVoice];
	 
	 [[owner nodeToDraw] setNumTouches:[[owner nodeToDrawObject] getNumTouches] - [touches count]];
	 //[pd numberOfTouches:[[owner nodeToDrawObject] numTouches] toVoiceWithId:kPreviewVoice];
	 [pd numberOfTouches:[[owner nodeToDrawObject] getNumTouches] toVoiceWithId:kPreviewVoice];
	 
	 // Enumerate through all the touch objects.
	 for (UITouch *touch in touches)
	 {
	 //found a touch.  Is it already on our list?
	 int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
	 CGPoint point = [touch locationInView:[UIApplication sharedApplication].keyWindow];
	 
	 if (fingerID != -1)
	 {
	 touchTracker->g_touchTracker[fingerID].m_touchPointer = nil;
	 [self updateNodeToDrawPoints:point withID:fingerID andState:NO];
	 } else
	 {
	 //wasn't on our list
	 continue;
	 }
	 }
	 
	 [view updateDrawing:YES];
	 */
}



@end
