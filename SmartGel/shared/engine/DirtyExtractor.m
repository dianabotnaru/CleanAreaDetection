//
//  ExtractDirty.m
//  grayscale test
//
//  Created by jordi on 4/10/17.
//  Copyright © 2017 afco. All rights reserved.
//

#import "DirtyExtractor.h"
#import "SGConstant.h"

#define NO_DIRTY_PIXEL          0x0
#define PINK_DIRTY_PIXEL        0xFF00FFFF
#define BLUE_DIRTY_PIXEL        0x00FFFFFF

#define PIXEL_STEP              3
#define AREA_DIRTY_RATE      0.95

#define MAX_DIRTY_VALUE         10.0f

#define MIN_LOCAL_AREA_PERCENT  0.01f

@implementation DirtyExtractor

- (id) init
{
    self = [super init];
    return self;
}

-(instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if(self){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *colorOffset = [defaults objectForKey:@"coloroffset"];
        if(colorOffset == nil){
            m_colorOffset = SGDefaultColorOffset;
        }else{
            m_colorOffset = [colorOffset intValue];
        }
        [self reset];
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
    _dirtyValue = 0.0f;
    _localDirtyValue = 0.0f;
    
    m_imageWidth = 0;
    m_imageHeight = 0;
    
    m_nPinkCount = 0;
    m_nBlueCount = 0;
    
    _areaDirtyState = [[NSMutableArray alloc] init];
    
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
            if([self areaFiltering:x withYPoint:y])
                m_nBlueCount++;
        }
    }
    [self calculateDirtyValue];
}

- (bool)areaFiltering :(int)xPoint withYPoint:(int)yPoint
{
    UInt32 * pPixelBuffer = m_donePreprocess ? m_pOutBuffer : m_pInBuffer;
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
                dirtyCount ++;
            }
        }
    }
    
    if(dirtyCount>AREA_DIRTY_RATE* m_imageHeight*m_imageWidth/(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER)){
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
        [_areaDirtyState addObject:@(YES)];
        return true;
    }
    else{
        [_areaDirtyState addObject:@(NO)];
        return false;
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
    _dirtyValue =  10*(float)m_nBlueCount / (float)(AREA_DIVIDE_NUMBER*AREA_DIVIDE_NUMBER);
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
        return NO_DIRTY_PIXEL;
    
    int yellowValue = rgba->r + rgba->g;
    int greenValue = rgba->g + rgba->b;
    int pinkValue = rgba->r + rgba->b;
    
    
    BOOL isPinkSerial = pinkValue > greenValue;
    if (isPinkSerial)
    {
        if(pinkValue>(yellowValue-m_colorOffset))
            return PINK_DIRTY_PIXEL;
        else
            return NO_DIRTY_PIXEL;
    }
    else //means green serial
    {
        return BLUE_DIRTY_PIXEL;
    }
}


- (double) ColourDistance:(RGBA*) e1
{
    long rmean = ( (long)e1->r + (long)255 ) / 2;
    long r = (long)e1->r - 255;
    long g = (long)e1->g-0;
    long b = (long)e1->b-128;
    return sqrt((((512+rmean)*r*r)>>8) + 4*g*g + (((767-rmean)*b*b)>>8));
}

-(void)setColorOffset:(int)colorOffset{
    m_colorOffset = colorOffset;
}


@end
