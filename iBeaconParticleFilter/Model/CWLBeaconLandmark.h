//
//  CWLBeaconLandmark.h
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWLBeaconLandmark : NSObject

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, strong) UIColor* color;

+ (CWLBeaconLandmark*)landmarkWithX:(float)x y:(float)y color:(UIColor*)color;

@end
