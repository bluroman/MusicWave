//
//  HelpListTableViewCell.h
//  MusicWave
//
//  Created by Nam Hoon on 11. 8. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Tutorial;

@interface HelpListTableViewCell : UITableViewCell {
    UILabel *tutorialLabel;
    UIImageView *tutorialImageView;
}

@property (nonatomic, retain) UILabel *tutorialLabel;
@property (nonatomic, retain) UIImageView *tutorialImageView;
@property (nonatomic, retain) Tutorial *tutorial;

@end
