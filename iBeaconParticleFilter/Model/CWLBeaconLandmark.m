//
//  CWLBeaconLandmark.m
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import "CWLBeaconLandmark.h"

@interface CWLBeaconLandmark ()

@property (nonatomic, strong) NSString* ident;
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, strong) UIColor* color;

@end


@implementation CWLBeaconLandmark

+ (CWLBeaconLandmark*)landmarkWithIdent:(NSString*)ident x:(float)x y:(float)y color:(UIColor*)color {
    CWLBeaconLandmark* ret = [[CWLBeaconLandmark alloc] init];
    ret.ident = ident;
    ret.x = x;
    ret.y = y;
    ret.color = color;
    
    return ret;
}

@end
