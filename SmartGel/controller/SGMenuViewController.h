//
//  SGMenuViewController.h
//  SmartGel
//
//  Created by jordi on 15/10/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "Firebase.h"
#import "SGBaseViewController.h"

@interface SGMenuViewController : SGBaseViewController
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@end
