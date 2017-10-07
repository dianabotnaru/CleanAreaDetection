//
//  SGDateTimePickerView.m
//  puriSCOPE
//
//  Created by Jordi on 17/09/2017.
//
//

#import "SGDateTimePickerView.h"

@implementation SGDateTimePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(IBAction)doneButtonTapped{
    if(self.delegate)
        [self.delegate doneButtonTapped:self.datePicker.date];
}

-(IBAction)cancelButtonTapped{
    if(self.delegate)
        [self.delegate cancelButtonTapped];
}

- (void)setPickerMinDate:(NSString *)dateString{
    self.datePicker.minimumDate = [self getDateFromString:dateString];
}

- (void)setPickerMaxDate:(NSString *)dateString{
    self.datePicker.minimumDate = [self getDateFromString:dateString];
}

- (NSDate *)getDateFromString:(NSString*)dateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}


@end
