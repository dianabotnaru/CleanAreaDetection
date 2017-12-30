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
        self.cleanValue = [snapshot.value[@"value"] floatValue];
        self.imageUrl = snapshot.value[@"image"];
        self.date = snapshot.value[@"date"];
        self.location = snapshot.value[@"location"];
        self.customer = snapshot.value[@"customer"];
        self.tag = snapshot.value[@"tag"];
        self.blankColor = [snapshot.value[@"blankcolor"] intValue];
        self.sampleColor = [snapshot.value[@"samplecolor"] intValue];
        self.resultState = [snapshot.value[@"resultstate"] intValue];        
    }
    return self;
}

-(instancetype)init{
    
    self = [super init];
    if(self){
        self.cleanValue = 0;
        self.imageUrl = @"";
        self.date = @"";
        self.location = @"";
        self.customer = @"";
        self.tag = @"";
        self.unit = @"";
        self.blankColor = 0;
        self.sampleColor = 0;
        self.resultState = 0;
    }
    return self;
}


@end
