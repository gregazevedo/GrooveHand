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
    x = vector.usbTowardsWrist ? x : -x;
    //    x -= x % 10;
//    NSLog(@"rotation vec x %f int x %i", vector.x, x);
}

-(void)myo:(Myo *)myo onOrientationDataWithRoll:(int)roll pitch:(int)pitch yaw:(int)yaw
{
//    NSLog(@"orientation roll %i pitch %i yaw %i", roll, pitch, yaw);

    if (self.lights.state == MYHStateAdjustingBrightness) {
        int fistedRollChange = roll-self.latestNoFistRoll;
        [self.lights adjustBrightnessWithRotation:fistedRollChange];
    }
    else {
        self.latestNoFistRoll = roll;
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
            [self.lights togglePartyMode];
            break;
        case MyoPoseTypeReserved:
            break;
    }
}

-(void)updateMusicForPose:(MyoPoseType)pose
{
    switch (pose) {
        case MyoPoseTypeFist:
            NSLog(@"fist made");
            break;
        case MyoPoseTypeFingersSpread:
            [self.player toggleMusic];
            NSLog(@"togglemusic");
            break;
        case MyoPoseTypeWaveIn:
            [self.player playNextSong];
            break;
        case MyoPoseTypeWaveOut:
            [self.player playLastSong];
            break;
    }
}

-(void)myo:(Myo *)myo onPose:(MyoPose *)pose
{
//    self.state = MYHStateDefault;
    if (self.mode == MYHModeLights) {
        [self updateLightsForPose:pose.poseType];
    } else if (self.mode == MYHModeMusic) {
        [self updateMusicForPose:pose.poseType];
    }
    //[myo vibrateWithType:MyoVibrationTypeShort];
}

@end
