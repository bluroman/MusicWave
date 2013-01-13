//
//  BookMarkLayerDelegate.m
//  iPodSongs
//
//  Created by hun nam on 11. 5. 27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookMarkLayerDelegate.h"
#import "BookMark.h"
#import "iPodSongsViewController.h"


@implementation BookMarkLayerDelegate
@synthesize currentSong;
@synthesize startTime, endTime, currentDelta;

-(id)init
{
	self = [super init];
	if(self != nil)
    {
        currentSong = nil;
        startTime = 0.f;
        endTime = 0.f;
        currentDelta = NAN;
    }
    return self;
}
-(void)dealloc
{
    [currentSong release];
	[super dealloc];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    CGRect bounds = CGContextGetClipBoundingBox(context);
    if (self.currentSong == nil) {
        return;
    }
    if (self.startTime == self.endTime) {
        //NSLog(@"always same........");
    }
    else if (self.startTime > 0 && self.endTime > 0) {
        if (self.endTime > self.startTime) {
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:0.5f].CGColor);
            CGContextAddRect(context, CGRectMake(self.startTime / self.currentDelta, 0.0, self.endTime / self.currentDelta - self.startTime / self.currentDelta, bounds.size.height));
            CGContextFillPath(context);
        }
        else {
            //layer.opacity = 0.2f;
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:0.5f].CGColor);
            CGContextAddRect(context, CGRectMake(self.endTime / self.currentDelta, 0.0, self.startTime / self.currentDelta - self.endTime / self.currentDelta, bounds.size.height));
            CGContextFillPath(context);
        }
    }
    else {
        //NSLog(@"other case happens in draw rectangle pos1:%f, pos2:%f", [self.currentSong.pos1 floatValue], [self.currentSong.pos2 floatValue]);
    }
    
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    layer.opacity = 1.0f;
    
    //NSMutableArray *sortedBookMark = [[NSMutableArray alloc] initWithArray:[self.currentSong.bookmarks allObjects]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keepDate" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortedBookMarks = [[NSMutableArray alloc] initWithArray:[currentSong.bookmarks allObjects]];
	[sortedBookMarks sortUsingDescriptors:sortDescriptors];
    
	
    int bookMarkCount = [sortedBookMarks count];
    for (int i = 0; i < bookMarkCount; i++) {
        
        BookMark *tempBookMark = [sortedBookMarks objectAtIndex:i];
        char numChar[20] ;
        snprintf(numChar,sizeof(numChar),"%d",i + 1) ;
        CGContextSetRGBStrokeColor(context, 255.0/255.0f, 255.0/255.0f, 255.0/255.0f, 1.0);
        CGContextMoveToPoint(context, [tempBookMark.duration floatValue]/self.currentDelta, 0.0);
        CGContextAddLineToPoint(context, [tempBookMark.duration floatValue]/self.currentDelta, bounds.size.height);
        CGContextStrokePath(context);
        CGContextSelectFont (context, "Helvetica", 8, kCGEncodingMacRoman);
        CGContextSetTextDrawingMode (context, kCGTextFillStroke);
        CGContextSetRGBFillColor (context, 255.0/255.0f, 255.0/255.0f, 255.0/255.0f, 1);
        CGContextSetRGBStrokeColor (context, 255.0/255.0f, 255.0/255.0f, 255.0/255.0f, 1);
        CGContextSetTextMatrix(context, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
        CGContextShowTextAtPoint (context, [tempBookMark.duration floatValue]/self.currentDelta, 8, numChar, strlen(numChar));
    }
    [sortDescriptor release];
	[sortDescriptors release];
	[sortedBookMarks release];

       
}

@end
