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

@interface CWLParticleBase ()
@property (nonatomic, assign) float weight;
@end



@implementation CWLParticleFilter


- (id)initWithSize:(CGSize)size landmarks:(NSArray*)landMarks particleCount:(NSUInteger)particleCount {
    self = [super init];
    if (self) {
        _particleCount = particleCount;
        DDLogInfo(@"[%@] Instantiated.", self.class);
    }
    return self;
}

- (void)move {
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
    for (id particle in self.particles) {
        [self.delegate particleFilter:self moveParticle:particle];
    }
    
    DDLogVerbose(@"[%@] Particles moved.", self.class);
}
    
- (void)sense:(id)measurements {
    
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
    
    // Determine likelihoods
    float totalLikelihood = 0.0;
    for (CWLParticleBase* particle in self.particles) {
        particle.weight = [self.delegate particleFilter:self getLikelihood:particle withMeasurements:measurements];
        totalLikelihood += particle.weight;
    }


    // Normalize likelihoods and sort
    [self.particles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CWLParticleBase* particle = obj;
        particle.weight /= totalLikelihood;
    }];
    NSArray* sortedParticles = [self.particles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CWLParticleBase* particle1 = obj1;
        CWLParticleBase* particle2 = obj2;
        
        if (particle1.weight == particle2.weight)
            return NSOrderedSame;
        else if (particle1.weight < particle2.weight)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    
    // Create new generation of particles and replace old ones
    NSMutableArray* newParticles = [[NSMutableArray alloc] initWithCapacity:self.particleCount];
    for (NSUInteger i = 0; i < self.particleCount; i++) {
        CWLParticleBase* particle = [self randomWeightedParticle:sortedParticles];
        newParticles[i] = [self.delegate particleFilter:self particleWithNoiseFromParticle:particle];
    }
    self.particles = newParticles;
    
    // Notify delegate we're done
    [self.delegate particleFilter:self particlesDidAdvance:self.particles];
    DDLogVerbose(@"[%@] Particles advanced.", self.class);
}


#pragma mark Helpers

- (void)initializeParticles {
    DDLogInfo(@"[%@] Initializing %ld particles.", self.class, (long)self.particleCount);
    
    NSMutableArray* tmpParticles = [[NSMutableArray alloc] initWithCapacity:self.particleCount];
    for (NSUInteger i = 0; i < self.particleCount; i++) {
        tmpParticles[i] = [self.delegate newParticleForParticleFilter:self];
    }
    
    self.particles = tmpParticles;
}


// REVIEW: sampling could be improved thus: http://stackoverflow.com/a/4511616/46731
- (CWLParticleBase*)randomWeightedParticle:(NSArray*)sortedParticles {
    float accumulatedWeight = 0.0;
    float targetWeight = (float)drand48();
    
    for (CWLParticleBase* particle in sortedParticles){
        accumulatedWeight += particle.weight;
        if (accumulatedWeight >= targetWeight) {
            return particle;
        }
    }
    
    DDLogWarn(@"[%@] randomWeightedParticle ran past end of array.", self.class);
    return sortedParticles.lastObject;
}


@end
