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
        keepDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [keepDateLabel setBackgroundColor:[UIColor clearColor]];
        [keepDateLabel setFont:[UIFont systemFontOfSize:14.0]];
        [keepDateLabel setTextColor:[UIColor colorWithRed:102.0/255.0f green:101.0/255.0f blue:95.0/255.0f alpha:1.0]];
        [keepDateLabel setHighlightedTextColor:[UIColor colorWithRed:189.0/255.0f green:188.0/255.0f blue:179.0/255.0f alpha:1.0]];
        [self.contentView addSubview:keepDateLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [timeLabel setTextColor:[UIColor colorWithRed:131.0/255.0f green:130.0/255.0f blue:124.0/255.0f alpha:1.0]];
        [timeLabel setHighlightedTextColor:[UIColor colorWithRed:255.0/255.0f green:253.0/255.0f blue:242.0/255.0f alpha:1.0]];
        [self.contentView addSubview:timeLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    //NSLog(@"book Mark cell selected:%d", selected);
    if(selected)
    {
        UIImageView *soundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-volume.png"]];
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


#define EDITING_INSET       7.0
#define TIME_UPPER_MARGIN   4.0
#define TEXT_LEFT_MARGIN    10.0
#define TIME_LABEL_HEIGHT  28.0
#define SUBTITLE_LABEL_HEIGHT   20.0


- (CGRect)_timeLabelFrame
{
    return CGRectMake(TEXT_LEFT_MARGIN, TIME_UPPER_MARGIN, self.contentView.bounds.size.width - TEXT_LEFT_MARGIN, TIME_LABEL_HEIGHT);
}

- (CGRect)_keepDateLabelFrame
{
    return CGRectMake(TEXT_LEFT_MARGIN, TIME_UPPER_MARGIN + TIME_LABEL_HEIGHT, self.contentView.bounds.size.width - TEXT_LEFT_MARGIN, SUBTITLE_LABEL_HEIGHT);
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
        //NSLog(@"Duration:%lu", duration);
        UInt32 minutes = duration / (60 * 100);
        UInt32 seconds = (duration / 100)  - (minutes * 60);
        UInt32 millsec = duration % 100;
        timeLabel.text = [NSString stringWithFormat: @"%02ld:%02ld:%02ld - %@", minutes, seconds, millsec, song.songTitle];
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
