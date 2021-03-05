#include "PBListItem.h"
#import <UIKit/UIKit.h>

@interface PMTrackModel
- (NSURL *)audioTrackURL;
- (NSString *)songName;
- (NSString *)artistName;
- (NSString *)albumName;
- (UIImage *)albumArt;
@end

@interface MPNowPlayingInfoCenter : NSObject
+ (id)defaultCenter;
- (void)setNowPlayingInfo:(id)songInfo;
- (NSDictionary *)nowPlayingInfo;
@end

@interface MPRemoteCommand : NSObject
- (void)addTarget:(id)tar action:(SEL)act;
- (void)setEnabled:(BOOL)tar;
- (void)removeTarget:(id)target;
- (unsigned int)mediaRemoteCommandType;
- (BOOL)isEnabled;
@end

@interface MPRemoteCommandCenter : NSObject
+ (MPRemoteCommandCenter *)sharedCommandCenter;
- (MPRemoteCommand *)playCommand;
- (MPRemoteCommand *)pauseCommand;
- (MPRemoteCommand *)nextTrackCommand;
- (MPRemoteCommand *)previousTrackCommand;
- (MPRemoteCommand *)changePlaybackPositionCommand;
@end

@interface MPRemoteCommandEvent : NSObject
- (MPRemoteCommand *)command;
- (NSTimeInterval)positionTime;
@end

@interface PMNowPlayingPhoneViewController : UIViewController
- (PMTrackModel *)nowPlayingTrack;
- (void)createDirectory:(NSString *)directoryName;
- (void)downloadButtonWasPressed:(id)arg1;
- (void)libWasPressed:(id)arg1;
- (void)downloadMusic:(NSURL *)aUrl toPath:(NSString *)path;
- (UIView *)nowPlayingControlBarView;
- (BOOL)isPlaying;
@end

@interface PMPlayingButton : NSObject
- (void)callOnTouchUp:(id)arg1;
@end

@interface PBQueuePlayer : UIViewController <UITableViewDataSource, UITableViewDelegate, UIApplicationDelegate>

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) UIView *playerController;
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, retain) NSMutableArray *songIdentifiers;
@property (nonatomic, retain) PBListItem *nowPlayingInfo;
@property (nonatomic, assign) UIButton *playButton;
@property (nonatomic, assign) UIButton *sortByButton;
@property (nonatomic) int sortStyle;
@property (nonatomic, assign) PMNowPlayingPhoneViewController *PMDelegate;

- (void)initPlayer;
- (void)closeButtonPressed;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteListItemAtIndex:(int)index;
- (void)playButtonPressed;
- (void)backButtonPressed;
- (void)forwardButtonPressed;
- (void)sortByButtonPressed;
- (void)initializeQueuePlayer:(PBListItem *)item;
- (void)initializeBackgroundPlay:(id)item;
- (void)viewDidAppear:(BOOL)animated;
- (void)itemDidFinishPlaying:(NSNotification *)notification;
- (BOOL)canBecomeFirstResponder;
- (int)handleCommand:(id)event;
- (void)ensurePMPaused;
- (BOOL)listNeedsUpdating;
- (void)generateIdentifiers;
- (void)sortIdentifiers;

@end
