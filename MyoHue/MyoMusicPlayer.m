//
//  MyoMusicPlayer.m
//  MyoHue
//
//  Created by Katelyn Findlay on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MyoMusicPlayer.h"

@interface MyoMusicPlayer()
@property (nonatomic) AVAudioPlayer *songPlayer;
@property (nonatomic) NSArray *songList;
@property (nonatomic) int songIndex;
@property (nonatomic) BOOL isPlaying;

@end
@implementation MyoMusicPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.songIndex = 0;
//        self.songList = [NSMutableArray new];
//        [self createPlaylist];
    }
    return self;
}

-(void)playSongWithName:(NSString *)song {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:song ofType:@"mp3"]];
    self.songPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.songPlayer setVolume:1.0f];
    [self.songPlayer play];
    NSLog(@"playing music");
}

-(void)playMusic {
    if (!self.songPlayer) {
        NSString *title = [self.songList firstObject];
        [self playSongWithName:title];
    }
    [self.songPlayer play];
    self.isPlaying = true;
}

-(void)pauseMusic {
    [self.songPlayer pause];
    self.isPlaying = false;
}

-(void)stopMusic {
    [self.songPlayer stop];
    self.isPlaying = false;
}

-(void)playNextSong {
   self.songIndex++;
    if(self.songIndex == 15) {
        self.songIndex = 0;
    }
    [self playSongWithName:[self.songList objectAtIndex:self.songIndex]];
    self.isPlaying = true;
}

-(void)playLastSong {
    if(self.songIndex == 0) {
        self.songIndex = 14;
    } else {
        self.songIndex--;
    }
    [self playSongWithName:[self.songList objectAtIndex:self.songIndex]];
    self.isPlaying = true;
}

-(void) toggleMusic {
    if(self.isPlaying) {
        [self pauseMusic];
    } else {
        [self playMusic];
    }
}

-(NSArray *)songList
{
    if (!_songList) {
        _songList = @[@"YoungBlood",@"SweetNothing", @"NeverLetYouGo", @"ShakeItOut", @"APunk",@"Daylight",@"OneHeadlight",@"RedHands",@"DropsofJupiter",
                      @"CrookedTeeth",@"SweetDisposition",@"Houdini",
                      @"LittleSecrets",@"Years",@"TimeToPretend"];
    }
    return _songList;
}

@end
