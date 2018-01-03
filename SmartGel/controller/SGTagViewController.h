//
//  SGTagViewController.h
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBaseViewController.h"
#import "SGTagCollectionViewCell.h"

@interface SGTagViewController : SGBaseViewController <SGTagCollectionViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (strong, nonatomic) NSMutableArray *tagArray;
@property (strong, nonatomic) SGTag *selectedTag;
@property (assign, nonatomic) SGTagCollectionViewCell *selectedCell;

@end
