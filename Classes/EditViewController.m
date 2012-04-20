    //
//  EditViewController.m
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "EditView.h"
#import <mach/mach.h>
#import <mach/mach_time.h>

@implementation EditViewController

@synthesize pd;
@synthesize touchPhaseText;
@synthesize loopSwitch;
@synthesize recorder;
@synthesize recordButton;
@synthesize editModePlayButton;
@synthesize sentViewController;
@synthesize receivedViewController;
@synthesize touchTracker;
@synthesize currentTouches;
@synthesize editModeTCs;
@synthesize scratchModeTCs;
@synthesize scratchMode;
@synthesize nodeToDrawObject;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (EditViewController *)initWithPd:(PdInterface *)pdPointer
{
	
	self = [super init];
	if (self != nil)
	{
		pd = pdPointer;
		
		lastTime = -1;
		numberOfCurrentTouches = 0;
		
		record = FALSE;
		recorder = [[SoundObjectEncoder alloc] init];
		
		[self setTouchTracker:[[TouchTracker alloc] init]];
		[recorder setTouchTracker:[self touchTracker]];
	
		scratchMode = YES;
		
		[self setNodeToDrawObject:[[SoundObjectNodeToDraw alloc] init]];
	}
	
	return self;		
}


- (void)postInit {
	
	[self setSentViewController: SENTVIEWCONTROLLER];
	[self setReceivedViewController: RECEIVEDVIEWCONTROLLER];
	//sentViewController = SENTVIEWCONTROLLER;
	[NSThread detachNewThreadSelector:@selector(receivedObjectsPlaybackTimer) 
							 toTarget:self 
						   withObject:nil];
	
}

- (void)dealloc {
	
	//[nodeToDrawObject release];
    [super dealloc];
}

- (void)receivedObjectsPlaybackTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray* playingObjects = [receivedViewController playingSoundObjectDecoders];
	int i;
	double time;
	while (TRUE) {
		[NSThread sleepForTimeInterval:0.006];
		time = [EditViewController timestamp];
		for (i = 0; i<[playingObjects count]; i+=1) {
			//cue objects
			[[playingObjects objectAtIndex:i] cueForTimestamp:(time - [[[playingObjects objectAtIndex:i] startTime] doubleValue])]; 
		}
	}	
	[pool release];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	self.view = [[EditView alloc] init];
	//[self.view setNodeToDraw:&nodeToDraw];
	[self.view setNodeToDrawObject:[self nodeToDrawObject]];
	[self.view setTouchTracker:[self touchTracker]];
	
	//make loop radio button
	loopSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
	[loopSwitch setImage:[UIImage imageNamed:@"recordoff.png"] forState:UIControlStateNormal];
	[loopSwitch setImage:[UIImage imageNamed:@"loopon.png"] forState:UIControlStateSelected];
	[loopSwitch setFrame:CGRectMake(290, 370, 25, 25)];
	[loopSwitch addTarget:self action:@selector(loopSwitchCB:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:loopSwitch];
	[self.view bringSubviewToFront:loopSwitch];
	//[loopSwitch release];
	
	//make record radio button
	recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[recordButton setImage:[UIImage imageNamed:@"recordoff.png"] forState:UIControlStateNormal];
	[recordButton setImage:[UIImage imageNamed:@"recordon.png"] forState:UIControlStateSelected];
	[recordButton setFrame:CGRectMake(5, 370, 25, 25)];
	[recordButton addTarget:self action:@selector(recordButtonCB:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:recordButton];
	[self.view bringSubviewToFront:recordButton];
	//[recordButton release];
	
	editModePlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[editModePlayButton setImage:[UIImage imageNamed:@"recordoff.png"] forState:UIControlStateNormal];
	[editModePlayButton setImage:[UIImage imageNamed:@"recordon.png"] forState:UIControlStateHighlighted];
	[editModePlayButton setFrame:CGRectMake(35, 370, 25, 25)];
	[editModePlayButton addTarget:self action:@selector(editModePlayButtonCB:) forControlEvents:UIControlEventTouchUpInside];
	editModePlayButton.hidden = YES;
	[self.view addSubview:editModePlayButton];
	[self.view bringSubviewToFront:editModePlayButton];
	//subview will be added and removed according to edit mode
	 
	
	clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[clearButton setImage:[UIImage imageNamed:@"recordoff.png"] forState:UIControlStateNormal];
	[clearButton setImage:[UIImage imageNamed:@"recordon.png"] forState:UIControlStateHighlighted];
	[clearButton setFrame:CGRectMake(260, 370, 25, 25)];
	[clearButton addTarget:self action:@selector(clearButtonCB:) forControlEvents:UIControlEventTouchUpInside];
	clearButton.hidden = YES;
	[self.view addSubview:clearButton];
	[self.view bringSubviewToFront:clearButton];
	//subview will be added and removed according to edit mode
	
}

-(void)startEditModeWithDecoder:(SoundObjectDecoder *)sod {
	
	editModePlayButton.hidden = NO;
	clearButton.hidden = NO;
	scratchMode = FALSE;	
	[editModeTCs startEditModeWithDecoder:sod];
}
	 
-(void)endEditMode {
	editModePlayButton.hidden = YES;
	clearButton.hidden = YES;
	scratchMode = YES;
	[editModeTCs endEditMode];
}
	 
- (void)loopSwitchCB:(UIButton *)button{	
	//[pd loopEnable:[loopSwitch isOn]];
	if (!button.selected) {
		button.selected = TRUE;
	}
	else if (button.selected) {
		button.selected = FALSE;
	}	
}

- (void)clearButtonCB:(UIButton *)button{	
	
	if(!scratchMode) {	
		[self endEditMode];
	}
}

- (void)editModePlayButtonCB:(UIButton *)button{	
	
	if(!scratchMode) {	
		[editModeTCs playEditable];
	}
}


- (void)recordButtonCB:(UIButton *)button{
	
	if (!button.selected) {
		button.selected = TRUE;
		record = TRUE;
		[recorder recordStartIsEditMode:(!scratchMode)];
		if( numberOfCurrentTouches > 0)
		[recorder addTouches:currentTouches withAction:kTouchesBegan atTime:[EditViewController timestamp]];
	}
	else if (button.selected) {
		button.selected = FALSE;
		record = FALSE;
		recorder->isLooped = [loopSwitch isSelected];
		[recorder recordEnd];
		[[sentViewController sentSoundObjects] addObject:recorder];
	}	
}

- (BOOL)isRecording {
	return record;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (self.scratchMode)
		[[self scratchModeTCs] touchesBegan:touches withEvent:event];
	else
		[[self editModeTCs] touchesBegan:touches withEvent:event];
	
	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
	if (self.scratchMode)
		[[self scratchModeTCs] touchesMoved:touches withEvent:event];
	else
		[[self editModeTCs] touchesMoved:touches withEvent:event];
	

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	if (self.scratchMode)
		[[self scratchModeTCs] touchesEnded:touches withEvent:event];
	else
		[[self editModeTCs] touchesEnded:touches withEvent:event];
	
	//sdfdsf
}
		 
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.scratchMode)
		[[self scratchModeTCs] touchesCancelled:touches withEvent:event];
	else
		[[self editModeTCs] touchesCancelled:touches withEvent:event];
	// Enumerate through all the touch objects.
	/*for (UITouch *touch in touches)
	{
		//found a touch.  Is it already on our list?
		int fingerID = [touchTracker GetFingerTrackIDByTouch:touch];
		if (fingerID != -1)
		{
			touchTracker->g_touchTracker[fingerID].m_touchPointer = NULL;
		} else
		{
			//wasn't on our list
			continue;
		}
	}*/
}
		 

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

+ (double)timestamp
{
    // get the timebase info -- different on phone and OSX
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
	
    // get the time
    uint64_t absTime = mach_absolute_time();
	
    // apply the timebase info
    absTime *= info.numer;
    absTime /= info.denom;
	
    // convert nanoseconds into seconds and return
    return ((double) absTime / 1000000000.0);
}

#pragma mark -
#pragma mark SoundObjectDecoderDelegate

//- (void)processNode:(SoundObjectNode *)node {
- (void)processNode:(SoundObjectNode *)node withVoice:(int)voiceNumber{	
	int numTouches= [[node runningXCoords] count];
			
	float xSum = 0;
	float ySum = 0;
			
	// Compute centroid of each coordinate
	for (int i = 0; i < numTouches; i+=1)
	{
		xSum += [[[node runningXCoords] objectAtIndex:i] floatValue];
		ySum += [[[node runningYCoords] objectAtIndex:i] floatValue];
	}
			
	
	[pd numberOfTouches:(float)numTouches toVoiceWithId:voiceNumber];
	
	if(numTouches > 0) {
		[pd sendXCentroid:(xSum / numTouches) toVoiceWithId:voiceNumber];
		[pd sendYCentroid:(ySum / numTouches) toVoiceWithId:voiceNumber];
	}
	
}

- (void)stopPlaying:(SoundObjectDecoder *)decoder {
	
	if(decoder->isLooped == YES) {
		decoder->nodeIndex = 0; 
		[decoder setStartTime:[NSNumber numberWithDouble:[EditViewController timestamp]]];
	}
	else {
		[[receivedViewController playingSoundObjectDecoders] removeObjectIdenticalTo:decoder];
		[decoder setIsPlaying:[NSNumber numberWithBool:FALSE]];
		[self performSelectorOnMainThread:@selector(updateButtonWhenStopped:) withObject:decoder waitUntilDone:NO];
		[pd numberOfTouches:0.0 toVoiceWithId:decoder->voice];
		[[VoiceTracker getVoiceTracker] makeVoiceAvailable:decoder->voice];
		decoder->voice = -1;
	}		
}

- (void)stopPlayingFromRecView:(SoundObjectDecoder *)decoder {
	[[receivedViewController playingSoundObjectDecoders] removeObjectIdenticalTo:decoder];
	[decoder setIsPlaying:[NSNumber numberWithBool:FALSE]];
	[self performSelectorOnMainThread:@selector(updateButtonWhenStopped:) withObject:decoder waitUntilDone:NO];
	[pd numberOfTouches:0.0 toVoiceWithId:decoder->voice];
	decoder->voice = -1;
	
}

- (void)editModeStopPlaying:(SoundObjectDecoder *)decoder {
	
		[decoder setIsPlaying:[NSNumber numberWithBool:FALSE]];
		[pd numberOfTouches:0.0 toVoiceWithId:decoder->voice];
}

- (void)editModeUpdateNodeToDraw:(SoundObjectNode *)son {
	[editModeTCs editModeUpdateNodeToDraw:son];	
}
- (void)updateButtonWhenStopped:(id)dec {
	[receivedViewController removeButtonAttributes:(SoundObjectDecoder*)dec];
}

- (void)mergeNode:(SoundObjectNode *)son {
	[editModeTCs mergeNode:son];
}


@end
