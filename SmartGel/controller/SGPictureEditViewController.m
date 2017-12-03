//
//  SGPictureEditViewController.m
//  SmartGel
//
//  Created by jordi on 30/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGPictureEditViewController.h"
#import "SGConstant.h"
@interface SGPictureEditViewController ()<ACEDrawingViewDelegate>

@end

@implementation SGPictureEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.takenImageView setImage:self.takenImage];
    [self drawGridView:self.takenImage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated: YES];
}

-(void)drawGridView:(UIImage *)image{
    [self.gridContentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    self.gridView = [[SGGridView alloc] initWithFrame:[self calculateClientRectOfImageInUIImageView:self.takenImageView]];
    [self.gridView addGridViews:SGGridCount withColCount:SGGridCount];
    [self.gridContentView addSubview:self.gridView];
}

-(CGRect)calculateClientRectOfImageInUIImageView:(UIImageView *)imgView
{
    CGSize imgViewSize=imgView.frame.size;                  // Size of UIImageView
    CGSize imgSize=imgView.image.size;                      // Size of the image, currently displayed
    
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
    
    imageRect.origin.x+=imgView.frame.origin.x;
    imageRect.origin.y+=imgView.frame.origin.y;
    
    return imageRect;
}








/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
