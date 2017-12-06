//
//  SGLaboratoryViewController.m
//  SmartGel
//
//  Created by jordi on 05/12/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGLaboratoryViewController.h"

@interface SGLaboratoryViewController ()

@end

@implementation SGLaboratoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)launchPhotoPickerController{
    //    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    //    imagePickerController.delegate = self;
    //    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    [self presentViewController:imagePickerController animated:NO completion:nil];
    
    UIImage *image = [UIImage imageNamed:@"test.png"];
    [self estimateValue:image];
    
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
    firstrun=1;
    //imageView.image = image;
    //UIColor* color=nil;
    CGImageRef ref = image.CGImage;
    CGContextRef bitmapcrop1 = [self createARGBBitmapContextFromImage:ref];
    //CGContextRef bitmapcrop1 = CreateARGBBitmapContext(ref);
    if (bitmapcrop1 == NULL)
    {
        //NSLog(@"Error Creating ContextRef");
        // error creating context
        return;
    }
    
    size_t w = CGImageGetWidth(ref);
    size_t h = CGImageGetHeight(ref);
    CGRect rect = {{0,0},{w,h}};
    CGContextDrawImage(bitmapcrop1, rect, ref);
    
    //NSLog(@"w ,%i h, %i",w,h);
    
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
            {nb++;
                int offset = 4*((w*yb)+xb);
                //int alpha =  data[offset]; maybe we need it?
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
            rednewbx=0,greennewbx=0,bluenewbx=0;
        }
        
        //NSLog(@"Blank: Pixels:%i crop:%f:%f:%f:%f",nb,br,bt,bl,bb);
        
        
        //________________________________________________________
        
        //SAMPLE Crop
        
        int xs=0,ys=0,rednewsx=0,greennewsx=0,bluenewsx=0,rednewsy=0,greennewsy=0,bluenewsy=0,ns=0;
        //sr = (width*width%/100)
        float sr,sl,st,sb;
        sr=(w*70.0/100.0);
        sl=(w*85.0/100.0);
        st=(h*75.0/100.0);//55
        sb=(h*90.0/100.0);//70
        int alpha;
        
        for(ys=st;ys<sb;ys++)
        {
            for(xs=sr;xs<sl;xs++)
            {ns++;
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
            rednewsx=0,greennewsx=0,bluenewsx=0;
        }
        
        //NSLog(@"BLANK:%i:%i:%i:SAMPLE:%i:%i:%i",rednewby/nb, greennewby/nb,bluenewby/nb,rednewsy/ns, greennewsy/ns,bluenewsy/ns);
        //result.text = [NSString stringWithFormat:@"%ix%i",w,h];
        //result2.text = [NSString stringWithFormat:@"BLANK:%i:%i:%i  SAMPLE:%i:%i:%i",rednewby/nb, greennewby/nb,bluenewby/nb,rednewsy/ns, greennewsy/ns,bluenewsy/ns];
        
        
        float sred,sgreen,sblue,bred,bgreen,bblue,ssred,ssgreen,ssblue,bbblue,bbgreen,bbred;
        bred=rednewby/(nb*255.0f);
        bgreen=greennewby/(nb*255.0f);
        bblue=bluenewby/(nb*255.0f);
        sred=rednewsy/(ns*255.0f);
        sgreen=greennewsy/(ns*255.0f);
        sblue=bluenewsy/(ns*255.0f);
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
        
        
        
        
        /*double LD,RB,RS,GB,GS,MN2S,V1M,S1M,IZERO550,IZERO625,IATT550B,IATT550S,IATT625B,IATT625S,ABS550B,ABS550S,ABS625B,ABS625S,MN7B,MN7S,MN6B,MN6S,RSF,MGL_ORG,UGCM2_ORG;
         
         float MN2Q=3.00;
         float RGIZero=160.00;
         
         float WR550=163.00;
         float WG550=296.00;
         float WR625=352.00;
         float WG625=98.00;
         
         float M550_7=0.212;
         float M625_7=0.169;
         float M550_6=0.1;
         float M625_6=0.222;
         
         float DIV=0.03;
         float MNREF=0.114;
         
         
         RS=ssred;
         RB=bbred;
         GS=ssgreen;
         GB=bbgreen;
         
         IZERO550=(RGIZero*WR550+RGIZero*WG550)/1000;
         IZERO625=(RGIZero*WR625+RGIZero*WG625)/1000;
         IATT550B=(RB*WR550+GB*WG550)/1000;
         IATT550S=(RS*WR550+GS*WG550)/1000;
         IATT625B=(RB*WR625+GB*WG625)/1000;
         IATT625S=(RS*WR625+GS*WG625)/1000;
         
         ABS550B=(-log10(IATT550B/IZERO550));
         ABS625B=(-log10(IATT625B/IZERO625));
         ABS550S=(-log10(IATT550S/IZERO550));
         ABS625S=(-log10(IATT625S/IZERO625));
         
         MN7B=((M550_7*ABS550B-M625_7*ABS625B)/DIV)*MNREF;
         MN7S=((M550_7*ABS550S-M625_7*ABS625S)/DIV)*MNREF;
         MN6B=((M550_6*ABS550B-M625_6*ABS625B)/DIV)*MNREF;
         MN6S=-(((M550_6*ABS550S-M625_6*ABS625S)/DIV)*MNREF);
         //NSLog(@"ABS:%.3f;%.3f;%.3f;%.3f",ABS550B,ABS625B,ABS550S,ABS625S);
         //NSLog(@"MN:%.3f;%.3f;%.3f;%.3f",MN7B,MN7S,MN6B,MN6S);
         
         MN2S=(MN7B+MN6B)-(MN7S+MN6S);
         //IF MN2S <0 THEN MN2S=0;
         if(MN2S<=0)
         {MN2S=0;
         }
         //NSLog(@"MN2S%.3f",MN2S);
         
         
         RSF=(MN6S+4*MN2Q*MN2S)-MN6B;
         
         MGL_ORG=RSF*7.5;
         
         V1M=((LD/20)*(LD/20))*3.1415/10;
         S1M=(LD/10)*3.1415*100;
         
         UGCM2_ORG=(MGL_ORG*V1M*1000)/S1M;*/
        
        
        
        
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
        
        // Berechnungsstufe 4:
        /*if (ERR < 20)
         {
         CEQU = (RSF + Mn7R) / 2;
         }
         else
         {
         if (ERR > 20 && ssgreen > ssblue)
         {
         CEQU = RSF;
         }
         else
         {
         CEQU = Mn7R;
         }
         }*/
        // Berechnungsstufe 5:
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
        /*
         NSLog([NSString stringWithFormat:@"RSF %.2f",RSF]);
         NSLog([NSString stringWithFormat:@"maxug %.2f",maxug]);
         NSLog([NSString stringWithFormat:@"maxmg %.2f",maxmgl]);
         NSLog([NSString stringWithFormat:@"ug %.2f",ug_cm2]);
         NSLog([NSString stringWithFormat:@"mg %.2f",mgl_CH2O]);
         NSLog([NSString stringWithFormat:@"dia %.2f",Diam]);
         NSLog([NSString stringWithFormat:@"dia %.2f",Diam]);
         */
        li = true;
        if(li)
        {
            if([[NSUserDefaults standardUserDefaults] integerForKey:@"ugormg"]==0)
            {
                if(RSF<=0.2)
                {
                    
                    self.resultValueLabel.text =[ NSString stringWithFormat:@"%.2f",ug_cm2];
                }else
                {
                    self.resultValueLabel.text =[ NSString stringWithFormat:@"> %.2f",maxug];
                }
//                reslabel.hidden = FALSE;
//                resultfox.hidden = FALSE;
                self.lbldiam.text=[NSString stringWithFormat:@"%@", _diam];
                if(ug_cm2 < vgood)
                {
                    
                    self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_pink.png"];
//                    reslabel.text = vgoodlab;
                    
                }else
                {if(ug_cm2 < satis)
                {
                    self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_green.png"];
//                    reslabel.text = satislab;
                    
                }else
                {
                    self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_yellow.png"];
//                    reslabel.text = inadeqlab;
                }
                }
                
                
            }else
            {
                if(RSF<=0.2)
                {
                    self.resultValueLabel.text =[ NSString stringWithFormat:@"%.2f",mgl_CH2O];
                }else
                {
                    self.resultValueLabel.text =[ NSString stringWithFormat:@"> %.2f",maxmgl];
                }
//                reslabel.hidden=TRUE;
                self.resultfoxImageView.image=nil;
                self.lbldiam.text=@"";
            }
        }else
        {
            self.resultValueLabel.text=@"---";
            if(ug_cm2 <= 0.01)
            {
                self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_pink.png"];
                
            }else
            {if(ug_cm2 < maxug)
            {
                self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_green.png"];
                
            }else
            {
                self.resultfoxImageView.image = [UIImage imageNamed:@"Smiley_yellow.png"];
            }
            }
            
            self.lblugormg.text = @"";
            //reslabel.hidden=TRUE;
        }
        
        // Datum
        static NSDateFormatter *dateFormatter = nil;
        NSDate *today = [NSDate date];
        
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        }
//        timeLabel.text = [dateFormatter stringFromDate:today];
//        save.enabled=TRUE;
        //int xb=0,yb=0,rednewbx=0,greennewbx=0,bluenewbx=0,rednewby=0,greennewby=0,bluenewby=0,nb=0;
        //double E535_S,E435_S,E405_S,Mn7_S,Mn6_S,Mn2_S,E535_CS,E435_CS,E405_CS,Mn7_CS,Mn6_CS,Mn2_CS,I,T,RSF,CEQU,mgl_CH2O,Mn7R,ERR;
        
    }
    
    
//    if(picorimg)
//    {
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//    }
    // Free image data memory for the context
    if (data)
    {
        free(data);
    }
    CGContextRelease(bitmapcrop1);
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
