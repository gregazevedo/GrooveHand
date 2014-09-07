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
-(void)myo:(Myo *)myo onAccelerometerDataWithVector:(MyoVector*)vector
{
    //    NSLog(@"accelerometer x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
}
-(void)myo:(Myo *)myo onGyroscopeDataWithVector:(MyoVector*)vector
{
    //    NSLog(@"gyroscope x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
    int x = (int)vector.x;
    //    x -= x % 10;
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
    NSLog(@"Current Pose: %i", pose);
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

-(void)myo:(Myo *)myo onPose:(MyoPose *)pose
{
    if (self.mode == MYHModeLights) {
        [self updateLightsForPose:pose.poseType];
    } else if (self.mode == MYHModeMusic) {
        [self updateMusicForPose:pose.poseType];
    }
}

@end
