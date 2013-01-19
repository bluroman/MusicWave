//
//  MusicTableViewController.m
//  iPodSongs
//
//  Created by hoon nam on 11. 6. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "MusicTableViewController.h"
#import "iPodSongsViewController.h"
#import "PlayListTableViewCell.h"
#import "MusicListDetailViewController.h"

@interface MusicTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
#define TMP NSTemporaryDirectory()
@implementation MusicTableViewController
@synthesize mediaItemCollectionTable;
@synthesize mainViewController;
@synthesize deleteIndexPath;
@synthesize navigationItem, navigationBar;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize managedObjectContext;
- (void)removeGraphImage:(NSString *)myPath
{
    BOOL result = NO;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath: myPath])
    {
        NSLog(@"Remove file exists on:%@", myPath);
        result = [fileManager removeItemAtPath:myPath error:&error];
        if (!result)
        {
            NSLog(@"Remove file error %@, %@", error, [error userInfo]);
        }
    }
    else NSLog(@"No Remove file found on:%@", myPath);
}
- (void)removeAllGraphImageOnCache:(NSString *)myDir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    for (Song *item in _fetchedResultsController.fetchedObjects)
    {
        if(item.doneGraphDrawing)
        {
            if ([item isEqual:((iPodSongsViewController *)mainViewController).currentSong])
                continue;
            BOOL success = [fileManager removeItemAtPath:item.graphPath error:&error];
            if (!success)
            {
                NSLog(@"Remove all file error %@, %@", error, [error userInfo]);
            }
            else item.doneGraphDrawing = NO;
        }
    }
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.mediaItemCollectionTable reloadData];
}
- (void)deleteAllSongs
{
    NSError *error;
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    for (Song *item in _fetchedResultsController.fetchedObjects)
    {
        if ([item isEqual:((iPodSongsViewController *)mainViewController).currentSong])
            continue;
        [context deleteObject:item];
    }
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.mediaItemCollectionTable reloadData];
}
- (void)checkIpodLibrary
{
    NSError *error;
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    for (Song *item in _fetchedResultsController.fetchedObjects)
    {
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:item.persistentId forProperty:MPMediaItemPropertyPersistentID];
        MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
        [songQuery addFilterPredicate: predicate];
        if (songQuery.items.count > 0)
        {
        }
        else
        {
            NSLog(@"Not existing song");
            [context deleteObject:item];
            [self removeGraphImage:item.graphPath];
        }
        [songQuery release];
    }
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
- (IBAction)editAction:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.cancelButton;
    self.deletButton.enabled = YES;
    self.graphDeleteButton.enabled = YES;
    self.mediaItemCollectionTable.allowsMultipleSelectionDuringEditing = YES;
    [self.mediaItemCollectionTable setEditing:YES animated:YES];
}
- (IBAction)cancelAction:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.mediaItemCollectionTable.allowsMultipleSelectionDuringEditing = NO;
    [self.mediaItemCollectionTable setEditing:NO animated:YES];
    self.deletButton.title = NSLocalizedString(@"Delete", @"music list delete default title");
    self.graphDeleteButton.title = NSLocalizedString(@"Delete Graph", @"music list graph delete default title");
    self.deletButton.enabled = NO;
    self.graphDeleteButton.enabled = NO;
}
- (IBAction)deleteAction:(id)sender
{
    NSArray *selectedRows = [self.mediaItemCollectionTable indexPathsForSelectedRows];
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    if (selectedRows.count > 0)
    {
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            Song *deleteSong = [_fetchedResultsController objectAtIndexPath:selectionIndex];
            if (deleteSong.doneGraphDrawing)
            {
                [self removeGraphImage:deleteSong.graphPath];
            }
            [context deleteObject:deleteSong];
        }
    }
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.mediaItemCollectionTable setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.editButton;
    [self.mediaItemCollectionTable setEditing:NO animated:YES];
    self.deletButton.title = NSLocalizedString(@"Delete", @"music list delete default title");
    self.deletButton.enabled = NO;
    self.graphDeleteButton.enabled = NO;
}
- (IBAction)graphDeleteAction:(id)sender
{
    NSArray *selectedRows = [self.mediaItemCollectionTable indexPathsForSelectedRows];
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    if (selectedRows.count > 0)
    {
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            Song *deleteSong = [_fetchedResultsController objectAtIndexPath:selectionIndex];
            if (deleteSong.doneGraphDrawing)
            {
                [self removeGraphImage:deleteSong.graphPath];
                deleteSong.doneGraphDrawing = NO;
            }
        }
    }
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.mediaItemCollectionTable setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.editButton;
    [self.mediaItemCollectionTable setEditing:NO animated:YES];
    self.deletButton.title = NSLocalizedString(@"Delete", @"music list delete default title");
    self.deletButton.enabled = NO;
    self.graphDeleteButton.enabled = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    self.mediaItemCollectionTable.rowHeight = 58.0;
    self.mediaItemCollectionTable.backgroundColor = [UIColor colorWithRed:34.0/255.0f green:33.0/255.0f blue:29.0/255.0f alpha:1.0];
    self.mediaItemCollectionTable.separatorColor = [UIColor colorWithRed:131.0/255.0f green:130.0/255.0f blue:124.0/255.0f alpha:1.0];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar2.png"] forBarMetrics:UIBarMetricsDefault];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 5, 174, 30)];
    titleLabel.tag = 1;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedString(@"My List", @"Music List Title");
    titleLabel.highlightedTextColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blueColor];
    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Close", @"Music List close");
    self.deletButton.enabled = NO;
    self.graphDeleteButton.enabled = NO;
    [musicTableToolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet release];
    switch (buttonIndex)
    {
        case 0:
            [self deleteAllSongs];
            break;
        case 1:
            [self removeAllGraphImageOnCache:TMP];
            break;
        case 2:
            [self tapCheckLibraryButton];
            break;
        default:
            break;
    }
}
- (IBAction)tapMenuButton:(id)sender
{
    UIActionSheet *menu = [[UIActionSheet alloc]
                           initWithTitle: @""
                           delegate:self
                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"delete cancel")
                           destructiveButtonTitle:nil
                           otherButtonTitles:NSLocalizedString(@"Delete all songs", @"delete all songs on music list"), NSLocalizedString(@"Delete all graph", @"delete all graph on cache"), NSLocalizedString(@"Update library", @"update ipod library"), nil];
    menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [menu showInView:self.view];
}
- (void) tapCheckLibraryButton
{
    [self checkIpodLibrary];
    [self.mediaItemCollectionTable reloadData];
}
- (IBAction) doneShowingMusicList: (id) sender
{
	[(iPodSongsViewController *)mainViewController musicTableViewControllerDidFinish:self];
}
- (IBAction) showMediaPicker: (id) sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	picker.delegate						= self;
	picker.allowsPickingMultipleItems	= YES;
	picker.prompt						= NSLocalizedString (@"Select songs to my List", @"Music picker prompt");
    [self presentModalViewController: picker animated: YES];
	[picker release];
}
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    [self dismissModalViewControllerAnimated: YES];
    [self updateUserSongListWithMediaCollection:mediaItemCollection];
	[self.mediaItemCollectionTable reloadData];
}
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissModalViewControllerAnimated: YES];
}
- (void)configureCell:(PlayListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Song *song = (Song *)[_fetchedResultsController objectAtIndexPath:indexPath];
    cell.song = song;
    if ([cell.song isEqual:((iPodSongsViewController *)mainViewController).currentSong])
    {
        cell.artistLabel.highlighted = YES;
        cell.titleLabel.highlighted = YES;
        cell.playOrHasGraphView.image = [UIImage imageNamed:@"list-volume.png"];
    }
}
- (void)alertOKCancelAction
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"My Music alert title")
                        message:NSLocalizedString(@"Are you sure to delete now playing Item?", @"My Music alert message")
                        delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"My Music delete cancel")
                        otherButtonTitles:NSLocalizedString(@"OK", @"My Music delete ok"), nil];
	[alert show];
	[alert release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
        Song *song = (Song *)[_fetchedResultsController objectAtIndexPath:self.deleteIndexPath];
        [self removeGraphImage:song.graphPath];
        [context deleteObject:song];
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [(iPodSongsViewController *)mainViewController deleteCurrentSong];
    }
}
- (void)insertNewSong:(MPMediaItem *)mediaItem
{
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[_fetchedResultsController fetchRequest] entity];
    Song *newSong = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    newSong.songTitle = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    newSong.songArtist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
    newSong.songDuration = [NSNumber  numberWithFloat:[[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue]];
    newSong.persistentId = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
    newSong.songAlbum = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSURL *tempURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    newSong.songURL = [tempURL absoluteString];
    MPMediaItemArtwork *artwork = [mediaItem valueForProperty: MPMediaItemPropertyArtwork];
    newSong.artworkImage = [artwork imageWithSize:CGSizeMake(56, 56)];
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
- (void) updateUserSongListWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection
{
    NSMutableArray *previousUserSongList = [[_fetchedResultsController fetchedObjects] mutableCopy];
	if (mediaItemCollection)
    {
		if ([previousUserSongList count] == 0)
        {
            NSArray *mediaItems = [mediaItemCollection items];
            NSEnumerator *enumer = [mediaItems objectEnumerator];
            id myObject;
            while ((myObject = [enumer nextObject]) != nil)
            {
                MPMediaItem *tempMediaItem = (MPMediaItem *) myObject;
                [self insertNewSong:tempMediaItem];
            }
		}
        else
        {
            NSArray *newMediaItems				= [mediaItemCollection items];
            for (int i = 0; i < [newMediaItems count]; i++)
            {
                MPMediaItem *tempMediaItem = [newMediaItems objectAtIndex:i];
                NSNumber *tempPersistentId = [tempMediaItem valueForProperty:MPMediaItemPropertyPersistentID];
                BOOL exist = NO;
                for (int j = 0; j < [previousUserSongList count]; j++)
                {
                    Song *tempSong = [previousUserSongList objectAtIndex:j];
                    if ([tempPersistentId unsignedLongLongValue] == [tempSong.persistentId unsignedLongLongValue])
                    {
                        exist = YES;
                    }
                }
                if (exist == NO)
                {
                    [self insertNewSong:tempMediaItem];
                }
            }
            
		}
	}
    [previousUserSongList release];
}
#pragma mark Table view methods________________________
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessory Button Tapped");
    Song *song = (Song *)[_fetchedResultsController objectAtIndexPath:indexPath];
    MusicListDetailViewController *detailViewController = [[MusicListDetailViewController alloc] initWithNibName:@"MusicListDetailViewController" bundle:nil];
    detailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    detailViewController.currentSong = song;
    
    [self presentModalViewController: detailViewController animated: YES];
    [detailViewController release];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mediaItemCollectionTable.isEditing)
    {
        NSInteger graphCount = 0;
        NSArray *selectedRows = [self.mediaItemCollectionTable indexPathsForSelectedRows];
        if (selectedRows.count > 0)
        {
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                Song *tempSong = [_fetchedResultsController objectAtIndexPath:selectionIndex];
                if (tempSong.doneGraphDrawing)
                {
                    graphCount++;
                }
            }
        }
        self.deletButton.title = [NSString stringWithFormat: NSLocalizedString(@"Delete (%d)", @"music table delete song title"), selectedRows.count];
        self.graphDeleteButton.title = [NSString stringWithFormat: NSLocalizedString(@"Delete graph (%d)", @"music table delete graph title"), graphCount];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayListViewCellIdentifier";
    PlayListTableViewCell *cell = (PlayListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PlayListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [self configureCell:cell atIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.mediaItemCollectionTable.isEditing)
    {
        Song *song = (Song *)[_fetchedResultsController objectAtIndexPath:indexPath];
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:song.persistentId forProperty:MPMediaItemPropertyPersistentID];
        MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
        [songQuery addFilterPredicate: predicate];
        if (songQuery.items.count > 0)
        {
            [songQuery release];
        }
        else
        {
            [tableView deselectRowAtIndexPath: indexPath animated: YES];
            [songQuery release];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not Found", @"music not found alert title") message:NSLocalizedString(@"select music does not exist, update library required.", @"music not found alert message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"music not found cancel title") otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            return;
        }
        ((iPodSongsViewController *)mainViewController).currentSong = song;
        [(iPodSongsViewController *)mainViewController updateCurrentSong];
        [tableView deselectRowAtIndexPath: indexPath animated: YES];
        [(iPodSongsViewController *)mainViewController musicTableViewControllerDidFinish:self];
    }
    else
    {
        NSInteger graphCount = 0;
        NSArray *selectedRows = [self.mediaItemCollectionTable indexPathsForSelectedRows];
        if (selectedRows.count > 0)
        {
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                Song *tempSong = [_fetchedResultsController objectAtIndexPath:selectionIndex];
                if (tempSong.doneGraphDrawing)
                {
                    graphCount++;
                }
            }
        }
        self.deletButton.title = [NSString stringWithFormat: NSLocalizedString(@"Delete (%d)", @"music table delete song title"), selectedRows.count];
        self.graphDeleteButton.title = [NSString stringWithFormat: NSLocalizedString(@"Delete graph (%d)", @"music table delete graph title"), graphCount];
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Song *deleteSong = [_fetchedResultsController objectAtIndexPath:indexPath];
        if ([deleteSong isEqual:((iPodSongsViewController *)mainViewController).currentSong])
        {
            self.deleteIndexPath = indexPath;
            [self alertOKCancelAction];
            return;
        }
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
        [self removeGraphImage:deleteSong.graphPath];
        [context deleteObject:deleteSong];
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
    else NSLog(@"EditingSyle:%d", editingStyle);
}
#pragma mark Application state management_____________
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
    [self setDeletButton:nil];
    [self setGraphDeleteButton:nil];
    [self setCancelButton:nil];
    [self setEditButton:nil];
    musicTableToolBar = nil;
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
    [_editButton release];
    [_cancelButton release];
    [_deletButton release];
    [_graphDeleteButton release];
    [super dealloc];
}
#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"songTitle" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
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
@end
