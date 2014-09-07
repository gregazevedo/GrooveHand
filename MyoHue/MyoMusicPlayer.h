//
//  MyoMusicPlayer.h
//  MyoHue
//
//  Created by Katelyn Findlay on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, MYMState) {
    MYMStateDefault,
    MYMStateAdjustingVolume
};

@interface MyoMusicPlayer : NSObject

@property (nonatomic) MYMState state;
@property (nonatomic) NSTimer *volumeIncreaseTimer;
@property (nonatomic) NSTimer *volumeDecreaseTimer;

-(void)stopMusic;
-(void)playMusic;
-(void)pauseMusic;
-(void)toggleMusic;
-(void)playNextSong;
-(void)playLastSong;
-(void)adjustVolumeWithRotation:(int)rotation;




@end
