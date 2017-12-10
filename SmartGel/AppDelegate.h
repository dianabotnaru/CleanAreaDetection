//
//  AppDelegate.h
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firebase.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) NSString *userID;

-(void)setFireDataBaseRef:(FIRDatabaseReference*)ref;
-(FIRDatabaseReference*)getFireDataBaseRef;
-(void)setFireStorageRef:(FIRStorageReference*)storageRef;
-(FIRStorageReference*)getFireStorageRef;

@end

