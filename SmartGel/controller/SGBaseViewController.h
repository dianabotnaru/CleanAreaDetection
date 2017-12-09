//
//  SGBaseViewController.h
//  SmartGel
//
//  Created by jordi on 16/10/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SGBaseViewController : UIViewController
@property (strong, nonatomic) AppDelegate *appDelegate;

-(void)showAlertdialog:(NSString*)title message:(NSString*)message;
-(NSString *)getCurrentTimeString;

@end
