//
//  CommonUtil.h
//  MusicWave
//
//  Created by Nam Hoon on 13. 1. 20..
//
//

#import <Foundation/Foundation.h>
//#define TMP NSTemporaryDirectory()
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define IMGBARBUTTON(IMAGE, SELECTOR) [[[UIBarButtonItem alloc] initWithImage:IMAGE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface CommonUtil : NSObject
+ (NSString *) applicationDocumentsDirectory;
+ (NSString *) assetCacheFolder;
+ (NSString *) cachedAudioPictogramPathForCurrentSong:(NSNumber *)libraryId;
+ (UIImage *) getCachedImage:(NSNumber *)libraryId;
+ (NSString *) cacheImage:(NSNumber *)libraryId fileToWrite:(UIImage *)imageToWrite;
+ (void)removeGraphImage:(NSString *)myPath;
+ (void)removeTMPDirectory;
+ (NSString *) assetPictogramFileName:(NSNumber *)libraryId;
+ (NSDate *) assetCreationDate:(NSNumber *)libraryId;
+ (BOOL) IS_IPHONE5_RETINA;
@end
