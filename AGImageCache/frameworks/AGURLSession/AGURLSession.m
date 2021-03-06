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

#import "AGURLSession.h"

#import "VBDefines.h"

#ifdef DEBUG1
#define AGSessionLog(str, ...) VBLog(str, ##__VA_ARGS__);
#else
#define AGSessionLog(str, ...)
#endif

@interface AGURLSession ()

@property (nonatomic, strong) NSURLSession* session;
@property (nonatomic, strong) dispatch_queue_t queueCompletion;

@end

@implementation AGURLSession

- (instancetype) init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

        sessionConfig.allowsCellularAccess = NO;
        
//        [sessionConfig setHTTPAdditionalHeaders:
//         @{@"Accept": @"application/json"}];
        
//        sessionConfig.timeoutIntervalForRequest = 30.0;
//        sessionConfig.timeoutIntervalForResource = 60.0;
//        sessionConfig.HTTPMaximumConnectionsPerHost = 1;
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
        self.queueCompletion = dispatch_queue_create("AGURLSessionServiceQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSURLSessionConfiguration *) sessionConfiguration {
    return self.session.configuration;
}

#pragma mark - json task
- (void) loadJSONWithURLString:(NSString*)urlString
                    completion:(AGURLSessionJSONCompletion)completion  {
    [self loadTask:[self jsonTaskWithURLString:urlString
                                    completion:completion]];
}

- (void) loadJSONWithURL:(NSURL*)url
              completion:(AGURLSessionJSONCompletion)completion {
    [self loadTask:[self jsonTaskWithURL:url
                              completion:completion]];
}

- (void) loadJSONWithURLRequest:(NSURLRequest*)request
                                  completion:(AGURLSessionJSONCompletion)completion {
    [self loadTask:[self jsonTaskWithURLRequest:request
                                     completion:completion]];
}

- (NSURLSessionTask*) jsonTaskWithURLString:(NSString*)urlString
                                 completion:(AGURLSessionJSONCompletion)completion  {
    
    return [self jsonTaskWithURL:[NSURL URLWithString:urlString]
                      completion:completion];
}

- (NSURLSessionTask*) jsonTaskWithURL:(NSURL*)url
                           completion:(AGURLSessionJSONCompletion)completion {
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    return [self jsonTaskWithURLRequest:request
                             completion:completion];
}

- (NSURLSessionTask*) jsonTaskWithURLRequest:(NSURLRequest*)request
                     completion:(AGURLSessionJSONCompletion)completion {
    __weak typeof(self) __self = self;
    return [self dataTaskWithURLRequest:request
                             completion:^(NSData *data, NSError *error) {
                                 dispatch_async(__self.queueCompletion, ^{
                                     id json = nil;
                                     NSError* jsonError = nil;
                                     if (error == nil) {
                                         json = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                                  error:&jsonError];
                                         if (jsonError == nil && json && [json isKindOfClass:[NSArray class]] == NO) {
                                             json = [NSArray arrayWithObject:json];
                                         }
                                     }
                                     if (!error && !jsonError) {
                                         AGSessionLog(@"(http:%@) success \nurl:%@ \njson:%@", @(httpCode), response.URL.absoluteString, json);
                                     }
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (completion) {
                                             completion(json, error, jsonError);
                                         }
                                     });
                                 });
                             }];
}

#pragma mark - data task
- (void) loadDataWithURLString:(NSString*)urlString
                    completion:(AGURLSessionDataCompletion)completion {
    
    [self loadTask:[self dataTaskWithURLString:urlString
                                    completion:completion]];
}
- (void) loadDataWithURL:(NSURL*)url
              completion:(AGURLSessionDataCompletion)completion {
    [self loadTask:[self dataTaskWithURL:url
                              completion:completion]];
}
- (void) loadDataWithURLRequest:(NSURLRequest*)request
                     completion:(AGURLSessionDataCompletion)completion {
    [self loadTask:[self dataTaskWithURLRequest:request
                                     completion:completion]];
}


- (NSURLSessionTask*) dataTaskWithURLString:(NSString*)urlString
                                 completion:(AGURLSessionDataCompletion)completion {
    
    return [self dataTaskWithURL:[NSURL URLWithString:urlString]
                      completion:completion];
}

- (NSURLSessionTask*) dataTaskWithURL:(NSURL*)url
                           completion:(AGURLSessionDataCompletion)completion {
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    return [self dataTaskWithURLRequest:request
                             completion:completion];
}

- (NSURLSessionTask*) dataTaskWithURLRequest:(NSURLRequest*)request
                                  completion:(AGURLSessionDataCompletion)completion {
    
    __weak typeof(self) __self = self;
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     dispatch_async(__self.queueCompletion, ^{
                                                         NSInteger httpCode = ((NSHTTPURLResponse*)response).statusCode;
                                                         if (error) {
                                                             AGSessionLog(@"(http:%@) failure\nurl:%@ \nnetworkError:%@", @(httpCode), response.URL.absoluteString,  error);
                                                         }else{
                                                             AGSessionLog(@"(http:%@) success\nurl:%@", @(httpCode), response.URL.absoluteString);
                                                         }
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             if (completion) {
                                                                 completion(data, error);
                                                             }
                                                         });
                                                     });
                                                 }];
    return task;
}

#pragma mark - task
- (void) loadTask:(NSURLSessionTask*)task {
    [task resume];
}

- (void) cancelTask:(NSURLSessionTask*)task {
    [task cancel];
}

#pragma mark - url builder
- (NSString*) urlStringWithSchema:(AGURLSchema)schema
                       serverPath:(NSString*)serverPath
                   additionalPath:(NSString*)additionalPath
                           params:(NSDictionary*)params {
    
    NSString* urlPath = [NSString stringWithFormat:@"%@://%@", [self schemaSrtingWithSchema:schema], serverPath];
    if (additionalPath.length) {
        urlPath = [urlPath stringByAppendingPathComponent:additionalPath];
    }
    if (params.allKeys.count) {
        urlPath = [urlPath stringByAppendingFormat:@"?%@", [self paramsStringFromDictionary:params]];
    }
    return urlPath;
}

- (NSString*) paramsStringFromDictionary:(NSDictionary*) params {
    NSMutableArray* pairs = [NSMutableArray new];
    
    for (NSString* key in params.allKeys) {
        id value = params[key];
        NSString* valueString = [value isKindOfClass:[NSString class]] ? value : [NSString stringWithFormat:@"%@", value];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self encodedString:valueString]]];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}

- (NSString*) schemaSrtingWithSchema:(AGURLSchema)schema {
    return schema == AGURLSchemaHttps ? @"https" : @"http";
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
