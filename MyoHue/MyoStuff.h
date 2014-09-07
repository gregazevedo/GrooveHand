//
//  MyoStuff.h
//  MyoHue
//
//  Created by Alexander Athan on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Myo;

#pragma mark - MYO POSE
typedef enum MyoPoseType {
    MyoPoseTypeRest,
    MyoPoseTypeFist,
    MyoPoseTypeFingersSpread,
    MyoPoseTypeWaveIn,
    MyoPoseTypeWaveOut,
    MyoPoseTypeReserved,
    MyoPoseTypeThumbToPinky
} MyoPoseType;

@interface MyoPose : NSObject

@property (nonatomic)MyoPoseType poseType;

@end


@interface MyoVector : NSObject
//{
//    float _data[4];
//}
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;
@property (nonatomic) BOOL usbTowardsWrist;
@property (nonatomic, readonly) float magnitude;

-(id)init;
-(id)initWithX:(float)x y:(float)y z:(float)z orientation:(BOOL)usbTowardsWrist;
-(float)x;
-(float)y;
-(float)z;
-(BOOL)usbTowardsWrist;
-(float)magnitude;
-(float)productWithVector:(MyoVector*)rhs;
-(MyoVector*)normalized;
-(MyoVector*)crossProductWithVector:(MyoVector*)rhs;
-(float)angleWithVector:(MyoVector *)rhs;

@end


#pragma mark - MYO DELEGATE

@protocol MyoDelegate <NSObject>

@optional

-(void)myoOnArmLost:(Myo*)myo;
-(void)myoOnArmRecognized:(Myo*)myo;
-(void)myoOnPair:(Myo*)myo;
-(void)myoOnConnect:(Myo*)myo;
-(void)myoOnDisconnect:(Myo*)myo;
-(void)myo:(Myo*)myo onPose:(MyoPose *)pose;
-(void)myo:(Myo*)myo onOrientationDataWithRoll:(int)roll pitch:(int)pitch yaw:(int)yaw;
-(void)myo:(Myo*)myo onAccelerometerDataWithVector:(MyoVector*)vector;
-(void)myo:(Myo*)myo onGyroscopeDataWithVector:(MyoVector*)vector;
-(void)myo:(Myo*)myo onRssi:(int8_t)rssi;

@end


#pragma mark - MyoVibrationType
typedef enum MyoVibrationType {
    MyoVibrationTypeShort = 0,
    MyoVibrationTypeMedium = 1,
    MyoVibrationTypeLong = 2
} MyoVibrationType;

#pragma mark - MYO
@interface Myo : NSObject

- (instancetype)initWithApplicationIdentifier:(NSString*)identifier;
-(BOOL)connectMyoWaiting:(int)milliseconds;
-(void)startUpdate;
-(void)stopUpdate;
-(void)vibrateWithType:(MyoVibrationType)type;

@property (nonatomic) int updateTime;
@property (nonatomic, assign) id <MyoDelegate> delegate;

@end
