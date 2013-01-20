//
//  CommonUtil.m
//  MusicWave
//
//  Created by Nam Hoon on 13. 1. 20..
//
//

#import "CommonUtil.h"

@implementation CommonUtil
+ (BOOL) IS_IPHONE5_RETINA{
    BOOL isiPhone5Retina = NO;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([UIScreen mainScreen].scale == 2.0f) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960){
                //NSLog(@"iPhone 4, 4s Retina Resolution");
            }
            if(result.height == 1136){
                //NSLog(@"iPhone 5 Resolution");
                isiPhone5Retina = YES;
            }
        } else {
            //NSLog(@"iPhone Standard Resolution");
        }
    }
    return isiPhone5Retina;
}

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
+ (NSString *) assetPictogramFileName:(NSNumber *)libraryId
{
    NSString *assetPictogramFilename = [NSString stringWithFormat:@"graph_%@.%@",libraryId,imgExt];
    return assetPictogramFilename;
}
+ (NSDate *) assetCreationDate:(NSNumber *)libraryId
{
    NSString *assetPictogramFilename = [[self class] assetPictogramFileName:libraryId];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: assetPictogramFilename];
    NSDate *creationDate;

    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
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
        NSLog(@"asset creation date error: file not found %@", uniquePath);
    }
    return creationDate;

}


+ (NSString *) cachedAudioPictogramPathForCurrentSong:(NSNumber *)libraryId
{
    NSString *assetFolder = [[self class] assetCacheFolder];
    NSString *assetPictogramFilename = [[self class] assetPictogramFileName:libraryId];
    return [NSString stringWithFormat:@"%@/%@", assetFolder, assetPictogramFilename];
}

+ (UIImage *) getCachedImage:(NSNumber *)libraryId
{
    NSString *assetPictogramFilename = [[self class] assetPictogramFileName:libraryId];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: assetPictogramFilename];
    
    UIImage *image = nil;
    
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        image = [UIImage imageWithContentsOfFile: uniquePath];
    }
    else
    {
        NSLog(@"image reading error: file not found:%@", uniquePath);
    }
    
    return image;
}
+ (NSString *) cacheImage:(NSNumber *)libraryId fileToWrite:(UIImage *)imageToWrite
{
    NSString *assetPictogramFilename = [[self class] assetPictogramFileName:libraryId];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: assetPictogramFilename];
    NSString *returnedGraphPath = nil;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath] && imageToWrite != nil)
    {
        [imageToData(imageToWrite) writeToFile: uniquePath atomically: YES];
        returnedGraphPath = uniquePath;
        //currentSong.graphPath = uniquePath;
    }
    else NSLog(@"image writing error: file exist or image file was nil:%@", uniquePath);
    return returnedGraphPath;
}
+ (void)removeGraphImage:(NSString *)myPath
{
    BOOL result = NO;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath: myPath])
    {
        result = [fileManager removeItemAtPath:myPath error:&error];
        if (!result)
        {
            NSLog(@"Remove file error %@, %@", error, [error userInfo]);
        }
    }
    else NSLog(@"No Remove file found on:%@", myPath);
}
+ (void)removeTMPDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator* en = [fileManager enumeratorAtPath:TMP];
    NSError* err = nil;
    BOOL res;

    NSString* file;
    while (file = [en nextObject])
    {
        res = [fileManager removeItemAtPath:[TMP stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"oops: %@", err);
        }
    }
}



@end
