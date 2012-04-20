//
//  SetupViewController.h
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ReceivedViewController.h"
#import "SentViewController.h"
#import "CoreLocationController.h"
#import "Position.h"
#define kAccelerometerFrequency 8

@interface SetupViewController : UIViewController  <GKSessionDelegate, UITableViewDelegate, UITableViewDataSource, UIAccelerometerDelegate, CoreLocationControllerDelegate>{ 
	
	// Session Object
	GKSession *verticesSession;
	// Array of peers available / connected
	NSMutableArray *peerAvailable;
	NSMutableArray *peerConnected;
	NSMutableArray *positionList;
	NSMutableArray *tableArray;
	NSString * mySelfPeerID;
	NSMutableArray* connectionRequestsIn;
	NSMutableArray* acceptancesOut;
	NSMutableArray* connectionRequestsOut;
	UITableView *peerTable;
	ReceivedViewController* receivedViewController;
	SentViewController* sentViewController;
	NSError *err;
	Position *peerPosition;
	UIImageView *tossImageView;
	
	//ACCEL
	CGPoint deviceTilt0;
	CGPoint deviceTilt1;
	double z0;
	double z1;
	int accWaitTime;
	
	//LOCATION
	CoreLocationController *CLController;
	
}


- (void)postInit;
- (void)sendData:(NSData*)data toPeers:(int)peers;
//@property (retain) id *showList;
// 4.  Methods to connect and send data
- (void) showList;
- (void) sendData2:(NSArray *)peer;
- (void) connect:(NSString *)peerID;
- (void) imhere:(NSData *)data;
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state;
- (void)denyConnectionFromPeer:(NSString *)peerID;
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID;
- (void)session:(GKSession *)session didFailWithError:(NSError *)error;
//- (void) dataSendingMode;
- (void)removePicture;


@property (retain) GKSession *verticesSession;
@property (nonatomic, retain) ReceivedViewController* receivedViewController;
@property (nonatomic, retain) SentViewController* sentViewController;
@property (nonatomic, retain) NSString* mySelfPeerID;
@property (nonatomic, retain) CoreLocationController *CLController;
@property (retain) NSMutableArray* connectionRequestsIn;
@property (retain) NSMutableArray* acceptancesOut;
@property (retain) NSMutableArray* connectionRequestsOut;
@end
