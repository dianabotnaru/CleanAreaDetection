//
//  SGPictureEditViewController.h
//  SmartGel
//
//  Created by jordi on 30/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ACEDrawingView.h>

@interface SGPictureEditViewController : UIViewController

@property (strong, nonatomic) UIImage *takenImage;
@property (strong, nonatomic) IBOutlet ACEDrawingView *aceDrawingView;
@property (strong, nonatomic) IBOutlet UIImageView *takenImageView;
@property (strong, nonatomic) IBOutlet UISlider *widthSlider;

@property (nonatomic, strong) IBOutlet UIButton *undoButton;
@property (nonatomic, strong) IBOutlet UIButton *redoButton;

@end
