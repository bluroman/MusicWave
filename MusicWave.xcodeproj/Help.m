//
//  Help.m
//  MusicWave
//
//  Created by Nam Hoon on 11. 8. 19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Help.h"


@implementation Help
@synthesize title, tutorials;

- (void)dealloc {
    [title release];
    [tutorials release];
    [super dealloc];
}


@end
