//
//  SGUserSignUpViewController.m
//  SmartGel
//
//  Created by jordi on 17/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGUserSignUpViewController.h"
#import "SGUserSigninViewController.h"
#import "AppDelegate.h"

@interface SGUserSignUpViewController ()

@end

@implementation SGUserSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)signUpButtonTapped{
    if([self.emailTextField.text isEqualToString:@""]){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return;
    }
    if(![self isValidEmailAddress:self.emailTextField.text]){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return;
    }
    [[FIRAuth auth] createUserWithEmail:self.emailTextField.text
                               password:self.pwTextField.text
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 
                             }];
}

- (IBAction)notNowButtonTapped{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate initMenuViewController];
}

- (IBAction)signInButtonTapped{
    [self.navigationController popViewControllerAnimated: YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.companyNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
}
@end
