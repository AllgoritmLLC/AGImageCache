//
//  AGImageCacheDefines.h
//  AGImageCacheExamples
//
//  Created by develop on 09/02/15.
//  Copyright (c) 2015 Allgoritm LLC. All rights reserved.
//

#ifndef AGImageCache_AGImageCacheDefines_h
#define AGImageCache_AGImageCacheDefines_h

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIImage.h>
typedef UIImage AGImage;
#else
typedef NSImage AGImage;
#endif

typedef void(^AGImageCacheCompletion)(AGImage* image, NSString* url, NSError* error);

#endif
