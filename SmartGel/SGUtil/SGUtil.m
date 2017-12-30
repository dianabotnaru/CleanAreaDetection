//
//  SGUtil.m
//  SmartGel
//
//  Created by jordi on 22/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGUtil.h"

@implementation SGUtil

+ (instancetype)sharedUtil {
    static id _sharedUtil = nil;
    static dispatch_once_t onceToken;
    
    _dispatch_once(&onceToken, ^{
        _sharedUtil = [[SGUtil alloc] init];
    });
    
    return _sharedUtil;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

-(NSString *)getCurrentTimeString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    return dateString;
}

- (NSString *)getDateString:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd,yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

- (NSDate *)getDateFromString:(NSString*)dateString{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [formatter dateFromString:dateString];
    return [self getLocalTime:date];
}

- (NSDate *)getLocalTime:(NSDate *)date{
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [date dateByAddingTimeInterval:timeZoneSeconds];
    return dateInLocalTimezone;
}


- (BOOL)isValidEmailAddress:(NSString *)emailAddress {
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc]
                                  initWithPattern:regExPattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailAddress
                                                     options:0
                                                       range:NSMakeRange(0, [emailAddress length])];
    return (regExMatches == 0) ? NO : YES ;
}

-(CGRect)calculateClientRectOfImageInUIImageView:(UIImageView*)imageView
                                      takenImage:(UIImage*)takenImage
{
    CGSize imgViewSize=imageView.frame.size;                  // Size of UIImageView
    CGSize imgSize=takenImage.size;                      // Size of the image, currently displayed
    CGFloat scaleW = imgViewSize.width / imgSize.width;
    CGFloat scaleH = imgViewSize.height / imgSize.height;
    CGFloat aspect=fmin(scaleW, scaleH);
    CGRect imageRect={ {0,0} , { imgSize.width*=aspect, imgSize.height*=aspect } };
    imageRect.origin.x=(imgViewSize.width-imageRect.size.width)/2;
    imageRect.origin.y=(imgViewSize.height-imageRect.size.height)/2;
    imageRect.origin.x+=imageView.frame.origin.x;
    imageRect.origin.y+=imageView.frame.origin.y;
    return imageRect;
}

-(NSMutableArray *)sortbyKey:(NSMutableArray *)mutableArray
                     withKey:(NSString *)sortKey{
    NSArray *array = [[NSArray alloc] initWithArray:mutableArray];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey
                                                 ascending:YES];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:@[sortDescriptor]];
    mutableArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    return mutableArray;
}

@end
