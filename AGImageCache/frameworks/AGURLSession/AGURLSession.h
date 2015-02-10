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

#import <Foundation/Foundation.h>

typedef void (^AGURLSessionJSONCompletion)(NSArray* jsonResponse, NSError* networkError, NSError* jsonError);
typedef void (^AGURLSessionDataCompletion)(NSData* data, NSError* networkError);

typedef enum{
    AGURLSchemaHttp = 0,
    AGURLSchemaHttps
}AGURLSchema;

@interface AGURLSession : NSObject

@property (nonatomic, weak, readonly) NSURLSessionConfiguration* sessionConfiguration;

#pragma mark - json task
- (void) loadJSONWithURLString:(NSString*)urlString
                    completion:(AGURLSessionJSONCompletion)completion;
- (void) loadJSONWithURL:(NSURL*)url
              completion:(AGURLSessionJSONCompletion)completion;
- (void) loadJSONWithURLRequest:(NSURLRequest*)request
                     completion:(AGURLSessionJSONCompletion)completion;

- (NSURLSessionTask*) jsonTaskWithURLString:(NSString*)urlString
                                 completion:(AGURLSessionJSONCompletion)completion;
- (NSURLSessionTask*) jsonTaskWithURL:(NSURL*)url
                           completion:(AGURLSessionJSONCompletion)completion;
- (NSURLSessionTask*) jsonTaskWithURLRequest:(NSURLRequest*)request
                                  completion:(AGURLSessionJSONCompletion)completion;

#pragma mark - data task
- (void) loadDataWithURLString:(NSString*)urlString
                    completion:(AGURLSessionDataCompletion)completion;
- (void) loadDataWithURL:(NSURL*)url
              completion:(AGURLSessionDataCompletion)completion;
- (void) loadDataWithURLRequest:(NSURLRequest*)request
                     completion:(AGURLSessionDataCompletion)completion;


- (NSURLSessionTask*) dataTaskWithURLString:(NSString*)urlString
                                 completion:(AGURLSessionDataCompletion)completion;
- (NSURLSessionTask*) dataTaskWithURL:(NSURL*)url
                           completion:(AGURLSessionDataCompletion)completion;
- (NSURLSessionTask*) dataTaskWithURLRequest:(NSURLRequest*)request
                                  completion:(AGURLSessionDataCompletion)completion;


#pragma mark - url builder
- (NSString*) urlStringWithSchema:(AGURLSchema)schema
                       serverPath:(NSString*)serverPath
                   additionalPath:(NSString*)additionalPath
                           params:(NSDictionary*)params;

@end
