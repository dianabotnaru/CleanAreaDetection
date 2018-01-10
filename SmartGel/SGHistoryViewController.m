//
//  SGHistoryViewController.m
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGHistoryViewController.h"
#import "UIImageView+WebCache.h"
#import "SmartGelHistoryCollectionViewCell.h"
#import "SGLaboratoryCollectionViewCell.h"
#import "SGLaboratoryItemViewController.h"
#import "SGFirebaseManager.h"

#import "SGHistoryDetailViewController.h"
#import <PFNavigationDropdownMenu.h>
#import <GLDateUtils.h>
#import <GLCalendarDateRange.h>
#import <GLCalendarDayCell.h>
#import "SGUtil.h"

@interface SGHistoryViewController () <SGHistoryDetailViewControllerDelegate,GLCalendarViewDelegate,SGLaboratoryItemViewControllerDelegate>

@end

@implementation SGHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.smartGelHistoryCollectionView registerNib:[UINib nibWithNibName:@"SmartGelHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SmartGelHistoryCollectionViewCell"];
    fromDate = [self setMinDate];
    toDate = [SGUtil.sharedUtil getLocalTime:[NSDate date]];
    isLaboratory = false;
    [self.dateLabel setText:[NSString stringWithFormat:@"%@ - %@",[SGUtil.sharedUtil getDateString:fromDate],[SGUtil.sharedUtil getDateString: toDate]]];
    [self initNavigationBar];
    [self initGlcalendarView];
    [self getHistoryArray];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.calendarView reload];
}

-(void)initNavigationBar{
    NSArray *items = @[@"SmartGel", @"Laboratory"];
    PFNavigationDropdownMenu *menuView = [[PFNavigationDropdownMenu alloc]initWithFrame:CGRectMake(0, 0, 300, 44)title:[items objectAtIndex:0] items:items containerView:self.view];
    [menuView setCellBackgroundColor:SGColorBlack];
    menuView.cellTextLabelColor = [UIColor whiteColor];
    menuView.didSelectItemAtIndexHandler = ^(NSUInteger indexPath){
        if(indexPath == 0){
            [self.smartGelHistoryCollectionView registerNib:[UINib nibWithNibName:@"SmartGelHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SmartGelHistoryCollectionViewCell"];
            isLaboratory = false;
            [self getHistoryArray];
        }else{
            [self.smartGelHistoryCollectionView registerNib:[UINib nibWithNibName:@"SGLaboratoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SGLaboratoryCollectionViewCell"];
            isLaboratory = true;
            [self getLabortories];
        }
    };
    self.navigationItem.titleView = menuView;
}

- (void)onDeletedImage{
    [self getHistoryArray];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)initArrays{
    self.historyArray = [[NSMutableArray alloc] init];
    self.historyFilterArray = [[NSMutableArray alloc] init];
}

-(void)getHistoryArray{
    [self initArrays];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) wself = self;
    [[SGFirebaseManager sharedManager] getSmartGelHistorys:^(NSError *error,NSMutableArray* array) {
        __strong typeof(wself) sself = wself;
        [hud hideAnimated:false];
        if (sself) {
            if(error==nil){
                sself.historyArray = array;
                sself.historyFilterArray = array;
                [sself.smartGelHistoryCollectionView reloadData];
            }else{
                [sself showAlertdialog:@"Error!" message:error.localizedDescription];
            }
        }
    }];
}

-(void)getLabortories{
    self.laboratoryArray = [[NSMutableArray alloc] init];
    self.laboratoryFilterArray = [[NSMutableArray alloc] init];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) wself = self;
    [[SGFirebaseManager sharedManager] getLaboratoryHistorys:^(NSError *error,NSMutableArray* array) {
        __strong typeof(wself) sself = wself;
        [hud hideAnimated:false];
        if (sself) {
            if(error==nil){
                sself.laboratoryArray = array;
                sself.laboratoryFilterArray = array;
                [sself.smartGelHistoryCollectionView reloadData];
            }else{
                [sself showAlertdialog:@"Error!" message:error.localizedDescription];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(isLaboratory)
        return self.laboratoryFilterArray.count;
    else
        return self.historyFilterArray.count;
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2); // top, left, bottom, right
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        return CGSizeMake(self.smartGelHistoryCollectionView.frame.size.width/4-8,240);
    else
        return CGSizeMake(self.smartGelHistoryCollectionView.frame.size.width/2-4,240);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(!isLaboratory){
        NSString *cellIdentifier = @"SmartGelHistoryCollectionViewCell";
        SmartGelHistoryCollectionViewCell *cell = (SmartGelHistoryCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        EstimateImageModel *estimateImageModel = [self.historyFilterArray objectAtIndex:indexPath.row];
        [cell setEstimateData:estimateImageModel];
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        return cell;
    }else{
        NSString *cellIdentifier = @"SGLaboratoryCollectionViewCell";
        SGLaboratoryCollectionViewCell *cell = (SGLaboratoryCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        LaboratoryDataModel *laboratoryDataModel = [self.laboratoryFilterArray objectAtIndex:indexPath.row];
        [cell setLaboratoryData:laboratoryDataModel];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard  *storyboard;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    else
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if(!isLaboratory){
        EstimateImageModel *estimateImageModel = [self.historyFilterArray objectAtIndex:indexPath.row];
        SGHistoryDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"SGHistoryDetailViewController"];
        detailViewController.selectedEstimateImageModel = estimateImageModel;
        detailViewController.delegate = self;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }else{
        LaboratoryDataModel *laboratoryDatamodel = [self.laboratoryFilterArray objectAtIndex:indexPath.row];
        SGLaboratoryItemViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"SGLaboratoryItemViewController"];
        detailViewController.laboratoryDataModel = laboratoryDatamodel;
        detailViewController.delegate = self;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (NSDate *)setMinDate{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:1];
    [comps setYear:2017];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return date;
}

-(void)getFilterArray{
    self.historyFilterArray = [NSMutableArray array];
    for(int i = 0; i<self.historyArray.count;i++){
        EstimateImageModel *estimateImageModel = [[EstimateImageModel alloc] init];
        estimateImageModel = [self.historyArray objectAtIndex:i];
        NSDate *takenDate = [SGUtil.sharedUtil getDateFromString:estimateImageModel.date];
        
        double fromDateLongValue = fromDate.timeIntervalSince1970;
        double toDateLongValue = toDate.timeIntervalSince1970;
        double takenDateLongValue = takenDate.timeIntervalSince1970;
        
        if((fromDateLongValue <= takenDateLongValue)&&(toDateLongValue>=takenDateLongValue)){
            [self.historyFilterArray addObject:estimateImageModel];
        }
    }
    [self.smartGelHistoryCollectionView reloadData];
}

-(void)initGlcalendarView{
    NSDate *today = [NSDate date];
    GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:today endDate:today];
    range.backgroundColor = UIColorFromRGB(0x80ae99);
    range.editable = YES;
    self.calendarView.ranges = [@[range] mutableCopy];
    self.calendarView.delegate = self;
    self.calendarView.firstDate = fromDate;
    self.rangeUnderEdit = range;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.calendarView scrollToDate:today animated:NO];
    });
    [self initCalendarViewUi];
}

-(void)initCalendarViewUi{
    [GLCalendarDayCell appearance].dayLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColorFromRGB(0x555555)};
    [GLCalendarDayCell appearance].monthLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:8]};
}

- (BOOL)calenderView:(GLCalendarView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate
{
    return YES;
}

- (GLCalendarDateRange *)calenderView:(GLCalendarView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate
{
    [self.calendarView removeRange:self.rangeUnderEdit];
    if(dateSelectState == 0){
        dateSelectState =1;
        fromDate = beginDate;
        GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:beginDate endDate:beginDate];
        range.backgroundColor = UIColorFromRGB(0x80ae99);
        range.editable = YES;
        self.rangeUnderEdit = range;
        return range;
    }else{
        dateSelectState =0;
        toDate = beginDate;
        GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:fromDate endDate:beginDate];
        range.backgroundColor = UIColorFromRGB(0x80ae99);
        range.editable = YES;
        self.rangeUnderEdit = range;
        return range;
    }
}

- (void)calenderView:(GLCalendarView *)calendarView beginToEditRange:(GLCalendarDateRange *)range
{
}

- (void)calenderView:(GLCalendarView *)calendarView finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing
{
}

- (BOOL)calenderView:(GLCalendarView *)calendarView canUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    return YES;
}

- (void)calenderView:(GLCalendarView *)calendarView didUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
}

- (IBAction)showCalendar{
    [self.calendarContainerView setHidden:NO];
}

-(IBAction)didSelectDateRange{
    [self.calendarContainerView setHidden:YES];
    [self.calendarView removeRange:self.rangeUnderEdit];
    [self.dateLabel setText:[NSString stringWithFormat:@"%@ - %@",[SGUtil.sharedUtil getDateString:fromDate],[SGUtil.sharedUtil getDateString: toDate]]];
    [self getFilterArray];
}

-(IBAction)didCancelDateRange{
    [self.calendarView removeRange:self.rangeUnderEdit];
    [self.calendarContainerView setHidden:YES];
}

-(IBAction)didSortButtonTapped{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sort"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Date"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self sortHistoryFilterArrar:@"date"];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Value"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self sortHistoryFilterArrar:@"cleanValue"];
                                                           }];
    
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:@"Tag"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self sortHistoryFilterArrar:@"tag"];
                                                           }];
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.frame.size.width-30, 0, 30, 0);
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)sortHistoryFilterArrar:(NSString *)sortKey{
    if(isLaboratory)
        self.laboratoryFilterArray = [SGUtil.sharedUtil sortbyKey:self.laboratoryFilterArray withKey:sortKey];
    else
        self.historyFilterArray = [SGUtil.sharedUtil sortbyKey:self.historyFilterArray withKey:sortKey];
    [self.smartGelHistoryCollectionView reloadData];
}

@end
