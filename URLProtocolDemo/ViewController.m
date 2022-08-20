//
//  ViewController.m
//  URLProtocolDemo
//
//  Created by lanht on 2022/8/19.
//

#import "ViewController.h"
#import "CustomURLProtocol1.h"
#import "CustomURLProtocol2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSURLProtocol registerClass:[CustomURLProtocol1 class]];
    
    [NSURLProtocol registerClass:[CustomURLProtocol2 class]];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self startRequest];
}

- (void)startRequest {
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error -- %@", error.localizedDescription);
        }
    }];
    [task resume];
}

@end
