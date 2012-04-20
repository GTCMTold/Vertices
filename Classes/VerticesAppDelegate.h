//
//  VerticesAppDelegate.h
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdInterface.h"
#import "VoiceTracker.h"
#import "SentViewController.h"

@class PdInterface; 

@interface VerticesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	@public
	UITabBarController *tabBarController;
	PdInterface *pd;
	SentViewController *svc;
}

- (void)initUI;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) PdInterface *pd;
@property (nonatomic, retain) SentViewController *svc;

@end

