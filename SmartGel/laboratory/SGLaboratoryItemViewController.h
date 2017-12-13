//
//  SGLaboratoryItemViewController.h
//  SmartGel
//
//  Created by jordi on 11/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaboratoryDataModel.h"
#import "MBProgressHUD.h"
#import "SGBaseViewController.h"

@protocol SGLaboratoryItemViewControllerDelegate <NSObject>
@required
- (void)onDeletedImage;
@end


@interface SGLaboratoryItemViewController : SGBaseViewController

@property (weak, nonatomic) id<SGLaboratoryItemViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *blankView;
@property (strong, nonatomic) IBOutlet UIView *sampleView;
@property (strong, nonatomic) IBOutlet UIImageView *resultfoxImageView;

@property (strong, nonatomic) IBOutlet UILabel *resultValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;
@property (strong, nonatomic) IBOutlet UILabel *customerLabel;

@property (strong, nonatomic) LaboratoryDataModel *laboratoryDataModel;

@property (strong, nonatomic) MBProgressHUD *hud;

@end
