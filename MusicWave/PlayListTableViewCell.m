//
//  PlayListTableViewCell.m
//  iPodSongs
//
//  Created by hun nam on 11. 6. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayListTableViewCell.h"


#pragma mark -
#pragma mark SubviewFrames category

@interface PlayListTableViewCell (SubviewFrames)
- (CGRect)_titleLabelFrame;
- (CGRect)_artistLabelFrame;
- (CGRect)_playOrHasGraphViewFrame;
@end


#pragma mark -
#pragma mark PlayListTableViewCell implementation

@implementation PlayListTableViewCell

@synthesize song, titleLabel, artistLabel, playOrHasGraphView;


#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        artistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        artistLabel.textAlignment = UITextAlignmentLeft;
        [artistLabel setFont:[UIFont systemFontOfSize:14.0]];
        [artistLabel setTextColor:[UIColor colorWithRed:102.0/255.0f green:101.0/255.0f blue:95.0/255.0f alpha:1.0]];
        [artistLabel setHighlightedTextColor:[UIColor colorWithRed:189.0/255.0f green:188.0/255.0f blue:179.0/255.0f alpha:1.0]];
        [artistLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:artistLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = UITextAlignmentLeft;
        [titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [titleLabel setTextColor:[UIColor colorWithRed:131.0/255.0f green:130.0/255.0f blue:124.0/255.0f alpha:1.0]];
        [titleLabel setHighlightedTextColor:[UIColor colorWithRed:255.0/255.0f green:253.0/255.0f blue:242.0/255.0f alpha:1.0]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:titleLabel];
        
        playOrHasGraphView = [[UIImageView alloc] initWithFrame:CGRectZero];
		playOrHasGraphView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:playOrHasGraphView];
    }
    
    return self;
}


#pragma mark -
#pragma mark Laying out subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    //CGFloat title_width = self.contentView.bounds.size.width - self.accessoryView.bounds.size.width;
    //NSLog(@"title width:%f, content width:%f, accessory width:%f", title_width, self.contentView.bounds.size.width, self.accessoryView.bounds.size.width);
	
    [titleLabel setFrame:[self _titleLabelFrame]];
    [artistLabel setFrame:[self _artistLabelFrame]];
    [playOrHasGraphView setFrame:[self _playOrHasGraphViewFrame]];
    
}

#define TEXT_LEFT_MARGIN    10.0
#define TITLE_UPPER_MARGIN  4.0
#define TITLE_LABEL_HEIGHT  28.0
#define SUBTITLE_LABEL_HEIGHT   20.0
#define PLAYORHAS_GRAPH_IMAGE_WIDTH 23.0
#define PLAYORHAS_GRAPH_IMAGE_HEIGHT    23.0
#define PLAYORHAS_GRAPH_IMAGE_MARGIN    2.0

- (CGRect)_titleLabelFrame
{
    return CGRectMake(TEXT_LEFT_MARGIN, TITLE_UPPER_MARGIN, self.contentView.bounds.size.width - TEXT_LEFT_MARGIN, TITLE_LABEL_HEIGHT);
}

- (CGRect)_artistLabelFrame
{
    return CGRectMake(TEXT_LEFT_MARGIN, TITLE_UPPER_MARGIN + TITLE_LABEL_HEIGHT, self.contentView.bounds.size.width - TEXT_LEFT_MARGIN, SUBTITLE_LABEL_HEIGHT);
}

- (CGRect)_playOrHasGraphViewFrame
{
    return CGRectMake(self.contentView.bounds.size.width - PLAYORHAS_GRAPH_IMAGE_WIDTH - PLAYORHAS_GRAPH_IMAGE_MARGIN, (self.contentView.bounds.size.height - PLAYORHAS_GRAPH_IMAGE_HEIGHT) / 2, PLAYORHAS_GRAPH_IMAGE_WIDTH, PLAYORHAS_GRAPH_IMAGE_HEIGHT);
}

#pragma mark -
#pragma mark Song set accessor

- (void)setSong:(Song *)newSong {
    if (newSong != song) {
        [song release];
        song = [newSong retain];
	}
    titleLabel.text = song.songTitle;
    artistLabel.text = [NSString stringWithFormat: @"%@ - %@", song.songAlbum, song.songArtist];
    if([song.doneGraphDrawing boolValue])
        playOrHasGraphView.image = [UIImage imageNamed:@"graph_t2_on.png"];
    else
        playOrHasGraphView.image = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [song release];
    [titleLabel release];
    [artistLabel release];
    [playOrHasGraphView release];
    [super dealloc];
}

@end
