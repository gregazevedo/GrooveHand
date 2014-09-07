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
    NSLog(@"accelerometer x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
}
-(void)myo:(Myo *)myo onGyroscopeDataWithVector:(MyoVector*)vector
{
    NSLog(@"gyroscope x %f y %f z %f mag %f", vector.x, vector.y, vector.z, vector.magnitude);
}
-(void)myo:(Myo *)myo onOrientationDataWithRoll:(int)roll pitch:(int)pitch yaw:(int)yaw
{
    NSLog(@"orientation roll %i pitch %i yaw %i", roll, pitch, yaw);
}
-(void)myo:(Myo *)myo onRssi:(int8_t)rssi
{
    NSLog(@"Myo on rssi");
}
-(void)myo:(Myo *)myo onPose:(MyoPose *)pose
{
    NSLog(@"posed : %u",pose.poseType);
    if (pose.poseType == MyoPoseTypeFingersSpread){
        NSString *messageBody;
        if(self.lightOn){
            messageBody = [NSString stringWithFormat: @"{\"on\":false, \"transitiontime\":1}"];
            self.lightOn = false;
        }else{
            messageBody = [NSString stringWithFormat: @"{\"on\":true, \"transitiontime\":1}"];
            self.lightOn = true;
        }
        [self updateHueWithMessageBody:messageBody];
    }
    
    if (pose.poseType == MyoPoseTypeWaveOut) {
        if(self.index == 19)
            self.index = 0;
        else
            self.index++;
        
        NSString *messageBody = [NSString stringWithFormat: @"{\"hue\":%@}", [self.hueColors objectAtIndex:self.index]];
        [self updateHueWithMessageBody:messageBody];
    }
    
    if (pose.poseType == MyoPoseTypeWaveIn){
        if(self.index == 0)
            self.index = 19;
        else
            self.index--;
        
        NSString *messageBody = [NSString stringWithFormat: @"{\"hue\":%@}", [self.hueColors objectAtIndex:self.index]];
        [self updateHueWithMessageBody:messageBody];
    }
    
    if (pose.poseType == MyoPoseTypeThumbToPinky) {
        if(self.isPartyMode) {
            NSString *messageBody = [NSString stringWithFormat: @"{\"effect\":\"none\"}"];
            [self updateHueWithMessageBody:messageBody];
            self.isPartyMode = false;
        } else {
            NSString *messageBody = [NSString stringWithFormat: @"{\"effect\":\"colorloop\"}"];
            [self updateHueWithMessageBody:messageBody];
            self.isPartyMode = true;
        }
    }
    
    //[myo vibrateWithType:MyoVibrationTypeShort];
}

@end
