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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
