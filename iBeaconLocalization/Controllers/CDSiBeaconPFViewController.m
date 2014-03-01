//
//  CDSViewController.m
//  iBeaconLocalization
//
//  Created by Andrew Craze on 12/12/13.
//  Copyright (c) 2013 Codeswell. All rights reserved.
//

#import "CDSiBeaconPFViewController.h"
#import "CDSXYParticleFilter.h"
#import "CDSArenaView.h"

#import "ESTBeaconManager.h"

@interface CDSiBeaconPFViewController () <CDSXYParticleFilterDelegate, UITableViewDataSource, UITableViewDelegate, ESTBeaconManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (weak, nonatomic) IBOutlet CDSArenaView *arenaView;

@property (nonatomic, strong) CDSXYParticleFilter* particleFilter;
@property (nonatomic, strong) NSArray* landmarks;
@property (nonatomic, strong) NSDictionary* landmarkHash;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) ESTBeaconManager* beaconMgr;

@end


static NSString* beaconRegionId = @"com.dxydoes.ibeacondemo";

// Define the arena (Measurements in meters)
#define PXPERMETER (320.0/7.0)
#define ARENAWIDTH 7.0
#define ARENAHEIGHT 5.0
// Landmark locations and identification
#define LANDMARKSMAJOR 18900
#define LANDMARK1X 0.4
#define LANDMARK1Y 0.4
#define LANDMARK1MINOR 1234
#define LANDMARK2X 6.6
#define LANDMARK2Y 0.4
#define LANDMARK2MINOR 567
#define LANDMARK3X 3.5
#define LANDMARK3Y 4.6
#define LANDMARK3MINOR 89

// Filter parameters
#define PARTICLECOUNT 500
#define MEASUREMENTINTERVAL 0.5
#define MEASUREMENTSIGMA 2.0
#define NOISESIGMA 0.1


@implementation CDSiBeaconPFViewController

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
        self.particleFilter = [[CDSXYParticleFilter alloc] initWithParticleCount:PARTICLECOUNT
                                                                            minX:0.0
                                                                            maxX:ARENAWIDTH
                                                                            minY:0.0
                                                                            maxY:ARENAHEIGHT
                                                                      noiseSigma:NOISESIGMA];
        self.particleFilter.delegate = self;
    }
    
    if (self.landmarks == nil) {
        self.landmarks = @[
                           [CDSBeaconLandmark landmarkWithIdent:[CDSBeaconLandmark identFromMajor:LANDMARKSMAJOR minor:LANDMARK1MINOR]
                                                              x:LANDMARK1X
                                                              y:LANDMARK1Y
                                                          color:[UIColor greenColor]],
                           [CDSBeaconLandmark landmarkWithIdent:[CDSBeaconLandmark identFromMajor:LANDMARKSMAJOR minor:LANDMARK2MINOR]
                                                              x:LANDMARK2X
                                                              y:LANDMARK2Y
                                                          color:[UIColor purpleColor]],
                           [CDSBeaconLandmark landmarkWithIdent:[CDSBeaconLandmark identFromMajor:LANDMARKSMAJOR minor:LANDMARK3MINOR]
                                                              x:LANDMARK3X
                                                              y:LANDMARK3Y
                                                          color:[UIColor blueColor]]
                           ];
        self.arenaView.landmarks = self.landmarks;
        
        NSMutableDictionary* tmpLandmarkHash = [NSMutableDictionary dictionary];
        for (CDSBeaconLandmark* landmark in self.landmarks) {
            tmpLandmarkHash[landmark.ident] = landmark;
        }
        self.landmarkHash = tmpLandmarkHash;
    }
        
// Used for timer-driven measurement/sampling
//    if (self.timer == nil) {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:MEASUREMENTINTERVAL
//                                                      target:self
//                                                    selector:@selector(advanceParticleFilter)
//                                                    userInfo:nil
//                                                     repeats:YES];
//    }
    
}

// Used for timer-driven measurement/sampling
//- (void)viewWillDisappear:(BOOL)animated {
//    [self.timer invalidate];
//    self.timer = nil;
//}
//
//- (void)advanceParticleFilter {
//    // [self.particleFilter applyMotion];
//    [self.particleFilter applyMeasurements:self.landmarks];
//}


#pragma mark CDSXYParticleFilterDelegate protocol

- (void)xyParticleFilter:(CDSXYParticleFilter*)filter moveParticle:(CDSXYParticle*)particle {
    CDSXYParticle* p = particle;
    
    // Calculate incremental movement (There's none in our case)
    double delta_x = 0.0;
    double delta_y = 0.0;
    
    // Apply movement
    p.x += delta_x;
    p.y += delta_y;
}


- (double)xyParticleFilter:(CDSXYParticleFilter*)filter getLikelihood:(CDSXYParticle*)particle withMeasurements:(id)measurements {
    CDSXYParticle* p = particle;
    
    NSArray* measuredLandmarks = measurements;
    double confidence = 1.0;
    
    for (CDSBeaconLandmark* landmark in measuredLandmarks) {
        
        if (landmark.rssi < -10) {
            
            // Get the expected distance in pixels, using a^2 + b^2 = c^2
            double expectedDistance = sqrtf(
                                           powf((landmark.x-p.x), 2)
                                           + powf((landmark.y-p.y), 2)
                                           );
            
            double error = landmark.meters - expectedDistance;
            confidence *= [self confidenceFromDisplacement:error sigma:MEASUREMENTSIGMA];
        }
    }
    
    return confidence;
}


// Optional
//- (double)xyParticleFilter:(CDSXYParticleFilter*)filter noiseWithMean:(double)m sigma:(double)s;


- (void)xyParticleFilter:(CDSXYParticleFilter*)filter particlesResampled:(NSArray*)particles {
    self.arenaView.particles = particles;
    [self.arenaView setNeedsDisplay];
}


#pragma mark ESTBeaconManagerDelegate protocol

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if ([region.identifier isEqualToString:beaconRegionId]) {
        
        [self.landmarks enumerateObjectsUsingBlock:^(CDSBeaconLandmark* landmark, NSUInteger idx, BOOL *stop) {
            landmark.rssi = 0;
        }];
        
        for (ESTBeacon* beacon in beacons) {
            NSString* ident = [CDSBeaconLandmark identFromMajor:[beacon.major integerValue] minor:[beacon.minor integerValue]];
            
            CDSBeaconLandmark* landmark = self.landmarkHash[ident];
            landmark.rssi = beacon.rssi;
        }

        [self.beaconTable reloadData];
        [self.particleFilter applyMeasurements:self.landmarks];
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
    
    CDSBeaconLandmark* landmark = self.landmarks[indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%lddB)", landmark.ident, (long)landmark.rssi];
    cell.textLabel.textColor = landmark.color;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"range: %4.2fm  mean: %4.2fdB  std. dev: ±%4.2f",
                                 landmark.meters, landmark.meanRssi, landmark.stdDeviationRssi];
    
    return cell;
}


#pragma mark Helpers

- (double)confidenceFromDisplacement:(double)displacement sigma:(double)sigma {
    
    // Based on http://stackoverflow.com/a/656992/46731
    // No need to normalize it, since the particle filter will normalize all weights
    
    double ret = exp( -pow(displacement, 2) / (2 * pow(sigma, 2)) );
    return ret;
}


@end
