//
//  BookMarkListTableViewCell.h
//  iPodSongs
//
//  Created by hun nam on 11. 6. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "BookMark.h"


@interface BookMarkListTableViewCell : UITableViewCell {
    Song *song;
    BookMark *bookMark;
    UILabel *keepDateLabel;
    UILabel *timeLabel;
}
@property (nonatomic, retain) Song *song;
@property (nonatomic, retain) UILabel *keepDateLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) BookMark *bookMark;

@end
