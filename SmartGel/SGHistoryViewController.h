//
//  SGHistoryViewController.h
//  SmartGel
//
//  Created by jordi on 28/09/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGHistoryViewController : UIViewController{
    bool isShowDirtyArea;
    bool isShowDetailView;
    bool isFromButtonTapped;
//    SGDateTimePickerView *sgDateTimePickerView;
    NSDate *fromDate;
    NSDate *toDate;
    NSArray *dirtyStateArray;
}


@end
