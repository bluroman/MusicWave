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
@end
