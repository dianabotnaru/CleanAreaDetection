//
//  SGHomeViewController.h
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SGBaseViewController.h"

#import "MBProgressHUD.h"
#import "Firebase.h"
#import "EstimateImageModel.h"
#import "DirtyExtractor.h"
#import "RESideMenu.h"
#import "SGGridView.h"
#import "UIImageView+WebCache.h"

@interface SGHomeViewController : SGBaseViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>{
    bool isShowDirtyArea;
    bool isSavedImage;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UIImageView *takenImageView;

@property (strong, nonatomic) IBOutlet UIView *gridContentView;

@property (strong, nonatomic) SGGridView *gridView;
@property (strong, nonatomic) IBOutlet UIView *noGelView;

@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;

@property (strong, nonatomic) UIImage *takenImage;
@property (strong, nonatomic) UIImage *croppedImage;

@property (nonatomic, strong) DirtyExtractor *engine;
@property (nonatomic, strong) DirtyExtractor *partyEngine;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) EstimateImageModel *estimateImage;

@property (strong, nonatomic) IBOutlet UIButton *showCleanAreaButton;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;

@end
