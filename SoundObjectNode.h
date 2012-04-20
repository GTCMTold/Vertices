//
//  SoundObjectNode.h
//  Vertices
//
//  Created by James O'Neill on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SoundObjectNode : NSObject {

	@public
	int type;
	int runningTouchCount;
	NSNumber *time;
	NSMutableArray *runningXCoords;
	NSMutableArray *runningYCoords;
	NSMutableArray *runningTouchIDs;
	
}

@property (nonatomic, retain) NSMutableArray *runningXCoords;
@property (nonatomic, retain) NSMutableArray *runningYCoords;
@property (nonatomic, retain) NSMutableArray *runningTouchIDs;
@property (nonatomic, retain) NSNumber *time;

@end
