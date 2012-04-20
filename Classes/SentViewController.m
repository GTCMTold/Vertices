    //
//  SentViewController.m
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SentViewController.h"
#import "SentView.h"

@implementation SentViewController
@synthesize sentSoundObjects;
@synthesize setupViewController;

- (id)init {
    self = [super init];
    if (self) {
        sentSoundObjects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)postInit {
	
	//setupViewController = SETUPVIEWCONTROLLER;
	[self setSetupViewController: SETUPVIEWCONTROLLER];
	
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	self.view = [[SentView alloc] init];
	CGRect labelFrame = CGRectMake( 10, 40, 200, 30 );
	UILabel* label = [[UILabel alloc] initWithFrame: labelFrame];
	[label setText: @"This is the sent view"];
	[label setTextColor: [UIColor blackColor]];
	[self.view addSubview: label];	
	[self.view bringSubviewToFront:label];
	
	UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[sendButton addTarget:self action:@selector(sendButtonCB) forControlEvents:UIControlEventTouchUpInside];
	[sendButton setTitle:@"Connect" forState:UIControlStateNormal];
	sendButton.frame = CGRectMake(20, 100, 280, 30);
	//btnConnect.tag = 12;
	[self.view addSubview:sendButton];
	
}

- (void)sendButtonCB {
	
	data = [[sentSoundObjects lastObject] dataToSend];
	//[[setupViewController verticesSession] sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
	[setupViewController sendData:data toPeers:kAllPeers];
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
    [super dealloc];
}


@end
