//
//  ReceivedViewController.h
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundObjectDecoder.h"
#import "VoiceTracker.h"

@interface ReceivedViewController : UIViewController {
	

	@public
	NSMutableArray* receivedSoundObjectDecoders;
	NSMutableArray* playingSoundObjectDecoders;
	NSMutableArray* receivedButtonRows;
	int numRows;
	int numCols;
	int maxObjects;
	int receivedCount;
	UIViewController* editViewController;
	NSTimer* touchTimer;
	bool buttonPressed;
	int buttonPressedTag;
	//VoiceTracker* voiceTracker;

}

- (id)init;
- (void)addSoundObjectForData:(NSData*)data fromPeer:(NSUInteger)peerIndex;
- (void)postInit;
- (void)receivedButtonCB:(id)sender;
- (void)removeButtonAttributes:(SoundObjectDecoder*)decoder;
+ (double)timestamp;

@property (retain) NSMutableArray *receivedSoundObjectDecoders;
@property (retain) NSMutableArray* playingSoundObjectDecoders;
@property (nonatomic, retain) NSMutableArray* receivedButtonRows;
@property (nonatomic, retain) UIViewController* editViewController;

@end
