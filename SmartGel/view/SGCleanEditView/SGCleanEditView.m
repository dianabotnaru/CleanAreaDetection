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

@implementation SGCleanEditView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
    }
    return self;
}

-(void)customInit{
    [self initViews];
}

-(void)initViews{

    self.scrollView.minimumZoomScale=1;
    self.scrollView.maximumZoomScale=3.0;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = YES;
    self.scrollView.delegate=self;
    UITapGestureRecognizer *singleTapGR, *doubleTapGR;
    
    doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myDoubleTapHandler)];
    doubleTapGR.numberOfTapsRequired = 2;
    [singleTapGR requireGestureRecognizerToFail:doubleTapGR];
    
    [self.scrollView addGestureRecognizer:doubleTapGR];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
//    self.scrollView.clipsToBounds = YES;
    self.imgview.translatesAutoresizingMaskIntoConstraints = YES;
    self.imgview.contentMode = UIViewContentModeScaleAspectFit;
    CGRect rect = [[SGUtil sharedUtil] calculateClientRectOfImageInUIImageView:self.imgview takenImage:self.imgview.image];
    self.imgview.frame = rect;
    [self drawGridView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgview;
}

-(void)myDoubleTapHandler
{
    if(self.zoomed) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ [self.scrollView setZoomScale:1.0f animated:NO]; }
                         completion:nil];
        self.zoomed = NO;
    } else {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ [self.scrollView setZoomScale:3.0f animated:NO]; }
                         completion:nil];
        self.zoomed = YES;
    }
}

-(void)drawGridView{
    [self.gridContentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    CGRect rect = [[SGUtil sharedUtil] calculateClientRectOfImageInUIImageView:self.imgview takenImage:self.imgview.image];
    self.gridView = [[SGGridView alloc] initWithFrame:rect];
    [self.gridView addGridViews:SGGridCount withColCount:SGGridCount];
    [self.gridContentView addSubview:self.gridView];
}

@end
