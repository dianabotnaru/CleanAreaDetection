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
#import "DirtyExtractor.h"
#import "SGDateTimePickerView.h"
#import "SGBaseViewController.h"
#import "DirtyExtractor.h"
#import "SGGridView.h"

@interface SGHistoryViewController : SGBaseViewController{
    bool isShowDirtyArea;
    bool isShowDetailView;
    bool isFromButtonTapped;
    SGDateTimePickerView *sgDateTimePickerView;
    NSDate *fromDate;
    NSDate *toDate;
    NSArray *dirtyStateArray;
}
@property (nonatomic, strong) DirtyExtractor *engine;
@property (strong, nonatomic) IBOutlet SGGridView *gridView;

@property (strong, nonatomic) IBOutlet UICollectionView *smartGelHistoryCollectionView;
@property (strong, nonatomic) NSMutableArray *historyArray;
@property (strong, nonatomic) NSMutableArray *historyFilterArray;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) IBOutlet UIView *historyView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIImageView *takenImageView;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIButton *showDirtyAreaButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTopMargin;

@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (strong, nonatomic) IBOutlet UILabel *toLabel;

@property (strong, nonatomic) EstimateImageModel *selectedImageModel;

@end
