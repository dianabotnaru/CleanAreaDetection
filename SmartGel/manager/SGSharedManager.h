//
//  SGSharedManager.h
//  SmartGel
//
//  Created by jordi on 04/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGTag.h"

#define SGTagName @"tagName"
#define SGTagImageUrl @"tagImageUrl"

@interface SGSharedManager : NSObject
+ (instancetype)sharedManager;

-(void)saveTag:(SGTag *)tag;
-(SGTag *)getTag;
@end
