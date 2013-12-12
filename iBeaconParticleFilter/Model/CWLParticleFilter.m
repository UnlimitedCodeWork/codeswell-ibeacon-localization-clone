//
//  CWLParticleFilter.m
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import "CWLParticleFilter.h"


@interface CWLParticleFilter ()

@property (nonatomic, assign) NSUInteger particleCount;
@property (nonatomic, strong) NSArray* particles;

@end


@implementation CWLParticleFilter


- (id)initWithSize:(CGSize)size landmarks:(NSArray*)landMarks particleCount:(NSUInteger)particleCount {
    self = [super init];
    if (self) {
        self.particleCount = particleCount;
        DDLogInfo(@"[%@] Instantiated.", self.class);
    }
    return self;
}

- (void)advance {
    
    // Initialize particles if need be
    if (self.particles == nil) {
        if (self.delegate) {
            [self initializeParticles];
            [self.delegate particleFilter:self particlesDidAdvance:self.particles];
        } else {
            // We can't do anything without a delegate
            return;
        }
    }
    
    // Apply motion and noise
    
    // Determine likelihood
    
    // Normalize likelihoods and sort
    
    // Create new generation of particles and replace old ones
    
    // Notify delegate
    [self.delegate particleFilter:self particlesDidAdvance:self.particles];
    DDLogInfo(@"[%@] Particles advanced.", self.class);
}


#pragma mark Helpers

- (void)initializeParticles {
    DDLogInfo(@"[%@] Initializing %d particles.", self.class, self.particleCount);
    
    NSMutableArray* tmpParticles = [[NSMutableArray alloc] initWithCapacity:self.particleCount];
    for (NSUInteger i = 0; i < self.particleCount; i++) {
        tmpParticles[i] = [self.delegate newParticleForParticleFilter:self];
    }
    
    self.particles = tmpParticles;
}


@end
