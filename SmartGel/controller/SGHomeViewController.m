//
//  SGHomeViewController.m
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGHomeViewController.h"
#import "SGConstant.h"
#import "AppDelegate.h"
#import "SGFirebaseManager.h"
#import "SGUtil.h"
#import "SCLAlertView.h"
#import "SGTagViewController.h"
#import "UIImageView+WebCache.h"
#import "SGSharedManager.h"

@interface SGHomeViewController ()

@end

@implementation SGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (([FIRAuth auth].currentUser)&&(([SGSharedManager.sharedManager isAlreadyRunnded])) ) {
        [self getCurrentUser];
    }else{
        [self anonymouslySignIn];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(isTakenPhoto){
        [self initDataUiWithImage];
        isTakenPhoto = false;
        [hud hideAnimated:false];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)homeScreenInit{
    [self initData];
    [self initSelectedTag:[SGSharedManager.sharedManager getTag]];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self initDeviceRotateNotification];
}

-(void)initDeviceRotateNotification{
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification
             object:device];
}

- (void)orientationChanged:(NSNotification *)note
{
    if(self.estimateImage!=nil){
        if(isShowDirtyArea){
           [self hideDirtyArea];
        }
        [self.cleanareaViews removeAllObjects];
        [self drawGridView];
        [self initCleanareaViews: self.engine.areaCleanState];
    }
}

- (void)initData{
    isSavedImage = false;
    isTakenPhoto = false;
    isAddCleanArea = false;
    self.engine = [[DirtyExtractor alloc] init];
    [self initLocationManager];
    self.cleanareaViews = [NSMutableArray array];
    [self.dateLabel setText:[[SGUtil sharedUtil] getCurrentTimeString]];
}

-(void)getCurrentUser{
    if([SGFirebaseManager sharedManager].currentUser == nil){
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self) wself = self;
        [[SGFirebaseManager sharedManager] getCurrentUserwithUserID:[FIRAuth auth].currentUser.uid
                                                  completionHandler:^(NSError *error, SGUser *sgUser) {
                                                      __strong typeof(wself) sself = wself;
                                                      if(sself){
                                                          [hud hideAnimated:false];
                                                          if (error!= nil){
                                                              [sself showAlertdialog:@"Error" message:error.localizedDescription];
                                                          }else{
                                                              [self homeScreenInit];
                                                          }
                                                      }
                                                  }];
    }else{
        [self homeScreenInit];
   }
}

- (void)anonymouslySignIn{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        if(error == nil){
            [[SGFirebaseManager sharedManager] registerWithFireUser:user
                                             completionHandler:^(NSError *error, SGUser *sgUser) {
                                                 [hud hideAnimated:false];
                                                 if(error != nil){
                                                     [self showAlertdialog:nil message:error.localizedDescription];
                                                 }else{
                                                    if(![SGSharedManager.sharedManager isAlreadyRunnded]){
                                                         [SGSharedManager.sharedManager setAlreadyRunnded];
                                                    }
                                                    [self homeScreenInit];
                                                 }
                                             }];
        }else{
            [hud hideAnimated:false];
            [self showAlertdialog:nil message:error.localizedDescription];
        }
    }];
}

-(void)showNoConnectionAlertdialog{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ATTENTION"
                                                                   message:@"No connection, Please check your network settings and retry"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (([FIRAuth auth].currentUser)&&(([SGSharedManager.sharedManager isAlreadyRunnded])) ) {
            [self getCurrentUser];
        }else{
            [self anonymouslySignIn];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}



-(void)setLabelsWithEstimateData{
    if(!self.notificationLabel.isHidden)
        [self.notificationLabel setHidden:YES];
    [self.takenImageView setImage:self.estimateImage.image];
    [self.dateLabel setText:[[SGUtil sharedUtil] getCurrentTimeString]];
    [self.valueLabel setText:[NSString stringWithFormat:@"%.2f", self.estimateImage.cleanValue]];
    [self.dirtyvalueLabel setText:[NSString stringWithFormat:@"%.2f", CLEAN_MAX_VALUE - self.estimateImage.cleanValue]];
}

-(void)drawGridView{
    [self.gridContentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    CGRect rect = [[SGUtil sharedUtil] calculateClientRectOfImageInUIImageView:self.takenImageView takenImage:self.estimateImage.image];
    self.gridView = [[SGGridView alloc] initWithFrame:rect];
    [self.gridView addGridViews:SGGridCount withColCount:SGGridCount];
    [self.gridContentView addSubview:self.gridView];
}

-(void)showCleanAndDirtyArea{
    isShowDirtyArea = true;
    [self.notificationLabel setHidden:YES];
    [self.showCleanAreaLabel setText:@"Hide clean area"];
    [self.showCleanAreaButton setBackgroundColor:SGColorDarkGreen];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i<self.cleanareaViews.count; i++) {
            UIView *view = [self.cleanareaViews objectAtIndex:i];
            if([[self.engine.areaCleanState objectAtIndex:i] intValue] != NO_GEL)
                [self.takenImageView addSubview:view];
        }
        [hud hideAnimated:false];
    });
}

-(void)hideDirtyArea{
    isShowDirtyArea = false;
    [self.notificationLabel setHidden:NO];
    [self.showCleanAreaLabel setText:@"Show clean area"];
    [self.showCleanAreaButton setBackgroundColor:SGColorDarkPink];
    for (int i = 0; i<self.cleanareaViews.count; i++) {
        UIView *view = [self.cleanareaViews objectAtIndex:i];
        [view removeFromSuperview];
    }
}

-(void)initCleanareaViews:(NSMutableArray*)dirtyState{
    [self.cleanareaViews removeAllObjects];
    CGRect rect = [[SGUtil sharedUtil] calculateClientRectOfImageInUIImageView:self.takenImageView takenImage:self.estimateImage.image];
    float areaWidth = rect.size.width/AREA_DIVIDE_NUMBER;
    float areaHeight = rect.size.height/AREA_DIVIDE_NUMBER;
    for(int i = 0; i<(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);i++){
        int x,y;
        if(self.estimateImage.image.imageOrientation == UIImageOrientationLeft){
            y = (AREA_DIVIDE_NUMBER-1) - i/AREA_DIVIDE_NUMBER;
            x = i%AREA_DIVIDE_NUMBER;
        }else if(self.estimateImage.image.imageOrientation == UIImageOrientationRight){
            y = i/AREA_DIVIDE_NUMBER;
            x = (AREA_DIVIDE_NUMBER-1) - i%AREA_DIVIDE_NUMBER;
        }else if(self.estimateImage.image.imageOrientation == UIImageOrientationUp){
            x = i/AREA_DIVIDE_NUMBER;
            y = i%AREA_DIVIDE_NUMBER;
        }else{
            x = (AREA_DIVIDE_NUMBER-1)-i/AREA_DIVIDE_NUMBER;
            y = (AREA_DIVIDE_NUMBER-1)-i%AREA_DIVIDE_NUMBER;
        }
        UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(x*areaWidth+rect.origin.x, y*areaHeight+rect.origin.y, areaWidth, areaHeight)];
        if([[dirtyState objectAtIndex:i] intValue] == IS_CLEAN){
            [paintView setBackgroundColor:[UIColor redColor]];
            [paintView setAlpha:0.3];
        }else if([[dirtyState objectAtIndex:i] intValue] == IS_DIRTY){
            [paintView setBackgroundColor:[UIColor blueColor]];
            [paintView setAlpha:0.2];
        }
        [self.cleanareaViews addObject:paintView];
    }
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
            [self showSaveAlertView];
        }
    }
}

- (void)saveResultImage{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[SGFirebaseManager sharedManager] saveResultImage:self.estimateImage
                                            selectedTag:self.selectedTag
                                    engineColorOffset :self.engine.m_colorOffset
                                     completionHandler:^(NSError *error) {
                                         [hud hideAnimated:false];
                                         if(error == nil){
                                             isSavedImage = true;
                                             [self showAlertdialog:@"Image Uploading Success!" message:error.localizedDescription];
                                         }else{
                                             [self showAlertdialog:@"Image Uploading Failed!" message:error.localizedDescription];
                                         }
                                     }];
}

-(IBAction)showHideCleanArea{
    if(self.estimateImage.image == nil){
        [self showAlertdialog:nil message:@"Please take a photo."];
        return;
    }
    if(isShowDirtyArea)
        [self hideDirtyArea];
    else
        [self showCleanAndDirtyArea];
}

-(IBAction)resetNonGelAreaTapped:(id)sender{
    if(self.estimateImage.image == nil){
        [self showAlertdialog:nil message:@"Please take a photo."];
        return;
    }
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isShowDirtyArea)
        [self hideDirtyArea];
        [self initDataUiWithImage];
        [hud hideAnimated:false];
    });
}

-(IBAction)launchPhotoPickerController{
    if(!self.selectedTag.tagName){
//        [self showAlertdialog:nil message:@"Please select a tag"];
//        return;
        self.selectedTag = [[SGTag alloc] init];
    }
    if(isShowDirtyArea)
        [self hideDirtyArea];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:NO completion:nil];
    
//    self.estimateImage = [[EstimateImageModel alloc] init];
//    self.estimateImage.image = [UIImage imageNamed:@"test.png"];
//    isTakenPhoto = true;
//    [self initDataUiWithImage];

//    NSString* imageURL = [self getImageUrl:3];
//    [self.takenImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
//                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                              if(error==nil){
//                                  [self initDataUiWithImage:image];
//                              }
//                          }];
}

-(IBAction)addManualAreaButtonTapped{
    if(isAddCleanArea){
        isAddCleanArea = false;
        [self.addManualAreaLabel setText:@"Add Clean Area"];
        [self.addManualAreaButton setBackgroundColor:SGColorDarkPink];
    }else{
        isAddCleanArea = true;
        [self.addManualAreaLabel setText:@"Add Non-Gel Area"];
        [self.addManualAreaButton setBackgroundColor:SGColorLigtGray];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    self.estimateImage = [[EstimateImageModel alloc] init];
    self.estimateImage.image = image;
    isTakenPhoto = true;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initDataUiWithImage{
    [self.cleanareaViews removeAllObjects];
    isSavedImage = false;
    self.engine = [[DirtyExtractor alloc] initWithImage:self.estimateImage.image];
    [self.estimateImage setImageDataModel:self.engine.cleanValue withDate:self.dateLabel.text withTag:self.tagLabel.text withLocation:self.locationLabel.text  withCleanArray:self.engine.areaCleanState];
    [self setLabelsWithEstimateData];
    [self drawGridView];
    [self initCleanareaViews: self.engine.areaCleanState];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch1 = [touches anyObject];
    CGPoint location = [touch1 locationInView:self.imageareaView];

    if(CGRectContainsPoint(self.tagImageView.frame, location)){
        [self imgToFullScreen];
        return ;
    }
    
    if(isShowDirtyArea){
        if(!CGRectContainsPoint(self.gridContentView.frame, location))
            return ;
        if(self.estimateImage==nil)
            return;
        CGPoint touchLocation = [touch1 locationInView:self.gridView];
        int touchPosition = [self.gridView getContainsFrame:self.estimateImage.image withPoint:touchLocation withRowCount:SGGridCount withColCount:SGGridCount];
        if(touchPosition != -1){
            if(isAddCleanArea)
                [self addManualPinkArea:touchPosition];
            else
                [self addManualNonGelArea:touchPosition];
        }
    }
}

-(void)addManualNonGelArea:(int)touchPosition{
    [self.estimateImage updateNonGelAreaString:touchPosition];
    [self.engine setNonGelAreaState:[self.estimateImage getNonGelAreaArray]];
    [self.estimateImage setCleanAreaWithArray:self.engine.areaCleanState];
    
    int pointX = touchPosition/SGGridCount;
    int pointY = touchPosition%SGGridCount;
    [self updateNonGelAreaViews:pointX withPointY:pointY];
}

-(void)addManualPinkArea:(int)touchPosition{
    [self.engine addCleanArea:touchPosition];
    [self.estimateImage setCleanAreaWithArray:self.engine.areaCleanState];
    int pointX = touchPosition/SGGridCount;
    int pointY = touchPosition%SGGridCount;
    [self addManualPinkAreaViews:pointX withPointY:pointY];
}

-(void)updateNonGelAreaViews:(int)pointX
                 withPointY:(int)pointY{
    int rate = AREA_DIVIDE_NUMBER/SGGridCount;
    for(int i = 0; i<rate;i++){
        for(int j = 0; j< rate; j++){
            NSUInteger postion = AREA_DIVIDE_NUMBER*rate*pointX+(i*AREA_DIVIDE_NUMBER)+(rate*pointY+j);
            UIView *view = [self.cleanareaViews objectAtIndex:postion];
            [view removeFromSuperview];
        }
    }
    [self.valueLabel setText:[NSString stringWithFormat:@"%.2f", self.engine.cleanValue]];
    [self.dirtyvalueLabel setText:[NSString stringWithFormat:@"%.2f", CLEAN_MAX_VALUE - self.engine.cleanValue]];
    self.estimateImage.cleanValue = self.engine.cleanValue;
}

-(void)addManualPinkAreaViews:(int)pointX
                   withPointY:(int)pointY{
    
    int rate = AREA_DIVIDE_NUMBER/SGGridCount;
    for(int i = 0; i<rate;i++){
        for(int j = 0; j< rate; j++){
            NSUInteger postion = AREA_DIVIDE_NUMBER*rate*pointX+(i*AREA_DIVIDE_NUMBER)+(rate*pointY+j);
            UIView *view = [self.cleanareaViews objectAtIndex:postion];
            [view removeFromSuperview];
            [view setBackgroundColor:[UIColor redColor]];
            [view setAlpha:0.3];
            [self.cleanareaViews replaceObjectAtIndex:postion withObject:view];
            [self.takenImageView addSubview:view];
        }
    }

    [self.valueLabel setText:[NSString stringWithFormat:@"%.2f", self.engine.cleanValue]];
    [self.dirtyvalueLabel setText:[NSString stringWithFormat:@"%.2f", CLEAN_MAX_VALUE - self.engine.cleanValue]];
    self.estimateImage.cleanValue = self.engine.cleanValue;
}

-(IBAction)btnTagIndicatorTapped:(id)sender{
    SGTagViewController *tagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGTagViewController"];
    tagVC.delegate = self;
    [self.navigationController pushViewController:tagVC animated:YES];
}

- (void)showSaveAlertView{
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = SGColorBlack;
    alert.iconTintColor = [UIColor whiteColor];
    alert.tintTopCircle = NO;
    alert.backgroundViewColor = SGColorDarkGray;
    alert.view.backgroundColor = SGColorDarkGray;
    alert.backgroundType = SCLAlertViewBackgroundTransparent;
    
    alert.labelTitle.textColor = [UIColor whiteColor];
    
    UITextField *tagTextField = [alert addTextField:self.estimateImage.tag];
    [tagTextField setText:self.estimateImage.tag];
    [tagTextField setEnabled:false];
    [tagTextField setBackgroundColor:[UIColor clearColor]];
    [tagTextField setTextColor:[UIColor lightGrayColor]];

    UITextField *customerTextField = [alert addTextField:[SGFirebaseManager sharedManager].currentUser.email];
    [customerTextField setText:[SGFirebaseManager sharedManager].currentUser.email];
    [customerTextField setEnabled:false];
    [customerTextField setBackgroundColor:[UIColor clearColor]];
    [customerTextField setTextColor:[UIColor lightGrayColor]];

    [alert addButton:@"Done" actionBlock:^(void) {
        [self saveResultImage];
    }];
    [alert.viewText setTextColor:[UIColor whiteColor]];
    [alert showEdit:self title:@"Uploading Image?" subTitle:@"Are you sure want to upload image?" closeButtonTitle:@"Cancel" duration:0.0f];
}

- (void)didSelectTag:(SGTag *)tag{
    [self initSelectedTag:tag];
    [SGSharedManager.sharedManager saveTag:tag];
}

-(void)initSelectedTag:(SGTag *)tag{
    self.selectedTag = tag;
    if(self.selectedTag.tagName){
        self.tagLabel.text = tag.tagName;
    }else{
        self.tagLabel.text = @"No Tag";
    }
    [self.tagImageView sd_setImageWithURL:[NSURL URLWithString:tag.tagImageUrl]
                         placeholderImage:[UIImage imageNamed:@""]
                                  options:SDWebImageProgressiveDownload];

}

-(void)imgToFullScreen{
    if (!isFullScreen) {

        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //save previous frame
            prevFrame = self.tagImageView.frame;
            [self.tagImageView setFrame:[[UIScreen mainScreen] bounds]];
        }completion:^(BOOL finished){
            isFullScreen = true;
        }];
        return;
    } else {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            [self.tagImageView setFrame:prevFrame];
        }completion:^(BOOL finished){
            isFullScreen = false;
        }];
        return;
    }
}


@end
