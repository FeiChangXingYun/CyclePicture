//
//  ViewController.m
//  JYYPictureCircle
//
//  Created by Yanyan Jiang on 2017/11/29.
//  Copyright © 2017年 Yanyan Jiang. All rights reserved.
//

#import "ViewController.h"
#import "JYYCycleView.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    JYYCycleView *cycleView = [[JYYCycleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-300)];
    cycleView.imageURLS = [self loadData];
    [self.view addSubview:cycleView];
}


#pragma mark -自定义方法
//加载图片数据
- (NSArray *)loadData{
    NSMutableArray *arrayM = [[NSMutableArray alloc]init];
    for(int i = 0;i<10;i++){
        NSString *fileName = [NSString stringWithFormat:@"%02d.jpg",i+1];
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        [arrayM addObject:url];
    }
    return arrayM.copy;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
