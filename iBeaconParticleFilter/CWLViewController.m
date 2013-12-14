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


@implementation CWLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
                                                        particleCount:200];
        self.particleFilter.delegate = self;
    }
    
    if (self.landmarks == nil) {
        self.landmarks = @[
                           [CWLBeaconLandmark landmarkWithIdent:[self identFromMajor:18900 minor:1234]
                                                              x:10.0
                                                              y:10.0
                                                          color:[UIColor greenColor]],
                           [CWLBeaconLandmark landmarkWithIdent:[self identFromMajor:18900 minor:567]
                                                              x:self.arenaView.bounds.size.width-10.0
                                                              y:10.0
                                                          color:[UIColor purpleColor]],
                           [CWLBeaconLandmark landmarkWithIdent:[self identFromMajor:18900 minor:89]
                                                              x:self.arenaView.bounds.size.width/2.0
                                                              y:self.arenaView.bounds.size.height-10.0
                                                          color:[UIColor blueColor]]
                           ];
        self.arenaView.landmarks = self.landmarks;
        
        NSMutableDictionary* tmpLandmarkHash = [NSMutableDictionary dictionary];
        for (CWLBeaconLandmark* landmark in self.landmarks) {
            tmpLandmarkHash[landmark.ident] = landmark;
        }
        self.landmarkHash = tmpLandmarkHash;
    }
        
    
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(advanceParticleFilter)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
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
    ret.x = arc4random() % ((NSInteger)self.arenaView.bounds.size.width-20) + 10.0;
    ret.y = arc4random() % ((NSInteger)self.arenaView.bounds.size.height-20) + 10.0;
    
    return ret;
}


- (void)particleFilter:(CWLParticleFilter*)filter particlesDidAdvance:(NSArray *)particles {
    self.arenaView.particles = particles;
    [self.arenaView setNeedsDisplay];
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

#define MEASUREMENTSTANDARDDEVIATION 50.0
- (float)particleFilter:(CWLParticleFilter*)filter getLikelihood:(CWLParticleBase*)particle withMeasurements:(id)measurements {
    CWLPointParticle* p = (CWLPointParticle*)particle;

    NSArray* measuredLandmarks = measurements;
    float confidence = 1.0;
    
    for (CWLBeaconLandmark* landmark in measuredLandmarks) {
        
        if (landmark.rssi < -10) {
            
            // Get the expected distance, using a^2 + b^2 = c^2
            float expectedDistance = sqrtf(
                                           powf((landmark.x-p.x), 2)
                                           + powf((landmark.y-p.y), 2)
                                           );
            
            float error = landmark.distance - expectedDistance;
            confidence *= [self confidenceFromDisplacement:error sigma:MEASUREMENTSTANDARDDEVIATION];
        }
    }
    
    return confidence;
}

#define NOISESTANDARDDEVIATION 5.0
- (CWLParticleBase*)particleFilter:(CWLParticleFilter*)filter particleWithNoiseFromParticle:(CWLParticleBase*)particle {
    CWLPointParticle* p = (CWLPointParticle*)particle;
    
    // Create new particle from old and add gaussian noise
    CWLPointParticle* ret = [[CWLPointParticle alloc] init];
    ret.x = p.x + box_muller(0.0, NOISESTANDARDDEVIATION);
    ret.y = p.y + box_muller(0.0, NOISESTANDARDDEVIATION);
    
    return ret;
}


#pragma mark ESTBeaconManagerDelegate protocol

#define PXPERMETER (400.0/7.0)
-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if ([region.identifier isEqualToString:beaconRegionId]) {
        
        [self.landmarks enumerateObjectsUsingBlock:^(CWLBeaconLandmark* landmark, NSUInteger idx, BOOL *stop) {
            landmark.rssi = 0;
            landmark.distance = 0;
        }];
        
        for (ESTBeacon* beacon in beacons) {
            NSString* ident = [self identFromMajor:[beacon.major integerValue] minor:[beacon.minor integerValue]];
            
            CWLBeaconLandmark* landmark = self.landmarkHash[ident];
            landmark.rssi = beacon.rssi;
        }

        // Pre-calculate the measured distance to save repetition
        [self.landmarks enumerateObjectsUsingBlock:^(CWLBeaconLandmark* landmark, NSUInteger idx, BOOL *stop) {
            if (landmark.rssi < -10) {
                float distanceInPx = PXPERMETER * [self metersFromRssi:landmark.rssi];
                landmark.distance = distanceInPx;
            }
        }];
        
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", landmark.ident, (long)landmark.rssi];
    cell.textLabel.textColor = landmark.color;
    
    return cell;
}


#pragma mark Helpers

- (NSString*)identFromMajor:(NSInteger)major minor:(NSInteger)minor {
    return [NSString stringWithFormat:@"%ld-%ld", (long)major, (long)minor];
}

- (float)metersFromRssi:(NSInteger)rssi {

    // Based on measurement of Estimote beacons, power set at -8

//    float ret = 8.6604 * logf(-rssi) + 72.971;
    float ret = 0.0003 * expf(0.1122*-rssi);
    
    return ret;
}


- (float)confidenceFromDisplacement:(float)displacement sigma:(float)sigma {
    
    // Based on http://stackoverflow.com/a/656992/46731
    // No need to normalize it, since the particle filter will normalize all weights
    
    float ret = exp( -pow(displacement, 2) / (2 * pow(sigma, 2)) );
    return ret;
}


@end
