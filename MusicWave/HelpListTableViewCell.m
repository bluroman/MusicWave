//
//  HelpListTableViewCell.m
//  MusicWave
//
//  Created by Nam Hoon on 11. 8. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpListTableViewCell.h"
#import "Tutorial.h"

#pragma mark -
#pragma mark SubviewFrames category

@interface HelpListTableViewCell (SubviewFrames)
- (CGRect)_tutorialLabelFrame;
- (CGRect)_tutorialImageViewFrame;
@end
@implementation HelpListTableViewCell
@synthesize tutorialLabel, tutorialImageView, tutorial;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        tutorialLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tutorialLabel.textAlignment = UITextAlignmentLeft;
        [tutorialLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [tutorialLabel setTextColor:[UIColor blackColor]];
        [tutorialLabel setHighlightedTextColor:[UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0]];
        [tutorialLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:tutorialLabel];
        
        tutorialImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		tutorialImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:tutorialImageView];
    }
    return self;
}
#pragma mark -
#pragma mark Laying out subviews

/*
 To save space, the prep time label disappears during editing.
 */
- (void)layoutSubviews {
    [super layoutSubviews];
	
    //[tutorialLabel setFrame:[self _tutorialLabelFrame]];
    [tutorialImageView setFrame:[self _tutorialImageViewFrame]];
}
#define IMAGE_SIZE          56.0
#define TEXT_LEFT_MARGIN    5.0


- (CGRect)_tutorialLabelFrame {
    return CGRectMake(0.0, 280.0, self.contentView.bounds.size.width, 42.0);
}
- (CGRect)_tutorialImageViewFrame {
    return CGRectMake(20.0, 0.0, 280.0 , 326.0);
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    //NSLog(@"Selected:%d", selected);

    // Configure the view for the selected state
    /*if (selected == YES)
        helpImageView.hidden = NO;   
    else if (selected == NO)
        helpImageView.hidden = YES;*/
}
- (void)setTutorial:(Tutorial *)newTutorial {
    
    if (tutorial != newTutorial) {
        [tutorial release];
        tutorial = [newTutorial retain];
        
        //NSLog(@"Description:%@, ImageName:%@", tutorial.description, tutorial.imageName);
        
        tutorialLabel.text = tutorial.description;
        tutorialImageView.image = [UIImage imageNamed:tutorial.imageName];
    }
}


- (void)dealloc
{
    [tutorialLabel release];
    [tutorialImageView release];
    [tutorial release];
    [super dealloc];
}

@end
