//
//  SGHistoryDetailViewController.h
//  SmartGel
//
//  Created by jordi on 28/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGGridView.h"
#import "EstimateImageModel.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "Firebase.h"
#import "SGBaseViewController.h"
#import "SGConstant.h"
#import "DirtyExtractor.h"

@protocol SGHistoryDetailViewControllerDelegate <NSObject>
@required
- (void)onDeletedImage;
@end

@interface SGHistoryDetailViewController : SGBaseViewController{
    bool isShowDirtyArea;
    bool isShowDirtyAreaUpdatedParameter;
    bool isShowPartArea;
}

@property (weak, nonatomic) id<SGHistoryDetailViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *takenImageView;
@property (strong, nonatomic) SGGridView *gridView;
@property (strong, nonatomic) IBOutlet UIView *gridContentView;


@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UILabel *dirtyLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) IBOutlet UIButton *showDirtyAreaButton;

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) EstimateImageModel *selectedEstimateImageModel;

@property (nonatomic, strong) DirtyExtractor *engine;
@property (nonatomic, strong) DirtyExtractor *partyEngine;

@end
