//
//  SGHomeViewController.h
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"
#import "Firebase.h"
#import "EstimateImageModel.h"
#import "DirtyExtractor.h"

@interface SGHomeViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>{
    bool isShowDirtyArea;
    bool isSavedImage;
    MBProgressHUD *hud;
}


@property (strong, nonatomic) IBOutlet UIImageView *takenImageView;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;

@property (strong, nonatomic) UIImage *takenImage;

@property (nonatomic, strong) DirtyExtractor *engine;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) EstimateImageModel *estimateImage;
@property (strong, nonatomic) NSString *userID;

@end
