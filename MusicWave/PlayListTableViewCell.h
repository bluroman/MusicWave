//
//  PlayListTableViewCell.h
//  iPodSongs
//
//  Created by hun nam on 11. 6. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"


@interface PlayListTableViewCell : UITableViewCell {
    Song *song;
    
    UIImageView *imageView;
    UILabel *titleLabel;
    UILabel *artistLabel;
    UIImageView *graphView;
    BOOL nowPlaying;
}
@property (nonatomic, retain) Song *song;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *graphView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *artistLabel;
@property (nonatomic, assign) BOOL nowPlaying;
@end
