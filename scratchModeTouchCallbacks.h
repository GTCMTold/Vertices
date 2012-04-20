//
//  scratchModeTouchCallbacks.h
//  Vertices
//
//  Created by James O'Neill on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchTracker.h"
#import "PdInterface.h"
#import "EditViewController.h"
#import "EditView.h"
#import "SoundObjectNodeToDraw.h"


@interface scratchModeTouchCallbacks : NSObject {

	EditViewController* owner;
	EditView *view;
	TouchTracker *touchTracker;
	PdInterface *pd;
	SoundObjectNodeToDraw *nodeToDrawObject;
	int acceptTouchesMoved;
}

- (id)initWithOwner:(EditViewController*)own;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@property (nonatomic, retain)EditViewController* owner;
@property (nonatomic, retain)EditView *view;
@property (nonatomic, retain) TouchTracker *touchTracker;
@property (nonatomic, retain) PdInterface *pd;
@property (nonatomic, retain) SoundObjectNodeToDraw *nodeToDrawObject;

@end
