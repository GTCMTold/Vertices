//
//  SetupViewController.m
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SetupViewController.h"
#import "SetupView.h"

@implementation SetupViewController

@synthesize verticesSession;
@synthesize receivedViewController;
@synthesize sentViewController;
@synthesize mySelfPeerID;
@synthesize CLController;
@synthesize connectionRequestsIn;
@synthesize acceptancesOut;
@synthesize connectionRequestsOut;


- (id)init {
    self = [super init];
    if (self) {
		connectionRequestsIn = [[NSMutableArray alloc] init];
		connectionRequestsOut = [[NSMutableArray alloc] init];
		acceptancesOut = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)postInit {
	
	[self setReceivedViewController: RECEIVEDVIEWCONTROLLER];
	[self setSentViewController: SENTVIEWCONTROLLER];
	err = [[NSError alloc] init];

[NSThread detachNewThreadSelector:@selector(btTimer) 
						 toTarget:self 
					   withObject:nil];

}

- (void)btTimer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL check;
	while (TRUE) {
		[NSThread sleepForTimeInterval:2];
		
		[peerAvailable setArray:[verticesSession peersWithConnectionState:GKPeerStateAvailable]];
		[peerConnected setArray:[verticesSession peersWithConnectionState:GKPeerStateConnected]];
		//tableArray = [[NSMutableArray alloc] initWithObjects:peerConnected,peerAvailable,nil];
		[self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];

	
		//[self.view setNeedsDisplay];
		//for(int i = 0; i<[[self.view subviews] count]; i+=1) {
//			[[[self.view subviews] objectAtIndex:i] setNeedsDisplay];
//			//[self.view bringSubviewToFront:[[self.view subviews] objectAtIndex:i] ];
//			
//		}	
			
		//peerTable = [[UITableView alloc] 
//					 initWithFrame:[[UIScreen mainScreen] applicationFrame]
//					 style:UITableViewStyleGrouped];
//		peerTable.delegate = self;
//		peerTable.dataSource = self;
//		[self.view addSubview:peerTable];
		
		//update contingent lists
		
		if([connectionRequestsIn count] > 0) {
			check = [verticesSession acceptConnectionFromPeer:[connectionRequestsIn objectAtIndex:0] error:&err];
			if(!check) {
				NSLog(@"connectionRequestError %@", [err code]);
			}
			else {
				[acceptancesOut addObject:[connectionRequestsIn objectAtIndex:0]];
				[connectionRequestsIn removeObjectAtIndex:0];
			}
		}
		else if([connectionRequestsOut count] > 0) {
			[verticesSession connectToPeer:[connectionRequestsOut objectAtIndex:0] withTimeout:0];
			[connectionRequestsOut removeObjectAtIndex:0];
		}	
	}
	[pool release];
}

- (void) refreshTableView
{
	[peerTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// This creates a peer mode session named "verticesSession", session ID is "Vertices", display name is the iphone name


	[self setVerticesSession:[[GKSession alloc] initWithSessionID:@"Vertices" 
													  displayName:nil 
													  sessionMode:GKSessionModePeer]];
	 [[self verticesSession]setDelegate:self]; 
	 [[self verticesSession]setAvailable:YES]; 
	 [[self verticesSession] setDisconnectTimeout:0]; 
	 [[self verticesSession] setDataReceiveHandler:self withContext:nil];
	
	 [self setMySelfPeerID:[verticesSession displayNameForPeer:verticesSession.peerID]];
	
	//Create a list to store peers list
	peerAvailable=[[NSMutableArray alloc] init];
	peerConnected=[[NSMutableArray alloc] init];
	positionList=[[NSMutableArray alloc] init];
	
	for (int i = 0; i < MAX_PEERS; i+=1)
	{
		[positionList addObject:[NSNumber numberWithFloat:-1.0]];
	}
	
	[peerAvailable setArray:[verticesSession peersWithConnectionState:GKPeerStateAvailable]];
	[peerConnected setArray:[verticesSession peersWithConnectionState:GKPeerStateConnected]];
	
	//NSLog(@"%@", [verticesSession displayNameForPeer:[peerAvailable objectAtIndex:0]]);
//	NSLog(@"connected%@", peerConnected);
//	NSLog(@"available%@", peerAvailable);
	
	tableArray = [[NSMutableArray alloc] initWithObjects:peerConnected,peerAvailable,nil];
	//NSLog(@"tableArray initial %@", tableArray);
	
	//draw the list in NStable
	peerTable = [[UITableView alloc] 
				 initWithFrame:[[UIScreen mainScreen] applicationFrame]
				 style:UITableViewStyleGrouped];
	peerTable.delegate = self;
	peerTable.dataSource = self;
	[self.view addSubview:peerTable];
	
	
	//Instruction Alert View	
	UIAlertView *instructions1 = [[UIAlertView alloc] initWithTitle:@"How To - Step 1"  message:@"In SETUP view, choose available peers to connect with. To calibrate, click the name of each connected peer with your phone pointed at that phone." delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil];
	instructions1.tag=1;
	[instructions1 show];
	[instructions1 release];
	
	//Toss View
	tossImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"toss.png"]];
	[tossImageView setAlpha:0];
	//[self.view addSubview:tossImageView];
	[[APPDELEGATE window] addSubview:tossImageView];
	
	UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnRefresh addTarget:self action:@selector(refreshButtonCB) forControlEvents:UIControlEventTouchUpInside];
	btnRefresh.frame = CGRectMake(20, 300, 280, 30);
	//[btnRefresh setImage:[UIImage imageNamed:@"refresh.jpg"] forState:UIControlStateNormal];
	[btnRefresh setTitle:@"refresh" forState:UIControlStateNormal];
	[self.view addSubview:btnRefresh];	
	
	//Create the buttons "connect"
//	UIButton *btnConnect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//	[btnConnect addTarget:self action:@selector(showList) forControlEvents:UIControlEventTouchUpInside];
//	[btnConnect setTitle:@"Search" forState:UIControlStateNormal];
//	btnConnect.frame = CGRectMake(20, 100, 280, 30);
//	//btnConnect.tag = 12;
//	[self.view addSubview:btnConnect];
	
	//ACCELEROMETER
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
	accWaitTime = 0;
	
	//LOCATION
	CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];
	
	
	//Compass initialization
	peerPosition=[[Position alloc] init];
	[peerPosition initialize];
	}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if(buttonIndex==0){
		if(actionSheet.tag==1)
		{
			[APPDELEGATE tabBarController].selectedViewController = [[[APPDELEGATE tabBarController] viewControllers]objectAtIndex:1];
			NSLog(@"tag=1");
			UIAlertView *instructions2 = [[UIAlertView alloc] initWithTitle:@"How To - Step 2"  message:@"In EDIT view, draw vertices with fingers. Press the bottom left button to start/stop recording and bottom right button to switch loop mode on/off." delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil];
			[instructions2 show];
			instructions2.tag=2;
			[instructions2 release];
		}
		if (actionSheet.tag==2) {
			[APPDELEGATE tabBarController].selectedViewController = [[[APPDELEGATE tabBarController] viewControllers]objectAtIndex:2];
			NSLog(@"tag=2");
			UIAlertView *instructions3 = [[UIAlertView alloc] initWithTitle:@"How To - Step 3"  message:@"In RECEIVED view, select which sound objects to playback or edit. Press one of the numbers to play audio back. Hold one of the numbers to edit object." delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil];
			//UIAlertView *instructions3 = [[UIAlertView alloc] initWithTitle:@"Finish"  message:@"Start your VERTICES!" delegate:self cancelButtonTitle:@"GO!" otherButtonTitles:nil];
			instructions3.tag=3;
			[instructions3 show];
			[instructions3 release];

		}
		if (actionSheet.tag==3){
			[APPDELEGATE tabBarController].selectedViewController = [[[APPDELEGATE tabBarController] viewControllers]objectAtIndex:0];
			UIAlertView *instructions4 = [[UIAlertView alloc] initWithTitle:@"Finish"  message:@"Start your VERTICES!" delegate:self cancelButtonTitle:@"GO!" otherButtonTitles:nil];
			[instructions4 show];
			[instructions4 release];
		}
	}
}



// UIAccelerometerDelegate method, called when the device accelerates.
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    // Update the accelerometer graph view
	//deviceTilt0.x = deviceTilt1.x;
	//deviceTilt0.y = deviceTilt1.y;
	z0 = z1;
	
	//deviceTilt1.x = acceleration.x;
	//deviceTilt1.y = acceleration.y;
	z1 = acceleration.z;
	
	//NSLog([NSString stringWithFormat:@"%f", acceleration.z]);
	if(accWaitTime > 0)
		accWaitTime -= 1;
	
	//else if(deviceTilt1.y - deviceTilt0.y > 0.9) {
		else if( z1 - z0 < -1.5 ) {

		//this is where a toss is detected
		//NSLog([NSString stringWithFormat:@"%f", deviceTilt1.y - deviceTilt0.y]);
		//NSLog([NSString stringWithFormat:@"%f", z1 - z0]);

		accWaitTime = 0;	

		//Diretion it points to
		//NSLog(@"direction %f", [peerPosition magneticHeading]);
		
			
			
		//send data
		if ([[sentViewController sentSoundObjects] count] > 0) {
		NSData* data = [[[sentViewController sentSoundObjects] lastObject] dataToSend];
		//[self sendData:data toPeers:kAllPeers];
			//NSLog([peerPosition compassAvailable]);

			//NSLog(@"compassaAvailable %@", [peerPosition compassAvailable]?@"YES":@"NO");		
			
			if ([peerPosition compassAvailable]==TRUE){
			//Compare the heading with all the peer position
			 //NSLog(@"magneticHeading %f",[peerPosition magneticHeading]);
			 NSEnumerator *e1 = [positionList objectEnumerator];
			 NSNumber * object1;
			 while (object1 = [e1 nextObject]) {
				 if ([object1 floatValue]!=-1){
					 if ((fabs([peerPosition magneticHeading]-[object1 floatValue])<30)||(fabs([peerPosition magneticHeading]+360-[object1 floatValue])<30)||(fabs([peerPosition magneticHeading]-360-[object1 floatValue])<30)) {
						 //NSLog(@"magneticHeading coming %f",[peerPosition magneticHeading]);
						 int index=[positionList indexOfObject:object1];
						 NSArray *peerToReceive = [NSArray arrayWithObject:[peerConnected objectAtIndex:index]];
						 //[verticesSession sendData:data toPeers:[peerConnected objectAtIndex:index]];
						 [verticesSession sendData:data toPeers:peerToReceive withDataMode:GKSendDataReliable error:nil];
						 //NSLog(@"senddata to %@", [peerConnected objectAtIndex:index]);
					 }
				 }
			 }
			}
			else{
			  [self sendData:data toPeers:kAllPeers];
			} 
			
		//make animation
		[tossImageView setAlpha:1];
		[UIView beginAnimations:nil context:NULL]; // animate the following:
		[UIView setAnimationDuration:1.0];
		[tossImageView setAlpha:0];
		[UIView commitAnimations];
		}
		
	}	
}

//LOCATION STUFF
- (void)locationUpdate:(CLLocation *)location {
	//NSLog([NSString stringWithFormat:@"%f", [location course]]);
	
}

- (void)locationError:(NSError *)error {
	
}


- (void)showList
{//get the list of available peersID
	[peerAvailable setArray:[verticesSession peersWithConnectionState:GKPeerStateAvailable]];
	[peerConnected setArray:[verticesSession peersWithConnectionState:GKPeerStateConnected]];

	NSLog(@"%@", [verticesSession displayNameForPeer:[peerAvailable objectAtIndex:0]]);
	NSLog(@"connected%@", peerConnected);
	NSLog(@"available%@", peerAvailable);
	
	tableArray = [[NSMutableArray alloc] initWithObjects:peerConnected,peerAvailable,nil];
	//NSLog(@"tableArray initial %@", tableArray);

	//draw the list in NStable
	peerTable = [[UITableView alloc] 
							  initWithFrame:[[UIScreen mainScreen] applicationFrame]
							  style:UITableViewStyleGrouped];
	peerTable.delegate = self;
	peerTable.dataSource = self;
	[self.view addSubview:peerTable];
	
	
	 UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	 [btnRefresh addTarget:self action:@selector(refreshButtonCB) forControlEvents:UIControlEventTouchUpInside];
	 btnRefresh.frame = CGRectMake(20, 300, 280, 30);
	 //[btnRefresh setImage:[UIImage imageNamed:@"refresh.jpg"] forState:UIControlStateNormal];
	 [btnRefresh setTitle:@"refresh" forState:UIControlStateNormal];
	 [self.view addSubview:btnRefresh];	
}

-(void)refreshButtonCB {
	
	tableArray = [[NSMutableArray alloc] initWithObjects:peerConnected,peerAvailable,nil];
	peerTable = [[UITableView alloc] 
				 initWithFrame:[[UIScreen mainScreen] applicationFrame]
				 style:UITableViewStyleGrouped];
	peerTable.delegate = self;
	peerTable.dataSource = self;
	[self.view addSubview:peerTable];
	
	UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnRefresh addTarget:self action:@selector(refreshButtonCB) forControlEvents:UIControlEventTouchUpInside];
	btnRefresh.frame = CGRectMake(20, 300, 280, 30);
	//[btnRefresh setImage:[UIImage imageNamed:@"refresh.jpg"] forState:UIControlStateNormal];
	[btnRefresh setTitle:@"refresh" forState:UIControlStateNormal];
	[self.view addSubview:btnRefresh];	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger sections = [tableArray count];
	//NSLog(@"tableArray in section %@", tableArray);
	//NSLog(@"number of sections%d", sections);
	return sections;
}


- (NSInteger)tableView:(UITableView *)peerTable numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"tableArray%@",tableArray);
	NSArray *sectionContents = [tableArray objectAtIndex:section];
	NSInteger rows = [sectionContents count];
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)peerTable 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [peerTable dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	// Set up the cell...
	NSArray *sectionContents = [tableArray objectAtIndex:[indexPath section]];
	NSString *contentForThisRow = [sectionContents objectAtIndex:[indexPath row]];	
	//cell.font=[UIFont fontWithName:@"Arial" size:16.0];
	//cell.imageView.image = [UIImage imageNamed:@"peer2.jpg"];
	cell.textLabel.text = [verticesSession displayNameForPeer:contentForThisRow];
	return cell;
	
}

- (NSString *)tableView:(UITableView *)peerTable
titleForHeaderInSection:(NSInteger)section{
	switch (section){
		case 0:
			return @"Connected Peers";
			break;
		case 1:
			return @"Available Peers";
			break;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSLog(@"%d was pressed", indexPath.row);
	if ([indexPath section] == 0) {
		//NSLog(@"section %d", [indexPath section]);
		//if([positionList objectAtIndex:[indexPath row]]==-1.0){
			//[positionList replaceObject:[NSNumber numberWithFloat:[peerPosition magneticHeading]] atIndex:indexPath.row];
		[positionList replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:[peerPosition magneticHeading]]];
		NSLog(@"positinList %@",positionList);
		//}
		//else{
		//	[positionList replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:[peerPosition magneticHeading]]];
		//}
	}
	else if ([indexPath section] == 1) {
		//NSLog(@"section %d", [indexPath section]);
		
		[connectionRequestsOut addObject:[peerAvailable objectAtIndex:indexPath.row]];
		//[self connect:[peerAvailable objectAtIndex:indexPath.row]];
	}	
}

//check constants in .pch for 'peers' argument
- (void)sendData:(NSData*)data toPeers:(int)peers {
	
	if(peers == kAllPeers) {
		[verticesSession sendDataToAllPeers:data
							   withDataMode:GKSendDataReliable 
									  error:nil]; 
		}	
}

- (void)dealloc {
	[peerAvailable release];
	[peerConnected release];
	[tableArray release];
    [super dealloc];
}


#pragma mark -
#pragma mark GKSessionDelegate

//send request to connect
- (void)connect:(NSString *)peerID
{
	[verticesSession connectToPeer:peerID withTimeout:0];
	NSLog(@"connection requested to %@",peerID);
}


//print peerID, When receiving connection request from peers. Then automatically receive! JUTS FOR NOW!!!
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID{
	NSLog(@":%s", peerID);
	
//[NSError errorWithDomain:GKSessionErrorDomain code:<#(NSInteger)code#> userInfo:<#(NSDictionary *)dict#> 
	[connectionRequestsIn addObject:[[NSString alloc] initWithString:peerID]];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	
	
	
}

//When peers change states
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
	
	if(state == GKPeerStateConnected){
		// Add the peer to the Array
		[peerConnected addObject:peerID];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected"  message:peerID delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	if(state == GKPeerStateAvailable){
		// Add the peer to the Array
		NSLog([verticesSession displayNameForPeer:peerID]);
		NSLog(@"available");
		
	}
	
	if(state == GKPeerStateUnavailable){
		// Add the peer to the Array
		NSLog([verticesSession displayNameForPeer:peerID]);
	}
	
	if(state == GKPeerStateDisconnected){
		//[peerConnected removeObject:peerID];	
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected"  message:peerID delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
}

- (void)denyConnectionFromPeer:(NSString *)peerID {
	
	
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	
	NSUInteger peerIndex = [peerConnected indexOfObject: peer];
	[receivedViewController addSoundObjectForData:data fromPeer:peerIndex]; 
	
	//Convert received NSData to NSString to display
   //	NSString *whatDidIget = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//	
//	//Display as a UIAlertView
//	UIAlertView *r = [[UIAlertView alloc] initWithTitle:@"Received" message:whatDidIget delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	 [r show];
//	 [r release];
//	[whatDidIget release];
	
	//Display what others are drawing??
	
}

@end
