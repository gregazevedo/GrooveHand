//
//  MainViewController.m
//  MyoLights
//
//  Created by Alexander Athan on 9/6/14.
//  Copyright (c) 2014 Dolo. All rights reserved.
//

#import "MainViewController.h"
#include <cmath>
#include <iostream>

@interface MainViewController ()

@property (weak) IBOutlet NSButton *lightsButton;
@property (weak) IBOutlet NSButton *musicButton;
@property (nonatomic) BOOL lightOn;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) Myo *myMyo;
@property (nonatomic) NSMutableArray *hueColors;
@property (nonatomic) int index;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        //self.hueColors = [[NSArray alloc] initWithObjects:@2, @15000, @60000, nil];
        self.hueColors = [NSMutableArray new];
        [self createColors];
        self.index = 0;
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.2/api/newdeveloper/lights/3"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    NSString *method = @"GET";
    [request setHTTPMethod:method];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSDictionary *lightDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        // Add to internal state
        NSNumber *dict = [[lightDict objectForKey:@"state"] objectForKey:@"on"];
        self.lightOn = [dict isEqualToNumber:@1] ? YES : NO;
    }];
    NSLog(@"strobe to %i", self.lightOn);
    
    self.myMyo = [[Myo alloc] initWithApplicationIdentifier:@"com.example.myoobjc"];
    BOOL found = false;
    while (!found) {
        found = [self.myMyo connectMyoWaiting:10000];
    }
    self.myMyo.delegate = self;
    self.myMyo.updateTime = 1000;

}

- (IBAction)lightsButtonPushed:(id)sender {
    if([self.musicButton state] == 1){
        [self.musicButton setState:0];
    }
    
    if([self.lightsButton state] == 1){
          //self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(strobeLights) userInfo:nil repeats:YES];
        [self.myMyo startUpdate];

    }else{
        [self.timer invalidate];
    }
}

- (IBAction)musicButtonPushed:(id)sender {
    if([self.lightsButton state] == 1){
        [self.lightsButton setState:0];
        [self.timer invalidate];
    }
    
    if([self.musicButton state] == 1)
        NSLog(@"Pressed music");
}

-(void)strobeLights{
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
    NSLog(@"Myo on accelerometer data");
}
-(void)myo:(Myo *)myo onGyroscopeDataWithVector:(MyoVector*)vector
{
    NSLog(@"Myo on gyroscope data");
}
-(void)myo:(Myo *)myo onOrientationDataWithRoll:(int)roll pitch:(int)pitch yaw:(int)yaw
{
    // NSLog(@"Myo on orientation data");
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

-(void)createColors{
    //colors[0] = initialColor;
    [self.hueColors addObject:@2000];
    //std::cout << "initial " << initialColor << std::endl;
    for(int i = 1; i < 20; i++) {
        [self.hueColors addObject:[NSNumber numberWithInt:(rand() % 65535)]];
    }
}



@end
