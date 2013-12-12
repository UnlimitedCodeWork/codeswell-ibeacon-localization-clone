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

@interface CWLViewController () <CWLParticleFilterDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (weak, nonatomic) IBOutlet CWLArenaView *arenaView;

@property (nonatomic, strong) CWLParticleFilter* particleFilter;
@property (nonatomic, strong) NSArray* landmarks;
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation CWLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.particleFilter == nil) {
        self.particleFilter = [[CWLParticleFilter alloc] initWithSize:self.arenaView.bounds.size
                                                            landmarks:nil
                                                        particleCount:20];
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
    }
        
    
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
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
    
    NSArray* measurements = nil;
    [self.particleFilter sense:measurements];
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

- (float)particleFilter:(CWLParticleFilter*)filter getLikelihood:(CWLParticleBase*)particle withMeasurements:(id)measurements {
#warning Incomplete method implementation.
    return 30;
}

#define NOISESTANDARDDEVIATION 3.0
- (CWLParticleBase*)particleFilter:(CWLParticleFilter*)filter particleWithNoiseFromParticle:(CWLParticleBase*)particle {
    CWLPointParticle* p = (CWLPointParticle*)particle;
    
    // Create new particle from old and add gaussian noise
    CWLPointParticle* ret = [[CWLPointParticle alloc] init];
    ret.x = p.x + box_muller(0.0, NOISESTANDARDDEVIATION);
    ret.y = p.y + box_muller(0.0, NOISESTANDARDDEVIATION);
    
    return ret;
}



#pragma mark UITableViewDataSource Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    return 3;
}


#pragma mark UITableViewDelegate Protocol

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BeaconCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row+1];
    
    return cell;
}


#pragma mark Helpers

- (NSString*)identFromMajor:(NSInteger)major minor:(NSInteger)minor {
    return [NSString stringWithFormat:@"%d-%d", major, minor];
}


@end
