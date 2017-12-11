//
//  LaboratoryDataModel.m
//  SmartGel
//
//  Created by jordi on 08/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "LaboratoryDataModel.h"

@implementation LaboratoryDataModel

-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot{
    
    self = [super init];
    if(self){
        self.resultValue = [snapshot.value[@"value"] floatValue];
        self.imageUrl = snapshot.value[@"image"];
        self.date = snapshot.value[@"date"];
        self.location = snapshot.value[@"location"];
        self.customer = snapshot.value[@"customer"];
        self.tag = snapshot.value[@"tag"];
    }
    return self;
}


@end
