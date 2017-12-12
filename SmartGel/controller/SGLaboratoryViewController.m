//
//  SGLaboratoryViewController.m
//  SmartGel
//
//  Created by jordi on 05/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGLaboratoryViewController.h"
#import "SCLAlertView.h"
#import "SGConstant.h"
#import <ContactsUI/ContactsUI.h>
#import "MBProgressHUD.h"
#import "Firebase.h"

@interface SGLaboratoryViewController ()<UITextFieldDelegate,CNContactPickerDelegate>

@end

@implementation SGLaboratoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.laboratoryDataModel = [[LaboratoryDataModel alloc] init];
    [self initLocationManager];
    li=[self licheck];
    DIA = [[NSUserDefaults standardUserDefaults] integerForKey:@"DIAMETER"];
    if( [[NSUserDefaults standardUserDefaults] integerForKey:@"ugormg"]==0)
    {
        ugormg=FALSE;
        self.lblugormg.text = @"ug/cm2 Organic";
    }
    else
    {
        ugormg=TRUE;
        self.lblugormg.text = @"mg/l Organic";
    }
    
    vgood = [[NSUserDefaults standardUserDefaults] floatForKey:@"vgood"];
    satis = [[NSUserDefaults standardUserDefaults] floatForKey:@"satis"];
    vgoodlab = [[NSUserDefaults standardUserDefaults] stringForKey:@"vgoodlab"];
    satislab = [[NSUserDefaults standardUserDefaults] stringForKey:@"satislab"];
    inadeqlab = [[NSUserDefaults standardUserDefaults] stringForKey:@"inadeqlab"];
    
    R = [[NSUserDefaults standardUserDefaults] floatForKey:@"BlankR"];
    G = [[NSUserDefaults standardUserDefaults] floatForKey:@"BlankG"];
    B = [[NSUserDefaults standardUserDefaults] floatForKey:@"BlankB"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    firstrun=true;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    thePath = [rootPath stringByAppendingPathComponent:@"Data.xml"];
    
    NSMutableArray *bData = [[NSMutableArray alloc] initWithContentsOfFile:thePath];
    //NSLog(@"bd:%@",bData);
    
    int len;
    len = [bData count];
    
    if(len<=1)
    {
        //Ausgabe mit RGB
        NSArray *plistentries = [[NSArray alloc] initWithObjects:@"Date",@"Customer",@"Tag",@"Diameter",@"Result",@"UgorMg",@"BlankR",@"BlankG",@"BlankB",@"SampleR",@"SampleG",@"SampleB",nil];
        NSMutableArray *dData= [[NSMutableArray alloc] init];
        [dData addObject:plistentries];
        [dData writeToFile:thePath atomically:YES];
    }
}

-(void)initLocationManager{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             NSString *address = [NSString stringWithFormat:@"%@ %@,%@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];
             self.laboratoryDataModel.location = address;
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    self.laboratoryDataModel.image = image;
    self.laboratoryDataModel.date = [self getCurrentTimeString];
    [self estimateValue:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)launchCameraController{
    if(firstrun){
        [self capturePhoto];
    }else{

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@"Do you want to save the Result?"
                                                                preferredStyle:UIAlertControllerStyleAlert]; // 1
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showSaveAlertView];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self capturePhoto];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)choosePhotoPickerController{
    if(firstrun){
        [self loadPhoto];
    }else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@"Do you want to save the Result?"
                                                                preferredStyle:UIAlertControllerStyleAlert]; // 1
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showSaveAlertView];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self loadPhoto];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)capturePhoto{
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:NO completion:nil];
//    UIImage *image = [UIImage imageNamed:@"test.png"];
//    self.laboratoryDataModel.image = image;
//    self.laboratoryDataModel.date = [self getCurrentTimeString];
//
//    [self estimateValue:image];
}

-(void)loadPhoto{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:NO completion:nil];
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    return context;
}

- (void)estimateValue:(UIImage *)image{
    firstrun=false;
    CGImageRef ref = image.CGImage;
    CGContextRef bitmapcrop1 = [self createARGBBitmapContextFromImage:ref];
    if (bitmapcrop1 == NULL)
    {
        return;
    }
    
    size_t w = CGImageGetWidth(ref);
    size_t h = CGImageGetHeight(ref);
    CGRect rect = {{0,0},{w,h}};
    CGContextDrawImage(bitmapcrop1, rect, ref);
    unsigned char* data = CGBitmapContextGetData (bitmapcrop1);
    if (data != NULL)
    {
        
        //_________________________________________________________
        //BLANK Crop
        
        int xb=0,yb=0,rednewbx=0,greennewbx=0,bluenewbx=0,rednewby=0,greennewby=0,bluenewby=0,nb=0;
        //br = (width*width%/100)
        float br,bl,bt,bb;
        br=(w*20.0/100.0);
        bl=(w*35.0/100.0);
        bt=(h*75.0/100.0);//55
        bb=(h*90.0/100.0);//70
        
        for(yb=bt;yb<bb;yb++)
        {
            for(xb=br;xb<bl;xb++)
            {
                nb++;
                int offset = 4*((w*yb)+xb);
                int redb = data[offset+1];
                data[offset+1]=255;
                int greenb = data[offset+2];
                data[offset+2]=255;
                int blueb = data[offset+3];
                data[offset+3]=255;
                rednewbx=rednewbx+redb;
                greennewbx=greennewbx+greenb;
                bluenewbx=bluenewbx+blueb;
            }
            nb++;
            rednewby=rednewby+rednewbx;
            greennewby=greennewby+greennewbx;
            bluenewby=bluenewby+bluenewbx;
            rednewbx=0;greennewbx=0;bluenewbx=0;
        }
        
        int xs=0,ys=0,rednewsx=0,greennewsx=0,bluenewsx=0,rednewsy=0,greennewsy=0,bluenewsy=0,ns=0;
        float sr,sl,st,sb;
        sr=(w*70.0/100.0);
        sl=(w*85.0/100.0);
        st=(h*75.0/100.0);//55
        sb=(h*90.0/100.0);//70
        int alpha;
        for(ys=st;ys<sb;ys++)
        {
            for(xs=sr;xs<sl;xs++)
            {
                ns++;
                int offset = 4*((w*ys)+xs);
                alpha =  data[offset]; //maybe we need it?
                int reds = data[offset+1];
                data[offset+1]=255;
                int greens = data[offset+2];
                data[offset+1]=255;
                int blues = data[offset+3];
                data[offset+1]=255;
                rednewsx=rednewsx+reds;
                greennewsx=greennewsx+greens;
                bluenewsx=bluenewsx+blues;
            }
            ns++;
            rednewsy=rednewsy+rednewsx;
            greennewsy=greennewsy+greennewsx;
            bluenewsy=bluenewsy+bluenewsx;
            rednewsx=0; greennewsx=0; bluenewsx=0;
        }
        
        float sred,sgreen,sblue,bred,bgreen,bblue,ssred,ssgreen,ssblue,bbblue,bbgreen,bbred;
        bred=rednewby/(nb*255.0f);
        bgreen=greennewby/(nb*255.0f);
        bblue=bluenewby/(nb*255.0f);
        sred=rednewsy/(ns*255.0f);
        sgreen=greennewsy/(ns*255.0f);
        sblue=bluenewsy/(ns*255.0f);
        
        self.laboratoryDataModel.blankColor =((unsigned)(bred * 255) << 16) + ((unsigned)(bgreen * 255) << 8) + ((unsigned)(bblue * 255) << 0);
        self.laboratoryDataModel.sampleColor = ((unsigned)(sred * 255) << 16) + ((unsigned)(sgreen * 255) << 8) + ((unsigned)(sblue * 255) << 0);

        self.blankView.backgroundColor = [UIColor colorWithRed:bred green:bgreen blue:bblue alpha:1];
        self.sampleView.backgroundColor = [UIColor colorWithRed:sred green:sgreen blue:sblue alpha:1];
        
        ssred=rednewsy/ns;
        ssgreen=greennewsy/ns;
        ssblue=bluenewsy/ns;
        
        blankR=rednewby/nb;
        blankG=greennewby/nb;
        blankB=bluenewby/nb;
        
        sampleR=ssred;
        sampleG=ssgreen;
        sampleB=ssblue;
        
        bbred=rednewby/nb+R;//-4
        bbgreen=greennewby/nb+G;//-4
        bbblue=bluenewby/nb+B;//-7

        double E535_S,E435_S,E405_S,Mn7_S,Mn6_S,Mn2_S,E535_CS,E435_CS,E405_CS,Mn7_CS,Mn6_CS,Mn2_CS,I,T,RSF,mgl_CH2O,ug_cm2,Mn7R,ERR,maxmgl,maxug,RSFGO;
        I=4.07;
        T=8.53;
        // Diamter Berechnung
        DIA = [[NSUserDefaults standardUserDefaults] integerForKey:@"DIAMETER"];
        switch (DIA) {
            case 1:Diam=0.2;
                break;
            case 2:Diam=0.35;
                break;
            case 3:Diam=0.5;
                break;
            case 4:Diam=0.6;
                break;
            case 5:Diam=2.5;
                break;
            case 6:Diam=0.3175;
                break;
            case 7:Diam=0.47625;
                break;
            case 8:Diam=0.635;
                break;
            case 9:Diam=0.95252;
                break;
            case 10:Diam=1.27;
                break;
            default:Diam=0.5;
                break;
        }
        
        switch (DIA) {
            case 1:_diam=@"4mm";
                break;
            case 2:_diam=@"7mm";
                break;
            case 3:_diam=@"10mm";
                break;
            case 4:_diam=@"12mm";
                break;
            case 5:_diam=@"50mm";
                break;
            case 6:_diam=@"1/4\"";
                break;
            case 7:_diam=@"3/8\"";
                break;
            case 8:_diam=@"1/2\"";
                break;
            case 9:_diam=@"3/4\"";
                break;
            case 10:_diam=@"1\"";
                break;
            default:_diam=@"10mm";
                break;
        }
        
        ssgreen = (ssgreen+120)/2;
        bbgreen = (bbgreen+120)/2;
        
        ssblue = (ssblue+140)/2;
        bbblue = (bbblue+140)/2;
        
        
        // Berechnungsstufe 1_S:
        
        E535_S = ((-log10(((ssred/(I-4.0)*((T-4.0)*100.0/16.0*(-0.3327)+107.64)/100.0))/3205.0))*112.0+(-log10(((ssgreen/(I-4.0)*((T-4.0)*100.0/16.0*(-0.3327)+107.64)/100.0))/3205.0))*411.0)/100.0;
        E435_S = ((-log10(((ssred/(I-4)*((T-4)*100.0/16.0*(-0.3327)+107.64)/100))/3205))*35+(-log10(((ssblue/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*306)/100;
        E405_S = ((-log10(((ssred/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*130+(-log10(((ssblue/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*200)/100;
        
        // Berechnungsstufe 2_S:
        
        Mn7_S = (-1670.2*E535_S-1969.1*E435_S+4201.7*E405_S)/(-26606.7);
        Mn6_S = (-555.1*E535_S-5931*E435_S+8130.7*E405_S)/(26606.7);
        Mn2_S = (E535_S-26.6*(-1670.2*E535_S-1969.1*E435_S+4201.7*E405_S)/(-26606.7)-20*(-555.1*E535_S-5931*E435_S+8130.7*E405_S)/(26606.7))/18.3;
        
        // Berechnungsstufe 1_CS:
        
        E535_CS = ((-log10(((bbred/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*112+(-log10(((bbgreen/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*411)/100;
        E435_CS = ((-log10(((bbred/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*35+(-log10(((bbblue/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*306)/100;
        E405_CS = ((-log10(((bbred/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*130+(-log10(((bbblue/(I-4)*((T-4)*100/16*(-0.3327)+107.64)/100))/3205))*200)/100;
        
        // Berechnungsstufe 2_CS:
        
        Mn7_CS = (-1670.2*E535_CS-1969.1*E435_CS+4201.7*E405_CS)/(-26606.7);
        Mn6_CS = (-555.1*E535_CS-5931*E435_CS+8130.7*E405_CS)/(26606.7);
        Mn2_CS = (E535_CS-26.6*(-1670.2*E535_CS-1969.1*E435_CS+4201.7*E405_CS)/(-26606.7)-20*(-555.1*E535_CS-5931*E435_CS+8130.7*E405_CS)/(26606.7))/18.3;
        
        // Berechnungsstufe 3:
        
        RSF = (Mn6_S - Mn6_CS) + ((Mn2_S - Mn2_CS)*4);
        Mn7R = (Mn7_CS - Mn7_S);
        ERR = abs((Mn7R-RSF)*100/Mn7R);
        
        if(RSF*7.5<0.38)
        {   RSFGO = (RSF*7.5);
        }else
        {
            RSFGO = (RSF*7.5)*1.5-0.13;
        }
        mgl_CH2O = RSFGO;
        ug_cm2 = (RSFGO*1000)/(2*1000/(Diam));
        
        maxmgl=0.2*7.5;
        maxug=(0.2*7.5*1000)/(2*1000/(Diam));
        li = true;
        if(li)
        {
            if([[NSUserDefaults standardUserDefaults] integerForKey:@"ugormg"]==0)
            {
                if(RSF<=0.2)
                {
                    self.resultValueLabel.text =[ NSString stringWithFormat:@"%.2f",ug_cm2];
                }else{
                    self.resultValueLabel.text =[ NSString stringWithFormat:@"> %.2f",maxug];
                }
                self.lbldiam.text=[NSString stringWithFormat:@"%@", _diam];
                if(ug_cm2 < vgood)
                {
                    self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_pink.png"];
                    self.laboratoryDataModel.resultState = 1;
                }else{
                    if(ug_cm2 < satis){
                    self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_green.png"];
                        self.laboratoryDataModel.resultState = 2;
                    }else{
                        self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_yellow.png"];
                        self.laboratoryDataModel.resultState = 3;
                    }
                }
            }
            else
            {
                if(RSF<=0.2)
                {
                    self.resultValueLabel.text =[ NSString stringWithFormat:@"%.2f",mgl_CH2O];
                }
                else
                {
                    self.resultValueLabel.text =[ NSString stringWithFormat:@"> %.2f",maxmgl];
                }
                self.resultfoxImageView.image=nil;
                self.lbldiam.text=@"";
            }
        }
        else
        {
            self.resultValueLabel.text=@"---";
            if(ug_cm2 <= 0.01)
            {
                self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_pink.png"];
                self.laboratoryDataModel.resultState = 1;
            }else{
                if(ug_cm2 < maxug)
                {
                    self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_green.png"];
                    self.laboratoryDataModel.resultState = 2;

                }else{
                    self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_yellow.png"];
                    self.laboratoryDataModel.resultState = 3;
                }
            }
            self.lblugormg.text = @"";
        }
    }
    if (data)
    {
        free(data);
    }
    CGContextRelease(bitmapcrop1);
    self.laboratoryDataModel.resultValue = [self.resultValueLabel.text floatValue];
}

- (BOOL)licheck
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lkeyI = [defaults stringForKey:@"lkey"];
    //    NSString *aresult = [[[UIDevice currentDevice] uniqueIdentifier] stringByReplacingOccurrencesOfString:@"a" withString:@""];
    NSString *aresult = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"a" withString:@""];
    NSString *bresult = [aresult stringByReplacingOccurrencesOfString:@"b" withString:@""];
    NSString *cresult = [bresult stringByReplacingOccurrencesOfString:@"c" withString:@""];
    NSString *dresult = [cresult stringByReplacingOccurrencesOfString:@"d" withString:@""];
    NSString *eresult = [dresult stringByReplacingOccurrencesOfString:@"e" withString:@""];
    NSString *fresult = [eresult stringByReplacingOccurrencesOfString:@"f" withString:@""];
    
    int l = [fresult length];
    
    NSString *nr1 = [fresult substringFromIndex:l-2];
    NSString *nr2 = [[fresult substringFromIndex:l-4] substringToIndex:2];
    NSString *nr3 = [[fresult substringFromIndex:l-6] substringToIndex:2];
    NSString *nr4 = [[fresult substringFromIndex:l-8] substringToIndex:2];
    NSString *nr5 = [[fresult substringFromIndex:l-10] substringToIndex:2];
    NSString *nr6 = [[fresult substringFromIndex:l-12] substringToIndex:2];
    NSString *nr7 = [[fresult substringFromIndex:l-14] substringToIndex:2];
    NSString *nr8 = [[fresult substringFromIndex:l-16] substringToIndex:2];
    NSString *nr9 = [[fresult substringFromIndex:l-18] substringToIndex:2];
    NSString *nr10 = [fresult substringToIndex:l-(l-2)];
    
    NSArray *nrs = [[NSArray alloc] initWithObjects:nr1,nr2,nr3,nr4,nr5,nr6,nr7,nr8,nr9,nr10,nil];
    int i;
    NSMutableArray *LK= [[NSMutableArray alloc] init];
    
    for(i=0;i<10;i++)
    {
        float nrn = [[nrs objectAtIndex:i] floatValue]/99.0*25.0;
        if(nrn<=0)
        {
            [LK addObject:@"A"];
        }
        else
        {
            if(nrn<=1)
            {
                [LK addObject:@"B"];
            }else
            {
                if(nrn<=2)
                {
                    [LK addObject:@"C"];
                }else
                {
                    if(nrn<=3)
                    {
                        [LK addObject:@"D"];
                    }else
                    {
                        if(nrn<=4)
                        {
                            [LK addObject:@"E"];
                        }else
                        {
                            if(nrn<=5)
                            {
                                [LK addObject:@"F"];
                            }else
                            {
                                if(nrn<=6)
                                {
                                    [LK addObject:@"G"];
                                }else
                                {
                                    if(nrn<=7)
                                    {
                                        [LK addObject:@"H"];
                                    }else
                                    {
                                        if(nrn<=8)
                                        {
                                            [LK addObject:@"I"];
                                        }else
                                        {
                                            if(nrn<=9)
                                            {
                                                [LK addObject:@"J"];
                                            }else
                                            {
                                                if(nrn<=10)
                                                {
                                                    [LK addObject:@"K"];
                                                }else
                                                {
                                                    if(nrn<=11)
                                                    {
                                                        [LK addObject:@"L"];
                                                    }else
                                                    {
                                                        if(nrn<=12)
                                                        {
                                                            [LK addObject:@"M"];
                                                        }else
                                                        {
                                                            if(nrn<=13)
                                                            {
                                                                [LK addObject:@"N"];
                                                            }else
                                                            {
                                                                if(nrn<=14)
                                                                {
                                                                    [LK addObject:@"O"];
                                                                }else
                                                                {
                                                                    if(nrn<=15)
                                                                    {
                                                                        [LK addObject:@"P"];
                                                                    }else
                                                                    {
                                                                        if(nrn<=16)
                                                                        {
                                                                            [LK addObject:@"Q"];
                                                                        }else
                                                                        {
                                                                            if(nrn<=17)
                                                                            {
                                                                                [LK addObject:@"R"];
                                                                            }else
                                                                            {
                                                                                if(nrn<=18)
                                                                                {
                                                                                    [LK addObject:@"S"];
                                                                                }else
                                                                                {
                                                                                    if(nrn<=19)
                                                                                    {
                                                                                        [LK addObject:@"T"];
                                                                                    }else
                                                                                    {
                                                                                        if(nrn<=20)
                                                                                        {
                                                                                            [LK addObject:@"U"];
                                                                                        }else
                                                                                        {
                                                                                            if(nrn<=21)
                                                                                            {
                                                                                                [LK addObject:@"V"];
                                                                                            }else
                                                                                            {
                                                                                                if(nrn<=22)
                                                                                                {
                                                                                                    [LK addObject:@"W"];
                                                                                                }else
                                                                                                {
                                                                                                    if(nrn<=23)
                                                                                                    {
                                                                                                        [LK addObject:@"X"];
                                                                                                    }else
                                                                                                    {
                                                                                                        if(nrn<=24)
                                                                                                        {
                                                                                                            [LK addObject:@"Y"];
                                                                                                        }else
                                                                                                        {
                                                                                                            if(nrn<=25)
                                                                                                            {
                                                                                                                [LK addObject:@"Z"];
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if([LK count]>=10)
    {
        if([lkeyI isEqualToString:[NSString stringWithFormat:@"%@%@%@%@-%@%@%@-%@%@%@",[LK objectAtIndex:0],[LK objectAtIndex:1],[LK objectAtIndex:2],[LK objectAtIndex:3],[LK objectAtIndex:4],[LK objectAtIndex:5],[LK objectAtIndex:6],[LK objectAtIndex:7],[LK objectAtIndex:8],[LK objectAtIndex:9]]]){
            return TRUE;
        }else{
            return FALSE;
        }
    }else{
        return FALSE;
    }
}

- (void)showSaveAlertView{

    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = SGColorBlack;
    alert.iconTintColor = [UIColor whiteColor];
    alert.tintTopCircle = NO;
    alert.backgroundViewColor = SGColorDarkGray;
    alert.view.backgroundColor = SGColorDarkGray;
    alert.backgroundType = SCLAlertViewBackgroundTransparent;

    alert.labelTitle.textColor = [UIColor whiteColor];
    self.tagTextField = [alert addTextField:@"Type Tag in here!"];
    self.customerTextField = [alert addTextField:@"no Customer Selected!"];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(customerTextFieldTapped)];
    [self.customerTextField addGestureRecognizer:singleFingerTap];
    [alert addButton:@"Done" actionBlock:^(void) {
        self.laboratoryDataModel.tag = self.tagTextField.text;
        self.laboratoryDataModel.customer = self.customerTextField.text;
        [self saveLaboratoryDatas];
    }];
    [alert showEdit:self title:@"TAG YOUR RESULT" subTitle:nil closeButtonTitle:@"Cancel" duration:0.0f];
}

-(void)customerTextFieldTapped{
    [self launchContactPickerViewController];
}

-(void) contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    self.customerTextField.text = contact.givenName;
}

-(void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
}

-(void)launchContactPickerViewController{
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    contactPicker.delegate = self;
    contactPicker.displayedPropertyKeys = @[CNContactGivenNameKey];
    [self presentViewController:contactPicker animated:YES completion:nil];
}

-(void)saveLaboratoryDatas{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Uploading image...";
    FIRStorageReference *riversRef = [self.appDelegate.storageRef child:[NSString stringWithFormat:@"%@/%@.png",self.appDelegate.userID,self.laboratoryDataModel.date]];
    NSData *imageData = UIImageJPEGRepresentation(self.laboratoryDataModel.image,0.7);
    [riversRef putData:imageData
              metadata:nil
            completion:^(FIRStorageMetadata *metadata,NSError *error) {
                [hud hideAnimated:false];
                if (error != nil) {
                    [self showAlertdialog:@"Image Uploading Failed!" message:error.localizedDescription];
                } else {
                    [self showAlertdialog:@"Image Uploading Success!" message:error.localizedDescription];
                    NSString *key = self.appDelegate.userID;
                    NSDictionary *post = @{@"value": [NSString stringWithFormat:@"%.1f",self.laboratoryDataModel.resultValue],
                                           @"image": metadata.downloadURL.absoluteString,
                                           @"tag": self.laboratoryDataModel.tag,
                                           @"islaboratory" : @"1",
                                           @"customer": self.laboratoryDataModel.customer,
                                           @"date": self.laboratoryDataModel.date,
                                           @"location": self.laboratoryDataModel.location,
                                           @"blankcolor":[NSString stringWithFormat:@"%lld",self.laboratoryDataModel.blankColor],
                                           @"samplecolor":[NSString stringWithFormat:@"%lld",self.laboratoryDataModel.sampleColor],
                                           @"resultstate":[NSString stringWithFormat:@"%d",self.laboratoryDataModel.resultState]
                                           };
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@", key,self.laboratoryDataModel.date]: post};
                    [self.appDelegate.ref updateChildValues:childUpdates];
                }
            }];

}

@end
