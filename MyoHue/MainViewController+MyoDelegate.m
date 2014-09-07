//
//  MainViewController+MyoDelegate.m
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MainViewController+MyoDelegate.h"
#import "MainViewController+HueDelegate.h"

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

    if (self.state == MYHStateAdjustingBrightness) {
        int fistedRollChange = roll-self.latestNoFistRoll;
        [self adjustBrightnessWithRotation:fistedRollChange];
    }
    else {
        self.latestNoFistRoll = roll;
    }
}

-(void)myo:(Myo *)myo onRssi:(int8_t)rssi
{
    NSLog(@"Myo on rssi");
}

-(void)myo:(Myo *)myo onPose:(MyoPose *)pose
{
    self.state = MYHStateDefault;
    NSLog(@"Current Pose: %@", pose);
    switch (pose.poseType) {
        case MyoPoseTypeRest:
            break;
        case MyoPoseTypeFingersSpread:
            [self toggleLightOn];
            break;
        case MyoPoseTypeWaveOut:
            [self updateToNextHue];
            break;
        case MyoPoseTypeWaveIn:
            [self updateToPreviousHue];
            break;
        case MyoPoseTypeFist:
            self.state = MYHStateAdjustingBrightness;
            break;
        case MyoPoseTypeThumbToPinky:
            [self togglePartyMode];
            break;
    }
    
    
    //[myo vibrateWithType:MyoVibrationTypeShort];
}

@end
