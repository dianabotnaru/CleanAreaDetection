//
//  EstimateImageModel.m
//  puriSCOPE
//
//  Created by Jordi on 14/09/2017.
//
//

#import "EstimateImageModel.h"
#import "SGConstant.h"

@implementation EstimateImageModel

-(instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if(self){
        self.cleanValue = [[dict objectForKey:@"value"] floatValue];
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
        self.cleanValue = [snapshot.value[@"value"] floatValue];
        self.imageUrl = snapshot.value[@"image"];
        self.tag = snapshot.value[@"tag"];
        self.date = snapshot.value[@"date"];
        self.location = snapshot.value[@"location"];
        self.cleanArea = snapshot.value[@"cleanarea"];
        self.nonGelArea = snapshot.value[@"nonGelArea"];
        self.coloroffset = [snapshot.value[@"colorOffset"] intValue];
    }
    return self;
}

- (void)setImageDataModel:(UIImage*)image
       withEstimatedValue:(float)vaule
                 withDate:(NSString*)dateString
                  withTag:(NSString*)tag
             withLocation:(NSString*)currentLocation
           withCleanArray:(NSMutableArray *)cleanArray{
    self.image = image;
    self.cleanValue = vaule;
    self.date = dateString;
    self.tag = tag;
    self.location = currentLocation;
    self.cleanArea = [self getStringFromArray:cleanArray];
    self.nonGelArea = [self getStringFromArray:[self nonGelAreaArrayInit]];
}

- (NSMutableArray *)nonGelAreaArrayInit{
    NSMutableArray *gelAreaArray = [[NSMutableArray alloc] init];
    for(int i=0;i<SGGridCount*SGGridCount;i++){
        [gelAreaArray addObject:@(false)];
    }
    return gelAreaArray;
}


-(void)updateNonGelAreaString:(int)position{
    NSMutableArray *nonGelAreaArray = [self getArrayFromString : self.nonGelArea];
    bool isNonGelArea = [[nonGelAreaArray objectAtIndex:position] boolValue];
    [nonGelAreaArray replaceObjectAtIndex:position withObject:@(!isNonGelArea)];
    self.nonGelArea = [self getStringFromArray:nonGelAreaArray];
}

-(void)setCleanAreaWithArray:(NSMutableArray*)array{
    self.cleanArea = [self getStringFromArray:array];
}

-(NSMutableArray *)getNonGelAreaArray{
    return [self getArrayFromString:self.nonGelArea];
}

-(NSString *)getStringFromArray:(NSMutableArray *)array{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSMutableArray *)getArrayFromString:(NSString *)string{
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return values;
}
@end
