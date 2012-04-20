//
//  Position.m
//  Vertices
//
//  Created by Sisi Sun on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Position.h"


@implementation Position
@synthesize magneticHeading;
@synthesize compassAvailable;


//get the pointing direction (when selecting a peer to calibrate / shake gesture happened)  
-(void)initialize{
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.headingFilter = 5;
	count = 0;
	if( locationManager.locationServicesEnabled && locationManager.headingAvailable) 	
	{
		[locationManager startUpdatingHeading];
		compassAvailable=TRUE;
		NSLog(@"compassaAvailable %@", compassAvailable?@"YES":@"NO");		
	} 
	else 
	{
		NSLog(@"Can't report heading");
		compassAvailable=FALSE;
		NSLog(@"compassaAvailable %@", compassAvailable?@"YES":@"NO");		

	}	
	
	//NSLog(@"heading %f",[locationManager heading]);
	
}

//return a float number of direction



- (void)locationManager:(CLLocationManager*)manager
	   didUpdateHeading:(CLHeading*)newHeading
{
	if (newHeading.headingAccuracy > 0)
	{
		magneticHeading = newHeading.magneticHeading;
		//NSLog(@"magneticHeading %f",magneticHeading);
		//NSLog(@"trueHeading %f",trueHeading);
	}
}


@end
