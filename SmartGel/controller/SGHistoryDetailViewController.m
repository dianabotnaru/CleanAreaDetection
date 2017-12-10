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

- (void)initUI{
    self.locationLabel.text = self.selectedEstimateImageModel.location;
    self.dateLabel.text = self.selectedEstimateImageModel.date;
    self.valueLabel.text = [NSString stringWithFormat:@"Estimated Value: %.1f", self.selectedEstimateImageModel.cleanValue];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
                                                      [self.hud hideAnimated:YES];
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
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawView:[self getDirtyAreaArray]];
        [self.hud hideAnimated:false];
    });
}

-(void)drawView:(NSMutableArray*)dirtyState{
    for(int i = 0; i<(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);i++){
        int y = i/AREA_DIVIDE_NUMBER;
        int x = (AREA_DIVIDE_NUMBER-1) - i%AREA_DIVIDE_NUMBER;
        CGRect rect = [self calculateClientRectOfImageInUIImageView];
        
        float areaWidth = rect.size.width/AREA_DIVIDE_NUMBER;
        float areaHeight = rect.size.height/AREA_DIVIDE_NUMBER;
        
        UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(x*areaWidth+rect.origin.x, y*areaHeight+rect.origin.y, areaWidth, areaHeight)];
        if([[dirtyState objectAtIndex:i] intValue] == IS_CLEAN){
            [paintView setBackgroundColor:[UIColor redColor]];
            [paintView setAlpha:0.5];
            [self.takenImageView addSubview:paintView];
        }else if([[dirtyState objectAtIndex:i] intValue] == IS_DIRTY){
            [paintView setBackgroundColor:[UIColor blueColor]];
            [paintView setAlpha:0.5];
            [self.takenImageView addSubview:paintView];
        }else if([[dirtyState objectAtIndex:i] intValue] == NO_GEL){
            [paintView setBackgroundColor:[UIColor yellowColor]];
            [paintView setAlpha:0.3];
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
    
    // Note: the above is the same as :
    // CGRect imageRect=CGRectMake(0,0,imgSize.width*=aspect,imgSize.height*=aspect) I just like this notation better
    
    // Center image
    
    imageRect.origin.x=(imgViewSize.width-imageRect.size.width)/2;
    imageRect.origin.y=(imgViewSize.height-imageRect.size.height)/2;
    
    // Add imageView offset
    
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
            if(self.delegate!=nil){
                [self.delegate onDeletedImage];
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
                [self drawView :self.engine.areaCleanState];
                [self.hud hideAnimated:false];
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
