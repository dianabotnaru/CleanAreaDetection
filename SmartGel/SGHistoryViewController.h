//
//  SGHistoryViewController.h
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firebase.h"
#import "MBProgressHUD.h"
#import "EstimateImageModel.h"
#import "SGDateTimePickerView.h"
#import "SGBaseViewController.h"

@interface SGHistoryViewController : SGBaseViewController{
    bool isFromButtonTapped;
    SGDateTimePickerView *sgDateTimePickerView;
    NSDate *fromDate;
    NSDate *toDate;
}
@property (strong, nonatomic) IBOutlet UICollectionView *smartGelHistoryCollectionView;
@property (strong, nonatomic) NSMutableArray *historyArray;
@property (strong, nonatomic) NSMutableArray *historyFilterArray;

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet UIView *historyView;

@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (strong, nonatomic) IBOutlet UILabel *toLabel;

@end
