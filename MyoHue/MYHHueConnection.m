//
//  MYHHueConnection.m
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MYHHueConnection.h"

@implementation MYHHueConnection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.index = 0;
        self.isPartyMode = false;
    }
    return self;
}

-(void)toggleLightOn
{
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

-(void)togglePartyMode
{
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

-(void)updateToNextHue
{
    if(self.index == 19)
        self.index = 0;
    else
        self.index++;
    
    NSString *messageBody = [NSString stringWithFormat: @"{\"hue\":%@}", [self.hueColors objectAtIndex:self.index]];
    [self updateHueWithMessageBody:messageBody];
}

-(void)updateToPreviousHue
{
    if(self.index == 0)
        self.index = 19;
    else
        self.index--;
    
    NSString *messageBody = [NSString stringWithFormat: @"{\"hue\":%@}", [self.hueColors objectAtIndex:self.index]];
    [self updateHueWithMessageBody:messageBody];
}

-(void)increaseBrightness
{
    self.currentBrightness = [NSNumber numberWithInt:([self.currentBrightness intValue] + 25)];
    if ([self.currentBrightness intValue] < 0) {
        self.currentBrightness = @0;
    } else if ([self.currentBrightness intValue] > 255) {
        self.currentBrightness = @255;
    }
    NSString *messageBody = [NSString stringWithFormat: @"{\"bri\":%@}", self.currentBrightness];
    [self updateHueWithMessageBody:messageBody];
}

-(void)decreaseBrightness
{
    self.currentBrightness = [NSNumber numberWithInt:([self.currentBrightness intValue] - 25)];
    if ([self.currentBrightness intValue] < 0) {
        self.currentBrightness = @0;
    } else if ([self.currentBrightness intValue] > 255) {
        self.currentBrightness = @255;
    }
    NSString *messageBody = [NSString stringWithFormat: @"{\"bri\":%@}", self.currentBrightness];
    [self updateHueWithMessageBody:messageBody];
}

-(void)adjustBrightnessWithRotation:(int)rotation
{
    BOOL isIncreasingBrightness = (BOOL)self.brightnessIncreaseTimer;
    BOOL isDecreasingBrightness = (BOOL)self.brightnessDecreaseTimer;
    BOOL shouldIncrease = rotation > 0;
    BOOL shouldDecrease = rotation < 0;
    
    if (shouldIncrease && !isIncreasingBrightness) {
        self.brightnessIncreaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(increaseBrightness) userInfo:nil repeats:YES];
        self.brightnessDecreaseTimer = nil;
    } else if (shouldDecrease && !isDecreasingBrightness) {
        self.brightnessDecreaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(decreaseBrightness) userInfo:nil repeats:YES];
        self.brightnessIncreaseTimer = nil;
    }
}

-(void)createColors {
    self.hueColors = [NSMutableArray array];
    NSNumber *firstColor = self.initialColor ? self.initialColor : @0; //0 is red
    [self.hueColors addObject:firstColor];
    for(int i = 1; i < 20; i++) {
        [self.hueColors addObject:[NSNumber numberWithInt:(rand() % 65535)]];
    }
}

-(void)retrieveInitialHueInfo {
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.2/api/newdeveloper/lights/3"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    NSString *method = @"GET";
    [request setHTTPMethod:method];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data) {
            NSDictionary *lightDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSNumber *dict = [[lightDict objectForKey:@"state"] objectForKey:@"on"];
            self.initialColor = [[lightDict objectForKey:@"state"] objectForKey:@"hue"];
            self.currentBrightness = [[lightDict objectForKey:@"state"] objectForKey:@"bri"];
            self.lightOn = [dict isEqualToNumber:@1] ? YES : NO;
        } else {
            NSLog(@"error no response for inital light state");
            self.initialColor = @0;
            self.currentBrightness = @0;
        }
    }];
}

-(void)updateHueWithMessageBody:(NSString *)messageBody {
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.2/api/newdeveloper/lights/3/state/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    
    NSData* bodyData = [messageBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
    NSString *method = @"PUT";
    
    [request setHTTPMethod:method];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //    NSLog(@"strobe to %i", self.lightOn);
}

@end
