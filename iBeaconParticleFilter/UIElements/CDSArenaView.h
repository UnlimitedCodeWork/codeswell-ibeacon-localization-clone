//
//  CWLArenaView.h
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSPointParticle.h"
#import "CDSBeaconLandmark.h"


@interface CDSArenaView : UIView

@property (nonatomic, copy) NSArray* particles;
@property (nonatomic, copy) NSArray* landmarks;
@property (nonatomic, assign) float pxPerMeter;

@end
