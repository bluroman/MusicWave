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
    MyGraphView *graphView;
    MPVolumeView *mpVolumeView;
    MyScrollView *scrollView;
    NSTimer *updateTimer;
    NSTimer *playbackTimer;
    NSMutableArray *bookMarkArray;
    Song *currentSong;
    IBOutlet UIToolbar *toolBar;
    UILabel *playbackTimeLabel;
    UILabel *remainTimeLabel;
    //UILabel *startTimeLabel;
    //UILabel *endTimeLabel;
    //UILabel *samplingRateLabel;
    //UILabel *totalTimeLabel;
    UILabel *songTitleLabel;
    UILabel *songArtistLabel;
    //UISlider *mainSlider;
    IBOutlet UIButton *mainButton;
    UIButton *repeatButton;
    V8HorizontalPickerView *startPickerView;
    V8HorizontalPickerView *endPickerView;
    PlayListViewController *playListViewController;
    AVPlayer *avPlayer;
    enum playBackState playState;
    BOOL repeatMode;
    UIBackgroundTaskIdentifier bgTaskId;
    id timeObserver;
    //UIImageView *repeatModeView;
    NSManagedObjectContext *managedObjectContext;
    CGFloat startPickerTime;
    CGFloat endPickerTime;
    CGFloat delta;
    CGFloat maximumWidth;
    BOOL movingOffset;
    UIImage *graphImage;
    //BOOL selectedCurrentSong;
}
@property (nonatomic, strong) MyScrollView *myScrollView;
@property (nonatomic, strong) MyGraphView *myGraphView;
@property (nonatomic, retain) UIImage *graphImage;
@property (nonatomic, retain) UIView *graphView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *bookMarkArray;
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UILabel *playbackTimeLabel;
@property (nonatomic, retain) UILabel *remainTimeLabel;
//@property (nonatomic, retain) IBOutlet UILabel *startTimeLabel;
//@property (nonatomic, retain) IBOutlet UILabel *endTimeLabel;
//@property (nonatomic, retain) IBOutlet UILabel *samplingRateLabel;
//@property (nonatomic, retain) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, retain) UIButton *mainButton;
@property (nonatomic, retain) V8HorizontalPickerView *startPickerView;
@property (nonatomic, retain) V8HorizontalPickerView *endPickerView;
@property (nonatomic, retain) PlayListViewController *playListViewController;
@property (nonatomic, retain) AVPlayer *avPlayer;
@property (nonatomic, readwrite) enum playBackState playState;
//@property (nonatomic, retain) UIImageView *repeatModeView;
@property (nonatomic, retain) UILabel *songTitleLabel;
@property (nonatomic, retain) UILabel *songArtistLabel;
@property (nonatomic, assign) CGFloat startPickerTime;
@property (nonatomic, assign) CGFloat endPickerTime;
@property (nonatomic, assign) CGFloat delta;
//@property (nonatomic, assign) BOOL selectedCurrentSong;
- (IBAction) selectSongs: (id)sender;
- (IBAction) tapMainButton: (id)sender;

- (void) updatePosition;
- (void) pause;
- (void) play;
- (void) unregisterTimeObserver;
- (void) setCurrentPostion: (int)value;
-(void) createPlaybackTimer;
- (void) updateCurrentSong;
-(void) setUpAVPlayerForURL: (NSURL*) url;
- (void) musicTableViewControllerDidFinish: (UIViewController *) controller;
- (void) deleteCurrentSong;
- (void) cacheImage;
- (UIImage *) getCachedImage;
@end
