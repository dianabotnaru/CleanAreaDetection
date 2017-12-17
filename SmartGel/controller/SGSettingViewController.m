//
//  SGSettingViewController.m
//  SmartGel
//
//  Created by jordi on 27/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGSettingViewController.h"
#import "SGConstant.h"

@interface SGSettingViewController ()

@end

@implementation SGSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *colorOffset = [defaults objectForKey:@"coloroffset"];
    if(colorOffset == nil){
        [self.sliderView setValue:SGDefaultColorOffset];
    }else{
        float sliderValue = [colorOffset floatValue];
        [self.sliderView setValue:sliderValue];
    }
    self.valueLabel.text = [NSString stringWithFormat:@"Offset : %.0f",self.sliderView.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)sliderValueChange{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%.0f",_sliderView.value] forKey:@"coloroffset"];
    self.valueLabel.text = [NSString stringWithFormat:@"Offset : %.0f",self.sliderView.value];
}

-(IBAction)setDefaultValue{
    [self.sliderView setValue:SGDefaultColorOffset];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%.0f",self.sliderView.value] forKey:@"coloroffset"];
    self.valueLabel.text = [NSString stringWithFormat:@"Offset : %.0f",self.sliderView.value];
}
@end
