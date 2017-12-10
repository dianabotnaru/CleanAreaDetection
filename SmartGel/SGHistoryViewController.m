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
#import "SGHistoryDetailViewController.h"
#import <CCDropDownMenus/CCDropDownMenus.h>

@interface SGHistoryViewController () <SGDateTimePickerViewDelegate,SGHistoryDetailViewControllerDelegate,CCDropDownMenuDelegate>

@end

@implementation SGHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.smartGelHistoryCollectionView registerNib:[UINib nibWithNibName:@"SmartGelHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SmartGelHistoryCollectionViewCell"];
    [self initDateTimePickerView];
    fromDate = [self setMinDate];
    [self.fromLabel setText:[self getDateString:fromDate]];
    toDate = [self getLocalTime:[NSDate date]];
    [self.toLabel setText:[self getDateString:toDate]];
    // Do any additional setup after loading the view.
    [self initNavigationBar];
//    [self getHistoryArray];
    //    [self getTestResults];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)initNavigationBar{
    SyuDropDownMenu *menu = [[SyuDropDownMenu alloc] initWithNavigationBar:self.navigationController.navigationBar useNavigationController:YES];
    menu.delegate = self;
    menu.numberOfRows = 2;
    menu.textOfRows = @[@"SmartGel", @"Laboratory"];
    [self.view addSubview:menu];
}

- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index {
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
    NSString *userID = [FIRAuth auth].currentUser.uid;
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[self.appDelegate.ref child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.hud hideAnimated:YES];
        for(snapshot in snapshot.children){
            EstimateImageModel *estimageImageModel =  [[EstimateImageModel alloc] initWithSnapshot:snapshot];
            [self.historyArray addObject:estimageImageModel];
        }
        self.historyFilterArray = self.historyArray;
        [self.smartGelHistoryCollectionView reloadData];
    } withCancelBlock:^(NSError * _Nonnull error) {
        [self.hud hideAnimated:YES];
        [self showAlertdialog:@"Error" message:error.localizedDescription];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.historyFilterArray.count;
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2); // top, left, bottom, right
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.smartGelHistoryCollectionView.frame.size.width/2-4,220);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SmartGelHistoryCollectionViewCell";
    SmartGelHistoryCollectionViewCell *cell = (SmartGelHistoryCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    EstimateImageModel *estimateImageModel = [self.historyFilterArray objectAtIndex:indexPath.row];
    [cell setEstimateData:estimateImageModel];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    EstimateImageModel *estimateImageModel = [self.historyFilterArray objectAtIndex:indexPath.row];
    SGHistoryDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGHistoryDetailViewController"];
    detailViewController.selectedEstimateImageModel = estimateImageModel;
    detailViewController.delegate = self;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)fromButtonTapped{
    isFromButtonTapped = true;
    sgDateTimePickerView.datePicker.minimumDate = [self setMinDate];
    sgDateTimePickerView.datePicker.maximumDate = [NSDate date];
    [sgDateTimePickerView setHidden:NO];
}

-(IBAction)toButtonTapped{
    isFromButtonTapped = false;
    sgDateTimePickerView.datePicker.minimumDate = fromDate;
    sgDateTimePickerView.datePicker.maximumDate = [NSDate date];
    [sgDateTimePickerView setHidden:NO];
}

/////////////////////////// Add DateTimePicker View/////////////////////////////////////////////////////////////
- (void)initDateTimePickerView{
    sgDateTimePickerView = [[[NSBundle mainBundle] loadNibNamed:@"SGDateTimePickerView" owner:nil options:nil] lastObject];
    sgDateTimePickerView.frame = CGRectMake(5, [[[UIApplication sharedApplication] delegate] window].frame.size.height-305, [[[UIApplication sharedApplication] delegate] window].frame.size.width-10,300);
    sgDateTimePickerView.delegate = self;
    [self.view addSubview:sgDateTimePickerView];
    [sgDateTimePickerView setHidden:YES];
}

-(void)doneButtonTapped:(NSDate *)date{
    [sgDateTimePickerView setHidden:YES];
    if(isFromButtonTapped){
        fromDate = [self getLocalTime:date];
        [self.fromLabel setText:[self getDateString:date]];
        [self getFilterArray];
    }
    else{
        toDate = [self getLocalTime:date];
        [self.toLabel setText:[self getDateString:date]];
        [self getFilterArray];
    }
}

-(void)cancelButtonTapped{
    [sgDateTimePickerView setHidden:YES];
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
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
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


- (IBAction)showCalendar{
    
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
