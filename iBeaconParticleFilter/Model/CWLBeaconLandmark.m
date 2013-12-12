//
//  CWLBeaconLandmark.m
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import "CWLBeaconLandmark.h"

@implementation CWLBeaconLandmark

+ (CWLBeaconLandmark*)landmarkWithX:(float)x y:(float)y color:(UIColor*)color {
    CWLBeaconLandmark* ret = [[CWLBeaconLandmark alloc] init];
    ret.x = x;
    ret.y = y;
    ret.color = color;
    
    return ret;
}

@end
