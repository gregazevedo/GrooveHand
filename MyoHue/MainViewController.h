//
//  MainViewController.h
//  MyoLights
//
//  Created by Alexander Athan on 9/6/14.
//  Copyright (c) 2014 Dolo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyoStuff.h"

typedef NS_ENUM(NSUInteger, MYHState) {
    MYHStateDefault,
    MYHStatePartyMode,
    MYHStateAdjustingBrightness
};

@interface MainViewController : NSViewController <MyoDelegate>

@property (nonatomic) BOOL lightOn;
@property (nonatomic) BOOL isPartyMode;
@property (nonatomic) NSMutableArray *hueColors;
@property (nonatomic) int index;
@property (nonatomic) NSNumber *initialColor;
@property (nonatomic) NSNumber *currentBrightness;
@property (nonatomic) MYHState state;

@end
