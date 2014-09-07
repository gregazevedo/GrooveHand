//
//  MyoMusicPlayer.h
//  MyoHue
//
//  Created by Katelyn Findlay on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MyoMusicPlayer : NSObject

-(void)stopMusic;
-(void)playMusic;
-(void)pauseMusic;
-(void)playNextSong;
-(void)playLastSong;



@end
