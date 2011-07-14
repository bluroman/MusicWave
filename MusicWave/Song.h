//
//  Song.h
//  MusicWave
//
//  Created by hun nam on 11. 7. 11..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BookMark, ViewInfo;
@interface ImageToDataTransformer : NSValueTransformer {
}
@end

@interface Song : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * doneGraphDrawing;
@property (nonatomic, retain) NSNumber * pos1;
@property (nonatomic, retain) NSNumber * pos2;
@property (nonatomic, retain) NSString * songURL;
@property (nonatomic, retain) NSString * songTitle;
@property (nonatomic, retain) NSString * songArtist;
@property (nonatomic, retain) NSNumber * songDuration;
@property (nonatomic, retain) UIImage * artworkImage;
@property (nonatomic, retain) NSNumber * persistentId;
@property (nonatomic, retain) NSSet* bookmarks;
@property (nonatomic, retain) NSSet* viewinfos;

- (void)addViewinfosObject:(ViewInfo *)value;
- (void)addBookmarksObject:(BookMark *)value;
- (void)removeBookmarksObject:(BookMark *)value;
@end
