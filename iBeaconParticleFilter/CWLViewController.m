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
#import "CWLPointParticle.h"

@interface CWLViewController () <CWLParticleFilterDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (weak, nonatomic) IBOutlet CWLArenaView *arenaView;

@property (nonatomic, strong) CWLParticleFilter* particleFilter;

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
    
    [self.particleFilter advance];
}


#pragma mark CWLParticleFilterDelegate Protocol

- (id)newParticleForParticleFilter:(CWLParticleFilter *)filter {
    
    CWLPointParticle* ret = [[CWLPointParticle alloc] init];
    ret.x = arc4random() % ((NSInteger)self.arenaView.bounds.size.width-20) + 10.0;
    ret.y = arc4random() % ((NSInteger)self.arenaView.bounds.size.height-20) + 10.0;
    
    return ret;
}

- (void)particleFilter:(CWLParticleFilter *)filter particlesDidAdvance:(NSArray *)particles {
    self.arenaView.particles = particles;
    [self.arenaView setNeedsDisplay];
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


@end
