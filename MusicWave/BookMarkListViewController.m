//
//  BookMarkListViewController.m
//  iPodSongs
//
//  Created by hun nam on 11. 6. 9..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookMarkListViewController.h"
#import "BookMarkListTableViewCell.h"
#import "iPodSongsViewController.h"


@implementation BookMarkListViewController
@synthesize currentSong, mainViewController;
@synthesize bookMarkArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        currentSong = nil;
    }
    return self;
}

- (void)dealloc
{
    [currentSong release];
    [mainViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.rowHeight = 58.0;
    self.title = NSLocalizedString(@"BookMarks", @"Title for BookMark List");
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundColor = [UIColor colorWithRed:45.0/255.0f green:51.0/255.0f blue:69.0/255.0f alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:32.0/255.0f green:36.0/255.0f blue:45.0/255.0f alpha:1.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.bookMarkArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookMarkListTableViewCell";
    
    BookMarkListTableViewCell *cell = (BookMarkListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[BookMarkListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSInteger row = [indexPath row];
    BookMark *bookMark = [self.bookMarkArray objectAtIndex:row];
    cell.song = currentSong;
    cell.bookMark = bookMark;
    //cell.song = currentSong;

	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        BookMark *bookMark = [self.bookMarkArray objectAtIndex:indexPath.row];
        if ([bookMark.position floatValue]== ((iPodSongsViewController *)mainViewController).startPickerPosition) {
            ((iPodSongsViewController *)mainViewController).startPickerPosition = 0.f;
            [(iPodSongsViewController *)mainViewController unregisterTimeObserver];
        }
        if ([bookMark.position floatValue] == ((iPodSongsViewController *)mainViewController).endPickerPosition) {
            ((iPodSongsViewController *)mainViewController).endPickerPosition = 0.f;
             [(iPodSongsViewController *)mainViewController unregisterTimeObserver];
        }
        [self.bookMarkArray removeObjectAtIndex:indexPath.row];
        
        [self.currentSong removeBookmarksObject:bookMark];
        NSManagedObjectContext *context = [self.currentSong managedObjectContext];
        // Save the context.
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    //NSLog(@"bookmark list table view did select:%d", indexPath.row);
    [((iPodSongsViewController *)mainViewController).startPickerView scrollToElement:(indexPath.row + 1) animated:NO];
    if (((iPodSongsViewController *)mainViewController).playState == playBackStatePaused) {
        [(iPodSongsViewController *)mainViewController play];
    }
}

@end
