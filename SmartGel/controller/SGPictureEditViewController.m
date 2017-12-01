//
//  SGPictureEditViewController.m
//  SmartGel
//
//  Created by jordi on 30/11/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGPictureEditViewController.h"

@interface SGPictureEditViewController ()<ACEDrawingViewDelegate>

@end

@implementation SGPictureEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.takenImageView setImage:self.takenImage];
    self.aceDrawingView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated: YES];
}

-(IBAction)widthButtonClicked{
    if(self.widthSlider.isHidden)
        [self.widthSlider setHidden:NO];
    else
        [self.widthSlider setHidden:YES];
}

- (void)updateButtonStatus
{
    self.undoButton.enabled = [self.aceDrawingView canUndo];
    self.redoButton.enabled = [self.aceDrawingView canRedo];
}

- (IBAction)undo:(id)sender
{
    [self.aceDrawingView undoLatestStep];
    [self updateButtonStatus];
}

- (IBAction)redo:(id)sender
{
    [self.aceDrawingView redoLatestStep];
    [self updateButtonStatus];
}

- (IBAction)clear:(id)sender
{
    [self.aceDrawingView clear];
    [self updateButtonStatus];
}

- (IBAction)widthChange:(UISlider *)sender
{
    self.aceDrawingView.lineWidth = sender.value;
}


#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    [self updateButtonStatus];
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
