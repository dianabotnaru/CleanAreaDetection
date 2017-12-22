//
//  SGUtil.h
//  SmartGel
//
//  Created by jordi on 22/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SGUtil : NSObject
+ (instancetype)sharedUtil;

-(NSString *)getCurrentTimeString;
- (BOOL)isValidEmailAddress:(NSString *)emailAddress;
-(CGRect)calculateClientRectOfImageInUIImageView:(UIImageView*)imageView
                                      takenImage:(UIImage*)takenImage;

@end
