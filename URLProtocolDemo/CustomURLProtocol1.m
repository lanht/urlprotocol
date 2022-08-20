//
//  CustomURLProtocol1.m
//  URLProtocolDemo
//
//  Created by lanht on 2022/8/20.
//

#import "CustomURLProtocol1.h"

static NSString * const HTCustomURLProtocolHandledKey = @"HTCustomURLProtocolHandledKey1";

@interface CustomURLProtocol1 ()

// 在拓展中定义一个 NSURLConnection 属性。通过 NSURLSession 也可以拦截，这里只是以 NSURLConnection 为例。
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation CustomURLProtocol1

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
//    NSLog(@"protocol1 --- %s  requestInfo --- %@",__FUNCTION__, request.description);
    NSLog(@"%s ",__FUNCTION__);

    if ([NSURLProtocol propertyForKey:HTCustomURLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSLog(@"%s",__FUNCTION__);
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    return mutableRequest;
}

- (void)startLoading {
    NSLog(@"%s",__FUNCTION__);

    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
       // 打 tag，防止递归调用
   [NSURLProtocol setProperty:@YES forKey:HTCustomURLProtocolHandledKey inRequest:mutableRequest];
   // 也可以在这里检查缓存
   // 将 request 转发，对于 NSURLConnection 来说，就是创建一个 NSURLConnection 对象；对于 NSURLSession 来说，就是发起一个 NSURLSessionTask。
   self.connection = [NSURLConnection connectionWithRequest:mutableRequest delegate:self];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    NSLog(@"%s",__FUNCTION__);

    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)stopLoading {
    NSLog(@"%s",__FUNCTION__);

    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
}

#pragma mark- NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark - NSURLConnectionDataDelegate

// 当接收到服务器的响应（连通了服务器）时会调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s", __func__);
//    self.responseData = [[NSMutableData alloc] init];
    // 可以处理不同的 statusCode 场景
    // NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    // 可以设置 Cookie
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

// 接收到服务器的数据时会调用，可能会被调用多次，每次只传递部分数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.responseData appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

// 服务器的数据加载完毕后调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
