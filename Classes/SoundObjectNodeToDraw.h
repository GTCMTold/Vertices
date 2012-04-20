//
//  SoundObjectNodeToDraw.h
//  Vertices
//
//  Created by Scott on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


struct SoundObjectNodeStruct
{	
	int numTouches;
	int pointIDs[5];
	CGPoint points[5];
	int currentEditing[5];
	int userNodeIDtoPlayingID[MAX_TOUCHES];
};


@interface SoundObjectNodeToDraw : NSObject {
	
	@public
	struct SoundObjectNodeStruct nodeToDraw;

}

- (int)getNumTouches;
- (void)setNumTouches:(int)numberOfTouches;

- (int)getPointIDAtIndex:(int)index;
- (void)setPointIDValue:(int)value atIndex:(int)index;

- (CGPoint)getPointAtIndex:(int)index;
- (void)setPointValues:(CGPoint)value atIndex:(int)index;

- (int)getEditStatusAtIndex:(int)index;
- (void)setEditStatusValue:(int)value atIndex:(int)index;

@end
