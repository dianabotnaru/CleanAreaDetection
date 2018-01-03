//
//  SGTag.h
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Firebase.h"

@interface SGTag : NSObject
@property (strong, nonatomic) NSString *tagName;
@property (strong, nonatomic) UIImage *tagImage;

-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot;
@end
