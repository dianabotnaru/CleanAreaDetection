//
//  SGLaboratoryCollectionViewCell.m
//  SmartGel
//
//  Created by jordi on 11/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGLaboratoryCollectionViewCell.h"

@implementation SGLaboratoryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setLaboratoryData:(LaboratoryDataModel *)laboratoryData{
    self.locationLabel.text = laboratoryData.location;
    self.dateLabel.text = laboratoryData.date;
    self.resultValueLabel.text = [NSString stringWithFormat:@"Estimated Value: %.1f", laboratoryData.resultValue];
    
    self.blankView.backgroundColor = [self getUIColorFromInt:laboratoryData.blankColor];
    self.sampleView.backgroundColor = [self getUIColorFromInt:laboratoryData.sampleColor];
}

- (UIColor *)getUIColorFromInt:(int)intValue{
    return [UIColor colorWithRed:((CGFloat)((intValue & 0xFF0000) >> 16)) / 255.0
                           green:((CGFloat)((intValue & 0xFF00) >> 8)) / 255.0
                            blue:((CGFloat)(intValue & 0xFF)) / 255.0
                           alpha:1.0];
}

@end
