//
//  SGGridView.h
//  SmartGel
//
//  Created by jordi on 22/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRID_WIDTH 1
@interface SGGridView : UIView
- (void)addGridViews:(int)rowCount withColCount:(int)colCount;
-(CGRect)getContainsFrame:(CGPoint)point
            withRowCount :(int)rowCount
            withColCount :(int)colCount;

@end
