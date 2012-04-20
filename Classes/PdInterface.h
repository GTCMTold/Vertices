//
//  PdInterface.h
//  Vertices
//
//  Created by Scott on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdAudio.h"
#import "PdFile.h"

@interface PdInterface : NSObject {
	
	PdAudio *pdAudio;
	PdFile *patch;
	
	BOOL previewTriggerOn;	
}

- (PdInterface *) init;
- (void)loopEnable:(BOOL)state;

- (void)triggerSound:(BOOL)state toVoiceWithId:(int)voiceId;

// Number of touches
- (void)numberOfTouches:(float)numTouches toVoiceWithId:(int)voiceId;

// New sending methods
- (void)sendXCentroid:(float)xCentroid toVoiceWithId:(int)voiceId;
- (void)sendYCentroid:(float)yCentroid toVoiceWithId:(int)voiceId;

// Sharpness
- (void)sendSharpness:(float)sharpness toVoiceWithId:(int)voidId;

// Selects which synthesis mode the audio plays back in
- (void)selectPreset:(BOOL)soundPreset;

@property BOOL previewTriggerOn;

@end
