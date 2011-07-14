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
        layer.frame = CGRectMake(0, 0, 2, 180);
        layer.contents = (id) [UIImage imageNamed:@"bar.jpg"].CGImage;
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
@synthesize current, parent, currentPixel, currentSong;
@synthesize bookMarkLayer;
@synthesize viewInfoArray;

#define myUpperMargin 0.0f


// Designated initializer

-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
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
        
        soundLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soundline.jpg"]];
        soundLineView.frame = CGRectMake(0, 89, self.bounds.size.width, 2);
        [self addSubview:soundLineView];
        //[soundLine release];
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
    
    [bookMarkLayer setNeedsDisplay];
    
    [current.layer setPosition:CGPointMake(0.0, 90.0)];
}
- (void)setUpBookMarkLayer {
    
    bookMarkLayer.frame = self.bounds;//CGRectMake(0.0, 0.0, 32.0, 112.0);
    
    bookMarkLayer.backgroundColor = [UIColor clearColor].CGColor;
    bookMarkLayer.opacity = 1.0f;
    bookMarkLayerDelegate.currentSong = self.currentSong;
    soundLineView.frame = CGRectMake(0, 89, self.bounds.size.width, 2);
    
        
}
- (void) setCurrentPlaybackPosition:(CGFloat)value {
    int i = 0;
    ViewInfo *tempViewInfo = nil;
    for (; i < [self.viewInfoArray count]; i++) {
        tempViewInfo = [self.viewInfoArray objectAtIndex:i];
        if(value < [tempViewInfo.time floatValue]  || value == [tempViewInfo.time floatValue])
            break;
    }
    self.currentPixel = [tempViewInfo.x floatValue];
    //NSLog(@"Now currentPixel:%f", self.currentPixel);
    [current.layer setPosition:CGPointMake(self.currentPixel, 90.0)];
}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint pointInView = [[touches anyObject] locationInView:self];
    NSLog(@"Start touches:pointInView x:%f, y:%f", pointInView.x, pointInView.y);
    
    
    if ([self.viewInfoArray count] < pointInView.x) {
        NSLog(@"something wrong with view info array");
        return;
    }
    self.currentPixel = pointInView.x;
    [current.layer setPosition:CGPointMake(self.currentPixel, 90.0)];
    //Get duration of the point and send it to viewcontroller
    iPodSongsViewController *controller = (iPodSongsViewController *)parent;
    ViewInfo *tempViewInfo = [self.viewInfoArray objectAtIndex:self.currentPixel];
    NSLog(@"touches current time:%f", [tempViewInfo.time floatValue]);
    [controller setCurrentPostion:[tempViewInfo.time floatValue]];
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    CGPoint pointInView = [[touches anyObject] locationInView:self];
    NSLog(@"Moved pointInView x:%f, y:%f", pointInView.x, pointInView.y);
   
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    CGPoint pointInView = [[touches anyObject] locationInView:self];
    NSLog(@"Ended pointInView x:%f, y:%f", pointInView.x, pointInView.y);
        
}

- (void)drawViewInfoArray {
    CGRect viewRect = self.bounds;
    int count = [self.viewInfoArray count];
    CGFloat graphHeight = viewRect.size.height - myUpperMargin;
    //CGFloat scaleFactor =  graphHeight / 2;
    double scaleFactor = floor( self.bounds.size.height  / 2.0 );
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
    CGContextSetRGBStrokeColor(context, 123.0/255.0f, 218.0/255.0f, 245.0/255.0f, 1.0);
    CGContextMoveToPoint(context, 0.0, graphHeight / 2);
    CGContextAddLineToPoint(context, viewRect.size.width, graphHeight / 2);
    CGContextStrokePath(context);//center line
    
    if (count < 1) {
        NSLog(@"something wrong with draw view info");
        return;
    }
    CGMutablePathRef maxPath = CGPathCreateMutable();
    CGContextTranslateCTM(context, 0.0, graphHeight / 2);
    CGPathMoveToPoint(maxPath, NULL, 0, 0);
    for (int i = 0; i < count; i++) {
        ViewInfo *tempViewInfo = [self.viewInfoArray objectAtIndex:i];
        CGPathAddLineToPoint(maxPath, NULL, [tempViewInfo.x floatValue], scaleFactor * [tempViewInfo.max floatValue]);
        

    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath( path, NULL, maxPath );
    
    
    CGAffineTransform xf = CGAffineTransformIdentity;
    xf = CGAffineTransformScale(xf, 1.0, -1.0);
  
    CGPathAddPath( path, &xf, maxPath );
    //CGPathAddPath(path, NULL, minPath);
    CGPathCloseSubpath(path);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:96.0/255.0f green:143.0/255.0f blue:199.0/255.0f alpha:1.0].CGColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    //CGContextAddPath(context, path);
    //CGContextSetRGBStrokeColor(context, 96, 143, 199, 1.0);
    //[[UIColor colorWithRed:96.0/255.0f green:143.0/255.0f blue:199.0/255.0f alpha:1.0] setStroke];
    //CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(maxPath);
    //CGPathRelease(minPath);
    CGPathRelease(path);
    
      NSLog(@"view width:%f, view height:%f, graph height:%f", viewRect.size.width, viewRect.size.height, graphHeight);
}


- (void)dealloc
{
    [current release];
    [viewInfoArray release];
    [bookMarkLayerDelegate release];
    [currentSong release];
    [soundLineView release];
    [super dealloc];
}

@end
