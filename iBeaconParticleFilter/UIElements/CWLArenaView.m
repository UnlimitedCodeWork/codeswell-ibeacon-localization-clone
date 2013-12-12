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
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign) CGColorRef strokeColor;
@property (nonatomic, assign) CGColorRef fillColor;

@end



@implementation CWLArenaView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)initialize {
    self.particleRadius = 5.0;
    self.strokeWidth = 1.0;
    self.strokeColor = [UIColor blueColor].CGColor;
    self.fillColor = [UIColor redColor].CGColor;
    
    self.isInitialized = YES;
}

- (void)drawRect:(CGRect)rect {
    DDLogVerbose(@"[%@] Redrawing.", self.class);
    
    if (!self.isInitialized) {
        [self initialize];
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.strokeColor);
    CGContextSetFillColorWithColor(context, self.fillColor);
    
    for (CWLPointParticle* particle in self.particles) {
        CGRect rect = CGRectMake(
                                 particle.x-(self.particleRadius/2.0),
                                 particle.y-(self.particleRadius/2.0),
                                 self.particleRadius,
                                 self.particleRadius);
        CGContextFillEllipseInRect (context, rect);
    }

    CGContextFillPath(context);
    
}


@end
