//
//  SGForgotPasswordViewController.h
//  SmartGel
//
//  Created by jordi on 17/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBaseViewController.h"

@interface SGForgotPasswordViewController : SGBaseViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;

@end
