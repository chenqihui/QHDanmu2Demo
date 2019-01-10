//
//  QHTableSubViewController.m
//  QHTableViewDemo
//
//  Created by chen on 17/3/21.
//  Copyright © 2017年 chen. All rights reserved.
//

#import "QHTableSubViewController.h"

#import "SLCDanmuViewCell.h"
#import "QHViewUtil.h"

@interface QHTableSubViewController ()

@end

@implementation QHTableSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addDanmuView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addDanmuView {
    QHDanmuView *danmuView = [[QHDanmuView alloc] initWithFrame:CGRectZero style:QHDanmuViewStyleCustom];
    danmuView.dataSource = self;
    danmuView.delegate = self;
    [self.playView addSubview:danmuView];
    [QHViewUtil fullScreen:danmuView];
    [danmuView registerClass:[SLCDanmuViewCell class] forCellReuseIdentifier:kSLCDanmuViewCellContentIdentifier];
    self.danmuView = danmuView;
}

#pragma mark - Action

- (IBAction)testSendAction:(id)sender {
    if (_danmuSwitch.on == NO) {
        return;
    }
    [_danmuView insertData:@[@{@"body": @{@"n": @"小白", @"c": [NSString stringWithFormat:@"(%i)-讲得挺好，一听就明白。", 2]}}, @{@"body": @{@"n": @"小白", @"c": [NSString stringWithFormat:@"(%i)-讲得挺好，一听就明白。", 2]}}]];
}

- (IBAction)switchChangeAction:(id)sender {
    UISwitch *s = sender;
    if (s.on == NO) {
        [_danmuView cleanData];
    }
}

@end
