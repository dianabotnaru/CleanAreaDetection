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
        }
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] createUserWithEmail:self.emailTextField.text
                               password:self.pwTextField.text
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 
                                 if(error == nil){
                                     self.appDelegate.user =[self getSGUserFromFIRUser:user];
                                     self.appDelegate.ref = [[FIRDatabase database] reference];
                                     self.appDelegate.storageRef = [[FIRStorage storage] reference];
                                     NSDictionary *post = @{
                                                            @"userid": self.appDelegate.user.userID,
                                                            @"email": self.appDelegate.user.email,
                                                            @"password": self.appDelegate.user.email,
                                                            @"companyname": self.appDelegate.user.companyName,
                                                            @"latestdate": [self getCurrentTimeString]
                                                            };
                                     [[[self.appDelegate.ref child:@"users"] child:self.appDelegate.user.userID] setValue:post];
                                     [self.appDelegate initMenuViewController];
                                     [hud hideAnimated:false];
                                 }else{
                                     [self showAlertdialog:nil message:error.localizedDescription];
                                     [hud hideAnimated:false];
                                 }
                             }];
}

-(SGUser *)getSGUserFromFIRUser:(FIRUser *)user{
    SGUser *sgUser = [[SGUser alloc] init];
    sgUser.userID = user.uid;
    sgUser.companyName = self.companyNameTextField.text;
    sgUser.email = user.email;
    sgUser.password = self.pwTextField.text;
    sgUser.latestLoginDate = [self getCurrentTimeString];
    return sgUser;
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
