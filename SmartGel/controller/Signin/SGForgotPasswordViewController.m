//
//  SGForgotPasswordViewController.m
//  SmartGel
//
//  Created by jordi on 17/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGForgotPasswordViewController.h"
#import "Firebase.h"

@interface SGForgotPasswordViewController ()

@end

@implementation SGForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)submitButtonTapped{
    if([self.emailTextField.text isEqualToString:@""]){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return;
    }
    if(![self isValidEmailAddress:self.emailTextField.text]){
        [self showAlertdialog:nil message:@"Please input a valid email"];
        return;
    }
    [self submitForgotPassword];
}

-(void)submitForgotPassword{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] sendPasswordResetWithEmail:self.emailTextField.text completion:^(NSError *_Nullable error) {
        if(error!=nil){
            [self showAlertdialog:nil message:error.localizedDescription];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:@"Submit success! Please check out your email."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated: YES];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        [hud hideAnimated:false];
    }];
}

- (IBAction)cancelButtonTapped{
    [self.navigationController popViewControllerAnimated: YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailTextField resignFirstResponder];
}
@end
