//
//  BookMark.h
//  MusicWave
//
//  Created by Nam Hoon on 13. 1. 12..
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song;

@interface BookMark : NSManagedObject

@property (nonatomic, retain) NSDate * keepDate;
@property (nonatomic, retain) NSNumber * delta;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) Song *song;

@end
