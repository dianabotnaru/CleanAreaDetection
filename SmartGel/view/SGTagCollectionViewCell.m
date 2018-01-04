//
//  SGTagCollectionViewCell.m
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import "SGTagCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "SGConstant.h"

@implementation SGTagCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setTags:(SGTag *)sgTag{
    self.tagLabel.text = sgTag.tagName;
    [self.tagImageView sd_setImageWithURL:[NSURL URLWithString:sgTag.tagImageUrl]
                           placeholderImage:[UIImage imageNamed:@""]
                                    options:SDWebImageProgressiveDownload];
    [self initSelectedUi];
}

-(IBAction)addPictureButtonTapped:(id)sender{
    if(self.delegate)
        [self.delegate addPictureButtonTapped:self.index withSender:self];
}

-(void)initSelectedUi{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = SGColorDarkGreen.CGColor;
    [self.selectImageView setHidden:false];
}

-(void)initDeselectedUi{
    [self.selectImageView setHidden:true];
}
@end
