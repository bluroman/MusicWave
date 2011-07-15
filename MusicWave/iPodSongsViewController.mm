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
#import "BookMarkListViewController.h"
#import "MusicTableViewController.h"
#import "BookMark.h"
#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:208.0/255.0f green:208.0/255.0f blue:208.0/255.0f alpha:1.0f]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define IMGBARBUTTON(IMAGE, SELECTOR) [[[UIBarButtonItem alloc] initWithImage:IMAGE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@implementation iPodSongsViewController
@synthesize mediaControllerDelegate, graphView, scrollView;
@synthesize currentSong;
@synthesize playbackTimeLabel;
@synthesize startTimeLabel, endTimeLabel, samplingRateLabel, totalTimeLabel;
@synthesize mainButton;
@synthesize startPickerView, endPickerView;
@synthesize playListViewController;
@synthesize avPlayer;
@synthesize playState;
@synthesize bookMarkArray;
@synthesize repeatModeView;
@synthesize songTitleLabel, songArtistLabel;

- (void)startGetDrawingInfoThread:(AVURLAsset *)currentAsset {
    
    [self.view setAlpha:0.7f];
	HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading";
    
    HUD.detailsLabelText = @"Information";
	
    //[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    [HUD show:YES];
    NSLog(@"HUD retain count:%d", [HUD retainCount]);
    
    //[HUD showWhileExecuting:@selector(extractDataFromAsset:) onTarget:self withObject:currentAsset animated:YES];

    [NSThread detachNewThreadSelector:@selector(extractDataFromAsset:) toTarget:self withObject:currentAsset];
}
- (void)loadComplete:(id)total {
    int pixelCount = [total intValue];
    if (pixelCount > 320) {
        [scrollView setContentSize:CGSizeMake(pixelCount, graphView.bounds.size.height)];
        [graphView setFrame:CGRectMake(0, 0, pixelCount, graphView.bounds.size.height)];
    }
    else {
        [scrollView setContentSize:CGSizeMake(pixelCount, graphView.bounds.size.height)];
        [graphView setFrame:CGRectMake(0, 0, pixelCount, graphView.bounds.size.height)];
    }
    [graphView setUpBookMarkLayer];
    scrollView.contentOffset = CGPointMake(0.0, 0.0);
    [graphView setNeedsDisplay];
    [HUD hide:YES];
    [self.view setAlpha:1.0f];
    //NSURL *songURL = [currentSong.song valueForProperty:MPMediaItemPropertyAssetURL];
    [self setUpAVPlayerForURL:[NSURL URLWithString:currentSong.songURL]];
    //[self setCurrentPostion:0.0f];
}
- (void) extractDataFromAsset:(AVURLAsset *)songAsset {
    /*You need this for all threads you create or you will leak! */
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSError * error = nil;
    UInt64 songSampleRate = 0;
    UInt64 channelsPerFrame = 0;
    UInt64 divisor = 100;
    int mod = 1;
    
    NSArray *metadata = [songAsset commonMetadata];
    for ( AVMetadataItem* item in metadata ) {
        NSString *key = [item commonKey];
        NSString *value = [item stringValue];
        NSLog(@"key = %@, value = %@", key, value);
    }
    for (AVAssetTrack* track in songAsset.tracks) {
        NSLog(@"track.id: %d", track.trackID);
        NSLog(@"track.mediaType: %@", track.mediaType);
        CMFormatDescriptionRef fmt = (CMFormatDescriptionRef)[track.formatDescriptions objectAtIndex:0];
        AudioStreamBasicDescription* desc = (AudioStreamBasicDescription *)CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
        NSLog(@"track samplerate:%f", desc->mSampleRate);
        NSLog(@"track formatID:%lu", desc->mFormatID);
        NSLog(@"track formatFlags:%lu", desc->mFormatFlags);
        NSLog(@"track BytesPerPacket:%lu", desc->mBytesPerPacket);
        NSLog(@"track BytesPerFrame:%lu", desc->mBytesPerFrame);
        NSLog(@"track BitsPerChannel:%lu", desc->mBitsPerChannel);
        NSLog(@"track FramesPerPacket:%lu", desc->mFramesPerPacket);
        NSLog(@"track ChannelsPerFrame:%lu", desc->mChannelsPerFrame);
        NSLog(@"track.enabled: %d", track.enabled);
        NSLog(@"track.selfContained: %d", track.selfContained);
        songSampleRate = desc->mSampleRate;
        channelsPerFrame = desc->mChannelsPerFrame;
        if (channelsPerFrame == 1) {
            mod = 2;
        }
    }
    /*UInt64 songDuration = CMTimeGetSeconds(songAsset.duration);
	
	UInt32 minutes = songDuration / 60;
	UInt32 seconds = songDuration % 60;
	totalTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
    samplingRateLabel.text = [NSString stringWithFormat:@"%dHz", songSampleRate];*/
    
    
    AVAssetReader * reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    
    AVAssetTrack * songTrack = [songAsset.tracks objectAtIndex:0];
    NSMutableDictionary* audioReadSettings = [NSMutableDictionary dictionary];
    [audioReadSettings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
   
    AVAssetReaderTrackOutput * output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:audioReadSettings];
    [reader addOutput:output];
    [output release];
    NSLog(@"songAsset duration:%f", CMTimeGetSeconds(songAsset.duration));
    
    CMTime duration = CMTimeMakeWithSeconds(CMTimeGetSeconds(songAsset.duration), 1.0);
    
    CMTime start = CMTimeMakeWithSeconds(0.0, 1.0);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    reader.timeRange = range;
    int remaining = -1, count = 0, remaining_count = 0, totalSize = 0, first = 1;
    int len = songSampleRate / divisor;
    //int len = 480;/* always 100 */
    int mMaxSamples = (songSampleRate / len) * (CMTimeGetSeconds(songAsset.duration) / mod);
    /*if (channelsPerFrame == 1) {
        len = songSampleRate / (divisor * 2);
    }*/
    
    CGFloat *temp = new CGFloat[mMaxSamples];
    for (int i = 0; i < mMaxSamples; i++) {
        temp[i] = 0.;
    }
    int i = 0;
    float progress = 0.;
    //float progress = (float)((float)i / (float)mMaxSamples);
    
    [reader startReading];
    NSLog(@"start reading reader status:%d", reader.status);
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
                //NSLog(@"buffersize:%d", bufferSize);
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
                        
                        NSLog(@"4410th frame:%f at position:%d", frame[position] / 32768.0f, position);
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
                        NSLog(@"remaing lost:%d", remaining_count);
                    }
                    if (remaining < len) break;
                }
                float percent = 100.0 * (float)i/mMaxSamples;
                NSLog(@"Progress:%f ,%i, %i, %f, %d", (float)i/mMaxSamples, i, mMaxSamples, percent, (int)percent);
                progress = (float)i / mMaxSamples;
                HUD.detailsLabelText = [NSString stringWithFormat:@"%d%%", (int)percent];
                
            }

            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
            CFRelease(blockBufferRef);
            
            //HUD.progress = (float)(i / mMaxSamples);
        }
        NSLog(@"reader status:%d total:%d, sample count:%d, remaining_lost:%d", reader.status, totalSize, count, remaining_count);
    }
    if (reader.status == AVAssetReaderStatusCompleted) {
        NSLog(@"completed reading");
        progress = 1.0f;
        //HUD.progress = 1.0f;
        HUD.detailsLabelText = [NSString stringWithFormat:@"%d%%", progress *100];
    }
    CGFloat min=0., max=0., sumsq = 0., rms = 0., d = 0.;
    int j = 0;
    CGFloat pixel = 0.;
    int sampling = 10;
    if (mod == 2) {
        sampling = 10 / mod;
    }
    NSLog(@"start graph");
    //HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Drawing";
    HUD.detailsLabelText = @"Graph";
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
        //[graphView addViewInfo:currentInfo];
        [currentSong addViewinfosObject:currentInfo];
        //[currentInfo release];

        j += sampling;
    }
    delete[] temp;
    NSLog(@"ending graph");
    //graphView.currentSong = currentSong;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"x" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
    NSMutableArray *tempViewInfoArray = [[NSMutableArray alloc] initWithArray:[currentSong.viewinfos allObjects]];
    [tempViewInfoArray sortUsingDescriptors:sortDescriptors];
    
    graphView.viewInfoArray = tempViewInfoArray;
    /*for (int i=0; i < [graphView.viewInfoArray count]; i++) {
        ViewInfo *printInfo = [graphView.viewInfoArray objectAtIndex:i];
        NSLog(@"max:%f, x:%f, d:%f", [printInfo.max floatValue], [printInfo.x floatValue], [printInfo.time floatValue]);
    }*/
    [sortDescriptor release];
	[sortDescriptors release];
    [tempViewInfoArray release];
    currentSong.doneGraphDrawing = [NSNumber numberWithBool:YES];

    //NSError *error = nil;
    if (![context save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
    }

    
    [reader release];
    
    id idVar = [NSNumber numberWithInt: pixel];
	[self performSelectorOnMainThread:@selector(loadComplete:) withObject:idVar waitUntilDone:NO];
    
	[pool release];
   
 
}
- (void)updateCurrentSong {
    if (playState == playBackStatePlaying) {
        [self pause];
    }
    //Set graph view current song.
    graphView.currentSong = currentSong;
    //Update information label for current song.
    UInt64 songSampleRate = 0;
    UInt64 channelsPerFrame = 0;
    //NSURL *songURL = [currentSong.song valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:currentSong.songURL] options:nil];
    for (AVAssetTrack* track in songAsset.tracks) {
        NSLog(@"track.id: %d", track.trackID);
        NSLog(@"track.mediaType: %@", track.mediaType);
        CMFormatDescriptionRef fmt = (CMFormatDescriptionRef)[track.formatDescriptions objectAtIndex:0];
        AudioStreamBasicDescription* desc = (AudioStreamBasicDescription *)CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
        NSLog(@"track samplerate:%f", desc->mSampleRate);
        NSLog(@"track formatID:%lu", desc->mFormatID);
        NSLog(@"track formatFlags:%lu", desc->mFormatFlags);
        NSLog(@"track BytesPerPacket:%lu", desc->mBytesPerPacket);
        NSLog(@"track BytesPerFrame:%lu", desc->mBytesPerFrame);
        NSLog(@"track BitsPerChannel:%lu", desc->mBitsPerChannel);
        NSLog(@"track FramesPerPacket:%lu", desc->mFramesPerPacket);
        NSLog(@"track ChannelsPerFrame:%lu", desc->mChannelsPerFrame);
        NSLog(@"track.enabled: %d", track.enabled);
        NSLog(@"track.selfContained: %d", track.selfContained);
        songSampleRate = desc->mSampleRate;
        channelsPerFrame = desc->mChannelsPerFrame;
    }
    UInt64 songDuration = CMTimeGetSeconds(songAsset.duration);
	
	UInt32 minutes = songDuration / 60;
	UInt32 seconds = songDuration % 60;
	totalTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
    samplingRateLabel.text = [NSString stringWithFormat:@"%dHz", songSampleRate];
    //self.title = [currentSong.song valueForProperty:MPMediaItemPropertyTitle];
    //titleLabel.text = self.title;
    //self.title = currentSong.songTitle;
    self.songTitleLabel.text = currentSong.songTitle;
    self.songArtistLabel.text = currentSong.songArtist;
    playState = playBackStateNone;
    NSLog(@"state none:%d line:%d", playState, __LINE__);
    repeatMode = NO;
    if (timeObserver != nil) {
        [avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    if (repeatMode) {
        repeatModeView.image = [UIImage imageNamed:@"re_on.png"];
    }
    else repeatModeView.image = [UIImage imageNamed:@"re_off.png"];
    [self drawingCurrentGraphView];
    
}
- (void)drawingCurrentGraphView {
    if (![currentSong.doneGraphDrawing boolValue]) {
        //NSURL *songURL = [currentSong.song valueForProperty:MPMediaItemPropertyAssetURL];
        //AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];
        
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:currentSong.songURL] options:nil];
        [self startGetDrawingInfoThread:songAsset];
        NSLog(@"Start drawing graphview URL:%@", currentSong.songURL);
        NSLog(@"current song retain count:%d", [currentSong retainCount]);
    }
    else {
        //graphView.currentSong = currentSong;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"x" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
        
        NSMutableArray *tempViewInfoArray = [[NSMutableArray alloc] initWithArray:[currentSong.viewinfos allObjects]];
        [tempViewInfoArray sortUsingDescriptors:sortDescriptors];
        
        graphView.viewInfoArray = tempViewInfoArray;
        /*for (int i=0; i < [graphView.viewInfoArray count]; i++) {
            ViewInfo *printInfo = [graphView.viewInfoArray objectAtIndex:i];
            NSLog(@"max:%f, x:%f, d:%f", [printInfo.max floatValue], [printInfo.x floatValue], [printInfo.time floatValue]);
        }*/
        [sortDescriptor release];
        [sortDescriptors release];
        [tempViewInfoArray release];

        id idVar = [NSNumber numberWithInt: [currentSong.viewinfos count]];
        [self loadComplete:idVar];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keepDate" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortedBookMarks = [[NSMutableArray alloc] initWithArray:[currentSong.bookmarks allObjects]];
	[sortedBookMarks sortUsingDescriptors:sortDescriptors];
	self.bookMarkArray = sortedBookMarks;
    
	[sortDescriptor release];
	[sortDescriptors release];
	[sortedBookMarks release];


}
- (void)deleteCurrentSong {
    if (playState == playBackStatePlaying) {
        [self pause];
    }
    if (playbackTimer) {
		[playbackTimer invalidate];
        playbackTimer = nil;
    }
    self.currentSong = nil;
    graphView.currentSong = self.currentSong;
    [graphView.viewInfoArray removeAllObjects];
    [self.bookMarkArray removeAllObjects];
    totalTimeLabel.text = @"00:00";
    samplingRateLabel.text = @"";
    playbackTimeLabel.text = @"00:00";
    self.songTitleLabel.text = @"MusicWave";
    self.songArtistLabel.text = @"";
    playState = playBackStateNone;
    [startPickerView reloadData];
    [endPickerView reloadData];
    NSLog(@"state none:%d line:%d", playState, __LINE__);
    repeatMode = NO;
    if (repeatMode) {
        repeatModeView.image = [UIImage imageNamed:@"re_on.png"];
    }
    else repeatModeView.image = [UIImage imageNamed:@"re_off.png"];
    [scrollView setContentSize:CGSizeMake(320, graphView.bounds.size.height)];
    [graphView setFrame:CGRectMake(0, 0, 320, graphView.bounds.size.height)];
    [graphView setUpBookMarkLayer];
    scrollView.contentOffset = CGPointMake(0.0, 0.0);
    [graphView setNeedsDisplay];
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
        NSLog(@"remove time observer %d", __LINE__);
        [avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }

}
- (void)registerTimeObserver {
    if (repeatMode) {
        ViewInfo *startViewInfo = nil;
        ViewInfo *endViewInfo = nil;
        if ([currentSong.pos1 floatValue]!= 0 && [currentSong.pos2 floatValue] != 0) {
            if ([currentSong.pos1 floatValue] < [currentSong.pos2 floatValue])
            {
                startViewInfo = [graphView.viewInfoArray objectAtIndex:[currentSong.pos1 floatValue]];
                endViewInfo = [graphView.viewInfoArray objectAtIndex:[currentSong.pos2 floatValue]];
            }
            else if ([currentSong.pos2 floatValue] < [currentSong.pos1 floatValue]) {
                startViewInfo = [graphView.viewInfoArray objectAtIndex:[currentSong.pos2 floatValue]];
                endViewInfo = [graphView.viewInfoArray objectAtIndex:[currentSong.pos1 floatValue]];
            }
            else {
                NSLog(@"This is very weird case");
                if (timeObserver != nil) {
                    NSLog(@"remove time observer %d", __LINE__);
                    [avPlayer removeTimeObserver:timeObserver];
                    timeObserver = nil;
                }
                return;
            }
            if (timeObserver != nil) {
                NSLog(@"remove time observer %d", __LINE__);
                [avPlayer removeTimeObserver:timeObserver];
                timeObserver = nil;
            }
            CMTime endTime = CMTimeMakeWithSeconds([endViewInfo.time floatValue], 1);
            NSLog(@"Register time observer %d", __LINE__);
            timeObserver = [avPlayer addBoundaryTimeObserverForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:endTime]] queue:NULL usingBlock:^(void) {
                //NSLog(@"time observer fired %d", __LINE__);
                //[avPlayer removeTimeObserver:timeObserver];
                //timeObserver = nil;
                [self setCurrentPostion:[startViewInfo.time floatValue]];
            }];
            
        }
    }
    else 
    {
        if (timeObserver != nil) {
            NSLog(@"remove time observer %d", __LINE__);
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
    NSLog(@"state pause:%d", playState);
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
    NSLog(@"state play:%d", playState);
}

- (void) fastforward
{
    CMTime OneSeconds = CMTimeMake(1, 1);
    CMTime ForwardOneSeconds = CMTimeAdd(avPlayer.currentTime, OneSeconds);
    [avPlayer seekToTime:ForwardOneSeconds];
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
        repeatModeView.image = [UIImage imageNamed:@"re_on.png"];
    }
    else 
    {
        repeatModeView.image = [UIImage imageNamed:@"re_off.png"];
    }
    [self registerTimeObserver];
    
    NSLog(@"repeatMode:%d", repeatMode);
}
- (void) rewind
{
    CMTime OneSeconds = CMTimeMake(1, 1);
    CMTime ReverseOneSeconds = CMTimeSubtract(avPlayer.currentTime, OneSeconds);
    [avPlayer seekToTime:ReverseOneSeconds];
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
    [graphView release];
    [bookMarkArray release];
    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    [playbackTimeLabel release];
    [startTimeLabel release];
    [samplingRateLabel release];
    [totalTimeLabel release];
    [endTimeLabel release];
    [HUD release];
    [startPickerView release];
    [endPickerView release];
    [playListViewController release];
    [avPlayer release];
    [titleView release];
    [songTitleLabel release];
    [songArtistLabel release];
    [repeatModeView release];
    
    [super dealloc];
}

- (void)updatePosition {
    //Float32 temp = [player currentPlaybackTime];
    Float32 temp = CMTimeGetSeconds(avPlayer.currentTime);
    //NSLog(@"update position %f", temp);
	
    [graphView setCurrentPlaybackPosition:temp];
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
    CMTime currentTime = avPlayer.currentTime;
	UInt64 currentTimeSec = currentTime.value / currentTime.timescale;
		
	UInt32 minutes = currentTimeSec / 60;
	UInt32 seconds = currentTimeSec % 60;
	playbackTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
	
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
    MusicWaveAppDelegate *appDelegate = (MusicWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    controller.managedObjectContext = appDelegate.managedObjectContext;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController: controller animated: YES];
    [controller release];
}
- (IBAction) goToBookMark:(id)sender {
    BookMarkListViewController *bookMarkViewController = [[BookMarkListViewController alloc] initWithNibName:@"BookMarkListViewController" bundle:nil];
    bookMarkViewController.mainViewController = self;
    bookMarkViewController.currentSong = self.currentSong;
    bookMarkViewController.bookMarkArray = self.bookMarkArray;
    [self.navigationController pushViewController:bookMarkViewController animated:YES];
    [bookMarkViewController release];

}
- (IBAction) tapBookMarkButton:(id)sender {
    int tag = ((UIButton *)sender).tag;
    NSLog(@"Tapping bookmark button:%d", tag);
    int bookMarkCount = [self.bookMarkArray count];
    if (bookMarkCount < tag) {
        NSLog(@"No book mark available in %d", tag);
        return;
    }
    BookMark *tempBookMark = [self.bookMarkArray objectAtIndex:(tag - 1)];
    
    ViewInfo *tempViewInfo = [graphView.viewInfoArray objectAtIndex:[tempBookMark.position floatValue]];
    [self setCurrentPostion:[tempViewInfo.time floatValue]];
}
-(void)addBookMarkOnPixel:(CGFloat)pixel {
    NSManagedObjectContext *context = [currentSong managedObjectContext];
    
    BookMark *bookMark = [NSEntityDescription insertNewObjectForEntityForName:@"BookMark" inManagedObjectContext:context];
   
    ViewInfo *tempViewInfo = [graphView.viewInfoArray objectAtIndex:pixel - 1];
    bookMark.duration = tempViewInfo.time;
    bookMark.position = [NSNumber numberWithFloat:pixel];
    bookMark.keepDate = [NSDate date];
    [currentSong addBookmarksObject:bookMark];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keepDate" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortedBookMarks = [[NSMutableArray alloc] initWithArray:[currentSong.bookmarks allObjects]];
	[sortedBookMarks sortUsingDescriptors:sortDescriptors];
	self.bookMarkArray = sortedBookMarks;
    
	[sortDescriptor release];
	[sortDescriptors release];
	[sortedBookMarks release];
}
- (IBAction) tapMainButton:(id)sender {
    
    NSLog(@"play state:%d", playState);
	
	if (playState == playBackStatePaused || playState == playBackStatePlaying) {
        [self addBookMarkOnPixel:[graphView currentPixel]];
        [graphView.bookMarkLayer setNeedsDisplay];
        [startPickerView reloadData];
        [endPickerView reloadData];
        int bookMarkCount = [self.bookMarkArray count];
        for ( int i = 0; i < bookMarkCount; i++) {
            BookMark *tempBookMark = [self.bookMarkArray objectAtIndex:i];
            NSLog(@"BookMark count:%d, position:%f, time:%f", bookMarkCount, [tempBookMark.position floatValue], [tempBookMark.duration floatValue]);
        }
    }
}

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    NSLog(@"scroll did scroll offset x:%f y:%f", offset.x, offset.y);
    CGFloat start = offset.x;
    CGFloat end = offset.x + 320;
    if ([graphView.viewInfoArray count] == 0) {
        NSLog(@"viewInfoArray delete");
        return;
    }
    if (start < 0) {
        start = 0;
    }
    if (end > [graphView.viewInfoArray count] - 1) {
        end = [graphView.viewInfoArray count] - 1;
    }
    ViewInfo *startViewInfo = [graphView.viewInfoArray objectAtIndex:start];
    ViewInfo *endViewInfo = [graphView.viewInfoArray objectAtIndex:end];
    UInt64 startTimeSec = [startViewInfo.time floatValue];
    UInt64 endTimeSec = [endViewInfo.time floatValue];
	
	UInt32 minutes = startTimeSec / 60;
	UInt32 seconds = startTimeSec % 60;
	startTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
    
    minutes = endTimeSec / 60;
	seconds = endTimeSec % 60;
	endTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
}
- (void) scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    NSLog(@"scroll did end decelerating offset x:%f y:%f", offset.x, offset.y);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning received");
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - View lifecycle
- (void)settingUpBackgroundView {
    UIImageView *timeBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time_bg.jpg"]];
    timeBackGround.frame = CGRectMake(0, 0, 320, 25);
    UIImageView *pageBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page_bg.jpg"]];
    pageBackGround.frame = CGRectMake(0, 205, 320, 25);
    UIImageView *pickerBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg.jpg"]];
    pickerBackGround.frame = CGRectMake(0, 230, 320, 147);
    
    [self.view addSubview:timeBackGround];
    [self.view addSubview:pageBackGround];
    [self.view addSubview:pickerBackGround];
    
    [timeBackGround release];
    [pageBackGround release];
    [pickerBackGround release];
    
    UIFont *systemFont = [UIFont systemFontOfSize:12.0];
    UILabel *upLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 26.0, 24.0, 16.0)];
    [upLabel setText:@"+1.0"];
    [upLabel setTextAlignment:UITextAlignmentRight];
    [upLabel setTextColor:[UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0]];
    [upLabel setFont:systemFont];
    [upLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:upLabel];
    UILabel *midLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 106.0, 24.0, 16.0)];
    [midLabel setText:@"0.0"];
    [midLabel setTextAlignment:UITextAlignmentRight];
    [midLabel setTextColor:[UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0]];
    [midLabel setFont:systemFont];
    [midLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:midLabel];
    UILabel *downLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 190.0, 24.0, 16.0)];
    [downLabel setText:@"-1.0"];
    [downLabel setTextAlignment:UITextAlignmentRight];
    [downLabel setTextColor:[UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0]];
    [downLabel setFont:systemFont];
    [downLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:downLabel];
    [upLabel release];
    [midLabel release];
    [downLabel release];
}
- (void)settingUpLabel {
    self.playbackTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(139.0f, 0.0f, 46.0f, 25.0f)];
    [playbackTimeLabel setText:@"00:00"];
    [playbackTimeLabel setTextAlignment:UITextAlignmentCenter];
    playbackTimeLabel.textColor = [UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0];
    playbackTimeLabel.backgroundColor = [UIColor clearColor];
    playbackTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    [self.view addSubview:playbackTimeLabel];
    
    self.startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 0.0f, 46.0f, 25.0f)];
    [startTimeLabel setText:@"00:00"];
    [startTimeLabel setTextAlignment:UITextAlignmentCenter];
    startTimeLabel.textColor = [UIColor colorWithRed:107.0/255.0f green:114.0/255.0f blue:133.0/255.0f alpha:1.0];
    startTimeLabel.backgroundColor = [UIColor clearColor];
    startTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    [self.view addSubview:startTimeLabel];
    
    self.endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(265.0f, 0.0f, 46.0f, 25.0f)];
    [endTimeLabel setText:@"00:00"];
    [endTimeLabel setTextAlignment:UITextAlignmentCenter];
    endTimeLabel.textColor = [UIColor colorWithRed:107.0/255.0f green:114.0/255.0f blue:133.0/255.0f alpha:1.0];
    endTimeLabel.backgroundColor = [UIColor clearColor];
    endTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    [self.view addSubview:endTimeLabel];
    
    self.samplingRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0f, 230.0f, 89.0f, 18.0f)];
    [samplingRateLabel setText:@""];
    [samplingRateLabel setTextAlignment:UITextAlignmentCenter];
    samplingRateLabel.textColor = [UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0];
    samplingRateLabel.backgroundColor = [UIColor clearColor];
    samplingRateLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    [self.view addSubview:samplingRateLabel];
    
    self.totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(265.0f, 230.0f, 46.0f, 18.0f)];
    [totalTimeLabel setText:@"00:00"];
    [totalTimeLabel setTextAlignment:UITextAlignmentCenter];
    totalTimeLabel.textColor = [UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0];
    totalTimeLabel.backgroundColor = [UIColor clearColor];
    totalTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(11.0)];
    [self.view addSubview:totalTimeLabel];
}
- (void)settingUpPicker {
    UIImageView *leftBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg_basic.png"]];
    leftBackGround.frame = CGRectMake(12, 246, 104, 66);
    [self.view addSubview:leftBackGround];
    [leftBackGround release];

    CGRect leftFrame = CGRectMake(12.0f, 246.0f, 104.0f, 66.0f);
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
	UIImageView *startIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_cell.png"]];
    startIndicator.layer.opacity = 0.56f;
	startPickerView.selectionIndicatorView = startIndicator;
	startPickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location
	[startIndicator release];
    
	// add gradient images to left and right of view if desired
    UIImageView *startLeftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg_left.png"]];
    startPickerView.leftEdgeView = startLeftFade;
    [startLeftFade release];
    //
    UIImageView *startRightFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg_right.png"]];
    startPickerView.rightEdgeView = startRightFade;
    [startRightFade release];
    [self.view addSubview:startPickerView];
    
    UIImageView *rightBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg_basic.png"]];
    rightBackGround.frame = CGRectMake(204, 246, 104, 66);
    [self.view addSubview:rightBackGround];
    [rightBackGround release];
    CGRect rightFrame = CGRectMake(204.0f, 246.0f, 104.0f, 66.0f);
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
	UIImageView *endIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_cell.png"]];
    endIndicator.layer.opacity = 0.56f;
	endPickerView.selectionIndicatorView = endIndicator;
	endPickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location
	[endIndicator release];
    
	// add gradient images to left and right of view if desired
    UIImageView *endLeftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg_left.png"]];
    endPickerView.leftEdgeView = endLeftFade;
    [endLeftFade release];
    //
    UIImageView *endRightFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_bg_right.png"]];
    endPickerView.rightEdgeView = endRightFade;
    [endRightFade release];
    [self.view addSubview:endPickerView];
}
- (void)settingUpBookMarkButton {
    mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mainButton.frame = CGRectMake(127.0f, 246.0f, 65.0f, 79.0f);
    
    [mainButton setBackgroundImage:[UIImage imageNamed:@"btn_bookmark_off.png"] forState:UIControlStateNormal];
    [mainButton setBackgroundImage:[UIImage imageNamed:@"btn_bookmark_on.png"] forState:UIControlStateSelected];
    [mainButton setBackgroundImage:[UIImage imageNamed:@"btn_bookmark_on.png"] forState:UIControlStateHighlighted];
    [mainButton addTarget:self action:@selector(tapMainButton:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:mainButton];
}
- (void)settingUpVolumeSlider {
    UIImageView *soundOffImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sound_off.png"]];
    soundOffImage.frame = CGRectMake(21, 407-64, 14, 10);
    [self.view addSubview:soundOffImage];
    [soundOffImage release];
    
    UIImageView *soundOnImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sound_on.png"]];
    soundOnImage.frame = CGRectMake(288, 407-64, 14, 10);
    [self.view addSubview:soundOnImage];
    [soundOnImage release];
    
    CGRect frame = CGRectMake(44, 407-64-5, 235, 9);
    UISlider *customSlider = [[UISlider alloc] initWithFrame:frame];
    MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:[customSlider frame]] autorelease];
    UISlider *volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
		if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
			volumeViewSlider = (UISlider *) view;
		}
	}
    volumeViewSlider.backgroundColor = [UIColor clearColor];	
    UIImage *stetchLeftTrack = [[UIImage imageNamed:@"bar_on.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0];
    UIImage *stetchRightTrack = [[UIImage imageNamed:@"bar_off.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0];
    [volumeViewSlider setThumbImage: [UIImage imageNamed:@"sound_controll.png"] forState:UIControlStateNormal];
    [volumeViewSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [volumeViewSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    [customSlider removeFromSuperview];
    [self.view addSubview:volumeView];
    [customSlider release];
    //[volumeView release];
}
- (void)applicationWillResign {
    NSLog(@"application will resign");
}
- (void)applicationWillEnterForeground {
    NSLog(@"application will enter foreground");
    if (avPlayer.rate == 0.0f && playState == playBackStatePlaying) {
        NSLog(@"avPlayer rate is 0");
        NSLog(@"self playstae:%d", playState);
        [self pause];
    }
    else
    {
        NSLog(@"avPlayer rate is %f", avPlayer.rate);
        NSLog(@"self playstate:%d", playState);
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(songsPicked:) name:@"SongsPicked" object:nil];
    [notificationCenter addObserver:self selector:@selector(applicationWillResign) name:UIApplicationWillResignActiveNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    //self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    //self.navigationController.navigationBar.translucent = YES;
    self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"My List", @selector(goToMyList:));
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"BookMarks", @selector(goToBookMark:));
    self.title = @"Back";
    avPlayer = nil;
    //self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    UIView *btn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    //btn.backgroundColor = [UIColor whiteColor];
    
    //UILabel *label;
    self.songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 160, 32)];
    self.songTitleLabel.tag = 1;
    self.songTitleLabel.backgroundColor = [UIColor clearColor];
    self.songTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.songTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.songTitleLabel.textAlignment = UITextAlignmentCenter;
    self.songTitleLabel.textColor = [UIColor whiteColor];
    self.songTitleLabel.text = @"MusicWave";
    self.songTitleLabel.highlightedTextColor = [UIColor blackColor];
    [btn addSubview:self.songTitleLabel];
    //[label release];
    
    self.songArtistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, 160, 12)];
    self.songArtistLabel.tag = 2;
    self.songArtistLabel.backgroundColor = [UIColor clearColor];
    self.songArtistLabel.font = [UIFont boldSystemFontOfSize:12];
    self.songArtistLabel.adjustsFontSizeToFitWidth = NO;
    self.songArtistLabel.textAlignment = UITextAlignmentCenter;
    self.songArtistLabel.textColor = [UIColor whiteColor];
    self.songArtistLabel.text = @"";
    self.songArtistLabel.highlightedTextColor = [UIColor blackColor];
    [btn addSubview:self.songArtistLabel];
    //[label release];
    
    self.navigationItem.titleView = btn;
    
    self.currentSong = nil;
    //scrollView.delegate = self;
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    
    
    
    
    //self.navigationItem.leftBarButtonItem = BARBUTTON(@"My List", @selector(selectSongs:));
    
    	
    [graphView setParent:self];
    //playState = playBackStateNone;
    //[self imageViewTest];
    [self settingUpBackgroundView];
    [self settingUpLabel];
    [self settingUpPicker];
    [self settingUpBookMarkButton];
    [self settingUpVolumeSlider];
    
    self.repeatModeView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.repeatModeView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.repeatModeView.frame = CGRectMake(151, 211, 21, 13);
    if (repeatMode) {
        repeatModeView.image = [UIImage imageNamed:@"re_on.png"];
    }
    else repeatModeView.image = [UIImage imageNamed:@"re_off.png"];
    [self.view addSubview:repeatModeView];

    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
    NSLog(@"main view did load");
    
}
#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
	return [self.bookMarkArray count] + 1;
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    //BookMark *mark = [currentSong.bookMarkArray objectAtIndex:index];
    NSString *returnString = @"N";
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
	return textSize.width + 20.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
	//self.infoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
    NSLog(@"picker view selected index %d tag:%d", index, picker.tag);
    if (index == 0) {
        if (picker.tag == 0) {
            currentSong.pos1 = [NSNumber numberWithFloat:0.f];
        }
        else {
            currentSong.pos2 = [NSNumber numberWithFloat:0.f];
        }
        [graphView.bookMarkLayer setNeedsDisplay];
        return;
    }
    
    int bookMarkCount = [self.bookMarkArray count];
    if (bookMarkCount < index) {
        NSLog(@"No book mark available in %d", index);
        return;
    }
    BookMark *tempBookMark = [self.bookMarkArray objectAtIndex:index - 1];
    if (picker.tag == 0) {
        currentSong.pos1 = tempBookMark.position;
    }
    else {
        currentSong.pos2 = tempBookMark.position;
    }
        ViewInfo *tempViewInfo = [graphView.viewInfoArray objectAtIndex:[tempBookMark.position floatValue]];
    NSLog(@"bookMark position:%f, time:%f", [tempBookMark.position floatValue], [tempViewInfo.time floatValue]);
    [self setCurrentPostion:[tempViewInfo.time floatValue]];
    //[self updatePosition];
    CGFloat moveOffset = [tempBookMark.position floatValue] - scrollView.bounds.size.width / 2;
   
    if (scrollView.contentSize.width - [tempBookMark.position floatValue] < scrollView.bounds.size.width / 2) {
        moveOffset = scrollView.contentSize.width - scrollView.bounds.size.width; 
    }
    if (moveOffset < 0) {
        moveOffset = 0;
    }
    [scrollView setContentOffset:CGPointMake(moveOffset, 0.0)];
    [graphView.bookMarkLayer setNeedsDisplay];
    [graphView setCurrentPlaybackPosition:[tempViewInfo.time floatValue]];
    [self registerTimeObserver];
    //[graphView.layer setNeedsDisplay];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"main view will appear");
    [graphView.bookMarkLayer setNeedsDisplay];
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
        [self play];
	}
}
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [avPlayer seekToTime:kCMTimeZero];
    [graphView.layer setNeedsDisplay];
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
