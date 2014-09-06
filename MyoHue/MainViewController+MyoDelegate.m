//
//  MainViewController+MyoDelegate.m
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MainViewController+MyoDelegate.h"

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
        NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.2/api/newdeveloper/lights/3/state/"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        
        NSString *jsonBody;
        if(self.lightOn){
            jsonBody = [NSString stringWithFormat: @"{\"on\":false, \"transitiontime\":1}"];
            self.lightOn = false;
        }else{
            jsonBody = [NSString stringWithFormat: @"{\"on\":true}"];
            self.lightOn = true;
        }
        
        NSData* bodyData = [jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
        NSString *method = @"PUT";
        
        [request setHTTPMethod:method];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:bodyData];
        
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSLog(@"strobe to %i", self.lightOn);
    }
    
    if (pose.poseType == MyoPoseTypeWaveOut) {
        if(self.index == 19)
            self.index = 0;
        else
            self.index++;
        
        NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.2/api/newdeveloper/lights/3/state/"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        
        NSString *jsonBody = [NSString stringWithFormat: @"{\"hue\":%@}", [self.hueColors objectAtIndex:self.index]];
        
        NSData* bodyData = [jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
        NSString *method = @"PUT";
        
        [request setHTTPMethod:method];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:bodyData];
        
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
    }
    
    if (pose.poseType == MyoPoseTypeWaveIn){
        if(self.index == 0)
            self.index = 19;
        else
            self.index--;
        NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.2/api/newdeveloper/lights/3/state/"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        
        NSString *jsonBody = [NSString stringWithFormat: @"{\"hue\":%@}", [self.hueColors objectAtIndex:self.index]];
        
        NSData* bodyData = [jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
        NSString *method = @"PUT";
        
        [request setHTTPMethod:method];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:bodyData];
        
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }
    //[myo vibrateWithType:MyoVibrationTypeShort];
}

@end
