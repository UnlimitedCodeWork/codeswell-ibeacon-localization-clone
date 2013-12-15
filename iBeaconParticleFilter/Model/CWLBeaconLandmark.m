//
//  CWLBeaconLandmark.m
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import "CWLBeaconLandmark.h"

@interface CWLBeaconLandmark ()

// Set-once stuff
@property (nonatomic, strong) NSString* ident;
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, strong) UIColor* color;

// Calculated from rssi
@property (nonatomic, assign) float meanRssi;
@property (nonatomic, assign) float stdDeviationRssi;
@property (nonatomic, assign) float meters;
@property (nonatomic, assign) float meanMeters;
@property (nonatomic, assign) float meanMetersVariance;

// Ring-buffer for running average, Std Dev.
#define RSSIBUFFERSIZE 30
@property (nonatomic, assign) NSInteger* rssiBuffer;
@property (nonatomic, assign) NSInteger bufferIndex;
@property (nonatomic, assign) BOOL bufferFull;

@end


@implementation CWLBeaconLandmark

+ (CWLBeaconLandmark*)landmarkWithIdent:(NSString*)ident x:(float)x y:(float)y color:(UIColor*)color {
    CWLBeaconLandmark* ret = [[CWLBeaconLandmark alloc] init];
    ret.ident = ident;
    ret.x = x;
    ret.y = y;
    ret.color = color;
    
    ret.rssiBuffer = malloc(RSSIBUFFERSIZE*sizeof(NSInteger));
    
    return ret;
}

- (void)setRssi:(NSInteger)rssi {
    _rssi = rssi;

    // Ignore zeros in average, StdDev -- we clear the value before setting it to
    // prevent old values from hanging around if there's no reading
    if (rssi == 0) {
        self.meters = 0;
        return;
    }
    
    self.meters = [self metersFromRssi:rssi];
    
    NSInteger* pidx = self.rssiBuffer;
    *(pidx+self.bufferIndex++) = rssi;
    
    if (self.bufferIndex >= RSSIBUFFERSIZE) {
        self.bufferIndex %= RSSIBUFFERSIZE;
        self.bufferFull = YES;
    }
    
    if (self.bufferFull) {
        
        // Only calculate trailing mean and Std Dev when we have enough data
        float accumulator = 0;
        for (NSInteger i = 0; i < RSSIBUFFERSIZE; i++) {
            accumulator += *(pidx+i);
        }
        self.meanRssi = accumulator / RSSIBUFFERSIZE;
        self.meanMeters = [self metersFromRssi:self.meanRssi];
        
        accumulator = 0;
        for (NSInteger i = 0; i < RSSIBUFFERSIZE; i++) {
            NSInteger difference = *(pidx+i) - self.meanRssi;
            accumulator += difference*difference;
        }
        self.stdDeviationRssi = sqrtf( accumulator / RSSIBUFFERSIZE);
        self.meanMetersVariance = ABS(
                                      [self metersFromRssi:self.meanRssi]
                                      - [self metersFromRssi:self.meanRssi+self.stdDeviationRssi]
                                      );
    }
    
}


#pragma mark Helpers

+ (NSString*)identFromMajor:(NSInteger)major minor:(NSInteger)minor {
    return [NSString stringWithFormat:@"%ld-%ld", (long)major, (long)minor];
}

- (float)metersFromRssi:(NSInteger)rssi {
    
    // Based on measurement of Estimote beacons, power set at -8
    
    //    float ret = 8.6604 * logf(-rssi) + 72.971;
    float ret = 0.0003 * expf(0.1122*-rssi);
    
    return ret;
}




@end
