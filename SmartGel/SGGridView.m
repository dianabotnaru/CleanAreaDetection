//
//  SGGridView.m
//  SmartGel
//
//  Created by jordi on 22/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGGridView.h"
#import "SGConstant.h"

@implementation SGGridView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)addGridViews:(int)rowCount withColCount:(int)colCount {
    
    float width = self.frame.size.width/(float)rowCount;
    float height = self.frame.size.height/(float)colCount;
    for(int i = 0;i<=rowCount;i++){
        UIView *paintView;
        if(i == rowCount)
            paintView=[[UIView alloc]initWithFrame:CGRectMake(width*i,0,GRID_WIDTH,self.frame.size.height)];
        else
            paintView=[[UIView alloc]initWithFrame:CGRectMake(width*i,0,GRID_WIDTH,self.frame.size.height)];
        [paintView setBackgroundColor:SGColorDarkGray];

        [self addSubview:paintView];
    }
    for(int j = 0;j<=colCount;j++){
        UIView *paintView;
        if(j==colCount)
            paintView=[[UIView alloc]initWithFrame:CGRectMake(0,height*j,self.frame.size.width,GRID_WIDTH)];
        else
            paintView=[[UIView alloc]initWithFrame:CGRectMake(0,height*j,self.frame.size.width,GRID_WIDTH)];
        [paintView setBackgroundColor:SGColorDarkGray];
        [self addSubview:paintView];
    }
}

-(int)getContainsFrame:(UIImage *)takenImage
                withPoint: (CGPoint)point
            withRowCount :(int)rowCount
            withColCount :(int)colCount{
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    int frameWidth = self.frame.size.width/rowCount;
    int frameHeight = self.frame.size.height/colCount;
    
    for(int i = 0;i<rowCount;i++)
        for(int j = 0;j<colCount;j++){
            rect = CGRectMake(frameWidth*i,frameHeight*j,frameWidth,frameHeight);
            if(CGRectContainsPoint(rect, point)){
                if(takenImage.imageOrientation == UIImageOrientationLeft){
                    return (SGGridCount-1-j)*SGGridCount + i;
                }else if(takenImage.imageOrientation == UIImageOrientationRight){
                    return j*SGGridCount + (SGGridCount-1-i);
                }else if(takenImage.imageOrientation == UIImageOrientationUp){
                    return i*SGGridCount + j;
                }else{
                    return (SGGridCount-1-i)*SGGridCount + (SGGridCount-1-j);
                }
            }
        }
    return -1;
}
@end
