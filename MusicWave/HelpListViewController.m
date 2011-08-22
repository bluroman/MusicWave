//
//  HelpListViewController.m
//  MusicWave
//
//  Created by Nam Hoon on 11. 8. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpListViewController.h"
#import "HelpListTableViewCell.h"

#import "SectionInfo.h"
#import "SectionHeaderView.h"
#import "Help.h"
#import "Tutorial.h"

#define DEFAULT_ROW_HEIGHT 322
#define HEADER_HEIGHT 56
#define NAVIGATION_BAR_COLOR    [UIColor colorWithRed:200.0/255.0f green:204.0/255.0f blue:211.0/255.0f alpha:1.0f]



@implementation HelpListViewController
@synthesize helpListTable, helps;
@synthesize sectionInfoArray, uniformRowHeight, initialPinchHeight, pinchedIndexPath, openSectionIndex;
@synthesize navigationBar, navigationItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)dealloc
{
    [helpListTable release];
    [helps release];
    [sectionInfoArray release];
    [pinchedIndexPath release];
    [navigationBar release];
    [navigationItem release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (IBAction) doneShowingHelpList: (id) sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"help list view did load");
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"current language:%@", language);
    //if([language isEqualToString:@"ko"])
        //NSLog(@"current string equal to ko");
    //else
        //NSLog(@"current string not equal to ko");
    
    self.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
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
    titleLabel.text = NSLocalizedString(@"Help", @"Help List Title");
    titleLabel.highlightedTextColor = [UIColor blackColor];
    [titleView addSubview:titleLabel];
    [titleLabel release];
    //[label release];
    
    self.navigationItem.titleView = titleView;
    [titleView release];
    
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
    
    [leftBarButton addTarget:self action:@selector(doneShowingHelpList:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    //[leftBarButton release];
    
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    self.helpListTable.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:241.0/255.0f blue:243.0/255.0f alpha:1.0];
    
    self.helpListTable.sectionHeaderHeight = HEADER_HEIGHT;
	/*
     The section info array is thrown away in viewWillUnload, so it's OK to set the default values here. If you keep the section information etc. then set the default values in the designated initializer.
     */
    self.uniformRowHeight = DEFAULT_ROW_HEIGHT;
    self.openSectionIndex = NSNotFound;
    
    if ((self.sectionInfoArray == nil) || ([self.sectionInfoArray count] != [self numberOfSectionsInTableView:self.helpListTable])) {
		
        // For each play, set up a corresponding SectionInfo object to contain the default height for each row.
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
		
		for (Help *help in self.helps) {
			
			SectionInfo *sectionInfo = [[SectionInfo alloc] init];			
			sectionInfo.help = help;
			sectionInfo.open = NO;
			
            NSNumber *defaultRowHeight = [NSNumber numberWithInteger:DEFAULT_ROW_HEIGHT];
			NSInteger countOfQuotations = [[sectionInfo.help tutorials] count];
			for (NSInteger i = 0; i < countOfQuotations; i++) {
				[sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
			}
			
			[infoArray addObject:sectionInfo];
			[sectionInfo release];
		}
		
		self.sectionInfoArray = infoArray;
        for (int i = 0; i < [sectionInfoArray count]; i++) {
            SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:i];
            NSLog(@"Title:%@", sectionInfo.help.title);
        }
		[infoArray release];
	}

}
- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated]; 
    //NSLog(@"help list view will appear");
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.helpListTable = nil;
    self.sectionInfoArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    //NSLog(@"sections count:%d", [self.helps count]);
    
    return [self.helps count];
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
	NSInteger numStoriesInSection = [[sectionInfo.help tutorials] count];
	
    return sectionInfo.open ? numStoriesInSection : 0;
}
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    static NSString *CellIdentifier = @"HelpListViewCellIdentifier";
    
    HelpListTableViewCell *cell = (HelpListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[HelpListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Help *help = (Help *)[[self.sectionInfoArray objectAtIndex:indexPath.section] help];
    cell.tutorial = [help.tutorials objectAtIndex:indexPath.row];
    
    return cell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    /*
     Create the section header views lazily.
     */
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (!sectionInfo.headerView) {
		NSString *titleName = sectionInfo.help.title;
        //NSLog(@"Title Name:%@ %i", titleName, section);
        sectionInfo.headerView = [[[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.helpListTable.bounds.size.width, HEADER_HEIGHT) title:titleName section:section delegate:self] autorelease];
    }
    
    return sectionInfo.headerView;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
    return [[sectionInfo objectInRowHeightsAtIndex:indexPath.row] floatValue];
    // Alternatively, return rowHeight.
}
#pragma mark Section header delegate

-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionOpened];
	
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.help.tutorials count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
		
		SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.help.tutorials count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // Apply the updates.
    [self.helpListTable beginUpdates];
    [self.helpListTable insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.helpListTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.helpListTable endUpdates];
    self.openSectionIndex = sectionOpened;
    
    [indexPathsToInsert release];
    [indexPathsToDelete release];
}


-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionClosed];
	
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.helpListTable numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.helpListTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
        [indexPathsToDelete release];
    }
    self.openSectionIndex = NSNotFound;
}


@end
