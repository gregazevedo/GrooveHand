//
//  MainViewController.m
//  MyoLights
//
//  Created by Alexander Athan on 9/6/14.
//  Copyright (c) 2014 Dolo. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (weak) IBOutlet NSButton *lightsButton;
@property (weak) IBOutlet NSButton *musicButton;
@property (nonatomic) BOOL lightOn;
@property (nonatomic) NSTimer *timer;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.

        
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

}

- (IBAction)lightsButtonPushed:(id)sender {
    if([self.musicButton state] == 1){
        [self.musicButton setState:0];
    }
    
    if([self.lightsButton state] == 1){
          self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(strobeLights) userInfo:nil repeats:YES];
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

@end
