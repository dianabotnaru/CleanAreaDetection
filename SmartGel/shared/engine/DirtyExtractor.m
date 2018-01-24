//
//  ExtractDirty.m
//  grayscale test
//
//  Created by jordi on 4/10/17.
//  Copyright © 2017 afco. All rights reserved.
//

#import "DirtyExtractor.h"
#import "SGConstant.h"
#import "GPUImage.h"
#include <math.h>

#define NO_DIRTY_PIXEL          0x0
#define PINK_DIRTY_PIXEL        0xFF00FFFF
#define BLUE_DIRTY_PIXEL        0x00FFFFFF

#define PIXEL_STEP              3
#define AREA_DIRTY_RATE      0.8

#define MAX_DIRTY_VALUE         10.0f

#define MIN_LOCAL_AREA_PERCENT  0.01f

#define PINK_COLOR_OFFSET  25.0f


@implementation DirtyExtractor

- (id) init
{
    self = [super init];
    return self;
}

-(instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if(self){
        m_nNoGelCount = 0;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *colorOffset = [defaults objectForKey:@"coloroffset"];
        if(colorOffset == nil){
            self.m_colorOffset = SGDefaultColorOffset;
        }else{
            self.m_colorOffset = [colorOffset intValue];
        }
        [self reset];
//        [self importImage:[self gpuImageFilter:image]];
        [self importImage:image];
        [self extract];
    }
    return self;
}

-(instancetype)initWithImage:(UIImage *)image withColoroffset:(int)coloroffset{
    self = [super init];
    if(self){
        self.m_colorOffset = coloroffset;
        [self reset];

        //        [self importImage:[self gpuImageFilter:image]];
        [self importImage:image];
        [self extract];
    }
    return self;
}


- (void) dealloc
{
    [self reset];
}

- (void) reset
{
    _cleanValue = 0.0f;
    
    m_imageWidth = 0;
    m_imageHeight = 0;
    
    m_nPinkCount = 0;
    m_nBlueCount = 0;
    
    _areaCleanState = [[NSMutableArray alloc] init];
    _originalAreaCleanState = [[NSMutableArray alloc] init];

    if (m_pInBuffer)
    {
        free (m_pInBuffer);
        m_pInBuffer = NULL;
    }
    
    if (m_pOutBuffer)
    {
        free (m_pOutBuffer);
        m_pOutBuffer = NULL;
    }
}

- (void) importImage:(UIImage *)image
{
    m_imageWidth = image.size.width;
    m_imageHeight = image.size.height;
    
    m_pInBuffer = (UInt32 *)calloc(sizeof(UInt32), m_imageWidth * m_imageHeight);
    m_pOutBuffer = (UInt32 *)calloc(sizeof(UInt32), m_imageWidth * m_imageHeight);
    
    int nBytesPerRow = m_imageWidth * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(m_pInBuffer, m_imageWidth, m_imageHeight, 8, nBytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_imageWidth, m_imageHeight), image.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
}

- (void)extract
{
    [self smoothBufferByAverage];
    for(int x = 0; x<AREA_DIVIDE_NUMBER;x++){
        for(int y = 0; y<AREA_DIVIDE_NUMBER;y++){
            if([self areaFiltering:x withYPoint:y] == IS_CLEAN)
                m_nPinkCount++;
        }
    }
    for(int i =0;i<_originalAreaCleanState.count;i++){
        [_areaCleanState addObject:[_originalAreaCleanState objectAtIndex:i]];
    }
    [self calculateDirtyValue];
}

- (int)areaFiltering :(int)xPoint withYPoint:(int)yPoint
{
    UInt32 * pPixelBuffer = m_donePreprocess ? m_pOutBuffer : m_pInBuffer;
    int cleanCount = 0;
    int dirtyCount = 0;

    for (int y = (yPoint*m_imageHeight/AREA_DIVIDE_NUMBER); y < ((yPoint+1)*m_imageHeight/AREA_DIVIDE_NUMBER); y++)
    {
        for (int x = (xPoint*m_imageWidth/AREA_DIVIDE_NUMBER); x < ((xPoint+1)*m_imageWidth/AREA_DIVIDE_NUMBER); x++)
        {
            int index = y * m_imageWidth + x;
            
            RGBA rgba;
            memcpy(&rgba, &pPixelBuffer[index], sizeof(RGBA));
            
            UInt32 dirtyPixel = [self getDirtyPixel:&rgba];
            if (dirtyPixel == PINK_DIRTY_PIXEL ){
                cleanCount ++;
            }else if(dirtyPixel == BLUE_DIRTY_PIXEL){
                dirtyCount ++;
            }
        }
    }
    
    if(cleanCount>AREA_DIRTY_RATE* m_imageHeight*m_imageWidth/(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER)){
        for (int y = (yPoint*m_imageHeight/AREA_DIVIDE_NUMBER); y < ((yPoint+1)*m_imageHeight/AREA_DIVIDE_NUMBER); y++)
        {
            for (int x = (xPoint*m_imageWidth/AREA_DIVIDE_NUMBER); x < ((xPoint+1)*m_imageWidth/AREA_DIVIDE_NUMBER); x++)
            {
                int index = y * m_imageWidth + x;
                RGBA rgba;
                memcpy(&rgba, &pPixelBuffer[index], sizeof(RGBA));
                m_pOutBuffer[index] = PINK_DIRTY_PIXEL;
            }
        }
        [_originalAreaCleanState addObject:@(IS_CLEAN)];
        return IS_CLEAN;
    }else {
        [_originalAreaCleanState addObject:@(IS_DIRTY)];
        return IS_DIRTY;
    }
    
}

- (void)smoothBufferByAverage
{
    int pixelStep = PIXEL_STEP;
    for (int y = 0; y < m_imageHeight; y += pixelStep)
    {
        for(int x = 0; x < m_imageWidth; x+= pixelStep)
        {
            int endX = MIN(m_imageWidth, x + pixelStep);
            int endY = MIN(m_imageHeight, y + pixelStep);
            
            int sR = 0;
            int sG = 0;
            int sB = 0;
            int nCount = 0;
            for (int yy = y; yy < endY; yy++)
            {
                for (int xx = x; xx < endX; xx++)
                {
                    RGBA rgba;
                    int index = yy * m_imageWidth + xx;
                    memcpy(&rgba, &m_pInBuffer[index], sizeof(RGBA));
                    sR += rgba.r;
                    sG += rgba.g;
                    sB += rgba.b;
                    
                    nCount++;
                }
            }
            
            RGBA averageRGB;
            averageRGB.r = sR / nCount;
            averageRGB.g = sG / nCount;
            averageRGB.b = sB / nCount;
            
            for (int yy = y; yy < endY; yy++)
            {
                for (int xx = x; xx < endX; xx++)
                {
                    int index = yy * m_imageWidth + xx;
                    memcpy(&m_pOutBuffer[index], &averageRGB, sizeof(RGBA));
                }
            }
        }
    }
    m_donePreprocess = YES;
}

- (void) calculateDirtyValue{
    m_nPinkCount = 0;
    m_nNoGelCount = 0;
    for(int i =0;i<_areaCleanState.count;i++){
        int areaState = [[_areaCleanState objectAtIndex:i] intValue];
        if(areaState == IS_CLEAN)
            m_nPinkCount++;
        else if(areaState == NO_GEL)
            m_nNoGelCount++;
    }
    float totalCount = (float)((AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER)-m_nNoGelCount);
    if(totalCount!=0)
        _cleanValue =  10*(float)m_nPinkCount / totalCount;
    else
        _cleanValue = 0;
}

- (UIImage *) exportImage
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(m_pOutBuffer, m_imageWidth, m_imageHeight, 8, m_imageWidth * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    return resultUIImage;
}

- (UInt32)   getDirtyPixel:(RGBA *)rgba
{
    UInt8 minValue = 0x4F;
    if (rgba->r < minValue && rgba->g < minValue && rgba->b < minValue)
        return BLUE_DIRTY_PIXEL;

    int yellowValue = rgba->r + rgba->g;
    int greenValue = rgba->g + rgba->b;
    int pinkValue = rgba->r + rgba->b;

    BOOL isPinkSerial = pinkValue > greenValue;
    if (isPinkSerial)
    {
        if(pinkValue>(yellowValue-self.m_colorOffset))
            return PINK_DIRTY_PIXEL;
        else
            return BLUE_DIRTY_PIXEL;
//        float distance = [self getDistanceWithPinkColor:rgba];
//        if(distance<PINK_COLOR_OFFSET)
//            return PINK_DIRTY_PIXEL;
//        else
//            return NO_DIRTY_PIXEL;

    }
    else //means green serial
    {
        return BLUE_DIRTY_PIXEL;
    }
}


-(void)setNonGelAreaState:(NSMutableArray *)nonGelAreaArray{
    m_nNoGelCount = 0;
//    [_areaCleanState removeAllObjects];
//    for(int i =0;i<_originalAreaCleanState.count;i++){
//        [_areaCleanState addObject:[_originalAreaCleanState objectAtIndex:i]];
//    }
    for(int i=0;i<nonGelAreaArray.count;i++){
        bool isNonGel = [[nonGelAreaArray objectAtIndex:i] boolValue];
        if(isNonGel){
            int pointX = i/SGGridCount;
            int pointY = i%SGGridCount;
            int rate = AREA_DIVIDE_NUMBER/SGGridCount;
            m_nNoGelCount+= rate*rate;
            for(int i = 0; i<rate;i++){
                for(int j = 0; j< rate; j++){
                    NSUInteger postion = AREA_DIVIDE_NUMBER*rate*pointX+(i*AREA_DIVIDE_NUMBER)+(rate*pointY+j);
                    [_areaCleanState replaceObjectAtIndex:postion withObject:@(NO_GEL)];
                }
            }
        }
    }
    [self calculateDirtyValue];
}

-(void)addCleanArea:(int)touchPosition{
    int pointX = touchPosition/SGGridCount;
    int pointY = touchPosition%SGGridCount;
    int rate = AREA_DIVIDE_NUMBER/SGGridCount;
    for(int i = 0; i<rate;i++){
        for(int j = 0; j< rate; j++){
            NSUInteger postion = AREA_DIVIDE_NUMBER*rate*pointX+(i*AREA_DIVIDE_NUMBER)+(rate*pointY+j);
            [_areaCleanState replaceObjectAtIndex:postion withObject:@(IS_CLEAN)];
        }
    }
    [self calculateDirtyValue];
}

- (XYZ)getXYZfromRGB : (RGBA *)rgbColor{
    
    float red = (float)rgbColor->r/255;
    float green = (float)rgbColor->g/255;
    float blue = (float)rgbColor->b/255;
    
    // adjusting values
    if(red>0.04045){
        red = (red+0.055)/1.055;
        red = pow(red,2.4);
    }
    else{
        red = red/12.92;
    }
    if(green>0.04045){
        green = (green+0.055)/1.055;
        green = pow(green,2.4);
    }
    else{
        green = green/12.92;
    }
    if(blue>0.04045){
        blue = (blue+0.055)/1.055;
        blue = pow(blue,2.4);
    }
    else{
        blue = blue/12.92;
    }

    red *= 100;
    green *= 100;
    blue *= 100;
    
    XYZ xyzColor;
    // applying the matrix
    xyzColor.x = red * 0.4124 + green * 0.3576 + blue * 0.1805;
    xyzColor.y = red * 0.2126 + green * 0.7152 + blue * 0.0722;
    xyzColor.z = red * 0.0193 + green * 0.1192 + blue * 0.9505;
    return xyzColor;
}

-(LAB)getLABfromXYZ: (XYZ)xyzColor{
    float $_x = xyzColor.x/95.047;
    float $_y = xyzColor.y/100;
    float $_z = xyzColor.z/108.883;
    
    // adjusting the values
    if($_x>0.008856){
        $_x = pow($_x,(float)1/3);
    }
    else{
        $_x = 7.787*$_x + 16/116;
    }
    if($_y>0.008856){
        $_y = pow($_y,(float)1/3);
    }
    else{
        $_y = (7.787*$_y) + (16/116);
    }
    if($_z>0.008856){
        $_z = pow($_z,(float)1/3);
    }
    else{
        $_z = 7.787*$_z + 16/116;
    }
    LAB labColor;
    labColor.l= 116*$_y -16;
    labColor.a= 500*($_x-$_y);
    labColor.b= 200*($_y-$_z);
    return labColor;
}

-(float)getDistanceWithPinkColor:(RGBA *)rgba{
    RGBA pinkRgb;
    
    pinkRgb.r = 255;
    pinkRgb.g = 105;
    pinkRgb.b = 180;
    
    XYZ xyzPink = [self getXYZfromRGB:&pinkRgb];
    XYZ xyz1 = [self getXYZfromRGB:rgba];
    LAB labPink = [self getLABfromXYZ:xyzPink];
    LAB lab1 = [self getLABfromXYZ:xyz1];
    
//    float l = labPink.l - lab1.l;
//    float a = labPink.a - lab1.a;
//    float b = labPink.b - lab1.b;

//    float distance = sqrt((l*l)+(a*a)+(b*b));
    float distance = [self getDeltaE:labPink withLab2:lab1];
    return distance;
}

-(float)getDeltaE:(LAB)labl
         withLab2:(LAB)lab2{
    float deltaL = labl.l - lab2.l;
    float deltaA = labl.a - lab2.a;
    float deltaB = labl.b - lab2.b;
    float c1 = sqrt(labl.a * labl.a + labl.b * labl.b);
    float c2 = sqrt(lab2.a * lab2.a + lab2.b * lab2.b);
    float deltaC = c1 - c2;
    float deltaH = deltaA * deltaA + deltaB * deltaB - deltaC * deltaC;
    deltaH = deltaH < 0 ? 0 : sqrt(deltaH);
    float sc = 1.0 + 0.045 * c1;
    float sh = 1.0 + 0.015 * c1;
    float deltaLKlsl = (float)deltaL / (1.0);
    float deltaCkcsc = (float)deltaC / (sc);
    float deltaHkhsh = (float)deltaH / (sh);
    float i = deltaLKlsl * deltaLKlsl + deltaCkcsc * deltaCkcsc + deltaHkhsh * deltaHkhsh;
    return i < 0 ? 0 : sqrt(i);
}

- (UIImage *)gpuImageFilter:(UIImage *)image{
    GPUImageGammaFilter *filter = [[GPUImageGammaFilter alloc] init];
    [(GPUImageGammaFilter *)filter setGamma:2.0];
    image = [filter imageByFilteringImage:image];
    return image;
}

@end
