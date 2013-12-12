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
@property (nonatomic, assign) float distance;

+ (CWLBeaconLandmark*)landmarkWithIdent:(NSString*)ident x:(float)x y:(float)y color:(UIColor*)color;

@end
