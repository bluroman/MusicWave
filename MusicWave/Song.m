//
//  Song.m
//  MusicWave
//
//  Created by hun nam on 11. 7. 11..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Song.h"
#import "BookMark.h"
#import "ViewInfo.h"

@implementation ImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return [uiImage autorelease];
}

@end
@implementation Song
@dynamic doneGraphDrawing;
@dynamic pos1;
@dynamic pos2;
@dynamic songURL;
@dynamic songTitle;
@dynamic songArtist;
@dynamic songDuration;
@dynamic artworkImage;
@dynamic persistentId;
@dynamic bookmarks;
@dynamic viewinfos;

- (void)addBookmarksObject:(BookMark *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"bookmarks"] addObject:value];
    [self didChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeBookmarksObject:(BookMark *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"bookmarks"] removeObject:value];
    [self didChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addBookmarks:(NSSet *)value {    
    [self willChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"bookmarks"] unionSet:value];
    [self didChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeBookmarks:(NSSet *)value {
    [self willChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"bookmarks"] minusSet:value];
    [self didChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addViewinfosObject:(ViewInfo *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"viewinfos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"viewinfos"] addObject:value];
    [self didChangeValueForKey:@"viewinfos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeViewinfosObject:(ViewInfo *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"viewinfos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"viewinfos"] removeObject:value];
    [self didChangeValueForKey:@"viewinfos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addViewinfos:(NSSet *)value {    
    [self willChangeValueForKey:@"viewinfos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"viewinfos"] unionSet:value];
    [self didChangeValueForKey:@"viewinfos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeViewinfos:(NSSet *)value {
    [self willChangeValueForKey:@"viewinfos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"viewinfos"] minusSet:value];
    [self didChangeValueForKey:@"viewinfos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
