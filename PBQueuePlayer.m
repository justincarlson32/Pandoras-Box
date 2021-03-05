#import <AVFoundation/AVFoundation.h>
#include "PBQueuePlayer.h"

@implementation PBQueuePlayer

- (void)initPlayer{

  self.view.backgroundColor = [UIColor blackColor];

  UIButton *closeButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
  closeButton.frame = CGRectMake((self.view.frame.size.width - 50), (0.08 * self.view.frame.size.height), 30, 30);
  closeButton.backgroundColor = [UIColor clearColor];
  [closeButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
  [closeButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
  [closeButton setTitle:@"X" forState:UIControlStateNormal];
  [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  closeButton.layer.cornerRadius = 10.5f;
  closeButton.layer.borderColor = [UIColor whiteColor].CGColor;
  closeButton.layer.borderWidth= 1.25f;
  [self.view addSubview:closeButton];


  CGFloat bottomOffset = [UIScreen mainScreen].bounds.size.height - (.25 * [UIScreen mainScreen].bounds.size.height);
  CGRect frame = CGRectMake(0, ([UIScreen mainScreen].bounds.size.height / 7.5), [UIScreen mainScreen].bounds.size.width, bottomOffset);
  CGRect controllerframe = CGRectMake(0, (frame.origin.y + frame.size.height), [UIScreen mainScreen].bounds.size.width, ([UIScreen mainScreen].bounds.size.height - (frame.origin.y + frame.size.height)));

  UIView *controllerView = [[UIView alloc] initWithFrame:controllerframe];
  controllerView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
  self.playerController = controllerView;

  UIButton *playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
  playButton.frame = CGRectMake(((controllerView.frame.size.width / 2) - 30), controllerView.frame.origin.y, 60, 60);
  [playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [playButton.titleLabel setFont:[UIFont systemFontOfSize:50]];
  [playButton setTitle:@"⏸️" forState:UIControlStateNormal];
  playButton.backgroundColor = [UIColor clearColor];
  playButton.adjustsImageWhenHighlighted = NO;
  self.playButton = playButton;

  UIButton *backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
  backButton.frame = CGRectMake((controllerView.frame.size.width / 8) , controllerView.frame.origin.y, 60, 60);
  [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [backButton.titleLabel setFont:[UIFont systemFontOfSize:50]];
  [backButton setTitle:@"⏪" forState:UIControlStateNormal];
  backButton.backgroundColor = [UIColor clearColor];
  backButton.adjustsImageWhenHighlighted = NO;

  UIButton *forwardButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
  forwardButton.frame = CGRectMake((controllerView.frame.size.width - ((controllerView.frame.size.width / 8) + 60)) , controllerView.frame.origin.y, 60, 60);
  [forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [forwardButton.titleLabel setFont:[UIFont systemFontOfSize:50]];
  [forwardButton setTitle:@"⏩️" forState:UIControlStateNormal];
  forwardButton.backgroundColor = [UIColor clearColor];
  forwardButton.adjustsImageWhenHighlighted = NO;

  [self.view addSubview:controllerView];

  [self.view addSubview:playButton];
  [self.view addSubview:backButton];
  [self.view addSubview:forwardButton];


  UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
  tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  tableView.rowHeight = 50;
  tableView.showsVerticalScrollIndicator = YES;
  tableView.backgroundColor = [UIColor blackColor];
  tableView.delegate = self;
  tableView.dataSource = self;
  tableView.scrollEnabled = YES;

  self.tableView = tableView;

  // ADDING VIEWS
  [self.view addSubview:tableView];

  UIButton *sortButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
  sortButton.frame = CGRectMake((self.view.frame.size.width * 0.2), (0.08 * self.view.frame.size.height), 120, 30);
  sortButton.backgroundColor = [UIColor clearColor];
  [sortButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
  [sortButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
  [sortButton setTitle:@"Sorted By: None" forState:UIControlStateNormal];
  [sortButton addTarget:self action:@selector(sortByButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  sortButton.layer.cornerRadius = 10.5f;
  sortButton.layer.borderColor = [UIColor whiteColor].CGColor;
  sortButton.layer.borderWidth= 1.25f;

  self.sortByButton = sortButton;
  [self.view addSubview:sortButton];

  self.sortStyle = 0;
}

- (void)sortByButtonPressed{
  self.sortStyle = self.sortStyle + 1;

  if (self.sortStyle == 4)
    self.sortStyle = 0;

  if (self.sortStyle == 0) {
    [self.sortByButton  setTitle:@"Sorted By: None" forState:UIControlStateNormal];
  }else if (self.sortStyle == 1){
    [self.sortByButton  setTitle:@"Sorted By: Song" forState:UIControlStateNormal];
  }else if (self.sortStyle == 2){
    [self.sortByButton  setTitle:@"Sorted By: Artist" forState:UIControlStateNormal];
  }else if (self.sortStyle == 3){
    [self.sortByButton  setTitle:@"Sorted By: Album" forState:UIControlStateNormal];
  }

  [self.tableView reloadData];
}

- (void)closeButtonPressed{
  [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)generateIdentifiers{
  self.songIdentifiers = [[NSMutableArray alloc] init];
  NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  cachePath = [cachePath stringByAppendingPathComponent:@"PandorasBox"];
  NSArray *artists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:NULL];
  for (int i = 0; i < [artists count]; i++){
    NSArray *albums = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[cachePath stringByAppendingPathComponent:(NSString *)artists[i]] error:NULL];
    for (int j = 0; j < [albums count]; j++){
      NSString *currentPath = [[cachePath stringByAppendingPathComponent:(NSString *)artists[i]] stringByAppendingPathComponent:albums[j]];
      NSArray *songs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentPath error:NULL];
      for (int k = 0; k < [songs count]; k++){
        if (![(NSString *)songs[k] containsString:@"AlbumArtwork.jpg"]){
          PBListItem *newItem = [PBListItem alloc];
          newItem.albumName = [NSString stringWithFormat:@"%@", albums[j]]; // this is done to create a unique string object that can be filtered
          newItem.artistName = [NSString stringWithFormat:@"%@", artists[i]]; // ^^^^
          newItem.albumArtwork = [currentPath stringByAppendingString:@"/AlbumArtwork.jpg"];
          newItem.songName = [(NSString *)songs[k] substringToIndex:([songs[k] length] - 4)];
          newItem.rawPath = [currentPath stringByAppendingPathComponent:songs[k]];
          [self.songIdentifiers addObject:newItem];
        }
      }
    }
  }
}

- (void)sortIdentifiers {
  if (self.sortStyle == 0) {
    return;
  }

  NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
  NSMutableArray *newIdentifiers = [[NSMutableArray alloc] initWithCapacity:self.songIdentifiers.count];
  if (self.sortStyle == 1){
    for (int i = 0; i < self.songIdentifiers.count; i++)
      [sortedArray addObject:[[[self songIdentifiers] objectAtIndex:i] songName]];
    sortedArray = [[sortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    for (int i = 0; i < sortedArray.count; i++){
      NSString *currentString = sortedArray[i];
      for (int j = 0; j < sortedArray.count; j++){
        if (currentString == [self.songIdentifiers[j] songName]){
          [newIdentifiers insertObject:self.songIdentifiers[j] atIndex:i];
          break;
        }
      }
    }
  }else if (self.sortStyle == 2){
    for (int i = 0; i < self.songIdentifiers.count; i++)
      [sortedArray addObject:[[[self songIdentifiers] objectAtIndex:i] artistName]];
    sortedArray = [[sortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    for (int i = 0; i < sortedArray.count; i++){
      NSString *currentString = sortedArray[i];
      for (int j = 0; j < sortedArray.count; j++){
        if (currentString == [self.songIdentifiers[j] artistName]){
          [newIdentifiers insertObject:self.songIdentifiers[j] atIndex:i];
          break;
        }
      }
    }
  }else if (self.sortStyle == 3){
    for (int i = 0; i < self.songIdentifiers.count; i++)
      [sortedArray addObject:[[[self songIdentifiers] objectAtIndex:i] albumName]];
    sortedArray = [[sortedArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    for (int i = 0; i < sortedArray.count; i++){
      NSString *currentString = sortedArray[i];
      for (int j = 0; j < sortedArray.count; j++){
        if (currentString == [self.songIdentifiers[j] albumName]){
          [newIdentifiers insertObject:self.songIdentifiers[j] atIndex:i];
          break;
        }
      }
    }
  }

  self.songIdentifiers = newIdentifiers;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section{
  [self generateIdentifiers];
  [self sortIdentifiers];
  return ([self.songIdentifiers count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  NSString *simpleTableIdentifier = @"cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
  if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
  }

  PBListItem *currentItem = [self.songIdentifiers objectAtIndex:[indexPath row]];
  NSString *detailString = [NSString stringWithFormat:@"%@ • %@", currentItem.albumName, currentItem.artistName];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.imageView.image = [UIImage imageWithContentsOfFile:currentItem.albumArtwork];
  cell.textLabel.text = currentItem.songName;
  [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
  cell.detailTextLabel.text = detailString;
  cell.detailTextLabel.textColor = [UIColor lightGrayColor];
  [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.backgroundColor = [UIColor blackColor];


  if ([self.nowPlayingInfo.rawPath isEqualToString:currentItem.rawPath]){
    [self.nowPlayingInfo release];
    self.nowPlayingInfo = nil;
    self.nowPlayingInfo = currentItem;
    cell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.70 blue:0.95 alpha:0.95];
    cell.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.0];
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  dispatch_async(dispatch_get_main_queue(), ^{
    PBListItem *currentItem = [self.songIdentifiers objectAtIndex:[indexPath row]];

    [self initializeQueuePlayer:currentItem];

    [tableView reloadData];
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.70 blue:0.95 alpha:0.95];
    currentCell.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.0];

    [self.audioPlayer play];
  });

}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
   {
       [self deleteListItemAtIndex:[indexPath row]];
   }];
   button.backgroundColor = [UIColor redColor];
   return @[button];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
       return YES;
}

- (void)deleteListItemAtIndex:(int)index{
  NSFileManager *manager = [NSFileManager defaultManager];
  PBListItem *deletedItem = [self.songIdentifiers objectAtIndex:index];

  [manager removeItemAtPath:[deletedItem rawPath] error:nil];

  NSString *currentPath = [[deletedItem rawPath] stringByDeletingLastPathComponent];
  NSArray *songsAndArtwork = [manager contentsOfDirectoryAtPath:currentPath error:NULL];
  if ([songsAndArtwork count] < 2)
    [manager removeItemAtPath:currentPath error:nil];

  currentPath = [currentPath stringByDeletingLastPathComponent];
  NSArray *Albums = [manager contentsOfDirectoryAtPath:currentPath error:NULL];
  if ([Albums count] == 0)
    [manager removeItemAtPath:currentPath error:nil];

  [self.songIdentifiers removeObjectAtIndex:index];
  [self.tableView reloadData];
}

- (void)initializeQueuePlayer:(PBListItem *)item{
  self.nowPlayingInfo = item;

  if (!self.audioPlayer)
    self.audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:item.rawPath]];

  AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:item.rawPath]];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
    [self initializeBackgroundPlay:item];
  });
  [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
  [self ensurePMPaused];

  [self.playButton setTitle:@"⏸" forState:UIControlStateNormal];
}

- (void)playButtonPressed{
  if (self.audioPlayer.rate != 0){
    [self.audioPlayer pause];
    [self.playButton setTitle:@"▶️" forState:UIControlStateNormal];
  }else{
    [self.audioPlayer play];
    [self.playButton setTitle:@"⏸" forState:UIControlStateNormal];
  }
  if (self.nowPlayingInfo){
    [self ensurePMPaused];
    //[self initializeBackgroundPlay:self.nowPlayingInfo];
  }
}

- (void)backButtonPressed{
  if (CMTimeGetSeconds(self.audioPlayer.currentTime) > 3.0){
    NSMutableDictionary *songInfo = [[(MPNowPlayingInfoCenter *)[NSClassFromString(@"MPNowPlayingInfoCenter") defaultCenter] nowPlayingInfo] mutableCopy];
    [songInfo setObject:[NSNumber numberWithFloat:0.0f] forKey:@"MPNowPlayingInfoPropertyPlaybackTime"];
    [[NSClassFromString(@"MPNowPlayingInfoCenter") defaultCenter] setNowPlayingInfo:songInfo];
    [self.audioPlayer seekToTime:CMTimeMake(0.0, 1.0)];
  }else{
    int nowPlayingIndex = [self.songIdentifiers indexOfObject:self.nowPlayingInfo];
    if (nowPlayingIndex == 0){
      [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:(self.songIdentifiers.count - 1) inSection:0]];
    }else{
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(nowPlayingIndex - 1) inSection:0];
      [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
  }
  if (self.nowPlayingInfo){
    [self ensurePMPaused];
    //[self initializeBackgroundPlay:self.nowPlayingInfo];
  }
}

- (void)forwardButtonPressed{
  int nowPlayingIndex = [self.songIdentifiers indexOfObject:self.nowPlayingInfo];

  if (nowPlayingIndex >= (self.songIdentifiers.count - 1)){
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  }else{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(nowPlayingIndex + 1) inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
  }
  if (self.nowPlayingInfo){
    [self ensurePMPaused];
    //[self initializeBackgroundPlay:self.nowPlayingInfo];
  }
}

- (void)itemDidFinishPlaying:(NSNotification *)arg1{
  int nowPlayingIndex = [self.songIdentifiers indexOfObject:self.nowPlayingInfo];

  if (nowPlayingIndex >= (self.songIdentifiers.count - 1)){
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  }else{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(nowPlayingIndex + 1) inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
  }
}

- (void)initializeBackgroundPlay:(PBListItem *)currentItem{
  [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
  [[AVAudioSession sharedInstance] setActive: YES error: nil];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(250 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    [songInfo setObject:currentItem.songName forKey:@"title"];
    [songInfo setObject:currentItem.albumName forKey:@"albumTitle"];
    [songInfo setObject:currentItem.artistName forKey:@"artist"];
    id albumArt = [[NSClassFromString(@"MPMediaItemArtwork") alloc] initWithImage:[UIImage imageWithContentsOfFile:currentItem.albumArtwork]];
    [songInfo setObject:albumArt forKey:@"artwork"];

    [songInfo setObject:[NSNumber numberWithFloat:CMTimeGetSeconds(self.audioPlayer.currentItem.duration)] forKey:@"playbackDuration"];
    [songInfo setObject:[NSNumber numberWithDouble:1.0f] forKey:@"MPMediaItemPropertyPlaybackRate"];
    [songInfo setObject:[NSNumber numberWithFloat:CMTimeGetSeconds(self.audioPlayer.currentTime)] forKey:@"MPNowPlayingInfoPropertyPlaybackTime"];

    [[NSClassFromString(@"MPNowPlayingInfoCenter") defaultCenter] setNowPlayingInfo:songInfo];

    MPRemoteCommandCenter *commandCenter = [NSClassFromString(@"MPRemoteCommandCenter") sharedCommandCenter];

    if (![commandCenter.previousTrackCommand isEnabled]){
      [commandCenter.playCommand removeTarget:nil];
      [commandCenter.playCommand addTarget:self action:@selector(handleCommand:)];
      [commandCenter.playCommand setEnabled:YES];

      [commandCenter.pauseCommand removeTarget:nil];
      [commandCenter.pauseCommand addTarget:self action:@selector(handleCommand:)];
      [commandCenter.pauseCommand setEnabled:YES];

      [commandCenter.previousTrackCommand removeTarget:nil];
      [commandCenter.previousTrackCommand addTarget:self action:@selector(handleCommand:)];
      [commandCenter.previousTrackCommand setEnabled:YES];

      [commandCenter.nextTrackCommand removeTarget:nil];
      [commandCenter.nextTrackCommand addTarget:self action:@selector(handleCommand:)];
      [commandCenter.nextTrackCommand setEnabled:YES];

      [commandCenter.changePlaybackPositionCommand removeTarget:nil];
      [commandCenter.changePlaybackPositionCommand addTarget:self action:@selector(handleCommand:)];
      [commandCenter.changePlaybackPositionCommand setEnabled:YES];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.audioPlayer.currentItem];
    [self becomeFirstResponder];
  });
}

- (void)viewDidAppear:(BOOL)animated{
    if ([self listNeedsUpdating])
      [self.tableView reloadData];
}

- (BOOL)prefersHomeIndicatorAutoHidden{
   return YES;
}

- (int)handleCommand:(MPRemoteCommandEvent *)event{
    if ([[event command] mediaRemoteCommandType] == 0 || [[event command] mediaRemoteCommandType] == 1 || [[event command] mediaRemoteCommandType] == 2)
        [self playButtonPressed];
    if ([[event command] mediaRemoteCommandType] == 4)
        [self forwardButtonPressed];
    if ([[event command] mediaRemoteCommandType] == 5)
        [self backButtonPressed];
    if ([[event command] mediaRemoteCommandType] == 24){
        CMTime seekToTime = CMTimeMakeWithSeconds([event positionTime], 1);
        [[self audioPlayer] seekToTime:seekToTime];
    }
    return 0;
}

- (BOOL)canBecomeFirstResponder{
  return YES;
}

- (void)ensurePMPaused{
  if ([[self PMDelegate] isPlaying]){
    PMPlayingButton *button = (PMPlayingButton *)[[[[self PMDelegate] nowPlayingControlBarView] subviews] objectAtIndex:0];
    [button callOnTouchUp:nil];
  }
}

- (BOOL)listNeedsUpdating {
  int count = 0;
  NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  cachePath = [cachePath stringByAppendingPathComponent:@"PandorasBox"];
  NSArray *artists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:NULL];
  for (int i = 0; i < [artists count]; i++){
    NSArray *albums = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[cachePath stringByAppendingPathComponent:(NSString *)artists[i]] error:NULL];
    for (int j = 0; j < [albums count]; j++){
      NSString *currentPath = [[cachePath stringByAppendingPathComponent:(NSString *)artists[i]] stringByAppendingPathComponent:albums[j]];
      NSArray *songs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentPath error:NULL];
      for (int k = 0; k < [songs count]; k++){
        if (![(NSString *)songs[k] containsString:@"AlbumArtwork.jpg"]){
          count++;
        }
      }
    }
  }
  if (count != self.songIdentifiers.count)
    return YES;
  return NO;
}

@end
