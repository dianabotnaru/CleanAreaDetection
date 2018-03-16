//
//  SGSettingViewController.h
//  SmartGel
//
//  Created by jordi on 27/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBaseViewController.h"

@interface SGSettingViewController : SGBaseViewController
@property (strong, nonatomic) IBOutlet UISlider *sliderView;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;

@end
