//
//  BookMarkListViewController.h
//  iPodSongs
//
//  Created by hun nam on 11. 6. 9..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"


@interface BookMarkListViewController : UITableViewController {
    Song *currentSong;
    UIViewController *mainViewController;
    NSMutableArray *bookMarkArray;
}
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, retain) UIViewController *mainViewController;
@property (nonatomic, retain) NSMutableArray *bookMarkArray;

@end
