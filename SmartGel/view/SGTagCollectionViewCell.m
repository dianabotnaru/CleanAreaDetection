//
//  SGTagCollectionViewCell.m
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import "SGTagCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation SGTagCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setTags:(SGTag *)sgTag{
    self.tagLabel.text = sgTag.tagName;
    [self.tagImageView sd_setImageWithURL:[NSURL URLWithString:sgTag.tagImageUrl]
                           placeholderImage:[UIImage imageNamed:@""]
                                    options:SDWebImageProgressiveDownload];
}

-(IBAction)addPictureButtonTapped:(id)sender{
    if(self.delegate)
        [self.delegate addPictureButtonTapped:self.index withSender:self];
}

@end
