//
//  SGTagCollectionViewCell.h
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGTag.h"

@protocol SGTagCollectionViewCellDelegate<NSObject>
@required
- (void)addPictureButtonTapped:(NSInteger)index withSender:(UICollectionViewCell *)sender;
@end


@interface SGTagCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) id<SGTagCollectionViewCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *tagImageView;
@property (strong, nonatomic) IBOutlet UIButton *addPictureButton;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;
@property (assign, nonatomic) int index;


-(void)setTags:(SGTag *)sgTag;

@end
