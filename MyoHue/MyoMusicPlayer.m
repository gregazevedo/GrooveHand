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
@property (nonatomic) NSMutableArray *songList;
@property (nonatomic) int songIndex;

@end
@implementation MyoMusicPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.songIndex = 0;
        self.songList = [NSMutableArray new];
        [self createPlaylist];
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
    [self.songPlayer play];
}

-(void)pauseMusic {
    [self.songPlayer pause];
}

-(void)stopMusic {
    [self.songPlayer stop];
}

-(void)playNextSong {
    self.songIndex++;
    if(self.songIndex == 15) {
        self.songIndex = 0;
    }
    [self playSongWithName:[self.songList objectAtIndex:self.songIndex]];
}

-(void)playLastSong {
    if(self.songIndex == 0) {
        self.songIndex = 14;
    } else {
        self.songIndex--;
    }
    [self playSongWithName:[self.songList objectAtIndex:self.songIndex]];
}

-(void)createPlaylist {
    [self.songList addObject:@"YoungBlood"];
    [self.songList addObject:@"SweetNothing"];
    [self.songList addObject:@"NeverLetYouGo"];
    [self.songList addObject:@"ShakeItOut"];
    [self.songList addObject:@"APunk"];
    [self.songList addObject:@"Daylight"];
    [self.songList addObject:@"OneHeadlight"];
    [self.songList addObject:@"RedHands"];
    [self.songList addObject:@"DropsofJupiter"];
    [self.songList addObject:@"CrookedTeeth"];
    [self.songList addObject:@"SweetDisposition"];
    [self.songList addObject:@"Houdini"];
    [self.songList addObject:@"LittleSecrets"];
    [self.songList addObject:@"Years"];
    [self.songList addObject:@"TimeToPretend"];
}

@end
