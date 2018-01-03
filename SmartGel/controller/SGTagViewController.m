//
//  SGTagViewController.m
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import "SGTagViewController.h"

@interface SGTagViewController ()

@end

@implementation SGTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated: YES];
}

@end
