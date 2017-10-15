//
//  SGHomeViewController.m
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGHomeViewController.h"
#import "SGHistoryViewController.h"
#import "GPUImage.h"

@interface SGHomeViewController ()

@end

@implementation SGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.engine = [[DirtyExtractor alloc] init];
    isShowDirtyArea = false;
    isSavedImage = false;
    
    [self initLocationManager];
    [self.dateLabel setText:[self getCurrentTimeString]];
    
    self.ref = [[FIRDatabase database] reference];
    
    self.estimateImage = [[EstimateImageModel alloc] init];
    [self loginFireBase];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginFireBase{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        [hud hideAnimated:false];
        if(error==nil){
            self.userID = user.uid;
            self.storageRef = [[FIRStorage storage] reference];
        }else{
            [self showAlertdialog:@"Error" message:error.localizedDescription];
        }
    }];
}

-(void)launchSettingParameterViewController{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"customcamera" bundle:[NSBundle mainBundle]];
//    SGParameterSettingViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"SGParameterSettingViewController"];
//    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentViewController:controller animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    if(!self.notificationLabel.isHidden)
        [self.notificationLabel setHidden:YES];
    [self hideDirtyArea];
    isSavedImage = false;
    GPUImageGammaFilter *filter = [[GPUImageGammaFilter alloc] init];
    [(GPUImageGammaFilter *)filter setGamma:1.7];
    UIImage *quickFilteredImage = [filter imageByFilteringImage:image];
    [self getEstimagtedValue:quickFilteredImage];
    
    [self.dateLabel setText:[self getCurrentTimeString]];
    [self.takenImageView setImage:image];
    [self setImageDataModel:image withEstimatedValue:self.engine.dirtyValue withDate:self.dateLabel.text withLocation:self.locationLabel.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setImageDataModel:(UIImage*)image
       withEstimatedValue:(float)vaule
                 withDate:(NSString*)dateString
             withLocation:(NSString*)currentLocation{
    self.estimateImage.image = image;
    self.estimateImage.dirtyValue = vaule;
    self.estimateImage.date = dateString;
    self.estimateImage.location = currentLocation;
    self.estimateImage.dirtyArea = [self getDirtyStateJsonString];
}

-(IBAction)backButtonPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showDirtyArea{
    isShowDirtyArea = true;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        for(int i = 0; i<(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);i++)
            [self drawView:i];
        [hud hideAnimated:false];
    });
}

-(void)hideDirtyArea{
    isShowDirtyArea = false;
    [self.takenImageView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

-(void)getEstimagtedValue:(UIImage *)image{
    [self.engine reset];
    [self.engine importImage:image];
    [self.engine extract];
    [self.valueLabel setText:[NSString stringWithFormat:@"Estimated Value: %.2f", self.engine.dirtyValue]];
}

-(void)drawView:(int)index{
    
    int y = index/AREA_DIVIDE_NUMBER;
    int x = (AREA_DIVIDE_NUMBER-1) - index%AREA_DIVIDE_NUMBER;
    
    float areaWidth = self.takenImageView.frame.size.width/AREA_DIVIDE_NUMBER;
    float areaHeight = self.takenImageView.frame.size.height/AREA_DIVIDE_NUMBER;
    
    UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(x*areaWidth, y*areaHeight, areaWidth, areaHeight)];
    
    if([[self.engine.areaDirtyState objectAtIndex:index] boolValue]){
        [paintView setBackgroundColor:[UIColor redColor]];
        [paintView setAlpha:0.5];
        [self.takenImageView addSubview:paintView];
    }
}

-(NSString *)getCurrentTimeString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    return dateString;
}

-(void)initLocationManager{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             NSString *address = [NSString stringWithFormat:@"%@ %@,%@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];
             self.locationLabel.text = address;
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self showAlertdialog:@"Error" message:@"Failed to Get Your Location"];
}

-(IBAction)savePhoto{
    if(self.estimateImage.image == nil){
        [self showAlertdialog:nil message:@"Please take a photo."];
    }else{
        if(isSavedImage)
            [self showAlertdialog:nil message:@"You have already saved this Image."];
        else
            [self saveResultImage];
    }
}

- (IBAction)showActionSheet{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Save Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Show Hitory" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if(self.storageRef!=nil){
            [self performSegueWithIdentifier:@"gotoHistory" sender:self];
        }else{
            [self showAlertdialog:@"Error" message:@"Failed to connect to server. Please check internet connection!"];
        }
    }]];
    
    //    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Setting Paramters" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //        [self launchSettingParameterViewController];
    //    }]];
    
    CGRect rect = CGRectMake(50, 50 , 0, 0);
    actionSheet.popoverPresentationController.sourceView = self.view;
    actionSheet.popoverPresentationController.sourceRect = rect;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)saveResultImage{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Uploading image...";
    FIRStorageReference *riversRef = [self.storageRef child:[NSString stringWithFormat:@"%@/%@.png",self.userID,self.estimateImage.date]];
    NSData *imageData = UIImageJPEGRepresentation(self.estimateImage.image,0.7);
    [riversRef putData:imageData
              metadata:nil
            completion:^(FIRStorageMetadata *metadata,NSError *error) {
                [hud hideAnimated:false];
                if (error != nil) {
                    [self showAlertdialog:@"Image Uploading Failed!" message:error.localizedDescription];
                } else {
                    isSavedImage = true;
                    [self showAlertdialog:@"Image Uploading Success!" message:error.localizedDescription];
                    NSString *key = self.userID;
                    NSDictionary *post = @{@"value": [NSString stringWithFormat:@"%.1f",self.estimateImage.dirtyValue],
                                           @"image": metadata.downloadURL.absoluteString,
                                           @"date": self.estimateImage.date,
                                           @"location": self.estimateImage.location,
                                           @"dirtyarea": self.estimateImage.dirtyArea};
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@", key,self.estimateImage.date]: post};
                    [self.ref updateChildValues:childUpdates];
                }
            }];
}

-(void)showAlertdialog:(NSString*)title message:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert]; // 1
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSString *)getDirtyStateJsonString{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.engine.areaDirtyState options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

-(IBAction)showHideCleanArea{
    if(isShowDirtyArea){
        [self.notificationLabel setHidden:NO];
        [self.takePhotoButton setHidden:NO];
        [self.showCleanAreaButton setTitle:@"Show Clean Area" forState:UIControlStateNormal];
        [self hideDirtyArea];
    }else{
        if(self.estimateImage.image == nil){
            [self showAlertdialog:nil message:@"Please take a photo."];
        }
        else{
            [self.notificationLabel setHidden:YES];
            [self.takePhotoButton setHidden:YES];
            [self.showCleanAreaButton setTitle:@"Hide Clean Area" forState:UIControlStateNormal];
            [self showDirtyArea];
        }
    }
}

-(IBAction)launchPhotoPickerController{
//
//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    imagePickerController.delegate = self;
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    [self presentViewController:imagePickerController animated:NO completion:nil];
    
    [self hideDirtyArea];
    isSavedImage = false;
//    GPUImageGammaFilter *filter = [[GPUImageGammaFilter alloc] init];
//    [(GPUImageGammaFilter *)filter setGamma:1.7];
    UIImage *quickFilteredImage = [UIImage imageNamed:@"test.jpg"];
    [self getEstimagtedValue:quickFilteredImage];
    
    [self.dateLabel setText:[self getCurrentTimeString]];
    [self.takenImageView setImage:quickFilteredImage];
    [self setImageDataModel:quickFilteredImage withEstimatedValue:self.engine.dirtyValue withDate:self.dateLabel.text withLocation:self.locationLabel.text];
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void)gotoHistory{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"gotoHistory"]) {
        SGHistoryViewController *vc = [segue destinationViewController];
        vc.storageRef = self.storageRef;
        vc.ref = self.ref;
    }
}

@end
