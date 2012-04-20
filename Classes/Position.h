//
//  Position.h
//  Vertices
//
//  Created by Sisi Sun on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface Position : NSObject <CLLocationManagerDelegate> {
	
	CLLocationManager *locationManager;
	float magneticHeading;
	int count;
	float headingPosition;
	
}

-(void)initialize;

@property float magneticHeading;
@property BOOL compassAvailable;

@end
