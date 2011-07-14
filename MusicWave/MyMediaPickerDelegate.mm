//
//  MyMediaPickerDelegate.m
//  iPodSongs
//
//  Created by hun nam on 11. 5. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyMediaPickerDelegate.h"


@implementation MyMediaPickerDelegate
- (void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSArray *mediaItems = [mediaItemCollection items];
    NSEnumerator *enumer = [mediaItems objectEnumerator];
    id myObject;
    while ((myObject = [enumer nextObject]) != nil) {
        MPMediaItem *tempMediaItem = (MPMediaItem *) myObject;
        NSLog(@"Title: %@", [tempMediaItem valueForProperty:MPMediaItemPropertyTitle]);
        NSLog(@"id: %@", [tempMediaItem valueForProperty:MPMediaItemPropertyArtist]);
        NSLog(@"id: %i", (int)[tempMediaItem valueForProperty:MPMediaItemPropertyPersistentID]);
        NSLog(@"----------------------------");
    }
    
    [mediaPicker.parentViewController dismissModalViewControllerAnimated:YES];
    [mediaPicker release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SongsPicked" object:mediaItemCollection];
}
- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker.parentViewController dismissModalViewControllerAnimated:YES];
    [mediaPicker release];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
