//
//  BookMarkLayerDelegate.h
//  iPodSongs
//
//  Created by hun nam on 11. 5. 27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Song.h"

@class BookMark;

@interface BookMarkLayerDelegate : NSObject {
    Song *currentSong;
}
@property (nonatomic, assign) Song *currentSong;

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;

@end
