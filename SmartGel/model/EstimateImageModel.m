//
//  EstimateImageModel.m
//  puriSCOPE
//
//  Created by Jordi on 14/09/2017.
//
//

#import "EstimateImageModel.h"

@implementation EstimateImageModel

-(instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if(self){
        self.dirtyValue = [[dict objectForKey:@"value"] floatValue];
        self.date = [dict objectForKey:@"date"];
        self.location = [dict objectForKey :@"location"];
        self.imageUrl = [dict objectForKey :@"image"];
        self.dirtyArea = [dict objectForKey :@"dirtyarea"];
    }
    return self;
}

-(void)getDirtyAreaJsonString:(NSMutableArray *)array{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    self.dirtyArea = jsonString;
}

- (NSArray *)getDirtyAreaArray{
    NSData* data = [self.dirtyArea dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];  // if you are expecting  the JSON string to
    return values;
}


@end
