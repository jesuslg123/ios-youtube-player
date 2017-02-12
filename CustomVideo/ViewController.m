//
//  ViewController.m
//  CustomVideo
//
//  Created by Jesus Tiendeo on 3/8/15.
//  Copyright (c) 2015 Jesus Tiendeo. All rights reserved.
//

#import "ViewController.h"
#import "YoutubePlayer.h"

@interface ViewController ()
{
    BOOL alternar;
}

@property (nonatomic, strong) YoutubePlayer *videoAux;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoAux = nil;
    alternar = NO;
    
}

- (void)initVideoPlayer {
    self.videoAux = [[YoutubePlayer alloc] init];
    [self.videoAux setPauseWhenMinimized:NO];
    [self.videoAux setBackgroundWhenMaximized:NO];
    [self.videoAux setStartWithPreview:YES];
    [self.videoAux loadVideoWithID:@"wdb7MKYC57Q"];
    [self.videoAux startVidePlayerOnView:self.view mode:YoutubePlayerViewStateMinimized];
}

- (void)minimize {
    if (self.videoAux == nil) {
        [self initVideoPlayer];
    }
    [self.videoAux setVideoSizeTo:YoutubePlayerViewStateMinimized];
}

- (void)maximize {
    if (self.videoAux == nil) {
        [self initVideoPlayer];
    }
    [self.videoAux setVideoSizeTo:YoutubePlayerViewStateMaximized];
}

- (void)viewDidAppear:(BOOL)animated
{

}
- (IBAction)addVideoFull:(id)sender
{
    [self maximize];
}
- (IBAction)addView:(id)sender
{
    [self minimize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
