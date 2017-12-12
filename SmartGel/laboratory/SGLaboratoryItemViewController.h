//
//  SGLaboratoryItemViewController.h
//  SmartGel
//
//  Created by jordi on 11/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaboratoryDataModel.h"

@interface SGLaboratoryItemViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *blankView;
@property (strong, nonatomic) IBOutlet UIView *sampleView;
@property (strong, nonatomic) IBOutlet UIImageView *resultfoxImageView;

@property (strong, nonatomic) IBOutlet UILabel *resultValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;
@property (strong, nonatomic) IBOutlet UILabel *customerLabel;

@property (strong, nonatomic) LaboratoryDataModel *laboratoryDataModel;

@end
