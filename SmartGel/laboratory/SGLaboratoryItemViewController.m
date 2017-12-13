//
//  SGLaboratoryItemViewController.m
//  SmartGel
//
//  Created by jordi on 11/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGLaboratoryItemViewController.h"

@interface SGLaboratoryItemViewController ()

@end

@implementation SGLaboratoryItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)initLabels{
    self.locationLabel.text = self.laboratoryDataModel.location;
    self.dateLabel.text = self.laboratoryDataModel.date;
    self.resultValueLabel.text = [NSString stringWithFormat:@"Estimated Value: %.2f", self.laboratoryDataModel.resultValue];
    self.customerLabel.text = self.laboratoryDataModel.customer;
    self.tagLabel.text = self.laboratoryDataModel.tag;

    self.blankView.backgroundColor = [self getUIColorFromInt:self.laboratoryDataModel.blankColor];
    self.sampleView.backgroundColor = [self getUIColorFromInt:self.laboratoryDataModel.sampleColor];
    
    if(self.laboratoryDataModel.resultState == 1)
        self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_pink.png"];
    else if(self.laboratoryDataModel.resultState == 2)
        self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_green.png"];
    else if(self.laboratoryDataModel.resultState == 3)
        self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_yellow.png"];
}

- (UIColor *)getUIColorFromInt:(int)intValue{
    return [UIColor colorWithRed:((CGFloat)((intValue & 0xFF0000) >> 16)) / 255.0
                           green:((CGFloat)((intValue & 0xFF00) >> 8)) / 255.0
                            blue:((CGFloat)(intValue & 0xFF)) / 255.0
                           alpha:1.0];
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated: YES];
}

-(IBAction)removeLaboratoryItem{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Are you sure to delete this image?"
                                                            preferredStyle:UIAlertControllerStyleAlert]; // 1
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userID = [FIRAuth auth].currentUser.uid;
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        FIRStorageReference *desertRef = [self.appDelegate.storageRef child:[NSString stringWithFormat:@"%@/%@.png",userID,self.laboratoryDataModel.date]];
        [desertRef deleteWithCompletion:^(NSError *error){
            [self.hud hideAnimated:false];
            if (error == nil) {
                [[[self.appDelegate.ref child:userID] child:self.laboratoryDataModel.date] removeValue];
            } else {
                [self showAlertdialog:@"Image Delete Failed!" message:error.localizedDescription];
            }
            if(self.delegate!=nil){
                [self.delegate onDeletedImage];
            }
            [self backButtonClicked:nil];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];

}

@end
