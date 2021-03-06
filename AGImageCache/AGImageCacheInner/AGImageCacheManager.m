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

#import <UIKit/UIScreen.h>

#if defined(DEBUG) && 0
#define AGImageCacheManagerLog(format, ...) VBLog(format, ## __VA_ARGS__)
#else
#define AGImageCacheManagerLog(format, ...)
#endif

#define AGImageCacheManagerCleanupInterval  60 * 10

NSInteger AGImageCacheMaxBytes = 1024 * 1024 * 10;
NSInteger AGImageCacheMaxFileAge = 60 * 60 * 24;
BOOL AGImageCacheUseScreenScale = YES;

@interface AGImageCacheManager ()

@property (nonatomic, strong) AGURLSession* session;
@property (nonatomic, strong) NSMutableArray* tasks;

@property (nonatomic, strong) dispatch_queue_t queueCleanup;

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
        self.tasks = [NSMutableArray new];
        self.queueCleanup = dispatch_queue_create("AGImageCacheManagerQueue", DISPATCH_QUEUE_SERIAL);

        [self runCleanup];
    }
    return self;
}

#pragma mark - load
+ (void) loadImageWithUrl:(NSString*) url
              forceReload:(BOOL) forceReload
           useScreenScale:(BOOL) useScreenScale
                   sender:(id) sender
               completion:(AGImageCacheCompletion) completion {
    
    [[self sharedInstance] loadImageWithUrl:[NSURL URLWithString:url]
                                forceReload:forceReload
                             useScreenScale:useScreenScale
                                     sender:sender
                                 completion:completion];
}

- (void) loadImageWithUrl:(NSURL*) url
              forceReload:(BOOL) forceReload
           useScreenScale:(BOOL) useScreenScale
                   sender:(id) sender
               completion:(AGImageCacheCompletion) completion {
    
    @synchronized(self){
        NSString* cachePath = [self cachePathWithUrl:url];
        AGImage* image = [[AGImage alloc] initWithContentsOfFile:cachePath];

        if (nil == image || forceReload) {
            __weak typeof(self) __self = self;
            NSURLSessionTask* task = [self.session dataTaskWithURL:url
                                                        completion:^(NSData *data, NSError *networkError) {
                                                            AGImage* image = nil;
                                                            if (networkError == nil && data) {
                                                                image = [[AGImage alloc] initWithData:data];
                                                                
                                                                if (useScreenScale) {
                                                                    image = [UIImage imageWithCGImage:image.CGImage
                                                                                                scale:[UIScreen mainScreen].scale
                                                                                          orientation:image.imageOrientation];
                                                                }
                                                                
                                                                if (image) {
                                                                    AGImageCacheManagerLog(@"DID LOAD image\nurl: %@", url);
                                                                    [data writeToFile:cachePath
                                                                           atomically:YES];
                                                                }else{
                                                                    AGImageCacheManagerLog(@"DID FAIL to read loaded image\nurl: %@", url);
                                                                }
                                                            }else{
                                                                AGImageCacheManagerLog(@"DID FAIL to load image \nurl: %@\nerror: %@", url, networkError);
                                                            }
                                                            [__self removeCompletedTasks];

                                                            if (completion) {
                                                                completion(image, url.absoluteString, networkError);
                                                            }
                                                        }];
            if (sender) {
                [self cancelLoadingWithSender:sender];
                [self.tasks addObject:@[task, sender]];
            }
            [self.session loadTask:task];
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
    [[self sharedInstance] cancelLoadingWithSender:sender];
}
- (void) cancelLoadingWithSender:(id)sender {
    NSArray* tasksEntry = [[self.tasks objectsAtIndexes:
                           [self.tasks indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return obj[1] == sender;
    }]] lastObject];
    
    if (tasksEntry) {
        NSURLSessionTask* taskPrev = tasksEntry[0];
        if (taskPrev.state != NSURLSessionTaskStateCompleted) {
            [self.session cancelTask:taskPrev];
            [self.tasks removeObject:tasksEntry];
        }
    }
}

- (void) removeCompletedTasks {
    NSArray* tasksCompleted = [self.tasks objectsAtIndexes:
                               [self.tasks indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSURLSessionTask* tmpTask = (NSURLSessionTask*)obj[0];
        return tmpTask.state == NSURLSessionTaskStateSuspended || tmpTask.state == NSURLSessionTaskStateCompleted;
    }]];
    for (NSArray* tasksEntry in tasksCompleted) {
        [self.session cancelTask:tasksEntry[0]];
        [self.tasks removeObject:tasksEntry];
    }
}

#pragma mark - cleanup
- (void) runCleanup {
    __weak typeof(self) __self = self;
    dispatch_async(self.queueCleanup, ^{
        while (YES) {
            [__self cleanupOldImages];
            sleep(AGImageCacheManagerCleanupInterval);
        }
    });
}
- (void) cleanupOldImages {
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error = nil;
    NSArray* paths = [fm contentsOfDirectoryAtPath:[self cacheDirectory]
                                             error:&error];
    NSString* pathKey = @"path";
    NSMutableArray* files = [NSMutableArray new];
    for (NSString* path in paths) {
        NSError* err = nil;
        NSString* fullPath = [[self cacheDirectory] stringByAppendingPathComponent:path];
        NSDictionary* attrib = [fm attributesOfItemAtPath:fullPath
                                                    error:&err];
        if (err) continue;
        
        NSTimeInterval interval = ABS([[NSDate date] timeIntervalSinceDate:attrib[NSFileCreationDate]]);
        if (interval > AGImageCacheMaxFileAge) {
            [fm removeItemAtPath:fullPath
                           error:nil];
        }else{
            [files addObject:@{pathKey:             fullPath,
                               NSFileSize:          attrib[NSFileSize],
                               NSFileCreationDate:  attrib[NSFileCreationDate]}];
        }
    }
    
    [files sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSFileCreationDate ascending:YES]]];
    
    double totalSize = [[files valueForKeyPath:@"@sum.NSFileSize"] doubleValue];
    double sizeExceeding = totalSize > AGImageCacheMaxBytes ? totalSize - AGImageCacheMaxBytes : 0;
    if (sizeExceeding > 0) {
        double sizeRemoved = 0;
        for (NSInteger i = 0; i < files.count; i++) {
            NSDictionary* entry = files[i];
            [fm removeItemAtPath:entry[pathKey]
                           error:nil];
            sizeRemoved += [entry[NSFileSize] doubleValue];
            if (sizeRemoved > sizeExceeding) {
                break;
            }
        }
    }
}

#pragma mark - path
- (NSString*) cacheDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString* dirPath = [paths lastObject];
    dirPath = [[dirPath stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"AGImageCache"];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath
                                             isDirectory:&isDir] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    return dirPath;
}

- (NSString*) cachePathWithUrl:(NSURL*)url {
    NSString* path = [self cacheDirectory];
    NSString* urlAbsolute = url.absoluteString;
    urlAbsolute = [self encodedString:urlAbsolute];
    path = [path stringByAppendingPathComponent:urlAbsolute];
    if (path.length >= FILENAME_MAX) {
        path = [path substringFromIndex:path.length - FILENAME_MAX - 1];
    }
    return path;
}

- (NSString*) encodedString:(NSString*)string {
    NSString* encoded =
    (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                          NULL, /* allocator */
                                                                          (__bridge CFStringRef)string,
                                                                          NULL, /* charactersToLeaveUnescaped */
                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]._",
                                                                          kCFStringEncodingUTF8));
    return encoded;
}

@end
