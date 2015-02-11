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

#import "UIButton+AGImageCache.h"

#import "AGImageCacheDefines.h"
#import "AGImageCacheManager.h"

#import "UIImage+AGImageCache.h"

@implementation UIButton (AGImageCache)

#pragma mark - image
- (void) setImageWithUrlString:(NSString*) urlString
                      forState:(UIControlState) state {
    [self setImageWithUrlString:urlString
                placeholderName:nil
                       forState:state];
}

- (void) setImageWithUrlString:(NSString*) urlString
               placeholderName:(NSString*) placeholderName
                      forState:(UIControlState) state {
    [self setImageWithUrlString:urlString
                    placeholder:[UIImage imageNamed:placeholderName]
                       forState:state
                     completion:nil];
}

- (void) setImageWithUrlString:(NSString*) urlString
                   placeholder:(UIImage*) placeholder
                      forState:(UIControlState) state {
    [self setImageWithUrlString:urlString
                    placeholder:placeholder
                       forState:state
                     completion:nil];
}

- (void) setImageWithUrlString:(NSString*) urlString
               placeholderName:(NSString*) placeholderName
                      forState:(UIControlState) state
                    completion:(AGImageCacheCompletion)completion {
    [self setImageWithUrlString:urlString
                    placeholder:[UIImage imageNamed:placeholderName]
                       forState:state
                     completion:completion];
}

- (void) setImageWithUrlString:(NSString*) urlString
                   placeholder:(UIImage*) placeholder
                      forState:(UIControlState) state
                    completion:(AGImageCacheCompletion)completion {
    [self setImageWithUrlString:urlString
                    placeholder:placeholder
                       forState:state
                    forceReload:NO
                 useScreenScale:AGImageCacheUseScreenScale
                     completion:completion];
}

#pragma mark full
- (void) setImageWithUrlString:(NSString*) urlString
                   placeholder:(UIImage*) placeholder
                      forState:(UIControlState) state
                   forceReload:(BOOL) forceReload
                useScreenScale:(BOOL) useScreenScale
                    completion:(AGImageCacheCompletion)completion {
    
    if (placeholder) {
        [self setImage:placeholder
              forState:state];
    }
    
    if (urlString != nil) {
        __weak typeof(self) __self = self;
        
        [self cancelLoadingImages];
        [AGImageCacheManager loadImageWithUrl:urlString
                                  forceReload:forceReload
                               useScreenScale:useScreenScale
                                       sender:self
                                   completion:^(UIImage *image, NSString *imageUrl, NSError *error) {
                                       if (!__self) return;
                                       
                                       if (!error && image) {
                                           [__self setImage:image
                                                   forState:state];
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

#pragma mark - background image
- (void) setBackgroundImageWithUrlString:(NSString*) urlString
                                forState:(UIControlState) state {
    [self setBackgroundImageWithUrlString:urlString
                          placeholderName:nil
                                 forState:state];
}

- (void) setBackgroundImageWithUrlString:(NSString*) urlString
                         placeholderName:(NSString*) placeholderName
                                forState:(UIControlState) state {
    [self setBackgroundImageWithUrlString:urlString
                              placeholder:[UIImage imageNamed:placeholderName]
                                 forState:state
                               completion:nil];
}

- (void) setBackgroundImageWithUrlString:(NSString*) urlString
                             placeholder:(UIImage*) placeholder
                                forState:(UIControlState) state {
    [self setBackgroundImageWithUrlString:urlString
                              placeholder:placeholder
                                 forState:state
                               completion:nil];
}

- (void) setBackgroundImageWithUrlString:(NSString*) urlString
                         placeholderName:(NSString*) placeholderName
                                forState:(UIControlState) state
                              completion:(AGImageCacheCompletion)completion {
    [self setBackgroundImageWithUrlString:urlString
                              placeholder:[UIImage imageNamed:placeholderName]
                                 forState:state
                               completion:completion];
}

- (void) setBackgroundImageWithUrlString:(NSString*) urlString
                             placeholder:(UIImage*) placeholder
                                forState:(UIControlState) state
                              completion:(AGImageCacheCompletion)completion {
    [self setBackgroundImageWithUrlString:urlString
                              placeholder:placeholder
                                 forState:state
                              forceReload:NO
                           useScreenScale:AGImageCacheUseScreenScale
                               completion:completion];
}

#pragma mark full
- (void) setBackgroundImageWithUrlString:(NSString*) urlString
                   placeholder:(UIImage*) placeholder
                      forState:(UIControlState) state
                   forceReload:(BOOL) forceReload
                useScreenScale:(BOOL) useScreenScale
                    completion:(AGImageCacheCompletion)completion {
    
    if (placeholder) {
        [self setBackgroundImage:placeholder
                        forState:state];
    }
    
    if (urlString != nil) {
        __weak typeof(self) __self = self;
        
        [self cancelLoadingImages];
        [AGImageCacheManager loadImageWithUrl:urlString
                                  forceReload:forceReload
                               useScreenScale:useScreenScale
                                       sender:self
                                   completion:^(UIImage *image, NSString *imageUrl, NSError *error) {
                                       if (!__self) return;
                                       
                                       if (!error && image) {
                                           [__self setBackgroundImage:image
                                                             forState:state];
                                       }
                                       if (completion) {
                                           completion(image, imageUrl, error);
                                       }
                                   }];
    }
}

@end
