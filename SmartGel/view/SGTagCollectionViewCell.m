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
    [self initDeselectedUi];
}

-(IBAction)addPictureButtonTapped:(id)sender{
    if(self.delegate)
        [self.delegate addPictureButtonTapped:self.index withSender:self];
}

-(void)initSelectedUi{
    self.selectedState = YES;
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = SGColorDarkGreen.CGColor;
    [self.selectImageView setHidden:false];
    [self.maskView setHidden:false];
}

-(void)initDeselectedUi{
    self.selectedState = NO;
    self.layer.borderWidth = 0.0;
    [self.selectImageView setHidden:true];
    [self.maskView setHidden:true];
}
@end
