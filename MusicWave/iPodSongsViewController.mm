//
//  iPodSongsViewController.m
//  iPodSongs
//
//  Created by hun nam on 11. 5. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iPodSongsViewController.h"
#import "MyMediaPickerDelegate.h"
#import "ViewInfo.h"
#import "MusicWaveAppDelegate.h"
#import "MyScrollView.h"
//#import "PlayListViewController.h"
#import "BookMarkViewController.h"
#import "MusicTableViewController.h"
#import "BookMark.h"
@interface UINavigationBar (CustomHeight)

@end

@implementation UINavigationBar (CustomHeight)

- (CGSize)sizeThatFits:(CGSize)size {
    // Change navigation bar height. The height must be even, otherwise there will be a white line above the navigation bar.
    CGSize newSize = CGSizeMake(self.frame.size.width, 62);
    return newSize;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    

    // Make items on navigation bar vertically centered.
    int i = 0;
    for (UIView *view in self.subviews) {
        //NSLog(@"%i. %@", i++, [view description]);
        i++;
        if (i == 0)
            continue;
        float centerY = self.bounds.size.height / 2.0f;
        CGPoint center = view.center;
        center.y = centerY;
        view.center = center;
    }
}
@end
#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:208.0/255.0f green:208.0/255.0f blue:208.0/255.0f alpha:1.0f]
#define NAVIGATION_BAR_COLOR    [UIColor colorWithRed:200.0/255.0f green:204.0/255.0f blue:211.0/255.0f alpha:1.0f]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define IMGBARBUTTON(IMAGE, SELECTOR) [[[UIBarButtonItem alloc] initWithImage:IMAGE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define STATUSBAR_HEIGHT    20

@implementation iPodSongsViewController
@synthesize mediaControllerDelegate, graphView, scrollView;
@synthesize currentSong;
@synthesize playbackTimeLabel;
@synthesize remainTimeLabel;
//@synthesize startTimeLabel, endTimeLabel;
//@synthesize samplingRateLabel; //totalTimeLabel;
@synthesize mainButton;
@synthesize startPickerView, endPickerView;
@synthesize playListViewController;
@synthesize avPlayer;
@synthesize playState;
@synthesize bookMarkArray;
@synthesize repeatModeView;
@synthesize songTitleLabel, songArtistLabel;
@synthesize managedObjectContext;
@synthesize startPickerPosition, endPickerPosition;
//@synthesize selectedCurrentSong;

- (void)startDrawingCurrentGraphViewThread {
    //[self.view setAlpha:0.7f];
    
    [self drawingCurrentGraphViewDispatchQueue];
    
    //[NSThread detachNewThreadSelector:@selector(drawingCurrentGraphView) toTarget:self withObject:nil];
}
- (void)loadComplete:(id)total {
    int pixelCount = [total intValue];
    NSLog(@"Graph pixel count:%d", pixelCount);
    if (pixelCount > 320) {
        [self.myScrollView setContentSize:CGSizeMake(pixelCount, self.myGraphView.bounds.size.height)];
        [self.myGraphView setFrame:CGRectMake(0, 0, pixelCount, self.myGraphView.bounds.size.height)];
    }
    else {
        [self.myScrollView setContentSize:CGSizeMake(pixelCount, self.myGraphView.bounds.size.height)];
        [self.myGraphView setFrame:CGRectMake(0, 0, pixelCount, self.myGraphView.bounds.size.height)];
    }
    
    [self.myGraphView setUpBookMarkLayer];
    self.myScrollView.contentOffset = CGPointMake(0.0, 0.0);
    [self.myGraphView settingStartEndPosition:startPickerPosition endPosition:endPickerPosition];
    [self.myGraphView setNeedsDisplay];
    [self setUpAVPlayerForURL:[NSURL URLWithString:currentSong.songURL]];
    [self.startPickerView scrollToElement:0 animated:NO];
    [self.endPickerView scrollToElement:0 animated:NO];
    
    //[HUD hide:YES];
    //[self.view setAlpha:1.0f];
}
- (void) addGraphViewArray {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"x" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
    NSMutableArray *tempViewInfoArray = [[NSMutableArray alloc] initWithArray:[currentSong.viewinfos allObjects]];
    [tempViewInfoArray sortUsingDescriptors:sortDescriptors];
    
    self.myGraphView.viewInfoArray = tempViewInfoArray;
    /*for (int i=0; i < [self.myGraphView.viewInfoArray count]; i++) {
     ViewInfo *printInfo = [self.myGraphView.viewInfoArray objectAtIndex:i];
     NSLog(@"max:%f, x:%f, d:%f", [printInfo.max floatValue], [printInfo.x floatValue], [printInfo.time floatValue]);
     }*/
    [sortDescriptor release];
	[sortDescriptors release];
    [tempViewInfoArray release];
}
- (void) extractDataFromAsset:(AVURLAsset *)songAsset {
    NSError * error = nil;
    UInt64 songSampleRate = 0;
    UInt64 channelsPerFrame = 0;
    UInt64 divisor = 100;
    int mod = 1;
    
    for (AVAssetTrack* track in songAsset.tracks) {
        CMFormatDescriptionRef fmt = (CMFormatDescriptionRef)[track.formatDescriptions objectAtIndex:0];
        AudioStreamBasicDescription* desc = (AudioStreamBasicDescription *)CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
        //NSLog(@"track samplerate:%f", desc->mSampleRate);
        //NSLog(@"track formatID:%lu", desc->mFormatID);
        //NSLog(@"track formatFlags:%lu", desc->mFormatFlags);
        //NSLog(@"track BytesPerPacket:%lu", desc->mBytesPerPacket);
        //NSLog(@"track BytesPerFrame:%lu", desc->mBytesPerFrame);
        //NSLog(@"track BitsPerChannel:%lu", desc->mBitsPerChannel);
        //NSLog(@"track FramesPerPacket:%lu", desc->mFramesPerPacket);
        //NSLog(@"track ChannelsPerFrame:%lu", desc->mChannelsPerFrame);
        //NSLog(@"track.enabled: %d", track.enabled);
        //NSLog(@"track.selfContained: %d", track.selfContained);
        songSampleRate = desc->mSampleRate;
        channelsPerFrame = desc->mChannelsPerFrame;
        if (channelsPerFrame == 1) {
            mod = 2;
        }
    }
    AVAssetReader * reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    
    AVAssetTrack * songTrack = [songAsset.tracks objectAtIndex:0];
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        //     [NSNumber numberWithInt:44100.0],AVSampleRateKey, /*Not Supported*/
                                        //     [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,    /*Not Supported*/
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
   
    AVAssetReaderTrackOutput * output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    [output release];
    
    CMTime duration = CMTimeMakeWithSeconds(CMTimeGetSeconds(songAsset.duration), 1.0);
    
    CMTime start = CMTimeMakeWithSeconds(0.0, 1.0);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    reader.timeRange = range;
    int remaining = -1, count = 0, remaining_count = 0, totalSize = 0, first = 1;
    int len = songSampleRate / divisor;
    int mMaxSamples = (songSampleRate / len) * (CMTimeGetSeconds(songAsset.duration) / mod);
    
    CGFloat *temp = new CGFloat[mMaxSamples];
    for (int i = 0; i < mMaxSamples; i++) {
        temp[i] = 0.;
    }
    int i = 0;
    float progress = 0.;
    
    [reader startReading];
    //NSLog(@"start reading reader status:%d", reader.status);
    while (reader.status == AVAssetReaderStatusReading){
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        if (sampleBufferRef){
            AudioBufferList audioBufferList;
            CMBlockBufferRef blockBufferRef;
            
            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBufferRef, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBufferRef);
            if (audioBufferList.mNumberBuffers == 1) {
                AudioBuffer audioBuffer = audioBufferList.mBuffers[0];
                int bufferSize = audioBuffer.mDataByteSize / sizeof(Float32);
                
                SInt16 *frame = (SInt16 *)audioBuffer.mData;
                int position = 0, flag = 0, start = 0;
                NSLog(@"buffersize:%d, databytesize:%ld", bufferSize, audioBuffer.mDataByteSize);
                totalSize += bufferSize;
                if (remaining > 0) {
                    
                    start = len - remaining - 1; 
                    flag = 1;
                    //NSLog(@"start remaining:%d, start position:%d", remaining, start);
                }
                while (position < bufferSize) {
                    if (flag == 1) {
                        count++;
                        flag = 0;
                        position += start;
                        
                        //NSLog(@"4410th frame:%f at position:%d", frame[position] / 32768.0f, position);
                        temp[i] = frame[position] / 32768.0f;
                        i++;
                    }
                    if (first == 1) {
                        position += len - 1;
                        first = 0;
                    }
                    else position += len ;
                    if (position < bufferSize) {
                        count++;
                        //NSLog(@"4410th frame:%f at position:%d", frame[position] / 32768.0f, position);
                        temp[i] = frame[position] / 32768.0f;
                        i++;
                    }
                    remaining = bufferSize - position - 1;
                    
                    //NSLog(@"Remaining:%d", remaining);
                    if (remaining == len || remaining == 0) {
                        remaining_count++;
                        //NSLog(@"remaing lost:%d", remaining_count);
                    }
                    if (remaining < len) break;
                }
                //float percent = 100.0 * (float)i/mMaxSamples;
                //NSLog(@"Progress:%f ,%i, %i, %f, %d", (float)i/mMaxSamples, i, mMaxSamples, percent, (int)percent);
                progress = (float)i / mMaxSamples;
                //HUD.detailsLabelText = [NSString stringWithFormat:@"%d%%", (int)percent];
                
            }

            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
            CFRelease(blockBufferRef);
            
            //HUD.progress = (float)(i / mMaxSamples);
        }
        NSLog(@"reader status:%d total:%d, sample count:%d, remaining_lost:%d", reader.status, totalSize, count, remaining_count);
    }
    if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown){
        // Something went wrong. return nil
        NSLog(@"Something went wrong");
        
        return;
    }
    if (reader.status == AVAssetReaderStatusCompleted) {
        //NSLog(@"completed reading");
        //progress = 1.0f;
        //HUD.progress = 1.0f;
        //HUD.detailsLabelText = [NSString stringWithFormat:@"%d%%", 100];
    }
    CGFloat min=0., max=0., sumsq = 0., rms = 0., d = 0.;
    int j = 0;
    CGFloat pixel = 0.;
    int sampling = 10;
    if (mod == 2) {
        sampling = 10 / mod;
    }
    //NSLog(@"start graph");
    //HUD.mode = MBProgressHUDModeIndeterminate;
    //HUD.labelText = NSLocalizedString(@"Drawing", @"Main View Hud drawing label");
    //HUD.detailsLabelText = NSLocalizedString(@"Graph", @"Main View Hud drawing detail label");
    NSManagedObjectContext *context = [currentSong managedObjectContext];
    while (j < mMaxSamples) {
        //ViewInfo *currentInfo = [ViewInfo alloc];
        ViewInfo *currentInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ViewInfo" inManagedObjectContext:context];
        int i = 0;
        min = temp[j];
        max = temp[j];
        sumsq = temp[j] * temp[j];
        for ( i = j + 1; i < j + sampling; i++) {
            CGFloat current = temp[i];
            if (current < min) {
                min = current;
            }
            if (current > max) {
                max = current;
            }
            sumsq += current * current;
        }
        rms = sqrt(sumsq / sampling);
        d += 10.0 / (songSampleRate/len) ;
        pixel++;
        if (min < -1.0f or min > 1.0f) {
            min = 0.f;
        }
        if (max < -1.0f or max > 1.0f) {
            max = 0.f;
        }
        if (rms < -1.0f or rms > 1.0f) {
            rms = 0.f;
        }
        currentInfo.min = [NSNumber numberWithFloat:min];
        currentInfo.max = [NSNumber numberWithFloat:max];
        currentInfo.rms = [NSNumber numberWithFloat:rms];
        currentInfo.time = [NSNumber numberWithFloat:d];
        currentInfo.x = [NSNumber numberWithFloat:pixel];
        
        //[currentInfo print];
        //[self.myGraphView addViewInfo:currentInfo];
        [currentSong addViewinfosObject:currentInfo];
        //[currentInfo release];

        j += sampling;
    }
    delete[] temp;
    //NSLog(@"ending graph");
    //self.myGraphView.currentSong = currentSong;
    
    [self addGraphViewArray];
    currentSong.doneGraphDrawing = [NSNumber numberWithBool:YES];
    
    //NSManagedObjectContext *context = [currentSong managedObjectContext];
    //NSError *error = nil;
    
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        NSLog(@"Saving graph error");
        [reader release];
        [self deleteCurrentSong];
        
        return;
    }


    [reader release];
}
- (void)updateCurrentSong {
    if (playState == playBackStatePlaying) {
        [self pause];
    }
    self.myGraphView.currentSong = currentSong;
    UInt64 songSampleRate = 0;
    UInt64 channelsPerFrame = 0;
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:currentSong.songURL] options:nil];
    for (AVAssetTrack* track in songAsset.tracks) {
        CMFormatDescriptionRef fmt = (CMFormatDescriptionRef)[track.formatDescriptions objectAtIndex:0];
        AudioStreamBasicDescription* desc = (AudioStreamBasicDescription *)CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
        //NSLog(@"track samplerate:%f", desc->mSampleRate);
        //NSLog(@"track formatID:%lu", desc->mFormatID);
        //NSLog(@"track formatFlags:%lu", desc->mFormatFlags);
        //NSLog(@"track BytesPerPacket:%lu", desc->mBytesPerPacket);
        //NSLog(@"track BytesPerFrame:%lu", desc->mBytesPerFrame);
        //NSLog(@"track BitsPerChannel:%lu", desc->mBitsPerChannel);
        //NSLog(@"track FramesPerPacket:%lu", desc->mFramesPerPacket);
        //NSLog(@"track ChannelsPerFrame:%lu", desc->mChannelsPerFrame);
        //NSLog(@"track.enabled: %d", track.enabled);
        //NSLog(@"track.selfContained: %d", track.selfContained);
        songSampleRate = desc->mSampleRate;
        channelsPerFrame = desc->mChannelsPerFrame;
    }
    UInt64 songDuration = CMTimeGetSeconds(songAsset.duration);
	
	UInt32 minutes = songDuration / 60;
	UInt32 seconds = songDuration % 60;
	//totalTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
    //samplingRateLabel.text = [NSString stringWithFormat:@"%dHz", songSampleRate];
    self.songTitleLabel.text = currentSong.songTitle;
    self.songArtistLabel.text = currentSong.songArtist;
    playState = playBackStateNone;
    repeatMode = NO;
    self.startPickerPosition = 0.f;
    self.endPickerPosition = 0.f;
    if (timeObserver != nil) {
        [avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    movingOffset = NO;
    if (repeatMode) {
        repeatModeView.image = [UIImage imageNamed:@"repeat_on_test.png"];
    }
    else repeatModeView.image = [UIImage imageNamed:@"repeat_off_test.png"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keepDate" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortedBookMarks = [[NSMutableArray alloc] initWithArray:[currentSong.bookmarks allObjects]];
	[sortedBookMarks sortUsingDescriptors:sortDescriptors];
	self.bookMarkArray = sortedBookMarks;
    
    
	[sortDescriptor release];
	[sortDescriptors release];
	[sortedBookMarks release];

    [self startDrawingCurrentGraphViewThread];
    
}
- (void)drawingCurrentGraphViewDispatchQueue {
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    BOOL isGraphDrawing = [currentSong.doneGraphDrawing boolValue];
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    if (!isGraphDrawing) {
        HUD.labelText = NSLocalizedString(@"Loading", @"Main View Hud loading hud label");
        HUD.detailsLabelText = NSLocalizedString(@"Information", @"Main View Hud loading hud detail label");
    }
    else {
        HUD.labelText = NSLocalizedString(@"Drawing", @"Main View Hud drawing label");
        HUD.detailsLabelText = NSLocalizedString(@"Graph", @"Main View Hud drawing detail label");
    }
    //[HUD show:YES];
    
    dispatch_async(concurrentQueue, ^{
        //__block UIImage *image = nil;
        dispatch_sync(concurrentQueue, ^{
            //Download image
            if (!isGraphDrawing) {
                AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:currentSong.songURL] options:nil];
                [self extractDataFromAsset:songAsset];
            }
            else {
                [self addGraphViewArray];
            }
        });
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Show image to user
            id idVar = [NSNumber numberWithInt: [currentSong.viewinfos count]];
            [self loadComplete:idVar];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}
- (void)drawingCurrentGraphView {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    if (![currentSong.doneGraphDrawing boolValue]) {
        //HUD.mode = MBProgressHUDModeIndeterminate;
        //HUD.labelText = NSLocalizedString(@"Loading", @"Main View Hud loading hud label");
        
        //HUD.detailsLabelText = NSLocalizedString(@"Information", @"Main View Hud loading hud detail label");
        
        //[HUD show:YES];

        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:currentSong.songURL] options:nil];
        [self extractDataFromAsset:songAsset];
    }
    else {
        //HUD.mode = MBProgressHUDModeIndeterminate;
        //HUD.labelText = NSLocalizedString(@"Drawing", @"Main View Hud drawing label");
        //HUD.detailsLabelText = NSLocalizedString(@"Graph", @"Main View Hud drawing detail label");
        //[HUD show:YES];
        [self addGraphViewArray];
    }
    id idVar = [NSNumber numberWithInt: [currentSong.viewinfos count]];
	[self performSelectorOnMainThread:@selector(loadComplete:) withObject:idVar waitUntilDone:NO];
    [pool release];
}
- (void)deleteCurrentSong {
    //NSLog(@"delete currentSong in MainView");
    if (playState == playBackStatePlaying) {
        [self pause];
    }
    if (playbackTimer) {
		[playbackTimer invalidate];
        playbackTimer = nil;
    }
    self.currentSong = nil;
    movingOffset = NO;
    self.myGraphView.currentSong = self.currentSong;
    [self.myGraphView.viewInfoArray removeAllObjects];
    [self.bookMarkArray removeAllObjects];
    //totalTimeLabel.text = @"00:00";
    //samplingRateLabel.text = @"";
    playbackTimeLabel.text = @"00:00";
    remainTimeLabel.text = @"00.00";
    self.songTitleLabel.text = @"MusicWave";
    self.songArtistLabel.text = @"";
    playState = playBackStateNone;
    [startPickerView reloadData];
    [endPickerView reloadData];
    //NSLog(@"state none:%d line:%d", playState, __LINE__);
    repeatMode = NO;
    if (repeatMode) {
        repeatModeView.image = [UIImage imageNamed:@"repeat_on_test.png"];
    }
    else repeatModeView.image = [UIImage imageNamed:@"repeat_off_test.png"];
    [self.myScrollView setContentSize:CGSizeMake(280, self.myGraphView.bounds.size.height)];
    [self.myGraphView setFrame:CGRectMake(0, 0, 280, self.myGraphView.bounds.size.height)];
    [self.myGraphView setUpBookMarkLayer];
    self.myScrollView.contentOffset = CGPointMake(0.0, 0.0);
    [self.myGraphView setNeedsDisplay];
    if (timeObserver != nil) {
        [avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    [avPlayer release];
    avPlayer = nil;
    [toolBar setItems:nil];
}
- (void) unregisterTimeObserver{
    if (timeObserver != nil) {
        //NSLog(@"remove time observer %d", __LINE__);
        [avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }

}
- (void)registerTimeObserver {
    if (repeatMode) {
        ViewInfo *startViewInfo = nil;
        ViewInfo *endViewInfo = nil;
        CGFloat position = 0.;
        if (self.startPickerPosition != 0 && self.endPickerPosition != 0) {
            if (self.startPickerPosition  < self.endPickerPosition)
            {
                startViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:self.startPickerPosition];
                endViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:self.endPickerPosition];
                position = self.startPickerPosition;
            }
            else if (self.endPickerPosition < self.startPickerPosition) {
                startViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:self.endPickerPosition];
                endViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:self.startPickerPosition];
                position = self.endPickerPosition;
            }
            else {
                //NSLog(@"This is very weird case");
                if (timeObserver != nil) {
                    //NSLog(@"remove time observer %d", __LINE__);
                    [avPlayer removeTimeObserver:timeObserver];
                    timeObserver = nil;
                }
                return;
            }
            if (timeObserver != nil) {
                //NSLog(@"remove time observer %d", __LINE__);
                [avPlayer removeTimeObserver:timeObserver];
                timeObserver = nil;
            }
            CMTime endTime = CMTimeMakeWithSeconds([endViewInfo.time floatValue], 1);
            //NSLog(@"Register time observer %d", __LINE__);
            timeObserver = [avPlayer addBoundaryTimeObserverForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:endTime]] queue:NULL usingBlock:^(void) {
                //NSLog(@"time observer fired %d", __LINE__);
                //[avPlayer removeTimeObserver:timeObserver];
                //timeObserver = nil;
                [self setCurrentPostion:[startViewInfo.time floatValue]];
                //[self updatePosition];
                CGFloat moveOffset = position - self.myScrollView.bounds.size.width / 2;
                
                if (self.myScrollView.contentSize.width - position < self.myScrollView.bounds.size.width / 2) {
                    moveOffset = self.myScrollView.contentSize.width - self.myScrollView.bounds.size.width; 
                }
                if (moveOffset < 0) {
                    moveOffset = 0;
                }
                [self.myScrollView setContentOffset:CGPointMake(moveOffset, 0.0)];
            }];
            
        }
        else {
            if (timeObserver != nil) {
                //NSLog(@"remove time observer %d", __LINE__);
                [avPlayer removeTimeObserver:timeObserver];
                timeObserver = nil;
            }
        }
            
    }
    else 
    {
        if (timeObserver != nil) {
            //NSLog(@"remove time observer %d", __LINE__);
            [avPlayer removeTimeObserver:timeObserver];
            timeObserver = nil;
        }
    }

}

# pragma mark TOOLBAR CONTENTS
- (NSArray *) playItems
{
	NSMutableArray *items = [NSMutableArray array];
	
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
    [items addObject:IMGBARBUTTON([UIImage imageNamed:@"btn_prev_off.png"], @selector(rewind))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
    [items addObject:IMGBARBUTTON([UIImage imageNamed:@"btn_play_off.png"], @selector(play))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
    [items addObject:IMGBARBUTTON([UIImage imageNamed:@"btn_next_off.png"], @selector(fastforward))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
    [items addObject:IMGBARBUTTON([UIImage imageNamed:@"btn_re_off.png"], @selector(repeatModeOnOff))];
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	
	return items;
}

- (NSArray *) pauseItems
{
	NSMutableArray *items = [NSMutableArray array];
	
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
    [items addObject:IMGBARBUTTON([UIImage imageNamed:@"btn_prev_off.png"], @selector(rewind))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
    [items addObject:IMGBARBUTTON([UIImage imageNamed:@"btn_pause_off.png"], @selector(pause))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
    [items addObject:IMGBARBUTTON([UIImage imageNamed:@"btn_next_off.png"], @selector(fastforward))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
    [items addObject:IMGBARBUTTON([UIImage imageNamed:@"btn_re_off.png"], @selector(repeatModeOnOff))];
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	
	return items;
}

#pragma mark PLAYBACK
- (void) pause
{
    toolBar.items = [self playItems];
    [updateTimer invalidate];
    updateTimer = nil;
    [avPlayer pause];
    playState = playBackStatePaused;
    //mainSlider.enabled = NO;
    //NSLog(@"state pause:%d", playState);
}

- (void) play
{
	//[player play];
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    toolBar.items = [self pauseItems];
    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
        
    }
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(updatePosition) userInfo:nil repeats:YES];
    [self createPlaybackTimer];
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    
    if (newTaskId != UIBackgroundTaskInvalid && bgTaskId != UIBackgroundTaskInvalid)
        [[UIApplication sharedApplication] endBackgroundTask: bgTaskId];
    
    bgTaskId = newTaskId;
    [avPlayer play];
    
    playState = playBackStatePlaying;
    //mainSlider.enabled = YES;
    //NSLog(@"state play:%d", playState);
}

- (void) fastforward
{
    CMTime OneSeconds = CMTimeMake(1*1000, 1000);
    CMTime ForwardOneSeconds = CMTimeAdd(avPlayer.currentTime, OneSeconds);
    [avPlayer seekToTime:ForwardOneSeconds];
    [self updatePosition];
}
- (void) repeatModeOnOff
{
    if (repeatMode) {
        repeatMode = NO;
    }
    else 
    {
        repeatMode = YES;
    }
    if (repeatMode) {
        repeatModeView.image = [UIImage imageNamed:@"repeat_on_test.png"];
    }
    else 
    {
        repeatModeView.image = [UIImage imageNamed:@"repeat_off_test.png"];
    }
    [self registerTimeObserver];
    
    //NSLog(@"repeatMode:%d", repeatMode);
}
- (void) rewind
{
    CMTime OneSeconds = CMTimeMake(1 * 1000, 1000);
    CMTime ReverseOneSeconds = CMTimeSubtract(avPlayer.currentTime, OneSeconds);
    [avPlayer seekToTime:ReverseOneSeconds];
    [self updatePosition];
}
#pragma mark Music notification handlers__________________

- (void) handle_iPodLibraryChanged: (id) notification {
    
	// Implement this method to update cached collections of media items when the 
	// user performs a sync while your application is running. This sample performs 
	// no explicit media queries, so there is nothing to update.
    NSLog(@"Library changed");
}




- (void)dealloc
{
    
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     //[[NSNotificationCenter defaultCenter] removeObserver: self
     //name: MPMediaLibraryDidChangeNotification
     //object: player];
     
     [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
     
     
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [mediaControllerDelegate release];
    [mpVolumeView release];
    [self.myGraphView release];
    [bookMarkArray release];
    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    [playbackTimeLabel release];
    [remainTimeLabel release];
    //[startTimeLabel release];
    //[samplingRateLabel release];
    //[totalTimeLabel release];
    //[endTimeLabel release];
    //[HUD release];
    [startPickerView release];
    [endPickerView release];
    [playListViewController release];
    [avPlayer release];
    [titleView release];
    [songTitleLabel release];
    [songArtistLabel release];
    [repeatModeView release];
    [managedObjectContext release];
    //[mainSlider release];
    //[startPickerPosition release];
    //[endPickerPosition release];
    [super dealloc];
}

- (void)updatePosition {
    //Float32 temp = [player currentPlaybackTime];
    Float32 temp = CMTimeGetSeconds(avPlayer.currentTime);
    //NSLog(@"update position %f", temp);
	
    [self.myGraphView setCurrentPlaybackPosition:temp];
    if (self.myScrollView.contentSize.width < self.myScrollView.bounds.size.width) {
        movingOffset = NO;
        return;
    }
    
    if(movingOffset == NO && self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width - 20 < self.myGraphView.currentPixel && self.myGraphView.currentPixel < self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width)
    {
       //NSLog(@"Current PlayBack Position:%f, contentOffset:%f, width:%f", self.myGraphView.currentPixel, self.myScrollView.contentOffset.x, self.myScrollView.bounds.size.width);
        movingOffset = YES;
    }
    if (movingOffset) {
        if (self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width / 2 > self.myGraphView.currentPixel || self.myGraphView.currentPixel > self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width) {
            movingOffset = NO;
        }
    }
    if (movingOffset) {
        
        CGFloat moveOffset = self.myScrollView.contentOffset.x + 1.0f;
        [self.myScrollView setContentOffset:CGPointMake(moveOffset, 0.0)];
        if (self.myGraphView.currentPixel < self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width/2) {
            movingOffset = NO;
        }
    }
        
        
}
- (void)setCurrentPostion:(CGFloat)value {
    [avPlayer seekToTime:CMTimeMake(value * 1000, 1000)];
}
-(void) createPlaybackTimer {
	if (playbackTimer) {
		[playbackTimer invalidate];
        playbackTimer = nil;
        
    }
	playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
													  target:self
													selector:@selector(playerTimerUpdate:)
													userInfo:nil
													 repeats:YES];
}
-(void) playerTimerUpdate: (NSTimer*) timer {
	// playback time label
    CMTime duration = avPlayer.currentItem.duration;
    CMTime currentTime = avPlayer.currentItem.currentTime;
    CMTime remainTime = CMTimeSubtract(duration,currentTime);
	UInt64 currentTimeSec = currentTime.value / currentTime.timescale;
    UInt64 remainTimeSec = remainTime.value / remainTime.timescale;
		
	UInt32 minutes = currentTimeSec / 60;
	UInt32 seconds = currentTimeSec % 60;
	playbackTimeLabel.text = [NSString stringWithFormat: @"%02d:%02ld", minutes, seconds];
    
    minutes = remainTimeSec / 60;
	seconds = remainTimeSec % 60;
	remainTimeLabel.text = [NSString stringWithFormat: @"-%02d:%02ld", minutes, seconds];
    
    //mainSlider.value = (currentTimeSec / [currentSong.songDuration floatValue]);
	
}
- (void) musicTableViewControllerDidFinish: (UIViewController *) controller {
	[controller dismissModalViewControllerAnimated: YES];
}

- (IBAction) selectSongs:(id)sender {
    MPMediaPickerController *mediaController = [[MPMediaPickerController alloc] init];
    mediaController.allowsPickingMultipleItems = YES;
    mediaController.delegate = [[MyMediaPickerDelegate alloc] init];
    mediaController.prompt =
    NSLocalizedString (@"노래를 추가해 주세요.",
                       "Prompt in media item picker");
    [self presentModalViewController:mediaController animated:YES];
}
- (IBAction) goToMyList:(id)sender {
    
    MusicTableViewController *controller = [[MusicTableViewController alloc] initWithNibName: @"MusicTableView" bundle: nil];
    controller.mainViewController = self;
    //MusicWaveAppDelegate *appDelegate = (MusicWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    controller.managedObjectContext = self.managedObjectContext;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController: controller animated: YES];
    [controller release];
}
- (IBAction) goToBookMark:(id)sender {
    BookMarkViewController *bookMarkViewController = [[BookMarkViewController alloc] initWithNibName:@"BookMarkViewController" bundle:nil];
    bookMarkViewController.mainViewController = self;
    bookMarkViewController.currentSong = self.currentSong;
    bookMarkViewController.bookMarkArray = self.bookMarkArray;
    [self.navigationController pushViewController:bookMarkViewController animated:YES];
    [bookMarkViewController release];

}
- (IBAction) tapBookMarkButton:(id)sender {
    int tag = ((UIButton *)sender).tag;
    //NSLog(@"Tapping bookmark button:%d", tag);
    int bookMarkCount = [self.bookMarkArray count];
    if (bookMarkCount < tag) {
        //NSLog(@"No book mark available in %d", tag);
        return;
    }
    BookMark *tempBookMark = [self.bookMarkArray objectAtIndex:(tag - 1)];
    
    ViewInfo *tempViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:[tempBookMark.position floatValue]];
    [self setCurrentPostion:[tempViewInfo.time floatValue]];
}
-(void)addBookMarkOnPixel:(CGFloat)pixel {
    NSManagedObjectContext *context = [currentSong managedObjectContext];
    NSError *error = nil;
    
    BookMark *bookMark = [NSEntityDescription insertNewObjectForEntityForName:@"BookMark" inManagedObjectContext:context];
   
    ViewInfo *tempViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:pixel - 1];
    bookMark.duration = tempViewInfo.time;
    bookMark.position = [NSNumber numberWithFloat:pixel];
    bookMark.keepDate = [NSDate date];
    [self.bookMarkArray addObject:bookMark];
    [currentSong addBookmarksObject:bookMark];
    
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
- (int) restorePickerIndex:(NSNumber *)position {
    int bookMarkCount = [self.bookMarkArray count];
    if (bookMarkCount == 0) {
        return 0;
    }
    for (int i = 0; i < bookMarkCount; i++) {
        BookMark *tempBookMark = [self.bookMarkArray objectAtIndex:i];
        NSLog(@"position:%f, temp:%f", [position floatValue], [tempBookMark.position floatValue]);
        if ([position floatValue] == [tempBookMark.position floatValue]) {
            NSLog(@"picker view index:%i", i);
            return i + 1;
        }
    }
    return 0;
}
- (IBAction) tapMainButton:(id)sender {
    
    //NSLog(@"play state:%d", playState);
	
	//if (playState == playBackStatePaused || playState == playBackStatePlaying) {
    if ([currentSong.doneGraphDrawing boolValue]) {
        [self addBookMarkOnPixel:[self.myGraphView currentPixel]];
        [self.myGraphView.bookMarkLayer setNeedsDisplay];
        [startPickerView reloadData];
        [endPickerView reloadData];
    }
    else NSLog(@"No graph available");
       
        /*int bookMarkCount = [self.bookMarkArray count];
        for ( int i = 0; i < bookMarkCount; i++) {
            BookMark *tempBookMark = [self.bookMarkArray objectAtIndex:i];
            NSLog(@"BookMark count:%d, position:%f, time:%f", bookMarkCount, [tempBookMark.position floatValue], [tempBookMark.duration floatValue]);
        }*/
    //}
}

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    //NSLog(@"scroll did scroll offset x:%f y:%f", offset.x, offset.y);
    CGFloat start = offset.x;
    CGFloat end = offset.x + 320;
    if ([self.myGraphView.viewInfoArray count] == 0) {
        //NSLog(@"viewInfoArray delete");
        return;
    }
    if (start < 0) {
        start = 0;
    }
    if (end > [self.myGraphView.viewInfoArray count] - 1) {
        end = [self.myGraphView.viewInfoArray count] - 1;
    }
    ViewInfo *startViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:start];
    ViewInfo *endViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:end];
    UInt64 startTimeSec = [startViewInfo.time floatValue];
    UInt64 endTimeSec = [endViewInfo.time floatValue];
	
	UInt32 minutes = startTimeSec / 60;
	UInt32 seconds = startTimeSec % 60;
	//startTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
    
    minutes = endTimeSec / 60;
	seconds = endTimeSec % 60;
	//endTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
}
- (void) scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    //CGPoint offset = aScrollView.contentOffset;
    //NSLog(@"scroll did end decelerating offset x:%f y:%f", offset.x, offset.y);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning received");
    
    // Release any cached data, images, etc that aren't in use.
}
- (void) scrubbingDone: (UISlider *) aSlider
{
	[self play];
    
    CGFloat moveOffset = self.myGraphView.currentPixel - self.myScrollView.bounds.size.width / 2;
    
    if (self.myScrollView.contentSize.width - self.myGraphView.currentPixel < self.myScrollView.bounds.size.width / 2) {
        moveOffset = self.myScrollView.contentSize.width - self.myScrollView.bounds.size.width; 
    }
    if (moveOffset < 0) {
        moveOffset = 0;
    }
    [self.myScrollView setContentOffset:CGPointMake(moveOffset, 0.0)];
}

- (void) scrub: (UISlider *) aSlider
{
	// Pause the player
	[self pause];
	
	// Calculate the new current time
    [self setCurrentPostion:aSlider.value * [currentSong.songDuration floatValue]];
    [self.myGraphView setCurrentPlaybackPosition:aSlider.value * [currentSong.songDuration floatValue]];
    
    
	
	// Update the title, nav bar
	//self.title = [NSString stringWithFormat:@"%@ of %@", [self formatTime:self.player.currentTime], [self formatTime:self.player.duration]];
	//self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, self, @selector(play:));
}

#pragma mark - View lifecycle
- (void)settingUpBackgroundView {
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainview_bg.png"]];
    backGround.frame = CGRectMake(0,  0, 320, 374);
    [self.view addSubview:backGround];
    [backGround release];
}
- (void)settingUpLabel {
    self.playbackTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0f, 194.0f, 60.0f, 20.0f)];
    [playbackTimeLabel setText:@"00:00"];
    [playbackTimeLabel setTextAlignment:UITextAlignmentCenter];
    playbackTimeLabel.adjustsFontSizeToFitWidth = NO;
    playbackTimeLabel.textColor = [UIColor whiteColor];
    playbackTimeLabel.backgroundColor = [UIColor clearColor];
    //playbackTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(12.0)];
    playbackTimeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.view addSubview:playbackTimeLabel];
    
    remainTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(242.0f, 194.0f, 60.0f, 20.0f)];
    [remainTimeLabel setText:@"00:00"];
    [remainTimeLabel setTextAlignment:UITextAlignmentCenter];
    remainTimeLabel.adjustsFontSizeToFitWidth = NO;
    remainTimeLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0];
    remainTimeLabel.backgroundColor = [UIColor clearColor];
    //remainTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(12.0)];
    remainTimeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.view addSubview:remainTimeLabel];
    
    //self.startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0f, 7.0f, 46.0f, 11.0f)];
    //[startTimeLabel setText:@"00:00"];
    //[startTimeLabel setTextAlignment:UITextAlignmentLeft];
    //startTimeLabel.textColor = [UIColor colorWithRed:107.0/255.0f green:114.0/255.0f blue:133.0/255.0f alpha:1.0];
    //startTimeLabel.backgroundColor = [UIColor clearColor];
    //startTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    //startTimeLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    //[self.view addSubview:startTimeLabel];
    
    //self.endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(253.0f, 7.0f, 46.0f, 11.0f)];
    //[endTimeLabel setText:@"00:00"];
    //[endTimeLabel setTextAlignment:UITextAlignmentRight];
    //endTimeLabel.textColor = [UIColor colorWithRed:107.0/255.0f green:114.0/255.0f blue:133.0/255.0f alpha:1.0];
    //endTimeLabel.backgroundColor = [UIColor clearColor];
    //endTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    //endTimeLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    //[self.view addSubview:endTimeLabel];
    
    //self.samplingRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0f, 230.0f, 89.0f, 11.0f)];
    //[samplingRateLabel setText:@""];
    //[samplingRateLabel setTextAlignment:UITextAlignmentLeft];
    //samplingRateLabel.textColor = [UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0];
    //samplingRateLabel.backgroundColor = [UIColor clearColor];
    //samplingRateLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    //samplingRateLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    //[self.view addSubview:samplingRateLabel];
    
    //self.totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(253.0f, 230.0f, 46.0f, 11.0f)];
    //[totalTimeLabel setText:@"00:00"];
    //[totalTimeLabel setTextAlignment:UITextAlignmentRight];
    //totalTimeLabel.textColor = [UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0];
    //totalTimeLabel.backgroundColor = [UIColor clearColor];
    //totalTimeLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    //totalTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    //[self.view addSubview:totalTimeLabel];
}
- (void)settingUpPicker {
    UIImageView *leftBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_background.png"]];
    leftBackGround.frame = CGRectMake(57 - 41, 249, 82, 69);
    [self.view addSubview:leftBackGround];
    [leftBackGround release];

    CGRect leftFrame = CGRectMake(57 - 41, 250, 82, 45);
	startPickerView = [[V8HorizontalPickerView alloc] initWithFrame:leftFrame];
	startPickerView.backgroundColor   = [UIColor clearColor];
	startPickerView.selectedTextColor = [UIColor blackColor];
	startPickerView.textColor   = [UIColor blackColor];
	startPickerView.delegate    = self;
	startPickerView.dataSource  = self;
	startPickerView.elementFont = [UIFont boldSystemFontOfSize:25.0f];
    startPickerView.tag = 0;
	//startPickerView.selectionPoint = CGPointMake(60, 0);
    
	// add carat or other view to indicate selected element
	//UIImageView *startIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_cell.png"]];
    //startIndicator.layer.opacity = 0.56f;
	//startPickerView.selectionIndicatorView = startIndicator;
	//startPickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location
	//[startIndicator release];
    
	// add gradient images to left and right of view if desired
    UIImageView *startLeftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scroll_up.png"]];
    startLeftFade.layer.opacity = 0.8f;
    startPickerView.leftEdgeView = startLeftFade;
    [startLeftFade release];
    //
    //UIImageView *startRightFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg_right.png"]];
    //startPickerView.rightEdgeView = startRightFade;
    //[startRightFade release];
    [self.view addSubview:startPickerView];
    
    UIImageView *rightBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_background.png"]];
    rightBackGround.frame = CGRectMake(206 + 57 - 41, 249, 82, 69);
    [self.view addSubview:rightBackGround];
    [rightBackGround release];
    CGRect rightFrame = CGRectMake(206 + 57 - 41, 250, 82, 45);
	endPickerView = [[V8HorizontalPickerView alloc] initWithFrame:rightFrame];
	endPickerView.backgroundColor   = [UIColor clearColor];
	endPickerView.selectedTextColor = [UIColor blackColor];
	endPickerView.textColor   = [UIColor blackColor];
	endPickerView.delegate    = self;
	endPickerView.dataSource  = self;
	endPickerView.elementFont = [UIFont boldSystemFontOfSize:25.0f];
    endPickerView.tag = 1;
	//startPickerView.selectionPoint = CGPointMake(60, 0);
    
	// add carat or other view to indicate selected element
	//UIImageView *endIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_cell.png"]];
    //endIndicator.layer.opacity = 0.56f;
	//endPickerView.selectionIndicatorView = endIndicator;
	//endPickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location
	//[endIndicator release];
    
	// add gradient images to left and right of view if desired
    UIImageView *endLeftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scroll_up.png"]];
    endLeftFade.layer.opacity = 0.8f;
    endPickerView.leftEdgeView = endLeftFade;
    [endLeftFade release];
    //
    //UIImageView *endRightFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg_right.png"]];
    //endPickerView.rightEdgeView = endRightFade;
    //[endRightFade release];
    [self.view addSubview:endPickerView];
}
- (void)settingUpBookMarkButton {
    mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mainButton.frame = CGRectMake(160 - 46, 238.0f, 92.0f, 92.0f);
    
    [mainButton setBackgroundImage:[UIImage imageNamed:@"bookmark_off.png"] forState:UIControlStateNormal];
    [mainButton setBackgroundImage:[UIImage imageNamed:@"bookmark_on.png"] forState:UIControlStateSelected];
    [mainButton setBackgroundImage:[UIImage imageNamed:@"bookmark_on.png"] forState:UIControlStateHighlighted];
    [mainButton addTarget:self action:@selector(tapMainButton:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:mainButton];
}
- (void)settingUpVolumeSlider {
    //UIImageView *soundOffImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sound_off.png"]];
    //soundOffImage.frame = CGRectMake(21, 407-65 + STATUSBAR_HEIGHT, 14, 10);
    //[self.view addSubview:soundOffImage];
    //[soundOffImage release];
    
    //UIImageView *soundOnImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sound_on.png"]];
    //soundOnImage.frame = CGRectMake(285, 407-65 + STATUSBAR_HEIGHT, 13, 10);
    //[self.view addSubview:soundOnImage];
    //[soundOnImage release];
    
    CGRect frame = CGRectMake(52, 349, 210, 6);
    UISlider *customSlider = [[UISlider alloc] initWithFrame:frame];
    MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:[customSlider frame]] autorelease];
    UISlider *volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
		if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
			volumeViewSlider = (UISlider *) view;
		}
	}
    volumeViewSlider.backgroundColor = [UIColor clearColor];	
    //UIImage *stetchLeftTrack = [[UIImage imageNamed:@"bar_on.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0];
    //UIImage *stetchRightTrack = [[UIImage imageNamed:@"bar_off.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0];
    [volumeViewSlider setThumbImage: [UIImage imageNamed:@"volume_pos.png"] forState:UIControlStateNormal];
    [volumeViewSlider setMinimumTrackImage:[UIImage imageNamed:@"volume_left.png"] forState:UIControlStateNormal];
    //[volumeViewSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    [customSlider removeFromSuperview];
    [self.view addSubview:volumeView];
    [customSlider release];
    //[volumeView release];
}
- (void)applicationWillResign {
    //NSLog(@"application will resign");
}
- (void)applicationWillEnterForeground {
    //NSLog(@"application will enter foreground");
    if (avPlayer.rate == 0.0f && playState == playBackStatePlaying) {
        //NSLog(@"avPlayer rate is 0");
        //NSLog(@"self playstae:%d", playState);
        [self pause];
    }
    else
    {
        //NSLog(@"avPlayer rate is %f", avPlayer.rate);
        //NSLog(@"self playstate:%d", playState);
    }
}
-(void)checkLibrary
{
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSLog(@"Title:%@", songTitle);
        NSString *songID = [song valueForProperty: MPMediaItemPropertyPersistentID];
        NSLog(@"ID:%@", songID);
        NSString *albumTitle = [song valueForProperty: MPMediaItemPropertyAlbumTitle];
        NSLog(@"Album Titel:%@", albumTitle);
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.startPickerPosition = 0.f;
    self.endPickerPosition = 0.f;
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"current language:%@", language);
    //if([language isEqualToString:@"ko"])
        //NSLog(@"current string equal to ko");
    //else
        //NSLog(@"current string not equal to ko");
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(songsPicked:) name:@"SongsPicked" object:nil];
    [notificationCenter addObserver:self selector:@selector(applicationWillResign) name:UIApplicationWillResignActiveNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    //self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    //self.navigationController.navigationBar.translucent = YES;
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftBarButton.frame = CGRectMake(0.0f, 0.0f, 60.0f, 36.0f);
    if ([language isEqualToString:@"ko"]) {
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"music_off_kor.png"] forState:UIControlStateNormal];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"music_on_kor.png"] forState:UIControlStateSelected];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"music_on_kor.png"] forState:UIControlStateHighlighted];
    }
    else {
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"music_off_eng.png"] forState:UIControlStateNormal];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"music_on_eng.png"] forState:UIControlStateSelected];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"music_on_eng.png"] forState:UIControlStateHighlighted];
    }
 
    [leftBarButton addTarget:self action:@selector(goToMyList:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    [leftBarButton release];

    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];

    //self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
    //self.navigationItem.leftBarButtonItem = BARBUTTON(NSLocalizedString(@"Music",@"Title for My List"), @selector(goToMyList:));
    
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightBarButton.frame = CGRectMake(0.0f, 0.0f, 60.0f, 36.0f);
    if ([language isEqualToString:@"ko"]) {
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"bookmark_right_off_kor.png"] forState:UIControlStateNormal];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"bookmark_right_on_kor.png"] forState:UIControlStateSelected];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"bookmark_right_on_kor.png"] forState:UIControlStateHighlighted];
    } else {
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"bookmark_right_off_eng.png"] forState:UIControlStateNormal];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"bookmark_right_on_eng.png"] forState:UIControlStateSelected];
        [rightBarButton setBackgroundImage:[UIImage imageNamed:@"bookmark_right_on_eng.png"] forState:UIControlStateHighlighted];
    }
    [rightBarButton addTarget:self action:@selector(goToBookMark:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    [rightBarButton release];
    
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [rightBarItem release];

    //self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
    //self.navigationItem.rightBarButtonItem = BARBUTTON(NSLocalizedString(@"BookMark", @"Title for BookMarks"), @selector(goToBookMark:));
    //self.title = NSLocalizedString (@"Back", @"Title for MainViewController");
    avPlayer = nil;
    //self.navigationController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
    //self.navigationController.navigationBar.translucent = YES;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.translucent = YES;
    //self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    //NSLog(@"left bar button width:%f, right bar button width:%f, navigation bar width:%f", self.navigationItem.leftBarButtonItem.width, self.navigationItem.rightBarButtonItem.width, self.navigationController.navigationBar.bounds.size.width);
    /*UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 62)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 3;
    label.font = [UIFont boldSystemFontOfSize: 12.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    NSString *songData;
    songData = NSLocalizedString(@"MusicWave MusicWave MusicWave MusicWave", @"Default title for song label");//[[songList objectAtIndex:currentIndex] artistName];
    songData = [songData stringByAppendingString:@"\n"];
    songData = [songData stringByAppendingString:NSLocalizedString(@"MusicWave", @"Default title for song label")];//[songData stringByAppendingString: [[songList objectAtIndex:currentIndex] songName]];
    songData = [songData stringByAppendingString:@"\n"];
    songData = [songData stringByAppendingString:NSLocalizedString(@"MusicWave", @"Default title for song label")];//[songData stringByAppendingString: [[songList objectAtIndex:currentIndex] albumName]];
    label.text = songData;
    self.navigationItem.titleView = label;*/
    
    UILabel *songDataView = [[UILabel alloc] initWithFrame:CGRectMake(72, 0, 174, 62)];
    songDataView.backgroundColor = [UIColor clearColor];
    
    //UILabel *label;
    self.songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, songDataView.bounds.size.width, 30)];
    self.songTitleLabel.tag = 1;
    self.songTitleLabel.backgroundColor = [UIColor clearColor];
    self.songTitleLabel.font = [UIFont boldSystemFontOfSize:22];
    self.songTitleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    //self.songTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.songTitleLabel.textAlignment = UITextAlignmentCenter;
    self.songTitleLabel.textColor = [UIColor whiteColor];
    self.songTitleLabel.text = NSLocalizedString(@"MusicWave", @"Default title for song label");
    self.songTitleLabel.highlightedTextColor = [UIColor whiteColor];
    [songDataView addSubview:self.songTitleLabel];
    //[label release];
    
    self.songArtistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 33, songDataView.bounds.size.width, 22)];
    self.songArtistLabel.tag = 2;
    self.songArtistLabel.backgroundColor = [UIColor clearColor];
    self.songArtistLabel.font = [UIFont systemFontOfSize:14];
    self.songArtistLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    //self.songArtistLabel.adjustsFontSizeToFitWidth = NO;
    self.songArtistLabel.textAlignment = UITextAlignmentCenter;
    self.songArtistLabel.textColor = [UIColor whiteColor];
    self.songArtistLabel.text = NSLocalizedString(@"MusicWave", @"Default title for song label");;
    self.songArtistLabel.highlightedTextColor = [UIColor whiteColor];
    [songDataView addSubview:self.songArtistLabel];
    //[label release];
    
    self.navigationItem.titleView = songDataView;
    
    //self.currentSong = nil;
    //self.myScrollView.delegate = self;
    //HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    //[self.navigationController.view addSubview:HUD];
    //HUD.delegate = self;
    
    
    
    
    //self.navigationItem.leftBarButtonItem = BARBUTTON(@"My List", @selector(selectSongs:));
    
    	
    [self.myGraphView setParent:self];
    //playState = playBackStateNone;
    //[self imageViewTest];
    [self settingUpBackgroundView];
    [self settingUpLabel];
    [self settingUpPicker];
    [self settingUpBookMarkButton];
    [self settingUpVolumeSlider];
    //[self settingUpMainSlider];
    
    [toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back.png"]
             forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    //mainSlider.enabled = NO;
    
    self.repeatModeView = [[UIImageView alloc] initWithFrame:CGRectZero];
    //self.repeatModeView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.repeatModeView.frame = CGRectMake(160 - 38, 195, 76, 21);
    if (repeatMode) {
        repeatModeView.image = [UIImage imageNamed:@"repeat_on_test.png"];
    }
    else repeatModeView.image = [UIImage imageNamed:@"repeat_off_test.png"];
    [self.view addSubview:repeatModeView];
    
    CGRect scrollViewRect = CGRectMake(10, 33, 300, 157);
    
    self.myScrollView = [[MyScrollView alloc] initWithFrame:scrollViewRect];
    self.myScrollView.scrollEnabled = YES;
    self.myScrollView.backgroundColor = [UIColor clearColor];
    self.myScrollView.contentSize = CGSizeMake(scrollViewRect.size.width,
                                               scrollViewRect.size.height);
    [self.view addSubview:self.myScrollView];
    
    CGRect graphViewRect = self.myScrollView.bounds;
    self.myGraphView = [[MyGraphView alloc] initWithFrame:graphViewRect];
    self.myGraphView.backgroundColor = [UIColor clearColor];
    self.myGraphView.parent = self;
    [self.myScrollView addSubview:self.myGraphView];

    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
    //NSLog(@"main view did load");
    
}
#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
	return [self.bookMarkArray count] + 1;
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    //BookMark *mark = [currentSong.bookMarkArray objectAtIndex:index];
    NSString *returnString;
    if (picker.tag == 0) {
        returnString = @"L";
    }
    else returnString = @"R";
    if (index > 0) {
        returnString = [NSString stringWithFormat:@"%d", index];
    }
    
	return returnString;
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
	CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    //BookMark *mark = [currentSong.bookMarkArray objectAtIndex:index];
    NSString *text = @"N";
    if (index > 0) {
        text = [NSString stringWithFormat:@"%d", index];
    }
	CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:16.0]
					   constrainedToSize:constrainedSize
						   lineBreakMode:UILineBreakModeWordWrap];
	return textSize.width + 22.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
	//self.infoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
    //NSLog(@"picker view selected index %d tag:%d", index, picker.tag);
    if (index == 0) {
        if (picker.tag == 0) {
            self.startPickerPosition = 0.f;
        }
        else {
            self.endPickerPosition = 0.f;
        }
        [self.myGraphView settingStartEndPosition:startPickerPosition endPosition:endPickerPosition];
        [self.myGraphView.bookMarkLayer setNeedsDisplay];
        [self registerTimeObserver];
        return;
    }
    
    int bookMarkCount = [self.bookMarkArray count];
    if (bookMarkCount < index) {
        //NSLog(@"No book mark available in %d", index);
        return;
    }
    BookMark *tempBookMark = [self.bookMarkArray objectAtIndex:index - 1];
    if (picker.tag == 0) {
        self.startPickerPosition = [tempBookMark.position floatValue];
    }
    else {
        self.endPickerPosition = [tempBookMark.position floatValue];
    }
    //NSLog(@"Self startPickerPosition:%f, endPickerPosition:%f", self.startPickerPosition, self.endPickerPosition);
    ViewInfo *tempViewInfo = [self.myGraphView.viewInfoArray objectAtIndex:[tempBookMark.position floatValue]];
    //NSLog(@"bookMark position:%f, time:%f", [tempBookMark.position floatValue], [tempViewInfo.time floatValue]);
    [self setCurrentPostion:[tempViewInfo.time floatValue]];
    //[self updatePosition];
    CGFloat moveOffset = [tempBookMark.position floatValue] - self.myScrollView.bounds.size.width / 2;
   
    if (self.myScrollView.contentSize.width - [tempBookMark.position floatValue] < self.myScrollView.bounds.size.width / 2) {
        moveOffset = self.myScrollView.contentSize.width - self.myScrollView.bounds.size.width; 
    }
    if (moveOffset < 0) {
        moveOffset = 0;
    }
    [self.myScrollView setContentOffset:CGPointMake(moveOffset, 0.0)];
    [self.myGraphView settingStartEndPosition:startPickerPosition endPosition:endPickerPosition];
    [self.myGraphView.bookMarkLayer setNeedsDisplay];
    [self.myGraphView setCurrentPlaybackPosition:[tempViewInfo.time floatValue]];
    [self registerTimeObserver];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //NSLog(@"main view will appear");
    [self.myGraphView settingStartEndPosition:startPickerPosition endPosition:endPickerPosition];
    [self.myGraphView.bookMarkLayer setNeedsDisplay];
    [startPickerView reloadData];
    [endPickerView reloadData];
}

-(void) setUpAVPlayerForURL: (NSURL*) url {
    if (!avPlayer) {
        avPlayer = [[AVPlayer alloc] initWithURL:url];
    } else {
        [avPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    }
    

    if (avPlayer) {
        [toolBar setItems:[self playItems]];
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification
         object:avPlayer.currentItem];
        //[self play];
	}
}
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [avPlayer seekToTime:kCMTimeZero];
    [self.myGraphView.layer setNeedsDisplay];
    [self.myScrollView setContentOffset:CGPointMake(0.0, 0.0)];
    movingOffset = NO;
    [self pause];
    if (repeatMode) {
        [self play];
        [self registerTimeObserver];
    }
}


- (void) songsPicked: (NSNotification *)notification {
    //[self updateUserSongListWithMediaCollection:(MPMediaItemCollection *)[notification object]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    startPickerView = nil;
    endPickerView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
