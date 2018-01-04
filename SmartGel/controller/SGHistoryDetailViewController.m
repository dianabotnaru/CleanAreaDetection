//
//  SGHistoryDetailViewController.m
//  SmartGel
//
//  Created by jordi on 28/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGHistoryDetailViewController.h"
#import "SGFirebaseManager.h"

@interface SGHistoryDetailViewController ()

@end

@implementation SGHistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDeviceRotateNotification];
    [self initDatas];
}

-(void)viewWillAppear:(BOOL)animated{
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initDatas{
    isShowDirtyArea = false;
    isShowDirtyAreaUpdatedParameter = false;
    isShowPartArea = false;
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
    if(isShowDirtyArea){
        [self hideDirtyArea];
    }
    [self drawGridView];
}

- (void)initUI{
    self.locationLabel.text = self.selectedEstimateImageModel.location;
    self.dateLabel.text = self.selectedEstimateImageModel.date;
    self.valueLabel.text = [NSString stringWithFormat:@"%.2f", self.selectedEstimateImageModel.cleanValue];
    self.dirtyLabel.text = [NSString stringWithFormat:@"%.2f", CLEAN_MAX_VALUE-self.selectedEstimateImageModel.cleanValue];
    self.tagLabel.text = self.selectedEstimateImageModel.tag;
    [self.tagImageView sd_setImageWithURL:[NSURL URLWithString:self.selectedEstimateImageModel.tagImageUrl]
                         placeholderImage:[UIImage imageNamed:@""]
                                  options:SDWebImageProgressiveDownload];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.takenImageView sd_setImageWithURL:[NSURL URLWithString:self.selectedEstimateImageModel.imageUrl]
                                    placeholderImage:[UIImage imageNamed:@"puriSCOPE_114.png"]
                                    options:SDWebImageProgressiveDownload
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                              if (error) {
                                              } else {
                                                  self.selectedEstimateImageModel.image = image;
                                                  self.takenImageView.image = image;
                                                  [self drawGridView];
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      self.engine = [[DirtyExtractor alloc] initWithImage:image];
                                                      [hud hideAnimated:YES];
                                                  });
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawView:[self getDirtyAreaArray]];
        [hud hideAnimated:false];
    });
}

-(void)drawView:(NSMutableArray*)dirtyState{
    for(int i = 0; i<(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);i++){
        int x,y;
        if(self.takenImageView.image.imageOrientation == UIImageOrientationLeft){
            y = (AREA_DIVIDE_NUMBER-1) - i/AREA_DIVIDE_NUMBER;
            x = i%AREA_DIVIDE_NUMBER;
        }else if(self.takenImageView.image.imageOrientation == UIImageOrientationRight){
            y = i/AREA_DIVIDE_NUMBER;
            x = (AREA_DIVIDE_NUMBER-1) - i%AREA_DIVIDE_NUMBER;
        }else if(self.takenImageView.image.imageOrientation == UIImageOrientationUp){
            x = i/AREA_DIVIDE_NUMBER;
            y = i%AREA_DIVIDE_NUMBER;
        }else{
            x = (AREA_DIVIDE_NUMBER-1)-i/AREA_DIVIDE_NUMBER;
            y = (AREA_DIVIDE_NUMBER-1)-i%AREA_DIVIDE_NUMBER;
        }
//        int y = i/AREA_DIVIDE_NUMBER;
//        int x = (AREA_DIVIDE_NUMBER-1) - i%AREA_DIVIDE_NUMBER;
        CGRect rect = [self calculateClientRectOfImageInUIImageView];
        
        float areaWidth = rect.size.width/AREA_DIVIDE_NUMBER;
        float areaHeight = rect.size.height/AREA_DIVIDE_NUMBER;
        
        UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(x*areaWidth+rect.origin.x, y*areaHeight+rect.origin.y, areaWidth, areaHeight)];
        if([[dirtyState objectAtIndex:i] intValue] == IS_CLEAN){
            [paintView setBackgroundColor:[UIColor redColor]];
            [paintView setAlpha:0.3];
            [self.takenImageView addSubview:paintView];
        }else if([[dirtyState objectAtIndex:i] intValue] == IS_DIRTY){
            [paintView setBackgroundColor:[UIColor blueColor]];
            [paintView setAlpha:0.2];
            [self.takenImageView addSubview:paintView];
        }
    }
}

-(CGRect)calculateClientRectOfImageInUIImageView
{
    CGSize imgViewSize=self.takenImageView.frame.size;                  // Size of UIImageView
    CGSize imgSize=self.takenImageView.image.size;                      // Size of the image, currently displayed
    CGFloat scaleW = imgViewSize.width / imgSize.width;
    CGFloat scaleH = imgViewSize.height / imgSize.height;
    CGFloat aspect=fmin(scaleW, scaleH);
    CGRect imageRect={ {0,0} , { imgSize.width*=aspect, imgSize.height*=aspect } };
    imageRect.origin.x=(imgViewSize.width-imageRect.size.width)/2;
    imageRect.origin.y=(imgViewSize.height-imageRect.size.height)/2;
    
    imageRect.origin.x+=self.takenImageView.frame.origin.x;
    imageRect.origin.y+=self.takenImageView.frame.origin.y;
    
    return imageRect;
}


- (NSMutableArray *)getDirtyAreaArray{
    NSData* data = [self.selectedEstimateImageModel.cleanArea dataUsingEncoding:NSUTF8StringEncoding];
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

- (IBAction)rightTrashButtonCliecked{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Are you sure to delete this image?"
                                                            preferredStyle:UIAlertControllerStyleAlert]; // 1
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self removeHistory];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)removeHistory{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) wself = self;
    [[SGFirebaseManager sharedManager] removeSmartGelHistory:self.selectedEstimateImageModel
                                     completionHandler:^(NSError *error) {
                                         [hud hideAnimated:false];
                                         __strong typeof(wself) sself = wself;
                                         if(sself){
                                             if(error != nil)
                                                  [self showAlertdialog:@"Image Delete Failed!" message:error.localizedDescription];
                                             else{
                                                 if(self.delegate!=nil){
                                                    [self.delegate onDeletedImage];
                                                    [self backButtonClicked:nil];
                                                 }
                                             }
                                         }
                                     }];
}

////harded code to test/////////////////////////////////////
-(IBAction)showDetailViewWithUpdatedParameter{
    if(self.takenImageView.image!=nil){
        if(!isShowDirtyAreaUpdatedParameter){
            isShowDirtyAreaUpdatedParameter = true;
            [self.showDirtyAreaButton setTitle:@"Hide Clean Area" forState:UIControlStateNormal];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self drawView :self.engine.areaCleanState];
                [hud hideAnimated:false];
            });
        }else{
            isShowDirtyAreaUpdatedParameter = false;
            [self hideDirtyArea];
        }
    }
}

-(void)drawGridView{
    [self.gridContentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    CGRect rect = [self calculateClientRectOfImageInUIImageView];
    self.gridView = [[SGGridView alloc] initWithFrame:rect];
    [self.gridView addGridViews:SGGridCount withColCount:SGGridCount];
    [self.gridContentView addSubview:self.gridView];
}
@end
