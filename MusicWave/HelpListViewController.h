//
//  HelpListViewController.h
//  MusicWave
//
//  Created by Nam Hoon on 11. 8. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionHeaderView.h"



@interface HelpListViewController : UIViewController <UITableViewDelegate, SectionHeaderViewDelegate, UITableViewDataSource>{
    IBOutlet UITableView *helpListTable;
    //NSMutableArray *helpArray;
    //NSMutableDictionary *selectedIndexes;
    //NSInteger selectedIndex;
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UINavigationItem *navigationItem;
    NSArray *helps;
}
@property (nonatomic, retain) UITableView *helpListTable;
//@property (nonatomic, retain) NSMutableArray *helpArray;
@property (nonatomic, retain) NSArray *helps;

@property (nonatomic, retain) NSMutableArray* sectionInfoArray;
@property (nonatomic, retain) NSIndexPath* pinchedIndexPath;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) CGFloat initialPinchHeight;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) UINavigationItem *navigationItem;

// Use the uniformRowHeight property if the pinch gesture should change all row heights simultaneously.
@property (nonatomic, assign) NSInteger uniformRowHeight;

- (IBAction) doneShowingHelpList: (id) sender;

@end
