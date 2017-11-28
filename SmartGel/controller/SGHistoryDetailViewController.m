//
//  SGHistoryDetailViewController.m
//  SmartGel
//
//  Created by jordi on 28/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGHistoryDetailViewController.h"

@interface SGHistoryDetailViewController ()

@end

@implementation SGHistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI{
    self.locationLabel.text = self.selectedEstimateImageModel.location;
    self.dateLabel.text = self.selectedEstimateImageModel.date;
    self.valueLabel.text = [NSString stringWithFormat:@"Estimated Value: %.1f", self.selectedEstimateImageModel.dirtyValue];
    [self.takenImageView sd_setImageWithURL:[NSURL URLWithString:self.selectedEstimateImageModel.imageUrl]
                           placeholderImage:[UIImage imageNamed:@"puriSCOPE_114.png"]
                                    options:SDWebImageProgressiveDownload];
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)removeImage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Are you sure to delete this image?"
                                                            preferredStyle:UIAlertControllerStyleAlert]; // 1
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userID = [FIRAuth auth].currentUser.uid;
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        FIRStorageReference *desertRef = [self.appDelegate.storageRef child:[NSString stringWithFormat:@"%@/%@.png",userID,self.selectedEstimateImageModel.date]];
        [desertRef deleteWithCompletion:^(NSError *error){
            [self.hud hideAnimated:false];
            if (error == nil) {
                [[[self.appDelegate.ref child:userID] child:self.selectedEstimateImageModel.date] removeValue];
            } else {
                [self showAlertdialog:@"Image Delete Failed!" message:error.localizedDescription];
            }
            [self backButtonClicked:nil];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
