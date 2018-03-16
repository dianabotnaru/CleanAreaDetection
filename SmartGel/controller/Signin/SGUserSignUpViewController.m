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
#import "SGConstant.h"
#import "SGFirebaseManager.h"
#import "SGUtil.h"

@interface SGUserSignUpViewController ()

@end

@implementation SGUserSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)signUpButtonTapped{
    if([self checkInputValidation]){
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[SGFirebaseManager sharedManager] registerWithCompanyname:self.companyNameTextField.text email:self.emailTextField.text password:self.pwTextField.text completionHandler:^(NSError *error, SGUser *sgUser) {
            [hud hideAnimated:false];
            if(error == nil){
               [self.appDelegate initMenuViewController];
            }else{
                [self showAlertdialog:nil message:error.localizedDescription];
            }
        }];
    }
}

-(BOOL)checkInputValidation{
    if([self.emailTextField.text isEqualToString:@""]){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return false;
    }
    bool isVaildEmail = [[SGUtil sharedUtil] isValidEmailAddress:self.emailTextField.text];
    if(!isVaildEmail){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return false;
    }
    if([self.pwTextField.text isEqualToString:@""]){
        [self showAlertdialog:nil message:@"Please input a password"];
        return false;
    }
    return true;
}

- (IBAction)notNowButtonTapped{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        [hud hideAnimated:false];
        if(error==nil){
            [self.appDelegate initMenuViewController];
        }else{
            [self showAlertdialog:@"Error" message:error.localizedDescription];
        }
    }];
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

- (void)keyboardWillShow:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.25 animations:^
     {
         CGRect newFrame = [self.view frame];
         if (newFrame.origin.y==0){
             newFrame.origin.y -= 100; // tweak here to adjust the moving position
             [self.view setFrame:newFrame];
         }
     }completion:^(BOOL finished)
     {
         
     }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.25 animations:^
     {
         CGRect newFrame = [self.view frame];
         if (newFrame.origin.y!=0){
             newFrame.origin.y += 100; // tweak here to adjust the moving position
             [self.view setFrame:newFrame];
         }
     }completion:^(BOOL finished)
     {
         
     }];
}

@end
