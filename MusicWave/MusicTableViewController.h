//
//  MusicTableViewController.h
//  iPodSongs
//
//  Created by hoon nam on 11. 6. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MusicTableViewController : UIViewController <MPMediaPickerControllerDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
	IBOutlet UITableView *mediaItemCollectionTable;
    IBOutlet UIToolbar *musicTableToolBar;
    UIViewController *mainViewController;
    NSIndexPath *deleteIndexPath;
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray	*filteredListContent;
}
@property (retain, nonatomic) IBOutlet UIBarButtonItem *deletButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UITableView *mediaItemCollectionTable;
@property (nonatomic, retain) UIViewController *mainViewController;
@property (nonatomic, retain) NSIndexPath *deleteIndexPath;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
- (void) updateUserSongListWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;
- (IBAction) showMediaPicker: (id) sender;
- (void) doneShowingMusicList;
- (void) tapCheckLibraryButton;
- (IBAction) tapMenuButton: (id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)deleteAction:(id)sender;

@end