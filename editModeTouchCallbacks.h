//
//  editModeTouchCallbacks.h
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


@interface editModeTouchCallbacks : NSObject {
	
	EditViewController* owner;
	EditView *view;
	TouchTracker *touchTracker;
	PdInterface *pd;
	SoundObjectNodeToDraw *nodeToDrawObject;
	
	SoundObjectNodeToDraw *nodeFromUserTouches;
	SoundObjectNodeToDraw *nodeFromRecordedTouches;
	SoundObjectDecoder *editableSOD;
	
	SoundObjectNode *playingNode;
	
	BOOL editing;
}

- (id)initWithOwner:(EditViewController*)own;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)updateNodeToDrawPoints:(CGPoint)pointToUpdate withID:(int)pointID andState:(BOOL)state;
- (void)updateNodeFromUserTouchesPoints:(CGPoint)pointToUpdate withID:(int)pointID andState:(BOOL)state;
- (void)startEditModeWithDecoder:(SoundObjectDecoder *)sod;
- (void)editModeUpdateNodeToDraw:(SoundObjectNode *)son;
- (void)setNeedsDisplayHook:(NSNull*)n;
- (void)endEditMode;
- (void)linkTouchForID:(int)tID;
- (void)unlinkTouchForID:(int)tID;

- (void)mergeNode:(SoundObjectNode *)son;

-(void) playEditable;
-(void) stopEditable;

@property (nonatomic, retain)EditViewController* owner;
@property (nonatomic, retain)EditView *view;
@property (nonatomic, retain) TouchTracker *touchTracker;
@property (nonatomic, retain) PdInterface *pd;
@property (nonatomic, retain) SoundObjectNodeToDraw *nodeToDrawObject;
@property (nonatomic, retain) SoundObjectNodeToDraw *nodeFromUserTouches;
@property (nonatomic, retain) SoundObjectNodeToDraw *nodeFromRecordedTouches;
@property (nonatomic, retain) SoundObjectDecoder *editableSOD;

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, retain) SoundObjectNode *playingNode;


@end
