//
//  SGFirebaseManager.h
//  SmartGel
//
//  Created by jordi on 22/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Firebase.h"
#import "SGUser.h"

@interface SGFirebaseManager : NSObject
+ (instancetype)sharedManager;

@property (strong, nonatomic) SGUser *currentUser;
@property (strong, nonatomic) FIRDatabaseReference *dataBaseRef;
@property (strong, nonatomic) FIRStorageReference *storageRef;

- (void)registerWithCompanyname:(NSString *)companyName
                          email:(NSString *)email
                       password:(NSString *)password
              completionHandler:(void (^)(NSError *error, SGUser *sgUser))completionHandler;

- (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
       completionHandler:(void (^)(NSError *error, SGUser *sgUser))completionHandler;
-(void)getCurrentUserwithUserID:(NSString *)userID
              completionHandler:(void (^)(NSError *error, SGUser *sgUser))completionHandler;

@end
