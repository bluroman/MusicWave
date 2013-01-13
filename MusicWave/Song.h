//
//  Song.h
//  MusicWave
//
//  Created by Nam Hoon on 13. 1. 4..
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BookMark, ViewInfo;
@interface ImageToDataTransformer : NSValueTransformer {
}
@end

@interface Song : NSManagedObject

@property (nonatomic, retain) NSNumber * persistentId;
@property (nonatomic, retain) UIImage * artworkImage;
@property (nonatomic, retain) NSNumber * doneGraphDrawing;
@property (nonatomic, retain) NSString * songURL;
@property (nonatomic, retain) NSString * songTitle;
@property (nonatomic, retain) NSNumber * songDuration;
@property (nonatomic, retain) NSString * songArtist;
@property (nonatomic, retain) NSString * songAlbum;
@property (nonatomic, retain) NSString * graphPath;
@property (nonatomic, retain) NSSet *bookmarks;
@property (nonatomic, retain) NSSet *viewinfos;
@end

@interface Song (CoreDataGeneratedAccessors)

- (void)addBookmarksObject:(BookMark *)value;
- (void)removeBookmarksObject:(BookMark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;
- (void)addViewinfosObject:(ViewInfo *)value;
- (void)removeViewinfosObject:(ViewInfo *)value;
- (void)addViewinfos:(NSSet *)values;
- (void)removeViewinfos:(NSSet *)values;
@end
