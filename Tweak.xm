#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <objc/runtime.h>
#import <CoreMedia/CoreMedia.h>
#import "PBQueuePlayer.h"

static PBQueuePlayer *queuePlayer = nil;

@interface PMAdvertisingController

- (void)disableInterstitialTillNextDay;
- (void)radioUserUpgradeFinished;

@end

%hook PMAdvertisingController

- (id)init{
  return nil;
}

- (_Bool)readyForVideoAdDisplay{
  return NO;
}

- (_Bool)refreshTimeHasPassed{
  return NO;
}

- (_Bool)readyForVideoAdDisplay:(id)arg1 interaction:(id)arg2{
  return NO;
}

- (_Bool)allowAdDisplayForInteraction:(id)arg1 adType:(long long)arg2{
  return NO;
}

- (_Bool)canLoadInterstitialAd{
  [self disableInterstitialTillNextDay];
  [self radioUserUpgradeFinished];
  return NO;
}

- (void)sleepTimerEnded:(id)arg1{

}


%end


@interface PMOnlineTrackQueue
- (void)discardAudioAds;
- (id)headDescriptor;
@end

%hook PMSubscriptionState

- (BOOL)isAdSupportedListener{
  return NO;
}

- (void)setIsAdSupportedListener:(BOOL)ar1{
  return %orig(NO);
}

/* never tested this, will not work if this works. As premium has a whole different internal structure written in swift
- (BOOL)isPandoraPremiumSubscriber{
  return YES;
}
*/

%end

/*
%hook PMStationPlayer

- (void)setSkipsAudioAds:(BOOL)arg1{
  return %orig(YES);
}

- (BOOL)skipsAudioAds{
  return YES;
}

%end
*/

@interface PMAudioDownloadPlayer : NSObject
- (void)end;
- (void)markAsComplete;
- (void)setMarkedAsComplete:(BOOL)arg1;
- (NSObject *)descriptor;
@end

%hook PMAudioDownloadPlayer
- (BOOL)canSkip{
  return YES;
}

- (void)play{
    %orig();
    if ([[self descriptor] class] == NSClassFromString(@"PMLegacy.AudioAdTrackModel")){
      [self end];
      [self setMarkedAsComplete:YES];
      [self end];
    }
}

%end

%hook PMPlayerSwitcher

- (PMAudioDownloadPlayer *)trackPlayerForTrack:(id)arg1{
  if ([arg1 class] == NSClassFromString(@"PMLegacy.AudioAdTrackModel")){
      [%orig() setMarkedAsComplete:YES];
      [%orig() end];
  }
  return %orig();
}

%end

%hook PMOnlineTrackQueue

- (BOOL)preparePlaylist:(id)arg1 withTrack:(id)arg2{
  if ([[self headDescriptor] class] == NSClassFromString(@"PMLegacy.AudioAdTrackModel")){
    [self discardAudioAds];
  }
    return %orig();
}

/*
- (NSArray *)players{
  NSMutableArray<PMAudioDownloadPlayer *> *newArray = [%orig() mutableCopy];
  for (int i = 0; i < [%orig() count]; i++){
    if ([[[newArray objectAtIndex:i] descriptor] class] == NSClassFromString(@"PMLegacy.AudioAdTrackModel")){
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", [[newArray objectAtIndex:i] descriptor]] message:NSStringFromClass([newArray objectAtIndex:i].descriptor.class) delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil];
      [alert show];
      [newArray removeObjectAtIndex:i];
      [self discardAudioAds];
    }
    return newArray;
  }
  return %orig();
}
*/


%end


/* used for skipping tracks to simulate finishing tracks
%hook PMAudioDownloadPlayer
- (void)markAsComplete{

}
%end
*/

%hook PMActionCounter

- (NSInteger)maximumCountPerDuration{
  return 9999;
}

%end


%hook PMSkipLimitState

- (NSInteger)maximumCountPerDuration{
  return 9999;
}

- (NSInteger)dailySkipLimit{
  return 9999;
}

- (NSInteger)dailySkipLimitRemaining{
  return 9999;
}

- (NSInteger)hourlyStationSkipLimit{
  return 9999;
}

- (BOOL)unlimitedDailySkips{
  return YES;
}

%end

%hook PMTrackModel

+ (id)alloc{
  return %orig();
}

%end


%hook PMNowPlayingPhoneViewController

%new
- (void)downloadMusic:(NSURL *)aUrl toPath:(NSString *)path{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSData *videoData = [NSData dataWithContentsOfURL:aUrl];
    [videoData writeToFile:[path stringByAppendingPathExtension:@"mp3"] atomically:YES];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Song saved!" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
  });
}

%new
- (void)createDirectory:(NSString *)directoryName {
    if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryName withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"Create directory error...");
    }
}

%new
- (void)downloadButtonWasPressed:(id)arg1 {
  PMTrackModel *currentTrackModel = [self nowPlayingTrack];

  NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  cachePath = [cachePath stringByAppendingPathComponent:@"PandorasBox"];
  cachePath = [cachePath stringByAppendingPathComponent:[currentTrackModel artistName]];
  cachePath = [cachePath stringByAppendingPathComponent:[currentTrackModel albumName]];

  [self createDirectory:cachePath];


  NSString *stringSavePath = [cachePath stringByAppendingString:@"/AlbumArtwork"];
  [UIImageJPEGRepresentation([currentTrackModel albumArt], 1.0) writeToFile:[stringSavePath stringByAppendingPathExtension:@"jpg"] atomically:YES];


  cachePath = [cachePath stringByAppendingPathComponent:[currentTrackModel songName]];
  [self downloadMusic:[currentTrackModel audioTrackURL] toPath:cachePath];

}

%new
- (void)libButtonWasPressed:(id)arg1 {

  UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
  while (topRootViewController.presentedViewController)
  {
    topRootViewController = topRootViewController.presentedViewController;
  }

  if (!queuePlayer) {
    queuePlayer = [PBQueuePlayer alloc];
    [queuePlayer initPlayer];
    queuePlayer.PMDelegate = self;
  }
  [topRootViewController presentViewController:queuePlayer animated:YES completion:nil];

}

%new
- (void)debugButtonWasPressed:(id)arg1 {
  dispatch_async(dispatch_get_main_queue(), ^{
    PMTrackModel *currentTrackModel = [self nowPlayingTrack];

    NSString *titleString = [NSString stringWithFormat:@"%@", currentTrackModel];
    NSString *infoString = [NSString stringWithFormat:@"%@", [currentTrackModel songName]];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:infoString delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil];
    [alert show];
  });
}

- (void)setIsPlaying:(BOOL)arg1 {
  %orig();

  CGFloat bottomOffset = [UIScreen mainScreen].bounds.size.height - (0.28 * [UIScreen mainScreen].bounds.size.height);
  UIButton *downloadButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
  downloadButton.frame = CGRectMake(25, bottomOffset, 50, 35);
  downloadButton.backgroundColor = [UIColor clearColor];
  [downloadButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
  [downloadButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:21.0]];
  [downloadButton setTitle:@"DL" forState:UIControlStateNormal];
  [downloadButton addTarget:self action:@selector(downloadButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
  downloadButton.layer.cornerRadius = 10.0f;
  downloadButton.layer.borderWidth = 1.15f;
  downloadButton.layer.borderColor = [UIColor whiteColor].CGColor;

  [self.view addSubview:downloadButton];

  UIButton *libButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
  libButton.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 75), bottomOffset, 50, 35);
  libButton.backgroundColor = [UIColor clearColor];
  [libButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
  [libButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:21.0]];
  [libButton setTitle:@"Lib" forState:UIControlStateNormal];
  [libButton addTarget:self action:@selector(libButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
  libButton.layer.cornerRadius = 10.0f;
  libButton.layer.borderWidth = 1.15f;
  libButton.layer.borderColor = [UIColor whiteColor].CGColor;

  [self.view addSubview:libButton];

  UIButton *debugButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
  debugButton.frame = CGRectMake(((([UIScreen mainScreen].bounds.size.width) / 2) - 25), bottomOffset, 50, 35);
  debugButton.backgroundColor = [UIColor clearColor];
  [debugButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
  [debugButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:21.0]];
  [debugButton setTitle:@"DBG" forState:UIControlStateNormal];
  [debugButton addTarget:self action:@selector(debugButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
  debugButton.layer.cornerRadius = 10.0f;
  debugButton.layer.borderWidth = 1.15f;
  debugButton.layer.borderColor = [UIColor whiteColor].CGColor;

  [self.view addSubview:debugButton];

}

%end

%hook PMPhoneApplicationDelegate

- (void)applicationDidEnterBackground:(UIApplication *)application {
  if (queuePlayer.audioPlayer.rate != 0.0){

  }else{
    %orig();
  }
}

%end

@interface PMRemoteControlManager : NSObject
+ (id)sharedManager;
- (void)updateControlsForCurrentTrack;
@end

%hook PMPlayingButton
- (void)callOnTouchUp:(id)arg1{

  if (queuePlayer.audioPlayer.rate != 0.0 && queuePlayer) {
    [queuePlayer playButtonPressed];
  }

  MPRemoteCommandCenter *commandCenter = [NSClassFromString(@"MPRemoteCommandCenter") sharedCommandCenter];
  if ([commandCenter.previousTrackCommand isEnabled]){
    [commandCenter.playCommand removeTarget:nil];
    [commandCenter.pauseCommand removeTarget:nil];
    [commandCenter.previousTrackCommand removeTarget:nil];
    [commandCenter.nextTrackCommand removeTarget:nil];
    [commandCenter.changePlaybackPositionCommand removeTarget:nil];
  }

  PMRemoteControlManager *manager = (PMRemoteControlManager *)[NSClassFromString(@"PMRemoteControlManager") sharedManager];
  [manager updateControlsForCurrentTrack];
  %orig();
}
%end

%ctor {
  %init(PMTrackModel = NSClassFromString(@"PMLegacy.StationTrackModel"),
        PMPlayingButton = NSClassFromString(@"Pandora.PMNowPlayingControlBarButton"));
}
