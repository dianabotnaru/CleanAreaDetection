//
//  SmartGelHistoryCollectionViewCell.h
//  puriSCOPE
//
//  Created by Jordi on 14/09/2017.
//
//

#import <UIKit/UIKit.h>
#import "EstimateImageModel.h"

@interface SmartGelHistoryCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *takenImageView;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;

-(void)setEstimateData:(EstimateImageModel *)estimateImageData;

@end
