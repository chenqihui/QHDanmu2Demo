//
//  QHDetailRootViewController.m
//  QHTableDemo
//
//  Created by chen on 17/3/13.
//  Copyright © 2017年 chen. All rights reserved.
//

#import "QHDetailRootViewController.h"

#import "QHDanmuView.h"
#import "QHViewUtil.h"
#import "QHBaseUtil.h"

@interface QHDetailRootViewController () <QHDanmuViewDataSource, QHDanmuViewDelegate>

@property (nonatomic, strong) QHDanmuView *danmuView;

@end

@implementation QHDetailRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat w = [UIScreen mainScreen].bounds.size.width - 20;
    UIView *c = [[UIView alloc] initWithFrame:CGRectMake(10, 200, w, 300)];
    c.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:c];
    
    QHDanmuView *danmuView = [[QHDanmuView alloc] initWithFrame:CGRectZero style:QHDanmuViewStyleCustom];
    danmuView.dataSource = self;
    danmuView.delegate = self;
    danmuView.danmuPoolMaxCount = 10;
    danmuView.searchPathwayMode = QHDanmuViewSearchPathwayModeBreadthFirst;
    [c addSubview:danmuView];
    [QHViewUtil fullScreen:danmuView];
    [danmuView registerClass:[QHDanmuViewCell class] forCellReuseIdentifier:@"1"];
    _danmuView = danmuView;
    
    
    UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b1 setTitle:@"pause" forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [b1 setFrame:CGRectMake(10, 100, 60, 30)];
    [b1 addTarget:self action:@selector(b1Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b1];
    
    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b2 setTitle:@"send" forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [b2 setFrame:CGRectMake(CGRectGetMaxX(b1.frame) + 20, 100, 40, 30)];
    [b2 addTarget:self action:@selector(b2Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b2];
    
    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b3 setTitle:@"resume" forState:UIControlStateNormal];
    [b3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [b3 setFrame:CGRectMake(CGRectGetMaxX(b2.frame) + 20, 100, 60, 30)];
    [b3 addTarget:self action:@selector(b3Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Util


#pragma mark - QHDanmuViewDataSource

- (NSInteger)numberOfPathwaysInDanmuView:(QHDanmuView *)danmuView {
    return 10;
}

- (CGFloat)heightOfPathwayCellInDanmuView:(QHDanmuView *)danmuView {
    CGSize size = [QHBaseUtil getSizeWithString:@"陈" fontSize:15];
    return size.height;
}

- (QHDanmuViewCell *)danmuView:(QHDanmuView *)danmuView cellForPathwayWithData:(NSDictionary *)data {
    QHDanmuViewCell *cell = [danmuView dequeueReusableCellWithIdentifier:@"1"];
    cell.textLabel.attributedText = [QHBaseUtil toHTML:data[@"c"] fontSize:15];
    return cell;
}

#pragma mark - QHDanmuViewDelegate

- (CGFloat)danmuView:(QHDanmuView *)danmuView widthForPathwayWithData:(NSDictionary *)data {
    NSAttributedString *c = [QHBaseUtil toHTML:data[@"c"] fontSize:15];
    return c.size.width;
}

#pragma mark - Action

- (void)b1Action {
//    [_danmuView cleanData];
    [_danmuView pause];
}

static int pwId = 0;

- (void)b2Action {
    pwId++;
    [_danmuView insertData:@[@{@"n": @"小白", @"c": [NSString stringWithFormat:@"(%i)-讲得挺好，一听就明白。", pwId]}] withRowAnimation:QHDanmuViewCellAnimationRight];
//    [_danmuView insertDanmuData:@[@{@"n": @"小白", @"c": [NSString stringWithFormat:@"讲得挺好，一听就明白。"]}]];
}

- (void)b3Action {
    [_danmuView resume];
}

@end
