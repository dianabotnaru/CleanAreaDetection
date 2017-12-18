//
//  SGUserSigninViewController.h
//  SmartGel
//
//  Created by jordi on 16/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBaseViewController.h"
#import "MBProgressHUD.h"

@interface SGUserSigninViewController : SGBaseViewController <UITextFieldDelegate>{
    MBProgressHUD *hud;
}
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *pwTextField;

@end
