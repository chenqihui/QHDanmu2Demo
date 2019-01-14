//
//  QHDanmuManagerViewController.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/10.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHDanmuManagerViewController.h"

#import "QHDanmuView.h"
#import "QHViewUtil.h"
#import "QHBaseUtil.h"
#import "QHDanmuManager.h"
#import "NSTimer+QHEOCBlocksSupport.h"

NSString * const kDanmuContentKey = @"c";
NSString * const kDanmuTimeKey = @"v";

#define kDanmuFontSize 18

@interface QHDanmuManagerViewController () <QHDanmuViewDataSource, QHDanmuViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *danmuViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *mediaPlayShowView;

@property (nonatomic, strong) NSTimer *mediaPlayTimer;
@property (nonatomic) CFTimeInterval mediaPlayAbsoluteTime;

@property (nonatomic, strong) QHDanmuView *danmuView;
@property (nonatomic, strong) QHDanmuManager *danmuManager;

@end

@implementation QHDanmuManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _mediaPlayAbsoluteTime = 0;
    
    QHDanmuView *danmuView = [[QHDanmuView alloc] initWithFrame:CGRectZero style:QHDanmuViewStyleCustom];
    danmuView.dataSource = self;
    danmuView.delegate = self;
    danmuView.danmuPoolMaxCount = 20;
    [_danmuViewContainer addSubview:danmuView];
    [QHViewUtil fullScreen:danmuView];
    [danmuView registerClass:[QHDanmuViewCell class] forCellReuseIdentifier:@"1"];
    _danmuView = danmuView;
    
    QHDanmuManager *danmuManager = [[QHDanmuManager alloc] initWithDanmuView:_danmuView];
    danmuManager.startTimeBlock = ^CFTimeInterval(NSDictionary *data) {
        CFTimeInterval startTime = [data[@"v"] doubleValue];
        return startTime;
    };
    _danmuManager = danmuManager;
    
    [self p_addDanmuData];
}

#pragma mark - Private

- (void)p_addDanmuData {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [[path stringByAppendingPathComponent:@"QHDanmuSource"] stringByAppendingPathExtension:@"plist"];
    NSArray *data = [NSArray arrayWithContentsOfFile:path];
    [_danmuManager addDanmu:data];
}

- (void)p_go {
    _danmuManager.mediaPlayAbsoluteTime = _mediaPlayAbsoluteTime;
}

- (void)p_addNextData {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [[path stringByAppendingPathComponent:@"QHDanmuSourceNext"] stringByAppendingPathExtension:@"plist"];
    NSArray *data = [NSArray arrayWithContentsOfFile:path];
    [_danmuManager addDanmu:data];
}

#pragma mark - QHDanmuViewDataSource

- (NSInteger)numberOfPathwaysInDanmuView:(QHDanmuView *)danmuView forAnimationSection:(NSInteger)section {
    return 3;
}

- (CGFloat)heightOfPathwayCellInDanmuView:(QHDanmuView *)danmuView forAnimationSection:(NSInteger)section {
    CGSize size = [QHBaseUtil getSizeWithString:@"陈" fontSize:kDanmuFontSize];
    return size.height;
}

- (QHDanmuViewCell *)danmuView:(QHDanmuView *)danmuView cellForPathwayWithData:(NSDictionary *)data forAnimationSection:(NSInteger)section {
    NSString *s = [NSString stringWithFormat:@"%@-%@", data[@"v"], data[@"c"]];
    QHDanmuViewCell *cell = [danmuView dequeueReusableCellWithIdentifier:@"1"];
    cell.textLabel.attributedText = [QHBaseUtil toHTML:s fontSize:kDanmuFontSize];
    return cell;
}

- (BOOL)waitWhenNowHasNoPathwayInDanmuView:(QHDanmuView * _Nonnull)danmuView withData:(NSDictionary * _Nonnull)data forAnimationSection:(NSInteger)section {
    if ([data[@"x"] integerValue] == 1) {
        return YES;
    }
    return NO;
}

#pragma mark - QHDanmuViewDelegate

- (CGFloat)danmuView:(QHDanmuView *)danmuView widthForPathwayWithData:(NSDictionary *)data forAnimationSection:(NSInteger)section {
    NSString *s = [NSString stringWithFormat:@"%@-%@", data[@"v"], data[@"c"]];
    NSAttributedString *c = [QHBaseUtil toHTML:s fontSize:kDanmuFontSize];
    return c.size.width;
}

#pragma mark - Action

- (IBAction)playAction:(id)sender {
    [_danmuManager start];
    // 模拟播放器回调
    if (_mediaPlayTimer == nil) {
        __weak typeof(self) weakSelf = self;
        _mediaPlayTimer = [NSTimer qheoc_scheduledTimerWithTimeInterval:1 block:^{
            weakSelf.mediaPlayAbsoluteTime++;
            weakSelf.mediaPlayShowView.text = [NSString stringWithFormat:@"%.1f", weakSelf.mediaPlayAbsoluteTime];
            [weakSelf p_go];
            if (weakSelf.mediaPlayAbsoluteTime == 9) {
                [weakSelf p_addNextData];
            }
        } repeats:YES];
    }
}

- (IBAction)stopAction:(id)sender {
    [_danmuManager stop];
}

- (IBAction)resumeAction:(id)sender {
    [_danmuManager resume];
}

- (IBAction)pauseAction:(id)sender {
    [_danmuManager pause];
}

- (IBAction)sendAction:(id)sender {
    [_danmuManager insertDanmu:@{@"c": @"现在全场我说了算", @"x": @(1)}];
}

@end
