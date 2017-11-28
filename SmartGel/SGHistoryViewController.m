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

@interface SGHistoryViewController () <SGDateTimePickerViewDelegate>

@end

@implementation SGHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isShowDetailView = false;
    self.trashButton.tintColor = [UIColor clearColor];
    self.trashButton.enabled = NO;
    [self.smartGelHistoryCollectionView registerNib:[UINib nibWithNibName:@"SmartGelHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SmartGelHistoryCollectionViewCell"];
    self.selectedImageModel = [[EstimateImageModel alloc] init];
    [self hideDirtyArea];
    [self initDateTimePickerView];
    fromDate = [self setMinDate];
    [self.fromLabel setText:[self getDateString:fromDate]];
    toDate = [self getLocalTime:[NSDate date]];
    [self.toLabel setText:[self getDateString:toDate]];
    dirtyStateArray = [NSArray array];
    
//    [self getHistoryArray];

    [self getTestResults];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.gridView addGridViews:5 withColCount:5];
}

-(void)getHistoryArray{
    self.historyArray = [NSMutableArray array];
    self.historyFilterArray = [NSMutableArray array];
    NSString *userID = [FIRAuth auth].currentUser.uid;
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[self.appDelegate.ref child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.hud hideAnimated:YES];
        for(snapshot in snapshot.children){
            EstimateImageModel *estimageImageModel =  [[EstimateImageModel alloc] init];
            estimageImageModel.dirtyValue = [snapshot.value[@"value"] floatValue];
            estimageImageModel.date = snapshot.value[@"date"];
            estimageImageModel.location = snapshot.value[@"location"];
            estimageImageModel.imageUrl = snapshot.value[@"image"];
            estimageImageModel.dirtyArea = snapshot.value[@"dirtyarea"];
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
    self.selectedImageModel = [self.historyFilterArray objectAtIndex:indexPath.row];
    SGHistoryDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SGHistoryDetailViewController"];
    detailViewController.selectedEstimateImageModel = self.selectedImageModel;
    [self.navigationController pushViewController:detailViewController animated:YES];

//    [self showDetailView:self.selectedImageModel];
}

-(IBAction)backButtonPressed{
    if(isShowDetailView)
        [self hideDetailView];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showDetailView :(EstimateImageModel *)estimateImageData{
    isShowDetailView = true;
    [UIView transitionWithView:self.detailView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.detailView.hidden = NO;
                        self.trashButton.tintColor = [UIColor whiteColor];
                        self.trashButton.enabled = YES;
                    }
                    completion:NULL];
    
    self.locationLabel.text = estimateImageData.location;
    self.dateLabel.text = estimateImageData.date;
    self.valueLabel.text = [NSString stringWithFormat:@"Estimated Value: %.2f", estimateImageData.dirtyValue];
    [self.takenImageView sd_setImageWithURL:[NSURL URLWithString:estimateImageData.imageUrl]
                           placeholderImage:[UIImage imageNamed:@"puriSCOPE_114.png"]];
}

-(void)hideDetailView{
    isShowDetailView = false;
    [UIView transitionWithView:self.detailView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.detailView.hidden = YES;
                        self.trashButton.tintColor = [UIColor clearColor];
                        self.trashButton.enabled = NO;
                    }
                    completion:NULL];
    [self hideDirtyArea];
}

//-(IBAction)rightButtonAction{
//    if(isShowDetailView)
//        [self removeImage];
//}

-(IBAction)detailImageTapped{
    [self hideDetailView];
}

//- (void)removeImage{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
//                                                                   message:@"Are you sure to delete this image?"
//                                                            preferredStyle:UIAlertControllerStyleAlert]; // 1
//    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        NSString *userID = [FIRAuth auth].currentUser.uid;
//        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        FIRStorageReference *desertRef = [self.appDelegate.storageRef child:[NSString stringWithFormat:@"%@/%@.png",userID,self.selectedImageModel.date]];
//        [desertRef deleteWithCompletion:^(NSError *error){
//            [self.hud hideAnimated:false];
//            if (error == nil) {
//                [[[self.appDelegate.ref child:userID] child:self.selectedImageModel.date] removeValue];
//                [self getHistoryArray];
//                [self hideDetailView];
//            } else {
//                [self showAlertdialog:@"Image Delete Failed!" message:error.localizedDescription];
//            }
//        }];
//
//    }]];
//
//    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//    }]];
//
//    [self presentViewController:alert animated:YES completion:nil];
//}

-(void)showAlertdialog:(NSString*)title message:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert]; // 1
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSArray *)getDirtyAreaArray{
    NSData* data = [self.selectedImageModel.dirtyArea dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];  // if you are expecting  the JSON string to
    return values;
}

-(void)drawView:(int)index:(bool)isUpdate{
    int y = index/AREA_DIVIDE_NUMBER;
    int x = (AREA_DIVIDE_NUMBER-1) - index%AREA_DIVIDE_NUMBER;
    float areaWidth = self.takenImageView.frame.size.width/AREA_DIVIDE_NUMBER;
    float areaHeight = self.takenImageView.frame.size.height/AREA_DIVIDE_NUMBER;
    UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(x*areaWidth, y*areaHeight, areaWidth, areaHeight)];
    if([[dirtyStateArray objectAtIndex:index] boolValue]){
        if(isUpdate)
            [paintView setBackgroundColor:[UIColor blueColor]];
        else
            [paintView setBackgroundColor:[UIColor redColor]];

        [paintView setAlpha:0.7];
        [self.takenImageView addSubview:paintView];
    }
}

-(IBAction)showHideDirtyArea{
    if(isShowDirtyArea)
        [self hideDirtyArea];
    else
        [self showDirtyArea];
}

-(void)showDirtyArea{
    isShowDirtyArea = true;
    [self.showDirtyAreaButton setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:128.0f/255.0f blue:210.0f/255.0f alpha:1.0]];
    [self.showDirtyAreaButton setTitle:@"H" forState:UIControlStateNormal];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        dirtyStateArray = [NSArray array];
        dirtyStateArray = [self getDirtyAreaArray];
        for(int i = 0; i<(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);i++)
            [self drawView:i:false];
        [self.hud hideAnimated:false];
    });
}

-(void)hideDirtyArea{
    isShowDirtyArea = false;
    [self.takenImageView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self.showDirtyAreaButton setBackgroundColor:[UIColor colorWithRed:185.0f/255.0f green:74.0f/255.0f blue:72.0f/255.0f alpha:1.0]];
    [self.showDirtyAreaButton setTitle:@"S" forState:UIControlStateNormal];
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

- (IBAction)showDirtyAreaWithUpdatedModule{

    if(self.takenImageView.image){
        [self initEngine:self.takenImageView.image];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.engine.areaDirtyState options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.selectedImageModel.dirtyArea = jsonString;
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            dirtyStateArray = [NSArray array];
            dirtyStateArray = [self getDirtyAreaArray];
            for(int i = 0; i<(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);i++)
                [self drawView:i:true];
            [self.hud hideAnimated:false];
        });
    }
}

- (IBAction)hideDirtAreaWithUpdatedModule{
    [self hideDirtyArea];
}

-(void)initEngine:(UIImage *)image{
    self.engine = [[DirtyExtractor alloc] init];
    [self.engine reset];
    [self.engine importImage:image];
    [self.engine extract];
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
