//
//  VerticesAppDelegate.m
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VerticesAppDelegate.h"

#import "EditViewController.h"
#import "SetupViewController.h"
#import "ReceivedViewController.h"
#import "scratchModeTouchCallbacks.h"
#import "editModeTouchCallbacks.h"

@implementation VerticesAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize pd;
@synthesize svc;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain
										 code:1718449215
											   userInfo:nil];
	NSLog(@"Error: %@", [error description]);
    // Override point for customization after application launch.
    pd = [[PdInterface alloc] init];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled: YES];
	[self initUI];
	[window addSubview:[tabBarController view]];
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)initUI {
	
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *localViewControllers = [[NSMutableArray alloc] initWithCapacity:4];
	
	
	SetupViewController *stvc;
	//stvc = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
	stvc = [[SetupViewController alloc] init];
	stvc.tabBarItem.title = @"Setup";
	//vc.tabBarItem.image = [UIImage imageNamed:@"myimage"];  //set image
	[localViewControllers addObject:stvc];
	[stvc release];
	
	EditViewController *evc;
	//evc = [[EditViewController alloc] init];
	evc = [[EditViewController alloc] initWithPd:pd];
	evc.tabBarItem.title = @"Edit";
	//vc.tabBarItem.image = [UIImage imageNamed:@"myimage"];  //set image
	[localViewControllers addObject:evc];
	[evc release];
	
	ReceivedViewController *rvc;
	rvc = [[ReceivedViewController alloc] init];
	//rvc = [[ReceivedViewController alloc] initWithPd:pd];
	rvc.tabBarItem.title = @"Received";
	//vc.tabBarItem.image = [UIImage imageNamed:@"myimage"];  //set image
	[localViewControllers addObject:rvc];
	[rvc release];
	
	
	svc = [[SentViewController alloc] init];
//	svc.tabBarItem.title = @"Sent";
	//vc.tabBarItem.image = [UIImage imageNamed:@"myimage"];  //set image
//	[localViewControllers addObject:svc];
//	[svc release];
	
	tabBarController.viewControllers = localViewControllers;
	[localViewControllers release];
	
	scratchModeTouchCallbacks *smtc = [[scratchModeTouchCallbacks alloc] initWithOwner:[[tabBarController viewControllers] objectAtIndex:1]];
	editModeTouchCallbacks *emtc = [[editModeTouchCallbacks alloc] initWithOwner:[[tabBarController viewControllers] objectAtIndex:1]]; 
	
	[[[tabBarController viewControllers] objectAtIndex:1] setEditModeTCs:emtc];
	[[[tabBarController viewControllers] objectAtIndex:1] setScratchModeTCs:smtc];
	
	for (int i = 0; i < [[tabBarController viewControllers] count]; i+=1) {
		
		[[[tabBarController viewControllers] objectAtIndex:i] postInit];
	}
	[svc postInit];
	//[[[tabBarController viewControllers] objectAtIndex:3] setSentViewController:[[tabBarController viewControllers] objectAtIndex:2] ]; 
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	exit(0);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	exit(0);
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[tabBarController release];
    [window release];
	[pd release];
    [super dealloc];
}


@end
