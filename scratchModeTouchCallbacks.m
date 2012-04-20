//
//  scratchModeTouchCallbacks.m
//  Vertices
//
//  Created by James O'Neill on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "scratchModeTouchCallbacks.h"


@implementation scratchModeTouchCallbacks
@synthesize owner;
@synthesize	view;
@synthesize touchTracker;
@synthesize pd;
@synthesize nodeToDrawObject;

- (id)initWithOwner:(EditViewController*)own {
    self = [super init];
    if (self) {
		
		[self setOwner:own];
		[self setView:(EditView*)[[self owner] view]];
		[self setTouchTracker:[[self owner] touchTracker]];
		[self setPd:[[self owner] pd]];
		[self setNodeToDrawObject:[[self owner] nodeToDrawObject]];
		acceptTouchesMoved = 0;
		
    }
    return self;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	
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
		
		xSum = xSum + point.x;
		ySum = ySum + point.y;
		
	}
	
	[view setNeedsDisplay];
	
	xCentroid = xSum / [[owner nodeToDrawObject] getNumTouches];
	yCentroid = ySum / [[owner nodeToDrawObject] getNumTouches];
	
	[pd sendXCentroid:xCentroid toVoiceWithId:kPreviewVoice];
	[pd sendYCentroid:yCentroid toVoiceWithId:kPreviewVoice];
	
	[pd numberOfTouches:(float)([[owner nodeToDrawObject] getNumTouches]) toVoiceWithId:kPreviewVoice];
	
	//touches will already be logged for the recorder to fetch
	if(owner->record == TRUE)
		[owner.recorder addTouches:touches withAction:kTouchesBegan atTime:(double)[event timestamp]];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//double currentTime = [EditViewController timestamp];
	
	//if (currentTime - owner->lastTime > 0.6)    ///FIX THIS - update lastTimefile://localhost/Users/jamesoneill/NMVertices/Vertices/Vertices/Vertices.xcodeproj
	//{
	
	if(owner->record == TRUE)
		[owner.recorder addTouches:touches withAction:kTouchesMoved atTime:(double)[event timestamp]];
		
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
			
			NSLog(@"callback:%f  %f", point.x, point.y);
		}
		
		[view setNeedsDisplay];
		
		xCentroid = xSum / [[owner nodeToDrawObject] getNumTouches];
		yCentroid = ySum / [[owner nodeToDrawObject] getNumTouches];
		
		
		[pd sendXCentroid:xCentroid toVoiceWithId:kPreviewVoice];
		[pd sendYCentroid:yCentroid toVoiceWithId:kPreviewVoice];
		
	//}	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	
	//NSSet *endTouches = [event allTouches];
	//numberOfCurrentTouches -= [endTouches count];
	//owner->numberOfCurrentTouches -= [touches count];
	
	if (owner->record == TRUE)
		[owner.recorder addTouches:touches withAction:kTouchesEnded atTime:(double)[event timestamp]];
	
	
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
