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
#import "SGConstant.h"
#import "AppDelegate.h"

@interface SGHomeViewController ()

@end

@implementation SGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self.dateLabel setText:[self getCurrentTimeString]];
    [self loginFireBase];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.gridView addGridViews:5 withColCount:5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData{
    self.engine = [[DirtyExtractor alloc] init];
    isShowDirtyArea = false;
    isSavedImage = false;
    isShowPartArea = false;
    self.estimateImage = [[EstimateImageModel alloc] init];
    [self initLocationManager];
    self.appDelegate.ref = [[FIRDatabase database] reference];
}

-(void)initDataUiWithImage:(UIImage *)image{
    isSavedImage = false;
    self.takenImage = image;
    self.engine = [[DirtyExtractor alloc] initWithImage:image];
    
    if(!self.notificationLabel.isHidden)
        [self.notificationLabel setHidden:YES];
    [self hideDirtyArea];
    [self.takenImageView setImage:self.takenImage];
    [self.dateLabel setText:[self getCurrentTimeString]];
    [self.valueLabel setText:[NSString stringWithFormat:@"Estimated Value: %.2f", self.engine.dirtyValue]];
    
    [self.estimateImage setImageDataModel:image withEstimatedValue:self.engine.dirtyValue withDate:self.dateLabel.text withLocation:self.locationLabel.text withDirtyArray:self.engine.areaDirtyState];
}

-(void)loginFireBase{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        [hud hideAnimated:false];
        if(error==nil){
            self.userID = user.uid;
            self.appDelegate.ref = [[FIRDatabase database] reference];
            self.appDelegate.storageRef = [[FIRStorage storage] reference];
        }else{
            [self showAlertdialog:@"Error" message:error.localizedDescription];
        }
    }];
}


- (void)saveResultImage{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Uploading image...";
    FIRStorageReference *riversRef = [self.appDelegate.storageRef child:[NSString stringWithFormat:@"%@/%@.png",self.userID,self.estimateImage.date]];
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
                    [self.appDelegate.ref updateChildValues:childUpdates];
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
    [self initDataUiWithImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)backButtonPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showDirtyArea{
    isShowDirtyArea = true;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isShowPartArea)
            [self drawView :self.partyEngine.areaDirtyState];
        else
            [self drawView : self.engine.areaDirtyState];
        [hud hideAnimated:false];
    });
}

-(void)hideDirtyArea{
    isShowDirtyArea = false;
    [self.takenImageView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

-(void)drawView:(NSMutableArray*)dirtyState{
    for(int i = 0; i<(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);i++){
        int y = i/AREA_DIVIDE_NUMBER;
        int x = (AREA_DIVIDE_NUMBER-1) - i%AREA_DIVIDE_NUMBER;
        float areaWidth = self.takenImageView.frame.size.width/AREA_DIVIDE_NUMBER;
        float areaHeight = self.takenImageView.frame.size.height/AREA_DIVIDE_NUMBER;
        UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(x*areaWidth, y*areaHeight, areaWidth, areaHeight)];
        if([[dirtyState objectAtIndex:i] boolValue]){
            [paintView setBackgroundColor:[UIColor redColor]];
            [paintView setAlpha:0.5];
            [self.takenImageView addSubview:paintView];
        }
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
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uploading Image"
                                                                           message:@"Are you sure want to upload image?"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self saveResultImage];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
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

//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    imagePickerController.delegate = self;
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    [self presentViewController:imagePickerController animated:NO completion:nil];

    NSString* imageURL = [self getImageUrl];
    [self.takenImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              if(error==nil){
                                  [self initDataUiWithImage:image];
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }
                          }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideDirtyArea];
    if(!isShowPartArea){
        isShowPartArea = true;
        UITouch *touch1 = [touches anyObject];
        CGPoint touchLocation = [touch1 locationInView:self.gridView];
        CGRect rect = [self.gridView getContainsFrame:self.takenImage withPoint:touchLocation withRowCount:5 withColCount:5];
        self.croppedImage = [self croppIngimageByImageName:self.takenImage toRect:rect];
        self.takenImageView.image = self.croppedImage;
        self.partyEngine = [[DirtyExtractor alloc] initWithImage:self.croppedImage];
        [self.valueLabel setText:[NSString stringWithFormat:@"Estimated Value: %.2f", self.partyEngine.dirtyValue]];
    }else{
        isShowPartArea = false;
        self.takenImageView.image = self.takenImage;
    }
}

- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIImage *image = [UIImage imageWithCGImage:cropped.CGImage scale:1.0 orientation:UIImageOrientationRight];
    return image;
}

- (UIImage *)gpuImageFilter:(UIImage *)image{
    GPUImageGammaFilter *filter = [[GPUImageGammaFilter alloc] init];
    [(GPUImageGammaFilter *)filter setGamma:2.0];
    image = [filter imageByFilteringImage:image];
    return image;
}

/// remove-harded code/////////////////

- (NSString *) getImageUrl{
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"smartgel-tests" ofType:@"json"];
    NSString *stringContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"\n Result = %@",stringContent);
    NSData *objectData = [stringContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    NSDictionary *imageArrayDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
    NSArray* keys=[imageArrayDict allKeys];
    
    NSLog(@"\n jsonError = %@",jsonError.description);
    NSDictionary* imageDict = [imageArrayDict objectForKey:[keys objectAtIndex:14]];
    return  [imageDict objectForKey :@"image"];
}
@end
