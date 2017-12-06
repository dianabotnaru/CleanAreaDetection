//
//  SGLaboratoryViewController.h
//  SmartGel
//
//  Created by jordi on 05/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGLaboratoryViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    int firstrun;
    float vgood,good,satis,adeq,R,G,B,blankR,blankG,blankB,sampleR,sampleG,sampleB;
    uint DIA;
    double Diam;
    NSString *_diam;
    NSString *vgoodlab, *satislab, *inadeqlab,*thePath;
    bool OPorIN,li,ugormg;

}

@property (strong, nonatomic) IBOutlet UIView *blankView;
@property (strong, nonatomic) IBOutlet UIView *sampleView;
@property (strong, nonatomic) IBOutlet UILabel *resultValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *lbldiam;
@property (strong, nonatomic) IBOutlet UILabel *lblugormg;
//@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UIImageView *resultfoxImageView;

@end
