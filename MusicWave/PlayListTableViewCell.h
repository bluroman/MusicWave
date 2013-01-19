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
    
    UILabel *titleLabel;
    UILabel *artistLabel;
    UIImageView *playOrHasGraphView;
}
@property (nonatomic, retain) Song *song;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *artistLabel;
@property (nonatomic, retain) UIImageView *playOrHasGraphView;
@end
