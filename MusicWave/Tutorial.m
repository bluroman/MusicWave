//
//  Tutorial.m
//  MusicWave
//
//  Created by Nam Hoon on 11. 8. 19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tutorial.h"


@implementation Tutorial

@synthesize imageName, description;

- (void)dealloc {
    [imageName release];
    [description release];
    [super dealloc];
}

@end
