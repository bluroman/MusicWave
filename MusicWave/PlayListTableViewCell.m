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
- (CGRect)_imageViewFrame;
- (CGRect)_titleLabelFrame;
- (CGRect)_artistLabelFrame;
- (CGRect)_durationLabelFrame;
@end


#pragma mark -
#pragma mark PlayListTableViewCell implementation

@implementation PlayListTableViewCell

@synthesize song, imageView, titleLabel, artistLabel, durationLabel, nowPlaying;


#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"list_bg_off.jpg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];  
        self.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"list_bg_on.jpg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imageView];
        
        artistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        artistLabel.textAlignment = UITextAlignmentLeft;
        [artistLabel setFont:[UIFont systemFontOfSize:12.0]];
        [artistLabel setTextColor:[UIColor colorWithRed:135.0/255.0f green:139.0/255.0f blue:149.0/255.0f alpha:1.0]];
        [artistLabel setHighlightedTextColor:[UIColor colorWithRed:142.0/255.0f green:142.0/255.0f blue:134.0/255.0f alpha:1.0]];
        [artistLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:artistLabel];
        
        durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        durationLabel.textAlignment = UITextAlignmentLeft;
        //[durationLabel setFont:[UIFont fontWithName:@"Tahoma Bold" size:(11.0)]];
        [durationLabel setFont:[UIFont systemFontOfSize:11.0]];
        [durationLabel setTextColor:[UIColor colorWithRed:82.0/255.0f green:89.0/255.0f blue:107.0/255.0f alpha:1.0]];
        [durationLabel setHighlightedTextColor:[UIColor whiteColor]];
        [durationLabel setBackgroundColor:[UIColor clearColor]];
		//durationLabel.minimumFontSize = 7.0;
		//durationLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:durationLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = UITextAlignmentLeft;
        [titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setHighlightedTextColor:[UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:titleLabel];
        
        self.nowPlaying = NO;
        
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
	
    [imageView setFrame:[self _imageViewFrame]];
    [titleLabel setFrame:[self _titleLabelFrame]];
    [artistLabel setFrame:[self _artistLabelFrame]];
    //if (!self.nowPlaying) {
        [durationLabel setFrame:[self _durationLabelFrame]];
    //}
    
    if (self.editing || self.nowPlaying) {
        durationLabel.alpha = 0.0;
    } else {
        durationLabel.alpha = 1.0;
    }
}


#define IMAGE_SIZE          56.0
#define EDITING_INSET       0.0
#define TEXT_LEFT_MARGIN    16.0
#define TEXT_RIGHT_MARGIN   5.0
#define PREP_TIME_WIDTH     30.0
#define PREP_IMAGE          30.0

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

- (CGRect)_titleLabelFrame {
    if (self.editing) {
        return CGRectMake(IMAGE_SIZE + EDITING_INSET + TEXT_LEFT_MARGIN, 8.0, self.contentView.bounds.size.width - IMAGE_SIZE - EDITING_INSET - TEXT_LEFT_MARGIN, 24.0);
    }
	else {
        return CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 8.0, self.contentView.bounds.size.width - IMAGE_SIZE - TEXT_RIGHT_MARGIN * 2 - PREP_TIME_WIDTH, 24.0);
    }
}

- (CGRect)_artistLabelFrame {
    if (self.editing) {
        return CGRectMake(IMAGE_SIZE + EDITING_INSET + TEXT_LEFT_MARGIN, 33.0, self.contentView.bounds.size.width - IMAGE_SIZE - EDITING_INSET - TEXT_LEFT_MARGIN, 16.0);
    }
	else {
        return CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 33.0, self.contentView.bounds.size.width - IMAGE_SIZE - TEXT_RIGHT_MARGIN * 2 - PREP_TIME_WIDTH, 16.0);
    }
}

- (CGRect)_durationLabelFrame {
    CGRect contentViewBounds = self.contentView.bounds;
    return CGRectMake(contentViewBounds.size.width - PREP_TIME_WIDTH - TEXT_RIGHT_MARGIN, 25.0, PREP_TIME_WIDTH, 14.0);
}


#pragma mark -
#pragma mark Song set accessor

- (void)setSong:(Song *)newSong {
    if (newSong != song) {
        [song release];
        song = [newSong retain];
	}
    //MPMediaItem *anItem = song.song;
	
	//if (anItem) {
        //MPMediaItemArtwork *artwork = [anItem valueForProperty: MPMediaItemPropertyArtwork];
    imageView.image = song.artworkImage;//[artwork imageWithSize:[imageView frame].size];
    if (imageView.image == nil) {
        imageView.image = [UIImage imageNamed:@"artist_img.png"];
    }
    titleLabel.text = song.songTitle;
    artistLabel.text = song.songArtist;
        //NSNumber *durationNumber = [anItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    durationLabel.text = [NSString stringWithFormat: @"%02d:%02d",[song.songDuration intValue] / 60,[song.songDuration intValue] % 60];
	//}
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [song release];
    [imageView release];
    [titleLabel release];
    [artistLabel release];
    [durationLabel release];
    [super dealloc];
}

@end
