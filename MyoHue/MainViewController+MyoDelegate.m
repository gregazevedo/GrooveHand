//
//  MainViewController+MyoDelegate.m
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MainViewController+MyoDelegate.h"
#import "MYHHueConnection.h"
#import "MyoMusicPlayer.h"

@implementation MainViewController (MyoDelegate)

-(void)myo:(Myo *)myo onAccelerometerDataWithVector:(MyoVector*)vector
{
//    if (fabsf(vector.x) > 1.5 && self.canSwitchMode) {
//        self.mode = MYHModeLights;
//        NSLog(@"accelerometer x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
//        NSLog(@"TOGGLE TO LIGHT MODE");
//        self.latestCommand = @"Toggled To Light Mode";
//        self.canSwitchMode = NO;
//        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(allowModeSwitch:) userInfo:nil repeats:NO];
//
//    } else if (fabsf(vector.y) > 1.5 && self.canSwitchMode) {
//        self.mode = MYHModeMusic;
//        NSLog(@"accelerometer x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
//        self.latestCommand = @"Toggled To Music Mode";
//        NSLog(@"TOGGLE TO MUSIC MODE");
//        self.canSwitchMode = NO;
//        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(allowModeSwitch:) userInfo:nil repeats:NO];
//    }
}

-(void)myo:(Myo *)myo onGyroscopeDataWithVector:(MyoVector*)vector
{
    
    if (vector.y > self.highY) {
        self.highY = vector.y;
        self.lowY = vector.y;
    }
    if (vector.y < self.lowY) {
        self.lowY = vector.y;
    }
    
    if (self.highY - self.lowY > 300) {
        NSLog(@"gyroscope x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
        NSLog(@"high %f low %f", self.highY, self.lowY);

        if (self.mode == MYHModeLights) {
            self.mode = MYHModeMusic;
            NSLog(@"TOGGLE TO MUSIC MODE");

        } else {
            self.mode = MYHModeLights;
            NSLog(@"TOGGLE TO LIGHT MODE");

        }
        self.highY = -999;
        self.lowY = -999;
    }
    
//    if (vector.y > 200 && self.canSwitchMode) {
//        self.mode = MYHModeLights;
//        NSLog(@"accelerometer x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
//        NSLog(@"TOGGLE TO LIGHT MODE");
//        self.latestCommand = @"Toggled To Light Mode";
//        self.canSwitchMode = NO;
//        
//    } else if (vector.y < -200 && self.canSwitchMode) {
//        self.mode = MYHModeMusic;
//        NSLog(@"accelerometer x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
//        self.latestCommand = @"Toggled To Music Mode";
//        NSLog(@"TOGGLE TO MUSIC MODE");
//        self.canSwitchMode = NO;
//    }
//
    
    
    int x = (int)vector.x;
    x = vector.usbTowardsWrist ? x : -x;
//    NSLog(@"rotation vec x %f int x %i", vector.x, x);
}

-(void)myo:(Myo *)myo onOrientationDataWithRoll:(int)roll pitch:(int)pitch yaw:(int)yaw
{
    //    NSLog(@"orientation roll %i pitch %i yaw %i", roll, pitch, yaw);
    
    roll = -roll*100;
    if (self.mode == MYHModeLights){
        if (self.lights.state == MYHStateAdjustingBrightness) {
            int fistedRollChange = roll-self.latestNoFistRoll;
            [self.lights adjustBrightnessWithRotation:fistedRollChange];
        }
        else {
            self.latestNoFistRoll = roll;
        }
    }else if (self.mode == MYHModeMusic){
        if (self.player.state == MYMStateAdjustingVolume) {
            int fistedRollChange = roll-self.latestNoFistRoll;
            [self.player adjustVolumeWithRotation:fistedRollChange];
        }
        else {
            self.latestNoFistRoll = roll;
        }
    }
}

-(void)myo:(Myo *)myo onRssi:(int8_t)rssi
{
    NSLog(@"Myo on rssi");
}

-(void)updateLightsForPose:(MyoPoseType)pose
{
    self.lights.state = MYHStateDefault;
    switch (pose) {
        case MyoPoseTypeRest:
            break;
        case MyoPoseTypeFingersSpread:
            [self.lights toggleLightOn];
            break;
        case MyoPoseTypeWaveOut:
            [self.lights updateToNextHue];
            break;
        case MyoPoseTypeWaveIn:
            [self.lights updateToPreviousHue];
            break;
        case MyoPoseTypeFist:
            self.lights.state = MYHStateAdjustingBrightness;
            break;
        case MyoPoseTypeThumbToPinky:
//            [self.lights togglePartyMode];
            break;
        case MyoPoseTypeReserved:
            break;
    }
}

-(void)updateMusicForPose:(MyoPoseType)pose
{
    self.player.state = MYMStateDefault;
    switch (pose) {
        case MyoPoseTypeRest:
            break;
        case MyoPoseTypeFist:
            self.player.state = MYMStateAdjustingVolume;
            break;
        case MyoPoseTypeFingersSpread:
            [self.player toggleMusic];
            [self.lights togglePartyMode];
            NSLog(@"toggle music");
            break;
        case MyoPoseTypeWaveIn:
            [self.player playNextSong];
            break;
        case MyoPoseTypeWaveOut:
            [self.player playLastSong];
            break;
        case MyoPoseTypeThumbToPinky:
            break;
        case MyoPoseTypeReserved:
            break;
    }
}

-(void)allowModeSwitch:(NSTimer *)timer
{
    NSLog(@"arg: %@", timer);
    self.canSwitchMode = YES;
}

-(void)myo:(Myo *)myo onPose:(MyoPose *)pose
{
    switch (pose.poseType) {
        case MyoPoseTypeFist:
            NSLog(@"MyoPoseTypeFist");
            break;
        case MyoPoseTypeFingersSpread:
            NSLog(@"MyoPoseTypeFingersSpread");
            break;
        case MyoPoseTypeWaveIn:
            NSLog(@"MyoPoseTypeWaveIn");
            break;
        case MyoPoseTypeWaveOut:
            NSLog(@"MyoPoseTypeWaveOut");
            break;
        case MyoPoseTypeRest:
            NSLog(@"MyoPoseTypeRest");
            break;
        case MyoPoseTypeThumbToPinky:
            NSLog(@"MyoPoseTypeThumbToPinky");
            break;
    }
    
    switch (self.mode) {
        case MYHModeLights:
            NSLog(@"MYHModeLights");
            break;
        case MYHModeMusic:
            NSLog(@"MYHModeMusic");
            break;
    }
    
    if (pose.poseType == MyoPoseTypeRest) {
        self.canSwitchMode = YES;
    } else {
        self.canSwitchMode = NO;
    }
    
//    self.state = MYHStateDefault;
    if (self.mode == MYHModeLights) {
        [self updateLightsForPose:pose.poseType];
    } else if (self.mode == MYHModeMusic) {
        [self updateMusicForPose:pose.poseType];
    }
}

-(void)myoOnConnect:(Myo *)myo
{
    NSLog(@"Myo on connect");
}

-(void)myoOnDisconnect:(Myo *)myo
{
    NSLog(@"Myo on disconnect");
}

-(void)myoOnArmRecognized:(Myo *)myo
{
    NSLog(@"Myo on arm recognized");
}

-(void)myoOnArmLost:(Myo *)myo
{
    NSLog(@"Myo on arm lost");
}

-(void)myoOnPair:(Myo *)myo
{
    NSLog(@"Myo on pair");
}

@end
