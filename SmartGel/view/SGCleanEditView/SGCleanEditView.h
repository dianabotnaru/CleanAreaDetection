//
//  SGCleanEditView.h
//  SmartGel
//
//  Created by jordi on 02/02/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGGridView.h"

@interface SGCleanEditView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) UIImageView *imgview;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *gridContentView;

@property (strong, nonatomic) SGGridView *gridView;

@property (strong, nonatomic) NSMutableArray *cleanareaViews;
@property (strong, nonatomic) NSMutableArray *orignialcleanareaViews;
@property (strong, nonatomic) UIImage *takenImage;

@property (nonatomic) BOOL zoomed;
-(void)setImage:(UIImage *)image
 withCleanArray: (NSMutableArray *)cleanArray;

@end
