//
//  MusicListDetailViewController.m
//  MusicWave
//
//  Created by Nam Hoon on 13. 1. 18..
//
//

#import "MusicListDetailViewController.h"
#import "Song.h"

#define TMP NSTemporaryDirectory()
#define imgExt @"png"
@interface MusicListDetailViewController ()

@end

@implementation MusicListDetailViewController
@synthesize currentSong;
@synthesize navItem;
@synthesize fileName, creationDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
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

- (IBAction)graphDeleteAction:(id)sender
{
    if (currentSong.doneGraphDrawing)
    {
        [self removeGraphImage:currentSong.graphPath];
        currentSong.doneGraphDrawing = NO;
        
        //Reset current UI Here.
        graphImageView.image = nil;
        self.fileNameLabel.text = nil;
        self.notFoundLabel.text = @"File Not Found";
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
- (UIImage *) getCachedImage
{
    NSNumber * libraryId = currentSong.persistentId;
    NSString *assetPictogramFilename = [NSString stringWithFormat:@"asset_%@.%@",libraryId,imgExt];
    
    NSString *uniquePath = [TMP stringByAppendingPathComponent: assetPictogramFilename];
    
    UIImage *image = nil;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        NSLog(@"File exists on cache:%@", uniquePath);
        fileName = assetPictogramFilename;
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:uniquePath error:nil];
        
        if (attrs != nil) {
            creationDate = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        }
        else {
            NSLog(@"attribut error not found");
        }

    }
    else
    {
        NSLog(@"No File exists on cache:%@", uniquePath);
    }
    
    return image;
}
- (void) goMusicTable
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navBar setBackgroundImage:[UIImage imageNamed:@"nav_bar2.png"] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithRed:34.0/255.0f green:33.0/255.0f blue:29.0/255.0f alpha:1.0];

    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftBarButton.frame = CGRectMake(0.0f, 0.0f, 37.0f, 38.0f);
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateNormal];
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateSelected];
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"stichClose.png"] forState:UIControlStateHighlighted];
    [leftBarButton addTarget:self action:@selector(goMusicTable) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    self.navItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    self.albumImageView.image = currentSong.artworkImage;
    self.artistLabel.text = currentSong.songArtist;
    self.albumLabel.text = currentSong.songAlbum;
    UInt32 duration = [currentSong.songDuration floatValue] * 100;
    UInt32 minutes = duration / (60 * 100);
    UInt32 seconds = (duration / 100)  - (minutes * 60);

    self.durationLabel.text = [NSString stringWithFormat: @"%02ldmin %02ldsec", minutes, seconds];
    
    [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    navItem.title = @"Info";
    graphImageView = [[UIImageView alloc] initWithFrame:self.graphBgImageView.frame];
    graphImageView.image = nil;
    graphImageView.backgroundColor = [UIColor clearColor];
    if (currentSong.doneGraphDrawing)
    {
        graphImageView.image = [self getCachedImage];
        self.notFoundLabel.text = nil;
        self.fileNameLabel.text = [NSString stringWithFormat:@"Filename: %@", self.fileName];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        self.createDateLabel.text = [NSString stringWithFormat:@"Created: %@", [formatter stringForObjectValue:self.creationDate]];
        [formatter release];
    }
    else
    {
        self.notFoundLabel.text = @"No Graph Found";
        self.trashBarButtonItem.enabled = NO;
    }
    [self.view addSubview:graphImageView];
    [graphImageView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [navItem release];
    [_navBar release];
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
    [super dealloc];
}
- (void)viewDidUnload {
    [self setNavItem:nil];
    [self setNavBar:nil];
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
    [super viewDidUnload];
}
@end
