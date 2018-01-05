//
//  AppDelegate.m
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "AppDelegate.h"
#import "Firebase.h"
#import "SGHomeViewController.h"
#import "SGMenuViewController.h"
#import "SGUserSigninViewController.h"
#import "SGConstant.h"
#import "SGSharedManager.h"

@interface AppDelegate () <RESideMenuDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [FIRApp configure];
    [self initNavigationbar];
    if ([FIRAuth auth].currentUser) {
        if ([SGSharedManager.sharedManager isAlreadyRunnded]) {
            self.isAreadyLoggedIn = true;
            [self initMenuViewController];
        }else{
            self.isAreadyLoggedIn = false;
        }
    }else{
        self.isAreadyLoggedIn = false;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initMenuViewController{
    
    [SGSharedManager.sharedManager setAlreadyRunnded];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SGHomeViewController *ORfeedviewcontroller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGHomeViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:ORfeedviewcontroller];
    SGMenuViewController *ORmenuviewcontroller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGMenuViewController"];
    SGMenuViewController *rightMenuViewController = [[SGMenuViewController alloc] init];
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                    leftMenuViewController:ORmenuviewcontroller
                                                                   rightMenuViewController:rightMenuViewController];
    sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    self.window.rootViewController = sideMenuViewController;
    self.window.backgroundColor = SGColorBlack;
    [self.window makeKeyAndVisible];
}

-(void)gotoSignInScreen{
    SGUserSigninViewController *signInViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGUserSigninViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:signInViewController];
    [self initNavigationbar];
    self.window.rootViewController = navigationController;
}

-(void)initNavigationbar{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:SGColorBlack];
    [[UINavigationBar appearance] setTitleTextAttributes:
    @{NSForegroundColorAttributeName:[UIColor whiteColor],
      NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18]}];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTranslucent:NO];
}
@end
