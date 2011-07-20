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
@synthesize startPosition, endPosition;

-(id)init
{
	self = [super init];
	if(self != nil)
    {
        currentSong = nil;
        startPosition = 0.f;
        endPosition = 0.f;
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
	// We aren't interested in the actual content of this layer, we just want to draw something.
	// Towards that end, we'll fill the content with a random color,
	// then fill a randomly generated polygon.
    
    CGRect bounds = CGContextGetClipBoundingBox(context);
    if (self.currentSong == nil) {
        return;
    }
    if (self.startPosition == self.endPosition) {
        //NSLog(@"always same........");
    }
    else if (self.startPosition > 0 && self.endPosition > 0) {
        if (self.endPosition > self.startPosition) {
            //layer.opacity = 0.2f;
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0f green:231.0/255.0f blue:0.0/255.0f alpha:0.2f].CGColor);
            CGContextAddRect(context, CGRectMake(self.startPosition, 0.0, self.endPosition - self.startPosition, bounds.size.height));
            CGContextFillPath(context);
        }
        else {
            //layer.opacity = 0.2f;
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0f green:231.0/255.0f blue:0.0/255.0f alpha:0.2f].CGColor);
            CGContextAddRect(context, CGRectMake(self.endPosition, 0.0, self.startPosition - self.endPosition, bounds.size.height));
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
        CGContextSetRGBStrokeColor(context, 255.0/255.0f, 249.0/255.0f, 190.0/255.0f, 1.0);
        CGContextMoveToPoint(context, [tempBookMark.position floatValue], 0.0);
        CGContextAddLineToPoint(context, [tempBookMark.position floatValue], bounds.size.height);
        CGContextStrokePath(context);
        CGContextSelectFont (context, "Helvetica", 11, kCGEncodingMacRoman);
        CGContextSetTextDrawingMode (context, kCGTextFillStroke);
        CGContextSetRGBFillColor (context, 255.0/255.0f, 255.0/255.0f, 255.0/255.0f, 1);
        CGContextSetRGBStrokeColor (context, 255.0/255.0f, 255.0/255.0f, 255.0/255.0f, 1);
        CGContextSetTextMatrix(context, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
        CGContextShowTextAtPoint (context, [tempBookMark.position floatValue], 11, numChar, strlen(numChar));
    }
    [sortDescriptor release];
	[sortDescriptors release];
	[sortedBookMarks release];

       
}

@end
