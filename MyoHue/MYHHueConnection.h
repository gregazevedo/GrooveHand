//
//  MYHHueConnection.h
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MYHState) {
    MYHStateDefault,
    MYHStatePartyMode,
    MYHStateAdjustingBrightness
};

@interface MYHHueConnection : NSObject

@property (nonatomic) BOOL lightOn;
@property (nonatomic) BOOL isPartyMode;
@property (nonatomic) NSMutableArray *hueColors;
@property (nonatomic) int index;
@property (nonatomic) NSNumber *initialColor;
@property (nonatomic) NSNumber *currentBrightness;
@property (nonatomic) MYHState state;

@property (nonatomic) NSTimer *brightnessIncreaseTimer;
@property (nonatomic) NSTimer *brightnessDecreaseTimer;

-(void)retrieveInitialHueInfo;
-(void)updateHueWithMessageBody:(NSString *)messageBody;
-(void)createColors;
-(void)toggleLightOn;
-(void)togglePartyMode;
-(void)updateToNextHue;
-(void)updateToPreviousHue;
-(void)adjustBrightnessWithRotation:(int)rotation;

@end
