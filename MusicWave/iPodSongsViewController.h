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
//#import "MyGraphView.h"
#import "MBProgressHUD.h"
#import "Song.h"
#import "V8HorizontalPickerView.h"
@class MyMediaPickerDelegate;
@class MyScrollView;
@class GradientButton;
@class PlayListViewController;
@class MusicTableViewController;
@class AutoScrollLabel;
enum playBackState { playBackStateNone = 0, playBackStatePlaying, playBackStatePaused };

@interface iPodSongsViewController : UIViewController <MBProgressHUDDelegate, UIScrollViewDelegate, V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource, UINavigationControllerDelegate>
{
    MPVolumeView *mpVolumeView;
    MyScrollView *myScrollView;
    NSTimer *updateTimer;
    NSTimer *playbackTimer;
    NSMutableArray *bookMarkArray;
    Song *currentSong;
    UIButton *minimizeButton;
    UIButton *maximizeButton;
    UIButton *playOrPauseButton;
    UIButton *forwardButton;
    UIButton *rewindButton;
    UILabel *playbackTimeLabel;
    UILabel *remainTimeLabel;
    UILabel *startTimeLabel;
    UILabel *endTimeLabel;
    AutoScrollLabel *songTitleLabel;
    AutoScrollLabel *songArtistLabel;
    AutoScrollLabel *albumTitleLabel;
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
    MPVolumeView *volumeView;
    //BOOL selectedCurrentSong;
    UIView *songDataView;
    UIImageView *leftBackGround;
    UIImageView *rightBackGround;
    UIImageView *graphBackGround;
    UIImageView *graphBelowBackGround;
    UIImageView *soundBackGround;
    UIImageView *aboveBar;
    UIImageView *belowBar;
    CGRect leftPickerPortraitFrame;
    CGRect leftPickerBgPortraitFrame;
    CGRect rightPickerPortraitFrame;
    CGRect rightPickerBgPortraitFrame;
    CGRect mainButtonPortraitFrame;
    CGRect minimizeButtonPortraitFrame;
    CGRect rewindButtonPortraitFrame;
    CGRect playOrPauseButtonPortraitFrame;
    CGRect forwardButtonPortraitFrame;
    CGRect maximizeButtonPortraitFrame;
    CGRect aboveBarPortraitFrame;
    CGRect graphBackGroundPortraitFrame;
    CGRect belowBarPortraitFrame;
    CGRect startTimeLabelPortraitFrame;
    CGRect endTimeLabelPortraitFrame;
    CGRect playbackTimeLabelPortraitFrame;
    CGRect remainTimeLabelPortraitFrame;
    CGRect graphBelowBackGroundPortraitFrame;
    CGRect scrollViewPortraitFrame;
    CGRect repeatButtonPortraitFrame;
    CGRect volumeViewPortraitFrame;
}
@property (nonatomic, retain) MyScrollView *myScrollView;
//@property (nonatomic, strong) MyGraphView *myGraphView;
@property (nonatomic, retain) UIImage *graphImage;
//@property (nonatomic, retain) UIView *graphView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *bookMarkArray;
@property (nonatomic, retain) Song *currentSong;
//@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UILabel *playbackTimeLabel;
@property (nonatomic, retain) UILabel *remainTimeLabel;
@property (nonatomic, retain) UILabel *startTimeLabel;
@property (nonatomic, retain) UILabel *endTimeLabel;
@property (nonatomic, retain) UIButton *mainButton;
@property (nonatomic, retain) V8HorizontalPickerView *startPickerView;
@property (nonatomic, retain) V8HorizontalPickerView *endPickerView;
@property (nonatomic, retain) PlayListViewController *playListViewController;
@property (nonatomic, retain) AVPlayer *avPlayer;
@property (nonatomic, readwrite) enum playBackState playState;
//@property (nonatomic, retain) UIImageView *repeatModeView;
@property (nonatomic, retain) AutoScrollLabel *songTitleLabel;
@property (nonatomic, retain) AutoScrollLabel *songArtistLabel;
@property (nonatomic, retain) AutoScrollLabel *albumTitleLabel;
@property (nonatomic, assign) CGFloat startPickerTime;
@property (nonatomic, assign) CGFloat endPickerTime;
@property (nonatomic, assign) CGFloat delta;
@property (nonatomic, retain) UIImageView *aboveBar;
@property (nonatomic, retain) UIImageView *graphBackGround;
//@property (nonatomic, assign) BOOL selectedCurrentSong;
//- (IBAction) selectSongs: (id)sender;
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
@end
