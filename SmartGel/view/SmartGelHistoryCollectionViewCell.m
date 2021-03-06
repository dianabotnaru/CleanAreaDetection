//
//  SmartGelHistoryCollectionViewCell.m
//  puriSCOPE
//
//  Created by Jordi on 14/09/2017.
//
//

#import "SmartGelHistoryCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation SmartGelHistoryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 3;
    // Initialization code
}

-(void)setEstimateData:(EstimateImageModel *)estimateImageData{
    self.locationLabel.text = estimateImageData.location;
    self.dateLabel.text = estimateImageData.date;
    self.tagLabel.text = estimateImageData.tag;
    self.valueLabel.text = [NSString stringWithFormat:@"Estimated Value: %.2f", estimateImageData.cleanValue];
    [self.takenImageView sd_setImageWithURL:[NSURL URLWithString:estimateImageData.imageUrl]
                           placeholderImage:[UIImage imageNamed:@"puriSCOPE_114.png"]
                                    options:SDWebImageProgressiveDownload];
}
@end

