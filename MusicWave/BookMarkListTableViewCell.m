//
//  BookMarkListTableViewCell.m
//  iPodSongs
//
//  Created by hun nam on 11. 6. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookMarkListTableViewCell.h"
#pragma mark -
#pragma mark SubviewFrames category

@interface BookMarkListTableViewCell (SubviewFrames)
- (CGRect)_timeLabelFrame;
- (CGRect)_keepDateLabelFrame;
@end



@implementation BookMarkListTableViewCell
@synthesize song, timeLabel, keepDateLabel, bookMark;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"list_bg_off.jpg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];  
        self.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"list_bg_on.jpg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
        
        keepDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [keepDateLabel setBackgroundColor:[UIColor clearColor]];
        [keepDateLabel setFont:[UIFont systemFontOfSize:12.0]];
        [keepDateLabel setTextColor:[UIColor colorWithRed:135.0/255.0f green:139.0/255.0f blue:149.0/255.0f alpha:1.0]];
        [keepDateLabel setHighlightedTextColor:[UIColor colorWithRed:142.0/255.0f green:142.0/255.0f blue:134.0/255.0f alpha:1.0]];
        [self.contentView addSubview:keepDateLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
        [timeLabel setTextColor:[UIColor whiteColor]];
        [timeLabel setHighlightedTextColor:[UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0]];
        [self.contentView addSubview:timeLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    NSLog(@"book Mark cell selected:%d", selected);
    if(selected)
    {
        UIImageView *soundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"]];
        soundImageView.frame = CGRectMake(273, 21, 20, 16);
        self.accessoryView = soundImageView;
        [soundImageView release];

    }
    else
        self.accessoryView = nil;
}
#pragma mark -
#pragma mark Laying out subviews

/*
 To save space, the prep time label disappears during editing.
 */
- (void)layoutSubviews {
    [super layoutSubviews];
	
    [timeLabel setFrame:[self _timeLabelFrame]];
    [keepDateLabel setFrame:[self _keepDateLabelFrame]];
}


#define IMAGE_SIZE          0.0
#define EDITING_INSET       10.0
#define TEXT_LEFT_MARGIN    21.0
#define TEXT_RIGHT_MARGIN   5.0
#define PREP_TIME_WIDTH     0.0

/*
 Return the frame of the various subviews -- these are dependent on the editing state of the cell.
 */
- (CGRect)_imageViewFrame {
    if (self.editing) {
        return CGRectMake(EDITING_INSET, 0.0, IMAGE_SIZE, IMAGE_SIZE);
    }
	else {
        return CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE);
    }
}

- (CGRect)_timeLabelFrame {
    if (self.editing) {
        return CGRectMake(IMAGE_SIZE + EDITING_INSET + TEXT_LEFT_MARGIN, 15.0, self.contentView.bounds.size.width - IMAGE_SIZE - EDITING_INSET - TEXT_LEFT_MARGIN, 16.0);
    }
	else {
        return CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 15.0, self.contentView.bounds.size.width - IMAGE_SIZE - TEXT_RIGHT_MARGIN * 2 - PREP_TIME_WIDTH, 16.0);
    }
}

- (CGRect)_keepDateLabelFrame {
    if (self.editing) {
        return CGRectMake(IMAGE_SIZE + EDITING_INSET + TEXT_LEFT_MARGIN, 33.0, self.contentView.bounds.size.width - IMAGE_SIZE - EDITING_INSET - TEXT_LEFT_MARGIN, 16.0);
    }
	else {
        return CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 33.0, self.contentView.bounds.size.width - IMAGE_SIZE - TEXT_LEFT_MARGIN, 16.0);
    }
}

- (CGRect)_durationLabelFrame {
    CGRect contentViewBounds = self.contentView.bounds;
    return CGRectMake(contentViewBounds.size.width - PREP_TIME_WIDTH - TEXT_RIGHT_MARGIN, 4.0, PREP_TIME_WIDTH, 16.0);
}


#pragma mark -
#pragma mark BookMark set accessor

- (void)setBookMark:(BookMark *)newBookMark {
    if (newBookMark != bookMark) {
        [bookMark release];
        bookMark = [newBookMark retain];
	}
    if (bookMark) {
        UInt32 duration = [bookMark.duration floatValue] * 100;
        NSLog(@"Duration:%lu", duration);
        UInt32 minutes = duration / (60 * 100);
        UInt32 seconds = (duration / 100)  - (minutes * 60);
        UInt32 millsec = duration % 100;
        timeLabel.text = [NSString stringWithFormat: @"%02d:%02d:%02d - %@", minutes, seconds, millsec, song.songTitle];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        keepDateLabel.text = [formatter stringForObjectValue:bookMark.keepDate];
        [formatter release];
    }
}


- (void)dealloc
{
    [song release];
    [bookMark release];
    [timeLabel release];
    [keepDateLabel release];
    [super dealloc];
}

@end
