//
//  MyoStuff.m
//  MyoHue
//
//  Created by Alexander Athan on 9/6/14.
//  Copyright (c) 2014 Gregory Azevedo. All rights reserved.
//

#import "MyoStuff.h"
#import <myo/myo.hpp>

@class Myo;

class DataCollector : public myo::DeviceListener {
public:
    DataCollector()
    : onArm(false), roll_w(0), pitch_w(0), yaw_w(0), currentPose(), initalRoll(0), currentRoll(0)
    {
    }
    void onOrientationData(myo::Myo* myo, uint64_t timestamp, const myo::Quaternion<float>& quat)
    {
        using std::atan2;
        using std::asin;
        using std::sqrt;
        
        // Calculate Euler angles (roll, pitch, and yaw) from the unit quaternion.
        float roll = atan2(2.0f * (quat.w() * quat.x() + quat.y() * quat.z()),
                           1.0f - 2.0f * (quat.x() * quat.x() + quat.y() * quat.y()));
        float pitch = asin(2.0f * (quat.w() * quat.y() - quat.z() * quat.x()));
        float yaw = atan2(2.0f * (quat.w() * quat.z() + quat.x() * quat.y()),
                          1.0f - 2.0f * (quat.y() * quat.y() + quat.z() * quat.z()));
        
        if (initalRoll) {
            currentRoll = initalRoll - roll*100;
        } else {
            initalRoll = roll*100;
            currentRoll = initalRoll;
        }
//        std::cout << " roll " << adjustedRoll << '\n';

        // Convert the floating point angles in radians to a scale from 0 to 20.
        roll_w = static_cast<int>((roll + (float)M_PI)/(M_PI * 2.0f) * 18);
        pitch_w = static_cast<int>((pitch + (float)M_PI/2.0f)/M_PI * 18);
        yaw_w = static_cast<int>((yaw + (float)M_PI)/(M_PI * 2.0f) * 18);
        
        if ([_myo.delegate respondsToSelector:@selector(myo:onOrientationDataWithRoll:pitch:yaw:)]) {
            [_myo.delegate myo:_myo onOrientationDataWithRoll:currentRoll pitch:pitch_w yaw:yaw_w];
        }
    }
    
    void onAccelerometerData(myo::Myo* myo, uint64_t timestamp, const myo::Vector3<float>& accel)
    {
        MyoVector *vector = [[MyoVector alloc] initWithX:accel.x() y:accel.y() z:accel.z() orientation:usbOrientation];
        if ([_myo.delegate respondsToSelector:@selector(myo:onAccelerometerDataWithVector:)]) {
            [_myo.delegate myo:_myo onAccelerometerDataWithVector:vector];
        }
    }
    
    /// Called when a paired Myo has provided new gyroscope data in units of deg/s.
    void onGyroscopeData(myo::Myo* myo, uint64_t timestamp, const myo::Vector3<float>& gyro)
    {
        MyoVector *vector = [[MyoVector alloc] initWithX:gyro.x() y:gyro.y() z:gyro.z() orientation:usbOrientation];
        if ([_myo.delegate respondsToSelector:@selector(myo:onGyroscopeDataWithVector:)]) {
            [_myo.delegate myo:_myo onGyroscopeDataWithVector:vector];
        }
    }
    
    /// Called when a paired Myo has provided a new RSSI value.
    /// @see Myo::requestRssi() to request an RSSI value from the Myo.
    void onRssi(Myo* myo, uint64_t timestamp, int8_t rssi)
    {
        if ([_myo.delegate respondsToSelector:@selector(myo:onRssi:)]) {
            [_myo.delegate myo:_myo onRssi:rssi];
        }
    }
    
    void onPose(myo::Myo* myo, uint64_t timestamp, myo::Pose pose)
    {
        currentPose = pose;
        //        print();
        MyoPose *myopose = [MyoPose new];
        if (pose.type() == myo::Pose::fist)
            myopose.poseType = MyoPoseTypeFist;
        if (pose.type() == myo::Pose::fingersSpread)
            myopose.poseType = MyoPoseTypeFingersSpread;
        if (pose.type() == myo::Pose::waveIn)
            myopose.poseType = MyoPoseTypeWaveIn;
        if (pose.type() == myo::Pose::waveOut)
            myopose.poseType = MyoPoseTypeWaveOut;
        if (pose.type() == myo::Pose::thumbToPinky)
            myopose.poseType = MyoPoseTypeThumbToPinky;
        if ([_myo.delegate respondsToSelector:@selector(myo:onPose:)]) {
            [_myo.delegate myo:_myo onPose:myopose];
        }
    }
    void onArmRecognized(myo::Myo* myo, uint64_t timestamp, myo::Arm arm, myo::XDirection xDirection)
    {
        onArm = true;
        whichArm = arm;
        usbOrientation = xDirection;
        if ([_myo.delegate respondsToSelector:@selector(myoOnArmRecognized:)]) {
            [_myo.delegate myoOnArmRecognized:_myo];
        }
    }
    void onArmLost(myo::Myo* myo, uint64_t timestamp)
    {
        onArm = false;
        if ([_myo.delegate respondsToSelector:@selector(myoOnArmLost:)]) {
            [_myo.delegate myoOnArmLost:_myo];
        }
    }
    
    void onPair(Myo* myo, uint64_t timestamp, myo::FirmwareVersion firmwareVersion)
    {
        if ([_myo.delegate respondsToSelector:@selector(myoOnPair:)]) {
            [_myo.delegate myoOnPair:_myo];
        }
    }
    
    /// Called when a paired Myo has been connected.
    void onConnect(Myo* myo, uint64_t timestamp, myo::FirmwareVersion firmwareVersion)
    {
        if ([_myo.delegate respondsToSelector:@selector(myoOnConnect:)]) {
            [_myo.delegate myoOnConnect:_myo];
        }
    }
    
    /// Called when a paired Myo has been disconnected.
    void onDisconnect(Myo* myo, uint64_t timestamp)
    {
        if ([_myo.delegate respondsToSelector:@selector(myoOnDisconnect:)]) {
            [_myo.delegate myoOnDisconnect:_myo];
        }
    }
    
    
    void print()
    {
        // Clear the current line
        std::cout << '\r';
        std::cout << '[' << std::string(roll_w, '*') << std::string(18 - roll_w, ' ') << ']'
        << '[' << std::string(pitch_w, '*') << std::string(18 - pitch_w, ' ') << ']'
        << '[' << std::string(yaw_w, '*') << std::string(18 - yaw_w, ' ') << ']';
        
        if (onArm) {
            std::string poseString = currentPose.toString();
            
            std::cout << '[' << (whichArm == myo::armLeft ? "L" : "R") << ']'
            << '[' << poseString << std::string(14 - poseString.size(), ' ') << ']';
        } else {
            std::cout << "[?]" << '[' << std::string(14, ' ') << ']';
        }
        
        std::cout << std::flush;
    }
    
    // These values are set by onArmRecognized() and onArmLost() above.
    bool onArm;
    myo::Arm whichArm;
    myo::XDirection usbOrientation;
    // These values are set by onOrientationData() and onPose() above.
    int roll_w, pitch_w, yaw_w;
    int initalRoll;
    int currentRoll;
    myo::Pose currentPose;
    Myo *_myo;
};

#define DEFAULT_UPDATE_TIME 100
#pragma mark - MYOPOSE
@implementation MyoPose

@end

#pragma mark - MYOVECTOR
@implementation MyoVector

-(id)init
{
    return [self initWithX:0 y:0 z:0 orientation:YES];
}

- (instancetype)initWithX:(float)x y:(float)y z:(float)z orientation:(BOOL)usbTowardsWrist
{
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.z = z;
        self.usbTowardsWrist = usbTowardsWrist;
    }
    return self;
}

-(float)magnitude
{
    return std::sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
}

-(float)productWithVector:(MyoVector*)rhs
{
    return self.x * self.x + self.y * self.y + self.z * self.z;
}

-(MyoVector*)normalized
{
    float norm = self.magnitude;
    return [[MyoVector alloc] initWithX:(self.x / norm) y:(self.y / norm) z:(self.z / norm) orientation:self.usbTowardsWrist];
}

-(MyoVector*)crossProductWithVector:(MyoVector*)rhs
{
    float x = self.x * rhs.y - self.y * rhs.x;
    float y = self.y * rhs.z - self.z * rhs.y;
    float z = self.z * rhs.x - self.x * rhs.z;
    return [[MyoVector alloc] initWithX:x y:y z:z orientation:rhs.usbTowardsWrist];
}

-(float)angleWithVector:(MyoVector *)rhs
{
    return std::acos([self productWithVector:rhs] / (self.magnitude * rhs.magnitude));
}

@end


#pragma mark - MYO

@implementation Myo {
    myo::Hub hub;
    myo::Myo* myo;
    DataCollector collector;
    BOOL update;
}

- (instancetype)initWithApplicationIdentifier:(NSString*)identifier
{
    self = [super init];
    if (self) {
        myo::Hub hub([identifier UTF8String]);
        self.updateTime = DEFAULT_UPDATE_TIME;
    }
    return self;
}

-(BOOL)connectMyoWaiting:(int)milliseconds
{
    myo = hub.waitForMyo(milliseconds);
    
    if (!myo) {
        return false;
    }
    std::cout << "Connected to a Myo armband!" << std::endl << std::endl;
    collector._myo = self;
    hub.addListener(&collector);
    return true;
}

-(void)startUpdate
{
    update = true;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        while (update) {
            hub.run(_updateTime);
            collector.print();
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            NSLog(@"run ui updates");
        });
    });
}
-(void)stopUpdate {
    update = false;
}

-(void)vibrateWithType:(MyoVibrationType)type {
    
    switch (type) {
        case MyoVibrationTypeShort:
            myo->vibrate(myo::Myo::vibrationShort);
            break;
        case MyoVibrationTypeLong:
            myo->vibrate(myo::Myo::vibrationLong);
            break;
        default:
            myo->vibrate(myo::Myo::vibrationMedium);
            break;
    }
}

@end
