//
//  SGFirebaseManager.m
//  SmartGel
//
//  Created by jordi on 22/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGFirebaseManager.h"
#import "SGUtil.h"
#import "SGUser.h"

@implementation SGFirebaseManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    
    _dispatch_once(&onceToken, ^{
        _sharedManager = [[SGFirebaseManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.dataBaseRef = [[FIRDatabase database] reference];
        self.storageRef = [[FIRStorage storage] reference];
    }
    return self;
}

- (void)registerWithCompanyname:(NSString *)companyName
                          email:(NSString *)email
                       password:(NSString *)password
              completionHandler:(void (^)(NSError *error, SGUser *sgUser))completionHandler {
    
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 if(error == nil){
                                     self.currentUser = [[SGUser alloc] init];
                                     self.currentUser.userID = user.uid;
                                     self.currentUser.companyName = companyName;
                                     self.currentUser.email = user.email;
                                     self.currentUser.password = password;
                                     self.currentUser.latestLoginDate = [[SGUtil sharedUtil] getCurrentTimeString];
                                     NSDictionary *post = @{
                                                            @"userid": self.currentUser.userID,
                                                            @"email": self.currentUser.email,
                                                            @"password": self.currentUser.password,
                                                            @"companyname": self.currentUser.companyName,
                                                            @"latestdate":self.currentUser.latestLoginDate
                                                            };
                                     [[[self.dataBaseRef child:@"users"] child:self.currentUser.userID] setValue:post];
                                     completionHandler(nil, self.currentUser);
                                 }else{
                                     completionHandler(error, nil);
                                 }
                             }];
}

- (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
       completionHandler:(void (^)(NSError *error, SGUser *sgUser))completionHandler {
    
    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRUser *user, NSError *error) {
                             if(error==nil){
                                 [[[self.dataBaseRef child:@"users"] child:user.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                     self.currentUser = [[SGUser alloc] initWithSnapshot:snapshot];
                                     completionHandler(nil, self.currentUser);
                                 } withCancelBlock:^(NSError * _Nonnull error) {
                                     completionHandler(error, nil);
                                 }];
                             }else{
                                 completionHandler(error, nil);
                             }
                         }];
}

-(void)getCurrentUserwithUserID:(NSString *)userID
              completionHandler:(void (^)(NSError *error, SGUser *sgUser))completionHandler {
    [[[self.dataBaseRef child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.currentUser = [[SGUser alloc] initWithSnapshot:snapshot];
        completionHandler(nil, self.currentUser);
    } withCancelBlock:^(NSError * _Nonnull error) {
        completionHandler(error, nil);
    }];
}

-(void)saveResultImage:(EstimateImageModel *)estimateImageModel
     engineColorOffset:(int)colorOffset
     completionHandler:(void (^)(NSError *error))completionHandler {
        FIRStorageReference *riversRef = [self.storageRef child:[NSString stringWithFormat:@"%@/%@.png",self.currentUser.userID,estimateImageModel.date]];
        NSData *imageData = UIImageJPEGRepresentation(estimateImageModel.image,0.7);
        [riversRef putData:imageData
                  metadata:nil
                completion:^(FIRStorageMetadata *metadata,NSError *error) {
                    if (error != nil) {
                        completionHandler(error);
                    } else {
                        NSDictionary *post = @{
                                               @"value": [NSString stringWithFormat:@"%.2f",estimateImageModel.cleanValue],
                                               @"image": metadata.downloadURL.absoluteString,
                                               @"tag": estimateImageModel.tag,
                                               @"date": estimateImageModel.date,
                                               @"location": estimateImageModel.location,
                                               @"cleanarea": estimateImageModel.cleanArea,
                                               @"nonGelArea": estimateImageModel.nonGelArea,
                                               @"coloroffset": [NSString stringWithFormat:@"%d", colorOffset]
                                               };
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"%@/%@/%@/%@",@"users", self.currentUser.userID, @"photos",estimateImageModel.date]: post};
                        [self.dataBaseRef updateChildValues:childUpdates];
                        completionHandler(error);
                    }
                }];
}

-(void)getSmartGelHistorys:(void (^)(NSError *error,NSMutableArray* array))completionHandler {
    [[[[self.dataBaseRef child:@"users"] child:[FIRAuth auth].currentUser.uid] child:@"photos"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableArray *estimateImageArray = [NSMutableArray array];
        for(snapshot in snapshot.children){
            EstimateImageModel *estimageImageModel =  [[EstimateImageModel alloc] initWithSnapshot:snapshot];
            [estimateImageArray addObject:estimageImageModel];
        }
        completionHandler(nil,estimateImageArray);
    } withCancelBlock:^(NSError * _Nonnull error) {
        completionHandler(error,nil);
    }];
}

-(void)removeSmartGelHistory:(EstimateImageModel *)estimateImageModel
           completionHandler:(void (^)(NSError *error))completionHandler {
        NSString *userID = [FIRAuth auth].currentUser.uid;
        FIRStorageReference *desertRef = [self.storageRef child:[NSString stringWithFormat:@"%@/%@.png",userID,estimateImageModel.date]];
        [desertRef deleteWithCompletion:^(NSError *error){
            if (error == nil) {
                [[[self.dataBaseRef child:[NSString stringWithFormat:@"%@/%@/%@",@"users", userID, @"photos"]] child:estimateImageModel.date] removeValue];
            }
            completionHandler(error);
        }];
}


@end
