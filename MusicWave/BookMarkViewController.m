//
//  BookMarkViewController.m
//  MusicWave
//
//  Created by Nam Hoon on 11. 8. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookMarkViewController.h"
#import "BookMarkListTableViewCell.h"
#import "iPodSongsViewController.h"
#import "HelpListViewController.h"
#import "MusicWaveAppDelegate.h"


@implementation BookMarkViewController
@synthesize bookMarkNavItem, bookMarkListTable;
@synthesize currentSong, mainViewController;
@synthesize bookMarkArray;
@synthesize rightBarButton, rightBarItem, menuBarItem;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentSong = nil;
    }
    return self;
}

- (void)dealloc
{
    [bookMarkNavItem release];
    [bookMarkListTable release];
    [currentSong release];
    [mainViewController release];
    //[rightBarButton release];
    [rightBarItem release];
    [menuBarItem release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (IBAction) tapEditButton: (id)sender {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"current language:%@", language);
    //if([language isEqualToString:@"ko"])
        //NSLog(@"current string equal to ko");
    //else
        //NSLog(@"current string not equal to ko");
    if (self.bookMarkListTable.editing) {
        // Execute tasks for editing status
        [self.bookMarkListTable setEditing:NO animated:YES];
        if ([language isEqualToString:@"ko"]) {
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_kor_basic.png"] forState:UIControlStateNormal];
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_kor_press.png"] forState:UIControlStateSelected];
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_kor_press.png"] forState:UIControlStateHighlighted];
        } else {
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_eng_basic.png"] forState:UIControlStateNormal];
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_eng_press.png"] forState:UIControlStateSelected];
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_eng_press.png"] forState:UIControlStateHighlighted];
        }    
    } else {
        [self.bookMarkListTable setEditing:YES animated:YES];
        if ([language isEqualToString:@"ko"]) {
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_kor_basic.png"] forState:UIControlStateNormal];
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_kor_press.png"] forState:UIControlStateSelected];
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_kor_press.png"] forState:UIControlStateHighlighted];
        } else {
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_eng_basic.png"] forState:UIControlStateNormal];
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_eng_press.png"] forState:UIControlStateSelected];
            [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_done_eng_press.png"] forState:UIControlStateHighlighted];
        }
    }
}
- (IBAction) tapBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) say: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
    
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:statement message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease];
    [av show];
	[statement release];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet release];
	//[self say:@"User Pressed Button %d\n", buttonIndex + 1];
    switch (buttonIndex) {
        case 0:
            [self gotoHelpList];
            break;
        case 1:
            [self showPicker:nil];
            break;
        case 2:
            [self gotoReviews:nil];
            break;

            
        default:
            break;
    }
}
-(void) gotoHelpList
{
    HelpListViewController *controller = [[HelpListViewController alloc] initWithNibName: @"HelpListViewController" bundle: nil];
    MusicWaveAppDelegate *appDelegate = (MusicWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    controller.helps = appDelegate.helps;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController: controller animated: YES];
    [controller release]; 
}
-(void) action: (UIBarButtonItem *) item
{
    UIActionSheet *menu = [[UIActionSheet alloc]
                           initWithTitle: @""
                           delegate:self
                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"delete cancel")
                           destructiveButtonTitle:nil
                           otherButtonTitles:NSLocalizedString(@"Help", @"Title for help list"), NSLocalizedString(@"Email Support", @"Title for menu email support"), NSLocalizedString(@"Rate MusicWave", @"Title for menu rate"), nil];
    [menu showInView:self.view];
}
- (IBAction) tapMenuButton:(id)sender {
    [self action:nil];
}

-(IBAction)showPicker:(id)sender
{
	// This sample can run on devices running iPhone OS 2.0 or later  
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
	// So, we must verify the existence of the above class and provide a workaround for devices running 
	// earlier versions of the iPhone OS. 
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}


#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Feedback about MusicWave"];
	
    
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"bluroman@gmail.com"]; 
	//NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
	//NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
	
	[picker setToRecipients:toRecipients];
	//[picker setCcRecipients:ccRecipients];	
	//[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    //NSData *myData = [NSData dataWithContentsOfFile:path];
	//[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
	// Fill out the email body text
	NSString *emailBody = @"Thank you for your concerning, if you have any question or feedback. Please let me know, your concerning will help to MusicWave";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
            //[self say:@"Result: canceled"];
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
            //[self say:@"Result: saved"];
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
            [self say:@"Thank you for your concerning"];
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
            //[self say:@"Result: failed"];
			//message.text = @"Result: failed";
			break;
		default:
            //[self say:@"Result: not sent"];
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:bluroman@gmail.com?cc=bluroman@gmail.com&subject=Feedback about MusicWave";
	NSString *body = @"&body=Thank you for your concerning, if you have any question or feedback. Please let me know, your concerning will help to MusicWave";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (IBAction)gotoReviews:(id)sender
{
    //NSString *str =@"http://itunes.com/apps/MusicWave";
    NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
    str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str]; 
    str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
    
    // Here is the app id from itunesconnect
    str = [NSString stringWithFormat:@"%@452506718", str]; 
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"current language:%@", language);
    //if([language isEqualToString:@"ko"])
        //NSLog(@"current string equal to ko");
    //else
        //NSLog(@"current string not equal to ko");
    self.bookMarkListTable.rowHeight = 58.0;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 160, 44)];
    //btn.backgroundColor = [UIColor whiteColor];
    
    //UILabel *label;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleView.bounds.size.width, 44)];
    titleLabel.tag = 1;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    //self.songTitleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = NSLocalizedString(@"BookMarks", @"Title for BookMark List");
    titleLabel.highlightedTextColor = [UIColor blackColor];
    [titleView addSubview:titleLabel];
    [titleLabel release];
    //[label release];
    
    self.navigationItem.titleView = titleView;
    [titleView release];
    rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //rightBarButton.buttonType = UIButtonTypeRoundedRect;
    
    //rightBarButton = [[UIButton alloc] buttonWithType:UIButtonTypeRoundedRect];
	rightBarButton.frame = CGRectMake(0.0f, 0.0f, 59.0f, 30.0f);
    if ([language isEqualToString:@"ko"]) {
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_kor_basic.png"] forState:UIControlStateNormal];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_kor_press.png"] forState:UIControlStateSelected];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_kor_press.png"] forState:UIControlStateHighlighted];
    } else {
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_eng_basic.png"] forState:UIControlStateNormal];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_eng_press.png"] forState:UIControlStateSelected];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"btn_edit_eng_press.png"] forState:UIControlStateHighlighted];
    }
    [rightBarButton addTarget:self action:@selector(tapEditButton:) forControlEvents: UIControlEventTouchUpInside];
    //UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    //[rightBarButton release];
    rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    //[rightBarButton release];
    
    self.navigationItem.rightBarButtonItem = rightBarItem;
    //[rightBarItem release];
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftBarButton.frame = CGRectMake(0.0f, 0.0f, 59.0f, 30.0f);
    if ([language isEqualToString:@"ko"]) {
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_back_kor_basic.png"] forState:UIControlStateNormal];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_back_kor_press.png"] forState:UIControlStateSelected];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_back_kor_press.png"] forState:UIControlStateHighlighted];
    } else {
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_back_eng_basic.png"] forState:UIControlStateNormal];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_back_eng_press.png"] forState:UIControlStateSelected];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"btn_back_eng_press.png"] forState:UIControlStateHighlighted];
    }
    [leftBarButton addTarget:self action:@selector(tapBackButton:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    //[leftBarButton release];
    
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    self.menuBarItem.title = NSLocalizedString(@"Menu", @"Title for menu");
    
    
    //self.editButtonItem.customView = rightBarButton;
    //[rightBarItem release];
    
    //self.title = NSLocalizedString(@"BookMarks", @"Title for BookMark List");
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.bookMarkListTable.backgroundColor = [UIColor colorWithRed:45.0/255.0f green:51.0/255.0f blue:69.0/255.0f alpha:1.0];
    self.bookMarkListTable.separatorColor = [UIColor colorWithRed:32.0/255.0f green:36.0/255.0f blue:45.0/255.0f alpha:1.0];
    
    /*UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	tb.center = CGPointMake(160.0f, 400.0f);
	NSMutableArray *tbitems = [NSMutableArray array];
    
	[tbitems addObject:BARBUTTON(@"Title", @selector(action))];
	[tbitems addObject:SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(action))];
	[tbitems addObject:IMGBARBUTTON([UIImage imageNamed:@"TBUmbrella.png"], @selector(action))];
	[tbitems addObject:CUSTOMBARBUTTON([[[UISwitch alloc] init] autorelease])];
	[tbitems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[tbitems addObject:IMGBARBUTTON([UIImage imageNamed:@"TBPuzzle.png"], @selector(action))];
	
	// Add fixed 20 pixel width
	UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	bbi.width = 20.0f;
	[tbitems addObject:bbi];
	
	tb.items = tbitems;
	[self.view addSubview:tb];
	[tb release];*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    menuBarItem = nil;
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
