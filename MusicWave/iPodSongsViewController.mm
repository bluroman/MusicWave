//
//  iPodSongsViewController.m
//  iPodSongs
//
//  Created by hun nam on 11. 5. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iPodSongsViewController.h"
#import "ViewInfo.h"
#import "MusicWaveAppDelegate.h"
#import "MyScrollView.h"
//#import "PlayListViewController.h"
#import "BookMarkViewController.h"
#import "MusicTableViewController.h"
#import "BookMark.h"
#import "AutoScrollLabel.h"
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define IMGBARBUTTON(IMAGE, SELECTOR) [[[UIBarButtonItem alloc] initWithImage:IMAGE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define TMP NSTemporaryDirectory()
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)
#define ZOOM_STEP 2.0f

@implementation iPodSongsViewController
//@synthesize graphView;
@synthesize scrollView, graphImage;
@synthesize currentSong;
@synthesize playbackTimeLabel;
@synthesize remainTimeLabel;
@synthesize startTimeLabel, endTimeLabel;
//@synthesize samplingRateLabel; //totalTimeLabel;
@synthesize mainButton;
@synthesize startPickerView, endPickerView;
@synthesize playListViewController;
@synthesize avPlayer;
@synthesize playState;
@synthesize bookMarkArray;
//@synthesize repeatModeView;
@synthesize songTitleLabel, songArtistLabel;
@synthesize managedObjectContext;
@synthesize startPickerTime, endPickerTime;
@synthesize delta;
//@synthesize selectedCurrentSong;
+ (NSString *) assetCacheFolder  {
    NSArray  *assetFolderRoot = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [NSString stringWithFormat:@"%@/audio", [assetFolderRoot objectAtIndex:0]];
}
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (NSString *) cachedAudioPictogramPathForCurrentSong{
    NSString *assetFolder = [[self class] assetCacheFolder];
    NSNumber * libraryId = currentSong.persistentId;
    NSString *assetPictogramFilename = [NSString stringWithFormat:@"asset_%@.%@",libraryId,imgExt];
    return [NSString stringWithFormat:@"%@/%@", assetFolder, assetPictogramFilename];
    
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
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
    else
    {
        NSLog(@"No File exists on cache:%@", uniquePath);
    }
    
    return image;
}
- (void) cacheImage
{
    
    // Generate a unique path to a resource representing the image you want
    NSNumber * libraryId = currentSong.persistentId;
    NSString *assetPictogramFilename = [NSString stringWithFormat:@"asset_%@.%@",libraryId,imgExt];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: assetPictogramFilename];
    
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath] && self.graphImage != nil)
    {
        // The file doesn't exist, we should get a copy of it
        NSLog(@"File does not exist so write file to:%@", uniquePath);
        
        [imageToData(self.graphImage) writeToFile: uniquePath atomically: YES];
        currentSong.graphPath = uniquePath;
    }
}
-(UIImage *) audioImageGraph:(SInt16 *) samples
                normalizeMax:(SInt16) normalizeMax
                 sampleCount:(NSInteger) sampleCount
                channelCount:(NSInteger) channelCount
                 imageHeight:(float) imageHeight {
    
    CGSize imageSize = CGSizeMake(sampleCount, imageHeight);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetAlpha(context,1.0);
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    //CGColorRef leftcolor = [[UIColor whiteColor] CGColor];
    //CGColorRef rightcolor = [[UIColor redColor] CGColor];
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0);
    
    float halfGraphHeight = (imageHeight / 2) / (float) channelCount ;
    float centerLeft = halfGraphHeight;
    //float centerRight = (halfGraphHeight*3) ;
    float sampleAdjustmentFactor = (imageHeight/ (float) channelCount) / (float) normalizeMax;
    
    /*for (NSInteger intSample = 1 ; intSample < sampleCount + 1 ; intSample ++ ) {
        SInt16 left = *samples++;
        float pixels = (float) left;
        pixels *= sampleAdjustmentFactor;
        CGContextMoveToPoint(context, intSample, centerLeft-pixels);
        CGContextAddLineToPoint(context, intSample, centerLeft+pixels);
        CGContextSetStrokeColorWithColor(context, leftcolor);
        CGContextStrokePath(context);
        
        if (channelCount==2) {
            SInt16 right = *samples++;
            float pixels = (float) right;
            pixels *= sampleAdjustmentFactor;
            CGContextMoveToPoint(context, intSample, centerRight - pixels);
            CGContextAddLineToPoint(context, intSample, centerRight + pixels);
            CGContextSetStrokeColorWithColor(context, rightcolor);
            CGContextStrokePath(context);
        }
    }*/
    centerLeft = imageHeight / 2;
    sampleAdjustmentFactor = imageHeight/ (float) normalizeMax;
    CGMutablePathRef maxPath = CGPathCreateMutable();
    CGContextTranslateCTM(context, 0.0, imageHeight / 2);
    CGPathMoveToPoint(maxPath, NULL, 0, 0);
    for (NSInteger i = 1; i < sampleCount + 1; i++) {
        SInt16 left = *samples++;
        float pixels = (float) left;
        pixels *= sampleAdjustmentFactor;
        CGPathAddLineToPoint(maxPath, NULL, i, pixels);
        if (channelCount==2) {
            SInt16 right = *samples++;
            float pixels = (float) right;
            pixels *= sampleAdjustmentFactor;
        }
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath( path, NULL, maxPath );
    
    
    CGAffineTransform xf = CGAffineTransformIdentity;
    xf = CGAffineTransformScale(xf, 1.0, -1.0);
    
    CGPathAddPath( path, &xf, maxPath );
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    CGContextClip(context);
    // Declare the gradient
    CGGradientRef myGradient;
    
    //	Define the color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Define the color components of the gradient
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.1,  // Start color
        1.0, 1.0, 1.0, 0.9 }; // End color
    
    // Define the location of each component
    int num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    // Create the gradient
    myGradient = CGGradientCreateWithColorComponents (colorSpace, components,
                                                      locations, num_locations);
    
    // Draw the gradient
    CGContextDrawLinearGradient (context, myGradient, CGPointMake(0, -90),
                                 CGPointMake(0, 90), 0);
    
	//	Clean up the color space & gradient
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(myGradient);
    
    CGPathRelease(maxPath);
    CGPathRelease(path);

    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (void) renderPNGAudioPictogramForAsset:(AVURLAsset *)songAsset {
    NSError * error = nil;
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
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    [output release];
    
    UInt32 sampleRate,channelCount;
    NSArray* formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = ( CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if(fmtDesc ) {
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
            NSLog(@"channels:%lu, bytes/packet: %lu, sampleRate %f",fmtDesc->mChannelsPerFrame, fmtDesc->mBytesPerPacket,fmtDesc->mSampleRate);
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    SInt16 normalizeMax = 0;
    NSMutableData * fullSongData = [[NSMutableData alloc] init];
    NSLog(@"Duration:%f, %f", CMTimeGetSeconds(songAsset.duration), [currentSong.songDuration doubleValue]);
    CMTime duration = CMTimeMakeWithSeconds([currentSong.songDuration doubleValue], 1.0);
    CMTime start = CMTimeMakeWithSeconds(0.0, 1.0);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    reader.timeRange = range;
    
    [reader startReading];
    
    UInt64 totalBytes = 0;
    SInt64 totalLeft = 0;
    SInt64 totalRight = 0;
    NSInteger sampleTally = 0;
    NSInteger samplesPerPixel = sampleRate / 50;
    
    while (reader.status == AVAssetReaderStatusReading){
        
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef){
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            //NSLog(@"Total:%lld, Length:%zd", totalBytes, length);
            NSMutableData * data = [NSMutableData dataWithLength:length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
                
            SInt16 * samples = (SInt16 *) data.mutableBytes;
            int sampleCount = length / bytesPerSample;
            for (int i = 0; i < sampleCount ; i ++) {
                SInt16 left = *samples++;
                totalLeft  += left;
                SInt16 right;
                if (channelCount==2) {
                    right = *samples++;
                    totalRight += right;
                }
                sampleTally++;
                if (sampleTally > samplesPerPixel) {
                    left  = totalLeft / sampleTally;
                    SInt16 fix = abs(left);
                    if (fix > normalizeMax) {
                        normalizeMax = fix;
                    }
                    //NSLog(@"appendleft:%d", left);
                    [fullSongData appendBytes:&left length:sizeof(left)];
                    if (channelCount==2) {
                        right = totalRight / sampleTally;
                        SInt16 fix = abs(right);
                        if (fix > normalizeMax) {
                            normalizeMax = fix;
                        }
                        [fullSongData appendBytes:&right length:sizeof(right)];
                    }
                    totalLeft   = 0;
                    totalRight  = 0;
                    sampleTally = 0;
                }
            }
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }
    //NSData * finalData = nil;
    if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown){
        // Something went wrong. return nil
        return;
    }
    
    if (reader.status == AVAssetReaderStatusCompleted){
        
        NSLog(@"rendering output graphics using normalizeMax %d, %d, %lld",normalizeMax,fullSongData.length/4, totalBytes);
        
        self.graphImage = [self audioImageGraph:(SInt16 *)
                         fullSongData.bytes
                                 normalizeMax:normalizeMax
                                  sampleCount:fullSongData.length / (2*channelCount)
                                 channelCount:channelCount
                                  imageHeight:self.myScrollView.frame.size.height];
        //NSLog(@"Image width:%f, height:%f", test.size.width, test.size.height);
        NSLog(@"Maximum scale factor:%f", self.graphImage.size.width / self.myScrollView.frame.size.width);
        //delta = [currentSong.songDuration floatValue]/self.graphImage.size.width;
        
        [self cacheImage];
        currentSong.doneGraphDrawing = [NSNumber numberWithBool:YES];
        
        
        
        //finalData = imageToData(graphImage);
        //NSLog(@"Image Data Length:%d", [finalData length]);
        NSManagedObjectContext *context = [currentSong managedObjectContext];
        NSError *error = nil;
        
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            NSLog(@"Saving graph error");
        }

    }
    
    
    
    
    [fullSongData release];
    [reader release];
    
    //return finalData;
}
- (void)redrawWithSize:(float)scalefactor {
    BOOL isPlaying = NO;

    CGFloat newWidth = scalefactor * self.myScrollView.contentSize.width;
    if (newWidth < self.myScrollView.frame.size.width) {
        if (self.myScrollView.contentSize.width == self.myScrollView.frame.size.width)
            return;
        NSLog(@"Too small so setting to default");
        newWidth = self.myScrollView.frame.size.width;
    }
    else if (newWidth > maximumWidth)
    {
        if (self.myScrollView.contentSize.width == maximumWidth)
            return;
        NSLog(@"Too large so setting to original");
        newWidth = maximumWidth;
    }
    CGSize newSize = CGSizeMake(newWidth, self.myScrollView.frame.size.height);
    //NSLog(@"Current Image width:%f, height:%f", resizeImage.size.width, resizeImage.size.height);
    [self.myScrollView setContentSize:newSize];
    //[self.myGraphView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
    //[self.myGraphView.graphImageView sizeThatFits:newSize];
    [self.myScrollView.graphImageView setFrame:CGRectMake(0,0,newSize.width,newSize.height)];
    delta = [currentSong.songDuration doubleValue]/newSize.width;
    [self.myScrollView setDelta:delta];
    [self.myScrollView settingStartEndTime:startPickerTime endPosition:endPickerTime];
    [self.myScrollView.bookMarkLayer setNeedsDisplay];
    
    if (playState == playBackStatePlaying) {
        isPlaying = YES;
        [self pause];
    }
    Float32 temp = CMTimeGetSeconds(avPlayer.currentTime);
    
    CGFloat moveOffset = temp/self.delta - self.myScrollView.bounds.size.width / 2;
    
    if (self.myScrollView.contentSize.width - temp / self.delta < self.myScrollView.bounds.size.width / 2) {
        moveOffset = self.myScrollView.contentSize.width - self.myScrollView.bounds.size.width;
    }
    if (moveOffset < 0) {
        moveOffset = 0;
    }
    [self.myScrollView setContentOffset:CGPointMake(moveOffset, 0.0)];
    //NSLog(@"update position %f", temp);
	
    [self.myScrollView setCurrentPlaybackPosition:temp/delta];
    if (isPlaying) {
        [self play];
    }
}
- (void)loadCompleteImage {
    //int pixelCount = [total intValue];
    //self.graphImage = [[self class] imageWithImage:graphImage scaledToSize:CGSizeMake(300, 157)];
    NSLog(@"Load Image width:%f, height:%f", graphImage.size.width, graphImage.size.height);
    delta = [currentSong.songDuration floatValue]/self.graphImage.size.width;
    [self.myScrollView setDelta:delta];
    maximumWidth = graphImage.size.width;
    [self.myScrollView setContentSize:graphImage.size];
    //[self.myGraphView setFrame:CGRectMake(0, 0, graphImage.size.width, graphImage.size.height)];
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:graphImage];
    self.myScrollView.graphImageView.image = graphImage;
    [self.myScrollView.graphImageView setFrame:CGRectMake(0,0,graphImage.size.width,graphImage.size.height)];
    //[self.myGraphView addSubview:imageView];
    
    [self.myScrollView setUpBookMarkLayer];
    self.myScrollView.contentOffset = CGPointMake(0.0, 0.0);
    [self.myScrollView settingStartEndTime:startPickerTime endPosition:endPickerTime];
    [self.myScrollView setNeedsDisplay];
    [self setUpAVPlayerForURL:[NSURL URLWithString:currentSong.songURL]];
    [self.startPickerView scrollToElement:0 animated:NO];
    [self.endPickerView scrollToElement:0 animated:NO];
    
    [self playerTimerUpdate:nil];
    
    //[HUD hide:YES];
    //[self.view setAlpha:1.0f];
}

- (void)updateCurrentSong {
    if (playState == playBackStatePlaying) {
        [self pause];
    }
    self.myScrollView.currentSong = currentSong;
    self.graphImage = [self getCachedImage];
    //self.graphImage = currentSong.graphImage;
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
    //UInt64 songDuration = CMTimeGetSeconds(songAsset.duration);
    
    delta = [currentSong.songDuration doubleValue]/self.graphImage.size.width;
    [self.myScrollView setDelta:delta];

	
	//UInt32 minutes = songDuration / 60;
	//UInt32 seconds = songDuration % 60;
	//totalTimeLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
    //samplingRateLabel.text = [NSString stringWithFormat:@"%dHz", songSampleRate];
    self.songTitleLabel.text = currentSong.songTitle;
    self.songArtistLabel.text = currentSong.songArtist;
    playState = playBackStateNone;
    repeatMode = NO;
    self.startPickerTime = 0.f;
    self.endPickerTime = 0.f;
    if (timeObserver != nil) {
        [avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    movingOffset = NO;
    if (repeatMode) {
        [repeatButton setBackgroundImage:[UIImage imageNamed:@"repeat_on_test.png"] forState:UIControlStateNormal];
        //repeatModeView.image = [UIImage imageNamed:@"repeat_on_test.png"];
    }
    else [repeatButton setBackgroundImage:[UIImage imageNamed:@"repeat_off_test.png"] forState:UIControlStateNormal];//repeatModeView.image = [UIImage imageNamed:@"repeat_off_test.png"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keepDate" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortedBookMarks = [[NSMutableArray alloc] initWithArray:[currentSong.bookmarks allObjects]];
	[sortedBookMarks sortUsingDescriptors:sortDescriptors];
	self.bookMarkArray = sortedBookMarks;
    
    
	[sortDescriptor release];
	[sortDescriptors release];
	[sortedBookMarks release];

    [self drawingCurrentGraphViewDispatchQueue];
    
}
- (void)drawingCurrentGraphViewDispatchQueue {
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    BOOL isGraphDrawing = [currentSong.doneGraphDrawing boolValue];
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    if (!isGraphDrawing) {
        HUD.labelText = NSLocalizedString(@"Loading", @"Main View Hud loading hud label");
        HUD.detailsLabelText = NSLocalizedString(@"Information", @"Main View Hud loading hud detail label");
        self.myScrollView.graphImageView.image = nil;
        [self.myScrollView setContentSize:CGSizeMake(self.myScrollView.frame.size.width, self.myScrollView.frame.size.height)];
        self.myScrollView.contentOffset = CGPointMake(0.0, 0.0);
        [self.myScrollView setNeedsDisplay];
    }
    else {
        HUD.labelText = NSLocalizedString(@"Drawing", @"Main View Hud drawing label");
        HUD.detailsLabelText = NSLocalizedString(@"Graph", @"Main View Hud drawing detail label");
    }
    
    dispatch_async(concurrentQueue, ^{
        self.navigationItem.leftBarButtonItem.enabled = NO;
        dispatch_sync(concurrentQueue, ^{
            //Download image
            if (!isGraphDrawing) {
                AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:currentSong.songURL] options:nil];
                //[self extractDataFromAsset:songAsset];
                [self renderPNGAudioPictogramForAsset:songAsset];
            }
        });
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Show image to user
            //id idVar = [NSNumber numberWithInt: [currentSong.viewinfos count]];
            //[self loadComplete:idVar];
            [self loadCompleteImage];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        });
        self.navigationItem.leftBarButtonItem.enabled = YES;
    });
    
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
    self.myScrollView.currentSong = self.currentSong;
    self.graphImage = nil;
    self.myScrollView.graphImageView.image = nil;
    [self.bookMarkArray removeAllObjects];
    //totalTimeLabel.text = @"00:00";
    //samplingRateLabel.text = @"";
    playbackTimeLabel.text = @"00:00";
    remainTimeLabel.text = @"00:00";
    startTimeLabel.text = @"00:00";
    endTimeLabel.text = @"00:00";
    self.songTitleLabel.text = @"MusicWave";
    self.songArtistLabel.text = @"";
    playState = playBackStateNone;
    [startPickerView reloadData];
    [endPickerView reloadData];
    //NSLog(@"state none:%d line:%d", playState, __LINE__);
    repeatMode = NO;
    if (repeatMode) {
        [repeatButton setBackgroundImage:[UIImage imageNamed:@"repeat_on_test.png"] forState:UIControlStateNormal];
        //repeatModeView.image = [UIImage imageNamed:@"repeat_on_test.png"];
    }
    else [repeatButton setBackgroundImage:[UIImage imageNamed:@"repeat_off_test.png"] forState:UIControlStateNormal];//repeatModeView.image = [UIImage imageNamed:@"repeat_off_test.png"];
    [self.myScrollView setContentSize:CGSizeMake(self.myScrollView.frame.size.width, self.myScrollView.frame.size.height)];
    //[self.myGraphView setFrame:CGRectMake(0, 0, 280, self.myGraphView.bounds.size.height)];
    [self.myScrollView setUpBookMarkLayer];
    self.myScrollView.contentOffset = CGPointMake(0.0, 0.0);
    [self.myScrollView setNeedsDisplay];
    if (timeObserver != nil) {
        [avPlayer removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    [avPlayer release];
    avPlayer = nil;
    [self toolBarIsNil];
    //[toolBar setItems:nil];
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
        CGFloat startTime,endTime;
        //CGFloat position = 0.;
        if (self.startPickerTime != 0 && self.endPickerTime != 0) {
            if (self.startPickerTime  < self.endPickerTime)
            {
                startTime = self.startPickerTime;
                endTime = self.endPickerTime;
                //position = self.startPickerTime / delta;
            }
            else if (self.endPickerTime < self.startPickerTime) {
                startTime = self.endPickerTime;
                endTime = self.startPickerTime;
                //position = self.endPickerTime / delta;
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
            CMTime endedTime = CMTimeMakeWithSeconds(endTime, 1);
            //NSLog(@"Register time observer %d", __LINE__);
            timeObserver = [avPlayer addBoundaryTimeObserverForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:endedTime]] queue:NULL usingBlock:^(void) {
                //NSLog(@"time observer fired %d", __LINE__);
                //[avPlayer removeTimeObserver:timeObserver];
                //timeObserver = nil;
                [self setCurrentPostion:startTime];
                CGFloat position = startTime / delta;
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

#pragma mark PLAYBACK
- (void) pause
{
    //toolBar.items = [self playItems];
    [self toolBarPlay];
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
    //toolBar.items = [self pauseItems];
    [self toolBarPause];
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
        [repeatButton setBackgroundImage:[UIImage imageNamed:@"repeat_on_test.png"] forState:UIControlStateNormal];
        //repeatModeView.image = [UIImage imageNamed:@"repeat_on_test.png"];
    }
    else 
    {
        [repeatButton setBackgroundImage:[UIImage imageNamed:@"repeat_off_test.png"] forState:UIControlStateNormal];
        //repeatModeView.image = [UIImage imageNamed:@"repeat_off_test.png"];
    }
    [self registerTimeObserver];
    
    //NSLog(@"repeatMode:%d", repeatMode);
}
- (void) fastforwardDown
{
    NSLog(@"fastforward down");
    if (playState != playBackStatePlaying)
        return;
    avPlayer.rate = +2.0f;
}
- (void) fastforwardRelease
{
    NSLog(@"fastforward release");
    if (playState != playBackStatePlaying)
        return;
    avPlayer.rate = 1.0f;
}
- (void) rewindDown
{
    NSLog(@"rewind down");
    if (playState != playBackStatePlaying)
        return;
    avPlayer.rate = -2.0f;
}
- (void) rewindRelease
{
    NSLog(@"rewind release");
    if (playState != playBackStatePlaying)
        return;
    avPlayer.rate = 1.0f;
}
- (void) rewind
{
    CMTime OneSeconds = CMTimeMake(1 * 1000, 1000);
    CMTime ReverseOneSeconds = CMTimeSubtract(avPlayer.currentTime, OneSeconds);
    [avPlayer seekToTime:ReverseOneSeconds];
    [self updatePosition];
}
- (void) zoom_in
{
    [self redrawWithSize:ZOOM_STEP];
}
- (void) zoom_out
{
    [self redrawWithSize:1.0f/ZOOM_STEP];
}
#pragma mark Music notification handlers__________________
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [mpVolumeView release];
    [graphImage release];
    //[self.myGraphView release];
    [bookMarkArray release];
    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    [playbackTimeLabel release];
    [remainTimeLabel release];
    [startTimeLabel release];
    //[samplingRateLabel release];
    //[totalTimeLabel release];
    [endTimeLabel release];
    //[HUD release];
    [startPickerView release];
    [endPickerView release];
    [playListViewController release];
    [avPlayer release];
    [songTitleLabel release];
    [songArtistLabel release];
    //[repeatModeView release];
    [managedObjectContext release];
    [super dealloc];
}

- (void)updatePosition {
    //Float32 temp = [player currentPlaybackTime];
    Float32 temp = CMTimeGetSeconds(avPlayer.currentTime);
    //NSLog(@"update position %f", temp);
	
    [self.myScrollView setCurrentPlaybackPosition:temp/delta];
    if (self.myScrollView.contentSize.width < self.myScrollView.bounds.size.width) {
        movingOffset = NO;
        return;
    }
    
    if(movingOffset == NO && self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width - 20 < self.myScrollView.currentPixel && self.myScrollView.currentPixel < self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width)
    {
       //NSLog(@"Current PlayBack Position:%f, contentOffset:%f, width:%f", self.myGraphView.currentPixel, self.myScrollView.contentOffset.x, self.myScrollView.bounds.size.width);
        movingOffset = YES;
    }
    if (movingOffset) {
        if (self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width / 2 > self.myScrollView.currentPixel || self.myScrollView.currentPixel > self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width) {
            movingOffset = NO;
        }
    }
    if (movingOffset) {
        
        CGFloat moveOffset = self.myScrollView.contentOffset.x + (1.0f / delta + 10.0f) / 20.0f;
        [self.myScrollView setContentOffset:CGPointMake(moveOffset, 0.0)];
        if (self.myScrollView.currentPixel < self.myScrollView.contentOffset.x + self.myScrollView.bounds.size.width/2) {
            movingOffset = NO;
        }
    }
        
        
}
- (void)setCurrentPostion:(int)value {
    //CGFloat temp = value*delta;
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
	playbackTimeLabel.text = [NSString stringWithFormat: @"%02ld:%02ld", minutes, seconds];
    
    minutes = remainTimeSec / 60;
	seconds = remainTimeSec % 60;
	remainTimeLabel.text = [NSString stringWithFormat: @"-%02ld:%02ld", minutes, seconds];
    
    //mainSlider.value = (currentTimeSec / [currentSong.songDuration floatValue]);
	
}
- (void) musicTableViewControllerDidFinish: (UIViewController *) controller {
	[controller dismissModalViewControllerAnimated: YES];
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

-(void)addBookMarkOnPixel:(CGFloat)pixel {
    NSManagedObjectContext *context = [currentSong managedObjectContext];
    NSError *error = nil;
    
    BookMark *bookMark = [NSEntityDescription insertNewObjectForEntityForName:@"BookMark" inManagedObjectContext:context];
   
    bookMark.duration = [NSNumber numberWithFloat:pixel*delta];
    bookMark.delta = [NSNumber numberWithFloat:delta];
    bookMark.keepDate = [NSDate date];
    [self.bookMarkArray addObject:bookMark];
    [currentSong addBookmarksObject:bookMark];
    
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
- (IBAction) tapMainButton:(id)sender {
    
    //NSLog(@"play state:%d", playState);
	
	//if (playState == playBackStatePaused || playState == playBackStatePlaying) {
    if ([currentSong.doneGraphDrawing boolValue]) {
        [self addBookMarkOnPixel:[self.myScrollView currentPixel]];
        [self.myScrollView.bookMarkLayer setNeedsDisplay];
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
    if (self.graphImage.size.width == 0) {
        //NSLog(@"viewInfoArray delete");
        return;
    }
    if (start < 0) {
        start = 0;
    }
    if (end > self.graphImage.size.width) {
        end = self.graphImage.size.width;
    }
    
    UInt64 startTimeSec = start * delta;
    UInt64 endTimeSec = end * delta;
	
	UInt32 minutes = startTimeSec / 60;
	UInt32 seconds = startTimeSec % 60;
	startTimeLabel.text = [NSString stringWithFormat: @"%02ld:%02ld", minutes, seconds];
    
    minutes = endTimeSec / 60;
	seconds = endTimeSec % 60;
	endTimeLabel.text = [NSString stringWithFormat: @"%02ld:%02ld", minutes, seconds];
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
#pragma mark - View lifecycle
- (void)settingUpBackgroundView {
    /*UIImageView *upper_toolbar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbar_back.png"]];
    upper_toolbar.frame = CGRectMake(0,  0, 320, 44);
    [self.view addSubview:upper_toolbar];
    [upper_toolbar release];*/
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainview_bg2.png"]];
    backGround.frame = CGRectMake(0,  0, 320, 392);
    [self.view addSubview:backGround];
    [backGround release];
    UIImageView *upper_bar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upper_bar.png"]];
    upper_bar.frame = CGRectMake(0,  0, 320, 32);
    [self.view addSubview:upper_bar];
    [upper_bar release];
    UIImageView *tool_bar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbar_back.png"]];
    tool_bar.frame = CGRectMake(0,  392, 320, 44);
    [self.view addSubview:tool_bar];
    [tool_bar release];
    //UIImageView *graph_below = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graph_below.png"]];
    //graph_below.frame = CGRectMake(0,  240, 320, 143);
    //[self.view addSubview:graph_below];
    //[graph_below release];
    

}
- (void)settingUpLabel {
    self.startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0f, 5.0f, 60.0f, 20.0f)];
    [startTimeLabel setText:@"00:00"];
    [startTimeLabel setTextAlignment:UITextAlignmentCenter];
    startTimeLabel.adjustsFontSizeToFitWidth = NO;
    startTimeLabel.textColor = [UIColor orangeColor];
    startTimeLabel.backgroundColor = [UIColor clearColor];
    //playbackTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(12.0)];
    startTimeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.view addSubview:startTimeLabel];
    
    self.endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(242.0f, 5.0f, 60.0f, 20.0f)];
    [endTimeLabel setText:@"00:00"];
    [endTimeLabel setTextAlignment:UITextAlignmentCenter];
    endTimeLabel.adjustsFontSizeToFitWidth = NO;
    endTimeLabel.textColor = [UIColor orangeColor];
    endTimeLabel.backgroundColor = [UIColor clearColor];
    //playbackTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(12.0)];
    endTimeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.view addSubview:endTimeLabel];
    
    self.playbackTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0f, 194.0f + 12, 60.0f, 20.0f)];
    [playbackTimeLabel setText:@"00:00"];
    [playbackTimeLabel setTextAlignment:UITextAlignmentCenter];
    playbackTimeLabel.adjustsFontSizeToFitWidth = NO;
    playbackTimeLabel.textColor = [UIColor whiteColor];
    playbackTimeLabel.backgroundColor = [UIColor clearColor];
    //playbackTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(12.0)];
    playbackTimeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.view addSubview:playbackTimeLabel];
    
    remainTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(242.0f, 194.0f + 12, 60.0f, 20.0f)];
    [remainTimeLabel setText:@"00:00"];
    [remainTimeLabel setTextAlignment:UITextAlignmentCenter];
    remainTimeLabel.adjustsFontSizeToFitWidth = NO;
    remainTimeLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:249.0/255.0f green:245.0/255.0f blue:213.0/255.0f alpha:1.0];
    remainTimeLabel.backgroundColor = [UIColor clearColor];
    //remainTimeLabel.font = [UIFont fontWithName:@"Tahoma Bold" size:(12.0)];
    remainTimeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [self.view addSubview:remainTimeLabel];
}
- (void)settingUpRepeatButton {
    repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
	repeatButton.frame = CGRectMake(160 - 38, 195 + 10, 76, 21);
    
    [repeatButton setBackgroundImage:[UIImage imageNamed:@"repeat_off_test.png"] forState:UIControlStateNormal];
    [repeatButton addTarget:self action:@selector(repeatModeOnOff) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:repeatButton];
}

- (void)settingUpPicker {
    UIImageView *leftBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_background.png"]];
    leftBackGround.frame = CGRectMake(57 - 41, 249 + 12, 82, 69);
    [self.view addSubview:leftBackGround];
    [leftBackGround release];

    CGRect leftFrame = CGRectMake(57 - 41, 250 + 12, 82, 45);
	startPickerView = [[V8HorizontalPickerView alloc] initWithFrame:leftFrame];
	startPickerView.backgroundColor   = [UIColor clearColor];
	startPickerView.selectedTextColor = [UIColor blackColor];
	startPickerView.textColor   = [UIColor blackColor];
	startPickerView.delegate    = self;
	startPickerView.dataSource  = self;
	startPickerView.elementFont = [UIFont boldSystemFontOfSize:25.0f];
    startPickerView.tag = 0;
    // add gradient images to left and right of view if desired
    UIImageView *startLeftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scroll_up.png"]];
    startLeftFade.layer.opacity = 0.8f;
    startPickerView.leftEdgeView = startLeftFade;
    [startLeftFade release];
    [self.view addSubview:startPickerView];
    
    UIImageView *rightBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_background.png"]];
    rightBackGround.frame = CGRectMake(206 + 57 - 41, 249+ 12, 82, 69);
    [self.view addSubview:rightBackGround];
    [rightBackGround release];
    CGRect rightFrame = CGRectMake(206 + 57 - 41, 250+ 12, 82, 45);
	endPickerView = [[V8HorizontalPickerView alloc] initWithFrame:rightFrame];
	endPickerView.backgroundColor   = [UIColor clearColor];
	endPickerView.selectedTextColor = [UIColor blackColor];
	endPickerView.textColor   = [UIColor blackColor];
	endPickerView.delegate    = self;
	endPickerView.dataSource  = self;
	endPickerView.elementFont = [UIFont boldSystemFontOfSize:25.0f];
    endPickerView.tag = 1;
    // add gradient images to left and right of view if desired
    UIImageView *endLeftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scroll_up.png"]];
    endLeftFade.layer.opacity = 0.8f;
    endPickerView.leftEdgeView = endLeftFade;
    [endLeftFade release];
    [self.view addSubview:endPickerView];
}
- (void)settingUpBookMarkButton {
    mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mainButton.frame = CGRectMake(160 - 46, 238.0f + 12, 92.0f, 92.0f);
    
    [mainButton setBackgroundImage:[UIImage imageNamed:@"bookmark_off.png"] forState:UIControlStateNormal];
    [mainButton setBackgroundImage:[UIImage imageNamed:@"bookmark_on.png"] forState:UIControlStateSelected];
    [mainButton setBackgroundImage:[UIImage imageNamed:@"bookmark_on.png"] forState:UIControlStateHighlighted];
    [mainButton addTarget:self action:@selector(tapMainButton:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:mainButton];
}
- (void)settingUpVolumeSlider {
    
    CGRect frame = CGRectMake(52, 345 + 18, 210, 6);
    UISlider *customSlider = [[UISlider alloc] initWithFrame:frame];
    MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:[customSlider frame]] autorelease];
    UISlider *volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
		if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
			volumeViewSlider = (UISlider *) view;
		}
	}
    volumeViewSlider.backgroundColor = [UIColor clearColor];	
    [volumeViewSlider setThumbImage: [UIImage imageNamed:@"sound_controll.png"] forState:UIControlStateNormal];
    [volumeViewSlider setMinimumTrackImage:[UIImage imageNamed:@"volume_left.png"] forState:UIControlStateNormal];
    //[volumeViewSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    [customSlider removeFromSuperview];
    [self.view addSubview:volumeView];
    [customSlider release];
    //[volumeView release];
}
- (void)settingUpToolBarButton {
    CGFloat gap = 28.0f;
    minimizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	minimizeButton.frame = CGRectMake(gap + 1, 396, 30.0f, 30.0f);
    
    [minimizeButton setBackgroundImage:[UIImage imageNamed:@"zoom_out.png"] forState:UIControlStateNormal];
    [minimizeButton setBackgroundImage:[UIImage imageNamed:@"zoom_out.png"] forState:UIControlStateSelected];
    [minimizeButton setBackgroundImage:[UIImage imageNamed:@"zoom_out.png"] forState:UIControlStateHighlighted];
    [minimizeButton addTarget:self action:@selector(zoom_out) forControlEvents: UIControlEventTouchUpInside];
    minimizeButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:minimizeButton];
    rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rewindButton.frame = CGRectMake(2*gap+ 30 + 1, 396, 30.0f, 30.0f);
    
    [rewindButton setBackgroundImage:[UIImage imageNamed:@"btn_prev_off.png"] forState:UIControlStateNormal];
    [rewindButton setBackgroundImage:[UIImage imageNamed:@"btn_prev_on.png"] forState:UIControlStateSelected];
    [rewindButton setBackgroundImage:[UIImage imageNamed:@"btn_prev_on.png"] forState:UIControlStateHighlighted];
    [rewindButton addTarget:self action:@selector(rewindRelease) forControlEvents: UIControlEventTouchUpInside];
    [rewindButton addTarget:self action:@selector(rewindDown) forControlEvents: UIControlEventTouchDown];
    rewindButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:rewindButton];
    
    playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	playOrPauseButton.frame = CGRectMake(3*gap+ 30*2 + 1, 396, 30.0f, 30.0f);
    
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play_off.png"] forState:UIControlStateNormal];
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play_on.png"] forState:UIControlStateSelected];
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play_on.png"] forState:UIControlStateHighlighted];
    [playOrPauseButton addTarget:self action:@selector(play) forControlEvents: UIControlEventTouchUpInside];
    playOrPauseButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:playOrPauseButton];
    
    forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	forwardButton.frame = CGRectMake(4*gap + 30*3 + 1, 396, 30.0f, 30.0f);
    
    [forwardButton setBackgroundImage:[UIImage imageNamed:@"btn_next_off.png"] forState:UIControlStateNormal];
    [forwardButton setBackgroundImage:[UIImage imageNamed:@"btn_next_on.png"] forState:UIControlStateSelected];
    [forwardButton setBackgroundImage:[UIImage imageNamed:@"btn_next_on.png"] forState:UIControlStateHighlighted];
    [forwardButton addTarget:self action:@selector(fastforwardRelease) forControlEvents: UIControlEventTouchUpInside];
    [forwardButton addTarget:self action:@selector(fastforwardDown) forControlEvents: UIControlEventTouchDown];
    forwardButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:forwardButton];
    
    maximizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	maximizeButton.frame = CGRectMake(5*gap + 30*4 + 1, 396, 30.0f, 30.0f);
    
    [maximizeButton setBackgroundImage:[UIImage imageNamed:@"zoom_in.png"] forState:UIControlStateNormal];
    [maximizeButton setBackgroundImage:[UIImage imageNamed:@"zoom_in.png"] forState:UIControlStateSelected];
    [maximizeButton setBackgroundImage:[UIImage imageNamed:@"zoom_in.png"] forState:UIControlStateHighlighted];
    [maximizeButton addTarget:self action:@selector(zoom_in) forControlEvents: UIControlEventTouchUpInside];
    maximizeButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:maximizeButton];
}
- (void)toolBarIsNil {
    minimizeButton.enabled = NO;
    maximizeButton.enabled = NO;
    rewindButton.enabled = NO;
    playOrPauseButton.enabled = NO;
    forwardButton.enabled = NO;
}
- (void)toolBarPlay {
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play_off.png"] forState:UIControlStateNormal];
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play_on.png"] forState:UIControlStateSelected];
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play_on.png"] forState:UIControlStateHighlighted];
    [playOrPauseButton addTarget:self action:@selector(play) forControlEvents: UIControlEventTouchUpInside];
    minimizeButton.enabled = YES;
    maximizeButton.enabled = YES;
    rewindButton.enabled = YES;
    playOrPauseButton.enabled = YES;
    forwardButton.enabled = YES;
}
- (void)toolBarPause {
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_pause_off.png"] forState:UIControlStateNormal];
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_pause_on.png"] forState:UIControlStateSelected];
    [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_pause_on.png"] forState:UIControlStateHighlighted];
    [playOrPauseButton addTarget:self action:@selector(pause) forControlEvents: UIControlEventTouchUpInside];
    minimizeButton.enabled = YES;
    maximizeButton.enabled = YES;
    rewindButton.enabled = YES;
    playOrPauseButton.enabled = YES;
    forwardButton.enabled = YES;
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
- (void) handlePinches:(UIPinchGestureRecognizer*)paramSender{
    
    if (paramSender.state == UIGestureRecognizerStateEnded){
        //NSLog(@"State End:%f", paramSender.scale);
        //CGFloat scale = 0.5f;
        [self redrawWithSize:paramSender.scale];
    } else if (paramSender.state == UIGestureRecognizerStateBegan){
        //NSLog(@"State Began:%f", paramSender.scale);
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.startPickerTime = 0.f;
    self.endPickerTime = 0.f;
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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
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
    self.navigationItem.leftBarButtonItem = leftBarItem;
    //self.navigationItem.leftBarButtonItem.enabled = NO;
    //[leftBarItem release];

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
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [rightBarItem release];

    avPlayer = nil;
    
    self.title = NSLocalizedString(@"Playing", @"Default title for main controller");
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar2.png"] forBarMetrics:UIBarMetricsDefault];
    UILabel *songDataView = [[UILabel alloc] initWithFrame:CGRectMake(72, 0, 174, 62)];
    songDataView.backgroundColor = [UIColor clearColor];
    
    //UILabel *label;
    self.songTitleLabel = [[AutoScrollLabel alloc] initWithFrame:CGRectMake(0, 5, songDataView.bounds.size.width, 30)];
    self.songTitleLabel.tag = 1;
    self.songTitleLabel.backgroundColor = [UIColor clearColor];
    self.songTitleLabel.font = [UIFont boldSystemFontOfSize:22];
    self.songTitleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    //self.songTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.songTitleLabel.textAlignment = UITextAlignmentCenter;
    self.songTitleLabel.textColor = [UIColor whiteColor];
    self.songTitleLabel.text = NSLocalizedString(@"MusicWave", @"Default title for song label");
    self.songTitleLabel.labelSpacing = 30;
    self.songTitleLabel.pauseInterval = 1.7;
    self.songTitleLabel.scrollSpeed = 30;
    //self.songTitleLabel.highlightedTextColor = [UIColor whiteColor];
    [songDataView addSubview:self.songTitleLabel];
    //[label release];
    
    self.songArtistLabel = [[AutoScrollLabel alloc] initWithFrame:CGRectMake(0, 33, songDataView.bounds.size.width, 22)];
    self.songArtistLabel.tag = 2;
    self.songArtistLabel.backgroundColor = [UIColor clearColor];
    self.songArtistLabel.font = [UIFont systemFontOfSize:14];
    self.songArtistLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    //self.songArtistLabel.adjustsFontSizeToFitWidth = NO;
    self.songArtistLabel.textAlignment = UITextAlignmentCenter;
    self.songArtistLabel.textColor = [UIColor whiteColor];
    self.songArtistLabel.text = NSLocalizedString(@"MusicWave", @"Default title for song label");
    self.songArtistLabel.labelSpacing = 30;
    self.songArtistLabel.pauseInterval = 1.7;
    self.songArtistLabel.scrollSpeed = 30;
    //self.songArtistLabel.highlightedTextColor = [UIColor whiteColor];
    [songDataView addSubview:self.songArtistLabel];
    //[label release];
    
    self.navigationItem.titleView = songDataView;
    [songDataView release];
    
    //[self.myScrollView setParent:self];
    //playState = playBackStateNone;
    //[self imageViewTest];
    [self settingUpBackgroundView];
    [self settingUpLabel];
    [self settingUpPicker];
    [self settingUpBookMarkButton];
    [self settingUpVolumeSlider];
    [self settingUpRepeatButton];
    [self settingUpToolBarButton];
    
    [self toolBarIsNil];
    //[toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar_back.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    CGRect scrollViewRect = CGRectMake(10, 35, 300, 164);
    
    self.myScrollView = [[MyScrollView alloc] initWithFrame:scrollViewRect];
    self.myScrollView.scrollEnabled = YES;
    self.myScrollView.backgroundColor = [UIColor clearColor];
    self.myScrollView.parent = self;
    self.myScrollView.delegate = self;
    self.myScrollView.contentSize = CGSizeMake(scrollViewRect.size.width,
                                               scrollViewRect.size.height);
    [self.view addSubview:self.myScrollView];
    
    //CGRect graphViewRect = self.myScrollView.bounds;
    //self.myGraphView = [[MyGraphView alloc] initWithFrame:graphViewRect];
    //self.myGraphView.backgroundColor = [UIColor clearColor];
    //self.myGraphView.parent = self;
    //[self.myScrollView addSubview:self.myGraphView];
    
    self.graphImage = nil;
    
    // Add a pinch gesture recognizer to the table view.
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinches:)];
	[self.myScrollView addGestureRecognizer:pinchRecognizer];

    
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
            self.startPickerTime = 0.f;
        }
        else {
            self.endPickerTime = 0.f;
        }
        [self.myScrollView settingStartEndTime:startPickerTime endPosition:endPickerTime];
        [self.myScrollView.bookMarkLayer setNeedsDisplay];
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
        self.startPickerTime = [tempBookMark.duration floatValue];
    }
    else {
        self.endPickerTime = [tempBookMark.duration floatValue];
    }
    //NSLog(@"bookMark old position:%f, delta:%f", [tempBookMark.duration floatValue]/[tempBookMark.delta floatValue], self.delta);
    [self setCurrentPostion:[tempBookMark.duration floatValue]];
    //[self updatePosition];
    CGFloat moveOffset = [tempBookMark.duration floatValue]/self.delta - self.myScrollView.bounds.size.width / 2;
   
    if (self.myScrollView.contentSize.width - [tempBookMark.duration floatValue]/self.delta < self.myScrollView.bounds.size.width / 2) {
        moveOffset = self.myScrollView.contentSize.width - self.myScrollView.bounds.size.width; 
    }
    if (moveOffset < 0) {
        moveOffset = 0;
    }
    [self.myScrollView setContentOffset:CGPointMake(moveOffset, 0.0)];
    [self.myScrollView settingStartEndTime:startPickerTime endPosition:endPickerTime];
    [self.myScrollView.bookMarkLayer setNeedsDisplay];
    [self.myScrollView setCurrentPlaybackPosition:[tempBookMark.duration floatValue]/self.delta];
    [self registerTimeObserver];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //NSLog(@"main view will appear");
    [self.myScrollView settingStartEndTime:startPickerTime endPosition:endPickerTime];
    [self.myScrollView.bookMarkLayer setNeedsDisplay];
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
        //[toolBar setItems:[self playItems]];
        [self toolBarPlay];
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification
         object:avPlayer.currentItem];
        //[self play];
	}
}
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [avPlayer seekToTime:kCMTimeZero];
    [self.myScrollView.layer setNeedsDisplay];
    [self.myScrollView setContentOffset:CGPointMake(0.0, 0.0)];
    movingOffset = NO;
    [self pause];
    if (repeatMode) {
        [self play];
        [self registerTimeObserver];
    }
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
