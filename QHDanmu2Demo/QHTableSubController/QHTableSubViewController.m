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

#define kQHDanmuSwitchKey @"QHDanmuSwitchKey"

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
    id bStartObj = [[NSUserDefaults standardUserDefaults] objectForKey:kQHDanmuSwitchKey];
    if (bStartObj != nil) {
        if ([bStartObj boolValue] == NO) {
            _danmuSwitch.on = NO;
            [danmuView stop];
        }
    }
    self.danmuView = danmuView;
}

#pragma mark - Action

- (IBAction)testSendAction:(id)sender {
    [_danmuView insertData:@[@{@"body": @{@"n": @"小白", @"c": [NSString stringWithFormat:@"(%i)-讲得挺好，一听就明白。", 2]}}, @{@"body": @{@"n": @"小白", @"c": [NSString stringWithFormat:@"(%i)-讲得挺好，一听就明白。", 2]}}]];
}

- (IBAction)switchChangeAction:(id)sender {
    UISwitch *s = sender;
    if (s.on == NO) {
        [_danmuView stop];
    }
    else {
        [_danmuView start];
    }
    [[NSUserDefaults standardUserDefaults] setBool:s.on forKey:kQHDanmuSwitchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
