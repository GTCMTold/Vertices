//
//  TouchTracker.h
//  Vertices
//
//  Created by James O'Neill on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

struct TouchTrack
{	
	id m_touchPointer;
};


#import <Foundation/Foundation.h>


@interface TouchTracker : NSObject {
	
	@public
	struct TouchTrack g_touchTracker[MAX_TOUCHES];
	
	
}

- (id)init;
- (int) GetFingerTrackIDByTouch:(id)touch;
- (int) AddNewTouch:(id)touch;
- (int) GetTouchesActive;


@end
