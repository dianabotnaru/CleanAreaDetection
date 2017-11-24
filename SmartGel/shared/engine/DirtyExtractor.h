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
@property (nonatomic, strong)   NSMutableArray  *areaDirtyState;

@property (nonatomic, assign, readonly)   float   dirtyValue;
@property (nonatomic, assign, readonly)   float   localDirtyValue;

- (void)        reset;

- (void)        importImage:(UIImage *)image;
- (UIImage *)   exportImage;

- (void)        extract;
-(instancetype)initWithImage:(UIImage *)image;
@end
