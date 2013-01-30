//
//  MusicListDetailViewController.m
//  MusicWave
//
//  Created by Nam Hoon on 13. 1. 18..
//
//

#import "MusicListDetailViewController.h"
#import "Song.h"
#import "CommonUtil.h"

@interface MusicListDetailViewController ()

@end

@implementation MusicListDetailViewController
@synthesize currentSong;
@synthesize fileName, creationDate;
@synthesize isPlaying;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (IBAction)graphDeleteAction:(id)sender
{
    if (currentSong.doneGraphDrawing)
    {
        //[self removeGraphImage:currentSong.graphPath];
        [CommonUtil removeGraphImage:currentSong.graphPath];
        currentSong.doneGraphDrawing = NO;
        
        //Reset current UI Here.
        graphImageView.image = nil;
        self.fileNameLabel.text = nil;
        self.notFoundLabel.text = NSLocalizedString(@"No Graph Found", @"no graph found label");
        self.createDateLabel.text = nil;
        self.trashBarButtonItem.enabled = NO;
        
        NSManagedObjectContext *context = [self.currentSong managedObjectContext];
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (void) goMusicTable
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar2.png"] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithRed:34.0/255.0f green:33.0/255.0f blue:29.0/255.0f alpha:1.0];
    self.title = NSLocalizedString(@"Music Info", @"Music Info Title");

    /*UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftBarButton.frame = CGRectMake(0.0f, 0.0f, 37.0f, 38.0f);
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateNormal];
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateSelected];
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateHighlighted];
    [leftBarButton addTarget:self action:@selector(goMusicTable) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];*/
    if (self.isPlaying) {
        self.nowPlayingImageView.image = [UIImage imageNamed:@"list-volume.png"];
        self.trashBarButtonItem.enabled = NO;
    }
    
    
    if (currentSong.artworkImage == nil) {
        self.albumImageView.image = [UIImage imageNamed:@"artist_img.png"];
    }
    else self.albumImageView.image = currentSong.artworkImage;
    
    self.artistLabel.text = currentSong.songArtist;
    self.albumLabel.text = currentSong.songAlbum;
    UInt32 duration = [currentSong.songDuration floatValue] * 100;
    UInt32 minutes = duration / (60 * 100);
    UInt32 seconds = (duration / 100)  - (minutes * 60);

    self.durationLabel.text = [NSString stringWithFormat: @"%02ldmin %02ldsec", minutes, seconds];
    
    [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back_landscape.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsLandscapePhone];
    self.toolBar.autoresizingMask = self.toolBar.autoresizingMask | UIViewAutoresizingFlexibleHeight;

    graphImageView = [[UIImageView alloc] initWithFrame:self.graphBgImageView.frame];
    graphImageView.image = nil;
    graphImageView.backgroundColor = [UIColor clearColor];
    if (currentSong.doneGraphDrawing)
    {
        //graphImageView.image = [self getCachedImage];
        graphImageView.image = [CommonUtil getCachedImage:currentSong.persistentId];
        self.creationDate = [CommonUtil assetCreationDate:currentSong.persistentId];
        self.fileName = [CommonUtil assetPictogramFileName:currentSong.persistentId];
        self.notFoundLabel.text = nil;
        self.fileNameLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Filename", @"graph file label"), self.fileName];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        self.createDateLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Created", @"file creation date label"), [formatter stringForObjectValue:self.creationDate]];
        [formatter release];
    }
    else
    {
        self.notFoundLabel.text = NSLocalizedString(@"No Graph Found", @"no graph found label");
        self.trashBarButtonItem.enabled = NO;
    }
    [self.view addSubview:graphImageView];
    //[graphImageView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //[navItem release];
    [currentSong release];
    [_albumImageView release];
    [_artistLabel release];
    [_albumLabel release];
    [_durationLabel release];
    [_graphBgImageView release];
    [graphImageView release];
    
    [_toolBar release];
    [_fileNameLabel release];
    [_createDateLabel release];
    [_notFoundLabel release];
    [_trashBarButtonItem release];
    [_nowPlayingImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setAlbumImageView:nil];
    [self setArtistLabel:nil];
    [self setAlbumLabel:nil];
    [self setDurationLabel:nil];
    [self setGraphBgImageView:nil];
    [self setToolBar:nil];
    [self setFileNameLabel:nil];
    [self setCreateDateLabel:nil];
    [self setNotFoundLabel:nil];
    [self setTrashBarButtonItem:nil];
    [self setNowPlayingImageView:nil];
    [super viewDidUnload];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self layoutByOrientation];
}
- (void) layoutByOrientation {
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGSize size = bounds.size;
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        NSLog(@"Portrait mode");
        NSLog(@"Artist Label frame: width %f, height %f origin %f %f", self.artistLabel.frame.size.width, self.artistLabel.frame.size.height, self.artistLabel.frame.origin.x, self.artistLabel.frame.origin.y);
        NSLog(@"Album Label frame: width %f, height %f origin %f %f", self.albumLabel.frame.size.width, self.albumLabel.frame.size.height, self.albumLabel.frame.origin.x, self.albumLabel.frame.origin.y);
        NSLog(@"Duration Label frame: width %f, height %f origin %f %f", self.durationLabel.frame.size.width, self.durationLabel.frame.size.height, self.durationLabel.frame.origin.x, self.durationLabel.frame.origin.y);
        NSLog(@"Now Playing image frame: width %f, height %f origin %f %f", self.nowPlayingImageView.frame.size.width, self.nowPlayingImageView.frame.size.height, self.nowPlayingImageView.frame.origin.x, self.nowPlayingImageView.frame.origin.y);
        NSLog(@"Graph Bg frame: width %f, height %f origin %f %f", self.graphBgImageView.frame.size.width, self.graphBgImageView.frame.size.height, self.graphBgImageView.frame.origin.x, self.graphBgImageView.frame.origin.y);
        self.albumImageView.frame = CGRectMake(3, 4, 80, 80);
        self.artistLabel.frame = CGRectMake(86, 4, 234, 21);
        self.albumLabel.frame = CGRectMake(86, 26, 234, 21);
        self.durationLabel.frame = CGRectMake(86, 63, 132, 21);
        self.nowPlayingImageView.frame = CGRectMake(277, 63, 23, 16);
        graphImageView.frame = CGRectMake(0, 89, 320, 171);
        self.notFoundLabel.frame = CGRectMake(0, 164, 320, 21);
        self.fileNameLabel.frame = CGRectMake(3, 268, 317, 21);
        self.createDateLabel.frame = CGRectMake(3, 288, 317, 21);
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size.width = bounds.size.height;
        size.height = bounds.size.width;
        NSLog(@"Landscape mode");
        NSLog(@"Artist Label frame: width %f, height %f origin %f %f", self.artistLabel.frame.size.width, self.artistLabel.frame.size.height, self.artistLabel.frame.origin.x, self.artistLabel.frame.origin.y);
        self.albumImageView.frame = CGRectMake(3, 4, 40, 40);
        self.artistLabel.frame = CGRectMake(46, 4, 234, 21);
        self.albumLabel.frame = CGRectMake(46, 26, 234, 21);
        self.durationLabel.frame = CGRectMake(300, 4, 132, 21);
        self.nowPlayingImageView.frame = CGRectMake(300, 26, 23, 16);
        graphImageView.frame = CGRectMake(0, 49, size.width, 150);
        self.notFoundLabel.frame = CGRectMake(0, 91, size.width, 21);
        self.fileNameLabel.frame = CGRectMake(3, 200, 317, 21);
        self.createDateLabel.frame = CGRectMake(3, 220, 317, 21);
    }
    else NSLog(@"Other mode");
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSLog(@"willRotateTo:%d", orientation);
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"Go To:%d", toInterfaceOrientation);
    // we grab the screen frame first off; these are always
    // in portrait mode
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGSize size = bounds.size;
    //CGRect startPickerPortraitFrame = CGRectZero;
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog(@"Detail List current orientation:%d", orientation);
    }
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // we're going to landscape, which means we gotta swap them
        size.width = bounds.size.height;
        size.height = bounds.size.width;
    }
    [self layoutByOrientation];
    
    //[self layoutByOrientation];
    // size is now the width and height that we will have after the rotation
    NSLog(@"orientation %d size: w:%f h:%f", toInterfaceOrientation, size.width, size.height);
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    NSLog(@"detail list autorotaion:%d", interfaceOrientation);
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
