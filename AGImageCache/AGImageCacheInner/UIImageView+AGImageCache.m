//
//    The MIT License (MIT)
//
//    Copyright (c) 2015 Allgoritm LLC
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

#import "UIImageView+AGImageCache.h"

#import "AGImageCacheDefines.h"
#import "AGImageCacheManager.h"

@implementation UIImageView (AGImageCache)

- (void) setImageWithUrlString:(NSString*) urlString {
    [self setImageWithUrlString:urlString
                placeholderName:nil];
}

- (void) setImageWithUrlString:(NSString*) urlString
               placeholderName:(NSString*) placeholderName {
    [self setImageWithUrlString:urlString
                    placeholder:[UIImage imageNamed:placeholderName]
                     completion:nil];
}

- (void) setImageWithUrlString:(NSString*) urlString
                   placeholder:(UIImage*) placeholder {
    [self setImageWithUrlString:urlString
                    placeholder:placeholder
                     completion:nil];
}

- (void) setImageWithUrlString:(NSString*) urlString
               placeholderName:(NSString*) placeholderName
                    completion:(AGImageCacheCompletion)completion {
    [self setImageWithUrlString:urlString
                    placeholder:[UIImage imageNamed:placeholderName]
                     completion:completion];
}

- (void) setImageWithUrlString:(NSString*) urlString
                   placeholder:(UIImage*) placeholder
                    completion:(AGImageCacheCompletion)completion {
    [self setImageWithUrlString:urlString
                    placeholder:placeholder
                       useCache:YES
                     completion:completion];
}

#pragma mark - full
- (void) setImageWithUrlString:(NSString*) urlString
                   placeholder:(UIImage*) placeholder
                      useCache:(BOOL) useCache
                    completion:(AGImageCacheCompletion)completion {
    
    if (placeholder) {
        self.image = placeholder;
    }
    
    if (urlString != nil) {
        __weak UIImageView* __self = self;
        [AGImageCacheManager cancelLoadingWithSender:self];
        [AGImageCacheManager loadImageWithUrl:urlString
                                     useCache:useCache
                                       sender:self
                                   completion:^(UIImage *image, NSString *imageUrl, NSError *error) {
                                         if (!__self) return;
                                         
                                         if (!error && image && [imageUrl isEqualToString:urlString]) {
                                             __self.image = image;
                                         }
                                         if (completion) {
                                             completion(image, imageUrl, error);
                                         }
                                   }];
    }
}

- (void) cancelLoadingImages {
    [AGImageCacheManager cancelLoadingWithSender:self];
}

@end
