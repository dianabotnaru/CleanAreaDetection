//
//  SGPictureEditViewController.h
//  SmartGel
//
//  Created by jordi on 30/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ACEDrawingView.h>
#import "SGGridView.h"

@interface SGPictureEditViewController : UIViewController

@property (strong, nonatomic) UIImage *takenImage;
@property (strong, nonatomic) IBOutlet UIView *gridContentView;
@property (strong, nonatomic) SGGridView *gridView;

@property (strong, nonatomic) IBOutlet UIImageView *takenImageView;


@end
