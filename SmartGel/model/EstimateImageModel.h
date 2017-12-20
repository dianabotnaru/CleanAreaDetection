//
//  EstimateImageModel.h
//  puriSCOPE
//
//  Created by Jordi on 14/09/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Firebase.h"

@interface EstimateImageModel : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageUrl;
@property (assign) float cleanValue;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *cleanArea;
@property (strong, nonatomic) NSString *dirtyArea;
@property (strong, nonatomic) NSString *nonGelArea;
@property (strong, nonatomic) NSString *tag;


@property (assign) int coloroffset;

@property (nonatomic,strong) NSDictionary *data;

-(instancetype)initWithDict:(NSDictionary *)dict;
-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot;

- (void)setImageDataModel:(UIImage*)image
       withEstimatedValue:(float)vaule
                 withDate:(NSString*)dateString
             withLocation:(NSString*)currentLocation
           withCleanArray:(NSMutableArray *)cleanArray
          withNonGelArray:(NSMutableArray *)nonGelArray;
-(void)updateNonGelAreaString:(int)position;
-(NSMutableArray *)getNonGelAreaArray;
-(void)setCleanAreaWithArray:(NSMutableArray*)array;


@end
