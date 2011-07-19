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
    CGFloat startPosition;
    CGFloat endPosition;
}
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, assign) CGFloat startPosition;
@property (nonatomic, assign) CGFloat endPosition;

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;

@end
