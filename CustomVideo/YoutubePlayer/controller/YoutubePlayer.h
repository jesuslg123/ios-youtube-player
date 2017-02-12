//
//  VideoContainer.h
//  CustomVideo
//
//  Created by Jesus Tiendeo on 3/8/15.
//  Copyright (c) 2015 Jesus Tiendeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YoutubePlayerProtocol.h"
#import "XCDYouTubeVideoPlayerViewController.h"

@interface YoutubePlayer : UIView

@property(nonatomic, weak) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightButtonConstraint;
@property (weak, nonatomic) id<YoutubePlayerDelegate> delegate;

- (void) startVidePlayerOnView:(UIView *)theView mode:(YoutubePlayerViewState)aMode;
- (void) loadVideoWithID:(NSString *) theVideoID;
- (void) autoPlayVideoWithID:(NSString *) theVideoID;
- (NSString *) getYoutbeIDFromURL:(NSString *) theURL;
- (void)setVideoSizeTo:(YoutubePlayerViewState)newState;
- (void)close;

@property (nonatomic) BOOL pauseWhenMinimized;
@property (nonatomic) BOOL backgroundWhenMaximized;
@property (nonatomic) BOOL startWithPreview;

@property (nonatomic, strong) NSString *videoID;

@end
		
