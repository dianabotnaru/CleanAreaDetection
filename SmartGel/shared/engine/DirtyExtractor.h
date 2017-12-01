//
//  ExtractDirty.h
//  grayscale test
//
//  Created by jordi on 4/10/17.
//  Copyright © 2017 afco. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AREA_DIVIDE_NUMBER      100

typedef struct
{
    UInt8 a;
    UInt8 b;
    UInt8 g;
    UInt8 r;
}RGBA;

typedef struct
{
    float x;
    float y;
    float z;
}XYZ;

typedef struct
{
    float l;
    float a;
    float b;
}LAB;

@interface DirtyExtractor : NSObject
{
    UInt32 *    m_pInBuffer;
    UInt32 *    m_pOutBuffer;
    
    int         m_imageWidth;
    int         m_imageHeight;
    
    BOOL        m_donePreprocess;
    
    int         m_nPinkCount;
    int         m_nBlueCount;
}
@property (nonatomic, strong)   NSMutableArray  *areaCleanState;

@property (nonatomic, assign, readonly)   float   cleanValue;

@property (nonatomic, assign)   int   m_colorOffset;

- (void)        reset;

- (void)        importImage:(UIImage *)image;
- (UIImage *)   exportImage;

- (void)        extract;
-(instancetype)initWithImage:(UIImage *)image;
-(instancetype)initWithImage:(UIImage *)image withColoroffset:(int)coloroffset;

@end
