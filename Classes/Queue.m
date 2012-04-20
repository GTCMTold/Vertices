//
//  Queue.m
//  Vertices
//
//  Created by Scott on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Queue.h"


@implementation Queue

- (id)init 
{
	if ((self = [super init])) 
	{
		objects = [[NSMutableArray alloc] init];    
	}
	return self;
}

- (void)dealloc 
{
    [objects release];
    [super dealloc];
}

- (void)addObject:(id)object 
{
	[objects addObject:object];
}

// Alright, this is kind of a hack and doesn't fit in with the 'general' nature of this class
- (void)removeObjectAtIndex:(int)object
{
	for (int i = 0; i < [objects count]; i += 1)
	{
		if ([[objects objectAtIndex:i] integerValue] == object)
			[objects removeObjectAtIndex:i];
	}
}

// Pops the object at the beginning of the queue
- (id)pop
{
	id object = nil;
	
	if ([objects count] > 0) 
	{
		object = [objects objectAtIndex:0];
		[objects removeObjectAtIndex:0];
	}
	
	return object;
}

- (BOOL)isEmpty
{
	if ([objects count] == 0)
		return YES;
	else 
		return NO;
}

@end
