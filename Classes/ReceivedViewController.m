    //
//  ReceivedViewController.m
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReceivedViewController.h"
#import	"ReceivedView.h"
#import <mach/mach.h>
#import <mach/mach_time.h>


@implementation ReceivedViewController

@synthesize receivedSoundObjectDecoders;
@synthesize playingSoundObjectDecoders;
@synthesize editViewController;
@synthesize receivedButtonRows;

- (id)init {
    self = [super init];
    if (self) {
		numRows = 6;
		numCols = 4;
		maxObjects = numCols*numRows;
		receivedCount = 0;
		
		[self setReceivedSoundObjectDecoders: [[NSMutableArray alloc] initWithCapacity:maxObjects]];
		for(int i = 0; i<maxObjects; i+=1) {
			[receivedSoundObjectDecoders insertObject:[NSNumber numberWithBool:NO] atIndex:i];
		}
		[self setPlayingSoundObjectDecoders:[[NSMutableArray alloc] init]];
		[self setReceivedButtonRows:[[NSMutableArray alloc] init]];
		
		//voiceTracker = [[VoiceTracker alloc] init];
		
    }
    return self;
}

- (void)postInit {
	
	[self setEditViewController:EDITVIEWCONTROLLER];
	
}	

- (void)addSoundObjectForData:(NSData*)data fromPeer:(NSUInteger)peerIndex{
	
	//SET VOICE
	int rcModMax = receivedCount % maxObjects;
	SoundObjectDecoder *sod = [[SoundObjectDecoder alloc] initWithData:data andDelegate:editViewController];
	//if the thing it is replacing is also a SOD, do this
	if (receivedCount > maxObjects) {
		SoundObjectDecoder *oldSod = [receivedSoundObjectDecoders objectAtIndex:rcModMax];
		if ([[oldSod isPlaying] boolValue]) {
		[playingSoundObjectDecoders removeObjectIdenticalTo:oldSod];
		}
	}
	[receivedSoundObjectDecoders replaceObjectAtIndex:rcModMax withObject:sod];
	//[[receivedSoundObjectDecoders objectAtIndex:rcModMax] setStartTime:[NSNumber numberWithDouble:[ReceivedViewController timestamp]]];
	[sod setStartTime:[NSNumber numberWithDouble:[ReceivedViewController timestamp]]];
	//isPlaying set to YES in initializer, since it will always start playing when it arrives.
	//[[receivedSoundObjectDecoders objectAtIndex:rcModMax] setIsPlaying:[NSNumber numberWithBool:YES]];y
	
	sod->voice = [[VoiceTracker getVoiceTracker] getAvailableVoice:playingSoundObjectDecoders];
	[playingSoundObjectDecoders addObject:sod];			
	
	int rcRow = rcModMax / numCols; //these are ints, will truncate
	int rcCol = rcModMax % numCols;
	
	//set info about the sound object, color of person it came from
	UIButton* but = [[receivedButtonRows objectAtIndex:rcRow] objectAtIndex:rcCol];
	if(sod->isLooped != NO)
		[but setBackgroundColor:[UIColor orangeColor]];
	else 
		[but setBackgroundColor:[UIColor blueColor]];
	
	switch(peerIndex)
	{
		case 0:
		[but setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		break;
		case 1:
		[but setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
		break;
		case 2:
		[but setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
		break;
		case 3:
		[but setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		break;
		case 4:
		[but setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
		break;
	}
	[but setTitleShadowColor:[UIColor blueColor] forState:UIControlStateNormal];
	[but setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
	[but setTitleShadowColor:[UIColor greenColor] forState:UIControlStateHighlighted];
	 
	receivedCount +=1;
	
	[sod release];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[ReceivedView alloc] init];
		
	int tag;
	for(int i = 0; i<numRows; i+=1) {
		NSMutableArray* receivedButtonCols = [[NSMutableArray alloc] init];
		for(int j = 0; j<numCols; j+=1) {
			UIButton *rButton = [UIButton buttonWithType:UIButtonTypeCustom];
			//[rButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//			[rButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
//			[rButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
//			[rButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
			[rButton addTarget:self action:@selector(receivedButtonTouchUpCB:) forControlEvents:UIControlEventTouchUpInside];
			[rButton addTarget:self action:@selector(startTouchTimer:) forControlEvents:UIControlEventTouchDown];
			tag = (i*numCols)+j;
			rButton.tag = tag; 
			[rButton setTitle:[NSString stringWithFormat:@"%d", tag] forState:UIControlStateNormal];
			rButton.frame = CGRectMake(60*(j+1)-15, 60*(i+1)-40, 50, 50);
			[self.view addSubview:rButton];
			
			[receivedButtonCols addObject:rButton];
		}
		[receivedButtonRows addObject:receivedButtonCols];
		[receivedButtonCols release];
	}	
		
	
}

- (void)startTouchTimer:(id)sender {
	
	touchTimer = [NSTimer scheduledTimerWithTimeInterval:1.4 target:self selector:@selector(touchHeld:) userInfo:nil repeats:NO];
	buttonPressed = TRUE;
	buttonPressedTag = [sender tag];
	
}

- (void)touchHeld:(NSTimer*)timer {
	
	if([touchTimer isValid]) [touchTimer invalidate];
	if (buttonPressed) {
		NSLog(@"button held");
		//Load SO for buttonPressedTag
		SoundObjectDecoder* sod = [receivedSoundObjectDecoders objectAtIndex:buttonPressedTag];
		if(![[sod isPlaying] boolValue]) {
		[editViewController startEditModeWithDecoder:sod];
		[APPDELEGATE tabBarController].selectedViewController = [[[APPDELEGATE tabBarController] viewControllers]objectAtIndex:1];
		}
	}	
	
}


- (void)receivedButtonTouchUpCB:(id)sender {
	
	buttonPressed = FALSE;
	//Right now, pressing the received view will toggle between playing and no
	
	UIButton *but = (UIButton *)sender;
	if(but.tag > receivedCount-1)
		return;
	
	NSLog([NSString stringWithFormat:@"%d", but.tag]);
	
	SoundObjectDecoder* sod = [receivedSoundObjectDecoders objectAtIndex:but.tag];
	if ([[sod isPlaying] boolValue] == TRUE) {
		sod->stopFromRecView = YES;
		[[VoiceTracker getVoiceTracker] makeVoiceAvailable:sod->voice];
		/*
		[sod setIsPlaying:[NSNumber numberWithBool:FALSE]];
		[playingSoundObjectDecoders removeObjectIdenticalTo:sod];
		[but setBackgroundColor:[UIColor clearColor]];
		[self performSelectorOnMainThread:@selector(sendPdZero:) withObject:[NSNumber numberWithInt:kVoiceOne] waitUntilDone:NO];
		 */
	}
	else {
		[sod setIsPlaying:[NSNumber numberWithBool:TRUE]];
		sod->nodeIndex = 0;
		sod->voice = [[VoiceTracker getVoiceTracker] getAvailableVoice:playingSoundObjectDecoders];
		[sod setStartTime:[NSNumber numberWithDouble:[ReceivedViewController timestamp] - 0.020]]; 
		//20 millisecond head start makes sure that the first node actually plays first
		[playingSoundObjectDecoders addObject:sod];
		
		if(sod->isLooped != NO)
			[but setBackgroundColor:[UIColor orangeColor]];
		else 
			[but setBackgroundColor:[UIColor blueColor]];
		
	}
	
}

- (void)sendPdZero:(id)voice {
	[[editViewController pd] numberOfTouches:0.0 toVoiceWithId:[voice intValue]];
}

- (void)removeButtonAttributes:(SoundObjectDecoder*)decoder {
	int i = [receivedSoundObjectDecoders indexOfObjectIdenticalTo:decoder];
	int r = i / numCols; //these are ints, will truncate
	int c = i % numCols;
	UIButton* b = [[receivedButtonRows objectAtIndex:r] objectAtIndex:c];
	[b setBackgroundColor:[UIColor clearColor]];

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


- (void)dealloc {
	//[voiceTracker release];
    [super dealloc];
}

+ (double)timestamp {
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
	 

@end
