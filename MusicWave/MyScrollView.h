//
//  MyScrollView.h
//  iPodSongs
//
//  Created by hun nam on 11. 5. 27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookMarkLayerDelegate.h"
#import "Song.h"

@class GraphViewSegment;
@class BookMark;

@interface MyScrollView : UIScrollView {
    CGContextRef context;
    CGPoint touchPoint;
    UIViewController * parent;
    CGFloat currentPixel;
    Song *currentSong;
    
    
    CALayer *bookMarkLayer;
    BookMarkLayerDelegate *bookMarkLayerDelegate;
    UIImageView *graphImageView;
    //UIImageView *soundLineView;
    //UIImageView *startBarView;
    //UIImageView *endBarView;
    //NSMutableArray *viewInfoArray;
}
@property(nonatomic, assign) GraphViewSegment *current;
@property (nonatomic, assign) UIViewController * parent;
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, retain) UIImageView *graphImageView;
//@property (nonatomic, retain) NSMutableArray *viewInfoArray;
@property CGFloat currentPixel;
@property (nonatomic, retain) CALayer *bookMarkLayer;
- (void)drawViewInfoArray;
- (void)setCurrentPlaybackPosition: (int)pixel;
- (void)setUpBookMarkLayer;
- (void)settingStartEndTime: (CGFloat)start endPosition:(CGFloat)end;
- (void)setDelta: (CGFloat)current_delta;


@end
