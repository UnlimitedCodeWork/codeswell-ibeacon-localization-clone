//
//  CWLArenaView.h
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWLPointParticle.h"
#import "CWLBeaconLandmark.h"


@interface CWLArenaView : UIView

@property (nonatomic, copy) NSArray* particles;
@property (nonatomic, copy) NSArray* landmarks;

@end
