/*
probably should have made this a struct, but I had different intentions
 when I had first started making this...
 */
#import <UIKit/UIKit.h>
@interface PBListItem : NSObject

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *albumArtwork;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSString *rawPath;

@end
