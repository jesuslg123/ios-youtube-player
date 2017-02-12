//
//  YoutubePlayerProtocol.h
//  Tiendeo
//
//  Created by Jesus Tiendeo on 5/8/15.
//  Copyright (c) 2015 Tiendeo. All rights reserved.
//

#ifndef Tiendeo_YoutubePlayerProtocol_h

typedef NS_ENUM(NSInteger, YoutubePlayerViewState) {
    YoutubePlayerViewStateMinimized,
    YoutubePlayerViewStateMaximized
};

typedef NS_ENUM(NSInteger, YoutubePlayerState) {
    YoutubePlayerStatePlaying,
    YoutubePlayerStateStoped,
    YoutubePlayerStatePaused
};

@protocol YoutubePlayerDelegate <NSObject>

@required
- (void)youtubePlayer:(id)thePlayer didChangeState:(YoutubePlayerState) theState;
- (void)youtubePlayerWillClose:(id)thePlayer;

@end

#define Tiendeo_YoutubePlayerProtocol_h


#endif
