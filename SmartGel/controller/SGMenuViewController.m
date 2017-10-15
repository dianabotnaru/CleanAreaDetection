//
//  SGMenuViewController.m
//  SmartGel
//
//  Created by jordi on 15/10/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGMenuViewController.h"
#import "SGMenuTableViewCell.h"

@interface SGMenuViewController ()

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
