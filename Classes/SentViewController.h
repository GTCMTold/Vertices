//
//  SentViewController.h
//  Vertices
//
//  Created by James O'Neill on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundObjectEncoder.h"
//#import "SetupViewController.h"

@interface SentViewController : UIViewController {

	@public
	NSMutableArray *sentSoundObjects;
	UIViewController *setupViewController;
	NSData *data;
	
}

-(id)init;
-(void)postInit;

@property (nonatomic, retain) NSMutableArray *sentSoundObjects;
@property (nonatomic, retain) UIViewController *setupViewController;

@end
