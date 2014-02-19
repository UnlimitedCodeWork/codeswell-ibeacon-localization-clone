//
//  CWLBeaconLandmark.h
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWLBeaconLandmark : NSObject

@property (nonatomic, readonly) NSString* ident;
@property (nonatomic, readonly) float x;
@property (nonatomic, readonly) float y;
@property (nonatomic, readonly) UIColor* color;

@property (nonatomic, assign) NSInteger rssi;
// Trailing average and standard deviation of RSSI values
@property (nonatomic, readonly) float meanRssi;
@property (nonatomic, readonly) float stdDeviationRssi;
// Calculated range distances based on above
@property (nonatomic, readonly) float meters;
@property (nonatomic, readonly) float meanMeters;
@property (nonatomic, readonly) float meanMetersVariance;


+ (CWLBeaconLandmark*)landmarkWithIdent:(NSString*)ident x:(float)x y:(float)y color:(UIColor*)color;

// Helpers
+ (NSString*)identFromMajor:(NSInteger)major minor:(NSInteger)minor;

@end
