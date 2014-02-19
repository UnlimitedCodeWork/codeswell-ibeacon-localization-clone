//
//  CWLViewController.m
//  iBeaconParticleFilter
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import "CWLViewController.h"
#import "CWLParticleFilter.h"
#import "CWLArenaView.h"
#import "boxmuller.h"

#import "ESTBeaconManager.h"

@interface CWLViewController () <CWLParticleFilterDelegate, UITableViewDataSource, UITableViewDelegate, ESTBeaconManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (weak, nonatomic) IBOutlet CWLArenaView *arenaView;

@property (nonatomic, strong) CWLParticleFilter* particleFilter;
@property (nonatomic, strong) NSArray* landmarks;
@property (nonatomic, strong) NSDictionary* landmarkHash;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) ESTBeaconManager* beaconMgr;

@end


static NSString* beaconRegionId = @"com.dxydoes.ibeacondemo";
#define PXPERMETER (300.0/7.0)
#define XBOUND 7.0
#define YBOUND 5.0
#define INSET 0.4
#define MEASUREMENTSIGMA 3.0
#define NOISESIGMA 0.10


@implementation CWLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arenaView.pxPerMeter = PXPERMETER;
    
    self.beaconMgr = [[ESTBeaconManager alloc] init];
    self.beaconMgr.delegate = self;
    self.beaconMgr.avoidUnknownStateBeacons = YES;
    
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithIdentifier:beaconRegionId];
    [self.beaconMgr startRangingBeaconsInRegion:region];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.particleFilter == nil) {
        self.particleFilter = [[CWLParticleFilter alloc] initWithSize:self.arenaView.bounds.size
                                                            landmarks:nil
                                                        particleCount:250];
        self.particleFilter.delegate = self;
    }
    
    if (self.landmarks == nil) {
        self.landmarks = @[
                           [CWLBeaconLandmark landmarkWithIdent:[CWLBeaconLandmark identFromMajor:18900 minor:1234]
                                                              x:INSET
                                                              y:INSET
                                                          color:[UIColor greenColor]],
                           [CWLBeaconLandmark landmarkWithIdent:[CWLBeaconLandmark identFromMajor:18900 minor:567]
                                                              x:XBOUND-INSET
                                                              y:INSET
                                                          color:[UIColor purpleColor]],
                           [CWLBeaconLandmark landmarkWithIdent:[CWLBeaconLandmark identFromMajor:18900 minor:89]
                                                              x:XBOUND/2.0
                                                              y:YBOUND
                                                          color:[UIColor blueColor]]
                           ];
        self.arenaView.landmarks = self.landmarks;
        
        NSMutableDictionary* tmpLandmarkHash = [NSMutableDictionary dictionary];
        for (CWLBeaconLandmark* landmark in self.landmarks) {
            tmpLandmarkHash[landmark.ident] = landmark;
        }
        self.landmarkHash = tmpLandmarkHash;
    }
        
    
//    if (self.timer == nil) {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
//                                                      target:self
//                                                    selector:@selector(advanceParticleFilter)
//                                                    userInfo:nil
//                                                     repeats:YES];
//    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)advanceParticleFilter {
    [self.particleFilter move];
    [self.particleFilter sense:self.landmarks];
}


#pragma mark CWLParticleFilterDelegate Protocol

- (CWLParticleBase*)newParticleForParticleFilter:(CWLParticleFilter *)filter {
    
    CWLPointParticle* ret = [[CWLPointParticle alloc] init];
    ret.x = (arc4random() % (NSInteger)(XBOUND*1000)) / 1000.0;
    ret.y = (arc4random() % (NSInteger)(YBOUND*1000)) / 1000.0;
    DDLogVerbose(@"New particle: (%4.2f,%4.2f)", ret.x, ret.y);
    
    return ret;
}


- (void)particleFilter:(CWLParticleFilter*)filter moveParticle:(CWLParticleBase*)particle {
    CWLPointParticle* p = (CWLPointParticle*)particle;
    
    // Calculate incremental movement (There's none in our case)
    float delta_x = 0.0;
    float delta_y = 0.0;
    
    // Apply movement
    p.x += delta_x;
    p.y += delta_y;
}


- (float)particleFilter:(CWLParticleFilter*)filter getLikelihood:(CWLParticleBase*)particle withMeasurements:(id)measurements {
    CWLPointParticle* p = (CWLPointParticle*)particle;

    NSArray* measuredLandmarks = measurements;
    float confidence = 1.0;
    
    for (CWLBeaconLandmark* landmark in measuredLandmarks) {
        
        if (landmark.rssi < -10) {
            
            // Get the expected distance in pixels, using a^2 + b^2 = c^2
            float expectedDistance = sqrtf(
                                           powf((landmark.x-p.x), 2)
                                           + powf((landmark.y-p.y), 2)
                                           );
            
            float error = landmark.meters - expectedDistance;
            confidence *= [self confidenceFromDisplacement:error sigma:MEASUREMENTSIGMA];
        }
    }
    
    return confidence;
}


- (CWLParticleBase*)particleFilter:(CWLParticleFilter*)filter particleWithNoiseFromParticle:(CWLParticleBase*)particle {
    CWLPointParticle* p = (CWLPointParticle*)particle;
    
    // Create new particle from old and add gaussian noise
    CWLPointParticle* ret = [[CWLPointParticle alloc] init];
    ret.x = p.x + box_muller(0.0, NOISESIGMA);
    ret.y = p.y + box_muller(0.0, NOISESIGMA);
    
    return ret;
}


- (void)particleFilter:(CWLParticleFilter*)filter particlesDidAdvance:(NSArray *)particles {
    self.arenaView.particles = particles;
    [self.arenaView setNeedsDisplay];
}


#pragma mark ESTBeaconManagerDelegate protocol

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if ([region.identifier isEqualToString:beaconRegionId]) {
        
        [self.landmarks enumerateObjectsUsingBlock:^(CWLBeaconLandmark* landmark, NSUInteger idx, BOOL *stop) {
            landmark.rssi = 0;
        }];
        
        for (ESTBeacon* beacon in beacons) {
            NSString* ident = [CWLBeaconLandmark identFromMajor:[beacon.major integerValue] minor:[beacon.minor integerValue]];
            
            CWLBeaconLandmark* landmark = self.landmarkHash[ident];
            landmark.rssi = beacon.rssi;
        }

        [self.beaconTable reloadData];
        [self.particleFilter sense:self.landmarks];
    }
}



#pragma mark UITableViewDataSource Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.landmarks.count;
}


#pragma mark UITableViewDelegate Protocol

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Known landmarks";
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BeaconCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CWLBeaconLandmark* landmark = self.landmarks[indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%lddB)", landmark.ident, (long)landmark.rssi];
    cell.textLabel.textColor = landmark.color;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"range: %4.2fm  mean: %4.2fdB  std. dev: ±%4.2f",
                                 landmark.meters, landmark.meanRssi, landmark.stdDeviationRssi];
    
    return cell;
}


#pragma mark Helpers

- (float)confidenceFromDisplacement:(float)displacement sigma:(float)sigma {
    
    // Based on http://stackoverflow.com/a/656992/46731
    // No need to normalize it, since the particle filter will normalize all weights
    
    float ret = exp( -pow(displacement, 2) / (2 * pow(sigma, 2)) );
    return ret;
}


@end
