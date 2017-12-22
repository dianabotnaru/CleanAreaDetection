//
//  SGUserSigninViewController.m
//  SmartGel
//
//  Created by jordi on 16/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGUserSigninViewController.h"
#import "SGUserSignUpViewController.h"
#import "SGForgotPasswordViewController.h"
#import "SGFirebaseManager.h"
#import "SGUtil.h"

#import "AppDelegate.h"

@interface SGUserSigninViewController ()

@end

@implementation SGUserSigninViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailTextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
}

- (IBAction)signInButtonTapped{
    
    if([self.emailTextField.text isEqualToString:@""]){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return;
    }
    
    bool isVaildEmail = [[SGUtil sharedUtil] isValidEmailAddress:self.emailTextField.text];
    if(!isVaildEmail){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return ;
    }
    
    if([self.pwTextField.text isEqualToString:@""]){
        [self showAlertdialog:nil message:@"Please input a password"];
        return;
    }
    [self signIn];
}

- (void)signIn{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[SGFirebaseManager sharedManager] signInWithEmail:self.emailTextField.text
                                              password:self.pwTextField.text
                                      completionHandler:^(NSError *error, SGUser *sgUser) {
        [hud hideAnimated:false];
        if(error == nil){
            [self.appDelegate initMenuViewController];
        }else{
            [self showAlertdialog:nil message:error.localizedDescription];
        }
    }];
}

- (IBAction)signUpButtonTapped{
    SGUserSignUpViewController *signUpViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGUserSignUpViewController"];
    [self.navigationController pushViewController:signUpViewController animated:YES];
}

- (IBAction)fogotPasswordButtonTapped{
    SGForgotPasswordViewController *forgotViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGForgotPasswordViewController"];
    [self.navigationController pushViewController:forgotViewController animated:YES];
}

- (IBAction)notNowButtonTapped{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        [hud hideAnimated:false];
        if(error==nil){
            self.appDelegate.ref = [[FIRDatabase database] reference];
            self.appDelegate.storageRef = [[FIRStorage storage] reference];
            [self.appDelegate initMenuViewController];
        }else{
            [self showAlertdialog:@"Error" message:error.localizedDescription];
        }
    }];
}
@end
