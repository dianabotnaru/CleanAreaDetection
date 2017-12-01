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
        self.cleanArea = [dict objectForKey :@"cleanarea"];
        self.coloroffset = [[dict objectForKey :@"coloroffset"] intValue];
    }
    return self;
}

-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot{
    self = [super init];
    if(self){
        self.dirtyValue = [snapshot.value[@"value"] floatValue];
        self.date = snapshot.value[@"date"];
        self.location = snapshot.value[@"location"];
        self.imageUrl = snapshot.value[@"image"];
        self.cleanArea = snapshot.value[@"cleanarea"];
        self.coloroffset = [snapshot.value[@"coloroffset"] intValue];
    }
    return self;
}


- (void)setImageDataModel:(UIImage*)image
       withEstimatedValue:(float)vaule
                 withDate:(NSString*)dateString
             withLocation:(NSString*)currentLocation
           withCleanArray:(NSMutableArray *)array{
    self.image = image;
    self.dirtyValue = vaule;
    self.date = dateString;
    self.location = currentLocation;
    self.cleanArea = [self setDirtyAreaJsonString:array];
}

-(NSString *)setDirtyAreaJsonString:(NSMutableArray *)array{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSArray *)getCleanAreaArray{
    NSData* data = [self.cleanArea dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];  // if you are expecting  the JSON string to
    return values;
}


@end
