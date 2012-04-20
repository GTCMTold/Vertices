//
//  EditView.m
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditView.h"
#import <stdio.h>
#import <math.h>


@implementation EditView

@synthesize vertexLayers;
@synthesize vertexImages;
@synthesize touchTracker;
@synthesize nodeToDrawObject;
@synthesize pointOrder;


// Declare C function for sorting
void bubble_sort(float *arrayToSort, float length, int *arrayIDs);


- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
	
    if (self) 
	{
		[self setMultipleTouchEnabled:YES];
		self.backgroundColor = [UIColor whiteColor];
		
		vertexLayers = [[NSArray alloc] initWithObjects:
						 [[CALayer alloc] init],
						 [[CALayer alloc] init],
						 [[CALayer alloc] init],
						 [[CALayer alloc] init],
						 [[CALayer alloc] init], nil];
		
		vertexImages = [[NSArray alloc] initWithObjects:
							 [UIImage imageNamed:@"lime.png"],
							 [UIImage imageNamed:@"purple.png"],
							 [UIImage imageNamed:@"skyblue.png"],
							 [UIImage imageNamed:@"yellow.png"],
							 [UIImage imageNamed:@"red.png"], nil];
		
		for (int i = 0; i < 5; i++)
		{
			[[vertexLayers objectAtIndex:i] setBounds:CGRectMake(0.0, 0.0, 50.0, 50.0)];
			
			CGImageRef image = [[vertexImages objectAtIndex:i] CGImage];

			[[vertexLayers objectAtIndex:i] setContents:(id)image];
			[[vertexLayers objectAtIndex:i] setHidden:YES];
			[[vertexLayers objectAtIndex:i] setShouldRasterize:YES];
			[[self layer] addSublayer:[vertexLayers objectAtIndex:i]];
		}
								
		pointNumChanged = NO;
		drawingNeedsUpdate = NO;
		
    }
    return self;
}

- (void)dealloc 
{
	[vertexLayers release];
	[vertexImages release];
    [super dealloc];
}


- (void)drawRect:(CGRect)rect
{
	[self drawPoints];
	[self drawLines];		
}

- (void)drawPoints
{
	
	CALayer* vl;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
	for (int i = 0; i < MAX_TOUCHES; i++)
	{
		vl = [self.vertexLayers objectAtIndex:i];
		
		if ([self.nodeToDrawObject getPointIDAtIndex:i] != -1)
		{
			[vl setPosition:[self.nodeToDrawObject getPointAtIndex:i]];
			
			if([vl isHidden])
				[vl setHidden:NO];
		}
		else 
		{	
			[vl setHidden:YES];
		}
		
	}
	[CATransaction commit];
}

- (void)drawLines
{
	// Use this throughout the entire draw cycle.
	int numTouches = [self.nodeToDrawObject getNumTouches];
	
	if (numTouches > 1)
	{
		int numberOfLines = [self numberOfLinesForNumberOfTouches:numTouches];
	
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetLineWidth(context, LINE_WEIGHT);
	
		// Line color
		[[UIColor blackColor] set];
		
		// Create Array of Lines
		NSMutableArray *lines = [[NSMutableArray alloc] init];
		for (int i = 0; i < numberOfLines; i++)
		{
			[lines addObject:[[[Line alloc] init] autorelease]];
		}
		
		int sortedIDs[numTouches];
		for (int i = 0; i<numTouches; i+=1){
			sortedIDs[i] = 0;
		}
		
		[self grahamHullSort:sortedIDs];

		int zero = sortedIDs[0];
		[[lines objectAtIndex:0] setBegin:[self.nodeToDrawObject getPointAtIndex:zero]];

		
		for (int i = 0; i < numberOfLines; i++)
		{
			if (i < numberOfLines - 1 && numberOfLines > 1)	
			{
				int first = sortedIDs[i+1];
				int second = first;
				
				[[lines objectAtIndex:i] setEndPoint:[self.nodeToDrawObject getPointAtIndex:first]];
				[[lines	objectAtIndex:i + 1] setBegin:[self.nodeToDrawObject getPointAtIndex:second]];
			}
			else if (numberOfLines > 1)
			{
				int last = sortedIDs[0];
				[[lines objectAtIndex:i] setEndPoint:[self.nodeToDrawObject getPointAtIndex:last]];
			}
			
			
			if (numberOfLines == 1)
			{
				int one = sortedIDs[i+1];
				[[lines objectAtIndex:i] setEndPoint:[self.nodeToDrawObject getPointAtIndex:one]];
			}
			
			CGContextMoveToPoint(context, [[lines objectAtIndex:i] begin].x, [[lines objectAtIndex:i] begin].y);
			CGContextAddLineToPoint(context, [[lines objectAtIndex:i] endPoint].x, [[lines objectAtIndex:i] endPoint].y);
			CGContextStrokePath(context);
		}
		
		[lines release];
	}

}

- (void)grahamHullSort:(int *)nodeIDsToSort
{
	int lowestY = 500;
	int lowestYID = -1;
	
	int numTouches = [self.nodeToDrawObject getNumTouches];
	
	float angles[numTouches];
	
	int counter = 0;
	
	for (int i = 0; i < MAX_TOUCHES; i++)
	{
		if ([self.nodeToDrawObject getPointIDAtIndex:i] != -1)
		{
			nodeIDsToSort[counter] = i;
			
			if ([self.nodeToDrawObject getPointAtIndex:i].y <= lowestY)
			{
				lowestYID = counter;
				lowestY = [self.nodeToDrawObject getPointAtIndex:i].y;
			}
			else if ([self.nodeToDrawObject getPointAtIndex:i].y == lowestY)
			{
				int test = 999;
				
			}
			counter++;
		}
	}
	
	// If x value of two points equals each other, and one of the points is 'lowest' lines will cross 

	for (int i = 0; i < numTouches; i++)
	{
		if ([self.nodeToDrawObject getPointAtIndex:nodeIDsToSort[i]].y == [self.nodeToDrawObject getPointAtIndex:lowestYID].y && [self.nodeToDrawObject getPointAtIndex:nodeIDsToSort[i]].x == [self.nodeToDrawObject getPointAtIndex:lowestYID].x)
			angles[i] = 0.0;
		else 
		{
			angles[i] = atan(([self.nodeToDrawObject getPointAtIndex:nodeIDsToSort[i]].y - [self.nodeToDrawObject getPointAtIndex:lowestYID].y) / ([self.nodeToDrawObject getPointAtIndex:nodeIDsToSort[i]].x - [self.nodeToDrawObject getPointAtIndex:lowestYID].x));
		}

	}	
	
	bubble_sort(angles, sizeof(angles)/sizeof(angles[0]), nodeIDsToSort);
	
}


void bubble_sort(float *arrayToSort, float length, int *arrayIDs)
{
	int j;
	float t = 1.0;
	int tempID;
	
	while (length-- && t)
		for (j = 0; j < length; j++)
		{
			if (arrayToSort[j] <= arrayToSort[j + 1]) 
				continue;
			
			t = arrayToSort[j];
			tempID = arrayIDs[j];
			
			arrayToSort[j] = arrayToSort[j + 1];
			arrayIDs[j] = arrayIDs[j + 1];
			
			arrayToSort[j + 1] = t;
			arrayIDs[j + 1] = tempID;
			
			t = 1.0;
		}
}

- (int)numberOfLinesForNumberOfTouches:(int)numberOfTouches
{
	switch (numberOfTouches)
	{
		case 1:
			return 0;
			break;
		case 2:
			return 1;
			break;
		case 3:
			return 3;
			break;
		case 4:
			return 4;
			break;
		case 5:
			return 5;
			break;
		default:
			return numberOfTouches;
			break;
	}
}

@end
