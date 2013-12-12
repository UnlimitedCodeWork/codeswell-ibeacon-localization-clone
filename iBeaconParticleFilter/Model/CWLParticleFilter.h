//
//  CWLParticleFilter.h
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLParticleBase.h"

@class CWLParticleFilter;


@protocol CWLParticleFilterDelegate <NSObject>

@required
- (CWLParticleBase*)newParticleForParticleFilter:(CWLParticleFilter*)filter;
- (void)particleFilter:(CWLParticleFilter*)filter moveParticle:(CWLParticleBase*)particle;
- (float)particleFilter:(CWLParticleFilter*)filter getLikelihood:(CWLParticleBase*)particle withMeasurements:(id)measurements;
- (CWLParticleBase*)particleFilter:(CWLParticleFilter*)filter particleWithNoiseFromParticle:(CWLParticleBase*)particle;

@optional
- (void)particleFilter:(CWLParticleFilter*)filter particlesDidAdvance:(NSArray*)particles;

@end


@interface CWLParticleFilter : NSObject


@property (nonatomic, strong) id<CWLParticleFilterDelegate> delegate;
@property (nonatomic, readonly) NSArray* particles;

- (id)initWithSize:(CGSize)size landmarks:(NSArray*)landMarks particleCount:(NSUInteger)particleCount;
- (void)move;
- (void)sense:(id)measurements;

@end
