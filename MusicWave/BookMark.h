//
//  BookMark.h
//  MusicWave
//
//  Created by hun nam on 11. 7. 11..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song;

@interface BookMark : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * keepDate;
@property (nonatomic, retain) Song * song;

@end
