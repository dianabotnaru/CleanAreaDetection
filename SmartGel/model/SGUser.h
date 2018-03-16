//
//  SGUser.h
//  SmartGel
//
//  Created by jordi on 18/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Firebase.h"

@interface SGUser : NSObject
@property (strong, nonatomic) NSString *userID;

@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *latestLoginDate;
-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot;

@end
