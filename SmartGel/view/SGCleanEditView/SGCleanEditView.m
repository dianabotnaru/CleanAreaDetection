//
//  SGCleanEditView.m
//  SmartGel
//
//  Created by jordi on 02/02/2018.
//  Copyright © 2018 AFCO. All rights reserved.
//

#import "SGCleanEditView.h"
#import "SGUtil.h"
#import "SGConstant.h"
#import "DirtyExtractor.h"

@implementation SGCleanEditView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.imgview = [[UIImageView alloc] init];
    }
    return self;
}

-(void)setImage:(UIImage *)image
 withCleanArray: (NSMutableArray *)cleanArray{
    [self initViewWithImage:image];
    [self initDatas];

//    [self drawGridView];
    //    [self initCleanareaViews: cleanArray];
}

-(void)initViewWithImage:(UIImage *)image{
    [self.scrollView setZoomScale:1];
    [self.imgview removeFromSuperview];
    CGRect rect = [[SGUtil sharedUtil] calculateClientRectOfImageInUIImageView:self.scrollView takenImage:image];
    self.imgview =  [[UIImageView alloc] initWithFrame:rect];
    self.imgview.image = image;
    self.takenImage = image;
    [self.scrollView addSubview:self.imgview];
}

/************************************************************************************************************************************
  * image zooming function
*************************************************************************************************************************************/
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgview;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imgview.frame;
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0;
    } else {
        contentsFrame.origin.x = 0.0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0;
    } else {
        contentsFrame.origin.y = 0.0;
    }
    self.imgview.frame = contentsFrame;
}

-(void)initDatas{
    self.cleanareaViews = [NSMutableArray array];
    self.orignialcleanareaViews = [NSMutableArray array];
}

/************************************************************************************************************************************
 * Grid View
 *************************************************************************************************************************************/

-(void)drawGridView{
    [self.gridContentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    self.gridView = [[SGGridView alloc] initWithFrame:self.imgview.frame];
    [self.gridView addGridViews:SGGridCount withColCount:SGGridCount];
    [self.imgview addSubview:self.gridView];
}

/************************************************************************************************************************************
 * Clean area views
 *************************************************************************************************************************************/

//
//-(void)initCleanareaViews:(NSMutableArray*)dirtyState{
//    [self.cleanareaViews removeAllObjects];
//    [self.orignialcleanareaViews removeAllObjects];
//    CGRect rect = [[SGUtil sharedUtil] calculateClientRectOfImageInUIImageView:self.imgview takenImage:self.takenImage];
//    float areaWidth = rect.size.width/AREA_DIVIDE_NUMBER;
//    float areaHeight = rect.size.height/AREA_DIVIDE_NUMBER;
//    for(int i = 0; i<(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);i++){
//        int x,y;
//        if(self.takenImage.imageOrientation == UIImageOrientationLeft){
//            y = (AREA_DIVIDE_NUMBER-1) - i/AREA_DIVIDE_NUMBER;
//            x = i%AREA_DIVIDE_NUMBER;
//        }else if(self.takenImage.imageOrientation == UIImageOrientationRight){
//            y = i/AREA_DIVIDE_NUMBER;
//            x = (AREA_DIVIDE_NUMBER-1) - i%AREA_DIVIDE_NUMBER;
//        }else if(self.takenImage.imageOrientation == UIImageOrientationUp){
//            x = i/AREA_DIVIDE_NUMBER;
//            y = i%AREA_DIVIDE_NUMBER;
//        }else{
//            x = (AREA_DIVIDE_NUMBER-1)-i/AREA_DIVIDE_NUMBER;
//            y = (AREA_DIVIDE_NUMBER-1)-i%AREA_DIVIDE_NUMBER;
//        }
//        UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(x*areaWidth+rect.origin.x, y*areaHeight+rect.origin.y, areaWidth, areaHeight)];
//        if([[dirtyState objectAtIndex:i] intValue] == IS_CLEAN){
//            [paintView setBackgroundColor:[UIColor redColor]];
//            [paintView setAlpha:0.3];
//        }else if([[dirtyState objectAtIndex:i] intValue] == IS_DIRTY){
//            [paintView setBackgroundColor:[UIColor blueColor]];
//            [paintView setAlpha:0.2];
//        }
//        [self.cleanareaViews addObject:paintView];
//        [self.orignialcleanareaViews addObject:paintView];
//    }
//}
//
//
//-(void)addManualNonGelArea:(int)touchPosition withCleanArray:(NSMutableArray *)cleanArray{
//    int pointX = touchPosition/SGGridCount;
//    int pointY = touchPosition%SGGridCount;
//    [self updateNonGelAreaViews:pointX withPointY:pointY withCleanArray:cleanArray];
//}
//
//-(void)addManualCleanArea:(int)touchPosition{
//    int pointX = touchPosition/SGGridCount;
//    int pointY = touchPosition%SGGridCount;
//    [self addManualPinkAreaViews:pointX withPointY:pointY];
//}
//
//-(void)removeMaunalCleanArea:(int)touchPosition{
//    int pointX = touchPosition/SGGridCount;
//    int pointY = touchPosition%SGGridCount;
//    [self removeManualPinkAreaViews:pointX withPointY:pointY];
//}
//
//-(void)updateNonGelAreaViews:(int)pointX
//                  withPointY:(int)pointY
//              withCleanArray:(NSMutableArray *)cleanArray{
//    int rate = AREA_DIVIDE_NUMBER/SGGridCount;
//    for(int i = 0; i<rate;i++){
//        for(int j = 0; j< rate; j++){
//            NSUInteger postion = AREA_DIVIDE_NUMBER*rate*pointX+(i*AREA_DIVIDE_NUMBER)+(rate*pointY+j);
//            UIView *view = [self.cleanareaViews objectAtIndex:postion];
//            if([[cleanArray objectAtIndex:postion] intValue] == NO_GEL){
//                [view removeFromSuperview];
//            }else{
//                [self.imgview addSubview:view];
//            }
//        }
//    }
//}
//
//-(void)addManualPinkAreaViews:(int)pointX
//                   withPointY:(int)pointY{
//    int rate = AREA_DIVIDE_NUMBER/SGGridCount;
//    for(int i = 0; i<rate;i++){
//        for(int j = 0; j< rate; j++){
//            NSUInteger postion = AREA_DIVIDE_NUMBER*rate*pointX+(i*AREA_DIVIDE_NUMBER)+(rate*pointY+j);
//            UIView *view = [self.cleanareaViews objectAtIndex:postion];
//            [view removeFromSuperview];
//            UIView *manualPinkView = [[UIView alloc] initWithFrame:view.frame];
//            [manualPinkView setBackgroundColor:[UIColor redColor]];
//            [manualPinkView setAlpha:0.3];
//            [self.cleanareaViews replaceObjectAtIndex:postion withObject:manualPinkView];
//            [self.imgview addSubview:[self.cleanareaViews objectAtIndex:postion]];
//        }
//    }
//}
//
//-(void)removeManualPinkAreaViews:(int)pointX
//                      withPointY:(int)pointY{
//    int rate = AREA_DIVIDE_NUMBER/SGGridCount;
//    for(int i = 0; i<rate;i++){
//        for(int j = 0; j< rate; j++){
//            NSUInteger postion = AREA_DIVIDE_NUMBER*rate*pointX+(i*AREA_DIVIDE_NUMBER)+(rate*pointY+j);
//            UIView *view = [self.cleanareaViews objectAtIndex:postion];
//            [view removeFromSuperview];
//            UIView *originalview = [self.orignialcleanareaViews objectAtIndex:postion];
//            [self.cleanareaViews replaceObjectAtIndex:postion withObject:originalview];
//            [self.imgview addSubview:originalview];
//        }
//    }
//}
@end
