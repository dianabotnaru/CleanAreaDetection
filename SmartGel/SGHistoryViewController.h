//
//  SGHistoryViewController.h
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firebase.h"
#import "MBProgressHUD.h"
#import "EstimateImageModel.h"
#import "LaboratoryDataModel.h"
#import "SGDateTimePickerView.h"
#import "SGBaseViewController.h"
#import <GLCalendarView.h>

@interface SGHistoryViewController : SGBaseViewController{
    bool isFromButtonTapped;
    SGDateTimePickerView *sgDateTimePickerView;
    NSDate *fromDate;
    NSDate *toDate;
    int dateSelectState;
    bool isLaboratory;
}

@property (strong, nonatomic) IBOutlet UICollectionView *smartGelHistoryCollectionView;
@property (strong, nonatomic) IBOutlet GLCalendarView *calendarView;
@property (strong, nonatomic) IBOutlet UIView *historyView;
@property (strong, nonatomic) IBOutlet UIView *calendarContainerView;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSMutableArray *historyArray;
@property (strong, nonatomic) NSMutableArray *historyFilterArray;

@property (strong, nonatomic) NSMutableArray *laboratoryArray;
@property (strong, nonatomic) NSMutableArray *laboratoryFilterArray;

@property (nonatomic, weak) GLCalendarDateRange *rangeUnderEdit;
@end
