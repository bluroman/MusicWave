//
//  MusicListDetailViewController.h
//  MusicWave
//
//  Created by Nam Hoon on 13. 1. 18..
//
//

#import <UIKit/UIKit.h>
@class Song;

@interface MusicListDetailViewController : UIViewController
{
    UINavigationItem *navItem;
    Song *currentSong;
    UIImageView *graphImageView;
    NSString *fileName;
    NSDate *creationDate;
}
@property (retain, nonatomic) IBOutlet UILabel *notFoundLabel;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSDate *creationDate;
@property (retain, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *createDateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *graphBgImageView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *trashBarButtonItem;

@property (retain, nonatomic) IBOutlet UILabel *artistLabel;
@property (retain, nonatomic) IBOutlet UILabel *albumLabel;
@property (retain, nonatomic) IBOutlet UILabel *durationLabel;
@property (retain, nonatomic) IBOutlet UIImageView *albumImageView;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) Song *currentSong;

- (IBAction)graphDeleteAction:(id)sender;
@end
