//
//  SGTagViewController.m
//  SmartGel
//
//  Created by jordi on 03/01/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import "SGTagViewController.h"
#import "SGTagCollectionViewCell.h"

@interface SGTagViewController ()

@end

@implementation SGTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tagCollectionView registerNib:[UINib nibWithNibName:@"SGTagCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SGTagCollectionViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated: YES];
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
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SGTagCollectionViewCell";
    SGTagCollectionViewCell *cell = (SGTagCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

@end
