//
//  CWLParticleFilter.h
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CWLParticleFilter;


@protocol CWLParticleFilterDelegate <NSObject>

@required
- (id)newParticleForParticleFilter:(CWLParticleFilter*)filter;

@optional
- (void)particleFilter:(CWLParticleFilter*)filter particlesDidAdvance:(NSArray*)particles;

@end


@interface CWLParticleFilter : NSObject


@property (nonatomic, strong) id<CWLParticleFilterDelegate> delegate;
@property (nonatomic, readonly) NSArray* particles;

- (id)initWithSize:(CGSize)size landmarks:(NSArray*)landMarks particleCount:(NSUInteger)particleCount;
- (void)advance;

@end
