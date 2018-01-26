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

-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot{
    self = [super init];
    if(self){
        self.cleanValue = [snapshot.value[@"value"] floatValue];
        self.imageUrl = snapshot.value[@"image"];
        self.tag = snapshot.value[@"tag"];
        self.tagImageUrl = snapshot.value[@"tagImageUrl"];
        self.date = snapshot.value[@"date"];
        self.location = snapshot.value[@"location"];
        self.cleanArea = snapshot.value[@"cleanarea"];
        self.nonGelArea = snapshot.value[@"nonGelArea"];
        self.coloroffset = [snapshot.value[@"colorOffset"] intValue];
    }
    return self;
}

- (void)setImageDataModel:(float)vaule
                 withDate:(NSString*)dateString
                  withTag:(NSString*)tag
             withLocation:(NSString*)currentLocation
           withCleanArray:(NSMutableArray *)cleanArray{
    self.cleanValue = vaule;
    self.date = dateString;
    self.tag = tag;
    self.location = currentLocation;
    self.cleanArea = [self getStringFromArray:cleanArray];
    self.nonGelArea = [self getStringFromArray:[self nonGelAreaArrayInit]];
    self.manualCleanlArea = [self getStringFromArray:[self nonGelAreaArrayInit]];
}

-(void)resetNonGelArea{
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

-(void)updateManualCleanAreaString:(int)position{
    NSMutableArray *manualCleanAreaArray = [self getArrayFromString : self.manualCleanlArea];
    bool isManualCleanArea = [[manualCleanAreaArray objectAtIndex:position] boolValue];
    [manualCleanAreaArray replaceObjectAtIndex:position withObject:@(!isManualCleanArea)];
    self.manualCleanlArea = [self getStringFromArray:manualCleanAreaArray];
}


-(void)addNonGelAreaString:(int)position
                withState :(BOOL)isNonGelArea{
    NSMutableArray *nonGelAreaArray = [self getArrayFromString : self.nonGelArea];
    [nonGelAreaArray replaceObjectAtIndex:position withObject:@(false)];
    self.nonGelArea = [self getStringFromArray:nonGelAreaArray];
}


-(BOOL)isNonGelArea:(int)position{
    NSMutableArray *nonGelAreaArray = [self getArrayFromString : self.nonGelArea];
    return [[nonGelAreaArray objectAtIndex:position] boolValue];
}

-(BOOL)isManualCleanlArea:(int)position{
    NSMutableArray *manualCleanAreaArray = [self getArrayFromString : self.manualCleanlArea];
    return [[manualCleanAreaArray objectAtIndex:position] boolValue];
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
