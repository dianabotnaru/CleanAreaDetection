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
    self.valueLabel.text = [NSString stringWithFormat:@"Estimated Value: %.1f", estimateImageData.dirtyValue];
    [self.takenImageView sd_setImageWithURL:[NSURL URLWithString:estimateImageData.imageUrl]
                 placeholderImage:[UIImage imageNamed:@"puriSCOPE_114.png"]];
    
}

@end
