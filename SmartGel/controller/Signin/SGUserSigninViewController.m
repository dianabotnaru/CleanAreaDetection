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
    if(![self isValidEmailAddress:self.emailTextField.text]){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return;
    }
    if([self.pwTextField.text isEqualToString:@""]){
        [self showAlertdialog:nil message:@"Please input a password"];
        return;
    }
    [self signIn];
}

- (void)signIn{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text
                           password:self.pwTextField.text
                         completion:^(FIRUser *user, NSError *error) {
                             if(error==nil){
                                 NSString *userID =user.uid;
                                 self.appDelegate.ref = [[FIRDatabase database] reference];
                                 self.appDelegate.storageRef = [[FIRStorage storage] reference];
                                 [[[self.appDelegate.ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                     self.appDelegate.user = [[SGUser alloc] initWithSnapshot:snapshot];
                                     [self.appDelegate initMenuViewController];
                                     [hud hideAnimated:false];
                                 } withCancelBlock:^(NSError * _Nonnull error) {
                                     [self showAlertdialog:nil message:error.localizedDescription];
                                     [hud hideAnimated:false];
                                 }];
                             }else{
                                 [self showAlertdialog:nil message:error.localizedDescription];
                                 [hud hideAnimated:false];
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
