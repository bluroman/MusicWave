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
    CGFloat startTime;
    CGFloat endTime;
    CGFloat currentDelta;
}
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, assign) CGFloat currentDelta;

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;

@end
