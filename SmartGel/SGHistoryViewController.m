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

#import "SGHistoryDetailViewController.h"
#import <PFNavigationDropdownMenu.h>
#import <GLDateUtils.h>
#import <GLCalendarDateRange.h>
#import <GLCalendarDayCell.h>

@interface SGHistoryViewController () <SGHistoryDetailViewControllerDelegate,GLCalendarViewDelegate>

@end

@implementation SGHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.smartGelHistoryCollectionView registerNib:[UINib nibWithNibName:@"SmartGelHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SmartGelHistoryCollectionViewCell"];
    fromDate = [self setMinDate];
    toDate = [self getLocalTime:[NSDate date]];
    isLaboratory = false;
    [self.dateLabel setText:[NSString stringWithFormat:@"%@ - %@",[self getDateString:fromDate],[self getDateString: toDate]]];
    // Do any additional setup after loading the view.
    [self initNavigationBar];
    [self initGlcalendarView];
    [self getHistoryArray];
//        [self getTestResults];
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
        }else{
            [self.smartGelHistoryCollectionView registerNib:[UINib nibWithNibName:@"SGLaboratoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SGLaboratoryCollectionViewCell"];
            isLaboratory = true;
        }
        [self.smartGelHistoryCollectionView reloadData];
    };
    self.navigationItem.titleView = menuView;
}

- (void)onDeletedImage{
    [self getHistoryArray];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)getHistoryArray{
    self.historyArray = [NSMutableArray array];
    self.historyFilterArray = [NSMutableArray array];
    self.laboratoryArray = [NSMutableArray array];
    self.laboratoryFilterArray = [NSMutableArray array];

    NSString *userID = [FIRAuth auth].currentUser.uid;
    if(userID!= NULL){
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[self.appDelegate.ref child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            [self.hud hideAnimated:YES];
            for(snapshot in snapshot.children){
                bool  isLaboraotoryHistory = [snapshot.value[@"islaboratory"] boolValue];
                if(!isLaboraotoryHistory){
                    EstimateImageModel *estimageImageModel =  [[EstimateImageModel alloc] initWithSnapshot:snapshot];
                    [self.historyArray addObject:estimageImageModel];
                }else{
                    LaboratoryDataModel *laboratoryDataModel = [[LaboratoryDataModel alloc] initWithSnapshot:snapshot];
                    [self.laboratoryArray addObject:laboratoryDataModel];
                }
            }
            self.laboratoryFilterArray = self.laboratoryArray;
            self.historyFilterArray = self.historyArray;
            [self.smartGelHistoryCollectionView reloadData];
        } withCancelBlock:^(NSError * _Nonnull error) {
            [self.hud hideAnimated:YES];
            [self showAlertdialog:@"Error" message:error.localizedDescription];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return CGSizeMake(self.smartGelHistoryCollectionView.frame.size.width/4-8,220);
    else
        return CGSizeMake(self.smartGelHistoryCollectionView.frame.size.width/2-4,220);
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
    if(!isLaboratory){
        EstimateImageModel *estimateImageModel = [self.historyFilterArray objectAtIndex:indexPath.row];
        SGHistoryDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGHistoryDetailViewController"];
        detailViewController.selectedEstimateImageModel = estimateImageModel;
        detailViewController.delegate = self;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }else{
        LaboratoryDataModel *laboratoryDatamodel = [self.laboratoryFilterArray objectAtIndex:indexPath.row];
        SGLaboratoryItemViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGLaboratoryItemViewController"];
        detailViewController.laboratoryDataModel = laboratoryDatamodel;
        [self.navigationController pushViewController:detailViewController animated:YES];

    }
}

- (NSDate *)setMinDate{
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setYear:2017];
    [components setMonth:1];
    [components setDay:1];
    [components setHour: 0];
    [components setMinute: 0];
    [components setSecond: 0];
    NSDate *newDate = [gregorian dateFromComponents: components];
    return newDate;
}

-(void)getFilterArray{
    self.historyFilterArray = [NSMutableArray array];
    for(int i = 0; i<self.historyArray.count;i++){
        EstimateImageModel *estimateImageModel = [[EstimateImageModel alloc] init];
        estimateImageModel = [self.historyArray objectAtIndex:i];
        NSDate *takenDate = [self getDateFromString:estimateImageModel.date];
        
        double fromDateLongValue = fromDate.timeIntervalSince1970;
        double toDateLongValue = toDate.timeIntervalSince1970;
        double takenDateLongValue = takenDate.timeIntervalSince1970;
        
        if((fromDateLongValue <= takenDateLongValue)&&(toDateLongValue>=takenDateLongValue)){
            [self.historyFilterArray addObject:estimateImageModel];
        }
    }
    [self.smartGelHistoryCollectionView reloadData];
}

- (NSString *)getDateString:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd,yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

- (NSDate *)getDateFromString:(NSString*)dateString{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [formatter dateFromString:dateString];
    return [self getLocalTime:date];
}

- (NSDate *)getLocalTime:(NSDate *)date{
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [date dateByAddingTimeInterval:timeZoneSeconds];
    return dateInLocalTimezone;
}

//todo remove- harded code
- (void)getTestResults{
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"smartgel-tests" ofType:@"json"];
    NSString *stringContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"\n Result = %@",stringContent);
    NSData *objectData = [stringContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    NSDictionary *imageArrayDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    NSArray* keys=[imageArrayDict allKeys];

    NSLog(@"\n jsonError = %@",jsonError.description);
    self.historyArray = [NSMutableArray array];
    self.historyFilterArray = [NSMutableArray array];

    for(int i =0 ; i<keys.count;i++){
        NSDictionary* imageDict = [imageArrayDict objectForKey:[keys objectAtIndex:i]];
        EstimateImageModel *estimageImageModel = [[EstimateImageModel alloc] initWithDict:imageDict];
        [self.historyArray addObject:estimageImageModel];
    }
    self.historyFilterArray = self.historyArray;
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
    [self.dateLabel setText:[NSString stringWithFormat:@"%@ - %@",[self getDateString:fromDate],[self getDateString: toDate]]];
    [self getFilterArray];
}

-(IBAction)didCancelDateRange{
    [self.calendarView removeRange:self.rangeUnderEdit];
    [self.calendarContainerView setHidden:YES];
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
