/*
    File: MusicTableViewController.m
Abstract: Table view controller class for AddMusic. Shows the list
of music chosen by the user.
 Version: 1.1

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.

*/


#import "MusicTableViewController.h"
#import "iPodSongsViewController.h"
#import "PlayListTableViewCell.h"

@interface MusicTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

#define NAVIGATION_BAR_COLOR    [UIColor colorWithRed:200.0/255.0f green:204.0/255.0f blue:211.0/255.0f alpha:1.0f]

@implementation MusicTableViewController


//@synthesize delegate;					// The main view controller is the delegate for this class.
@synthesize mediaItemCollectionTable;	// The table shown in this class's view.
@synthesize addMusicButton;				// The button for invoking the media item picker. Setting the title
										//		programmatically supports localization.
@synthesize mainViewController;
@synthesize deleteIndexPath;
@synthesize navigationItem, navigationBar;

@synthesize fetchedResultsController=_fetchedResultsController;

@synthesize managedObjectContext;
- (void)checkIpodLibrary
{
    NSError *error;
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    
    for (Song *item in _fetchedResultsController.fetchedObjects)
    {
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:item.persistentId forProperty:MPMediaItemPropertyPersistentID];
        MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
        [songQuery addFilterPredicate: predicate];
        if (songQuery.items.count > 0) {
            //song exists
            //NSLog(@"Existing song");
        }
        else
        {
            NSLog(@"Not existing song");
            [context deleteObject:item];
        }
        [songQuery release];
    }
    // Save the context.
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();  // Fail
	}
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"current language:%@", language);
    //if([language isEqualToString:@"ko"])
    //NSLog(@"current string equal to ko");
    //else
    //NSLog(@"current string not equal to ko");
    
    // Set the table view's row height
    //self.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 5, 174, 30)];
    titleLabel.tag = 1;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    //self.songTitleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedString(@"My List", @"Music List Title");
    titleLabel.highlightedTextColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //rightBarButton.buttonType = UIButtonTypeRoundedRect;
    
    //rightBarButton = [[UIButton alloc] buttonWithType:UIButtonTypeRoundedRect];
	rightBarButton.frame = CGRectMake(0.0f, 0.0f, 29.0f, 30.0f);
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_plus_basic.png"] forState:UIControlStateNormal];
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_plus_press.png"] forState:UIControlStateSelected];
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_plus_press.png"] forState:UIControlStateHighlighted];
   
    [rightBarButton addTarget:self action:@selector(showMediaPicker:) forControlEvents: UIControlEventTouchUpInside];
    //UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    //[rightBarButton release];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    //[rightBarButton release];
    
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [rightBarItem release];
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftBarButton.frame = CGRectMake(0.0f, 0.0f, 59.0f, 30.0f);
    if ([language isEqualToString:@"ko"]) {
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_kor_basic.png"] forState:UIControlStateNormal];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_kor_press.png"] forState:UIControlStateSelected];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_kor_press.png"] forState:UIControlStateHighlighted];
    } else {
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_eng_basic.png"] forState:UIControlStateNormal];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_eng_press.png"] forState:UIControlStateSelected];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_eng_press.png"] forState:UIControlStateHighlighted];
    }

    
    [leftBarButton addTarget:self action:@selector(doneShowingMusicList:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    //[leftBarButton release];
    
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];

    //self.navigationItem.title = NSLocalizedString(@"My List", @"Music List Title");
    //self.navigationItem.prompt = NSLocalizedString(@"Select song to play", @"Music table view prompt");
    self.mediaItemCollectionTable.rowHeight = 58.0;
    self.mediaItemCollectionTable.backgroundColor = [UIColor colorWithRed:45.0/255.0f green:51.0/255.0f blue:69.0/255.0f alpha:1.0];
    self.mediaItemCollectionTable.separatorColor = [UIColor colorWithRed:32.0/255.0f green:36.0/255.0f blue:45.0/255.0f alpha:1.0];
    
    [musicTableToolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back.png"]
             forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
}
- (IBAction) tapCheckLibraryButton: (id)sender
{
    [self checkIpodLibrary];
    [self.mediaItemCollectionTable reloadData];
}

// When the user taps Done, invokes the delegate's method that dismisses the table view.
- (IBAction) doneShowingMusicList: (id) sender {
	[(iPodSongsViewController *)mainViewController musicTableViewControllerDidFinish:self];
}


// Configures and displays the media item picker.
- (IBAction) showMediaPicker: (id) sender {

	MPMediaPickerController *picker =
		[[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
	
	picker.delegate						= self;
	picker.allowsPickingMultipleItems	= YES;
	picker.prompt						= NSLocalizedString (@"Select songs to my List", @"Music picker prompt");
    [self presentModalViewController: picker animated: YES];
	[picker release];
}


// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    [self dismissModalViewControllerAnimated: YES];
    [self updateUserSongListWithMediaCollection:mediaItemCollection];
	[self.mediaItemCollectionTable reloadData];
}


// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {

	[self dismissModalViewControllerAnimated: YES];
}

- (void)configureCell:(PlayListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Song *song = (Song *)[_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.song = song;
    if ([cell.song isEqual:((iPodSongsViewController *)mainViewController).currentSong]) {
        cell.nowPlaying = YES;
        UIImageView *soundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"]];
        soundImageView.frame = CGRectMake(273, 21, 20, 16);
        cell.accessoryView = soundImageView;
        [soundImageView release];
    }
    else {
        cell.nowPlaying = NO;
        cell.accessoryView = nil;
    }
}

- (void)alertOKCancelAction
{
	// open a alert with an OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"My Music alert title") message:NSLocalizedString(@"Are you sure to delete now playing Item?", @"My Music alert message") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"My Music delete cancel") otherButtonTitles:NSLocalizedString(@"OK", @"My Music delete ok"), nil];
	[alert show];
	[alert release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
        [context deleteObject:[_fetchedResultsController objectAtIndexPath:self.deleteIndexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [(iPodSongsViewController *)mainViewController deleteCurrentSong];
    }
}



#pragma mark Table view methods________________________

// To learn about using table views, see the TableViewSuite sample code  
//		and Table View Programming Guide for iPhone OS.

- (void)insertNewSong:(MPMediaItem *)mediaItem {
    
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[_fetchedResultsController fetchRequest] entity];
    Song *newSong = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    newSong.songTitle = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    newSong.songArtist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
    newSong.songDuration = [mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    newSong.persistentId = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
    NSURL *tempURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    newSong.songURL = [tempURL absoluteString];
    MPMediaItemArtwork *artwork = [mediaItem valueForProperty: MPMediaItemPropertyArtwork];
    newSong.artworkImage = [artwork imageWithSize:CGSizeMake(56, 56)];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

- (void) updateUserSongListWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {

    NSMutableArray *previousUserSongList = [[_fetchedResultsController fetchedObjects] mutableCopy];
    
    if (previousUserSongList == nil) {
        //NSLog(@"previousUserSongList nil");
    }
    //[request release];
	if (mediaItemCollection) {
		if ([previousUserSongList count] == 0) {
            
            NSArray *mediaItems = [mediaItemCollection items];
            NSEnumerator *enumer = [mediaItems objectEnumerator];
            id myObject;
            while ((myObject = [enumer nextObject]) != nil) {
                MPMediaItem *tempMediaItem = (MPMediaItem *) myObject;
                //NSLog(@"Title: %@", [tempMediaItem valueForProperty:MPMediaItemPropertyTitle]);
                //NSLog(@"Artist: %@", [tempMediaItem valueForProperty:MPMediaItemPropertyArtist]);
                //NSLog(@"Persistent Id: %llu", [[tempMediaItem valueForProperty:MPMediaItemPropertyPersistentID] unsignedLongLongValue]);
                //NSLog(@"----------------------------");
                [self insertNewSong:tempMediaItem];
            }
		} else {
            NSArray *newMediaItems				= [mediaItemCollection items];
            for (int i = 0; i < [newMediaItems count]; i++) {
                MPMediaItem *tempMediaItem = [newMediaItems objectAtIndex:i];
                NSNumber *tempPersistentId = [tempMediaItem valueForProperty:MPMediaItemPropertyPersistentID];
                BOOL exist = NO;
                for (int j = 0; j < [previousUserSongList count]; j++) {
                    Song *tempSong = [previousUserSongList objectAtIndex:j];
                    if ([tempPersistentId unsignedLongLongValue] == [tempSong.persistentId unsignedLongLongValue])
                    {
                        //NSLog(@"equal temp:%llu , song:%llu", [tempPersistentId unsignedLongLongValue], [tempSong.persistentId unsignedLongLongValue]);
                        //NSLog(@"Exist song title:%@", tempSong.songTitle);
                        exist = YES;
                    }
                }
                if (exist == NO) {
                    //NSLog(@"not equal add to song List");
                    [self insertNewSong:tempMediaItem];
                }
            }
            
		}
	}
    [previousUserSongList release];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayListViewCellIdentifier";
    
    PlayListTableViewCell *cell = (PlayListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PlayListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    
    return cell;
}


//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    //NSLog(@"play list table view did select:%d", indexPath.row);
    //NSLog(@"play list select");
    Song *song = (Song *)[_fetchedResultsController objectAtIndexPath:indexPath];
    
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:song.persistentId forProperty:MPMediaItemPropertyPersistentID]; 
    MPMediaQuery *songQuery = [[MPMediaQuery alloc] init]; 
    [songQuery addFilterPredicate: predicate]; 
    if (songQuery.items.count > 0) {
        //song exists  
        //NSLog(@"Existing song");
        [songQuery release];
        //return;
    }
    else {
        //NSLog(@"Not existing song");
        [tableView deselectRowAtIndexPath: indexPath animated: YES];
        [songQuery release];
        return;
    }
    ((iPodSongsViewController *)mainViewController).currentSong = song;
    [(iPodSongsViewController *)mainViewController updateCurrentSong];
    //[(iPodSongsViewController *)mainViewController startUpdateCurrentSongThread];
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    [(iPodSongsViewController *)mainViewController musicTableViewControllerDidFinish:self];
    //NSLog(@"view disappear");
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Song *deleteSong = [_fetchedResultsController objectAtIndexPath:indexPath];
        if ([deleteSong isEqual:((iPodSongsViewController *)mainViewController).currentSong])
        {
            //NSLog(@"current song is deleted warning");
            //NSLog(@"if Yes, all playing contents cleared");
            self.deleteIndexPath = indexPath;
            [self alertOKCancelAction];
            
            return;
        }
        //[theDataObject.userSongList removeObjectAtIndex:indexPath.row];
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
        [context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark Application state management_____________
// Standard methods for managing application state.
- (void)didReceiveMemoryWarning {

	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [musicTableToolBar release];
    musicTableToolBar = nil;

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.fetchedResultsController = nil;
}


- (void)dealloc {
    [_fetchedResultsController release];
    [managedObjectContext release];
    [mainViewController release];
    [deleteIndexPath release];
    [navigationItem release];
    [navigationBar release];
    [musicTableToolBar release];
    [super dealloc];
}
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"songTitle" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
	/*NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}*/
    
    return _fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.mediaItemCollectionTable beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.mediaItemCollectionTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.mediaItemCollectionTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.mediaItemCollectionTable;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.mediaItemCollectionTable endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


@end
