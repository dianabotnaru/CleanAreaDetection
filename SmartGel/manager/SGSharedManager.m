//
//  SGSharedManager.m
//  SmartGel
//
//  Created by jordi on 04/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import "SGSharedManager.h"

@implementation SGSharedManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        _sharedManager = [[SGSharedManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

-(void)saveTag:(SGTag *)tag{
    [[NSUserDefaults standardUserDefaults] setObject:tag.tagName forKey:SGTagName];
    [[NSUserDefaults standardUserDefaults] setObject:tag.tagImageUrl forKey:SGTagImageUrl];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(SGTag *)getTag{
    SGTag *tag = [[SGTag alloc] init];
    tag.tagName = [[NSUserDefaults standardUserDefaults] stringForKey:SGTagName];
    tag.tagImageUrl = [[NSUserDefaults standardUserDefaults] stringForKey:SGTagImageUrl];
    return tag;
}

-(void)setAlreadyRunnded{
    [[NSUserDefaults standardUserDefaults] setObject:@"isAlreadyRunnded" forKey:SGAlreadyRunned];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(bool)isAlreadyRunnded{
    NSString *alreadyRunnded = [[NSUserDefaults standardUserDefaults] stringForKey:SGAlreadyRunned];
    if(alreadyRunnded)
        return true;
    else
        return false;
}
@end
