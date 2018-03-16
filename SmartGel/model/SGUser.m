//
//  SGUser.m
//  SmartGel
//
//  Created by jordi on 18/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGUser.h"
#import "SGUtil.h"

@implementation SGUser
-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot{
    
    self = [super init];
    if(self){
        self.userID = snapshot.value[@"userid"];
        self.email = snapshot.value[@"email"];
        self.companyName = snapshot.value[@"companyname"];
        self.latestLoginDate = snapshot.value[@"latestdate"];
    }
    return self;
}

@end
