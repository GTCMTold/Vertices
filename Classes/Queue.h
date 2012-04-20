//
//  Queue.h
//  Vertices
//
//  Created by Scott on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Queue : NSObject 
{
	NSMutableArray *objects;
}

- (void)addObject:(id)object;
- (void)removeObjectAtIndex:(int)object;
- (id)pop;
- (BOOL)isEmpty;

@end
