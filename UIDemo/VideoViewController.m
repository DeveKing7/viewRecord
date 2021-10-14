//
//  TestVideoViewController.m
//  Memento
//
//  Created by Ömer Faruk Gül on 22/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "VideoViewController.h"
@import AVFoundation;

@interface VideoViewController ()
@property (strong, nonatomic) NSURL *videoUrl;


@end

@implementation VideoViewController{
    
    
    AVPlayerViewController      *_playerController;
    
    
    
    AVPlayer                    *_player;
    AVAudioSession              *_session;
    
    UIButton * _cancelButton;
    
    
}

- (instancetype)initWithVideoUrl:(NSURL *)url {
    self = [super init];
    if(self) {
        _videoUrl = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (self.videoUrl) {
        _session = [AVAudioSession sharedInstance];
        [_session setCategory:AVAudioSessionCategoryPlayback error:nil];
       AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_videoUrl];
        
       _player = [AVPlayer playerWithPlayerItem:item];
       // _player = [[AVAudioPlayer alloc]initWithContentsOfURL:_videoUrl error:nil];
        self.player = _player;
        self.videoGravity = AVLayerVideoGravityResizeAspect;
        self.delegate = self;
        self.allowsPictureInPicturePlayback = true;    //画中画，iPad可用
        self.showsPlaybackControls = true;
        
        
        self.view.translatesAutoresizingMaskIntoConstraints = true;    //AVPlayerViewController 内部可能是用约束写的，这句可以禁用自动约束，消除报错
        CGRect frame = self.view.bounds;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height == 812.0f?(88):(64);
        //                                                             _playerController.view.frame = frame;
        
        
        //自动播放
        
        
        
        
        _playerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieFinishedCallback:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    
    // cancel button
    [self.view addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.frame = CGRectMake(0, 0, 44, 44);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.player play];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)movieFinishedCallback:(NSNotification*) aNotification {
   
    [_player pause];
   
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
     [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}


- (UIButton *)cancelButton {
    if(!_cancelButton) {
        UIImage *cancelImage = [UIImage imageNamed:@"cancel.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor whiteColor];
        [button setImage:cancelImage forState:UIControlStateNormal];
        button.imageView.clipsToBounds = NO;
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        button.layer.shadowOpacity = 0.4f;
        button.layer.shadowRadius = 1.0f;
        button.clipsToBounds = NO;
        
        _cancelButton = button;
    }
    
    return _cancelButton;
}

- (void)cancelButtonPressed:(UIButton *)button {
    NSLog(@"cancel button pressed!");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
