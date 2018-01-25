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
@property (strong, nonatomic) NSString *tagImageUrl;

@property (assign) int coloroffset;

@property (nonatomic,strong) NSDictionary *data;

-(instancetype)initWithSnapshot:(FIRDataSnapshot *) snapshot;

- (void)setImageDataModel:(float)vaule
                 withDate:(NSString*)dateString
                  withTag:(NSString*)tag
             withLocation:(NSString*)currentLocation
           withCleanArray:(NSMutableArray *)cleanArray;
-(void)updateNonGelAreaString:(int)position;
-(NSMutableArray *)getNonGelAreaArray;
-(void)setCleanAreaWithArray:(NSMutableArray*)array;
-(void)resetNonGelArea;
-(BOOL)isNonGelArea:(int)position;
-(void)addNonGelAreaString:(int)position;

@end
