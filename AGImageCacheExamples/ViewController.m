//
//  ViewController.m
//  AGImageCacheExamples
//
//  Created by develop on 09/02/15.
//  Copyright (c) 2015 Allgoritm LLC. All rights reserved.
//

#import "ViewController.h"

#import "AGImageCache.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIImageView* iv1;
@property (nonatomic, strong) IBOutlet UIImageView* iv2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AGImageCacheMaxFileAge = 10;
    
    [self.iv1 setImageWithUrlString:@"http://img.drive.ru/i/0/54d889fe95a6568b3d000003.jpg" placeholder:nil forceReload:NO completion:nil];
    [self.iv2 setImageWithUrlString:@"http://img.drive.ru/i/0/54d885fa95a656de3300000a.jpg" placeholder:nil forceReload:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
