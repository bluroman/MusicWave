//
//  MyGraphView.m
//  iPodSongs
//
//  Created by hun nam on 11. 5. 11..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MyGraphView.h"
#import "ViewInfo.h"
#import "iPodSongsViewController.h"
#import "BookMark.h"

@interface GraphViewSegment : NSObject
{
	CALayer *layer;
}
@property(nonatomic, readonly) CALayer *layer;

@end
@implementation GraphViewSegment

@synthesize layer;

-(id)initWithFrame:(CGRect)frame
{
	self = [super init];
	if(self != nil)
	{
        layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, 1, frame.size.height);
        layer.backgroundColor = [UIColor whiteColor].CGColor;
        //layer.contents = (id) [UIImage imageNamed:@"bar.jpg"].CGImage;
        layer.masksToBounds = YES;
	}
	return self;
}

-(void)dealloc
{
	[layer release];
	[super dealloc];
}

@end

#define MAX_BOOKMARK 10

@implementation MyGraphView
@synthesize current, parent, currentPixel, currentSong, graphImageView;
@synthesize bookMarkLayer;
//@synthesize viewInfoArray;

#define myUpperMargin 0.0f


// Designated initializer
-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self != nil)
	{
        context = nil;
        current = [[GraphViewSegment alloc] initWithFrame:self.bounds];
        [self.layer addSublayer:current.layer];
        bookMarkLayerDelegate = [[BookMarkLayerDelegate alloc] init];
        bookMarkLayer = [CALayer layer];
        bookMarkLayer.delegate = bookMarkLayerDelegate;
        [self setUpBookMarkLayer];
        [self.layer addSublayer:bookMarkLayer];
        graphImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:graphImageView];
	}
	return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.*/

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (context == nil) context = UIGraphicsGetCurrentContext();
    
    [self drawViewInfoArray];
    
    //endBarView.frame = CGRectMake(self.bounds.size.width - 2, 86, 2, 9);
    
    [bookMarkLayer setNeedsDisplay];
    
    [current.layer setPosition:CGPointMake(0.0 + current.layer.bounds.size.width / 2, current.layer.bounds.size.height / 2)];
}
- (void)setUpBookMarkLayer {
    
    bookMarkLayer.frame = self.bounds;//CGRectMake(0.0, 0.0, 32.0, 112.0);
    
    bookMarkLayer.backgroundColor = [UIColor clearColor].CGColor;
    bookMarkLayer.opacity = 1.0f;
    bookMarkLayerDelegate.currentSong = self.currentSong;
    //soundLineView.frame = CGRectMake(0, 89, self.bounds.size.width, 2);
    
        
}
- (void)setDelta: (CGFloat)current_delta {
    NSLog(@"Settng BookMark layer delta:%f", current_delta);
    bookMarkLayerDelegate.currentDelta = current_delta;
}

- (void)settingStartEndTime:(CGFloat)start endPosition:(CGFloat)end
{
    bookMarkLayerDelegate.startTime = start;
    bookMarkLayerDelegate.endTime = end;
}
- (void) setCurrentPlaybackPosition:(int)pixel {
    self.currentPixel = pixel;
    //NSLog(@"Now currentPixel:%f", self.currentPixel);
    [current.layer setPosition:CGPointMake(self.currentPixel, current.layer.bounds.size.height / 2)];
}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint pointInView = [[touches anyObject] locationInView:self];
    //NSLog(@"Start touches:pointInView x:%f, y:%f", pointInView.x, pointInView.y);
    
    
    if (self.bounds.size.width < pointInView.x) {
        NSLog(@"something wrong with view info array");
        return;
    }
    self.currentPixel = pointInView.x;
    [current.layer setPosition:CGPointMake(self.currentPixel, self.current.layer.bounds.size.height/2)];
    //Get duration of the point and send it to viewcontroller
    iPodSongsViewController *controller = (iPodSongsViewController *)parent;
    //ViewInfo *tempViewInfo = [self.viewInfoArray objectAtIndex:self.currentPixel];
    //NSLog(@"touches current time:%f", [tempViewInfo.time floatValue]);
    [controller setCurrentPostion:self.currentPixel * controller.delta];
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    //CGPoint pointInView = [[touches anyObject] locationInView:self];
    //NSLog(@"Moved pointInView x:%f, y:%f", pointInView.x, pointInView.y);
   
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    //CGPoint pointInView = [[touches anyObject] locationInView:self];
    //NSLog(@"Ended pointInView x:%f, y:%f", pointInView.x, pointInView.y);
        
}

- (void)drawViewInfoArray {
    CGRect viewRect = self.bounds;
    int len = 0;
    
    //CGContextSetRGBStrokeColor(context, 59, 65, 83, 1.0);
    //CGContextMoveToPoint(context, 0.0, 1.0);
    //CGContextAddLineToPoint(context, viewRect.size.width, 1.0);
    //CGContextStrokePath(context);//upper stretching bar
    
    while( len < viewRect.size.width){
        CGContextSetRGBStrokeColor(context, 54.0/255.0f, 57.0/255.0f, 65.0/255.0f, 1.0);
        CGContextMoveToPoint(context, len, 0.0);
        CGContextAddLineToPoint(context, len, 4.0);
        CGContextStrokePath(context);//upper stretching bar
        
        if ((len % 25) == 0) {
            CGContextSetRGBStrokeColor(context, 75.0/255.0f, 77.0/255.0f, 86.0/255.0f, 1.0);
            CGContextMoveToPoint(context, len, 0.0);
            CGContextAddLineToPoint(context, len, 8.0);
            CGContextStrokePath(context);//upper stretching bar
        }
        len += 5;
    }
    //NSLog(@"view width:%f, view height:%f, graph height:%f", viewRect.size.width, viewRect.size.height, graphHeight);
}


- (void)dealloc
{
    [current release];
    [bookMarkLayerDelegate release];
    [currentSong release];
    [graphImageView release];
    [super dealloc];
}

@end
