//
//  SGTag.m
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import "SGTag.h"

@implementation SGTag

-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot{
    self = [super init];
    if(self){
        self.tagId = snapshot.value[@"key"];
        self.tagName = snapshot.value[@"name"];
        self.tagImageUrl = snapshot.value[@"image"];
    }
    return self;
}

@end
