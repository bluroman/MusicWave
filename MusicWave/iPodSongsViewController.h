//
//  iPodSongsViewController.h
//  iPodSongs
//
//  Created by hun nam on 11. 5. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MyGraphView.h"
#import "MBProgressHUD.h"
#import "Song.h"
#import "V8HorizontalPickerView.h"
@class MyMediaPickerDelegate;
@class MyScrollView;
@class GradientButton;
@class PlayListViewController;
@class MusicTableViewController;
enum playBackState { playBackStateNone = 0, playBackStatePlaying, playBackStatePaused };

@interface iPodSongsViewController : UIViewController <MBProgressHUDDelegate, UIScrollViewDelegate, V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource, UINavigationControllerDelegate>
{
    MyMediaPickerDelegate *mediaControllerDelegate;
    MyGraphView *graphView;
    MPVolumeView *mpVolumeView;
    MyScrollView *scrollView;
    NSTimer *updateTimer;
    NSTimer *playbackTimer;
    //NSMutableArray *songArray;
    //NSMutableArray *viewInfoArray;
    NSMutableArray *bookMarkArray;
    Song *currentSong;
    MBProgressHUD *HUD;
    IBOutlet UIToolbar *toolBar;
    UILabel *playbackTimeLabel;
    UILabel *startTimeLabel;
    UILabel *endTimeLabel;
    UILabel *samplingRateLabel;
    UILabel *totalTimeLabel;
    UIView *titleView;
    UILabel *songTitleLabel;
    UILabel *songArtistLabel;
    IBOutlet UIButton *mainButton;
    V8HorizontalPickerView *startPickerView;
    V8HorizontalPickerView *endPickerView;
    PlayListViewController *playListViewController;
    AVPlayer *avPlayer;
    enum playBackState playState;
    BOOL repeatMode;
    UIBackgroundTaskIdentifier bgTaskId;
    id timeObserver;
    UIImageView *repeatModeView;
    NSManagedObjectContext *managedObjectContext;
    CGFloat startPickerPosition;
    CGFloat endPickerPosition;
    BOOL movingOffset;
    //BOOL selectedCurrentSong;
}
@property (nonatomic, retain) MyMediaPickerDelegate *mediaControllerDelegate;
@property (nonatomic, retain) IBOutlet UIView *graphView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, retain) NSMutableArray *songArray;
//@property (nonatomic, retain) NSMutableArray *viewInfoArray;
@property (nonatomic, retain) NSMutableArray *bookMarkArray;
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *playbackTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *startTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *endTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *samplingRateLabel;
@property (nonatomic, retain) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, retain) IBOutlet UIButton *mainButton;
@property (nonatomic, retain) V8HorizontalPickerView *startPickerView;
@property (nonatomic, retain) V8HorizontalPickerView *endPickerView;
@property (nonatomic, retain) PlayListViewController *playListViewController;
@property (nonatomic, retain) AVPlayer *avPlayer;
@property (nonatomic, readwrite) enum playBackState playState;
@property (nonatomic, retain) UIImageView *repeatModeView;
@property (nonatomic, retain) UILabel *songTitleLabel;
@property (nonatomic, retain) UILabel *songArtistLabel;
@property (nonatomic, assign) CGFloat startPickerPosition;
@property (nonatomic, assign) CGFloat endPickerPosition;
//@property (nonatomic, assign) BOOL selectedCurrentSong;
- (IBAction) selectSongs: (id)sender;
- (IBAction) tapMainButton: (id)sender;

- (void) updatePosition;
- (void) pause;
- (void) play;
- (void) unregisterTimeObserver;
- (void) extractDataFromAsset:(AVURLAsset *)songAsset;
- (void) setCurrentPostion: (CGFloat)value;
- (void) loadComplete: (id)total;
-(void) createPlaybackTimer;
- (void) drawingCurrentGraphView;
- (void) updateCurrentSong;
-(void) setUpAVPlayerForURL: (NSURL*) url;
- (void) musicTableViewControllerDidFinish: (UIViewController *) controller;
- (void) deleteCurrentSong;
- (int) restorePickerIndex:(NSNumber *)position;
- (void)startDrawingCurrentGraphViewThread;
@end
