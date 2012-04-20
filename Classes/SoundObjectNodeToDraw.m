//
//  SoundObjectNodeToDraw.m
//  Vertices
//
//  Created by Scott on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundObjectNodeToDraw.h"


@implementation SoundObjectNodeToDraw


- (SoundObjectNodeToDraw *) init
{
	self = [super init];
	
	if (self != nil)
	{
		
		for(int i = 0; i<MAX_TOUCHES; i+=1)
			nodeToDraw.userNodeIDtoPlayingID[i] = -1;
		
		nodeToDraw.numTouches = 0;
		
		for (int i = 0; i < MAX_TOUCHES; i++)
		{
			nodeToDraw.pointIDs[i] = -1;
			nodeToDraw.points[i].x = 0.0;
			nodeToDraw.points[i].y = 0.0;
			nodeToDraw.currentEditing[i] = 0;
		}
		
	}
	
	return self;
}

- (int)getNumTouches
{
	return nodeToDraw.numTouches;
}
- (void)setNumTouches:(int)numberOfTouches
{
	nodeToDraw.numTouches = numberOfTouches;
}

- (int)getPointIDAtIndex:(int)index
{
	if (index < MAX_TOUCHES)
		return nodeToDraw.pointIDs[index];
}

- (int)getEditStatusAtIndex:(int)index
{
	if (index < MAX_TOUCHES)
		return nodeToDraw.currentEditing[index];
}

- (void)setEditStatusValue:(int)value atIndex:(int)index
{
	if (index < MAX_TOUCHES)
		nodeToDraw.currentEditing[index] = value;
}

- (void)setPointIDValue:(int)value atIndex:(int)index
{
	if (index <	MAX_TOUCHES)
		nodeToDraw.pointIDs[index] = value;
}

- (CGPoint)getPointAtIndex:(int)index
{
	if (index < MAX_TOUCHES)
		return nodeToDraw.points[index];
}

- (void)setPointValues:(CGPoint)value atIndex:(int)index
{
	if (index < MAX_TOUCHES)
		nodeToDraw.points[index] = value;
}				  
				  
- (void) dealloc
{
	[super dealloc];
}

@end
