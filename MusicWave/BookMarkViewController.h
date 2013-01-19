//
//  BookMarkViewController.h
//  MusicWave
//
//  Created by Nam Hoon on 11. 8. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Song.h"


@interface BookMarkViewController : UIViewController <UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>{
    IBOutlet UITableView					*bookMarkListTable;
    IBOutlet UIToolbar *bookMarkToolBar;
    //IBOutlet UIToolbar *bookMarkToolBar;
    Song *currentSong;
    UIViewController *mainViewController;
    NSMutableArray *bookMarkArray;
    UIButton *rightBarButton;
    UIBarButtonItem *rightBarItem;

}
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionBarItem;
@property (nonatomic, retain) UITableView *bookMarkListTable;
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, retain) UIViewController *mainViewController;
@property (nonatomic, retain) NSMutableArray *bookMarkArray;
@property (nonatomic, retain) UIButton *rightBarButton;
@property (nonatomic, retain) UIBarButtonItem *rightBarItem;
-(IBAction)showPicker:(id)sender;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
-(void)gotoHelpList;
- (IBAction)gotoReviews:(id)sender;

- (IBAction) tapMenuButton: (id)sender;


@end
