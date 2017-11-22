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

@interface SGHomeViewController : SGBaseViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>{
    bool isShowDirtyArea;
    bool isSavedImage;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UIImageView *takenImageView;

@property (strong, nonatomic) IBOutlet SGGridView *gridView;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;

@property (strong, nonatomic) UIImage *takenImage;

@property (nonatomic, strong) DirtyExtractor *engine;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) EstimateImageModel *estimateImage;
@property (strong, nonatomic) NSString *userID;

@property (strong, nonatomic) IBOutlet UIButton *showCleanAreaButton;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;

@end
