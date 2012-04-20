//
//  PdInterface.m
//  Vertices
//
//  Created by Scott on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PdInterface.h"

@interface PdInterface()

@property (nonatomic, retain) PdAudio *pdAudio;
@property (nonatomic, retain) PdFile *patch;
@property int ticksPerBuffer;

- (void) openAndRunTestPatch;

@end


@implementation PdInterface

@synthesize pdAudio;
@synthesize ticksPerBuffer;
@synthesize patch;
@synthesize previewTriggerOn;
//@synthesize testArray;


- (PdInterface *) init
{
	self = [super init];
	
	if (self != nil)
	{
#if TARGET_IPHONE_SIMULATOR
		self.ticksPerBuffer = 512 / [PdBase getBlockSize];
		
		self.pdAudio = [[PdAudio alloc] initWithSampleRate:44100
										 andTicksPerBuffer:ticksPerBuffer
								  andNumberOfInputChannels:2
								 andNumberOfOutputChannels:2];
#else
		self.ticksPerBuffer = 8;
		self.pdAudio = [[PdAudio alloc] initWithSampleRate:16000
										 andTicksPerBuffer:ticksPerBuffer
								  andNumberOfInputChannels:2
								 andNumberOfOutputChannels:2];
						//andAudioSessionCategory:kAudioSessionCategory_AmbientSound];
#endif
		
		[self openAndRunTestPatch]; 
	
	}
	
	return self;
}

- (void) openAndRunTestPatch
{
	// open patch located in app bundle
	self.patch = [PdFile openFileNamed:@"_main.pd" path:[[NSBundle mainBundle] bundlePath]];
	
	// tell pd to compute audio and play
	[PdBase computeAudio:YES];
	[self.pdAudio play];

}

- (void) triggerSound:(BOOL)state toVoiceWithId:(int)voiceId
{
	float f_state = -1.0;
	
	if (state == YES)
		f_state = 1.0;
	if (state == NO)
		f_state = 0.0;
	
	NSArray *messageToSend = [NSArray arrayWithObjects:
							  [NSNumber numberWithFloat:(float)voiceId],
							  [NSNumber numberWithFloat:(float)f_state], nil];
	
	[PdBase sendList:messageToSend toReceiver:@"trigger"];
}

- (void)loopEnable:(BOOL)state
{
	float f_state = -1.0;
	
	if (state == YES)
		f_state = 1.0;
	if (state == NO)
		f_state = 0.0;
	
	[PdBase sendFloat:f_state toReceiver:@"loop"];
}

- (void) numberOfTouches:(float)numTouches toVoiceWithId:(int)voiceId
{
	NSArray *messageToSend = [NSArray arrayWithObjects:
							  [NSNumber numberWithFloat:(float)voiceId],
							  [NSNumber numberWithFloat:(float)numTouches], nil];
	
	[PdBase sendList:messageToSend toReceiver:@"num-touches"];
	
}


- (void) sendXCentroid:(float)xCentroid toVoiceWithId:(int)voiceId
{
	NSArray *messageToSend = [NSArray arrayWithObjects:
								[NSNumber numberWithFloat:(float)voiceId],
								[NSNumber numberWithFloat:(float)xCentroid], nil];
	
	[PdBase sendList:messageToSend toReceiver:@"x-centroid"];
}

- (void) sendYCentroid:(float)yCentroid toVoiceWithId:(int)voiceId
{	
	NSArray *messageToSend = [NSArray arrayWithObjects:
							  [NSNumber numberWithFloat:(float)voiceId],
							  [NSNumber numberWithFloat:(float)yCentroid], nil];
	
	[PdBase sendList:messageToSend toReceiver:@"y-centroid"];
}

- (void) sendSharpness:(float)sharpness toVoiceWithId:(int)voiceId
{
	NSArray *messageToSend = [NSArray arrayWithObjects:
							  [NSNumber numberWithFloat:(float)voiceId],
							  [NSNumber numberWithFloat:(float)sharpness], nil];
	
	[PdBase sendList:messageToSend toReceiver:@"sharpness"];
}

- (void)selectPreset:(BOOL)soundPreset
{
	float f_state = -1.0;
	
	if (soundPreset == YES)
		f_state = 1.0;
	if (soundPreset == NO)
		f_state = 0.0;
	
	[PdBase sendFloat:f_state toReceiver:@"preset"];
		
}

- (void) dealloc
{
	[self.patch closeFile];
	
	self.pdAudio = nil;
	[super dealloc];
}


@end
