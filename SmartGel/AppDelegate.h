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
@property (strong, nonatomic) UIStoryboard *storyboard;

@property (assign, nonatomic) bool isLoggedIn;

- (void)initMenuViewController;
-(void)gotoSignInScreen;

@end

