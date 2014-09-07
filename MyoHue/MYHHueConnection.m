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
        messageBody = [NSString stringWithFormat: @"{\"on\":false}"];
        self.lightOn = false;
    }else{
        messageBody = [NSString stringWithFormat: @"{\"on\":true}"];
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
    self.currentBrightness = [NSNumber numberWithInt:([self.currentBrightness intValue] + 3)];
    
    if ([self.currentBrightness intValue] < 0) {
        self.currentBrightness = @0;
    } else if ([self.currentBrightness intValue] >= 255) {
        self.currentBrightness = @255;
    }
    
    NSString *messageBody = [NSString stringWithFormat: @"{\"bri\":%@}", self.currentBrightness];
    [self updateHueWithMessageBody:messageBody];
}

-(void)decreaseBrightness{
    self.currentBrightness = [NSNumber numberWithInt:([self.currentBrightness intValue] - 3)];
    if ([self.currentBrightness intValue] <= 0) {
        self.currentBrightness = @0;
    } else if ([self.currentBrightness intValue] > 255) {
        self.currentBrightness = @255;
    }
    NSString *messageBody = [NSString stringWithFormat: @"{\"bri\":%@}", self.currentBrightness];
    [self updateHueWithMessageBody:messageBody];
}

-(void)adjustBrightnessWithRotation:(int)rotation
{
    BOOL shouldIncrease = rotation > 30;
    BOOL shouldDecrease = rotation < -30;
    if (shouldIncrease) {
        [self.brightnessDecreaseTimer invalidate];
        self.brightnessIncreaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(increaseBrightness) userInfo:nil repeats:NO];
        [self.brightnessIncreaseTimer fire];
    } else if (shouldDecrease) {
        [self.brightnessIncreaseTimer invalidate];
        self.brightnessDecreaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(decreaseBrightness) userInfo:nil repeats:NO];
        [self.brightnessDecreaseTimer fire];
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

-(void)retrieveInitialHueInfo
{
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.2/api/newdeveloper/lights/1"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    NSString *method = @"GET";
    [request setHTTPMethod:method];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSDictionary *lightDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"LIGHT INFO: %@", lightDict);
            NSNumber *dict = [[lightDict objectForKey:@"state"] objectForKey:@"on"];
            self.initialColor = [[lightDict objectForKey:@"state"] objectForKey:@"hue"];
            self.currentBrightness = [[lightDict objectForKey:@"state"] objectForKey:@"bri"];
            self.lightOn = [dict isEqualToNumber:@1] ? YES : NO;
        } else {
            self.initialColor = @0;
            self.currentBrightness = @0;
        }
    }];
}

-(void)updateHueWithMessageBody:(NSString *)messageBody {
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.2.2/api/newdeveloper/lights/1/state/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    
    NSData* bodyData = [messageBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
    NSString *method = @"PUT";
    NSLog(@"BODY DATA: %@", messageBody);
    [request setHTTPMethod:method];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    }];

    
//    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //    NSLog(@"strobe to %i", self.lightOn);
}

@end
