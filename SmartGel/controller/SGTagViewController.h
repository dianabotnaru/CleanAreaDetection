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

@protocol SGTagViewControllerDelegate<NSObject>
@required
- (void)didSelectTag:(SGTag *)tag;
@end

@interface SGTagViewController : SGBaseViewController <SGTagCollectionViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    bool isSelect;
}

@property (weak, nonatomic) id<SGTagViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (strong, nonatomic) NSMutableArray *tagArray;
@property (strong, nonatomic) SGTag *selectedTag;
@property (assign, nonatomic) SGTagCollectionViewCell *selectedCell;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *trashBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectBarButtonItem;

@end
