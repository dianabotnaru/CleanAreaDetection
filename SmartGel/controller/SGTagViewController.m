//
//  SGTagViewController.m
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import "SGTagViewController.h"
#import "MBProgressHUD.h"
#import "SGFirebaseManager.h"
#import "SCLAlertView.h"
#import "SGConstant.h"

@interface SGTagViewController ()

@end

@implementation SGTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tagCollectionView registerNib:[UINib nibWithNibName:@"SGTagCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SGTagCollectionViewCell"];
    [self getTags];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)getTags{
    self.tagArray = [NSMutableArray array];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) wself = self;
    [[SGFirebaseManager sharedManager] getTags:^(NSError *error,NSMutableArray* array) {
        __strong typeof(wself) sself = wself;
        [hud hideAnimated:false];
        if (sself) {
            if(error==nil){
                sself.tagArray = array;
                [sself.tagCollectionView reloadData];
            }else{
                [sself showAlertdialog:@"Error!" message:error.localizedDescription];
            }
        }
    }];
}

-(void)addTagsWithoutImage:(NSString *)tagName{
    SGTag *sgTag = [[SGTag alloc] init];
    sgTag.tagName = tagName;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[SGFirebaseManager sharedManager] addTagsWithoutImage:sgTag];
    [hud hideAnimated:false];
    [self showAlertdialog:@"Tag Adding Success!" message:@""];
    [self getTags];
}

-(IBAction)addButtonClicked:(id)sender{
    [self showAddAlertView];
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)showAddAlertView{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = SGColorBlack;
    alert.iconTintColor = [UIColor whiteColor];
    alert.tintTopCircle = NO;
    alert.backgroundViewColor = SGColorDarkGray;
    alert.view.backgroundColor = SGColorDarkGray;
    alert.backgroundType = SCLAlertViewBackgroundTransparent;
    alert.labelTitle.textColor = [UIColor whiteColor];
    UITextField *tagTextField = [alert addTextField:@"Tag Name"];
    [tagTextField setTextColor:[UIColor lightGrayColor]];
    [alert addButton:@"Done" actionBlock:^(void) {
        if([tagTextField.text isEqualToString:@""]){
            [self showAlertdialog:@"" message:@"Please input a tag name"];
            [self showAddAlertView];
        }else{
            [self addTagsWithoutImage:tagTextField.text];
        }
    }];
    alert.showAnimationType = 0;
    [alert.viewText setTextColor:[UIColor whiteColor]];
    [alert showEdit:self title:@"Adding tag?" subTitle:@"Are you sure want to add a tag?" closeButtonTitle:@"Cancel" duration:0.0f];
}


#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2); // top, left, bottom, right
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        return CGSizeMake(self.tagCollectionView.frame.size.width/4-8,self.tagCollectionView.frame.size.width/4-8);
    else
        return CGSizeMake(self.tagCollectionView.frame.size.width/2-4,self.tagCollectionView.frame.size.width/2-4);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tagArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SGTagCollectionViewCell";
    SGTagCollectionViewCell *cell = (SGTagCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    SGTag *sgTag = [self.tagArray objectAtIndex:indexPath.row];
    cell.index = indexPath.row;
    cell.delegate = self;
    [cell setTags:sgTag];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)addPictureButtonTapped:(NSInteger)index withSender:(UICollectionViewCell *)sender{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Choose a Photo" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        actionSheet.modalPresentationStyle = UIModalPresentationPopover;
        actionSheet.popoverPresentationController.sourceView = self.view;
        actionSheet.popoverPresentationController.sourceRect = sender.frame;
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}
@end
