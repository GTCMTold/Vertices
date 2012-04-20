//
//  EditView.h
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Line.h"
#import "TouchTracker.h"
#import "EditViewController.h"
#import "SoundObjectNodeToDraw.h"

#define LINE_WEIGHT 8.0

@interface EditView : UIView {
	
	NSArray *vertexLayers;
	NSArray *vertexImages;
	
	SoundObjectNodeToDraw *nodeToDrawObject;
	
	BOOL pointNumChanged;
	BOOL drawingNeedsUpdate;
	
}

- (void)updateDrawing:(BOOL)numberOfPointsChanged;
- (int)numberOfLinesForNumberOfTouches:(int)numberOfTouches;
- (void)grahamHullSort:(int *)nodeIDsToSort;
- (void)drawPoints;
- (void)drawLines;

@property (nonatomic, retain) TouchTracker *touchTracker;
@property (nonatomic, retain) NSArray *vertexImages;
@property (nonatomic, retain) NSArray *vertexLayers;
@property (nonatomic, retain) NSMutableArray *pointOrder;
@property (nonatomic, retain) SoundObjectNodeToDraw *nodeToDrawObject;


@end
