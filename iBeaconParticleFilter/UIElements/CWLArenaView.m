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
@property (nonatomic, assign) CGFloat landmarkRadius;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign) CGColorRef strokeColor;
@property (nonatomic, assign) CGColorRef fillColor;

@end



@implementation CWLArenaView


- (void)initialize {
    self.particleRadius = 3.0;
    self.landmarkRadius = 8.0;
    self.strokeWidth = 1.0;
    self.strokeColor = [UIColor redColor].CGColor;
    self.fillColor = [UIColor redColor].CGColor;
    
    self.isInitialized = YES;
}


- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"[%@] Redrawing.", self.class);
    
    if (!self.isInitialized) {
        [self initialize];
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.fillColor);
    
    for (CWLPointParticle* particle in self.particles) {
        CGRect rect = CGRectMake(
                                 particle.x-(self.particleRadius/2.0),
                                 particle.y-(self.particleRadius/2.0),
                                 self.particleRadius,
                                 self.particleRadius);
        CGContextFillEllipseInRect (context, rect);
    }

    for (CWLBeaconLandmark* landmark in self.landmarks) {
        CGRect rect = CGRectMake(
                                 landmark.x-(self.landmarkRadius/2.0),
                                 landmark.y-(self.landmarkRadius/2.0),
                                 self.landmarkRadius,
                                 self.landmarkRadius);
        
        CGContextSetFillColorWithColor(context, landmark.color.CGColor);
        CGContextFillEllipseInRect (context, rect);
        
        if (landmark.distance > self.landmarkRadius) {
            CGRect rect = CGRectMake(
                                     landmark.x-(self.landmarkRadius/2.0),
                                     landmark.y-(self.landmarkRadius/2.0),
                                     self.landmarkRadius,
                                     self.landmarkRadius);
            
            CGContextSetStrokeColorWithColor(context, self.strokeColor);
            CGContextStrokeEllipseInRect(context, rect);
            
            CGRect distRect = CGRectMake(
                                     landmark.x-landmark.distance,
                                     landmark.y-landmark.distance,
                                     landmark.distance*2.0,
                                     landmark.distance*2.0);
            CGContextSetStrokeColorWithColor(context, landmark.color.CGColor);
            CGContextStrokeEllipseInRect(context, distRect);
            
        }
    }
    
    CGContextFillPath(context);
    
}


@end
