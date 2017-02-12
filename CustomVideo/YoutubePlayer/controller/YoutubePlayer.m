//
//  VideoContainer.m
//  CustomVideo
//
//  Created by Jesus Tiendeo on 3/8/15.
//  Copyright (c) 2015 Jesus Tiendeo. All rights reserved.
//

#import "YoutubePlayer.h"

#define previewURL @"http://img.youtube.com/vi/%@/0.jpg"
#define isIPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface YoutubePlayer()

@property (nonatomic, strong) NSMutableDictionary *views;
@property (nonatomic, strong) NSMutableDictionary *metrics;
@property (nonatomic, strong) NSMutableArray *addedConstraints;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic) BOOL isMinimized;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayer;

@end

@implementation YoutubePlayer

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self setUp];
    }
    
    return self;
}

- (id) init
{
    if(self = [super init])
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"YoutubePlayer" owner:nil options:nil] firstObject];
        [self setUp];
    }
    
    return self;
}

- (void)loadConstraints
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.addedConstraints = [NSMutableArray new];
    
    self.metrics = [NSMutableDictionary new];
    self.views = [NSMutableDictionary new];
    
    [self.views setObject:self forKey:@"self"];
    [self.metrics setObject:[NSNumber numberWithInt:10] forKey:@"margin"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) && isIPAD == NO)
    {
        [self.metrics setObject:[NSNumber numberWithFloat:screenWidth/screenHeight] forKey:@"aspectRatio"];
    }
    else
    {
        [self.metrics setObject:[NSNumber numberWithFloat:screenHeight/screenWidth] forKey:@"aspectRatio"];
    }
    
}

//To fix when re-appear using the same instance
- (void) setUp
{
    [self setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width , [[UIScreen mainScreen] bounds].size.height, 0, 0)];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self loadConstraints];
    
    self.isMinimized = NO;
    self.pauseWhenMinimized = NO;
    self.backgroundWhenMaximized = NO;
    self.startWithPreview = YES;
    
    [self.closeButton.layer setZPosition:99999];
    
    UITapGestureRecognizer *previewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped)];
    [self.previewView addGestureRecognizer:previewTapGesture];
}


- (void) viewTapped {
    
}

- (void) previewTapped {
    [self hidePreviewView];
    [self setFullMode];
    [self playVideo];
}

- (void)setupView:(UIView *)theView
{
    
    [self setAlpha:1.f];
    [self.bgView removeFromSuperview];
    
    if([theView.subviews containsObject:self])
    {
        return;
    }
    
    [self setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width , [[UIScreen mainScreen] bounds].size.height, 0, 0)];
    
    [self.closeButton.layer setZPosition:99999];
    
    self.parentView = theView;
    [self.views setObject:self.parentView forKey:@"parentView"];
    [self.parentView addSubview:self];
    [self.parentView bringSubviewToFront:self];
}

- (void) startVidePlayerOnView:(UIView *)theView mode:(YoutubePlayerViewState)aMode {
    switch (aMode) {
        case YoutubePlayerViewStateMinimized:
            [self startMinimizedOnView:theView];
            break;
        case YoutubePlayerViewStateMaximized:
            [self startMaximizedOnView:theView];
            break;
    }
}

- (void) startMinimizedOnView:(UIView *) theView
{
    [self setupView:theView];
    self.isMinimized = NO;
    [self setMinimizedMode];
}

- (void) startMaximizedOnView:(UIView *) theView
{
    [self setupView:theView];
    self.isMinimized = YES;
    [self setFullMode];
}

- (void) autoPlayVideoWithID:(NSString *) theVideoID
{
    [self loadVideoWithID:theVideoID andPlay:YES];
}

- (void) loadVideoWithID:(NSString *) theVideoID
{
    [self loadVideoWithID:theVideoID andPlay:NO];
}


- (void)loadVideoWithID:(NSString *)theVideoID andPlay:(BOOL) isAutoPlay
{
    [self setVideoID:theVideoID];
    [self loadPreviewImageWithID:theVideoID];
    [self initVideoWithID:theVideoID];
    [self showVideoView];
    
    if(isAutoPlay)
        [self playVideo];
}


- (void) loadPreviewImageWithID:(NSString *) theVideoID
{
    if(self.startWithPreview)
    {
        [self showPreviewView];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:previewURL, theVideoID]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc]initWithData:data];
        [self.previewImageView setImage:img];
    }
    else
    {
        [self hidePreviewView];
    }
}




- (void) setMinimizedMode
{
    if(self.isMinimized == NO)
    {
        [self setSmallViewConstraints];
        self.isMinimized = YES;
        
        if(self.pauseWhenMinimized) {
            [self.videoPlayer.moviePlayer pause];
            
        }
    }
}

- (void) setFullMode
{
    if(self.isMinimized == YES)
    {
        [self setBigViewConstraints];
        self.isMinimized = NO;
        
        if (self.backgroundWhenMaximized)
            [self showGrayBackground];
    }
}


- (void) setSmallViewConstraints
{
    [self removeOldConstraints];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.parentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:50];
    [self.parentView addConstraint:bottomConstraint];
    
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.parentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10];
    [self.parentView addConstraint:trailingConstraint];
    
    NSLayoutConstraint *equalWidthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.parentView attribute:NSLayoutAttributeWidth multiplier:0.45 constant:0];
    [self.parentView addConstraint:equalWidthConstraint];
    
    NSLayoutConstraint *aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:[[self.metrics objectForKey:@"aspectRatio"] floatValue] constant:0];
    [self.parentView addConstraint:aspectRatioConstraint];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.parentView updateConstraintsIfNeeded];
    [self.parentView layoutIfNeeded];
    [UIView commitAnimations];
    
    [self.addedConstraints addObject:aspectRatioConstraint];
    [self.addedConstraints addObject:trailingConstraint];
    [self.addedConstraints addObject:equalWidthConstraint];
    [self.addedConstraints addObject:bottomConstraint];
}


- (void) setBigViewConstraints
{
    [self removeOldConstraints];
    
    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:self.parentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.parentView addConstraint:yCenterConstraint];
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.parentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.parentView addConstraint:leadingConstraint];
    
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.parentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.parentView addConstraint:trailingConstraint];
    
    NSLayoutConstraint *aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:[[self.metrics objectForKey:@"aspectRatio"] floatValue] constant:0];
    [self.parentView addConstraint:aspectRatioConstraint];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.parentView updateConstraintsIfNeeded];
    [self.parentView layoutIfNeeded];
    [UIView commitAnimations];
    
    
    [self.addedConstraints addObject:aspectRatioConstraint];
    [self.addedConstraints addObject:yCenterConstraint];
    [self.addedConstraints addObject:trailingConstraint];
    [self.addedConstraints addObject:leadingConstraint];
}

- (void) removeOldConstraints
{
    for (int i=0; i<self.addedConstraints.count; i++)
    {
        id constraint = self.addedConstraints[i];
        if([constraint isKindOfClass:[NSArray class]])
            [self.parentView removeConstraints:constraint];
        else
            [self.parentView removeConstraint:constraint];
    }
    self.addedConstraints = [NSMutableArray new];
}

- (void)setVideoSizeTo:(YoutubePlayerViewState)newState {
    switch (newState) {
        case YoutubePlayerViewStateMinimized:
            [self setMinimizedMode];
            break;
            
        case YoutubePlayerViewStateMaximized:
            [self setFullMode];
            break;
    }
}

- (void) changeViewMode {
    if(self.isMinimized) {
        [self setFullMode];
    }
    else {
        [self setMinimizedMode];
    }
}

- (void) showPreviewView
{
    [self.previewView.layer setZPosition:998];
    [self.previewView setHidden:NO];
}

- (void) hidePreviewView
{
    [self.previewView.layer setZPosition:-1];
    [self.previewView setHidden:YES];
}

#pragma Background view configuration methods

- (void) showGrayBackground
{
    float size = self.parentView.frame.size.height;
    if(self.parentView.frame.size.height < self.parentView.frame.size.width)
        size = self.parentView.frame.size.width;
    
    CGRect maxFrame = CGRectMake(0, 0, size, size); //This need to be udpated to constrains, but it was breaking
    self.bgView = [[UIView alloc] initWithFrame:maxFrame];
    [self.bgView setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.8]];
    [self.parentView insertSubview:self.bgView belowSubview:self];
    
}

- (void) hideGrayBackground
{
    [self.bgView removeFromSuperview];
}

#pragma Buttons calls

- (void)remove
{
    [self notifyWillClose];
    [self close];
}

- (void) close
{
    [self removeVideo];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.alpha = 0.0;
                         self.bgView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self hideGrayBackground];
                         [self removeFromSuperview];
                     }];
    
}
- (IBAction)stateChangeAction:(id)sender {
    [self changeViewMode];
}

- (IBAction)closeView:(id)sender {
    [self remove];
}

- (NSString *) getYoutbeIDFromURL:(NSString *) theURL
{
    NSString *regexString = @"^(?:http(?:s)?://)?(?:www\\.)?(?:m\\.)?(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)/))([^\?&\"'>]+)";
    
    NSError *error;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:regexString
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:theURL
                                                    options:0
                                                      range:NSMakeRange(0, [theURL length])];
    
    if (match && match.numberOfRanges == 2) {
        NSRange videoIDRange = [match rangeAtIndex:1];
        NSString *videoID = [theURL substringWithRange:videoIDRange];
        
        return videoID;
    }
    return nil;
}


#pragma VideoPlayer methods wraps
- (void) showVideoView
{
    [self.videoPlayer removeFromParentViewController];
    [self.videoPlayer presentInView:self.playerView];
}

- (void) playVideo
{
    [self.videoPlayer.moviePlayer play];
    [self hidePreviewView];
    [self notifyStateChange:YoutubePlayerStatePlaying];
}

- (void) pauseVideo
{
    [self.videoPlayer.moviePlayer pause];
    [self notifyStateChange:YoutubePlayerStatePaused];
}

- (void) stopVideo
{
    [self.videoPlayer.moviePlayer stop];
    [self notifyStateChange:YoutubePlayerStateStoped];
}

- (void) initVideoWithID:(NSString *) theVideoID
{
    if(self.videoPlayer == nil)
    {
        self.videoPlayer = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:theVideoID];
        [self.videoPlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    }
    else
    {
        [self stopVideo];
        [self.videoPlayer setVideoIdentifier:theVideoID];
    }
}

- (void) removeVideo
{
    [self stopVideo];
    [self.videoPlayer removeFromParentViewController];
    self.videoPlayer = nil;
}

#pragma mark - Delegate calls

- (void) notifyStateChange:(YoutubePlayerState) theState
{
    if([self.delegate respondsToSelector:@selector(youtubePlayer:didChangeState:)])
        [self.delegate youtubePlayer:self didChangeState:theState];
}

- (void) notifyWillClose
{
    if([self.delegate respondsToSelector:@selector(youtubePlayerWillClose:)])
        [self.delegate youtubePlayerWillClose:self];
}

@end
