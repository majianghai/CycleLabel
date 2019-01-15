//
//  ViewController.m
//  CycleLabel
//
//  Created by aiyunxiao on 2019/1/15.
//  Copyright © 2019年 aiyunxiao. All rights reserved.
//

#import "ViewController.h"
#import "YXCycleLabel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet YXCycleLabel *cycleLB;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     tips:
        1.项目开发中，这三个text、textColor、font都是必填的，所以我对着三个属性进行了判断，一定要赋值呦
        2.如果你使用xib进行布局，那么也不要忘了给label设置宽高。
     */
    //
    self.cycleLB.text = @"本次作业有2题需要老师批改，批改后答题统计自动更新。方可查看作业正确率";
    self.cycleLB.textColor = [UIColor redColor];
    self.cycleLB.font = [UIFont systemFontOfSize:18];
}


@end
