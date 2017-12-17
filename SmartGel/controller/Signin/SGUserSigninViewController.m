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
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate initMenuViewController];
}
@end
