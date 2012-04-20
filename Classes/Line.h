//
//  Line.h
//  Vertices
//
//  Created by Scott on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Line : NSObject
{
	CGPoint begin;
	CGPoint endPoint;
}
@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint endPoint;

@end
