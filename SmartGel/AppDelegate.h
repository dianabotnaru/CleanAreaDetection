//
//  AppDelegate.h
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firebase.h"
#import "SGUser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) SGUser *user;

@property (assign, nonatomic) bool isAreadyLoggedIn;

-(void)setFireDataBaseRef:(FIRDatabaseReference*)ref;
-(FIRDatabaseReference*)getFireDataBaseRef;
-(void)setFireStorageRef:(FIRStorageReference*)storageRef;
-(FIRStorageReference*)getFireStorageRef;
- (void)initMenuViewController;
-(void)gotoSignInScreen;

@end

