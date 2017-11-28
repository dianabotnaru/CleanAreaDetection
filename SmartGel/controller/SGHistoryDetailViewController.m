//
//  SGHistoryDetailViewController.m
//  SmartGel
//
//  Created by jordi on 28/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGHistoryDetailViewController.h"

@interface SGHistoryDetailViewController ()

@end

@implementation SGHistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isShowDirtyArea = false;
    isShowDirtyAreaUpdatedParameter = false;
    isShowPartArea = false;
    [self initUI];
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

- (void)initUI{
    self.locationLabel.text = self.selectedEstimateImageModel.location;
    self.dateLabel.text = self.selectedEstimateImageModel.date;
    self.valueLabel.text = [NSString stringWithFormat:@"Estimated Value: %.1f", self.selectedEstimateImageModel.dirtyValue];
    [self.takenImageView sd_setImageWithURL:[NSURL URLWithString:self.selectedEstimateImageModel.imageUrl]
                                    placeholderImage:[UIImage imageNamed:@"puriSCOPE_114.png"]
                                    options:SDWebImageProgressiveDownload
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                              if (error) {
                                              } else {
                                                  self.selectedEstimateImageModel.image = image;
                                                  self.takenImageView.image = image;
                                                  self.engine = [[DirtyExtractor alloc] initWithImage:image];
                                              }
                                          }];

}

-(IBAction)showHideDirtyArea{
    if(isShowDirtyArea)
        [self hideDirtyArea];
    else
        [self showDirtyArea];
}

-(void)showDirtyArea{
    isShowDirtyArea = true;
    [self.showDirtyAreaButton setTitle:@"Hide Clean Area" forState:UIControlStateNormal];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawView :[self getDirtyAreaArray]];
        [self.hud hideAnimated:false];
    });
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

- (NSMutableArray *)getDirtyAreaArray{
    NSData* data = [self.selectedEstimateImageModel.dirtyArea dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return values;
}

-(void)hideDirtyArea{
    isShowDirtyArea = false;
    [self.showDirtyAreaButton setTitle:@"Show Clean Area" forState:UIControlStateNormal];
    [self.takenImageView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)removeImage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Are you sure to delete this image?"
                                                            preferredStyle:UIAlertControllerStyleAlert]; // 1
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userID = [FIRAuth auth].currentUser.uid;
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        FIRStorageReference *desertRef = [self.appDelegate.storageRef child:[NSString stringWithFormat:@"%@/%@.png",userID,self.selectedEstimateImageModel.date]];
        [desertRef deleteWithCompletion:^(NSError *error){
            [self.hud hideAnimated:false];
            if (error == nil) {
                [[[self.appDelegate.ref child:userID] child:self.selectedEstimateImageModel.date] removeValue];
            } else {
                [self showAlertdialog:@"Image Delete Failed!" message:error.localizedDescription];
            }
            [self backButtonClicked:nil];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

////harded code to test/////////////////////////////////////
-(IBAction)showDetailViewWithUpdatedParameter{
    if(self.takenImageView.image!=nil){
        if(!isShowDirtyAreaUpdatedParameter){
            isShowDirtyAreaUpdatedParameter = true;
            [self.showDirtyAreaButton setTitle:@"Hide Clean Area" forState:UIControlStateNormal];
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self drawView :self.engine.areaDirtyState];
                [self.hud hideAnimated:false];
            });
        }else{
            isShowDirtyAreaUpdatedParameter = false;
            [self hideDirtyArea];
        }
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch1 = [touches anyObject];
    CGPoint location = [touch1 locationInView:self.view];
    if(!CGRectContainsPoint(self.gridView.frame, location))
        return ;
    if(self.selectedEstimateImageModel.image==nil)
        return;
    [self hideDirtyArea];
    if(!isShowPartArea){
        isShowPartArea = true;
        CGPoint touchLocation = [touch1 locationInView:self.gridView];
        CGRect rect = [self.gridView getContainsFrame:self.selectedEstimateImageModel.image withPoint:touchLocation withRowCount:5 withColCount:5];
        UIImage *croppedImage = [self croppIngimageByImageName:self.selectedEstimateImageModel.image toRect:rect];
        [self initUiWithImage:croppedImage];
    }else{
        isShowPartArea = false;
        [self initUiWithImage:self.selectedEstimateImageModel.image];
    }
}

-(void)initUiWithImage:(UIImage *)image{
    self.takenImageView.image = image;
//    self.engine = [[DirtyExtractor alloc] initWithImage:image];
//    [self.valueLabel setText:[NSString stringWithFormat:@"Estimated Value: %.2f", self.engine.dirtyValue]];
}

- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIImage *image = [UIImage imageWithCGImage:cropped.CGImage scale:1.0 orientation:UIImageOrientationRight];
    return image;
}


@end
