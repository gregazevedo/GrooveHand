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
@property (nonatomic) NSTimer *timer;
@property (nonatomic) Myo *myMyo;
//@property (nonatomic) NSMutableArray *hueColors;
//@property (nonatomic) int index;
@property (nonatomic) NSNumber *initialColor;

@end


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.index = 0;
        self.isPartyMode = false;
    }
    return self;
}

-(void)awakeFromNib {
    
    [super awakeFromNib];
    [self retrieveInitialHueInfo];
    [self createColors];
    
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


-(void)retrieveInitialHueInfo{
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
        NSNumber *initialColor = [[lightDict objectForKey:@"state"] objectForKey:@"hue"];
        self.lightOn = [dict isEqualToNumber:@1] ? YES : NO;
        self.initialColor = initialColor;
    }];

}

-(void)createColors {
    self.hueColors = [NSMutableArray array];
    NSNumber *firstColor = self.initialColor ? self.initialColor : @0; //0 is red
    [self.hueColors addObject:firstColor];
    for(int i = 1; i < 20; i++) {
        [self.hueColors addObject:[NSNumber numberWithInt:(rand() % 65535)]];
    }
}

@end
