//
//  ViewInfo.h
//  MusicWave
//
//  Created by hun nam on 11. 7. 11..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song;

@interface ViewInfo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * min;
@property (nonatomic, retain) NSNumber * max;
@property (nonatomic, retain) NSNumber * rms;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) Song * song;

@end
