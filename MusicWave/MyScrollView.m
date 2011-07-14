//
//  MyScrollView.m
//  iPodSongs
//
//  Created by hun nam on 11. 5. 27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyScrollView.h"


@implementation MyScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    //CGPoint pointInView = [[touches allObjects] locationInView:volumeView];
    //NSLog(@"Start touches:pointInView x:%f, y:%f", pointInView.x, pointInView.y);
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint touchPoint = [touch locationInView:touch.view];
    NSLog(@"[%s] touched point :: %f, %f", __FUNCTION__, touchPoint.x, touchPoint.y);
    //[self setScrollEnabled:NO];
    [[self.subviews objectAtIndex:0] touchesBegan:touches withEvent:event];
    
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint touchPoint = [touch locationInView:touch.view];
    NSLog(@"[%s] touched point :: %f, %f", __FUNCTION__, touchPoint.x, touchPoint.y);
    [[self.subviews objectAtIndex:0] touchesMoved:touches withEvent:event];

}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint touchPoint = [touch locationInView:touch.view];
    NSLog(@"[%s] touched point :: %f, %f", __FUNCTION__, touchPoint.x, touchPoint.y);
    //[self setScrollEnabled:YES];
    [[self.subviews objectAtIndex:0] touchesEnded:touches withEvent:event];

}


- (void)dealloc
{
    [super dealloc];
}

@end
