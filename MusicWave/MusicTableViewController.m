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
#import "CommonUtil.h"
@interface NSManagedObject (FirstLetter)
- (NSString *)uppercaseFirstLetterOfName;
@end

@implementation NSManagedObject (FirstLetter)
- (NSString *)uppercaseFirstLetterOfName {
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
    NSString *aString = [[self valueForKey:@"songTitle"] uppercaseString];
    
    // support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];
    
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}
@end
@interface MusicTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
@implementation MusicTableViewController
@synthesize mediaItemCollectionTable;
@synthesize mainViewController;
@synthesize deleteIndexPath;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize managedObjectContext;
@synthesize filteredListContent;
- (void)removeAllGraphImageOnCache:(NSString *)myDir
{
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    for (Song *item in _fetchedResultsController.fetchedObjects)
    {
        if(item.doneGraphDrawing)
        {
            if ([item isEqual:((iPodSongsViewController *)mainViewController).currentSong])
                continue;
            [CommonUtil removeGraphImage:item.graphPath];
            item.doneGraphDrawing = NO;
        }
        
    }
    //[CommonUtil removeTMPDirectory];
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
        if (item.doneGraphDrawing)
        {
            [CommonUtil removeGraphImage:item.graphPath];
        }
        
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
            
            [CommonUtil removeGraphImage:item.graphPath];
            [context deleteObject:item];
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
    self.mediaItemCollectionTable.allowsMultipleSelectionDuringEditing = YES;
    [self.mediaItemCollectionTable setEditing:YES animated:YES];
}
- (IBAction)cancelAction:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.mediaItemCollectionTable.allowsMultipleSelectionDuringEditing = NO;
    [self.mediaItemCollectionTable setEditing:NO animated:YES];
    self.deletButton.enabled = NO;
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
            if ([deleteSong isEqual:((iPodSongsViewController *)mainViewController).currentSong])
                continue;
            if (deleteSong.doneGraphDrawing)
            {
                [CommonUtil removeGraphImage:deleteSong.graphPath];
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.deletButton.enabled = NO;
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
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar2.png"] forBarMetrics:UIBarMetricsDefault];
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.action = @selector(editAction:);
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
    self.title = NSLocalizedString(@"My List", @"Music List Title");
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftBarButton.frame = CGRectMake(0.0f, 0.0f, 37.0f, 38.0f);
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateNormal];
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateSelected];
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateHighlighted];
    [leftBarButton addTarget:self action:@selector(doneShowingMusicList) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    //self.navigationItem.leftBarButtonItem.tintColor = [UIColor blueColor];
    //self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Close", @"Music List close");
    self.deletButton.enabled = NO;
    [musicTableToolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [musicTableToolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back_landscape.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsLandscapePhone];
    musicTableToolBar.autoresizingMask = musicTableToolBar.autoresizingMask | UIViewAutoresizingFlexibleHeight;
    self.filteredListContent = [NSMutableArray arrayWithCapacity:[[_fetchedResultsController fetchedObjects] count]];
    
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
            [self removeAllGraphImageOnCache:[[self class] applicationDocumentsDirectory]];
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
- (void) doneShowingMusicList
{
	//[self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
    //NSLog(@"Here comes ");
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                         
                     }];
    [self.navigationController popViewControllerAnimated:NO];
    
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
- (void)configureCell:(PlayListTableViewCell *)cell contentSong:(Song *)song
{
    cell.song = song;
    if ([cell.song isEqual:((iPodSongsViewController *)mainViewController).currentSong])
    {
        cell.artistLabel.highlighted = YES;
        cell.titleLabel.highlighted = YES;
        cell.playOrHasGraphView.image = [UIImage imageNamed:@"list-volume.png"];
    }
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
        //[self removeGraphImage:song.graphPath];
        [CommonUtil removeGraphImage:song.graphPath];
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 1;
    return [[_fetchedResultsController sections] count];
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
    //return [_fetchedResultsController sectionIndexTitles];
//}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [_fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }

    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return nil;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}
/*- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return nil;
    // create the parent view
    UIView * customSectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    customSectionView.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.000] colorWithAlphaComponent:0.9];
    // create the label
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, -5, 300, customSectionView.frame.size.height)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.text = [sectionInfo name];
    // package and return
    [customSectionView addSubview:headerLabel];
    [headerLabel release];
    
    return [customSectionView autorelease];
}*/
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
    //return 1;
//}
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
    //return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
//}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"accessory Button Tapped");
    Song *song = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
        song = [self.filteredListContent objectAtIndex:indexPath.row];
    else song = (Song *)[_fetchedResultsController objectAtIndexPath:indexPath];
    MusicListDetailViewController *detailViewController = [[MusicListDetailViewController alloc] initWithNibName:@"MusicListDetailViewController" bundle:nil];
    //detailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    detailViewController.currentSong = song;
    detailViewController.isPlaying = [song isEqual:((iPodSongsViewController *)mainViewController).currentSong];
    
    //[self presentModalViewController: detailViewController animated: YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
    //controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    //[self presentModalViewController: controller animated: YES];

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
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayListViewCellIdentifier";
    PlayListTableViewCell *cell = (PlayListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[PlayListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    Song *song = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        song = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        song = (Song *)[_fetchedResultsController objectAtIndexPath:indexPath];
    }
    [self configureCell:cell contentSong:song];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.mediaItemCollectionTable.isEditing)
    {
        Song *song = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            song = [self.filteredListContent objectAtIndex:indexPath.row];
        }
        else
        {
            song = (Song *)[_fetchedResultsController objectAtIndexPath:indexPath];
        }

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
        /*if (self.navigationItem.rightBarButtonItem == nil) {
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
            self.navigationItem.rightBarButtonItem.action = @selector(editAction:);
        }
        if (self.navigationItem.leftBarButtonItem.enabled == NO) {
            self.navigationItem.leftBarButtonItem.enabled = YES;
        }*/
        ((iPodSongsViewController *)mainViewController).currentSong = song;
        [(iPodSongsViewController *)mainViewController updateCurrentSong];
        [self doneShowingMusicList];
        //[self.navigationController popToViewController:mainViewController animated:YES];
        //[(iPodSongsViewController *)mainViewController musicTableViewControllerDidFinish:self];
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
        //[self removeGraphImage:deleteSong.graphPath];
        [CommonUtil removeGraphImage:deleteSong.graphPath];
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
#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.filteredListContent removeAllObjects];
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    NSMutableArray *allSongList = [[_fetchedResultsController fetchedObjects] mutableCopy];
	for (Song *song in allSongList)
	{
        NSComparisonResult result = [song.songTitle compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:song];
            }
    
	}
    [allSongList release];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 58.0f;
    tableView.backgroundColor = [UIColor colorWithRed:34.0/255.0f green:33.0/255.0f blue:29.0/255.0f alpha:1.0];
    tableView.separatorColor = [UIColor colorWithRed:131.0/255.0f green:130.0/255.0f blue:124.0/255.0f alpha:1.0];
    
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    self.navigationItem.rightBarButtonItem = nil;
    //self.navigationItem.leftBarButtonItem.enabled = NO;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    //NSLog(@"unload search results table view");
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.action = @selector(editAction:);
    //self.navigationItem.leftBarButtonItem.enabled = YES;
}

#pragma mark Application state management_____________
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
    [self setDeletButton:nil];
    [self setCancelButton:nil];
    musicTableToolBar = nil;
    self.filteredListContent = nil;
    self.fetchedResultsController = nil;
}
- (void)dealloc {
    [_fetchedResultsController release];
    [managedObjectContext release];
    [mainViewController release];
    [deleteIndexPath release];
    [musicTableToolBar release];
    [_cancelButton release];
    [_deletButton release];
    [filteredListContent release];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"songTitle" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"uppercaseFirstLetterOfName" cacheName:@"Root"];
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
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    //NSLog(@"willRotateTo:%d", orientation);
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //NSLog(@"Go To:%d", toInterfaceOrientation);
    // we grab the screen frame first off; these are always
    // in portrait mode
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGSize size = bounds.size;
    //CGRect startPickerPortraitFrame = CGRectZero;
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        //NSLog(@"current orientation:%d", orientation);
        //NSLog(@"Portrait Music Table size width:%f, height:%f", self.mediaItemCollectionTable.frame.size.width, self.mediaItemCollectionTable.frame.size.height);
    }
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // we're going to landscape, which means we gotta swap them
        size.width = bounds.size.height;
        size.height = bounds.size.width;
        //NSLog(@"Music Table size width:%f, height:%f", self.mediaItemCollectionTable.frame.size.width, self.mediaItemCollectionTable.frame.size.height);
    }

    //[self layoutByOrientation];
    // size is now the width and height that we will have after the rotation
    //NSLog(@"orientation %d size: w:%f h:%f", toInterfaceOrientation, size.width, size.height);
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //NSLog(@"music table autorotaion:%d", interfaceOrientation);
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
