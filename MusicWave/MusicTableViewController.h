//
//  MusicTableViewController.h
//  iPodSongs
//
//  Created by hoon nam on 11. 6. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MusicTableViewController : UIViewController <MPMediaPickerControllerDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
{
	IBOutlet UITableView *mediaItemCollectionTable;
    IBOutlet UIToolbar *musicTableToolBar;
    IBOutlet UINavigationBar *navigationBar;
    UIViewController *mainViewController;
    NSIndexPath *deleteIndexPath;
    IBOutlet UINavigationItem *navigationItem;
    NSManagedObjectContext *managedObjectContext;
}
@property (retain, nonatomic) IBOutlet UIBarButtonItem *graphDeleteButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *deletButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) UITableView *mediaItemCollectionTable;
@property (nonatomic, retain) UIViewController *mainViewController;
@property (nonatomic, retain) NSIndexPath *deleteIndexPath;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UINavigationItem *navigationItem;
@property (nonatomic, retain) UINavigationBar *navigationBar;
- (void) updateUserSongListWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;
- (IBAction) showMediaPicker: (id) sender;
- (IBAction) doneShowingMusicList: (id) sender;
- (void) tapCheckLibraryButton;
- (IBAction) tapMenuButton: (id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)deleteAction:(id)sender;
- (IBAction)graphDeleteAction:(id)sender;

@end