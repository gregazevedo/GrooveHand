//
//  MainViewController+MyoDelegate.m
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MainViewController+MyoDelegate.h"
#import "MYHHueConnection.h"

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
    NSLog(@"orientation roll %i pitch %i yaw %i", roll, pitch, yaw);

//    int fistedRollChange = self.latestNoFistRoll - roll;
//    [self.lights adjustBrightnessWithRotation:fistedRollChange];

//    if (self.state == MYHStateAdjustingBrightness) {
//        NSLog(@"adjusting brightness to %i", fistedRollChange);
//    }
//    else {
//        self.latestNoFistRoll = roll;
////        self.currentBrightness = [NSNumber numberWithInt:roll];
//    }
}

-(void)myo:(Myo *)myo onRssi:(int8_t)rssi
{
    NSLog(@"Myo on rssi");
}

-(void)myo:(Myo *)myo onPose:(MyoPose *)pose
{
//    self.state = MYHStateDefault;
    
    switch (pose.poseType) {
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
//            self.state = MYHStateAdjustingBrightness;
            
            break;
        case MyoPoseTypeThumbToPinky:
            [self.lights togglePartyMode];
            break;
        case MyoPoseTypeReserved:
            break;
    }
    
    
    //[myo vibrateWithType:MyoVibrationTypeShort];
}

@end
