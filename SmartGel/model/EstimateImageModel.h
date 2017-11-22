//
//  EstimateImageModel.h
//  puriSCOPE
//
//  Created by Jordi on 14/09/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EstimateImageModel : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageUrl;
@property (assign) float dirtyValue;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *dirtyArea;

@property (nonatomic,strong) NSDictionary *data;

-(instancetype)initWithDict:(NSDictionary *)dict;

@end
