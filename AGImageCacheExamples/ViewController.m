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

@property (nonatomic, strong) IBOutlet UIButton* bn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AGImageCacheMaxFileAge = 10;
    
    self.iv1.contentMode =
    self.iv2.contentMode = UIViewContentModeCenter;
    
    NSString* path = @"http://buyingvalue.com/wp-content/uploads/2011/03/tony_the_tiger-lg-200x200.jpg";
    
    [self.iv1 setImageWithUrlString:path placeholder:nil forceReload:YES useScreenScale:YES completion:nil];
    [self.iv2 setImageWithUrlString:path placeholder:nil forceReload:YES useScreenScale:NO completion:nil];
    
    [self.bn setImageWithUrlString:path
                          forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
