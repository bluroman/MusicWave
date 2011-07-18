//
//  MusicWaveAppDelegate.h
//  MusicWave
//
//  Created by hun nam on 11. 7. 11..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iPodSongsViewController;
@interface MusicWaveAppDelegate : NSObject <UIApplicationDelegate> {
    iPodSongsViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iPodSongsViewController *mainViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)applicationDocumentDirectory;
- (void) createEditableCopyOfDatabaseIfNeeded;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
