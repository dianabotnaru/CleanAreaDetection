//
//  LaboratoryDataModel.h
//  SmartGel
//
//  Created by jordi on 08/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaboratoryDataModel : NSObject

@property (strong, nonatomic) NSString *imageUrl;
@property (assign, nonatomic) float resultValue;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *unit;
@property (strong, nonatomic) NSString *tag;
//@property (strong, nonatomic) NSString *customer;

@end
