//
//  SGDateTimePickerView.h
//  puriSCOPE
//
//  Created by Jordi on 17/09/2017.
//
//

#import <UIKit/UIKit.h>

@protocol SGDateTimePickerViewDelegate <NSObject>
@required
- (void)doneButtonTapped:(NSDate *)date;
- (void)cancelButtonTapped;
@end

@interface SGDateTimePickerView : UIView
@property (weak, nonatomic) id<SGDateTimePickerViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@end
