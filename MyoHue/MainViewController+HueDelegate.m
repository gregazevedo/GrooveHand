//
//  MainViewController+HueDelegate.m
//  MyoHue
//
//  Created by Greg Azevedo on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MainViewController+HueDelegate.h"

@implementation MainViewController (HueDelegate)

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
        
        NSDictionary *lightDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        // Add to internal state
        NSNumber *dict = [[lightDict objectForKey:@"state"] objectForKey:@"on"];
        self.initialColor = [[lightDict objectForKey:@"state"] objectForKey:@"hue"];
        self.currentBrightness = [[lightDict objectForKey:@"state"] objectForKey:@"bri"];
        self.lightOn = [dict isEqualToNumber:@1] ? YES : NO;
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
    NSLog(@"strobe to %i", self.lightOn);
}

@end
