//
//  MainViewController.h
//  MyoLights
//
//  Created by Alexander Athan on 9/6/14.
//  Copyright (c) 2014 Dolo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyoStuff.h"

@class MyoMusicPlayer, MYHHueConnection;

typedef NS_ENUM(NSUInteger, MYHMode) {
    MYHModeLights,
    MYHModeMusic
};

@interface MainViewController : NSViewController <MyoDelegate>

@property (nonatomic) MyoMusicPlayer *player;
@property (nonatomic) MYHHueConnection *lights;

//@property (nonatomic) int latestNoFistRoll;

@end
