//
//  EditViewController.h
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PdInterface.h"
#import "SoundObjectEncoder.h"
#import "SentViewController.h"
#import "ReceivedViewController.h"
#import "TouchTracker.h"
#import "SoundObjectNodeToDraw.h"

/*struct SoundObjectNodeStruct
{	
	int numTouches;
	int pointIDs[5];
	CGPoint points[5];
};*/


@interface EditViewController : UIViewController {
	
	@public
	//struct SoundObjectNodeStruct nodeToDraw;
	SoundObjectNodeToDraw *nodeToDrawObject;
	
	id editModeTCs;
	id scratchModeTCs;
	
	PdInterface *pd;
	SentViewController *sentViewController;
	ReceivedViewController *receivedViewController;
	
	UILabel *touchPhaseText;		// Displays the touch phase
	UIButton *loopSwitch;
	UIButton *recordButton;
	UIButton *editModePlayButton;
	UIButton *clearButton;
	
	//UISwitch *presetSwitch;
	
	NSUInteger numberOfCurrentTouches;		// Keeps track of the current number of touches, so libpd has accurate value
	NSMutableSet * currentTouches;    //to be used when record button is pressed
	
	SoundObjectEncoder* recorder;
	TouchTracker* touchTracker;
	bool record;
	double currentTime;
	double lastTime;

	bool scratchMode;
}

- (EditViewController *)initWithPd:(PdInterface *)pdPointer;
- (void)postInit;
- (void)receivedObjectsPlaybackTimer;
//- (void)processNode:(SoundObjectNode *)node;
- (void)processNode:(SoundObjectNode *)node withVoice:(int)voiceNumber;
- (void)stopPlaying:(SoundObjectDecoder *)decoder;
- (void)recordButtonCB:(UIButton *)button;
- (void)loopSwitchCB:(UIButton *)button;
- (void)clearButtonCB:(UIButton *)button;
- (void)editModePlayButtonCB:(UIButton *)button;
- (void)startEditModeWithDecoder:(SoundObjectDecoder *)sod;
- (void)editModeUpdateNodeToDraw:(SoundObjectNode *)son;
- (void)endEditMode;
- (BOOL)isRecording;
+ (double)timestamp;




@property (nonatomic, retain) PdInterface *pd;
@property (nonatomic, retain) UILabel *touchPhaseText;
@property (nonatomic, retain) UIButton *loopSwitch;
@property (nonatomic, retain) UIButton *recordButton;
@property (nonatomic, retain) UIButton *editModePlayButton;
@property (nonatomic, retain) UIButton *clearButton;

@property (nonatomic, retain) SoundObjectEncoder *recorder;
@property (nonatomic, retain) SentViewController *sentViewController;
@property (nonatomic, retain) ReceivedViewController *receivedViewController;
@property (nonatomic, retain) TouchTracker* touchTracker;
@property (nonatomic, assign) NSMutableSet* currentTouches; 
@property (nonatomic, retain) id editModeTCs;
@property (nonatomic, retain) id scratchModeTCs;
@property (nonatomic, assign) bool scratchMode;

@property (nonatomic, retain) SoundObjectNodeToDraw *nodeToDrawObject;



@end
