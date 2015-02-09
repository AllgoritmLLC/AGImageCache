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

#import "AGImageCacheManager.h"

#import "AGImageCacheDefines.h"

#import "AGURLSession.h"
#import "VBDefines.h"

#if defined(DEBUG) && 0
#define AGImageCacheManagerLog(format, ...) VBLog(format, ## __VA_ARGS__)
#else
#define AGImageCacheManagerLog(format, ...)
#endif

@interface AGImageCacheManager ()

@property (nonatomic, strong) AGURLSession* session;

@end

@implementation AGImageCacheManager

+ (instancetype) sharedInstance {
    static AGImageCacheManager* __instance = nil;
    if (nil == __instance) {
        __instance = [AGImageCacheManager new];
    }
    return __instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.session = [AGURLSession new];
    }
    return self;
}

#pragma mark - load
+ (void) loadImageWithUrl:(NSString*)url
              saveToCache:(BOOL)saveToCache
                   sender:(id)sender
               completion:(AGImageCacheCompletion)completion {
    [[self sharedInstance] loadImageWithUrl:[NSURL URLWithString:url]
                                saveToCache:saveToCache
                                     sender:sender
                                 completion:completion];
}

- (void) loadImageWithUrl:(NSURL*) url
              saveToCache:(BOOL) saveToCache
                   sender:(id) sender
               completion:(AGImageCacheCompletion) completion{
    
    @synchronized(self){
        NSString* cachePath = [self cachePathWithUrl:url];
        AGImage* image = [[AGImage alloc] initWithContentsOfFile:cachePath];

        if (nil == image) {
            [self.session loadDataWithURL:url
                               completion:^(NSData *data, NSError *networkError) {
                                   AGImage* image = nil;
                                   if (networkError == nil && data) {
                                            image = [[AGImage alloc] initWithData:data];
                                           if (image) {
                                               AGImageCacheManagerLog(@"DID LOAD image\nurl: %@", url);
                                               if (saveToCache) {
                                                   [data writeToFile:cachePath
                                                          atomically:YES];
                                               }
                                           }else{
                                               AGImageCacheManagerLog(@"DID FAIL to read loaded image\nurl: %@", url);
                                           }
                                       }else{
                                           AGImageCacheManagerLog(@"DID FAIL to load image \nurl: %@\nerror: %@", url, error);
                                       }
                               }];
        } else {
            AGImageCacheManagerLog(@"DID FOUND image\nurl: %@", url);
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image, url.absoluteString, nil);
                });
            }
        }
    }
}

+ (void) cancelLoadingWithSender:(id)sender {
    
}

#pragma mark - path
- (NSString*) cacheDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

- (NSString*) cachePathWithUrl:(NSURL*)url {
    NSString* path = [[self cacheDirectory] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    path = [path stringByAppendingPathComponent:url.lastPathComponent];
    return path;
}

@end