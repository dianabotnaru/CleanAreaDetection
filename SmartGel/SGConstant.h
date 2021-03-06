//
//  SGConstant.h
//  SmartGel
//
//  Created by jordi on 15/10/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//
#import "AppDelegate.h"

#ifndef SGConstant_h
#define SGConstant_h

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define SGColorBlack UIColorFromRGB(0x262D36)
#define SGColorDarkGray UIColorFromRGB(0x323A45)
#define SGColorDarkGreen UIColorFromRGB(0x3AA7CB)
#define SGColorDarkPink UIColorFromRGB(0xC04399)
#define SGColorDarkYellow UIColorFromRGB(0x323A45)

#define SGColorLigtGray UIColorFromRGB(0xE0E0E0)

#define SGDefaultColorOffset 5
#define SGGridCount 10

#define _SGAppDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

#endif /* SGConstant_h */
