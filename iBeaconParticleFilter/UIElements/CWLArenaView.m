//
//  CWLArenaView.m
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import "CWLArenaView.h"

@interface CWLArenaView ()

@property (nonatomic, assign) BOOL isInitialized;

@property (nonatomic, assign) CGFloat particleRadius;
@property (nonatomic, assign) CGColorRef particleColor;

@property (nonatomic, assign) CGFloat landmarkRadius;
@property (nonatomic, assign) CGFloat activeRingLineWidth;
@property (nonatomic, assign) CGColorRef activeRingLineColor;

@property (nonatomic, assign) CGFloat currentDistanceArcLineWidth;

@property (nonatomic, assign) CGColorRef meanDistanceVarianceRingLineColor;

@end



@implementation CWLArenaView


- (void)initialize {
    self.particleRadius = 1.0;
    self.particleColor = [UIColor redColor].CGColor;
    
    self.landmarkRadius = 5.0;
    self.activeRingLineWidth = 2.0;
    self.activeRingLineColor = [UIColor redColor].CGColor;
    
    self.currentDistanceArcLineWidth = 3.0;
    
    self.meanDistanceVarianceRingLineColor = [UIColor lightGrayColor].CGColor;
    
    self.isInitialized = YES;
}


- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"[%@] Redrawing.", self.class);
    
    if (!self.isInitialized) {
        [self initialize];
    }

    CGContextRef context = UIGraphicsGetCurrentContext();

    
    // Draw variance arcs, if needed
    for (CWLBeaconLandmark* landmark in self.landmarks) {
        if (landmark.meanRssi < -1) {
            CGFloat x = landmark.x * self.pxPerMeter;
            CGFloat y = landmark.y * self.pxPerMeter;
            CGRect rect = [self rectForCircleX:x y:y radius:landmark.meanMeters * self.pxPerMeter];
            
            CGContextSetLineDash(context, 0.0, NULL, 0);
            float varianceFactor = 2.0; // 2 (one sigma on each side) = 66% likely
            //float varianceFactor = 4.0; // 4 (two sigma on each side) = 95% likely
            //float varianceFactor = 6.0; // 6 (three sigma on each side) = 99.7% likely
            CGContextSetLineWidth(context, landmark.meanMetersVariance * varianceFactor * self.pxPerMeter);
            CGContextSetStrokeColorWithColor(context, self.meanDistanceVarianceRingLineColor);
            CGContextStrokeEllipseInRect(context, rect);
        }
    }
    
    // Draw mean arcs, if needed
    for (CWLBeaconLandmark* landmark in self.landmarks) {
        if (landmark.rssi < -1) {
            CGFloat x = landmark.x * self.pxPerMeter;
            CGFloat y = landmark.y * self.pxPerMeter;
            CGRect rect = [self rectForCircleX:x y:y radius:landmark.meanMeters * self.pxPerMeter];
            
            CGContextSetLineWidth(context, 1.0);
            CGContextSetStrokeColorWithColor(context, landmark.color.CGColor);
            CGContextStrokeEllipseInRect(context, rect);
        }
    }
    
        
    // Draw current measurement arc
    for (CWLBeaconLandmark* landmark in self.landmarks) {
        if (landmark.rssi < -1) {
            CGFloat x = landmark.x * self.pxPerMeter;
            CGFloat y = landmark.y * self.pxPerMeter;
            rect = [self rectForCircleX:x y:y radius:landmark.meters * self.pxPerMeter];
            
            const CGFloat dashLengths[] = {10, 10};
            CGContextSetLineDash(context, 0.0, dashLengths, 2);
            CGContextSetLineWidth(context, self.currentDistanceArcLineWidth);
            CGContextSetStrokeColorWithColor(context, landmark.color.CGColor);
            CGContextStrokeEllipseInRect(context, rect);
        }
    }
    
    
    // Draw landmarks and active rings
    for (CWLBeaconLandmark* landmark in self.landmarks) {
        
        // Draw landmark
        CGFloat x = landmark.x * self.pxPerMeter;
        CGFloat y = landmark.y * self.pxPerMeter;
        CGRect rect = [self rectForCircleX:x y:y radius:self.landmarkRadius];
        CGContextSetFillColorWithColor(context, landmark.color.CGColor);
        CGContextFillEllipseInRect (context, rect);
        
        // Draw active ring, if there's a current measurement
        if (landmark.rssi < -1) {
            CGRect rect = [self rectForCircleX:x y:y radius:self.landmarkRadius + self.activeRingLineWidth];
            CGContextSetLineDash(context, 0.0, NULL, 0);
            CGContextSetLineWidth(context, self.activeRingLineWidth);
            CGContextSetStrokeColorWithColor(context, self.activeRingLineColor);
            CGContextStrokeEllipseInRect(context, rect);
        }
    }

    
    // Draw particles
    CGContextSetFillColorWithColor(context, self.particleColor);
    
    for (CWLPointParticle* particle in self.particles) {
        CGRect rect = [self rectForCircleX:particle.x * self.pxPerMeter y:particle.y * self.pxPerMeter
                                    radius:self.particleRadius];
        CGContextFillEllipseInRect (context, rect);
    }
    
    
    CGContextFillPath(context);
    
}

- (CGRect)rectForCircleX:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius {
    
    return CGRectMake(
                      x - radius,
                      y - radius,
                      radius * 2.0,
                      radius * 2.0
                      );
}


@end
