//
//  SGMenuViewController.m
//  SmartGel
//
//  Created by jordi on 15/10/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGMenuViewController.h"
#import "SGMenuTableViewCell.h"
#import "SGHomeViewController.h"
#import "SGHistoryViewController.h"
#import "SGWebViewController.h"
#import "SGSettingViewController.h"
#import "SGLaboratoryViewController.h"

@interface SGMenuViewController ()
@property (strong, nonatomic) SGHomeViewController *sgHomeViewController;
@property (strong, nonatomic) SGHistoryViewController *sgHistoryViewController;
@property (strong, nonatomic) SGWebViewController *sgWebViewController;
@property (strong, nonatomic) SGSettingViewController *sgSettingViewController;
@property (strong, nonatomic) SGLaboratoryViewController *sgLaboratoryViewController;

@end

@implementation SGMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.menuTableView registerNib:[UINib nibWithNibName:@"SGMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"SGMenuTableViewCell"];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID=@"SGMenuTableViewCell";
    SGMenuTableViewCell *cell=(SGMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(indexPath.row == 0){
        [cell setLabels:@"Home"];
    }else if(indexPath.row ==1){
        [cell setLabels:@"Laboratory"];
    }else if(indexPath.row ==2){
        [cell setLabels:@"History"];
    }else if(indexPath.row == 3){
        [cell setLabels:@"Settings"];
    }else if(indexPath.row == 4){
        [cell setLabels:@"About"];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            self.sgHomeViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGHomeViewController"];
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.sgHomeViewController]
                                                         animated:YES];
            break;
        case 1:
            self.sgLaboratoryViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGLaboratoryViewController"];
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.sgLaboratoryViewController]
                                                         animated:YES];
            break;

        case 2:
            self.sgHistoryViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGHistoryViewController"];
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.sgHistoryViewController]
                                                         animated:YES];
            break;
        case 3:
            self.sgSettingViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGSettingViewController"];
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.sgSettingViewController]
                                                         animated:YES];
            break;
        case 4:
            self.sgWebViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGWebViewController"];
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:self.sgWebViewController]
                                                         animated:YES];
            break;
        default:
            break;
    }
    [self.sideMenuViewController hideMenuViewController];
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
